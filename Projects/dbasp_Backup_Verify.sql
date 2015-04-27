USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Backup_Verify]    Script Date: 09/18/2012 16:51:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Backup_Verify]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Backup_Verify]
GO

USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Backup_Verify]    Script Date: 09/18/2012 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[dbasp_Backup_Verify]
--/*********************************************************
-- **  Stored Procedure dbasp_Backup_Verify                  
-- **  Written by Jim Wilson, Getty Images                
-- **  August 13, 2012                                      
-- **  
-- **  This dbasp is set up to verify recent sql backups.
-- ** 
-- ***************************************************************/
AS
SET	TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- Do not lock anything, and do not get held up by any locks. 
SET	NOCOUNT ON
SET	ANSI_WARNINGS OFF
--	================================================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	========================================================================
--	08/13/2012	Jim Wilson		New process.
--	09/12/2012	Steve Ledridge		Modified process to run Verifyies in a parallel thread and monitoring
--						it for progress. If no progress is made after 10 minutes, checking of
--						that file is aborted. If a file is Locked and older than 4 hours, it is
--						forcably unlocked so that it can be checked. all progress is logged in
--						[dbaadmin].[dbo].[EventLog] WHERE [cEModule] = 'dbasp_Backup_Verify'
--	================================================================================================================

	
-----------------  declares  ------------------

DECLARE		@miscprint			nvarchar(255)
		,@cmd				varchar(8000)
		,@cmd2				varchar(8000)
		,@G_O				nvarchar(2)
		,@firstflag			char(1)
		,@filegroup_flag		char(1)
		,@HoldBackupName		nvarchar(260)
		,@maxBSI_D			int
		,@maxBSI_I			int
		,@output_flag			char(1)
		,@BkUpMethod			nvarchar(10)
		,@Holdfam_seq_num		tinyint
		,@hold_from			nvarchar(5)
		,@hold_comma			nvarchar(1)
		,@save_backup_set_id		int
		,@save_type			char(1)
		,@save_filegroup_name		sysname
		,@save_DBname			sysname
		,@parms				sysname
		,@cEModule			sysname
		,@cECategory			sysname
		,@cEEvent			sysname
		,@cEGUID			uniqueidentifier
		,@cEMessage			nvarchar(max)
		,@cERE_ForceScreen		BIT
		,@cERE_Severity			INT
		,@cERE_State			INT
		,@cERE_With			VarChar(2048)
		,@cEStat_Rows			BigInt
		,@cEStat_Duration		FLOAT
		,@cEMethod_Screen		BIT
		,@cEMethod_TableLocal		BIT
		,@cEMethod_TableCentral		BIT
		,@cEMethod_RaiseError		BIT
		,@cEMethod_Twitter		BIT
		,@StartDate			DATETIME
		,@StopDate			DATETIME
		,@UnD_Results			INT
		,@TXT				VarChar(8000)
		,@NestLevel			INT
	
	
DECLARE		@ThreadID			UniqueIdentifier
		,@Desc				VarChar(8000)
		,@Session_ID			INT
		,@OutputFile			VarChar(8000)
		,@PercentDone			FLOAT
		,@NoProgressCount		INT
		,@PercentDoneString		VarChar(50)
----------------  initial values  -------------------

Select		@G_O				= 'g' + 'o'
		,@output_flag			= 'n'
		,@BkUpMethod 			= 'MS'
		,@cEModule			= 'dbasp_Backup_Verify'
		,@cEGUID			= NEWID()
		,@NestLevel			= 0

/*********************************************************************
 *                Initialization
 ********************************************************************/

