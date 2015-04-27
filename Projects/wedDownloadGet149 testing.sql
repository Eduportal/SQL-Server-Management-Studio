--USE [WCDS]
--GO
--CREATE NONCLUSTERED INDEX [IX_Download_SiteId_DownloadID_CreatedDate]
--ON [dbo].[Download] ([SiteId],[DownloadID],[CreatedDate])
--WITH (SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]



		----INSERT INTO @IndividualDownloads(DownloadID)
		--SELECT		DISTINCT DownloadID
		--FROM		dbo.DownloadDetail WITH(NOLOCK)
		--WHERE		CompanyID = 0
		--	AND		DownloadID >= 9876949


--		--INSERT		@DownloadsOfInterest (DownloadId,SiteID)
--;WITH		ID
--			AS
--			(
--			SELECT		DISTINCT DownloadID
--			FROM		dbo.DownloadDetail WITH(NOLOCK)
--			WHERE		CompanyID = 0
--				AND		DownloadID >= 9876949
--			)
--		SELECT		d.DownloadID
--					,d.SiteID
--		FROM		dbo.Download d WITH(NOLOCK)
--		JOIN		ID
--				ON	d.DownloadID = id.DownloadID
--		WHERE		d.CreatedDate	>= '1/1/2006' 
--			AND		d.CreatedDate	<= '8/1/2013'
--			AND		d.SiteID		=  CASE
--										WHEN 410 = 0	THEN d.SiteID
--										WHEN 0 = 1		THEN d.SiteID
--										ELSE 410
--										END

--;WITH		ID
--			AS
--			(
--			SELECT		DISTINCT DownloadID
--			FROM		dbo.DownloadDetail WITH(NOLOCK)
--			WHERE		CompanyID = 0
--				AND		DownloadID >= 9876949
--			)
--		SELECT		d.DownloadID
--					,d.SiteID
--		FROM		dbo.Download d WITH(NOLOCK)
--		WHERE		d.CreatedDate	>= '1/1/2006' 
--			AND		d.CreatedDate	<= '8/1/2013'
--			AND		d.SiteID		=  CASE
--										WHEN 410 = 0	THEN d.SiteID
--										WHEN 0 = 1		THEN d.SiteID
--										ELSE 410
--										END
--			AND		d.DownloadID IN (SELECT DownloadID FROM ID)

SET NOCOUNT ON

DECLARE @SortBy			INT = 1
DECLARE @DownloadFilter int = 0
DECLARE @PurchasedFilter int = 3
DECLARE @AssetIdList varchar(1000) = ''

DECLARE	@Loop	int = 100
DECLARE @BS		INT = 100000
DECLARE @LC		INT

	--DECLARE @PreSortData TABLE
	--(
	--	DownloadDetailId			INT PRIMARY KEY,
	--	[vchUserName]				[nvarchar](40) NULL,
	--	[MediaType]					[nvarchar](10) NULL,
	--	[SortColumn]				sql_variant NULL,
	--	[IsEditorial]               [bit] NULL
	--)


--DROP TABLE #ID

--SELECT		DISTINCT 
--			(ROW_NUMBER() OVER (ORDER BY DownloadID) / 100000)+1 BatchNumber
--			,DownloadID
--INTO		##ID
--FROM		dbo.DownloadDetail WITH(NOLOCK)
--WHERE		CompanyID = 0
--	AND		DownloadID >= 9876949

