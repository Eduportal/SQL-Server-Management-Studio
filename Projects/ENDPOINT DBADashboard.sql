IF EXISTS (SELECT * FROM sys.endpoints e WHERE e.name = N'DBADashboard') 
DROP ENDPOINT [DBADashboard] 
GO
IF NOT EXISTS (SELECT * FROM sys.endpoints e WHERE e.name = N'DBADashboard') 
BEGIN
CREATE ENDPOINT [DBADashboard] 
	AUTHORIZATION [AMER\sledridge]
	STATE=STARTED
	AS HTTP	(
			PATH=N'/DBADashboard'
			, AUTHENTICATION = (NTLM)
			, PORTS = (CLEAR)
			, SITE=N'SEAFRESQLDBA01'
			)
	FOR SOAP	(
				WEBMETHOD 'LookupList'(NAME=N'[dbaadmin].[dbo].[dbasp_LookupList]')
				,WEBMETHOD 'EnlightenServerInfo'(NAME=N'[dbaadmin].[dbo].[dbasp_GetEnlightenServerInfo]')
				--,WEBMETHOD ''(NAME=N'')
				--,WEBMETHOD ''(NAME=N'')
				--,WEBMETHOD ''(NAME=N'')
				--,WEBMETHOD ''(NAME=N'')
				--,WEBMETHOD ''(NAME=N'')
				--,WEBMETHOD ''(NAME=N'')
				, BATCHES=DISABLED
				, WSDL=DEFAULT
				, DATABASE=N'dbaadmin'
				, NAMESPACE=N'http://ecommops/DBA'
				)
END
GO
GRANT CONNECT ON ENDPOINT:: DBADashboard TO PUBLIC
GO
GRANT VIEW DEFINITION ON ENDPOINT:: DBADashboard TO PUBLIC
GO



[dbaadmin].[dbo].[dbasp_LookupList] '', '', '', '', '', '', 'Y', 'ServerName'