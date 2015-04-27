use mRemote
GO

--SET NOCOUNT ON
--Go
--DELETE FROM tblRoot
--GO
--INSERT INTO tblRoot (Name, Export, Protected, ConfVersion) VALUES('Connections', 0, 'H72JLB5/aCBMZHs8WDbH+yZ9Q+mONr4bsaO025sBJ3SCq81CQVVoMsD6iB+fBZj8',2.1)
--GO
--DELETE FROM tblCons
TRUNCATE TABLE tblCons
GO
INSERT INTO tblCons (Name, Type, Expanded, Description, Icon, Panel, Username, DomainName, Password, Hostname, Protocol, PuttySession, Port, ConnectToConsole, RenderingEngine, ICAEncryptionStrength, RDPAuthenticationLevel, Colors, Resolution, DisplayWallpaper, DisplayThemes, CacheBitmaps, RedirectDiskDrives, RedirectPorts, RedirectPrinters, RedirectSmartCards, RedirectSound, RedirectKeys, Connected, PreExtApp, PostExtApp, MacAddress, UserField, ExtApp, VNCCompression, VNCEncoding, VNCAuthMode, VNCProxyType, VNCProxyIP, VNCProxyPort, VNCProxyUsername, VNCProxyPassword, VNCColors, VNCSmartSizeMode, VNCViewOnly, InheritCacheBitmaps, InheritColors, InheritDescription, InheritDisplayThemes, InheritDisplayWallpaper, InheritDomain, InheritIcon, InheritPanel, InheritPassword, InheritPort, InheritProtocol, InheritPuttySession, InheritRedirectDiskDrives, InheritRedirectKeys, InheritRedirectPorts, InheritRedirectPrinters, InheritRedirectSmartCards, InheritRedirectSound, InheritResolution, InheritUseConsoleSession, InheritRenderingEngine, InheritUsername, InheritICAEncryptionStrength, InheritRDPAuthenticationLevel, InheritPreExtApp, InheritPostExtApp, InheritMacAddress, InheritUserField, InheritExtApp, InheritVNCCompression, InheritVNCEncoding, InheritVNCAuthMode, InheritVNCProxyType, InheritVNCProxyIP, InheritVNCProxyPort, InheritVNCProxyUsername, InheritVNCProxyPassword, InheritVNCColors, InheritVNCSmartSizeMode, InheritVNCViewOnly, PositionID, ParentID, ConstantID, LastChange)VALUES ('GettyImages','Container',1,'','mRemote','General','','','','','RDP','Default Settings','3389',0,'IE','EncrBasic','NoAuth','Colors16Bit','FitToWindow',0,0,1,0,0,0,0,'DoNotPlay',0,0,'','','','','','CompNone','EncHextile','AuthVNC','ProxyNone','','0','','','ColNormal','SmartSAspect',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,2009121513584795264719,'20091215 13:58:56')
GO

DECLARE @LastPosition INT
DECLARE @LastID INT
DECLARE @ServerList Table
(
Col1 VarChar(max)
,Col2 VarChar(max)
,Col3 VarChar(max)
,Col4 VarChar(max)
,Col5 VarChar(max)
,Col6 VarChar(max)
)
INSERT INTO @ServerList (Col1,Col2,Col3,Col4)--,Col5,Col6)
SELECT		DISTINCT
			CASE Active WHEN 'Y' THEN 'ACTIVE' ELSE 'NOT ACTIVE' END Active
			,UPPER(DomainName) DomainName
			,UPPER([SQLEnv]) Environment
			,UPPER([ServerName]) SQLInstance
			--,'Apps(' + COALESCE(SEAFRESQLDBA01.DBAcentral.dbo.ServerDBApps([SQLName]),'')+')' Apps
			--,'DBs(' + COALESCE(SEAFRESQLDBA01.DBAcentral.dbo.ServerDBs([SQLName]),'')+')' DBs
FROM		SEAFRESQLDBA01.[DBAcentral].[dbo].[DBA_ServerInfo]
ORDER BY	1,2,3,4

Select @LastPosition = max(PositionID), @LastID = MAX(ID) FROM tblCons

