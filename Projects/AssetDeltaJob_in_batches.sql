USE [AssetKeyword]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

       
DECLARE       @BatchSize           INT
              ,@oiErrorID          INT                  
              ,@ovchErrorMessage   NVARCHAR(256)        

SET @BatchSize = 100

       SET NOCOUNT ON

       IF OBJECT_ID('tempdb..#AssetDeltaWorkQueue') IS NOT NULL
              DROP TABLE #AssetDeltaWorkQueue

       CREATE TABLE #AssetDeltaWorkQueue 
                     (
                     JobID                INT PRIMARY KEY CLUSTERED -- primary key required if XML index needed
                     ,Username            VARCHAR(100)
                     ,UserGroupCode             VARCHAR(10)
                     ,AssetDeltasXML            XML
                     )

       CREATE PRIMARY XML INDEX PXML_QUEUETABLE
       ON #AssetDeltaWorkQueue (AssetDeltasXML)


       IF OBJECT_ID('tempdb..#AssetsToIndex') IS NOT NULL
              DROP TABLE #AssetsToIndex
              
       CREATE TABLE #AssetsToIndex 
                     (
                     MasterID             VARCHAR(50) NOT NULL
                     )


       DECLARE       @XML                       XML
                     ,@dtStart                  DATETIME
                     ,@KeywordsModified         BIT
                     ,@MetadataModified         BIT
                     ,@VocabularyModified       BIT
                     ,@Delim                           CHAR(1)
                     ,@VitriaPublishPriority           VARCHAR(10)
                     ,@BlockVitriaPublish       BIT
                     ,@BlockVitriaPublishString VARCHAR(10)
                     ,@WorkingID                INT
                     ,@JobID                           INT
                     ,@ErrMsg                   NVARCHAR(4000)
                     ,@ErrSeverity              INT
                     ,@Username                 VARCHAR(100)
                     ,@UserGroupCode                   VARCHAR(10)
                     ,@AssetDeltasXML           NVARCHAR(MAX)
                     ,@indexPriority                   TINYINT
                     ,@dt                       DATETIME
                     ,@KEYWORDS_DELETED         TINYINT
                     ,@KEYWORDS_UPDATED         TINYINT
                     ,@KEYWORDS_NOT_UPDATED            TINYINT
                     ,@AKAUDIT_ADD              TINYINT
                     ,@AKAUDIT_UPDATE           TINYINT
                     ,@AKAUDIT_DELETE           TINYINT
                     ,@duration                 INT
                     ,@assetcount               INT
                     ,@keywordcount                    INT
                     ,@TimeCheck                DATETIME



       DECLARE              @AssetsTouched                    TABLE 
                     (
                     MasterID                   VARCHAR(50)
                     ,KeywordsUpdated           TINYINT
                     )
                     
       DECLARE              @AuditStageID              TABLE 
                     (
                     MasterID                   VARCHAR(50)   NOT NULL
                     ,StageIDPrevious           TINYINT              NOT NULL
                     ,StageID                   TINYINT              NOT NULL
                     )
                     
       DECLARE              @AuditAK                   TABLE 
                     (
                     MasterID                   VARCHAR(50)   NOT NULL
                     ,TermID                           INT           NOT NULL
                     ,ConfidencePrevious        TINYINT       NOT NULL
                     ,Confidence                TINYINT       NOT NULL
                     ,WeightPrevious                   TINYINT       NOT NULL
                     ,Weight                           TINYINT       NOT NULL
                     ,WeightConfidencePrevious  TINYINT       NULL
                     ,WeightConfidence          TINYINT       NULL
                     )
       
       DECLARE              @Asset                     TABLE 
                     (
                     JobID                      INT
                     ,MasterID                  VARCHAR(50)
                     ,ResultCode                INT
                     ,ResultMsg                 VARCHAR(1000)
                     )

       DECLARE              @InfoDeltas                TABLE 
                     (
                     JobID                      INT
                     ,DeltaType                 VARCHAR(20)   NULL
                     ,FieldType                 VARCHAR(50)   NULL
                     ,ItemID                           INT           NULL
                     ,ItemValue                 VARCHAR(2000) NULL
                     )

       DECLARE              @KeywordDeltas                    TABLE 
                     (
                     JobID                      INT
                     ,DeltaType                 VARCHAR(20)   NULL
                     ,TermID                           INT           NULL
                     ,Weight                           INT           NULL
                     )

       DECLARE              @Deltas                           TABLE  
                     (
                     JobID                      INT
                     ,DeltaType                 VARCHAR(20)   NULL
                     ,FieldType                 VARCHAR(50)   NULL
                     ,ItemID                           INT           NULL
                     ,ItemValue                 VARCHAR(2000) NULL
                     )
                                  
       DECLARE              @Vitria                           TABLE  
                     (
                     JobID                      INT 
                     ,VitriaPublishPriority            VARCHAR(10)
                     ,BlockVitriaPublish        VARCHAR(10)
                     )

       DECLARE              @InferredAuditHistory             TABLE 
                     (
                     MasterID                   VARCHAR(50)
                     )

       DECLARE              @AssetStageHistoryID       TABLE 
                     (
                     AssetStageHistoryID        BIGINT
                     ,MasterID                  VARCHAR(50)
                     ,SequenceNo                INT
                     )

       SELECT        @TimeCheck                 = getdate()

