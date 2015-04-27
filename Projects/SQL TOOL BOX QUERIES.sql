
 SET NOCOUNT ON
 DECLARE @XML XML

 DECLARE	@Results		TABLE
			(
			[Source]			SYSNAME NULL
			,[Rn]				INT NULL
			,[Property]			SYSNAME NULL
			,[Value]			VarChar(max) NULL
			)


---- Windows information (SQL Server 2008 R2 SP1 or greater)  (Query 5) (Windows Info)
---- Gives you major OS version, Service Pack, Edition, and language info for the operating system
--SELECT		@XML = (
--		SELECT		*
--		FROM		(
--					SELECT		*, 1 [Rn]
--					FROM		sys.dm_os_windows_info WITH (NOLOCK)
--					) Row 
--					FOR
--						XML AUTO,
--							ROOT('Root') ,
--							ELEMENTS XSINIL
--							)
--							OPTION (RECOMPILE)
--INSERT INTO	@Results
--SELECT		'dm_os_windows_info' AS [Source],*
--FROM		dbaadmin.dbo.dbaudf_PivotData(@XML)



---- SQL Server Services information (SQL Server 2008 R2 SP1 or greater)  (Query 6) (SQL Server Services Info)
---- Tells you the account being used for the SQL Server Service and the SQL Agent Service
---- Shows when they were last started, and their current status
---- Shows whether you are running on a failover cluster
--SELECT		@XML = (
--		SELECT		*
--		FROM		(
--					SELECT		*, 1 [Rn]
--					FROM		sys.dm_server_services WITH (NOLOCK) 
--					) Row 
--					FOR
--						XML AUTO,
--							ROOT('Root') ,
--							ELEMENTS XSINIL
--							)
--							OPTION (RECOMPILE)
--INSERT INTO	@Results
--SELECT		'dm_server_services' AS [Source],*
--FROM		dbaadmin.dbo.dbaudf_PivotData(@XML)



-- Hardware information from SQL Server 2008 and 2008 R2  (Query 8) (Hardware Info)
-- (Cannot distinguish between HT and multi-core)
-- Gives you some good basic hardware information about your database server
--SELECT		@XML = (
--		SELECT		*
--		FROM		(
--					SELECT		*, 1 [Rn]
--					FROM		sys.dm_os_sys_info WITH (NOLOCK) 
--					) Row 
--					FOR
--						XML AUTO,
--							ROOT('Root') ,
--							ELEMENTS XSINIL
--							)
--							OPTION (RECOMPILE)
--INSERT INTO	@Results
--SELECT		'dm_os_sys_info' AS [Source],*
--FROM		dbaadmin.dbo.dbaudf_PivotData(@XML)


-- SQL Server NUMA Node information  (Query 7) (SQL Server NUMA Info)
-- Gives you some useful information about the composition 
-- and relative load on your NUMA nodes
--SELECT		@XML = (
--		SELECT		*
--		FROM		(
--					SELECT		node_id	
--								,node_state_desc	
--								,memory_node_id	
--								,cpu_affinity_mask	
--								,online_scheduler_count	
--								,idle_scheduler_count	
--								,active_worker_count	
--								,avg_load_balance	
--								,timer_task_affinity_mask	
--								,permanent_task_affinity_mask	
--								,resource_monitor_state	
--								,online_scheduler_mask	
--								,processor_group	
--								,ROW_NUMBER() OVER(ORDER BY node_id) [Rn]
--					FROM		sys.dm_os_nodes WITH (NOLOCK) 
--					) Row 
--					FOR
--						XML AUTO,
--							ROOT('Root') ,
--							ELEMENTS XSINIL
--							)
--							OPTION (RECOMPILE)
--INSERT INTO	@Results
--SELECT		'dm_os_nodes' AS [Source],*
--FROM		dbaadmin.dbo.dbaudf_PivotData(@XML)


-- Get the current node name from your cluster nodes  (Query 11) (Current Cluster Node)
-- (if your database server is in a cluster)
-- Knowing which node owns the cluster resources is critical
-- Especially when you are installing Windows or SQL Server updates
-- You will see no results if your instance is not clustered
--SELECT		@XML = (
--		SELECT		*
--		FROM		(
--					SELECT		*,ROW_NUMBER() OVER(ORDER BY NodeName) [Rn]
--					FROM		sys.dm_os_cluster_nodes WITH (NOLOCK) 
--					) Row 
--					FOR
--						XML AUTO,
--							ROOT('Root') ,
--							ELEMENTS XSINIL
--							)
--							OPTION (RECOMPILE)
--INSERT INTO	@Results
--SELECT		'dm_os_cluster_nodes' AS [Source],*
--FROM		dbaadmin.dbo.dbaudf_PivotData(@XML)





-- Get processor description from Windows Registry  (Query 10) (Processor Description)
-- Gives you the model number and rated clock speed of your processor(s)
-- Your processors may be running at less that the rated clock speed due
-- to the Windows Power Plan or hardware power management
INSERT INTO @Results (Property,Value)
EXEC xp_instance_regread 
'HKEY_LOCAL_MACHINE', 'HARDWARE\DESCRIPTION\System\CentralProcessor\0',
'ProcessorNameString';


-- Get configuration values for instance  (Query 12) (Configuration Values)
-- Focus on
-- backup compression default
-- clr enabled (only enable if it is needed)
-- lightweight pooling (should be zero)
-- max degree of parallelism (depends on your workload)
-- max server memory (MB) (set to an appropriate value)
-- optimize for ad hoc workloads (should be 1)
-- priority boost (should be zero)
INSERT INTO @Results 
SELECT		'sys.configurations'
			,ROW_NUMBER() OVER(ORDER BY name)
			,name
			,CAST(value AS VarChar(max)) + CASE WHEN value != value_in_use THEN ' (' + CAST(value_in_use AS VarChar(max)) + ')' ELSE '' END
FROM		sys.configurations WITH (NOLOCK)
ORDER BY	name OPTION (RECOMPILE);






SELECT		*
FROM		@Results

UNION ALL


-- This gives you a lot of useful information about your instance of SQL Server
SELECT		1 [Order],'Server Name' [Property],	CAST(@@SERVERNAME AS VarChar(max)) [Value]
UNION ALL
SELECT		4,'SQL Server and OS Version Info',	CAST(@@VERSION AS VarChar(max))									
UNION ALL
SELECT		3,'MachineName',			CAST(SERVERPROPERTY('MachineName') AS VarChar(max))									
UNION ALL
SELECT		1,'ServerName',				CAST(SERVERPROPERTY('ServerName') AS VarChar(max))									
UNION ALL
SELECT		2,'Instance',				CAST(SERVERPROPERTY('InstanceName') AS VarChar(max))									
UNION ALL
SELECT		4,'IsClustered',			CAST(SERVERPROPERTY('IsClustered') AS VarChar(max))								
UNION ALL
SELECT		3,'ComputerNamePhysicalNetBIOS',	CAST(SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS VarChar(max))	
UNION ALL
SELECT		4,'Edition',				CAST(SERVERPROPERTY('Edition') AS VarChar(max))											
UNION ALL
SELECT		4,'ProductLevel',			CAST(SERVERPROPERTY('ProductLevel') AS VarChar(max))								
UNION ALL
SELECT		4,'ProductVersion',			CAST(SERVERPROPERTY('ProductVersion') AS VarChar(max))							
UNION ALL
SELECT		5,'ProcessID',				CAST(SERVERPROPERTY('ProcessID') AS VarChar(max))										
UNION ALL
SELECT		6,'Collation',				CAST(SERVERPROPERTY('Collation') AS VarChar(max))										
UNION ALL
SELECT		7,'IsFullTextInstalled',		CAST(SERVERPROPERTY('IsFullTextInstalled') AS VarChar(max))					
UNION ALL
SELECT		8,'IsIntegratedSecurityOnly',		CAST(SERVERPROPERTY('IsIntegratedSecurityOnly') AS VarChar(max))		
UNION ALL
SELECT		9,'SQL Server Install Date',		CAST(createdate AS VarChar(max)) 
FROM		sys.syslogins WITH (NOLOCK) 
WHERE		[sid] = 0x010100000000000512000000  

ORDER BY 1,2


-- Returns a list of all global trace flags that are enabled (Query 4) (Global Trace Flags)
DBCC TRACESTATUS (-1);

