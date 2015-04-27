USE [msdb]
GO

/****** Object:  Job [SPCL - POST DR FAILOVER JOB]    Script Date: 5/30/2013 10:31:05 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 5/30/2013 10:31:05 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SPCL - POST DR FAILOVER JOB', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'After a Failover, run this job once, restart sql, and then run this job one more time. This must also be done after failing back. This job will rename the sql instance to mach the current machine name, drop and recreate the shares, and then fix all job log output file paths.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'DBAsledridge', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Failover Cleanup]    Script Date: 5/30/2013 10:31:05 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Failover Cleanup', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON

DECLARE		@MSG				VarChar(max)
			,@DynamicCode		VarChar(8000)
			,@DefaultBackupDir	VarChar(512)
			,@machinename		SYSNAME
			,@ServerName		SYSNAME
			,@instancename		SYSNAME
			,@ServiceExt		SYSNAME
			,@ShareName			SYSNAME


SELECT		@instancename		= ISNULL(''\''+NULLIF(REPLACE(@@SERVICENAME,''MSSQLSERVER'',''''),''''),'''')
			,@ServerName		= REPLACE(@@SERVERNAME,@instancename,'''')
			,@machinename		= CONVERT(NVARCHAR(100), SERVERPROPERTY(''machinename'')) + @instancename
			,@ServiceExt		= ISNULL(''$''+NULLIF(REPLACE(@@SERVICENAME,''MSSQLSERVER'',''''),''''),'''')
			--,@DefaultBackupDir	= ''k:\Backup''

		EXEC	master..xp_instance_regread
					@rootkey		= ''HKEY_LOCAL_MACHINE'' 
					,@key			= ''Software\Microsoft\MSSQLServer\MSSQLServer'' 
					,@value_name	= ''BackupDirectory''
					,@dir			= @DefaultBackupDir OUTPUT

--PRINT @DefaultBackupDir

IF (OBJECT_ID(''tempdb..#ExecOutput''))	IS NOT NULL	DROP TABLE #ExecOutput
IF (OBJECT_ID(''tempdb..#RMTSHARE''))		IS NOT NULL	DROP TABLE #RMTSHARE
IF (OBJECT_ID(''tempdb..#RMTSHARE2''))		IS NOT NULL	DROP TABLE #RMTSHARE2

CREATE	TABLE	#ExecOutput		([rownum] INT IDENTITY PRIMARY KEY,[TextOutput] VARCHAR(8000));


-- GET CURRENT BACKUP PATH
		CREATE TABLE #RMTSHARE ([Share] VARCHAR(MAX) NULL, [Path] VARCHAR(MAX) NULL)
		SET		@DynamicCode	= ''RMTSHARE \\'' + CONVERT(NVARCHAR(100), SERVERPROPERTY(''machinename''))
		INSERT INTO #RMTSHARE([Share])
		EXEC	xp_CmdShell		@DynamicCode
		UPDATE	#RMTSHARE SET [Path] = dbaadmin.dbo.dbaudf_ReturnPart(REPLACE([Share],'' '',''|''),2)
		UPDATE	#RMTSHARE SET [Share] = dbaadmin.dbo.dbaudf_ReturnPart(REPLACE([Share],'' '',''|''),1)
		DELETE	#RMTSHARE WHERE	ISNULL(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE([Share],''_'',''|''),2),'''') NOT IN (''backup'',''base'',''builds'',''dba'',''dbasql'',''ldf'',''log'',''mdf'',''nxt'',''SQLjob'')
		SET @DefaultBackupDir = COALESCE(@DefaultBackupDir,(SELECT [Path] FROM #RMTSHARE WHERE dbaadmin.dbo.dbaudf_ReturnPart(REPLACE([Share],''_'',''|''),2) = ''backup''))
		PRINT @DefaultBackupDir

	IF ISNULL(NULLIF(@machinename,''''),@@SERVERNAME) != @@SERVERNAME
	BEGIN
		IF EXISTS (SELECT * FROM sys.servers WHERE name = @machinename) AND NOT EXISTS (SELECT * FROM sys.servers WHERE name = @@SERVERNAME)
		BEGIN
			SET @MSG = ''SEVER NAME CHANGE PENDING SQL RESTART''
			PRINT @MSG
			GOTO EndCode
		END
		ELSE
		BEGIN
			SET @MSG = ''SERVER NAME NEEDS CHANGED TO '' +  @machinename
			PRINT @MSG
		END
	END
	ELSE
	BEGIN
		SET @MSG = ''SERVER NAME IS SET''
		PRINT @MSG
		GOTO SkipRename
	END
	


-- RENAME
	IF @machinename != @@SERVERNAME 
	BEGIN
		IF EXISTS (SELECT * FROM sys.servers WHERE name = @@SERVERNAME)
			EXEC sp_dropserver @@SERVERNAME; 
		IF NOT EXISTS (SELECT * FROM sys.servers WHERE name = @machinename)
			EXEC sp_addserver @machinename, ''local''
		SET @Msg =	''SERVER NAME CHANGED TO '' +  @machinename;
		PRINT @MSG
		GOTO EndCode
	END

SkipRename:


	-- DROP AND RECREATE SHARES
		--DROP SHARES
		SET @Msg =	''Drop Existing Shares''; 
		PRINT @Msg;
		CREATE TABLE #RMTSHARE2 ([OUTPUT] VARCHAR(MAX))
		SET		@DynamicCode	= ''RMTSHARE \\'' + REPLACE(@@SERVERNAME,''\''+@@SERVICENAME,'''')
		INSERT INTO #RMTSHARE2
		EXEC	xp_CmdShell		@DynamicCode

		UPDATE	#RMTSHARE2 SET [OUTPUT] = dbaadmin.dbo.dbaudf_ReturnPart(REPLACE([OUTPUT],'' '',''|''),1)
		DELETE	#RMTSHARE2 WHERE	ISNULL(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE([OUTPUT],''_'',''|''),2),'''') NOT IN (''backup'',''base'',''builds'',''dba'',''dbasql'',''ldf'',''log'',''mdf'',''nxt'',''SQLjob'')

		DECLARE ShareCursor CURSOR 
		FOR
		SELECT [OUTPUT] FROM #RMTSHARE2 

		OPEN ShareCursor
		FETCH NEXT FROM ShareCursor INTO @ShareName
		WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			IF (@@FETCH_STATUS <> -2)
			BEGIN
				SET @Msg =	''  -- Dropping Share '' + @ShareName; 
				PRINT @Msg;
				SET		@DynamicCode	= ''RMTSHARE \\'' + REPLACE(@@SERVERNAME,''\''+@@SERVICENAME,'''') + ''\'' + @ShareName + '' /DELETE''
				EXEC	xp_CmdShell		@DynamicCode, no_output 
			END
			FETCH NEXT FROM ShareCursor INTO @ShareName
		END
		CLOSE ShareCursor
		DEALLOCATE ShareCursor
		DROP TABLE #RMTSHARE2
	
		-- BUILD SHARES
		SET @Msg =	''Build Shares''; 
		PRINT @Msg;
		
		TRUNCATE TABLE #ExecOutput
		SET @DynamicCode	= ''sqlcmd -S'' + @@SERVERNAME + '' -E -Q"EXEC dbaadmin.dbo.dbasp_dba_sqlsetup '''''' + @DefaultBackupDir + ''''''"''
		INSERT INTO #ExecOutput(TextOutput)
		EXEC master.sys.xp_cmdshell @DynamicCode

		SET @DynamicCode	= ''sqlcmd -S'' + @@SERVERNAME + '' -E -Q"EXEC dbaadmin.dbo.dbasp_create_NXTshare"''
		INSERT INTO #ExecOutput(TextOutput)
		EXEC master.sys.xp_cmdshell @DynamicCode	
	
	
	-- FIX JOB OUTPUTS
	SET @Msg =	''Fix Job Outputs''; 
	PRINT @Msg;
	
	EXEC dbaadmin.dbo.dbasp_FixJobOutput


exec dbaadmin.dbo.dbasp_capture_local_serverenviro

exec dbaadmin.dbo.dbasp_check_SQLhealth


EndCode:
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


