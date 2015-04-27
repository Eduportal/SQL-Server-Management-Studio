USE [dbaadmin]

if object_id(N'[dbasp_IndexMaintenance]') is null
	exec (N'create proc [dbasp_IndexMaintenance] as return 0')
go
alter procedure [dbasp_IndexMaintenance]
	@usesOnlineReindex		bit		= 1
	,@mode				int		= 0
	,@fragThreshold			int		= 8
	,@RebuildThreshold		int		= 30
	,@fillFactor_HighRead		int		= 100
	,@fillFactor_LowRead		int		= 80
	,@fillFactor			int		= 90
	,@databaseName			nvarchar(128) 
	,@maxIndexLevelToConsider	int		= 0
	,@sortInTempDb			bit		= 1
	,@minPages			int		= 1000
	,@continueOnError		bit		= 0
	,@ScriptMode			TinyInt		= 2
	,@Path				VARCHAR(1024)	= 'd:'
	,@Filename			VARCHAR(1024)	= 'IndexMaintenanceScript.sql'
	,@exceptionXML			xml = 
N'
<EXCEPTION>
	<Exclude ScansPerHr="1" />
</EXCEPTION>		
'	
AS
/*
Description: Scans Index Physical Stats from DMVs and optionally rebuilds indexes
Parameters:


monotonically increasing key

	@usesOnlineReindex		= Whether or not online reindexing is used.
	
	@mode				0= rebuild	(failback to reorganize if not allowd). 
						If using online rebuild, reorganize objects that can't 
						be rebuilt online. 
					1= rebuild only	(failback to offline if not allowed). 
						If using online rebuild, objects that can't be rebuilt 
						online will be rebuilt offline. 
					2= reorganize only.
					3= Auto 
						Uses @RebuildThreshold to automaticly switch between
						Rebuild(0) and Reorginize(2).
						
	@fragThreshold			= Apply maintenance when fragementation is over this threshold
	
	@RebuildThreshold		= If in Auto Mode, Anything with Fragmentation >= this are rebuilt
						instead of reorginized.
						
	@fillFactor			= Page fill defaults to 80
	
	@databaseName			= The target database.
	
	@maxIndexLevelToConsider	= Num levels of an index to check for fragmentation: 
						0= leaf level only
						1= leaf + index_level 1
						2.. etc.
						
	@sortInTempDb			1= sort in tempdb. 
					0= sort in user db
					
	@minPages			= Min pages for an index to be eligible for maintenance.
	
	@continueOnError		= Set to 1 to continue on and reindex other tables after catching an error. 
						The job will still fail after completion.
						
	@exceptionXML			= A list of exceptions: Elements to exclude from the job. 
						Reads SchemaName, TableName, and TndexName.
						
	@ScriptMode			0= Execute Now, Do not Create Script.
					1= Output Script to a file. Nothing Executed Now.
					2= Output Script to a Screen. Nothing Executed Now.
					3= Output Script to a File & Screen. Nothing Executed Now.
					
	@Path & @Filename		= point to location of Script to be generated.

@XSpec XML wcds:
<EXCEPTION>
	<Exclude SchemaName="WTAB" />
	<Exclude SchemaName="EVT" TableName="Log" />
	<Exclude TableName="z%" />
	<Exclude ScansPerHr="1" />
</EXCEPTION>

*******************************************************************************
Change History
*******************************************************************************
Date:		Author:		Description:
----------	------------	--------------------------------------------------
2008-05-19	SteveL		Created
2009-02-01	SteveL		Improved error handling, flow control, loops through indexes instead of partitions.
2009-02-07	SteveL		Added @exceptionXML parameter support.
2010-04-01	SteveL		Modified For GettyImages.
*/
set nocount on

BEGIN TRY -- Outer Try block
	DECLARE 
		@maxFragPercent tinyint
		,@databaseID tinyint
		,@pageCount bigint
		,@reindexId int
		,@schemaName sysname
		,@tableName sysname
		,@tableObjectId int
		,@objDescription nvarchar(1000) 
		,@indexId int
		,@indexName sysname
		,@totalPages bigint
		,@indexSizeGB int
		,@sql nvarchar(max)
		,@onlineIndexingForbidden bit
		,@operation nvarchar(50)
		,@runStarted datetime
		,@indexStartDate datetime
		,@getReindexItems nvarchar(max)
		,@checkOnlineIndexingSQL nvarchar(max)
		,@getPhysicalStatsSQL nvarchar(max)
		,@breakNow bit
		,@exclusionId tinyint
		,@maxExclusionId tinyint
		,@exclusionItem nvarchar(2000)
		,@rowcount bigint
		,@imPhysicalStatsId bigint
		,@ReadPct float
		,@Splits Int
		,@OrigFillFactor Int
	--------------------------------------------
	-- DECLARE EVT VARIABLES
	--------------------------------------------
	BEGIN
		DECLARE
			@cEModule sysname
			,@cEMessage varchar(32)
			,@lEType varchar(16)
			,@lMsg nvarchar(max)
			,@lError bit
			,@Diagnose bit
			,@lRunSpec xml
			,@processGUID uniqueidentifier

		SELECT @cEModule='[dbasp_IndexMaintenance]'
			, @cEMessage='EVT_SUR'
			, @lError=0
			, @Diagnose=1
			, @ProcessGUID=newid()
			, @breakNow=0
			, @continueOnError= coalesce(@continueOnError,0) -- if this is passed in null, default it to zero.
	END

		DECLARE @exclusionTable table (
			exclusionId tinyint identity primary key -- using tinyint on purpose: let's not support more than 255 exclusions
			,schemaName sysname
			,tableName sysname
			,indexName sysname
			,ScansPerHr decimal(10,2)
			)
			
		DECLARE	@ExcludedIndexes TABLE
			(
			ID	INT IDENTITY PRIMARY KEY
			,DatabaseName	sysname
			,TableName	sysname
			,IndexName	sysname
			,Reason		VarChar(8000)
			)
			
		DECLARE	@SkipedIndexes TABLE
			(
			ID	INT IDENTITY PRIMARY KEY
			,DatabaseName	sysname
			,TableName	sysname
			,IndexName	sysname
			,Reason		VarChar(8000)
			)
						
		DECLARE	@RebuiltIndexes TABLE
			(
			ID	INT IDENTITY PRIMARY KEY
			,DatabaseName	sysname
			,TableName	sysname
			,IndexName	sysname
			,Reason		VarChar(8000)
			)
			
		DECLARE	@ReorgedIndexes TABLE
			(
			ID	INT IDENTITY PRIMARY KEY
			,DatabaseName	sysname
			,TableName	sysname
			,IndexName	sysname
			,Reason		VarChar(8000)
			)			
				
		DECLARE	@OutputScript	VarChar(max)
		DECLARE	@OutputReport	VarChar(max)
		DECLARE @OutputScreen	VarChar(8000)	
			
	SELECT @databaseID=database_id
	from sys.databases
	where name=@databaseName;
	
	SET	@OutputScript		=
'USE DBAADMIN;
BEGIN -- DECLARE VARIABLES
	DECLARE	@cEModule		sysname
		,@cEMessage		varchar(32)
		,@lEType		varchar(16)
		,@lMsg			nvarchar(max)
		,@lError		bit
		,@Diagnose		bit
		,@lRunSpec		xml
		,@processGUID		uniqueidentifier	
		,@ScriptMode		bit
		,@imPhysicalStatsId	bigint
		,@ScreenMsg		VarChar(max)
END
BEGIN	-- SET GLOBAL VALUES
	SELECT	@cEModule		= ''[dbasp_IndexMaintenance]''
		,@cEMessage		= ''EVT_SUR''
		,@processGUID		= NEWID()
		,@Diagnose		= 1
		,@ScriptMode		= '+CAST(@ScriptMode AS VarChar(10))+'
