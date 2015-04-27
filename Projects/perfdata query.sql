-- Do not lock anything, and do not get held up by any locks. 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
DECLARE @ServerName sysname
SET @ServerName = 'g1sqla'
;WITH		PerfData
			AS
			(
			SELECT		ServerName	
						,CounterName
						,REPLACE(REPLACE(REPLACE(CounterName,CHAR(13)+CHAR(10),' '),'  ',' '),'  ',' ') AS CleanCounterName
						,Time	
						,Value
						,Slope
			FROM		dbaperf.dbo.SCOM_BUFFER_ReportData WITH(NOLOCK)
			WHERE		ServerName = LEFT(@ServerName,CHARINDEX('\',@ServerName+'\')-1)
			--	AND	Time >= CAST(CONVERT(VarChar(12),Getdate()-5,101)AS DateTime)
			)
			,CounterDevisors
			AS
			(
			SELECT		ServerName
						,CleanCounterName
						,COUNT(*)/100 Divisor
			FROM		PerfData			
			GROUP BY	ServerName
						,CleanCounterName
			)
			,PerfDataWithRownumbers
			AS
			(
			SELECT		ROW_NUMBER() OVER (PARTITION BY ServerName,CleanCounterName ORDER BY Time) AS rownum	
						,*			
			FROM		PerfData
			)
SELECT		T1.ServerName	
			,T1.CounterName	
			,T1.CleanCounterName	
			,T1.Time	
			,T1.Value	
			,T1.Slope
FROM		PerfDataWithRownumbers T1
JOIN		CounterDevisors T2
		ON	T1.ServerName = T2.ServerName
		AND T1.CleanCounterName = T2.CleanCounterName
WHERE		rownum % CASE WHEN T2.Divisor < 1 THEN 1 ELSE T2.Divisor END = 0			
ORDER BY	ServerName,CleanCounterName,Time
