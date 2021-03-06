USE [dbaadmin]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbaadmin].[dbo].[WhosOnFirst_Members]') IS NOT NULL
	DROP VIEW [dbo].[WhosOnFirst_Members]
GO
CREATE VIEW [dbo].[WhosOnFirst_Members]
AS
SELECT	T1.*
,(SELECT [vchContactNumber] FROM [SEAFRESQLBOA].[EDS].[dbo].[CONTACT_NUMBERS] WHERE [iContactID] = T1.[iContactID] AND [iNumberTypeID] = 1 ) AS [Phone_Home]
,(SELECT [vchContactNumber] FROM [SEAFRESQLBOA].[EDS].[dbo].[CONTACT_NUMBERS] WHERE [iContactID] = T1.[iContactID] AND [iNumberTypeID] = 2 ) AS [Phone_Work]
,(SELECT [vchContactNumber] FROM [SEAFRESQLBOA].[EDS].[dbo].[CONTACT_NUMBERS] WHERE [iContactID] = T1.[iContactID] AND [iNumberTypeID] = 3 ) AS [Phone_Mobile]
,(SELECT [vchContactNumber] FROM [SEAFRESQLBOA].[EDS].[dbo].[CONTACT_NUMBERS] WHERE [iContactID] = T1.[iContactID] AND [iNumberTypeID] = 28 ) AS [EMail_Home]
,(SELECT [vchContactNumber] FROM [SEAFRESQLBOA].[EDS].[dbo].[CONTACT_NUMBERS] WHERE [iContactID] = T1.[iContactID] AND [iNumberTypeID] = 27 ) AS [EMail_Work]
,(SELECT [vchContactNumber] FROM [SEAFRESQLBOA].[EDS].[dbo].[CONTACT_NUMBERS] WHERE [iContactID] = T1.[iContactID] AND [iNumberTypeID] = 29 ) AS [EMail_Mobile]

FROM	[SEAFRESQLBOA].eds.dbo.CONTACTS T1
JOIN	[SEAFRESQLBOA].eds.dbo.CONTACT_GROUPS T2
  ON	T1.iContactID = T2.iContactID
WHERE	T2.[iGroupID] = 63
  AND	T1.IsActive = 1
GO

	
--DROP TABLE	[dbo].[WhosOnFirst_Schedule]	
GO	
IF OBJECT_ID('[dbaadmin].[dbo].[WhosOnFirst_Schedule]') IS NULL
CREATE TABLE	[dbo].[WhosOnFirst_Schedule]
	(
	WOF_SchedID		Int	IDENTITY(1,1) PRIMARY KEY
	,ScheduleGroup		VarChar(50)
	,[Year]			INT
	,[Week]			INT
	,EffectiveDate		DateTime 
	,iContactID		INT
	)
GO


-- POPULATE ONCALL
-- SET STARTING PATTERN
--INSERT INTO [dbaadmin].[dbo].[WhosOnFirst_Schedule]
--SELECT 'OnCall',2010,19,'2010-05-07',936 -- STEVE
--UNION ALL
--SELECT 'OnCall',2010,20,'2010-05-14',653 -- JOE
--UNION ALL
--SELECT 'OnCall',2010,21,'2010-05-21',272 -- JIM
--UNION ALL
--SELECT 'OnCall',2010,22,'2010-05-28',271 -- ANNE

--DECLARE @loop INT
--SET @loop = 0
--WHILE @loop < 100
--BEGIN
--	INSERT INTO [dbaadmin].[dbo].[WhosOnFirst_Schedule]
--	SELECT	TOP 4 
--		ScheduleGroup
--		,YEAR(EffectiveDate + 28) AS [Year]
--		,DATEPART (week,EffectiveDate + 28) AS [Week]
--		,EffectiveDate + 28
--		,iContactID
--	FROM	[dbaadmin].[dbo].[WhosOnFirst_Schedule]
--	WHERE	ScheduleGroup = 'OnCall'
--	ORDER BY	EffectiveDate DESC	
--	SET @loop = @loop + 1
--END	

--SELECT * FROM	[dbaadmin].[dbo].[WhosOnFirst_Schedule]



