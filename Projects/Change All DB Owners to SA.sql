USE [master]
GO
ALTER DATABASE [WireImageDB] SET  READ_WRITE WITH NO_WAIT
GO

sp_msforeachdb 'use ?;exec sp_changedbowner ''sa'''


USE [master]
GO
ALTER DATABASE [WireImageDB] SET  READ_ONLY WITH NO_WAIT
GO