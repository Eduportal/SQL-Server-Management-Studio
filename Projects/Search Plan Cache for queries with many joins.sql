



;WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 

--(SELECT COUNT(*) FROM @XML.nodes('//RelOp') AS RelOps(RelOp) WHERE RelOps.Relop.value('@LogicalOp','sysname') LIKE '%join%') 
SELECT		sql_handle	
		,plan_handle	
		,last_execution_time	
		,execution_count	
		,total_worker_time	
		,total_physical_reads	
		,total_logical_reads	
		,MAX(CAST(query_plan AS VarChar(max)))
		,MAX(CAST(text AS VarChar(max)))
		,COUNT(LogicalOp)


FROM		(
		SELECT		Plans.*
				,RelOps.RelOp.value('@LogicalOp[1]', 'sysname') AS [LogicalOp]
				--,keylookups.keylookup.value('(Object/@Database)[1]', 'sysname') AS [database]
		FROM		(
				SELECT		query_stats.*
						,[query_plan].[query_plan]
						,[sql_text].[text]
				FROM		(
						SELECT		[sql_handle] , 
								[plan_handle] , 
								MAX(last_execution_time) AS last_execution_time , 
								SUM(execution_count) AS execution_count , 
								SUM(total_worker_time) AS total_worker_time , 
								SUM(total_physical_reads) AS total_physical_reads , 
								SUM(total_logical_reads) AS total_logical_reads 
						FROM		sys.dm_exec_query_stats
						GROUP BY	[sql_handle]
								,[plan_handle]
						)query_stats
				CROSS APPLY	sys.dm_exec_query_plan(query_stats.plan_handle) [query_plan] 
				CROSS APPLY	sys.dm_exec_sql_text(query_stats.sql_handle) [sql_text] 
				) [plans]
		CROSS APPLY	query_plan.nodes('//RelOp') AS RelOps ( RelOp ) 
		) Data
WHERE		LogicalOp Like '%Join%'


GROUP BY	sql_handle	
		,plan_handle	
		,last_execution_time	
		,execution_count	
		,total_worker_time	
		,total_physical_reads	
		,total_logical_reads	

HAVING		COUNT(LogicalOp) > 3

order by 4 desc