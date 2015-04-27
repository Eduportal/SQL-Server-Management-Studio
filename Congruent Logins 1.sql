

sp_msforeachDB ' use [?];DROP USER [Congruent_RSubramanian];'
sp_msforeachDB ' use [?];DROP USER [Congruent_LSharma];'
GO


--USE [master]
--GO
--ALTER LOGIN [Congruent_RSubramanian] WITH PASSWORD=N'eFVDl?dU2vTun/h6'
--GO
--ALTER LOGIN [Congruent_LSharma] WITH PASSWORD=N'Mhd2T?4(/.1IXVv2'
--GO


USE [master]
GO
DROP LOGIN [Congruent_RSubramanian]
GO
CREATE LOGIN [Congruent_RSubramanian] WITH PASSWORD=N'eFVDl?dU2vTun/h6', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
DROP LOGIN [Congruent_LSharma]
GO
CREATE LOGIN [Congruent_LSharma] WITH PASSWORD=N'Mhd2T?4(/.1IXVv2', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO


USE [DataWarehouse]
GO
CREATE USER [Congruent_RSubramanian] FOR LOGIN [Congruent_RSubramanian]
CREATE USER [Congruent_LSharma] FOR LOGIN [Congruent_LSharma]
GO
EXEC sp_addrolemember N'db_datareader', N'Congruent_RSubramanian'
EXEC sp_addrolemember N'db_datareader', N'Congruent_LSharma'
GO


--USE [EnterpriseDataWarehouse]
--GO
--CREATE USER [Congruent_RSubramanian] FOR LOGIN [Congruent_RSubramanian]
--CREATE USER [Congruent_LSharma] FOR LOGIN [Congruent_LSharma]
--GO
--EXEC sp_addrolemember N'db_datareader', N'Congruent_RSubramanian'
--EXEC sp_addrolemember N'db_datareader', N'Congruent_LSharma'
--GO



USE [DownloadDataMart]
GO
CREATE USER [Congruent_RSubramanian] FOR LOGIN [Congruent_RSubramanian]
CREATE USER [Congruent_LSharma] FOR LOGIN [Congruent_LSharma]
GO
EXEC sp_addrolemember N'db_datareader', N'Congruent_RSubramanian'
EXEC sp_addrolemember N'db_datareader', N'Congruent_LSharma'
GO


USE [MarketingDataMart]
GO
CREATE USER [Congruent_RSubramanian] FOR LOGIN [Congruent_RSubramanian]
CREATE USER [Congruent_LSharma] FOR LOGIN [Congruent_LSharma]
GO
EXEC sp_addrolemember N'db_datareader', N'Congruent_RSubramanian'
EXEC sp_addrolemember N'db_datareader', N'Congruent_LSharma'
GO

USE [ReplicationSubscriberFromSEAPCOGSQL01]
GO
CREATE USER [Congruent_RSubramanian] FOR LOGIN [Congruent_RSubramanian]
CREATE USER [Congruent_LSharma] FOR LOGIN [Congruent_LSharma]
GO
EXEC sp_addrolemember N'db_datareader', N'Congruent_RSubramanian'
EXEC sp_addrolemember N'db_datareader', N'Congruent_LSharma'
GO


USE [TeamsDataMart]
GO
CREATE USER [Congruent_RSubramanian] FOR LOGIN [Congruent_RSubramanian]
CREATE USER [Congruent_LSharma] FOR LOGIN [Congruent_LSharma]
GO
EXEC sp_addrolemember N'db_datareader', N'Congruent_RSubramanian'
EXEC sp_addrolemember N'db_datareader', N'Congruent_LSharma'
GO


USE [User_Marketing]
GO
CREATE USER [Congruent_RSubramanian] FOR LOGIN [Congruent_RSubramanian]
CREATE USER [Congruent_LSharma] FOR LOGIN [Congruent_LSharma]
GO
EXEC sp_addrolemember N'db_owner', N'Congruent_RSubramanian'
EXEC sp_addrolemember N'db_owner', N'Congruent_LSharma'
GO



