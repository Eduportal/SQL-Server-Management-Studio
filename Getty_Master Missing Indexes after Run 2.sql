 
  --  MAXDOP setting will be : 5
 
USE [Getty_Master]
 
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
 
	SELECT	@cEModule		= 'Missing & Unused Index Tuneing for [Getty_Master]'
		,@cEGUID		= NEWID()
 
	PRINT	'  -- LOGGED RESULTS CAN BE RETRIEVED WITH:'
	PRINT	'  -- SELECT  * FROM [dbaadmin].[dbo].[EventLog] where cEGUID = '''+CAST(@cEGUID AS VarChar(50))+''''
 
 
 
/* 001 - 0029659630 */  RAISERROR('Updateing Statistics ON [x_deal_calc_result]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[x_deal_calc_result]'
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
 
                        UPDATE STATISTICS [dbo].[x_deal_calc_result]
 
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
 
                        RAISERROR('Creating Index [AMIX_x_deal_calc_result_ABDAC] on [x_deal_calc_result]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.56
 
                        SELECT    @cEEvent       = 'AMIX_x_deal_calc_result_ABDAC on [dbo].[x_deal_calc_result]'
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
 
                        CREATE NONCLUSTERED INDEX AMIX_x_deal_calc_result_ABDAC on [dbo].[x_deal_calc_result]([deal_sid], [period_sid], [udkey_3_sid],[udkey_2_sid]) WITH(MAXDOP=5,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
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
 
 
/* 002 - 0006423112 */  RAISERROR('Updateing Statistics ON [x_job_queue]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[x_job_queue]'
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
 
                        UPDATE STATISTICS [dbo].[x_job_queue]
 
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
 
                        RAISERROR('Creating Index [AMIX_x_job_queue_202F7] on [x_job_queue]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.43
 
                        SELECT    @cEEvent       = 'AMIX_x_job_queue_202F7 on [dbo].[x_job_queue]'
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
 
                        CREATE NONCLUSTERED INDEX AMIX_x_job_queue_202F7 on [dbo].[x_job_queue]([job_priority], [batch_process_sid], [start_relative_to_period_sid], [processing_type_sid],[status_sid]) WITH(MAXDOP=5,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
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
 
 
/* 003 - 0000341938 */  RAISERROR('Updateing Statistics ON [c_logical_field_terminology_locale]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[c_logical_field_terminology_locale]'
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
 
                        UPDATE STATISTICS [dbo].[c_logical_field_terminology_locale]
 
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
 
                        RAISERROR('Creating Index [AMIX_c_logical_field_terminology_locale_B0CA8] on [c_logical_field_terminology_locale]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_c_logical_field_terminology_locale_B0CA8 on [dbo].[c_logical_field_terminology_locale]'
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
 
                        CREATE NONCLUSTERED INDEX AMIX_c_logical_field_terminology_locale_B0CA8 on [dbo].[c_logical_field_terminology_locale]([locale_sid]) Include ([logical_field_sid], [name], [label_singular], [label_plural]) WITH(MAXDOP=5,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
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
 
 
/* 004 - 0000132935 */  RAISERROR('Updateing Statistics ON [x_contract_udf_lookup]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[x_contract_udf_lookup]'
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
 
                        UPDATE STATISTICS [dbo].[x_contract_udf_lookup]
 
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
 
                        RAISERROR('Creating Index [AMIX_x_contract_udf_lookup_20D9B] on [x_contract_udf_lookup]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_x_contract_udf_lookup_20D9B on [dbo].[x_contract_udf_lookup]'
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
 
                        CREATE NONCLUSTERED INDEX AMIX_x_contract_udf_lookup_20D9B on [dbo].[x_contract_udf_lookup]([sql_resolved_flag],[contract_sid]) WITH(MAXDOP=5,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
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
 
 
/* 005 - 0000035174 */  RAISERROR('Updateing Statistics ON [c_contact]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[c_contact]'
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
 
                        UPDATE STATISTICS [dbo].[c_contact]
 
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
 
                        RAISERROR('Creating Index [AMIX_c_contact_40973] on [c_contact]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_c_contact_40973 on [dbo].[c_contact]'
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
 
                        CREATE NONCLUSTERED INDEX AMIX_c_contact_40973 on [dbo].[c_contact]([alliant_user_sid]) WITH(MAXDOP=5,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
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
 
 
/* 006 - 0000034112 */  RAISERROR('Updateing Statistics ON [x_posted_period]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[x_posted_period]'
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
 
                        UPDATE STATISTICS [dbo].[x_posted_period]
 
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
 
                        RAISERROR('Creating Index [AMIX_x_posted_period_6F049] on [x_posted_period]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_x_posted_period_6F049 on [dbo].[x_posted_period]'
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
 
                        CREATE NONCLUSTERED INDEX AMIX_x_posted_period_6F049 on [dbo].[x_posted_period]([udkey_1_sid],[period_sid]) Include ([row_identity], [start_user_date], [end_user_date], [udkey_2_sid], [udkey_3_sid], [udkey_4_sid], [udkey_5_sid], [udkey_6_sid], [udkey_7_sid], [udkey_8_sid], [udkey_9_sid], [udkey_10_sid], [udkey_11_sid], [udkey_12_sid], [udkey_13_sid], [udkey_14_sid], [udkey_15_sid], [udkey_16_sid], [udkey_17_sid], [udkey_18_sid], [udkey_19_sid], [udkey_20_sid], [user_contact_sid], [user_contact_2_sid], [user_contact_3_sid], [user_contact_4_sid], [price_point], [alt_price_point], [user_rate], [user_2_rate], [user_3_rate], [actual_period_sid], [other_period_sid], [amount], [alt_amount], [qty], [alt_qty], [user_comment], [alt_user_comment]) WITH(MAXDOP=5,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
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
 
 
/* 007 - 0000003541 */  RAISERROR('Updateing Statistics ON [c_entity]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[c_entity]'
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
 
                        UPDATE STATISTICS [dbo].[c_entity]
 
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
 
                        RAISERROR('Creating Index [AMIX_c_entity_70807] on [c_entity]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_c_entity_70807 on [dbo].[c_entity]'
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
 
                        CREATE NONCLUSTERED INDEX AMIX_c_entity_70807 on [dbo].[c_entity]([system_layer_table_flag], [allow_auto_delete_data_flag]) WITH(MAXDOP=5,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
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
 
 
/* 008 - 0000002733 */  RAISERROR('Updateing Statistics ON [x_contract_in_use]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[x_contract_in_use]'
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
 
                        UPDATE STATISTICS [dbo].[x_contract_in_use]
 
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
 
                        RAISERROR('Creating Index [AMIX_x_contract_in_use_B4842] on [x_contract_in_use]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.63
 
                        SELECT    @cEEvent       = 'AMIX_x_contract_in_use_B4842 on [dbo].[x_contract_in_use]'
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
 
                        CREATE NONCLUSTERED INDEX AMIX_x_contract_in_use_B4842 on [dbo].[x_contract_in_use]([layer_sid],[batch_process_sid]) Include ([contract_or_group_sid], [contract_group_flag], [process_server_sid], [service_nbr]) WITH(MAXDOP=5,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
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
 
 
/* 009 - 0000001357 */  RAISERROR('Updateing Statistics ON [x_deal]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[x_deal]'
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
 
                        UPDATE STATISTICS [dbo].[x_deal]
 
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
 
                        RAISERROR('Creating Index [AMIX_x_deal_C10DC] on [x_deal]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_x_deal_C10DC on [dbo].[x_deal]'
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
 
                        CREATE NONCLUSTERED INDEX AMIX_x_deal_C10DC on [dbo].[x_deal]([deal_id]) WITH(MAXDOP=5,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
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
 
 
/* 010 - 0000001320 */  RAISERROR('Updateing Statistics ON [x_contract]',-1,-1) WITH NOWAIT
 
                        SELECT    @cEEvent       = '[dbo].[x_contract]'
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
 
                        UPDATE STATISTICS [dbo].[x_contract]
 
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
 
                        RAISERROR('Creating Index [AMIX_x_contract_673B9] on [x_contract]',-1,-1) WITH NOWAIT
                        -- Table write:read ratio: 0.00
 
                        SELECT    @cEEvent       = 'AMIX_x_contract_673B9 on [dbo].[x_contract]'
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
 
                        CREATE NONCLUSTERED INDEX AMIX_x_contract_673B9 on [dbo].[x_contract]([status_sid]) WITH(MAXDOP=5,SORT_IN_TEMPDB=ON,ONLINE=ON)
 
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
 
 
 
 
 
