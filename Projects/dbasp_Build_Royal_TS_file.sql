USE [DBAcentral]
GO

SET		NOCOUNT			ON
DECLARE		@Text			VarChar(max)
DECLARE		@Level1			VarChar(max)
DECLARE		@Level2			VarChar(max)
DECLARE		@Level3			VarChar(max)
DECLARE		@Level4			VarChar(max)
DECLARE		@Server			VarChar(max)
DECLARE		@Desc			VarChar(max)
DECLARE		@Level1Desc 		VarChar(max)
DECLARE		@Level2Desc 		VarChar(max)
DECLARE		@Level3Desc 		VarChar(max)
DECLARE		@Port			VarChar(max)
DECLARE		@DomainName 		VarChar(max)
DECLARE		@Apps			VarChar(max)
DECLARE		@DBs			VarChar(max)
DECLARE		@xDomLogin 		VarChar(max)
DECLARE		@xDomPaswd		VarChar(max)
DECLARE		@XML			VarChar(max)
DECLARE		@DocID			UniqueIdentifier

SET		@DocID			= NEWID()		



DECLARE @ServerList Table
(
 Col1 VarChar(max)	-- LEVEL 1 ('Active')
,Col2 VarChar(max)	-- Level 2 ('By Environment','By DB','By App','ALL')
,Col3 VarChar(max)	-- Level 3 ({SQLEnv},{DBName},{Appl_desc},'ALL')
,Col4 VarChar(max)	-- Level 4 ({DomainName},{DEPLStatus},',')
,Col5 VarChar(max)	-- {ServerName}
,Col6 VarChar(max)	-- {SQLPort}
,Col7 VarChar(max)	-- {DomainName}
,Col8 VarChar(max)	-- concatonated {Appl_desc} When Not "By APP"
,Col9 VarChar(max)	-- concatonated {DBName} When Not "By DB"
)

DECLARE @ServerInfoList Table
(
	SQLName			VarChar(max)
	,Port			VarChar(max)
	,SQLEnv			VarChar(max)
	,DomainName		VarChar(max)
	,Apps			VarChar(max)
	,DBs			VarChar(max)
	,Active			VarChar(max)
	,SQL_Version		VarChar(max)
	,SQL_Build		VarChar(max)
	,SQL_Edition		VarChar(max)
	,SQL_BitLevel		VarChar(max)
	,CPU_Physical		VarChar(max)
	,CPU_Cores		VarChar(max)
	,CPU_Logical		VarChar(max)
	,CPU_BitLevel		VarChar(max)
	,CPU_Speed		VarChar(max)
	,OS_Version		VarChar(max)
	,OS_Build		VarChar(max)
	,OS_Edition		VarChar(max)
	,OS_BitLevel		VarChar(max)
)

DECLARE @Folders Table
(
	[FolderName]		SYSNAME
	,FolderID		UniqueIdentifier
	,[ParentFolder]		SYSNAME
)


INSERT INTO @ServerInfoList (SQLName,Port,SQLEnv,DomainName,Apps,DBs,Active,SQL_Version,SQL_Build,SQL_Edition,SQL_BitLevel,CPU_Physical,CPU_Cores,CPU_Logical,CPU_BitLevel,CPU_Speed,OS_Version,OS_Build,OS_Edition,OS_BitLevel)

