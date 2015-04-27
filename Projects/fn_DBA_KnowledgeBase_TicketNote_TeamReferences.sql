

USE [users]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[fn_DBA_KnowledgeBase_TicketNote_TeamReferences]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[fn_DBA_KnowledgeBase_TicketNote_TeamReferences]
GO

CREATE FUNCTION [dbo].[fn_DBA_KnowledgeBase_TicketNote_TeamReferences](@NID INT,@IncludeArchived BIT)
RETURNS		VarChar(8000)
AS
BEGIN
	DECLARE		@notes		VarChar(7500)
			,@RefString	VarChar(8000)

	IF @IncludeArchived = 0		
		SELECT		@notes = notes
		FROM		users.dbo.frmNotes
		WHERE		NID = @NID
	ELSE
		SELECT		@notes = notes
		FROM		TicketingArchive.dbo.frmNotes
		WHERE		NID = @NID

	SELECT		@RefString = COALESCE	(
						@RefString + CHAR(13) + CHAR(10) + CAST([ID] AS CHAR(10)) + ' ' + CAST([Name] AS CHAR(25)) + ' ' + CAST([TS_Team] AS CHAR(10))
						,CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +'      REFERENCED TEAM MEMBERS IN NOTES'
						+ CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + CAST('USERID' AS CHAR(10)) + ' ' + CAST('USERNAME' AS CHAR(25)) + ' ' + CAST('TEAM' AS CHAR(10))
						+ CHAR(13) + CHAR(10) + '==============================================='
						+ CHAR(13) + CHAR(10) + CAST([ID] AS CHAR(10)) + ' ' + CAST([Name] AS CHAR(25)) + ' ' + CAST([TS_Team] AS CHAR(10))
						)                        

	FROM		[Users].[dbo].[DBA_Dashboard_TeamUsers]
	WHERE		CHARINDEX([name],@notes) > 0

	RETURN @RefString
END
GO


SELECT	[dbo].[fn_DBA_KnowledgeBase_TicketNote_TeamReferences] (5744677,0)



