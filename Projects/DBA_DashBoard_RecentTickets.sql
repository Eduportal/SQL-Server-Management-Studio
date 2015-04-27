DROP VIEW DBA_DashBoard_RecentTickets
GO
CREATE VIEW DBA_DashBoard_RecentTickets
AS
SELECT	TOP 25
	[Gears_id] AS [ID] , CASE 
WHEN [InDC] = 'N' THEN '<span style=''background:PaleGoldenrod''>' + [Environment] + '</span>'
WHEN [Status] = 'complete' THEN '<font color=green>' + [Environment] + '</font>'
WHEN [Status] Like '%work%' THEN '<span style=''background:PaleGreen''><font color=red>' + [Environment] + '</font></span>'
WHEN [Status] = 'pending' THEN '<span style=''background:Lightcoral''><font color=black>' + [Environment] + '</font></span>'
WHEN [Status] = 'Gears Completed' THEN '<font color=MidnightBlue>' + [Environment] + '</font>'
ELSE [Environment]
END AS [Env] , CASE 
WHEN [InDC] = 'N' THEN '<span style=''background:PaleGoldenrod''>' + [StartTime] + '</span>'
WHEN [Status] = 'complete' THEN '<font color=green>' + [StartTime] + '</font>'
WHEN [Status] Like '%work%' THEN '<span style=''background:PaleGreen''><font color=red>' + [StartTime] + '</font></span>'
WHEN [Status] = 'pending' THEN '<span style=''background:Lightcoral''><font color=black>' + [StartTime] + '</font></span>'
WHEN [Status] = 'Gears Completed' THEN '<font color=MidnightBlue>' + [StartTime] + '</font>'
ELSE [StartTime]
END AS [StartTime] , CASE 
WHEN [InDC] = 'N' THEN '<span style=''background:PaleGoldenrod''>' + [Status] + '</span>'
WHEN [Status] = 'complete' THEN '<font color=green>' + [Status] + '</font>'
WHEN [Status] Like '%work%' THEN '<span style=''background:PaleGreen''><font color=red>' + [Status] + '</font></span>'
WHEN [Status] = 'pending' THEN '<span style=''background:Lightcoral''><font color=black>' + [Status] + '</font></span>'
WHEN [Status] = 'Gears Completed' THEN '<font color=MidnightBlue>' + [Status] + '</font>'
ELSE [Status]
END AS [Status] , CASE 
WHEN [InDC] = 'N' THEN '<span style=''background:PaleGoldenrod''>' + [DBAapproved] + '</span>'
WHEN [Status] = 'complete' THEN '<font color=green>' + '   '+[DBAapproved]+'    ' + '</font>'
WHEN [Status] Like '%work%' THEN '<span style=''background:PaleGreen''><font color=red>' + '   '+[DBAapproved]+'    ' + '</font></span>'
WHEN [Status] = 'pending' THEN '<span style=''background:Lightcoral''><font color=black>' + '   '+[DBAapproved]+'    ' + '</font></span>'
WHEN [Status] = 'Gears Completed' THEN '<font color=MidnightBlue>' + '   '+[DBAapproved]+'    ' + '</font>'
ELSE [DBAapproved]
END AS [Approved] , CASE 
WHEN [InDC] = 'N' THEN '<span style=''background:PaleGoldenrod''>' + [DBAapprover] + '</span>'
WHEN [Status] = 'complete' THEN '<font color=green>' + [DBAapprover] + '</font>'
WHEN [Status] Like '%work%' THEN '<span style=''background:PaleGreen''><font color=red>' + [DBAapprover] + '</font></span>'
WHEN [Status] = 'pending' THEN '<span style=''background:Lightcoral''><font color=black>' + [DBAapprover] + '</font></span>'
WHEN [Status] = 'Gears Completed' THEN '<font color=MidnightBlue>' + [DBAapprover] + '</font>'
ELSE [DBAapprover]
END AS [Approver] , CASE 
WHEN [InDC] = 'N' THEN '<span style=''background:PaleGoldenrod''>' + [RequestDate] + '</span>'
WHEN [Status] = 'complete' THEN '<font color=green>' + [RequestDate] + '</font>'
WHEN [Status] Like '%work%' THEN '<span style=''background:PaleGreen''><font color=red>' + [RequestDate] + '</font></span>'
WHEN [Status] = 'pending' THEN '<span style=''background:Lightcoral''><font color=black>' + [RequestDate] + '</font></span>'
WHEN [Status] = 'Gears Completed' THEN '<font color=MidnightBlue>' + [RequestDate] + '</font>'
ELSE [RequestDate]
END AS [Requested] , CASE 
WHEN [InDC] = 'N' THEN '<span style=''background:PaleGoldenrod''>' + [InDC] + '</span>'
WHEN [Status] = 'complete' THEN '<font color=green>' + [InDC] + '</font>'
WHEN [Status] Like '%work%' THEN '<span style=''background:PaleGreen''><font color=red>' + [InDC] + '</font></span>'
WHEN [Status] = 'pending' THEN '<span style=''background:Lightcoral''><font color=black>' + [InDC] + '</font></span>'
WHEN [Status] = 'Gears Completed' THEN '<font color=MidnightBlue>' + [InDC] + '</font>'
ELSE [InDC]
END AS [InDC]
,CAST([RequestDate] AS DateTime) [RD]
,CAST([StartTime] AS DateTime) [ST]
,[Notes]
FROM 
(
SELECT		[Gears_id]
		,[Environment]
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
		,COALESCE((SELECT [Status] FROM [gears].[dbo].[BUILD_REQUESTS] WHERE [build_request_id] = [Gears_id]),[Status])[Status]
		,[DBAapproved]
		,[DBAapprover]
		,Convert(VarChar(50),[RequestDate],120) [RequestDate]
		,'Y' [InDC]
		,[Notes]
FROM		[DEPLcontrol].[dbo].[Request] 
UNION ALL
SELECT		[build_request_id] [Gears_id]
		,T2.environment_name [Environment]
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
FROM		[gears].[dbo].[BUILD_REQUESTS] T1
JOIN		[gears].dbo.ENVIRONMENT T2
	ON	T1.[environment_id] = T2.[environment_id]
WHERE		[build_request_id] NOT IN (SELECT [Gears_id] FROM [DEPLcontrol].[dbo].[Request])
) Tickets
WHERE		Convert(VarChar(10),[RequestDate],120) = CONVERT(VarChar(10),GetDate()-1,120)	--YESTERDAY
	OR	Convert(VarChar(10),[RequestDate],120) = CONVERT(VarChar(10),GetDate(),120)	--TODAY
