
DECLARE		@DatabaseName	sysname
		,@dbid		int 
		, @Table	sysname
		, @MinReadCost	int
		, @CutOff	int
		

SELECT		@DatabaseName	= DB_name()
		,@dbid		= db_id(@DatabaseName)
		, @Table	= 'SubscriptionDetail'
		, @MinReadCost	= 100
		, @CutOff	= 50
 
--SELECT		@DatabaseName Database_Name
--		, @dbid [Database_id]
--		, Name	Object_Name
--		, ID	Object_ID
--FROM		sysobjects
--WHERE		objectproperty(id, 'isusertable')=1 
--ORDER BY	1 


----Unused indexes 
--SELECT		DB_Name(s.database_id) Database_Name
--		, s.database_id [Database_id]
--		, object_name(s.object_id) as Object_Name
--		, s.object_id
--		, i.name as IndexName
--		, i.index_id 
--		, user_seeks + user_scans + user_lookups  as reads
--		, user_updates as writes 
--		, 100 -((user_updates * 100.00) / (user_seeks + user_scans + user_lookups + user_updates)) read_percent
--		, sum(p.rows) as rows
--FROM		sys.dm_db_index_usage_stats s 
--JOIN		sys.indexes i 
--	ON	s.object_id					= i.object_id  
--	AND	s.index_id					= i.index_id 
--	AND	s.database_id					= @dbid
--	AND	object_name(s.object_id)			= @Table 
--JOIN		sys.partitions p 
--	ON	s.object_id					= p.object_id 
--	AND	p.index_id					= s.index_id
--WHERE		objectproperty(s.object_id,'IsUserTable')	= 1 
--	AND	s.index_id					> 0 
--	AND	user_updates					> (user_seeks + user_scans + user_lookups)
--GROUP BY	s.database_id
--		, s.object_id
--		, i.name
--		, i.index_id
--		, user_seeks + user_scans + user_lookups
--		, user_updates
--ORDER BY	read_percent 
--		, writes desc 



----Missing indexes
--SELECT		DB_Name(mid.database_id) Database_Name
--		, mid.database_id [Database_id]
--		, sys.objects.name [Object_name]
--		, mid.object_id
--		, (avg_total_user_cost * avg_user_impact) * (user_seeks + user_scans) as Impact
--		, mid.equality_columns
--		, mid.inequality_columns
--		, mid.included_columns
--FROM		sys.dm_db_missing_index_group_stats AS migs
--JOIN		sys.dm_db_missing_index_groups AS mig 
--	ON	migs.group_handle = mig.index_group_handle
--JOIN		sys.dm_db_missing_index_details AS mid 
--	ON	mig.index_handle = mid.index_handle
--	AND	mid.database_id = @dbid
--JOIN		sys.objects WITH (nolock) 
--	ON	sys.objects.object_id = mid.object_id
--	AND	sys.objects.name = @Table
--WHERE		objectproperty(sys.objects.object_id, 'isusertable')=1

--ORDER BY	5 DESC 


SELECT		@DatabaseName	= QUOTENAME(@DatabaseName)
		, @Table	= QUOTENAME(@Table)
		
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
WITH XMLNAMESPACES  
(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
SELECT		TOP (@CutOff)  --ecp.plan_handle,
		@@ServerName																AS server_name
		, REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Database)[1]','sysname'),'[',''),']','')		AS database_name
		, DB_ID(REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Database)[1]','sysname'),'[',''),']',''))	AS database_id
		, SCHEMA_ID(REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Schema)[1]','sysname'),'[',''),']','')) AS schema_id
		, REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Schema)[1]','sysname'),'[',''),']','')		AS schema_name
		, OBJECT_ID(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Schema)[1]','sysname')
		+ '.' +	n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Table)[1]','sysname'))					AS object_id
		, REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Table)[1]','sysname'),'[',''),']','')		AS table_name
		--,DENSE_RANK() OVER ( ORDER BY ecp.plan_handle )											AS ArbitraryPlanNumber
		, n.value('(@StatementSubTreeCost)[1]', 'VARCHAR(128)')
			* ISNULL(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/@Impact)[1]','float'), 0)
			* ecp.usecounts										AS Improvement
		, query_plan											AS CompleteQueryPlan
		, n.value('(@StatementId)[1]', 'float')								AS StatementID
		, n.value('(@StatementText)[1]', 'VARCHAR(4000)')						AS StatementText
		, n.value('(@StatementSubTreeCost)[1]', 'VARCHAR(128)')						AS StatementSubTreeCost
		, n.query('./QueryPlan/MissingIndexes')								AS MissingIndex
		--, n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Database)[1]','sysname')	AS DatabaseName
		--, n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Schema)[1]','sysname')	AS SchemaName
		--, n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Table)[1]','sysname')	AS TableName
		, n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/@Impact)[1]','float')			AS IndexImpact
		, ecp.usecounts
		,eqp.dbid
		,OBJECT_NAME(eqp.objectid)
		,eqp.objectid
FROM		sys.dm_exec_cached_plans									AS ecp
CROSS APPLY	sys.dm_exec_query_plan(plan_handle)								AS eqp
CROSS APPLY	query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple')			AS qn ( n )
WHERE		n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/@Impact)[1]','float') IS NOT NULL 
	--AND	ecp.usecounts > 100
	AND	n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Database)[1]','sysname')	= @DatabaseName
	AND	n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Table)[1]','sysname')	= @Table
	AND	eqp.query_plan.exist('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan"; /ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple/QueryPlan/MissingIndexes') = 1 
--ORDER BY	TableName DESC



SELECT TOP	(@CutOff)  
		SUBSTRING(est.text, eqs.statement_start_offset/2, (CASE WHEN eqs.statement_end_offset = -1 then LEN(CONVERT(nvarchar(max), est.text)) * 2 ELSE eqs.statement_end_offset end - eqs.statement_start_offset)/2) AS [Statement]   
		, OBJECT_NAME(est.objectid) AS [Stored Procedure]  
		, eqp.query_plan  
		, eqs.execution_count   
		, eqs.min_logical_reads, eqs.max_logical_reads, (eqs.total_logical_reads/eqs.execution_count) AS avg_logical_reads  
		, eqs.min_logical_writes, eqs.max_logical_writes, (eqs.total_logical_writes/eqs.execution_count) AS avg_logical_writes  
		, eqs.min_worker_time, eqs.max_worker_time, (eqs.total_worker_time/eqs.execution_count) AS avg_worker_time  
		, eqs.min_elapsed_time, eqs.max_elapsed_time, (eqs.total_elapsed_time/eqs.execution_count) AS avg_elapsed_time   

FROM  sys.dm_exec_query_stats eqs  
CROSS APPLY sys.dm_exec_sql_text(eqs.sql_handle) est  
CROSS APPLY sys.dm_exec_query_plan(eqs.plan_handle) eqp  
WHERE eqp.query_plan.exist('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan"; //MissingIndexes//MissingIndex[@Database = sql:variable("@DatabaseName") and @Table = sql:variable("@Table")]') = 1
  AND eqs.max_logical_reads > @MinReadCost  
ORDER BY avg_logical_reads DESC  













