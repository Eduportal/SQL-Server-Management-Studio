USE DBAADMIN
GO
SET NOCOUNT ON
DECLARE	@Data Table (ServerName sysname)
------------------------------------------------------------------
------------------------------------------------------------------
-- PASTE INSERT LINES HERE
------------------------------------------------------------------
------------------------------------------------------------------
Insert Into @Data									
SELECT		DISTINCT
		[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Server')
FROM		[dbaadmin].[dbo].[Filescan_History] T1
LEFT JOIN	dbo.DBA_ServerInfo T2
	ON	T2.ServerName = T1.Machine
LEFT JOIN	dbo.DBA_ServerInfo T3
	ON	T3.SQLName = T1.Machine + CASE WHEN T1.Instance > '' THEN '\' + T1.Instance ELSE '' END
	
WHERE		EventDateTime >= GetDate()-1
	AND	UPPER(REPLACE(COALESCE(T3.SQLEnv,T2.SQLEnv,'Unknown'),'production','prod')) != 'prod'
	AND	KnownCondition = 'Backup-NoFullExists'
	AND	Machine IN
		(
		SELECT DISTINCT Machine	
		FROM dbo.Filescan_MachineSource
		WHERE Domain =
			'AMER'
			--'STAGE'
			--'PRODUCTION'
		)
Order By	1
------------------------------------------------------------------
------------------------------------------------------------------
-- END OF INSERT LINES HERE
------------------------------------------------------------------
------------------------------------------------------------------
DECLARE @ServerName	sysname
DECLARE @LoginName	sysname
DECLARE	@PrintLine	VarChar(max)
DECLARE ServerCursor	CURSOR
FOR
SELECT	DISTINCT 
	ServerName 
FROM	@Data

OPEN ServerCursor
FETCH NEXT FROM ServerCursor INTO @ServerName
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
	
	SET	@PrintLine = ':CONNECT ' + @ServerName + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
		+ 'USE [master]
GO
DECLARE @Commands VARCHAR(8000)
SET	@Commands = ''''
SELECT	@Commands = @Commands + ''ALTER DATABASE [''+NAME+''] SET RECOVERY SIMPLE WITH NO_WAIT''     +CHAR(13)+CHAR(10)
FROM	sysdatabases
WHERE	name NOT IN (''tempdb'')
EXEC	(@Commands)
GO'
	PRINT	@PrintLine
	END
	FETCH NEXT FROM ServerCursor INTO @ServerName
END
CLOSE ServerCursor
DEALLOCATE ServerCursor



