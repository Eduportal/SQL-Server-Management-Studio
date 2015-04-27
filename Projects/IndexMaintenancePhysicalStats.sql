USE [dbaadmin]
GO

/****** Object:  Table [IndexMaintenancePhysicalStats]    Script Date: 04/06/2010 18:16:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[IndexMaintenancePhysicalStats]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[IndexMaintenancePhysicalStats](
	[imPhysicalStatsId] [bigint] IDENTITY(1,1) NOT NULL,
	[insert_date] [datetime] NULL,
	[scan_started] [datetime] NULL,
	[database_id] [int] NULL,
	[object_id] [int] NULL,
	[tablename] [nvarchar](255) NULL,
	[index_id] [int] NULL,
	[partition_number] [int] NULL,
	[index_depth] [tinyint] NULL,
	[index_level] [tinyint] NULL,
	[avg_fragmentation_in_percent] [float] NULL,
	[page_count] [bigint] NULL,
	[avg_page_space_used_in_percent] [float] NULL,
	[record_count] [bigint] NULL,
	[min_record_size_in_bytes] [int] NULL,
	[max_record_size_in_bytes] [int] NULL,
	[avg_record_size_in_bytes] [float] NULL,
	[user_seeks] [bigint] NULL,
	[user_scans] [bigint] NULL,
	[user_lookups] [bigint] NULL,
	[user_updates] [bigint] NULL,
	[system_seeks] [bigint] NULL,
	[system_scans] [bigint] NULL,
	[system_lookups] [bigint] NULL,
	[system_updates] [bigint] NULL,
 CONSTRAINT [PK__IndexMai__1AF9F2312180FB33] PRIMARY KEY CLUSTERED 
(
	[imPhysicalStatsId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'description' , N'SCHEMA',N'dbo', N'TABLE',N'IndexMaintenancePhysicalStats', N'COLUMN',N'imPhysicalStatsId'))
EXEC sys.sp_addextendedproperty @name=N'description', @value=N'Sequential number to identify the row.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IndexMaintenancePhysicalStats', @level2type=N'COLUMN',@level2name=N'imPhysicalStatsId'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'description' , N'SCHEMA',N'dbo', N'TABLE',N'IndexMaintenancePhysicalStats', N'COLUMN',N'insert_date'))
EXEC sys.sp_addextendedproperty @name=N'description', @value=N'Datetime at which the object scan started' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IndexMaintenancePhysicalStats', @level2type=N'COLUMN',@level2name=N'insert_date'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'description' , N'SCHEMA',N'dbo', N'TABLE',N'IndexMaintenancePhysicalStats', N'COLUMN',N'scan_started'))
EXEC sys.sp_addextendedproperty @name=N'description', @value=N'Datetime at which the job run pulling the data started' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IndexMaintenancePhysicalStats', @level2type=N'COLUMN',@level2name=N'scan_started'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'description' , N'SCHEMA',N'dbo', N'TABLE',N'IndexMaintenancePhysicalStats', N'COLUMN',N'database_id'))
EXEC sys.sp_addextendedproperty @name=N'description', @value=N'System Database_Id in which the physical stats are located.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IndexMaintenancePhysicalStats', @level2type=N'COLUMN',@level2name=N'database_id'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'description' , N'SCHEMA',N'dbo', N'TABLE',N'IndexMaintenancePhysicalStats', N'COLUMN',N'object_id'))
EXEC sys.sp_addextendedproperty @name=N'description', @value=N'System object_id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IndexMaintenancePhysicalStats', @level2type=N'COLUMN',@level2name=N'object_id'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'description' , N'SCHEMA',N'dbo', N'TABLE',N'IndexMaintenancePhysicalStats', N'COLUMN',N'tablename'))
EXEC sys.sp_addextendedproperty @name=N'description', @value=N'Schema + . + tablename on which the index lives' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IndexMaintenancePhysicalStats', @level2type=N'COLUMN',@level2name=N'tablename'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'description' , N'SCHEMA',N'dbo', N'TABLE',N'IndexMaintenancePhysicalStats', N'COLUMN',N'index_id'))
EXEC sys.sp_addextendedproperty @name=N'description', @value=N'System id for the index on the table. 1= clustered index.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IndexMaintenancePhysicalStats', @level2type=N'COLUMN',@level2name=N'index_id'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'description' , N'SCHEMA',N'dbo', N'TABLE',N'IndexMaintenancePhysicalStats', N'COLUMN',N'partition_number'))
EXEC sys.sp_addextendedproperty @name=N'description', @value=N'1-based partition number within the owning object; a table, view, or index. .' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IndexMaintenancePhysicalStats', @level2type=N'COLUMN',@level2name=N'partition_number'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'description' , N'SCHEMA',N'dbo', N'TABLE',N'IndexMaintenancePhysicalStats', N'COLUMN',N'index_depth'))
EXEC sys.sp_addextendedproperty @name=N'description', @value=N'Number of levels in the given index.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IndexMaintenancePhysicalStats', @level2type=N'COLUMN',@level2name=N'index_depth'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'description' , N'SCHEMA',N'dbo', N'TABLE',N'IndexMaintenancePhysicalStats', N'COLUMN',N'index_level'))
EXEC sys.sp_addextendedproperty @name=N'description', @value=N'Number of level for this row of data. 0= leaf level.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IndexMaintenancePhysicalStats', @level2type=N'COLUMN',@level2name=N'index_level'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'description' , N'SCHEMA',N'dbo', N'TABLE',N'IndexMaintenancePhysicalStats', N'COLUMN',N'avg_fragmentation_in_percent'))
EXEC sys.sp_addextendedproperty @name=N'description', @value=N'Level of fragmentation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IndexMaintenancePhysicalStats', @level2type=N'COLUMN',@level2name=N'avg_fragmentation_in_percent'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'description' , N'SCHEMA',N'dbo', N'TABLE',N'IndexMaintenancePhysicalStats', N'COLUMN',N'page_count'))
EXEC sys.sp_addextendedproperty @name=N'description', @value=N'Number of pages at this level of this index.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IndexMaintenancePhysicalStats', @level2type=N'COLUMN',@level2name=N'page_count'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'description' , N'SCHEMA',N'dbo', N'TABLE',N'IndexMaintenancePhysicalStats', N'COLUMN',N'avg_page_space_used_in_percent'))
EXEC sys.sp_addextendedproperty @name=N'description', @value=N'Avg page fill-- null if Limited scan was run' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IndexMaintenancePhysicalStats', @level2type=N'COLUMN',@level2name=N'avg_page_space_used_in_percent'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'description' , N'SCHEMA',N'dbo', N'TABLE',N'IndexMaintenancePhysicalStats', N'COLUMN',N'record_count'))
EXEC sys.sp_addextendedproperty @name=N'description', @value=N'Records in this level of this index -- null if Limited scan was run' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IndexMaintenancePhysicalStats', @level2type=N'COLUMN',@level2name=N'record_count'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'description' , N'SCHEMA',N'dbo', N'TABLE',N'IndexMaintenancePhysicalStats', N'COLUMN',N'min_record_size_in_bytes'))
EXEC sys.sp_addextendedproperty @name=N'description', @value=N'lowest record size for this level of this index-- null if Limited scan was run' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IndexMaintenancePhysicalStats', @level2type=N'COLUMN',@level2name=N'min_record_size_in_bytes'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'description' , N'SCHEMA',N'dbo', N'TABLE',N'IndexMaintenancePhysicalStats', N'COLUMN',N'max_record_size_in_bytes'))
EXEC sys.sp_addextendedproperty @name=N'description', @value=N'max record size for this level of this index-- null if Limited scan was run' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IndexMaintenancePhysicalStats', @level2type=N'COLUMN',@level2name=N'max_record_size_in_bytes'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'description' , N'SCHEMA',N'dbo', N'TABLE',N'IndexMaintenancePhysicalStats', N'COLUMN',N'avg_record_size_in_bytes'))
EXEC sys.sp_addextendedproperty @name=N'description', @value=N'avg record size for this level of this index-- null if Limited scan was run' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IndexMaintenancePhysicalStats', @level2type=N'COLUMN',@level2name=N'avg_record_size_in_bytes'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'description' , N'SCHEMA',N'dbo', N'TABLE',N'IndexMaintenancePhysicalStats', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'description', @value=N'Table containing index physical statistics (avg fragmentation) data pulled by dbo.IndexMaintenancePhysicalStats.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IndexMaintenancePhysicalStats'
GO


