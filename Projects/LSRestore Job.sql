--:SETVAR DBName "RM_Integration"
--:SETVAR ServerName "FREPSQLRYLA01"

:SETVAR DBName "GINS_Integration"
:SETVAR ServerName "FREPSQLRYLB01"

USE [msdb]
GO

/****** Object:  Job [LSRestore_$(ServerName)_$(DBName)]    Script Date: 04/02/2013 13:03:06 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Log Shipping]    Script Date: 04/02/2013 13:03:06 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Log Shipping' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Log Shipping'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'LSRestore_$(ServerName)_$(DBName)', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Log shipping restore log job for $(ServerName):$(DBName).', 
		@category_name=N'Log Shipping', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Log shipping restore log job step.]    Script Date: 04/02/2013 13:03:06 ******/
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
		@command=N'EXEC [dbaadmin].[dbo].[dbasp_Restore_Tranlog] @DBName = ''$(DBName)'',@DBPath  = ''E:\Data'',@LogPath = ''F:\Log''', 
		@output_file_name=N'\\SEAPSQLLSHP01\SEAPSQLLSHP01$SQL2K5_SQLjob_logs\LSRestore_$(ServerName)_$(DBName).txt', 
		@flags=34
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Full Reset Database]    Script Date: 04/02/2013 13:03:06 ******/
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
		@command=N'EXEC dbaadmin.[dbo].[dbasp_Logship_MS_Fix] ''$(DBName)'',1,1,0', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAPSQLLSHP01\SEAPSQLLSHP01$SQL2K5_SQLjob_logs\LSRestore_$(ServerName)_$(DBName).txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Retry Logship Restore after Database Reset]    Script Date: 04/02/2013 13:03:06 ******/
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
		@command=N'EXEC [dbaadmin].[dbo].[dbasp_Restore_Tranlog] @DBName = ''$(DBName)'',@DBPath  = ''E:\Data'',@LogPath = ''F:\Log''', 
		@output_file_name=N'\\SEAPSQLLSHP01\SEAPSQLLSHP01$SQL2K5_SQLjob_logs\LSRestore_$(ServerName)_$(DBName).txt', 
		@flags=34
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
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


