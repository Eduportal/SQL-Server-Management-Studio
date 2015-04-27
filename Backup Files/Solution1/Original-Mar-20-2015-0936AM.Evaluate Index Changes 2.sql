--SET TRANSACTION ISOLATION LEVEL SNAPSHOT;


DECLARE		@SCRIPT_ADDS		BIT		= 1
		,@SCRIPT_DROPS		BIT		= 0
		,@PRINT_SCRIPTS		BIT		= 1
		,@RUN_SCRIPTS		BIT		= 1
		,@SAVE_SCRIPTS		VarChar(max)	= NULL	-- NULL = DO NOT WRITE FILE  -- OR 'C:\Index_Tuneing.sql'
		,@APPEND_SCRIPTS	BIT		= 0	-- 0 = OVERWRITE, 1 = APPEND
		,@FORCE_MAXDOP		INT		= NULL

		------------ FIXED VARIABLES --------

		,@SQL_SCRIPT		VARCHAR(MAX)
		,@SQL_SCRIPT_2		VARCHAR(MAX)
		,@MSG			VARCHAR(MAX)
		,@hyperthreadingRatio	BIT
		,@logicalCPUs		INT
		,@HTEnabled		INT
		,@physicalCPU		INT
		,@SOCKET		INT
		,@logicalCPUPerNuma	INT
		,@NoOfNUMA		INT
		,@MAXDOP		INT
		,@Unique_ID		VARCHAR(5)
		,@equality_columns	VARCHAR(MAX)
		,@inequality_columns	VARCHAR(MAX)
		,@included_columns	VARCHAR(MAX)
		,@Weight		DECIMAL(18,2)
		,@avg_cost		DECIMAL(18,2)
		,@avg_impact		DECIMAL(18,2)
		,@reads			INT
		,@Writes		INT
		,@user_seeks		INT
		,@user_scans		INT
		,@WriteRatio		DECIMAL(18,2)
		,@SchemaName		SYSNAME
		,@TableName		SYSNAME
		,@row_num		INT
		,@Rank			INT
		,@IndexName		SYSNAME
		,@IndexSizeKB		BIGINT
		,@IndexPages		BIGINT
		,@TotalIndexSizeKB	BIGINT = 0
		,@is_unique		BIT
		,@type_desc		SYSNAME
		,@KeyColumns		VARCHAR(MAX)
		,@IncludedColumns	VARCHAR(MAX)
		,@Filter_definition	VARCHAR(MAX)
		,@is_padded		BIT
		,@Fill_factor		INT
		,@ignore_dup_key	BIT
		,@no_recompute		BIT
		,@allow_row_locks	BIT
		,@allow_page_locks	BIT
		,@DataSpaceName		SYSNAME

-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
--			CALCULATE BEST MAXDOP
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
IF @FORCE_MAXDOP IS NULL
BEGIN
	select		@logicalCPUs = cpu_count -- [Logical CPU Count]
			,@hyperthreadingRatio = hyperthread_ratio --  [Hyperthread Ratio]
			,@physicalCPU = cpu_count / hyperthread_ratio -- [Physical CPU Count]
			,@HTEnabled = case 
					when cpu_count > hyperthread_ratio
						then 1
					else 0
					end -- HTEnabled
	from		sys.dm_os_sys_info
	option (recompile);

	select		@logicalCPUPerNuma = COUNT(parent_node_id) -- [NumberOfLogicalProcessorsPerNuma]
	from		sys.dm_os_schedulers
	where		[status] = 'VISIBLE ONLINE'
		and	parent_node_id < 64
	group by	parent_node_id
	option (recompile);

	select		@NoOfNUMA = count(distinct parent_node_id)
	from		sys.dm_os_schedulers -- find NO OF NUMA Nodes 
	where		[status] = 'VISIBLE ONLINE'
	    and		parent_node_id < 64

	select @MAXDOP = 
	    --- 8 or less processors and NO HT enabled
	    case 
		when @logicalCPUs < 8
		    and @HTEnabled = 0
		    then @logicalCPUs
			--- 8 or more processors and NO HT enabled
		when @logicalCPUs >= 8
		    and @HTEnabled = 0
		    then 8
			--- 8 or more processors and HT enabled and NO NUMA
		when @logicalCPUs >= 8
		    and @HTEnabled = 1
		    and @NoofNUMA = 1
		    then @logicalCPUPerNuma / @physicalCPU
			--- 8 or more processors and HT enabled and NUMA
		when @logicalCPUs >= 8
		    and @HTEnabled = 1
		    and @NoofNUMA > 1
		    then @logicalCPUPerNuma / @physicalCPU
		else 1
		end 
