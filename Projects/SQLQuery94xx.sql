--SELECT COUNT(*) FROM SWL_BUCKETSCORES WITH(NOLOCK)

--DROP TABLE SWL_BUCKETSCORES
--GO
--DROP XML SCHEMA COLLECTION ProductCatalog_BucketScores
--GO

--DECLARE		@XSD	XML

--;WITH		AllScores
--		AS
--		(
--		SELECT NULL [ID]
--		)
--		,BucketScores
--		AS
--		(
--		SELECT NULL [ID]
--		)
--		,BucketScore
--		AS
--		(
--		SELECT top 10  assetId Id, datasetid Dsid, keywordid Kwid, bucketid Bkid, score Score
--		FROM dbo.DSOPublishedDataSet with (nolock)
--		)
--SELECT		@XSD = 
--		(
--		SELECT		*
--		FROM		AllScores
--		CROSS JOIN	BucketScores
--		CROSS JOIN	BucketScore
--		WHERE		1=2
--		FOR XML AUTO, TYPE,XMLSCHEMA('urn:ProductCatalog_BucketScores')
--		).query('*[1]')
--		--.query('declare namespace xs = "http://www.w3.org/2001/XMLSchema" /xs:schema') ; -- ERRORS WITH : XQuery [query()]: All prolog entries need to end with ';', found '/'.


--CREATE ""  ProductCatalog_BucketScores AS @XSD
--GO

--DROP TABLE SWL_BUCKETSCORES
--GO
--CREATE TABLE SWL_BUCKETSCORES 
--		(
--		id		INT PRIMARY KEY CLUSTERED IDENTITY, -- primary key required if XML index needed
--		BucketScores	XML(CONTENT ProductCatalog_BucketScores)
--		)
--go

--CREATE PRIMARY XML INDEX PXML_BucketScores
--ON [dbo].[SWL_BUCKETSCORES] (BucketScores)
--GO

DELETE SWL_BUCKETSCORES
GO
DECLARE		@XML		XML(ProductCatalog_BucketScores)
		,@bucketScores	XML

DECLARE @OldBucketScoresTable TABLE	(
					[AssetId]		[nvarchar](50) NOT NULL,
					[KeywordId]		[int] NOT NULL,
					[BucketId]		[int] NOT NULL,
					[DatasetId]		[int] NOT NULL,
					[Score]			[int] NULL,
					[OmnitureActions]	[nvarchar](2048) NULL,
					[RegionId]		[int] NOT NULL
					)




SELECT		@bucketScores	=
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

		,@XML = @bucketScores


--;WITH		AllScores
--		AS
--		(
--		SELECT NULL [ID]
--		)
--		,BucketScores
--		AS
--		(
--		SELECT NULL [ID]
--		)
--		,BucketScore
--		AS
--		(
--		SELECT top 10  assetId Id, datasetid Dsid, keywordid Kwid, bucketid Bkid, score Score
--		FROM dbo.DSOPublishedDataSet with (nolock)
--		)
--SELECT		--@XML = 
--		(
--		SELECT		*
--		FROM		AllScores
--		CROSS JOIN	BucketScores
--		CROSS JOIN	BucketScore
--		FOR XML AUTO, TYPE,XMLSCHEMA('urn:ProductCatalog_BucketScores')
--		).query('/*[position()>1]')
--		,--@bucketScores = 
--		(
--		SELECT		*
--		FROM		AllScores
--		CROSS JOIN	BucketScores
--		CROSS JOIN	BucketScore
--		FOR XML AUTO, TYPE --,XMLSCHEMA('urn:ProductCatalog_BucketScores')
--		)--.query('/*[position()>1]')


--SELECT	@XML,@bucketScores

INSERT INTO SWL_BUCKETSCORES VALUES(@XML)

