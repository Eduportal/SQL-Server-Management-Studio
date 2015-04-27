------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- RUN On MASTER server
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
USE MasterAuditDatabase

SELECT 	*
FROM	MasterAuditTable

SELECT 	*
FROM	TargetAuditQueue

SELECT 	COUNT(*)
FROM	AuditErrors


SELECT CAST(message_body AS XML), * FROM TargetAuditQueue

SELECT * FROM sys.transmission_queue 
SELECT * FROM sys.conversation_endpoints

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- RUN on CHILD servers
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
USE TestDb1
-- test if it works
INSERT INTO dbo.Person
SELECT 1, 'name 1', 'surname 1', GETDATE() - 1000 UNION ALL
SELECT 2, 'name 2', 'surname 2', GETDATE() - 100 UNION ALL
SELECT 3, 'name 3', 'surname 3', GETDATE() - 10 UNION ALL
SELECT 4, 'name 4', 'surname 4', GETDATE() - 1

SELECT * FROM Person

UPDATE dbo.Person
SET FirstName = 'test update 1'
WHERE ID = 2

SELECT * FROM Person
SELECT * FROM InitiatorAuditQueue
-- see if error happened
SELECT * FROM AuditErrors
-- check our conversation dialog id
SELECT * FROM AuditDialogs
SELECT CAST(message_body AS XML), * FROM sys.transmission_queue 
SELECT * FROM sys.conversation_endpoints
