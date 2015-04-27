DROP TABLE dbo.dmv_MissingIndexSnapshot
GO
SELECT		qp.query_plan
		, total_worker_time/execution_count AS AvgCPU 
		, total_elapsed_time/execution_count AS AvgDuration 
		, (total_logical_reads+total_physical_reads)/execution_count AS AvgReads 
		, execution_count 
		, SUBSTRING(st.TEXT, (qs.statement_start_offset/2)+1 , ((CASE qs.statement_end_offset WHEN -1 THEN datalength(st.TEXT) ELSE qs.statement_end_offset END - qs.statement_start_offset)/2) + 1) AS txt 
		, qp.query_plan.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan"; (/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple/QueryPlan/MissingIndexes/MissingIndexGroup/@Impact)[1]' , 'decimal(18,4)') * execution_count AS TotalImpact
		, qp.query_plan.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan"; (/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple/QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Database)[1]' , 'varchar(100)') AS [DATABASE]
		, qp.query_plan.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan"; (/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple/QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex/@Table)[1]' , 'varchar(100)') AS [TABLE]
INTO		dbo.dmv_MissingIndexSnapshot
FROM		sys.dm_exec_query_stats qs
cross apply	sys.dm_exec_sql_text(sql_handle) st
cross apply	sys.dm_exec_query_plan(plan_handle) qp
WHERE		qp.query_plan.exist('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple/QueryPlan/MissingIndexes/MissingIndexGroup/MissingIndex[@Database!="[msdb]"]') = 1
ORDER BY	TotalImpact DESC
GO

SELECT * 
FROM		dmv_MissingIndexSnapshot
WHERE		[DATABASE] != '[wcds]'
WHERE		[Table] IN ('[IndividualJobRoleRel]','[DownloadDetail]')


SELECT		T1.[Table]
		,(T1.[Rank]
		+T2.[Rank]
		+T3.[Rank]
		+T4.[Rank])/4 [Rank]
		
FROM		(
		SELECT		row_number() OVER(ORDER BY max(TotalImpact) desc) as [Rank]
				,[Table]
				,max(TotalImpact) TotalImpact
		FROM		dmv_MissingIndexSnapshot
		GROUP BY	[Table]
		) T1
JOIN		(
		SELECT		row_number() OVER(ORDER BY avg(TotalImpact) desc) as [Rank]
				,[Table]
				,avg(TotalImpact) TotalImpact
		FROM		dmv_MissingIndexSnapshot
		GROUP BY	[Table]
		) T2
	ON	T1.[Table] = T2.[Table]		
JOIN		(
		SELECT		row_number() OVER(ORDER BY SUM(TotalImpact) desc) as [Rank]
				,[Table]
				,SUM(TotalImpact) TotalImpact
		FROM		dmv_MissingIndexSnapshot
		GROUP BY	[Table]
		) T3
	ON	T1.[Table] = T3.[Table]		
JOIN		(
		SELECT		row_number() OVER(ORDER BY min(TotalImpact) desc) as [Rank]
				,[Table]
				,min(TotalImpact) TotalImpact
		FROM		dmv_MissingIndexSnapshot
		GROUP BY	[Table]
		) T4
	ON	T1.[Table] = T4.[Table]		

ORDER BY 2