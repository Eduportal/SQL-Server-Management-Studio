
USE dbaadmin;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE NAME = 'dbaudf_ConvertToExtents')
   DROP FUNCTION dbaudf_ConvertToExtents;
GO


-- This function cracks the output from a DBCC PAGE dump
-- of an allocation bitmap. It takes a string in the form
-- "(1:8) -- (1:16)" or "(1:8) -" and returns the number
-- of extents represented by the string. Both the examples
-- above equal 1 extent.
--


CREATE FUNCTION dbaudf_ConvertToExtents (
   @extents VARCHAR (100))
RETURNS INTEGER
AS
BEGIN
   DECLARE @extentTotal   INT;
   DECLARE @colon         INT;
   DECLARE @firstExtent   INT;
   DECLARE @secondExtent  INT;


   SET @extentTotal = 0;
   SET @colon = CHARINDEX (':', @extents);

   -- Check for the single extent case
   --
   IF (CHARINDEX (':', @extents, @colon + 1) = 0)
      SET @extentTotal = 1;
   ELSE
      -- We're in the multi-extent case
      --
      BEGIN
      SET @firstExtent = CONVERT (INT,
         SUBSTRING (@extents, @colon + 1, CHARINDEX (')', @extents, @colon) - @colon - 1));
      SET @colon = CHARINDEX (':', @extents, @colon + 1);
      SET @secondExtent = CONVERT (INT,
         SUBSTRING (@extents, @colon + 1, CHARINDEX (')', @extents, @colon) - @colon - 1));
      SET @extentTotal = (@secondExtent - @firstExtent) / 8 + 1;
   END

   RETURN @extentTotal;
END;
GO


USE master;
GO


IF OBJECT_ID ('sp_DIFForFULL') IS NOT NULL
   DROP PROCEDURE sp_DIFForFULL;
GO


-- This SP cracks all differential bitmap pages for all online
-- data files in a database. It creates a sum of changed extents
-- and reports it as follows (example small dbaadmin):
-- 
-- EXEC sp_DIFForFULL 'dbaadmin';
-- GO
--
-- Total Extents Changed Extents Percentage Changed
-- ————- ————— ———————-
-- 102           56              54.9
--
-- Note that after a full backup you will always see some extents
-- marked as changed. The number will be 4 + (number of data files -- 1).
-- These extents contain the file headers of each file plus the
-- roots of some of the critical system tables in file 1.
-- The number for dbaadmin may be round 20.
--
CREATE PROCEDURE sp_DIFForFULL (
   @dbName VARCHAR (128))
AS
BEGIN
   SET NOCOUNT ON;


   -- Create the temp table
   --
   IF EXISTS (SELECT * FROM dbaadmin.sys.objects WHERE NAME = 'DBCCPage')
   DROP TABLE dbaadmin.dbo.DBCCPage;

   CREATE TABLE dbaadmin.dbo.DBCCPage (
      [ParentObject] VARCHAR (100),
      [Object]       VARCHAR (100),
      [Field]        VARCHAR (100),
      [VALUE]        VARCHAR (100));

   DECLARE @fileID         INT;
   DECLARE @fileSizePages  INT;
   DECLARE @extentID       INT;
   DECLARE @pageID         INT;
   DECLARE @DIFFTotal      INT;
   DECLARE @sizeTotal      INT;
   DECLARE @total          INT;
   DECLARE @dbccPageString VARCHAR (200);

   SELECT @DIFFTotal = 0;
   SELECT @sizeTotal = 0;

   -- Setup a cursor for all online data files in the database
   --
   DECLARE files CURSOR FOR
      SELECT [file_id], [size] FROM master.sys.master_files
      WHERE [type_desc] = 'ROWS'
      AND [state_desc] = 'ONLINE'
      AND [database_id] = DB_ID (@dbName);

   OPEN files;

   FETCH NEXT FROM files INTO @fileID, @fileSizePages;

   WHILE @@FETCH_STATUS = 0
   BEGIN
      SELECT @extentID = 0;

      -- The size returned from master.sys.master_files is in
      -- pages -- we need to convert to extents
      --
      SELECT @sizeTotal = @sizeTotal + @fileSizePages / 8;

      WHILE (@extentID < @fileSizePages)
      BEGIN
         -- There may be an issue with the DIFF map page position
         -- on the four extents where PFS pages and GAM pages live
         -- (at page IDs 516855552, 1033711104, 1550566656, 2067422208)
         -- but I think we'll be ok.
         -- PFS pages are every 8088 pages (page 1, 8088, 16176, etc)
         -- GAM extents are every 511232 pages
         --
         SELECT @pageID = @extentID + 6;

         -- Build the dynamic SQL
         --
         SELECT @dbccPageString = 'DBCC PAGE ('
            + @dbName + ', '
            + CAST (@fileID AS VARCHAR) + ', '
            + CAST (@pageID AS VARCHAR) + ', 3) WITH TABLERESULTS, NO_INFOMSGS';

         -- Empty out the temp table and insert into it again
         --
         DELETE FROM dbaadmin.dbo.DBCCPage;
         INSERT INTO dbaadmin.dbo.DBCCPage EXEC (@dbccPageString);

         -- Aggregate all the changed extents using the function
         --
         SELECT @total = SUM ([dbaadmin].[dbo].[dbaudf_ConvertToExtents] ([Field]))
         FROM dbaadmin.dbo.DBCCPage
            WHERE [VALUE] = '    CHANGED'
            AND [ParentObject] LIKE 'DIFF_MAP%';

         SET @DIFFTotal = @DIFFTotal + @total;

         -- Move to the next GAM extent
         SET @extentID = @extentID + 511232;
      END

      FETCH NEXT FROM files INTO @fileID, @fileSizePages;
   END;

   -- Clean up
   --
   DROP TABLE dbaadmin.dbo.DBCCPage;
   CLOSE files;
   DEALLOCATE files;

   -- Output the results
   --
   SELECT
      @sizeTotal AS [Total Extents],
      @DIFFTotal AS [Changed Extents],
      ROUND (
         (CONVERT (FLOAT, @DIFFTotal) /
         CONVERT (FLOAT, @sizeTotal)) * 100, 2) AS [Percentage Changed];
END;
GO


-- Mark the SP as a system object
--
EXEC sys.sp_MS_marksystemobject sp_DIFForFULL;
GO


-- Test to make sure everything was setup correctly
--
EXEC sp_DIFForFULL 'dbaadmin';
GO