----------------------  Main header  ----------------------
EXEC	dbaadmin.dbo.dbasp_Print ' ',@NestLevel,1,1
SET	@TXT = REPLICATE('-',80)
EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1
EXEC	dbaadmin.dbo.dbasp_Print 'Backup Verify Process',@NestLevel,1,1
EXEC	dbaadmin.dbo.dbasp_Print ' ',@NestLevel,1,1
SET	@TXT = 'For Server: ' + @@servername + ' on '  + convert(varchar(30),getdate(),9)
EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1
EXEC	dbaadmin.dbo.dbasp_Print ' ',@NestLevel,1,1
SET	@TXT = REPLICATE('-',80)
EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1
EXEC	dbaadmin.dbo.dbasp_Print ' ',@NestLevel,1,1

SET	@NestLevel = @NestLevel + 1

DECLARE BackupVerifyCursor CURSOR
KEYSET
FOR
SELECT		DISTINCT
		bs.backup_set_id
		, bs.database_name
		, bs.type
		, bf.filegroup_name
		, bmf.physical_device_name 
FROM		msdb.dbo.backupset bs with (NOLOCK)
JOIN		msdb.dbo.backupfile bf with (NOLOCK)
	ON	bs.backup_set_id = bf.backup_set_id
JOIN		msdb.dbo.backupmediafamily bmf with (NOLOCK)
	ON	bs.media_set_id = bmf.media_set_id
WHERE		bs.backup_start_date > getdate()-30
	AND	bf.is_present = 1
	AND	bmf.physical_device_name NOT LIKE '{%'
	AND	bf.filegroup_name is not null
	AND	bs.type in ('D','F','I')
	AND	bmf.physical_device_name NOT IN	(
						SELECT	DISTINCT
							[cEEvent]
						FROM	[dbaadmin].[dbo].[EventLog] WITH(NOLOCK)
						WHERE	[cEModule] = 'dbasp_Backup_Verify'
						  AND	[cEMessage] IN ('Valid','Invalid','File Not Found')
						)
ORDER BY	1 desc

OPEN BackupVerifyCursor
FETCH NEXT FROM BackupVerifyCursor INTO @save_backup_set_id	
					,@save_DBname		
					,@save_type		
					,@save_filegroup_name	
					,@HoldBackupName	

WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		StartOfFileLoop:

		-------------------------------------------------------
		--	CREATE HEADER FOR EACH FILE TO BE CHECKED
		-------------------------------------------------------
		EXEC	dbaadmin.dbo.dbasp_Print ' ',@NestLevel,1,1
		SET	@TXT = REPLICATE('-',80)
		EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1
		SET	@NestLevel = @NestLevel + 1
		EXEC	dbaadmin.dbo.dbasp_Print @save_DBname,@NestLevel,1,1
		EXEC	dbaadmin.dbo.dbasp_Print @HoldBackupName,@NestLevel,1,1
		SET	@NestLevel = @NestLevel - 1
		EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1
		EXEC	dbaadmin.dbo.dbasp_Print ' ',@NestLevel,1,1
		SET	@NestLevel = @NestLevel + 1
		
		Select		@cECategory		= @save_DBname

		-------------------------------------------------------
		--	CHECK FOR MISSING OR LOCKED FILE
		-------------------------------------------------------
		EXEC	@UnD_Results	= [dbaadmin].[dbo].[dbasp_UnlockAndDelete] @HoldBackupName,0,0,@NestLevel -- JUST CHECK FOR LOCKS
		
		SELECT	@cEEvent	= @HoldBackupName
			,@cEMessage	= CASE dbaadmin.dbo.dbaudf_CheckFileStatus(@HoldBackupName)
					WHEN 0			THEN 'File is Good'
					WHEN -1			THEN 'FileSystemObject could not be created'
					WHEN -2147024809	THEN 'Parameter is Incorrect'
					WHEN -2147023570	THEN 'Logon failure: unknown user name or bad password'
					WHEN -2146828235	THEN 'File Not Found'
					WHEN -2146828212	THEN 'Path not found'
					WHEN -2146828218	THEN 'Permission Denied (in use)'
					WHEN 1			THEN 'Permission Denied (in use)'
					ELSE CAST(dbaadmin.dbo.dbaudf_CheckFileStatus(@HoldBackupName) AS VarChar(50))
					END
			,@cEMessage	= CASE	WHEN @UnD_Results > 0 AND DATEDIFF(hour,CAST(dbaadmin.dbo.dbaudf_GetFileProperty(@HoldBackupName,'File','DateCreated') AS DateTime),getdate()) > 0
							THEN 'File is Locked and Older than 4 Hours'
						WHEN @UnD_Results > 0
							THEN 'File is Locked BUT Newer than 4 Hours'
						ELSE @cEMessage END

		exec [dbo].[dbasp_LogEvent]
					 @cEModule
					,@cECategory
					,@cEEvent
					,@cEGUID
					,@cEMessage
					,@cEMethod_Screen = 1
					,@cEMethod_TableLocal = 1
		-----------------------------------------------------------------------
		--   IF FILE IS LOCKED AND MORE THAN 4HRS OLD THEN TRY TO UNLOCK IT
		-----------------------------------------------------------------------
		IF	@cEMessage = 'File is Locked and Older than 4 Hours'
		BEGIN
			EXEC @UnD_Results = [dbaadmin].[dbo].[dbasp_UnlockAndDelete] @HoldBackupName,1,0,@NestLevel -- JUST UNLOCK LOCKS

			exec [dbo].[dbasp_LogEvent]
					 @cEModule
					,@cECategory
					,@cEEvent
					,@cEGUID
					,@cEMessage = 'File was unlocked'
					,@cEMethod_Screen = 1
					,@cEMethod_TableLocal = 1
					
			GOTO StartOfFileLoop -- RESTART LOOP AND CHECK AGIAN
		END

		-----------------------------------------------------------------------
		--	IF FILE IS INVALID FOR ANOTHER REASON THEN SKIP IT FOR NOW
		-----------------------------------------------------------------------
		IF	@cEMessage != 'File is Good'
			GOTO EndOfFileLoop


	-----------------------------------------------------------------------
	--		GENERATE VALIDATE COMMAND BASED ON FILE TYPE
	-----------------------------------------------------------------------
	If @HoldBackupName like '%.sqb' OR @HoldBackupName like '%.sqd' OR @HoldBackupName like '%.mdf'
	   BEGIN
		SELECT @cEEvent	= 'RedGate Command'
		--  Redgate verify syntax	
	   	IF EXISTS (select 1 from master.sys.databases where name = @save_DBname and page_verify_option = 2)
		   BEGIN
			--Select @parms = ' with CHECKSUM, SINGLERESULTSET'
			SELECT @parms = ' with SINGLERESULTSET'
		   END
		ELSE
		   BEGIN
			SELECT @parms = ' with SINGLERESULTSET'
		   END

		SELECT	@CMD	= ' EXEC master.dbo.sqlbackup '
				+ QUOTENAME('-SQL "RESTORE VERIFYONLY' 
				+ ' FROM DISK = [' + rtrim(@HoldBackupName)
				+ ']' + @parms + '"','''')
	   END
	ELSE
	   BEGIN
		SELECT @cEEvent	= 'Native Command'
		--  Standard verify syntax
	   	If exists (select 1 from master.sys.databases where name = @save_DBname and page_verify_option = 2)
		   begin
			--Select @parms = ' with CHECKSUM'
			Select @parms = ''
		   end
		Else
		   begin
			Select @parms = ''
		   end
		select @cmd = 'RESTORE VERIFYONLY FROM disk = ''' + @HoldBackupName + '''' + @parms
	    END		

	---------------------------------------------------
	--	LOG PRE
	---------------------------------------------------					
	EXEC [dbo].[dbasp_LogEvent]
				 @cEModule
				,@cECategory
				,@cEEvent
				,@cEGUID
				,@cEMessage = @cmd 
				,@cEMethod_Screen = 1
				,@cEMethod_TableLocal = 1
			
	---------------------------------------------------
	--	RUN VERIFY
	---------------------------------------------------
	
	SELECT	@StartDate		= GetDate()
		,@NoProgressCount	= 0
		,@PercentDone		= 0
		
	EXEC	dbaadmin.dbo.dbasp_SpawnAsyncTSQLThread	@TSQL = @cmd
			,@ThreadID	= @ThreadID	OUTPUT
			,@Desc		= @Desc		OUTPUT
			,@OutputFile	= @OutputFile	OUTPUT
			,@Session_ID	= @Session_ID	OUTPUT
			

	WHILE EXISTS (SELECT 1 FROM sys.dm_exec_requests WHERE session_id = @Session_ID)
	BEGIN
		IF @PercentDone < (SELECT max(percent_complete) FROM sys.dm_exec_requests WHERE command Like '%RESTORE VERIFYON%')
		BEGIN
			SELECT		@PercentDone		= percent_complete
					,@PercentDoneString	= CAST(percent_complete AS VarChar(50))
					,@NoProgressCount	= 0 -- ANY PROGRESS RESETS COUNTER
			FROM		sys.dm_exec_requests r
			WHERE		command Like '%RESTORE VERIFYON%'

			RAISERROR (N'	-- Still Verifying, %s Percent Done.',-1,-1,@PercentDoneString) WITH NOWAIT
		END
		ELSE
		BEGIN
			SET 	@NoProgressCount = @NoProgressCount + 1	
			RAISERROR (N'	-- Still Verifying, No Progress.',-1,-1) WITH NOWAIT
		END
		
		IF @NoProgressCount > 60
			BREAK -- 60 TIMES AT 10 SECONDS FOR DELAY IS 10 MINUTES WITHOUT PROGRESS
		
		WAITFOR DELAY '00:00:10' 
	END

	SET @StopDate = GetDate()

   	---------------------------------------------------
	--	LOG RESULTS
	---------------------------------------------------					
	SELECT	@cEEvent		= @HoldBackupName
		,@cEStat_Duration	= DATEDIFF(second,@StartDate,@StopDate) -- GRANULARITY IN SECONDS RESULT IN MINUTES
		,@cEMessage		= CASE	WHEN EXISTS (SELECT 1 FROM dbo.dbaudf_FileAccess_Read(@OutputFile,NULL) WHERE [Line] Like '%is valid.%') 
							THEN 'Valid'
						WHEN EXISTS (SELECT 1 FROM dbo.dbaudf_FileAccess_Read(@OutputFile,NULL) WHERE [Line] Like '%failed%') 
							THEN 'Invalid'
						WHEN @NoProgressCount > 60
							THEN 'ProcessHung' 
						ELSE 'Unknown' END

	EXEC [dbo].[dbasp_LogEvent]
				 @cEModule
				,@cECategory
				,@cEEvent
				,@cEGUID
				,@cEMessage
				,@cEStat_Duration	= @cEStat_Duration
				,@cEMethod_Screen	= 1
				,@cEMethod_TableLocal	= 1

	If @cEMessage = 'Invalid'
	   begin
		SELECT * FROM dbo.dbaudf_FileAccess_Read(@OutputFile,NULL)
		Select @miscprint = 'DBA ERROR: Backup verification failed for DB ' + @save_DBname + ' and backup file ' + @HoldBackupName
		RAISERROR (@miscprint,-1,-1) WITH NOWAIT
		--raiserror(67016, 16, -1, @miscprint)
		--goto label99
	   end
	   
	SET @NestLevel = @NestLevel - 1
	
	EndOfFileLoop:
	END
	FETCH NEXT FROM BackupVerifyCursor INTO @save_backup_set_id	
						,@save_DBname		
						,@save_type		
						,@save_filegroup_name	
						,@HoldBackupName
END

CLOSE BackupVerifyCursor
DEALLOCATE BackupVerifyCursor

GO