END
ELSE
	SET @MAXDOP = @FORCE_MAXDOP

	PRINT ''
	RAISERROR('  --  MAXDOP setting will be : %d',-1,-1,@MAXDOP) WITH NOWAIT
	PRINT ''

---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
----			GENERATE CREATE INDEX COMMANDS
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

	SET		@SQL_SCRIPT		= 'USE ['+DB_NAME()+']' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)

						+'	DECLARE	@cEModule		sysname' + CHAR(13) + CHAR(10)
						+'		,@cECategory		sysname' + CHAR(13) + CHAR(10)
						+'		,@cEEvent		sysname' + CHAR(13) + CHAR(10)
						+'		,@cEGUID		uniqueidentifier' + CHAR(13) + CHAR(10)
						+'		,@cEMessage		nvarchar(max)' + CHAR(13) + CHAR(10)
						+'		,@cERE_ForceScreen	BIT' + CHAR(13) + CHAR(10)
						+'		,@cERE_Severity		INT' + CHAR(13) + CHAR(10)
						+'		,@cERE_State		INT' + CHAR(13) + CHAR(10)
						+'		,@cERE_With		VarChar(2048)' + CHAR(13) + CHAR(10)
						+'		,@cEStat_Rows		BigInt' + CHAR(13) + CHAR(10)
						+'		,@cEStat_Duration	FLOAT' + CHAR(13) + CHAR(10)
						+'		,@cEMethod_Screen	BIT' + CHAR(13) + CHAR(10)
						+'		,@cEMethod_TableLocal	BIT' + CHAR(13) + CHAR(10)
						+'		,@cEMethod_TableCentral	BIT' + CHAR(13) + CHAR(10)
						+'		,@cEMethod_RaiseError	BIT' + CHAR(13) + CHAR(10)
						+'		,@cEMethod_Twitter	BIT' + CHAR(13) + CHAR(10)
						+'		,@StartDate		DATETIME' + CHAR(13) + CHAR(10)
						+'		,@StopDate		DATETIME' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
						+'	SELECT	@cEModule		= ''Missing & Unused Index Tuneing for ' + QUOTENAME(DB_NAME())+ '''' + CHAR(13) + CHAR(10)
						+'		,@cEGUID		= NEWID()' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
						+'	PRINT	''  -- LOGGED RESULTS CAN BE RETRIEVED WITH:''' + CHAR(13) + CHAR(10)
						+'	PRINT	''  -- SELECT  * FROM [dbaadmin].[dbo].[EventLog] where cEGUID = ''''''+CAST(@cEGUID AS VarChar(50))+''''''''' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
						+ CHAR(13) + CHAR(10) 

