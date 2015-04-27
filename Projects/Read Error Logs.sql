----select * From sysobjects where name like '%error%'

----select * From sys.traces

----sp_trace_getdata 1

----DECLARE		@FileName	VarChar(8000)

----SELECT		@FileName = CAST(value AS VarChar(8000))
----FROM		fn_trace_getinfo(1)
----WHERE		Property = 2

----SELECT		[TextData]
----			,[DatabaseID]	
----			--,[TransactionID]
----			--,[LineNumber]
----			,[NTUserName]
----			,[NTDomainName]
----			,[HostName]
----			,[ClientProcessID]
----			,[ApplicationName]
----			,[LoginName]
----			,[SPID]
----			--,[Duration]
----			,[StartTime]
----			--,[EndTime]
----			--,[Reads]
----			--,[Writes]	
----			--,[CPU]
----			--,[Permissions]
----			--,[Severity]
----			,[EventSubClass]
----			--,[ObjectID]
----			,[Success]
----			--,[IndexID]
----			--,[IntegerData]	
----			--,[ServerName]	
----			,[EventClass]	
----			--,[ObjectType]	
----			--,[NestLevel]
----			--,[State]
----			,[Error]
----			--,[Mode]
----			--,[Handle]
----			--,[ObjectName]
----			,[DatabaseName]
----			--,[FileName]
----			--,[OwnerName]
----			--,[RoleName]
----			--,[TargetUserName]
----			--,[DBUserName]	
----			--,[LoginSid]
----			--,[TargetLoginName]
----			--,[TargetLoginSid]
----			--,[ColumnPermissions]
----			--,[LinkedServerName]
----			--,[ProviderName]
----			--,[MethodName]	
----			--,[RowCounts]
----			,[RequestID]
----			--,[XactSequence]
----			,[EventSequence]
----			--,[BigintData1]
----			--,[BigintData2]
----			--,[GUID]
----			--,[IntegerData2]
----			--,[ObjectID2]
----			--,[Type]
----			--,[OwnerID]
----			--,[ParentName]	
----			--,[IsSystem]
----			--,[Offset]
----			--,[SourceDatabaseID]
----			--,[SqlHandle]
----			,[SessionLoginName]
----			--,[PlanHandle]

----FROM		fn_trace_gettable(@FileName,1)
----WHERE		TextData Like '%Login%'
----		AND	SPID != @@SPID
----ORDER BY	StartTime

SET			NOCOUNT		ON

DECLARE		@DateStart	DATETIME
DECLARE		@DateStop	DATETIME
DECLARE		@DateAdjust	INT
DECLARE		@ErrorLog	TABLE(LogNumber INT NULL, EventDate DateTime,ProcessInfo SYSNAME, Text VarChar(max))
DECLARE		@LogList	TABLE(ArchiveNumber INT,EventDate DateTime,LogSize BIGINT)
DECLARE		@JobLogList	TABLE(job_id uniqueidentifier, JobName VarChar(2048), FileName VarChar(4000))
DECLARE		@DateTemp	DATETIME
DECLARE		@ActiveLog	INT
DECLARE		@Job_id		Uniqueidentifier

-- GET PST TIMEZONE UPDATE VALUE
SELECT		@DateAdjust = 0 --7 - DATEDIFF(hour,GetDate(),GetUTCDate())

SELECT		@DateStart	= '2012-06-08 00:00:00.000'
			,@DateStop	= '2012-06-11 00:00:00.000'

-- AUTOMATICLY FIX IF DATES ARE BACKWARDS
SELECT		@DateStart	= MIN(Date)
			,@DateStop	= MAX(Date)
FROM		(
			SELECT	COALESCE(@DateStart,'0001-01-01 00:00:00.000') [Date] UNION ALL
			SELECT	COALESCE(@DateStop,'9999-12-31 23:59:59.999')
			) Dates

