---------------------------------------------------------
---------------------------------------------------------
----				[DeliveryTb]
---------------------------------------------------------
---------------------------------------------------------


--USE [DeliveryDB]
--GO

--/****** Object:  Index [PK__Delivery__626D8FCE07E124C1]    Script Date: 03/13/2012 15:55:04 ******/
--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DeliveryTb]') AND name = N'PK__Delivery__626D8FCE07E124C1')
--ALTER TABLE [dbo].[DeliveryTb] DROP CONSTRAINT [PK__Delivery__626D8FCE07E124C1]
--GO


--USE [DeliveryDB]
--GO

--/****** Object:  Index [DeliveryTb_UI_SourceId_DestinationId]    Script Date: 03/13/2012 15:57:35 ******/
--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DeliveryTb]') AND name = N'DeliveryTb_UI_SourceId_DestinationId')
--DROP INDEX [DeliveryTb_UI_SourceId_DestinationId] ON [dbo].[DeliveryTb] WITH ( ONLINE = OFF )
--GO

--USE [DeliveryDB]
--GO

--/****** Object:  Index [DeliveryTb_UI_SourceId_DestinationId]    Script Date: 03/13/2012 15:57:35 ******/
--CREATE UNIQUE CLUSTERED INDEX [IX_DeliveryTb_CLST_DestinationId_SourceId] ON [dbo].[DeliveryTb] 
--(
--	[DestinationId] ASC,
--	[SourceId] ASC
--)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
--GO


--USE [DeliveryDB]
--GO

--/****** Object:  Index [PK__Delivery__626D8FCE07E124C1]    Script Date: 03/13/2012 15:55:04 ******/
--ALTER TABLE [dbo].[DeliveryTb] ADD PRIMARY KEY NONCLUSTERED 
--(
--	[DeliveryId] ASC
--)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
--GO

--CREATE NONCLUSTERED INDEX [IX_DeliveryTb_8_10_44_14_23_56_INC_7_11_50] 
--ON [dbo].[DeliveryTb] ([SourceId], [ConfigStatusCode], [WorkerStatusCode], [ConfigMaxItemsPerBatch], [MetricCurrentQueCount], [MetricNextAttemptDate])
--INCLUDE ([DeliveryId], [ConfigPriorityBoost], [LastWorkerBatchEndDate])
--WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF
--, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, MAXDOP = 1) ON [PRIMARY]
--GO


---------------------------------------------------------
---------------------------------------------------------
----				[BatchItemTb]
---------------------------------------------------------
---------------------------------------------------------


--/****** Object:  Index [BatchItemTb_DeliveryId_MEI_ResultCode_StartDate]    Script Date: 03/13/2012 16:04:47 ******/
--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[BatchItemTb]') AND name = N'BatchItemTb_DeliveryId_MEI_ResultCode_StartDate')
--DROP INDEX [BatchItemTb_DeliveryId_MEI_ResultCode_StartDate] ON [dbo].[BatchItemTb] WITH ( ONLINE = OFF )
--GO
--USE [DeliveryDB]
--GO

--/****** Object:  Index [BatchItemTb_ItemId]    Script Date: 03/13/2012 16:05:09 ******/
--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[BatchItemTb]') AND name = N'BatchItemTb_ItemId')
--DROP INDEX [BatchItemTb_ItemId] ON [dbo].[BatchItemTb] WITH ( ONLINE = OFF )
--GO
--USE [DeliveryDB]
--GO

--/****** Object:  Index [BatchItemTb_JobId]    Script Date: 03/13/2012 16:05:18 ******/
--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[BatchItemTb]') AND name = N'BatchItemTb_JobId')
--DROP INDEX [BatchItemTb_JobId] ON [dbo].[BatchItemTb] WITH ( ONLINE = OFF )
--GO
--USE [DeliveryDB]
--GO

--/****** Object:  Index [BatchItemTb_SourceId_AssetId_AssetVersion_JobId]    Script Date: 03/13/2012 16:05:40 ******/
--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[BatchItemTb]') AND name = N'BatchItemTb_SourceId_AssetId_AssetVersion_JobId')
--DROP INDEX [BatchItemTb_SourceId_AssetId_AssetVersion_JobId] ON [dbo].[BatchItemTb] WITH ( ONLINE = OFF )
--GO
--USE [DeliveryDB]
--GO

