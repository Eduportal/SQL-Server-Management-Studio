USE [dbacentral]
GO

SELECT	DomainName
	
	,dbaadmin.dbo.Returnword(REPLACE(REPLACE([SQLver],CHAR(9),' '),'  ',' '),4)			AS SQL_Version
	--,CASE WHEN (SELECT MIN(OccurenceId) FROM dbaadmin.dbo.dbaudf_split(REPLACE(REPLACE([SQLver],CHAR(9),' '),'  ',' '),' ')WHERE SplitValue = '-') > 5 THEN dbaadmin.dbo.Returnword(REPLACE(REPLACE([SQLver],CHAR(9),' '),'  ',' '),5)+' ' ELSE '' END
	--+CASE WHEN (SELECT MIN(OccurenceId) FROM dbaadmin.dbo.dbaudf_split(REPLACE(REPLACE([SQLver],CHAR(9),' '),'  ',' '),' ')WHERE SplitValue = '-') > 6 THEN dbaadmin.dbo.Returnword(REPLACE(REPLACE([SQLver],CHAR(9),' '),'  ',' '),6)+' ' ELSE '' END
	--+CASE WHEN (SELECT MIN(OccurenceId) FROM dbaadmin.dbo.dbaudf_split(REPLACE(REPLACE([SQLver],CHAR(9),' '),'  ',' '),' ')WHERE SplitValue = '-') > 7 THEN dbaadmin.dbo.Returnword(REPLACE(REPLACE([SQLver],CHAR(9),' '),'  ',' '),7)+' ' ELSE '' END
	--+CASE WHEN (SELECT MIN(OccurenceId) FROM dbaadmin.dbo.dbaudf_split(REPLACE(REPLACE([SQLver],CHAR(9),' '),'  ',' '),' ')WHERE SplitValue = '-') > 8 THEN dbaadmin.dbo.Returnword(REPLACE(REPLACE([SQLver],CHAR(9),' '),'  ',' '),8) ELSE '' END
	
	
	,dbaadmin.dbo.Returnword(REPLACE(REPLACE([SQLver],CHAR(9),' '),'  ',' ')
							 ,(
								SELECT		OccurenceId - 1
								FROM		dbaadmin.dbo.dbaudf_split(REPLACE(REPLACE([SQLver],CHAR(9),' '),'  ',' '),' ')
								WHERE		SplitValue = 'Edition'
							  )
							)									AS SQL_Edition
		, SQLNAME 

	,REPLACE(CPUphysical,' physical','')						AS CPU_Physical
	,REPLACE(REPLACE(CPUcore,' cores',''),' core(s)','')		AS CPU_Cores
From
dbacentral.dbo.DBA_ServerInfo 
WHERE				SQLEnv = 'production'
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





								CASE WHEN (SELECT MIN(OccurenceId) FROM dbaadmin.dbo.dbaudf_split(REPLACE(REPLACE([SQLver],CHAR(9),' '),'  ',' '),' ')WHERE SplitValue = '-') > 5 THEN


Microsoft SQL Server 2005 - 9.00.3077.00 (X64)  Dec 17 2008 20:40:08  Copyright (c) 1988-2005 Microsoft Corporation Enterprise Edition (64-bit) on Windows NT 5.2 (Build 3790: Service Pack 2)
Microsoft SQL Server 2008 R2 (RTM) - 10.50.1600.1 (X64)  Apr 2 2010 15:48:46  Copyright (c) Microsoft Corporation Standard Edition (64-bit) on Windows NT 6.0 <X64> (Build 6002: Service Pack 2)
Microsoft SQL Server 2008 (SP1) - 10.0.2531.0 (X64)  Mar 29 2009 10:11:52  Copyright (c) 1988-2008 Microsoft Corporation Standard Edition (64-bit) on Windows NT 6.0 <X64> (Build 6002: Service Pack 2)
Microsoft SQL Server 2005 - 9.00.3282.00 (Intel X86)  Aug 5 2008 01:01:05  Copyright (c) 1988-2005 Microsoft Corporation Enterprise Edition on Windows NT 5.2 (Build 3790: Service Pack 2)
Microsoft SQL Server 2008 R2 (RTM) - 10.50.1600.1 (X64)  Apr 2 2010 15:48:46  Copyright (c) Microsoft Corporation Standard Edition (64-bit) on Windows NT 6.0 <X64> (Build 6002: Service Pack 2)
Microsoft SQL Server 2008 R2 (RTM) - 10.50.1600.1 (X64)  Apr 2 2010 15:48:46  Copyright (c) Microsoft Corporation Enterprise Edition (64-bit) on Windows NT 6.0 <X64> (Build 6002: Service Pack 2) (VM)