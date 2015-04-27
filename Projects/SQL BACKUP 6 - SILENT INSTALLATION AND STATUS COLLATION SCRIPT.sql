---------------------------------------------------------------------------------------------------------------------
-- SQL BACKUP 6 - SILENT INSTALLATION AND STATUS COLLATION SCRIPT                                                  --
-- For SQL Server 2000, 2005 and 2008                                                                              --       
--                                                                                                                 --
-- (c) Red Gate Software Ltd, 2009                                                                                 --
-- Copyright (c) 2009, Red Gate Software Limited.																   --
-- All rights reserved.																							   --
-- Redistribution and use in source and binary forms, with or without modification, are permitted provided that    --
-- the following conditions are met:																			   --
-- Redistributions of source code must retain the above copyright notice, this list of conditions and the		   --
-- following disclaimer.																				           --
-- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the	   --
-- following disclaimer in the documentation and/or other materials provided with the distribution.		           --
-- Neither the name of Red Gate Software Limited nor the names of its contributors may be used to endorse or	   --
-- promote products derived from this software without specific prior written permission.					       --
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED		   --
-- WARRANTIES,INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A		   --
-- PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY	   --
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,	   --
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER   --
-- CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE     --
-- OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF		   --
-- SUCH DAMAGE.																									   --

---------------------------------------------------------------------------------------------------------------------
--                                                                                                                 --
--   The following script can be used, in conjunction with SQL Multi Script, to install the SQL Backup 6 Server    --
-- components automatically onto multiple local and remote machines.  The script will also collate the before and  --
-- after status, reporting any installation failures that may have occurred.                                       --
--                                                                                                                 --
--   To perform the installation, complete the following steps:                                                    --
--                                                                                                                 --
-- 1) Open this script in SQL Multi Script.                                                                        --
--                                                                                                                 --
-- 2) Copy the SQBServerSetup.exe file to a central location, in a folder that the user executing the script has   --
--    full read-write access to.  If the user does not have read-write access, the installation status information --
--    will be unavailable.                                                                                         --                          
--                                                                                                                 --
--    Enter this information below:                                                                                --

DECLARE @DownloadDirectory VARCHAR(260); 
SET @DownloadDirectory = '\\seafresqldba01\DBA_Docs\utilities\RedGate_SQLbackup\Red_Gate_6.4';

--                                                                                                                 --
-- 3) If you wish to supply credentials for the SQL Backup Agent, enter these below:                               --
--                                                                                                                 --
--    a) Service Application Startup Account.  If you want to run the service as the LocalSystem account, leave    --
--       the values as 'NULL', otherwise if you want to run the service as a named account, enter the username and --
--       password below:                                                                                           --                          
--                                                                                                                 --

DECLARE @ServiceUsername VARCHAR(128);
DECLARE @ServicePassword VARCHAR(128);
SET @ServiceUsername = 'AMER\SQLAdminDev';  -- SET @ServiceUsername = 'username@domain.com';
SET @ServicePassword = 'squ33zepl@y';  -- SET @ServicePassword = 'myp@ssw0rd';

--                                                                                                                 --
--    b) The SQL Server Authentication Mode.  If you want the Service to use the current Windows Authentication to --
--       connect, leave the values as 'NULL', otherwise if you want to use a specific SQL Authentication enter the --
--       username and password below:                                                                              --
--                                                                                                                 --

DECLARE @SqlUsername VARCHAR(128);
DECLARE @SqlPassword VARCHAR(128);
SET @SqlUsername = NULL; -- SET @SqlUsername = 'sa';
SET @SqlPassword = NULL; -- SET @SqlPassword = 'p@ssw0rd';

--                                                                                                                 --
-- 4) Set the @PerformInstallation flag to 1 to perform the actual installation.  If this is set to 0, the script  --
--    will return versioning and licensing information, but not attempt the install.                               --
--                                                                                                                 --

DECLARE @PerformInstallation BIT ;
SET @PerformInstallation = 0 ;

