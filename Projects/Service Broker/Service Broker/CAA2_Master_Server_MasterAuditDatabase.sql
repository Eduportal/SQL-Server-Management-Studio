:Setvar CLIENT_IPADDR	"10.196.3.41"
:Setvar CENTRAL_IPADDR	"10.196.6.142"
:Setvar	CENTRAL_GUID	"70AFD547-C6CC-43A4-B34A-1475B97D28B9"
:Setvar	PORT			"4022"


USE master

-- enable service broker
ALTER DATABASE DBACentral SET ENABLE_BROKER

GO
USE DBACentral	
GO
-- get service broker guid for DBACentral.
-- we must copy/paste this guid to the BEGIN DIALOG
-- in dbo.usp_SendAuditData stored procedure

SELECT service_broker_guid
FROM   sys.databases
WHERE  database_id = DB_ID()

GO
IF OBJECT_ID('dbo.MasterAuditTable') IS NOT NULL
	DROP TABLE dbo.MasterAuditTable

GO
-- Master Audit Table
CREATE TABLE dbo.MasterAuditTable
(
	Id BIGINT IDENTITY(1,1),
	SourceServer sysname NOT NULL, 
	SourceDB sysname NOT NULL, 
	SourceTable sysname NOT NULL, 
	UserID NVARCHAR(500) NOT NULL,	
	-- D = Delete, I = Insert, U = Update
	DMLType char(1) NOT NULL CHECK (DMLType IN ('D', 'U', 'I')), 
	ChangedData XML NOT NULL,
	ChangeDate DATETIME NOT NULL DEFAULT GETUTCDATE()
)

GO
IF OBJECT_ID('dbo.AuditErrors') IS NOT NULL
	DROP TABLE dbo.AuditErrors

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
IF OBJECT_ID('dbo.usp_WriteAuditData') IS NOT NULL
	DROP PROCEDURE dbo.usp_WriteAuditData

GO
-- stored procedure that writes the audit data from the queue to the audit table
CREATE PROCEDURE dbo.usp_WriteAuditData
AS
BEGIN
	DECLARE @msgBody XML	
	DECLARE @dlgId uniqueidentifier

	WHILE(1=1)
	BEGIN
		BEGIN TRANSACTION	
		BEGIN TRY		
			-- insert messages into audit table one message at a time
			;RECEIVE top(1) 
					@msgBody	= message_body,      
					@dlgId		= conversation_handle    
			FROM	dbo.TargetAuditQueue

			-- exit when the whole queue has been processed
			IF @@ROWCOUNT = 0
			BEGIN
				IF @@TRANCOUNT > 0
				BEGIN 
					ROLLBACK;
				END  
				BREAK;
			END 

			SELECT @msgBody, @dlgId

			DECLARE @SourceServer sysname, @SourceDB sysname, @SourceTable sysname, 
					@UserID NVARCHAR(500), @DMLType CHAR(1), @ChangedData XML
			
			-- xml datatype and its capabilities rock
			SELECT	@SourceServer = T.c.query('/AuditMsg/SourceServer').value('.[1]', 'sysname'),
					@SourceDB = T.c.query('/AuditMsg/SourceDb').value('.[1]', 'sysname'),
					@SourceTable = T.c.query('/AuditMsg/SourceTable').value('.[1]', 'sysname'),
					@UserID = T.c.query('/AuditMsg/UserId').value('.[1]', 'NVARCHAR(50)'),
					@DMLType = T.c.query('/AuditMsg/DMLType').value('.[1]', 'CHAR(1)'),
					@ChangedData = T.c.query('*')
			FROM	@msgBody.nodes('/AuditMsg/ChangedData') T(c)

			INSERT INTO dbo.MasterAuditTable(SourceServer, SourceDB, SourceTable, UserID, DMLType, ChangedData)
			SELECT @SourceServer, @SourceDB, @SourceTable, @UserID, @DMLType, @ChangedData
			
			-- No need to close the conversation because auditing never ends			
			-- you can end conversations if you want periodicaly with a scheduled job
			-- END CONVERSATION @dlgId WITH CLEANUP

			IF @@TRANCOUNT > 0
			BEGIN 
				COMMIT;
			END
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			BEGIN 
				ROLLBACK;
			END
			-- insert error into the AuditErrors table
			INSERT INTO AuditErrors (	
					ErrorProcedure, ErrorLine, ErrorNumber, ErrorMessage, 
					ErrorSeverity, ErrorState, AuditedData)
			SELECT	ERROR_PROCEDURE(), ERROR_LINE(), ERROR_NUMBER(), ERROR_MESSAGE(), 
					ERROR_SEVERITY(), ERROR_STATE(), @msgBody			
			DECLARE @errorId BIGINT, @dbName nvarchar(128)
			SELECT  @errorId = scope_identity(), @dbName = DB_NAME()

			RAISERROR (N'Error while receiving Service Broker message. Error info can be found in ''%s.dbo.AuditErrors'' table with id: %I64d', 16, 1, @dbName, @errorId) WITH LOG;
		END CATCH;
	END	
END

GO
IF EXISTS(SELECT * FROM sys.services WHERE NAME = N'//Audit/DataWriter')
	DROP SERVICE [//Audit/DataWriter]

IF EXISTS(SELECT * FROM sys.service_queues WHERE NAME = N'TargetAuditQueue')
	DROP QUEUE dbo.TargetAuditQueue

IF EXISTS(SELECT * FROM sys.service_contracts  WHERE NAME = N'//Audit/Contract')
	DROP CONTRACT [//Audit/Contract]

IF EXISTS(SELECT * FROM sys.service_message_types WHERE NAME = N'//Audit/Message')
	DROP MESSAGE TYPE [//Audit/Message]

IF EXISTS(SELECT * FROM sys.routes WHERE NAME = 'RouteDataReceiver')
	DROP ROUTE RouteDataReceiver

GO
-- create a message that must be well formed XML
CREATE MESSAGE TYPE [//Audit/Message] 
	VALIDATION = WELL_FORMED_XML

-- create a contract for the message
CREATE CONTRACT [//Audit/Contract]
	([//Audit/Message] SENT BY INITIATOR)

-- create the queue to run the usp_WriteAuditData automaticaly when new messages arrive
-- execute it as dbo
CREATE QUEUE dbo.TargetAuditQueue 
	WITH STATUS = ON, 
	ACTIVATION (	
		PROCEDURE_NAME = usp_WriteAuditData,	-- sproc to run when the queue receives a message
		MAX_QUEUE_READERS = 50,					-- max concurrently executing instances of sproc
		EXECUTE AS 'dbo' );

-- create a target service that will accept inbound audit messages
CREATE SERVICE [//Audit/DataWriter] 
	AUTHORIZATION dbo -- set the owner to dbo
	ON QUEUE dbo.TargetAuditQueue ([//Audit/Contract])

-- create service with transport and name of the machine in the address address 
GRANT SEND ON SERVICE::[//Audit/DataWriter] TO PUBLIC
GO

-- Create Transport Route
CREATE ROUTE [RouteDataReceiver]
	WITH ADDRESS = N'TRANSPORT'
