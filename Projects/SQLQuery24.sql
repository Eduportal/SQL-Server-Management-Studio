
DECLARE		@DatabaseName	sysname
		,@DB_ID		int 
		, @Table	sysname
		, @ObjectID	int
		

SELECT		@DatabaseName	= DB_name()
		,@DB_ID		= db_id(@DatabaseName)
		, @Table	= 'DownloadDetail'
		, @ObjectID	= OBJECT_ID(@Table);



WITH ReferencingObjects (referenced_major_id, object_id, parent_object_name, object_name, Level)
AS
(
-- Anchor member definition
    SELECT e.referenced_major_id, e.object_id, object_name(e.referenced_major_id), object_name(e.object_id), 
        0 AS Level
    FROM sys.sql_dependencies AS e
    WHERE referenced_major_id = @ObjectID--not in (select distinct object_id from sys.sql_dependencies)
    UNION ALL
-- Recursive member definition
    SELECT e.referenced_major_id, e.object_id, object_name(e.referenced_major_id), object_name(e.object_id),
        Level + 1
    FROM sys.sql_dependencies AS e
    INNER JOIN ReferencingObjects AS d
        ON e.referenced_major_id = d.object_id
)
select * 
from sys.syscacheobjects
WHERE objid in
( 
SELECT		DISTINCT 
		object_id
FROM		ReferencingObjects
UNION ALL
SELECT		@ObjectID
)

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
, ReferencingObjects (referenced_major_id, object_id, parent_object_name, object_name, Level)
AS
(
-- Anchor member definition
    SELECT e.referenced_major_id, e.object_id, object_name(e.referenced_major_id), object_name(e.object_id), 
        0 AS Level
    FROM sys.sql_dependencies AS e
    WHERE referenced_major_id = @ObjectID--not in (select distinct object_id from sys.sql_dependencies)
    UNION ALL
-- Recursive member definition
    SELECT e.referenced_major_id, e.object_id, object_name(e.referenced_major_id), object_name(e.object_id),
        Level + 1
    FROM sys.sql_dependencies AS e
    INNER JOIN ReferencingObjects AS d
        ON e.referenced_major_id = d.object_id
)
SELECT		@@ServerName																AS server_name
		, REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Database)[1]','sysname'),'[',''),']','')		AS database_name
		, DB_ID(REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Database)[1]','sysname'),'[',''),']',''))	AS database_id
		, SCHEMA_ID(REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Schema)[1]','sysname'),'[',''),']','')) AS schema_id
		, REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Schema)[1]','sysname'),'[',''),']','')		AS schema_name
		, OBJECT_ID(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Schema)[1]','sysname')
		+ '.' +	n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Table)[1]','sysname'))					AS object_id
		, REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Table)[1]','sysname'),'[',''),']','')		AS table_name
		, n.value('(@StatementSubTreeCost)[1]', 'VARCHAR(128)')
			* ISNULL(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/@Impact)[1]','float'), 0)
			* ecp.usecounts AS Improvement 
		, query_plan AS CompleteQueryPlan 
		, OBJECT_NAME(objectid) Sproc_name
		, n.value('(@StatementId)[1]', 'float') AS StatementID 
		, n.value('(@StatementText)[1]', 'VARCHAR(4000)') AS StatementText 
		, n.value('(@StatementSubTreeCost)[1]', 'VARCHAR(128)') AS StatementSubTreeCost 
		, n.query('./QueryPlan/MissingIndexes') MissingIndex 
		, n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/@Impact)[1]','float') IndexImpact 
		, ecp.usecounts
FROM		sys.dm_exec_cached_plans AS ecp
CROSS APPLY	sys.dm_exec_query_plan(plan_handle) AS eqp
CROSS APPLY	query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS qn ( n )