END'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)

	if @usesOnlineReindex = 1 AND SERVERPROPERTY('Edition') NOT IN ('Enterprise Edition','Enterprise Evaluation Edition','Developer Edition')
		BEGIN
			--------------------------------------------
			-- LOG MESSAGE /W RAISERROR
			--------------------------------------------
			set @lMsg=N'Server Edition ' + CAST(SERVERPROPERTY('Edition') AS VarChar(255)) + ': Online Reindexing Not Allowed'
			--------------------------------------------
			exec [dbasp_LogMsg]
				@ModuleName=@cEModule
				,@MessageKeyword=@cEMessage
				,@TypeKeyword='EVT_FAIL'
				,@ProcessGUID=@ProcessGUID
				,@AdHocMsg = @lMsg 
				,@Diagnose=@Diagnose
				,@ScriptMode=@ScriptMode
			--------------------------------------------
			RAISERROR (@lMsg,16,1)
			--------------------------------------------		
		END

	if (@databaseID is null or @mode not in (0,1,2,3) or coalesce(@ScriptMode,-1) not in (0,1,2,3))
		begin
			--------------------------------------------
			-- LOG MESSAGE /W RAISERROR
			--------------------------------------------
			set @lMsg=N'Incorrect DatabaseName, Mode, or ScriptMode. Check parameters';
			--------------------------------------------
			exec [dbasp_LogMsg]
				@ModuleName=@cEModule
				,@MessageKeyword=@cEMessage
				,@TypeKeyword='EVT_FAIL'
				,@ProcessGUID=@ProcessGUID
				,@AdHocMsg = @lMsg 
				,@Diagnose=@Diagnose
				,@ScriptMode=@ScriptMode
			--------------------------------------------
			RAISERROR (@lMsg,16,1)
			--------------------------------------------
		end

	SET @runStarted = getdate() --Date that the entire run started

	--Log start of run to EVT
	--------------------------------------------
	-- LOG MESSAGE
	--------------------------------------------
	SET @lMsg = @databaseName + N': Starting Index Maintenance' 
		+ case @ScriptMode
			when 0 then N'(Live Execution)' 
			when 1 then N'(Script to File)' 
			when 2 then N'(Script to Screen)' 
			when 3 then N'(Script to File & Screen) '
			ELSE '(Unknown ScriptMode) ' 
			END
		+ N'Mode is ' + case @mode 
					when 0 then N'rebuild online or reorganize.' 
					when 1 then N'rebuild only.' 
					when 2 then N'reorganize only.'
					when 3 then N'Auto.'
					ELSE 'Unknown.' 
					end
		+ N'Index Page Threshold is ' + cast(@minPages as nvarchar(10)) + N' pages '
		+ N'Fragmentation Threshold is ' + cast(@fragThreshold as nvarchar) + N'%. '
		+ CASE @mode 
			WHEN 3 THEN 'AutoRebuild Threshold is '+ cast(@RebuildThreshold as nvarchar) + N'%. '
			ELSE ''
			END
		+ N'Sort In TempDb is ' + case @sortInTempDb 
						when 1 then N'on.' 
						else N'off.' 
						end
	--------------------------------------------
	exec [dbasp_LogMsg]
		@ModuleName=@cEModule
		,@MessageKeyword=@cEMessage
		,@TypeKeyword='EVT_START'
		,@ProcessGUID=@ProcessGUID
		,@AdHocMsg = @lMsg 
		,@Diagnose=@Diagnose
		,@ScriptMode=@ScriptMode
	--------------------------------------------
	--------------------------------------------

	--------------------------------------------
	-- BUILD OBJECT TABLE
	--------------------------------------------
	DECLARE @reindex table (
		reindexId int identity
		, SchemaName sysname
		, tableName sysname
		, tableObjectId int
		, indexId int
		, indexName sysname
		, totalPages int
		, indexSizeMB int
		, user_seeks int
		, user_scans int
		, user_lookups int
		, user_updates int
		, ReadPct float
		, WritePct float
		, Splits int
		, OrigFillFactor int
		, IndexUsage int
		, IndexUsagetoSizeRatio decimal(10,2)
		, UptimeHr decimal(10,2)
		, ScansPerHr decimal(10,2)
	)

	SELECT @getReindexItems = REPLACE(
N'SELECT		schemaName = s.name
			, tableName = o.name
			, tableObjectId= o.object_id
			, si.index_id
			, indexName = si.name
			, totalPages=sum(au.Total_Pages)
			, indexSizeMB = cast(sum(au.Total_Pages) * 8.00 / 1024.00 as decimal(10,2))
			,COALESCE(MAX(user_seeks),0)user_seeks
			,COALESCE(MAX(user_scans),0)user_scans
			,COALESCE(MAX(user_lookups),0)user_lookups
			,COALESCE(MAX(user_updates),0)user_updates
			,COALESCE(MAX((([user_seeks]+[user_scans]+[user_lookups])*100.00)/([user_seeks]+[user_scans]+[user_lookups]+[user_updates])),0) AS ReadPct
			,COALESCE(MAX((([user_updates])*100.00)/([user_seeks]+[user_scans]+[user_lookups]+[user_updates])),0) AS WritePct
			,COALESCE(MAX(ios.leaf_allocation_count + ios.nonleaf_allocation_count),0) AS [Splits]
			,COALESCE(MAX(si.Fill_Factor),100) as OrigFillFactor
			,COALESCE(MAX(user_seeks+user_scans+user_lookups+user_updates),0) as IndexUsage
			,cast(COALESCE(MAX(user_seeks+user_scans+user_lookups+user_updates),0)/(sum(au.Total_Pages)*8)+.01  as decimal(10,2)) IndexUsagetoSizeRatio
			,(SELECT datediff(minute,login_time,getdate())/60.00 From sys.sysprocesses where spid = 1) UptimeHr
			,COALESCE(MAX(user_scans),0)/(SELECT datediff(minute,login_time,getdate())/60.00 From sys.sysprocesses where spid = 1) ScansPerHr
FROM		[?].sys.objects o with (nolock)
join		[?].sys.schemas s with (nolock)
	on		o.schema_id = s.schema_id
join		[?].sys.indexes si with (nolock)
	on		o.[object_id]=si.[object_id]
	and		si.type <> 0 -- no heaps
join		[?].sys.partitions par (nolock) 
	on		si.[object_id]= par.[object_id]
	and		si.index_id=par.index_id
join		[?].sys.allocation_units au (nolock) 
	on		par.partition_id=au.container_id
join		[?].sys.data_spaces ds with (nolock) 
	on		si.data_space_id = ds.data_space_id
left join	[?].sys.dm_db_index_usage_stats us
	on		us.database_id = db_id(''?'')
	and		us.object_id = si.object_id
	and		us.index_id = si.index_id
LEFT JOIN	[?].sys.dm_db_index_operational_stats(DB_ID(''?''),NULL,NULL,NULL)ios
	ON		us.[database_id]	=ios.[database_id]
	AND		us.[object_id]		=ios.[object_id]
	AND		us.[index_id]		=ios.[index_id]	
WHERE		o.type_desc in (N''USER_TABLE'',N''VIEW'')
GROUP BY	s.name
			, o.name
			, o.object_id
			, si.index_id
			, si.name
HAVING		sum(au.Total_Pages) > '+ cast(@minPages as nvarchar(10)) +'
ORDER BY	s.name, o.name','?',@databaseName)

	
	--------------------------------------------
	-- LOG MESSAGE
	--------------------------------------------
	SET @lMsg = 'Getting indexes with more than '  + cast(@minPages as nvarchar(10)) + N' pages.'
	--------------------------------------------
	EXEC [dbasp_LogMsg]
		@ModuleName=@cEModule
		,@MessageKeyword=@cEMessage
		,@TypeKeyword='EVT_INFO'
		,@ProcessGUID=@ProcessGUID
		,@AdHocMsg = @lMsg 
		,@Diagnose=@Diagnose
		,@ScriptMode=@ScriptMode
	--------------------------------------------
	--------------------------------------------

	INSERT @reindex (schemaName, tableName, tableObjectId, indexId, indexName, totalPages, indexSizeMb, user_seeks, user_scans, user_lookups, user_updates, ReadPct, WritePct, Splits, OrigFillFactor, IndexUsage, IndexUsagetoSizeRatio, UptimeHr, ScansPerHr)
	EXEC sp_executesql @getReindexItems;

	SELECT @getReindexItems = REPLACE(
N'SELECT		''?'' DatabaseName
			, tableName = o.name
			, indexName = CASE si.type
					WHEN 0 THEN ''Table is a Heap''
					ELSE si.name
					END
			, Reason = CASE si.type
					WHEN 0 THEN ''NoClstIndx: Table has No Clustered Indexes''
					ELSE ''IndxTooSml: Index has '' + cast(sum(au.Total_Pages) as nvarchar(10)) + '' Pages which is less than the limit of '  + cast(@minPages as nvarchar(10)) + ' pages''
					END
FROM		[?].sys.objects o with (nolock)
join		[?].sys.indexes si with (nolock)
	on		o.[object_id]=si.[object_id]
join		[?].sys.partitions par (nolock) 
	on		si.[object_id]= par.[object_id]
	and		si.index_id=par.index_id
join		[?].sys.allocation_units au (nolock) 
	on		par.partition_id=au.container_id
WHERE		o.type_desc in (N''USER_TABLE'',N''VIEW'')
GROUP BY	o.name
		,si.name
		,si.type
HAVING		sum(au.Total_Pages) <= '+ cast(@minPages as nvarchar(10)) +' OR si.type = 0
ORDER BY	o.name, si.name','?',@databaseName)

	INSERT @ExcludedIndexes (DatabaseName, TableName, IndexName, Reason)
	EXEC sp_executesql @getReindexItems;
	

	IF @exceptionXML is not null
	BEGIN -- parse exclusions block
	
		--------------------------------------------
		-- LOG MESSAGE
		--------------------------------------------
		SELECT @lMsg = 'Parsing exclusion list'
		--------------------------------------------
		exec [dbasp_LogMsg]
			@ModuleName=@cEModule
			,@MessageKeyword=@cEMessage
			,@TypeKeyword='EVT_INFO'
			,@ProcessGUID=@ProcessGUID
			,@AdHocMsg = @lMsg 
			,@Diagnose=@Diagnose
			,@ScriptMode=@ScriptMode
		--------------------------------------------
		--------------------------------------------

		INSERT @exclusionTable (schemaName, tableName, indexName,ScansPerHr )	
		SELECT DISTINCT 
			schemaName=coalesce(x.SchemaName,'%')
			,tableName=coalesce(x.TableName,'%')
			,indexName=coalesce(x.IndexName,'%')
			,ScansPerHr=coalesce(x.ScansPerHr,0.0)
		FROM
		(	
			SELECT DISTINCT
				SchemaName = e.i.value('@SchemaName','sysname') 
				,TableName = e.i.value('@TableName','sysname') 
				,IndexName = e.i.value('@IndexName','sysname') 
				,ScansPerHr = e.i.value('@ScansPerHr','decimal(10,2)')
			FROM @exceptionXML.nodes('EXCEPTION/Exclude') e(i)
			WHERE (	e.i.value('@DatabaseName','sysname')=@databaseName or e.i.value('@DatabaseName','sysname') is null )
				and (
					e.i.value('@SchemaName','sysname') is not null	
					or e.i.value('@TableName','sysname') is not null
					or e.i.value('@IndexName','sysname') is not null
					or e.i.value('@ScansPerHr','decimal(10,2)') is not null
				)
			) x
		SELECT @maxExclusionId=@@ROWCOUNT, @exclusionId = 1;



		IF @maxExclusionId >0 --process exclusions. This could easily be done without a loop, but this makes the logging very clear.
			WHILE @exclusionId <= @maxExclusionId
			BEGIN -- process exclusions block
				SELECT @exclusionItem = '['+ schemaName + '].[' + tableName + '].[' + indexName + '] SPH <= ' + CAST(ScansPerHr AS VarChar(50))
				from @exclusionTable 
				where exclusionId = @exclusionId;

		
				INSERT INTO	@ExcludedIndexes (DatabaseName,TableName,IndexName,Reason)
				SELECT		@databaseName
						,r.TableName
						,r.IndexName
						,'ExclsParam: Exclusion Parameter:'
						+ CASE x.schemaName
							WHEN '%' THEN ''
							ELSE ' Schema:'+ x.schemaName
							END
						+ CASE x.tableName
							WHEN '%' THEN ''
							ELSE ' Table:'+ x.tableName
							END
						+ CASE x.indexName
							WHEN '%' THEN ''
							ELSE ' Index:'+ x.indexName
							END
						+ CASE x.ScansPerHr
							WHEN 0.0 THEN ''
							ELSE ' ScansPerHr:'+ CAST(x.ScansPerHr AS VarChar(50)) + ' CurrentValue: ' + CAST(r.ScansPerHr AS VarChar(50)) + ')'
							END																					
				FROM @reindex r
				JOIN @exclusionTable x on 
					(r.SchemaName like x.schemaName or x.schemaName='%')
					and (r.tableName like x.tableName  or x.tableName = '%')
					and (r.indexName like x.indexName or x.indexName ='%')
					and (r.ScansPerHr <= x.ScansPerHr or x.ScansPerHr =0.0)
				WHERE x.exclusionId =@exclusionId
				
				DELETE @reindex
				FROM @reindex r
				JOIN @exclusionTable x on 
					(r.SchemaName like x.schemaName or x.schemaName='%')
					and (r.tableName like x.tableName  or x.tableName = '%')
					and (r.indexName like x.indexName or x.indexName ='%')
					and (r.ScansPerHr <= x.ScansPerHr or x.ScansPerHr =0.0)
				WHERE x.exclusionId =@exclusionId

				SELECT @rowcount = @@ROWCOUNT 


				--------------------------------------------
				-- LOG MESSAGE
				--------------------------------------------
				IF @rowcount > 0
					SELECT @lMsg= 'Exclusion: will not reindex '+ CAST(@rowcount as nvarchar(5)) + ' item(s) due to exclusion:' + @exclusionItem
						, @lEType='EVT_INFO'
				ELSE
					SELECT @lMsg = @exclusionItem + ' was requested to be excluded, but was not found in database ' + @databaseName + '.'
						, @lEType='EVT_WARN'
				--------------------------------------------
				EXEC [dbasp_LogMsg]
				@ModuleName=@cEModule
				,@MessageKeyword=@cEMessage
				,@TypeKeyword=@lEType 
				,@ProcessGUID=@ProcessGUID
				,@AdHocMsg = @lMsg 
				,@Diagnose=@Diagnose
				,@ScriptMode=@ScriptMode
				--------------------------------------------
				--------------------------------------------
			
				SELECT @exclusionId=@exclusionId+1
			END -- process exclusions block
	END -- parse exclusions block

	--DECLARE the cursor
	DECLARE TableCursor CURSOR LOCAL FAST_FORWARD FOR
		SELECT reindexId, schemaName, tableName, tableObjectId, indexId, indexName, totalPages, indexSizeMb, ReadPct, Splits, OrigFillFactor 
		from @reindex
		order by schemaName, tableName, indexId
		
	OPEN TableCursor
	FETCH NEXT FROM TableCursor INTO @reindexId, @schemaName, @tableName, @tableObjectId, @indexId, @indexName, @totalPages, @indexSizeGB, @ReadPct, @Splits, @OrigFillFactor

	WHILE (@@FETCH_STATUS = 0 and @breakNow=0)
	
	BEGIN --block for WHILE @@FETCH_STATUS = 0 and @lError=0
	BEGIN TRY -- Try block within cursor  

			SET @indexStartDate=GETDATE()
			SET @sql = null

			-- cannot use online reindexing with disabled indices or with text/image/xml/LOB data
			SELECT @checkOnlineIndexingSQL =N'
				SELECT 
				@fbdn = max(case when si.is_disabled = 1 then 1
						when t.name in (''text'',''ntext'',''image'',''xml'') then 1
						when t.name in (''char'',''nchar'',''varchar'',''nvarchar'') and c.max_length = -1 then 1
						else 0
						end)
				from	'+ @databaseName + N'.sys.indexes si with (nolock)
				join '+ @databaseName + N'.sys.columns c with (nolock)
					on si.object_id = c.object_id
				join '+ @databaseName + N'.sys.systypes t with (nolock) 
					on c.system_type_id = t.xtype
				join '+ @databaseName + N'.sys.data_spaces ds with (nolock)
					on si.data_space_id = ds.data_space_id
				where  si.object_id = ' + cast(@tableObjectId as nvarchar) + '
				and si.index_id = ' + cast(@indexId as nvarchar) + '
				group  by si.object_id
			'

			EXEC sp_executesql @stmt=@checkOnlineIndexingSQL, @params=N'@fbdn int OUTPUT', @fbdn=@onlineIndexingForbidden OUTPUT;
		
			
			--Set the object description.
			SET @objDescription = coalesce(@schemaName,'???') + N'.' + coalesce(@tableName,'???') 
					+ N' index=' + coalesce(@indexName,'???') 
					+ N' (' + coalesce(cast(@indexSizeGB as nvarchar),'?') + N'GB) '
					+ N'Online reindex ' + case @onlineIndexingForbidden when 1 then N'forbidden.' else N'OK.' end

			--------------------------------------------
			-- LOG MESSAGE
			--------------------------------------------
			SET @cEMessage='EVT_SCI'
			SET @lMsg = @databaseName + N': Starting check for ' 
					+ @objDescription 
			--------------------------------------------
			--Log start of index scan to EVT
			EXEC [dbasp_LogMsg]
				@ModuleName=@cEModule
				,@MessageKeyword=@cEMessage
				,@TypeKeyword='EVT_START'
				,@ProcessGUID=@ProcessGUID
				,@AdHocMsg = @lMsg 
				,@Diagnose=@Diagnose
				,@ScriptMode=@ScriptMode
			--------------------------------------------
			--------------------------------------------
		
			-- Set up the query to get the stats. Dynamic sql is required since we're pulling from a different database.
			SELECT @getPhysicalStatsSQL= N'
				SELECT 
					insert_date=''' + convert(nvarchar, @indexStartDate, 126) + '''
					, scan_started = ''' + convert(nvarchar, @runStarted, 126) + '''
					, ps.database_id
					, ps.[object_id]
					, ''' + @schemaName + N'.' + @tableName + N'''
					, ps.index_id
					, ps.partition_number
					, ps.index_depth
					, ps.index_level
					, ps.avg_fragmentation_in_percent
					, ps.page_count
					, ps.avg_page_space_used_in_percent
					, ps.record_count
					, ps.min_record_size_in_bytes
					, ps.max_record_size_in_bytes
					, ps.avg_record_size_in_bytes
					, us.user_seeks
					, us.user_scans
					, us.user_lookups
					, us.user_updates
					, us.system_seeks
					, us.system_scans
					, us.system_lookups
					, us.system_updates
					, ios.leaf_allocation_count
					+ ios.nonleaf_allocation_count AS [Splits]
				from	[' + @databaseName + '].[sys].[dm_db_index_physical_stats](' 
					+ cast(@databaseId as nvarchar)  
					+ ',' + convert(nvarchar, @tableObjectId, 126) 
					+ ',' + convert(nvarchar, @indexId, 126) 
					+ ',null' 
					+ ',''' + case @maxIndexLevelToConsider when 0 then 'LIMITED' else 'DETAILED' END 
					+ ''') ps
				join	[' + @databaseName + '].[sys].[dm_db_index_usage_stats] us
					on ps.database_id = us.database_id
					AND ps.[object_id] = us.[object_id]
					AND ps.index_id = us.index_id
				join	[' + @databaseName + '].[sys].[dm_db_index_operational_stats]('
					+ cast(@databaseId as nvarchar)  
					+ ',' + convert(nvarchar, @tableObjectId, 126) 
					+ ',' + convert(nvarchar, @indexId, 126) 
					+ ',NULL'
					+ ') ios
					on ps.[database_id] = ios.[database_id]
					AND ps.[object_id] = ios.[object_id]
					AND ps.[index_id] = ios.[index_id]
				WHERE ps.index_type_desc <> ''HEAP''
			'
			-- Pull the stats for this index
			INSERT dbaadmin.dbo.IndexMaintenancePhysicalStats 
				(insert_date, scan_started, database_id, [object_id], tablename, index_id, partition_number, index_depth
				, index_level, avg_fragmentation_in_percent, page_count, avg_page_space_used_in_percent, record_count
				, min_record_size_in_bytes, max_record_size_in_bytes, avg_record_size_in_bytes
				,[user_seeks],[user_scans],[user_lookups],[user_updates],[system_seeks],[system_scans],[system_lookups],[system_updates],[Splits])
			EXEC sp_executesql @getPhysicalStatsSQL;

			SET @imPhysicalStatsId = SCOPE_IDENTITY()

			SELECT @maxFragPercent = max(avg_fragmentation_in_percent)
			FROM dbaadmin.dbo.IndexMaintenancePhysicalStats 
			WHERE insert_date=@indexStartDate 
			and [object_id]=@tableObjectId
			and index_id = @indexId
			and index_level <= @maxIndexLevelToConsider -- typically only look at leaf level and one level up.  most indexes won't be deeper than 4 levels
			and page_count > @minPages

			-- Figure out the operation. The rules:
			--For partitioned indexes, you cannot rebuild an individual partition online in SQL 2005/2008. 
			--You can rebuild an entire index which is partitioned online, however.
			--This script only supports rebuilding an entire index.

			-----------------------------------------------------------
			-----------------------------------------------------------
			-- LOGIC TO SELECT BETWEEN REORG OR REBUILD
			-----------------------------------------------------------
			-----------------------------------------------------------
			SELECT	@operation = CASE 
						WHEN	@maxFragPercent is null			-- no qualifying indexes (e.g., < @minPages pages on every index_level)
						or	@maxFragPercent < @fragThreshold	--Isn't fragmented
						THEN	N'No maintenance' 

						WHEN	@mode = 2				-- always reorganize if we're in reorganize only mode
						or						-- if mode = 0 or 3 and you can't do an online rebuild
						(						-- , reorganize
							@mode				IN (0,3)
							and @onlineIndexingForbidden	= 1 
							and @usesOnlineReindex		= 1
						)
						or						-- if mode=3 and framentation is under the rebuild threshold.
						(
							@mode				= 3
							and @maxFragPercent		< @RebuildThreshold
						) 
						THEN N'REORGANIZE'
						
						ELSE N'REBUILD'
						END	

				
			IF @operation in ('REORGANIZE','REBUILD') --Always bracket the names (esp. for net conversions)
				SET @sql = N'USE [' + @databaseName + N']; ALTER INDEX [' + @indexName + N'] ON ['+@schemaName + N'].['+ @tableName+ N'] '
						-- REBUILD OR REORG
						+ @operation

						-- Set options
						+ case @operation
							when 'REORGANIZE' then N''
							when 'REBUILD' then 
								N' WITH (FILLFACTOR = ' + CASE
												WHEN @ReadPct > 60 THEN cast(@fillFactor_HighRead as nvarchar)
												WHEN @ReadPct < 30 THEN cast(@fillFactor_LowRead as nvarchar)
												ELSE cast(@fillFactor as nvarchar)
												END
								+ N', PAD_INDEX = ON'
								+ N', SORT_IN_TEMPDB = ' + case @sortInTempDb when 1 then N'ON' else N'OFF' end
								+ N', STATISTICS_NORECOMPUTE = OFF'
								+ N', ONLINE = '
									+ case when @usesOnlineReindex = 1 and isnull(@onlineIndexingForbidden,0) <> 1 
										then N'ON'
										else N'OFF'
									end + N');'
							else null -- the no maint operation should do nothing but log
							end
			
			If @OrigFillFactor != CASE
						WHEN @ReadPct > 60 THEN @fillFactor_HighRead
						WHEN @ReadPct < 30 THEN @fillFactor_LowRead
						ELSE @fillFactor
						END
			AND @operation = 'REBUILD'
			BEGIN
				--------------------------------------------
				-- LOG MESSAGE
				--------------------------------------------
				SELECT @lMsg= N'IdxFilFact: Index Fill Factor changing From '
					+ CAST(@OrigFillFactor AS nVarChar) +' to '
					+ CASE
						WHEN @ReadPct > 60 THEN cast(@fillFactor_HighRead as nvarchar)
						WHEN @ReadPct < 30 THEN cast(@fillFactor_LowRead as nvarchar)
						ELSE cast(@fillFactor as nvarchar)
						END 
				--------------------------------------------
				EXEC [dbasp_LogMsg]
					@ModuleName=@cEModule
					,@MessageKeyword=@cEMessage
					,@TypeKeyword='EVT_INFO'
					,@ProcessGUID=@ProcessGUID
					,@AdHocMsg = @lMsg 
					,@Diagnose=@Diagnose
					,@ScriptMode=@ScriptMode
				--------------------------------------------
				--------------------------------------------
			END
			--Log completion of index scan to EVT
			--------------------------------------------
			-- LOG MESSAGE
			--------------------------------------------
			SELECT @lMsg= CASE @operation
					WHEN 'No maintenance' THEN 'IdxNotFrag: '
					ELSE ''
					END
				+ N'DMV says ' 
				+ CASE WHEN @maxFragPercent is not null then 
						N'Frag=' + cast(coalesce(@maxFragPercent,0) as nvarchar) + N'% ' 
					else N'All frag beneath threshold of ' + cast(@fragThreshold as nvarchar) + N'%. '  
					end
				+ @operation + N': ' 
				+ @objDescription 
			--------------------------------------------
			EXEC [dbasp_LogMsg]
				@ModuleName=@cEModule
				,@MessageKeyword=@cEMessage
				,@TypeKeyword='EVT_SUCCESS'
				,@ProcessGUID=@ProcessGUID
				,@AdHocMsg = @lMsg 
				,@Diagnose=@Diagnose
				,@ScriptMode=@ScriptMode
			--------------------------------------------
			--------------------------------------------
			
			IF @operation = 'No maintenance'
			BEGIN
				INSERT INTO @SkipedIndexes	(DatabaseName,TableName,IndexName,Reason)
				VALUES				(@DatabaseName,@TableName,@IndexName,@lMsg)
				
				--SET @OutputScript = @OutputScript 
				--+ '--------------------------------------------'+CHAR(13)+CHAR(10)
				--+ '--------------------------------------------'+CHAR(13)+CHAR(10)
				--+ '-- ' + QuoteName(@DatabaseName)+'.'+QUOTENAME(@TableName)+'.'+QUOTENAME(@IndexName)+' '+@lMsg+CHAR(13)+CHAR(10)
				--+ '--------------------------------------------'+CHAR(13)+CHAR(10)
				--+ '--------------------------------------------'+CHAR(13)+CHAR(10)
			END

			IF (coalesce(@onlineIndexingForbidden,0) = 1 and @usesOnlineReindex = 1 )
			BEGIN -- Block to log warning if object can't be rebuilt online
				--------------------------------------------
				-- LOG MESSAGE
				--------------------------------------------
				IF @mode=1
					SELECT @lMsg= N'FBtoOffLin: Rebuild Online only SELECTed, but this index cannot be rebuilt online. Offline rebuild will be used for: ' 
						+ @objDescription 
						+ N' Use @mode=0 to REORG objects that cannot be rebuilt online and REBUILD all others.'
						, @lEType= 'EVT_WARN';
				ELSE IF @mode in (0,3)
					SELECT @lMsg= N'FBtoReOrg: This index cannot be rebuilt online. @mode=0 or 3 so REORG will be used for: ' 
						+ @objDescription 
						, @lEType= 'EVT_INFO';
				--------------------------------------------
				EXEC [dbasp_LogMsg]
					@ModuleName=@cEModule
					,@MessageKeyword=@cEMessage
					,@TypeKeyword=@lEType
					,@ProcessGUID=@ProcessGUID
					,@AdHocMsg = @lMsg 
					,@Diagnose=@Diagnose
					,@ScriptMode=@ScriptMode
				--------------------------------------------
				SET @OutputScript = @OutputScript 
				+ '--------------------------------------------'+CHAR(13)+CHAR(10)
				+ '--------------------------------------------'+CHAR(13)+CHAR(10)
				+ '-- ' + QuoteName(@DatabaseName)+'.'+QUOTENAME(@TableName)+'.'+QUOTENAME(@IndexName)+CHAR(13)+CHAR(10)
				+ '-- ' +@lMsg+CHAR(13)+CHAR(10)
				+ '--------------------------------------------'+CHAR(13)+CHAR(10)
				+ '--------------------------------------------'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
				--------------------------------------------
				IF @operation = 'REBUILD'
				BEGIN
					INSERT INTO @RebuiltIndexes	(DatabaseName,TableName,IndexName,Reason)
					VALUES				(@DatabaseName,@TableName,@IndexName,@lMsg)
				END					
			END -- Block to log warning if object can't be rebuilt online
			ELSE
			BEGIN
				SET @lMsg	= 'Mode: ' + CAST(@mode as VarChar(1)) + ' Frag: ' + cast(coalesce(@maxFragPercent,0) as nvarchar)
				IF @operation	= 'REBUILD'
				BEGIN
					SET	@lMsg = 'IdxRebuild: ' + @lMsg
					INSERT INTO @RebuiltIndexes	(DatabaseName,TableName,IndexName,Reason)
					VALUES				(@DatabaseName,@TableName,@IndexName,@lMsg)
				END	
				IF @operation	= 'REORGANIZE'
				BEGIN
					SET	@lMsg = 'IdxReorgnz: ' + @lMsg
					INSERT INTO @ReorgedIndexes	(DatabaseName,TableName,IndexName,Reason)
					VALUES				(@DatabaseName,@TableName,@IndexName,@lMsg)
				END	
			END
			
			SET @lMsg	= @databaseName + N': ' + coalesce(@sql,@operation)
			SET @cEMessage	='EVT_RDX'

			
			IF @operation in ('REORGANIZE','REBUILD') and @sql is null 
			BEGIN
				-- we have hit an error if we don't have @sql populated at this point!
				SELECT @lMsg = @databaseName + N': Reindex job error. @sql variable set to null when it should not be!'
				RAISERROR(@lMsg,16,1) -- if we are in error, go to the catch block	
			END
				
			IF @operation in ('REORGANIZE','REBUILD')
				IF @ScriptMode=0
				BEGIN --Block for index rebuild
					--------------------------------------------
					-- LOG MESSAGE
					--------------------------------------------
					EXEC [dbasp_LogMsg]
						@ModuleName=@cEModule
						,@MessageKeyword=@cEMessage
						,@TypeKeyword='EVT_START'
						,@ProcessGUID=@ProcessGUID
						,@AdHocMsg = @lMsg 
						,@Diagnose=@Diagnose
						,@ScriptMode=@ScriptMode
					--------------------------------------------
					UPDATE	dbaadmin.dbo.IndexMaintenancePhysicalStats
					SET	ActionTaken		= @sql
						,ActionStarted		= GetDate()
					WHERE	imPhysicalStatsId	= @imPhysicalStatsId
					--------------------------------------------

					SELECT @SQL
					--The action happens here.
					EXEC sp_executesql @sql

					--------------------------------------------
					-- LOG MESSAGE
					--------------------------------------------
					EXEC [dbasp_LogMsg]
						@ModuleName=@cEModule
						,@MessageKeyword=@cEMessage
						,@TypeKeyword='EVT_SUCCESS'
						,@ProcessGUID=@ProcessGUID
						,@AdHocMsg = @lMsg 
						,@Diagnose=@Diagnose
						,@ScriptMode=@ScriptMode
					--------------------------------------------
					UPDATE	dbaadmin.dbo.IndexMaintenancePhysicalStats
					SET	ActionCompleted		= GetDate()
					WHERE	imPhysicalStatsId	= @imPhysicalStatsId
					--------------------------------------------

				END --Block for index rebuild
				ELSE --  When @ScriptMode!=0 Generate Script for File and/or Screen.
				BEGIN
					--------------------------------------------
					-- LOG MESSAGE
					--------------------------------------------
					Set @lMsg = 'ScriptMode, Adding Entry For :' + @sql;
					--------------------------------------------
					EXEC [dbasp_LogMsg]
						@ModuleName=@cEModule
						,@MessageKeyword=@cEMessage
						,@TypeKeyword='EVT_INFO'
						,@ProcessGUID=@ProcessGUID
						,@AdHocMsg = @lMsg 
						,@Diagnose=@Diagnose
						,@ScriptMode=@ScriptMode				
					--------------------------------------------
					--------------------------------------------
					-- ADD HEADER FOR INDEX
					--------------------------------------------
					--------------------------------------------
					SET	@OutputScript = @OutputScript
					+ '--------------------------------------------'+CHAR(13)+CHAR(10)
					+ '--------------------------------------------'+CHAR(13)+CHAR(10)
					+ '-- ' + QuoteName(@DatabaseName)+'.'+QUOTENAME(@TableName)+'.'+QUOTENAME(@IndexName)+CHAR(13)+CHAR(10)
					+ '-- ' +@operation+CHAR(13)+CHAR(10)
					+ '--------------------------------------------'+CHAR(13)+CHAR(10)
					+ '--------------------------------------------'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
					--------------------------------------------
					--------------------------------------------
					-- GENERATE SCRIPT BLOCK
					--------------------------------------------
					--------------------------------------------
					+ COALESCE
						(
						'BEGIN	-- INDEX OPERATION'								+ CHAR(13)+CHAR(10)
						+'	SELECT	@cEMessage		= ''EVT_RDX'''					+ CHAR(13)+CHAR(10)
						+'		,@lMsg			= '''+@sql+''''					+ CHAR(13)+CHAR(10)
						+'		,@imPhysicalStatsId	= '+CAST(@imPhysicalStatsId AS VarChar(50))	+ CHAR(13)+CHAR(10)
						+'	--------------------------------------------'					+ CHAR(13)+CHAR(10)
						+'	-- LOG MESSAGE'									+ CHAR(13)+CHAR(10)
						+'	--------------------------------------------'					+ CHAR(13)+CHAR(10)
						+'	EXEC [dbasp_LogMsg]'								+ CHAR(13)+CHAR(10)
						+'		@ModuleName=@cEModule'							+ CHAR(13)+CHAR(10)
						+'		,@MessageKeyword=@cEMessage'						+ CHAR(13)+CHAR(10)
						+'		,@TypeKeyword=''EVT_START'''						+ CHAR(13)+CHAR(10)
						+'		,@ProcessGUID=@ProcessGUID'						+ CHAR(13)+CHAR(10)
						+'		,@AdHocMsg = @lMsg '							+ CHAR(13)+CHAR(10)
						+'		,@Diagnose=@Diagnose'							+ CHAR(13)+CHAR(10)
						+'		,@ScriptMode=@ScriptMode'						+ CHAR(13)+CHAR(10)
						+'	--------------------------------------------'					+ CHAR(13)+CHAR(10)
						+'	UPDATE	dbaadmin.dbo.IndexMaintenancePhysicalStats'				+ CHAR(13)+CHAR(10)
						+'	SET	ActionTaken		= '''+@sql+''''					+ CHAR(13)+CHAR(10)
						+'		,ActionStarted		= GetDate()'					+ CHAR(13)+CHAR(10)
						+'	WHERE	imPhysicalStatsId	= @imPhysicalStatsId'				+ CHAR(13)+CHAR(10)
						+'	--------------------------------------------'					+ CHAR(13)+CHAR(10) 
						+'	'										+ CHAR(13)+CHAR(10)
						+ REPLACE(
							REPLACE(
								REPLACE(
									@sql
									,'REORGINIZE'
									,CHAR(13)+CHAR(10)+'	REORGINIZE')
								,'REBUILD'
								,CHAR(13)+CHAR(10)+'	REBUILD')
							,'ALTER INDEX'
							,CHAR(13)+CHAR(10)
							+'	PRINT ''	'+ QuoteName(@DatabaseName)+'.'+QUOTENAME(@TableName)+'.'+QUOTENAME(@IndexName)+''''+ CHAR(13)+CHAR(10)
							+'	SELECT @ScreenMsg = ''	Frag Before:	'' + CAST(max(avg_fragmentation_in_percent) AS VarChar(10)) +CHAR(13) + CHAR(10) +''	Index Type:	'' + max(index_type_desc) +CHAR(13) + CHAR(10) +''	Index Size:	'' + CAST(max(page_count) as VarChar(10)) + '' Pages'' FROM sys.dm_db_index_physical_stats'+ CHAR(13)+CHAR(10)
							+'		( '+CAST(DB_ID(@DatabaseName) AS VarChar(25))+ CHAR(13)+CHAR(10)
							+'		, '+CAST(@tableObjectId AS VarChar(25))+ CHAR(13)+CHAR(10)
							+'		, '+CAST(@indexId AS VarChar(25))+ CHAR(13)+CHAR(10)
							+'		, NULL'+ CHAR(13)+CHAR(10)
							+'		, ''DETAILED'''+ CHAR(13)+CHAR(10)
							+'		) ps'+ CHAR(13)+CHAR(10)
							+'	PRINT @ScreenMsg'+ CHAR(13)+CHAR(10)
							+'	PRINT ''	'+ @operation +'ing...'''				+ CHAR(13)+CHAR(10)	 
							+'	ALTER INDEX'
							)										+ CHAR(13)+CHAR(10) 
						+'	PRINT ''	DONE'''								+ CHAR(13)+CHAR(10)
						+'	SELECT @ScreenMsg = ''	Frag After:'
						+'	'' + CAST(max(avg_fragmentation_in_percent) AS VarChar(10))'
						+'	FROM sys.dm_db_index_physical_stats'						+ CHAR(13)+CHAR(10)
						+'		( '+CAST(DB_ID(@DatabaseName) AS VarChar(25))				+ CHAR(13)+CHAR(10)
						+'		, '+CAST(@tableObjectId AS VarChar(25))					+ CHAR(13)+CHAR(10)
						+'		, '+CAST(@indexId AS VarChar(25))					+ CHAR(13)+CHAR(10)
						+'		, NULL'									+ CHAR(13)+CHAR(10)
						+'		, ''DETAILED'''									+ CHAR(13)+CHAR(10)
						+'		) ps'									+ CHAR(13)+CHAR(10)
						+'	PRINT @ScreenMsg'								+ CHAR(13)+CHAR(10)
						+'	USE DBAADMIN;'									+ CHAR(13)+CHAR(10)
						+'	--------------------------------------------'					+ CHAR(13)+CHAR(10)
						+'	-- LOG MESSAGE'									+ CHAR(13)+CHAR(10)
						+'	--------------------------------------------'					+ CHAR(13)+CHAR(10)
						+'	EXEC [dbasp_LogMsg]'								+ CHAR(13)+CHAR(10)
						+'		@ModuleName=@cEModule'							+ CHAR(13)+CHAR(10)
						+'		,@MessageKeyword=@cEMessage'						+ CHAR(13)+CHAR(10)
						+'		,@TypeKeyword=''EVT_SUCCESS'''						+ CHAR(13)+CHAR(10)
						+'		,@ProcessGUID=@ProcessGUID'						+ CHAR(13)+CHAR(10)
						+'		,@AdHocMsg = @lMsg'							+ CHAR(13)+CHAR(10) 
						+'		,@Diagnose=@Diagnose'							+ CHAR(13)+CHAR(10)
						+'		,@ScriptMode=@ScriptMode'						+ CHAR(13)+CHAR(10)
						+'	--------------------------------------------'					+ CHAR(13)+CHAR(10)
						+'	UPDATE	dbaadmin.dbo.IndexMaintenancePhysicalStats'				+ CHAR(13)+CHAR(10)
						+'	SET	ActionCompleted		= GetDate()'					+ CHAR(13)+CHAR(10)
						+'	WHERE	imPhysicalStatsId	= @imPhysicalStatsId'				+ CHAR(13)+CHAR(10)	
						+'	--------------------------------------------'					+ CHAR(13)+CHAR(10)
						+'END'
																	+ CHAR(13)+CHAR(10)
						,'-- NULL VALUE ERROR GENERATING SCRIPT BLOCK --'					+ CHAR(13)+CHAR(10)
						)											+ CHAR(13)+CHAR(10)
				END
				
	END TRY -- Try block within cursor 
	BEGIN CATCH -- Catch from Try block within cursor 

		--------------------------------------------
		-- LOG MESSAGE
		--------------------------------------------
		SELECT @lMsg = N'try/catch: Reindex job failed against [' 
				+ @databaseName + N'].[' + @tableName + '].[' + @indexName + N']! The error message given was: ' + ERROR_MESSAGE() 
				+ N'. The error severity originally raised was: ' + cast(ERROR_SEVERITY() as nvarchar) + N'.'
		--------------------------------------------
		exec [dbasp_LogMsg]
			@ModuleName=@cEModule
			,@MessageKeyword=@cEMessage
			,@TypeKeyword='EVT_FAIL'
			,@AdHocMsg=@lMsg
			,@ProcessGUID=@ProcessGUID
			,@LogPublisherMessage=0
			,@Diagnose=@Diagnose
			,@ScriptMode=@ScriptMode
			,@SuppressRaiseError=1 -- Don't raise error here, it wouldn't gracefully close the cursor. 
		--------------------------------------------
		SET @lError=1 -- Flag an error now. In a few lines we'll determine if we should continue.

	END CATCH -- Catch from Try block within cursor 

	FETCH NEXT FROM TableCursor INTO @reindexId, @schemaName, @tableName, @tableObjectId, @indexId, @indexName, @totalPages, @indexSizeGB, @ReadPct, @Splits, @OrigFillFactor

	--Evaluate if we should continue on the next loop...
	IF @continueOnError = 0 and @lError=1
		SET @breakNow = 1;

	END --Block for WHILE @@FETCH_STATUS = 0 and @lError=0

	CLOSE TableCursor
	DEALLOCATE TableCursor

	-- Clean up rows in dbaadmin.dbo.IndexMaintenancePhysicalStats  which are older than 1 week
	DELETE
	FROM dbaadmin.dbo.IndexMaintenancePhysicalStats 
	WHERE scan_started < getdate()-7

	BEGIN -- LOG IndexMaintenanceLastRunDetails
		--------------------------------------------
		-- LOG MESSAGE START
		--------------------------------------------
		SELECT @lMsg = N'CLEAR IndexMaintenanceLastRunDetails for ' + @DatabaseName
		--------------------------------------------
		exec [dbasp_LogMsg]
			@ModuleName=@cEModule
			,@MessageKeyword=@cEMessage
			,@TypeKeyword='EVT_START'
			,@AdHocMsg=@lMsg
			,@ProcessGUID=@ProcessGUID
			,@LogPublisherMessage=0
			,@Diagnose=@Diagnose
			,@ScriptMode=@ScriptMode
			,@SuppressRaiseError=1;
		--------------------------------------------
		--------------------------------------------

		-- REMOVE ALL ENTRIES FOR THIS DATABASE
		DELETE		dbaadmin.dbo.IndexMaintenanceLastRunDetails
		WHERE		DatabaseName = @DatabaseName

		--------------------------------------------
		-- LOG MESSAGE SUCCESS
		--------------------------------------------
		--------------------------------------------
		exec [dbasp_LogMsg]
			@ModuleName=@cEModule
			,@MessageKeyword=@cEMessage
			,@TypeKeyword='EVT_SUCCESS'
			,@AdHocMsg=@lMsg
			,@ProcessGUID=@ProcessGUID
			,@LogPublisherMessage=0
			,@Diagnose=@Diagnose
			,@ScriptMode=@ScriptMode
			,@SuppressRaiseError=1;
		--------------------------------------------
		--------------------------------------------

		--------------------------------------------	
		--------------------------------------------
		-- LOG MESSAGE START
		--------------------------------------------
		SELECT @lMsg = N'Log to IndexMaintenanceLastRunDetails'
		--------------------------------------------
		exec [dbasp_LogMsg]
			@ModuleName=@cEModule
			,@MessageKeyword=@cEMessage
			,@TypeKeyword='EVT_START'
			,@AdHocMsg=@lMsg
			,@ProcessGUID=@ProcessGUID
			,@LogPublisherMessage=0
			,@Diagnose=@Diagnose
			,@ScriptMode=@ScriptMode
			,@SuppressRaiseError=1;
		--------------------------------------------
		--------------------------------------------
		
		-- ADD ENTRIES FROM THIS RUN
		INSERT INTO	dbaadmin.dbo.IndexMaintenanceLastRunDetails
		SELECT		DatabaseName
				,TableName
				,IndexName
				,'Excluded' Process
				,Reason
		FROM		@ExcludedIndexes		
		UNION
		SELECT		DatabaseName
				,TableName
				,IndexName
				,'Skiped' Process
				,Reason
		FROM		@SkipedIndexes
		UNION
		SELECT		DatabaseName
				,TableName
				,IndexName
				,'Reorgonize' Process
				,Reason
		FROM		@ReorgedIndexes
		UNION
		SELECT		DatabaseName
				,TableName
				,IndexName
				,'Rebuild' Process
				,Reason
		FROM		@RebuiltIndexes
		ORDER BY	1,2,3
		
		--------------------------------------------
		-- LOG MESSAGE SUCCESS
		--------------------------------------------
		--------------------------------------------
		exec [dbasp_LogMsg]
			@ModuleName=@cEModule
			,@MessageKeyword=@cEMessage
			,@TypeKeyword='EVT_SUCCESS'
			,@AdHocMsg=@lMsg
			,@ProcessGUID=@ProcessGUID
			,@LogPublisherMessage=0
			,@Diagnose=@Diagnose
			,@ScriptMode=@ScriptMode
			,@SuppressRaiseError=1;
		--------------------------------------------
		--------------------------------------------		
	END
	
	--------------------------------------------
	-- WRITE SCRIPT TO FILE
	--------------------------------------------
	If @ScriptMode IN (1,3)
	BEGIN
		--------------------------------------------
		-- LOG MESSAGE START
		--------------------------------------------
		SELECT @lMsg = N'Write Script to File ' + @Path + '\' + @Filename
		--------------------------------------------
		exec [dbasp_LogMsg]
			@ModuleName=@cEModule
			,@MessageKeyword=@cEMessage
			,@TypeKeyword='EVT_START'
			,@AdHocMsg=@lMsg
			,@ProcessGUID=@ProcessGUID
			,@LogPublisherMessage=0
			,@Diagnose=@Diagnose
			,@ScriptMode=@ScriptMode
			,@SuppressRaiseError=1;
		--------------------------------------------
		--------------------------------------------
		
		EXEC dbaadmin.[dbo].[dbasp_FileAccess_Write]
			@String		= @OutputScript
			,@Path		= @Path
			,@Filename	= @Filename
			
		--------------------------------------------
		-- LOG MESSAGE SUCCESS
		--------------------------------------------
		--------------------------------------------
		exec [dbasp_LogMsg]
			@ModuleName=@cEModule
			,@MessageKeyword=@cEMessage
			,@TypeKeyword='EVT_SUCCESS'
			,@AdHocMsg=@lMsg
			,@ProcessGUID=@ProcessGUID
			,@LogPublisherMessage=0
			,@Diagnose=@Diagnose
			,@ScriptMode=@ScriptMode
			,@SuppressRaiseError=1;
		--------------------------------------------
		--------------------------------------------		
	END
	
	
	
	BEGIN	-- PRINT SUMMARY

		DECLARE	@SummaryVCHR	VarChar(max)
		DECLARE	@SummaryINT	INT
		
		SET	@SummaryVCHR = ''
		SELECT	@SummaryVCHR = @SummaryVCHR
			+ '--	' 
			+ CAST('Excluded' AS CHAR(15))
			+ LEFT(Reason,11)
			+ CAST(count(*) AS CHAR(10))
			+ CHAR(13) + CHAR(10)
		FROM	@ExcludedIndexes
		GROUP BY LEFT(Reason,11)
		
		SELECT	@SummaryVCHR = @SummaryVCHR
			+ '--	' 
			+ CAST('Skiped' AS CHAR(15))
			+ LEFT(Reason,11)
			+ CAST(count(*) AS CHAR(10))
			+ CHAR(13) + CHAR(10)
		FROM	@SkipedIndexes
		GROUP BY LEFT(Reason,11)

		SELECT	@SummaryVCHR = @SummaryVCHR
			+ '--	' 
			+ CAST('Reorgonized' AS CHAR(15))
			+ LEFT(Reason,11)
			+ CAST(count(*) AS CHAR(10))
			+ CHAR(13) + CHAR(10)
		FROM	@ReorgedIndexes
		GROUP BY LEFT(Reason,11)				
		
		SELECT	@SummaryVCHR = @SummaryVCHR
			+ '--	' 
			+ CAST('Rebuilt' AS CHAR(15))
			+ LEFT(Reason,11)
			+ CAST(count(*) AS CHAR(10))
			+ CHAR(13) + CHAR(10)
		FROM	@RebuiltIndexes
		GROUP BY LEFT(Reason,11)		
		
		PRINT	'-------------------------------------------------------------'
		PRINT	'-------------------------------------------------------------'
		PRINT	'--			MAINTENANCE SUMMARY'
		PRINT	'-------------------------------------------------------------'
		PRINT	'--	'
		PRINT	@SummaryVCHR
		PRINT	'--	'
		PRINT	'-------------------------------------------------------------'
		PRINT	'-------------------------------------------------------------'
	END

END TRY -- Outer Try block
BEGIN CATCH -- Catch from outer Try block

	--------------------------------------------
	-- LOG MESSAGE
	--------------------------------------------
	SELECT @lMsg = N'try/catch: Reindex job failed against database [' 
			+ @databaseName + N']! The error message given was: ' + ERROR_MESSAGE() 
			+ N'. The error severity originally raised was: ' + cast(ERROR_SEVERITY() as nvarchar) + N'.'
	--------------------------------------------
	exec [dbasp_LogMsg]
		@ModuleName=@cEModule
		,@MessageKeyword=@cEMessage
		,@TypeKeyword='EVT_FAIL'
		,@AdHocMsg=@lMsg
		,@ProcessGUID=@ProcessGUID
		,@LogPublisherMessage=0
		,@Diagnose=@Diagnose
		,@ScriptMode=@ScriptMode
		,@SuppressRaiseError=1;
	--------------------------------------------
	--------------------------------------------
	SET @lError=1 -- Flag an error. 

END CATCH -- Catch from outer Try block

--Finish up

--------------------------------------------
-- LOG MESSAGE
--------------------------------------------
IF @lError=0
BEGIN
	SET @lMsg=@databaseName + N': IndexMaintenance completed ' + CASE @ScriptMode when 1 then 'in Script mode (scan only, all reindexing to Script '+@Path+'\'+@Filename+').' END
	SET @lEType='EVT_SUCCESS'
