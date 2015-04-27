DECLARE @in_QueueId sql_variant
	delete	dbo.QueueTb
					where	QueueId		= @in_QueueId
 
GO 8
 
 
 declare     --  @QueueDate    datetime,    
 @in_QueueId	sql_variant,   
 @DeliveryId    int,      
 @SubqueueId    nchar(10),      
 @SourceId    int,      
 @DestinationId   int,      
 @ItemId     int,      
 @AssetId    nvarchar(256),      
 @AssetVersion   tinyint,    
 @AssetSizeBytes   int,    
 @MEI     int,      @ExternalSystem   varchar(12),      @ExternalId    nvarchar(256),      
 @MasterId    nvarchar(256),      @DeliveryAttemptCount smallint,      
 @StatusCode    nchar(1),      @LastWorkerMachine  nvarchar(128),      @LastWorkerProgram  nvarchar(128),      
 @LastWorkerBatchId  bigint,      @LastWorkerBatchItemId bigint        
 
 select		 @DeliveryId    = DeliveryId,      
			 @SubqueueId    = SubqueueId,      
			 @SourceId    = SourceId,      
			 @DestinationId   = DestinationId,       
			 @ItemId     = ItemId,       
			 @AssetId    = AssetId,      
			 @AssetVersion   = AssetVersion,    
			 --  @AssetPriority   = AssetPriority,      
			 @AssetSizeBytes   = AssetSizeBytes,    
			 --  @AssetDataXml   = AssetDataXml,      
			 @MEI     = MEI,      
			 @ExternalSystem   = ExternalSystem,      
			 @ExternalId    = ExternalId,      
			 @MasterId    = MasterId,      
			 @DeliveryAttemptCount = DeliveryAttemptCount,      
			 @StatusCode    = StatusCode,    -- Q=QueuedReadyForDelivery B=BatchedForTransit X=ItemInTransit F=FailedMaxDeliveryAttempts      
			 @LastWorkerMachine  = LastWorkerMachine,      
			 @LastWorkerProgram  = LastWorkerProgram,      
			 @LastWorkerBatchId  = LastWorkerBatchId,      
			 @LastWorkerBatchItemId = LastWorkerBatchItemId    
			 
 from dbo.QueueTb   with (nolock)    
 where QueueId    = @in_QueueId
 
 
 
 
GO 1
 DECLARE @in_ConfigMaxItemsPerBatch int
 ,@in_DeliveryId sql_variant
 ,@in_SubqueueId sql_variant
 ,@in_CommandDate sql_variant
 
			select	top (@in_ConfigMaxItemsPerBatch)
						QueueId,	-- primary key in queue table
						ItemId,
						AssetId,
						AssetVersion,
						ExternalSystem,
						ExternalId,
						MasterId
			from	dbo.QueueTb	with (rowlock,updlock,readpast)	-- XLOCK: exclusive rowlock for these items so no other worker can grab (select) them
			where	DeliveryId		= @in_DeliveryId	-- source queue
			and		SubqueueId		in (N'PUBLIC',@in_SubqueueId)	-- source subqueue id (SOURCE-WORKER-IDENTIFIER-KEY)
			and		StatusCode		= N'Q'
			and		NextAttemptDate	<= @in_CommandDate	-- incase requeued with a delay after a failed attempt
			order by									-- make this the CLUSTERED INDEX for fast dequeuing
					DeliveryId			asc,			-- included since in the WHERE clause above
					SubqueueId			asc,			-- included since in the WHERE clause above
					StatusCode			asc,			-- included since in the WHERE clause above
					AssetPriority		asc,
					NextAttemptDate		asc				-- nice to include for fast searching; but would be incorrect logic for picking the next items to process!!!
 
 
GO 5
 
  DECLARE @in_QueueId sql_variant
  
	delete	dbo.QueueTb
				where	QueueId		= @in_QueueId
				
 
GO 8
 
 
DECLARE @in_QueueId sql_variant

	delete	dbo.QueueTb
					where	QueueId		= @in_QueueId
					
 
