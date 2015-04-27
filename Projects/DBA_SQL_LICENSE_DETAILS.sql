USE [dbacentral]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW	[dbo].[DBA_SQL_LICENSE_DETAILS]
AS

SELECT		*
		,CASE WHEN [OldLicenseModel] = 'CPU' AND [NewLicenseModel] = 'CORE' THEN (([NewLicenseCount]-([OldLicenseCount]*4))*100)/([OldLicenseCount]*4) ELSE 0 END [PercentChange]
		,CASE WHEN [OldLicenseModel] = 'CPU' AND [NewLicenseModel] = 'CORE' THEN [NewLicenseCount]-([OldLicenseCount]*4) ELSE 0 END [Change]
		,CASE WHEN [OldLicenseModel] = 'CPU' AND [NewLicenseModel] = 'CORE' THEN [OldLicenseCount]*4 ELSE 0 END [OldLicenseCoreEquivelent]
FROM		(
		SELECT		SQL_Edition
				,REPLACE(REPLACE(REPLACE(SQL_Version,' (RTM)',''),' (SP1)',''),' (SP2)','') AS SQL_Version
				,SQL_Build
				,CASE WHEN PARSENAME(IPnum,3) IN ('216','220') THEN 'DR' ELSE 'A' END AS [Role]
				,ServerName
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
		FROM		dbacentral.[dbo].[ServerInfo] 
		WHERE		Active != 'N'
				AND	SQLEnv = 'production'
		) Data			
			
GO

			