-- POPULATE ON DEPLOY
-- SET STARTING PATTERN
--INSERT INTO [dbaadmin].[dbo].[WhosOnFirst_Schedule]
--SELECT 'OnDepl',2010,19,'2010-05-07',653 -- JOE
--UNION ALL
--SELECT 'OnDepl',2010,20,'2010-05-14',272 -- JIM
--UNION ALL
--SELECT 'OnDepl',2010,21,'2010-05-21',271 -- ANNE
--UNION ALL
--SELECT 'OnDepl',2010,22,'2010-05-28',936 -- STEVE

--DECLARE @loop INT
--SET @loop = 0
--WHILE @loop < 100
--BEGIN
--	INSERT INTO [dbaadmin].[dbo].[WhosOnFirst_Schedule]
--	SELECT	TOP 4 
--		ScheduleGroup
--		,YEAR(EffectiveDate + 28) AS [Year]
--		,DATEPART (week,EffectiveDate + 28) AS [Week]
--		,EffectiveDate + 28
--		,iContactID
--	FROM	[dbaadmin].[dbo].[WhosOnFirst_Schedule]
--	WHERE	ScheduleGroup = 'OnDepl'
--	ORDER BY	EffectiveDate DESC	
--	SET @loop = @loop + 1
--END	

--SELECT * FROM	[dbaadmin].[dbo].[WhosOnFirst_Schedule]


IF OBJECT_ID (N'dbaadmin.dbo.WhosOnFirst_Really') IS NOT NULL
    DROP FUNCTION dbo.WhosOnFirst_Really
GO

CREATE FUNCTION dbo.WhosOnFirst_Really(@Date DateTime, @ScheduleGroup VarChar(50))
RETURNS TABLE
AS RETURN
(
	SELECT		TOP 1
			T1.[WOF_SchedID]
			,T1.[ScheduleGroup]
			,T1.[Year]
			,T1.[Week]
			,T1.[EffectiveDate]
			,T2.*
	FROM		[dbaadmin].[dbo].[WhosOnFirst_Schedule] T1
	JOIN		[dbaadmin].[dbo].[WhosOnFirst_Members] T2
		ON	T1.iContactID = T2.iContactID
	WHERE		[EffectiveDate] < @Date
		AND	[ScheduleGroup] = @ScheduleGroup
	ORDER BY	[EffectiveDate] DESC
)
GO

	





IF OBJECT_ID('[dbaadmin].[dbo].[EventLog_Throttle]') IS NULL
CREATE TABLE	[dbo].[EventLog_Throttle]
	(
	cE_ThrottleGrouping	VarChar(255) PRIMARY KEY
	,LastSent		DateTime
	)
GO	

IF OBJECT_ID('[dbaadmin].[dbo].[EventLog]') IS NULL
CREATE TABLE	[dbo].[EventLog]
	(
	EventLogID		BigInt	IDENTITY(1,1) PRIMARY KEY
	,EventDate		DateTime DEFAULT(GetUTCDATE())
	,cEModule		sysname
	,cECategory		sysname
	,cEEvent		sysname
	,cEGUID			uniqueidentifier
	,cEMessage		nvarchar(max)
	,cEStat_Rows		BigInt
	,cEStat_Duration	FLOAT
	)
GO
	
IF DB_ID('dbacentral') IS NOT NULL 
	IF OBJECT_ID('[dbacentral].[dbo].[EventLog]') IS NULL
	BEGIN
		USE	dbacentral
		DECLARE	@TSQL	VarChar(max)
		SET	@TSQL = '	
		CREATE TABLE	[dbo].[EventLog]
			(
			EventLogID		BigInt	IDENTITY(1,1) PRIMARY KEY
			,ServerName		sysname
			,EventDate		DateTime DEFAULT(GetUTCDATE())
			,cEModule		sysname
			,cECategory		sysname
			,cEEvent		sysname
			,cEGUID			uniqueidentifier
			,cEMessage		nvarchar(max)
			,cEStat_Rows		BigInt
			,cEStat_Duration	FLOAT
			)'
		EXEC	(@TSQL);
		USE	dbaadmin;
	END
GO


if object_id(N'[dbo].[dbasp_IndexUpdateStats]') is null
	exec (N'create proc [dbo].[dbasp_IndexUpdateStats] as return 0')



IF OBJECT_ID('dbasp_LogEvent_Method_TableLocal') IS NULL
	exec (N'create proc [dbo].[dbasp_LogEvent_Method_TableLocal] as return 0')
