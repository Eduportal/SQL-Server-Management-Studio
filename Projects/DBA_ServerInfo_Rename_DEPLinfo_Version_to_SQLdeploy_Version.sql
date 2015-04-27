/*

		DROP TRIGGER [dbo].[TR_DBA_ServerInfo_Update_SQLdeploy_Version_from_DEPLinfo_Version]
		GO
		DROP STATISTICS [dbo].[DBA_ServerInfo].[CustomStat_DEPLinfo_Version]
		GO
		DROP STATISTICS [dbo].[DBA_ServerInfo].[CustomStat_SQLdeploy_Version]
		GO
		ALTER TABLE [dbo].[DBA_ServerInfo] DROP COLUMN [DEPLinfo_Version]
		GO
		EXEC sp_rename 'dbo.DBA_ServerInfo.SQLdeploy_Version','DEPLinfo_Version','COLUMN'
		GO
		CREATE STATISTICS [CustomStat_DEPLinfo_Version] ON [dbo].[DBA_ServerInfo]([DEPLinfo_Version])
		GO
		

dbasp_Self_Register_Report
ServerInfo
HotServerHealthData



*/



BEGIN TRANSACTION
GO
	
SET NOEXEC OFF
GO
IF DB_ID('dbaCentral') IS NULL
SET NOEXEC ON
	USE [dbaCentral]
	GO
	PRINT 'Checking '+DB_NAME()+' Database...'
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	SET ANSI_PADDING ON
	GO
	IF COLUMNPROPERTY(OBJECT_ID('[dbo].[DBA_ServerInfo]'),'SQLdeploy_Version','ColumnId') IS NOT NULL
	BEGIN
		PRINT 'DBA_ServerInfo already has a SQLdeploy_Version Column.  No Change Made.'
		SET NOEXEC ON
	END
		PRINT '  DROPING STATISTICS [dbo].[DBA_ServerInfo].[CustomStat_DEPLinfo_Version]'
		GO
		DROP STATISTICS [dbo].[DBA_ServerInfo].[CustomStat_DEPLinfo_Version]
		GO

		PRINT '  RENAMING COLUMN DEPLinfo_Version TO SQLdeploy_Version'
		GO
		EXEC sp_rename 'dbo.DBA_ServerInfo.DEPLinfo_Version','SQLdeploy_Version','COLUMN'
		GO

		PRINT '  ADDING TEMPORARY COLUMN DEPLinfo_Version'
		GO
		ALTER TABLE [dbo].[DBA_ServerInfo] ADD [DEPLinfo_Version] [sysname] NULL
		GO

		PRINT '  CREATING TEMPORARY TRIGGER'
		GO
		CREATE TRIGGER [dbo].[TR_DBA_ServerInfo_Update_SQLdeploy_Version_from_DEPLinfo_Version]
		ON [dbo].[DBA_ServerInfo]
		AFTER INSERT, UPDATE
		AS 
		BEGIN
			IF UPDATE(DEPLinfo_Version)
				UPDATE		[dbo].[DBA_ServerInfo]
					SET	[dbo].[DBA_ServerInfo].SQLdeploy_Version = i.DEPLinfo_Version
				FROM		INSERTED i
				WHERE		[dbo].[DBA_ServerInfo].[SQLServerID] = i.SQLServerID

		END
		GO

		PRINT '  CREATING STATISTICS [dbo].[DBA_ServerInfo].[CustomStat_SQLdeploy_Version]'
		GO
		CREATE STATISTICS [CustomStat_SQLdeploy_Version] ON [dbo].[DBA_ServerInfo]([SQLdeploy_Version])
		GO
		
		PRINT '  CREATING STATISTICS [dbo].[DBA_ServerInfo].[CustomStat_DEPLinfo_Version]'
		GO
		CREATE STATISTICS [CustomStat_DEPLinfo_Version] ON [dbo].[DBA_ServerInfo]([DEPLinfo_Version])
		GO
		SELECT * FROM [dbo].[DBA_ServerInfo] 
SET NOEXEC OFF
GO


IF DB_ID('dbaadmin') IS NULL
SET NOEXEC ON
	USE [dbaadmin]
	GO
	PRINT 'Checking '+DB_NAME()+' Database...'
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	SET ANSI_PADDING ON
	GO

	IF COLUMNPROPERTY(OBJECT_ID('[dbo].[DBA_ServerInfo]'),'SQLdeploy_Version','ColumnId') IS NOT NULL
	BEGIN
		PRINT 'DBA_ServerInfo already has a SQLdeploy_Version Column.  No Change Made.'
		SET NOEXEC ON
	END

		PRINT '  DROPING STATISTICS [dbo].[DBA_ServerInfo].[CustomStat_DEPLinfo_Version]'
		GO
		DROP STATISTICS [dbo].[DBA_ServerInfo].[CustomStat_DEPLinfo_Version]
		GO

		PRINT '  RENAMING COLUMN DEPLinfo_Version TO SQLdeploy_Version'
		GO
		EXEC sp_rename 'dbo.DBA_ServerInfo.DEPLinfo_Version','SQLdeploy_Version','COLUMN'
		GO

		PRINT '  CREATING STATISTICS [dbo].[DBA_ServerInfo].[CustomStat_SQLdeploy_Version]'
		GO
		CREATE STATISTICS [CustomStat_SQLdeploy_Version] ON [dbo].[DBA_ServerInfo]([SQLdeploy_Version])
		GO
		SELECT * FROM [dbo].[DBA_ServerInfo]
SET NOEXEC OFF
GO

ROLLBACK TRANSACTION
GO


SELECT * FROM dbaadmin.[dbo].[DBA_ServerInfo] 
SELECT * FROM dbacentral.[dbo].[DBA_ServerInfo] 
GO