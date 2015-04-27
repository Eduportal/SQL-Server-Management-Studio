
DECLARE		@DestinationId		int
			,@MasterId			nvarchar(256)
			,@Meid				int
			,@ThumbDest			int	
			,@p0				int
			,@in_DeliveryId		int
			
DECLARE		@DestinationTb		TABLE(DestinationId INT)
DECLARE		@RouteTb			TABLE(RoutingName nVarChar(260))


declare	@MetricCurrentQueCount	int,
		@MetricCurrentQueSize	int,
		@MetricNextAttemptDate	datetime,
		@ThrottleSeconds		int			-- DELIVERY throttle (not SPID/CONNECTION throttle)

-- Use TRANSACTION to prevent "QueueAddSp" from updating "DeliveryTb" for this "DeliveryId"
/* ??? need to think about this for a while ???
begin tran

select	'x'
from	dbo.DeliveryTb		with (rowlock,updlock)
where	DeliveryId			= @in_DeliveryId
*/

select	@MetricCurrentQueCount	= count(*),										-- always will return a number
		@MetricCurrentQueSize	= sum(AssetSizeBytes),							-- will return NULL if no qualifying records
--		@MetricCurrentQueSize	= sum(isnull(AssetSizeBytes,0)),				-- will return NULL if no qualifying records
--		@MetricCurrentQueSize	= isnull(sum(AssetSizeBytes),0),				-- always will return a number
		@MetricNextAttemptDate	= min(NextAttemptDate)							-- will return NULL if no qualifying records
from	dbo.QueueTb				with (nolock)
where	DeliveryId				= @in_DeliveryId
--	and		SubqueueId				in (N'PUBLIC',@in_SubqueueId)	-- source subqueue id (SOURCE-WORKER-IDENTIFIER-KEY)
																-- *** cannot include or we could STARVE a SUBQUEUE ***
																-- *** need new table [DeliverySubqueueTb] to fix this issue 
and		StatusCode				= N'Q'
--	and		NextAttemptDate			<= @in_CommandDate				-- *** cannot include this is the COUNT ***




















