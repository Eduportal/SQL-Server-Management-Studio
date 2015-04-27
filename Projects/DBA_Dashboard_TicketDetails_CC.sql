USE [users]
GO
CREATE VIEW	DBA_Dashboard_TicketDetails_CC
AS
SELECT		top 100 PERCENT
                T1.TID [Ticket],
                'http://intranet.seattle.gettyimages.com/forms/TransactionView.asp?commID=376&comm=Change%20Control&TID='+CAST(T1.TID AS VarChar(50))+'&service=Change%20Control%20Request' [Ticket Link], 
                T6.name [Sender],
                T6.ID [Sender ID],
                'http://intranet.seattle.gettyimages.com/search/user_record.asp?id='+CAST(T6.ID AS VarChar(50))+'' [Sender Link],
                CASE T1.priority
			WHEN 1 THEN 'Low'
			WHEN 2 THEN 'Medium'
			WHEN 3 THEN 'High'
			WHEN 4 THEN 'Critical'
			ELSE 'Project' END [Priority], 
                T1.subject [Subject], 
		T1.workflowTitle [Current Workflow Stage],
                T1.category [Review Category], 
                T1.category2 [Location], 
                T1.category3 [Support Team], 
                T5.formTitle [Service], 
                DATEADD(hour,-8,CONVERT(DateTime,LTRIM(REPLACE(REPLACE(RIGHT([start].value,LEN([start].value) - CHARINDEX(',',[start].value)),' UTC',''),' GMT','')),113)) [Start Time],
                DATEADD(hour,-8,CONVERT(DateTime,LTRIM(REPLACE(REPLACE(RIGHT([end].value,LEN([end].value) - CHARINDEX(',',[end].value)),' UTC',''),' GMT','')),113)) [End Time],  
                T1.timeStamp [Date Received], 
                T1.timeStamp2 [Date Resolved], 
                T1.timeStamp3 [Date Updated], 
                T1.handler [Handler],
                CASE T1.Status WHEN '0' THEN 'Open' ELSE 'Closed' END [Status]
		,T2.userName
		,T2.timeStamp AS [Date Noted]
		,T2.notes
		,T3.TS_Team Team_a -- Notes from Team
		,T4.TS_Team Team_b -- Assigned to Team
		,T6.TS_Team Team_c -- Created By Team
		,CASE WHEN T3.TS_Team = 'DBA' or T4.TS_Team = 'DBA' THEN 1 ELSE 0 END AS [TS_DBA]
		,CASE WHEN T3.TS_Team = 'WEB' or T4.TS_Team = 'WEB' THEN 1 ELSE 0 END AS [TS_WEB]
FROM		Users.dbo.frmTransactions T1
JOIN		Users.dbo.frmNotes T2
	ON	T1.TID = T2.TID
JOIN		(
		SELECT		id
				,name
				,CASE	WHEN ID IN (3529,7519,833,1474,6542,7368,7075,7255) THEN 'DBA'
					WHEN ID IN (3532,1626,1988,6611,6838,6384) THEN 'WEB'
					ELSE '' END AS TS_Team
		FROM		Users.dbo.tbl_users
		) T3
	ON	T2.userid = T3.id
JOIN		(
		SELECT		id
				,name
				,CASE	WHEN ID IN (3529,7519,833,1474,6542,7368,7075,7255) THEN 'DBA'
					WHEN ID IN (3532,1626,1988,6611,6838,6384) THEN 'WEB'
					ELSE '' END AS TS_Team
		FROM		Users.dbo.tbl_users
		) T4
	ON	T1.handler = T4.name
Join		Users.dbo.frmForm T5 
	On	T1.FID = T5.FID
	and	T5.commID = '376'			-- Change Control	
JOIN		(
		SELECT		id
				,name
				,CASE	WHEN ID IN (3529,7519,833,1474,6542,7368,7075,7255) THEN 'DBA'
					WHEN ID IN (3532,1626,1988,6611,6838,6384) THEN 'WEB'
					ELSE '' END AS TS_Team
		FROM		Users.dbo.tbl_users
		) T6
	ON	T1.userid = T6.ID
Join		Users.dbo.frmData [start]
	on	[start].TID = T1.TID
	AND	[start].CID ='15558'	--Start Date/Time
Join		Users.dbo.frmData [end]
	on	[end].TID = T1.TID
	AND	[end].CID ='5035'	--End Date/Time	
WHERE		year(T1.timeStamp) >= year(Getdate())-1
	AND	(  
		T3.TS_Team IN ('WEB','DBA')		-- HAS NOTES FROM A TEAM OR TEAM MEMBER
		OR 
		T4.TS_Team IN ('WEB','DBA')		-- ASSIGNED TO A TEAM OR TEAM MEMBER
		OR 
		T6.TS_Team IN ('WEB','DBA')		-- ASSIGNED TO A TEAM OR TEAM MEMBER
		)

