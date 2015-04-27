

select wait_type, waiting_tasks_count, wait_time_ms, signal_wait_time_ms, wait_time_ms / waiting_tasks_count
from sys.dm_os_wait_stats  
where wait_type like 'PAGEIOLATCH%'  and waiting_tasks_count > 0
order by wait_type



SELECT TOP 1000 
a2.name AS [tablename], (a1.reserved + ISNULL(a4.reserved,0))* 8 AS reserved, 
a1.rows as row_count, a1.data * 8 AS data, 
(CASE WHEN (a1.used + ISNULL(a4.used,0)) > a1.data THEN (a1.used + ISNULL(a4.used,0)) - a1.data ELSE 0 END) * 8 AS index_size, 
(CASE WHEN (a1.reserved + ISNULL(a4.reserved,0)) > a1.used THEN (a1.reserved + ISNULL(a4.reserved,0)) - a1.used ELSE 0 END) * 8 AS unused, 
(row_number() over(order by (a1.reserved + ISNULL(a4.reserved,0)) desc))%2 as l1, 
a3.name AS [schemaname] 
FROM (SELECT ps.object_id, SUM (CASE WHEN (ps.index_id < 2) THEN row_count ELSE 0 END) AS [rows], 
SUM (ps.reserved_page_count) AS reserved, 
SUM (CASE WHEN (ps.index_id < 2) THEN (ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count) 
ELSE (ps.lob_used_page_count + ps.row_overflow_used_page_count) END ) AS data, 
SUM (ps.used_page_count) AS used 
FROM sys.dm_db_partition_stats ps 
GROUP BY ps.object_id) AS a1 
LEFT OUTER JOIN (SELECT it.parent_id, 
SUM(ps.reserved_page_count) AS reserved, 
SUM(ps.used_page_count) AS used 
FROM sys.dm_db_partition_stats ps 
INNER JOIN sys.internal_tables it ON (it.object_id = ps.object_id) 
WHERE it.internal_type IN (202,204) 
GROUP BY it.parent_id) AS a4 ON (a4.parent_id = a1.object_id) 
INNER JOIN sys.all_objects a2  ON ( a1.object_id = a2.object_id ) 
INNER JOIN sys.schemas a3 ON (a2.schema_id = a3.schema_id) 
WHERE a2.type <> N'S' and a2.type <> N'IT'  




	-- Do not lock anything, and do not get held up by any locks. 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	
	-- Identify queries running slower than normal.
	SELECT TOP 100
	[Runs] = qs.execution_count 
	--, [Total time] = qs.total_worker_time - qs.last_worker_time 
	, [Avg time] = (qs.total_worker_time - qs.last_worker_time) / ISNULL(NULLIF(qs.execution_count-1,0),1) 
	, [Last time] = qs.last_worker_time 
	, [Time Deviation] = (qs.last_worker_time - ((qs.total_worker_time - qs.last_worker_time) / ISNULL(NULLIF(qs.execution_count-1,0),1)))
	, [% Time Deviation] = CASE 
							WHEN qs.last_worker_time = 0 THEN 100
							ELSE	(
									qs.last_worker_time -	(
															(qs.total_worker_time - qs.last_worker_time) / ISNULL(NULLIF(qs.execution_count-1,0),1) 
															)
									) * 100 
							END 
						/	ISNULL(NULLIF((
								(
								ISNULL(NULLIF(qs.total_worker_time - qs.last_worker_time,0),1) 
								/	ISNULL(NULLIF(qs.execution_count-1,0),1)
								)
							),0),1)
	, [Last IO] = last_logical_reads + last_logical_writes + last_physical_reads
	, [Avg IO] = ((total_logical_reads + total_logical_writes + total_physical_reads) 
				- (last_logical_reads + last_logical_writes + last_physical_reads)) 
					/ ISNULL(NULLIF(qs.execution_count-1,0),1)
	, [Individual Query] = SUBSTRING (qt.text,qs.statement_start_offset/2, 
		 (CASE WHEN qs.statement_end_offset = -1 
			THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
		  ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)
	, [Parent Query] = qt.text
	, [DatabaseName] = DB_NAME(qt.dbid)
	INTO #SlowQueries
	FROM	(
			SELECT	*
			FROM	sys.dm_exec_query_stats qs
			WHERE	total_worker_time !=	last_worker_time	
				AND	total_worker_time !=	min_worker_time	
				AND	total_worker_time !=	max_worker_time
				AND	execution_count > 1
				AND last_worker_time > 0
				AND last_worker_time > min_worker_time
			) qs
	CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) qt
	WHERE qs.execution_count > 1
	ORDER BY [% Time Deviation] DESC

	-- Calculate the [IO Deviation] and [% IO Deviation].
	-- Negative values means we did less I/O than average.
	SELECT TOP 100 [Runs]
		, [Avg time]
		, [Last time]
		, [Time Deviation]
		, [% Time Deviation]
		, [Last IO]
		, [Avg IO]
		, [IO Deviation] = [Last IO] - [Avg IO]
		, [% IO Deviation] = 
				CASE WHEN [Avg IO] = 0
						THEN 0
					 ELSE ([Last IO]- [Avg IO]) * 100 / [Avg IO]
				END 
		, [Individual Query]
		, [Parent Query]
		, [DatabaseName]
	INTO #SlowQueriesByIO
	FROM #SlowQueries
	ORDER BY [% Time Deviation] DESC

	-- Extract items where [% Time deviation] less [% IO deviation] is 'large' 
	-- These queries are slow running, even when we take into account IO deviation.
	SELECT TOP 100 [Runs] 
		, [Avg time]
		, [Last time]
		, [Time Deviation]
		, [% Time Deviation]
		, [Last IO]
		, [Avg IO]
		, [IO Deviation] 
		, [% IO Deviation] 
		, [Impedance] = [% Time Deviation] - [% IO Deviation]
		, [Individual Query]
		, [Parent Query]
		, [DatabaseName]
	FROM #SlowQueriesByIO
	WHERE [% Time Deviation] - [% IO Deviation]  > 20
	ORDER BY [Impedance] DESC

	-- Tidy up.
	DROP TABLE #SlowQueries
	DROP TABLE #SlowQueriesByIO
	
	





