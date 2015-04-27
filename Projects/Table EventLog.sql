USE [dbaadmin]
GO

/****** Object:  Table [dbo].[EventLog]    Script Date: 10/28/2010 21:48:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EventLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[EventLog](
	[EventLogID] [bigint] IDENTITY(1,1) NOT NULL,
	[EventDate] [datetime] NULL,
	[cEModule] [sysname] NOT NULL,
	[cECategory] [sysname] NOT NULL,
	[cEEvent] [sysname] NOT NULL,
	[cEGUID] [uniqueidentifier] NULL,
	[cEMessage] [nvarchar](max) NULL,
	[cEStat_Rows] [bigint] NULL,
	[cEStat_Duration] [float] NULL,
 CONSTRAINT [PK__EventLog__1218F6B8] PRIMARY KEY CLUSTERED 
(
	[EventLogID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__EventLog__EventD__130D1AF1]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[EventLog] ADD  CONSTRAINT [DF__EventLog__EventD__130D1AF1]  DEFAULT (getutcdate()) FOR [EventDate]
END

GO











USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_LogEvent]    Script Date: 10/22/2010 10:48:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_LogEvent]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_LogEvent]
GO

CREATE procedure [dbo].[dbasp_LogEvent]
	(
	-- REQUIRED VALUES --
	
	 @cEModule		sysname			=null
	,@cECategory		sysname			=null
	,@cEEvent		sysname			=null
	,@cEGUID		uniqueidentifier	=null
	,@cEMessage		nvarchar(max)		=null
	
	-- OPTIONAL VALUES --
	,@cE_ThrottleType	VarChar(50)		=null
	,@cE_ThrottleNumber	INT			=null
	,@cE_ThrottleGrouping	VarChar(255)		=null
	
	,@cETable_FQName	VarChar(2048)		= 'dbaadmin.dbo.EventLog'
	
	,@cE_ForwardTo		VarChar(2048)		=null
	,@cE_RedirectTo		VarChar(2048)		=null
	
	,@cEStat_Rows		BigInt			=null
	,@cEStat_Duration	FLOAT			=null
	
	,@cEWinLog_LogName	sysname			= 'APPLICATION'
	,@cEWinLog_EventType	sysname			= 'INFORMATION'
	,@cEWinLog_EventID	INT			= 1
	
	,@cEMail_Subject	VarChar(2048)		=null
	,@cEMail_To		VarChar(2048)		=null
	,@cEMail_CC		VarChar(2048)		=null
	,@cEMail_BCC		VarChar(2048)		=null
	,@cEMail_Urgent		BIT			= 1
	
	,@cEFile_Name		VarChar(2048)		=null
	,@cEFile_Path		VarChar(2048)		=null
	,@cEFile_OverWrite	BIT			= 0
	
	-- METHODS TO USE TO LOG THE MESSAGE MUST USE ONE OR MORE--

	,@cEMethod_Screen	BIT			= 1
	,@cEMethod_TableLocal	BIT			= 1
	,@cEMethod_TableCentral	BIT			= 0
	,@cEMethod_WinLog	BIT			= 0
	,@cEMethod_EMail	BIT			= 0
	,@cEMethod_File		BIT			= 0
	,@cEMethod_Twitter	BIT			= 0
	,@DebugPrint		BIT			= 0
	)

/***************************************************************
 **  Stored Procedure dbasp_LogEvent                 
 **  Written by Steve Ledridge, Getty Images                
 **  MAY 8, 2010                                      
 **
 **  
 **  Description: Creates a common interface to perform all event logging and messaging across all 
 **  Opperations databases, code and proccesses.
 **
 **
 **  This proc accepts the following input parameters:
 **  
 	@cEModule		= GENERIC NAME OF SPROC, JOB, OR GENERAL TASK TO USE FOR GROUPING
	@cECategory		= THE CATEGORY KEYWORD 
	@cEEvent		= THE EVENT KEYWORD
	@cEGUID			= GUID USED TO LINK RELATED EVENTS AS A PROCCESS OR INSTANCE ex (one execution of a sproc)
	@cEMessage		= THE ACTUAL MESSAGE BEING LOGGED
	
	-- OPTIONAL VALUES --
	@cE_ThrottleType	= ex('FilterPerXMin','FilterPerXSec','DelayPerXMin','DelayPerXSec')
					"Filter%"	= Will drop extra messages.
					"Delay%"	= Will queue messages and deliver at interval. 
					"X"		= Value in @cE_ThrottleNumber Parameter
					
	@cE_ThrottleNumber	= Number used in ThrottleType Calculation.
	@cE_ThrottleGrouping	= Value Used to Identify Similar Message to be Throttled.

	@cETable_FQName		= The Fully Qualified Database.Schema.Table name of the Table used for TableLocal or TableRemote.
	
	@cE_ForwardTo		= A Comma Delimited String of Servers That will also execute this LogEvent (Event is also Logged Here)
	@cE_RedirectTo		= A Comma Delimited String of Servers That will execute this LogEvent instead of being Executed Here. (Event is not Logged Here)
	
	@cEStat_Rows		= PASS IN @@ROWCOUNT IF APPROPRIATE
	@cEStat_Duration	= USE FLOAT VALUE FOR MINUTES IF CALCULATED IN PROCCESS

	@cEWinLog_LogName	= WINDOWS EVENT LOG: EventLog LOG Name (APPLICATION,SYSTEM,SECURITY, or other custom log already existing) DEFAULT:APPLICATION
	@cEWinLog_EventType	= WINDOWS EVENT LOG: EventLog Entry Type (INFORMATION,ERROR,WARNING,SUCCESS) DEFAULT:INFORMATION
	@cEWinLog_EventID	= WINDOWS EVENT LOG: EventLog Event ID Number (1-1000) DEFAULT:1
	
	@cEMail_Subject		= Subject Line For Email
	@cEMail_To		= Delimited List of Recipients
	@cEMail_CC		= Delimited List of Recipients
	@cEMail_BCC		= Delimited List of Recipients
	@cEMail_Urgent		= 1 IF UGENT 0 IF NORMAL

	@cEFile_Name		= FileName to write
	@cEFile_Path		= Path to Write File
	@cEFile_OverWrite	= 1 TO OVERWRITE 0 TO APPEND

	-- METHODS TO USE TO LOG THE MESSAGE MUST USE ONE OR MORE--

	@cEMethod_Screen	= Prints Message to screen prefixed with "--" to make sure it doesnt interfere with scripting.
	@cEMethod_TableLocal	= Write to the Local [dbo].EventLog Table. (MUST BE USED TO GET THROTTLE TO WORK)
	@cEMethod_TableCentral	= Write to the Central dbacentral.dbo.EventLog Table
	@cEMethod_WinLog	= Write to Windows EventLog
	@cEMethod_EMail		= Sends Email
	@cEMethod_File		= Writes to a File
	@cEMethod_Twitter	= Send a Twitter Update
	
	EACH LOG_METHOD OTHER THAN SCREEN SHOULD BE WRITTEN AS A SEPERATE SPROC WHICH IS CALLED BY THIS ONE 
	AND THEY SHOULD ALL BE CALLED BEFORE THE SCREEN LOG_METHOD IS EXECUTED SO THAT IT CAN RETURN ANY INFO 
	GATHERED FROM THE OTHER LOG_METHOD's
	SO THAT THIS DOESNT GET TOO LARGE AND CONFUSING
 **
 ***************************************************************
 IDEAS:
	If logging to table, you could have it calculate duration on 'stop,end,finnish...' entries by looking at related 'start,begin..' entries

 ***************************************************************/
