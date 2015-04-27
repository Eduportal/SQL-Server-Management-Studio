 Sproc_Insert_Usage_GINS 15000, 1500000


 Select count(1) from reports_work.dbo.Temp_GINSInsertRefUSAGETable
 SELECT Top 1 1 from reports_work.dbo.Temp_GINSInsertRefUSAGETable

 Select SUM(NetExtAmt) from reports_work.dbo.Temp_GINSInsertRefUSAGETable


USE [reports_work]
GO

 CREATE STATISTICS [_dta_stat_1143935397_9] ON [dbo].[Temp_GINSInsertRefUSAGETable]([CurrencyType])


 CREATE NONCLUSTERED INDEX [_dta_index_Temp_GINSInsertRefUSAGETable_9_1143935397__K7] ON [dbo].[Temp_GINSInsertRefUSAGETable]
(
	[NetExtAmt] ASC
)WITH (SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = ON) ON [PRIMARY]


USE [Usage_Integration]
GO

CREATE STATISTICS [_dta_stat_1174399353_11_5] ON [dbo].[Usage_Master]([Process_Period], [Brand_id])
GO

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [_dta_index_Usage_Master_15_1174399353__K16_K11_K5_12] ON [dbo].[Usage_Master]
(
	[Master_Status] ASC,
	[Process_Period] ASC,
	[Brand_id] ASC
)
INCLUDE ( 	[Allocation_amt]) WITH (SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = ON) ON [PRIMARY]
GO

CREATE STATISTICS [_dta_stat_1174399353_16_5] ON [dbo].[Usage_Master]([Master_Status], [Brand_id])
GO

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [_dta_index_Usage_Master_15_1174399353__K5_K16_11_12] ON [dbo].[Usage_Master]
(
	[Brand_id] ASC,
	[Master_Status] ASC
)
INCLUDE ( 	[Process_Period],
	[Allocation_amt]) WITH (SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = ON) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_Usage_Master_Process_Period_Master_Status_I_ManyColumns]
ON [dbo].[Usage_Master] ([Process_Period],[Master_Status])
INCLUDE ([UsageID],[Asset_id],[Asset_descr],[Brand_id],[Sales_Order_id],[oracle_invoice_num],[Oracle_invoice_seqnum],[UsageDate],[Allocation_amt],[Currency_type],[Quantity])
WITH (SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = ON)
GO