--;With		JobHistory
--			AS
--			(
--			SELECT		msdb.dbo.agent_datetime(run_date,run_time) AS StartDateTime
--						,DATEADD(s,DATEDIFF(s,msdb.dbo.agent_datetime(run_date,0),msdb.dbo.agent_datetime(run_date,run_duration)),msdb.dbo.agent_datetime(run_date,run_time)) AS EndDateTime
--						,DATEDIFF(s,msdb.dbo.agent_datetime(run_date,0),msdb.dbo.agent_datetime(run_date,run_duration)) AS Duration_Seconds
--						,*
--			from		msdb..sysjobhistory WITH(NOLOCK)
--			WHERE		msdb.dbo.agent_datetime(run_date,run_time) BETWEEN @DateStart AND @DateStop
--					OR	DATEADD(s,DATEDIFF(s,msdb.dbo.agent_datetime(run_date,0),msdb.dbo.agent_datetime(run_date,run_duration)),msdb.dbo.agent_datetime(run_date,run_time)) BETWEEN @DateStart AND @DateStop
--					OR	(
--						msdb.dbo.agent_datetime(run_date,run_time) < @DateStart
--					AND	DATEADD(s,DATEDIFF(s,msdb.dbo.agent_datetime(run_date,0),msdb.dbo.agent_datetime(run_date,run_duration)),msdb.dbo.agent_datetime(run_date,run_time)) > @DateStop
--						)			
--			)
-----INSERT INTO	@JobLogList			
--SELECT		DISTINCT
--			j.job_id
--			,j.name
--			,s.output_file_name
--FROM		msdb..sysjobs j
--JOIN		msdb..sysjobsteps s
--		ON	j.job_id = s.job_id
--WHERE		j.job_id IN	(			
--						SELECT		DISTINCT 
--									job_id
--						FROM		JobHistory
--						)

--DECLARE		@FileName		VarChar(8000)

--WHILE EXISTS (SELECT * FROM @JobLogList)
--BEGIN
--	SELECT		TOP 1
--				@Job_id = job_id
--				,@FileName = FileName
--	FROM		@JobLogList
--	ORDER BY	job_id

--	--INSERT INTO	@ErrorLog(EventDate,ProcessInfo,[Text])
--	exec		sp_readerrorlog 1,1, 'S:\sql\MSSQL.1\MSSQL\log\SQLjob_logs\maint_weekly_process.txt'
	
--	--UPDATE		@ErrorLog SET LogNumber = @ActiveLog WHERE LogNumber IS NULL

--	DELETE		@JobLogList
--	WHERE		job_id = @Job_id
--END



---- Do not lock anything, and do not get held up by any locks. 
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--DECLARE		@FilterOutlierPercent	INT
--DECLARE		@FloatRange				INT

--SET			@FilterOutlierPercent	= 10
--SET			@FloatRange				= 100

--DECLARE		@Results	TABLE		(
--									[JobName] [sysname] NOT NULL,
--									[job_id] [uniqueidentifier] NOT NULL,
--									[instance_id] [int] NOT NULL,
--									[RowNumber] [bigint] NULL,
--									[Start] [datetime] NULL,
--									[Stop] [datetime] NULL,
--									[Seconds] [numeric](12, 1) NULL,
--									[run_status] [int] NOT NULL,
--									[run_status_msg] [nvarchar](50) NULL,
--									[message] [nvarchar](1024) NULL,
--									[DevsFromAvg] [float] NULL,
--									[TREND] [INT] NULL,
--									[AVG_Value] [numeric](38, 6) NULL,
--									[STDEVP_Value] [float] NULL,
--									[schedule_id] [INT] NULL,
--									[is_job_enabled] [INT] NULL,
--									[is_schedule_enabled] [INT] NULL,
--									[schedule_name] [nvarchar](1024) NULL,
--									[Freq_type] [nvarchar](1024) NULL,
--									[Description] [nvarchar](1024) NULL,
--									[starttime] [datetime] NULL,
--									[endtime] [datetime] NULL										
--									)

