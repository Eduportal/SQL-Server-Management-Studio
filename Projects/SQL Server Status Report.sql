USE [dbaadmin]
GO
SET NOCOUNT ON
GO

---------------------------------------------------------------------------
---------------------------------------------------------------------------
--							SQL SERVER INFO
---------------------------------------------------------------------------
---------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#TempData') IS NOT NULL DROP TABLE #TempData
GO
---------------------------------------------------------------------------

SELECT		'<b>'+[Parameter]+'</b>' [Parameter]
			, [Value]
INTO		#TempData
FROM		(
			SELECT		'Server Name' [Parameter],			CAST(@@SERVERNAME AS VarChar(max)) [Value]
			UNION ALL
			SELECT		'SQL Server and OS Version Info',	CAST(@@VERSION AS VarChar(max))									
			UNION ALL
			SELECT		'MachineName',						CAST(SERVERPROPERTY('MachineName') AS VarChar(max))									
			UNION ALL
			SELECT		'ServerName',						CAST(SERVERPROPERTY('ServerName') AS VarChar(max))									
			UNION ALL
			SELECT		'Instance',							CAST(SERVERPROPERTY('InstanceName') AS VarChar(max))									
			UNION ALL
			SELECT		'IsClustered',						CAST(SERVERPROPERTY('IsClustered') AS VarChar(max))								
			UNION ALL
			SELECT		'ComputerNamePhysicalNetBIOS',		CAST(SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS VarChar(max))	
			UNION ALL
			SELECT		'Edition',							CAST(SERVERPROPERTY('Edition') AS VarChar(max))											
			UNION ALL
			SELECT		'ProductLevel',						CAST(SERVERPROPERTY('ProductLevel') AS VarChar(max))								
			UNION ALL
			SELECT		'ProductVersion',					CAST(SERVERPROPERTY('ProductVersion') AS VarChar(max))							
			UNION ALL
			SELECT		'ProcessID',						CAST(SERVERPROPERTY('ProcessID') AS VarChar(max))										
			UNION ALL
			SELECT		'Collation',						CAST(SERVERPROPERTY('Collation') AS VarChar(max))										
			UNION ALL
			SELECT		'IsFullTextInstalled',				CAST(SERVERPROPERTY('IsFullTextInstalled') AS VarChar(max))					
			UNION ALL
			SELECT		'IsIntegratedSecurityOnly',			CAST(SERVERPROPERTY('IsIntegratedSecurityOnly') AS VarChar(max))		
			UNION ALL
			SELECT		'SQL Server Install Date',			CAST(createdate AS VarChar(max)) 
			FROM		sys.syslogins WITH (NOLOCK) 
			WHERE		[sid] = 0x010100000000000512000000  
			) ServerData

---------------------------------------------------------------------------
SELECT [dbaadmin].[dbo].[dbaudf_FileAccess_Write]([dbaadmin].[dbo].[dbaudf_FormatTableToHTML] 
(
'#TempData'
,'MSSQLServer'
,'Microsoft SQL Server'
,'This gives you a lot of useful information about your instance of SQL Server'
,11
,1
),'C:\temp\table.html',0,1)
---------------------------------------------------------------------------
---------------------------------------------------------------------------


---------------------------------------------------------------------------
---------------------------------------------------------------------------
--							SQL SERVICE INFO
---------------------------------------------------------------------------
---------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#TempData') IS NOT NULL DROP TABLE #TempData
GO
---------------------------------------------------------------------------

SELECT		*
INTO		#TempData
FROM		sys.dm_server_services WITH (NOLOCK) 

---------------------------------------------------------------------------
SELECT [dbaadmin].[dbo].[dbaudf_FileAccess_Write]([dbaadmin].[dbo].[dbaudf_FormatTableToHTML] ('#TempData'
,'SQLServices'
,'SQL Services'
,'Microsoft SQL Server Services: Tells you the account being used for the SQL Server Service and the SQL Agent Service. Shows when they were last started, and their current status. Shows whether you are running on a failover cluster.'
,11
,1
),'C:\temp\table.html',1,1)
---------------------------------------------------------------------------
---------------------------------------------------------------------------



---------------------------------------------------------------------------
---------------------------------------------------------------------------
--							SQL SERVER NUMA NODE INFORMATION
---------------------------------------------------------------------------
---------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#TempData') IS NOT NULL DROP TABLE #TempData
GO
---------------------------------------------------------------------------

