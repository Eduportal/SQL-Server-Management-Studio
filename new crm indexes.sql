/*
Missing Index Details from SQLQuery5.sql - SEAPCRMSQL1A.Getty_Images_US_Inc__MSCRM (AMER\s-sledridge (108))
The Query Processor estimates that implementing the following index could improve the query cost by 99.9943%.
*/

/*
USE [Getty_Images_US_Inc__MSCRM]
GO
CREATE NONCLUSTERED INDEX [IX_New_webnoteExtensionBase_new_contactid]
ON [dbo].[New_webnoteExtensionBase] ([new_contactid])

GO
*/




CREATE STATISTICS [_dta_stat_446220940_7_10] ON [dbo].[New_webnoteBase]([New_webnoteId], [statecode])

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [_dta_index_New_webnoteExtensionBase_8_478221054__K10_K9_7_8] ON [dbo].[New_webnoteExtensionBase]
(
	[new_contactid] ASC,
	[New_webnoteId] ASC
)
INCLUDE ( 	[New_notetext],
	[New_site]) WITH (SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = ON) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [_dta_index_New_webnoteBase_8_446220940__K10_K7_11] ON [dbo].[New_webnoteBase]
(
	[statecode] ASC,
	[New_webnoteId] ASC
)
INCLUDE ( 	[statuscode]) WITH (SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = ON) ON [PRIMARY]
