

SET NOCOUNT ON

DECLARE @RC int
DECLARE @SiteId uniqueidentifier
DECLARE @WebId uniqueidentifier
DECLARE @ListID UNIQUEIDENTIFIER
DECLARE @UserId int
DECLARE @ServerTemplate int
DECLARE @Id INT
DECLARE @ItemId INT
DECLARE @UseNvarchar1ItemName bit
DECLARE @AuditIfNecessary bit
DECLARE @UserTitle nvarchar(255)
DECLARE @Version int
DECLARE @NeedsAuthorRestriction bit
DECLARE @Basetype int
DECLARE @DeleteOp int
DECLARE @DeleteTransactionId varbinary(16)
DECLARE @Size BIGINT
DECLARE @NextAvailID INT
DECLARE @ItemDirName nvarchar(256)
DECLARE @ItemLeafName nvarchar(128)
DECLARE @TimeNow DATETIME
DECLARE @tp_GUID UNIQUEIDENTIFIER
DECLARE @RowOrdinal int
DECLARE @Columns1 VARCHAR(MAX)
DECLARE @Columns2 VARCHAR(MAX)
DECLARE @Columns3 VARCHAR(MAX)
DECLARE @Columns4 VARCHAR(MAX)
DECLARE	@Counter INT
DECLARE @WebTitle VARCHAR(255)
DECLARE @ListTitle VARCHAR(255)

DECLARE	@Counter_nvarchar	INT
DECLARE	@Counter_datetime	INT
DECLARE	@Counter_ntext		INT
DECLARE	@Counter_float		INT
DECLARE	@Counter_int		INT
DECLARE	@Counter_bit		INT

SET	@Counter_nvarchar	= 0
SET	@Counter_datetime	= 0
SET	@Counter_ntext		= 0
SET	@Counter_float		= 0
SET	@Counter_int		= 0
SET	@Counter_bit		= 0

SET	@WebTitle = 'DBA'
SET	@ListTitle = 'DBA_DBInfo'

SET @RowOrdinal = 0

SELECT	@WebId = Id
	,@SiteId = SiteID
FROM	dbo.Webs 
WHERE	Title = @WebTitle

SELECT	@ListID = tp_ID
	,@ServerTemplate = tp_ServerTemplate
FROM	dbo.Lists 
WHERE	tp_Title = @ListTitle

SELECT @UserId = [WSS_Content_eCommOps].[dbo].[fn_UserIDFromSid] (@SiteId,SUSER_SID('Amer\sledridge'))

SELECT	TOP 1
	@ItemId = COALESCE(tp_ID,0)
FROM	dbo.UserData
WHERE	tp_ListId = @ListID
ORDER BY [tp_ID] DESC

WHILE @ItemId > 0
BEGIN
	EXECUTE @RC = [WSS_Content_eCommOps].[dbo].[proc_DropListRecord] 
		@SiteId = @SiteId
		,@WebId = @WebId
		,@ListId = @ListId
		,@ServerTemplate = @ServerTemplate
		,@Id = @ItemId
		,@UserId = @UserId
		,@UserTitle = NULL

	SET @ItemId = NULL
	
	SELECT	TOP 1
		@ItemId = COALESCE(tp_ID,0)
	FROM	dbo.UserData
	WHERE	tp_ListId = @ListID
	ORDER BY [tp_ID] Desc
END


UPDATE dbo.Lists
	SET tp_NextAvailableID = 1
WHERE tp_ID = @ListID


DECLARE	@SQLName nvarchar(128)
	,@DBName nvarchar(128)
	,@status nvarchar(128)
	,@CreateDate datetime
	,@ENVname nvarchar(128)
	,@ENVnum nvarchar(128)
	,@Appl_desc nvarchar(128)
	,@BaselineFolder nvarchar(128)
	,@BaselineServername nvarchar(128)
	,@BaselineDate nvarchar(128)
	,@build nvarchar(128)
	,@data_size_MB nvarchar(18)
	,@log_size_MB nvarchar(18)
	,@row_count bigint
	,@RecovModel nvarchar(128)
	,@FullTextCat char(1)
	,@Assemblies char(1)
	,@Mirroring char(1)
	,@Repl_Flag char(1)
	,@LogShipping char(1)
	,@ReportingSvcs char(1)
	,@StartupSprocs char(1)
	,@modDate datetime
	,@DBCompat nvarchar(10)
	,@DEPLstatus char(1)

