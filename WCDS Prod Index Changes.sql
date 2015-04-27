 
 -- CHANGES FROM EVALUATING PRODUCTION
 --USE [master]
--GO
--ALTER DATABASE [wcds] SET PARAMETERIZATION FORCED WITH NO_WAIT
--GO
--ALTER DATABASE [wcds] SET COMPATIBILITY_LEVEL = 100
--GO
--ALTER DATABASE [wcds] SET AUTO_UPDATE_STATISTICS_ASYNC ON WITH NO_WAIT
--GO
--ALTER DATABASE [wcds] SET ALLOW_SNAPSHOT_ISOLATION ON
--GO
--ALTER DATABASE [WCDS] SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE
--GO

  --  MAXDOP setting should be : 8
 
USE [WCDS]
 
	DECLARE	@cEModule		sysname
		,@cECategory		sysname
		,@cEEvent		sysname
		,@cEGUID		uniqueidentifier
		,@cEMessage		nvarchar(max)
		,@cERE_ForceScreen	BIT
		,@cERE_Severity		INT
		,@cERE_State		INT
		,@cERE_With		VarChar(2048)
		,@cEStat_Rows		BigInt
		,@cEStat_Duration	FLOAT
		,@cEMethod_Screen	BIT
		,@cEMethod_TableLocal	BIT
		,@cEMethod_TableCentral	BIT
		,@cEMethod_RaiseError	BIT
		,@cEMethod_Twitter	BIT
		,@StartDate		DATETIME
		,@StopDate		DATETIME
 
	SELECT	@cEModule		= 'Missing & Unused Index Tuneing for [WCDS]'
		,@cEGUID		= NEWID()
 
	PRINT	'  -- LOGGED RESULTS CAN BE RETRIEVED WITH:'
	PRINT	'  -- SELECT  * FROM [dbaadmin].[dbo].[EventLog] where cEGUID = '''+CAST(@cEGUID AS VarChar(50))+''''
 
 
 
/* 001 - 3714856476 */  RAISERROR('Updateing Statistics ON [SubscriptionBillingInfo]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[Subscription].[SubscriptionBillingInfo]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [Subscription].[SubscriptionBillingInfo]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_SubscriptionBillingInfo_9D05C] on [SubscriptionBillingInfo]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.14
 
                        SELECT    @cEEvent       = 'AMIX_SubscriptionBillingInfo_9D05C on [Subscription].[SubscriptionBillingInfo]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_SubscriptionBillingInfo_9D05C on [Subscription].[SubscriptionBillingInfo]([SubscriptionID]) Include ([SubscriptionBillingInfoID], [CountryCode], [CurrencyCode], [BillingTotalAmount], [SubscriptionBillingPaymentID], [CustomerClient], [CustomerJobReference], [CustomerOrderedBy], [CustomerPurchaseOrder], [BillingCustomerID], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [BillingDay], [PlanPrice], [PurchaserIsNotLicensee], [PromoCode]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 002 - 1485928674 */  RAISERROR('Updateing Statistics ON [SubscriptionBillingNext]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[Subscription].[SubscriptionBillingNext]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [Subscription].[SubscriptionBillingNext]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_SubscriptionBillingNext_3CA85] on [SubscriptionBillingNext]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_SubscriptionBillingNext_3CA85 on [Subscription].[SubscriptionBillingNext]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_SubscriptionBillingNext_3CA85 on [Subscription].[SubscriptionBillingNext]([SubscriptionID]) Include ([SubscriptionBillingNextID], [BillingPeriod], [BillingDate], [BillingRetryDate], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 003 - 0313854165 */  RAISERROR('Updateing Statistics ON [Cart]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[Cart]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[Cart]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_Cart_1A06B] on [Cart]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 2.00
 
                        SELECT    @cEEvent       = 'AMIX_Cart_1A06B on [dbo].[Cart]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_Cart_1A06B on [dbo].[Cart]([iIndividualID], [iOriginalSystemID],[IsQuoteCart]) Include ([iCartID], [iLineCount], [dtModified]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 004 - 0244414553 */  RAISERROR('Updateing Statistics ON [EditorialOrderSchedule]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[EditorialOrderSchedule]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[EditorialOrderSchedule]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_EditorialOrderSchedule_58606] on [EditorialOrderSchedule]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_EditorialOrderSchedule_58606 on [dbo].[EditorialOrderSchedule]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_EditorialOrderSchedule_58606 on [dbo].[EditorialOrderSchedule]([SubscriptionID], [ActiveFlag]) Include ([SchedOrderDate], [OrderFulfilledDate]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 005 - 0135901864 */  RAISERROR('Updateing Statistics ON [AgreementDetailKANLMCollection]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[AgreementDetailKANLMCollection]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[AgreementDetailKANLMCollection]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_AgreementDetailKANLMCollection_7FAC1] on [AgreementDetailKANLMCollection]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_AgreementDetailKANLMCollection_7FAC1 on [dbo].[AgreementDetailKANLMCollection]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_AgreementDetailKANLMCollection_7FAC1 on [dbo].[AgreementDetailKANLMCollection]([iAgreementDetailID]) Include ([NLMCollectionID]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 006 - 0115166604 */  RAISERROR('Updateing Statistics ON [Address]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[Address]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[Address]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_Address_BDB4F] on [Address]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_Address_BDB4F on [dbo].[Address]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_Address_BDB4F on [dbo].[Address]([iStatusID], [iTypeID], [iEntityID], [iEntityTypeID], [tiRomanCharacterOnlyFlag]) Include ([iAddressID], [vchAddress1], [vchAddress2], [vchAddress3], [vchCity], [chStateCode], [vchProvince], [vchCounty], [nchCountryCode], [vchPostalCode]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 007 - 0106981490 */  RAISERROR('Updateing Statistics ON [SubscriptionSeat]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[Subscription].[SubscriptionSeat]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [Subscription].[SubscriptionSeat]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_SubscriptionSeat_5FDD0] on [SubscriptionSeat]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.01
 
                        SELECT    @cEEvent       = 'AMIX_SubscriptionSeat_5FDD0 on [Subscription].[SubscriptionSeat]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_SubscriptionSeat_5FDD0 on [Subscription].[SubscriptionSeat]([SubscriptionID]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 008 - 0052704379 */  RAISERROR('Updateing Statistics ON [SubscriptionDetail]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[SubscriptionDetail]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[SubscriptionDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_SubscriptionDetail_981CA] on [SubscriptionDetail]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_SubscriptionDetail_981CA on [dbo].[SubscriptionDetail]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_SubscriptionDetail_981CA on [dbo].[SubscriptionDetail]([SubscriptionID], [Billable], [ActiveFlag],[StartDate], [EndDate]) Include ([SubscriptionContentCategoryId]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 009 - 0019401955 */  RAISERROR('Updateing Statistics ON [DownloadDetail]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[DownloadDetail]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[DownloadDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_DownloadDetail_3DA27] on [DownloadDetail]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 1.28
 
                        SELECT    @cEEvent       = 'AMIX_DownloadDetail_3DA27 on [dbo].[DownloadDetail]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_DownloadDetail_3DA27 on [dbo].[DownloadDetail]([IndividualId],[ImageID], [StatusID]) Include ([DownloadId], [DownloadSourceId], [SourceDetailID]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 010 - 0005411289 */  RAISERROR('Updateing Statistics ON [Company]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[Company]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[Company]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_Company_73553] on [Company]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_Company_73553 on [dbo].[Company]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_Company_73553 on [dbo].[Company]([iTypeID]) Include ([iCompanyID], [vchCompanyName], [BillToEmailAddress]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 011 - 0004026590 */  RAISERROR('Updateing Statistics ON [OrderDetail]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[OrderDetail]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[OrderDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_OrderDetail_92899] on [OrderDetail]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.18
 
                        SELECT    @cEEvent       = 'AMIX_OrderDetail_92899 on [dbo].[OrderDetail]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_OrderDetail_92899 on [dbo].[OrderDetail]([tiRightsEmailSentFlag],[iStatusID], [iMediaTypeID], [mUnitPrice], [dtUseEndDate]) Include ([iOrderDetailID], [iOrderID], [vchItemDescription], [vchMasterID], [iBrandID], [iSCIOwnerId], [iUsageId], [dtUseStartDate], [UseVersion]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 012 - 0003676917 */  RAISERROR('Updateing Statistics ON [IndividualPreference]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[IndividualPreference]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[IndividualPreference]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_IndividualPreference_A503C] on [IndividualPreference]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.03
 
                        SELECT    @cEEvent       = 'AMIX_IndividualPreference_A503C on [dbo].[IndividualPreference]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_IndividualPreference_A503C on [dbo].[IndividualPreference]([iOriginalSystemID]) Include ([iIndividualID], [vchXMLstring]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 013 - 0002024919 */  RAISERROR('Updateing Statistics ON [Orders]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[Orders]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[Orders]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_Orders_C4DDD] on [Orders]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.04
 
                        SELECT    @cEEvent       = 'AMIX_Orders_C4DDD on [dbo].[Orders]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_Orders_C4DDD on [dbo].[Orders]([iCompanyID],[iOriginalSystemID], [dtOrderDate]) Include ([iOrderID], [iIndividualID], [vchCustPurchaseOrder]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 014 - 0001335963 */  RAISERROR('Updateing Statistics ON [SubscriptionPortfolio]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[SubscriptionPortfolio]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[SubscriptionPortfolio]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_SubscriptionPortfolio_9DBFD] on [SubscriptionPortfolio]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_SubscriptionPortfolio_9DBFD on [dbo].[SubscriptionPortfolio]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_SubscriptionPortfolio_9DBFD on [dbo].[SubscriptionPortfolio]([PortfolioId]) Include ([SubscriptionPortfolioId], [SubscriptionAgreementId], [IsWhollyOwn]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 015 - 0001235025 */  RAISERROR('Updateing Statistics ON [AgreementDetailNLMResolution]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[AgreementDetailNLMResolution]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[AgreementDetailNLMResolution]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_AgreementDetailNLMResolution_AB509] on [AgreementDetailNLMResolution]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.01
 
                        SELECT    @cEEvent       = 'AMIX_AgreementDetailNLMResolution_AB509 on [dbo].[AgreementDetailNLMResolution]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_AgreementDetailNLMResolution_AB509 on [dbo].[AgreementDetailNLMResolution]([iAgreementDetailID],[iResolutionID]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 016 - 0000443278 */  RAISERROR('Updateing Statistics ON [VitriaEventLog_sdw]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[VitriaEventLog_sdw]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[VitriaEventLog_sdw]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_VitriaEventLog_sdw_252EF] on [VitriaEventLog_sdw]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.99
 
                        SELECT    @cEEvent       = 'AMIX_VitriaEventLog_sdw_252EF on [dbo].[VitriaEventLog_sdw]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_VitriaEventLog_sdw_252EF on [dbo].[VitriaEventLog_sdw]([new_vchObjectClass]) Include ([cmd], [old_iEventLogID], [old_iOriginalSystemID], [old_iObjectID], [old_iObjectID2], [old_vchTransactionType], [old_vchObjectClass], [old_dtCreated], [new_iEventLogID], [new_iOriginalSystemID], [new_iObjectID], [new_iObjectID2], [new_vchTransactionType], [new_dtCreated], [orderID2]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 017 - 0000425363 */  RAISERROR('Updateing Statistics ON [Subscription]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[Subscription].[Subscription]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [Subscription].[Subscription]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_Subscription_5F6C7] on [Subscription]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.66
 
                        SELECT    @cEEvent       = 'AMIX_Subscription_5F6C7 on [Subscription].[Subscription]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_Subscription_5F6C7 on [Subscription].[Subscription]([IndividualID], [StatusID], [ChangedFromSubscriptionID]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 018 - 0000288277 */  RAISERROR('Updateing Statistics ON [WebNotes]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[WebNotes]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[WebNotes]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_WebNotes_BDBF6] on [WebNotes]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_WebNotes_BDBF6 on [dbo].[WebNotes]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_WebNotes_BDBF6 on [dbo].[WebNotes]([IsActive],[dtExpiration]) Include ([WebNoteID]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 019 - 0000227088 */  RAISERROR('Updateing Statistics ON [Download]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[Download]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[Download]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_Download_2B899] on [Download]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 1.29
 
                        SELECT    @cEEvent       = 'AMIX_Download_2B899 on [dbo].[Download]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_Download_2B899 on [dbo].[Download]([SiteId],[DownloadID], [CreatedDate]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 020 - 0000211811 */  RAISERROR('Updateing Statistics ON [ImagePackInstanceStateChange]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[Subscription].[ImagePackInstanceStateChange]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [Subscription].[ImagePackInstanceStateChange]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_ImagePackInstanceStateChange_4C720] on [ImagePackInstanceStateChange]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.01
 
                        SELECT    @cEEvent       = 'AMIX_ImagePackInstanceStateChange_4C720 on [Subscription].[ImagePackInstanceStateChange]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_ImagePackInstanceStateChange_4C720 on [Subscription].[ImagePackInstanceStateChange]([ImagePackInstanceId], [NewStateId]) Include ([StateChangeReason]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 021 - 0000134462 */  RAISERROR('Updateing Statistics ON [DistributorContractNote]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[DistributorContractNote]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[DistributorContractNote]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_DistributorContractNote_2CDFC] on [DistributorContractNote]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.02
 
                        SELECT    @cEEvent       = 'AMIX_DistributorContractNote_2CDFC on [dbo].[DistributorContractNote]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_DistributorContractNote_2CDFC on [dbo].[DistributorContractNote]([iContractID]) Include ([iNoteID], [nvchNote], [tiActiveFlag], [iCreatedBy], [dtCreated]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 022 - 0000119801 */  RAISERROR('Updateing Statistics ON [CartDetail]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[CartDetail]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[CartDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_CartDetail_320A0] on [CartDetail]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.51
 
                        SELECT    @cEEvent       = 'AMIX_CartDetail_320A0 on [dbo].[CartDetail]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_CartDetail_320A0 on [dbo].[CartDetail]([iDurationId],[iMediaTypeID], [mUnitPrice], [iUsageId]) Include ([iCartDetailID], [iCartID], [vchMasterID], [dtCreated]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 023 - 0000117349 */  RAISERROR('Updateing Statistics ON [IndividualCommissionData]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[IndividualCommissionData]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[IndividualCommissionData]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_IndividualCommissionData_A2BD0] on [IndividualCommissionData]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.67
 
                        SELECT    @cEEvent       = 'AMIX_IndividualCommissionData_A2BD0 on [dbo].[IndividualCommissionData]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_IndividualCommissionData_A2BD0 on [dbo].[IndividualCommissionData]([LastPurchaseDate],[CommissionStatusID]) Include ([IndividualId], [IsInherited], [Override]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 024 - 0000111283 */  RAISERROR('Updateing Statistics ON [CompanySCIUserRel]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[CompanySCIUserRel]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[CompanySCIUserRel]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_CompanySCIUserRel_070A2] on [CompanySCIUserRel]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_CompanySCIUserRel_070A2 on [dbo].[CompanySCIUserRel]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_CompanySCIUserRel_070A2 on [dbo].[CompanySCIUserRel]([iStatusID]) Include ([iSCIOwnerId]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 025 - 0000077954 */  RAISERROR('Updateing Statistics ON [SecuritySystem]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[SecuritySystem]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[SecuritySystem]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_SecuritySystem_8C900] on [SecuritySystem]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_SecuritySystem_8C900 on [dbo].[SecuritySystem]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_SecuritySystem_8C900 on [dbo].[SecuritySystem]([OwningCompanyId]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 026 - 0000075410 */  RAISERROR('Updateing Statistics ON [OrderPromotion]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[OrderPromotion]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[OrderPromotion]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_OrderPromotion_42703] on [OrderPromotion]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_OrderPromotion_42703 on [dbo].[OrderPromotion]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_OrderPromotion_42703 on [dbo].[OrderPromotion]([UserPromoCode], [IndividualId]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 027 - 0000070388 */  RAISERROR('Updateing Statistics ON [MediaBin]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[MediaBin]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[MediaBin]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_MediaBin_ACEF0] on [MediaBin]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.14
 
                        SELECT    @cEEvent       = 'AMIX_MediaBin_ACEF0 on [dbo].[MediaBin]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_MediaBin_ACEF0 on [dbo].[MediaBin]([iOwnedByID], [iOwnedByIDType], [iOriginalSystemID]) Include ([iMediaBinID], [vchMediaBinName], [tiShared]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 028 - 0000062395 */  RAISERROR('Updateing Statistics ON [DistributorContractPercentage]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[DistributorContractPercentage]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[DistributorContractPercentage]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_DistributorContractPercentage_160B9] on [DistributorContractPercentage]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.07
 
                        SELECT    @cEEvent       = 'AMIX_DistributorContractPercentage_160B9 on [dbo].[DistributorContractPercentage]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_DistributorContractPercentage_160B9 on [dbo].[DistributorContractPercentage]([iPercentTypeID]) Include ([iContractID]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 029 - 0000059075 */  RAISERROR('Updateing Statistics ON [FlickrImageRequest]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[Flickr].[FlickrImageRequest]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [Flickr].[FlickrImageRequest]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_FlickrImageRequest_B69F5] on [FlickrImageRequest]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.98
 
                        SELECT    @cEEvent       = 'AMIX_FlickrImageRequest_B69F5 on [Flickr].[FlickrImageRequest]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_FlickrImageRequest_B69F5 on [Flickr].[FlickrImageRequest]([CheckedOutDate]) Include ([FlickrImageRequestID], [CurrentStatusID], [ExpirationDate], [ModifiedDate]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 030 - 0000027970 */  RAISERROR('Updateing Statistics ON [Phone]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[Phone]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[Phone]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_Phone_6E441] on [Phone]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_Phone_6E441 on [dbo].[Phone]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_Phone_6E441 on [dbo].[Phone]([iEntityTypeID], [iTechnologyTypeID], [iUsageTypeID]) Include ([iEntityID], [vchPhoneNumber], [vchExtension]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 031 - 0000012060 */  RAISERROR('Updateing Statistics ON [AuthGroupIndividual]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[AuthGroupIndividual]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[AuthGroupIndividual]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_AuthGroupIndividual_ACDC9] on [AuthGroupIndividual]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_AuthGroupIndividual_ACDC9 on [dbo].[AuthGroupIndividual]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_AuthGroupIndividual_ACDC9 on [dbo].[AuthGroupIndividual]([AuthGroupID]) Include ([IndividualID]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 032 - 0000009098 */  RAISERROR('Updateing Statistics ON [LicensePreferenceBrand]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[LicensePreferenceBrand]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[LicensePreferenceBrand]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_LicensePreferenceBrand_CB7F0] on [LicensePreferenceBrand]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.01
 
                        SELECT    @cEEvent       = 'AMIX_LicensePreferenceBrand_CB7F0 on [dbo].[LicensePreferenceBrand]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_LicensePreferenceBrand_CB7F0 on [dbo].[LicensePreferenceBrand]([BrandID]) Include ([LicensePreferenceID]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 033 - 0000006662 */  RAISERROR('Updateing Statistics ON [SubscriptionBillingHistory]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[Subscription].[SubscriptionBillingHistory]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [Subscription].[SubscriptionBillingHistory]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_SubscriptionBillingHistory_36D9E] on [SubscriptionBillingHistory]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_SubscriptionBillingHistory_36D9E on [Subscription].[SubscriptionBillingHistory]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_SubscriptionBillingHistory_36D9E on [Subscription].[SubscriptionBillingHistory]([SubscriptionBillingStatusID]) Include ([SubscriptionID], [BillingAmount]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 034 - 0000004035 */  RAISERROR('Updateing Statistics ON [SCIDomainAccount]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[SCIDomainAccount]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[SCIDomainAccount]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_SCIDomainAccount_E39FF] on [SCIDomainAccount]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_SCIDomainAccount_E39FF on [dbo].[SCIDomainAccount]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_SCIDomainAccount_E39FF on [dbo].[SCIDomainAccount]([bUnassignedProxy]) Include ([iIndividualID]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 035 - 0000001869 */  RAISERROR('Updateing Statistics ON [FlickrImageRequestDetail]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[Flickr].[FlickrImageRequestDetail]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [Flickr].[FlickrImageRequestDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_FlickrImageRequestDetail_66299] on [FlickrImageRequestDetail]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.33
 
                        SELECT    @cEEvent       = 'AMIX_FlickrImageRequestDetail_66299 on [Flickr].[FlickrImageRequestDetail]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_FlickrImageRequestDetail_66299 on [Flickr].[FlickrImageRequestDetail]([FlickrImageRequestID]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 036 - 0000001282 */  RAISERROR('Updateing Statistics ON [EasyAccessDetail]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[EasyAccessDetail]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[EasyAccessDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_EasyAccessDetail_12840] on [EasyAccessDetail]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_EasyAccessDetail_12840 on [dbo].[EasyAccessDetail]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_EasyAccessDetail_12840 on [dbo].[EasyAccessDetail]([RemovalDate]) Include ([EasyAccessDetailId], [ModifiedDate]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 037 - 0000001252 */  RAISERROR('Updateing Statistics ON [DistributorContract]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[DistributorContract]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[DistributorContract]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_DistributorContract_CB412] on [DistributorContract]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_DistributorContract_CB412 on [dbo].[DistributorContract]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_DistributorContract_CB412 on [dbo].[DistributorContract]([iCompanyID], [iStatus],[iContractID]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 038 - 0000001238 */  RAISERROR('Updateing Statistics ON [EasyAccessDetailInfo]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[EasyAccessDetailInfo]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[EasyAccessDetailInfo]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_EasyAccessDetailInfo_0EA20] on [EasyAccessDetailInfo]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_EasyAccessDetailInfo_0EA20 on [dbo].[EasyAccessDetailInfo]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_EasyAccessDetailInfo_0EA20 on [dbo].[EasyAccessDetailInfo]([EasyAccessTypeId]) Include ([EasyAccessDetailId], [PortfolioCollectionId]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 039 - 0000000267 */  RAISERROR('Updateing Statistics ON [SubscriptionAutoRenewal]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[Subscription].[SubscriptionAutoRenewal]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [Subscription].[SubscriptionAutoRenewal]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_SubscriptionAutoRenewal_7E9B9] on [SubscriptionAutoRenewal]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_SubscriptionAutoRenewal_7E9B9 on [Subscription].[SubscriptionAutoRenewal]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_SubscriptionAutoRenewal_7E9B9 on [Subscription].[SubscriptionAutoRenewal]([IsAutoRenewal]) Include ([SubscriptionID]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 040 - 0000000190 */  RAISERROR('Updateing Statistics ON [AuxDelivery]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[AuxDelivery]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[AuxDelivery]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_AuxDelivery_E41EB] on [AuxDelivery]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.07
 
                        SELECT    @cEEvent       = 'AMIX_AuxDelivery_E41EB on [dbo].[AuxDelivery]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_AuxDelivery_E41EB on [dbo].[AuxDelivery]([iIndividualID], [iOriginalSystemID]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
/* 041 - 0000000141 */  RAISERROR('Updateing Statistics ON [BuildDetail]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[BuildDetail]'
                                  ,@cECategory   = 'UPDATE STATISTICS'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        UPDATE STATISTICS [dbo].[BuildDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
                        RAISERROR('Creating Index [AMIX_BuildDetail_96F50] on [BuildDetail]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 4.07
 
                        SELECT    @cEEvent       = 'AMIX_BuildDetail_96F50 on [dbo].[BuildDetail]'
                                  ,@cECategory   = 'CREATE MISSING INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        CREATE NONCLUSTERED INDEX AMIX_BuildDetail_96F50 on [dbo].[BuildDetail]([vchLabel],[ScriptName]) WITH(MAXDOP=8,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
 
	SELECT  * FROM [dbaadmin].[dbo].[EventLog] where cEGUID = @cEGUID
 
 
 
 
 
RAISERROR('Dropping Index [IX_LoginDate_Site_UserName] on [SiteActivity].[UserLogins]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 24830721  RATIO: 24830721.00  SIZE: 59.65 GB
                        SELECT    @cEEvent       = '[IX_LoginDate_Site_UserName] on [SiteActivity].[UserLogins]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [IX_LoginDate_Site_UserName] ON [SiteActivity].[UserLogins] (  LoginDate ASC  , SiteID ASC  , UserName ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[IX_LoginDate_Site_UserName] on [SiteActivity].[UserLogins]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [IX_LoginDate_Site_UserName] ON [SiteActivity].[UserLogins]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [IX_LoginDate_UserName] on [SiteActivity].[UserLogins]',-1,-1) WITH NOWAIT
  --  READS: 16119  WRITES: 24830721  RATIO: 1540.46  SIZE: 40.69 GB
                        SELECT    @cEEvent       = '[IX_LoginDate_UserName] on [SiteActivity].[UserLogins]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [IX_LoginDate_UserName] ON [SiteActivity].[UserLogins] (  LoginDate ASC  , UserName ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[IX_LoginDate_UserName] on [SiteActivity].[UserLogins]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [IX_LoginDate_UserName] ON [SiteActivity].[UserLogins]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [IX_DownloadDetail_SourceDetailID_StatusID_I_DownloadDetailID_ImageID] on [dbo].[DownloadDetail]',-1,-1) WITH NOWAIT
  --  READS: 8527  WRITES: 12222685  RATIO: 1433.41  SIZE: 11.11 GB
                        SELECT    @cEEvent       = '[IX_DownloadDetail_SourceDetailID_StatusID_I_DownloadDetailID_ImageID] on [dbo].[DownloadDetail]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [IX_DownloadDetail_SourceDetailID_StatusID_I_DownloadDetailID_ImageID] ON [dbo].[DownloadDetail] (  SourceDetailID ASC  , StatusID ASC  )   INCLUDE ( DownloadDetailID , ImageID )  WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[IX_DownloadDetail_SourceDetailID_StatusID_I_DownloadDetailID_ImageID] on [dbo].[DownloadDetail]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [IX_DownloadDetail_SourceDetailID_StatusID_I_DownloadDetailID_ImageID] ON [dbo].[DownloadDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [IX_Download_DownloadStatusID_I_DownloadID_SiteId_CreatedDate] on [dbo].[Download]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 12421924  RATIO: 12421924.00  SIZE: 10.88 GB
                        SELECT    @cEEvent       = '[IX_Download_DownloadStatusID_I_DownloadID_SiteId_CreatedDate] on [dbo].[Download]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [IX_Download_DownloadStatusID_I_DownloadID_SiteId_CreatedDate] ON [dbo].[Download] (  DownloadStatusID ASC  )   INCLUDE ( CreatedDate , DownloadID , SiteId )  WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[IX_Download_DownloadStatusID_I_DownloadID_SiteId_CreatedDate] on [dbo].[Download]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [IX_Download_DownloadStatusID_I_DownloadID_SiteId_CreatedDate] ON [dbo].[Download]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [PA-queryIndex] on [dbo].[DownloadDetail]',-1,-1) WITH NOWAIT
  --  READS: 419575  WRITES: 12222879  RATIO: 29.13  SIZE: 9.33 GB
                        SELECT    @cEEvent       = '[PA-queryIndex] on [dbo].[DownloadDetail]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [PA-queryIndex] ON [dbo].[DownloadDetail] (  DownloadSourceId ASC  , StatusID ASC  )   INCLUDE ( CompanyId , DownloadDetailID , DownloadId , OrderDetailID , OrderID , SourceDetailID )  WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[PA-queryIndex] on [dbo].[DownloadDetail]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [PA-queryIndex] ON [dbo].[DownloadDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [nclDownloadDetail_CompanyIdImageId] on [dbo].[DownloadDetail]',-1,-1) WITH NOWAIT
  --  READS: 8474  WRITES: 12201443  RATIO: 1439.87  SIZE: 9.07 GB
                        SELECT    @cEEvent       = '[nclDownloadDetail_CompanyIdImageId] on [dbo].[DownloadDetail]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [nclDownloadDetail_CompanyIdImageId] ON [dbo].[DownloadDetail] (  CompanyId ASC  , ImageID ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[nclDownloadDetail_CompanyIdImageId] on [dbo].[DownloadDetail]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [nclDownloadDetail_CompanyIdImageId] ON [dbo].[DownloadDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [IX_DownloadDetail_StatusModifiedDateTime] on [dbo].[DownloadDetail]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 12214290  RATIO: 12214290.00  SIZE: 7.14 GB
                        SELECT    @cEEvent       = '[IX_DownloadDetail_StatusModifiedDateTime] on [dbo].[DownloadDetail]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [IX_DownloadDetail_StatusModifiedDateTime] ON [dbo].[DownloadDetail] (  StatusModifiedDateTime ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[IX_DownloadDetail_StatusModifiedDateTime] on [dbo].[DownloadDetail]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [IX_DownloadDetail_StatusModifiedDateTime] ON [dbo].[DownloadDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [dtModified_ndx] on [dbo].[MediaBinItem]',-1,-1) WITH NOWAIT
  --  READS: 1  WRITES: 1677373  RATIO: 1677373.00  SIZE: 5.74 GB
                        SELECT    @cEEvent       = '[dtModified_ndx] on [dbo].[MediaBinItem]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [dtModified_ndx] ON [dbo].[MediaBinItem] (  dtModified ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[dtModified_ndx] on [dbo].[MediaBinItem]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [dtModified_ndx] ON [dbo].[MediaBinItem]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [nclDownload_CreatedDate] on [dbo].[Download]',-1,-1) WITH NOWAIT
  --  READS: 45  WRITES: 12421924  RATIO: 276042.76  SIZE: 5.57 GB
                        SELECT    @cEEvent       = '[nclDownload_CreatedDate] on [dbo].[Download]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [nclDownload_CreatedDate] ON [dbo].[Download] (  CreatedDate ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[nclDownload_CreatedDate] on [dbo].[Download]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [nclDownload_CreatedDate] ON [dbo].[Download]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [NCLDownloadDetail_DownloadSourceID] on [dbo].[DownloadDetail]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 12201443  RATIO: 12201443.00  SIZE: 3.78 GB
                        SELECT    @cEEvent       = '[NCLDownloadDetail_DownloadSourceID] on [dbo].[DownloadDetail]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [NCLDownloadDetail_DownloadSourceID] ON [dbo].[DownloadDetail] (  DownloadSourceId ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[NCLDownloadDetail_DownloadSourceID] on [dbo].[DownloadDetail]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [NCLDownloadDetail_DownloadSourceID] ON [dbo].[DownloadDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [dtModified_ndx] on [dbo].[MediaBin]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 3637630  RATIO: 3637630.00  SIZE: 2.48 GB
                        SELECT    @cEEvent       = '[dtModified_ndx] on [dbo].[MediaBin]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [dtModified_ndx] ON [dbo].[MediaBin] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[dtModified_ndx] on [dbo].[MediaBin]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [dtModified_ndx] ON [dbo].[MediaBin]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [iCompanyID_ndx] on [dbo].[MediaBin]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 2014562  RATIO: 2014562.00  SIZE: 1.29 GB
                        SELECT    @cEEvent       = '[iCompanyID_ndx] on [dbo].[MediaBin]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [iCompanyID_ndx] ON [dbo].[MediaBin] (  iCompanyID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[iCompanyID_ndx] on [dbo].[MediaBin]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [iCompanyID_ndx] ON [dbo].[MediaBin]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[IndividualPreference]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 1740166  RATIO: 1740166.00  SIZE: 1.06 GB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[IndividualPreference]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[IndividualPreference] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[IndividualPreference]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[IndividualPreference]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [PhoneNumber_ndx] on [dbo].[Phone]',-1,-1) WITH NOWAIT
  --  READS: 90  WRITES: 50015  RATIO: 555.72  SIZE: 934.71 MB
                        SELECT    @cEEvent       = '[PhoneNumber_ndx] on [dbo].[Phone]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [PhoneNumber_ndx] ON [dbo].[Phone] (  vchPhoneNumber ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[PhoneNumber_ndx] on [dbo].[Phone]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [PhoneNumber_ndx] ON [dbo].[Phone]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[CartDetail]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 3339751  RATIO: 3339751.00  SIZE: 924.18 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[CartDetail]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[CartDetail] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[CartDetail]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[CartDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[OrderDetail]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 157008  RATIO: 157008.00  SIZE: 883.59 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[OrderDetail]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[OrderDetail] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[OrderDetail]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[OrderDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixCreateddate] on [dbo].[OrderDetail]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 148388  RATIO: 148388.00  SIZE: 856.54 MB
                        SELECT    @cEEvent       = '[ixCreateddate] on [dbo].[OrderDetail]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixCreateddate] ON [dbo].[OrderDetail] (  dtCreated ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixCreateddate] on [dbo].[OrderDetail]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixCreateddate] ON [dbo].[OrderDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[Address]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 60583  RATIO: 60583.00  SIZE: 854.34 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[Address]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[Address] (  dtModified ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[Address]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[Address]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [OrderDetail_QuoteID_Ndx] on [dbo].[OrderDetail]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 148388  RATIO: 148388.00  SIZE: 828.98 MB
                        SELECT    @cEEvent       = '[OrderDetail_QuoteID_Ndx] on [dbo].[OrderDetail]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [OrderDetail_QuoteID_Ndx] ON [dbo].[OrderDetail] (  QuoteID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[OrderDetail_QuoteID_Ndx] on [dbo].[OrderDetail]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [OrderDetail_QuoteID_Ndx] ON [dbo].[OrderDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [OrderDetail_iRightsOverrideBy_Ndx] on [dbo].[OrderDetail]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 148388  RATIO: 148388.00  SIZE: 819.79 MB
                        SELECT    @cEEvent       = '[OrderDetail_iRightsOverrideBy_Ndx] on [dbo].[OrderDetail]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [OrderDetail_iRightsOverrideBy_Ndx] ON [dbo].[OrderDetail] (  iRightsOverrideBy ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[OrderDetail_iRightsOverrideBy_Ndx] on [dbo].[OrderDetail]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [OrderDetail_iRightsOverrideBy_Ndx] ON [dbo].[OrderDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [CartDetail_iRightsOverrideBy_Ndx] on [dbo].[CartDetail]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 3320218  RATIO: 3320218.00  SIZE: 734.91 MB
                        SELECT    @cEEvent       = '[CartDetail_iRightsOverrideBy_Ndx] on [dbo].[CartDetail]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [CartDetail_iRightsOverrideBy_Ndx] ON [dbo].[CartDetail] (  iRightsOverrideBy ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[CartDetail_iRightsOverrideBy_Ndx] on [dbo].[CartDetail]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [CartDetail_iRightsOverrideBy_Ndx] ON [dbo].[CartDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixCreateddate] on [dbo].[Address]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 49932  RATIO: 49932.00  SIZE: 716.95 MB
                        SELECT    @cEEvent       = '[ixCreateddate] on [dbo].[Address]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixCreateddate] ON [dbo].[Address] (  dtCreated ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixCreateddate] on [dbo].[Address]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixCreateddate] ON [dbo].[Address]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [WebSiteUseCompany_ndx] on [dbo].[WebSiteUse]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 65476  RATIO: 65476.00  SIZE: 575.89 MB
                        SELECT    @cEEvent       = '[WebSiteUseCompany_ndx] on [dbo].[WebSiteUse]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [WebSiteUseCompany_ndx] ON [dbo].[WebSiteUse] (  iCompanyID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[WebSiteUseCompany_ndx] on [dbo].[WebSiteUse]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [WebSiteUseCompany_ndx] ON [dbo].[WebSiteUse]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[WebSiteUse]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 117755  RATIO: 117755.00  SIZE: 562.19 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[WebSiteUse]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[WebSiteUse] (  dtModified ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[WebSiteUse]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[WebSiteUse]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixCompanyShipToAddress] on [dbo].[Orders]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 59495  RATIO: 59495.00  SIZE: 474.60 MB
                        SELECT    @cEEvent       = '[ixCompanyShipToAddress] on [dbo].[Orders]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixCompanyShipToAddress] ON [dbo].[Orders] (  iInvoiceToAddressID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixCompanyShipToAddress] on [dbo].[Orders]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixCompanyShipToAddress] ON [dbo].[Orders]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [PhoneEntityType_cmp_cvr_ndx] on [dbo].[Phone]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 43184  RATIO: 43184.00  SIZE: 471.66 MB
                        SELECT    @cEEvent       = '[PhoneEntityType_cmp_cvr_ndx] on [dbo].[Phone]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [PhoneEntityType_cmp_cvr_ndx] ON [dbo].[Phone] (  iEntityID ASC  , iEntityTypeID ASC  , iPhoneID ASC  , iUsageTypeID ASC  , iTechnologyTypeID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[PhoneEntityType_cmp_cvr_ndx] on [dbo].[Phone]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [PhoneEntityType_cmp_cvr_ndx] ON [dbo].[Phone]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[Phone]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 50602  RATIO: 50602.00  SIZE: 441.65 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[Phone]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[Phone] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[Phone]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[Phone]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [IndividualFamilyName_ndx] on [dbo].[Individual]',-1,-1) WITH NOWAIT
  --  READS: 3328  WRITES: 65060  RATIO: 19.55  SIZE: 440.65 MB
                        SELECT    @cEEvent       = '[IndividualFamilyName_ndx] on [dbo].[Individual]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [IndividualFamilyName_ndx] ON [dbo].[Individual] (  vchFamilyName ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[IndividualFamilyName_ndx] on [dbo].[Individual]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [IndividualFamilyName_ndx] ON [dbo].[Individual]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixCreateddate] on [dbo].[Phone]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 43184  RATIO: 43184.00  SIZE: 439.98 MB
                        SELECT    @cEEvent       = '[ixCreateddate] on [dbo].[Phone]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixCreateddate] ON [dbo].[Phone] (  dtCreated ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixCreateddate] on [dbo].[Phone]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixCreateddate] ON [dbo].[Phone]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [OrdersBillTo_ndx] on [dbo].[Orders]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 59495  RATIO: 59495.00  SIZE: 434.90 MB
                        SELECT    @cEEvent       = '[OrdersBillTo_ndx] on [dbo].[Orders]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [OrdersBillTo_ndx] ON [dbo].[Orders] (  iBillToAddressID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[OrdersBillTo_ndx] on [dbo].[Orders]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [OrdersBillTo_ndx] ON [dbo].[Orders]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [OrdersSalesPers_ndx] on [dbo].[Orders]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 59495  RATIO: 59495.00  SIZE: 433.98 MB
                        SELECT    @cEEvent       = '[OrdersSalesPers_ndx] on [dbo].[Orders]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [OrdersSalesPers_ndx] ON [dbo].[Orders] (  iSalesPersonID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[OrdersSalesPers_ndx] on [dbo].[Orders]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [OrdersSalesPers_ndx] ON [dbo].[Orders]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [IndividualShipTo_ndx] on [dbo].[Individual]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 25583  RATIO: 25583.00  SIZE: 432.84 MB
                        SELECT    @cEEvent       = '[IndividualShipTo_ndx] on [dbo].[Individual]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [IndividualShipTo_ndx] ON [dbo].[Individual] (  iPrimShipToAddressID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[IndividualShipTo_ndx] on [dbo].[Individual]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [IndividualShipTo_ndx] ON [dbo].[Individual]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [OrdersShipTo_ndx] on [dbo].[Orders]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 59495  RATIO: 59495.00  SIZE: 432.31 MB
                        SELECT    @cEEvent       = '[OrdersShipTo_ndx] on [dbo].[Orders]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [OrdersShipTo_ndx] ON [dbo].[Orders] (  iShipToAddressID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[OrdersShipTo_ndx] on [dbo].[Orders]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [OrdersShipTo_ndx] ON [dbo].[Orders]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[Individual]',-1,-1) WITH NOWAIT
  --  READS: 375  WRITES: 186630  RATIO: 497.68  SIZE: 429.94 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[Individual]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[Individual] (  dtModified ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[Individual]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[Individual]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [IndividualGivenName_ndx] on [dbo].[Individual]',-1,-1) WITH NOWAIT
  --  READS: 2817  WRITES: 65103  RATIO: 23.11  SIZE: 427.76 MB
                        SELECT    @cEEvent       = '[IndividualGivenName_ndx] on [dbo].[Individual]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [IndividualGivenName_ndx] ON [dbo].[Individual] (  vchGivenName ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[IndividualGivenName_ndx] on [dbo].[Individual]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [IndividualGivenName_ndx] ON [dbo].[Individual]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixCreateddate] on [dbo].[WebSiteUse]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 57835  RATIO: 57835.00  SIZE: 425.55 MB
                        SELECT    @cEEvent       = '[ixCreateddate] on [dbo].[WebSiteUse]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixCreateddate] ON [dbo].[WebSiteUse] (  dtCreated ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixCreateddate] on [dbo].[WebSiteUse]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixCreateddate] ON [dbo].[WebSiteUse]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [IndividualCountry_fk_ndx] on [dbo].[Individual]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 63806  RATIO: 63806.00  SIZE: 406.04 MB
                        SELECT    @cEEvent       = '[IndividualCountry_fk_ndx] on [dbo].[Individual]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [IndividualCountry_fk_ndx] ON [dbo].[Individual] (  nchCountryCode ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[IndividualCountry_fk_ndx] on [dbo].[Individual]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [IndividualCountry_fk_ndx] ON [dbo].[Individual]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [CartDetail_CartDetailNoteID_Ndx] on [dbo].[CartDetail]',-1,-1) WITH NOWAIT
  --  READS: 13220  WRITES: 3498494  RATIO: 264.64  SIZE: 402.47 MB
                        SELECT    @cEEvent       = '[CartDetail_CartDetailNoteID_Ndx] on [dbo].[CartDetail]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [CartDetail_CartDetailNoteID_Ndx] ON [dbo].[CartDetail] (  CartDetailNoteID ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[CartDetail_CartDetailNoteID_Ndx] on [dbo].[CartDetail]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [CartDetail_CartDetailNoteID_Ndx] ON [dbo].[CartDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [CartDetail_QuoteID_Ndx] on [dbo].[CartDetail]',-1,-1) WITH NOWAIT
  --  READS: 28548  WRITES: 3320218  RATIO: 116.30  SIZE: 402.33 MB
                        SELECT    @cEEvent       = '[CartDetail_QuoteID_Ndx] on [dbo].[CartDetail]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [CartDetail_QuoteID_Ndx] ON [dbo].[CartDetail] (  QuoteID ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[CartDetail_QuoteID_Ndx] on [dbo].[CartDetail]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [CartDetail_QuoteID_Ndx] ON [dbo].[CartDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [IndividualBillTo_ndx] on [dbo].[Individual]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 36365  RATIO: 36365.00  SIZE: 399.98 MB
                        SELECT    @cEEvent       = '[IndividualBillTo_ndx] on [dbo].[Individual]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [IndividualBillTo_ndx] ON [dbo].[Individual] (  iPrimBillToAddressID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[IndividualBillTo_ndx] on [dbo].[Individual]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [IndividualBillTo_ndx] ON [dbo].[Individual]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixModifieddate] on [dbo].[Company]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 128913  RATIO: 128913.00  SIZE: 387.03 MB
                        SELECT    @cEEvent       = '[ixModifieddate] on [dbo].[Company]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixModifieddate] ON [dbo].[Company] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixModifieddate] on [dbo].[Company]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixModifieddate] ON [dbo].[Company]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[Orders]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 59570  RATIO: 59570.00  SIZE: 382.13 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[Orders]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[Orders] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[Orders]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[Orders]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixCreateddate] on [dbo].[Orders]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 59495  RATIO: 59495.00  SIZE: 378.54 MB
                        SELECT    @cEEvent       = '[ixCreateddate] on [dbo].[Orders]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixCreateddate] ON [dbo].[Orders] (  dtCreated ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixCreateddate] on [dbo].[Orders]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixCreateddate] ON [dbo].[Orders]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [IndividualMailTo_ndx] on [dbo].[Individual]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 30599  RATIO: 30599.00  SIZE: 368.99 MB
                        SELECT    @cEEvent       = '[IndividualMailTo_ndx] on [dbo].[Individual]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [IndividualMailTo_ndx] ON [dbo].[Individual] (  iPrimMailToAddressID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[IndividualMailTo_ndx] on [dbo].[Individual]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [IndividualMailTo_ndx] ON [dbo].[Individual]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixCartAddress] on [dbo].[Cart]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 3996430  RATIO: 3996430.00  SIZE: 367.63 MB
                        SELECT    @cEEvent       = '[ixCartAddress] on [dbo].[Cart]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixCartAddress] ON [dbo].[Cart] (  iShipToAddressId ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixCartAddress] on [dbo].[Cart]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixCartAddress] ON [dbo].[Cart]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[CartDetailNote]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 145450  RATIO: 145450.00  SIZE: 360.06 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[CartDetailNote]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[CartDetailNote] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[CartDetailNote]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[CartDetailNote]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [OrdersDate_ndx] on [dbo].[Orders]',-1,-1) WITH NOWAIT
  --  READS: 2674  WRITES: 59495  RATIO: 22.25  SIZE: 352.70 MB
                        SELECT    @cEEvent       = '[OrdersDate_ndx] on [dbo].[Orders]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [OrdersDate_ndx] ON [dbo].[Orders] (  dtOrderDate ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[OrdersDate_ndx] on [dbo].[Orders]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [OrdersDate_ndx] ON [dbo].[Orders]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixCreateddate] on [dbo].[Individual]',-1,-1) WITH NOWAIT
  --  READS: 375  WRITES: 20612  RATIO: 54.97  SIZE: 323.46 MB
                        SELECT    @cEEvent       = '[ixCreateddate] on [dbo].[Individual]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixCreateddate] ON [dbo].[Individual] (  dtCreated ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixCreateddate] on [dbo].[Individual]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixCreateddate] ON [dbo].[Individual]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[OrderInvoiceInfo]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 56027  RATIO: 56027.00  SIZE: 300.55 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[OrderInvoiceInfo]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[OrderInvoiceInfo] (  ModifiedDate ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[OrderInvoiceInfo]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[OrderInvoiceInfo]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [IX_PremiumAccessDownloadLog_DownloadId] on [dbo].[PremiumAccessDownloadLog]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 283057  RATIO: 283057.00  SIZE: 282.57 MB
                        SELECT    @cEEvent       = '[IX_PremiumAccessDownloadLog_DownloadId] on [dbo].[PremiumAccessDownloadLog]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [IX_PremiumAccessDownloadLog_DownloadId] ON [dbo].[PremiumAccessDownloadLog] (  DownloadId ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[IX_PremiumAccessDownloadLog_DownloadId] on [dbo].[PremiumAccessDownloadLog]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [IX_PremiumAccessDownloadLog_DownloadId] ON [dbo].[PremiumAccessDownloadLog]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [CartCompany_ndx] on [dbo].[Cart]',-1,-1) WITH NOWAIT
  --  READS: 12175  WRITES: 3996430  RATIO: 328.25  SIZE: 273.02 MB
                        SELECT    @cEEvent       = '[CartCompany_ndx] on [dbo].[Cart]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [CartCompany_ndx] ON [dbo].[Cart] (  iCompanyID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[CartCompany_ndx] on [dbo].[Cart]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [CartCompany_ndx] ON [dbo].[Cart]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[IndividualInterestType]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 40250  RATIO: 40250.00  SIZE: 260.49 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[IndividualInterestType]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[IndividualInterestType] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[IndividualInterestType]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[IndividualInterestType]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ConsolidatedBilling_imp_iCompanyID_Ndx] on [dbo].[ConsolidatedBilling_imp]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 54673  RATIO: 54673.00  SIZE: 258.34 MB
                        SELECT    @cEEvent       = '[ConsolidatedBilling_imp_iCompanyID_Ndx] on [dbo].[ConsolidatedBilling_imp]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ConsolidatedBilling_imp_iCompanyID_Ndx] ON [dbo].[ConsolidatedBilling_imp] (  iCompanyID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ConsolidatedBilling_imp_iCompanyID_Ndx] on [dbo].[ConsolidatedBilling_imp]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ConsolidatedBilling_imp_iCompanyID_Ndx] ON [dbo].[ConsolidatedBilling_imp]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixCreateddate] on [dbo].[OrderDetailNote]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 28983  RATIO: 28983.00  SIZE: 257.52 MB
                        SELECT    @cEEvent       = '[ixCreateddate] on [dbo].[OrderDetailNote]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixCreateddate] ON [dbo].[OrderDetailNote] (  dtCreated ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixCreateddate] on [dbo].[OrderDetailNote]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixCreateddate] ON [dbo].[OrderDetailNote]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[OrderDetailNote]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 28983  RATIO: 28983.00  SIZE: 236.80 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[OrderDetailNote]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[OrderDetailNote] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[OrderDetailNote]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[OrderDetailNote]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ix1] on [dbo].[IndividualCommissionData]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 20680  RATIO: 20680.00  SIZE: 224.22 MB
                        SELECT    @cEEvent       = '[ix1] on [dbo].[IndividualCommissionData]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ix1] ON [dbo].[IndividualCommissionData] (  FirstPurchaseDate ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ix1] on [dbo].[IndividualCommissionData]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ix1] ON [dbo].[IndividualCommissionData]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ix4] on [dbo].[IndividualCommissionData]',-1,-1) WITH NOWAIT
  --  READS: 17  WRITES: 38216  RATIO: 2248.00  SIZE: 208.50 MB
                        SELECT    @cEEvent       = '[ix4] on [dbo].[IndividualCommissionData]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ix4] ON [dbo].[IndividualCommissionData] (  CommissionCalculationDate ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ix4] on [dbo].[IndividualCommissionData]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ix4] ON [dbo].[IndividualCommissionData]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[OrderExtension]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 59495  RATIO: 59495.00  SIZE: 205.30 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[OrderExtension]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[OrderExtension] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[OrderExtension]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[OrderExtension]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ix_OrderAggDate] on [dbo].[IndividualCommissionData]',-1,-1) WITH NOWAIT
  --  READS: 17  WRITES: 20680  RATIO: 1216.47  SIZE: 186.35 MB
                        SELECT    @cEEvent       = '[ix_OrderAggDate] on [dbo].[IndividualCommissionData]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ix_OrderAggDate] ON [dbo].[IndividualCommissionData] (  OrderAggregationDate ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ix_OrderAggDate] on [dbo].[IndividualCommissionData]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ix_OrderAggDate] ON [dbo].[IndividualCommissionData]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ix2] on [dbo].[IndividualCommissionData]',-1,-1) WITH NOWAIT
  --  READS: 17  WRITES: 20680  RATIO: 1216.47  SIZE: 186.34 MB
                        SELECT    @cEEvent       = '[ix2] on [dbo].[IndividualCommissionData]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ix2] ON [dbo].[IndividualCommissionData] (  LastPurchaseDate ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ix2] on [dbo].[IndividualCommissionData]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ix2] ON [dbo].[IndividualCommissionData]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ix5] on [dbo].[IndividualCommissionData]',-1,-1) WITH NOWAIT
  --  READS: 34  WRITES: 20646  RATIO: 607.24  SIZE: 176.23 MB
                        SELECT    @cEEvent       = '[ix5] on [dbo].[IndividualCommissionData]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ix5] ON [dbo].[IndividualCommissionData] (  OverrideExpiry ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ix5] on [dbo].[IndividualCommissionData]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ix5] ON [dbo].[IndividualCommissionData]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [CreditCardValues_cmp_cvr_ndx] on [dbo].[CreditCard]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 13864  RATIO: 13864.00  SIZE: 169.41 MB
                        SELECT    @cEEvent       = '[CreditCardValues_cmp_cvr_ndx] on [dbo].[CreditCard]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [CreditCardValues_cmp_cvr_ndx] ON [dbo].[CreditCard] (  iIndividualID ASC  , vchCcNumber ASC  , vchNameOnCard ASC  , sdtCcExpirationDate ASC  , iTypeID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[CreditCardValues_cmp_cvr_ndx] on [dbo].[CreditCard]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [CreditCardValues_cmp_cvr_ndx] ON [dbo].[CreditCard]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[OrderTax]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 38767  RATIO: 38767.00  SIZE: 160.84 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[OrderTax]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[OrderTax] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[OrderTax]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[OrderTax]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixCreateddate] on [dbo].[Email]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 20953  RATIO: 20953.00  SIZE: 151.89 MB
                        SELECT    @cEEvent       = '[ixCreateddate] on [dbo].[Email]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixCreateddate] ON [dbo].[Email] (  dtCreated ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixCreateddate] on [dbo].[Email]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixCreateddate] ON [dbo].[Email]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[Email]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 22343  RATIO: 22343.00  SIZE: 145.46 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[Email]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[Email] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[Email]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[Email]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ix3] on [dbo].[IndividualCommissionData]',-1,-1) WITH NOWAIT
  --  READS: 1  WRITES: 38216  RATIO: 38216.00  SIZE: 144.09 MB
                        SELECT    @cEEvent       = '[ix3] on [dbo].[IndividualCommissionData]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ix3] ON [dbo].[IndividualCommissionData] (  CommissionStatusID ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ix3] on [dbo].[IndividualCommissionData]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ix3] ON [dbo].[IndividualCommissionData]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [IX_IndividualID_SiteID_IsActive_ExpDate] on [dbo].[WebNotes]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 17325  RATIO: 17325.00  SIZE: 126.05 MB
                        SELECT    @cEEvent       = '[IX_IndividualID_SiteID_IsActive_ExpDate] on [dbo].[WebNotes]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [IX_IndividualID_SiteID_IsActive_ExpDate] ON [dbo].[WebNotes] (  SiteID ASC  , IndividualID ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[IX_IndividualID_SiteID_IsActive_ExpDate] on [dbo].[WebNotes]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [IX_IndividualID_SiteID_IsActive_ExpDate] ON [dbo].[WebNotes]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [CreditCardNumber_ndx] on [dbo].[CreditCard]',-1,-1) WITH NOWAIT
  --  READS: 3  WRITES: 13864  RATIO: 4621.33  SIZE: 111.82 MB
                        SELECT    @cEEvent       = '[CreditCardNumber_ndx] on [dbo].[CreditCard]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [CreditCardNumber_ndx] ON [dbo].[CreditCard] (  vchCcNumber ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[CreditCardNumber_ndx] on [dbo].[CreditCard]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [CreditCardNumber_ndx] ON [dbo].[CreditCard]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [CompanyShipTo_ndx] on [dbo].[Company]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 4107  RATIO: 4107.00  SIZE: 100.10 MB
                        SELECT    @cEEvent       = '[CompanyShipTo_ndx] on [dbo].[Company]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [CompanyShipTo_ndx] ON [dbo].[Company] (  iPrimShipToAddressID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[CompanyShipTo_ndx] on [dbo].[Company]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [CompanyShipTo_ndx] ON [dbo].[Company]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixCreateddate] on [dbo].[Company]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 3531  RATIO: 3531.00  SIZE: 87.10 MB
                        SELECT    @cEEvent       = '[ixCreateddate] on [dbo].[Company]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixCreateddate] ON [dbo].[Company] (  dtCreated ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixCreateddate] on [dbo].[Company]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixCreateddate] ON [dbo].[Company]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[OrderDetailCustomAttribute]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 32592  RATIO: 32592.00  SIZE: 83.97 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[OrderDetailCustomAttribute]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[OrderDetailCustomAttribute] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[OrderDetailCustomAttribute]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[OrderDetailCustomAttribute]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [CompanyBillTo_ndx] on [dbo].[Company]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 6939  RATIO: 6939.00  SIZE: 77.63 MB
                        SELECT    @cEEvent       = '[CompanyBillTo_ndx] on [dbo].[Company]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [CompanyBillTo_ndx] ON [dbo].[Company] (  iPrimBillToAddressID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[CompanyBillTo_ndx] on [dbo].[Company]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [CompanyBillTo_ndx] ON [dbo].[Company]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [IX_Company_iType] on [dbo].[Company]',-1,-1) WITH NOWAIT
  --  READS: 568  WRITES: 7154  RATIO: 12.60  SIZE: 77.20 MB
                        SELECT    @cEEvent       = '[IX_Company_iType] on [dbo].[Company]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [IX_Company_iType] ON [dbo].[Company] (  iTypeID ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[IX_Company_iType] on [dbo].[Company]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [IX_Company_iType] ON [dbo].[Company]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [CompanyMailTo_ndx] on [dbo].[Company]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 6739  RATIO: 6739.00  SIZE: 76.32 MB
                        SELECT    @cEEvent       = '[CompanyMailTo_ndx] on [dbo].[Company]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [CompanyMailTo_ndx] ON [dbo].[Company] (  iPrimMailToAddressID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[CompanyMailTo_ndx] on [dbo].[Company]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [CompanyMailTo_ndx] ON [dbo].[Company]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixCompanyMailToAddress] on [dbo].[Company]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 6739  RATIO: 6739.00  SIZE: 76.31 MB
                        SELECT    @cEEvent       = '[ixCompanyMailToAddress] on [dbo].[Company]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixCompanyMailToAddress] ON [dbo].[Company] (  iPrimMailToAddressID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixCompanyMailToAddress] on [dbo].[Company]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixCompanyMailToAddress] ON [dbo].[Company]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[CompanySCIUserRel]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 2790  RATIO: 2790.00  SIZE: 73.91 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[CompanySCIUserRel]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[CompanySCIUserRel] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[CompanySCIUserRel]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[CompanySCIUserRel]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ContactName_ndx] on [dbo].[Contact]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 10299  RATIO: 10299.00  SIZE: 65.70 MB
                        SELECT    @cEEvent       = '[ContactName_ndx] on [dbo].[Contact]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ContactName_ndx] ON [dbo].[Contact] (  vchName ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ContactName_ndx] on [dbo].[Contact]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ContactName_ndx] ON [dbo].[Contact]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[CreditCard]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 13864  RATIO: 13864.00  SIZE: 65.64 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[CreditCard]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[CreditCard] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[CreditCard]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[CreditCard]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[Contact]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 10299  RATIO: 10299.00  SIZE: 63.99 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[Contact]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[Contact] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[Contact]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[Contact]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[AuxDelivery]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 2171  RATIO: 2171.00  SIZE: 59.05 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[AuxDelivery]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[AuxDelivery] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[AuxDelivery]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[AuxDelivery]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ix2] on [dbo].[CompanyCommissionData]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 3142  RATIO: 3142.00  SIZE: 46.91 MB
                        SELECT    @cEEvent       = '[ix2] on [dbo].[CompanyCommissionData]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ix2] ON [dbo].[CompanyCommissionData] (  LastPurchaseDate ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ix2] on [dbo].[CompanyCommissionData]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ix2] ON [dbo].[CompanyCommissionData]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[EasyAccessDetail]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 27648  RATIO: 27648.00  SIZE: 39.96 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[EasyAccessDetail]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[EasyAccessDetail] (  ModifiedDate ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[EasyAccessDetail]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[EasyAccessDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[CompanyPreference]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 6517  RATIO: 6517.00  SIZE: 39.38 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[CompanyPreference]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[CompanyPreference] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[CompanyPreference]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[CompanyPreference]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[CompanyIndividualRel]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 7736  RATIO: 7736.00  SIZE: 36.84 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[CompanyIndividualRel]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[CompanyIndividualRel] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[CompanyIndividualRel]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[CompanyIndividualRel]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[Quote]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 24220  RATIO: 24220.00  SIZE: 34.25 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[Quote]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[Quote] (  ModifiedDate ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[Quote]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[Quote]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[EasyAccessDetailInfo]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 21108  RATIO: 21108.00  SIZE: 33.63 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[EasyAccessDetailInfo]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[EasyAccessDetailInfo] (  ModifiedDate ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[EasyAccessDetailInfo]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[EasyAccessDetailInfo]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [IX_SubscriptionBillingHistory_Cover1] on [Subscription].[SubscriptionBillingHistory]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 18478  RATIO: 18478.00  SIZE: 30.66 MB
                        SELECT    @cEEvent       = '[IX_SubscriptionBillingHistory_Cover1] on [Subscription].[SubscriptionBillingHistory]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [IX_SubscriptionBillingHistory_Cover1] ON [Subscription].[SubscriptionBillingHistory] (  SubscriptionBillingStatusID ASC  , SubscriptionBillingErrorID ASC  , BillingDate ASC  )   INCLUDE ( OrderID )  WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[IX_SubscriptionBillingHistory_Cover1] on [Subscription].[SubscriptionBillingHistory]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [IX_SubscriptionBillingHistory_Cover1] ON [Subscription].[SubscriptionBillingHistory]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [IX_CartLogAnonymous_CreatedDate] on [dbo].[CartLogAnonymous]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 227895  RATIO: 227895.00  SIZE: 25.49 MB
                        SELECT    @cEEvent       = '[IX_CartLogAnonymous_CreatedDate] on [dbo].[CartLogAnonymous]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [IX_CartLogAnonymous_CreatedDate] ON [dbo].[CartLogAnonymous] (  CreatedDate ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[IX_CartLogAnonymous_CreatedDate] on [dbo].[CartLogAnonymous]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [IX_CartLogAnonymous_CreatedDate] ON [dbo].[CartLogAnonymous]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ContactEmail_ndx] on [dbo].[Contact]',-1,-1) WITH NOWAIT
  --  READS: 7  WRITES: 10299  RATIO: 1471.29  SIZE: 25.12 MB
                        SELECT    @cEEvent       = '[ContactEmail_ndx] on [dbo].[Contact]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ContactEmail_ndx] ON [dbo].[Contact] (  vchEmailAddress ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ContactEmail_ndx] on [dbo].[Contact]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ContactEmail_ndx] ON [dbo].[Contact]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ix1] on [dbo].[CompanyCommissionData]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 3142  RATIO: 3142.00  SIZE: 24.05 MB
                        SELECT    @cEEvent       = '[ix1] on [dbo].[CompanyCommissionData]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ix1] ON [dbo].[CompanyCommissionData] (  FirstPurchaseDate ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ix1] on [dbo].[CompanyCommissionData]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ix1] ON [dbo].[CompanyCommissionData]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ix4] on [dbo].[CompanyCommissionData]',-1,-1) WITH NOWAIT
  --  READS: 17  WRITES: 3244  RATIO: 190.82  SIZE: 22.63 MB
                        SELECT    @cEEvent       = '[ix4] on [dbo].[CompanyCommissionData]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ix4] ON [dbo].[CompanyCommissionData] (  CommissionCalculationDate ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ix4] on [dbo].[CompanyCommissionData]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ix4] ON [dbo].[CompanyCommissionData]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ix5] on [dbo].[CompanyCommissionData]',-1,-1) WITH NOWAIT
  --  READS: 34  WRITES: 3132  RATIO: 92.12  SIZE: 21.07 MB
                        SELECT    @cEEvent       = '[ix5] on [dbo].[CompanyCommissionData]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ix5] ON [dbo].[CompanyCommissionData] (  OverrideExpiry ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ix5] on [dbo].[CompanyCommissionData]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ix5] ON [dbo].[CompanyCommissionData]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ix3] on [dbo].[CompanyCommissionData]',-1,-1) WITH NOWAIT
  --  READS: 2  WRITES: 3251  RATIO: 1625.50  SIZE: 17.84 MB
                        SELECT    @cEEvent       = '[ix3] on [dbo].[CompanyCommissionData]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ix3] ON [dbo].[CompanyCommissionData] (  CommissionStatusID ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ix3] on [dbo].[CompanyCommissionData]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ix3] ON [dbo].[CompanyCommissionData]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [IndividualLicensePreference_IndividualID_Ndx] on [dbo].[IndividualLicensePreference]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 484  RATIO: 484.00  SIZE: 13.68 MB
                        SELECT    @cEEvent       = '[IndividualLicensePreference_IndividualID_Ndx] on [dbo].[IndividualLicensePreference]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [IndividualLicensePreference_IndividualID_Ndx] ON [dbo].[IndividualLicensePreference] (  iIndividualID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[IndividualLicensePreference_IndividualID_Ndx] on [dbo].[IndividualLicensePreference]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [IndividualLicensePreference_IndividualID_Ndx] ON [dbo].[IndividualLicensePreference]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[CartDetailCustomAttribute]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 2334213  RATIO: 2334213.00  SIZE: 13.15 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[CartDetailCustomAttribute]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[CartDetailCustomAttribute] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[CartDetailCustomAttribute]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[CartDetailCustomAttribute]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[IndividualLicensePreference]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 533  RATIO: 533.00  SIZE: 12.35 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[IndividualLicensePreference]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[IndividualLicensePreference] (  DateModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[IndividualLicensePreference]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[IndividualLicensePreference]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[AgreementSubDetail]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 5912  RATIO: 5912.00  SIZE: 11.95 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[AgreementSubDetail]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[AgreementSubDetail] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[AgreementSubDetail]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[AgreementSubDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[CartTax]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 147271  RATIO: 147271.00  SIZE: 10.26 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[CartTax]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[CartTax] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[CartTax]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[CartTax]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [NCIX_Individual] on [Subscription].[SubscriptionSeat]',-1,-1) WITH NOWAIT
  --  READS: 90  WRITES: 6508  RATIO: 72.31  SIZE: 10.03 MB
                        SELECT    @cEEvent       = '[NCIX_Individual] on [Subscription].[SubscriptionSeat]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [NCIX_Individual] ON [Subscription].[SubscriptionSeat] (  IndividualID ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[NCIX_Individual] on [Subscription].[SubscriptionSeat]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [NCIX_Individual] ON [Subscription].[SubscriptionSeat]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[DownloadDetailNote]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 11139427  RATIO: 11139427.00  SIZE: 9.08 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[DownloadDetailNote]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[DownloadDetailNote] (  ModifiedDateTime ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[DownloadDetailNote]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[DownloadDetailNote]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ix1] on [dbo].[CommissionInheritanceSnapshot]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 17  RATIO: 17.00  SIZE: 8.72 MB
                        SELECT    @cEEvent       = '[ix1] on [dbo].[CommissionInheritanceSnapshot]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ix1] ON [dbo].[CommissionInheritanceSnapshot] (  CommissionStatusID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ix1] on [dbo].[CommissionInheritanceSnapshot]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ix1] ON [dbo].[CommissionInheritanceSnapshot]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [IX_IndividualSecuritySnapshot] on [dbo].[IndividualSecuritySnapshot]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 6135  RATIO: 6135.00  SIZE: 6.69 MB
                        SELECT    @cEEvent       = '[IX_IndividualSecuritySnapshot] on [dbo].[IndividualSecuritySnapshot]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [IX_IndividualSecuritySnapshot] ON [dbo].[IndividualSecuritySnapshot] (  IndividualID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[IX_IndividualSecuritySnapshot] on [dbo].[IndividualSecuritySnapshot]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [IX_IndividualSecuritySnapshot] ON [dbo].[IndividualSecuritySnapshot]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ix1] on [dbo].[IndividualCommissionAudit]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 51  RATIO: 51.00  SIZE: 6.38 MB
                        SELECT    @cEEvent       = '[ix1] on [dbo].[IndividualCommissionAudit]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ix1] ON [dbo].[IndividualCommissionAudit] (  IndividualId ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ix1] on [dbo].[IndividualCommissionAudit]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ix1] ON [dbo].[IndividualCommissionAudit]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[IndividualNotes]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 96  RATIO: 96.00  SIZE: 6.33 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[IndividualNotes]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[IndividualNotes] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[IndividualNotes]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[IndividualNotes]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ix3] on [dbo].[IndividualSecurityView]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 5984  RATIO: 5984.00  SIZE: 6.11 MB
                        SELECT    @cEEvent       = '[ix3] on [dbo].[IndividualSecurityView]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ix3] ON [dbo].[IndividualSecurityView] (  DateCreated ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ix3] on [dbo].[IndividualSecurityView]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ix3] ON [dbo].[IndividualSecurityView]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [IDX_CompanyInfoAudit_ColumnName] on [dbo].[CompanyInfoAudit]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 1097  RATIO: 1097.00  SIZE: 5.26 MB
                        SELECT    @cEEvent       = '[IDX_CompanyInfoAudit_ColumnName] on [dbo].[CompanyInfoAudit]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [IDX_CompanyInfoAudit_ColumnName] ON [dbo].[CompanyInfoAudit] (  ColumnName ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[IDX_CompanyInfoAudit_ColumnName] on [dbo].[CompanyInfoAudit]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [IDX_CompanyInfoAudit_ColumnName] ON [dbo].[CompanyInfoAudit]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [NCIX_Subscription_Status_SubType] on [Subscription].[Subscription]',-1,-1) WITH NOWAIT
  --  READS: 40768  WRITES: 57417425  RATIO: 1408.39  SIZE: 5.22 MB
                        SELECT    @cEEvent       = '[NCIX_Subscription_Status_SubType] on [Subscription].[Subscription]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [NCIX_Subscription_Status_SubType] ON [Subscription].[Subscription] (  SubscriptionID ASC  , StatusID ASC  , SubscriptionTypeID ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[NCIX_Subscription_Status_SubType] on [Subscription].[Subscription]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [NCIX_Subscription_Status_SubType] ON [Subscription].[Subscription]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [IndividualNotes_iSCIUserID_Ndx] on [dbo].[IndividualNotes]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 96  RATIO: 96.00  SIZE: 4.91 MB
                        SELECT    @cEEvent       = '[IndividualNotes_iSCIUserID_Ndx] on [dbo].[IndividualNotes]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [IndividualNotes_iSCIUserID_Ndx] ON [dbo].[IndividualNotes] (  iSCIUserId ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[IndividualNotes_iSCIUserID_Ndx] on [dbo].[IndividualNotes]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [IndividualNotes_iSCIUserID_Ndx] ON [dbo].[IndividualNotes]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ix2] on [dbo].[IndividualSecurityView]',-1,-1) WITH NOWAIT
  --  READS: 129  WRITES: 5984  RATIO: 46.39  SIZE: 4.39 MB
                        SELECT    @cEEvent       = '[ix2] on [dbo].[IndividualSecurityView]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ix2] ON [dbo].[IndividualSecurityView] (  AccessedByID ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ix2] on [dbo].[IndividualSecurityView]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ix2] ON [dbo].[IndividualSecurityView]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[AgreementDetail]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 1543  RATIO: 1543.00  SIZE: 3.77 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[AgreementDetail]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[AgreementDetail] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[AgreementDetail]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[AgreementDetail]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [FlickrImageRequestModifiedDate_ndx] on [Flickr].[FlickrImageRequest]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 25893  RATIO: 25893.00  SIZE: 3.01 MB
                        SELECT    @cEEvent       = '[FlickrImageRequestModifiedDate_ndx] on [Flickr].[FlickrImageRequest]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [FlickrImageRequestModifiedDate_ndx] ON [Flickr].[FlickrImageRequest] (  ModifiedDate ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[FlickrImageRequestModifiedDate_ndx] on [Flickr].[FlickrImageRequest]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [FlickrImageRequestModifiedDate_ndx] ON [Flickr].[FlickrImageRequest]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[AgreementDetailUseCategory]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 753  RATIO: 753.00  SIZE: 1.37 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[AgreementDetailUseCategory]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[AgreementDetailUseCategory] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[AgreementDetailUseCategory]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[AgreementDetailUseCategory]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[Agreement]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 429  RATIO: 429.00  SIZE: 1.19 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[Agreement]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[Agreement] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[Agreement]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[Agreement]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[CompanyNotes]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 26  RATIO: 26.00  SIZE: 1.02 MB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[CompanyNotes]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[CompanyNotes] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[CompanyNotes]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[CompanyNotes]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [FlickrImageRequestCheckedOutDate_ndx] on [Flickr].[FlickrImageRequest]',-1,-1) WITH NOWAIT
  --  READS: 598  WRITES: 25893  RATIO: 43.30  SIZE: 936.00 KB
                        SELECT    @cEEvent       = '[FlickrImageRequestCheckedOutDate_ndx] on [Flickr].[FlickrImageRequest]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [FlickrImageRequestCheckedOutDate_ndx] ON [Flickr].[FlickrImageRequest] (  CheckedOutDate ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[FlickrImageRequestCheckedOutDate_ndx] on [Flickr].[FlickrImageRequest]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [FlickrImageRequestCheckedOutDate_ndx] ON [Flickr].[FlickrImageRequest]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [FlickrImageRequestExpirationDate_ndx] on [Flickr].[FlickrImageRequest]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 80  RATIO: 80.00  SIZE: 832.00 KB
                        SELECT    @cEEvent       = '[FlickrImageRequestExpirationDate_ndx] on [Flickr].[FlickrImageRequest]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [FlickrImageRequestExpirationDate_ndx] ON [Flickr].[FlickrImageRequest] (  ExpirationDate ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[FlickrImageRequestExpirationDate_ndx] on [Flickr].[FlickrImageRequest]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [FlickrImageRequestExpirationDate_ndx] ON [Flickr].[FlickrImageRequest]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[EasyAccessHeader]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 3659  RATIO: 3659.00  SIZE: 832.00 KB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[EasyAccessHeader]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[EasyAccessHeader] (  ModifiedDate ASC  )   WITH (  PAD_INDEX = ON ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[EasyAccessHeader]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[EasyAccessHeader]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [CompanyNotes_iSCIUserID_Ndx] on [dbo].[CompanyNotes]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 26  RATIO: 26.00  SIZE: 824.00 KB
                        SELECT    @cEEvent       = '[CompanyNotes_iSCIUserID_Ndx] on [dbo].[CompanyNotes]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [CompanyNotes_iSCIUserID_Ndx] ON [dbo].[CompanyNotes] (  iSCIUserId ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[CompanyNotes_iSCIUserID_Ndx] on [dbo].[CompanyNotes]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [CompanyNotes_iSCIUserID_Ndx] ON [dbo].[CompanyNotes]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[SubscriptionDetailTax]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 750  RATIO: 750.00  SIZE: 752.00 KB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[SubscriptionDetailTax]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[SubscriptionDetailTax] (  Modified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[SubscriptionDetailTax]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[SubscriptionDetailTax]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ix1] on [dbo].[CompanyCommissionAudit]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 41  RATIO: 41.00  SIZE: 616.00 KB
                        SELECT    @cEEvent       = '[ix1] on [dbo].[CompanyCommissionAudit]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ix1] ON [dbo].[CompanyCommissionAudit] (  CompanyId ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ix1] on [dbo].[CompanyCommissionAudit]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ix1] ON [dbo].[CompanyCommissionAudit]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [FlickrImageRequestCurrentStatusID_ndx] on [Flickr].[FlickrImageRequest]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 80  RATIO: 80.00  SIZE: 608.00 KB
                        SELECT    @cEEvent       = '[FlickrImageRequestCurrentStatusID_ndx] on [Flickr].[FlickrImageRequest]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [FlickrImageRequestCurrentStatusID_ndx] ON [Flickr].[FlickrImageRequest] (  CurrentStatusID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[FlickrImageRequestCurrentStatusID_ndx] on [Flickr].[FlickrImageRequest]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [FlickrImageRequestCurrentStatusID_ndx] ON [Flickr].[FlickrImageRequest]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [CompanyAssociation_CompanyIDAssociated_Ndx] on [dbo].[CompanyAssociation]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 22  RATIO: 22.00  SIZE: 592.00 KB
                        SELECT    @cEEvent       = '[CompanyAssociation_CompanyIDAssociated_Ndx] on [dbo].[CompanyAssociation]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [CompanyAssociation_CompanyIDAssociated_Ndx] ON [dbo].[CompanyAssociation] (  CompanyIDAssociated ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[CompanyAssociation_CompanyIDAssociated_Ndx] on [dbo].[CompanyAssociation]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [CompanyAssociation_CompanyIDAssociated_Ndx] ON [dbo].[CompanyAssociation]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[CompanyAssociation]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 22  RATIO: 22.00  SIZE: 584.00 KB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[CompanyAssociation]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[CompanyAssociation] (  ModifiedDateTime ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[CompanyAssociation]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[CompanyAssociation]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [idx_sagree_01] on [dbo].[SubscriptionAgreement]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 603  RATIO: 603.00  SIZE: 336.00 KB
                        SELECT    @cEEvent       = '[idx_sagree_01] on [dbo].[SubscriptionAgreement]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [idx_sagree_01] ON [dbo].[SubscriptionAgreement] (  BillingUserName ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[idx_sagree_01] on [dbo].[SubscriptionAgreement]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [idx_sagree_01] ON [dbo].[SubscriptionAgreement]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[ProfileIndividualRel]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 63  RATIO: 63.00  SIZE: 264.00 KB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[ProfileIndividualRel]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[ProfileIndividualRel] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[ProfileIndividualRel]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[ProfileIndividualRel]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [Subscription_BillingUserID_Ndx] on [dbo].[Subscription]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 217  RATIO: 217.00  SIZE: 192.00 KB
                        SELECT    @cEEvent       = '[Subscription_BillingUserID_Ndx] on [dbo].[Subscription]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [Subscription_BillingUserID_Ndx] ON [dbo].[Subscription] (  BillingUserID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[Subscription_BillingUserID_Ndx] on [dbo].[Subscription]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [Subscription_BillingUserID_Ndx] ON [dbo].[Subscription]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [NCIX_MediaType] on [dbo].[Bundle]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 13  RATIO: 13.00  SIZE: 128.00 KB
                        SELECT    @cEEvent       = '[NCIX_MediaType] on [dbo].[Bundle]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [NCIX_MediaType] ON [dbo].[Bundle] (  EnabledFlag ASC  , BundleId ASC  , MediaType ASC  )   INCLUDE ( BundleName , IsRestricted , WhollyOwnedBundleId )  WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[NCIX_MediaType] on [dbo].[Bundle]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [NCIX_MediaType] ON [dbo].[Bundle]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ix_CompensationRoleMap_iBrandID] on [dbo].[CompensationRoleMap]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 31  RATIO: 31.00  SIZE: 120.00 KB
                        SELECT    @cEEvent       = '[ix_CompensationRoleMap_iBrandID] on [dbo].[CompensationRoleMap]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ix_CompensationRoleMap_iBrandID] ON [dbo].[CompensationRoleMap] (  iBrandID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ix_CompensationRoleMap_iBrandID] on [dbo].[CompensationRoleMap]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ix_CompensationRoleMap_iBrandID] ON [dbo].[CompensationRoleMap]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ix_CompensationRoleMap_iTypeID] on [dbo].[CompensationRoleMap]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 31  RATIO: 31.00  SIZE: 96.00 KB
                        SELECT    @cEEvent       = '[ix_CompensationRoleMap_iTypeID] on [dbo].[CompensationRoleMap]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ix_CompensationRoleMap_iTypeID] ON [dbo].[CompensationRoleMap] (  iTypeID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ix_CompensationRoleMap_iTypeID] on [dbo].[CompensationRoleMap]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ix_CompensationRoleMap_iTypeID] ON [dbo].[CompensationRoleMap]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ix_CompensationRoleMap_iCompensationRoleID] on [dbo].[CompensationRoleMap]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 31  RATIO: 31.00  SIZE: 96.00 KB
                        SELECT    @cEEvent       = '[ix_CompensationRoleMap_iCompensationRoleID] on [dbo].[CompensationRoleMap]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ix_CompensationRoleMap_iCompensationRoleID] ON [dbo].[CompensationRoleMap] (  iCompensationRoleID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ix_CompensationRoleMap_iCompensationRoleID] on [dbo].[CompensationRoleMap]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ix_CompensationRoleMap_iCompensationRoleID] ON [dbo].[CompensationRoleMap]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [OrderDetail_imp_iBatchId] on [dbo].[OrderDetail_imp]',-1,-1) WITH NOWAIT
  --  READS: 1290  WRITES: 17267  RATIO: 13.39  SIZE: 88.00 KB
                        SELECT    @cEEvent       = '[OrderDetail_imp_iBatchId] on [dbo].[OrderDetail_imp]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [OrderDetail_imp_iBatchId] ON [dbo].[OrderDetail_imp] (  iBatchID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[OrderDetail_imp_iBatchId] on [dbo].[OrderDetail_imp]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [OrderDetail_imp_iBatchId] ON [dbo].[OrderDetail_imp]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [SystemError_Lookup1] on [dbo].[SystemError]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 1  RATIO: 1.00  SIZE: 88.00 KB
                        SELECT    @cEEvent       = '[SystemError_Lookup1] on [dbo].[SystemError]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [SystemError_Lookup1] ON [dbo].[SystemError] (  iSQLErrorID ASC  , iAppErrorID ASC  , vchErrorMessage ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[SystemError_Lookup1] on [dbo].[SystemError]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [SystemError_Lookup1] ON [dbo].[SystemError]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[OriginalSystem]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 133  RATIO: 133.00  SIZE: 72.00 KB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[OriginalSystem]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[OriginalSystem] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[OriginalSystem]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[OriginalSystem]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[PortfolioCollection]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 19  RATIO: 19.00  SIZE: 56.00 KB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[PortfolioCollection]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[PortfolioCollection] (  ModifiedDate ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[PortfolioCollection]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[PortfolioCollection]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[AgentOperationalUnitRel]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 12  RATIO: 12.00  SIZE: 40.00 KB
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[AgentOperationalUnitRel]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[AgentOperationalUnitRel] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[AgentOperationalUnitRel]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[AgentOperationalUnitRel]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [MediaRoomAssetRoomID_ndx] on [dbo].[MediaRoomAsset]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 5818  RATIO: 5818.00  SIZE: 0.00 Bytes
                        SELECT    @cEEvent       = '[MediaRoomAssetRoomID_ndx] on [dbo].[MediaRoomAsset]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [MediaRoomAssetRoomID_ndx] ON [dbo].[MediaRoomAsset] (  iMediaRoomID ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[MediaRoomAssetRoomID_ndx] on [dbo].[MediaRoomAsset]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [MediaRoomAssetRoomID_ndx] ON [dbo].[MediaRoomAsset]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
RAISERROR('Dropping Index [ixmodifieddate] on [dbo].[MediaRoomAsset]',-1,-1) WITH NOWAIT
  --  READS: 0  WRITES: 5818  RATIO: 5818.00  SIZE: 0.00 Bytes
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[MediaRoomAsset]'
                                  ,@cECategory   = 'DROP INDEX RECOVERY SCRIPT'
                                  ,@cEMessage    = ' CREATE NONCLUSTERED INDEX [ixmodifieddate] ON [dbo].[MediaRoomAsset] (  dtModified ASC  )   WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , DROP_EXISTING = ON , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  ) ON [PRIMARY ] '
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
                        SELECT    @cEEvent       = '[ixmodifieddate] on [dbo].[MediaRoomAsset]'
                                  ,@cECategory   = 'DROP UNUSED INDEX'
                                  ,@cEMessage    = 'Starting'
                                  ,@StartDate    = GETDATE()
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEMethod_TableLocal = 1
 
  DROP INDEX [ixmodifieddate] ON [dbo].[MediaRoomAsset]
 
                        SELECT    @cEMessage        = 'Done'
                                  ,@StopDate         = getdate()
                                  ,@cEStat_Duration  = DATEDIFF(ss,@StartDate,@StopDate) / 60.0000
 
                        exec [dbaadmin].[dbo].[dbasp_LogEvent]
                                  @cEModule
                                  ,@cECategory
                                  ,@cEEvent
                                  ,@cEGUID
                                  ,@cEMessage
                                  ,@cEStat_Duration = @cEStat_Duration
                                  ,@cEMethod_TableLocal = 1
 
 
 
 --    TOTAL SPACE SAVED BY DROPPING UNUSED INDEXES:  191.24 GB
