

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

SET @RowOrdinal = 0

SELECT	@WebId = Id
	,@SiteId = SiteID
FROM	dbo.Webs 
WHERE	Title = 'DBA'

SELECT	@ListID = tp_ID
	,@ServerTemplate = tp_ServerTemplate
FROM	dbo.Lists 
WHERE	tp_Title = 'DBA_ClusterInfo'

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


DECLARE
	@SQLName NVARCHAR(255)
	,@ClusterName NVARCHAR(255)
	,@ClusterIP NVARCHAR(255)
	,@ClusterVer NVARCHAR(255)
	,@ClusterSvcAcct NVARCHAR(255)
	,@modDate NVARCHAR(255)
	,@Quorumgroup NVARCHAR(255)
	,@Quorumgroup_node NVARCHAR(255)
	,@Quorumgroup_status NVARCHAR(255)
	,@DTCgroup NVARCHAR(255)
	,@DTCgroup_node NVARCHAR(255)
	,@DTCgroup_status NVARCHAR(255)
	,@VirtSrv01 NVARCHAR(255)
	,@VirtSrv01_node NVARCHAR(255)
	,@VirtSrv01_status NVARCHAR(255)
	,@VirtSrv02 NVARCHAR(255)
	,@VirtSrv02_node NVARCHAR(255)
	,@VirtSrv02_status NVARCHAR(255)
	,@VirtSrv03 NVARCHAR(255)
	,@VirtSrv03_node NVARCHAR(255)
	,@VirtSrv03_status NVARCHAR(255)
	,@VirtSrv04 NVARCHAR(255)
	,@VirtSrv04_node NVARCHAR(255)
	,@VirtSrv04_status NVARCHAR(255)
	,@VirtSrv05 NVARCHAR(255)
	,@VirtSrv05_node NVARCHAR(255)
	,@VirtSrv05_status NVARCHAR(255)
	,@clustNode01 NVARCHAR(255)
	,@clustNode01_IP NVARCHAR(255)
	,@clustNode01_status NVARCHAR(255)
	,@clustNode02 NVARCHAR(255)
	,@clustNode02_IP NVARCHAR(255)
	,@clustNode02_status NVARCHAR(255)
	,@clustNode03 NVARCHAR(255)
	,@clustNode03_IP NVARCHAR(255)
	,@clustNode03_status NVARCHAR(255)
	,@clustNode04 NVARCHAR(255)
	,@clustNode04_IP NVARCHAR(255)
	,@clustNode04_status NVARCHAR(255)
	,@clustNode05 NVARCHAR(255)
	,@clustNode05_IP NVARCHAR(255)
	,@clustNode05_status NVARCHAR(255)

DECLARE NewItemCursor CURSOR
FOR
SELECT		*
FROM		SEAFRESQLDBA01.dbaadmin.dbo.DBA_ClusterInfo

DECLARE @name varchar(40)
OPEN NewItemCursor

