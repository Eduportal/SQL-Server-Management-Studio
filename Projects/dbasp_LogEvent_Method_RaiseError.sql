USE [dbaadmin]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER procedure [dbo].[dbasp_LogEvent_Method_RaiseError]
	(
	 @cEModule		sysname			=null
	,@cECategory		sysname			=null
	,@cEEvent		sysname			=null
	,@cEEventID		INT			=null
	,@cEGUID		uniqueidentifier	=null
	,@cEMessage		varchar(8000)		=null
	,@cERE_Severity		INT			=null
	,@cERE_State		INT			=null
	,@cERE_With		VarChar(2048)		=null
	,@Traditional		BIT			=False
	)
AS
BEGIN
	DECLARE @CMD VarChar(8000)
	
	IF	@Traditional = True
	BEGIN
		SET @CMD = ''RAISERROR ('' + QUOTENAME(@cEMessage,'''''''') +'', '' + CAST(@cERE_Severity AS VarChar(20)) + '', '' + CAST(@cERE_State AS VarChar(20)) + '') '' + COALESCE(@cERE_With,'''')
		EXEC (@CMD)
		RETURN 0
	END
	
	SET	@CMD = 'eventcreate /SO TSSQLDBA /ID '+CAST(+' /L APPLICATION /T ERROR /D "This is a test error"'

	exec XP_CMDSHELL @CMD


	
END
GO






DECLARE @CMD VarChar(8000)
SET	@CMD = 'eventcreate /SO "DBA ANTHILL DEPLOYMENT 1234567890A1234567890B1234567890C1234567890D" /ID 100 /L APPLICATION /T INFORMATION /D "STARTING DEPLOYMENT FOR TICKET 47337"'
exec XP_CMDSHELL @CMD

	