INSERT INTO tblCons ([ConstantID], [PositionID], [ParentID], [LastChange]
			, [Name], [Type], [Expanded], [Description], [Icon]
			, [Panel], [Username], [DomainName], [Password], [Hostname]
			, [Protocol], [PuttySession], [Port], [ConnectToConsole]
			, [RenderingEngine], [ICAEncryptionStrength]
			, [RDPAuthenticationLevel], [Colors], [Resolution]
			, [DisplayWallpaper], [DisplayThemes], [CacheBitmaps]
			, [RedirectDiskDrives], [RedirectPorts], [RedirectPrinters]
			, [RedirectSmartCards], [RedirectSound], [RedirectKeys]
			, [Connected], [PreExtApp], [PostExtApp], [MacAddress]
			, [UserField], [ExtApp], [VNCCompression], [VNCEncoding]
			, [VNCAuthMode], [VNCProxyType], [VNCProxyIP], [VNCProxyPort]
			, [VNCProxyUsername], [VNCProxyPassword], [VNCColors]
			, [VNCSmartSizeMode], [VNCViewOnly], [InheritCacheBitmaps]
			, [InheritColors], [InheritDescription], [InheritDisplayThemes]
			, [InheritDisplayWallpaper], [InheritDomain], [InheritIcon]
			, [InheritPanel], [InheritPassword], [InheritPort]
			, [InheritProtocol], [InheritPuttySession]
			, [InheritRedirectDiskDrives], [InheritRedirectKeys]
			, [InheritRedirectPorts], [InheritRedirectPrinters]
			, [InheritRedirectSmartCards], [InheritRedirectSound]
			, [InheritResolution], [InheritUseConsoleSession]
			, [InheritRenderingEngine], [InheritICAEncryptionStrength]
			, [InheritRDPAuthenticationLevel], [InheritUsername]
			, [InheritPreExtApp], [InheritPostExtApp], [InheritMacAddress]
			, [InheritUserField], [InheritExtApp], [InheritVNCCompression]
			, [InheritVNCEncoding], [InheritVNCAuthMode]
			, [InheritVNCProxyType], [InheritVNCProxyIP]
			, [InheritVNCProxyPort], [InheritVNCProxyUsername]
			, [InheritVNCProxyPassword], [InheritVNCColors]
			, [InheritVNCSmartSizeMode], [InheritVNCViewOnly]) 

Select	--@LastID + ROW_NUMBER() OVER (ORDER BY col2) [ID]
	RIGHT('0000' + CAST(DatePart(yy,getdate())AS VarChar(4)),4)
	+ RIGHT('00' + CAST(DatePart(mm,getdate())AS VarChar(2)),2)
	+ RIGHT('00' + CAST(DatePart(dd,getdate())AS VarChar(2)),2)
	+ RIGHT('00' + CAST(DatePart(Hh,getdate())AS VarChar(2)),2)
	+ RIGHT('00' + CAST(DatePart(mi,getdate())AS VarChar(2)),2)
	+ RIGHT('00' + CAST(DatePart(ss,getdate())AS VarChar(2)),2)
	+ RIGHT('000' + CAST(DatePart(Ms,getdate())AS VarChar(3)),3)
	+ RIGHT(CAST(newid()AS VarChar(50)),5)
	, @LastPosition + ROW_NUMBER() OVER (ORDER BY col2) [PositionID]
	, (Select [ConstantID] FROM tblCons WHERE [Name] collate Latin1_General_CI_AS = 'GettyImages' ) [ParentID]
	, getdate()
	, col2
	, 'Container'
	, 'False'
	, ''
	, 'mRemote'
	, 'General'
	, ''
	, ''
	, ''
	, col2
	, 'RDP'
	, 'Default Settings'
	, 3389
	, 'False'
	, 'IE', 'EncrBasic', 'NoAuth'
	, 'Colors16Bit', 'FitToWindow'
	, 'False', 'False', 'True', 'False'
	, 'False', 'False', 'False', 'DoNotPlay'
	, 'False', 'False', '', '', '', '', ''
	, 'CompNone', 'EncHextile', 'AuthVNC'
	, 'ProxyNone', '', 0, '', ''
	, 'ColNormal', 'SmartSAspect', 'False', 'True', 'True'
	, 'False', 'True', 'True', 'True', 'True', 'True', 'True'
	, 'True', 'True', 'True', 'True', 'True', 'True', 'True'
	, 'True', 'True', 'True', 'True', 'True', 'True', 'True'
	, 'True', 'True', 'True', 'True', 'True', 'True', 'True'
	, 'True', 'True', 'True', 'True', 'True', 'True', 'True'
	, 'True', 'True', 'True'

