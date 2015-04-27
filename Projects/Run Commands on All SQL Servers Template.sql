DECLARE @ServerName	sysname
DECLARE @SQLName	sysname
DECLARE @JobName	sysname
SET	@JobName	= 'DBA - Test LogParser'

DECLARE @TSQL1		VarChar(max)
DECLARE @TSQL2		VarChar(max)
DECLARE @TSQL3		VarChar(max)
DECLARE @TSQL4		VarChar(max)
DECLARE @TSQL5		VarChar(max)
DECLARE @TSQL6		VarChar(max)
DECLARE @TSQL7		VarChar(max)
DECLARE @TSQL8		VarChar(max)
DECLARE @TSQL9		VarChar(max)

DECLARE ActiveServer	CURSOR
FOR
SELECT		DISTINCT 
		Machine						AS ServerName
		,Machine +	CASE
				WHEN Instance = '' THEN '' 
				ELSE '\' + Instance 
				END				AS SQLName
From		dbaadmin.dbo.Filescan_MachineSource
WHERE		Domain =
		--'AMER'
		--'PRODUCTION'
		'STAGE'
	AND	Machine NOT IN -- Temporary Exclude List
		(
		'SEAPSCOMACSSQL1'
		--,''
		--,''
		)
ORDER BY	1,2


SET		@TSQL1 =
'USE [msdb]
GO
SET NOCOUNT ON
declare	@job_name sysname
	, @execution_status int 
	, @job_id UNIQUEIDENTIFIER 
	, @is_sysadmin INT
	, @job_owner   sysname

select @job_id = job_id 
	,@is_sysadmin = ISNULL(IS_SRVROLEMEMBER(N''sysadmin''), 0)
	,@job_owner = SUSER_SNAME()
from msdb..sysjobs_view where name = N''{JobName}''	
	
CREATE TABLE #xp_results (job_id                UNIQUEIDENTIFIER NOT NULL,
                            last_run_date         INT              NOT NULL,
                            last_run_time         INT              NOT NULL,
                            next_run_date         INT              NOT NULL,
                            next_run_time         INT              NOT NULL,
                            next_run_schedule_id  INT              NOT NULL,
                            requested_to_run      INT              NOT NULL, -- BOOL
                            request_source        INT              NOT NULL,
                            request_source_id     sysname          COLLATE database_default NULL,
                            running               INT              NOT NULL, -- BOOL
                            current_step          INT              NOT NULL,
                            current_retry_attempt INT              NOT NULL,
                            job_state             INT              NOT NULL)
IF ((@@microsoftversion / 0x01000000) >= 8) -- SQL Server 8.0 or greater
	    INSERT INTO #xp_results
	    EXECUTE master.dbo.xp_sqlagent_enum_jobs @is_sysadmin, @job_owner, @job_id
ELSE
	    INSERT INTO #xp_results
	    EXECUTE master.dbo.xp_sqlagent_enum_jobs @is_sysadmin, @job_owner
