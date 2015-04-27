declare @top_n_plans int;
set @top_n_plans = 25;


;with XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' as sql)
select		top(@top_n_plans)
		qst.text as sql_text, qp.query_plan
		, qst.statement_id
		, qst.statement_text as select_statement
		, qps2.statement_optimization_level
		, qps2.statement_optimization_early_abort_reason
		, (
		  select	sum(ro.SubTreeCost.value(N'@EstimatedTotalSubtreeCost', 'float'))
		  from		qp.query_plan.nodes(N'//sql:Batch/sql:Statements/sql:StmtSimple/sql:QueryPlan[1]/sql:RelOp[1]') as ro(SubTreeCost)		  
		  ) as Totalcost
		, qps2.statement_sub_tree_cost
		, qst.creation_time
		, qst.last_execution_time
		, qst.execution_count
		, qst.total_elapsed_time
		, qst.last_elapsed_time
		, qst.min_elapsed_time
		, qst.max_elapsed_time
		, qst.total_worker_time
		, qst.last_worker_time
		, qst.min_worker_time
		, qst.max_worker_time
		, qst.total_physical_reads
		, qst.last_physical_reads
		, qst.min_physical_reads
		, qst.max_physical_reads
		, qst.total_logical_writes
		, qst.last_logical_writes
		, qst.min_logical_writes
		, qst.max_logical_writes
		, qst.total_logical_reads
		, qst.last_logical_reads
		, qst.min_logical_reads
		, qst.max_logical_reads
		, qst.total_clr_time
		, qst.last_clr_time
		, qst.min_clr_time
		, qst.max_clr_time
		, qst.sql_handle
		, qst.plan_handle
  from		(
		select		*
				, substring(st.text, (qs.statement_start_offset/2)+1
				, ((case qs.statement_end_offset
					when -1 then datalength(st.text)
					else qs.statement_end_offset
					end - qs.statement_start_offset)/2) + 1) as statement_text
				, ROW_NUMBER() OVER(PARTITION BY qs.plan_handle ORDER BY qs.statement_start_offset) as statement_id
		from		sys.dm_exec_query_stats as qs
		cross apply	sys.dm_exec_sql_text(qs.sql_handle) as st
		) as qst
 cross apply	sys.dm_exec_query_plan (qst.plan_handle) as qp
 cross apply	(
		-- Since sys.dm_exec_query_stats doesn't have statement id,
		-- we just sort the actual statement id from showplan for
		-- SELECT statements and join them with similar sequence number generated based
		-- on the statement start offset in sys.dm_exec_query_stats.
		-- This allows us to match the row from showplan with that of the query stats.
		-- This is a problem for batches containing multiple SELECT statements
		-- and hence this solution.
		select		ROW_NUMBER() OVER(ORDER BY qps1.statement_id) as rel_statement_id
				, qps1.statement_optimization_level
				, qps1.statement_sub_tree_cost
				, qps1.statement_optimization_early_abort_reason
		from		(
				select		sel.StmtSimple.value('@StatementId', 'int')				AS statement_id
						, sel.StmtSimple.value('@StatementSubTreeCost', 'float')		AS statement_sub_tree_cost
						, sel.StmtSimple.value('@StatementOptmLevel' , 'varchar(30)')		AS statement_optimization_level
						, sel.StmtSimple.value('@StatementOptmEarlyAbortReason', 'varchar(30)')	AS statement_optimization_early_abort_reason
				from		qp.query_plan.nodes(N'//sql:Batch/sql:Statements/sql:StmtSimple[@StatementType = "SELECT"]') as sel(StmtSimple)
				) qps1
		) qps2
 where		qps2.rel_statement_id = qst.statement_id
	and	qst.text like '%WedAgreementsGet%'				/* can be used to filter only particular statemetns */
 order by	Totalcost desc
		, qst.plan_handle
		, qst.statement_id;
		
		
		
--select		(
--		select	sum(ro.SubTreeCost.value(N'@EstimatedTotalSubtreeCost', 'float'))
--		from	qp.query_plan.nodes(N'//sql:Batch/sql:Statements/sql:StmtSimple/sql:QueryPlan[1]/sql:RelOp[1]') as ro(SubTreeCost)		  
--		) as Totalcost
--		,*

SELECT		REPLACE(REPLACE(REPLACE(QPT.query_plan,'&#xd;',CHAR(13)),'&#xa;',CHAR(10)),'&#x9;','	')
FROM		sys.dm_exec_query_stats qs
CROSS APPLY	sys.dm_exec_sql_text (qs.[sql_handle]) AS qt
cross apply	sys.dm_exec_query_plan (qs.plan_handle) as qp
CROSS APPLY	sys.dm_exec_text_query_plan(qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) QPT
WHERE		qt.objectid = 209487875  
ORDER BY	total_elapsed_time DESC


SELECT		REPLACE(REPLACE(REPLACE(QPT.query_plan,'&#xd;','	'),'&#xa;','	'),'&#x9;','	')
FROM		sys.dm_exec_query_stats qs
CROSS APPLY	sys.dm_exec_sql_text (qs.[sql_handle]) AS qt
cross apply	sys.dm_exec_query_plan (qs.plan_handle) as qp
CROSS APPLY	sys.dm_exec_text_query_plan(qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) QPT
WHERE		qt.objectid = 209487875  
ORDER BY	total_elapsed_time DESC   