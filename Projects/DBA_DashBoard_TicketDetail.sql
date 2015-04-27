USE [DEPLcontrol]
GO
DROP VIEW [dbo].[DBA_DashBoard_TicketDetail]
GO
CREATE VIEW [dbo].[DBA_DashBoard_TicketDetail]
AS
SELECT		TOP 100 PERCENT
		[APPLname] AS [APPL]	 
		,[DEPLcontrol].[dbo].[db_sequence].[DBname] AS [DB]	 
		,[Process]  AS [Process]	 
		,[ProcessType]  AS [Type]	 
		,[ProcessDetail]  AS [Detail] 	 
		,[Status] AS [Status] 	 
		,[SQLname]  AS [SQL] 	 
		,[Domain]  AS [Domain] 	 
		,[BASEfolder] AS [Base] 	 	 
		,'File://\\'+LEFT([SQLname],CHARINDEX('\',[SQLname]+'\')-1) AS [Go]
		,[Gears_id] 	 
FROM [DEPLcontrol].[dbo].[Request_detail] 
JOIN [DEPLcontrol].[dbo].[db_sequence]
ON [DEPLcontrol].[dbo].[Request_detail].DBName = [DEPLcontrol].[dbo].[db_sequence].[dbname]
ORDER BY [SQLname],CASE [Process] WHEN 'Start' THEN 1 WHEN 'Restore' THEN 2 WHEN 'Deploy' THEN 3 WHEN 'End' THEN 4 END,seq_id
GO


SELECT * FROM [DBA_DashBoard_TicketDetail]
WHERE [Gears_id] = 43442
