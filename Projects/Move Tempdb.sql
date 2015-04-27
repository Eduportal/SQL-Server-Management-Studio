USE master;
GO
ALTER DATABASE tempdb 
MODIFY FILE (NAME = tempdev, FILENAME = 'E:\Data\tempdb.mdf');
GO
ALTER DATABASE tempdb 
MODIFY FILE (NAME = templog, FILENAME = 'E:\Log\templog.ldf');
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdev2', FILENAME = N'E:\Data\tempdev2.ndf' , SIZE = 3072KB , FILEGROWTH = 1024KB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdev3', FILENAME = N'E:\Data\tempdev3.ndf' , SIZE = 3072KB , FILEGROWTH = 1024KB )
GO
