USE [users]
GO
DECLARE		@Now	DATETIME
SET			@NOW	= GetDate()

SELECT		CASE [ReOpened]
				WHEN 0 THEN DATEDIFF(hour,[Date Opened],@Now) 
				ELSE DATEDIFF(hour,[Date Resolved],@Now)
				END																				[Age]
			,DATEADD(hour,DATEDIFF(hour,CASE [ReOpened] WHEN 0 THEN [Date Opened] ELSE [Date Resolved] END,@Now),cast(0 as DateTime))
			,YEAR(DATEADD(hour,DATEDIFF(hour,CASE [ReOpened] WHEN 0 THEN [Date Opened] ELSE [Date Resolved] END,@Now),cast(0 as DateTime)))- 1900	[Years]
			,MONTH(DATEADD(hour,DATEDIFF(hour,CASE [ReOpened] WHEN 0 THEN [Date Opened] ELSE [Date Resolved] END,@Now),cast(0 as DateTime)))		[Months]
			,DAY(DATEADD(hour,DATEDIFF(hour,CASE [ReOpened] WHEN 0 THEN [Date Opened] ELSE [Date Resolved] END,@Now),cast(0 as DateTime)))			[Days]
			,CASE	WHEN YEAR(DATEADD(hour,DATEDIFF(hour,CASE [ReOpened] WHEN 0 THEN [Date Opened] ELSE [Date Resolved] END,@Now),cast(0 as DateTime)))- 1900 = 1
						THEN '1 Year '
					WHEN YEAR(DATEADD(hour,DATEDIFF(hour,CASE [ReOpened] WHEN 0 THEN [Date Opened] ELSE [Date Resolved] END,@Now),cast(0 as DateTime)))- 1900 > 1
						THEN CAST(YEAR(DATEADD(hour,DATEDIFF(hour,CASE [ReOpened] WHEN 0 THEN [Date Opened] ELSE [Date Resolved] END,@Now),cast(0 as DateTime)))- 1900 AS VarChar(4)) + ' Years '
					ELSE '' END						

			+CASE	WHEN MONTH(DATEADD(hour,DATEDIFF(hour,CASE [ReOpened] WHEN 0 THEN [Date Opened] ELSE [Date Resolved] END,@Now),cast(0 as DateTime))) = 1
						THEN '1 Month '
					WHEN MONTH(DATEADD(hour,DATEDIFF(hour,CASE [ReOpened] WHEN 0 THEN [Date Opened] ELSE [Date Resolved] END,@Now),cast(0 as DateTime))) > 1
						THEN CAST(MONTH(DATEADD(hour,DATEDIFF(hour,CASE [ReOpened] WHEN 0 THEN [Date Opened] ELSE [Date Resolved] END,@Now),cast(0 as DateTime))) AS VarChar(2)) + ' Months '
					ELSE '' END

			+CASE	WHEN DAY(DATEADD(hour,DATEDIFF(hour,CASE [ReOpened] WHEN 0 THEN [Date Opened] ELSE [Date Resolved] END,@Now),cast(0 as DateTime))) = 1
						THEN '1 Day '
					WHEN DAY(DATEADD(hour,DATEDIFF(hour,CASE [ReOpened] WHEN 0 THEN [Date Opened] ELSE [Date Resolved] END,@Now),cast(0 as DateTime))) > 1
						THEN CAST(DAY(DATEADD(hour,DATEDIFF(hour,CASE [ReOpened] WHEN 0 THEN [Date Opened] ELSE [Date Resolved] END,@Now),cast(0 as DateTime))) AS VarChar(2)) + ' Days '
					ELSE '' END																	[AgeText]
			
			,COALESCE(DATEDIFF(hour,COALESCE([Date Updated],[Date Opened]),@Now),0)				[InactiveHrs]
			
			,CASE	WHEN YEAR(DATEADD(hour,DATEDIFF(hour,COALESCE([Date Updated],[Date Opened]),@Now),cast(0 as DateTime)))- 1900 = 1
						THEN '1 Year '
					WHEN YEAR(DATEADD(hour,DATEDIFF(hour,COALESCE([Date Updated],[Date Opened]),@Now),cast(0 as DateTime)))- 1900 > 1
						THEN CAST(YEAR(DATEADD(hour,DATEDIFF(hour,COALESCE([Date Updated],[Date Opened]),@Now),cast(0 as DateTime)))- 1900 AS VarChar(4)) + ' Years '
					ELSE '' END						

			+CASE	WHEN MONTH(DATEADD(hour,DATEDIFF(hour,COALESCE([Date Updated],[Date Opened]),@Now),cast(0 as DateTime))) = 1
						THEN '1 Month '
					WHEN MONTH(DATEADD(hour,DATEDIFF(hour,COALESCE([Date Updated],[Date Opened]),@Now),cast(0 as DateTime))) > 1
						THEN CAST(MONTH(DATEADD(hour,DATEDIFF(hour,COALESCE([Date Updated],[Date Opened]),@Now),cast(0 as DateTime))) AS VarChar(2)) + ' Months '
					ELSE '' END

			+CASE	WHEN DAY(DATEADD(hour,DATEDIFF(hour,COALESCE([Date Updated],[Date Opened]),@Now),cast(0 as DateTime))) = 1
						THEN '1 Day '
					WHEN DAY(DATEADD(hour,DATEDIFF(hour,COALESCE([Date Updated],[Date Opened]),@Now),cast(0 as DateTime))) > 1
						THEN CAST(DAY(DATEADD(hour,DATEDIFF(hour,COALESCE([Date Updated],[Date Opened]),@Now),cast(0 as DateTime))) AS VarChar(2)) + ' Days '
					ELSE '' END																	[InactiveText]			
			
			
			,*

