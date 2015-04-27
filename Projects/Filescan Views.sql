
CREATE VIEW	[FileScan_LastSessionResults]
AS
Select		Top 1
		SessionResults
FROM		dbo.Filescan_AggSession
ORDER BY	RunDate	 Desc
GO

CREATE VIEW	[FileScan_History_ErrorsByDate]
AS
SELECT		CAST(CONVERT(VarChar(12),EventDateTime,101)AS DateTime)	EventDateTime
		,count(DISTINCT COALESCE(FixData,LEFT(Message,50)))	UniqueErrorCount
		,count(*)						TotalErrorCount
FROM		[dbaadmin].[dbo].[Filescan_History]
WHERE		EventDateTime >= GetDate()-30
GROUP BY	CAST(CONVERT(VarChar(12),EventDateTime,101)AS DateTime)
GO

CREATE VIEW	[FileScan_Daily_ErrorsByMachine]
AS
SELECT		TOP 100 PERCENT
		Machine	+ CASE WHEN Instance > '' THEN '\'+Instance ELSE '' END	AS [Server]
		,count(*) As ErrorCount
FROM		[dbaadmin].[dbo].[Filescan_History]
WHERE		EventDateTime >= GetDate()-1
GROUP BY	Machine
		,Instance
ORDER BY	2  desc
GO

CREATE VIEW	[FileScan_Daily_ErrorsByCondition]
AS
SELECT		DISTINCT
		KnownCondition
		,count(DISTINCT COALESCE(FixData,LEFT(Message,50))) UniqueErrorCount
		,count(*)  As TotalErrorCount
FROM		[dbaadmin].[dbo].[Filescan_History]
WHERE		EventDateTime >= GetDate()-1
GROUP BY	KnownCondition
GO

CREATE VIEW	[FileScan_Alerts_NonReportingServers]
AS
SELECT	[SourceType]
	,[Machine]
	,[Instance]
	,[LastReported]
	, RIGHT('000' + CAST(DATEDIFF(Minute,[LastReported],getdate())/60 AS VarChar(10)),3)
	+ ':'
	+ RIGHT('00' + CAST(DATEDIFF(Minute,[LastReported],getdate()) - ((DATEDIFF(Minute,[LastReported],getdate())/60)*60) AS VarChar(10)),2) [HHH:MM Since Last Report]
  FROM [dbaadmin].[dbo].[Filescan_MachineSource]
WHERE  DATEDIFF(Minute,[LastReported],getdate()) > 15