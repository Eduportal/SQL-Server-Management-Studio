SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
GO

DECLARE @DatabaseName	sysname		= DB_NAME()
		,@TableName		sysname		= 'QueueTb'
		,@IndexName		sysname		--= 'IX_QueueTb_DeliveryId_StatusCode_I_AssetSizeBytes_NextAttemptDate'
	
;WITH XMLNAMESPACES(DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT		*
FROM		(
			SELECT		usecounts
						,Data.StatementEstRows
						,Data.StatementOptmLevel
						,Data.StatementOptmEarlyAbortReason
						,Data.StatementSubTreeCost
						,Data.StatementType
						,Data.StatementText
						,operators.value('(IndexScan/Object/@Database)[1]','sysname')	AS DatabaseName
						,operators.value('(IndexScan/Object/@Schema)[1]','sysname')		AS SchemaName
						,operators.value('(IndexScan/Object/@Table)[1]','sysname')		AS TableName
						,operators.value('(IndexScan/Object/@Index)[1]','sysname')		AS IndexName
						,operators.value('@PhysicalOp','nvarchar(50)')					AS PhysicalOperator
						--,operators.value('@StatementText','nvarchar(max)')				AS StatementText
						,operators.query('*') RelOps
			FROM		(
						SELECT		cp.usecounts
									,c.value('@StatementEstRows', 'float')							AS StatementEstRows
									,c.value('@StatementOptmLevel', 'varchar(255)')					AS StatementOptmLevel
									,c.value('@StatementOptmEarlyAbortReason', 'varchar(255)')		AS StatementOptmEarlyAbortReason
									,c.value('@StatementSubTreeCost', 'float')						AS StatementSubTreeCost
									,c.value('@StatementType', 'varchar(255)')						AS StatementType
									,c.value('@StatementText', 'varchar(max)')						AS StatementText
									--,c.value('@QueryHash', 'varchar(255)')							AS QueryHash
									--,c.value('@QueryPlanHash', 'varchar(255)')						AS QueryPlanHash
									--,qp.query_plan
									,c.query('*') Statements
						FROM		sys.dm_exec_cached_plans cp
						CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
						CROSS APPLY qp.query_plan.nodes('//StmtSimple') t(c)
						WHERE		qp.query_plan.exist('//StmtSimple') = 1
						) Data
			CROSS APPLY Statements.nodes('//RelOp') rel(operators)
			) Data
WHERE		(DatabaseName	= QUOTENAME(@DatabaseName,'[')	OR @DatabaseName IS NULL)
		AND	(TableName		= QUOTENAME(@TableName,'[')		OR @TableName IS NULL)
		AND	(IndexName		= QUOTENAME(@IndexName,'[')		OR @IndexName IS NULL)
		
		--AND	operators.value('@PhysicalOp','nvarchar(50)') IN ('Clustered Index Scan','Index Scan','Clustered Index Seek','Index Seek')



