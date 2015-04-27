;WITH		PerfData
			AS
			(
			SELECT		TOP 100 PERCENT
						row_number() over (PARTITION BY ServerName,CounterName order by [Time]) as RowNumber
						,*
			FROM		dbaperf.dbo.dbaudf_ReturnScommPerfCounters	(
									/* SERVER LIST  */					'G1SQLA,G1SQLB,SEADCPCSQLA,SEADCSHSQLA,SEADCSQLC01A,SEADCSQLWVA,SEADCSQLWVB,SEAEXSQLMAIL,SEAFRESQLBOA,SEAPDWDCSQLD0A,SEAPDWDCSQLP0A,SEAPEDSQL0A,SEAPSQLDBA01,SEAPSQLDIST0A,SEAPTRCSQLA,SQLDEPLOYER01,SQLDEPLOYER02,SQLDEPLOYER04,SQLDEPLOYER05'
									/* COUNTER LIST */					,'Logins/sec,User Connections,Number of Deadlocks/sec,Buffer cache hit ratio,SQL Re-Compilations/sec,SQL SENDs/sec,Rows written,Rows read,Broker Transaction Rollbacks,Open Connection Count,Tasks Aborted/sec,Stored Procedures Invoked/sec,Lock Requests/sec,Transactions/sec,Message Fragment Sends/sec,Enqueued Transport Msgs/sec,Buffers spooled,Enqueued Messages/sec,Tasks Started/sec,SQL Compilations/sec,Task Limit Reached,Task Limit Reached/sec,Lock Timeouts/sec,Send I/Os/sec,Message Fragment Receives/sec,Lock Waits/sec,Receive I/Os/sec,SQL RECEIVEs/sec'
																	)
			--WHERE		CounterName = 'Lock Requests/sec'--'User Connections'
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
INSERT INTO	SCOM_BUFFER_ReportData			
SELECT		ServerName
			,CounterName
			,Time
			,COALESCE(Value,0) AS [Value]
			,COALESCE(Mid_value-(Min_Value+(CAST([B] AS Float)*(CountPeriods/2))-CAST([B] AS Float))
			+ Min_Value+(CAST([B] AS Float)*RowNumber)-CAST([B] AS Float),0) AS [Slope]
FROM		Results
WHERE		Min_Value != Max_Value
ORDER BY	1,2,3