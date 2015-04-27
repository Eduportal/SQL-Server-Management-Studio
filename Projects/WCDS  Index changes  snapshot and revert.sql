



USE master;
-- Create Snapshot
CREATE DATABASE WCDS_snapshot ON
	(NAME = WCDSData, FILENAME = 'E:\SQL\Data\WCDSData_snapshot.ss')
	,(NAME = WCDSData02, FILENAME = 'E:\SQL\Data\WCDSData02_snapshot.ss')
AS SNAPSHOT OF WCDS;
GO






USE [WCDS]
-- Create Index
GO
CREATE NONCLUSTERED INDEX [IX_PremiumAccessDownloadLog_DownloadId]
ON [dbo].[PremiumAccessDownloadLog] ([DownloadId]) WITH(ONLINE = ON)
 
GO


USE [WCDS]
GO

/****** Object:  Index [IX_PremiumAccessDownloadLog_DownloadId]    Script Date: 12/13/2011 15:03:09 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[PremiumAccessDownloadLog]') AND name = N'IX_PremiumAccessDownloadLog_DownloadId')
DROP INDEX [IX_PremiumAccessDownloadLog_DownloadId] ON [dbo].[PremiumAccessDownloadLog] WITH ( ONLINE = OFF )
GO






USE master;
go
declare @dbname sysname
set @dbname = 'wcds'	-- substitute your database name here

set nocount on
declare Users cursor for 
	select spid
	from master..sysprocesses 
	where db_name(dbid) = @dbname

declare @spid int, @str varchar(255)

open users

fetch next from users into @spid

while @@fetch_status <> -1
begin
   if @@fetch_status = 0
   begin
      set @str = 'kill ' + convert(varchar, @spid)
      exec (@str)
   end
   fetch next from users into @spid
end

deallocate users

-- Reverting DATABASE
RESTORE DATABASE WCDS from 
DATABASE_SNAPSHOT = 'WCDS_snapshot';
GO