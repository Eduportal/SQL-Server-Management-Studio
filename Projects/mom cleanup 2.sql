use SCR2
GO
CREATE PROCEDURE pr_Disable_Foreign_Keys
    @disable BIT = 1
AS
    DECLARE
        @sql VARCHAR(500),
        @tableName VARCHAR(128),
        @foreignKeyName VARCHAR(128)

    -- A list of all foreign keys and table names
    DECLARE foreignKeyCursor CURSOR
    FOR SELECT
        ref.constraint_name AS FK_Name,
        fk.table_name AS FK_Table
    FROM
        INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS ref
        INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS fk 
    ON ref.constraint_name = fk.constraint_name
    ORDER BY
        fk.table_name,
        ref.constraint_name 

    OPEN foreignKeyCursor

    FETCH NEXT FROM foreignKeyCursor 
    INTO @foreignKeyName, @tableName

    WHILE ( @@FETCH_STATUS = 0 )
        BEGIN
            IF @disable = 1
                SET @sql = 'ALTER TABLE [' 
                    + @tableName + '] NOCHECK CONSTRAINT [' 
                    + @foreignKeyName + ']'
            ELSE
                SET @sql = 'ALTER TABLE [' 
                    + @tableName + '] CHECK CONSTRAINT [' 
                    + @foreignKeyName + ']'

        PRINT 'Executing Statement - ' + @sql

        EXECUTE(@sql)
        FETCH NEXT FROM foreignKeyCursor 
        INTO @foreignKeyName, @tableName
    END

    CLOSE foreignKeyCursor
    DEALLOCATE foreignKeyCursor
GO

exec pr_Disable_Foreign_Keys 1
GO    


SET IDENTITY_INSERT SCR2.dbo.SC_ComputerRuleDimension_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_UserDimension_Table OFF
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ScriptDimension_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_AlertToEventFact_Table OFF
GO


SET IDENTITY_INSERT SCR2.dbo.EventsQueue OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_ComputerToConfigurationGroupDimension_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_ComputerRuleToProcessRuleGroupFact_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_EventDetailDimension_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_DateDimension_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_ScriptToConfigurationGroupDimension_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_EventTypeDimension_Table OFF
GO


SET IDENTITY_INSERT SCR2.dbo.SC_ConfigurationGroupDimension_Table OFF
GO


SET IDENTITY_INSERT SCR2.dbo.SC_ClassInstanceFact_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_ProcessRuleMembershipFact_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_OperationalDataDimension_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_ComputerToComputerRuleFact_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_ProcessRuleToScriptFact_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_RelationshipAttributeInstanceFact_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_RelationshipDefinitionDimension_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_RelationshipInstanceFact_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_ComputerDimension_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_AlertLevelDimension_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_ClassAttributeDefinitionDimension_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_ProcessRuleDimension_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_TimeDimension_Table OFF
GO
SET IDENTITY_INSERT SCR2.dbo.SC_RelationshipAttributeDefinitionDimension_Table OFF
GO
SET IDENTITY_INSERT SCR2.dbo.SC_CounterDetailDimension_Table OFF
GO
SET IDENTITY_INSERT SCR2.dbo.SC_AlertResolutionStateDimension_Table OFF
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ProviderDetailDimension_Table OFF
GO
SET IDENTITY_INSERT SCR2.dbo.Modifications OFF
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ClassDefinitionDimension_Table OFF
GO
SET IDENTITY_INSERT SCR2.dbo.Users OFF
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ProcessRuleToConfigurationGroupDimension_Table OFF
GO
    
    
    
    
    
    
GO    
ALTER TABLE SCR2.dbo.ClassMethods DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.ClassMethods
GO
INSERT INTO SCR2.dbo.ClassMethods ([CM_ClassID],[CM_Description],[CM_DllID],[CM_IsStatic],[CM_MethodID],[CM_MethodName])
SELECT [CM_ClassID],[CM_Description],[CM_DllID],[CM_IsStatic],[CM_MethodID],[CM_MethodName] FROM SystemCenterReporting.dbo.ClassMethods
GO


ALTER TABLE SCR2.dbo.ProductSchema DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.ProductSchema
GO
INSERT INTO SCR2.dbo.ProductSchema ([PS_Description],[PS_PostDTSTransferSP],[PS_ProductID],[PS_ProductName])
SELECT [PS_Description],[PS_PostDTSTransferSP],[PS_ProductID],[PS_ProductName] FROM SystemCenterReporting.dbo.ProductSchema
GO


ALTER TABLE SCR2.dbo.ClassProperties DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.ClassProperties
GO
INSERT INTO SCR2.dbo.ClassProperties ([CP_ClassID],[CP_ClassPropertyID],[CP_DefaultValue],[CP_Description],[CP_IsIdentity],[CP_IsInherited],[CP_Nullable],[CP_PrimaryKey],[CP_PropertyName],[CP_PropertyTypeID],[CP_System])
SELECT [CP_ClassID],[CP_ClassPropertyID],[CP_DefaultValue],[CP_Description],[CP_IsIdentity],[CP_IsInherited],[CP_Nullable],[CP_PrimaryKey],[CP_PropertyName],[CP_PropertyTypeID],[CP_System] FROM SystemCenterReporting.dbo.ClassProperties
GO


SET IDENTITY_INSERT SCR2.dbo.SC_ComputerRuleDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_ComputerRuleDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_ComputerRuleDimension_Table
GO
INSERT INTO SCR2.dbo.SC_ComputerRuleDimension_Table ([ComputerRuleID_PK],[Description],[Expression],[IsEnabled],[Name],[SMC_InstanceID],[Type ])
SELECT [ComputerRuleID_PK],[Description],[Expression],[IsEnabled],[Name],[SMC_InstanceID],[Type ] FROM SystemCenterReporting.dbo.SC_ComputerRuleDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ComputerRuleDimension_Table OFF
GO

ALTER TABLE SCR2.dbo.PropertyInstancesAudits DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.PropertyInstancesAudits
GO
INSERT INTO SCR2.dbo.PropertyInstancesAudits ([PIA_ClassID],[PIA_ClassPropertyID],[PIA_EndModID],[PIA_InstanceID],[PIA_StartModID],[PIA_SuserSid],[PIA_Value])
SELECT [PIA_ClassID],[PIA_ClassPropertyID],[PIA_EndModID],[PIA_InstanceID],[PIA_StartModID],[PIA_SuserSid],[PIA_Value] FROM SystemCenterReporting.dbo.PropertyInstancesAudits
GO


SET IDENTITY_INSERT SCR2.dbo.SC_UserDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_UserDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_UserDimension_Table
GO
INSERT INTO SCR2.dbo.SC_UserDimension_Table ([SMC_InstanceID],[UserName_PK])
SELECT [SMC_InstanceID],[UserName_PK] FROM SystemCenterReporting.dbo.SC_UserDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_UserDimension_Table OFF
GO

ALTER TABLE SCR2.dbo.ClassIndexes DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.ClassIndexes
GO
INSERT INTO SCR2.dbo.ClassIndexes ([CI_ClassID],[CI_ClassIndexID],[CI_Clustered],[CI_FileGroupID],[CI_FillFactor],[CI_IndexName],[CI_System],[CI_Unique])
SELECT [CI_ClassID],[CI_ClassIndexID],[CI_Clustered],[CI_FileGroupID],[CI_FillFactor],[CI_IndexName],[CI_System],[CI_Unique] FROM SystemCenterReporting.dbo.ClassIndexes
GO


SET IDENTITY_INSERT SCR2.dbo.SC_ScriptDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_ScriptDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_ScriptDimension_Table
GO
INSERT INTO SCR2.dbo.SC_ScriptDimension_Table ([Description],[Name],[ScriptID_PK],[SMC_InstanceID],[Version])
SELECT [Description],[Name],[ScriptID_PK],[SMC_InstanceID],[Version] FROM SystemCenterReporting.dbo.SC_ScriptDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ScriptDimension_Table OFF
GO

ALTER TABLE SCR2.dbo.ClassInstances DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.ClassInstances
GO
INSERT INTO SCR2.dbo.ClassInstances ([CI_ClassID],[CI_FriendlyName],[CI_InstanceID],[CI_StartModID])
SELECT [CI_ClassID],[CI_FriendlyName],[CI_InstanceID],[CI_StartModID] FROM SystemCenterReporting.dbo.ClassInstances
GO