GO
ALTER procedure [dbo].[dbasp_LogEvent_Method_TableLocal]
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
	INSERT INTO	dbaadmin.dbo.EventLog (cEModule,cECategory,cEEvent,cEGUID,cEMessage,cEStat_Rows,cEStat_Duration)
	SELECT		@cEModule
			,@cECategory
			,@cEEvent
			,@cEGUID
			,@cEMessage
			,@cEStat_Rows
			,@cEStat_Duration
	If @@ROWCOUNT = 1			
		RETURN 0
	ELSE
		RETURN -1		
END
GO

IF OBJECT_ID('dbasp_LogEvent_Method_TableCentral') IS NULL
	exec (N'create proc [dbo].[dbasp_LogEvent_Method_TableCentral] as return 0')
GO
ALTER procedure [dbo].[dbasp_LogEvent_Method_TableCentral]
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
	DECLARE		@CentralServer	sysname
			,@TSQL		VarChar(8000)
	SELECT		@CentralServer	= env_detail 
	from		dbaadmin.dbo.Local_ServerEnviro 
	where		env_type	= 'CentralServer'

	IF NOT EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = N'CentralServer')
	BEGIN
		EXEC master.dbo.sp_addlinkedserver
				@server		= N'CentralServer'
				, @srvproduct	=N'SQL'
				, @provider	=N'SQLNCLI'
				, @datasrc	=@CentralServer
				
		EXEC master.dbo.sp_addlinkedsrvlogin	
				@rmtsrvname	=N'CentralServer'
				,@useself	=N'True'
				,@locallogin	=NULL
				,@rmtuser	=NULL
				,@rmtpassword	=NULL
				
		EXEC master.dbo.sp_serveroption @server=N'CentralServer', @optname=N'collation compatible'	, @optvalue=N'true'
		EXEC master.dbo.sp_serveroption @server=N'CentralServer', @optname=N'data access'		, @optvalue=N'true'
		EXEC master.dbo.sp_serveroption @server=N'CentralServer', @optname=N'rpc'			, @optvalue=N'true'
		EXEC master.dbo.sp_serveroption @server=N'CentralServer', @optname=N'rpc out'			, @optvalue=N'true'
		EXEC master.dbo.sp_serveroption @server=N'CentralServer', @optname=N'connect timeout'		, @optvalue=N'0'
		EXEC master.dbo.sp_serveroption @server=N'CentralServer', @optname=N'query timeout'		, @optvalue=N'0'
		EXEC master.dbo.sp_serveroption @server=N'CentralServer', @optname=N'use remote collation'	, @optvalue=N'true'

	END

	SET @TSQL = '
	INSERT INTO	dbaadmin.dbo.EventLog (cEModule,cECategory,cEEvent,cEGUID,cEMessage,cEStat_Rows,cEStat_Duration)
	SELECT		cEModule		= ' + QUOTENAME(@cEModule,'''') + '
			,cECategory		= ' + QUOTENAME(@cECategory,'''') + '
			,cEEvent		= ' + QUOTENAME(@cEEvent,'''') + '
			,cEGUID			= ' + QUOTENAME(CAST(@cEGUID AS VarChar(50)),'''') + '
			,cEMessage		= ' + QUOTENAME(@cEMessage,'''') + '
			,cEStat_Rows		= ' + QUOTENAME(CAST(@cEStat_Rows AS VarChar(50)),'''') + '
			,cEStat_Duration	= ' + QUOTENAME(CAST(@cEStat_Duration AS VarChar(50)),'''') + '
'
			
	EXEC	(@TSQL) AT CentralServer

	RETURN 0

END
GO

IF OBJECT_ID('dbasp_LogEvent_Method_RaiseError') IS NULL
	exec (N'create proc [dbo].[dbasp_LogEvent_Method_RaiseError] as return 0')
GO
ALTER procedure [dbo].[dbasp_LogEvent_Method_RaiseError]
	(
	 @cEModule		sysname			=null
	,@cECategory		sysname			=null
	,@cEEvent		sysname			=null
	,@cEGUID		uniqueidentifier	=null
	,@cEMessage		nvarchar(max)		=null
	,@cERE_Severity		INT			=null
	,@cERE_State		INT			=null
	,@cERE_With		VarChar(2048)		=null
	)
AS
BEGIN
	DECLARE @TSQL VarChar(8000)
	
	SET @TSQL = 'RAISERROR (' + QUOTENAME(@cEMessage,'''') +', ' + CAST(@cERE_Severity AS VarChar(20)) + ', ' + CAST(@cERE_State AS VarChar(20)) + ') ' + COALESCE(@cERE_With,'')
	EXEC (@TSQL)

	RETURN 0
