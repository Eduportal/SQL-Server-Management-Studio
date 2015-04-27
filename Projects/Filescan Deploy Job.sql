USE dbaadmin
GO
DECLARE @ServerName	sysname
DECLARE @SQLName	sysname
DECLARE @JobName	sysname
SET	@JobName	= 'DBA - Test LogParser'

DECLARE @TSQL1		VarChar(max)
DECLARE @TSQL2		VarChar(max)
DECLARE @TSQL3		VarChar(max)
DECLARE @TSQL4		VarChar(max)
DECLARE ActiveServer	CURSOR
FOR
SELECT		DISTINCT 
		Machine						AS ServerName
		,Machine +	CASE
				WHEN Instance = '' THEN '' 
				ELSE '\' + Instance 
				END				AS SQLName
From		dbaadmin.dbo.Filescan_MachineSource
WHERE		Machine = 'FREDRZTSQL01' -- NOT IN
--(
--'GONESSQLA'
--,'GONESSQLB'
--,'SEADCPCSQLA'
--,'SEADCSHSQLA'
--,'SEAEXSQLMAIL'
--,'SEAFRESTGSQL'
--,'SEASTGPCSQLA'
--,'SEASTGSHSQLA'
--)
 
ORDER BY	1,2

SET		@TSQL1 =
'USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N''{JobName}''
GO
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N''{JobName}'')
EXEC msdb.dbo.sp_delete_job @job_name = N''{JobName}''
GO
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
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N''{JobName}'', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N''use log parser to extract data and place it on the central server'', 
		@category_name=N''[Uncategorized (Local)]'', 
		@owner_login_name=N''sa'', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback'

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

SET		@TSQL2 =
'EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''SQL ERRORLOG'', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=2, 
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

SET		@LogBufferMin = -20

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
	AND	sj.name = ''''{JobName}'''' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,GetDate()-30)	 

SELECT		@Machine	= REPLACE(@@servername,''''\''''+@@SERVICENAME,'''''''')
		,@Instance	= REPLACE(@@SERVICENAME,''''MSSQLSERVER'''','''''''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''''CentralServer''''

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
		+ ''''.w3c" -i:TEXTLINE -o:W3C -fileMode:0 -encodeDelim''''
		
exec master..xp_cmdshell @cmd'', 
		@database_name=N''master'', 
		@output_file_name=N''\\{SERVERNAME}\{SQLNAME}_log\SQLjob_logs\{JobName}.txt'', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback'

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

SET		@TSQL3 =
'EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''SQLAGENT'', 
		@step_id=2, 
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

SET		@LogBufferMin = -20

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
	AND	sj.name = ''''{JobName}'''' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,GetDate()-30)	 

SELECT		@Machine	= REPLACE(@@servername,''''\''''+@@SERVICENAME,'''''''')
		,@Instance	= REPLACE(@@SERVICENAME,''''MSSQLSERVER'''','''''''')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = ''''CentralServer''''

IF @Instance = '''''''' SET @Instance = ''''-''''

Select	@cmd = ''''%windir%\system32\LogParser "file:\\''''
		+ @central_server + ''''\'''' + @central_server 
		+ ''''_filescan\Aggregates\Queries\''''
		+ ''''SQLAGENT.sql?startdate='''' + @LastDate + ''''+starttime=''''
		+ @LastTime +''''+machine=''''
		+ @Machine + ''''+instance=''''
		+ @Instance + ''''+machineinstance=''''
		+ UPPER(REPLACE(@@servername,''''\'''',''''$'''')) + ''''+OutputFile=\\'''' 
		+ @central_server + ''''\'''' + @central_server 
		+ ''''_filescan\Aggregates\SQLAGENT_''''
		+ UPPER(REPLACE(@@servername,''''\'''',''''$''''))
		+ ''''.w3c" -i:TSV -o:W3C -fileMode:0 -iSeparator:space''''
		+ '''' -iHeaderFile:"\\''''
		+ @central_server + ''''\'''' + @central_server 
		+ ''''_filescan\Aggregates\Queries\SQLAGENT.tsv"''''
		
exec master..xp_cmdshell @cmd'', 
		@database_name=N''master'', 
		@output_file_name=N''\\{SERVERNAME}\{SQLNAME}_log\SQLjob_logs\{JobName}.txt'', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback'

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

SET		@TSQL4 =
'EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
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
EXEC msdb.dbo.sp_start_job @job_name=N''{JobName}''
GO'

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

OPEN ActiveServer
FETCH NEXT FROM ActiveServer INTO @ServerName,@SQLName
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		PRINT ':CONNECT ' + @SQLName
		PRINT 'GO'
		PRINT ''
		PRINT REPLACE(REPLACE(REPLACE(@TSQL1,'{SQLNAME}',REPLACE(@SQLName,'\','$')),'{SERVERNAME}',@ServerName),'{JobName}',@JobName)
		PRINT REPLACE(REPLACE(REPLACE(@TSQL2,'{SQLNAME}',REPLACE(@SQLName,'\','$')),'{SERVERNAME}',@ServerName),'{JobName}',@JobName)
		PRINT REPLACE(REPLACE(REPLACE(@TSQL3,'{SQLNAME}',REPLACE(@SQLName,'\','$')),'{SERVERNAME}',@ServerName),'{JobName}',@JobName)
		PRINT REPLACE(REPLACE(REPLACE(@TSQL4,'{SQLNAME}',REPLACE(@SQLName,'\','$')),'{SERVERNAME}',@ServerName),'{JobName}',@JobName)
		PRINT ''
		PRINT 'GO'	
		PRINT ''	
	END
	FETCH NEXT FROM ActiveServer INTO @ServerName,@SQLName
END
CLOSE ActiveServer
DEALLOCATE ActiveServer
GO



