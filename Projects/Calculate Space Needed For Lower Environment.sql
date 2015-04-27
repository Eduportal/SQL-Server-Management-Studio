




--DECLARE			@Results		TABLE
--				(
--				EnvNum		SYSNAME
--				,SQLName	SYSNAME
--				,DBName		SYSNAME
--				,DEPLStatus	CHAR(1)
--				)
				
--INSERT INTO		@Results
--SELECT			DISTINCT
--				DI.ENVnum
--				,SI.SQLName
--				,DI.DBName
--				,DI.DEPLstatus
--FROM			[dbacentral].dbo.DBA_DBInfo			DI
--JOIN			[dbacentral].dbo.ServerInfo		    SI
--		ON		DI.SQLName = SI.SQLName
--WHERE			DI.DBName IN	(
--								'ArtistListing'        
--								,'AssetKeyword'        
--								,'Bundle20'        
--								,'CommerceService'        
--								,'CRMexport'        
--								,'DataExtract'        
--								,'DeliveryLog'        
--								,'Discovery'        
--								,'DynamicSortOrder'        
--								,'Getty_Images_US_Inc__METABASE'        
--								,'Getty_Images_US_Inc__MSCRM'        
--								,'Getty_Images_US_Inc_Custom'        
--								,'GimBroker'        
--								,'GSsearch'        
--								,'Hardgood_Assets'        
--								,'iLoc'        
--								,'KeywordLookup'        
--								,'LocalizationLookup'        
--								,'LocalMusicPlatform'        
--								,'Mercury'        
--								,'MessageQueue'        
--								,'MetadataRevisionTool'        
--								,'MSCRM_CONFIG'        
--								,'PACueSheet'        
--								,'PriceUpdate'        
--								,'Product'        
--								,'ProductCatalog'        
--								,'PumpAudio_Live'        
--								,'PumpAudioWeb'        
--								,'RightsPrice'        
--								,'SoundtrackDB'        
--								,'StackFactors'        
--								,'STPS'        
--								,'TEAMSDataMart'        
--								,'Unauth'        
--								,'VocabularyTool'        
--								,'WCDS'        
--								,'WCDSarchive'        
--								,'WCDSwork'
--								)
--		AND		DI.ENVNum	= 'test04'
--		AND		SI.Active = 'Y'	


--INSERT INTO		@Results
--SELECT			DISTINCT
--				DI.ENVnum
--				,SI.SQLName
--				,DI.DBName
--				,DI.DEPLstatus
--FROM			[dbacentral].dbo.DBA_DBInfo			DI
--JOIN			[dbacentral].dbo.ServerInfo		    SI
--		ON		DI.SQLName = SI.SQLName
--LEFT JOIN		@Results R
--		ON		R.DBName = DI.DBName
--WHERE			DI.DBName IN	(
--								'ArtistListing'        
--								,'AssetKeyword'        
--								,'Bundle20'        
--								,'CommerceService'        
--								,'CRMexport'        
--								,'DataExtract'        
--								,'DeliveryLog'        
--								,'Discovery'        
--								,'DynamicSortOrder'        
--								,'Getty_Images_US_Inc__METABASE'        
--								,'Getty_Images_US_Inc__MSCRM'        
--								,'Getty_Images_US_Inc_Custom'        
--								,'GimBroker'        
--								,'GSsearch'        
--								,'Hardgood_Assets'        
--								,'iLoc'        
--								,'KeywordLookup'        
--								,'LocalizationLookup'        
--								,'LocalMusicPlatform'        
--								,'Mercury'        
--								,'MessageQueue'        
--								,'MetadataRevisionTool'        
--								,'MSCRM_CONFIG'        
--								,'PACueSheet'        
--								,'PriceUpdate'        
--								,'Product'        
--								,'ProductCatalog'        
--								,'PumpAudio_Live'        
--								,'PumpAudioWeb'        
--								,'RightsPrice'        
--								,'SoundtrackDB'        
--								,'StackFactors'        
--								,'STPS'        
--								,'TEAMSDataMart'        
--								,'Unauth'        
--								,'VocabularyTool'        
--								,'WCDS'        
--								,'WCDSarchive'        
--								,'WCDSwork'
--								)
--		AND		DI.ENVNum	= 'test02'
--		AND		SI.Active = 'Y'	
--		AND		R.DBName IS NULL



