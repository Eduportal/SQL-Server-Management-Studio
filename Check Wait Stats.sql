WITH [Waits] AS
    (SELECT
        [wait_type],
        [wait_time_ms] / 1000.0 AS [WaitS],
        ([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
        [signal_wait_time_ms] / 1000.0 AS [SignalS],
        [waiting_tasks_count] AS [WaitCount],
        100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
        ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]
    FROM sys.dm_os_wait_stats
    WHERE [wait_type] NOT IN (
        N'CLR_SEMAPHORE',    N'LAZYWRITER_SLEEP',
        N'RESOURCE_QUEUE',   N'SQLTRACE_BUFFER_FLUSH',
        N'SLEEP_TASK',       N'SLEEP_SYSTEMTASK',
        N'WAITFOR',          N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
        N'CHECKPOINT_QUEUE', N'REQUEST_FOR_DEADLOCK_SEARCH',
        N'XE_TIMER_EVENT',   N'XE_DISPATCHER_JOIN',
        N'LOGMGR_QUEUE',     N'FT_IFTS_SCHEDULER_IDLE_WAIT',
        N'BROKER_TASK_STOP', N'CLR_MANUAL_EVENT',
        N'CLR_AUTO_EVENT',   N'DISPATCHER_QUEUE_SEMAPHORE',
        N'TRACEWRITE',       N'XE_DISPATCHER_WAIT',
        N'BROKER_TO_FLUSH',  N'BROKER_EVENTHANDLER',
        N'FT_IFTSHC_MUTEX',  N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        N'DIRTY_PAGE_POLL',  N'SP_SERVER_DIAGNOSTICS_SLEEP')
    )
SELECT
    [W1].[wait_type] AS [WaitType],
    CAST ([W1].[WaitS] AS DECIMAL(14, 2)) AS [Wait_S],
    CAST ([W1].[ResourceS] AS DECIMAL(14, 2)) AS [Resource_S],
    CAST ([W1].[SignalS] AS DECIMAL(14, 2)) AS [Signal_S],
    [W1].[WaitCount] AS [WaitCount],
    CAST ([W1].[Percentage] AS DECIMAL(4, 2)) AS [Percentage],
    CAST (([W1].[WaitS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgWait_S],
    CAST (([W1].[ResourceS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgRes_S],
    CAST (([W1].[SignalS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgSig_S]
FROM [Waits] AS [W1]
INNER JOIN [Waits] AS [W2]
    ON [W2].[RowNum] <= [W1].[RowNum]
GROUP BY [W1].[RowNum], [W1].[wait_type], [W1].[WaitS],
    [W1].[ResourceS], [W1].[SignalS], [W1].[WaitCount], [W1].[Percentage]
HAVING SUM ([W2].[Percentage]) - [W1].[Percentage] < 95; -- percentage threshold
GO

SELECT
    [owt].[session_id],
    [owt].[exec_context_id],
    [owt].[wait_duration_ms],
    [owt].[wait_type],
    [owt].[blocking_session_id],
    [owt].[resource_description],
    CASE [owt].[wait_type]
        WHEN N'CXPACKET' THEN
            RIGHT ([owt].[resource_description],
            CHARINDEX (N'=', REVERSE ([owt].[resource_description])) - 1)
        ELSE NULL
    END AS [Node ID],
    [es].[program_name],
    [est].text,
    [er].[database_id],
    [eqp].[query_plan],
    [er].[cpu_time]
FROM sys.dm_os_waiting_tasks [owt]
INNER JOIN sys.dm_exec_sessions [es] ON
    [owt].[session_id] = [es].[session_id]
INNER JOIN sys.dm_exec_requests [er] ON
    [es].[session_id] = [er].[session_id]
OUTER APPLY sys.dm_exec_sql_text ([er].[sql_handle]) [est]
OUTER APPLY sys.dm_exec_query_plan ([er].[plan_handle]) [eqp]
WHERE
    [es].[is_user_process] = 1
ORDER BY
    [owt].[session_id],
    [owt].[exec_context_id];
GO



IF EXISTS (SELECT * FROM [tempdb].[sys].[objects]
	WHERE [name] = N'##TempSpinlockStats1')
	DROP TABLE [##TempSpinlockStats1];

IF EXISTS (SELECT * FROM [tempdb].[sys].[objects]
	WHERE [name] = N'##TempSpinlockStats2')
	DROP TABLE [##TempSpinlockStats2];
GO

-- Baseline
SELECT * INTO [##TempSpinlockStats1]
FROM sys.dm_os_spinlock_stats
WHERE [collisions] > 0
ORDER BY [name];
GO

---- Now do something
--DBCC CHECKDB (N'SalesDB') WITH NO_INFOMSGS;
--GO
USE [Getty_Images_US_Inc__MSCRM]
GO
DECLARE @NOW DATETIME = GETDATE()
DECLARE @StartDate DATETIME = DATEADD(DAY, -14, CONVERT(DATETIME, CONVERT(CHAR(10), GETDATE(), 120)));

SELECT soeb.*
INTO #SOEB
FROM dbo.SalesOrderExtensionBase soeb (NOLOCK)
WHERE EXISTS
       (SELECT 1
       FROM dbo.SalesOrderBase sob (NOLOCK)
       WHERE sob.SalesOrderId = soeb.SalesOrderId
       AND sob.ModifiedOn >= @StartDate)
ORDER BY soeb.SalesOrderId;

DROP TABLE #SOEB

PRINT DATEDIFF(ms,@Now,GetDate())

GO 10

-- Capture updated stats
SELECT * INTO [##TempSpinlockStats2]
FROM sys.dm_os_spinlock_stats
WHERE [collisions] > 0
ORDER BY [name];
GO

-- Diff them
SELECT
    '***' AS [New],
    [ts2].[name] AS [Spinlock],
    [ts2].[collisions] AS [DiffCollisions],
    [ts2].[spins] AS [DiffSpins],
    [ts2].[spins_per_collision] AS [SpinsPerCollision],
    [ts2].[sleep_time] AS [DiffSleepTime],
    [ts2].[backoffs] AS [DiffBackoffs]
FROM [##TempSpinlockStats2] [ts2]
LEFT OUTER JOIN [##TempSpinlockStats1] [ts1]
    ON [ts2].[name] = [ts1].[name]
WHERE [ts1].[name] IS NULL
UNION
SELECT
    '' AS [New],
    [ts2].[name] AS [Spinlock],
    [ts2].[collisions] - [ts1].[collisions] AS [DiffCollisions],
    [ts2].[spins] - [ts1].[spins] AS [DiffSpins],
    CASE ([ts2].[spins] - [ts1].[spins]) WHEN 0 THEN 0
        ELSE ([ts2].[spins] - [ts1].[spins]) /
            ([ts2].[collisions] - [ts1].[collisions]) END
            AS [SpinsPerCollision],
    [ts2].[sleep_time] - [ts1].[sleep_time] AS [DiffSleepTime],
    [ts2].[backoffs] - [ts1].[backoffs] AS [DiffBackoffs]
FROM [##TempSpinlockStats2] [ts2]
LEFT OUTER JOIN [##TempSpinlockStats1] [ts1]
    ON [ts2].[name] = [ts1].[name]
WHERE [ts1].[name] IS NOT NULL
    AND [ts2].[collisions] - [ts1].[collisions] > 0
ORDER BY [New] DESC, [Spinlock] ASC;
GO

xp_cmdshell 'ping -l 65000 SEAPSQLLSHP01'



--Following query shows the number of pending I/Os that are waiting to be completed for the entire SQL Server instance:
SELECT SUM(pending_disk_io_count) AS [Number of pending I/Os] FROM sys.dm_os_schedulers 

--Following query gives details about the stalled I/O count reported by the first query.
SELECT *  FROM sys.dm_io_pending_io_requests

--Following query shows the splitup of stalled I/O per each database files in the SQL Server instance. The values are cumulative since SQL Server started. You can use sample_ms  column output to compare the output between two instances of the output and find which file is the cause of the stalled I/O. (sample_ms is the number of milliseconds since the computer was started)
SELECT		DB_NAME(database_id) AS [Database]
		,[file_id]
		, [io_stall_read_ms]
		,[io_stall_write_ms]
		,[io_stall] 
FROM		sys.dm_io_virtual_file_stats(NULL,NULL) 


select wait_type, waiting_tasks_count, wait_time_ms, signal_wait_time_ms, wait_time_ms / waiting_tasks_count
from sys.dm_os_wait_stats  
where wait_type like 'PAGEIOLATCH%'  and waiting_tasks_count > 0
order by wait_type


select 
    database_id, 
    file_id, 
    io_stall,
    io_pending_ms_ticks,
    scheduler_address 
from  sys.dm_io_virtual_file_stats(NULL, NULL)t1,
        sys.dm_io_pending_io_requests as t2
where t1.file_handle = t2.io_handle


select top 15 (total_logical_reads/execution_count) as avg_logical_reads,
                   (total_logical_writes/execution_count) as avg_logical_writes,
           (total_physical_reads/execution_count) as avg_physical_reads,
           Execution_count, statement_start_offset, p.query_plan, q.text
from sys.dm_exec_query_stats
      cross apply sys.dm_exec_query_plan(plan_handle) p
      cross apply sys.dm_exec_sql_text(plan_handle) as q
order by (total_logical_reads + total_logical_writes)/execution_count Desc

select top 15 (total_logical_reads/execution_count) as avg_logical_reads,
                   (total_logical_writes/execution_count) as avg_logical_writes,
           (total_physical_reads/execution_count) as avg_physical_reads,
           Execution_count, statement_start_offset, p.query_plan, q.text
from sys.dm_exec_query_stats
      cross apply sys.dm_exec_query_plan(plan_handle) p
      cross apply sys.dm_exec_sql_text(plan_handle) as q
order by (total_logical_reads + total_logical_writes) Desc

select top 15 
    (total_logical_reads/execution_count) as avg_logical_reads,
    (total_logical_writes/execution_count) as avg_logical_writes,
    (total_physical_reads/execution_count) as avg_phys_reads,
     Execution_count, 
    statement_start_offset as stmt_start_offset, 
    sql_handle, 
    plan_handle
from sys.dm_exec_query_stats  
order by  (total_logical_reads + total_logical_writes) Desc

