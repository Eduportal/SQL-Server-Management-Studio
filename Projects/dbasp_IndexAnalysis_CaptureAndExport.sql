USE DBAPERF
GO
CREATE PROC	dbasp_IndexAnalysis_CaptureAndExport
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE		@database_name		sysname
		,@schema_name		sysname
		,@table_name		sysname
		,@Fill_Factor		int
		,@PopulateDMVsForAll	bit
		,@TSQL1			VarChar(max)
		,@TSQL2			VarChar(max)
		,@TSQL3			VarChar(max)
		,@Object		sysname
		,@object_id		int
		,@database_id		int
		,@IndexScript		nvarchar(max)
		,@RC			int
		,@Script		VarChar(6000)
		,@Export_Source		sysname
		,@UNCPath		VarChar(6000)
		,@LocalPath		VarChar(6000)
		,@FileName		VarChar(6000)
		,@target_env		VarChar(50)
		,@target_server		sysname
		,@target_share		VarChar(2048)
		,@retry_limit		INT 
		
		
		
		

SELECT		@UNCPath		= '\\g1sqla\d$'
		,@target_env		= 'amer'
		,@target_server		= 'SEAFRESQLDBA01'
		,@target_share		= 'SEAFRESQLDBA01_dbasql\dba_UpdateFiles'
		,@retry_limit		= 5 
		,@Fill_Factor		= 98
		,@PopulateDMVsForAll	= 1
		,@object_id		= OBJECT_ID(@database_name+'.'+@schema_name+'.'+@table_name)
		,@database_id		= db_id(@database_name)
		,@IndexScript		= ''
		
		
		,@LocalPath		= @UNCPath

--EXEC [dbaadmin].[dbo].[dbasp_get_share_path] 
--	@share_name	= @UNCPath
--	,@phy_path	= @LocalPath OUTPUT


IF OBJECT_ID('tempdb..#ForeignKeys') IS NOT NULL
    DROP TABLE #ForeignKeys

CREATE TABLE #ForeignKeys
    (
    database_id int
    ,foreign_key_name sysname
    ,object_id int
    ,fk_columns nvarchar(max)
    ,fk_columns_compare nvarchar(max)
    );
    
    
DECLARE CreateAllDBViews CURSOR
FOR
SELECT 'sys','tables'
UNION ALL
SELECT 'sys','schemas'
UNION ALL
SELECT 'sys','sysindexes'
UNION ALL
SELECT 'sys','indexes'
UNION ALL
SELECT 'sys','dm_db_partition_stats'
UNION ALL
SELECT 'sys','allocation_units'
UNION ALL
SELECT 'sys','partitions'
UNION ALL
SELECT 'sys','columns'
UNION ALL
SELECT 'sys','index_columns'
UNION ALL
SELECT 'sys','foreign_keys'
UNION ALL
SELECT 'sys','foreign_key_columns'


OPEN CreateAllDBViews
FETCH NEXT FROM CreateAllDBViews INTO @TSQL2,@TSQL3
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET	@TSQL1	= 'IF OBJECT_ID(''[dbo].[vw_AllDB_'+@TSQL3+']'') IS NOT NULL' +CHAR(13)+CHAR(10)
		+ 'DROP VIEW [dbo].[vw_AllDB_'+@TSQL3+']' +CHAR(13)+CHAR(10)
		SET	@TSQL1	= 'USE [dbaperf];'+CHAR(13)+CHAR(10)+'EXEC (''' + REPLACE(@TSQL1,'''','''''') + ''')'
		EXEC	(@TSQL1)

		SET	@TSQL1	= 'CREATE VIEW [dbo].[vw_AllDB_'+@TSQL3+'] AS' +CHAR(13)+CHAR(10)+'SELECT	''master'' AS database_name, DB_ID(''master'') AS database_id, * From [master].['+@TSQL2+'].['+@TSQL3+']'+CHAR(13)+CHAR(10)
		SELECT	@TSQL1 = @TSQL1 +
		'UNION ALL'+CHAR(13)+CHAR(10)+'SELECT	'''+name+''', DB_ID('''+name+'''), * From ['+name+'].['+@TSQL2+'].['+@TSQL3+']'+CHAR(13)+CHAR(10)
		FROM	master.sys.databases
		WHERE	name != 'master'
		SET	@TSQL1	= 'USE [dbaperf];'+CHAR(13)+CHAR(10)+'EXEC (''' + REPLACE(@TSQL1,'''','''''') + ''')'
		EXEC	(@TSQL1)
	END
	FETCH NEXT FROM CreateAllDBViews INTO @TSQL2,@TSQL3
END

CLOSE CreateAllDBViews
DEALLOCATE CreateAllDBViews    
    

BEGIN -- POPULATE DMVs or TEMP TABLES

	-------------------------------------------------------
	-------------------------------------------------------
	-- POPULATE dmv_MissingIndexSnapshot
	-------------------------------------------------------
	-------------------------------------------------------

SELECT		@database_name		= QUOTENAME(@database_name)
		,@schema_name		= QUOTENAME(@schema_name)
		,@table_name		= QUOTENAME(@table_name)
		
		