AS
BEGIN
	
	/*--------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------
	INITALIZE VARIABLES
	----------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------*/
	SET NOCOUNT ON
	DECLARE		@cLogDBName		[sys].[sysname]
			,@cLogSysuser		[sys].[sysname]
			,@cLogModuleVersion	nvarchar(32)
			,@cESpace		varchar(32)
			,@lRC			int
			,@PrintMessage		VarChar(8000)

	SET		@cLogDBName		=db_name()
	SET		@cLogSysuser		=system_user
	SET		@cLogModuleVersion	= '0.01'
	SET		@cESpace		='EVT_NDX'
	
	-- IF @cEGUID IS NULL THEN CREATE ONE AND THIS EVENT WILL NOT BE LINKED TO ANY OTHERS
	IF @cEGUID is null 
		set @cEGUID=newid()

	/*--------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------
	CHECK FOR FORWARD AND REDIRECT FLAGS
	----------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------*/

	if @cE_ForwardTo IS NOT NULL OR @cE_RedirectTo IS NOT NULL
	BEGIN
	----------------------------------------------------
	---------- CALL SPROC ON REMOTE TABLES
	----------------------------------------------------
		SET @cE_ForwardTo = @cE_ForwardTo
		--TODO:
		--	GENERATE CURSOR OF SERVERS TO SEND SPROC CALL TO.
		--	DELIVER COMMAND TO FIRE SPROC ON REMOTE SERVER.

	END
	
	if @cE_RedirectTo IS NOT NULL
	BEGIN
	----------------------------------------------------
	---------- EXIT NOW IF REDIRECT
	----------------------------------------------------
		RETURN 0
	END

	/*--------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------
	START CALLING LOG_METHOD's
	----------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------*/

----------------------------------------------------
---------- LOG_METHOD:	TABLE_LOCAL
----------------------------------------------------	

	IF @cEMethod_TableLocal = 1
	BEGIN
		EXEC [dbo].[dbasp_LogEvent_Method_TableLocal]
			@cEModule
			,@cECategory
			,@cEEvent
			,@cEGUID
			,@cEMessage
			,@cETable_FQName
			,@cEStat_Rows
			,@cEStat_Duration

	END
	
----------------------------------------------------
---------- LOG_METHOD:	TABLE_CENTRAL
----------------------------------------------------	

	IF @cEMethod_TableCentral = 1
	BEGIN
		EXEC [dbo].[dbasp_LogEvent_Method_TableCentral]
			@cEModule
			,@cECategory
			,@cEEvent
			,@cEGUID
			,@cEMessage
			,@cETable_FQName
			,@cEStat_Rows
			,@cEStat_Duration

	END

----------------------------------------------------
---------- LOG_METHOD:	WINDOWS EVENT LOG
----------------------------------------------------	

	IF @cEMethod_WinLog = 1
	BEGIN

		EXEC [dbo].[dbasp_LogEvent_Method_WindowsEvent]
			@cEModule
			,@cECategory
			,@cEEvent
			,@cEGUID
			,@cEMessage
			,@cEWinLog_LogName
			,@cEWinLog_EventType
			,@cEWinLog_EventID
			,@cEStat_Rows
			,@cEStat_Duration

	END
	
----------------------------------------------------
---------- LOG_METHOD:	EMAIL
----------------------------------------------------	

	IF @cEMethod_Email = 1
	BEGIN
		EXEC [dbo].[dbasp_LogEvent_Method_EMail]
			@cEModule
			,@cECategory
			,@cEEvent
			,@cEGUID
			,@cEMessage
			,@cEMail_Subject
			,@cEMail_To
			,@cEMail_CC
			,@cEMail_BCC
			,@cEMail_Urgent
			,@cEStat_Rows
			,@cEStat_Duration

	END

----------------------------------------------------
---------- LOG_METHOD:	FILE
----------------------------------------------------	

	IF @cEMethod_File = 1
	BEGIN
		EXEC [dbo].[dbasp_LogEvent_Method_File]
			@cEModule
			,@cECategory
			,@cEEvent
			,@cEGUID
			,@cEMessage
			,@cEFile_Name
			,@cEFile_Path
			,@cEFile_OverWrite
			,@cEStat_Rows
			,@cEStat_Duration
	END
	
----------------------------------------------------
---------- LOG_METHOD:	TWITTER
----------------------------------------------------	

	IF @cEMethod_Twitter = 1
	BEGIN
		EXEC [dbo].[dbasp_LogEvent_Method_Twitter]
			@cEModule
			,@cECategory
			,@cEEvent
			,@cEGUID
			,@cEMessage
			,@cEStat_Rows
			,@cEStat_Duration
			
	END
	