--/****** Object:  Index [BatchItemTb_QueueId]    Script Date: 03/13/2012 16:05:57 ******/
--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[BatchItemTb]') AND name = N'BatchItemTb_QueueId')
--DROP INDEX [BatchItemTb_QueueId] ON [dbo].[BatchItemTb] WITH ( ONLINE = OFF )
--GO
--USE [DeliveryDB]
--GO

--/****** Object:  Index [BatchItemTb_SourceId_DestinationId]    Script Date: 03/13/2012 16:06:14 ******/
--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[BatchItemTb]') AND name = N'BatchItemTb_SourceId_DestinationId')
--DROP INDEX [BatchItemTb_SourceId_DestinationId] ON [dbo].[BatchItemTb] WITH ( ONLINE = OFF )
--GO
--USE [DeliveryDB]
--GO

--/****** Object:  Index [BatchItemTb_DeliveryId]    Script Date: 03/13/2012 16:06:31 ******/
--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[BatchItemTb]') AND name = N'BatchItemTb_DeliveryId')
--DROP INDEX [BatchItemTb_DeliveryId] ON [dbo].[BatchItemTb] WITH ( ONLINE = OFF )
--GO


--USE [DeliveryDB]
--GO

--/****** Object:  Index [PK__BatchIte__E2C7A1F125918339]    Script Date: 03/13/2012 16:03:57 ******/
--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[BatchItemTb]') AND name = N'PK__BatchIte__E2C7A1F125918339')
--ALTER TABLE [dbo].[BatchItemTb] DROP CONSTRAINT [PK__BatchIte__E2C7A1F125918339]
--GO
--USE [DeliveryDB]
--GO



--USE [DeliveryDB]
--GO

--/****** Object:  Index [DeliveryTb_UI_SourceId_DestinationId]    Script Date: 03/13/2012 15:57:35 ******/
--CREATE CLUSTERED INDEX [IX_BatchItemTb_CLST_DestinationId_SourceId] ON [dbo].[BatchItemTb] 
--(
--	[DestinationId] ASC,
--	[SourceId] ASC
--)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
--GO


--USE [DeliveryDB]
--GO

--/****** Object:  Index [PK__BatchIte__E2C7A1F125918339]    Script Date: 03/13/2012 16:03:57 ******/
--ALTER TABLE [dbo].[BatchItemTb] ADD PRIMARY KEY NONCLUSTERED 
--(
--	[BatchItemId] ASC
--)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
--GO


--USE [DeliveryDB]
--GO

--/****** Object:  Index [DeliveryTb_UI_SourceId_DestinationId]    Script Date: 03/13/2012 15:57:35 ******/
--CREATE NONCLUSTERED INDEX [IX_BatchItemTb_13_14_24_28] ON [dbo].[BatchItemTb] 
--([SourceId], [DestinationId], [MasterId], [SuccessF]
--)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF
--, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, MAXDOP = 1) ON [PRIMARY]
--GO


--USE [DeliveryDB]
--GO
--CREATE NONCLUSTERED INDEX [IX_BatchItemTb_DestinationId_MEI_ResultCode]
--ON [dbo].[BatchItemTb] ([DestinationId],[MEI],[ResultCode])
--INCLUDE ([AssetId],[ExternalSystem],[ExternalId])
--GO

-------------------------------------------------------------------
-------------------------------------------------------------------
---- CREATE INDEXIX_BatchItemTb_11_21_INC_1_2_3_4_9_15_16_17_25_27_30_33
-------------------------------------------------------------------
-------------------------------------------------------------------

--USE [DeliveryDB]

--IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[BatchItemTb]') AND name = N'IX_BatchItemTb_11_21_INC_1_2_3_4_9_15_16_17_25_27_30_33')
--CREATE INDEX [IX_BatchItemTb_11_21_INC_1_2_3_4_9_15_16_17_25_27_30_33] ON [dbo].[BatchItemTb]
--(
--[DeliveryId], [JobId]
--)
--INCLUDE
--(
--[BatchItemId], [BatchId], [StartDate], [QueueDate], [DeliveryAttemptCount], [ItemId], [AssetId], [AssetVersion], [EndDate], [ErrorMessage], [ResultCode], [BatchItemStartToBatchItemEndTimeMs]
--)
--WITH
--(
--SORT_IN_TEMPDB = ON
--, IGNORE_DUP_KEY = OFF
--, DROP_EXISTING = OFF
--, ONLINE = ON
--, PAD_INDEX = OFF
--, STATISTICS_NORECOMPUTE = OFF
--, ALLOW_ROW_LOCKS = ON
--, ALLOW_PAGE_LOCKS = ON
--)



