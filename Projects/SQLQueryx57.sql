DECLARE	@NID INT
	,@TID INT
	
SELECT	@TID = 1629224
	--,@NID = 5775441

	DECLARE		@UserID		INT 
	DECLARE		@name		varchar(40)
	DECLARE		@team		varchar(40)
	DECLARE		@SUM		TABLE (TID INT, NID INT, UserID INT, Name VarChar(40), Team VarChar(40))

	DECLARE		TeamUserCursor	CURSOR
	FOR
	SELECT	QUOTENAME([Name],'"'),[TS_Team],ID
	FROM	[Users].[dbo].[DBA_Dashboard_TeamUsers]

	OPEN TeamUserCursor
	FETCH NEXT FROM TeamUserCursor INTO @name,@team,@UserID
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			INSERT INTO	@SUM(NID,UserID,Name,Team)
			SELECT		DISTINCT [KEY],@UserID,@name,@Team
			FROM		CONTAINSTABLE(frmNotes,notes,@name)
			WHERE		[KEY] IN
						(
						SELECT	DISTINCT NID
						FROM	frmNotes
						WHERE	TID = @TID
						)
				AND	([KEY] = @NID 
				OR	COALESCE(@NID,0) = 0)
		END
		FETCH NEXT FROM TeamUserCursor INTO @name,@team,@UserID
	END
	CLOSE TeamUserCursor
	DEALLOCATE TeamUserCursor
	
SELECT * FROM @SUM	
	
	
	
	
	
	