GO 1
 
   DECLARE @in_QueueId sql_variant
 						,@in_CommandMachine sql_variant
						,@in_CommandProgram sql_variant
						,@in_CommandCode sql_variant
						,@in_CommandText sql_variant
						,@in_CommandDate sql_variant
						,@in_WorkerBatchId sql_variant
						
	DECLARE @BatchItemTb TABLE(QueueId sql_variant)
						
	update	dbo.QueueTb
				set		-- LAST-COMMAND
						LastCommandSqlConnectOptions	= @@OPTIONS,
						LastCommandSqlSPID				= @@SPID,
						LastCommandMachine				= @in_CommandMachine,
						LastCommandProgram				= @in_CommandProgram,
						LastCommandCode					= @in_CommandCode,			-- C=Connect QA=QueueAdd BS=BatchStart BE=BatchEnd BIS=BatchItemStart BIE=BatchItemEnd BP=BatchPing BK=BatchKill X=ExternalUserDefinedCommand
						LastCommandRoutine				= left(db_name() + N'.' + object_name(@@procid),80),
						LastCommandText					= @in_CommandText,
						LastCommandDate					= @in_CommandDate,
						-- STATE
				--		DeliveryAttemptCount			= DeliveryAttemptCount + 1,		-- dont do this until "BatchItemStart"
				--		NextAttemptDate					= null,
						StatusCode						= N'B',							-- Q=QueuedReadyForDelivery B=BatchedForTransit X=ItemInTransit
						-- LAST-WORKER
						LastWorkerMachine				= @in_CommandMachine,
						LastWorkerProgram				= @in_CommandProgram,
						LastWorkerBatchId				= @in_WorkerBatchId,
						LastWorkerBatchStartDate		= @in_CommandDate,
						LastWorkerBatchEndDate			= null,
						LastWorkerBatchItemId			= null,
						LastWorkerBatchItemStartDate	= null,
						LastWorkerBatchItemEndDate		= null
				where	QueueId in (select	QueueId from @BatchItemTb)

			
 
 
GO 5
   DECLARE @in_QueueId sql_variant
 						,@in_CommandMachine sql_variant
						,@in_CommandProgram sql_variant
						,@in_CommandCode sql_variant
						,@in_CommandText sql_variant
						,@in_CommandDate sql_variant
						,@in_WorkerBatchId sql_variant
						,@in_ConfigFailureRetryDelaySeconds int

						
	DECLARE @BatchItemTb TABLE(QueueId sql_variant) 
 
	update	dbo.QueueTb
			set		-- LAST-COMMAND
					LastCommandSqlConnectOptions	= @@OPTIONS,
					LastCommandSqlSPID				= @@SPID,
					LastCommandMachine				= @in_CommandMachine,
					LastCommandProgram				= @in_CommandProgram,
					LastCommandCode					= @in_CommandCode,		-- BK=BatchKill BKD=BatchKillDefunct BKS=BatchkillShutdown
																			-- C=Connect QA=QueueAdd BS=BatchStart BE=BatchEnd BIS=BatchItemStart BIE=BatchItemEnd BP=BatchPing BK=BatchKill X=ExternalUserDefinedCommand
					LastCommandRoutine				= left(db_name() + N'.' + object_name(@@procid),80),
					LastCommandText					= @in_CommandText,
					LastCommandDate					= @in_CommandDate,
					NextAttemptDate					= dateadd(second,@in_ConfigFailureRetryDelaySeconds,@in_CommandDate),
					StatusCode						= N'Q',							-- Q=QueuedReadyForDelivery B=BatchedForTransit X=ItemInTransit
					-- LAST-WORKER
					LastWorkerBatchEndDate			= @in_CommandDate,
					LastWorkerBatchItemEndDate		= @in_CommandDate
			where	LastWorkerBatchId				= @in_WorkerBatchId				-- this batch (not neccessarily the CURRENT bacth id)
		--	and		StatusCode						IN (N'B',N'X')					-- OUTSTANDING items (assets) left hanging; we will kill/DEFUNCT them below
																					-- WHH: no reason to include this in WHERE clause since row would not exist if it wasnt OUTSTANDING
		
 
 
GO 1
 		DECLARE	@in_ExternalId sql_variant
				,@in_ExternalSystem sql_variant
 
		DECLARE @MasterIdsTb TABLE(MasterId sql_variant)
 
		select	SourceId,
				DestinationId,
				DeliveryId,
				AssetVersion,
				Status = case 
					when StatusCode = N'Q'
						then N'Queued'
					when StatusCode = N'B'
						then N'Batched'
					when StatusCode = N'X'
						then N'Processing'
					else
						N''
				end,
				DeliveryAttemptCount,
				NextAttemptDate
		from	dbo.QueueTb with (nolock)
		where	ExternalId		= @in_ExternalId and
				ExternalSystem	= @in_ExternalSystem
		union
		select	SourceId,
				DestinationId,
				DeliveryId,
				AssetVersion,
				Status = case 
					when StatusCode = N'Q'
						then N'Queued'
					when StatusCode = N'B'
						then N'Batched'
					when StatusCode = N'X'
						then N'Processing'
					else
						N''
				end,
				DeliveryAttemptCount,
				NextAttemptDate
		from	dbo.QueueTb q with (nolock)
		join	@MasterIdsTb m on q.MasterId = m.MasterId

	
 
 
