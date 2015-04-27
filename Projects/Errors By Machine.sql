

--SELECT		TOP 100 PERCENT
--		CASE CONVERT(VarChar(12),T1.EventDateTime,101)
--			WHEN CONVERT(VarChar(12),GETDATE(),101) THEN 'Today'
--			ELSE 'Yesterday' END					AS [DAY]
--		,UPPER(REPLACE(COALESCE(T3.SQLEnv,T2.SQLEnv,'Unknown'),'production','prod'))			AS [Env]
--		,T1.Machine + CASE	WHEN T1.Instance > '' 
--					THEN '\' + T1.Instance 
--					ELSE '' 
--					END					AS [Server]
--		,T1.EventDateTime
--		,count(*)							AS [FailCount]
--FROM		[dbaadmin].[dbo].[Filescan_History] T1  WITH(NOLOCK)
--LEFT JOIN	dbo.DBA_ServerInfo T2
--	ON	T2.ServerName = T1.Machine
--LEFT JOIN	dbo.DBA_ServerInfo T3
--	ON	T3.SQLName = T1.Machine + CASE WHEN T1.Instance > '' THEN '\' + T1.Instance ELSE '' END
--WHERE		T1.EventDateTime >= CAST(CONVERT(VarChar(12),GETDATE()-1,101)AS DateTime)
--GROUP BY	CASE CONVERT(VarChar(12),T1.EventDateTime,101)
--			WHEN CONVERT(VarChar(12),GETDATE(),101) THEN 'Today'
--			ELSE 'Yesterday' END
--		,UPPER(REPLACE(COALESCE(T3.SQLEnv,T2.SQLEnv,'Unknown'),'production','prod'))
--		,T1.Machine + CASE WHEN T1.Instance > '' THEN '\' + T1.Instance ELSE '' END
--		,T1.EventDateTime
--ORDER BY	1 Desc,2,5 DESC

--CREATE VIEW	FileScan_Daily_Count_ErrorsByCondition
--AS
--SELECT		TOP 100 PERCENT
--		CASE CONVERT(VarChar(12),T1.EventDateTime,101)
--			WHEN CONVERT(VarChar(12),GETDATE(),101) THEN 'Today'
--			ELSE 'Yesterday' END							AS [DAY]
--		,UPPER(REPLACE(COALESCE(T3.SQLEnv,T2.SQLEnv,'Unknown'),'production','prod'))	AS [Env]
--		,T1.Machine + CASE	WHEN T1.Instance > '' 
--					THEN '\' + T1.Instance 
--					ELSE '' 
--					END							AS [Server]
--		,KnownCondition									AS [KnownCondition]
--		,SourceType
--		,FixData
--		,Message
--		,T1.EventDateTime
--FROM		[dbaadmin].[dbo].[Filescan_History] T1  WITH(NOLOCK)
--LEFT JOIN	dbo.DBA_ServerInfo T2
--	ON	T2.ServerName = T1.Machine
--LEFT JOIN	dbo.DBA_ServerInfo T3
--	ON	T3.SQLName = T1.Machine + CASE WHEN T1.Instance > '' THEN '\' + T1.Instance ELSE '' END
--WHERE		T1.EventDateTime >= CAST(CONVERT(VarChar(12),GETDATE()-1,101)AS DateTime)
--	AND	T1.KnownCondition = 'Login Failed'
--ORDER BY	1,2,3,4	


SELECT		DISTINCT T1.KnownCondition
FROM		[dbaadmin].[dbo].[Filescan_History] T1 WITH(NOLOCK)
LEFT JOIN	dbo.DBA_ServerInfo T2
	ON	T2.ServerName = T1.Machine
LEFT JOIN	dbo.DBA_ServerInfo T3
	ON	T3.SQLName = T1.Machine + CASE WHEN T1.Instance > '' THEN '\' + T1.Instance ELSE '' END

WHERE		T1.EventDateTime >= CAST(CONVERT(VarChar(12),GETDATE()-1,101)AS DateTime)


CREATE VIEW	FileScan_Daily_HistoricalTotalCount
AS
SELECT		TOP 100 PERCENT
		UPPER(REPLACE(COALESCE(T3.SQLEnv,T2.SQLEnv,'Unknown'),'production','prod'))	AS [Env]
		,CAST(CONVERT(VarChar(12),T1.EventDateTime,101) AS DATETIME)			AS [EventDate]
		,COUNT(*)									AS [ErrorCount]
		,COUNT(DISTINCT FixData)							AS [UniqueCount]
FROM		[dbaadmin].[dbo].[Filescan_History] T1  WITH(NOLOCK)
LEFT JOIN	dbo.DBA_ServerInfo T2
	ON	T2.ServerName = T1.Machine
LEFT JOIN	dbo.DBA_ServerInfo T3
	ON	T3.SQLName = T1.Machine + CASE WHEN T1.Instance > '' THEN '\' + T1.Instance ELSE '' END
