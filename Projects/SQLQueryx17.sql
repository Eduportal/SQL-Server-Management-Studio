-- Make sure that all of the session settings are set properly
IF sessionproperty('ARITHABORT') = 0 SET ARITHABORT ON
IF sessionproperty('CONCAT_NULL_YIELDS_NULL') = 0 SET CONCAT_NULL_YIELDS_NULL ON
IF sessionproperty('QUOTED_IDENTIFIER') = 0 SET QUOTED_IDENTIFIER ON
IF sessionproperty('ANSI_NULLS') = 0 SET ANSI_NULLS ON
IF sessionproperty('ANSI_PADDING') = 0 SET ANSI_PADDING ON
IF sessionproperty('ANSI_WARNINGS') = 0 SET ANSI_WARNINGS ON
IF sessionproperty('NUMERIC_ROUNDABORT') = 1 SET NUMERIC_ROUNDABORT OFF
go

DROP VIEW	frmData_NOCTicket_Severity
GO
-- Create the view, it must comply with the rules (deterministic)
CREATE VIEW	frmData_NOCTicket_Severity		--WITH SCHEMABINDING 
AS 
SELECT		frmData.TID
		,CAST(REPLACE(frmData.Value,'sev','') AS INT) AS Severity
		,count_big(*) as cnt
FROM		dbo.frmData frmData
WHERE		frmData.CID IN (14248,14249)
	AND	isnumeric(REPLACE(frmData.Value,'sev','')) = 1
GROUP BY	frmData.TID
		,CAST(REPLACE(frmData.Value,'sev','') AS INT)
GO

---- Check to see if the indexes can be created 
--if ObjectProperty(object_id('frmData_NOCTicket_Severity'),'IsIndexable') = 1
--BEGIN
---- Create a clustered index, it MUST be unique
--CREATE UNIQUE CLUSTERED INDEX TID_Severity ON 
--frmData_NOCTicket_Severity(TID, Severity)

--EXEC SP_SPACEUSED 'frmData_NOCTicket_Severity'

--END

GO


DROP VIEW	frmData_NOCTicket_Creator_Name
GO
-- Create the view, it must comply with the rules (deterministic)
CREATE VIEW	frmData_NOCTicket_Creator_Name		--WITH SCHEMABINDING 
AS 
SELECT		frmData.TID
		,CAST(frmData.Value AS VarChar(25)) AS Creator_Name
		,count_big(*) as cnt
FROM		dbo.frmData frmData
WHERE		frmData.CID IN (5099)
GROUP BY	frmData.TID
		,CAST(frmData.Value AS VarChar(25))
GO

---- Check to see if the indexes can be created 
--if ObjectProperty(object_id('frmData_NOCTicket_Creator_Name'),'IsIndexable') = 1
--BEGIN
---- Create a clustered index, it MUST be unique
--CREATE UNIQUE CLUSTERED INDEX TID_Creator_Name ON 
--frmData_NOCTicket_Creator_Name(TID, Creator_Name)

--EXEC SP_SPACEUSED 'frmData_NOCTicket_Creator_Name'

END

GO



/*
	SELECT		max(len(Value))
	FROM		Users.dbo.frmData FD1
	WHERE		FD1.CID IN (5099)
		--AND	FD1.TID = FT.TID
		
		
		
	SELECT		TID,Value
	FROM		Users.dbo.frmData FD2
	WHERE		FD2.CID IN (14248,14249)
		--AND	FD2.TID = FT.TID



SELECT		TID,Severity
FROM		frmData_NOCTicket_Severity WITH(NOEXPAND)





*/






