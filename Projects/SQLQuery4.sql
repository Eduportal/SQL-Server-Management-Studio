USE [master]
GO

/****** Object:  Table [dbo].[spt_values]    Script Date: 05/20/2010 12:06:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spt_values]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[spt_values](
	[name] [nvarchar](35) NULL,
	[number] [int] NOT NULL,
	[type] [nchar](3) NOT NULL,
	[low] [int] NULL,
	[high] [int] NULL,
	[status] [int] NULL
) ON [PRIMARY]
END
GO


USE [master]
/****** Object:  Index [spt_valuesclust]    Script Date: 05/20/2010 12:06:32 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[spt_values]') AND name = N'spt_valuesclust')
CREATE UNIQUE CLUSTERED INDEX [spt_valuesclust] ON [dbo].[spt_values] 
(
	[type] ASC,
	[number] ASC,
	[name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


USE [master]
/****** Object:  Index [ix2_spt_values_nu_nc]    Script Date: 05/20/2010 12:06:32 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[spt_values]') AND name = N'ix2_spt_values_nu_nc')
CREATE NONCLUSTERED INDEX [ix2_spt_values_nu_nc] ON [dbo].[spt_values] 
(
	[number] ASC,
	[type] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__spt_value__statu__436BFEE3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[spt_values] ADD  CONSTRAINT [DF__spt_value__statu__436BFEE3]  DEFAULT ((0)) FOR [status]
END

GO