FROM	(
	SELECT	Distinct
		col2
	FROM	@ServerList
	) data
WHERE (Select [ConstantID] FROM tblCons WHERE [Name] collate Latin1_General_CI_AS = 'GettyImages' ) IS NOT NULL 
AND col2 IS NOT NULL
	
Select @LastPosition = max(PositionID), @LastID = MAX(ID) FROM tblCons
	
INSERT INTO tblCons ([ConstantID], [PositionID], [ParentID], [LastChange]
			, [Name], [Type], [Expanded], [Description], [Icon]
			, [Panel], [Username], [DomainName], [Password], [Hostname]
			, [Protocol], [PuttySession], [Port], [ConnectToConsole]
			, [RenderingEngine], [ICAEncryptionStrength]
			, [RDPAuthenticationLevel], [Colors], [Resolution]
			, [DisplayWallpaper], [DisplayThemes], [CacheBitmaps]
			, [RedirectDiskDrives], [RedirectPorts], [RedirectPrinters]
			, [RedirectSmartCards], [RedirectSound], [RedirectKeys]
			, [Connected], [PreExtApp], [PostExtApp], [MacAddress]
			, [UserField], [ExtApp], [VNCCompression], [VNCEncoding]
			, [VNCAuthMode], [VNCProxyType], [VNCProxyIP], [VNCProxyPort]
			, [VNCProxyUsername], [VNCProxyPassword], [VNCColors]
			, [VNCSmartSizeMode], [VNCViewOnly], [InheritCacheBitmaps]
			, [InheritColors], [InheritDescription], [InheritDisplayThemes]
			, [InheritDisplayWallpaper], [InheritDomain], [InheritIcon]
			, [InheritPanel], [InheritPassword], [InheritPort]
			, [InheritProtocol], [InheritPuttySession]
			, [InheritRedirectDiskDrives], [InheritRedirectKeys]
			, [InheritRedirectPorts], [InheritRedirectPrinters]
			, [InheritRedirectSmartCards], [InheritRedirectSound]
			, [InheritResolution], [InheritUseConsoleSession]
			, [InheritRenderingEngine], [InheritICAEncryptionStrength]
			, [InheritRDPAuthenticationLevel], [InheritUsername]
			, [InheritPreExtApp], [InheritPostExtApp], [InheritMacAddress]
			, [InheritUserField], [InheritExtApp], [InheritVNCCompression]
			, [InheritVNCEncoding], [InheritVNCAuthMode]
			, [InheritVNCProxyType], [InheritVNCProxyIP]
			, [InheritVNCProxyPort], [InheritVNCProxyUsername]
			, [InheritVNCProxyPassword], [InheritVNCColors]
			, [InheritVNCSmartSizeMode], [InheritVNCViewOnly]) 

