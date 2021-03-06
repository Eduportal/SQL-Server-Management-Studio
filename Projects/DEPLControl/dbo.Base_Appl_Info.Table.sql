USE [DEPLcontrol]
GO
/****** Object:  Table [dbo].[Base_Appl_Info]    Script Date: 10/4/2013 11:02:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Base_Appl_Info](
	[bai_id] [int] IDENTITY(1,1) NOT NULL,
	[DBname] [sysname] NULL,
	[CompanionDB_name] [sysname] NULL,
	[APPLname] [sysname] NULL,
	[BASEfolder] [sysname] NULL,
	[SQLname] [sysname] NULL,
	[baseline_srvname] [sysname] NULL,
	[ENVnum] [sysname] NULL,
	[Domain] [sysname] NULL,
	[moddate] [datetime] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Index [IX_clust_Base_Appl_Info]    Script Date: 10/4/2013 11:02:05 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_clust_Base_Appl_Info] ON [dbo].[Base_Appl_Info]
(
	[bai_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Base_Appl_Info] ADD  CONSTRAINT [DF_Base_Appl_Info_moddate]  DEFAULT (getdate()) FOR [moddate]
GO
