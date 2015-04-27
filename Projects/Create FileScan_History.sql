USE [dbaadmin]
GO

/****** Object:  Table [dbo].[FileScan_History]    Script Date: 01/19/2010 17:26:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[FileScan_History](
	[HistoryID] [bigint] IDENTITY(1,1) NOT NULL,
	[WorkfileID] [bigint] NOT NULL,
	[EventDateTime] [datetime] NOT NULL,
	[Machine] [varchar](255) NOT NULL,
	[Instance] [varchar](255) NOT NULL,
	[SourceType] [varchar](255) NOT NULL,
	[SourceFileIndex] [int] NOT NULL,
	[Message] [varchar](255) NOT NULL,
	[KnownCondition] [varchar](50) NOT NULL,
	[FixData] [varchar](max) NULL,
	[FixQuery] [varchar](max) NULL,
 CONSTRAINT [PK_FileScan_History] PRIMARY KEY CLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
USE [dbaadmin]
GO

/****** Object:  Index [IX_FileScan_History_Unique]    Script Date: 01/19/2010 17:27:13 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_FileScan_History_Unique] ON [dbo].[FileScan_History] 
(
	[SourceType] ASC,
	[Machine] ASC,
	[Instance] ASC,
	[EventDateTime] ASC,
	[SourceFileIndex] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

SET ANSI_PADDING OFF
GO


