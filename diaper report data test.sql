DECLARE		@ServerName	SYSNAME		= 'SEADCPCSQLA\A'
		,@DatabaseName	SYSNAME		= 'ProductCatalog'
		,@RunDate	DATETIME	= '6/11/2015 12:00:00 AM'



--SELECT		DISTINCT
--		rundate
--FROM		[DBAperf_reports].[dbo].[IndexHealth_Results]
--WHERE		[ServerName] = @ServerName
--	AND	[DatabaseName]	= @DatabaseName
--ORDER BY	rundate desc

--SELECT		TOP 1
--		rundate
--FROM		[DBAperf_reports].[dbo].[IndexHealth_Results]
--WHERE		[ServerName] = @ServerName
--	AND	[DatabaseName]	= @DatabaseName
--ORDER BY	rundate desc

--SELECT		DISTINCT
--		[ServerName]
--FROM		[DBAperf_reports].[dbo].[IndexHealth_Results]


--SELECT		DISTINCT
--		[DatabaseName]
--FROM		[DBAperf_reports].[dbo].[IndexHealth_Results]
--WHERE		[ServerName] = @ServerName


SELECT		[rundate]
		,[ServerName]
		,[DatabaseName]
		,[SchemaName]
		,[TableName]
		,[IHCR_id]
		,[check_id]
		,[findings_group]
		,[finding]
		,[URL]
		,[details]
		--,CAST(REPLACE(DBAADMIN.DBO.DBAUDF_ReturnPart(replace([details],' estimated benefit: ','|'),2),',','') AS VarChar(1000))
		,CAST(REPLACE(DBAADMIN.DBO.DBAUDF_ReturnPart(replace(REPLACE([details],'|PARENT',';PARENT'),' estimated benefit: ','|'),2),',','') AS BIGINT) [Benefit]
		,[index_definition]
		,[secret_columns]
		,[index_usage_summary]
		,DBAADMIN.DBO.DBAUDF_ReturnPart(replace(replace([index_usage_summary],' uses; Impact: ','|'),'; Avg query cost: ','|'),2) [Impact]
		,DBAADMIN.DBO.DBAUDF_ReturnPart(replace(replace([index_usage_summary],' uses; Impact: ','|'),'; Avg query cost: ','|'),3) [Cost]
		,[index_size_summary]
		--,CAST(CASE 
		--	WHEN [finding] = 'Cascading Updates or Deletes'
		--	THEN '0'
		--	WHEN [finding] = 'Disabled Index'
		--	THEN '0'
		--	WHEN [finding] = 'Hypothetical Index'
		--	THEN '0'
		--	WHEN [findings_group] = 'Indexaphobia'
		--	THEN '0'
		--	WHEN [findings_group] = 'Feature-Phobic Indexes'
		--	THEN '0'
		--	WHEN [index_size_summary] LIKE '% PARTITIONS] %'
		--	THEN COALESCE(REPLACE(DBAADMIN.DBO.DBAUDF_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([index_size_summary],' (MAX)',''),' (ALL)',''),' rows; ','|'),';','|'),' rows','|'),' PARTITIONS] ','|'),2),',',''),'0')
		--	ELSE COALESCE(REPLACE(DBAADMIN.DBO.DBAUDF_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([index_size_summary],' (MAX)',''),' (ALL)',''),' rows; ','|'),';','|'),' rows','|'),1),',',''),'0')
		--	END AS VarChar(1000))
		--,CASE 
		--	WHEN [finding] = 'Cascading Updates or Deletes'
		--	THEN '0'
		--	WHEN [finding] = 'Disabled Index'
		--	THEN '0'
		--	WHEN [finding] = 'Hypothetical Index'
		--	THEN '0'
		--	WHEN [findings_group] = 'Indexaphobia'
		--	THEN '0'
		--	WHEN [findings_group] = 'Feature-Phobic Indexes'
		--	THEN '0'
		--	ELSE COALESCE(REPLACE(REPLACE(REPLACE(DBAADMIN.DBO.DBAUDF_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE([index_size_summary],' (MAX)',''),' (ALL)',''),' rows; ','|'),';','|'),2),'MB',''),'GB',''),',',''),'0')
		--	END
		,CAST(CASE 
			WHEN [finding] = 'Cascading Updates or Deletes'
			THEN '0'
			WHEN [finding] = 'Disabled Index'
			THEN '0'
			WHEN [finding] = 'Hypothetical Index'
			THEN '0'
			WHEN [findings_group] = 'Indexaphobia'
			THEN '0'
			WHEN [findings_group] = 'Feature-Phobic Indexes'
			THEN '0'
			WHEN [index_size_summary] LIKE '% PARTITIONS] %'
			THEN COALESCE(REPLACE(DBAADMIN.DBO.DBAUDF_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([index_size_summary],' (MAX)',''),' (ALL)',''),' rows; ','|'),';','|'),' rows','|'),' PARTITIONS] ','|'),2),',',''),'0')
			ELSE COALESCE(REPLACE(DBAADMIN.DBO.DBAUDF_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([index_size_summary],' (MAX)',''),' (ALL)',''),' rows; ','|'),';','|'),' rows','|'),1),',',''),'0')
			END AS FLOAT) [Rows]
		,CAST(CASE 
			WHEN [finding] = 'Cascading Updates or Deletes'
			THEN '0'
			WHEN [finding] = 'Disabled Index'
			THEN '0'
			WHEN [finding] = 'Hypothetical Index'
			THEN '0'
			WHEN [findings_group] = 'Indexaphobia'
			THEN '0'
			WHEN [findings_group] = 'Feature-Phobic Indexes'
			THEN '0'
			ELSE COALESCE(REPLACE(REPLACE(REPLACE(DBAADMIN.DBO.DBAUDF_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE([index_size_summary],' (MAX)',''),' (ALL)',''),' rows; ','|'),';','|'),2),'MB',''),'GB',''),',',''),'0')
			END AS FLOAT) [Size]

		,CASE WHEN RIGHT(DBAADMIN.DBO.DBAUDF_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE([index_size_summary],' (MAX)',''),' (ALL)',''),' rows; ','|'),';','|'),2),2) = 'GB'
					THEN 1024.0
					ELSE 1.0
					END  [Size_Multiplier]

		,COALESCE(CAST(REPLACE(REPLACE(REPLACE(REPLACE(DBAADMIN.DBO.DBAUDF_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE([index_size_summary],' (MAX)',''),' (ALL)',''),' rows; ','|'),';','|'),3),'MB',''),'GB',''),',',''),' LOB','') AS FLOAT),0.0) [LOB_Size]

		,CASE WHEN RIGHT(REPLACE(DBAADMIN.DBO.DBAUDF_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE([index_size_summary],' (MAX)',''),' (ALL)',''),' rows; ','|'),';','|'),3),' LOB',''),2) = 'GB'
					THEN 1024.0
					ELSE 1.0
					END  [LOB_Size_Multiplier]
		,[create_tsql]
		,[more_info]
		,[database_id]
		,[object_id]
		,[index_id]
		,[index_type]
		,[database_name]
		,[schema_name]
		,[object_name]
		,[index_name]
		,[key_column_names]
		,[key_column_names_with_sort_order]
		,[key_column_names_with_sort_order_no_types]
		,[count_key_columns]
		,[include_column_names]
		,[include_column_names_no_types]
		,[count_included_columns]
		,[partition_key_column_name]
		,[filter_definition]
		,[is_indexed_view]
		,[is_unique]
		,[is_primary_key]
		,[is_XML]
		,[is_spatial]
		,[is_NC_columnstore]
		,[is_CX_columnstore]
		,[is_disabled]
		,[is_hypothetical]
		,[is_padded]
		,[fill_factor]
		,[user_seeks]
		,[user_scans]
		,[user_lookups]
		,[user_updates]
		,[last_user_seek]
		,[last_user_scan]
		,[last_user_lookup]
		,[last_user_update]
		,[is_referenced_by_foreign_key]
		,[secret_columns_2]
		,[count_secret_columns]
		,[create_date]
		,[modify_date]
		,[create_tsql_2]
		,[stat_date]

