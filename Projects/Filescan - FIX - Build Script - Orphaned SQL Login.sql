USE dbacentral
GO
SET NOCOUNT ON
DECLARE	@Data Table (ServerName sysname,LoginName sysname)
------------------------------------------------------------------
------------------------------------------------------------------
-- PASTE INSERT LINES HERE
------------------------------------------------------------------
------------------------------------------------------------------
Insert Into @Data									
SELECT		DISTINCT
		[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Server')
		,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Login')
FROM		[dbacentral].[dbo].[Filescan_History]
WHERE		EventDateTime >= GetDate()-1
	AND	KnownCondition = 'Login-Orphaned'
	AND	Machine IN
		(
		SELECT DISTINCT Machine	
		FROM [dbacentral].dbo.Filescan_MachineSource
		WHERE Domain =
			'AMER'
			--'STAGE'
			--'PRODUCTION'
		)
Order By	1,2
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
		+ 'USE MASTER
GO
DECLARE	@PrintLine	VarChar(8000)
SET	@PrintLine	= ''Server		:'' + @@SERVERNAME
PRINT	(@PrintLine)
SET	@PrintLine	= ''SQL VERSION	:'' + LTRIM(RTRIM(REPLACE(CAST(LEFT(@@version,26)AS VarChar(30)),''Microsoft SQL Server'','''')))
PRINT	(@PrintLine)
GO
CREATE PROCEDURE #RemoveOrphan
(@LoginName	sysname)
AS
DECLARE @PrintLine	VarChar(8000)
DECLARE	@TSQL		VarChar(8000)
SET	@PrintLine	= ''Login		:'' + @LoginName
PRINT	(@PrintLine)
IF LTRIM(RTRIM(REPLACE(CAST(LEFT(@@version,26)AS VarChar(30)),''Microsoft SQL Server'',''''))) = ''2000''
 GOTO DropLogin
'
PRINT	@PrintLine
SET	@PrintLine =
' 

/**************************************************************
REASSIGN OWNED ASSEMBLIES TO DBO
**************************************************************/
SET	@TSQL		= 
''USE [?];
DECLARE @cmd nvarchar(500)
DECLARE @name sysname
DECLARE ChangeOwner_Cursor CURSOR
FOR
SELECT	QUOTENAME(A.name) name
from		sys.assemblies A
INNER JOIN	sys.database_principals DP
	ON	A.Principal_id = DP.Principal_id
where		DP.name = '''''' + @LoginName + ''''''
OPEN ChangeOwner_Cursor
FETCH NEXT FROM ChangeOwner_Cursor INTO @name
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET @cmd = ''''ALTER AUTHORIZATION ON Assembly::'''' + @name + '''' TO dbo;''''
		PRINT (@cmd)
		EXEC (@cmd)
		If @@Error = 0 
		    PRINT ''''		  -- Successfull''''
		ELSE
		   begin
			SET @cmd = ''''DBA WARNING: '''' + @cmd
			raiserror(@cmd,-1,-1)
		   end	    
	END
	FETCH NEXT FROM ChangeOwner_Cursor INTO @name
END
CLOSE ChangeOwner_Cursor
DEALLOCATE ChangeOwner_Cursor''
exec sp_msForEachDB @TSQL
SET	@PrintLine	= ''		  -- Assemblies Done''
PRINT	(@PrintLine)
'
PRINT	@PrintLine
SET	@PrintLine =
' 

/**************************************************************
REASSIGN OWNED SCHEMAS TO DBO
**************************************************************/
SET	@TSQL		= 
''USE [?];
DECLARE @cmd nvarchar(500)
DECLARE @name sysname
DECLARE ChangeOwner_Cursor CURSOR
FOR
SELECT		QUOTENAME(S.name) name
FROM		[?].sys.schemas S
INNER JOIN	sys.database_principals DP
	ON	S.Principal_id = DP.Principal_id
where		DP.name = '''''' + @LoginName + ''''''
OPEN ChangeOwner_Cursor
FETCH NEXT FROM ChangeOwner_Cursor INTO @name
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET @cmd = ''''ALTER AUTHORIZATION ON SCHEMA::'''' + @name + '''' TO dbo;''''
		PRINT (@cmd)
		EXEC (@cmd)
		If @@Error = 0 
		    PRINT ''''		  -- Successfull''''
		ELSE
		   begin
			SET @cmd = ''''DBA WARNING: '''' + @cmd
			raiserror(@cmd,-1,-1)
		   end	    
	END
	FETCH NEXT FROM ChangeOwner_Cursor INTO @name
END
CLOSE ChangeOwner_Cursor
DEALLOCATE ChangeOwner_Cursor''
exec sp_msForEachDB @TSQL
SET	@PrintLine	= ''		  -- Schemas Done''
PRINT	(@PrintLine)
'
PRINT	@PrintLine
SET	@PrintLine =
' 

/**************************************************************
REASSIGN OWNED ROLES TO DBO
**************************************************************/
SET	@TSQL		= 
''USE [?];
DECLARE @cmd nvarchar(500)
DECLARE @name sysname
DECLARE ChangeOwner_Cursor CURSOR
FOR
SELECT		QUOTENAME(DP1.name) name
FROM		[?].sys.database_principals DP1
INNER JOIN	sys.database_principals DP2
	ON	DP1.owning_principal_id = DP2.Principal_id
where		DP2.name = '''''' + @LoginName + ''''''
	AND	DP1.is_fixed_role = 0 
	AND	DP1.type = ''''R'''' 
OPEN ChangeOwner_Cursor
FETCH NEXT FROM ChangeOwner_Cursor INTO @name
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET @cmd = ''''ALTER AUTHORIZATION ON ROLE::'''' + @name + '''' TO dbo;''''
		PRINT (@cmd)
		EXEC (@cmd)
		If @@Error = 0 
		    PRINT ''''		  -- Successfull''''
		ELSE
		   begin
			SET @cmd = ''''DBA WARNING: '''' + @cmd
			raiserror(@cmd,-1,-1)
		   end	    
	END
	FETCH NEXT FROM ChangeOwner_Cursor INTO @name
END
CLOSE ChangeOwner_Cursor
DEALLOCATE ChangeOwner_Cursor''
exec sp_msForEachDB @TSQL
SET	@PrintLine	= ''		  -- Roles Done''
PRINT	(@PrintLine)
'
PRINT	@PrintLine
SET	@PrintLine =
' 

/**************************************************************
DROP USER IN EACH DB
**************************************************************/
SET	@TSQL		= 
''USE [?];
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'''''' + @LoginName + '''''')
DROP USER ['' + @LoginName + '']''
exec sp_msForEachDB @TSQL
SET	@PrintLine	= ''		  -- Users Done''
PRINT	(@PrintLine)

/**************************************************************
DROP LOGIN ON SERVER
**************************************************************/
DropLogin:
IF LTRIM(RTRIM(REPLACE(CAST(LEFT(@@version,26)AS VarChar(30)),''Microsoft SQL Server'',''''))) = ''2000''
	SET	@TSQL		= ''exec sp_revokelogin '''''' + @LoginName + ''''''''
ELSE
	SET	@TSQL		= 
''IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'''''' + @LoginName + '''''')
DROP LOGIN ['' + @LoginName + '']''
exec	(@TSQL)
SET	@PrintLine	= ''		  -- Login Done''
PRINT	(@PrintLine)
GO'
	PRINT	@PrintLine

	DECLARE LoginCursor	CURSOR
	FOR
	SELECT	DISTINCT 
		LoginName
	FROM	@Data
	WHERE	ServerName = @ServerName

	OPEN LoginCursor
	FETCH NEXT FROM LoginCursor INTO @LoginName
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
		
		SET	@PrintLine = 'EXEC #RemoveOrphan '''+@LoginName+'''
GO'
			PRINT	@PrintLine
		END
		FETCH NEXT FROM LoginCursor INTO @LoginName
	END
	CLOSE LoginCursor
	DEALLOCATE LoginCursor

	SET	@PrintLine = 'DROP PROCEDURE #RemoveOrphan
GO'
	PRINT	@PrintLine

	END
	FETCH NEXT FROM ServerCursor INTO @ServerName
END
CLOSE ServerCursor
DEALLOCATE ServerCursor



