
CREATE PROC	dbasp_WhatWasRunningAt
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

