
-- DB/Server Lookup

SELECT		DISTINCT
		UPPER(T1.DBName) DBName
		,UPPER(REPLACE(COALESCE(T2.SQLEnv,'Unknown'),'production','prod'))   ENVname
		,UPPER(T1.SQLName)   SQLName
		,T2.port
		,UPPER(T1.SQLName)+ ',' + CAST(T2.port AS VARCHAR(10)) Link
FROM		dbo.DBA_DBInfo T1
LEFT JOIN	dbo.DBA_ServerInfo T2
	ON	T1.SQLName=T2.SQLName
WHERE		T2.ACTIVE = 'Y'	
ORDER BY	1,2,3


SELECT		TOP 25
		KnownCondition	AS [KnownCondition]
		,COUNT(DISTINCT FixData) AS [UniqueCount]
FROM		[dbaadmin].[dbo].[Filescan_History] T1  WITH(NOLOCK)
WHERE		CAST(CONVERT(VARCHAR(12),EventDateTime,101)AS DATETIME) 
		= CAST(CONVERT(VarChar(12),GETDATE()-1,101)AS DateTime)
GROUP BY	KnownCondition
HAVING		COUNT(DISTINCT FixData) > 0
ORDER BY	2 desc