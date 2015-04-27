
DECLARE		@Indexes	Table
		(
		Issue		VarChar(50)
		,TableName	sysname
		,Object_ID	INT
		,Index1		sysname
		,Index1id	INT
		,Index2		sysname
		,Index2id	int
		,Index1Columns	VarChar(4000)
		,Index2Columns	VarChar(4000)
		,Index1SizeMb	int
		,Index1Rowcnt	int
		,Index2SizeMb	int
		,Index2Rowcnt	int
		)

-- REDUNDENT INDEXES


INSERT INTO	@Indexes
SELECT		DISTINCT
		'REDUNDENT'
		,CIX.TableName
		,CIX.[Object_ID]
		,CIX.IndexName
		,CIX.indid
		,SIX.IndexName
		,SIX.indid
		,CIX.col1 + COALESCE(','+CIX.col2,'') + COALESCE(','+CIX.col3,'') + COALESCE(','+CIX.col4,'') + COALESCE(','+CIX.col5,'') + COALESCE(','+CIX.col6,'') + COALESCE(','+CIX.col7,'') + COALESCE(','+CIX.col8,'') + COALESCE(','+CIX.col9,'') + COALESCE(','+CIX.col10,'') + COALESCE(','+CIX.col11,'') + COALESCE(','+CIX.col12,'') + COALESCE(','+CIX.col13,'') + COALESCE(','+CIX.col14,'') + COALESCE(','+CIX.col15,'') + COALESCE(','+CIX.col16,'') ClusteredIndex_Columns
		,SIX.col1 + COALESCE(','+SIX.col2,'') + COALESCE(','+SIX.col3,'') + COALESCE(','+SIX.col4,'') + COALESCE(','+SIX.col5,'') + COALESCE(','+SIX.col6,'') + COALESCE(','+SIX.col7,'') + COALESCE(','+SIX.col8,'') + COALESCE(','+SIX.col9,'') + COALESCE(','+SIX.col10,'') + COALESCE(','+SIX.col11,'') + COALESCE(','+SIX.col12,'') + COALESCE(','+SIX.col13,'') + COALESCE(','+SIX.col14,'') + COALESCE(','+SIX.col15,'') + COALESCE(','+SIX.col16,'') RedundentIndex_Columns
		,CIX.reservedKb / 1024
		,CIX.rowcnt
		,SIX.reservedKb / 1024
		,SIX.rowcnt
FROM		(
		SELECT	DISTINCT
			sch.[name]+'.'+tbl.[name] AS TableName,
			idx.[name] AS IndexName,
			tbl.[object_id],
			idx.indid,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 1 ) AS col1,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 2 ) AS col2,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 3 ) AS col3,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 4 ) AS col4,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 5 ) AS col5,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 6 ) AS col6,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 7 ) AS col7,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 8 ) AS col8,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 9 ) AS col9,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 10 ) AS col10,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 11 ) AS col11,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 12 ) AS col12,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 13 ) AS col13,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 14 ) AS col14,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 15 ) AS col15,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 16 ) AS col16,
			cast(reserved as float)*8192/(1024) as ReservedKb,
			rowcnt
		FROM SYSINDEXES idx
		INNER JOIN SYS.OBJECTS tbl ON idx.[id] = tbl.[object_id]
		JOIN sys.schemas sch ON tbl.schema_id = sch.schema_id
		WHERE indid > 0
		AND INDEXPROPERTY( tbl.[object_id], idx.[name], 'IsStatistics') = 0
		--AND INDEXPROPERTY( tbl.[object_id], idx.[name], 'IsClustered') = 0
		) CIX