Select	--@LastID + ROW_NUMBER() OVER (ORDER BY col2,col3) [ID]
	RIGHT('0000' + CAST(DatePart(yy,getdate())AS VarChar(4)),4)
	+ RIGHT('00' + CAST(DatePart(mm,getdate())AS VarChar(2)),2)
	+ RIGHT('00' + CAST(DatePart(dd,getdate())AS VarChar(2)),2)
	+ RIGHT('00' + CAST(DatePart(Hh,getdate())AS VarChar(2)),2)
	+ RIGHT('00' + CAST(DatePart(mi,getdate())AS VarChar(2)),2)
	+ RIGHT('00' + CAST(DatePart(ss,getdate())AS VarChar(2)),2)
	+ RIGHT('000' + CAST(DatePart(Ms,getdate())AS VarChar(3)),3)
	+ RIGHT(CAST(newid()AS VarChar(50)),5)
	, @LastPosition + ROW_NUMBER() OVER (ORDER BY col2,col3) [PositionID]
	, (Select [ConstantID] FROM tblCons WHERE [Name] collate Latin1_General_CI_AS = Data.Col2 ) [ParentID]
	, getdate()
	, col3
	, 'Container'
	, 'False'
	, ''
	, 'mRemote'
	, 'General'
	, ''
	, ''
	, ''
	, col3
	, 'RDP'
	, 'Default Settings'
	, 3389
	, 'False'
	, 'IE', 'EncrBasic', 'NoAuth'
	, 'Colors16Bit', 'FitToWindow'
	, 'False', 'False', 'True', 'False'
	, 'False', 'False', 'False', 'DoNotPlay'
	, 'False', 'False', '', '', '', '', ''
	, 'CompNone', 'EncHextile', 'AuthVNC'
	, 'ProxyNone', '', 0, '', ''
	, 'ColNormal', 'SmartSAspect', 'False', 'True', 'True'
	, 'False', 'True', 'True', 'True', 'True', 'True', 'True'
	, 'True', 'True', 'True', 'True', 'True', 'True', 'True'
	, 'True', 'True', 'True', 'True', 'True', 'True', 'True'
	, 'True', 'True', 'True', 'True', 'True', 'True', 'True'
	, 'True', 'True', 'True', 'True', 'True', 'True', 'True'
	, 'True', 'True', 'True'

FROM	(
	SELECT	Distinct
		col2
		,col3
	FROM	@ServerList
	) data
WHERE	(Select [ConstantID] FROM tblCons WHERE [Name] collate Latin1_General_CI_AS = Data.Col2 ) IS NOT NULL	
	
--Select @LastPosition = max(PositionID), @LastID = MAX(ID) FROM tblCons
	
--INSERT INTO tblCons ([ConstantID], [PositionID], [ParentID], [LastChange]
--			, [Name], [Type], [Expanded], [Description], [Icon]
--			, [Panel], [Username], [DomainName], [Password], [Hostname]
--			, [Protocol], [PuttySession], [Port], [ConnectToConsole]
--			, [RenderingEngine], [ICAEncryptionStrength]
--			, [RDPAuthenticationLevel], [Colors], [Resolution]
--			, [DisplayWallpaper], [DisplayThemes], [CacheBitmaps]
--			, [RedirectDiskDrives], [RedirectPorts], [RedirectPrinters]
--			, [RedirectSmartCards], [RedirectSound], [RedirectKeys]
--			, [Connected], [PreExtApp], [PostExtApp], [MacAddress]
--			, [UserField], [ExtApp], [VNCCompression], [VNCEncoding]
--			, [VNCAuthMode], [VNCProxyType], [VNCProxyIP], [VNCProxyPort]
--			, [VNCProxyUsername], [VNCProxyPassword], [VNCColors]
--			, [VNCSmartSizeMode], [VNCViewOnly], [InheritCacheBitmaps]
--			, [InheritColors], [InheritDescription], [InheritDisplayThemes]
--			, [InheritDisplayWallpaper], [InheritDomain], [InheritIcon]
--			, [InheritPanel], [InheritPassword], [InheritPort]
--			, [InheritProtocol], [InheritPuttySession]
--			, [InheritRedirectDiskDrives], [InheritRedirectKeys]
--			, [InheritRedirectPorts], [InheritRedirectPrinters]
--			, [InheritRedirectSmartCards], [InheritRedirectSound]
--			, [InheritResolution], [InheritUseConsoleSession]
--			, [InheritRenderingEngine], [InheritICAEncryptionStrength]
--			, [InheritRDPAuthenticationLevel], [InheritUsername]
--			, [InheritPreExtApp], [InheritPostExtApp], [InheritMacAddress]
--			, [InheritUserField], [InheritExtApp], [InheritVNCCompression]
--			, [InheritVNCEncoding], [InheritVNCAuthMode]
--			, [InheritVNCProxyType], [InheritVNCProxyIP]
--			, [InheritVNCProxyPort], [InheritVNCProxyUsername]
--			, [InheritVNCProxyPassword], [InheritVNCColors]
--			, [InheritVNCSmartSizeMode], [InheritVNCViewOnly]) 

