

--- YOU MUST EXECUTE THE FOLLOWING SCRIPT IN SQLCMD MODE.

--:SETVAR DBName	iStock_Staging
--:SETVAR Source	SEAPSQLEDW01
--:SETVAR Dest	ASHPSQLEDW01

--:Connect $(Source)

GO
EXEC sp_configure 'remote query timeout', 0 ;
GO
RECONFIGURE ;
GO

DECLARE		@DBName			SYSNAME
		,@SourceServer		SYSNAME		= @@SERVERNAME
		,@DestServer		SYSNAME		= 'ASHPSQLEDW01'
		,@AGroup		SYSNAME		= NULL
		,@ExcludeDBs		VarChar(max) = 'Datawarehouse|ConsolidatedDataWarehouse|Controller|EnterpriseDataWarehouse|DownloadDataMart|DWStage' -- Pipe Delimited Database List
		,@InAG			BIT
		,@AllDBsJoined		BIT
		,@AgentJob		SYSNAME
		,@Backup_cmd		nvarchar(max)
		,@Restore_cmd		nvarchar(max)

SET		@AgentJob		= 'MAINT - TranLog Backup'


	-- ADD DYNAMIC LINKED SERVER
	IF  EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = N'DYN_DBA_RMT')
		EXEC ('master.dbo.sp_dropserver @server=N''DYN_DBA_RMT'', @droplogins=''droplogins''')
  
	EXEC ('sp_addlinkedserver @server=''DYN_DBA_RMT'',@srvproduct='''',@provider=''SQLNCLI'',@datasrc='''+@DestServer+'''')
	EXEC ('master.dbo.sp_serveroption @server=N''DYN_DBA_RMT'', @optname=N''rpc'', @optvalue=N''true''')
	EXEC ('master.dbo.sp_serveroption @server=N''DYN_DBA_RMT'', @optname=N''rpc out'', @optvalue=N''true''')
	EXEC ('master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N''DYN_DBA_RMT'',@useself=N''True'',@locallogin=NULL,@rmtuser=''DBAsledridge'',@rmtpassword=''Tigger4U''')
	EXEC ('master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N''DYN_DBA_RMT'',@useself=N''False'',@locallogin=N''DBAsledridge'',@rmtuser=''DBAsledridge'',@rmtpassword=''Tigger4U''')
--	EXEC ('master.dbo.sp_addlinkedsrvlogin ''DYN_DBA_RMT'',''True''')

IF @AGroup IS NULL
	SELECT		TOP 1
			@AGroup = AG.name
	FROM		master.sys.availability_groups AS AG

DECLARE DBCursor CURSOR
FOR
-- SELECT QUERY FOR CURSOR
SELECT		DB.Name
		,CASE WHEN database_name IS NULL THEN 0 ELSE 1 END [InAG]
		,CASE WHEN COALESCE(MIN(CAST(is_database_joined AS INT)),0) = 0 THEN 0 ELSE 1 END [AllDBsJoined]
FROM		sys.databases db
LEFT JOIN	master.sys.dm_hadr_database_replica_cluster_states AS dbcs
	ON	db.name = dbcs.database_name

WHERE		db.name not in ('master','model','msdb','tempdb','dbaadmin','dbaperf','sqldeploy')
	AND	db.Name not in (SELECT DISTINCT [SplitValue] FROM dbaadmin.dbo.dbaudf_StringToTable(@ExcludeDBs,'|'))
GROUP BY	DB.Name,database_name
ORDER BY	DB.Name 

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
			RAISERROR ('Database: %s already has All DB''s Joined to Availability Group.',-1,-1,@DBName) WITH NOWAIT 
		END
		ELSE
		BEGIN

			IF @InAG = 1
			BEGIN
				RAISERROR ('Database: %s is already a part of the Availability Group.',-1,-1,@DBName) WITH NOWAIT 
			END
			ELSE
			BEGIN
				RAISERROR ('Adding Database %s To the Availability Group.',-1,-1,@DBName) WITH NOWAIT
				EXEC ('ALTER AVAILABILITY GROUP ['+@AGroup+'] ADD DATABASE ['+@DBName+'];')
			END

			IF dbaadmin.dbo.[dbaudf_GetJobStatus](@AgentJob) != -2
			BEGIN
				RAISERROR ('Agent Job: %s is being disabled.',-1,-1,@AgentJob) WITH NOWAIT 
				EXEC	msdb.dbo.sp_update_job @job_Name=@AgentJob, @enabled=0

				WHILE dbaadmin.dbo.[dbaudf_GetJobStatus](@AgentJob) = 4
				BEGIN
					RAISERROR ('Agent Job: %s is running, Waiting for it to finish.',-1,-1,@AgentJob) WITH NOWAIT
					WAITFOR DELAY '00:01:00'
				END
			END	

			RAISERROR ('Backing Up Transaction Log on Database %s).',-1,-1,@DBName) WITH NOWAIT
			EXEC [dbaadmin].[dbo].[dbasp_format_BackupRestore] 
				       @DBName		= @DBName
				      ,@Mode		= 'BL' 
				      ,@Verbose		= 0
				      ,@syntax_out	= @Backup_cmd OUTPUT 
			SET  @Backup_cmd = REPLACE(@Backup_cmd,'INSERT INTO','--INSERT INTO')
			EXEC (@Backup_cmd)

			RAISERROR ('Restoring Database %s.',-1,-1,@DBName) WITH NOWAIT
			
			SET @Restore_cmd	= '
			DECLARE @Restore_cmd nvarchar(max)
			EXEC [dbaadmin].[dbo].[dbasp_format_BackupRestore] 
				       @DBName		= '''+@DBName+'''
				      ,@Mode		= ''RD'' 
				      ,@FromServer	= '''+@SourceServer+'''
				      ,@Verbose		= 0
				      ,@FullReset	= 1 
				      ,@LeaveNORECOVERY = 1
				      ,@syntax_out	= @Restore_cmd OUTPUT 
			EXEC (@Restore_cmd)'
			EXEC (@Restore_cmd) AT [DYN_DBA_RMT]

			SET @Restore_cmd	= '
			DECLARE @Restore_cmd nvarchar(max)
			EXEC [dbaadmin].[dbo].[dbasp_format_BackupRestore] 
				       @DBName		= '''+@DBName+'''
				      ,@Mode		= ''RD'' 
				      ,@FromServer	= '''+@SourceServer+'''
				      ,@Verbose		= 0
				      ,@LeaveNORECOVERY = 1
				      ,@syntax_out	= @Restore_cmd OUTPUT 
			EXEC (@Restore_cmd)'
			EXEC (@Restore_cmd) AT [DYN_DBA_RMT]

			RAISERROR ('Setting Database %s HADR to Availability Group.',-1,-1,@DBName) WITH NOWAIT
			EXEC ('ALTER DATABASE ['+@DBName+'] SET HADR AVAILABILITY GROUP = ['+@AGroup+']') AT [DYN_DBA_RMT]

			IF dbaadmin.dbo.[dbaudf_GetJobStatus](@AgentJob) != -2
			BEGIN
				RAISERROR ('Agent Job: %s is being enabled.',-1,-1,@AgentJob) WITH NOWAIT
				EXEC	msdb.dbo.sp_update_job @job_Name=@AgentJob, @enabled=1
			END
	
		END
		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM DBCursor INTO @DBName,@InAG,@AllDBsJoined;
END
CLOSE DBCursor;
DEALLOCATE DBCursor;
GO