ALTER TABLE SCR2.dbo.ClassInstancesAudits DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.ClassInstancesAudits
GO
INSERT INTO SCR2.dbo.ClassInstancesAudits ([CIA_ClassID],[CIA_EndModID],[CIA_FriendlyName],[CIA_InstanceID],[CIA_StartModID],[CIA_SuserSid])
SELECT [CIA_ClassID],[CIA_EndModID],[CIA_FriendlyName],[CIA_InstanceID],[CIA_StartModID],[CIA_SuserSid] FROM SystemCenterReporting.dbo.ClassInstancesAudits
GO


ALTER TABLE SCR2.dbo.DatatypeDefinitions DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.DatatypeDefinitions
GO
INSERT INTO SCR2.dbo.DatatypeDefinitions ([DD_DatatypeID],[DD_Description],[DD_IsBlob],[DD_MaxLength],[DD_Name],[DD_RequiresLength],[DD_RequiresScalePrecision],[DD_VariableLength])
SELECT [DD_DatatypeID],[DD_Description],[DD_IsBlob],[DD_MaxLength],[DD_Name],[DD_RequiresLength],[DD_RequiresScalePrecision],[DD_VariableLength] FROM SystemCenterReporting.dbo.DatatypeDefinitions
GO


ALTER TABLE SCR2.dbo.ClassSchemaPartitions DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.ClassSchemaPartitions
GO
INSERT INTO SCR2.dbo.ClassSchemaPartitions ([CSP_ClassID],[CSP_Current],[CSP_DTSDone],[CSP_ID],[CSP_PartitionDate],[CSP_PartitionTableName])
SELECT [CSP_ClassID],[CSP_Current],[CSP_DTSDone],[CSP_ID],[CSP_PartitionDate],[CSP_PartitionTableName] FROM SystemCenterReporting.dbo.ClassSchemaPartitions
GO


SET IDENTITY_INSERT SCR2.dbo.SC_AlertToEventFact_Table ON
GO
ALTER TABLE SCR2.dbo.SC_AlertToEventFact_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_AlertToEventFact_Table
GO
INSERT INTO SCR2.dbo.SC_AlertToEventFact_Table ([AlertID],[ConfigurationGroup_FK],[DateTimeAlertAdded],[DateTimeEventStored],[EventID],[SMC_InstanceID])
SELECT [AlertID],[ConfigurationGroup_FK],[DateTimeAlertAdded],[DateTimeEventStored],[EventID],[SMC_InstanceID] FROM SystemCenterReporting.dbo.SC_AlertToEventFact_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_AlertToEventFact_Table OFF
GO

ALTER TABLE SCR2.dbo.DllDefinitions DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.DllDefinitions
GO
INSERT INTO SCR2.dbo.DllDefinitions ([DD_CLSID],[DD_DllID],[DD_DllName],[DD_DllPath])
SELECT [DD_CLSID],[DD_DllID],[DD_DllName],[DD_DllPath] FROM SystemCenterReporting.dbo.DllDefinitions
GO


ALTER TABLE SCR2.dbo.RelationshipTypes DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.RelationshipTypes
GO
INSERT INTO SCR2.dbo.RelationshipTypes ([RT_AllowMultipleConstraints],[RT_Cardinality],[RT_Description],[RT_GenerateView],[RT_HistoryUDFName],[RT_HistoryViewName],[RT_IsConstrained],[RT_IsHighVolume],[RT_MustBeDeleted],[RT_Name],[RT_NotifyOnDelete],[RT_NotifyOnInsert],[RT_NotifyOnUpdate],[RT_RelationshipTypeID],[RT_Signed],[RT_SignedModID],[RT_System],[RT_ViewInvalid],[RT_ViewName],[RT_ViewSrcName],[RT_ViewTargetName])
SELECT [RT_AllowMultipleConstraints],[RT_Cardinality],[RT_Description],[RT_GenerateView],[RT_HistoryUDFName],[RT_HistoryViewName],[RT_IsConstrained],[RT_IsHighVolume],[RT_MustBeDeleted],[RT_Name],[RT_NotifyOnDelete],[RT_NotifyOnInsert],[RT_NotifyOnUpdate],[RT_RelationshipTypeID],[RT_Signed],[RT_SignedModID],[RT_System],[RT_ViewInvalid],[RT_ViewName],[RT_ViewSrcName],[RT_ViewTargetName] FROM SystemCenterReporting.dbo.RelationshipTypes
GO


SET IDENTITY_INSERT SCR2.dbo.EventsQueue ON
GO
ALTER TABLE SCR2.dbo.EventsQueue DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.EventsQueue
GO
INSERT INTO SCR2.dbo.EventsQueue ([EQ_Action],[EQ_ClassID],[EQ_CreationModID],[EQ_EventID],[EQ_InstanceID],[EQ_RelationshipInstanceID],[EQ_RelationshipTypeID],[EQ_SourceInstanceID],[EQ_TargetInstanceID])
SELECT [EQ_Action],[EQ_ClassID],[EQ_CreationModID],[EQ_EventID],[EQ_InstanceID],[EQ_RelationshipInstanceID],[EQ_RelationshipTypeID],[EQ_SourceInstanceID],[EQ_TargetInstanceID] FROM SystemCenterReporting.dbo.EventsQueue
GO
SET IDENTITY_INSERT SCR2.dbo.EventsQueue OFF
GO

ALTER TABLE SCR2.dbo.PropertyInstances DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.PropertyInstances
GO
INSERT INTO SCR2.dbo.PropertyInstances ([PI_ClassID],[PI_ClassPropertyID],[PI_InstanceID],[PI_StartModID],[PI_Value])
SELECT [PI_ClassID],[PI_ClassPropertyID],[PI_InstanceID],[PI_StartModID],[PI_Value] FROM SystemCenterReporting.dbo.PropertyInstances
GO


ALTER TABLE SCR2.dbo.RelationshipInstancesAudits DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.RelationshipInstancesAudits
GO
INSERT INTO SCR2.dbo.RelationshipInstancesAudits ([RIA_EndModID],[RIA_InstanceID],[RIA_RelationshipTypeID],[RIA_SourceInstanceID],[RIA_StartModID],[RIA_SuserSid],[RIA_TargetInstanceID],[RIA_Usage])
SELECT [RIA_EndModID],[RIA_InstanceID],[RIA_RelationshipTypeID],[RIA_SourceInstanceID],[RIA_StartModID],[RIA_SuserSid],[RIA_TargetInstanceID],[RIA_Usage] FROM SystemCenterReporting.dbo.RelationshipInstancesAudits
GO


























SET IDENTITY_INSERT SCR2.dbo.SC_ComputerToConfigurationGroupDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_ComputerToConfigurationGroupDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_ComputerToConfigurationGroupDimension_Table
GO
INSERT INTO SCR2.dbo.SC_ComputerToConfigurationGroupDimension_Table ([Computer_FK_PK],[ConfigurationGroup_FK_PK],[SMC_InstanceID])
SELECT [Computer_FK_PK],[ConfigurationGroup_FK_PK],[SMC_InstanceID] FROM SystemCenterReporting.dbo.SC_ComputerToConfigurationGroupDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ComputerToConfigurationGroupDimension_Table OFF
GO

ALTER TABLE SCR2.dbo.RelationshipInstances DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.RelationshipInstances
GO
INSERT INTO SCR2.dbo.RelationshipInstances ([RI_InstanceID],[RI_RelationshipTypeID],[RI_SourceInstanceID],[RI_StartModID],[RI_TargetInstanceID],[RI_Usage])
SELECT [RI_InstanceID],[RI_RelationshipTypeID],[RI_SourceInstanceID],[RI_StartModID],[RI_TargetInstanceID],[RI_Usage] FROM SystemCenterReporting.dbo.RelationshipInstances
GO


SET IDENTITY_INSERT SCR2.dbo.SC_ComputerRuleToProcessRuleGroupFact_Table ON
GO
ALTER TABLE SCR2.dbo.SC_ComputerRuleToProcessRuleGroupFact_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_ComputerRuleToProcessRuleGroupFact_Table
GO
INSERT INTO SCR2.dbo.SC_ComputerRuleToProcessRuleGroupFact_Table ([ComputerRule_FK],[ConfigurationGroup_FK],[DateAdded_FK],[DateTimeAdded],[DateTimeOfTransfer],[ProcessRuleGroup_FK],[SMC_InstanceID],[TimeAdded_FK])
SELECT [ComputerRule_FK],[ConfigurationGroup_FK],[DateAdded_FK],[DateTimeAdded],[DateTimeOfTransfer],[ProcessRuleGroup_FK],[SMC_InstanceID],[TimeAdded_FK] FROM SystemCenterReporting.dbo.SC_ComputerRuleToProcessRuleGroupFact_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ComputerRuleToProcessRuleGroupFact_Table OFF
GO

