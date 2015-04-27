-- Version 11
SET NOCOUNT ON
GO
DECLARE		@RunMode		int
		,@database_name		sysname
		,@schema_name		sysname
		,@table_name		sysname
		,@Fill_Factor		int
		,@PopulateDMVsForAll	bit
		,@ReportOnlyTopTable	bit
		
SELECT		@RunMode		= 3
				--	0 = Build dbaperf DMV's Only
				--	1 = Build DMV's and Run Report
				--	2 = Run Report without DMV's
				--	3 = Run Report From DMV's
		,@database_name		= 'WCDS'
		--,@schema_name		= 'dbo'
		--,@table_name		= 'DownloadDetail'
				
		,@Fill_Factor		= 98
		,@PopulateDMVsForAll	= 0
		,@ReportOnlyTopTable	= 0		

DECLARE		@TSQL1			VarChar(max)
		,@TSQL2			VarChar(max)
		,@TSQL3			VarChar(max)
		,@Object		sysname
		,@object_id		int
		,@object_id2		int
		,@database_id		int
		,@database_id2		int

		,@IndexScript		nvarchar(max)
		
SELECT		@object_id		= OBJECT_ID(@database_name+'.'+@schema_name+'.'+@table_name)
		,@database_id		= db_id(@database_name)
		,@IndexScript		= ''

IF @PopulateDMVsForAll = 1 
	SELECT	@database_id2		= NULL
		, @object_id2		= NULL
ELSE
	SELECT	@database_id2		= @database_id
		, @object_id2		= @object_id


SELECT		@database_name
		,@table_name
		,@object_id
		,@database_id

		
/*

row_id:				Row identifier used for populating the table
index_action:			Analysis recommendation on action to take on the index
	CREATE:		Recommend adding the index to the table.
	DROP:		Recommend dropping the index from the table
	BLEND:		Review the missing index details to see if the missing index details can be added to an existing index.
	REALIGN:	Bookmark lookups on the index exceed the number of seeks on the table.  Recommend investigating whether to move the clustered index to another index or add included columns to the indexes that are part of the bookmark lookups.

schema_id:			Schema ID
schema_name:			Name of the schema.
object_id:			Object ID
table_name:			Name of the table name
index_id:			Index ID
index_name:			Name of the index.
is_unique:			Flag indicating whether an index has a unique index.
has_unique:			Flag indicating whether the table has a unique index.
type_desc:			Type of index; either clustered or non-clustered.
partition_number:		Partition number.
reserved_page_count:		Total number of pages reserved for the index.
size_in_mb:			The amount of space in MB the index utilizes on disk.
buffered_page_count:		Total number of pages in the buffer for the index.
buffer_mb:			The amount of space in MB in the buffer for the index.
pct_in_buffer:			The percentage of an index that is current in the SQL Server buffer.
table_buffer_mb:		The amount of space in MB in the SQL Server buffer that is being utilized by the table.
row_count:			Number of rows in the index.
impact:				Calculation of impact of a potential index.  This is based on the seeks and scans that the index could have utilized multiplied by average improvement the index would have provided.  This is included only for missing indexes.
existing_ranking:		Ranking of the existing indexes ordered by user_total descending across the indexes for the table.
user_total:			Total number of seek, scan, and lookup operations for the index.
user_total_pct:			Percentage of total number of seek, scan, and lookup operations for this index compared to all seek, scan, and lookup operations for existing indexes for the table.
estimated_user_total_pct:	Percentage of total number of seek, scan, and lookup operations for this index compared to all seek, scan, and lookup operations for existing and potential indexes for the table.  This number is naturally skewed because a seek for potential Index A resulted in another operation on an existing index and both of these operations would be counted.
user_seeks:			Number of seek operations on the index.
user_scans:			Number of scan operations on the index.
user_lookups:			Number of lookup operations on the index.
row_lock_count:			Cumulative number of row locks requested.
row_lock_wait_count:		Cumulative number of times the Database Engine waited on a row lock.
row_lock_wait_in_ms:		Total number of milliseconds the Database Engine waited on a row lock.
row_block_pct:			Percentage of row locks that encounter waits on a row lock.
avg_row_lock_waits_ms:		Average number of milliseconds the Database Engine waited on a row lock.
indexed_columns:		Columns that are part of the index, missing index or foreign key.
included_columns:		Columns that are included in the index or missing index.
indexed_columns_compare:	Column IDs that are part of the index, missing index or foreign key
included_columns_compare:	Column IDs that are included in the index or missing index.
duplicate_indexes:		List of Indexes that exist on the table that are identical to the index on this row.
overlapping_indexes:		List of Indexes that exist on the table that overlap the index on this row.
related_foreign_keys:		List of foreign keys that are related to the index either as an exact match or covering index.
related_foreign_keys_xml:	XML document listing foreign keys that are related to the index either as an exact match or covering index.

*/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

