;WITH	XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'),
		TopIOQuery AS
		(
			SELECT  TOP 10
			DB_NAME(CAST(qpa.value AS INT)) DBName,
			qs.total_logical_reads / qs.execution_count avg_logical_reads,
			SUBSTRING(st.text, CASE
								WHEN qs.statement_start_offset IN (0,NULL) THEN 1
								ELSE qs.statement_start_offset/2 + 1 
							   END,
							   CASE 
								WHEN qs.statement_end_offset IN (0,-1,NULL) THEN LEN(st.text)
								ELSE qs.statement_end_offset/2
							   END - CASE
										WHEN qs.statement_start_offset IN (0, NULL) THEN 1
										ELSE qs.statement_start_offset/2 +1
									 END
					 ) query_text,
					 qp.query_plan
			FROM	sys.dm_exec_query_stats qs
				CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
				CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
				CROSS APPLY sys.dm_exec_plan_attributes(qs.plan_handle) qpa
			WHERE	qpa.attribute = 'dbid' 
					AND qpa.value > 4
			ORDER BY qs.total_logical_reads / qs.execution_count DESC
		)
SELECT	t.DBName,
		t.avg_logical_reads,
		CAST('<q> ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(t.query_text,' OR ',' OR ' + CHAR(10)),' AND ',' AND ' + CHAR(10)),'&amp;','&amp;amp;'),'>','&amp;gt;'),'<','&amp;lt;') + ' </q>' AS XML) Query,
		t.query_text,
		RelOp.Col.value('(./@PhysicalOp)[1]','VARCHAR(200)') Operation,
		ISNULL(RelOp.Col.value('(.//Object[1]/@Schema)[1]','SYSNAME'),'tempdb.') + '.' + RelOp.Col.value('(.//Object[1]/@Table)[1]','SYSNAME') TableName,
		RelOp.Col.value('(./@EstimateRows)[1]','FLOAT') EstimatedRows,
		RelOp.Col.value('(./@EstimateCPU)[1]','FLOAT') EstimatedCPU,
		RelOp.Col.value('(./@EstimateIO)[1]','FLOAT') EstimatedIO,
		RelOp.Col.value('(./@EstimatedTotalSubtreeCost)[1]','FLOAT') EstimatedCost,
		RelOp.Col.query('./OutputList') OutputList,
		CAST('<p> ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RelOp.Col.value('(./IndexScan/Predicate/ScalarOperator/@ScalarString)[1]','VARCHAR(MAX)'),' OR ',' OR ' + CHAR(10)),' AND ',' AND ' + CHAR(10)),'&amp;','&amp;amp;'),'>','&amp;gt;'),'<','&amp;lt;') + ' </p>' AS XML) Predicate,
		RelOp.Col.query('.') RelOpXML,
		t.query_plan QueryPlan
FROM	TopIOQuery t
			--CROSS APPLY t.query_plan.nodes('//RelOp[@PhysicalOp="Clustered Index Scan"]') RelOp(col)
			--CROSS APPLY t.query_plan.nodes('//RelOp[@PhysicalOp="Table Spool"]') RelOp(col)
			--CROSS APPLY t.query_plan.nodes('//RelOp[@PhysicalOp="Index Spool"]') RelOp(col)
			CROSS APPLY t.query_plan.nodes('//RelOp[@PhysicalOp="Index Scan"]') RelOp(col)
			--CROSS APPLY t.query_plan.nodes('//RelOp[@PhysicalOp="Table Scan"]') RelOp(col)
			--CROSS APPLY t.query_plan.nodes('//RelOp[@PhysicalOp="Remote Index Scan"]') RelOp(col)
			--CROSS APPLY t.query_plan.nodes('//RelOp[@PhysicalOp="Remote Scan"]') RelOp(col)
			--CROSS APPLY t.query_plan.nodes('//RelOp[@PhysicalOp="RID Lookup"]') RelOp(col)
WHERE	RelOp.col.value('(.//Object/@Schema)[1]','SYSNAME') <> '[sys]'
ORDER BY avg_logical_reads DESC,query_text,EstimatedIO DESC





SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH XMLNAMESPACES
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT
    n.value('(@StatementText)[1]', 'VARCHAR(4000)') AS sql_text,
    n.query('.'),
    i.value('(@PhysicalOp)[1]', 'VARCHAR(128)') AS PhysicalOp,
    i.value('(./IndexScan/Object/@Database)[1]', 'VARCHAR(128)') AS DatabaseName,
    i.value('(./IndexScan/Object/@Schema)[1]', 'VARCHAR(128)') AS SchemaName,
    i.value('(./IndexScan/Object/@Table)[1]', 'VARCHAR(128)') AS TableName,
    i.value('(./IndexScan/Object/@Index)[1]', 'VARCHAR(128)') as IndexName,
    i.query('.'),
    STUFF((SELECT DISTINCT ', ' + cg.value('(@Column)[1]', 'VARCHAR(128)')
       FROM i.nodes('./OutputList/ColumnReference') AS t(cg)
       FOR  XML PATH('')),1,2,'') AS output_columns,
    STUFF((SELECT DISTINCT ', ' + cg.value('(@Column)[1]', 'VARCHAR(128)')
       FROM i.nodes('./IndexScan/SeekPredicates/SeekPredicateNew//ColumnReference') AS t(cg)
       FOR  XML PATH('')),1,2,'') AS seek_columns,
    i.value('(./IndexScan/Predicate/ScalarOperator/@ScalarString)[1]', 'VARCHAR(4000)') as Predicate,
	cp.usecounts,
    query_plan
FROM (  SELECT plan_handle, query_plan
        FROM (  SELECT DISTINCT plan_handle
                FROM sys.dm_exec_query_stats WITH(NOLOCK)) AS qs
        OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle) tp
      ) as tab (plan_handle, query_plan)
INNER JOIN sys.dm_exec_cached_plans AS cp 
    ON tab.plan_handle = cp.plan_handle
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/*') AS q(n)
CROSS APPLY n.nodes('.//RelOp[IndexScan[@Lookup="1"] and IndexScan/Object[@Schema!="[sys]"]]') as s(i)
OPTION(RECOMPILE, MAXDOP 1);


SELECT  Xplan.p.value('declare default element namespace "<a href="http://schemas.microsoft.com/sqlserver/2004/07/showplan";">http://schemas.microsoft.com/sqlserver/2004/07/showplan";</a>
@NodeId', 'int') AS NodeID,
Xplan.p.value('declare default element namespace "<a href="http://schemas.microsoft.com/sqlserver/2004/07/showplan";">http://schemas.microsoft.com/sqlserver/2004/07/showplan";</a>
@PhysicalOp','varchar(50)') AS PhysicalOp,
Xplan.p.value('declare default element namespace "<a href="http://schemas.microsoft.com/sqlserver/2004/07/showplan";">http://schemas.microsoft.com/sqlserver/2004/07/showplan";</a>
@EstimatedIO','decimal(7,6)') AS EstimatedIO,
Xplan.p.value('declare default element namespace "<a href="http://schemas.microsoft.com/sqlserver/2004/07/showplan";">http://schemas.microsoft.com/sqlserver/2004/07/showplan";</a>
@EstimatedCPU','decimal(7,6)') AS EstimatedCPU,
dest.text,
deqp.query_plan
FROM    sys.dm_exec_procedure_stats AS deps
CROSS APPLY sys.dm_exec_sql_text(deps.sql_handle) AS dest
CROSS APPLY sys.dm_exec_query_plan(deps.plan_handle) AS deqp
CROSS APPLY deqp.query_plan.nodes('declare default element namespace
"<a href="http://schemas.microsoft.com/sqlserver/2004/07/showplan";">http://schemas.microsoft.com/sqlserver/2004/07/showplan";</a>
//RelOp') XPlan (p)
WHERE   dest.text LIKE 'CREATE PROCEDURE dbo.GetSalesDetails%' ;



GO


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ;

WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'),
core AS (
        SELECT
                eqp.query_plan AS [QueryPlan],
                ecp.plan_handle [PlanHandle],
                q.[Text] AS [Statement],
                n.value('(@StatementOptmLevel)[1]', 'VARCHAR(25)') AS OptimizationLevel ,
                ISNULL(CAST(n.value('(@StatementSubTreeCost)[1]', 'VARCHAR(128)') as float),0) AS SubTreeCost ,
                ecp.usecounts [UseCounts],
                ecp.size_in_bytes [SizeInBytes]
        FROM
                sys.dm_exec_cached_plans AS ecp
                CROSS APPLY sys.dm_exec_query_plan(ecp.plan_handle) AS eqp
                CROSS APPLY sys.dm_exec_sql_text(ecp.plan_handle) AS q
                CROSS APPLY query_plan.nodes ('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS qn ( n )
)

SELECT TOP 100
        QueryPlan,
        PlanHandle,
        [Statement],
        OptimizationLevel,
        SubTreeCost,
        UseCounts,
        SubTreeCost * UseCounts [GrossCost],
        SizeInBytes
FROM
        core
ORDER BY
        GrossCost DESC
        --SubTreeCost DESC