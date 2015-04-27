USE dbaperf
GO
;WITH		PerfData
			AS
			(
			SELECT		TOP 100 PERCENT
						row_number() over (PARTITION BY ServerName,CounterName order by [Time]) as RowNumber
						,*
			FROM		dbaperf.dbo.SCOM_BUFFER_ReportData
			)
			, Linear
			AS
			(			
			SELECT		ServerName
						,CounterName
						,COUNT(*)	AS CountPeriods
						,MIN(Value) AS Min_Value	
						,MAX(Value)	AS Max_Value
						,dbaadmin.dbo.Linear(RowNumber,Value) AS Data
			FROM		[PerfData]		
			GROUP BY	ServerName
						,CounterName			
			)			
			,BestFit
			AS
			(
			SELECT		ServerName
						,CounterName
						,Data.value('data(/dws/@bestfit)[1]','nvarchar(255)') AS [RegressionType]
			FROM		Linear
			)
			,Results
			AS
			(
			SELECT		T1.*
						,T2.CountPeriods
						,T2.Min_Value
						,T2.Max_Value
						,(T2.Max_Value+T2.Min_Value)/2 AS Mid_Value
						,T2.Data
						,T3.RegressionType
						, CASE T3.[RegressionType]
							WHEN 'linear'		THEN T2.Data.value('data(/dws/linear/@A)[1]','nvarchar(2048)')
							WHEN 'exponential'	THEN T2.Data.value('data(/dws/exponential/@A)[1]','nvarchar(2048)')
							WHEN 'logarithmic'	THEN T2.Data.value('data(/dws/logarithmic/@A)[1]','nvarchar(2048)')
							WHEN 'power'		THEN T2.Data.value('data(/dws/power/@A)[1]','nvarchar(2048)')
							ELSE NULL END AS [A]
						, CASE T3.[RegressionType]
							WHEN 'linear'		THEN T2.Data.value('data(/dws/linear/@b)[1]','nvarchar(2048)')
							WHEN 'exponential'	THEN T2.Data.value('data(/dws/exponential/@b)[1]','nvarchar(2048)')
							WHEN 'logarithmic'	THEN T2.Data.value('data(/dws/logarithmic/@b)[1]','nvarchar(2048)')
							WHEN 'power'		THEN T2.Data.value('data(/dws/power/@b)[1]','nvarchar(2048)')
							ELSE NULL END AS [B]
			FROM		PerfData T1
			JOIN		Linear T2	
					ON	T1.ServerName = T2.ServerName
					AND	T1.CounterName = T2.CounterName
			JOIN		BestFit T3	
					ON	T1.ServerName = T3.ServerName
					AND	T1.CounterName = T3.CounterName
			)

UPDATE		T1
	SET		Slope = T2.Slope

FROM		dbaperf.dbo.SCOM_BUFFER_ReportData T1
JOIN		(
			SELECT		ServerName
						,CounterName
						,Time
						,MAX(COALESCE(Value,0)) AS [Value]
						,MAX(COALESCE(Mid_value-(Min_Value+(CAST([B] AS Float)*(CountPeriods/2))-CAST([B] AS Float))
						+ Min_Value+(CAST([B] AS Float)*RowNumber)-CAST([B] AS Float),0)) AS [Slope]
			FROM		Results
			WHERE		Min_Value != Max_Value
			GROUP BY	ServerName
						,CounterName
						,Time
			) T2
	ON		T2.ServerName = T1.ServerName
		AND T2.CounterName = T1.CounterName
		AND T2.Time = T1.Time
WHERE	T1.Slope != T2.Slope
			
--MERGE INTO	dbaperf.dbo.SCOM_BUFFER_ReportData	AS Target		
--USING		(

--SELECT		*
--FROM		dbaperf.dbo.SCOM_BUFFER_ReportData T1
--JOIN		(
--			SELECT		ServerName
--						,CounterName
--						,Time
--						,MAX(COALESCE(Value,0)) AS [Value]
--						,MAX(COALESCE(Mid_value-(Min_Value+(CAST([B] AS Float)*(CountPeriods/2))-CAST([B] AS Float))
--						+ Min_Value+(CAST([B] AS Float)*RowNumber)-CAST([B] AS Float),0)) AS [Slope]
--			FROM		Results
--			WHERE		Min_Value != Max_Value
--			GROUP BY	ServerName
--						,CounterName
--						,Time
--			) T2
--	ON		T2.ServerName = T1.ServerName
--		AND T2.CounterName = T1.CounterName
--		AND T2.Time = T1.Time
			
--			) AS Source
--		ON	(			
--			Source.ServerName = Target.ServerName
--		AND Source.CounterName = Target.CounterName
--		AND Source.Time = Target.Time
--			)
--WHEN MATCHED THEN
--	UPDATE SET Slope = Source.Slope
--WHEN NOT MATCHED THEN
--	INSERT	(ServerName,CounterName,Time,Value,Slope)
--	VALUES	(Source.ServerName,Source.CounterName,Source.Time,Source.Value,Source.Slope)
--	OUTPUT	inserted.*, $action, deleted.Slope;


--SELECT		ServerName
--			,CounterName
--			,Time
--			,COUNT(*)
--FROM		dbaperf.dbo.SCOM_BUFFER_ReportData
--GROUP BY	ServerName
--			,CounterName
--			,Time
--ORDER BY	3 desc			