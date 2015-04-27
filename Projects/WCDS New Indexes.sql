

--ADD MISSING INDEX
USE [WCDS]
GO
CREATE NONCLUSTERED INDEX [IX_DownloadDetail_CompanyID_DownloadID]
ON [dbo].[DownloadDetail] ([CompanyId],[DownloadId])
--ON [ps_Download]([StatusModifiedDateTime]) 



CREATE NONCLUSTERED INDEX [IX_DownloadDetail_IndividualId_DownloadId]
ON [dbo].[DownloadDetail] ([IndividualId],[DownloadId])
--ON [ps_Download]([StatusModifiedDateTime]) 
GO


USE [WCDS]
GO
CREATE NONCLUSTERED INDEX [IX_DownloadDetail_CompanyId_StatusModifiedDateTime_I_DownloadId]
ON [dbo].[DownloadDetail] ([CompanyId],[StatusModifiedDateTime])
INCLUDE ([DownloadId])
--ON [ps_Download]([StatusModifiedDateTime]) 
GO

USE [WCDS]
GO
CREATE NONCLUSTERED INDEX [IX_Download_CreatedDate_I_DownloadID_SideID]
ON [dbo].[Download] ([CreatedDate])
INCLUDE ([DownloadID],[SiteId])
--ON [ps_Download]([StatusModifiedDateTime]) 
GO


USE [WCDS]
GO
CREATE NONCLUSTERED INDEX [IX_DownloadDetail_IndividualId_StatusModifiedDateTime_I_DownloadId]
ON [dbo].[DownloadDetail] ([IndividualId],[StatusModifiedDateTime])
INCLUDE ([DownloadId])
--ON [ps_Download]([StatusModifiedDateTime]) 
GO

USE [WCDS]
GO
CREATE NONCLUSTERED INDEX [IX_Download_CreatedDate_I_DownloadID_SideID_DownloadStatusID]
ON [dbo].[Download] ([CreatedDate])
INCLUDE ([DownloadID],[SiteId],[DownloadStatusID])
GO

CREATE NONCLUSTERED INDEX [IX_DownloadDetail_IndividualId_DownloadId_I_CoverFor_wedDownloadGet149]
ON [dbo].[DownloadDetail] ([IndividualId],[DownloadId])
INCLUDE ([DownloadDetailID],[ImageID],[CompanyId],[CompanyTypeId],[ImageSizeExternalID],[DownloadSourceId],[SourceDetailID],[StatusID],[OrderID],[CollectionID],[CollectionName],[ImageTitle],[PhotographerName],[StatusModifiedBy],[StatusModifiedDateTime],[ImageSource],[OrderDetailID])
GO

CREATE NONCLUSTERED INDEX [IX_DownloadDetail_CompanyId_DownloadId_I_CoverFor_wedDownloadGet149]
ON [dbo].[DownloadDetail] ([CompanyId],[DownloadId])
INCLUDE ([DownloadDetailID],[ImageID],[IndividualId],[CompanyTypeId],[ImageSizeExternalID],[DownloadSourceId],[SourceDetailID],[StatusID],[OrderID],[CollectionID],[CollectionName],[ImageTitle],[PhotographerName],[StatusModifiedBy],[StatusModifiedDateTime],[ImageSource],[OrderDetailID])