----------------------------------------------------
---------- LOG_METHOD:	SCREEN
----------------------------------------------------	

	if @cEMethod_Screen = 1
	BEGIN
		SET	@PrintMessage
			= '-- Module=' + @cEModule
			+ N'  Date=' + CONVERT(nvarchar(50),GETUTCDATE(),120)
			+ N'  Category=' +coalesce(@cECategory,N'(undefined)')
			+ N'  Event=' +coalesce(@cEEvent,N'(undefined)')
			+ COALESCE(N'  Message=' + REPLACE(REPLACE(REPLACE(@cEMessage,CHAR(13),' '),CHAR(10),' '),'  ',' '), N'')
			
		IF @DebugPrint = 1			
		SET	@PrintMessage
			=  @PrintMessage + COALESCE(CHAR(13)+CHAR(10)+N' -- RowCount = ' + cast(@cEStat_Rows as nvarchar), N'')
			+ COALESCE(CHAR(13)+CHAR(10)+N' -- Duration = ' + cast(@cEStat_Duration as nvarchar), N'')
			+ CASE @cEMethod_TableLocal	WHEN 1 THEN CHAR(13)+CHAR(10)+N'  -- TableLocal   = ' + @cETable_FQName ELSE '' END
			+ CASE @cEMethod_TableCentral	WHEN 1 THEN CHAR(13)+CHAR(10)+N'  -- TableCentral = ' + @cETable_FQName ELSE '' END
			+ CASE @cEMethod_WinLog		WHEN 1 THEN CHAR(13)+CHAR(10)+N'  -- WinLog       = ' + @cEWinLog_LogName+'|'+@cEWinLog_EventType+'|'+CAST(@cEWinLog_EventID AS VarChar(4)) ELSE '' END
			+ CASE @cEMethod_EMail		WHEN 1 THEN CHAR(13)+CHAR(10)+N'  -- Email        = ' + @cEMail_To+'|'+@cEMail_CC+'|'+@cEMail_BCC+'|'+CAST(@cEMail_Urgent AS CHAR(1)) ELSE '' END
			+ CASE @cEMethod_File		WHEN 1 THEN CHAR(13)+CHAR(10)+N'  -- File         = ' + @cEFile_Path+'\'+@cEFile_Name+'|'+CAST(@cEFile_OverWrite AS CHAR(1)) ELSE '' END
			+ CASE @cEMethod_Twitter	WHEN 1 THEN CHAR(13)+CHAR(10)+N'  -- Twitter      = TWEETED' ELSE '' END

		if LEN(@PrintMessage) > 2047	-- IF LENGTH TO BIG FOR RAISERROR PRINT FIRST WITH BLANK RAISERROR
						-- BLANK LINES ARE PREVENTED BY NOT USING PRINT IF POSIBLE
		BEGIN
			PRINT	@PrintMessage
			SET	@PrintMessage = ''
		END
		RAISERROR (@PrintMessage,-1,-1) WITH NOWAIT

	END
	
	/*--------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------
	DONE
	----------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------*/
	return 0
end

