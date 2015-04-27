USE [users]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







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
		FROM		[Users].[dbo].[DBA_Dashboard_TicketDetails_NOC]		
		WHERE		YEAR([Date Received]) >= YEAR(GetDate())-5 -- THIS AND LAST YEAR
			AND	ISNUMERIC(Severity) = 1
		GROUP BY	CAST( DATEPART(year,[Date Received])AS VarChar(4)) + '-' + RIGHT('00'+CAST(DATEPART(month,[Date Received])AS VarChar(2)),2)
				,[Ticket]
		) ChartData
GROUP BY	[TicketDate]
ORDER BY	1	



					
					

SELECT		[TicketDate]			[Date]
		, SUM([TS_DBA_Critical])	[DBA_Critical]
		, SUM([TS_DBA_High])		[DBA_High]
		, SUM([TS_DBA_Medium])		[DBA_Medium]
		, SUM([TS_DBA_Project])		[DBA_Project]
		, SUM([TS_DBA_Critical])+SUM([TS_DBA_High])+SUM([TS_DBA_Medium])+SUM([TS_DBA_Project]) [DBA]
		, CAST(SUM([TS_DBA_Critical]) AS VarChar(10))+'-'+CAST(SUM([TS_DBA_High]) AS VarChar(10))+'-'+CAST(SUM([TS_DBA_Medium]) AS VarChar(10))+'-'+CAST(SUM([TS_DBA_Project]) AS VarChar(10)) [DBA_Lab]
		, SUM([TS_WEB_Critical])	[WEB_Critical]
		, SUM([TS_WEB_High])		[WEB_High]
		, SUM([TS_WEB_Medium])		[WEB_Medium]
		, SUM([TS_WEB_Project])		[WEB_Project]
		, SUM([TS_WEB_Critical])+SUM([TS_WEB_High])+SUM([TS_WEB_Medium])+SUM([TS_WEB_Project]) [WEB]
		, CAST(SUM([TS_WEB_Critical]) AS VarChar(10))+'-'+CAST(SUM([TS_WEB_High]) AS VarChar(10))+'-'+CAST(SUM([TS_WEB_Medium]) AS VarChar(10))+'-'+CAST(SUM([TS_WEB_Project]) AS VarChar(10)) [WEB_Lab]
FROM		(		
		SELECT		CAST( DATEPART(year,[Date Received])AS VarChar(4)) + '-' + RIGHT('00'+CAST(DATEPART(month,[Date Received])AS VarChar(2)),2) [TicketDate]
				,[Ticket]
				,CASE MAX([Priority])
					WHEN 'Critical' 
					THEN MAX([TS_DBA_Notes]|[TS_DBA_Assign]|[TS_DBA_Create])
					ELSE 0 END					AS [TS_DBA_Critical]
				,CASE MAX([Priority])
					WHEN 'High' 
					THEN MAX([TS_DBA_Notes]|[TS_DBA_Assign]|[TS_DBA_Create])
					ELSE 0 END					AS [TS_DBA_High]
				,CASE MAX([Priority])
					WHEN 'Medium' 
					THEN MAX([TS_DBA_Notes]|[TS_DBA_Assign]|[TS_DBA_Create])
					ELSE 0 END					AS [TS_DBA_Medium]
				,CASE MAX([Priority])
					WHEN 'Project' 
					THEN MAX([TS_DBA_Notes]|[TS_DBA_Assign]|[TS_DBA_Create])
					ELSE 0 END					AS [TS_DBA_Project]
				,CASE MAX([Priority])
					WHEN 'Critical' 
					THEN MAX([TS_WEB_Notes]|[TS_WEB_Assign]|[TS_WEB_Create])
					ELSE 0 END					AS [TS_WEB_Critical]
				,CASE MAX([Priority])
					WHEN 'High' 
					THEN MAX([TS_WEB_Notes]|[TS_WEB_Assign]|[TS_WEB_Create])
					ELSE 0 END					AS [TS_WEB_High]
				,CASE MAX([Priority])
					WHEN 'Medium' 
					THEN MAX([TS_WEB_Notes]|[TS_WEB_Assign]|[TS_WEB_Create])
					ELSE 0 END					AS [TS_WEB_Medium]
				,CASE MAX([Priority])
					WHEN 'Project' 
					THEN MAX([TS_WEB_Notes]|[TS_WEB_Assign]|[TS_WEB_Create])
					ELSE 0 END					AS [TS_WEB_Project]
		FROM		[Users].[dbo].[DBA_Dashboard_TicketDetails_CC]		
		WHERE		YEAR([Date Received]) >= YEAR(GetDate())-5 -- THIS AND LAST YEAR


		GROUP BY	CAST( DATEPART(year,[Date Received])AS VarChar(4)) + '-' + RIGHT('00'+CAST(DATEPART(month,[Date Received])AS VarChar(2)),2)
				,[Ticket]
		) ChartData
GROUP BY	[TicketDate]
ORDER BY	1
			