USE [dbacentral]
GO
SET ROWCOUNT 100
agian:
DELETE	[dbo].[FileScan_History]
WHERE	[EventDateTime] > Getdate()-365
if @@rowcount = 100 goto agian
set ROWCOUNT 0
