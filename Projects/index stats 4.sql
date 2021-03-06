/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [database_id]
      ,[object_id]
      ,[index_id]
      ,[user_seeks]
      ,[user_scans]
      ,[user_lookups]
      ,[user_updates]
      ,[last_user_seek]
      ,[last_user_scan]
      ,[last_user_lookup]
      ,[last_user_update]
      ,[system_seeks]
      ,[system_scans]
      ,[system_lookups]
      ,[system_updates]
      ,[last_system_seek]
      ,[last_system_scan]
      ,[last_system_lookup]
      ,[last_system_update]
      

FROM [WCDS].[sys].[dm_db_index_usage_stats]

DECLARE		@IndexUsageToSizeRatio decimal(10,2)
			,@indexusage int
			,@tblUnusedIndexes Table
				(
				UnusedIndid int identity(1,1),
				Schemaname varchar(100),
				tablename varchar(100),
				IndexName varchar(500),
				IndexUsage int,
				IndexUsageToSizeRatio decimal(10,2),
				IndexKey varchar(1000),
				IncludedCol varchar(1000),
				ConstraintType varchar(1000),
				IndexSizeKB int,
				DropQry varchar(4000),
				IndexStatus varchar(20) default 'Active'
				)

insert into @tblUnusedIndexes
(
Schemaname,
tablename,
IndexName,
IndexUsage,
IndexUsageToSizeRatio,
IndexKey,
IncludedCol,
ConstraintType,
IndexSizeKB,
DropQry
)
-- Indexes that does not exist in sys.dm_db_index_usage_stats
select		ss.name SchemaName
			,so.name as TableName
			,ISNULL(si.name,'NoIndex') as IndexName
			,0 IndexUsage
			,0 IndexUsageToSizeRatio
			,dbo.Uf_GetIndexCol(si.index_id,so.object_id,0) As IndexKey
			,dbo.Uf_GetIndexCol(si.index_id,so.object_id,1) As IncludedCol
			,Case When is_primary_key=1 then 'Primary Key Constraint' 
				Else 'Index'End ConstraintType
			,dbo.Uf_GetIndexSize(si.index_id,so.object_id) As IndexSizeInKB
			,Case When (is_primary_key=1) 
				then ('alter table ' + so.name + ' drop constraint ' + si.name)
				Else ('Drop Index ' + ss.name + '.' + so.name + '.' + si.name) 
				End As DropQry
from		sys.objects so 
inner join	sys.indexes si 
	on		so.object_id=si.Object_id
inner join	sys.schemas ss 
	on		ss.schema_id=so.schema_id
where		not exists (select * from sys.dm_db_index_usage_stats spi where si.object_id=spi.object_id and si.index_id=spi.index_id)
	and		so.type='U' and ss.schema_id<>4 and si.index_id>0
	and		si.name not in (select indexname from tblUnusedIndexes)


union 
-- Indexes that doesn't satisfy the Indexusage criteria.
select ss.name,b.TableName,b.IndexName,
b.IndexUsage ,b.IndexUsageToSizeRatio,
dbo.Uf_GetIndexCol(b.index_id,object_id(b.tablename),0) As IndexKey,
dbo.Uf_GetIndexCol(b.index_id,object_id(b.tablename),1) As IncludedCol,
b.ConstraintType,
dbo.Uf_GetIndexSize(b.index_id,object_id(b.tablename)) As IndexSizeInKB,
Case b.ConstraintType When 'Index' 
then ('Drop Index ' + ss.name + '.' + b.TableName + '.' + b.IndexName)
Else ('alter table ' + b.TableName + ' drop constraint ' + b.IndexName)
End DropQry
from tblIndexUsageInfo b,sys.tables st,sys.schemas ss
where(b.indexusage<=@indexUsage Or IndexUsageToSizeRatio<=@IndexUsageToSizeRatio)
and st.name=tablename and st.schema_id=ss.schema_id
and b.indexname not in (select indexname from tblUnusedIndexes)
group by b.indexname,b.tablename,ss.name,ss.schema_id,
b.ConstraintType,b.index_id,b.indexusage,b.IndexUsageToSizeRatio
END