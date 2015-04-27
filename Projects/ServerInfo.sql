IF OBJECT_ID('[dbo].[ServerInfo]') IS NOT NULL
DROP VIEW	[dbo].[ServerInfo]
GO
CREATE VIEW	[dbo].[ServerInfo]
AS
SELECT	SQLServerID
	,ServerName
	,SQLNAME 
	,Port
	,DomainName
	,SQLEnv
	
	,dbaadmin.dbo.Returnword(REPLACE(REPLACE(REPLACE(REPLACE
		(REPLACE(SQLver,'- ',''),'(SP1) ',''),'Intel ','')
		,'(',''),')',''),4)					AS SQL_Version
	,dbaadmin.dbo.Returnword(REPLACE(REPLACE(REPLACE(REPLACE
		(REPLACE(SQLver,'- ',''),'(SP1) ',''),'Intel ','')
		,'(',''),')',''),5)					AS SQL_Build
	,dbaadmin.dbo.Returnword(REPLACE(REPLACE(REPLACE(REPLACE
		(REPLACE(REPLACE(SQLver,'- ',''),'(SP1) ','')
		,'Intel ',''),'(',''),')',''),'Corporation',''),15)	AS SQL_Edition
	,dbaadmin.dbo.Returnword(REPLACE(REPLACE(REPLACE(REPLACE
		(REPLACE(SQLver,'- ',''),'(SP1) ',''),'Intel ','')
		,'(',''),')',''),6)					AS SQL_BitLevel

	,REPLACE(CPUphysical,' physical','')				AS CPU_Physical
	,REPLACE(REPLACE(CPUcore,' cores',''),' core(s)','')		AS CPU_Cores
	,REPLACE(CPUlogical,' logical','')				AS CPU_Logical
	,REPLACE('X'+dbaadmin.dbo.Returnword(
		REPLACE(REPLACE(REPLACE(CPUtype,'EM','')
		,'Intel',''),'T',''),1),'xx','X')			AS CPU_BitLevel
	,SUBSTRING(CPUtype,CHARINDEX('~',CPUtype)+1
		,len(CPUtype)-CHARINDEX('~',CPUtype))			AS CPU_Speed
		
	,REPLACE(dbaadmin.dbo.Returnword(OSname,4),',','')		AS OS_Version
	,OSver								AS OS_Build
	,dbaadmin.dbo.Returnword(OSname,5)				AS OS_Edition
	,REPLACE(REPLACE('X86' + REPLACE(dbaadmin.dbo.Returnword
		(OSname,6),'Edition','X86'),'X86X86','X86')
		,'X86X64','X64')					AS OS_BitLevel
	
	,dbaadmin_Version						AS OPSDBVersion_DBAADMIN
	,dbaperf_Version						AS OPSDBVersion_DBAPERF
	,DEPLinfo_Version						AS OPSDBVersion_DEPLINFO

	,CAST(REPLACE(REPLACE(Memory,',',''),' MB','') AS FLOAT)		AS MEM_MB_Total
	,CAST(SQLmax_memory AS FLOAT)						AS MEM_MB_SQLMax
	,CAST(REPLACE(REPLACE(Pagefile_maxsize,',',''),' MB','') AS FLOAT)	AS MEM_MB_PageFileMax
	,CAST(REPLACE(REPLACE(Pagefile_available,',',''),' MB','') AS FLOAT)	AS MEM_MB_PageFileAvailable
	,CAST(REPLACE(REPLACE(Pagefile_inuse,',',''),' MB','') AS FLOAT)	AS MEM_MB_PageFileInUse
	
	,MDACver	
	,IEver	
	,AntiVirus_type	
	,AntiVirus_Excludes

	,awe_enabled
	,boot_3gb
	,boot_pae
	,boot_userva
	,iscluster
	,Active
	,Filescan
	,SQLMail
	,SQLScanforStartupSprocs
	,LiteSpeed	
	,RedGate
	,IndxSnapshot_process
	,SAN	
	,FullTextCat
	,Mirroring	
	,Repl_Flag	
	,LogShipping	
	,LinkedServers	
	,ReportingSvcs	
	,LocalPasswords	
	,DEPLstatus
	
	,IndxSnapshot_inverval
	,backup_type
	,MAXdop_value
	,tempdb_filecount	


	,REPLACE(CASE	WHEN TimeZone Like '%pacific%' THEN 'GMT-08:00'
		WHEN COALESCE(TimeZone,'') = '' THEN  'GMT-08:00'
		ELSE REPLACE(REPLACE(LEFT(TimeZone,CHARINDEX(')',TimeZone+')')),'(',''),')','')
		END,'GMT','') AS DateTime_Offset
	,modDate
	,SQLinstallDate	
	,SQLinstallBy	
	,SQLrecycleDate
	,OSinstallDate	
	,OSuptime
	,MOMverifyDate

	,SQLSvcAcct	
	,SQLAgentAcct

	,Assemblies
	,CLR_state
	,FrameWork_ver
	,FrameWork_dir
	,OracleClient	
	,TNSnamesPath
	,Location
	,IPnum
From
dbacentral.dbo.DBA_ServerInfo 
GO