--;WITH		Schedules
--			AS
--			(
--			SELECT		schedule_id
--						,name
--						,enabled
--						,CASE freq_type
--								WHEN 1 THEN 'One Time'
--								WHEN 4 THEN CASE freq_subday_type 
--													WHEN 1 THEN 'Daily'
--													WHEN 2 THEN 'Second-ly'
--													WHEN 4 THEN 'Minutely'
--													WHEN 8 THEN 'Hourly'
--													ELSE ''
--													END
--								WHEN 8 THEN 'Weekly'
--								WHEN 16 THEN 'Monthly'
--								WHEN 32 THEN 'Monthly, relative to freq_interval'
--								WHEN 64 THEN 'Runs when the SQL Server Agent service starts'
--								WHEN 128 THEN 'Runs when the computer is idle'
--								END AS [Freq_Type]
								
--						,CASE freq_type
--								WHEN 1	THEN 'one time at ' + CONVERT(VarChar(100), msdb.dbo.agent_datetime(active_start_date,active_start_time),120)
--								WHEN 8	THEN 'every ' + CAST(freq_recurrence_factor AS varchar(10)) + ' week(s) '	/* (weekly) */				
--								WHEN 16	THEN 'every ' + CAST(freq_recurrence_factor AS varchar(10)) + ' month(s) '	/* (monthly) */				
--								WHEN 32	THEN 'every ' + CAST(freq_recurrence_factor AS varchar(10)) + ' week(s) '	/* (monthly relative) */	
--								ELSE ''
--								END AS freq_recurrence_factor
																
--						, CASE freq_type
--								WHEN 4	THEN 'every ' + CAST(freq_interval AS varchar(10)) + ' day(s) '				/* (daily) */
--								WHEN 8	THEN REPLACE	(															/* (weekly) */	
--														  CASE WHEN freq_interval&1 = 1		THEN 'Sunday, '		ELSE '' END
--														+ CASE WHEN freq_interval&2 = 2		THEN 'Monday, '		ELSE '' END
--														+ CASE WHEN freq_interval&4 = 4		THEN 'Tuesday, '	ELSE '' END
--														+ CASE WHEN freq_interval&8 = 8		THEN 'Wednesday, '	ELSE '' END
--														+ CASE WHEN freq_interval&16 = 16	THEN 'Thursday, '	ELSE '' END
--														+ CASE WHEN freq_interval&32 = 32	THEN 'Friday, '		ELSE '' END
--														+ CASE WHEN freq_interval&64 = 64	THEN 'Saturday, '	ELSE '' END
--														+ '|'
--														, ', |'
--														, ' ') /* get rid of trailing comma */
--								WHEN 16	THEN 'on day ' + CAST(freq_interval AS varchar(10)) + ' of every month '	/* (monthly) */
--								WHEN 32 THEN 'Every ' + CASE freq_interval											/* (day of week) */
--															WHEN 1 THEN 'Sunday'
--															WHEN 2 THEN 'Monday'
--															WHEN 3 THEN 'Tuesday'
--															WHEN 4 THEN 'Wednesday'
--															WHEN 5 THEN 'Thursday'
--															WHEN 6 THEN 'Friday'
--															WHEN 7 THEN 'Saturday'
--															WHEN 8 THEN 'Day'
--															WHEN 9 THEN 'Weekday'
--															WHEN 10 THEN 'Weekend day'
--															END
--								ELSE ''
--								END AS [freq_interval]
								
--						,CASE freq_subday_type
--								WHEN 1 THEN 'at ' +  CONVERT(VarChar(100), msdb.dbo.agent_datetime(active_start_date,active_start_time),108)
--								WHEN 2 THEN ', every ' + CAST(freq_subday_interval AS varchar(10)) + ' second(s)'
--								WHEN 4 THEN ', every ' + CAST(freq_subday_interval AS varchar(10)) + ' minute(s)'
--								WHEN 8 THEN ', every ' + CAST(freq_subday_interval AS varchar(10)) + ' hour(s)'
--								ELSE ''
--								END
--						+ CASE
--								WHEN	freq_subday_type in (2,4,8) /* repeat seconds/mins/hours */
--								THEN	', between '  + CONVERT(VarChar(100), msdb.dbo.agent_datetime(active_start_date,active_start_time),108)
--										+ ' and ' + CONVERT(VarChar(100), msdb.dbo.agent_datetime(active_end_date,active_end_time),108)
--								ELSE	''
--								END AS [freq_subday_type]



--						,CONVERT(VarChar(100), msdb.dbo.agent_datetime(active_start_date,active_start_time),120)	AS starttime
--						,CONVERT(VarChar(100), msdb.dbo.agent_datetime(active_end_date,active_end_time),120)		AS endtime
--			FROM		msdb.dbo.sysschedules
--			)
--			,JobSchedules
--			AS
--			(
--			SELECT		SJ.job_id
--						,SS.schedule_id
--						,SJ.enabled		AS is_job_enabled
--						,SS.enabled		AS is_schedule_enabled
--						,SS.name		AS schedule_name
--						,SS.Freq_type
--						,'Occurs ' +SS.freq_recurrence_factor+SS.freq_interval+SS.freq_subday_type AS Description
--						,SS.starttime
--						,SS.endtime			
--			FROM		msdb.dbo.sysjobs SJ
--			JOIN		msdb.dbo.sysjobschedules SJS
--					ON	SJ.job_id = SJS.job_id
--			JOIN		Schedules SS
--					ON	SJS.schedule_id = SS.schedule_id
--			)
--			--,JobSchedSummaries
--			--AS
--			--(
--			--SELECT		DISTINCT
--			--			job_id
						
--			--			,(REPLACE	(
--			--					STUFF	(
--			--							(
--			--							SELECT		'|' + schedule_name +' -- (' + Freq_type	+ ') -- "' + Description +'" ' + CONVERT(VarChar(50),starttime,101) + ' - ' + CONVERT(VarChar(50),endtime,101)
--			--							FROM		JobSchedules S2 
--			--							WHERE		S1.job_id = S2.job_id	
--			--							ORDER BY	1
--			--							FOR XML PATH(''), TYPE, ROOT
--			--							).value('root[1]','nvarchar(max)')
--			--							,1
--			--							,1
--			--							,''
--			--							)
--			--						,'|'
--			--						,CHAR(13)+CHAR(10)
--			--						)	
--			--					) as FirstNames
--			--FROM		JobSchedules S1
--			--)
--			,JobHistoryData
--			AS
--			(
--			SELECT		job_id
--						,instance_id
--						,row_number() over (PARTITION BY job_id order by [StartDateTime])		AS RowNumber
--						,COUNT(*) over (PARTITION BY job_id)									AS SetCount
--						,(@FilterOutlierPercent 
--							* COUNT(*) over (PARTITION BY job_id))
--							/ 100																AS OutlierRowCount
--						,RANK() OVER (PARTITION BY job_id order by [Duration_Seconds])			AS ValueRankAsc
--						,RANK() OVER (PARTITION BY job_id order by [Duration_Seconds]DESC)		AS ValueRankDesc
--						,StartDateTime	[Start]
--						,EndDateTime	[Stop]
--						,Duration_Seconds [Seconds]
--						,run_status
--						,message						 
--			FROM		(
--						SELECT		msdb.dbo.agent_datetime(run_date,run_time) AS StartDateTime
--									,DATEADD(s,DATEDIFF(s,msdb.dbo.agent_datetime(run_date,0),msdb.dbo.agent_datetime(run_date,run_duration)),msdb.dbo.agent_datetime(run_date,run_time)) AS EndDateTime
--									,DATEDIFF(s,msdb.dbo.agent_datetime(run_date,0),msdb.dbo.agent_datetime(run_date,run_duration)) AS Duration_Seconds
--									,*
--						from		msdb..sysjobhistory
--						where		step_id = 0 
--						) JobHistory
--			)
--			,FloatingAverage
--			AS
--			(
--			SELECT		[JobHistoryData].job_id
--						,[JobHistoryData].RowNumber
--						,AVG([JobHistoryData3].Seconds)				AS AVG_Value
--						,STDEVP([JobHistoryData3].Seconds)			AS STDEVP_Value
--			FROM		[JobHistoryData]
--			JOIN		(
--						SELECT		*
--						FROM		[JobHistoryData]
--						WHERE		ValueRankAsc	> OutlierRowCount
--								AND	ValueRankDesc	> OutlierRowCount
--						) [JobHistoryData3]
--					ON	[JobHistoryData].job_id	= [JobHistoryData3].job_id
--					AND ABS([JobHistoryData].RowNumber - [JobHistoryData3].RowNumber) < @FloatRange
--			GROUP BY	[JobHistoryData].job_id	
--						,[JobHistoryData].RowNumber
--			)
--			,Results
--			AS
--			(
--			SELECT		T1.job_id
--						,T1.instance_id	
--						,T1.RowNumber
--						,T1.Start
--						,T1.Stop
--						,T1.Seconds
--						,run_status
--						,CASE run_status 
--							WHEN 0 THEN 'Failure' 
--							WHEN 1 THEN 'Success' 
--							WHEN 2 THEN 'Retry' 
--							WHEN 3 THEN 'Cancelled' 
--							WHEN 4 THEN 'Running' 
--							ELSE 'Other: ' + 
--							Convert(VARCHAR,run_status) 
--						  END AS run_status_msg
--						,message				
--						,ABS(Seconds-AVG_Value)/isnull(nullif(STDEVP_Value,0),1)		AS DevsFromAvg
--						,CAST(ABS(Seconds-AVG_Value)/isnull(nullif(STDEVP_Value,0),1)/2 AS INT) AS TREND
--						,T2.AVG_Value
--						,T2.STDEVP_Value
--			FROM		[JobHistoryData] T1
--			JOIN		[FloatingAverage] T2
--					ON	T1.job_id = T2.job_id
--					AND T1.RowNumber = T2.RowNumber
--			)
--INSERT INTO @Results			
--SELECT		(SELECT name from msdb..sysjobs where job_id = R.job_id) JobName
--			,R.*
--			,S.schedule_id
--			,S.is_job_enabled
--			,S.is_schedule_enabled
--			,S.schedule_name
--			,S.Freq_type
--			,S.Description
--			,S.starttime
--			,S.endtime	
--FROM		Results R
--LEFT JOIN	JobSchedules S 
--		ON	R.job_id = S.job_id
--		AND R.message like '%The Job was invoked by Schedule '+CAST(S.schedule_id AS VarChar(20))+' ('+S.schedule_name+')%'
			


