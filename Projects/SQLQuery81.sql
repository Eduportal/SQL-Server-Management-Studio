USE [msdb]
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N''[Uncategorized (Local)]'' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N''JOB'', @type=N''LOCAL'', @name=N''[Uncategorized (Local)]''
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N''DBA - Test LogParser'', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N''use log parser to extract data and place it on the central server'', 
		@category_name=N''[Uncategorized (Local)]'', 
		@owner_login_name=N''sa'', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''Aggrigate Yesterdays SQLErrorLogs'', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N''TSQL'', 
		@command=N''SET NOCOUNT ON

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

-- OVERLAP IN MINUTES FOR EACH EXTRACTION
SET		@LogBufferMin = -20

-- GET TIME AND DATE JOB WAS LAST RUN
SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''''00000000'''' + convert(varchar,sjh.run_date),8),4) 
			+ ''''-'''' + SUBSTRING(RIGHT(''''00000000'''' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''''-'''' + right(RIGHT(''''00000000'''' + convert(varchar,sjh.run_date),8),2) 
			+ '''' '''' + left(RIGHT(''''000000'''' + convert(varchar,sjh.run_time),6),2) 
			+ '''':'''' +	SUBSTRING(RIGHT(''''000000'''' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '''':'''' + right(RIGHT(''''000000'''' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''''DBA - Test LogParser'''' 		
	AND	sjh.run_status = 1	

-- GET ALL IF JOB HAS NOT BEEN RUN BEFORE.		
SET		@Last = COALESCE(@Last,CAST(''''2000-01-01 00:00:00'''' AS DateTime))	 

-- SET ALL VARIABLES
SELECT		@Machine	= REPLACE(@@servername,''''\''''+@@SERVICENAME,'''''''')
		,@Instance	= REPLACE(@@SERVICENAME,''''MSSQLSERVER'''','''''''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''''CentralServer''''

-- BUILD COMMAND
Select	@cmd = ''''%windir%\system32\LogParser "file:\\''''
		+ @central_server + ''''\'''' + @central_server 
		+ ''''_filescan\Aggregates\Queries\''''
		+ ''''SQLErrorLog2.sql?startdate='''' + @LastDate + ''''+starttime=''''
		+ @LastTime +''''+machine=''''
		+ @Machine + ''''+instance=''''
		+ @Instance + ''''+machineinstance=''''
		+ UPPER(REPLACE(@@servername,''''\'''',''''$'''')) + ''''+OutputFile=\\'''' 
		+ @central_server + ''''\'''' + @central_server 
		+ ''''_filescan\Aggregates\SQLErrorLOG_''''
		+ UPPER(REPLACE(@@servername,''''\'''',''''$''''))
		+ ''''.csv" -i:TEXTLINE -o:CSV -fileMode:0 -tabs:ON -oDQuotes:OFF''''
		
-- RUN IT		
exec master..xp_cmdshell @cmd'', 
		@database_name=N''master'', 
		@output_file_name=N''\\GINSSQLTEST02\GINSSQLTEST02$A_log\SQLjob_logs\DBA - Test LogParser.txt'', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N''Every 15 Minutes'', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100112, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N''(local)''
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


