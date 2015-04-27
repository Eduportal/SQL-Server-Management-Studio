DROP VIEW	[dbo].[DBA_DashBoard_GearsTicket_HL_Local_Amer]
DROP VIEW	[dbo].[DBA_DashBoard_GearsTicket_HL_Local_Prod]
DROP VIEW	[dbo].[DBA_DashBoard_GearsTicket_HL_Local_Stage]
DROP VIEW	[dbo].[DBA_DashBoard_GearsTicket_HL_Remote_Prod]
DROP VIEW	[dbo].[DBA_DashBoard_GearsTicket_HL_Remote_Stage]
GO
CREATE VIEW	[dbo].[DBA_DashBoard_GearsTicket_HL_Local_Amer]
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
WHERE [Domain] NOT IN ('STAGE','PRODUCTION')
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

CREATE VIEW	[dbo].[DBA_DashBoard_GearsTicket_HL_Local_Stage]
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
WHERE [Domain] = 'STAGE'
GO


CREATE VIEW	[dbo].[DBA_DashBoard_GearsTicket_HL_Remote_Prod]
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
FROM [SEAEXSQLMAIL].[DEPLcontrol].[dbo].[control_HL]
GO

CREATE VIEW	[dbo].[DBA_DashBoard_GearsTicket_HL_Remote_Stage]
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
FROM [SEAFRESTGSQL].[DEPLcontrol].[dbo].[control_HL]
GO


DROP FUNCTION DBA_DashBoard_GearsTicket_HL 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION DBA_DashBoard_GearsTicket_HL 
(
	@Gears_ID int
	,@UseRemote bit = 0 
)
RETURNS 
@Results TABLE 
(
	[Domain]		sysname
	,[SQLName]		sysname
	,[HandShake_Status]	VarChar(25)
	,[HandShake_Sql]	VarChar(25)
	,[HandShake_Agent]	VarChar(25)
	,[HandShake_DEPLjobs]	VarChar(25)
	,[Setup_Status]		VarChar(25)
	,[Restore_Status]	VarChar(25)
	,[Deploy_Status]	VarChar(25)
	,[End_Status]		VarChar(25)
	,[LogPath]		nVarChar(4000)
)
AS
BEGIN
	INSERT INTO	@Results
	SELECT		[domain]
			,[SQLname]
			,[HandShake_Status]
			,[HandShake_sql]
			,[HandShake_agent]
			,[HandShake_DEPLjobs]
			,[Setup_Status]
			,[Restore_Status]
			,[Deploy_Status]
			,[End_Status]
			,[LogPath]
	FROM		[DEPLcontrol].[dbo].[DBA_DashBoard_GearsTicket_HL_Local_Amer]
	WHERE		[Gears_id]=@Gears_ID
	
	IF @UseRemote = 0
	BEGIN
		INSERT INTO	@Results
		SELECT		[domain]
				,[SQLname]
				,[HandShake_Status]
				,[HandShake_sql]
				,[HandShake_agent]
				,[HandShake_DEPLjobs]
				,[Setup_Status]
				,[Restore_Status]
				,[Deploy_Status]
				,[End_Status]
				,[LogPath]
		FROM		[DEPLcontrol].[dbo].[DBA_DashBoard_GearsTicket_HL_Local_Stage]
		WHERE		[Gears_id]=@Gears_ID	
		
		INSERT INTO	@Results
		SELECT		[domain]
				,[SQLname]
				,[HandShake_Status]
				,[HandShake_sql]
				,[HandShake_agent]
				,[HandShake_DEPLjobs]
				,[Setup_Status]
				,[Restore_Status]
				,[Deploy_Status]
				,[End_Status]
				,[LogPath]
		FROM		[DEPLcontrol].[dbo].[DBA_DashBoard_GearsTicket_HL_Local_Prod]
		WHERE		[Gears_id]=@Gears_ID	
	END
	ELSE
	BEGIN
		INSERT INTO	@Results
		SELECT		[domain]
				,[SQLname]
				,[HandShake_Status]
				,[HandShake_sql]
				,[HandShake_agent]
				,[HandShake_DEPLjobs]
				,[Setup_Status]
				,[Restore_Status]
				,[Deploy_Status]
				,[End_Status]
				,[LogPath]
		FROM		[DEPLcontrol].[dbo].[DBA_DashBoard_GearsTicket_HL_Remote_Stage]
		WHERE		[Gears_id]=@Gears_ID	
		
		INSERT INTO	@Results
		SELECT		[domain]
				,[SQLname]
				,[HandShake_Status]
				,[HandShake_sql]
				,[HandShake_agent]
				,[HandShake_DEPLjobs]
				,[Setup_Status]
				,[Restore_Status]
				,[Deploy_Status]
				,[End_Status]
				,[LogPath]
		FROM		[DEPLcontrol].[dbo].[DBA_DashBoard_GearsTicket_HL_Remote_Prod]
		WHERE		[Gears_id]=@Gears_ID	
	END
	RETURN 
END
GO



--Get Data Locally
SELECT		[domain]
		,[SQLname]
		,[HandShake_Status]
		,[HandShake_sql]
		,[HandShake_agent]
		,[HandShake_DEPLjobs]
		,[Setup_Status]
		,[Restore_Status]
		,[Deploy_Status]
		,[End_Status]
		,[LogPath]
FROM		DBA_DashBoard_GearsTicket_HL (43482,0)
ORDER BY	[domain],[SQLname]

--Get Data Remotely
SELECT		[domain]
		,[SQLname]
		,[HandShake_Status]
		,[HandShake_sql]
		,[HandShake_agent]
		,[HandShake_DEPLjobs]
		,[Setup_Status]
		,[Restore_Status]
		,[Deploy_Status]
		,[End_Status]
		,[LogPath]
FROM		DBA_DashBoard_GearsTicket_HL (43482,1)
ORDER BY	[domain],[SQLname]

SELECT		[domain]
		,[SQLname]
		,[HandShake_Status]
		,[HandShake_sql]
		,[HandShake_agent]
		,[HandShake_DEPLjobs]
		,[Setup_Status]
		,[Restore_Status]
		,[Deploy_Status]
		,[End_Status]
		,[LogPath]
FROM		DBA_DashBoard_GearsTicket_HL (@ID,@Remote)
ORDER BY	[domain],[SQLname]