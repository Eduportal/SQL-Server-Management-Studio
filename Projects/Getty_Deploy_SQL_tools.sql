--	EXEC sys.sp_dropextendedproperty @Name = 'NEWServerDeployStep'
--	SHUTDOWN
/*

	DECLARE @Step INT
	SET		@Step = 2
	IF NOT EXISTS (SELECT value FROM fn_listextendedproperty('NEWServerDeployStep', default, default, default, default, default, default))
		EXEC sys.sp_addextendedproperty @Name = 'NEWServerDeployStep', @value = @Step
	ELSE
		EXEC sys.sp_updateextendedproperty @Name = 'NEWServerDeployStep', @value = @Step
		
*/
	exec dbo.Getty_Deploy_SQL

	USE [master]
	GO
	EXEC sp_configure 'show advanced option', 1;RECONFIGURE WITH OVERRIDE;EXEC sp_configure 'xp_cmdshell', 1;RECONFIGURE WITH OVERRIDE;;EXEC sp_configure 'Ole Automation Procedures', 1;RECONFIGURE WITH OVERRIDE;
	GO

	DECLARE		@TSQL		VarChar(8000)
	IF (OBJECT_ID('tempdb..#ExecOutput')) IS NOT NULL
		DROP TABLE #ExecOutput
	CREATE TABLE	#ExecOutput	([rownum] int identity primary key,[TextOutput] VARCHAR(8000));

	SELECT		@TSQL		= REPLACE(CAST(serverproperty('machinename') AS sysname),'-N','') -- BUILD SERVERNAME
				,@TSQL		= 'SET NOCOUNT ON;SELECT dbaadmin.dbo.dbaudf_ConcatenateUnique(REPLACE(SQLName,servername,'''')) FROM dbacentral.dbo.dba_ServerInfo where ServerName = '''+ @TSQL + ''''
				,@TSQL		= 'sqlcmd -Udbasledridge -PTigger4U -SSEAFRESQLDBA01 -Q"'+@TSQL+'" -w65535 -h-1'
	INSERT INTO	#ExecOutput([TextOutput])
	EXEC		XP_CMDSHELL  @TSQL

	DELETE		#ExecOutput
	WHERE		nullif([TextOutput],'') IS NULL

	SELECT [TextOutput] FROM #ExecOutput



	SELECT @@SERVERNAME [@@ServerName]
			,(SELECT TOP 1 TextOutput FROM master.dbo.ServerDeploymentStatus WHERE nullif(TextOutput,'') IS NOT NULL ORDER BY rownum desc) [LastStatus]
			,(select value FROM fn_listextendedproperty('NEWServerDeployStep', default, default, default, default, default, default)) [NextStep]
			,(SELECT [env_name] FROM [DEPLinfo].[dbo].[enviro_info] WHERE env_type = 'domain')				[Domain]
			,(SELECT [env_name] FROM [DEPLinfo].[dbo].[enviro_info] WHERE env_type = 'ENVnum')				[Enviro]
			,(SELECT [env_name] FROM [DEPLinfo].[dbo].[enviro_info] WHERE env_type = 'SRVname')				[SRVname]
			,(SELECT [env_name] FROM [DEPLinfo].[dbo].[enviro_info] WHERE env_type = 'GearsServer')			[GearsServer]
			,(SELECT [env_name] FROM [DEPLinfo].[dbo].[enviro_info] WHERE env_type = 'BuildcodeServer')		[BuildcodeServer]
			,(SELECT [env_name] FROM [DEPLinfo].[dbo].[enviro_info] WHERE env_type = 'CentralServer')		[CentralServer]
			,(SELECT [env_name] FROM [DEPLinfo].[dbo].[enviro_info] WHERE env_type = 'AutoTestServer')		[AutoTestServer]
			,(SELECT [env_name] FROM [DEPLinfo].[dbo].[enviro_info] WHERE env_type = 'CentralWebServer')	[CentralWebServer]



select * FROM master.dbo.ServerDeploymentStatus

select * FROM master.dbo.ServerDeploymentSummary

/*
-- DROP ALL DEPLOYMENT COMPONENTS
--

USE MASTER
GO
	-- DELETE SCHEDULED TASK TO RESTART SQL EVERY MINUTE
	DECLARE		@DynamicCode	VarChar(8000)
	SELECT		@DynamicCode	= isnull('$'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
				,@DynamicCode	= 'SCHTASKS.EXE /DELETE /TN "RESTART SQL INSTANCE '+REPLACE(@DynamicCode,'$','')+'" /F'

	EXEC	XP_CMDSHELL @DynamicCode, no_output

	EXEC sp_procoption
		@ProcName		= 'master.dbo.dbasp_LogSQLStartup'
		,@OptionName	= 'STARTUP' 
		,@OptionValue	= 'off'
			
IF OBJECT_ID('ServerDeploymentStatus') IS NOT NULL
	DROP TABLE master.dbo.ServerDeploymentStatus
IF OBJECT_ID('ServerDeploymentSummary') IS NOT NULL
	DROP TABLE master.dbo.ServerDeploymentSummary
IF OBJECT_ID('dbasp_CloneDBs') IS NOT NULL
	DROP PROCEDURE dbo.dbasp_CloneDBs
IF OBJECT_ID('dbasp_FileAccess_Write') IS NOT NULL
	DROP PROCEDURE dbo.dbasp_FileAccess_Write
IF OBJECT_ID('dbasp_LogSQLStartup') IS NOT NULL
	DROP PROCEDURE dbo.dbasp_LogSQLStartup
IF OBJECT_ID('dbasp_RestoreDatabase') IS NOT NULL
	DROP PROCEDURE dbo.dbasp_RestoreDatabase
IF OBJECT_ID('dbasp_sp_configure') IS NOT NULL
	DROP PROCEDURE dbo.dbasp_sp_configure
IF OBJECT_ID('Getty_Deploy_SQL') IS NOT NULL
	DROP PROCEDURE dbo.Getty_Deploy_SQL
IF OBJECT_ID('SaveTableAsHTML') IS NOT NULL
	DROP PROCEDURE dbo.SaveTableAsHTML
IF OBJECT_ID('dbaudf_Dir') IS NOT NULL
	DROP FUNCTION dbo.dbaudf_Dir
IF OBJECT_ID('dbaudf_FileAccess_Read') IS NOT NULL
	DROP FUNCTION dbo.dbaudf_FileAccess_Read
IF OBJECT_ID('dbaudf_CPUInfo') IS NOT NULL
	DROP FUNCTION dbo.dbaudf_CPUInfo

*/
--	
--	SELECT * FROM master.dbo.ServerDeploymentStatus	--WHERE @@ServerName = 'FRETMRTSQL02\A' ORDER BY rownum
--	SELECT * FROM master.dbo.ServerDeploymentSummary	--WHERE @@ServerName = 'FRETMRTSQL02\A'
--	
--	exec xp_fixeddrives
--	
--	SELECT @@SERVERNAME,value FROM fn_listextendedproperty('NEWServerDeployStep', default, default, default, default, default, default)
--	
--	
--	SHUTDOWN


/*

	IF (SELECT TOP 1 TextOutput FROM master.dbo.ServerDeploymentStatus WHERE nullif(TextOutput,'') IS NOT NULL ORDER BY rownum desc) = 'WAITING FOR SQL RESTART'
		SELECT @@SERVERNAME
	ELSE
		SELECT	NULL 
		
*/	
	
/*

	IF (SELECT TOP 1 TextOutput FROM dbaadmin.dbo.ServerDeploymentStatus WHERE nullif(TextOutput,'') IS NOT NULL ORDER BY rownum desc) = 'WAITING FOR SQL RESTART'
		SHUTDOWN
		
*/

/*

	exec sp_procoption
		@ProcName		= 'Getty_Deploy_SQL'
		,@OptionName	= 'STARTUP' 
		,@OptionValue	= 'on'
		
*/

--	EXEC sys.sp_dropextendedproperty @Name = 'NEWServerDeployStep'

/*

	DECLARE @Step INT
	SET		@Step = 5
	IF NOT EXISTS (SELECT value FROM fn_listextendedproperty('NEWServerDeployStep', default, default, default, default, default, default))
		EXEC sys.sp_addextendedproperty @Name = 'NEWServerDeployStep', @value = @Step
	ELSE
		EXEC sys.sp_updateextendedproperty @Name = 'NEWServerDeployStep', @value = @Step
		
*/

/*
		DECLARE @DynamicCode VarChar(8000), @ScriptPath VarChar(8000)

	SET		@DynamicCode	= isnull('$'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
	SET		@DynamicCode	= 'SCHTASKS.EXE /DELETE /TN "RESTART SQL INSTANCE '+REPLACE(@DynamicCode,'$','')+'" /F'
	EXEC	XP_CMDSHELL @DynamicCode--, no_output

	
	SET		@DynamicCode	= isnull('$'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
	SET		@DynamicCode	= 'SCHTASKS.EXE /CREATE /SC MINUTE /MO 1 /TN "RESTART SQL INSTANCE '+REPLACE(@DynamicCode,'$','')+'" /ST 00:00:00 /SD 01/01/2000 /TR "C:\RestartSQL'+@DynamicCode+'.cmd" /RU SYSTEM /F'
	EXEC	XP_CMDSHELL @DynamicCode--, no_output

		
		INSERT INTO master.dbo.ServerDeploymentStatus(TextOutput) Values('WAITING FOR SQL RESTART');
		
			SET		@DynamicCode = 'CREATE PROCEDURE [dbo].[dbasp_FileAccess_Write]
				(
				@String			Varchar(max)			--8000 in SQL Server 2000
				,@Path			VARCHAR(4000)
				,@Filename		VARCHAR(1024)	= NULL	-- CAN BE NULL IF PASSING THE FILENAME AS PART OF THE PATH
				,@Append		bit				= 0		-- DEFAULT IS TO OVERWRITE
				)
			as
			SET NOCOUNT ON

			DECLARE		@objFileSystem		int
						,@objTextStream		int
						,@objErrorObject	int
						,@strErrorMessage	Varchar(1024)
						,@Command			varchar(1024)
						,@hr				int
						,@fileAndPath		varchar(1024)
						,@Method			INT
				
			SET			@Method = CASE @Append WHEN 0 THEN 2 ELSE 8 END

			select @strErrorMessage=''opening the File System Object''
			EXECUTE @hr = sp_OACreate  ''Scripting.FileSystemObject'' , @objFileSystem OUT

			Select @FileAndPath=@path+COALESCE(CASE WHEN RIGHT(@Path,1) = ''\'' THEN '''' ELSE ''\'' END+@filename,'''')
			if @HR=0 Select @objErrorObject=@objFileSystem , @strErrorMessage=CASE @Append WHEN 0 THEN ''Creating file "'' ELSE ''Appending file "'' END +@FileAndPath+''"''
			if @HR=0 execute @hr = sp_OAMethod   @objFileSystem,''OpenTextFile'',@objTextStream OUT,@FileAndPath,@Method,True

			if @HR=0 Select @objErrorObject=@objTextStream, 
				@strErrorMessage=''writing to the file "''+@FileAndPath+''"''
			if @HR=0 execute @hr = sp_OAMethod  @objTextStream, ''Write'', Null, @String

			if @HR=0 Select @objErrorObject=@objTextStream, @strErrorMessage=''closing the file "''+@FileAndPath+''"''
			if @HR=0 execute @hr = sp_OAMethod  @objTextStream, ''Close''

			if @hr<>0
				begin
				Declare 
					@Source varchar(1024),
					@Description Varchar(1024),
					@Helpfile Varchar(1024),
					@HelpID int
				
				EXECUTE sp_OAGetErrorInfo  @objErrorObject, 
					@source output,@Description output,@Helpfile output,@HelpID output
				Select @strErrorMessage=''Error whilst ''
						+coalesce(@strErrorMessage,''doing something'')
						+'', ''+coalesce(@Description,'''')
				raiserror (@strErrorMessage,16,1)
				end
			EXECUTE  sp_OADestroy @objTextStream
			EXECUTE sp_OADestroy @objTextStream'
			EXEC(@DynamicCode)
			
		SET		@DynamicCode	= ' '
		SET		@ScriptPath		= 'C:\RestartSQL'+isnull('$'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
		EXEC	[dbo].[dbasp_FileAccess_Write] 
					@DynamicCode
					,@ScriptPath	

	SET		@DynamicCode	= 'If Exist "c:\RestartSQL'+isnull('$'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')+'" (NET STOP MSSQL'+isnull('$'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')+' /YES)'+CHAR(13)+CHAR(10)+'If Exist "c:\RestartSQL'+isnull('$'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')+'" (DEL c:\RestartSQL'+isnull('$'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')+')'+CHAR(13)+CHAR(10)+'NET START SQLAgent'+isnull('$'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
	SET		@ScriptPath		= 'C:\RestartSQL'+isnull('$'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')+'.cmd'
	EXEC	[dbo].[dbasp_FileAccess_Write] 
				@DynamicCode
				,@ScriptPath

	SET		@DynamicCode	= isnull('$'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
	SET		@DynamicCode	= 'SCHTASKS.EXE /RUN /TN "RESTART SQL INSTANCE '+REPLACE(@DynamicCode,'$','')+'"'
	EXEC	XP_CMDSHELL @DynamicCode--, no_output		
	
*/

/*

	IF @@ServerName = 'FRETMRTSQL02\A'
		EXEC dbaadmin.dbo.dbasp_check_SQLhealth @rpt_recipient='steve.ledridge@gettyimages.com'


*/

/*
--
--	SERVER NAME CHANGES
--
DECLARE @OldName sysname, @NewName Sysname
SELECT	@OldName = @@SERVERNAME
		,@NewName = CAST(serverproperty('machinename') AS sysname) + isnull('\'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
		
IF @OldName != @NewName
	BEGIN
		IF EXISTS (SELECT * FROM sys.servers where name = @OldName)
			EXEC sp_dropserver @OldName; 
		IF NOT EXISTS (SELECT * FROM sys.servers where name = @NewName)
			EXEC sp_addserver @NewName, 'local'
		PRINT 'SERVER NAME CHANGED FROM ' +@OldName+ ' TO ' +  @NewName
	END
	ELSE PRINT 'SERVER NAME IS ALREADY SET'
*/



