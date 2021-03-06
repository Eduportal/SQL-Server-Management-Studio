USE [DEPLcontrol]
GO
/****** Object:  View [dbo].[DBA_DashBoard_GearsTicket_HL_Local_Prod]    Script Date: 10/4/2013 11:02:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW	[dbo].[DBA_DashBoard_GearsTicket_HL_Local_Prod]
AS
SELECT [Gears_id]
,[domain]
,[SQLname]
,CASE [HandShake_Status]
	WHEN 'in-work' THEN '~/Images/1.png' 
	WHEN 'completed' THEN '~/Images/2.png' 
	WHEN 'notify-dba' THEN '~/Images/3.png' 
	ELSE '~/Images/0.png' 
	END AS [HandShake_Status]
,CASE [HandShake_sql]
	WHEN 'OK' THEN '~/Images/2.png' 
	ELSE '~/Images/1.png' 
	END AS [HandShake_sql]
,CASE [HandShake_agent]
	WHEN 'OK' THEN '~/Images/2.png' 
	ELSE '~/Images/1.png' 
	END AS [HandShake_agent]
,CASE [HandShake_DEPLjobs]
	WHEN 'OK' THEN '~/Images/2.png' 
	ELSE '~/Images/1.png' 
	END AS [HandShake_DEPLjobs]
,CASE [Setup_Status]
	WHEN 'in-work' THEN '~/Images/1.png' 
	WHEN 'completed' THEN '~/Images/2.png' 
	WHEN 'notify-dba' THEN '~/Images/3.png' 
	ELSE '~/Images/0.png' 
	END AS [Setup_Status]
,CASE [Restore_Status]
	WHEN 'in-work' THEN '~/Images/1.png' 
	WHEN 'completed' THEN '~/Images/2.png' 
	WHEN 'notify-dba' THEN '~/Images/3.png' 
	ELSE '~/Images/0.png' 
	END AS [Restore_Status]
,CASE [Deploy_Status]
	WHEN 'in-work' THEN '~/Images/1.png' 
	WHEN 'completed' THEN '~/Images/2.png' 
	WHEN 'notify-dba' THEN '~/Images/3.png' 
	ELSE '~/Images/0.png' 
	END AS [Deploy_Status]
,CASE [End_Status]
	WHEN 'in-work' THEN '~/Images/1.png' 
	WHEN 'completed' THEN '~/Images/2.png' 
	WHEN 'notify-dba' THEN '~/Images/3.png' 
	ELSE '~/Images/0.png' 
	END AS [End_Status]
,'file://\\'+LEFT([SQLname]+'\',CHARINDEX('\',[SQLname]+'\')-1)+'\'+REPLACE([SQLname],'\','$')+'_SQLjob_logs\' AS [LogPath]
FROM [DEPLcontrol].[dbo].[control_HL]
WHERE [Domain] = 'PRODUCTION'

GO