END
GO

IF OBJECT_ID('dbasp_LogEvent_Method_Twitter') IS NULL
	exec (N'create proc [dbo].[dbasp_LogEvent_Method_Twitter] as return 0')
GO
ALTER procedure [dbo].[dbasp_LogEvent_Method_Twitter]
	(
	 @cEModule		sysname			=null
	,@cECategory		sysname			=null
	,@cEEvent		sysname			=null
	,@cEGUID		uniqueidentifier	=null
	,@cEMessage		nvarchar(max)		=null
	)
AS
BEGIN
	-- MAKE SURE THERE IS A TIMESTAMP IN THE MESSAGE SO IT DOESNT THINK THEY ARE DUPES.
	--TWITTER WILL DENY DUPES
	SET @cEMessage = LEFT(@cEModule+CHAR(10)
			+ CONVERT(nvarchar(50),GETUTCDATE(),120)+CHAR(10)
			+ @cECategory+CHAR(10)
			+ @cEEvent+CHAR(10)
			+ COALESCE(@cEMessage,''),140)

	EXECUTE [dbaadmin].[dbo].[dbasp_SendTweet] 
		   @TwitterUser = 'TSSQLDBA'
		  ,@TwitterPass = 'L84Lunch'
		  ,@message = @cEMessage

	RETURN 0
END
GO


IF OBJECT_ID('dbasp_LogEvent_Method_EMail') IS NULL
	exec (N'create proc [dbo].[dbasp_LogEvent_Method_EMail] as return 0')
GO	
ALTER procedure [dbo].[dbasp_LogEvent_Method_EMail]
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
	
	)
AS
BEGIN

	SET	@cEMessage	= 'Module:   ' + @cEModule +CHAR(13)+CHAR(10)
				+ 'Category: ' + @cECategory +CHAR(13)+CHAR(10)
				+ 'Event:    ' + @cEEvent +CHAR(13)+CHAR(10)
				+ 'GUID:     ' + CAST(@cEGUID AS VarChar(50)) +CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
				+ @cEMessage

	EXEC [dbaadmin].[dbo].[dbasp_sendmail] 
	   @recipients			= @cEMail_To
	  ,@copy_recipients		= @cEMail_CC
	  ,@blind_copy_recipients	= @cEMail_BCC
	  ,@subject			= @cEMail_Subject
	  ,@message			= @cEMessage


	RETURN 0
END
GO






IF OBJECT_ID('dbasp_LogEvent_Method_File') IS NULL
	exec (N'create proc [dbo].[dbasp_LogEvent_Method_File] as return 0')
GO	
ALTER procedure [dbo].[dbasp_LogEvent_Method_File]
	(
	 @cEModule		sysname			=null
	,@cECategory		sysname			=null
	,@cEEvent		sysname			=null
	,@cEGUID		uniqueidentifier	=null
	,@cEMessage		nvarchar(max)		=null
	,@cEFile_Name		VarChar(2048)		=null
	,@cEFile_Path		VarChar(2048)		=null
	,@cEFile_OverWrite	BIT			=null
	
	)
AS
BEGIN

	EXEC [dbaadmin].[dbo].[dbasp_FileAccess_Write] 
	   @String	= @cEMessage
	  ,@Path	= @cEFile_Path
	  ,@Filename	= @cEFile_Name



	RETURN 0
END
GO




IF OBJECT_ID('dbasp_LogEvent_Method_DBAPager') IS NULL
	exec (N'create proc [dbo].[dbasp_LogEvent_Method_DBAPager] as return 0')
GO
ALTER procedure [dbo].[dbasp_LogEvent_Method_DBAPager]
	(
	 @cEModule		sysname			=null
	,@cECategory		sysname			=null
	,@cEEvent		sysname			=null
	,@cEGUID		uniqueidentifier	=null
	,@cEMessage		nvarchar(max)		=null
	,@cEPage_Subject	VarChar(2048)		=null
	,@cEPage_To		VarChar(2048)		=null
	)
