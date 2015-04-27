USE MASTER
GO
EXECUTE AS LOGIN = 'AMER\SQLAdminprod2010';
GO

--ALTER DATABASE [DBAPerf]
--SET ENABLE_BROKER 
--GO
--ALTER DATABASE [DBAPerf]
--SET TRUSTWORTHY ON
--GO
--ALTER DATABASE [DBAadmin]
--SET ENABLE_BROKER 
--GO
--ALTER DATABASE [DBAadmin]
--SET TRUSTWORTHY ON
--GO

----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
--					START CERTIFICATE SETUP
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

USE [Master]
GO

--CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'H1nd@nb8rG'
--GO

--DECLARE	@Path	VarChar(max)
--	,@File	VarChar(max)
--	,@TSQL	VarChar(8000)

--SELECT	@Path	= dbaadmin.dbo.dbaudf_GetSharePath(dbaadmin.dbo.dbaudf_getShareUNC('dbasql'))
--	,@File	= @Path + '\MASTER_KEY_' + REPLACE(@@SERVERNAME,'\','$') + '.key'
--	,@TSQL	= 'BACKUP MASTER KEY TO FILE = '''+@File+''' ENCRYPTION BY PASSWORD = ''H1nd@nb8rG'''
--EXEC	(@TSQL)
--GO

--DECLARE @TSQL	VarChar(8000)

--SELECT	@TSQL	= 'CREATE CERTIFICATE TS_DBA_Master_Cert WITH SUBJECT = ''TS_DBA_Master_Cert_' + REPLACE(@@SERVERNAME,'\','$')+''''
--exec	(@TSQL) 
--GO


--DECLARE	@Path	VarChar(max)
--	,@File	VarChar(max)
--	,@TSQL	VarChar(8000)

--SELECT	@Path	= dbaadmin.dbo.dbaudf_GetSharePath(dbaadmin.dbo.dbaudf_getShareUNC('dbasql'))
--	,@File	= @Path + '\TS_DBA_Master_Cert_' + REPLACE(@@SERVERNAME,'\','$') + '.cer'
--	,@TSQL	= 'BACKUP CERTIFICATE TS_DBA_Master_Cert TO FILE = '''+@File+''' WITH PRIVATE KEY ( FILE = '''+ REPLACE(@File,'.cer','.pky') +''', ENCRYPTION BY PASSWORD = ''H1nd@nb8rG'')'
--EXEC	(@TSQL)
--GO




--USE [DBAAdmin]
--GO
--IF EXISTS (select * From sys.certificates where name = 'TS_DBA_Master_Cert')
--	DROP CERTIFICATE TS_DBA_Master_Cert
--GO

--DECLARE	@Path	VarChar(max)
--	,@File	VarChar(max)
--	,@TSQL	VarChar(8000)

--SELECT	@Path	= dbaadmin.dbo.dbaudf_GetSharePath(dbaadmin.dbo.dbaudf_getShareUNC('dbasql'))
--	,@File	= @Path + '\MASTER_KEY_' + REPLACE(@@SERVERNAME,'\','$') + '.key'
--	,@TSQL	= 'RESTORE MASTER KEY FROM FILE = '''+@File+''' DECRYPTION BY PASSWORD = ''H1nd@nb8rG'' ENCRYPTION BY PASSWORD = ''H1nd@nb8rG'' FORCE'
--EXEC	(@TSQL)
--GO


--DECLARE	@Path	VarChar(max)
--	,@File	VarChar(max)
--	,@TSQL	VarChar(8000)

--SELECT	@Path	= dbaadmin.dbo.dbaudf_GetSharePath(dbaadmin.dbo.dbaudf_getShareUNC('dbasql'))
--	,@File	= @Path + '\TS_DBA_Master_Cert_' + REPLACE(@@SERVERNAME,'\','$') + '.cer'
--	,@TSQL	= 'CREATE CERTIFICATE TS_DBA_Master_Cert FROM FILE = '''+@File+''' WITH PRIVATE KEY ( FILE = '''+ REPLACE(@File,'.cer','.pky') +''', ENCRYPTION BY PASSWORD = ''H1nd@nb8rG'', DECRYPTION BY PASSWORD = ''H1nd@nb8rG'')'
--EXEC	(@TSQL)
--GO




--USE [DBAPerf]
--GO
----DROP SIGNATURE FROM dbo.sCaptureBlockingEvents
----  BY CERTIFICATE TS_DBA_Master_Cert 
--GO


--IF EXISTS (select * From sys.certificates where name = 'TS_DBA_Master_Cert')
--	DROP CERTIFICATE TS_DBA_Master_Cert
--GO

--DECLARE	@Path	VarChar(max)
--	,@File	VarChar(max)
--	,@TSQL	VarChar(8000)

--SELECT	@Path	= dbaadmin.dbo.dbaudf_GetSharePath(dbaadmin.dbo.dbaudf_getShareUNC('dbasql'))
--	,@File	= @Path + '\MASTER_KEY_' + REPLACE(@@SERVERNAME,'\','$') + '.key'
--	,@TSQL	= 'RESTORE MASTER KEY FROM FILE = '''+@File+''' DECRYPTION BY PASSWORD = ''H1nd@nb8rG'' ENCRYPTION BY PASSWORD = ''H1nd@nb8rG'' FORCE'
--EXEC	(@TSQL)
--GO


--DECLARE	@Path	VarChar(max)
--	,@File	VarChar(max)
--	,@TSQL	VarChar(8000)

--SELECT	@Path	= dbaadmin.dbo.dbaudf_GetSharePath(dbaadmin.dbo.dbaudf_getShareUNC('dbasql'))
--	,@File	= @Path + '\TS_DBA_Master_Cert_' + REPLACE(@@SERVERNAME,'\','$') + '.cer'
--	,@TSQL	= 'CREATE CERTIFICATE TS_DBA_Master_Cert FROM FILE = '''+@File+''' WITH PRIVATE KEY ( FILE = '''+ REPLACE(@File,'.cer','.pky') +''', ENCRYPTION BY PASSWORD = ''H1nd@nb8rG'', DECRYPTION BY PASSWORD = ''H1nd@nb8rG'')'
--EXEC	(@TSQL)
--GO



----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
--					START SERVICE BROKER SETUP
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

--receive * from [dbo].[BlockedProcessReportQueue]
--alter queue [dbo].[BlockedProcessReportQueue] with status = OFF
--drop service [//SSWUG.org/BlockedProcessReportService]
--drop queue [dbo].[BlockedProcessReportQueue]

--ALTER DATABASE [dbaperf] SET NEW_BROKER WITH ROLLBACK IMMEDIATE;

--declare @conversation uniqueidentifier 
--while exists (select top 1 conversation_handle from sys.transmission_queue ) 
--begin 
--  set @conversation = (select top 1 conversation_handle from sys.transmission_queue )
--  end conversation @conversation with cleanup 
--end



USE [DBAPerf]

IF EXISTS (SELECT * 
 FROM [sys].[server_event_notifications] 
 WHERE [name] = 'BlockedProcessReportEventNotification')
	DROP EVENT NOTIFICATION BlockedProcessReportEventNotification ON SERVER 
GO 
IF EXISTS (SELECT * 
FROM [sys].[routes] 
WHERE name = N'BlockedProcessReportRoute')
	DROP ROUTE [BlockedProcessReportRoute]   
GO
IF EXISTS (SELECT * 
FROM [sys].[services] 
WHERE name = N'//SSWUG.org/BlockedProcessReportService')
	DROP SERVICE [//SSWUG.org/BlockedProcessReportService] 
GO
IF EXISTS (SELECT * 
FROM [sys].[service_queues] 
WHERE name = N'BlockedProcessReportQueue')
	DROP QUEUE [dbo].[BlockedProcessReportQueue]
GO

 
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('BlockedProcessesEventLog') IS NOT NULL
	DROP TABLE [dbo].[BlockedProcessesEventLog]
GO

CREATE TABLE [dbo].[BlockedProcessesEventLog]
		(
		[EventRowID]		[bigint] IDENTITY(1, 1) NOT NULL
		,[ProcID]		[VarChar](64) NOT NULL
		,[EventType]		[nvarchar](128) NOT NULL
		,[AlertTime]		[datetime] NULL
		,[Database]		[nvarchar](256) NULL
		,[BlockedProcessReport]	[xml] NULL
		,[BlockingEventData]	[xml] NULL
		,[AuditDate]		[smalldatetime] DEFAULT CURRENT_TIMESTAMP NOT NULL
		,[AlertData]		[VarChar](max) NULL
		,CONSTRAINT		[PK_SQLServerBlockingEvents_EventRowID] PRIMARY KEY CLUSTERED ([EventRowID] ASC) 
		WITH	(
			PAD_INDEX = OFF
			,STATISTICS_NORECOMPUTE = OFF
			,IGNORE_DUP_KEY = OFF
			,ALLOW_ROW_LOCKS = ON
			,ALLOW_PAGE_LOCKS = ON
			,FILLFACTOR = 100
			)
		ON [PRIMARY]
		)
		ON [PRIMARY]
GO
 
IF NOT EXISTS (SELECT * FROM [sys].[service_queues] WHERE name = N'BlockedProcessReportQueue')
	CREATE QUEUE [dbo].[BlockedProcessReportQueue]
GO

IF NOT EXISTS (SELECT * FROM [sys].[services] WHERE name = N'//SSWUG.org/BlockedProcessReportService')
	CREATE SERVICE [//SSWUG.org/BlockedProcessReportService] 
	 AUTHORIZATION [dbo] ON QUEUE [dbo].[BlockedProcessReportQueue] 
	 ([http://schemas.microsoft.com/SQL/Notifications/PostEventNotification])
GO

IF NOT EXISTS (SELECT * FROM [sys].[routes] WHERE name = N'BlockedProcessReportRoute')
	CREATE ROUTE [BlockedProcessReportRoute]   
	AUTHORIZATION [dbo]   
	WITH SERVICE_NAME  = N'//SSWUG.org/BlockedProcessReportService' 
	    ,ADDRESS  = N'LOCAL' 
GO

 
DECLARE @AuditServiceBrokerGuid [uniqueidentifier]
	,@SQL [varchar] (max);
 
-- Retrieving the service broker guid of CaptureDeadlockGraph database
SELECT		@AuditServiceBrokerGuid = [service_broker_guid]
FROM		[master].[sys].[databases]
WHERE		[name] = 'DBAPerf'
 
-- Building and executing dynamic SQL to create event notification objects
-- Dynamic SQL to create BlockedProcessReportEventNotification event notification object
SET @SQL = 'IF EXISTS (SELECT * 
 FROM [sys].[server_event_notifications] 
 WHERE [name] = ''BlockedProcessReportEventNotification'')
 
DROP EVENT NOTIFICATION BlockedProcessReportEventNotification ON SERVER 
 
CREATE EVENT NOTIFICATION BlockedProcessReportEventNotification 
ON SERVER
WITH fan_in
FOR BLOCKED_PROCESS_REPORT
TO SERVICE ''//SSWUG.org/BlockedProcessReportService'', ''' 
+ CAST(@AuditServiceBrokerGuid AS [varchar](50)) + ''';'
 
EXEC (@SQL)
GO
 
--SELECT * FROM [sys].[server_event_notifications]
--WHERE [name] = 'BlockedProcessReportEventNotification';
--GO

IF OBJECT_ID(N'[dbo].[wait_resource_name]') IS NOT NULL
	DROP FUNCTION [dbo].[wait_resource_name]
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[wait_resource_name](@obj nvarchar(max))
RETURNS @wait_resource TABLE	(
				 wait_resource_database_name	sysname
				,wait_resource_schema_name	sysname
				,wait_resource_object_name	sysname
				)
AS
BEGIN
    DECLARE @dbid int
    DECLARE @objid int

    IF @obj IS NULL RETURN
    IF @obj NOT LIKE 'OBJECT: %' RETURN

    SET @obj = SUBSTRING(@obj, 9, LEN(@obj) - 9 + CHARINDEX(':', @obj, 9))

    SET @dbid = LEFT(@obj, CHARINDEX(':', @obj, 1) - 1)
    SET @objid = SUBSTRING(@obj, CHARINDEX(':', @obj, 1) + 1, CHARINDEX(':', @obj, CHARINDEX(':', @obj, 1) + 1) - CHARINDEX(':', @obj, 1) - 1)

    INSERT INTO @wait_resource (wait_resource_database_name, wait_resource_schema_name, wait_resource_object_name)
    SELECT db_name(@dbid), object_schema_name(@objid, @dbid), object_name(@objid, @dbid)

    RETURN
END
GO

IF OBJECT_ID(N'[dbo].[sCaptureBlockingEvents]') IS NOT NULL
	DROP PROCEDURE [dbo].[sCaptureBlockingEvents]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROC [dbo].[sCaptureBlockingEvents]
WITH EXECUTE AS OWNER 
--Purpose:
--Service broker service program stored procedure that will be called by 
--BlockedProcessReportQueue, and will process messages from this queue.
 
AS
BEGIN

	SET NOCOUNT ON
	SET CONCAT_NULL_YIELDS_NULL ON
	SET ANSI_PADDING ON
	SET ANSI_WARNINGS ON 
 
	DECLARE  @EventTime [datetime]
		,@EventType [varchar](128)
		,@Database [nvarchar](256)
		,@BlockedProcessReport [xml]
		,@message_body [xml] 
		,@message_type_name [nvarchar](256)
		,@dialog [uniqueidentifier]
		,@BlockingDurration bigint
		,@EmailBody VarChar(max)
		,@Emailsubj VarChar(1000)
		,@EmailEventRowID BIGINT
		,@ProcID VarChar(64)
		,@LastAlerted DateTime
 

	BEGIN TRY
 		WHILE (1 = 1)
		BEGIN
			BEGIN
				BEGIN TRANSACTION
					-- Receive the next available message from the queue
					WAITFOR	(-- just handle one message at a time
						RECEIVE TOP(1)
						--the type of message received 
						@message_type_name = [message_type_id]
						,-- the message contents
						@message_body = CAST([message_body] AS [xml])
						,-- the identifier of the dialog this message was received on
						@dialog = [conversation_handle] 
						-- if the queue is empty for one second, give UPDATE and go away
						FROM [dbo].[BlockedProcessReportQueue]
						)
						,TIMEOUT 2000 
 
					--rollback and exit if no messages were found
					IF (@@ROWCOUNT = 0)
					BEGIN
						ROLLBACK TRANSACTION
						BREAK
					END
 
					--end conversation of end dialog message
					IF (@message_type_name IN	(
									 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
									,'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog')
									)
					BEGIN
						PRINT 'End Dialog received for dialog # ' + CAST(@dialog as [nvarchar](40));
						END CONVERSATION @dialog;
					END;
					ELSE
					BEGIN
						SET @ProcID = UPPER(CAST(@message_body AS [xml]).value('(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@id)[1]', 'varchar(64)'))
						SET @EventTime = CAST(@message_body AS [xml]).value('(/EVENT_INSTANCE/PostTime)[1]', 'datetime')
						SET @Database = DB_NAME(CAST(@message_body AS [xml]).value('(/EVENT_INSTANCE/DatabaseID)[1]', 'int'))
						SET @EventType = CAST(@message_body.query('/EVENT_INSTANCE/EventType/text()') AS [nvarchar](128))
						SET @BlockedProcessReport = CAST(@message_body AS [xml]).query('(/EVENT_INSTANCE/TextData/blocked-process-report/.)[1]')
						SET @BlockingDurration = CAST(CAST(@message_body AS [xml]).value('(/EVENT_INSTANCE/Duration)[1]', 'bigint') / 1000000.0 AS [decimal](6, 2))/60
						SET @EmailSubj	= '(Persistent Blocking for '+COALESCE(CAST(@BlockingDurration AS Varchar(50)),'??')+' Minutes on ' + @@Servername + '.' + COALESCE(@Database,'DBNAME')+')'
						SET @EmailBody	= COALESCE(CAST(@BlockedProcessReport AS nVarChar(4000)),'-- NO DATA --')

						INSERT INTO [dbo].[BlockedProcessesEventLog]
						  ([ProcID]
						  ,[EventType]
						  ,[AlertTime]
						  ,[Database]
						  ,[BlockedProcessReport]
						  ,[BlockingEventData])
						VALUES 
						(@ProcID,@EventType, @EventTime, @Database, @BlockedProcessReport, @message_body)

						SET @EmailEventRowID = SCOPE_IDENTITY()

						If @BlockingDurration >= 5
						BEGIN
							SELECT		@LastAlerted = MAX([AuditDate]) 
							FROM		[dbo].[BlockedProcessesEventLog]
							WHERE		[ProcID] = @ProcID
								AND	[AlertData] IS NOT NULL
							
							IF @LastAlerted IS NULL or DATEDIFF(minute,@LastAlerted,getdate()) >= 5
							BEGIN
								UPDATE		[dbo].[BlockedProcessesEventLog] 
									SET	[AlertData] = COALESCE(@EmailSubj,'') + COALESCE(@EmailBody,'') 
								WHERE		[EventRowID] = @EmailEventRowID

								SET @EmailSubj = @EmailSubj + '|'+CAST(@EmailEventRowID AS VarChar(50))+'|'
								RAISERROR(67020,10,1,@EmailSubj) WITH LOG
							END
						END
					END
				-- Commit the transaction. At any point before this, we could roll
				-- back - the received message would be back on the queue AND the response
				-- wouldn't be sent.
				COMMIT TRANSACTION
			END
 		END --end of loop
	END TRY  
	BEGIN CATCH 
		DECLARE @ErrorMessage [nvarchar](4000);
		DECLARE @ErrorSeverity [int];
		DECLARE @ErrorState [int];
 
		SELECT	@ErrorMessage	= ERROR_MESSAGE()
			,@ErrorSeverity = ERROR_SEVERITY()
			,@ErrorState	= ERROR_STATE();
 
		-- Use RAISERROR inside the CATCH block to return error
		-- information about the original error that caused
		-- execution to jump to the CATCH block.
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	END CATCH  
END
GO

--ADD SIGNATURE TO dbo.sCaptureBlockingEvents
--  BY CERTIFICATE TS_DBA_Master_Cert WITH PASSWORD = 'H1nd@nb8rG'
--GO
 
 
ALTER QUEUE [dbo].[BlockedProcessReportQueue]
WITH STATUS = ON
,ACTIVATION (PROCEDURE_NAME = [dbo].[sCaptureBlockingEvents]
    ,STATUS = ON
    ,MAX_QUEUE_READERS = 50
    ,EXECUTE AS OWNER)
GO 
 
 
USE [master]
GO
 
--Change the blocked process threshold to 5 seconds
EXEC [sp_configure] 'show advanced options', 1;
GO
 
RECONFIGURE;
GO
 
EXEC [sp_configure] 'blocked process threshold', 5;
GO
 
RECONFIGURE;
GO








EXEC msdb.dbo.sp_set_sqlagent_properties @alert_replace_runtime_tokens = 1
GO

USE [msdb]
GO
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
	EXEC msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
GO
IF EXISTS ( SELECT 1 FROM msdb.dbo.sysjobs where name = 'UTIL - Persistent Blocking Email')
	EXEC msdb.dbo.sp_delete_job @job_name=N'UTIL - Persistent Blocking Email', @delete_unused_schedule=1
GO

EXEC msdb.dbo.sp_add_job @job_name=N'UTIL - Persistent Blocking Email', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa'
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'UTIL - Persistent Blocking Email', @step_name=N'Send Email', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET QUOTED_IDENTIFIER ON
SET NOCOUNT ON

DECLARE	@EventTime 		[datetime]
		,@EventType 		[varchar](128)
		,@Database		[nvarchar](256)
		,@BlockedProcessReport	[xml]
		,@message_body 		[xml] 
		,@message_type_name	[nvarchar](256)
		,@dialog 			[uniqueidentifier]
		,@BlockingDurration 	bigint
		,@EmailBody 		VarChar(max)
		,@Emailsubj 		VarChar(1000)
		,@EmailEventRowID	BIGINT
		,@ProcID 		VarChar(64)
		,@LastAlerted 		DateTime
		,@msgString 		nvarchar(max)
		,@recipients 		VarChar(max)
		,@DBAEmail		VarChar(max)

SET @msgString 	= ''$(ESCAPE_SQUOTE(A-MSG))''
SET @DBAEmail	= ''tsdba@gmail.com;steve.ledridge@gmail.com''
SET @recipients 	= ''AppDevSalesTools@gettyimages.com''

-- GET DATA FROM BLOCKEDPROCESSESEVENTLOG TABLE
SELECT @EmailEventRowID 	= dbaadmin.dbo.dbaudf_ReturnPart(@msgString,2)
SELECT @message_body		= [BlockingEventData] FROM [dbaperf].[dbo].[BlockedProcessesEventLog] WHERE [EventRowID] = @EmailEventRowID 

-- SET VARIABLES
SET @ProcID 			= UPPER(CAST(@message_body AS [xml]).value(''(/EVENT_INSTANCE/TextData/blocked-process-report/blocked-process/process/@id)[1]'', ''varchar(64)''))
SET @EventTime			= CAST(@message_body AS [xml]).value(''(/EVENT_INSTANCE/PostTime)[1]'', ''datetime'')
SET @Database			= DB_NAME(CAST(@message_body AS [xml]).value(''(/EVENT_INSTANCE/DatabaseID)[1]'', ''int''))
SET @EventType			= CAST(@message_body.query(''/EVENT_INSTANCE/EventType/text()'') AS [nvarchar](128))
SET @BlockedProcessReport	= CAST(@message_body AS [xml]).query(''(/EVENT_INSTANCE/TextData/blocked-process-report/.)[1]'')
SET @BlockingDurration 		= CAST(CAST(@message_body AS [xml]).value(''(/EVENT_INSTANCE/Duration)[1]'', ''bigint'') / 1000000.0 AS [decimal](6, 2))/60
SET @EmailSubj			= ''Persistent Blocking for ''+COALESCE(CAST(@BlockingDurration AS Varchar(50)),''??'')+'' Minutes on '' + @@Servername + ''.'' + COALESCE(@Database,''DBNAME'')
SET @EmailBody			= COALESCE([dbaadmin].[dbo].[dbaudf_FormatXML2String](@BlockedProcessReport),''-- NO DATA --'')

--SET RECIPIENTS BASED ON DATABASE INVOLVED
IF @Database IN (''Master'',''Model'',''MSDB'',''TempDB'',''DBAAdmin'',''DBAPerf'',''DBACentral'',''SQLDeploy'',''DBAPerf_reports'',''DEPLOYcentral'')
	SET @recipients = @DBAEmail
ELSE
	SET @recipients = @recipients +'';''+ @DBAEmail

PRINT '' Sending Email to '' + @recipients
PRINT ''   SUBJECT: '' + @EmailSubj
PRINT ''=============================================================================================================''
PRINT ''                                               MESSAGE BODY''
PRINT ''=============================================================================================================''
PRINT @EmailBody
PRINT ''=============================================================================================================''
PRINT ''=============================================================================================================''

exec dbaadmin.dbo.dbasp_sendmail @recipients = @recipients,@subject = @EmailSubj, @message = @EmailBody

', 
		@database_name=N'master', 
		@output_file_name=N'O:\SQLjob_logs\PersistentBlockingReport.txt', 
		@flags=6
GO
EXEC msdb.dbo.sp_update_job @job_name=N'UTIL - Persistent Blocking Email', @start_step_id = 1
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'UTIL - Persistent Blocking Email', @server_name = N'(local)'
GO






EXEC msdb.dbo.sp_set_sqlagent_properties @alert_replace_runtime_tokens = 1
GO

IF EXISTS ( SELECT 1 FROM msdb.dbo.sysjobs where name = 'UTIL - WMI Response - DATABASE Class Event')
	EXEC msdb.dbo.sp_delete_job @job_name=N'UTIL - WMI Response - DATABASE Class Event', @delete_unused_schedule=1
GO
EXEC msdb.dbo.sp_add_job @job_name=N'UTIL - WMI Response - DATABASE Class Event', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Sends notifications to DBA when DATABASE DDL event(s) occur(s)', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa'
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'UTIL - WMI Response - DATABASE Class Event', 
	@step_name=N'Send e-mail in response to WMI alert(s)', 
	@step_id=1, 
	@subsystem=N'TSQL', 
	@command=N'SET QUOTED_IDENTIFIER ON
SET NOCOUNT ON

DECLARE	@subject			NVARCHAR(max)
		,@message		NVARCHAR(max)
		,@recipients		NVARCHAR(max)	= ''tsdba@gettyimages;steve.ledridge@gmail.com''

		,@Class			SYSNAME	=''$(ESCAPE_SQUOTE(WMI(__CLASS)))''
		,@ComputerName		SYSNAME	=''$(ESCAPE_SQUOTE(WMI(ComputerName)))''
		,@DatabaseName		SYSNAME	=''$(ESCAPE_SQUOTE(WMI(DatabaseName)))''
		,@LoginName		SYSNAME	=''$(ESCAPE_SQUOTE(WMI(LoginName)))''
		,@PostTime		SYSNAME	=''$(ESCAPE_SQUOTE(WMI(PostTime)))''
		,@SPID			INT		=''$(ESCAPE_SQUOTE(WMI(SPID)))''
		,@SQLInstance		SYSNAME	=''$(ESCAPE_SQUOTE(WMI(SQLInstance)))''
		,@Time_Created		SYSNAME	=''$(ESCAPE_SQUOTE(WMI(TIME_CREATED)))''
		,@TSQLCommand		XML		=''$(ESCAPE_SQUOTE(WMI(TSQLCommand)))''

SET	@Subject	= @ComputerName + '' - '' + @DatabaseName + '' - '' + @Class + '' Event''
SET	@message	= ''

SQL SERVER WMI ALERT FOR DDL_DATABASE_EVENTS 


	Class		: '' + @Class		 	+ ''
	ComputerName	: '' + @ComputerName	 	+ ''
	DatabaseName	: '' + @DatabaseName	 	+ ''
	LoginName	: '' + @LoginName		 	+ ''
	PostTime		: '' + @PostTime		 	+ ''
	SPID		: '' + CAST(@SPID AS VARCHAR(50))	+ ''
	SQLInstance	: '' + @SQLInstance		 	+ ''
	TIME_CREATED	: '' + @TIME_CREATED	 	+ ''

	TSQLCommand	: '' + @TSQLCommand.value(''(/TSQLCommand/CommandText)[1]'', ''varchar(max)'') 

EXEC	dbaadmin.dbo.dbasp_sendmail
		@recipients	= @recipients
		,@subject	= @subject
		,@message	= @message;
', 
		@database_name=N'master', 
		@output_file_name=N'O:\SQLjob_logs\EmailResposeToWMIAlert.txt', 
		@flags=6
GO
EXEC msdb.dbo.sp_update_job @job_name=N'UTIL - WMI Response - DATABASE Class Event', @start_step_id = 1
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'UTIL - WMI Response - DATABASE Class Event', @server_name = N'(local)'
GO


IF EXISTS ( SELECT 1 FROM msdb.dbo.sysjobs where name = 'UTIL - WMI Response - SERVER Class Event')
	EXEC msdb.dbo.sp_delete_job @job_name=N'UTIL - WMI Response - SERVER Class Event', @delete_unused_schedule=1
GO
EXEC msdb.dbo.sp_add_job @job_name=N'UTIL - WMI Response - SERVER Class Event', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Sends notifications to DBA when DATABASE DDL event(s) occur(s)', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa'
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'UTIL - WMI Response - SERVER Class Event', 
	@step_name=N'Send e-mail in response to WMI alert(s)', 
	@step_id=1, 
	@subsystem=N'TSQL', 
	@command=N'SET QUOTED_IDENTIFIER ON
SET NOCOUNT ON

DECLARE	@subject			NVARCHAR(max)
		,@message		NVARCHAR(max)
		,@recipients		NVARCHAR(max)	= ''tsdba@gettyimages;steve.ledridge@gmail.com''

		,@Class			SYSNAME	=''$(ESCAPE_SQUOTE(WMI(__CLASS)))''
		,@ComputerName		SYSNAME	=''$(ESCAPE_SQUOTE(WMI(ComputerName)))''
		,@LoginName		SYSNAME	=''$(ESCAPE_SQUOTE(WMI(LoginName)))''
		,@PostTime		SYSNAME	=''$(ESCAPE_SQUOTE(WMI(PostTime)))''
		,@SPID			INT		=''$(ESCAPE_SQUOTE(WMI(SPID)))''
		,@SQLInstance		SYSNAME	=''$(ESCAPE_SQUOTE(WMI(SQLInstance)))''
		,@Time_Created		SYSNAME	=''$(ESCAPE_SQUOTE(WMI(TIME_CREATED)))''
		,@TSQLCommand		XML		=''$(ESCAPE_SQUOTE(WMI(TSQLCommand)))''

SET	@Subject	= @ComputerName + '' - '' + @Class + '' Event''
SET	@message	= ''

SQL SERVER WMI ALERT FOR DDL_SERVER_LEVEL_EVENTS 


	Class		: '' + @Class		 	+ ''
	ComputerName	: '' + @ComputerName	 	+ ''
	LoginName	: '' + @LoginName		 	+ ''
	PostTime		: '' + @PostTime		 	+ ''
	SPID		: '' + CAST(@SPID AS VARCHAR(50))	+ ''
	SQLInstance	: '' + @SQLInstance		 	+ ''
	TIME_CREATED	: '' + @TIME_CREATED	 	+ ''

	TSQLCommand	: '' + @TSQLCommand.value(''(/TSQLCommand/CommandText)[1]'', ''varchar(max)'') 

EXEC	dbaadmin.dbo.dbasp_sendmail
		@recipients	= @recipients
		,@subject	= @subject
		,@message	= @message;
', 
		@database_name=N'master', 
		@output_file_name=N'O:\SQLjob_logs\EmailResposeToWMIAlert.txt', 
		@flags=6
GO
EXEC msdb.dbo.sp_update_job @job_name=N'UTIL - WMI Response - SERVER Class Event', @start_step_id = 1
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'UTIL - WMI Response - SERVER Class Event', @server_name = N'(local)'
GO




USE [msdb]
GO
IF EXISTS (SELECT * FROM msdb.dbo.sysalerts WHERE name = 'Extended Blocking')
	EXEC msdb.dbo.sp_delete_alert @name=N'Extended Blocking' 
GO
EXEC msdb.dbo.sp_add_alert @name=N'Extended Blocking', 
		@message_id=67020, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=5, 
		@include_event_description_in=5, 
		@event_description_keyword=N'Persistent Blocking', 
		@job_name=N'UTIL - Persistent Blocking Email'
GO





IF EXISTS (SELECT * FROM msdb.dbo.sysalerts WHERE name = 'WMI - Database DDL Events')
	EXEC msdb.dbo.sp_delete_alert @name=N'WMI - Database DDL Events' 
GO
EXEC msdb.dbo.sp_add_alert @name=N'WMI - Database DDL Events', 
  @message_id=0, 
  @severity=0, 
  @enabled=1, 
  @delay_between_responses=15, 
  @include_event_description_in=1, 
  @notification_message=N'WMI - DB Change notification', 
  @wmi_namespace=N'\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER', 
  @wmi_query=N'select * from DDL_DATABASE_EVENTS', 
  @job_name=N'UTIL - WMI Response - DATABASE Class Event'
GO

IF EXISTS (SELECT * FROM msdb.dbo.sysalerts WHERE name = 'WMI - Server DDL Events')
	EXEC msdb.dbo.sp_delete_alert @name=N'WMI - Server DDL Events' 
GO
EXEC msdb.dbo.sp_add_alert @name=N'WMI - Server DDL Events', 
  @message_id=0, 
  @severity=0, 
  @enabled=1, 
  @delay_between_responses=15, 
  @include_event_description_in=1, 
  @notification_message=N'WMI - Server Change notification', 
  @wmi_namespace=N'\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER', 
  @wmi_query=N'select * from DDL_SERVER_LEVEL_EVENTS', 
  @job_name=N'UTIL - WMI Response - SERVER Class Event'
GO

IF EXISTS (SELECT * FROM msdb.dbo.sysalerts WHERE name = 'WMI - Blocked Process Report')
	EXEC msdb.dbo.sp_delete_alert @name=N'WMI - Blocked Process Report' 
GO
EXEC msdb.dbo.sp_add_alert @name=N'WMI - Blocked Process Report', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=15, 
		@include_event_description_in=1, 
		@notification_message=N'WMI - Blocked Process Report', 
		@wmi_namespace=N'\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER', 
		@wmi_query=N'SELECT * FROM BLOCKED_PROCESS_REPORT', 
		@job_name=N'UTIL - WMI Response - DATABASE Class Event'
GO










GO
--SHOW EVENT POSIBILITIES
--SELECT * FROM sys.event_notification_event_types ORDER BY 2





 




IF EXISTS ( SELECT 1 FROM msdb.dbo.sysjobs where name = 'UTIL - WMI Response - Database Mirroring State Change Event')
	EXEC msdb.dbo.sp_delete_job @job_name=N'UTIL - WMI Response - Database Mirroring State Change Event', @delete_unused_schedule=1
GO
EXEC msdb.dbo.sp_add_job @job_name=N'UTIL - WMI Response - Database Mirroring State Change Event', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Sends notifications to DBA when DATABASE_MIRRORING_STATE_CHANGE event(s) occur(s)', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa'
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'UTIL - WMI Response - Database Mirroring State Change Event', 
	@step_name=N'Send e-mail in response to WMI alert(s)', 
	@step_id=1, 
	@subsystem=N'TSQL', 
	@command=N'SET QUOTED_IDENTIFIER ON
SET NOCOUNT ON

DECLARE	@subject			NVARCHAR(max)
		,@message		NVARCHAR(max)
		,@recipients		NVARCHAR(max)	= ''tsdba@gettyimages;steve.ledridge@gmail.com''

		,@Class			SYSNAME	=''$(ESCAPE_SQUOTE(WMI(__CLASS)))''
		,@ComputerName		SYSNAME	=''$(ESCAPE_SQUOTE(WMI(ComputerName)))''
		,@DatabaseName		SYSNAME	=''$(ESCAPE_SQUOTE(WMI(ComputerName)))''
		,@LoginName		SYSNAME	=''$(ESCAPE_SQUOTE(WMI(SessionLoginName)))''
		,@PostTime		SYSNAME	=''$(ESCAPE_SQUOTE(WMI(PostTime)))''
		,@SPID			INT		=''$(ESCAPE_SQUOTE(WMI(SPID)))''
		,@SQLInstance		SYSNAME	=''$(ESCAPE_SQUOTE(WMI(SQLInstance)))''
		,@Time_Created		SYSNAME	=''$(ESCAPE_SQUOTE(WMI(StartTime)))''
		,@State			SYSNAME	=''$(ESCAPE_SQUOTE(WMI(State)))''
		,@TextData		VARCHAR(max) =''$(ESCAPE_SQUOTE(WMI(TextData)))''

SET	@Subject	= @ComputerName + '' - '' + @Class + '' Event''
SET	@message	= ''

SQL SERVER WMI ALERT FOR DDL_SERVER_LEVEL_EVENTS 


	Class		: '' + @Class		 	+ ''
	ComputerName	: '' + @ComputerName	 	+ ''
	DatabaseName	: '' + @DatabaseName	 	+ ''
	LoginName	: '' + @LoginName		 	+ ''
	PostTime		: '' + @PostTime		 	+ ''
	SPID		: '' + CAST(@SPID AS VARCHAR(50))	+ ''
	SQLInstance	: '' + @SQLInstance		 	+ ''
	TIME_CREATED	: '' + @TIME_CREATED	 	+ ''
	State		: '' + @State	 	+ ''

	TextData	: '' + @TextData 

EXEC	dbaadmin.dbo.dbasp_sendmail
		@recipients	= @recipients
		,@subject	= @subject
		,@message	= @message;
', 
		@database_name=N'master', 
		@output_file_name=N'O:\SQLjob_logs\EmailResposeTo_WMI_DBMSC_Alert.txt', 
		@flags=6
GO
EXEC msdb.dbo.sp_update_job @job_name=N'UTIL - WMI Response - Database Mirroring State Change Event', @start_step_id = 1
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'UTIL - WMI Response - Database Mirroring State Change Event', @server_name = N'(local)'
GO