IF OBJECT_ID('[dbo].[syn_dmv_IndexBaseLine]') IS NOT NULL
	DROP SYNONYM [dbo].[syn_dmv_IndexBaseLine]

IF OBJECT_ID('[dbo].[syn_dmv_MissingIndexSnapshot]') IS NOT NULL
	DROP SYNONYM [dbo].[syn_dmv_MissingIndexSnapshot]

IF OBJECT_ID('tempdb..##dmv_IndexBaseLine') IS NOT NULL
    DROP TABLE ##dmv_IndexBaseLine

IF OBJECT_ID('tempdb..##dmv_MissingIndexSnapshot') IS NOT NULL
    DROP TABLE ##dmv_MissingIndexSnapshot



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
    

BEGIN -- CLEAR AND CREATE DMV's or TEMP TABLES & VIEWS
	-- dmv_IndexBaseLine
	SET	@TSQL3 = 'dmv_IndexBaseLine'
	SET	@TSQL1 = 
'		(
		row_id int IDENTITY(1,1)
		,server_name sysname
		,database_name sysname
		,database_id INT
		,index_action varchar(50)
		,schema_id int
		,schema_name sysname
		,object_id int
		,table_name sysname
		,index_id int
		,index_name nvarchar(256)
		,is_unique bit DEFAULT(0)
		,has_unique bit DEFAULT(0)
		,type_desc nvarchar(255)
		,partition_number int
		,reserved_page_count bigint
		,page_count bigint
		,max_key_size int
		,size_in_mb decimal(12, 2)
		,buffered_page_count int
		,buffer_mb decimal(12, 2)
		,pct_in_buffer decimal(12, 2)
		,table_buffer_mb decimal(12, 2)
		,row_count bigint
		,impact int
		,existing_ranking bigint
		,user_total_read bigint
		,user_total_read_pct decimal(6, 2)
		,estimated_user_total_read_pct decimal(6, 2)
		,user_total_write bigint
		,user_total_write_pct decimal(6,2)
		,estimated_user_total_write_pct decimal(6,2)
		,index_read_pct decimal(6,2)
		,index_write_pct decimal(6,2)
		,user_seeks bigint
		,user_scans bigint
		,user_lookups bigint
		,user_updates bigint
		,row_lock_count bigint
		,row_lock_wait_count bigint
		,row_lock_wait_in_ms bigint
		,row_block_pct decimal(6, 2)
		,avg_row_lock_waits_ms bigint
		,page_lock_count bigint
		,page_lock_wait_count bigint
		,page_lock_wait_in_ms bigint
		,page_block_pct decimal(6, 2)
		,avg_page_lock_waits_ms bigint
		,splits bigint
		,indexed_columns nvarchar(max)
		,indexed_column_count int
		,included_columns nvarchar(max)
		,included_column_count int
		,indexed_columns_compare nvarchar(max)
		,included_columns_compare nvarchar(max)
		,duplicate_indexes nvarchar(max)
		,overlapping_indexes nvarchar(max)
		,related_foreign_keys nvarchar(max)
		,related_foreign_keys_xml xml
		)'

	IF @RunMode IN (0,1,3)
	BEGIN -- USE DMV's
		IF OBJECT_ID('[dbaperf].[dbo].['+@TSQL3+']') IS NULL
		BEGIN -- CREATE DMVs IF THIS IS FIRST TIME
			SET @TSQL2 = 'CREATE TABLE [dbaperf].[dbo].['+@TSQL3+']' + CHAR(13)+CHAR(10)+@TSQL1
			EXEC	(@TSQL2)
		END
		
		IF @RunMode IN (0,1)
		BEGIN
			SET	@TSQL2 = 'TRUNCATE TABLE [dbaperf].[dbo].['+@TSQL3+']; CREATE SYNONYM [dbo].[syn_'+@TSQL3+'] FOR [dbaperf].[dbo].['+@TSQL3+']'
			EXEC	(@TSQL2)
		END
		ELSE
		BEGIN
			SET	@TSQL2 = 'CREATE SYNONYM [dbo].[syn_'+@TSQL3+'] FOR [dbaperf].[dbo].['+@TSQL3+']'
			EXEC	(@TSQL2)
		END
	END
	ELSE
	BEGIN -- USE TEMP TABLES
		SET	@TSQL2 = 'CREATE TABLE ##'+@TSQL3+ CHAR(13)+CHAR(10)+@TSQL1
		EXEC	(@TSQL2)
		
		SET	@TSQL2 = 'CREATE SYNONYM [dbo].[syn_'+@TSQL3+'] FOR ##'+@TSQL3
		EXEC	(@TSQL2)
	END	


	-- dmv_MissingIndexSnapshot
	SET	@TSQL3 = 'dmv_MissingIndexSnapshot'
	SET	@TSQL1 = 
	'	(
		[server_name]		[nvarchar](128)		NULL
		,[database_name]	[nvarchar](4000)	NULL
		,[database_id]		[smallint]		NULL
		,[schema_id]		[int]			NULL
		,[schema_name]		[nvarchar](4000)	NULL
		,[object_id]		[int]			NULL
		,[table_name]		[nvarchar](4000)	NULL
		,[Improvement]		[float]			NULL
		,[CompleteQueryPlan]	[xml]			NULL
		,[Sproc_name]		[nvarchar](128)		NULL
		,[StatementID]		[float]			NULL
		,[StatementText]	[varchar](4000)		NULL
		,[StatementSubTreeCost]	[varchar](128)		NULL
		,[MissingIndex]		[xml]			NULL
		,[IndexImpact]		[float]			NULL
		,[usecounts]		[int]			NOT NULL
		,[IndexColumns]		[nvarchar](4000)	NULL
		,[IncludeColumns]	[nvarchar](4000)	NULL
		,[IndexName]		[nvarchar](4000)	NULL
		)'

	IF @RunMode IN (0,1,3)
	BEGIN -- USE DMV's
		IF OBJECT_ID('[dbaperf].[dbo].['+@TSQL3+']') IS NULL
		BEGIN -- CREATE DMVs IF THIS IS FIRST TIME
			SET @TSQL2 = 'CREATE TABLE [dbaperf].[dbo].['+@TSQL3+']' + CHAR(13)+CHAR(10)+@TSQL1
			EXEC	(@TSQL2)
		END
		
		IF @RunMode IN (0,1)
		BEGIN
			SET	@TSQL2 = 'TRUNCATE TABLE [dbaperf].[dbo].['+@TSQL3+']; CREATE SYNONYM [dbo].[syn_'+@TSQL3+'] FOR [dbaperf].[dbo].['+@TSQL3+']'
			EXEC	(@TSQL2)
		END
		ELSE
		BEGIN
			SET	@TSQL2 = 'CREATE SYNONYM [dbo].[syn_'+@TSQL3+'] FOR [dbaperf].[dbo].['+@TSQL3+']'
			EXEC	(@TSQL2)
		END
	END
	ELSE
	BEGIN -- USE TEMP TABLES
		SET	@TSQL2 = 'CREATE TABLE ##'+@TSQL3+ CHAR(13)+CHAR(10)+@TSQL1
		EXEC	(@TSQL2)
		
		SET	@TSQL2 = 'CREATE SYNONYM [dbo].[syn_'+@TSQL3+'] FOR ##'+@TSQL3
		EXEC	(@TSQL2)
	END
		
