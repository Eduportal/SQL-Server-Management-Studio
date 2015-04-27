SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NOCOUNT ON
GO
USE [dbaadmin]
GO
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- CREATE TEMP SESSION UPDATE SPROC
----------------------------------------------------------------------------
----------------------------------------------------------------------------
CREATE PROCEDURE	##UpdateAggSessionResults
			(
			@SessionID UniqueIdentifier
			,@StatusMsg nVarChar(MAX)
			)
AS
PRINT	@StatusMsg
PRINT	''
IF NOT EXISTS (SELECT 1 FROM [dbaadmin].[dbo].[Filescan_AggSession] WHERE [SessionID]=@SessionID)
INSERT INTO [dbaadmin].[dbo].[Filescan_AggSession]
           ([SessionID]
           ,[RunDate]
           ,[SessionResults])
     VALUES
           (@SessionID
           ,GetDate()
           ,@StatusMsg)
ELSE 
UPDATE	[dbaadmin].[dbo].[Filescan_AggSession]
	SET	[SessionResults]	=[SessionResults]
					+ Cast(GetDate()AS VarChar(50)) 
					+ ' - ' 
					+ COALESCE(@StatusMsg,'')
					+ CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
WHERE	[SessionID]=@SessionID
GO
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- START PROCESSING
----------------------------------------------------------------------------
----------------------------------------------------------------------------
DECLARE @TSQL			VarChar(8000)
DECLARE @SessionID		UniqueIdentifier
DECLARE @Date			DateTime
DECLARE @DateStamp		VarChar(8)
DECLARE @central_server		sysname
DECLARE @StatusMsg		nVarChar(MAX)
DECLARE @TmpRowcount		Int

-- SET VARIABLES
SELECT	@SessionID		= NewID()
	,@Date			= GETDATE()
	,@central_server	= @@SERVERNAME 
					
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                          UPDATE SESSION RESULTS		          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET @StatusMsg	= '-----------------------------------------------------------' +CHAR(13)+CHAR(10)
		+ '-----------------------------------------------------------'	+CHAR(13)+CHAR(10)
		+ '--             STARTING FILESCAN AGREGATION              --' +CHAR(13)+CHAR(10)
		+ '-----------------------------------------------------------' +CHAR(13)+CHAR(10)
		+ '-----------------------------------------------------------' +CHAR(13)+CHAR(10)
		+ '--  ' + CAST(@Date AS VarChar(50)) +CHAR(13)+CHAR(10)
							 
exec	##UpdateAggSessionResults @SessionID, @StatusMsg
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- DROP IMPORT TABLE IF EXISTS
----------------------------------------------------------------------------
----------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FilescanImport_CurrentWorkTable]') AND type in (N'U'))
	DROP TABLE [dbo].[FilescanImport_CurrentWorkTable]
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- MOVE ACTIVE FILES TO WORK DIRECTORY
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET	@TSQL	= 'Move \\SQLDEPLOYER04\SQLDEPLOYER04_filescan\Aggregates\SQLErrorLOG*.w3c \\SQLDEPLOYER04\SQLDEPLOYER04_filescan\Aggregates\WORK'
exec master..xp_cmdshell @TSQL, no_output

SET	@TSQL	= 'Move \\SEAFRESQLDBA01\SEAFRESQLDBA01_filescan\Aggregates\SQLErrorLOG*.w3c \\SEAFRESQLDBA01\SEAFRESQLDBA01_filescan\Aggregates\WORK'
exec master..xp_cmdshell @TSQL, no_output
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                          UPDATE SESSION RESULTS		          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET	@StatusMsg = 'Moved New Files to WORK Directory'					 
exec	##UpdateAggSessionResults @SessionID, @StatusMsg
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- IMPORT FILES FROM WORK DIRECTORY
----------------------------------------------------------------------------
----------------------------------------------------------------------------
CREATE TABLE	#LogParserResults (ln nvarchar(4000))

SET	@TSQL	= 'LogParser file:\\'+ @central_server + '\'+ @central_server 
		+ '_filescan\Aggregates\Queries\AggQueries\SQLErrorLog_CreateAggTable.sql -i:W3C -o:SQL -server:'
		+ @central_server 
		+ ' -database:dbaadmin -driver:"SQL Server" -createTable:ON -clearTable:ON'
INSERT #LogParserResults exec master..xp_cmdshell @TSQL
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                         UPDATE SESSION RESULTS		          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET	@StatusMsg	= 'Log Parser Complete' + CHAR(13) + CHAR(10)
SELECT	@StatusMsg	= @StatusMsg 
			+ ln 
			+ CHAR(13) 
			+ CHAR(10)
FROM	#LogParserResults
WHERE	ln IS NOT NULL
					 
