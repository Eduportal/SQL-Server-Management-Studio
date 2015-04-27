DECLARE		@CRLF				VarChar(2) = CHAR(13)+CHAR(10)
			,@server_name		sysname =	--'SEAPSQLDIST0A'
											--'FRESSQLDIST0A' 
											@@SERVERNAME 
			,@database_name		sysname	= 'DeliveryDb'
			,@table_name		sysname	= 'dbo.DeliveryTb'
			

--SELECT [Table Class]
--      ,[server_name]
--      ,[database_name]
--      ,[table_name]
--      ,[Table_Rows]
--      ,[table_pages]
--      ,[table_size_GB]
--      ,[index_pages]
--      ,[index_size_GB]
--      ,[wasted_pages]
--      ,[wasted_size_GB]
--      ,[Blends]
--      ,[Creates]
--      ,[Drops]
--      ,[Realignes]
--      ,[existing_indexes]
--  FROM [dbo].[GIMPI_Database]
--  WHERE server_name = @server_name
--  AND database_name = @database_name
--  ORDER BY [table_size_GB] desc

		SELECT		DISTINCT
				Server_Name
				, Database_name
				, Table_Name
				, Index_Name 
				, '-----------------------------------------------------------------'+@CRLF
				+ '-----------------------------------------------------------------'+@CRLF
				+ '--		CREATE INDEX'+ COALESCE(Index_Name,'')+@CRLF
				+ '-----------------------------------------------------------------'+@CRLF
				+ '-----------------------------------------------------------------'+@CRLF+@CRLF
				+ REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
					'USE [{DATABASE_NAME}]'+@CRLF+@CRLF+
					'IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N''[{SCHEMA_NAME}].[{TABLE_NAME}]'') AND name = N''{INDEX_NAME}'')'+@CRLF+
					'CREATE INDEX [{INDEX_NAME}] ON [{SCHEMA_NAME}].[{TABLE_NAME}]'+@CRLF+
					'('+@CRLF+
					'	{INDEX_COLUMNS}'+@CRLF+
					')'+@CRLF
					,'{DATABASE_NAME}'	,database_name)
					,'{SCHEMA_NAME}'	,schema_name)
					,'{TABLE_NAME}'		,table_name)
					,'{INDEX_NAME}'		,Index_Name)
					,'{INDEX_COLUMNS}'	,Indexed_Columns)
				+ COALESCE(
					'INCLUDE'+@CRLF+
					'('+@CRLF+
					'	'+STUFF(Included_Columns,1,1,'')+@CRLF+
					')'+@CRLF
					,'')

				+ 'WITH'+@CRLF+ 
					'('+@CRLF+
					'  SORT_IN_TEMPDB	 = ON'+@CRLF+
					', IGNORE_DUP_KEY	 = OFF'+@CRLF+
					', DROP_EXISTING		 = OFF'+@CRLF+
					', ONLINE		 = ON'+@CRLF+
					', PAD_INDEX		 = OFF'+@CRLF+
					', STATISTICS_NORECOMPUTE = OFF'+@CRLF+
					', ALLOW_ROW_LOCKS	 = ON'+@CRLF+
					', ALLOW_PAGE_LOCKS	 = ON'+@CRLF+
					')'+@CRLF+@CRLF+@CRLF AS [Statement_Create]
				, '-----------------------------------------------------------------'+@CRLF
				+ '-----------------------------------------------------------------'+@CRLF
				+ '--		DROP INDEX '+ COALESCE(Index_Name,'')+@CRLF
				+ '-----------------------------------------------------------------'+@CRLF
				+ '-----------------------------------------------------------------'+@CRLF+@CRLF
				+ REPLACE(REPLACE(REPLACE(REPLACE(
					'USE [{DATABASE_NAME}]'+@CRLF+@CRLF+
					'IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N''[{SCHEMA_NAME}].[{TABLE_NAME}]'') AND name = N''{INDEX_NAME}'')'+@CRLF+
					'ALTER TABLE [{SCHEMA_NAME}].[{TABLE_NAME}] DROP CONSTRAINT [{INDEX_NAME}]'+@CRLF
					,'{DATABASE_NAME}'	,database_name)
					,'{SCHEMA_NAME}'	,schema_name)
					,'{TABLE_NAME}'		,table_name)
					,'{INDEX_NAME}'		,Index_Name) AS [Statement_Drop]
		FROM		dmv_IndexBaseLine
		WHERE		Server_Name = @Server_Name
			AND	Database_Name = @Database_Name
			AND	schema_name + '.' + table_name = @Table_Name



