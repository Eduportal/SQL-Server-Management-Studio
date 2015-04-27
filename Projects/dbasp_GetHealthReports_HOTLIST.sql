----CREATE TYPE String_List AS TABLE ([Entry] VarChar(50) NOT NULL PRIMARY KEY)
----GO
--IF OBJECT_ID('dbasp_GetHealthReports') IS NOT NULL
--	DROP PROCEDURE dbasp_GetHealthReports
--GO
--CREATE PROCEDURE	dbasp_GetHealthReports
--		(
SECLARE		@SearchString		String_List		READONLY
			,@ExcludeServers	String_List		READONLY
			,@EnviroList		String_List		READONLY
--		)	
--AS
SET NOCOUNT ON


DECLARE @ServerInfoList Table
(
	[SQLName]		SYSNAME
	,[ServerName]	SYSNAME
	,SQLEnv			VarChar(max)
	,DomainName		VarChar(max)
	,Apps			VarChar(max)
	,DBs			VarChar(max)
	,SearchString	VarChar(max)
)

DECLARE @ServerList		Table
(
	SQLName			SYSNAME
	,ServerName		SYSNAME
	,Hits			VarChar(max)
	,Apps			VarChar(max)
	,DBs			VarChar(max)
)
DECLARE	@Results		Table
(
	[SQLname]		SYSNAME
	,[ServerName]	SYSNAME
	,[Hits]			VarChar(max)
	,[Domain]		SYSNAME
	,[ENVname]		SYSNAME
	,[Subject01]	VarChar(max)
	,[Value01]		VarChar(max)
	,[Notes01]		VarChar(max)
	,[Grade01]		VarChar(max)
	,[Check_date]	DATETIME
	,[Apps]			VarChar(max)
	,[DBs]			VarChar(max)
)


----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--			POPULATE SERVER INFO LIST
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

INSERT INTO @ServerInfoList (SQLName,ServerName,SQLEnv,DomainName,Apps,DBs)
SELECT		UPPER(SI.[SQLName])																			[SQLName]
			,UPPER(SI.[ServerName])																		[ServerName]
			,MAX(UPPER(COALESCE(SI.SQLEnv,'--')))														[SQLEnv]
			,MAX(UPPER(COALESCE(SI.DomainName,'--')))													[DomainName]
			,LTRIM((
						SELECT		dbaadmin.dbo.dbaudf_Concatenate(' '+ExtractedText)
						FROM		(
									SELECT		DISTINCT 
												ExtractedText
									FROM		[DBAcentral].dbo.dbaudf_StringToTable(UPPER(isnull(NULLIF(dbaadmin.dbo.dbaudf_Concatenate(REPLACE(REPLACE(DI.[Appl_desc],'(',','),')',',')),''),'OTHER')),',')
									WHERE		nullif(ExtractedText,'') IS NOT NULL) Data
									))			[Apps]
			,LTRIM((
						SELECT		dbaadmin.dbo.dbaudf_Concatenate(' '+ExtractedText)
						FROM		(
									SELECT		DISTINCT 
												ExtractedText
									FROM		[DBAcentral].dbo.dbaudf_StringToTable(dbaadmin.dbo.dbaudf_Concatenate(UPPER(DI.[DBName])),',')
									WHERE		nullif(ExtractedText,'') IS NOT NULL) Data
									))			[DBs]
FROM		[DBAcentral].[dbo].[DBA_ServerInfo] SI
LEFT JOIN	[DBAcentral].[dbo].[DBA_DBInfo] DI
	ON		SI.SQLName = DI.SQLName
