USE [users]
GO

/****** Object:  View [dbo].[DBA_Dashboard_TicketDetails_CC]    Script Date: 5/23/2013 9:49:02 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW	[dbo].[DBA_Dashboard_TicketDetails_CC]
AS
SELECT		
		*
FROM		(
		Select		DISTINCT
					T1.TID [Ticket]
					,'http://intranet.seattle.gettyimages.com/forms/TransactionView.asp?commID=376&comm=Change%20Control&TID={0}&service=Change%20Control%20Request' [Ticket Mask]
					,T6.name [Sender]
					,T6.ID [Sender ID]
					,'http://intranet.seattle.gettyimages.com/search/user_record.asp?id={0}' [Sender ID Mask]
					,CASE T1.priority
						WHEN 1 THEN 'Low'
						WHEN 2 THEN 'Medium'
						WHEN 3 THEN 'High'
						WHEN 4 THEN 'Critical'
						ELSE 'Project' END [Priority]
					,T1.subject [Subject]
					,T1.workflowTitle [Current Workflow Stage]
					,T1.category [Category 1]
					,T1.category2 [Category 2]
					,T1.category3 [Category 3]
					,T5.formTitle [Service]

					,CAST([dbaadmin].[dbo].[dbaudf_ReturnWord]([start].value,2)+' '
					  +[dbaadmin].[dbo].[dbaudf_ReturnWord]([start].value,3)+' '
					  +[dbaadmin].[dbo].[dbaudf_ReturnWord]([start].value,4)+' '
					  +[dbaadmin].[dbo].[dbaudf_ReturnWord]([start].value,5) AS DATETIME) [Start Time]
					,CAST([dbaadmin].[dbo].[dbaudf_ReturnWord]([end].value,2)+' '
					  +[dbaadmin].[dbo].[dbaudf_ReturnWord]([end].value,3)+' '
					  +[dbaadmin].[dbo].[dbaudf_ReturnWord]([end].value,4)+' '
					  +[dbaadmin].[dbo].[dbaudf_ReturnWord]([end].value,5) AS DATETIME) [END Time]
					--,[start].value [Start Time] --DATEADD(hour,-8,CONVERT(DateTime,LTRIM(REPLACE(REPLACE(RIGHT([start].value,LEN([start].value) - CHARINDEX(',',[start].value)),' UTC',''),' GMT','')),113)) [Start Time]
					--,[end].value [END Time] --DATEADD(hour,-8,CONVERT(DateTime,LTRIM(REPLACE(REPLACE(RIGHT([end].value,LEN([end].value) - CHARINDEX(',',[end].value)),' UTC',''),' GMT','')),113)) [End Time]

					,T1.timeStamp [Date Received] 
					,T1.timeStamp2 [Date Resolved]
					,T1.timeStamp3 [Date Updated]
					,T1.handler [Handler]
					,CASE T1.Status WHEN '0' THEN 'Open' ELSE 'Closed' END [Status]
					,CASE WHEN T3.TS_Team = 'DBA' THEN 1 ELSE 0 END AS [TS_DBA_Notes]
					,CASE WHEN T4.TS_Team = 'DBA' THEN 1 ELSE 0 END AS [TS_DBA_Assign]
					,CASE WHEN T6.TS_Team = 'DBA' THEN 1 ELSE 0 END AS [TS_DBA_Create]
					,CASE WHEN T3.TS_Team = 'WEB' THEN 1 ELSE 0 END AS [TS_WEB_Notes]                
					,CASE WHEN T4.TS_Team = 'WEB' THEN 1 ELSE 0 END AS [TS_WEB_Assign]                
					,CASE WHEN T6.TS_Team = 'WEB' THEN 1 ELSE 0 END AS [TS_WEB_Create]                
		FROM		Users.dbo.frmTransactions T1
		LEFT JOIN	Users.dbo.frmNotes T2
			ON	T1.TID = T2.TID

		LEFT JOIN		(		-- NOTE USER
				SELECT		id
						,name
						,CASE	WHEN ID IN (3529,7519,833,1474,6542,7368,7075,7255) THEN 'DBA'
							WHEN ID IN (3532,1626,1988,6611,6838,6384) THEN 'WEB'
							ELSE '' END AS TS_Team
				FROM		Users.dbo.tbl_users
				) T3
			ON	T2.userid = T3.id

		LEFT JOIN		(		-- HANDLER USER
				SELECT		id
						,name
						,CASE	WHEN ID IN (3529,7519,833,1474,6542,7368,7075,7255) THEN 'DBA'
							WHEN ID IN (3532,1626,1988,6611,6838,6384) THEN 'WEB'
							ELSE '' END AS TS_Team
				FROM		Users.dbo.tbl_users
				) T4
			ON	T1.handler = T4.name

		LEFT Join		Users.dbo.frmForm T5		-- FORMS
			On	T1.FID = T5.FID
			and	T5.commID = '376'

		LEFT JOIN		(		-- SENDER USER
				SELECT		id
						,name
						,CASE	WHEN ID IN (3529,7519,833,1474,6542,7368,7075,7255) THEN 'DBA'
							WHEN ID IN (3532,1626,1988,6611,6838,6384) THEN 'WEB'
							ELSE '' END AS TS_Team
				FROM		Users.dbo.tbl_users
				) T6
			ON	T1.userid = T6.ID


		Left Join	Users.dbo.frmData [start]
			on	[start].TID = T1.TID
			AND	[start].CID = '15558'

		LEFT Join	Users.dbo.frmData [end]
			on	[end].TID = T1.TID
			AND	[end].CID ='5035'	

		WHERE		T1.timeStamp >= CAST(YEAR(GetDate())-1 AS VarChar(4)) + '-01-01'
			--AND	(  
			--	T3.TS_Team IN ('WEB','DBA')		-- HAS NOTES FROM A TEAM OR TEAM MEMBER
			--	OR 
			--	T4.TS_Team IN ('WEB','DBA')		-- ASSIGNED TO A TEAM OR TEAM MEMBER
			--	OR 
			--	T6.TS_Team IN ('WEB','DBA')		-- ASSIGNED TO A TEAM OR TEAM MEMBER
			--	)

		--UNION ALL


		--Select		DISTINCT
		--			T1.TID [Ticket]
		--			,'http://intranet.seattle.gettyimages.com/forms/TransactionView.asp?commID=376&comm=Change%20Control&TID={0}&service=Change%20Control%20Request' [Ticket Mask]
		--			,T6.name [Sender]
		--			,T6.ID [Sender ID]
		--			,'http://intranet.seattle.gettyimages.com/search/user_record.asp?id={0}' [Sender ID Mask]
		--			,CASE T1.priority
		--				WHEN 1 THEN 'Low'
		--				WHEN 2 THEN 'Medium'
		--				WHEN 3 THEN 'High'
		--				WHEN 4 THEN 'Critical'
		--				ELSE 'Project' END [Priority] 
		--			,T1.subject [Subject]
		--			,T1.workflowTitle [Current Workflow Stage]
		--			,T1.category [Category 1]
		--			,T1.category2 [Category 2]
		--			,T1.category3 [Category 3]
		--			,T5.formTitle [Service]

		--			,CAST([dbaadmin].[dbo].[dbaudf_ReturnWord]([start].value,2)+' '
		--			  +[dbaadmin].[dbo].[dbaudf_ReturnWord]([start].value,3)+' '
		--			  +[dbaadmin].[dbo].[dbaudf_ReturnWord]([start].value,4)+' '
		--			  +[dbaadmin].[dbo].[dbaudf_ReturnWord]([start].value,5) AS DATETIME) [Start Time]
		--			,CAST([dbaadmin].[dbo].[dbaudf_ReturnWord]([end].value,2)+' '
		--			  +[dbaadmin].[dbo].[dbaudf_ReturnWord]([end].value,3)+' '
		--			  +[dbaadmin].[dbo].[dbaudf_ReturnWord]([end].value,4)+' '
		--			  +[dbaadmin].[dbo].[dbaudf_ReturnWord]([end].value,5) AS DATETIME) [END Time]
		--			--,[start].value [Start Time] --DATEADD(hour,-8,CONVERT(DateTime,LTRIM(REPLACE(REPLACE(RIGHT([start].value,LEN([start].value) - CHARINDEX(',',[start].value)),' UTC',''),' GMT','')),113)) [Start Time]
		--			--,[end].value [END Time] --DATEADD(hour,-8,CONVERT(DateTime,LTRIM(REPLACE(REPLACE(RIGHT([end].value,LEN([end].value) - CHARINDEX(',',[end].value)),' UTC',''),' GMT','')),113)) [End Time]

		--			,T1.timeStamp [Date Received]
		--			,T1.timeStamp2 [Date Resolved]
		--			,T1.timeStamp3 [Date Updated]
		--			,T1.handler [Handler]
		--			,CASE T1.Status WHEN '0' THEN 'Open' ELSE 'Closed' END [Status]
		--			,CASE WHEN T3.TS_Team = 'DBA' THEN 1 ELSE 0 END AS [TS_DBA_Notes]
		--			,CASE WHEN T4.TS_Team = 'DBA' THEN 1 ELSE 0 END AS [TS_DBA_Assign]
		--			,CASE WHEN T6.TS_Team = 'DBA' THEN 1 ELSE 0 END AS [TS_DBA_Create]
		--			,CASE WHEN T3.TS_Team = 'WEB' THEN 1 ELSE 0 END AS [TS_WEB_Notes]                
		--			,CASE WHEN T4.TS_Team = 'WEB' THEN 1 ELSE 0 END AS [TS_WEB_Assign]                
		--			,CASE WHEN T6.TS_Team = 'WEB' THEN 1 ELSE 0 END AS [TS_WEB_Create]                
		--FROM		TicketingArchive.dbo.frmTransactions T1
		--Left JOIN	TicketingArchive.dbo.frmNotes T2
		--	ON	T1.TID = T2.TID
		--LEFT JOIN		(
		--		SELECT		id
		--				,name
		--				,CASE	WHEN ID IN (3529,7519,833,1474,6542,7368,7075,7255) THEN 'DBA'
		--					WHEN ID IN (3532,1626,1988,6611,6838,6384) THEN 'WEB'
		--					ELSE '' END AS TS_Team
		--		FROM		Users.dbo.tbl_users
		--		) T3
		--	ON	T2.userid = T3.id
		--LEFT JOIN		(
		--		SELECT		id
		--				,name
		--				,CASE	WHEN ID IN (3529,7519,833,1474,6542,7368,7075,7255) THEN 'DBA'
		--					WHEN ID IN (3532,1626,1988,6611,6838,6384) THEN 'WEB'
		--					ELSE '' END AS TS_Team
		--		FROM		Users.dbo.tbl_users
		--		) T4
		--	ON	T1.handler = T4.name
		--LEFT Join		Users.dbo.frmForm T5 
		--	On	T1.FID = T5.FID
		--	and	T5.commID = '376'
		--LEFT JOIN		(
		--		SELECT		id
		--				,name
		--				,CASE	WHEN ID IN (3529,7519,833,1474,6542,7368,7075,7255) THEN 'DBA'
		--					WHEN ID IN (3532,1626,1988,6611,6838,6384) THEN 'WEB'
		--					ELSE '' END AS TS_Team
		--		FROM		Users.dbo.tbl_users
		--		) T6
		--	ON	T1.userid = T6.ID
		--Left Join	Users.dbo.frmData [start]
		--	on	[start].TID = T1.TID
		--	AND	[start].CID = '15558'
		--LEFT Join	Users.dbo.frmData [end]
		--	on	[end].TID = T1.TID
		--	AND	[end].CID ='5035'		
		--WHERE		T1.timeStamp >= CAST(YEAR(GetDate())-1 AS VarChar(4)) + '-01-01'
		--	--AND	(  
		--	--	T3.TS_Team IN ('WEB','DBA')		-- HAS NOTES FROM A TEAM OR TEAM MEMBER
		--	--	OR 
		--	--	T4.TS_Team IN ('WEB','DBA')		-- ASSIGNED TO A TEAM OR TEAM MEMBER
		--	--	OR 
		--	--	T6.TS_Team IN ('WEB','DBA')		-- ASSIGNED TO A TEAM OR TEAM MEMBER
		--	--	)
		) DBA_Dashboard_TicketDetails_NOC

GO
