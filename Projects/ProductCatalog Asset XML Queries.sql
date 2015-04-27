

GO
WITH XMLNAMESPACES ('http://www.gettyimages.com/schema/product-catalog' AS "pc")

SELECT		DISTINCT
			CAST(x.query('local-name((.)[1])') AS SYSNAME)		[Level1]
			,CAST(x.query('local-name((*)[1])') AS SYSNAME)		[Level2]
			,CAST(x.query('local-name((*/*)[1])') AS SYSNAME)	[Level3]
			,CAST(x.query('local-name((*/*/*)[1])') AS SYSNAME)	[Level4]
			--,x.query('.')[Data]
			--,CASE WHEN nullif(CAST(x.query('local-name((*/*)[1])') AS VarChar(max)),'') IS NOT NULL THEN x.query('*/.') ELSE x.query('.') END [Data]
FROM		AssetAsXml Asset			
CROSS APPLY	Asset.ntAssetXml.nodes('pc:Asset/*') a(x)
--where nvchAssetID = '115065033'
ORDER BY	1,2,3

GO



CREATE VIEW [AssetAsXml]
AS
SELECT		[nvchAssetID]
			,CAST([ntAssetXml] AS XML) AS [ntAssetXml]
			,[nvchSchemaVersion]
			,[dtModified]
			,[bActive]
			,[intProcessState]
			,[Updated]
			,[TeamsMetadataDate]
			,[AssetKeywordDate]
FROM		[ProductCatalog].[dbo].[Asset]
GO



GO
WITH XMLNAMESPACES ('http://www.gettyimages.com/schema/product-catalog' AS "pc")

SELECT		*
FROM		(
			SELECT		[nvchAssetID]
						,CAST([ntAssetXml] AS XML) AS [ntAssetXml]
						,[nvchSchemaVersion]
						,[dtModified]
						,[bActive]
						,[intProcessState]
						,[Updated]
						,[TeamsMetadataDate]
						,[AssetKeywordDate]
			FROM		[ProductCatalog].[dbo].[Asset] WITH(NOLOCK)
			WHERE		nvchAssetID in ('115065033', '115065031', '115065038', '115065036', '115065024', '111970806', '112508832', '112508822', '112280846', '112280842')
			) RawData

WHERE		ntAssetXml.exist ('//pc:Keywords/pc:Keyword[@Confidence="5" and @ID="8789353" and @Type="-1" and @Weight="5" and @WeightValue="0"]') = 1

GO

SELECT		*
FROM		(
			SELECT		[nvchAssetID]
						,CAST([ntAssetXml] AS XML) AS [ntAssetXml]
						,[nvchSchemaVersion]
						,[dtModified]
						,[bActive]
						,[intProcessState]
						,[Updated]
						,[TeamsMetadataDate]
						,[AssetKeywordDate]
			FROM		[ProductCatalog].[dbo].[Asset] WITH(NOLOCK)
			--WHERE		nvchAssetID in ('115065033', '115065031', '115065038', '115065036', '115065024', '111970806', '112508832', '112508822', '112280846', '112280842')
			) RawData

WHERE		ntAssetXml.exist ('//pc:Keyword[@Confidence="5" and @ID="8789353" and @Type="-1" and @Weight="5" and @WeightValue="0"]') = 1

GO


;WITH XMLNAMESPACES ('http://www.gettyimages.com/schema/product-catalog' AS "pc")
SELECT		nvchAssetID
			,K.Words.value ('@ID','int')			AS	KeywordID
			,K.Words.value ('@Confidence','int')	AS	Confidence
			,K.Words.value ('@Type','int')			AS	Type
			,K.Words.value ('@Weight','int')		AS	Weight
			,K.Words.value ('@WeightValue','int')	AS	WeightValue
FROM		(
			SELECT		[nvchAssetID]
						,CAST([ntAssetXml] AS XML) AS [ntAssetXml]
						,[nvchSchemaVersion]
						,[dtModified]
						,[bActive]
						,[intProcessState]
						,[Updated]
						,[TeamsMetadataDate]
						,[AssetKeywordDate]
			FROM		[ProductCatalog].[dbo].[Asset]
			) Asset  
CROSS APPLY	ntAssetXml.nodes('//pc:Keyword')		AS K(Words)

WHERE		nvchAssetID in ('115065033', '115065031', '115065038', '115065036', '115065024', '111970806', '112508832', '112508822', '112280846', '112280842')