----insert dbo.QueueTb      (       -- CONNECT       /*       SqlConnectOptions    ,       SqlSPID       ,       */      -- CALLER       Machine       , --default(HOST_NAME()),  -- Queuer Machine       Username      , --default(SYSTEM_USER),  -- Queuer Username       Program       , --default(APP_NAME()),  -- Queuer application/version string      -- QUEUE       QueueDate      , --default(GETDATE()),   -- Queue date      -- LAST-COMMAND       LastCommandSqlConnectOptions ,       LastCommandSqlSPID    ,       LastCommandMachine    ,       LastCommandProgram    ,       LastCommandCode     ,        -- C=Connect QA=QueAdd BS=BatchStart BE=BatchEnd BIS=BatchItemStart BIE=BatchItemEnd BP=BatchPing BK=BatchKill X=ExternalUserDefinedCommand       LastCommandRoutine    ,        -- routine that processed the command       LastCommandText     ,        -- Format: Command:BatchId:Parm (ie. BatchStart:22323:10)LastCommandRoutine        LastCommandDate     ,        -- last command start date      -- WORKER: who is delivering the asset      -- LAST-WORKER: who last attempted to deliver the record       LastWorkerMachine    ,        -- worker machine       LastWorkerProgram    ,        -- name of worker process ie. "Worker Process #1":500       LastWorkerBatchId    ,        -- worker scan id       LastWorkerBatchStartDate  ,        -- date/time worker process started       LastWorkerBatchEndDate   ,        -- date/time worker process ended       LastWorkerBatchItemId   ,        LastWorkerBatchItemStartDate ,        -- date/time worker process started processing the item (asset)       LastWorkerBatchItemEndDate  ,        -- date/time worker process finished processing the item (asset)      -- STATE       DeliveryAttemptCount   ,--default(0),     -- number of attempts to deliver by any worker       NextAttemptDate     ,--not null default(GETDATE()), -- next time a worker can process this item (asset)       StatusCode      ,--default(N'Q'),    -- P=PreQueue                       -- Q=QueuedReadyForDelivery                       -- B=BatchedForTransit                       -- X=ItemInTransit                       -- ** dont need these since they would result in the record being removed from this queue **                       -- F=LastAttemptFailed (if >MAX-ATTEMPTS move FAIL-QUEUE; else set StatusCode=Q for requeue)                       -- S=LastAttemptSuccess (move SUCCESS-QUEUE)      -- data       -- DELIVERY       DeliveryId      ,        -- internal destination id       SubqueueId      ,        -- Source Subqueue Id       -- denormalized already in DeliveryTb       SourceId      ,        -- source destination name       DestinationId     ,        -- source destination id       -- ASSET       ItemId       ,        -- internal asset id       AssetId       ,       AssetVersion     ,     --  AssetDataXml     ,       AssetPriority     ,       AssetSizeBytes     , --default(0)     -- asset size       MEI        ,       JobId       ,       ExternalSystem     ,       ExternalId      ,       MasterId      ,      -- STATS       QueueAddCommandTimeMs         )     values      (      -- CONNECT       /*       @@options,       @@spid,       */      -- CALLER       @Machine,       @Username,       @in_Program,      -- QUEUE       @RunDate,      -- LAST-COMMAND       @@OPTIONS,       @@SPID,       @Machine,       @in_Program,       N'QA',      -- C=Connect QA=QueueAdd BS=BatchStart BE=BatchEnd BIS=BatchItemStart BIE=BatchItemEnd BP=BatchPing BK=BatchKill X=ExternalUserDefinedCommand       left(db_name() + N'.' + object_name(@@procid),80),       @CommandText,       @RunDate,      -- WORKER: who is delivering the asset      -- LAST-WORKER: who last attempted to deliver the record       null,       null,       null,       null,       null,       null,       null,       null,      -- STATE       0,       dateadd(second,@in_DelayDeliverySeconds,@RunDate),       N'Q',    -- *** do not set to "Q" until the procedure completes successfully at the end of the procedure ***            -- P=PreQueue(got rid of this one since using transactions to maintain proper state now)      -- DELIVERY       @out_DeliveryId,       @in_SubqueueId,       @out_SourceId,       @in_DestinationId,      -- ASSET       @out_ItemId,       @in_AssetId,       @in_AssetVersion,     --  @in_AssetDataXml,       @in_AssetPriority,       @in_AssetSizeBytes,       @in_MEI,       @in_JobId,       @in_ExternalSystem,       @in_ExternalId,       @in_MasterId,      -- STATS       null      )       


-- insert @DestinationTb (DestinationId)   
 
-- select distinct dr.DestinationId    
-- from DestinationRoutingTb dr    
-- inner join RoutingTb r 
-- on r.RoutingId = dr.RoutingId     
-- inner join @RouteTb tr 
-- on tr.RoutingName = r.RoutingName    
-- where r.IsDirectRouting = 1     and r.RoutingTypeCode = 'I'     



-- select		top 1 
--			'x'    
-- from		dbo.BatchItemTb with (nolock)    
-- where		SourceId  = 1    
--	 and	DestinationId = @DestinationId    
--	 and	SuccessF  = 1    
--	 and	MasterId  = @MasterId   
	 
	 
--select		distinct 
--			bi.AssetId
--			,     i.MasterId
--			,     bi.ExternalSystem
--			,     bi.ExternalId      
--from		BatchItemTb bi with (nolock)    
--inner join	ItemTb i with (nolock) 
--		on	bi.ExternalId = i.ExternalId 
--		and	bi.ExternalSystem = i.ExternalSystem    
--where		bi.MEI = @Meid    
--		and	bi.ResultCode = 'S'    
--		and	bi.DestinationId = @ThumbDest
		

