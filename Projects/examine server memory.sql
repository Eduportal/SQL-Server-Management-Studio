

exec sp_configure 'clr enabled' , 0
GO
RECONFIGURE WITH OVERRIDE
GO
dbcc FREEPROCCACHE

DBCC FREESYSTEMCACHE ('ALL') WITH MARK_IN_USE_FOR_REMOVAL;

DBCC FREESESSIONCACHE 

DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS



dbcc memorystatus

DBCC sqlmgrstats 

DBCC stackdump



dbcc proccache 
DBCC memusage 




DBCC mscorwks (FREE)





















select * from dbo.DMV_Memory_Clerks_log
where rundate > getdate()-1
order by type, rundate desc






select name, count(*) 
from sys.dm_os_memory_cache_entries 

group by name

order by count(*) desc ;


SELECT convert(varchar,getdate(),120) as [Timestamp], 
max(region_size_in_bytes)/1024 [Total max contiguous block size in KB] 
from sys.dm_os_virtual_address_dump 
where region_state = 0x00010000 --- MEM_FREE   





SELECT		lm.[base_address]
		, lm.NAME
		, SUM(vad.region_size_in_bytes)/1024 AS [Mem kb] 
FROM		[dbaadmin].sys.dm_os_loaded_modules lm
INNER JOIN	[sys].[dm_os_virtual_address_dump] vad
	ON	lm.[base_address] = vad.[region_allocation_base_address]
where		name like (SELECT Value+'%' FROM [dbaadmin].[sys].[dm_clr_properties] WHERE name = 'directory')
GROUP BY	lm.[base_address], lm.[name]
ORDER BY	3 DESC
GO


;WITH		VAS_Summary
		AS
		(
		SELECT		VAS_Dump.Size AS [SIZE]
				,SUM(CASE(CONVERT(INT, VAS_Dump.Base)^0) WHEN 0 THEN 0 ELSE 1 END) AS [Reserved]
				,SUM(CASE(CONVERT(INT, VAS_Dump.Base)^0) WHEN 0 THEN 1 ELSE 0 END) AS [Free]
		FROM		(
				SELECT		CONVERT(VARBINARY, SUM(region_size_in_bytes))	AS [Size]
						,region_allocation_base_address			AS [Base]
				FROM		sys.dm_os_virtual_address_dump
				WHERE		region_allocation_base_address <> 0x0
				GROUP BY	region_allocation_base_address
				UNION ALL
				SELECT		CONVERT(VARBINARY, region_size_in_bytes)	AS [Size]
						,region_allocation_base_address			AS [Base]
				FROM		sys.dm_os_virtual_address_dump
				WHERE		region_allocation_base_address = 0x0
				) AS VAS_Dump
		GROUP BY	Size
		)

SELECT		SUM(CONVERT(BIGINT,Size)*Free)/1024	AS [Total avail mem, KB]
		,CAST(MAX(Size) AS BIGINT)/1024		AS [Max free size, KB]
FROM		VAS_Summary
WHERE		Free <> 0
GO







SELECT		lm.[base_address]
		, lm.NAME
		, SUM(vad.region_size_in_bytes)/1024 AS [Mem kb]
FROM		sys.[dm_os_loaded_modules] lm
INNER JOIN	[sys].[dm_os_virtual_address_dump] vad
	ON	lm.[base_address] = vad.[region_allocation_base_address]
GROUP BY	lm.[base_address], lm.[name]
ORDER BY	2 DESC




SELECT * FROM [dbaadmin].[sys].[dm_clr_properties]

/*
STATES

Mscoree is not loaded.
Mscoree is loaded.
Locked CLR version with mscoree.
CLR is initialized.
CLR initialization permanently failed.
CLR is stopped.


The "Mscoree is not loaded" and "Mscoree is loaded" states show the progression of the hosted CLR 
initialization on server startup, and are not likely to be seen. 

The "Locked CLR version with mscoree" state may be seen where the hosted CLR is not being used 
and, thus, it has not yet been initialized. The hosted CLR is initialized the first time a DDL 
statement (such as CREATE ASSEMBLY (Transact-SQL)) or a managed database object is executed.

The "CLR is initialized" state indicates that the hosted CLR was successfully initialized. 
Note that this does not indicate whether execution of user CLR code was enabled. 
If the execution of user CLR code is first enabled and then disabled using the Transact-SQL 
sp_configure stored procedure, the state value will still be CLR is initialized.

The "CLR initialization permanently failed" state indicates that hosted CLR initialization failed. 
Memory pressure is a likely cause, or it could also be the result of a failure in the hosting 
handshake between SQL Server and the CLR. Error message 6512 or 6513 will be thrown in such a case.

The "CLR is stopped" state is only seen when SQL Server is in the process of shutting down.


*/

SELECT * FROM [dbaadmin].sys.dm_clr_loaded_assemblies
SELECT * FROM [dbaadmin].sys.dm_clr_appdomains
SELECT * FROM [dbaadmin].sys.dm_clr_tasks
SELECT * FROM [dbaadmin].sys.dm_os_memory_pools
SELECT * FROM [dbaadmin].sys.dm_os_memory_objects
SELECT * FROM [dbaadmin].sys.dm_os_hosts
SELECT * FROM [dbaadmin].sys.dm_os_memory_clerks

select		mc.single_pages_kb + mc.multi_pages_kb + mc.virtual_memory_committed_kb 
		,*
from		[dbaadmin].sys.dm_os_memory_clerks mc
JOIN		[dbaadmin].sys.dm_os_memory_objects mo
	ON	mo.page_allocator_address = mc.page_allocator_address

where		mc.type LIKE 'MEMORYCLERK_SQLCLR%'





SELECT * FROM [dbaadmin].sys.dm_os_loaded_modules where name like 'C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\%' order by name
SELECT * FROM [dbaadmin].sys.dm_os_virtual_address_dump order by 4 desc


sp_configure 'show advanced options', 1
RECONFIGURE
GO
sp_configure 'awe enabled', 1
RECONFIGURE
GO


