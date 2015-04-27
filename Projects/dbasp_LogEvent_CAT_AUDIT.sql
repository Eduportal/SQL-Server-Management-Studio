
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
						
		,@cEWinLog_EventType =	CASE @Modifier+@cEEvent
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
		,@cEWinLog_LogName	= 'TSSQLDBA3' 
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








