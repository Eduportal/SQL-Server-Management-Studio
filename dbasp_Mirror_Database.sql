USE [dbaadmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[dbasp_Mirror_Database]
	(
	@ServerName		SYSNAME		= ''
	,@DBName		SYSNAME		= ''
	,@BackupPath		VARCHAR(MAX)	= NULL
	,@RestorePath		VARCHAR(MAX)	= NULL
	,@FullReset		BIT		= 1
	,@TestCopyOnly		BIT		= 1
	,@NoRestore		BIT		= 0
	,@filegroups		VARCHAR(MAX)	= NULL
	,@files			VARCHAR(MAX)	= NULL
	)
AS

--DECLARE	@ServerName		SYSNAME		= 'SEAPCRMSQL1A'
--	,@DBName		SYSNAME		= 'Getty_Images_US_Inc__MSCRM'
--	,@BackupPath		VARCHAR(MAX)	= NULL
--	,@RestorePath		VARCHAR(MAX)	= NULL
--	,@FullReset		BIT		= 1
--	,@TestCopyOnly		BIT		= 0
--	,@filegroups		VARCHAR(MAX)	= 'Primary'
--	,@files			VARCHAR(MAX)	= NULL

	SET NOCOUNT ON
	SET ANSI_NULLS ON
	SET ANSI_WARNINGS ON

	DECLARE		@MostRecent_Full	DATETIME
			,@MostRecent_Diff	DATETIME
			,@MostRecent_Log	DATETIME
			,@CMD			VARCHAR(MAX)
			,@CMD2			VARCHAR(MAX)
			,@COPY_CMD		VARCHAR(MAX)
			,@CnD_CMD		VARCHAR(8000)
			,@FileName		VARCHAR(MAX)
			,@AgentJob		SYSNAME
			,@MachineName		SYSNAME
			,@RemoteEndpointName	SYSNAME
			,@RemoteEndpointID	INT
			,@RemoteEndpointPort	INT
			,@LocalEndpointName	SYSNAME
			,@LocalEndpointID	INT
			,@LocalEndpointPort	INT
			,@CreateEndpoint	VarChar(MAX)
			,@Local_FQDN		SYSNAME
			,@Remote_FQDN		SYSNAME
			,@ShareName			VarChar(500)
			,@LogPath			VarChar(100)
			,@DataPath			VarChar(100)
			,@CMD_TYPE			CHAR(3)
			,@errorcode			INT
			,@sqlerrorcode		INT
			,@RestoreOrder		INT
			,@DateModified		DATETIME
			,@Extension			VARCHAR(MAX)
			,@CopyStartTime		DateTime
			,@partial_flag		BIT
			,@FileNameSet		VarChar(MAX)
			,@RtnCode			INT
			,@CopyThreads		INT
			,@syntax_out		VarChar(max)
			,@TryBackup			bit	
				
	SELECT		@partial_flag	= 0
				,@TryBackup		= 0
				,@CopyThreads	= 48
				,@MachineName	= LEFT(@ServerName,CHARINDEX('\',@ServerName+'\')-1)
				,@CreateEndpoint = 'CREATE ENDPOINT [Mirroring] 
	AUTHORIZATION [sa]
	STATE=STARTED
	AS TCP (LISTENER_PORT = 5022, LISTENER_IP = ALL)
	FOR DATA_MIRRORING (ROLE = PARTNER, AUTHENTICATION = WINDOWS NEGOTIATE
, ENCRYPTION = REQUIRED ALGORITHM RC4)'

	-- ADD DYNAMIC LINKED SERVER
	IF  EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = N'DYN_DBA_RMT')
		EXEC master.dbo.sp_dropserver @server=N'DYN_DBA_RMT', @droplogins='droplogins'
  
	EXEC sp_addlinkedserver @server='DYN_DBA_RMT',@srvproduct='',@provider='SQLNCLI',@datasrc=@ServerName
	EXEC master.dbo.sp_serveroption @server=N'DYN_DBA_RMT', @optname=N'rpc', @optvalue=N'true'
	EXEC master.dbo.sp_serveroption @server=N'DYN_DBA_RMT', @optname=N'rpc out', @optvalue=N'true'
	EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DYN_DBA_RMT',@useself=N'True',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL
	IF @TestCopyOnly = 0
	BEGIN
		RAISERROR('Disabeling Transaction Log Backup Job on On Primary Server',-1,-1) WITH NOWAIT
		-- DISABLE LOG BACKUPS ON PRIMARY TILL MIRRORING IS DONE
		SET @CMD = 'EXEC msdb.dbo.sp_update_job @job_name=N''MAINT - TranLog Backup'', @enabled=0'
		RAISERROR('    -- %s',-1,-1,@CMD) WITH NOWAIT
		EXEC (@CMD)  AT [DYN_DBA_RMT]	

		-- GET LOCAL MIRRORING ENPOINT INFO
		SELECT		@LocalEndpointID	= endpoint_id
				,@LocalEndpointPort	= port
		FROM		master.sys.tcp_endpoints 
		WHERE		TYPE=4

		IF @LocalEndpointID IS NOT NULL
			SELECT		@LocalEndpointName = NAME
			FROM		master.sys.endpoints 
			WHERE		endpoint_id = @LocalEndpointID
		ELSE
		BEGIN
			EXEC (@CreateEndpoint)

			SELECT		@LocalEndpointID	= endpoint_id
					,@LocalEndpointPort	= port
					,@LocalEndpointName	= 'Mirroring'-- select *
			FROM		master.sys.tcp_endpoints 
			WHERE		TYPE=4
		END


		-- GET REMOTE MIRRORING ENPOINT INFO
		SELECT		@RemoteEndpointID	= endpoint_id
				,@RemoteEndpointPort	= port
		FROM		[DYN_DBA_RMT].master.sys.tcp_endpoints 
		WHERE		TYPE=4

		IF @RemoteEndpointID IS NOT NULL
			SELECT		@RemoteEndpointName = NAME
			FROM		[DYN_DBA_RMT].master.sys.endpoints 
			WHERE		endpoint_id = @RemoteEndpointID
		ELSE
		BEGIN
			EXEC (@CreateEndpoint) AT [DYN_DBA_RMT]

			SELECT		@LocalEndpointID	= endpoint_id
					,@LocalEndpointPort	= port
					,@LocalEndpointName	= 'Mirroring'
			FROM		[DYN_DBA_RMT].master.sys.tcp_endpoints 
			WHERE		TYPE=4
		END
	END
	
	-- GET LOCAL FQDN
	EXEC xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SYSTEM\CurrentControlSet\Services\Tcpip\Parameters', N'Domain', @Local_FQDN OUTPUT
	SELECT @Local_FQDN = Cast(SERVERPROPERTY('MachineName') as nvarchar) + '.' + @Local_FQDN

	-- GET REMOTE FQDN
	EXEC [DYN_DBA_RMT].master..xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SYSTEM\CurrentControlSet\Services\Tcpip\Parameters', N'Domain', @Remote_FQDN OUTPUT
	SELECT @Remote_FQDN = @MachineName + '.' + @Remote_FQDN


	IF @FullReset = 1 AND DB_ID(@DBNAME) IS NOT NULL 
	BEGIN
		Print '**** FULL RESET REQUESTED, '+UPPER(@DBNAME)+' DATABASE WILL BE DROPED AND RECREATED. ***'

		-- DROP ANY DATABASE SNAPSHOTS
		CheckForSnapshots:
		IF EXISTS(SELECT 1 FROM sys.databases WHERE source_database_id = DB_ID(@DBNAME))
		BEGIN		
			SELECT TOP 1 @CMD = name, @CMD2 = 'DROP DATABASE ['+name+'];'
			FROM sys.databases 
			WHERE source_database_id = DB_ID(@DBNAME)
					
			RAISERROR('  -- %s is a Snapshot of %s and must be droped first.',-1,-1,@CMD2,@DBNAME) WITH NOWAIT
			RAISERROR('    -- %s',-1,-1,@CMD2) WITH NOWAIT
				EXEC dbaadmin.dbo.dbasp_KillAllOnDB @CMD
				EXEC (@CMD2)
				EXEC msdb.dbo.sp_delete_database_backuphistory @CMD
				
			IF DB_ID(@CMD2) IS NULL
				RAISERROR('      -- Success.',-1,-1) WITH NOWAIT
			ELSE
				RAISERROR('      -- Failure.',-1,-1) WITH NOWAIT
		END
		
		IF EXISTS(SELECT 1 FROM sys.databases WHERE source_database_id = DB_ID(@DBNAME))
			GOTO CheckForSnapshots
		
		-- SET DATABASE TO RESTRICTED USER TO KICK EVERYONE OUT
		IF (select state_desc From master.sys.databases WHERE database_id = DB_ID(@DBName)) = 'ONLINE'
		BEGIN
			RAISERROR('  -- Restricting %s so that drop can be done.',-1,-1,@DBNAME) WITH NOWAIT
			SET @CMD = 'ALTER DATABASE ['+@DBName+'] SET RESTRICTED_USER WITH ROLLBACK IMMEDIATE'
			RAISERROR('    -- %s',-1,-1,@CMD) WITH NOWAIT
			EXEC (@CMD)
		END

		-- DISABLE MIRRORING PARTNERSHIP
		IF EXISTS(select * From master.sys.database_mirroring WHERE database_id = DB_ID(@DBName) AND mirroring_partner_name IS NOT NULL)
		BEGIN
			RAISERROR('  -- %s is currently a Mirroring Partner and must be Turned Off first.',-1,-1,@DBNAME) WITH NOWAIT
			SET @CMD = 'ALTER DATABASE ['+@DBName+'] SET PARTNER OFF;'
			RAISERROR('    -- %s',-1,-1,@CMD) WITH NOWAIT
			EXEC (@CMD)
		END

		-- TRY SIMPLE DROP
		BEGIN TRY
			RAISERROR('  -- Dropping %s...',-1,-1,@DBNAME) WITH NOWAIT
			SET @CMD = 'DROP DATABASE ['+@DBName+']'
			RAISERROR('    -- %s',-1,-1,@CMD) WITH NOWAIT
			EXEC (@CMD)
		END TRY
		BEGIN CATCH
			RAISERROR('      -- Failed, Attempting to Prepare DB For Dropping.',-1,-1,@DBNAME) WITH NOWAIT
		END CATCH
		
		-- RECOVER RESTORING DATABASE
		IF EXISTS(select * From master.sys.databases WHERE database_id = DB_ID(@DBName) AND state_desc = 'RESTORING')
		BEGIN
			RAISERROR('  -- %s is currently Restoring and must be Recovered first.',-1,-1,@DBNAME) WITH NOWAIT
			SET @CMD = 'RESTORE DATABASE ['+@DBName+'] WITH RECOVERY;'
			RAISERROR('    -- %s',-1,-1,@CMD) WITH NOWAIT
			EXEC (@CMD)
		END
		
		-- TRY SIMPLE DROP AGIAN
		IF DB_ID(@DBNAME) IS NOT NULL 
		BEGIN 
			RAISERROR('  -- Dropping %s...',-1,-1,@DBNAME) WITH NOWAIT
			SET @CMD = 'DROP DATABASE ['+@DBName+']'
			RAISERROR('    -- %s',-1,-1,@CMD) WITH NOWAIT
			EXEC (@CMD)
		END


		IF DB_ID(@DBName) IS NULL
			RAISERROR('      -- Success.',-1,-1) WITH NOWAIT
		ELSE
			RAISERROR('      -- Failure.',-1,-1) WITH NOWAIT
	END

	IF DB_ID(@DBNAME) IS NULL
		EXEC msdb.dbo.sp_delete_database_backuphistory @DBName

	IF @NoRestore = 1 GOTO NoRestore

	RetryRestore:

	RAISERROR('      -- Starting Transaction Log Backup of %s on Primary Server',-1,-1,@DBName) WITH NOWAIT
	-- DISABLE LOG BACKUPS ON PRIMARY TILL MIRRORING IS DONE
	SET @CMD = 'EXEC dbaadmin.dbo.dbasp_Backup @DBName = '''+@DBName+''', @Mode = ''BL'''
	RAISERROR('        -- %s',-1,-1,@CMD) WITH NOWAIT
	EXEC (@CMD)  AT [DYN_DBA_RMT]	

	RAISERROR('  -- Start Generating Restore Script',-1,-1) WITH NOWAIT

	 EXEC		[dbaadmin].[dbo].[dbasp_format_BackupRestore] 
					@DBName			= @DBName
					,@Mode			= 'RD'
					,@FromServer		= @ServerName
					,@Verbose		= 0
					,@FullReset		= 1
					,@LeaveNORECOVERY	= 1
					,@syntax_out		= @syntax_out OUTPUT

	IF NULLIF(@syntax_out,'') IS NULL 
	BEGIN
		IF @TryBackup = 1
		BEGIN
			RAISERROR('      -- Still Nothing to Restore. Aborting Procedure',16,1) WITH NOWAIT
			RETURN -1
		END

		SET @TryBackup = 1

		RAISERROR('    -- Nothing to Restore. Kicking of Source Backups and retrying Restore Script Generation',-1,-1) WITH NOWAIT

		RAISERROR('      -- Starting Full Backup of %s on Primary Server',-1,-1,@DBName) WITH NOWAIT
		-- DISABLE LOG BACKUPS ON PRIMARY TILL MIRRORING IS DONE
		SET @CMD = 'EXEC dbaadmin.dbo.dbasp_Backup @DBName = '''+@DBName+''', @Mode = ''BF'''
		RAISERROR('        -- %s',-1,-1,@CMD) WITH NOWAIT
		EXEC (@CMD)  AT [DYN_DBA_RMT]	

		Goto RetryRestore
	END

	RAISERROR('  -- Done Generating Restore Script',-1,-1) WITH NOWAIT

	RAISERROR('  -- Start Running Restore Script',-1,-1) WITH NOWAIT
	--IF @TestCopyOnly = 0
		EXEC (@syntax_out)
	RAISERROR('  -- Done Running Restore Script',-1,-1) WITH NOWAIT

	NoRestore:

	IF @TestCopyOnly = 0
	BEGIN
		RAISERROR('  -- Start Mirroring Configuration',-1,-1) WITH NOWAIT

		-- STOP MIRRORING PARTNER AT PRIMARY
		IF EXISTS(select * From [DYN_DBA_RMT].master.sys.database_mirroring T1 JOIN [DYN_DBA_RMT].master.sys.databases T2 ON T1.database_id = T2.database_id WHERE T2.name = @DBName AND T1.mirroring_partner_name IS NOT NULL)
		BEGIN
			SET @CMD = 'ALTER DATABASE ['+@DBName+'] SET PARTNER OFF'
			RAISERROR('    -- %s',-1,-1,@CMD) WITH NOWAIT
			EXEC (@CMD) AT [DYN_DBA_RMT]
		END
	
		-- SET MIRRORING PARTNER AT MIRROR
		SET @CMD = 'ALTER DATABASE ['+@DBName+'] SET PARTNER = ''TCP://'+@Remote_FQDN+':'+CAST(@RemoteEndpointPort AS VarChar(10))+''''
		RAISERROR('    -- %s',-1,-1,@CMD) WITH NOWAIT
		EXEC (@CMD) 	
		
		-- SET MIRRORING PARTNER AT PRIMARY
		SET @CMD = 'ALTER DATABASE ['+@DBName+'] SET PARTNER = ''TCP://'+@Local_FQDN+':'+CAST(@LocalEndpointPort AS VarChar(10))+''''
		RAISERROR('    -- %s',-1,-1,@CMD) WITH NOWAIT
		EXEC (@CMD) AT [DYN_DBA_RMT]

		-- SET MIRRORING SAFETY OFF AT PRIMARY
		SET @CMD = 'ALTER DATABASE ['+@DBName+'] SET SAFETY OFF'
		RAISERROR('    -- %s',-1,-1,@CMD) WITH NOWAIT
		EXEC (@CMD) AT [DYN_DBA_RMT]

		RAISERROR('  -- Done with Mirroring Configuration',-1,-1) WITH NOWAIT

	-- ENABLE LOG BACKUPS ON PRIMARY NOW THAT MIRRORING IS DONE
	SET @CMD = 'EXEC msdb.dbo.sp_update_job @job_name=N''MAINT - TranLog Backup'', @enabled=1'
	EXEC (@CMD)  AT [DYN_DBA_RMT]

	END
	ELSE RAISERROR('  -- Mirroring Configuration Skipped',-1,-1) WITH NOWAIT


GO
 
 
 
 
 
 
