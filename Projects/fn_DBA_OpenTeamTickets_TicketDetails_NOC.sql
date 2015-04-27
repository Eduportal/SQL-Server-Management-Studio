USE [users]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[fn_DBA_OpenTeamTickets_TicketDetails_NOC]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[fn_DBA_OpenTeamTickets_TicketDetails_NOC]
GO

USE [users]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fn_DBA_OpenTeamTickets_TicketDetails_NOC](@Team VarChar(100))
RETURNS TABLE
AS RETURN
	(

	--DECLARE		@Team		VarChar(100)
	--SET		@Team		= 'DBA'

	SELECT		[FT].[TID]
			,'http://intranet.seattle.gettyimages.com/forms/TransactionView.asp?'
					+ 'commID=376&comm=Change%20Control&TID='
					+ CAST([FT].[TID] AS VarChar)
					+ '&service=Change%20Control%20Request'			[Link_Ticket]
					
			,[FT].[userID]								[UserID_Creator]
			,'http://intranet.seattle.gettyimages.com/search/user_record.asp?id='
					+CAST([FT].[UserID] AS VarChar)				[Link_Creator]
			,COALESCE(TU1.[name],U1.[name])						[UserName_Creator]
			,TU1.[TS_Team]								[Team_Creator]
			
			,[FT].[handlerID]							[UserID_Owner]
			,'http://intranet.seattle.gettyimages.com/search/user_record.asp?id='
					+CAST(FT.[handlerID] AS VarChar)			[Link_Owner]
			,COALESCE(TU2.[name],[FT].[Handler],U2.[name])				[UserName_Owner]
			,TU2.[TS_Team]								[Team_Owner]
			,[FT].[status]
			,CASE priority
				WHEN 1 THEN 'Low'
				WHEN 2 THEN 'Medium'
				WHEN 3 THEN 'High'
				WHEN 4 THEN 'Critical'
				ELSE 'Project' END						[Priority]
			,	(
				SELECT		CAST(REPLACE(FD.Value,'sev','') AS INT)
				FROM		Users.dbo.frmData FD
				WHERE		FD.TID = FT.TID
					AND	FD.CID IN (14248,14249)
					AND	isnumeric(REPLACE(FD.Value,'sev','')) = 1
				)								[Severity]
			,[FT].[subject]
			,[FT].[stage]
			,[FT].[workflowTitle]
			,[FT].[category]
			,[FT].[category2]
			,[FT].[category3]							[ServiceLevel]
			,'Seattle NOC Ticket'							[Service]
			,[FT].timeStamp								[Date Received]
			,[FT].timeStamp2							[Date Resolved]
			,[FT].timeStamp3							[Date Updated]
			
	FROM		Users.dbo.frmTransactions [FT]
	LEFT JOIN	Users.dbo.fn_DBA_TickitList_TeamReferencedInNotes (@Team,0) NoteFilter
		ON	[NoteFilter].[TID] = [FT].[TID]
	
	LEFT JOIN	[users].[dbo].[tbl_TeamUsers]  TU1
		ON	CAST(TU1.[ID] AS INT) = CAST([FT].[userID] AS INT)
		
	LEFT JOIN	[users].[dbo].[tbl_Users]  U1
		ON	CAST(U1.[ID] AS INT) = CAST([FT].[userID] AS INT)
		
	LEFT JOIN	[users].[dbo].[tbl_TeamUsers]  TU2
		ON	CAST(TU2.[ID] AS INT) = CAST([FT].[handlerID] AS INT)

	LEFT JOIN	[users].[dbo].[tbl_Users]  U2
		ON	CAST(U2.[ID] AS INT) = CAST([FT].[handlerID] AS INT)
		
	WHERE		FT.FID = 840
		AND	FT.status = '0'
		AND	(
			TU1.[TS_Team] = @Team
		OR	TU2.[TS_Team] = @Team
		OR	[NoteFilter].[TID] IS NOT NULL
			)
		
	)


GO