;WITH		MissingIndexSnapshot
		AS
		(
		SELECT		server_name
				, database_name
				, table_name
				, IndexName AS Index_Name
				, IndexColumns
				, IncludeColumns
				, SUM(UseCounts) UseCounts
				, SUM(CAST(StatementSubTreeCost AS Float)) StatementSubTreeCost
				, SUM(IndexImpact) IndexImpact
				, SUM(Improvement) Improvement

		FROM		dmv_MissingIndexSnapshot
		WHERE		COALESCE([IndexName],'') Like 'IX%'
			AND	Server_Name = @Server_Name
			AND	Database_Name = @Database_Name
			AND	schema_name + '.' + table_name = @Table_Name		    			
		GROUP BY	server_name
				, database_name
				, table_name
				, IndexName
				, IndexColumns
				, IncludeColumns
		)
		,IndexTSQL
		AS
		(
		SELECT		DISTINCT
				Server_Name
				, Database_name
				, Table_Name
				, Index_Name 
				, '-----------------------------------------------------------------'+@CRLF
				+ '-----------------------------------------------------------------'+@CRLF
				+ '--		CREATE INDEX'+ COALESCE(Index_Name,'')+@CRLF
				+ '-----------------------------------------------------------------'+@CRLF
				+ '-----------------------------------------------------------------'+@CRLF+@CRLF
				+ REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
					'USE [{DATABASE_NAME}]'+@CRLF+@CRLF+
					'IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N''[{SCHEMA_NAME}].[{TABLE_NAME}]'') AND name = N''{INDEX_NAME}'')'+@CRLF+
					'CREATE INDEX [{INDEX_NAME}] ON [{SCHEMA_NAME}].[{TABLE_NAME}]'+@CRLF+
					'('+@CRLF+
					'	{INDEX_COLUMNS}'+@CRLF+
					')'+@CRLF
					,'{DATABASE_NAME}'	,database_name)
					,'{SCHEMA_NAME}'	,schema_name)
					,'{TABLE_NAME}'		,table_name)
					,'{INDEX_NAME}'		,Index_Name)
					,'{INDEX_COLUMNS}'	,Indexed_Columns)
				+ COALESCE(
					'INCLUDE'+@CRLF+
					'('+@CRLF+
					'	'+STUFF(Included_Columns,1,1,'')+@CRLF+
					')'+@CRLF
					,'')

				+ 'WITH'+@CRLF+ 
					'('+@CRLF+
					'  SORT_IN_TEMPDB	 = ON'+@CRLF+
					', IGNORE_DUP_KEY	 = OFF'+@CRLF+
					', DROP_EXISTING		 = OFF'+@CRLF+
					', ONLINE		 = ON'+@CRLF+
					', PAD_INDEX		 = OFF'+@CRLF+
					', STATISTICS_NORECOMPUTE = OFF'+@CRLF+
					', ALLOW_ROW_LOCKS	 = ON'+@CRLF+
					', ALLOW_PAGE_LOCKS	 = ON'+@CRLF+
					')'+@CRLF+@CRLF+@CRLF AS [Statement_Create]
				, '-----------------------------------------------------------------'+@CRLF
				+ '-----------------------------------------------------------------'+@CRLF
				+ '--		DROP INDEX '+ COALESCE(Index_Name,'')+@CRLF
				+ '-----------------------------------------------------------------'+@CRLF
				+ '-----------------------------------------------------------------'+@CRLF+@CRLF
				+ REPLACE(REPLACE(REPLACE(REPLACE(
					'USE [{DATABASE_NAME}]'+@CRLF+@CRLF+
					'IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N''[{SCHEMA_NAME}].[{TABLE_NAME}]'') AND name = N''{INDEX_NAME}'')'+@CRLF+
					'ALTER TABLE [{SCHEMA_NAME}].[{TABLE_NAME}] DROP CONSTRAINT [{INDEX_NAME}]'+@CRLF
					,'{DATABASE_NAME}'	,database_name)
					,'{SCHEMA_NAME}'	,schema_name)
					,'{TABLE_NAME}'		,table_name)
					,'{INDEX_NAME}'		,Index_Name) AS [Statement_Drop]
		FROM		dmv_IndexBaseLine
		WHERE		Server_Name = @Server_Name
			AND	Database_Name = @Database_Name
			AND	schema_name + '.' + table_name = @Table_Name
		)	
		--,IndexTest
		--AS
		--(
		--SELECT		DISTINCT
		--		Server_Name
		--		, Database_name
		--		, Table_Name
		--		, [IndexName] AS Index_Name
		--		, REPLACE(COALESCE(
		--		    (
		--			SELECT	DISTINCT 
		--				@CRLF + @CRLF + '-- FROM SPROC:' + T2.[Sproc_name] + ' Statement #' + CAST(T2.[StatementID] AS nVarChar(50)) + @CRLF + @CRLF + T2.[StatementText] + @CRLF + @CRLF
		--			FROM	dmv_MissingIndexSnapshot T2
		--			WHERE	T2.[Server_Name]	= T1.[Server_Name] 
		--			    AND T2.[Database_name]	= T1.[Database_name]
		--			    AND T2.[IndexName]		= T1.[IndexName]

		--		    FOR XML PATH('')
		--		    )
		--		  , SPACE(0)),N'&#x0D;',SPACE(0)) AS [statement] 

		--FROM		dmv_MissingIndexSnapshot T1
			
		--WHERE		COALESCE([IndexName],'') Like 'IX%'
		--)
