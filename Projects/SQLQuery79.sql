:CONNECT ASPSQLDEV01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\ASPSQLDEV01\ASPSQLDEV01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT ASPSQLDEV01\A02
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\ASPSQLDEV01\ASPSQLDEV01$A02_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT ASPSQLLOAD01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\ASPSQLLOAD01\ASPSQLLOAD01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT ASPSQLLOAD01\A02
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\ASPSQLLOAD01\ASPSQLLOAD01$A02_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT ASPSQLTEST01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\ASPSQLTEST01\ASPSQLTEST01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT ASPSQLTEST01\A02
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\ASPSQLTEST01\ASPSQLTEST01$A02_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT CATSQLDEV01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\CATSQLDEV01\CATSQLDEV01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT CATSQLDEV01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\CATSQLDEV01\CATSQLDEV01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT CRMSQLDEV01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\CRMSQLDEV01\CRMSQLDEV01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT CRMSQLDEV02
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\CRMSQLDEV02\CRMSQLDEV02_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT CRMSQLTEST01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\CRMSQLTEST01\CRMSQLTEST01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT CRMSQLTEST02
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\CRMSQLTEST02\CRMSQLTEST02_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT DAPSQLDEV01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\DAPSQLDEV01\DAPSQLDEV01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT DAPSQLTEST01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\DAPSQLTEST01\DAPSQLTEST01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT DEVSHSQL01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\DEVSHSQL01\DEVSHSQL01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT DEVSHSQL02\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\DEVSHSQL02\DEVSHSQL02$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREAASPSQL01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREAASPSQL01\FREAASPSQL01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREAGMSSQL01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREAGMSSQL01\FREAGMSSQL01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREAGMSSQL01\B
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREAGMSSQL01\FREAGMSSQL01$B_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREAGMSSQL01\HGA
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREAGMSSQL01\FREAGMSSQL01$HGA_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREAPCXSQL01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREAPCXSQL01\FREAPCXSQL01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREASHLSQL01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREASHLSQL01\FREASHLSQL01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREASHWSQL01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREASHWSQL01\FREASHWSQL01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREDCRMSQL01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREDCRMSQL01\FREDCRMSQL01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREDMRTSQL01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREDMRTSQL01\FREDMRTSQL01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREDMRTSQL01\B
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREDMRTSQL01\FREDMRTSQL01$B_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREDMRTSQL02\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREDMRTSQL02\FREDMRTSQL02$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREDMRTSQL02\B
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREDMRTSQL02\FREDMRTSQL02$B_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREDRZTSQL01\A01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREDRZTSQL01\FREDRZTSQL01$A01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREDRZTSQL01\A03
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREDRZTSQL01\FREDRZTSQL01$A03_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREDSQLEDW01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREDSQLEDW01\FREDSQLEDW01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREDSQLSRM01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREDSQLSRM01\FREDSQLSRM01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREDSQLTOL01\A01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREDSQLTOL01\FREDSQLTOL01$A01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRELASPSQL02\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRELASPSQL02\FRELASPSQL02$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRELGMSSQLA\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRELGMSSQLA\FRELGMSSQLA$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRELGMSSQLB\B
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRELGMSSQLB\FRELGMSSQLB$B_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRELLNPSQL01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRELLNPSQL01\FRELLNPSQL01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRELRZTSQL01\A03
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRELRZTSQL01\FRELRZTSQL01$A03_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRELSHLSQL01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRELSHLSQL01\FRELSHLSQL01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREPSQLEDW01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREPSQLEDW01\FREPSQLEDW01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREPSQLGLB01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREPSQLGLB01\FREPSQLGLB01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREPSQLRYLA01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREPSQLRYLA01\FREPSQLRYLA01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREPSQLRYLA11
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREPSQLRYLA11\FREPSQLRYLA11_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREPSQLRYLA13
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREPSQLRYLA13\FREPSQLRYLA13_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREPSQLRYLB11
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREPSQLRYLB11\FREPSQLRYLB11_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREPSQLRYLB12
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREPSQLRYLB12\FREPSQLRYLB12_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREPSQLRYLB13
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREPSQLRYLB13\FREPSQLRYLB13_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREPSQLRYLB14
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREPSQLRYLB14\FREPSQLRYLB14_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREPSQLRYLB15
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREPSQLRYLB15\FREPSQLRYLB15_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREPSQLRYLI01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREPSQLRYLI01\FREPSQLRYLI01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREPSQLRYLR01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREPSQLRYLR01\FREPSQLRYLR01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FREPTSSQL01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREPTSSQL01\FREPTSSQL01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRESCRMSQL01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRESCRMSQL01\FRESCRMSQL01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRESCRMSQL02
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRESCRMSQL02\FRESCRMSQL02_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRESEDSQL0A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRESEDSQL0A\FRESEDSQL0A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRESSQLEDW01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRESSQLEDW01\FRESSQLEDW01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRESSQLRYL01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRESSQLRYL01\FRESSQLRYL01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRESSQLRYL11
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRESSQLRYL11\FRESSQLRYL11_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRESSQLRYL12
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRESSQLRYL12\FRESSQLRYL12_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRETCRMSQL01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRETCRMSQL01\FRETCRMSQL01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRETMRTSQL01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRETMRTSQL01\FRETMRTSQL01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRETMRTSQL01\B
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRETMRTSQL01\FRETMRTSQL01$B_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRETMRTSQL02\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRETMRTSQL02\FRETMRTSQL02$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRETMRTSQL02\B
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRETMRTSQL02\FRETMRTSQL02$B_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRETRZTSQL01\A01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRETRZTSQL01\FRETRZTSQL01$A01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRETRZTSQL01\A02
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRETRZTSQL01\FRETRZTSQL01$A02_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRETRZTSQL01\A03
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRETRZTSQL01\FRETRZTSQL01$A03_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRETSCOMRPTSQL1
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRETSCOMRPTSQL1\FRETSCOMRPTSQL1_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRETSCOMSQL01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRETSCOMSQL01\FRETSCOMSQL01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRETSQLDIP02
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRETSQLDIP02\FRETSQLDIP02_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRETSQLEDW01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRETSQLEDW01\FRETSQLEDW01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRETSQLRYL02
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRETSQLRYL02\FRETSQLRYL02_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT FRETSQLRYL03
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRETSQLRYL03\FRETSQLRYL03_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GINSSQLDEV01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GINSSQLDEV01\GINSSQLDEV01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GINSSQLDEV02\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GINSSQLDEV02\GINSSQLDEV02$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GINSSQLDEV04\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GINSSQLDEV04\GINSSQLDEV04$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GINSSQLTEST01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GINSSQLTEST01\GINSSQLTEST01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GINSSQLTEST02\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GINSSQLTEST02\GINSSQLTEST02$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GINSSQLTEST03\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GINSSQLTEST03\GINSSQLTEST03$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GINSSQLTEST04\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GINSSQLTEST04\GINSSQLTEST04$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLDEV01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLDEV01\GMSSQLDEV01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLDEV01\B
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLDEV01\GMSSQLDEV01$B_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLDEV01\HGA
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLDEV01\GMSSQLDEV01$HGA_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLDEV04\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLDEV04\GMSSQLDEV04$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLDEV04\B
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLDEV04\GMSSQLDEV04$B_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLDEV04\HGA
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLDEV04\GMSSQLDEV04$HGA_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLLOAD02\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLLOAD02\GMSSQLLOAD02$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLLOAD02\B
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLLOAD02\GMSSQLLOAD02$B_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLLOAD02\HGA
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLLOAD02\GMSSQLLOAD02$HGA_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLTEST01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLTEST01\GMSSQLTEST01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLTEST01\B
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLTEST01\GMSSQLTEST01$B_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLTEST01\HGA
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLTEST01\GMSSQLTEST01$HGA_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLTEST02\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLTEST02\GMSSQLTEST02$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLTEST02\B
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLTEST02\GMSSQLTEST02$B_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLTEST02\HGA
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLTEST02\GMSSQLTEST02$HGA_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLTEST03\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLTEST03\GMSSQLTEST03$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLTEST03\B
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLTEST03\GMSSQLTEST03$B_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLTEST03\HGA
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLTEST03\GMSSQLTEST03$HGA_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLTEST04\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLTEST04\GMSSQLTEST04$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLTEST04\B
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLTEST04\GMSSQLTEST04$B_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT GMSSQLTEST04\HGA
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\GMSSQLTEST04\GMSSQLTEST04$HGA_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT MSSQLDEV01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\MSSQLDEV01\MSSQLDEV01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT MSSQLTEST01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\MSSQLTEST01\MSSQLTEST01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT NYCMVSQLDEV01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\NYCMVSQLDEV01\NYCMVSQLDEV01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT PCSQLDEV01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\PCSQLDEV01\PCSQLDEV01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT PCSQLDEV01\A02
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\PCSQLDEV01\PCSQLDEV01$A02_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT PCSQLLOAD02\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\PCSQLLOAD02\PCSQLLOAD02$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT PCSQLLOADA\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\PCSQLLOADA\PCSQLLOADA$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT PCSQLTEST01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\PCSQLTEST01\PCSQLTEST01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT PCSQLTEST01\A02
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\PCSQLTEST01\PCSQLTEST01$A02_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEADCCSO01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEADCCSO01\SEADCCSO01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEADCSQLC01A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEADCSQLC01A\SEADCSQLC01A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEADCSQLWVB\B
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEADCSQLWVB\SEADCSQLWVB$B_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFREAPPNOE01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFREAPPNOE01\SEAFREAPPNOE01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFREDWDMSDD01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFREDWDMSDD01\SEAFREDWDMSDD01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFREDWDMSPD01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFREDWDMSPD01\SEAFREDWDMSPD01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRENOETIXTST
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRENOETIXTST\SEAFRENOETIXTST_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQL01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQL01\SEAFRESQL01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLBOA
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLBOA\SEAFRESQLBOA_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLBOT01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLBOT01\SEAFRESQLBOT01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLBOT01\HGA
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLBOT01\SEAFRESQLBOT01$HGA_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLBOT01\TEST
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLBOT01\SEAFRESQLBOT01$TEST_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLDWARCH
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLDWARCH\SEAFRESQLDWARCH_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLDWD01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLDWD01\SEAFRESQLDWD01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLDWP01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLDWP01\SEAFRESQLDWP01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLDWT01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLDWT01\SEAFRESQLDWT01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLIBMDIR
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLIBMDIR\SEAFRESQLIBMDIR_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLIMMGR
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLIMMGR\SEAFRESQLIMMGR_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLMOMA\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLMOMA\SEAFRESQLMOMA$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLPROJ01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLPROJ01\SEAFRESQLPROJ01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLRF01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLRF01\SEAFRESQLRF01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLSB01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLSB01\SEAFRESQLSB01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLSHRA\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLSHRA\SEAFRESQLSHRA$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLSTGDAP
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLSTGDAP\SEAFRESQLSTGDAP_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLT01\DEV
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLT01\SEAFRESQLT01$DEV_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLT01\STAGE
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLT01\SEAFRESQLT01$STAGE_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLT01\TEST
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLT01\SEAFRESQLT01$TEST_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLTAL04
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLTAL04\SEAFRESQLTAL04_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLTAL05
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLTAL05\SEAFRESQLTAL05_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLTALS01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLTALS01\SEAFRESQLTALS01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLTALS02
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLTALS02\SEAFRESQLTALS02_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLTALTST
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLTALTST\SEAFRESQLTALTST_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLWVSTGA\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLWVSTGA\SEAFRESQLWVSTGA$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESQLWVSTGB\B
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESQLWVSTGB\SEAFRESQLWVSTGB$B_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESRSD01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESRSD01\SEAFRESRSD01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAFRESRST01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESRST01\SEAFRESRST01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEALABSSQL01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEALABSSQL01\SEALABSSQL01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAPDWDCSQLD0A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAPDWDCSQLD0A\SEAPDWDCSQLD0A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAPDWDCSQLP0A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAPDWDCSQLP0A\SEAPDWDCSQLP0A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAPEDSQL0A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAPEDSQL0A\SEAPEDSQL0A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAPSCOMACSSQL1
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAPSCOMACSSQL1\SEAPSCOMACSSQL1_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAPSECDB01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAPSECDB01\SEAPSECDB01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAPSQLWBS01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAPSQLWBS01\SEAPSQLWBS01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAPTRCSQLA\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAPTRCSQLA\SEAPTRCSQLA$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAPVMWSUS01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAPVMWSUS01\SEAPVMWSUS01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEASTRCSQLA
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEASTRCSQLA\SEASTRCSQLA_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEATESTHARNESS
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEATESTHARNESS\SEATESTHARNESS_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEATESTHARNESS2
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEATESTHARNESS2\SEATESTHARNESS2_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAVMSQLDWFTST1
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAVMSQLDWFTST1\SEAVMSQLDWFTST1_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAVMSQLMOMT01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAVMSQLMOMT01\SEAVMSQLMOMT01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAVMSQLMSDEV01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAVMSQLMSDEV01\SEAVMSQLMSDEV01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAVMSQLWVLOAD1\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAVMSQLWVLOAD1\SEAVMSQLWVLOAD1$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SEAVMSQLWVLOAD1\B
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAVMSQLWVLOAD1\SEAVMSQLWVLOAD1$B_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SHAREDSQLLOAD01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SHAREDSQLLOAD01\SHAREDSQLLOAD01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SHAREDSQLLOAD02\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SHAREDSQLLOAD02\SHAREDSQLLOAD02$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SQLDEPLOYER01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SQLDEPLOYER01\SQLDEPLOYER01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SQLDEPLOYER02
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SQLDEPLOYER02\SQLDEPLOYER02_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SQLDEPLOYER03
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SQLDEPLOYER03\SQLDEPLOYER03_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT SQLDEPLOYER04
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SQLDEPLOYER04\SQLDEPLOYER04_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT TESTSHSQL01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\TESTSHSQL01\TESTSHSQL01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
:CONNECT TESTSHSQL02\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\TESTSHSQL02\TESTSHSQL02$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
:CONNECT DLVRSQLDEV01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\DLVRSQLDEV01\DLVRSQLDEV01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO

:CONNECT DLVRSQLDEV01\A02
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\DLVRSQLDEV01\DLVRSQLDEV01$A02_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO

:CONNECT DLVRSQLTEST01\A
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\DLVRSQLTEST01\DLVRSQLTEST01$A_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO

:CONNECT DLVRSQLTEST01\A02
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\DLVRSQLTEST01\DLVRSQLTEST01$A02_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO

 
:CONNECT FRETSQLCTX01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FRETSQLCTX01\FRETSQLCTX01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO

:CONNECT FREPSQLRYLB01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\FREPSQLRYLB01\FREPSQLRYLB01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 :CONNECT SEAFRESRSP01
GO
USE [msdb]
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Test LogParser')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Test LogParser'
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Test LogParser', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'use log parser to extract data and place it on the central server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggrigate Yesterdays SQLErrorLogs', 
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

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),4) 
			+ ''-'' + SUBSTRING(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),5,2) 
			+ ''-'' + right(RIGHT(''00000000'' + convert(varchar,sjh.run_date),8),2) 
			+ '' '' + left(RIGHT(''000000'' + convert(varchar,sjh.run_time),6),2) 
			+ '':'' +	SUBSTRING(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 3,2) 
			+ '':'' + right(RIGHT(''000000'' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = ''DBA - Test LogParser'' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,CAST(''2000-01-01 00:00:00'' AS DateTime))	 

SELECT		@Machine	= REPLACE(@@servername,''\''+@@SERVICENAME,'''')
		,@Instance	= REPLACE(@@SERVICENAME,''MSSQLSERVER'','''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''CentralServer''

Select	@cmd = ''%windir%\system32\LogParser "file:\\''
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\Queries\''
		+ ''SQLErrorLog2.sql?startdate='' + @LastDate + ''+starttime=''
		+ @LastTime +''+machine=''
		+ @Machine + ''+instance=''
		+ @Instance + ''+machineinstance=''
		+ UPPER(REPLACE(@@servername,''\'',''$'')) + ''+OutputFile=\\'' 
		+ @central_server + ''\'' + @central_server 
		+ ''_filescan\Aggregates\SQLErrorLOG_''
		+ UPPER(REPLACE(@@servername,''\'',''$''))
		+ ''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''
		
exec master..xp_cmdshell @cmd', 
		@database_name=N'master', 
		@output_file_name=N'\\SEAFRESRSP01\SEAFRESRSP01_log\SQLjob_logs\DBA - Test LogParser.txt', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 Minutes', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
exec msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
 
 