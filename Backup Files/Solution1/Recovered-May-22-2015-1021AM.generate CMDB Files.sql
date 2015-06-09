
DECLARE @filename nvarchar(4000)	= 'C:\temp\DATA_EXTRACT__DATABASE_INSTANCE.csv'
DECLARE @includeheaders bit		= 1
DECLARE @quoteall bit			= 1
DECLARE @provideoutput bit		= 1
DECLARE	@sqlcmd nvarchar(4000)		= 
'
		SELECT		UPPER(SQLName)		[Instance Name]
				,''MSSQL''		[Class/Type]
				,CASE	WHEN SQLver LIKE ''%SQL Server 2000%'' THEN ''2000''
					ELSE STUFF(SQLVer,1,CHARINDEX(''SQL Server'',SQLVer)+10,'''')
					END		[Version]
				,Port			[TCP Port]
				,UPPER([ServerName])	[Server]
				,CASE WHEN [Active] != ''N'' THEN ''active'' else ''inactive'' END [Operational]
				,SQLmax_memory		[SQL_MAX_MEMORY]
				,NULL			[Short Description]
				,NULL			[Application Support Group]
				,NULL			[Infrastructure Support Group]
				,NULL			[IT Manager/Service Owner]

				
		FROM		[dbacentral].[dbo].[DBA_ServerInfo] T1
		WHERE		[SQLEnv] = ''Production''
			--AND	[Active] != ''N''
		UNION

		SELECT		dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(Listener,'','',''|''),1)
				,''MSSQL''
				,''Availability Group''
				,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(Listener,'','',''|''),2)
				,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(Listener,'','',''|''),1)
				,''active''
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				
		FROM		[dbacentral].[dbo].[DBA_AGInfo] T1
		WHERE		Listener IS NOT NULL
			AND	(SELECT SQLEnv FROM dbacentral.dbo.DBA_ServerInfo Where SQLName = T1.SQLName) = ''production''

		ORDER BY	1

 '
--EXEC (@sqlcmd)
EXECUTE [DBAADMIN].[dbo].[dbasp_Export_CsvFile] 
   @sqlcmd
  ,@filename
  ,@includeheaders
  ,@quoteall
  ,@provideoutput
GO


DECLARE @filename nvarchar(4000)	= 'C:\temp\DATA_EXTRACT__DATABASE_SERVER.csv'
DECLARE @includeheaders bit		= 1
DECLARE @quoteall bit			= 1
DECLARE @provideoutput bit		= 1
DECLARE	@sqlcmd varchar(8000)		= 
'
		SELECT		*
				
		FROM		[dbacentral].[dbo].[DATA_EXTRACT__DATABASE_SERVER] T1

		ORDER BY	1
'
--EXEC (@sqlcmd)
EXECUTE [DBAADMIN].[dbo].[dbasp_Export_CsvFile] 
   @sqlcmd
  ,@filename
  ,@includeheaders
  ,@quoteall
  ,@provideoutput
GO


DECLARE @filename nvarchar(4000)	= 'C:\temp\DATA_EXTRACT__DATABASES.csv'
DECLARE @includeheaders bit		= 1
DECLARE @quoteall bit			= 1
DECLARE @provideoutput bit		= 1
DECLARE	@sqlcmd nvarchar(4000)		= 
'	SELECT		UPPER(T2.DBName) [DBName_Specific]
			,UPPER(COALESCE(T2.DBName_Cleaned,T2.DBName)) [DBName_General]

			,CASE WHEN NULLIF(T3.AvailGrp,'''') IS NULL THEN UPPER(T3.SQLName) 
				ELSE (SELECT DISTINCT dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(Listener,'','',''|''),1) FROM [dbacentral].[dbo].[DBA_AGInfo] WHERE AGName = T3.AvailGrp)
				END [SQLName]
	
			,''MSSQL'' [DB Tupe]
			,T3.status [Status]
			,T3.CreateDate	
			,T3.Appl_desc	
			,T3.BaselineFolder	
			,T3.BaselineServername	
			,T3.BaselineDate	
			,T3.build	
			,T3.RecovModel	
			,T3.PageVerify	
			,T3.Collation	
			,T3.AvailGrp	
			,T3.Mirroring	
			,T3.modDate	
			,T3.DBCompat	
			,T3.DEPLstatus
	FROM		[dbacentral].[dbo].[DBA_ServerInfo] T1
	JOIN		(
			SELECT		DI.*,DNC.DBName_Cleaned
			FROM		[DBAcentral].[dbo].[DBA_DBInfo]		DI
			LEFT JOIN	[DBAcentral].dbo.DBA_DBNameCleaner	DNC
					ON	DI.[DBName] Like DNC.[DBName]
			) T2
		ON	T1.[SQLName] = T2.SQLName
	JOIN		[dbacentral].[dbo].[DBA_DBInfo] T3
		ON	T3.SQLName = T1.SQLName
		AND	T3.DBName = T2.DBName
	WHERE		T1.[SQLEnv] = ''Production''
		AND	T1.[Active] != ''N''

	ORDER BY 3,1
'
		
--EXEC (@sqlcmd)
EXECUTE [DBAADMIN].[dbo].[dbasp_Export_CsvFile] 
   @sqlcmd
  ,@filename
  ,@includeheaders
  ,@quoteall
  ,@provideoutput
GO