/*
USAGE:

--------------------------------------------------
--     \/         HEADDER CODE          \/      --
--------------------------------------------------

	DECLARE @StartDate		datetime	-- used in example to calculate durration
		,@StopDate		datetime	-- multiple sets might be needed if nested
							-- durations are used.
							
	--------------------------------------------------
	-- DECLARE ALL cE VARIABLES AT HEAD OF PROCCESS --
	--------------------------------------------------
	DECLARE	@cEModule		sysname
		,@cECategory		sysname
		,@cEEvent		sysname
		,@cEGUID		uniqueidentifier
		,@cEMessage		nvarchar(max)

		-- ONLY NEEDED IF USED
		----------------------------------------------
		,@cEStat_Rows		BigInt
		,@cEStat_Duration	FLOAT
		,@cE_ForwardTo		VarChar(2048)
		,@cE_RedirectTo		VarChar(2048)
		,@cE_ThrottleType	VarChar(50)
		,@cE_ThrottleNumber	INT
		,@cE_ThrottleGrouping	VarChar(255)
		,@cETable_FQName	VarChar(2048)	-- ONLY NEEDED IF NOT 'dbaadmin.dbo.EventLog'
		,@cEWinLog_LogName	sysname		-- ONLY NEEDED IF NOT 'APPLICATION'
		,@cEWinLog_EventType	sysname		-- ONLY NEEDED IF NOT 'INFORMATION'
		,@cEWinLog_EventID	INT
		,@cEMail_Subject	VarChar(2048)
		,@cEMail_To		VarChar(2048)
		,@cEMail_CC		VarChar(2048)
		,@cEMail_BCC		VarChar(2048)
		,@cEMail_Urgent		BIT		-- ONLY NEEDED IF URGENT (1)
		,@cEFile_Name		VarChar(2048)
		,@cEFile_Path		VarChar(2048)
		,@cEFile_OverWrite	BIT		-- ONLY NEEDED IF OverWrite (1) otherwise it Appends

		,@cEMethod_Screen	BIT -- ONLY NEEDED IF NOT USED	(0)
		,@cEMethod_TableLocal	BIT -- ONLY NEEDED IF NOT USED	(0)
		,@cEMethod_TableCentral	BIT -- ONLY NEEDED IF USED	(1)
		,@cEMethod_WinLog	BIT -- ONLY NEEDED IF USED	(1)
		,@cEMethod_EMail	BIT -- ONLY NEEDED IF USED	(1)
		,@cEMethod_File		BIT -- ONLY NEEDED IF USED	(1)
		,@cEMethod_Twitter	BIT -- ONLY NEEDED IF USED	(1)
	--------------------------------------------------
	--           SET GLOBAL cE VARIABLES            --
	--------------------------------------------------
	SELECT	@cEModule		= 'TestLogingProccess'	-- SHOULD BE SET ONCE AT BEGINNING OF PROCCESS
		,@cEGUID		= NEWID()		-- SHOULD BE SET ONCE AT BEGINNING OF PROCCESS
		----------------------------------------------------------------------------
		-- ALL EVENTS SHOULD GO TO SAME LOG AND/OR TABLE UNLESS SPECIFIC NEED EXISTS
		----------------------------------------------------------------------------
		--,@cEWinLog_LogName	= 'SYSTEM'		-- ONLY NEEDED IF USED AND NOT 'APPLICATION'
		,@cEMethod_WinLog	= 1			-- ONLY USE HERE IF ALL EVENTS ARE LOGED TO WINDOWS
		--,@cETable_FQName	= 'CustomTableName	-- ONLY NEEDED IF USED AND NOT 'dbaadmin.dbo.EventLog'


--------------------------------------------------
--     /\      END HEADDER CODE         /\      --
--------------------------------------------------




--------------------------------------------------
--     \/         PER EVENT CODE        \/      --
--------------------------------------------------

	--------------------------------------------------
	--            SET EVENT cE VARIABLES            --
	--------------------------------------------------
	SELECT	@cECategory		= 'AUDIT STEP'
		,@cEEvent		= 'Calculate Sales'
		,@cEMessage		= 'Calculate Last Month Sales by reconsiling Sales with returns and discounts'
		,@cEWinLog_EventType	= 'INFORMATION'
		,@cEWinLog_EventID	= 10 -- SPECIFIC EVENT CODE FOR "AUDIT STEP START"
	--------------------------------------------------
	--            CALL LOG EVENT SPROC              --
	--------------------------------------------------
	exec [dbo].[dbasp_LogEvent]
		@cEModule               = @cEModule         
		,@cECategory            = @cECategory       
		,@cEEvent               = @cEEvent          
		,@cEGUID                = @cEGUID           
		,@cEMessage             = @cEMessage
		,@cEWinLog_LogName	= @cEWinLog_LogName 
		,@cEWinLog_EventType	= @cEWinLog_EventTyp
		,@cEWinLog_EventID	= @cEWinLog_EventID 
		,@cEMethod_WinLog	= @cEMethod_WinLog  

	--------------------------------------------------
	--                    DONE                      --
	--------------------------------------------------
	SET	@StartDate = GetDate()
	
	
	----------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------
	-- DO SOME STUFF
	----------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------
		--------------------------------------------------
		--      	    DO THE STEP	                --
		--------------------------------------------------
		SELECT @@SERVERNAME

		--------------------------------------------------
		--	    CALCULATE RESULTS OF STEP       	--
		--------------------------------------------------
		-- EXAMPLE ASSUMES @@ERROR RESULTS OF 0=SUCCESS, 1=WARNING, >1=ERROR


		SELECT		@cEStat_Rows		= @@ROWCOUNT	-- MUST BE DONE RIGHT AFTER SELECT/INSERT/UPDATE/DELETE
		
		IF @@ERROR = 0 
		BEGIN
			-- EVENT SUCCEDED
			SELECT	@cEWinLog_EventType	= 'SUCCESS'
				,@cEWinLog_EventID	= 12 -- SPECIFIC EVENT CODE FOR "AUDIT STEP SUCCESS"
				,@cEMessage		= 'Last Months Sales Are Complete'
		END
		ELSE
		BEGIN
			IF @@ERROR = 1
			BEGIN
				-- EVENT WARNING
				SELECT	@cEWinLog_EventType	= 'WARNING'
					,@cEWinLog_EventID	= 13 -- SPECIFIC EVENT CODE FOR "AUDIT STEP WARNING"
					,@cEMessage		= 'Last Month Sales were calculated but some transaction are missing. Totals will change.'
			END
			ELSE
			BEGIN
				-- EVENT FAILURE
				SELECT	@cEWinLog_EventType	= 'ERROR'
					,@cEWinLog_EventID	= 14 -- SPECIFIC EVENT CODE FOR "AUDIT STEP FAILURE"
					,@cEMessage		= 'Last Month Sales were not able to be calculated.'
			END
		END
	
		SET	@StopDate		= GetDate()
		SET	@cEStat_Duration	= DATEDIFF(ss,@StartDate,@StopDate) / 60.0000 -- GRANULARITY IN SECONDS
		--				= DATEDIFF(ms,@StartDate,@StopDate) / 1000.0000 / 60.0000 -- GRANULARITY IN MILISECONDS	
	
	
	----------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------
	-- DONE DOING SOME STUFF
	----------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------
	
	--------------------------------------------------
	--            CALL LOG EVENT SPROC              --
	--------------------------------------------------
	exec [dbo].[dbasp_LogEvent]
		@cEModule               = @cEModule         
		,@cECategory            = @cECategory       
		,@cEEvent               = @cEEvent          
		,@cEGUID                = @cEGUID           
		,@cEMessage             = @cEMessage
		        
		-- OPTIONAL VALUES ONLY USE IF USED AND/OR NONDEFAULT                                           
		,@cEStat_Rows			= @cEStat_Rows
		,@cEStat_Duration		= @cEStat_Duration
		,@cEWinLog_LogName		= @cEWinLog_LogName 
		,@cEWinLog_EventType		= @cEWinLog_EventTyp
		,@cEWinLog_EventID		= @cEWinLog_EventID 
		,@cEMethod_WinLog		= @cEMethod_WinLog  

	--------------------------------------------------
	--                    DONE                      --
	--------------------------------------------------

--------------------------------------------------
--   /\         END PER EVENT CODE      /\      --
--------------------------------------------------

	
--*/


GO

USE [dbaadmin]
GO

USE DBAADMIN
GO
IF OBJECT_ID('dbasp_LogEvent_Method_WindowsEvent') IS NOT NULL
	DROP PROCEDURE [dbo].[dbasp_LogEvent_Method_WindowsEvent]
GO	
CREATE PROCEDURE [dbo].[dbasp_LogEvent_Method_WindowsEvent]
	(
	@cEModule		sysname			=null
	,@cECategory		sysname			=null
	,@cEEvent		sysname			=null
	,@cEGUID		uniqueidentifier	=null
	,@cEMessage		varchar(8000)		=null
	,@cEWinLog_LogName	sysname			= 'APPLICATION'
	,@cEWinLog_EventType	sysname			= 'INFORMATION'
	,@cEWinLog_EventID	INT			= 1
	,@cEStat_Rows		BigInt			=null
	,@cEStat_Duration	FLOAT			=null	
	)
