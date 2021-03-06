USE [DEPLcontrol]
GO
/****** Object:  View [dbo].[DBA_Dashboard_GearsTicketCounts_Detail_Today]    Script Date: 10/4/2013 11:02:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW	[dbo].[DBA_Dashboard_GearsTicketCounts_Detail_Today]
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