WHERE		eqp.objectid in	( -- ONLY LOOK AT PLANS for OBJECTS WITH REFERENCES TO THE TABLE
				SELECT		DISTINCT 
						object_id
				FROM		ReferencingObjects
				)
	AND	n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/@Impact)[1]','float') IS NOT NULL
	--AND	ecp.usecounts > 100 
	AND	eqp.query_plan.exist('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan"; 
					/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple/QueryPlan/MissingIndexes') = 1 
	AND	DB_ID(REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Database)[1]','sysname'),'[',''),']','')) = @DB_ID
	--AND	(
	--	OBJECT_ID(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Schema)[1]','sysname')
	--	+ '.' +	n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Table)[1]','sysname')) = @ObjectID
	--	OR
	--	@ObjectID IS NULL
	--	)
ORDER BY	Improvement DESC




--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
--WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
--SELECT		@@ServerName																AS server_name
--		, REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Database)[1]','sysname'),'[',''),']','')		AS database_name
--		, DB_ID(REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Database)[1]','sysname'),'[',''),']',''))	AS database_id
--		, SCHEMA_ID(REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Schema)[1]','sysname'),'[',''),']','')) AS schema_id
--		, REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Schema)[1]','sysname'),'[',''),']','')		AS schema_name
--		, OBJECT_ID(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Schema)[1]','sysname')
--		+ '.' +	n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Table)[1]','sysname'))					AS object_id
--		, REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Table)[1]','sysname'),'[',''),']','')		AS table_name
--		, n.value('(@StatementSubTreeCost)[1]', 'VARCHAR(128)')
--			* ISNULL(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/@Impact)[1]','float'), 0)
--			* ecp.usecounts AS Improvement 
--		, query_plan AS CompleteQueryPlan 
--		, OBJECT_NAME(objectid) Sproc_name
--		, n.value('(@StatementId)[1]', 'float') AS StatementID 
--		, n.value('(@StatementText)[1]', 'VARCHAR(4000)') AS StatementText 
--		, n.value('(@StatementSubTreeCost)[1]', 'VARCHAR(128)') AS StatementSubTreeCost 
--		, n.query('./QueryPlan/MissingIndexes') MissingIndex 
--		, n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/@Impact)[1]','float') IndexImpact 
--		, ecp.usecounts

--SELECT		REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Database)[1]','sysname'),'[',''),']','')
--		,n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Schema)[1]','sysname')
--		+ '.' +	n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Table)[1]','sysname')
--SELECT		top 1000
--		*
		
--FROM		sys.dm_exec_cached_plans AS ecp
--CROSS APPLY	sys.dm_exec_query_plan(plan_handle) AS eqp
----CROSS APPLY	query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS qn ( n )
--WHERE		cast(query_plan as nvarchar(max)) like '%MissingIndexes%'


--		n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/@Impact)[1]','float') IS NOT NULL
--	--AND	ecp.usecounts > 100 
--	AND	eqp.query_plan.exist('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan"; 
--					/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple/QueryPlan/MissingIndexes') = 1 
--	AND	DB_ID(REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Database)[1]','sysname'),'[',''),']','')) = @DB_ID
--	--AND	(
--	--	OBJECT_ID(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Schema)[1]','sysname')
--	--	+ '.' +	n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Table)[1]','sysname')) = @ObjectID
--	--	OR
--	--	@ObjectID IS NULL
--	--	)
--ORDER BY	Improvement DESC





----SELECT  COUNT(*) CountBeforeInclude ,
----        mid.statement ,
--        SUM(migs.user_seeks) seeks ,
--        mid.statement + ' (' + ISNULL(mid.equality_columns, '')
--        + CASE WHEN mid.equality_columns IS NOT NULL
--                    AND mid.inequality_columns IS NOT NULL THEN ','
--               ELSE ''
--          END + ISNULL(mid.inequality_columns, '') + ')' AS base_index_statement ,
--        SUM(CONVERT (DECIMAL(28, 1), migs.avg_total_user_cost
--            * migs.avg_user_impact * ( migs.user_seeks + migs.user_scans ))) AS improvement_measure

--FROM    sys.dm_db_missing_index_groups mig
--        INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
--        INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
        
--WHERE   database_id = @DB_ID
--AND mid.statement LIKE '%'+@Table+'%' 