---------------------------------------------------------
---------------------------------------------------------
----				[DestinationRoutingTb]
---------------------------------------------------------
---------------------------------------------------------

--USE [DeliveryDB]
--GO

--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DestinationRoutingTb]') AND name = N'DestinationRoutingTb_Ix1')
--DROP INDEX [DestinationRoutingTb_Ix1] ON [dbo].[DestinationRoutingTb] WITH ( ONLINE = OFF )
--GO

--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DestinationRoutingTb]') AND name = N'PK__Destinat__C0B787732942188C')
--ALTER TABLE [dbo].[DestinationRoutingTb] DROP CONSTRAINT [PK__Destinat__C0B787732942188C]
--GO


--CREATE UNIQUE CLUSTERED INDEX [IX_DestinationRoutingTb_RoutingId_DestinationId] ON [dbo].[DestinationRoutingTb] 
--(
--	[RoutingId] ASC,
--	[DestinationId] ASC
	
--)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
--GO

--ALTER TABLE [dbo].[DestinationRoutingTb] ADD PRIMARY KEY NONCLUSTERED 
--(
--	[DestinationRoutingId] ASC
--)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
--GO

-------------------------------------------------------------------
-------------------------------------------------------------------
---- CREATE INDEXIX_DestinationRoutingTb_2_INC_1_3_4
-------------------------------------------------------------------
-------------------------------------------------------------------

--USE [DeliveryDB]

--IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DestinationRoutingTb]') AND name = N'IX_DestinationRoutingTb_2_INC_1_3_4')
--CREATE INDEX [IX_DestinationRoutingTb_2_INC_1_3_4] ON [dbo].[DestinationRoutingTb]
--(
--[DestinationId]
--)
--INCLUDE
--(
--[DestinationRoutingId], [RoutingId], [IsSystemRouting]
--)
--WITH
--(
--SORT_IN_TEMPDB = ON
--, IGNORE_DUP_KEY = OFF
--, DROP_EXISTING = OFF
--, ONLINE = ON
--, PAD_INDEX = OFF
--, STATISTICS_NORECOMPUTE = OFF
--, ALLOW_ROW_LOCKS = ON
--, ALLOW_PAGE_LOCKS = ON
--)

-----------------------------------------------------------
-----------------------------------------------------------
------				[QueueTb]
-----------------------------------------------------------
-----------------------------------------------------------

--USE [DeliveryDB]
--GO

--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[QueueTb]') AND name = N'QueueTb_DeliveryId_StatusCode_DeliveryAttemptCount')
--DROP INDEX [QueueTb_DeliveryId_StatusCode_DeliveryAttemptCount] ON [dbo].[QueueTb] WITH ( ONLINE = OFF )
--GO

--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[QueueTb]') AND name = N'QueueTb_SourceId_DestinationId')
--DROP INDEX [QueueTb_SourceId_DestinationId] ON [dbo].[QueueTb] WITH ( ONLINE = OFF )
--GO

--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[QueueTb]') AND name = N'QueueTb_SourceId_AssetId_AssetVersion_JobId')
--DROP INDEX [QueueTb_SourceId_AssetId_AssetVersion_JobId] ON [dbo].[QueueTb] WITH ( ONLINE = OFF )
--GO

--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[QueueTb]') AND name = N'QueueTb_MasterId')
--DROP INDEX [QueueTb_MasterId] ON [dbo].[QueueTb] WITH ( ONLINE = OFF )
--GO

--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[QueueTb]') AND name = N'PK__QueueTb__8324E71546D27B73')
--ALTER TABLE [dbo].[QueueTb] DROP CONSTRAINT [PK__QueueTb__8324E71546D27B73]
--GO

--CREATE CLUSTERED INDEX [IX_QueueTb_DeliveryId_StatusCode_I_AssetSizeBytes_NextAttemptDate]
--ON [dbo].[QueueTb] ([StatusCode],[DeliveryId])
----INCLUDE ([AssetSizeBytes],[NextAttemptDate])
--GO

--ALTER TABLE [dbo].[QueueTb] ADD PRIMARY KEY NONCLUSTERED 
--(
--	[QueueId] ASC
--)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 100) ON [PRIMARY]
--GO

