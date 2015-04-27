--CREATE DATABASE [Test]
--GO
USE [Test];
GO
--CREATE TABLE [Test]
--    (
--      RowID INT IDENTITY
--                PRIMARY KEY ,
--      datacol CHAR(4000) NOT NULL
--                         DEFAULT ( '' )
--    )
--GO
INSERT  INTO [Test]
        DEFAULT VALUES;
GO 100000


USE [Test]
GO
TRUNCATE TABLE [TEST]
GO
DBCC SHRINKFILE (N'Test' , 0, TRUNCATEONLY)
GO
DBCC SHRINKFILE (N'Test' , 0, NOTRUNCATE)
GO
DBCC SHRINKFILE (N'Test' , 0, TRUNCATEONLY)
GO
DBCC SHRINKFILE (N'Testdata2' , 0, TRUNCATEONLY)
GO
DBCC SHRINKFILE (N'Testdata2' , 0, NOTRUNCATE)
GO
DBCC SHRINKFILE (N'Testdata2' , 0, TRUNCATEONLY)
GO

USE dbaadmin
go
--CREATE TABLE [DDL_Events] (ID INT IDENTITY(1,1), [EventData] XML)
select * From  [DDL_Events] 


IF EXISTS (SELECT * FROM sys.server_triggers
      WHERE name = 'ddl_trig_database')
  DROP TRIGGER ddl_trig_database
  ON ALL SERVER;
  GO
  CREATE TRIGGER ddl_trig_database 
  ON ALL SERVER 
  FOR DDL_SERVER_LEVEL_EVENTS
  AS 
     INSERT INTO dbaadmin.dbo.[DDL_Events]([EventData])
      SELECT EVENTDATA()
  GO
  --DROP TRIGGER ddl_trig_database
  --ON ALL SERVER;
  --GO

