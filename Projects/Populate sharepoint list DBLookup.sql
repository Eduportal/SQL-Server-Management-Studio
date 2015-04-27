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

SET @RowOrdinal = 0

SELECT	@ListID = tp_ID
	,@WebId = [tp_WebId]
	,@ServerTemplate = tp_ServerTemplate
FROM	dbo.Lists 
WHERE	tp_Title = 'DBLookup'

SELECT	@SiteId = SiteID
FROM	[dbo].[Webs] 
WHERE [Id] = @WebId

SELECT @UserId = [WSS_Content_eCommOps].[dbo].[fn_UserIDFromSid] (@SiteId,SUSER_SID('Amer\sledridge'))

SELECT * FROM [dbo].[Lists] WHERE [tp_Id] = @ListID
SELECT * FROM [dbo].[UserData] WHERE [tp_ListId] = @ListID

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


DECLARE	@DBName		NVARCHAR(255)
	,@ENVName	NVARCHAR(255)
	,@SQLName	NVARCHAR(255)
	,@Port		NVARCHAR(255)
	,@Link		NVARCHAR(255)

DECLARE NewItemCursor CURSOR
FOR
SELECT		DISTINCT
		UPPER(T1.DBName) DBName
		,UPPER(REPLACE(COALESCE(T2.SQLEnv,'Unknown'),'production','prod'))   ENVname
		,UPPER(T1.SQLName)   SQLName
		,CAST(T2.port AS VARCHAR(10))
		,UPPER(T1.SQLName)+ ',' + CAST(T2.port AS VARCHAR(10)) Link
FROM		SEAPSQLDBA01.dbacentral.dbo.DBA_DBInfo T1
LEFT JOIN	SEAPSQLDBA01.dbacentral.dbo.DBA_ServerInfo T2
	ON	T1.SQLName=T2.SQLName
WHERE		T2.ACTIVE = 'Y'	
ORDER BY	1,2,3


DECLARE @name varchar(40)
OPEN NewItemCursor

FETCH NEXT FROM NewItemCursor INTO @DBName,@ENVName,@SQLName,@Port,@Link	
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
		
		SET @Size = LEN(@DBName+@ENVName+@SQLName+@Port+@Link)

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
			,@nvarchar1 = @DBName
			,@nvarchar3 = @ENVName
			,@nvarchar4 = @SQLName
			,@nvarchar5 = @Port
			,@nvarchar6 = @Link

			,@tp_Modified = @TimeNow
			,@tp_Created = @TimeNow
			,@tp_ModerationStatus = 0
			,@Size = @Size
			,@ExtraItemSize = 0
			
			,@tp_InstanceID = 1
			,@tp_ContentType = 'Item'
			,@tp_ContentTypeId = 0x0100D7035EF13D43984981578788F0F762F7

		--PRINT @ItemDirName
		--PRINT @ItemLeafName
		--PRINT @NextAvailID
		--PRINT @ItemId
		--PRINT @DBName+'|'+@ENVName+'|'+@SQLName+'|'+@Port+'|'+@Link
		--PRINT ''
		
	END
	FETCH NEXT FROM NewItemCursor INTO @DBName,@ENVName,@SQLName,@Port,@Link
END

CLOSE NewItemCursor
DEALLOCATE NewItemCursor
GO
