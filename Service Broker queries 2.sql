
--	exec sp_whoisactive
--	exec sp_who2
--	exec EventServiceDb.dbo.TeamsSndQueFaildEvntJobSp


USE EventServiceDB
GO
select top 1000 * from sys.conversation_endpoints
SELECT TOP 1000 * FROM sys.transmission_queue
GO
USE EditorialSiteDB
GO
select top 1000 * from sys.conversation_endpoints order by lifetime
SELECT TOP 1000 * FROM sys.transmission_queue
GO

ALTER DATABASE EventServiceDB set NEW_BROKER WITH ROLLBACK IMMEDIATE
GO
ALTER DATABASE EditorialSiteDB set NEW_BROKER WITH ROLLBACK IMMEDIATE
GO
ALTER DATABASE EventServiceDB SET TRUSTWORTHY ON
GO
ALTER DATABASE EditorialSiteDB SET TRUSTWORTHY ON
GO