--GROUP BY mid.statement ,
--        mid.statement + ' (' + ISNULL(mid.equality_columns, '')
--        + CASE WHEN mid.equality_columns IS NOT NULL
--                    AND mid.inequality_columns IS NOT NULL THEN ','
--               ELSE ''
--          END + ISNULL(mid.inequality_columns, '') + ')'

--ORDER BY improvement_measure DESC	





--SELECT  mid.statement ,
--        migs.user_seeks ,
--        equality_columns ,
--        inequality_columns ,
--        included_columns ,
--        'CREATE INDEX missing_index_'
--		+ CONVERT (VARCHAR, mig.index_group_handle) + '_'
--		+ CONVERT (VARCHAR, mid.index_handle) + ' ON ' + mid.statement + ' ('
--		+ ISNULL(mid.equality_columns, '')
--		+ CASE	WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL 
--			THEN ','
--			ELSE ''
--			END
--		+ ISNULL(mid.inequality_columns, '') + ')' 
--		+ ISNULL(' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement ,
--        migs.* ,
--        mid.database_id ,
--        mid.[object_id] ,
--        mig.index_group_handle ,
--        mid.index_handle ,
--        CONVERT (DECIMAL(28, 1), migs.avg_total_user_cost
--        * migs.avg_user_impact * ( migs.user_seeks + migs.user_scans )) AS improvement_measure
        
--FROM    sys.dm_db_missing_index_groups mig
--        INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
--        INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
                
--WHERE   database_id = @DB_ID
--        AND mid.statement LIKE '%'+@Table+'%'        
    
    
    
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
SELECT		TOP 10
		@@ServerName																AS server_name
		, REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Database)[1]','sysname'),'[',''),']','')		AS database_name
		, DB_ID(REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Database)[1]','sysname'),'[',''),']',''))	AS database_id
		, SCHEMA_ID(REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Schema)[1]','sysname'),'[',''),']','')) AS schema_id
		, REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Schema)[1]','sysname'),'[',''),']','')		AS schema_name
		, OBJECT_ID(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Schema)[1]','sysname')
		+ '.' +	n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Table)[1]','sysname'))					AS object_id
		, REPLACE(REPLACE(n.value('(./QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Table)[1]','sysname'),'[',''),']','')		AS table_name
		, SUBSTRING(
			  est.text
			  ,eqs.statement_start_offset/2
			  , (
			    CASE 
			    WHEN eqs.statement_end_offset = -1 
			    THEN LEN(CONVERT(nvarchar(max), est.text)) * 2 
			    ELSE eqs.statement_end_offset 
			    end - eqs.statement_start_offset
			    )/2
			 )						AS [Statement]   
		, OBJECT_NAME(est.objectid)				AS [Stored Procedure]  
		, eqp.query_plan  
		, eqs.execution_count   
		, eqs.min_logical_reads
		, eqs.max_logical_reads
		, (eqs.total_logical_reads/eqs.execution_count)		AS avg_logical_reads  
		, eqs.min_logical_writes
		, eqs.max_logical_writes
		, (eqs.total_logical_writes/eqs.execution_count)	AS avg_logical_writes  
		, eqs.min_worker_time
		, eqs.max_worker_time
		, (eqs.total_worker_time/eqs.execution_count)		AS avg_worker_time  
		, eqs.min_elapsed_time
		, eqs.max_elapsed_time
		, (eqs.total_elapsed_time/eqs.execution_count)		AS avg_elapsed_time   

FROM		sys.dm_exec_query_stats eqs  
CROSS APPLY	sys.dm_exec_sql_text(eqs.sql_handle) est  
CROSS APPLY	sys.dm_exec_query_plan(eqs.plan_handle) eqp 
CROSS APPLY	query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS qn ( n )
 
WHERE		eqp.query_plan.exist('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";
							//MissingIndexes//MissingIndex[@Database = sql:variable("@DbName") and @Table = sql:variable("@Table")]') = 1
ORDER BY	avg_logical_reads DESC  