--;WITH		Schedules
--			AS
--			(
--			SELECT		schedule_id
--						,name
--						,enabled
--						,CASE freq_type
--								WHEN 1 THEN 'One Time'
--								WHEN 4 THEN CASE freq_subday_type 
--													WHEN 1 THEN 'Daily'
--													WHEN 2 THEN 'Second-ly'
--													WHEN 4 THEN 'Minutely'
--													WHEN 8 THEN 'Hourly'
--													ELSE ''
--													END
--								WHEN 8 THEN 'Weekly'
--								WHEN 16 THEN 'Monthly'
--								WHEN 32 THEN 'Monthly, relative to freq_interval'
--								WHEN 64 THEN 'Runs when the SQL Server Agent service starts'
--								WHEN 128 THEN 'Runs when the computer is idle'
--								END AS [Freq_Type]
								
--						,CASE freq_type
--								WHEN 1	THEN 'one time at ' + CONVERT(VarChar(100), msdb.dbo.agent_datetime(active_start_date,active_start_time),120)
--								WHEN 8	THEN 'every ' + CAST(freq_recurrence_factor AS varchar(10)) + ' week(s) '	/* (weekly) */				
--								WHEN 16	THEN 'every ' + CAST(freq_recurrence_factor AS varchar(10)) + ' month(s) '	/* (monthly) */				
--								WHEN 32	THEN 'every ' + CAST(freq_recurrence_factor AS varchar(10)) + ' week(s) '	/* (monthly relative) */	
--								ELSE ''
--								END AS freq_recurrence_factor
																
--						, CASE freq_type
--								WHEN 4	THEN 'every ' + CAST(freq_interval AS varchar(10)) + ' day(s) '				/* (daily) */
--								WHEN 8	THEN REPLACE	(															/* (weekly) */	
--														  CASE WHEN freq_interval&1 = 1		THEN 'Sunday, '		ELSE '' END
--														+ CASE WHEN freq_interval&2 = 2		THEN 'Monday, '		ELSE '' END
--														+ CASE WHEN freq_interval&4 = 4		THEN 'Tuesday, '	ELSE '' END
--														+ CASE WHEN freq_interval&8 = 8		THEN 'Wednesday, '	ELSE '' END
--														+ CASE WHEN freq_interval&16 = 16	THEN 'Thursday, '	ELSE '' END
--														+ CASE WHEN freq_interval&32 = 32	THEN 'Friday, '		ELSE '' END
--														+ CASE WHEN freq_interval&64 = 64	THEN 'Saturday, '	ELSE '' END
--														+ '|'
--														, ', |'
--														, ' ') /* get rid of trailing comma */
--								WHEN 16	THEN 'on day ' + CAST(freq_interval AS varchar(10)) + ' of every month '	/* (monthly) */
--								WHEN 32 THEN 'Every ' + CASE freq_interval											/* (day of week) */
--															WHEN 1 THEN 'Sunday'
--															WHEN 2 THEN 'Monday'
--															WHEN 3 THEN 'Tuesday'
--															WHEN 4 THEN 'Wednesday'
--															WHEN 5 THEN 'Thursday'
--															WHEN 6 THEN 'Friday'
--															WHEN 7 THEN 'Saturday'
--															WHEN 8 THEN 'Day'
--															WHEN 9 THEN 'Weekday'
--															WHEN 10 THEN 'Weekend day'
--															END
--								ELSE ''
--								END AS [freq_interval]
								
--						,CASE freq_subday_type
--								WHEN 1 THEN 'at ' +  CONVERT(VarChar(100), msdb.dbo.agent_datetime(active_start_date,active_start_time),108)
--								WHEN 2 THEN ', every ' + CAST(freq_subday_interval AS varchar(10)) + ' second(s)'
--								WHEN 4 THEN ', every ' + CAST(freq_subday_interval AS varchar(10)) + ' minute(s)'
--								WHEN 8 THEN ', every ' + CAST(freq_subday_interval AS varchar(10)) + ' hour(s)'
--								ELSE ''
--								END
--						+ CASE
--								WHEN	freq_subday_type in (2,4,8) /* repeat seconds/mins/hours */
--								THEN	', between '  + CONVERT(VarChar(100), msdb.dbo.agent_datetime(active_start_date,active_start_time),108)
--										+ ' and ' + CONVERT(VarChar(100), msdb.dbo.agent_datetime(active_end_date,active_end_time),108)
--								ELSE	''
--								END AS [freq_subday_type]



--						,CONVERT(VarChar(100), msdb.dbo.agent_datetime(active_start_date,active_start_time),120)	AS starttime
--						,CONVERT(VarChar(100), msdb.dbo.agent_datetime(active_end_date,active_end_time),120)		AS endtime
--			FROM		msdb.dbo.sysschedules
--			)
--			,JobSchedules
--			AS
--			(
--			SELECT		SJ.job_id
--						,SS.schedule_id
--						,SJ.enabled		AS is_job_enabled
--						,SS.enabled		AS is_schedule_enabled
--						,SS.name		AS schedule_name
--						,SS.Freq_type
--						,'Occurs ' +SS.freq_recurrence_factor+SS.freq_interval+SS.freq_subday_type AS Description
--						,SS.starttime
--						,SS.endtime			
--			FROM		msdb.dbo.sysjobs SJ
--			JOIN		msdb.dbo.sysjobschedules SJS
--					ON	SJ.job_id = SJS.job_id
--			JOIN		Schedules SS
--					ON	SJS.schedule_id = SS.schedule_id
--			)
--			,JobSchedSummaries
--			AS
--			(
--			SELECT		DISTINCT
--						job_id
--						,(REPLACE	(
--								STUFF	(
--										(
--										SELECT		'|' + schedule_name +' -- (' + Freq_type	+ ') -- "' + Description +'" ' + CONVERT(VarChar(50),starttime,101) + ' - ' + CONVERT(VarChar(50),endtime,101)
--										FROM		JobSchedules S2 
--										WHERE		S1.job_id = S2.job_id	
--										ORDER BY	1
--										FOR XML PATH(''), TYPE, ROOT
--										).value('root[1]','nvarchar(max)')
--										,1
--										,1
--										,''
--										)
--									,'|'
--									,CHAR(13)+CHAR(10)
--									)	
--								) as Descriptions
--			FROM		JobSchedules S1
--			)			
--SELECT		jh.JobName
--			,(	SELECT Name 
--				From sys.syslogins 
--				WHERE sid = (	SELECT owner_sid 
--								FROM msdb..sysjobs 
--								WHERE job_id = jh.job_id
--							)
--				)														AS [Owner Name]
--			,AVG(AVG_Value)												AS [Weighted Average Run Duration]
--			,AVG(Seconds)												AS [Average Run Duration]
--			,AVG(DevsFromAvg)											AS [AVGDevs]
--			,COUNT(CASE WHEN [Start] >= GetDate()-1 THEN 1 END)			AS [Executions Per Day]
--			,COUNT(CASE WHEN [Start] >= GetDate()-1 
--							AND [Trend] >= 20 THEN 1 END)				AS [Outliers Per Day]
--			,Count(*)													AS [Executions]
--			,max([Start])												AS [LastRun]
			