DROP FUNCTION [dbo].[fn_DBA_KnowledgeBase_TicketDetails_NOC]
GO
CREATE FUNCTION [dbo].[fn_DBA_KnowledgeBase_TicketDetails_NOC](@Search VarChar(8000))
RETURNS TABLE
AS RETURN
	(
	SELECT		FT.[TID]								[Ticket_ID]
			,'http://intranet.seattle.gettyimages.com/forms/TransactionView.asp?'
				+ 'commID=376&comm=Change%20Control&TID='
				+ CAST(FT.TID AS VarChar)
				+ '&service=Change%20Control%20Request'				[Ticket_Link]
			,FT.[FID]
			,FT.[WID]
			,FT.[userID]								[Creator_ID]
			,FD1.[Creator_Name]
			,'http://intranet.seattle.gettyimages.com/search/user_record.asp?id='
				+CAST(FT.UserID AS VarChar)					[Creator_Link]
			,CASE	WHEN [userid] IN (3529,7519,833,1474,6542,7368,7075,7255) 
					THEN 'DBA'
				WHEN [userid] IN (3532,1626,1988,6611,6838,6384) 
					THEN 'WEB'
				ELSE '' END							[Creator_TS_Team]	
									
			,[handlerID]								[Owner_ID]
			,[handler]								[Owner_Name]
			,'http://intranet.seattle.gettyimages.com/search/user_record.asp?id='
				+CAST(FT.handlerID AS VarChar)					[Owner_Link]
			,CASE	WHEN [HandlerID] IN (3529,7519,833,1474,6542,7368,7075,7255) 
					THEN 'DBA'
				WHEN [HandlerID] IN (3532,1626,1988,6611,6838,6384) 
					THEN 'WEB'
				ELSE '' END							[Owner_TS_Team]
				
			,[status]
			,CASE FT.priority
				WHEN 1 THEN 'Low'
				WHEN 2 THEN 'Medium'
				WHEN 3 THEN 'High'
				WHEN 4 THEN 'Critical'
				ELSE 'Project' END						[Priority]
			,FD2.[Severity]
			,[subject]
			,[stage]
			,[workflowTitle]
			,[category]
			,[category2]
			,[category3]								[ServiceLevel]
			,'Seattle NOC Ticket'							[Service]
			,timeStamp								[Date Received]
			,timeStamp2								[Date Resolved]
			,timeStamp3								[Date Updated]

	FROM		Users.dbo.frmTransactions FT
	JOIN		Users.dbo.frmData_NOCTicket_Creator_Name FD1 --WITH(NOEXPAND)
		ON	FD1.TID = FT.TID
	JOIN		Users.dbo.frmData_NOCTicket_Severity FD2 --WITH(NOEXPAND)
		ON	FD2.TID = FT.TID					
	WHERE		FT.FID = 840
		AND	(
			FT.TID IN
				( --ALL TID THAT HAVE A NOTE WITH CRITERA MATCH
				SELECT		DISTINCT
						TID
				FROM		Users.dbo.frmNotes
				WHERE		CONTAINS (notes, @Search)
					OR	CONTAINS (UserName, @Search)
					OR	CONTAINS (UserEmail, @Search)
				)
		OR	CONTAINS ([handler], @Search)
		OR	CONTAINS ([category], @Search)
		OR	CONTAINS ([category2], @Search)
		OR	CONTAINS ([category3], @Search)
		OR	CONTAINS ([subject], @Search)
		OR	[FD1].[Creator_Name] like '%' + @Search + '%'		
			)
			
	UNION

	SELECT		FT.[TID]								[Ticket_ID]
			,'http://intranet.seattle.gettyimages.com/forms/TransactionView.asp?'
				+ 'commID=376&comm=Change%20Control&TID='
				+ CAST(FT.TID AS VarChar)
				+ '&service=Change%20Control%20Request'				[Ticket_Link]
			,FT.[FID]
			,FT.[WID]
			,FT.[userID]								[Creator_ID]
			,FD1.[Creator_Name]
			,'http://intranet.seattle.gettyimages.com/search/user_record.asp?id='
				+CAST(FT.UserID AS VarChar)					[Creator_Link]
			,CASE	WHEN [userid] IN (3529,7519,833,1474,6542,7368,7075,7255) 
					THEN 'DBA'
				WHEN [userid] IN (3532,1626,1988,6611,6838,6384) 
					THEN 'WEB'
				ELSE '' END							[Creator_TS_Team]	
									
			,[handlerID]								[Owner_ID]
			,[handler]								[Owner_Name]
			,'http://intranet.seattle.gettyimages.com/search/user_record.asp?id='
				+CAST(FT.handlerID AS VarChar)					[Owner_Link]
			,CASE	WHEN [HandlerID] IN (3529,7519,833,1474,6542,7368,7075,7255) 
					THEN 'DBA'
				WHEN [HandlerID] IN (3532,1626,1988,6611,6838,6384) 
					THEN 'WEB'
				ELSE '' END							[Owner_TS_Team]
				
			,[status]
			,CASE FT.priority
				WHEN 1 THEN 'Low'
				WHEN 2 THEN 'Medium'
				WHEN 3 THEN 'High'
				WHEN 4 THEN 'Critical'
				ELSE 'Project' END						[Priority]
			,FD2.[Severity]
			,[subject]
			,[stage]
			,[workflowTitle]
			,[category]
			,[category2]
			,[category3]								[ServiceLevel]
			,'Seattle NOC Ticket'							[Service]
			,timeStamp								[Date Received]
			,timeStamp2								[Date Resolved]
			,timeStamp3								[Date Updated]

	FROM		TicketingArchive.dbo.frmTransactions FT
	JOIN		TicketingArchive.dbo.frmData_NOCTicket_Creator_Name FD1 --WITH(NOEXPAND)
		ON	FD1.TID = FT.TID
	JOIN		TicketingArchive.dbo.frmData_NOCTicket_Severity FD2 --WITH(NOEXPAND)
		ON	FD2.TID = FT.TID					
	WHERE		FT.FID = 840
		AND	(
			FT.TID IN
				( --ALL TID THAT HAVE A NOTE WITH CRITERA MATCH
				SELECT		DISTINCT
						TID
				FROM		TicketingArchive.dbo.frmNotes
				WHERE		CONTAINS (notes, @Search)
					OR	CONTAINS (UserName, @Search)
					OR	CONTAINS (UserEmail, @Search)
				)
		OR	CONTAINS ([handler], @Search)
		OR	CONTAINS ([category], @Search)
		OR	CONTAINS ([category2], @Search)
		OR	CONTAINS ([category3], @Search)
		OR	CONTAINS ([subject], @Search)
		OR	[FD1].[Creator_Name] like '%' + @Search + '%'		
			)
	)
