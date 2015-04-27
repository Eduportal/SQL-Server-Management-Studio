USE [dbaadmin]
GO
/****** Object:  StoredProcedure [dbo].[dbasp_UnlockAndDelete]    Script Date: 06/12/2012 19:22:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE	[dbo].[dbasp_UnlockAndDelete]
	(
	@FileName			VarChar(1000)
	,@Unlock			BIT				= 0
	,@Delete			BIT				= 0
	,@StartNestLevel	INT				= 0
	)
AS
BEGIN
		SET NOCOUNT ON
		EXEC [dbo].[dbasp_print] 'Database Extended Property "EnableCodeComments" is Enabled',@StartNestLevel
		DECLARE			@TXT			VarChar(1024)
						,@NestLevel		INT 
						,@FileNameFound VarChar(1024)
						,@PID			VarChar(50)
						,@Handle		VarChar(50)
						,@CMD			VarChar(8000)
						,@Result		INT
						,@HandleString	VarChar(8000)

		DECLARE			@HandleTab		TABLE([Row] VarChar(max) NULL)

		SET				@NestLevel		= @StartNestLevel + 1

		IF [dbaadmin].[dbo].[dbaudf_GetFileProperty] (@FileName,'File','Path') IS NULL
		BEGIN	
				SET @TXT = @FileName + ' Does Not Exist.' ; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1
				RETURN
		END
		
		SET @TXT = 'Checking Handles on '+@FileName; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1;

		Select	@cmd		= 'handle ' 
							+ QUOTENAME(@FileName,'"')
							+ ' -accepteula'
				,@NestLevel	= @NestLevel + 1
				,@TXT		= @cmd

		EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		
		INSERT INTO @HandleTab([Row])
		EXEC @Result = master.sys.xp_cmdshell @cmd

		DELETE	@HandleTab	WHERE [ROW] NOT LIKE '%'+REPLACE(@FileName,'.sql','')+'%' OR [ROW] IS NULL

		SELECT	@NestLevel	= @NestLevel - 1
				,@TXT		= 'Locks:'
		EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		SELECT	@NestLevel	= @NestLevel + 1

		IF NOT EXISTS(SELECT 1 FROM @HandleTab)
		BEGIN
			SET @TXT = 'No Locks Found'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1

			IF @Delete = 1
			BEGIN
				SELECT	@NestLevel	= @NestLevel + 1
						,@TXT		= 'Deleting...' 
				EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1

				SELECT	@CMD		= 'DEL ' + QUOTENAME(@FileName,'"')
						,@TXT		= @cmd
				EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
				EXEC	@Result		= master.sys.xp_cmdshell @cmd,no_output		

				SELECT	@TXT		= 'Deleted.'
				EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1
				SELECT	@NestLevel	= @NestLevel - 1
			END		
		END
		
		DECLARE Delete_Cursor CURSOR
		KEYSET FOR SELECT [ROW] FROM @HandleTab
		OPEN Delete_Cursor
		FETCH NEXT FROM Delete_Cursor INTO @HandleString
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN
						-- CLEAR CURSOR VARIABLES
						SELECT	@FileNameFound = NULL, @PID = NULL, @Handle = NULL
						
						-- GET AND DISECT HANDLE RECORD
						SELECT	Identity(int,1,1)[RowId], [SplitValue]
						INTO	#HandleBits
						FROM	dbaadmin.dbo.dbaudf_split(@HandleString,' ')
						WHERE	COALESCE([SplitValue],'')!=''
						ORDER BY [OccurenceId]
						
						-- POPULATE VARIABLES TO PROCESS HANDLE
						SELECT		@Handle			= CASE RowID WHEN 4 THEN REPLACE([SplitValue],':','') ELSE @Handle END
									,@PID			= CASE RowID WHEN 3 THEN [SplitValue] ELSE @PID END
									,@FileNameFound	= CASE RowID WHEN 5 THEN [SplitValue] ELSE @FileNameFound END
						FROM		#HandleBits
						DROP TABLE	#HandleBits

						-- DISPLAY FILE HANDLE
						SET @TXT = 'Lock Found on ' + @FileNameFound + ' (PID:' + @PID + ' HANDLE:' + @Handle + ')'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1

						IF @Unlock = 1
						BEGIN
							SELECT	@NestLevel	= @NestLevel + 1
									,@TXT		= 'Unlocking...' 
							EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1

							SELECT	@cmd		= 'handle -c ' + @Handle + ' -p ' + @Pid + ' -y'
									,@TXT		= @cmd
							EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
							EXEC	@Result		= master.sys.xp_cmdshell @cmd,no_output

							SELECT	@TXT		= 'Unlocked.'
							EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1
							SELECT	@NestLevel	= @NestLevel - 1
						END
						
						IF @Delete = 1
						BEGIN
							SELECT	@NestLevel	= @NestLevel + 1
									,@TXT		= 'Deleting...' 
							EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1

							SELECT	@CMD		= 'DEL ' + QUOTENAME(@FileNameFound,'"')
									,@TXT		= @cmd
							EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
							EXEC	@Result		= master.sys.xp_cmdshell @cmd,no_output		

							SELECT	@TXT		= 'Deleted.'
							EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1
							SELECT	@NestLevel	= @NestLevel - 1
						END
		
			END
			FETCH NEXT FROM Delete_Cursor INTO @HandleString
		END
		CLOSE Delete_Cursor
		DEALLOCATE Delete_Cursor

END
 
GO




USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_RunTSQL]    Script Date: 06/12/2012 22:03:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE	[dbo].[dbasp_RunTSQL]
	(
	@Name				VarChar(1000)	= NULL
	,@TSQL				VarChar(8000)	= NULL
	,@DBName			sysname			= NULL
	,@Server			sysname			= NULL
	,@Login				sysname			= NULL
	,@Password			sysname			= NULL
	,@OutputPath		VarChar(1000)	= NULL
	,@OutputFile		VarChar(1000)	= NULL
	,@SQLcmdOptions		VarChar(1000)	= ' -I -p -b -e'
	,@StartNestLevel	INT				= 0
	,@OutputText		VarChar(max)	= NULL OUTPUT
	,@OutputMatrix		INT				= NULL -- NULL=DYNAMIC,0=NONE Bit-Matrix(1=Screen,2=File,4=Parameter) ONLY APLIES TO QUERY RESULTS: DEBUG MESSAGES ALL GO TO SCREEN
	,@DebugMatrix		INT				= 0 -- NULL=0=NONE Bit-Matrix(1=Dont Delete Temp OUT File,2=Dont Delete Temp SQL File,4=,8=,16=)
	)
AS
BEGIN
	SET NOCOUNT ON
	EXEC [dbo].[dbasp_print] 'Database Extended Property "EnableCodeComments" is Enabled',@StartNestLevel
	DECLARE			@extprop_cmd	nVarChar(4000)
					,@PARAMETERS	nVarChar(4000)
					,@ExtPropChk	sysname
					,@CMD			VarChar(8000)
					,@Result		Int
					,@UniqueName	sysname
					,@Results		varChar(max)
					,@Results_part	varChar(8000)
					,@Marker1		INT
					,@Marker2		INT
					,@NestLevel		INT
					,@CRLF			CHAR(2)
					,@TXT			VarChar(max)
					,@HandleString	varchar(max)
					,@Handle		varchar(25)
					,@Pid			varchar(25)
					,@cEGUID		VarChar(50)
					,@ErrorCount	INT
					
	DECLARE			@HandleTab		TABLE([Row] VarChar(max) NULL)
	DECLARE			@ResultTab		TABLE([Lineno] INT, [Line] VarChar(max) NULL)

	SELECT			@cEGUID			= CAST(value as VarChar(50))
					,@ErrorCount	= 0
	FROM			DEPLinfo.sys.fn_listextendedproperty('DEPLInstanceID', default, default, default, default, default, default)	

	SET	@TXT = 'Starting '+COALESCE(OBJECT_NAME(@@PROCID),'');EXEC dbaadmin.dbo.dbasp_Print @TXT,@StartNestLevel

	-- SET CONSTANTS
	SELECT			@NestLevel		= @StartNestLevel + 1
					,@CRLF			= CHAR(13) + CHAR(10)
					,@UniqueName	= sys.fn_repluniquename(NEWID(),object_name(@@Procid),default,default,default)+'.out'
					,@Server		= COALESCE(@Server,@@servername)
					,@DBName		= COALESCE(@DBName,'master')
					,@SQLcmdOptions	= COALESCE(' -U' + @Login + ' -P' + @Password,' -E') + COALESCE(@SQLcmdOptions,'') + ' -o' + QUOTENAME(@UniqueName,'"')
					,@extprop_cmd	= 'DECLARE @TXT VarChar(max)' + @CRLF
									+ 'SET @TXT = ''Setting ''+@ExtProp+'' ExtendedProperty to "''+@ExtPropVal+''"''' + @CRLF
									+ 'EXEC dbaadmin.dbo.dbasp_Print @TXT, @NestLevel' + @CRLF
									+ 'SELECT      @ExtPropChk = CAST(value AS SYSNAME)' + @CRLF
									+ 'FROM  '+@DBName+'.sys.fn_listextendedproperty(@ExtProp, default, default, default, default, default, default)' + @CRLF
									+ 'IF @@ROWCOUNT = 0' + @CRLF
									+ '  EXEC '+@DBName+'.sys.sp_addextendedproperty @name=@ExtProp, @value=@ExtPropVal' + @CRLF
									+ 'ELSE' + @CRLF
									+ '  EXEC '+@DBName+'.sys.sp_updateextendedproperty @name=@ExtProp, @value=@ExtPropVal'
					,@PARAMETERS	= '@ExtProp sysname,@ExtPropVal sysname,@ExtPropChk sysname OUT,@NestLevel INT'
      
	-- Set the extended property 'DeplFileName'
	exec sp_executesql 
		@statement		= @extprop_cmd
		, @params		= @PARAMETERS
		, @ExtProp		= 'DeplFileName'
		, @ExtPropVal	= @Name
		, @ExtPropChk	= @ExtPropChk OUT
		, @NestLevel	= @NestLevel
		
	IF COALESCE(@cEGUID,'') != ''
	BEGIN
			INSERT INTO [dbaadmin].[dbo].[BuildSchemaChanges]
					   (
					   [EventType]
					   ,[DatabaseName]
					   ,[DEPLFileName]
					   ,[SQLCommand]
					   ,[ObjectName]
					   ,[ObjectType]
					   ,[EventDate]
					   ,[Status]
						)
			select		'DEPL_RUN_SCRIPT'
						,@DBName
						,@Name
						,@TSQL
						,@OutputFile
						,@OutputPath
						,getdate()
						,'STARTING'	
	END

	IF @TSQL IS NULL
	BEGIN	-- RUN FILE ----------------------------------------------------------
			----------------------------------------------------------------------
			--																	--
			--						START FILE BLOCK							--
			--																	--
			----------------------------------------------------------------------
			----------------------------------------------------------------------
	SET @TXT = 'Executing File'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		-- Execute the File	
		SELECT	@Results	= @CRLF + @CRLF + 'Running DB\file: ' + @DBName + ' \ ' + @Name + '		'  
							+ @CRLF + CAST(Getdate() AS VarChar(50))  + @CRLF + @CRLF
				,@NestLevel	= @NestLevel + 1
				,@cmd		= 'sqlcmd -S' + @Server 
							+ ' -d' + @DBName
							+ ' -i' + @Name
							+ @SQLcmdOptions
		IF [dbo].[dbaudf_GetFileProperty] (@Name,'File','Path') IS NULL
			BEGIN
				SELECT	@TXT			= 'Error: The File, ' + @Name + ', Does Not Exist.'
						,@OutputText	= @TXT
				EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1 -- ALWAYS PRINT ERROR
				RETURN -1			
			END
		SET @TXT = @cmd; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		EXEC @Result = master.sys.xp_cmdshell @cmd,no_output
		If @Result !=0
		BEGIN
			SELECT	@TXT			= 'Error: Script Execution Returned This Error Code (' + CAST(@Result AS VarChar) + ')' 
					,@OutputText	= @TXT
			EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1 -- ALWAYS PRINT ERROR
			RETURN	@Result
		END
	END		-- RUN FILE ----------------------------------------------------------
			----------------------------------------------------------------------
			--																	--
			--							END FILE BLOCK							--
			--																	--
			----------------------------------------------------------------------
			----------------------------------------------------------------------
	ELSE
	BEGIN	-- RUN SCRIPT --------------------------------------------------------
			----------------------------------------------------------------------
			--																	--
			--						START SCRIPT BLOCK							--
			--																	--
			----------------------------------------------------------------------
			----------------------------------------------------------------------
	SET @TXT = 'Executing Script'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		-- Execute the TSQL Script
		SET		@Results = @CRLF + @CRLF + 'Running TSQL SCRIPT: 		' + CAST(Getdate() AS VarChar(50))  +@CRLF + @CRLF
				
		Select	@NestLevel	= @NestLevel + 1
				,@UniqueName= REPLACE(@UniqueName,'.out','.sql')
				,@cmd		= 'sqlcmd -S' + @Server 
							+ ' -d' + @DBName
							+ ' -i' + QUOTENAME(@UniqueName,'"')
							+ @SQLcmdOptions
							
		SET @TXT = 'Writing Script to Temp File '+@UniqueName; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		EXEC	dbaadmin.[dbo].[dbasp_FileAccess_Write]	@TSQL,@UniqueName,null,0
				
		SET @TXT = @cmd; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		EXEC @Result = master.sys.xp_cmdshell @cmd,no_output
		If @Result !=0
		BEGIN
			SELECT	@ErrorCount = @ErrorCount + 1
					,@NestLevel = @NestLevel + 1
			
			SET		@TXT			= 'Error: Script Execution Returned This Error Code (' + CAST(@Result AS VarChar) + ')'; 
			EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1 -- ALWAYS PRINT ERROR
			SELECT	@NestLevel		= @NestLevel - 1
			
		END
		
		-- UNLOCK AND DELETE TEMP .SQL FILE
		IF @DebugMatrix & 2 != 2
		BEGIN
			SET @TXT = 'Deleting Temp .SQL File ' + @UniqueName; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
			EXEC dbo.dbasp_UnlockAndDelete @UniqueName,1,1,@NestLevel
		END
		ELSE
		BEGIN
			SET @TXT = 'Temp .SQL File ' + @UniqueName + ' was NOT Deleted.'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1
		END
						
		SET		@UniqueName= REPLACE(@UniqueName,'.sql','.out')
	END		-- RUN SCRIPT --------------------------------------------------------
			----------------------------------------------------------------------
			--																	--
			--						END SCRIPT BLOCK							--
			--																	--
			----------------------------------------------------------------------
			----------------------------------------------------------------------

	SET @NestLevel = @NestLevel + 1
	BEGIN	-- GET OUTPUT --------------------------------------------------------
			----------------------------------------------------------------------
			--																	--
			--					START GATHER OUTPUT BLOCK						--
			--																	--
			----------------------------------------------------------------------
			----------------------------------------------------------------------
			
		-- OUTPUT SCRIPT TO WINDOW AFTER EVERYTHING ELSE UNLESS OUTPUT FILE SET
		SET		@TXT = 'Getting Results'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
			
		SELECT		@NestLevel	= @NestLevel + 1
					,@Marker1	= 0
		
		SET		@TXT = 'Reading Results into Table'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel	
		INSERT INTO	@ResultTab([Lineno],[Line])
		SELECT		[Lineno],[Line]
		FROM		dbaadmin.dbo.dbaudf_FileAccess_Read(@UniqueName,NULL)
		ORDER BY	[Lineno]

		SET		@TXT = 'Agrigating Results Into Variable'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		SELECT		@Results = @Results+COALESCE([Line],'') + @CRLF
		FROM		@ResultTab
		ORDER BY	[Lineno]

	END		-- GET OUTPUT --------------------------------------------------------
			----------------------------------------------------------------------
			--																	--
			--						END GATHER OUTPUT BLOCK						--
			--																	--
			----------------------------------------------------------------------
			----------------------------------------------------------------------

	BEGIN	-- SHOW OUTPUT -------------------------------------------------------
			----------------------------------------------------------------------
			--																	--
			--						START SHOW OUTPUT BLOCK						--
			--																	--
			----------------------------------------------------------------------
			----------------------------------------------------------------------

		If @OutputMatrix IS NULL -- DYNAMICLY BUILD MATRIX FROM PARAMETERS
		BEGIN
			SET		@TXT = '@OutputMatrix was NULL, Building Dynamicly.'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
			SET	@OutputMatrix = 0
			IF	@OutputPath IS NULL SET @OutputMatrix = @OutputMatrix | 1		--SET SCREEN BIT
			IF	@OutputPath IS NOT NULL SET @OutputMatrix = @OutputMatrix | 2	--SET FILE BIT
			SET @OutputMatrix = @OutputMatrix | 4								--SET PARAMETER BIT
		END

		IF @OutputMatrix & 1 = 1 -- CHECK SCREEN BIT
		BEGIN
			-- OUTPUT TO SCREEN
			SET		@TXT = '@OutputMatrix Screen=YES'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
						
			PrintMore: -- LOOP THROUGH 1k+ Chunks of the results Printing them using the first LF after 1k as the break point so it looks right

				SET @Marker2 = CHARINDEX(CHAR(10),@Results,@Marker1 + 1024)
				IF @Marker2 = 0
					SET @Marker2 = LEN(@Results)

				SET @TXT = SUBSTRING(@Results,@Marker1,(@Marker2-@Marker1)-1); EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,0,1;

				SET @Marker1 = @Marker2 + 1
				If @Marker2 < LEN(@Results)
					GOTO PrintMore
		END
		ELSE
		BEGIN
			SET		@TXT = '@OutputMatrix Screen=NO'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		END

		IF @OutputMatrix & 2 = 2 -- CHECK FILE BIT
		BEGIN
			-- OUTPUT TO FILE
			SET		@TXT = '@OutputMatrix File=YES'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
			EXEC	dbaadmin.[dbo].[dbasp_FileAccess_Write]	@Results,@OutputPath,@OutputFile,1
		END
		ELSE
		BEGIN
			SET		@TXT = '@OutputMatrix File=NO'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		END
		
		IF @OutputMatrix & 4 = 4 -- CHECK PARAMETER BIT
		BEGIN
			-- OUTPUT TO PARAMETER
			SET		@TXT = '@OutputMatrix Parameter=YES'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
			SET		@OutputText = @Results
		END
		ELSE
		BEGIN
			SET		@TXT = '@OutputMatrix Parameter=NO'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		END
		
	END		-- SHOW OUTPUT -------------------------------------------------------
			----------------------------------------------------------------------
			--																	--
			--						END SHOW OUTPUT BLOCK						--
			--																	--
			----------------------------------------------------------------------
			----------------------------------------------------------------------	

	-- UNLOCK AND DELETE TEMP .OUT FILE
	IF @DebugMatrix & 1 != 1
	BEGIN
		SET @TXT = 'Deleting Temp .OUT File ' + @UniqueName; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		EXEC dbo.dbasp_UnlockAndDelete @UniqueName,1,1,@NestLevel
	END
	ELSE
	BEGIN
		SET @TXT = 'Temp .OUT File ' + @UniqueName + ' was NOT Deleted.'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1
	END
	
	-- CLEANUP AND CLOSE -------------------------------------------------
	----------------------------------------------------------------------
	--																	--
	--						CLEANUP AND CLOSE							--
	--																	--
	----------------------------------------------------------------------
	----------------------------------------------------------------------
			
	IF COALESCE(@cEGUID,'') != ''
	BEGIN
			INSERT INTO [dbaadmin].[dbo].[BuildSchemaChanges]
					   (
					   [EventType]
					   ,[DatabaseName]
					   ,[DEPLFileName]
					   ,[SQLCommand]
					   ,[ObjectName]
					   ,[ObjectType]
					   ,[EventDate]
					   ,[Status]
						)
			select		'DEPL_RUN_SCRIPT'
						,@DBName
						,@Name
						,@TSQL
						,@OutputFile
						,@OutputPath
						,getdate()
						,'DONE'	
	END
		-- Clear the extended property 'DeplFileName'
		exec sp_executesql 
			@statement		= @extprop_cmd
			, @params		= @PARAMETERS
			, @ExtProp		= 'DeplFileName'
			, @ExtPropVal	= Null
			, @ExtPropChk	= @ExtPropChk OUT
			, @NestLevel	= @NestLevel			

RETURN COALESCE(@ErrorCount,0)
END

GO

 
 
 USE [dbaadmin]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER function [dbo].[dbaudf_CheckFileStatus] (@filename nvarchar(1000))
returns INT

/**************************************************************
 **  User Defined Function dbaudf_CheckFileStatus                  
 **  Written by Jim Wilson, Getty Images                
 **  November 28, 2005                                      
 **  
 **  This dbaudf is set up to check the file status.
 **  In Use 		= 1
 **  Ready 			= 0
 ***************************************************************/
