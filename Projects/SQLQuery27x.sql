DECLARE		@server_name		sysname =	--'SEAPSQLDIST0A'
											--'FRESSQLDIST0A' 
											@@SERVERNAME 
			,@database_name		sysname	= 'DeliveryDb'
			,@table_name		sysname	= 'QueueTb'
			

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

  
SELECT [server_name]
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
  FROM [dbo].[dmv_MissingIndexSnapshot]
  WHERE server_name = @server_name
  AND database_name = @database_name
  AND table_name = @table_name  
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
  AND table_name = @table_name
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
  AND table_name = @table_name
  AND index_action = 'DROP'