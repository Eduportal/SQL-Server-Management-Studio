SET NOCOUNT ON
DECLARE	@Data Table (ServerName sysname,JobName sysname)
------------------------------------------------------------------
------------------------------------------------------------------
-- PASTE INSERT LINES HERE
------------------------------------------------------------------
------------------------------------------------------------------
INSERT INTO	@Data
SELECT		DISTINCT
		[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Server')
		,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Job')
		--,Message
		--,*
FROM		[dbaadmin].[dbo].[Filescan_History] T1   WITH(NOLOCK)
WHERE		EventDateTime >= GetDate()-1
	AND	KnownCondition = 'AgentJob-LongRunning'
Order By	1,2
------------------------------------------------------------------
------------------------------------------------------------------
-- END OF INSERT LINES HERE
------------------------------------------------------------------
------------------------------------------------------------------
DECLARE @ServerName	sysname
DECLARE @JobName	sysname
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

	DECLARE DBCursor	CURSOR
	FOR
	SELECT	DISTINCT 
		JobName 
	FROM	@Data
	WHERE	ServerName = @ServerName

	OPEN DBCursor
	FETCH NEXT FROM DBCursor INTO @JobName
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			PRINT	''
			SET	@PrintLine = '--FIX SCRIPT NOT DEFINED   JobName = ' + @JobName
			PRINT	@PrintLine

		END
		FETCH NEXT FROM DBCursor INTO @JobName

		PRINT	''
		PRINT	'GO'
		PRINT	''
		PRINT	''
	END
	CLOSE DBCursor
	DEALLOCATE DBCursor

	END
	FETCH NEXT FROM ServerCursor INTO @ServerName
END
CLOSE ServerCursor
DEALLOCATE ServerCursor



