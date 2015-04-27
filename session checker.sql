
SET NOEXEC OFF

IF DB_ID('dbaperf') IS NULL
	SET NOEXEC ON

USE [dbaperf]
GO

/****** Object:  Table [dbo].[DMV_exec_sessions]    Script Date: 11/1/2013 4:01:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('dbo.DMV_exec_sessions') IS NOT NULL
	SET NOEXEC ON
GO

CREATE TABLE [dbo].[DMV_exec_sessions](
	[rundate] [datetime] NOT NULL,
	[ServerName] [sysname] NOT NULL,
	[SQLName] [sysname] NOT NULL,
	[Application] [nvarchar](138) NOT NULL,
	[program_name] [nchar](128) NOT NULL,
	[login_name] [nchar](128) NOT NULL,
	[DBName] [nvarchar](128) NULL,
	[session_ids] [int] NOT NULL,
	[Activesessions] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[DMV_exec_sessions] TO  SCHEMA OWNER 
GO

SET NOEXEC OFF

SET ANSI_WARNINGS OFF
SET NOCOUNT ON
GO

IF DB_ID('dbaperf') IS NULL
	SET NOEXEC ON

IF @@VERSION LIKE 'Microsoft SQL Server  2000%'
	SET NOEXEC ON

 
LoopTop:


INSERT INTO	DBAPERF.DBO.DMV_exec_sessions
SELECT		GETUTCDATE() rundate
		,REPLACE(@@SERVERNAME,'\'+@@SERVICENAME,'') ServerName
		,@@SERVERNAME SQLName
		,CASE
			WHEN LEFT([host_name],15) = 'SEAPINTWINUUSVC'	THEN 'Unauthorized Use'
			WHEN LEFT([host_name],12) = 'SEAPWIRPVWEB'	THEN 'Wire Image Film Magic'
			WHEN LEFT([host_name],11) = 'SEAPCRM5IWS'	THEN 'CRM'
			WHEN LEFT([host_name],11) = 'SEAPCRM5WEB'	THEN 'CRM'
			WHEN LEFT([host_name],11) = 'SEAPEWSFEED'	THEN 'FEEDS'
			WHEN LEFT([host_name],11) = 'SEAPGIPVWEB'	THEN 'Getty Images Newsmaker'
			WHEN LEFT([host_name],10) = 'SEAPENTSVC'	THEN 'Enterprise Web Services'
			WHEN LEFT([host_name],10) = 'SEAPAPISVC'	THEN 'API Services'
			WHEN LEFT([host_name],10) = 'SEAPCONWEB'	THEN 'Contour By Getty Images'
			WHEN LEFT([host_name],10) = 'SEAPCTBWEB'	THEN 'Contributor Systems'
			WHEN LEFT([host_name],10) = 'SEAPCTBSVC'	THEN 'Contributor Systems Web Services'
			WHEN LEFT([host_name],10) = 'G1IBSEARCH'	THEN 'Corporate'
			WHEN LEFT([host_name],10) = 'SEAPDELWEB'	THEN 'Delivery'
			WHEN LEFT([host_name],10) = 'SEAPDSOAPP'	THEN 'DSO'
			WHEN LEFT([host_name],10) = 'SEAPJUPWEB'	THEN 'Jupiter Images'
			WHEN LEFT([host_name],10) = 'SEAPPARWEB'	THEN 'Partner Portal'
			WHEN LEFT([host_name],10) = 'SEAPXESWEB'	THEN 'Proxy Connect Gibson'
			WHEN LEFT([host_name],10) = 'SEAPSDTWEB'	THEN 'SDT AssetKeywordingService\MappingService\VocabularyService'
			WHEN LEFT([host_name],10) = 'SEAPSTKAPP'	THEN 'Stacks'
			WHEN LEFT([host_name],10) = 'SEAPTKSWEB'	THEN 'ThinkStock'
			WHEN LEFT([host_name],10) = 'SEAPUNAWEB'	THEN 'Unauthorized Use'
			WHEN LEFT([host_name],10) = 'SEAPWINSVC'	THEN 'Windows Service AssetFlattener\AutoSuggest_KeywordIndexBuilder\BundleRefresh\Indexer\IndexRebuilder\KeywordUpdateService\SchedulingService'
			WHEN LEFT([host_name],10) = 'SEAPWIRWEB'	THEN 'Wire Image Film Magic'
			WHEN LEFT([host_name],10) = 'SEAPVITAPP'	THEN 'Vitria'
			WHEN LEFT([host_name],9)  = 'SEAPGIWEB'		THEN 'Getty Images Newsmaker'
			WHEN LEFT([host_name],9)  = 'SEAPCMSWS'		THEN 'Alfresco Bullseye'
			WHEN LEFT([host_name],9)  = 'SEAPACWEB'		THEN 'Auto Suggest'
			WHEN LEFT([host_name],9)  = 'SEADCXWSA'		THEN 'External Web Services'
			WHEN LEFT([host_name],9)  = 'SEADCIWSA'		THEN 'IWSA Asset Keyword\Keyword Lookup\Keyword'
			WHEN LEFT([host_name],9)  = 'SEADCIWSB'		THEN 'IWSB Internal Account\Asset\Cart\DDS\LightBox\Order'
			WHEN LEFT([host_name],9)  = 'SEAPUUWEB'		THEN 'License Compliance'
			WHEN LEFT([host_name],9)  = 'SEADCPCWS'		THEN 'Product Catalog'
			WHEN LEFT([host_name],9)  = 'SEAPUNAWS'		THEN 'Unauthorized Use Web Service'
			WHEN LEFT([host_name],8)  = 'SEADCSCI'		THEN 'SCI'
			WHEN LEFT([host_name],8)  = 'SEADCCWS'		THEN 'CWS Credit\Tax'
			WHEN LEFT([host_name],7)  = 'GINSWEB'		THEN 'Legacy Editorial'
 
			WHEN LEFT([host_name],10) = 'ASHPENTSVC'	THEN 'DR SITE Enterprise Web Services'
			WHEN LEFT([host_name],10) = 'ASHPDELWEB'	THEN 'DR SITE Delivery'
			WHEN LEFT([host_name],9)  = 'ASHPCMSWS'		THEN 'DR SITE Alfresco Bullseye'
			WHEN LEFT([host_name],9)  = 'ASHPGIWEB'		THEN 'DR SITE Getty Images Newsmaker'
			WHEN LEFT([host_name],8)  = 'ASHPIWSA'		THEN 'DR SITE IWSA Asset Keyword\Keyword Lookup\Keyword'
			WHEN LEFT([host_name],8)  = 'ASHPPCWS'		THEN 'DR SITE Product Catalog'
			WHEN LEFT([host_name],7)  = 'ASHPSCI'		THEN 'DR SITE SCI'
			WHEN LEFT([host_name],7)  = 'ASHPCWS'		THEN 'DR SITE CWS Credit\Tax'
			ELSE 'UNKNOWN: '+ [host_name] END [Application]
		,program_name
		,[login_name]
		,DB_NAME(T2.[database_id]) DBName
		,COUNT(DISTINCT T1.[session_id]) [session_ids]
		,COUNT(DISTINCT T2.[session_id]) [ActiveSessions]
from		sys.dm_exec_sessions T1
LEFT JOIN	sys.dm_exec_requests T2
	ON	T1.session_id = T2.session_id
WHERE		[host_name] != REPLACE(@@SERVERNAME,'\'+@@SERVICENAME,'')
	AND	[host_name] != SERVERPROPERTY('ComputerNamePhysicalNetBIOS')
	AND	[login_name] != 'sa'
	AND	program_name NOT IN	(
					 'Microsoft SQL Server Management Studio'
					,'Microsoft SQL Server Management Studio - Query'
					,'Microsoft SQL Server'
					)
 
GROUP BY	CASE
			WHEN LEFT([host_name],15) = 'SEAPINTWINUUSVC'	THEN 'Unauthorized Use'
			WHEN LEFT([host_name],12) = 'SEAPWIRPVWEB'	THEN 'Wire Image Film Magic'
			WHEN LEFT([host_name],11) = 'SEAPCRM5IWS'	THEN 'CRM'
			WHEN LEFT([host_name],11) = 'SEAPCRM5WEB'	THEN 'CRM'
			WHEN LEFT([host_name],11) = 'SEAPEWSFEED'	THEN 'FEEDS'
			WHEN LEFT([host_name],11) = 'SEAPGIPVWEB'	THEN 'Getty Images Newsmaker'
			WHEN LEFT([host_name],10) = 'SEAPENTSVC'	THEN 'Enterprise Web Services'
			WHEN LEFT([host_name],10) = 'SEAPAPISVC'	THEN 'API Services'
			WHEN LEFT([host_name],10) = 'SEAPCONWEB'	THEN 'Contour By Getty Images'
			WHEN LEFT([host_name],10) = 'SEAPCTBWEB'	THEN 'Contributor Systems'
			WHEN LEFT([host_name],10) = 'SEAPCTBSVC'	THEN 'Contributor Systems Web Services'
			WHEN LEFT([host_name],10) = 'G1IBSEARCH'	THEN 'Corporate'
			WHEN LEFT([host_name],10) = 'SEAPDELWEB'	THEN 'Delivery'
			WHEN LEFT([host_name],10) = 'SEAPDSOAPP'	THEN 'DSO'
			WHEN LEFT([host_name],10) = 'SEAPJUPWEB'	THEN 'Jupiter Images'
			WHEN LEFT([host_name],10) = 'SEAPPARWEB'	THEN 'Partner Portal'
			WHEN LEFT([host_name],10) = 'SEAPXESWEB'	THEN 'Proxy Connect Gibson'
			WHEN LEFT([host_name],10) = 'SEAPSDTWEB'	THEN 'SDT AssetKeywordingService\MappingService\VocabularyService'
			WHEN LEFT([host_name],10) = 'SEAPSTKAPP'	THEN 'Stacks'
			WHEN LEFT([host_name],10) = 'SEAPTKSWEB'	THEN 'ThinkStock'
			WHEN LEFT([host_name],10) = 'SEAPUNAWEB'	THEN 'Unauthorized Use'
			WHEN LEFT([host_name],10) = 'SEAPWINSVC'	THEN 'Windows Service AssetFlattener\AutoSuggest_KeywordIndexBuilder\BundleRefresh\Indexer\IndexRebuilder\KeywordUpdateService\SchedulingService'
			WHEN LEFT([host_name],10) = 'SEAPWIRWEB'	THEN 'Wire Image Film Magic'
			WHEN LEFT([host_name],10) = 'SEAPVITAPP'	THEN 'Vitria'
			WHEN LEFT([host_name],9)  = 'SEAPGIWEB'		THEN 'Getty Images Newsmaker'
			WHEN LEFT([host_name],9)  = 'SEAPCMSWS'		THEN 'Alfresco Bullseye'
			WHEN LEFT([host_name],9)  = 'SEAPACWEB'		THEN 'Auto Suggest'
			WHEN LEFT([host_name],9)  = 'SEADCXWSA'		THEN 'External Web Services'
			WHEN LEFT([host_name],9)  = 'SEADCIWSA'		THEN 'IWSA Asset Keyword\Keyword Lookup\Keyword'
			WHEN LEFT([host_name],9)  = 'SEADCIWSB'		THEN 'IWSB Internal Account\Asset\Cart\DDS\LightBox\Order'
			WHEN LEFT([host_name],9)  = 'SEAPUUWEB'		THEN 'License Compliance'
			WHEN LEFT([host_name],9)  = 'SEADCPCWS'		THEN 'Product Catalog'
			WHEN LEFT([host_name],9)  = 'SEAPUNAWS'		THEN 'Unauthorized Use Web Service'
			WHEN LEFT([host_name],8)  = 'SEADCSCI'		THEN 'SCI'
			WHEN LEFT([host_name],8)  = 'SEADCCWS'		THEN 'CWS Credit\Tax'
			WHEN LEFT([host_name],7)  = 'GINSWEB'		THEN 'Legacy Editorial'
 
			WHEN LEFT([host_name],10) = 'ASHPENTSVC'	THEN 'DR SITE Enterprise Web Services'
			WHEN LEFT([host_name],10) = 'ASHPDELWEB'	THEN 'DR SITE Delivery'
			WHEN LEFT([host_name],9)  = 'ASHPCMSWS'		THEN 'DR SITE Alfresco Bullseye'
			WHEN LEFT([host_name],9)  = 'ASHPGIWEB'		THEN 'DR SITE Getty Images Newsmaker'
			WHEN LEFT([host_name],8)  = 'ASHPIWSA'		THEN 'DR SITE IWSA Asset Keyword\Keyword Lookup\Keyword'
			WHEN LEFT([host_name],8)  = 'ASHPPCWS'		THEN 'DR SITE Product Catalog'
			WHEN LEFT([host_name],7)  = 'ASHPSCI'		THEN 'DR SITE SCI'
			WHEN LEFT([host_name],7)  = 'ASHPCWS'		THEN 'DR SITE CWS Credit\Tax'
			ELSE 'UNKNOWN: '+ [host_name] END
		,program_name
		,[login_name]
		,DB_NAME(T2.[database_id])
 
ORDER BY	1,2,3,4,5,6


WAITFOR DELAY '00:05:00' 
GOTO LoopTop