-- If no global trace flags are enabled, no results will be returned.
-- It is very useful to know what global trace flags are currently enabled
-- as part of the diagnostic process.




-- Get System Manufacturer and model number from  (Query 9) (System Manufacturer)
-- SQL Server Error log. This query might take a few seconds 
-- if you have not recycled your error log recently
EXEC xp_readerrorlog 0,1,"Manufacturer"; 

-- This can help you determine the capabilities
-- and capacities of your database server

--EXEC xp_readerrorlog 0,1,"error"; 
--EXEC xp_readerrorlog 0,1,"failure"; 
--EXEC xp_readerrorlog 0,1,"failed"; 
--EXEC xp_readerrorlog 0,1,"unable"; 




---- Get information on location, time and size of any memory dumps from SQL Server (SQL Server 2008 R2 SP1 or greater)  (Query 13) (Memory Dump Info)
IF @@VERSION LIKE 'Microsoft SQL Server 2008%' OR @@VERSION LIKE 'Microsoft SQL Server 2012%'
SELECT [filename], creation_time, size_in_bytes
FROM sys.dm_server_memory_dumps WITH (NOLOCK) OPTION (RECOMPILE);

-- This will not return any rows if you have 
-- not had any memory dumps (which is a good thing)




-- TempDB Usage
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
SELECT		session_id 
			,command 
			,host_name 
			,statement_text
			,User_Obj_UsedSpace-User_Obj_FreeSpace [UnreleasedUserObjSpace]
			,Int_Obj_UsedSpace-Int_Obj_FreeSpace [UnreleasedIntObjSpace]
			,User_Obj_UsedSpace 
			,User_Obj_FreeSpace 
			,Int_Obj_UsedSpace 
			,Int_Obj_FreeSpace
FROM		(
			select		ts.session_id
						,ex.command 
						,ses.host_name
						,SUBSTRING(st.text, (ex.statement_start_offset/2)+1, 
						((CASE ex.statement_end_offset
						WHEN -1 THEN DATALENGTH(st.text)
						ELSE ex.statement_end_offset
						END - ex.statement_start_offset)/2) + 1) AS statement_text
						,sum(ts.user_objects_alloc_page_count)*8 as 'User_Obj_UsedSpace'
						,sum(ts.user_objects_dealloc_page_count)*8 as 'User_Obj_FreeSpace'
						,sum(ts.internal_objects_alloc_page_count)*8 as 'Int_Obj_UsedSpace'
						,sum(ts.internal_objects_dealloc_page_count)*8 as 'Int_Obj_FreeSpace'
			from		sys.dm_exec_requests as ex
			join		sys.dm_db_task_space_usage as ts 
				on		ex.session_id = ts.session_id 
			join		sys.dm_exec_sessions as ses 
				on		ex.session_id = ses.session_id
			outer apply	sys.dm_exec_sql_text(ex.sql_handle)as st
			group by	ts.session_id
						,ex.command 
						,st.text 
						,ex.statement_start_offset
						,ex.statement_end_offset
						,ses.host_name
			) TempDBUsage
ORDER BY		5 desc
			,6 desc




-- File Names and Paths for TempDB and all user databases in instance  (Query 14) (Database Filenames and Paths)
-- Things to look at:
-- Are data files and log files on different drives?
-- Is everything on the C: drive?
-- Is TempDB on dedicated drives?
-- Is there only one TempDB data file?
-- Are all of the TempDB data files the same size?
-- Are there multiple data files for user databases?


-- Volume info for all databases on the current instance (SQL Server 2008 R2 SP1 or greater)  (Query 15) (Volume Info)
SELECT		LD.DriveLetter
			,CAST(LD.TotalSize/POWER(1024.,3) AS NUMERIC(10,2))				[TotalSize_GB]
			,CAST(LD.AvailableSpace/POWER(1024.,3) AS NUMERIC(10,2))		[AvailableSpace_GB]
			,CAST(DBDriveData.Size AS NUMERIC(10,2))						[UsedDB_GB]
			,CAST((LD.TotalSize/POWER(1024.,3))
				-(DBDriveData.Size)
				-(LD.AvailableSpace/POWER(1024.,3)) AS NUMERIC(10,2))		[UsedNonDB_GB]
			,CAST((LD.AvailableSpace*100.0)/LD.TotalSize AS NUMERIC(10,2))	[% Free]	
			,LD.DriveType	
			,LD.FileSystem	
			,LD.IsReady	
			,LD.VolumeName
			,DBDriveData.[DBNames]

FROM		dbaadmin.dbo.dbaudf_ListDrives() LD
JOIN		(
			SELECT		[DriveLetter]
						,SUM([Size]) [Size]
						,REPLACE(dbaadmin.[dbo].[dbaudf_ConcatenateUnique]([DB_Name]+':'+Type_desc+'('+ CAST(CAST([Size] AS NUMERIC(10,2)) AS VarChar(50)) + ')'),'.00)',')') [DBNames]
			FROM		(
						SELECT		UPPER(LEFT(physical_name,1)) [DriveLetter]
									,DB_NAME(database_id) [DB_Name]
									,Type_desc
									,SUM(size/128./1024.) [Size]

						FROM		sys.master_files AS f WITH (NOLOCK)
						GROUP BY	LEFT(physical_name,1)
									,DB_NAME(database_id)
									,Type_desc
						) Data
			GROUP BY	[DriveLetter]
			
			) DBDriveData
	ON		DBDriveData.DriveLetter = LD.DriveLetter
OPTION (RECOMPILE);
--Shows you the free space on the LUNs where you have database data or log files


SELECT		LD.*
		,Data.[DB_Name]
		,Data.[Type_desc]
		,Data.[Size]
FROM		dbaadmin.dbo.dbaudf_ListDrives() LD
JOIN		(
		SELECT		UPPER(LEFT(physical_name,1)) [DriveLetter]
					,DB_NAME(database_id) [DB_Name]
					,Type_desc
					,SUM(size/128./1024.) [Size]
		FROM		sys.master_files AS f WITH (NOLOCK)
		GROUP BY	LEFT(physical_name,1)
					,DB_NAME(database_id)
					,Type_desc
		) Data
	ON	Data.DriveLetter = LD.DriveLetter



-- Recovery model, log reuse wait description, log file size, log usage size  (Query 16) (Database Properties)
-- and compatibility level for all databases on instance
SELECT db.[name] AS [Database Name], db.recovery_model_desc AS [Recovery Model], 
db.log_reuse_wait_desc AS [Log Reuse Wait Description], 
ls.cntr_value AS [Log Size (KB)], lu.cntr_value AS [Log Used (KB)],
CAST(CAST(lu.cntr_value AS FLOAT) / CAST(ls.cntr_value AS FLOAT)AS DECIMAL(18,2)) * 100 AS [Log Used %], 
db.[compatibility_level] AS [DB Compatibility Level], 
db.page_verify_option_desc AS [Page Verify Option], db.is_auto_create_stats_on, db.is_auto_update_stats_on,
db.is_auto_update_stats_async_on, db.is_parameterization_forced, 
db.snapshot_isolation_state_desc, db.is_read_committed_snapshot_on,
db.is_auto_close_on, db.is_auto_shrink_on, db.is_cdc_enabled
FROM sys.databases AS db WITH (NOLOCK)
INNER JOIN sys.dm_os_performance_counters AS lu WITH (NOLOCK)
ON db.name = lu.instance_name
INNER JOIN sys.dm_os_performance_counters AS ls WITH (NOLOCK) 
ON db.name = ls.instance_name
WHERE lu.counter_name LIKE N'Log File(s) Used Size (KB)%' 
AND ls.counter_name LIKE N'Log File(s) Size (KB)%'
AND ls.cntr_value > 0 OPTION (RECOMPILE);




-- Things to look at:
-- How many databases are on the instance?
-- What recovery models are they using?
-- What is the log reuse wait description?
-- How full are the transaction logs ?
-- What compatibility level are they on?
-- What is the Page Verify Option?
-- Make sure auto_shrink and auto_close are not enabled!



