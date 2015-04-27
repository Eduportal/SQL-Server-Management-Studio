DBCC FREEPROCCACHE
GO
DBCC DROPCLEANBUFFERS
GO
USE [dbaperf]
GO
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


USE [dbaperf]
GO

IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[dbo].[dbasp_Populate_DMV_CPU_Utilization]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[dbasp_Populate_DMV_CPU_Utilization]
GO

CREATE PROCEDURE dbo.dbasp_Populate_DMV_CPU_Utilization
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER ON

IF OBJECT_ID('DMV_CPU_Utilization') IS NULL
BEGIN
	EXEC ('
	CREATE TABLE [dbo].[DMV_CPU_Utilization](
		[DateTimeValue] [datetime] NOT NULL,
		[SQLProcessUtilization] [int] NULL,
		[OtherProcessUtilization] [int] NULL,
		[SystemIdle] [int] NULL
	)
	')

	EXEC ('
	CREATE UNIQUE CLUSTERED INDEX	[IX_DMV_CPU_Utilization] ON [dbo].[DMV_CPU_Utilization]
					(
					[DateTimeValue] ASC
					)
	')
END
	
INSERT INTO	dbaperf.dbo.DMV_CPU_Utilization
SELECT		CAST(CONVERT(VARCHAR(16),DATEADD(ms, -1 * ((SELECT  cpu_ticks / CONVERT(FLOAT, cpu_ticks_in_ms) FROM sys.dm_os_sys_info) - [timestamp]), GETDATE()),120)AS DATETIME) AS EventTime
		,SQLProcessUtilization
		,100 - SystemIdle - SQLProcessUtilization AS OtherProcessUtilization
		,SystemIdle
FROM		(
		SELECT		record.value('(./Record/@id)[1]', 'int') AS record_id,
				record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS SystemIdle,
				record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS SQLProcessUtilization,
				TIMESTAMP
		FROM		(
				SELECT	TIMESTAMP
					,CONVERT(XML, record) AS record 
				FROM	sys.dm_os_ring_buffers 
				WHERE	ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
					AND	record LIKE '% %'
				) AS x
		) AS y 

exec sp_monitor
GO



USE [dbaperf]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[dbo].[dbasp_Populate_DMV_PerfmonCounters]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[dbasp_Populate_DMV_PerfmonCounters]
GO

CREATE PROCEDURE dbo.dbasp_Populate_DMV_PerfmonCounters
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER ON

IF OBJECT_ID('DMV_PerfmonCounters') IS NULL
BEGIN

	EXEC ('
	CREATE TABLE	DMV_PerfmonCounters
			(
			[rundate]		[datetime]	NOT NULL,
			[object_name]		[nvarchar](128)	NOT NULL,
			[counter_name]		[nvarchar](128)	NOT NULL,
			[instance_name]		[nvarchar](128)	NULL,
			[cntr_value]		[bigint]	NOT NULL,
			[cntr_type]		[int]		NOT NULL,
			[seconds_between]	[bigint]	NULL,
			[calculated_value]	[float]		NULL
			)
	')


	CREATE CLUSTERED INDEX	[IX_DMV_PerfmonCounters_c_11_1403932869__K2_K3_K4_K1] 
			ON	[dbo].[DMV_PerfmonCounters]
				(
				[object_name] ASC,
				[counter_name] ASC,
				[instance_name] ASC,
				[rundate] ASC
				)

	CREATE STATISTICS	[_dta_stat_1403932869_2_3_4_1] 
			ON	[dbo].[DMV_PerfmonCounters]
				(
				[object_name], 
				[counter_name], 
				[instance_name], 
				[rundate]
				)

END

DECLARE		@RunDate	DateTime
SET		@RunDate	= GetDate()

;WITH		Metrics ([object_name],[counter_name])
		AS
		(
		SELECT 'SQLServer:General Statistics' 	,'User Connections' 		UNION ALL
		SELECT 'SQLServer:General Statistics'	,'Logical Connections'		UNION ALL
		SELECT 'SQLServer:General Statistics'	,'Active Temp Tables'		UNION ALL
		SELECT 'SQLServer:General Statistics'	,'Logins/sec'			UNION ALL
		SELECT 'SQLServer:General Statistics'	,'Logouts/sec'			UNION ALL
		SELECT 'SQLServer:General Statistics'	,'Temp Tables Creation Rate'	UNION ALL
		SELECT 'SQLServer:General Statistics'	,'Processes blocked'		UNION ALL

		SELECT 'SQLServer:Buffer Manager'	,'Page life expectancy'		UNION ALL
		SELECT 'SQLServer:Buffer Manager'	,'Total pages'			UNION ALL
		SELECT 'SQLServer:Buffer Manager'	,'Database Pages'		UNION ALL

		SELECT 'SQLServer:Buffer Node'		,'Page life expectancy'		UNION ALL
		SELECT 'SQLServer:Buffer Node'		,'Total pages'			UNION ALL
		SELECT 'SQLServer:Buffer Node'		,'Database Pages'		UNION ALL

		SELECT 'SQLServer:Memory Manager'	,'Memory Grants Pending'	UNION ALL

		SELECT 'SQLServer:SQL Statistics'	,'Batch Requests/sec'		UNION ALL
		SELECT 'SQLServer:SQL Statistics'	,'Forced Parameterizations/sec'	UNION ALL
		SELECT 'SQLServer:SQL Statistics'	,'Auto-Param Attempts/sec'	UNION ALL
		SELECT 'SQLServer:SQL Statistics'	,'Failed Auto-Params/sec'	UNION ALL
		SELECT 'SQLServer:SQL Statistics'	,'Safe Auto-Params/sec'		UNION ALL
		SELECT 'SQLServer:SQL Statistics'	,'Unsafe Auto-Params/sec'	UNION ALL
		SELECT 'SQLServer:SQL Statistics'	,'SQL Compilations/sec'		UNION ALL
		SELECT 'SQLServer:SQL Statistics'	,'SQL Re-Compilations/sec'	UNION ALL
		SELECT 'SQLServer:SQL Statistics'	,'SQL Attention rate'		UNION ALL

		SELECT 'SQLServer:SQL Errors'		,'Errors/sec'			UNION ALL

		SELECT 'SQLServer:CLR'			,'CLR Execution'		UNION ALL

		SELECT 'SQLServer:Resource Pool Stats'	,''				UNION ALL

		SELECT 'SQLServer:Access Methods'	,'Full Scans/sec'		UNION ALL
		SELECT 'SQLServer:Access Methods'	,'Range Scans/sec'		UNION ALL
		SELECT 'SQLServer:Access Methods'	,'Page Splits/sec'		UNION ALL
		SELECT 'SQLServer:Access Methods'	,'Table Lock Escalations/sec'	UNION ALL

		SELECT NULL,NULL
		)
		,LastValues
		AS
		(
		SELECT		ROW_NUMBER() OVER(PARTITION BY [object_name],[counter_name],[instance_name] ORDER BY [rundate] DESC) RowNumber
				,*
		FROM		dbo.DMV_PerfmonCounters
		)

INSERT INTO	dbo.DMV_PerfmonCounters
select		@RunDate
		,LTRIM(RTRIM(T1.object_name)) [object_name]
		,LTRIM(RTRIM(T1.counter_name)) [counter_name]
		,LTRIM(RTRIM(T1.instance_name)) [instance_name]
		,T1.cntr_value	
		,T1.cntr_type
		,CASE T1.cntr_type WHEN 272696576 THEN datediff(second,T3.rundate,@RunDate) END 
		,CASE T1.cntr_type 
			WHEN 65792	THEN T1.cntr_value 
			WHEN 272696576	THEN (T1.cntr_value - T3.cntr_value)/CAST(datediff(second,T3.rundate,@RunDate) AS FLOAT)
			ELSE NULL END
from		sys.dm_os_performance_counters T1
JOIN		Metrics T2
	ON	CAST(T1.[object_name]  AS VarChar(100))	= CAST(CASE @@SERVICENAME WHEN 'MSSQLSERVER' THEN T2.[object_name] ELSE REPLACE(T2.[object_name],'SQLServer:','MSSQL$'+@@SERVICENAME+':') END AS VarChar(100))
	AND	CAST(T1.[counter_name] AS VarChar(100))	= CAST(T2.[counter_name] AS VarChar(100))
LEFT JOIN	LastValues T3
	ON	T3.RowNumber				= 1
	AND	LTRIM(RTRIM(T1.[object_name]))		= LTRIM(RTRIM(T3.[object_name]))
	AND	LTRIM(RTRIM(T1.[counter_name]))		= LTRIM(RTRIM(T3.[counter_name]))
	AND	LTRIM(RTRIM(T1.[instance_name]))	= LTRIM(RTRIM(T3.[instance_name]))

UNION ALL

SELECT		@RunDate
		,CASE	WHEN program_name LIKE 'SQLAgent - TSQL JobStep%' 
			THEN 'Active Agent Job'
			ELSE 'sys.sysprocesses:ActiveSPIDs' END
		,CASE	WHEN program_name LIKE 'SQLAgent - TSQL JobStep%' 
			THEN j.[name]
			ELSE program_name END
		,CASE	WHEN program_name LIKE 'SQLAgent - TSQL JobStep%' 
			THEN 'Step ' + CAST(js.[step_id] AS VarChar(10)) + ': ' + js.[step_name] 
			ELSE p.loginame END
		,COUNT(p.spid) as ActiveConnections
		,65792
		,NULL
		,COUNT(p.spid) --select *
FROM		sys.sysprocesses P
LEFT JOIN	msdb.dbo.sysjobs j 
	on	master.dbo.fn_varbintohexstr(j.job_id) = [dbaadmin].[dbo].[dbaudf_ReturnPart] (REPLACE(REPLACE(REPLACE(p.program_name,'(Job ','|'),' : Step ','|'),')','|'),2)
LEFT JOIN	msdb.dbo.sysjobsteps js 
	on	j.job_id = js.job_id 
	and	js.step_id = [dbaadmin].[dbo].[dbaudf_ReturnPart] (REPLACE(REPLACE(REPLACE(p.program_name,'(Job ','|'),' : Step ','|'),')','|'),3)
WHERE		dbid > 0
	AND	spid != @@SPID
	AND	status NOT IN ('sleeping','background') 
	AND	cmd NOT IN ('AWAITING COMMAND','LAZY WRITER','CHECKPOINT SLEEP')
GROUP BY	CASE	WHEN program_name LIKE 'SQLAgent - TSQL JobStep%' 
			THEN 'Active Agent Job'
			ELSE 'sys.sysprocesses:ActiveSPIDs' END
		,CASE	WHEN program_name LIKE 'SQLAgent - TSQL JobStep%' 
			THEN j.[name]
			ELSE program_name END
		,CASE	WHEN program_name LIKE 'SQLAgent - TSQL JobStep%' 
			THEN 'Step ' + CAST(js.[step_id] AS VarChar(10)) + ': ' + js.[step_name] 
			ELSE p.loginame END

DELETE dbaperf.dbo.DMV_PerfmonCounters
WHERE	rundate IN	(
			SELECT		rundate
			FROM		dbaperf.dbo.DMV_PerfmonCounters WITH(NOLOCK)
			WHERE		object_name NOT IN ('sys.sysprocesses:ActiveSPIDs','Active Agent Job')
				AND	COALESCE(calculated_value,-1) < 0
			)

GO

SET QUOTED_IDENTIFIER ON
EXEC	dbaperf.dbo.dbasp_Populate_DMV_CPU_Utilization
EXEC	dbaperf.dbo.dbasp_Populate_DMV_PerfmonCounters



GO
SELECT		*
FROM		dbaperf.dbo.DMV_CPU_Utilization

SELECT		*
FROM		dbaperf.dbo.DMV_PerfmonCounters WITH(NOLOCK)
WHERE		[counter_name] = 'CLR Execution'
order by 1 desc

--WHERE		object_name NOT IN ('sys.sysprocesses:ActiveSPIDs','Active Agent Job')
--	AND	calculated_value < 0


--DELETE dbaperf.dbo.DMV_PerfmonCounters
--WHERE	rundate IN	(
--			SELECT		rundate
--			FROM		dbaperf.dbo.DMV_PerfmonCounters WITH(NOLOCK)
--			WHERE		object_name NOT IN ('sys.sysprocesses:ActiveSPIDs','Active Agent Job')
--				AND	COALESCE(calculated_value,-1) < 0
--			)

--UPDATE dbaperf.dbo.DMV_PerfmonCounters
--SET	[object_name]		= LTRIM(RTRIM([object_name]))
--	,[counter_name]		= LTRIM(RTRIM([counter_name]))
--	,[instance_name]	= LTRIM(RTRIM([instance_name]))


;WITH		Perfmon
		AS
		(
		SELECT		*
				,ROW_NUMBER() OVER(PARTITION BY [object_name],[counter_name],[instance_name] ORDER BY [rundate]) RowNumber
		FROM		dbaperf.dbo.DMV_PerfmonCounters WITH(NOLOCK)
		WHERE		[counter_name] = 'CLR Execution'
		)
UPDATE		T1
	SET	calculated_value = CASE WHEN T2.cntr_value IS NULL THEN 0 WHEN T2.cntr_value > T1.cntr_value THEN 0 ELSE (T1.cntr_value - T2.cntr_value)/CAST(datediff(second,T2.rundate,T1.rundate) AS FLOAT) END
FROM		Perfmon T1
LEFT JOIN	Perfmon T2
	ON	T1.RowNumber = T2.RowNumber + 1




UPDATE		dbaperf.dbo.DMV_PerfmonCounters
	SET	calculated_value = cntr_value
WHERE		[counter_name] = 'CLR Execution'


SELECT * FROM sys.dm_os_performance_counters T1



;with		PD
		as
		(
		SELECT		*
		FROM		dbaperf.dbo.DMV_PerfmonCounters WITH(NOLOCK)
		WHERE		counter_name IN ('Page life expectancy','Database Pages')
		)


SELECT		T1.rundate
		,T1.[object_name]
		,T1.[instance_name]
		,((((T2.cntr_value*8)/1024.0)/1024.0)/4)*300
		,T1.cntr_value
		,T2.cntr_value
FROM		PD T1
JOIN		PD T2
	ON	T1.[object_name] = T2.[object_name]
	AND	T1.[instance_name] = T2.[instance_name]
	AND	T1.rundate = T2.rundate
	AND	T1.counter_name = 'Page life expectancy'
	AND	T2.counter_name = 'Database Pages'


	
