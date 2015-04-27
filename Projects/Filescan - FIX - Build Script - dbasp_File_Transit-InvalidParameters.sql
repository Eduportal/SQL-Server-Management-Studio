USE DBAADMIN
GO
SET NOCOUNT ON
DECLARE	@Data Table (ServerName sysname)
------------------------------------------------------------------
------------------------------------------------------------------
-- PASTE INSERT LINES HERE
------------------------------------------------------------------
------------------------------------------------------------------
INSERT INTO	@Data
SELECT		DISTINCT
		[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Server')
FROM		[dbaadmin].[dbo].[Filescan_History] T1   WITH(NOLOCK)
WHERE		EventDateTime >= GetDate()-1
	AND	KnownCondition = 'dbasp_File_Transit-InvalidParameters'
Order By	1
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

	PRINT	''
	SET	@PrintLine = '--FIX SCRIPT NOT DEFINED' 
	PRINT	@PrintLine
	PRINT	''
	PRINT	'GO'
	PRINT	''
	PRINT	''

	END
	FETCH NEXT FROM ServerCursor INTO @ServerName
END
CLOSE ServerCursor
DEALLOCATE ServerCursor



