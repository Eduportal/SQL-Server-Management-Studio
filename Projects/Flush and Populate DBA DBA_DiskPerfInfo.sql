

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
SET	@ListTitle = 'DBA_DiskPerfInfo'

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


DECLARE	@SQLname nvarchar(128)
	,@MasterPath nvarchar(500)
	,@Master_Push_BytesSec bigint
	,@Master_Pull_BytesSec bigint
	,@MDFPath nvarchar(500)
	,@MDF_Push_BytesSec bigint
	,@MDF_Pull_BytesSec bigint
	,@LDFPath nvarchar(500)
	,@LDF_Push_BytesSec bigint
	,@LDF_Pull_BytesSec bigint
	,@TempdbPath nvarchar(500)
	,@Tempdb_Push_BytesSec bigint
	,@Tempdb_Pull_BytesSec bigint
	,@CreateDate datetime

DECLARE NewItemCursor CURSOR
FOR
SELECT		*
FROM		SEAFRESQLDBA01.dbaadmin.dbo.DBA_DiskPerfInfo




DECLARE @name varchar(40)
OPEN NewItemCursor

FETCH NEXT FROM NewItemCursor INTO @SQLname,@MasterPath,@Master_Push_BytesSec,@Master_Pull_BytesSec,@MDFPath,@MDF_Push_BytesSec,@MDF_Pull_BytesSec,@LDFPath,@LDF_Push_BytesSec,@LDF_Pull_BytesSec,@TempdbPath,@Tempdb_Push_BytesSec,@Tempdb_Pull_BytesSec,@CreateDate
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
		
		SET @Size = LEN(@SQLname+@MasterPath+@MDFPath+@LDFPath+@TempdbPath)+90

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

			,@nvarchar1 = @SQLname
			,@nvarchar3 = @MasterPath
			,@float1 = @Master_Push_BytesSec
			,@float2 = @Master_Pull_BytesSec
			,@nvarchar4 = @MDFPath
			,@float3 = @MDF_Push_BytesSec
			,@float4 = @MDF_Pull_BytesSec
			,@nvarchar5 = @LDFPath
			,@float5 = @LDF_Push_BytesSec
			,@float6 = @LDF_Pull_BytesSec
			,@nvarchar6 = @TempdbPath
			,@float7 = @Tempdb_Push_BytesSec
			,@float8 = @Tempdb_Pull_BytesSec
			,@datetime1 = @CreateDate

			,@tp_Modified = @TimeNow
			,@tp_Created = @TimeNow
			,@tp_ModerationStatus = 0
			,@Size = @Size
			,@ExtraItemSize = 0
			
			,@tp_InstanceID = 1
			,@tp_ContentType = 'Item'
			,@tp_ContentTypeId = 0x0100D7035EF13D43984981578788F0F762F7

	END
	FETCH NEXT FROM NewItemCursor INTO @SQLname,@MasterPath,@Master_Push_BytesSec,@Master_Pull_BytesSec,@MDFPath,@MDF_Push_BytesSec,@MDF_Pull_BytesSec,@LDFPath,@LDF_Push_BytesSec,@LDF_Pull_BytesSec,@TempdbPath,@Tempdb_Push_BytesSec,@Tempdb_Pull_BytesSec,@CreateDate
END

CLOSE NewItemCursor
DEALLOCATE NewItemCursor
GO
