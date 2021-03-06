USE [DEPLcontrol]
GO
/****** Object:  View [dbo].[DBA_DashBoard_RecentGearsTickets]    Script Date: 10/4/2013 11:02:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DBA_DashBoard_RecentGearsTickets]
AS
WITH	[CCApproved]
		AS
		(
		SELECT		[build_request_id] [Gears_id]
					,CASE t.[category] WHEN 'Recently Approved' THEN 1 ELSE 0 END [CCApproved]
		from		[gears].[dbo].[BUILD_REQUESTS] gbr
		JOIN		[SEAINTRASQL01].[users].[dbo].frmTransactions t
			ON		t.TID = gbr.change_control_ticket
			AND		t.FID IN (831,850)
		)
SELECT	Tickets.[Gears_id]								AS [ID] 
	,UPPER(REPLACE([Environment],'production','prod'))	AS [Env]
	,[ProjectName] + ' ' + [ProjectNum]					AS [Project]
	,[StartTime]										AS [StartTime] 
	,UPPER([Status])									AS [Status] 
	,CASE	WHEN [ProjectName] Like 'SQL_misc%' 
			THEN '-'
			ELSE UPPER([DBAapproved]) END				AS [Approved] 
	,COALESCE(
		CASE	WHEN [Environment] != 'production' 
				THEN '-'
				WHEN [CCApproved] = 1 THEN 'Y' 
				WHEN [CCApproved] = 0 THEN 'N' 
				ELSE '-' END,'-')						AS [CCApproved]
		,[DBAapprover]									AS [Approver] 
	,[RequestDate]										AS [Requested] 
	,UPPER([InDC])										AS [InDC]
	,CAST([RequestDate] AS DateTime)					AS [RD]
	,CAST([StartTime] AS DateTime)						AS [ST]
	,[Notes]
FROM 
(
SELECT		TOP 50
		[Gears_id]
		,[Environment]
		,[ProjectName]
		,[ProjectNum]
		,Convert(VarChar(10),[StartDate],120)+' '
		      +RIGHT('00'+CAST(CASE WHEN RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([StartTime],'|'),1),2) > 23 THEN '00'
			ELSE RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([StartTime],'|'),1),2) END
			+ CASE
			   WHEN RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([StartTime],'|'),1),2) BETWEEN 1 and 11
				AND [StartTime] LIKE '%pm%' THEN 12 ELSE 0 END AS varCHAR(2)),2) +':'
		      +CASE WHEN RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([StartTime],'|'),2),2) > 59 THEN '00'
			ELSE RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([StartTime],'|'),2),2) END +':'
		      +CASE WHEN RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([StartTime],'|'),3),2) > 59 THEN '00'
			ELSE RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([StartTime],'|'),3),2) END AS [StartTime]
		,COALESCE((SELECT [Status] FROM [gears].[dbo].[BUILD_REQUESTS] WITH(NOLOCK) WHERE [build_request_id] = [Gears_id]),[Status])[Status]
		,[DBAapproved]
		,[DBAapprover]
		,Convert(VarChar(50),[RequestDate],120) [RequestDate]
		,'Y' [InDC]
		,[Notes]
FROM		[DEPLcontrol].[dbo].[Request] WITH(NOLOCK)
ORDER BY	1 DESC 
UNION ALL
SELECT		TOP 50
		[build_request_id] [Gears_id]
		,T2.environment_name [Environment]
		,project_name
		,project_version
		,Convert(VarChar(10),[target_date],120)+' '
			+RIGHT('00'+CAST(CASE WHEN RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([target_time],'|'),1),2) > 23 THEN '00'
			  ELSE RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([target_time],'|'),1),2) END
			  + CASE
			    WHEN RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([target_time],'|'),1),2) BETWEEN 1 and 11
				AND [target_time] LIKE '%pm%' THEN 12 ELSE 0 END AS varCHAR(2)),2) +':'
			+CASE WHEN RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([target_time],'|'),2),2) > 59 THEN '00'
			  ELSE RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([target_time],'|'),2),2) END +':'
			+CASE WHEN RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([target_time],'|'),3),2) > 59 THEN '00'
			  ELSE RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([target_time],'|'),3),2) END AS [StartTime]
		,[status]
		,'n' [DBAapproved]
		,'' [DBAapprover]
		,Convert(VarChar(50),[request_date],120) [RequestDate]
		,'N' [InDC]
		,[notes]
FROM		[gears].[dbo].[BUILD_REQUESTS] T1 WITH(NOLOCK) 
JOIN		[gears].dbo.ENVIRONMENT T2  WITH(NOLOCK)
	ON	T1.[environment_id] = T2.[environment_id]
JOIN		[gears].dbo.PROJECTS T3 WITH(NOLOCK)
	ON	T1.project_id = T3.Project_id
WHERE		[build_request_id] NOT IN (SELECT TOP 100 [Gears_id] FROM [DEPLcontrol].[dbo].[Request] WITH(NOLOCK) ORDER BY 1 DESC)
ORDER BY	1 desc
) Tickets
LEFT JOIN CCApproved
	ON		CCApproved.[Gears_id] = Tickets.[Gears_id]


GO
EXEC sys.sp_addextendedproperty @name=N'BuildApplication', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'DBA_DashBoard_RecentGearsTickets'
GO
EXEC sys.sp_addextendedproperty @name=N'BuildBranch', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'DBA_DashBoard_RecentGearsTickets'
GO
EXEC sys.sp_addextendedproperty @name=N'BuildNumber', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'DBA_DashBoard_RecentGearsTickets'
GO
EXEC sys.sp_addextendedproperty @name=N'DeplFileName', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'DBA_DashBoard_RecentGearsTickets'
GO
EXEC sys.sp_addextendedproperty @name=N'Version', @value=N'1.0.0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'DBA_DashBoard_RecentGearsTickets'
GO
