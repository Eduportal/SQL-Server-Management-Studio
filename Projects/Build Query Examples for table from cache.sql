SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
GO
SET NOCOUNT ON
GO
DECLARE @DatabaseName	sysname			= DB_NAME()
		,@TableName		sysname			= 'DeliveryTb'
		,@IndexName		sysname			--= 'IX_QueueTb_DeliveryId_StatusCode_I_AssetSizeBytes_NextAttemptDate'
		,@QueryText		VarChar(max)	= ''
		,@CommentStart	INT
		,@CommentEnd	INT
		,@DT1			VarChar(max)	= ''
		,@DT2			VarChar(max)	= ''
	
;WITH XMLNAMESPACES(DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
			,CacheData
			AS
			(
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
						,operators.query('*') RelOps
			FROM		(
						SELECT		cp.usecounts
									,c.value('@StatementEstRows', 'float')							AS StatementEstRows
									,c.value('@StatementOptmLevel', 'varchar(255)')					AS StatementOptmLevel
									,c.value('@StatementOptmEarlyAbortReason', 'varchar(255)')		AS StatementOptmEarlyAbortReason
									,c.value('@StatementSubTreeCost', 'float')						AS StatementSubTreeCost
									,c.value('@StatementType', 'varchar(255)')						AS StatementType
									,c.value('@StatementText', 'varchar(max)')						AS StatementText
									,c.query('*') Statements
						FROM		sys.dm_exec_cached_plans cp
						CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
						CROSS APPLY qp.query_plan.nodes('//StmtSimple') t(c)
						WHERE		qp.query_plan.exist('//StmtSimple') = 1
						) Data
			CROSS APPLY Statements.nodes('//RelOp') rel(operators)
			WHERE		(operators.value('(IndexScan/Object/@Database)[1]','sysname')	= QUOTENAME(@DatabaseName,'[')	OR @DatabaseName IS NULL)
					AND	(operators.value('(IndexScan/Object/@Table)[1]','sysname')		= QUOTENAME(@TableName,'[')		OR @TableName IS NULL)
					AND	(operators.value('(IndexScan/Object/@Index)[1]','sysname')		= QUOTENAME(@IndexName,'[')		OR @IndexName IS NULL)
			) 

SELECT		StatementText
			--,SUM(usecounts) usecounts
			,CAST(((SUM(usecounts) * 100.0) / (SELECT SUM(usecounts) FROM CacheData))+1 AS INT) PctTotal
INTO		#CacheChecker			
FROM		CacheData
GROUP BY	StatementText

DECLARE test_cursor CURSOR
FOR
SELECT		StatementText
			,PctTotal
FROM		#CacheChecker
ORDER BY	2 DESC

DECLARE @StatementText varchar(max)
		,@Weight INT
		
OPEN test_cursor
FETCH NEXT FROM test_cursor INTO @StatementText,@Weight
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		--PRINT '------------------------------------------------------------------------------------------------'
		--PRINT '------------------------------------------------------------------------------------------------'
		--PRINT '/*'
		--PRINT @StatementText
		--PRINT '*/'
		--PRINT '------------------------------------------------------------------------------------------------'
		--PRINT '------------------------------------------------------------------------------------------------'

		SET @StatementText	= REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@StatementText,CHAR(9),' '),'  ',' '),'  ',' '),'  ',' '),CHAR(13)+CHAR(10)+' ',CHAR(13)+CHAR(10)),CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10),CHAR(13)+CHAR(10))+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)

		SET @CommentStart	= CHARINDEX('/*',@StatementText)
		WHILE @CommentStart > 0
		BEGIN
			SET @CommentEnd		= CHARINDEX('*/',@StatementText,@CommentStart)
			SET @StatementText	= STUFF(@StatementText,@CommentStart,(@CommentEnd-@CommentStart)+2,'')
			SET @CommentStart	= CHARINDEX('/*',@StatementText)
		END

		SET @CommentStart	= CHARINDEX('--',@StatementText)
		WHILE @CommentStart > 0
		BEGIN
			SET @CommentEnd		= CHARINDEX(CHAR(13)+CHAR(10),@StatementText,@CommentStart)
			SET @StatementText	= STUFF(@StatementText,@CommentStart,(@CommentEnd-@CommentStart)+2,'')
			SET @CommentStart	= CHARINDEX('--',@StatementText)
		END
		
		SELECT		@StatementText = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
						@StatementText
						,CHAR(9),' '),'  ',' '),'  ',' '),'  ',' '),CHAR(13)+CHAR(10)+' ',CHAR(13)+CHAR(10)),CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10),CHAR(13)+CHAR(10)),CHAR(13)+CHAR(10)+' ',CHAR(13)+CHAR(10)),CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10),CHAR(13)+CHAR(10)),CHAR(13)+' ',CHAR(13)),CHAR(10)+' ',CHAR(10))
					,@DT1 = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
						@StatementText
						,CHAR(13)+CHAR(10),' '),',',' '),'(',' '),')',' '),'+',' '),'-',' '),'*',' '),'/',' '),'=',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' ')
					,@DT2 = ''
										
		SELECT		@DT2		= @DT2 + 'DECLARE '+ COALESCE(SplitValue,'') + ' Sql_Variant' + CHAR(13)+CHAR(10)
		FROM		(
					SELECT		DISTINCT
								SplitValue 
					FROM		[DBAadmin].[dbo].dbaudf_split (LTRIM(RTRIM(@DT1)),' ')
					WHERE		SplitValue LIKE '@%'
							AND	SplitValue NOT LIKE '@@%'
					) Data
		
		PRINT '------------------------------------------------------------------------------------------------'			
		PRINT @DT2
		PRINT '------------------------------------------------------------------------------------------------'
		PRINT ''
		PRINT @StatementText
		PRINT ''
		PRINT 'GO ' + CAST(@Weight AS VarChar(50))
		PRINT '------------------------------------------------------------------------------------------------'
		PRINT '------------------------------------------------------------------------------------------------'
		PRINT ''
		PRINT ''
	END
	FETCH NEXT FROM test_cursor INTO @StatementText,@Weight
END
CLOSE test_cursor
DEALLOCATE test_cursor
GO

DROP TABLE #CacheChecker
GO