GO 1
 
 
DECLARE @in_QueueId sql_variant
	delete	dbo.QueueTb
					where	QueueId		= @in_QueueId
		
 
 
GO 1
 DECLARE @in_QueueId sql_variant

	declare	
				@DeliveryId				int,
				@SubqueueId				nchar(10),
				@SourceId				int,
				@DestinationId			int,
				@ItemId					int,
				@AssetId				nvarchar(256),
				@AssetVersion			tinyint,
		--		@AssetPriority			tinyint,
				@AssetSizeBytes			int,
		--		@AssetDataXml			xml,
				@MEI					int,
				@ExternalSystem			varchar(12),
				@ExternalId				nvarchar(256),
				@MasterId				nvarchar(256),
				@DeliveryAttemptCount	smallint,
				@StatusCode				nchar(1),
				@LastWorkerMachine		nvarchar(128),
				@LastWorkerProgram		nvarchar(128),
				@LastWorkerBatchId		bigint,
				@LastWorkerBatchItemId	bigint
		
		select	
		--		@QueueDate				= QueueDate,
		--		@QueuerUsername			= Username,
		--		@QueuerMachine			= Machine,
		--		@QueuerProgram			= Program,
				@DeliveryId				= DeliveryId,
				@SubqueueId				= SubqueueId,
				@SourceId				= SourceId,
				@DestinationId			= DestinationId,	
				@ItemId					= ItemId,	
				@AssetId				= AssetId,
				@AssetVersion			= AssetVersion,
		--		@AssetPriority			= AssetPriority,
				@AssetSizeBytes			= AssetSizeBytes,
		--		@AssetDataXml			= AssetDataXml,
				@MEI					= MEI,
				@ExternalSystem			= ExternalSystem,
				@ExternalId				= ExternalId,
				@MasterId				= MasterId,
				@DeliveryAttemptCount	= DeliveryAttemptCount,
				@StatusCode				= StatusCode,				-- Q=QueuedReadyForDelivery B=BatchedForTransit X=ItemInTransit F=FailedMaxDeliveryAttempts
				@LastWorkerMachine		= LastWorkerMachine,
				@LastWorkerProgram		= LastWorkerProgram,
				@LastWorkerBatchId		= LastWorkerBatchId,
				@LastWorkerBatchItemId	= LastWorkerBatchItemId
		from	dbo.QueueTb			with (nolock)
		where	QueueId				= @in_QueueId

	
 
 
GO 30
 
 DECLARE @in_QueueId sql_variant
		,@in_CommandMachine sql_variant
		,@in_CommandProgram sql_variant
		,@in_CommandText  sql_variant
		,@in_CommandCode  sql_variant
		,@in_ConfigFailureRetryDelaySeconds INT
		,@in_CommandDate datetime
		
	update	dbo.QueueTb
				set		-- LAST-COMMAND
						LastCommandSqlConnectOptions	= @@OPTIONS,
						LastCommandSqlSPID				= @@SPID,
						LastCommandMachine				= @in_CommandMachine,
						LastCommandProgram				= @in_CommandProgram,
						LastCommandCode					= @in_CommandCode,					-- C=Connect QA=QueueAdd BS=BatchStart BE=BatchEnd BIS=BatchItemStart BIE=BatchItemEnd BP=BatchPing BK=BatchKill X=ExternalUserDefinedCommand
						LastCommandRoutine				= left(db_name() + N'.' + object_name(@@procid),80),
						LastCommandText					= @in_CommandText,
						LastCommandDate					= @in_CommandDate,
						-- STATE
				--		DeliveryAttemptCount			= DeliveryAttemptCount - 1,
						NextAttemptDate					= dateadd(second,@in_ConfigFailureRetryDelaySeconds,@in_CommandDate),
						StatusCode						= N'Q',						-- Q=QueuedReadyForDelivery B=BatchedForTransit X=ItemInTransit
						-- LAST-WORKER
				--		LastWorkerMachine				= @in_CommandMachine,
				--		LastWorkerProgram				= @in_CommandProgram,
				--		LastWorkerBatchId				= @in_WorkerBatchId,
				--		LastWorkerBatchStartDate		= @in_WorkerBatchStartDate,
				--		LastWorkerBatchEndDate			= @in_WorkerBatchEndDate,
				--		LastWorkerBatchItemId			= @in_WorkerBatchItemId,
				--		LastWorkerBatchItemStartDate	= @in_WorkerBatchItemStartDate,
						LastWorkerBatchItemEndDate		= @in_CommandDate
				where	QueueId							= @in_QueueId

		
 
 