--Select	--@LastID + ROW_NUMBER() OVER (ORDER BY col3,col4) [ID]
--	RIGHT('0000' + CAST(DatePart(yy,getdate())AS VarChar(4)),4)
--	+ RIGHT('00' + CAST(DatePart(mm,getdate())AS VarChar(2)),2)
--	+ RIGHT('00' + CAST(DatePart(dd,getdate())AS VarChar(2)),2)
--	+ RIGHT('00' + CAST(DatePart(Hh,getdate())AS VarChar(2)),2)
--	+ RIGHT('00' + CAST(DatePart(mi,getdate())AS VarChar(2)),2)
--	+ RIGHT('00' + CAST(DatePart(ss,getdate())AS VarChar(2)),2)
--	+ RIGHT('000' + CAST(DatePart(Ms,getdate())AS VarChar(3)),3)
--	+ RIGHT(CAST(newid()AS VarChar(50)),5)
--	, @LastPosition + ROW_NUMBER() OVER (ORDER BY col3,col4) [PositionID]
--	, (Select T1.[ConstantID] FROM tblCons T1 Left Join tblCons T2 on T1.[ParentID] = T2.[ConstantID] WHERE T1.[Name] collate Latin1_General_CI_AS = data.col3 and T2.[Name] collate Latin1_General_CI_AS = data.col2  ) [ParentID]
--	, getdate()
--	, col4
--	, 'Connection'
--	, 'False'
--	, ''
--	, 'mRemote'
--	, 'General'
--	, ''
--	, ''
--	, ''
--	, col4
--	, 'RDP'
--	, 'Default Settings'
--	, 3389
--	, 'False'
--	, 'IE', 'EncrBasic', 'NoAuth'
--	, 'Colors16Bit', 'FitToWindow'
--	, 'False', 'False', 'True', 'False'
--	, 'False', 'False', 'False', 'DoNotPlay'
--	, 'False', 'False', '', '', '', '', ''
--	, 'CompNone', 'EncHextile', 'AuthVNC'
--	, 'ProxyNone', '', 0, '', ''
--	, 'ColNormal', 'SmartSAspect', 'False', 'True', 'True'
--	, 'False', 'True', 'True', 'True', 'True', 'True', 'True'
--	, 'True', 'True', 'True', 'True', 'True', 'True', 'True'
--	, 'True', 'True', 'True', 'True', 'True', 'True', 'True'
--	, 'True', 'True', 'True', 'True', 'True', 'True', 'True'
--	, 'True', 'True', 'True', 'True', 'True', 'True', 'True'
--	, 'True', 'True', 'True'

--FROM	(
--	SELECT	Distinct
--		col2
--		,col3
--		,col4
--	FROM	@ServerList
--	) data
--WHERE (Select T1.[ConstantID] FROM tblCons T1 Left Join tblCons T2 on T1.[ParentID] = T2.[ConstantID] WHERE T1.[Name] collate Latin1_General_CI_AS = data.col3 and T2.[Name] collate Latin1_General_CI_AS = data.col2  ) IS NOT NULL	


UPDATE tblCons SET PositionID=-1 
GO

UPDATE tblCons SET Description=Name + '/', PositionID=1 WHERE [ParentID] = '0'
GO


WHILE EXISTS (SELECT * FROM tblCons WHERE PositionID < 0) 
UPDATE T SET T.PositionID = P.PositionID + 1, 
T.Description = P.Description + T.Name + '/' 
--select		T.PositionID 
--			, P.PositionID + 1 
--			,T.Description
--			,P.Description + T.Name + '/' 
FROM tblCons AS T 
INNER JOIN tblCons AS P ON (T.[ParentID]=P.[ConstantID]) 
WHERE P.PositionID>=1 
AND P.Description Is Not Null 
AND T.PositionID < 0
GO

