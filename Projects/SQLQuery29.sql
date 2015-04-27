USE [ProductCatalog]
GO

SELECT		e.EventId
			, e.StartDate
			,	(
				SELECT		COUNT(*) AS Expr1
				FROM		dbo.EventAssetRelationship AS ear
				WHERE		EventId IN	(
										SELECT		ChildEventID
										FROM		dbo.EventActiveChildrenView AS eac
										WHERE		ParentEventID = e.EventId
										)
				)
			+	(
				SELECT		COUNT(*) AS Expr1
				FROM		dbo.EventAssetRelationship AS ear
				WHERE		EventId = e.EventId
				) AS AssetCount
			,	(
				SELECT		COUNT(*) AS Expr1
				FROM		dbo.EventActiveChildrenView
				WHERE		ParentEventID = e.EventId
				) AS ChildEventCount
			, ea.AssetId AS ThumbnailAssetID
			, ea.BrandCode AS ThumbnailBrandCode
			, ea.DeliveryLocation AS ThumbnailDeliveryLocation
			, e.Description
			, e.EventName
			, e.EventTypeId
			, e.isActive
			, e.isDisplayed
			,	(
				SELECT		COUNT(*) AS Expr1
				FROM		dbo.EventAssetRelationship AS ear
				WHERE		ear.assettypeid = 10 
					and		EventId IN	(
										SELECT		ChildEventID
										FROM		dbo.EventActiveChildrenView AS eac
										WHERE		ParentEventID = e.EventId
										)
				)
			+	(
				SELECT		COUNT(*) AS Expr1
				FROM		dbo.EventAssetRelationship AS ear
				WHERE		ear.assettypeid = 10  
					and		EventId = e.EventId
				) AS ImageCount
			,	(
				SELECT		COUNT(*) AS Expr1
				FROM		dbo.EventAssetRelationship AS ear
				WHERE		ear.assettypeid = 20 
					and		EventId IN	(
										SELECT		ChildEventID
										FROM		dbo.EventActiveChildrenView AS eac
										WHERE		ParentEventID = e.EventId
										)
				)
			+	(
				SELECT		COUNT(*) AS Expr1
				FROM		dbo.EventAssetRelationship AS ear
				WHERE		ear.assettypeid = 20
					and		EventId = e.EventId
				) AS FilmCount
FROM		dbo.Event AS e 
LEFT OUTER JOIN dbo.EventThumbnailView AS etv 
	ON		etv.EventID = e.EventId 
LEFT OUTER JOIN	dbo.EventAsset AS ea 
	ON		etv.ThumbnailAssetID = ea.AssetId


GO


DECLARE		@AssetCount	Table
				(
				EventID	Int
				,ParentEventID Int
				,AssetTypeID Int
				,AssetCount Int
				)
				
INSERT INTO	@AssetCount				
SELECT		ear.EventId
			,eac.ParentEventID
			,ear.assettypeid
			,COUNT(*) AS AssetCount
FROM		dbo.EventAssetRelationship AS ear WITH(NOLOCK)
JOIN		dbo.EventActiveChildrenView AS eac WITH(NOLOCK)
	ON		ear.EventId = eac.ChildEventID
GROUP BY	ear.EventId
			,eac.ParentEventID
			,ear.assettypeid	

SELECT		TOP 10
			e.EventId
			, e.StartDate
			, COALESCE(SUM(Asset.AssetCount),0) AS AssetCount
			, COALESCE(Child.EventCount,0) AS ChildEventCount
			, ea.AssetId AS ThumbnailAssetID
			, ea.BrandCode AS ThumbnailBrandCode
			, ea.DeliveryLocation AS ThumbnailDeliveryLocation
			, e.Description
			, e.EventName
			, e.EventTypeId
			, e.isActive
			, e.isDisplayed
			, COALESCE(SUM([Image].AssetCount),0) AS ImageCount
			, COALESCE(SUM([Film].AssetCount),0) AS FilmCount
FROM		dbo.Event AS e WITH(NOLOCK)
LEFT JOIN	(
			SELECT		ParentEventID AS EventID
						,COUNT(*) AS EventCount
			FROM		dbo.EventActiveChildrenView
			GROUP BY	ParentEventID
			) Child
	ON		Child.EventID = e.EventID
LEFT JOIN	(
			SELECT		EventID
						,ParentEventID
						,SUM(AssetCount) AssetCount
			FROM		@AssetCount
			GROUP BY	EventID
						,ParentEventID
			) Asset
	ON		Asset.EventID = e.EventID
	OR		Asset.ParentEventID = e.EventID
LEFT JOIN	@AssetCount AS [Image]
	ON		[Image].AssetTypeID = 10
	AND		([Image].EventID = e.EventID
	OR		[Image].ParentEventID = e.EventID)
LEFT JOIN	@AssetCount AS [Film]
	ON		[Film].AssetTypeID = 20
	AND		([Film].EventID = e.EventID
	OR		[Film].ParentEventID = e.EventID)

LEFT JOIN	dbo.EventThumbnailView AS etv  WITH(NOLOCK)
	ON		etv.EventID = e.EventId 
LEFT JOIN	dbo.EventAsset AS ea WITH(NOLOCK) 
	ON		etv.ThumbnailAssetID = ea.AssetId

GROUP BY	e.EventId
			, e.StartDate
			, Child.EventCount
			, ea.AssetId
			, ea.BrandCode
			, ea.DeliveryLocation
			, e.Description
			, e.EventName
			, e.EventTypeId
			, e.isActive
			, e.isDisplayed
