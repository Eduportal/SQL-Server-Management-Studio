SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
GO
USE [dbacentral]
GO
CREATE PROCEDURE dbo.dbasp_FileScan_ImportServerEventLogs
AS
SET NOCOUNT ON
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
							 
exec	dbacentral.dbo.dbasp_FileScan_UpdateAggSessionResults @SessionID, @StatusMsg
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- DROP IMPORT TABLE IF EXISTS
----------------------------------------------------------------------------
----------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FilescanImport_CurrentWorkTable_ServerEvent]') AND type in (N'U'))
	DROP TABLE [dbo].[FilescanImport_CurrentWorkTable_ServerEvent]
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- MOVE ACTIVE FILES TO WORK DIRECTORY
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET	@TSQL	= 'Move \\SQLDEPLOYER04\SQLDEPLOYER04_filescan\Aggregates\ServerEvent*.w3c \\SQLDEPLOYER04\SQLDEPLOYER04_filescan\Aggregates\WORK'
exec master..xp_cmdshell @TSQL, no_output

SET	@TSQL	= 'Move \\SQLDEPLOYER05\SQLDEPLOYER05_filescan\Aggregates\ServerEvent*.w3c \\SQLDEPLOYER05\SQLDEPLOYER05_filescan\Aggregates\WORK'
exec master..xp_cmdshell @TSQL, no_output

SET	@TSQL	= 'Move \\SEAFRESQLDBA01\SEAFRESQLDBA01_filescan\Aggregates\ServerEvent*.w3c \\SEAFRESQLDBA01\SEAFRESQLDBA01_filescan\Aggregates\WORK'
exec master..xp_cmdshell @TSQL, no_output
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                          UPDATE SESSION RESULTS		          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET	@StatusMsg = 'Moved New Files to WORK Directory'					 
exec	dbacentral.dbo.dbasp_FileScan_UpdateAggSessionResults @SessionID, @StatusMsg
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- IMPORT FILES FROM WORK DIRECTORY
----------------------------------------------------------------------------
----------------------------------------------------------------------------
CREATE TABLE	#LogParserResults (ln nvarchar(4000))

SET	@TSQL	= 'LogParser file:\\'+ @central_server + '\'+ @central_server 
		+ '_filescan\Aggregates\Queries\AggQueries\ServerEvent_CreateAggTable.sql -i:W3C -o:SQL -server:'
		+ @central_server 
		+ ' -database:dbacentral -driver:"SQL Server" -createTable:ON -clearTable:ON -iw:ON -dQuotes:ON'
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
					 
exec	dbacentral.dbo.dbasp_FileScan_UpdateAggSessionResults @SessionID, @StatusMsg
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
--   GET FILE LISTINGS IN WORK DIRECTORIES
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--  One Entry for each Central Server
----------------------------------------------------------------------------
----------------------------------------------------------------------------
Create table #DirectoryListing (ln nvarchar(4000))
set @TSQL = 'DIR \\SQLDEPLOYER04\SQLDEPLOYER04_filescan\Aggregates\WORK\ServerEvent_*.w3c /b'
Insert #DirectoryListing exec master..xp_cmdshell @TSQL

set @TSQL = 'DIR \\SQLDEPLOYER05\SQLDEPLOYER05_filescan\Aggregates\WORK\ServerEvent_*.w3c /b'
Insert #DirectoryListing exec master..xp_cmdshell @TSQL

set @TSQL = 'DIR \\SEAFRESQLDBA01\SEAFRESQLDBA01_filescan\Aggregates\WORK\ServerEvent_*.w3c /b'
Insert #DirectoryListing exec master..xp_cmdshell @TSQL

delete from #DirectoryListing
where	ln is NULL
 or	ln like 'File Not Found'

UPDATE	#DirectoryListing
SET	ln = REPLACE(REPLACE(REPLACE(ln,'ServerEvent_',''),'.w3c',''),'$','|') --leaving only the server name
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                         UPDATE SESSION RESULTS		          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET	@StatusMsg = 'Populated List of Reporting Servers'					 
exec	dbacentral.dbo.dbasp_FileScan_UpdateAggSessionResults @SessionID, @StatusMsg
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                          ADD ANY NEW ENTRIES 
--         DUPLICATES FALL TO THE FLOOOR BECAUSE OF INDEX IGNORE DUPES
----------------------------------------------------------------------------
----------------------------------------------------------------------------
INSERT INTO	[dbacentral].[dbo].[Filescan_MachineSource]
		([Machine]
		,[Instance]
		,[SourceType]
		,[LastReported]
		,[SessionAdded])
SELECT		[dbacentral].[dbo].[ReturnPart] ([ln],1) [Machine]
		,COALESCE([dbacentral].[dbo].[ReturnPart] ([ln],2),'')[Instance]
		,'ServerEvent' [SourceType]
		,GetDate() [EventDateTime]
		,@SessionID
FROM		#DirectoryListing
GROUP BY	[dbacentral].[dbo].[ReturnPart] ([ln],1) 
		,COALESCE([dbacentral].[dbo].[ReturnPart] ([ln],2),'')
