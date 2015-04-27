USE [users]
GO



DECLARE		@Team			VarChar(10)
		,@IncludeArchived	BIT
		
DECLARE		@Results		TABLE
			(
			TID		INT PRIMARY KEY
			)

SELECT		@Team			= 'DBA'
		,@IncludeArchived	= 0

DECLARE		@name		VarChar(100)
		,@lname		VarChar(100)
		,@email		VarChar(100)
		,@SearchPhrase	VarChar(8000)

DECLARE TeamCursor	CURSOR
FOR	
SELECT		QUOTENAME(name,'"'),QUOTENAME(lname,'"'),email
FROM		users.dbo.tbl_TeamUsers
WHERE		TS_Team = @Team

OPEN TeamCursor

FETCH NEXT FROM TeamCursor INTO @name,@lname,@email
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
	
	SET @SearchPhrase = @name + ' OR ' + @lname + ' OR "' + @email + '"'

	INSERT INTO	@Results(TID)
	SELECT		DISTINCT T1.TID
	FROM		Users.dbo.frmNotes T1 WITH(NOLOCK)
	JOIN		CONTAINSTable(Users.dbo.frmNotes,*,@SearchPhrase) T2
		ON	T1.NID = T2.[KEY]
	WHERE		T1.TID NOT IN (SELECT TID FROM @Results)

	END
	FETCH NEXT FROM TeamCursor INTO @name,@lname,@email
END

CLOSE TeamCursor
DEALLOCATE TeamCursor


SELECT	* From @Results
