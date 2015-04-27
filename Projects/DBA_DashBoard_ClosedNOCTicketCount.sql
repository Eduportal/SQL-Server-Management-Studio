create view	DBA_DashBoard_ClosedNOCTicketCount_Weekly
AS
select		datepart(year,[Date Resolved]) [Year]
		,datepart(week,[Date Resolved]) [Week]
		,Severity
		--,[Category 1]
		,[Category 2]
		,count(*) [Tickets]
from		dbo.DBA_DashBoard_ClosedNOCTickets
GROUP BY	datepart(year,[Date Resolved])
		,datepart(week,[Date Resolved])
		,Severity
		--,[Category 1]
		,[Category 2]
--order by 1 desc, 2 desc
GO


create view	DBA_DashBoard_ClosedNOCTicketCount_Monthly
AS
select		datepart(year,[Date Resolved]) [Year]
		,datepart(Month,[Date Resolved]) [Month]
		,Severity
		--,[Category 1]
		,[Category 2]
		,count(*) [Tickets]
from		dbo.DBA_DashBoard_ClosedNOCTickets
GROUP BY	datepart(year,[Date Resolved])
		,datepart(Month,[Date Resolved])
		,Severity
		--,[Category 1]
		,[Category 2]
--order by 1 desc, 2 desc
GO


