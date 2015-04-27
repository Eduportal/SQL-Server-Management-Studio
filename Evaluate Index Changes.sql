DECLARE	@SQL_SCRIPT		VarChar(max)
DECLARE	@MSG			VarChar(max)
declare @hyperthreadingRatio	bit
declare @logicalCPUs		int
declare @HTEnabled		int
declare @physicalCPU		int
declare @SOCKET			int
declare @logicalCPUPerNuma	int
declare @NoOfNUMA		int
DECLARE @MAXDOP			INT

-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
--			CALCULATE BEST MAXDOP
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
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

	PRINT ''
	RAISERROR('  --  MAXDOP setting should be : %d',-1,-1,@MAXDOP) WITH NOWAIT
	PRINT ''

-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
--			GENERATE UPDATE STATS COMMANDS
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

SET		@SQL_SCRIPT = 'USE ['+DB_NAME()+']' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)

SELECT		@SQL_SCRIPT = @SQL_SCRIPT + CHAR(13) + CHAR(10) + [command] 
FROM		(
		select		distinct 
				'RAISERROR(''Updateing Statistics ON [' + object_name(object_id) +']'',-1,-1) WITH NOWAIT' +CHAR(13)+CHAR(10)
				+'  UPDATE STATISTICS ' + QUOTENAME(OBJECT_SCHEMA_NAME(object_id,db_ID())) + '.' + QUOTENAME(object_name(object_id)) [command]
		FROM sys.dm_db_missing_index_group_stats a
		inner join sys.dm_db_missing_index_groups b
		on a.group_handle = b.index_group_handle
		inner join sys.dm_db_missing_index_details c
		on c.index_handle = b.index_handle
		where database_id = DB_ID()
		and equality_columns is not null
		AND a.avg_total_user_cost * a.avg_user_impact * (a.user_seeks + a.user_scans) > 100
		--and a.user_scans > 1
		) Data

SELECT		@SQL_SCRIPT = @SQL_SCRIPT + CHAR(13) + CHAR(10)+ CHAR(13) + CHAR(10)

-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
--			GENERATE CREATE INDEX COMMANDS
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

SELECT		@SQL_SCRIPT = @SQL_SCRIPT + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + '/* '+RIGHT('000' + CAST([Rank] as VarChar(10)),3)+' - '+ RIGHT('0000000000' + CAST(CAST([Weight] as BIGINT)AS VarChar(50)),10) +' */  ' + [Script] 

FROM		( --DECLARE @MAXDOP INT = 8
		SELECT		*
				,RANK() OVER(ORDER BY [Weight] desc) [Rank]
		FROM		(	-- DECLARE @MAXDOP INT = 8
				SELECT		'RAISERROR(''Creating Index [AMIX_' + object_name(c.object_id) +'_?????] on ['+ object_name(c.object_id)+']'',-1,-1) WITH NOWAIT' +CHAR(13)+CHAR(10)
							+ '                        '
							+ '-- Table write:read ratio: ' 
							+ (	SELECT		CAST(CONVERT(DECIMAL(18,2), SUM(s.user_updates)*1.0 
											/ ISNULL(NULLIF(SUM(s.user_scans + s.user_seeks + s.user_lookups),0),1)) AS VarChar(50))
								FROM		sys.dm_db_index_usage_stats AS s
								WHERE		object_id = c.object_id)
							+ CHAR(13) + CHAR(10) 
							+ '                        '
							+ 'CREATE NONCLUSTERED INDEX AMIX_' + object_name(c.object_id) +'_'+ left(cast(newid() as varchar(500)),5) 
							+ ' on ' + QUOTENAME(OBJECT_SCHEMA_NAME(object_id,db_ID())) + '.' + QUOTENAME(object_name(c.object_id))
							+ '('
							+ case	when c.equality_columns is not null and c.inequality_columns is not null 
									then c.equality_columns + ',' + c.inequality_columns
									when c.equality_columns is not null and c.inequality_columns is null 
									then c.equality_columns
									when c.inequality_columns is not null 
									then c.inequality_columns
									ELSE ''
									end
							+ ')' 
							+ case	when c.included_columns is not null 
									then ' Include (' + c.included_columns + ')'
									else ''
									end
							+ ' WITH(MAXDOP='+CAST(@MAXDOP AS VARCHAR(2))+',SORT_IN_TEMPDB=ON,ONLINE=ON)' [Script]
							,a.avg_total_user_cost * a.avg_user_impact * (a.user_seeks + a.user_scans) [Weight]
							,a.avg_total_user_cost avg_cost
							,a.avg_user_impact avg_impact
							,(a.user_seeks + a.user_scans) [reads]
							,a.user_seeks
							,a.user_scans
							,(	SELECT		CONVERT(DECIMAL(18,2), SUM(s.user_updates)*1.0 
											/ ISNULL(NULLIF(SUM(s.user_scans + s.user_seeks + s.user_lookups),0),1))
								FROM		sys.dm_db_index_usage_stats AS s
								WHERE		object_id = c.object_id) [Table write:read ratio]
							,object_name(c.object_id) [TableName]
							,ROW_NUMBER() OVER(partition by c.object_id order by a.avg_total_user_cost * a.avg_user_impact * (a.user_seeks + a.user_scans) desc) row_num
				
				FROM sys.dm_db_missing_index_group_stats a
				inner join sys.dm_db_missing_index_groups b
				on a.group_handle = b.index_group_handle
				inner join sys.dm_db_missing_index_details c
				on c.index_handle = b.index_handle
				where database_id = DB_ID()
				and equality_columns is not null
				AND a.avg_total_user_cost * a.avg_user_impact * (a.user_seeks + a.user_scans) > 100
				--and a.user_scans > 1
				) Data
		Where		row_num = 1
		) Data