END -- CLEAR AND CREATE DMV's or TEMP TABLES & VIEWS

IF @RunMode IN (0,1,2)
BEGIN -- POPULATE DMVs or TEMP TABLES

	-------------------------------------------------------
	-------------------------------------------------------
	-- POPULATE dmv_MissingIndexSnapshot
	-------------------------------------------------------
	-------------------------------------------------------
	;WITH XMLNAMESPACES    
		(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')	
	INSERT INTO	syn_dmv_MissingIndexSnapshot		
	SELECT		@@ServerName			AS server_name
			, REPLACE(
			  REPLACE(
			  MissingIndex.value
			   ('(./@Database)[1]','sysname')
			  ,'[','')
			  ,']','')			AS database_name
			, DB_ID(
			  REPLACE(
			  REPLACE(
			  MissingIndex.value
			   ('(./@Database)[1]','sysname')
			  ,'[','')
			  ,']',''))			AS database_id
			, SCHEMA_ID(
			  REPLACE(
			  REPLACE(
			  MissingIndex.value
			   ('(./@Schema)[1]','sysname')
			  ,'[','')
			  ,']',''))			AS schema_id
			, REPLACE(
			  REPLACE(
			  MissingIndex.value
			   ('(./@Schema)[1]','sysname')
			  ,'[','')
			  ,']','')			AS schema_name
			, OBJECT_ID(
			  MissingIndex.value
			   ('(./@Database)[1]','sysname')
			  + '.'
			+ MissingIndex.value
			   ('(./@Schema)[1]','sysname')
			   + '.' 
			+ MissingIndex.value
			  ('(./@Table)[1]','sysname')
			  )				AS object_id
			, REPLACE(
			  REPLACE(
			  MissingIndex.value
			   ('(./@Table)[1]','sysname')
			   ,'[','')
			   ,']','')			AS table_name
			, MissingIndex.value
			   ('(../../../../@StatementSubTreeCost)[1]', 'VARCHAR(128)')
			  * ISNULL(MissingIndex.value
			   ('(../@Impact)[1]','float'), 0) 
			  * usecounts			AS Improvement 
			, query_plan			AS CompleteQueryPlan 
			, OBJECT_NAME(objectid)		AS Sproc_name
			, MissingIndex.value
			   ('(../../../../@StatementId)[1]', 'float')
							AS StatementID 
			, MissingIndex.value
			   ('(../../../../@StatementText)[1]', 'VARCHAR(4000)')
							AS StatementText 
			, MissingIndex.value
			   ('(../../../../@StatementSubTreeCost)[1]', 'VARCHAR(128)')
							AS StatementSubTreeCost 
			, MissingIndex.query
			   ('..')
							AS MissingIndex 
			, MissingIndex.value
			   ('(../@Impact)[1]','float') 
							AS IndexImpact 
			, usecounts
			
			, REPLACE(CAST(MissingIndex.query
			   ('data( for $cg in ./ColumnGroup
				where $cg/@Usage="EQUALITY" or $cg/@Usage="INEQUALITY"
				return $cg/Column/@Name	)')
				AS NVarchar(255)),'] [','], [')			AS IndexColumns

			, ', ' 
			+ REPLACE(CAST(MissingIndex.query
			   ('data( for $cg in ./ColumnGroup
				where $cg/@Usage="INCLUDE"
				return $cg/Column/@Name	)')
				AS NVarchar(255)),'] [','], [')			AS IncludeColumns


			, 'IX_' 
			+ REPLACE(
			  REPLACE(
			  MissingIndex.value
			   ('(./@table)[1]','sysname')
			   ,'[','')
			   ,']','')
			+ '_'
			+ REPLACE(REPLACE(REPLACE(CAST(MissingIndex.query
			   ('data( for $cg in ./ColumnGroup
				where $cg/@Usage="EQUALITY" or $cg/@Usage="INEQUALITY"
				return $cg/Column/@ColumnId )')
				AS NVarchar(255)),'[',''),']',''),' ','_')
			+ CASE 				
				WHEN
				  REPLACE(REPLACE(REPLACE(CAST(MissingIndex.query
				   ('data( for $cg in ./ColumnGroup
					where $cg/@Usage="INCLUDE"
					return $cg/Column/@ColumnId )')
					AS NVarchar(255)),'[',''),']',''),' ','_') = ''
				THEN ''
				ELSE
				'_INC_'
				+ REPLACE(REPLACE(REPLACE(CAST(MissingIndex.query
				   ('data( for $cg in ./ColumnGroup
					where $cg/@Usage="INCLUDE"
					return $cg/Column/@ColumnId )')
					AS NVarchar(255)),'[',''),']',''),' ','_')
				END		AS IndexName

	FROM		sys.dm_exec_cached_plans		AS ecp
	CROSS APPLY	sys.dm_exec_query_plan(plan_handle)	AS eqp
	CROSS APPLY	query_plan.nodes
			 ('//MissingIndex')			AS qp(MissingIndex)
	WHERE		(
			query_plan.exist 
			 ('//MissingIndexes//MissingIndex[@Database = sql:variable("@database_name")]') = 1
			OR @database_name IS NULL
			OR @PopulateDMVsForAll = 1
			)
		AND	(
			query_plan.exist 
			 ('//MissingIndexes//MissingIndex[@Table = sql:variable("@table_name")]') = 1
			OR @table_name IS NULL
			OR @PopulateDMVsForAll = 1
			)

					
	ORDER BY	Improvement DESC

	-------------------------------------------------------
	-------------------------------------------------------
	-- POPULATE dmv_IndexBaseLine
	-------------------------------------------------------
	-------------------------------------------------------

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
	INSERT INTO syn_dmv_IndexBaseLine
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
	    
	LEFT JOIN	sys.dm_db_index_operational_stats(@database_id2, @object_id2, NULL, NULL) ios 
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


	INSERT INTO syn_dmv_IndexBaseLine
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
	FROM		syn_dmv_IndexBaseLine T1
	JOIN		syn_dmv_IndexBaseLine T2
		ON	T1.database_id		= T2.database_id
		AND	T1.object_id		= T2.Object_id
		AND	T2.type_desc		IN ('CLUSTERED', 'HEAP', 'UNIQUE CLUSTERED')
	JOIN		(
			Select		T1.row_id
					,SUM(T3.max_length)AS TotalIndexKeySize
			FROM		syn_dmv_IndexBaseLine				T1
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
								FROM	syn_dmv_IndexBaseLine iibl
								WHERE	ibl.database_id			= iibl.database_id
								 AND	ibl.object_id			= iibl.object_id
								 AND	ibl.index_id			<> iibl.index_id
								 AND	ibl.indexed_columns_compare	= iibl.indexed_columns_compare
								 AND	ibl.included_columns_compare	= iibl.included_columns_compare
								FOR XML PATH('')), 1, 2, '')
								
			,overlapping_indexes	= STUFF((	SELECT	', ' + index_name AS [data()]
								FROM	syn_dmv_IndexBaseLine iibl
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
	FROM		syn_dmv_IndexBaseLine ibl

	INSERT INTO syn_dmv_IndexBaseLine
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
	LEFT JOIN	syn_dmv_IndexBaseLine ia 
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
			FROM	syn_dmv_IndexBaseLine
			)
		,WriteAggregation
		AS	(
			SELECT	row_id
				,CAST((100.00 * user_updates)
				    /(NULLIF(SUM(user_updates) 
				    OVER(PARTITION BY database_id, schema_name, table_name), 0) * 1.) as decimal(12,2)) AS estimated_user_total_pct
			FROM	syn_dmv_IndexBaseLine 
			)
	UPDATE		ibl
		SET	estimated_user_total_read_pct		= COALESCE(r.estimated_user_total_pct, 0.00)
			,estimated_user_total_write_pct		= COALESCE(w.estimated_user_total_pct, 0.00)
			,table_buffer_mb			= r.table_buffer_mb
			,index_read_pct				= (COALESCE(user_total_read,0.00) * 100.00) / CASE WHEN COALESCE(user_total_read,0.00) + COALESCE(user_total_write,0.00) = 0.00 THEN 1.00 ELSE COALESCE(user_total_read,0.00) + COALESCE(user_total_write,0.00) END
			,index_write_pct			= (COALESCE(user_total_write,0.00) * 100.00) / CASE WHEN COALESCE(user_total_read,0.00) + COALESCE(user_total_write,0.00) = 0.00 THEN 1.00 ELSE COALESCE(user_total_read,0.00) + COALESCE(user_total_write,0.00) END
	FROM		syn_dmv_IndexBaseLine ibl
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
	    FROM syn_dmv_IndexBaseLine
	)
	UPDATE		ibl
		SET	index_action = ia.index_action
	FROM		syn_dmv_IndexBaseLine ibl 
	JOIN		IndexAction ia
		ON	ibl.row_id	= ia.row_id

	UPDATE		ibl
		SET	has_unique = 1
	FROM		syn_dmv_IndexBaseLine ibl
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

