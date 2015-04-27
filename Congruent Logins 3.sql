USE [master]
GO
ALTER LOGIN [Congruent_RSubramanian] WITH PASSWORD=N'eFVDl?dU2vTun/h6'
GO
ALTER LOGIN [Congruent_LSharma] WITH PASSWORD=N'Mhd2T?4(/.1IXVv2'
GO


USE [master]
GO
CREATE LOGIN [Congruent_RSubramanian] WITH PASSWORD=N'Thi$is@T3st', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
CREATE LOGIN [Congruent_LSharma] WITH PASSWORD=N'Thi$is@T3st', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO


USE [WCDS]
GO
CREATE USER [Congruent_RSubramanian] FOR LOGIN [Congruent_RSubramanian]
CREATE USER [Congruent_LSharma] FOR LOGIN [Congruent_LSharma]
GO
EXEC sp_addrolemember N'db_datareader', N'Congruent_RSubramanian'
EXEC sp_addrolemember N'db_datareader', N'Congruent_LSharma'
GO


USE [Getty_Images_US_Inc__MSCRM]
GO
CREATE USER [Congruent_RSubramanian] FOR LOGIN [Congruent_RSubramanian]
CREATE USER [Congruent_LSharma] FOR LOGIN [Congruent_LSharma]
GO
EXEC sp_addrolemember N'db_datareader', N'Congruent_RSubramanian'
EXEC sp_addrolemember N'db_datareader', N'Congruent_LSharma'
GO

