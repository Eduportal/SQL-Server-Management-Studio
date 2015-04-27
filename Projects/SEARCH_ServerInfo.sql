IF OBJECT_ID (N'dbo.SEARCH_ServerInfo') IS NOT NULL
    DROP FUNCTION dbo.SEARCH_ServerInfo
GO

CREATE FUNCTION dbo.SEARCH_ServerInfo
	(
--DECLARE
	@ServerName_E		VarChar(max)
	,@ServerName_I		VarChar(max)
	,@SQLName_E		VarChar(max)
	,@SQLName_I		VarChar(max)	
	,@DomainName_E		VarChar(max)
	,@DomainName_I		VarChar(max)
	,@SQLenv_E		VarChar(max)
	,@SQLenv_I		VarChar(max)
	,@SQL_Version_E		VarChar(max)
	,@SQL_Version_I		VarChar(max)
	,@SQL_Edition_E		VarChar(max)
	,@SQL_Edition_I		VarChar(max)
	,@SQL_BitLevel_E	VarChar(max)
	,@SQL_BitLevel_I	VarChar(max)
	,@CPU_BitLevel_E	VarChar(max)
	,@CPU_BitLevel_I	VarChar(max)
	,@OS_BitLevel_E		VarChar(max)
	,@OS_BitLevel_I		VarChar(max)
	,@OS_Version_E		VarChar(max)
	,@OS_Version_I		VarChar(max)
	,@OS_Edition_E		VarChar(max)
	,@OS_Edition_I		VarChar(max)
	,@backup_type_E		VarChar(max)
	,@backup_type_I		VarChar(max)
	,@SQLSvcAcct_E		VarChar(max)
	,@SQLSvcAcct_I		VarChar(max)
	,@SQLAgentAcct_E	VarChar(max)
	,@SQLAgentAcct_I	VarChar(max)
	,@CLR_state_E		VarChar(max)
	,@CLR_state_I		VarChar(max)
	-- >= & <= Fields
	,@MEM_MB_Total_GE	FLOAT
	,@MEM_MB_Total_LE	FLOAT
	-- Y/N FIELDS
	,@AntiVirus_Excludes	CHAR(1)
	,@awe_enabled		CHAR(1)
	,@boot_3gb		CHAR(1)
	,@boot_pae		CHAR(1)
	,@boot_userva		CHAR(1)
	,@iscluster		CHAR(1)
	,@Active		CHAR(1)
	,@Filescan		CHAR(1)
	,@SQLMail		CHAR(1)
	,@SQLScanforStartupSprocs	CHAR(1)
	,@LiteSpeed		CHAR(1)
	,@RedGate		CHAR(1)
	,@IndxSnapshot_process	CHAR(1)
	,@SAN			CHAR(1)
	,@FullTextCat		CHAR(1)
	,@Mirroring		CHAR(1)
	,@Repl_Flag		CHAR(1)
	,@LogShipping		CHAR(1)
	,@LinkedServers		CHAR(1)
	,@ReportingSvcs		CHAR(1)
	,@LocalPasswords	CHAR(1)
	,@DEPLstatus		CHAR(1)

	)
