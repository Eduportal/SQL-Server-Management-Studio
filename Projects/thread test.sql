SET NOCOUNT ON
GO
/*

DECLARE		@XML		XML(ProductCatalog_BucketScores)

SELECT		@XML	=
'<AllScores xmlns="urn:ProductCatalog_BucketScores">
<BucketScores>
  <BucketScore Id="MID4E" Dsid="900" Kwid="1022" Bkid="1" Score="13000000" /> 
  <BucketScore Id="MID4J" Dsid="900" Kwid="1027" Bkid="1" Score="500000" /> 
  <BucketScore Id="MID6A2" Dsid="900" Kwid="1029" Bkid="1" Score="1000000" /> 
  <BucketScore Id="MID6B1" Dsid="900" Kwid="1031" Bkid="1" Score="10000000" /> 
  <BucketScore Id="MID6D4" Dsid="900" Kwid="1034" Bkid="2" Score="40000000" /> 
  <BucketScore Id="MID7B" Dsid="800" Kwid="1042" Bkid="1" Score="100" /> 
  <BucketScore Id="MID7B" Dsid="900" Kwid="1042" Bkid="1" Score="10000000" /> 
  <BucketScore Id="MID7L" Dsid="1000" Kwid="1053" Bkid="1" Score="-2915128" /> 
  <BucketScore Id="MID7L" Dsid="800" Kwid="1044" Bkid="1" Score="100" /> 
  <BucketScore Id="MID7L" Dsid="900" Kwid="1052" Bkid="1" Score="10000000" /> 
  <BucketScore Id="MID8A" Dsid="900" Kwid="1063" Bkid="1" Score="10001000" /> 
  <BucketScore Id="MID1D" Dsid="900" Kwid="1004" Bkid="1" Score="10000000" /> 
  <BucketScore Id="MID3B" Dsid="900" Kwid="1011" Bkid="1" Score="12500000" /> 
  <BucketScore Id="MID4A" Dsid="900" Kwid="1018" Bkid="1" Score="500000" /> 
  <BucketScore Id="MID4F" Dsid="900" Kwid="1023" Bkid="1" Score="14000000" /> 
  <BucketScore Id="MID6B2" Dsid="900" Kwid="1031" Bkid="1" Score="10000000" /> 
  <BucketScore Id="MID6C1" Dsid="900" Kwid="1033" Bkid="2" Score="10000000" /> 
  <BucketScore Id="MID6D5" Dsid="900" Kwid="1034" Bkid="1" Score="50000000" /> 
  <BucketScore Id="MID7C" Dsid="900" Kwid="1043" Bkid="1" Score="10000000" /> 
  <BucketScore Id="MID7M" Dsid="1000" Kwid="1055" Bkid="1" Score="100" /> 
  <BucketScore Id="MID7M" Dsid="800" Kwid="1056" Bkid="1" Score="100" /> 
  <BucketScore Id="MID1E" Dsid="900" Kwid="10041" Bkid="1" Score="10000000" /> 
  <BucketScore Id="MID3C" Dsid="900" Kwid="1012" Bkid="1" Score="10000000" /> 
  <BucketScore Id="MID41A" Dsid="900" Kwid="10271" Bkid="1" Score="10001000" /> 
  <BucketScore Id="MID4B" Dsid="900" Kwid="1019" Bkid="1" Score="10000000" /> 
  <BucketScore Id="MID4G" Dsid="900" Kwid="1024" Bkid="1" Score="15000000" /> 
  <BucketScore Id="MID5A" Dsid="900" Kwid="1028" Bkid="1" Score="20001000" /> 
  <BucketScore Id="MID6C2" Dsid="900" Kwid="1033" Bkid="1" Score="20000000" /> 
  <BucketScore Id="MID6D6" Dsid="900" Kwid="1034" Bkid="1" Score="60000000" /> 
  <BucketScore Id="MID7D" Dsid="800" Kwid="1044" Bkid="1" Score="100" /> 
  <BucketScore Id="MID7D" Dsid="900" Kwid="1044" Bkid="1" Score="10000000" /> 
  <BucketScore Id="MID7N" Dsid="1000" Kwid="1058" Bkid="1" Score="100" /> 
  <BucketScore Id="MID7N" Dsid="800" Kwid="1059" Bkid="1" Score="100" /> 
  <BucketScore Id="MID7N" Dsid="900" Kwid="1057" Bkid="1" Score="500000" /> 
  <BucketScore Id="MID8C" Dsid="900" Kwid="1065" Bkid="1" Score="10000000" /> 
  <BucketScore Id="MID1A" Dsid="900" Kwid="10012" Bkid="1" Score="10000000" /> 
  <BucketScore Id="MID3D" Dsid="900" Kwid="1013" Bkid="1" Score="10000000" /> 
  <BucketScore Id="MID3D" Dsid="900" Kwid="1014" Bkid="1" Score="10500000" /> 
  <BucketScore Id="MID41B" Dsid="900" Kwid="10272" Bkid="1" Score="10000000" /> 
  <BucketScore Id="MID4C" Dsid="900" Kwid="1020" Bkid="1" Score="11000000" /> 
  <BucketScore Id="MID4H" Dsid="900" Kwid="1025" Bkid="1" Score="500000" /> 
  <BucketScore Id="MID5B" Dsid="900" Kwid="10281" Bkid="1" Score="1000" /> 
  <BucketScore Id="MID6C3" Dsid="900" Kwid="1033" Bkid="1" Score="30000000" /> 
  <BucketScore Id="MID6D2" Dsid="900" Kwid="1034" Bkid="3" Score="20000000" /> 
  <BucketScore Id="MID7E" Dsid="0" Kwid="0" Bkid="0" Score="0" /> 
  <BucketScore Id="MID1B" Dsid="900" Kwid="10021" Bkid="1" Score="10000000" /> 
  <BucketScore Id="MID4D" Dsid="900" Kwid="1021" Bkid="1" Score="12000000" /> 
  <BucketScore Id="MID4I" Dsid="900" Kwid="1026" Bkid="1" Score="500000" /> 
  <BucketScore Id="MID5C" Dsid="900" Kwid="10282" Bkid="1" Score="20000000" /> 
  <BucketScore Id="MID6A1" Dsid="900" Kwid="1029" Bkid="1" Score="100000000" /> 
  <BucketScore Id="MID6D3" Dsid="900" Kwid="1034" Bkid="2" Score="30000000" /> 
  <BucketScore Id="MID7A" Dsid="900" Kwid="1041" Bkid="1" Score="10000000" /> 
  <BucketScore Id="MID7F" Dsid="800" Kwid="1046" Bkid="1" Score="100" /> 
  <BucketScore Id="MID7K" Dsid="1000" Kwid="1051" Bkid="1" Score="100" /> 
  <BucketScore Id="MID7K" Dsid="800" Kwid="1044" Bkid="1" Score="100" /> 
  <BucketScore Id="MID7K" Dsid="900" Kwid="1050" Bkid="1" Score="10000000" /> 
  </BucketScores>
  </AllScores>'

INSERT INTO SWL_BUCKETSCORES VALUES(@XML)

GO 10000

*/
/*
IF OBJECT_ID('BUCKETSCORES_ROLLBACK') IS NOT NULL
	DROP TABLE BUCKETSCORES_ROLLBACK
GO
CREATE TABLE BUCKETSCORES_ROLLBACK 
		(
		id		INT PRIMARY KEY CLUSTERED IDENTITY, -- primary key required if XML index needed
		BucketScores	XML,
		ProcessDate	DateTime 
		)
GO

*/
/*

CREATE PROCEDURE	SWL_wedUpsertBucketScores_A
AS

DECLARE	@WorkingID		INT
	,@trancount		INT
	,@error			INT
	,@message		VARCHAR(4000)
	,@xstate		INT
	,@LoopCount		VarChar(20)
	,@DateTime		DateTime
	,@ExecTime		VarChar(50)
	
DECLARE @OldBucketScores	TABLE	(
					[AssetId]		[nvarchar](50) NOT NULL,
					[KeywordId]		[int] NOT NULL,
					[BucketId]		[int] NOT NULL,
					[DatasetId]		[int] NOT NULL,
					[Score]			[int] NULL,
					[OmnitureActions]	[nvarchar](2048) NULL,
					[RegionId]		[int] NOT NULL
					)
					
DECLARE @NewBucketScores	TABLE	(
					[AssetId]		[nvarchar](50) NOT NULL,
					[KeywordId]		[int] NOT NULL,
					[BucketId]		[int] NOT NULL,
					[DatasetId]		[int] NOT NULL,
					[Score]			[int] NULL,
					[RegionId]		[int] NOT NULL
					)

IF OBJECT_ID('tempdb..#BUCKETSCORES') IS NOT NULL
	DROP TABLE #BUCKETSCORES

CREATE TABLE #BUCKETSCORES 
		(
		id		INT PRIMARY KEY CLUSTERED IDENTITY, -- primary key required if XML index needed
		BucketScores	XML 
		)

CREATE PRIMARY XML INDEX PXML_BucketScores
ON #BUCKETSCORES (BucketScores)

SELECT	@LoopCount	= '0'
	,@DateTime	= GetDate()

WHILE (SELECT count(*) FROM SWL_BUCKETSCORES WITH(NOLOCK)) > 0
BEGIN
	--SET @LoopCount = CAST(@LoopCount AS INT) + 1
	--RAISERROR (@LoopCount,-1,-1) WITH NOWAIT
	
	-- POP RECORD OFF OF QUEUE
	DELETE		TOP(1) [SWL_BUCKETSCORES]
	OUTPUT		DELETED.BucketScores
	INTO		#BUCKETSCORES

	--SELECT @ExecTime = ' P1- ' + CAST(DATEDIFF(ms,@DateTime,GetDate()) AS VarChar(50));RAISERROR (@ExecTime,-1,-1) WITH NOWAIT;SELECT @DateTime = GetDate();

	INSERT INTO	BUCKETSCORES_ROLLBACK (BucketScores,ProcessDate)
	SELECT		BucketScores
			,GetDate()
	FROM		#BUCKETSCORES

	--SELECT @ExecTime = ' R1- ' + CAST(DATEDIFF(ms,@DateTime,GetDate()) AS VarChar(50));RAISERROR (@ExecTime,-1,-1) WITH NOWAIT;SELECT @DateTime = GetDate();

	SET		@WorkingID = SCOPE_IDENTITY()

	;WITH		XMLNAMESPACES(DEFAULT 'urn:ProductCatalog_BucketScores')
			,NewBucketScores
			AS
			(
			SELECT		T.c.value('(@Id)[1]', 'nvarchar(50)')	AS assetId, 
					T.c.value('(@Kwid)[1]', 'int')		AS keywordid, 
					T.c.value('(@Bkid)[1]', 'int')		AS bucketid, 
					T.c.value('(@Dsid)[1]', 'int')		AS datasetid, 
					T.c.value('(@Score)[1]', 'int')		AS score
					,0					AS RegionId
			FROM		#BUCKETSCORES
			CROSS APPLY	[BucketScores].nodes('/AllScores/BucketScores/BucketScore') T(c)
			)
	INSERT INTO	@NewBucketScores		
	SELECT		*
	FROM		NewBucketScores

	--SELECT @ExecTime = ' N1- ' + CAST(DATEDIFF(ms,@DateTime,GetDate()) AS VarChar(50));RAISERROR (@ExecTime,-1,-1) WITH NOWAIT;SELECT @DateTime = GetDate();

	SET @trancount = @@trancount;
	BEGIN TRY
		IF @trancount = 0
			BEGIN TRANSACTION
		ELSE
			SAVE TRANSACTION wedUpsertBucketScores
			
	--SELECT @ExecTime = ' T1- ' + CAST(DATEDIFF(ms,@DateTime,GetDate()) AS VarChar(50));RAISERROR (@ExecTime,-1,-1) WITH NOWAIT;SELECT @DateTime = GetDate();

			DELETE	dbo.DSOPublishedDataSet WITH(ROWLOCK)
			OUTPUT	DELETED.* INTO @OldBucketScores
			WHERE	assetId IN (SELECT AssetID FROM @NewBucketScores)

	--SELECT @ExecTime = ' D1- ' + CAST(DATEDIFF(ms,@DateTime,GetDate()) AS VarChar(50));RAISERROR (@ExecTime,-1,-1) WITH NOWAIT;SELECT @DateTime = GetDate();

			INSERT INTO	dbo.DSOPublishedDataSet WITH(ROWLOCK)
			SELECT		DISTINCT
					NewBucketScores.AssetId
					,NewBucketScores.KeywordId
					,NewBucketScores.BucketId
					,NewBucketScores.DatasetId
					,NewBucketScores.Score
					,OldBucketScores.OmnitureActions
					,COALESCE(OldBucketScores.RegionId,0)
			FROM		@NewBucketScores NewBucketScores
			LEFT JOIN	@OldBucketScores OldBucketScores
				ON	NewBucketScores.assetId		= OldBucketScores.assetId
				AND	NewBucketScores.datasetid	= OldBucketScores.datasetid
				AND	NewBucketScores.keywordid	= OldBucketScores.keywordid
				AND	NewBucketScores.bucketid	= OldBucketScores.bucketid
				
	--SELECT @ExecTime = ' I1- ' + CAST(DATEDIFF(ms,@DateTime,GetDate()) AS VarChar(50));RAISERROR (@ExecTime,-1,-1) WITH NOWAIT;SELECT @DateTime = GetDate();

		IF @trancount = 0
		BEGIN	
				COMMIT;
				--RAISERROR (' -- Transaction Commited',-1,-1) WITH NOWAIT;
		END

	END TRY
	BEGIN CATCH
		
		SELECT		@error		= ERROR_NUMBER()
				,@message	= ERROR_MESSAGE()
				,@xstate	= XACT_STATE()

		-- UNDO ANY CHANGES			
		IF @xstate = -1
			ROLLBACK;
		IF @xstate = 1 AND @trancount = 0
			ROLLBACK;
		IF @xstate = 1 and @trancount > 0
			ROLLBACK TRANSACTION wedUpsertBucketScores;

		-- RAISE ERROR
		RAISERROR ('wedUpsertBucketScores: %d: %s', 16, 1, @error, @message) ;

		-- POP BATCH BACK INTO QUEUE
		INSERT INTO	SWL_BUCKETSCORES
		SELECT		BucketScores
		FROM		BUCKETSCORES_ROLLBACK
		WHERE		id = @WorkingID

	END CATCH

	--SELECT @ExecTime = ' T2- ' + CAST(DATEDIFF(ms,@DateTime,GetDate()) AS VarChar(50));RAISERROR (@ExecTime,-1,-1) WITH NOWAIT;SELECT @DateTime = GetDate();

	DELETE		BUCKETSCORES_ROLLBACK
	WHERE		id = @WorkingID
	
	TRUNCATE TABLE #BUCKETSCORES
	DELETE	@NewBucketScores
	DELETE	@OldBucketScores

	--SELECT @ExecTime = ' X1- ' + CAST(DATEDIFF(ms,@DateTime,GetDate()) AS VarChar(50));RAISERROR (@ExecTime,-1,-1) WITH NOWAIT;SELECT @DateTime = GetDate();

END		

IF OBJECT_ID('tempdb..#BUCKETSCORES')	IS NOT NULL	DROP TABLE #BUCKETSCORES
GO

--*/