UPDATE	tblCons
SET	PositionID = T2.[PositionID]
FROM	tblCons T1
INNER JOIN
(
select		TOP 100 PERCENT
		ROW_NUMBER() OVER (ORDER BY Description) [PositionID]
		,ID
FROM		tblCons
ORDER BY	Description
) T2
ON T1.ID = T2.ID
GO

----DELETE FROM tblUpdate
----GO
----INSERT INTO tblUpdate (LastUpdate) SELECT GetDate()
----GO

--DECLARE	@text VarChar(max)
--DECLARE @Depth Int
--DECLARE @LastDepth Int
--DECLARE @name varchar(40)

--DECLARE test_cursor CURSOR
--KEYSET
--FOR

--Select		PositionID,Name
--FROM		tblCons
--ORDER BY	Description


--SET @text = '
--<?xml version="1.0" encoding="utf-8"?>
--<Connections Name="mR|Export (20091215 14:20:24)" Export="True" Protected="sSiXh9JRE92Dik6T2LrJZQdXX1tlN4JXkWGYRM50k7dYdUCb796P6cjOUSI+lPbZ" ConfVersion="2.1">'

--PRINT @TEXT
--SET @LastDepth = 0
--OPEN test_cursor

--FETCH NEXT FROM test_cursor INTO @Depth,@name
--WHILE (@@fetch_status <> -1)
--BEGIN
--	IF (@@fetch_status <> -2)
--	BEGIN
	
--	If @LastDepth > @Depth  
--	BEGIN
--		SET @text = 
--		CASE @LastDepth
--			WHEN 4
--			THEN '            </Node>'
--			WHEN 3
--			THEN '        </Node>'
--			WHEN 2
--			THEN '    </Node>'
--			END
--		PRINT @Text
--	END	
	
