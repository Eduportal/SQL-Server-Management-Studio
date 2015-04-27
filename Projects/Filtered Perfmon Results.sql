USE dbaperf
GO
SET QUOTED_IDENTIFIER ON
GO
-- Do not lock anything, and do not get held up by any locks. 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
GO
	

DECLARE @FilterOutlierPercent	INT
	,@FloatRange		INT
SELECT	@FilterOutlierPercent	= 5
	,@FloatRange		= 10

;WITH		[PerfData]
		AS
		(
		SELECT		[object_name]
				,[counter_name]
				,[instance_name]
				,row_number() over (PARTITION BY [object_name],[counter_name],[instance_name] order by [rundate])		AS RowNumber
				,COUNT(*) over (PARTITION BY [object_name],[counter_name],[instance_name])					AS SetCount
				,(@FilterOutlierPercent * COUNT(*) over (PARTITION BY  [object_name],[counter_name],[instance_name]))/100.0	AS OutlierRowCount
				,RANK() OVER (PARTITION BY [object_name],[counter_name],[instance_name] order by [calculated_value])		AS ValueRankAsc
				,RANK() OVER (PARTITION BY [object_name],[counter_name],[instance_name] order by [calculated_value]DESC)	AS ValueRankDesc
				,[rundate] AS [Time]
				,[calculated_value] AS [Value]
		FROM		dbaperf.[dbo].[DMV_PerfmonCounters]
		WHERE		[object_name] NOT IN ('Active Agent Job','sys.sysprocesses:ActiveSPIDs')
		)
		,FloatingAverage
		AS
		(
		SELECT		[PerfData].[object_name]
				,[PerfData].[counter_name]
				,[PerfData].[instance_name]
				,[PerfData].RowNumber
				,AVG([PerfData3].Value)					AS AVG_Value
				,STDEVP([PerfData3].Value)				AS STDEVP_Value
				,AVG([PerfData3].Value)-(STDEVP([PerfData3].Value)*2)	AS AVGMinus2Dev_Value
				,AVG([PerfData3].Value)-STDEVP([PerfData3].Value)	AS AVGMinus1Dev_Value
				,AVG([PerfData3].Value)+STDEVP([PerfData3].Value)	AS AVGPlus1Dev_Value
				,AVG([PerfData3].Value)+(STDEVP([PerfData3].Value)*2)	AS AVGPlus2Dev_Value
		FROM		[PerfData]
		JOIN		(
				SELECT		*
				FROM		[PerfData]
				WHERE		ValueRankAsc	> OutlierRowCount
					AND	ValueRankDesc	> OutlierRowCount
				) [PerfData3]
			ON	[PerfData].[object_name]	= [PerfData3].[object_name]
			AND	[PerfData].[counter_name]	= [PerfData3].[counter_name]
			AND	[PerfData].[instance_name]	= [PerfData3].[instance_name]
			AND	ABS([PerfData].RowNumber - [PerfData3].RowNumber) < @FloatRange
		GROUP BY	[PerfData].[object_name]	
				,[PerfData].[counter_name]
				,[PerfData].[instance_name]
				,[PerfData].RowNumber
		)
SELECT		T1.[object_name]	
		,T1.[counter_name]
		,T1.[instance_name]
		,T1.RowNumber
		,T1.Time
		,T1.Value
		,ABS(Value-AVG_Value)/isnull(nullif(STDEVP_Value,0),1) AS DevsFromAvg
		,CASE
			WHEN T1.Value < T2.AVGMinus2Dev_Value		THEN '0'
			WHEN T1.Value > T2.AVGPlus2Dev_Value		THEN '4'
			WHEN T1.Value < T2.AVGMinus1Dev_Value		THEN '1'
			WHEN T1.Value > T2.AVGPlus1Dev_Value		THEN '3'
			ELSE '2' END AS TREND
		,CASE
			WHEN T1.Value < T2.AVGMinus2Dev_Value		THEN '0'
			WHEN T1.Value > T2.AVGPlus2Dev_Value		THEN '4'
			ELSE NULL END AS TREND_Filtered
		,T2.AVG_Value
		,T2.STDEVP_Value
		,T2.AVGMinus2Dev_Value
		,T2.AVGMinus1Dev_Value
		,T2.AVGPlus1Dev_Value
		,T2.AVGPlus2Dev_Value