AS
BEGIN
	DECLARE @CMD nVarChar(4000)
	DECLARE @CRLF nVarChar(11)
	SET	@CRLF = '], [' --''
	
	SET	@cEMessage
		= @cECategory + ' (' + @cEEvent + ')'
		--+ @cEModule + @CRLF
		+ @CRLF + REPLACE(@cEMessage,CHAR(13)+CHAR(10),@CRLF)
		+ @CRLF + CAST(@cEGUID AS VarChar(50)) 
		+ COALESCE(@CRLF+N' -- RowCount = ' + cast(@cEStat_Rows as nvarchar(50)), N'')
		+ COALESCE(@CRLF+N' -- Duration = ' + cast(@cEStat_Duration as nvarchar(50)), N'')
		--+'Source Link: https://mixer.gettyimages.com/troubleshooting-guides/index.cgi?' + @cEModule+@CRLF
		--+'Event Link : https://mixer.gettyimages.com/opsmssql/index.cgi?' + CAST(@cEWinLog_EventID AS VarChar(4))+@CRLF
				
	SET	@CMD		= 'eventcreate2'
				+ ' /SO "' + @cEModule + '"'
				+ ' /ID ' + CAST(@cEWinLog_EventID AS VarChar(4))
				+ ' /L ' + @cEWinLog_LogName
				+ ' /T ' + @cEWinLog_EventType
				+ ' /D "[' + @cEMessage + ']"'
	--PRINT @CMD
	exec XP_CMDSHELL @CMD , no_output 
	
END
GO



GO
USE DBAADMIN
GO
IF OBJECT_ID('dbasp_LogEvent_CAT_VALIDATE') IS NOT NULL
	DROP PROCEDURE [dbo].[dbasp_LogEvent_CAT_VALIDATE]
GO	
CREATE PROCEDURE	[dbo].[dbasp_LogEvent_CAT_VALIDATE]
	(
	 @cEModule		sysname			
	,@cEGUID		uniqueidentifier	
	,@cEValidationType	sysname			
	,@cEEvent		sysname			
	,@cEMessage		nvarchar(max)		
	)
AS
BEGIN
	----------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------
	--
	--	dbasp_LogEvent_CAT_VALIDATE					10/26/2010
	--	
	--	This Sproc is a templated wrapper for the dbasp_LogEvent Sproc specificaly for the 
	--	VALIDATE category to simplify the calls in other code.
	--
	--	EXEC [DBAADMIN].[dbo].[dbasp_LogEvent_CAT_VALIDATE] 
	--		{MODULE},{GUID},{AUDIT_TYPE},{EVENT},{MESSAGE}
	--
	--	======================================================================================
	--	Revision History
	--	Date		Author     		Desc
	--	==========	====================	=============================================
	--	10/26/2010	Steve Ledridge		New process.
	--	
	--	
	--	======================================================================================
	--	PARAMETERS:
	--
	-- 	@cEModule		= GENERIC NAME OF SPROC, JOB, OR GENERAL TASK TO USE FOR GROUPING
	--	@cEGUID			= GUID USED TO LINK RELATED EVENTS AS A PROCCESS OR INSTANCE
	--	@cEValidationType	= THE AUDIT TYPE (OBJECT,SETTING,INPUT PARAMETER,...) 
	--	@cEEvent		= THE EVENT KEYWORD (-VALID,VALID,-INVALID,INVALID,+INVALID
	--				  ,-MISSING,MISSING,+MISSING,-PRE-EXISTING,PRE-EXISTING,+PRE-EXISTING,INFO)
	--	@cEMessage		= THE ACTUAL MESSAGE BEING LOGGED 
	
	----------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------
	DECLARE	@cEWinLog_EventID	INT
	DECLARE	@cEWinLog_EventType	SYSNAME
	DECLARE @cECategory		SYSNAME
	DECLARE @Modifier		CHAR(1)
	
	IF	LEFT(@cEEvent,1) IN ('+','-')
		SELECT	@Modifier = LEFT(@cEEvent,1)
			,@cEEvent = RIGHT(@cEEvent,LEN(@cEEvent)-1)
	
	SELECT	@cEWinLog_EventID =	CASE @cEEvent
						WHEN 'VALID'		THEN 10
						WHEN 'INVALID'		THEN 11
						WHEN 'MISSING'		THEN 12
						WHEN 'PRE-EXISTING'	THEN 13
						WHEN 'INFO'		THEN 14
						ELSE 0 END
						
		,@cEWinLog_EventType =	CASE COALESCE(@Modifier,'')+@cEEvent
						WHEN '-VALID'		THEN 'INFORMATION'
						WHEN 'VALID'		THEN 'SUCCESS'
						
						WHEN '-INVALID'		THEN 'INFORMATION'
						WHEN 'INVALID'		THEN 'WARNING'
						WHEN '+INVALID'		THEN 'ERROR'
						
						WHEN '-MISSING'		THEN 'INFORMATION'
						WHEN 'MISSING'		THEN 'WARNING'
						WHEN '+MISSING'		THEN 'ERROR'
						
						WHEN '-PRE-EXISTING'	THEN 'INFORMATION'
						WHEN 'PRE-EXISTING'	THEN 'WARNING'
						WHEN '+PRE-EXISTING'	THEN 'ERROR'
						
						ELSE 'INFORMATION' END
						
		,@cECategory =		'VALIDATE ' + @cEValidationType
		
	exec [dbo].[dbasp_LogEvent]
		@cEModule		= @cEModule
		,@cEGUID		= @cEGUID
		,@cEWinLog_LogName	= 'OPSMSSQL' 
		,@cEMethod_WinLog	= 1  
		,@cECategory            = @cECategory
		,@cEWinLog_EventType	= @cEWinLog_EventType
		,@cEEvent               = @cEEvent         
		,@cEWinLog_EventID	= @cEWinLog_EventID 
		,@cEMessage             = @cEMessage
END
/*
--------------------------------------------------------------------
--------------------------------------------------------------------
--	HEADDER PART
--------------------------------------------------------------------
--------------------------------------------------------------------

DECLARE		@cEModule		SYSNAME
		,@cEGUID		UNIQUEIDENTIFIER
		
SELECT		@cEModule		= COALESCE(OBJECT_NAME(@@Procid),'TestLogingProccess')
		,@cEGUID		= NEWID()
		
--------------------------------------------------------------------
--------------------------------------------------------------------
--	EVENT PART
--------------------------------------------------------------------
--------------------------------------------------------------------

EXEC [DBAADMIN].[dbo].[dbasp_LogEvent_CAT_VALIDATE] @cEModule,@cEGUID
	,'INPUT PARAMETER','+INVALID','Parameter Expects a ''Y'' or ''N'''

*/
GO



