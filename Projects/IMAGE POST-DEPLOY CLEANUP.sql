SET NOCOUNT ON

DECLARE		@MSG				VarChar(max)
			,@DynamicCode		VarChar(8000)
			,@DefaultBackupDir	VarChar(512)
			,@machinename		SYSNAME
			,@ServerName		SYSNAME
			,@instancename		SYSNAME
			,@ServiceExt		SYSNAME
			,@ShareName			SYSNAME


SELECT		@instancename		= ISNULL('\'+NULLIF(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
			,@ServerName		= REPLACE(@@SERVERNAME,@instancename,'')
			,@machinename		= CONVERT(NVARCHAR(100), SERVERPROPERTY('machinename')) + @instancename
			,@ServiceExt		= ISNULL('$'+NULLIF(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
			--,@DefaultBackupDir	= 'k:\Backup'

		EXEC	master..xp_instance_regread
					@rootkey		= 'HKEY_LOCAL_MACHINE' 
					,@key			= 'Software\Microsoft\MSSQLServer\MSSQLServer' 
					,@value_name	= 'BackupDirectory'
					,@dir			= @DefaultBackupDir OUTPUT

--PRINT @DefaultBackupDir

IF (OBJECT_ID('tempdb..#ExecOutput'))	IS NOT NULL	DROP TABLE #ExecOutput
IF (OBJECT_ID('tempdb..#RMTSHARE'))		IS NOT NULL	DROP TABLE #RMTSHARE
IF (OBJECT_ID('tempdb..#RMTSHARE2'))		IS NOT NULL	DROP TABLE #RMTSHARE2

CREATE	TABLE	#ExecOutput		([rownum] INT IDENTITY PRIMARY KEY,[TextOutput] VARCHAR(8000));


-- GET CURRENT BACKUP PATH
		CREATE TABLE #RMTSHARE ([Share] VARCHAR(MAX) NULL, [Path] VARCHAR(MAX) NULL)
		SET		@DynamicCode	= 'RMTSHARE \\' + CONVERT(NVARCHAR(100), SERVERPROPERTY('machinename'))
		INSERT INTO #RMTSHARE([Share])
		EXEC	xp_CmdShell		@DynamicCode
		UPDATE	#RMTSHARE SET [Path] = dbaadmin.dbo.dbaudf_ReturnPart(REPLACE([Share],' ','|'),2)
		UPDATE	#RMTSHARE SET [Share] = dbaadmin.dbo.dbaudf_ReturnPart(REPLACE([Share],' ','|'),1)
		DELETE	#RMTSHARE WHERE	ISNULL(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE([Share],'_','|'),2),'') NOT IN ('backup','base','builds','dba','dbasql','ldf','log','mdf','nxt','SQLjob')
		SET @DefaultBackupDir = COALESCE(@DefaultBackupDir,(SELECT [Path] FROM #RMTSHARE WHERE dbaadmin.dbo.dbaudf_ReturnPart(REPLACE([Share],'_','|'),2) = 'backup'))
		PRINT @DefaultBackupDir

	IF ISNULL(NULLIF(@machinename,''),@@SERVERNAME) != @@SERVERNAME
	BEGIN
		IF EXISTS (SELECT * FROM sys.servers WHERE name = @machinename) AND NOT EXISTS (SELECT * FROM sys.servers WHERE name = @@SERVERNAME)
		BEGIN
			SET @MSG = 'SEVER NAME CHANGE PENDING SQL RESTART'
			PRINT @MSG
			GOTO EndCode
		END
		ELSE
		BEGIN
			SET @MSG = 'SERVER NAME NEEDS CHANGED TO ' +  @machinename
			PRINT @MSG
		END
	END
	ELSE
	BEGIN
		SET @MSG = 'SERVER NAME IS SET'
		PRINT @MSG
		GOTO SkipRename
	END
	


-- RENAME
	IF @machinename != @@SERVERNAME 
	BEGIN
		IF EXISTS (SELECT * FROM sys.servers WHERE name = @@SERVERNAME)
			EXEC sp_dropserver @@SERVERNAME; 
		IF NOT EXISTS (SELECT * FROM sys.servers WHERE name = @machinename)
			EXEC sp_addserver @machinename, 'local'
		SET @Msg =	'SERVER NAME CHANGED TO ' +  @machinename;
		PRINT @MSG
		GOTO EndCode
	END

SkipRename:


	-- DROP AND RECREATE SHARES
		--DROP SHARES
		SET @Msg =	'Drop Existing Shares'; 
		PRINT @Msg;
		CREATE TABLE #RMTSHARE2 ([OUTPUT] VARCHAR(MAX))
		SET		@DynamicCode	= 'RMTSHARE \\' + REPLACE(@@SERVERNAME,'\'+@@SERVICENAME,'')
		INSERT INTO #RMTSHARE2
		EXEC	xp_CmdShell		@DynamicCode

		UPDATE	#RMTSHARE2 SET [OUTPUT] = dbaadmin.dbo.dbaudf_ReturnPart(REPLACE([OUTPUT],' ','|'),1)
		DELETE	#RMTSHARE2 WHERE	ISNULL(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE([OUTPUT],'_','|'),2),'') NOT IN ('backup','base','builds','dba','dbasql','ldf','log','mdf','nxt','SQLjob')

		DECLARE ShareCursor CURSOR 
		FOR
		SELECT [OUTPUT] FROM #RMTSHARE2 

		OPEN ShareCursor
		FETCH NEXT FROM ShareCursor INTO @ShareName
		WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			IF (@@FETCH_STATUS <> -2)
			BEGIN
				SET @Msg =	'  -- Dropping Share ' + @ShareName; 
				PRINT @Msg;
				SET		@DynamicCode	= 'RMTSHARE \\' + REPLACE(@@SERVERNAME,'\'+@@SERVICENAME,'') + '\' + @ShareName + ' /DELETE'
				EXEC	xp_CmdShell		@DynamicCode, no_output 
			END
			FETCH NEXT FROM ShareCursor INTO @ShareName
		END
		CLOSE ShareCursor
		DEALLOCATE ShareCursor
		DROP TABLE #RMTSHARE2
	
		-- BUILD SHARES
		SET @Msg =	'Build Shares'; 
		PRINT @Msg;
		
		TRUNCATE TABLE #ExecOutput
		SET @DynamicCode	= 'sqlcmd -S' + @@SERVERNAME + ' -E -Q"EXEC dbaadmin.dbo.dbasp_dba_sqlsetup ''' + @DefaultBackupDir + '''"'
		INSERT INTO #ExecOutput(TextOutput)
		EXEC master.sys.xp_cmdshell @DynamicCode

		SET @DynamicCode	= 'sqlcmd -S' + @@SERVERNAME + ' -E -Q"EXEC dbaadmin.dbo.dbasp_create_NXTshare"'
		INSERT INTO #ExecOutput(TextOutput)
		EXEC master.sys.xp_cmdshell @DynamicCode	
	
	
	-- FIX JOB OUTPUTS
	SET @Msg =	'Fix Job Outputs'; 
	PRINT @Msg;
	
	EXEC dbaadmin.dbo.dbasp_FixJobOutput


exec dbaadmin.dbo.dbasp_capture_local_serverenviro

exec dbaadmin.dbo.dbasp_check_SQLhealth


EndCode:



--select * From dbaadmin.dbo.dbaudf_ListDrives()
--select * From dbaadmin.dbo.dbaudf_FileAccess_Dir2('K:\',0,1)

--exec dbaadmin.dbo.dbasp_dba_sqlsetup 'G:\backup'

--exec dbaadmin.dbo.dbasp_check_SQLhealth

--select @@Servername
--
		
		