ALTER TABLE SCR2.dbo.ClassSchemas DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.ClassSchemas
GO
INSERT INTO SCR2.dbo.ClassSchemas ([CS_ClassDeleted],[CS_ClassID],[CS_ClassName],[CS_Description],[CS_GenerateHistory],[CS_GenerateView],[CS_HistoryTableFileGroupID],[CS_HistoryTableName],[CS_HistoryUDFName],[CS_HistoryViewName],[CS_InheritsFrom],[CS_InsertViewName],[CS_IsGroup],[CS_IsHighVolume],[CS_NotifyOnDelete],[CS_NotifyOnInsert],[CS_NotifyOnUpdate],[CS_ParentClassID],[CS_Signed],[CS_SignedModID],[CS_SingleTable],[CS_SP_ValidateRow],[CS_SP_ValidateTable],[CS_SupportsPartitions],[CS_System],[CS_TableFileGroupID],[CS_TableName],[CS_ViewInvalid],[CS_ViewName])
SELECT [CS_ClassDeleted],[CS_ClassID],[CS_ClassName],[CS_Description],[CS_GenerateHistory],[CS_GenerateView],[CS_HistoryTableFileGroupID],[CS_HistoryTableName],[CS_HistoryUDFName],[CS_HistoryViewName],[CS_InheritsFrom],[CS_InsertViewName],[CS_IsGroup],[CS_IsHighVolume],[CS_NotifyOnDelete],[CS_NotifyOnInsert],[CS_NotifyOnUpdate],[CS_ParentClassID],[CS_Signed],[CS_SignedModID],[CS_SingleTable],[CS_SP_ValidateRow],[CS_SP_ValidateTable],[CS_SupportsPartitions],[CS_System],[CS_TableFileGroupID],[CS_TableName],[CS_ViewInvalid],[CS_ViewName] FROM SystemCenterReporting.dbo.ClassSchemas
GO


SET IDENTITY_INSERT SCR2.dbo.SC_EventDetailDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_EventDetailDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_EventDetailDimension_Table
GO
INSERT INTO SCR2.dbo.SC_EventDetailDimension_Table ([Category_PK],[EventID_PK],[EventSource_PK],[EventSourceMessage],[Language_PK],[MsgID_PK],[SMC_InstanceID])
SELECT [Category_PK],[EventID_PK],[EventSource_PK],[EventSourceMessage],[Language_PK],[MsgID_PK],[SMC_InstanceID] FROM SystemCenterReporting.dbo.SC_EventDetailDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_EventDetailDimension_Table OFF
GO

ALTER TABLE SCR2.dbo.ValidationUDFs DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.ValidationUDFs
GO
INSERT INTO SCR2.dbo.ValidationUDFs ([VU_Description],[VU_Name],[VU_Signed],[VU_SignedModID],[VU_ValidationUDFID])
SELECT [VU_Description],[VU_Name],[VU_Signed],[VU_SignedModID],[VU_ValidationUDFID] FROM SystemCenterReporting.dbo.ValidationUDFs
GO


SET IDENTITY_INSERT SCR2.dbo.SC_DateDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_DateDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_DateDimension_Table
GO
INSERT INTO SCR2.dbo.SC_DateDimension_Table ([Date],[DateDay_PK],[DateMonth_PK],[DateYear_PK],[SMC_InstanceID])
SELECT [Date],[DateDay_PK],[DateMonth_PK],[DateYear_PK],[SMC_InstanceID] FROM SystemCenterReporting.dbo.SC_DateDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_DateDimension_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_ScriptToConfigurationGroupDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_ScriptToConfigurationGroupDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_ScriptToConfigurationGroupDimension_Table
GO
INSERT INTO SCR2.dbo.SC_ScriptToConfigurationGroupDimension_Table ([ConfigurationGroup_FK_PK],[DateAdded_FK],[DateLastModified_FK],[DateTimeAdded],[DateTimeLastModified],[Script_FK_PK],[SMC_InstanceID],[TimeAdded_FK],[TimeLastModified_FK],[UserLastModified_FK])
SELECT [ConfigurationGroup_FK_PK],[DateAdded_FK],[DateLastModified_FK],[DateTimeAdded],[DateTimeLastModified],[Script_FK_PK],[SMC_InstanceID],[TimeAdded_FK],[TimeLastModified_FK],[UserLastModified_FK] FROM SystemCenterReporting.dbo.SC_ScriptToConfigurationGroupDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ScriptToConfigurationGroupDimension_Table OFF
GO

ALTER TABLE SCR2.dbo.SMO_TypeConversions DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SMO_TypeConversions
GO
INSERT INTO SCR2.dbo.SMO_TypeConversions ([STC_ConversionClass],[STC_CSharpTypeID],[STC_SMCTypeID],[STC_TypeConversionID])
SELECT [STC_ConversionClass],[STC_CSharpTypeID],[STC_SMCTypeID],[STC_TypeConversionID] FROM SystemCenterReporting.dbo.SMO_TypeConversions
GO


ALTER TABLE SCR2.dbo.ValidationUDFParameterValues DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.ValidationUDFParameterValues
GO
INSERT INTO SCR2.dbo.ValidationUDFParameterValues ([VUPV_ParamName],[VUPV_PropertyTypeID],[VUPV_ValidationUDFID],[VUPV_Value])
SELECT [VUPV_ParamName],[VUPV_PropertyTypeID],[VUPV_ValidationUDFID],[VUPV_Value] FROM SystemCenterReporting.dbo.ValidationUDFParameterValues
GO


SET IDENTITY_INSERT SCR2.dbo.SC_EventTypeDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_EventTypeDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_EventTypeDimension_Table
GO
INSERT INTO SCR2.dbo.SC_EventTypeDimension_Table ([Description],[EventType_PK],[SMC_InstanceID])
SELECT [Description],[EventType_PK],[SMC_InstanceID] FROM SystemCenterReporting.dbo.SC_EventTypeDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_EventTypeDimension_Table OFF
GO

ALTER TABLE SCR2.dbo.PropertyTypeEnumerations DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.PropertyTypeEnumerations
GO
INSERT INTO SCR2.dbo.PropertyTypeEnumerations ([PTE_Description],[PTE_EnumerationID],[PTE_EnumerationValue],[PTE_PropertyTypeID])
SELECT [PTE_Description],[PTE_EnumerationID],[PTE_EnumerationValue],[PTE_PropertyTypeID] FROM SystemCenterReporting.dbo.PropertyTypeEnumerations
GO


ALTER TABLE SCR2.dbo.SMO_ClassProperties DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SMO_ClassProperties
GO
INSERT INTO SCR2.dbo.SMO_ClassProperties ([SCP_CSharpTypeID],[SCP_Description],[SCP_Hidden],[SCP_Name],[SCP_SMCClassPropertyID],[SCP_SMOClassID],[SCP_SMOClassPropertyID],[SCP_SMOClassSMCClassID])
SELECT [SCP_CSharpTypeID],[SCP_Description],[SCP_Hidden],[SCP_Name],[SCP_SMCClassPropertyID],[SCP_SMOClassID],[SCP_SMOClassPropertyID],[SCP_SMOClassSMCClassID] FROM SystemCenterReporting.dbo.SMO_ClassProperties
GO


ALTER TABLE SCR2.dbo.SMO_RelationshipSources DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SMO_RelationshipSources
GO
INSERT INTO SCR2.dbo.SMO_RelationshipSources ([SRS_SMORelationshipTypeID],[SRS_SourceSMCClassID],[SRS_SourceSMOClassID])
SELECT [SRS_SMORelationshipTypeID],[SRS_SourceSMCClassID],[SRS_SourceSMOClassID] FROM SystemCenterReporting.dbo.SMO_RelationshipSources
GO


ALTER TABLE SCR2.dbo.SMO_ClassMethods DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SMO_ClassMethods
GO
INSERT INTO SCR2.dbo.SMO_ClassMethods ([SCM_ClientSideProxyName],[SCM_ServerSideAssembly],[SCM_ServerSideClass],[SCM_ServerSideMethod],[SCM_SMOClassID],[SCM_SMOClassMethodID])
SELECT [SCM_ClientSideProxyName],[SCM_ServerSideAssembly],[SCM_ServerSideClass],[SCM_ServerSideMethod],[SCM_SMOClassID],[SCM_SMOClassMethodID] FROM SystemCenterReporting.dbo.SMO_ClassMethods
GO