SELECT		node_id							[node id]
			,node_state_desc				[node state]
			,memory_node_id					[memory node id]
			,cpu_affinity_mask				[cpu affinity mask]
			,online_scheduler_count			[online scheduler count]
			,idle_scheduler_count			[idle scheduler count]
			,active_worker_count			[active worker count]
			,avg_load_balance				[avg load balance]
			,timer_task_affinity_mask		[timer task affinity mask]
			,permanent_task_affinity_mask	[permanent task affinity mask]
			,resource_monitor_state			[resource monitor state]
			,online_scheduler_mask			[online scheduler mask]
			,processor_group				[processor group]
INTO		#TempData
FROM		sys.dm_os_nodes WITH (NOLOCK) 

---------------------------------------------------------------------------
SELECT [dbaadmin].[dbo].[dbaudf_FileAccess_Write]([dbaadmin].[dbo].[dbaudf_FormatTableToHTML] ('#TempData'
,'NUMANodeInfo'
,'SQL Server NUMA Node information'
,'SQL Server NUMA Node information: Gives you some useful information about the composition and relative load on your NUMA nodes.'
,11
,1
),'C:\temp\table.html',1,1)
---------------------------------------------------------------------------
---------------------------------------------------------------------------


---------------------------------------------------------------------------
---------------------------------------------------------------------------
--							SQL CLUSTER INFO
---------------------------------------------------------------------------
---------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#TempData') IS NOT NULL DROP TABLE #TempData
GO
---------------------------------------------------------------------------

SELECT		*
INTO		#TempData
FROM		sys.dm_os_cluster_nodes WITH (NOLOCK) 

---------------------------------------------------------------------------
SELECT [dbaadmin].[dbo].[dbaudf_FileAccess_Write]([dbaadmin].[dbo].[dbaudf_FormatTableToHTML] ('#TempData'
,'SQLCluster'
,'SQL Server Cluster'
,'Microsoft SQL Server Cluster: Knowing which node owns the cluster resources is critical Especially when you are installing Windows or SQL Server updates. You will see no results if your instance is not clustered.'
,11
,1
),'C:\temp\table.html',1,1)
---------------------------------------------------------------------------
---------------------------------------------------------------------------


---------------------------------------------------------------------------
---------------------------------------------------------------------------
--							SQL CONFIGURATION INFO
---------------------------------------------------------------------------
---------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#TempData') IS NOT NULL DROP TABLE #TempData
GO
---------------------------------------------------------------------------

SELECT		name [Parameter]
			,CAST(value AS VarChar(max)) + CASE WHEN value != value_in_use THEN ' (' + CAST(value_in_use AS VarChar(max)) + ')' ELSE '' END [Value]
INTO		#TempData
FROM		sys.configurations WITH (NOLOCK)
ORDER BY	name OPTION (RECOMPILE);

---------------------------------------------------------------------------
SELECT [dbaadmin].[dbo].[dbaudf_FileAccess_Write]([dbaadmin].[dbo].[dbaudf_FormatTableToHTML] ('#TempData'
,'SQLConfig'
,'SQL Server Configuration'
,'Microsoft SQL Server Configurations: Get configuration values for instance. Focus on backup compression default, clr enabled (only enable if it is needed), lightweight pooling (should be zero), max degree of parallelism (depends on your workload), max server memory (MB) (set to an appropriate value), optimize for ad hoc workloads (should be 1), priority boost (should be zero)'
,11
,1
),'C:\temp\table.html',1,1)
---------------------------------------------------------------------------
---------------------------------------------------------------------------


---------------------------------------------------------------------------
---------------------------------------------------------------------------
--							OS INFO
---------------------------------------------------------------------------
---------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#TempData') IS NOT NULL DROP TABLE #TempData
GO
---------------------------------------------------------------------------

SELECT		*
INTO		#TempData
FROM		sys.dm_os_windows_info WITH (NOLOCK)

---------------------------------------------------------------------------
SELECT [dbaadmin].[dbo].[dbaudf_FileAccess_Write]([dbaadmin].[dbo].[dbaudf_FormatTableToHTML] ('#TempData'
,'WindowsOS'
,'Windows Operating System'
,'Microsoft Windows Operating System Information: Gives you major OS version, Service Pack, Edition, and language info for the operating system.'
,11
,1
),'C:\temp\table.html',1,1)
---------------------------------------------------------------------------
---------------------------------------------------------------------------


---------------------------------------------------------------------------
---------------------------------------------------------------------------
--							HARDWARE INFO
---------------------------------------------------------------------------
---------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#TempData') IS NOT NULL DROP TABLE #TempData
GO
---------------------------------------------------------------------------

