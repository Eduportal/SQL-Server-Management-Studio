USE [DynamicSortOrder]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[OmnitureActions_NEW](
	[AssetId] [nvarchar](100) NOT NULL,
	[Brand] [varchar](100) NULL,
	[KeywordId] [int] NOT NULL,
	[HitCount] [smallint] NULL,
	[ActionType] [tinyint] NOT NULL,
	[Country] [varchar](30) NULL,
	[UserId] [varchar](30) NULL,
	[Culture] [varchar](10) NULL,
	[Domain] [varchar](255) NULL,
	[WhenActionOccurred] [smalldatetime] NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


USE [DynamicSortOrder]
CREATE NONCLUSTERED INDEX [idxOmnitureActions_NEW_AssetIdKeywordIdActionType] ON [dbo].[OmnitureActions_NEW] 
(
	[AssetId] ASC
)
INCLUDE ( [KeywordId],
[ActionType]) WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 100) ON [PRIMARY]
GO


USE [DynamicSortOrder]
CREATE NONCLUSTERED INDEX [idxOmnitureActions_NEW_WhenActionOccurred] ON [dbo].[OmnitureActions_NEW] 
(
	[WhenActionOccurred] ASC
)
INCLUDE ( [AssetId],
[KeywordId],
[ActionType]) WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO

GRANT DELETE ON [dbo].[OmnitureActions_NEW] TO [role_DynamicSortOrderUser] AS [dbo]
GO

GRANT INSERT ON [dbo].[OmnitureActions_NEW] TO [role_DynamicSortOrderUser] AS [dbo]
GO

GRANT SELECT ON [dbo].[OmnitureActions_NEW] TO [role_DynamicSortOrderUser] AS [dbo]
GO


