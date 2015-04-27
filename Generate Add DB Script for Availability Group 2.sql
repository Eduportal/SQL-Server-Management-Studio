--:SETVAR ScriptPath null
:OUT $(TEMP)\SetVars.sql
DECLARE @UID UniqueIdentifier = NEWID()
PRINT ':SETVAR ScriptPath ' + dbaadmin.[dbo].[dbaudf_getShareUNC]('backup') + '\RunAllAdds_'+CAST(@UID AS VarChar(50))+'.sql' 
PRINT ':SETVAR TemplatePath ' + dbaadmin.[dbo].[dbaudf_getShareUNC]('backup') + '\AddDBToAG_'+CAST(@UID AS VarChar(50))+'.sql'
GO
:OUT stdout
:r $(TEMP)\SetVars.sql
GO



PRINT 'Script File Generated: $(ScriptPath)'
PRINT 'Template File Generated: $(TemplatePath)'

DECLARE		@DBName			SYSNAME
		,@SourceServer		SYSNAME		= @@SERVERNAME
		,@DestServer		SYSNAME		= 'ASHPSQLEDW01'
		,@AGroup		SYSNAME		= NULL
		,@ExcludeDBs		VarChar(max)	= 'DataWarehouse_Snapshot_AnalysisServices|ConsolidatedDataWarehouse|DWStage' -- Pipe Delimited Database List
		,@InAG			CHAR(1)
		,@AllDBsJoined		BIT
		,@ScriptOutput		VarChar(max)
		,@TemplateOutput	VarChar(max)
		,@ScriptPath		VarChar(max)	= '$(ScriptPath)'
		,@TemplatePath		VarChar(max)	= '$(TemplatePath)'


SET	@TemplateOutput	= 
':Connect '+CHAR(36)+'(Source)

IF '''+CHAR(36)+'(InAG)'' = ''1''
BEGIN
	RAISERROR (''Database: '+CHAR(36)+'(DBName) is already a part of the Availability Group.'',-1,-1) WITH NOWAIT 
END
ELSE
BEGIN
	RAISERROR (''Adding Database '+CHAR(36)+'(DBName) To the Availability Group.'',-1,-1) WITH NOWAIT
	ALTER AVAILABILITY GROUP ['+CHAR(36)+'(AGroup)] ADD DATABASE ['+CHAR(36)+'(DBName)];
END

DECLARE @AgentJob SYSNAME = ''MAINT - TranLog Backup''
	,@LockCount INT
IF dbaadmin.dbo.[dbaudf_GetJobStatus](@AgentJob) != -2
BEGIN
	--INCREMENT "Lock_TranlogBackups" LOCK
	SELECT @LockCount = dbaadmin.[dbo].[dbaudf_SetEV](''Lock_TranlogBackups'',ISNULL(CAST(dbaadmin.[dbo].[dbaudf_GetEV](''Lock_TranlogBackups'') AS INT),0)+1)

	RAISERROR (''Agent Job: %s is being disabled.'',-1,-1,@AgentJob) WITH NOWAIT 
	EXEC	msdb.dbo.sp_update_job @job_Name=@AgentJob, @enabled=0

	WHILE dbaadmin.dbo.[dbaudf_GetJobStatus](@AgentJob) = 4
	BEGIN
		RAISERROR (''Agent Job: %s is running, Waiting for it to finish.'',-1,-1,@AgentJob) WITH NOWAIT
		WAITFOR DELAY ''00:01:00''
	END
END	

DECLARE @Backup_cmd nvarchar(max)
RAISERROR (''Generating Transaction Log Backup Command on Database '+CHAR(36)+'(DBName).'',-1,-1) WITH NOWAIT
EXEC [dbaadmin].[dbo].[dbasp_format_BackupRestore] 
		@DBName			= '''+CHAR(36)+'(DBName)''
		,@Mode			= ''BL'' 
		,@Verbose		= 0
		,@syntax_out		= @Backup_cmd OUTPUT 
SET  @Backup_cmd = REPLACE(@Backup_cmd,''INSERT INTO'',''--INSERT INTO'')

RAISERROR (''Backing Up Transaction Log on Database '+CHAR(36)+'(DBName).'',-1,-1) WITH NOWAIT
EXEC (@Backup_cmd)
GO

'
+':Connect '+CHAR(36)+'(Dest)

DECLARE @Restore_cmd nvarchar(max)

RAISERROR (''Generating Restore Command for Database '+CHAR(36)+'(DBName).'',-1,-1) WITH NOWAIT
EXEC [dbaadmin].[dbo].[dbasp_format_BackupRestore] 
		@DBName			= '''+CHAR(36)+'(DBName)''
		,@Mode			= ''RD'' 
		,@FromServer		= '''+CHAR(36)+'(Source)''
		,@Verbose		= 0
		,@LeaveNORECOVERY	= 1
		,@syntax_out		= @Restore_cmd OUTPUT 

RAISERROR (''Restoring Database '+CHAR(36)+'(DBName).'',-1,-1) WITH NOWAIT
EXEC (@Restore_cmd)

BEGIN TRY
	RAISERROR (''Setting Database '+CHAR(36)+'(DBName) HADR to Availability Group.'',-1,-1) WITH NOWAIT
	ALTER DATABASE ['+CHAR(36)+'(DBName)] SET HADR AVAILABILITY GROUP = ['+CHAR(36)+'(AGroup)];
END TRY

