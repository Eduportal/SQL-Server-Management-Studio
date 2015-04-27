SET NOCOUNT ON

:r \\seapsqldba01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_2005\dbasp_dba_sqlsetup.sql
:r \\seapsqldba01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_2005\dbasp_dba_logshares.sql
:r \\seapsqldba01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_2005\dbasp_FixJobLogOutputFiles.sql



DECLARE		@share_name		varchar	(100)
			,@OldLogPath	VarChar	(8000)
			,@NewLogPath	VarChar	(8000)
			,@BackupPath	VarChar (8000)

Select	@share_name			= REPLACE(@@SERVERNAME,'\','$') + '_backup'

PRINT 'Getting Backup Path'
EXEC	dbaadmin.dbo.dbasp_get_share_path @share_name = @share_name, @phy_path = @BackupPath OUT
PRINT	'	'+@BackupPath
PRINT	''

PRINT	'Expected New _SQLjob_logs Path'
PRINT	'	' +Left(@BackupPath,2) + '\SQLjob_logs' + REPLACE('$'+@@SERVICENAME,'$MSSQLSERVER','')
PRINT	''

Select	@share_name			= REPLACE(@@SERVERNAME,'\','$') + '_SQLjob_logs'

PRINT 'Getting Current Path'
EXEC	dbaadmin.dbo.dbasp_get_share_path @share_name = @share_name, @phy_path = @OldLogPath OUT
PRINT	'	'+@OldLogPath
PRINT	''

PRINT 'Resetting Path'
EXEC	dbaadmin.[dbo].[dbasp_dba_logshares] -- RE-POINT  SQLjob_logs

PRINT 'Getting New Path'
EXEC	dbaadmin.dbo.dbasp_get_share_path @share_name = @share_name, @phy_path = @NewLogPath OUT
PRINT	'	'+@NewLogPath
PRINT	''

IF		@OldLogPath = @NewLogPath
	PRINT 'Share Path Did Not Change'
ELSE
	BEGIN
		PRINT 'Started Changing Current Jobs'
		
		EXEC dbaadmin.dbo.dbasp_FixJobLogOutputFiles	@NestLevel	= 1
														,@Verbose	= 0
														,@PrintOnly	= 0
														,@ForcePath	= 1
														,@OldPath	= @OldLogPath
														
		PRINT 'Finished Changing Current Jobs'
	END
	
----------------------------------------------------------------
----------------------------------------------------------------
--					REDGATE SETTINGS
----------------------------------------------------------------
----------------------------------------------------------------
DECLARE		@DataPath		nvarchar(4000) 
			,@LogFolder		nvarchar(4000) 
			,@RegKey		nvarchar(4000)
			,@RegValue		nvarchar(4000)
			,@RegValName	nvarchar(4000)
			,@CMD			VarChar(max)
			,@IsClustered	BIT   

DECLARE		@Instances		TABLE([Instance] SYSNAME)
DECLARE		@Resources		TABLE([Resource] SYSNAME)
DECLARE		@Values			TABLE([Key]  nvarchar(4000) NULL, [ValName] SYSNAME NULL,[Value] nvarchar(4000) NULL)
DECLARE		@CheckValues	TABLE([Key]  nvarchar(4000) NULL, [ValName] SYSNAME NULL,[Value] nvarchar(4000) NULL)
DECLARE		@Keys			TABLE([Key]  nvarchar(4000))
DECLARE		@ServiceState	TABLE([State] varchar(100))

-- CHECK FOR Red Gate KEY
DELETE @Keys
INSERT INTO @Keys
EXEC master.dbo.xp_regenumkeys 
    N'HKEY_LOCAL_MACHINE',
    N'Software'
IF COALESCE((SELECT 1 FROM @Keys WHERE [Key] = 'Red Gate'),0) = 0
BEGIN
	PRINT '	- No Red Gate Software Installed.'
	GOTO SkipRedGate
END

-- CHECK FOR SQL Backup KEY
DELETE @Keys
INSERT INTO @Keys
EXEC master.dbo.xp_regenumkeys 
    N'HKEY_LOCAL_MACHINE',
    N'Software\Red Gate'
IF COALESCE((SELECT 1 FROM @Keys WHERE [Key] = 'SQL Backup'),0) = 0
BEGIN
	PRINT '	- SQL Backup Software Not Installed.'
	GOTO SkipRedGate
END

-- CHECK FOR BackupSettingsGlobal KEY
DELETE @Keys
INSERT INTO @Keys
EXEC master.dbo.xp_regenumkeys 
    N'HKEY_LOCAL_MACHINE',
    N'Software\Red Gate\SQL Backup'
IF COALESCE((SELECT 1 FROM @Keys WHERE [Key] = 'BackupSettingsGlobal'),0) = 0
BEGIN
	PRINT '	- SQL Backup Software Not Configured.'
	GOTO SkipRedGate
END

-- GET INSTANCES
INSERT INTO @Instances
EXEC master.dbo.xp_regenumkeys 
    N'HKEY_LOCAL_MACHINE',
    N'Software\Red Gate\SQL Backup\BackupSettingsGlobal'

DELETE @Instances WHERE REPLACE([Instance],'(LOCAL)','MSSQLSERVER') != @@SERVICENAME


-- CHECK IF CLUSTERED
INSERT INTO @Keys
EXEC master.dbo.xp_regenumkeys 
    N'HKEY_LOCAL_MACHINE',
    N''

SELECT @IsClustered = COALESCE((SELECT 1 FROM @Keys WHERE [Key] = 'Cluster'),0)
DELETE @Keys

IF @IsClustered = 1
BEGIN
	PRINT	'	- Server Is Clustered'
	-- GET CLUSTER RESOURCES
	INSERT INTO @Resources
	EXEC master.dbo.xp_regenumkeys 
		N'HKEY_LOCAL_MACHINE',
		N'Cluster\Resources'

	-- GET ALL RESOURCE VALUES 
	DECLARE Resource_Cursor CURSOR
	FOR
	SELECT Resource FROM @Resources
	OPEN Resource_Cursor
	FETCH NEXT FROM Resource_Cursor INTO @RegKey
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			SET @RegKey = 'Cluster\Resources\'+@RegKey

			-- GET RESOURCES VALUES
			INSERT INTO @Values([ValName],[Value])
			EXEC master.dbo.xp_regenumValues 
				N'HKEY_LOCAL_MACHINE',
				@RegKey

			UPDATE @Values SET [Key] = @RegKey WHERE [Key] IS NULL

		END
		FETCH NEXT FROM Resource_Cursor INTO @RegKey
	END
	CLOSE Resource_Cursor
	DEALLOCATE Resource_Cursor

	-- REMOVE ALL BUT SQLBACKUP NAME VALUES
	DELETE @Values WHERE Value != 'SQLBackupAgent' +REPLACE('_'+@@SERVICENAME,'_MSSQLMASTER','')

	-- GET SQLBACKUP REGSYNC VALUES
	DECLARE Resource_Cursor2 CURSOR
	FOR
	SELECT [Key] FROM @Values
	OPEN Resource_Cursor2
	FETCH NEXT FROM Resource_Cursor2 INTO @RegKey
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			DELETE @Keys
			-- GET KEYS UNDER RESOURCE
			INSERT INTO @Keys
			EXEC master.dbo.xp_regenumKeys 
				N'HKEY_LOCAL_MACHINE',
				@RegKey	
		
			IF EXISTS (SELECT 1 FROM @Keys WHERE [Key] = 'RegSync')
			BEGIN
				SET @RegKey = @RegKey + '\RegSync'
				-- GET RESOURCES VALUES
				INSERT INTO @Values([ValName],[Value])
				EXEC master.dbo.xp_regenumValues 
					N'HKEY_LOCAL_MACHINE',
					@RegKey

				UPDATE @Values SET [Key] = @RegKey WHERE [Key] IS NULL
			END
		END
		FETCH NEXT FROM Resource_Cursor2 INTO @RegKey
	END
	CLOSE Resource_Cursor2
	DEALLOCATE Resource_Cursor2


	-- TAKE SQLBACKUP CLUSTER RESOURCES OFFLINE
	DECLARE Resource_Cursor3 CURSOR
	FOR
	SELECT		DISTINCT 
				[Value] 
	FROM		@Values 
	WHERE		Value LIKE 'SQLBackupAgent%'
	OPEN Resource_Cursor3
	FETCH NEXT FROM Resource_Cursor3 INTO @RegValue
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			-- REMOVE REGISTRY CHECKPOINTS
			SET	@CMD = 'Cluster . res '+@RegValue+' /OFF'
			PRINT @CMD
			EXEC xp_CmdShell @CMD
		END
		FETCH NEXT FROM Resource_Cursor3 INTO @RegValue
	END
	CLOSE Resource_Cursor3
	DEALLOCATE Resource_Cursor3


	-- REMOVE EXISTING SQLBACKUP CLUSTER REGISTRY SYNC CHECKPOINTS
	DECLARE Resource_Cursor4 CURSOR
	FOR
	SELECT		DISTINCT 
				T1.[Value]
				,T2.[Value] 
	FROM		@Values T1 
	JOIN		@Values T2
			ON	T1.[Key]+'\RegSync' = T2.[Key]

	OPEN Resource_Cursor4
	FETCH NEXT FROM Resource_Cursor4 INTO @RegValue,@RegKey
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			-- REMOVE REGISTRY CHECKPOINTS
			SET	@CMD = 'Cluster . res '+@RegValue+' /RemoveCheckpoints:"'+@RegKey+'"'
			PRINT @CMD
			EXEC xp_CmdShell @CMD
		END
		FETCH NEXT FROM Resource_Cursor4 INTO @RegValue,@RegKey
	END
	CLOSE Resource_Cursor4
	DEALLOCATE Resource_Cursor4
END
ELSE
BEGIN
	INSERT INTO	@Values
	SELECT		'','Name','SQLBackupAgent' + REPLACE('_'+[Instance],'_(LOCAL)','')
	FROM		@Instances
	UNION
	SELECT		'','0','SOFTWARE\Red Gate\SQL Backup\BackupSettingsGlobal\'+[Instance]
	FROM		@Instances
	
	-- TAKE SQLBACKUP SERVICES OFFLINE IF NOT CLUSTERED
	DECLARE Resource_Cursor3 CURSOR
	FOR
	SELECT		DISTINCT 
				[Value] 
	FROM		@Values 
	WHERE		Value LIKE 'SQLBackupAgent%'
	OPEN Resource_Cursor3
	FETCH NEXT FROM Resource_Cursor3 INTO @RegValue
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			-- CHECK SERVICE STATUS
			DELETE @ServiceState
			INSERT @ServiceState
			EXEC xp_servicecontrol N'QUERYSTATE',@RegValue

			IF EXISTS (SELECT 1 FROM @ServiceState WHERE [State] IN ('Running.'))
			BEGIN
				SET @CMD = '		- Stopping	Service ' + @RegValue
				RAISERROR (@CMD,-1,-1) WITH NOWAIT
				
				-- STOP SERVICE
				DELETE @ServiceState
				INSERT @ServiceState
				EXEC xp_servicecontrol N'STOP',@RegValue			
				
				--SELECT Top 1 @CMD = State FROM @ServiceState
				--RAISERROR (@CMD,-1,-1) WITH NOWAIT
				
				WHILE NOT EXISTS (SELECT 1 FROM @ServiceState WHERE [State] IN ('Service Stopped.','Stopped.'))
				BEGIN
					--SELECT Top 1 @CMD = State FROM @ServiceState
					--RAISERROR (@CMD,-1,-1) WITH NOWAIT
					
					WAITFOR DELAY '00:00:05'
					SET @CMD = '			- Waiting for ' + @RegValue + ' Service to Stop'
					RAISERROR (@CMD,-1,-1) WITH NOWAIT
					-- CHECK SERVICE STATUS
					DELETE @ServiceState
					INSERT @ServiceState
					EXEC xp_servicecontrol N'QUERYSTATE',@RegValue
				END
				SET @CMD = '			- ' + @RegValue + ' Service has Stopped'
				RAISERROR (@CMD,-1,-1) WITH NOWAIT
			END
			ELSE
			BEGIN
				SET @CMD = '			- ' + @RegValue + ' Service Already Stopped'
				RAISERROR (@CMD,-1,-1) WITH NOWAIT
			END
		END
		FETCH NEXT FROM Resource_Cursor3 INTO @RegValue
	END
	CLOSE Resource_Cursor3
	DEALLOCATE Resource_Cursor3

END


-- CHANGE DATA AND LOG PATHS
DECLARE InstanceCursor CURSOR
FOR
SELECT		DISTINCT
			[Value]
FROM		@Values
WHERE		[Value] Like 'SOFTWARE\Red Gate\SQL Backup\BackupSettingsGlobal%'
OPEN InstanceCursor
FETCH NEXT FROM InstanceCursor INTO @RegKey
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		DELETE @CheckValues
		-- GET KEYS UNDER PATH
		INSERT INTO @CheckValues([ValName],[Value])
		EXEC master.dbo.xp_regenumValues 
			N'HKEY_LOCAL_MACHINE',
			@RegKey		
		
		UPDATE @CheckValues SET [Key] = @RegKey WHERE [Key] IS NULL
		
		IF EXISTS (SELECT 1 FROM @CheckValues WHERE [ValName] = 'DataPath')
		BEGIN
			PRINT 'Changing "DataPath"...'

			-- GET EXISTING PATH
			EXEC master.dbo.xp_regread 
				N'HKEY_LOCAL_MACHINE'
				,@RegKey
				,N'DataPath'
				,@value = @RegValue OUT

			-- CHANGE VALUE			
			SET @RegValue = LEFT(@NewLogPath,CHARINDEX('\SQLjob_logs',@NewLogPath)) + STUFF(@RegValue,1,CHARINDEX('\Red Gate\SQL Backup',@RegValue),'')
		
			PRINT @RegValue
			-- WRITE NEW PATH
			EXEC master.dbo.xp_regwrite 
				N'HKEY_LOCAL_MACHINE'
				,@RegKey
				,N'DataPath'
				,N'REG_SZ'
				,@RegValue
		END
		
		IF EXISTS (SELECT 1 FROM @CheckValues WHERE [ValName] = 'LogFolder')
		BEGIN
			PRINT 'Changing "LogFolder"...'

			-- GET EXISTING PATH
			EXEC master.dbo.xp_regread 
				N'HKEY_LOCAL_MACHINE'
				,@RegKey
				,N'LogFolder'
				,@value = @RegValue OUT

			-- CHANGE VALUE			
			SET @RegValue = LEFT(@NewLogPath,CHARINDEX('\SQLjob_logs',@NewLogPath)) + STUFF(@RegValue,1,CHARINDEX('\Red Gate\SQL Backup',@RegValue),'')
		
			PRINT @RegValue
			-- WRITE NEW PATH
			EXEC master.dbo.xp_regwrite 
				N'HKEY_LOCAL_MACHINE'
				,@RegKey
				,N'LogFolder'
				,N'REG_SZ'
				,@RegValue
		END
				
		
	END
	FETCH NEXT FROM InstanceCursor INTO @RegKey
END
CLOSE InstanceCursor
DEALLOCATE InstanceCursor






IF @IsClustered = 1
BEGIN
	-- REPLACE PREVIOUS SQLBACKUP CLUSTER REGISTRY SYNC CHECKPOINTS
	DECLARE Resource_Cursor5 CURSOR
	FOR
	SELECT		DISTINCT 
				T1.[Value]
				,T2.[Value] 
	FROM		@Values T1 
	JOIN		@Values T2
			ON	T1.[Key]+'\RegSync' = T2.[Key]

	OPEN Resource_Cursor5
	FETCH NEXT FROM Resource_Cursor5 INTO @RegValue,@RegKey
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			-- REMOVE REGISTRY CHECKPOINTS
			SET	@CMD = 'Cluster . res '+@RegValue+' /AddCheckpoints:"'+@RegKey+'"'
			PRINT @CMD
			EXEC xp_CmdShell @CMD
		END
		FETCH NEXT FROM Resource_Cursor5 INTO @RegValue,@RegKey
	END
	CLOSE Resource_Cursor5
	DEALLOCATE Resource_Cursor5

	-- BRING SQLBACKUP CLUSTER RESOURCES ONLINE
	DECLARE Resource_Cursor6 CURSOR
	FOR
	SELECT		DISTINCT 
				[Value] 
	FROM		@Values 
	WHERE		Value LIKE 'SQLBackupAgent%'
	OPEN Resource_Cursor6
	FETCH NEXT FROM Resource_Cursor6 INTO @RegValue
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			-- REMOVE REGISTRY CHECKPOINTS
			SET	@CMD = 'Cluster . res '+@RegValue+' /ON'
			PRINT @CMD
			EXEC xp_CmdShell @CMD
		END
		FETCH NEXT FROM Resource_Cursor6 INTO @RegValue
	END
	CLOSE Resource_Cursor6
	DEALLOCATE Resource_Cursor6

END
ELSE
BEGIN
	-- SET SQLBACKUP SERVICES ONLINE IF NOT CLUSTERED
	DECLARE Resource_Cursor3 CURSOR
	FOR
	SELECT		DISTINCT 
				[Value] 
	FROM		@Values 
	WHERE		Value LIKE 'SQLBackupAgent%'
	OPEN Resource_Cursor3
	FETCH NEXT FROM Resource_Cursor3 INTO @RegValue
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			-- CHECK SERVICE STATUS
			DELETE @ServiceState
			INSERT @ServiceState
			EXEC xp_servicecontrol N'QUERYSTATE',@RegValue

			IF EXISTS (SELECT 1 FROM @ServiceState WHERE [State] IN ('Service Stopped.','Stopped.'))
			BEGIN
				SET @CMD = '		- Starting Service ' + @RegValue
				RAISERROR (@CMD,-1,-1) WITH NOWAIT
				
				-- START SERVICE
				DELETE @ServiceState
				INSERT @ServiceState
				EXEC xp_servicecontrol N'START',@RegValue			
				
				--SELECT Top 1 @CMD = State FROM @ServiceState
				--RAISERROR (@CMD,-1,-1) WITH NOWAIT
				
				WHILE NOT EXISTS (SELECT 1 FROM @ServiceState WHERE [State] IN ('Service Started.','Running.'))
				BEGIN
					--SELECT Top 1 @CMD = State FROM @ServiceState
					--RAISERROR (@CMD,-1,-1) WITH NOWAIT
					
					WAITFOR DELAY '00:00:05'
					SET @CMD = '			- Waiting for ' + @RegValue + ' Service to Start'
					RAISERROR (@CMD,-1,-1) WITH NOWAIT
					-- CHECK SERVICE STATUS
					DELETE @ServiceState
					INSERT @ServiceState
					EXEC xp_servicecontrol N'QUERYSTATE',@RegValue
				END
				SET @CMD = '			- ' + @RegValue + ' Service has Started'
				RAISERROR (@CMD,-1,-1) WITH NOWAIT
			END
			ELSE
			BEGIN
				SET @CMD = '			- ' + @RegValue + ' Service Already Stopped'
				RAISERROR (@CMD,-1,-1) WITH NOWAIT
			END
		END
		FETCH NEXT FROM Resource_Cursor3 INTO @RegValue
	END
	CLOSE Resource_Cursor3
	DEALLOCATE Resource_Cursor3
END	



SkipRedGate:


GO