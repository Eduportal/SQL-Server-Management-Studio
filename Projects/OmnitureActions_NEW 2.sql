USE [DynamicSortOrder]
GO

SET NOCOUNT ON
GO

SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET NUMERIC_ROUNDABORT OFF
GO

IF OBJECT_ID('dbo.OmnitureActions_NEW', 'U') IS NOT NULL
  DROP TABLE dbo.OmnitureActions_NEW
GO

IF EXISTS( 
  SELECT * 
    FROM sys.partition_schemes
   WHERE name = N'PS_OmnitureActions'
)
	DROP PARTITION SCHEME PS_OmnitureActions
GO

IF EXISTS( 
  SELECT * 
    FROM sys.partition_functions
   WHERE name = N'PF_OmnitureActions'
)
	DROP PARTITION FUNCTION PF_OmnitureActions
GO


-- Create partition function
CREATE PARTITION FUNCTION PF_OmnitureActions(smalldatetime)
AS 
	RANGE RIGHT FOR VALUES ('20110101', '20110201', '20110301', '20110401', '20110501', '20110601', '20110701')
GO
-- Create partition scheme
CREATE PARTITION SCHEME PS_OmnitureActions
AS 
	PARTITION PF_OmnitureActions ALL TO ([PRIMARY])
GO

-- Create table on partition scheme
CREATE TABLE dbo.OmnitureActions_NEW 
(
	[WhenActionOccurred]	[smalldatetime]	NOT NULL
	,[AssetId]				[nvarchar](100)	NOT NULL
	,[Brand]				[varchar](100)	NULL
	,[KeywordId]			[int]			NOT NULL
	,[HitCount]				[smallint]		NULL
	,[ActionType]			[tinyint]		NOT NULL
	,[Country]				[varchar](30)	NULL
	,[UserId]				[varchar](30)	NULL
	,[Culture]				[varchar](10)	NULL
	,[Domain]				[varchar](255)	NULL
	
)
	ON [PS_OmnitureActions] (WhenActionOccurred) 
GO
CREATE CLUSTERED INDEX [IX_OmnitureActions_NEW_WhenActionOccurred] ON [dbo].[OmnitureActions_NEW]
(
[WhenActionOccurred]
) ON [PS_OmnitureActions](WhenActionOccurred);
 
 
--DROP INDEX [IX_OmnitureActions_NEW_WhenActionOccurred] ON [dbo].[OmnitureActions_NEW] WITH ( ONLINE = OFF );



select * from sys.partition_range_values
 where function_id in (select function_id 
      from sys.partition_functions
       where name in ('PF_OmnitureActions'))
       
GO       

DECLARE @ProcessDate		DateTime
		,@Msg				VarChar(max)
		,@Records			INT

SELECT		@ProcessDate = CAST(CONVERT(VarChar(12),MIN([WhenActionOccurred]),101)AS DateTime) 
FROM		[DynamicSortOrder].[dbo].[OmnitureActions] WITH(NOLOCK)

CopyDay:

SELECT		@Msg = 'Starting ' + CAST(@ProcessDate AS VarChar)
RAISERROR (@Msg,-1,-1) WITH NOWAIT
       
INSERT INTO [DynamicSortOrder].[dbo].[OmnitureActions_NEW]
           ([AssetId]
           ,[Brand]
           ,[KeywordId]
           ,[HitCount]
           ,[ActionType]
           ,[Country]
           ,[UserId]
           ,[Culture]
           ,[Domain]
           ,[WhenActionOccurred])
SELECT [AssetId]
      ,[Brand]
      ,[KeywordId]
      ,[HitCount]
      ,[ActionType]
      ,[Country]
      ,[UserId]
      ,[Culture]
      ,[Domain]
      ,[WhenActionOccurred]
  FROM [DynamicSortOrder].[dbo].[OmnitureActions] WITH(NOLOCK)
  WHERE [WhenActionOccurred] >= @ProcessDate
    AND	[WhenActionOccurred] <  @ProcessDate + 1

SELECT		@Msg = '  Processed - ' + CAST(@@ROWCOUNT AS VarChar)
RAISERROR (@Msg,-1,-1) WITH NOWAIT

SET	@ProcessDate = @ProcessDate + 1

IF @ProcessDate < (SELECT CAST(CONVERT(VarChar(12),MAX([WhenActionOccurred]),101)AS DateTime) FROM [DynamicSortOrder].[dbo].[OmnitureActions] WITH(NOLOCK))
 GOTO CopyDay
 
 
GO



        
       