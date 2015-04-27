--DECLARE @MSGID		uniqueidentifier
--DECLARE @MESSAGE	VarChar(2000)
--SET	@MSGID		= newid()
--SET	@MESSAGE	= 'DBA Warning: ' + CAST(@MSGID AS VarChar(50))

--raiserror (@MESSAGE,15,1) WITH LOG,NOWAIT



--SET	@MESSAGE	= 'Error: 67023 Severity: 1 State: 1 ERROR: 67023 DBA Warning: TEST ERROR ' + CAST(@MSGID AS VarChar(50))

--raiserror (67023,15,1) WITH LOG,NOWAIT


DECLARE		@cEModule		SYSNAME
		,@cEGUID		UNIQUEIDENTIFIER
		
SELECT		@cEModule		= OBJECT_NAME(@@Procid)
		,@cEGUID		= NEWID()
		
--------------------------------------------------------------------
--------------------------------------------------------------------
--	EVENT PART
--------------------------------------------------------------------
--------------------------------------------------------------------

EXEC [DBAADMIN].[dbo].[dbasp_LogEvent_CAT_VALIDATE] @cEModule,@cEGUID
	,'INPUT PARAMETER','Valid','@DayOfWeek was between 1 and 7'

EXEC [DBAADMIN].[dbo].[dbasp_LogEvent_CAT_VALIDATE] @cEModule,@cEGUID
	,'INPUT PARAMETER','InValid','@DayOfWeek was not between 1 and 7'
	
EXEC [DBAADMIN].[dbo].[dbasp_LogEvent_CAT_VALIDATE] @cEModule,@cEGUID
	,'INPUT PARAMETER','+InValid','@DayOfWeek was not between 1 and 7'		