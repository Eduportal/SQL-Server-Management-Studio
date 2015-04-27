
---- NOCLUSTERED INDEX EXIST ON THESE TABLES SO I CONVERTED THE PK'S TO CLUSTERED INDEXES
--USE [getty_master]
--GO

--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[c_contact]') AND name = N'PK__c_contact__208A65EC')
--ALTER TABLE [dbo].[c_contact] DROP CONSTRAINT [PK__c_contact__208A65EC]
--GO
--ALTER TABLE [dbo].[c_contact] ADD  CONSTRAINT [PK__c_contact__208A65EC] PRIMARY KEY CLUSTERED 
--(
--	[contact_sid] ASC
--)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
--GO


--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[x_period]') AND name = N'PK__x_period__5276C73B')
--ALTER TABLE [dbo].[x_period] DROP CONSTRAINT [PK__x_period__5276C73B]
--GO
--ALTER TABLE [dbo].[x_period] ADD  CONSTRAINT [PK__x_period__5276C73B] PRIMARY KEY CLUSTERED 
--(
--	[period_sid] ASC
--)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
--GO


--USE [getty_master]
--GO
--CREATE UNIQUE CLUSTERED INDEX [CIX_c_contact_contact_sid] ON [dbo].[c_contact] 
--(
--	[contact_sid] ASC
--)WITH (MAXDOP = 4, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
--GO

--USE [getty_master]
--GO
--CREATE UNIQUE CLUSTERED INDEX [CIX_x_period_period_sid] ON [dbo].[x_period] 
--(
--	[period_sid] ASC
--)WITH (MAXDOP = 4, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
--GO




CREATE STATISTICS [_dta_stat_1767764860_3_6] ON [dbo].[x_deal_calc_result]([file_download_nbr], [period_sid])

	
USE [rm_integration]
GO
CREATE NONCLUSTERED INDEX [IX_rm_integration_Process_status_I_SeqNum]
ON [dbo].[Contract_Stg] ([Process_status])
INCLUDE ([SeqNum])
GO


USE [getty_master]
GO
CREATE NONCLUSTERED INDEX [IX_x_contract_status_code_I_contract_id_contact_sid_descr_recipient_group_sid_admin_code]
ON [dbo].[x_contract] ([status_code])
INCLUDE ([contract_id],[contact_sid],[descr],[recipient_group_sid],[admin_code])
GO

USE [reports_work]
GO
CREATE NONCLUSTERED INDEX [IX_RM_Contract_stg_ref_contractid_seqnum_modifiedDate]
ON [dbo].[RM_Contract_stg_ref] ([contractid],[seqnum],[modifiedDate])

GO

USE [reports_work]
GO
CREATE NONCLUSTERED INDEX [IX_AlliantProcessContractRef_admin_code_I_PrimaryContactID_RecipientGroupName_RecipientDtlContactid_RecipGrpContactId]
ON [dbo].[AlliantProcessContractRef] ([admin_code])
INCLUDE ([PrimaryContactID],[RecipientGroupName],[RecipientDtlContactid],[RecipGrpContactId])
GO

USE [reports_work]
GO
CREATE NONCLUSTERED INDEX [IX_AlliantProcessContractRef_Contract_id_admin_code_I_PrimaryContactID_RecipientGroupName_RecipGrpContactId]
ON [dbo].[AlliantProcessContractRef] ([Contract_id],[admin_code])
INCLUDE ([PrimaryContactID],[RecipientGroupName],[RecipGrpContactId])
GO


USE [getty_master]
GO
CREATE NONCLUSTERED INDEX [IX_x_contract_status_code_comment_I_contract_id]
ON [dbo].[x_contract] ([status_code],[comment])
INCLUDE ([contract_id])
GO




GO
CREATE VIEW [dbo].[_dta_mv_1] WITH SCHEMABINDING
 AS 
SELECT  [dbo].[x_deal_calc_result].[period_sid] as _col_1,  count_big(*) as _col_2 FROM  [dbo].[x_deal_calc_result]  GROUP BY  [dbo].[x_deal_calc_result].[period_sid]  
GO


SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
CREATE UNIQUE CLUSTERED INDEX [_dta_index__dta_mv_1_c_16_2076966629__K1] ON [dbo].[_dta_mv_1] 
(
	[_col_1] ASC
)WITH (MAXDOP = 4, SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO









EXEC DBAADMIN.dbo.[dbasp_CreateMissingSingleColumnStats] 'rm_integration'
EXEC DBAADMIN.dbo.[dbasp_CreateMissingSingleColumnStats] 'getty_master'
EXEC DBAADMIN.dbo.[dbasp_CreateMissingSingleColumnStats] 'reports_work'

EXEC DBAADMIN.dbo.[dbasp_RapidUpdateStats] @DatabaseName = 'rm_integration'
EXEC DBAADMIN.dbo.[dbasp_RapidUpdateStats] @DatabaseName = 'getty_master'
EXEC DBAADMIN.dbo.[dbasp_RapidUpdateStats] @DatabaseName = 'reports_work'
