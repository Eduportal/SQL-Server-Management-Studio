--DECLARE @RC int
--DECLARE @gears_id int
--DECLARE @report_fromdate datetime
--DECLARE @report_only char(1)

---- TODO: Set parameter values here.

--EXECUTE @RC = [DEPLcontrol].[dbo].[dpsp_Status] 43179
--   @gears_id
--  ,@report_fromdate
--  ,@report_only
--GO

SELECT [Gears_id]
      ,[ProjectName]
      ,[Environment]
      ,[StartDate]
      ,[StartTime]
      ,[Status]
      ,[DBAapproved]
      ,[DBAapprover]
      ,[RequestDate]
      --,[Notes]
      --,[ProjectNum]
      --,[ModDate]
  FROM [DEPLcontrol].[dbo].[Request]
WHERE [Status] NOT IN ('Gears Completed','Gears Canceled','completed','cancelled')



SELECT [APPLname] AS [APPL]
      ,[DBname] AS [DB]
      ,[Process]
      ,[ProcessType]
      ,[ProcessDetail]
      ,CASE [Status]
	WHEN 'completed' THEN '<font color=green>' + [Status] + '</font>'
	WHEN 'in-work' THEN '<font color=blue>' + [Status] + '</font>'
	ELSE '<font color=grey>' + [Status] + '</font>'
	END [Status]
      ,[SQLname] AS [SQL]
      ,[Domain]
      ,[BASEfolder] AS [Base]
      ,LEFT([SQLname],CHARINDEX('\',[SQLname]+'\')-1) AS [Go]
  FROM [DEPLcontrol].[dbo].[Request_detail]
  WHERE [Gears_id] = 43179
  ORDER BY [SQLname],CASE [Process]
	WHEN 'Start' THEN 1
	WHEN 'Restore' THEN 2
	WHEN 'Deploy' THEN 3
	WHEN 'End' THEN 4
	END

OrderID:<A href="http://www.someplace.com/orders/orderDetail.aspx?id={v}">{v}</A>
  
--WHERE [Gears_id] IN
--	(
--	SELECT	DISTINCT
--		[Gears_id]
--	  FROM	[DEPLcontrol].[dbo].[Request]
--	WHERE	[Status] NOT IN ('Gears Completed','Gears Canceled','completed','cancelled')
--	)