WHERE		dbacentral.[dbo].[dbaudf_GetServerClass] (SI.[SQLName]) = 'High' 
GROUP BY	SI.[SQLName],SI.[ServerName]
ORDER BY	1

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--			CLEAN UP APPS, DBS, AND POPULATE SEARCH STRING
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
UPDATE		@ServerInfoList
	SET		[Apps] =	LTRIM((
						SELECT		dbaadmin.dbo.dbaudf_Concatenate(' '+ExtractedText)
						FROM		(
									SELECT		DISTINCT 
												ExtractedText
									FROM		[DBAcentral].dbo.dbaudf_StringToTable(T1.[Apps],',')
									WHERE		nullif(ExtractedText,'') IS NOT NULL) Data
									))
			,[DBs] =	LTRIM((
						SELECT		dbaadmin.dbo.dbaudf_Concatenate(' '+ExtractedText)
						FROM		(
									SELECT		DISTINCT 
												ExtractedText
									FROM		[DBAcentral].dbo.dbaudf_StringToTable(T1.[DBs],',')
									WHERE		nullif(ExtractedText,'') IS NOT NULL) Data
									))
			,[SearchString] = LTRIM((
						SELECT		dbaadmin.dbo.dbaudf_Concatenate(' '+ExtractedText)
						FROM		(
									SELECT		DISTINCT 
												ExtractedText
									FROM		[DBAcentral].dbo.dbaudf_StringToTable(T1.[Apps]+','+T1.[DBs],',')
									WHERE		nullif(ExtractedText,'') IS NOT NULL) Data
									))
FROM		@ServerInfoList T1	

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--			POPULATE SERVER LIST
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

INSERT INTO	@ServerList
SELECT		T1.SQLname
			,T1.ServerName
			,dbaadmin.dbo.dbaudf_Concatenate(T2.[Entry]) [Hits]
			,dbaadmin.dbo.dbaudf_Concatenate(T1.[Apps]) [Apps]
			,dbaadmin.dbo.dbaudf_Concatenate(T1.[DBs]) [DBs]
FROM		@ServerInfoList T1
JOIN		@SearchString T2
	ON		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(','+T1.[SearchString]+',',CHAR(9),' '),'  ',' '),'  ',' '),' ,',','),', ',',') LIKE '%,'+T2.[Entry]+',%'
GROUP BY	T1.SQLname,T1.ServerName
ORDER BY	1

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--			GET MOST RECENT HEALTH STATUS
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

;WITH	LastCheckIn
		AS
		(
		SELECT		SQLname
					,MAX(CAST(CONVERT(VARCHAR(12),check_date,101)AS DATETIME)) AS last_date
		FROM		[dbacentral].[dbo].[SQLHealth_Central]
		GROUP BY	SQLname
		)
--INSERT INTO	@Results		
SELECT		SL.[SQLname]
			,SL.[ServerName]
			,NULL [Hits]
			,SHC.[Domain]
			,SHC.[ENVname]
			,SHC.[Subject01]
			,SHC.[Value01]
			,SHC.[Notes01]
			,SHC.[Grade01]
			,CAST(CONVERT(VARCHAR(12),SHC.check_date,101)AS DATETIME) [Check_date]
			,SL.[Apps]
			,SL.[DBs]
FROM		[dbacentral].[dbo].[SQLHealth_Central] SHC
JOIN		LastCheckIn
		ON	SHC.[SQLname] = LastCheckIn.[SQLname]
		AND	CAST(CONVERT(VARCHAR(12),SHC.[Check_date],101)AS DATETIME) = LastCheckIn.last_date
JOIN		(
			SELECT		UPPER(SI.[SQLName])																			[SQLName]
						,UPPER(SI.[ServerName])																		[ServerName]
						,MAX(UPPER(COALESCE(SI.SQLEnv,'--')))														[SQLEnv]
						,MAX(UPPER(COALESCE(SI.DomainName,'--')))													[DomainName]
						,LTRIM((
									SELECT		dbaadmin.dbo.dbaudf_Concatenate(' '+ExtractedText)
									FROM		(
												SELECT		DISTINCT TOP 100 PERCENT
															LTRIM(RTRIM(ExtractedText)) [ExtractedText]
												FROM		[DBAcentral].dbo.dbaudf_StringToTable(UPPER(isnull(NULLIF(dbaadmin.dbo.dbaudf_Concatenate(REPLACE(REPLACE(DI.[Appl_desc],'(',','),')',',')),''),'OTHER')),',')
												WHERE		nullif(ExtractedText,'') IS NOT NULL ORDER BY 1) Data
												))			[Apps]
						,LTRIM((
									SELECT		dbaadmin.dbo.dbaudf_Concatenate(' '+ExtractedText)
									FROM		(
												SELECT		DISTINCT TOP 100 PERCENT
															LTRIM(RTRIM(ExtractedText)) [ExtractedText]
												FROM		[DBAcentral].dbo.dbaudf_StringToTable(dbaadmin.dbo.dbaudf_Concatenate(UPPER(DI.[DBName])),',')
												WHERE		nullif(ExtractedText,'') IS NOT NULL ORDER BY 1) Data
												))			[DBs]
			FROM		[DBAcentral].[dbo].[DBA_ServerInfo] SI
			LEFT JOIN	[DBAcentral].[dbo].[DBA_DBInfo] DI
				ON		SI.SQLName = DI.SQLName
			WHERE		dbacentral.[dbo].[dbaudf_GetServerClass] (SI.[SQLName]) = 'High' 
			GROUP BY	SI.[SQLName],SI.[ServerName]
			) SL
		ON	SL.SQLname = SHC.[SQLname]