GO		




GO
DROP FUNCTION [dbo].[fn_DBA_KnowledgeBase_TicketNote_TeamReferences]
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


--SELECT * FROM [fn_DBA_KnowledgeBase_TicketNote_TeamReferences]('DETAIL',NULL,NULL)
--SELECT * FROM [fn_DBA_KnowledgeBase_TicketNote_TeamReferences]('DETAIL',1629224,NULL)
--SELECT * FROM [fn_DBA_KnowledgeBase_TicketNote_TeamReferences]('DETAIL',1629224,5775441)


DROP FUNCTION [fn_DBA_KnowledgeBase_TicketNote_TeamReferences_String] 
GO
CREATE FUNCTION [fn_DBA_KnowledgeBase_TicketNote_TeamReferences_String] 
	(	
	@TID		INT
	,@NID		INT
	)
RETURNS VARCHAR(8000)
AS
BEGIN
	IF COALESCE(@TID,0) = 0 RETURN NULL
		
	DECLARE		@Results	VarChar(8000)
	SET		@Results	= ''
	SET		@NID		= COALESCE(@NID,0)
	
	SELECT		@Results	= @Results +CHAR(13)+CHAR(10)+ [Results]
	FROM		(
			SELECT		DISTINCT
					CAST	(
						REPLACE([Name],'"','')		-- UserName
						+ ' (' + [Team] + ') '		-- Team
						AS CHAR(30)
						)
					+ 'http://intranet.seattle.gettyimages.com/search/user_record.asp?id='
					+ [userID] AS [Results]
			FROM		[dbo].[fn_DBA_KnowledgeBase_TicketNote_TeamReferences]('DETAIL',@TID,@NID)
			) [Data]

	RETURN @Results		
END
GO