--SELECT		UserDBs.SQLName
--			, UserDBs.Apps
--			,(UserDBs.SizeMB * 2.5) + (OpsDBs.SizeMB * 1.5) [DataDriveMB]
--			,(UserDBs.SizeMB + OpsDBs.SizeMB)*.3 [LogDriveMB]
--			, UserDBs.SizeMB * .5 [SQBDriveMB]
--FROM		(
--			SELECT			CAST(DI.SQLName as VarChar(20)) SQLName
--							,SUM(CAST(DI.data_size_mb AS FLOAT)) SizeMB
--							,dbaadmin.dbo.dbaudf_ConcatenateUnique(Appl_desc) Apps
--			FROM			[dbacentral].dbo.DBA_DBInfo DI
--			JOIN			@Results R
--					ON		R.SQLName	= DI.SQLName
--					AND		R.DBName	= DI.DBName
--			GROUP BY		DI.SQLName		
--			) UserDBs

--LEFT JOIN	(
--			SELECT			DI.SQLName
--							--,DI.DBName
--							,SUM(CAST(DI.data_size_mb AS FLOAT)) SizeMB
--			FROM			[dbacentral].dbo.DBA_DBInfo DI
--			WHERE			SQLName IN	(
--										SELECT		SQLName
--										FROM		@Results
--										)
--					AND		DI.DEPLstatus = 'N'
--			GROUP BY DI.SQLName--,DI.DBName
--			) OpsDBs
--	ON		UserDBs.SQLName = OpsDBs.SQLName
			
--SELECT			DISTINCT
--				SQLName
--				,DBName
--				,Appl_desc			
--FROM			[dbacentral].dbo.DBA_DBInfo DI
--WHERE			NULLIF(Appl_desc,'') IS NOT NULL
--ORDER BY		2,1,3

--SELECT			DISTINCT
--				SQLName
--				,DBName
--				,Appl_desc			
--FROM			[dbacentral].dbo.DBA_DBInfo DI
--WHERE			NULLIF(Appl_desc,'') IS NULL
--ORDER BY		2,1,3


			
--SELECT			CAST(DI.ENVNum as VarChar(20)) ENVNum
--				,CAST(DI.SQLName as VarChar(20)) SQLName
--				,CAST(DI.Appl_desc as VarChar(20)) Appl_desc
--				--,dbaadmin.dbo.dbaudf_ConcatenateUnique(Appl_desc) Apps
--				,SUM(CAST(DI.data_size_mb AS FLOAT)) SizeMB
--FROM			[dbacentral].dbo.DBA_DBInfo DI
--WHERE			DI.ENVName IN ('Dev','Test')
--	AND			DBName Not In ('dbaadmin','dbaperf','DEPLinfo','systeminfo')
--GROUP BY		DI.ENVNum,DI.SQLName,DI.Appl_desc
--ORDER BY		1,2,3		

--SELECT			DBName
				
--FROM			[dbacentral].dbo.DBA_DBInfo DI
--WHERE			DBName Not In ('dbaadmin','dbaperf','DEPLinfo','systeminfo')

--select		DISTINCT
--			 cast(dbaadmin.dbo.ReturnWord(replace(ipnum,'.',' '),1) as Int) 
--			,cast(dbaadmin.dbo.ReturnWord(replace(ipnum,'.',' '),2) as Int) 
--			,cast(dbaadmin.dbo.ReturnWord(replace(ipnum,'.',' '),3) as Int) 
--			,MIN(cast(dbaadmin.dbo.ReturnWord(replace(ipnum,'.',' '),4) as Int))
--			,MAX(cast(dbaadmin.dbo.ReturnWord(replace(ipnum,'.',' '),4) as Int)) 
--			,count(*)
--From		dba_serverinfo
--WHERE		isnumeric(replace(ipnum,'.','')) = 1
--GROUP BY	cast(dbaadmin.dbo.ReturnWord(replace(ipnum,'.',' '),1) as Int) 
--			,cast(dbaadmin.dbo.ReturnWord(replace(ipnum,'.',' '),2) as Int) 
--			,cast(dbaadmin.dbo.ReturnWord(replace(ipnum,'.',' '),3) as Int)
			