exec	##UpdateAggSessionResults @SessionID, @StatusMsg
DROP TABLE #LogParserResults
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--   LOG ALL REPORTING SERVERS
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- This is done by looking at the files in the Work directory rather than the
-- import because servers can create 0 byte files if no errors were found in
-- the last check
----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--   GET FILE LISTINGS IN WORK DIRECTORIES
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--  One Entry for each Central Server
----------------------------------------------------------------------------
----------------------------------------------------------------------------
Create table #DirectoryListing (ln nvarchar(4000))
set @TSQL = 'DIR \\SQLDEPLOYER04\SQLDEPLOYER04_filescan\Aggregates\WORK\SQLErrorLOG_*.w3c /b'
Insert #DirectoryListing exec master..xp_cmdshell @TSQL
set @TSQL = 'DIR \\SEAFRESQLDBA01\SEAFRESQLDBA01_filescan\Aggregates\WORK\SQLErrorLOG_*.w3c /b'
Insert #DirectoryListing exec master..xp_cmdshell @TSQL

delete from #DirectoryListing
where	ln is NULL
 or	ln like 'File Not Found'

UPDATE	#DirectoryListing
SET	ln = REPLACE(REPLACE(REPLACE(ln,'SQLErrorLOG_',''),'.w3c',''),'$','|') --leaving only the server name
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                         UPDATE SESSION RESULTS		          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET	@StatusMsg = 'Populated List of Reporting Servers'					 
exec	##UpdateAggSessionResults @SessionID, @StatusMsg
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                          ADD ANY NEW ENTRIES 
--         DUPLICATES FALL TO THE FLOOOR BECAUSE OF INDEX IGNORE DUPES
----------------------------------------------------------------------------
----------------------------------------------------------------------------
INSERT INTO	[dbaadmin].[dbo].[Filescan_MachineSource]
		([Machine]
		,[Instance]
		,[SourceType]
		,[LastReported]
		,[SessionAdded])
SELECT		[dbaadmin].[dbo].[ReturnPart] ([ln],1) [Machine]
		,COALESCE([dbaadmin].[dbo].[ReturnPart] ([ln],2),'')[Instance]
		,'SQL_ERRORLOG' [SourceType]
		,GetDate() [EventDateTime]
		,@SessionID
FROM		#DirectoryListing
GROUP BY	[dbaadmin].[dbo].[ReturnPart] ([ln],1) 
		,COALESCE([dbaadmin].[dbo].[ReturnPart] ([ln],2),'')
ORDER BY	[dbaadmin].[dbo].[ReturnPart] ([ln],1) 
		,COALESCE([dbaadmin].[dbo].[ReturnPart] ([ln],2),'') 
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                          UPDATE SESSION RESULTS		          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET	@StatusMsg = 'Added ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' New Reporting Servers'
exec	##UpdateAggSessionResults @SessionID, @StatusMsg
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                          UPDATE CHANGED ENTRIES 
----------------------------------------------------------------------------
----------------------------------------------------------------------------
UPDATE		[dbaadmin].[dbo].[Filescan_MachineSource]
	SET	[LastReported] = T2.[EventDateTime]
		,[SessionUpdated] = @SessionID
FROM		[dbaadmin].[dbo].[Filescan_MachineSource] T1		
INNER JOIN	(
		SELECT		[dbaadmin].[dbo].[ReturnPart] ([ln],1) [Machine]
				,COALESCE([dbaadmin].[dbo].[ReturnPart] ([ln],2),'')[Instance]
				,'SQL_ERRORLOG'	[SourceType]
				,GetDate()   [EventDateTime]
		FROM		#DirectoryListing
		GROUP BY	[dbaadmin].[dbo].[ReturnPart] ([ln],1) 
				,COALESCE([dbaadmin].[dbo].[ReturnPart] ([ln],2),'')
		) T2
	ON	T1.[Machine]		 = T2.[Machine]
	AND	T1.[Instance]		 = T2.[Instance]
	AND	T1.[SourceType]		 = T2.[SourceType]
	AND	T1.[LastReported]	!= T2.[EventDateTime]
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                            UPDATE SESSION RESULTS		          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET	@StatusMsg = 'UPDATED ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' Reporting Servers'
exec	##UpdateAggSessionResults @SessionID, @StatusMsg
----------------------------------------------------------------------------
----------------------------------------------------------------------------
DROP table #DirectoryListing
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- MOVE WORK FILES TO ARCHIVE DIRECTORY
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET	@TSQL	= 'Move \\SQLDEPLOYER04\SQLDEPLOYER04_filescan\Aggregates\WORK\SQLErrorLOG*.w3c \\SQLDEPLOYER04\SQLDEPLOYER04_filescan\Aggregates\WORK\Archive'
exec master..xp_cmdshell @TSQL, no_output

