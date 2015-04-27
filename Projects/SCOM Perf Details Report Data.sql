-- Do not lock anything, and do not get held up by any locks. 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE		@FilterOutlierPercent	INT = 5
DECLARE		@FloatRange				INT = 5
DECLARE		@CounterName			VarChar(255) = 'Transactions'+CHAR(13)+CHAR(10)+'sec'


;WITH		[PerfData]
			AS
			(
			SELECT		ServerName	
						,REPLACE(REPLACE(REPLACE(CounterName,CHAR(13)+CHAR(10),' '),'  ',' '),'  ',' ') AS CounterName
						,row_number() over (PARTITION BY ServerName,CounterName order by [Time])	AS RowNumber
						,COUNT(*) over (PARTITION BY ServerName,CounterName)						AS SetCount
						,(@FilterOutlierPercent 
							* COUNT(*) over (PARTITION BY ServerName,CounterName))
							/ 100																	AS OutlierRowCount
						,RANK() OVER (PARTITION BY ServerName,CounterName order by [Value])			AS ValueRankAsc
						,RANK() OVER (PARTITION BY ServerName,CounterName order by [Value]DESC)		AS ValueRankDesc
						,Time	
						,Value
						,Slope
			FROM		dbaperf.dbo.SCOM_BUFFER_ReportData WITH(NOLOCK)
			WHERE		ServerName = 'G1SQLA'
					AND	REPLACE(REPLACE(REPLACE(CounterName,CHAR(13)+CHAR(10),' '),'  ',' '),'  ',' ') = REPLACE(REPLACE(REPLACE(@CounterName,CHAR(13)+CHAR(10),' '),'  ',' '),'  ',' ')
			)
			,FloatingAverage
			AS
			(
			SELECT		[PerfData].ServerName	
						,[PerfData].CounterName
						,[PerfData].RowNumber
						,AVG([PerfData3].Value)				AS AVG_Value
						,STDEVP([PerfData3].Value)			AS STDEVP_Value
						,AVG([PerfData3].Value)
							-(STDEVP([PerfData3].Value)*2)	AS	AVGMinus2Dev_Value
						,AVG([PerfData3].Value)
							-STDEVP([PerfData3].Value)		AS	AVGMinus1Dev_Value
						,AVG([PerfData3].Value)
							+STDEVP([PerfData3].Value)		AS	AVGPlus1Dev_Value
						,AVG([PerfData3].Value)
							+(STDEVP([PerfData3].Value)*2)	AS	AVGPlus2Dev_Value
			FROM		[PerfData]
			JOIN		(
						SELECT		*
						FROM		[PerfData]
						WHERE		ValueRankAsc	> OutlierRowCount
								AND	ValueRankDesc	> OutlierRowCount
						) [PerfData3]
					ON	[PerfData].ServerName	= [PerfData3].ServerName
					AND	[PerfData].CounterName	= [PerfData3].CounterName
					AND ABS([PerfData].RowNumber - [PerfData3].RowNumber) < @FloatRange
			GROUP BY	[PerfData].ServerName	
						,[PerfData].CounterName
						,[PerfData].RowNumber
			)
SELECT		T1.ServerName	
			,T1.CounterName	
			,T1.RowNumber
			,T1.Time
			,T1.Value
			,T1.Slope
			,ABS(Value-AVG_Value)/isnull(nullif(STDEVP_Value,0),1)		AS DevsFromAvg
			,CASE
				WHEN T1.Value < T2.AVGMinus2Dev_Value		THEN '0'
				WHEN T1.Value > T2.AVGPlus2Dev_Value		THEN '4'
				WHEN T1.Value < T2.AVGMinus1Dev_Value		THEN '1'
				WHEN T1.Value > T2.AVGPlus1Dev_Value		THEN '3'
				ELSE '2' END AS TREND
			,CAST(ABS(Value-AVG_Value)/isnull(nullif(STDEVP_Value,0),1)/2 AS INT) AS TREND_Filtered
			,T2.AVG_Value
			,T2.STDEVP_Value
			,T2.AVGMinus2Dev_Value
			,T2.AVGMinus1Dev_Value
			,T2.AVGPlus1Dev_Value
			,T2.AVGPlus2Dev_Value
FROM		[PerfData] T1
JOIN		[FloatingAverage] T2
		ON	T1.ServerName = T2.ServerName
		AND	T1.CounterName = T2.CounterName
		AND T1.RowNumber = T2.RowNumber
			
		