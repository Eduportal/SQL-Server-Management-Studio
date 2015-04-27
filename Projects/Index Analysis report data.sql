
GO
ALTER PROCEDURE	[dbasp_Report_Index_Analysis_Detail]
			(
			@Server_Name		sysname = NULL
			,@Database_Name		sysname = NULL
			,@Table_Name		sysname = NULL
			)
AS

DECLARE		@CRLF		nChar (4)
SET		@CRLF		= CHAR(13)+CHAR(10)
		
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
		    			
		GROUP BY	server_name
				, database_name
				, table_name
				, IndexName
				, IndexColumns
				, IncludeColumns
		)
		,IndexCreate
		AS
		(
		SELECT		DISTINCT
				Server_Name
				, Database_name
				, Table_Name
				, IndexName AS Index_Name
				, '-----------------------------------------------------------------'+@CRLF
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
					')'+@CRLF+@CRLF+@CRLF AS [statement]
		FROM		dmv_MissingIndexSnapshot
			
		WHERE		COALESCE([IndexName],'') Like 'IX%'
		)	
		,IndexTest
		AS
		(
		SELECT		DISTINCT
				Server_Name
				, Database_name
				, Table_Name
				, [IndexName] AS Index_Name
				, REPLACE(COALESCE(
				    (
					SELECT	DISTINCT 
						@CRLF + @CRLF + '-- FROM SPROC:' + T2.[Sproc_name] + ' Statement #' + CAST(T2.[StatementID] AS nVarChar(50)) + @CRLF + @CRLF + T2.[StatementText] + @CRLF + @CRLF
					FROM	dmv_MissingIndexSnapshot T2
					WHERE	T2.[Server_Name]	= T1.[Server_Name] 
					    AND T2.[Database_name]	= T1.[Database_name]
					    AND T2.[IndexName]		= T1.[IndexName]

				    FOR XML PATH('')
				    )
				  , SPACE(0)),N'&#x0D;',SPACE(0)) AS [statement] 

		FROM		dmv_MissingIndexSnapshot T1
			
		WHERE		COALESCE([IndexName],'') Like 'IX%'
		)
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
		,T3.[statement] AS CreateStatement
		,T4.[statement] AS TestStatement
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
	
LEFT JOIN	IndexCreate T3	
	ON	T1.Server_Name				= T3.Server_Name
	AND	T1.Database_Name			= T3.Database_Name
	AND	T1.Table_Name				= T3.Table_Name
	AND	T1.index_name				= T3.Index_Name	
	
LEFT JOIN	IndexTest T4	
	ON	T1.Server_Name				= T4.Server_Name
	AND	T1.Database_Name			= T4.Database_Name
	AND	T1.Table_Name				= T4.Table_Name
	AND	T1.index_name				= T4.Index_Name
	
WHERE		(T1.Server_Name = @Server_Name		OR @Server_Name IS NULL)
	AND	(T1.Database_Name = @Database_Name	OR @Database_Name IS NULL)
	AND	(T1.Table_Name = @Table_Name		OR @Table_Name IS NULL)

ORDER BY	T1.Server_Name
		, T1.Database_Name
		, T1.Table_Name
		, T1.table_buffer_mb DESC
		, T1.impact desc
		, T1.user_total_read DESC			
GO	
	
	
	

DECLARE		@Server_Name		sysname
		, @Database_Name	sysname
		, @Table_Name		sysname
		
SELECT		@Server_Name		= @@SERVERNAME
		, @Database_Name	= 'WCDS'
		, @Table_Name		= 'OrderPromotion'
		

EXEC		dbaperf.dbo.[dbasp_Report_Index_Analysis_Detail] 
				@Server_Name
				, @Database_Name
				, @Table_Name

			
SELECT		Server_Name
		, Database_name
		, Table_Name
		, IndexName AS Index_Name
		, [Sproc_name]
		, [StatementID]
		, [StatementText]
		, [CompleteQueryPlan]
FROM		dmv_MissingIndexSnapshot T1

			
WHERE		(T1.Server_Name = @Server_Name		OR @Server_Name IS NULL)
	AND	(T1.Database_Name = @Database_Name	OR @Database_Name IS NULL)
	AND	(T1.Table_Name = @Table_Name		OR @Table_Name IS NULL)
	
ORDER BY	1,2,3,4,5,6
























