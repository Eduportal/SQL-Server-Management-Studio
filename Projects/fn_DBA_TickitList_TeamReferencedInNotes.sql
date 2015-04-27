-- =============================================
-- Create table function (TF)
-- =============================================
IF EXISTS (SELECT * 
	   FROM   sysobjects 
	   WHERE  name = N'fn_DBA_TickitList_TeamReferencedInNotes')
	DROP FUNCTION fn_DBA_TickitList_TeamReferencedInNotes
GO

CREATE FUNCTION fn_DBA_TickitList_TeamReferencedInNotes
	(@Team			VarChar(10)
	,@IncludeArchived	BIT)
RETURNS @Results TABLE 
	(TID INT PRIMARY KEY)
AS
BEGIN
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
		
		IF @IncludeArchived = 1
			INSERT INTO	@Results(TID)
			SELECT		DISTINCT T1.TID
			FROM		TicketingArchive.dbo.frmNotes T1 WITH(NOLOCK)
			JOIN		CONTAINSTable(TicketingArchive.dbo.frmNotes,*,@SearchPhrase) T2
				ON	T1.NID = T2.[KEY]
			WHERE		T1.TID NOT IN (SELECT TID FROM @Results)		

		END
		FETCH NEXT FROM TeamCursor INTO @name,@lname,@email
	END

	CLOSE TeamCursor
	DEALLOCATE TeamCursor

	RETURN 
END
GO

-- =============================================
-- Example to execute function
-- =============================================
SELECT * FROM dbo.fn_DBA_TickitList_TeamReferencedInNotes ('DBA',1)
GO

