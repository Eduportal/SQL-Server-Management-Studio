
--SELECT top 100 deqs.last_execution_time AS [Time],
--dest.TEXT AS [Query],
--decp.query_plan
--,total_elapsed_time / execution_count Avg_elapsed_time
--FROM sys.dm_exec_query_stats AS deqs
--CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
--CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS decp

--ORDER BY 4 desc
--ORDER BY deqs.last_execution_time DESC


--SELECT * FROM sys.dm_exec_query_stats


IF OBJECT_ID('tempdb..#tmp1') IS NOT NULL DROP TABLE #tmp1
IF OBJECT_ID('tempdb..#tmp2') IS NOT NULL DROP TABLE #tmp2
GO

;WITH XMLNAMESPACES ( DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan' )
SELECT  top 100 qp.objectid,
        qp.query_plan,
		x.y.query('.') StmtSimple
INTO #tmp1
FROM sys.dm_exec_query_stats AS cp (NOLOCK)
	CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
	CROSS APPLY query_plan.nodes( 'ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple[1]' ) x(y)
WHERE cp.last_execution_time > DATEADD(HOUR, -2, GETDATE())
OPTION ( RECOMPILE )

SELECT *
FROM #tmp1
GO

;WITH XMLNAMESPACES ( DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan' )
SELECT  top 100 qp.objectid,
        qp.query_plan,
		x.y.value('@Database', 'SYSNAME') [Database],
		x.y.value('@Schema', 'SYSNAME') [Schema],
		x.y.value('@Table', 'SYSNAME') [Table],
		x.y.value('@Column', 'SYSNAME') [Column]
INTO #tmp2
FROM sys.dm_exec_query_stats AS cp (NOLOCK)
	CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
	CROSS APPLY query_plan.nodes( '//ColumnReference' ) x(y)
WHERE cp.last_execution_time > DATEADD(HOUR, -2, GETDATE())
OPTION ( RECOMPILE )

SELECT *
FROM #tmp2