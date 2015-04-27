USE [dbacentral]
GO
ALTER VIEW	dbo.DBA_SQL_LICENSE_COUNTS
AS
WITH		ServerGroups
			AS
			(
			SELECT	1 [Order],'SQL Server 2005 CAL (device)' [GroupName] UNION ALL
			SELECT	2,'SQL Server 2005 CAL (user)' UNION ALL
			SELECT	3,'SQL Server 2008 CAL (device)' UNION ALL
			SELECT	4,'SQL Server Standard 2000 (Per Processor)' UNION ALL
			SELECT	5,'SQL Server Standard 2005 (per Processor)' UNION ALL
			SELECT	6,'SQL Server Standard 2008 R2 (per Processor)' UNION ALL
			SELECT	7,'SQL Server Standard 2008 (per Processor)' UNION ALL
			SELECT	8,'SQL Server Enterprise 2000 (Per Processor)' UNION ALL
			SELECT	9,'SQL Server Enterprise 2005 (per Processor)' UNION ALL
			SELECT	10,'SQL Server Enterprise 2008 (per Processor)' UNION ALL
			SELECT	11,'SQL Server Enterprise 2008 R2 (per Processor)' UNION ALL
			SELECT	12,'SQL Server Standard 2000' UNION ALL
			SELECT	13,'SQL Server Standard 2005' UNION ALL
			SELECT	14,'SQL Server Standard 2008' UNION ALL
			SELECT	15,'SQL Server Standard 2008 R2' UNION ALL
			SELECT	16,'SQL Server Enterprise 2000' UNION ALL
			SELECT	17,'SQL Server Enterprise 2005' UNION ALL
			SELECT	18,'SQL Server Enterprise 2008' UNION ALL
			SELECT	19,'SQL Server Enterprise 2008 R2' UNION ALL
			SELECT	20,'SQL Server Enterprise 2012' UNION ALL
			SELECT	21,'SQL Server Enterprise 2012 (per processor)' UNION ALL
			SELECT	22,'SQL Server Standard 2012' UNION ALL
			SELECT	23,'SQL Server Standard 2012 (per processor)'

			)
			,ServerInfo
			AS
			(
			SELECT		ServerName
						,SQLNAME 
						,SQLEnv
						,DomainName
						,REPLACE(REPLACE(REPLACE(SQL_Version,' (RTM)',''),' (SP1)',''),' (SP2)','') AS SQL_Version
						,SQL_Build
						,SQL_Edition
						,SQL_BitLevel
						,CPU_Physical
						,CPU_Cores
						,CPU_Logical
						,CPU_BitLevel
			FROM		dbacentral.[dbo].[ServerInfo] 
			WHERE		Active = 'Y'
					AND	SQLEnv = 'production'
			)

SELECT		TOP 100 PERCENT
			G.GroupName
			,S.[Count]
			,REPLACE(S.ServerList,',',', ') ServerList
FROM		ServerGroups G
LEFT JOIN	(
			SELECT		'SQL Server ' + SQL_Edition + ' ' + SQL_Version + ' (Per Processor)'				AS [GroupName]
						,SUM(CAST(CPU_Physical AS INT))														AS [Count]
						,dbaadmin.dbo.dbaudf_Concatenate('('+CAST(CPU_Physical AS VarChar(2))+')'+SQLName)	AS [ServerList]
			FROM		ServerInfo
			WHERE		DomainName = 'production' AND SQLName != 'SEAEXSQLMAIL'
			GROUP BY	'SQL Server ' + SQL_Edition + ' ' + SQL_Version + ' (Per Processor)'			
			UNION ALL

			SELECT		'SQL Server ' + SQL_Edition + ' ' + SQL_Version
						,COUNT(DISTINCT ServerName)
						,dbaadmin.dbo.dbaudf_Concatenate(SQLName)
			FROM		ServerInfo
			WHERE		DomainName != 'production' OR SQLName = 'SEAEXSQLMAIL'
			GROUP BY	'SQL Server ' + SQL_Edition + ' ' + SQL_Version
			) S
		ON	S.GroupName = G.GroupName

ORDER BY	G.[Order]
GO

SELECT * FROM dbo.DBA_SQL_LICENSE_COUNTS