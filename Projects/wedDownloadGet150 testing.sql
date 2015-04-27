USE [WCDS]
GO
--CREATE NONCLUSTERED INDEX [IX_DownloadDetail_CompanyId_DownloadId]
--ON [dbo].[DownloadDetail] ([CompanyId],[DownloadId])
--WITH (SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = ON)
--GO

--SET ANSI_PADDING ON

--CREATE NONCLUSTERED INDEX [_dta_index_DownloadDetail_9_1221631445__K1_K2_K8_K3] ON [dbo].[DownloadDetail]
--(
--	[DownloadDetailID] ASC,
--	[DownloadId] ASC,
--	[DownloadSourceId] ASC,
--	[ImageID] ASC
--)WITH (SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = ON) ON [PRIMARY]


--CREATE NONCLUSTERED INDEX [_dta_index_DDT_9_958730568__K2] ON [dbo].[DDT]
--(
--	[DownloadDetailId] ASC
--)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]

--CREATE STATISTICS [_dta_stat_1221631445_2_1_8_3] ON [dbo].[DownloadDetail]([DownloadId], [DownloadDetailID], [DownloadSourceId], [ImageID])
--CREATE STATISTICS [_dta_stat_1221631445_8_3_1] ON [dbo].[DownloadDetail]([DownloadSourceId], [ImageID], [DownloadDetailID])
--CREATE STATISTICS [_dta_stat_1221631445_2_8_3] ON [dbo].[DownloadDetail]([DownloadId], [DownloadSourceId], [ImageID])


--sp_who2 active

DECLARE @RC int
DECLARE @IndividualId int
DECLARE @CompanyId int
DECLARE @PerspectiveFilter int
DECLARE @SiteId int
DECLARE @StartDate datetime
DECLARE @EndDate datetime
DECLARE @DownloadFilter int
DECLARE @PurchasedFilter int
DECLARE @CrossSitePAandEZA tinyint
DECLARE @PageNumber int
DECLARE @ResultsPerPage int
DECLARE @SortBy int
DECLARE @SortDirection int
DECLARE @AssetIdList varchar(1000)
DECLARE @TotalRows int
DECLARE @TotalPages int
DECLARE @CurrentPage int
DECLARE @oiErrorID int
DECLARE @ovchErrorMessage varchar(256)

-- TODO: Set parameter values here.

EXECUTE @RC = [WCDS].[dbo].[wedDownloadGet150] 
   6894451
  ,0
  ,@PerspectiveFilter
  ,410
  ,'1/1/2006'
  ,'8/1/2013'
  ,0
  ,3
  ,0
  ,1
  ,10
  ,1
  ,@SortDirection
  ,''
  ,@TotalRows OUTPUT
  ,@TotalPages OUTPUT
  ,@CurrentPage OUTPUT
  ,@oiErrorID OUTPUT
  ,@ovchErrorMessage OUTPUT

SELECT		@TotalRows
			,@TotalPages 
			,@CurrentPage 
			,@oiErrorID 
			,@ovchErrorMessage 


GO
