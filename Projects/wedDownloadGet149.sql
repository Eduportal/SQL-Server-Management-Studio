USE [WCDS]
GO

/****** Object:  StoredProcedure [dbo].[wedDownloadGet149]    Script Date: 10/27/2011 14:52:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[wedDownloadGet149]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[wedDownloadGet149]
GO

USE [WCDS]
GO

/****** Object:  StoredProcedure [dbo].[wedDownloadGet149]    Script Date: 10/27/2011 14:52:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[wedDownloadGet149]
(
	@IndividualId		INT				= 0,
	@CompanyId			INT				= 0,
	@PerspectiveFilter	INT				= 0,
	@SiteId				INT				= 0,
	@StartDate			DATETIME 		= null,
	@EndDate			DATETIME 		= null, 
	@DownloadFilter		INT				= 0,
	@PurchasedFilter	INT				= 0,
	@CrossSitePAandEZA  tinyint			= 0,        --flag is used for Editorial Sub also besides PA and EZA
	@PageNumber			INT 			= 1,
	@ResultsPerPage		INT 			= 30,
	@SortBy				INT 			= 0,
	@SortDirection		INT 			= 0,
	@AssetIdList        Varchar(1000)   = '',
	@TotalRows			INT 			= 0 	output,
	@TotalPages			INT 			= 0 	output,
	@CurrentPage		INT 			= 0		output,
	@oiErrorID			INT 			= 0 	output,
	@ovchErrorMessage	VARCHAR(256) 	= '' 	output
)
AS
BEGIN

/* ---------------------------------------------------------------------------
--	Procedure: wedDownloadGet149
--
--	Revision History
--	Created 	09/28/04	Anne Pau
--				Move FROM GSSearch
--	Modified	10/07/04   Anne Pau
--				Add @DownloadFilter AS input parameter
--  Modified	11/23/2004  Anne Pau
--				Add Download Notes, UserName to recordset
--	Modified	12/2/04   Anne Pau
--				Add @PurchasedFilter input parameter
--	Modified	04/04/05   John Boen
--				"redundant specification" of company ID IN query.  
--				Hopefully will pick up better index.
--	Modifed		09/05/07	Wade Holt
--				cleaned up AND formated code IN general for readability
--				added "SET NOCOUNT ON" to beginning of proc to eliminate extra round-trip
--					to front-END caller. removed this cause not sure WHEN to use it!
--				replace #Summary temporary TABLEwith @Summary SQL TABLEVariable
--				replace #DownloadSummaryWork temporary TABLEwith @DownloadSummaryWork SQL TABLEVariable
--				removed all uses of "SELECT ... INTO ... FROM"
--				added fully qualified owner name to all object references (ie. append "dbo."
--					IN front of all TABLEnames)
--				keep NOCOUNT ON for duration of procedure
--	Modified	11/14/08	Matthew Potter
--				Added additional DownloadFilter value check to support Premium Access
--	Modified	9/22/10		matthew potter
--				Branched from wedDownloadGet (unversioned)
--				Drastically improved query times
--				is provided via another report (just dups for a single asset in a report)
-- Modified		Added optional parameter for filtering based on a comma seperated assetId list 
-- Modified		Added auth check when company perspective is requested 
--  Modified    8/2/2011  Jagdeep Sihota and Lisa Guo
--              To return PA and EZA cross site downloads 
--
--	Purpose:
--	Retrieves image download history.
--
--	Returns:
--
--	Output variables:
--		@totalRows - Number of rows IN complete history SET
--		@totalPages - Number of pages required to display SET
--		@currentPage - current page returned
--
--		0	:	Success
--		999	:	Can't find user
--		Other	:	Other SQL error
--
--------------------------------------------------------------------------- */

	-- Turn ON NOCOUNT until final SELECT. ADO doesn't want to see
	-- multiple rowsets returned.
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @DownloadsOfInterest TABLE
	(
		DownloadId			INT PRIMARY KEY,
		SiteId			INT
	)

	DECLARE @DownloadDetails TABLE
	(
		RowNumber			INT IDENTITY(1,1),
		DownloadDetailId	INT PRIMARY KEY
	)

	DECLARE @DownloadDetails2 TABLE
	(
		RowNumber			INT IDENTITY(1,1),
		PageNumber			INT,
		DownloadDetailId	INT PRIMARY KEY
	)
		
	DECLARE @DuplicateImages TABLE
	(
		DownloadDetailId	INT PRIMARY KEY,
		ImageID				NVARCHAR(50),
		[Count]				INT
	)

	DECLARE
		@RowCount					INT,
		@iError						INT,
		@iReturnStatus				INT,
		@ErrorId_UnAuthorized		INT,
		@Error_UnAuthorized			VARCHAR(50),
		@Error_Unspecified			VARCHAR(50),
		@CurrentError				VARCHAR(50),
		@TempString					VARCHAR(4000),
		@MAXRowcount				INT,
		@DupsCount					INT,
		@TotalRowsNoDups			INT

	SELECT
		@RowCount					= 0,
		@iError						= 0,
		@ErrorId_UnAuthorized		= 100,
		@Error_Unspecified			= 'Unspecified',
		@Error_UnAuthorized			= 'UnAuthorized',
		@CurrentError				= @Error_Unspecified,
		@MAXRowcount				= 1000,
		@DupsCount					= 0,
		@TotalRowsNoDups			= 0

	DECLARE
		@cstart				DATETIME,
		@cend				DATETIME,
		@minRow				INT,
		@maxRow				INT,
		@startRow			INT,
		@endRow				INT,
		@num				INT

	-- If company perspective, ensure customer is allowed to view company downloads.
	IF @PerspectiveFilter = 1
	BEGIN			
		IF NOT EXISTS
		(
			SELECT 1
			FROM IndividualPreference
			WHERE iIndividualID = @IndividualID AND vchXMLstring LIKE '%key="KAHISTORYACCESS" value="1"%'
		)
		BEGIN
		  SELECT
			@oiErrorID = @ErrorId_UnAuthorized,
			@ovchErrorMessage = @Error_UnAuthorized
			GOTO ErrorHandler
		END
	END

	-- IF the parameter of @StartDate is null, THEN DEFAULT it to an early DATETIME
	IF (@StartDate is null) OR (@StartDate = '')
		SET @StartDate = '1/1/2000'

	-- IF the parameter of @DateEnd is null, THEN DEFAULT it to now
	IF (@EndDate is null) OR (@EndDate = '')
		SET @EndDate = getdate()

	-- Add 1 day to get dates that have a time portion
	SET @EndDate = dateadd(dd,1,@EndDate)	
	
	SET @num = 0
	---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=


	---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	-- Get DownloadID rows we are probably interested in for company AND/OR individual
	IF @PerspectiveFilter = 1
	BEGIN
		INSERT	@DownloadsOfInterest (DownloadId, SiteId)
		SELECT		DISTINCT d.DownloadID, d.SiteId
		FROM		dbo.Download (NOLOCK) d
		WHERE		d.CreatedDate	>= @StartDate 
			AND		d.CreatedDate	<= @EndDate
			AND		d.SiteID		=  CASE
										WHEN @SiteID = 0				THEN d.SiteID
										WHEN @CrossSitePAandEZA = 1		THEN d.SiteID
										ELSE @SiteID
										END
			AND		DownloadID IN	(
									SELECT		DownloadID
									FROM		dbo.DownloadDetail WITH(NOLOCK)
									WHERE		CompanyID = @CompanyId
										AND		StatusModifiedDateTime >= @StartDate
										AND		StatusModifiedDateTime <= @EndDate
									)		

		SELECT	@Rowcount = @@ROWCOUNT
		PRINT 'Only companyId - found ' + STR(@RowCount) + ' rows.'
	END
	ELSE --IF @PerspectiveFilter = 0
	BEGIN
		INSERT	@DownloadsOfInterest (DownloadId, SiteId)
		SELECT		DISTINCT d.DownloadID, d.SiteId
		FROM		dbo.Download (NOLOCK) d
		WHERE		d.CreatedDate	>= @StartDate 
			AND		d.CreatedDate	<= @EndDate
			AND		d.SiteID		=  CASE
										WHEN @SiteID = 0				THEN d.SiteID
										WHEN @CrossSitePAandEZA = 1		THEN d.SiteID
										ELSE @SiteID
										END
			AND		DownloadID IN	(
									SELECT		DownloadID
									FROM		dbo.DownloadDetail WITH(NOLOCK)
									WHERE		IndividualID = @IndividualId
										AND		StatusModifiedDateTime >= @StartDate
										AND		StatusModifiedDateTime <= @EndDate
									)

		SELECT @Rowcount = @@ROWCOUNT
		PRINT 'only individualId - found ' + STR(@RowCount) + ' rows.'
	END
	
	---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    -- Remove downloads from different sites for other types then Editorial Subscription, EZA and PA 
    -- with crossSitePAand EZA Flag is set to 1
	---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	IF (@SiteID <> 0 AND @CrossSitePAandEZA = 1)
	BEGIN
		DELETE		@DownloadsOfInterest 
		FROM		@DownloadsOfInterest  d
		JOIN		dbo.DownloadDetail  dd
			ON		d.DownloadID = dd.DownloadID 
			AND		dd.StatusModifiedDateTime >= @StartDate
			AND		dd.StatusModifiedDateTime <= @EndDate			
			AND		dd.DownloadSourceID NOT IN (3100,3101,3103)
		WHERE		d.SiteID <> @SiteID
		
        SELECT @Rowcount = @@ROWCOUNT
		PRINT 'Numbers of rows after ' + STR(@RowCount) + ' rows.'
	END

	---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	
	-- Get the DownloadDetailID for all the rows we are interested in, sorted in the manner
	-- we need (unbounded)

	-- Prepare for search on asset id list
	SET @AssetIdList = ',' + @AssetIdList + ','

	INSERT INTO	@DownloadDetails (DownloadDetailID)
	SELECT		DownloadDetailId
				--,[SortColumn]
	FROM		(
				SELECT		dd.DownloadDetailId
							,CASE @SortBy
							WHEN 0  THEN CAST(o.DownloadID AS SQL_VARIANT)			
							WHEN 1  THEN CAST(o.DownloadID AS SQL_VARIANT)			
							WHEN 2  THEN CAST(dd.ImageID AS SQL_VARIANT)			
							WHEN 4  THEN CAST(dd.CollectionName AS SQL_VARIANT)		
							WHEN 6  THEN CAST(dd.PhotographerName AS SQL_VARIANT)	
							WHEN 8  THEN CAST(i.vchUserName AS SQL_VARIANT)			
							WHEN 10 THEN CAST(b.MediaType AS SQL_VARIANT)			
							END AS [SortColumn]

				FROM		@DownloadsOfInterest o
				JOIN		dbo.DownloadDetail (NOLOCK) dd	
					ON		o.DownloadID = dd.DownloadID
					AND		dd.StatusModifiedDateTime >= @StartDate
					AND		dd.StatusModifiedDateTime <= @EndDate
					AND		dd.StatusID NOT IN (951,954)
					
					AND		dd.DownloadSourceID = 
							CASE @DownloadFilter 
								WHEN 0 THEN ISNULL (dd.DownloadSourceID,0)	-- DEFAULT to returns everything
								WHEN 4 THEN ISNULL (dd.DownloadSourceID,0)	-- returns everything 
								WHEN 1 THEN 3100							-- editorial subscription download
								WHEN 2 THEN 3101							-- easy access download
								WHEN 3 THEN 3102							-- RF subscription download (NO LONGER AVAILABLE ON GI.COM SINCE CE SHUTDOWN - 07/2010)
								WHEN 5 THEN 3103							-- Premium Access download
								WHEN 6 THEN 3104							-- Royalty-Free Subscription - (used by Thinkstock)
								WHEN 7 THEN 3105							-- Image Pack download - (used by Thinkstock)
							END
					AND		ISNULL (dd.OrderID,0) =
							CASE @PurchasedFilter
								WHEN 1 THEN ISNULL (dd.OrderID,0)			-- returns everything
								WHEN 2 THEN COALESCE (dd.OrderID,dd.OrderID)-- returns only purchased 
								WHEN 3 THEN 0
							END			
				JOIN		dbo.Individual (NOLOCK) i 
					ON		dd.IndividualId = i.iIndividualId
				Left Join	Brand b 
					ON		dd.CollectionID = b.iBrandId

				WHERE		@AssetIdList = ',,' 
					OR		CHARINDEX(',' + dd.ImageId + ',', @AssetIdList) > 0
				) Data
	ORDER BY	CASE @SortDirection	
						WHEN 0 THEN (RANK() OVER (ORDER BY [SortColumn] ASC))
							   ELSE (RANK() OVER (ORDER BY [SortColumn] DESC))
				END
				,CASE @SortDirection	
						WHEN 0 THEN DownloadDetailId 
							   ELSE (DownloadDetailId * -1)
				END
				
				
				 
	---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	
	SET @TotalRows = @@ROWCOUNT

	---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	-- Get EZA duplicate download counts
	IF @DownloadFilter = 0 OR @DownloadFilter = 2
	BEGIN
		INSERT INTO @DuplicateImages
		(
			DownloadDetailId,
			ImageID,
			[Count]
		)
		SELECT
			MAX(t.DownloadDetailId),
			dd.ImageID,
			CASE
				WHEN Count(dd.ImageID) > 0 THEN Count(dd.ImageID) - 1
				ELSE 0
			END
		FROM		@DownloadDetails t
		JOIN		dbo.DownloadDetail dd (nolock) 
			ON		t.DownloadDetailID = dd.DownloadDetailID
			AND		dd.StatusModifiedDateTime >= @StartDate
			AND		dd.StatusModifiedDateTime <= @EndDate
		GROUP BY	dd.ImageID
		
		SET @DupsCount = @@ROWCOUNT
	END
	
		
	--PRINT 'Inserted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows into @DuplicateImages table.'
	---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

	-- Remove irrelevant download details from the list
	IF (@DupsCount >0)
	BEGIN		
		DELETE		dd
		FROM		@DownloadDetails dd 
		LEFT JOIN	@DuplicateImages dups 
			ON		dd.DownloadDetailId = dups.DownloadDetailId
		WHERE		dups.DownloadDetailId IS NULL
	END

	INSERT INTO	@DownloadDetails2 (DownloadDetailID)
	SELECT		DownloadDetailID
	FROM		@DownloadDetails
	ORDER BY	RowNumber
	
	SET @TotalRowsNoDups = @@ROWCOUNT
	
	UPDATE @DownloadDetails2
	SET PageNumber = (RowNumber/@ResultsPerPage)  + CASE WHEN RowNumber%@ResultsPerPage = 0 THEN 0 ELSE 1 END
	
	---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	IF @ResultsPerPage = 0 BEGIN
		SET @ResultsPerPage	= @TotalRows
		SET @PageNumber		= 1	
	END

	-- Check for condition where all rows are returned on a single 
	-- page. Otherwise, calculate the total pages and set the current page.

	IF @TotalRowsNoDups = @ResultsPerPage BEGIN
		SET @TotalPages		= 1
		SET @CurrentPage	= 1
	END
	ELSE
	BEGIN
		SET @TotalPages		= (@TotalRowsNoDups/@ResultsPerPage)  + CASE WHEN @TotalRowsNoDups%@ResultsPerPage = 0 THEN 0 ELSE 1 END
		SET @CurrentPage	= @PageNumber
	END


	SELECT
		dd.DownloadDetailID,
		dd.DownloadID,
		dd.ImageID,
		dd.IndividualId,
		dd.CompanyId,
		dd.CompanyTypeID,
		dd.ImageSizeExternalID,
		dd.DownloadSourceID,
		dd.SourceDetailID,
		dd.StatusID,
		dd.OrderID,
		dd.OrderDetailID,
		dd.CollectionID,
		dd.CollectionName,
		REPLACE(ISNULL (dd.ImageTitle, ""),N'|',N',') as [ImageTitle],
		dd.PhotographerName,
		dd.ImageSource,
		d.CreatedDate as DateCreated,
		CAST (dn.Notes AS NVARCHAR(100)) as [Notes],
		i.vchUserName,
		ISNULL (sa.IsNoteRequired, 0) as [IsNoteRequired],
		ISNULL (sa.IsProjectCodeRequired, 0) as [IsProjectCodeRequired],
		CAST (dpc.ProjectCode AS NVARCHAR(70)) as [ProjectCode],
		ISNULL (dups.count, 0) as 'Count',
		b.MediaType,
		d.SiteId
	FROM		@DownloadDetails2 tdd
	JOIN		dbo.DownloadDetail (NOLOCK) dd 
		ON		tdd.DownloadDetailID = dd.DownloadDetailID
		AND		dd.StatusModifiedDateTime >= @StartDate
		AND		dd.StatusModifiedDateTime <= @EndDate
	JOIN		dbo.Download (NOLOCK) d 
		ON		d.DownloadID = dd.DownloadID
		AND		d.CreatedDate	>= @StartDate 
		AND		d.CreatedDate	<= @EndDate
	JOIN		dbo.Individual (NOLOCK) i 
		ON		i.iIndividualID = dd.IndividualID
	Left Join	Brand b 
		ON		dd.CollectionID = b.iBrandId
	LEFT JOIN	dbo.DownloadDetailNote (NOLOCK) dn 
		ON		dd.DownloadDetailID	= dn.DownloadDetailID
	LEFT JOIN	dbo.DownloadDetailProjectCode (NOLOCK) dpc 
		ON		dd.DownloadDetailId = dpc.DownloadDetailId
	LEFT JOIN	dbo.SubscriptionAgreement (NOLOCK) sa 
		ON		dd.SourceDetailId = sa.SubscriptionAgreementId
		AND		dd.DownloadSourceId = 3103
	LEFT JOIN	@DuplicateImages dups 
		ON		dd.DownloadDetailID = dups.DownloadDetailID

	WHERE		tdd.PageNumber = @PageNumber
	ORDER BY	tdd.RowNumber


	RETURN 0

	-------------------------------------------
	-- Error handler
	-------------------------------------------
	ErrorHandler:

	-- RETURN error
	RETURN -999

END


GO

GRANT EXECUTE ON [dbo].[wedDownloadGet149] TO [role_oneuser] AS [dbo]
GO


