


SELECT	 REPLACE(REPLACE('http://www.google.com/search?q=Event+ID+{EventID}+{SourceName}','{EventID}',CAST([EventID] AS VarChar(50))),'{SourceName}',REPLACE([SourceName],' ','+')) AS GoogleSearch
	,REPLACE(REPLACE('http://www.eventid.net/display.asp?eventid={EventID}&source={SourceName}&phase=1','{EventID}',CAST([EventID] AS VarChar(50))),'{SourceName}',REPLACE([SourceName],' ','+')) AS EventIDSearch
	,[EventID],[Strings],[Message],[Data],[SourceName],[EventType]
	,[EventTypeName]
	,[EventCategory]
	,[EventCategoryName]
FROM [dbaadmin].[dbo].[FilescanImport_CurrentWorkTable_ServerEvent]
WHERE	(SourceName Like '%SQL%' OR EventType IN (1,16))
 AND	EventID NOT IN	(
			0	-- Generic Error 
			,3	-- Admin Connection is not Valid
			,8	-- Windows Update Failures
			,10	-- WinMgmt
			,107	-- LDAP Failure
			,208	-- Agent Job Failure
			,265	-- No Valid License
			,267	-- Connection to repository failed
			,318	-- Unable to read local eventlog
			,333	-- Registry I/O Failure 
			,439	-- SUS20ClientDataStore
			,529	-- Login Failed
			,531	-- Login Failed
			,537	-- Login Failed
			,560	-- Security Failure Audit
			,577	-- (ignore) Privilaged Use Audit
			,680	-- Login Failed
			,861	-- (ignore) Firewall detected listening Red Gate
			,1000	-- Generic Application Error. posibly http://www-01.ibm.com/support/docview.wss?uid=swg21200995
			,1001	-- Security policy cannot be propagated, Error code = 112
			,1005	-- (ignore) Perflib Error http://www.eventid.net/display.asp?eventid=1005&eventno=3553&source=Perflib&phase=1
			,1006	-- Group Policy - Invalid Credentials http://www.eventid.net/display.asp?eventid=1006&eventno=2187&source=Userenv&phase=1
			,1008	-- (ignore) Perflib Error http://www.eventid.net/display.asp?eventid=1008&eventno=70&source=Perflib&phase=1
			,1010	-- (ignore) Perflib Error http://www.eventid.net/display.asp?eventid=1010&eventno=853&source=Perflib&phase=1
			,1017	-- (ignore) Perflib Error http://asitech.wordpress.com/2007/08/02/perflib-errors-with-event-id-1017/
			,1021	-- (ignore) Perflib Error http://publib.boulder.ibm.com/infocenter/director/v5r2/index.jsp?topic=/diricinfo_5.20/fqm0_r_tbs_97800_extraneous_perflib_errors.html
			,1023	-- Instalation Failed http://www.eventid.net/display.asp?eventid=1023&eventno=5651&source=MsiInstaller&phase=1
			,1024	-- (ignore) DELL OMSA 5.x Logs Critical Error ID 1024 in Windows® Event Log
			,1030	-- Group Policy - Can Not Query http://www.eventid.net/display.asp?eventid=1030&eventno=1542&source=Userenv&phase=1
			,1053	-- Access is denied. 
			,2001	-- (ignore) Perflib Error http://support.microsoft.com/kb/811089
			,3024	-- Windows Update Failed http://www.eventid.net/display.asp?eventid=3024&source=Windows+Search+Service&phase=1
			,4099	-- Tivoli Storage Manager. Add the following syntax in your TSM config file (dsm.opt): exclude.dir "c:\Program Files\BigFix Enterprise\BES Client\__BESData" 
			,4373	-- Service Pack installation failed. Access is denied. http://www.eventid.net/display.asp?eventid=4373&source=NtServicePack&phase=1 
			,5004	-- McAfee Installation Corrupt. Uninstall, Use Microsoft Cleanup Utility, Reinstall. 
			,5031	-- Windows Firewall Blocked Application
			,5152	-- Windows Filtering Platform Blocked Packet
			,5157	-- Windows Filtering Platform Blocked Packet
			,5159	-- Windows Filtering Platform blocked bind to local port
			,7011	-- Service Timeout http://www.eventid.net/display.asp?eventid=7011&eventno=110&source=Service%20Control%20Manager&phase=1
			,7024	-- Tivoli Storage Manager. The TSM Cluster Scheduler service terminated with service-specific error 12 (0xC). http://www-01.ibm.com/support/docview.wss?rs=663&uid=swg21243061
			,7034	-- SQLdm Management Service terminated unexpectedly
			,7886	-- SQL Read Failure http://www.eventid.net/display.asp?eventid=7886&eventno=9925&source=MSSQLSERVER&phase=1
			,8193	-- Volume Shadow Copy Service error http://www.eventid.net/display.asp?eventid=8193&source=VSS&phase=1
			,9100	-- MOM Failure http://www.eventid.net/display.asp?eventid=9100&source=Microsoft+Operations+Manager&phase=1
			,10005	-- Instalation Failed
			,10016	-- DCOM Failure http://www.eventid.net/display.asp?eventid=10016&source=DCOM&phase=1
			,11920	-- Service Failed To Start http://www.eventid.net/display.asp?eventid=11920&source=MsiInstaller&phase=1
			,11922	-- Product: Idera SQL diagnostic manager (x64) 
			,12291	-- Package Failure
			,17061	-- 67015|16|1|ProductCatalog Asset Warning
			,17207	-- (ignore) File Failure. Caused By Restoring NXT Database that is missing Log File.
			,17806	-- SSPI handshake failed			
			,18456	-- Login Failed
			,18452	-- Login Failed
			,25267	-- MOM Failure
			,26009	-- MOM Failure http://www.eventid.net/display.asp?eventid=26009&source=Microsoft+Operations+Manager&phase=1
			)
--AND	COALESCE([Strings],'')+COALESCE([Message],'')+COALESCE([Data],'') Like '%SQL%'			 
ORDER BY EventID