SELECT		UPPER(SI.[SQLName])									[SQLName]
		,MAX(COALESCE(SI.[Port],'1433'))							[Port]
		,MAX(UPPER(COALESCE(SI.SQLEnv,'--')))							[SQLEnv]
		,MAX(UPPER(COALESCE(SI.DomainName,'--')))						[DomainName]
		,UPPER(isnull(NULLIF(dbaadmin.dbo.dbaudf_Concatenate(DI.[Appl_desc]),''),'OTHER'))	[Apps]
		,dbaadmin.dbo.dbaudf_Concatenate(UPPER(DI.[DBName]))					[DBs]
		,MAX(CASE SI.Active WHEN 'Y' THEN 'ACTIVE' ELSE 'NOT ACTIVE' END)			[Active]
		,MAX(dbaadmin.dbo.Returnword(REPLACE(REPLACE(REPLACE(REPLACE
			(REPLACE(SQLver,'- ',''),'(SP1) ',''),'Intel ','')
			,'(',''),')',''),4))								[SQL_Version]
		,MAX(dbaadmin.dbo.Returnword(REPLACE(REPLACE(REPLACE(REPLACE
			(REPLACE(SQLver,'- ',''),'(SP1) ',''),'Intel ','')
			,'(',''),')',''),5))								[SQL_Build]
		,MAX(dbaadmin.dbo.Returnword(REPLACE(REPLACE(REPLACE(REPLACE
			(REPLACE(REPLACE(SQLver,'- ',''),'(SP1) ','')
			,'Intel ',''),'(',''),')',''),'Corporation',''),15))				[SQL_Edition]
		,MAX(dbaadmin.dbo.Returnword(REPLACE(REPLACE(REPLACE(REPLACE
			(REPLACE(SQLver,'- ',''),'(SP1) ',''),'Intel ','')
			,'(',''),')',''),6))								[SQL_BitLevel]
		,MAX(REPLACE(CPUphysical,' physical',''))						[CPU_Physical]
		,MAX(REPLACE(REPLACE(CPUcore,' cores',''),' core(s)',''))				[CPU_Cores]
		,MAX(REPLACE(CPUlogical,' logical',''))							[CPU_Logical]
		,MAX(REPLACE('X'+dbaadmin.dbo.Returnword(
			REPLACE(REPLACE(REPLACE(CPUtype,'EM','')
			,'Intel',''),'T',''),1),'xx','X'))						[CPU_BitLevel]
		,MAX(SUBSTRING(CPUtype,CHARINDEX('~',CPUtype)+1
			,len(CPUtype)-CHARINDEX('~',CPUtype)))						[CPU_Speed]
		,MAX(REPLACE(dbaadmin.dbo.Returnword(OSname,4),',',''))					[OS_Version]
		,MAX(OSver)											[OS_Build]
		,MAX(dbaadmin.dbo.Returnword(OSname,5))							[OS_Edition]
		,MAX(REPLACE(REPLACE('X86' + REPLACE(dbaadmin.dbo.Returnword
			(OSname,6),'Edition','X86'),'X86X86','X86')
			,'X86X64','X64'))								[OS_BitLevel]
		--,MAX(SQLver)
		--,MAX(OSname)
FROM		[DBAcentral].[dbo].[DBA_ServerInfo] SI
LEFT JOIN	[DBAcentral].[dbo].[DBA_DBInfo] DI
	ON		SI.SQLName = DI.SQLName
GROUP BY	SI.[SQLName] 
ORDER BY	1


UPDATE		@ServerInfoList
	SET		[Apps] =	LTRIM((
						SELECT		dbaadmin.dbo.dbaudf_Concatenate(' '+ExtractedText)
						FROM		(
									SELECT		DISTINCT 
												ExtractedText
									FROM		dbo.dbaudf_StringToTable(T1.[Apps],',')
									WHERE		nullif(ExtractedText,'') IS NOT NULL) Data
									))
			,[DBs] =	LTRIM((
						SELECT		dbaadmin.dbo.dbaudf_Concatenate(' '+ExtractedText)
						FROM		(
									SELECT		DISTINCT 
												ExtractedText
									FROM		dbo.dbaudf_StringToTable(T1.[DBs],',')
									WHERE		nullif(ExtractedText,'') IS NOT NULL) Data
									))
FROM		@ServerInfoList T1	


INSERT INTO @ServerList (Col1,Col2,Col3,Col4,Col5,Col6,Col7,Col8,Col9)

SELECT		CASE Active WHEN 'Y' THEN 'ACTIVE' ELSE 'NOT ACTIVE' END		[Level1]
			,'Virtual Servers'												[Level2]
			,UPPER([SQLEnv])												[Level3]
			,COALESCE(nullif(REPLACE(
			 (	select max(ENVnum) 
				FROM dbacentral.dbo.DBA_DBInfo 
				WHERE SQLName = T1.[SQLName]
			 ),[SQLEnv],''),''),'01')										[Level4]
			,[SQLName]														[SQLInstance]
			,COALESCE([Port],'1433')										[SQLPort]
			,UPPER(COALESCE(DomainName,'--'))							[DomainName]
			,''																[Apps]
			,''																[DBs]