BEGIN CATCH
	SET @Restore_cmd	= ''''

	RAISERROR (''Generating Restore Command for Database '+CHAR(36)+'(DBName).'',-1,-1) WITH NOWAIT
	EXEC [dbaadmin].[dbo].[dbasp_format_BackupRestore] 
			@DBName			= '''+CHAR(36)+'(DBName)''
			,@Mode			= ''RD'' 
			,@FromServer		= '''+CHAR(36)+'(Source)''
			,@Verbose		= 0
			,@LeaveNORECOVERY	= 1
			,@syntax_out		= @Restore_cmd OUTPUT 

	RAISERROR (''Restoring Database '+CHAR(36)+'(DBName).'',-1,-1) WITH NOWAIT
	EXEC (@Restore_cmd)

	RAISERROR (''Setting Database '+CHAR(36)+'(DBName) HADR to Availability Group.'',-1,-1) WITH NOWAIT
	ALTER DATABASE ['+CHAR(36)+'(DBName)] SET HADR AVAILABILITY GROUP = ['+CHAR(36)+'(AGroup)];
END CATCH
GO

'
+':Connect '+CHAR(36)+'(Source)

DECLARE @AgentJob SYSNAME = ''MAINT - TranLog Backup''
	,@LockCount INT
IF dbaadmin.dbo.[dbaudf_GetJobStatus](@AgentJob) != -2
BEGIN
	--DECREMENT "Lock_TranlogBackups" LOCK
	SELECT @LockCount = dbaadmin.[dbo].[dbaudf_SetEV](''Lock_TranlogBackups'',nullif(ISNULL(CAST(dbaadmin.[dbo].[dbaudf_GetEV](''Lock_TranlogBackups'') AS INT)-1,0),0))


	IF @LockCount IS NULL
	BEGIN
		RAISERROR (''Agent Job: %s is being enabled.'',-1,-1,@AgentJob) WITH NOWAIT
		EXEC	msdb.dbo.sp_update_job @job_Name=@AgentJob, @enabled=1
	END
	ELSE
	BEGIN
		RAISERROR (''Agent Job: %s is Not being enabled because other sessions still have it locked.'',-1,-1,@AgentJob) WITH NOWAIT
	END
END

GO
'
exec dbaadmin.dbo.dbasp_FileAccess_Write @TemplateOutput, @TemplatePath,0,1


IF @AGroup IS NULL
	SELECT		TOP 1
			@AGroup = AG.name
	FROM		master.sys.availability_groups AS AG

DECLARE DBCursor CURSOR
FOR
-- SELECT QUERY FOR CURSOR
SELECT		DB.Name
		,CASE WHEN database_name IS NULL THEN '0' ELSE '1' END [InAG]
		,CASE WHEN COALESCE(MIN(CAST(is_database_joined AS INT)),0) = 0 THEN 0 ELSE 1 END [AllDBsJoined]
FROM		sys.databases db
LEFT JOIN	master.sys.dm_hadr_database_replica_cluster_states AS dbcs
	ON	db.name = dbcs.database_name

WHERE		db.name not in ('master','model','msdb','tempdb','dbaadmin','dbaperf','sqldeploy')
	AND	db.Name not in (SELECT DISTINCT [SplitValue] FROM dbaadmin.dbo.dbaudf_StringToTable(@ExcludeDBs,'|'))
GROUP BY	DB.Name,database_name
ORDER BY	DB.Name 

SET		@ScriptOutput = '--- YOU MUST EXECUTE THE FOLLOWING SCRIPT IN SQLCMD MODE.' +CHAR(13)+CHAR(10)

OPEN DBCursor;
FETCH DBCursor INTO @DBName,@InAG,@AllDBsJoined;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP

		IF @AllDBsJoined = 1
		BEGIN
			RAISERROR ('--Database: %s already has All DB''s Joined to Availability Group.',-1,-1,@DBName) WITH NOWAIT 
			PRINT ''
		END
		ELSE
		BEGIN

			SET	@ScriptOutput = @ScriptOutput + '' +CHAR(13)+CHAR(10)

			SET	@ScriptOutput = @ScriptOutput + ':SETVAR DBName	' + @DBName		+ CHAR(13)+CHAR(10)
			SET	@ScriptOutput = @ScriptOutput + ':SETVAR AGroup	' + @AGroup		+ CHAR(13)+CHAR(10)
			SET	@ScriptOutput = @ScriptOutput + ':SETVAR Source	' + @SourceServer	+ CHAR(13)+CHAR(10)
			SET	@ScriptOutput = @ScriptOutput + ':SETVAR Dest	' + @DestServer		+ CHAR(13)+CHAR(10)
			SET	@ScriptOutput = @ScriptOutput + ':SETVAR InAG	' + @InAG		+ CHAR(13)+CHAR(10)
			SET	@ScriptOutput = @ScriptOutput + ''					+ CHAR(13)+CHAR(10)
			SET	@ScriptOutput = @ScriptOutput + ':R ' + @TemplatePath			+ CHAR(13)+CHAR(10)
			SET	@ScriptOutput = @ScriptOutput + 'GO'					+ CHAR(13)+CHAR(10)
			SET	@ScriptOutput = @ScriptOutput + ''					+ CHAR(13)+CHAR(10)
	
		END
		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM DBCursor INTO @DBName,@InAG,@AllDBsJoined;
END
CLOSE DBCursor;
DEALLOCATE DBCursor;

exec dbaadmin.dbo.dbasp_FileAccess_Write @ScriptOutput, @ScriptPath,0,1

GO

:r $(ScriptPath)
GO