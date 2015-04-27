use dbacentral
go

SELECT		* 
FROM		dbacentral.dbo.[FileScan_History_ErrorsByDate]
ORDER BY	1  DESC





SELECT		* 
FROM		dbacentral.dbo.[FileScan_Daily_Count_ErrorsByMachine]
ORDER BY	2 DESC
SELECT		* 
FROM		dbacentral.dbo.[FileScan_Daily_Detail_ErrorsByMachine]
ORDER BY	2 DESC





SELECT		* 
FROM		dbacentral.dbo.[FileScan_Daily_Count_ErrorsByCondition]
ORDER BY	2 DESC ,3 DESC

SELECT		* 
FROM		dbacentral.dbo.[FileScan_Daily_Detail_ErrorsByCondition]
ORDER BY	1 ,2,3 DESC




SELECT		top 1000 
		*
FROM		dbo.FileScan_History

WHERE		Machine = 'CRMSQLTEST01'
ORDER BY	EventDateTime desc






SELECT		* 
FROM		dbacentral.dbo.[FileScan_Alerts_NonReportingServers]
ORDER BY	4





--DELETE		[dbaadmin].[dbo].[Filescan_History]
--WHERE		KnownCondition = 'AgentJob-StepFailed'
--	AND	FixData LIKE '%DBA - Filescan AgggImport%'
	