RETURNS TABLE
AS RETURN
(
	SELECT 
			* 
			
			
			
	FROM		[dbo].[ServerInfo]

	WHERE		(ServerName NOT IN	(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@ServerName_E,','))	OR @ServerName_E	IS NULL)
		AND	(ServerName IN		(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@ServerName_I,','))	OR @ServerName_I	IS NULL)

		AND	(SQLName NOT IN		(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@SQLName_E,','))		OR @SQLName_E		IS NULL)
		AND	(SQLName IN		(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@SQLName_I,','))		OR @SQLName_I		IS NULL)

		AND	(DomainName NOT IN	(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@DomainName_E,','))	OR @DomainName_E	IS NULL)
		AND	(DomainName IN		(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@DomainName_I,','))	OR @DomainName_I	IS NULL)

		AND	(SQLenv NOT IN		(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@SQLenv_E,','))		OR @SQLenv_E		IS NULL)
		AND	(SQLenv IN		(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@SQLenv_I,','))		OR @SQLenv_I		IS NULL)

		AND	(SQL_Version NOT IN	(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@SQL_Version_E,','))	OR @SQL_Version_E	IS NULL)
		AND	(SQL_Version IN		(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@SQL_Version_I,','))	OR @SQL_Version_I	IS NULL)

		AND	(SQL_Edition NOT IN	(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@SQL_Edition_E,','))	OR @SQL_Edition_E	IS NULL)
		AND	(SQL_Edition IN		(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@SQL_Edition_I,','))	OR @SQL_Edition_I	IS NULL)

		AND	(CLR_state NOT IN	(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@CLR_state_E,','))		OR @CLR_state_E		IS NULL)
		AND	(CLR_state IN		(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@CLR_state_I,','))		OR @CLR_state_I		IS NULL)

		AND	(SQLAgentAcct NOT IN	(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@SQLAgentAcct_E,','))	OR @SQLAgentAcct_E	IS NULL)
		AND	(SQLAgentAcct IN	(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@SQLAgentAcct_I,','))	OR @SQLAgentAcct_I	IS NULL)

		AND	(SQLSvcAcct NOT IN	(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@SQLSvcAcct_E,','))	OR @SQLSvcAcct_E	IS NULL)
		AND	(SQLSvcAcct IN		(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@SQLSvcAcct_I,','))	OR @SQLSvcAcct_I	IS NULL)

		AND	(backup_type NOT IN	(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@backup_type_E,','))	OR @backup_type_E	IS NULL)
		AND	(backup_type IN		(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@backup_type_I,','))	OR @backup_type_I	IS NULL)

		AND	(OS_Edition NOT IN	(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@OS_Edition_E,','))	OR @OS_Edition_E	IS NULL)
		AND	(OS_Edition IN		(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@OS_Edition_I,','))	OR @OS_Edition_I	IS NULL)

		AND	(OS_Version NOT IN	(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@OS_Version_E,','))	OR @OS_Version_E	IS NULL)
		AND	(OS_Version IN		(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@OS_Version_I,','))	OR @OS_Version_I	IS NULL)

		AND	(OS_BitLevel NOT IN	(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@OS_BitLevel_E,','))	OR @OS_BitLevel_E	IS NULL)
		AND	(OS_BitLevel IN		(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@OS_BitLevel_I,','))	OR @OS_BitLevel_I	IS NULL)

		AND	(CPU_BitLevel NOT IN	(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@CPU_BitLevel_E,','))	OR @CPU_BitLevel_E	IS NULL)
		AND	(CPU_BitLevel IN	(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@CPU_BitLevel_I,','))	OR @CPU_BitLevel_I	IS NULL)

		AND	(SQL_BitLevel NOT IN	(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@SQL_BitLevel_E,','))	OR @SQL_BitLevel_E	IS NULL)
		AND	(SQL_BitLevel IN	(SELECT DISTINCT ExtractedText FROM dbo.dbaudf_StringToTable(@SQL_BitLevel_I,','))	OR @SQL_BitLevel_I	IS NULL)

		
		AND	(MEM_MB_Total >=		@MEM_MB_Total_GE		OR @MEM_MB_Total_GE		IS NULL)
		AND	(MEM_MB_Total <=		@MEM_MB_Total_LE		OR @MEM_MB_Total_LE		IS NULL)


		AND	(AntiVirus_Excludes		= @AntiVirus_Excludes		OR @AntiVirus_Excludes		IS NULL)
		AND	(awe_enabled			= @awe_enabled			OR @awe_enabled			IS NULL)	
		AND	(boot_3gb			= @boot_3gb			OR @boot_3gb			IS NULL)	
		AND	(boot_pae			= @boot_pae			OR @boot_pae			IS NULL)	
		AND	(boot_userva			= @boot_userva			OR @boot_userva			IS NULL)	
		AND	(iscluster			= @iscluster			OR @iscluster			IS NULL)	
		AND	(Active				= @Active			OR @Active			IS NULL)	
		AND	(Filescan			= @Filescan			OR @Filescan			IS NULL)	
		AND	(SQLMail			= @SQLMail			OR @SQLMail			IS NULL)	
		AND	(SQLScanforStartupSprocs	= @SQLScanforStartupSprocs	OR @SQLScanforStartupSprocs	IS NULL)
		AND	(LiteSpeed			= @LiteSpeed			OR @LiteSpeed			IS NULL)		
		AND	(RedGate			= @RedGate			OR @RedGate			IS NULL)		
		AND	(IndxSnapshot_process		= @IndxSnapshot_process		OR @IndxSnapshot_process	IS NULL)	
		AND	(SAN				= @SAN				OR @SAN				IS NULL)			
		AND	(FullTextCat			= @FullTextCat			OR @FullTextCat			IS NULL)		
		AND	(Mirroring			= @Mirroring			OR @Mirroring			IS NULL)		
		AND	(Repl_Flag			= @Repl_Flag			OR @Repl_Flag			IS NULL)		
		AND	(LogShipping			= @LogShipping			OR @LogShipping			IS NULL)		
		AND	(LinkedServers			= @LinkedServers		OR @LinkedServers		IS NULL)		
		AND	(ReportingSvcs			= @ReportingSvcs		OR @ReportingSvcs		IS NULL)		
		AND	(LocalPasswords			= @LocalPasswords		OR @LocalPasswords		IS NULL)	
		AND	(DEPLstatus			= @DEPLstatus			OR @DEPLstatus			IS NULL)		

)
GO