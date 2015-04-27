

DROP PROCEDURE DBA_Dashboard_GearsRunningTicketStatus_Reader
GO
CREATE PROCEDURE DBA_Dashboard_GearsRunningTicketStatus_Reader
	(
	@TicketID	INT
	,@Verbose	BIT = 0
	)
AS
BEGIN	
	SET NOCOUNT ON

	declare @rc int
	declare @object int
	declare @src varchar(255)
	declare @desc varchar(255)
	declare @osql_cmd varchar(1000)

	PRINT 'Checking Ticket ' + CAST(@TicketID AS VarChar(50))
	IF NOT EXISTS	(
			SELECT		*
			FROM		dbo.DBA_Dashboard_GearsRunningTicketStatus 
			WHERE		[TicketID] = @TicketID
			)
	BEGIN
		PRINT 'Running Updater'
		-- create shell object 
		exec @rc = sp_oacreate 'wscript.shell', @object out

		set @osql_cmd = 'osql -E -dDEPLcontrol -SSEAFRESQLDBA01 -Q"deplcontrol.dbo.DBA_Dashboard_GearsRunningTicketStatus_Updater ' + CAST(@TicketID AS VarChar(50)) + ',' + CAST(@Verbose AS Char(1))

		Print 'use method'
		exec sp_oamethod @object,
				     'run',
				     @desc OUTPUT,
				     @osql_cmd

		print 'destroy object'
		exec sp_oadestroy @object
	END
	ELSE
		PRINT 'Updater Already Running'

	SELECT	[StatusDate]
		, REPLACE([StatusMessage],CHAR(13)+CHAR(10),'<BR>') AS [StatusMessage]
		,[Link]
		,[Code] 
	FROM dbo.DBA_Dashboard_GearsRunningTicketStatus 
	WHERE ([TicketID] = @TicketID) 
	ORDER BY [GRTStatusID]
END
GO


GRANT EXECUTE ON DBA_Dashboard_GearsRunningTicketStatus_Reader TO Public
GO

exec DEPLcontrol.dbo.DBA_Dashboard_GearsRunningTicketStatus_Reader 45466,1


