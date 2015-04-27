USE [TicketingArchive]
GO

IF  EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[frmData]') AND name = N'PK_DID')
ALTER TABLE [dbo].[frmData] DROP CONSTRAINT [PK_DID]
GO


USE [TicketingArchive]
GO

IF  EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[frmData]') AND name = N'INDX_TID')
DROP INDEX [dbo].[frmData].[INDX_TID]
GO

USE [TicketingArchive]
GO

CREATE CLUSTERED INDEX [INDX_TID] ON [dbo].[frmData] 
(
	[TID] ASC
) ON [PRIMARY]
GO


USE [TicketingArchive]
GO

ALTER TABLE [dbo].[frmData] ADD  CONSTRAINT [PK_DID] PRIMARY KEY NONCLUSTERED 
(
	[DID] ASC
) ON [PRIMARY]
GO





IF (OBJECTPROPERTY(OBJECT_ID(N'[dbo].[frmData]'), 'TableFullTextCatalogId') = 0) 
EXEC dbo.sp_fulltext_table @tabname=N'[dbo].[frmData]', @action=N'create', @keyname=N'PK_DID', @ftcat=N'TicketingArchive'
GO

declare @lcid int select @lcid=lcid from master.dbo.syslanguages where alias=N'English' EXEC dbo.sp_fulltext_column @tabname=N'[dbo].[frmData]', @colname=N'controlTitle', @action=N'add', @language=@lcid
GO

declare @lcid int select @lcid=lcid from master.dbo.syslanguages where alias=N'English' EXEC dbo.sp_fulltext_column @tabname=N'[dbo].[frmData]', @colname=N'value', @action=N'add', @language=@lcid
GO

EXEC dbo.sp_fulltext_table @tabname=N'[dbo].[frmData]', @action=N'start_change_tracking'
GO

EXEC dbo.sp_fulltext_table @tabname=N'[dbo].[frmData]', @action=N'start_background_updateindex'
GO


