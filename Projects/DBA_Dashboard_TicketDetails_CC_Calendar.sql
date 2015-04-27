ALTER VIEW [DBA_Dashboard_TicketDetails_CC_Calendar]
AS
SELECT		T1.[Date Received]
			,T1.[Start Time]
			,T1.[END Time]
			,T1.[Date Resolved]
			,T1.[Ticket]
			,T1.[Subject]
			,[users].[dbo].[udf_StripHTML]([users].[dbo].[TicketNotesAsText] (T1.[Ticket])) [Description]
			,[Ticket Mask]
			,[Sender]
			,[Sender ID]
			,[Sender ID Mask]
			,[Priority]
			,[Current Workflow Stage]
			,[Category 1]
			,[Category 2]
			,[Category 3]
			,[Service]
			,[Date Updated]
			,[Handler]
			,[Status]
			,[TS_DBA_Notes]
			,[TS_DBA_Assign]
			,[TS_DBA_Create]

FROM		[users].[dbo].[DBA_Dashboard_TicketDetails_CC] T1
WHERE		[Start Time] >= CAST(CONVERT(VarChar(12),getdate() - ((DATEPART(weekday,getdate())-1)+7),101)AS DateTime)
	AND		[END Time] < CAST(CONVERT(VarChar(12),getdate() - ((DATEPART(weekday,getdate())-1)-14),101)AS DateTime)
ORDER BY	2,3