IF OBJECT_ID('[dbo].[dbasp_CreateSQLCMD_ToAll]') IS NOT NULL
DROP PROCEDURE dbasp_CreateSQLCMD_ToAll  
GO  
CREATE PROCEDURE dbasp_CreateSQLCMD_ToAll
	(
	@Command			VarChar(max)
	,@Environment			sysname		= NULL
	,@Ticket			sysname		= NULL
	,@Results			sysname		= 'Results.txt'
	,@ServerName_E			VarChar(max)	= NULL
	,@ServerName_I			VarChar(max)	= NULL
	,@SQLName_E			VarChar(max)	= NULL
	,@SQLName_I			VarChar(max)	= NULL
	,@DomainName_E			VarChar(max)	= NULL
	,@DomainName_I			VarChar(max)	= NULL
	,@SQLenv_E			VarChar(max)	= NULL
	,@SQLenv_I			VarChar(max)	= NULL
	,@SQL_Version_E			VarChar(max)	= NULL
	,@SQL_Version_I			VarChar(max)	= NULL
	,@SQL_Edition_E			VarChar(max)	= NULL
	,@SQL_Edition_I			VarChar(max)	= NULL
	,@SQL_BitLevel_E		VarChar(max)	= NULL
	,@SQL_BitLevel_I		VarChar(max)	= NULL
	,@CPU_BitLevel_E		VarChar(max)	= NULL
	,@CPU_BitLevel_I		VarChar(max)	= NULL
	,@OS_BitLevel_E			VarChar(max)	= NULL
	,@OS_BitLevel_I			VarChar(max)	= NULL
	,@OS_Version_E			VarChar(max)	= NULL
	,@OS_Version_I			VarChar(max)	= NULL
	,@OS_Edition_E			VarChar(max)	= NULL
	,@OS_Edition_I			VarChar(max)	= NULL
	,@backup_type_E			VarChar(max)	= NULL
	,@backup_type_I			VarChar(max)	= NULL
	,@SQLSvcAcct_E			VarChar(max)	= NULL
	,@SQLSvcAcct_I			VarChar(max)	= NULL
	,@SQLAgentAcct_E		VarChar(max)	= NULL
	,@SQLAgentAcct_I		VarChar(max)	= NULL
	,@CLR_state_E			VarChar(max)	= NULL
	,@CLR_state_I			VarChar(max)	= NULL
	
	-- >= & <= Fields
	,@MEM_MB_Total_GE		FLOAT		= NULL
	,@MEM_MB_Total_LE		FLOAT		= NULL
	
	-- Y/N FIELDS
	,@AntiVirus_Excludes		CHAR(1)		= NULL
	,@awe_enabled			CHAR(1)		= NULL
	,@boot_3gb			CHAR(1)		= NULL
	,@boot_pae			CHAR(1)		= NULL
	,@boot_userva			CHAR(1)		= NULL
	,@iscluster			CHAR(1)		= NULL
	,@Active			CHAR(1)		= NULL
	,@Filescan			CHAR(1)		= NULL
	,@SQLMail			CHAR(1)		= NULL
	,@SQLScanforStartupSprocs	CHAR(1)		= NULL
	,@LiteSpeed			CHAR(1)		= NULL
	,@RedGate			CHAR(1)		= NULL
	,@IndxSnapshot_process		CHAR(1)		= NULL
	,@SAN				CHAR(1)		= NULL
	,@FullTextCat			CHAR(1)		= NULL
	,@Mirroring			CHAR(1)		= NULL
	,@Repl_Flag			CHAR(1)		= NULL
	,@LogShipping			CHAR(1)		= NULL
	,@LinkedServers			CHAR(1)		= NULL
	,@ReportingSvcs			CHAR(1)		= NULL
	,@LocalPasswords		CHAR(1)		= NULL
	,@DEPLstatus			CHAR(1)		= NULL
	)
