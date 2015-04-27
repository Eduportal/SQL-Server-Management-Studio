



--USE msdb;
--GO
---- Disable constraints
---- this is done to make sure that constraint logic does not interfere with cleanup process
--ALTER TABLE dbo.syscollector_collection_sets_internal
--  NOCHECK CONSTRAINT FK_syscollector_collection_sets_collection_sysjobs

--ALTER TABLE dbo.syscollector_collection_sets_internal  
--  NOCHECK CONSTRAINT FK_syscollector_collection_sets_upload_sysjobs

---- Delete data collector jobs
--DECLARE @job_id uniqueidentifier
--DECLARE datacollector_jobs_cursor CURSOR LOCAL
--FOR
--  SELECT collection_job_id AS job_id FROM syscollector_collection_sets
--  WHERE collection_job_id IS NOT NULL
--  UNION
--  SELECT upload_job_id AS job_id FROM syscollector_collection_sets
--  WHERE upload_job_id IS NOT NULL

--OPEN datacollector_jobs_cursor

--FETCH NEXT FROM datacollector_jobs_cursor INTO @job_id

--WHILE (@@fetch_status = 0)
-- BEGIN
--  IF EXISTS ( SELECT COUNT(job_id) FROM sysjobs WHERE job_id = @job_id )
--  BEGIN
--    DECLARE @job_name sysname
--    SELECT @job_name = name from sysjobs WHERE job_id = @job_id
--    PRINT 'Removing job '+ @job_name
--    EXEC dbo.sp_delete_job @job_id=@job_id, @delete_unused_schedule=0
--  END

--  FETCH NEXT FROM datacollector_jobs_cursor INTO @job_id
--END

--CLOSE datacollector_jobs_cursor
--DEALLOCATE datacollector_jobs_cursor

---- Enable Constraints back
--ALTER TABLE dbo.syscollector_collection_sets_internal
--  CHECK CONSTRAINT FK_syscollector_collection_sets_collection_sysjobs

--ALTER TABLE dbo.syscollector_collection_sets_internal
--  CHECK CONSTRAINT FK_syscollector_collection_sets_upload_sysjobs