GROUP BY	UPPER(REPLACE(COALESCE(T3.SQLEnv,T2.SQLEnv,'Unknown'),'production','prod'))
		,CAST(CONVERT(VarChar(12),T1.EventDateTime,101) AS DATETIME)
ORDER BY	1,2


CREATE VIEW	FileScan_Daily_Count_ErrorsByMachine
AS
SELECT		TOP 100 PERCENT
		CASE CONVERT(VarChar(12),T1.EventDateTime,101)
			WHEN CONVERT(VarChar(12),GETDATE(),101) THEN 'Today'
			ELSE 'Yesterday' END							AS [DAY]
		,UPPER(REPLACE(COALESCE(T3.SQLEnv,T2.SQLEnv,'Unknown'),'production','prod'))	AS [Env]
		,T1.Machine + CASE	WHEN T1.Instance > '' 
					THEN '\' + T1.Instance 
					ELSE '' 
					END							AS [Server]
		,COUNT(*)									AS [ErrorCount]
		,COUNT(DISTINCT FixData)							AS [UniqueCount]
FROM		[dbaadmin].[dbo].[Filescan_History] T1  WITH(NOLOCK)
LEFT JOIN	dbo.DBA_ServerInfo T2
	ON	T2.ServerName = T1.Machine
LEFT JOIN	dbo.DBA_ServerInfo T3
	ON	T3.SQLName = T1.Machine + CASE WHEN T1.Instance > '' THEN '\' + T1.Instance ELSE '' END
WHERE		T1.EventDateTime >= CAST(CONVERT(VarChar(12),GETDATE()-1,101)AS DateTime)
GROUP BY	CASE CONVERT(VarChar(12),T1.EventDateTime,101)
			WHEN CONVERT(VarChar(12),GETDATE(),101) THEN 'Today'
			ELSE 'Yesterday' END
		,UPPER(REPLACE(COALESCE(T3.SQLEnv,T2.SQLEnv,'Unknown'),'production','prod'))
		,T1.Machine + CASE	WHEN T1.Instance > '' 
					THEN '\' + T1.Instance 
					ELSE '' 
					END
ORDER BY	1,2,5 desc


 dbo.FileScan_Daily_Detail_ErrorsByCondition
 dbo.FileScan_Daily_Detail_ErrorsByMachine















--SELECT DISTINCT UPPER(CASE WHEN JobType = 'APPL' AND Env = 'PROD' THEN 'APPL_PROD' ELSE JobType END) 
--FROM FileScan_Daily_JobFailures WITH(NOLOCK)



--SELECT DISTINCT JobTypes
--      FROM FileScan_Daily_JobFailures p1

--     CROSS APPLY ( SELECT DISTINCT '['+UPPER(CASE WHEN JobType = 'APPL' AND Env = 'PROD' THEN 'APPL_PROD' ELSE JobType END) + ']' 
--                     FROM FileScan_Daily_JobFailures p2
--                    WHERE p2.[Day] = p1.[Day] 
--                    ORDER BY '['+UPPER(CASE WHEN JobType = 'APPL' AND Env = 'PROD' THEN 'APPL_PROD' ELSE JobType END) + ']'  
--                      FOR XML PATH('') )  D ( JobTypes )
--      WHERE [DAY] = @YesterdayOrToday

DECLARE @YesterdayOrToday VARCHAR(50)
SET	@YesterdayOrToday = 'YESTERDAY'

SELECT		REPLACE(COALESCE([JobType],'TOTAL'),'AGGREGATIONS','_AGGREGATIONS') [JobType]
		,COALESCE([ALPHA],0) [ALPHA]
		,COALESCE([DEV],0) [DEV]
		,COALESCE([LOAD],0) [LOAD]
		,COALESCE([PROD],0) [PROD]
		,COALESCE([STAGE],0) [STAGE]
		,COALESCE([TEST],0) [TEST]
		,COALESCE([ALPHA],0)+COALESCE([DEV],0)+COALESCE([LOAD],0)+COALESCE([PROD],0)+COALESCE([STAGE],0)+COALESCE([TEST],0) [TOTAL] 
FROM		(
		Select		DISTINCT 
				[JobType]				[JobType]
				,GROUPING([JobType])			[SortField]
				,SUM([ALPHA])				[ALPHA]
				,SUM([DEV])				[DEV]
				,SUM([LOAD])				[LOAD]
				,SUM([PROD])			[PROD]
				,SUM([STAGE])				[STAGE]
				,SUM([TEST])				[TEST]
		FROM		(
				SELECT		UPPER([JobType]) [JobType]
						,[Env]
						,[FailCount]
				FROM		[FileScan_Daily_JobFailures]
				WHERE [Day] = @YesterdayOrToday
				) AS [Data]
		PIVOT		(
				SUM(FailCount) FOR [Env] IN ([ALPHA],[DEV],[LOAD],[PROD],[STAGE],[TEST])
				) AS [PivotTable]
		GROUP BY	[JobType] WITH CUBE
		) [Data]
ORDER BY	[SortField],[JobType]