AS	  
BEGIN  
	DECLARE	@TSQL	VarChar(max)
	SELECT	@Environment = COALESCE(@Environment,'')
		,@Ticket = COALESCE(@Ticket,'')

	DECLARE ActiveServerCursor CURSOR
	KEYSET
	FOR 
	SELECT	':CONNECT ' + SQLNAME 
		+ CASE Port
			WHEN 1433 THEN ''
			ELSE ',' + Port
			END
		+ CASE 	DomainName
			WHEN 'AMER' THEN ''
			ELSE ' -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)'
			END 
		+ CHAR(13) + CHAR(10)
		+ 'PRINT '''''	+ CHAR(13) + CHAR(10)
		+ 'PRINT''-- RUNNING COMMAND > '+ REPLACE(REPLACE(@Command,'{DomainName}',DomainName),'{SQLSvcAcct}',SQLSvcAcct) + '''' + CHAR(13) + CHAR(10)
		+ REPLACE(REPLACE(@Command,'{DomainName}',DomainName),'{SQLSvcAcct}',SQLSvcAcct) + CHAR(13) + CHAR(10)
		+ 'PRINT''-- DONE...'''+ CHAR(13) + CHAR(10)
		+ 'PRINT '''''	+ CHAR(13) + CHAR(10)
		+'GO' + CHAR(13) + CHAR(10)
	FROM		[dbacentral].[dbo].[SEARCH_ServerInfo] 
				(
				@ServerName_E
				,@ServerName_I
				,@SQLName_E
				,@SQLName_I
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
				,@MEM_MB_Total_GE
				,@MEM_MB_Total_LE
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
	
	OPEN ActiveServerCursor

PRINT '' 
PRINT ':SETVAR	SQLCMD_UserSettings "\SQLCMD_UserSettings.sql"'
PRINT ':SETVAR SQLCMD_GlobalSettings "\\seafresqldba01\DBA_Docs\SQLCMD_GlobalSettings.sql"'
PRINT 'GO'
PRINT ':ON ERROR IGNORE'
PRINT 'GO'
PRINT '-- DECLARE AND SET USER VARIABLES'
PRINT ':r $(USERPROFILE)$(SQLCMD_UserSettings)'
PRINT 'GO'
PRINT '-- DECLARE AND SET GLOBAL VARIABLES'
PRINT ':r $(SQLCMD_GlobalSettings)'
PRINT 'GO'
PRINT ''

IF COALESCE(@Environment + @Ticket,'') > '' 
BEGIN
	PRINT ':SETVAR SQLENV "'+@Environment+'"'
	PRINT ':SETVAR TICKET "'+@Ticket+'"'
	PRINT 'GO'
	PRINT '-- CREATE RESULTS DIRECTORY'
	PRINT '!!if not exist ".\"$(SQLENV)"_"$(TICKET) md ".\"$(SQLENV)"_"$(TICKET)'
	PRINT 'GO'
	PRINT '-- USE OUTPUT DIR TO SAVE RESULTS TO FILE'
	PRINT ':OUT ".\"$(SQLENV)"_"$(TICKET)"\'+@Results+'"'
	PRINT 'GO'
	PRINT ''
	PRINT 'PRINT	''-- DIRECTORY OF OUTPUT FOLDER'''
	PRINT 'GO'
	PRINT '!!dir ".\$(SQLENV)_$(TICKET)"'
	PRINT 'GO'	
	PRINT ''
	PRINT ''
END
ELSE
BEGIN
	PRINT ':OUT STDERR'
	PRINT 'GO'
	PRINT ''
END
PRINT ''
PRINT 'PRINT	''------------------------------------------------'''
PRINT 'PRINT	''--'''
PRINT 'PRINT	''--           SCRIPT EXECUTION RESULTS		 '''
PRINT 'PRINT	''--'''
PRINT 'PRINT	''------------------------------------------------'''
PRINT 'PRINT	''-- RUN BY    $(USERNAME) AT '' + CAST(GetDate() AS VarChar(50))'
PRINT 'PRINT	''-- RUN FROM  $(USERDNSDOMAIN).$(COMPUTERNAME)   '''
PRINT 'PRINT	''-- USING $(SQLCMDUSER) As Login when needed'''
PRINT 'PRINT	''--'''
PRINT 'PRINT	''-- USER SETTINGS AT      $(USERPROFILE)$(SQLCMD_UserSettings) '''
PRINT 'PRINT	''-- GLOBAL SETTINGS AT    $(SQLCMD_GlobalSettings) '''
PRINT 'PRINT	''-- SQLCMDINI AT          $(SQLCMDINI) '''
PRINT 'PRINT	''--'''

IF COALESCE(@Environment + @Ticket,'') > '' 
PRINT 'PRINT	''-- OUTPUT AT             .\$(SQLENV)_$(TICKET)\'+@Results+''''

PRINT 'PRINT	''------------------------------------------------'''
PRINT 'PRINT	'''''
PRINT 'GO'
PRINT ''
PRINT ''
	
	FETCH NEXT FROM ActiveServerCursor INTO @TSQL
	WHILE (@@fetch_status > -1)
	BEGIN
		IF (@@fetch_status > -2)
		BEGIN
			PRINT @TSQL
		END
		FETCH NEXT FROM ActiveServerCursor INTO @TSQL
	END

	CLOSE ActiveServerCursor
	DEALLOCATE ActiveServerCursor
	
PRINT ''
PRINT '-- CLEAR USERNAME AND PASSWORD'
PRINT ':setvar SQLCMDUSER '
PRINT ':setvar SQLCMDPASSWORD '
PRINT ''	
END
GO