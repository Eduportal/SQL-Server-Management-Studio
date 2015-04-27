USE [DBAadmin]
GO


EXEC [dbasp_WhatWasRunningBetween] '2014-09-15 17:20:00','2014-09-15 17:30:00',1
EXEC [dbasp_WhatWasRunningAt] '2014-09-15 17:29:00'




USE [DBAadmin]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_WhatWasRunningAt]    Script Date: 9/16/2014 1:06:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROC	[dbo].[dbasp_WhatWasRunningAt]
	(
	@jobsRunningAt DATETIME = NULL
	)
AS	
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



/****** Object:  StoredProcedure [dbo].[dbasp_WhatWasRunningBetween]    Script Date: 9/16/2014 12:54:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC	[dbo].[dbasp_WhatWasRunningBetween]
	(
	@WindowStart	DateTime = NULL
	,@WindowEnd	DateTime = NULL
	,@ShowSteps	Bit	 = 0
	)
AS

SELECT		DISTINCT
		--instance_id
		Job_name
		,CASE @ShowSteps WHEN 1 Then step_name else '' END AS step_name
		,CASE @ShowSteps WHEN 1 Then step_id else '' END AS step_id
		,CASE @ShowSteps WHEN 1 Then SQL_Message_id ELSE '' END AS SQL_Message_id
		,CASE @ShowSteps WHEN 1 Then SM.text ELSE '' END AS SQL_Message
		,CASE @ShowSteps WHEN 1 Then SQL_severity ELSE '' END AS SQL_severity
		,CASE @ShowSteps WHEN 1 Then [status] ELSE '' END AS [status]
		,CASE @ShowSteps WHEN 1 Then [message] ELSE '' END AS [message]
		,CASE @ShowSteps WHEN 1 Then Start_DateTime ELSE Job_Start_DateTime END AS Start_DateTime
		,CASE @ShowSteps WHEN 1 Then End_DateTime ELSE Job_End_DateTime END AS End_DateTime
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

WHERE		Job_Start_DateTime	<= COALESCE(@WindowEnd,GetDate())
	AND	Job_End_DateTime	>= COALESCE(@WindowStart,GetDate()-.25)
--ORDER BY	Instance_id


GO

