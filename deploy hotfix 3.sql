

IF OBJECT_ID('tempdb..#Output')	IS NOT NULL	DROP TABLE #Output
IF OBJECT_ID('tempdb..#REG')	IS NOT NULL	DROP TABLE #REG

CREATE TABLE #Output	(line VarChar(8000))
CREATE TABLE #REG	(App VarChar(1000))

DECLARE		@SP		VarChar(8000)
		,@Flags		int
		,@Script	VarChar(8000)
		,@Domain	VarChar(50)
		,@SQLEnv	VarChar(50)


SELECT		@Script = CASE DomainName
				WHEN 'STAGE' THEN '"\\SEASDBASQL01\SEASDBASQL01_builds'
				WHEN 'PRODUCTION' THEN '"\\seapdbasql02\SEAPDBASQL02_builds'
				ELSE '"\\seapdbasql01\builds' 
				END
		,@Domain = DomainName
		,@SQLEnv = SQLEnv
FROM		dbaadmin.dbo.DBA_ServerInfo
WHERE		SQLName = @@SERVERNAME


IF @@Version Like '%(x64)%'
	SET @Script = @Script + '\WindowsServer2003.WindowsXP-KB932370-v3-x64-ENU.exe" /Z /U /O'
ELSE
	SET @Script = @Script + '\WindowsServer2003-KB932370-v3-x86-ENU.exe" /Z /U /O'

EXEC xp_regread
	'HKEY_LOCAL_MACHINE'
	,N'SOFTWARE\Microsoft\Updates\UpdateExeVolatile'
	,N'Flags'
	,@Flags OUT;

INSERT INTO #REG
EXEC xp_regenumkeys N'HKEY_LOCAL_MACHINE',N'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';

SELECT		@SP = App
FROM		#REG
WHERE		App Like '%KB932370%'

SELECT @Flags [Flags],@SP [SP],@Domain [Domain],@SQLEnv [SQLEnv],@Script [Script]

--if @SP IS NULL
--	exec xp_cmdshell @Script

--if @Flags IS NOT NULL AND @SQLEnv != 'production'
--BEGIN
--	raiserror ('RESTARTING SERVER TO APPLY HOTFIX : %s:%s:%s',-1,-1,@Domain,@SQLEnv,@@SERVERNAME) WITH NOWAIT
--	exec xp_cmdshell 'Shutdown /r /c "Restart to Apply Hotfix" /d P:02:17 /t 30 /f'
--END


GO
-- xp_cmdshell 'kill msinfo32.exe'