FROM		(
			SELECT		CASE FT.FID WHEN 840 THEN 'NOC Ticket' WHEN 776 THEN 'WEB Error' END	[TicketType]
						,CASE FT.[status] WHEN 0 THEN 'Open' ELSE 'Closed' END					[Status]
						,[FT].[TID]																[Ticket]
						,'http://intranet.seattle.gettyimages.com/forms/TransactionView.asp?'
								+ 'commID=376&comm=Change%20Control&TID='
								+ CAST([FT].[TID] AS VarChar)
								+ '&service=Change%20Control%20Request'							[Link_Ticket]
						,	(
							SELECT		REPLACE(REPLACE(FD.Value,'sev',''),'Project','P')
							FROM		Users.dbo.frmData FD
							WHERE		FD.TID = FT.TID
									AND	FD.CID IN (14248,14249)
							)																	[Severity]
						,[FT].[category]														[System Name]
						,	(
							SELECT		FD.Value
							FROM		Users.dbo.frmData FD
							WHERE		FD.TID = FT.TID
									AND	FD.CID IN (6505)
							)																	[Site/Service]			
						,[FT].[subject]															[subject]
						,[FT].[workflowTitle]													[WorkflowTitle]
						,COALESCE(TU2.[name],[FT].[Handler],U2.[name])							[UserName_Owner]
						,'http://intranet.seattle.gettyimages.com/search/user_record.asp?id='
								+CAST(FT.[handlerID] AS VarChar)								[Link_Owner]
						,[FT].timeStamp															[Date Opened]
						,[FT].timeStamp2														[Date Resolved]
						,[FT].timeStamp3														[Date Updated]

						,CASE	WHEN DATEDIFF(minute,[FT].timeStamp3,GetDate()) > 60*4 THEN 1 
								ELSE 0 END														[NoActivity]
						,CASE	WHEN [FT].timeStamp2 < [FT].timeStamp3 THEN 1 
								ELSE 0 END														[ReOpened]
				FROM		Users.dbo.frmTransactions [FT]
				LEFT JOIN	[users].[dbo].[tbl_TeamUsers]  TU2
					ON	CAST(TU2.[ID] AS INT) = CAST([FT].[handlerID] AS INT)
				LEFT JOIN	[users].[dbo].[tbl_Users]  U2
					ON	CAST(U2.[ID] AS INT) = CAST([FT].[handlerID] AS INT)
				WHERE		FT.FID		IN	(
											840		-- NOC TICKET
											,776	-- WEB ERROR	
											)
			) TicketData
		
WHERE		[Status] = 'Open'

ORDER BY	[Age] desc 

--SELECT		Category		Cat1
--			,count(*)		Count
--			,min(timeStamp)	FirstTime
--			,max(timeStamp)	LastTime
--FROM		Users.dbo.frmTransactions
--WHERE		nullif(Category,'') IS NOT NULL
--GROUP BY	Category