SELECT		cpu_ticks	
			,ms_ticks	
			,cpu_count															[cpu count]
			,hyperthread_ratio													[hyperthread ratio]
			,CAST(physical_memory_in_bytes/POWER(1024.,3) AS NUMERIC(10,2))		[Phys. Mem GB]	 
			,CAST(virtual_memory_in_bytes/POWER(1024.,3) AS NUMERIC(10,2))		[Virt. Mem GB]
			,CAST(bpool_committed/POWER(1024.,2) AS NUMERIC(10,2))				[bpool commit MB]
			,CAST(bpool_commit_target/POWER(1024.,2) AS NUMERIC(10,2))			[bpool commit target MB]
			,CAST(bpool_visible/POWER(1024.,2) AS NUMERIC(10,2))				[bpool visible MB]
			,CAST(stack_size_in_bytes/POWER(1024.,2) AS NUMERIC(10,2))			[stack size MB]
			,os_quantum															[OS quantum]
			,os_error_mode														[OS error mode]
			,os_priority_class													[os priority class]
			,max_workers_count													[max worker count]
			,scheduler_count													[scheduler count]
			,scheduler_total_count												[scheduler total count]
			,deadlock_monitor_serial_number										[deadlock monitor serial number]
			,sqlserver_start_time_ms_ticks										[start time memory ticks]
			,sqlserver_start_time												[start time]
			--,affinity_type													[affinity type]
			,affinity_type_desc													[affinity type desc]
			,process_kernel_time_ms												[kernel time ms]
			,process_user_time_ms												[user time ms]
			--,time_source														[time source]
			,time_source_desc													[time source desc]
			--,virtual_machine_type												[vm type]
			,virtual_machine_type_desc											[vm type desc]
INTO		#TempData
FROM		sys.dm_os_sys_info WITH (NOLOCK)

---------------------------------------------------------------------------
SELECT [dbaadmin].[dbo].[dbaudf_FileAccess_Write]([dbaadmin].[dbo].[dbaudf_FormatTableToHTML] ('#TempData'
,'ServerHardware'
,'Server Hardware Information'
,'Server Hardware Information: Gives you some good basic hardware information about your database server.'
,11
,1
),'C:\temp\table.html',1,1)
---------------------------------------------------------------------------
---------------------------------------------------------------------------


---------------------------------------------------------------------------
---------------------------------------------------------------------------
--							CPU INFO
---------------------------------------------------------------------------
---------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#TempData') IS NOT NULL DROP TABLE #TempData
GO
---------------------------------------------------------------------------

Create Table #TempData ([Property] sysname, [Value] varchar(max))

INSERT INTO #TempData (Property,Value)
EXEC xp_instance_regread 
'HKEY_LOCAL_MACHINE', 'HARDWARE\DESCRIPTION\System\CentralProcessor\0',
'ProcessorNameString';

---------------------------------------------------------------------------
SELECT [dbaadmin].[dbo].[dbaudf_FileAccess_Write]([dbaadmin].[dbo].[dbaudf_FormatTableToHTML] ('#TempData'
,'CPUInfo'
,'CPU Information'
,'CPU Information: Get processor description from Windows Registry. Gives you the model number and rated clock speed of your processor(s). Your processors may be running at less that the rated clock speed due to the Windows Power Plan or hardware power management.'
,11
,1
),'C:\temp\table.html',1,1)
---------------------------------------------------------------------------
---------------------------------------------------------------------------


---------------------------------------------------------------------------
---------------------------------------------------------------------------
--							DRIVE INFO
---------------------------------------------------------------------------
---------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#TempData') IS NOT NULL DROP TABLE #TempData
GO
---------------------------------------------------------------------------

SELECT		LD.DriveLetter
			,CAST(LD.TotalSize/POWER(1024.,3) AS NUMERIC(10,2))				[Total Size GB]
			,CAST(LD.AvailableSpace/POWER(1024.,3) AS NUMERIC(10,2))		[Available Space GB]
			,CAST(DBDriveData.Size AS NUMERIC(10,2))						[Used DB GB]
			,CAST((LD.TotalSize/POWER(1024.,3))
				-(DBDriveData.Size)
				-(LD.AvailableSpace/POWER(1024.,3)) AS NUMERIC(10,2))		[Used NonDB GB]
			,CAST((LD.AvailableSpace*100.0)/LD.TotalSize AS NUMERIC(10,2))	[% Free]	
			,LD.DriveType [Drive Type]	
			,LD.FileSystem	[File System]
			,LD.IsReady	[Ready]
			,LD.VolumeName [Volume]
			,DBDriveData.DBNames [DB Names]
