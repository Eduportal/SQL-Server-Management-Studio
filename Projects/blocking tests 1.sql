SET NOCOUNT ON
GO
 
-- Count the locks
 
IF EXISTS ( SELECT  Name
            FROM    tempdb..sysobjects
            WHERE   name LIKE '#Hold_sp_lock%' )
--If So Drop it
    DROP TABLE #Hold_sp_lock
GO
CREATE TABLE #Hold_sp_lock
    (
      spid INT,
      dbid INT,
      ObjId INT,
      IndId SMALLINT,
      Type VARCHAR(20),
      Resource VARCHAR(50),
      Mode VARCHAR(20),
      Status VARCHAR(20)
    )
INSERT  INTO #Hold_sp_lock
        EXEC sp_lock
SELECT  COUNT(spid) AS lock_count,
        SPID,
        Type,
        Cast(DB_NAME(DBID) as varchar(30)) as DBName,
        mode
FROM    #Hold_sp_lock
GROUP BY SPID,
        Type,
        DB_NAME(DBID),
        MODE
Order by lock_count desc,
        DBName,
        SPID,
        MODE
 
--Show any blocked or blocking processes
 
IF EXISTS ( SELECT  Name
            FROM    tempdb..sysobjects
            Where   name like '#Catch_SPID%' )
--If So Drop it
    DROP TABLE #Catch_SPID
GO
Create Table #Catch_SPID
    (
      bSPID int,
      BLK_Status char(10)
    )
GO
Insert  into #Catch_SPID
        Select Distinct
                SPID,
                'BLOCKED'
        from    master..sysprocesses
        where   blocked <> 0
        UNION
        Select Distinct
                blocked,
                'BLOCKING'
        from    master..sysprocesses
        where   blocked <> 0
 
DECLARE @tSPID int
DECLARE @blkst char(10)
SELECT TOP 1
        @tSPID = bSPID,
        @blkst = BLK_Status
from    #Catch_SPID
 
WHILE( @@ROWCOUNT > 0 )
    BEGIN
 
        PRINT 'DBCC Results for SPID ' + Cast(@tSPID as varchar(5)) + '( '
            + rtrim(@blkst) + ' )'
        PRINT '-----------------------------------'
        PRINT ''
        DBCC INPUTBUFFER(@tSPID)
 
 
        SELECT TOP 1
                @tSPID = bSPID,
                @blkst = BLK_Status
        from    #Catch_SPID
        WHERE   bSPID > @tSPID
        Order by bSPID
 
    END

--DBCC TRACEON (1118,-1)

USE [DBAadmin]
GO
/****** Object:  StoredProcedure [dbo].[usp_Find_Problems]    Script Date: 06/22/2009 22:41:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[usp_Find_Problems] ( @count_locks BIT = 1 )
AS
    SET NOCOUNT ON
-- Count the locks
    IF @count_locks = 0
        GOTO Get_Blocks
    ELSE
        IF @count_locks = 1
            BEGIN
 
                    CREATE TABLE #Hold_sp_lock
                        (
                          spid INT,
                          dbid INT,
                          ObjId INT,
                          IndId SMALLINT,
                          Type VARCHAR(20),
                          Resource VARCHAR(50),
                          Mode VARCHAR(20),
                          Status VARCHAR(20)
                        )
                INSERT  INTO #Hold_sp_lock
                        EXEC sp_lock
                SELECT  COUNT(spid) AS lock_count,
                        SPID,
                        Type,
                        CAST(DB_NAME(DBID) AS VARCHAR(30)) AS DBName,
                        mode
                FROM    #Hold_sp_lock
                GROUP BY SPID,
                        Type,
                        CAST(DB_NAME(DBID) AS VARCHAR(30)),
                        MODE
                ORDER BY lock_count DESC,
                        DBName,
                        SPID,
                        MODE
 
--Show any blocked or blocking processes
 
                Get_Blocks:
 
 
                    CREATE TABLE #Catch_SPID
                        (
                          bSPID INT,
                          BLK_Status CHAR(10)
                        )
 
                INSERT  INTO #Catch_SPID
                        SELECT DISTINCT
                                SPID,
                                'BLOCKED'
                        FROM    master..sysprocesses
                        WHERE   blocked <> 0
                        UNION
                        SELECT DISTINCT
                                blocked,
                                'BLOCKING'
                        FROM    master..sysprocesses
                        WHERE   blocked <> 0
 
                DECLARE @tSPID INT
                DECLARE @blkst CHAR(10)
                SELECT TOP 1
                        @tSPID = bSPID,
                        @blkst = BLK_Status
                FROM    #Catch_SPID
               
 
 
                WHILE( @@ROWCOUNT > 0 )
                    BEGIN
 
                        PRINT 'DBCC Results for SPID '
                            + CAST(@tSPID AS VARCHAR(5)) + '( ' + RTRIM(@blkst)
                            + ' )'
                        PRINT '-----------------------------------'
                        PRINT ''
                        DBCC INPUTBUFFER(@tSPID)
 
 
                        SELECT TOP 1
                                @tSPID = bSPID,
                                @blkst = BLK_Status
                        FROM    #Catch_SPID
                        WHERE   bSPID > @tSPID
                        ORDER BY bSPID
 
                    END
 
            END