SET IDENTITY_INSERT SCR2.dbo.SC_ConfigurationGroupDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_ConfigurationGroupDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_ConfigurationGroupDimension_Table
GO
INSERT INTO SCR2.dbo.SC_ConfigurationGroupDimension_Table ([ConfigurationGroupID_PK],[ConfigurationGroupName],[SMC_InstanceID],[Version])
SELECT [ConfigurationGroupID_PK],[ConfigurationGroupName],[SMC_InstanceID],[Version] FROM SystemCenterReporting.dbo.SC_ConfigurationGroupDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ConfigurationGroupDimension_Table OFF
GO

ALTER TABLE SCR2.dbo.ClassIndexesColumns DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.ClassIndexesColumns
GO
INSERT INTO SCR2.dbo.ClassIndexesColumns ([CIC_Ascending],[CIC_ClassIndexID],[CIC_ClassPropertyID],[CIC_Order],[CIC_System])
SELECT [CIC_Ascending],[CIC_ClassIndexID],[CIC_ClassPropertyID],[CIC_Order],[CIC_System] FROM SystemCenterReporting.dbo.ClassIndexesColumns
GO


ALTER TABLE SCR2.dbo.MethodParameterDefinitions DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.MethodParameterDefinitions
GO
INSERT INTO SCR2.dbo.MethodParameterDefinitions ([MPD_MethodID],[MPD_Order],[MPD_ParameterName],[MPD_ParameterTypeID],[MPD_ParameterUsage])
SELECT [MPD_MethodID],[MPD_Order],[MPD_ParameterName],[MPD_ParameterTypeID],[MPD_ParameterUsage] FROM SystemCenterReporting.dbo.MethodParameterDefinitions
GO


ALTER TABLE SCR2.dbo.SMO_RelationshipTypes DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SMO_RelationshipTypes
GO
INSERT INTO SCR2.dbo.SMO_RelationshipTypes ([SRT_Description],[SRT_Name],[SRT_SMCRelationshipTypeID],[SRT_SMCSourceClassPropertyID],[SRT_SMCTargetClassPropertyID],[SRT_SMORelationshipTypeID],[SRT_SourceCSharpPropertyName],[SRT_TargetCSharpPropertyName])
SELECT [SRT_Description],[SRT_Name],[SRT_SMCRelationshipTypeID],[SRT_SMCSourceClassPropertyID],[SRT_SMCTargetClassPropertyID],[SRT_SMORelationshipTypeID],[SRT_SourceCSharpPropertyName],[SRT_TargetCSharpPropertyName] FROM SystemCenterReporting.dbo.SMO_RelationshipTypes
GO


SET IDENTITY_INSERT SCR2.dbo.SC_ClassInstanceFact_Table ON
GO
ALTER TABLE SCR2.dbo.SC_ClassInstanceFact_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_ClassInstanceFact_Table
GO
INSERT INTO SCR2.dbo.SC_ClassInstanceFact_Table ([ClassDefinition_FK],[ClassInstanceID],[ConfigurationGroup_FK],[DateAdded_FK],[DateLastModified_FK],[DateTimeAdded],[DateTimeLastModified],[DateTimeOfTransfer],[KeyValue],[SMC_InstanceID],[State],[TimeAdded_FK],[TimeLastModified_FK],[UserLastModified_FK])
SELECT [ClassDefinition_FK],[ClassInstanceID],[ConfigurationGroup_FK],[DateAdded_FK],[DateLastModified_FK],[DateTimeAdded],[DateTimeLastModified],[DateTimeOfTransfer],[KeyValue],[SMC_InstanceID],[State],[TimeAdded_FK],[TimeLastModified_FK],[UserLastModified_FK] FROM SystemCenterReporting.dbo.SC_ClassInstanceFact_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ClassInstanceFact_Table OFF
GO

ALTER TABLE SCR2.dbo.WrapperColumns DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.WrapperColumns
GO
INSERT INTO SCR2.dbo.WrapperColumns ([WC_ClassPropertyID],[WC_ColumnName],[WC_InOrder],[WC_OutOrder],[WC_VariableType],[WC_WrapperID])
SELECT [WC_ClassPropertyID],[WC_ColumnName],[WC_InOrder],[WC_OutOrder],[WC_VariableType],[WC_WrapperID] FROM SystemCenterReporting.dbo.WrapperColumns
GO


SET IDENTITY_INSERT SCR2.dbo.SC_ProcessRuleMembershipFact_Table ON
GO
ALTER TABLE SCR2.dbo.SC_ProcessRuleMembershipFact_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_ProcessRuleMembershipFact_Table
GO
INSERT INTO SCR2.dbo.SC_ProcessRuleMembershipFact_Table ([ConfigurationGroup_FK],[DateAdded_FK],[DateTimeAdded],[DateTimeOfTransfer],[Level],[ProcessRuleGroup_FK],[ProcessRuleMember_FK],[SMC_InstanceID],[TimeAdded_FK])
SELECT [ConfigurationGroup_FK],[DateAdded_FK],[DateTimeAdded],[DateTimeOfTransfer],[Level],[ProcessRuleGroup_FK],[ProcessRuleMember_FK],[SMC_InstanceID],[TimeAdded_FK] FROM SystemCenterReporting.dbo.SC_ProcessRuleMembershipFact_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ProcessRuleMembershipFact_Table OFF
GO

ALTER TABLE SCR2.dbo.WarehouseClassProperty DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.WarehouseClassProperty
GO
INSERT INTO SCR2.dbo.WarehouseClassProperty ([WCP_ClassPropertyID],[WCP_ColumnLevelTransform],[WCP_IsFilterColumn],[WCP_IsGroomColumn])
SELECT [WCP_ClassPropertyID],[WCP_ColumnLevelTransform],[WCP_IsFilterColumn],[WCP_IsGroomColumn] FROM SystemCenterReporting.dbo.WarehouseClassProperty
GO


SET IDENTITY_INSERT SCR2.dbo.SC_OperationalDataDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_OperationalDataDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_OperationalDataDimension_Table
GO
INSERT INTO SCR2.dbo.SC_OperationalDataDimension_Table ([OperationalDataID],[SMC_InstanceID],[Type])
SELECT [OperationalDataID],[SMC_InstanceID],[Type] FROM SystemCenterReporting.dbo.SC_OperationalDataDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_OperationalDataDimension_Table OFF
GO

ALTER TABLE SCR2.dbo.SMO_ClassSMCClassJoins DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SMO_ClassSMCClassJoins
GO
INSERT INTO SCR2.dbo.SMO_ClassSMCClassJoins ([SCSCJ_SMCRelationshipTypeID],[SCSCJ_SourceSMOClassSMCClassID],[SCSCJ_TargetSMOClassSMCClassID])
SELECT [SCSCJ_SMCRelationshipTypeID],[SCSCJ_SourceSMOClassSMCClassID],[SCSCJ_TargetSMOClassSMCClassID] FROM SystemCenterReporting.dbo.SMO_ClassSMCClassJoins
GO


SET IDENTITY_INSERT SCR2.dbo.SC_ComputerToComputerRuleFact_Table ON
GO
ALTER TABLE SCR2.dbo.SC_ComputerToComputerRuleFact_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_ComputerToComputerRuleFact_Table
GO
INSERT INTO SCR2.dbo.SC_ComputerToComputerRuleFact_Table ([Computer_FK],[ComputerRule_FK],[ConfigurationGroup_FK],[DateAdded_FK],[DateTimeAdded],[DateTimeOfTransfer],[Level],[SMC_InstanceID],[TimeAdded_FK])
SELECT [Computer_FK],[ComputerRule_FK],[ConfigurationGroup_FK],[DateAdded_FK],[DateTimeAdded],[DateTimeOfTransfer],[Level],[SMC_InstanceID],[TimeAdded_FK] FROM SystemCenterReporting.dbo.SC_ComputerToComputerRuleFact_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ComputerToComputerRuleFact_Table OFF
GO

ALTER TABLE SCR2.dbo.SMO_ClassSchemas DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SMO_ClassSchemas
GO
INSERT INTO SCR2.dbo.SMO_ClassSchemas ([SCS_CSharpAssemblyID],[SCS_CSharpClassTypeName],[SCS_Description],[SCS_SMOClassID],[SCS_ViewName])
SELECT [SCS_CSharpAssemblyID],[SCS_CSharpClassTypeName],[SCS_Description],[SCS_SMOClassID],[SCS_ViewName] FROM SystemCenterReporting.dbo.SMO_ClassSchemas
GO


ALTER TABLE SCR2.dbo.SMO_CSharpTypes DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SMO_CSharpTypes
GO
INSERT INTO SCR2.dbo.SMO_CSharpTypes ([SCT_AssemblyID],[SCT_CSharpTypeID],[SCT_Description],[SCT_Name])
SELECT [SCT_AssemblyID],[SCT_CSharpTypeID],[SCT_Description],[SCT_Name] FROM SystemCenterReporting.dbo.SMO_CSharpTypes
GO