--ORDER BY	1,2,3			

--SELECT		'        <Node Name="'+ServerName+'" Type="Connection" Descr="" Icon="Database" Panel="General" Username="" Domain="" Password="" Hostname="'+ServerName+'" Protocol="RDP" PuttySession="Default Settings" Port="3389" ConnectToConsole="False" RenderingEngine="IE" ICAEncryptionStrength="EncrBasic" RDPAuthenticationLevel="NoAuth" Colors="Colors16Bit" Resolution="FitToWindow" DisplayWallpaper="False" DisplayThemes="False" CacheBitmaps="True" RedirectDiskDrives="False" RedirectPorts="False" RedirectPrinters="False" RedirectSmartCards="False" RedirectSound="DoNotPlay" RedirectKeys="False" Connected="False" PreExtApp="" PostExtApp="" MacAddress="" UserField="" ExtApp="" VNCCompression="CompNone" VNCEncoding="EncHextile" VNCAuthMode="AuthVNC" VNCProxyType="ProxyNone" VNCProxyIP="" VNCProxyPort="0" VNCProxyUsername="" VNCProxyPassword="" VNCColors="ColNormal" VNCSmartSizeMode="SmartSAspect" VNCViewOnly="False" InheritCacheBitmaps="True" InheritColors="True" InheritDescription="False" InheritDisplayThemes="True" InheritDisplayWallpaper="True" InheritDomain="True" InheritIcon="True" InheritPanel="True" InheritPassword="True" InheritPort="True" InheritProtocol="True" InheritPuttySession="True" InheritRedirectDiskDrives="True" InheritRedirectKeys="True" InheritRedirectPorts="True" InheritRedirectPrinters="True" InheritRedirectSmartCards="True" InheritRedirectSound="True" InheritResolution="True" InheritUseConsoleSession="True" InheritRenderingEngine="True" InheritUsername="True" InheritICAEncryptionStrength="True" InheritRDPAuthenticationLevel="True" InheritPreExtApp="True" InheritPostExtApp="True" InheritMacAddress="True" InheritUserField="True" InheritExtApp="True" InheritVNCCompression="True" InheritVNCEncoding="True" InheritVNCAuthMode="True" InheritVNCProxyType="True" InheritVNCProxyIP="True" InheritVNCProxyPort="True" InheritVNCProxyUsername="True" InheritVNCProxyPassword="True" InheritVNCColors="True" InheritVNCSmartSizeMode="True" InheritVNCViewOnly="True" />'
--FROM		dba_serverinfo
--WHERE		DomainName like 's%'
--ORDER BY	ServerName

;WITH		DBSizes (DBName,DEPLstatus,SizeGB,[Servers])
AS			(
			SELECT			CAST(DI.DBName as VarChar(20)) DBName
							,MAX(DEPLstatus) DEPLstatus
							,MAX(CASE DI.DBName 
									WHEN 'dbaperf' Then 10.0 
									ELSE DI.data_size_Gb END) SizeGB
							,dbaadmin.dbo.dbaudf_Concatenate(SQLName) [Servers]
			FROM			(
							SELECT		T1.DBName
										,T1.ENVName 
										,T1.DEPLstatus
										,T1.SQLName
										,CEILING(CAST(T1.data_size_mb AS FLOAT)/1024.0) data_size_Gb
							FROM		[dbacentral].dbo.DBA_DBInfo T1
							WHERE		T1.ENVName IN ('Dev','Test')
							) DI
			GROUP BY		DI.DBName
			)
			,ServerLocations (ServerName,IPAddress,FQDN,Locationname,RackRow)
AS			(
			SELECT		DISTINCT
						S.[ShortName] [ServerName]
						,S.[HostID] [IPAddress]
						,S.[FQDN] 
						,L.[Locationname]
						,S.[RackRow]
			FROM		[SEAFRESQLBOA].[Enlighten].[dbo].[cmdbServers] S
			JOIN		[SEAFRESQLBOA].[Enlighten].[dbo].[genLocations] L
				ON		S.[Location] = L.[genLocationsID]
			)
			
SELECT		SI.ServerName
			,SL.[Locationname]
			,DI.EnvName
			,CEILING(SUM(CASE DI.DEPLstatus WHEN 'y' THEN DBS.SizeGB * 2.5 ELSE DBS.SizeGB * 1.5 END)/(CASE WHEN SUM(CASE DI.DEPLstatus WHEN 'y' THEN DBS.SizeGB * 2.5 ELSE DBS.SizeGB * 1.5 END)>=100 THEN 50 ELSE 10 END))*(CASE WHEN SUM(CASE DI.DEPLstatus WHEN 'y' THEN DBS.SizeGB * 2.5 ELSE DBS.SizeGB * 1.5 END)>=100 THEN 50 ELSE 10 END) [DataDriveGB]
			,CEILING(SUM(DBS.SizeGB * .3)/(CASE WHEN SUM(DBS.SizeGB * .3)>=100 THEN 50 ELSE 10 END))*(CASE WHEN SUM(DBS.SizeGB * .3)>=100 THEN 50 ELSE 10 END) [LogDriveGB]
			,CEILING(SUM(CASE DI.DEPLstatus WHEN 'y' THEN DBS.SizeGB * .5 ELSE 0 END)/(CASE WHEN SUM(CASE DI.DEPLstatus WHEN 'y' THEN DBS.SizeGB * .5 ELSE 0 END)>=100 THEN 50 ELSE 10 END))*(CASE WHEN SUM(CASE DI.DEPLstatus WHEN 'y' THEN DBS.SizeGB * .5 ELSE 0 END)>=100 THEN 50 ELSE 10 END) [SQBDriveGB]
			,dbaadmin.dbo.dbaudf_ConcatenateUnique(CASE WHEN SI.ServerName = SI.SQLName THEN 'MSSQL' ELSE REPLACE(SI.SQLName,SI.ServerName+'\','')END)	[Instances]
			,dbaadmin.dbo.dbaudf_ConcatenateUnique(COALESCE(DI.Appl_desc,DI2.Appl_desc)) Apps
			
FROM		[dbacentral].dbo.DBA_DBInfo			DI
JOIN		[dbacentral].dbo.ServerInfo		    SI
		ON	DI.SQLName = SI.SQLName
LEFT JOIN	ServerLocations SL
		ON	SI.ServerName = SL.ServerName
JOIN		(
			SELECT		DBName
						,MAX(Appl_desc) Appl_desc 
			FROM		[dbacentral].dbo.DBA_DBInfo 
			Group By	DBName
			) DI2
		ON	DI.DBName = DI2.DBName
LEFT JOIN	DBSizes DBS
		ON	DBS.DBName = DI.DBName
WHERE		SI.ServerName IN
			(
			'ASPSQLDEV01'
			,'CATSQLDEV01'
			,'CRMSQLDEV02'
			,'DEVSHSQL01'
			,'DEVSHSQL02'
			,'FREDMRTSQL01'
			,'FREDMRTSQL02'
			,'FREDRZTSQL01'
			,'GINSSQLDEV01'
			,'GINSSQLDEV02'
			,'GINSSQLDEV04'
			,'GMSSQLDEV01'
			,'GMSSQLDEV02'
			,'GMSSQLDEV04'
			,'PCSQLDEV01'
			,'SEAFRESQLTALS01'
			,'SEAFRESQLTALS02'
			,'FREBGMSSQLA01'
			,'FREBGMSSQLB01'
			,'FREBPCXSQL01'
			,'FREBSHWSQL01'
			,'ASPSQLTEST01'
			,'CRMSQLTEST01'
			,'CRMSQLTEST02'
			,'FREASHWSQL01'
			,'FRECASPSQL01'
			,'FRECGMSSQLA01'
			,'FRECGMSSQLB01'
			,'FRECPCXSQL01'
			,'FRECSHWSQL01'
			,'FREPTSSQL01'
			,'FRETCRMSQL04'
			,'FRETMRTSQL01'
			,'FRETMRTSQL02'
			,'FRETRZTSQL01'
			,'GINSSQLTEST01'
			,'GINSSQLTEST02'
			,'GINSSQLTEST03'
			,'GINSSQLTEST04'
			,'GMSSQLTEST01'
			,'GMSSQLTEST02'
			,'GMSSQLTEST03'
			,'GMSSQLTEST04'
			,'PCSQLTEST01'
			,'TESTSHSQL01'
			,'TESTSHSQL02'
			,'ASPSQLLOAD01'
			,'FRELASPSQL02'
			,'FRELLNPSQL01'
			,'FRELRZTSQL01'
			,'FRELSHLSQL01'
			,'GMSSQLLOAD02'
			,'PCSQLLOAD02'
			,'PCSQLLOADA'
			,'SHAREDSQLLOAD01'
			,'SHAREDSQLLOAD02'
			)
--WHERE		DI.EnvName IN ('dev','test')
GROUP BY	SI.ServerName,SL.[Locationname],DI.EnvName
ORDER BY	3,1

GO


select		*
FROM		[dbacentral].dbo.DBA_DiskInfo			
			



--select * 
--From [dbacentral].dbo.DBA_ServerInfo T1
--join [SEAFRESQLBOA].[Enlighten].[dbo].[Servers] T2
--	ON T1.ServerName = T2.[ShortName]

--where dbname = 'enlighten'

--SELECT [cmdbServersID]
--      ,[ShortName]
--      ,[HostID]
--      ,[IPAddress]
--      ,[FQDN]
--      ,[SerialNumber]
--      ,[DeviationStdBuild]
--      ,[AssetID]
--      ,[Domain]
--      ,[DomainName]
--      ,[BackupClass]
--      ,[BackupClassName]
--      ,[Environment]
--      ,[EnvironmentName]
--      ,[SLA]
--      ,[SLAName]
--      ,[StdBuild]
--      ,[StandardBuildName]
--      ,[Location]
--      ,[Locationname]
--      ,[RackRow]
--      ,[SystemFamily]
--      ,[AIMSSystemFamilyName]
--      ,[EnlightenSystemID]
--      ,[EnligthenSystemName]
--      ,[Customer]
--      ,[CustomerName]
--      ,[QAContact]
--      ,[QAContactName]
--      ,[CustomerNotes]
--      ,[Owner]
--      ,[OwnerName]
--      ,[LocationContact]
--      ,[LocationContactName]
--      ,[ServerType]
--      ,[ServerTypeName]
--      ,[Manufacturer]
--      ,[ManufacturerName]
--      ,[Model]
--      ,[ModelName]
--      ,[Region]
--      ,[RegionName]
--      ,[DataCenterAlertCondition]
--      ,[DataCenterAlertConditionName]
--      ,[MaintenanceWindow]
--      ,[NotificationGroups]
--      ,[NotificationGroupName]
--      ,[Retired]
--      ,[PONumber]
--      ,[AcquisitionDate]
--      ,[Notes]
--      ,[genSubLocationsID]
--      ,[SublocationName]
--      ,[cmdbDeviceTypeID]
--      ,[DeviceTypeName]
--      ,[cmdbVM_ClusterID]
--      ,[VM_ClusterName]
--      ,[cmdbBladeChassisID]
--      ,[BladeChassisName]
--  FROM [SEAFRESQLBOA].[Enlighten].[dbo].[Servers]
--GO







--SELECT		DISTINCT
--			SQLName
--			,DBName
--			,Appl_desc
			
			
--FROM		[dbacentral].dbo.DBA_DBInfo
--WHERE		SQLName = 'FREBASPSQL01\A'
--WHERE		DBName Not In ('dbaadmin','dbaperf','DEPLinfo','systeminfo')
--ORDER BY	2,1,3





--SELECT		DI.*
--FROM		[dbacentral].dbo.DBA_DBInfo	DI
--JOIN		(
--			SELECT		[db_name] DBName
--						,MIN([RSTRfolder]) [RSTRfolder]
--			FROM		[DEPLcontrol].[dbo].[db_BaseLocation]
--			WHERE		nullif(companionDB_name,'') IS NULL
--			GROUP BY	[db_name]
--			) BL
--	ON		DI.DBName	= BL.DBName	
--WHERE		DI.Appl_desc IS NULL

--UPDATE		DI
--	SET		BaselineFolder	= RSTRfolder
--			, Appl_desc		= Appl_desc2
--FROM		[dbacentral].dbo.DBA_DBInfo	DI
--JOIN		(
--			SELECT		DISTINCT
--						DI1.DBName
--						,DI1.BaselineFolder
--						,DI1.Appl_desc
--						,BL.RSTRfolder
--						,BtoA.Appl_desc Appl_desc2
--			FROM		[dbacentral].dbo.DBA_DBInfo	DI1
--			JOIN		[dbacentral].dbo.DBA_DBInfo	DI2
--				ON		DI1.SQLName = DI2.SQLName
--			JOIN		[DEPLcontrol].[dbo].[db_BaseLocation] BL
--				ON		(
--						DI1.DBName = BL.[db_name]
--				AND		DI2.DBName = BL.[companionDB_name]
--						)
--				OR		(
--						DI1.DBName = BL.[db_name]
--				AND		nullif(BL.companionDB_name,'') IS NULL
--						)
--			JOIN		(
--						SELECT	DISTINCT
--								BaselineFolder
--								,MIN(Appl_desc) Appl_desc
--						FROM	[dbacentral].dbo.DBA_DBInfo	DI1
--						GROUP BY BaselineFolder
--						) BtoA
--				ON		BtoA.BaselineFolder = BL.RSTRfolder
				
--			WHERE		nullif(DI1.BaselineFolder,'')	IS NULL
--					OR	nullif(DI1.Appl_desc,'')		IS NULL
--			) T2
--		ON	Di.DBName = T2.DBName



--			SELECT		DISTINCT
--						DI1.DBName
--						,DI1.BaselineFolder
--						,DI1.Appl_desc
--						,BL.RSTRfolder
--						,BtoA.Appl_desc Appl_desc2
--			FROM		[dbacentral].dbo.DBA_DBInfo	DI1
--			JOIN		[dbacentral].dbo.DBA_DBInfo	DI2
--				ON		DI1.SQLName = DI2.SQLName
--			JOIN		[dbacentral].[dbo].[db_ApplCrossRef] CR
--				ON		(
--						DI1.DBName = BL.[db_name]
--				AND		DI2.DBName = BL.[companionDB_name]
--						)
--				OR		(
--						DI1.DBName = BL.[db_name]
--				AND		nullif(BL.companionDB_name,'') IS NULL
--						)

--		SELECT		*
--		--UPDATE		DI
--		--	SET		Appl_desc		= T2.Appl_desc
--		--			,BaselineFolder	= ISNULL(T2.RSTRfolder,'')
--		FROM		[dbacentral].dbo.DBA_DBInfo DI
--		JOIN		(
--					SELECT		DISTINCT
--								T1A.SQLName
--								,T1A.DBName
--								,COALESCE(T1C.DBName_Cleaned,T1A.DBName)	DB_Name
--								,COALESCE(T1D.DBName_Cleaned,T1B.DBName)	companionDB_name
--					FROM		[dbacentral].dbo.DBA_DBInfo			T1A
--					JOIN		[dbacentral].dbo.DBA_DBInfo			T1B
--						ON		T1A.SQLName = T1B.SQLName

--					LEFT JOIN	[dbacentral].dbo.DBA_DBNameCleaner	T1C
--						ON		T1A.DBName = T1C.DBName
					
--					LEFT JOIN	[dbacentral].dbo.DBA_DBNameCleaner	T1D
--						ON		T1B.DBName = T1D.DBName		
--					) T1		
--			ON		DI.SQLName = T1.SQLName
--			AND		DI.DBName = T1.DBName
--		JOIN		[dbacentral].dbo.db_ApplCrossRef		T2
--			ON		T1.DB_Name = REPLACE(T2.DB_Name,'*','')
--			AND		(
--					T1.companionDB_name = T2.companionDB_name
--					OR
--					nullif(T2.companionDB_name,'') IS NULL
--					)
--		WHERE		isNull(DI.Appl_desc,'') != isNull(T2.Appl_desc,'')
--			AND		DI.SQLName NOT IN ('SEAFRESQLRPT01')


--		UPDATE		[dbacentral].dbo.DBA_DBInfo 
--			SET		Appl_Desc = Case
--									WHEN DBName IN ('deplinfo','deplcontrol','gears') THEN 'Operations'
--									WHEN SQLName LIKE '%SQLRYL%' THEN 'Alliant'
--									WHEN SQLName LIKE 'NYMV%' THEN 'MediaVast'
--									WHEN DBName Like '%citrix%' THEN 'Citrix'
--									ELSE Appl_Desc
--									END 
		
--		WHERE		nullif(Appl_Desc,'') IS NULL 
--			AND		DEPLStatus = 'n'
			
--SELECT			* 
--FROM			[dbacentral].dbo.DBA_DBInfo T1
--JOIN			(SELECT DISTINCT DBName,BaselineServerName,Appl_Desc,BaselineFolder FROM [dbacentral].dbo.DBA_DBInfo WHERE nullif(Appl_Desc,'') IS NOT NULL) T2
--	ON			T1.DBName = T2.DBName
--	AND			T1.BaselineServerName = T2.BaselineServerName
	
--WHERE			nullif(T1.Appl_Desc,'') IS NULL 
--	AND			nullif(T2.Appl_Desc,'') IS NOT NULL 

--ORDER BY		T1.DBName,T1.SQLName








--SELECT * FROM [dbacentral].dbo.DBA_ServerInfo
--SELECT * FROM [dbacentral].[dbo].[db_ApplCrossRef] ORDER BY 5
--SELECT * FROM [dbacentral].dbo.DBA_DBNameCleaner
--SELECT DISTINCT DBName FROM [dbacentral].dbo.DBA_DBInfo WHERE nullif(Appl_Desc,'') IS NULL --SQLName = 'ASPSQLDEV01\A'

--SELECT * FROM [dbacentral].dbo.DBA_DBInfo WHERE nullif(Appl_Desc,'') IS NULL ORDER BY EnvNum,DBName,SQLName

--SELECT			CASE WHEN T3.ServerName = T3.SQLName THEN '' ELSE REPLACE(T3.SQLName,T3.ServerName,'')END InstName
--				,REPLACE(REPLACE(REPLACE(REPLACE(T3.ServerName,'seafre',''),'fres',''),'fred',''),'frep','') ServerName_Striped_01
--				,T2.*,T1.* 
--FROM			[dbacentral].dbo.DBA_DBInfo t1
--JOIN			(
--				SELECT		SQLName
--							,dbaadmin.dbo.dbaudf_ConcatenateUnique(Appl_desc) Appl_desc
--				FROM		[dbacentral].dbo.DBA_DBInfo	DI
--				WHERE		nullif(DI.Appl_desc,'') IS NOT NULL
--				GROUP BY	SQLName
--				) t2
--		--ON		T1.SQLName = T2.SQLName
--		ON		RIGHT(STUFF(T1.SQLName,1,4,''),LEN(T1.SQLName)-6) = RIGHT(STUFF(T2.SQLName,1,4,''),LEN(T2.SQLName)-6)		
--JOIN			[dbacentral].dbo.DBA_ServerInfo T3
--		ON		T1.SQLName = T3.SQLName
--WHERE			T1.DBName IN ('ReportServer','Reports_Work','ReportServerTempDB') 
--		AND		T1.Appl_desc NOT IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_Split(T1.Appl_desc,','))
--order by		T1.DBName,T1.SQLName



--SELECT			*
--FROM			(
--				SELECT			DISTINCT
--								ServerName
--								,SQLName
--								,InstName
--								,EnvName
--								,Env_Number
--								,EnvNum
--								,DBName
--								,REPLACE(REPLACE(REPLACE(ServerName_Striped_01,EnvNum,''),EnvName,''),Env_Number,'') ServerName_Striped_02
--				FROM			(
--								SELECT			DISTINCT
--												COALESCE(T3.DBName_Cleaned,T1.DBName) DBName
--												,T1.SQLName
--												,T2.ServerName
--												,CASE WHEN T2.ServerName = T2.SQLName THEN '' ELSE REPLACE(T2.SQLName,T2.ServerName,'')END InstName
--												,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(T2.ServerName,'seafre',''),'fres',''),'fred',''),'frep',''),'frel','') ServerName_Striped_01
--												,T1.EnvName
--												,REPLACE(T1.EnvNum,T1.EnvName,'') Env_Number
--												,T1.EnvNum
--												,T1.Appl_desc
--								FROM			[dbacentral].dbo.DBA_DBInfo t1
--								JOIN			[dbacentral].dbo.DBA_ServerInfo T2
--										ON		T1.SQLName = T2.SQLName
--								LEFT JOIN		[dbacentral].dbo.DBA_DBNameCleaner	T3
--										ON		T1.DBName = T3.DBName	
--								WHERE			nullif(T1.Appl_desc,'') IS NULL
--								) T1
--				) T1
--JOIN			(
--				SELECT			ServerName
--								,SQLName
--								,InstName
--								,EnvName
--								,Env_Number
--								,EnvNum
--								,DBName
--								,REPLACE(REPLACE(REPLACE(ServerName_Striped_01,EnvNum,''),EnvName,''),Env_Number,'') ServerName_Striped_02
--								,dbaadmin.dbo.dbaudf_ConcatenateUnique(Appl_desc) Appl_desc
--				FROM			(
--								SELECT			DISTINCT
--												COALESCE(T3.DBName_Cleaned,T1.DBName) DBName
--												,T1.SQLName
--												,T2.ServerName
--												,CASE WHEN T2.ServerName = T2.SQLName THEN '' ELSE REPLACE(T2.SQLName,T2.ServerName,'')END InstName
--												,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(T2.ServerName,'seafre',''),'fres',''),'fred',''),'frep',''),'frel','') ServerName_Striped_01
--												,T1.EnvName
--												,REPLACE(T1.EnvNum,T1.EnvName,'') Env_Number
--												,T1.EnvNum
--												,T1.Appl_desc
--								FROM			[dbacentral].dbo.DBA_DBInfo t1
--								JOIN			[dbacentral].dbo.DBA_ServerInfo T2
--										ON		T1.SQLName = T2.SQLName
--								LEFT JOIN		[dbacentral].dbo.DBA_DBNameCleaner	T3
--										ON		T1.DBName = T3.DBName	
--								WHERE			Nullif(nullif(T1.Appl_desc,''),'Operations') IS NOT NULL
--								) T1
--				GROUP BY		ServerName
--								,SQLName
--								,InstName
--								,EnvName
--								,Env_Number
--								,EnvNum
--								,DBName
--								,REPLACE(REPLACE(REPLACE(ServerName_Striped_01,EnvNum,''),EnvName,''),Env_Number,'')
--				) T2		
--		ON		T1.DBName = T2.DBName
--		AND		T1.ServerName_Striped_02 = T2.ServerName_Striped_02









--UPDATE		[dbacentral].dbo.DBA_DBInfo	
--	SET		Appl_desc		= 'Operations Database'
--WHERE		nullif(Appl_desc,'')		IS NULL
--		AND	DBName IN ('dbaadmin','dbaperf','DEPLinfo','systeminfo')



--UPDATE		[dbacentral].dbo.DBA_DBInfo	
--	SET		Appl_desc		= CASE
--								WHEN DBName Like 'alliant%' THEN 'Alliant'
--								WHEN DBName Like 'bundle%' THEN 'Bundle'
								
--								END
--WHERE		nullif(Appl_desc,'')		IS NULL
--	AND		DBName NOT IN ('dbaadmin','dbaperf','DEPLinfo','systeminfo')

	
--SELECT		*
--FROM		[dbacentral].dbo.DBA_DBInfo	DI
--WHERE		nullif(DI.Appl_desc,'')		IS NULL
--	AND		SQLName Not Like 'sqldeployer%'
--	AND		SQLName != 'SEAFRESQLDBA01'
--ORDER BY	2	

--SELECT		DISTINCT
--			DBName
--			,Appl_desc
--FROM		[dbacentral].dbo.DBA_DBInfo	DI
--WHERE		nullif(DI.Appl_desc,'')		IS NOT NULL
--ORDER BY	2			