END
ELSE
	SET @lEType='EVT_FAIL'
--------------------------------------------
EXEC [dbasp_LogMsg]
	@ModuleName		=@cEModule
	,@MessageKeyword	=@cEMessage
	,@TypeKeyword		=@lEType
	,@AdHocMsg		=@lMsg
	,@ProcessGUID		=@ProcessGUID
	,@LogPublisherMessage	=0
	,@Diagnose		=@Diagnose
	,@ScriptMode		=@ScriptMode
	,@SuppressRaiseError	=1;
--------------------------------------------
IF @lEType='EVT_FAIL' 
	RAISERROR (@lMsg,16,1)WITH LOG;
--------------------------------------------

-- OUTPUT SCRIPT TO WINDOW AFTER EVERYTHING ELSE
If @ScriptMode In (2,3)
BEGIN
	PRINT ''
	PRINT ''
	PRINT '----------------------------------------------------------------------------'
	PRINT '--	\/	\/	\/	SCRIPT START	\/	\/	\/'
	PRINT '----------------------------------------------------------------------------'
	PRINT ''
	PRINT ''
	Print SUBSTRING(@OutputScript,1,8000)
	IF LEN(@OutputScript) > 8000
		Print SUBSTRING(@OutputScript,8001,8000)
	IF LEN(@OutputScript) > 16000
		Print SUBSTRING(@OutputScript,16001,8000)
	IF LEN(@OutputScript) > 24000
		Print SUBSTRING(@OutputScript,24001,8000)
	IF LEN(@OutputScript) > 32000
		Print SUBSTRING(@OutputScript,32001,8000)
	IF LEN(@OutputScript) > 40000
		Print SUBSTRING(@OutputScript,40001,8000)
	IF LEN(@OutputScript) > 48000				-- KEEP ADDING ADDIONAL PRINT BLOCKS IF
		Print SUBSTRING(@OutputScript,48001,8000)	-- SCRIPT IS TOO LARGE.
	PRINT ''
	PRINT ''
	PRINT '----------------------------------------------------------------------------'
	PRINT '--	/\	/\	/\	SCRIPT END	/\	/\	/\'
	PRINT '----------------------------------------------------------------------------'
	PRINT ''
	PRINT ''	
END
RETURN @lError;

GO
