	
	
select		ss.name SchemaName
			,so.name as TableName
			,ISNULL(si.name,'NoIndex') as IndexName
			,(coalesce(user_seeks,0)+coalesce(user_scans,0)+coalesce(user_lookups,0)+coalesce(user_updates,0)) IndexUsage
			,Cast	(
					(coalesce(user_seeks,0)+coalesce(user_scans,0)+coalesce(user_lookups,0)+coalesce(user_updates,0))
					/
					(	select CASE WHEN sum(cast(reserved as float))*8192.00/(1024.00) = 0 THEN 1 ELSE sum(cast(reserved as float))*8192.00/(1024.00) END
						from sysindexes 
						where indid=si.index_id and id=so.object_id
					)
					As decimal(10,2)
					) IndexUsageToSizeRatio
			
			,stuff((select	',' + sc.name
					From	sys.index_columns sic
					JOIN	sys.columns sc
						ON	sic.object_id = sc.object_id
						AND sic.column_id = sc.column_id
						AND sic.is_included_column=0
					WHERE	sic.object_id=so.object_id
						and	sic.index_id=si.index_id
					for xml path('')),1,1,'') As IndexKey
			,stuff((select	',' + sc.name
					From	sys.index_columns sic
					JOIN	sys.columns sc
						ON	sic.object_id = sc.object_id
						AND sic.column_id = sc.column_id
						AND sic.is_included_column=1
					WHERE	sic.object_id=so.object_id
						and	sic.index_id=si.index_id
					for xml path('')),1,1,'') As IncludedCol
			,Case When is_primary_key=1 then 'Primary Key Constraint' 
				Else 'Index'End ConstraintType
			,(select sum(cast(reserved as float))*8192/(1024) from sysindexes where indid=si.index_id and id=so.object_id) As IndexSizeInKB
			,Case When (is_primary_key=1) 
				then ('alter table ' + so.name + ' drop constraint ' + si.name)
				Else ('Drop Index ' + ss.name + '.' + so.name + '.' + si.name) 
				End As DropQry
FROM		sys.objects so 
INNER JOIN	sys.indexes si 
	ON		so.object_id=si.Object_id
INNER JOIN	sys.schemas ss 
	ON		ss.schema_id=so.schema_id
LEFT JOIN	sys.dm_db_index_usage_stats spi	
	ON		spi.object_id = si.object_id
	AND		spi.index_id=si.index_id
	
where		so.type='U' 
	and		ss.schema_id<>4 
	and		si.index_id>0
	and		
ORDER BY 4