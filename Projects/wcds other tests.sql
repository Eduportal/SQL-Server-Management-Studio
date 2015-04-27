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
ORDER BY 1,2


DBCC TRACEON (1204,-1)
DBCC TRACEON (1222,-1)
DBCC TRACESTATUS
sp_cycle_errorlog


select	datepart(hour,[CreatedDate])
		,datepart(minute,[CreatedDate])
		,count(*) 
From Download 
where [CreatedDate] > cast(convert(varchar(12),getdate(),101)As Datetime)
GROUP BY datepart(hour,[CreatedDate]),datepart(minute,[CreatedDate])
ORDER BY 1


select	datepart(hour,StatusModifiedDateTime)
		,datepart(minute,StatusModifiedDateTime)
		,count(*) 
From DownloadDetail 
where StatusModifiedDateTime > cast(convert(varchar(12),getdate(),101)As Datetime)
GROUP BY datepart(hour,StatusModifiedDateTime),datepart(minute,StatusModifiedDateTime)
ORDER BY 1

sp_who2 active

-- DOWNLOADS MISSING DETAILS
SELECT		*
FROM		Download 
WHERE		[CreatedDate] > '2011-11-02 11:00:00'
	AND		DownloadID NOT IN
								(
								SELECT		DownloadID
								FROM		DownloadDetail 
								WHERE		StatusModifiedDateTime > '2011-11-02 11:00:00'
								)

