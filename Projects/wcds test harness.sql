
DECLARE @CompanyId int
,@minRow int
,@maxRow int
,@StartDate datetime
,@EndDate datetime
,@SiteID int
,@CrossSitePAandEZA int
,@IndividualId INT
,@cstart DateTime
,@PerspectiveFilter int
,@DownloadFilter int
,@PurchasedFilter int
,@PageNumber int
,@ResultsPerPage int
,@SortBy int
,@SortDirection int
,@AssetIdList varchar(max)
,@num int
,@TotalRows int
,@TotalPages int
,@CurrentPage int
,@oiErrorID int
,@ovchErrorMessage varchar(256)


	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ANSI_NULLS ON
	SET ANSI_PADDING ON
	SET ANSI_WARNINGS ON
	SET ARITHABORT ON
	SET QUOTED_IDENTIFIER ON
	SET CONCAT_NULL_YIELDS_NULL ON
	SET XACT_ABORT ON


DECLARE	@Download TABLE
	(
	[DownloadID] [int] NOT NULL PRIMARY KEY,
	[SiteId] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[DownloadStatusID] [int] NOT NULL
	)

DECLARE	@DownloadDetail TABLE
	(
	[DownloadDetailID] [int] NOT NULL PRIMARY KEY,
	[DownloadId] [int] NOT NULL,
	[ImageID] [nvarchar](50) NOT NULL,
	[IndividualId] [int] NOT NULL,
	[CompanyId] [int] NOT NULL,
	[CompanyTypeId] [int] NOT NULL,
	[ImageSizeExternalID] [tinyint] NOT NULL,
	[DownloadSourceId] [int] NULL,
	[SourceDetailID] [int] NULL,
	[StatusID] [int] NOT NULL,
	[OrderID] [int] NULL,
	[CollectionID] [int] NULL,
	[CollectionName] [nvarchar](50) NULL,
	[ImageTitle] [nvarchar](256) NOT NULL,
	[PhotographerName] [nvarchar](256) NOT NULL,
	[StatusModifiedBy] [int] NOT NULL,
	[StatusModifiedDateTime] [datetime] NOT NULL,
	[ImageSource] [nvarchar](50) NOT NULL,
	[OrderDetailID] [int] NULL,
	[vchUserName] [nvarchar](40) NULL,
	[MediaType] [nvarchar](10) NULL,
	[SortColumn] SQL_VARIANT NULL
	)

	DECLARE @PreSortData TABLE
	(
		DownloadDetailId	INT,
		SortColumn			sql_variant
	)

	DECLARE @IndividualDownloads TABLE
	(
		DownloadId			INT PRIMARY KEY
	)
	
	DECLARE @DownloadsOfInterest TABLE
	(
		DownloadId			INT PRIMARY KEY,
		SiteId				INT
	)

	DECLARE @DownloadDetails TABLE
	(
		RowNumber			INT IDENTITY(1,1),
		RowId				INT,
		DownloadDetailId	INT
	)
	
	DECLARE @DownloadDetails2 TABLE
	(
		RowNumber			INT IDENTITY(1,1),
		PageNumber			INT,
		DownloadDetailId	INT PRIMARY KEY
	)
		
	DECLARE @DuplicateImages TABLE
	(
		DownloadDetailId	INT,
		ImageID				NVARCHAR(50),
		[Count]				INT
	)
/*	
	
SELECT		TOP 10 IndividualID
			,CompanyID
			,COUNT(*)
FROM		DownloadDetail WITH(NOLOCK)
GROUP BY	IndividualID
			,CompanyID
ORDER BY	3 desc
	

IndividualID	CompanyID	(No column name)
4619599			4619604		1435850
4680261			4506704		1036829
4784952			4784946		349578
2691384			2043079		246931
5509488			4549608		243208
440443			1202321		216732
4638385			3096475		203165
6073716			2157295		202872
6830774			4111716		195194
2630466			2630464		181355

*/	





	
SELECT @IndividualId=6073716,@CompanyId=2157295,@PerspectiveFilter=1,@SiteId=100,@StartDate='Aug  2 2011  9:58:40:793AM',@EndDate='Oct 31 2011  9:58:40:793AM'

,@DownloadFilter=0,@PurchasedFilter=1,@CrossSitePAandEZA=0

,@PageNumber=1,@ResultsPerPage=30,@SortBy=0,@SortDirection=0,@AssetIdList=''













---- TODO: Set parameter values here.

