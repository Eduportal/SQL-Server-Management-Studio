USE [master]
GO

-- USE [dbaperf];TRUNCATE TABLE [dbo].[BlockedProcessesEventLog];use [dbaadmin]
 
SELECT	[EventRowID]
	,[ProcID]
	,[EventType]
	,[AlertTime]
	,[Database]
	,[BlockedProcessReport]
	,[BlockingEventData]
	,[AuditDate]
	,[AlertData]
FROM [dbaperf].[dbo].[BlockedProcessesEventLog]
GO

--SELECT * FROM SYS.sysprocesses


-- UPDATE [dbaperf].[dbo].[BlockedProcessesEventLog] SET [AlertData] = NULL

SELECT	TOP 100
	[EventRowID]
	,UPPER([BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@id)[1]', 'varchar(64)')) AS [ProcessID]
	,[AlertData]
	,[BlockingEventData].value('(/EVENT_INSTANCE/PostTime)[1]', 'datetime') AS [BlockingEventTime]
	,[BlockingEventData].value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(50)') AS [BlockingEventType]
	,CAST([BlockingEventData].value('(/EVENT_INSTANCE/Duration)[1]', 'bigint') / 1000000.0 AS [decimal](6, 2)) AS [BlockingDurationInSeconds]
	,[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@waitresource)[1]', 'varchar(max)') AS [BlockedWaitResource]
	,DB_NAME([BlockingEventData].value('(/EVENT_INSTANCE/DatabaseID)[1]', 'int')) AS [BlockedWaitResourceDatabase]
	,[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@spid)[1]', 'int') AS [BlockedProcessSPID]
	,[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@loginname)[1]', 'varchar(64)') AS [BlockedProcessOwnerLoginName]
	,UPPER([BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@status)[1]', 'varchar(32)')) AS [BlockedProcessStatus]
	,[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@lockMode)[1]', 'varchar(64)') AS [BlockedProcessLockMode]
	,UPPER([BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@transactionname)[1]', 'varchar(64)')) AS [BlockedProcessCommandType]
	,[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process)[1]', 'varchar(max)') AS [BlockedProcessTSQL]
	,[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@lastbatchstarted)[1]', 'datetime') AS [BlockedProcessLastBatchStartTime]
	,[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@lastbatchcompleted)[1]', 'datetime') AS [BlockedProcessLastBatchCompleteTime]
	,UPPER([BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@isolationlevel)[1]', 'varchar(64)')) AS [BlockedProcessTransactionIsolationLevel]
	,[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@clientapp)[1]', 'varchar(128)') AS [BlockedProcessClientApplication]
	,[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@hostname)[1]', 'varchar(64)') AS [BlockedProcessHostName]
	,[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process/process/@spid)[1]', 'int') AS [BlockingProcessSPID]
	,[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process/process/@loginname)[1]', 'varchar(64)') AS [BlockingProcessOwnerLoginName]
	,UPPER([BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process/process/@status)[1]', 'varchar(32)')) AS [BlockingProcessStatus]
	,[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process)[1]', 'varchar(64)') AS [BlockingProcessTSQL]
	,[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process/process/@lastbatchstarted)[1]', 'datetime') AS [BlockingProcessLastBatchStartTime]
	,[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process/process/@lastbatchcompleted)[1]', 'datetime') AS [BlockingProcessLastBatchCompleteTime]
	,UPPER([BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process/process/@isolationlevel)[1]', 'varchar(64)')) AS [BlockingProcessTransactionIsolationLevel]
	,[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process/process/@clientapp)[1]', 'varchar(128)') AS [BlockingProcessClientApplication]
	,[BlockingEventData].value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocking-process/process/@hostname)[1]', 'varchar(64)') AS [BlockingProcessHostName]
	,[BlockedProcessReport]
	,[BlockingEventData]
FROM [dbaperf].[dbo].[BlockedProcessesEventLog]
ORDER BY 1 desc

GO

exec sp_whoisactive
/*

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--	RUN THIS IN TWO SEPERATE QUERY WINDOWS TO START BLOCKING
--			RUN AGIAN TO UNBLOCK
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

USE [DBAAdmin]
GO
SET NOCOUNT ON
GO 
IF @@TRANCOUNT > 0
BEGIN
	ROLLBACK TRAN
	RAISERROR('Blocking has Ended...',-1,-1) WITH NOWAIT
	END
ELSE
BEGIN
	BEGIN TRAN
 
	UPDATE [DBAAdmin].[dbo].[LicenseInfo]
	SET [Active] = 'Y'
	DECLARE @Active CHAR(1)
	SELECT TOP 1 @Active = Active FROM [DBAAdmin].[dbo].[LicenseInfo]
	RAISERROR('Blocking has Started...',-1,-1) WITH NOWAIT
END 

*/