SET IDENTITY_INSERT SCR2.dbo.SC_ProcessRuleToScriptFact_Table ON
GO
ALTER TABLE SCR2.dbo.SC_ProcessRuleToScriptFact_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_ProcessRuleToScriptFact_Table
GO
INSERT INTO SCR2.dbo.SC_ProcessRuleToScriptFact_Table ([ConfigurationGroup_FK],[DateAdded_FK],[DateTimeAdded],[DateTimeOfTransfer],[ProcessRule_FK],[Script_FK],[SMC_InstanceID],[TimeAdded_FK])
SELECT [ConfigurationGroup_FK],[DateAdded_FK],[DateTimeAdded],[DateTimeOfTransfer],[ProcessRule_FK],[Script_FK],[SMC_InstanceID],[TimeAdded_FK] FROM SystemCenterReporting.dbo.SC_ProcessRuleToScriptFact_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ProcessRuleToScriptFact_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_RelationshipAttributeInstanceFact_Table ON
GO
ALTER TABLE SCR2.dbo.SC_RelationshipAttributeInstanceFact_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_RelationshipAttributeInstanceFact_Table
GO
INSERT INTO SCR2.dbo.SC_RelationshipAttributeInstanceFact_Table ([ConfigurationGroup_FK],[DateAdded_FK],[DateLastModified_FK],[DateTimeAdded],[DateTimeLastModified],[DateTimeOfTransfer],[RelationshipAttributeDefinition_FK],[RelationshipAttributeInstanceID],[RelationshipInstanceID],[SMC_InstanceID],[SourceClassInstanceKeyValue],[TargetClassInstanceKeyValue],[TimeAdded_FK],[TimeLastModified_FK],[UserLastModified_FK],[Value])
SELECT [ConfigurationGroup_FK],[DateAdded_FK],[DateLastModified_FK],[DateTimeAdded],[DateTimeLastModified],[DateTimeOfTransfer],[RelationshipAttributeDefinition_FK],[RelationshipAttributeInstanceID],[RelationshipInstanceID],[SMC_InstanceID],[SourceClassInstanceKeyValue],[TargetClassInstanceKeyValue],[TimeAdded_FK],[TimeLastModified_FK],[UserLastModified_FK],[Value] FROM SystemCenterReporting.dbo.SC_RelationshipAttributeInstanceFact_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_RelationshipAttributeInstanceFact_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_RelationshipDefinitionDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_RelationshipDefinitionDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_RelationshipDefinitionDimension_Table
GO
INSERT INTO SCR2.dbo.SC_RelationshipDefinitionDimension_Table ([Description],[IsConnector],[IsContainment],[RelationshipTypeID_PK],[RelationshipTypeName],[SMC_InstanceID],[SourceClassDefinition_FK],[TargetClassDefinition_FK])
SELECT [Description],[IsConnector],[IsContainment],[RelationshipTypeID_PK],[RelationshipTypeName],[SMC_InstanceID],[SourceClassDefinition_FK],[TargetClassDefinition_FK] FROM SystemCenterReporting.dbo.SC_RelationshipDefinitionDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_RelationshipDefinitionDimension_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_RelationshipInstanceFact_Table ON
GO
ALTER TABLE SCR2.dbo.SC_RelationshipInstanceFact_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_RelationshipInstanceFact_Table
GO
INSERT INTO SCR2.dbo.SC_RelationshipInstanceFact_Table ([ConfigurationGroup_FK],[DateAdded_FK],[DateLastModified_FK],[DateTimeAdded],[DateTimeLastModified],[DateTimeOfTransfer],[RelationshipDefinition_FK],[RelationshipInstanceID],[SMC_InstanceID],[SourceClassInstanceID],[SourceClassInstanceKeyValue],[TargetClassInstanceID],[TargetClassInstanceKeyValue],[TimeAdded_FK],[TimeLastModified_FK],[UserLastModified_FK])
SELECT [ConfigurationGroup_FK],[DateAdded_FK],[DateLastModified_FK],[DateTimeAdded],[DateTimeLastModified],[DateTimeOfTransfer],[RelationshipDefinition_FK],[RelationshipInstanceID],[SMC_InstanceID],[SourceClassInstanceID],[SourceClassInstanceKeyValue],[TargetClassInstanceID],[TargetClassInstanceKeyValue],[TimeAdded_FK],[TimeLastModified_FK],[UserLastModified_FK] FROM SystemCenterReporting.dbo.SC_RelationshipInstanceFact_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_RelationshipInstanceFact_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_ComputerDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_ComputerDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_ComputerDimension_Table
GO
INSERT INTO SCR2.dbo.SC_ComputerDimension_Table ([ComputerDomain_PK],[ComputerID],[ComputerName_PK],[ComputerType],[DateTimeLastContacted],[Description],[DNSName],[FullComputerName],[IsAgent],[IsCollector],[SMC_InstanceID])
SELECT [ComputerDomain_PK],[ComputerID],[ComputerName_PK],[ComputerType],[DateTimeLastContacted],[Description],[DNSName],[FullComputerName],[IsAgent],[IsCollector],[SMC_InstanceID] FROM SystemCenterReporting.dbo.SC_ComputerDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ComputerDimension_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_AlertLevelDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_AlertLevelDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_AlertLevelDimension_Table
GO
INSERT INTO SCR2.dbo.SC_AlertLevelDimension_Table ([AlertLevel_PK],[AlertLevelColor],[AlertLevelName],[Language],[SMC_InstanceID])
SELECT [AlertLevel_PK],[AlertLevelColor],[AlertLevelName],[Language],[SMC_InstanceID] FROM SystemCenterReporting.dbo.SC_AlertLevelDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_AlertLevelDimension_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_ClassAttributeDefinitionDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_ClassAttributeDefinitionDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_ClassAttributeDefinitionDimension_Table
GO
INSERT INTO SCR2.dbo.SC_ClassAttributeDefinitionDimension_Table ([ClassAttributeID_PK],[ClassAttributeName],[ClassDefinition_FK],[DateTimeAdded],[Description],[IsEnabled],[IsPrimaryKey],[SMC_InstanceID])
SELECT [ClassAttributeID_PK],[ClassAttributeName],[ClassDefinition_FK],[DateTimeAdded],[Description],[IsEnabled],[IsPrimaryKey],[SMC_InstanceID] FROM SystemCenterReporting.dbo.SC_ClassAttributeDefinitionDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ClassAttributeDefinitionDimension_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_ProcessRuleDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_ProcessRuleDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_ProcessRuleDimension_Table
GO
INSERT INTO SCR2.dbo.SC_ProcessRuleDimension_Table ([IsRuleGroup],[ProcessRuleID_PK],[ProcessRuleName],[ProviderDetail_FK],[SMC_InstanceID])
SELECT [IsRuleGroup],[ProcessRuleID_PK],[ProcessRuleName],[ProviderDetail_FK],[SMC_InstanceID] FROM SystemCenterReporting.dbo.SC_ProcessRuleDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ProcessRuleDimension_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_TimeDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_TimeDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_TimeDimension_Table
GO
INSERT INTO SCR2.dbo.SC_TimeDimension_Table ([AMPM],[Hour_PK],[Minute_PK],[Second_PK],[SMC_InstanceID],[TimeOfDay])
SELECT [AMPM],[Hour_PK],[Minute_PK],[Second_PK],[SMC_InstanceID],[TimeOfDay] FROM SystemCenterReporting.dbo.SC_TimeDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_TimeDimension_Table OFF
GO

ALTER TABLE SCR2.dbo.FileGroups DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.FileGroups
GO
INSERT INTO SCR2.dbo.FileGroups ([FG_FileGroupID],[FG_Name])
SELECT [FG_FileGroupID],[FG_Name] FROM SystemCenterReporting.dbo.FileGroups
GO


ALTER TABLE SCR2.dbo.GroomingSettings DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.GroomingSettings
GO
INSERT INTO SCR2.dbo.GroomingSettings ([GS_DataWarehouseInUse],[GS_LiveDataPeriod])
SELECT [GS_DataWarehouseInUse],[GS_LiveDataPeriod] FROM SystemCenterReporting.dbo.GroomingSettings
GO