---- Disable trigger on syscollector_collection_sets_internal
---- this is done to make sure that trigger logic does not interfere with cleanup process
--EXEC('DISABLE TRIGGER syscollector_collection_set_is_running_update_trigger
--     ON syscollector_collection_sets_internal')

---- Set collection sets as not running state
--UPDATE syscollector_collection_sets_internal
-- SET is_running = 0

---- Update collect and upload jobs as null
--UPDATE syscollector_collection_sets_internal
-- SET collection_job_id = NULL, upload_job_id = NULL


--SELECT * FROM syscollector_collection_sets_internal


--DELETE  FROM syscollector_collection_sets_internal


---- Enable back trigger on syscollector_collection_sets_internal
--EXEC('ENABLE TRIGGER syscollector_collection_set_is_running_update_trigger
--     ON syscollector_collection_sets_internal')


--SELECT * FROM syscollector_config_store_internal



---- re-set collector config store
--UPDATE syscollector_config_store_internal
-- SET parameter_value = 0
-- WHERE parameter_name IN ('CollectorEnabled')

--UPDATE syscollector_config_store_internal
-- SET parameter_value = NULL
-- WHERE parameter_name IN ( 'MDWDatabase', 'MDWInstance' )

---- Delete collection set logs
--DELETE FROM syscollector_execution_log_internal

--UPDATE syscollector_config_store_internal
-- SET parameter_value = 'DBAPerf'
-- WHERE parameter_name = 'MDWDatabase'

--UPDATE syscollector_config_store_internal
-- SET parameter_value = '(local)'
-- WHERE parameter_name = 'MDWInstance'


--SELECT * FROM [dbo].[syscollector_tsql_query_collector]
--SELECT * FROM [dbo].[syscollector_execution_stats_internal]
--SELECT * FROM [dbo].[syscollector_execution_log_internal]
--SELECT * FROM [dbo].[syscollector_config_store_internal]
--SELECT * FROM [dbo].[syscollector_collector_types_internal]
--SELECT * FROM [msdb].[dbo].[syscollector_collection_sets_internal]
--SELECT * FROM [dbo].[syscollector_collection_items_internal]
--SELECT * FROM [dbo].[syscollector_blobs_internal]

UPDATE [syscollector_collection_sets_internal] SET is_system = 0


EXEC [msdb].[dbo].[sp_syscollector_delete_collection_set]  @name = 'Server Activity'
EXEC [msdb].[dbo].[sp_syscollector_delete_collection_set]  @name = 'Disk Usage'
EXEC [msdb].[dbo].[sp_syscollector_delete_collection_set]  @name = 'Query Statistics'
EXEC [msdb].[dbo].[sp_syscollector_delete_collection_set]  @name = 'Utility Information'

Declare @collection_set_id	int
Declare @collection_set_uid	uniqueidentifier
Declare @collection_item_id	int
Declare @collector_type_uid	uniqueidentifier

SET	@collection_set_uid	= '49268954-4FD4-4EB6-AA04-CD59D9BB5714'

EXEC [msdb].[dbo].[sp_syscollector_create_collection_set] 
	@name				=N'Server Activity'
	, @collection_mode		=0
	, @description			=N'Collects top-level performance indicators for the computer and the Database Engine. Enables analysis of resource use, resource bottlenecks, and Database Engine activity.'
	, @logging_level		=2
	, @days_until_expiration	=30
	, @schedule_name		=N'CollectorSchedule_Every_15min'
	, @collection_set_id		=@collection_set_id OUTPUT
	, @collection_set_uid		=@collection_set_uid OUTPUT

Select		@collection_set_id
		, @collection_set_uid

Select		@collector_type_uid = collector_type_uid 
From		[msdb].[dbo].[syscollector_collector_types] 
Where		name = N'Generic T-SQL Query Collector Type';

EXEC [msdb].[dbo].[sp_syscollector_create_collection_item] 
	@name				=N'Server Activity - DMV Snapshots'
	, @collection_item_id		=@collection_item_id OUTPUT
	, @frequency			=60
	, @collection_set_id		=@collection_set_id
	, @collector_type_uid		=@collector_type_uid
	, @parameters			=N'<ns:TSQLQueryCollector xmlns:ns="DataCollectorType"><Query><Value>
SET NOCOUNT ON
SELECT 
    LEFT (wait_type, 45) AS wait_type, 
    SUM (waiting_tasks_count) AS waiting_tasks_count, 
    SUM (wait_time_ms) AS wait_time_ms, 
    SUM (signal_wait_time_ms) AS signal_wait_time_ms
FROM 
(
    SELECT 
        LEFT (wait_type, 45) AS wait_type, 
    waiting_tasks_count, 
    wait_time_ms,  
    signal_wait_time_ms
FROM sys.dm_os_wait_stats 
WHERE waiting_tasks_count &gt; 0 OR wait_time_ms &gt; 0 OR signal_wait_time_ms &gt; 0
    UNION ALL 
    SELECT 
        LEFT (wait_type, 45) AS wait_type, 
        1 AS waiting_tasks_count, 
        wait_duration_ms AS wait_time_ms, 
        0 AS signal_wait_time_ms
    FROM sys.dm_os_waiting_tasks
    WHERE wait_duration_ms &gt; 60000
) AS merged_wait_stats
GROUP BY wait_type
</Value><OutputTable>os_wait_stats</OutputTable></Query><Query><Value>
SET NOCOUNT ON
SELECT 
  LEFT(latch_class,45) as latch_class,
  waiting_requests_count,
  wait_time_ms
FROM sys.dm_os_latch_stats 
WHERE waiting_requests_count &gt; 0 OR wait_time_ms &gt; 0
</Value><OutputTable>os_latch_stats</OutputTable></Query><Query><Value>
SET NOCOUNT ON
SELECT 
    pm.physical_memory_in_use_kb            AS sql_physical_memory_in_use_kb, 
    pm.large_page_allocations_kb            AS sql_large_page_allocations_kb, 
    pm.locked_page_allocations_kb           AS sql_locked_page_allocations_kb, 
    pm.total_virtual_address_space_kb       AS sql_total_virtual_address_space_kb, 
    pm.virtual_address_space_reserved_kb    AS sql_virtual_address_space_reserved_kb, 
    pm.virtual_address_space_committed_kb   AS sql_virtual_address_space_committed_kb, 
    pm.virtual_address_space_available_kb   AS sql_virtual_address_space_available_kb, 
    pm.page_fault_count                     AS sql_page_fault_count, 
    pm.memory_utilization_percentage        AS sql_memory_utilization_percentage, 
    pm.available_commit_limit_kb            AS sql_available_commit_limit_kb, 
    pm.process_physical_memory_low          AS sql_process_physical_memory_low, 
    pm.process_virtual_memory_low           AS sql_process_virtual_memory_low, 
    
    sm.total_physical_memory_kb             AS system_total_physical_memory_kb, 
    sm.available_physical_memory_kb         AS system_available_physical_memory_kb, 
    sm.total_page_file_kb                   AS system_total_page_file_kb, 
    sm.available_page_file_kb               AS system_available_page_file_kb, 
    sm.system_cache_kb                      AS system_cache_kb, 
    sm.kernel_paged_pool_kb                 AS system_kernel_paged_pool_kb, 
    sm.kernel_nonpaged_pool_kb              AS system_kernel_nonpaged_pool_kb, 
    sm.system_high_memory_signal_state      AS system_high_memory_signal_state, 
    sm.system_low_memory_signal_state       AS system_low_memory_signal_state, 
    
    si.bpool_commit_target                  AS bpool_commit_target, 
    si.bpool_committed                      AS bpool_committed, 
    si.bpool_visible                        AS bpool_visible
FROM sys.dm_os_process_memory AS pm
CROSS JOIN sys.dm_os_sys_memory AS sm   -- single-row DMV
CROSS JOIN sys.dm_os_sys_info AS si;    -- single-row DMV
</Value><OutputTable>sql_process_and_system_memory</OutputTable></Query><Query><Value>
SET NOCOUNT ON
SELECT 
    memory_node_id, 
    virtual_address_space_reserved_kb, 
    virtual_address_space_committed_kb, 
    locked_page_allocations_kb, 
    single_pages_kb, 
    multi_pages_kb, 
    shared_memory_reserved_kb, 
    shared_memory_committed_kb
FROM sys.dm_os_memory_nodes
</Value><OutputTable>os_memory_nodes</OutputTable></Query><Query><Value>
SET NOCOUNT ON
SELECT 
    type,
    memory_node_id as memory_node_id,
    SUM(single_pages_kb) as single_pages_kb,
    SUM(multi_pages_kb) as multi_pages_kb,
    SUM(virtual_memory_reserved_kb) as virtual_memory_reserved_kb,
    SUM(virtual_memory_committed_kb) as virtual_memory_committed_kb,
    SUM(awe_allocated_kb) as awe_allocated_kb,
    SUM(shared_memory_reserved_kb) as shared_memory_reserved_kb,
    SUM(shared_memory_committed_kb) as shared_memory_committed_kb
FROM sys.dm_os_memory_clerks
GROUP BY type, memory_node_id</Value><OutputTable>os_memory_clerks</OutputTable></Query><Query><Value>
SET NOCOUNT ON
SELECT 
    [parent_node_id],
    [scheduler_id],
    [cpu_id],
    [status],
    [is_idle],
    [preemptive_switches_count],
    [context_switches_count],
    [yield_count],
    [current_tasks_count],
    [runnable_tasks_count],
    [work_queue_count],
    [pending_disk_io_count]
FROM sys.dm_os_schedulers
WHERE scheduler_id &lt; 128
</Value><OutputTable>os_schedulers</OutputTable></Query><Query><Value>
SELECT 
    DB_NAME (f.database_id) AS database_name, f.database_id, f.name AS logical_file_name, f.[file_id], f.type_desc, 
    CAST (CASE 
        -- Handle UNC paths (e.g. ''\\fileserver\readonlydbs\dept_dw.ndf'' --&gt; ''\\fileserver\readonlydbs'')
        WHEN LEFT (LTRIM (f.physical_name), 2) = ''\\'' 
            THEN LEFT (LTRIM (f.physical_name), CHARINDEX (''\'', LTRIM (f.physical_name), CHARINDEX (''\'', LTRIM (f.physical_name), 3) + 1) - 1)
        -- Handle local paths (e.g. ''C:\Program Files\...\master.mdf'' --&gt; ''C:'') 
        WHEN CHARINDEX (''\'', LTRIM(f.physical_name), 3) &gt; 0 
            THEN UPPER (LEFT (LTRIM (f.physical_name), CHARINDEX (''\'', LTRIM (f.physical_name), 3) - 1))
        ELSE f.physical_name
    END AS nvarchar(255)) AS logical_disk, 
    fs.num_of_reads, fs.num_of_bytes_read, fs.io_stall_read_ms, fs.num_of_writes, fs.num_of_bytes_written, 
    fs.io_stall_write_ms, fs.size_on_disk_bytes
FROM sys.dm_io_virtual_file_stats (default, default) AS fs
INNER JOIN sys.master_files AS f ON fs.database_id = f.database_id AND fs.[file_id] = f.[file_id]
</Value><OutputTable>io_virtual_file_stats</OutputTable></Query></ns:TSQLQueryCollector>'

Select		@collection_item_id

Select		@collector_type_uid = collector_type_uid 
From		[msdb].[dbo].[syscollector_collector_types] 
Where		name = N'Performance Counters Collector Type';

EXEC [msdb].[dbo].[sp_syscollector_create_collection_item] 
	@name				=N'Server Activity - Performance Counters'
	, @collection_item_id		=@collection_item_id OUTPUT
	, @frequency			=60
	, @collection_set_id		=@collection_set_id
	, @collector_type_uid		=@collector_type_uid
	, @parameters			=N'<ns:PerformanceCountersCollector xmlns:ns="DataCollectorType"><PerformanceCounters Objects="Memory" Counters="% Committed Bytes In Use" /><PerformanceCounters Objects="Memory" Counters="Available Bytes" /><PerformanceCounters Objects="Memory" Counters="Cache Bytes" /><PerformanceCounters Objects="Memory" Counters="Cache Faults/sec" /><PerformanceCounters Objects="Memory" Counters="Committed Bytes" /><PerformanceCounters Objects="Memory" Counters="Free &amp; Zero Page List Bytes" /><PerformanceCounters Objects="Memory" Counters="Modified Page List Bytes" /><PerformanceCounters Objects="Memory" Counters="Pages/sec" /><PerformanceCounters Objects="Memory" Counters="Page Reads/sec" /><PerformanceCounters Objects="Memory" Counters="Page Write/sec" /><PerformanceCounters Objects="Memory" Counters="Page Faults/sec" /><PerformanceCounters Objects="Memory" Counters="Pool Nonpaged Bytes" /><PerformanceCounters Objects="Memory" Counters="Pool Paged Bytes" /><PerformanceCounters Objects="Memory" Counters="Standby Cache Core Bytes" /><PerformanceCounters Objects="Memory" Counters="Standby Cache Normal Priority Bytes" /><PerformanceCounters Objects="Memory" Counters="Standby Cache Reserve Bytes" /><PerformanceCounters Objects="Memory" Counters="Pool Paged Bytes" /><PerformanceCounters Objects="Memory" Counters="Write Copies/sec" /><PerformanceCounters Objects="Process" Counters="*" Instances="_Total" /><PerformanceCounters Objects="Process" Counters="*" Instances="$(TARGETPROCESS)" /><PerformanceCounters Objects="Process" Counters="Thread Count" Instances="*" /><PerformanceCounters Objects="Process" Counters="% Processor Time" Instances="*" /><PerformanceCounters Objects="Process" Counters="IO Read Bytes/sec" Instances="*" /><PerformanceCounters Objects="Process" Counters="IO Write Bytes/sec" Instances="*" /><PerformanceCounters Objects="Process" Counters="Private Bytes" Instances="*" /><PerformanceCounters Objects="Process" Counters="Working Set" Instances="*" /><PerformanceCounters Objects="Processor" Counters="% Processor Time" Instances="*" /><PerformanceCounters Objects="Processor" Counters="% User Time" Instances="*" /><PerformanceCounters Objects="Processor" Counters="% Privileged Time" Instances="*" /><PerformanceCounters Objects="Server Work Queues" Counters="Queue Length" Instances="*" /><PerformanceCounters Objects="LogicalDisk" Counters="% Disk Time" Instances="*" /><PerformanceCounters Objects="LogicalDisk" Counters="Avg. Disk Queue Length" Instances="*" /><PerformanceCounters Objects="LogicalDisk" Counters="Avg. Disk Read Queue Length" Instances="*" /><PerformanceCounters Objects="LogicalDisk" Counters="Avg. Disk Write Queue Length" Instances="*" /><PerformanceCounters Objects="LogicalDisk" Counters="Avg. Disk sec/Read" Instances="*" /><PerformanceCounters Objects="LogicalDisk" Counters="Avg. Disk sec/Write" Instances="*" /><PerformanceCounters Objects="LogicalDisk" Counters="Avg. Disk sec/Transfer" Instances="*" /><PerformanceCounters Objects="LogicalDisk" Counters="Disk Reads/sec" Instances="*" /><PerformanceCounters Objects="LogicalDisk" Counters="Disk Bytes/sec" Instances="*" /><PerformanceCounters Objects="LogicalDisk" Counters="Disk Writes/sec" Instances="*" /><PerformanceCounters Objects="LogicalDisk" Counters="Split IO/sec" Instances="*" /><PerformanceCounters Objects="System" Counters="Processor Queue Length" /><PerformanceCounters Objects="System" Counters="File Read Operations/sec" /><PerformanceCounters Objects="System" Counters="File Write Operations/sec" /><PerformanceCounters Objects="System" Counters="File Control Operations/sec" /><PerformanceCounters Objects="System" Counters="File Read Bytes/sec" /><PerformanceCounters Objects="System" Counters="File Write Bytes/sec" /><PerformanceCounters Objects="System" Counters="File Control Bytes/sec" /><PerformanceCounters Objects="Network Interface" Counters="Bytes Total/sec" Instances="*" /><PerformanceCounters Objects="Network Interface" Counters="Output Queue Length" Instances="*" /><PerformanceCounters Objects="$(INSTANCE):Buffer Manager" Counters="Stolen pages" /><PerformanceCounters Objects="$(INSTANCE):Buffer Manager" Counters="Page life expectancy" /><PerformanceCounters Objects="$(INSTANCE):Memory Manager" Counters="Memory Grants Outstanding" /><PerformanceCounters Objects="$(INSTANCE):Memory Manager" Counters="Memory Grants Pending" /><PerformanceCounters Objects="$(INSTANCE):Databases" Counters="Transactions/sec" Instances="_Total" /><PerformanceCounters Objects="$(INSTANCE):Databases" Counters="Transactions/sec" Instances="tempdb" /><PerformanceCounters Objects="$(INSTANCE):Databases" Counters="Active Transactions" Instances="*" /><PerformanceCounters Objects="$(INSTANCE):General Statistics" Counters="Logins/sec" /><PerformanceCounters Objects="$(INSTANCE):General Statistics" Counters="Logouts/sec" /><PerformanceCounters Objects="$(INSTANCE):General Statistics" Counters="User Connections" /><PerformanceCounters Objects="$(INSTANCE):General Statistics" Counters="Logical Connections" /><PerformanceCounters Objects="$(INSTANCE):General Statistics" Counters="Transactions" /><PerformanceCounters Objects="$(INSTANCE):General Statistics" Counters="Processes blocked" /><PerformanceCounters Objects="$(INSTANCE):General Statistics" Counters="Active Temp Tables" /><PerformanceCounters Objects="$(INSTANCE):SQL Statistics" Counters="Batch Requests/sec" /><PerformanceCounters Objects="$(INSTANCE):SQL Statistics" Counters="SQL Compilations/sec" /><PerformanceCounters Objects="$(INSTANCE):SQL Statistics" Counters="SQL Re-Compilations/sec" /><PerformanceCounters Objects="$(INSTANCE):SQL Statistics" Counters="SQL Attention rate" /><PerformanceCounters Objects="$(INSTANCE):SQL Statistics" Counters="Auto-Param Attempts/sec" /><PerformanceCounters Objects="$(INSTANCE):SQL Statistics" Counters="Failed Auto-Params/sec" /><PerformanceCounters Objects="$(INSTANCE):Plan Cache" Counters="Cache Hit Ratio" Instances="_Total" /><PerformanceCounters Objects="$(INSTANCE):Plan Cache" Counters="Cache Hit Ratio" Instances="Object Plans" /><PerformanceCounters Objects="$(INSTANCE):Plan Cache" Counters="Cache Hit Ratio" Instances="SQL Plans" /><PerformanceCounters Objects="$(INSTANCE):Plan Cache" Counters="Cache Hit Ratio" Instances="Temporary Tables &amp; Table Variables" /><PerformanceCounters Objects="$(INSTANCE):Transactions" Counters="Free Space in tempdb (KB)" /><PerformanceCounters Objects="$(INSTANCE):Workload Group Stats" Counters="Active requests" Instances="*" /><PerformanceCounters Objects="$(INSTANCE):Workload Group Stats" Counters="Blocked tasks" Instances="*" /><PerformanceCounters Objects="$(INSTANCE):Workload Group Stats" Counters="CPU usage %" Instances="*" /></ns:PerformanceCountersCollector>'

Select		@collection_item_id








SET	@collection_set_uid	= '7B191952-8ECF-4E12-AEB2-EF646EF79FEF'

EXEC [msdb].[dbo].[sp_syscollector_create_collection_set] 
	@name				=N'Disk Usage'
	, @collection_mode		=1
	, @description			=N'Collects data about the disk and log usage for all databases.'
	, @logging_level		=2
	, @days_until_expiration	=30
	, @schedule_name		=N'CollectorSchedule_Every_6h'
	, @collection_set_id		=@collection_set_id OUTPUT
	, @collection_set_uid		=@collection_set_uid OUTPUT

Select		@collection_set_id
		, @collection_set_uid

Select		@collector_type_uid = collector_type_uid 
From		[msdb].[dbo].[syscollector_collector_types] 
Where		name = N'Generic T-SQL Query Collector Type';

EXEC [msdb].[dbo].[sp_syscollector_create_collection_item] 
	@name				=N'Disk Usage - Data Files'
	, @collection_item_id		=@collection_item_id OUTPUT
	, @frequency			=60
	, @collection_set_id		=@collection_set_id
	, @collector_type_uid		=@collector_type_uid
	, @parameters			=N'<ns:TSQLQueryCollector xmlns:ns="DataCollectorType"><Query><Value>
DECLARE @dbsize bigint 
DECLARE @logsize bigint 
DECLARE @ftsize bigint 
DECLARE @reservedpages bigint 
DECLARE @pages bigint 
DECLARE @usedpages bigint

SELECT @dbsize = SUM(convert(bigint,case when type = 0 then size else 0 end)) 
      ,@logsize = SUM(convert(bigint,case when type = 1 then size else 0 end)) 
      ,@ftsize = SUM(convert(bigint,case when type = 4 then size else 0 end)) 
FROM sys.database_files

SELECT @reservedpages = SUM(a.total_pages) 
       ,@usedpages = SUM(a.used_pages) 
       ,@pages = SUM(CASE 
                        WHEN it.internal_type IN (202,204) THEN 0 
                        WHEN a.type != 1 THEN a.used_pages 
                        WHEN p.index_id &lt; 2 THEN a.data_pages 
                        ELSE 0 
                     END) 
FROM sys.partitions p  
JOIN sys.allocation_units a ON p.partition_id = a.container_id 
LEFT JOIN sys.internal_tables it ON p.object_id = it.object_id 

SELECT 
        @dbsize as ''dbsize'',
        @logsize as ''logsize'',
        @ftsize as ''ftsize'',
        @reservedpages as ''reservedpages'',
        @usedpages as ''usedpages'',
        @pages as ''pages''
</Value><OutputTable>disk_usage</OutputTable></Query><Databases UseSystemDatabases="true" UseUserDatabases="true" /></ns:TSQLQueryCollector>'

Select		@collection_item_id

Select		@collector_type_uid = collector_type_uid 
From		[msdb].[dbo].[syscollector_collector_types]
Where		name = N'Generic T-SQL Query Collector Type';

EXEC [msdb].[dbo].[sp_syscollector_create_collection_item] 
	@name				=N'Disk Usage - Log Files'
	, @collection_item_id		=@collection_item_id OUTPUT
	, @frequency			=60
	, @collection_set_id		=@collection_set_id
	, @collector_type_uid		=@collector_type_uid
	, @parameters			=N'<ns:TSQLQueryCollector xmlns:ns="DataCollectorType"><Query><Value>
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;
DECLARE @tran_log_space_usage table( 
        database_name sysname
,       log_size_mb float
,       log_space_used float
,       status int
); 
INSERT INTO @tran_log_space_usage 
EXEC(''DBCC SQLPERF (LOGSPACE) WITH NO_INFOMSGS'');
 
SELECT 
    database_name,
    log_size_mb,
    log_space_used,
    status    
FROM @tran_log_space_usage
</Value><OutputTable>log_usage</OutputTable></Query></ns:TSQLQueryCollector>'

Select		@collection_item_id














SET	@collection_set_uid	= '2DC02BD6-E230-4C05-8516-4E8C0EF21F95'

EXEC [msdb].[dbo].[sp_syscollector_create_collection_set] 
	@name				=N'Query Statistics'
	, @collection_mode		=0
	, @description			=N'Collects query statistics, T-SQL text, and query plans of most of the statements that affect performance. Enables analysis of poor performing queries in relation to overall SQL Server Database Engine activity.'
	, @logging_level		=2
	, @days_until_expiration	=30
	, @schedule_name		=N'CollectorSchedule_Every_15min'
	, @collection_set_id		=@collection_set_id OUTPUT
	, @collection_set_uid		=@collection_set_uid OUTPUT

Select		@collection_set_id
		, @collection_set_uid

Select		@collector_type_uid = collector_type_uid 
From		[msdb].[dbo].[syscollector_collector_types] 
Where		name = N'Query Activity Collector Type';

EXEC [msdb].[dbo].[sp_syscollector_create_collection_item] 
	@name				=N'Query Statistics - Query Activity'
	, @parameters			=N'<ns:QueryActivityCollector xmlns:ns="DataCollectorType"><Databases IncludeSystemDatabases="true" /></ns:QueryActivityCollector>'
	, @collection_item_id		=@collection_item_id OUTPUT
	, @frequency			=10
	, @collection_set_id		=@collection_set_id
	, @collector_type_uid		=@collector_type_uid

Select		@collection_item_id























SET	@collection_set_uid	= 'ABA37A22-8039-48C6-8F8F-39BFE0A195DF'

EXEC [msdb].[dbo].[sp_syscollector_create_collection_set] 
	@name				=N'Utility Information'
	, @collection_mode		=1
	, @description			=N'Collects data about instances of SQL Server that are managed in the SQL Server Utility.'
	, @logging_level		=2
	, @days_until_expiration	=30
	, @collection_set_id		=@collection_set_id OUTPUT
	, @collection_set_uid		=@collection_set_uid OUTPUT

Select		@collection_set_id
		, @collection_set_uid

Select		@collector_type_uid = collector_type_uid 
From		[msdb].[dbo].[syscollector_collector_types] 
Where		name = N'Generic T-SQL Query Collector Type';

EXEC [msdb].[dbo].[sp_syscollector_create_collection_item] 
	@name				=N'Utility Information - Managed Instance'
	, @collection_item_id		=@collection_item_id OUTPUT
	, @frequency			=900
	, @collection_set_id		=@collection_set_id
	, @collector_type_uid		=@collector_type_uid
	, @parameters			=N'<ns:TSQLQueryCollector xmlns:ns="DataCollectorType"><Query><Value>
         EXEC [msdb].[dbo].[sp_sysutility_mi_get_dac_execution_statistics_internal];
      </Value><OutputTable>sysutility_ucp_dac_collected_execution_statistics_internal</OutputTable></Query><Query><Value>
      -- Check for the existance of the temp table.  If it is there, then the Utility is
      -- set up correctly.  If it is not there, do not fail the upload.  This handles the
      -- case when a user might run the collection set out-of-band from the Utility.
      -- The data may not be staged, but no sporratic errors should occur
      DECLARE @batch_time datetimeoffset(7) = SYSDATETIMEOFFSET()
      IF OBJECT_ID (''[tempdb].[dbo].[sysutility_batch_time_internal]'') IS NOT NULL
      BEGIN
          SELECT @batch_time = latest_batch_time FROM tempdb.dbo.sysutility_batch_time_internal
      END
      SELECT 
         [server_instance_name],
         CAST(clustered_check.is_clustered_server AS SMALLINT) AS [is_clustered_server], 
         [virtual_server_name],
         [physical_server_name],
         [num_processors],
         [computer_processor_usage_percentage]  AS [server_processor_usage],
         [instance_processor_usage_percentage]  AS [instance_processor_usage],
         [cpu_name],
           [cpu_caption],
         [msdb].[dbo].[fn_sysutility_mi_get_cpu_family_name](cpu_family_id) AS [cpu_family],
         [msdb].[dbo].[fn_sysutility_mi_get_cpu_architecture_name](cpu_architecture_id) AS [cpu_architecture],
         [cpu_max_clock_speed],
         [cpu_clock_speed],
         [l2_cache_size],
         [l3_cache_size], 
         @batch_time AS [batch_time]
         FROM [msdb].[dbo].[sysutility_mi_cpu_stage_internal],
           (SELECT TOP 1 CAST (CASE WHEN COUNT(*) = 0 THEN 0 ELSE 1 END AS bit) AS is_clustered_server
            FROM msdb.sys.dm_os_cluster_nodes 
            WHERE NodeName = SERVERPROPERTY(''ComputerNamePhysicalNetBIOS'')) AS clustered_check
      </Value><OutputTable>sysutility_ucp_cpu_memory_configurations_internal</OutputTable></Query><Query><Value>
         -- Check for the existance of the temp table.  If it is there, then the Utility is
         -- set up correctly.  If it is not there, do not fail the upload.  This handles the
         -- case when a user might run the collection set out-of-band from the Utility.
         -- The data may not be staged, but no sporratic errors should occur
         DECLARE @batch_time datetimeoffset(7) = SYSDATETIMEOFFSET()
         IF OBJECT_ID (''[tempdb].[dbo].[sysutility_batch_time_internal]'') IS NOT NULL
         BEGIN
             SELECT @batch_time = latest_batch_time FROM tempdb.dbo.sysutility_batch_time_internal
         END
         SELECT 
            [volume_device_id],
            [volume_name],
            CAST([capacity_mb] AS REAL)   AS [total_space_available],
            CAST([free_space_mb] AS REAL) AS [free_space],
            [virtual_server_name],
            [physical_server_name],
            [server_instance_name], 
            @batch_time AS [batch_time]
         FROM [msdb].[dbo].[sysutility_mi_volumes_stage_internal]
      </Value><OutputTable>sysutility_ucp_volumes_internal</OutputTable></Query><Query><Value>
      -- Check for the existance of the temp table.  If it is there, then the Utility is
      -- set up correctly.  If it is not there, do not fail the upload.  This handles the
      -- case when a user might run the collection set out-of-band from the Utility.
      -- The data may not be staged, but no sporratic errors should occur
      DECLARE @batch_time datetimeoffset(7) = SYSDATETIMEOFFSET()
      IF OBJECT_ID (''[tempdb].[dbo].[sysutility_batch_time_internal]'') IS NOT NULL
      BEGIN
          SELECT @batch_time = latest_batch_time FROM tempdb.dbo.sysutility_batch_time_internal
      END
      
      SELECT 
         smo.[physical_server_name],
         smo.[server_instance_name],
         [object_type],
         [urn],
         [property_name],
         -- DC (SSIS, really) does not support sql_variant.  It will implicitly convert all variant columns to nvarchar(256), 
         -- which can cause data loss.  To avoid this we explicitly convert to nvarchar(4000) so that nothing gets truncated. 
         -- On the UCP, we reverse this conversion in sp_copy_live_table_data_into_cache_tables.  In order to round-trip the 
         -- data through nvarchar successfully, we must use the same language-independent conversion style on MI and UCP. We 
         -- use the shared fn_sysutility_get_culture_invariant_conversion_style_internal function to get a consistent 
         -- language-independent conversion style for each property data type.  (References: VSTS 361531, 359504, 12967)
         CONVERT 
         (
            nvarchar(4000), 
            CASE [property_name] 
               WHEN N''ProcessorUsage'' -- Hijack the ProcessorUsage property and insert our own value
               THEN CAST(cpu.[instance_processor_usage_percentage] AS INT)  -- loss of decimal places
               ELSE [property_value] 
            END, 
            msdb.dbo.fn_sysutility_get_culture_invariant_conversion_style_internal(CONVERT (varchar(30), SQL_VARIANT_PROPERTY (property_value, ''BaseType''))) 
         ) AS [property_value], 
         @batch_time AS [batch_time]
      FROM [msdb].[dbo].[sysutility_mi_smo_stage_internal] AS smo
      INNER JOIN [msdb].[dbo].[sysutility_mi_cpu_stage_internal] AS cpu 
         ON smo.[server_instance_name] = cpu.[server_instance_name]
      </Value><OutputTable>sysutility_ucp_smo_properties_internal</OutputTable></Query><!-- Query to collect/upload the batch manifest --><Query><Value>
        -- Check for the existance of the temp table.  If it is there, then the Utility is
        -- set up correctly.  If it is not there, do not fail the upload.  This handles the
        -- case when a user might run the collection set out-of-band from the Utility.
        -- The data may not be staged, but no sporratic errors should occur
        DECLARE @batch_time datetimeoffset(7) = SYSDATETIMEOFFSET()
        IF OBJECT_ID (''[tempdb].[dbo].[sysutility_batch_time_internal]'') IS NOT NULL
        BEGIN
          SELECT @batch_time = latest_batch_time FROM tempdb.dbo.sysutility_batch_time_internal
        END 
        SELECT CONVERT(SYSNAME, SERVERPROPERTY(N''ServerName'')) AS [server_instance_name],
            @batch_time AS [batch_time],
            bm.parameter_name,
            bm.parameter_value
        FROM [msdb].[dbo].[fn_sysutility_mi_get_batch_manifest]() bm  
    </Value><OutputTable>sysutility_ucp_batch_manifests_internal</OutputTable></Query></ns:TSQLQueryCollector>'
    
Select		@collection_item_id

GO


UPDATE [syscollector_collection_sets_internal] SET is_system = 1

EXEC [msdb].[dbo].[sp_syscollector_start_collection_set]  @name = 'Server Activity'
EXEC [msdb].[dbo].[sp_syscollector_start_collection_set]  @name = 'Disk Usage'
EXEC [msdb].[dbo].[sp_syscollector_start_collection_set]  @name = 'Query Statistics'

EXEC [msdb].[dbo].[sp_syscollector_run_collection_set]  @name = 'Disk Usage'
EXEC [msdb].[dbo].[sp_syscollector_run_collection_set]  @name = 'Utility Information'	

EXEC [msdb].[dbo].[sp_syscollector_upload_collection_set]  @name = 'Server Activity'
EXEC [msdb].[dbo].[sp_syscollector_upload_collection_set]  @name = 'Query Statistics'


--CREATE TABLE [tempdb].[dbo].[sysutility_batch_time_internal] ( 
--latest_batch_time datetimeoffset(7) PRIMARY KEY NOT NULL 

--) 