FROM		[dbacentral].[dbo].[DBA_ServerInfo] T1
WHERE		[SystemModel] like '%VMware%' --order by 5

UNION ALL

SELECT		SI.Active														[Level1]
			,'BY ENV'														[Level2]
			,SI.[SQLEnv]													[Level3]
			,SI.DomainName													[Level4]
			,SI.[SQLName]													[SQLInstance]
			,SI.[Port]														[SQLPort]
			,SI.DomainName													[DomainName]
			,SI.[APPs]														[Apps]
			,SI.[DBs]														[DBs]
FROM		@ServerInfoList SI

UNION ALL

SELECT		SI.Active														[Level1]
			,'BY DB'														[Level2]
			,UPPER(COALESCE(DBName_Cleaned,DI.[DBName]))					[Level3]
			,UPPER(CASE WHEN DI.[DBName] = COALESCE(DBName_Cleaned,DI.[DBName])
				THEN '--' ELSE 	DI.[DBName] END)							[Level4]
			,SI.[SQLName]													[SQLInstance]
			,MAX(SI.[Port])													[SQLPort]
			,MAX(SI.SQLEnv)+'-'+MAX(SI.DomainName)							[DomainName]
			,MAX(SI.[APPs])													[Apps]
			,MAX(SI.[DBs])													[DBs]
FROM		@ServerInfoList SI
JOIN		(
			SELECT		DI.*,DNC.DBName_Cleaned
			FROM		[DBAcentral].[dbo].[DBA_DBInfo]		DI
			LEFT JOIN	[DBAcentral].dbo.DBA_DBNameCleaner	DNC
					ON	DI.[DBName] = DNC.[DBName]
			) DI
	ON		SI.SQLName = DI.SQLName
WHERE		SI.Active = 'ACTIVE'
GROUP BY	SI.Active														-- LEVEL 1
			,UPPER(COALESCE(DBName_Cleaned,DI.[DBName]))					-- LEVEL 3
			,CASE WHEN DI.[DBName] = COALESCE(DBName_Cleaned,DI.[DBName])
				THEN '--' ELSE 	DI.[DBName] END								-- LEVEL 4
			,SI.[SQLName]													-- SERVER NAME

UNION ALL

SELECT		SI.Active														[Level1]
			,'BY APP-ENV'													[Level2]
			,UPPER(isnull(NULLIF(DI.[Appl_desc],''),'OTHER'))				[Level3]
			,SI.[SQLEnv]													[Level4]
			,SI.[SQLName]													[SQLInstance]
			,MAX(SI.[Port])													[SQLPort]
			,MAX(SI.DomainName)												[DomainName]
			,MAX(SI.[APPs])													[Apps]
			,MAX(SI.[DBs])													[DBs]
FROM		@ServerInfoList SI
LEFT JOIN	[DBAcentral].[dbo].[DBA_DBInfo] DI
	ON		SI.SQLName = DI.SQLName
WHERE		SI.Active = 'ACTIVE'
GROUP BY	SI.Active														-- LEVEL 1
			,UPPER(isnull(NULLIF(DI.[Appl_desc],''),'OTHER'))				-- LEVEL 3
			,SI.[SQLEnv]													-- LEVEL 4
			,SI.[SQLName]													-- SERVER NAME

UNION ALL

SELECT		SI.Active														[Level1]
			,'By APP-DB'													[Level2]
			,UPPER(isnull(NULLIF(DI.[Appl_desc],''),'OTHER'))				[Level3]
			,UPPER(DI.[DBName])												[Level4]
			,SI.[SQLName]													[SQLInstance]
			,MAX(SI.[Port])													[SQLPort]
			,MAX(SI.DomainName)												[DomainName]
			,MAX(SI.[APPs])													[Apps]
			,MAX(SI.[DBs])													[DBs]
