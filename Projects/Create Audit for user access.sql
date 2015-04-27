USE [master]
GO

IF  EXISTS (SELECT * FROM sys.server_audits WHERE name = N'oneuser_Audit')
BEGIN
	ALTER SERVER AUDIT [oneuser_Audit]
	WITH (STATE = OFF);

	DROP SERVER AUDIT [oneuser_Audit]
END
GO

CREATE SERVER AUDIT [oneuser_Audit]
TO FILE 
(	FILEPATH = N'd:\'
	,MAXSIZE = 500 MB
	,MAX_ROLLOVER_FILES = 2147483647
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
	,AUDIT_GUID = 'dd141c06-d63d-43fd-9023-20e05b8fc7a2'
)
GO

USE [wcds]
GO

IF  EXISTS (SELECT * FROM sys.database_audit_specifications WHERE name = N'oneuser_CreditCard')
BEGIN
	ALTER DATABASE AUDIT SPECIFICATION [oneuser_CreditCard]
	WITH (STATE = OFF);
	
	DROP DATABASE AUDIT SPECIFICATION [oneuser_CreditCard]
END
GO

IF  EXISTS (SELECT * FROM sys.database_audit_specifications WHERE name = N'oneuser_All')
BEGIN
	ALTER DATABASE AUDIT SPECIFICATION [oneuser_All]
	WITH (STATE = OFF);
	
	DROP DATABASE AUDIT SPECIFICATION [oneuser_All]
END
GO


CREATE DATABASE AUDIT SPECIFICATION [oneuser_CreditCard]
FOR SERVER AUDIT [oneuser_Audit]
ADD (DELETE ON OBJECT::[dbo].[CreditCard] BY [oneuser]),
ADD (INSERT ON OBJECT::[dbo].[CreditCard] BY [oneuser]),
ADD (REFERENCES ON OBJECT::[dbo].[CreditCard] BY [oneuser]),
ADD (SELECT ON OBJECT::[dbo].[CreditCard] BY [oneuser]),
ADD (UPDATE ON OBJECT::[dbo].[CreditCard] BY [oneuser])
WITH (STATE = ON)
GO

--CREATE DATABASE AUDIT SPECIFICATION [oneuser_All]
--FOR SERVER AUDIT [oneuser_Audit]
--ADD (DELETE ON DATABASE::[wcds] BY [oneuser]),
--ADD (INSERT ON DATABASE::[wcds] BY [oneuser]),
--ADD (REFERENCES ON DATABASE::[wcds] BY [oneuser]),
--ADD (SELECT ON DATABASE::[wcds] BY [oneuser]),
--ADD (UPDATE ON DATABASE::[wcds] BY [oneuser])
--WITH (STATE = ON)
--GO


USE [Master]
GO

ALTER SERVER AUDIT [oneuser_Audit]
WITH (STATE = ON);
GO