GO 8
 
 
DECLARE @in_ConfigMaxItemsPerBatch int
DECLARE @in_DeliveryId	sql_variant
DECLARE @in_SubqueueId	sql_variant
DECLARE @in_CommandDate	sql_variant	

			select	top (@in_ConfigMaxItemsPerBatch)
					-- SOURCE-QUEUER
			--			Machine,
			--			Username,
			--			Program,
					-- QUEUE
			--			QueueDate,
						QueueId,	-- primary key in queue table
					-- ASSET
						ItemId,
						AssetId,
						AssetVersion,
			--			AssetDataXml,
			--			AssetPriority,
			--			AssetSizeBytes,
						ExternalSystem,
						ExternalId,
						MasterId
					-- WORKER: who is delivering the asset
			--			DeliveryAttemptCount,
					-- other
			--			NextAttemptDate
			from	dbo.QueueTb	with (rowlock,updlock,readpast)	-- XLOCK: exclusive rowlock for these items so no other worker can grab (select) them
																-- UPDLOCK: other SPIDs can read but no SPIDs can update since we have an UPDATE lock on the record.
																--			also take note that another SPID would not be able to run this proc and get our record because it needs an UPDATE lock that we already have; so it would go into WAIT mode
																-- READPAST: this is actually designed for use with Queueing applications so READERs with UPDLOCKs do not block other READERs attempting to get UPDLOCKs -- they instead SKIP to next row!
			where	DeliveryId		= @in_DeliveryId	-- source queue
			and		SubqueueId		in (N'PUBLIC',@in_SubqueueId)	-- source subqueue id (SOURCE-WORKER-IDENTIFIER-KEY)
			and		StatusCode		= N'Q'
			and		NextAttemptDate	<= @in_CommandDate	-- incase requeued with a delay after a failed attempt
					
 
 
GO 1
 
 

DECLARE @in_QueueId sql_variant
	delete	dbo.QueueTb
					where	QueueId		= @in_QueueId
					
 
GO 1
 
  
 DECLARE @in_QueueId sql_variant
		,@in_CommandMachine sql_variant
		,@in_CommandProgram sql_variant
		,@in_CommandText  sql_variant
		,@in_CommandCode  sql_variant
		,@in_ConfigFailureRetryDelaySeconds INT
		,@in_CommandDate datetime
		,@in_WorkerBatchItemId sql_variant

	update	dbo.QueueTb
		set		-- LAST-COMMAND
				LastCommandSqlConnectOptions	= @@OPTIONS,
				LastCommandSqlSPID				= @@SPID,
				LastCommandMachine				= @in_CommandMachine,
				LastCommandProgram				= @in_CommandProgram,
				LastCommandCode					= @in_CommandCode,			-- C=Connect QA=QueueAdd BS=BatchStart BE=BatchEnd BIS=BatchItemStart BIE=BatchItemEnd BP=BatchPing BK=BatchKill X=ExternalUserDefinedCommand
				LastCommandRoutine				= left(db_name() + N'.' + object_name(@@procid),80),
				LastCommandText					= @in_CommandText,
				LastCommandDate					= @in_CommandDate,
				-- STATE
				DeliveryAttemptCount			= DeliveryAttemptCount + 1,
		--		NextAttemptDate					= null,
				StatusCode						= N'X',							-- Q=QueuedReadyForDelivery B=BatchedForTransit X=ItemInTransit S=LastAttemptSuccess F=LastAttemptFailed
				-- LAST-WORKER
		--		LastWorkerMachine				= @in_CommandMachine,
		--		LastWorkerProgram				= @in_CommandProgram,
		--		LastWorkerBatchId				= @in_WorkerBatchId,
		--		LastWorkerBatchStartDate		= @in_CommandDate,
		--		LastWorkerBatchEndDate			= @in_CommandDate,
				LastWorkerBatchItemId			= @in_WorkerBatchItemId,
				LastWorkerBatchItemStartDate	= @in_CommandDate,
				LastWorkerBatchItemEndDate		= null
		where	QueueId							= @in_QueueId

	
 
 
