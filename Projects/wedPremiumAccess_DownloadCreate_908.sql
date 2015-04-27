USE [WCDS]
GO

/****** Object:  StoredProcedure [dbo].[wedPremiumAccess_DownloadCreate_908]    Script Date: 10/27/2011 13:42:03 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[wedPremiumAccess_DownloadCreate_908]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[wedPremiumAccess_DownloadCreate_908]
GO

USE [WCDS]
GO

/****** Object:  StoredProcedure [dbo].[wedPremiumAccess_DownloadCreate_908]    Script Date: 10/27/2011 13:42:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[wedPremiumAccess_DownloadCreate_908] 
	@DownloadID            		int,
	@vchImageString	        	varchar(1000),
	@IndividualId          		int,
	@CompanyId             		int,
	@CompanyTypeId	        	int,
	@vchImageSizeString			varchar(1000),
	@vchDownloadSourceID		varchar(1000),
	@vchSourceDetailID 			varchar(1000),
	@StatusID	        		int,
	@vchCollectionID 			varchar(1000),
	@vchCollectionName			nvarchar(1000),
	@vchImageTitle				nvarchar(4000),
	@vchPhotographerName		nvarchar(1000),
	@vchImageSource				varchar(1000),
	@OrderDetailID	        	int, -- Default must be NULL,
	@Notes						nvarchar(4000) = NULL,
	@ProjectCode				nvarchar(2000) = NULL,
	@bundleIds					varchar(1000),
	@mediaTypeIds				varchar(1000),
	@oiErrorID              	int = 0 	OUTPUT,
	@ovchErrorMessage       	varchar(256) = '' 	OUTPUT
AS

	SET XACT_ABORT ON
		
	-- Establish error handling variables

    DECLARE	
        @iError                         int,
        @iReturnStatus                  int,
        @Error_Insert_Failed            varchar(50),
        @Error_Unspecified              varchar(50),
		@Error_DownloadNotExists		varchar(50),
        @CurrentError                   varchar(50)

    SELECT
        @iError                          = 0,
        @Error_Insert_Failed             = 'Insert_Failed',
        @Error_Unspecified               = 'Unspecified',
		@Error_DownloadNotExists		 = 'DownloadNotExists',
        @CurrentError                    = @Error_Unspecified

    -- Local variables
    DECLARE
        @ImageId              		nvarchar(50),
        @ImageSize					tinyint,
		@SourceDetailID				int,
		@CollectionID				int,
		@CollectionName				nvarchar(50),
		@ImageTitle					nvarchar(256),
		@PhotographerName			nvarchar(256),
		@ImageSource				nvarchar(50),
		@DownloadSourceID			int,
		@DownloadNotes				nvarchar(256),
		@DownloadProjectCode		nvarchar(35),
		@bundleId					int,
		@mediaTypeId					int,
		@Sep						char(1),
		@DownloadDetailId			int,
		@currentValue				int,
		@newCurrentValue			int,
		@premiumAccessLogId			int,
		@date						datetime,
		@isContactLevelAgreement	bit


	-- Check if DownloadID is valid
	IF NOT EXISTS (SELECT * FROM Download WITH(NOLOCK) WHERE DownloadID = @DownloadID)
	BEGIN
		SELECT @CurrentError = @Error_DownloadNotExists
		GOTO ErrorHandler
	END
 
    -- Parse image ids and sizes into the temp table
    SET @vchImageString = @vchImageString + ','
    SET @vchImageSizeString = @vchImageSizeString + ','
    SET @vchDownloadSourceID = @vchDownloadSourceID + ','
    SET @vchSourceDetailID = @vchSourceDetailID + ','
    SET @vchCollectionID = @vchCollectionID + ','
	SET @vchCollectionName = @vchCollectionName + ','
	SET @vchImageTitle = @vchImageTitle + ','
	SET @vchPhotographerName = @vchPhotographerName + ','
	SET @vchImageSource = @vchImageSource + ','
	SET @bundleIds = @bundleIds + ','
	set @mediaTypeIds = @mediaTypeIds + ','
	SET @Sep = CHAR(9) -- tab
	SET @Notes = @Notes + @Sep
	SET @ProjectCode = @ProjectCode + @Sep

	--iterate over all of the premium access downloads in this batch and do inserts as necessary
    WHILE @vchImageString <> ''
    BEGIN
		--read this record into local variables.
		SET @ImageId = LTRIM(CAST(SUBSTRING(@vchImageString,1,CHARINDEX(',', @vchImageString)-1) AS NVARCHAR(50)))
		SET @vchImageString = SUBSTRING(@vchImageString,CHARINDEX(',', @vchImageString) + 1, LEN(@vchImageString))
   		SET @ImageSize = CAST(SUBSTRING(@vchImageSizeString,1,CHARINDEX(',', @vchImageSizeString)-1) AS INT)      
		SET @vchImageSizeString = SUBSTRING(@vchImageSizeString,CHARINDEX(',', @vchImageSizeString) + 1, LEN(@vchImageSizeString))
		SET @DownloadSourceID = CAST(SUBSTRING(@vchDownloadSourceID,1,CHARINDEX(',', @vchDownloadSourceID)-1) AS INT)
		SET @vchDownloadSourceID = SUBSTRING(@vchDownloadSourceID,CHARINDEX(',', @vchDownloadSourceID) + 1, LEN(@vchDownloadSourceID))
		SET @SourceDetailID = CAST(SUBSTRING(@vchSourceDetailID,1,CHARINDEX(',', @vchSourceDetailID)-1) AS INT)
		SET @vchSourceDetailID = SUBSTRING(@vchSourceDetailID,CHARINDEX(',', @vchSourceDetailID) + 1, LEN(@vchSourceDetailID))
		SET @CollectionID = CAST(SUBSTRING(@vchCollectionID,1,CHARINDEX(',', @vchCollectionID)-1) AS INT)
		SET @vchCollectionID = SUBSTRING(@vchCollectionID,CHARINDEX(',', @vchCollectionID) + 1, LEN(@vchCollectionID))
		SET @CollectionName = CAST(SUBSTRING(@vchCollectionName,1,CHARINDEX(',', @vchCollectionName)-1) AS NVARCHAR(50))
		SET @vchCollectionName = SUBSTRING(@vchCollectionName,CHARINDEX(',', @vchCollectionName) + 1, LEN(@vchCollectionName))
		SET @ImageTitle = CAST(SUBSTRING(@vchImageTitle,1,CHARINDEX(',', @vchImageTitle)-1) AS NVARCHAR(256))
		SET @vchImageTitle = SUBSTRING(@vchImageTitle,CHARINDEX(',', @vchImageTitle) + 1, LEN(@vchImageTitle))
		SET @PhotographerName = CAST(SUBSTRING(@vchPhotographerName,1,CHARINDEX(',', @vchPhotographerName)-1) AS NVARCHAR(50))
		SET @vchPhotographerName = SUBSTRING(@vchPhotographerName,CHARINDEX(',', @vchPhotographerName) + 1, LEN(@vchPhotographerName))
		SET @ImageSource = CAST(SUBSTRING(@vchImageSource,1,CHARINDEX(',', @vchImageSource)-1) AS NVARCHAR(50))
		SET @vchImageSource = SUBSTRING(@vchImageSource,CHARINDEX(',', @vchImageSource) + 1, LEN(@vchImageSource))
		SET @DownloadNotes = CAST(SUBSTRING(@Notes,1,CHARINDEX(@Sep, @Notes)-1) AS NVARCHAR(256))
		SET @Notes = SUBSTRING(@Notes,CHARINDEX(@Sep, @Notes) + 1, LEN(@Notes))
		SET @DownloadProjectCode = CAST(SUBSTRING(@ProjectCode,1,CHARINDEX(@Sep, @ProjectCode)-1) AS NVARCHAR(35))
		SET @ProjectCode = SUBSTRING(@ProjectCode,CHARINDEX(@Sep, @ProjectCode) + 1, LEN(@ProjectCode))
		SET @bundleId = CAST(SUBSTRING(@bundleIds,1,CHARINDEX(',', @bundleIds)-1) AS INT)
		SET @mediaTypeId = CAST(SUBSTRING(@mediaTypeIds,1,CHARINDEX(',', @mediaTypeIds)-1) AS INT)
		
    	--set defaults
		SELECT @DownloadDetailId = null, @currentValue = null, @newCurrentValue	= null,  @premiumAccessLogId = null, @date	= getdate()

		-- *******************BEGIN PREMIUM ACCESS DATA INSERTS*******************************

		--CHECK TO SEE IF THIS IMAGE HAS BEEN DOWNLOADED FOR THIS AGREEMENT BEFORE
		SELECT @DownloadDetailId = downloaddetailid from dbo.DownloadDetail WITH(NOLOCK) where imageid = @ImageId and SourceDetailID = @SourceDetailID and StatusId = 950
		
		--If a download detail record does not exist for this image and for this agreement create a new one and charge it against the customers count
		--otherwise just log a transactional record
		BEGIN TRANSACTION

		if(@downloadDetailId is null)
		BEGIN

			--insert the download detail record
			INSERT INTO DownloadDetail
			(
				DownloadID, ImageID, IndividualId,	CompanyId, CompanyTypeId, ImageSizeExternalID,
				DownloadSourceID, SourceDetailID, StatusID,	CollectionID, CollectionName, ImageTitle,
				PhotographerName, StatusModifiedBy, StatusModifiedDateTime,	ImageSource, OrderDetailID
			)
			SELECT
				@DownloadID, @ImageId, @IndividualId, @CompanyId, @CompanyTypeId, @ImageSize,
				@DownloadSourceId, @SourceDetailID, 950, @CollectionID, @CollectionName, @ImageTitle,
				@PhotographerName, @IndividualId, getdate(), @ImageSource, @OrderDetailID
			
			SELECT @iError = @@ERROR

			IF @iError <> 0
			BEGIN
				ROLLBACK TRANSACTION	
				SELECT @CurrentError = @Error_Insert_Failed
				GOTO ErrorHandler
			END

			SELECT @DownloadDetailId = @@identity
			
			--insert a PremiumAccessDownloadLog record
			SELECT @DownloadProjectCode = ltrim(rtrim(@DownloadProjectCode))
			SELECT @DownloadNotes = ltrim(rtrim(@DownloadNotes))
			
			INSERT INTO dbo.PremiumAccessDownloadLog (DownloadId, DownloadDetailId, SubscriptionAgreementId, IndividualId, DownloadDate, StatusUpdatedDate, [Status], 
			Duplicate, BundleId, MediaTypeId,Notes,ProjectCode)
			VALUES(@DownloadID, @DownloadDetailId, @SourceDetailID, @IndividualId, @date, @date, 950, 0, @bundleId, @mediaTypeId,@DownloadNotes,@DownloadProjectCode)
			
			SELECT @iError = @@ERROR

			IF @iError <> 0
			BEGIN
				ROLLBACK TRANSACTION
				SELECT @CurrentError = @Error_Insert_Failed
				GOTO ErrorHandler
			END
			
			SELECT @premiumAccessLogId = @@identity
			
			--now read the value of the current count in the subscription and update it.
			EXEC wedPremiumAccess_IncrementAgreementCount 	@IndividualId,
														    @SourceDetailID, 
															@currentValue OUTPUT, 
															@newCurrentValue OUTPUT, 
															@isContactLevelAgreement OUTPUT
  
			SELECT @iError = @@ERROR

			IF @iError <> 0
			BEGIN
				ROLLBACK TRANSACTION
				SELECT @CurrentError = @Error_Insert_Failed
				GOTO ErrorHandler
			END
			
			--using the values we just calculated, track this download in the premiumaccesscount table.
			INSERT INTO dbo.PremiumAccessCountDetail (PremiumAccessDownloadLogId, SubscriptionAgreementId, DownloadDetailId, IndividualId, IsContactLevelAgreement, OldCurrentValue, NewCurrentValue)
			VALUES (@premiumAccessLogId, @SourceDetailID, @DownloadDetailId, @IndividualId, @isContactLevelAgreement, @currentValue, @newCurrentValue)
			
			SELECT @iError = @@ERROR

			IF @iError <> 0
			BEGIN
				ROLLBACK TRANSACTION
				SELECT @CurrentError = @Error_Insert_Failed
				GOTO ErrorHandler
			END
			
			--Tell vitria that we have a new download that should trigger a royalty payment
			EXEC VitriaEventMsg 100, @DownloadDetailId, 'Insert', 'DownloadDetail'
			
		END
		ELSE --already have a download detail, so just log a transactional record
			BEGIN
				SELECT @DownloadProjectCode = ltrim(rtrim(@DownloadProjectCode))
				SELECT @DownloadNotes = ltrim(rtrim(@DownloadNotes))
				
				INSERT INTO dbo.PremiumAccessDownloadLog (DownloadId, DownloadDetailId, SubscriptionAgreementId, IndividualId, DownloadDate, StatusUpdatedDate,
				 [Status], Duplicate, BundleId, MediaTypeId,Notes,ProjectCode)
				VALUES(@DownloadID, @DownloadDetailId, @SourceDetailID, @IndividualId, @date, @date, 950, 1, @bundleId, @mediaTypeId,@DownloadNotes,@DownloadProjectCode)
			END
	
		--insert downloads notes.
		SELECT @DownloadNotes = ltrim(rtrim(@DownloadNotes))
		
		IF(len(@DownloadNotes) > 0)
		BEGIN
			--if download notes exist, update existing data
			IF EXISTS(SELECT DownloadDetailId FROM DownloadDetailNote WITH(NOLOCK) where DownloadDetailId = @downloadDetailId)
				BEGIN
					UPDATE DownloadDetailNote
					SET Notes = @DownloadNotes, ModifiedBy = @IndividualId,ModifiedDateTime = getdate()
					WHERE DownloadDetailId = @downloadDetailId
				END
			ELSE 
				BEGIN
					--  insert only download with notes
					INSERT INTO DownloadDetailNote(DownloadDetailId,Notes,CreatedBy,CreatedDateTime,ModifiedBy,ModifiedDateTime)
					SELECT @downloadDetailId, @DownloadNotes,@IndividualId,getdate(),@IndividualId,getdate()
				END
			
			IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRANSACTION
				SELECT @CurrentError = @Error_Insert_Failed
				GOTO ErrorHandler
			END
		END
		--  insert project code (if set) for PA downloads
		SELECT @DownloadProjectCode = ltrim(rtrim(@DownloadProjectCode))
		IF(len(@DownloadProjectCode) > 0)
		BEGIN
			--if project code exists update the existing data
			IF EXISTS(SELECT DownloadDetailId FROM DownloadDetailProjectCode WITH(NOLOCK) where DownloadDetailId = @downloadDetailId)
				BEGIN
					UPDATE DownloadDetailProjectCode
					SET ProjectCode = @DownloadProjectCode, ModifiedBy = @IndividualId, ModifiedDateTime = getdate()
					WHERE DownloadDetailId = @downloadDetailId
				END
			ELSE
				BEGIN
					INSERT INTO DownloadDetailProjectCode(DownloadDetailId,ProjectCode,CreatedBy,CreatedDateTime,ModifiedBy,ModifiedDateTime)
					SELECT @downloadDetailId, @DownloadProjectCode,@IndividualId,getdate(),@IndividualId,getdate()
				END
			

			IF @@Error <> 0
			BEGIN
				ROLLBACK TRANSACTION
				SELECT @CurrentError = @Error_Insert_Failed
				GOTO ErrorHandler
			END	
		END
    END -- end loop
    
    COMMIT TRANSACTION
    
RETURN 0
-------------------------------------------
-- Error handler
-------------------------------------------
ErrorHandler:
-- call error-lookup proc, filling OUTPUT parameters

select @CurrentError

EXECUTE @iReturnStatus = wedGetErrorInfo
	@CurrentError,
	@oiErrorID OUTPUT,
	@ovchErrorMessage OUTPUT

IF @iReturnStatus <> 0
BEGIN
	SELECT	@oiErrorID = -999
	SELECT	@ovchErrorMessage = 'Call to wedGetErrorInfo failed with ' + @CurrentError + '; ' + convert(char(30),getdate())
END

RETURN  -999


GO

GRANT EXECUTE ON [dbo].[wedPremiumAccess_DownloadCreate_908] TO [role_oneuser] AS [dbo]
GO


