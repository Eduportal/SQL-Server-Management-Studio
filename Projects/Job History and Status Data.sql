
-- Do not lock anything, and do not get held up by any locks. 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET	NOCOUNT ON

DECLARE		@FilterOutlierPercent	INT
DECLARE		@FloatRange				INT
DECLARE		@Today					DateTime
DECLARE		@share_name				VarChar(255)
DECLARE		@LogPath				VarChar(100)
DECLARE		@Results				TABLE		(
												[JobName]						[sysname]	NOT NULL
												,[OwnerName]					[sysname]	NOT NULL
												,[WeightedAverageRunDuration]	[INT]		NULL
												,[AverageRunDuration]			[INT]		NULL	
												,[AVGDevs]						[float]		NULL	
												,[ExecutionsToday]				[INT]		NULL	
												,[OutliersToday]				[INT]		NULL	
												,[Executions]					[INT]		NULL	
												,[LastRun]						[DateTime]	NULL
												,[Failures]						[INT]		NULL	
												,[FailuresToday]				[INT]		NULL	
												,[LastStatus]					[INT]		NULL
												,[LastStatusMsg]				[SYSNAME]	NULL
												,[CurrentCount]					[INT]		NULL
												,[AvgDailyExecutionsCount]		[FLOAT]		NULL	
												,[MaxDailyExecutionsCount]		[FLOAT]		NULL	
												,[AvgDailyFailCount]			[FLOAT]		NULL
												,[MaxDailyFailCount]			[FLOAT]		NULL
												,[AvgDailyFailPercent]			[FLOAT]		NULL
												,[MaxDailyFailPercent]			[FLOAT]		NULL
												)
									