JOIN		(
		SELECT	DISTINCT
			sch.[name]+'.'+tbl.[name] AS TableName,
			idx.[name] AS IndexName,
			tbl.[object_id],
			idx.indid,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 1 ) AS col1,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 2 ) AS col2,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 3 ) AS col3,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 4 ) AS col4,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 5 ) AS col5,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 6 ) AS col6,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 7 ) AS col7,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 8 ) AS col8,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 9 ) AS col9,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 10 ) AS col10,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 11 ) AS col11,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 12 ) AS col12,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 13 ) AS col13,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 14 ) AS col14,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 15 ) AS col15,
			INDEX_COL( sch.[name]+'.'+tbl.[name], idx.indid, 16 ) AS col16,
			cast(reserved as float)*8192/(1024) as ReservedKb,
			rowcnt
		FROM SYSINDEXES idx
		INNER JOIN SYS.OBJECTS tbl ON idx.[id] = tbl.[object_id]
		JOIN sys.schemas sch ON tbl.schema_id = sch.schema_id
		WHERE indid > 0
		AND INDEXPROPERTY( tbl.[object_id], idx.[name], 'IsStatistics') = 0
		--AND INDEXPROPERTY( tbl.[object_id], idx.[name], 'IsClustered') = 0
		) SIX
	ON	CIX.[Object_id] = SIX.[Object_id]
	AND	CIX.Indid < SIX.Indid
	AND	CIX.col1 = SIX.col1
	AND	COALESCE(CIX.col2,SIX.col2,'') = COALESCE(SIX.col2,'')
	AND	COALESCE(CIX.col3,SIX.col3,'') = COALESCE(SIX.col3,'')
	AND	COALESCE(CIX.col4,SIX.col4,'') = COALESCE(SIX.col4,'')
	AND	COALESCE(CIX.col5,SIX.col5,'') = COALESCE(SIX.col5,'')
	AND	COALESCE(CIX.col6,SIX.col6,'') = COALESCE(SIX.col6,'')
	AND	COALESCE(CIX.col7,SIX.col7,'') = COALESCE(SIX.col7,'')
	AND	COALESCE(CIX.col8,SIX.col8,'') = COALESCE(SIX.col8,'')
	AND	COALESCE(CIX.col9,SIX.col9,'') = COALESCE(SIX.col9,'')
	AND	COALESCE(CIX.col10,SIX.col10,'') = COALESCE(SIX.col10,'')
	AND	COALESCE(CIX.col11,SIX.col11,'') = COALESCE(SIX.col11,'')
	AND	COALESCE(CIX.col12,SIX.col12,'') = COALESCE(SIX.col12,'')
	AND	COALESCE(CIX.col13,SIX.col13,'') = COALESCE(SIX.col13,'')
	AND	COALESCE(CIX.col14,SIX.col14,'') = COALESCE(SIX.col14,'')
	AND	COALESCE(CIX.col15,SIX.col15,'') = COALESCE(SIX.col15,'')
	AND	COALESCE(CIX.col16,SIX.col16,'') = COALESCE(SIX.col16,'')
WHERE		CIX.TableName + CIX.IndexName + SIX.IndexName NOT IN (SELECT TableName+Index1+Index2 FROM @Indexes)	
	AND	CIX.TableName + SIX.IndexName + CIX.IndexName NOT IN (SELECT TableName+Index1+Index2 FROM @Indexes)	



UPDATE		@Indexes
	SET	Issue = 'DUPLICATE'
WHERE		Index1Columns = Index2Columns	


SELECT		IX.Issue
		,IX.TableName
		,IX.Index1
		,SI1.Type_desc Index1Type
		,IX.Index1Columns
		,IX.Index1SizeMb
		,IX.Index1Rowcnt
		,COALESCE(SUM(US1.user_seeks + US1.user_scans + US1.user_lookups),0)  as Index1Reads
		,COALESCE(SUM(US1.user_updates),0) as Index1Writes
		,SI2.Type_desc Index2Type
		,IX.Index2Columns
		,IX.Index2SizeMb
		,IX.Index2Rowcnt
		,COALESCE(SUM(US2.user_seeks + US2.user_scans + US2.user_lookups),0)  as Index2Reads
		,COALESCE(SUM(US2.user_updates),0) as Index2Writes 
FROM		@Indexes IX
LEFT join	sys.indexes SI1
	ON	SI1.object_id = IX.Object_id
	AND	SI1.name = IX.Index1	 
LEFT JOIN	sys.dm_db_index_usage_stats US1 
	on	US1.object_id = IX.object_id  
	and	US1.index_id = IX.index1id
	
LEFT join	sys.indexes SI2
	ON	SI2.object_id = IX.Object_id
	AND	SI2.name = IX.Index2	 
LEFT JOIN	sys.dm_db_index_usage_stats US2 
	on	US2.object_id = IX.object_id  
	and	US2.index_id = IX.index2id
GROUP BY	IX.Issue
		,IX.TableName
		,IX.Index1
		,SI1.Type_desc 
		,IX.Index1Columns
		,IX.Index1SizeMb
		,IX.Index1Rowcnt
		,SI2.Type_desc 
		,IX.Index2Columns
		,IX.Index2SizeMb
		,IX.Index2Rowcnt
		
			
ORDER BY 1,2,3