--                                                                                                                 --
-- 5) In SQL Multi Script, using the "Database Distribution List", add the relevant servers you wish to install    --
--    SQL Backup on.  When prompted for a database, select the 'tempdb' database.                                  --
--                                                                                                                 --
-- 6) Execute the script.  The 'Results' pane will display the outcome of the installations.  If you have any      --
--    issues with the installation, the installation log file should be available in your temporary files		   --
--    directory.  In Windows XP this is found in (where <user> is the account name of the user executing the       --    
--    script):                                                                                                     --
--      C:\Documents and Settings\<user>\Local Settings\Temp\                                                      --
--                                                                                                                 --
---------------------------------------------------------------------------------------------------------------------
-- *** NO CHANGES NEED TO BE MADE TO THE SCRIPT BEYOND THIS POINT ***                                              --
---------------------------------------------------------------------------------------------------------------------

USE tempdb;



DECLARE @SqlProductVersion NVARCHAR(20);
DECLARE @SqlMajorVersion INT;
DECLARE @SqlIsClustered NVARCHAR(1);

DECLARE @OldDllVersion VARCHAR(20);
DECLARE @OldExeVersion VARCHAR(20);
DECLARE @OldLicenseVersionId VARCHAR(1);
DECLARE @OldLicenseVersionText VARCHAR(20);

DECLARE @NewDllVersion VARCHAR(20);
DECLARE @NewExeVersion VARCHAR(20);
DECLARE @NewLicenseVersionId VARCHAR(1);
DECLARE @NewLicenseVersionText VARCHAR(20);

DECLARE @SerialNumber VARCHAR(30);

DECLARE @MachineName VARCHAR(128);
DECLARE @InstanceName VARCHAR(128);
DECLARE @CombinedName VARCHAR(128);

DECLARE @CmdshellState INT;

DECLARE @SqbFileExistsExec VARCHAR(1024);
DECLARE @SqbExistsResult VARCHAR(50);

DECLARE @SqbTestFileCreateExec VARCHAR(1024);
DECLARE @SqbTestFileExistsExec VARCHAR(1024);
DECLARE @SqbTestFileDeleteExec VARCHAR(1024);
DECLARE @SqbTestFileExistsResult VARCHAR(50);

DECLARE @SqbSetupExec VARCHAR(1024);
DECLARE @TypeExitCodeFileExec VARCHAR(1024);
DECLARE @DelExitCodeFileExec VARCHAR(1024);

DECLARE @SqbExecutionResult INT;
DECLARE @SqbExecutionResultText VARCHAR(512);

DECLARE @ExecRetryCount INT;
DECLARE @SqbInstallRetry BIT;

-- Establish the current SQL Server major version (e.g. 8, 9, 10).
SET @SqlProductVersion = CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR);
SET @SqlMajorVersion = CAST(SUBSTRING(@SqlProductVersion, 1, CHARINDEX('.', @SqlProductVersion) - 1) AS INT);

-- Establish the clustering status ('1' means clustered, '0' means non-clustered, NULL means unknown)
SET @SqlIsClustered = CAST(SERVERPROPERTY('IsClustered') AS VARCHAR(1));


