/*
Missing Index Details from SQLQuery21.sql - G1SQLA\A.WCDS (dbasledridge (456))
The Query Processor estimates that implementing the following index could improve the query cost by 10.3103%.
*/

/*
USE [WCDS]
GO
CREATE NONCLUSTERED INDEX [IX_Download_DownloadStatusID_I_DownloadID_SiteId_CreatedDate]
ON [dbo].[Download] ([DownloadStatusID])
INCLUDE ([DownloadID],[SiteId],[CreatedDate])
WITH(ONLINE=ON)
GO
*/
