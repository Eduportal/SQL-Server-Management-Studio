USE [dbaadmin]
GO

/****** Object:  View [dbo].[DBA_DashBoard_ActiveEnvironment]    Script Date: 03/22/2010 11:28:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[DBA_DashBoard_ActiveEnvironment]
AS
SELECT	T1.[Environment] 
	,T2.[Servers]
	,T2.[SQL Instances]
	,T1.[Distinct Databases]
	,T1.[Databases]
	,[ordertbl].[ord] [OrderHelper]
FROM	(
	SELECT [ENVname] [Environment]
		,COUNT(*) [Databases]
		,count(distinct DBName) [Distinct Databases]
	  FROM [dbaadmin].[dbo].[DBA_DBInfo] DI
	  JOIN dbo.DBA_ServerInfo AS SI 
	  ON DI.SQLName = SI.SQLName
	WHERE si.Active = 'Y'
	  GROUP BY [ENVname]
	) T1
JOIN	(	
	SELECT	SQLEnv [Environment]
		,count(*) [SQL Instances]
		,count(distinct ServerName) [Servers]

	FROM  dbo.DBA_ServerInfo 
	WHERE Active = 'Y'
	GROUP BY SQLEnv
	) T2
ON T1.[Environment] = T2.[Environment]	
JOIN	(
		SELECT 'alpha' [Environment],'1' [ord]
		UNION ALL
		SELECT 'dev','2'
		UNION ALL
		SELECT 'test','3'
		UNION ALL
		SELECT 'load','4'
		UNION ALL
		SELECT 'stage','5'
		UNION ALL
		SELECT 'staging','6'
		UNION ALL
		SELECT 'production','7'
		) [ordertbl]
ON	T1.[Environment] = [ordertbl].[Environment]
 
UNION ALL 
 
SELECT	T1.[Environment] 
	,T2.[Servers]
	,T2.[SQL Instances]
	,T1.[Distinct Databases]
	,T1.[Databases]
	,100 [OrderHelper]
FROM	(
	SELECT 'Total' [Environment]
		,COUNT(*) [Databases]
		,count(distinct DBName) [Distinct Databases]
	  FROM [dbaadmin].[dbo].[DBA_DBInfo] DI
	  JOIN dbo.DBA_ServerInfo AS SI 
	  ON DI.SQLName = SI.SQLName
	WHERE si.Active = 'Y'
	) T1
JOIN	(	
	SELECT	'Total' [Environment]
		,count(*) [SQL Instances]
		,count(distinct ServerName) [Servers]
	FROM  dbo.DBA_ServerInfo 
	WHERE Active = 'Y'
	) T2
ON T1.[Environment] = T2.[Environment]	 

GO


