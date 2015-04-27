USE master
GO

if OBJECT_ID('startblackbox') IS NOT NULL
DROP PROC startblackbox
GO
CREATE PROC startblackbox
AS
DECLARE	@TraceId	int
DECLARE	@maxfilesize	bigint 
SET	@maxfilesize	= 25 
if not exists(select * From sys.traces where [path] like '%blackbox%' AND status like 1)
BEGIN
	EXEC sp_trace_create
		@TraceId OUTPUT, 
		@options = 8, 
		@tracefile = NULL,
		@maxfilesize = @maxfilesize

	EXEC sp_trace_setstatus
		@TraceId
		, 1
END
GO

--Optional part of syntax to make the black box start on the startup of SQL Server
exec sp_procoption startblackbox, 'startup', 'on'
go

-- START TRACE
EXEC startblackbox
GO




USE [dbaperf]
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BlackBoxTrace_Snapshots_Index]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BlackBoxTrace_Snapshots_Index](
	[Index_ID] [INT] IDENTITY(1,1) PRIMARY KEY,
	[TriggerID] [uniqueidentifier] NOT NULL,
	[EventDate] [datetime] NOT NULL,
	[DatabaseName] [sysname] NULL,
	[ErrorNumber] [int] NULL,
	[ErrorSeverity] [int] NULL,
	[ErrorMessage] [varchar](8000) NULL
) ON [PRIMARY]
END
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BlackBoxTrace_Snapshots]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BlackBoxTrace_Snapshots](
	[Row_Number] [bigint] IDENTITY(1,1) NOT NULL,
	[Trigger_ID] [uniqueidentifier] NULL,
	[TextData] [ntext] NULL,
	[BinaryData] [image] NULL,
	[DatabaseID] [int] NULL,
	[TransactionID] [bigint] NULL,
	[LineNumber] [int] NULL,
	[NTUserName] [nvarchar](256) NULL,
	[NTDomainName] [nvarchar](256) NULL,
	[HostName] [nvarchar](256) NULL,
	[ClientProcessID] [int] NULL,
	[ApplicationName] [nvarchar](256) NULL,
	[LoginName] [nvarchar](256) NULL,
	[SPID] [int] NULL,
	[Duration] [bigint] NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Reads] [bigint] NULL,
	[Writes] [bigint] NULL,
	[CPU] [int] NULL,
	[Permissions] [bigint] NULL,
	[Severity] [int] NULL,
	[EventSubClass] [int] NULL,
	[ObjectID] [int] NULL,
	[Success] [int] NULL,
	[IndexID] [int] NULL,
	[IntegerData] [int] NULL,
	[ServerName] [nvarchar](256) NULL,
	[EventClass] [int] NULL,
	[ObjectType] [int] NULL,
	[NestLevel] [int] NULL,
	[State] [int] NULL,
	[Error] [int] NULL,
	[Mode] [int] NULL,
	[Handle] [int] NULL,
	[ObjectName] [nvarchar](256) NULL,
	[DatabaseName] [nvarchar](256) NULL,
	[FileName] [nvarchar](256) NULL,
	[OwnerName] [nvarchar](256) NULL,
	[RoleName] [nvarchar](256) NULL,
	[TargetUserName] [nvarchar](256) NULL,
	[DBUserName] [nvarchar](256) NULL,
	[LoginSid] [image] NULL,
	[TargetLoginName] [nvarchar](256) NULL,
	[TargetLoginSid] [image] NULL,
	[ColumnPermissions] [int] NULL,
	[LinkedServerName] [nvarchar](256) NULL,
	[ProviderName] [nvarchar](256) NULL,
	[MethodName] [nvarchar](256) NULL,
	[RowCounts] [bigint] NULL,
	[RequestID] [int] NULL,
	[XactSequence] [bigint] NULL,
	[EventSequence] [bigint] NULL,
	[BigintData1] [bigint] NULL,
	[BigintData2] [bigint] NULL,
	[GUID] [uniqueidentifier] NULL,
	[IntegerData2] [int] NULL,
	[ObjectID2] [bigint] NULL,
	[Type] [int] NULL,
	[OwnerID] [int] NULL,
	[ParentName] [nvarchar](256) NULL,
	[IsSystem] [int] NULL,
	[Offset] [int] NULL,
	[SourceDatabaseID] [int] NULL,
	[SqlHandle] [image] NULL,
	[SessionLoginName] [nvarchar](256) NULL,
	[PlanHandle] [image] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO


USE [msdb]
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
	EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END


-- DROP JOB IF IT EXISTS
if EXISTS (select job_id from msdb.dbo.sysjobs where name = N'UTIL - PERF BLACK BOX INSERT ON ERROR')
BEGIN
	exec msdb.dbo.sp_delete_job @job_name=N'UTIL - PERF BLACK BOX INSERT ON ERROR'
END

DECLARE @jobId UNIQUEIDENTIFIER
select @jobId = job_id from msdb.dbo.sysjobs where (name = N'UTIL - PERF BLACK BOX INSERT ON ERROR')
if (@jobId is NULL)
BEGIN
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'UTIL - PERF BLACK BOX INSERT ON ERROR', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'AMER\sledridge', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END
IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobsteps WHERE job_id = @jobId and step_id = 1)
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'INSERT LOG INTO TABLE', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'set nocount on 

PRINT N''ERROR RESPONCE   $(ESCAPE_SQUOTE(DATE))    $(ESCAPE_SQUOTE(TIME)) ''
PRINT N''From $(ESCAPE_SQUOTE(A-SVR)).$(ESCAPE_SQUOTE(A-DBN)) ''
PRINT N''''
PRINT N''Error:    $(ESCAPE_SQUOTE(A-ERR)) ''
PRINT N''Severity: $(ESCAPE_SQUOTE(A-SEV)) ''
PRINT N''Message:  $(ESCAPE_SQUOTE(A-MSG)) ''
PRINT N''Error: $(ESCAPE_SQUOTE(A-ERR)) ''
PRINT N''Error: $(ESCAPE_SQUOTE(A-ERR)) ''
PRINT N''Error: $(ESCAPE_SQUOTE(A-ERR)) ''

DECLARE		@Error		INT
			,@Severity	INT
			,@DBName	sysname
			,@MSG		VarChar(8000)


SELECT			@Error		= $(ESCAPE_NONE(A-ERR))
			,@Severity	= $(ESCAPE_NONE(A-SEV))
			,@DBName	= ''$(ESCAPE_SQUOTE(A-DBN))''
			,@MSG		= ''$(ESCAPE_SQUOTE(A-MSG))''

DECLARE		@TraceId	INT
DECLARE		@Path		VarChar(8000)
DECLARE		@TSQL		varchar(8000)
DECLARE		@TriggerID	UniqueIdentifier

select		@TraceId = id
		,@Path = [path]
		,@TriggerID = newid() 
From		sys.traces
WHERE		[path] like ''%blackbox%''

EXEC sp_trace_setstatus @TraceId, 0 -- stop the trace but dont delete it.

INSERT INTO	DBAPERF.dbo.BlackBoxTrace_Snapshots_Index
SELECT		@TriggerID,getdate(),@DBName,@Error,@Severity,@MSG 

INSERT INTO 	DBAPERF.dbo.BlackBoxTrace_Snapshots
SELECT 		@TriggerID AS Trigger_ID, * 
FROM 		::fn_trace_gettable (@Path,default)

EXEC sp_trace_setstatus @TraceId, 1 -- restart the trace.', 
		@database_name=N'master', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


USE [msdb]
GO

DECLARE @job_id UNIQUEIDENTIFIER
select @job_id = job_id from msdb.dbo.sysjobs where (name = N'UTIL - PERF BLACK BOX INSERT ON ERROR')

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'701 Insufficient Memory')
EXEC msdb.dbo.sp_add_alert @name=N'701 Insufficient Memory', 
		@message_id=701, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@job_id=@job_id


IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'DATAMONGER TEST')
EXEC msdb.dbo.sp_add_alert @name=N'DATAMONGER TEST', 
		@message_id=0, 
		@severity=1, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@event_description_keyword=N'DATAMONGER', 
		@category_name=N'[Uncategorized]', 
		@job_id=@job_id
GO


-- SOME MAINTENANCE SCRIPTS....
/*
-- FIRE OFF TEST ALERT
RAISERROR ('DATAMONGER',1,1) WITH LOG,NOWAIT

-- VIEW DATA
SELECT * FROM DBAPERF.dbo.BlackBoxTrace_Snapshots_Index
SELECT * FROM DBAPERF.dbo.BlackBoxTrace_Snapshots

-- EMPTY TABLES WHEN DONE WITH DATA
TRUNCATE TABLE BlackBoxTrace_Snapshots_Index
TRUNCATE TABLE BlackBoxTrace_Snapshots
*/