--SELECT [dbo].[fn_DBA_KnowledgeBase_TicketNote_TeamReferences_String](NULL,NULL)
--SELECT [dbo].[fn_DBA_KnowledgeBase_TicketNote_TeamReferences_String](1629224,NULL)
--SELECT [dbo].[fn_DBA_KnowledgeBase_TicketNote_TeamReferences_String](1629224,5775441)


DROP FUNCTION [fn_DBA_KnowledgeBase_TicketNote_TeamReferences_String_TeamOnly] 
GO
CREATE FUNCTION [fn_DBA_KnowledgeBase_TicketNote_TeamReferences_String_TeamOnly] 
	(	
	@TID		INT
	,@NID		INT
	)
RETURNS VARCHAR(8000)
AS
BEGIN
	IF COALESCE(@TID,0) = 0 RETURN NULL
		
	DECLARE		@Results	VarChar(8000)
	SET		@Results	= ''
	SET		@NID		= COALESCE(@NID,0)

	SELECT		@Results = @Results + ',' + [Team]
	FROM		(	
			SELECT	DISTINCT
				[Team] 
			FROM	[Users].[dbo].[fn_DBA_KnowledgeBase_TicketNote_TeamReferences]
				('DETAIL',@TID,@NID)
			) Data
	IF LEN(@Results) > 0 SET @Results = STUFF(@Results,1,1,'')		
	RETURN @Results		
END
GO


--SELECT [dbo].[fn_DBA_KnowledgeBase_TicketNote_TeamReferences_String_TeamOnly](NULL,NULL)
--SELECT [dbo].[fn_DBA_KnowledgeBase_TicketNote_TeamReferences_String_TeamOnly](1629224,NULL)
--SELECT [dbo].[fn_DBA_KnowledgeBase_TicketNote_TeamReferences_String_TeamOnly](1629224,5775441)



	
DROP FUNCTION [dbo].[fn_DBA_KnowledgeBase_TicketNotes_NOC]
GO	
CREATE FUNCTION [dbo].[fn_DBA_KnowledgeBase_TicketNotes_NOC](@TID INT)
RETURNS TABLE
AS RETURN
	(
	SELECT		[note].[NID]
			,[note].[FID]
			,[note].[TID]
			,[WID]
			, dbo.udf_StripHTML([notes])							[notes]
			,[timeStamp]
			,[note].[userID]								[Updater_ID]
			,[note].[userName]								[Updater_Name]
			,'http://intranet.seattle.gettyimages.com/search/user_record.asp?id='
				+ CAST([note].[userID] AS VarChar)					[Updater_Link]
			,[User].[TS_Team]								[Updater_TS_Team]
			,T1.[name]									[References]
			,T1.[team]									[Reference_TS_Team]
	FROM		[Users].[dbo].[frmNotes]		[note]
	LEFT JOIN	[Users].[dbo].[DBA_Dashboard_TeamUsers]	[User]
		ON	[note].[userid] = [User].[id]
	LEFT JOIN	[Users].[dbo].[fn_DBA_KnowledgeBase_TicketNote_TeamReferences]('SUM_NID',@TID,NULL) T1
		ON	T1.NID = [note].[NID]
	WHERE		[note].[TID] = @TID
	

	UNION ALL

	SELECT		[note].[NID]
			,[note].[FID]
			,[note].[TID]
			,[WID]
			, dbo.udf_StripHTML([notes])							[notes]
			,[timeStamp]
			,[note].[userID]								[Updater_ID]
			,[note].[userName]								[Updater_Name]
			,'http://intranet.seattle.gettyimages.com/search/user_record.asp?id='
				+ CAST([note].[userID] AS VarChar)					[Updater_Link]
			,[User].[TS_Team]								[Updater_TS_Team]
			,T1.[name]									[References]
			,T1.[team]									[Reference_TS_Team]
	FROM		[TicketingArchive].[dbo].[frmNotes]		[note]
	LEFT JOIN	[Users].[dbo].[DBA_Dashboard_TeamUsers]	[User]
		ON	[note].[userid] = [User].[id]
	LEFT JOIN	[TicketingArchive].[dbo].[fn_DBA_KnowledgeBase_TicketNote_TeamReferences]('SUM_NID',@TID,NULL) T1
		ON	T1.NID = [note].[NID]
	WHERE		[note].[TID] = @TID
	)