AS
BEGIN
	DECLARE	@OnCallDBA	VarChar(50)
		,@OnDeplDBA	VarChar(50)
		,@AllDBA	VarChar(2048)

	SELECT	@OnCallDBA	= [EMail_Mobile]
	FROM	dbo.WhosOnFirst_Really(GetDate(), 'OnCall')

	SELECT	@OnDeplDBA	= [EMail_Mobile]
	FROM	dbo.WhosOnFirst_Really(GetDate(), 'OnDepl')

	SELECT	@AllDBA		= dbo.dbaudf_Concatenate(COALESCE([EMail_Mobile]+';',''))
	FROM	dbo.WhosOnFirst_Members
	
	SET	@cEPage_To	= REPLACE(REPLACE(REPLACE(@cEPage_To
				,'OnCallDBA',COALESCE(@OnCallDBA,'OnCallDBA-NOT RESOLVED'))
				,'OnDeplDBA',COALESCE(@OnDeplDBA,'OnDeplDBA-NOT RESOLVED'))
				,'AllDBA',COALESCE(@AllDBA,'AllDBA-NOT RESOLVED'))

	SET	@cEMessage	= 'Module:   ' + @cEModule +CHAR(13)+CHAR(10)
				+ 'Category: ' + @cECategory +CHAR(13)+CHAR(10)
				+ 'Event:    ' + @cEEvent +CHAR(13)+CHAR(10)
				+ 'GUID:     ' + CAST(@cEGUID AS VarChar(50)) +CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
				+ @cEMessage

	EXEC [dbaadmin].[dbo].[dbasp_sendmail] 
	   @recipients			= @cEPage_To
	  ,@subject			= @cEPage_Subject
	  ,@message			= @cEMessage


	RETURN 0
END
GO





















IF OBJECT_ID('dbasp_LogEvent') IS NULL
	exec (N'create proc [dbo].[dbasp_LogEvent] as return 0')
GO
ALTER procedure [dbo].[dbasp_LogEvent]
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
	
	,@cE_ForwardTo		VarChar(2048)		=null
	,@cE_RedirectTo		VarChar(2048)		=null
	
	,@cEStat_Rows		BigInt			=null
	,@cEStat_Duration	FLOAT			=null
	
	,@cERE_ForceScreen	BIT			= 0
	,@cERE_Severity		INT			= 16
	,@cERE_State		INT			= 1
	,@cERE_With		VarChar(2048)		= 'WITH LOG' -- NOT NULL FOR EASY CONCATONATION TO COMMAND
	
	,@cEMail_Subject	VarChar(2048)		=null
	,@cEMail_To		VarChar(2048)		=null
	,@cEMail_CC		VarChar(2048)		=null
	,@cEMail_BCC		VarChar(2048)		=null
	,@cEMail_Urgent		BIT			= 1
	
	,@cEFile_Name		VarChar(2048)		=null
	,@cEFile_Path		VarChar(2048)		=null
	,@cEFile_OverWrite	BIT			= 0
	
	,@cEPage_Subject	VarChar(2048)		=null
	,@cEPage_To		VarChar(2048)		=null
	
	-- METHODS TO USE TO LOG THE MESSAGE MUST USE ONE OR MORE--

	,@cEMethod_Screen	BIT			= 1
	,@cEMethod_TableLocal	BIT			= 0
	,@cEMethod_TableCentral	BIT			= 0
	,@cEMethod_RaiseError	BIT			= 0
	,@cEMethod_EMail	BIT			= 0
	,@cEMethod_File		BIT			= 0
	,@cEMethod_Twitter	BIT			= 0
	,@cEMethod_DBAPager	BIT			= 0
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
	
	@cE_ForwardTo		= A Comma Delimited String of Servers That will also execute this LogEvent (Event is also Logged Here)
	@cE_RedirectTo		= A Comma Delimited String of Servers That will execute this LogEvent instead of being Executed Here. (Event is not Logged Here)
	
	@cEStat_Rows		= PASS IN @@ROWCOUNT IF APPROPRIATE
	@cEStat_Duration	= USE FLOAT VALUE FOR MINUTES IF CALCULATED IN PROCCESS

	@cERE_ForceScreen	= RAISEERROR: FORCES ALL VALUES FOR RAISEERROR TO "raiserror('', -1,-1) with nowait" WICH CAUSES IMEDIATE SCREEN UPDATE
	@cERE_Severity		= RAISEERROR: SEVERITY VALUE
	@cERE_State		= RAISEERROR: STATE VALUE
	@cERE_With		= RAISEERROR: 'with nowait' or LOG,SETERROR
	
	@cEMail_Subject		= Subject Line For Email
	@cEMail_To		= Delimited List of Recipients
	@cEMail_CC		= Delimited List of Recipients
	@cEMail_BCC		= Delimited List of Recipients
	@cEMail_Urgent		= 1 IF UGENT 0 IF NORMAL

	@cEFile_Name		= FileName to write
	@cEFile_Path		= Path to Write File
	@cEFile_OverWrite	= 1 TO OVERWRITE 0 TO APPEND

	@cEPage_Subject	VarChar	= Subject Line For Page (SMS)
	@cEPage_To		= Delimited List of Recipients or CODEWORDS used to calculate Recipient ex(ONCALLDBA,ALLDBAS,CURENTDEPLDBA...)
	
	-- METHODS TO USE TO LOG THE MESSAGE MUST USE ONE OR MORE--

	@cEMethod_Screen	= Prints Message to screen prefixed wit "--" to make sure it doesnt interfere with scripting.
	@cEMethod_TableLocal	= Write to the Local dbaadmin.dbo.EventLog Table.
	@cEMethod_TableCentral	= Write to the Central dbacentral.dbo.EventLog Table
	@cEMethod_RaiseError	= Raises an Error
	@cEMethod_EMail		= Sends Email
	@cEMethod_File		= Writes to a File
	@cEMethod_Twitter	= Send a Twitter Update
	@cEMethod_DBAPager	= Send a Page
	
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
	DECLARE		@cLogDBName		sysname
			,@cLogSysuser		sysname
			,@cLogModuleVersion	nvarchar(32)
			,@cESpace		varchar(32)
			,@lRC			int

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
		EXEC dbo.dbasp_LogEvent_Method_TableLocal
			@cEModule
			,@cECategory
			,@cEEvent
			,@cEGUID
			,@cEMessage
			,@cEStat_Rows
			,@cEStat_Duration

	END
	
