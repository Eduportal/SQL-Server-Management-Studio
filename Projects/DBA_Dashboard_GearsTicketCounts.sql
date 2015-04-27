DROP VIEW	DBA_Dashboard_GearsTicketCounts_Summary_Today
GO
CREATE VIEW	DBA_Dashboard_GearsTicketCounts_Summary_Today
AS
SELECT		UPPER	(
			CASE
			WHEN InDC = 'N'			THEN 'Not In DEPL Control' 
			WHEN Status = 'COMPLETE'	THEN Status  
			WHEN Approved = 'n'		THEN 'Waiting For Approval' 
			WHEN StartTime >= Getdate()	THEN 'Past Start Time' 
			ELSE Status END
			) AS Status
		, COUNT(*) AS TicketCount
		, COUNT(*) * 5 AS BarWidth
		, '~/Images/Digits/' + SUBSTRING(RIGHT ('000' + CAST(COUNT(*) AS VARCHAR(3)), 3), 1, 1) + '.png' AS Digit1
		, '~/Images/Digits/' + SUBSTRING(RIGHT ('000' + CAST(COUNT(*) AS VARCHAR(3)), 3), 2, 1) + '.png' AS Digit2
		, '~/Images/Digits/' + SUBSTRING(RIGHT ('000' + CAST(COUNT(*) AS VARCHAR(3)), 3), 3, 1) + '.png' AS Digit3 
FROM		DBA_DashBoard_RecentGearsTickets 
WHERE		StartTime >= CAST(CONVERT (VarChar(12), GETDATE(), 101) AS DateTime)
	OR	(InDC = 'Y' and Status !='Complete')
GROUP BY	UPPER	(
			CASE
			WHEN InDC = 'N'			THEN 'Not In DEPL Control' 
			WHEN Status = 'COMPLETE'	THEN Status  
			WHEN Approved = 'n'		THEN 'Waiting For Approval' 
			WHEN StartTime >= Getdate()	THEN 'Past Start Time' 
			ELSE Status END
			) 
GO

DROP VIEW	DBA_Dashboard_GearsTicketCounts_Detail_Today
GO
CREATE VIEW	DBA_Dashboard_GearsTicketCounts_Detail_Today
AS
SELECT		UPPER	(
			CASE
			WHEN InDC = 'N'			THEN 'Not In DEPL Control' 
			WHEN Status = 'COMPLETE'	THEN Status  
			WHEN Approved = 'n'		THEN 'Waiting For Approval' 
			WHEN StartTime >= Getdate()	THEN 'Past Start Time' 
			ELSE Status END
			) AS AggStatus
		, *
FROM		DBA_DashBoard_RecentGearsTickets 
WHERE		StartTime >= CAST(CONVERT (VarChar(12), GETDATE(), 101) AS DateTime)
	OR	(InDC = 'Y' and Status !='Complete')
GO

DROP VIEW	DBA_Dashboard_GearsTicketCounts_Summary_Yesterday
GO
CREATE VIEW	DBA_Dashboard_GearsTicketCounts_Summary_Yesterday
AS
SELECT		UPPER	(
			CASE
			WHEN InDC = 'N'			THEN 'Not In DEPL Control' 
			WHEN Status = 'COMPLETE'	THEN Status  
			WHEN Approved = 'n'		THEN 'Waiting For Approval' 
			WHEN StartTime >= Getdate()	THEN 'Past Start Time' 
			ELSE Status END
			) AS Status
		, COUNT(*) AS TicketCount
		, COUNT(*) * 5 AS BarWidth
		, '~/Images/Digits/' + SUBSTRING(RIGHT ('000' + CAST(COUNT(*) AS VARCHAR(3)), 3), 1, 1) + '.png' AS Digit1
		, '~/Images/Digits/' + SUBSTRING(RIGHT ('000' + CAST(COUNT(*) AS VARCHAR(3)), 3), 2, 1) + '.png' AS Digit2
		, '~/Images/Digits/' + SUBSTRING(RIGHT ('000' + CAST(COUNT(*) AS VARCHAR(3)), 3), 3, 1) + '.png' AS Digit3 
FROM		DBA_DashBoard_RecentGearsTickets 
WHERE		StartTime >= CAST(CONVERT (VarChar(12), GETDATE()-1, 101) AS DateTime)
	AND	StartTime < CAST(CONVERT (VarChar(12), GETDATE(), 101) AS DateTime)
GROUP BY	UPPER	(
			CASE
			WHEN InDC = 'N'			THEN 'Not In DEPL Control' 
			WHEN Status = 'COMPLETE'	THEN Status  
			WHEN Approved = 'n'		THEN 'Waiting For Approval' 
			WHEN StartTime >= Getdate()	THEN 'Past Start Time' 
			ELSE Status END
			) 
GO

DROP VIEW	DBA_Dashboard_GearsTicketCounts_Detail_Yesterday
GO
CREATE VIEW	DBA_Dashboard_GearsTicketCounts_Detail_Yesterday
AS
SELECT		UPPER	(
			CASE
			WHEN InDC = 'N'			THEN 'Not In DEPL Control' 
			WHEN Status = 'COMPLETE'	THEN Status  
			WHEN Approved = 'n'		THEN 'Waiting For Approval' 
			WHEN StartTime >= Getdate()	THEN 'Past Start Time' 
			ELSE Status END
			) AS AggStatus
		, *
FROM		DBA_DashBoard_RecentGearsTickets 
WHERE		StartTime >= CAST(CONVERT (VarChar(12), GETDATE()-1, 101) AS DateTime)
	AND	StartTime < CAST(CONVERT (VarChar(12), GETDATE(), 101) AS DateTime)
GO