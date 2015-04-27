exec dbo.Getty_Deploy_SQL

	SELECT @@SERVERNAME 

	SELECT TOP 1 TextOutput [LastStatus] FROM dbaadmin.dbo.ServerDeploymentStatus WHERE nullif(TextOutput,'') IS NOT NULL ORDER BY rownum desc

--	SELECT * FROM dbaadmin.dbo.ServerDeploymentStatus	WHERE @@ServerName = 'GINSSQLTEST04-N\A' ORDER BY rownum
--	SELECT * FROM dbaadmin.dbo.ServerDeploymentSummary	WHERE @@ServerName = 'FRETMRTSQL02\A'
--	DROP TABLE dbaadmin.dbo.ServerDeploymentStatus
--	DROP TABLE dbaadmin.dbo.ServerDeploymentSummary
--	exec xp_fixeddrives
--	
--	SELECT @@SERVERNAME,value FROM fn_listextendedproperty('NEWServerDeployStep', default, default, default, default, default, default)
--	
--	
--	SHUTDOWN


/*

	IF (SELECT TOP 1 TextOutput FROM dbaadmin.dbo.ServerDeploymentStatus WHERE nullif(TextOutput,'') IS NOT NULL ORDER BY rownum desc) = 'WAITING FOR SQL RESTART'
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
	-- CREATE SCHEDULED TASK TO RESTART SQL EVERY MINUTE
	DECLARE	@DynamicCode	VarChar(8000)
	SET		@DynamicCode	= isnull('$'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
	SET		@DynamicCode	= 'SCHTASKS.EXE /CREATE /SC MINUTE /MO 1 /TN "RESTART SQL INSTANCE '+REPLACE(@DynamicCode,'$','')+'" /ST 00:00:00 /SD 01/01/2000 /TR "NET START SQLAgent'+@DynamicCode+'" /RU SYSTEM /F'
	EXEC	XP_CMDSHELL @DynamicCode--, no_output
	GO
	
	-- STOP THE SQL SERVICE
	DECLARE	@DynamicCode	VarChar(8000)
	SET		@DynamicCode = 'NET STOP "MSSQL'+ REPLACE('$'+@@SERVICEName,'$MSSQLSERVER','') +'" /Y'
	exec xp_cmdshell @DynamicCode--, no_output
	GO

	-- DELETE SCHEDULED TASK TO RESTART SQL EVERY MINUTE
	DECLARE	@DynamicCode	VarChar(8000)
	SET		@DynamicCode	= isnull('$'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
	SET		@DynamicCode	= 'SCHTASKS.EXE /DELETE /TN "RESTART SQL INSTANCE '+REPLACE(@DynamicCode,'$','')+'" /F'
	EXEC	XP_CMDSHELL @DynamicCode--, no_output
	GO


	IF @@ServerName = 'FRETMRTSQL02\A'
		EXEC dbaadmin.dbo.dbasp_check_SQLhealth @rpt_recipient='steve.ledridge@gettyimages.com'


*/