--SELECT * FROM SWL_BUCKETSCORES
BEGIN TRANSACTION

    ;WITH XMLNAMESPACES(DEFAULT 'urn:ProductCatalog_BucketScores')
	,NewBucketScores
	AS
	(
	SELECT		T.c.value('(@Id)[1]', 'nvarchar(50)')	as assetId, 
			T.c.value('(@Dsid)[1]', 'int')		as datasetid, 
			T.c.value('(@Kwid)[1]', 'int')		as keywordid, 
			T.c.value('(@Bkid)[1]', 'int')		as bucketid, 
			T.c.value('(@Score)[1]', 'int')		as score--, 
			--0					as isUpdate
	FROM		[SWL_BUCKETSCORES]
	CROSS APPLY	[BucketScores].nodes('/AllScores/BucketScores/BucketScore') T(c)
	)
DELETE	dbo.DSOPublishedDataSet
OUTPUT	DELETED.* INTO @OldBucketScoresTable
WHERE	assetId IN (SELECT AssetID FROM NewBucketScores)

;WITH		XMLNAMESPACES(DEFAULT 'urn:ProductCatalog_BucketScores')
		,NewBucketScores
		AS
		(
		SELECT		T.c.value('(@Id)[1]', 'nvarchar(50)')	as assetId, 
				T.c.value('(@Dsid)[1]', 'int')		as datasetid, 
				T.c.value('(@Kwid)[1]', 'int')		as keywordid, 
				T.c.value('(@Bkid)[1]', 'int')		as bucketid, 
				T.c.value('(@Score)[1]', 'int')		as score--, 
				--0					as isUpdate
		FROM		[SWL_BUCKETSCORES]
		CROSS APPLY	[BucketScores].nodes('/AllScores/BucketScores/BucketScore') T(c)
		)		
INSERT INTO	dbo.DSOPublishedDataSet
SELECT		DISTINCT
		NewBucketScores.AssetId
		,NewBucketScores.KeywordId
		,NewBucketScores.BucketId
		,NewBucketScores.DatasetId
		,NewBucketScores.Score
		,OldBucketScores.OmnitureActions
		,COALESCE(OldBucketScores.RegionId,0)
FROM		NewBucketScores
LEFT JOIN	@OldBucketScoresTable OldBucketScores
	ON	NewBucketScores.assetId = OldBucketScores.assetId
	AND	NewBucketScores.datasetid = OldBucketScores.datasetid
	AND	NewBucketScores.keywordid = OldBucketScores.keywordid
	AND	NewBucketScores.bucketid = OldBucketScores.bucketid
	
COMMIT TRANSACTION







	
SELECT		top 100 *
FROM		dbo.DSOPublishedDataSet ds with (nolock)
WHERE		assetId IN (SELECT AssetID FROM NewBucketScores)	


	SELECT	assetId
		,COUNT(*)
	FROM	dbo.DSOPublishedDataSet ds with (nolock)
	GROUP BY assetId
	ORDER BY 2 desc


    --;WITH XMLNAMESPACES(DEFAULT 'urn:ProductCatalog_BucketScores')
    --SELECT 
    --    T.c.value('(@Id)[1]', 'nvarchar(50)')	as assetId, 
    --    T.c.value('(@Dsid)[1]', 'int')		as datasetid, 
    --    T.c.value('(@Kwid)[1]', 'int')		as keywordid, 
    --    T.c.value('(@Bkid)[1]', 'int')		as bucketid, 
    --    T.c.value('(@Score)[1]', 'int')		as score, 
    --    0					as isUpdate
    --FROM @XML.nodes('/AllScores/BucketScores/BucketScore') T(c)

    SELECT 
        T.c.value('(@Id)[1]', 'nvarchar(50)')	as assetId, 
        T.c.value('(@Dsid)[1]', 'int')		as datasetid, 
        T.c.value('(@Kwid)[1]', 'int')		as keywordid, 
        T.c.value('(@Bkid)[1]', 'int')		as bucketid, 
        T.c.value('(@Score)[1]', 'int')		as score, 
        0					as isUpdate
    FROM @bucketScores.nodes('/AllScores/BucketScores/BucketScore') T(c)









