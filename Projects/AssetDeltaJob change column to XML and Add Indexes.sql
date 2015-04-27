USE [AssetKeyword]
GO

DROP INDEX [IXML_AssetDeltaJob_AssetDeltasXML_Property] ON [dbo].[AssetDeltaJob]
DROP INDEX [IXML_AssetDeltaJob_AssetDeltasXML_Value] ON [dbo].[AssetDeltaJob]
DROP INDEX [IXML_AssetDeltaJob_AssetDeltasXML_Path] ON [dbo].[AssetDeltaJob]
DROP INDEX [IXML_AssetDeltaJob_AssetDeltasXML_Primary] ON [dbo].[AssetDeltaJob]



ALTER TABLE dbo.AssetDeltaJob ALTER COLUMN
	[AssetDeltasXML] NVARCHAR(MAX) NULL
GO
	
CREATE PRIMARY XML INDEX [IXML_AssetDeltaJob_AssetDeltasXML_Primary]
ON AssetDeltaJob(AssetDeltasXML)
GO

CREATE XML INDEX [IXML_AssetDeltaJob_AssetDeltasXML_Path] 
ON AssetDeltaJob(AssetDeltasXML)
USING XML INDEX [IXML_AssetDeltaJob_AssetDeltasXML_Primary]
FOR PATH
GO

CREATE XML INDEX [IXML_AssetDeltaJob_AssetDeltasXML_Value] 
ON AssetDeltaJob(AssetDeltasXML)
USING XML INDEX [IXML_AssetDeltaJob_AssetDeltasXML_Primary]
FOR VALUE
GO

CREATE XML INDEX [IXML_AssetDeltaJob_AssetDeltasXML_Property] 
ON AssetDeltaJob(AssetDeltasXML)
USING XML INDEX [IXML_AssetDeltaJob_AssetDeltasXML_Primary]
FOR PROPERTY
GO
