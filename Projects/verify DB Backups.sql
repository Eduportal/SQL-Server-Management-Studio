--USE [msdb]
--GO
--CREATE		NONCLUSTERED INDEX [IX_backupset_backup_start_date_I_backup_set_id_media_set_id_type_database_name]
--	ON	[dbo].[backupset] ([backup_start_date])
--	INCLUDE	([backup_set_id],[media_set_id],[type],[database_name])
--GO


USE [dbaadmin]
GO
/****** Object:  StoredProcedure [dbo].[dbasp_Backup_Verify]    Script Date: 08/27/2012 11:04:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--ALTER PROCEDURE [dbo].[dbasp_Backup_Verify]

--/*********************************************************
-- **  Stored Procedure dbasp_Backup_Verify                  
-- **  Written by Jim Wilson, Getty Images                
-- **  August 13, 2012                                      
-- **  
-- **  This dbasp is set up to verify recent sql backups.
-- ** 
-- ***************************************************************/
--  as
set nocount on

--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	08/13/2012	Jim Wilson		New process.
--	======================================================================================

	
-----------------  declares  ------------------

DECLARE
	 @miscprint		nvarchar(255)
	,@cmd			nvarchar(4000)
	,@cmd2			nvarchar(4000)
	,@G_O			nvarchar(2)
	,@firstflag		char(1)
	,@filegroup_flag	char(1)
	,@HoldBackupName	nvarchar(260)
	,@maxBSI_D		int
	,@maxBSI_I		int
	,@output_flag		char(1)
	,@BkUpMethod		nvarchar(10)
	,@Holdfam_seq_num	tinyint
	,@hold_from		nvarchar(5)
	,@hold_comma		nvarchar(1)
	,@save_backup_set_id	int
	,@save_type		char(1)
	,@save_filegroup_name	sysname
	,@save_DBname		sysname
	,@parms			sysname
	,@cEModule		sysname
	,@cECategory		sysname
	,@cEEvent		sysname
	,@cEGUID		uniqueidentifier
	,@cEMessage		nvarchar(max)
	,@cERE_ForceScreen	BIT
	,@cERE_Severity		INT
	,@cERE_State		INT
	,@cERE_With		VarChar(2048)
	,@cEStat_Rows		BigInt
	,@cEStat_Duration	FLOAT
	,@cEMethod_Screen	BIT
	,@cEMethod_TableLocal	BIT
	,@cEMethod_TableCentral	BIT
	,@cEMethod_RaiseError	BIT
	,@cEMethod_Twitter	BIT
	,@StartDate		DATETIME
	,@StopDate		DATETIME
----------------  initial values  -------------------

Select @G_O		= 'g' + 'o'
Select @output_flag	= 'n'
Select @BkUpMethod 	= 'MS'
SELECT	@cEModule	= 'dbasp_Backup_Verify'
	,@cEGUID	= NEWID()


create table #resultstring (message varchar (2500) null) 


/*********************************************************************
 *                Initialization
 ********************************************************************/

----------------------  Main header  ----------------------
Print  ' '
Print  '/************************************************************************'
Select @miscprint = 'Backup Verify Process'  
Print  @miscprint
Select @miscprint = 'For Server: ' + @@servername + ' on '  + convert(varchar(30),getdate(),9)
Print  @miscprint
Print  '************************************************************************/'
Print  ' '

