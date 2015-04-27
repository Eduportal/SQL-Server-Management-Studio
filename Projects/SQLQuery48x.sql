--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
--GO
 
--DECLARE @op sysname = 'Index Scan';
--DECLARE @IndexName sysname = 'IX_QueueTb_DeliveryId_StatusCode_I_AssetSizeBytes_NextAttemptDate';

--;WITH XMLNAMESPACES(DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
--SELECT		cp.plan_handle
--			,operators.value('(IndexScan/Object/@Schema)[1]','sysname')	AS SchemaName
--			,operators.value('(IndexScan/Object/@Table)[1]','sysname')	AS TableName
--			,operators.value('(IndexScan/Object/@Index)[1]','sysname')	AS IndexName
--			,operators.value('@PhysicalOp','nvarchar(50)')				AS PhysicalOperator
--			,cp.usecounts
--			,qp.query_plan
--FROM		sys.dm_exec_cached_plans					cp
--CROSS APPLY	sys.dm_exec_query_plan(cp.plan_handle)		qp
----CROSS APPLY sys.dm_exec_sql_text(cp.sql_handle)			st
--CROSS APPLY sys.dm_exec_plan_attributes(cp.plan_handle)	qpa

--CROSS APPLY	query_plan.nodes('//RelOp')					rel(operators)



--WHERE		operators.value('(IndexScan/Object/@Index)[1]','sysname') = QUOTENAME(@IndexName,'[')
----		AND	operators.value('@PhysicalOp','nvarchar(50)') IN ('Clustered Index Scan','Index Scan')
--ORDER BY	cp.usecounts DESC
--;





GO
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
GO

DECLARE @IndexName sysname = 'IX_QueueTb_DeliveryId_StatusCode_I_AssetSizeBytes_NextAttemptDate';

;WITH XMLNAMESPACES(DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan')

SELECT		cp.plan_handle
			,cp.usecounts

			,c.value('@StatementEstRows', 'float')							AS StatementEstRows
			,c.value('@StatementOptmLevel', 'varchar(255)')					AS StatementOptmLevel
			,c.value('@StatementOptmEarlyAbortReason', 'varchar(255)')		AS StatementOptmEarlyAbortReason
			,c.value('@StatementSubTreeCost', 'float')						AS StatementSubTreeCost
			,c.value('@StatementText', 'varchar(max)')						AS StatementText
			,c.value('@StatementType', 'varchar(255)')						AS StatementType
			,c.value('@QueryHash', 'varchar(255)')							AS QueryHash
			,c.value('@QueryPlanHash', 'varchar(255)')						AS QueryPlanHash

			,operators.value('(IndexScan/Object/@Schema)[1]','sysname')		AS SchemaName
			,operators.value('(IndexScan/Object/@Table)[1]','sysname')		AS TableName
			,operators.value('(IndexScan/Object/@Index)[1]','sysname')		AS IndexName
			,operators.value('@PhysicalOp','nvarchar(50)')					AS PhysicalOperator
			,operators.value('@StatementText','nvarchar(50)')				AS StatementText
						
			,qp.query_plan
			,c.query('*') Statements
			,operators.query('*') 
FROM		sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
CROSS APPLY qp.query_plan.nodes('//StmtSimple') t(c)
CROSS APPLY c.nodes('//RelOp') rel(operators)

WHERE		qp.query_plan.exist('//StmtSimple') = 1
		AND	nullif(CAST(c.query('*') AS VarChar(max)),'') IS NOT NULL
		AND	operators.value('(IndexScan/Object/@Index)[1]','sysname') = QUOTENAME(@IndexName,'[')
		AND	operators.value('@PhysicalOp','nvarchar(50)') IN ('Clustered Index Scan','Index Scan','Clustered Index Seek','Index Seek')









--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
--GO

--WITH XMLNAMESPACES
--(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
--SELECT		cp.plan_handle
--			,qp.query_plan
--			,c.value('@StatementEstRows', 'float')						AS StatementEstRows
--			,c.value('@StatementOptmLevel', 'varchar(255)')				AS StatementOptmLevel
--			,c.value('@StatementOptmEarlyAbortReason', 'varchar(255)')	AS StatementOptmEarlyAbortReason
--			,c.value('@StatementSubTreeCost', 'float')					AS StatementSubTreeCost
--			,c.value('@StatementText', 'varchar(max)')					AS StatementText
--			,c.value('@StatementType', 'varchar(255)')					AS StatementType
--			,c.value('@QueryHash', 'varchar(255)')						AS QueryHash
--			,c.value('@QueryPlanHash', 'varchar(255)')					AS QueryPlanHash
--FROM sys.dm_exec_cached_plans AS cp
--CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
--CROSS APPLY qp.query_plan.nodes('//StmtSimple') t(c)
--WHERE qp.query_plan.exist('//StmtSimple') = 1









----DB_NAME(CAST(qpa.value AS INT)) DBName,
----            qs.total_logical_reads / qs.execution_count avg_logical_reads,
----            SUBSTRING(st.text, CASE
----                                WHEN qs.statement_start_offset IN (0,NULL) THEN 1
----                                ELSE qs.statement_start_offset/2 + 1
----                               END,
----                               CASE
----                                WHEN qs.statement_end_offset IN (0,-1,NULL) THEN LEN(st.text)
----                                ELSE qs.statement_end_offset/2
----                               END - CASE
----                                        WHEN qs.statement_start_offset IN (0, NULL) THEN 1
----                                        ELSE qs.statement_start_offset/2 +1
----                                     END
----                     ) query_text,
----                     qp.query_plan
                     
----            FROM    sys.dm_exec_query_stats qs
----                CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
----                CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
----                CROSS APPLY sys.dm_exec_plan_attributes(qs.plan_handle) qpa