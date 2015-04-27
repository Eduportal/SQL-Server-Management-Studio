USE [AssetKeyword]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	
--ALTER PROCEDURE [dbo].[SaveAssetDeltasJob130_XPATH_BATCHED]
DECLARE
		@Username		VARCHAR(100)
		,@UserGroupCode		VARCHAR(10)
		,@AssetDeltasXML	NVARCHAR(MAX)
		,@oiErrorID		INT			--= 0	OUTPUT -- App-defined error if non-zero. 
		,@ovchErrorMessage	NVARCHAR(256)		--= ''	OUTPUT -- Text description of app-defined error
--AS

	IF OBJECT_ID('tempdb..#QueueTable') IS NOT NULL
	       DROP TABLE #QueueTable

	CREATE TABLE #QueueTable 
		      (
		      JobID		INT PRIMARY KEY CLUSTERED -- primary key required if XML index needed
		      ,Username		VARCHAR(100)
		      ,UserGroupCode	VARCHAR(10)
		      ,AssetDeltasXML	XML
		      )

	CREATE PRIMARY XML INDEX PXML_QUEUETABLE
	ON #QueueTable (AssetDeltasXML)

	UPDATE		TOP(200)
			dbo.AssetDeltaJob
			-- SET VALUES IN SELECTED RECORD
		SET	JobStatus	= 'Pending' --'Processing'
			,UpdatedDate	= GETDATE()
	OUTPUT		DELETED.JobID
			,DELETED.Username
			,ISNULL(DELETED.UserGroupCode, 'GETTY')
			,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(DELETED.AssetDeltasXML,' <','<'),' <','<'),' <','<'),' <','<'),'','>'),' >','>'),' >','>'),' >','>')
	INTO		#QueueTable		
	WHERE		JobType = 'MRT'
		AND	(
				JobStatus IN  ('Pending', 'Retrying')
			OR	(
					JobStatus = 'Processing'  -- Get 'Processing' to recover from aborted jobs
				AND	UpdatedDate < DATEADD(mi,-60,GETDATE())
				)
			)
		


/* 
---------------------------------------------------------------------------
---------------------------------------------------------------------------
	Procedure: [SaveAssetDeltasJob130]
	For: Getty Images

	Revision History
		Created:	 
		
		Modified:	05/02/2007	jboen, Added logic to supply additional information into the VitriaEventLog table.
		Modified:	05/06/2008	Ziji Huang, Added @UserGroupCode parameter for auditing
			Added logic to audit StageID changes of Assets
			Modified Keyword delete logic use IsDeleted to perform soft deletion of AssetKeyword table records
			Added logic to audit Keyword changes of Assets
		Modified:	05/11/2008	Ziji Huang, Modified to use isnull() to replace nullif() to fix bug
		Modified:	05/16/2008	Ziji Huang, Modified to set Confidence = 5 for AssetKeyword Delete actions by a user
		Modified:	01/22/2009	Ziji Huang, Modified to set StackPriority = 60 as suggested by Michael Kosten
		Modified:	04/15/2009	Ziji Huang, Added logic to handle AssetRulesQueue, reduce frequency for indexing and republishing
        Modified:   05/07/2009  Michael Kosten, Optimized to resolve blocking issues and improve speed
		Modified:   06/10/2009  Michael Kosten, Workaround for bug in adding required term that is also upserted by job
		Modified:   06/15/2009  Michael Kosten, Revise prior change because bug is fixed in web method
		Modofied:   10/26/2009  Michael Kosten, Modified to set WeightConfidence and add option for not changing weight
		

	Return Values
		0:	Success
		-999:	Some failure; check output parameters
---------------------------------------------------------------------------
--------------------------------------------------------------------------- 
*/

