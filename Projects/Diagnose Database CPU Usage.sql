
;WITH		DB_CPU_Stats
			AS
			(
			SELECT		DatabaseID
						,DB_Name(DatabaseID) AS [DatabaseName]
						,SUM(total_worker_time) AS [CPU_Time_Ms]
			FROM		sys.dm_exec_query_stats AS qs
			CROSS APPLY	(
						SELECT		CONVERT(int, value) AS [DatabaseID] 
						FROM		sys.dm_exec_plan_attributes(qs.plan_handle)
						WHERE		attribute = N'dbid'
						) AS F_DB
			GROUP BY	DatabaseID
			)
			,DB_CPU_Totals
			AS
			(
			SELECT		DatabaseName [Database Name]
						,ROW_NUMBER() OVER(ORDER BY [CPU_Time_Ms] DESC) AS [CPU Rank]
						,[CPU_Time_Ms] [CPU Time Ms]
						,CAST([CPU_Time_Ms] * 1.0 / SUM([CPU_Time_Ms]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPU %]
			FROM		DB_CPU_Stats
			)
			,Aggregate_IO_Statistics
			AS
			(
			SELECT		DB_NAME(database_id) AS [Database Name]
						,CAST(SUM(num_of_bytes_read + num_of_bytes_written)/1048576 AS DECIMAL(12, 2)) AS io_in_mb
			FROM		sys.dm_io_virtual_file_stats(NULL, NULL) AS [DM_IO_STATS]
			GROUP BY	database_id
			)
			,DB_IO_Totals
			AS
			(
			SELECT		[Database Name]
						,ROW_NUMBER() OVER(ORDER BY io_in_mb DESC) AS [I/O Rank]
						,io_in_mb AS [Total I/O (MB)]
						,CAST(io_in_mb/ SUM(io_in_mb) OVER() * 100.0 AS DECIMAL(5,2)) AS [I/O %]
			FROM		Aggregate_IO_Statistics
			)
			,DB_Buffer_Totals
			AS
			(
			SELECT		DB_NAME(database_id) AS [Database Name]
						,ROW_NUMBER() OVER(ORDER BY CAST(COUNT(*) * 8/1024.0 AS DECIMAL (10,2)) DESC) AS [Cache Rank]
						,CAST(COUNT(*) * 8/1024.0 AS DECIMAL (10,2))  AS [Cached Size (MB)]
			FROM		sys.dm_os_buffer_descriptors WITH (NOLOCK)
			GROUP BY	DB_NAME(database_id)
			)			
SELECT		T1.[Database Name]
			,T1.[CPU Rank]
			,T1.[CPU Time Ms]
			,T1.[CPU %]
			,T2.[I/O Rank]
			,T2.[Total I/O (MB)]
			,T2.[I/O %]
			,T3.[Cache Rank]
			,T3.[Cached Size (MB)]
FROM		DB_IO_Totals T2
LEFT JOIN	DB_CPU_Totals T1
		ON	T2.[Database Name] = T1.[Database Name]
LEFT JOIN	DB_Buffer_Totals T3
		ON	T3.[Database Name] = T1.[Database Name]
ORDER BY	T1.[Database Name]
OPTION (RECOMPILE);

GO

-- Get CPU Utilization History for last 256 minutes (in one minute intervals)  (Query 27) (CPU Utilization History)
-- This version works with SQL Server 2008 and SQL Server 2008 R2 only
DECLARE @ts_now bigint 
SELECT @ts_now = (SELECT cpu_ticks/(cpu_ticks/ms_ticks)FROM sys.dm_os_sys_info); 

SELECT TOP(256) SQLProcessUtilization AS [SQL Server Process CPU Utilization], 
               SystemIdle AS [System Idle Process], 
               100 - SystemIdle - SQLProcessUtilization AS [Other Process CPU Utilization], 
               DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS [Event Time] 
FROM ( 
	  SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') 
			AS [SystemIdle], 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 
			'int') 
			AS [SQLProcessUtilization], [timestamp] 
	  FROM ( 
			SELECT [timestamp], CONVERT(xml, record) AS [record] 
			FROM sys.dm_os_ring_buffers WITH (NOLOCK)
			WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
			AND record LIKE N'%<SystemHealth>%') AS x 
	  ) AS y 
ORDER BY record_id DESC OPTION (RECOMPILE);

GO