GO 14
   
-- DECLARE @in_QueueId sql_variant
--		,@in_CommandMachine sql_variant
--		,@in_CommandProgram sql_variant
--		,@in_CommandText  sql_variant
--		,@in_CommandCode  sql_variant
--		,@in_ConfigFailureRetryDelaySeconds INT
--		,@in_CommandDate datetime
--		,@in_WorkerBatchItemId sql_variant


 
--	insert	dbo.BatchItemTb
--					(
--					-- CONNECTION
--						/*
--						SqlConnectOptions				,--int				not null default(@@OPTIONS),	-- current connection options
--						SqlSPID							,--int				not null default(@@SPID),		-- current SPID
--						*/
--					-- BATCH
--						BatchId							, --bigint				not null,							-- foreign key
--					-- QUEUE
--						QueueDate						, --datetime			not null,							-- date asset added to queue
--						QueueId							, --bigint				not null,							-- que id
--						-- denormalized since in QueueTb; but need it since we remove/move records from that table
--						QueuerMachine					, --nvarchar(128)		not null,							-- calling machine name for logging
--						QueuerUsername					, --nvarchar(50)		not null,							-- Denali Username; most likely will always be NULL
--						QueuerProgram					, --nvarchar(128)		not null,							-- calling application/version string for logging
--						DeliveryAttemptCount			, --smallint			not null,							-- original attempt count before processing
--						ConfigMaxFailureCount			, --smallint			not null,							-- DeliveryTb.ConfigMaxFailureCount for informational purposes
--					-- DELIVERY
--						DeliveryId						, --int					not null,							-- internal destination id
--						SubqueueId						, --nchar(10)			not null,							-- Source Subqueue Id
--						-- denormalized already in DeliveryTb
--						SourceId						, --int					not null,							-- source name
--						DestinationId					, --int					not null,							-- source destination id
--					-- ITEM/ASSET
--						ItemId							, --int					not null,							-- internal asset id
--						-- denormalized since in QueueTb; but need it since we remove/move records from that table
--						AssetId							, --nvarchar(256)		not null,							-- asset id
--						AssetVersion					, --tinyint				not null,							-- asset version
--						JobId							,
--						AssetPriority					, --tinyint				not null,							-- sort priority of asset
--						AssetSizeBytes					, --int					not null,							-- asset size
--						--AssetDataXml					, --xml					not null,							-- payload
--						MEI								, --int					null,								-- event
--						ExternalSystem					, --varchar(12)			null,								-- 'CRM', 'EWSINGESTION', 'EWSDELIVERY'
--						ExternalId						, --nvarchar(256)		null,								-- an EwsId or externally-defined value
--						MasterId						, --nvarchar(256)		null,								-- TEAMS MasterId
--					-- other
--						StartDate						, --datetime			not null default(GETDATE()),		-- date/time worker process started processing this item
--					-- populated on completion
--						EndDate							, --datetime			null,								-- date/time worker process finished processing this item
--						ErrorCode						, --nchar(16)			null,
--						ErrorMessage					, --nvarchar(500)		null,								-- worker message outcome
--						SuccessF						, --bit					null,								-- if successfully sent
--						MaxFailuresReachedF				, --bit					null,								-- (DeliveryTb.ConfigMaxFailureCount) if max failed attempts reached which means the record is removed from the QueueTb table
--						ResultCode						, --nchar(5)			null,								-- ??? should depricate "SuccessF" and "MaxFailuresReachedF"
--					-- Runtime stats for Commands
--						BatchItemStartCommandTimeMs			, --int		null,				-- time it took for the system to process the CommandCode=BIS (BatchItemStart) in milliseconds
--						BatchItemEndCommandTimeMs			, --int		null,				-- time it took for the system to process the CommandCode=BIE (BatchItemEnd) in milliseconds
--						BatchItemStartToBatchItemEndTimeMs	 --int		null,				-- no need for this; "EndDate"-"StartDate" gives it
--					)
--			select	
--					-- CONNECTION
--						/*
--						@@options				,
--						@@spid					,
--						*/
--					-- BATCH
--						LastWorkerBatchId		,
--					-- QUEUE
--						QueueDate				,
--						@in_QueueId				,
--						-- denormalized since in QueueTb; but need it since we remove/move records from that table
--						Machine					,
--						Username				,
--						Program					,
--						DeliveryAttemptCount+1		-- +1 to reflect the co
 
 
--GO 15
    
 DECLARE @out_QueueId sql_variant
		,@in_QueueId sql_variant
		,@in_CommandMachine sql_variant
		,@in_CommandProgram sql_variant
		,@in_CommandText  sql_variant
		,@in_CommandCode  sql_variant
		,@in_ConfigFailureRetryDelaySeconds INT
		,@in_CommandDate datetime
		,@in_WorkerBatchItemId sql_variant
		,@rundate datetime

 
	--end

		-- V.3. modify QUEUE "stats" properties
		--
		
			update	dbo.QueueTb
			set		
			--		StatusCode				= N'Q',		-- ready for Worker Process to grab (no need since using transactions to maintain proper state)
					QueueAddCommandTimeMs	= datediff(millisecond,@RunDate,getdate())
			where	QueueId					= @out_QueueId

		
 
 