EXECUTE [WCDS].[dbo].[wedDownloadGet149] @IndividualId=2630466,@CompanyId=0,@PerspectiveFilter=0,@SiteId=100,@StartDate='Aug  2 2011  9:58:40:793AM',@EndDate='Oct 31 2011  9:58:40:793AM'

,@DownloadFilter=0,@PurchasedFilter=1,@CrossSitePAandEZA=0

,@PageNumber=1,@ResultsPerPage=30,@SortBy=6,@SortDirection=0,@AssetIdList=''





DECLARE @PageNumber INT
SET		@PageNumber = 0

WHILE @PageNumber < 20
BEGIN
	SET @PageNumber = @PageNumber + 1
	
	EXECUTE [WCDS].[dbo].[wedDownloadGet150] @IndividualId=2630466,@CompanyId=0,@PerspectiveFilter=0,@SiteId=100,@StartDate='Aug  2 2011  9:58:40:793AM',@EndDate='Oct 31 2011  9:58:40:793AM'
	,@DownloadFilter=0,@PurchasedFilter=1,@CrossSitePAandEZA=0,@PageNumber=@PageNumber,@ResultsPerPage=30,@SortBy=6,@SortDirection=1,@AssetIdList=''
END




DECLARE @PageNumber INT
SET		@PageNumber = 0

WHILE @PageNumber < 20
BEGIN
	SET @PageNumber = @PageNumber + 1
	
	EXECUTE [WCDS].[dbo].[wedDownloadGet151] @IndividualId=2630466,@CompanyId=0,@PerspectiveFilter=0,@SiteId=100,@StartDate='Aug  2 2011  9:58:40:793AM',@EndDate='Oct 31 2011  9:58:40:793AM'
	,@DownloadFilter=0,@PurchasedFilter=1,@CrossSitePAandEZA=0,@PageNumber=@PageNumber,@ResultsPerPage=30,@SortBy=6,@SortDirection=1,@AssetIdList=''
END




DECLARE @PageNumber INT
SET		@PageNumber = 0

WHILE @PageNumber < 20
BEGIN
	SET @PageNumber = @PageNumber + 1
	
	EXECUTE [WCDS].[dbo].[wedDownloadGet152] @IndividualId=2630466,@CompanyId=0,@PerspectiveFilter=0,@SiteId=100,@StartDate='Aug  2 2011  9:58:40:793AM',@EndDate='Oct 31 2011  9:58:40:793AM'
	,@DownloadFilter=0,@PurchasedFilter=1,@CrossSitePAandEZA=0,@PageNumber=@PageNumber,@ResultsPerPage=30,@SortBy=6,@SortDirection=1,@AssetIdList=''
END









EXECUTE [WCDS].[dbo].[wedDownloadGet150] @IndividualId=2630466,@CompanyId=0,@PerspectiveFilter=0,@SiteId=100,@StartDate='Aug  2 2011  9:58:40:793AM',@EndDate='Oct 31 2011  9:58:40:793AM'

,@DownloadFilter=0,@PurchasedFilter=1,@CrossSitePAandEZA=0

,@PageNumber=2,@ResultsPerPage=30,@SortBy=6,@SortDirection=1,@AssetIdList=''



EXECUTE [WCDS].[dbo].[wedDownloadGet150] @IndividualId=2630466,@CompanyId=0,@PerspectiveFilter=0,@SiteId=100,@StartDate='Aug  2 2011  9:58:40:793AM',@EndDate='Oct 31 2011  9:58:40:793AM'

,@DownloadFilter=0,@PurchasedFilter=1,@CrossSitePAandEZA=0

,@PageNumber=1,@ResultsPerPage=60,@SortBy=6,@SortDirection=1,@AssetIdList=''








--IF @PerspectiveFilter = 0

--		INSERT INTO @IndividualDownloads(DownloadID)
--		SELECT		DISTINCT DownloadID
--		FROM		dbo.DownloadDetail WITH(NOLOCK)
--		WHERE		IndividualID = @IndividualId
--			AND		StatusModifiedDateTime >= @StartDate
--			AND		StatusModifiedDateTime <= @EndDate
--ELSE

--		INSERT INTO @IndividualDownloads(DownloadID)
--		SELECT		DISTINCT DownloadID
--		FROM		dbo.DownloadDetail WITH(NOLOCK)
--		WHERE		CompanyID = @CompanyId
--			AND		StatusModifiedDateTime >= @StartDate
--			AND		StatusModifiedDateTime <= @EndDate



