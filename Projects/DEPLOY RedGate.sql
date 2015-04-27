
USE [master]
GO
SET NOCOUNT ON

if exists (SELECT * FROM sys.sysconfigures WHERE comment = 'show advanced options' AND value != 1)
	EXEC sp_configure 'show advanced options', 1
	
if exists (SELECT * FROM sys.sysconfigures WHERE comment = 'Enable or disable command shell' AND value != 1)
	EXEC sp_configure 'xp_cmdshell', 1
	
if exists (SELECT * FROM sys.sysconfigures WHERE comment = 'Enable or disable Ole Automation Procedures' AND value != 1)
	EXEC sp_configure 'Ole Automation Procedures', 1

IF EXISTS (SELECT * FROM sys.configurations WHERE value != value_in_use)
	RECONFIGURE WITH OVERRIDE

	DECLARE 
			@RedgateInstalled		Int				,@RedgateTested			Bit				,@ServerString2			SysName			,@ServerName			SysName			
			,@EnvNum				SysName			,@ServiceActLogin		SysName			,@ServiceActPass		SysName			,@InstanceName			SysName
			,@RedgateConfigured		Bit				,@DynamicCode			VarChar(8000)	,@SqlIsClustered		NVarChar(1)		,@OldDllVersion			VarChar(20)		
			,@OldExeVersion			VarChar(20)		,@OldLicenseVersionId	VarChar(1)		,@OldLicenseVersionText VarChar(20)		,@NewDllVersion			VarChar(20)		
			,@NewExeVersion			VarChar(20)		,@NewLicenseVersionId	VarChar(1)		,@NewLicenseVersionText VarChar(20)		,@SerialNumber			VarChar(30)		
			,@SqbFileExistsExec		VarChar(1024)	,@SqbExistsResult		Int				,@SqbTestFileCreateExec VarChar(1024)	,@SqbTestFileExistsResult Int		
			,@SqbTestFileExistsExec VarChar(1024)	,@SqbExecutionResultText VarChar(512)	,@RedGateNetworkPath	VarChar(260)	,@SqbTestFileDeleteExec VarChar(1024)	
			,@SqbSetupExec			VarChar(1024)	,@TypeExitCodeFileExec	VarChar(1024)	,@DelExitCodeFileExec	VarChar(1024)	,@SqbExecutionResult	Int
			,@SqbInstallRetry		Bit				,@RedGateKey			VarChar(50)		,@MachineName			SysName			,@ReCheck				Bit				
			,@ScriptPath			VarChar(8000)	,@ExecRetryCount		Int
			,@TargetVersion			VarChar(20)
			,@TargetLicence			VarChar(20)