----------------------------------------------------
---------- LOG_METHOD:	TABLE_CENTRAL
----------------------------------------------------	

	IF @cEMethod_TableCentral = 1
	BEGIN
		EXEC dbo.dbasp_LogEvent_Method_TableCentral
			@cEModule
			,@cECategory
			,@cEEvent
			,@cEGUID
			,@cEMessage
			,@cEStat_Rows
			,@cEStat_Duration

	END

----------------------------------------------------
---------- LOG_METHOD:	RAISEERROR
----------------------------------------------------	

	IF @cEMethod_RaiseError = 1 or @cERE_ForceScreen = 1
	BEGIN
		-- Declare here because only used here
		DECLARE @cEMessage2		VarChar(MAX)
		
		-- RESET VAULES IF @cERE_ForceScreen = 1
		SELECT	@cEMessage2		= CASE @cERE_ForceScreen
							WHEN 1 THEN ''
							ELSE @cEMessage END
			,@cERE_Severity		= CASE @cERE_ForceScreen
							WHEN 1 THEN -1
							ELSE @cERE_Severity END 
			,@cERE_State		= CASE @cERE_ForceScreen
							WHEN 1 THEN -1
							ELSE @cERE_State END
			,@cERE_With	= CASE @cERE_ForceScreen
							WHEN 1 THEN 'WITH NOWAIT'
							ELSE @cERE_With END

		EXEC dbo.dbasp_LogEvent_Method_RaiseError
			@cEModule
			,@cECategory
			,@cEEvent
			,@cEGUID
			,@cEMessage2
			,@cERE_Severity
			,@cERE_State
			,@cERE_With

	END
	
----------------------------------------------------
---------- LOG_METHOD:	EMAIL
----------------------------------------------------	

	IF @cEMethod_Email = 1
	BEGIN
		EXEC dbo.dbasp_LogEvent_Method_EMail
			@cEModule
			,@cECategory
			,@cEEvent
			,@cEGUID
			,@cEMessage
			,@cEStat_Rows
			,@cEMail_To
			,@cEMail_CC
			,@cEMail_BCC
			,@cEMail_Urgent

	END

----------------------------------------------------
---------- LOG_METHOD:	FILE
----------------------------------------------------	

	IF @cEMethod_File = 1
	BEGIN
		EXEC dbo.dbasp_LogEvent_Method_File
			@cEModule
			,@cECategory
			,@cEEvent
			,@cEGUID
			,@cEMessage
			,@cEFile_Name
			,@cEFile_Path
			,@cEFile_OverWrite
	END
	