SELECT		@SQL_SCRIPT = @SQL_SCRIPT + CHAR(13) + CHAR(10)+ CHAR(13) + CHAR(10)+ CHAR(13) + CHAR(10)

-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
--			GENERATE DROP INDEX COMMANDS
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

;WITH		IndexData
		AS
		(
		SELECT		[drop_statement]	= 'RAISERROR(''Dropping Index ' + QUOTENAME(i.name) +' on '+ + QUOTENAME(OBJECT_SCHEMA_NAME(s.object_id,db_ID())) + '.' + QUOTENAME(OBJECT_NAME(s.OBJECT_ID)) +''',-1,-1) WITH NOWAIT' +CHAR(13)+CHAR(10)
							+ '  --  READS: ' + CAST(SUM(s.user_scans + s.user_seeks + s.user_lookups) AS VarChar(50)) 
							+ '  WRITES: '+ CAST(SUM(s.user_updates) AS VarChar(50)) 
							+ '  RATIO: '+ CAST(CONVERT(DECIMAL(18,2), SUM(s.user_updates)*1.0 / ISNULL(NULLIF(SUM(s.user_scans + s.user_seeks + s.user_lookups),0),1)) AS VarChar(50)) 
							+ '  SIZE: ' + dbaadmin.dbo.dbaudf_FormatBytes((SUM(p.[used_page_count]) * 8),'kb') 
							+ CHAR(13) + CHAR(10)
							+ '  DROP INDEX ' + QUOTENAME(i.name) + ' ON ' + QUOTENAME(OBJECT_SCHEMA_NAME(s.object_id,db_ID())) + '.' + QUOTENAME(OBJECT_NAME(s.OBJECT_ID))
				,[TableName]		= object_name(s.object_id)
				,[IndexName]		= i.name 
				,[write_ops]		= SUM(s.user_updates)
				,[read_ops]		= SUM(s.user_scans + s.user_seeks + s.user_lookups)
				,[write:read ratio]	= CONVERT(DECIMAL(18,2), SUM(s.user_updates)*1.0 
							/ ISNULL(NULLIF(SUM(s.user_scans + s.user_seeks + s.user_lookups),0),1))
				,[Current_IndexSizekb]	= SUM(p.[used_page_count]) * 8
				,[Current_IndexPages]	= SUM(p.[used_page_count])
		FROM		sys.dm_db_index_usage_stats AS s
		JOIN		sys.indexes i 
			ON	i.index_id = s.index_id 
			AND	s.OBJECT_ID = i.OBJECT_ID
		JOIN		sys.dm_db_partition_stats AS p
			ON	p.[object_id] = i.[object_id]
			AND	p.[index_id] = i.[index_id]
		WHERE		OBJECTPROPERTY(s.OBJECT_ID,'IsUserTable') = 1
			--AND	i.name Like 'AMIX_' + object_name(s.object_id) + '%'
			AND	s.database_id = DB_ID()
			AND	i.type_desc = 'nonclustered'
			AND	i.is_primary_key = 0
			AND	i.is_unique_constraint = 0
		--	AND	coalesce(last_user_seek,last_user_scan,last_user_lookup,last_system_scan,last_system_seek,last_system_lookup,STATS_DATE(o.object_id, i.index_id)) < GetDate()-30
	
		GROUP BY	s.object_id
				,i.name
		)
SELECT		@SQL_SCRIPT	= @SQL_SCRIPT + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) 
				  + CASE 
					WHEN [TableName] = 'TOTAL' THEN ''
					ELSE COALESCE([drop_statement] ,'')
					END
		,@MSG		= CASE 
					WHEN [TableName] = 'TOTAL' THEN ' --    TOTAL SPACE SAVED BY DROPPING UNUSED INDEXES:  ' + [Current_IndexSize]
					ELSE @MSG
					END
FROM		(			
		SELECT		[drop_statement]	
				,[TableName]		
				,[IndexName]		
				,[write_ops]		
				,[read_ops]		
				,[write:read ratio]
				,[Current_IndexSize] =  dbaadmin.dbo.dbaudf_FormatBytes([Current_IndexSizekb],'kb')
				,[Current_IndexPages]
		FROM		IndexData
		WHERE		[read_ops] = 0
			OR	[write:read ratio] >= 10

		UNION ALL	
		SELECT		[drop_statement]	= null
				,[TableName]		= 'TOTAL'
				,[IndexName]		= null
				,[write_ops]		= null
				,[read_ops]		= null
				,[write:read ratio]	= null
				,[Current_IndexSize]	=  dbaadmin.dbo.dbaudf_FormatBytes(SUM([Current_IndexSizekb]),'kb')
				,[Current_IndexPages]	= NULL
		FROM		IndexData
		WHERE		[read_ops] = 0
			OR	[write:read ratio] >= 10
		) Data


exec dbaadmin.dbo.dbasp_printLarge @SQL_SCRIPT
PRINT ''
exec dbaadmin.dbo.dbasp_printLarge @MSG
--EXEC		(@SQL_SCRIPT)


 
