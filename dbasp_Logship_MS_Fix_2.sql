USE [DBAAdmin]
GO
/****** Object:  StoredProcedure [dbo].[dbasp_Logship_MS_Fix_2]    Script Date: 9/5/2014 11:13:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[dbasp_Logship_MS_Fix_2]') IS NOT NULL
	DROP PROCEDURE [dbo].[dbasp_Logship_MS_Fix_2]
GO

CREATE PROCEDURE [dbo].[dbasp_Logship_MS_Fix_2]
	(
	@DBName		SYSNAME
	,@SQLName	SYSNAME
	,@BackupPath	VARCHAR(8000)	= NULL
	,@AgentJob	VARCHAR(8000)	= NULL
	,@FullReset	BIT		= 0
	,@ResetFromJob	BIT		= 0
	,@Verbose	INT		= 0
	,@CreateJob	BIT		= 0
	,@WorkDir	VarChar(8000)	= NULL
	,@OverrideXML	XML		= NULL OUTPUT
	)
AS


	/*

		-- ============================================================================================================
		--	Revision History
		--	Date		Author     				                     Desc
		--	==========	====================	=======================================================================
		--	02/26/2013	Steve Ledridge		Modified Calls to functions supporting the replacement of OLE with CLR.
		--	04/02/2013	Steve Ledridge		Improved Calls AND logic AND made more portable FOR other servers.
		--	01/14/2014	Steve Ledridge		Modified to Support Multi-File Restores with new restore sproc
		--	01/24/2014	Joseph Brown		Modified @DBSources data for new server locations.
		--	03/26/2014	Steve Ledridge		Added entry for WCDSwork Database
		--	04/25/2014	Steve Ledridge		Added entry for ContributorSystemsContract Database
		--	09/05/2014	Steve Ledridge		Added all ASHBURN CRM Databases.
		--	09/23/2014	Steve Ledridge		Created New Version that has no lookup table.
		-- ============================================================================================================
		-- ============================================================================================================

	-- EXAMPLES FULL RESET STAND ALONE

	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'DeliveryDB'				,'SQLDISTG0A'		,NULL	,NULL	,1,0,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'DeliveryArchiveDB'			,'SQLDISTG0A'		,NULL	,NULL	,1,0,1

	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'EditorialSiteDB'			,'EDSQLG0A'		,NULL	,NULL	,1,0,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'EventServiceDB'			,'EDSQLG0A'		,NULL	,NULL	,1,0,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Getty_Master'				,'FREPSQLRYLA01'	,NULL	,NULL	,1,0,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'RM_Integration'			,'FREPSQLRYLA01'	,NULL	,NULL	,1,0,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'GINS_Master'				,'FREPSQLRYLB01'	,NULL	,NULL	,1,0,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Gins_Integration'			,'FREPSQLRYLB01'	,NULL	,NULL	,1,0,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Product'				,'G1sqlB'		,NULL	,NULL	,1,0,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'RightsPrice'				,'G1sqlB'		,NULL	,NULL	,1,0,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'WCDS'					,'G1sqlA'		,NULL	,'LSRestore_G1SQLA\A_WCDS2'	,1,0,1					
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'WCDSwork'				,'G1sqlA'		,NULL	,'LSRestore_tcp:G1SQLA\A,1252_WCDSwork2'	,1,0,1			
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'AssetUsage_Archive'			,'G1sqlB'		,NULL	,NULL	,1,0,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'ContributorSystemsContract'		,'SEAPCTBSQLA'		,NULL	,NULL	,1,0,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Getty_Images_CRM_GENESYS'		,'SEAPCRMSQL1A'		,NULL	,NULL	,1,0,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Getty_Images_US_Inc__MSCRM'		,'SEAPCRMSQL1A'		,NULL	,NULL	,1,0,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Getty_Images_US_Inc__MSCRM_Clone'	,'SEAPCRMSQL1A'		,NULL	,NULL	,1,0,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Getty_Images_US_Inc_Custom'		,'SEAPCRMSQL1A'		,NULL	,NULL	,1,0,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'MSCRM_CONFIG'				,'SEAPCRMSQL1A'		,NULL	,NULL	,1,0,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'ReportServer'				,'SEAPCRMSQL1A'		,NULL	,NULL	,1,0,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'ReportServer2'			,'SEAPCRMSQL1A'		,NULL	,NULL	,1,0,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'ReportServerTempDB'			,'SEAPCRMSQL1A'		,NULL	,NULL	,1,0,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'ReportServer2TempDB'			,'SEAPCRMSQL1A'		,NULL	,NULL	,1,0,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'ImportManager'			,'SEAPCRMSQL1A'		,NULL	,NULL	,1,0,1

	*/


	SET NOCOUNT ON
	SET ANSI_WARNINGS OFF


	DECLARE		@MostRecent_Full	DATETIME
			,@MostRecent_Diff	DATETIME
			,@MostRecent_Log	DATETIME
			,@CMD			VARCHAR(8000)
			,@CMD2			VARCHAR(8000)
			,@CnD_CMD		VARCHAR(8000)
			,@COPY_CMD		VARCHAR(max)
			,@RestorePath		VARCHAR(max)
			,@FileName		VARCHAR(MAX)
			,@ShareName		VarChar(500)
			,@LogPath		VarChar(100)
			,@DataPath		VarChar(100)
			,@CMD_TYPE		CHAR(3)
			,@errorcode		INT
			,@sqlerrorcode		INT
			,@DateModified		DATETIME
			,@Extension		VARCHAR(MAX)
			,@CopyStartTime		DateTime
			,@partial_flag		BIT
			,@RestoreOrder		INT
			,@syntax_out		VarChar(max)
			,@StandBy		VarChar(max)
			,@ReturnCode		INT
			,@jobId			BINARY(16)
			,@JobLogFile		VarChar(8000)
			,@Dynamic1		nVarChar(4000)
			,@RestoreLogOnly	bit
				
	DECLARE		@SourceFiles		TABLE 
			(
			[Mask]			[nvarchar](4000) NULL,
			[Name]			[nvarchar](4000) NULL,
			[FullPathName]		[nvarchar](4000) NULL,
			[Directory]		[nvarchar](4000) NULL,
			[Extension]		[nvarchar](4000) NULL,
			[DateCreated]		[datetime] NULL,
			[DateAccessed]		[datetime] NULL,
			[DateModified]		[datetime] NULL,
			[Attributes]		[nvarchar](4000) NULL,
			[Size]			[bigint] NULL
			)
			
	DECLARE		@nameMatches		TABLE (NAME VARCHAR(MAX))		
	DECLARE		@CopyAndDeletes		TABLE (CnD_CMD VarChar(max))
	

	IF OBJECT_ID('tempdb..#filelist')	IS NOT NULL	DROP TABLE #filelist		
	CREATE TABLE #filelist		(
					LogicalName NVARCHAR(128) NULL, 
					PhysicalName NVARCHAR(260) NULL, 
					type CHAR(1), 
					FileGroupName NVARCHAR(128) NULL, 
					SIZE NUMERIC(20,0), 
					MaxSize NUMERIC(20,0),
					FileId BIGINT,
					CreateLSN NUMERIC(25,0),
					DropLSN NUMERIC(25,0),
					UniqueId VARCHAR(50),
					ReadOnlyLSN NUMERIC(25,0),
					ReadWriteLSN NUMERIC(25,0),
					BackupSizeInBytes BIGINT,
					SourceBlockSize INT,
					FileGroupId INT,
					LogGroupGUID VARCHAR(50) NULL,
					DifferentialBaseLSN NUMERIC(25,0),
					DifferentialBaseGUID VARCHAR(50),
					IsReadOnly BIT,
					IsPresent BIT,
					TDEThumbprint VARBINARY(32) NULL,
					New_PhysicalName  NVARCHAR(1000) NULL
					)


	SELECT		@BackupPath	= COALESCE(@BackupPath,'\\'+ LEFT(@SQLName,CHARINDEX('\',@SQLName+'\')-1)+'\'+REPLACE(@SQLName,'\','$')+'_backup\')
			,@RestorePath	= '\\'+ LEFT(@@ServerName,CHARINDEX('\',@@ServerName+'\')-1)+'\'+REPLACE(@@ServerName,'\','$')+'_backup\LogShip\'+@DBName
			,@AgentJob	= COALESCE(@AgentJob,'LSRestore_' + @SQLName + '_' + @DBName) 
			,@COPY_CMD	= 'ROBOCOPY '+@BackupPath+'\ '+@RestorePath +'\'
			,@DataPath	= nullif(dbaadmin.[dbo].[dbaudf_GetSharePath](dbaadmin.[dbo].[dbaudf_getShareUNC]('mdf')),'Not Found')
			,@StandBy	= @DataPath + '\UNDO_' + @DBName + '.dat'
			,@JobLogFile	= nullif(dbaadmin.[dbo].[dbaudf_GetSharePath](dbaadmin.[dbo].[dbaudf_getShareUNC]('SQLjob_logs')),'C:') + '\' + @AgentJob + '.txt' 
			,@RestoreLogOnly = CASE WHEN @FullReset  = 0 AND DB_ID(@DBName) IS NOT NULL THEN 1 ELSE 0 END

	If NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs where name = @AgentJob)
		SET @CreateJob = 1

	IF @CreateJob = 1
	BEGIN
		BEGIN TRANSACTION

		IF EXISTS (SELECT * FROM msdb.dbo.sysjobs where name = @AgentJob)
			EXEC msdb.dbo.sp_delete_job @job_name=@AgentJob, @delete_unused_schedule=1

		SELECT @ReturnCode = 0
		IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Log Shipping' AND category_class=1)
		BEGIN
			EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Log Shipping'
			IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		END

		SELECT	@Dynamic1	= N'Log shipping restore log job for '+ @SQLName +':'+ @DBName +'.'
		EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@AgentJob, 
				@enabled=0, 
				@notify_level_eventlog=0, 
				@notify_level_email=0, 
				@notify_level_netsend=0, 
				@notify_level_page=0, 
				@delete_level=0, 
				@description=@Dynamic1, 
				@category_name=N'Log Shipping', 
				@owner_login_name=N'sa', @job_id = @jobId OUTPUT
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		SELECT	@Dynamic1	= N'EXEC [dbaadmin].[dbo].[dbasp_Logship_MS_Fix_2]  '''+@DBName+''','''+@SQLName+''','+COALESCE(''''+@BackupPath+'''','NULL')+','+COALESCE(''''+@AgentJob+'''','NULL')+',0,1' 
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Log shipping restore log job step.', 
				@step_id=1, 
				@cmdexec_success_code=0, 
				@on_success_action=1, 
				@on_success_step_id=0, 
				@on_fail_action=3, 
				@on_fail_step_id=0, 
				@retry_attempts=0, 
				@retry_interval=0, 
				@os_run_priority=0, @subsystem=N'TSQL', 
				@command=@Dynamic1, 
				@database_name=N'master', 
				@output_file_name=@JobLogFile, 
				@flags=6
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		SELECT	@Dynamic1	= N'EXEC [dbaadmin].[dbo].[dbasp_Logship_MS_Fix_2]  '''+@DBName+''','''+@SQLName+''','+COALESCE(''''+@BackupPath+'''','NULL')+','+COALESCE(''''+@AgentJob+'''','NULL')+',1,1' 
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Full Reset Database', 
				@step_id=2, 
				@cmdexec_success_code=0, 
				@on_success_action=3, 
				@on_success_step_id=0, 
				@on_fail_action=2, 
				@on_fail_step_id=0, 
				@retry_attempts=0, 
				@retry_interval=0, 
				@os_run_priority=0, @subsystem=N'TSQL', 
				@command=@Dynamic1, 
				@database_name=N'master', 
				@output_file_name=@JobLogFile, 
				@flags=6
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		SELECT	@Dynamic1	= N'EXEC [dbaadmin].[dbo].[dbasp_Logship_MS_Fix_2]  '''+@DBName+''','''+@SQLName+''','+COALESCE(''''+@BackupPath+'''','NULL')+','+COALESCE(''''+@AgentJob+'''','NULL')+',0,1' 
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Retry Logship Restore after Database Reset', 
				@step_id=3, 
				@cmdexec_success_code=0, 
				@on_success_action=1, 
				@on_success_step_id=0, 
				@on_fail_action=2, 
				@on_fail_step_id=0, 
				@retry_attempts=0, 
				@retry_interval=0, 
				@os_run_priority=0, @subsystem=N'TSQL', 
				@command=@Dynamic1, 
				@database_name=N'master', 
				@output_file_name=@JobLogFile, 
				@flags=6
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DefaultRestoreJobSchedule', 
				@enabled=1, 
				@freq_type=4, 
				@freq_interval=1, 
				@freq_subday_type=8, 
				@freq_subday_interval=1, 
				@freq_relative_interval=0, 
				@freq_recurrence_factor=0, 
				@active_start_date=20121118, 
				@active_end_date=99991231, 
				@active_start_time=1000, 
				@active_end_time=235900 
				--@schedule_uid=N'1a17fb82-e4b7-4322-9b7e-d6208c98ae37'
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		COMMIT TRANSACTION

		GOTO EndSave
		QuitWithRollback:
		    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
		EndSave:
	END

	-- Job Exists and Not being Run from inside of Job
	IF @ResetFromJob = 0 AND dbaadmin.dbo.[dbaudf_GetJobStatus](@AgentJob) != -2
	BEGIN
		IF dbaadmin.dbo.[dbaudf_GetJobStatus](@AgentJob) = 4
		BEGIN
			PRINT	'Agent Job: '+@AgentJob+' is running, Stopping it now.' 
			EXEC	msdb.dbo.sp_stop_job @Job_Name = @AgentJob
		END

		PRINT	'Agent Job: '+@AgentJob+' is being disabled.' 
		EXEC	msdb.dbo.sp_update_job @job_Name=@AgentJob, @enabled=0
	END	

	--FULL RESET AND DATABASE DOES EXIST
	IF @FullReset = 1 AND DB_ID(@DBNAME) IS NOT NULL
	BEGIN
		Print '**** FULL RESET REQUESTED, '+UPPER(@DBNAME)+' DATABASE WILL BE DROPED AND RECREATED. ***'

		IF EXISTS(select * From master.sys.database_mirroring WHERE database_id = DB_ID(@DBName) AND mirroring_partner_name IS NOT NULL)
		BEGIN
			PRINT '  -- Turning Off Mirroring'
			SET @CMD = 'ALTER DATABASE ['+@DBName+'] SET PARTNER OFF;'
			EXEC (@CMD)
		END
		
		IF EXISTS(select * From master.sys.databases WHERE database_id = DB_ID(@DBName) AND state_desc IN('RECOVERING'))
		BEGIN
			PRINT '  -- Turning Off Mirroring'
			SET @CMD = 'ALTER DATABASE ['+@DBName+'] SET PARTNER OFF;'
			EXEC (@CMD)
		END
		
		IF EXISTS(select * From master.sys.databases WHERE database_id = DB_ID(@DBName) AND state_desc IN('RESTORING'))
		BEGIN
			PRINT '  -- Finishing Restore with Recovery'
			SET @CMD = 'RESTORE DATABASE ['+@DBName+'] WITH RECOVERY;'
			EXEC (@CMD)
		END
		
		PRINT '  -- Dropping Existing Database'
		SET @CMD = 'ALTER DATABASE ['+@DBName+'] SET RESTRICTED_USER WITH ROLLBACK IMMEDIATE;DROP DATABASE ['+@DBName+']'
		EXEC (@CMD)
	END

	IF DB_ID(@DBNAME) IS NULL
		EXEC msdb.dbo.sp_delete_database_backuphistory @DBNAME

	RAISERROR('  -- Building DB Restore''s',-1,-1) WITH NOWAIT

	EXEC [dbaadmin].[dbo].[dbasp_format_BackupRestore] 
			@DBName			= @DBName 
			,@Mode			= 'RD' 
			,@Verbose		= @Verbose
			,@FullReset             = @FullReset
			,@LeaveNORECOVERY	= 1 
			,@FilePath		= @BackupPath
			,@StandBy		= @StandBy
			,@syntax_out		= @syntax_out		OUTPUT
			,@WorkDir		= @WorkDir
			,@OverrideXML		= @OverrideXML		OUTPUT
			,@NoFullRestores	= @RestoreLogOnly
			,@NoDifRestores		= @RestoreLogOnly
			

	RAISERROR('  -- Starting DB Restore''s',-1,-1) WITH NOWAIT

	If @verbose >= 1
		EXEC [dbaadmin].[dbo].[dbasp_PrintLarge] @syntax_out
	
	EXEC (@syntax_out)

	RAISERROR('  -- Done with DB Restore''s',-1,-1) WITH NOWAIT


	IF @ResetFromJob = 0 AND dbaadmin.dbo.[dbaudf_GetJobStatus](@AgentJob) != -2
	BEGIN
		DECLARE @AgentJob2 SYSNAME
		SET	@AgentJob2 = REPLACE(@AgentJob,'LSRestore_','LSCopy_')

		IF EXISTS (SELECT * FROM msdb.dbo.sysjobs where name = @AgentJob2)
		BEGIN
			PRINT	'Agent Job: '+@AgentJob2+' is being re-enabled.' 
			EXEC		msdb.dbo.sp_update_job @job_Name=@AgentJob2, @enabled=1
			EXEC		msdb.dbo.sp_start_job @Job_Name = @AgentJob2
		END

		IF EXISTS (SELECT * FROM msdb.dbo.sysjobs where name = @AgentJob)
		BEGIN
			PRINT	'Agent Job: '+@AgentJob+' is being re-enabled.' 
			EXEC		msdb.dbo.sp_update_job @job_Name=@AgentJob, @enabled=1
			EXEC		msdb.dbo.sp_start_job @Job_Name = @AgentJob
		END
	END
 
GO 
 
 
 
 
 
 
 
 
 
