USE [users]
GO
ALTER VIEW	[dbo].[DBA_Dashboard_TicketDetails_NOC]
AS
SELECT		
		*
FROM		(
		Select		DISTINCT
				T1.TID [Ticket],
				'http://intranet.seattle.gettyimages.com/forms/TransactionView.asp?commID=376&comm=Change%20Control&TID={0}&service=Change%20Control%20Request' [Ticket Mask], 
				T6.name [Sender],
				T6.ID [Sender ID],
				'http://intranet.seattle.gettyimages.com/search/user_record.asp?id={0}' [Sender ID Mask],
				CASE T1.priority
					WHEN 1 THEN 'Low'
					WHEN 2 THEN 'Medium'
					WHEN 3 THEN 'High'
					WHEN 4 THEN 'Critical'
					ELSE 'Project' END [Priority], 
				T1.subject [Subject], 
				T1.workflowTitle [Current Workflow Stage],
				T1.category [Category 1], 
				T1.category2 [Category 2], 
				T1.category3 [Category 3], 
				T5.formTitle [Service], 
				REPLACE(Sev.Value,'sev','') [Severity],
				[name].value [Name],  
				T1.timeStamp [Date Received], 
				T1.timeStamp2 [Date Resolved], 
				T1.timeStamp3 [Date Updated], 
				T1.handler [Handler],
				CASE T1.Status WHEN '0' THEN 'Open' ELSE 'Closed' END [Status]
				,CASE WHEN T3.TS_Team = 'DBA' OR T7.TS_Team = 'DBA' THEN 1 ELSE 0 END AS [TS_DBA_Notes]
				,CASE WHEN T4.TS_Team = 'DBA' THEN 1 ELSE 0 END AS [TS_DBA_Assign]
				,CASE WHEN T6.TS_Team = 'DBA' THEN 1 ELSE 0 END AS [TS_DBA_Create]
				,CASE WHEN T3.TS_Team = 'WEB' OR T7.TS_Team = 'WEB' THEN 1 ELSE 0 END AS [TS_WEB_Notes]                
				,CASE WHEN T4.TS_Team = 'WEB' THEN 1 ELSE 0 END AS [TS_WEB_Assign]                
				,CASE WHEN T6.TS_Team = 'WEB' THEN 1 ELSE 0 END AS [TS_WEB_Create]                
		FROM		Users.dbo.frmTransactions T1
		LEFT JOIN	Users.dbo.frmNotes T2
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
		--	and	T5.commID = '184'
			and	T5.formTitle IN ('Seattle NOC Ticket')	
		JOIN		(
				SELECT		id
						,name
						,CASE	WHEN ID IN (3529,7519,833,1474,6542,7368,7075,7255) THEN 'DBA'
							WHEN ID IN (3532,1626,1988,6611,6838,6384) THEN 'WEB'
							ELSE '' END AS TS_Team
				FROM		Users.dbo.tbl_users
				) T6
			ON	T1.userid = T6.ID
		Left Join	Users.dbo.frmData [Sev]
			on	[Sev].TID = T1.TID
			AND	[Sev].CID IN (14248,14249)
		LEFT Join	Users.dbo.frmData [name]
			on	[name].TID = T1.TID
			AND	[name].CID ='5099'	
				LEFT JOIN	(
				SELECT		Notes.TID
						,Users.*
				FROM		Users.dbo.frmNotes Notes
				JOIN		(
						SELECT		name
								,fname
								,lname
								,email
								,CASE	WHEN ID IN (3529,7519,833,1474,6542,7368,7075,7255) THEN 'DBA'
													WHEN ID IN (3532,1626,1988,6611,6838,6384) THEN 'WEB'
													ELSE '' END AS TS_Team
						FROM		Users.dbo.tbl_users
						WHERE		ID IN (3529,7519,833,1474,6542,7368,7075,7255) -- 'DBA'
							OR	ID IN (3532,1626,1988,6611,6838,6384) -- 'WEB'
						) Users
					ON	CHARINDEX(Users.fname,Notes.Notes,0) > 0
					AND	CHARINDEX(Users.lname,Notes.Notes,0) > 0
				) T7
			ON	T7.TID = T1.TID					
		WHERE		(  
				T3.TS_Team IN ('WEB','DBA')		-- HAS NOTES FROM A TEAM OR TEAM MEMBER
				OR 
				T4.TS_Team IN ('WEB','DBA')		-- ASSIGNED TO A TEAM OR TEAM MEMBER
				OR 
				T6.TS_Team IN ('WEB','DBA')		-- ASSIGNED TO A TEAM OR TEAM MEMBER
				OR
				T7.TS_Team IN ('WEB','DBA')		-- Full Name In Notes.
				)

		UNION ALL


		Select		DISTINCT
				T1.TID [Ticket],
				'http://intranet.seattle.gettyimages.com/forms/TransactionView.asp?commID=376&comm=Change%20Control&TID={0}&service=Change%20Control%20Request' [Ticket Mask], 
				T6.name [Sender],
				T6.ID [Sender ID],
				'http://intranet.seattle.gettyimages.com/search/user_record.asp?id={0}' [Sender ID Mask],
				CASE T1.priority
					WHEN 1 THEN 'Low'
					WHEN 2 THEN 'Medium'
					WHEN 3 THEN 'High'
					WHEN 4 THEN 'Critical'
					ELSE 'Project' END [Priority], 
				T1.subject [Subject], 
				T1.workflowTitle [Current Workflow Stage],
				T1.category [Category 1], 
				T1.category2 [Category 2], 
				T1.category3 [Category 3], 
				T5.formTitle [Service], 
				REPLACE(Sev.Value,'sev','') [Severity],
				[name].value [Name],  
				T1.timeStamp [Date Received], 
				T1.timeStamp2 [Date Resolved], 
				T1.timeStamp3 [Date Updated], 
				T1.handler [Handler],
				CASE T1.Status WHEN '0' THEN 'Open' ELSE 'Closed' END [Status]
				,CASE WHEN T3.TS_Team = 'DBA' 
					--OR T7.TS_Team = 'DBA' 
					THEN 1 ELSE 0 END AS [TS_DBA_Notes]
				,CASE WHEN T4.TS_Team = 'DBA' THEN 1 ELSE 0 END AS [TS_DBA_Assign]
				,CASE WHEN T6.TS_Team = 'DBA' THEN 1 ELSE 0 END AS [TS_DBA_Create]
				,CASE WHEN T3.TS_Team = 'WEB' 
					--OR T7.TS_Team = 'WEB' 
					THEN 1 ELSE 0 END AS [TS_WEB_Notes]                
				,CASE WHEN T4.TS_Team = 'WEB' THEN 1 ELSE 0 END AS [TS_WEB_Assign]                
				,CASE WHEN T6.TS_Team = 'WEB' THEN 1 ELSE 0 END AS [TS_WEB_Create]                

		FROM		TicketingArchive.dbo.frmTransactions T1
		Left JOIN	TicketingArchive.dbo.frmNotes T2
			ON	T1.TID = T2.TID
			AND	T2.[timestamp] >= CAST(YEAR(GetDate())-1 AS VarChar(4)) + '-01-01'
			AND	T1.[timestamp] >= CAST(YEAR(GetDate())-1 AS VarChar(4)) + '-01-01'
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
		--	and	T5.commID = '184'
			and	T5.formTitle IN ('Seattle NOC Ticket')
		JOIN		(
				SELECT		id
						,name
						,CASE	WHEN ID IN (3529,7519,833,1474,6542,7368,7075,7255) THEN 'DBA'
							WHEN ID IN (3532,1626,1988,6611,6838,6384) THEN 'WEB'
							ELSE '' END AS TS_Team
				FROM		Users.dbo.tbl_users
				) T6
			ON	T1.userid = T6.ID
		Left Join	TicketingArchive.dbo.frmData [Sev]
			on	[Sev].TID = T1.TID
			AND	[Sev].CID IN (14248,14249)
		LEFT Join	TicketingArchive.dbo.frmData [name]
			on	[name].TID = T1.TID
			AND	[name].CID ='5099'
		LEFT JOIN	(
				SELECT		Notes.TID
						,Users.*
				FROM		TicketingArchive.dbo.frmNotes Notes
				JOIN		(
						SELECT		name
								,fname
								,lname
								,email
								,CASE	WHEN ID IN (3529,7519,833,1474,6542,7368,7075,7255) THEN 'DBA'
													WHEN ID IN (3532,1626,1988,6611,6838,6384) THEN 'WEB'
													ELSE '' END AS TS_Team
						FROM		Users.dbo.tbl_users
						WHERE		ID IN (3529,7519,833,1474,6542,7368,7075,7255) -- 'DBA'
							OR	ID IN (3532,1626,1988,6611,6838,6384) -- 'WEB'
						) Users
					ON	CHARINDEX(Users.fname,Notes.Notes,0) > 0
					AND	CHARINDEX(Users.lname,Notes.Notes,0) > 0
					AND	Notes.[timestamp] >= CAST(YEAR(GetDate())-1 AS VarChar(4)) + '-01-01'
				) T7
			ON	T7.TID = T1.TID					
		WHERE		(  
				T3.TS_Team IN ('WEB','DBA')		-- HAS NOTES FROM A TEAM OR TEAM MEMBER
				OR 
				T4.TS_Team IN ('WEB','DBA')		-- ASSIGNED TO A TEAM OR TEAM MEMBER
				OR 
				T6.TS_Team IN ('WEB','DBA')		-- ASSIGNED TO A TEAM OR TEAM MEMBER
				--OR
				--T7.TS_Team IN ('WEB','DBA')		-- Full Name In Notes.
				)
		) DBA_Dashboard_TicketDetails_NOC

 
