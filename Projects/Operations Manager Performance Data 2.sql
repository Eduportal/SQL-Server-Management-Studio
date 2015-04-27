DECLARE @cutoffDate datetime 

SELECT @cutoffDate = DATEADD(Hour, -1, GETUTCDATE()) 

SELECT 

pdv.TimeAdded as [TimeAdded], 

pdv.TimeSampled as [Time], 

pdv.SampleValue as [Value], 

mtc.DNSName AS [Server], 

pcv.ObjectName, 

pcv.CounterName, 

pcv.InstanceName 

FROM OperationsManager.[dbo].PerformanceDataAllView pdv with (NOLOCK) 

INNER JOIN OperationsManager.[dbo].PerformanceCounterView pcv on pdv.PerformanceSourceInternalId = pcv.PerformanceSourceInternalId

INNER JOIN OperationsManager.[dbo].BaseManagedEntity bme on pcv.ManagedEntityId = bme.BaseManagedEntityId 

INNER JOIN OperationsManager.[dbo].MT_Computer mtc ON bme.TopLevelHostEntityId = mtc.BaseManagedEntityId 

WHERE (pdv.TimeAdded > @cutoffDate) 

AND (mtc.DNSName LIKE 'g1sqla%%') 

AND (pcv.ObjectName NOT IN ('VM Processor', 'Network Interface', 'LogicalDisk', 'Web Service', 'Memory', 'System', 'Health Service', 'SMTP Server'))

--AND (pdv.SampleValue > 0) 

ORDER BY [Time]



DECLARE		@ServerName		SYSNAME

SELECT		DISTINCT
			--@ServerName = 
			DNSName
			--,UPPER(COALESCE(parsename(DNSName,4),parsename(DNSName,3),parsename(DNSName,2),parsename(DNSName,1))) [ShortName]
FROM		OperationsManager.[dbo].MT_Computer WITH(NOLOCK)
WHERE		DNSName LIKE 'g1sqla%%'

;WITH		PerformanceCountersCTE
			AS
			(
			SELECT		PS.PerformanceSourceInternalId
						,PS.BaseManagedEntityId AS ManagedEntityId
						,REPLACE(REPLACE(STUFF(ObjectName,1,CHARINDEX(':',ObjectName),'MSSQL:'),' :',':'),': ',':') AS ObjectName
						,PC.CounterName
						,PS.PerfmonInstanceName AS InstanceName
			FROM		dbo.PerformanceSource AS PS WITH (NOLOCK)
			JOIN		dbo.Rules AS R WITH(NOLOCK)
					ON	R.RuleId = PS.RuleId
			JOIN		dbo.PerformanceCounter AS PC WITH (NOLOCK)
					ON	PS.PerformanceCounterId = PC.PerformanceCounterId
					AND	R.RuleName Like '%SQLServer%' 
					AND	R.RuleCategory = 'PerformanceCollection'
			)
			,PerformanceData
			AS
			(
			SELECT		ROW_NUMBER() 
						OVER	( 
								PARTITION BY parsename(REPLACE(pcv.ObjectName,':','.'),1)+'.'+pcv.CounterName 
								ORDER BY pdv.TimeSampled DESC 
								) AS [RowNumber]
						,pcv.ObjectName
						,pcv.CounterName
						,pdv.TimeSampled as [Time] 
						,pdv.SampleValue as [Value]
			FROM		OperationsManager.[dbo].PerformanceDataAllView pdv WITH(NOLOCK)
			INNER JOIN	PerformanceCountersCTE pcv WITH(NOLOCK) 
					on	pdv.PerformanceSourceInternalId = pcv.PerformanceSourceInternalId
			INNER JOIN	OperationsManager.[dbo].BaseManagedEntity bme WITH(NOLOCK) 
					on	pcv.ManagedEntityId = bme.BaseManagedEntityId
					AND	bme.IsDeleted = 0 
			INNER JOIN	OperationsManager.[dbo].MT_Computer mtc WITH(NOLOCK) 
					ON	bme.TopLevelHostEntityId = mtc.BaseManagedEntityId 
			WHERE		mtc.DNSName = 'G1SQLA.production.local'
			)
SELECT		[ObjectName]+'.'+[CounterName] [Metric]
			,[Time]
			,[Value]
FROM		PerformanceData
WHERE		[RowNumber] <= 20			
ORDER BY	1,2


