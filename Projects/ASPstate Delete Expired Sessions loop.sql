SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

GO
DECLARE @now datetime
DECLARE @RecCnt INT
DECLARE @CurrentCount INT
DECLARE @Msg VarChar(50)
DECLARE @Msg2 VarChar(50)
DECLARE @BatchSize INT

SELECT	@now			= GETUTCDATE()
		,@BatchSize		= 1
		,@RecCnt		= COUNT(*)
		,@CurrentCount	= @RecCnt
		,@Msg			= CAST(@RecCnt AS VarChar(50)) + ' Records to Be Removed' 
FROM	[ASPState].dbo.ASPStateTempSessions WITH(NOLOCK) 
WHERE	Expires < @now 
OPTION(MAXDOP 1)

IF @RecCnt = 0 GOTO DoneDeleting

RAISERROR(@Msg,-1,-1)

SET ROWCOUNT @BatchSize

	DoItAgian:
		DELETE [ASPState].dbo.ASPStateTempSessions WHERE Expires < @now OPTION(MAXDOP 1)
		
		IF @@ROWCOUNT < @BatchSize goto DoneDeleting
		
		SELECT	@CurrentCount = @CurrentCount - @BatchSize
				,@Msg = CAST(((@RecCnt-@CurrentCount)*100)/@RecCnt AS VarChar(50)) + ' Percent Done.'
		
		IF @Msg !=  @Msg2
		BEGIN
			RAISERROR(@Msg,-1,-1)
			SET @Msg2 = @Msg 
		END
		ELSE
			RAISERROR('.',-1,-1)
			RAISERROR(@Msg,-1,-1)
		goto DoItAgian    

	DoneDeleting:
	RAISERROR('Done Removing Records.',-1,-1)

GO
SET ROWCOUNT 0
