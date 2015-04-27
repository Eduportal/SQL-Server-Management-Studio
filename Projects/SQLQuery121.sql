declare @p15 int
set @p15=210
declare @p16 int
set @p16=10
declare @p17 int
set @p17=5
declare @p18 int
set @p18=NULL
declare @p19 varchar(256)
set @p19=NULL
exec wedDownloadGet149 @IndividualId=2680063,@CompanyId=2680060,@PerspectiveFilter=0,@SiteId=100,@StartDate='2011-08-23 00:00:00',@EndDate='2011-10-01 00:00:00',@DownloadFilter=0,@PurchasedFilter=1,@CrossSitePAandEZA=1,@PageNumber=1,@ResultsPerPage=21,@SortBy=0,@SortDirection=1,@AssetIdList=N'',@TotalRows=@p15 output,@TotalPages=@p16 output,@CurrentPage=@p17 output,@oiErrorID=@p18 output,@ovchErrorMessage=@p19 output
select @p15, @p16, @p17, @p18, @p19

GO

declare @p15 int
set @p15=210
declare @p16 int
set @p16=10
declare @p17 int
set @p17=5
declare @p18 int
set @p18=NULL
declare @p19 varchar(256)
set @p19=NULL
exec wedDownloadGet150 @IndividualId=2680063,@CompanyId=2680060,@PerspectiveFilter=0,@SiteId=100,@StartDate='2011-08-23 00:00:00',@EndDate='2011-10-01 00:00:00',@DownloadFilter=0,@PurchasedFilter=1,@CrossSitePAandEZA=1,@PageNumber=1,@ResultsPerPage=21,@SortBy=0,@SortDirection=1,@AssetIdList=N'',@TotalRows=@p15 output,@TotalPages=@p16 output,@CurrentPage=@p17 output,@oiErrorID=@p18 output,@ovchErrorMessage=@p19 output
select @p15, @p16, @p17, @p18, @p19