DELETE		dmv_MissingIndexSnapshot		
WHERE		(
		QUOTENAME(database_name) = @database_name
		OR @database_name IS NULL
		OR @PopulateDMVsForAll = 1
		)
	AND	(
		QUOTENAME(table_name) = @table_name
		OR @table_name IS NULL
		OR @PopulateDMVsForAll = 1
		)		
				

	;WITH	XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
		, PlanData AS
		( 
		SELECT		ecp.plan_handle
				, MissingIndex.value ('(.//MissingIndex/@Database)[1]','sysname')	AS database_name
				, MissingIndex.value ('(.//MissingIndex/@Schema)[1]','sysname')		AS schema_name
				, MissingIndex.value ('(.//MissingIndex/@Table)[1]','sysname')		AS table_name
				, MissingIndex.query ('.')						AS Statements 
				, MissingIndex.value ('(./@StatementId)[1]', 'int')			AS StatementID 
				, MissingIndex.value ('(./@StatementText)[1]', 'varchar(max)')		AS StatementText 
				, MissingIndex.value ('(./@StatementSubTreeCost)[1]', 'float')		AS StatementSubTreeCost
				, MissingIndex.value ('(.//MissingIndexGroup/@Impact)[1]','float')	AS Impact
				, usecounts								AS UseCounts
				, eqp.[dbid]
				, eqp.[objectid]
				, ecp.objtype

		FROM		sys.dm_exec_cached_plans		AS ecp
		CROSS APPLY	sys.dm_exec_query_plan(ecp.plan_handle)	AS eqp
		CROSS APPLY	query_plan.nodes
				 ('for $stmt in .//Statements/*
				where	count($stmt/Condition/QueryPlan/MissingIndexes) > 0
				or	count($stmt/QueryPlan/MissingIndexes) > 0
				return $stmt')				AS qp(MissingIndex)
		WHERE		(
				MissingIndex.exist 
				 ('.//MissingIndex[@Database = sql:variable("@database_name")]') = 1
				OR @database_name IS NULL
				OR @PopulateDMVsForAll = 1
				)
			AND	(
				MissingIndex.exist 
				 ('.//MissingIndex[@Table = sql:variable("@table_name")]') = 1
				OR @table_name IS NULL
				OR @PopulateDMVsForAll = 1
				)
		)
		, FormatedData AS
		(	
		SELECT		@@ServerName				AS server_name
				, REPLACE(REPLACE(
				  [database_name]
				  ,'[',''),']','')			AS database_name
				, DB_ID(REPLACE(REPLACE(
				  [database_name]
				  ,'[',''),']',''))			AS database_id
				, SCHEMA_ID(REPLACE(REPLACE(
				  [schema_name]
				  ,'[',''),']',''))			AS schema_id
				, REPLACE(REPLACE(
				  [schema_name]
				  ,'[',''),']','')			AS schema_name
				, OBJECT_ID(
				  [database_name]
				  +'.'+[schema_name]
				  +'.'+[table_name]
				  )					AS object_id
				, REPLACE(REPLACE(
				  [table_name]
				   ,'[',''),']','')			AS table_name
				, [StatementSubTreeCost]
				  * ISNULL([Impact], 0) 
				  * usecounts				AS Improvement 
				, [Statements]				AS CompleteQueryPlan 
				, OBJECT_NAME([objectid],[dbid])	AS Sproc_name
				, [StatementId]				AS StatementID 
				, [StatementText]			AS StatementText 
				, [StatementSubTreeCost]		AS StatementSubTreeCost
				, NULL					AS MissingIndex 
				, [Impact]				AS IndexImpact 
				, [usecounts]				AS UseCounts
				
				, REPLACE(CAST(Mi.query
				   ('data( for $cg in .//ColumnGroup
					where $cg/@Usage="EQUALITY" or $cg/@Usage="INEQUALITY"
					return $cg/Column/@Name	)')
					AS NVarchar(4000)),'] [','], [')				AS IndexColumns
					
				, REPLACE(CAST(Mi.query
				   ('data( for $cg in .//ColumnGroup
					where $cg/@Usage="INCLUDE"
					return $cg/Column/@Name	)')
					AS NVarchar(4000)),'] [','], [')				AS IncludeColumns
					
				,REPLACE(REPLACE(REPLACE(CAST(Mi.query
				    ('data( for $cg in .//ColumnGroup
					where $cg/@Usage="EQUALITY" or $cg/@Usage="INEQUALITY"
					return $cg/Column/@ColumnId )')
					AS NVarchar(4000)),'[',''),']',''),' ','_')			AS IndexColumnIDs
				,REPLACE(REPLACE(REPLACE(CAST(Mi.query
				   ('data( for $cg in .//ColumnGroup
					where $cg/@Usage="INCLUDE"
					return $cg/Column/@ColumnId )')
					AS NVarchar(4000)),'[',''),']',''),' ','_')			AS IncludeColumnIDs
				
		From		PlanData				AS pd
		CROSS APPLY	Statements.nodes
				 ('.//MissingIndex')			AS St(Mi)
		)		
	INSERT INTO	dmv_MissingIndexSnapshot		
	SELECT		server_name
			, database_name
			, database_id
			, schema_id
			, schema_name
			, object_id
			, table_name
			, Improvement 
			, CompleteQueryPlan 
			, Sproc_name
			, StatementID 
			, StatementText 
			, StatementSubTreeCost
			, MissingIndex 
			, IndexImpact 
			, UseCounts
			, IndexColumns
			, ', ' + [IncludeColumns]		AS IncludeColumns
			, 'IX_' 
			+ REPLACE(REPLACE(
			  [table_name]
			   ,'[',''),']','')
			+ '_'
			+ [IndexColumnIDs]
			+ CASE
			  WHEN [IncludeColumnIDs] = ''
			  THEN ''
			  ELSE '_INC_' + [IncludeColumnIDs]
			  END					AS IndexName				
		
			
			
	FROM		FormatedData
				
	ORDER BY	Improvement DESC

	-------------------------------------------------------
	-------------------------------------------------------
	-- POPULATE dmv_IndexBaseLine
	-------------------------------------------------------
	-------------------------------------------------------
	
	SELECT		@database_name		= REPLACE(REPLACE(
						  @database_name
						  ,'[',''),']','')
			,@schema_name		= REPLACE(REPLACE(
						  @schema_name
						  ,'[',''),']','')
			,@table_name		= REPLACE(REPLACE(
						  @table_name
						  ,'[',''),']','')
	

	;WITH	AllocationUnits
		AS	(
			SELECT	p.database_id
				,p.object_id
				,p.index_id
				,p.partition_number 
				,au.allocation_unit_id
			FROM	dbaperf.dbo.vw_AllDB_allocation_units AS au
			JOIN	dbaperf.dbo.vw_AllDB_partitions AS p 
			 ON	au.container_id = p.hobt_id 
			 AND	au.database_id = p.database_id
			 AND	(au.type = 1 OR au.type = 3)
			 WHERE	(p.database_id = @database_id OR @database_id IS NULL OR @PopulateDMVsForAll = 1)
			  AND	(p.object_id = @object_id OR @object_id IS NULL OR @PopulateDMVsForAll = 1)
			UNION ALL
			SELECT	p.database_id
				,p.object_id
				,p.index_id
				,p.partition_number 
				,au.allocation_unit_id
			FROM	dbaperf.dbo.vw_AllDB_allocation_units AS au
			JOIN	dbaperf.dbo.vw_AllDB_partitions AS p 
			 ON	au.container_id = p.partition_id
			 AND	au.database_id = p.database_id 
			 AND	au.type = 2
			 WHERE	(p.database_id = @database_id OR @database_id IS NULL OR @PopulateDMVsForAll = 1)
			  AND	(p.object_id = @object_id OR @object_id IS NULL OR @PopulateDMVsForAll = 1)
			)
		,MemoryBuffer
		AS	(
			SELECT	au.database_id
				,au.object_id
				,au.index_id
				,au.partition_number
				,COUNT(*)AS buffered_page_count
				,CONVERT(decimal(12,2), CAST(COUNT(*) as bigint)*CAST(8 as float)/1024) as buffer_mb
			FROM	sys.dm_os_buffer_descriptors AS bd 
			JOIN	AllocationUnits au 
			ON bd.allocation_unit_id = au.allocation_unit_id
			AND bd.database_id = au.database_id
			 WHERE	(au.database_id = @database_id OR @database_id IS NULL OR @PopulateDMVsForAll = 1)
			  AND	(au.object_id = @object_id OR @object_id IS NULL OR @PopulateDMVsForAll = 1)
			GROUP BY au.database_id, au.object_id, au.index_id, au.partition_number
			)
	INSERT INTO dmv_IndexBaseLine
	    (server_name, database_name, database_id, schema_id, schema_name, object_id, table_name, index_id, index_name, is_unique, type_desc, partition_number, reserved_page_count, size_in_mb, buffered_page_count, buffer_mb, pct_in_buffer, row_count, page_count, existing_ranking
	    , user_total_read, user_total_read_pct
	    , user_total_write, user_total_write_pct
	    , user_seeks, user_scans, user_lookups,user_updates
	    , row_lock_count, row_lock_wait_count, row_lock_wait_in_ms, row_block_pct, avg_row_lock_waits_ms
	    , page_lock_count, page_lock_wait_count, page_lock_wait_in_ms, page_block_pct, avg_page_lock_waits_ms
	    , splits, indexed_columns, included_columns, indexed_columns_compare, included_columns_compare)
	SELECT	@@SERVERNAME
		,DB_Name(t.database_id)
		,t.database_id 
		,s.schema_id
		,s.name as schema_name
		,t.object_id
		,t.name as table_name
		,i.index_id
		,COALESCE(i.name, 'N/A') as index_name
		,i.is_unique
		,CASE WHEN i.is_unique = 1 THEN 'UNIQUE ' ELSE '' END + i.type_desc as type_desc
		,ps.partition_number
		,ps.reserved_page_count 
		,CAST(reserved_page_count * CAST(8 as float) / 1024 as decimal(12,2)) as size_in_mb
		,mb.buffered_page_count
		,mb.buffer_mb
		,CAST(100*buffer_mb/NULLIF(CAST(reserved_page_count * CAST(8 as float) / 1024 as decimal(12,2)),0) AS decimal(12,2)) as pct_in_buffer
		,row_count
		,used_page_count
		,ROW_NUMBER()
			OVER (PARTITION BY i.object_id ORDER BY i.is_primary_key desc, ius.user_seeks + ius.user_scans + ius.user_lookups desc) as existing_ranking

		,ius.user_seeks + ius.user_scans + ius.user_lookups as user_total_read
		,COALESCE(CAST(100 * (ius.user_seeks + ius.user_scans + ius.user_lookups)
			/(NULLIF(SUM(ius.user_seeks + ius.user_scans + ius.user_lookups) 
			OVER(PARTITION BY i.object_id), 0) * 1.) as decimal(6,2)),0) as user_total_read_pct

		,ius.user_updates as user_total_write
		,COALESCE(CAST(100 * (ius.user_updates)
			/(NULLIF(SUM(ius.user_updates) 
			OVER(PARTITION BY i.object_id), 0) * 1.) as decimal(6,2)),0) as user_total_write_pct
			
		,ius.user_seeks
		,ius.user_scans
		,ius.user_lookups
		,ius.user_updates

		,ios.row_lock_count 
		,ios.row_lock_wait_count 
		,ios.row_lock_wait_in_ms 
		,CAST(100.0 * ios.row_lock_wait_count/NULLIF(ios.row_lock_count, 0) AS decimal(12,2)) AS row_block_pct 
		,CAST(1. * ios.row_lock_wait_in_ms /NULLIF(ios.row_lock_wait_count, 0) AS decimal(12,2)) AS avg_row_lock_waits_ms 

		,ios.page_lock_count 
		,ios.page_lock_wait_count 
		,ios.page_lock_wait_in_ms 
		,CAST(100.0 * ios.page_lock_wait_count/NULLIF(ios.page_lock_count, 0) AS decimal(12,2)) AS page_block_pct 
		,CAST(1. * ios.page_lock_wait_in_ms /NULLIF(ios.page_lock_wait_count, 0) AS decimal(12,2)) AS avg_page_lock_waits_ms 

		,ios.leaf_allocation_count + ios.nonleaf_allocation_count AS [Splits]

		,STUFF((SELECT	', ' + QUOTENAME(c.name)
			FROM	dbaperf.dbo.vw_AllDB_index_columns ic
			JOIN	dbaperf.dbo.vw_AllDB_columns c 
			ON	ic.database_id		= c.database_id 
			AND	ic.object_id		= c.object_id 
			AND	ic.column_id		= c.column_id
		    WHERE	is_included_column	= 0
		     AND	i.database_id		= ic.database_id 
		     AND	i.object_id		= ic.object_id
		     AND	i.index_id		= ic.index_id
		    ORDER BY key_ordinal ASC
		    FOR XML PATH('')), 1, 2, '') AS indexed_columns
	    ,STUFF((SELECT ', ' + QUOTENAME(c.name)
		    FROM dbaperf.dbo.vw_AllDB_index_columns ic
		    JOIN dbaperf.dbo.vw_AllDB_columns c 
			ON ic.database_id = c.database_id 
			AND ic.object_id = c.object_id 
			AND ic.column_id = c.column_id
		    WHERE i.database_id = ic.database_id 
		    AND i.object_id = ic.object_id
		    AND i.index_id = ic.index_id
		    
		    AND is_included_column = 1
		    ORDER BY key_ordinal ASC
		    FOR XML PATH('')), 1, 2, '') AS included_columns
	    ,(SELECT QUOTENAME(ic.column_id,'(')
		    FROM dbaperf.dbo.vw_AllDB_index_columns ic
		    WHERE i.database_id = ic.database_id 
		    AND i.object_id = ic.object_id
		    AND i.index_id = ic.index_id
		    AND is_included_column = 0
		    ORDER BY key_ordinal ASC
		    FOR XML PATH('')) AS indexed_columns_compare
	    ,COALESCE((SELECT QUOTENAME(ic.column_id, '(')
		    FROM dbaperf.dbo.vw_AllDB_index_columns ic
		    WHERE i.database_id = ic.database_id 
		    AND i.object_id = ic.object_id
		    AND i.index_id = ic.index_id
		    AND is_included_column = 1
		    ORDER BY key_ordinal ASC
		    FOR XML PATH('')), SPACE(0)) AS included_columns_compare
	FROM		dbaperf.dbo.vw_AllDB_tables t
	JOIN		dbaperf.dbo.vw_AllDB_schemas s 
	    ON		t.database_id		= s.database_id
	    AND		t.schema_id		= s.schema_id
	    
	JOIN		dbaperf.dbo.vw_AllDB_indexes i 
	    ON		t.database_id		= i.database_id
	    AND		t.object_id		= i.object_id
	    
	JOIN		dbaperf.dbo.vw_AllDB_dm_db_partition_stats ps 
	    ON		i.database_id		= ps.database_id
	    AND		i.object_id		= ps.object_id 
	    AND		i.index_id		= ps.index_id
	    
	LEFT JOIN	sys.dm_db_index_usage_stats ius 
	    ON		i.database_id		= ius.database_id
	    AND		i.object_id		= ius.object_id 
	    AND		i.index_id		= ius.index_id 
	    
	LEFT JOIN	sys.dm_db_index_operational_stats(@database_id, @object_id, NULL, NULL) ios 
	    ON		ps.database_id		= ios.database_id
	    AND		ps.object_id		= ios.object_id 
	    AND		ps.index_id		= ios.index_id 
	    AND		ps.partition_number	= ios.partition_number
	    
	LEFT JOIN	MemoryBuffer mb 
	    ON		ps.database_id		= mb.database_id
	    AND		ps.object_id		= mb.object_id 
	    AND		ps.index_id		= mb.index_id 
	    AND		ps.partition_number	= mb.partition_number
	    
	WHERE		(t.database_id = @database_id OR @database_id IS NULL OR @PopulateDMVsForAll = 1)
	    AND		(t.object_id = @object_id OR @object_id IS NULL OR @PopulateDMVsForAll = 1)


	INSERT INTO dmv_IndexBaseLine
	    (server_name, database_name, database_id, schema_id, schema_name, object_id, table_name, index_name
	    , type_desc, impact, existing_ranking, user_total_read, user_seeks, user_scans, user_lookups, indexed_columns
	    , indexed_column_count, included_columns, included_column_count)
	SELECT		@@Servername
			,db_name(mid.database_id)
			,mid.database_id
			,s.schema_id
			,s.name AS schema_name
			,t.object_id
			,t.name AS table_name
			,'IX_'+t.name
			+COALESCE((SELECT	'_'+CAST(column_id AS VarChar)
				FROM	dbaadmin.dbo.dbaudf_split(equality_columns,',') T1
				JOIN	dbaperf.dbo.vw_AllDB_columns T2
				ON	LTRIM(RTRIM(REPLACE(REPLACE(T1.SplitValue,'[',''),']',''))) = T2.name
				AND	T2.database_id		= t.database_id
				AND	T2.object_id		= t.object_id
				order by OccurenceId
				FOR XML PATH('')),'')
			+COALESCE((SELECT	'_'+CAST(column_id AS VarChar)
				FROM	dbaadmin.dbo.dbaudf_split(inequality_columns,',') T1
				JOIN	dbaperf.dbo.vw_AllDB_columns T2
				ON	LTRIM(RTRIM(REPLACE(REPLACE(T1.SplitValue,'[',''),']',''))) = T2.name
				AND	T2.database_id		= t.database_id
				AND	T2.object_id		= t.object_id
				order by OccurenceId
				FOR XML PATH('')),'')	
			+CASE WHEN included_columns IS NULL THEN '' ELSE '_INC' END
			+COALESCE((SELECT	'_'+CAST(column_id AS VarChar)
				FROM	dbaadmin.dbo.dbaudf_split(included_columns,',') T1
				JOIN	dbaperf.dbo.vw_AllDB_columns T2
				ON	LTRIM(RTRIM(REPLACE(REPLACE(T1.SplitValue,'[',''),']',''))) = T2.name
				AND	T2.database_id		= t.database_id
				AND	T2.object_id		= t.object_id
				order by OccurenceId
				FOR XML PATH('')),'')
			,'--NONCLUSTERED--' AS type_desc
			,(migs.user_seeks + migs.user_scans) * migs.avg_user_impact as impact
			,0 AS existing_ranking
			,migs.user_seeks + migs.user_scans as user_total_read
			,migs.user_seeks 
			,migs.user_scans
			,0 as user_lookups
			,COALESCE(equality_columns,'')
			+COALESCE(CASE WHEN equality_columns IS NULL THEN '' ELSE ', ' END + inequality_columns,'') as indexed_columns
			,(LEN(COALESCE(equality_columns + ', ', SPACE(0)) + COALESCE(inequality_columns, SPACE(0))) - LEN(REPLACE(COALESCE(equality_columns + ', ', SPACE(0)) + COALESCE(inequality_columns, SPACE(0)),'[',''))) indexed_column_count
			,', '+ included_columns 
			,(LEN(included_columns) - LEN(REPLACE(included_columns,'[',''))) included_column_count
			
	FROM		dbaperf.dbo.vw_AllDB_tables t
	JOIN		dbaperf.dbo.vw_AllDB_schemas s 
		ON	t.database_id		= s.database_id
		AND	t.schema_id		= s.schema_id
		
	JOIN		sys.dm_db_missing_index_details mid 
		ON	t.database_id		= mid.database_id
		AND	t.object_id		= mid.object_id
		
	JOIN		sys.dm_db_missing_index_groups mig 
		ON	mid.index_handle	= mig.index_handle
		
	JOIN		sys.dm_db_missing_index_group_stats migs 
		ON	mig.index_group_handle	= migs.group_handle
	   
	WHERE		(t.database_id = @database_id OR @database_id IS NULL OR @PopulateDMVsForAll = 1)
		AND	(t.object_id = @object_id OR @object_id IS NULL OR @PopulateDMVsForAll = 1)

	UPDATE		T1
		SET	size_in_mb = 
					[dbaperf].[dbo].[fn_GetLeafLevelIndexSpace] 
					(
					T1.indexed_column_count
					,0
					,0
					,T3.TotalIndexKeySize
					,98
					,T2.row_count)/1000.00/1000.00
					+
					[dbaperf].[dbo].[fn_getIndexSpace] (
					T1.indexed_column_count
					,0
					,0
					,T3.TotalIndexKeySize
					,T2.row_count)/1000.00/1000.00
			,max_key_size = T3.TotalIndexKeySize
	FROM		dmv_IndexBaseLine T1
	JOIN		dmv_IndexBaseLine T2
		ON	T1.database_id		= T2.database_id
		AND	T1.object_id		= T2.Object_id
		AND	T2.type_desc		IN ('CLUSTERED', 'HEAP', 'UNIQUE CLUSTERED')
	JOIN		(
			Select		T1.row_id
					,SUM(T3.max_length)AS TotalIndexKeySize
			FROM		dmv_IndexBaseLine				T1
			CROSS APPLY	dbaadmin.dbo.dbaudf_split(indexed_columns,',')	T2
			JOIN		dbaperf.dbo.vw_AllDB_columns			T3
				ON	T1.database_id			= T3.database_id
				AND	T1.object_id			= T3.object_id
				AND	ltrim(rtrim(T2.SplitValue))	= QUOTENAME(T3.name)
			WHERE type_desc = '--NONCLUSTERED--'
			GROUP BY	T1.row_id
			) T3
		ON	T1.row_id = T3.row_id
	where	T2.row_count > 0



	INSERT INTO #ForeignKeys
	    (database_id, foreign_key_name, object_id, fk_columns, fk_columns_compare)
	SELECT fk.database_id, fk.name + '|PARENT' AS foreign_key_name
	    ,fkc.parent_object_id AS object_id
	    ,STUFF((SELECT ', ' + QUOTENAME(c.name)
		FROM	dbaperf.dbo.vw_AllDB_foreign_key_columns ifkc
		JOIN	dbaperf.dbo.vw_AllDB_columns c
		ON	ifkc.database_id	= c.database_id  
		AND	ifkc.parent_object_id	= c.object_id 
		AND	ifkc.parent_column_id	= c.column_id
		WHERE	fk.database_id		= ifkc.database_id
		AND	fk.object_id		= ifkc.constraint_object_id
		ORDER BY ifkc.constraint_column_id
		FOR XML PATH('')), 1, 2, '') AS fk_columns
	    ,(	SELECT	QUOTENAME(ifkc.parent_column_id,'(')
		FROM	dbaperf.dbo.vw_AllDB_foreign_key_columns ifkc
		WHERE	fk.database_id	= ifkc.database_id
		AND	fk.object_id	= ifkc.constraint_object_id
		ORDER BY ifkc.constraint_column_id
		FOR XML PATH('')) AS fk_columns_compare
	FROM	dbaperf.dbo.vw_AllDB_foreign_keys fk
	JOIN	dbaperf.dbo.vw_AllDB_foreign_key_columns fkc 
	ON	fk.database_id			= fkc.database_id
	AND	fk.object_id			= fkc.constraint_object_id
	WHERE	fkc.constraint_column_id	= 1
	AND	(fkc.database_id = @database_id OR @database_id IS NULL OR @PopulateDMVsForAll = 1)
	AND	(fkc.parent_object_id = @object_id OR @object_id IS NULL OR @PopulateDMVsForAll = 1)
	
	UNION ALL
	SELECT fk.database_id, fk.name + '|REFERENCED' as foreign_key_name
	    ,fkc.referenced_object_id AS object_id
	    ,STUFF((	SELECT	', ' + QUOTENAME(c.name)
			FROM	dbaperf.dbo.vw_AllDB_foreign_key_columns ifkc
			JOIN	dbaperf.dbo.vw_AllDB_columns c 
			ON	ifkc.database_id		= c.database_id 
			AND	ifkc.referenced_object_id	= c.object_id 
			AND	ifkc.referenced_column_id	= c.column_id
			WHERE	fk.database_id			= ifkc.database_id
			AND	fk.object_id			= ifkc.constraint_object_id
			ORDER BY ifkc.constraint_column_id
			FOR XML PATH('')), 1, 2, '') AS fk_columns
	    ,(	SELECT	QUOTENAME(ifkc.referenced_column_id,'(')
		FROM	dbaperf.dbo.vw_AllDB_foreign_key_columns ifkc
		WHERE	fk.database_id		= ifkc.database_id
		AND	fk.object_id		= ifkc.constraint_object_id
		ORDER BY ifkc.constraint_column_id
		FOR XML PATH('')) AS fk_columns_compare
	FROM dbaperf.dbo.vw_AllDB_foreign_keys fk
	JOIN dbaperf.dbo.vw_AllDB_foreign_key_columns fkc 
	ON	fk.database_id			= fkc.database_id
	AND	fk.object_id			= fkc.constraint_object_id
	WHERE	fkc.constraint_column_id	= 1
	AND	(fkc.database_id = @database_id OR @database_id IS NULL OR @PopulateDMVsForAll = 1)
	AND	(fkc.referenced_object_id = @object_id OR @object_id IS NULL OR @PopulateDMVsForAll = 1)

	UPDATE		ibl
		SET	duplicate_indexes	= STUFF((	SELECT	', ' + index_name AS [data()]
								FROM	dmv_IndexBaseLine iibl
								WHERE	ibl.database_id			= iibl.database_id
								 AND	ibl.object_id			= iibl.object_id
								 AND	ibl.index_id			<> iibl.index_id
								 AND	ibl.indexed_columns_compare	= iibl.indexed_columns_compare
								 AND	ibl.included_columns_compare	= iibl.included_columns_compare
								FOR XML PATH('')), 1, 2, '')
								
			,overlapping_indexes	= STUFF((	SELECT	', ' + index_name AS [data()]
								FROM	dmv_IndexBaseLine iibl
								WHERE	ibl.object_id			= iibl.object_id
								 AND	ibl.index_id			<> iibl.index_id
								 AND	(ibl.indexed_columns_compare	LIKE iibl.indexed_columns_compare + '%' 
								 OR	iibl.indexed_columns_compare	LIKE ibl.indexed_columns_compare + '%')
								 AND	ibl.indexed_columns_compare	<> iibl.indexed_columns_compare 
								FOR XML PATH('')), 1, 2, '')
								
			,related_foreign_keys = STUFF((		SELECT	', ' + foreign_key_name AS [data()]
								FROM	#ForeignKeys ifk
								WHERE	ifk.object_id			= ibl.object_id
								 AND	ibl.indexed_columns_compare	LIKE ifk.fk_columns_compare + '%'
								FOR XML PATH('')), 1, 2, '')
								
			,related_foreign_keys_xml = CAST((	SELECT	foreign_key_name
								FROM	#ForeignKeys ForeignKeys
								WHERE	ForeignKeys.object_id		= ibl.object_id
								 AND	ibl.indexed_columns_compare	LIKE ForeignKeys.fk_columns_compare + '%'
								FOR XML AUTO) as xml) 
	FROM		dmv_IndexBaseLine ibl

	INSERT INTO dmv_IndexBaseLine
	    (server_name, database_name, database_id, schema_id, schema_name, object_id, table_name, index_name, type_desc, existing_ranking, indexed_columns)
	SELECT		@@ServerName
			,DB_Name(t.database_id)
			,t.database_id
			,s.schema_id
			,s.name AS schema_name
			,t.object_id
			,t.name AS table_name
			,fk.foreign_key_name AS index_name
			,'--MISSING FOREIGN KEY--' as type_desc
			,9999
			,fk.fk_columns
	FROM		dbaperf.dbo.vw_AllDB_tables t
	JOIN		dbaperf.dbo.vw_AllDB_schemas s 
		ON	t.database_id			= s.database_id
		AND	t.schema_id			= s.schema_id
	JOIN		#ForeignKeys fk 
		ON	t.database_id			= fk.database_id
		AND	t.object_id			= fk.object_id
	LEFT JOIN	dmv_IndexBaseLine ia 
		ON	fk.database_id			= ia.database_id 
		AND	fk.object_id			= ia.object_id 
		AND	ia.indexed_columns_compare	LIKE fk.fk_columns_compare + '%'
	WHERE		ia.index_name			IS NULL;


	;WITH	ReadAggregation
		AS	(
			SELECT	row_id
				,CAST(100. * (user_seeks + user_scans + user_lookups)
				    /(NULLIF(SUM(user_seeks + user_scans + user_lookups) 
				    OVER(PARTITION BY database_id, schema_name, table_name), 0) * 1.) as decimal(12,2)) AS estimated_user_total_pct
				,SUM(buffer_mb) OVER(PARTITION BY database_id, schema_name, table_name) as table_buffer_mb
			FROM	dmv_IndexBaseLine
			)
		,WriteAggregation
		AS	(
			SELECT	row_id
				,CAST((100.00 * user_updates)
				    /(NULLIF(SUM(user_updates) 
				    OVER(PARTITION BY database_id, schema_name, table_name), 0) * 1.) as decimal(12,2)) AS estimated_user_total_pct
			FROM	dmv_IndexBaseLine 
			)
	UPDATE		ibl
		SET	estimated_user_total_read_pct		= COALESCE(r.estimated_user_total_pct, 0.00)
			,estimated_user_total_write_pct		= COALESCE(w.estimated_user_total_pct, 0.00)
			,table_buffer_mb			= r.table_buffer_mb
			,index_read_pct				= (COALESCE(user_total_read,0.00) * 100.00) / CASE WHEN COALESCE(user_total_read,0.00) + COALESCE(user_total_write,0.00) = 0.00 THEN 1.00 ELSE COALESCE(user_total_read,0.00) + COALESCE(user_total_write,0.00) END
			,index_write_pct			= (COALESCE(user_total_write,0.00) * 100.00) / CASE WHEN COALESCE(user_total_read,0.00) + COALESCE(user_total_write,0.00) = 0.00 THEN 1.00 ELSE COALESCE(user_total_read,0.00) + COALESCE(user_total_write,0.00) END
	FROM		dmv_IndexBaseLine ibl
	JOIN		ReadAggregation r 
		ON	ibl.row_id = r.row_id
	JOIN		WriteAggregation w 
		ON	ibl.row_id = w.row_id


	;WITH IndexAction
	AS (
	    SELECT row_id
		,CASE WHEN user_lookups > user_seeks AND type_desc IN ('CLUSTERED', 'HEAP', 'UNIQUE CLUSTERED') THEN 'REALIGN'
		    WHEN type_desc = '--MISSING FOREIGN KEY--' THEN 'CREATE'
		    WHEN type_desc = 'XML' THEN '---'
		    WHEN is_unique = 1 THEN '---'
		    WHEN type_desc = '--NONCLUSTERED--' AND ROW_NUMBER() OVER (PARTITION BY table_name ORDER BY user_total_read desc) <= 10 AND estimated_user_total_read_pct > 1 THEN 'CREATE'
		    WHEN type_desc = '--NONCLUSTERED--' THEN 'BLEND'
		    WHEN ROW_NUMBER() OVER (PARTITION BY database_id, table_name ORDER BY user_total_read desc, existing_ranking) > 10 THEN 'DROP' 
		    WHEN user_total_read = 0 THEN 'DROP' 
		    ELSE '---' END AS index_action
	    FROM dmv_IndexBaseLine
	)
	UPDATE		ibl
		SET	index_action = ia.index_action
	FROM		dmv_IndexBaseLine ibl 
	JOIN		IndexAction ia
		ON	ibl.row_id	= ia.row_id

	UPDATE		ibl
		SET	has_unique = 1
	FROM		dmv_IndexBaseLine ibl
	JOIN		(
			SELECT		DISTINCT
					database_id 
					,object_id 
			FROM		dbaperf.dbo.vw_AllDB_indexes i 
			WHERE		i.is_unique = 1
			) x 
		ON	ibl.database_id		= x.database_id
		AND	ibl.object_id		= x.object_id
END


SET	@Export_Source		= 'dbaperf.dbo.dmv_IndexBaseLine'
SELECT	@FileName		= REPLACE([dbaadmin].[dbo].[dbasp_base64_encode] (@@SERVERNAME+'|'+REPLACE(@Export_Source,'dbaperf.dbo.','')+'|'+@Database_Name+'|'+@Schema_Name+'|'+@Table_Name)+'.dat','=','$')
SET	@SCRIPT			= 'bcp '+@Export_Source+' out "'+@LocalPath+'\'+@FileName+'" -S G1SQLA\A,1252 -T -N'
Print	@Script
EXEC	xp_cmdshell		@SCRIPT, no_output


EXEC	[dbaadmin].[dbo].[dbasp_File_Transit] 
		@source_name		= @FileName
		,@source_path		= @UNCPath
		,@target_env		= @target_env
		,@target_server		= @target_server
		,@target_share		= @target_share
		,@retry_limit		= @retry_limit
  
waitfor delay '00:00:05'  
  
-- DELETE FILE AFTER SENDING
SET	@Script = 'DEL "'+ @UNCPath+'\'+@FileName+'"'
Print	@Script
exec	master..xp_cmdshell @Script, no_output
		
SET	@Export_Source		= 'dbaperf.dbo.dmv_MissingIndexSnapshot'
SELECT	@FileName		= REPLACE([dbaadmin].[dbo].[dbasp_base64_encode] (@@SERVERNAME+'|'+REPLACE(@Export_Source,'dbaperf.dbo.','')+'|'+@Database_Name+'|'+@Schema_Name+'|'+@Table_Name)+'.dat','=','$')
SET	@SCRIPT			= 'bcp '+@Export_Source+' out "'+@LocalPath+'\'+@FileName+'" -S G1SQLA\A,1252 -T -N'
Print	@Script
EXEC	xp_cmdshell		@SCRIPT, no_output

  
EXEC	[dbaadmin].[dbo].[dbasp_File_Transit] 
		@source_name		= @FileName
		,@source_path		= @UNCPath
		,@target_env		= @target_env
		,@target_server		= @target_server
		,@target_share		= @target_share
		,@retry_limit		= @retry_limit  

waitfor delay '00:00:05' 

-- DELETE FILE AFTER SENDING
SET	@Script = 'DEL "'+ @UNCPath+'\'+@FileName+'"'
Print	@Script
exec	xp_cmdshell @Script, no_output

GO








