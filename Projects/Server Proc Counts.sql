USE [dbacentral]
GO

SELECT		DomainName
			,dbaadmin.dbo.Returnword(REPLACE(REPLACE([SQLver]
				,CHAR(9),' '),'  ',' '),4)								AS SQL_Version
			,dbaadmin.dbo.Returnword(REPLACE(REPLACE([SQLver]
				,CHAR(9),' '),'  ',' '),
					(
					SELECT		OccurenceId - 1
					FROM		dbaadmin.dbo.dbaudf_split(REPLACE(REPLACE([SQLver]
									,CHAR(9),' '),'  ',' '),' ')
					WHERE		SplitValue = 'Edition'
					))													AS SQL_Edition
			, SQLNAME													AS SQL_Name
			,REPLACE(CPUphysical,' physical','')						AS CPU_Physical
			,REPLACE(REPLACE(CPUcore,' cores',''),' core(s)','')		AS CPU_Cores
From		dbacentral.dbo.DBA_ServerInfo 
WHERE		DomainName		= 'production'
		AND	Active			= 'Y'
ORDER BY 1,2,3,4

GO

SELECT [DomainName]
      ,[SQL_Version]
      ,[SQL_Edition]
      ,[SQLNAME]
      ,[CPU_Physical]
      ,[CPU_Cores]
FROM [dbacentral].[dbo].[ServerInfo]
WHERE [SQLEnv] = 'production'
ORDER BY 1,2,3,4
GO