SELECT		T1.server_name
		,T1.database_name
		,T1.schema_name + '.' + T1.table_name as object_name
		,T1.has_unique
		,T1.table_buffer_mb
		,T1.index_action
		,T1.index_name
		,T1.indexed_columns
		,T1.included_columns
		,T1.is_unique
		,REPLACE(T1.type_desc,'-','') AS type_desc
		,T1.impact AS impact_estimate_curent
		,T2.Improvement AS impact_estimate_cached
		,T2.[IndexImpact]
		,T1.size_in_mb
		,T1.buffer_mb
		,T1.pct_in_buffer
		,T1.row_count
		,T1.page_count
		,T1.max_key_size
		,T1.user_total_read
		,T1.user_total_read_pct
		,T1.estimated_user_total_read_pct
		,T1.user_total_write
		,T1.user_total_write_pct
		,T1.estimated_user_total_write_pct
		,T1.index_read_pct
		,T1.index_write_pct
		,T1.user_seeks
		,T1.user_scans
		,T1.user_lookups
		,T1.user_updates
		,T1.row_lock_count
		,T1.row_lock_wait_count
		,T1.row_lock_wait_in_ms
		,T1.row_block_pct
		,T1.avg_row_lock_waits_ms
		,T1.page_lock_count
		,T1.page_lock_wait_count
		,T1.page_lock_wait_in_ms
		,T1.page_block_pct
		,T1.avg_page_lock_waits_ms
		,T1.splits
		,T1.indexed_column_count
		,T1.included_column_count
		,T1.duplicate_indexes
		,T1.overlapping_indexes
		,T1.related_foreign_keys
		,T1.related_foreign_keys_xml
		,T2.[usecounts]
		,T2.StatementSubTreeCost
		,CAST(T3.[Statement_Create] AS XML) AS CreateStatement
		,CAST(T3.[Statement_Drop] AS XML) AS DropStatement
		,NULL AS TestStatement
		,CASE T1.index_action
			WHEN 'CREATE' THEN 1
			WHEN 'BLEND' THEN 1
			ELSE 0 END AS Issue_Missing
			
		,CASE T1.index_action
			WHEN 'Drop' THEN 1
			ELSE 0 END AS Issue_Drop
			
		,CASE T1.index_action
			WHEN 'REALIGN' Then 1
			ELSE 0 END AS Issue_Realign
		
		,CASE WHEN T1.index_read_pct < 5 THEN 1 ELSE 0 END AS Issue_LowRead
			
		,CASE WHEN T1.Splits > (T1.user_updates / 2) THEN 1 ELSE 0 END AS Issue_HighSplits
			
		,CASE WHEN T1.duplicate_indexes IS NULL THEN 0 ELSE 1 END AS Issue_Duplicates	
		
		,CASE WHEN T1.overlapping_indexes IS NULL THEN 0 ELSE 1 END AS Issue_Overlaps
