USE [master]
GO

/****** Object:  Table [dbo].[dtproperties]    Script Date: 05/20/2010 11:19:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dtproperties]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[dtproperties](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[objectid] [int] NULL,
	[property] [varchar](64) NOT NULL,
	[value] [varchar](255) NULL,
	[uvalue] [nvarchar](255) NULL,
	[lvalue] [image] NULL,
	[version] [int] NOT NULL,
 CONSTRAINT [pk_dtproperties] PRIMARY KEY CLUSTERED 
(
	[id] ASC,
	[property] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__dtpropert__versi__2EB0D91F]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[dtproperties] ADD  CONSTRAINT [DF__dtpropert__versi__2EB0D91F]  DEFAULT (0) FOR [version]
END

GO