--			,COUNT(CASE run_status WHEN 0 THEN 1 END)					AS [Failures]	
--			,MAX(CASE run_status WHEN 0 THEN [Start] END)				AS [LastFailed]					
--			,COUNT(CASE WHEN [Start] >= GetDate()-1 
--							AND [run_status]= 0 THEN 1 END)				AS [Failures Per Day]
--			,MIN(CASE WHEN jh.[RowNumber] = LR.[RowNumber] 
--					THEN [run_status_msg] END)								AS [Final Status]
--			,COUNT(CASE WHEN jh.[RowNumber] > LF.[RowNumber] 
--					THEN 1 END)											AS [Executions Since LastFailed]	
--			,MAX(LF.[instance_id])
--			,(SELECT MAX(T1.[instance_id]) 
--					FROM	@Results T1
--					WHERE	T1.Job_id = jh.Job_id
--					AND		T1.[run_status] = 1
--					AND		T1.[RowNumber] < max(LF.[RowNumber]))

--			,MAX(LF.[RowNumber])
--				-(SELECT MAX(T1.[RowNumber]) 
--					FROM	@Results T1
--					WHERE	T1.Job_id = jh.Job_id
--					AND		T1.[run_status] = 1
--					AND		T1.[RowNumber] < max(LF.[RowNumber]))		AS [Last FailedInaRow]
--			,MAX(S.Descriptions) [Schedules]
--FROM		@Results jh
--LEFT JOIN	JobSchedSummaries S 
--		ON	S.job_id = jh.job_id
--LEFT JOIN	(SELECT job_id,max([RowNumber])[RowNumber],max([instance_id])[instance_id] FROM @Results GROUP BY job_id) LR
--		ON	LR.job_id = jh.job_id
--LEFT JOIN	(SELECT job_id,max([RowNumber])[RowNumber],max([instance_id])[instance_id] FROM @Results WHERE [run_status]= 0 GROUP BY job_id) LF
--		ON	LF.job_id = jh.job_id		
--GROUP BY	JobName
--			,jh.job_id
--ORDER BY	[Executions] DESC