FROM		dmv_IndexBaseLine T1
LEFT JOIN	MissingIndexSnapshot T2
	ON	T1.Server_Name				= T2.Server_Name
	AND	T1.Database_Name			= T2.Database_Name
	AND	T1.Table_Name				= T2.Table_Name
	AND	T1.index_name				= T2.Index_Name
	AND	T1.type_desc				= '--NONCLUSTERED--'
	
LEFT JOIN	IndexTSQL T3	
	ON	T1.Server_Name				= T3.Server_Name
	AND	T1.Database_Name			= T3.Database_Name
	AND	T1.Table_Name				= T3.Table_Name
	AND	T1.index_name				= T3.Index_Name	
	
--LEFT JOIN	IndexTest T4	
--	ON	T1.Server_Name				= T4.Server_Name
--	AND	T1.Database_Name			= T4.Database_Name
--	AND	T1.Table_Name				= T4.Table_Name
--	AND	T1.index_name				= T4.Index_Name
	
WHERE		T1.Server_Name = @Server_Name
	AND	T1.Database_Name = @Database_Name
	AND	T1.schema_name + '.' + T1.table_name = @Table_Name

ORDER BY	T1.Server_Name
		, T1.Database_Name
		, T1.Table_Name
		, T1.table_buffer_mb DESC
		, T1.impact desc
		, T1.user_total_read DESC			





  
SELECT		[server_name]
			,[database_name]
			,[database_id]
			,[schema_id]
			,[schema_name]
			,[object_id]
			,[table_name]
			,[Improvement]
			,[CompleteQueryPlan]
			,[Sproc_name]
			,[StatementID]
			,[StatementText]
			,[StatementSubTreeCost]
			,[MissingIndex]
			,[IndexImpact]
			,[usecounts]
			,[IndexColumns]
			,[IncludeColumns]
			,[IndexName]
			,[SnapShotDate]
			,CAST('-----------------------------------------------------------------'+@CRLF
			+ '-----------------------------------------------------------------'+@CRLF
			+ '--		CREATE INDEX'+ COALESCE(IndexName,'')+@CRLF
			+ '-----------------------------------------------------------------'+@CRLF
			+ '-----------------------------------------------------------------'+@CRLF+@CRLF
			+ REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			'USE [{DATABASE_NAME}]'+@CRLF+@CRLF+
			'IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N''[{SCHEMA_NAME}].[{TABLE_NAME}]'') AND name = N''{INDEX_NAME}'')'+@CRLF+
			'CREATE INDEX [{INDEX_NAME}] ON [{SCHEMA_NAME}].[{TABLE_NAME}]'+@CRLF+
			'('+@CRLF+
			'	{INDEX_COLUMNS}'+@CRLF+
			')'+@CRLF
			,'{DATABASE_NAME}'	,database_name)
			,'{SCHEMA_NAME}'	,schema_name)
			,'{TABLE_NAME}'		,table_name)
			,'{INDEX_NAME}'		,IndexName)
			,'{INDEX_COLUMNS}'	,IndexColumns)
			+ COALESCE(
			'INCLUDE'+@CRLF+
			'('+@CRLF+
			'	'+STUFF(IncludeColumns,1,1,'')+@CRLF+
			')'+@CRLF
			,'')
			+ 'WITH'+@CRLF+ 
			'('+@CRLF+
			'  SORT_IN_TEMPDB	 = ON'+@CRLF+
			', IGNORE_DUP_KEY	 = OFF'+@CRLF+
			', DROP_EXISTING		 = OFF'+@CRLF+
			', ONLINE		 = ON'+@CRLF+
			', PAD_INDEX		 = OFF'+@CRLF+
			', STATISTICS_NORECOMPUTE = OFF'+@CRLF+
			', ALLOW_ROW_LOCKS	 = ON'+@CRLF+
			', ALLOW_PAGE_LOCKS	 = ON'+@CRLF+
			')'+@CRLF+@CRLF+@CRLF AS XML) AS [Statement_Create]

  FROM [dbo].[dmv_MissingIndexSnapshot]
  WHERE server_name = @server_name
  AND database_name = @database_name
  AND schema_name + '.' + table_name = @Table_Name
  ORDER BY [improvement] desc  



