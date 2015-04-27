SELECT		*
FROM		frmForm
WHERE		FID IN (840,776)

DECLARE		@Title			VarChar(50),
			@description	varchar(2000),
			@instructions	varchar(1000),
			@categorization varchar(3),
			@catListTitle	varchar(50),
			@categoryList	varchar(2500),
			@catList2Title	varchar(50),
			@categoryList2	varchar(1500),
			@catList3Title	varchar(50),
			@categoryList3	varchar(1500)
			,@CMD		VarChar(8000)


SELECT		@Title			=  formTitle,			
			@description	=  description,	
			@instructions	=  instructions,		
			@categorization =  categorization, 
			@catListTitle	=  catListTitle,	
			@categoryList	=  categoryList,	
			@catList2Title	=  catList2Title,	
			@categoryList2	=  categoryList2,	
			@catList3Title	=  catList3Title,	
			@categoryList3	=  categoryList3	
FROM		frmForm
WHERE		FID = 776



SELECT		@CMD	= 'UPDATE		frmForm 
	SET	[categoryList] = '''+@categoryList+'''
		,[categoryList2] = '''+@categoryList2+'''
		,[categoryList3] = '''+@categoryList3+'''
WHERE		FID = 776'

PRINT @CMD


SELECT		@Title			=  formTitle,			
			@description	=  description,	
			@instructions	=  instructions,		
			@categorization =  categorization, 
			@catListTitle	=  catListTitle,	
			@categoryList	=  categoryList,	
			@catList2Title	=  catList2Title,	
			@categoryList2	=  categoryList2,	
			@catList3Title	=  catList3Title,	
			@categoryList3	=  categoryList3	
FROM		frmForm
WHERE		FID = 840



SELECT		@CMD	= 'UPDATE		frmForm 
	SET	[categoryList] = '''+@categoryList+'''
		,[categoryList2] = '''+@categoryList2+'''
		,[categoryList3] = '''+@categoryList3+'''
WHERE		FID = 840'

PRINT @CMD







--SELECT		COALESCE(@catListTitle,'Cat1') AS ListTitle,*
--FROM		dbaadmin.dbo.dbaudf_split(@categoryList,',')
--UNION 
--SELECT		COALESCE(@catList2Title,'Cat2') AS ListTitle,*
--FROM		dbaadmin.dbo.dbaudf_split(@categoryList2,',')
--UNION
--SELECT		COALESCE(@catList3Title,'Cat3') AS ListTitle,*
--FROM		dbaadmin.dbo.dbaudf_split(@categoryList3,',')

--ORDER BY 1,2

/*
ACAT,Active Directory (AD),Adobe Web Service,AIP,Akamai,Alliant (Editorial),Alliant (Rights Managed),APIS,Asset Parser,B-Editorial (MLB),B-Editorial (NASCAR),B-Editorial (NBA),B-Editorial (NFL),B-Editorial (Time Life),BigIP (F5),Blackberry (BES),ChangeMe,Checkpoint Firewall,Corporate Site,CRM,DAP,DAS,Delivery,DEWDS/MediaFactory,DNS (External),DNS / WINS (Internal),DropIT,DVD Preview,Editorial FTP, Upload,Event Manager,Exchange,FAST,GetPAID,Globe, GettyImages.com - Creative, GettyImages.com - Editorial, GettyImages.com - Footage,GimBroker,HP OpenView (OVO),HSM,IM Logic,Image Bank Search (TIB),Image Direct,Image.net (XADS),Intranet (One Place),Jupiter Images,LCS,Legacy Creative,Legacy Editorial,Life.com,MediaManager,MediaManager Creative Link,Mercury2,MKS Integrity Suite,Moodstream,MRT,MS Project Server 2003,NetBackup,Network (Internal),Newsbase,Noetix,Operations Manager (MOM),Oracle Finance,Oracle Fulfillment,Oracle HR,Partner Portal,Performance Management,Pixel Ripper,Power/UPS/HVAC,Product Catalog,PumpAudio,PunchStock,Rights Management Service,SAN (Customer Facing),SAN (Internal),SCI,SCI2,Sendmail,SI MediaStore,Sitemaps,SSL,SnapShot (SharePoint),StingRay,Talisma,TaxWare,TEAMS (CFW),TEAMS (SI),Transcoder,Triactive,Unauthorized Use,Unity Voicemail,Varicent,Verisign / Paymentech,Vitria BusinessWare,VMT,WAN (CFW Connectivity),WAN (Interoffice),Web Services,White Label Sites, WireImage (MediaVast),WCDS,Zeppo,----------,Misc. Backoffice,Misc. SQL, Misc. Internal Server/App, Other

,----General----,AE Association,AE Disassociation,Backup Failure,Build Break,Disk Space,Marketing Content Update,Sitemap Update,Web Vision User Update,,----Issues----,Creative Site Issue,Editorial Site Issue,Network Issue,SCI/CRM Issue,SQL Error,Other Issue,,----Outages----,Complete Outage,Degraded Functionality,Editorial Ingestion,Redundancy Failure,Duplicate Ticket

Gold, Platinum, Silver, Bronze
*/