--			(SELECT job_id,max([RowNumber])[RowNumber] FROM @Results WHERE [run_status]= 0 GROUP BY job_id) LF
			

--SELECT		(SELECT name from msdb..sysjobs where job_id = R.job_id) JobName
--			,*
--FROM		msdb..sysjobhistory R
--WHERE		instance_id > 11500181 
--		AND instance_id <= 11500520 
--AND			job_id = '8BE893CA-2D47-4718-A153-9C2879E0B1AB'


			
--SELECT			MIN(msdb.dbo.agent_datetime(run_date,run_time)) AS StartDateTime
--			MAX(DATEADD(s,DATEDIFF(s,msdb.dbo.agent_datetime(run_date,0),msdb.dbo.agent_datetime(run_date,run_duration)),msdb.dbo.agent_datetime(run_date,run_time))) AS EndDateTime 
--from		msdb..sysjobhistory 
--WHERE		[run_status] = 0
						
			
			
			
			
			
			
			
			
			
			
			
	































INSERT INTO	@LogList
exec		sp_enumerrorlogs

-- FIX DATES IN LOGLIST TO PST Time Zone
UPDATE		@LogList
		SET	EventDate = DATEADD(hour,@DateAdjust*(-1),[EventDate])

DELETE		@LogList
WHERE		EventDate < @DateStart