--DECLARE @filename nvarchar(4000)	= 'C:\temp\DATA_EXTRACT__CLUSTER_SERVERS.csv'
--DECLARE @includeheaders bit		= 1
--DECLARE @quoteall bit			= 1
--DECLARE @provideoutput bit		= 1
--DECLARE	@sqlcmd nvarchar(4000)		= 
--'		SELECT		DISTINCT
--				UPPER(Cluster) [ClusterName]
--				,(SELECT GroupName From [dbacentral].[dbo].[DBA_ClusterInfo] WHERE ResourceType = ''Network Name'' AND ClusterName = T1.Cluster AND (ResourceDetail = T1.ServerName OR ResourceName Like ''%''+T1.ServerName+''%'')) [ClusterGroup]
--				,UPPER([ServerName]) [ServerName]
--				,UPPER(SQLName) [SQLName]
--				,UPPER(DomainName) [DomainName]	
--				,UPPER(COALESCE(FQDN,[ServerName]+ CASE	WHEN DomainName = ''amer''	THEN ''.amer.gettywan.com''
--									WHEN DomainName = ''production''	THEN ''.production.local''
--									WHEN DomainName = ''stage''	THEN ''.stage.local''
--									END)) [FQDN]	
--				,''Cluster Server'' [ServerType]	
--				,Memory	
--				,SQLmax_memory	
--				,FrameWork_ver	
--				,SAN	
--				,PowerPath	
--				,(SELECT	REPLACE(dbaadmin.dbo.dbaudf_Concatenate(ResourceDetail),'','',''|'')
--				  FROM	(
--					SELECT		ResourceDetail
--					FROM		[dbacentral].[dbo].[DBA_ClusterInfo]
--					WHERE		ResourceType = ''IP Address''
--						AND	ClusterName = T1.Cluster
--						AND	GroupName = (SELECT GroupName From [dbacentral].[dbo].[DBA_ClusterInfo] WHERE ResourceType = ''Network Name'' AND ClusterName = T1.Cluster AND (ResourceDetail = T1.ServerName OR ResourceName Like ''%''+T1.ServerName+''%''))
--					UNION
--					SELECT		T1.IPnum
--					) Data
-- 				 ) [IPnum]
--				,CPUphysical	
--				,CPUcore	
--				,CPUlogical	
--				,CPUtype	
--				,OSname	
--				,OSver	
--				,OSinstallDate	
--				,TimeZone	
--				,SystemModel	
--				,Services
--		FROM		[dbacentral].[dbo].[DBA_ServerInfo] T1
--		WHERE		[SQLEnv] = ''Production''
--			AND	[Active] != ''N''
--			AND	NULLIF([Cluster],'''') Is NOT Null
--			AND	ServerName NOT IN	(
--							SELECT		ResourceName
--							FROM		[dbacentral].[dbo].[DBA_ClusterInfo]
--							WHERE		[ResourceType] = ''Node''
--								AND	ResourceName IN (SELECT ServerName FROM [dbacentral].[dbo].[DBA_ServerInfo])
--							)'
		

--EXECUTE [DBAADMIN].[dbo].[dbasp_Export_CsvFile] 
--   @sqlcmd
--  ,@filename
--  ,@includeheaders
--  ,@quoteall
--  ,@provideoutput
--GO






DECLARE @filename nvarchar(4000)	= 'C:\temp\DATA_EXTRACT__CLUSTER_NODES.csv'
DECLARE @includeheaders bit		= 1
DECLARE @quoteall bit			= 1
DECLARE @provideoutput bit		= 1
DECLARE	@sqlcmd nvarchar(4000)		= 
'		;WITH		ClusterNodeA
				AS
				(
				SELECT		ClusterName
						,ResourceName
						,State
				FROM		[dbacentral].[dbo].[DBA_ClusterInfo]
				WHERE		[ResourceType] = ''Node''
					AND	ResourceName NOT IN (SELECT ServerName FROM [dbacentral].[dbo].[DBA_ServerInfo])
				)
		SELECT		DISTINCT
				UPPER(T1.ClusterName) [ClusterName]
				,UPPER(T1.[ResourceName]) [ServerName]
				,UPPER(DomainName) [DomainName]	
				,UPPER(T1.[ResourceName]+ CASE	WHEN DomainName = ''amer''	THEN ''.amer.gettywan.com''
								WHEN DomainName = ''production''	THEN ''.production.local''
								WHEN DomainName = ''stage''	THEN ''.stage.local''
								END) [FQDN]	
				,''Cluster Node'' [ServerType]	
				,(SELECT ResourceDetail FROM [dbacentral].[dbo].[DBA_ClusterInfo] WHERE ResourceType = ''Network Interface'' AND ResourceName Like ''%''+T1.ResourceName+''%'' AND ResourceName Like ''%Public%'') [NodePublicIP]
				,(SELECT ResourceDetail FROM [dbacentral].[dbo].[DBA_ClusterInfo] WHERE ResourceType = ''Network Interface'' AND ResourceName Like ''%''+T1.ResourceName+''%'' AND ResourceName Like ''%Private%'') [NodePrivateIP]
		FROM		ClusterNodeA T1
		JOIN		[dbacentral].[dbo].[DBA_ServerInfo] T2
			ON	T2.[Cluster] = T1.ClusterName
		WHERE		T2.[SQLEnv] = ''Production''
			AND	T2.[Active] != ''N''
			AND	NULLIF(T2.[Cluster],'''') Is Not Null'
		
--EXEC (@sqlcmd)
EXECUTE [DBAADMIN].[dbo].[dbasp_Export_CsvFile] 
   @sqlcmd
  ,@filename
  ,@includeheaders
  ,@quoteall
  ,@provideoutput
GO


