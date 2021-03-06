
USE dbacentral
GO

exec dbacentral.dbo.dbasp_CreateSQLCMD_ToAll
	@Command			= 'EXEC msdb.dbo.sp_set_sqlagent_properties @errorlogging_level=7, @alert_replace_runtime_tokens=1'
	,@Active			= 'y'
	,@SQL_Version_I			= '2008,2005'
	,@ServerName_E			= 'FRECSHWSQL01,FRETRZTSQL01,SEAVMSQLWVLOAD1'


exec dbacentral.dbo.dbasp_CreateSQLCMD_ToAll
	@Command			= ':r C:\Users\sledridge\Desktop\SQLCMD_DeployBlackBox.sql'
	,@SQLName_I			= 'GMSSQLDEV04\HGA,SEAFRESQLSB01,SEAFRESRSD01,SEAVMSQLMSDEV01\A,DEVSHSQL02\A,CATSQLDEV01\A,PCSQLDEV01\A,CATSQLDEV01,GMSSQLLOAD02\HGA,FRELASPSQL02\A,ASPSQLLOAD01\A,SEAPDWDCSQLP0A,FREPSQLGLB01,SEAPDWDCSQLD0A,SEAFRESQLBOA,SEAFRESQLDWP01,SEADCVISQL01,FREPTSSQL01,SEAFREAPPNOE01,SEAPVMWSUS01,GONESSQLA\A,SEAFRESQLWVSTGB\B,SEAFRESQLWVSTGA\A,PCSQLTEST01\A,TESTSHSQL02\A,PCSQLTEST01\A02,TESTSHSQL01\A'	
	,@ServerName_E			= 'FRECSHWSQL01,FRETRZTSQL01,SEAVMSQLWVLOAD1'


exec dbacentral.dbo.dbasp_CreateSQLCMD_ToAll
	@Command			= ':r "Z:\SQLCMD Scripts\SQLCMD_RemoveBlackBox.sql"'
	,@SQLName_I			= 'GMSSQLDEV04\HGA,SEAFRESQLSB01,SEAFRESRSD01,SEAVMSQLMSDEV01\A,DEVSHSQL02\A,CATSQLDEV01\A,PCSQLDEV01\A,CATSQLDEV01,GMSSQLLOAD02\HGA,FRELASPSQL02\A,ASPSQLLOAD01\A,SEAPDWDCSQLP0A,FREPSQLGLB01,SEAPDWDCSQLD0A,SEAFRESQLBOA,SEAFRESQLDWP01,SEADCVISQL01,FREPTSSQL01,SEAFREAPPNOE01,SEAPVMWSUS01,GONESSQLA\A,SEAFRESQLWVSTGB\B,SEAFRESQLWVSTGA\A,PCSQLTEST01\A,TESTSHSQL02\A,PCSQLTEST01\A02,TESTSHSQL01\A'	
	,@ServerName_E			= 'FRECSHWSQL01,FRETRZTSQL01,SEAVMSQLWVLOAD1'



exec dbacentral.dbo.dbasp_CreateSQLCMD_ToAll
	@Command			= ':r \\seafresqldba01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_2005\dbasp_set_maintplans.SQL'
	,@Active			= 'y'
	,@SQL_Version_I			= '2005'
	,@ServerName_E			= 'FRECSHWSQL01,FRETRZTSQL01,SEAVMSQLWVLOAD1'


exec dbacentral.dbo.dbasp_CreateSQLCMD_ToAll
	@Command			= ':r \\seafresqldba01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_2008\dbasp_set_maintplans.SQL'
	--,@Active			= 'y'
	--,@SQL_Version_I			= '2008'
	,@ServerName_I			= 'FRECSHWSQL01,FRETRZTSQL01,SEAVMSQLWVLOAD1'






EXEC dbacentral.dbo.dbasp_FileScan_ListServer_WithKnownCondition 'SysMessagesError- 701','2010-05-27 23:22:15.660'

	

