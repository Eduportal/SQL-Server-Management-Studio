USE [users]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[fn_DBA_KnowledgeBase_TicketDetails_NOC]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[fn_DBA_KnowledgeBase_TicketDetails_NOC]
GO

USE [users]
GO

SET ANSI_NULLS ON
GO


SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_DBA_KnowledgeBase_TicketDetails_NOC](@Search VarChar(8000),@IncludeArchived BIT)
RETURNS TABLE
AS RETURN
	(
	SELECT		FT.[TID]
			,'http://intranet.seattle.gettyimages.com/forms/TransactionView.asp?'
					+ 'commID=376&comm=Change%20Control&TID='
					+ CAST(FT.TID AS VarChar)
					+ '&service=Change%20Control%20Request'			[Link_Ticket]
			,[userID]								[UserID_Creator]
			,'http://intranet.seattle.gettyimages.com/search/user_record.asp?id='
					+CAST(FT.UserID AS VarChar)				[Link_Creator]
			,(SELECT name from tbl_users WHERE ID = [UserID])			[UserName_Creator]
			,(Select TS_Team from [users].[dbo].[DBA_Dashboard_TeamUsers] TU
				WHERE ID = FT.[userID])						[Team_Creator]
			,[handlerID]								[UserID_Owner]
			,'http://intranet.seattle.gettyimages.com/search/user_record.asp?id='
					+CAST(FT.UserID AS VarChar)				[Link_Owner]
			,(SELECT name from tbl_users WHERE ID = [handlerID])			[UserName_Owner]
			,(Select TS_Team from [users].[dbo].[DBA_Dashboard_TeamUsers] TU
				WHERE ID = FT.[handlerID])					[Team_Owner]
			,[status]
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
			,Search.Archived

	FROM		(
			SELECT		*,NULL AS [TransArcDate]
			FROM		Users.dbo.frmTransactions 
			UNION ALL
			SELECT		*
			FROM		TicketingArchive.dbo.frmTransactions 
			WHERE		@IncludeArchived = 1
			) FT
	JOIN		[Users].[dbo].[fn_DBA_KnowledgeBase_TicketSearch](@Search,@IncludeArchived) Search
		ON	Search.TID = FT.TID
	WHERE		FT.FID = 840
	)
	
GO
