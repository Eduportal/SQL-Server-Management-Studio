
SELECT
'INSERT INTO #Indexes VALUES('''+CAST(id AS VarChar)+''','''+CAST(status AS VarChar)+''','''+CAST(indid AS VarChar)+''','''+CAST(minlen AS VarChar)+''','''+CAST(keycnt AS VarChar)+''','''+CAST(groupid AS VarChar)+''','''+CAST(xmaxlen AS VarChar)+''','''+CAST(name AS VarChar)+''')'	
From sysindexes where nullif(name,'') IS NOT NULL





select
'INSERT INTO #Index_Columns VALUES('''+s.name+''','''+t.name+''','''+i.name+''','''+c.name+''')'	
-- s.name, t.name, i.name, c.name
from		sys.tables t
inner join	sys.schemas s 
	on		t.schema_id = s.schema_id
inner join	sys.indexes i 
	on		i.object_id = t.object_id
inner join	sys.columns c 
	on		c.object_id = t.object_id 
inner join	sys.index_columns ic 
	on		ic.object_id	= t.object_id
	and		ic.column_id	= c.column_id
	and		ic.index_id		= i.index_id

where i.index_id > 0    
and i.type in (1, 2) -- clustered & nonclustered only
--and i.is_primary_key = 0 -- do not include PK indexes
--and i.is_unique_constraint = 0 -- do not include UQ
and i.is_disabled = 0
and i.is_hypothetical = 0
--and ic.key_ordinal > 0

order by 1,2,3,4

SELECT	* FROM sys.indexes 