GO
USE DBAADMIN
GO
IF OBJECT_ID('dbasp_LogEvent_CAT_AUDIT') IS NOT NULL
	DROP PROCEDURE [dbo].[dbasp_LogEvent_CAT_AUDIT]
GO	
CREATE PROCEDURE	[dbo].[dbasp_LogEvent_CAT_AUDIT]
	(
	 @cEModule		sysname			
	,@cEGUID		uniqueidentifier	
	,@cEAuditType		sysname			
	,@cEEvent		sysname			
	,@cEMessage		nvarchar(max)		
	)
AS
BEGIN
	----------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------
	--
	--	dbasp_LogEvent_CAT_AUDIT					10/26/2010
	--	
	--	This Sproc is a templated wrapper for the dbasp_LogEvent Sproc specificaly for the 
	--	AUDIT category to simplify the calls in other code.
	--
	--	EXEC [DBAADMIN].[dbo].[dbasp_LogEvent_CAT_AUDIT] 
	--		{MODULE},{GUID},{AUDIT_TYPE},{EVENT},{MESSAGE}
	--
	--	======================================================================================
	--	Revision History
	--	Date		Author     		Desc
	--	==========	====================	=============================================
	--	10/26/2010	Steve Ledridge		New process.
	--	
	--	
	--	======================================================================================
	--	PARAMETERS:
	--
	-- 	@cEModule		= GENERIC NAME OF SPROC, JOB, OR GENERAL TASK TO USE FOR GROUPING
	--	@cEGUID			= GUID USED TO LINK RELATED EVENTS AS A PROCCESS OR INSTANCE
	--	@cEAuditType		= THE AUDIT TYPE (STEP,JOB,PROCCESS) 
	--	@cEEvent		= THE EVENT KEYWORD (START,-SKIP,+SKIP,-FAIL,+FAIL,SUCCESS,INFO)
	--	@cEMessage		= THE ACTUAL MESSAGE BEING LOGGED 
	
	----------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------
	DECLARE	@cEWinLog_EventID	INT
	DECLARE	@cEWinLog_EventType	SYSNAME
	DECLARE @cECategory		SYSNAME
	DECLARE @Modifier		CHAR(1)
	
	IF	LEFT(@cEEvent,1) IN ('+','-')
		SELECT	@Modifier = LEFT(@cEEvent,1)
			,@cEEvent = RIGHT(@cEEvent,LEN(@cEEvent)-1)
	
	SELECT	@cEWinLog_EventID =	CASE @cEEvent
						WHEN 'START'	THEN 10
						WHEN 'SKIP'	THEN 11
						WHEN 'FAIL'	THEN 12
						WHEN 'SUCCESS'	THEN 13
						WHEN 'INFO'	THEN 14
						ELSE 99 END
						
		,@cEWinLog_EventType =	CASE COALESCE(@Modifier,'')+@cEEvent
						WHEN 'SKIP'	THEN 'WARNING'
						WHEN '-SKIP'	THEN 'INFORMATION'
						WHEN 'FAIL'	THEN 'ERROR'
						WHEN '-FAIL'	THEN 'WARNING'
						WHEN 'SUCCESS'	THEN 'SUCCESS'
						ELSE 'INFORMATION' END
						
		,@cECategory =		'AUDIT ' + @cEAuditType
		
	exec [dbo].[dbasp_LogEvent]
		@cEModule		= @cEModule
		,@cEGUID		= @cEGUID
		,@cEWinLog_LogName	= 'OPSMSSQL' 
		,@cEMethod_WinLog	= 1  
		,@cECategory            = @cECategory
		,@cEWinLog_EventType	= @cEWinLog_EventType
		,@cEEvent               = @cEEvent         
		,@cEWinLog_EventID	= @cEWinLog_EventID 
		,@cEMessage             = @cEMessage
END
/*
--------------------------------------------------------------------
--------------------------------------------------------------------
--	HEADDER PART
--------------------------------------------------------------------
--------------------------------------------------------------------

DECLARE		@cEModule		SYSNAME
		,@cEGUID		UNIQUEIDENTIFIER
		
SELECT		@cEModule		= COALESCE(OBJECT_NAME(@@Procid),'dbasp_Baseline_SQLjobs_mover')
		,@cEGUID		= NEWID()
		
--------------------------------------------------------------------
--------------------------------------------------------------------
--	EVENT PART
--------------------------------------------------------------------
--------------------------------------------------------------------

EXEC [DBAADMIN].[dbo].[dbasp_LogEvent_CAT_VALIDATE] @cEModule,@cEGUID
	,'INPUT PARAMETER','INVALID','@DayOfWeek was 0 and should be between 1 and 7'

*/
GO


USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_LogEvent_Method_File]    Script Date: 10/28/2010 21:51:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_LogEvent_Method_File]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_LogEvent_Method_File]
GO

USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_LogEvent_Method_File]    Script Date: 10/28/2010 21:51:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_LogEvent_Method_File]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


CREATE procedure [dbo].[dbasp_LogEvent_Method_File]
	(
	 @cEModule		sysname			=null
	,@cECategory		sysname			=null
	,@cEEvent		sysname			=null
	,@cEGUID		uniqueidentifier	=null
	,@cEMessage		nvarchar(max)		=null
	,@cEFile_Name		VarChar(2048)		=null
	,@cEFile_Path		VarChar(2048)		=null
	,@cEFile_OverWrite	BIT			=null
	,@cEStat_Rows		BigInt			=null
	,@cEStat_Duration	FLOAT			=null	
	)