-- Missing Indexes for all databases by Index Advantage  (Query 17) (Missing Indexes All Databases)
SELECT		CONVERT(decimal(18,2),user_seeks * avg_total_user_cost * (avg_user_impact * 0.01)) AS [index_advantage]
			,DB_NAME(mid.database_id) AS [Database Name]
			,OBJECT_NAME(mid.object_id,mid.database_id) AS [Table Name]
			, mid.[statement] AS [Database.Schema.Table]
			,migs.last_user_seek
			,mid.equality_columns
			,mid.inequality_columns
			,mid.included_columns
			,migs.unique_compiles
			,migs.user_seeks
			,migs.avg_total_user_cost
			,migs.avg_user_impact
			--,p.rows AS [Table Rows]

FROM		sys.dm_db_missing_index_group_stats AS migs WITH (NOLOCK)
JOIN		sys.dm_db_missing_index_groups AS mig WITH (NOLOCK)
	ON		migs.group_handle = mig.index_group_handle
JOIN		sys.dm_db_missing_index_details AS mid WITH (NOLOCK)
	ON		mig.index_handle = mid.index_handle
--JOIN		sys.partitions AS p WITH (NOLOCK)
--	ON		p.object_id = mid.object_id
--WHERE		mid.database_id = DB_ID() -- Remove this to see for entire instance
ORDER BY	index_advantage DESC OPTION (RECOMPILE);

-- Getting missing index information for all of the databases on the instance is very useful
-- Look at last user seek time, number of user seeks to help determine source and importance
-- SQL Server is overly eager to add included columns, so beware
-- Do not just blindly add indexes that show up from this query!!!



-- Get VLF Counts for all databases on the instance (Query 18) (VLF Counts)
-- (adapted from Michelle Ufford) 
CREATE TABLE #VLFInfo (FileID  int,
					   FileSize bigint, StartOffset bigint,
					   FSeqNo      bigint, [Status]    bigint,
					   Parity      bigint, CreateLSN   numeric(38));
	 
CREATE TABLE #VLFCountResults(DatabaseName sysname, VLFCount int);
	 
EXEC sp_MSforeachdb N'Use [?]; 

				INSERT INTO #VLFInfo 
				EXEC sp_executesql N''DBCC LOGINFO([?])''; 
	 
				INSERT INTO #VLFCountResults 
				SELECT DB_NAME(), COUNT(*) 
				FROM #VLFInfo; 

				TRUNCATE TABLE #VLFInfo;'
	 
SELECT DatabaseName, VLFCount  
FROM #VLFCountResults
ORDER BY VLFCount DESC;
	 
DROP TABLE #VLFInfo;
DROP TABLE #VLFCountResults;

-- High VLF counts can affect write performance 
-- and they can make database restores and recovery take much longer



-- Calculates average stalls per read, per write, and per total input/output for each database file  (Query 19) (IO Stalls by File)
SELECT DB_NAME(fs.database_id) AS [Database Name], mf.physical_name, io_stall_read_ms, num_of_reads,
CAST(io_stall_read_ms/(1.0 + num_of_reads) AS NUMERIC(10,1)) AS [avg_read_stall_ms],io_stall_write_ms, 
num_of_writes,CAST(io_stall_write_ms/(1.0+num_of_writes) AS NUMERIC(10,1)) AS [avg_write_stall_ms],
io_stall_read_ms + io_stall_write_ms AS [io_stalls], num_of_reads + num_of_writes AS [total_io],
CAST((io_stall_read_ms + io_stall_write_ms)/(1.0 + num_of_reads + num_of_writes) AS NUMERIC(10,1)) 
AS [avg_io_stall_ms]
FROM sys.dm_io_virtual_file_stats(null,null) AS fs
INNER JOIN sys.master_files AS mf WITH (NOLOCK)
ON fs.database_id = mf.database_id
AND fs.[file_id] = mf.[file_id]
ORDER BY avg_io_stall_ms DESC OPTION (RECOMPILE);
-- Helps you determine which database files on the entire instance have the most I/O bottlenecks
-- This can help you decide whether certain LUNs are overloaded and whether you might
-- want to move some files to a different location



SELECT SUM(pending_disk_io_count) AS [Number of pending I/Os] FROM sys.dm_os_schedulers 

--Following query gives details about the stalled I/O count reported by the first query.

SELECT *  FROM sys.dm_io_pending_io_requests

SELECT DB_NAME(database_id) AS [Database]
			,[file_id]
			,[io_stall_read_ms]
			,[io_stall_write_ms]
			,[io_stall] 
FROM sys.dm_io_virtual_file_stats(NULL,NULL) 


Select  wait_type,  
        waiting_tasks_count,  
        wait_time_ms 
from    sys.dm_os_wait_stats   
where    wait_type like 'PAGEIOLATCH%'   
order by wait_type 


select  
    database_id,  
    file_id,  
    io_stall, 
    io_pending_ms_ticks, 
    scheduler_address  
from    sys.dm_io_virtual_file_stats(NULL, NULL)t1, 
        sys.dm_io_pending_io_requests as t2 
where    t1.file_handle = t2.io_handle

SELECT  CAST(SUM(io_stall_read_ms + io_stall_write_ms) /
             SUM(1.0 + num_of_reads + num_of_writes) AS NUMERIC(10, 1)
        ) AS [avg_io_stall_ms]
FROM    sys.dm_io_virtual_file_stats(DB_ID(), NULL)
WHERE   FILE_ID <> 2;



select top 20  
    (total_logical_reads/execution_count) as avg_logical_reads, 
    (total_logical_writes/execution_count) as avg_logical_writes, 
    (total_physical_reads/execution_count) as avg_phys_reads, 
     Execution_count,  
    statement_start_offset as stmt_start_offset,  
    sql_handle,  
    plan_handle 
	,T2.*
from sys.dm_exec_query_stats T1
CROSS APPLY   sys.dm_exec_query_plan(T1.plan_handle) T2
WHERE T2.Query_Plan IS NOT NULL
order by  
 (total_logical_reads + total_logical_writes) Desc


 

-- SHOW CUMULATIVE WAIT STATS
GO
--DBCC SQLPERF (N'sys.dm_os_wait_stats', CLEAR);
--GO

;WITH [Waits] AS
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


-- numa nodes and schedulers
select node_id, online_scheduler_count
from sys.dm_os_nodes
order by node_id
go

-- see if anything is waiting on tempdb
select * 
from sys.dm_os_waiting_tasks
where resource_description like '2:%'
go

---- Get CPU utilization by database (adapted from Robert Pearl)  (Query 20) (CPU Usage by Database)
--WITH DB_CPU_Stats
--AS
--(SELECT DatabaseID, DB_Name(DatabaseID) AS [DatabaseName], SUM(total_worker_time) AS [CPU_Time_Ms]
-- FROM sys.dm_exec_query_stats AS qs
-- CROSS APPLY (SELECT CONVERT(int, value) AS [DatabaseID] 
--              FROM sys.dm_exec_plan_attributes(qs.plan_handle)
--              WHERE attribute = N'dbid') AS F_DB
-- GROUP BY DatabaseID)
--SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Time_Ms] DESC) AS [row_num],
--       DatabaseName, [CPU_Time_Ms], 
--       CAST([CPU_Time_Ms] * 1.0 / SUM([CPU_Time_Ms]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPUPercent]
--FROM DB_CPU_Stats
--WHERE DatabaseID > 0 -- system databases
--AND DatabaseID <> 32767 -- ResourceDB
--ORDER BY row_num OPTION (RECOMPILE);

---- Helps determine which database is using the most CPU resources on the instance


---- Get I/O utilization by database (Query 21) (IO Usage By Database)
WITH Aggregate_IO_Statistics
AS
(SELECT DB_NAME(database_id) AS [Database Name],
CAST(SUM(num_of_bytes_read + num_of_bytes_written)/1048576 AS DECIMAL(12, 2)) AS io_in_mb
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS [DM_IO_STATS]
GROUP BY database_id)
SELECT ROW_NUMBER() OVER(ORDER BY io_in_mb DESC) AS [I/O Rank], [Database Name], io_in_mb AS [Total I/O (MB)],
       CAST(io_in_mb/ SUM(io_in_mb) OVER() * 100.0 AS DECIMAL(5,2)) AS [I/O Percent]
FROM Aggregate_IO_Statistics
ORDER BY [I/O Rank] OPTION (RECOMPILE);

---- Helps determine which database is using the most I/O resources on the instance



---- Get total buffer usage by database for current instance  (Query 22) (Total Buffer Usage by Database)
---- This make take some time to run on a busy instance
--SELECT DB_NAME(database_id) AS [Database Name],
--CAST(COUNT(*) * 8/1024.0 AS DECIMAL (10,2))  AS [Cached Size (MB)]
--FROM sys.dm_os_buffer_descriptors WITH (NOLOCK)
--WHERE database_id > 4 -- system databases
--AND database_id <> 32767 -- ResourceDB
--GROUP BY DB_NAME(database_id)
--ORDER BY [Cached Size (MB)] DESC OPTION (RECOMPILE);

---- Tells you how much memory (in the buffer pool) 
---- is being used by each database on the instance




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



-- Clear Wait Stats 
-- DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);

