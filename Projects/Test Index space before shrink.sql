-----------------------------------------------------------------------------------
-- Script to Indentify tables/index that will be affected by a shrinkfile.
-- 
-- This script calls "DBCC IND" against all indexes/heaps in the same filegroup as the target file,
--  identifying how many pages/mb from each would be moved by a shrinkfile.  
--
--
-- Parameters:
-- @target_file_id  -- file_id from sys.database_files corresponding to the file to be shrunk.
-- @target_file_size_in_MB -- the target size in MB of the file
--
-- Returns 2 Resultsets:
--		1. Summary information including the amount of data that would be moved
--		2. Detail information per affected index including pages/mb total, and 
--         pages/mb of non-clustered-indexes
--
------------------------------------------------------------------------------------
SET NOCOUNT ON


DECLARE @target_file_id INT
DECLARE @target_file_size_in_MB INT

IF OBJECT_ID('tempdb..#DataFileStats') IS NOT NULL DROP TABLE #DataFileStats

CREATE TABLE #DataFileStats 
([FileId] TINYINT, 
[FileGroup] TINYINT, 
[TotalExtents] DEC(20,2),
[UsedExtents] DEC(20,2),
[Name] VARCHAR(255), 
[FileName] VARCHAR(400))

INSERT #DataFileStats (FileId,[FileGroup],TotalExtents,UsedExtents,[Name],[FileName])
EXECUTE('DBCC SHOWFILESTATS WITH NO_INFOMSGS')

SELECT [FileId],[Name],[UsedExtents]*64/1024.00 AS [SpaceUsed_MB]
FROM #DataFileStats

SET @target_file_id = 0

StartFileLoop:

--Parameters, shrink file 3 to 7 GB.
SELECT		TOP 1
			@target_file_id				= [FileId]
			,@target_file_size_in_MB	= [UsedExtents]*64/1024.00 + 1
FROM		#DataFileStats
WHERE		[FileId] > @target_file_id

If @Target_file_id IS NULL
	goto ExitFileLoop

--Temp table to hold output of DBCC IND
IF OBJECT_ID('tempdb..#IndexPages', 'table') IS NOT NULL 
    DROP TABLE #IndexPages

CREATE TABLE #IndexPages
    (
      [PageFID] [tinyint] NOT NULL
    , [PagePID] [int] NOT NULL
    , [IAMFID] [tinyint] NULL
    , [IAMPID] [int] NULL
    , [ObjectID] [int] NULL
    , [IndexID] [int] NULL
    , [PartitionNumber] [tinyint] NULL
    , [PartitionID] [bigint] NULL
    , [iam_chain_type] [varchar](30) NULL
    , [PageType] [tinyint] NULL
    , [IndexLevel] [tinyint] NULL
    , [NextPageFID] [tinyint] NULL
    , [NextPagePID] [int] NULL
    , [PrevPageFID] [tinyint] NULL
    , [PrevPagePID] [int] NULL
    , CONSTRAINT [IndexPages_PK2] PRIMARY KEY CLUSTERED ( [PageFID] ASC, [PagePID] ASC )
    )

--Use cursor to iterate over all indexes, populating table.
DECLARE curDbcc CURSOR STATIC FORWARD_ONLY
FOR
    SELECT DISTINCT -- distinct required for partitioned data
        'INSERT  INTO #IndexPages
        EXEC ( ' + QUOTENAME(+'DBCC IND ([' + DB_NAME() + '], ''[' + s.NAME + '].[' 
        + t.name + ']'', ' + CAST(index_id AS VARCHAR(10)) + ')', '''') + ')' dbcc_ind_sql
    FROM
        sys.schemas s
        INNER JOIN sys.tables t ON s.schema_id = t.schema_id
        INNER JOIN sys.indexes i ON t.object_id = i.object_id
        INNER JOIN --Only scan indexes on the same filegroup as the @target_file_id
        ( SELECT
            partition_scheme_id source_data_space_id
          , data_space_id destination_data_space_id
          FROM
            sys.destination_data_spaces
          UNION
          SELECT
            data_space_id
          , data_space_id
          FROM
            sys.data_spaces
          WHERE
            type = 'FG'
        ) ds ON i.data_space_id = ds.source_data_space_id
        INNER JOIN sys.database_files df ON df.file_id = @target_file_id
                                            AND df.data_space_id = ds.destination_data_space_id

    
DECLARE @dbcc_sql NVARCHAR(MAX)

OPEN curDbcc
FETCH NEXT FROM curDbcc INTO @dbcc_sql

WHILE @@fetch_Status = 0 
    BEGIN
           EXEC sp_executesql @dbcc_sql
        FETCH NEXT FROM curDbcc INTO @dbcc_sql
    END
CLOSE curDbcc
DEALLOCATE curDbcc


DECLARE @starting_page_to_clear INT


SET @starting_page_to_clear = @target_file_size_in_MB * 1024 / 8

SELECT
    size file_size_in_pages
  , size / 128 file_size_in_mb
  , @starting_page_to_clear target_file_size_in_pages
  , @target_file_size_in_MB target_file_size_in_mb
  , ( size - @starting_page_to_clear ) pages_to_shrink
  , ( size - @starting_page_to_clear ) / 128 mb_to_shrink
  , ( SELECT
        COUNT(*)
      FROM
        #IndexPages
      WHERE
        PageFID = @target_file_id
        AND PagePID >= @starting_page_to_clear
    ) pages_to_move
  , ( SELECT
        COUNT(*)
      FROM
        #IndexPages
      WHERE
        PageFID = @target_file_id
        AND PagePID >= @starting_page_to_clear
    ) / 128 mb_to_move
FROM
    sys.database_files
WHERE
    file_id = @target_file_id

SELECT
    s.NAME schema_name
  , t.NAME table_name
  , i.NAME index_name
  , COUNT(*) total_pages_to_move
  , SUM(CASE WHEN index_id > 1 THEN 1
             ELSE 0
        END) non_clus_index_pages_to_move
  , COUNT(*) / 128.0 total_mb_to_move
  , SUM(CASE WHEN index_id > 1 THEN 1
             ELSE 0
        END) / 128.0 non_clus_index_mb_to_move
FROM
    sys.schemas s
    INNER JOIN sys.tables t ON s.schema_id = t.schema_id
    INNER JOIN sys.indexes i ON t.object_id = i.object_id
    INNER JOIN #IndexPages ip ON ip.ObjectID = t.object_id
                                 AND ip.IndexID = i.index_id
WHERE
    PageFID = @target_file_id
    AND PagePID >= @starting_page_to_clear
GROUP BY
    s.NAME
  , t.NAME
  , i.name
HAVING
    COUNT(*) > 0
ORDER BY
    SUM(CASE WHEN index_id > 1 THEN 1
             ELSE 0
        END) DESC
	
goto StartFileLoop

ExitFileLoop:

PRINT 'Done Checking.'