--select		dt.Machine       
--			,     dt.Username       
--			,     dt.Program       
--			,     dt.CreateDate      
--			,     dt.DeliveryId      
--			,     dt.SourceId       
--			,     dt.DestinationId     
--			,     dt.ConfigStatusCode     
--			,     dt.ConfigPriorityBoost    
--			,     dt.ConfigResendDelayDays   
--			,     dt.ConfigMaxWorkerThreads   
--			,     dt.ConfigMaxItemsPerBatch   
--			,     dt.ConfigMaxSecondsPerItem  
--			,     dt.ConfigMaxFailureCount   
--			,     dt.ConfigFailureRetryDelaySeconds 
--			,     dt.ConfigTraceLevel     
--			,     dt.ConfigUserDefined1    
--			,     dt.OfflineQueueAddCount    
--			,     dt.LastOfflineQueueAddDate   
--			,     dt.MetricCurrentQueCount   
--			,     dt.MetricCurrentQueSize    
--			,     dt.MetricTodayComputeDate   
--			,     dt.MetricTodayMaxQueCount   
--			,     dt.MetricTodayMaxQueCountDate  
--			,     dt.MetricTodayTotalQueCount   
--			,     dt.MetricTodayTotalFailCount  
--			,     dt.MetricTodayTotalSendCount  
--			,     dt.LastCommandSqlConnectOptions  
--			,     dt.LastCommandSqlSPID    
--			,     dt.LastCommandMachine    
--			,     dt.LastCommandProgram    
--			,     dt.LastCommandCode     
--			,     dt.LastCommandRoutine    
--			,     dt.LastCommandText     
--			,     dt.LastCommandDate     
--			,     dt.LastQueuerQueueId    
--			,     dt.LastQueuerAddDate    
--			,     dt.LastQueuerMachine    
--			,     dt.LastQueuerUsername    
--			,     dt.LastQueuerProgram    
--			,     dt.WorkerStatusCode     
--			,     dt.LastWorkerMachine    
--			,     dt.LastWorkerProgram    
--			,     dt.LastWorkerBatchId    
--			,     dt.LastWorkerBatchSecret   
--			,     dt.LastWorkerBatchStartDate   
--			,     dt.LastWorkerBatchEndDate   
--			,     dt.LastWorkerBatchItemCount   
--			,     dt.LastWorkerBatchItemDoneCount  
--			,     dt.ConfigMaxIdleSecondsPerBatch  
--			,     dt.MetricNextAttemptDate   
--			,     dt.LastQueuerSubqueueId    
--			,     dt.LastWorkerBatchSubqueueId  
--			,     dt.LastWorkerBatchIdleExpireDate 
--			,     dt.LastWorkerBatchExpireDate   
			
--from		DeliveryTb dt with (nolock)   
--join		@DestinationTb d on dt.DestinationId = d.DestinationId         -- Result set #1: Destinations  


--SELECT		[t0].[DeliveryId]
--			,[t0].[SourceId]
--			, [t0].[DestinationId]
--			, [t0].[ConfigStatusCode]
--			, [t0].[ConfigPriorityBoost]
--			, [t0].[ConfigResendDelayDays]
--			, [t0].[ConfigMaxWorkerThreads]
--			, [t0].[ConfigMaxItemsPerBatch]
--			, [t0].[ConfigMaxIdleSecondsPerBatch] AS [ConfigMaxSecondsPerBatch]
--			, [t0].[ConfigMaxSecondsPerItem]
--			, [t0].[ConfigMaxFailureCount]
--			, [t0].[ConfigFailureRetryDelaySeconds]
--			, [t0].[ConfigTraceLevel]
--			, [t0].[ConfigUserDefined1]
--			, [t0].[LastWorkerBatchEndDate]  
--FROM		[dbo].[DeliveryTb] AS [t0]  
--WHERE		[t0].[DestinationId] = @p0


--update		deliverydb.dbo.deliverytb 
--	set		configmaxworkerthreads=10
--			, configmaxitemsperbatch=30 
--where		destinationid in (1136,1137)


----SELECT distinct object_name(id) From syscomments where text like '%BatchItemId%'		
		
		