INTO		#TempData
FROM		dbaadmin.dbo.dbaudf_ListDrives() LD
JOIN		(
			SELECT		[DriveLetter]
						,SUM([Size]) [Size]
						,REPLACE(dbaadmin.[dbo].[dbaudf_ConcatenateUnique]([DB_Name]+':'+Type_desc+'('+ CAST(CAST([Size] AS NUMERIC(10,2)) AS VarChar(50)) + ') '),'.00)',')') [DBNames]
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


---------------------------------------------------------------------------
SELECT [dbaadmin].[dbo].[dbaudf_FileAccess_Write]([dbaadmin].[dbo].[dbaudf_FormatTableToHTML] ('#TempData'
,'DriveInfo'
,'Drive Information'
,'Disk Drive Information: Volume info for all databases on the current instance. Shows you the free space on the LUNs where you have database data or log files. Things to look at: Are data files and log files on different drives?, Is everything on the C: drive?, Is TempDB on dedicated drives?, Is there only one TempDB data file?, Are all of the TempDB data files the same size?, Are there multiple data files for user databases?'
,11
,1
),'C:\temp\table.html',1,1)
---------------------------------------------------------------------------
---------------------------------------------------------------------------



---------------------------------------------------------------------------
---------------------------------------------------------------------------
--							DATABASE INFO
---------------------------------------------------------------------------
---------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#TempData') IS NOT NULL DROP TABLE #TempData
GO
---------------------------------------------------------------------------

SELECT		db.[name] AS [Database Name]
			,db.recovery_model_desc AS [Recovery Model]
			,db.log_reuse_wait_desc AS [Log Reuse Wait Description]
			,ls.cntr_value AS [Log Size (KB)]
			,lu.cntr_value AS [Log Used (KB)]
			,CAST(CAST(lu.cntr_value AS FLOAT) / CAST(ls.cntr_value AS FLOAT)AS DECIMAL(18,2)) * 100 AS [Log Used %]
			,db.[compatibility_level] AS [DB Compatibility Level]
			,db.page_verify_option_desc AS [Page Verify Option]
			,db.is_auto_create_stats_on [auto create stats]
			,db.is_auto_update_stats_on [auto update stats]
			,db.is_auto_update_stats_async_on [auto update stats async]
			,db.is_parameterization_forced [forced params]
			,db.snapshot_isolation_state_desc [snapshot isolation]
			,db.is_read_committed_snapshot_on [read committed snapshot]
			,db.is_auto_close_on [auto close]
			,db.is_auto_shrink_on [auto shrink]
			,db.is_cdc_enabled [cdc enabled]
INTO		#TempData
FROM		sys.databases AS db WITH (NOLOCK)
JOIN		sys.dm_os_performance_counters AS lu WITH (NOLOCK)
		ON	db.name = lu.instance_name
JOIN		sys.dm_os_performance_counters AS ls WITH (NOLOCK) 
		ON	db.name = ls.instance_name
WHERE		lu.counter_name LIKE N'Log File(s) Used Size (KB)%' 
		AND	ls.counter_name LIKE N'Log File(s) Size (KB)%'
		AND	ls.cntr_value > 0 
OPTION (RECOMPILE);

---------------------------------------------------------------------------
SELECT [dbaadmin].[dbo].[dbaudf_FileAccess_Write]([dbaadmin].[dbo].[dbaudf_FormatTableToHTML] ('#TempData'
,'DBInfo'
,'Database Information'
,'SQL Server Database Settings: Recovery model, log reuse wait description, log file size, log usage size and compatibility level for all databases on instance. Things to look at: How many databases are on the instance?, What recovery models are they using?, What is the log reuse wait description?, How full are the transaction logs ?, What compatibility level are they on?, What is the Page Verify Option?, Make sure auto_shrink and auto_close are not enabled!'
,11
,1
),'C:\temp\table.html',1,1)
---------------------------------------------------------------------------
---------------------------------------------------------------------------

---------------------------------------------------------------------------
---------------------------------------------------------------------------
--							DATABASE RESOURCE USAGE INFO
---------------------------------------------------------------------------
---------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#TempData') IS NOT NULL DROP TABLE #TempData
GO
---------------------------------------------------------------------------

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
			,T2.[CPU Rank]
			,T2.[CPU Time Ms]
			,T2.[CPU %]
			,T1.[I/O Rank]
			,T1.[Total I/O (MB)]
			,T1.[I/O %]
			,T3.[Cache Rank]
			,T3.[Cached Size (MB)]
INTO		#TempData
FROM		DB_IO_Totals T1
LEFT JOIN	DB_CPU_Totals T2
		ON	T2.[Database Name] = T1.[Database Name]
LEFT JOIN	DB_Buffer_Totals T3
		ON	T3.[Database Name] = T1.[Database Name]
ORDER BY	T1.[Database Name]
OPTION (RECOMPILE);

---------------------------------------------------------------------------
SELECT [dbaadmin].[dbo].[dbaudf_FileAccess_Write]([dbaadmin].[dbo].[dbaudf_FormatTableToHTML] ('#TempData'
,'DBResourceUsage'
,'Database Resource Usage'
,'Database Resource Usage: CPU utilization by database Helps determine which database is using the most CPU resources on the instance. I/O utilization by database helps determine which database is using the most I/O resources on the instance. Buffer usage by database helps determine which database is using the most Buffer Cache resources on the instance. This make take some time to run on a busy instance.'
,11
,1
),'C:\temp\table.html',1,1)
---------------------------------------------------------------------------
---------------------------------------------------------------------------


---------------------------------------------------------------------------
---------------------------------------------------------------------------
--							TEMPDB USAGE INFO
---------------------------------------------------------------------------
---------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#TempData') IS NOT NULL DROP TABLE #TempData
GO
---------------------------------------------------------------------------


SELECT		session_id [SPID]
			,command [Command]
			,host_name [Host Name]
			,statement_text [Statement Text]
			,User_Obj_UsedSpace-User_Obj_FreeSpace [Unreleased UserObj Space]
			,Int_Obj_UsedSpace-Int_Obj_FreeSpace [Unreleased IntObj Space]
			,User_Obj_UsedSpace [Used UsrObj Space]
			,User_Obj_FreeSpace [Free UsrObj Space]
			,Int_Obj_UsedSpace [Used IntObj Space]
			,Int_Obj_FreeSpace [Free IntObj Space]
INTO		#TempData
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
ORDER BY	5 desc
			,6 desc

---------------------------------------------------------------------------
SELECT [dbaadmin].[dbo].[dbaudf_FileAccess_Write]([dbaadmin].[dbo].[dbaudf_FormatTableToHTML] ('#TempData'
,'TempDBUsage'
,'TempDB Usage'
,'TempDB Usage: Identify the SPIDs, Hosts, and Queries that are using the majority of the space in TempDB. This is helpful to identify what SPID can be killed in order to prevent TempDB from filling up compleatly and causing Server Errors.'
,11
,1
),'C:\temp\table.html',1,1)
---------------------------------------------------------------------------
---------------------------------------------------------------------------

---------------------------------------------------------------------------
---------------------------------------------------------------------------
--							MISSING INDEX INFO
---------------------------------------------------------------------------
---------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#TempData') IS NOT NULL DROP TABLE #TempData
GO
---------------------------------------------------------------------------

SELECT		CONVERT(decimal(18,2),user_seeks * avg_total_user_cost * (avg_user_impact * 0.01)) AS [index advantage]
			,DB_NAME(mid.database_id) AS [Database Name]
			,OBJECT_NAME(mid.object_id,mid.database_id) AS [Table Name]
			, mid.[statement] AS [Database Schema Table]
			,migs.last_user_seek [last user seek]
			,mid.equality_columns [equality columns]
			,mid.inequality_columns [inequality columns]
			,mid.included_columns [included columns]
			,migs.unique_compiles [unique compiles]
			,migs.user_seeks [user seeks]
			,migs.avg_total_user_cost [avg total user cost]
			,migs.avg_user_impact [avg user impact]
INTO		#TempData
FROM		sys.dm_db_missing_index_group_stats AS migs WITH (NOLOCK)
JOIN		sys.dm_db_missing_index_groups AS mig WITH (NOLOCK)
	ON		migs.group_handle = mig.index_group_handle
JOIN		sys.dm_db_missing_index_details AS mid WITH (NOLOCK)
	ON		mig.index_handle = mid.index_handle
ORDER BY	1 DESC OPTION (RECOMPILE);

---------------------------------------------------------------------------
SELECT [dbaadmin].[dbo].[dbaudf_FileAccess_Write]([dbaadmin].[dbo].[dbaudf_FormatTableToHTML] ('#TempData'
,'MissingIDX'
,'Missing Indexes'
,'Missing Indexes for all databases by Index Advantage: Getting missing index information for all of the databases on the instance is very useful. Look at last user seek time, number of user seeks to help determine source and importance. SQL Server is overly eager to add included columns, so beware and do not just blindly add indexes that show up from this query!!!.'
,11
,1
),'C:\temp\table.html',1,1)
---------------------------------------------------------------------------
---------------------------------------------------------------------------

---------------------------------------------------------------------------
---------------------------------------------------------------------------
--							VLF INFO
---------------------------------------------------------------------------
---------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#TempData') IS NOT NULL DROP TABLE #TempData
GO
---------------------------------------------------------------------------

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

---------------------------------------------------------------------------
SELECT [dbaadmin].[dbo].[dbaudf_FileAccess_Write]([dbaadmin].[dbo].[dbaudf_FormatTableToHTML] ('#VLFCountResults'
,'VLFCnt'
,'VLF Counts'
,'Get VLF Counts for all databases on the instance: High VLF counts can affect write performance and they can make database restores and recovery take much longer.'
,11
,1
),'C:\temp\table.html',1,1)
---------------------------------------------------------------------------
---------------------------------------------------------------------------
	 
DROP TABLE #VLFInfo;
DROP TABLE #VLFCountResults;

---------------------------------------------------------------------------
---------------------------------------------------------------------------
--							IO STALLS BY FILE
---------------------------------------------------------------------------
---------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#TempData') IS NOT NULL DROP TABLE #TempData
GO
---------------------------------------------------------------------------

SELECT		DB_NAME(fs.database_id) AS [Database Name]
			,mf.physical_name [Physical Name]
			,io_stall_read_ms [IO Stall Read ms]
			,num_of_reads [Number of Reads]
			,CAST(io_stall_read_ms/(1.0 + num_of_reads) AS NUMERIC(10,1)) AS [avg Read Stall ms]
			,io_stall_write_ms [IO Stall Write ms]
			,num_of_writes,CAST(io_stall_write_ms/(1.0+num_of_writes) AS NUMERIC(10,1)) AS [avg Write Stall ms]
			,io_stall_read_ms + io_stall_write_ms AS [IO Stalls]
			,num_of_reads + num_of_writes AS [IO Total]
			,CAST((io_stall_read_ms + io_stall_write_ms)/(1.0 + num_of_reads + num_of_writes) AS NUMERIC(10,1)) AS [avg IO Stall ms]
INTO		#TempData
FROM		sys.dm_io_virtual_file_stats(null,null) AS fs
JOIN		sys.master_files AS mf WITH (NOLOCK)
		ON	fs.database_id = mf.database_id
		AND	fs.[file_id] = mf.[file_id]
ORDER BY	11 DESC 
OPTION (RECOMPILE);

---------------------------------------------------------------------------
SELECT [dbaadmin].[dbo].[dbaudf_FileAccess_Write]([dbaadmin].[dbo].[dbaudf_FormatTableToHTML] ('#TempData'
,'IOStalls'
,'IO Stalls By File'
,'IO Stalls: Calculates average stalls per read, per write, and per total input/output for each database file. Helps you determine which database files on the entire instance have the most I/O bottlenecks. This can help you decide whether certain LUNs are overloaded and whether you might want to move some files to a different location.'
,11
,1
),'C:\temp\table.html',1,1)
---------------------------------------------------------------------------
---------------------------------------------------------------------------


---------------------------------------------------------------------------
---------------------------------------------------------------------------
--							TOP WAITS
---------------------------------------------------------------------------
---------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#TempData') IS NOT NULL DROP TABLE #TempData
GO
---------------------------------------------------------------------------

;WITH		Waits 
			AS
			(
			SELECT		wait_type
						,wait_time_ms / 1000. AS wait_time_s
						,100. * wait_time_ms / SUM(wait_time_ms) OVER() AS pct
						,ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS rn
			FROM		sys.dm_os_wait_stats WITH (NOLOCK)
			WHERE		wait_type NOT IN	(N'CLR_SEMAPHORE',N'LAZYWRITER_SLEEP',N'RESOURCE_QUEUE',N'SLEEP_TASK',
											N'SLEEP_SYSTEMTASK',N'SQLTRACE_BUFFER_FLUSH',N'WAITFOR', N'LOGMGR_QUEUE',N'CHECKPOINT_QUEUE',
											N'REQUEST_FOR_DEADLOCK_SEARCH',N'XE_TIMER_EVENT',N'BROKER_TO_FLUSH',N'BROKER_TASK_STOP',N'CLR_MANUAL_EVENT',
											N'CLR_AUTO_EVENT',N'DISPATCHER_QUEUE_SEMAPHORE', N'FT_IFTS_SCHEDULER_IDLE_WAIT',
											N'XE_DISPATCHER_WAIT', N'XE_DISPATCHER_JOIN', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
											N'ONDEMAND_TASK_QUEUE', N'BROKER_EVENTHANDLER', N'SLEEP_BPOOL_FLUSH')
			)
SELECT		W1.wait_type [Wait Type]
			,CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS [Wait Time Seconds]
			,CAST(W1.pct AS DECIMAL(12, 2)) AS [Wait Percent]
			,CAST(SUM(W2.pct) AS DECIMAL(12, 2)) AS [Running Percent]
INTO		#TempData
FROM		Waits AS W1
JOIN		Waits AS W2
		ON	W2.rn <= W1.rn
GROUP BY	W1.rn
			,W1.wait_type
			,W1.wait_time_s
			,W1.pct
HAVING		SUM(W2.pct) - W1.pct < 99 OPTION (RECOMPILE); -- percentage threshold

---------------------------------------------------------------------------
SELECT [dbaadmin].[dbo].[dbaudf_FileAccess_Write]([dbaadmin].[dbo].[dbaudf_FormatTableToHTML] ('#TempData'
,'TopWaits'
,'Top Waits'
,'<table class="SummaryRow">
<tr><td colspan="3">Top Waits: Isolate top waits for server instance since last restart or statistics clear.Common Significant Wait types with BOL explanations</td></tr>
<tr><td colspan="3">&nbsp;</td></tr>
<tr><td colspan="3">*** Network Related Waits ***</td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td>ASYNC_NETWORK_IO</td><td>Occurs on network writes when the task is blocked behind the network</td></tr>
<tr><td colspan="3">&nbsp;</td></tr>
<tr><td colspan="3">*** Locking Waits ***</td></tr>
<tr><td>&nbsp;</td><td>LCK_M_IX</td><td>Occurs when a task is waiting to acquire an Intent Exclusive (IX) lock
<tr><td>&nbsp;</td><td>LCK_M_IU</td><td>Occurs when a task is waiting to acquire an Intent Update (IU) lock
<tr><td>&nbsp;</td><td>LCK_M_S</td><td>Occurs when a task is waiting to acquire a Shared lock
<tr><td colspan="3">&nbsp;</td></tr>
<tr><td colspan="3">*** I/O Related Waits ***</td></tr>
<tr><td>&nbsp;</td><td>ASYNC_IO_COMPLETION</td><td>Occurs when a task is waiting for I/Os to finish</td></tr>
<tr><td>&nbsp;</td><td>IO_COMPLETION</td><td>Occurs while waiting for I/O operations to complete. This wait type generally represents non-data page I/Os. Data page I/O completion waits appear as PAGEIOLATCH_* waits</td></tr>
<tr><td>&nbsp;</td><td>PAGEIOLATCH_SH</td><td>Occurs when a task is waiting on a latch for a buffer that is in an I/O request. The latch request is in Shared mode. Long waits may indicate problems with the disk subsystem.</td></tr>
<tr><td>&nbsp;</td><td>PAGEIOLATCH_EX</td><td>Occurs when a task is waiting on a latch for a buffer that is in an I/O request. The latch request is in Exclusive mode. Long waits may indicate problems with the disk subsystem.</td></tr>
<tr><td>&nbsp;</td><td>WRITELOG</td><td>Occurs while waiting for a log flush to complete. Common operations that cause log flushes are checkpoints and transaction commits.</td></tr>
<tr><td>&nbsp;</td><td>PAGELATCH_EX</td><td>Occurs when a task is waiting on a latch for a buffer that is not in an I/O request. The latch request is in Exclusive mode.</td></tr>
<tr><td>&nbsp;</td><td>BACKUPIO</td><td>Occurs when a backup task is waiting for data, or is waiting for a buffer in which to store data.</td></tr>
<tr><td colspan="3">&nbsp;</td></tr>
<tr><td colspan="3">*** CPU Related Waits ***</td></tr>
<tr><td>&nbsp;</td><td>SOS_SCHEDULER_YIELD</td><td>Occurs when a task voluntarily yields the scheduler for other tasks to execute. During this wait the task is waiting for its quantum to be renewed.</td></tr>
<tr><td>&nbsp;</td><td>THREADPOOL</td><td>Occurs when a task is waiting for a worker to run on. This can indicate that the maximum worker setting is too low, or that batch executions are taking unusually long, thus reducing the number of workers available to satisfy other batches.</td></tr>
<tr><td>&nbsp;</td><td>CX_PACKET</td><td>Occurs when trying to synchronize the query processor exchange iterator You may consider lowering the degree of parallelism if contention on this wait type becomes a problem often caused by missing indexes or poorly written queries.</td></tr>
</font></table>'
,11
,1
),'C:\temp\table.html',1,1)
---------------------------------------------------------------------------
---------------------------------------------------------------------------

DECLARE	@HTMLOutput				VarChar(max)
		,@TitleString			VarChar(max)
		,@InputValidation		Bit
		,@InputValidationMsg	VarChar(max)
		,@SeriesString			VarChar(max)
		,@ColumnString			VarChar(max)


SELECT	@HTMLOutput				= ''
		,@TitleString			= 'CPU History'
		,@InputValidation		= 0
		,@InputValidationMsg	= ''
		,@SeriesString			= '1:{type: "area"}, 2:{type: "area"}'
		,@ColumnString			= '0,1,2,3'

	SELECT		@HTMLOutput = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <title>
      Getty Images Opperations Report
    </title>
    <script type="text/javascript" src="http://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load(''visualization'', ''1'', {packages: [''table'',''corechart'']});
    </script>
    <script type="text/javascript">
      function drawVisualization() {
        // Create and populate the data table.
        var data = new google.visualization.DataTable();
        data.addColumn(''datetime'', ''Event'');
        data.addColumn(''number'', ''SQL'');
        data.addColumn(''number'', ''IDLE'');
        data.addColumn(''number'', ''OTHER'');
        data.addRows(['+CHAR(13)+CHAR(10)


-- Get CPU Utilization History for last 256 minutes (in one minute intervals)  (Query 27) (CPU Utilization History)
-- This version works with SQL Server 2008 and SQL Server 2008 R2 only
DECLARE @ts_now bigint = (SELECT cpu_ticks/(cpu_ticks/ms_ticks)FROM sys.dm_os_sys_info); 

SELECT		TOP(256)
			@HTMLOutput		= @HTMLOutput
							+ '            [ new Date(' + REPLACE(REPLACE(REPLACE(CONVERT(VarChar(50),DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()),120),'-',','),' ',','),':',',')
							+ '),'	+ CAST(COALESCE([SQLProcessUtilization],'')							AS VarChar(50))
							+ ','	+ CAST(COALESCE([SystemIdle],'')									AS VarChar(50))
							+ ','	+ CAST(COALESCE(100 - [SystemIdle] - [SQLProcessUtilization],'')	AS VarChar(50))
							+ '],'	+CHAR(13)+CHAR(10) 
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


	SELECT		@HTMLOutput = @HTMLOutput +'      ]);
		var chart1		= new google.visualization.AreaChart(document.getElementById(''chart1''));
		var options1	= {isStacked: true, 
							height: 400, 
							legend: "bottom", 
							title: '''+@TitleString+''',
							vAxis: {title: "% CPU"},
							hAxis: {title: "Date"}
							};
		
		var table		= new google.visualization.Table(document.getElementById(''table''));
		var dataView	= new google.visualization.DataView(data);
		
        // Create and draw the visualization.
		dataView.setColumns(['+@ColumnString+']);
        chart1.draw(data, options1);  
		table.draw(data, null);
        }
	function ShowHide(divId) 
		{
		if(document.getElementById(divId).style.display == ''none'')
			{
			document.getElementById(divId).style.display=''block'';
			}
		else
			{
			document.getElementById(divId).style.display = ''none'';
			}
		drawVisualization;
		}
      google.setOnLoadCallback(drawVisualization);
    </script>
  </head>
  <body style="font-family: Arial;border: 0 none;">
    <div id="chart1" style="width:90%; height: 400px;"></div>
	<input id="ShowHideData" type="button" value="Show/Hide Data" onclick="ShowHide(''table'')" />
	<div id="table" style="DISPLAY: none"></div>
	<div id="chart2" style="width:90%; height: 200px;"></div>
 </body>
</html>'


SELECT [dbaadmin].[dbo].[dbaudf_FileAccess_Write](@HTMLOutput,'C:\temp\table.html',1,1)


---------------------------------------------------------------------------
---------------------------------------------------------------------------
--							Job Durations
---------------------------------------------------------------------------
---------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#TempData') IS NOT NULL DROP TABLE #TempData
GO
---------------------------------------------------------------------------


;WITH		JobData
			AS
			(
			SELECT		TOP 100 PERCENT
						t2.name [JobName]
						,ROW_NUMBER() OVER( PARTITION BY t2.name ORDER BY [dbaadmin].[dbo].[dbaudf_AgentDateTime2DateTime] (T1.run_date,T1.run_time)) [RowNum]
						--,[dbaadmin].[dbo].[dbaudf_AgentDateTime2DateTime] (T1.run_date,T1.run_time) [RunDate]
						,CAST(t1.run_duration AS VarChar(50)) [Duration]
			FROM		msdb..sysjobhistory T1
			JOIN		msdb..sysjobs T2
					ON	T1.job_id = T2.job_id
			WHERE		T1.step_id = 0
			ORDER BY	1,2
			)

SELECT		[JobName]
			, dbaadmin.dbo.dbaudf_SparklineChart([JobName],[dbaadmin].[dbo].[dbaudf_Concatenate]([Duration])) [Job Durrations]
INTO		#TempData
FROM		JobData
GROUP BY	[JobName]
ORDER BY	[JobName]

SELECT [dbaadmin].[dbo].[dbaudf_FileAccess_Write]([dbaadmin].[dbo].[dbaudf_FormatTableToHTML] ('#TempData'
,'JobDur'
,'Agent Job Durration History'
,'This shows a general trend for agent job run time durrations.'
,11
,1
),'C:\temp\table.html',1,1)