DECLARE BackupVerifyCursor CURSOR
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
		Print '--============================================================================'
		Print @save_DBname
		print @HoldBackupName
		Print '--============================================================================'
	
		Select		@cECategory		= @save_DBname

		---------------------------------------------------
		--	CHECK FOR MISSING FILE
		---------------------------------------------------					

		IF dbaadmin.dbo.dbaudf_CheckFileStatus(@HoldBackupName) != 0
		BEGIN
			
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
	
			exec [dbo].[dbasp_LogEvent]
						 @cEModule
						,@cECategory
						,@cEEvent
						,@cEGUID
						,@cEMessage
						,@cEMethod_Screen = 1
						,@cEMethod_TableLocal = 1
						
			FETCH NEXT FROM BackupVerifyCursor INTO @save_backup_set_id	
					,@save_DBname		
					,@save_type		
					,@save_filegroup_name	
					,@HoldBackupName							

			CONTINUE
		END

	Start_full:

	If @HoldBackupName like '%.sqb' OR @HoldBackupName like '%.sqd'
	   BEGIN
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

		Select @cmd = 'master.dbo.sqlbackup' 
		Select @cmd2 = '-SQL "RESTORE VERIFYONLY' 
				+ ' FROM DISK = [' + rtrim(@HoldBackupName)
				+ ']' + @parms
		Select @cmd2 = @cmd2 + '"' 
		
		---------------------------------------------------
		--	LOG PRE
		---------------------------------------------------					
		
		SELECT	@cEEvent	= 'RedGate Command'
			,@cEMessage	= 'EXEC ' + @cmd + QUOTENAME(@cmd2,'''')
	
		EXEC [dbo].[dbasp_LogEvent]
					 @cEModule
					,@cECategory
					,@cEEvent
					,@cEGUID
					,@cEMessage
					,@cEMethod_Screen = 1
					,@cEMethod_TableLocal = 1
				
		---------------------------------------------------
		--	RUN VERIFY
		---------------------------------------------------					
		DELETE FROM	#resultstring
		SET @StartDate = GetDate()
		INSERT INTO	#resultstring 
		EXEC		@cmd @cmd2 
		SET @StopDate = GetDate()
	   END
	ELSE
	   BEGIN
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

		select @cmd2 = 'RESTORE VERIFYONLY FROM disk = ''' + @HoldBackupName + '''' + @parms
		Select @cmd = 'sqlcmd -S' + @@servername + ' -Q"' + @cmd2 + '" -E'

		---------------------------------------------------
		--	LOG PRE
		---------------------------------------------------					
		
		SELECT	@cEEvent	= 'TSQL Command'
			,@cEMessage	= @cmd2
	
		EXEC [dbo].[dbasp_LogEvent]
					 @cEModule
					,@cECategory
					,@cEEvent
					,@cEGUID
					,@cEMessage
					,@cEMethod_Screen = 1
					,@cEMethod_TableLocal = 1
				
		---------------------------------------------------
		--	RUN VERIFY
		---------------------------------------------------					
		DELETE FROM	#resultstring
		SET @StartDate = GetDate()
		INSERT INTO	#resultstring 
		EXEC Master.sys.xp_cmdshell @cmd
		SET @StopDate = GetDate()
	   END


	   	---------------------------------------------------
		--	LOG RESULTS
		---------------------------------------------------					
		SELECT	@cEEvent		= @HoldBackupName
			,@cEStat_Duration	= DATEDIFF(second,@StartDate,@StopDate) / 60.0000 -- GRANULARITY IN SECONDS RESULT IN MINUTES
			,@cEMessage		= CASE WHEN EXISTS (SELECT 1 FROM #resultstring WHERE Message LIKE '%is valid%') 
							THEN 'Valid' ELSE 'Invalid' END

		--IF EXISTS (SELECT 1 FROM #resultstring WHERE Message LIKE '%is valid%')
		--BEGIN
		--	SELECT	@cEEvent		= @HoldBackupName
		--		,@cEMessage		= 'Valid'
		--		,@cEStat_Duration	= DATEDIFF(second,@StartDate,@StopDate) / 60.0000 -- GRANULARITY IN SECONDS
		--END
		--ELSE
		--BEGIN
		--	SELECT	@cEEvent		= @HoldBackupName
		--		,@cEMessage		= 'Invalid'
		--		,@cEStat_Duration	= DATEDIFF(second,@StartDate,@StopDate) / 60.0000 -- GRANULARITY IN SECONDS
		--END
			
		EXEC [dbo].[dbasp_LogEvent]
					 @cEModule
					,@cECategory
					,@cEEvent
					,@cEGUID
					,@cEMessage
					,@cEStat_Duration	= @cEStat_Duration
					,@cEMethod_Screen	= 1
					,@cEMethod_TableLocal	= 1



	--If not exists (select 1 from #resultstring where message like '%is valid%')
	--   begin
	--	Select @miscprint = 'DBA ERROR: Backup verification failed for DB ' + @save_DBname + ' and backup file ' + @HoldBackupName
	--	--raiserror(67016, 16, -1, @miscprint)
	--	goto label99
	--   end


	----  Check for more rows to process
	--delete from #backupinfo where physical_device_name = @HoldBackupName
	--delete from #backupinfo where type = @save_type and filegroup_name = @save_filegroup_name and database_name = @save_DBname
	--Select @save_backup_set_id = (select top 1 backup_set_id from #backupinfo where database_name = @save_DBname and type in ('D', 'F') order by backup_set_id desc)
	--If @save_backup_set_id is not null
	--   begin
	--	goto Start_full
	--   end


	--skip_full:


	--Select @save_backup_set_id = (select top 1 backup_set_id from #backupinfo where database_name = @save_DBname and type in ('I') order by backup_set_id desc)

	--If @save_backup_set_id is null
	--   begin
	--	Select @miscprint = 'No recent differential backup exists for this DB.  ' + @save_DBname 
	--	Print  @miscprint
	--	Print  ' '
	--	goto skip_diff
	--   end


	--Start_diff:
	--Select @save_type = (select top 1 type from #backupinfo where backup_set_id = @save_backup_set_id and database_name = @save_DBname)
	--Select @save_filegroup_name = (select top 1 filegroup_name from #backupinfo where backup_set_id = @save_backup_set_id and type = @save_type and database_name = @save_DBname)
	--Select @HoldBackupName = (select top 1 physical_device_name from #backupinfo where backup_set_id = @save_backup_set_id and type = @save_type and filegroup_name = @save_filegroup_name and database_name = @save_DBname)

	--Print '--============================================================================'
	--Print @save_DBname
	--print @HoldBackupName
	--Print '--============================================================================'

	--delete from #resultstring

	--If @HoldBackupName like '%.sqd'
	--   begin
	--	--  Redgate verify syntax	
	--   	If exists (select 1 from master.sys.databases where name = @save_DBname and page_verify_option = 2)
	--	   begin
	--		--Select @parms = ' with CHECKSUM, SINGLERESULTSET'
	--		Select @parms = ' with SINGLERESULTSET'
	--	   end
	--	Else
	--	   begin
	--		Select @parms = ' with SINGLERESULTSET'
	--	   end

	--	Select @cmd = 'master.dbo.sqlbackup' 
	--	Select @cmd2 = '-SQL "RESTORE VERIFYONLY' 
	--			+ ' FROM DISK = [' + rtrim(@HoldBackupName)
	--			+ ']' + @parms
	--	Select @cmd2 = @cmd2 + '"' 
		
	--	Print @cmd
	--	Print @cmd2
	--	Print ' '
	--	Insert into #resultstring exec @cmd @cmd2
	--   end
	--Else
	--   begin
	--	--  Standard verify syntax
	--   	If exists (select 1 from master.sys.databases where name = @save_DBname and page_verify_option = 2)
	--	   begin
	--		--Select @parms = ' with CHECKSUM'
	--		Select @parms = ''
	--	   end
	--	Else
	--	   begin
	--		Select @parms = ''
	--	   end

	--	select @cmd2 = 'RESTORE VERIFYONLY FROM disk = ''' + @HoldBackupName + '''' + @parms
	--	Select @cmd = 'sqlcmd -S' + @@servername + ' -Q"' + @cmd2 + '" -E'

	--	Print @cmd
	--	Print ' '
	--	Insert into #resultstring exec master.sys.xp_cmdshell @cmd
	--	select * from #resultstring
	--   end

	--If not exists (select 1 from #resultstring where message like '%is valid%')
	--   begin
	--	Select @miscprint = 'DBA ERROR: Backup verification failed for DB ' + @save_DBname + ' and backup file ' + @HoldBackupName
	--	--raiserror(67016, 16, -1, @miscprint)
	--	goto label99
	--   end


	----  Check for more rows to process
	--delete from #backupinfo where physical_device_name = @HoldBackupName
	--delete from #backupinfo where type = @save_type and filegroup_name = @save_filegroup_name and database_name = @save_DBname
	--Select @save_backup_set_id = (select top 1 backup_set_id from #backupinfo where database_name = @save_DBname and type in ('I') order by backup_set_id desc)
	--If @save_backup_set_id is not null
	--   begin
	--	goto Start_diff
	--   end

	--skip_diff:

	--delete from #backupinfo where database_name = @save_DBname
	--If exists (select 1 from #backupinfo)
	--   begin
	--	goto start01
	--   end

 --  end







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




---------------------------  Finalization  -----------------------
label99:

--drop table #backupinfo
drop table #resultstring



--DECLARE		@HoldBackupName VarChar(8000)
--SET		@HoldBackupName = 'G:\Backup\alliant_dtc_work_db_20120825005747.SQB'

--SELECT		CASE dbaadmin.dbo.dbaudf_CheckFileStatus(@HoldBackupName)
--					WHEN 0			THEN 'File is Good'
--					WHEN -1			THEN 'FileSystemObject could not be created'
--					WHEN -2147024809	THEN 'Parameter is Incorrect'
--					WHEN -2147023570	THEN 'Logon failure: unknown user name or bad password'
--					WHEN -2146828235	THEN 'File Not Found'
--					WHEN -2146828212	THEN 'Path not found'
--					WHEN -2146828218	THEN 'Permission Denied (in use)'
--					WHEN 1			THEN 'Permission Denied (in use)'
--					ELSE CAST(dbaadmin.dbo.dbaudf_CheckFileStatus(@HoldBackupName) AS VarChar(50))
--					END
 
--exec master.dbo.sqlbackup '-SQL "RESTORE VERIFYONLY FROM DISK = [G:\Backup\alliant_dtc_work_db_20120825005747.SQB] with SINGLERESULTSET"'