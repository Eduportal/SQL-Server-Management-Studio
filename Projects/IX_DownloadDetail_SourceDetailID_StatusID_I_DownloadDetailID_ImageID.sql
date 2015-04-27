/*
Missing Index Details from SQLQuery21.sql - G1SQLA\A.WCDS (dbasledridge (456))
The Query Processor estimates that implementing the following index could improve the query cost by 99.9983%.
*/

/*
USE [WCDS]
GO
CREATE NONCLUSTERED INDEX [IX_DownloadDetail_SourceDetailID_StatusID_I_DownloadDetailID_ImageID]
ON [dbo].[DownloadDetail] ([SourceDetailID],[StatusID])
INCLUDE ([DownloadDetailID],[ImageID])
WITH(ONLINE=ON)
GO
*/