/*
  <?xml version="1.0" encoding="utf-16" ?> 
- <AssetDeltaSets>
  <MasterIDs>56415050</MasterIDs> 
- <Deltas>
  <DeltaType>Update</DeltaType> 
  <FieldType>Info</FieldType> 
  <ItemID>0</ItemID> 
  <ItemValue>2</ItemValue> 
  </Deltas>
- <Deltas>
  <DeltaType>Delete</DeltaType> 
  <FieldType>Keyword</FieldType> 
  <ItemID>36108</ItemID> 
  <ItemValue>0</ItemValue> 
  </Deltas>
- <Deltas>
  <DeltaType>Upsert</DeltaType> 
  <FieldType>Keyword</FieldType> 
  <ItemID>36109</ItemID> 
  <ItemValue>5</ItemValue> 
  </Deltas>
  </AssetDeltaSet>

*/

	SET NOCOUNT ON

	IF OBJECT_ID('tempdb..#AssetsToIndex') IS NOT NULL
		DROP TABLE #AssetsToIndex
		
	CREATE TABLE #AssetsToIndex (MasterID VARCHAR(50) NOT NULL)


	DECLARE @XML XML
	DECLARE @dtStart DATETIME
	DECLARE @KeywordsModified BIT
	DECLARE @MetadataModified BIT
	DECLARE @VocabularyModified BIT
	DECLARE @Delim CHAR(1)
	DECLARE @VitriaPublishPriority VARCHAR(10)
	DECLARE @BlockVitriaPublish BIT
	DECLARE @BlockVitriaPublishString VARCHAR(10)
	DECLARE	@WorkingID INT
	DECLARE	@JobID INT

	DECLARE @ErrMsg		NVARCHAR(4000)
		,@ErrSeverity	INT

	SET @dtStart = GETDATE()
	SET @KeywordsModified = 0
	SET @MetadataModified = 0
	SET @VocabularyModified = 0
	SET @Delim = ','
	SET @BlockVitriaPublish = 0

	DECLARE @indexPriority TINYINT

	DECLARE @dt DATETIME
	SET @dt = GETUTCDATE()

	-- Collect list of assets with modifications for AssetStatus and QueuedAsset updates at end
	DECLARE @AssetsTouched TABLE (
	MasterID VARCHAR(50)
	, KeywordsUpdated TINYINT
	)
	DECLARE @AuditStageID TABLE (
	MasterID VARCHAR(50) NOT NULL
	, StageIDPrevious TINYINT NOT NULL
	, StageID TINYINT NOT NULL
	)
	DECLARE @AuditAK TABLE (
	MasterID VARCHAR(50) NOT NULL
	, TermID INT NOT NULL
	, ConfidencePrevious TINYINT NOT NULL
	, Confidence TINYINT NOT NULL
	, WeightPrevious TINYINT NOT NULL
	, Weight TINYINT NOT NULL
	, WeightConfidencePrevious TINYINT NULL
	, WeightConfidence TINYINT NULL
	)

	DECLARE	@KEYWORDS_DELETED TINYINT,
			@KEYWORDS_UPDATED TINYINT,
			@KEYWORDS_NOT_UPDATED TINYINT,
			@AKAUDIT_ADD TINYINT,
			@AKAUDIT_UPDATE TINYINT,
			@AKAUDIT_DELETE TINYINT
			
	DECLARE @duration INT
	DECLARE @assetcount INT
	DECLARE @keywordcount INT

	SELECT	@KEYWORDS_DELETED = 2,
			@KEYWORDS_UPDATED = 1,
			@KEYWORDS_NOT_UPDATED = 0,
			@AKAUDIT_ADD = 10,
			@AKAUDIT_UPDATE = 20,
			@AKAUDIT_DELETE = 30

	
    DECLARE @Asset TABLE (
			JobID INT,
			MasterID VARCHAR(50), 
			ResultCode INT, 
			ResultMsg VARCHAR(1000) )

    DECLARE @InfoDeltas TABLE (
			JobID INT,
			DeltaType VARCHAR(20) NULL,
			FieldType VARCHAR(50) NULL,
			ItemID INT NULL,
			ItemValue VARCHAR(2000) NULL)

    DECLARE @KeywordDeltas TABLE (
			JobID INT,
			DeltaType VARCHAR(20) NULL,
			TermID INT NULL,
			Weight INT NULL)

	DECLARE		@Deltas TABLE	(
					JobID INT,
					DeltaType	VARCHAR(20)	NULL
					,FieldType	VARCHAR(50)	NULL
					,ItemID		INT		NULL
					,ItemValue	VARCHAR(2000)	NULL
					)
					
	DECLARE		@Vitria TABLE	(
					JobID			INT
					,VitriaPublishPriority	VARCHAR(10)
					,BlockVitriaPublish	VARCHAR(10)
					)

	-- build any missing AssetStatusHistory records for this asset
	DECLARE		@InferredAuditHistory TABLE (MasterID VARCHAR(50))

	-- For capturing new AssetStatusHistoryID values for AssetStatus table
	DECLARE		@AssetStageHistoryID TABLE (AssetStageHistoryID BIGINT, MasterID VARCHAR(50), SequenceNo INT)

	INSERT INTO	@Asset		
	SELECT		Q.JobID
			,x.value('.[1]', 'VARCHAR(50)')	MasterID
			,0				ResultCode
			,''				ResultMsg
	FROM		#QueueTable Q
	CROSS APPLY	Q.AssetDeltasXML.nodes(N'/AssetDeltaSet/MasterIDs') t(x)		

	INSERT INTO	@Deltas
	SELECT		Q.JobID 
			,x.value('DeltaType[1]'	,'varchar(20)')		DeltaType
			,x.value('FieldType[1]'	,'VARCHAR(50)')		FieldType
			,x.value('ItemID[1]'	,'INT')			ItemID
			,x.value('ItemValue[1]'	,'varchar(2000)')	ItemValue
	FROM		#QueueTable Q
	CROSS APPLY	Q.AssetDeltasXML.nodes(N'/AssetDeltaSet/Deltas') t(x)

	/* mark invalid ones as result 1000 */
	UPDATE		@Asset 
		SET	ResultCode = 1000
	FROM		@Asset a
	WHERE		MasterID NOT IN (SELECT MasterID FROM dbo.AssetStatus WITH (NOLOCK))


	INSERT INTO	@InfoDeltas
	SELECT		JobID 
			,DeltaType
			,FieldType
			,ItemID
			,ItemValue
	FROM		@Deltas
	WHERE		FieldType = 'Info'
						
	INSERT INTO	@KeywordDeltas		
	SELECT		JobID 
			,DeltaType
			,ItemID
			,ItemValue	   
	FROM		@Deltas
	WHERE		FieldType = 'Keyword'
	
	INSERT INTO	@Vitria
	SELECT		Q.JobID
			,x.value('(./VitriaPublishPriority[1]/@*)[1]'	,'varchar(10)')
			,x.value('(./BlockVitriaPublish[1]/@*)[1]'	,'VARCHAR(10)')
	FROM		#QueueTable Q
	CROSS APPLY	Q.AssetDeltasXML.nodes(N'/AssetDeltaSet') t(x)

	DECLARE test_cursor CURSOR
	FOR
	SELECT		JobID
			,Username
			,UserGroupCode
	FROM		#QUEUETABLE
	OPEN test_cursor
	FETCH NEXT FROM test_cursor INTO @JobID, @Username, @UserGroupCode
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
		IF (@@FETCH_STATUS <> -2)
		BEGIN
		    BEGIN TRY
			PRINT @JobID
			
			DELETE FROM #AssetsToIndex
			
			SELECT	@BlockVitriaPublishString	= BlockVitriaPublish
				,@BlockVitriaPublish		= CASE BlockVitriaPublish WHEN 'true' THEN 1 ELSE 0 END
				,@VitriaPublishPriority		= NULLIF(VitriaPublishPriority,'')
			FROM	@Vitria		
			WHERE	JobID = @JobID

			IF NOT EXISTS ( SELECT 1 FROM @Asset WHERE JobID = @JobID)
			BEGIN
				SET @ovchErrorMessage='No assets specified'
				RAISERROR(@ovchErrorMessage, 15, 1)
			END

			-- ===============================================
			/* INFO UPDATES: single value fields */
			-- Info.StageID --
			IF (SELECT COUNT(*) FROM @InfoDeltas InfoDeltas WHERE JobID = @JobID AND InfoDeltas.ItemID = 0 AND InfoDeltas.DeltaType = 'Update') > 0
			BEGIN
				DELETE FROM @InferredAuditHistory

				-- Add missing AuditStageHistory from current data
				-- First, add Stage 0 if no history
				INSERT INTO dbo.AssetStageHistory (MasterID, StageIDPrevious, StageID, ChangeDate, EndDate, Username, UserGroupCode, SequenceNo)
				OUTPUT Inserted.MasterID INTO @InferredAuditHistory
				SELECT DISTINCT Asset.MasterID, 0, 0, Asset.AddedToAKSDate, CASE WHEN AssetStatus.StageID = 0 THEN NULL ELSE AssetStatus.StageLastUpdated END, 'SYSTEM', 'SYSTEM', 1
				FROM @Asset a
				JOIN dbo.AssetStatus WITH (NOLOCK)
				  ON a.JobID = @JobID
				  AND a.MasterID = AssetStatus.MasterID
				JOIN dbo.Asset WITH (NOLOCK)
				  ON a.MasterID = Asset.MasterID
				LEFT JOIN dbo.AssetStageHistory WITH (NOLOCK)
				  ON a.MasterID = AssetStageHistory.MasterID
			   CROSS JOIN @InfoDeltas InfoDeltas
			   WHERE AssetStageHistory.AssetStageHistoryID IS NULL
				 AND InfoDeltas.JobID = @JobID
				 AND InfoDeltas.ItemID = 0 
				 AND InfoDeltas.DeltaType = 'Update'
				 AND AssetStatus.StageID <> CAST(InfoDeltas.ItemValue AS INT)

				-- Add history for current stage for these if not currently stage 0
				INSERT INTO dbo.AssetStageHistory (MasterID, StageIDPrevious, StageID, ChangeDate, Username, UserGroupCode, SequenceNo)
				SELECT DISTINCT AssetStatus.MasterID, 0, AssetStatus.StageID, AssetStatus.StageLastUpdated, 'SYSTEM', 'SYSTEM', 2
				  FROM @InferredAuditHistory iah
				  JOIN dbo.AssetStatus WITH (NOLOCK)
					ON iah.MasterID = AssetStatus.MasterID
				 WHERE AssetStatus.StageID <> 0 

				DELETE FROM @AuditStageID

				UPDATE dbo.AssetStatus SET
				StageID = CAST(InfoDeltas.ItemValue AS TINYINT)
				, StageLastUpdated = @dt
				, StageLastUpdatedBy = @Username
				OUTPUT INSERTED.MasterID, ISNULL(DELETED.StageID, 0), CAST(InfoDeltas.ItemValue AS TINYINT) 
				INTO @AuditStageID
				FROM @Asset a CROSS JOIN @InfoDeltas InfoDeltas
				WHERE InfoDeltas.ItemID = 0 
					AND a.JobID = @JobID
					AND InfoDeltas.JobID = @JobID
					AND InfoDeltas.DeltaType = 'Update'
					AND dbo.AssetStatus.MasterID = a.MasterID
					AND dbo.AssetStatus.StageID <> CAST(InfoDeltas.ItemValue AS INT)
			   
				DELETE FROM @AssetStageHistoryID

				INSERT INTO dbo.AssetStageHistory (MasterID, StageIDPrevious, StageID, ChangeDate, Username ,UserGroupCode, SequenceNo)
				OUTPUT INSERTED.AssetStageHistoryID, INSERTED.MasterID, INSERTED.SequenceNo 
				INTO @AssetStageHistoryID
				SELECT DISTINCT MasterID, StageIDPrevious, StageID, @dt, @Username, @UserGroupCode,
									ISNULL((SELECT MAX(SequenceNo)
											  FROM AssetStageHistory WITH (NOLOCK)
											 WHERE MasterID = asi.MasterID), 0) + 1 SequenceNo
				FROM @AuditStageID asi

				UPDATE dbo.AssetStageHistory
				   SET EndDate = @dt
				  FROM dbo.AssetStageHistory WITH (NOLOCK)
				  JOIN @AssetStageHistoryID ashi
					ON AssetStageHistory.MasterID = ashi.MasterID
				   AND AssetStageHistory.SequenceNo = ashi.SequenceNo - 1
			    
				UPDATE dbo.AssetStatus
				   SET AssetStageHistoryID = ashi.AssetStageHistoryID
				  FROM dbo.AssetStatus WITH (NOLOCK)
				  JOIN @AssetStageHistoryID ashi
					ON ashi.MasterID = AssetStatus.MasterID

				INSERT INTO @AssetsTouched (MasterID, KeywordsUpdated)
					SELECT DISTINCT MasterID, @KEYWORDS_NOT_UPDATED
					FROM @AuditStageID
			END
			-- ===============================================

			-- ===============================================
			-- KEYWORD UPDATES
			-- 1. special delete
			-- 2. delete
			-- 3. update (update and update step of upsert)
			-- 4. insert (insert and insert step of upsert)
			-- ===============================================

			-- 1. Special delete, if there is a deletekeyword with KeywordID of -1
			IF EXISTS(SELECT * FROM @KeywordDeltas WHERE JobID = @JobID AND DeltaType = 'Delete' AND TermID = -1)
			BEGIN
				SET @KeywordsModified = 1

				DELETE FROM @AuditAK
				
				UPDATE dbo.AssetKeyword SET
				IsDeleted = 1
				, Confidence = 5
				, UpdatedDate = @dt
				, UpdatedBy = @Username
				OUTPUT DELETED.MasterID, DELETED.TermID, ISNULL(DELETED.Confidence, 0), ISNULL(INSERTED.Confidence, 0)
					, ISNULL(DELETED.Weight, 0) , ISNULL(DELETED.Weight, 0)
					, DELETED.WeightConfidence , DELETED.WeightConfidence 
				INTO @AuditAK
				FROM @Asset a
				WHERE a.JobID = @JobID
				AND dbo.AssetKeyword.MasterID = a.MasterID
				
				-- Audit
				INSERT INTO dbo.AssetKeywordHistory (
					MasterID, TermID, ConfidencePrevious, Confidence, WeightPrevious, Weight, WeightConfidencePrevious
					, WeightConfidence, ActionID, ActionDate, Username, UserGroupCode)
				SELECT MasterID, TermID, ConfidencePrevious, Confidence, WeightPrevious, Weight, WeightConfidencePrevious
					, WeightConfidence, @AKAUDIT_DELETE, @dt, @Username, @UserGroupCode
				FROM @AuditAK

				-- @AssetsTouched
				INSERT INTO @AssetsTouched (MasterID, KeywordsUpdated)
					SELECT DISTINCT MasterID, @KEYWORDS_DELETED
					FROM @AuditAK

			END

			-- 2. normal delete
			IF EXISTS(SELECT 1 FROM @KeywordDeltas WHERE JobID = @JobID AND DeltaType = 'Delete')
			BEGIN
				SET @KeywordsModified = 1

				DELETE FROM @AuditAK
				
				UPDATE dbo.AssetKeyword SET
				IsDeleted = 1
				, Confidence = 5
				, UpdatedDate = @dt
				, UpdatedBy = @Username
				OUTPUT DELETED.MasterID, DELETED.TermID, ISNULL(DELETED.Confidence, 0), ISNULL(INSERTED.Confidence, 0)
					, ISNULL(DELETED.Weight, 0) , ISNULL(DELETED.Weight, 0)
					, DELETED.WeightConfidence , DELETED.WeightConfidence INTO @AuditAK
				FROM dbo.AssetKeyword WITH (NOLOCK)
			JOIN (SELECT a.MasterID, KeywordDeltas.TermID
				FROM @Asset a
				JOIN @KeywordDeltas KeywordDeltas
						  ON a.JobID = @JobID AND KeywordDeltas.JobID = @JobID AND a.ResultCode = 0
						  
				 AND KeywordDeltas.DeltaType = 'Delete') DeleteTerms
			  ON AssetKeyword.MasterID = DeleteTerms.MasterID
			 AND AssetKeyword.TermID = DeleteTerms.TermID
				
				-- Audit
				INSERT INTO dbo.AssetKeywordHistory (
				MasterID, TermID, ConfidencePrevious, Confidence, WeightPrevious, Weight, WeightConfidencePrevious
				, WeightConfidence, ActionID, ActionDate, Username, UserGroupCode)
					SELECT MasterID, TermID, ConfidencePrevious, Confidence, WeightPrevious, Weight, WeightConfidencePrevious
					, WeightConfidence, @AKAUDIT_DELETE, @dt, @Username, @UserGroupCode
					FROM @AuditAK

				-- @AssetsTouched
				INSERT INTO @AssetsTouched (MasterID, KeywordsUpdated)
					SELECT DISTINCT MasterID, @KEYWORDS_DELETED
					FROM @AuditAK
			END

			-- 3. Update (weight)
			IF EXISTS(SELECT 1 FROM @KeywordDeltas WHERE JobID = @JobID AND DeltaType IN ('Update','Upsert'))
			BEGIN
				SET @KeywordsModified = 1

				DELETE FROM @AuditAK
				
				UPDATE dbo.AssetKeyword
				   SET Weight = CASE WHEN UpdateTerms.Weight >= 0 THEN UpdateTerms.Weight ELSE ISNULL(AssetKeyword.Weight, 0) END,
				       Confidence = 5,
				       WeightConfidence = CASE WHEN UpdateTerms.Weight >= 0 THEN 5 ELSE AssetKeyword.WeightConfidence END,
				       UpdatedDate = @dt,
				       UpdatedBy = @Username
				OUTPUT DELETED.MasterID, DELETED.TermID, ISNULL(DELETED.Confidence, 0), ISNULL(INSERTED.Confidence, 0)
					, ISNULL(DELETED.Weight, 0), INSERTED.Weight
					, DELETED.WeightConfidence, INSERTED.WeightConfidence INTO @AuditAK
				FROM dbo.AssetKeyword WITH (NOLOCK)
			JOIN (SELECT a.MasterID, KeywordDeltas.TermID, KeywordDeltas.Weight
				FROM @Asset a
				JOIN @KeywordDeltas KeywordDeltas
				  ON a.JobID = @JobID AND KeywordDeltas.JobID = @JobID AND a.ResultCode = 0
				 AND (KeywordDeltas.DeltaType = 'Update' OR KeywordDeltas.DeltaType = 'Upsert')) UpdateTerms
			  ON AssetKeyword.MasterID = UpdateTerms.MasterID
			 AND AssetKeyword.TermID = UpdateTerms.TermID
			 AND ISNULL(dbo.AssetKeyword.IsDeleted, 0) = 0
			--	WHERE (isnull(dbo.AssetKeyword.Weight, 0) <> isnull(KeywordDeltas.Weight, 0) OR dbo.AssetKeyword.Confidence <> 5)

				-- Remove NoOp changes to prevent nuisance audit trail
				DELETE @AuditAK
				WHERE Weight = WeightPrevious
					AND Confidence = ConfidencePrevious
				   AND ISNULL(WeightConfidence, 0) = ISNULL(WeightConfidencePrevious, 0)

				-- Audit
				INSERT INTO dbo.AssetKeywordHistory (
				MasterID, TermID, ConfidencePrevious, Confidence, WeightPrevious, Weight, WeightConfidencePrevious
				, WeightConfidence, ActionID, ActionDate, Username, UserGroupCode
				)
					SELECT MasterID, TermID, ConfidencePrevious, Confidence, WeightPrevious, Weight, WeightConfidencePrevious
					, WeightConfidence, @AKAUDIT_UPDATE, @dt, @Username, @UserGroupCode
					FROM @AuditAK

				-- @AssetsTouched
				INSERT INTO @AssetsTouched (MasterID, KeywordsUpdated)
					SELECT DISTINCT MasterID, @KEYWORDS_UPDATED
					FROM @AuditAK
			END

			-- 3. Insert (weight)
			IF EXISTS(SELECT 1 FROM @KeywordDeltas WHERE JobID = @JobID AND DeltaType IN ('Insert','Upsert'))
			BEGIN
				SET @KeywordsModified = 1

				DELETE FROM @AuditAK
				
				-- Get set of records to insert. Separate NOLOCK SELECT from INSERT to reduce time intent exclusive lock held on AK table.
				INSERT INTO @AuditAK (MasterID, TermID, ConfidencePrevious, Confidence, WeightPrevious, Weight, WeightConfidencePrevious, WeightConfidence)
				SELECT InsertTerms.MasterID, -- MasterID
				       InsertTerms.TermID, -- TermID
				       0, -- ConfidencePrevious
				       5, -- Confidence
				       0, -- WeightPrevious
				       CASE WHEN InsertTerms.Weight >= 0 THEN InsertTerms.Weight ELSE 0 END, -- Weight
				       0, -- WeightConfidencePrevious
				       CASE WHEN InsertTerms.Weight >= 0 THEN 5 ELSE 0 END -- WeightConfidence
			 FROM (SELECT a.MasterID, KeywordDeltas.TermID, KeywordDeltas.Weight
				 FROM @Asset a
				 JOIN @KeywordDeltas KeywordDeltas
				  ON a.JobID = @JobID AND KeywordDeltas.JobID = @JobID AND a.ResultCode = 0
				  AND (KeywordDeltas.DeltaType = 'Insert' OR KeywordDeltas.DeltaType = 'Upsert')) InsertTerms
			 LEFT JOIN dbo.AssetKeyword WITH (NOLOCK)
			   ON AssetKeyword.MasterID = InsertTerms.MasterID
			  AND AssetKeyword.TermID = InsertTerms.TermID
			WHERE AssetKeyword.MasterID IS NULL
			   OR AssetKeyword.IsDeleted = 1

				-- Update AssetKeyword.IsDelete = 0 for matching @AuditAK records where AssetKeyword.IsDelete = 1
				UPDATE dbo.AssetKeyword SET
				IsDeleted = 0
				, Weight = ad.Weight
				, Confidence = ad.Confidence
				, WeightConfidence = ad.WeightConfidence
				, UpdatedDate = @dt
				, UpdatedBy = @Username
			FROM [dbo].[AssetKeyword] WITH (NOLOCK)
				JOIN @AuditAK AS ad
				  ON ad.MasterID = dbo.AssetKeyword.MasterID
				 AND ad.TermID = dbo.AssetKeyword.TermID
				 AND dbo.AssetKeyword.IsDeleted = 1

				-- Insert records that exist in @AuditAK but not exist in AssetKeyword table yet
				INSERT INTO dbo.AssetKeyword (
				MasterID, TermID, Weight, Confidence, WeightConfidence
				, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy, IsDeleted
				)
					SELECT ad.MasterID, ad.TermID, ad.Weight, ad.Confidence, ad.WeightConfidence
					, @dt, @Username, @dt, @Username, 0
					FROM @AuditAK AS ad
						LEFT JOIN dbo.AssetKeyword AS ak WITH (NOLOCK) ON ad.MasterID = ak.MasterID AND ad.TermID = ak.TermID
					WHERE ak.MasterID IS NULL

				-- Audit
				INSERT INTO dbo.AssetKeywordHistory (
				MasterID, TermID, ConfidencePrevious, Confidence, WeightPrevious, Weight, WeightConfidencePrevious
				, WeightConfidence, ActionID, ActionDate, Username, UserGroupCode
				)
					SELECT MasterID, TermID, ConfidencePrevious, Confidence, WeightPrevious, Weight, WeightConfidencePrevious
					, WeightConfidence, @AKAUDIT_ADD, @dt, @Username, @UserGroupCode
					FROM @AuditAK

				-- @AssetsTouched
				INSERT INTO @AssetsTouched (MasterID, KeywordsUpdated)
					SELECT DISTINCT MasterID, @KEYWORDS_UPDATED
					FROM @AuditAK
			END

			DECLARE @eventType VARCHAR(30)
			SELECT @eventType = 'SaveAssetDeltas'  
			IF EXISTS (
				SELECT *
				FROM @AssetsTouched
			)
			BEGIN
				DECLARE @RetStatus INT
				
				-- Update AssetStatus of all assets affected by keyword updates ONLY
				UPDATE dbo.AssetStatus SET
				KeywordsLastUpdated = @dt
				, KeywordsLastUpdatedBy = @Username
				FROM dbo.AssetStatus AST
				WHERE AST.MasterID IN (
					SELECT DISTINCT MasterID
					FROM @AssetsTouched
					WHERE KeywordsUpdated = @KEYWORDS_UPDATED OR KeywordsUpdated = @KEYWORDS_DELETED
				)
				
				-- Add to indexing queue all assets affected by ALL updates
				-- if number of assets affected is large, lower the priority
				IF( SELECT COUNT(*) FROM @AssetsTouched ) >= 500
					SET @indexPriority = 50
				ELSE
					SET @indexPriority = 25

			INSERT #AssetsToIndex (MasterID)
			SELECT DISTINCT MasterID FROM @AssetsTouched
				
				IF @KeywordsModified = 1 OR @MetadataModified = 1
				BEGIN
					-- ===============================================
					-- if there is any Keyword or Metadata change, don't push to FAST index queue
					-- ===============================================
					EXEC @RetStatus= dbo.QueueAssetsForRules05 
						@indexPriority, @KeywordsModified, @MetadataModified, @VocabularyModified, @VitriaPublishPriority, @BlockVitriaPublish
					IF @RetStatus <> 0 RAISERROR('Error in QueueAssetsForRules', 15, 1)
				END
				ELSE
				BEGIN
					-- ===============================================
					-- if no Keyword or Metadata change, push to FAST index queue
					-- ===============================================
					EXEC @RetStatus=QueueAssetsForIndexing
						@indexPriority, @eventType -- uses #AssetsToIndex
					IF @RetStatus <> 0 RAISERROR('Error in QueueAssetsForIndexing', 15, 1)
				END

				-- ===============================================
				-- don't push to stacking queue
				-- ===============================================
			END

			-- ===============================================
			-- Log with us
			SELECT		@duration = DATEDIFF(ss, @dtStart, GETDATE())
					,@assetcount = COUNT(*) 
			FROM		@Asset 
			WHERE		resultcode = 0
				AND	JobID = @JobID
			
			SELECT		@keywordcount = COUNT(*) 
			FROM		@InfoDeltas
			WHERE		JobID = @JobID
			
			SELECT		@keywordcount = @keywordCount + COUNT(*) 
			FROM		@KeywordDeltas
			WHERE		JobID = @JobID

			EXEC dbo.LogEvent 
				@duration = @duration
				, @assetcount = @assetcount	-- show # assets attempted (that exist), not # actually processed by db, FAST indexer, or Vitria
				, @keywordcount = @keywordcount
				, @loglevel = 20
				, @username = @username
				, @eventType = @eventType
			-- ===============================================

			-- SET TO COMPLETED
			RAISERROR('Job Completed',-1,-1)WITH NOWAIT
			
			UPDATE		dbo.AssetDeltaJob 
				SET	JobStatus	= 'Completed'
					,TriesRemaining	= 0
					,UpdatedDate	= GETDATE()
					,AssetDeltasXML	= NULL
			WHERE		JobID = @JobID

		    END TRY
		    BEGIN CATCH

			-------------------------------------------
			-- Error handler
			-------------------------------------------
			-- Log error

				SELECT		@ErrMsg		= ERROR_MESSAGE(),
						@ErrSeverity	= ERROR_SEVERITY(),
						@duration	= DATEDIFF(ss, @dtStart, GETDATE())

				EXEC dbo.LogEvent 
					@duration = @duration,
					@loglevel = 5,
					@username = 'SaveAssetDeltasJob',
					@eventType = 'SaveAssetDeltas',
					@eventData = @ErrMsg

				-- SET TO RETRYING OR FAILED
				RAISERROR('Job Failed',-1,-1)WITH NOWAIT
				RAISERROR(@ErrMsg,-1,-1)WITH NOWAIT
				
				UPDATE		dbo.AssetDeltaJob 
					SET	JobStatus	= CASE WHEN TriesRemaining > 1 THEN 'Retrying' ELSE 'Failed' END
						,TriesRemaining	= CASE WHEN TriesRemaining > 1 THEN TriesRemaining - 1 ELSE 0 END
						,UpdatedDate	= GETDATE()
				WHERE		JobID = @JobID

				CONTINUE
		    END CATCH
		
		END
		FETCH NEXT FROM test_cursor INTO @JobID, @Username, @UserGroupCode
	END

	CLOSE test_cursor
	DEALLOCATE test_cursor


-------------------------------------------
-- Normal exit
-------------------------------------------
NormalExit:
	IF OBJECT_ID('TEMPDB..#AssetsToIndex','U') IS NOT NULL DROP TABLE #AssetsToIndex
	--RETURN 0
GO