/*
UPDATE		frmForm 
	SET	[categoryList] = 'ACAT,Active Directory (AD),Adobe Web Service,AIP,Akamai,Alliant (Editorial),Alliant (Rights Managed),APIS,Asset Parser,B-Editorial (MLB),B-Editorial (NASCAR),B-Editorial (NBA),B-Editorial (NFL),B-Editorial (Time Life),BigIP (F5),Blackberry (BES),ChangeMe,Checkpoint Firewall,Corporate Site,CRM,DAP,DAS,Delivery,DEWDS/MediaFactory,DNS (External),DNS / WINS (Internal),DropIT,DVD Preview,Editorial FTP, Upload,Event Manager,Exchange,FAST,GetPAID,Globe, GettyImages.com - Creative, GettyImages.com - Editorial, GettyImages.com - Footage,GimBroker,HP OpenView (OVO),HSM,IM Logic,Image Bank Search (TIB),Image Direct,Image.net (XADS),Intranet (One Place),Jupiter Images,LCS,Legacy Creative,Legacy Editorial,Life.com,MediaManager,MediaManager Creative Link,Mercury2,MKS Integrity Suite,Moodstream,MRT,MS Project Server 2003,NetBackup,Network (Internal),Newsbase,Noetix,Operations Manager (MOM),Oracle Finance,Oracle Fulfillment,Oracle HR,Partner Portal,Performance Management,Pixel Ripper,Power/UPS/HVAC,Product Catalog,PumpAudio,PunchStock,Rights Management Service,SAN (Customer Facing),SAN (Internal),SCI,SCI2,Sendmail,SI MediaStore,Sitemaps,SSL,SnapShot (SharePoint),StingRay,Talisma,TaxWare,TEAMS (CFW),TEAMS (SI),Transcoder,Triactive,Unauthorized Use,Unity Voicemail,Varicent,Verisign / Paymentech,Vitria BusinessWare,VMT,WAN (CFW Connectivity),WAN (Interoffice),Web Services,White Label Sites, WireImage (MediaVast),WCDS,Zeppo,----------,Misc. Backoffice,Misc. SQL, Misc. Internal Server/App, Other'
		,[categoryList2] = ',----General----,AE Association,AE Disassociation,Backup Failure,Build Break,Disk Space,Marketing Content Update,Sitemap Update,Web Vision User Update,,----Issues----,Creative Site Issue,Editorial Site Issue,Network Issue,SCI/CRM Issue,SQL Error,Other Issue,,----Outages----,Complete Outage,Degraded Functionality,Editorial Ingestion,Redundancy Failure,Duplicate Ticket'
		,[categoryList3] = 'Gold, Platinum, Silver, Bronze'
WHERE		FID = 776

UPDATE		frmForm 
	SET	[categoryList] = 'ACAT,Active Directory (AD),Adobe Web Service,AIP,Akamai,Alliant (Editorial),Alliant (Rights Managed),APIS,Asset Parser,B-Editorial (MLB),B-Editorial (NASCAR),B-Editorial (NBA),B-Editorial (NFL),B-Editorial (Time Life),BigIP (F5),Blackberry (BES),ChangeMe,Checkpoint Firewall,Corporate Site,CRM,DAP,DAS,Delivery,DEWDS/MediaFactory,DNS (External),DNS / WINS (Internal),DropIT,Editorial FTP, Upload,Exchange,Event Manager,FAST,GetPAID,Globe, GettyImages.com - Creative, GettyImages.com - Editorial, GettyImages.com - Footage,GimBroker,HP OpenView (OVO),HSM,IM Logic,Image Bank Search (TIB),Image Direct,Image.net (XADS),Intranet (One Place),Jupiter Images,LCS,Legacy Creative, Legacy Editorial, Life.com,MediaManager,MediaManager Creative Link,Mercury2,MKS Integrity Suite,Moodstream,MRT,MS Project Server 2003,NetBackup,Network (Internal),Newsbase,Noetix,Operations Manager (MOM),Oracle Finance,Oracle Fulfillment,Oracle HR,Partner Portal,Performance Management,Pixel Ripper,Power/UPS/HVAC,Product Catalog,PumpAudio,PunchStock,Rights Management Service,SAN (Customer Facing),SAN (Internal),SCI,SCI2,Sendmail,SI MediaStore,SmartMaps,SnapShot (SharePoint),SSL,Stacking,StingRay,Talisma,TaxWare,TEAMS (CFW),TEAMS (SI),Transcoder,Triactive,Unauthorized Use,Unity Voicemail,Varicent,Verisign / Paymentech,Vitria BusinessWare,VMT,WAN (CFW Connectivity),WAN (Interoffice),Web Services,White Label Sites,WireImage (MediaVast),WCDS,Zeppo,----------,Misc. Backoffice,Misc. SQL, Misc. Internal Server/App, Other'
		,[categoryList2] = '----General----,AE Association,AE Disassociation,Backup Failure,Build Break,Disk Space,Marketing Content Update,,----Issues----,Creative Site Issue,Editorial Site Issue,Network Issue,SCI/CRM Issue,SQL Error,Other Issue,,----Outages----,Complete Outage,Degraded Functionality,Editorial Ingestion,Redundancy Failure,Duplicate Ticket,,----Monitoring----,MOM/OVO Inconsistancy, MOM Alert Tuning'
		,[categoryList3] = 'Gold, Platinum, Silver, Bronze'
WHERE		FID = 840


*/