--	SET @text = 
--	CASE @Depth
--		WHEN 1
--		THEN '    <Node Name="'+@name+'" Type="Container" Expanded="True" Descr="" Icon="mRemote" Panel="General" Username="" Domain="" Password="" Hostname="" Protocol="RDP" PuttySession="Default Settings" Port="3389" ConnectToConsole="False" RenderingEngine="IE" ICAEncryptionStrength="EncrBasic" RDPAuthenticationLevel="NoAuth" Colors="Colors16Bit" Resolution="FitToWindow" DisplayWallpaper="False" DisplayThemes="False" CacheBitmaps="True" RedirectDiskDrives="True" RedirectPorts="True" RedirectPrinters="True" RedirectSmartCards="True" RedirectSound="DoNotPlay" RedirectKeys="True" Connected="False" PreExtApp="" PostExtApp="" MacAddress="" UserField="" ExtApp="" VNCCompression="CompNone" VNCEncoding="EncHextile" VNCAuthMode="AuthVNC" VNCProxyType="ProxyNone" VNCProxyIP="" VNCProxyPort="0" VNCProxyUsername="" VNCProxyPassword="" VNCColors="ColNormal" VNCSmartSizeMode="SmartSAspect" VNCViewOnly="False" InheritCacheBitmaps="False" InheritColors="False" InheritDescription="False" InheritDisplayThemes="False" InheritDisplayWallpaper="False" InheritDomain="False" InheritIcon="False" InheritPanel="False" InheritPassword="False" InheritPort="False" InheritProtocol="False" InheritPuttySession="False" InheritRedirectDiskDrives="False" InheritRedirectKeys="False" InheritRedirectPorts="False" InheritRedirectPrinters="False" InheritRedirectSmartCards="False" InheritRedirectSound="False" InheritResolution="False" InheritUseConsoleSession="False" InheritRenderingEngine="False" InheritUsername="False" InheritICAEncryptionStrength="False" InheritRDPAuthenticationLevel="False" InheritPreExtApp="False" InheritPostExtApp="False" InheritMacAddress="False" InheritUserField="False" InheritExtApp="False" InheritVNCCompression="False" InheritVNCEncoding="False" InheritVNCAuthMode="False" InheritVNCProxyType="False" InheritVNCProxyIP="False" InheritVNCProxyPort="False" InheritVNCProxyUsername="False" InheritVNCProxyPassword="False" InheritVNCColors="False" InheritVNCSmartSizeMode="False" InheritVNCViewOnly="False">'
--		WHEN 2
--		THEN '        <Node Name="'+@name+'" Type="Container" Expanded="True" Descr="" Icon="mRemote" Panel="General" Username="" Domain="'+@name+'" Password="" Hostname="" Protocol="RDP" PuttySession="Default Settings" Port="3389" ConnectToConsole="False" RenderingEngine="IE" ICAEncryptionStrength="EncrBasic" RDPAuthenticationLevel="NoAuth" Colors="Colors16Bit" Resolution="FitToWindow" DisplayWallpaper="False" DisplayThemes="False" CacheBitmaps="True" RedirectDiskDrives="True" RedirectPorts="True" RedirectPrinters="True" RedirectSmartCards="True" RedirectSound="DoNotPlay" RedirectKeys="True" Connected="False" PreExtApp="" PostExtApp="" MacAddress="" UserField="" ExtApp="" VNCCompression="CompNone" VNCEncoding="EncHextile" VNCAuthMode="AuthVNC" VNCProxyType="ProxyNone" VNCProxyIP="" VNCProxyPort="0" VNCProxyUsername="" VNCProxyPassword="" VNCColors="ColNormal" VNCSmartSizeMode="SmartSAspect" VNCViewOnly="False" InheritCacheBitmaps="True" InheritColors="True" InheritDescription="True" InheritDisplayThemes="True" InheritDisplayWallpaper="True" InheritDomain="False" InheritIcon="True" InheritPanel="True" InheritPassword="False" InheritPort="True" InheritProtocol="True" InheritPuttySession="True" InheritRedirectDiskDrives="True" InheritRedirectKeys="True" InheritRedirectPorts="True" InheritRedirectPrinters="True" InheritRedirectSmartCards="True" InheritRedirectSound="True" InheritResolution="True" InheritUseConsoleSession="True" InheritRenderingEngine="True" InheritUsername="False" InheritICAEncryptionStrength="True" InheritRDPAuthenticationLevel="True" InheritPreExtApp="True" InheritPostExtApp="True" InheritMacAddress="True" InheritUserField="True" InheritExtApp="True" InheritVNCCompression="True" InheritVNCEncoding="True" InheritVNCAuthMode="True" InheritVNCProxyType="True" InheritVNCProxyIP="True" InheritVNCProxyPort="True" InheritVNCProxyUsername="True" InheritVNCProxyPassword="True" InheritVNCColors="True" InheritVNCSmartSizeMode="True" InheritVNCViewOnly="True">'
--		WHEN 3
--		THEN '            <Node Name="'+@name+'" Type="Container" Expanded="True" Descr="" Icon="mRemote" Panel="General" Username="" Domain="" Password="" Hostname="" Protocol="RDP" PuttySession="Default Settings" Port="3389" ConnectToConsole="False" RenderingEngine="IE" ICAEncryptionStrength="EncrBasic" RDPAuthenticationLevel="NoAuth" Colors="Colors16Bit" Resolution="FitToWindow" DisplayWallpaper="False" DisplayThemes="False" CacheBitmaps="True" RedirectDiskDrives="True" RedirectPorts="True" RedirectPrinters="True" RedirectSmartCards="True" RedirectSound="DoNotPlay" RedirectKeys="True" Connected="False" PreExtApp="" PostExtApp="" MacAddress="" UserField="" ExtApp="" VNCCompression="CompNone" VNCEncoding="EncHextile" VNCAuthMode="AuthVNC" VNCProxyType="ProxyNone" VNCProxyIP="" VNCProxyPort="0" VNCProxyUsername="" VNCProxyPassword="" VNCColors="ColNormal" VNCSmartSizeMode="SmartSAspect" VNCViewOnly="False" InheritCacheBitmaps="True" InheritColors="True" InheritDescription="True" InheritDisplayThemes="True" InheritDisplayWallpaper="True" InheritDomain="True" InheritIcon="True" InheritPanel="True" InheritPassword="True" InheritPort="True" InheritProtocol="True" InheritPuttySession="True" InheritRedirectDiskDrives="True" InheritRedirectKeys="True" InheritRedirectPorts="True" InheritRedirectPrinters="True" InheritRedirectSmartCards="True" InheritRedirectSound="True" InheritResolution="True" InheritUseConsoleSession="True" InheritRenderingEngine="True" InheritUsername="True" InheritICAEncryptionStrength="True" InheritRDPAuthenticationLevel="True" InheritPreExtApp="True" InheritPostExtApp="True" InheritMacAddress="True" InheritUserField="True" InheritExtApp="True" InheritVNCCompression="True" InheritVNCEncoding="True" InheritVNCAuthMode="True" InheritVNCProxyType="True" InheritVNCProxyIP="True" InheritVNCProxyPort="True" InheritVNCProxyUsername="True" InheritVNCProxyPassword="True" InheritVNCColors="True" InheritVNCSmartSizeMode="True" InheritVNCViewOnly="True">'
--		WHEN 4
--		THEN '                <Node Name="'+@name+'" Type="Connection" Descr="" Icon="mRemote" Panel="General" Username="" Domain="AMER" Password="" Hostname="'+@name+'" Protocol="RDP" PuttySession="Default Settings" Port="3389" ConnectToConsole="False" RenderingEngine="IE" ICAEncryptionStrength="EncrBasic" RDPAuthenticationLevel="NoAuth" Colors="Colors16Bit" Resolution="FitToWindow" DisplayWallpaper="False" DisplayThemes="False" CacheBitmaps="True" RedirectDiskDrives="True" RedirectPorts="True" RedirectPrinters="True" RedirectSmartCards="True" RedirectSound="DoNotPlay" RedirectKeys="True" Connected="False" PreExtApp="" PostExtApp="" MacAddress="" UserField="" ExtApp="" VNCCompression="CompNone" VNCEncoding="EncHextile" VNCAuthMode="AuthVNC" VNCProxyType="ProxyNone" VNCProxyIP="" VNCProxyPort="0" VNCProxyUsername="" VNCProxyPassword="" VNCColors="ColNormal" VNCSmartSizeMode="SmartSAspect" VNCViewOnly="False" InheritCacheBitmaps="True" InheritColors="True" InheritDescription="True" InheritDisplayThemes="True" InheritDisplayWallpaper="True" InheritDomain="True" InheritIcon="True" InheritPanel="True" InheritPassword="True" InheritPort="True" InheritProtocol="True" InheritPuttySession="True" InheritRedirectDiskDrives="True" InheritRedirectKeys="True" InheritRedirectPorts="True" InheritRedirectPrinters="True" InheritRedirectSmartCards="True" InheritRedirectSound="True" InheritResolution="True" InheritUseConsoleSession="True" InheritRenderingEngine="True" InheritUsername="True" InheritICAEncryptionStrength="True" InheritRDPAuthenticationLevel="True" InheritPreExtApp="True" InheritPostExtApp="True" InheritMacAddress="True" InheritUserField="True" InheritExtApp="True" InheritVNCCompression="True" InheritVNCEncoding="True" InheritVNCAuthMode="True" InheritVNCProxyType="True" InheritVNCProxyIP="True" InheritVNCProxyPort="True" InheritVNCProxyUsername="True" InheritVNCProxyPassword="True" InheritVNCColors="True" InheritVNCSmartSizeMode="True" InheritVNCViewOnly="True"/>'
--		END
--        PRINT @Text

--	END
--	SET @LastDepth = @Depth
--	FETCH NEXT FROM test_cursor INTO @Depth,@name
--END

--CLOSE test_cursor
--DEALLOCATE test_cursor

--SET @text = 
--CASE @LastDepth
--	WHEN 4
--	THEN '                 </Node>'+CHAR(13)+CHAR(10)+'            </Node>'+CHAR(13)+CHAR(10)+'        </Node>'
--	WHEN 3
--	THEN '            </Node>'+CHAR(13)+CHAR(10)+'        </Node>'
--	WHEN 2
--	THEN '        </Node>'
--	END
--PRINT @Text
		
--SET @TEXT = '    </Node>'+CHAR(13)+CHAR(10)+'</Connections>'
--PRINT @Text


--GO