--SELECT * FROM @LogList

-- READ IN LOGS
WHILE EXISTS (SELECT * FROM @LogList)
BEGIN
	SELECT		TOP 1
				@ActiveLog = ArchiveNumber
	FROM		@LogList
	ORDER BY	ArchiveNumber

	INSERT INTO	@ErrorLog(EventDate,ProcessInfo,[Text])
	exec		sp_readerrorlog @ActiveLog
	
	UPDATE		@ErrorLog SET LogNumber = @ActiveLog WHERE LogNumber IS NULL

	DELETE		@LogList
	WHERE		ArchiveNumber = @ActiveLog
END

-- FIX DATES IN LOG TO PST Time Zone
UPDATE		@ErrorLog
		SET	EventDate = DATEADD(hour,@DateAdjust*(-1),[EventDate])


;WITH		ErrorLog
			AS
			(
			SELECT		Row_Number() OVER(PARTITION BY [ProcessInfo] ORDER BY EventDate) RowNumber
						,DATEDIFF(minute,[EventDate],DATEADD(hour,@DateAdjust*(-1),getdate())) MinFromNow
						,CASE WHEN [TEXT] LIKE 'Error%Severity%State%' THEN CAST(REPLACE(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE([Text],',','|'),1),'Error: ','') AS INT) END					AS [Error]
						,CASE WHEN [TEXT] LIKE 'Error%Severity%State%' THEN CAST(REPLACE(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE([Text],',','|'),2),' Severity: ','') AS INT) END				AS [Severity]
						,CASE WHEN [TEXT] LIKE 'Error%Severity%State%' THEN CAST(REPLACE(REPLACE(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE([Text],',','|'),3),' State: ',''),'.','') AS INT) END	AS [State]
						,CASE WHEN [TEXT] LIKE 'Login failed for user%CLIENT%' THEN dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE([Text],'Login failed for user ''',''),'''. [CLIENT: ','|'),']',''),1) END AS [User]
						,CASE WHEN [TEXT] LIKE 'Login failed for user%CLIENT%' THEN dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE([Text],'Login failed for user ''',''),'''. [CLIENT: ','|'),']',''),2) END AS [Client]
						,CASE
							WHEN LEFT(ProcessInfo,4) IN ('Serv','spid') THEN CASE
																				WHEN TEXT LIKE 'I/O%' THEN 'I\O'
																				END
							END AS [ServerEvent]
								
						,LEFT(STUFF([TEXT],1,CHARINDEX('user ''',[Text])+6,''),CHARINDEX('''.',[Text],CHARINDEX('user ''',[Text])+6)) AS [text1]
						,*
			FROM		@ErrorLog
			WHERE		EventDate BETWEEN @DateStart AND @DateStop
			)