IF @SCRIPT_ADDS = 1
BEGIN


	DECLARE MissingIndexes CURSOR
	FOR
	SELECT		*
			,RANK() OVER(ORDER BY [Weight] desc) [Rank]
	FROM		(
			SELECT		left(cast(newid() as varchar(500)),5) [Unique_ID] 
					,c.equality_columns
					,c.inequality_columns
					,c.included_columns
					,a.avg_total_user_cost * a.avg_user_impact * (a.user_seeks + a.user_scans) [Weight]
					,a.avg_total_user_cost avg_cost
					,a.avg_user_impact avg_impact
					,a.user_seeks + a.user_scans [reads]
					,a.user_seeks
					,a.user_scans
					,(	SELECT		CONVERT(DECIMAL(18,2), SUM(s.user_updates)*1.0 
									/ ISNULL(NULLIF(SUM(s.user_scans + s.user_seeks + s.user_lookups),0),1))
						FROM		sys.dm_db_index_usage_stats AS s
						WHERE		object_id = c.object_id) [Table write:read ratio]
					,OBJECT_SCHEMA_NAME(object_id,db_ID()) [SchemaName]
					,object_name(c.object_id) [TableName]
					,ROW_NUMBER() OVER(partition by c.object_id order by a.avg_total_user_cost * a.avg_user_impact * (a.user_seeks + a.user_scans) desc) row_num

			FROM		sys.dm_db_missing_index_group_stats a
			JOIN		sys.dm_db_missing_index_groups b
				ON	a.group_handle = b.index_group_handle
			JOIN		sys.dm_db_missing_index_details c
				ON	c.index_handle = b.index_handle
			WHERE		database_id = DB_ID()
				AND	equality_columns is not null
				AND	a.avg_total_user_cost * a.avg_user_impact * (a.user_seeks + a.user_scans) > 100
				--and a.user_scans > 1
			) Data
	Where		row_num = 1 
	option (recompile);

	OPEN MissingIndexes;
	FETCH MissingIndexes INTO @Unique_ID,@equality_columns,@inequality_columns,@included_columns,@Weight,@avg_cost,@avg_impact,@reads,@user_seeks,@user_scans,@WriteRatio,@SchemaName,@TableName,@row_num,@Rank;
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			---------------------------- 
			---------------------------- CURSOR LOOP TOP
	
			SET	@SQL_SCRIPT		= @SQL_SCRIPT + CHAR(13) + CHAR(10)
							+ '/* '+RIGHT('000' + CAST(@Rank as VarChar(10)),3)+' - '+ RIGHT('0000000000' + CAST(CAST(@Weight as BIGINT)AS VarChar(50)),10) +' */  ' 
							+ 'RAISERROR(''Updateing Statistics ON ' + QUOTENAME(@TableName) +''',-1,-1) WITH NOWAIT' + CHAR(13) + CHAR(10)
							+ CHAR(13) + CHAR(10)
							+ '                        SELECT    @cEEvent       = '''+ QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName)+'''' + CHAR(13) + CHAR(10)
							+ '                                  ,@cECategory   = ''UPDATE STATISTICS''' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEMessage    = ''Starting''' + CHAR(13) + CHAR(10)
							+ '                                  ,@StartDate    = GETDATE()' + CHAR(13) + CHAR(10)
							+ CHAR(13) + CHAR(10)
							+ '                        exec [dbaadmin].[dbo].[dbasp_LogEvent]' + CHAR(13) + CHAR(10)
							+ '                                  @cEModule' + CHAR(13) + CHAR(10)
							+ '                                  ,@cECategory' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEEvent' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEGUID' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEMessage' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEMethod_TableLocal = 1' + CHAR(13) + CHAR(10)
							+ CHAR(13) + CHAR(10)
							+ '                        UPDATE STATISTICS ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + CHAR(13) + CHAR(10)
							+ CHAR(13) + CHAR(10)
							+ '                        SELECT    @cEMessage        = ''Done''' + CHAR(13) + CHAR(10)
							+ '                                  ,@StopDate         = getdate()' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000' + CHAR(13) + CHAR(10)
							+ CHAR(13) + CHAR(10)
							+ '                        exec [dbaadmin].[dbo].[dbasp_LogEvent]' + CHAR(13) + CHAR(10)
							+ '                                  @cEModule' + CHAR(13) + CHAR(10)
							+ '                                  ,@cECategory' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEEvent' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEGUID' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEMessage' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEStat_Duration = @cEStat_Duration' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEMethod_TableLocal = 1' + CHAR(13) + CHAR(10)
							+ CHAR(13) + CHAR(10) 
							+ '                        RAISERROR(''Creating Index [AMIX_' + @TableName + '_' + @Unique_ID + '] on '+ QUOTENAME(@TableName) + ''',-1,-1) WITH NOWAIT' + CHAR(13) + CHAR(10)
							+ '                        -- Table write:read ratio: ' + CAST(@WriteRatio AS VarChar(50)) + CHAR(13) + CHAR(10) 
							+ CHAR(13) + CHAR(10)
							+ '                        SELECT    @cEEvent       = ''AMIX_' + @TableName +'_'+ @Unique_ID + ' on ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName)+'''' + CHAR(13) + CHAR(10)
							+ '                                  ,@cECategory   = ''CREATE MISSING INDEX''' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEMessage    = ''Starting''' + CHAR(13) + CHAR(10)
							+ '                                  ,@StartDate    = GETDATE()' + CHAR(13) + CHAR(10)
							+ CHAR(13) + CHAR(10)
							+ '                        exec [dbaadmin].[dbo].[dbasp_LogEvent]' + CHAR(13) + CHAR(10)
							+ '                                  @cEModule' + CHAR(13) + CHAR(10)
							+ '                                  ,@cECategory' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEEvent' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEGUID' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEMessage' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEMethod_TableLocal = 1' + CHAR(13) + CHAR(10)
							+ CHAR(13) + CHAR(10)
							+ '                        CREATE NONCLUSTERED INDEX AMIX_' + @TableName +'_'+ @Unique_ID 
							+ ' on ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName)
							+ '('
							+ case	when @equality_columns is not null and @inequality_columns is not null 
									then @equality_columns + ',' + @inequality_columns
									when @equality_columns is not null and @inequality_columns is null 
									then @equality_columns
									when @inequality_columns is not null 
									then @inequality_columns
									ELSE ''
									end
							+ ')' 
							+ case	when @included_columns is not null 
									then ' Include (' + @included_columns + ')'
									else ''
									end
							+ ' WITH(MAXDOP='+CAST(@MAXDOP AS VARCHAR(2))+',SORT_IN_TEMPDB=ON,ONLINE=ON)' + CHAR(13) + CHAR(10) 
							+ CHAR(13) + CHAR(10)
							+ '                        SELECT    @cEMessage        = ''Done''' + CHAR(13) + CHAR(10)
							+ '                                  ,@StopDate         = getdate()' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000' + CHAR(13) + CHAR(10)
							+ CHAR(13) + CHAR(10)
							+ '                        exec [dbaadmin].[dbo].[dbasp_LogEvent]' + CHAR(13) + CHAR(10)
							+ '                                  @cEModule' + CHAR(13) + CHAR(10)
							+ '                                  ,@cECategory' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEEvent' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEGUID' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEMessage' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEStat_Duration = @cEStat_Duration' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEMethod_TableLocal = 1' + CHAR(13) + CHAR(10)
							+ CHAR(13) + CHAR(10) 

			---------------------------- CURSOR LOOP BOTTOM
			----------------------------
		END
 		FETCH NEXT FROM MissingIndexes INTO @Unique_ID,@equality_columns,@inequality_columns,@included_columns,@Weight,@avg_cost,@avg_impact,@reads,@user_seeks,@user_scans,@WriteRatio,@SchemaName,@TableName,@row_num,@Rank;
	END
	CLOSE MissingIndexes;
	DEALLOCATE MissingIndexes;


	SELECT		@SQL_SCRIPT	= @SQL_SCRIPT + CHAR(13) + CHAR(10)+ CHAR(13) + CHAR(10)
					+ '	SELECT  * FROM [dbaadmin].[dbo].[EventLog] where cEGUID = @cEGUID' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
					+ CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)

