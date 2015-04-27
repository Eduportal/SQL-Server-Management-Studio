
--set quoted_identifier on
--set arithabort off
--set numeric_roundabort off
--set ansi_warnings on
--set ansi_padding on
--set ansi_nulls on
--set concat_null_yields_null on
--set cursor_close_on_commit off
--set implicit_transactions off
--set language us_english
--set dateformat mdy
--set datefirst 7
--set transaction isolation level read committed

--EXEC dbo.InstallWorkItemWordsContains
select * From sysusers
/*

 "S-1-9-3-4132833348-1300388418-2870831243-3730709561."

*/

GO


GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
/*---------------------------------------------------------------------------
// Name: InstallWorkItemWordsContains
//
// Installs WorkItemWordsContains function (and FT catalog if needed).
//
// Arguments: None
//-------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.InstallWorkItemWordsContains
WITH EXECUTE AS 'TFSWITDDLADMIN'

, ENCRYPTION

AS
BEGIN
SET NOCOUNT ON

DECLARE @sql NVARCHAR(MAX)

DECLARE @isFullTextAvailable BIT

SELECT @isFullTextAvailable = CAST(SERVERPROPERTY('IsFullTextInstalled') AS BIT)

-- If FT available, we need to ensure that the catalog/index are present.
IF (@isFullTextAvailable = 1)
BEGIN
SET @sql = N'
-- If catalog does not exists, create it
if not exists (select * from sys.fulltext_catalogs where Name = N''TeamFoundationServer10FullTextCatalog'')
begin
CREATE FULLTEXT CATALOG TeamFoundationServer10FullTextCatalog AS DEFAULT
end

-- If table does not have a Full Text index, create it
if OBJECTPROPERTY(OBJECT_ID(N''WorkItemLongTexts''),N''TableFulltextCatalogId'') = 0
begin
declare @LCID as int
set @LCID = convert(int, (SELECT COLLATIONPROPERTY(convert(nvarchar(4000),DATABASEPROPERTYEX(DB_NAME(),''collation'')), ''LCID''))) & 0xFFFF

-- Default to Neutral if Language resource not available for Full Text
if not exists(select * from sys.fulltext_languages where lcid = @LCID)
begin
set @LCID = 0
end

-- Create Full Text index on the table (may fail if existing catalog is corrupt)
DECLARE @sql NVARCHAR(MAX)
SET @sql =   N''CREATE FULLTEXT INDEX ON WorkItemLongTexts(Words LANGUAGE '' + CAST(@LCID AS NVARCHAR) + '')
KEY INDEX UQ_WorkItemLongTexts_ChangedOrder --Unique index
WITH CHANGE_TRACKING AUTO''

EXEC SP_EXECUTESQL @sql
end
'

EXEC SP_EXECUTESQL @sql
END

-- Drop the function
SET @sql = N'IF EXISTS (SELECT * FROM sysobjects WHERE type in (''IF'', ''TF'', ''FN'') AND name =''WorkItemWordsContains'') drop function WorkItemWordsContains'
EXEC SP_EXECUTESQL @sql

-- pick up encrypt setting
DECLARE @encrypt NVARCHAR(255)
SET @encrypt = N''

SET @encrypt = 'WITH ENCRYPTION'


-- pick up the where clause.
DECLARE @whereClause NVARCHAR(255)
IF (@isFullTextAvailable = 0)
BEGIN
SET @whereClause = N'W.Words LIKE @pattern'
END
ELSE
BEGIN
SET @whereClause = N'contains (W.Words , @pattern)'
END

-- Create the function
SET @sql = N'
/*---------------------------------------------------------------------------
// Name: WorkItemWordsContains
//
// Returns a result set of the ID of WorkItems that have an entry contains the
// pattern in the latest value of the words column of a named field of the
// long text type as of a UTC time.
//
// Arguments:
//  @pattern    Pattern that is looked for in the Words column
//  @fieldID    ID of keyword field
//  @changeDate UTC datetime or null for current clock time.
//  @fEver      Zero if only latest entry is to be looked at
//
// Returns:
//      Single column table of int
//-------------------------------------------------------------------------*/
CREATE FUNCTION WorkItemWordsContains
(
@pattern nvarchar (4000)
,@fldID INT
,@changeDate datetime
,@fEver bit
)
returns @ids table
(
[System.ID] int primary key
)
' + @encrypt + '
AS
begin
declare @vers table
(
ID int
,[Changed Date] datetime
,FldID int
,primary key (ID,[Changed Date],FldID)
)


if @changeDate is null
insert into @vers
select distinct W.ID,W.[AddedDate],W.FldID
from dbo.WorkItemLongTexts W
where
' + @whereClause + '
and W.FldID = @fldID
else
insert into @vers
select distinct W.ID,W.[AddedDate],W.FldID
from dbo.WorkItemLongTexts W
where
' + @whereClause + '
and W.AddedDate <= @changeDate
and W.FldID = @fldID


if @fEver = 0
insert into @ids
select distinct ID
from @vers W
where not exists
(
select * from dbo.WorkItemLongTexts W2
where
W.ID = W2.ID
and W.FldID = W2.FldID
and W.[Changed Date] < W2.AddedDate
)
else
insert into @ids
select distinct ID
from @vers W

return
end'
EXEC SP_EXECUTESQL @sql

SELECT @isFullTextAvailable
END


GO
