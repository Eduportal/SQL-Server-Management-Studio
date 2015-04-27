USE [DEPLcontrol]
GO
/****** Object:  Table [dbo].[job_pong_log]    Script Date: 10/4/2013 11:02:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[job_pong_log](
	[jpl_id] [int] IDENTITY(1,1) NOT NULL,
	[Gears_id] [int] NOT NULL,
	[SQLname] [sysname] NOT NULL,
	[Process] [sysname] NOT NULL,
	[Status] [sysname] NOT NULL,
	[ModDate] [datetime] NULL
) ON [PRIMARY]

GO