-- Isolate top waits for server instance since last restart or statistics clear  (Query 23) (Top Waits)
WITH Waits AS
(SELECT wait_type, wait_time_ms / 1000. AS wait_time_s,
100. * wait_time_ms / SUM(wait_time_ms) OVER() AS pct,
ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS rn
FROM sys.dm_os_wait_stats WITH (NOLOCK)
WHERE wait_type NOT IN (N'CLR_SEMAPHORE',N'LAZYWRITER_SLEEP',N'RESOURCE_QUEUE',N'SLEEP_TASK',
N'SLEEP_SYSTEMTASK',N'SQLTRACE_BUFFER_FLUSH',N'WAITFOR', N'LOGMGR_QUEUE',N'CHECKPOINT_QUEUE',
N'REQUEST_FOR_DEADLOCK_SEARCH',N'XE_TIMER_EVENT',N'BROKER_TO_FLUSH',N'BROKER_TASK_STOP',N'CLR_MANUAL_EVENT',
N'CLR_AUTO_EVENT',N'DISPATCHER_QUEUE_SEMAPHORE', N'FT_IFTS_SCHEDULER_IDLE_WAIT',
N'XE_DISPATCHER_WAIT', N'XE_DISPATCHER_JOIN', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
N'ONDEMAND_TASK_QUEUE', N'BROKER_EVENTHANDLER', N'SLEEP_BPOOL_FLUSH'))
SELECT W1.wait_type, 
CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS wait_time_s,
CAST(W1.pct AS DECIMAL(12, 2)) AS pct,
CAST(SUM(W2.pct) AS DECIMAL(12, 2)) AS running_pct
FROM Waits AS W1
INNER JOIN Waits AS W2
ON W2.rn <= W1.rn
GROUP BY W1.rn, W1.wait_type, W1.wait_time_s, W1.pct
HAVING SUM(W2.pct) - W1.pct < 99 OPTION (RECOMPILE); -- percentage threshold


-- Common Significant Wait types with BOL explanations

-- *** Network Related Waits ***
-- ASYNC_NETWORK_IO		Occurs on network writes when the task is blocked behind the network

-- *** Locking Waits ***
-- LCK_M_IX				Occurs when a task is waiting to acquire an Intent Exclusive (IX) lock
-- LCK_M_IU				Occurs when a task is waiting to acquire an Intent Update (IU) lock
-- LCK_M_S				Occurs when a task is waiting to acquire a Shared lock

-- *** I/O Related Waits ***
-- ASYNC_IO_COMPLETION  Occurs when a task is waiting for I/Os to finish
-- IO_COMPLETION		Occurs while waiting for I/O operations to complete. 
--                      This wait type generally represents non-data page I/Os. Data page I/O completion waits appear 
--                      as PAGEIOLATCH_* waits
-- PAGEIOLATCH_SH		Occurs when a task is waiting on a latch for a buffer that is in an I/O request. 
--                      The latch request is in Shared mode. Long waits may indicate problems with the disk subsystem.
-- PAGEIOLATCH_EX		Occurs when a task is waiting on a latch for a buffer that is in an I/O request. 
--                      The latch request is in Exclusive mode. Long waits may indicate problems with the disk subsystem.
-- WRITELOG             Occurs while waiting for a log flush to complete. 
--                      Common operations that cause log flushes are checkpoints and transaction commits.
-- PAGELATCH_EX			Occurs when a task is waiting on a latch for a buffer that is not in an I/O request. 
--                      The latch request is in Exclusive mode.
-- BACKUPIO				Occurs when a backup task is waiting for data, or is waiting for a buffer in which to store data

-- *** CPU Related Waits ***
-- SOS_SCHEDULER_YIELD  Occurs when a task voluntarily yields the scheduler for other tasks to execute. 
--                      During this wait the task is waiting for its quantum to be renewed.

-- THREADPOOL			Occurs when a task is waiting for a worker to run on. 
--                      This can indicate that the maximum worker setting is too low, or that batch executions are taking 
--                      unusually long, thus reducing the number of workers available to satisfy other batches.
-- CX_PACKET			Occurs when trying to synchronize the query processor exchange iterator 
--						You may consider lowering the degree of parallelism if contention on this wait type becomes a problem
--						Often caused by missing indexes or poorly written queries




