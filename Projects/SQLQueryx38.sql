USE [users]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[frmData_NOCTicket_Creator_Name]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[frmData_NOCTicket_Creator_Name]
GO

USE [users]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[frmData_NOCTicket_Severity]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[frmData_NOCTicket_Severity]
GO





USE [users]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Create the view, it must comply with the rules (deterministic)
CREATE VIEW	[dbo].[frmData_NOCTicket_Severity]		WITH SCHEMABINDING 
AS 
SELECT		frmData.TID
		,CAST(REPLACE(frmData.Value,'sev','') AS INT) AS Severity
		,count_big(*) as cnt
FROM		dbo.frmData frmData
WHERE		frmData.CID IN (14248,14249)
	AND	isnumeric(REPLACE(frmData.Value,'sev','')) = 1
GROUP BY	frmData.TID
		,CAST(REPLACE(frmData.Value,'sev','') AS INT)

GO



USE [users]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW	[dbo].[frmData_NOCTicket_Creator_Name]		WITH SCHEMABINDING 
AS 
SELECT		frmData.TID
		,CAST(frmData.Value AS VarChar(25)) AS Creator_Name
		,count_big(*) as cnt
FROM		dbo.frmData frmData
WHERE		frmData.CID IN (5099)
GROUP BY	frmData.TID
		,CAST(frmData.Value AS VarChar(25))

GO