exec dbacentral.dbo.dbasp_CreateSQLCMD_ToAll
	@Command			= ':r C:\Users\sledridge\Desktop\DiskSpaceCheck.sql'
	,@Active			= 'y'
	,@SQL_Version_I			= '2008,2005'
	,@ServerName_E			= 'FREPSQLNOE01,FRESDBASQL01,FRECSHWSQL01,FRETRZTSQL01,SEAVMSQLWVLOAD1'




exec dbacentral.dbo.dbasp_CreateSQLCMD_ToAll
	@Command			= ':r C:\Users\sledridge\Desktop\DeployGimpi.sql
exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport'
	,@Active			= 'y'
	,@SQL_Version_I			= '2008,2005'
	,@DomainName_I			= 'Production'
	,@ServerName_E			= 'FREPSQLNOE01,FRESDBASQL01,FRECSHWSQL01,FRETRZTSQL01,SEAVMSQLWVLOAD1'







exec dbacentral.dbo.dbasp_CreateSQLCMD_ToAll
	@Command			= ':r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
	,@SQLName_I			= 'SEADCSQLWVA\A,SEADCSQLWVB\B'	










exec dbacentral.dbo.dbasp_CreateSQLCMD_ToAll
	@Command			= ':r C:\Users\sledridge\Desktop\DiskSpaceCheck.sql'
	,@Active			= 'y'
	,@SQL_Version_I			= '2008,2005'
	,@DomainName_I			= 'Production'
	,@ServerName_E			= 'FREPSQLNOE01,FRESDBASQL01,FRECSHWSQL01,FRETRZTSQL01,SEAVMSQLWVLOAD1'



exec dbacentral.dbo.dbasp_CreateSQLCMD_ToAll
	@Command			= 'EXEC msdb.dbo.sp_update_jobstep @job_name=N''UTIL - DBA Nightly Processing'', @step_id=2 , @retry_attempts=2, @retry_interval=1'
	,@Active			= 'y'
	,@ServerName_E			= 'FREPTSSQL01,FRETRZTSQL01,GINSSQLDEV04,SEAPSHLSQL0A'



























select * From dbacentral.dbo.serverinfo


















SELECT		instance_id
		,Job_name
		,step_name
		,step_id
		,SQL_Message_id
		,SM.text AS SQL_Message
		,SQL_severity
		,[status]
		,[message]
		,Start_DateTime
		,End_DateTime
FROM		(
		SELECT		instance_id,
				jobs.job_id,
				job_name = jobs.[name],
				step_id,
				step_name,
				SQL_Message_id,
				SQL_severity,
				[status] = CASE run_status WHEN 0 THEN 'Failed' WHEN 1 THEN 'Succeeded' WHEN 2 THEN 'Retry' WHEN 3 THEN 'Canceled' WHEN 4 THEN 'In Progress' END,
				[message],
				run_time,
				run_time_hours = run_time/10000,
				run_time_minutes = (run_time%10000)/100, 
				run_time_seconds = (run_time%10000)%100,
				run_time_elapsed_seconds = 
					(run_time/10000 /*run_time_hours*/ * 60 * 60 /* hours to minutes to seconds*/) +
					((run_time%10000)/100 /* run_time_minutes */ * 60 /* minutes to seconds */ ) +
					(run_time%10000)%100,
				Start_Date = CONVERT(DATETIME, RTRIM(run_date)),
				Start_DateTime = 
					CONVERT(DATETIME, RTRIM(run_date)) + 
					((run_time/10000 * 3600) + ((run_time%10000)/100*60) 
					+ (run_time%10000)%100 /*run_time_elapsed_seconds*/) 
					/ (23.999999*3600 /* seconds in a day*/),
				End_DateTime = 
					CONVERT(DATETIME, RTRIM(run_date)) 
					+ ((run_time/10000 * 3600) 
					+ ((run_time%10000)/100*60) 
					+ (run_time%10000)%100) 
					/ (86399.9964 /* Start Date Time */)
					+ ((run_duration/10000 * 3600) 
					+ ((run_duration%10000)/100*60) 
					+ (run_duration%10000)%100 /*run_duration_elapsed_seconds*/) 
					/ (86399.9964 /* seconds in a day*/),
				Job_Start_DateTime = (
					SELECT TOP 1
					CONVERT(DATETIME, RTRIM(T1.run_date)) + 
					((T1.run_time/10000 * 3600) + ((T1.run_time%10000)/100*60) 
					+ (T1.run_time%10000)%100 /*run_time_elapsed_seconds*/) 
					/ (23.999999*3600 /* seconds in a day*/)
					FROM msdb.dbo.sysjobhistory T1
					WHERE T1.job_id = jobs.job_id
					AND T1.Step_id = 0
					AND T1.instance_id > history.instance_id
					ORDER BY run_date, run_time 
					),
				Job_End_DateTime = (
					SELECT TOP 1
					CONVERT(DATETIME, RTRIM(T2.run_date)) 
					+ ((T2.run_time/10000 * 3600) 
					+ ((T2.run_time%10000)/100*60) 
					+ (T2.run_time%10000)%100) 
					/ (86399.9964 /* Start Date Time */)
					+ ((T2.run_duration/10000 * 3600) 
					+ ((T2.run_duration%10000)/100*60) 
					+ (T2.run_duration%10000)%100 /*run_duration_elapsed_seconds*/) 
					/ (86399.9964 /* seconds in a day*/)					
					FROM msdb.dbo.sysjobhistory T2
					WHERE T2.job_id = jobs.job_id
					AND T2.Step_id = 0
					AND T2.instance_id > history.instance_id
					ORDER BY run_date, run_time 
					)
		FROM		msdb.dbo.sysjobs jobs WITH(NOLOCK)
		INNER JOIN	msdb.dbo.sysjobhistory history WITH(NOLOCK)
			ON	jobs.job_id = history.job_id
		WHERE		step_id != 0 
		) Data
