USE [msdb]
GO

/****** Object:  Job [MAINT - Logship Restore AssetUsage_Archive]    Script Date: 11/12/2012 09:56:41 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'MAINT - Logship Restore AssetUsage_Archive')
EXEC msdb.dbo.sp_delete_job @job_name= N'MAINT - Logship Restore AssetUsage_Archive', @delete_unused_schedule=1
GO

USE [msdb]
GO

/****** Object:  Job [MAINT - Logship Restore AssetUsage_Archive]    Script Date: 11/12/2012 09:56:41 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 11/12/2012 09:56:41 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'MAINT - Logship Restore AssetUsage_Archive', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'DBA', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Logship Restore for AssetUsage_Archive]    Script Date: 11/12/2012 09:56:41 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Logship Restore for AssetUsage_Archive', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=3, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [dbaadmin].[dbo].[dbasp_Restore_Tranlog]
	@DBName = ''AssetUsage_Archive''
	,@DBPath	= ''E:\MSSQL.1\MSSQL\Data''
	,@LogPath = ''F:\MSSQL.1\MSSQL\Log''', 
		@database_name=N'master', 
		@output_file_name=N'E:\MSSQL.1\MSSQL\log\SQLjob_logs\maint_logship_restore_AssetUsage_Archive.txt', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Cleanup Backup Files]    Script Date: 11/12/2012 09:56:41 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Cleanup Backup Files', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=3, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dbaadmin.dbo.[dbasp_Logship_Fix] ''AssetUsage_Archive'',0,1', 
		@database_name=N'master', 
		@output_file_name=N'E:\MSSQL.1\MSSQL\log\SQLjob_logs\maint_logship_restore_AssetUsage_Archive.txt', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Reset Database]    Script Date: 11/12/2012 09:56:41 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Reset Database', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dbaadmin.dbo.[dbasp_Logship_Fix] ''AssetUsage_Archive'',1', 
		@database_name=N'master', 
		@output_file_name=N'E:\MSSQL.1\MSSQL\log\SQLjob_logs\maint_logship_restore_AssetUsage_Archive.txt', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Retry Logship Restore for AssetUsage_Archive]    Script Date: 11/12/2012 09:56:41 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Retry Logship Restore for AssetUsage_Archive', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [dbaadmin].[dbo].[dbasp_Restore_Tranlog]
	@DBName 	= ''AssetUsage_Archive''
	,@DBPath	= ''E:\MSSQL.1\MSSQL\Data''
	,@LogPath 	= ''F:\MSSQL.1\MSSQL\Log''', 
		@database_name=N'master', 
		@output_file_name=N'E:\MSSQL.1\MSSQL\log\SQLjob_logs\maint_logship_restore_AssetUsage_Archive.txt', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'hourly', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20120914, 
		@active_end_date=99991231, 
		@active_start_time=1000, 
		@active_end_time=235959 
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