SELECT		@RedGateNetworkPath		= '\\seafresqldba01\DBA_Docs\utilities\RedGate_SQLbackup\Red_Gate_6.4\AutomatedInstall'				
			,@RedGateKey			= '010-110-127441-4B91'
			,@TargetVersion			= '6.4.0.56'
			,@TargetLicence			= 'Professional'
			,@ReCheck				= 0
			,@ExecRetryCount		= 10		
			,@SqbExecutionResult	= -1		
			,@SqbInstallRetry		= 1		
			,@OldDllVersion			= 'Not Installed'
			,@OldExeVersion			= 'Not Installed'
			,@OldLicenseVersionId	= '-1'
			,@OldLicenseVersionText	= 'Unknown'
			,@SerialNumber			= 'Unknown'
			,@InstanceName			= isnull('\'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
			,@ServerName			= @@SERVERNAME
			,@MachineName			= convert(nVarChar(100), serverproperty('machinename')) 
			,@SqlIsClustered		= CAST(SERVERPROPERTY('IsClustered') AS VarChar(1))
			
					
	IF OBJECT_ID('tempdb..#EnvLogins')		IS NOT NULL	DROP TABLE #EnvLogins		
	IF OBJECT_ID('tempdb..#ExecOutput')		IS NOT NULL	DROP TABLE #ExecOutput
	IF OBJECT_ID('tempdb..#File_Exists')	IS NOT NULL	DROP TABLE #File_Exists
	IF OBJECT_ID('tempdb..#RGBTest')		IS NOT NULL	DROP TABLE #RGBTest

	CREATE	TABLE	#EnvLogins			(EnvNum SysName, ServiceActLogin SysName, ServiceActPass SysName)
	CREATE	TABLE	#ExecOutput			([rownum] Int identity primary key,[TextOutput] VarChar(8000))
	CREATE	TABLE	#File_Exists		(isFile Bit, isDir Bit, hasParentDir Bit)
	CREATE	TABLE	#RGBTest			([database] SysName,[login] SysName,processed Int,level1_size Int,level2_size Int,level3_size Int,level4_size Int)

	INSERT IntO #EnvLogins
	SELECT	'alpha'			,'AMER\SQLAdminAlpha'		,'v&5enewU@'		UNION ALL
	SELECT	'beta'			,'AMER\SQLAdminBeta'		,'#r3&=azuB'		UNION ALL
	SELECT	'candidate'		,'AMER\SQLAdminCandidate'	,'kE@uFr89A'		UNION ALL
	SELECT	'dev'			,'AMER\SQLAdminDev'			,'squ33zepl@y'		UNION ALL
	SELECT	'load'			,'AMER\SQLAdminLoad'		,'squ33zepl@y'		UNION ALL
	SELECT	'stage'			,'AMER\SQLAdminStage2010'	,'Hyp0d@syr8ngE'	UNION ALL
	SELECT	'test'			,'AMER\SQLAdmIntest'		,'squ33zepl@y'		UNION ALL
	SELECT	'production'	,'AMER\SQLAdminProd2010'	,'S3wingm@ch7nE'

	SELECT	@EnvNum				=	env_detail  
	From	dbaadmin.dbo.Local_ServerEnviro 
	WHERE	env_type = 'ENVname'
	
	SELECT	@ServiceActLogin	=	ServiceActLogin	
			,@ServiceActPass	=	ServiceActPass
	FROM	#EnvLogins
	WHERE	EnvNum = @EnvNum	

	--RESET VARIABLES
	
CheckRedgate:
	IF @ReCheck = 0
		PRINT ' -- Start Checking...'
	Else
		PRINT ' -- Start Re-Checking...'
		
		SELECT		@RedgateInstalled		= 0
					,@RedgateConfigured		= 0
					,@RedgateTested			= 0
						
					
	-- CHECK FOR REDGATE

		
		PRINT '  -- Checking Installed...'
		IF @RedgateInstalled = 0
			exec master.dbo.xp_fileexist @filename = 'C:\Program Files (x86)\Red Gate\SQL Backup 6\SQBServerSetup.exe',@file_exists = @RedgateInstalled OUT

		IF @RedgateInstalled = 0
			exec master.dbo.xp_fileexist @filename = 'C:\Program Files\Red Gate\SQL Backup 6\SQBServerSetup.exe',@file_exists = @RedgateInstalled OUT
	
		PRINT '  -- Checking Configured...'
		IF OBJECT_ID('master.dbo.sqbutility') IS NOT NULL
			SET @RedgateConfigured = 1

		PRINT '  -- Checking Tested...'
		TRUNCATE TABLE #RGBTest
		If OBJECT_ID('master.dbo.sqbtest') IS NOT NULL
		BEGIN	
			INSERT IntO #RGBTest
			exec master.dbo.sqbtest 'dbaadmin'

			If Exists (Select * From #RGBTest where [database] = 'dbaadmin')
				SET @RedgateTested = 1
		END

		-- GET REDGATE INFORMATION
			-- If the SQL Backup components are already installed, attempt to get the current version details.
			IF OBJECT_ID('master..sqbutility') IS NOT NULL
			  BEGIN
				PRINT '   -- Getting Version Numbers...'
				-- A version has been installed, we need to find out which (we use #ExecOutput to get rid of the blank result sets)
				TRUNCATE TABLE #ExecOutput -- Clean the temporary table
				INSERT #ExecOutput(TextOutput) EXECUTE master..sqbutility 30,	@NewDllVersion OUTPUT
				INSERT #ExecOutput(TextOutput) EXECUTE master..sqbutility 1030,	@NewExeVersion OUTPUT
				INSERT #ExecOutput(TextOutput) EXECUTE master..sqbutility 1021,	@NewLicenseVersionId OUTPUT, NULL, @SerialNumber OUTPUT

				-- Convert the License Edition Into Text
				SELECT @NewLicenseVersionText = CASE @NewLicenseVersionId 
													WHEN '0' THEN 'Trial: Expired'
													WHEN '1' THEN 'Trial'
													WHEN '2' THEN 'Standard'
													WHEN '3' THEN 'Professional'
													WHEN '6' THEN 'Lite'
													ELSE 'Unknown'
													END
				IF @ReCheck = 0													
					SELECT			@OldDllVersion			= @NewDllVersion
									,@OldExeVersion			= @NewExeVersion
									,@OldLicenseVersionId	= @NewLicenseVersionId
									,@OldLicenseVersionText	= @NewLicenseVersionText
			
		END
		
	IF @ReCheck = 1 Goto AfterRecheck
	IF @OldDllVersion = @TargetVersion AND @OldExeVersion = @TargetVersion AND @OldLicenseVersionText = @TargetLicence
	BEGIN
		PRINT '    -- Versions Are Current, Skipping Install...'
		Goto AfterRecheck
	END

	SELECT	@NewDllVersion			= 'Not Installed'
			,@NewExeVersion			= 'Not Installed'
			,@NewLicenseVersionId	= '-1'					
			,@NewLicenseVersionText	= 'Unknown'
							

	-- STOP SERVICE IF IT IS RUNNING
	IF @OldDllVersion != 'Not Installed'
	BEGIN
		PRINT '    -- Stoping Service...'
		SET		@DynamicCode = 'NET STOP "SQL Backup Agent-'+ REPLACE(@InstanceName,'\','') +'"'
		exec xp_cmdshell @DynamicCode, no_output
	END

	-- COPY REDGATE TOOLS AND INSTALLER
		PRINT '    -- Verifing Network Install Files...'
        -- Check that the file exists (returning "1" if valid), if it doesn't, we cannot do the installation
        SET @DynamicCode =  @RedGateNetworkPath + '\SqbServerSetup.exe'
        exec master.dbo.xp_fileexist @filename = @DynamicCode,@file_exists = @SqbExistsResult OUT

		IF @SqbExistsResult IS NOT NULL
		BEGIN
			-- CREATE DIRECTORY
			PRINT '     -- Creating Directory...'
			SET @DynamicCode = 'MD "C:\Program Files (x86)\Red Gate\SQL Backup 6\"'
			EXEC	XP_CMDSHELL @DynamicCode, no_output

			-- DELETE EXISTING
			PRINT '     -- Deleting Existing Files...'
			SET @DynamicCode = 'DEL "C:\Program Files (x86)\Red Gate\SQL Backup 6\*.*" /S'
			EXEC	XP_CMDSHELL @DynamicCode, no_output
			
			-- COPY FILES
			PRINT '     -- Copying Files...'
			SET @DynamicCode = 'XCOPY "' + @RedGateNetworkPath + '\*.*" "C:\Program Files (x86)\Red Gate\SQL Backup 6\" /Q /C /Y /E'
			EXEC	XP_CMDSHELL @DynamicCode, no_output
			
			--CREATE SHORTCUTS
			PRINT '     -- Creating Shortcuts...'
			SET @DynamicCode = 'Move /Y "C:\Program Files (x86)\Red Gate\SQL Backup 6\Red Gate" "C:\Documents and Settings\All Users\Start Menu\Programs\Red Gate"'
			EXEC	XP_CMDSHELL @DynamicCode, no_output

			PRINT	'-- Redgate Files were coppied'
		END
		ELSE
		BEGIN
			PRINT	'-- Redgate Files were not found'
		END
		
		SET @SqbExistsResult = NULL

	-- INSTALL REDGATE BACKUP
		PRINT '      -- Starting Install...'
        -- Check that the file exists (returning "1" if valid), if it doesn't, we cannot do the installation
        PRINT '       -- Checking Install File...'
        exec master.dbo.xp_fileexist @filename = 'C:\Program Files (x86)\Red Gate\SQL Backup 6\SqbServerSetup.exe',@file_exists = @SqbExistsResult OUT

		-- Check that we can create files in the directory (for exitcodefile), if we can't then no poInt doing the installation
		PRINT '       -- Checking file Creation...'
        SET @SqbTestFileCreateExec = 'echo 1 > "C:\Program Files (x86)\Red Gate\SQL Backup 6\exitcodetest.txt"'
        SET @SqbTestFileExistsExec = 'if exist "C:\Program Files (x86)\Red Gate\SQL Backup 6\exitcodetest.txt" echo 1'
        SET @SqbTestFileDeleteExec = 'del "C:\Program Files (x86)\Red Gate\SQL Backup 6\exitcodetest.txt"'

		EXECUTE master..xp_cmdshell @SqbTestFileCreateExec, no_output
		exec master.dbo.xp_fileexist @filename = 'C:\Program Files (x86)\Red Gate\SQL Backup 6\exitcodetest.txt',@file_exists = @SqbTestFileExistsResult OUT
        EXECUTE master..xp_cmdshell @SqbTestFileDeleteExec, no_output

		IF @SqbExistsResult = 1 AND @SqbTestFileExistsResult = 1
		BEGIN
		PRINT '        -- Installing...'
            -- Generate the command strings for 'reading' and deleting the exitcode file, with instance-specific naming
            SET @TypeExitCodeFileExec = 'type "C:\Program Files (x86)\Red Gate\SQL Backup 6\exitcode_' + REPLACE(@ServerName,'\','_') + '.txt"'
            SET @DelExitCodeFileExec = 'del "C:\Program Files (x86)\Red Gate\SQL Backup 6\exitcode_' + REPLACE(@ServerName,'\','_') + '.txt"'

            -- Generate the command to execute the installation, including any applicable credentials and instance details
            SET @SqbSetupExec = '"C:\Program Files (x86)\Red Gate\SQL Backup 6\SqbServerSetup.exe" /VERYSILENT /SUPPRESSMSGBOXES '
				+ '/LOG /EXITCODEFILE exitcode_' + REPLACE(@ServerName,'\','_')+ '.txt' + ' /SVCUSER ' + @ServiceActLogin + ' /SVCPW ' + @ServiceActPass
				+ CASE WHEN nullif(@InstanceName,'') IS NOT NULL THEN ' /I ' + REPLACE(@InstanceName,'\','') ELSE '' END

            WHILE @ExecRetryCount > 0 AND @SqbInstallRetry = 1
              BEGIN
                -- Perform the execution and get the exit code
                EXECUTE master..xp_cmdshell @SqbSetupExec, no_output
                
                -- Get and Parse the output
                PRINT '        -- Checking Install Results...'
                INSERT #ExecOutput(TextOutput) EXECUTE master..xp_cmdshell @TypeExitCodeFileExec
                SELECT @SqbExecutionResult = CAST(TextOutput AS Int) FROM #ExecOutput 

                -- If the exit code is 5, we want to retry in a few seconds
                IF @SqbExecutionResult = 5
                  BEGIN
                    SET @ExecRetryCount = @ExecRetryCount - 1
                    WAITFOR DELAY '00:00:10' -- Wait for 10 seconds and try again
                  END
                ELSE 
                  SET @SqbInstallRetry = 0 -- Set retry flag to 0
              END

            -- Clean up and delete the temporary exit code file
            PRINT '       -- Cleaning Up...'
            INSERT #ExecOutput(TextOutput) EXECUTE master..xp_cmdshell @DelExitCodeFileExec

            -- Parse the output code, and generate the necessary text
            PRINT '       -- Evaluating Results...'
            IF @SqbExecutionResult = 0
            BEGIN
				SET @SqbExecutionResultText = 'Successful (0).'
            END
            ELSE 
              BEGIN
                IF @SqbExecutionResult < 8192
                  SELECT @SqbExecutionResultText = 
                    CASE WHEN @SqbExecutionResult = 5 
                           THEN 'Unsuccessful: Another Installation is currently running, try again later (5).'
                         WHEN @SqbExecutionResult = 6000
                           THEN 'Unsuccessful: Current user has insufficient permissions to modify Windows Services (6000).'
                         WHEN @SqbExecutionResult = 6010
                           THEN 'Unsuccessful: Windows 2003 Itanium Edition requires SP1 to be installed first (6010).'
                         WHEN @SqbExecutionResult = 6020
                           THEN 'Unsuccessful: Service account username could not be validated (6020).'
                         WHEN @SqbExecutionResult = 6030
                           THEN 'Unsuccessful: Service account username was ambiguous, fully qualify it (6030).'
                         WHEN @SqbExecutionResult = 6040
                           THEN 'Unsuccessful: Service account password is invalid (6040).'
                         WHEN @SqbExecutionResult = 6100
                           THEN 'Unsuccessful: Current user is denied "Log On As A Service" rights (6100).'
                         WHEN @SqbExecutionResult = 6110
                           THEN 'Unsuccessful: Unable to grant "Log On As A Service" rights (6110).'
                         WHEN @SqbExecutionResult = 6200
                           THEN 'Unsuccessful: SQL Authenticated Username or Password is incorrect (6200).'
                         WHEN @SqbExecutionResult = 6210
                           THEN 'Unsuccessful: SQL Authenticated Account is not a member of the sysadmin role (6210).'
                         ELSE 'Unsuccessful: Check installation log for further information (' + CAST(@SqbExecutionResult AS VarChar(8)) + ').'
                  END
                ELSE
                  BEGIN
                    -- Installation was 'successful', but a post-installation check failed
                    SET @SqbExecutionResultText = 'The following post-installation checks failed: '

                    IF @SqbExecutionResult % 524288 / 262144 = 1 
                      SET @SqbExecutionResultText = @SqbExecutionResultText + 'The version of xp_sqlbackup.dll is incorrect (262144) '

                    IF @SqbExecutionResult % 262144 / 131072 = 1 
                      SET @SqbExecutionResultText = @SqbExecutionResultText + 'The file xp_sqlbackup.dll was not installed correctly (131072) '

                    IF @SqbExecutionResult % 131072 / 65536 = 1 
                      SET @SqbExecutionResultText = @SqbExecutionResultText + 'The SQL Backup Agent service was unable to start within 1 minute (65536) '

                    IF @SqbExecutionResult % 65536 / 32768 = 1 
                      SET @SqbExecutionResultText = @SqbExecutionResultText + 'The SQL Backup Agent service could not be registered correctly (32768) '    

                    IF @SqbExecutionResult % 32768 / 16384 = 1 
                      SET @SqbExecutionResultText = @SqbExecutionResultText + 'The version of the SQL Backup Agent service is incorrect (16384) '    

                    IF @SqbExecutionResult % 16384 / 8192 = 1 
                      SET @SqbExecutionResultText = @SqbExecutionResultText + 'The SQL Backup Agent service executable was not installed (8192) '    
                  END
              END
		END
        ELSE
          BEGIN
            -- Installer file does not exist, so return generic message
            SET @SqbExecutionResult = -1
            SET @SqbExecutionResultText = 'Unsuccessful: The file could not be found (-1).'
          END

	SET @ReCheck = 1
	GOTO CheckRedgate
	AfterRecheck:       

	-- SET SERVICE ACCOUNT ON Redgate Backup Service
	PRINT '     -- Starting Service Account Setup...'
	SELECT	@DynamicCode = 'strComputer = "."
	Set objWMIService = GetObject("winmgmts:" _
		& "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
	Set colServiceList = objWMIService.ExecQuery _
		("Select * from Win32_Service")
	For Each objservice in colServiceList
		If objService.name = "SQL Backup Agent-'+@InstanceName+'" Then
		wscript.echo objservice.name
			errReturn = objService.Change( , , , , , ,"'+@ServiceActLogin+'", "'+@ServiceActPass+'")
		End If 
	Next'
	,@ScriptPath = 'C:\Program Files (x86)\Red Gate\SQL Backup 6\SetServiceAccount_' + REPLACE(@ServerName,'\','_') + '.vbs'

	-- WRITE SCRIPT FILE
	PRINT '        -- Writing Script...'
	EXEC	dbaadmin.[dbo].[dbasp_FileAccess_Write] 
				@DynamicCode
				,@ScriptPath
				
	-- RUN SCRIPT FILE
	PRINT '        -- Running Script...'
	SET		@DynamicCode = 'cscript "'+ @ScriptPath +'"'
	EXEC	XP_CMDSHELL @DynamicCode, no_output

	-- STOP SERVICE
	PRINT '         -- Stoping Service...'
	SET		@DynamicCode = 'NET STOP "SQL Backup Agent-'+ REPLACE(@InstanceName,'\','') +'"'
	exec xp_cmdshell @DynamicCode, no_output

	-- START SERVICE
	PRINT '         -- Starting Service...'
	SET		@DynamicCode = 'NET START "SQL Backup Agent-'+ REPLACE(@InstanceName,'\','') +'"'
	exec xp_cmdshell @DynamicCode, no_output


	PRINT '      -- Done...'
	
	SELECT		@RedgateInstalled			[RedGate Installed]	
				,@RedgateConfigured			[RedGate Configured]
				,@RedgateTested				[RedGate Tested]
				,@OldDllVersion				[RedGate PreviousDllVersion]
				,@OldExeVersion				[RedGate PreviousExeVersion]
				,@OldLicenseVersionId		[RedGate PreviousLicenseId]
				,@OldLicenseVersionText		[RedGate PreviousLicenseText]
				,@NewDllVersion				[RedGate CurrentDllVersion]	
				,@NewExeVersion				[RedGate CurrentExeVersion]
				,@NewLicenseVersionId		[RedGate CurrentLicenseId]
				,@NewLicenseVersionText		[RedGate CurrentLicenseText]
				,@SerialNumber				[RedGate SerialNumber]		
				,@SqbExecutionResultText	[RedGate InstallStatus]