ORDER BY	[dbacentral].[dbo].[ReturnPart] ([ln],1) 
		,COALESCE([dbacentral].[dbo].[ReturnPart] ([ln],2),'') 
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                          UPDATE SESSION RESULTS		          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET	@StatusMsg = 'Added ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' New Reporting Servers'
exec	dbacentral.dbo.dbasp_FileScan_UpdateAggSessionResults @SessionID, @StatusMsg
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                          UPDATE CHANGED ENTRIES 
----------------------------------------------------------------------------
----------------------------------------------------------------------------
UPDATE		[dbacentral].[dbo].[Filescan_MachineSource]
	SET	[LastReported] = T2.[EventDateTime]
		,[SessionUpdated] = @SessionID
FROM		[dbacentral].[dbo].[Filescan_MachineSource] T1		
INNER JOIN	(
		SELECT		[dbacentral].[dbo].[ReturnPart] ([ln],1) [Machine]
				,COALESCE([dbacentral].[dbo].[ReturnPart] ([ln],2),'')[Instance]
				,'ServerEvent'	[SourceType]
				,GetDate()   [EventDateTime]
		FROM		#DirectoryListing
		GROUP BY	[dbacentral].[dbo].[ReturnPart] ([ln],1) 
				,COALESCE([dbacentral].[dbo].[ReturnPart] ([ln],2),'')
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
exec	dbacentral.dbo.dbasp_FileScan_UpdateAggSessionResults @SessionID, @StatusMsg
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                            POPULATE DOMAIN			          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
UPDATE		dbo.Filescan_MachineSource
	SET	Domain = T2.DOMAINName
FROM		dbo.Filescan_MachineSource   T1
JOIN		dbo.DBA_ServerInfo T2
	ON	t1.machine = T2.servername
WHERE		T1.Domain IS NULL
----------------------------------------------------------------------------
----------------------------------------------------------------------------
DROP table #DirectoryListing
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- MOVE WORK FILES TO ARCHIVE DIRECTORY
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET	@TSQL	= 'Move \\SQLDEPLOYER04\SQLDEPLOYER04_filescan\Aggregates\WORK\ServerEvent*.w3c \\SQLDEPLOYER04\SQLDEPLOYER04_filescan\Aggregates\WORK\Archive'
exec master..xp_cmdshell @TSQL, no_output

SET	@TSQL	= 'Move \\SQLDEPLOYER05\SQLDEPLOYER05_filescan\Aggregates\WORK\ServerEvent*.w3c \\SQLDEPLOYER05\SQLDEPLOYER05_filescan\Aggregates\WORK\Archive'
exec master..xp_cmdshell @TSQL, no_output

SET	@TSQL	= 'Move \\SEAFRESQLDBA01\SEAFRESQLDBA01_filescan\Aggregates\WORK\ServerEvent*.w3c \\SEAFRESQLDBA01\SEAFRESQLDBA01_filescan\Aggregates\WORK\Archive'
exec master..xp_cmdshell @TSQL, no_output
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                            UPDATE SESSION RESULTS		          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET	@StatusMsg = 'Moved New Files to ARCHIVE Directory'
exec	dbacentral.dbo.dbasp_FileScan_UpdateAggSessionResults @SessionID, @StatusMsg
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- CHECK FOR IMPORTS
----------------------------------------------------------------------------
----------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FilescanImport_CurrentWorkTable_ServerEvent]') AND type in (N'U'))
	BEGIN
		----------------------------------------------------------------------------
		--                            UPDATE SESSION RESULTS		          --
		----------------------------------------------------------------------------
		----------------------------------------------------------------------------
		SET	@StatusMsg = 'No Data Imported No need to Continue'
		exec	dbacentral.dbo.dbasp_FileScan_UpdateAggSessionResults @SessionID, @StatusMsg
		----------------------------------------------------------------------------
		----------------------------------------------------------------------------
		GOTO NoDataImported
	END
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- ALTER TABLE AND CLEANUP DATA ISSUES
----------------------------------------------------------------------------
----------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM syscolumns WHERE ID = OBJECT_ID('FilescanImport_CurrentWorkTable_ServerEvent') AND name = 'ID')
BEGIN
ALTER TABLE dbo.FilescanImport_CurrentWorkTable_ServerEvent ADD 
	KnownCondition varchar(50) NOT NULL CONSTRAINT DF_FilescanImport_CurrentWorkTable_ServerEvent__KnownCondition DEFAULT 'Unknown'
	, ID bigint NOT NULL IDENTITY (1, 1)

