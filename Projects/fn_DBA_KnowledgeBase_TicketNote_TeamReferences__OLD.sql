
USE [users]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[fn_DBA_KnowledgeBase_TicketNote_TeamReferences]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[fn_DBA_KnowledgeBase_TicketNote_TeamReferences]
GO

USE [users]
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_DBA_KnowledgeBase_TicketNote_TeamReferences](@Mode VarChar(50),@TID INT,@NID INT)
RETURNS	@Results	Table
		(
		TID	INT
		,NID	VarChar(2000)
		,UserID VarChar(2000)
		,Name	VarChar(2000)
		,Team	VarChar(2000)
		)

BEGIN
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

	IF @Mode = 'Detail'
		INSERT INTO	@Results(TID,NID,UserID,Name,Team)
		SELECT		DISTINCT @TID,NID,UserID,Name,Team
		FROM		@SUM

	ELSE
	BEGIN

		DECLARE		SUM_NID_Cursor	CURSOR
		FOR
		SELECT		DISTINCT NID,UserID,Name,Team
		FROM		@SUM

		OPEN SUM_NID_Cursor
		FETCH NEXT FROM SUM_NID_Cursor INTO @NID,@UserID,@name,@team
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN
				IF @Mode = 'SUM_NID'
				BEGIN 
					IF NOT EXISTS (SELECT * FROM @Results WHERE TID=@TID and NID=@NID)
					INSERT INTO	@Results(TID,NID,UserID,Name,Team)
							VALUES(@TID,@NID,@UserID,@name,@Team)

					ELSE

					UPDATE		@Results
						SET	UserID	= UserID	+ ',' + CAST(@UserID AS VarChar(40))
							,Name	= Name		+ ',' + CAST(@name AS VarChar(40))
							,Team	= Team		+ ',' + CAST(@team AS VarChar(40))
					WHERE		TID=@TID 
						AND	NID=@NID
				END
				
				IF @Mode = 'SUM_TID'
				BEGIN 
					IF NOT EXISTS (SELECT * FROM @Results WHERE TID=@TID)
					INSERT INTO	@Results(TID,NID,UserID,Name,Team)
							VALUES(@TID,@NID,@UserID,@name,@Team)

					ELSE

					UPDATE		@Results
						SET	NID	= NID		+ ',' + CAST(@NID AS VarChar(40))
							,UserID	= UserID	+ ',' + CAST(@UserID AS VarChar(40))
							,Name	= Name		+ ',' + CAST(@name AS VarChar(40))
							,Team	= Team		+ ',' + CAST(@team AS VarChar(40))
					WHERE		TID=@TID 

				END				

			END
			FETCH NEXT FROM SUM_NID_Cursor INTO @NID,@UserID,@name,@team
		END
		CLOSE SUM_NID_Cursor
		DEALLOCATE SUM_NID_Cursor
	
	END
	
	RETURN
END

GO