USE [ProductCatalog]
GO
/****** Object:  StoredProcedure [dbo].[wedUpsertBucketScores]    Script Date: 09/06/2012 09:09:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================================================
-- Author		Date		Comments
-- -----------------	----------	------------------------------------------------------------
-- Jacob Graves	       05/01/2012	upserts assets bucket scores
-- =============================================================================================

/*
<AllScores xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<BucketScores>
		<BucketScore Id="ASSETID" Dsid="DATASETID" Kwid="KEYWORDID" Bkid="BUCKETID" Score="SCORE" />
		<BucketScore Id="ASSETID" Dsid="DATASETID" Kwid="KEYWORDID" Bkid="BUCKETID" Score="SCORE" />
		<BucketScore Id="ASSETID" Dsid="DATASETID" Kwid="KEYWORDID" Bkid="BUCKETID" Score="SCORE" />
		<BucketScore Id="ASSETID_DELETE_ALL_ITS_EXISTING_BUCKETSCORES" />
		.
		.
		.
	</BucketScores>
</AllScores>

NOTE - regionId is assumed to be always 0
NOTE - a Bucketscore with a dsid of 0 will not be inserted (used to delete all of an assets Bucketscores)
*/

--ALTER PROCEDURE [dbo].[wedUpsertBucketScores] 
DECLARE    @bucketScores xml, 
	@oiErrorId INT	--= 0 OUTPUT
--AS

SELECT	@bucketScores = '<AllScores xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<BucketScores>
		<BucketScore Id="ASSETID" Dsid="DATASETID" Kwid="KEYWORDID" Bkid="BUCKETID" Score="SCORE" />
		<BucketScore Id="ASSETID" Dsid="DATASETID" Kwid="KEYWORDID" Bkid="BUCKETID" Score="SCORE" />
		<BucketScore Id="ASSETID" Dsid="DATASETID" Kwid="KEYWORDID" Bkid="BUCKETID" Score="SCORE" />
		<BucketScore Id="ASSETID_DELETE_ALL_ITS_EXISTING_BUCKETSCORES" />
	</BucketScores>
</AllScores>'
	,@oiErrorId = 0




