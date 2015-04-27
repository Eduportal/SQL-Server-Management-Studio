
:Setvar CLIENT_IPADDR	"10.196.3.41"
:Setvar CENTRAL_IPADDR	"10.196.6.142"
:Setvar	CENTRAL_GUID	"70AFD547-C6CC-43A4-B34A-1475B97D28B9"
:Setvar	PORT			"4022"

USE master

GO
-- enable service broker
ALTER DATABASE DBAAdmin SET ENABLE_BROKER

GO
USE DBAAdmin

-- Drop existing service broker items
IF EXISTS(SELECT * FROM sys.routes WHERE NAME = 'RouteDataSender')
	DROP ROUTE RouteDataSender

IF EXISTS(SELECT * FROM sys.services WHERE NAME = N'tcp://$(CLIENT_IPADDR):$(PORT)/DBAAdmin/Audit/DataSender')
	DROP SERVICE [tcp://$(CLIENT_IPADDR):$(PORT)/DBAAdmin/Audit/DataSender]

IF EXISTS(SELECT * FROM sys.service_queues WHERE NAME = N'InitiatorAuditQueue')
	DROP QUEUE InitiatorAuditQueue

IF EXISTS(SELECT * FROM sys.service_contracts  WHERE NAME = N'//Audit/Contract')
	DROP CONTRACT [//Audit/Contract]

IF EXISTS(SELECT * FROM sys.service_message_types WHERE NAME = N'//Audit/Message')
	DROP MESSAGE TYPE [//Audit/Message]

GO
-- create a route on which the messages will be sent to receiver
CREATE ROUTE RouteDataSender
	AUTHORIZATION dbo
WITH
	-- target server's service to which the data will be sent
	SERVICE_NAME = '//Audit/DataWriter',
	-- target server's DBACentral Service Broker id 
	-- (change it to yours and remove < and >)
	BROKER_INSTANCE = '$(CENTRAL_GUID)',	
	-- IP and PORT of the target server
	ADDRESS = 'TCP://$(CENTRAL_IPADDR):$(PORT)'
GO

GO
-- create a message that must be well formed
CREATE MESSAGE TYPE [//Audit/Message] 
	VALIDATION = WELL_FORMED_XML

-- create a contract for the message
CREATE CONTRACT [//Audit/Contract]
	([//Audit/Message] SENT BY INITIATOR)

-- create the initiator queue 
CREATE QUEUE dbo.InitiatorAuditQueue

-- create an initiator service that will send audit messages to target service
CREATE SERVICE [tcp://$(CLIENT_IPADDR):$(PORT)/DBAAdmin/Audit/DataSender] 
	AUTHORIZATION dbo
	ON QUEUE dbo.InitiatorAuditQueue -- no contract means service can only be the initiator

-- create service with IP and PORT of the initiator (this) server
GRANT SEND ON SERVICE::[tcp://$(CLIENT_IPADDR):$(PORT)/DBAAdmin/Audit/DataSender] TO PUBLIC
GO

-- drop support objects
IF OBJECT_ID('dbo.AuditErrors') IS NOT NULL
	DROP TABLE dbo.AuditErrors

IF OBJECT_ID('dbo.AuditDialogs') IS NOT NULL
	DROP TABLE dbo.AuditDialogs

IF OBJECT_ID('dbo.usp_SendAuditData') IS NOT NULL
	DROP PROCEDURE dbo.usp_SendAuditData

GO
-- create Errors table
CREATE TABLE dbo.AuditErrors
(
	Id BIGINT IDENTITY(1, 1) PRIMARY KEY,
	ErrorProcedure NVARCHAR(126) NOT NULL,
	ErrorLine INT NOT NULL,
	ErrorNumber INT NOT NULL,
	ErrorMessage NVARCHAR(MAX) NOT NULL,
	ErrorSeverity INT NOT NULL,
	ErrorState INT NOT NULL,
	AuditedData XML NOT NULL,
	ErrorDate DATETIME NOT NULL DEFAULT GETUTCDATE()
)

GO
-- Table that will hold dialog id for database
-- These dialogs will be reused. 
CREATE TABLE dbo.AuditDialogs
(
	DbId INT NOT NULL, 
	DialogId UNIQUEIDENTIFIER NOT NULL
)

GO
-- stored procedure that sends the audit data to the be audited
CREATE PROCEDURE dbo.usp_SendAuditData
(
	@AuditedData XML
)
AS
BEGIN
	------------------------------------------------------
	-- CHECK INITIATOR QUEUE FOR ERRORS IF NEEDED
	------------------------------------------------------
	BEGIN TRY
		DECLARE @dlgId UNIQUEIDENTIFIER
				
		-- Check if our database already has a dialog id that was previously used
		-- if it does reuse the conversation
		SELECT	@dlgId = DialogId
		FROM	dbo.AuditDialogs
		WHERE	DbId = DB_ID()
		-- if we're reusing a dialog conversation then 
		-- check if it is in a good state for conversation ...
		IF @dlgId IS NOT NULL 
		   AND NOT EXISTS(	SELECT	* 
							FROM	sys.conversation_endpoints 
							WHERE	conversation_handle = @dlgId AND state IN ('SO', 'CO'))
		BEGIN 
			-- ... if it isn't then delete it from our saved dialogs table ...
			DELETE
			FROM	dbo.AuditDialogs
			WHERE	DbId = DB_ID() AND DialogId = @dlgId

			-- ... optionally you can end the conversation here, 
			--     but it is better to end it from target server
			-- END CONVERSATION @dlgId WITH CLEANUP

			-- ... and set it to null to create a new dialog
			SELECT	@dlgId = NULL
		END
		IF @dlgId IS NULL
		BEGIN 
			-- Begin the dialog, with the new Id
			BEGIN DIALOG CONVERSATION @dlgId
				FROM SERVICE    [tcp://$(CLIENT_IPADDR):$(PORT)/DBAAdmin/Audit/DataSender]
				TO SERVICE      '//Audit/DataWriter', 
								-- this is a DBACentral Service Broker Id
								-- (change it to yours and remove < and >)
								'$(CENTRAL_GUID)'
				ON CONTRACT     [//Audit/Contract]
				WITH ENCRYPTION = OFF;

			-- add our db's dialog to AuditDialogs table if it doesn't exist yet
			INSERT INTO dbo.AuditDialogs(DbId, DialogId)
			SELECT	DB_ID(), @dlgId
		END 
		-- Send our data to be audited
		;SEND ON CONVERSATION @dlgId	
		MESSAGE TYPE [//Audit/Message] (@AuditedData)
	END TRY
	BEGIN CATCH		
		INSERT INTO AuditErrors (
				ErrorProcedure, ErrorLine, ErrorNumber, ErrorMessage, 
				ErrorSeverity, ErrorState, AuditedData)
		SELECT	ERROR_PROCEDURE(), ERROR_LINE(), ERROR_NUMBER(), ERROR_MESSAGE(), 
				ERROR_SEVERITY(), ERROR_STATE(), @AuditedData
		DECLARE @errorId BIGINT, @dbName nvarchar(128)
		SELECT  @errorId = scope_identity(), @dbName = DB_NAME()

		RAISERROR (N'Error while sending Service Broker message. Error info can be found in ''%s.dbo.AuditErrors'' table with id: %I64d', 16, 1, @dbName, @errorId) WITH LOG;
	END CATCH
END

------------------------------------------------------------------------
-- S A M P L E    T A B L E    W I T H    A U D I T I N G
------------------------------------------------------------------------
GO
-- Create Sample Table
IF OBJECT_ID('Person') IS NOT NULL
	DROP TABLE Person

GO
CREATE TABLE Person
(
	ID INT PRIMARY KEY,
	FirstName varchar(50),
	LastName varchar(50),
	DateOfBirth SMALLDATETIME
)

-- Create Trigger that will audit data
GO
IF OBJECT_ID ('trgPersonAudit','TR') IS NOT NULL
    DROP TRIGGER trgPersonAudit

GO
CREATE TRIGGER dbo.trgPersonAudit
ON Person
AFTER INSERT, UPDATE, DELETE 
AS
	DECLARE @auditBody XML
	DECLARE @DMLType CHAR(1)	
	-- after delete statement
	IF NOT EXISTS (SELECT * FROM inserted)
	BEGIN	
		SELECT	@auditBody = (select * FROM deleted AS t FOR XML AUTO, ELEMENTS),
				@DMLType = 'D'
	END 
	-- after update or insert statement
	ELSE
	BEGIN
		SELECT	@auditBody = (select * FROM inserted AS t FOR XML AUTO, ELEMENTS)
		-- after update statement
		IF EXISTS (SELECT * FROM deleted)
			SELECT 	@DMLType = 'U'
		-- after insert statement
		ELSE
			SELECT	@DMLType = 'I'
	END

	-- get table name dynamicaly but
	-- for performance this should be changed to constant in every trigger like:
	-- SELECT	@tableName = 'Person'
	DECLARE @tableName sysname 
	SELECT	@tableName = tbl.name 
    FROM	sys.tables tbl 
			JOIN sys.triggers trg ON tbl.[object_id] = trg.parent_id 
    WHERE	trg.[object_id] = @@PROCID 

	SELECT @auditBody = 
		'<AuditMsg> 
			<SourceServer>' + @@servername + '</SourceServer>
			<SourceDb>' + DB_NAME() + '</SourceDb>
			<SourceTable>' + @tableName + '</SourceTable>
			<UserId>' + SUSER_SNAME() + '</UserId>
			<DMLType>' + @DMLType + '</DMLType>
			<ChangedData>' + CAST(@auditBody AS NVARCHAR(MAX)) + '</ChangedData>
		</AuditMsg>'
	-- Audit data asynchrounously
	EXEC dbo.usp_SendAuditData @auditBody

GO
-- we want this trigger to fire last for each command so that if there are other triggers
-- that update the table they finish their job before auditing
EXEC sp_settriggerorder 'dbo.trgPersonAudit', 'Last', 'delete'
EXEC sp_settriggerorder 'dbo.trgPersonAudit', 'Last', 'insert'
EXEC sp_settriggerorder 'dbo.trgPersonAudit', 'Last', 'update'
