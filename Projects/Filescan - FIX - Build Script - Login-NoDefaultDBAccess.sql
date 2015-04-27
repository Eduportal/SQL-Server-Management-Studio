USE DBAADMIN
GO
SET NOCOUNT ON
DECLARE	@Data Table (LoginName sysname,DBName sysname, ServerName sysname)
------------------------------------------------------------------
------------------------------------------------------------------
-- PASTE INSERT LINES HERE
------------------------------------------------------------------
------------------------------------------------------------------
INSERT INTO	@Data
SELECT		DISTINCT
		[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Login')
		,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Database')
		,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Server')
FROM		[dbacentral].[dbo].[Filescan_History] T1   WITH(NOLOCK)
WHERE		EventDateTime >= GetDate()-1
	AND	KnownCondition = 'Login-NoDefaultDBAccess'
Order By	3,2,1
------------------------------------------------------------------
------------------------------------------------------------------
-- END OF INSERT LINES HERE
------------------------------------------------------------------
------------------------------------------------------------------
DECLARE @ServerName	sysname
DECLARE @DBName		sysname
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
	PRINT	@PrintLine

	DECLARE LoginCursor	CURSOR
	FOR
	SELECT	DISTINCT 
		LoginName
		,DBName 
	FROM	@Data
	WHERE	ServerName = @ServerName

	OPEN LoginCursor
	FETCH NEXT FROM LoginCursor INTO @LoginName,@DBName
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
		
		SET	@PrintLine = 'USE [' + @DBName + ']' + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10)
			+ 'DECLARE @TSQL VarChar(8000)' + CHAR(13) + CHAR(10)
			+ 'IF SUBSTRING(@@version,23,4) = ''2000''' + CHAR(13) + CHAR(10)
			+ ' SET @TSQL = ''exec sp_adduser ''''' + @LoginName + '''''''' + CHAR(13) + CHAR(10)
			+ 'ELSE' + CHAR(13) + CHAR(10)
			+ ' SET @TSQL = ''CREATE USER [' + @LoginName + '] FOR LOGIN [' + @LoginName + ']''' + CHAR(13) + CHAR(10)
			+ 'EXEC (@TSQL)' + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10)
			+ 'EXEC sp_change_users_login ''Update_One'', ''' + @LoginName + ''' , ''' + @LoginName + '''' + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10)
			PRINT	@PrintLine
		END
		FETCH NEXT FROM LoginCursor INTO @LoginName,@DBName
	END
	CLOSE LoginCursor
	DEALLOCATE LoginCursor

	END
	FETCH NEXT FROM ServerCursor INTO @ServerName
END
CLOSE ServerCursor
DEALLOCATE ServerCursor



