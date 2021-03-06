/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [ServerName]
      ,[FQDN]
      ,[IPnum]
      ,[SQLName]
      ,UPPER([SQLEnv]) [SQLEnv]
      ,UPPER([DomainName]) [DomainName]
      ,UPPER([DomainName])+'\'+[SQLSvcAcct] [SQLSvcAcct]
      ,CASE UPPER([DomainName])+'\'+[SQLSvcAcct]
		WHEN 'amer\SQLAdminAlpha' THEN 'v&5enewU@' 
		WHEN 'amer\SQLAdminBeta' THEN '#r3&=azuB' 
		WHEN 'amer\SQLAdminCandidate' THEN 'kE@uFr89A' 
		WHEN 'AMER\SQLAdminDev' THEN 'squ33zepl@y' 
		WHEN 'AMER\SQLAdminTest' THEN 'squ33zepl@y' 
		WHEN 'AMER\SQLAdminLoad' THEN 'squ33zepl@y' 
		WHEN 'AMER\SQLAdminStage2010' THEN 'Hyp0d@syr8ngE' 
		WHEN 'AMER\SQLAdminProd2010' THEN 'S3wingm@ch7nE' 
		WHEN 'STAGE\SQLAdminStage2010' THEN 'St0n4h@ngE' 
		WHEN 'PRODUCTION\SQLAdminProd2010' THEN 'Ch7ch@nitzA'
		WHEN 'AMER\royaltydatabase' THEN 'squ33z3b@11db'
		WHEN 'STAGE\sqladminstage2012' THEN 'Scre3npl@Y'
		WHEN 'PRODUCTION\sqladminprod2012' THEN 'M@rd1gr@S'
		WHEN 'PRODUCTION\SQLAdminProd2008' THEN 'Meg@h3rtZ'
		WHEN 'AMER\SQLAdminProd2008' THEN 'L3fth@nD'
		WHEN 'AMER\SQLAdminProduction' THEN 'c@1ntheH@'
		WHEN 'PRODUCTION\SQLadminstaging2010' THEN 'Acr0p@1iS'
		WHEN 'PRODUCTION\SQLadmin-PRODUCTION' THEN 'SQL.s3rv3'
		WHEN 'AMER\SQLAdminKerbProd' THEN 'GoatF@c3'
		WHEN 'AMER\sqladminstage2008' THEN 'R1ghth@nD'
		END [Password]

  FROM [dbacentral].[dbo].[DBA_ServerInfo]
  WHERE Active = 'Y'

  SELECT COALESCE([FQDN],[ServerName],[IPnum]) Server
  FROM [dbacentral].[dbo].[DBA_ServerInfo]
  WHERE Active = 'Y'


  

SELECT 	REPLACE([FQDN],[ServerName],'')
	,count(*)
  FROM [dbacentral].[dbo].[DBA_ServerInfo]
  WHERE Active = 'Y'
  GROUP BY REPLACE([FQDN],[ServerName],'')