--SELECT
--  migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) AS improvement_measure,
--  'CREATE INDEX [missing_index_' + CONVERT (varchar, mig.index_group_handle) + '_' + CONVERT (varchar, mid.index_handle)
--  + '_' + LEFT (PARSENAME(mid.statement, 1), 32) + ']'
--  + ' ON ' + mid.statement
--  + ' (' + ISNULL (mid.equality_columns,'')
--    + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END
--    + ISNULL (mid.inequality_columns, '')
--  + ')'
--  + ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement,
--  migs.*, mid.* -- mid.database_id, mid.[object_id]
--FROM sys.dm_db_missing_index_groups mig
--INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
--INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
--WHERE migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) > 10
--AND mid.database_id > 4
--ORDER BY migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) DESC


--SELECT [object_name]
--      ,[counter_name]
--      ,[instance_name]
--      ,[cntr_value]
--      ,[cntr_type]
--  FROM [WCDS].[sys].[dm_os_performance_counters]
--Where counter_name like '%life%'


--SELECT		[Total Lines] = COUNT(*)
--		,[Distinct Lines] = COUNT(DISTINCT [AssetId])
--			-- the closer to 1, the better
--		,[selectivity] = COUNT(DISTINCT [AssetId])/CAST( COUNT(*) AS DEC(10,2))
--FROM		[WCDS].[dbo].[SubscriptionDownload]

--SELECT		[Total Lines] = COUNT(*)
--		,[Distinct Lines] = COUNT(DISTINCT [DownloadId])
--			-- the closer to 1, the better
--		,[selectivity] = COUNT(DISTINCT [DownloadId])/CAST( COUNT(*) AS DEC(10,2))
--FROM		[WCDS].[dbo].[SubscriptionDownload]    
    
    
/*
as we can find in the best practices on BOL:
Use the following guidelines for ordering columns in the CREATE INDEX statements you write from 
the missing indexes feature component output:

List the equality columns first (leftmost in the column list).
List the inequality columns after the equality columns (to the right of equality columns listed).
List the include columns in the INCLUDE clause of the CREATE INDEX statement.
*/
    
--with xmlnamespaces('http://schemas.microsoft.com/sqlserver/2004/07/showplan' as s)

--select top 50 st.text, qp.query_plan, qs.ec as exec_count, qs.tlr as total_reads

--from (

--  select s.sql_handle, s.plan_handle, max(s.execution_count) as ec, max(s.total_logical_reads) as tlr

--  from sys.dm_exec_query_stats as s

--  where s.max_logical_reads > 100

--  group by s.sql_handle, s.plan_handle) as qs

--  cross apply sys.dm_exec_query_plan(qs.plan_handle) as qp

--  cross apply sys.dm_exec_sql_text(qs.sql_handle) as st

