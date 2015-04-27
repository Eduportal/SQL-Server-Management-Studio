USE DBAADMIN
GO

SET NOCOUNT ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET NUMERIC_ROUNDABORT OFF

DECLARE @RC			INT
DECLARE	@DBName		sysname
DECLARE @COMMAND	VarChar(8000)
DECLARE @ScriptPath VarChar(max)
DECLARE	@cEGUID		varChar(50)
DECLARE @ID			UniqueIdentifier

SET		@ID			= NEWID()
SET		@DBName		= ''

IF NOT EXISTS (SELECT value FROM fn_listextendedproperty('DEPLInstanceID', default, default, default, default, default, default))
BEGIN
	EXEC sys.sp_addextendedproperty @Name = 'DEPLInstanceID', @value = @ID
	SET @cEGUID = CAST(@ID as VarChar(50))

	EXECUTE [DBAadmin].[dbo].[dbasp_LogEvent] 
		@cEGUID = @cEGUID,@cERE_ForceScreen = 1,@cEMethod_Screen = 1,@cEMethod_TableLocal = 1
		,@cEModule		= 'DDL Audit'
		,@cECategory	= 'Deploy'
		,@cEEvent		= 'Add Extended Property'
		,@cEMessage		= 'DEPLInstanceID'
END
ELSE
BEGIN
	IF (SELECT COALESCE(value,'') FROM fn_listextendedproperty('DEPLInstanceID', default, default, default, default, default, default)) = ''
	BEGIN
		EXEC sys.sp_updateextendedproperty	@Name = 'DEPLInstanceID', @value = @ID
		SET @cEGUID = CAST(@ID as VarChar(50))
				
		EXECUTE [DBAadmin].[dbo].[dbasp_LogEvent] 
			@cEGUID = @cEGUID,@cERE_ForceScreen = 1,@cEMethod_Screen = 1,@cEMethod_TableLocal = 1
			,@cEModule		= 'DDL Audit'
			,@cECategory	= 'Deploy'
			,@cEEvent		= 'Update Extended Property'
			,@cEMessage		= 'DEPLInstanceID'
	END
	ELSE
	BEGIN
		SELECT @cEGUID = CAST(Value as VarChar(50)) FROM fn_listextendedproperty('DEPLInstanceID', default, default, default, default, default, default)

		EXECUTE [DBAadmin].[dbo].[dbasp_LogEvent] 
			@cEGUID = @cEGUID,@cERE_ForceScreen = 1,@cEMethod_Screen = 1,@cEMethod_TableLocal = 1
			,@cEModule		= 'DDL Audit'
			,@cECategory	= 'Deploy'
			,@cEEvent		= 'Use Current Extended Property'
			,@cEMessage		= 'DEPLInstanceID'
	END
END

BEGIN

	-- LOG START DEPLOY
	EXECUTE [DBAadmin].[dbo].[dbasp_LogEvent] 
		@cEGUID = @cEGUID,@cERE_ForceScreen = 1,@cEMethod_Screen = 1,@cEMethod_TableLocal = 1
		,@cEModule		= 'DDL Audit'
		,@cECategory	= 'Deploy'
		,@cEEvent		= 'Start'
		,@cEMessage		= @DBName
		
	--DEPLOY TABLE
	SELECT	@ScriptPath	= '\\seafresqldba01\DBA_Docs\SourceCode\DDL_AUDIT\BuildSchemaChanges.sql'
			,@COMMAND	= 'sqlcmd -S' + @@servername + ' -d' + @DBName + ' -u -I -E -b -i' + @ScriptPath 
	EXEC	@RC			= master.sys.xp_cmdshell @COMMAND

	--DEPLOY TRIGGER
	SELECT	@ScriptPath	= '\\seafresqldba01\DBA_Docs\SourceCode\DDL_AUDIT\tr_AuditDDLChange.sql'
			,@COMMAND	= 'sqlcmd -S' + @@servername + ' -d' + @DBName + ' -u -I -E -b -i' + @ScriptPath 
	EXEC	@RC			= master.sys.xp_cmdshell @COMMAND
	
	-- LOG COMPLETE DEPLOY
	EXECUTE [DBAadmin].[dbo].[dbasp_LogEvent] 
		@cEGUID = @cEGUID,@cERE_ForceScreen = 1,@cEMethod_Screen = 1,@cEMethod_TableLocal = 1
		,@cEModule		= 'DDL Audit'
		,@cECategory	= 'Deploy'
		,@cEEvent		= 'Complete'
		,@cEMessage		= @DBName	

END


IF @cEGUID = @ID
	EXEC sys.sp_updateextendedproperty	@Name = 'DEPLInstanceID', @value = ''
