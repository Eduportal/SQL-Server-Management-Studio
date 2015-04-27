
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
						
		,@cEWinLog_EventType =	CASE @Modifier+@cEEvent
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

raiserror ('DBA Warning: test message',16,1) WITH LOG,NOWAIT