--		INSERT	@DownloadsOfInterest (DownloadId,SiteID)
--		SELECT		d.DownloadID,d.SiteID
--		FROM		dbo.Download d WITH(NOLOCK)
--		JOIN		@IndividualDownloads id
--				ON	d.DownloadID = id.DownloadID
--		WHERE		d.CreatedDate	>= @StartDate 
--			AND		d.CreatedDate	<= @EndDate
--			AND		d.SiteID		=  CASE
--										WHEN @SiteID = 0				THEN d.SiteID
--										WHEN @CrossSitePAandEZA = 1		THEN d.SiteID
--										ELSE @SiteID
--										END
										

--SET @AssetIdList = ',' + @AssetIdList + ','
		
--	INSERT INTO @PreSortData(DownloadDetailID,SortColumn)
--	SELECT		dd.DownloadDetailId
--				,CASE @SortBy
--				WHEN 0  THEN CAST(dd.DownloadID AS SQL_VARIANT)			
--				WHEN 1  THEN CAST(dd.DownloadID AS SQL_VARIANT)			
--				WHEN 2  THEN CAST(dd.ImageID AS SQL_VARIANT)			
--				WHEN 4  THEN CAST(dd.CollectionName AS SQL_VARIANT)		
--				WHEN 6  THEN CAST(dd.PhotographerName AS SQL_VARIANT)	
--				WHEN 8  THEN CAST((SELECT vchUserName FROM dbo.Individual WITH(NOLOCK) WHERE iIndividualId = dd.IndividualId)AS SQL_VARIANT)			
--				WHEN 10 THEN CAST((SELECT MediaType FROM dbo.Brand WHERE iBrandId = dd.CollectionID)AS SQL_VARIANT)			
--				END AS [SortColumn]

--	FROM		dbo.DownloadDetail dd WITH(NOLOCK)	
--	WHERE		dd.StatusModifiedDateTime >= @StartDate
--		AND		dd.StatusModifiedDateTime <= @EndDate
--		AND		dd.StatusID NOT IN (951,954)
		
--		AND		dd.DownloadSourceID = 
--				CASE @DownloadFilter 
--					WHEN 0 THEN ISNULL (dd.DownloadSourceID,0)	-- DEFAULT to returns everything
--					WHEN 4 THEN ISNULL (dd.DownloadSourceID,0)	-- returns everything 
--					WHEN 1 THEN 3100							-- editorial subscription download
--					WHEN 2 THEN 3101							-- easy access download
--					WHEN 3 THEN 3102							-- RF subscription download (NO LONGER AVAILABLE ON GI.COM SINCE CE SHUTDOWN - 07/2010)
--					WHEN 5 THEN 3103							-- Premium Access download
--					WHEN 6 THEN 3104							-- Royalty-Free Subscription - (used by Thinkstock)
--					WHEN 7 THEN 3105							-- Image Pack download - (used by Thinkstock)
--				END
--		AND		(
--				(@PurchasedFilter = 2 AND dd.OrderID IS NOT NULL)
--			OR	(@PurchasedFilter = 3 AND dd.OrderID IS NULL)
--			OR	(@PurchasedFilter = 1)
--				)
--		AND		dd.DownloadID IN	(SELECT DownloadID FROM @DownloadsOfInterest)
					
--		AND		(
--				@AssetIdList = ',,' 
--			OR	CHARINDEX(',' + dd.ImageId + ',', @AssetIdList) > 0
--				)	

--	IF @SortDirection=0
--		INSERT INTO	@DownloadDetails (DownloadDetailID)					
--		SELECT		DownloadDetailId
--		FROM		@PreSortData
--		ORDER BY	(RANK() OVER (ORDER BY [SortColumn] ASC))
--					,DownloadDetailId
--	ELSE
--		INSERT INTO	@DownloadDetails (DownloadDetailID)					
--		SELECT		TOP (@PageNumber * @ResultsPerPage)
--					DownloadDetailId
--		FROM		@PreSortData
--		ORDER BY	(RANK() OVER (ORDER BY [SortColumn] ASC))
--					,DownloadDetailId
	
					

--	INSERT INTO	@DownloadDetails2 (DownloadDetailID)
--	SELECT		DownloadDetailID
--	FROM		@DownloadDetails
--	ORDER BY	RowNumber * CASE @SortDirection WHEN 0 THEN 1 ELSE -1 END
	
--	UPDATE @DownloadDetails2
--	SET PageNumber = (RowNumber/@ResultsPerPage)  + CASE WHEN RowNumber%@ResultsPerPage = 0 THEN 0 ELSE 1 END


