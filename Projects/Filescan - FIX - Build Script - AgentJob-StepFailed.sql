

SET NOCOUNT ON
DECLARE	@Data Table (ServerName sysname,JobName sysname, StepName sysname)
------------------------------------------------------------------
------------------------------------------------------------------
-- PASTE INSERT LINES HERE
------------------------------------------------------------------
------------------------------------------------------------------
INSERT INTO	@Data
SELECT		DISTINCT
		[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Server')
		,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Job')
		,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Step')
		--,Message
		--,*
FROM		[dbacentral].[dbo].[Filescan_History] T1   WITH(NOLOCK)
WHERE		EventDateTime >= GetDate()-1
	AND	KnownCondition = 'AgentJob-StepFailed'
Order By	1,2,3
------------------------------------------------------------------
------------------------------------------------------------------
-- END OF INSERT LINES HERE
------------------------------------------------------------------
------------------------------------------------------------------
DECLARE @ServerName	sysname
DECLARE @JobName	sysname
DECLARE	@StepName	sysname
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
	
	DECLARE DBCursor	CURSOR
	FOR
	SELECT	DISTINCT 
		JobName
		,StepName 
	FROM	@Data
	WHERE	ServerName = @ServerName

	OPEN DBCursor
	FETCH NEXT FROM DBCursor INTO @JobName,@StepName
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			
			SET	@PrintLine = '--FIX SCRIPT NOT DEFINED   JobName = ' + @JobName	 + ', StepName = ' + @StepName
			PRINT	@PrintLine

		END
		FETCH NEXT FROM DBCursor INTO @JobName,@StepName
	END
	CLOSE DBCursor
	DEALLOCATE DBCursor

	END
	FETCH NEXT FROM ServerCursor INTO @ServerName
	PRINT	''
	PRINT	'GO'
	PRINT	''
	PRINT	''

END
CLOSE ServerCursor
DEALLOCATE ServerCursor



