
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--	SET TICKET NUMBER
----------------------------------------------------------------------------
----------------------------------------------------------------------------
:SETVAR Ticket_Number 49656
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--	SET OUTPUT DIRECTORY
----------------------------------------------------------------------------
----------------------------------------------------------------------------
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\Release Toolkit\SetOutputDirectory.sql"
:r TempFile.sql
GO
!! DEL Tempfile.sql
GO
PRINT 'OUTPUT FILES WRITTEN TO $(OutputDirectory)'
GO 
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--	CALL HEADER FILE
----------------------------------------------------------------------------
----------------------------------------------------------------------------
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\SQLCMD_Header.sql"
GO
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--	GET TICKET STATUS
----------------------------------------------------------------------------
----------------------------------------------------------------------------
:r "\\seafresqldba01\DBA_Docs\SQLCMD Scripts\Release Toolkit\Ticket_Status.sql"

----------------------------------------------------------------------------
----------------------------------------------------------------------------
--	APPROVE TICKET
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--:SETVAR Approve_Runtype			""
:SETVAR Approve_Runtype			",@runtype = 'manual'"
--:SETVAR Approve_Runtype		",@runtype = 'auto'"

:SETVAR Approve_DBA_override		""
--:SETVAR Approve_DBA_override		",@DBA_override = 'y'" 

--:r "\\seafresqldba01\DBA_Docs\SQLCMD Scripts\Release Toolkit\Gears_Approve.sql"

----------------------------------------------------------------------------
----------------------------------------------------------------------------
--	CANCEL TICKET
----------------------------------------------------------------------------
----------------------------------------------------------------------------
GOTO SkipCancel -- COMMENT THIS OUT TO PERFORM
 :CONNECT $(CentralServer_Amer)
 PRINT ''
 PRINT'-- RUNNING COMMAND > CANCEL TICKET...'
 PRINT ''
 exec DEPLcontrol.dbo.dpsp_Cancel_Gears @gears_id = $(Ticket_Number)
 PRINT'-- DONE...'
 PRINT ''
SkipCancel:
GO


----------------------------------------------------------------------------
----------------------------------------------------------------------------
--	DELETE TICKET
----------------------------------------------------------------------------
----------------------------------------------------------------------------
GOTO SkipDelete -- COMMENT THIS OUT TO PERFORM
	GOTO SkipDelete_amer
	 :CONNECT $(CentralServer_Amer)
	  PRINT ''
	  PRINT'-- RUNNING COMMAND > DELETE TICKET IN AMER...'
	  PRINT ''
	  exec DEPLcontrol.dbo.dpsp_Delete @gears_id = $(Ticket_Number)
	  PRINT'-- DONE...'
	  PRINT ''
	SkipDelete_amer:

	GOTO SkipDelete_Stage
	 :CONNECT $(CentralServer_Stage) -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
	  PRINT ''
	  PRINT'-- RUNNING COMMAND > DELETE TICKET IN STAGE...'
	  PRINT ''
	  exec DEPLcontrol.dbo.dpsp_Delete @gears_id = $(Ticket_Number)
	  PRINT'-- DONE...'
	  PRINT ''
	SkipDelete_Stage:

	GOTO SkipDelete_Prod
	 :CONNECT $(CentralServer_Prod) -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
	  PRINT ''
	  PRINT'-- RUNNING COMMAND > DELETE TICKET IN PROD...'
	  PRINT ''
	  exec DEPLcontrol.dbo.dpsp_Delete @gears_id = $(Ticket_Number)
	  PRINT'-- DONE...'
	  PRINT ''
	SkipDelete_Prod:
SkipDelete:
GO


----------------------------------------------------------------------------
----------------------------------------------------------------------------
--	GENERATE PRE-RELEASE BACKUPS SCRIPT
----------------------------------------------------------------------------
----------------------------------------------------------------------------
:CONNECT $(CentralServer_Amer)
 PRINT '--	====================================================================================================================='
 PRINT '--		GENERATING SCRIPT FOR PRE-RELEASE BACKUPS AT $(OutputDirectory)\StartPreReleaseBackups.sql'
 PRINT '--	====================================================================================================================='
 GO
:OUT	$(OutputDirectory)\StartPreReleaseBackups.sql
 GO
 exec DEPLcontrol.dbo.dpsp_Script_PreRelease @gears_id = $(Ticket_Number)
 GO
:OUT STDERR
 PRINT '--	Script Generated...'
 PRINT ''
 GO

----------------------------------------------------------------------------
----------------------------------------------------------------------------
--	GENERATE MANUAL START SCRIPT
----------------------------------------------------------------------------
----------------------------------------------------------------------------
:CONNECT $(CentralServer_Amer)
 PRINT '--	====================================================================================================================='
 PRINT '--		GENERATING SCRIPT FOR MANUAL START AT $(OutputDirectory)\ManualStart.sql'
 PRINT '--	====================================================================================================================='
 GO
:OUT	$(OutputDirectory)\ManualStart.sql
 GO
 exec DEPLcontrol.dbo.dpsp_ManualStart @gears_id = $(Ticket_Number), @SQLname = 'ScriptAll'
 GO
:OUT STDERR
 PRINT '--	Script Generated...'
 PRINT ''
 GO
 
 
-- CLEAR USERNAME AND PASSWORD
:setvar SQLCMDUSER 
:setvar SQLCMDPASSWORD 
 
