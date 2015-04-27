USE [MercuryDM]
GO
ALTER DATABASE MercuryDM SET Single_user WITH ROLLBACK IMMEDIATE
GO
USE [MercuryDM]
GO
DBCC CHECKTABLE('dbo.ProductSubjectList',repair_allow_data_loss) WITH ALL_ERRORMSGS,PHYSICAL_ONLY
GO
ALTER DATABASE MercuryDM SET Multi_user WITH ROLLBACK IMMEDIATE
GO

USE [MercuryDM]
GO

/****** Object:  Index [ix_SubjectList]    Script Date: 06/18/2010 12:51:50 ******/
IF  EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[ProductSubjectList]') AND name = N'ix_SubjectList')
DROP INDEX [dbo].[ProductSubjectList].[ix_SubjectList]
GO

USE [MercuryDM]
GO

/****** Object:  Index [ix_SubjectList]    Script Date: 06/18/2010 12:51:50 ******/
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[ProductSubjectList]') AND name = N'ix_SubjectList')
CREATE NONCLUSTERED INDEX [ix_SubjectList] ON [dbo].[ProductSubjectList] 
(
	[SubjectList] ASC
) ON [PRIMARY]
GO