--  cross apply (select distinct relop.value('@Index','nvarchar(130)') as IndexRef

--  from qp.query_plan.nodes(

--     N'//s:Batch/s:Statements/s:StmtSimple/s:QueryPlan[1]//

--     s:RelOp[@PhysicalOp = ("Index Scan")]/*[local-name() = ("IndexScan")]/

--     s:Object[@Database = ("[DBNameHere]")

--     and @Table = ("[TableNameHere]")

--     and @Index = ("[IndexNameHere]")]'

--     ) as ro(relop)

--  ) as r    
  
  
  

---- Description:  Return the heavier queries in the procedure cache for whom the optimzer judges 
----               it could use a better index.
----    @CutOff (default=50) - Number of rows to be displayed.
----    @MinReadCost - Minimum IO cost to be considered.
----------------------------------------------------------------------------------------------------


DECLARE		@Table varchar(100)
		, @MinReadCost int
		, @CutOff int

SELECT		@Table = 'DownloadDetail'
		, @MinReadCost = 1000
		, @CutOff = 50	

	DECLARE @DbName varchar(100)
	SELECT	@DbName = QUOTENAME(DB_NAME())
		,@Table = QUOTENAME(@Table)

	SELECT TOP (@CutOff)  
	 SUBSTRING(est.text, eqs.statement_start_offset/2, (CASE WHEN eqs.statement_end_offset = -1 then LEN(CONVERT(nvarchar(max), est.text)) * 2 ELSE eqs.statement_end_offset end - eqs.statement_start_offset)/2) AS [Statement]   
	, OBJECT_NAME(est.objectid) AS [Stored Procedure]  
	, eqp.query_plan  
	, eqs.execution_count   
	, eqs.min_logical_reads, eqs.max_logical_reads, (eqs.total_logical_reads/eqs.execution_count) AS avg_logical_reads  
	, eqs.min_logical_writes, eqs.max_logical_writes, (eqs.total_logical_writes/eqs.execution_count) AS avg_logical_writes  
	, eqs.min_worker_time, eqs.max_worker_time, (eqs.total_worker_time/eqs.execution_count) AS avg_worker_time  
	, eqs.min_elapsed_time, eqs.max_elapsed_time, (eqs.total_elapsed_time/eqs.execution_count) AS avg_elapsed_time   

	FROM  sys.dm_exec_query_stats eqs  
	CROSS APPLY sys.dm_exec_sql_text(eqs.sql_handle) est  
	CROSS APPLY sys.dm_exec_query_plan(eqs.plan_handle) eqp  
	WHERE eqp.query_plan.exist('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";
								//MissingIndexes//MissingIndex[@Database = sql:variable("@DbName") and @Table = sql:variable("@Table")]') = 1
	  AND eqs.max_logical_reads > @MinReadCost  
	ORDER BY avg_logical_reads DESC  
	
	
	
	
	
SELECT
  migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) AS improvement_measure,
  'CREATE INDEX [missing_index_' + CONVERT (varchar, mig.index_group_handle) + '_' + CONVERT (varchar, mid.index_handle)
  + '_' + LEFT (PARSENAME(mid.statement, 1), 32) + ']'
  + ' ON ' + mid.statement
  + ' (' + ISNULL (mid.equality_columns,'')
    + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END
    + ISNULL (mid.inequality_columns, '')
  + ')'
  + ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement,
  migs.*, mid.* -- mid.database_id, mid.[object_id]
FROM sys.dm_db_missing_index_groups mig
INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
WHERE migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) > 10
AND mid.database_id = DB_ID()
AND mid.object_id = object_id(@Table)
ORDER BY migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) DESC
	
 
 
select object_name(object_id), max(rows)
from sys.partitions
group by object_name(object_id)
order by 2 desc



-- ---------------------------------------------------------------------------------------------------
--  Author:  Michael Smith, Minneapolis, MN
--  Date:    2007-08-17
--  
--  Purpose: To report indexes proposed by the database engine that have highest probable user impact.
--    Note that no consideration is given to 'reasonableness' of indexes-- bytes, overall size, total
--    number of indexes on a table, etc.  Intended to provide targeted starting point for holistic 
--    evaluation of indexes.
--  
--  
--  Directions:  Specify running total percent impact threshold and minimum number or results.
--  
--  
--  Many thanks to Itzik Ben-Gan for the query technique and pattern as discussed in his book,
--  Inside SQL Server 2005: T-SQL Querying.  Also, the "impact formula" is taken from SQL Server
--  Books Online [cost * impact * (scans + seeks)].
-- ---------------------------------------------------------------------------------------------------



SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;
GO

DECLARE @percent_lvl  int;
DECLARE @min_rows int;

SET @percent_lvl = 50;
SET @min_rows = 20;


WITH	missing_index_impact AS (
		        SELECT	
				        dm_db_missing_index_groups.index_handle,
				        SUM(
				            (dm_db_missing_index_group_stats.avg_total_user_cost * dm_db_missing_index_group_stats.avg_user_impact *
				                (dm_db_missing_index_group_stats.user_seeks + dm_db_missing_index_group_stats.user_scans))
				            ) AS "total_impact",
				        (100.00 *
				            SUM(dm_db_missing_index_group_stats.avg_total_user_cost * dm_db_missing_index_group_stats.avg_user_impact *
				                (dm_db_missing_index_group_stats.user_seeks + dm_db_missing_index_group_stats.user_scans)) /
                                 SUM(SUM(dm_db_missing_index_group_stats.avg_total_user_cost *
                                    dm_db_missing_index_group_stats.avg_user_impact *
                                    (dm_db_missing_index_group_stats.user_seeks + dm_db_missing_index_group_stats.user_scans))) OVER()
                         ) AS "percent_impact",
				        ROW_NUMBER() OVER(ORDER BY SUM(avg_total_user_cost * avg_user_impact * (user_seeks + user_scans)) DESC ) AS rn
		        FROM	sys.dm_db_missing_index_groups AS dm_db_missing_index_groups
		        JOIN	sys.dm_db_missing_index_group_stats AS dm_db_missing_index_group_stats
		          ON	dm_db_missing_index_groups.index_group_handle = dm_db_missing_index_group_stats.group_handle
		        GROUP
		           BY	dm_db_missing_index_groups.index_handle),
		 agg_missing_index_impact AS (
 		        SELECT	missing_index_impact_1.index_handle,
		                missing_index_impact_1.total_impact,
		                SUM(missing_index_impact_2.total_impact) AS running_total_impact,
		                missing_index_impact_1.percent_impact,
		                SUM(missing_index_impact_2.percent_impact) AS running_total_percent,
		                missing_index_impact_1.rn
		        FROM	missing_index_impact AS missing_index_impact_1
		        JOIN	missing_index_impact AS missing_index_impact_2
		          ON	missing_index_impact_1.rn <= missing_index_impact_2.rn
		        GROUP
		           BY	missing_index_impact_1.index_handle, missing_index_impact_1.total_impact,
		                missing_index_impact_1.percent_impact, missing_index_impact_1.rn
		        HAVING	SUM(missing_index_impact_2.percent_impact) - missing_index_impact_1.percent_impact >= @percent_lvl
			        OR	missing_index_impact_1.rn <= @min_rows
		 ),
		 missing_index_details AS (
	 		    SELECT	dm_db_missing_index_details.index_handle,
			            dm_db_missing_index_details."statement",
			            dm_db_missing_index_details.equality_columns,
			            dm_db_missing_index_details.inequality_columns,
			            dm_db_missing_index_details.included_columns
	            FROM	sys.dm_db_missing_index_details AS dm_db_missing_index_details
		 )
		 
SELECT	agg_missing_index_impact.rn,
		missing_index_details."statement",
		agg_missing_index_impact.running_total_impact,
		agg_missing_index_impact.total_impact,
		agg_missing_index_impact.running_total_percent,
		agg_missing_index_impact.percent_impact,
		missing_index_details.equality_columns,
		missing_index_details.inequality_columns,
		missing_index_details.included_columns
FROM	agg_missing_index_impact
JOIN	missing_index_details
  ON	agg_missing_index_impact.index_handle = missing_index_details.index_handle
ORDER
   BY	agg_missing_index_impact.rn ASC;
