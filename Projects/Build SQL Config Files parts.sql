SET NOCOUNT ON

DECLARE @Data Table 
	(
	ParamOrder INT
	,ParamType sysname
	,Parameter sysname
	,DefaultValue sysname
	,Description VarChar(MAX)
	)
	
	
INSERT INTO @Data SELECT 01,'SQL Server Setup Control'		,'ACTION','DefaultValue','to indicate the installation workflow. Supported values: •Install'
INSERT INTO @Data SELECT 02,'SQL Server Setup Control'		,'CONFIGURATIONFILE','DefaultValue','Specifies the ConfigurationFile [ http:msdn.microsoft.comen-uslibrarydd239405.aspx ] to use.'
INSERT INTO @Data SELECT 03,'SQL Server Setup Control'		,'ERRORREPORTING','DefaultValue','Specifies the error reporting for SQL Server. For more information, see Privacy Statement for the Microsoft Error Reporting Service [ http:go.microsoft.comfwlink?LinkID=72173 ] . Supported values: •1=enabled •0=disabled'
INSERT INTO @Data SELECT 04,'SQL Server Setup Control'		,'FEATURES','DefaultValue','Specifies components to install.'
INSERT INTO @Data SELECT 05,'SQL Server Setup Control'		,'HELP','DefaultValue','Displays the usage options for installation parameters.'
INSERT INTO @Data SELECT 06,'SQL Server Setup Control'		,'INDICATEPROGRESS','DefaultValue','Specifies that the verbose Setup log file is piped to the console.'
INSERT INTO @Data SELECT 07,'SQL Server Setup Control'		,'INSTALLSHAREDDIR','DefaultValue','Specifies a nondefault installation directory for 64-bit shared components.'
INSERT INTO @Data SELECT 08,'SQL Server Setup Control'		,'INSTALLSHAREDWOWDIR','DefaultValue','Specifies a nondefault installation directory for 32-bit shared components. Supported only on a 64-bit system.'
INSERT INTO @Data SELECT 09,'SQL Server Setup Control'		,'INSTANCEDIR','DefaultValue','Specifies a nondefault installation directory for instance-specific components.'
INSERT INTO @Data SELECT 11,'SQL Server Setup Control'		,'INSTANCEID','DefaultValue','Specifies a nondefault value for an InstanceID.'
INSERT INTO @Data SELECT 11,'SQL Server Setup Control'		,'INSTANCENAME','DefaultValue','Specifies a SQL Server instance name. For more information, see Instance Configuration [ http:msdn.microsoft.comen-uslibraryms143531.aspx ] .'
INSERT INTO @Data SELECT 12,'SQL Server Setup Control'		,'PID','DefaultValue','Specifies the product key for the edition of SQL Server. If this parameter is not specified, SQL Server 2008 Enterprise Evaluation is used.'
INSERT INTO @Data SELECT 13,'SQL Server Setup Control'		,'Q','DefaultValue','Specifies that Setup runs in a quiet mode without any user interface. This is used for unattended installations.'
INSERT INTO @Data SELECT 14,'SQL Server Setup Control'		,'QS','DefaultValue','Specifies that Setup runs and shows progress through the UI, but does not accept any input or show any error messages.'
INSERT INTO @Data SELECT 15,'SQL Server Setup Control'		,'SQMREPORTING','DefaultValue','Specifies feature usage reporting for SQL Server. For more information, see Privacy Statement for the Microsoft Error Reporting Service [ http:go.microsoft.comfwlink?LinkID=72173 ] . Supported values: •1=enabled •0=disabled'
INSERT INTO @Data SELECT 16,'SQL Server Setup Control'		,'HIDECONSOLE','DefaultValue','Specifies that the console window is hidden or closed.'
INSERT INTO @Data SELECT 17,'SQL Server Agent'			,'AGTSVCACCOUNT','DefaultValue','Specifies the account for the SQL Server Agent service.'
INSERT INTO @Data SELECT 18,'SQL Server Agent'			,'AGTSVCPASSWORD','DefaultValue','Specifies the password for SQL Server Agent service account.'
INSERT INTO @Data SELECT 19,'SQL Server Agent'			,'AGTSVCSTARTUPTYPE','DefaultValue','Specifies the startup mode for the SQL Server Agent service. Supported values: •Automatic •Disabled •Manual'
INSERT INTO @Data SELECT 20,'','','',''
INSERT INTO @Data SELECT 21,'Analysis Services'			,'ASBACKUPDIR','DefaultValue','Specifies the directory for Analysis Services backup files. Default values: •For WOW mode on 64-bit: %Program Files(x86)%\Microsoft SQL Server\ <INSTANCEDIR>\<ASInstanceID>\OLAP\Backup. •For all other installations: %Program Files%\Microsoft SQL Server\ <INSTANCEDIR>\<ASInstanceID>\OLAP\Backup.'
INSERT INTO @Data SELECT 22,'Analysis Services'			,'ASCOLLATION','DefaultValue','Specifies the collation setting for Analysis Services. Default value: •Latin1_General_CI_AS'
INSERT INTO @Data SELECT 23,'Analysis Services'			,'ASCONFIGDIR','DefaultValue','Specifies the directory for Analysis Services configuration files. Default values: •For WOW mode on 64-bit: %Program Files(x86)%\Microsoft SQL Server\ <INSTANCEDIR>\<ASInstanceID>\OLAP\Config. •For all other installations: %Program Files%\Microsoft SQL Server\<INSTANCEDIR>\<ASInstanceID>\OLAP\Config.'
INSERT INTO @Data SELECT 24,'Analysis Services'			,'ASDATADIR','DefaultValue','Specifies the directory for Analysis Services data files. Default values: •For WOW mode on 64-bit: %Program Files(x86)%\Microsoft SQL Server\<INSTANCEDIR>\<ASInstanceID>\OLAP\Data. •For all other installations: %Program Files%\Microsoft SQL Server\<INSTANCEDIR>\<ASInstanceID>\OLAP\Data.'
INSERT INTO @Data SELECT 25,'Analysis Services'			,'ASLOGDIR','DefaultValue','Specifies the directory for Analysis Services log files. Default values: •For WOW mode on 64-bit: %Program Files(x86)%\Microsoft SQL Server\<INSTANCEDIR>\<ASInstanceID>\OLAP\Log. •For all other installations: %Program Files%\Microsoft SQL Server\<INSTANCEDIR>\<ASInstanceID>\OLAP\Log.'
INSERT INTO @Data SELECT 26,'Analysis Services'			,'ASSVCACCOUNT','DefaultValue','Specifies the account for the Analysis Services service. Analysis ServicesASSVCPASSWORD Specifies the password for the Analysis Services service.'
INSERT INTO @Data SELECT 27,'Analysis Services'			,'ASSVCSTARTUPTYPE','DefaultValue','Specifies the startup mode for the Analysis Services service. Supported values: •Automatic •Disabled •Manual'
INSERT INTO @Data SELECT 28,'Analysis Services'			,'ASSYSADMINACCOUNTS','DefaultValue','Specifies the administrator credentials for Analysis Services.'
INSERT INTO @Data SELECT 29,'Analysis Services'			,'ASTEMPDIR','DefaultValue','Specifies the directory for Analysis Services temporary files. Default values: •For WOW mode on 64-bit: %Program Files(x86)%\Microsoft SQL Server\<INSTANCEDIR>\<ASInstanceID>\OLAP\Temp. •For all other installations: %Program Files%\Microsoft SQL Server\<INSTANCEDIR>\<ASInstanceID>\OLAP\Temp.'
INSERT INTO @Data SELECT 30,'Analysis Services'			,'ASPROVIDERMSOLAP','DefaultValue','Specifies whether the MSOLAP provider can run in-process. Default value: •1=enabled'
INSERT INTO @Data SELECT 31,'SQL Server Browser'		,'BROWSERSVCSTARTUPTYPE','DefaultValue','Specifies the startup mode for SQL Server Browser service. Supported values: •Automatic •Disabled •Manual'
INSERT INTO @Data SELECT 32,'','','',''
INSERT INTO @Data SELECT 33,'SQL Server Database Engine'	,'ENABLERANU','DefaultValue','Enables run-as credentials for SQL Server Express installations.'
INSERT INTO @Data SELECT 34,'SQL Server Database Engine'	,'INSTALLSQLDATADIR','DefaultValue','Specifies the data directory for SQL Server data files. Default values: •For WOW mode on 64-bit:%Program Files(x86)%\Microsoft SQL Server\ •For all other installations:%Program Files%\Microsoft SQL Server\'
INSERT INTO @Data SELECT 35,'SQL Server Database Engine'	,'SAPWD','DefaultValue','Specifies the password for the SQL Server sa account. when SECURITYMODE=SQL'
INSERT INTO @Data SELECT 36,'SQL Server Database Engine'	,'SECURITYMODE','DefaultValue','Specifies the security mode for SQL Server. If this parameter is not supplied, then Windows-only authentication mode is supported. Supported value: •SQL'
INSERT INTO @Data SELECT 37,'SQL Server Database Engine'	,'SQLBACKUPDIR','DefaultValue','Specifies the directory for backup files. Default value: •<InstallSQLDataDir>\ <SQLInstanceID>\MSSQL\Backup'
INSERT INTO @Data SELECT 38,'SQL Server Database Engine'	,'SQLCOLLATION','DefaultValue','Specifies the collation settings for SQL Server. Default value: •SQL_Latin1_General_CP1_CS_AS'
INSERT INTO @Data SELECT 39,'SQL Server Database Engine'	,'SQLSVCACCOUNT','DefaultValue','Specifies the startup account for the SQL Server service.'
INSERT INTO @Data SELECT 40,'SQL Server Database Engine'	,'SQLSVCPASSWORD','DefaultValue','Specifies the password for SQLSVCACCOUNT.'
INSERT INTO @Data SELECT 41,'SQL Server Database Engine'	,'SQLSVCSTARTUPTYPE','DefaultValue','Specifies the startup mode for the SQL Server service. Supported values: •Automatic •Disabled •Manual'
INSERT INTO @Data SELECT 42,'SQL Server Database Engine'	,'SQLSYSADMINACCOUNTS','DefaultValue','Use this parameter to provision logins to be members of the sysadmin role. SQL Server Database EngineSQLTEMPDBDIRSpecifies the directory for the data files for tempdb. Default value: •<InstallSQLDataDir>\ <SQLInstanceID>\MSSQL\Data'
INSERT INTO @Data SELECT 43,'SQL Server Database Engine'	,'SQLTEMPDBLOGDIR','DefaultValue','Specifies the directory for the log files for tempdb. Default value: •<InstallSQLDataDir>\ <SQLInstanceID>\MSSQL\Data'
INSERT INTO @Data SELECT 44,'SQL Server Database Engine'	,'SQLUSERDBDIR','DefaultValue','Specifies the directory for the data files for user databases. Default value: •<InstallSQLDataDir>\ <SQLInstanceID>\MSSQL\Data'
INSERT INTO @Data SELECT 45,'SQL Server Database Engine'	,'SQLUSERDBLOGDIR','DefaultValue','Specifies the directory for the log files for user databases. Default value: •<InstallSQLDataDir>\ <SQLInstanceID>\MSSQL\Data'
INSERT INTO @Data SELECT 46,'SQL Server Database Engine'	,'USESYSDB','DefaultValue','Specifies the location of the SQL Server system databases to use for this installation. The path that is specified must not include the \Data suffix.'
INSERT INTO @Data SELECT 47,'FILESTREAM'			,'FILESTREAMLEVEL','DefaultValue','Specifies the access level for the FILESTREAM feature. Supported values: •0 =Disable FILESTREAM support for this instance. (Default value) •1=Enable FILESTREAM for Transact-SQL access. •2=Enable FILESTREAM for Transact-SQL and file IO streaming access. (Not valid for cluster scenarios) •3=Allow remote clients to have streaming access to FILESTREAM data.'
INSERT INTO @Data SELECT 48,'FILESTREAM'			,'FILESTREAMSHARENAME','DefaultValue','Specifies the name of the windows share in which the FILESTREAM data will be stored.'
INSERT INTO @Data SELECT 49,'SQL Server Full Text'		,'FTSVCACCOUNT','DefaultValue','Specifies the account for Full-Text filter launcher service. This parameter is ignored in Windows Server 2008 and Windows Vista operating systems. ServiceSID is used to help secure the communication between SQL Server and Full-text Filter Daemon. If the values are not provided, the Full-text Filter Launcher Service is disabled. You have to use SQL Server Control Manager to change the service account and enable full-text functionality. Default value: •Local Service Account'
INSERT INTO @Data SELECT 50,'SQL Server Full Text'		,'FTSVCPASSWORD','DefaultValue','Specifies the password for the Full-Text filter launcher service. This parameter is ignored in Windows Server 2008 and Windows Vista operating systems.'
INSERT INTO @Data SELECT 51,'Integration Services'		,'ISSVCACCOUNT','DefaultValue','Specifies the account for Integration Services. Default value: •NT AUTHORITY\NETWORK SERVICE'
INSERT INTO @Data SELECT 52,'Integration Services'		,'ISSVCPASSWORD','DefaultValue','Specifies the Integration Services password.'
INSERT INTO @Data SELECT 53,'Integration Services'		,'ISSVCStartupType','DefaultValue','Specifies the startup mode for the Integration Services service.'
INSERT INTO @Data SELECT 54,'','','',''
INSERT INTO @Data SELECT 55,'SQL Server Network Configuration'	,'NPENABLED','DefaultValue','Specifies the state of the Named Pipes protocol for the SQL Server service. Supported values: •0=disable the Named Pipes protocol  •1=enable the Named Pipes protocol'
INSERT INTO @Data SELECT 56,'SQL Server Network Configuration'	,'TCPENABLED','DefaultValue','Specifies the state of the TCP protocol for the SQL Server service.  Supported values: •0=disable the TCP protocol  •1=enable the TCP protocol'
INSERT INTO @Data SELECT 57,'Reporting Services'		,'RSINSTALLMODE','DefaultValue','Specifies the Install mode for Reporting Services.'
INSERT INTO @Data SELECT 58,'Reporting Services'		,'RSSVCACCOUNT','DefaultValue','Specifies the startup account for Reporting Services.'
INSERT INTO @Data SELECT 59,'Reporting Services'		,'RSSVCPASSWORD','DefaultValue','Specifies the password for the startup account for the Reporting Services service.'
INSERT INTO @Data SELECT 60,'Reporting Services'		,'RSSVCStartupType','DefaultValue','Specifies the startup mode for Reporting Services'     
--INSERT INTO @Data SELECT 01, 'INSTANCEID'		,'MSSQLSERVER','Specify the Instance ID for the SQL Server features you have specified. SQL Server directory structure, registry structure, and service names will reflect the instance ID of the SQL Server instance.'
--INSERT INTO @Data SELECT 02, 'ACTION'			,'Install','Specifies a Setup work flow, like INSTALL, UNINSTALL, or UPGRADE. This is a required parameter.'
--INSERT INTO @Data SELECT 03, 'FEATURES'			,'SQLENGINE,RS,BIDS,CONN,IS,BC,BOL,SSMS,ADV_SSMS,OCS','Specifies features to install, uninstall, or upgrade. The list of top-level features include SQL, AS, RS, IS, and Tools. The SQL feature will install the database engine, replication, and full-text. The Tools feature will install Management Tools, Books online, Business Intelligence Development Studio, and other shared components.'
--INSERT INTO @Data SELECT 04, 'X86'			,'False','Specifies that Setup should install into WOW64. This command line argument is not supported on an IA64 or a 32-bit system.'
--INSERT INTO @Data SELECT 05, 'HELP'			,'False','Displays the command line parameters usage'
--INSERT INTO @Data SELECT 06, 'INDICATEPROGRESS'		,'False','Specifies that the detailed Setup log should be piped to the console.'
--INSERT INTO @Data SELECT 07, 'QUIET'			,'False','Setup will not display any user interface.'
--INSERT INTO @Data SELECT 08, 'QUIETSIMPLE'		,'False','Setup will display progress only without any user interaction.'
--INSERT INTO @Data SELECT 09, 'MEDIASOURCE'		,'C:\Installs\Standard\','Specifies the path to the installation media folder where setup.exe is located.'
--INSERT INTO @Data SELECT 10, 'ERRORREPORTING'		,'False','Specify if errors can be reported to Microsoft to improve future SQL Server releases. Specify 1 or True to enable and 0 or False to disable this feature.'
--INSERT INTO @Data SELECT 11, 'INSTALLSHAREDDIR'		,'C:\Program Files\Microsoft SQL Server','Specify the root installation directory for native shared components.'
--INSERT INTO @Data SELECT 12, 'INSTALLSHAREDWOWDIR'	,'C:\Program Files (x86)\Microsoft SQL Server','Specify the root installation directory for the WOW64 shared components.'
--INSERT INTO @Data SELECT 13, 'INSTANCEDIR'		,'F:','Specify the installation directory.'
--INSERT INTO @Data SELECT 14, 'SQMREPORTING'		,'False','Specify that SQL Server feature usage data can be collected and sent to Microsoft. Specify 1 or True to enable and 0 or False to disable this feature.'
--INSERT INTO @Data SELECT 15, 'INSTANCENAME'		,'MSSQLSERVER','Specify a default or named instance. MSSQLSERVER is the default instance for non-Express editions and SQLExpress for Express editions. This parameter is required when installing the SQL Server Database Engine (SQL), Analysis Services (AS), or Reporting Services (RS).'
--INSERT INTO @Data SELECT 16, 'AGTSVCACCOUNT'		,'AMER\SQLAdminProd2008','Agent account name'
--INSERT INTO @Data SELECT 17, 'AGTSVCSTARTUPTYPE'	,'Automatic','Auto-start service after installation.'
--INSERT INTO @Data SELECT 18, 'ISSVCSTARTUPTYPE'		,'Automatic','Startup type for Integration Services.'
--INSERT INTO @Data SELECT 19, 'ISSVCACCOUNT'		,'AMER\SQLAdminProd2008','Account for Integration Services: Domain\User or system account.'
--INSERT INTO @Data SELECT 20, 'ASSVCSTARTUPTYPE'		,'Automatic','Controls the service startup type setting after the service has been created.'
--INSERT INTO @Data SELECT 21, 'ASCOLLATION'		,'Latin1_General_CI_AS','The collation to be used by Analysis Services.'
--INSERT INTO @Data SELECT 22, 'ASDATADIR'		,'Data','The location for the Analysis Services data files.'
--INSERT INTO @Data SELECT 23, 'ASLOGDIR'			,'Log','The location for the Analysis Services log files.'
--INSERT INTO @Data SELECT 24, 'ASBACKUPDIR'		,'Backup','The location for the Analysis Services backup files.'
--INSERT INTO @Data SELECT 25, 'ASTEMPDIR'		,'Temp','The location for the Analysis Services temporary files.'
--INSERT INTO @Data SELECT 26, 'ASCONFIGDIR'		,'Config','The location for the Analysis Services configuration files.'
--INSERT INTO @Data SELECT 27, 'ASPROVIDERMSOLAP'		,'1','Specifies whether or not the MSOLAP provider is allowed to run in process.'
--INSERT INTO @Data SELECT 28, 'SQLSVCSTARTUPTYPE'	,'Automatic','Startup type for the SQL Server service.'
--INSERT INTO @Data SELECT 29, 'FILESTREAMLEVEL'		,'0','Level to enable FILESTREAM feature at (0, 1, 2 or 3).'
--INSERT INTO @Data SELECT 30, 'ENABLERANU'		,'False','Set to 1 to enable RANU for SQL Server Express.'
--INSERT INTO @Data SELECT 31, 'SQLCOLLATION'		,'SQL_Latin1_General_CP1_CI_AS','Specifies a Windows collation or an SQL collation to use for the Database Engine.'
--INSERT INTO @Data SELECT 32, 'SQLSVCACCOUNT'		,'AMER\SQLAdminProd2008','Account for SQL Server service: Domain\User or system account.'
--INSERT INTO @Data SELECT 33, 'SQLSYSADMINACCOUNTS'	,'AMER\sledridge','Windows account(s) to provision as SQL Server system administrators.'
--INSERT INTO @Data SELECT 34, 'SECURITYMODE'		,'SQL','The default is Windows Authentication. Use SQL for Mixed Mode Authentication.'
--INSERT INTO @Data SELECT 35, 'INSTALLSQLDATADIR'	,'E:','The Database Engine root data directory.'
--INSERT INTO @Data SELECT 36, 'SQLBACKUPDIR'		,'F:\MSSQL10.MSSQLSERVER\MSSQL\Backup','Default directory for the Database Engine backup files.'
--INSERT INTO @Data SELECT 37, 'SQLUSERDBDIR'		,'F:\MSSQL10.MSSQLSERVER\MSSQL\Data','Default directory for the Database Engine user databases.'
--INSERT INTO @Data SELECT 38, 'SQLTEMPDBDIR'		,'E:\MSSQL10.MSSQLSERVER\MSSQL\Data','Directory for Database Engine TempDB files.'
--INSERT INTO @Data SELECT 39, 'ADDCURRENTUSERASSQLADMIN'	,'False','Provision current user as a Database Engine system administrator for SQL Server 2008 Express.'
--INSERT INTO @Data SELECT 40, 'TCPENABLED'		,'1','Specify 0 to disable or 1 to enable the TCP/IP protocol.'
--INSERT INTO @Data SELECT 41, 'NPENABLED'		,'0','Specify 0 to disable or 1 to enable the Named Pipes protocol.'
--INSERT INTO @Data SELECT 42, 'BROWSERSVCSTARTUPTYPE'	,'Disabled','Startup type for Browser Service.'
--INSERT INTO @Data SELECT 43, 'RSSVCACCOUNT'		,'AMER\SQLAdminProd2008','Specifies which account the report server NT service should execute under.  When omitted or when the value is empty string, the default built-in account for the current operating system. The username part of RSSVCACCOUNT is a maximum of 20 characters long and The domain part of RSSVCACCOUNT is a maximum of 254 characters long.'
--INSERT INTO @Data SELECT 44, 'RSSVCSTARTUPTYPE'		,'Automatic','Specifies how the startup mode of the report server NT service.  When Manual - Service startup is manual mode (default). Automatic - Service startup is automatic mode. Disabled - Service is disabled'
--INSERT INTO @Data SELECT 45, 'RSINSTALLMODE'		,'DefaultNativeMode','Specifies which mode report server is installed in. Default value: “FilesOnly”'

--SELECT '<table>'
--UNION ALL
--SELECT '	<tr>'
--UNION ALL
--SELECT	* 
--FROM	(
--	SELECT top 1000 '
--		<td>
--			<asp:Label ID="Label_'+[Parameter]+'" runat="server" Text="'+[Parameter]+'" ToolTip="'+[Description]+'"></asp:Label>
--		</td>
--		<td>
--			<asp:TextBox ID="TextBox_'+[Parameter]+'" runat="server" ToolTip="'+[Description]+'">'+[DefaultValue]+'</asp:TextBox>
--		</td>'+  
--		CASE WHEN ParamOrder % 2 = 0 THEN CHAR(13)+CHAR(10)+ '	</tr>'+CHAR(13)+CHAR(10)+ '	<tr>'
--		ELSE '' END
		
--		as parameter
		
--	FROM @Data
--	ORDER BY ParamOrder
--	) Data
--UNION ALL
--SELECT '	</tr>'
--UNION ALL
--SELECT '</table>'


SELECT '        + " /'+[Parameter]+'=" + TextBox_'+[Parameter]+'.Text.ToString()'
FROM @Data
ORDER BY ParamOrder