SET			@FilterOutlierPercent	= 10
SET			@FloatRange				= 100
SET			@Today					= CAST(CONVERT(VarChar(12),GetDate(),101)AS DATETIME)
SET			@share_name				=  REPLACE(@@SERVERNAME,'\','$') + '_SQLjob_logs'

EXEC		dbaadmin.dbo.dbasp_get_share_path @share_name = @share_name, @phy_path = @LogPath OUT

;WITH		JobHistoryData
			AS
			(
			SELECT		job_id
						,row_number() over (PARTITION BY job_id order by [StartDateTime])		AS RowNumber
						,row_number() over (PARTITION BY job_id order by [StartDateTime] DESC)	AS RowNumberInversion
						,COUNT(*) over (PARTITION BY job_id)									AS SetCount
						,(@FilterOutlierPercent 
							* COUNT(*) over (PARTITION BY job_id))
							/ 100																AS OutlierRowCount
						,RANK() OVER (PARTITION BY job_id order by [Duration_Seconds])			AS ValueRankAsc
						,RANK() OVER (PARTITION BY job_id order by [Duration_Seconds]DESC)		AS ValueRankDesc
						,StartDateTime	[Start]
						,EndDateTime	[Stop]
						,Duration_Seconds [Seconds]
						,run_status
						,message						 
			FROM		(
						SELECT		msdb.dbo.agent_datetime(run_date,run_time) AS StartDateTime
									,DATEADD(s,DATEDIFF(s,msdb.dbo.agent_datetime(run_date,0),msdb.dbo.agent_datetime(run_date,run_duration%240000)+(run_duration/240000)),msdb.dbo.agent_datetime(run_date,run_time)) AS EndDateTime
									,DATEDIFF(s,msdb.dbo.agent_datetime(run_date,0),msdb.dbo.agent_datetime(run_date,run_duration%240000)+(run_duration/240000)) AS Duration_Seconds
									,*
						from		msdb..sysjobhistory
						where		step_id = 0 
						) JobHistory
			)
			,F0
			AS
			(
			SELECT		job_id
						,RowNumber
			FROM		JobHistoryData
			WHERE		run_status = 0
			)
			,F1
			AS
			(
			SELECT		job_id
						,RowNumber
						,RowNumber - ROW_NUMBER() OVER (PARTITION BY job_id ORDER BY RowNumber) AS Grp
			FROM		F0
			)
			,S0
			AS
			(
			SELECT		job_id
						,RowNumber
			FROM		JobHistoryData
			WHERE		run_status = 1
			)
			,S1
			AS
			(
			SELECT		job_id
						,RowNumber
						,RowNumber - ROW_NUMBER() OVER (PARTITION BY job_id ORDER BY RowNumber) AS Grp
			FROM		S0
			)
			,T1
			AS
			(			
			SELECT		job_id
						,RowNumber
						,ROW_NUMBER() OVER (PARTITION BY job_id,Grp ORDER BY RowNumber) AS Consecutive
			FROM		F1
			UNION ALL
			SELECT		job_id
						,RowNumber
						,ROW_NUMBER() OVER (PARTITION BY job_id,Grp ORDER BY RowNumber) AS Consecutive
			FROM		S1
			)
			,DailyFailRate
			AS
			(
			SELECT		job_id
						,AVG([DailyExecutionsCount])	[AvgDailyExecutionsCount]
						,MAX([DailyExecutionsCount])	[MaxDailyExecutionsCount]
						,AVG([DailyFailCount])			[AvgDailyFailCount]
						,MAX([DailyFailCount])			[MaxDailyFailCount]
						,AVG([DailyFailPercent])		[AvgDailyFailPercent]
						,MAX([DailyFailPercent])		[MaxDailyFailPercent]
			FROM		(						
						SELECT		job_id
									,CAST(CONVERT(VarChar(12),[Start],101)AS DateTime)	AS [StartDay]
									,COUNT(*)+0.0										AS [DailyExecutionsCount]
									,COUNT(CASE run_status WHEN 0 THEN 1 END)+0.0		AS [DailyFailCount]
									,(100*(COUNT(CASE run_status WHEN 0 THEN 1 END)+0.0))
										/(COUNT(*)+0.0)									AS [DailyFailPercent] 
						FROM		JobHistoryData
						GROUP BY	job_id
									,CAST(CONVERT(VarChar(12),[Start],101)AS DateTime)
						)DFR
			GROUP BY	job_id						
			)
			,FloatingAverage
			AS
			(
			SELECT		[JobHistoryData].job_id
						,[JobHistoryData].RowNumber
						,AVG([JobHistoryData3].Seconds)				AS AVG_Value
						,STDEVP([JobHistoryData3].Seconds)			AS STDEVP_Value
			FROM		[JobHistoryData]
			JOIN		(
						SELECT		*
						FROM		[JobHistoryData]
						WHERE		ValueRankAsc	> OutlierRowCount
								AND	ValueRankDesc	> OutlierRowCount
						) [JobHistoryData3]
					ON	[JobHistoryData].job_id	= [JobHistoryData3].job_id
					AND ABS([JobHistoryData].RowNumber - [JobHistoryData3].RowNumber) < @FloatRange
			GROUP BY	[JobHistoryData].job_id	
						,[JobHistoryData].RowNumber
			)
			,Results
			AS
			(
			SELECT		(SELECT name from msdb..sysjobs where job_id = T1.job_id) JobName
						,T1.job_id
						,T1.RowNumber
						,T1.RowNumberInversion
						,T1.Start
						,T1.Stop
						,T1.Seconds
						,run_status
						,CASE run_status 
							WHEN 0 THEN 'Failure' 
							WHEN 1 THEN 'Success' 
							WHEN 2 THEN 'Retry' 
							WHEN 3 THEN 'Cancelled' 
							WHEN 4 THEN 'Running' 
							ELSE 'Other: ' + 
							Convert(VARCHAR,run_status) 
						  END AS run_status_msg
						,message				
						,ABS(Seconds-AVG_Value)/isnull(nullif(STDEVP_Value,0),1)		AS DevsFromAvg
						,CAST(ABS(Seconds-AVG_Value)/isnull(nullif(STDEVP_Value,0),1)/2 AS INT) AS TREND
						,T2.AVG_Value
						,T2.STDEVP_Value
			FROM		[JobHistoryData] T1
			JOIN		[FloatingAverage] T2
					ON	T1.job_id = T2.job_id
					AND T1.RowNumber = T2.RowNumber
			)
			--,Schedules
			--AS
			--(
			--SELECT		schedule_id
			--			,name
			--			,enabled
			--			,CASE freq_type
			--					WHEN 1 THEN 'One Time'
			--					WHEN 4 THEN CASE freq_subday_type 
			--										WHEN 1 THEN 'Daily'
			--										WHEN 2 THEN 'Second-ly'
			--										WHEN 4 THEN 'Minutely'
			--										WHEN 8 THEN 'Hourly'
			--										ELSE ''
			--										END
			--					WHEN 8 THEN 'Weekly'
			--					WHEN 16 THEN 'Monthly'
			--					WHEN 32 THEN 'Monthly, relative to freq_interval'
			--					WHEN 64 THEN 'Runs when the SQL Server Agent service starts'
			--					WHEN 128 THEN 'Runs when the computer is idle'
			--					END AS [Freq_Type]
								
			--			,CASE freq_type
			--					WHEN 1	THEN 'one time at ' + CONVERT(VarChar(100), msdb.dbo.agent_datetime(active_start_date,active_start_time),120)
			--					WHEN 8	THEN 'every ' + CAST(freq_recurrence_factor AS varchar(10)) + ' week(s) '	/* (weekly) */				
			--					WHEN 16	THEN 'every ' + CAST(freq_recurrence_factor AS varchar(10)) + ' month(s) '	/* (monthly) */				
			--					WHEN 32	THEN 'every ' + CAST(freq_recurrence_factor AS varchar(10)) + ' week(s) '	/* (monthly relative) */	
			--					ELSE ''
			--					END AS freq_recurrence_factor
																
			--			, CASE freq_type
			--					WHEN 4	THEN 'every ' + CAST(freq_interval AS varchar(10)) + ' day(s) '				/* (daily) */
			--					WHEN 8	THEN REPLACE	(															/* (weekly) */	
			--											  CASE WHEN freq_interval&1 = 1		THEN 'Sunday, '		ELSE '' END
			--											+ CASE WHEN freq_interval&2 = 2		THEN 'Monday, '		ELSE '' END
			--											+ CASE WHEN freq_interval&4 = 4		THEN 'Tuesday, '	ELSE '' END
			--											+ CASE WHEN freq_interval&8 = 8		THEN 'Wednesday, '	ELSE '' END
			--											+ CASE WHEN freq_interval&16 = 16	THEN 'Thursday, '	ELSE '' END
			--											+ CASE WHEN freq_interval&32 = 32	THEN 'Friday, '		ELSE '' END
			--											+ CASE WHEN freq_interval&64 = 64	THEN 'Saturday, '	ELSE '' END
			--											+ '|'
			--											, ', |'
			--											, ' ') /* get rid of trailing comma */
			--					WHEN 16	THEN 'on day ' + CAST(freq_interval AS varchar(10)) + ' of every month '	/* (monthly) */
			--					WHEN 32 THEN 'Every ' + CASE freq_interval											/* (day of week) */
			--												WHEN 1 THEN 'Sunday'
			--												WHEN 2 THEN 'Monday'
			--												WHEN 3 THEN 'Tuesday'
			--												WHEN 4 THEN 'Wednesday'
			--												WHEN 5 THEN 'Thursday'
			--												WHEN 6 THEN 'Friday'
			--												WHEN 7 THEN 'Saturday'
			--												WHEN 8 THEN 'Day'
			--												WHEN 9 THEN 'Weekday'
			--												WHEN 10 THEN 'Weekend day'
			--												END
			--					ELSE ''
			--					END AS [freq_interval]
								
			--			,CASE freq_subday_type
			--					WHEN 1 THEN 'at ' +  CONVERT(VarChar(100), msdb.dbo.agent_datetime(active_start_date,active_start_time),108)
			--					WHEN 2 THEN ', every ' + CAST(freq_subday_interval AS varchar(10)) + ' second(s)'
			--					WHEN 4 THEN ', every ' + CAST(freq_subday_interval AS varchar(10)) + ' minute(s)'
			--					WHEN 8 THEN ', every ' + CAST(freq_subday_interval AS varchar(10)) + ' hour(s)'
			--					ELSE ''
			--					END
			--			+ CASE
			--					WHEN	freq_subday_type in (2,4,8) /* repeat seconds/mins/hours */
			--					THEN	', between '  + CONVERT(VarChar(100), msdb.dbo.agent_datetime(active_start_date,active_start_time),108)
			--							+ ' and ' + CONVERT(VarChar(100), msdb.dbo.agent_datetime(active_end_date,active_end_time),108)
			--					ELSE	''
			--					END AS [freq_subday_type]



			--			,CONVERT(VarChar(100), msdb.dbo.agent_datetime(active_start_date,active_start_time),120)	AS starttime
			--			,CONVERT(VarChar(100), msdb.dbo.agent_datetime(active_end_date,active_end_time),120)		AS endtime
			--FROM		msdb.dbo.sysschedules
			--)
			--,JobSchedules
			--AS
			--(
			--SELECT		SJ.job_id
			--			,SS.schedule_id
			--			,SJ.enabled		AS is_job_enabled
			--			,SS.enabled		AS is_schedule_enabled
			--			,SS.name		AS schedule_name
			--			,SS.Freq_type
			--			,'Occurs ' +SS.freq_recurrence_factor+SS.freq_interval+SS.freq_subday_type AS Description
			--			,SS.starttime
			--			,SS.endtime			
			--FROM		msdb.dbo.sysjobs SJ
			--JOIN		msdb.dbo.sysjobschedules SJS
			--		ON	SJ.job_id = SJS.job_id
			--JOIN		Schedules SS
			--		ON	SJS.schedule_id = SS.schedule_id
			--)
			--,JobSchedSummaries
			--AS
			--(
			--SELECT		DISTINCT
			--			job_id
			--			,(REPLACE	(
			--					STUFF	(
			--							(
			--							SELECT		'|' + schedule_name +' -- (' + Freq_type	+ ') -- "' + Description +'" ' + CONVERT(VarChar(50),starttime,101) + ' - ' + CONVERT(VarChar(50),endtime,101)
			--							FROM		JobSchedules S2 
			--							WHERE		S1.job_id = S2.job_id	
			--							ORDER BY	1
			--							FOR XML PATH(''), TYPE, ROOT
			--							).value('root[1]','nvarchar(max)')
			--							,1
			--							,1
			--							,''
			--							)
			--						,'|'
			--						,CHAR(13)+CHAR(10)
			--						)	
			--					) as Descriptions
			--FROM		JobSchedules S1
			--)
INSERT INTO	@Results						
SELECT		jh.JobName
			,(	SELECT Name 
				From sys.syslogins 
				WHERE sid = (	SELECT owner_sid 
								FROM msdb..sysjobs 
								WHERE job_id = jh.job_id
							)
				)															AS [Owner Name]
			,AVG(AVG_Value)													AS [Weighted Average Run Duration]
			,AVG(Seconds)													AS [Average Run Duration]
			,AVG(DevsFromAvg)												AS [AVGDevs]
			,COUNT(CASE WHEN [Start] >= @Today 
						THEN 1 END)											AS [ExecutionsToday]
			,COUNT(CASE WHEN [Start] >= @Today AND [Trend] >= 20 
						THEN 1 END)											AS [OutliersToday]
			,Count(*)														AS [Executions]
			,max([Start])													AS [LastRun]
			
			,COUNT(CASE run_status WHEN 0 THEN 1 END)						AS [Failures]	
			,COUNT(CASE
					WHEN [Start] >= 
					CAST(CONVERT(VarChar(12),GetDate(),101)AS DATETIME) 
					AND [run_status]= 0 THEN 1 END)							AS [FailuresToday]
			,MAX(CASE RowNumberInversion WHEN 1 THEN [run_status] END)		AS [LastStatus]
			,MAX(CASE RowNumberInversion WHEN 1 THEN [run_status_msg] END)	AS [LastStatusMsg]
			,MAX(CASE RowNumberInversion WHEN 1 THEN T1.Consecutive END)	AS [CurrentCount]
			,max(DFR.[AvgDailyExecutionsCount])								AS [AvgDailyExecutionsCount]	
			,max(DFR.[MaxDailyExecutionsCount])								AS [MaxDailyExecutionsCount]	
			,max(DFR.[AvgDailyFailCount])									AS [AvgDailyFailCount]
			,max(DFR.[MaxDailyFailCount])									AS [MaxDailyFailCount]
			,max(DFR.[AvgDailyFailPercent])									AS [AvgDailyFailPercent]
			,max(DFR.[MaxDailyFailPercent])									AS [MaxDailyFailPercent]

FROM		Results jh
--LEFT JOIN	JobSchedSummaries S 
--		ON	S.job_id = jh.job_id
LEFT JOIN	T1
		ON	T1.job_id = jh.job_id
		AND	T1.RowNumber = jh.RowNumber	
LEFT JOIN	DailyFailRate DFR
		ON	DFR.job_id = jh.job_id			
GROUP BY	jh.JobName
			,jh.job_id


SELECT		*
FROM		(

			SELECT		'Warning' AS [Level]
						,'The Job "'
						+JobName
						+'" has run longer or shorter than expected '+CAST(OutliersToday AS VarChar(10))+' times Today.'  AS [Alert]
			From		@Results			
			WHERE		COALESCE(OutliersToday,0) > 0 AND LastStatus = 1	
			UNION ALL

			SELECT		CASE WHEN (FailuresToday*100)/COALESCE(NULLIF(ExecutionsToday,0),1) > AvgDailyFailPercent + ((MaxDailyFailPercent-AvgDailyFailPercent)/2) THEN 'Error' ELSE	
						'Warning' END AS [Level]
						,'The Job "'
						+JobName
						+'" has Failed '+CAST(FailuresToday AS VarChar(10))+' times Today.'  AS [Alert]
			From		@Results			
			WHERE		COALESCE(FailuresToday,0) > 0 AND LastStatus = 1
			UNION ALL

			SELECT		'Error' AS [Level]
						,'The Job "'
						+JobName
						+'" last execution on "'+CAST(LastRun AS VarChar(50))+'" Failed' 
						+ CASE WHEN CurrentCount > 1 THEN ', and has Failed ' +CAST(CurrentCount AS VarChar(5))+ ' times in a row.' ELSE '.' END AS [Alert]
			From		@Results			
			WHERE		LastStatus = 0	
			UNION ALL
						
			SELECT		'Warning' AS [Level]
						,'The Job "'
						+JobName
						+'" is owned by "'+OwnerName+'" rather than "SA".' AS [Alert]
			From		@Results			
			WHERE		OwnerName != 'sa'	
			UNION ALL
			SELECT		'Warning' AS [Level]
						,'The Job "'
						+(SELECT name from msdb..sysjobs where job_id = T1.job_id)
						+'" (step '+ Cast(step_id AS VarChar(5)) +') "'
						+step_name
						+'" Points to Database "'+database_name+'" rather than Master.' AS [Alert]
			FROM		msdb..sysjobsteps T1
			WHERE		database_name != 'master'			

			UNION ALL
			SELECT		'Error' AS [Level]
						,'The Job "'
						+(SELECT name from msdb..sysjobs where job_id = T1.job_id)
						+'" (step '+ Cast(step_id AS VarChar(5)) +') "'
						+step_name
						+'" Does not have an output log.' AS [Alert]
			FROM		msdb..sysjobsteps T1
			WHERE		nullif(output_file_name,'') IS NULL
						
			UNION ALL
			SELECT		'Warning' AS [Level]
						,'The Job "'
						+(SELECT name from msdb..sysjobs where job_id = T1.job_id)
						+'" (step '+ Cast(step_id AS VarChar(5)) +') "'
						+step_name
						+'" Output Log File points to "'+output_file_name+'" to the "SQLjob_logs" share.' AS [Alert]
			FROM		msdb..sysjobsteps T1
			WHERE		output_file_name NOT LIKE @LogPath +'%'	
					AND	output_file_name NOT LIKE '\\'+CAST(SERVERPROPERTY('machinename')AS VarChar(50))+'\'+@share_name +'\%'	
									
			UNION ALL
			SELECT		'Warning' AS [Level]
						,'The Job "'
						+(SELECT name from msdb..sysjobs where job_id = T1.job_id)
						+'" (step '+ Cast(step_id AS VarChar(5)) +') "'
						+step_name
						+'" Output Log File is set to Overwrite instead of Append.' AS [Alert]
			FROM		msdb..sysjobsteps T1
			WHERE		flags & 2 != 2		

			UNION ALL
			SELECT		'Warning' AS [Level]
						,'The Job "'
						+(SELECT name from msdb..sysjobs where job_id = T1.job_id)
						+'" (step '+ Cast(step_id AS VarChar(5)) +') "'
						+step_name
						+'" Output Log File does not include job step output.' AS [Alert]
			FROM		msdb..sysjobsteps T1
			WHERE		flags & 4 != 4
			) Alerts
WHERE		[Level] = 'Error'			
					