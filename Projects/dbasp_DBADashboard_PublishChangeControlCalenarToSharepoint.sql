CREATE PROCEDURE dbasp_DBADashboard_PublishChangeControlCalenarToSharepoint
AS

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

DECLARE		@DateReceived			DateTime
			,@StartTime				DateTime
			,@ENDTime				DateTime
			,@DateResolved			DateTime
			,@Ticket				VarChar(500)
			,@Subject				VarChar(500)
			,@Description			varchar(max)
			,@TicketMask			VarChar(500)
			,@Sender				VarChar(500)
			,@SenderID				VarChar(500)
			,@SenderIDMask	        VarChar(500)
			,@Priority				VarChar(500)
			,@CurrentWorkflowStage  VarChar(500)
			,@Category1				VarChar(500)
			,@Category2				VarChar(500)
			,@Category3				VarChar(500)
			,@Service				VarChar(500)
			,@DateUpdated			DateTime
			,@Handler				VarChar(500)
			,@Status				VarChar(500)
			,@TS_DBA_Notes			BIT
			,@TS_DBA_Assign         BIT
			,@TS_DBA_Create         BIT



SET @RowOrdinal = 0

SELECT	@ListID = tp_ID
	,@WebId = [tp_WebId]
	,@ServerTemplate = tp_ServerTemplate
FROM	[WSS_Content_eCommOps].dbo.Lists 
WHERE	tp_Title = 'ChangeControls'

SELECT	@SiteId = SiteID
FROM	[WSS_Content_eCommOps].[dbo].[Webs] 
WHERE [Id] = @WebId

SELECT @UserId = [WSS_Content_eCommOps].[dbo].[fn_UserIDFromSid] (@SiteId,SUSER_SID('Amer\sledridge'))

--SELECT * FROM [WSS_Content_eCommOps].[dbo].[Lists] WHERE [tp_Id] = @ListID
--SELECT * FROM [WSS_Content_eCommOps].[dbo].[UserData] WHERE [tp_ListId] = @ListID

SELECT	TOP 1
	@ItemId = COALESCE(tp_ID,0)
FROM	[WSS_Content_eCommOps].dbo.UserData
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
	FROM	[WSS_Content_eCommOps].dbo.UserData
	WHERE	tp_ListId = @ListID
	ORDER BY [tp_ID] Desc
END


UPDATE [WSS_Content_eCommOps].dbo.Lists
	SET tp_NextAvailableID = 1
WHERE tp_ID = @ListID



DECLARE NewItemCursor CURSOR
FOR
SELECT		[Date Received]
			,[Start Time]
			,[END Time]
			,[Date Resolved]
			,[Ticket]
			,[Subject]
			,[Description]
			,REPLACE([Ticket Mask],'{0}',[Ticket]) [Ticket Mask]
			,[Sender]
			,[Sender ID]
			,[Sender ID Mask]
			,[Priority]
			,[Current Workflow Stage]
			,[Category 1]
			,[Category 2]
			,[Category 3]
			,[Service]
			,[Date Updated]
			,[Handler]
			,[Status]
			,[TS_DBA_Notes]
			,[TS_DBA_Assign]
			,[TS_DBA_Create]

FROM		[SEAINTRASQL01].[users].[dbo].[DBA_Dashboard_TicketDetails_CC_Calendar] 
ORDER BY	5

DECLARE @name varchar(40)
OPEN NewItemCursor


FETCH NEXT FROM NewItemCursor INTO @DateReceived,@StartTime,@ENDTime,@DateResolved,@Ticket,@Subject,@Description,@TicketMask,@Sender,@SenderID,@SenderIDMask,@Priority,@CurrentWorkflowStage,@Category1,@Category2,@Category3,@Service,@DateUpdated,@Handler,@Status,@TS_DBA_Notes,@TS_DBA_Assign,@TS_DBA_Create

WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET @RowOrdinal = @RowOrdinal + 1
		SET @TimeNow = GETDATE()
		SET @tp_GUID = NEWID()
		
		Select @NextAvailID = tp_NextAvailableID
		From [WSS_Content_eCommOps].dbo.Lists
		WHERE tp_ID = @ListID
		
	SET	@Size	= ISNULL(LEN(@DateReceived),0)
				+ ISNULL(LEN(@StartTime),0)
				+ ISNULL(LEN(@ENDTime),0)
				+ ISNULL(LEN(@DateResolved),0)
				+ ISNULL(LEN(@Ticket),0)
				+ ISNULL(LEN(@Subject),0)
				+ ISNULL(LEN(@Description),0)
				+ ISNULL(LEN(@TicketMask),0)
				--+ ISNULL(LEN(@Sender),0)
				--+ ISNULL(LEN(@SenderID),0)
				--+ ISNULL(LEN(@SenderIDMask),0)
				+ ISNULL(LEN(@Priority),0)
				+ ISNULL(LEN(@CurrentWorkflowStage),0)
				+ ISNULL(LEN(@Category1),0)
				+ ISNULL(LEN(@Category2),0)
				+ ISNULL(LEN(@Category3),0)
				+ ISNULL(LEN(@Service),0)
				+ ISNULL(LEN(@DateUpdated),0)
				+ ISNULL(LEN(@Handler),0)
				+ ISNULL(LEN(@Status),0)
				+ ISNULL(LEN(@TS_DBA_Notes),0)
				+ ISNULL(LEN(@TS_DBA_Assign),0)
				+ ISNULL(LEN(@TS_DBA_Create),0)        

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

			,@datetime4 = @DateReceived			
			,@datetime1 = @StartTime				
			,@datetime2 = @ENDTime				
			,@datetime5 = @DateResolved			
			,@nvarchar1 = @Ticket				
			,@nvarchar3 = @Subject				
			,@ntext2 = @Description			
			,@nvarchar6 = @TicketMask			
			--,@Sender				
			--,@SenderID				
			--,@SenderIDMask	        
			,@nvarchar8 = @Priority				
			,@nvarchar9 = @CurrentWorkflowStage  
			,@nvarchar10 = @Category1				
			,@nvarchar11 = @Category2				
			,@nvarchar12 = @Category3				
			,@nvarchar13 = @Service				
			,@datetime6 = @DateUpdated			
			,@nvarchar14 = @Handler				
			,@nvarchar15 = @Status				
			,@bit5 = @TS_DBA_Notes			
			,@bit6 = @TS_DBA_Assign         
			,@bit7 = @TS_DBA_Create         

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
	FETCH NEXT FROM NewItemCursor INTO @DateReceived,@StartTime,@ENDTime,@DateResolved,@Ticket,@Subject,@Description,@TicketMask,@Sender,@SenderID,@SenderIDMask,@Priority,@CurrentWorkflowStage,@Category1,@Category2,@Category3,@Service,@DateUpdated,@Handler,@Status,@TS_DBA_Notes,@TS_DBA_Assign,@TS_DBA_Create
END

CLOSE NewItemCursor
DEALLOCATE NewItemCursor
GO