SET IDENTITY_INSERT SCR2.dbo.SC_RelationshipAttributeDefinitionDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_RelationshipAttributeDefinitionDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_RelationshipAttributeDefinitionDimension_Table
GO
INSERT INTO SCR2.dbo.SC_RelationshipAttributeDefinitionDimension_Table ([Description],[RelationshipAttributeID_PK],[RelationshipAttributeName],[RelationshipDefinition_FK],[SMC_InstanceID])
SELECT [Description],[RelationshipAttributeID_PK],[RelationshipAttributeName],[RelationshipDefinition_FK],[SMC_InstanceID] FROM SystemCenterReporting.dbo.SC_RelationshipAttributeDefinitionDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_RelationshipAttributeDefinitionDimension_Table OFF
GO

ALTER TABLE SCR2.dbo.MetaVersion DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.MetaVersion
GO
INSERT INTO SCR2.dbo.MetaVersion ([MV_CreationDate],[MV_Description],[MV_MajorVersion],[MV_MinorVersion],[MV_Name])
SELECT [MV_CreationDate],[MV_Description],[MV_MajorVersion],[MV_MinorVersion],[MV_Name] FROM SystemCenterReporting.dbo.MetaVersion
GO


ALTER TABLE SCR2.dbo.SMC_Messages DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SMC_Messages
GO
INSERT INTO SCR2.dbo.SMC_Messages ([SM_Language],[SM_Message],[SM_MsgID],[SM_Name],[SM_Severity])
SELECT [SM_Language],[SM_Message],[SM_MsgID],[SM_Name],[SM_Severity] FROM SystemCenterReporting.dbo.SMC_Messages
GO


ALTER TABLE SCR2.dbo.SMO_CSharpAssemblies DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SMO_CSharpAssemblies
GO
INSERT INTO SCR2.dbo.SMO_CSharpAssemblies ([SCA_AssemblyID],[SCA_Culture],[SCA_Name],[SCA_PublicKeyToken],[SCA_Version])
SELECT [SCA_AssemblyID],[SCA_Culture],[SCA_Name],[SCA_PublicKeyToken],[SCA_Version] FROM SystemCenterReporting.dbo.SMO_CSharpAssemblies
GO


SET IDENTITY_INSERT SCR2.dbo.SC_CounterDetailDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_CounterDetailDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_CounterDetailDimension_Table
GO
INSERT INTO SCR2.dbo.SC_CounterDetailDimension_Table ([CounterID],[CounterName_PK],[InstanceName_PK],[ObjectName_PK],[ScaleFactor],[ScaleLegend],[SMC_InstanceID])
SELECT [CounterID],[CounterName_PK],[InstanceName_PK],[ObjectName_PK],[ScaleFactor],[ScaleLegend],[SMC_InstanceID] FROM SystemCenterReporting.dbo.SC_CounterDetailDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_CounterDetailDimension_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_AlertResolutionStateDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_AlertResolutionStateDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_AlertResolutionStateDimension_Table
GO
INSERT INTO SCR2.dbo.SC_AlertResolutionStateDimension_Table ([AlertResolutionState_PK],[AlertResolutionStateDescription],[SMC_InstanceID])
SELECT [AlertResolutionState_PK],[AlertResolutionStateDescription],[SMC_InstanceID] FROM SystemCenterReporting.dbo.SC_AlertResolutionStateDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_AlertResolutionStateDimension_Table OFF
GO

ALTER TABLE SCR2.dbo.MethodParameterTypes DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.MethodParameterTypes
GO
INSERT INTO SCR2.dbo.MethodParameterTypes ([MPT_ParameterTypeID],[MPT_ParameterTypeName])
SELECT [MPT_ParameterTypeID],[MPT_ParameterTypeName] FROM SystemCenterReporting.dbo.MethodParameterTypes
GO


SET IDENTITY_INSERT SCR2.dbo.SC_ProviderDetailDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_ProviderDetailDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_ProviderDetailDimension_Table
GO
INSERT INTO SCR2.dbo.SC_ProviderDetailDimension_Table ([ProviderInstanceID_PK],[ProviderInstanceName],[ProviderTypeClassID],[ProviderTypeName],[SMC_InstanceID])
SELECT [ProviderInstanceID_PK],[ProviderInstanceName],[ProviderTypeClassID],[ProviderTypeName],[SMC_InstanceID] FROM SystemCenterReporting.dbo.SC_ProviderDetailDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ProviderDetailDimension_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.Modifications ON
GO
ALTER TABLE SCR2.dbo.Modifications DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.Modifications
GO
INSERT INTO SCR2.dbo.Modifications ([M_Date],[M_ModificationID],[M_TransactionToken],[M_UserID])
SELECT [M_Date],[M_ModificationID],[M_TransactionToken],[M_UserID] FROM SystemCenterReporting.dbo.Modifications
GO
SET IDENTITY_INSERT SCR2.dbo.Modifications OFF
GO

ALTER TABLE SCR2.dbo.ValidationUDFParameters DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.ValidationUDFParameters
GO
INSERT INTO SCR2.dbo.ValidationUDFParameters ([VUP_ParamDatatypeID],[VUP_ParamLength],[VUP_ParamName],[VUP_ParamOrder],[VUP_ParamPrecision],[VUP_ParamScale],[VUP_ValidationUDFID])
SELECT [VUP_ParamDatatypeID],[VUP_ParamLength],[VUP_ParamName],[VUP_ParamOrder],[VUP_ParamPrecision],[VUP_ParamScale],[VUP_ValidationUDFID] FROM SystemCenterReporting.dbo.ValidationUDFParameters
GO


ALTER TABLE SCR2.dbo.PropertyTypes DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.PropertyTypes
GO
INSERT INTO SCR2.dbo.PropertyTypes ([PT_DatatypeID],[PT_Deleted],[PT_Description],[PT_IsEnumeration],[PT_Length],[PT_ParentTypeID],[PT_Precision],[PT_Scale],[PT_Signed],[PT_SignedModID],[PT_System],[PT_TypeID],[PT_TypeName],[PT_UDFValidationID])
SELECT [PT_DatatypeID],[PT_Deleted],[PT_Description],[PT_IsEnumeration],[PT_Length],[PT_ParentTypeID],[PT_Precision],[PT_Scale],[PT_Signed],[PT_SignedModID],[PT_System],[PT_TypeID],[PT_TypeName],[PT_UDFValidationID] FROM SystemCenterReporting.dbo.PropertyTypes
GO


ALTER TABLE SCR2.dbo.WarehouseClassSchemaToProductSchema DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.WarehouseClassSchemaToProductSchema
GO
INSERT INTO SCR2.dbo.WarehouseClassSchemaToProductSchema ([WCSPS_ClassID],[WCSPS_LowWatermarkFromSourceQuery],[WCSPS_ProductID],[WCSPS_SourceQuery])
SELECT [WCSPS_ClassID],[WCSPS_LowWatermarkFromSourceQuery],[WCSPS_ProductID],[WCSPS_SourceQuery] FROM SystemCenterReporting.dbo.WarehouseClassSchemaToProductSchema
GO


ALTER TABLE SCR2.dbo.WarehouseClassSchema DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.WarehouseClassSchema
GO
INSERT INTO SCR2.dbo.WarehouseClassSchema ([WCS_ClassID],[WCS_DimensionType],[WCS_FactType],[WCS_GroomDays],[WCS_MustBeGroomed],[WCS_TableTransformOrder],[WCS_WarehouseTableType])
SELECT [WCS_ClassID],[WCS_DimensionType],[WCS_FactType],[WCS_GroomDays],[WCS_MustBeGroomed],[WCS_TableTransformOrder],[WCS_WarehouseTableType] FROM SystemCenterReporting.dbo.WarehouseClassSchema
GO


ALTER TABLE SCR2.dbo.SMO_ClassSMCClasses DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SMO_ClassSMCClasses
GO
INSERT INTO SCR2.dbo.SMO_ClassSMCClasses ([SCSC_IsPrimary],[SCSC_IsUsedInRelationships],[SCSC_SMCClassID],[SCSC_SMOClassID],[SCSC_SMOClassSMCClassID],[SCSC_ViewAlias])
SELECT [SCSC_IsPrimary],[SCSC_IsUsedInRelationships],[SCSC_SMCClassID],[SCSC_SMOClassID],[SCSC_SMOClassSMCClassID],[SCSC_ViewAlias] FROM SystemCenterReporting.dbo.SMO_ClassSMCClasses
GO


SET IDENTITY_INSERT SCR2.dbo.SC_ClassDefinitionDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_ClassDefinitionDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_ClassDefinitionDimension_Table
GO
INSERT INTO SCR2.dbo.SC_ClassDefinitionDimension_Table ([ClassID_PK],[Description],[Name],[SMC_InstanceID])
SELECT [ClassID_PK],[Description],[Name],[SMC_InstanceID] FROM SystemCenterReporting.dbo.SC_ClassDefinitionDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ClassDefinitionDimension_Table OFF
GO