FETCH NEXT FROM NewItemCursor INTO @SQLName,@ClusterName,@ClusterIP,@ClusterVer,@ClusterSvcAcct,@modDate,@Quorumgroup,@Quorumgroup_node,@Quorumgroup_status,@DTCgroup,@DTCgroup_node,@DTCgroup_status,@VirtSrv01,@VirtSrv01_node,@VirtSrv01_status,@VirtSrv02,@VirtSrv02_node,@VirtSrv02_status,@VirtSrv03,@VirtSrv03_node,@VirtSrv03_status,@VirtSrv04,@VirtSrv04_node,@VirtSrv04_status,@VirtSrv05,@VirtSrv05_node,@VirtSrv05_status,@clustNode01,@clustNode01_IP,@clustNode01_status,@clustNode02,@clustNode02_IP,@clustNode02_status,@clustNode03,@clustNode03_IP,@clustNode03_status,@clustNode04,@clustNode04_IP,@clustNode04_status,@clustNode05,@clustNode05_IP,@clustNode05_status	
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
		
		SET @Size = LEN(@SQLName+@ClusterName+@ClusterIP+@ClusterVer+@ClusterSvcAcct+@modDate+@Quorumgroup+@Quorumgroup_node+@Quorumgroup_status+@DTCgroup+@DTCgroup_node+@DTCgroup_status+@VirtSrv01+@VirtSrv01_node+@VirtSrv01_status+@VirtSrv02+@VirtSrv02_node+@VirtSrv02_status+@VirtSrv03+@VirtSrv03_node+@VirtSrv03_status+@VirtSrv04+@VirtSrv04_node+@VirtSrv04_status+@VirtSrv05+@VirtSrv05_node+@VirtSrv05_status+@clustNode01+@clustNode01_IP+@clustNode01_status+@clustNode02+@clustNode02_IP+@clustNode02_status+@clustNode03+@clustNode03_IP+@clustNode03_status+@clustNode04+@clustNode04_IP+@clustNode04_status+@clustNode05+@clustNode05_IP+@clustNode05_status)

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
			,@nvarchar3 = @ClusterName
			,@nvarchar4 = @ClusterIP
			,@nvarchar5 = @ClusterVer
			,@nvarchar6 = @ClusterSvcAcct
			,@datetime1 = @modDate
			,@nvarchar7 = @Quorumgroup        
			,@nvarchar8 = @Quorumgroup_node   
			,@nvarchar9 = @Quorumgroup_status 
			,@nvarchar10 = @DTCgroup          
			,@nvarchar11 = @DTCgroup_node     
			,@nvarchar12 = @DTCgroup_status   
			,@nvarchar13 = @VirtSrv01         
			,@nvarchar14 = @VirtSrv01_node    
			,@nvarchar15 = @VirtSrv01_status  
			,@nvarchar16 = @VirtSrv02         
			,@nvarchar17 = @VirtSrv02_node    
			,@nvarchar18 = @VirtSrv02_status  
			,@nvarchar19 = @VirtSrv03         
			,@nvarchar20 = @VirtSrv03_node    
			,@nvarchar21 = @VirtSrv03_status  
			,@nvarchar22 = @VirtSrv04         
			,@nvarchar23 = @VirtSrv04_node    
			,@nvarchar24 = @VirtSrv04_status  
			,@nvarchar25 = @VirtSrv05         
			,@nvarchar26 = @VirtSrv05_node    
			,@nvarchar27 = @VirtSrv05_status  
			,@nvarchar28 = @clustNode01       
			,@nvarchar29 = @clustNode01_IP    
			,@nvarchar30 = @clustNode01_status
			,@nvarchar31 = @clustNode02       
			,@nvarchar32 = @clustNode02_IP    
			,@nvarchar33 = @clustNode02_status
			,@nvarchar34 = @clustNode03       
			,@nvarchar35 = @clustNode03_IP    
			,@nvarchar36 = @clustNode03_status
			,@nvarchar37 = @clustNode04       
			,@nvarchar38 = @clustNode04_IP    
			,@nvarchar39 = @clustNode04_status
			,@nvarchar40 = @clustNode05       
			,@nvarchar41 = @clustNode05_IP    
			,@nvarchar42 = @clustNode05_status


			,@tp_Modified = @TimeNow
			,@tp_Created = @TimeNow
			,@tp_ModerationStatus = 0
			,@Size = @Size
			,@ExtraItemSize = 0
			
			,@tp_InstanceID = 1
			,@tp_ContentType = 'Item'
			,@tp_ContentTypeId = 0x0100D7035EF13D43984981578788F0F762F7

	END
	FETCH NEXT FROM NewItemCursor INTO @SQLName,@ClusterName,@ClusterIP,@ClusterVer,@ClusterSvcAcct,@modDate,@Quorumgroup,@Quorumgroup_node,@Quorumgroup_status,@DTCgroup,@DTCgroup_node,@DTCgroup_status,@VirtSrv01,@VirtSrv01_node,@VirtSrv01_status,@VirtSrv02,@VirtSrv02_node,@VirtSrv02_status,@VirtSrv03,@VirtSrv03_node,@VirtSrv03_status,@VirtSrv04,@VirtSrv04_node,@VirtSrv04_status,@VirtSrv05,@VirtSrv05_node,@VirtSrv05_status,@clustNode01,@clustNode01_IP,@clustNode01_status,@clustNode02,@clustNode02_IP,@clustNode02_status,@clustNode03,@clustNode03_IP,@clustNode03_status,@clustNode04,@clustNode04_IP,@clustNode04_status,@clustNode05,@clustNode05_IP,@clustNode05_status
END

CLOSE NewItemCursor
DEALLOCATE NewItemCursor

GO