SET	@TSQL	= 'Move \\SEAFRESQLDBA01\SEAFRESQLDBA01_filescan\Aggregates\WORK\SQLErrorLOG*.w3c \\SEAFRESQLDBA01\SEAFRESQLDBA01_filescan\Aggregates\WORK\Archive'
exec master..xp_cmdshell @TSQL, no_output
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                            UPDATE SESSION RESULTS		          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET	@StatusMsg = 'Moved New Files to ARCHIVE Directory'
exec	##UpdateAggSessionResults @SessionID, @StatusMsg
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- CHECK FOR IMPORTS
----------------------------------------------------------------------------
----------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FilescanImport_CurrentWorkTable]') AND type in (N'U'))
	BEGIN
		----------------------------------------------------------------------------
		--                            UPDATE SESSION RESULTS		          --
		----------------------------------------------------------------------------
		----------------------------------------------------------------------------
		SET	@StatusMsg = 'No Data Imported No need to Continue'
		exec	##UpdateAggSessionResults @SessionID, @StatusMsg
		----------------------------------------------------------------------------
		----------------------------------------------------------------------------
		GOTO NoDataImported
	END
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- ALTER TABLE AND CLEANUP DATA ISSUES
----------------------------------------------------------------------------
----------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM syscolumns WHERE ID = OBJECT_ID('FilescanImport_CurrentWorkTable') AND name = 'ID')
BEGIN
ALTER TABLE dbo.FilescanImport_CurrentWorkTable ADD 
	KnownCondition varchar(50) NOT NULL CONSTRAINT DF_FilescanImport_CurrentWorkTable__KnownCondition DEFAULT 'Unknown'
	, FixData varchar(MAX) NULL
	, FixQuery varchar(MAX) NULL
	, ID bigint NOT NULL IDENTITY (1, 1)