DECLARE		@ThreadID		UniqueIdentifier
		,@Desc			VarChar(8000)
		,@Session_ID		INT
		,@OutputFile		VarChar(8000)
		,@TSQL			VarChar(8000)
		,@StartValue		INT
		,@CurrentValue		INT
		,@PercentDone		VarChar(200)
		,@Threads		INT
		,@ThreadLoop		INT

DECLARE		@ThreadSessions		TABLE
					(
					Thread		INT
					,Session_ID	INT
					)
							
SELECT	@TSQL		= 'exec ProductCatalog.dbo.SWL_wedUpsertBucketScores_A'
	,@Threads	= 20
	
	,@ThreadLoop	= 0
	,@StartValue	= count(*) 
FROM	SWL_BUCKETSCORES WITH(NOLOCK)

IF COALESCE(@StartValue,0) = 0
BEGIN
	RAISERROR ('NO RECORDS TO PROCCESS.',-1,-1) WITH NOWAIT
	GOTO ExitProc
END

RAISERROR ('	-- Launching %d Threads.',-1,-1,@Threads) WITH NOWAIT

WHILE @ThreadLoop < @Threads
BEGIN

	EXEC	dbaadmin.dbo.dbasp_SpawnAsyncTSQLThread	
			@TSQL		= @TSQL
			,@ThreadID	= @ThreadID	OUTPUT
			,@Desc		= @Desc		OUTPUT
			,@OutputFile	= @OutputFile	OUTPUT
			,@Session_ID	= @Session_ID	OUTPUT
			
	INSERT INTO @ThreadSessions VALUES (@ThreadLoop,@Session_ID)

	SET	@ThreadLoop = @ThreadLoop + 1
	
	RAISERROR ('	  -- Thread %d Launched as SPID %d.',-1,-1,@ThreadLoop,@Session_ID) WITH NOWAIT
	
	SELECT		@PercentDone = CAST(CAST(100.-((COUNT(*)*100.00)/@StartValue) AS FLOAT) AS VarChar(200))
	FROM		SWL_BUCKETSCORES WITH(NOLOCK)
	
	RAISERROR ('	    -- Still Running, %s Percent Done.',-1,-1,@PercentDone) WITH NOWAIT	
	
	IF @PercentDone = 100 BREAK 
END		

RAISERROR ('	-- %d Threads Launched.',-1,-1,@ThreadLoop) WITH NOWAIT


WHILE EXISTS (SELECT 1 FROM sys.dm_exec_requests WHERE session_id IN (SELECT Session_ID FROM @ThreadSessions))
BEGIN
	SELECT		@PercentDone = CAST(CAST(100.-((COUNT(*)*100.00)/@StartValue) AS FLOAT) AS VarChar(200))
	FROM		SWL_BUCKETSCORES WITH(NOLOCK)
	
	RAISERROR ('	    -- Still Running, %s Percent Done.',-1,-1,@PercentDone) WITH NOWAIT
	
	WAITFOR DELAY '00:00:01' 
END

SELECT		@PercentDone = CAST(CAST(100.-((COUNT(*)*100.00)/@StartValue) AS FLOAT) AS VarChar(200))
FROM		SWL_BUCKETSCORES WITH(NOLOCK)

RAISERROR ('	      -- Done Running, %s Percent Done.',-1,-1,@PercentDone) WITH NOWAIT

ExitProc:

GO