SELECT		T1.EventDate
			,CASE T1.Error
				WHEN 18456	THEN CASE T1.[State]
									WHEN 1	THEN 'SQL Server is not ready to accept new client connections.'
									WHEN 2  THEN 'User ID is not valid.'
									WHEN 5  THEN 'User ID is not valid.'
									WHEN 6  THEN 'An attempt was made to use a Windows login name with SQL Server Authentication.'
									WHEN 7  THEN 'Login is disabled, and the password is incorrect.'
									WHEN 8  THEN 'The password is incorrect.'
									WHEN 9  THEN 'Password is not valid.'
									WHEN 11 THEN 'Login is valid, but server access failed.'
									WHEN 12 THEN 'Login is valid login, but server access failed.'
									--WHEN 16 THEN ''
									WHEN 18 THEN 'Password must be changed.'
									ELSE 'Error signifies an unexpected internal processing error.' 
									END
				WHEN 18470	THEN 'The account is disabled.'
				WHEN 17187	THEN 'SQL Server is not ready to accept new client connections.'
				--WHEN 701
									 
				END AS [ErrorMessage]
			,CASE WHEN Error IS NOT NULL THEN (SELECT Text FROM ErrorLog WHERE ProcessInfo = T1.ProcessInfo AND RowNumber = T1.RowNumber+1) END AS [ErrorDetails]
			,*
			
FROM		ErrorLog T1
WHERE		T1.Error IS NOT NULL
ORDER BY	T1.EventDate DESC


--SELECT		EventDate
--			,CASE
--				WHEN Text Like 'SQL Server is starting%' THEN 'SQL Starting'
--				WHEN Text Like 'SQL Server is now ready for client connections%' THEN 'SQL Ready'
--				END AS [ServerEvent]
--FROM		@ErrorLog
--WHERE		ProcessInfo = 'Server'
--		AND	(
--			Text Like 'SQL Server is starting%'
--		OR	Text Like 'SQL Server is now ready for client connections%'
--			)
--ORDER BY	EventDate

--SELECT		*
--FROM		@ErrorLog
--WHERE		(
--			ProcessInfo = 'Server'
--		OR	ProcessInfo Like 'spid%'
--			)
--		AND	Text Not Like 'I/O%'
--ORDER BY	EventDate



--SELECT * FROM @ErrorLog	WHERE EventDate Between  '2012-06-08 08:00:00.000' AND  '2012-06-08 09:00:00.000'
--ORDER BY	EventDate

--SELECT		TOP 1000
--			*
--FROM		@ErrorLog
--ORDER BY	EventDate DESC
