USE [msdb]
GO

USE [msdb]
GO



BEGIN TRANSACTION

DECLARE		@jobId			BINARY(16)
DECLARE		@ReturnCode		INT
SELECT		@ReturnCode		= 0

-- DROP JOB --
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'UTIL - PERF - GIMPI Collect and Export')
	EXEC msdb.dbo.sp_delete_job @job_name=N'UTIL - PERF - GIMPI Collect and Export', @delete_unused_schedule=1


-- CREATE JOB CATEGORY--
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
	EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

-- CREATE JOB --
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'UTIL - PERF - GIMPI Collect and Export', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Collect and Export Index Performance Data to support the GIMPI Reports', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback


-- CREATE JOB STEP--
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Export Data', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport', 
		@database_name=N'master', 
		@output_file_name=N'\\SEADCSQLC01A\SEADCSQLC01A_SQLjob_logs\UTIL_PERF_EXPORT_IndexAnalysisReport_Data.txt', 
		@flags=6
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	

-- UPDATE JOB --
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback


-- CREATE SCHEDULE --
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily at 1AM', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100507, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
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


