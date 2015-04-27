

--- YOU MUST EXECUTE THE FOLLOWING SCRIPT IN SQLCMD MODE.

:SETVAR DBName	User_Security
:SETVAR AGroup	SQLEDWA
:SETVAR Source	SEAPSQLEDW01
:SETVAR Dest	ASHPSQLEDW01
:SETVAR InAG	0

:Connect $(Source)


IF '$(InAG)' = '1'
BEGIN
	RAISERROR ('Database: $(DBName) is already a part of the Availability Group.',-1,-1) WITH NOWAIT 
END
ELSE
BEGIN
	RAISERROR ('Adding Database $(DBName) To the Availability Group.',-1,-1) WITH NOWAIT
	ALTER AVAILABILITY GROUP [$(AGroup)] ADD DATABASE [$(DBName)];
END

DECLARE @AgentJob SYSNAME = 'MAINT - TranLog Backup'
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

DECLARE @Backup_cmd nvarchar(max)
RAISERROR ('Backing Up Transaction Log on Database $(DBName)).',-1,-1) WITH NOWAIT
EXEC [dbaadmin].[dbo].[dbasp_format_BackupRestore] 
		@DBName			= '$(DBName)'
		,@Mode			= 'BL' 
		,@Verbose		= 0
		,@syntax_out		= @Backup_cmd OUTPUT 
SET  @Backup_cmd = REPLACE(@Backup_cmd,'INSERT INTO','--INSERT INTO')
EXEC (@Backup_cmd)
GO


:Connect $(Dest)

DECLARE @Restore_cmd nvarchar(max)
RAISERROR ('Restoring Database $(DBName).',-1,-1) WITH NOWAIT
EXEC [dbaadmin].[dbo].[dbasp_format_BackupRestore] 
		@DBName			= '$(DBName)'
		,@Mode			= 'RD' 
		,@FromServer		= '$(Source)'
		,@Verbose		= 0
		,@FullReset		= 1 
		,@LeaveNORECOVERY	= 1
		,@syntax_out		= @Restore_cmd OUTPUT 
EXEC (@Restore_cmd)

SET @Restore_cmd	= ''

RAISERROR ('Restoring Database $(DBName).',-1,-1) WITH NOWAIT
EXEC [dbaadmin].[dbo].[dbasp_format_BackupRestore] 
		@DBName			= '$(DBName)'
		,@Mode			= 'RD' 
		,@FromServer		= '$(Source)'
		,@Verbose		= 0
		,@LeaveNORECOVERY	= 1
		,@syntax_out		= @Restore_cmd OUTPUT 
EXEC (@Restore_cmd)

RAISERROR ('Setting Database $(DBName) HADR to Availability Group.',-1,-1) WITH NOWAIT
ALTER DATABASE [$(DBName)] SET HADR AVAILABILITY GROUP = [$(AGroup)];
GO

:Connect $(Source)

DECLARE @AgentJob SYSNAME = 'MAINT - TranLog Backup'
IF dbaadmin.dbo.[dbaudf_GetJobStatus](@AgentJob) != -2
BEGIN
	RAISERROR ('Agent Job: %s is being enabled.',-1,-1,@AgentJob) WITH NOWAIT
	EXEC	msdb.dbo.sp_update_job @job_Name=@AgentJob, @enabled=1
END

GO

