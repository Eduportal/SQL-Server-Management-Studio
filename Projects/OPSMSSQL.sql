
CREATE TABLE dbo.OPSMSSQL_CustomEventLog_Category
	(
	[CategoryID]	[tinyint] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[SymbolicName]	[nvarchar](50) NOT NULL,
	[Message]	[nvarchar](MAX) NOT NULL
	)
GO


CREATE TABLE dbo.OPSMSSQL_CustomEventLog_Severity
	(
	[SeverityID]	[tinyint] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[SymbolicName]	[nvarchar](50) NOT NULL,
	[Message]	[nvarchar](MAX) NOT NULL
	)
GO


CREATE TABLE [dbo].[OPSMSSQL_CustomEventLog_Event]
	(
	[EventID]	[tinyint] IDENTITY(10,1) NOT NULL PRIMARY KEY CLUSTERED,
	[SeverityID]	[tinyint] NOT NULL,
	[CategoryID]	[tinyint] NOT NULL,
	[SymbolicName]	[nvarchar](50) NOT NULL,
	[Message]	AS 'Getty Images Operations SQL Server Custom Event%r'+[SymbolicName]+'%r%r%1%r%rSupport Link https://mixer.gettyimages.com/troubleshooting-guides/index.cgi?DBA_' + CAST([EventID] AS VarChar(4))
	)
GO

/*
ALTER TABLE [dbo].[OPSMSSQL_CustomEventLog_Event] DROP COLUMN [Message]
GO
ALTER TABLE [dbo].[OPSMSSQL_CustomEventLog_Event] ADD [Message]	AS 'Getty Images Operations SQL Server Custom Event%r'+[SymbolicName]+'%r%r%1%r%rSupport Link https://mixer.gettyimages.com/troubleshooting-guides/index.cgi?DBA_' + CAST([EventID] AS VarChar(4))
GO
*/

ALTER TABLE dbo.OPSMSSQL_CustomEventLog_Event ADD CONSTRAINT
	FK_OPSMSSQL_CustomEventLog_Event_OPSMSSQL_CustomEventLog_Severity FOREIGN KEY
	(
	SeverityID
	) REFERENCES dbo.OPSMSSQL_CustomEventLog_Severity
	(
	SeverityID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.OPSMSSQL_CustomEventLog_Event ADD CONSTRAINT
	FK_OPSMSSQL_CustomEventLog_Event_OPSMSSQL_CustomEventLog_Category FOREIGN KEY
	(
	CategoryID
	) REFERENCES dbo.OPSMSSQL_CustomEventLog_Category
	(
	CategoryID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
DELETE OPSMSSQL_CustomEventLog_Severity

SET IDENTITY_INSERT OPSMSSQL_CustomEventLog_Severity ON
INSERT INTO OPSMSSQL_CustomEventLog_Severity ([SeverityID], [SymbolicName], [Message]) VALUES (0, 'SUCCESS', 'Success')
INSERT INTO OPSMSSQL_CustomEventLog_Severity ([SeverityID], [SymbolicName], [Message]) VALUES (1, 'INFORMATION', 'Information')
INSERT INTO OPSMSSQL_CustomEventLog_Severity ([SeverityID], [SymbolicName], [Message]) VALUES (2, 'WARNING', 'Warning')
INSERT INTO OPSMSSQL_CustomEventLog_Severity ([SeverityID], [SymbolicName], [Message]) VALUES (3, 'ERROR', 'Error')

SET IDENTITY_INSERT OPSMSSQL_CustomEventLog_Severity OFF
GO
DELETE OPSMSSQL_CustomEventLog_Category

SET IDENTITY_INSERT OPSMSSQL_CustomEventLog_Category ON

INSERT INTO OPSMSSQL_CustomEventLog_Category ([CategoryID], [SymbolicName], [Message]) VALUES (1, 'AUDIT', 'Audit')
INSERT INTO OPSMSSQL_CustomEventLog_Category ([CategoryID], [SymbolicName], [Message]) VALUES (2, 'VALIDATE', 'Validate')
INSERT INTO OPSMSSQL_CustomEventLog_Category ([CategoryID], [SymbolicName], [Message]) VALUES (3, 'CONDITION_LOW', 'Low Priority Condition')
INSERT INTO OPSMSSQL_CustomEventLog_Category ([CategoryID], [SymbolicName], [Message]) VALUES (4, 'CONDITION_MED', 'Medium Priority Condition ')
INSERT INTO OPSMSSQL_CustomEventLog_Category ([CategoryID], [SymbolicName], [Message]) VALUES (5, 'CONDITION_HI', 'High Priority Condition')
INSERT INTO OPSMSSQL_CustomEventLog_Category ([CategoryID], [SymbolicName], [Message]) VALUES (6, 'DEBUG', 'Debug')
SET IDENTITY_INSERT OPSMSSQL_CustomEventLog_Category OFF

GO
DELETE OPSMSSQL_CustomEventLog_Event

SET IDENTITY_INSERT OPSMSSQL_CustomEventLog_Event ON

INSERT INTO OPSMSSQL_CustomEventLog_Event ([EventID], [SeverityID], [CategoryID], [SymbolicName]) VALUES (10, 0, 2, 'VALIDATION_VALID')
INSERT INTO OPSMSSQL_CustomEventLog_Event ([EventID], [SeverityID], [CategoryID], [SymbolicName]) VALUES (11, 3, 2, 'VALIDATION_INVALID')
INSERT INTO OPSMSSQL_CustomEventLog_Event ([EventID], [SeverityID], [CategoryID], [SymbolicName]) VALUES (12, 2, 2, 'VALIDATION_MISSING')
INSERT INTO OPSMSSQL_CustomEventLog_Event ([EventID], [SeverityID], [CategoryID], [SymbolicName]) VALUES (13, 2, 2, 'VALIDATION_PRE_EXISTING')
INSERT INTO OPSMSSQL_CustomEventLog_Event ([EventID], [SeverityID], [CategoryID], [SymbolicName]) VALUES (14, 1, 2, 'VALIDATION_INFO')

SET IDENTITY_INSERT OPSMSSQL_CustomEventLog_Event OFF

GO
