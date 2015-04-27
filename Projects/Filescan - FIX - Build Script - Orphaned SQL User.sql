USE dbacentral
GO
SET NOCOUNT ON
DECLARE	@Data Table (LoginName sysname,DBName sysname, ServerName sysname)
------------------------------------------------------------------
------------------------------------------------------------------
-- PASTE INSERT LINES HERE
------------------------------------------------------------------
------------------------------------------------------------------
Insert Into @Data									
SELECT		DISTINCT
		[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','User')
		,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Database')
		,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Server')
FROM		[dbacentral].[dbo].[Filescan_History]     WITH(NOLOCK)
WHERE		EventDateTime >= GetDate()-1
	AND	KnownCondition = 'User-Orphaned'
	AND	[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','User') != 'MS_DataCollectorInternalUser'
	AND	Machine IN
		(
		SELECT DISTINCT Machine	
		FROM [dbacentral].dbo.Filescan_MachineSource
		WHERE Domain =
			'AMER'
			--'STAGE'
			--'PRODUCTION'
		)
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
		
		If	@LoginName = 'dbo'
		  SET	@Printline = @PrintLine + 'EXEC sp_changedbowner ''sa''' + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10)
		ELSE
		  SET	@Printline = @PrintLine + 'EXEC sp_change_users_login ''Update_One'', ''' + @LoginName + ''' , ''' + @LoginName + '''' + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10)
					+ 'If EXISTS (SELECT 1 from sysusers' + CHAR(13) + CHAR(10)
					+ 'where (sid is not null and sid <> 0x0)' + CHAR(13) + CHAR(10)
					+ 'and   suser_sname(sid) is null' + CHAR(13) + CHAR(10)
					+ 'and   name = ''' + @LoginName + ''')' + CHAR(13) + CHAR(10)
					+ 'IF LTRIM(RTRIM(REPLACE(CAST(LEFT(@@version,26)AS VarChar(30)),''Microsoft SQL Server'',''''))) = ''2000''' + CHAR(13) + CHAR(10)
					+ '	EXEC sp_dropuser ''' + @LoginName + '''' + CHAR(13) + CHAR(10)
					+ 'Else' + CHAR(13) + CHAR(10)
					+ '	EXEC (''DROP USER [' + @LoginName + ']'')' + CHAR(13) + CHAR(10) 
					+ 'GO' + CHAR(13) + CHAR(10)
		PRINT	@PrintLine
		PRINT	''
		PRINT	''
		
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