ALTER TABLE dbo.FilescanImport_CurrentWorkTable ADD CONSTRAINT
	PK_FilescanImport_CurrentWorkTable PRIMARY KEY CLUSTERED 
	(
	ID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END

UPDATE	[dbo].[FilescanImport_CurrentWorkTable]	  -- DECODE ALL "+" TO " " IN MESSAGE Field AND MAKE SURE 
  SET	Message = LTRIM(RTRIM(REPLACE(Message,'+',' '))) -- THERE IS NO LEADING OR TRAILING SPACES
  
UPDATE	[dbo].[FilescanImport_CurrentWorkTable]	  -- SOME VERSIONS OF SQL HAVE A SLIGHTLY DIFFERENT POSITION 
  SET	Message = RIGHT(Message,LEN(Message)-2)	  -- FOR THE MESSAGE FIELD SO SOME GET EXTRA TRASH ON THE LEFT
WHERE	Message Like '--%'			  -- WHICH NEEDS CLEANED OFF.
  
UPDATE	[dbo].[FilescanImport_CurrentWorkTable]	  -- SOME VERSIONS OF SQL HAVE A SLIGHTLY DIFFERENT POSITION
  SET	Message = RIGHT(Message,LEN(Message)-1)	  -- FOR THE MESSAGE FIELD SO SOME GET EXTRA TRASH ON THE LEFT
WHERE	Message Like '-%'			  -- WHICH NEEDS CLEANED OFF.
  
DELETE	[dbo].[FilescanImport_CurrentWorkTable]	  -- ALL RECORDS WITH [SourceFileIndex] = 1 ARE JUST USED
WHERE	[SourceFileIndex] = 1			  -- TO IDENTIFY REPORTING MACHINES AND ARE NOT ERRORS

DELETE	[dbo].[FilescanImport_CurrentWorkTable]	  -- NO ACTION NEEDED SHOULD NOT BE HERE
WHERE	[Message] Like 'DBA WARNING: Local DEPLinfo.dbo.control_local rows were orphaned and have been cancelled on server%No action needed%'

DELETE	[dbo].[FilescanImport_CurrentWorkTable]	  -- DATA ACCESS COMPONENTS SHOULD NOT BE HERE
WHERE	[Message] Like '%The OLE DB initialization service failed to load. Reinstall Microsoft Data Access Components.%'
----------------------------------------------------------------------------
--                            UPDATE SESSION RESULTS		          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET	@StatusMsg = 'Finished Modifing and Cleaning Work Table'
exec	##UpdateAggSessionResults @SessionID, @StatusMsg
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- START MARKING KNOWN CONDITIONS
----------------------------------------------------------------------------
----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: Backup-NoFullExists
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'Backup-NoFullExists'
			,[FixData] = REPLACE(REPLACE('Server=%Server%,Database=%Database%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%Database%'
					,LTRIM(RTRIM(REPLACE(REPLACE([Message],'DBA WARNING: No Full Backups exist for Database',''),'''','')))
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like '%No Full Backups exist for Database%'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' Backup-NoFullExists'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: Backup-NoTranLogExists
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'Backup-NoTranLogExists'
			,[FixData] = REPLACE(REPLACE('Server=%Server%,Database=%Database%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%Database%'
					,LTRIM(RTRIM(REPLACE(REPLACE([Message],'DBA WARNING: No TranLog Backups exist for Database',''),'''','')))
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like '%No TranLog Backups exist for Database%'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' Backup-NoTranLogExists'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: Backup-NoTranLogCurrent
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'Backup-NoTranLogCurrent'
			,[FixData] = REPLACE(REPLACE('Server=%Server%,Database=%Database%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%Database%'
					,REPLACE(SUBSTRING([Message],CHARINDEX('exists for Database',[Message])+21,LEN([Message])-(CHARINDEX('exists for Database',[Message])+22)),'.','')
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like '%No Current Transaction Log Backup exists for Database%'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' Backup-NoTranLogCurrent'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: Backup-FailureFull
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'Backup-FailureFull'
			,[FixData] = REPLACE(REPLACE('Server=%Server%,Database=%Database%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%Database%'
					,REPLACE(REPLACE(LEFT(REPLACE(REPLACE(SUBSTRING([Message],CHARINDEX('BACKUP DATABASE',[Message])+16,CHARINDEX('Check',[Message]+'Check')-(CHARINDEX('BACKUP DATABASE',[Message])+16)),'WITH DIFFERENTIAL',''),'.',''),CHARINDEX('TO',REPLACE(REPLACE(SUBSTRING([Message],CHARINDEX('BACKUP DATABASE',[Message])+16,CHARINDEX('Check',[Message]+'Check')-(CHARINDEX('BACKUP DATABASE',[Message])+16)),'WITH DIFFERENTIAL',''),'.','')+'TO')-1),'[',''),']','')
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like '%BACKUP failed to complete the command BACKUP DATABASE%'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' Backup-FailureFull'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: Backup-FailureLOG
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'Backup-FailureLOG'
			,[FixData] = REPLACE(REPLACE('Server=%Server%,Database=%Database%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%Database%'
					,REPLACE(REPLACE(LEFT(REPLACE(REPLACE(SUBSTRING([Message],CHARINDEX('BACKUP LOG',[Message])+11,CHARINDEX('Check',[Message]+'Check')-(CHARINDEX('BACKUP LOG',[Message])+11)),'WITH DIFFERENTIAL',''),'.',''),CHARINDEX('TO',REPLACE(REPLACE(SUBSTRING([Message],CHARINDEX('BACKUP DATABASE',[Message])+16,CHARINDEX('Check',[Message]+'Check')-(CHARINDEX('BACKUP DATABASE',[Message])+16)),'WITH DIFFERENTIAL',''),'.','')+'TO')-1),'[',''),']','')
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like '%BACKUP failed to complete the command BACKUP LOG%'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' Backup-FailureLOG'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: Backup-Failure
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'Backup-Failure'
			,[FixData] = NULL
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	(
		[Message] Like '%BACKUP failed to complete the command%'
	  OR	[Message] Like '%BackupMedium::ReportIoError:%'
	  OR	[Message] Like '%BackupVirtualDeviceFile::RequestDurableMedia:%'
	  OR	[Message] Like '%BackupIoRequest::WaitForIoCompletion:%'
	  OR	[Message] Like '%BackupDiskFile::CreateMedia:%'
	  OR	[Message] Like '%BackupDiskFile::OpenMedia:%'
	  OR	[Message] Like '%BackupSoftFile::WriteMediaFileMark:%'
	  OR	[Message] Like '%BackupVirtualDeviceFile::ClearError:%'
		)
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' Backup-Failure'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: Login-NoDefaultDBAccess 
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'Login-NoDefaultDBAccess'
			,[FixData] = REPLACE(REPLACE(REPLACE('Server=%Server%,Database=%Database%,Login=%Login%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%Database%'
					,SUBSTRING([Message],CHARINDEX('default DB',[Message])+12,CHARINDEX('on server',[Message])-(CHARINDEX('default DB',[Message])+14))
					),'%Login%'
					,SUBSTRING([Message],CHARINDEX('Login',[Message])+7,CHARINDEX('does not have',[Message])-(CHARINDEX('Login',[Message])+9))
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	 [Message] Like '%WARNING: Login % does not have access to default DB%'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' Login-NoDefaultDBAccess'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: Missing-Software-Redgate
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'Missing-Software-Redgate'
			,[FixData] = ''
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like '%WARNING: Restore SQB process skipped because Redgate is not installed.'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' Missing-Software-Redgate'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: Missing-Schema-BuildTable
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'Missing-Schema-BuildTable'
			,[FixData] = REPLACE(REPLACE('Server=%Server%,Database=%Database%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%Database%'
					,SUBSTRING([Message],CHARINDEX('DBA WARNING:',[Message])+13,CHARINDEX('is missing',[Message])-(CHARINDEX('DBA WARNING:',[Message])+14))
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like '%WARNING: % is missing the "Build" table.'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' Missing-Schema-BuildTable'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: User-Disabled
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'User-Disabled'
			,[FixData] = REPLACE(REPLACE(REPLACE('Server=%Server%,Database=%Database%,User=%User%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%Database%'
					,SUBSTRING([Message],CHARINDEX('found in database',[Message])+19,CHARINDEX('on server',[Message])-(CHARINDEX('found in database',[Message])+21))
					),'%User%'
					,SUBSTRING([Message],CHARINDEX('SQL USER',[Message])+10,CHARINDEX('found in database',[Message])-(CHARINDEX('SQL USER',[Message])+12))
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like '%Disabled (hasdbaccess=0) SQL USER%'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' User-Disabled'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: User-Orphaned
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'User-Orphaned'
			,[FixData] = REPLACE(REPLACE(REPLACE('Server=%Server%,Database=%Database%,User=%User%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%Database%'
					,SUBSTRING([Message],CHARINDEX('found in database',[Message])+19,CHARINDEX('on server',[Message])-(CHARINDEX('found in database',[Message])+21))
					),'%User%'
					,SUBSTRING([Message],CHARINDEX('Orphaned SQL USER',[Message])+19,CHARINDEX('found in database',[Message])-(CHARINDEX('Orphaned SQL USER',[Message])+21))
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like '%Orphaned SQL USER%'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' User-Orphaned'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: Login-Orphaned
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'Login-Orphaned'
			,[FixData] = REPLACE(REPLACE('Server=%Server%,Login=%Login%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%Login%'
					,REPLACE(REPLACE(SUBSTRING([Message],CHARINDEX('-',[Message])+3,LEN([Message])-(CHARINDEX('-',[Message])+3)),'.',''),'''','')
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like '%Orphaned SQL Login%'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' Login-Orphaned'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: User-OutOfSync
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'User-OutOfSync'
			,[FixData] = REPLACE(REPLACE(REPLACE('Server=%Server%,Database=%Database%,User=%User%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%Database%'
					,SUBSTRING([Message],CHARINDEX('found in database',[Message])+19,CHARINDEX('on server',[Message])-(CHARINDEX('found in database',[Message])+21))
					),'%User%'
					,SUBSTRING([Message],CHARINDEX('SQL USER',[Message])+10,CHARINDEX('found in database',[Message])-(CHARINDEX('SQL USER',[Message])+12))
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like '%WARNING: Out-of-Sync SQL USER%'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' User-OutOfSync'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: AgentJob-StepFailed
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- NOTES: Have seen two formats for the message on this condition which is
	--  probably due to SQL Version differences. The lesser Seen Example has the
	--  "Date/Time:" parameter between the "Step:" and the "Message:" parameters. 
	--  I am using a CASE statement below with this info to Identify the end of
	--  the "Step:" value. Here is an example of each format I have seen so far.
	-- 
	-- DBA Warning:  SQL job step failure detected.  Job: APPL - ETLSilverPop  Step: SilverPop extract  Date/Time: 20100115 60000   Message: Executed as user: AMER\SQLAdminDev. ...n 9.00.4035.00 for 64-bit  Copyright (C) Microsoft Corp 1984-2005. All rights rese
	-- DBA WARNING: Job Step Failed - Job: 'UTIL - SQL Perf Log Process' Step: 'DMV QueryStats Capture' Message: 'Executed as user: AMER\SQLAdminLoad. Could not find stored procedure 'dbaadmin.dbo.dbasp_DMVcapture_querystats'. [SQLSTATE 42000] (Error 2812).  NOT
	--
	--
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'AgentJob-StepFailed'
			,[FixData] = REPLACE(REPLACE(REPLACE('Server=%Server%,Job=%Job%,Step=%Step%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%Job%'
					,SUBSTRING([Message],CHARINDEX('Job:',[Message])+6,CHARINDEX('Step:',[Message])-(CHARINDEX('Job:',[Message])+8))
					),'%Step%'
					,CASE	WHEN [Message] Like '%Date/Time:%' THEN SUBSTRING([Message],CHARINDEX('Step:',[Message])+6,CHARINDEX('Date/Time:',[Message])-(CHARINDEX('Step:',[Message])+8))
						ELSE SUBSTRING([Message],CHARINDEX('Step:',[Message])+7,CHARINDEX('Message:',[Message])-(CHARINDEX('Step:',[Message])+9))
						END
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like '%WARNING:%Job Step Fail%'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' AgentJob-StepFailed'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: dbasp_File_Transit-InvalidParameters
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'dbasp_File_Transit-InvalidParameters'
			,[FixData] = REPLACE('Server=%Server%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					)
			,[FixQuery] = NULL 
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like '%WARNING: Invalid parameters to dbasp_File_Transit%'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' dbasp_File_Transit-InvalidParameters'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: AgentJob-LongRunning
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'AgentJob-LongRunning'
			,[FixData] = REPLACE(REPLACE('Server=%Server%,Job=%Job%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%Job%'
					,SUBSTRING([Message],CHARINDEX(': Job',[Message])+7,CHARINDEX('has been running',[Message])-(CHARINDEX(': Job',[Message])+9))
					)
			,[FixQuery] = NULL 
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	Message Like '%Job%has been running for%hours%'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' AgentJob-LongRunning'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: SQLServer-IO-LogicalConsistancy
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'SQLServer-IO-LogicalConsistancy'
			,[FixData] = REPLACE(REPLACE('Server=%Server%,File=%File%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%File%'
					,SUBSTRING([Message],CHARINDEX('in file',[Message])+9,CHARINDEX('''.',[Message]+'''.',CHARINDEX('in file',[Message])+10)-(CHARINDEX('in file',[Message])+9))
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like 'SQL Server detected a logical consistency-based I/O error%'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' SQLServer-IO-LogicalConsistancy'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: Disk-OutOfSpace
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET @TmpRowcount = 0 -- USE WHEN MULTIPLE UPDATES IN A SINGLE CONDITION
	
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'Disk-OutOfSpace'
			,[FixData] = REPLACE(REPLACE('Server=%Server%,File=%File%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%File%'
					,LEFT([Message],CHARINDEX(':MSSQL_DBCC16:',[Message])-1)
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like '%:MSSQL_DBCC16: Operating system error 112(There is not enough space on the disk.) encountered.'
	SET @TmpRowcount = @TmpRowcount + @@Rowcount -- USE WHEN MULTIPLE UPDATES IN A SINGLE CONDITION

	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'Disk-OutOfSpace'
			,[FixData] = REPLACE(REPLACE('Server=%Server%,File=%File%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%File%'
					,SUBSTRING([Message],CHARINDEX('file ''',[Message])+6,CHARINDEX(''' (',[Message])-(CHARINDEX('file ''',[Message])+6))
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like 'During restore restart, an I/O error occurred on checkpoint file%(operating system error 112(There is not enough space on the disk.%'
	SET @TmpRowcount = @TmpRowcount + @@Rowcount -- USE WHEN MULTIPLE UPDATES IN A SINGLE CONDITION

	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'Disk-OutOfSpace'
			,[FixData] = REPLACE(REPLACE('Server=%Server%,File=%File%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%File%'
					,SUBSTRING([Message],CHARINDEX('backup device',[Message])+15,CHARINDEX('Operating system error 112',[Message]+'''.')-(CHARINDEX('backup device',[Message])+18))
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like 'BackupMedium::%Operating system error 112%'
	SET @TmpRowcount = @TmpRowcount + @@Rowcount -- USE WHEN MULTIPLE UPDATES IN A SINGLE CONDITION

	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'Disk-OutOfSpace'
			,[FixData] = REPLACE(REPLACE('Server=%Server%,File=%File%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%File%'
					,LEFT([Message],CHARINDEX(': Operating system error 112',[Message])-1)
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like '%: Operating system error 112%'
	SET @TmpRowcount = @TmpRowcount + @@Rowcount -- USE WHEN MULTIPLE UPDATES IN A SINGLE CONDITION
	  
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'Disk-OutOfSpace'
			,[FixData] = REPLACE(REPLACE(REPLACE('Server=%Server%,Database=%Database%,FileGroup=%FileGroup%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%Database%'
					,SUBSTRING([Message],CHARINDEX('in database',[Message])+13,CHARINDEX('because the',[Message]+'''.')-(CHARINDEX('in database',[Message])+15))
					),'%FileGroup%'
					,SUBSTRING([Message],CHARINDEX('because the',[Message])+13,CHARINDEX('filegroup is full',[Message])-(CHARINDEX('because the',[Message])+15))
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like 'Could not allocate space for object%in database%because the%filegroup is full%'
	SET @TmpRowcount = @TmpRowcount + @@Rowcount -- USE WHEN MULTIPLE UPDATES IN A SINGLE CONDITION
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@TmpRowcount AS VarChar(50)) + ' Disk-OutOfSpace'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: GSSearch-ImportStatus-dtEndDateIsNull
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'GSSearch-ImportStatus-dtEndDateIsNull'
			,[FixData] = NULL
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like '%A Warning:  GSSearch ImportStatus contains rows where dtEndDate IS NULL.%'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' GSSearch-ImportStatus-dtEndDateIsNull'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: User-InvalidDefaultSchema
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'User-InvalidDefaultSchema'
			,[FixData] = REPLACE(REPLACE(REPLACE('Server=%Server%,Database=%Database%,User=%User%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%Database%'
					,SUBSTRING([Message],CHARINDEX('found in database',[Message])+19,CHARINDEX('on server',[Message]+'''.')-(CHARINDEX('found in database',[Message])+21))
					),'%User%'
					,SUBSTRING([Message],CHARINDEX('User name =',[Message])+13,CHARINDEX('The default schema does not exist',[Message])-(CHARINDEX('User name =',[Message])+16))
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like '%WARNING: DB User with invalid default schema found in database%'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' User-InvalidDefaultSchema'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: TimeOut-Latch
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'TimeOut-Latch'
			,[FixData] = REPLACE(REPLACE('Server=%Server%,ObjectID=%ObjectID%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%ObjectID%'
					,SUBSTRING([Message],CHARINDEX('object ID',[Message])+9,CHARINDEX(', EC',[Message]+', EC')-(CHARINDEX('object ID',[Message])+9))
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like 'Time out occurred while waiting for buffer latch%'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' TimeOut-Latch'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: User-InvalidSID
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'User-InvalidSID'
			,[FixData] = REPLACE(REPLACE(REPLACE('Server=%Server%,Database=%Database%,User=%User%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%Database%'
					,SUBSTRING([Message],CHARINDEX('found in database',[Message])+19,CHARINDEX('on server',[Message]+'''.')-(CHARINDEX('found in database',[Message])+21))
					),'%User%'
					,SUBSTRING([Message],CHARINDEX('SID for',[Message])+8,CHARINDEX('found in database',[Message])-(CHARINDEX('SID for',[Message])+9))
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like '%Invalid SID for%found in database%on server%'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' User-InvalidSID'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: SQLServer-CLRNotEnabled
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'SQLServer-CLRNotEnabled'
			,[FixData] = NULL
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like '%''CLR Enabled'' setting in sp_configure is not enabled%'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' SQLServer-CLRNotEnabled'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: SQLServer-MissingStandardShare
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'SQLServer-MissingStandardShare'
			,[FixData] = REPLACE(REPLACE('Server=%Server%,Share=%Share%'
					,'%Server%'
					,[Machine] + CASE WHEN [Instance] > '' THEN '\'+[Instance] ELSE ''END
					),'%Share%'
					,REPLACE(RIGHT([Message],LEN([Message])-CHARINDEX('\\',[Message])+1),'.','')
					)
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like '%DBA WARNING: Standard share could not be found%'
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' SQLServer-MissingStandardShare'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: SysMessagesError-######
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
		SET	[KnownCondition] = 'SysMessagesError-' + SUBSTRING([Message],CHARINDEX('Error:',[Message])+6,CHARINDEX('Severity:',[Message])-(CHARINDEX('Error:',[Message])+8))
			,[Message]	= LEFT(Message + COALESCE(' ' 
					+ (
					Select Description 
					FROM sys.sysmessages 
					where msglangid = 1033 
					AND error = CAST(SUBSTRING([dbaadmin].[dbo].[FilescanImport_CurrentWorkTable].[Message],CHARINDEX('Error:',[Message])+6,CHARINDEX('Severity:',[dbaadmin].[dbo].[FilescanImport_CurrentWorkTable].[Message])-(CHARINDEX('Error:',[dbaadmin].[dbo].[FilescanImport_CurrentWorkTable].[Message])+8)) AS INT)     
					),''),255)
			,[FixData] = NULL
			,[FixQuery] = NULL -- ''
	WHERE	KnownCondition = 'Unknown'
	-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	  AND	[Message] Like 'error%'
	  AND	LEN([message]) < 50
	  AND	SUBSTRING([Message],CHARINDEX('Error:',[Message])+6,CHARINDEX('Severity:',[Message])-(CHARINDEX('Error:',[Message])+8)) IN
		(
		Select error 
		FROM sys.sysmessages 
		WHERE Description IS NOT NULL
		)
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--                            UPDATE SESSION RESULTS		          --
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SET	@StatusMsg = 'Identified ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' SysMessagesError-######'
	exec	##UpdateAggSessionResults @SessionID, @StatusMsg
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- CONDITION END
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- DONE MARKING KNOWN CONDITIONS
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                            UPDATE SESSION RESULTS		          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET	@StatusMsg = 'Done Marking Known Conditions'
exec	##UpdateAggSessionResults @SessionID, @StatusMsg
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- POPULATE HISTORY TABLE FROM WORK TABLE
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
	INSERT INTO [dbaadmin].[dbo].[FileScan_History]
		   ([WorkfileID]
		   ,[EventDateTime]
		   ,[Machine]
		   ,[Instance]
		   ,[SourceType]
		   ,[SourceFileIndex]
		   ,[Message]
		   ,[KnownCondition]
		   ,[FixData]
		   ,[FixQuery]
		   ,[SessionID])
	SELECT [ID]
	      ,[EventDateTime]
	      ,[Machine]
	      ,[Instance]
	      ,[SourceType]
	      ,[SourceFileIndex]
	      ,[Message]
	      ,[KnownCondition]
	      ,[FixData]
	      ,[FixQuery]
	      ,@SessionID
	  FROM [dbaadmin].[dbo].[FilescanImport_CurrentWorkTable]
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                            UPDATE SESSION RESULTS		          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET	@StatusMsg = 'Pushed ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' Records to History Table' + CHAR(13) + CHAR(10)
exec	##UpdateAggSessionResults @SessionID, @StatusMsg
----------------------------------------------------------------------------
----------------------------------------------------------------------------  	

----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                     SUMMARY SESSION ERRORS BY SERVER		          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET @StatusMsg	= '--------------------------------------------------------' + CHAR(13) + CHAR(10)
		+ '               Session Errors By Server' + CHAR(13) + CHAR(10) 
		+ '--------------------------------------------------------' + CHAR(13) + CHAR(10)
		+ ' SERVER                                         ERRORS' + CHAR(13) + CHAR(10)
		+ '--------------------------------------------------------' + CHAR(13) + CHAR(10)

SELECT		@StatusMsg = @StatusMsg
		+ ' ' + Machine + CASE WHEN Instance = '' THEN '' ELSE '\' + Instance END 
		+ SPACE(50-LEN(' ' + Machine + CASE WHEN Instance = '' THEN '' ELSE '\' + Instance END)) 
		+ CAST(count(*) As VarChar(50))
		+ CHAR(13) + CHAR(10)
FROM		[dbaadmin].[dbo].[FilescanImport_CurrentWorkTable]
GROUP BY	Machine
		,Instance
ORDER BY	COUNT(*)  desc

exec	##UpdateAggSessionResults @SessionID, @StatusMsg
----------------------------------------------------------------------------
---------------------------------------------------------------------------- 
--                  SUMMARY SESSION ERRORS BY CONDITION		          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET @StatusMsg	= '--------------------------------------------------------' + CHAR(13) + CHAR(10)
		+ '               Session Errors By Condition' + CHAR(13) + CHAR(10) 
		+ '--------------------------------------------------------' + CHAR(13) + CHAR(10)
		+ ' CONDITION                                      ERRORS' + CHAR(13) + CHAR(10)
		+ '--------------------------------------------------------' + CHAR(13) + CHAR(10)

SELECT		@StatusMsg = @StatusMsg
		+ ' ' + KnownCondition 
		+ SPACE(50-LEN(' ' + KnownCondition))
		+ CAST(count(*) As VarChar(50))
		+ CHAR(13) + CHAR(10)
FROM		[dbaadmin].[dbo].[FilescanImport_CurrentWorkTable]
GROUP BY	KnownCondition
ORDER BY	COUNT(*)  desc

exec	##UpdateAggSessionResults @SessionID, @StatusMsg
----------------------------------------------------------------------------
---------------------------------------------------------------------------- 
--                     SUMMARY SESSION ERRORS BY SERVER		          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET @StatusMsg	= '---------------------------------------------------------' + CHAR(13) + CHAR(10)
		+ '          SERVERS NOT REPORTING IN LAST 15 MIN' + CHAR(13) + CHAR(10)
		+ '---------------------------------------------------------' + CHAR(13) + CHAR(10)
		+ ' SOURCE		     SERVER		       MIN. SINCE' + CHAR(13) + CHAR(10)
		+ '                                                REPORTED' + CHAR(13) + CHAR(10)
		+ '---------------------------------------------------------' + CHAR(13) + CHAR(10)

SELECT		@StatusMsg = @StatusMsg
		+ [SourceType] + SPACE(20-LEN([SourceType]))
		+ Machine + CASE WHEN Instance = '' THEN '' ELSE '\' + Instance END 
		+ SPACE(30-LEN(Machine + CASE WHEN Instance = '' THEN '' ELSE '\' + Instance END)) 
		+ CAST(DATEDIFF(Minute,[LastReported],getdate()) As VarChar(50))
		+ CHAR(13) + CHAR(10)
FROM		[dbaadmin].[dbo].[Filescan_MachineSource]
WHERE		DATEDIFF(Minute,[LastReported],getdate()) > 15
ORDER BY	[SourceType],DATEDIFF(Minute,[LastReported],getdate()) DESC

exec	##UpdateAggSessionResults @SessionID, @StatusMsg
----------------------------------------------------------------------------
---------------------------------------------------------------------------- 
NoDataImported:

PRINT 'Done.'
GO
DROP PROCEDURE	##UpdateAggSessionResults
GO