AS
BEGIN

	SET	@cEMessage	= COALESCE(@cEModule, N'''')	
				+ ''|'' + CONVERT(nvarchar(50),GETUTCDATE(),120) 
				+ ''|'' + COALESCE(@cECategory, N'''') 
				+ ''|'' + COALESCE(@cEEvent, N'''')
				+ ''|'' + COALESCE(REPLACE(REPLACE(REPLACE(@cEMessage,CHAR(13),'' ''),CHAR(10),'' ''),''  '','' ''), N'''')
				+ ''|'' + COALESCE(cast(@cEStat_Rows as nvarchar), N'''')
				+ ''|'' + COALESCE(cast(@cEStat_Duration as nvarchar), N'''')

	EXEC	[dbo].[dbasp_FileAccess_Write] 
			@String	= @cEMessage
			,@Path	= @cEFile_Path
			,@Filename	= @cEFile_Name

	RETURN 0
END
' 
END
GO

USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_LogEvent_Method_EMail]    Script Date: 10/28/2010 21:52:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_LogEvent_Method_EMail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_LogEvent_Method_EMail]
GO

USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_LogEvent_Method_EMail]    Script Date: 10/28/2010 21:52:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_LogEvent_Method_EMail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE procedure [dbo].[dbasp_LogEvent_Method_EMail]
	(
	 @cEModule		sysname			=null
	,@cECategory		sysname			=null
	,@cEEvent		sysname			=null
	,@cEGUID		uniqueidentifier	=null
	,@cEMessage		nvarchar(max)		=null
	,@cEMail_Subject	VarChar(2048)		=null
	,@cEMail_To		VarChar(2048)		=null
	,@cEMail_CC		VarChar(2048)		=null
	,@cEMail_BCC		VarChar(2048)		=null
	,@cEMail_Urgent		BIT			=null
	,@cEStat_Rows		BigInt			=null
	,@cEStat_Duration	FLOAT			=null	
	)
AS
BEGIN

	SET	@cEMessage
		= @cEModule + ''|'' + @cECategory + ''|'' + @cEEvent + CHAR(13) + CHAR(10) 
		+ CHAR(13) + CHAR(10) + @cEMessage + CHAR(13) + CHAR(10)
		+ CHAR(13) + CHAR(10) + CAST(@cEGUID AS VarChar(50))
		+ COALESCE(CHAR(13)+CHAR(10)+N'' -- RowCount = '' + cast(@cEStat_Rows as nvarchar(50)), N'''')
		+ COALESCE(CHAR(13)+CHAR(10)+N'' -- Duration = '' + cast(@cEStat_Duration as nvarchar(50)), N'''')

	-- TODO: URGENT not yet supported
	EXEC [dbo].[dbasp_sendmail] 
	   @recipients			= @cEMail_To
	  ,@copy_recipients		= @cEMail_CC
	  ,@blind_copy_recipients	= @cEMail_BCC
	  ,@subject			= @cEMail_Subject
	  ,@message			= @cEMessage


	RETURN 0
END
' 
END
GO

USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_LogEvent_Method_TableCentral]    Script Date: 10/28/2010 21:52:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_LogEvent_Method_TableCentral]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_LogEvent_Method_TableCentral]
GO

USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_LogEvent_Method_TableCentral]    Script Date: 10/28/2010 21:52:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_LogEvent_Method_TableCentral]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE procedure [dbo].[dbasp_LogEvent_Method_TableCentral]
	(
	 @cEModule		sysname			=null
	,@cECategory		sysname			=null
	,@cEEvent		sysname			=null
	,@cEGUID		uniqueidentifier	=null
	,@cEMessage		nvarchar(max)		=null
	,@cETable_FQName	VarChar(2048)		= ''dbaadmin.dbo.EventLog''
	,@cEStat_Rows		BigInt			=null
	,@cEStat_Duration	FLOAT			=null	
	)
