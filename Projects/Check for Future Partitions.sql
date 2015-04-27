



--SELECT	$PARTITION.pf_Download(getdate())
--		,$PARTITION.pf_Download(dateadd(month,1,getdate()))
--		,$PARTITION.pf_Download(dateadd(month,2,getdate()))
--		,$PARTITION.pf_Download(dateadd(month,3,getdate()))
--		,$PARTITION.pf_Download(dateadd(month,4,getdate()))
--		,$PARTITION.pf_Download(dateadd(month,5,getdate()))
--		,$PARTITION.pf_Download(dateadd(month,6,getdate()))		
		
GO
DECLARE @Date DateTime
SET		@Date = GetDate()


;WITH		PartitionData
			AS
			(
			select		object_name(p.object_id)	[TableName]
						,p.partition_number			[PartitionNumber]
						,p.rows						[Rows]
						,au.total_pages				[TotalPages]
						,au.used_pages				[UsedPages]
						,au.data_pages				[DatePages]
						,fg.name 					[FileGroupName]
						,mf.name					[FileName]
						,mf.physical_name			[FilePhysicalName]					
						,ps.name 					[PartionSchemaName]
						,pf.name 					[PatitionFunctionName]
						,pf.type_desc				[PartitionFunctionType]
						,pf.fanout					[PartitionFunctionFanout]
						,pf.boundary_value_on_right	[PartitionFunctionBoundryOnRight]
						,prv.Value					[RangeValue]
			FROM		sys.partitions  p
			JOIN		sys.indexes i
				ON		p.object_id = i.object_id
				AND		p.index_id = i.index_id
				AND		i.type in (0,1) --0 = heap, 1 = clustered, skip the nonclustered for the count
			JOIN		sys.partition_schemes AS ps
				ON		ps.data_space_id = i.data_space_id
			JOIN		sys.partition_functions AS pf
				ON		ps.function_id = pf.function_id
			LEFT JOIN	sys.partition_range_values AS prv
				ON		prv.function_id = pf.function_id
				AND		p.partition_number = prv.boundary_id + isnull(pf.boundary_value_on_right,0)+1
			JOIN		sys.allocation_units au
				ON		(au.type in (1,3) AND p.partition_id = au.container_id)
				OR		(au.type in (2) AND p.hobt_id = au.container_id)
			JOIN		sys.filegroups fg
				ON		fg.data_space_id = au.data_space_id
			JOIN		sys.master_files mf
				ON		mf.data_space_id = au.data_space_id
				AND		mf.database_id = DB_ID()
			--ORDER BY 1,2
			)
			
SELECT		*			
FROM		(			
			SELECT		0 [MonthsFromNow],$PARTITION.pf_Download(dateadd(month,0,@Date)) [PartitionNumber]
						,'WCDS_D_'+CAST(YEAR(dateadd(month,0,@Date)) AS VARCHAR(4))+'_'+ RIGHT('00'+CAST(MONTH(dateadd(month,0,@Date)) AS VarChar(2)),2) [PartitionName]
			UNION ALL																																	  
			SELECT		1 [MonthsFromNow],$PARTITION.pf_Download(dateadd(month,1,@Date))
						,'WCDS_D_'+CAST(YEAR(dateadd(month,1,@Date)) AS VARCHAR(4))+'_'+ RIGHT('00'+CAST(MONTH(dateadd(month,1,@Date)) AS VarChar(2)),2)
			UNION ALL																																	  
			SELECT		2 [MonthsFromNow],$PARTITION.pf_Download(dateadd(month,2,@Date))
						,'WCDS_D_'+CAST(YEAR(dateadd(month,2,@Date)) AS VARCHAR(4))+'_'+ RIGHT('00'+CAST(MONTH(dateadd(month,2,@Date)) AS VarChar(2)),2)
			UNION ALL																																	  
			SELECT		3 [MonthsFromNow],$PARTITION.pf_Download(dateadd(month,3,@Date))
						,'WCDS_D_'+CAST(YEAR(dateadd(month,3,@Date)) AS VARCHAR(4))+'_'+ RIGHT('00'+CAST(MONTH(dateadd(month,3,@Date)) AS VarChar(2)),2)
			UNION ALL																																	  
			SELECT		4 [MonthsFromNow],$PARTITION.pf_Download(dateadd(month,4,@Date))
						,'WCDS_D_'+CAST(YEAR(dateadd(month,4,@Date)) AS VARCHAR(4))+'_'+ RIGHT('00'+CAST(MONTH(dateadd(month,4,@Date)) AS VarChar(2)),2)
			UNION ALL																																	  
			SELECT		5 [MonthsFromNow],$PARTITION.pf_Download(dateadd(month,5,@Date))
						,'WCDS_D_'+CAST(YEAR(dateadd(month,5,@Date)) AS VARCHAR(4))+'_'+ RIGHT('00'+CAST(MONTH(dateadd(month,5,@Date)) AS VarChar(2)),2)
			UNION ALL																																	  
			SELECT		6 [MonthsFromNow],$PARTITION.pf_Download(dateadd(month,6,@Date))
						,'WCDS_D_'+CAST(YEAR(dateadd(month,6,@Date)) AS VARCHAR(4))+'_'+ RIGHT('00'+CAST(MONTH(dateadd(month,6,@Date)) AS VarChar(2)),2)
			) PartitionTest
LEFT JOIN	PartitionData
	ON		PartitionData.PartitionNumber  = PartitionTest.PartitionNumber
	AND		PartitionData.FileGroupName  = PartitionTest.PartitionName
			