-- Signal Waits for instance  (Query 24) (Signal Waits)
SELECT		'Signal Waits (CPU)'
		,CAST(100.0 * SUM(signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [%signal (cpu) waits]
		,CAST(100.0 * SUM(wait_time_ms - signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [%resource waits]
FROM		sys.dm_os_wait_stats WITH (NOLOCK) OPTION (RECOMPILE);




-- Signal Waits above 10-15% is usually a sign of CPU pressure
-- Resource waits are non-CPU related waits
SELECT		'Signal Waits (CPU)' [Gague]
		,CAST(100.0 * SUM(signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [Value]
		,0 [LOW]
		,100 [High]
		,15 [Red_Start]
		,100 [Red_End]
		,10 [Yellow_Start]
		,15 [Yellow_End]
		,0 [Green_Start]
		,10 [Green_End]
		,cast(0 AS bit) [Reverse]
FROM		sys.dm_os_wait_stats WITH (NOLOCK)
UNION ALL
SELECT		'Resource Waits' [Gague]
		,CAST(100.0 * SUM(wait_time_ms - signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [Value]
		,0 [LOW]
		,100 [High]
		,85 [Red_Start]
		,0 [Red_End]
		,90 [Yellow_Start]
		,85 [Yellow_End]
		,100 [Green_Start]
		,90 [Green_End]
		,cast(1 as bit) [Reverse]
FROM		sys.dm_os_wait_stats WITH (NOLOCK) 





--  Get logins that are connected and how many sessions they have  (Query 25) (Connection Counts)
SELECT login_name, COUNT(session_id) AS [session_count] 
FROM sys.dm_exec_sessions WITH (NOLOCK)
WHERE session_id > 50	-- filter out system SPIDs
GROUP BY login_name
ORDER BY COUNT(session_id) DESC OPTION (RECOMPILE);

-- This can help characterize your workload and
-- determine whether you are seeing a normal level of activity


-- Get Average Task Counts (run multiple times)  (Query 26) (Avg Task Counts)
SELECT AVG(current_tasks_count) AS [Avg Task Count], 
AVG(runnable_tasks_count) AS [Avg Runnable Task Count],
AVG(pending_disk_io_count) AS [AvgPendingDiskIOCount]
FROM sys.dm_os_schedulers WITH (NOLOCK)
WHERE scheduler_id < 255 OPTION (RECOMPILE);

-- Sustained values above 10 suggest further investigation in that area
-- High current_tasks_count is often an indication of locking/blocking problems
-- High runnable_tasks_count is an indication of CPU pressure
-- High pending_disk_io_count is an indication of I/O pressure


-- Get CPU Utilization History for last 256 minutes (in one minute intervals)  (Query 27) (CPU Utilization History)
-- This version works with SQL Server 2008 and SQL Server 2008 R2 only
DECLARE @ts_now bigint = (SELECT cpu_ticks/(cpu_ticks/ms_ticks)FROM sys.dm_os_sys_info); 

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

-- Look at the trend over the entire period. 
-- Also look at high sustained Other Process CPU Utilization values


-- Good basic information about OS memory amounts and state  (Query 28) (System Memory)
SELECT total_physical_memory_kb/1024 AS [Physical Memory (MB)], 
       available_physical_memory_kb/1024 AS [Available Memory (MB)], 
       total_page_file_kb/1024 AS [Total Page File (MB)], 
	   available_page_file_kb/1024 AS [Available Page File (MB)], 
	   system_cache_kb/1024 AS [System Cache (MB)],
       system_memory_state_desc AS [System Memory State]
FROM sys.dm_os_sys_memory WITH (NOLOCK) OPTION (RECOMPILE);

-- You want to see "Available physical memory is high"
-- This indicates that you are not under external memory pressure


-- SQL Server Process Address space info  (Query 29) (Process Memory) 
--(shows whether locked pages is enabled, among other things)
SELECT physical_memory_in_use_kb/1024 AS [SQL Server Memory Usage (MB)],
       large_page_allocations_kb, locked_page_allocations_kb, page_fault_count, 
	   memory_utilization_percentage, available_commit_limit_kb, 
	   process_physical_memory_low, process_virtual_memory_low
FROM sys.dm_os_process_memory WITH (NOLOCK) OPTION (RECOMPILE);

-- You want to see 0 for process_physical_memory_low
-- You want to see 0 for process_virtual_memory_low
-- This indicates that you are not under internal memory pressure


-- Page Life Expectancy (PLE) value for each NUMA node in current instance  (Query 30) (PLE by NUMA Node)
SELECT @@SERVERNAME AS [Server Name], [object_name], instance_name, cntr_value AS [Page Life Expectancy]
FROM sys.dm_os_performance_counters WITH (NOLOCK)
WHERE [object_name] LIKE N'%Buffer Node%' -- Handles named instances
AND counter_name = N'Page life expectancy' OPTION (RECOMPILE);

-- PLE is a good measurement of memory pressure.
-- Higher PLE is better. Watch the trend, not the absolute value.
-- This will only return one row for non-NUMA systems.


-- Memory Grants Pending value for current instance  (Query 31) (Memory Grants Pending)
SELECT @@SERVERNAME AS [Server Name], [object_name], cntr_value AS [Memory Grants Pending]                                                                                                       
FROM sys.dm_os_performance_counters WITH (NOLOCK)
WHERE [object_name] LIKE N'%Memory Manager%' -- Handles named instances
AND counter_name = N'Memory Grants Pending' OPTION (RECOMPILE);

-- Memory Grants Pending above zero for a sustained period is a very strong indicator of memory pressure


-- Memory Clerk Usage for instance  (Query 32) (Memory Clerk Usage)
-- Look for high value for CACHESTORE_SQLCP (Ad-hoc query plans)
SELECT TOP(10) [type] AS [Memory Clerk Type], SUM(single_pages_kb)/1024 AS [SPA Memory Usage (MB)] 
FROM sys.dm_os_memory_clerks WITH (NOLOCK)
GROUP BY [type]  
ORDER BY SUM(single_pages_kb) DESC OPTION (RECOMPILE);

-- CACHESTORE_SQLCP  SQL Plans         
-- These are cached SQL statements or batches that aren't in stored procedures, functions and triggers
--
-- CACHESTORE_OBJCP  Object Plans      
-- These are compiled plans for stored procedures, functions and triggers
--
-- CACHESTORE_PHDR   Algebrizer Trees  
-- An algebrizer tree is the parsed SQL text that resolves the table and column names


-- Find single-use, ad-hoc and prepared queries that are bloating the plan cache  (Query 33) (Ad hoc Queries)
SELECT TOP(50) [text] AS [QueryText], cp.objtype, cp.size_in_bytes
FROM sys.dm_exec_cached_plans AS cp WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(plan_handle) 
WHERE cp.cacheobjtype = N'Compiled Plan' 
AND cp.objtype IN (N'Adhoc', N'Prepared') 
AND cp.usecounts = 1
ORDER BY cp.size_in_bytes DESC OPTION (RECOMPILE);

-- Gives you the text and size of single-use ad-hoc queries  that waste space in the plan cache
-- Enabling 'optimize for ad hoc workloads' for the instance can help (SQL Server 2008 and 2008 R2 only)
-- Running DBCC FREESYSTEMCACHE ('SQL Plans') periodically may be required to better control this.
-- Enabling forced parameterization for the database can help, but test first!





















-- Database specific queries *****************************************************************

-- **** Switch to a user database *****
USE dbaadmin;
GO

-- Individual File Sizes and space available for current database  (Query 34) (File Sizes and Space)
SELECT f.name AS [File Name] , f.physical_name AS [Physical Name], 
CAST((f.size/128.0) AS decimal(15,2)) AS [Total Size in MB],
CAST(f.size/128.0 - CAST(FILEPROPERTY(f.name, 'SpaceUsed') AS int)/128.0 AS decimal(15,2)) 
AS [Available Space In MB], [file_id], fg.name AS [Filegroup Name]
FROM sys.database_files AS f WITH (NOLOCK) 
LEFT OUTER JOIN sys.data_spaces AS fg WITH (NOLOCK) 
ON f.data_space_id = fg.data_space_id OPTION (RECOMPILE);

-- Look at how large and how full the files are and where they are located
-- Make sure the transaction log is not full!!



-- I/O Statistics by file for the current database  (Query 35) (IO Stats By File)
SELECT DB_NAME(DB_ID()) AS [Database Name], df.name AS [Logical Name], vfs.[file_id], 
df.physical_name AS [Physical Name], vfs.num_of_reads, vfs.num_of_writes, vfs.io_stall_read_ms, vfs.io_stall_write_ms,
CAST(100. * vfs.io_stall_read_ms/(vfs.io_stall_read_ms + vfs.io_stall_write_ms) AS DECIMAL(10,1)) AS [IO Stall Reads Pct],
CAST(100. * vfs.io_stall_write_ms/(vfs.io_stall_write_ms + vfs.io_stall_read_ms) AS DECIMAL(10,1)) AS [IO Stall Writes Pct],
(vfs.num_of_reads + vfs.num_of_writes) AS [Writes + Reads], vfs.num_of_bytes_read, vfs.num_of_bytes_written,
CAST(100. * vfs.num_of_reads/(vfs.num_of_reads + vfs.num_of_writes) AS DECIMAL(10,1)) AS [# Reads Pct],
CAST(100. * vfs.num_of_writes/(vfs.num_of_reads + vfs.num_of_writes) AS DECIMAL(10,1)) AS [# Write Pct],
CAST(100. * vfs.num_of_bytes_read/(vfs.num_of_bytes_read + vfs.num_of_bytes_written) AS DECIMAL(10,1)) AS [Read Bytes Pct],
CAST(100. * vfs.num_of_bytes_written/(vfs.num_of_bytes_read + vfs.num_of_bytes_written) AS DECIMAL(10,1)) AS [Written Bytes Pct]
FROM sys.dm_io_virtual_file_stats(DB_ID(), NULL) AS vfs
INNER JOIN sys.database_files AS df WITH (NOLOCK)
ON vfs.[file_id]= df.[file_id]
OPTION (RECOMPILE);

-- This helps you characterize your workload better from an I/O perspective for this database
-- It helps you determine whether you has an OLTP or DW/DSS type of workload



-- Top cached queries by Execution Count (SQL Server 2008)  (Query 36) (Query Execution Counts)
-- SQL Server 2008 R2 SP1 and greater only
SELECT TOP (250) qs.execution_count, qs.total_rows, qs.last_rows, qs.min_rows, qs.max_rows,
qs.last_elapsed_time, qs.min_elapsed_time, qs.max_elapsed_time,
total_worker_time, total_logical_reads, 
SUBSTRING(qt.TEXT,qs.statement_start_offset/2 +1,
(CASE WHEN qs.statement_end_offset = -1
			THEN LEN(CONVERT(NVARCHAR(MAX), qt.TEXT)) * 2
	  ELSE qs.statement_end_offset END - qs.statement_start_offset)/2) AS query_text 
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
ORDER BY qs.execution_count DESC OPTION (RECOMPILE);

-- Uses several new rows returned columns to help troubleshoot performance problems


-- Top Cached SPs By Execution Count (SQL 2008) (SQL 2008 R2 SP1 only) (Query 37) (SP Execution Counts)
SELECT TOP(250) p.name AS [SP Name], qs.execution_count,
ISNULL(qs.execution_count/DATEDIFF(Second, qs.cached_time, GETDATE()), 0) AS [Calls/Second],
qs.total_worker_time/qs.execution_count AS [AvgWorkerTime], qs.total_worker_time AS [TotalWorkerTime],  
qs.total_elapsed_time, qs.total_elapsed_time/qs.execution_count AS [avg_elapsed_time],
qs.cached_time
FROM sys.procedures AS p WITH (NOLOCK)
INNER JOIN sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
ON p.[object_id] = qs.[object_id]
WHERE qs.database_id = DB_ID()
ORDER BY qs.execution_count DESC OPTION (RECOMPILE);

-- Tells you which cached stored procedures are called the most often
-- This helps you characterize and baseline your workload


-- Top Cached SPs By Avg Elapsed Time (SQL 2008)  (Query 38) (SP Avg Elapsed Time) 
SELECT TOP(25) p.name AS [SP Name], qs.total_elapsed_time/qs.execution_count AS [avg_elapsed_time], 
qs.total_elapsed_time, qs.execution_count, ISNULL(qs.execution_count/DATEDIFF(Second, qs.cached_time, 
GETDATE()), 0) AS [Calls/Second], qs.total_worker_time/qs.execution_count AS [AvgWorkerTime], 
qs.total_worker_time AS [TotalWorkerTime], qs.cached_time
FROM sys.procedures AS p WITH (NOLOCK)
INNER JOIN sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
ON p.[object_id] = qs.[object_id]
WHERE qs.database_id = DB_ID()
ORDER BY avg_elapsed_time DESC OPTION (RECOMPILE);

-- This helps you find long-running cached stored procedures that
-- may be easy to optimize with standard query tuning techniques


-- Top Cached SPs By Avg Elapsed Time with execution time variability   (Query 39) (SP Avg Elapsed Variable Time)
SELECT TOP(25) p.name AS [SP Name], qs.execution_count, qs.min_elapsed_time,
qs.total_elapsed_time/qs.execution_count AS [avg_elapsed_time],
qs.max_elapsed_time, qs.last_elapsed_time,  qs.cached_time
FROM sys.procedures AS p WITH (NOLOCK)
INNER JOIN sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
ON p.[object_id] = qs.[object_id]
WHERE qs.database_id = DB_ID()
ORDER BY avg_elapsed_time DESC OPTION (RECOMPILE);

-- This gives you some interesting information about the variability in the
-- execution time of your cached stored procedures, which is useful for tuning


-- Top Cached SPs By Total Worker time (SQL 2008). Worker time relates to CPU cost  (Query 40) (SP Worker Time)
SELECT TOP(25) p.name AS [SP Name], qs.total_worker_time AS [TotalWorkerTime], 
qs.total_worker_time/qs.execution_count AS [AvgWorkerTime], qs.execution_count, 
ISNULL(qs.execution_count/DATEDIFF(Second, qs.cached_time, GETDATE()), 0) AS [Calls/Second],
qs.total_elapsed_time, qs.total_elapsed_time/qs.execution_count 
AS [avg_elapsed_time], qs.cached_time
FROM sys.procedures AS p WITH (NOLOCK)
INNER JOIN sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
ON p.[object_id] = qs.[object_id]
WHERE qs.database_id = DB_ID()
ORDER BY qs.total_worker_time DESC OPTION (RECOMPILE);

-- This helps you find the most expensive cached stored procedures from a CPU perspective
-- You should look at this if you see signs of CPU pressure


-- Top Cached SPs By Total Logical Reads (SQL 2008). Logical reads relate to memory pressure  (Query 41) (SP Logical Reads)
SELECT TOP(25) p.name AS [SP Name], qs.total_logical_reads AS [TotalLogicalReads], 
qs.total_logical_reads/qs.execution_count AS [AvgLogicalReads],qs.execution_count, 
ISNULL(qs.execution_count/DATEDIFF(Second, qs.cached_time, GETDATE()), 0) AS [Calls/Second], 
qs.total_elapsed_time, qs.total_elapsed_time/qs.execution_count 
AS [avg_elapsed_time], qs.cached_time
FROM sys.procedures AS p WITH (NOLOCK)
INNER JOIN sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
ON p.[object_id] = qs.[object_id]
WHERE qs.database_id = DB_ID()
ORDER BY qs.total_logical_reads DESC OPTION (RECOMPILE);

-- This helps you find the most expensive cached stored procedures from a memory perspective
-- You should look at this if you see signs of memory pressure


-- Top Cached SPs By Total Physical Reads (SQL 2008). Physical reads relate to disk I/O pressure  (Query 42) (SP Physical Reads)
SELECT TOP(25) p.name AS [SP Name],qs.total_physical_reads AS [TotalPhysicalReads], 
qs.total_physical_reads/qs.execution_count AS [AvgPhysicalReads], qs.execution_count, 
qs.total_logical_reads,qs.total_elapsed_time, qs.total_elapsed_time/qs.execution_count 
AS [avg_elapsed_time], qs.cached_time 
FROM sys.procedures AS p WITH (NOLOCK)
INNER JOIN sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
ON p.[object_id] = qs.[object_id]
WHERE qs.database_id = DB_ID()
AND qs.total_physical_reads > 0
ORDER BY qs.total_physical_reads DESC, qs.total_logical_reads DESC OPTION (RECOMPILE);

-- This helps you find the most expensive cached stored procedures from a read I/O perspective
-- You should look at this if you see signs of I/O pressure or of memory pressure
       
-- Top Cached SPs By Total Logical Writes (SQL 2008)  (Query 43) (SP Logical Writes)
-- Logical writes relate to both memory and disk I/O pressure 
SELECT TOP(25) p.name AS [SP Name], qs.total_logical_writes AS [TotalLogicalWrites], 
qs.total_logical_writes/qs.execution_count AS [AvgLogicalWrites], qs.execution_count,
ISNULL(qs.execution_count/DATEDIFF(Second, qs.cached_time, GETDATE()), 0) AS [Calls/Second],
qs.total_elapsed_time, qs.total_elapsed_time/qs.execution_count AS [avg_elapsed_time], 
qs.cached_time
FROM sys.procedures AS p WITH (NOLOCK)
INNER JOIN sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
ON p.[object_id] = qs.[object_id]
WHERE qs.database_id = DB_ID()
ORDER BY qs.total_logical_writes DESC OPTION (RECOMPILE);

-- This helps you find the most expensive cached stored procedures from a write I/O perspective
-- You should look at this if you see signs of I/O pressure or of memory pressure


-- Lists the top statements by average input/output usage for the current database  (Query 44) (Top IO Statements)
SELECT TOP(50) OBJECT_NAME(qt.objectid) AS [SP Name],
(qs.total_logical_reads + qs.total_logical_writes) /qs.execution_count AS [Avg IO],
SUBSTRING(qt.[text],qs.statement_start_offset/2, 
	(CASE 
		WHEN qs.statement_end_offset = -1 
	 THEN LEN(CONVERT(nvarchar(max), qt.[text])) * 2 
		ELSE qs.statement_end_offset 
	 END - qs.statement_start_offset)/2) AS [Query Text]	
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
WHERE qt.[dbid] = DB_ID()
ORDER BY [Avg IO] DESC OPTION (RECOMPILE);

-- Helps you find the most expensive statements for I/O by SP



-- Possible Bad NC Indexes (writes > reads)  (Query 45) (Bad NC Indexes)
SELECT OBJECT_NAME(s.[object_id]) AS [Table Name], i.name AS [Index Name], i.index_id, i.is_disabled,
user_updates AS [Total Writes], user_seeks + user_scans + user_lookups AS [Total Reads],
user_updates - (user_seeks + user_scans + user_lookups) AS [Difference]
FROM sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON s.[object_id] = i.[object_id]
AND i.index_id = s.index_id
WHERE OBJECTPROPERTY(s.[object_id],'IsUserTable') = 1
AND s.database_id = DB_ID()
AND user_updates > (user_seeks + user_scans + user_lookups)
AND i.index_id > 1
ORDER BY [Difference] DESC, [Total Writes] DESC, [Total Reads] ASC OPTION (RECOMPILE);

-- Look for indexes with high numbers of writes and zero or very low numbers of reads
-- Consider your complete workload
-- Investigate further before dropping an index!


-- Missing Indexes for current database by Index Advantage  (Query 46) (Missing Indexes)
SELECT DISTINCT CONVERT(decimal(18,2), user_seeks * avg_total_user_cost * (avg_user_impact * 0.01)) AS [index_advantage], 
migs.last_user_seek, mid.[statement] AS [Database.Schema.Table],
mid.equality_columns, mid.inequality_columns, mid.included_columns,
migs.unique_compiles, migs.user_seeks, migs.avg_total_user_cost, migs.avg_user_impact,
OBJECT_NAME(mid.object_id) AS [Table Name], p.rows AS [Table Rows]
FROM sys.dm_db_missing_index_group_stats AS migs WITH (NOLOCK)
INNER JOIN sys.dm_db_missing_index_groups AS mig WITH (NOLOCK)
ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details AS mid WITH (NOLOCK)
ON mig.index_handle = mid.index_handle
INNER JOIN sys.partitions AS p WITH (NOLOCK)
ON p.object_id = mid.object_id
WHERE mid.database_id = DB_ID() -- Remove this to see for entire instance
ORDER BY index_advantage DESC OPTION (RECOMPILE);

-- Look at index advantage, last user seek time, number of user seeks to help determine source and importance
-- SQL Server is overly eager to add included columns, so beware
-- Do not just blindly add indexes that show up from this query!!!


-- Find missing index warnings for cached plans in the current database  (Query 47) (Missing Index Warnings)
-- Note: This query could take some time on a busy instance
SELECT TOP(25) OBJECT_NAME(objectid) AS [ObjectName], 
               query_plan, cp.objtype, cp.usecounts
FROM sys.dm_exec_cached_plans AS cp WITH (NOLOCK)
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
WHERE CAST(query_plan AS NVARCHAR(MAX)) LIKE N'%MissingIndex%'
AND dbid = DB_ID()
ORDER BY cp.usecounts DESC OPTION (RECOMPILE);

-- Helps you connect missing indexes to specific stored procedures
-- This can help you decide whether to add them or not


-- Breaks down buffers used by current database by object (table, index) in the buffer cache  (Query 48) (Buffer Usage)
-- Note: This query could take some time on a busy instance
SELECT OBJECT_NAME(p.[object_id]) AS [ObjectName], 
p.index_id, COUNT(*)/128 AS [Buffer size(MB)],  COUNT(*) AS [BufferCount], 
p.data_compression_desc AS [CompressionType], a.type_desc, p.[rows]
FROM sys.allocation_units AS a WITH (NOLOCK)
INNER JOIN sys.dm_os_buffer_descriptors AS b WITH (NOLOCK)
ON a.allocation_unit_id = b.allocation_unit_id
INNER JOIN sys.partitions AS p WITH (NOLOCK)
ON a.container_id = p.partition_id
WHERE b.database_id = CONVERT(int,DB_ID())
AND p.[object_id] > 100
GROUP BY p.[object_id], p.index_id, p.data_compression_desc, a.type_desc, p.[rows]
ORDER BY [BufferCount] DESC OPTION (RECOMPILE);

-- Tells you what tables and indexes are using the most memory in the buffer cache


-- Get Table names, row counts, and compression status for clustered index or heap  (Query 49) (Table Sizes)
SELECT OBJECT_NAME(object_id) AS [ObjectName], 
SUM(Rows) AS [RowCount], data_compression_desc AS [CompressionType]
FROM sys.partitions WITH (NOLOCK)
WHERE index_id < 2 --ignore the partitions from the non-clustered index if any
AND OBJECT_NAME(object_id) NOT LIKE N'sys%'
AND OBJECT_NAME(object_id) NOT LIKE N'queue_%' 
AND OBJECT_NAME(object_id) NOT LIKE N'filestream_tombstone%' 
AND OBJECT_NAME(object_id) NOT LIKE N'fulltext%'
AND OBJECT_NAME(object_id) NOT LIKE N'ifts_comp_fragment%'
GROUP BY object_id, data_compression_desc
ORDER BY SUM(Rows) DESC OPTION (RECOMPILE);

-- Gives you an idea of table sizes, and possible data compression opportunities


-- Get some key table properties (Query 50) (Table Properties)
SELECT [name], create_date, lock_on_bulk_load, is_replicated, has_replication_filter, 
       is_tracked_by_cdc, lock_escalation_desc
FROM sys.tables WITH (NOLOCK) 
ORDER BY [name] OPTION (RECOMPILE);

-- Gives you some good information about your tables



-- When were Statistics last updated on all indexes?  (Query 51) (Statistics Update)
SELECT o.name, i.name AS [Index Name],  
      STATS_DATE(i.[object_id], i.index_id) AS [Statistics Date], 
      s.auto_created, s.no_recompute, s.user_created, st.row_count
FROM sys.objects AS o WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON o.[object_id] = i.[object_id]
INNER JOIN sys.stats AS s WITH (NOLOCK)
ON i.[object_id] = s.[object_id] 
AND i.index_id = s.stats_id
INNER JOIN sys.dm_db_partition_stats AS st WITH (NOLOCK)
ON o.[object_id] = st.[object_id]
AND i.[index_id] = st.[index_id]
WHERE o.[type] = 'U'
ORDER BY STATS_DATE(i.[object_id], i.index_id) ASC OPTION (RECOMPILE);  

-- Helps discover possible problems with out-of-date statistics
-- Also gives you an idea which indexes are the most active


-- Get fragmentation info for all indexes above a certain size in the current database  (Query 52) (Index Fragmentation)
-- Note: This could take some time on a very large database
SELECT DB_NAME(database_id) AS [Database Name], OBJECT_NAME(ps.OBJECT_ID) AS [Object Name], 
i.name AS [Index Name], ps.index_id, index_type_desc,
avg_fragmentation_in_percent, fragment_count, page_count
FROM sys.dm_db_index_physical_stats(DB_ID(),NULL, NULL, NULL ,N'LIMITED') AS ps 
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON ps.[object_id] = i.[object_id] 
AND ps.index_id = i.index_id
WHERE database_id = DB_ID()
AND page_count > 1500
ORDER BY avg_fragmentation_in_percent DESC OPTION (RECOMPILE);

-- Helps determine whether you have framentation in your relational indexes
-- and how effective your index maintenance strategy is


--- Index Read/Write stats (all tables in current DB) ordered by Reads  (Query 53) (Overall Index Usage - Reads)
SELECT OBJECT_NAME(s.[object_id]) AS [ObjectName], i.name AS [IndexName], i.index_id,
	   user_seeks + user_scans + user_lookups AS [Reads], s.user_updates AS [Writes],  
	   i.type_desc AS [IndexType], i.fill_factor AS [FillFactor]
FROM sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON s.[object_id] = i.[object_id]
WHERE OBJECTPROPERTY(s.[object_id],'IsUserTable') = 1
AND i.index_id = s.index_id
AND s.database_id = DB_ID()
ORDER BY user_seeks + user_scans + user_lookups DESC OPTION (RECOMPILE); -- Order by reads

-- Show which indexes in the current database are most active for Reads


--- Index Read/Write stats (all tables in current DB) ordered by Writes  (Query 54) (Overall Index Usage - Writes)
SELECT OBJECT_NAME(s.[object_id]) AS [ObjectName], i.name AS [IndexName], i.index_id,
	   s.user_updates AS [Writes], user_seeks + user_scans + user_lookups AS [Reads], 
	   i.type_desc AS [IndexType], i.fill_factor AS [FillFactor]
FROM sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON s.[object_id] = i.[object_id]
WHERE OBJECTPROPERTY(s.[object_id],'IsUserTable') = 1
AND i.index_id = s.index_id
AND s.database_id = DB_ID()
ORDER BY s.user_updates DESC OPTION (RECOMPILE);						 -- Order by writes

-- Show which indexes in the current database are most active for Writes


-- Look at recent Full backups for the current database (Query 55) (Recent Full Backups)
SELECT TOP (30) bs.server_name, bs.database_name AS [Database Name], 
CONVERT (BIGINT, bs.backup_size / 1048576 ) AS [Uncompressed Backup Size (MB)],
CONVERT (BIGINT, bs.compressed_backup_size / 1048576 ) AS [Compressed Backup Size (MB)],
CONVERT (NUMERIC (20,2), (CONVERT (FLOAT, bs.backup_size) /
CONVERT (FLOAT, bs.compressed_backup_size))) AS [Compression Ratio], 
DATEDIFF (SECOND, bs.backup_start_date, bs.backup_finish_date) AS [Backup Elapsed Time (sec)],
bs.backup_finish_date AS [Backup Finish Date]
FROM msdb.dbo.backupset AS bs WITH (NOLOCK)
WHERE DATEDIFF (SECOND, bs.backup_start_date, bs.backup_finish_date) > 0 
AND bs.backup_size > 0
AND bs.type = 'D' -- Change to L if you want Log backups
AND database_name = DB_NAME(DB_ID())
ORDER BY bs.backup_finish_date DESC OPTION (RECOMPILE);

-- Are your backup sizes and times changing over time?


-- Get the average full backup size by month for the current database (SQL 2008) (Query 56) (Database Size History)
-- This helps you understand your database growth over time
-- Adapted from Erin Stellato
SELECT [database_name] AS [Database], DATEPART(month,[backup_start_date]) AS [Month],
CAST(AVG([backup_size]/1024/1024) AS DECIMAL(15,2)) AS [Backup Size (MB)],
CAST(AVG([compressed_backup_size]/1024/1024) AS DECIMAL(15,2)) AS [Compressed Backup Size (MB)],
CAST(AVG([backup_size]/[compressed_backup_size]) AS DECIMAL(15,2)) AS [Compression Ratio]
FROM msdb.dbo.backupset WITH (NOLOCK)
WHERE [database_name] = DB_NAME(DB_ID())
AND [type] = 'D'
AND backup_start_date >= DATEADD(MONTH, -12, GETDATE())
GROUP BY [database_name],DATEPART(mm,[backup_start_date]) OPTION (RECOMPILE);

-- The Backup Size (MB) (without backup compression) shows the true size of your database over time
-- This helps you track and plan your data size growth
-- It is possible that your data files may be larger on disk due to empty space within those files


Select 
                'Login Name'= Substring(upper(SUSER_SNAME(SID)),1,40),
                'Login Create Date'=Convert(Varchar(24),CreateDate),
                'System Admin' = Case SysAdmin
                                                When 1 then 'YES (VERIFY)'
                                                When 0 then 'NO'
                End,
                'Security Admin' = Case SecurityAdmin
                                                When 1 then 'YES (VERIFY)'
                                                When 0 then 'NO'
                End,
                'Server Admin' = Case ServerAdmin
                                                When 1 then 'YES (VERIFY)'
                                                When 0 then 'NO'
                End,
                'Setup Admin' = Case SetupAdmin
                                                When 1 then 'YES (VERIFY)'
                                                When 0 then 'NO'
                End,
                'Process Admin' = Case ProcessAdmin
                                                When 1 then 'YES (VERIFY)'
                                                When 0 then 'NO'
                End,
                'Disk Admin' = Case DiskAdmin
                                                When 1 then 'YES (VERIFY)'
                                                When 0 then 'NO'
                End,
                'Database Creator' = Case DBCreator
                                                When 1 then 'YES (VERIFY)'
                                                When 0 then 'NO'
                End
                from Master.Sys.SysLogins order by 3 desc
Go




/********************************************************************************************* 
Find Key Lookups in Cached Plans

  
Note: 
   Exercise caution when running this in production! 

   The function sys.dm_exec_query_plan() is resource intensive and can put strain 
   on a server when used to retrieve all cached query plans. 

   Consider using TOP in the initial select statement (insert into @plans) 
   to limit the impact of running this query or run during non-peak hours 
*********************************************************************************************/ 
DECLARE @plans TABLE 
    ( 
      query_text NVARCHAR(MAX) , 
      o_name SYSNAME , 
      execution_plan XML , 
      last_execution_time DATETIME , 
      execution_count BIGINT , 
      total_worker_time BIGINT , 
      total_physical_reads BIGINT , 
      total_logical_reads BIGINT 
    ) ; 

DECLARE @lookups TABLE 
    ( 
      table_name SYSNAME , 
      index_name SYSNAME , 
      index_cols NVARCHAR(MAX) 
    ) ; 

WITH    query_stats 
          AS ( SELECT   [sql_handle] , 
                        [plan_handle] , 
                        MAX(last_execution_time) AS last_execution_time , 
                        SUM(execution_count) AS execution_count , 
                        SUM(total_worker_time) AS total_worker_time , 
                        SUM(total_physical_reads) AS total_physical_reads , 
                        SUM(total_logical_reads) AS total_logical_reads 
               FROM     sys.dm_exec_query_stats 
               GROUP BY [sql_handle] , 
                        [plan_handle] 
             ) 
    INSERT  INTO @plans 
            ( query_text , 
              o_name , 
              execution_plan , 
              last_execution_time , 
              execution_count , 
              total_worker_time , 
              total_physical_reads , 
              total_logical_reads 
            ) 
            SELECT /*TOP 50*/ 
                    sql_text.[text] , 
                    CASE WHEN sql_text.objectid IS NOT NULL 
                         THEN ISNULL(OBJECT_NAME(sql_text.objectid, 
                                                 sql_text.[dbid]), 
                                     'Unresolved') 
                         ELSE CAST('Ad-hoc\Prepared' AS SYSNAME) 
                    END , 
                    query_plan.query_plan , 
                    query_stats.last_execution_time , 
                    query_stats.execution_count , 
                    query_stats.total_worker_time , 
                    query_stats.total_physical_reads , 
                    query_stats.total_logical_reads 
            FROM    query_stats 
                    CROSS APPLY sys.dm_exec_sql_text(query_stats.sql_handle) 
                    AS [sql_text] 
                    CROSS APPLY sys.dm_exec_query_plan(query_stats.plan_handle) 
                    AS [query_plan] 
            WHERE   query_plan.query_plan IS NOT NULL ; 


;WITH		XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
		,lookups 
		AS 
		( 
   SELECT  DB_ID(REPLACE(REPLACE(keylookups.keylookup.value('(Object/@Database)[1]', 
                                                            'sysname'), '[', ''), 
                         ']', '')) AS [database_id] , 
           OBJECT_ID(keylookups.keylookup.value('(Object/@Database)[1]', 
                                                'sysname') + '.' 
                     + keylookups.keylookup.value('(Object/@Schema)[1]', 
                                                  'sysname') + '.' 
                     + keylookups.keylookup.value('(Object/@Table)[1]', 'sysname')) AS [object_id] , 
           keylookups.keylookup.value('(Object/@Database)[1]', 'sysname') AS [database] , 
           keylookups.keylookup.value('(Object/@Schema)[1]', 'sysname') AS [schema] , 
           keylookups.keylookup.value('(Object/@Table)[1]', 'sysname') AS [table] , 
           keylookups.keylookup.value('(Object/@Index)[1]', 'sysname') AS [index] , 
           REPLACE(keylookups.keylookup.query(' 
for $column in DefinedValues/DefinedValue/ColumnReference 
return string($column/@Column) 
').value('.', 'varchar(max)'), ' ', ', ') AS [columns] , 
           plans.query_text , 
           plans.o_name, 
           plans.execution_plan , 
           plans.last_execution_time , 
           plans.execution_count , 
           plans.total_worker_time , 
           plans.total_physical_reads, 
           plans.total_logical_reads 
   FROM    @plans AS [plans] 
           CROSS APPLY execution_plan.nodes('//RelOp/IndexScan[@Lookup="1"]') AS keylookups ( keylookup ) 
) 
SELECT  lookups.[database] , 
        lookups.[schema] , 
        lookups.[table] , 
        lookups.[index] , 
        lookups.[columns] , 
        index_stats.user_lookups , 
        index_stats.last_user_lookup , 
        lookups.execution_count , 
        lookups.total_worker_time , 
        lookups.total_physical_reads , 
        lookups.total_logical_reads, 
        lookups.last_execution_time , 
       lookups.o_name AS [object_name], 
        lookups.query_text , 
        lookups.execution_plan 
FROM    lookups 
        INNER JOIN sys.dm_db_index_usage_stats AS [index_stats] ON lookups.database_id = index_stats.database_id 
                                                              AND lookups.[object_id] = index_stats.[object_id] 
WHERE   index_stats.user_lookups > 0 
        AND lookups.[database] NOT IN ('[master]','[model]','[msdb]','[tempdb]') 
ORDER BY lookups.execution_count DESC 
--ORDER BY index_stats.user_lookups DESC 
--ORDER BY lookups.total_logical_reads DESC 