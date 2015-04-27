/*
Congruent_RSubramanian
Congruent_LSharma


SQL Server Instance	Database				Permission 

FREPVARSQL01		Controller				db_owner
			LeadGeneration				db_owner
			Lookups					db_reader

FREPSQLEDW01		DataWarehouse				db_reader
			EnterpriseDataWarehouse			db_reader
			DownloadDataMart			db_reader
			MarketingDataMart			db_reader
			ReplicationSubscriberFromSEAPCOGSQL01	db_reader
			TeamsDataMart				db_reader
			User_Marketing				db_owner

SEAPSQLRPT01		WCDS					db_reader
			Getty_Images_US_Inc__MSCRM		db_reader

*/

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


USE [Controller]
GO
CREATE USER [Congruent_RSubramanian] FOR LOGIN [Congruent_RSubramanian]
CREATE USER [Congruent_LSharma] FOR LOGIN [Congruent_LSharma]
GO
EXEC sp_addrolemember N'db_owner', N'Congruent_RSubramanian'
EXEC sp_addrolemember N'db_owner', N'Congruent_LSharma'
GO


USE [LeadGeneration]
GO
CREATE USER [Congruent_RSubramanian] FOR LOGIN [Congruent_RSubramanian]
CREATE USER [Congruent_LSharma] FOR LOGIN [Congruent_LSharma]
GO
EXEC sp_addrolemember N'db_owner', N'Congruent_RSubramanian'
EXEC sp_addrolemember N'db_owner', N'Congruent_LSharma'
GO


USE [Lookups]
GO
CREATE USER [Congruent_RSubramanian] FOR LOGIN [Congruent_RSubramanian]
CREATE USER [Congruent_LSharma] FOR LOGIN [Congruent_LSharma]
GO
EXEC sp_addrolemember N'db_datareader', N'Congruent_RSubramanian'
EXEC sp_addrolemember N'db_datareader', N'Congruent_LSharma'
GO



