use ProductCatalog
GO
SET QUOTED_IDENTIFIER ON
SET NOCOUNT ON

DECLARE @MiscPrint				VARCHAR(MAX)
		,@ROWCOUNT				int
		,@WaitTime				nvarchar(20)
		,@ThrottleBatchSize		int
		,@Debug					BIT
		,@StartTime				DateTime
		,@SetStartTime			DateTime
		,@TotalProcessed		INT

DECLARE	@UpdatedTable table
		(
		[nvchAssetID] varchar(50) PRIMARY KEY
		,[CollectionCode] varchar(10)
		)

PRINT		CHAR(13)+CHAR(10)+'/************************************************************************'
SELECT		@StartTime	= Getdate()
			,@MiscPrint		= 'Start execution 01_PopulateAssetMetaData_CollectionCode.sql : ' + CONVERT(VARCHAR(100),@StartTime,109)
RAISERROR	(@MiscPrint, -1,-1) WITH NOWAIT;

SELECT	@WaitTime				= '00:00:01'
		,@ThrottleBatchSize		= 5000
		,@TotalProcessed		= 0
		,@Debug					= 1

IF @Debug = 1
BEGIN
	SELECT		@SetStartTime	= Getdate()
				,@MiscPrint		= 'Populating WorkTable : ' + CONVERT(VARCHAR(100),@SetStartTime,109)
	RAISERROR	(@MiscPrint, -1,-1) WITH NOWAIT;
END

INSERT INTO	@UpdatedTable ([nvchAssetID],[CollectionCode])
SELECT		a.nvchAssetID
			,pc.value('@Brand','varchar(10)') as LocID
From		(Select nvchAssetID, CAST(ntAssetXml AS XML) ntAssetXml From Asset a WITH(NOLOCK) WHERE EXISTS (Select nvchAssetID FROM AssetMetaData amd WITH(NOLOCK) WHERE nvchAssetID = a.nvchAssetID AND CollectionCode IS NULL)) a
CROSS APPLY	ntAssetXml.nodes ('declare namespace pc="http://www.gettyimages.com/schema/product-catalog";/pc:Asset') AS AssetXml(pc)

IF @Debug = 1
BEGIN	
	SELECT		@MiscPrint		= 'Done Populating WorkTable : ' + + CAST(DATEDIFF(ms,@SetStartTime,GetDate()) AS VarChar(20)) +'ms.'
	RAISERROR	(@MiscPrint, -1,-1) WITH NOWAIT;
END

IF @Debug = 1
BEGIN	
	SELECT		@MiscPrint		= 'STARTING UPDATE LOOP.'
	RAISERROR	(@MiscPrint, -1,-1) WITH NOWAIT;
END

SET		@ROWCOUNT = @ThrottleBatchSize
WHILE	(@ROWCOUNT = @ThrottleBatchSize)
BEGIN
	SET			@SetStartTime		= GetDate()

	UPDATE		TOP(@ThrottleBatchSize)		AssetMetaData
		SET		CollectionCode = UT.CollectionCode
	FROM		AssetMetaData amd WITH(NOLOCK)
	JOIN		@UpdatedTable UT
		ON		UT.nvchAssetId = amd.nvchAssetID
	WHERE		amd.CollectionCode IS NULL

	SELECT		@ROWCOUNT				= @@ROWCOUNT
				,@TotalProcessed		= @TotalProcessed + @ROWCOUNT
	
	IF @Debug = 1
	BEGIN
		SELECT @MiscPrint = CHAR(13)+CHAR(10)+'Count: ' + CAST(@ROWCOUNT AS VARCHAR) + ' : ' + CAST(DATEDIFF(ms,@SetStartTime,GetDate()) AS VarChar(20)) +'ms. : Total :' + CAST(@TotalProcessed AS VarChar) 
		RAISERROR(@MiscPrint, -1,-1) WITH NOWAIT;
	END	

	WAITFOR DELAY @WaitTime
END

IF @Debug = 1
BEGIN	
	SELECT		@MiscPrint		= 'DONE WITH UPDATE LOOP.'
	RAISERROR	(@MiscPrint, -1,-1) WITH NOWAIT;
END

PRINT		CHAR(13)+CHAR(10)+'/************************************************************************'
SELECT		@MiscPrint = 'Completed execution 01_PopulateAssetMetaData_CollectionCode.sql : Finished in ' + CAST(DATEDIFF(ss,@StartTime,GetDate()) AS VarChar(20)) + ' seconds. : ' + CONVERT(VARCHAR(100),GETDATE(),109) + ' Total :' + CAST(@TotalProcessed AS VarChar) 
RAISERROR	(@MiscPrint, -1,-1) WITH NOWAIT;
GO