BEGIN

	SET NOCOUNT ON

	BEGIN TRY
	
	SET @oiErrorId = 0
	
	IF @bucketScores is null select 0
	
	declare	@defaultRegionId	int
	declare @priority		int
	declare @assetIndexAction	int

	DECLARE @NewBucketScoresTable TABLE	(
						assetId		nvarchar(50), 
						datasetid	int, 
						keywordid	int, 
						bucketid	int, 
						score		int, 
						isUpdate	bit
						)
						
	DECLARE @OldBucketScoresTable TABLE	(
						assetId		nvarchar(50), 
						datasetid	int, 
						keywordid	int, 
						bucketid	int, 
						score		int, 
						isDelete	bit
						)							
	set	@defaultRegionId	= 0
	set	@priority		= 201
	set	@assetIndexAction	= 1
	
	--extract new scores from xml to table
	

    INSERT INTO @NewBucketScoresTable (assetId, datasetid, keywordid, bucketid, score, isUpdate)
    SELECT 
        T.c.value('(@Id)[1]', 'nvarchar(50)')	as assetId, 
        T.c.value('(@Dsid)[1]', 'int')		as datasetid, 
        T.c.value('(@Kwid)[1]', 'int')		as keywordid, 
        T.c.value('(@Bkid)[1]', 'int')		as bucketid, 
        T.c.value('(@Score)[1]', 'int')		as score, 
        0					as isUpdate
    FROM @bucketScores.nodes('/AllScores/BucketScores/BucketScore') T(c)	

	if 0 = (select count(*) from @NewBucketScoresTable) select 0

	--get old scores from db
	

	
	INSERT INTO @OldBucketScoresTable (assetId, datasetid, keywordid, bucketid, score, isDelete)
	SELECT distinct ds.assetId, ds.datasetid, ds.keywordid, ds.bucketid, ds.score, 0
	FROM dbo.DSOPublishedDataSet ds with (nolock)
	join @NewBucketScoresTable ns on ns.assetId = ds.assetId
	
	--delete items in old scores and not in new scores (match on asset id, dataset id, keyword id and bucket id)
	
	update os
	set os.isDelete = 1
	from @OldBucketScoresTable os
	where not exists (
		select *
		from @NewBucketScoresTable ns
		where ns.assetId = os.assetId
		and ns.datasetid = os.datasetid
		and ns.keywordid = os.keywordid
		and ns.bucketid = os.bucketid
	)
	
	delete ds
	from dbo.DSOPublishedDataSet ds
	join @OldBucketScoresTable os 
		on os.isDelete = 1 
		and os.assetId = ds.assetId 
		and os.datasetid = ds.datasetid 
		and os.keywordid = ds.keywordid 
		and os.bucketid = ds.bucketid
	
	--insert items in new scores and not in old scores (match on asset id, dataset id, keyword id and bucket id)
	
	insert dbo.DSOPublishedDataSet (assetId, keywordid, bucketid, datasetid, score, regionId)
	select
		ns.assetId, 
		ns.keywordid, 
		ns.bucketid, 
		ns.datasetid, 
		ns.score, 
		@defaultRegionId
	from @NewBucketScoresTable ns
	where not exists (
		select *
		from @OldBucketScoresTable os
		where ns.assetId = os.assetId
		and ns.datasetid = os.datasetid
		and ns.keywordid = os.keywordid
		and ns.bucketid = os.bucketid
	)
	and ns.datasetid > 0
	
	--update items where score is differant between old and new (match on asset id, dataset id, keyword id and bucket id)
	
	update ns
	set ns.isUpdate = 1
	from @NewBucketScoresTable ns
	join @OldBucketScoresTable os 
		on ns.assetId = os.assetId 
		and ns.datasetid = os.datasetid 
		and ns.keywordid = os.keywordid 
		and ns.bucketid = os.bucketid 
		and ns.score <> os.score
	
	update ds
	set ds.score = ns.score
	from dbo.DSOPublishedDataSet ds
	join @NewBucketScoresTable ns 
		on ns.isUpdate = 1
		and ns.assetId = ds.assetId 
		and ns.datasetid = ds.datasetid 
		and ns.keywordid = ds.keywordid 
		and ns.bucketid = ds.bucketid 
	
	--add asset to queue for reindexing
	
	INSERT [dbo].AssetsToIndex (AssetId, Priority, AssetIndexAction)
	select distinct ns.assetId, @priority, @assetIndexAction
	from @NewBucketScoresTable ns

    select 0

	END TRY
	
	BEGIN CATCH

	IF (XACT_STATE() > 0)
	BEGIN
		ROLLBACK TRANSACTION
	END

	-- Log error
	DECLARE @ErrMsg nvarchar(4000), 
            @ErrSeverity int,
            @ErrorProcedure nvarchar(100),
            @Note nvarchar(500)

	SELECT @ErrMsg = ERROR_MESSAGE(),
	       @ErrSeverity = ERROR_SEVERITY(),
	       @Note = substring(ERROR_MESSAGE(), 1, 500),
	       @ErrorProcedure = substring(ERROR_PROCEDURE(), 1, 100),
		   @oiErrorId = ERROR_NUMBER()

	EXEC [dbo].wedProductCatalogEventLog 
	     @LogType = 'Error',
	     @EventSource = @ErrorProcedure,
	     @EventAction = 'Unexpected Error Occurred',
	     @AssetID = '', -- can't be null
	     @AfterValue = null,
	     @Note = @Note

	RAISERROR(@ErrMsg, @ErrSeverity, 1)
	SET NOCOUNT OFF
	select -999
	

	END CATCH

END
