DECLARE	@Database_Name sysname, @Table_name sysname, @PopulateDMVsForAll bit

SELECT		@database_name		= QUOTENAME('WCDS')
		,@table_name		= QUOTENAME('OrderPromotion')

DELETE		dmv_MissingIndexSnapshot		
WHERE		(
		QUOTENAME(database_name) = @database_name
		OR @database_name IS NULL
		OR @PopulateDMVsForAll = 1
		)
	AND	(
		QUOTENAME(table_name) = @table_name
		OR @table_name IS NULL
		OR @PopulateDMVsForAll = 1
		)
				

	;WITH	XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
		, PlanData AS
		( 
		SELECT		ecp.plan_handle
				, MissingIndex.value ('(.//MissingIndex/@Database)[1]','sysname')	AS database_name
				, MissingIndex.value ('(.//MissingIndex/@Schema)[1]','sysname')		AS schema_name
				, MissingIndex.value ('(.//MissingIndex/@Table)[1]','sysname')		AS table_name
				, MissingIndex.query ('.')						AS Statements 
				, MissingIndex.value ('(./@StatementId)[1]', 'int')			AS StatementID 
				, MissingIndex.value ('(./@StatementText)[1]', 'varchar(max)')		AS StatementText 
				, MissingIndex.value ('(./@StatementSubTreeCost)[1]', 'float')		AS StatementSubTreeCost
				, MissingIndex.value ('(.//MissingIndexGroup/@Impact)[1]','float')	AS Impact
				, usecounts								AS UseCounts
				, eqp.[dbid]
				, eqp.[objectid]
				, ecp.objtype

		FROM		sys.dm_exec_cached_plans		AS ecp
		CROSS APPLY	sys.dm_exec_query_plan(ecp.plan_handle)	AS eqp
		CROSS APPLY	query_plan.nodes
				 ('for $stmt in .//Statements/*
				where	count($stmt/Condition/QueryPlan/MissingIndexes) > 0
				or	count($stmt/QueryPlan/MissingIndexes) > 0
				return $stmt')				AS qp(MissingIndex)
		WHERE		(
				MissingIndex.exist 
				 ('.//MissingIndex[@Database = sql:variable("@database_name")]') = 1
				OR @database_name IS NULL
				OR @PopulateDMVsForAll = 1
				)
			AND	(
				MissingIndex.exist 
				 ('.//MissingIndex[@Table = sql:variable("@table_name")]') = 1
				OR @table_name IS NULL
				OR @PopulateDMVsForAll = 1
				)
		)
		, FormatedData AS
		(	
		SELECT		@@ServerName				AS server_name
				, REPLACE(REPLACE(
				  [database_name]
				  ,'[',''),']','')			AS database_name
				, DB_ID(REPLACE(REPLACE(
				  [database_name]
				  ,'[',''),']',''))			AS database_id
				, SCHEMA_ID(REPLACE(REPLACE(
				  [schema_name]
				  ,'[',''),']',''))			AS schema_id
				, REPLACE(REPLACE(
				  [schema_name]
				  ,'[',''),']','')			AS schema_name
				, OBJECT_ID(
				  [database_name]
				  +'.'+[schema_name]
				  +'.'+[table_name]
				  )					AS object_id
				, REPLACE(REPLACE(
				  [table_name]
				   ,'[',''),']','')			AS table_name
				, [StatementSubTreeCost]
				  * ISNULL([Impact], 0) 
				  * usecounts				AS Improvement 
				, [Statements]				AS CompleteQueryPlan 
				, OBJECT_NAME([objectid],[dbid])	AS Sproc_name
				, [StatementId]				AS StatementID 
				, [StatementText]			AS StatementText 
				, [StatementSubTreeCost]		AS StatementSubTreeCost
				, NULL					AS MissingIndex 
				, [Impact]				AS IndexImpact 
				, [usecounts]				AS UseCounts
				
				, REPLACE(CAST(Mi.query
				   ('data( for $cg in .//ColumnGroup
					where $cg/@Usage="EQUALITY" or $cg/@Usage="INEQUALITY"
					return $cg/Column/@Name	)')
					AS NVarchar(4000)),'] [','], [')				AS IndexColumns
					
				, REPLACE(CAST(Mi.query
				   ('data( for $cg in .//ColumnGroup
					where $cg/@Usage="INCLUDE"
					return $cg/Column/@Name	)')
					AS NVarchar(4000)),'] [','], [')				AS IncludeColumns
					
				,REPLACE(REPLACE(REPLACE(CAST(Mi.query
				    ('data( for $cg in .//ColumnGroup
					where $cg/@Usage="EQUALITY" or $cg/@Usage="INEQUALITY"
					return $cg/Column/@ColumnId )')
					AS NVarchar(4000)),'[',''),']',''),' ','_')			AS IndexColumnIDs
				,REPLACE(REPLACE(REPLACE(CAST(Mi.query
				   ('data( for $cg in .//ColumnGroup
					where $cg/@Usage="INCLUDE"
					return $cg/Column/@ColumnId )')
					AS NVarchar(4000)),'[',''),']',''),' ','_')			AS IncludeColumnIDs
				
		From		PlanData				AS pd
		CROSS APPLY	Statements.nodes
				 ('.//MissingIndex')			AS St(Mi)
		)		
	INSERT INTO	dmv_MissingIndexSnapshot		
	SELECT		server_name
			, database_name
			, database_id
			, schema_id
			, schema_name
			, object_id
			, table_name
			, Improvement 
			, CompleteQueryPlan 
			, Sproc_name
			, StatementID 
			, StatementText 
			, StatementSubTreeCost
			, MissingIndex 
			, IndexImpact 
			, UseCounts
			, IndexColumns
			, ', ' + [IncludeColumns]		AS IncludeColumns
			, 'IX_' 
			+ REPLACE(REPLACE(
			  [table_name]
			   ,'[',''),']','')
			+ '_'
			+ [IndexColumnIDs]
			+ CASE
			  WHEN [IncludeColumnIDs] = ''
			  THEN ''
			  ELSE '_INC_' + [IncludeColumnIDs]
			  END					AS IndexName				
		
			
			
	FROM		FormatedData
				
	ORDER BY	Improvement DESC