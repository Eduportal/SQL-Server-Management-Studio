SELECT			DISTINCT
				T1.[RSTRfolder]
				,T2.ENVName
				,T2.SQLName

FROM			[dbacentral].[dbo].[db_ApplCrossRef] T1

JOIN			[dbacentral].[dbo].[DBA_DBInfo]	T2
	ON			T1.[db_name] = T2.[dbname]
LEFT JOIN		[dbacentral].[dbo].[DBA_DBInfo]	T3
	ON			T1.[companionDB_name] = T3.[dbname]	
	AND			T2.SQLName = T3.SQLName
WHERE			T1.[RSTRfolder] IS NOT NULL	
ORDER BY		2,1,3



SELECT			DISTINCT
				BaseLineFolder
				,ENVName
				,SQLName
FROM			[dbacentral].[dbo].[DBA_DBInfo]
WHERE			NULLIF(BaseLineFolder,'') IS NOT NULL
		--AND		SQLName = 'G1SQLB\B'






  



  

SELECT [SQLServerID]
      ,[ServerName]
      ,[ServerType]
      ,[SQLName]
      ,[SQLEnv]
      ,[Active]
      ,[Filescan]
      ,[SQLmail]
      ,[modDate]
      ,[SQLver]
      ,[SQLinstallDate]
      ,[SQLinstallBy]
      ,[SQLrecycleDate]
      ,[SQLSvcAcct]
      ,[SQLAgentAcct]
      ,[SQLStartupParms]
      ,[SQLScanforStartupSprocs]
      ,[dbaadmin_Version]
      ,[dbaperf_Version]
      ,[DEPLinfo_Version]
      ,[backup_type]
      ,[LiteSpeed]
      ,[RedGate]
      ,[awe_enabled]
      ,[MAXdop_value]
      ,[Memory]
      ,[SQLmax_memory]
      ,[tempdb_filecount]
      ,[FullTextCat]
      ,[Assemblies]
      ,[Mirroring]
      ,[Repl_Flag]
      ,[LogShipping]
      ,[LinkedServers]
      ,[ReportingSvcs]
      ,[LocalPasswords]
      ,[DEPLstatus]
      ,[IndxSnapshot_process]
      ,[IndxSnapshot_inverval]
      ,[CLR_state]
      ,[FrameWork_ver]
      ,[FrameWork_dir]
      ,[OracleClient]
      ,[TNSnamesPath]
      ,[DomainName]
      ,[iscluster]
      ,[SAN]
      ,[Port]
      ,[Location]
      ,[IPnum]
      ,[CPUphysical]
      ,[CPUcore]
      ,[CPUlogical]
      ,[CPUtype]
      ,[OSname]
      ,[OSver]
      ,[OSinstallDate]
      ,[OSuptime]
      ,[MDACver]
      ,[IEver]
      ,[AntiVirus_type]
      ,[AntiVirus_Excludes]
      ,[boot_3gb]
      ,[boot_pae]
      ,[boot_userva]
      ,[Pagefile_maxsize]
      ,[Pagefile_available]
      ,[Pagefile_inuse]
      ,[Pagefile_path]
      ,[TimeZone]
      ,[SystemModel]
      ,[MOMverifyDate]
  FROM [dbacentral].[dbo].[DBA_ServerInfo]