GO







DECLARE	@Search	VarChar(8000)
SET	@Search	= 'sqldeployer02'

SELECT * FROM [fn_DBA_KnowledgeBase_TicketDetails_NOC](@Search) Ticket
GO

DECLARE @TicketID INT
SET	@TicketID = 123456

SELECT * FROM [fn_DBA_KnowledgeBase_TicketNotes_NOC](@TicketID)
GO



DECLARE	@Search	VarChar(8000)
SET	@Search	= 'ledridge'

SELECT		* 
FROM		[fn_DBA_KnowledgeBase_TicketDetails_NOC](@Search) Ticket
LEFT JOIN	(
		SELECT		[NID]
				,[FID]
				,[TID]
				,[WID]
				, dbo.udf_StripHTML([notes]) AS [notes]
				,[timeStamp]
				,[userID]								[Updater_ID]
				,[userName]								[Updater_Name]
				,'http://intranet.seattle.gettyimages.com/search/user_record.asp?id='
					+ CAST([userID] AS VarChar)					[Updater_Link]
				,CASE	WHEN [userID] IN (3529,7519,833,1474,6542,7368,7075,7255) 
						THEN 'DBA'
					WHEN [userID] IN (3532,1626,1988,6611,6838,6384) 
						THEN 'WEB'
						ELSE '' 
					END								[Updater_TS_Team]
		FROM		Users.dbo.frmNotes

		UNION ALL

		SELECT		[NID]
				,[FID]
				,[TID]
				,[WID]
				, dbo.udf_StripHTML([notes]) AS [notes]
				,[timeStamp]
				,[userID]								[Updater_ID]
				,[userName]								[Updater_Name]
				,'http://intranet.seattle.gettyimages.com/search/user_record.asp?id='
					+ CAST([userID] AS VarChar)					[Updater_Link]
				,CASE	WHEN [userID] IN (3529,7519,833,1474,6542,7368,7075,7255) 
						THEN 'DBA'
					WHEN [userID] IN (3532,1626,1988,6611,6838,6384) 
						THEN 'WEB'
						ELSE '' 
					END								[Updater_TS_Team]
		FROM		TicketingArchive.dbo.frmNotes
		) Note
	ON	Ticket.[Ticket_ID] = Note.TID
GO



SELECT		[NID]
		,[FID]
		,[TID]
		,[WID]
		, dbo.udf_StripHTML([notes]) AS [notes]
		,[timeStamp]
		,[userID]								[Updater_ID]
		,[userName]								[Updater_Name]
		,'http://intranet.seattle.gettyimages.com/search/user_record.asp?id='
			+ CAST([userID] AS VarChar)					[Updater_Link]
		,COALESCE([user].TS_Team,'')						TS_Team
FROM		Users.dbo.frmNotes [note]
LEFT JOIN	Users.dbo.[DBA_Dashboard_TeamUsers] [user]
	ON	[note].[userID] = [user].[id]






select * From Users.dbo.[DBA_Dashboard_TeamUsers]

SELECT		*
FROM		Users.dbo.frmNotes [note]
JOIN		FREETEXTTABLE(frmNotes,notes,'steve ledridge') note_filter
	ON	note.NID = note_filter.[key]
ORDER BY	 note_filter.[Rank] desc



SELECT		*
FROM		Users.dbo.frmNotes [note]
		, Users.dbo.[DBA_Dashboard_TeamUsers] [user]
WHERE		CONTAINS([note].[notes],[user].[name])

 
INNER JOIN	CONTAINSTABLE(table, column, contains_search_condition) AS KEY_TBL
   ON FT_TBL.unique_key_column = KEY_TBL.[KEY]
 




SELECT		@Search = COALESCE(@Search + ' OR "' + [user].[name] + '"','"' + [user].[name] + '"')
FROM		Users.dbo.[DBA_Dashboard_TeamUsers] [user]

SELECT		*
FROM		FREETEXTTABLE(frmNotes,notes,@Search)




