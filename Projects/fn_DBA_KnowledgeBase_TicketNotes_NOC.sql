USE [users]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[fn_DBA_KnowledgeBase_TicketNotes_NOC]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[fn_DBA_KnowledgeBase_TicketNotes_NOC]
GO

USE [users]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_DBA_KnowledgeBase_TicketNotes_NOC](@TID INT,@IncludeArchived BIT)
RETURNS TABLE
AS RETURN
	(
	SELECT		[note].[NID]
			,[note].[TID]
			,[WID]
			, dbo.udf_StripHTML([notes])							[notes]
			,[timeStamp]
			,[note].[userID]								[UserID_Updater]
			,[note].[userName]								[UserName_Updater]
			,'http://intranet.seattle.gettyimages.com/search/user_record.asp?id='
				+ CAST([note].[userID] AS VarChar)					[Link_Updater]
			,[User].[TS_Team]								[Team_Updater]
			,[dbo].[fn_DBA_KnowledgeBase_TicketNote_TeamReferences]([note].[NID],0)		[Note_References]
	FROM		[Users].[dbo].[frmNotes]		[note]
	LEFT JOIN	[Users].[dbo].[DBA_Dashboard_TeamUsers]	[User]
		ON	[note].[userid] = [User].[id]
	WHERE		[note].[TID] = @TID
	UNION ALL
	SELECT		[note].[NID]
			,[note].[TID]
			,[WID]
			, dbo.udf_StripHTML([notes])							[notes]
			,[timeStamp]
			,[note].[userID]								[UserID_Updater]
			,[note].[userName]								[UserName_Updater]
			,'http://intranet.seattle.gettyimages.com/search/user_record.asp?id='
				+ CAST([note].[userID] AS VarChar)					[Link_Updater]
			,[User].[TS_Team]								[Team_Updater]
			,[dbo].[fn_DBA_KnowledgeBase_TicketNote_TeamReferences]([note].[NID],1)		[Note_References]
	FROM		[TicketingArchive].[dbo].[frmNotes]		[note]
	LEFT JOIN	[Users].[dbo].[DBA_Dashboard_TeamUsers]		[User]
		ON	[note].[userid] = [User].[id]
	WHERE		@IncludeArchived = 1
		AND	[note].[TID] = @TID
	)
GO
	
