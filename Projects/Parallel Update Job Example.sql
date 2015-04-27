-- Assumption: Permenant WorkTable is used instead of memory table and two additional columns are added row_id(INT) is an identity and done(BIT) is used to identify completed records.
-- Name : PC_UpdateWorkTable 

SET NOCOUNT ON
DECLARE 	@ParalelThisSetNumber		INT
DECLARE 	@ParalelTotalSetNumber		INT
DECLARE 	@SetSize					bigint
DECLARE 	@Counter					bigint
DECLARE 	@BatchSize					int
DECLARE 	@CurMax						bigint
DECLARE 	@MiscPrint                  VARCHAR(MAX)

--	CHANGE the three variable set’s below to adjust for the number of threads used 
SET			@ParalelThisSetNumber		= 1
SET			@ParalelTotalSetNumber		= 20
SET			@BatchSize					= 100

SELECT		@CurMax						= MAX(row_id)
			,@Counter					= MIN(row_id)
			,@SetSize					= (@CurMax-@Counter)/@ParalelTotalSetNumber
FROM		dbo.PC_UpdateWorkTable WITH(NOLOCK)

PRINT 'SET ' + CAST(@ParalelThisSetNumber AS VarChar(50)) + ': Current MIN ID - ' + CAST(@Counter AS VarChar(50))
PRINT 'SET ' + CAST(@ParalelThisSetNumber AS VarChar(50)) + ': Current MAX ID - ' + CAST(@CurMax AS VarChar(50))
PRINT 'SET ' + CAST(@ParalelThisSetNumber AS VarChar(50)) + ': BATCH SIZE - ' + CAST(@BatchSize AS VarChar(50))
PRINT 'SET ' + CAST(@ParalelThisSetNumber AS VarChar(50)) + ': THIS SET - ' + CAST(@ParalelThisSetNumber AS VarChar(50))
PRINT 'SET ' + CAST(@ParalelThisSetNumber AS VarChar(50)) + ': TOTAL SETS - ' + CAST(@ParalelTotalSetNumber AS VarChar(50))
PRINT 'SET ' + CAST(@ParalelThisSetNumber AS VarChar(50)) + ': SET SIZE - ' + CAST(@SetSize AS VarChar(50))

-- RESET @Counter to current set
SET @Counter = @Counter + ((@ParalelThisSetNumber-1)*@SetSize)
PRINT 'SET ' + CAST(@ParalelThisSetNumber AS VarChar(50)) + ': SET STARTS ID - ' + CAST(@Counter AS VarChar(50))

-- RESET @CurMax to current set
SET @CurMax = @Counter + @SetSize - 1
PRINT 'SET ' + CAST(@ParalelThisSetNumber AS VarChar(50)) + ': SET END ID - ' + CAST(@CurMax AS VarChar(50))

--Force Output Write
RAISERROR   ('', -1,-1) WITH NOWAIT;

-- Dont redo if progress has already been made
SELECT		@Counter = MIN(row_id)
FROM		dbo.PC_UpdateWorkTable WITH(NOLOCK)
WHERE		row_id >= @Counter
	AND		row_id <= @CurMax
	AND		done	= 0

WHILE @COUNTER <= @CurMax
BEGIN
	SET @MiscPrint = 'SET ' + CAST(@ParalelThisSetNumber AS VarChar(50)) + ': STARTING BATCH FROM ID - ' + CAST(@Counter AS VarChar(50)) + ' TO ID - ' + CAST((@Counter + @BatchSize -1) AS VarChar(50))
	RAISERROR   (@MiscPrint, -1,-1) WITH NOWAIT;
	
	UPDATE		dbo.AssetMetaData
		SET		CollectionCode = UT.CollectionCode
	FROM        dbo.AssetMetaData amd WITH(NOLOCK)
	JOIN        dbo.PC_UpdateWorkTable UT
		ON		UT.nvchAssetId = amd.nvchAssetID
	WHERE       amd.CollectionCode IS NULL
		AND		UT.row_id >= @Counter
		AND		UT.row_id <= @Counter + @BatchSize
		AND		UT.row_id <= @CurMax 

	-- MARK BATCH DONE
	UPDATE		dbo.PC_UpdateWorkTable
		SET		done = 1
	WHERE       row_id >= @Counter
		AND		row_id <  @Counter + @BatchSize
		AND		row_id <= @CurMax 
			
	SET @MiscPrint = 'SET ' + CAST(@ParalelThisSetNumber AS VarChar(50)) + ':    COMPLETED BATCH...'
	RAISERROR   (@MiscPrint, -1,-1) WITH NOWAIT;
	
	SELECT @Counter = @Counter + @BatchSize
END

SET @MiscPrint = 'SET ' + CAST(@ParalelThisSetNumber AS VarChar(50)) + ':    COMPLETED SET...'
RAISERROR   (@MiscPrint, -1,-1) WITH NOWAIT;
