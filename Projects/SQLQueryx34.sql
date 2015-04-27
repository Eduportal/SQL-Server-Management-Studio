DECLARE	@search VarChar(8000)
SET	@search = 'ledridge'




	SELECT		TID,Value
	FROM		Users.dbo.frmData FD2
	WHERE		FD2.CID IN (14248,14249)
		--AND	FD2.TID = 123456

	SELECT		TID,Value
	FROM		Users.dbo.frmData FD2
	WHERE		FD2.CID IN (5099)
		--AND	FD2.TID = 123456

USE [users]
GO



SELECT		FT.[TID]									[Ticket_ID]
			,'http://intranet.seattle.gettyimages.com/forms/TransactionView.asp?'
				+ 'commID=376&comm=Change%20Control&TID='
				+ CAST(FT.TID AS VarChar)
				+ '&service=Change%20Control%20Request'				[Ticket_Link]
			,FT.[FID]
			,FT.[WID]
			,FT.[userID]								[Creator_ID]
			,FD1.Value								[Creator_Name]
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
			,REPLACE(FD2.Value,'sev','')						[Severity]
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
	JOIN		Users.dbo.frmData FD1
		ON	FD1.CID IN (5099)
		AND	FD1.TID = FT.TID
	JOIN		Users.dbo.frmData FD2
		ON	FD2.CID IN (14248,14249)
		AND	FD2.TID = FT.TID					
	WHERE		FT.FID = 840
		AND	(
			FT.TID IN	( --ALL TID THAT HAVE A NOTE WITH CRITERA MATCH
				SELECT		DISTINCT
						TID
				FROM		Users.dbo.frmNotes
				--WHERE		[notes] like '%' + @Search + '%'
				--	OR	[userName] like '%' + @Search + '%'
				--	OR	[userEmail] like '%' + @Search + '%'
				WHERE		CONTAINS (notes, @Search)
					OR	CONTAINS (UserName, @Search)
					OR	CONTAINS (UserEmail, @Search)
				)
		--OR	[handler]	like '%' + @Search + '%'
		--OR	[category]	like '%' + @Search + '%'
		--OR	[category2]	like '%' + @Search + '%'
		--OR	[category3]	like '%' + @Search + '%'
		--OR	[subject]	like '%' + @Search + '%'
		--OR	[FD1].[Value]	like '%' + @Search + '%'
		OR	CONTAINS ([handler], @Search)
		OR	CONTAINS ([category], @Search)
		OR	CONTAINS ([category2], @Search)
		OR	CONTAINS ([category3], @Search)
		OR	CONTAINS ([subject], @Search)
		OR	CONTAINS ([FD1].[Value], @Search)		
			)