-- Execute only if we are running SQL Server 2000, 2005 or 2008; and on a non-clustered instance.  
-- SQL Backup does not support SQL Server 7 or earlier.  This script does not currently support
-- clustered instances.
IF @SqlMajorVersion >= 8  AND @SqlMajorVersion <=10 AND (@SqlIsClustered = '0')
  BEGIN
  
    -- Firstly, get the instance naming details (and convert any NULL values to empty strings).
    SET @MachineName = CAST(SERVERPROPERTY('MachineName') AS VARCHAR(128));
    IF @MachineName IS NULL SET @MachineName = '';
    
    SET @InstanceName = CAST(SERVERPROPERTY('InstanceName') AS VARCHAR(128));
    IF @InstanceName IS NULL SET @InstanceName = '';

    SET @CombinedName = CAST(SERVERPROPERTY('ServerName') AS VARCHAR(128));
    IF @CombinedName IS NULL SET @CombinedName = '';


    -- Create a temporary object #SqbOutput, which will be used to store temporary information,
    -- as well as swallow up any discardable result sets (so they don't cluter SQL Multi Script up).
    IF (OBJECT_ID('tempdb..#SqbOutput')) IS NULL
      CREATE TABLE #SqbOutput (TextOutput VARCHAR(1024));
      

    -- If the SQL Backup components are already installed, attempt to get the current version details.
    IF OBJECT_ID('master..sqbutility') IS NOT NULL
      BEGIN
        -- A version has been installed, we need to find out which (we use #SqbOutput to get rid of the
        -- blank result sets)
        INSERT #SqbOutput EXECUTE master..sqbutility 30, @OldDllVersion OUTPUT;
        INSERT #SqbOutput EXECUTE master..sqbutility 1030, @OldExeVersion OUTPUT;
        INSERT #SqbOutput EXECUTE master..sqbutility 1021, @OldLicenseVersionId OUTPUT, NULL, @SerialNumber OUTPUT;

        -- Clean the temporary table
        DELETE FROM #SqbOutput;

        -- Convert the License Edition into Text
        SELECT @OldLicenseVersionText =
          CASE WHEN @OldLicenseVersionId = '0' THEN 'Trial: Expired'
               WHEN @OldLicenseVersionId = '1' THEN 'Trial'
               WHEN @OldLicenseVersionId = '2' THEN 'Standard'
               WHEN @OldLicenseVersionId = '3' THEN 'Professional'
               WHEN @OldLicenseVersionId = '6' THEN 'Lite'
          END
      END
    ELSE
      BEGIN
        SET @OldDllVersion = 'Not Installed';
        SET @OldExeVersion = 'Not Installed';
        SET @OldLicenseVersionId = '-1';
        SET @OldLicenseVersionText = 'Unknown';
        SET @SerialNumber = 'Unknown';
      END
    
    IF @PerformInstallation = 1
      BEGIN
        -- Installation bit is set, so perform the installation

        -- If running SQL Server 2005 (or later), need to turn on xp_cmdshell
        IF @SqlMajorVersion >= 9
          BEGIN

            EXECUTE master..sp_configure 'show advanced options', 1;
            RECONFIGURE WITH OVERRIDE; -- No 'go' because we don't want to lose variables

	        -- Want to keep the value of xp_cmdshell for later use
            SELECT @CmdshellState = value from master..sysconfigures where config=16390;
		
            EXECUTE master..sp_configure 'xp_cmdshell', 1;
            RECONFIGURE WITH OVERRIDE;
          END

        -- Check that the file exists (returning "1" if valid), if it doesn't, we cannot do the installation
        SET @SqbFileExistsExec = 'if exist ' + @DownloadDirectory + '\SqbServerSetup.exe echo 1';
        INSERT #SqbOutput EXECUTE master..xp_cmdshell @SqbFileExistsExec; 
            
        -- Parse the output, pulling it from the temporary table (TOP 1 to get rid of subsequent rows)
        SELECT TOP 1 @SqbExistsResult = CAST(TextOutput AS VARCHAR(50)) FROM #SqbOutput; 
        
        -- Clean the temporary table
        DELETE FROM #SqbOutput;

		-- Check that we can create files in the directory (for exitcodefile), if we can't then no point
        -- doing the installation
        SET @SqbTestFileCreateExec = 'echo 1 > ' + @DownloadDirectory + '\exitcodetest.txt';
        SET @SqbTestFileExistsExec = 'if exist ' + @DownloadDirectory + '\exitcodetest.txt echo 1';
        SET @SqbTestFileDeleteExec = 'del ' + @DownloadDirectory + '\exitcodetest.txt';

		EXECUTE master..xp_cmdshell @SqbTestFileCreateExec, no_output; 
        INSERT #SqbOutput EXECUTE master..xp_cmdshell @SqbTestFileExistsExec; 
        EXECUTE master..xp_cmdshell @SqbTestFileDeleteExec, no_output; 

        -- Parse the output, pulling it from the temporary table
        SELECT TOP 1 @SqbTestFileExistsResult = CAST (TextOutput AS VARCHAR(50)) FROM #SqbOutput;

        -- Clean the temporary table again
        DELETE FROM #SqbOutput;

        IF @SqbExistsResult IS NOT NULL AND @SqbTestFileExistsResult IS NOT NULL
          BEGIN

            -- Generate the command strings for 'reading' and deleting the exitcode file, with instance-specific naming
            SET @TypeExitCodeFileExec = 'type ' + @DownloadDirectory + '\exitcode_' + @MachineName + '_' 
              + @InstanceName + '.txt';
            SET @DelExitCodeFileExec = 'del ' + @DownloadDirectory + '\exitcode_' + @MachineName + '_' 
              + @InstanceName + '.txt';

            -- Generate the command to execute the installation, including any applicable credentials and instance details
            SET @SqbSetupExec = @DownloadDirectory + '\SqbServerSetup.exe /VERYSILENT /SUPPRESSMSGBOXES '
		      + '/LOG /EXITCODEFILE exitcode_' + @MachineName + '_' + @InstanceName + '.txt';

            IF @ServiceUsername IS NOT NULL AND @ServicePassword IS NOT NULL
              SET @SqbSetupExec = @SqbSetupExec + ' /SVCUSER ' + @ServiceUsername
                + ' /SVCPW ' + @ServicePassword; -- affix windows credentials (plain text)

            IF @SqlUsername IS NOT NULL AND @SqlPassword IS NOT NULL
              SET @SqbSetupExec = @SqbSetupExec + ' /SQLUSER ' + @SqlUsername
                + ' /SQLPW ' + @SqlPassword; -- affix SQL credentials

            IF @InstanceName <> '' -- already converted null to an empty string
              SET @SqbSetupExec = @SqbSetupExec + ' /I ' + @InstanceName; -- add instance details


            -- Perform the installation, if we get exit code 5 (another installation in progress) then retry
            SET @ExecRetryCount = 10;
            SET @SqbExecutionResult = -1;
            SET @SqbInstallRetry = 1; -- true

            WHILE @ExecRetryCount > 0 AND @SqbInstallRetry = 1
              BEGIN
                -- Perform the execution and get the exit code
                EXECUTE master..xp_cmdshell @SqbSetupExec, no_output;
                INSERT #SqbOutput EXECUTE master..xp_cmdshell @TypeExitCodeFileExec; 
            
                -- Parse the output, pulling it from the temporary table
                SELECT @SqbExecutionResult = CAST(TextOutput AS INT) FROM #SqbOutput; 

                -- If the exit code is 5, we want to retry in a few seconds
                IF @SqbExecutionResult = 5
                  BEGIN
                    SET @ExecRetryCount = @ExecRetryCount - 1;
                    WAITFOR DELAY '00:00:10'; -- Wait for 10 seconds and try again
                  END
                ELSE 
                  SET @SqbInstallRetry = 0; -- Set retry flag to 0
              END


            -- Clean up and delete the temporary exit code file
            INSERT #SqbOutput EXECUTE master..xp_cmdshell @DelExitCodeFileExec;

            -- Parse the output code, and generate the necessary text
            IF @SqbExecutionResult = 0
              SET @SqbExecutionResultText = 'Successful (0).';
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
                         ELSE 'Unsuccessful: Check installation log for further information (' + CAST(@SqbExecutionResult AS VARCHAR(8)) + ').'
                  END
                ELSE
                  BEGIN
                    -- Installation was 'successful', but a post-installation check failed
                    SET @SqbExecutionResultText = 'The following post-installation checks failed: ';

                    IF @SqbExecutionResult % 524288 / 262144 = 1 
                      SET @SqbExecutionResultText = @SqbExecutionResultText + 'The version of xp_sqlbackup.dll is incorrect (262144); ';

                    IF @SqbExecutionResult % 262144 / 131072 = 1 
                      SET @SqbExecutionResultText = @SqbExecutionResultText + 'The file xp_sqlbackup.dll was not installed correctly (131072); ';

                    IF @SqbExecutionResult % 131072 / 65536 = 1 
                      SET @SqbExecutionResultText = @SqbExecutionResultText + 'The SQL Backup Agent service was unable to start within 1 minute (65536); ';

                    IF @SqbExecutionResult % 65536 / 32768 = 1 
                      SET @SqbExecutionResultText = @SqbExecutionResultText + 'The SQL Backup Agent service could not be registered correctly (32768); ';    

                    IF @SqbExecutionResult % 32768 / 16384 = 1 
                      SET @SqbExecutionResultText = @SqbExecutionResultText + 'The version of the SQL Backup Agent service is incorrect (16384); ';    

                    IF @SqbExecutionResult % 16384 / 8192 = 1 
                      SET @SqbExecutionResultText = @SqbExecutionResultText + 'The SQL Backup Agent service executable was not installed (8192); ';    
                  END
              END
          END
        ELSE
          BEGIN
            -- Installer file does not exist, so return generic message
            SET @SqbExecutionResult = -1;
            SET @SqbExecutionResultText = 'Unsuccessful: The file could not be found (-1).';
          END

          -- If the SQL Backup components are now installed, attempt to get the current version details.
            IF OBJECT_ID('master..sqbutility') IS NOT NULL
              BEGIN
                -- A version has been installed, we need to find out which (we use #SqbOutput to get rid of the
                -- blank result sets)
                INSERT #SqbOutput EXECUTE master..sqbutility 30, @NewDllVersion OUTPUT;
                INSERT #SqbOutput EXECUTE master..sqbutility 1030, @NewExeVersion OUTPUT;
                INSERT #SqbOutput EXECUTE master..sqbutility 1021, @NewLicenseVersionId OUTPUT, NULL, @SerialNumber OUTPUT;

                -- Clean the temporary table
                DELETE FROM #SqbOutput;

                -- Convert the License Edition into Text
                SELECT @NewLicenseVersionText =
                  CASE WHEN @NewLicenseVersionId = '0' THEN 'Trial: Expired'
                       WHEN @NewLicenseVersionId = '1' THEN 'Trial'
                       WHEN @NewLicenseVersionId = '2' THEN 'Standard'
                       WHEN @NewLicenseVersionId = '3' THEN 'Professional'
                       WHEN @NewLicenseVersionId = '6' THEN 'Lite'
                END
              END
            ELSE
              BEGIN
                SET @NewDllVersion = 'Not Installed';
                SET @NewExeVersion = 'Not Installed';
                SET @NewLicenseVersionId = '-1';
                SET @NewLicenseVersionText = 'Unknown';
                SET @SerialNumber = 'Unknown';
              END

            -- Clean up temporary table
            IF (OBJECT_ID('tempdb..#SqbOutput')) IS NOT NULL
              DROP TABLE #SqbOutput;

            -- If running SQL Server 2005 (or later), need to reset xp_cmdshell to the previous value (ideally off)
            IF @SqlMajorVersion >= 9
              BEGIN
                EXECUTE master..sp_configure 'xp_cmdshell', @CmdshellState;
                RECONFIGURE WITH OVERRIDE;
                EXECUTE master..sp_configure 'show advanced options', 0;
                RECONFIGURE WITH OVERRIDE; -- No 'go' because we don't want to lose variables
              END

            SELECT @CombinedName AS SqlServerName, @OldDllVersion AS PreviousVersion, 
                   @OldLicenseVersionText AS PreviousLicense, @NewDllVersion AS NewVersion,
                   @NewLicenseVersionText AS NewLicense, @SerialNumber AS SerialNumber,
                   @SqbExecutionResultText AS InstallStatus;
      END
    ELSE
      -- Installation flag not set, just return the old details
      SELECT @CombinedName AS SqlServerName, @OldDllVersion AS CurrentVersion, 
             @OldLicenseVersionText AS CurrentLicense, @SerialNumber AS SerialNumber;
  END
ELSE
  IF @SqlIsClustered <> 1
    RAISERROR('Clustered installations are not supported in this version of the script.  Please install the server components manually.',16,1);
  ELSE
    IF @SqlMajorVersion < 8
      RAISERROR('SQL Backup 6 is not available for SQL Server 7 or earlier.  The software can only be installed on SQL Server 2000 SP3 or later.',16,1);
    ELSE
      RAISERROR('SQL Server 2008 is the latest SQL Server version supported by this script.  Please install the server components manually.', 16, 1);
    