LEFT JOIN	sys.messages sm
	ON	sm.message_id = data.SQL_Message_id
	AND	sm.language_id = 1033

WHERE		Job_Start_DateTime <= '2010/05/27 04:10:00'
	AND	Job_End_DateTime >= '2010/05/27 03:50:00'
ORDER BY	Instance_id

GO


SELECT		instance_id
		,Job_name
		,step_name
		,step_id
		,SQL_Message_id
		,SM.text AS SQL_Message
		,SQL_severity
		,[status]
		,[message]
		,Start_DateTime
		,End_DateTime
FROM		(
		SELECT		instance_id,
				jobs.job_id,
				job_name = jobs.[name],
				step_id,
				step_name,
				SQL_Message_id,
				SQL_severity,
				[status] = CASE run_status WHEN 0 THEN 'Failed' WHEN 1 THEN 'Succeeded' WHEN 2 THEN 'Retry' WHEN 3 THEN 'Canceled' WHEN 4 THEN 'In Progress' END,
				[message],
				run_time,
				run_time_hours = run_time/10000,
				run_time_minutes = (run_time%10000)/100, 
				run_time_seconds = (run_time%10000)%100,
				run_time_elapsed_seconds = 
					(run_time/10000 /*run_time_hours*/ * 60 * 60 /* hours to minutes to seconds*/) +
					((run_time%10000)/100 /* run_time_minutes */ * 60 /* minutes to seconds */ ) +
					(run_time%10000)%100,
				Start_Date = CONVERT(DATETIME, RTRIM(run_date)),
				Start_DateTime = 
					dbaadmin.dbo.dbaudf_AgentDateTime2DateTime (run_date,run_time),
				End_DateTime = 
					dbaadmin.dbo.dbaudf_AgentDateTime2DateTime (run_date,run_time+run_duration),
				Job_Start_DateTime = (
					SELECT TOP 1
					dbaadmin.dbo.dbaudf_AgentDateTime2DateTime (T1.run_date,T1.run_time)
					FROM msdb.dbo.sysjobhistory T1
					WHERE T1.job_id = jobs.job_id
					AND T1.Step_id = 0
					AND T1.instance_id > history.instance_id
					ORDER BY T1.instance_id 
					),
				Job_End_DateTime = (
					SELECT TOP 1
					dbaadmin.dbo.dbaudf_AgentDateTime2DateTime (T1.run_date,T1.run_time+T1.run_duration)
					FROM msdb.dbo.sysjobhistory T1
					WHERE T1.job_id = jobs.job_id
					AND T1.Step_id = 0
					AND T1.instance_id > history.instance_id
					ORDER BY T1.instance_id 
					)			
					
		FROM		msdb.dbo.sysjobs jobs WITH(NOLOCK)
		INNER JOIN	msdb.dbo.sysjobhistory history WITH(NOLOCK)
			ON	jobs.job_id = history.job_id
			AND	step_id != 0 
		) Data