ALTER TABLE SCR2.dbo.WarehouseGroomingInfo DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.WarehouseGroomingInfo
GO
INSERT INTO SCR2.dbo.WarehouseGroomingInfo ([WG_ClassID],[WG_EndTime],[WG_StartTime])
SELECT [WG_ClassID],[WG_EndTime],[WG_StartTime] FROM SystemCenterReporting.dbo.WarehouseGroomingInfo
GO


ALTER TABLE SCR2.dbo.WarehouseTransformInfo DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.WarehouseTransformInfo
GO
INSERT INTO SCR2.dbo.WarehouseTransformInfo ([WTI_ConfigurationGroupID],[WTI_CurrentEndTime],[WTI_CurrentStartTime])
SELECT [WTI_ConfigurationGroupID],[WTI_CurrentEndTime],[WTI_CurrentStartTime] FROM SystemCenterReporting.dbo.WarehouseTransformInfo
GO


ALTER TABLE SCR2.dbo.SMO_RelationshipTargets DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SMO_RelationshipTargets
GO
INSERT INTO SCR2.dbo.SMO_RelationshipTargets ([SRT_SMORelationshipTypeID],[SRT_TargetSMCClassID],[SRT_TargetSMOClassID])
SELECT [SRT_SMORelationshipTypeID],[SRT_TargetSMCClassID],[SRT_TargetSMOClassID] FROM SystemCenterReporting.dbo.SMO_RelationshipTargets
GO


ALTER TABLE SCR2.dbo.WrapperSchemas DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.WrapperSchemas
GO
INSERT INTO SCR2.dbo.WrapperSchemas ([WS_ClassID],[WS_ClassName],[WS_Query],[WS_QueryType],[WS_RelationshipTypeID],[WS_WrapperFileName],[WS_WrapperID],[WS_WrapperType])
SELECT [WS_ClassID],[WS_ClassName],[WS_Query],[WS_QueryType],[WS_RelationshipTypeID],[WS_WrapperFileName],[WS_WrapperID],[WS_WrapperType] FROM SystemCenterReporting.dbo.WrapperSchemas
GO


SET IDENTITY_INSERT SCR2.dbo.Users ON
GO
ALTER TABLE SCR2.dbo.Users DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.Users
GO
INSERT INTO SCR2.dbo.Users ([U_Description],[U_Fax],[U_Location],[U_Mail],[U_MobilePhone],[U_Pager],[U_Phone],[U_Problem],[U_Role],[U_UserID],[U_UserName])
SELECT [U_Description],[U_Fax],[U_Location],[U_Mail],[U_MobilePhone],[U_Pager],[U_Phone],[U_Problem],[U_Role],[U_UserID],[U_UserName] FROM SystemCenterReporting.dbo.Users
GO
SET IDENTITY_INSERT SCR2.dbo.Users OFF
GO

ALTER TABLE SCR2.dbo.ClassRelationships DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.ClassRelationships
GO
INSERT INTO SCR2.dbo.ClassRelationships ([CR_Description],[CR_RelationshipID],[CR_SourceClassID],[CR_System],[CR_TargetClassID])
SELECT [CR_Description],[CR_RelationshipID],[CR_SourceClassID],[CR_System],[CR_TargetClassID] FROM SystemCenterReporting.dbo.ClassRelationships
GO


ALTER TABLE SCR2.dbo.RelationshipConstraints DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.RelationshipConstraints
GO
INSERT INTO SCR2.dbo.RelationshipConstraints ([RC_ConstraintID],[RC_RelationshipTypeID],[RC_SourceClassID],[RC_System],[RC_TargetClassID],[RC_TargetFK])
SELECT [RC_ConstraintID],[RC_RelationshipTypeID],[RC_SourceClassID],[RC_System],[RC_TargetClassID],[RC_TargetFK] FROM SystemCenterReporting.dbo.RelationshipConstraints
GO


SET IDENTITY_INSERT SCR2.dbo.SC_ProcessRuleToConfigurationGroupDimension_Table ON
GO
ALTER TABLE SCR2.dbo.SC_ProcessRuleToConfigurationGroupDimension_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_ProcessRuleToConfigurationGroupDimension_Table
GO
INSERT INTO SCR2.dbo.SC_ProcessRuleToConfigurationGroupDimension_Table ([ConfigurationGroup_FK_PK],[DateAdded_FK],[DateLastModified_FK],[DateTimeAdded],[DateTimeLastModified],[IsEnabled],[ProcessRule_FK_PK],[SMC_InstanceID],[TimeAdded_FK],[TimeLastModified_FK],[UserLastModified_FK])
SELECT [ConfigurationGroup_FK_PK],[DateAdded_FK],[DateLastModified_FK],[DateTimeAdded],[DateTimeLastModified],[IsEnabled],[ProcessRule_FK_PK],[SMC_InstanceID],[TimeAdded_FK],[TimeLastModified_FK],[UserLastModified_FK] FROM SystemCenterReporting.dbo.SC_ProcessRuleToConfigurationGroupDimension_Table
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ProcessRuleToConfigurationGroupDimension_Table OFF
GO










SET IDENTITY_INSERT SCR2.dbo.SC_SampledNumericDataFact_Table ON
GO
ALTER TABLE SCR2.dbo.SC_SampledNumericDataFact_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_SampledNumericDataFact_Table
GO
INSERT INTO SCR2.dbo.SC_SampledNumericDataFact_Table ([Computer_FK],[ConfigurationGroup_FK],[CounterDetail_FK],[DateSampled_FK],[DateTimeAdded],[DateTimeSampled],[LocalDateSampled_FK],[LocalDateTimeSampled],[LocalTimeSampled_FK],[SampleValue],[SMC_InstanceID],[TimeSampled_FK])
SELECT [Computer_FK],[ConfigurationGroup_FK],[CounterDetail_FK],[DateSampled_FK],[DateTimeAdded],[DateTimeSampled],[LocalDateSampled_FK],[LocalDateTimeSampled],[LocalTimeSampled_FK],[SampleValue],[SMC_InstanceID],[TimeSampled_FK] FROM SystemCenterReporting.dbo.SC_SampledNumericDataFact_Table WHERE [DateTimeAdded] >= GetDate()-90
GO
SET IDENTITY_INSERT SCR2.dbo.SC_SampledNumericDataFact_Table OFF
GO




SET IDENTITY_INSERT SCR2.dbo.SC_SampledNumericDataFact_Table ON
GO
ALTER TABLE SCR2.dbo.SC_SampledNumericDataFact_Table DISABLE TRIGGER ALL
GO

InsertSomeMore:

INSERT INTO SCR2.dbo.SC_SampledNumericDataFact_Table ([Computer_FK],[ConfigurationGroup_FK],[CounterDetail_FK],[DateSampled_FK],[DateTimeAdded],[DateTimeSampled],[LocalDateSampled_FK],[LocalDateTimeSampled],[LocalTimeSampled_FK],[SampleValue],[SMC_InstanceID],[TimeSampled_FK])
SELECT [Computer_FK],[ConfigurationGroup_FK],[CounterDetail_FK],[DateSampled_FK],[DateTimeAdded],[DateTimeSampled],[LocalDateSampled_FK],[LocalDateTimeSampled],[LocalTimeSampled_FK],[SampleValue],[SMC_InstanceID],[TimeSampled_FK] FROM SystemCenterReporting.dbo.SC_SampledNumericDataFact_Table
WHERE	[SMC_InstanceID] IN
(
SELECT TOP 100 [SMC_InstanceID] 
FROM SystemCenterReporting.dbo.SC_SampledNumericDataFact_Table 
WHERE [SMC_InstanceID] NOT IN (SELECT [SMC_InstanceID] FROM SCR2.dbo.SC_SampledNumericDataFact_Table)
)

If @@RowCount = 100 Goto InsertSomeMore

ALTER TABLE SCR2.dbo.SC_SampledNumericDataFact_Table ENABLE TRIGGER ALL
GO

GO
SET IDENTITY_INSERT SCR2.dbo.SC_SampledNumericDataFact_Table OFF
GO







select count(*) FROM SCR2.dbo.SC_SampledNumericDataFact_Table 

select MIN(DateTimeAdded),max(DateTimeAdded) FROM SCR2.dbo.SC_SampledNumericDataFact_Table 





