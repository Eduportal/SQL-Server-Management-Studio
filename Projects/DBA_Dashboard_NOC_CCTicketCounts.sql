
DROP VIEW	dbo.DBA_Dashboard_NOC_CCTicketCounts_Summary_ThisMonth
GO
CREATE VIEW	dbo.DBA_Dashboard_NOC_CCTicketCounts_Summary_ThisMonth
AS
SELECT		[Source] + ' - ' + [priority] [Status]
		, [Tickets] AS TicketCount
		, [Tickets] * 5 AS BarWidth
		, '~/Images/Digits/' + SUBSTRING(RIGHT ('000' + CAST([Tickets] AS VARCHAR(3)), 3), 1, 1) + '.png' AS Digit1
		, '~/Images/Digits/' + SUBSTRING(RIGHT ('000' + CAST([Tickets] AS VARCHAR(3)), 3), 2, 1) + '.png' AS Digit2
		, '~/Images/Digits/' + SUBSTRING(RIGHT ('000' + CAST([Tickets] AS VARCHAR(3)), 3), 3, 1) + '.png' AS Digit3 
FROM		(
		SELECT [Year]
		      ,[Month]
		      ,'Change Control' [source]
		      ,[priority]
		      ,[Tickets]
		  FROM [users].[dbo].[DBA_DashBoard_ClosedCCTicketCount_Monthly]
		UNION ALL
		SELECT [Year]
		      ,[Month]
		      ,'NOC Alert' [source]
		      ,[Category 2]
		      ,SUM([Tickets]) [Tickets]
		  FROM [users].[dbo].[DBA_DashBoard_ClosedNOCTicketCount_Monthly]
		GROUP BY	[Year]
				,[Month]
				,[Category 2]
		--order by 1 desc, 2 desc,3,4
		) Data
WHERE		[Year]  = Year(Getdate())
	AND	[Month] = Month(Getdate())
--ORDER BY	1
GO


DROP VIEW	dbo.DBA_Dashboard_NOC_CCTicketCounts_Detail_ThisMonth
GO
CREATE VIEW	dbo.DBA_Dashboard_NOC_CCTicketCounts_Detail_ThisMonth
AS
SELECT		[Source] + ' - ' + [priority] [Status]
		,[Ticket]
		,[Ticket Mask]
		,[Sender]
		,[Sender ID]
		,[Sender ID Mask]
		,[Subject] 
FROM		(
		SELECT [Ticket]
		      ,[Ticket Mask]
		      ,[Sender]
		      ,[Sender ID]
		      ,[Sender ID Mask]
		      ,'Change Control' [source]
		      ,[Priority]
		      ,[Subject]
		      ,Year([Date Resolved])[Year]
		      ,Month([Date Resolved]) [Month]
		  FROM [users].[dbo].[DBA_DashBoard_ClosedCCTickets]
		UNION ALL
		SELECT [Ticket]
		      ,[Ticket Mask]
		      ,[Sender]
		      ,[Sender ID]
		      ,[Sender ID Mask]
		      ,'NOC Alert' [source]
		      ,[Category 2]
		      ,[Subject]
		      ,Year([Date Resolved])[Year]
		      ,Month([Date Resolved]) [Month]
		  FROM [users].[dbo].[DBA_DashBoard_ClosedNOCTickets]
		) Data
WHERE		[Year]  = Year(Getdate())
	AND	[Month] = Month(Getdate())
GO


DROP VIEW	dbo.DBA_Dashboard_NOC_CCTicketCounts_Summary_LastMonth
GO
CREATE VIEW	dbo.DBA_Dashboard_NOC_CCTicketCounts_Summary_LastMonth
AS
SELECT		[Source] + ' - ' + [priority] [Status]
		, [Tickets] AS TicketCount
		, [Tickets] * 5 AS BarWidth
		, '~/Images/Digits/' + SUBSTRING(RIGHT ('000' + CAST([Tickets] AS VARCHAR(3)), 3), 1, 1) + '.png' AS Digit1
		, '~/Images/Digits/' + SUBSTRING(RIGHT ('000' + CAST([Tickets] AS VARCHAR(3)), 3), 2, 1) + '.png' AS Digit2
		, '~/Images/Digits/' + SUBSTRING(RIGHT ('000' + CAST([Tickets] AS VARCHAR(3)), 3), 3, 1) + '.png' AS Digit3 
FROM		(
		SELECT [Year]
		      ,[Month]
		      ,'Change Control' [source]
		      ,[priority]
		      ,[Tickets]
		  FROM [users].[dbo].[DBA_DashBoard_ClosedCCTicketCount_Monthly]
		UNION ALL
		SELECT [Year]
		      ,[Month]
		      ,'NOC Alert' [source]
		      ,[Category 2]
		      ,SUM([Tickets]) [Tickets]
		  FROM [users].[dbo].[DBA_DashBoard_ClosedNOCTicketCount_Monthly]
		GROUP BY	[Year]
				,[Month]
				,[Category 2]
		--order by 1 desc, 2 desc,3,4
		) Data
WHERE		[Year]  = Year(dateadd(month,-1,Getdate()))
	AND	[Month] = Month(dateadd(month,-1,Getdate()))
--ORDER BY	1
GO


DROP VIEW	dbo.DBA_Dashboard_NOC_CCTicketCounts_Detail_LastMonth
GO
CREATE VIEW	dbo.DBA_Dashboard_NOC_CCTicketCounts_Detail_LastMonth
AS
SELECT		[Source] + ' - ' + [priority] [Status]
		,[Ticket]
		,[Ticket Mask]
		,[Sender]
		,[Sender ID]
		,[Sender ID Mask]
		,[Subject] 
FROM		(
		SELECT [Ticket]
		      ,[Ticket Mask]
		      ,[Sender]
		      ,[Sender ID]
		      ,[Sender ID Mask]
		      ,'Change Control' [source]
		      ,[Priority]
		      ,[Subject]
		      ,Year([Date Resolved])[Year]
		      ,Month([Date Resolved]) [Month]
		  FROM [users].[dbo].[DBA_DashBoard_ClosedCCTickets]
		UNION ALL
		SELECT [Ticket]
		      ,[Ticket Mask]
		      ,[Sender]
		      ,[Sender ID]
		      ,[Sender ID Mask]
		      ,'NOC Alert' [source]
		      ,[Category 2]
		      ,[Subject]
		      ,Year([Date Resolved])[Year]
		      ,Month([Date Resolved]) [Month]
		  FROM [users].[dbo].[DBA_DashBoard_ClosedNOCTickets]
		) Data
WHERE		[Year]  = Year(dateadd(month,-1,Getdate()))
	AND	[Month] = Month(dateadd(month,-1,Getdate()))
--ORDER BY	1
GO