LEFT JOIN	sys.messages sm
	ON	sm.message_id = data.SQL_Message_id
	AND	sm.language_id = 1033

WHERE		Job_Start_DateTime	<= '2010/05/27 04:10:00'
	AND	Job_End_DateTime	>= '2010/05/27 03:50:00'
ORDER BY	Instance_id

GO














WITH JobHistorySummary AS
(
    SELECT
        jobs.job_id,
        job_name = jobs.[name],
        step_id,
        step_name, 
        run_time,
        run_time_hours = run_time/10000,
        run_time_minutes = (run_time%10000)/100, 
        run_time_seconds = (run_time%10000)%100,
        run_time_elapsed_seconds = 
            (run_time/10000 /*run_time_hours*/ * 60 * 60 /* hours to minutes to seconds*/) +
            ((run_time%10000)/100 /* run_time_minutes */ * 60 /* minutes to seconds */ ) +
            (run_time%10000)%100,
        Start_Date = CONVERT(DATETIME, RTRIM(run_date)),
        Start_DateTime = 
            CONVERT(DATETIME, RTRIM(run_date)) + 
            ((run_time/10000 * 3600) + ((run_time%10000)/100*60) 
            + (run_time%10000)%100 /*run_time_elapsed_seconds*/) 
            / (23.999999*3600 /* seconds in a day*/),
        End_DateTime = 
            CONVERT(DATETIME, RTRIM(run_date)) 
            + ((run_time/10000 * 3600) 
            + ((run_time%10000)/100*60) 
            + (run_time%10000)%100) 
            / (86399.9964 /* Start Date Time */)
            + ((run_duration/10000 * 3600) 
            + ((run_duration%10000)/100*60) 
            + (run_duration%10000)%100 /*run_duration_elapsed_seconds*/) 
            / (86399.9964 /* seconds in a day*/)
    FROM msdb.dbo.sysjobs jobs WITH(NOLOCK)
        INNER JOIN msdb.dbo.sysjobhistory history WITH(NOLOCK) ON
            jobs.job_id = history.job_id
    WHERE step_name = '(Job outcome)' --Only interested in final outcome of jobs
)
SELECT	'CHECK TIME'  AS [Event]
	,COALESCE(@jobsRunningAt,getdate())	AS [DateTime]
UNION ALL
SELECT 
    'START  - ' + job_name  AS [Event]
    ,Start_DateTime	AS [DateTime]
FROM JobHistorySummary
WHERE Start_DateTime <= @jobsRunningAt AND End_DateTime >= @jobsRunningAt
UNION ALL
SELECT 
    'STOP   - ' + job_name
    ,End_DateTime
FROM JobHistorySummary
WHERE Start_DateTime <= COALESCE(@jobsRunningAt,getdate()) AND End_DateTime >= COALESCE(@jobsRunningAt,getdate())
ORDER BY [DateTime];

GO







select Formatmessage()


select ERROR_MESSAGE (701) 


select * From sys.messages order by message_id





DECLARE		@WindowStart	DateTime
		,@WindowEnd	DateTime

SELECT		@WindowStart	= '2010/05/27 03:50:00'
		,@WindowEnd	= '2010/05/27 04:10:00'



SELECT		instance_id
		,Job_name
		,step_name
		,step_id
		,SQL_Message_id
		,SQL_severity
		,[status]
		,[message]
		,Start_DateTime
		,End_DateTime
