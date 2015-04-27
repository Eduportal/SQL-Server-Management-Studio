USE [dbacentral]
GO



/****** Object:  View [dbo].[DBA_Dashboard_Chart_NOCTicketCounts]    Script Date: 05/25/2010 16:32:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW	[dbo].[DBA_Dashboard_Chart_NOCTicketCounts]
AS
SELECT		[TicketDate]	     [Date]
		, SUM([TS_DBA_SEV1]) [DBA_SEV1]
		, SUM([TS_DBA_SEV2]) [DBA_SEV2]
		, SUM([TS_DBA_SEV3]) [DBA_SEV3]
		, SUM([TS_DBA_SEV1])+SUM([TS_DBA_SEV2])+SUM([TS_DBA_SEV3]) [DBA]
		, CAST(SUM([TS_DBA_SEV1]) AS VarChar(10))+'-'+CAST(SUM([TS_DBA_SEV2]) AS VarChar(10))+'-'+CAST(SUM([TS_DBA_SEV3]) AS VarChar(10)) [DBA_Lab]
		, SUM([TS_WEB_SEV1]) [WEB_SEV1]
		, SUM([TS_WEB_SEV2]) [WEB_SEV2]
		, SUM([TS_WEB_SEV3]) [WEB_SEV3]
		, SUM([TS_WEB_SEV1])+SUM([TS_WEB_SEV2])+SUM([TS_WEB_SEV3]) [WEB]
		, CAST(SUM([TS_WEB_SEV1]) AS VarChar(10))+'-'+CAST(SUM([TS_WEB_SEV2]) AS VarChar(10))+'-'+CAST(SUM([TS_WEB_SEV3]) AS VarChar(10)) [WEB_Lab]
FROM		(		
		SELECT		CAST( DATEPART(year,[Date Received])AS VarChar(4)) + '-' + RIGHT('00'+CAST(DATEPART(month,[Date Received])AS VarChar(2)),2) [TicketDate]
				,[Ticket]
				,CASE MIN([Severity])
					WHEN 1 
					THEN MAX([TS_DBA_Notes]|[TS_DBA_Assign]|[TS_DBA_Create])
					ELSE 0 END					AS [TS_DBA_SEV1]
				,CASE MIN([Severity])
					WHEN 2 
					THEN MAX([TS_DBA_Notes]|[TS_DBA_Assign]|[TS_DBA_Create])
					ELSE 0 END					AS [TS_DBA_SEV2]
				,CASE MIN([Severity])
					WHEN 3 
					THEN MAX([TS_DBA_Notes]|[TS_DBA_Assign]|[TS_DBA_Create])
					ELSE 0 END					AS [TS_DBA_SEV3]
				
				,CASE MIN([Severity])
					WHEN 1 
					THEN MAX([TS_WEB_Notes]|[TS_WEB_Assign]|[TS_WEB_Create])
					ELSE 0 END					AS [TS_WEB_SEV1]
				,CASE MIN([Severity])
					WHEN 2 
					THEN MAX([TS_WEB_Notes]|[TS_WEB_Assign]|[TS_WEB_Create])
					ELSE 0 END					AS [TS_WEB_SEV2]
				,CASE MIN([Severity])
					WHEN 3 
					THEN MAX([TS_WEB_Notes]|[TS_WEB_Assign]|[TS_WEB_Create])
					ELSE 0 END					AS [TS_WEB_SEV3]
		FROM		[dbo].[DBA_Dashboard_TicketDetails_NOC]		
		WHERE		[Date Received] >= CAST(YEAR(GetDate())-1 AS VarChar(4)) + '-01-01'-- THIS AND LAST YEAR
                AND	ISNUMERIC(Severity) = 1
		GROUP BY	CAST( DATEPART(year,[Date Received])AS VarChar(4)) + '-' + RIGHT('00'+CAST(DATEPART(month,[Date Received])AS VarChar(2)),2)
				,[Ticket]
		) ChartData
GROUP BY	[TicketDate]

GO