IF @RunMode IN (1,2,3) 
BEGIN -- RUN REPORTS

	SELECT		row_number() OVER(ORDER BY max(improvement) desc) as [Rank]
			,[database_name]+'.'+[schema_name]+'.'+[Table_name]
			,max(improvement) improvement
	FROM		syn_dmv_MissingIndexSnapshot
	WHERE		(database_id = @database_id OR @database_id IS NULL)
	    AND		(object_id = @object_id OR @object_id IS NULL)
	GROUP BY	[database_name]+'.'+[schema_name]+'.'+[Table_name]

	SELECT		T1.server_name
			,T1.database_name
			,T1.schema_name + '.' + T1.table_name as object_name
			,T1.has_unique
			,T1.table_buffer_mb
			,T1.index_action
			,T1.index_name
			,T1.indexed_columns
			,T1.included_columns
			,T1.is_unique
			,REPLACE(T1.type_desc,'-','') AS type_desc
			,T1.impact AS impact_estimate_curent
			,T2.Improvement AS impact_estimate_cached
			,T2.[IndexImpact]
			,T1.size_in_mb
			,T1.buffer_mb
			,T1.pct_in_buffer
			,T1.row_count
			,T1.page_count
			,T1.max_key_size
			,T1.user_total_read
			,T1.user_total_read_pct
			,T1.estimated_user_total_read_pct
			,T1.user_total_write
			,T1.user_total_write_pct
			,T1.estimated_user_total_write_pct
			,T1.index_read_pct
			,T1.index_write_pct
			,T1.user_seeks
			,T1.user_scans
			,T1.user_lookups
			,T1.user_updates
			,T1.row_lock_count
			,T1.row_lock_wait_count
			,T1.row_lock_wait_in_ms
			,T1.row_block_pct
			,T1.avg_row_lock_waits_ms
			,T1.page_lock_count
			,T1.page_lock_wait_count
			,T1.page_lock_wait_in_ms
			,T1.page_block_pct
			,T1.avg_page_lock_waits_ms
			,T1.splits
			,T1.indexed_column_count
			,T1.included_column_count
			,T1.duplicate_indexes
			,T1.overlapping_indexes
			,T1.related_foreign_keys
			,T1.related_foreign_keys_xml
			,T2.[CompleteQueryPlan]
			,T2.[Sproc_name]
			,T2.[StatementText]
			,T2.[StatementSubTreeCost]
			,T2.[MissingIndex]
			,T2.[usecounts]
			,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
				'USE [{DATABASE_NAME}]'+CHAR(13)+CHAR(10)+
				'GO'+CHAR(13)+CHAR(10)+
				'IF NOT EXISTS (SELECT * FROM dbaperf.dbo.vw_AllDB_indexes WHERE object_id = OBJECT_ID(N''[{SCHEMA_NAME}].[{TABLE_NAME}]'') AND name = N''{INDEX_NAME}'')'+CHAR(13)+CHAR(10)+
				'CREATE INDEX [{INDEX_NAME}] ON [{SCHEMA_NAME}].[{TABLE_NAME}]'+CHAR(13)+CHAR(10)+
				'('+CHAR(13)+CHAR(10)+
				'	{INDEX_COLUMNS}'+CHAR(13)+CHAR(10)+
				')'+CHAR(13)+CHAR(10)
				,'{DATABASE_NAME}'	,T1.database_name)
				,'{SCHEMA_NAME}'	,T1.schema_name)
				,'{TABLE_NAME}'		,T1.table_name)
				,'{INDEX_NAME}'		,T1.Index_Name)
				,'{INDEX_COLUMNS}'	,T1.indexed_columns)

			+ COALESCE(
				'INCLUDE'+CHAR(13)+CHAR(10)+
				'('+CHAR(13)+CHAR(10)+
				'	'+STUFF(T1.included_columns,1,1,'')+CHAR(13)+CHAR(10)+
				')'+CHAR(13)+CHAR(10)
				,'')

			+ 'WITH'+CHAR(13)+CHAR(10)+ 
				'('+CHAR(13)+CHAR(10)+
				'  SORT_IN_TEMPDB	 = ON'+CHAR(13)+CHAR(10)+
				', IGNORE_DUP_KEY	 = OFF'+CHAR(13)+CHAR(10)+
				', DROP_EXISTING		 = OFF'+CHAR(13)+CHAR(10)+
				', ONLINE		 = ON'+CHAR(13)+CHAR(10)+
				', PAD_INDEX		 = OFF'+CHAR(13)+CHAR(10)+
				', STATISTICS_NORECOMPUTE = OFF'+CHAR(13)+CHAR(10)+
				', ALLOW_ROW_LOCKS	 = ON'+CHAR(13)+CHAR(10)+
				', ALLOW_PAGE_LOCKS	 = ON'+CHAR(13)+CHAR(10)+
				')' AS index_create_statement
				
			,CASE T1.index_action
				WHEN 'CREATE' THEN 1
				WHEN 'BLEND' THEN 1
				ELSE 0 END AS Issue_Missing
				
			,CASE T1.index_action
				WHEN 'Drop' THEN 1
				ELSE 0 END AS Issue_Drop
				
			,CASE T1.index_action
				WHEN 'REALIGN' Then 1
				ELSE 0 END AS Issue_Realign
			
			,CASE WHEN T1.index_read_pct < 5 THEN 1 ELSE 0 END AS Issue_LowRead
				
			,CASE WHEN T1.Splits > (T1.user_updates / 2) THEN 1 ELSE 0 END AS Issue_HighSplits
				
			,CASE WHEN T1.duplicate_indexes IS NULL THEN 0 ELSE 1 END AS Issue_Duplicates	
			
			,CASE WHEN T1.overlapping_indexes IS NULL THEN 0 ELSE 1 END AS Issue_Overlaps	
					
	FROM		syn_dmv_IndexBaseLine T1
	LEFT JOIN	syn_dmv_MissingIndexSnapshot T2
		ON	T1.database_id				= T2.database_id
		AND	T1.indexed_columns			= T2.[IndexColumns]
		AND	COALESCE(T1.included_columns,', ')	= T2.[IncludeColumns]
		AND	T1.type_desc				= '--NONCLUSTERED--'
		
	WHERE		(T1.database_id = @database_id OR @database_id IS NULL)
	    AND		(T1.object_id = @object_id OR @object_id IS NULL)
		
	ORDER BY	T1.Database_name
			, T1.table_buffer_mb DESC
			, T1.Object_id
			, impact_estimate_curent desc
			, T1.user_total_read DESC



	DECLARE IndexCreateCursor CURSOR
	FOR
	SELECT		'-----------------------------------------------------------------'+CHAR(13)+CHAR(10)
			+ '-----------------------------------------------------------------'+CHAR(13)+CHAR(10)
			+ '--	' + COALESCE(T1.database_name,'') + '.' + COALESCE(T1.schema_name,'') + '.' + COALESCE(T1.table_name,'') +CHAR(13)+CHAR(10)
			+ '--	' + COALESCE(T1.Index_Name,'')+CHAR(13)+CHAR(10)
			+ '-----------------------------------------------------------------'+CHAR(13)+CHAR(10)
			+ '-----------------------------------------------------------------'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
			+ '--	TEST QUERY FROM ' + COALESCE(T2.[Sproc_name],'')+CHAR(13)+CHAR(10)
			+ '--	SUB-TREE COST:'+COALESCE(CAST(T2.[StatementSubTreeCost] AS VarChar),'')+'  USE-COUNTS:'+COALESCE(CAST(T2.[usecounts] AS VarChar),'')+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
			+ 'BEGIN	-- BASELINE TEST QUERY'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
			+ COALESCE(T2.[StatementText],'-- NO EXAMPLE FOUND')+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
			+ 'END	-- BASELINE TEST QUERY'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+'GO'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
			+ 'BEGIN	-- CREATE INDEX'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
			+ REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
				'USE [{DATABASE_NAME}]'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+
				'IF NOT EXISTS (SELECT * FROM dbaperf.dbo.vw_AllDB_indexes WHERE object_id = OBJECT_ID(N''[{SCHEMA_NAME}].[{TABLE_NAME}]'') AND name = N''{INDEX_NAME}'')'+CHAR(13)+CHAR(10)+
				'CREATE INDEX [{INDEX_NAME}] ON [{SCHEMA_NAME}].[{TABLE_NAME}]'+CHAR(13)+CHAR(10)+
				'('+CHAR(13)+CHAR(10)+
				'	{INDEX_COLUMNS}'+CHAR(13)+CHAR(10)+
				')'+CHAR(13)+CHAR(10)
				,'{DATABASE_NAME}'	,T1.database_name)
				,'{SCHEMA_NAME}'	,T1.schema_name)
				,'{TABLE_NAME}'		,T1.table_name)
				,'{INDEX_NAME}'		,T1.Index_Name)
				,'{INDEX_COLUMNS}'	,T1.indexed_columns)
			+ COALESCE(
				'INCLUDE'+CHAR(13)+CHAR(10)+
				'('+CHAR(13)+CHAR(10)+
				'	'+STUFF(T1.included_columns,1,1,'')+CHAR(13)+CHAR(10)+
				')'+CHAR(13)+CHAR(10)
				,'')

			+ 'WITH'+CHAR(13)+CHAR(10)+ 
				'('+CHAR(13)+CHAR(10)+
				'  SORT_IN_TEMPDB	 = ON'+CHAR(13)+CHAR(10)+
				', IGNORE_DUP_KEY	 = OFF'+CHAR(13)+CHAR(10)+
				', DROP_EXISTING		 = OFF'+CHAR(13)+CHAR(10)+
				', ONLINE		 = ON'+CHAR(13)+CHAR(10)+
				', PAD_INDEX		 = OFF'+CHAR(13)+CHAR(10)+
				', STATISTICS_NORECOMPUTE = OFF'+CHAR(13)+CHAR(10)+
				', ALLOW_ROW_LOCKS	 = ON'+CHAR(13)+CHAR(10)+
				', ALLOW_PAGE_LOCKS	 = ON'+CHAR(13)+CHAR(10)+
				')'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) 
			+ 'END	-- CREATE INDEX'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+'GO'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
			+ 'BEGIN	-- IMPROVEMENT TEST QUERY'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
			+ COALESCE(T2.[StatementText],'-- NO EXAMPLE FOUND')+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
			+ 'END	-- IMPROVEMENT TEST QUERY'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+'GO'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) AS [IndexCreateScript]

	FROM		syn_dmv_IndexBaseLine T1
	LEFT JOIN	syn_dmv_MissingIndexSnapshot T2
		ON	T1.database_id				= T2.database_id
		AND	T1.indexed_columns			= T2.[IndexColumns]
		AND	COALESCE(T1.included_columns,', ')	= T2.[IncludeColumns]
		AND	T1.type_desc				= '--NONCLUSTERED--'
		


	WHERE		(T1.database_id = @database_id OR @database_id IS NULL)
	    AND		(T1.object_id = @object_id OR @object_id IS NULL)
	    AND		T1.impact IS NOT NULL
	    	
	ORDER BY	T1.Database_name
			, T1.table_buffer_mb DESC
			, T1.Object_id
			, T1.impact desc
			, T1.user_total_read DESC

	OPEN IndexCreateCursor
	FETCH NEXT FROM IndexCreateCursor INTO @IndexScript
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			PRINT		@IndexScript
		END
		FETCH NEXT FROM IndexCreateCursor INTO @IndexScript
	END

	CLOSE IndexCreateCursor
	DEALLOCATE IndexCreateCursor

END


IF OBJECT_ID('[dbo].[syn_dmv_IndexBaseLine]') IS NOT NULL
	DROP SYNONYM [dbo].[syn_dmv_IndexBaseLine]

IF OBJECT_ID('[dbo].[syn_dmv_MissingIndexSnapshot]') IS NOT NULL
	DROP SYNONYM [dbo].[syn_dmv_MissingIndexSnapshot]

IF OBJECT_ID('tempdb..##dmv_IndexBaseLine') IS NOT NULL
    DROP TABLE ##dmv_IndexBaseLine

IF OBJECT_ID('tempdb..##dmv_MissingIndexSnapshot') IS NOT NULL
    DROP TABLE ##dmv_MissingIndexSnapshot

GO













