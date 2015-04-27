
DECLARE	@ServerName_E			VarChar(max)	
	,@ServerName_I			VarChar(max)	
	,@DomainName_E			VarChar(max)	
	,@DomainName_I			VarChar(max)	
	,@SQLenv_E			VarChar(max)	
	,@SQLenv_I			VarChar(max)	
	,@SQL_Version_E			VarChar(max)	
	,@SQL_Version_I			VarChar(max)	
	,@SQL_Edition_E			VarChar(max)	
	,@SQL_Edition_I			VarChar(max)	
	,@SQL_BitLevel_E		VarChar(max)	
	,@SQL_BitLevel_I		VarChar(max)	
	,@CPU_BitLevel_E		VarChar(max)	
	,@CPU_BitLevel_I		VarChar(max)	
	,@OS_BitLevel_E			VarChar(max)	
	,@OS_BitLevel_I			VarChar(max)	
	,@OS_Version_E			VarChar(max)	
	,@OS_Version_I			VarChar(max)	
	,@OS_Edition_E			VarChar(max)	
	,@OS_Edition_I			VarChar(max)	
	,@backup_type_E			VarChar(max)	
	,@backup_type_I			VarChar(max)	
	,@SQLSvcAcct_E			VarChar(max)	
	,@SQLSvcAcct_I			VarChar(max)	
	,@SQLAgentAcct_E		VarChar(max)	
	,@SQLAgentAcct_I		VarChar(max)	
	,@CLR_state_E			VarChar(max)	
	,@CLR_state_I			VarChar(max)	
	-- Y/N FIELDS
	,@AntiVirus_Excludes		CHAR(1)		
	,@awe_enabled			CHAR(1)		
	,@boot_3gb			CHAR(1)		
	,@boot_pae			CHAR(1)		
	,@boot_userva			CHAR(1)		
	,@iscluster			CHAR(1)		
	,@Active			CHAR(1)		
	,@Filescan			CHAR(1)		
	,@SQLMail			CHAR(1)		
	,@SQLScanforStartupSprocs	CHAR(1)		
	,@LiteSpeed			CHAR(1)		
	,@RedGate			CHAR(1)		
	,@IndxSnapshot_process		CHAR(1)		
	,@SAN				CHAR(1)		
	,@FullTextCat			CHAR(1)		
	,@Mirroring			CHAR(1)		
	,@Repl_Flag			CHAR(1)		
	,@LogShipping			CHAR(1)		
	,@LinkedServers			CHAR(1)		
	,@ReportingSvcs			CHAR(1)		
	,@LocalPasswords		CHAR(1)		
	,@DEPLstatus			CHAR(1)		


SELECT	@ServerName_E			= NULL
	,@ServerName_I			= NULL
	,@DomainName_E			= NULL
	,@DomainName_I			= NULL
	,@SQLenv_E			= NULL
	,@SQLenv_I			= NULL
	,@SQL_Version_E			= NULL
	,@SQL_Version_I			= NULL
	,@SQL_Edition_E			= NULL
	,@SQL_Edition_I			= NULL
	,@SQL_BitLevel_E		= NULL
	,@SQL_BitLevel_I		= 'X86'
	,@CPU_BitLevel_E		= NULL
	,@CPU_BitLevel_I		= NULL
	,@OS_BitLevel_E			= NULL
	,@OS_BitLevel_I			= NULL
	,@OS_Version_E			= NULL
	,@OS_Version_I			= NULL
	,@OS_Edition_E			= NULL
	,@OS_Edition_I			= NULL
	,@backup_type_E			= NULL
	,@backup_type_I			= NULL
	,@SQLSvcAcct_E			= NULL
	,@SQLSvcAcct_I			= NULL
	,@SQLAgentAcct_E		= NULL
	,@SQLAgentAcct_I		= NULL
	,@CLR_state_E			= NULL
	,@CLR_state_I			= NULL
	-- Y/N FIELDS
	,@AntiVirus_Excludes		= NULL
	,@awe_enabled			= 'y'
	,@boot_3gb			= NULL
	,@boot_pae			= NULL
	,@boot_userva			= NULL
	,@iscluster			= NULL
	,@Active			= NULL
	,@Filescan			= NULL
	,@SQLMail			= NULL
	,@SQLScanforStartupSprocs	= NULL
	,@LiteSpeed			= NULL
	,@RedGate			= NULL
	,@IndxSnapshot_process		= NULL
	,@SAN				= NULL
	,@FullTextCat			= NULL
	,@Mirroring			= NULL
	,@Repl_Flag			= NULL
	,@LogShipping			= NULL
	,@LinkedServers			= NULL
	,@ReportingSvcs			= NULL
	,@LocalPasswords		= NULL
	,@DEPLstatus			= NULL

SELECT		*
FROM		[dbacentral].[dbo].[SEARCH_ServerInfo] 
				(
				@ServerName_E
				,@ServerName_I
				,@DomainName_E
				,@DomainName_I
				,@SQLenv_E
				,@SQLenv_I
				,@SQL_Version_E
				,@SQL_Version_I
				,@SQL_Edition_E
				,@SQL_Edition_I
				,@SQL_BitLevel_E
				,@SQL_BitLevel_I
				,@CPU_BitLevel_E
				,@CPU_BitLevel_I
				,@OS_BitLevel_E
				,@OS_BitLevel_I
				,@OS_Version_E
				,@OS_Version_I
				,@OS_Edition_E
				,@OS_Edition_I
				,@backup_type_E
				,@backup_type_I
				,@SQLSvcAcct_E
				,@SQLSvcAcct_I
				,@SQLAgentAcct_E
				,@SQLAgentAcct_I
				,@CLR_state_E
				,@CLR_state_I
				,@AntiVirus_Excludes
				,@awe_enabled
				,@boot_3gb
				,@boot_pae
				,@boot_userva
				,@iscluster
				,@Active
				,@Filescan
				,@SQLMail
				,@SQLScanforStartupSprocs
				,@LiteSpeed
				,@RedGate
				,@IndxSnapshot_process
				,@SAN
				,@FullTextCat
				,@Mirroring
				,@Repl_Flag
				,@LogShipping
				,@LinkedServers
				,@ReportingSvcs
				,@LocalPasswords
				,@DEPLstatus
				)
	ORDER BY	SQLNAME