----------------------------------------------------
---------- LOG_METHOD:	TWITTER
----------------------------------------------------	

	IF @cEMethod_Twitter = 1
	BEGIN
		EXEC dbo.dbasp_LogEvent_Method_Twitter
			@cEModule
			,@cECategory
			,@cEEvent
			,@cEGUID
			,@cEMessage

	END
	
----------------------------------------------------
---------- LOG_METHOD:	DBAPager
----------------------------------------------------	

	IF @cEMethod_DBAPager = 1
	BEGIN
		EXEC dbo.dbasp_LogEvent_Method_DBAPager
			@cEModule
			,@cECategory
			,@cEEvent
			,@cEGUID
			,@cEMessage
			,@cEPage_Subject
			,@cEPage_To

	END	
	
----------------------------------------------------
---------- LOG_METHOD:	SCREEN
----------------------------------------------------	

	if @cEMethod_Screen=1
	BEGIN
		PRINT	'-- Module=' + @cEModule
			+ N'  Date=' + CONVERT(nvarchar(50),GETUTCDATE(),120)
			+ N'  Category=' +coalesce(@cECategory,N'(undefined)')
			+ N'  Event=' +coalesce(@cEEvent,N'(undefined)')
			+ COALESCE(N'  Message=' + @cEMessage, N'')
			+ COALESCE(N'  RowCount=' + cast(@cEStat_Rows as nvarchar), N'')
			+ COALESCE(N'  Duration=' + cast(@cEStat_Duration as nvarchar), N'')

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
	-- DECLARE ALL cE VARIABLES AT HEAD OF PROCCESS --
	--------------------------------------------------
	DECLARE	@cEModule		sysname
		,@cECategory		sysname
		,@cEEvent		sysname
		,@cEGUID		uniqueidentifier
		,@cEMessage		nvarchar(max)
		,@cERE_ForceScreen	BIT
		,@cERE_Severity		INT
		,@cERE_State		INT
		,@cERE_With		VarChar(2048)
		,@cEStat_Rows		BigInt
		,@cEStat_Duration	FLOAT
		,@cEMethod_Screen	BIT
		,@cEMethod_TableLocal	BIT
		,@cEMethod_TableCentral	BIT
		,@cEMethod_RaiseError	BIT
		,@cEMethod_Twitter	BIT
	--------------------------------------------------
	--           SET GLOBAL cE VARIABLES            --
	--------------------------------------------------
	SELECT	@cEModule		= 'TestLogingProccess'	-- SHOULD BE SET ONCE AT BEGINNING OF PROCCESS
		,@cEGUID		= NEWID()		-- SHOULD BE SET ONCE AT BEGINNING OF PROCCESS



--------------------------------------------------
--     \/         PER EVENT CODE        \/      --
--------------------------------------------------


	--------------------------------------------------
	--            SET EVENT cE VARIABLES            --
	--------------------------------------------------
	SELECT	@cECategory		= 'STEP'
		,@cEEvent		= 'INITALIZE VARIABLES'
		,@cEMessage		= 'Initializing Variables'
	--------------------------------------------------
	--            CALL LOG EVENT SPROC              --
	--------------------------------------------------
	exec dbaadmin.dbo.[dbasp_LogEvent]
				 @cEModule
				,@cECategory
				,@cEEvent
				,@cEGUID
				,@cEMessage
	-- OPTIONAL VALUES  ONLY UNCOMMENT IF NONDEFAULT--
				--,@cEStat_Rows		= @@ROWCOUNT
				--,@cEStat_Duration	= DATEDIFF(ss,@StartDate,@StopDate) / 60.0000			-- GRANULARITY IN SECONDS
							--= DATEDIFF(ms,@StartDate,@StopDate) / 1000.0000 / 60.0000	-- GRANULARITY IN MILISECONDS	
				--,@cERE_ForceScreen	
				--,@cERE_Severity		
				--,@cERE_State		
				--,@cERE_With	
				--,@cEMethod_Screen
				--,@cEMethod_TableLocal
				--,@cEMethod_TableCentral
				--,@cEMethod_RaiseError
				,@cEMethod_Twitter	= 1
	--------------------------------------------------
	--                    DONE                      --
	--------------------------------------------------


--------------------------------------------------
--   /\         END PER EVENT CODE      /\      --
--------------------------------------------------

	
--*/