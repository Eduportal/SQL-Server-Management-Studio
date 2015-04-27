USE [dbacentral]
GO

/****** Object:  View [dbo].[DBA_SQL_LICENSE_DETAILS]    Script Date: 3/25/2015 1:02:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW	[dbo].[DBA_SQL_LICENSE_DETAILS]
AS
WITH		C
		AS
		(
		SELECT		DISTINCT
				SQLName
				,ResourceName Node
		FROM		dbacentral.[dbo].[DBA_ClustInfo]
		WHERE		ResourceType = 'Node'
		)
		,CAA
		AS
		(
		SELECT		SQLName
				,Node
				,(SELECT COUNT(DISTINCT SQLName)+1 FROM C WHERE Node = C2.Node AND SQLName != C2.SQLName) NodeCount
				,CASE WHEN EXISTS(SELECT * FROM C WHERE Node = C2.Node AND SQLName != C2.SQLName) THEN 1 ELSE 0 END IsActiveActive

		FROM		C AS C2
		)
		,VCTR
		AS
		(
		SELECT		vpxv_vms.NAME COLLATE Latin1_General_CI_AS [ServerName]
				,vpxv_hosts.NAME  COLLATE Latin1_General_CI_AS [ESX_HostName]
		FROM		[SEAPVCENTSQL].[VCDB].[dbo].vpxv_vms vpxv_vms
		JOIN		[SEAPVCENTSQL].[VCDB].[dbo].vpxv_hosts vpxv_hosts 
			on	VPXV_VMS.HOSTID = VPXV_HOSTS.HOSTID
		UNION		
		SELECT		vpxv_vms.NAME  COLLATE Latin1_General_CI_AS [ServerName]
				,vpxv_hosts.NAME  COLLATE Latin1_General_CI_AS [ESX_HostName]
		FROM		[ASHPSQLVCTRA].[VCDB].[dbo].vpxv_vms vpxv_vms
		JOIN		[ASHPSQLVCTRA].[VCDB].[dbo].vpxv_hosts vpxv_hosts 
			on	VPXV_VMS.HOSTID = VPXV_HOSTS.HOSTID
		)
		,Data
		AS
		(
		SELECT		SQL_Edition
				,REPLACE(REPLACE(REPLACE(SQL_Version,' (RTM)',''),' (SP1)',''),' (SP2)','') AS SQL_Version
				,SQL_Build
				,CASE WHEN PARSENAME(IPnum,3) IN ('216','220') THEN 'DR' ELSE 'A' END AS [Role]
				,T1.ServerName
				,ESX_HostName
				,SQLNAME 
				,upper(SQLEnv) [SQLEnv]
				,upper(DomainName) [DomainName]
				,SQL_BitLevel
				,cast(CPU_Physical as INT) [CPU_Physical]
				,cast(CPU_Cores as INT) [CPU_Cores]
				,cast(CPU_Logical as INT) [CPU_Logical]
				,CPU_BitLevel
				,IPnum
				,UPPER(Active) [Active]
				,CASE WHEN DomainName = 'production' AND SQLName != 'SEAEXSQLMAIL' THEN 'CPU' ELSE 'CAL' END AS [OldLicenseModel]
				,CASE WHEN DomainName = 'production' AND SQLName != 'SEAEXSQLMAIL' THEN cast(CPU_Physical as INT) ELSE 1 END AS [OldLicenseCount]
				,CASE WHEN SQL_Edition = 'ENTERPRISE' THEN 'CORE' WHEN DomainName = 'production' AND SQLName != 'SEAEXSQLMAIL' THEN 'CORE' ELSE 'CAL' END AS [NewLicenseModel]
				,CASE WHEN SQL_Edition = 'ENTERPRISE' THEN cast(CPU_Cores as INT) WHEN DomainName = 'production' AND SQLName != 'SEAEXSQLMAIL' THEN cast(CPU_Cores as INT) ELSE 1 END AS [NewLicenseCount]
		FROM		dbacentral.[dbo].[ServerInfo] T1
		LEFT JOIN	VCTR T2
			ON	T1.ServerName = T2.ServerName
		WHERE		Active != 'N'
				AND	SQLEnv = 'production'
		)
		
SELECT		*
		,CASE WHEN [OldLicenseModel] = 'CPU' AND [NewLicenseModel] = 'CORE' THEN (([NewLicenseCount]-([OldLicenseCount]*4))*100)/([OldLicenseCount]*4) ELSE 0 END [PercentChange]
		,CASE WHEN [OldLicenseModel] = 'CPU' AND [NewLicenseModel] = 'CORE' THEN [NewLicenseCount]-([OldLicenseCount]*4) ELSE 0 END [Change]
		,CASE WHEN [OldLicenseModel] = 'CPU' AND [NewLicenseModel] = 'CORE' THEN [OldLicenseCount]*4 ELSE 0 END [OldLicenseCoreEquivelent]
		,CASE WHEN EXISTS(SELECT * FROM C Where SQLName = Data.SQLName) THEN 1 ELSE 0 END AS IsClustered
		,COALESCE((SELECT MAX(IsActiveActive) From CAA WHERE SQLName = Data.SQLName),0) IsActiveActive
		--,CASE WHEN [OldLicenseModel] = 'CAL' THEN 0.0 WHEN [NewLicenseModel] = 'CAL' THEN 0.0 ELSE (([NewLicenseCount]*100)/[OldLicenseCoreEquivelent])-100 END [PercentChange]
		--,CASE WHEN [OldLicenseModel] = 'CAL' THEN 0.0 WHEN [NewLicenseModel] = 'CAL' THEN 0.0 ELSE [NewLicenseCount]-[OldLicenseCoreEquivelent] END [Change]
FROM		Data			
			

GO


