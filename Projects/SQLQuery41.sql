--CREATE VIEW	[dbo].[FileScan_Daily_Count_ErrorsByCondition]
AS
SELECT		TOP 100 PERCENT
		CASE CONVERT(VarChar(12),T1.EventDateTime,101)
			WHEN CONVERT(VarChar(12),GETDATE(),101) THEN 'Today'
			ELSE 'Yesterday' END							AS [DAY]
		,UPPER(REPLACE(COALESCE(T3.SQLEnv,T2.SQLEnv,'Unknown'),'production','prod'))	AS [Env]
		,KnownCondition									AS [KnownCondition]
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
		,KnownCondition
ORDER BY	1,2,5 desc
GO


SELECT		T1.Machine + CASE WHEN T1.Instance > '' THEN '\' + T1.Instance ELSE '' END	AS [Server]
		,COUNT(DISTINCT FixData)							AS [UniqueCount]
FROM		[dbaadmin].[dbo].[Filescan_History] T1  WITH(NOLOCK)
WHERE		CAST(CONVERT(VARCHAR(12),EventDateTime,101)AS DATETIME) 
		= CAST(CONVERT(VarChar(12),GETDATE()-1,101)AS DateTime)
GROUP BY	T1.Machine + CASE WHEN T1.Instance > '' THEN '\' + T1.Instance ELSE '' END
ORDER BY	2 desc
GO

SELECT		CAST(CONVERT(VARCHAR(12),EventDateTime,101)AS DATETIME) AS [EventDate]	
		,COUNT(DISTINCT FixData) AS [UniqueCount]
FROM		[dbaadmin].[dbo].[Filescan_History] T1  WITH(NOLOCK)
WHERE		EventDateTime< CAST(CONVERT(VarChar(12),GETDATE(),101)AS DateTime)
GROUP BY	CAST(CONVERT(VARCHAR(12),EventDateTime,101)AS DATETIME)
ORDER BY	1 desc