GO 7
 
 
DECLARE @in_QueueId sql_variant
	delete	dbo.QueueTb
					where	QueueId		= @in_QueueId
					
				-- I.2.d. modify ITEM ItemTb.MetricCurrentQueueRefCount	-- QueueTb DELETE Trigger would do this nicely
																		-- code in caller of this routine (BatchItemEndSp)
					/*
						-- *** ItemUpdQueueRefCountSp @in_ItemId = @in_ItemId ***
							
						update	dbo.ItemTb
						set		MetricCurrentQueueRefCount	= MetricCurrentQueueRefCount - 1
						where	ItemId						= @in_ItemId
					*/

				-- I.2.e. modify DELIVERY DeliveryTb.MetricCurrentQueCount	-- QueueTb DELETE Trigger would do this nicely
																			-- code in caller of this routine (BatchItemEndSp)
					/*
						-- *** DeliveryUpd_WorkerBatchItemEndSp @in_DeliveryId = @in_DeliveryId ***
							
						update	dbo.DeliveryTb
						set		MetricCurrentQueCount	= MetricCurrentQueCount - 1,
								MetricCurrentQueSize	= MetricCurrentQueSize - @in_AssetSizeBytes
						where	DeliveryId				= @in_DeliveryId
					*/

			-- BEGIN TRAN
			
		
 
 
GO 1
 
     
 DECLARE @out_QueueId sql_variant
		,@in_QueueId sql_variant
		,@in_CommandMachine sql_variant
		,@in_CommandProgram sql_variant
		,@in_CommandText  sql_variant
		,@in_CommandCode  sql_variant
		,@in_ConfigFailureRetryDelaySeconds INT
		,@in_CommandDate datetime
		,@in_WorkerBatchItemId sql_variant
		,@rundate datetime
		,@in_DeliveryId sql_variant

 
 			-- *** this is a major performance hit when this occurs ie. DeliveryTb gives us a record buat QueueTb has not to process ***
		
			-- RESYNC DeliveryTb.MetricCurrent* (MetricCurrentQueCount, MetricCurrentQueSize)
			--
			-- We should have had Items so must be OUT_OF_SYNC. Actually this may not be OUT_OF_SYNC since 
			-- QueueTb.NextAttemptDate (REQUEUE) may not be ready! But good idea to RECALC the metric value!
			-- Theoritically this code should almost never execute; but it's a great fail-safe!
			--
			--		Q1. Why not just set DeliveryTb.MetricCurrent* to 0?
			--			A1. because of QueueTb.NextAttemptDate being in the future so it's not ready to be processeed yet (due to a failure REQUEUE)
			--
			--		Q2. During the SELECT from dbo.QueueTb below to get the MetricCurrent* values, "QueueAddSp" could have queued more records
			--			for this DeliveryId. That would throw off our calculation and record the wrong metrics!
			--			A1. ??? Probably have to use TRANSACTION with UPDLOCK on DeliveryTb to prevent "QueueAddSp" from incrimenting the Metrics ???
			--			A2. Regardless, since @in_WorkerBatchItemCount==0, the most number of records that could be in the QueueTb with that
			--				DeliveryId is very minimal. So the SELECT from dbo.QueueTb below would run in a millisecond. That means "QueueAddSp"
			--				would have had to queued a new record in "QueueTb" with the same "DeliveryId" in that millisecond. It is possible, but
			--				probably unlikely!
			--
			
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
				
				--select @_ROWCOUNT = @@ROWCOUNT, @_ERROR = @@ERROR
				--if (@_ROWCOUNT = 0) begin		-- always = 1 so cannot use
			
 
 
GO 5
 
 