FROM		[PerfData] T1
JOIN		[FloatingAverage] T2
	ON	T1.[object_name]	= T2.[object_name]
	AND	T1.[counter_name]	= T2.[counter_name]
	AND	T1.[instance_name]	= T2.[instance_name]
	AND	T1.RowNumber		= T2.RowNumber





-- Do not lock anything, and do not get held up by any locks. 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


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

















;WITH		[PerfData]
		AS
		(
		SELECT		[object_name]
				,[counter_name]
				,[instance_name]
				,[rundate]
				,[cntr_value]
				,[cntr_type]
				,[seconds_between]
				,[calculated_value]
		FROM		dbaperf.[dbo].[DMV_PerfmonCounters]
		WHERE		[object_name] NOT IN ('Active Agent Job','sys.sysprocesses:ActiveSPIDs')
		)
		,CounterDevisors
		AS
		(
		SELECT		[object_name]
				,[counter_name]
				,[instance_name]
				,COUNT(*)/100 AS [Divisor]
		FROM		PerfData			
		GROUP BY	[object_name]
				,[counter_name]
				,[instance_name]
		)
		,PerfDataWithRownumbers
		AS
		(
		SELECT		row_number() over (PARTITION BY [object_name],[counter_name],[instance_name] order by [rundate]) AS rownum	
				,*			
		FROM		PerfData
		)
		,FilteredPerfData
		AS
		(
		SELECT		T1.[object_name]	
				,T1.[counter_name]	
				,T1.[instance_name]
				,row_number() over (PARTITION BY T1.[object_name],T1.[counter_name],T1.[instance_name] order by T1.[rundate]) AS rownum	
				,T1.[rundate]	
				,T1.[cntr_value]
				,T1.[cntr_type]
				,T1.[seconds_between]
				,T1.[calculated_value]	
		FROM		PerfDataWithRownumbers T1
		JOIN		CounterDevisors T2
			ON	T1.[object_name] = T2.[object_name]
			AND	T1.[counter_name] = T2.[counter_name]
			AND	T1.[instance_name] = T2.[instance_name]

		WHERE		rownum % CASE WHEN T2.Divisor < 1 THEN 1 ELSE T2.Divisor END = 0			

		)
		,ReCalcedPerfData
		AS
		(
		SELECT		T1.object_name	
				,T1.counter_name	
				,T1.instance_name	
				,T1.rownum	
				,T1.rundate	
				,T1.cntr_value	
				,T1.cntr_type	
				,COALESCE(DATEDIFF(second,T2.rundate,T1.rundate),T1.seconds_between) [seconds_between]
				,COALESCE(CASE T1.[cntr_type] WHEN 272696576 THEN (T1.[cntr_value]-T2.[cntr_value])/CAST(DATEDIFF(second,T2.rundate,T1.rundate) AS FLOAT) END,T1.calculated_value) [calculated_value]	
		FROM		FilteredPerfData T1
		LEFT JOIN	FilteredPerfData T2
			ON	T1.[object_name] = T2.[object_name]
			AND	T1.[counter_name] = T2.[counter_name]
			AND	T1.[instance_name] = T2.[instance_name]
			AND	T1.[rownum] = T2.[rownum]+1
		)

SELECT		T1.object_name	
		,T1.counter_name	
		,T1.instance_name	
		,T1.rownum	
		,T1.rundate	
		,T1.cntr_value	
		,T1.cntr_type		
		,T1.seconds_between
		,CASE WHEN T1.calculated_value < 0 THEN (SELECT AVG(calculated_value) FROM ReCalcedPerfData 
									WHERE	object_name = T1.object_name
									AND	counter_name = T1.counter_name
									AND	instance_name = T1.instance_name
									AND	rownum IN(T1.rownum-1,T1.rownum+1))
						ELSE T1.calculated_value END calculated_value
FROM		ReCalcedPerfData T1
		
ORDER BY	T1.[object_name]	
		,T1.[counter_name]	
		,T1.[instance_name]	
		,T1.[rundate]			
		
		
		
		
			
			
			
				