FROM		(
		SELECT		instance_id,
				jobs.job_id,
				job_name = jobs.[name],
				step_id,
				step_name,
				SQL_Message_id,
				SQL_severity,
				[status] = CASE run_status WHEN 0 THEN 'Failed' WHEN 1 THEN 'Succeeded' WHEN 2 THEN 'Retry' WHEN 3 THEN 'Canceled' WHEN 4 THEN 'In Progress' END,
				[message],
				run_time,
				run_time_hours = run_time/10000,
				run_time_minutes = (run_time%10000)/100, 
				run_time_seconds = (run_time%10000)%100,
				run_time_elapsed_seconds = 
					(run_time/10000 /*run_time_hours*/ * 60 * 60 /* hours to minutes to seconds*/) +
					((run_time%10000)/100 /* run_time_minutes */ * 60 /* minutes to seconds */ ) +
					(run_time%10000)%100,
				Start_Date = CONVERT(DATETIME, RTRIM(run_date)),
				Start_DateTime = 
					CONVERT(DATETIME, RTRIM(run_date)) + 
					((run_time/10000 * 3600) + ((run_time%10000)/100*60) 
					+ (run_time%10000)%100 /*run_time_elapsed_seconds*/) 
					/ (23.999999*3600 /* seconds in a day*/),
				End_DateTime = 
					CONVERT(DATETIME, RTRIM(run_date)) 
					+ ((run_time/10000 * 3600) 
					+ ((run_time%10000)/100*60) 
					+ (run_time%10000)%100) 
					/ (86399.9964 /* Start Date Time */)
					+ ((run_duration/10000 * 3600) 
					+ ((run_duration%10000)/100*60) 
					+ (run_duration%10000)%100 /*run_duration_elapsed_seconds*/) 
					/ (86399.9964 /* seconds in a day*/),
				--Job_SQL_Message_id = (
				--	SELECT TOP 1 SQL_Message_id
				--	FROM msdb.dbo.sysjobhistory T1
				--	WHERE T1.job_id = jobs.job_id
				--	AND T1.Step_id = 0
				--	AND T1.instance_id > history.instance_id
				--	ORDER BY run_date, run_time 
				--	),
				--Job_SQL_severity = (
				--	SELECT TOP 1 SQL_severity
				--	FROM msdb.dbo.sysjobhistory T1
				--	WHERE T1.job_id = jobs.job_id
				--	AND T1.Step_id = 0
				--	AND T1.instance_id > history.instance_id
				--	ORDER BY run_date, run_time 
				--	),
				--[Job_status] = (
				--	SELECT TOP 1 
				--	CASE run_status WHEN 0 THEN 'Failed' WHEN 1 THEN 'Succeeded' WHEN 2 THEN 'Retry' WHEN 3 THEN 'Canceled' WHEN 4 THEN 'In Progress' END
				--	FROM msdb.dbo.sysjobhistory T1
				--	WHERE T1.job_id = jobs.job_id
				--	AND T1.Step_id = 0
				--	AND T1.instance_id > history.instance_id
				--	ORDER BY run_date, run_time 
				--	),
				--Job_message = (
				--	SELECT TOP 1 Message
				--	FROM msdb.dbo.sysjobhistory T1
				--	WHERE T1.job_id = jobs.job_id
				--	AND T1.Step_id = 0
				--	AND T1.instance_id > history.instance_id
				--	ORDER BY run_date, run_time 
				--	),
				--Job_run_time = (
				--	SELECT TOP 1 run_time
				--	FROM msdb.dbo.sysjobhistory T1
				--	WHERE T1.job_id = jobs.job_id
				--	AND T1.Step_id = 0
				--	AND T1.instance_id > history.instance_id
				--	ORDER BY run_date, run_time 
				--	),
				--Job_run_time_hours = (
				--	SELECT TOP 1 run_time/10000
				--	FROM msdb.dbo.sysjobhistory T1
				--	WHERE T1.job_id = jobs.job_id
				--	AND T1.Step_id = 0
				--	AND T1.instance_id > history.instance_id
				--	ORDER BY run_date, run_time 
				--	),
				--Job_run_time_minutes = (
				--	SELECT TOP 1 (run_time%10000)/100
				--	FROM msdb.dbo.sysjobhistory T1
				--	WHERE T1.job_id = jobs.job_id
				--	AND T1.Step_id = 0
				--	AND T1.instance_id > history.instance_id
				--	ORDER BY run_date, run_time 
				--	), 
				--Job_run_time_seconds = (
				--	SELECT TOP 1 (run_time%10000)%100
				--	FROM msdb.dbo.sysjobhistory T1
				--	WHERE T1.job_id = jobs.job_id
				--	AND T1.Step_id = 0
				--	AND T1.instance_id > history.instance_id
				--	ORDER BY run_date, run_time 
				--	),
				--Job_run_time_elapsed_seconds = (
				--	SELECT TOP 1 
				--	(run_time/10000 /*run_time_hours*/ * 60 * 60 /* hours to minutes to seconds*/) +
				--	((run_time%10000)/100 /* run_time_minutes */ * 60 /* minutes to seconds */ ) +
				--	(run_time%10000)%100
				--	FROM msdb.dbo.sysjobhistory T1
				--	WHERE T1.job_id = jobs.job_id
				--	AND T1.Step_id = 0
				--	AND T1.instance_id > history.instance_id
				--	ORDER BY run_date, run_time 
				--	),
				Job_Start_DateTime = (
					SELECT TOP 1
					CONVERT(DATETIME, RTRIM(T1.run_date)) + 
					((T1.run_time/10000 * 3600) + ((T1.run_time%10000)/100*60) 
					+ (T1.run_time%10000)%100 /*run_time_elapsed_seconds*/) 
					/ (23.999999*3600 /* seconds in a day*/)
					FROM msdb.dbo.sysjobhistory T1
					WHERE T1.job_id = jobs.job_id
					AND T1.Step_id = 0
					AND T1.instance_id > history.instance_id
					ORDER BY run_date, run_time 
					),
				Job_End_DateTime = (
					SELECT TOP 1
					CONVERT(DATETIME, RTRIM(T2.run_date)) 
					+ ((T2.run_time/10000 * 3600) 
					+ ((T2.run_time%10000)/100*60) 
					+ (T2.run_time%10000)%100) 
					/ (86399.9964 /* Start Date Time */)
					+ ((T2.run_duration/10000 * 3600) 
					+ ((T2.run_duration%10000)/100*60) 
					+ (T2.run_duration%10000)%100 /*run_duration_elapsed_seconds*/) 
					/ (86399.9964 /* seconds in a day*/)					
					FROM msdb.dbo.sysjobhistory T2
					WHERE T2.job_id = jobs.job_id
					AND T2.Step_id = 0
					AND T2.instance_id > history.instance_id
					ORDER BY run_date, run_time 
					)
		FROM		msdb.dbo.sysjobs jobs WITH(NOLOCK)
		INNER JOIN	msdb.dbo.sysjobhistory history WITH(NOLOCK)
			ON	jobs.job_id = history.job_id
		WHERE		step_id != 0 
		) Data
WHERE		Job_Start_DateTime <= @WindowEnd
	AND	Job_End_DateTime >= @WindowStart

ORDER BY	7,2,4

GO







SELECT     Project, Task, TaskSequence, 
           StartDate, EndDate, PercentComplete, 
           DATEDIFF(DAY, StartDate, EndDate) 
                  * PercentComplete AS CompletedDays, 
           DATEDIFF(DAY, StartDate, EndDate) 
                  * (1 - PercentComplete) AS RemainingDays 
FROM         ProjectStatus



SELECT * From msdb.dbo.sysjobhistory WHERE job_id = '8BE893CA-2D47-4718-A153-9C2879E0B1AB' AND instance_id Between 5298100 AND 5298200


5298144
5298145
5298146
5298147
5298148
5298150
5298151
5298154
5298155
5298158
5298159
5298160










--SELECT 
--    job_name,
--    Start_DateTime,
--    End_DateTime
--FROM JobHistorySummary
--WHERE Start_DateTime <= @jobsRunningAt AND End_DateTime >= @jobsRunningAt
--ORDER BY End_DateTime DESC;