END

--exec dbaadmin.dbo.dbasp_printLarge @SQL_SCRIPT
--SELECT		@SQL_SCRIPT	= ''

---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
----			GENERATE DROP INDEX COMMANDS
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
IF @SCRIPT_DROPS = 1
BEGIN

	DECLARE UnusedIndexes CURSOR
	FOR
	-- SELECT QUERY FOR CURSOR

	SELECT		[SchemaName]		= OBJECT_SCHEMA_NAME(s.object_id,db_ID())
			,[TableName]		= object_name(s.object_id)
			,[IndexName]		= i.name
			,[write_ops]		= s.user_updates
			,[read_ops]		= s.user_scans + s.user_seeks + s.user_lookups
			,[write:read ratio]	= CONVERT(DECIMAL(18,2), s.user_updates*1.0 
						/ ISNULL(NULLIF(s.user_scans + s.user_seeks + s.user_lookups,0),1))
			,[Current_IndexSizekb]	= p.[used_page_count] * 8
			,[Current_IndexPages]	= p.[used_page_count]
			,[is_unique]		= I.is_unique
			,[type_desc]		= I.type_desc
			,[KeyColumns]		= [KeyColumns]
			,[IncludedColumns]	= [IncludedColumns]
			,[Filter_definition]	= I.Filter_definition
			,[is_padded]		= I.is_padded
			,[Fill_factor]		= I.Fill_factor
			,[ignore_dup_key]	= I.ignore_dup_key
			,[no_recompute]		= ST.no_recompute
			,[allow_row_locks]	= I.allow_row_locks
			,[allow_page_locks]	= I.allow_page_locks
			,[DataSpaceName]	= DS.name
	FROM		sys.indexes I 
	JOIN		sys.dm_db_partition_stats P 
		ON	P.[object_id] = I.[object_id]
		AND	P.[index_id] = I.[index_id]
		AND	OBJECTPROPERTY(I.OBJECT_ID,'IsUserTable') = 1
		AND	I.type_desc = 'nonclustered'
		AND	I.is_primary_key = 0
		AND	I.is_unique_constraint = 0
	JOIN		sys.dm_db_index_usage_stats AS S
		ON	S.database_id = DB_ID()
		AND	S.OBJECT_ID = I.OBJECT_ID
		AND	S.index_id = I.index_id 
	JOIN		sys.tables T 
		ON	T.Object_id = I.Object_id     
	JOIN		sys.sysindexes SI 
		ON	I.Object_id = SI.id 
		AND	I.index_id = SI.indid    
	JOIN		(
			SELECT		* 
			FROM		(   
					SELECT		IC2.object_id 
							,IC2.index_id 
							,STUFF(	(
								SELECT		' , ' + C.name 
										+ CASE 
											WHEN MAX(CONVERT(INT,IC1.is_descending_key)) = 1 THEN ' DESC ' 
											ELSE ' ASC ' END 
								FROM		sys.index_columns IC1   
								JOIN		Sys.columns C    
									ON	C.object_id = IC1.object_id    
									AND	C.column_id = IC1.column_id    
									AND	IC1.is_included_column = 0   
								WHERE		IC1.object_id = IC2.object_id    
									AND	IC1.index_id = IC2.index_id    
								GROUP BY	IC1.object_id
										,C.name,index_id   
								ORDER BY	MAX(IC1.key_ordinal)   
								FOR XML PATH('')
								),1,2,'') KeyColumns    
					FROM		sys.index_columns IC2    
					GROUP BY	IC2.object_id 
							,IC2.index_id
					) tmp3 
			)tmp4    
		ON	I.object_id = tmp4.object_id 
		AND	I.Index_id = tmp4.index_id   
	JOIN		sys.stats ST 
		ON	ST.object_id = I.object_id 
		AND	ST.stats_id = I.index_id    
	JOIN		sys.data_spaces DS 
		ON	I.data_space_id=DS.data_space_id    
	JOIN		sys.filegroups FG 
		ON	I.data_space_id=FG.data_space_id    
	LEFT JOIN	(
			SELECT		*
			FROM		(    
					SELECT		IC2.object_id 
							,IC2.index_id
							,STUFF(	(
								SELECT		' , ' + C.name  
								FROM		sys.index_columns IC1    
								JOIN		Sys.columns C     
									ON	C.object_id = IC1.object_id     
									AND	C.column_id = IC1.column_id     
									AND	IC1.is_included_column = 1    
								WHERE		IC1.object_id = IC2.object_id     
									AND	IC1.index_id = IC2.index_id     
								GROUP BY	IC1.object_id
										,C.name,index_id    
								FOR XML PATH('')
								),1,2,'') IncludedColumns     
					FROM		sys.index_columns IC2     
					GROUP BY	IC2.object_id 
							,IC2.index_id
					) tmp1    
			WHERE		IncludedColumns IS NOT NULL 
			) tmp2     
		ON	tmp2.object_id = I.object_id 
		AND	tmp2.index_id = I.index_id    
	WHERE		s.user_scans + s.user_seeks + s.user_lookups = 0 -- INDEX IS NEVER USED
		OR	CONVERT	(
				DECIMAL(18,2)
				,s.user_updates*1.0 / ISNULL(NULLIF(s.user_scans + s.user_seeks + s.user_lookups,0),1)
				) >= 10 -- INDEX IS UPDATED MUCH MORE THAN IT IS USED
	ORDER BY	[Current_IndexSizekb] DESC		
	option (recompile);

	OPEN UnusedIndexes;
	FETCH UnusedIndexes INTO @SchemaName,@TableName,@IndexName,@Writes,@Reads,@WriteRatio,@IndexSizeKB,@IndexPages,@is_unique,@type_desc,@KeyColumns,@IncludedColumns,@Filter_definition,@is_padded,@Fill_factor,@ignore_dup_key,@no_recompute,@allow_row_locks,@allow_page_locks,@DataSpaceName;
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			---------------------------- 
			---------------------------- CURSOR LOOP TOP
			SET	@TotalIndexSizeKB	= @TotalIndexSizeKB + @IndexSizeKB

			SET	@SQL_SCRIPT_2		= ' CREATE ' +  CASE 
										WHEN @is_unique = 1 THEN ' UNIQUE ' 
										ELSE '' 
										END  
								+ @type_desc COLLATE DATABASE_DEFAULT +' INDEX '     
								+ QUOTENAME(@IndexName)  + ' ON '     
								+ QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) 
								+ ' ( ' + @KeyColumns + ' )  ' +  
								ISNULL(' INCLUDE ('+ @IncludedColumns +' ) ','') +  
								ISNULL(' WHERE  '+ @Filter_definition,'') + ' WITH ( ' +  
								CASE WHEN @is_padded = 1 THEN ' PAD_INDEX = ON ' ELSE ' PAD_INDEX = OFF ' END + ','  +  
								'FILLFACTOR = '+CONVERT(CHAR(5),CASE WHEN @Fill_factor = 0 THEN 100 ELSE @Fill_factor END) + ','  +  
								-- default value  
								'SORT_IN_TEMPDB = OFF '  + ','  +  
								CASE WHEN @ignore_dup_key = 1 THEN ' IGNORE_DUP_KEY = ON ' ELSE ' IGNORE_DUP_KEY = OFF ' END + ','  +  
								CASE WHEN @no_recompute = 0 THEN ' STATISTICS_NORECOMPUTE = OFF ' ELSE ' STATISTICS_NORECOMPUTE = ON ' END + ','  +  
								-- default value   
								' DROP_EXISTING = ON '  + ','  +  
								-- default value   
								' ONLINE = OFF '  + ','  +  
								CASE WHEN @allow_row_locks = 1 THEN ' ALLOW_ROW_LOCKS = ON ' ELSE ' ALLOW_ROW_LOCKS = OFF ' END + ','  +  
								CASE WHEN @allow_page_locks = 1 THEN ' ALLOW_PAGE_LOCKS = ON ' ELSE ' ALLOW_PAGE_LOCKS = OFF ' END  + ' ) ON [' +  
								@DataSpaceName + ' ] '


			--exec dbaadmin.dbo.dbasp_printLarge @SQL_SCRIPT_2


			SET	@SQL_SCRIPT		= @SQL_SCRIPT + CHAR(13) + CHAR(10) 
							+ 'RAISERROR(''Dropping Index ' + QUOTENAME(@IndexName) +' on '+ + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) +''',-1,-1) WITH NOWAIT' + CHAR(13) + CHAR(10)
							+ '  --  READS: ' + CAST(@Reads AS VarChar(50)) 
							+ '  WRITES: '+ CAST(@Writes AS VarChar(50)) 
							+ '  RATIO: '+ CAST(@WriteRatio AS VarChar(50)) 
							+ '  SIZE: ' + dbaadmin.dbo.dbaudf_FormatBytes(@IndexSizeKB,'kb') 
							+ CHAR(13) + CHAR(10)
							+ '                        SELECT    @cEEvent       = '''+QUOTENAME(@IndexName) + ' on ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName)+'''' + CHAR(13) + CHAR(10)
							+ '                                  ,@cECategory   = ''DROP INDEX RECOVERY SCRIPT''' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEMessage    = '''+ @SQL_SCRIPT_2 +'''' + CHAR(13) + CHAR(10)
							+ '                                  ,@StartDate    = GETDATE()' + CHAR(13) + CHAR(10)
							+ CHAR(13) + CHAR(10)
							+ '                        exec [dbaadmin].[dbo].[dbasp_LogEvent]' + CHAR(13) + CHAR(10)
							+ '                                  @cEModule' + CHAR(13) + CHAR(10)
							+ '                                  ,@cECategory' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEEvent' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEGUID' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEMessage' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEMethod_TableLocal = 1' + CHAR(13) + CHAR(10)
							+ CHAR(13) + CHAR(10)
							+ '                        SELECT    @cEEvent       = '''+QUOTENAME(@IndexName) + ' on ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName)+'''' + CHAR(13) + CHAR(10)
							+ '                                  ,@cECategory   = ''DROP UNUSED INDEX''' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEMessage    = ''Starting''' + CHAR(13) + CHAR(10)
							+ '                                  ,@StartDate    = GETDATE()' + CHAR(13) + CHAR(10)
							+ CHAR(13) + CHAR(10)
							+ '                        exec [dbaadmin].[dbo].[dbasp_LogEvent]' + CHAR(13) + CHAR(10)
							+ '                                  @cEModule' + CHAR(13) + CHAR(10)
							+ '                                  ,@cECategory' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEEvent' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEGUID' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEMessage' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEMethod_TableLocal = 1' + CHAR(13) + CHAR(10)
							+ CHAR(13) + CHAR(10)
							+ '  DROP INDEX ' + QUOTENAME(@IndexName) + ' ON ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + CHAR(13) + CHAR(10)
							+ CHAR(13) + CHAR(10)
							+ '                        SELECT    @cEMessage        = ''Done''' + CHAR(13) + CHAR(10)
							+ '                                  ,@StopDate         = getdate()' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000' + CHAR(13) + CHAR(10)
							+ CHAR(13) + CHAR(10)
							+ '                        exec [dbaadmin].[dbo].[dbasp_LogEvent]' + CHAR(13) + CHAR(10)
							+ '                                  @cEModule' + CHAR(13) + CHAR(10)
							+ '                                  ,@cECategory' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEEvent' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEGUID' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEMessage' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEStat_Duration = @cEStat_Duration' + CHAR(13) + CHAR(10)
							+ '                                  ,@cEMethod_TableLocal = 1' + CHAR(13) + CHAR(10)
							+ CHAR(13) + CHAR(10)


			---------------------------- CURSOR LOOP BOTTOM
			----------------------------
		END
 		FETCH NEXT FROM UnusedIndexes INTO @SchemaName,@TableName,@IndexName,@Writes,@Reads,@WriteRatio,@IndexSizeKB,@IndexPages,@is_unique,@type_desc,@KeyColumns,@IncludedColumns,@Filter_definition,@is_padded,@Fill_factor,@ignore_dup_key,@no_recompute,@allow_row_locks,@allow_page_locks,@DataSpaceName;
	END
	CLOSE UnusedIndexes;
	DEALLOCATE UnusedIndexes;

	SET @MSG	= ' --    TOTAL SPACE SAVED BY DROPPING UNUSED INDEXES:  ' 
			+ dbaadmin.dbo.dbaudf_FormatBytes(@TotalIndexSizeKB,'kb')
END

IF @PRINT_SCRIPTS = 1
BEGIN
	exec dbaadmin.dbo.dbasp_printLarge @SQL_SCRIPT
	PRINT ''
	exec dbaadmin.dbo.dbasp_printLarge @MSG
END

IF @RUN_SCRIPTS = 1
 EXEC		(@SQL_SCRIPT)

 IF @SAVE_SCRIPTS IS NOT NULL
	EXEC dbaadmin.dbo.dbasp_FileAccess_Write @SQL_SCRIPT,@SAVE_SCRIPTS,@APPEND_SCRIPTS,1