ORDER BY	CAST([StartTime] AS DateTime) DESC
GO



SELECT TOP 25 [ID]
      ,[Env]
      ,[StartTime]
      ,[Status]
      ,[Approved]
      ,[Approver]
      ,[Requested]
      ,[InDC]
      ,[Notes]
  FROM [DEPLcontrol].[dbo].[DBA_DashBoard_RecentTickets]
  ORDER BY [ST] 














--UID=DBAsledridge;Initial Catalog=DEPLcontrol;Data Source=SEAFRESQLDBA01

--000:000
--000:0000
--0000:000
--0000:0000

--SELECT COUNT(*) FROM [DEPLcontrol].[dbo].[Request] WHERE [Status] = 'pending' and [DBAapproved] != 'y'


--SELECT COUNT(*) FROM [DEPLcontrol].[dbo].[Request] WHERE [Status] = 'pending' and [DBAapproved] = 'y' and 
--CAST(Convert(VarChar(50),[StartDate],101) + ' ' + [StartTime] AS DateTime) < GetDate()

--SELECT COUNT(*) FROM [DEPLcontrol].[dbo].[Request] WHERE
--CAST(Convert(VarChar(50),[StartDate],101) + ' ' + [StartTime] AS DateTime) >= CAST(CONVERT(VarChar(12),GetDate(),101)AS DateTime) 

--SELECT COUNT(*)
--FROM [DEPLcontrol].[dbo].[Request] 
--WHERE [StartDate] = CAST(CONVERT(VarChar(12),GetDate(),101)AS DateTime)

--SELECT (SELECT COUNT(*)
--	FROM [DEPLcontrol].[dbo].[Request] 
--	WHERE [StartDate] = CAST(CONVERT(VarChar(12),GetDate(),101)AS DateTime)
--	)
--	,(SELECT COUNT(*)
--	FROM [DEPLcontrol].[dbo].[Request] 
--	WHERE [StartDate] = CAST(CONVERT(VarChar(12),GetDate()-1,101)AS DateTime)
--	)
--	,MIN(TicketCount)
--	,AVG(TicketCount)
--	,MAX(TicketCount)
--FROM
--(SELECT COUNT(*) TicketCount
--FROM [DEPLcontrol].[dbo].[Request] 
--WHERE [StartDate] < CAST(CONVERT(VarChar(12),GetDate(),101)AS DateTime)
--AND [StartDate] >= CAST(CONVERT(VarChar(12),GetDate()-30,101)AS DateTime)
--AND DATEPART(dw,[StartDate]) BETWEEN 2 AND 6
--GROUP BY [StartDate]) Data


--select 1 tc union select 0

--SELECT COUNT(*) [Data]
--, CAST(COUNT(*)AS VarChar(2)) + ' Pending Ticket(s) Waiting for Approval.' [Label]
--FROM [DEPLcontrol].[dbo].[Request] WHERE [Status] = 'pending' and [DBAapproved] != 'y'
--UNION ALL
--SELECT	CASE WHEN (SELECT COUNT(*) FROM [DEPLcontrol].[dbo].[Request] WHERE [Status] = 'pending' and [DBAapproved] != 'y') > 0 THEN 0 ELSE 1 END
--	,CASE WHEN (SELECT COUNT(*) FROM [DEPLcontrol].[dbo].[Request] WHERE [Status] = 'pending' and [DBAapproved] != 'y') > 0 THEN '' ELSE 'No Pending Ticket(s) Waiting for Approval.' END








--SELECT COUNT(*) [Data], CAST(Count(*)AS VarCHAR(2)) + ' Ticket(s)'  [Label] 
--FROM [DEPLcontrol].[dbo].[Request] WHERE [Status] = 'pending' and [DBAapproved] != 'y' 
--UNION ALL 
--SELECT CASE WHEN COUNT(*) > 0 THEN 0 ELSE 1 END , CAST(Count(*)AS VarCHAR(2)) + ' Ticket(s)' 
--FROM [DEPLcontrol].[dbo].[Request] WHERE [Status] = 'pending' and [DBAapproved] != 'y'