BatchStart:

       DELETE        #AssetDeltaWorkQueue
       DELETE        @Asset                     
       DELETE        @Deltas                           
       DELETE        @InfoDeltas                
       DELETE        @KeywordDeltas                    
       DELETE        @Vitria                           

       SELECT        @KEYWORDS_DELETED          = 2
                     ,@KEYWORDS_UPDATED         = 1
                     ,@KEYWORDS_NOT_UPDATED            = 0
                     ,@AKAUDIT_ADD              = 10
                     ,@AKAUDIT_UPDATE           = 20
                     ,@AKAUDIT_DELETE           = 30
                     ,@dtStart                  = GETDATE()
                     ,@KeywordsModified         = 0
                     ,@MetadataModified         = 0
                     ,@VocabularyModified       = 0
                     ,@Delim                           = ','
                     ,@BlockVitriaPublish       = 0
                     ,@dt                       = GETUTCDATE()
                     


       --UPDATE dbo.AssetDeltaJob SET JobStatus = 'Pending' WHERE JobType = 'MRT' AND JobStatus = 'Processing'
       SELECT        @ErrMsg = CAST(COUNT(*)AS VarChar(50)) + ' Records in Queue. '+ CAST(DATEDIFF(ms,@TimeCheck,GetDate())AS VarChar(50))
       FROM          dbo.AssetDeltaJob
       WHERE         JobType = 'MRT'
              AND    (
                           JobStatus IN  ('Pending', 'Retrying')
                     OR     (
                                  JobStatus = 'Processing'  -- Get 'Processing' to recover from aborted jobs
                           AND    UpdatedDate < DATEADD(mi,-60,GETDATE())
                           )
                     )
       

       RAISERROR (@ErrMsg,-1,-1) WITH NOWAIT
       SELECT        @TimeCheck    = getdate()
                     ,@ErrMsg      = NULL 

       ;WITH         ADJ1 AS (
                       SELECT TOP (@BatchSize) * FROM dbo.AssetDeltaJob
                       WHERE  JobType = 'MRT'
                       AND    (
                              JobStatus IN  ('Pending', 'Retrying')
                              OR     (
                                     JobStatus = 'Processing'  -- Get 'Processing' to recover from aborted jobs
                                     AND    UpdatedDate < DATEADD(mi,-60,GETDATE())
                              )
                       )
                       ORDER BY JobID
                     )
       UPDATE        ADJ1
                     -- SET VALUES IN SELECTED RECORDS
       SET           JobStatus     = 'Processing'
                     ,UpdatedDate  = GETDATE()
       OUTPUT        DELETED.JobID
                     ,DELETED.Username
                     ,ISNULL(DELETED.UserGroupCode, 'GETTY')
                     ,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(DELETED.AssetDeltasXML,' <','<'),' <','<'),' <','<'),' <','<'),'','>'),' >','>'),' >','>'),' >','>')
       INTO          #AssetDeltaWorkQueue


       IF @@ROWCOUNT = 0
              GOTO NormalExit

       INSERT INTO   @Asset        
       SELECT        Q.JobID                           JobID
                     ,x.value('.[1]', 'VARCHAR(50)')   MasterID
                     ,0                         ResultCode
                     ,''                        ResultMsg
       FROM          #AssetDeltaWorkQueue Q
       CROSS APPLY   Q.AssetDeltasXML.nodes(N'/AssetDeltaSet/MasterIDs') t(x)             

       INSERT INTO   @Deltas
       SELECT        Q.JobID                                         JobID
                     ,x.value('DeltaType[1]'    ,'varchar(20)')            DeltaType
                     ,x.value('FieldType[1]'    ,'VARCHAR(50)')            FieldType
                     ,x.value('ItemID[1]' ,'INT')                    ItemID
                     ,x.value('ItemValue[1]'    ,'varchar(2000)')    ItemValue
       FROM          #AssetDeltaWorkQueue Q
       CROSS APPLY   Q.AssetDeltasXML.nodes(N'/AssetDeltaSet/Deltas') t(x)

       INSERT INTO   @Vitria
       SELECT        Q.JobID                                                       JobID
                     ,x.value('(./VitriaPublishPriority[1]/@*)[1]'   ,'varchar(10)')       VitriaPublishPriority
                     ,x.value('(./BlockVitriaPublish[1]/@*)[1]'      ,'VARCHAR(10)')       BlockVitriaPublish
       FROM          #AssetDeltaWorkQueue Q
       CROSS APPLY   Q.AssetDeltasXML.nodes(N'/AssetDeltaSet') t(x)

       /* mark invalid ones as result 1000 */
       UPDATE        @Asset 
              SET    ResultCode = 1000
       FROM          @Asset a
       WHERE         MasterID NOT IN (SELECT MasterID FROM dbo.AssetStatus WITH (NOLOCK))

       INSERT INTO   @InfoDeltas
       SELECT        JobID 
                     ,DeltaType
                     ,FieldType
                     ,ItemID
                     ,ItemValue
       FROM          @Deltas
       WHERE         FieldType = 'Info'

       INSERT INTO   @KeywordDeltas             
       SELECT        JobID 
                     ,DeltaType
                     ,ItemID
                     ,ItemValue       
       FROM          @Deltas
       WHERE         FieldType = 'Keyword'

       DECLARE test_cursor CURSOR
       FOR
       SELECT        JobID
                     ,Username
                     ,UserGroupCode
       FROM          #AssetDeltaWorkQueue

       OPEN test_cursor
       FETCH NEXT FROM test_cursor INTO @JobID, @Username, @UserGroupCode
       WHILE (@@FETCH_STATUS <> -1)
       BEGIN
              IF (@@FETCH_STATUS <> -2)
              BEGIN
                  BEGIN TRY

                     DELETE        @AssetsTouched                    
                     DELETE        @AuditStageID              
                     DELETE        @AuditAK                   
                     DELETE        @InferredAuditHistory             
                     DELETE        @AssetStageHistoryID       
                     DELETE        #AssetsToIndex

                     --PRINT              'CheckPoint StartLoop:' +CAST(DATEDIFF(ms,@TimeCheck,GetDate())AS VarChar(50))
                     --SET         @TimeCheck = getdate()
                     
                     
                     SELECT @BlockVitriaPublishString  = BlockVitriaPublish
                           ,@BlockVitriaPublish       = CASE BlockVitriaPublish WHEN 'true' THEN 1 ELSE 0 END
                           ,@VitriaPublishPriority           = NULLIF(VitriaPublishPriority,'')
                     FROM   @Vitria              
                     WHERE  JobID = @JobID

                     IF NOT EXISTS ( SELECT 1 FROM @Asset WHERE JobID = @JobID)
                     BEGIN
                           SET @ovchErrorMessage='No assets specified'
                           RAISERROR(@ovchErrorMessage, 15, 1)
                     END

                     -- ===============================================
                     /* INFO UPDATES: single value fields */
                     -- Info.StageID --
                     IF EXISTS (SELECT 1 FROM @InfoDeltas InfoDeltas WHERE JobID = @JobID AND InfoDeltas.ItemID = 0 AND InfoDeltas.DeltaType = 'Update')
                     BEGIN
                           DELETE FROM @InferredAuditHistory
                           DELETE FROM @AuditStageID
                           DELETE FROM @AssetStageHistoryID

                           -- Add missing AuditStageHistory from current data
                           -- First, add Stage 0 if no history
                           INSERT INTO   dbo.AssetStageHistory (MasterID, StageIDPrevious, StageID, ChangeDate, EndDate, Username, UserGroupCode, SequenceNo)
                                  OUTPUT Inserted.MasterID 
                                  INTO   @InferredAuditHistory
                           SELECT        DISTINCT 
                                         Asset.MasterID
                                         ,0
                                         ,0
                                         ,Asset.AddedToAKSDate
                                         ,CASE WHEN AssetStatus.StageID = 0 THEN NULL ELSE AssetStatus.StageLastUpdated END
                                         ,'SYSTEM'
                                         ,'SYSTEM'
                                         ,1
                           FROM          @Asset a
                           JOIN          dbo.AssetStatus WITH (NOLOCK)
                                  ON     a.JobID                    = @JobID
                                  AND    a.MasterID           = AssetStatus.MasterID
                           JOIN          dbo.Asset WITH (NOLOCK)
                                  ON     a.MasterID           = Asset.MasterID
                           LEFT JOIN     dbo.AssetStageHistory WITH (NOLOCK)
                                  ON     a.MasterID           = AssetStageHistory.MasterID
                        CROSS JOIN        @InfoDeltas InfoDeltas
                        WHERE             AssetStageHistory.AssetStageHistoryID IS NULL
                                  AND    InfoDeltas.JobID     = @JobID
                                  AND    InfoDeltas.ItemID    = 0 
                                  AND    InfoDeltas.DeltaType = 'Update'
                                  AND    AssetStatus.StageID  != CAST(InfoDeltas.ItemValue AS INT)

                           -- Add history for current stage for these if not currently stage 0
                           INSERT INTO   dbo.AssetStageHistory (MasterID, StageIDPrevious, StageID, ChangeDate, Username, UserGroupCode, SequenceNo)
                           SELECT        DISTINCT 
                                         AssetStatus.MasterID
                                         ,0
                                         ,AssetStatus.StageID
                                         ,AssetStatus.StageLastUpdated
                                         ,'SYSTEM'
                                         ,'SYSTEM'
                                         ,2
                           FROM          @InferredAuditHistory iah
                           JOIN          dbo.AssetStatus WITH (NOLOCK)
                                  ON     iah.MasterID         = AssetStatus.MasterID
                           WHERE        AssetStatus.StageID  != 0 

                           UPDATE        dbo.AssetStatus 
                                  SET    StageID                    = CAST(InfoDeltas.ItemValue AS TINYINT)
                                         ,StageLastUpdated    = @dt
                                         ,StageLastUpdatedBy  = @Username
                                  OUTPUT INSERTED.MasterID
                                         ,ISNULL(DELETED.StageID,0)
                                         ,CAST(InfoDeltas.ItemValue AS TINYINT) 
                                  INTO   @AuditStageID
                           FROM          @Asset a 
                           CROSS JOIN    @InfoDeltas InfoDeltas
                           WHERE         InfoDeltas.ItemID = 0 
                                  AND    a.JobID                           = @JobID
                                  AND    InfoDeltas.JobID           = @JobID
                                  AND    InfoDeltas.DeltaType       = 'Update'
                                  AND    dbo.AssetStatus.MasterID   = a.MasterID
                                  AND    dbo.AssetStatus.StageID           != CAST(InfoDeltas.ItemValue AS INT)
                        

                           INSERT INTO   dbo.AssetStageHistory (MasterID, StageIDPrevious, StageID, ChangeDate, Username ,UserGroupCode, SequenceNo)
                                  OUTPUT INSERTED.AssetStageHistoryID
                                         ,INSERTED.MasterID
                                         ,INSERTED.SequenceNo 
                                  INTO   @AssetStageHistoryID
                           SELECT        DISTINCT 
                                         MasterID
                                         ,StageIDPrevious
                                         ,StageID
                                         ,@dt
                                         ,@Username
                                         ,@UserGroupCode
                                         ,ISNULL((SELECT MAX(SequenceNo) FROM AssetStageHistory WITH (NOLOCK) WHERE MasterID = asi.MasterID),0) + 1
                           FROM          @AuditStageID asi


                           UPDATE        dbo.AssetStageHistory
                                  SET    EndDate                           = @dt
                           FROM          dbo.AssetStageHistory WITH (NOLOCK)
                           JOIN          @AssetStageHistoryID ashi
                                  ON     AssetStageHistory.MasterID = ashi.MasterID
                                  AND    AssetStageHistory.SequenceNo      = ashi.SequenceNo - 1
                         
                           UPDATE        dbo.AssetStatus
                                  SET    AssetStageHistoryID        = ashi.AssetStageHistoryID
                           FROM          dbo.AssetStatus WITH (NOLOCK)
                           JOIN          @AssetStageHistoryID ashi
                                  ON     ashi.MasterID              = AssetStatus.MasterID


                           INSERT INTO   @AssetsTouched (MasterID, KeywordsUpdated)
                           SELECT        DISTINCT 
                                         MasterID
                                         ,@KEYWORDS_NOT_UPDATED
                           FROM          @AuditStageID


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
                     --     WHERE (isnull(dbo.AssetKeyword.Weight, 0) <> isnull(KeywordDeltas.Weight, 0) OR dbo.AssetKeyword.Confidence <> 5)

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
                     SELECT        @duration = DATEDIFF(ss, @dtStart, GETDATE())
                                  ,@assetcount = COUNT(*) 
                     FROM          @Asset 
                     WHERE         resultcode = 0
                           AND    JobID = @JobID
                     
                     SELECT        @keywordcount = COUNT(*) 
                     FROM          @InfoDeltas
                     WHERE         JobID = @JobID
                     
                     SELECT        @keywordcount = @keywordCount + COUNT(*) 
                     FROM          @KeywordDeltas
                     WHERE         JobID = @JobID

                     EXEC dbo.LogEvent 
                           @duration = @duration
                           , @assetcount = @assetcount -- show # assets attempted (that exist), not # actually processed by db, FAST indexer, or Vitria
                           , @keywordcount = @keywordcount
                           , @loglevel = 20
                           , @username = @username
                           , @eventType = @eventType
                     -- ===============================================

                     -- SET TO COMPLETED
                     --RAISERROR('Job Completed',-1,-1)WITH NOWAIT
                     
                     UPDATE        dbo.AssetDeltaJob 
                           SET    JobStatus     = 'Completed'
                                  ,TriesRemaining      = 0
                                  ,UpdatedDate  = GETDATE()
                                  --,AssetDeltasXML      = NULL
                     WHERE         JobID = @JobID
                  END TRY
                  BEGIN CATCH

                     -------------------------------------------
                     -- Error handler
                     -------------------------------------------
                     -- Log error

                           SELECT        @ErrMsg              = ERROR_MESSAGE(),
                                         @ErrSeverity  = ERROR_SEVERITY(),
                                         @duration     = DATEDIFF(ss, @dtStart, GETDATE())

                           EXEC dbo.LogEvent 
                                  @duration = @duration,
                                  @loglevel = 5,
                                  @username = 'SaveAssetDeltasJob',
                                  @eventType = 'SaveAssetDeltas',
                                  @eventData = @ErrMsg

                           -- SET TO RETRYING OR FAILED
                           RAISERROR('Job Failed',-1,-1)WITH NOWAIT
                           RAISERROR(@ErrMsg,-1,-1)WITH NOWAIT

                           UPDATE        dbo.AssetDeltaJob 
                                  SET    JobStatus     = CASE WHEN TriesRemaining > 1 THEN 'Retrying' ELSE 'Failed' END
                                         ,TriesRemaining      = CASE WHEN TriesRemaining > 1 THEN TriesRemaining - 1 ELSE 0 END
                                         ,UpdatedDate  = GETDATE()
                           WHERE         JobID = @JobID

                           CONTINUE
                  END CATCH
              
              END
              FETCH NEXT FROM test_cursor INTO @JobID, @Username, @UserGroupCode
       END

       CLOSE test_cursor
       DEALLOCATE test_cursor

GOTO BatchStart




-------------------------------------------
-- Normal exit
-------------------------------------------
NormalExit:
       IF OBJECT_ID('TEMPDB..#AssetsToIndex','U') IS NOT NULL DROP TABLE #AssetsToIndex
       --RETURN 0
GO

