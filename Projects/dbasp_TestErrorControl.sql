DROP PROCEDURE dbasp_TestErrorControl
GO
CREATE PROCEDURE dbasp_TestErrorControl
		(
		@Input1			sysname
		,@Input2		sysname
		,@Input3		sysname
		,@DebugLevel	int = 0
		)
			-- DEBUG LEVELS --
			------------------
			-- 0 NONE
			-- 1 BLOCK LEVEL BREADCRUMBS
			-- 2 DETAILED BREADCRUMBS
			-- 3 USER DEFINED
			-- 4 USER DEFINED
			-- 5 USER DEFINED
			-- 6 PRINT AND RUN ALL DYNAMIC SCRIPTS
			-- 7 PRINT ONLY ALL DYNAMIC SCRIPTS
			-- 8 USER DEFINED
			-- 9 USER DEFINED
			-- 100 MAX
AS
SET NOCOUNT ON
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- DECLARE VARIABLES
---------------------------------------------------------------------------
IF @DebugLevel > 0
	PRINT 'STARTING VARIABLE DECLARATIONS'
---------------------------------------------------------------------------
---------------------------------------------------------------------------
DECLARE @ErrorSeverity	INT
DECLARE @ErrorState		INT
DECLARE @SprocName		sysname
DECLARE @ErrorMessage	nVarChar(4000)
DECLARE @ShortMsg		nVarChar(4000)
DECLARE @LongMsg		nVarChar(4000)
DECLARE @DebugData		nVarChar(4000)
---------------------------------------------------------------------------
DECLARE @ErrorStateLookUps TABLE (ErrorState INT, ShortMsg nVarChar(4000),LongMsg nVarChar(4000))
---------------------------------------------------------------------------
DECLARE <VariableName1,,>	<DataType1,,>
DECLARE <VariableName2,,>	<DataType2,,>

	
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- DEFINE ANTICIPATED ERRORS
-- DEBUG VALUE RE-POPULATED FROM TEMPLATE VALUE AT TIME OF CALL 
---------------------------------------------------------------------------
IF @DebugLevel > 0
	PRINT 'STARTING DEFINITION OF ANTICIPATED ERRORS'
---------------------------------------------------------------------------
---------------------------------------------------------------------------
INSERT INTO @ErrorStateLookUps
SELECT 1,'<ErrorState_1 Short Message,,Input Parameters Invalid>','<ErrorState_1 Long Message,,@Input1 and @Input2 Can Not Be The Same>'
UNION ALL
SELECT 2,'<ErrorState_2 Short Message,,Input Parameters Invalid>','<ErrorState_2 Long Message,,Input Parameters FAILURE BBB>'
UNION ALL
SELECT 3,'<ErrorState_3 Short Message,,Input Parameters Invalid>','<ErrorState_3 Long Message,,Input Parameters FAILURE BBB>'
UNION ALL
SELECT 4,'<ErrorState_4 Short Message,,TEST AAA>','<ErrorState_4 Long Message,,Test AAA Failed>'
UNION ALL
SELECT 5,'<ErrorState_5 Short Message,,TEST BBB>','<ErrorState_5 Long Message,,Test BBB Failed>'
UNION ALL
SELECT 6,'<ErrorState_6 Short Message,,TEST CCC>','<ErrorState_6 Long Message,,Test CCC Failed>'
UNION ALL
SELECT 7,'<ErrorState_7 Short Message,,TEST DDD>','<ErrorState_7 Long Message,,Test DDD Failed>'
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- END DEFINE ANTICIPATED ERRORS
---------------------------------------------------------------------------
IF @DebugLevel > 0
	PRINT 'ENDING DEFINITION OF ANTICIPATED ERRORS'
---------------------------------------------------------------------------
---------------------------------------------------------------------------
BEGIN TRY
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	-- CHECK INPUT PARAMETERS
	---------------------------------------------------------------------------
	IF @DebugLevel > 0
		PRINT 'STARTING INPUT PARAMETER CHECK'
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	IF 		@Input1 = @Input2
	BEGIN 
		RAISERROR ('Anticipated Error',16
		,1 -- ErrorState Value
		)
	END 





	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	-- END CHECK INPUT PARAMETERS
	---------------------------------------------------------------------------
	IF @DebugLevel > 0
		PRINT 'ENDING INPUT PARAMETER CHECK'
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	-- SPROC BODY
	---------------------------------------------------------------------------
	IF @DebugLevel > 0
		PRINT 'STARTING SPROC BODY'
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------

	IF @DebugLevel > 1
		PRINT '	DOING STUFF....'



			

			


	IF @DebugLevel > 1
		PRINT '	DONE WITH STUFF...'

	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	-- END SPROC BODY
	---------------------------------------------------------------------------
	IF @DebugLevel > 0
		PRINT 'ENDING SPROC BODY'
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
END TRY
BEGIN CATCH
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	-- SPROC BODY
	---------------------------------------------------------------------------
	IF @DebugLevel > 0
		PRINT 'STARTING CATCH BLOCK'
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
    SELECT	@ErrorMessage	= ERROR_MESSAGE()
			,@ErrorSeverity	= ERROR_SEVERITY()
			,@ErrorState	= ERROR_STATE()

	SELECT	@ErrorMessage	= '%s|%s|%s|%s'
			,@SprocName		= QUOTENAME(OBJECT_NAME(@@PROCID))
			,@ShortMsg		= COALESCE(ShortMsg,'UnAnticipated Error')
			,@LongMsg		= COALESCE(LongMsg,@ErrorMessage)
			,@DebugData		= CASE @ErrorState
								WHEN 1	THEN	QUOTENAME(CAST(@Input1 AS nVarChar(4000))) 
												+','+ QUOTENAME(CAST(@Input2 AS nVarChar(4000)))
								WHEN 2	THEN 'DEBUG DATA 2'
								WHEN 3	THEN 'DEBUG DATA 3'
								WHEN 4	THEN 'DEBUG DATA 4'
								WHEN 5	THEN 'DEBUG DATA 5'
								-- ELSE JUST STRINGS TOGEATHER THE INPUT PARAMETERS
								ELSE	QUOTENAME(CAST(@Input1 AS nVarChar(4000))) 
										+','+ QUOTENAME(CAST(@Input2 AS nVarChar(4000))) 
										+','+ QUOTENAME(CAST(@Input3 AS nVarChar(4000)))
								END
	FROM	@ErrorStateLookUps 
	WHERE	ErrorState		= @ErrorState
				
    -- Use RAISERROR inside the CATCH block to return error
    -- information about the original error that caused
    -- execution to jump to the CATCH block.
	RAISERROR	(
				@ErrorMessage
				,10				-- SEVERITY SWITCH TO A LOWER SEVERITY FOR 
				,@ErrorState	-- STATE
				,@SprocName		-- SPROC NAME
				,@ShortMsg		-- SHORT MESSAGE
				,@DebugData		-- DEBUG DATA
				,@LongMsg		-- LONG MESSAGE
				)
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	-- SPROC BODY
	---------------------------------------------------------------------------
	IF @DebugLevel > 0
		PRINT 'ENDING CATCH BLOCK'
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
END CATCH
GO


exec dbasp_TestErrorControl 'AAA','AAA','CCC'