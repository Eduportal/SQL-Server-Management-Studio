


USE [MetadataRevisionTool]
GO
CREATE NONCLUSTERED INDEX [IX_RuleVersion_IsCurrent_I_RuleVersionID_RuleID_LastRuleDeltaID]
ON [dbo].[RuleVersion] ([IsCurrent])
INCLUDE ([RuleVersionID],[RuleID],[LastRuleDeltaID]) WITH (DROP_EXISTING = ON, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


USE [MetadataRevisionTool]
GO
CREATE NONCLUSTERED INDEX [IX_Rule_ModifiedDate_I_RuleStage] 
ON [dbo].[Rule] ([ModifiedDate] ASC)
INCLUDE ( [RuleStage]) WITH (STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

USE [MetadataRevisionTool]
GO
CREATE NONCLUSTERED INDEX [_dta_index_RuleDelta_9_1301579675__K6_K5_K7_1] ON [dbo].[RuleDelta] 
(
	[RuleDeltaStatusDate] ASC,
	[RuleDeltaStatus] ASC,
	[RuleDeltaAssetCount] ASC
)
INCLUDE ( [RuleDeltaID]) WITH (STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

CREATE STATISTICS [_dta_stat_1301579675_5_7] ON [dbo].[RuleDelta]([RuleDeltaStatus], [RuleDeltaAssetCount])
CREATE STATISTICS [_dta_stat_1301579675_7_1_5_6] ON [dbo].[RuleDelta]([RuleDeltaAssetCount], [RuleDeltaID], [RuleDeltaStatus], [RuleDeltaStatusDate])
CREATE STATISTICS [_dta_stat_1301579675_1_5] ON [dbo].[RuleDelta]([RuleDeltaID], [RuleDeltaStatus])


USE [AssetKeyword]
GO
CREATE STATISTICS [_dta_stat_1502628396_1_3_2] ON [dbo].[QueuedAsset]([QueuedAssetID], [MasterID], [QueueID])
GO

CREATE NONCLUSTERED INDEX [_dta_index_QueuedAsset_7_1502628396__K3_K2_K1_6_7_9] 
ON [dbo].[QueuedAsset] 
(
	[MasterID] ASC,
	[QueueID] ASC,
	[QueuedAssetID] ASC
)
INCLUDE ( [Priority],
[InProcess],
[IndexBatchID]) WITH (STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


USE [AssetKeyword]
GO
CREATE NONCLUSTERED INDEX [IX_AssetKeyword_TermID_I_MasterID_Confidence_UpdatedBy_Weight_IsDeleted]
ON [dbo].[AssetKeyword] ([TermID])
INCLUDE ([MasterID],[Confidence],[UpdatedBy],[Weight],[IsDeleted])
WITH (STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO