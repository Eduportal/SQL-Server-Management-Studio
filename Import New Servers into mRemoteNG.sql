IF EXISTS
(
SELECT * FROM sys.sysprocesses 
WHERE hostprocess IN	(
			select DISTINCT hostprocess From sys.sysprocesses
			WHERE	DB_NAME(dbid) = 'mRemoteNG'
			  AND	program_name = '.Net SqlClient Data Provider'
			)
)
BEGIN
	RAISERROR('Update Cannot be performed while users are connected to database with mRemoteNG',16,1) WITH NOWAIT
	--RETURN -1
END

-- CLOSE ALL EXPANDED BRANCHES
UPDATE	[mRemoteNG].[dbo].[tblCons]
  SET	Expanded = 0

--DELETE ALL ENTRIES IN THE DOMAIN GROUPS
DELETE
		[mRemoteNG].[dbo].[tblCons]
WHERE		ParentID IN	(
				SELECT		DISTINCT
						(SELECT		ConstantID 
							FROM		[mRemoteNG].[dbo].[tblCons]
							WHERE		TYPE		= 'Container' 
								AND	NAME		= T1.DomainName
								AND	ParentID	= (SELECT ConstantID FROM [mRemoteNG].[dbo].[tblCons] WHERE TYPE = 'Container' AND NAME = 'MSSQL'))[ParentID]
				FROM		dbacentral.dbo.DBA_ServerInfo T1
				WHERE		Active = 'Y'
				)


-- POPULATE NEW ENTRIES
INSERT INTO [mRemoteNG].[dbo].[tblCons]
           ([ConstantID]
           ,[PositionID]
           ,[ParentID]
           ,[LastChange]
           ,[Name]
           ,[Type]
           ,[Expanded]
           ,[Description]
           ,[Icon]
           ,[Panel]
           ,[Username]
           ,[DomainName]
           ,[Password]
           ,[Hostname]
           ,[Protocol]
           ,[PuttySession]
           ,[Port]
           ,[ConnectToConsole]
           ,[UseCredSsp]
           ,[RenderingEngine]
           ,[ICAEncryptionStrength]
           ,[RDPAuthenticationLevel]
           ,[Colors]
           ,[Resolution]
           ,[DisplayWallpaper]
           ,[DisplayThemes]
           ,[EnableFontSmoothing]
           ,[EnableDesktopComposition]
           ,[CacheBitmaps]
           ,[RedirectDiskDrives]
           ,[RedirectPorts]
           ,[RedirectPrinters]
           ,[RedirectSmartCards]
           ,[RedirectSound]
           ,[RedirectKeys]
           ,[Connected]
           ,[PreExtApp]
           ,[PostExtApp]
           ,[MacAddress]
           ,[UserField]
           ,[ExtApp]
           ,[VNCCompression]
           ,[VNCEncoding]
           ,[VNCAuthMode]
           ,[VNCProxyType]
           ,[VNCProxyIP]
           ,[VNCProxyPort]
           ,[VNCProxyUsername]
           ,[VNCProxyPassword]
           ,[VNCColors]
           ,[VNCSmartSizeMode]
           ,[VNCViewOnly]
           ,[RDGatewayUsageMethod]
           ,[RDGatewayHostname]
           ,[RDGatewayUseConnectionCredentials]
           ,[RDGatewayUsername]
           ,[RDGatewayPassword]
           ,[RDGatewayDomain]
           ,[InheritCacheBitmaps]
           ,[InheritColors]
           ,[InheritDescription]
           ,[InheritDisplayThemes]
           ,[InheritDisplayWallpaper]
           ,[InheritEnableFontSmoothing]
           ,[InheritEnableDesktopComposition]
           ,[InheritDomain]
           ,[InheritIcon]
           ,[InheritPanel]
           ,[InheritPassword]
           ,[InheritPort]
           ,[InheritProtocol]
           ,[InheritPuttySession]
           ,[InheritRedirectDiskDrives]
           ,[InheritRedirectKeys]
           ,[InheritRedirectPorts]
           ,[InheritRedirectPrinters]
           ,[InheritRedirectSmartCards]
           ,[InheritRedirectSound]
           ,[InheritResolution]
           ,[InheritUseConsoleSession]
           ,[InheritUseCredSsp]
           ,[InheritRenderingEngine]
           ,[InheritICAEncryptionStrength]
           ,[InheritRDPAuthenticationLevel]
           ,[InheritUsername]
           ,[InheritPreExtApp]
           ,[InheritPostExtApp]
           ,[InheritMacAddress]
           ,[InheritUserField]
           ,[InheritExtApp]
           ,[InheritVNCCompression]
           ,[InheritVNCEncoding]
           ,[InheritVNCAuthMode]
           ,[InheritVNCProxyType]
           ,[InheritVNCProxyIP]
           ,[InheritVNCProxyPort]
           ,[InheritVNCProxyUsername]
           ,[InheritVNCProxyPassword]
           ,[InheritVNCColors]
           ,[InheritVNCSmartSizeMode]
           ,[InheritVNCViewOnly]
           ,[InheritRDGatewayUsageMethod]
           ,[InheritRDGatewayHostname]
           ,[InheritRDGatewayUseConnectionCredentials]
           ,[InheritRDGatewayUsername]
           ,[InheritRDGatewayPassword]
           ,[InheritRDGatewayDomain]
           ,[LoadBalanceInfo]
           ,[AutomaticResize]
           ,[InheritLoadBalanceInfo]
           ,[InheritAutomaticResize])

SELECT NewID() [ConstantID]
	,(SELECT MAX(PositionID) FROM [mRemoteNG].[dbo].[tblCons]) + ROW_NUMBER() OVER(ORDER BY [ServerName]) [PositionID]
	,(SELECT	ConstantID 
		FROM	[mRemoteNG].[dbo].[tblCons]
		WHERE	TYPE		= 'Container' 
		  AND	NAME		= T1.DomainName
		  AND	ParentID	= (SELECT ConstantID FROM [mRemoteNG].[dbo].[tblCons] WHERE TYPE = 'Container' AND NAME = 'MSSQL'))[ParentID]
      ,GetDate() [LastChange]
      ,UPPER(T1.ServerName) [Name]
      ,'Connection'[Type]
      ,0 [Expanded]
      ,'' [Description]
      ,'mRemoteNG' [Icon]
      ,'General' [Panel]
      ,'' [Username]
      ,'' [DomainName]
      ,'' [Password]
      ,UPPER(T1.FQDN) [Hostname]
      ,'RDP' [Protocol]
      ,'Default Settings' [PuttySession]
      ,3389 [Port]
      ,0 [ConnectToConsole]
      ,1 [UseCredSsp]
      ,'IE' [RenderingEngine]
      ,'EncrBasic' [ICAEncryptionStrength]
      ,'NoAuth' [RDPAuthenticationLevel]
      ,'Colors16Bit' [Colors]
      ,'FitToWindow' [Resolution]
      ,0 [DisplayWallpaper]
      ,0 [DisplayThemes]
      ,0 [EnableFontSmoothing]
      ,0 [EnableDesktopComposition]
      ,1 [CacheBitmaps]
      ,0 [RedirectDiskDrives]
      ,0 [RedirectPorts]
      ,0 [RedirectPrinters]
      ,0 [RedirectSmartCards]
      ,'DoNotPlay' [RedirectSound]
      ,0 [RedirectKeys]
      ,0 [Connected]
      ,'' [PreExtApp]
      ,'' [PostExtApp]
      ,'' [MacAddress]
      ,'' [UserField]
      ,'' [ExtApp]
      ,'CompNone' [VNCCompression]
      ,'EncHextile' [VNCEncoding]
      ,'AuthVNC' [VNCAuthMode]
      ,'ProxyNone' [VNCProxyType]
      ,'' [VNCProxyIP]
      ,0 [VNCProxyPort]
      ,'' [VNCProxyUsername]
      ,'' [VNCProxyPassword]
      ,'ColNormal' [VNCColors]
      ,'SmartSAspect' [VNCSmartSizeMode]
      ,0 [VNCViewOnly]
      ,'Never' [RDGatewayUsageMethod]
      ,'' [RDGatewayHostname]
      ,'Yes' [RDGatewayUseConnectionCredentials]
      ,'' [RDGatewayUsername]
      ,'' [RDGatewayPassword]
      ,'' [RDGatewayDomain]
      ,1 [InheritCacheBitmaps]
      ,1 [InheritColors]
      ,1 [InheritDescription]
      ,1 [InheritDisplayThemes]
      ,1 [InheritDisplayWallpaper]
      ,1 [InheritEnableFontSmoothing]
      ,1 [InheritEnableDesktopComposition]
      ,1 [InheritDomain]
      ,1 [InheritIcon]
      ,1 [InheritPanel]
      ,1 [InheritPassword]
      ,1 [InheritPort]
      ,1 [InheritProtocol]
      ,1 [InheritPuttySession]
      ,1 [InheritRedirectDiskDrives]
      ,1 [InheritRedirectKeys]
      ,1 [InheritRedirectPorts]
      ,1 [InheritRedirectPrinters]
      ,1 [InheritRedirectSmartCards]
      ,1 [InheritRedirectSound]
      ,1 [InheritResolution]
      ,1 [InheritUseConsoleSession]
      ,1 [InheritUseCredSsp]
      ,1 [InheritRenderingEngine]
      ,1 [InheritICAEncryptionStrength]
      ,1 [InheritRDPAuthenticationLevel]
      ,1 [InheritUsername]
      ,1 [InheritPreExtApp]
      ,1 [InheritPostExtApp]
      ,1 [InheritMacAddress]
      ,1 [InheritUserField]
      ,1 [InheritExtApp]
      ,1 [InheritVNCCompression]
      ,1 [InheritVNCEncoding]
      ,1 [InheritVNCAuthMode]
      ,1 [InheritVNCProxyType]
      ,1 [InheritVNCProxyIP]
      ,1 [InheritVNCProxyPort]
      ,1 [InheritVNCProxyUsername]
      ,1 [InheritVNCProxyPassword]
      ,1 [InheritVNCColors]
      ,1 [InheritVNCSmartSizeMode]
      ,1 [InheritVNCViewOnly]
      ,1 [InheritRDGatewayUsageMethod]
      ,1 [InheritRDGatewayHostname]
      ,1 [InheritRDGatewayUseConnectionCredentials]
      ,1 [InheritRDGatewayUsername]
      ,1 [InheritRDGatewayPassword]
      ,1 [InheritRDGatewayDomain]
      ,1 [LoadBalanceInfo]
      ,1 [AutomaticResize]
      ,1 [InheritLoadBalanceInfo]
      ,1 [InheritAutomaticResize]


FROM		(
		SELECT		DISTINCT
				DomainName
				,ServerName
				--,SQLName
				,COALESCE(FQDN,ServerName) [FQDN]
		FROM		dbacentral.dbo.DBA_ServerInfo
		WHERE		Active = 'Y'
			AND	ServerName NOT IN (SELECT Name  FROM  [mRemoteNG].[dbo].[tblCons] WHERE TYPE = 'Connection')
			AND	SQLName NOT IN (SELECT Name  FROM  [mRemoteNG].[dbo].[tblCons] WHERE TYPE = 'Connection')
		--ORDER BY	DomainName,ServerName
		) T1
ORDER BY	DomainName,ServerName



