use WCDS;
select		distinct 
			'WCDS' DbName
			,DB_ID()
			,so.name as 'TableName'
			,si.Object_id
			,ISNULL(si.name,'No Index') as IndexName
			,si.index_id
			,Case When is_primary_key=1 then 'Primary Key Constraint' 
				Else 'Index' End ConstraintType
			,si.type_desc
			,stuff((select	',' + sc.name
					From	sys.index_columns sic
					JOIN	sys.columns sc
						ON	sic.object_id = sc.object_id
						AND sic.column_id = sc.column_id
						AND sic.is_included_column=0
					WHERE	sic.object_id=so.object_id
						and	sic.index_id=si.index_id
					for xml path('')),1,1,'') As IndexKeyColumn
			,stuff((select	',' + sc.name
					From	sys.index_columns sic
					JOIN	sys.columns sc
						ON	sic.object_id = sc.object_id
						AND sic.column_id = sc.column_id
						AND sic.is_included_column=1
					WHERE	sic.object_id=so.object_id
						and	sic.index_id=si.index_id
					for xml path('')),1,1,'') As IncludedCols
			,spi.user_seeks
			,spi.user_scans
			,spi.user_lookups
			,spi.user_updates
			,(user_seeks+user_scans+user_lookups+user_updates) as IndexUsage
			,(select sum(cast(reserved as float))*8192/(1024) from sysindexes where indid=si.index_id and id=so.object_id) IndexSizeKB
			,Cast((user_seeks+user_scans+user_lookups+user_updates)/(select sum(cast(reserved as float))*8192.00/(1024.00)+.01 from sysindexes where indid=si.index_id and id=so.object_id) As decimal(10,2)) As IndexUsagetoSizeRatio
from		WCDS.sys.objects so inner join sys.indexes si 
	on		so.object_id=si.Object_id
inner join	WCDS.sys.dm_db_index_usage_stats spi 
	on		spi.Object_id=so.Object_id
--inner join	WCDS.sys.index_columns sic 
--	on		sic.object_id=si.object_id 
--	and		sic.index_id=si.index_id
--inner join	WCDS.sys.columns sc 
--	on		sc.Column_id=sic.column_id 
--	and		sc.object_id=sic.object_id
--inner join	WCDS.INFORMATION_SCHEMA.TABLE_CONSTRAINTS c 
--	on		so.name=c.TABLE_NAME where so.type='u'

ORDER BY user_scans desc