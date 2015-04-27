DECLARE	@SQL_SCRIPT	VarChar(max)

SET		@SQL_SCRIPT = 'USE ['+DB_NAME()+']' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)

SELECT		@SQL_SCRIPT = @SQL_SCRIPT + CHAR(13) + CHAR(10) + [command] 
FROM		(
		select		distinct 
				'RAISERROR(''Updateing Statistics ON [' + object_name(object_id) +']'',-1,-1) WITH NOWAIT' +CHAR(13)+CHAR(10)
				+'  UPDATE STATISTICS ' + object_name(object_id) [command]
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

SELECT		@SQL_SCRIPT = @SQL_SCRIPT + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + '/* '+RIGHT('000' + CAST([Rank] as VarChar(10)),3)+' - '+ RIGHT('0000000000' + CAST(CAST([Weight] as BIGINT)AS VarChar(50)),10) +' */  ' + [Script] 

FROM		(
		SELECT		*
				,RANK() OVER(ORDER BY [Weight] desc) [Rank]
		FROM		(
				SELECT		'RAISERROR(''Creating Index [AMIX_' + object_name(c.object_id) +'_?????] on ['+ object_name(c.object_id)+']'',-1,-1) WITH NOWAIT' +CHAR(13)+CHAR(10)
							+ '                        '
							+ 'CREATE NONCLUSTERED INDEX AMIX_' + object_name(c.object_id) +'_'+ left(cast(newid() as varchar(500)),5) 
							+ ' on ' + object_name(c.object_id)
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
							+ ' WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)' [Script]
							,a.avg_total_user_cost * a.avg_user_impact * (a.user_seeks + a.user_scans) [Weight]
							,a.avg_total_user_cost avg_cost
							,a.avg_user_impact avg_impact
							,(a.user_seeks + a.user_scans) [reads]
							,a.user_seeks
							,a.user_scans
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

SELECT		@SQL_SCRIPT = @SQL_SCRIPT + CHAR(13) + CHAR(10) + [drop_statement] 
FROM		(
		SELECT		'RAISERROR(''Dropping Index [' + i.name +'] on ['+ o.name+']'',-1,-1) WITH NOWAIT' +CHAR(13)+CHAR(10)
				+'  DROP INDEX ' + QUOTENAME(i.name) + ' ON ' + QUOTENAME(s.name) + '.' + QUOTENAME(OBJECT_NAME(dm_ius.OBJECT_ID)) AS [drop_statement]
				,schema_name(o.schema_id) AS [SchemaName]
				, o.name AS ObjectName
				, i.name AS IndexName
				, i.index_id AS IndexID
				, dm_ius.user_seeks AS UserSeek
				, dm_ius.user_scans AS UserScans
				, dm_ius.user_lookups AS UserLookups
				, dm_ius.user_updates AS UserUpdates
				, p.TableRows
				, i.type_desc
				, coalesce(last_user_seek,last_user_scan,last_user_lookup,last_system_scan,last_system_seek,last_system_lookup) as LastUsed
				, STATS_DATE(o.object_id, i.index_id) [CreateDate]
				--,*
		FROM		sys.dm_db_index_usage_stats dm_ius
		INNER JOIN	sys.indexes i 
			ON	i.index_id = dm_ius.index_id 
			AND	dm_ius.OBJECT_ID = i.OBJECT_ID
		INNER JOIN	sys.objects o 
			ON	dm_ius.OBJECT_ID = o.OBJECT_ID
		INNER JOIN	sys.schemas s 
			ON	o.schema_id = s.schema_id
		INNER JOIN	(
				SELECT		SUM(p.rows) TableRows
						, p.index_id
						, p.OBJECT_ID
				FROM		sys.partitions p 
				GROUP BY	p.index_id
						, p.OBJECT_ID
				) p
			ON	p.index_id = dm_ius.index_id 
			AND	dm_ius.OBJECT_ID = p.OBJECT_ID
		WHERE		OBJECTPROPERTY(dm_ius.OBJECT_ID,'IsUserTable') = 1
			AND	i.name Like 'AMIX_' + o.name + '%'
			AND	dm_ius.database_id = DB_ID()
			AND	i.type_desc = 'nonclustered'
			AND	i.is_primary_key = 0
			AND	i.is_unique_constraint = 0
			AND	(dm_ius.user_seeks + dm_ius.user_scans + dm_ius.user_lookups) = 0
			AND	coalesce(last_user_seek,last_user_scan,last_user_lookup,last_system_scan,last_system_seek,last_system_lookup,STATS_DATE(o.object_id, i.index_id)) < GetDate()-30
	
		--ORDER BY	(dm_ius.user_seeks + dm_ius.user_scans + dm_ius.user_lookups) ASC
		) Data

--SET @SQL_SCRIPT = @SQL_SCRIPT + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10)

exec dbaadmin.dbo.dbasp_printLarge @SQL_SCRIPT
--EXEC		(@SQL_SCRIPT)


 