set @execution_status = (select job_state from #xp_results)
drop table #xp_results

IF @execution_status != 4 
BEGIN
	PRINT ''Stoping Job''
	EXEC msdb.dbo.sp_stop_job @job_name=N''{JobName}''
END
ELSE
	PRINT ''Job Not Running''
GO'

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

SET		@TSQL2 =
'PRINT ''Disabeling Job''
EXEC msdb.dbo.sp_update_job @job_name=N''{JobName}'',@enabled=0
GO'

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

SET		@TSQL3 =
'PRINT ''DROPING STEP 3''
EXEC msdb.dbo.sp_delete_jobstep @job_name=N''{JobName}'', @step_id=3
GO
PRINT ''DROPING STEP 2''
EXEC msdb.dbo.sp_delete_jobstep @job_name=N''{JobName}'', @step_id=2
GO
PRINT ''DROPING STEP 1''
EXEC msdb.dbo.sp_delete_jobstep @job_name=N''{JobName}'', @step_id=1
GO'

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

SET		@TSQL4 =
'PRINT ''ADDING STEP 1''
EXEC msdb.dbo.sp_add_jobstep @job_name=N''{JobName}'', @step_name=N''SQL ERRORLOG'', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=3, 
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
	AND	sj.name = ''''DBA - Test LogParser'''' 		
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
		@output_file_name=N''\\{SERVERNAME}\{SQLNAME}_log\SQLjob_logs\DBA - Test LogParser.txt'', 
		@flags=6
GO'

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

SET		@TSQL5 =
'PRINT ''ADDING STEP 2''
EXEC msdb.dbo.sp_add_jobstep @job_name=N''{JobName}'', @step_name=N''SQLAGENT'', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=3, 
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
	AND	sj.name = ''''DBA - Test LogParser'''' 		
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
		@output_file_name=N''\\{SERVERNAME}\{SQLNAME}_log\SQLjob_logs\DBA - Test LogParser.txt'', 
		@flags=6
GO'

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

SET		@TSQL6 =
'PRINT ''ADDING STEP 3''
EXEC msdb.dbo.sp_add_jobstep @job_name=N''{JobName}'', @step_name=N''ServerEvent'', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
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
	AND	sj.name = ''''DBA - Test LogParser'''' 		
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
		+ ''''ServerEvent.sql?startdate='''' + @LastDate + ''''+starttime=''''
		+ @LastTime +''''+machine=''''
		+ @Machine + ''''+instance=''''
		+ @Instance + ''''+machineinstance=''''
		+ UPPER(REPLACE(@@servername,''''\'''',''''$'''')) + ''''+OutputFile=\\'''' 
		+ @central_server + ''''\'''' + @central_server 
		+ ''''_filescan\Aggregates\ServerEvent_''''
		+ UPPER(REPLACE(@@servername,''''\'''',''''$''''))
		+ ''''.w3c" -i:EVT -o:W3C -fileMode:0 -binaryFormat:ASC -oDQuotes:ON -encodeDelim:ON -resolveSIDs:ON''''
print @cmd

		
exec master..xp_cmdshell @cmd'', 
		@database_name=N''master'', 
		@output_file_name=N''\\{SERVERNAME}\{SQLNAME}_log\SQLjob_logs\DBA - Test LogParser.txt'', 
		@flags=6
GO'

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

SET		@TSQL7 =
'PRINT ''''
'
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

SET		@TSQL8 =
'PRINT ''Enabeling Job''
EXEC msdb.dbo.sp_update_job @job_name=N''{JobName}'',@enabled=1
GO'

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

SET		@TSQL9 =
'SET NOCOUNT ON
declare	@job_name sysname
	, @execution_status int 
	, @job_id UNIQUEIDENTIFIER 
	, @is_sysadmin INT
	, @job_owner   sysname

select @job_id = job_id 
	,@is_sysadmin = ISNULL(IS_SRVROLEMEMBER(N''sysadmin''), 0)
	,@job_owner = SUSER_SNAME()
from msdb..sysjobs_view where name = N''{JobName}''	
	
CREATE TABLE #xp_results (job_id                UNIQUEIDENTIFIER NOT NULL,
                            last_run_date         INT              NOT NULL,
                            last_run_time         INT              NOT NULL,
                            next_run_date         INT              NOT NULL,
                            next_run_time         INT              NOT NULL,
                            next_run_schedule_id  INT              NOT NULL,
                            requested_to_run      INT              NOT NULL, -- BOOL
                            request_source        INT              NOT NULL,
                            request_source_id     sysname          COLLATE database_default NULL,
                            running               INT              NOT NULL, -- BOOL
                            current_step          INT              NOT NULL,
                            current_retry_attempt INT              NOT NULL,
                            job_state             INT              NOT NULL)
IF ((@@microsoftversion / 0x01000000) >= 8) -- SQL Server 8.0 or greater
	    INSERT INTO #xp_results
	    EXECUTE master.dbo.xp_sqlagent_enum_jobs @is_sysadmin, @job_owner, @job_id
ELSE
	    INSERT INTO #xp_results
	    EXECUTE master.dbo.xp_sqlagent_enum_jobs @is_sysadmin, @job_owner
set @execution_status = (select job_state from #xp_results)
drop table #xp_results

IF @execution_status IN (4,5)
BEGIN
	PRINT ''Starting Job''
	EXEC msdb.dbo.sp_start_job @job_name=N''{JobName}''
END
ELSE
	PRINT ''Job Already Running''
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
		PRINT REPLACE(REPLACE(REPLACE(@TSQL5,'{SQLNAME}',REPLACE(@SQLName,'\','$')),'{SERVERNAME}',@ServerName),'{JobName}',@JobName)
		PRINT REPLACE(REPLACE(REPLACE(@TSQL6,'{SQLNAME}',REPLACE(@SQLName,'\','$')),'{SERVERNAME}',@ServerName),'{JobName}',@JobName)
		PRINT REPLACE(REPLACE(REPLACE(@TSQL7,'{SQLNAME}',REPLACE(@SQLName,'\','$')),'{SERVERNAME}',@ServerName),'{JobName}',@JobName)
		PRINT REPLACE(REPLACE(REPLACE(@TSQL8,'{SQLNAME}',REPLACE(@SQLName,'\','$')),'{SERVERNAME}',@ServerName),'{JobName}',@JobName)
		PRINT REPLACE(REPLACE(REPLACE(@TSQL9,'{SQLNAME}',REPLACE(@SQLName,'\','$')),'{SERVERNAME}',@ServerName),'{JobName}',@JobName)
		PRINT ''
		PRINT 'GO' -- MAKE SURE THERE IS A GO AT THE END BEFORE CONNECTING	
		PRINT ''	
	END
	FETCH NEXT FROM ActiveServer INTO @ServerName,@SQLName
END
CLOSE ActiveServer
DEALLOCATE ActiveServer
GO



