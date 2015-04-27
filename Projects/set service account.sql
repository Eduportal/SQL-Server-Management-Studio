DECLARE @Msg				varchar(max)
		,@MsgCommand		varchar(8000)
		,@DynamicCode		varchar(8000)
		,@ScriptPath		varchar(max)
		,@ServiceActLogin	varchar(max) = 'AMER\SQLAdminProd2010'
		,@ServiceActPass	varchar(max) = 'S3wingm@ch7nE'
		,@ServiceExt		varchar(max) = ''
		,@Feature_NetSend	bit = 0
		,@NetSendRecip		varchar(max)
		,@DefaultBackupDir	varchar(max) = 'G:\Backup'
		,@instancename		varchar(max) = ''
		,@ServerName		sysname
		,@machinename		sysname
		
		
	SET @Msg =	'          Setting Properties and Variables';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg; 
	SELECT	@instancename		= isnull('\'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
			,@ServerName		= REPLACE(@@SERVERNAME,@instancename,'')
			,@machinename		= convert(nvarchar(100), serverproperty('machinename')) + @instancename
			,@ServiceExt		= isnull('$'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')


	BEGIN -- SET SECURITY POLICY VALUES FOR SERVICE ACCOUNT
		SET @Msg =	'                Setting Service Account Rights';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg; 
		SET @Msg =	'                  -- SeServiceLogonRight';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET		@DynamicCode = 'ntrights +r SeServiceLogonRight -u "'+@ServiceActLogin+'"'
		EXEC	XP_CMDSHELL @DynamicCode, no_output

		SET @Msg =	'                  -- SeLockMemoryPrivilege';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET		@DynamicCode = 'ntrights +r SeLockMemoryPrivilege -u "'+@ServiceActLogin+'"'
		EXEC	XP_CMDSHELL @DynamicCode, no_output

		SET @Msg =	'                  -- SeBatchLogonRight';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET		@DynamicCode = 'ntrights +r SeBatchLogonRight -u "'+@ServiceActLogin+'"'
		EXEC	XP_CMDSHELL @DynamicCode, no_output

		SET @Msg =	'                  -- SeTcbPrivilege';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET		@DynamicCode = 'ntrights +r SeTcbPrivilege -u "'+@ServiceActLogin+'"'
		EXEC	XP_CMDSHELL @DynamicCode, no_output

		SET @Msg =	'                  -- SeAssignPrimaryTokenPrivilege';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET		@DynamicCode = 'ntrights +r SeAssignPrimaryTokenPrivilege -u "'+@ServiceActLogin+'"'
		EXEC	XP_CMDSHELL @DynamicCode, no_output

		SET @Msg =	'                  -- SeTakeOwnershipPrivilege';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET		@DynamicCode = 'ntrights +r SeTakeOwnershipPrivilege -u "'+@ServiceActLogin+'"'
		EXEC	XP_CMDSHELL @DynamicCode, no_output

		SET @Msg =	'                  -- SeCreatePermanentPrivilege';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET		@DynamicCode = 'ntrights +r SeCreatePermanentPrivilege -u "'+@ServiceActLogin+'"'
		EXEC	XP_CMDSHELL @DynamicCode, no_output

		SET @Msg =	'                  -- SeInteractiveLogonRight';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET		@DynamicCode = 'ntrights +r SeInteractiveLogonRight -u "'+@ServiceActLogin+'"'
		EXEC	XP_CMDSHELL @DynamicCode, no_output

		SET @Msg =	'                  -- SeDebugPrivilege';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET		@DynamicCode = 'ntrights +r SeDebugPrivilege -u "'+@ServiceActLogin+'"'
		EXEC	XP_CMDSHELL @DynamicCode, no_output

		SET @Msg =	'                Apply SECEDIT Policy Template';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET		@DynamicCode = 'secedit /configure /db secedit.sdb /cfg %windir%\system32\SQLServiceAccounts.inf /quiet'
		EXEC	XP_CMDSHELL @DynamicCode, no_output	
		
		SET @Msg =	'                Update Group Security Policy';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET		@DynamicCode = 'gpupdate'
		EXEC	XP_CMDSHELL @DynamicCode, no_output	
	END
	
	BEGIN -- CONFIGURE SERVICE ACCOUNTS
		SET @Msg =	'              Setting Service Account Logins and Passwords';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET		@DynamicCode = 'strComputer = "."
		Set objWMIService = GetObject("winmgmts:" _
			& "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
		Set colServiceList = objWMIService.ExecQuery _
			("Select * from Win32_Service")
		For Each objservice in colServiceList
			If objService.name = "MSSQL'+isnull(nullif(@ServiceExt,''),'SERVER')+'" or objService.name = "'+CASE WHEN nullif(@ServiceExt,'') IS NULL THEN 'SQLSERVERAGENT' ELSE 'SQLAgent'+ISNULL(@ServiceExt,'') END+'" or objService.name = "SQLBrowser" or objService.name = "SQL Backup Agent' +ISNULL('-'+NULLIF(@instancename,''),'')+'" Then
			wscript.echo objservice.name
				errReturn = objService.Change( , , , , , ,"'+ISNULL(@ServiceActLogin,'XXX')+'", "'+ISNULL(@ServiceActPass,'YYY')+'")
			End If 
		Next'

		SET		@ScriptPath		= @DefaultBackupDir + '\SetSQLServiceAccount.vbs'
		EXEC	[dbo].[dbasp_FileAccess_Write] 
					@DynamicCode
					,@ScriptPath
		-- CHANGE SERVICE ACOUNT
		SET		@DynamicCode = 'cscript "'+ @ScriptPath +'"'
		EXEC	XP_CMDSHELL @DynamicCode, no_output
	END	
			
	BEGIN -- ADD MEMBERS TO LOCAL ADMIN GROUP
		SET @Msg =	'                Adding Accounts to Local Administrators Group';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET @Msg =	'                  -- "Amer\DevArchitects"';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET		@DynamicCode = 'net localgroup "Administrators" "Amer\DevArchitects" /add'
		EXEC	XP_CMDSHELL @DynamicCode, no_output	

		SET @Msg =	'                  -- "Amer\DevDBAs"';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET		@DynamicCode = 'net localgroup "Administrators" "Amer\DevDBAs" /add'
		EXEC	XP_CMDSHELL @DynamicCode, no_output	

		SET @Msg =	'                  -- "Amer\SeaDevelopers"';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET		@DynamicCode = 'net localgroup "Administrators" "Amer\SeaDevelopers" /add'
		EXEC	XP_CMDSHELL @DynamicCode, no_output	

		SET @Msg =	'                  -- "Amer\TestQALeads"';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET		@DynamicCode = 'net localgroup "Administrators" "Amer\TestQALeads" /add'
		EXEC	XP_CMDSHELL @DynamicCode, no_output	

		SET @Msg =	'                  -- "Amer\TestQualAssurance"';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET		@DynamicCode = 'net localgroup "Administrators" "Amer\TestQualAssurance" /add'
		EXEC	XP_CMDSHELL @DynamicCode, no_output	

		SET @Msg =	'                  -- "Amer\SeaSQLProdFull"';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET		@DynamicCode = 'net localgroup "Administrators" "Amer\SeaSQLProdFull" /add'
		EXEC	XP_CMDSHELL @DynamicCode, no_output	

		SET @Msg =	'                  -- "Amer\SeaSQLTestFull"';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET		@DynamicCode = 'net localgroup "Administrators" "Amer\SeaSQLTestFull" /add'
		EXEC	XP_CMDSHELL @DynamicCode, no_output	
	END	

	BEGIN -- CREATE LOGIN FOR THE SERVICE ACCOUNT
		IF NOT EXISTS (SELECT * FROM syslogins where name = @ServiceActLogin)
		BEGIN
			SET @Msg =	'              Create Login for The Service Account';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
			SET	@DynamicCode	= 'CREATE LOGIN ['+@ServiceActLogin+'] FROM WINDOWS WITH DEFAULT_DATABASE=[master]'
			EXEC (@DynamicCode)
		END
	END

	BEGIN -- ADD THE SERVICE ACCOUNT TO SYSADMIN ROLE
		SET @Msg =	'              Add The Service Account to sysadmin Role';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET	@DynamicCode	= 'EXEC master..sp_addsrvrolemember @loginame = N'''+@ServiceActLogin+''', @rolename = N''sysadmin'''
		EXEC (@DynamicCode)
	END
	
	BEGIN -- CREATE LOGIN FOR LOCAL ADMINISTRATOR GROUP
		IF NOT EXISTS (SELECT * FROM syslogins where name = REPLACE(@MachineName,@InstanceName,'')+'\Administrator')
		BEGIN
			SET @Msg =	'              Create Login for Local Administrator Group';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
			SET	@DynamicCode	= 'CREATE LOGIN ['+REPLACE(@MachineName,@InstanceName,'')+'\Administrator] FROM WINDOWS WITH DEFAULT_DATABASE=[master]'
			EXEC (@DynamicCode)
		END
	END
	
	BEGIN -- ADD LOCAL ADMINISTRATOR GROUP TO SYSADMIN ROLE
		SET @Msg =	'              Add Local Administrator Group to sysadmin Role';IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;
		SET	@DynamicCode	= 'EXEC master..sp_addsrvrolemember @loginame = N'''+REPLACE(@MachineName,@InstanceName,'')+'\Administrator'', @rolename = N''sysadmin'''
		EXEC (@DynamicCode)
	END