--DELETE		[dbaadmin].[dbo].[Filescan_History]
--WHERE		KnownCondition = 'AgentJob-StepFailed'
--	AND	FixData LIKE '%DBA - Test LogParser%'
	
	
--ALTER VIEW	FileScan_Daily_JobFailures
--AS
--SELECT		TOP 100 PERCENT
--		CASE CONVERT(VarChar(12),EventDateTime,101)
--			WHEN CONVERT(VarChar(12),GETDATE(),101) THEN 'Today'
--			ELSE 'Yesterday' END					AS [DAY]
--		,UPPER(REPLACE(T3.SQLEnv,'production','prod'))			AS [Env]
--		,UPPER([dbaadmin].[dbo].[ReturnWord]
--		 (REPLACE(REPLACE(REPLACE(T1.[Job],'_',' '),'-',' '),'.',' ')
--		 ,1))								AS [JobType]
--		,T1.[Server]
--		,T1.[Job]
--		,T1.[Step]
--		,MIN(EventDateTime)						AS [FirstFail]
--		,MAX(EventDateTime)						AS [LastFail]
--		,count(*)							AS [FailCount]
--FROM		(
--		SELECT		[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Server')	AS [Server]
--				,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Job')	AS [Job]
--				,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Step')	AS [Step]
--				,EventDateTime
--		FROM		[dbaadmin].[dbo].[Filescan_History]
--		WHERE		EventDateTime >= CAST(CONVERT(VarChar(12),GETDATE()-1,101)AS DateTime)
--			AND	KnownCondition = 'AgentJob-StepFailed'
--			AND	[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Step')	 != '(Job outcome)'
--		UNION
--		SELECT		JO.*
--		FROM		(
--				SELECT		[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Server')	AS [Server]
--						,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Job')	AS [Job]
--						,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Step')	AS [Step]
--						,EventDateTime
--				FROM		[dbaadmin].[dbo].[Filescan_History]
--				WHERE		EventDateTime >= CAST(CONVERT(VarChar(12),GETDATE()-1,101)AS DateTime)
--					AND	KnownCondition = 'AgentJob-StepFailed'
--					AND	[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Step')= '(Job outcome)'
--				) JO

--		LEFT JOIN	(
--				SELECT		[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Server')	AS [Server]
--						,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Job')	AS [Job]
--						,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Step')	AS [Step]
--						,EventDateTime
--				FROM		[dbaadmin].[dbo].[Filescan_History]
--				WHERE		EventDateTime >= CAST(CONVERT(VarChar(12),GETDATE()-1,101)AS DateTime)
--					AND	KnownCondition = 'AgentJob-StepFailed'
--					AND	[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Step')	!= '(Job outcome)'
--				)  JS
--			ON	JO.[Server]=JS.[Server]
--			AND	JO.[Job]=JS.[Job]
--			--AND	DATEDIFF(hour,JS.[EventDateTime],JO.[EventDateTime])<2
--			AND	CAST(CONVERT(VarChar(12),JS.[EventDateTime],101)AS DateTime)=CAST(CONVERT(VarChar(12),JO.[EventDateTime],101)AS DateTime)
--		WHERE		JS.[Server] IS NULL
--		)  T1   

--LEFT JOIN	dbo.DBA_ServerInfo T3
--	ON	T3.SQLName = T1.Server	
--GROUP BY	CASE CONVERT(VarChar(12),EventDateTime,101)
--			WHEN CONVERT(VarChar(12),GETDATE(),101) THEN 'Today'
--			ELSE 'Yesterday' END
--		,REPLACE(T3.SQLEnv,'production','prod')
--		,[dbaadmin].[dbo].[ReturnWord] 
--		 (REPLACE(REPLACE(REPLACE(T1.[Job],'_',' '),'-',' '),'.',' ')
--		 ,1)
--		,T1.[Server]
--		,T1.[Job]
--		,T1.[Step]
--ORDER BY	1 Desc,2,8 DESC
--GO


--Select		[JobType]
--		,[ALPHA]
--		,[DEV]
--		,[LOAD]
--		,[PRODUCTION]
--		,[STAGE]
--		,[TEST]
--FROM		(
--		SELECT		[JobType]
--				,[Env]
--				,[FailCount]
--		FROM		[FileScan_Daily_JobFailures]
--		) AS [Data]
--PIVOT		(
--		SUM(FailCount) FOR [Env] IN ([ALPHA],[DEV],[LOAD],[PRODUCTION],[STAGE],[TEST])
--		) AS [PivotTable]


--SELECT		REPLACE(COALESCE([JobType],'TOTAL'),'AGGREGATIONS','_AGGREGATIONS') [JobType]
--		,COALESCE([ALPHA],0) [ALPHA]
--		,COALESCE([DEV],0) [DEV]
--		,COALESCE([LOAD],0) [LOAD]
--		,COALESCE([PRODUCTION],0) [PROD]
--		,COALESCE([STAGE],0) [STAGE]
--		,COALESCE([TEST],0) [TEST]
--		,COALESCE([ALPHA],0)+COALESCE([DEV],0)+COALESCE([LOAD],0)+COALESCE([PRODUCTION],0)+COALESCE([STAGE],0)+COALESCE([TEST],0) [TOTAL] 
--FROM		(
--		Select		DISTINCT 
--				[JobType]				[JobType]
--				,GROUPING([JobType])			[SortField]
--				,SUM([ALPHA])				[ALPHA]
--				,SUM([DEV])				[DEV]
--				,SUM([LOAD])				[LOAD]
--				,SUM([PRODUCTION])			[PRODUCTION]
--				,SUM([STAGE])				[STAGE]
--				,SUM([TEST])				[TEST]
--		FROM		(
--				SELECT		UPPER([JobType]) [JobType]
--						,[Env]
--						,[FailCount]
--				FROM		[FileScan_Daily_JobFailures]
--				) AS [Data]
--		PIVOT		(
--				SUM(FailCount) FOR [Env] IN ([ALPHA],[DEV],[LOAD],[PRODUCTION],[STAGE],[TEST])
--				) AS [PivotTable]
--		GROUP BY	[JobType] WITH CUBE
--		) [Data]
--ORDER BY	[SortField],[JobType]



 --SELECT DISTINCT JobTypes
 --     FROM FileScan_Daily_JobFailures p1

 --    CROSS APPLY ( SELECT DISTINCT '['+JobType + ']' 
 --                    FROM FileScan_Daily_JobFailures p2
 --                   WHERE p2.[Day] = p1.[Day] 
 --                   ORDER BY '['+JobType + ']'  
 --                     FOR XML PATH('') )  D ( JobTypes )
 --     WHERE [DAY] = 'Yesterday'                      

		
--SELECT	DISTINCT QUOTENAME(UPPER(T3.SQLEnv))
--FROM	dbo.Filescan_MachineSource T1
--JOIN	dbo.DBA_ServerInfo T3
--ON T3.SQLName = T1.Machine + CASE T1.Instance WHEN '' THEN '' ELSE '\'+T1.Instance   END

		

--DELETE		[dbaadmin].[dbo].[Filescan_History]
--WHERE		KnownCondition like '%sspi%' 
--	OR	KnownCondition IN ('Firewall detected listening Red Gate','Windows Filtering Platform Blocked Packet')
	
--DELETE		[dbaadmin].[dbo].[Filescan_History]
--WHERE		KnownCondition = 'AgentJob-StepFailed'
--	AND	[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Job') LIKE 'DBA - Test LogParser'

