FROM		@ServerInfoList SI
LEFT JOIN	[DBAcentral].[dbo].[DBA_DBInfo] DI
	ON		SI.SQLName = DI.SQLName
WHERE		SI.Active = 'ACTIVE'
GROUP BY	SI.Active														-- LEVEL 1
			,UPPER(isnull(NULLIF(DI.[Appl_desc],''),'OTHER'))				-- LEVEL 3
			,DI.[DBName]													-- LEVEL 4
			,SI.[SQLName]													-- SERVER NAME

UNION ALL

SELECT		DISTINCT
			SI.Active														[Level1]
			,'ALL'															[Level2]
			,'--'															[Level3]
			,'--'															[Level4]
			,SI.[SQLName]													[SQLInstance]
			,SI.[Port]														[SQLPort]
			,SI.[DomainName]												[DomainName]
			,SI.[APPs]														[Apps]
			,SI.[DBs]														[DBs]
FROM		@ServerInfoList SI

UNION ALL

SELECT		DISTINCT
			'SUPPORT'														[Level1]
			,'--'															[Level2]
			,'--'															[Level3]
			,'--'															[Level4]
			,SI.[SQLName]													[SQLInstance]
			,SI.[Port]														[SQLPort]
			,SI.DomainName													[DomainName]
			,SI.[APPs]														[Apps]
			,SI.[DBs]														[DBs]
FROM		@ServerInfoList SI
LEFT JOIN	[DBAcentral].[dbo].[DBA_DBInfo] DI
	ON		SI.SQLName = DI.SQLName
WHERE		(
			DI.DBName	=		'DBACentral'
		OR	SI.SQLName	Like	'%deployer%'
			) 

UNION ALL

SELECT		DISTINCT
			'HOT LIST'														[Level1]
			,SI.DomainName													[Level2]
			,'--'															[Level3]
			,'--'															[Level4]
			,SI.[SQLName]													[SQLInstance]
			,SI.[Port]														[SQLPort]
			,SI.DomainName													[DomainName]
			,SI.[APPs]														[Apps]
			,SI.[DBs]														[DBs]

FROM		@ServerInfoList SI
WHERE		dbo.dbaudf_GetServerClass(SI.SQLName) = 'high'


UPDATE		@ServerList
	SET		[Col1] = REPLACE(REPLACE(Col1,'/','-'),'.','-')
			,[Col2] = REPLACE(REPLACE(Col2,'/','-'),'.','-')
			,[Col3] = REPLACE(REPLACE(Col3,'/','-'),'.','-')
			,[Col4] = REPLACE(REPLACE(Col4,'/','-'),'.','-')


DELETE @ServerList WHERE Col5 NOT IN (SELECT top 50 Col5 From @Serverlist)