WHERE		SHC.[ENVname] = 'production'
ORDER BY	SHC.[SQLname]

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--			CLEAN UP APPS, DBS, AND Hits
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

UPDATE		@Results
	SET		[Apps] =	LTRIM((
						SELECT		dbaadmin.dbo.dbaudf_Concatenate(' '+ExtractedText)
						FROM		(
									SELECT		DISTINCT TOP 100 PERCENT
												LTRIM(RTRIM(ExtractedText)) [ExtractedText]
									FROM		[DBAcentral].dbo.dbaudf_StringToTable(T1.[Apps],',')
									WHERE		nullif(ExtractedText,'') IS NOT NULL ORDER BY 1) Data
									))
			,[DBs] =	LTRIM((
						SELECT		dbaadmin.dbo.dbaudf_Concatenate(' '+ExtractedText)
						FROM		(
									SELECT		DISTINCT TOP 100 PERCENT
												LTRIM(RTRIM(ExtractedText)) [ExtractedText]
									FROM		[DBAcentral].dbo.dbaudf_StringToTable(T1.[DBs],',')
									WHERE		nullif(ExtractedText,'') IS NOT NULL ORDER BY 1) Data
									))
			,[Hits] = LTRIM((
						SELECT		dbaadmin.dbo.dbaudf_Concatenate(' '+ExtractedText)
						FROM		(
									SELECT		DISTINCT TOP 100 PERCENT
												LTRIM(RTRIM(ExtractedText)) [ExtractedText]
									FROM		[DBAcentral].dbo.dbaudf_StringToTable(T1.[Hits],',')
									WHERE		nullif(ExtractedText,'') IS NOT NULL ORDER BY 1) Data
									))
FROM		@Results T1	


SELECT		SQLName
			,ServerName
			,Hits
			,Domain
			,EnvName
			,Check_Date
			,REPLACE(dbaadmin.dbo.dbaudf_Concatenate(Subject01+ISNULL('('+NULLIF(Value01,' ')+') ',' ')+ISNULL(NULLIF(Notes01,' '),'')+CHAR(13)+CHAR(10)),CHAR(13)+CHAR(10)+',',CHAR(13)+CHAR(10)) [Health_Status]
			,Apps
			,DBs
			,'file://'+[ServerName]+'/'+REPLACE([SQLName],'\','$')+'_dbasql/dba_reports/SQLHealthReport_'+REPLACE([SQLName],'\','$')+'.txt' [ReportLink]
FROM		@Results
GROUP BY	SQLName
			,ServerName
			,Hits
			,Domain
			,EnvName
			,Check_Date
			,Apps
			,DBs
ORDER BY	2,1
GO



--CREATE PROCEDURE	dbasp_GetHealthReports_HOTLIST
--AS
--SET NOCOUNT ON

--DECLARE	@SearchString		String_List 
--		,@ExcludeServers	String_List	
--		,@EnviroList		String_List	

--INSERT @SearchString VALUES ('unauth'),('Legacy Creative'),('Legacy HardGoods'),('Legacy Editorial')
--							,('Legacy Commerce Service'),('EF'),('ED'),('DEWDS'),('PumpAudio')
--							,('Search Data Tools'),('Transcoder'),('CRM')

--INSERT @EnviroList VALUES	('PRODUCTION')						

--INSERT @ExcludeServers VALUES ('SEAPSQLRPT01'),('SEADCCSO01'),('SQLDEPLOYER02')

--EXEC	dbasp_GetHealthReports
--			@SearchString
--			,@ExcludeServers
--			,@EnviroList

--GO