FROM		[DBAperf_reports].[dbo].[IndexHealth_Results]

--WHERE		[Finding] like '%Disabled%'
--WHERE		ISNUMERIC(CASE 
--			WHEN [finding] = 'Cascading Updates or Deletes'
--			THEN '0'
--			WHEN [finding] = 'Disabled Index'
--			THEN '0'
--			WHEN [finding] = 'Hypothetical Index'
--			THEN '0'
--			WHEN [findings_group] = 'Indexaphobia'
--			THEN '0'
--			WHEN [findings_group] = 'Feature-Phobic Indexes'
--			THEN '0'
--			WHEN [index_size_summary] LIKE '% PARTITIONS] %'
--			THEN COALESCE(REPLACE(DBAADMIN.DBO.DBAUDF_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([index_size_summary],' (MAX)',''),' (ALL)',''),' rows; ','|'),';','|'),' rows','|'),' PARTITIONS] ','|'),2),',',''),'0')
--			ELSE COALESCE(REPLACE(DBAADMIN.DBO.DBAUDF_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([index_size_summary],' (MAX)',''),' (ALL)',''),' rows; ','|'),';','|'),' rows','|'),1),',',''),'0')
--			END) = 0 




WHERE		[ServerName]	= @ServerName
	AND	[DatabaseName]	= @DatabaseName
	AND	[rundate] 	= @rundate
--ORDER BY	IHCR_id