SELECT [row_id]
      ,[server_name]
      ,[database_name]
      ,[database_id]
      ,[index_action]
      ,[schema_id]
      ,[schema_name]
      ,[object_id]
      ,[table_name]
      ,[index_id]
      ,[index_name]
      ,[is_unique]
      ,[has_unique]
      ,[type_desc]
      ,[partition_number]
      ,[reserved_page_count]
      ,[page_count]
      ,[max_key_size]
      ,[size_in_mb]
      ,[buffered_page_count]
      ,[buffer_mb]
      ,[pct_in_buffer]
      ,[table_buffer_mb]
      ,[row_count]
      ,[impact]
      ,[existing_ranking]
      ,[user_total_read]
      ,[user_total_read_pct]
      ,[estimated_user_total_read_pct]
      ,[user_total_write]
      ,[user_total_write_pct]
      ,[estimated_user_total_write_pct]
      ,[index_read_pct]
      ,[index_write_pct]
      ,[user_seeks]
      ,[user_scans]
      ,[user_lookups]
      ,[user_updates]
      ,[row_lock_count]
      ,[row_lock_wait_count]
      ,[row_lock_wait_in_ms]
      ,[row_block_pct]
      ,[avg_row_lock_waits_ms]
      ,[page_lock_count]
      ,[page_lock_wait_count]
      ,[page_lock_wait_in_ms]
      ,[page_block_pct]
      ,[avg_page_lock_waits_ms]
      ,[splits]
      ,[indexed_columns]
      ,[indexed_column_count]
      ,[included_columns]
      ,[included_column_count]
      ,[indexed_columns_compare]
      ,[included_columns_compare]
      ,[duplicate_indexes]
      ,[overlapping_indexes]
      ,[related_foreign_keys]
      ,[related_foreign_keys_xml]
      ,[SnapShotDate]
  FROM [dbo].[dmv_IndexBaseLine]
  WHERE server_name = @server_name
  AND database_name = @database_name
  AND schema_name + '.' + table_name = @Table_Name
  ORDER BY [index_action]


	
  SELECT	SUM([size_in_mb])		[size_in_mb]
		  ,SUM([buffer_mb])			[buffer_mb]
		  ,MAX([table_buffer_mb])	[table_buffer_mb]
		  ,SUM([splits])			[splits]
		  ,SUM([user_total_read])	[Reads]
		  ,SUM([user_total_write])	[Writes]
		  
  FROM [dbo].[dmv_IndexBaseLine]
  WHERE server_name = @server_name
  AND database_name = @database_name
  AND schema_name + '.' + table_name = @Table_Name
  AND index_action = 'DROP'