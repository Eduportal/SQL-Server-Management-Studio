DROP VIEW	[dbo].[DBA_DashBoard_GearsTicketDetails_Local_Stage]
DROP VIEW	[dbo].[DBA_DashBoard_GearsTicketDetails_Local_Prod]
DROP VIEW	[dbo].[DBA_DashBoard_GearsTicketDetails_Local_Amer]
DROP VIEW	[dbo].[DBA_DashBoard_GearsTicketDetails_Remote_Stage]
DROP VIEW	[dbo].[DBA_DashBoard_GearsTicketDetails_Remote_Prod]
GO
CREATE VIEW	[dbo].[DBA_DashBoard_GearsTicketDetails_Local_Stage]
AS
SELECT		[Gears_id]
		,[APPLname] AS [APPL]	 
		,T1.[DBname] AS [DB]	 
		,[Process]  AS [Process]	 
		,[ProcessType]  AS [Type]	 
		,[ProcessDetail]  AS [Detail] 	 
		,[Status] AS [Status] 	 
		,[SQLname]  AS [SQL] 	 
		,[Domain]  AS [Domain] 	 
		,[BASEfolder] AS [Base] 	 	 
		,'file://\\'+LEFT([SQLname],CHARINDEX('\',[SQLname]+'\')-1) AS [Go]
		,CASE [Process] WHEN 'Start' THEN 1 WHEN 'Restore' THEN 2 WHEN 'Deploy' THEN 3 WHEN 'End' THEN 4 END AS [RecordOrder]
		,T2.[seq_id]
		,T1.[reqdet_id]
FROM		[DEPLcontrol].[dbo].[Request_detail] T1 WITH(NOLOCK)
LEFT JOIN	[DEPLcontrol].[dbo].[db_sequence] T2 WITH(NOLOCK)
	ON	T1.[DBName] = T2.[dbname]
WHERE		[Domain] = 'STAGE'
GO

CREATE VIEW	[dbo].[DBA_DashBoard_GearsTicketDetails_Local_Prod]
AS
SELECT		[Gears_id]
		,[APPLname] AS [APPL]	 
		,T1.[DBname] AS [DB]	 
		,[Process]  AS [Process]	 
		,[ProcessType]  AS [Type]	 
		,[ProcessDetail]  AS [Detail] 	 
		,[Status] AS [Status] 	 
		,[SQLname]  AS [SQL] 	 
		,[Domain]  AS [Domain] 	 
		,[BASEfolder] AS [Base] 	 	 
		,'file://\\'+LEFT([SQLname],CHARINDEX('\',[SQLname]+'\')-1) AS [Go]
		,CASE [Process] WHEN 'Start' THEN 1 WHEN 'Restore' THEN 2 WHEN 'Deploy' THEN 3 WHEN 'End' THEN 4 END AS [RecordOrder]
		,T2.[seq_id]
		,T1.[reqdet_id]
FROM		[DEPLcontrol].[dbo].[Request_detail] T1 WITH(NOLOCK)
LEFT JOIN	[DEPLcontrol].[dbo].[db_sequence] T2 WITH(NOLOCK)
	ON	T1.[DBName] = T2.[dbname]
WHERE		[Domain] = 'PRODUCTION'
GO

CREATE VIEW	[dbo].[DBA_DashBoard_GearsTicketDetails_Local_Amer]
AS
SELECT		[Gears_id]
		,[APPLname] AS [APPL]	 
		,T1.[DBname] AS [DB]	 
		,[Process]  AS [Process]	 
		,[ProcessType]  AS [Type]	 
		,[ProcessDetail]  AS [Detail] 	 
		,[Status] AS [Status] 	 
		,[SQLname]  AS [SQL] 	 
		,[Domain]  AS [Domain] 	 
		,[BASEfolder] AS [Base] 	 	 
		,'file://\\'+LEFT([SQLname],CHARINDEX('\',[SQLname]+'\')-1) AS [Go]
		,CASE [Process] WHEN 'Start' THEN 1 WHEN 'Restore' THEN 2 WHEN 'Deploy' THEN 3 WHEN 'End' THEN 4 END AS [RecordOrder]
		,T2.[seq_id]
		,T1.[reqdet_id]
FROM		[DEPLcontrol].[dbo].[Request_detail] T1 WITH(NOLOCK)
LEFT JOIN	[DEPLcontrol].[dbo].[db_sequence] T2 WITH(NOLOCK)
	ON	T1.[DBName] = T2.[dbname]
WHERE		[Domain] NOT IN ('STAGE','PRODUCTION')
GO

CREATE VIEW	[dbo].[DBA_DashBoard_GearsTicketDetails_Remote_Stage]
AS
SELECT		[Gears_id]
		,[APPLname] AS [APPL]	 
		,T1.[DBname] AS [DB]	 
		,[Process]  AS [Process]	 
		,[ProcessType]  AS [Type]	 
		,[ProcessDetail]  AS [Detail] 	 
		,[Status] AS [Status] 	 
		,[SQLname]  AS [SQL] 	 
		,[Domain]  AS [Domain] 	 
		,[BASEfolder] AS [Base] 	 	 
		,'file://\\'+LEFT([SQLname],CHARINDEX('\',[SQLname]+'\')-1) AS [Go]
		,CASE [Process] WHEN 'Start' THEN 1 WHEN 'Restore' THEN 2 WHEN 'Deploy' THEN 3 WHEN 'End' THEN 4 END AS [RecordOrder]
		,T2.[seq_id]
		,T1.[reqdet_id]
FROM		[SEAFRESTGSQL].[DEPLcontrol].[dbo].[Request_detail] T1 WITH(NOLOCK)
LEFT JOIN	[SEAFRESTGSQL].[DEPLcontrol].[dbo].[db_sequence] T2 WITH(NOLOCK)
	ON	T1.[DBName] = T2.[dbname]
GO

CREATE VIEW	[dbo].[DBA_DashBoard_GearsTicketDetails_Remote_Prod]
AS
SELECT		[Gears_id]
		,[APPLname] AS [APPL]	 
		,T1.[DBname] AS [DB]	 
		,[Process]  AS [Process]	 
		,[ProcessType]  AS [Type]	 
		,[ProcessDetail]  AS [Detail] 	 
		,[Status] AS [Status] 	 
		,[SQLname]  AS [SQL] 	 
		,[Domain]  AS [Domain] 	 
		,[BASEfolder] AS [Base] 	 	 
		,'file://\\'+LEFT([SQLname],CHARINDEX('\',[SQLname]+'\')-1) AS [Go]
		,CASE [Process] WHEN 'Start' THEN 1 WHEN 'Restore' THEN 2 WHEN 'Deploy' THEN 3 WHEN 'End' THEN 4 END AS [RecordOrder]
		,T2.[seq_id]
		,T1.[reqdet_id]
FROM		[SEAEXSQLMAIL].[DEPLcontrol].[dbo].[Request_detail] T1 WITH(NOLOCK)
LEFT JOIN	[SEAEXSQLMAIL].[DEPLcontrol].[dbo].[db_sequence] T2 WITH(NOLOCK)
	ON	T1.[DBName] = T2.[dbname]
GO







DROP FUNCTION DBA_DashBoard_GearsTicketDetails 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION DBA_DashBoard_GearsTicketDetails 
(
	@Gears_ID int
	,@UseRemote bit = 0 
)
RETURNS 
@Results TABLE 
(
	[APPL]		sysname
	,[DB]		sysname
	,[Process]	sysname
	,[Type]		sysname
	,[Detail]	sysname
	,[Status]	sysname
	,[SQL]		sysname
	,[Domain]	sysname
	,[Base]		sysname
	,[Go]		VarChar(128)
	,[RecordOrder]	Int
	,[seq_id]	Int
	,[reqdet_id]	Int
)
AS
BEGIN
	INSERT INTO	@Results
	SELECT		[APPL]
			,[DB]
			,[Process]
			,[Type]
			,[Detail]
			,[Status]
			,[SQL]
			,[Domain]
			,[Base]
			,[Go]
			,[RecordOrder]
			,[seq_id]
			,[reqdet_id]
	FROM		[DEPLcontrol].[dbo].[DBA_DashBoard_GearsTicketDetails_Local_Amer]
	WHERE		[Gears_id]=@Gears_ID
	
	IF @UseRemote = 0
	BEGIN
		INSERT INTO	@Results
		SELECT		[APPL]
				,[DB]
				,[Process]
				,[Type]
				,[Detail]
				,[Status]
				,[SQL]
				,[Domain]
				,[Base]
				,[Go]
				,[RecordOrder]
				,[seq_id]
				,[reqdet_id]
		FROM		[DEPLcontrol].[dbo].[DBA_DashBoard_GearsTicketDetails_Local_Stage]
		WHERE		[Gears_id]=@Gears_ID	
		
		INSERT INTO	@Results
		SELECT		[APPL]
				,[DB]
				,[Process]
				,[Type]
				,[Detail]
				,[Status]
				,[SQL]
				,[Domain]
				,[Base]
				,[Go]
				,[RecordOrder]
				,[seq_id]
				,[reqdet_id]
		FROM		[DEPLcontrol].[dbo].[DBA_DashBoard_GearsTicketDetails_Local_Prod]
		WHERE		[Gears_id]=@Gears_ID	
	END
	ELSE
	BEGIN
		INSERT INTO	@Results
		SELECT		[APPL]
				,[DB]
				,[Process]
				,[Type]
				,[Detail]
				,[Status]
				,[SQL]
				,[Domain]
				,[Base]
				,[Go]
				,[RecordOrder]
				,[seq_id]
				,[reqdet_id]
		FROM		[DEPLcontrol].[dbo].[DBA_DashBoard_GearsTicketDetails_Remote_Stage]
		WHERE		[Gears_id]=@Gears_ID	
		
		INSERT INTO	@Results
		SELECT		[APPL]
				,[DB]
				,[Process]
				,[Type]
				,[Detail]
				,[Status]
				,[SQL]
				,[Domain]
				,[Base]
				,[Go]
				,[RecordOrder]
				,[seq_id]
				,[reqdet_id]
		FROM		[DEPLcontrol].[dbo].[DBA_DashBoard_GearsTicketDetails_Remote_Prod]
		WHERE		[Gears_id]=@Gears_ID	
	END
	RETURN 
END
GO



--Get Data Locally
SELECT		[APPL]
		,[DB]
		,[Process]
		,[Type]
		,[Detail]
		,[Status]
		,[SQL]
		,[Domain]
		,[Base]
		,[Go]
		,[reqdet_id]
FROM		DBA_DashBoard_GearsTicketDetails (43482,0)
ORDER BY	[SQL],RecordOrder,seq_id

--Get Data Remotely
SELECT		[APPL]
		,[DB]
		,[Process]
		,[Type]
		,[Detail]
		,[Status]
		,[SQL]
		,[Domain]
		,[Base]
		,[Go]
		,[reqdet_id]
FROM		DBA_DashBoard_GearsTicketDetails (43482,1)
ORDER BY	[SQL],RecordOrder,seq_id
