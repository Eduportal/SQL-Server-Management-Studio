DECLARE	@SQL_SCRIPT	VarChar(max)

SET		@SQL_SCRIPT = 'USE ['+DB_NAME()+']' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)

SELECT		@SQL_SCRIPT = @SQL_SCRIPT + CHAR(13) + CHAR(10) + [command] 
FROM		(
		select		distinct 
				'UPDATE STATISTICS ' + object_name(object_id) [command]
		FROM sys.dm_db_missing_index_group_stats a
		inner join sys.dm_db_missing_index_groups b
		on a.group_handle = b.index_group_handle
		inner join sys.dm_db_missing_index_details c
		on c.index_handle = b.index_handle
		where database_id = DB_ID()
		and equality_columns is not null
		) Data

--exec dbaadmin.dbo.dbasp_printLarge @SQL_SCRIPT
--EXEC		(@SQL_SCRIPT)
SELECT		@SQL_SCRIPT = @SQL_SCRIPT + CHAR(13) + CHAR(10)+ CHAR(13) + CHAR(10)+ CHAR(13) + CHAR(10)

--SET		@SQL_SCRIPT = ''

SELECT		@SQL_SCRIPT = @SQL_SCRIPT + CHAR(13) + CHAR(10) + '/* '+RIGHT('000' + CAST([Rank] as VarChar(10)),3)+' */  ' + [Script] 

FROM		(
		SELECT		*
				,RANK() OVER(ORDER BY [Weight] desc) [Rank]
		FROM		(
				SELECT		'CREATE NONCLUSTERED INDEX IX1_' + object_name(c.object_id) +'_'+ left(cast(newid() as varchar(500)),5) 
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
			
							,object_name(c.object_id) [TableName]
							,ROW_NUMBER() OVER(partition by c.object_id order by a.avg_total_user_cost * a.avg_user_impact * (a.user_seeks + a.user_scans) desc) row_num
				
				FROM sys.dm_db_missing_index_group_stats a
				inner join sys.dm_db_missing_index_groups b
				on a.group_handle = b.index_group_handle
				inner join sys.dm_db_missing_index_details c
				on c.index_handle = b.index_handle
				where database_id = DB_ID()
				and equality_columns is not null
				) Data
		Where		row_num = 1
		) Data


--SET @SQL_SCRIPT = @SQL_SCRIPT + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10)

exec dbaadmin.dbo.dbasp_printLarge @SQL_SCRIPT
--EXEC		(@SQL_SCRIPT)