ALTER TABLE dbo.FilescanImport_CurrentWorkTable_ServerEvent ADD CONSTRAINT
	PK_FilescanImport_CurrentWorkTable_ServerEvent PRIMARY KEY CLUSTERED 
	(
	ID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END

----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                         DECODE TEXT FIELDS			          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
UPDATE		[dbacentral].[dbo].[FilescanImport_CurrentWorkTable_ServerEvent]
	SET	[EventTypeName]		= REPLACE([EventTypeName],'+',' ')
		,[EventCategoryName]	= REPLACE([EventCategoryName],'+',' ')
		,[SourceName]		= REPLACE([SourceName],'+',' ')
		,[Strings]		= REPLACE([Strings],'+',' ')
		,[Message]		= REPLACE([Message],'+',' ')
		,[Data]			= REPLACE([Data],'+',' ')


UPDATE dbo.FilescanImport_CurrentWorkTable_ServerEvent
 SET [ComputerName] = REPLACE(REPLACE([ComputerName],'.test.gettyimages.net',''),'.amer.gettywan.com','')
----------------------------------------------------------------------------
--                            UPDATE SESSION RESULTS		          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET	@StatusMsg = 'Finished Modifing and Cleaning Work Table'
exec	dbacentral.dbo.dbasp_FileScan_UpdateAggSessionResults @SessionID, @StatusMsg
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- START MARKING KNOWN CONDITIONS
----------------------------------------------------------------------------
----------------------------------------------------------------------------
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	---- KNOWN CONDITION: Generic FixData For ServerEvent Data
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	--UPDATE	[dbo].[FilescanImport_CurrentWorkTable_ServerEvent]
	--	SET	[FixData] = REPLACE(REPLACE('MessageType=%MessageType%,MessageID=%MessageID%'
	--				,'%MessageType%'
	--				,[MessageType]
	--				),'%MessageID%'
	--				,[MessageID]
	--				)
	--		,[FixQuery] = NULL -- ''
	--WHERE	KnownCondition = 'Unknown'
	---- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	----                            UPDATE SESSION RESULTS		          --
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	--SET	@StatusMsg = 'Populated ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' Generic FixData For ServerEvent Data'
	--exec	dbacentral.dbo.dbasp_FileScan_UpdateAggSessionResults @SessionID, @StatusMsg
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	---- CONDITION END
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- DONE MARKING KNOWN CONDITIONS
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                            UPDATE SESSION RESULTS		          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET	@StatusMsg = 'Done Marking Known Conditions'
exec	dbacentral.dbo.dbasp_FileScan_UpdateAggSessionResults @SessionID, @StatusMsg
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- POPULATE HISTORY TABLE FROM WORK TABLE
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
INSERT INTO [dbacentral].[dbo].[FileScan_History]
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
SELECT		T1.[ID]
		,T1.[DateTimeGenerated]
		,T1.[ComputerName]
		,'' AS [Instance]
		,T1.[EventLog]
		,T1.[RecordNumber]
		,T1.[Message]
		,T2.[KnownCondition]
		,T1.[Strings]
		,'' AS [FixQuery]
		,@SessionID
FROM		[dbacentral].[dbo].[FilescanImport_CurrentWorkTable_ServerEvent]       T1
JOIN		[dbacentral].dbo.FileScan_EVTLOG_EventFilter			     T2
	ON	T1.[EventLog]		= T2.[EventLog]
	AND	T1.[EventID]		= T2.[EventID]
	AND	T1.[EventCategory]	= T2.[EventCategory]
	AND	T1.[SourceName]		= T2.[SourceName]

WHERE	T2.KnownCondition != 'Unknown'
 AND	T2.KnownCondition NOT LIKE 'Ignore%' 
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--                            UPDATE SESSION RESULTS		          --
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SET	@StatusMsg = 'Pushed ' + CAST(@@ROWCOUNT AS VarChar(50)) + ' Records to History Table' + CHAR(13) + CHAR(10)
exec	dbacentral.dbo.dbasp_FileScan_UpdateAggSessionResults @SessionID, @StatusMsg
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
		+ ' ' + [ComputerName] +  
		+ SPACE(50-LEN(' ' + [ComputerName] )) 
		+ CAST(count(*) As VarChar(50))
		+ CHAR(13) + CHAR(10)
FROM		[dbacentral].[dbo].[FilescanImport_CurrentWorkTable_ServerEvent]
GROUP BY	[ComputerName]

ORDER BY	COUNT(*)  desc

exec	dbacentral.dbo.dbasp_FileScan_UpdateAggSessionResults @SessionID, @StatusMsg
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
FROM		[dbacentral].[dbo].[FilescanImport_CurrentWorkTable_ServerEvent]
GROUP BY	KnownCondition
ORDER BY	COUNT(*)  desc

exec	dbacentral.dbo.dbasp_FileScan_UpdateAggSessionResults @SessionID, @StatusMsg
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
		+ [Machine] 
		+ SPACE(30-LEN([Machine] )) 
		+ CAST(DATEDIFF(Minute,[LastReported],getdate()) As VarChar(50))
		+ CHAR(13) + CHAR(10)
FROM		[dbacentral].[dbo].[Filescan_MachineSource]
WHERE		DATEDIFF(Minute,[LastReported],getdate()) > 15
ORDER BY	[SourceType],DATEDIFF(Minute,[LastReported],getdate()) DESC

exec	dbacentral.dbo.dbasp_FileScan_UpdateAggSessionResults @SessionID, @StatusMsg
------------------------------------------------------------------------
------------------------------------------------------------------------ 
NoDataImported:
PRINT 'Done.'
GO
