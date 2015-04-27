
DECLARE @TSQL VarChar(8000)
SET		@TSQL = ''
SELECT	@TSQL = @TSQL + 'exec dbasp_ChartData_DBGrowth '''+DatabaseName+''' ,@OutputAsHTML = 1'+CHAR(13)+CHAR(10)
FROM	(
		Select		DISTINCT 
					DatabaseName 
		FROM		dbaadmin.dbo.db_stats_log 
		WHERE		rundate > Getdate()-30 
			AND		DatabaseName NOT IN ('master','model','msdb','tempdb','dbaperf','dbaadmin','systeminfo')
		) Data

SELECT	@TSQL = @TSQL + 'exec dbasp_ChartData_DBGrowth ''SUMMARY'' ,@OutputAsHTML = 1'+CHAR(13)+CHAR(10)

EXEC(@TSQL)