AS
BEGIN
	DECLARE		@CentralServer	[sys].[sysname]
			,@TSQL		VarChar(8000)
	SELECT		@CentralServer	= [dbo].[Local_ServerEnviro].[env_detail] 
	from		[dbo].[Local_ServerEnviro] 
	where		[dbo].[Local_ServerEnviro].[env_type]	= ''CentralServer''

	IF NOT EXISTS (SELECT srv.name FROM [sys].[servers] srv WHERE srv.server_id != 0 AND srv.name = N''CentralServer'')
	BEGIN
		EXEC master.dbo.sp_addlinkedserver
				@server		= N''CentralServer''
				, @srvproduct	=N''SQL''
				, @provider	=N''SQLNCLI''
				, @datasrc	=@CentralServer
				
		EXEC master.dbo.sp_addlinkedsrvlogin	
				@rmtsrvname	=N''CentralServer''
				,@useself	=N''True''
				,@locallogin	=NULL
				,@rmtuser	=NULL
				,@rmtpassword	=NULL
				
		EXEC master.dbo.sp_serveroption @server=N''CentralServer'', @optname=N''collation compatible''	, @optvalue=N''true''
		EXEC master.dbo.sp_serveroption @server=N''CentralServer'', @optname=N''data access''		, @optvalue=N''true''
		EXEC master.dbo.sp_serveroption @server=N''CentralServer'', @optname=N''rpc''			, @optvalue=N''true''
		EXEC master.dbo.sp_serveroption @server=N''CentralServer'', @optname=N''rpc out''			, @optvalue=N''true''
		EXEC master.dbo.sp_serveroption @server=N''CentralServer'', @optname=N''connect timeout''		, @optvalue=N''0''
		EXEC master.dbo.sp_serveroption @server=N''CentralServer'', @optname=N''query timeout''		, @optvalue=N''0''
		EXEC master.dbo.sp_serveroption @server=N''CentralServer'', @optname=N''use remote collation''	, @optvalue=N''true''

	END

	SET		@TSQL		=
	''IF OBJECT_ID(N''''''+@cETable_FQName+'''''') IS NULL
	CREATE TABLE ''+@cETable_FQName+''(
	[EventLogID] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[EventDate] [datetime] NOT NULL DEFAULT (getutcdate()),
	[cEModule] [sysname] NOT NULL,
	[cECategory] [sysname] NOT NULL,
	[cEEvent] [sysname] NOT NULL,
	[cEGUID] [uniqueidentifier] NULL,
	[cEMessage] [nvarchar](4000) NULL,
	[cEStat_Rows] [bigint] NULL,
	[cEStat_Duration] [float] NULL) ON [PRIMARY]''

	EXEC	(@TSQL) AT CentralServer


	SET		@TSQL		= ''INSERT INTO	'' + COALESCE(@cETable_FQName,''dbaadmin.dbo.EventLog'') 
					+ '' (cEModule,cECategory,cEEvent,cEGUID,cEMessage,cEStat_Rows,cEStat_Duration)'' + CHAR(13) + CHAR(10)
					+ ''SELECT		 '' + QUOTENAME(COALESCE(@cEModule,''''),'''''''') + CHAR(13) + CHAR(10)
					+ ''			,'' + QUOTENAME(COALESCE(@cECategory,''''),'''''''') + CHAR(13) + CHAR(10)
					+ ''			,'' + QUOTENAME(COALESCE(@cEEvent,''''),'''''''') + CHAR(13) + CHAR(10)
					+ ''			,'' + QUOTENAME(COALESCE(CAST(@cEGUID AS VarChar(50)),''''),'''''''') + CHAR(13) + CHAR(10)
					+ ''			,'' + QUOTENAME(COALESCE(@cEMessage,''''),'''''''') + CHAR(13) + CHAR(10)
					+ ''			,'' + QUOTENAME(COALESCE(CAST(@cEStat_Rows AS VarChar(50)),''''),'''''''') + CHAR(13) + CHAR(10)
					+ ''			,'' + QUOTENAME(COALESCE(CAST(@cEStat_Duration AS VarChar(50)),''''),'''''''') + CHAR(13) + CHAR(10)

	EXEC	(@TSQL)	AT CentralServer	

	RETURN 0

END
' 
END
GO

USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_LogEvent_Method_TableLocal]    Script Date: 10/28/2010 21:52:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_LogEvent_Method_TableLocal]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_LogEvent_Method_TableLocal]
GO

USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_LogEvent_Method_TableLocal]    Script Date: 10/28/2010 21:52:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_LogEvent_Method_TableLocal]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE procedure [dbo].[dbasp_LogEvent_Method_TableLocal]
	(
	 @cEModule		sysname			=null
	,@cECategory		sysname			=null
	,@cEEvent		sysname			=null
	,@cEGUID		uniqueidentifier	=null
	,@cEMessage		nvarchar(4000)		=null
	,@cETable_FQName	VarChar(2048)		= ''dbaadmin.dbo.EventLog''
	,@cEStat_Rows		BigInt			=null
	,@cEStat_Duration	FLOAT			=null	
	)
AS
BEGIN
	
	DECLARE		@TSQL		VarChar(8000)

	SET		@TSQL		=
	''IF OBJECT_ID(N''''''+@cETable_FQName+'''''') IS NULL
	CREATE TABLE ''+@cETable_FQName+''(
	[EventLogID] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[EventDate] [datetime] NOT NULL DEFAULT (getutcdate()),
	[cEModule] [sysname] NOT NULL,
	[cECategory] [sysname] NOT NULL,
	[cEEvent] [sysname] NOT NULL,
	[cEGUID] [uniqueidentifier] NULL,
	[cEMessage] [nvarchar](4000) NULL,
	[cEStat_Rows] [bigint] NULL,
	[cEStat_Duration] [float] NULL) ON [PRIMARY]''

	EXEC	(@TSQL)


	SET		@TSQL		= ''INSERT INTO	'' + COALESCE(@cETable_FQName,''dbaadmin.dbo.EventLog'') 
					+ '' (cEModule,cECategory,cEEvent,cEGUID,cEMessage,cEStat_Rows,cEStat_Duration)'' + CHAR(13) + CHAR(10)
					+ ''SELECT		 '' + QUOTENAME(COALESCE(@cEModule,''''),'''''''') + CHAR(13) + CHAR(10)
					+ ''			,'' + QUOTENAME(COALESCE(@cECategory,''''),'''''''') + CHAR(13) + CHAR(10)
					+ ''			,'' + QUOTENAME(COALESCE(@cEEvent,''''),'''''''') + CHAR(13) + CHAR(10)
					+ ''			,'' + QUOTENAME(COALESCE(CAST(@cEGUID AS VarChar(50)),''''),'''''''') + CHAR(13) + CHAR(10)
					+ ''			,'' + QUOTENAME(COALESCE(@cEMessage,''''),'''''''') + CHAR(13) + CHAR(10)
					+ ''			,'' + QUOTENAME(COALESCE(CAST(@cEStat_Rows AS VarChar(50)),''''),'''''''') + CHAR(13) + CHAR(10)
					+ ''			,'' + QUOTENAME(COALESCE(CAST(@cEStat_Duration AS VarChar(50)),''''),'''''''') + CHAR(13) + CHAR(10)

	EXEC	(@TSQL)		

	RETURN 0

END' 
END
GO


USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_LogEvent_Method_Twitter]    Script Date: 10/28/2010 21:53:19 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_LogEvent_Method_Twitter]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_LogEvent_Method_Twitter]
GO

USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_LogEvent_Method_Twitter]    Script Date: 10/28/2010 21:53:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_LogEvent_Method_Twitter]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


CREATE procedure [dbo].[dbasp_LogEvent_Method_Twitter]
	(
	 @cEModule		sysname			=null
	,@cECategory		sysname			=null
	,@cEEvent		sysname			=null
	,@cEGUID		uniqueidentifier	=null
	,@cEMessage		nvarchar(max)		=null
	,@cEStat_Rows		BigInt			=null
	,@cEStat_Duration	FLOAT			=null	
	)
AS
BEGIN
	-- MAKE SURE THERE IS A TIMESTAMP IN THE MESSAGE SO IT DOESNT THINK THEY ARE DUPES.
	--TWITTER WILL DENY DUPES
	SET @cEMessage = LEFT(@cEModule+CHAR(10)
			+ CONVERT(nvarchar(50),GETUTCDATE(),120)+CHAR(10)
			+ @cECategory+CHAR(10)
			+ @cEEvent+CHAR(10)
			+ COALESCE(@cEMessage,''''),140)

	--EXECUTE [dbo].[dbasp_SendTweet] 
	--	   @TwitterUser = ''TSSQLDBA''
	--	  ,@TwitterPass = ''L84Lunch''
	--	  ,@message = @cEMessage
	
	PRINT ''Twitter Not Enabled at this time''

	RETURN 0
END
' 
END
GO

