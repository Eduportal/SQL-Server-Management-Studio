SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/**************************************************************

    sp_DATABASE_INFORMATION   -- provides information about

    DEVELOPER LOG:
        DPENTON        2001.05.31        Creation
**************************************************************/
CREATE PROCEDURE [dbo].[sp_DATABASE_INFORMATION]
AS
BEGIN

    SET NOCOUNT ON

    -- display database only information
    CREATE TABLE #tempA (
        "name" sysname
        , "db_size" varchar(13)
        , "owner" nvarchar (24)
        , "db_id" int
        , "created" datetime --varchar (11)
        , "status" varchar(2048)
        , "compatibility_level" char(2)
    )

    INSERT INTO #tempA (
        "name", "db_size", "owner", "db_id", "created", "status", "compatibility_level"
    )
    EXEC sp_helpdb

    SELECT
        CONVERT(nvarchar(22), "name") "name"
        , "db_size"
        , "owner"
        , "compatibility_level"
        , CAST(databasepropertyex("name", 'recovery') as char(12)) "Recovery"
        , CAST(databasepropertyex("name", 'status') as char(12)) "Status"
        , CASE databasepropertyex("name", 'IsAnsiNullDefault') WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE 'N/A' END "AnsiNulls"
        , CASE databasepropertyex("name", 'IsAnsiWarningsEnabled') WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE 'N/A' END "AnsiWarn"
        , CAST(databasepropertyex("name", 'Updateability') as char(12)) "Updateability"
        , CAST(databasepropertyex("name", 'UserAccess') as char(12)) "UserAccess"
        , CASE databasepropertyex("name", 'IsQuotedIdentifiersEnabled') WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE 'N/A' END "QuotedIdent"
        , CASE databasepropertyex("name", 'IsNullConcat') WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE 'N/A' END "NullConcat"
        , CASE databasepropertyex("name", 'IsFulltextEnabled') WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE 'N/A' END "FullText"
        , CASE databasepropertyex("name", 'IsCloseCursorsOnCommitEnabled') WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE 'N/A' END "CloseCursorOnCommit"
        , CASE databasepropertyex("name", 'IsAutoShrink') WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE 'N/A' END "AutoShrink"
        , CASE databasepropertyex("name", 'IsAutoUpdateStatistics') WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE 'N/A' END "AutoUpdateStats"
        , CASE databasepropertyex("name", 'IsAutoCreateStatistics') WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE 'N/A' END "AutoCreateStats"
    FROM
        #tempA
    ORDER BY
        2 DESC

    DROP TABLE #tempA

    -- display log information
    CREATE TABLE #tempB (
        "Database Name" nvarchar(384) --sysname
        , "Log Size (MB)" varchar(18) --decimal (13, 6)
        , "Log Space Used (%)" decimal (13, 6)
        , "Status" int
    )

    INSERT INTO #tempB
    EXEC sp_executesql N'DBCC SQLPERF (LOGSPACE)'

    SELECT *
    FROM
        #tempB
    ORDER BY
        3 DESC

    DROP TABLE #tempB

    -- display file information
    EXEC sp_MSforeachdb
    @command1 = 'INSERT INTO ##tempforsysfiles
    SELECT
        ''?'' [db_name]
        , CAST(CAST([size] / 128.0 AS decimal (12, 2)) as varchar(13)) +
        CASE [growth] WHEN 0 THEN '', Fixed'' ELSE
            CASE [maxsize] WHEN 0  THEN '', Fixed''
                WHEN -1 THEN '', Unlimited''
                ELSE '', Max: '' + CAST([maxsize] / 128 AS varchar(10)) END
            END +
        CASE [growth] WHEN 0 THEN ''''
          ELSE '', Growth: '' + 
            CASE [status] & 0x100000 WHEN 0x100000 THEN CAST([growth] as varchar) + ''%'' ELSE CAST(CEILING([growth] / 128.0) as varchar) END
        END [Size Info (MB)]
        , [fileid], RTRIM([name]) [name], RTRIM([filename]) [filename]
    FROM
        [?].[dbo].[sysfiles]'
    , @precommand = 'CREATE TABLE ##tempforsysfiles ([db_name] nchar(50), [Size Info (MB)] varchar(35), [fileid] int, [name] nvarchar(50), [filename] nvarchar(260))'
    , @postcommand = 'SELECT * FROM ##tempforsysfiles ORDER BY 1, 3; DROP TABLE ##tempforsysfiles'

    SET NOCOUNT OFF

    RETURN (0)

END
GO