USE USERS
GO
UPDATE		frmForm 
	SET	[categoryList]   = 'GettyImages.com - Creative,GettyImages.com - Editorial,GettyImages.com - Footage,Active Directory (AD),AIP,API,Akamai,Alliant,BES/Blackberry,Call Plan Issues,Clipart.com,Cognos,ContourByGetty,Corporate Site,CRM,DAS,Delivery,DEWDS/MediaFactory,Dex,DNS/WINS,DR Systems,DropIT,Enterprise Services,Exchange,EWS,Facilities,FAST/Solr,FilmMagic,FTP,GimBroker,Image.net (XADS),Internal Network,Internet,One Place,iStockPhoto,Jupiter Images,Lync,Marketing,MediaManager,Mixer,Moodstream,MRT,MSSQL,MySQL,NetBackup,Noetix,Partner Portal,PhotoLibrary,Pixel Ripper,Product Catalog,PumpAudio,PunchStock,SAN,SCI,SCOM,Search Services,Service Now,SharePoint,SSL,Storage,Talisma,TEAMS,Telecom,TFS/Git,ThinkStock,Transcoder,Unauthorized Use,Varicent,Verisign / Paymentech,Videoconferencing,Vitria BusinessWare,VMware,VOIP,WCDS,Web Services,White Label Sites,WireImage,Zenoss'
WHERE		FID = IN(776,840)
GO







