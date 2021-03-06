USE [DEPLcontrol]
GO
/****** Object:  Table [dbo].[Request]    Script Date: 10/4/2013 11:02:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Request](
	[req_id] [int] IDENTITY(1,1) NOT NULL,
	[Gears_id] [int] NOT NULL,
	[ProjectName] [sysname] NULL,
	[ProjectNum] [sysname] NULL,
	[RequestDate] [datetime] NULL,
	[StartDate] [datetime] NULL,
	[StartTime] [nvarchar](50) NULL,
	[Environment] [sysname] NULL,
	[Notes] [nvarchar](4000) NULL,
	[DBAapproved] [char](1) NOT NULL,
	[DBAapprover] [sysname] NULL,
	[Status] [sysname] NULL,
	[ModDate] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [IX_clust_Request]    Script Date: 10/4/2013 11:02:05 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_clust_Request] ON [dbo].[Request]
(
	[req_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Request]    Script Date: 10/4/2013 11:02:05 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Request] ON [dbo].[Request]
(
	[Gears_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