SET IDENTITY_INSERT SCR2.dbo.SC_EventFact_Table ON
GO
ALTER TABLE SCR2.dbo.SC_EventFact_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_EventFact_Table
GO
INSERT INTO SCR2.dbo.SC_EventFact_Table ([Computer_FK],[ComputerLogged_FK],[ConfigurationGroup_FK],[DateGenerated_FK],[DateOfFirstEvent_FK],[DateOfLastEvent_FK],[DateStarted_FK],[DateStored_FK],[DateTimeGenerated],[DateTimeOfFirstEvent],[DateTimeOfLastEvent],[DateTimeStarted],[DateTimeStored],[EventData],[EventDetail_FK],[EventID],[EventMessage],[EventType_FK],[IsAlerted],[IsConsolidated],[LocalDateGenerated_FK],[LocalDateStored_FK],[LocalDateTimeGenerated],[LocalDateTimeStored],[LocalTimeGenerated_FK],[LocalTimeStored_FK],[ProviderDetail_FK],[RepeatCount],[SMC_InstanceID],[TimeGenerated_FK],[TimeOfFirstEvent_FK],[TimeOfLastEvent_FK],[TimeStarted_FK],[TimeStored_FK],[User_FK])
SELECT [Computer_FK],[ComputerLogged_FK],[ConfigurationGroup_FK],[DateGenerated_FK],[DateOfFirstEvent_FK],[DateOfLastEvent_FK],[DateStarted_FK],[DateStored_FK],[DateTimeGenerated],[DateTimeOfFirstEvent],[DateTimeOfLastEvent],[DateTimeStarted],[DateTimeStored],[EventData],[EventDetail_FK],[EventID],[EventMessage],[EventType_FK],[IsAlerted],[IsConsolidated],[LocalDateGenerated_FK],[LocalDateStored_FK],[LocalDateTimeGenerated],[LocalDateTimeStored],[LocalTimeGenerated_FK],[LocalTimeStored_FK],[ProviderDetail_FK],[RepeatCount],[SMC_InstanceID],[TimeGenerated_FK],[TimeOfFirstEvent_FK],[TimeOfLastEvent_FK],[TimeStarted_FK],[TimeStored_FK],[User_FK] FROM SystemCenterReporting.dbo.SC_EventFact_Table WHERE [DateTimeStored] >= GetDate()-90
GO
SET IDENTITY_INSERT SCR2.dbo.SC_EventFact_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_EventParameterFact_Table ON
GO
ALTER TABLE SCR2.dbo.SC_EventParameterFact_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_EventParameterFact_Table
GO
INSERT INTO SCR2.dbo.SC_EventParameterFact_Table ([ConfigurationGroup_FK],[DateTimeEventStored],[EventID],[EventParameterName],[EventParameterValue],[Position],[SMC_InstanceID])
SELECT [ConfigurationGroup_FK],[DateTimeEventStored],[EventID],[EventParameterName],[EventParameterValue],[Position],[SMC_InstanceID] FROM SystemCenterReporting.dbo.SC_EventParameterFact_Table WHERE [DateTimeEventStored] >= GetDate()-90
GO
SET IDENTITY_INSERT SCR2.dbo.SC_EventParameterFact_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_AlertHistoryFact_Table ON
GO
ALTER TABLE SCR2.dbo.SC_AlertHistoryFact_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_AlertHistoryFact_Table
GO
INSERT INTO SCR2.dbo.SC_AlertHistoryFact_Table ([AlertID],[AlertResolutionState_FK],[Comments],[ConfigurationGroup_FK],[CustomField1],[CustomField2],[CustomField3],[CustomField4],[CustomField5],[DateLastModified_FK],[DateResolved_FK],[DateStateModified_FK],[DateTimeLastModified],[DateTimeResolved],[DateTimeStateModified],[LocalDateResolved_FK],[LocalDateTimeResolved],[LocalTimeResolved_FK],[SMC_InstanceID],[TimeLastModified_FK],[TimeResolved_FK],[TimeStateModified_FK],[UserLastModified_FK],[UserOwner_FK],[UserResolvedBy_FK])
SELECT [AlertID],[AlertResolutionState_FK],[Comments],[ConfigurationGroup_FK],[CustomField1],[CustomField2],[CustomField3],[CustomField4],[CustomField5],[DateLastModified_FK],[DateResolved_FK],[DateStateModified_FK],[DateTimeLastModified],[DateTimeResolved],[DateTimeStateModified],[LocalDateResolved_FK],[LocalDateTimeResolved],[LocalTimeResolved_FK],[SMC_InstanceID],[TimeLastModified_FK],[TimeResolved_FK],[TimeStateModified_FK],[UserLastModified_FK],[UserOwner_FK],[UserResolvedBy_FK] FROM SystemCenterReporting.dbo.SC_AlertHistoryFact_Table WHERE [DateTimeLastModified] >= GetDate()-90
GO
SET IDENTITY_INSERT SCR2.dbo.SC_AlertHistoryFact_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_ClassAttributeInstanceFact_Table ON
GO
ALTER TABLE SCR2.dbo.SC_ClassAttributeInstanceFact_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_ClassAttributeInstanceFact_Table
GO
INSERT INTO SCR2.dbo.SC_ClassAttributeInstanceFact_Table ([ClassAttributeDefinition_FK],[ClassAttributeInstanceID],[ClassInstanceID],[ClassInstanceKeyValue],[ConfigurationGroup_FK],[DateAdded_FK],[DateLastModified_FK],[DateTimeAdded],[DateTimeLastModified],[DateTimeOfTransfer],[SMC_InstanceID],[TimeAdded_FK],[TimeLastModified_FK],[UserLastModified_FK],[Value])
SELECT [ClassAttributeDefinition_FK],[ClassAttributeInstanceID],[ClassInstanceID],[ClassInstanceKeyValue],[ConfigurationGroup_FK],[DateAdded_FK],[DateLastModified_FK],[DateTimeAdded],[DateTimeLastModified],[DateTimeOfTransfer],[SMC_InstanceID],[TimeAdded_FK],[TimeLastModified_FK],[UserLastModified_FK],[Value] FROM SystemCenterReporting.dbo.SC_ClassAttributeInstanceFact_Table WHERE [DateTimeOfTransfer] >= GetDate()-90
GO
SET IDENTITY_INSERT SCR2.dbo.SC_ClassAttributeInstanceFact_Table OFF
GO

SET IDENTITY_INSERT SCR2.dbo.SC_AlertFact_Table ON
GO
ALTER TABLE SCR2.dbo.SC_AlertFact_Table DISABLE TRIGGER ALL
GO
DELETE SCR2.dbo.SC_AlertFact_Table
GO
INSERT INTO SCR2.dbo.SC_AlertFact_Table ([AlertDescription],[AlertID],[AlertID_PK],[AlertLevel_FK],[AlertName],[AlertResolutionState_FK],[Computer_FK],[ConfigurationGroup_FK],[Culprit],[DateAdded_FK],[DateOfFirstEvent_FK],[DateOfLastEvent_FK],[DateRaised_FK],[DateTimeAdded],[DateTimeLastModified],[DateTimeOfFirstEvent],[DateTimeOfLastEvent],[DateTimeRaised],[DateTimeResolved],[DateTimeStateModified],[LocalDateAdded_FK],[LocalDateRaised_FK],[LocalDateTimeAdded],[LocalDateTimeRaised],[LocalDateTimeResolved],[LocalTimeAdded_FK],[LocalTimeRaised_FK],[ProcessRule_FK],[RepeatCount],[SMC_InstanceID],[TimeAdded_FK],[TimeOfFirstEvent_FK],[TimeOfLastEvent_FK],[TimeRaised_FK],[UserResolvedBy_FK])
SELECT [AlertDescription],[AlertID],[AlertID_PK],[AlertLevel_FK],[AlertName],[AlertResolutionState_FK],[Computer_FK],[ConfigurationGroup_FK],[Culprit],[DateAdded_FK],[DateOfFirstEvent_FK],[DateOfLastEvent_FK],[DateRaised_FK],[DateTimeAdded],[DateTimeLastModified],[DateTimeOfFirstEvent],[DateTimeOfLastEvent],[DateTimeRaised],[DateTimeResolved],[DateTimeStateModified],[LocalDateAdded_FK],[LocalDateRaised_FK],[LocalDateTimeAdded],[LocalDateTimeRaised],[LocalDateTimeResolved],[LocalTimeAdded_FK],[LocalTimeRaised_FK],[ProcessRule_FK],[RepeatCount],[SMC_InstanceID],[TimeAdded_FK],[TimeOfFirstEvent_FK],[TimeOfLastEvent_FK],[TimeRaised_FK],[UserResolvedBy_FK] FROM SystemCenterReporting.dbo.SC_AlertFact_Table WHERE [DateTimeLastModified] >= GetDate()-90
GO
SET IDENTITY_INSERT SCR2.dbo.SC_AlertFact_Table OFF
GO