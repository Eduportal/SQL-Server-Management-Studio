USE [dbaadmin]
GO
SET XACT_ABORT ON
GO
EXEC sp_changedbowner 'sa'
GO
ALTER DATABASE dbaadmin SET TRUSTWORTHY ON
GO
ALTER DATABASE dbaadmin SET ALLOW_SNAPSHOT_ISOLATION ON
GO

exec sp_msforeachDB 'USE [?];IF DB_ID() > 4 EXEC sp_changedbowner ''sa'';'