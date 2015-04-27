USE [DEPLcontrol]
GO
DROP VIEW [dbo].[DBA_DashBoard_RecentTickets_NOHTML]
GO
CREATE VIEW [dbo].[DBA_DashBoard_RecentTickets_NOHTML]
AS
SELECT	[Gears_id]				AS [ID] 
	,UPPER(REPLACE([Environment],'production','prod')) AS [Env]
	,[ProjectName] + ' ' + [ProjectNum]	AS [Project]
	,[StartTime]				AS [StartTime] 
	,UPPER([Status])			AS [Status] 
	,UPPER([DBAapproved])			AS [Approved] 
	,[DBAapprover]				AS [Approver] 
	,[RequestDate]				AS [Requested] 
	,UPPER([InDC])				AS [InDC]
	,CAST([RequestDate] AS DateTime)	AS [RD]
	,CAST([StartTime] AS DateTime)		AS [ST]

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








----WHERE		Convert(VarChar(10),[RequestDate],120) = CONVERT(VarChar(10),GetDate()-1,120)	--YESTERDAY
----	OR	Convert(VarChar(10),[RequestDate],120) = CONVERT(VarChar(10),GetDate(),120)	--TODAY
--ORDER BY	CAST([StartTime] AS DateTime) DESC