DECLARE NewItemCursor CURSOR
FOR
SELECT		*
FROM		SEAFRESQLDBA01.dbaadmin.dbo.DBA_DBInfo


DECLARE @name varchar(40)
OPEN NewItemCursor

FETCH NEXT FROM NewItemCursor INTO @SQLName,@DBName,@status,@CreateDate,@ENVname,@ENVnum,@Appl_desc,@BaselineFolder,@BaselineServername,@BaselineDate,@build,@data_size_MB,@log_size_MB,@row_count,@RecovModel,@FullTextCat,@Assemblies,@Mirroring,@Repl_Flag,@LogShipping,@ReportingSvcs,@StartupSprocs,@modDate,@DBCompat,@DEPLstatus
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET @RowOrdinal = @RowOrdinal + 1
		SET @TimeNow = GETDATE()
		SET @tp_GUID = NEWID()
		
		Select @NextAvailID = tp_NextAvailableID
		From dbo.Lists
		WHERE tp_ID = @ListID
		
		SET @Size = LEN(@SQLName+@DBName+@status+@ENVname+@ENVnum+@Appl_desc+@BaselineFolder+@BaselineServername+@BaselineDate+@build+@data_size_MB+@log_size_MB+@RecovModel+@FullTextCat+@Assemblies+@Mirroring+@Repl_Flag+@LogShipping+@ReportingSvcs+@StartupSprocs+@DBCompat+@DEPLstatus)+40

		SET @ItemId = NULL
		SET @ItemDirName = NULL
		SET @ItemLeafName = NULL
					
		EXECUTE @RC = [WSS_Content_eCommOps].[dbo].[proc_AddListItem]
			@SiteId = @SiteId
			,@WebId = @WebId
			,@ListID = @ListID
			,@RowOrdinal = 0--@RowOrdinal
			,@ItemId = @ItemId OUTPUT
			,@ItemDirName = @ItemDirName OUTPUT
			,@ItemLeafName = @ItemLeafName OUTPUT
			,@UserID = @UserID
			,@TimeNow = @TimeNow
			,@ServerTemplate = @ServerTemplate
			,@Basetype= 0
			,@Level= 1
			,@tp_GUID = @tp_GUID
			,@AddNamespace = 1
			,@CheckDiskQuota = 1
			,@tp_ID = @NextAvailID

			,@nvarchar1 = @SQLName
			,@nvarchar3 = @DBName
			,@nvarchar4 = @status
			,@datetime1 = @CreateDate
			,@nvarchar5 = @ENVname
			,@nvarchar6 = @ENVnum
			,@nvarchar7 = @Appl_desc
			,@nvarchar8 = @BaselineFolder
			,@nvarchar9 = @BaselineServername
			,@nvarchar10 = @BaselineDate
			,@nvarchar11 = @build
			,@nvarchar12 = @data_size_MB
			,@nvarchar13 = @log_size_MB
			,@float1 = @row_count
			,@nvarchar14 = @RecovModel
			,@nvarchar15 = @FullTextCat
			,@nvarchar16 = @Assemblies
			,@nvarchar17 = @Mirroring
			,@nvarchar18 = @Repl_Flag
			,@nvarchar19 = @LogShipping
			,@nvarchar20 = @ReportingSvcs
			,@nvarchar21 = @StartupSprocs
			,@datetime2 = @modDate
			,@nvarchar22 = @DBCompat
			,@nvarchar23 = @DEPLstatus

			,@tp_Modified = @TimeNow
			,@tp_Created = @TimeNow
			,@tp_ModerationStatus = 0
			,@Size = @Size
			,@ExtraItemSize = 0
			
			,@tp_InstanceID = 1
			,@tp_ContentType = 'Item'
			,@tp_ContentTypeId = 0x0100D7035EF13D43984981578788F0F762F7

	END
	FETCH NEXT FROM NewItemCursor INTO @SQLName,@DBName,@status,@CreateDate,@ENVname,@ENVnum,@Appl_desc,@BaselineFolder,@BaselineServername,@BaselineDate,@build,@data_size_MB,@log_size_MB,@row_count,@RecovModel,@FullTextCat,@Assemblies,@Mirroring,@Repl_Flag,@LogShipping,@ReportingSvcs,@StartupSprocs,@modDate,@DBCompat,@DEPLstatus
END

CLOSE NewItemCursor
DEALLOCATE NewItemCursor

GO