--CREATE CLUSTERED INDEX [IX_ID]
--ON [dbo].[##ID] ([BatchNumber],[DownloadID])
--WITH (SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = OFF)

--SELECT		@LC = MAX(BatchNumber) 
--FROM		#ID

--RAISERROR ('Running on %i Batches of %i Records each.',-1,-1,@LC,@BS) WITH NOWAIT

--WHILE		@Loop <= @LC
--BEGIN

	DECLARE @IndividualDownloads TABLE
	(
		DownloadId					INT PRIMARY KEY
	)

		INSERT INTO @IndividualDownloads(DownloadID)
		SELECT		DISTINCT DownloadID
		FROM		dbo.DownloadDetail WITH(NOLOCK)
		WHERE		IndividualID = 6894451
			AND		DownloadID >= 9876949


	SELECT		d.DownloadID,d.SiteID
	FROM		dbo.Download d WITH(NOLOCK)
	WHERE		d.DownloadID IN (SELECT DownloadID FROM @IndividualDownloads)
		AND		d.CreatedDate	>= '2006-01-01 00:00:00' 
		AND		d.CreatedDate	<= '2013-08-02 09:09:49.223'
		AND		d.SiteID		=  CASE
									WHEN 410 = 0				THEN d.SiteID
									WHEN 0 = 1		THEN d.SiteID
									ELSE 410
									END



;WITH		ID
			AS
			(
			SELECT		DISTINCT [DownloadID]
			FROM		dbo.DownloadDetail WITH(NOLOCK)
			WHERE		IndividualID = 6894451
				AND		DownloadID >= 9876949
			)
			--,DownloadsOfInterest
			--AS
			--(
			SELECT		d.DownloadID
						,d.SiteID
			FROM		dbo.Download d WITH(NOLOCK)
			WHERE		d.DownloadID IN (SELECT DownloadID FROM ID)
				AND		d.CreatedDate	>= '2006-01-01 00:00:00' 
				AND		d.CreatedDate	<= '2013-08-02 09:09:49.223'
				AND		d.SiteID		=  CASE
											WHEN 410 = 0	THEN d.SiteID
											WHEN 0 = 1		THEN d.SiteID
											ELSE 410
											END
			)
--INSERT INTO @PreSortData(DownloadDetailID,vchUserName,MediaType,IsEditorial,SortColumn)
SELECT		dd.DownloadDetailId
			,(SELECT vchUserName FROM dbo.Individual WITH(NOLOCK) WHERE iIndividualId = dd.IndividualId) vchUserName
			,(SELECT MediaType FROM dbo.Brand WITH(NOLOCK) WHERE iBrandId = dd.CollectionID) MediaType
			,(SELECT bisEditorialCollectionFlag FROM dbo.Brand WITH(NOLOCK) WHERE iBrandId = dd.CollectionID) IsEditorial
			,CASE @SortBy
				WHEN 0  THEN CAST(dd.DownloadID AS SQL_VARIANT)			
				WHEN 1  THEN CAST(dd.DownloadID AS SQL_VARIANT)			
				WHEN 2  THEN CAST(dd.ImageID AS SQL_VARIANT)			
				WHEN 4  THEN CAST(dd.CollectionName AS SQL_VARIANT)		
				WHEN 6  THEN CAST(dd.PhotographerName AS SQL_VARIANT)	
				WHEN 8  THEN CAST((SELECT vchUserName FROM dbo.Individual WITH(NOLOCK) WHERE iIndividualId = dd.IndividualId)AS SQL_VARIANT)			
				WHEN 10 THEN CAST((SELECT MediaType FROM dbo.Brand WHERE iBrandId = dd.CollectionID)AS SQL_VARIANT)			
				END AS [SortColumn]
FROM		dbo.DownloadDetail dd WITH(NOLOCK)	
WHERE		dd.DownloadID >= 9876949
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
	AND		(
			(@PurchasedFilter = 2 AND dd.OrderID IS NOT NULL)	--PURCHASED
		OR	(@PurchasedFilter = 3 AND dd.OrderID IS NULL)		--NOT PURCHASED
		OR	(@PurchasedFilter = 1)								--ALL
			)
	AND		dd.DownloadID IN	(SELECT DownloadID FROM DownloadsOfInterest)

	AND		(
			(SELECT COUNT(*) FROM [wcds].[dbo].[getIntArrayFromString](@AssetIdList)) = 0
			OR
			dd.ImageId IN (SELECT Value FROM [wcds].[dbo].[getIntArrayFromString](@AssetIdList))
			)

--RAISERROR ('Batch Number %i. %i Records.',-1,-1,@Loop,@@ROWCOUNT) WITH NOWAIT
--DELETE @PreSortData
--SET @Loop = @Loop + 1
--END

