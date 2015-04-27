USE [master]
GO
EXEC master.dbo.sp_addlogin @loginame = N'dbasledridge', @passwd = 'Tigger4U', @defdb = N'master', @deflanguage = N'us_english'
GO
CREATE LOGIN [dbasledridge] WITH PASSWORD=N'?Tigger4U', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO

ALTER LOGIN [dbasledridge] ENABLE
GO

EXEC sys.sp_addsrvrolemember @loginame = N'dbasledridge', @rolename = N'sysadmin'
GO