UNION 

SELECT		top 100 PERCENT
                T1.TID [Ticket],
                'http://intranet.seattle.gettyimages.com/forms/TransactionView.asp?commID=376&comm=Change%20Control&TID='+CAST(T1.TID AS VarChar(50))+'&service=Change%20Control%20Request' [Ticket Link], 
                T6.name [Sender],
                T6.ID [Sender ID],
                'http://intranet.seattle.gettyimages.com/search/user_record.asp?id='+CAST(T6.ID AS VarChar(50))+'' [Sender Link],
                CASE T1.priority
			WHEN 1 THEN 'Low'
			WHEN 2 THEN 'Medium'
			WHEN 3 THEN 'High'
			WHEN 4 THEN 'Critical'
			ELSE 'Project' END [Priority], 
                T1.subject [Subject], 
		T1.workflowTitle [Current Workflow Stage],
                T1.category [Review Category], 
                T1.category2 [Location], 
                T1.category3 [Support Team], 
                T5.formTitle [Service], 
                DATEADD(hour,-8,CONVERT(DateTime,LTRIM(REPLACE(REPLACE(RIGHT([start].value,LEN([start].value) - CHARINDEX(',',[start].value)),' UTC',''),' GMT','')),113)) [Start Time],
                DATEADD(hour,-8,CONVERT(DateTime,LTRIM(REPLACE(REPLACE(RIGHT([end].value,LEN([end].value) - CHARINDEX(',',[end].value)),' UTC',''),' GMT','')),113)) [End Time],  
                T1.timeStamp [Date Received], 
                T1.timeStamp2 [Date Resolved], 
                T1.timeStamp3 [Date Updated], 
                T1.handler [Handler],
                CASE T1.Status WHEN '0' THEN 'Open' ELSE 'Closed' END [Status]
		,T2.userName
		,T2.timeStamp AS [Date Noted]
		,T2.notes
		,T3.TS_Team Team_a -- Notes from Team
		,T4.TS_Team Team_b -- Assigned to Team
		,T6.TS_Team Team_c -- Created By Team
		,CASE WHEN T3.TS_Team = 'DBA' or T4.TS_Team = 'DBA' THEN 1 ELSE 0 END AS [TS_DBA]
		,CASE WHEN T3.TS_Team = 'WEB' or T4.TS_Team = 'WEB' THEN 1 ELSE 0 END AS [TS_WEB]
FROM		TicketingArchive.dbo.frmTransactions T1
JOIN		TicketingArchive.dbo.frmNotes T2
	ON	T1.TID = T2.TID
JOIN		(
		SELECT		id
				,name
				,CASE	WHEN ID IN (3529,7519,833,1474,6542,7368,7075,7255) THEN 'DBA'
					WHEN ID IN (3532,1626,1988,6611,6838,6384) THEN 'WEB'
					ELSE '' END AS TS_Team
		FROM		Users.dbo.tbl_users
		) T3
	ON	T2.userid = T3.id
JOIN		(
		SELECT		id
				,name
				,CASE	WHEN ID IN (3529,7519,833,1474,6542,7368,7075,7255) THEN 'DBA'
					WHEN ID IN (3532,1626,1988,6611,6838,6384) THEN 'WEB'
					ELSE '' END AS TS_Team
		FROM		Users.dbo.tbl_users
		) T4
	ON	T1.handler = T4.name
Join		Users.dbo.frmForm T5 
	On	T1.FID = T5.FID
	and	T5.commID = '376'			-- Change Control	
JOIN		(
		SELECT		id
				,name
				,CASE	WHEN ID IN (3529,7519,833,1474,6542,7368,7075,7255) THEN 'DBA'
					WHEN ID IN (3532,1626,1988,6611,6838,6384) THEN 'WEB'
					ELSE '' END AS TS_Team
		FROM		Users.dbo.tbl_users
		) T6
	ON	T1.userid = T6.ID
Join		TicketingArchive.dbo.frmData [start]
	on	[start].TID = T1.TID
	AND	[start].CID ='15558'	--Start Date/Time
Join		TicketingArchive.dbo.frmData [end]
	on	[end].TID = T1.TID
	AND	[end].CID ='5035'	--End Date/Time	
WHERE		year(T1.timeStamp) >= year(Getdate())-1
	AND	(  
		T3.TS_Team IN ('WEB','DBA')		-- HAS NOTES FROM A TEAM OR TEAM MEMBER
		OR 
		T4.TS_Team IN ('WEB','DBA')		-- ASSIGNED TO A TEAM OR TEAM MEMBER
		OR 
		T6.TS_Team IN ('WEB','DBA')		-- ASSIGNED TO A TEAM OR TEAM MEMBER
		)
Order By	T1.timeStamp desc