INSERT INTO	@Folders
SELECT		[FolderName]
		,NEWID()
		,LEFT(FolderName,LEN(FolderName)-CHARINDEX('\',REVERSE(FolderName))) [ParentFolder]
FROM		(
		SELECT		DISTINCT
				REPLACE(REPLACE(REPLACE(COALESCE(Col1,'--')+'\'+COALESCE(Col2,'--')+'\'+COALESCE(Col3,'--')+'\'+COALESCE(Col4,'--'),'\--',''),'\--',''),'\--','') [FolderName]
		FROM		@ServerList 
		)sl	
		
AddSubFolders:

INSERT INTO	@Folders
SELECT		[FolderName]
		,NEWID()
		,LEFT(FolderName,LEN(FolderName)-CHARINDEX('\',REVERSE(FolderName))) [ParentFolder]
FROM		(
		SELECT		DISTINCT
				LEFT(FolderName,LEN(FolderName)-CHARINDEX('\',REVERSE(FolderName))) [FolderName]
		FROM		@Folders
		)sl
WHERE		[FolderName] NOT IN (SELECT [FolderName] FROM @Folders)
	
IF @@ROWCOUNT > 0 Goto AddSubFolders

UPDATE		@Folders
	SET	[ParentFolder] = ''
WHERE		[FolderName] = [ParentFolder]


SELECT		@XML =
(
SELECT		*
FROM		(
		SELECT		 [KeyValuePairs].ObjectID
				,T2.N.value('local-name(.)', 'nvarchar(128)') as [Key]
				,T2.N.value('.', 'nvarchar(max)') as [Value]
		FROM		(
				SELECT		CAST(@DocID AS VarChar(50)) [ObjectID]
						,(
						SELECT		'RoyalDocument'							[RoyalObjectType]
								,CAST(@DocID AS VarChar(50))					[ID]
								,'11/20/2012 10:11:14'						[Modified]
								,'CMS'								[Name]
								,'11/16/2012 15:17:36'						[Created]
								,'AMER\sledridge'						[ModifiedBy]
								,'AMER\sledridge'						[CreatedBy]
								,'0'								[PositionNr]
								,'True'								[IsExpanded]
								,'Workspace'							[DocumentType]
								,''								[CredentialUsername]
								,''								[CredentialPassword]
								,'00000000-0000-0000-0000-000000000000'				[CredentialID]
								,''								[CredentialName]
								,'Generated from CMS'						[Description]
								,'1'								[SaveOption]
								,'True'								[AutoSaveOnClose]
								,'Royal_ts.rtsx'						[FileName]
						for xml path(''), type
						) X
				) [KeyValuePairs]
		cross apply [KeyValuePairs].X.nodes('/*') as T2(N)

		UNION ALL
				  

		SELECT		[KeyValuePairs].ObjectID
				,T2.N.value('local-name(.)', 'nvarchar(128)') as [Key]
				,T2.N.value('.', 'nvarchar(max)') as [Value]
		FROM		(
				SELECT		FolderID ObjectID		
						,(
						SELECT		'RoyalFolder'									[RoyalObjectType]
								,FolderID									[ID]
								,GETDATE()									[Modified]
								,[FolderName]									[Name]
								,GETDATE()									[Created]
								,'AMER\sledridge'								[ModifiedBy]
								,'AMER\sledridge'								[CreatedBy]
								,[PositionNr] 
								,'False'									[IsExpanded]
								,'Created By Import'								[Description]
								,CAST(@DocID AS VarChar(50))							[ParentID] 
						for xml path(''), type
						) X
				FROM		(
						SELECT		*
								,RANK()OVER(PARTITION BY [ParentFolder] ORDER BY [FolderName])			[PositionNr]
						FROM		@Folders
						WHERE		[ParentFolder] = ''
						) T1
				) [KeyValuePairs]
		cross apply [KeyValuePairs].X.nodes('/*') as T2(N)

		UNION ALL

		SELECT		[KeyValuePairs].ObjectID
				,T2.N.value('local-name(.)', 'nvarchar(128)') as [Key]
				,T2.N.value('.', 'nvarchar(max)') as [Value]
		FROM		(
				SELECT		FolderID ObjectID		
						,(
						SELECT		'RoyalFolder'									[RoyalObjectType]
								,FolderID									[ID]
								,GETDATE()									[Modified]
								,[FolderName]									[Name]
								,GETDATE()									[Created]
								,'AMER\sledridge'								[ModifiedBy]
								,'AMER\sledridge'								[CreatedBy]
								,[PositionNr] 
								,'False'									[IsExpanded]
								,'Created By Import'								[Description]
								,(SELECT [FolderID] From @Folders Where FolderName = T1.ParentFolder)		[ParentID] 
						for xml path(''), type
						) X
				FROM		(
						SELECT		*
								,RANK()OVER(PARTITION BY [ParentFolder] ORDER BY [FolderName])			[PositionNr]
						FROM		@Folders
						WHERE		[ParentFolder] > ''
						) T1
				) [KeyValuePairs]
		cross apply [KeyValuePairs].X.nodes('/*') as T2(N)

		UNION ALL

		SELECT		[KeyValuePairs].ObjectID
				,T2.N.value('local-name(.)', 'nvarchar(128)') as [Key]
				,T2.N.value('.', 'nvarchar(max)') as [Value]
		FROM		(
				SELECT		FolderID ObjectID		
						,(
						SELECT		DISTINCT
								'RoyalRDSConnection'			[RoyalObjectType]
								,FolderID				[ID]
								,GETDATE()				[Modified]
								,[Col5]					[Name]	
								,GETDATE()				[Created]
								,'AMER\sledridge'			[ModifiedBy]
								,'AMER\sledridge'			[CreatedBy]
								,[PositionNr]
								,[FolderID]				[ParentID] 
								,''					[ObjectSpecialUsage]
								,LEFT(Col5,CHARINDEX('\',Col5+'\')-1)	[URI]
								,'SQL Server'				[Description]
								,'False'				[CredentialFromParent]	
								,'True'					[CredentialAutologon]	
								,'4'					[CredentialMode]		
								,''					[CredentialUsername]	
								,''					[CredentialPassword]	
								,'False'				[ConnectToAdminister0]	
								,'3389'					[RDPPort]		
								,'0'					[GatewayUsageMethod]	
								,'32'					[ColorDepth]		
								,'0'					[DisplayMode]		
								,'0'					[AudioRedirectionMode]	
								,'False'				[EnableWindowsKey]	
								,'True'					[RedirectClipboard]	
								,'False'				[RedirectDrives]		
								,'False'				[RedirectPorts]		
								,'False'				[RedirectPrinters]	
								,'False'				[RedirectSmartCards]	
								,'0'					[AuthenticationLevel]	
								,'False'				[IsAdHoc]		
								,'True'					[SmartReconnect]		
								,CASE [DomainName]
									WHEN 'PRODUCTION' THEN 'PRODUCTION'
									WHEN 'STAGE' THEN 'STAGE'
									ELSE 'AMER S DASH' END		[CredentialName]
								,Col5+','+Col6				[CustonmField1]
								,Col5					[CustonmField2]
								,Col6					[CustonmField3]
								,Col7					[CustonmField4]
								,Col9					[CustonmField5]
								,Col8					[CustonmField6]
								,SQL_Version				[CustonmField7]
								,SQL_Build				[CustonmField8]
								,SQL_Edition				[CustonmField9]
								,SQL_BitLevel				[CustonmField10]
								,CPU_Physical				[CustonmField11]
								,CPU_Cores				[CustonmField12]
								,CPU_Logical				[CustonmField13]
								,CPU_BitLevel				[CustonmField14]
								,CPU_Speed				[CustonmField15]
								,OS_Version				[CustonmField16]
								,OS_Build				[CustonmField17]
								,OS_Edition				[CustonmField18]
								,OS_BitLevel				[CustonmField19]
						for xml path(''), type		
						) X
				FROM		(
						SELECT		*
								,RANK()OVER(PARTITION BY [ParentFolder] ORDER BY [FolderName])			[PositionNr]
						FROM		@ServerList sl	
						JOIN		@ServerInfoList sil
							ON	sl.Col5 = sil.SQLName
						JOIN		@Folders fl
							ON	fl.FolderName = REPLACE(REPLACE(REPLACE(COALESCE(Col1,'--')+'\'+COALESCE(Col2,'--')+'\'+COALESCE(Col3,'--')+'\'+COALESCE(Col4,'--'),'\--',''),'\--',''),'\--','')
						) T1
				) [KeyValuePairs]
		cross apply [KeyValuePairs].X.nodes('/*') as T2(N)
		) [KeyValuePairs]
FOR XML AUTO, ELEMENTS, ROOT('NewDataSet')
)

--SET @XML.modify('
--insert <?xml version="1.0" standalone="yes"?> 
--as first
--into (/NewDataSet)[1]') 
 
--SET @xml.modify('insert attribute schemaVersion{"1"} as last into (RDCMan)[1]')


SELECT cast(@XML as XML)



exec dbaadmin.dbo.dbasp_FileAccess_Write @XML, 'C:\','Royal_TS.rtsx',0









--select T2.N.value('local-name(.)', 'nvarchar(128)') as [Key],
--       T2.N.value('.', 'nvarchar(max)') as Value
--from (select *
--      from @T
--      for xml path(''), type) as T1(X)
--  cross apply T1.X.nodes('/*') as T2(N)