as

	--======================================================================================
	--	Revision History
	--	Date		Author     		Desc
	--	==========	====================	=============================================
	--	11/28/2005	Jim Wilson		New process
	--	06/02/2006	Jim Wilson		Updated for SQL 2005.
	--	06/13/2012	Steve Ledridge	Modified return code to be int and return any error 
	--								after finding sp_OAGetErrorInfo nor reliable
	--	======================================================================================

/***
declare  @filename varchar(1000)

set @filename = '\\SEADCSQLWVA\SEADCSQLWVA_builds\deployment_logs\SQLDEPL_SEADCSQLWVA_AssetKeyword_F_20060602_1627.log'
set @filename = 'D:\sqldumps\etst.bak'

SET	@filename = 'D:\MSSQL10_50.MSSQLSERVER\MSSQL\Log\SQLjob_logs\xappl_TFS_rsp_check.txt'
--***/

BEGIN
DECLARE @FS				int
DECLARE @OLEResult		int
DECLARE @FileID			int
DECLARE @source			NVARCHAR(255)
DECLARE @description	NVARCHAR(255)
DECLARE @flag			INT

set @source ='Exist'
set @description='Exist'

EXECUTE @OLEResult = master.sys.sp_OACreate 'Scripting.FileSystemObject', @FS OUT
IF @OLEResult <> 0  
   begin
	EXEC master.sys.sp_OAGetErrorInfo NULL, @source OUTPUT, @description OUTPUT 
	goto displayerror
   end

--Open a file
execute @OLEResult = master.sys.sp_OAMethod @FS, 'OpenTextFile', @FileID OUT,@filename , 1

SELECT	@flag = isnull(nullif(@OLEResult,-2146828218),1) -- CHANGE INUSE CODE TO 1

IF @OLEResult <> 0  
   begin
	EXEC master.sys.sp_OAGetErrorInfo NULL, @source OUTPUT, @description OUTPUT
	
	SELECT	@description =	CASE @OLEResult
							WHEN -1				THEN 'FileSystemObject could not be created' 
							WHEN -2146828235	THEN 'File Not Found'
 							WHEN -2146828218	THEN 'Permission Denied (in use)'
							ELSE @description
							END
   end
ELSE
	BEGIN
		execute @OLEResult = master.sys.sp_OAMethod @FileID, 'Close'
		EXECUTE @OLEResult = master.sys.sp_OADestroy @FileID
	END

EXECUTE @OLEResult = master.sys.sp_OADestroy @FS

DisplayError:
return @flag
END

GO

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
