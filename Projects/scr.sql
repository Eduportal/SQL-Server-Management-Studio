--------------------------------------------------------------------------------
-- Embarcadero DB Change Manager Synchronization Script
-- FILE                : Alter DDL for SEAFRESQLMOMRP ( vs SEAFRESQLMOMRP )
-- DATE                : Jun 17, 2010 12:17:53 PM
-- 
-- SOURCE DATA SOURCE  : SEAFRESQLMOMRP
-- TARGET DATA SOURCE  : SEAFRESQLMOMRP
--------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.ClassIndexes') AND name=N'smc_idx_ClassIndex_ClassID')
BEGIN
    DROP INDEX dbo.ClassIndexes.smc_idx_ClassIndex_ClassID
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.ClassIndexes') AND name=N'smc_idx_ClassIndex_ClassID')
        PRINT N'<<< FAILED DROPPING INDEX dbo.ClassIndexes.smc_idx_ClassIndex_ClassID >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.ClassIndexes.smc_idx_ClassIndex_ClassID >>>'
END
go


ALTER TABLE dbo.ClassIndexesColumns
    DROP CONSTRAINT smc_fk_ClassIndexesColumns_ClassIndexes
go


ALTER TABLE dbo.ClassIndexes
    DROP CONSTRAINT smc_pk_ClassIndexes
go


ALTER TABLE dbo.ClassIndexes
    DROP CONSTRAINT smc_idx_ClassIndexes_ClassID_IndexName_Unique
go


ALTER TABLE dbo.ClassIndexes
    DROP CONSTRAINT smc_fk_ClassIndexes_ClassSchemas
go


ALTER TABLE dbo.ClassIndexes
    DROP CONSTRAINT smc_fk_ClassIndexes_FileGroups
go


ALTER TABLE dbo.ClassIndexes
    DROP CONSTRAINT smc_chk_ClassIndexes_FillFactor
go


DROP PROCEDURE dbo.SMC_Meta_DeleteClass
go


DROP TRIGGER dbo.triu_ClassIndexes_Validate
go


DROP TRIGGER dbo.triud_ClassIndexes_Signed
go


DROP TRIGGER dbo.triu_ClassIndexesColumns_Validate
go


DROP TRIGGER dbo.triud_ClassIndexesColumns_Signed
go


EXEC sp_rename 'dbo.DF_ClassIndexes_CI_Clustered','dbo.DF_ClassIndexes_CI_Clustered_d8caee60'
go


EXEC sp_rename 'dbo.DF_ClassIndexes_CI_Unique','dbo.DF_ClassIndexes_CI_Unique_ac2e1f21'
go


EXEC sp_rename 'dbo.DF_ClassIndexes_CI_FillFactor','dbo.DF_ClassIndexes_CI_FillFactor_d6379572'
go


EXEC sp_rename 'dbo.DF_ClassIndexes_CI_System','dbo.DF_ClassIndexes_CI_System_08389370'
go


EXEC sp_rename N'dbo.ClassIndexes',N'ClassIndexes_21924dfd',N'OBJECT'
go


ALTER TABLE dbo.ClassIndexesColumns
    DROP CONSTRAINT smc_pk_ClassIndexesColumns
go


ALTER TABLE dbo.ClassIndexesColumns
    DROP CONSTRAINT smc_fk_ClassIndexesColumns_ClassProperties
go


EXEC sp_rename 'dbo.DF_ClassIndexesColumns_CI_Ascending','dbo.DF_ClassIndexesColumns_CI_Ascending_95acf3b1'
go


EXEC sp_rename 'dbo.DF_ClassIndexesColumns_CIC_System','dbo.DF_ClassIndexesColumns_CIC_System_dcf9fd48'
go


EXEC sp_rename N'dbo.ClassIndexesColumns',N'ClassIndexesColumns_4409022b',N'OBJECT'
go


ALTER TABLE dbo.PropertyInstances
    DROP CONSTRAINT smc_fk_PropertyInstances_ClassInstances
go


ALTER TABLE dbo.RelationshipInstances
    DROP CONSTRAINT smc_fk_InstanceRelationships_ClassInstances_
go


ALTER TABLE dbo.RelationshipInstances
    DROP CONSTRAINT smc_fk_InstanceRelationships_ClassInstances_Source
go


ALTER TABLE dbo.ClassInstances
    DROP CONSTRAINT smc_pk_ClassInstances_InstanceID
go


ALTER TABLE dbo.ClassInstances
    DROP CONSTRAINT smc_fk_ClassInstances_ClassSchemas
go


ALTER TABLE dbo.ClassInstances
    DROP CONSTRAINT smc_fk_ClassInstances_Modifications_CreationID
go


DROP FUNCTION dbo.SMC_GroupsForInstance
go


DROP FUNCTION dbo.SMC_MembersInGroup
go


DROP PROCEDURE dbo.SMC_AddMembersToGroup
go


DROP TRIGGER dbo.triud_ClassInstances_History
go


DROP TRIGGER dbo.triu_RelationshipInstances_CheckConstraints
go


DROP TRIGGER dbo.tri_SMC_GroupMembers
go


DROP TRIGGER dbo.tru_SMC_GroupMembers
go


EXEC sp_rename 'dbo.DF_ClassInstances_CI_InstanceID','dbo.DF_ClassInstances_CI_InstanceID_62ef215b'
go


EXEC sp_rename N'dbo.ClassInstances',N'ClassInstances_47eb57f2',N'OBJECT'
go


ALTER TABLE dbo.ClassInstancesAudits
    DROP CONSTRAINT PK_ClassInstancesAudits
go


ALTER TABLE dbo.ClassInstancesAudits
    DROP CONSTRAINT smc_fk_ClassInstancesAudits_ClassSchemas
go


ALTER TABLE dbo.ClassInstancesAudits
    DROP CONSTRAINT smc_fk_ClassInstancesAudits_Modifications_ArchivedID
go


ALTER TABLE dbo.ClassInstancesAudits
    DROP CONSTRAINT smc_fk_ClassInstancesAudits_Modifications_CreationID
go


EXEC sp_rename 'dbo.DF__ClassInst__CIA_S__108B795B','dbo.DF__ClassInst__CIA_S__108B795B_f92822fb'
go


EXEC sp_rename N'dbo.ClassInstancesAudits',N'ClassInstancesAudits_33e6793d',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.ClassMethods') AND name=N'smc_idx_ClassMethods_ClassID')
BEGIN
    DROP INDEX dbo.ClassMethods.smc_idx_ClassMethods_ClassID
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.ClassMethods') AND name=N'smc_idx_ClassMethods_ClassID')
        PRINT N'<<< FAILED DROPPING INDEX dbo.ClassMethods.smc_idx_ClassMethods_ClassID >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.ClassMethods.smc_idx_ClassMethods_ClassID >>>'
END
go


ALTER TABLE dbo.MethodParameterDefinitions
    DROP CONSTRAINT smc_fk_MethodParameterDefinitions_ClassMethods
go


ALTER TABLE dbo.ClassMethods
    DROP CONSTRAINT smc_pk_ClassMethods_MethodID
go


ALTER TABLE dbo.ClassMethods
    DROP CONSTRAINT IX_Methods
go


ALTER TABLE dbo.ClassMethods
    DROP CONSTRAINT smc_fk_ClassMethods_ClassSchemas
go


ALTER TABLE dbo.ClassMethods
    DROP CONSTRAINT smc_fk_ClassMethods_DllDefinitions
go


EXEC sp_rename 'dbo.DF_ClassMethods_CM_MethodID','dbo.DF_ClassMethods_CM_MethodID_57402ede'
go


EXEC sp_rename 'dbo.DF_ClassMethods_CM_IsStatic','dbo.DF_ClassMethods_CM_IsStatic_e4f332cd'
go


EXEC sp_rename N'dbo.ClassMethods',N'ClassMethods_1b66045d',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.ClassProperties') AND name=N'smc_idx_ClassProperty_ClassID')
BEGIN
    DROP INDEX dbo.ClassProperties.smc_idx_ClassProperty_ClassID
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.ClassProperties') AND name=N'smc_idx_ClassProperty_ClassID')
        PRINT N'<<< FAILED DROPPING INDEX dbo.ClassProperties.smc_idx_ClassProperty_ClassID >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.ClassProperties.smc_idx_ClassProperty_ClassID >>>'
END
go


ALTER TABLE dbo.PropertyInstances
    DROP CONSTRAINT smc_fk_PropertyInstances_ClassProperties
go


ALTER TABLE dbo.PropertyInstancesAudits
    DROP CONSTRAINT smc_fk_PropertyInstancesAudits_ClassProperties
go


ALTER TABLE dbo.SMO_ClassProperties
    DROP CONSTRAINT smc_fk_SMO_ClassProperties_ClassProperties_SMCClassPropertyID
go


ALTER TABLE dbo.SMO_RelationshipTypes
    DROP CONSTRAINT smc_fk_SMO_RelationshipTypes_ClassProperties_SMCSourceClassProperty
go


ALTER TABLE dbo.SMO_RelationshipTypes
    DROP CONSTRAINT smc_fk_SMO_RelationshipTypes_ClassProperties_SMCTargetClassProperty
go


ALTER TABLE dbo.WarehouseClassProperty
    DROP CONSTRAINT smc_fk_WarehouseClassProperty_ClassPropertyID
go


ALTER TABLE dbo.WrapperColumns
    DROP CONSTRAINT smc_fk_WrapperColumns_ClassProperties
go


ALTER TABLE dbo.ClassProperties
    DROP CONSTRAINT smc_pk_ClassProperties_ClassPropertyID
go


ALTER TABLE dbo.ClassProperties
    DROP CONSTRAINT smc_fk_ClassProperties_ClassSchemas
go


ALTER TABLE dbo.ClassProperties
    DROP CONSTRAINT smc_fk_ClassProperties_PropertyTypes
go


ALTER TABLE dbo.ClassProperties
    DROP CONSTRAINT smc_chk_ClassProperties_PK_NOT_NULLABLE
go


DROP PROCEDURE dbo.SMC_GetGuidColumns
go


DROP PROCEDURE dbo.SMC_Meta_CreateHighVolumeViews
go


DROP PROCEDURE dbo.SMC_Meta_Sign_ClassSchema
go


DROP PROCEDURE dbo.smc_add_property_to_wrapper
go


DROP PROCEDURE dbo.smc_class_info
go


DROP TRIGGER dbo.triu_ClassProperties_UniqueNamesInClass
go


DROP TRIGGER dbo.triu_ClassProperties_ValidateDefaultValue
go


DROP TRIGGER dbo.triud_ClassProperties_Signed
go


DROP TRIGGER dbo.triud_ClassProperties_ViewInvalid
go


DROP TRIGGER dbo.tri_ClassSchemas_SMCInstanceID
go


DROP TRIGGER dbo.triu_ClassSchemas_Groups
go


DROP TRIGGER dbo.triu_RelationshipConstraints_CheckNotHighVolume
go


EXEC sp_rename 'dbo.DF_ClassProperties_CP_PrimaryKey','dbo.DF_ClassProperties_CP_PrimaryKey_459ccc67'
go


EXEC sp_rename 'dbo.DF_ClassProperties_CP_Nullable','dbo.DF_ClassProperties_CP_Nullable_842fd639'
go


EXEC sp_rename 'dbo.DF_ClassProperties_CP_IsInherited','dbo.DF_ClassProperties_CP_IsInherited_fb20f7e7'
go


EXEC sp_rename 'dbo.DF_ClassProperties_CP_System','dbo.DF_ClassProperties_CP_System_caaf5822'
go


EXEC sp_rename 'dbo.DF_ClassProperties_CP_IsIdentity','dbo.DF_ClassProperties_CP_IsIdentity_4ce3d509'
go


EXEC sp_rename N'dbo.ClassProperties',N'ClassProperties_ba1fe774',N'OBJECT'
go


ALTER TABLE dbo.ClassRelationships
    DROP CONSTRAINT smc_pk_ClassRelationships
go


ALTER TABLE dbo.ClassRelationships
    DROP CONSTRAINT smc_fk_ClassRelationships_ClassSchemas_SourceClassID
go


ALTER TABLE dbo.ClassRelationships
    DROP CONSTRAINT smc_fk_ClassRelationships_ClassSchemas_TargetClassID
go


EXEC sp_rename 'dbo.DF_ClassRelationships_CR_RelationshipID','dbo.DF_ClassRelationships_CR_RelationshipID_01b1605c'
go


EXEC sp_rename 'dbo.DF_ClassRelationships_CR_System','dbo.DF_ClassRelationships_CR_System_b290ceb5'
go


EXEC sp_rename N'dbo.ClassRelationships',N'ClassRelationships_5000c1c6',N'OBJECT'
go


ALTER TABLE dbo.ClassSchemaPartitions
    DROP CONSTRAINT PK_ClassSchemaPartitions
go


ALTER TABLE dbo.ClassSchemaPartitions
    DROP CONSTRAINT smc_idx_ClassSchemaPartitions_ID_ClassID_Unique
go


ALTER TABLE dbo.ClassSchemaPartitions
    DROP CONSTRAINT smc_fk_ClassSchemaPartitions_ClassSchemas
go


ALTER TABLE dbo.ClassSchemaPartitions
    DROP CONSTRAINT smc_chk_ClassSchemaPartitions_ID
go


DROP FUNCTION dbo.SMC_Internal_DBHasUniqueObjectNames
go


DROP PROCEDURE dbo.smc_grooming
go


DROP PROCEDURE dbo.smc_partition_class
go


DROP TRIGGER dbo.triud_ClassSchemaPartitions_Current
go


EXEC sp_rename 'dbo.DF_ClassSchemaPartitions_CSP_DTSDone','dbo.DF_ClassSchemaPartitions_CSP_DTSDone_ea17d56a'
go


EXEC sp_rename 'dbo.DF_ClassSchemaPartitions_CSP_Current','dbo.DF_ClassSchemaPartitions_CSP_Current_0a6b54e4'
go


EXEC sp_rename N'dbo.ClassSchemaPartitions',N'ClassSchemaPartitions_d4446ea8',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.ClassSchemas') AND name=N'smc_idx_ClassSchema_ClassName')
BEGIN
    DROP INDEX dbo.ClassSchemas.smc_idx_ClassSchema_ClassName
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.ClassSchemas') AND name=N'smc_idx_ClassSchema_ClassName')
        PRINT N'<<< FAILED DROPPING INDEX dbo.ClassSchemas.smc_idx_ClassSchema_ClassName >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.ClassSchemas.smc_idx_ClassSchema_ClassName >>>'
END
go


ALTER TABLE dbo.ClassSchemas
    DROP CONSTRAINT smc_fk_ClassSchemas_ClassSchemas_InheritsFrom
go


ALTER TABLE dbo.ClassSchemas
    DROP CONSTRAINT smc_fk_ClassSchemas_ClassSchemas_ParentClassID
go


ALTER TABLE dbo.PropertyInstancesAudits
    DROP CONSTRAINT smc_fk_PropertyInstancesAudits_ClassSchemas
go


ALTER TABLE dbo.RelationshipConstraints
    DROP CONSTRAINT smc_fk_RelationshipConstraints_ClassSchemas_SourceClassID
go


ALTER TABLE dbo.RelationshipConstraints
    DROP CONSTRAINT smc_fk_RelationshipConstraints_ClassSchemas_TargetClassID
go


ALTER TABLE dbo.SMO_ClassSMCClasses
    DROP CONSTRAINT smc_fk_SMO_ClassSMCClasses_ClassSchemas
go


ALTER TABLE dbo.SMO_RelationshipTargets
    DROP CONSTRAINT smc_fk_SMO_RelationshipTargets_ClassSchemas_TargetSMCClassID
go


ALTER TABLE dbo.WarehouseClassSchema
    DROP CONSTRAINT smc_fk_WarehouseClassSchema_ClassID
go


ALTER TABLE dbo.WarehouseClassSchemaToProductSchema
    DROP CONSTRAINT smc_fk_WarehouseClassSchemaToProductSchema_ClassID
go


ALTER TABLE dbo.WarehouseGroomingInfo
    DROP CONSTRAINT smc_fk_WarehouseGroomingInfo_ClassID
go


ALTER TABLE dbo.WrapperSchemas
    DROP CONSTRAINT smc_fk_WrapperSchemas_ClassSchemas
go


ALTER TABLE dbo.ClassSchemas
    DROP CONSTRAINT smc_pk_ClassSchemas_ClassID
go


ALTER TABLE dbo.ClassSchemas
    DROP CONSTRAINT smc_fk_ClassSchemas_FileGroups
go


ALTER TABLE dbo.ClassSchemas
    DROP CONSTRAINT smc_fk_ClassSchemas_FileGroups1
go


ALTER TABLE dbo.ClassSchemas
    DROP CONSTRAINT smc_fk_ClassSchemas_Modifications
go


ALTER TABLE dbo.ClassSchemas
    DROP CONSTRAINT smc_chk_ClassSchemas_CheckHighVolume
go


ALTER TABLE dbo.ClassSchemas
    DROP CONSTRAINT smc_chk_ClassSchemas_ClassID_NOTEQUAL_ParentClassID_InheritsFrom
go


ALTER TABLE dbo.ClassSchemas
    DROP CONSTRAINT smc_chk_ClassSchemas_InsertViewName
go


ALTER TABLE dbo.ClassSchemas
    DROP CONSTRAINT smc_chk_ClassSchemas_SupportsPartitions
go


ALTER TABLE dbo.ClassSchemas
    DROP CONSTRAINT smc_chk_ClassSchemas_ValidateSPs
go


DROP PROCEDURE dbo.SMC_GetAllChangesForClass
go


DROP PROCEDURE dbo.smc_dropinvalid
go


DROP PROCEDURE dbo.smc_generate_wrapper_for_class
go


DROP TRIGGER dbo.triu_ClassSchemas_CheckIsHighVolume
go


DROP TRIGGER dbo.triu_ClassSchemas_CheckValidationSPs
go


DROP TRIGGER dbo.triu_ClassSchemas_PopulateNames
go


DROP TRIGGER dbo.tru_ClassSchemas_ViewInvalid
go


DROP TRIGGER dbo.trud_ClassSchemas_Signed
go


DROP TRIGGER dbo.triu_RelationshipTypes_Validate
go


EXEC sp_rename 'dbo.DF_ClassSchemas_CS_ClassID','dbo.DF_ClassSchemas_CS_ClassID_4293959e'
go


EXEC sp_rename 'dbo.DF_ClassSchemas_CS_IsGroup','dbo.DF_ClassSchemas_CS_IsGroup_d7eb8077'
go


EXEC sp_rename 'dbo.DF_ClassSchemas_CS_Signed','dbo.DF_ClassSchemas_CS_Signed_d736275b'
go


EXEC sp_rename 'dbo.DF_ClassSchemas_CS_NotifyInsert','dbo.DF_ClassSchemas_CS_NotifyInsert_58c16987'
go


EXEC sp_rename 'dbo.DF_ClassSchemas_CS_NotifyUpdate','dbo.DF_ClassSchemas_CS_NotifyUpdate_2636c01c'
go


EXEC sp_rename 'dbo.DF_ClassSchemas_CS_NotifyDelete','dbo.DF_ClassSchemas_CS_NotifyDelete_1ee2b92a'
go


EXEC sp_rename 'dbo.DF_ClassSchemas_CS_ClassDeleted','dbo.DF_ClassSchemas_CS_ClassDeleted_8e82a5f5'
go


EXEC sp_rename 'dbo.DF_ClassSchemas_CS_SingleTable','dbo.DF_ClassSchemas_CS_SingleTable_cd0b5d05'
go


EXEC sp_rename 'dbo.DF_ClassSchemas_CS_System','dbo.DF_ClassSchemas_CS_System_b830340e'
go


EXEC sp_rename 'dbo.DF_ClassSchemas_CS_IsHighVolume','dbo.DF_ClassSchemas_CS_IsHighVolume_dd793109'
go


EXEC sp_rename 'dbo.DF_ClassSchemas_CS_GenerateHistory','dbo.DF_ClassSchemas_CS_GenerateHistory_79968f52'
go


EXEC sp_rename 'dbo.DF_ClassSchemas_CS_GenerateView','dbo.DF_ClassSchemas_CS_GenerateView_b9192fb5'
go


EXEC sp_rename 'dbo.DF_ClassSchemas_CS_SupportsPartitions','dbo.DF_ClassSchemas_CS_SupportsPartitions_fa5d82ca'
go


EXEC sp_rename 'dbo.DF_ClassSchemas_CS_ViewInvalid','dbo.DF_ClassSchemas_CS_ViewInvalid_0881f942'
go


EXEC sp_rename N'dbo.ClassSchemas',N'ClassSchemas_48c92478',N'OBJECT'
go


ALTER TABLE dbo.PropertyTypes
    DROP CONSTRAINT smc_fk_PropertyTypes_DatatypeDefinitions
go


ALTER TABLE dbo.ValidationUDFParameters
    DROP CONSTRAINT smc_fk_ValidationUDFParameters_DatatypeDefinitions
go


ALTER TABLE dbo.DatatypeDefinitions
    DROP CONSTRAINT smc_pk_DatatypeDefinitions
go


ALTER TABLE dbo.DatatypeDefinitions
    DROP CONSTRAINT CK_DatatypeDefinitions
go


DROP TRIGGER dbo.triu_PropertyTypes_DatatypeUsage
go


DROP TRIGGER dbo.triu_ValidationUDFParameterValues_ValidateValue
go


EXEC sp_rename 'dbo.DF_DatatypeDefinitions_DD_SupportsLength','dbo.DF_DatatypeDefinitions_DD_SupportsLength_a0e6adda'
go


EXEC sp_rename 'dbo.DF_DatatypeDefinitions_DD_SupportsScalePrecision','dbo.DF_DatatypeDefinitions_DD_SupportsScalePrecision_2ee27e72'
go


EXEC sp_rename 'dbo.DF_DatatypeDefinitions_DD_VariableLength','dbo.DF_DatatypeDefinitions_DD_VariableLength_8486185f'
go


EXEC sp_rename 'dbo.DF_DatatypeDefinitions_DD_MaxLength','dbo.DF_DatatypeDefinitions_DD_MaxLength_9fea9a38'
go


EXEC sp_rename 'dbo.DF_DatatypeDefinitions_DD_IsBlob','dbo.DF_DatatypeDefinitions_DD_IsBlob_396852f3'
go


EXEC sp_rename N'dbo.DatatypeDefinitions',N'DatatypeDefinitions_7d162e19',N'OBJECT'
go


ALTER TABLE dbo.DllDefinitions
    DROP CONSTRAINT smc_pk_DllDefinitions_DllID
go


EXEC sp_rename 'dbo.DF_DllDefinitions_DD_DllID','dbo.DF_DllDefinitions_DD_DllID_bf3a82a9'
go


EXEC sp_rename N'dbo.DllDefinitions',N'DllDefinitions_22833156',N'OBJECT'
go


ALTER TABLE dbo.EventsQueue
    DROP CONSTRAINT PK_EventsQueue
go


ALTER TABLE dbo.EventsQueue
    DROP CONSTRAINT smc_chk_EventQueue_Action
go


EXEC sp_rename N'dbo.EventsQueue',N'EventsQueue_bdeda739',N'OBJECT'
go


ALTER TABLE dbo.FileGroups
    DROP CONSTRAINT smc_pk_FileGroups
go


EXEC sp_rename N'dbo.FileGroups',N'FileGroups_2c1707cf',N'OBJECT'
go


ALTER TABLE dbo.GroomingSettings
    DROP CONSTRAINT smc_chk_GroomingSettings_LiveDataPeriod
go


DROP TRIGGER dbo.triud_GroomingSettings_RowCount
go


EXEC sp_rename N'dbo.GroomingSettings',N'GroomingSettings_0fb9f48d',N'OBJECT'
go


ALTER TABLE dbo.MetaVersion
    DROP CONSTRAINT PK_SMC_MetaVersion
go


EXEC sp_rename 'dbo.DF_SMC_MetaVersion_MV_MinorVersion','dbo.DF_SMC_MetaVersion_MV_MinorVersion_5d01246d'
go


EXEC sp_rename N'dbo.MetaVersion',N'MetaVersion_9dbc24b5',N'OBJECT'
go


ALTER TABLE dbo.MethodParameterDefinitions
    DROP CONSTRAINT smc_pk_MethodParameterDefinitions_MethodID_Order
go


ALTER TABLE dbo.MethodParameterDefinitions
    DROP CONSTRAINT smc_fk_MethodParameterDefinitions_MethodParameterTypes
go


ALTER TABLE dbo.MethodParameterDefinitions
    DROP CONSTRAINT CK_MethodParameterDefinitions
go


EXEC sp_rename N'dbo.MethodParameterDefinitions',N'MethodParameterDefinitions_ec02e7df',N'OBJECT'
go


ALTER TABLE dbo.MethodParameterTypes
    DROP CONSTRAINT smc_pk_MethodParameterTypes_ParameterTypeID
go


EXEC sp_rename N'dbo.MethodParameterTypes',N'MethodParameterTypes_eb73f48c',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.Modifications') AND name=N'smc_idx_Modifications_TransactionToken')
BEGIN
    DROP INDEX dbo.Modifications.smc_idx_Modifications_TransactionToken
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.Modifications') AND name=N'smc_idx_Modifications_TransactionToken')
        PRINT N'<<< FAILED DROPPING INDEX dbo.Modifications.smc_idx_Modifications_TransactionToken >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.Modifications.smc_idx_Modifications_TransactionToken >>>'
END
go


ALTER TABLE dbo.PropertyInstances
    DROP CONSTRAINT smc_fk_PropertyInstances_Modifications
go


ALTER TABLE dbo.PropertyInstancesAudits
    DROP CONSTRAINT smc_fk_PropertyInstancesAudits_Modifications_ArchivedID
go


ALTER TABLE dbo.PropertyInstancesAudits
    DROP CONSTRAINT smc_fk_PropertyInstancesAudits_Modifications_CreationID
go


ALTER TABLE dbo.PropertyTypes
    DROP CONSTRAINT smc_fk_PropertyTypes_Modifications
go


ALTER TABLE dbo.RelationshipInstances
    DROP CONSTRAINT smc_fk_InstanceRelationships_Modifications
go


ALTER TABLE dbo.RelationshipInstancesAudits
    DROP CONSTRAINT smc_fk_InstanceRelationshipsAudits_Modifications_ArchivedID
go


ALTER TABLE dbo.RelationshipInstancesAudits
    DROP CONSTRAINT smc_fk_InstanceRelationshipsAudits_Modifications_CreationID
go


ALTER TABLE dbo.RelationshipTypes
    DROP CONSTRAINT smc_fk_RelationshipTypes_Modifications
go


ALTER TABLE dbo.ValidationUDFs
    DROP CONSTRAINT smc_fk_ValidationUDFs_Modifications
go


ALTER TABLE dbo.Modifications
    DROP CONSTRAINT PK_Modifications_ModificationID
go


ALTER TABLE dbo.Modifications
    DROP CONSTRAINT smc_fk_Modifications_Users
go


DROP PROCEDURE dbo.SMC_GetModificationID
go


DROP PROCEDURE dbo.SMC_Meta_Sign_PropertyType
go


DROP PROCEDURE dbo.SMC_Meta_Sign_RelationshipType
go


DROP PROCEDURE dbo.SMC_Meta_Sign_ValidationUDF
go


DROP PROCEDURE dbo.smc_internal_getmodificationid
go


EXEC sp_rename N'dbo.Modifications',N'Modifications_2582a466',N'OBJECT'
go


ALTER TABLE dbo.WarehouseClassSchemaToProductSchema
    DROP CONSTRAINT smc_fk_WarehouseClassSchemaToProductSchema_ProductID
go


ALTER TABLE dbo.ProductSchema
    DROP CONSTRAINT smc_pk_ProductSchema_ProductID
go


EXEC sp_rename N'dbo.ProductSchema',N'ProductSchema_9a0f6057',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.PropertyInstances') AND name=N'smc_idx_PropertyInstances_InstanceID')
BEGIN
    DROP INDEX dbo.PropertyInstances.smc_idx_PropertyInstances_InstanceID
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.PropertyInstances') AND name=N'smc_idx_PropertyInstances_InstanceID')
        PRINT N'<<< FAILED DROPPING INDEX dbo.PropertyInstances.smc_idx_PropertyInstances_InstanceID >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.PropertyInstances.smc_idx_PropertyInstances_InstanceID >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.PropertyInstances') AND name=N'smc_idx_PropertyInstances_PropertyID')
BEGIN
    DROP INDEX dbo.PropertyInstances.smc_idx_PropertyInstances_PropertyID
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.PropertyInstances') AND name=N'smc_idx_PropertyInstances_PropertyID')
        PRINT N'<<< FAILED DROPPING INDEX dbo.PropertyInstances.smc_idx_PropertyInstances_PropertyID >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.PropertyInstances.smc_idx_PropertyInstances_PropertyID >>>'
END
go


ALTER TABLE dbo.PropertyInstances
    DROP CONSTRAINT smc_fk_PropertyInstances_ClassID_InstanceID_ClassPropertyID
go


DROP TRIGGER dbo.triud_PropertyInstances_History
go


EXEC sp_rename N'dbo.PropertyInstances',N'PropertyInstances_35cb1d88',N'OBJECT'
go


ALTER TABLE dbo.PropertyInstancesAudits
    DROP CONSTRAINT PK_PropertyInstancesAudits
go


EXEC sp_rename 'dbo.DF__PropertyI__PIA_S__20C1E124','dbo.DF__PropertyI__PIA_S__20C1E124_72e540a4'
go


EXEC sp_rename N'dbo.PropertyInstancesAudits',N'PropertyInstancesAudits_eff481f7',N'OBJECT'
go


ALTER TABLE dbo.PropertyTypeEnumerations
    DROP CONSTRAINT smc_pk_PropertyTypeEnumerations
go


ALTER TABLE dbo.PropertyTypeEnumerations
    DROP CONSTRAINT smc_idx_PropertyTypeEnumerations_PropType_Value_Unique
go


ALTER TABLE dbo.PropertyTypeEnumerations
    DROP CONSTRAINT smc_fk_PropertyTypeEnumerations_PropertyTypes
go


DROP PROCEDURE dbo.SMC_Meta_DeletePropertyType
go


DROP TRIGGER dbo.triud_PropertyTypeEnumerations_Signed
go


EXEC sp_rename N'dbo.PropertyTypeEnumerations',N'PropertyTypeEnumerations_fb681fcf',N'OBJECT'
go


ALTER TABLE dbo.PropertyTypes
    DROP CONSTRAINT smc_fk_PropertyTypes_PropertyTypes_ParentTypeID
go


ALTER TABLE dbo.SMO_TypeConversions
    DROP CONSTRAINT smc_fk_SMO_TypeConversions_PropertyTypes_TypeID
go


ALTER TABLE dbo.ValidationUDFParameterValues
    DROP CONSTRAINT smc_fk_ValidationUDFValues_PropertyTypes
go


ALTER TABLE dbo.PropertyTypes
    DROP CONSTRAINT smc_pk_PropertyTypes_TypeID
go


ALTER TABLE dbo.PropertyTypes
    DROP CONSTRAINT smc_fk_PropertyTypes_ValidationUDFs
go


ALTER TABLE dbo.PropertyTypes
    DROP CONSTRAINT smc_chk_PropertyTypes_EnumDatatype_is_int
go


ALTER TABLE dbo.PropertyTypes
    DROP CONSTRAINT smc_chk_PropertyTypes_Enumeration_No_UDF
go


ALTER TABLE dbo.PropertyTypes
    DROP CONSTRAINT smc_chk_PropertyTypes_PropertyID_NOTEQUAL_ParentPropertyID
go


ALTER TABLE dbo.PropertyTypes
    DROP CONSTRAINT smc_chk_PropertyTypes_ScalePrecision_Range
go


DROP TRIGGER dbo.trud_PropertyTypes_Signed
go


DROP TRIGGER dbo.triud_ValidationUDFParameterValues_Signed
go


EXEC sp_rename 'dbo.DF_PropertySchemas_PS_PropertyID','dbo.DF_PropertySchemas_PS_PropertyID_c663a31b'
go


EXEC sp_rename 'dbo.DF_PropertyTypes_PT_Length','dbo.DF_PropertyTypes_PT_Length_8bd710ee'
go


EXEC sp_rename 'dbo.DF_PropertyTypes_PT_Scale','dbo.DF_PropertyTypes_PT_Scale_982bd4bc'
go


EXEC sp_rename 'dbo.DF_PropertyTypes_PT_Precision','dbo.DF_PropertyTypes_PT_Precision_60984c6b'
go


EXEC sp_rename 'dbo.DF_PropertyTypes_PT_IsEnumeration','dbo.DF_PropertyTypes_PT_IsEnumeration_9c648d0d'
go


EXEC sp_rename 'dbo.DF_PropertySchemas_PS_Deleted','dbo.DF_PropertySchemas_PS_Deleted_8563ee80'
go


EXEC sp_rename 'dbo.DF_PropertySchemas_PS_System','dbo.DF_PropertySchemas_PS_System_47b74a53'
go


EXEC sp_rename 'dbo.DF_PropertySchemas_PS_Signed','dbo.DF_PropertySchemas_PS_Signed_672df651'
go


EXEC sp_rename N'dbo.PropertyTypes',N'PropertyTypes_0522b909',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.RelationshipConstraints') AND name=N'smx_idx_RelationshipConstraints_RelTypeID')
BEGIN
    DROP INDEX dbo.RelationshipConstraints.smx_idx_RelationshipConstraints_RelTypeID
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.RelationshipConstraints') AND name=N'smx_idx_RelationshipConstraints_RelTypeID')
        PRINT N'<<< FAILED DROPPING INDEX dbo.RelationshipConstraints.smx_idx_RelationshipConstraints_RelTypeID >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.RelationshipConstraints.smx_idx_RelationshipConstraints_RelTypeID >>>'
END
go


ALTER TABLE dbo.RelationshipConstraints
    DROP CONSTRAINT PK_RelationshipConstraints
go


ALTER TABLE dbo.RelationshipConstraints
    DROP CONSTRAINT smc_fk_RelationshipConstraints_RelationshipTypes
go


DROP PROCEDURE dbo.SMC_Meta_DeleteRelationshipType
go


DROP TRIGGER dbo.triu_RelationshipConstraints_Validate
go


DROP TRIGGER dbo.triud_RelationshipConstraints_ViewInvalid
go


DROP TRIGGER dbo.trud_RelationshipConstrainsts_Signed
go


EXEC sp_rename 'dbo.DF_RelationshipConstraints_RC_System','dbo.DF_RelationshipConstraints_RC_System_770b3ef6'
go


EXEC sp_rename N'dbo.RelationshipConstraints',N'RelationshipConstraints_0540f2b5',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.RelationshipInstances') AND name=N'smc_idx_InstanceRelationships_SourceInstanceID')
BEGIN
    DROP INDEX dbo.RelationshipInstances.smc_idx_InstanceRelationships_SourceInstanceID
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.RelationshipInstances') AND name=N'smc_idx_InstanceRelationships_SourceInstanceID')
        PRINT N'<<< FAILED DROPPING INDEX dbo.RelationshipInstances.smc_idx_InstanceRelationships_SourceInstanceID >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.RelationshipInstances.smc_idx_InstanceRelationships_SourceInstanceID >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.RelationshipInstances') AND name=N'smc_idx_InstanceRelationships_TargetInstanceID')
BEGIN
    DROP INDEX dbo.RelationshipInstances.smc_idx_InstanceRelationships_TargetInstanceID
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.RelationshipInstances') AND name=N'smc_idx_InstanceRelationships_TargetInstanceID')
        PRINT N'<<< FAILED DROPPING INDEX dbo.RelationshipInstances.smc_idx_InstanceRelationships_TargetInstanceID >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.RelationshipInstances.smc_idx_InstanceRelationships_TargetInstanceID >>>'
END
go


ALTER TABLE dbo.RelationshipInstances
    DROP CONSTRAINT smc_pk_InstanceRelationships
go


ALTER TABLE dbo.RelationshipInstances
    DROP CONSTRAINT smc_idx_RelationshipInstances_RelationshipID_Unique
go


ALTER TABLE dbo.RelationshipInstances
    DROP CONSTRAINT smc_fk_InstanceRelationships_RelationshipTypes
go


ALTER TABLE dbo.RelationshipInstances
    DROP CONSTRAINT smc_chk_RelationshipInstances_Usage
go


DROP TRIGGER dbo.tri_RelationshipInstances_EnforceCardinality
go


DROP TRIGGER dbo.triud_RelationshipInstances_History
go


DROP TRIGGER dbo.tru_RelationshipInstances_Validate
go


DROP TRIGGER dbo.trd_SMC_GroupMembers
go


EXEC sp_rename 'dbo.DF_InstanceRelationships_IR_RelationShipID','dbo.DF_InstanceRelationships_IR_RelationShipID_3e53f71f'
go


EXEC sp_rename 'dbo.DF_RelationshipInstances_RI_Usage','dbo.DF_RelationshipInstances_RI_Usage_5ee0d3af'
go


EXEC sp_rename N'dbo.RelationshipInstances',N'RelationshipInstances_40cdafc0',N'OBJECT'
go


ALTER TABLE dbo.RelationshipInstancesAudits
    DROP CONSTRAINT PK_RelationshipInstancesAudits
go


ALTER TABLE dbo.RelationshipInstancesAudits
    DROP CONSTRAINT smc_fk_InstanceRelationshipsAudits_RelationshipTypes
go


EXEC sp_rename 'dbo.DF__Relations__RIA_S__173876EA','dbo.DF__Relations__RIA_S__173876EA_1fbd7836'
go


EXEC sp_rename N'dbo.RelationshipInstancesAudits',N'RelationshipInstancesAudits_6770f36c',N'OBJECT'
go


ALTER TABLE dbo.SMO_ClassSMCClassJoins
    DROP CONSTRAINT smc_fk_SMO_ClassSMCClassJoins_RelationshipTypes_SMCRelationshipType
go


ALTER TABLE dbo.SMO_RelationshipTypes
    DROP CONSTRAINT smc_fk_SMO_RelationshipTypes_RelationshipTypes_SMCRelationshipTypeID
go


ALTER TABLE dbo.WrapperSchemas
    DROP CONSTRAINT smc_fk_WrapperSchemas_RelationshipTypes
go


ALTER TABLE dbo.RelationshipTypes
    DROP CONSTRAINT smc_pk_RelationshipTypes_Type
go


ALTER TABLE dbo.RelationshipTypes
    DROP CONSTRAINT smc_chk_RelationshipTypes_Cardinality
go


ALTER TABLE dbo.RelationshipTypes
    DROP CONSTRAINT smc_chk_RelationshipTypes_ViewSrcName_NotEqual_ViewTargetName
go


DROP PROCEDURE dbo.SMC_GetAllChangesForRelationshipType
go


DROP PROCEDURE dbo.smc_generate_wrapper_for_relationshiptype
go


DROP TRIGGER dbo.triu_RelationshipTypes_PopulateNames
go


DROP TRIGGER dbo.tru_RelationshipTypes_ViewInvalid
go


DROP TRIGGER dbo.trud_RelationshipTypes_Signed
go


EXEC sp_rename 'dbo.DF_RelationshipTypes_RT_Cardinality','dbo.DF_RelationshipTypes_RT_Cardinality_49ec3650'
go


EXEC sp_rename 'dbo.DF_RelationshipTypes_RT_IsStrong','dbo.DF_RelationshipTypes_RT_IsStrong_e9811f89'
go


EXEC sp_rename 'dbo.DF_RelationshipTypes_RT_IsConstrained_1','dbo.DF_RelationshipTypes_RT_IsConstrained_1_770c9827'
go


EXEC sp_rename 'dbo.DF_RelationshipTypes_RT_IsConstrained','dbo.DF_RelationshipTypes_RT_IsConstrained_e7da8728'
go


EXEC sp_rename 'dbo.DF_RelationshipTypes_RT_GenerateView','dbo.DF_RelationshipTypes_RT_GenerateView_cef37132'
go


EXEC sp_rename 'dbo.DF_RelationshipTypes_RT_NotifyOnInsert','dbo.DF_RelationshipTypes_RT_NotifyOnInsert_513a7019'
go


EXEC sp_rename 'dbo.DF_RelationshipTypes_RT_NotifyOnUpdate','dbo.DF_RelationshipTypes_RT_NotifyOnUpdate_c1a61a2d'
go


EXEC sp_rename 'dbo.DF_RelationshipTypes_RT_NotifyOnDelete','dbo.DF_RelationshipTypes_RT_NotifyOnDelete_e64120a2'
go


EXEC sp_rename 'dbo.DF_RelationshipTypes_RT_System','dbo.DF_RelationshipTypes_RT_System_e23fcba4'
go


EXEC sp_rename 'dbo.DF_RelationshipTypes_RT_Signed','dbo.DF_RelationshipTypes_RT_Signed_f4193cbf'
go


EXEC sp_rename 'dbo.DF_RelationshipTypes_RT_IsHighVolume','dbo.DF_RelationshipTypes_RT_IsHighVolume_6848c689'
go


EXEC sp_rename 'dbo.DF_RelationshipTypes_RT_ViewInvalid','dbo.DF_RelationshipTypes_RT_ViewInvalid_6ae92d2b'
go


EXEC sp_rename N'dbo.RelationshipTypes',N'RelationshipTypes_58836bba',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertFact_Table') AND name=N'AlertFact_AlertLevelFK_Index')
BEGIN
    DROP INDEX dbo.SC_AlertFact_Table.AlertFact_AlertLevelFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertFact_Table') AND name=N'AlertFact_AlertLevelFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_AlertFact_Table.AlertFact_AlertLevelFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_AlertFact_Table.AlertFact_AlertLevelFK_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertFact_Table') AND name=N'AlertFact_AlertName_Index')
BEGIN
    DROP INDEX dbo.SC_AlertFact_Table.AlertFact_AlertName_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertFact_Table') AND name=N'AlertFact_AlertName_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_AlertFact_Table.AlertFact_AlertName_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_AlertFact_Table.AlertFact_AlertName_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertFact_Table') AND name=N'AlertFact_ComputerFK_Index')
BEGIN
    DROP INDEX dbo.SC_AlertFact_Table.AlertFact_ComputerFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertFact_Table') AND name=N'AlertFact_ComputerFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_AlertFact_Table.AlertFact_ComputerFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_AlertFact_Table.AlertFact_ComputerFK_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertFact_Table') AND name=N'AlertFact_ConfigurationGroupFK_DateTimeAdded_Index')
BEGIN
    DROP INDEX dbo.SC_AlertFact_Table.AlertFact_ConfigurationGroupFK_DateTimeAdded_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertFact_Table') AND name=N'AlertFact_ConfigurationGroupFK_DateTimeAdded_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_AlertFact_Table.AlertFact_ConfigurationGroupFK_DateTimeAdded_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_AlertFact_Table.AlertFact_ConfigurationGroupFK_DateTimeAdded_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertFact_Table') AND name=N'AlertFact_LocalDateTimeRaised_Index')
BEGIN
    DROP INDEX dbo.SC_AlertFact_Table.AlertFact_LocalDateTimeRaised_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertFact_Table') AND name=N'AlertFact_LocalDateTimeRaised_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_AlertFact_Table.AlertFact_LocalDateTimeRaised_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_AlertFact_Table.AlertFact_LocalDateTimeRaised_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertFact_Table') AND name=N'AlertFact_LocalDateTimeResolved_Index')
BEGIN
    DROP INDEX dbo.SC_AlertFact_Table.AlertFact_LocalDateTimeResolved_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertFact_Table') AND name=N'AlertFact_LocalDateTimeResolved_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_AlertFact_Table.AlertFact_LocalDateTimeResolved_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_AlertFact_Table.AlertFact_LocalDateTimeResolved_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertFact_Table') AND name=N'AlertFact_ProcessRuleFK_Index')
BEGIN
    DROP INDEX dbo.SC_AlertFact_Table.AlertFact_ProcessRuleFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertFact_Table') AND name=N'AlertFact_ProcessRuleFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_AlertFact_Table.AlertFact_ProcessRuleFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_AlertFact_Table.AlertFact_ProcessRuleFK_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertFact_Table') AND name=N'AlertFact_SMCInstanceID_ClusteredIndex')
BEGIN
    DROP INDEX dbo.SC_AlertFact_Table.AlertFact_SMCInstanceID_ClusteredIndex
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertFact_Table') AND name=N'AlertFact_SMCInstanceID_ClusteredIndex')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_AlertFact_Table.AlertFact_SMCInstanceID_ClusteredIndex >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_AlertFact_Table.AlertFact_SMCInstanceID_ClusteredIndex >>>'
END
go


ALTER TABLE dbo.SC_AlertFact_Table
    DROP CONSTRAINT SC_AlertFact_Table_PK
go


EXEC sp_rename 'dbo.DF__SC_AlertF__Alert__50C5FA01','dbo.DF__SC_AlertF__Alert__50C5FA01_9c9235b8'
go


EXEC sp_rename 'dbo.DF__SC_AlertF__Alert__51BA1E3A','dbo.DF__SC_AlertF__Alert__51BA1E3A_c4bbf203'
go


EXEC sp_rename 'dbo.DF__SC_AlertF__DateT__52AE4273','dbo.DF__SC_AlertF__DateT__52AE4273_11971a07'
go


EXEC sp_rename 'dbo.DF__SC_AlertF__Local__53A266AC','dbo.DF__SC_AlertF__Local__53A266AC_c022f8bf'
go


EXEC sp_rename 'dbo.DF__SC_AlertF__Local__54968AE5','dbo.DF__SC_AlertF__Local__54968AE5_9433ebef'
go


EXEC sp_rename 'dbo.DF__SC_AlertF__Local__558AAF1E','dbo.DF__SC_AlertF__Local__558AAF1E_bf876f45'
go


EXEC sp_rename 'dbo.DF__SC_AlertF__Local__567ED357','dbo.DF__SC_AlertF__Local__567ED357_ad34ede8'
go


EXEC sp_rename 'dbo.DF__SC_AlertF__Local__5772F790','dbo.DF__SC_AlertF__Local__5772F790_77d98b6d'
go


EXEC sp_rename 'dbo.DF__SC_AlertF__Local__58671BC9','dbo.DF__SC_AlertF__Local__58671BC9_fdef7679'
go


EXEC sp_rename 'dbo.DF__SC_AlertF__UserR__595B4002','dbo.DF__SC_AlertF__UserR__595B4002_16ad288d'
go


EXEC sp_rename N'dbo.SC_AlertFact_Table',N'SC_AlertFact_Table_87a2789c',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertHistoryFact_Table') AND name=N'AlertHistoryFact_ConfigurationGroupFK_DateTimeLastModified_Index')
BEGIN
    DROP INDEX dbo.SC_AlertHistoryFact_Table.AlertHistoryFact_ConfigurationGroupFK_DateTimeLastModified_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertHistoryFact_Table') AND name=N'AlertHistoryFact_ConfigurationGroupFK_DateTimeLastModified_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_AlertHistoryFact_Table.AlertHistoryFact_ConfigurationGroupFK_DateTimeLastModified_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_AlertHistoryFact_Table.AlertHistoryFact_ConfigurationGroupFK_DateTimeLastModified_Index >>>'
END
go


ALTER TABLE dbo.SC_AlertHistoryFact_Table
    DROP CONSTRAINT SC_AlertHistoryFact_Table_PK
go


EXEC sp_rename 'dbo.DF__SC_AlertH__Local__1D114BD1','dbo.DF__SC_AlertH__Local__1D114BD1_711acf86'
go


EXEC sp_rename 'dbo.DF__SC_AlertH__Local__1E05700A','dbo.DF__SC_AlertH__Local__1E05700A_0cbe455b'
go


EXEC sp_rename 'dbo.DF__SC_AlertH__Local__1EF99443','dbo.DF__SC_AlertH__Local__1EF99443_4dbb3c8c'
go


EXEC sp_rename N'dbo.SC_AlertHistoryFact_Table',N'SC_AlertHistoryFact_Table_127cbb8a',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertLevelDimension_Table') AND name=N'AlertLevelDimension_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_AlertLevelDimension_Table.AlertLevelDimension_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertLevelDimension_Table') AND name=N'AlertLevelDimension_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_AlertLevelDimension_Table.AlertLevelDimension_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_AlertLevelDimension_Table.AlertLevelDimension_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_AlertLevelDimension_Table
    DROP CONSTRAINT SC_AlertLevelDimension_Table_PK
go


EXEC sp_rename N'dbo.SC_AlertLevelDimension_Table',N'SC_AlertLevelDimension_Table_2cd9522b',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertResolutionStateDimension_Table') AND name=N'AlertResolutionStateDimension_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_AlertResolutionStateDimension_Table.AlertResolutionStateDimension_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertResolutionStateDimension_Table') AND name=N'AlertResolutionStateDimension_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_AlertResolutionStateDimension_Table.AlertResolutionStateDimension_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_AlertResolutionStateDimension_Table.AlertResolutionStateDimension_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_AlertResolutionStateDimension_Table
    DROP CONSTRAINT SC_AlertResolutionStateDimension_Table_PK
go


EXEC sp_rename N'dbo.SC_AlertResolutionStateDimension_Table',N'SC_AlertResolutionStateDimension_Table_31ce82d5',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertToEventFact_Table') AND name=N'AlertToEventFact_ConfigurationGroupFK_DateTimeEventStored_Index')
BEGIN
    DROP INDEX dbo.SC_AlertToEventFact_Table.AlertToEventFact_ConfigurationGroupFK_DateTimeEventStored_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_AlertToEventFact_Table') AND name=N'AlertToEventFact_ConfigurationGroupFK_DateTimeEventStored_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_AlertToEventFact_Table.AlertToEventFact_ConfigurationGroupFK_DateTimeEventStored_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_AlertToEventFact_Table.AlertToEventFact_ConfigurationGroupFK_DateTimeEventStored_Index >>>'
END
go


ALTER TABLE dbo.SC_AlertToEventFact_Table
    DROP CONSTRAINT SC_AlertToEventFact_Table_PK
go


EXEC sp_rename 'dbo.DF__SC_AlertT__DateT__78D3EB5B','dbo.DF__SC_AlertT__DateT__78D3EB5B_6e87615d'
go


EXEC sp_rename N'dbo.SC_AlertToEventFact_Table',N'SC_AlertToEventFact_Table_dbcbafa5',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ClassAttributeDefinitionDimension_Table') AND name=N'ClassAttributeDefinitionDimension_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_ClassAttributeDefinitionDimension_Table.ClassAttributeDefinitionDimension_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ClassAttributeDefinitionDimension_Table') AND name=N'ClassAttributeDefinitionDimension_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ClassAttributeDefinitionDimension_Table.ClassAttributeDefinitionDimension_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ClassAttributeDefinitionDimension_Table.ClassAttributeDefinitionDimension_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_ClassAttributeDefinitionDimension_Table
    DROP CONSTRAINT SC_ClassAttributeDefinitionDimension_Table_PK
go


EXEC sp_rename N'dbo.SC_ClassAttributeDefinitionDimension_Table',N'SC_ClassAttributeDefinitionDimension_Table_ea6082b2',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ClassAttributeInstanceFact_Table') AND name=N'ClassAttributeInstanceFact_ClassAttributeDefinitionFK_Index')
BEGIN
    DROP INDEX dbo.SC_ClassAttributeInstanceFact_Table.ClassAttributeInstanceFact_ClassAttributeDefinitionFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ClassAttributeInstanceFact_Table') AND name=N'ClassAttributeInstanceFact_ClassAttributeDefinitionFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ClassAttributeInstanceFact_Table.ClassAttributeInstanceFact_ClassAttributeDefinitionFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ClassAttributeInstanceFact_Table.ClassAttributeInstanceFact_ClassAttributeDefinitionFK_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ClassAttributeInstanceFact_Table') AND name=N'ClassAttributeInstanceFact_ClassInstanceID_Index')
BEGIN
    DROP INDEX dbo.SC_ClassAttributeInstanceFact_Table.ClassAttributeInstanceFact_ClassInstanceID_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ClassAttributeInstanceFact_Table') AND name=N'ClassAttributeInstanceFact_ClassInstanceID_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ClassAttributeInstanceFact_Table.ClassAttributeInstanceFact_ClassInstanceID_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ClassAttributeInstanceFact_Table.ClassAttributeInstanceFact_ClassInstanceID_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ClassAttributeInstanceFact_Table') AND name=N'ClassAttributeInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex')
BEGIN
    DROP INDEX dbo.SC_ClassAttributeInstanceFact_Table.ClassAttributeInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ClassAttributeInstanceFact_Table') AND name=N'ClassAttributeInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ClassAttributeInstanceFact_Table.ClassAttributeInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ClassAttributeInstanceFact_Table.ClassAttributeInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex >>>'
END
go


ALTER TABLE dbo.SC_ClassAttributeInstanceFact_Table
    DROP CONSTRAINT SC_ClassAttributeInstanceFact_Table_PK
go


EXEC sp_rename 'dbo.DF__SC_ClassA__DateT__025D5595','dbo.DF__SC_ClassA__DateT__025D5595_ae890014'
go


EXEC sp_rename N'dbo.SC_ClassAttributeInstanceFact_Table',N'SC_ClassAttributeInstanceFact_Table_8c7b83e6',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ClassDefinitionDimension_Table') AND name=N'ClassDefinitionDimension_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_ClassDefinitionDimension_Table.ClassDefinitionDimension_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ClassDefinitionDimension_Table') AND name=N'ClassDefinitionDimension_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ClassDefinitionDimension_Table.ClassDefinitionDimension_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ClassDefinitionDimension_Table.ClassDefinitionDimension_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_ClassDefinitionDimension_Table
    DROP CONSTRAINT SC_ClassDefinitionDimension_Table_PK
go


EXEC sp_rename N'dbo.SC_ClassDefinitionDimension_Table',N'SC_ClassDefinitionDimension_Table_b498aacd',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ClassInstanceFact_Table') AND name=N'ClassInstanceFact_ClassDefinitionFK_Index')
BEGIN
    DROP INDEX dbo.SC_ClassInstanceFact_Table.ClassInstanceFact_ClassDefinitionFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ClassInstanceFact_Table') AND name=N'ClassInstanceFact_ClassDefinitionFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ClassInstanceFact_Table.ClassInstanceFact_ClassDefinitionFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ClassInstanceFact_Table.ClassInstanceFact_ClassDefinitionFK_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ClassInstanceFact_Table') AND name=N'ClassInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex')
BEGIN
    DROP INDEX dbo.SC_ClassInstanceFact_Table.ClassInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ClassInstanceFact_Table') AND name=N'ClassInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ClassInstanceFact_Table.ClassInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ClassInstanceFact_Table.ClassInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex >>>'
END
go


ALTER TABLE dbo.SC_ClassInstanceFact_Table
    DROP CONSTRAINT SC_ClassInstanceFact_Table_PK
go


EXEC sp_rename 'dbo.DF__SC_ClassI__DateT__25A691D2','dbo.DF__SC_ClassI__DateT__25A691D2_9165285b'
go


EXEC sp_rename N'dbo.SC_ClassInstanceFact_Table',N'SC_ClassInstanceFact_Table_8e4bdb5a',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ComputerDimension_Table') AND name=N'ComputerDimension_FullComputerName_Index')
BEGIN
    DROP INDEX dbo.SC_ComputerDimension_Table.ComputerDimension_FullComputerName_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ComputerDimension_Table') AND name=N'ComputerDimension_FullComputerName_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ComputerDimension_Table.ComputerDimension_FullComputerName_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ComputerDimension_Table.ComputerDimension_FullComputerName_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ComputerDimension_Table') AND name=N'ComputerDimension_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_ComputerDimension_Table.ComputerDimension_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ComputerDimension_Table') AND name=N'ComputerDimension_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ComputerDimension_Table.ComputerDimension_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ComputerDimension_Table.ComputerDimension_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_ComputerDimension_Table
    DROP CONSTRAINT SC_ComputerDimension_Table_PK
go


EXEC sp_rename 'dbo.DF__SC_Comput__IsAge__4924D839','dbo.DF__SC_Comput__IsAge__4924D839_06e8a8d6'
go


EXEC sp_rename 'dbo.DF__SC_Comput__IsCol__4A18FC72','dbo.DF__SC_Comput__IsCol__4A18FC72_f5ba3e5d'
go


EXEC sp_rename N'dbo.SC_ComputerDimension_Table',N'SC_ComputerDimension_Table_cca094f5',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ComputerRuleDimension_Table') AND name=N'ComputerRuleDimension_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_ComputerRuleDimension_Table.ComputerRuleDimension_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ComputerRuleDimension_Table') AND name=N'ComputerRuleDimension_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ComputerRuleDimension_Table.ComputerRuleDimension_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ComputerRuleDimension_Table.ComputerRuleDimension_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_ComputerRuleDimension_Table
    DROP CONSTRAINT SC_ComputerRuleDimension_Table_PK
go


EXEC sp_rename N'dbo.SC_ComputerRuleDimension_Table',N'SC_ComputerRuleDimension_Table_84a26c2d',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ComputerRuleToProcessRuleGroupFact_Table') AND name=N'ComputerRuleToProcessRuleGroupFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex')
BEGIN
    DROP INDEX dbo.SC_ComputerRuleToProcessRuleGroupFact_Table.ComputerRuleToProcessRuleGroupFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ComputerRuleToProcessRuleGroupFact_Table') AND name=N'ComputerRuleToProcessRuleGroupFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ComputerRuleToProcessRuleGroupFact_Table.ComputerRuleToProcessRuleGroupFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ComputerRuleToProcessRuleGroupFact_Table.ComputerRuleToProcessRuleGroupFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ComputerRuleToProcessRuleGroupFact_Table') AND name=N'ComputerRuleToProcessRuleGroupFact_ConfigurationGroupFK_DateTimeOfTransfer_ComputerRuleFK_Index')
BEGIN
    DROP INDEX dbo.SC_ComputerRuleToProcessRuleGroupFact_Table.ComputerRuleToProcessRuleGroupFact_ConfigurationGroupFK_DateTimeOfTransfer_ComputerRuleFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ComputerRuleToProcessRuleGroupFact_Table') AND name=N'ComputerRuleToProcessRuleGroupFact_ConfigurationGroupFK_DateTimeOfTransfer_ComputerRuleFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ComputerRuleToProcessRuleGroupFact_Table.ComputerRuleToProcessRuleGroupFact_ConfigurationGroupFK_DateTimeOfTransfer_ComputerRuleFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ComputerRuleToProcessRuleGroupFact_Table.ComputerRuleToProcessRuleGroupFact_ConfigurationGroupFK_DateTimeOfTransfer_ComputerRuleFK_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ComputerRuleToProcessRuleGroupFact_Table') AND name=N'ComputerRuleToProcessRuleGroupFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleGroupFK_Index')
BEGIN
    DROP INDEX dbo.SC_ComputerRuleToProcessRuleGroupFact_Table.ComputerRuleToProcessRuleGroupFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleGroupFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ComputerRuleToProcessRuleGroupFact_Table') AND name=N'ComputerRuleToProcessRuleGroupFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleGroupFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ComputerRuleToProcessRuleGroupFact_Table.ComputerRuleToProcessRuleGroupFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleGroupFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ComputerRuleToProcessRuleGroupFact_Table.ComputerRuleToProcessRuleGroupFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleGroupFK_Index >>>'
END
go


ALTER TABLE dbo.SC_ComputerRuleToProcessRuleGroupFact_Table
    DROP CONSTRAINT SC_ComputerRuleToProcessRuleGroupFact_Table_PK
go


EXEC sp_rename 'dbo.DF__SC_Comput__DateT__6F4A8121','dbo.DF__SC_Comput__DateT__6F4A8121_e2ff69d2'
go


EXEC sp_rename N'dbo.SC_ComputerRuleToProcessRuleGroupFact_Table',N'SC_ComputerRuleToProcessRuleGroupFact_Table_315b1fff',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ComputerToComputerRuleFact_Table') AND name=N'ComputerToComputerRuleFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex')
BEGIN
    DROP INDEX dbo.SC_ComputerToComputerRuleFact_Table.ComputerToComputerRuleFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ComputerToComputerRuleFact_Table') AND name=N'ComputerToComputerRuleFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ComputerToComputerRuleFact_Table.ComputerToComputerRuleFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ComputerToComputerRuleFact_Table.ComputerToComputerRuleFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ComputerToComputerRuleFact_Table') AND name=N'ComputerToComputerRuleFact_ConfigurationGroupFK_DateTimeOfTransfer_ComputerFK_Index')
BEGIN
    DROP INDEX dbo.SC_ComputerToComputerRuleFact_Table.ComputerToComputerRuleFact_ConfigurationGroupFK_DateTimeOfTransfer_ComputerFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ComputerToComputerRuleFact_Table') AND name=N'ComputerToComputerRuleFact_ConfigurationGroupFK_DateTimeOfTransfer_ComputerFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ComputerToComputerRuleFact_Table.ComputerToComputerRuleFact_ConfigurationGroupFK_DateTimeOfTransfer_ComputerFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ComputerToComputerRuleFact_Table.ComputerToComputerRuleFact_ConfigurationGroupFK_DateTimeOfTransfer_ComputerFK_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ComputerToComputerRuleFact_Table') AND name=N'ComputerToComputerRuleFact_ConfigurationGroupFK_DateTimeOfTransfer_ComputerRuleFK_Index')
BEGIN
    DROP INDEX dbo.SC_ComputerToComputerRuleFact_Table.ComputerToComputerRuleFact_ConfigurationGroupFK_DateTimeOfTransfer_ComputerRuleFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ComputerToComputerRuleFact_Table') AND name=N'ComputerToComputerRuleFact_ConfigurationGroupFK_DateTimeOfTransfer_ComputerRuleFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ComputerToComputerRuleFact_Table.ComputerToComputerRuleFact_ConfigurationGroupFK_DateTimeOfTransfer_ComputerRuleFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ComputerToComputerRuleFact_Table.ComputerToComputerRuleFact_ConfigurationGroupFK_DateTimeOfTransfer_ComputerRuleFK_Index >>>'
END
go


ALTER TABLE dbo.SC_ComputerToComputerRuleFact_Table
    DROP CONSTRAINT SC_ComputerToComputerRuleFact_Table_PK
go


EXEC sp_rename 'dbo.DF__SC_Comput__DateT__30592A6F','dbo.DF__SC_Comput__DateT__30592A6F_3e5223b0'
go


EXEC sp_rename 'dbo.DF__SC_Comput__Level__314D4EA8','dbo.DF__SC_Comput__Level__314D4EA8_e300fbaa'
go


EXEC sp_rename N'dbo.SC_ComputerToComputerRuleFact_Table',N'SC_ComputerToComputerRuleFact_Table_9c9d2f88',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ComputerToConfigurationGroupDimension_Table') AND name=N'ComputerToConfigurationGroupDimension_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_ComputerToConfigurationGroupDimension_Table.ComputerToConfigurationGroupDimension_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ComputerToConfigurationGroupDimension_Table') AND name=N'ComputerToConfigurationGroupDimension_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ComputerToConfigurationGroupDimension_Table.ComputerToConfigurationGroupDimension_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ComputerToConfigurationGroupDimension_Table.ComputerToConfigurationGroupDimension_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_ComputerToConfigurationGroupDimension_Table
    DROP CONSTRAINT SC_ComputerToConfigurationGroupDimension_Table_PK
go


EXEC sp_rename N'dbo.SC_ComputerToConfigurationGroupDimension_Table',N'SC_ComputerToConfigurationGroupDimension_Table_316b88e0',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ConfigurationGroupDimension_Table') AND name=N'ConfigurationGroupDimension_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_ConfigurationGroupDimension_Table.ConfigurationGroupDimension_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ConfigurationGroupDimension_Table') AND name=N'ConfigurationGroupDimension_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ConfigurationGroupDimension_Table.ConfigurationGroupDimension_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ConfigurationGroupDimension_Table.ConfigurationGroupDimension_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_ConfigurationGroupDimension_Table
    DROP CONSTRAINT SC_ConfigurationGroupDimension_Table_PK
go


EXEC sp_rename N'dbo.SC_ConfigurationGroupDimension_Table',N'SC_ConfigurationGroupDimension_Table_699f11f5',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_CounterDetailDimension_Table') AND name=N'CounterDetailDimension_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_CounterDetailDimension_Table.CounterDetailDimension_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_CounterDetailDimension_Table') AND name=N'CounterDetailDimension_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_CounterDetailDimension_Table.CounterDetailDimension_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_CounterDetailDimension_Table.CounterDetailDimension_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_CounterDetailDimension_Table
    DROP CONSTRAINT SC_CounterDetailDimension_Table_PK
go


EXEC sp_rename N'dbo.SC_CounterDetailDimension_Table',N'SC_CounterDetailDimension_Table_52815212',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_DateDimension_Table') AND name=N'DateDimension_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_DateDimension_Table.DateDimension_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_DateDimension_Table') AND name=N'DateDimension_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_DateDimension_Table.DateDimension_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_DateDimension_Table.DateDimension_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_DateDimension_Table
    DROP CONSTRAINT SC_DateDimension_Table_PK
go


EXEC sp_rename N'dbo.SC_DateDimension_Table',N'SC_DateDimension_Table_6e7157da',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_EventDetailDimension_Table') AND name=N'EventDetailDimension_EventIDPK_Index')
BEGIN
    DROP INDEX dbo.SC_EventDetailDimension_Table.EventDetailDimension_EventIDPK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_EventDetailDimension_Table') AND name=N'EventDetailDimension_EventIDPK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_EventDetailDimension_Table.EventDetailDimension_EventIDPK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_EventDetailDimension_Table.EventDetailDimension_EventIDPK_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_EventDetailDimension_Table') AND name=N'EventDetailDimension_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_EventDetailDimension_Table.EventDetailDimension_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_EventDetailDimension_Table') AND name=N'EventDetailDimension_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_EventDetailDimension_Table.EventDetailDimension_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_EventDetailDimension_Table.EventDetailDimension_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_EventDetailDimension_Table
    DROP CONSTRAINT SC_EventDetailDimension_Table_PK
go


EXEC sp_rename N'dbo.SC_EventDetailDimension_Table',N'SC_EventDetailDimension_Table_60b5bffe',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_EventFact_Table') AND name=N'EventFact_ComputerFK_Index')
BEGIN
    DROP INDEX dbo.SC_EventFact_Table.EventFact_ComputerFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_EventFact_Table') AND name=N'EventFact_ComputerFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_EventFact_Table.EventFact_ComputerFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_EventFact_Table.EventFact_ComputerFK_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_EventFact_Table') AND name=N'EventFact_ConfigurationGroupFK_DateTimeStored_Index')
BEGIN
    DROP INDEX dbo.SC_EventFact_Table.EventFact_ConfigurationGroupFK_DateTimeStored_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_EventFact_Table') AND name=N'EventFact_ConfigurationGroupFK_DateTimeStored_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_EventFact_Table.EventFact_ConfigurationGroupFK_DateTimeStored_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_EventFact_Table.EventFact_ConfigurationGroupFK_DateTimeStored_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_EventFact_Table') AND name=N'EventFact_EventDetailFK_Index')
BEGIN
    DROP INDEX dbo.SC_EventFact_Table.EventFact_EventDetailFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_EventFact_Table') AND name=N'EventFact_EventDetailFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_EventFact_Table.EventFact_EventDetailFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_EventFact_Table.EventFact_EventDetailFK_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_EventFact_Table') AND name=N'EventFact_EventType_Index')
BEGIN
    DROP INDEX dbo.SC_EventFact_Table.EventFact_EventType_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_EventFact_Table') AND name=N'EventFact_EventType_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_EventFact_Table.EventFact_EventType_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_EventFact_Table.EventFact_EventType_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_EventFact_Table') AND name=N'EventFact_LocalDateTimeGenerated_ClusteredIndex')
BEGIN
    DROP INDEX dbo.SC_EventFact_Table.EventFact_LocalDateTimeGenerated_ClusteredIndex
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_EventFact_Table') AND name=N'EventFact_LocalDateTimeGenerated_ClusteredIndex')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_EventFact_Table.EventFact_LocalDateTimeGenerated_ClusteredIndex >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_EventFact_Table.EventFact_LocalDateTimeGenerated_ClusteredIndex >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_EventFact_Table') AND name=N'EventFact_ProviderDetailFK_Index')
BEGIN
    DROP INDEX dbo.SC_EventFact_Table.EventFact_ProviderDetailFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_EventFact_Table') AND name=N'EventFact_ProviderDetailFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_EventFact_Table.EventFact_ProviderDetailFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_EventFact_Table.EventFact_ProviderDetailFK_Index >>>'
END
go


ALTER TABLE dbo.SC_EventFact_Table
    DROP CONSTRAINT SC_EventFact_Table_PK
go


EXEC sp_rename 'dbo.DF__SC_EventF__Local__0BE6BFCF','dbo.DF__SC_EventF__Local__0BE6BFCF_a8c3178c'
go


EXEC sp_rename 'dbo.DF__SC_EventF__Local__0CDAE408','dbo.DF__SC_EventF__Local__0CDAE408_bccdbc28'
go


EXEC sp_rename 'dbo.DF__SC_EventF__Local__0DCF0841','dbo.DF__SC_EventF__Local__0DCF0841_4a82240c'
go


EXEC sp_rename 'dbo.DF__SC_EventF__Local__0EC32C7A','dbo.DF__SC_EventF__Local__0EC32C7A_e8fece1d'
go


EXEC sp_rename 'dbo.DF__SC_EventF__Local__0FB750B3','dbo.DF__SC_EventF__Local__0FB750B3_74c803a8'
go


EXEC sp_rename 'dbo.DF__SC_EventF__Local__10AB74EC','dbo.DF__SC_EventF__Local__10AB74EC_effbdc62'
go


EXEC sp_rename N'dbo.SC_EventFact_Table',N'SC_EventFact_Table_171058ea',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_EventParameterFact_Table') AND name=N'EventParameterFact_ConfigurationGroupFK_DateTimeEventStored_Index')
BEGIN
    DROP INDEX dbo.SC_EventParameterFact_Table.EventParameterFact_ConfigurationGroupFK_DateTimeEventStored_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_EventParameterFact_Table') AND name=N'EventParameterFact_ConfigurationGroupFK_DateTimeEventStored_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_EventParameterFact_Table.EventParameterFact_ConfigurationGroupFK_DateTimeEventStored_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_EventParameterFact_Table.EventParameterFact_ConfigurationGroupFK_DateTimeEventStored_Index >>>'
END
go


ALTER TABLE dbo.SC_EventParameterFact_Table
    DROP CONSTRAINT SC_EventParameterFact_Table_PK
go


EXEC sp_rename N'dbo.SC_EventParameterFact_Table',N'SC_EventParameterFact_Table_ef793970',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_EventTypeDimension_Table') AND name=N'EventTypeDimension_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_EventTypeDimension_Table.EventTypeDimension_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_EventTypeDimension_Table') AND name=N'EventTypeDimension_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_EventTypeDimension_Table.EventTypeDimension_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_EventTypeDimension_Table.EventTypeDimension_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_EventTypeDimension_Table
    DROP CONSTRAINT SC_EventTypeDimension_Table_PK
go


EXEC sp_rename N'dbo.SC_EventTypeDimension_Table',N'SC_EventTypeDimension_Table_67d4e0f8',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_OperationalDataDimension_Table') AND name=N'OperationalData_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_OperationalDataDimension_Table.OperationalData_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_OperationalDataDimension_Table') AND name=N'OperationalData_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_OperationalDataDimension_Table.OperationalData_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_OperationalDataDimension_Table.OperationalData_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_OperationalDataDimension_Table
    DROP CONSTRAINT SC_OperationalDataDimension_Table_PK
go


EXEC sp_rename N'dbo.SC_OperationalDataDimension_Table',N'SC_OperationalDataDimension_Table_fe24ff6e',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProcessRuleDimension_Table') AND name=N'ProcessRuleDimension_ProcessRuleName_Index')
BEGIN
    DROP INDEX dbo.SC_ProcessRuleDimension_Table.ProcessRuleDimension_ProcessRuleName_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProcessRuleDimension_Table') AND name=N'ProcessRuleDimension_ProcessRuleName_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ProcessRuleDimension_Table.ProcessRuleDimension_ProcessRuleName_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ProcessRuleDimension_Table.ProcessRuleDimension_ProcessRuleName_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProcessRuleDimension_Table') AND name=N'ProcessRuleDimension_ProviderDetailFK_Index')
BEGIN
    DROP INDEX dbo.SC_ProcessRuleDimension_Table.ProcessRuleDimension_ProviderDetailFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProcessRuleDimension_Table') AND name=N'ProcessRuleDimension_ProviderDetailFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ProcessRuleDimension_Table.ProcessRuleDimension_ProviderDetailFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ProcessRuleDimension_Table.ProcessRuleDimension_ProviderDetailFK_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProcessRuleDimension_Table') AND name=N'ProcessRuleDimension_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_ProcessRuleDimension_Table.ProcessRuleDimension_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProcessRuleDimension_Table') AND name=N'ProcessRuleDimension_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ProcessRuleDimension_Table.ProcessRuleDimension_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ProcessRuleDimension_Table.ProcessRuleDimension_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_ProcessRuleDimension_Table
    DROP CONSTRAINT SC_ProcessRuleDimension_Table_PK
go


EXEC sp_rename 'dbo.DF__SC_Proces__IsRul__62E4AA3C','dbo.DF__SC_Proces__IsRul__62E4AA3C_592be9ac'
go


EXEC sp_rename N'dbo.SC_ProcessRuleDimension_Table',N'SC_ProcessRuleDimension_Table_1441a71e',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProcessRuleMembershipFact_Table') AND name=N'ProcessRuleMembershipFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex')
BEGIN
    DROP INDEX dbo.SC_ProcessRuleMembershipFact_Table.ProcessRuleMembershipFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProcessRuleMembershipFact_Table') AND name=N'ProcessRuleMembershipFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ProcessRuleMembershipFact_Table.ProcessRuleMembershipFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ProcessRuleMembershipFact_Table.ProcessRuleMembershipFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProcessRuleMembershipFact_Table') AND name=N'ProcessRuleMembershipFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleGroupFK_Index')
BEGIN
    DROP INDEX dbo.SC_ProcessRuleMembershipFact_Table.ProcessRuleMembershipFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleGroupFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProcessRuleMembershipFact_Table') AND name=N'ProcessRuleMembershipFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleGroupFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ProcessRuleMembershipFact_Table.ProcessRuleMembershipFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleGroupFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ProcessRuleMembershipFact_Table.ProcessRuleMembershipFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleGroupFK_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProcessRuleMembershipFact_Table') AND name=N'ProcessRuleMembershipFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleMemberFK_Index')
BEGIN
    DROP INDEX dbo.SC_ProcessRuleMembershipFact_Table.ProcessRuleMembershipFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleMemberFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProcessRuleMembershipFact_Table') AND name=N'ProcessRuleMembershipFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleMemberFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ProcessRuleMembershipFact_Table.ProcessRuleMembershipFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleMemberFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ProcessRuleMembershipFact_Table.ProcessRuleMembershipFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleMemberFK_Index >>>'
END
go


ALTER TABLE dbo.SC_ProcessRuleMembershipFact_Table
    DROP CONSTRAINT SC_ProcessRuleMembershipFact_Table_PK
go


EXEC sp_rename 'dbo.DF__SC_Proces__DateT__25DB9BFC','dbo.DF__SC_Proces__DateT__25DB9BFC_a9503bcb'
go


EXEC sp_rename 'dbo.DF__SC_Proces__Level__26CFC035','dbo.DF__SC_Proces__Level__26CFC035_cd9aba07'
go


EXEC sp_rename N'dbo.SC_ProcessRuleMembershipFact_Table',N'SC_ProcessRuleMembershipFact_Table_51270624',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProcessRuleToConfigurationGroupDimension_Table') AND name=N'ProcessRuleToConfigurationGroupDimension_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_ProcessRuleToConfigurationGroupDimension_Table.ProcessRuleToConfigurationGroupDimension_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProcessRuleToConfigurationGroupDimension_Table') AND name=N'ProcessRuleToConfigurationGroupDimension_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ProcessRuleToConfigurationGroupDimension_Table.ProcessRuleToConfigurationGroupDimension_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ProcessRuleToConfigurationGroupDimension_Table.ProcessRuleToConfigurationGroupDimension_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_ProcessRuleToConfigurationGroupDimension_Table
    DROP CONSTRAINT SC_ProcessRuleToConfigurationGroupDimension_Table_PK
go


EXEC sp_rename N'dbo.SC_ProcessRuleToConfigurationGroupDimension_Table',N'SC_ProcessRuleToConfigurationGroupDimension_Table_a9c6373e',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProcessRuleToScriptFact_Table') AND name=N'ProcessRuleToScriptFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex')
BEGIN
    DROP INDEX dbo.SC_ProcessRuleToScriptFact_Table.ProcessRuleToScriptFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProcessRuleToScriptFact_Table') AND name=N'ProcessRuleToScriptFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ProcessRuleToScriptFact_Table.ProcessRuleToScriptFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ProcessRuleToScriptFact_Table.ProcessRuleToScriptFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProcessRuleToScriptFact_Table') AND name=N'ProcessRuleToScriptFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleFK_Index')
BEGIN
    DROP INDEX dbo.SC_ProcessRuleToScriptFact_Table.ProcessRuleToScriptFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProcessRuleToScriptFact_Table') AND name=N'ProcessRuleToScriptFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ProcessRuleToScriptFact_Table.ProcessRuleToScriptFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ProcessRuleToScriptFact_Table.ProcessRuleToScriptFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleFK_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProcessRuleToScriptFact_Table') AND name=N'ProcessRuleToScriptFact_ConfigurationGroupFK_DateTimeOfTransfer_ScriptFK_Index')
BEGIN
    DROP INDEX dbo.SC_ProcessRuleToScriptFact_Table.ProcessRuleToScriptFact_ConfigurationGroupFK_DateTimeOfTransfer_ScriptFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProcessRuleToScriptFact_Table') AND name=N'ProcessRuleToScriptFact_ConfigurationGroupFK_DateTimeOfTransfer_ScriptFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ProcessRuleToScriptFact_Table.ProcessRuleToScriptFact_ConfigurationGroupFK_DateTimeOfTransfer_ScriptFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ProcessRuleToScriptFact_Table.ProcessRuleToScriptFact_ConfigurationGroupFK_DateTimeOfTransfer_ScriptFK_Index >>>'
END
go


ALTER TABLE dbo.SC_ProcessRuleToScriptFact_Table
    DROP CONSTRAINT SC_ProcessRuleToScriptFact_Table_PK
go


EXEC sp_rename 'dbo.DF__SC_Proces__DateT__37FA4C37','dbo.DF__SC_Proces__DateT__37FA4C37_beb0d6dc'
go


EXEC sp_rename N'dbo.SC_ProcessRuleToScriptFact_Table',N'SC_ProcessRuleToScriptFact_Table_acc59172',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProviderDetailDimension_Table') AND name=N'ProviderDetailDimension_ProviderInstanceName_Index')
BEGIN
    DROP INDEX dbo.SC_ProviderDetailDimension_Table.ProviderDetailDimension_ProviderInstanceName_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProviderDetailDimension_Table') AND name=N'ProviderDetailDimension_ProviderInstanceName_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ProviderDetailDimension_Table.ProviderDetailDimension_ProviderInstanceName_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ProviderDetailDimension_Table.ProviderDetailDimension_ProviderInstanceName_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProviderDetailDimension_Table') AND name=N'ProviderDetailDimension_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_ProviderDetailDimension_Table.ProviderDetailDimension_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ProviderDetailDimension_Table') AND name=N'ProviderDetailDimension_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ProviderDetailDimension_Table.ProviderDetailDimension_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ProviderDetailDimension_Table.ProviderDetailDimension_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_ProviderDetailDimension_Table
    DROP CONSTRAINT SC_ProviderDetailDimension_Table_PK
go


EXEC sp_rename N'dbo.SC_ProviderDetailDimension_Table',N'SC_ProviderDetailDimension_Table_0217ca48',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_RelationshipAttributeDefinitionDimension_Table') AND name=N'RelationshipAttributeDefinitionDimension_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_RelationshipAttributeDefinitionDimension_Table.RelationshipAttributeDefinitionDimension_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_RelationshipAttributeDefinitionDimension_Table') AND name=N'RelationshipAttributeDefinitionDimension_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_RelationshipAttributeDefinitionDimension_Table.RelationshipAttributeDefinitionDimension_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_RelationshipAttributeDefinitionDimension_Table.RelationshipAttributeDefinitionDimension_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_RelationshipAttributeDefinitionDimension_Table
    DROP CONSTRAINT SC_RelationshipAttributeDefinitionDimension_Table_PK
go


EXEC sp_rename N'dbo.SC_RelationshipAttributeDefinitionDimension_Table',N'SC_RelationshipAttributeDefinitionDimension_Table_5e770e77',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_RelationshipAttributeInstanceFact_Table') AND name=N'RelationshipAttributeInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex')
BEGIN
    DROP INDEX dbo.SC_RelationshipAttributeInstanceFact_Table.RelationshipAttributeInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_RelationshipAttributeInstanceFact_Table') AND name=N'RelationshipAttributeInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_RelationshipAttributeInstanceFact_Table.RelationshipAttributeInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_RelationshipAttributeInstanceFact_Table.RelationshipAttributeInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_RelationshipAttributeInstanceFact_Table') AND name=N'RelationshipAttributeInstanceFact_RelationshipAttributeDefinitionFK_Index')
BEGIN
    DROP INDEX dbo.SC_RelationshipAttributeInstanceFact_Table.RelationshipAttributeInstanceFact_RelationshipAttributeDefinitionFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_RelationshipAttributeInstanceFact_Table') AND name=N'RelationshipAttributeInstanceFact_RelationshipAttributeDefinitionFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_RelationshipAttributeInstanceFact_Table.RelationshipAttributeInstanceFact_RelationshipAttributeDefinitionFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_RelationshipAttributeInstanceFact_Table.RelationshipAttributeInstanceFact_RelationshipAttributeDefinitionFK_Index >>>'
END
go


ALTER TABLE dbo.SC_RelationshipAttributeInstanceFact_Table
    DROP CONSTRAINT SC_RelationshipAttributeInstanceFact_Table_PK
go


EXEC sp_rename 'dbo.DF__SC_Relati__DateT__3BCADD1B','dbo.DF__SC_Relati__DateT__3BCADD1B_7469fb7f'
go


EXEC sp_rename N'dbo.SC_RelationshipAttributeInstanceFact_Table',N'SC_RelationshipAttributeInstanceFact_Table_46e8fd21',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_RelationshipDefinitionDimension_Table') AND name=N'RelationshipDefinitionDimension_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_RelationshipDefinitionDimension_Table.RelationshipDefinitionDimension_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_RelationshipDefinitionDimension_Table') AND name=N'RelationshipDefinitionDimension_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_RelationshipDefinitionDimension_Table.RelationshipDefinitionDimension_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_RelationshipDefinitionDimension_Table.RelationshipDefinitionDimension_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_RelationshipDefinitionDimension_Table
    DROP CONSTRAINT SC_RelationshipDefinitionDimension_Table_PK
go


EXEC sp_rename N'dbo.SC_RelationshipDefinitionDimension_Table',N'SC_RelationshipDefinitionDimension_Table_21bd4cf3',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_RelationshipInstanceFact_Table') AND name=N'RelationshipInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex')
BEGIN
    DROP INDEX dbo.SC_RelationshipInstanceFact_Table.RelationshipInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_RelationshipInstanceFact_Table') AND name=N'RelationshipInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_RelationshipInstanceFact_Table.RelationshipInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_RelationshipInstanceFact_Table.RelationshipInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_RelationshipInstanceFact_Table') AND name=N'RelationshipInstanceFact_RelationshipDefinitionFK_Index')
BEGIN
    DROP INDEX dbo.SC_RelationshipInstanceFact_Table.RelationshipInstanceFact_RelationshipDefinitionFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_RelationshipInstanceFact_Table') AND name=N'RelationshipInstanceFact_RelationshipDefinitionFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_RelationshipInstanceFact_Table.RelationshipInstanceFact_RelationshipDefinitionFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_RelationshipInstanceFact_Table.RelationshipInstanceFact_RelationshipDefinitionFK_Index >>>'
END
go


ALTER TABLE dbo.SC_RelationshipInstanceFact_Table
    DROP CONSTRAINT SC_RelationshipInstanceFact_Table_PK
go


EXEC sp_rename 'dbo.DF__SC_Relati__DateT__4277DAAA','dbo.DF__SC_Relati__DateT__4277DAAA_caa0bd6d'
go


EXEC sp_rename N'dbo.SC_RelationshipInstanceFact_Table',N'SC_RelationshipInstanceFact_Table_cd454610',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_SampledNumericDataFact_Table') AND name=N'SampledNumericDataFact_ComputerFK_Index')
BEGIN
    DROP INDEX dbo.SC_SampledNumericDataFact_Table.SampledNumericDataFact_ComputerFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_SampledNumericDataFact_Table') AND name=N'SampledNumericDataFact_ComputerFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_SampledNumericDataFact_Table.SampledNumericDataFact_ComputerFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_SampledNumericDataFact_Table.SampledNumericDataFact_ComputerFK_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_SampledNumericDataFact_Table') AND name=N'SampledNumericDataFact_ConfigurationGroupFK_DateTimeAdded_Index')
BEGIN
    DROP INDEX dbo.SC_SampledNumericDataFact_Table.SampledNumericDataFact_ConfigurationGroupFK_DateTimeAdded_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_SampledNumericDataFact_Table') AND name=N'SampledNumericDataFact_ConfigurationGroupFK_DateTimeAdded_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_SampledNumericDataFact_Table.SampledNumericDataFact_ConfigurationGroupFK_DateTimeAdded_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_SampledNumericDataFact_Table.SampledNumericDataFact_ConfigurationGroupFK_DateTimeAdded_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_SampledNumericDataFact_Table') AND name=N'SampledNumericDataFact_CounterDetailFK_Index')
BEGIN
    DROP INDEX dbo.SC_SampledNumericDataFact_Table.SampledNumericDataFact_CounterDetailFK_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_SampledNumericDataFact_Table') AND name=N'SampledNumericDataFact_CounterDetailFK_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_SampledNumericDataFact_Table.SampledNumericDataFact_CounterDetailFK_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_SampledNumericDataFact_Table.SampledNumericDataFact_CounterDetailFK_Index >>>'
END
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_SampledNumericDataFact_Table') AND name=N'SampledNumericDataFact_LocalDateTimeSampled_ClusteredIndex')
BEGIN
    DROP INDEX dbo.SC_SampledNumericDataFact_Table.SampledNumericDataFact_LocalDateTimeSampled_ClusteredIndex
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_SampledNumericDataFact_Table') AND name=N'SampledNumericDataFact_LocalDateTimeSampled_ClusteredIndex')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_SampledNumericDataFact_Table.SampledNumericDataFact_LocalDateTimeSampled_ClusteredIndex >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_SampledNumericDataFact_Table.SampledNumericDataFact_LocalDateTimeSampled_ClusteredIndex >>>'
END
go


ALTER TABLE dbo.SC_SampledNumericDataFact_Table
    DROP CONSTRAINT SC_SampledNumericDataFact_Table_PK
go


EXEC sp_rename 'dbo.DF__SC_Sample__Local__6991A7CB','dbo.DF__SC_Sample__Local__6991A7CB_80ad32ee'
go


EXEC sp_rename 'dbo.DF__SC_Sample__Local__6A85CC04','dbo.DF__SC_Sample__Local__6A85CC04_84391055'
go


EXEC sp_rename 'dbo.DF__SC_Sample__Local__6B79F03D','dbo.DF__SC_Sample__Local__6B79F03D_0fb5d7c3'
go


EXEC sp_rename N'dbo.SC_SampledNumericDataFact_Table',N'SC_SampledNumericDataFact_Table_66425fab',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ScriptDimension_Table') AND name=N'Script_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_ScriptDimension_Table.Script_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ScriptDimension_Table') AND name=N'Script_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ScriptDimension_Table.Script_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ScriptDimension_Table.Script_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_ScriptDimension_Table
    DROP CONSTRAINT SC_ScriptDimension_Table_PK
go


EXEC sp_rename N'dbo.SC_ScriptDimension_Table',N'SC_ScriptDimension_Table_83773e97',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ScriptToConfigurationGroupDimension_Table') AND name=N'ScriptToConfigurationGroupDimension_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_ScriptToConfigurationGroupDimension_Table.ScriptToConfigurationGroupDimension_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_ScriptToConfigurationGroupDimension_Table') AND name=N'ScriptToConfigurationGroupDimension_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_ScriptToConfigurationGroupDimension_Table.ScriptToConfigurationGroupDimension_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_ScriptToConfigurationGroupDimension_Table.ScriptToConfigurationGroupDimension_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_ScriptToConfigurationGroupDimension_Table
    DROP CONSTRAINT SC_ScriptToConfigurationGroupDimension_Table_PK
go


EXEC sp_rename N'dbo.SC_ScriptToConfigurationGroupDimension_Table',N'SC_ScriptToConfigurationGroupDimension_Table_c18cf92e',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_TimeDimension_Table') AND name=N'TimeDimension_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_TimeDimension_Table.TimeDimension_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_TimeDimension_Table') AND name=N'TimeDimension_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_TimeDimension_Table.TimeDimension_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_TimeDimension_Table.TimeDimension_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_TimeDimension_Table
    DROP CONSTRAINT SC_TimeDimension_Table_PK
go


EXEC sp_rename N'dbo.SC_TimeDimension_Table',N'SC_TimeDimension_Table_fa2368e9',N'OBJECT'
go


IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_UserDimension_Table') AND name=N'UserDimension_SurrogateKey_Index')
BEGIN
    DROP INDEX dbo.SC_UserDimension_Table.UserDimension_SurrogateKey_Index
    IF EXISTS (SELECT * FROM sysindexes WHERE id=OBJECT_ID(N'dbo.SC_UserDimension_Table') AND name=N'UserDimension_SurrogateKey_Index')
        PRINT N'<<< FAILED DROPPING INDEX dbo.SC_UserDimension_Table.UserDimension_SurrogateKey_Index >>>'
    ELSE
        PRINT N'<<< DROPPED INDEX dbo.SC_UserDimension_Table.UserDimension_SurrogateKey_Index >>>'
END
go


ALTER TABLE dbo.SC_UserDimension_Table
    DROP CONSTRAINT SC_UserDimension_Table_PK
go


EXEC sp_rename N'dbo.SC_UserDimension_Table',N'SC_UserDimension_Table_62c3c491',N'OBJECT'
go


DROP PROCEDURE dbo.SMC_AddValidationUDF
go


DROP PROCEDURE dbo.SMC_Meta_DeleteValidationUDF
go


DROP PROCEDURE dbo.smc_add_parameter_to_sproc
go


DROP PROCEDURE dbo.smc_generate_wrapper_for_query
go


DROP PROCEDURE dbo.smc_generate_wrapper_for_sproc
go


DROP PROCEDURE dbo.smc_internal_getmessage
go


EXEC sp_rename N'dbo.SMC_Messages',N'SMC_Messages_a1120a3e',N'OBJECT'
go


EXEC sp_rename N'dbo.SMO_CSharpAssemblies',N'SMO_CSharpAssemblies_e8ce6d80',N'OBJECT'
go


ALTER TABLE dbo.SMO_CSharpTypes
    DROP CONSTRAINT FK_SMO_CSharpTypes_SMO_CSharpAssembly
go


EXEC sp_rename N'dbo.SMO_CSharpTypes',N'SMO_CSharpTypes_bdffdecc',N'OBJECT'
go


ALTER TABLE dbo.SMO_ClassMethods
    DROP CONSTRAINT FK_SMO_ClassMethods_SMO_ClassSchemas
go


EXEC sp_rename N'dbo.SMO_ClassMethods',N'SMO_ClassMethods_d6c0d6c0',N'OBJECT'
go


ALTER TABLE dbo.SMO_ClassProperties
    DROP CONSTRAINT FK_SMO_ClassProperties_SMO_ClassSMCClasses
go


ALTER TABLE dbo.SMO_ClassProperties
    DROP CONSTRAINT smc_fk_SMO_ClassProperties_SMO_CSharpTypes_CSharpTypeID
go


ALTER TABLE dbo.SMO_ClassProperties
    DROP CONSTRAINT smc_fk_SMO_ClassProperties_SMO_ClassSchemas_SMOClassID
go


EXEC sp_rename 'dbo.DF_SMO_ClassProperties_SCP_Hidden','dbo.DF_SMO_ClassProperties_SCP_Hidden_186d5309'
go


EXEC sp_rename N'dbo.SMO_ClassProperties',N'SMO_ClassProperties_1fe34a82',N'OBJECT'
go


ALTER TABLE dbo.SMO_ClassSMCClassJoins
    DROP CONSTRAINT smc_fk_SMO_ClassSMCClassJoins_SMO_ClassSMCClasses_SourceSMOClassSMCClass
go


ALTER TABLE dbo.SMO_ClassSMCClassJoins
    DROP CONSTRAINT smc_fk_SMO_ClassSMCClassJoins_SMO_ClassSMCClasses_TargetSMOClassSMCClass
go


EXEC sp_rename N'dbo.SMO_ClassSMCClassJoins',N'SMO_ClassSMCClassJoins_185627cd',N'OBJECT'
go


ALTER TABLE dbo.SMO_ClassSMCClasses
    DROP CONSTRAINT smc_fk_SMO_ClassSMCClasses_SMO_ClassSchemas_SMOClassID
go


EXEC sp_rename 'dbo.DF_SMO_ClassSMCClasses_SCSC_IsPrimary','dbo.DF_SMO_ClassSMCClasses_SCSC_IsPrimary_3024f58a'
go


EXEC sp_rename 'dbo.DF_SMO_ClassSMCClasses_SCSC_IsUsedInRelationships','dbo.DF_SMO_ClassSMCClasses_SCSC_IsUsedInRelationships_7702e284'
go


EXEC sp_rename N'dbo.SMO_ClassSMCClasses',N'SMO_ClassSMCClasses_a848adfa',N'OBJECT'
go


ALTER TABLE dbo.SMO_ClassSchemas
    DROP CONSTRAINT smc_fk_SMO_ClassSchemas_SMO_CSharpAssemblies
go


EXEC sp_rename N'dbo.SMO_ClassSchemas',N'SMO_ClassSchemas_abd03da5',N'OBJECT'
go


ALTER TABLE dbo.SMO_RelationshipSources
    DROP CONSTRAINT smc_fk_SMO_RelationshipSources_SMO_ClassSchemas_SourceSMOClassID
go


ALTER TABLE dbo.SMO_RelationshipSources
    DROP CONSTRAINT smc_fk_SMO_RelationshipSources_SMO_RelationshipTypes_SMORelationshipTypeID
go


EXEC sp_rename N'dbo.SMO_RelationshipSources',N'SMO_RelationshipSources_83990197',N'OBJECT'
go


ALTER TABLE dbo.SMO_RelationshipTargets
    DROP CONSTRAINT smc_fk_SMO_RelationshipTargets_SMO_ClassSchemas_TargetSMOClassID
go


ALTER TABLE dbo.SMO_RelationshipTargets
    DROP CONSTRAINT smc_fk_SMO_RelationshipTargets_SMO_RelationshipTypes_SMORelationshipTypeID
go


EXEC sp_rename N'dbo.SMO_RelationshipTargets',N'SMO_RelationshipTargets_69e4b599',N'OBJECT'
go


EXEC sp_rename N'dbo.SMO_RelationshipTypes',N'SMO_RelationshipTypes_f306396b',N'OBJECT'
go


ALTER TABLE dbo.SMO_TypeConversions
    DROP CONSTRAINT smc_fk_SMO_TypeConversions_SMO_CSharpTypes_CSharpTypeID
go


ALTER TABLE dbo.SMO_TypeConversions
    DROP CONSTRAINT smc_fk_SMO_TypeConversions_SMO_CSharpTypes_ConversionClass
go


EXEC sp_rename N'dbo.SMO_TypeConversions',N'SMO_TypeConversions_75bdf051',N'OBJECT'
go


DROP PROCEDURE dbo.smc_internal_getuserid
go


EXEC sp_rename N'dbo.Users',N'Users_4d8405f6',N'OBJECT'
go


ALTER TABLE dbo.ValidationUDFParameterValues
    DROP CONSTRAINT smc_fk_ValidationUDFParameterValues_ValidationUDFParameters
go


EXEC sp_rename N'dbo.ValidationUDFParameterValues',N'ValidationUDFParameterValues_483c41eb',N'OBJECT'
go


ALTER TABLE dbo.ValidationUDFParameters
    DROP CONSTRAINT smc_fk_ValidationUDFParameters_ValidationUDFs
go


ALTER TABLE dbo.ValidationUDFParameters
    DROP CONSTRAINT smc_chk_ValidationUDFParameters_ScalePrecisionInRange
go


DROP TRIGGER dbo.triud_ValidationUDFParameters_Signed
go


EXEC sp_rename N'dbo.ValidationUDFParameters',N'ValidationUDFParameters_597ca84f',N'OBJECT'
go


DROP TRIGGER dbo.triu_ValidationUDFs_Validate
go


DROP TRIGGER dbo.trud_ValidationUDFs_Signed
go


EXEC sp_rename 'dbo.DF_ValidationUDFs_VU_Signed','dbo.DF_ValidationUDFs_VU_Signed_2690e318'
go


EXEC sp_rename N'dbo.ValidationUDFs',N'ValidationUDFs_eddc8219',N'OBJECT'
go


EXEC sp_rename N'dbo.WarehouseClassProperty',N'WarehouseClassProperty_45d5a0fb',N'OBJECT'
go


EXEC sp_rename N'dbo.WarehouseClassSchema',N'WarehouseClassSchema_263c6ba5',N'OBJECT'
go


EXEC sp_rename N'dbo.WarehouseClassSchemaToProductSchema',N'WarehouseClassSchemaToProductSchema_0f6b48e4',N'OBJECT'
go


EXEC sp_rename N'dbo.WarehouseGroomingInfo',N'WarehouseGroomingInfo_565ed31f',N'OBJECT'
go


EXEC sp_rename N'dbo.WarehouseTransformInfo',N'WarehouseTransformInfo_31b8f41b',N'OBJECT'
go


ALTER TABLE dbo.WrapperColumns
    DROP CONSTRAINT smc_fk_WrapperColumns_WrapperSchemas
go


EXEC sp_rename N'dbo.WrapperColumns',N'WrapperColumns_e92fe117',N'OBJECT'
go


EXEC sp_rename N'dbo.WrapperSchemas',N'WrapperSchemas_c7ea2dd3',N'OBJECT'
go


DROP PROCEDURE dbo.dt_adduserobject
go


DROP PROCEDURE dbo.dt_addtosourcecontrol
go


DROP PROCEDURE dbo.dt_adduserobject_vcs
go


DROP PROCEDURE dbo.dt_checkinobject
go


DROP PROCEDURE dbo.dt_checkoutobject
go


DROP PROCEDURE dbo.dt_droppropertiesbyid
go


DROP PROCEDURE dbo.dt_dropuserobjectbyid
go


DROP PROCEDURE dbo.dt_generateansiname
go


DROP PROCEDURE dbo.dt_getobjwithprop
go


DROP PROCEDURE dbo.dt_getobjwithprop_u
go


DROP PROCEDURE dbo.dt_getpropertiesbyid
go


DROP PROCEDURE dbo.dt_getpropertiesbyid_u
go


DROP PROCEDURE dbo.dt_getpropertiesbyid_vcs
go


DROP PROCEDURE dbo.dt_isundersourcecontrol
go


DROP PROCEDURE dbo.dt_removefromsourcecontrol
go


DROP PROCEDURE dbo.dt_setpropertybyid
go


DROP PROCEDURE dbo.dt_setpropertybyid_u
go


DROP PROCEDURE dbo.dt_validateloginparams
go


DROP PROCEDURE dbo.dt_whocheckedout
go


EXEC sp_rename 'dbo.DF__dtpropert__versi__45544755','dbo.DF__dtpropert__versi__45544755_b2f55366'
go


EXEC sp_rename N'dbo.dtproperties',N'dtproperties_a3b24350',N'OBJECT'
go


DROP FUNCTION dbo.BaseChar
go


DROP FUNCTION dbo.CombiningChar
go


DROP FUNCTION dbo.Digit
go


DROP FUNCTION dbo.Extender
go


DROP FUNCTION dbo.Ideographic
go


DROP FUNCTION dbo.Letter
go


DROP FUNCTION dbo.NameChar
go


DROP FUNCTION dbo.SMC_IsValidName
go


DROP FUNCTION dbo.SMC_Meta_ClassInstances_Hist
go


DROP FUNCTION dbo.SMC_Meta_PropertyInstances_Hist
go


DROP FUNCTION dbo.SMC_Meta_RelationshipInstances_Hist
go


DROP FUNCTION dbo.ValidStartChar
go


DROP FUNCTION dbo.fn_ConvertToLocalDate
go


DROP FUNCTION dbo.fn_ExpandString
go


DROP FUNCTION dbo.fn_GetComputerIDsInGroup
go


DROP FUNCTION dbo.fn_GetComputersInGroup
go


DROP FUNCTION dbo.fn_GetDateRange
go


DROP FUNCTION dbo.fn_GetManagedComputers
go


DROP FUNCTION dbo.fn_GetOperationalDataIDs
go


DROP FUNCTION dbo.fn_GetProductID
go


DROP FUNCTION dbo.fn_ListComputerGroups
go


DROP FUNCTION dbo.fn_MaxDateTimeOfTransfer
go


DROP FUNCTION dbo.fn_ToLocalDate
go


DROP PROCEDURE dbo.SMC_DeleteRelationshipConstraint
go


DROP PROCEDURE dbo.SMC_GetClasses
go


DROP PROCEDURE dbo.SMC_GetConstraints
go


DROP PROCEDURE dbo.SMC_Internal_GetAllChanges
go


DROP PROCEDURE dbo.SMC_Internal_GetChanges
go


DROP PROCEDURE dbo.SMC_UpdateRelationshipConstraint
go


DROP PROCEDURE dbo.SMC_internal_CheckQuerySyntax
go


DROP PROCEDURE dbo.dt_addtosourcecontrol_u
go


DROP PROCEDURE dbo.dt_checkinobject_u
go


DROP PROCEDURE dbo.dt_checkoutobject_u
go


DROP PROCEDURE dbo.dt_displayoaerror
go


DROP PROCEDURE dbo.dt_displayoaerror_u
go


DROP PROCEDURE dbo.dt_getpropertiesbyid_vcs_u
go


DROP PROCEDURE dbo.dt_isundersourcecontrol_u
go


DROP PROCEDURE dbo.dt_validateloginparams_u
go


DROP PROCEDURE dbo.dt_vcsenabled
go


DROP PROCEDURE dbo.dt_verstamp006
go


DROP PROCEDURE dbo.dt_verstamp007
go


DROP PROCEDURE dbo.dt_whocheckedout_u
go


DROP PROCEDURE dbo.p_ComputeWatermark
go


DROP PROCEDURE dbo.p_CreateDWGroomJob
go


DROP PROCEDURE dbo.p_CreateDynamicViews
go


DROP PROCEDURE dbo.p_CreateIndexes
go


DROP PROCEDURE dbo.p_CreateLinkedServer
go


DROP PROCEDURE dbo.p_CreateLogin
go


DROP PROCEDURE dbo.p_CreateViewsForClassOrRelationshipDefinitions
go


DROP PROCEDURE dbo.p_DeleteDWGroomJob
go


DROP PROCEDURE dbo.p_DeleteIndexes
go


DROP PROCEDURE dbo.p_DeleteLinkedServer
go


DROP PROCEDURE dbo.p_ExchangeServer2003ClientMonitoringReport
go


DROP PROCEDURE dbo.p_GetNullCurrentEndTime
go


DROP PROCEDURE dbo.p_GroomDatawarehouseTables
go


DROP PROCEDURE dbo.p_MOMCapacityPlanningReport
go


DROP PROCEDURE dbo.p_MOMCapacityPlanningReportDetail
go


DROP PROCEDURE dbo.p_MOMLicensesInUseReport
go


DROP PROCEDURE dbo.p_PopulateDateDimension
go


DROP PROCEDURE dbo.p_PopulateOperationalDataDimension
go


DROP PROCEDURE dbo.p_PopulateTimeDimension
go


DROP PROCEDURE dbo.p_SQLBackupHistoryReport
go


DROP PROCEDURE dbo.p_SQLBlockAnalysisDetailReport
go


DROP PROCEDURE dbo.p_SQLBlockAnalysisReport
go


DROP PROCEDURE dbo.p_SQLTop25FailedloginsReport
go


DROP PROCEDURE dbo.p_SQLTop25SuccessfulLoginsReport
go


DROP PROCEDURE dbo.p_SetupLogins
go


DROP PROCEDURE dbo.p_UpdateCurrentEndTime
go


DROP PROCEDURE dbo.p_UpdateGroomDays
go


DROP PROCEDURE dbo.p_UpsertCurrentStartAndEndTime
go


DROP PROCEDURE dbo.p_UpsertCurrentStartTime
go


DROP PROCEDURE dbo.smc_CheckExistsObject
go


DROP PROCEDURE dbo.smc_InsertClassIndex
go


DROP PROCEDURE dbo.smc_InsertClassIndexColumn
go


DROP PROCEDURE dbo.smc_InsertClassProperty
go


DROP PROCEDURE dbo.smc_InsertClassSchema
go


DROP PROCEDURE dbo.smc_InsertFileGroup
go


DROP PROCEDURE dbo.smc_InsertFunctionParameter
go


DROP PROCEDURE dbo.smc_InsertProductSchema
go


DROP PROCEDURE dbo.smc_InsertPropertyType
go


DROP PROCEDURE dbo.smc_InsertRelationshipConstraint
go


DROP PROCEDURE dbo.smc_InsertRelationshipType
go


DROP PROCEDURE dbo.smc_InsertWarehouseClassProperty
go


DROP PROCEDURE dbo.smc_InsertWarehouseClassSchema
go


DROP PROCEDURE dbo.smc_InsertWarehouseClassSchemaToProductSchema
go


DROP PROCEDURE dbo.smc_InsertWarehouseGroomingInfo
go


DROP PROCEDURE dbo.smc_dropobject
go


DROP PROCEDURE dbo.smc_insertenumeration
go


DROP PROCEDURE dbo.smc_instance_info
go


DROP PROCEDURE dbo.smc_internal_IsValidClassSPValidator
go


DROP PROCEDURE dbo.smc_internal_IsValidPropertyValidator
go


DROP PROCEDURE dbo.smc_internal_alter_insertview
go


DROP PROCEDURE dbo.smc_internal_truncatetable
go


DROP PROCEDURE dbo.smc_partitioning
go


DROP PROCEDURE dbo.smo_InsertCSharpAssembly
go


DROP PROCEDURE dbo.smo_InsertCSharpType
go


DROP PROCEDURE dbo.smo_InsertClassMethod
go


DROP PROCEDURE dbo.smo_InsertClassProperty
go


DROP PROCEDURE dbo.smo_InsertClassSchema
go


DROP PROCEDURE dbo.smo_InsertRelationshipType
go


DROP PROCEDURE dbo.smo_InsertSMCClass
go


DROP PROCEDURE dbo.smo_InsertSMCClassJoin
go


DROP PROCEDURE dbo.smo_InsertTypeConversion
go


EXEC sp_revokedbaccess N'dbo'
go


IF SUSER_SID(N'sa') IS NULL
    EXEC sp_addlogin N'sa', N'dbo'
go


EXEC sp_grantdbaccess N'sa', N'dbo'
go


EXEC sp_addrolemember N'db_owner', N'dbo'
go


ALTER TABLE dbo.SMC_GroupsForInstance
    ADD CONSTRAINT PK__SMC_GroupsForIns__14B10FFA
    PRIMARY KEY CLUSTERED (SMC_InstanceID)

go

ALTER TABLE dbo.SMC_MembersInGroup
    ADD CONSTRAINT PK__SMC_MembersInGro__1699586C
    PRIMARY KEY CLUSTERED (SMC_InstanceID)

go

CREATE TABLE dbo.DatatypeDefinitions
(
    DD_DatatypeID             int           NOT NULL,
    DD_Name                   nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    DD_Description            nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    DD_RequiresLength         bit           CONSTRAINT DF_DatatypeDefinitions_DD_SupportsLength DEFAULT 0 NOT NULL,
    DD_RequiresScalePrecision bit           CONSTRAINT DF_DatatypeDefinitions_DD_SupportsScalePrecision DEFAULT 0 NOT NULL,
    DD_VariableLength         bit           CONSTRAINT DF_DatatypeDefinitions_DD_VariableLength DEFAULT 0 NOT NULL,
    DD_MaxLength              int           CONSTRAINT DF_DatatypeDefinitions_DD_MaxLength DEFAULT 0 NOT NULL,
    DD_IsBlob                 bit           CONSTRAINT DF_DatatypeDefinitions_DD_IsBlob DEFAULT 0 NOT NULL
)
go


INSERT INTO SCR.dbo.DatatypeDefinitions
( DD_DatatypeID,
  DD_Name,
  DD_Description,
  DD_RequiresLength,
  DD_RequiresScalePrecision,
  DD_VariableLength,
  DD_MaxLength,
  DD_IsBlob ) 
SELECT
DD_DatatypeID,
DD_Name,
DD_Description,
DD_RequiresLength,
DD_RequiresScalePrecision,
DD_VariableLength,
DD_MaxLength,
DD_IsBlob
FROM SCR.dbo.DatatypeDefinitions_7d162e19
go


CREATE TABLE dbo.DllDefinitions
(
    DD_DllID   uniqueidentifier CONSTRAINT DF_DllDefinitions_DD_DllID DEFAULT newid() NOT NULL,
    DD_DllName nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    DD_CLSID   uniqueidentifier NULL,
    DD_DllPath nvarchar(256)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
go


INSERT INTO SCR.dbo.DllDefinitions
( DD_DllID,
  DD_DllName,
  DD_CLSID,
  DD_DllPath ) 
SELECT
DD_DllID,
DD_DllName,
DD_CLSID,
DD_DllPath
FROM SCR.dbo.DllDefinitions_22833156
go


CREATE TABLE dbo.EventsQueue
(
    EQ_EventID                bigint           IDENTITY,
    EQ_Action                 char(1)          COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    EQ_CreationModID          bigint           NOT NULL,
    EQ_InstanceID             uniqueidentifier NULL,
    EQ_ClassID                uniqueidentifier NULL,
    EQ_RelationshipInstanceID uniqueidentifier NULL,
    EQ_RelationshipTypeID     uniqueidentifier NULL,
    EQ_SourceInstanceID       uniqueidentifier NULL,
    EQ_TargetInstanceID       uniqueidentifier NULL
)
go


SET IDENTITY_INSERT SCR.dbo.EventsQueue ON
go


INSERT INTO SCR.dbo.EventsQueue
( EQ_EventID,
  EQ_Action,
  EQ_CreationModID,
  EQ_InstanceID,
  EQ_ClassID,
  EQ_RelationshipInstanceID,
  EQ_RelationshipTypeID,
  EQ_SourceInstanceID,
  EQ_TargetInstanceID ) 
SELECT
EQ_EventID,
EQ_Action,
EQ_CreationModID,
EQ_InstanceID,
EQ_ClassID,
EQ_RelationshipInstanceID,
EQ_RelationshipTypeID,
EQ_SourceInstanceID,
EQ_TargetInstanceID
FROM SCR.dbo.EventsQueue_bdeda739
go


SET IDENTITY_INSERT SCR.dbo.EventsQueue OFF
go


CREATE TABLE dbo.FileGroups
(
    FG_FileGroupID uniqueidentifier NOT NULL,
    FG_Name        nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
go


INSERT INTO SCR.dbo.FileGroups
( FG_FileGroupID,
  FG_Name ) 
SELECT
FG_FileGroupID,
FG_Name
FROM SCR.dbo.FileGroups_2c1707cf
go


CREATE TABLE dbo.GroomingSettings
(
    GS_DataWarehouseInUse bit     NOT NULL,
    GS_LiveDataPeriod     tinyint NOT NULL
)
go


INSERT INTO SCR.dbo.GroomingSettings
( GS_DataWarehouseInUse,
  GS_LiveDataPeriod ) 
SELECT
GS_DataWarehouseInUse,
GS_LiveDataPeriod
FROM SCR.dbo.GroomingSettings_0fb9f48d
go


CREATE TABLE dbo.MetaVersion
(
    MV_MajorVersion int           NOT NULL,
    MV_MinorVersion int           CONSTRAINT DF_SMC_MetaVersion_MV_MinorVersion DEFAULT 0 NOT NULL,
    MV_Name         nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    MV_Description  nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    MV_CreationDate datetime      NOT NULL
)
go


INSERT INTO SCR.dbo.MetaVersion
( MV_MajorVersion,
  MV_MinorVersion,
  MV_Name,
  MV_Description,
  MV_CreationDate ) 
SELECT
MV_MajorVersion,
MV_MinorVersion,
MV_Name,
MV_Description,
MV_CreationDate
FROM SCR.dbo.MetaVersion_9dbc24b5
go


CREATE TABLE dbo.MethodParameterTypes
(
    MPT_ParameterTypeID   int          NOT NULL,
    MPT_ParameterTypeName varchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
go


INSERT INTO SCR.dbo.MethodParameterTypes
( MPT_ParameterTypeID,
  MPT_ParameterTypeName ) 
SELECT
MPT_ParameterTypeID,
MPT_ParameterTypeName
FROM SCR.dbo.MethodParameterTypes_eb73f48c
go


CREATE TABLE dbo.Modifications
(
    M_ModificationID   bigint       IDENTITY,
    M_Date             datetime     NOT NULL,
    M_UserID           int          NOT NULL,
    M_TransactionToken varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
go


SET IDENTITY_INSERT SCR.dbo.Modifications ON
go


INSERT INTO SCR.dbo.Modifications
( M_ModificationID,
  M_Date,
  M_UserID,
  M_TransactionToken ) 
SELECT
M_ModificationID,
M_Date,
M_UserID,
M_TransactionToken
FROM SCR.dbo.Modifications_2582a466
go


SET IDENTITY_INSERT SCR.dbo.Modifications OFF
go


CREATE TABLE dbo.ProductSchema
(
    PS_ProductID         uniqueidentifier NOT NULL,
    PS_ProductName       nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    PS_Description       nvarchar(256)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    PS_PostDTSTransferSP nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
go


INSERT INTO SCR.dbo.ProductSchema
( PS_ProductID,
  PS_ProductName,
  PS_Description,
  PS_PostDTSTransferSP ) 
SELECT
PS_ProductID,
PS_ProductName,
PS_Description,
PS_PostDTSTransferSP
FROM SCR.dbo.ProductSchema_9a0f6057
go


CREATE TABLE dbo.PropertyInstances
(
    PI_ClassID         uniqueidentifier NOT NULL,
    PI_InstanceID      uniqueidentifier NOT NULL,
    PI_ClassPropertyID uniqueidentifier NOT NULL,
    PI_Value           sql_variant      NOT NULL,
    PI_StartModID      bigint           NOT NULL
)
go


INSERT INTO SCR.dbo.PropertyInstances
( PI_ClassID,
  PI_InstanceID,
  PI_ClassPropertyID,
  PI_Value,
  PI_StartModID ) 
SELECT
PI_ClassID,
PI_InstanceID,
PI_ClassPropertyID,
PI_Value,
PI_StartModID
FROM SCR.dbo.PropertyInstances_35cb1d88
go


CREATE TABLE dbo.PropertyInstancesAudits
(
    PIA_ClassID         uniqueidentifier NOT NULL,
    PIA_ClassPropertyID uniqueidentifier NOT NULL,
    PIA_InstanceID      uniqueidentifier NOT NULL,
    PIA_Value           sql_variant      NOT NULL,
    PIA_StartModID      bigint           NOT NULL,
    PIA_EndModID        bigint           NOT NULL,
    PIA_SuserSid        varbinary(85)    CONSTRAINT DF__PropertyI__PIA_S__20C1E124 DEFAULT suser_sid() NULL
)
go


INSERT INTO SCR.dbo.PropertyInstancesAudits
( PIA_ClassID,
  PIA_ClassPropertyID,
  PIA_InstanceID,
  PIA_Value,
  PIA_StartModID,
  PIA_EndModID,
  PIA_SuserSid ) 
SELECT
PIA_ClassID,
PIA_ClassPropertyID,
PIA_InstanceID,
PIA_Value,
PIA_StartModID,
PIA_EndModID,
PIA_SuserSid
FROM SCR.dbo.PropertyInstancesAudits_eff481f7
go


CREATE TABLE dbo.PropertyTypes
(
    PT_TypeID          uniqueidentifier CONSTRAINT DF_PropertySchemas_PS_PropertyID DEFAULT newid() NOT NULL,
    PT_TypeName        nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    PT_DatatypeID      int              NOT NULL,
    PT_Length          int              CONSTRAINT DF_PropertyTypes_PT_Length DEFAULT 0 NOT NULL,
    PT_Scale           smallint         CONSTRAINT DF_PropertyTypes_PT_Scale DEFAULT 0 NOT NULL,
    PT_Precision       smallint         CONSTRAINT DF_PropertyTypes_PT_Precision DEFAULT 0 NOT NULL,
    PT_Description     nvarchar(256)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    PT_IsEnumeration   bit              CONSTRAINT DF_PropertyTypes_PT_IsEnumeration DEFAULT 0 NOT NULL,
    PT_UDFValidationID uniqueidentifier NULL,
    PT_ParentTypeID    uniqueidentifier NULL,
    PT_Deleted         bit              CONSTRAINT DF_PropertySchemas_PS_Deleted DEFAULT 0 NOT NULL,
    PT_System          bit              CONSTRAINT DF_PropertySchemas_PS_System DEFAULT 0 NOT NULL,
    PT_Signed          bit              CONSTRAINT DF_PropertySchemas_PS_Signed DEFAULT 0 NOT NULL,
    PT_SignedModID     bigint           NULL
)
go


INSERT INTO SCR.dbo.PropertyTypes
( PT_TypeID,
  PT_TypeName,
  PT_DatatypeID,
  PT_Length,
  PT_Scale,
  PT_Precision,
  PT_Description,
  PT_IsEnumeration,
  PT_UDFValidationID,
  PT_ParentTypeID,
  PT_Deleted,
  PT_System,
  PT_Signed,
  PT_SignedModID ) 
SELECT
PT_TypeID,
PT_TypeName,
PT_DatatypeID,
PT_Length,
PT_Scale,
PT_Precision,
PT_Description,
PT_IsEnumeration,
PT_UDFValidationID,
PT_ParentTypeID,
PT_Deleted,
PT_System,
PT_Signed,
PT_SignedModID
FROM SCR.dbo.PropertyTypes_0522b909
go


CREATE TABLE dbo.RelationshipTypes
(
    RT_RelationshipTypeID       uniqueidentifier NOT NULL,
    RT_Name                     nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    RT_Description              nvarchar(256)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    RT_ViewName                 nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    RT_ViewSrcName              nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    RT_ViewTargetName           nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    RT_HistoryViewName          nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    RT_HistoryUDFName           nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    RT_Cardinality              varchar(10)      COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT DF_RelationshipTypes_RT_Cardinality DEFAULT 'M:N' NOT NULL,
    RT_MustBeDeleted            bit              CONSTRAINT DF_RelationshipTypes_RT_IsStrong DEFAULT 0 NOT NULL,
    RT_IsConstrained            bit              CONSTRAINT DF_RelationshipTypes_RT_IsConstrained_1 DEFAULT 0 NOT NULL,
    RT_AllowMultipleConstraints bit              CONSTRAINT DF_RelationshipTypes_RT_IsConstrained DEFAULT 0 NOT NULL,
    RT_GenerateView             bit              CONSTRAINT DF_RelationshipTypes_RT_GenerateView DEFAULT 1 NOT NULL,
    RT_NotifyOnInsert           bit              CONSTRAINT DF_RelationshipTypes_RT_NotifyOnInsert DEFAULT 0 NOT NULL,
    RT_NotifyOnUpdate           bit              CONSTRAINT DF_RelationshipTypes_RT_NotifyOnUpdate DEFAULT 0 NOT NULL,
    RT_NotifyOnDelete           bit              CONSTRAINT DF_RelationshipTypes_RT_NotifyOnDelete DEFAULT 0 NOT NULL,
    RT_System                   bit              CONSTRAINT DF_RelationshipTypes_RT_System DEFAULT 0 NOT NULL,
    RT_Signed                   bit              CONSTRAINT DF_RelationshipTypes_RT_Signed DEFAULT 0 NOT NULL,
    RT_IsHighVolume             bit              CONSTRAINT DF_RelationshipTypes_RT_IsHighVolume DEFAULT 0 NOT NULL,
    RT_ViewInvalid              bit              CONSTRAINT DF_RelationshipTypes_RT_ViewInvalid DEFAULT 1 NOT NULL,
    RT_SignedModID              bigint           NULL
)
go


INSERT INTO SCR.dbo.RelationshipTypes
( RT_RelationshipTypeID,
  RT_Name,
  RT_Description,
  RT_ViewName,
  RT_ViewSrcName,
  RT_ViewTargetName,
  RT_HistoryViewName,
  RT_HistoryUDFName,
  RT_Cardinality,
  RT_MustBeDeleted,
  RT_IsConstrained,
  RT_AllowMultipleConstraints,
  RT_GenerateView,
  RT_NotifyOnInsert,
  RT_NotifyOnUpdate,
  RT_NotifyOnDelete,
  RT_System,
  RT_Signed,
  RT_IsHighVolume,
  RT_ViewInvalid,
  RT_SignedModID ) 
SELECT
RT_RelationshipTypeID,
RT_Name,
RT_Description,
RT_ViewName,
RT_ViewSrcName,
RT_ViewTargetName,
RT_HistoryViewName,
RT_HistoryUDFName,
RT_Cardinality,
RT_MustBeDeleted,
RT_IsConstrained,
RT_AllowMultipleConstraints,
RT_GenerateView,
RT_NotifyOnInsert,
RT_NotifyOnUpdate,
RT_NotifyOnDelete,
RT_System,
RT_Signed,
RT_IsHighVolume,
RT_ViewInvalid,
RT_SignedModID
FROM SCR.dbo.RelationshipTypes_58836bba
go


CREATE TABLE dbo.SC_AlertFact_Table
(
    AlertDescription        nvarchar(2000)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    AlertID                 uniqueidentifier NULL,
    AlertID_PK              uniqueidentifier CONSTRAINT DF__SC_AlertF__Alert__50C5FA01 DEFAULT newid() NOT NULL,
    AlertLevel_FK           bigint           NOT NULL,
    AlertName               nvarchar(255)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    AlertResolutionState_FK bigint           CONSTRAINT DF__SC_AlertF__Alert__51BA1E3A DEFAULT 1 NOT NULL,
    Computer_FK             bigint           NOT NULL,
    ConfigurationGroup_FK   bigint           NOT NULL,
    Culprit                 nvarchar(255)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    DateAdded_FK            bigint           NOT NULL,
    DateOfFirstEvent_FK     bigint           NOT NULL,
    DateOfLastEvent_FK      bigint           NOT NULL,
    DateRaised_FK           bigint           NOT NULL,
    DateTimeAdded           datetime         NOT NULL,
    DateTimeLastModified    datetime         CONSTRAINT DF__SC_AlertF__DateT__52AE4273 DEFAULT getdate() NOT NULL,
    DateTimeOfFirstEvent    datetime         NULL,
    DateTimeOfLastEvent     datetime         NULL,
    DateTimeRaised          datetime         NOT NULL,
    DateTimeResolved        datetime         NULL,
    DateTimeStateModified   datetime         NULL,
    LocalDateAdded_FK       bigint           CONSTRAINT DF__SC_AlertF__Local__53A266AC DEFAULT 1 NOT NULL,
    LocalDateRaised_FK      bigint           CONSTRAINT DF__SC_AlertF__Local__54968AE5 DEFAULT 1 NOT NULL,
    LocalDateTimeAdded      datetime         CONSTRAINT DF__SC_AlertF__Local__558AAF1E DEFAULT getdate() NOT NULL,
    LocalDateTimeRaised     datetime         CONSTRAINT DF__SC_AlertF__Local__567ED357 DEFAULT getdate() NOT NULL,
    LocalDateTimeResolved   datetime         NULL,
    LocalTimeAdded_FK       bigint           CONSTRAINT DF__SC_AlertF__Local__5772F790 DEFAULT 1 NOT NULL,
    LocalTimeRaised_FK      bigint           CONSTRAINT DF__SC_AlertF__Local__58671BC9 DEFAULT 1 NOT NULL,
    ProcessRule_FK          bigint           NOT NULL,
    RepeatCount             bigint           NULL,
    SMC_InstanceID          bigint           IDENTITY,
    TimeAdded_FK            bigint           NOT NULL,
    TimeOfFirstEvent_FK     bigint           NOT NULL,
    TimeOfLastEvent_FK      bigint           NOT NULL,
    TimeRaised_FK           bigint           NOT NULL,
    UserResolvedBy_FK       bigint           CONSTRAINT DF__SC_AlertF__UserR__595B4002 DEFAULT 1 NOT NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_AlertFact_Table ON
go


INSERT INTO SCR.dbo.SC_AlertFact_Table
( AlertDescription,
  AlertID,
  AlertID_PK,
  AlertLevel_FK,
  AlertName,
  AlertResolutionState_FK,
  Computer_FK,
  ConfigurationGroup_FK,
  Culprit,
  DateAdded_FK,
  DateOfFirstEvent_FK,
  DateOfLastEvent_FK,
  DateRaised_FK,
  DateTimeAdded,
  DateTimeLastModified,
  DateTimeOfFirstEvent,
  DateTimeOfLastEvent,
  DateTimeRaised,
  DateTimeResolved,
  DateTimeStateModified,
  LocalDateAdded_FK,
  LocalDateRaised_FK,
  LocalDateTimeAdded,
  LocalDateTimeRaised,
  LocalDateTimeResolved,
  LocalTimeAdded_FK,
  LocalTimeRaised_FK,
  ProcessRule_FK,
  RepeatCount,
  SMC_InstanceID,
  TimeAdded_FK,
  TimeOfFirstEvent_FK,
  TimeOfLastEvent_FK,
  TimeRaised_FK,
  UserResolvedBy_FK ) 
SELECT
AlertDescription,
AlertID,
AlertID_PK,
AlertLevel_FK,
AlertName,
AlertResolutionState_FK,
Computer_FK,
ConfigurationGroup_FK,
Culprit,
DateAdded_FK,
DateOfFirstEvent_FK,
DateOfLastEvent_FK,
DateRaised_FK,
DateTimeAdded,
DateTimeLastModified,
DateTimeOfFirstEvent,
DateTimeOfLastEvent,
DateTimeRaised,
DateTimeResolved,
DateTimeStateModified,
LocalDateAdded_FK,
LocalDateRaised_FK,
LocalDateTimeAdded,
LocalDateTimeRaised,
LocalDateTimeResolved,
LocalTimeAdded_FK,
LocalTimeRaised_FK,
ProcessRule_FK,
RepeatCount,
SMC_InstanceID,
TimeAdded_FK,
TimeOfFirstEvent_FK,
TimeOfLastEvent_FK,
TimeRaised_FK,
UserResolvedBy_FK
FROM SCR.dbo.SC_AlertFact_Table_87a2789c
go


SET IDENTITY_INSERT SCR.dbo.SC_AlertFact_Table OFF
go


CREATE TABLE dbo.SC_AlertHistoryFact_Table
(
    AlertID                 uniqueidentifier NOT NULL,
    AlertResolutionState_FK bigint           NOT NULL,
    Comments                nvarchar(3000)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    ConfigurationGroup_FK   bigint           NOT NULL,
    CustomField1            nvarchar(50)     COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CustomField2            nvarchar(50)     COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CustomField3            nvarchar(50)     COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CustomField4            nvarchar(50)     COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CustomField5            nvarchar(50)     COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    DateLastModified_FK     bigint           NOT NULL,
    DateResolved_FK         bigint           NOT NULL,
    DateStateModified_FK    bigint           NOT NULL,
    DateTimeLastModified    datetime         NOT NULL,
    DateTimeResolved        datetime         NULL,
    DateTimeStateModified   datetime         NULL,
    LocalDateResolved_FK    bigint           CONSTRAINT DF__SC_AlertH__Local__1D114BD1 DEFAULT 1 NOT NULL,
    LocalDateTimeResolved   datetime         CONSTRAINT DF__SC_AlertH__Local__1E05700A DEFAULT getdate() NULL,
    LocalTimeResolved_FK    bigint           CONSTRAINT DF__SC_AlertH__Local__1EF99443 DEFAULT 1 NOT NULL,
    SMC_InstanceID          bigint           IDENTITY,
    TimeLastModified_FK     bigint           NOT NULL,
    TimeResolved_FK         bigint           NOT NULL,
    TimeStateModified_FK    bigint           NOT NULL,
    UserLastModified_FK     bigint           NOT NULL,
    UserOwner_FK            bigint           NOT NULL,
    UserResolvedBy_FK       bigint           NOT NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_AlertHistoryFact_Table ON
go


INSERT INTO SCR.dbo.SC_AlertHistoryFact_Table
( AlertID,
  AlertResolutionState_FK,
  Comments,
  ConfigurationGroup_FK,
  CustomField1,
  CustomField2,
  CustomField3,
  CustomField4,
  CustomField5,
  DateLastModified_FK,
  DateResolved_FK,
  DateStateModified_FK,
  DateTimeLastModified,
  DateTimeResolved,
  DateTimeStateModified,
  LocalDateResolved_FK,
  LocalDateTimeResolved,
  LocalTimeResolved_FK,
  SMC_InstanceID,
  TimeLastModified_FK,
  TimeResolved_FK,
  TimeStateModified_FK,
  UserLastModified_FK,
  UserOwner_FK,
  UserResolvedBy_FK ) 
SELECT
AlertID,
AlertResolutionState_FK,
Comments,
ConfigurationGroup_FK,
CustomField1,
CustomField2,
CustomField3,
CustomField4,
CustomField5,
DateLastModified_FK,
DateResolved_FK,
DateStateModified_FK,
DateTimeLastModified,
DateTimeResolved,
DateTimeStateModified,
LocalDateResolved_FK,
LocalDateTimeResolved,
LocalTimeResolved_FK,
SMC_InstanceID,
TimeLastModified_FK,
TimeResolved_FK,
TimeStateModified_FK,
UserLastModified_FK,
UserOwner_FK,
UserResolvedBy_FK
FROM SCR.dbo.SC_AlertHistoryFact_Table_127cbb8a
go


SET IDENTITY_INSERT SCR.dbo.SC_AlertHistoryFact_Table OFF
go


CREATE TABLE dbo.SC_AlertLevelDimension_Table
(
    AlertLevel_PK   int          NOT NULL,
    AlertLevelColor nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    AlertLevelName  nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [Language]      int          NOT NULL,
    SMC_InstanceID  bigint       IDENTITY
)
go


SET IDENTITY_INSERT SCR.dbo.SC_AlertLevelDimension_Table ON
go


INSERT INTO SCR.dbo.SC_AlertLevelDimension_Table
( AlertLevel_PK,
  AlertLevelColor,
  AlertLevelName,
  [Language],
  SMC_InstanceID ) 
SELECT
AlertLevel_PK,
AlertLevelColor,
AlertLevelName,
[Language],
SMC_InstanceID
FROM SCR.dbo.SC_AlertLevelDimension_Table_2cd9522b
go


SET IDENTITY_INSERT SCR.dbo.SC_AlertLevelDimension_Table OFF
go


CREATE TABLE dbo.SC_AlertResolutionStateDimension_Table
(
    AlertResolutionState_PK         int           NOT NULL,
    AlertResolutionStateDescription nvarchar(512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SMC_InstanceID                  bigint        IDENTITY
)
go


SET IDENTITY_INSERT SCR.dbo.SC_AlertResolutionStateDimension_Table ON
go


INSERT INTO SCR.dbo.SC_AlertResolutionStateDimension_Table
( AlertResolutionState_PK,
  AlertResolutionStateDescription,
  SMC_InstanceID ) 
SELECT
AlertResolutionState_PK,
AlertResolutionStateDescription,
SMC_InstanceID
FROM SCR.dbo.SC_AlertResolutionStateDimension_Table_31ce82d5
go


SET IDENTITY_INSERT SCR.dbo.SC_AlertResolutionStateDimension_Table OFF
go


CREATE TABLE dbo.SC_AlertToEventFact_Table
(
    AlertID               uniqueidentifier NOT NULL,
    ConfigurationGroup_FK bigint           NOT NULL,
    DateTimeAlertAdded    datetime         NOT NULL,
    DateTimeEventStored   datetime         CONSTRAINT DF__SC_AlertT__DateT__78D3EB5B DEFAULT getutcdate() NOT NULL,
    EventID               uniqueidentifier NOT NULL,
    SMC_InstanceID        bigint           IDENTITY
)
go


SET IDENTITY_INSERT SCR.dbo.SC_AlertToEventFact_Table ON
go


INSERT INTO SCR.dbo.SC_AlertToEventFact_Table
( AlertID,
  ConfigurationGroup_FK,
  DateTimeAlertAdded,
  DateTimeEventStored,
  EventID,
  SMC_InstanceID ) 
SELECT
AlertID,
ConfigurationGroup_FK,
DateTimeAlertAdded,
DateTimeEventStored,
EventID,
SMC_InstanceID
FROM SCR.dbo.SC_AlertToEventFact_Table_dbcbafa5
go


SET IDENTITY_INSERT SCR.dbo.SC_AlertToEventFact_Table OFF
go


CREATE TABLE dbo.SC_ClassAttributeDefinitionDimension_Table
(
    ClassAttributeID_PK uniqueidentifier NOT NULL,
    ClassAttributeName  nvarchar(255)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    ClassDefinition_FK  bigint           NOT NULL,
    DateTimeAdded       datetime         NULL,
    Description         nvarchar(255)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    IsEnabled           bit              NULL,
    IsPrimaryKey        bit              NOT NULL,
    SMC_InstanceID      bigint           IDENTITY
)
go


SET IDENTITY_INSERT SCR.dbo.SC_ClassAttributeDefinitionDimension_Table ON
go


INSERT INTO SCR.dbo.SC_ClassAttributeDefinitionDimension_Table
( ClassAttributeID_PK,
  ClassAttributeName,
  ClassDefinition_FK,
  DateTimeAdded,
  Description,
  IsEnabled,
  IsPrimaryKey,
  SMC_InstanceID ) 
SELECT
ClassAttributeID_PK,
ClassAttributeName,
ClassDefinition_FK,
DateTimeAdded,
Description,
IsEnabled,
IsPrimaryKey,
SMC_InstanceID
FROM SCR.dbo.SC_ClassAttributeDefinitionDimension_Table_ea6082b2
go


SET IDENTITY_INSERT SCR.dbo.SC_ClassAttributeDefinitionDimension_Table OFF
go


CREATE TABLE dbo.SC_ClassAttributeInstanceFact_Table
(
    ClassAttributeDefinition_FK bigint           NOT NULL,
    ClassAttributeInstanceID    uniqueidentifier NOT NULL,
    ClassInstanceID             uniqueidentifier NOT NULL,
    ClassInstanceKeyValue       nvarchar(400)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    ConfigurationGroup_FK       bigint           NOT NULL,
    DateAdded_FK                bigint           NOT NULL,
    DateLastModified_FK         bigint           NOT NULL,
    DateTimeAdded               datetime         NOT NULL,
    DateTimeLastModified        datetime         NOT NULL,
    DateTimeOfTransfer          datetime         CONSTRAINT DF__SC_ClassA__DateT__025D5595 DEFAULT getutcdate() NOT NULL,
    SMC_InstanceID              bigint           IDENTITY,
    TimeAdded_FK                bigint           NOT NULL,
    TimeLastModified_FK         bigint           NOT NULL,
    UserLastModified_FK         bigint           NOT NULL,
    [Value]                     nvarchar(255)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_ClassAttributeInstanceFact_Table ON
go


INSERT INTO SCR.dbo.SC_ClassAttributeInstanceFact_Table
( ClassAttributeDefinition_FK,
  ClassAttributeInstanceID,
  ClassInstanceID,
  ClassInstanceKeyValue,
  ConfigurationGroup_FK,
  DateAdded_FK,
  DateLastModified_FK,
  DateTimeAdded,
  DateTimeLastModified,
  DateTimeOfTransfer,
  SMC_InstanceID,
  TimeAdded_FK,
  TimeLastModified_FK,
  UserLastModified_FK,
  [Value] ) 
SELECT
ClassAttributeDefinition_FK,
ClassAttributeInstanceID,
ClassInstanceID,
ClassInstanceKeyValue,
ConfigurationGroup_FK,
DateAdded_FK,
DateLastModified_FK,
DateTimeAdded,
DateTimeLastModified,
DateTimeOfTransfer,
SMC_InstanceID,
TimeAdded_FK,
TimeLastModified_FK,
UserLastModified_FK,
[Value]
FROM SCR.dbo.SC_ClassAttributeInstanceFact_Table_8c7b83e6
go


SET IDENTITY_INSERT SCR.dbo.SC_ClassAttributeInstanceFact_Table OFF
go


CREATE TABLE dbo.SC_ClassDefinitionDimension_Table
(
    ClassID_PK     uniqueidentifier NOT NULL,
    Description    nvarchar(512)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    Name           nvarchar(255)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SMC_InstanceID bigint           IDENTITY
)
go


SET IDENTITY_INSERT SCR.dbo.SC_ClassDefinitionDimension_Table ON
go


INSERT INTO SCR.dbo.SC_ClassDefinitionDimension_Table
( ClassID_PK,
  Description,
  Name,
  SMC_InstanceID ) 
SELECT
ClassID_PK,
Description,
Name,
SMC_InstanceID
FROM SCR.dbo.SC_ClassDefinitionDimension_Table_b498aacd
go


SET IDENTITY_INSERT SCR.dbo.SC_ClassDefinitionDimension_Table OFF
go


CREATE TABLE dbo.SC_ClassInstanceFact_Table
(
    ClassDefinition_FK    bigint           NOT NULL,
    ClassInstanceID       uniqueidentifier NOT NULL,
    ConfigurationGroup_FK bigint           NOT NULL,
    DateAdded_FK          bigint           NOT NULL,
    DateLastModified_FK   bigint           NOT NULL,
    DateTimeAdded         datetime         NOT NULL,
    DateTimeLastModified  datetime         NOT NULL,
    DateTimeOfTransfer    datetime         CONSTRAINT DF__SC_ClassI__DateT__25A691D2 DEFAULT getutcdate() NOT NULL,
    KeyValue              nvarchar(400)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SMC_InstanceID        bigint           IDENTITY,
    State                 int              NULL,
    TimeAdded_FK          bigint           NOT NULL,
    TimeLastModified_FK   bigint           NOT NULL,
    UserLastModified_FK   bigint           NOT NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_ClassInstanceFact_Table ON
go


INSERT INTO SCR.dbo.SC_ClassInstanceFact_Table
( ClassDefinition_FK,
  ClassInstanceID,
  ConfigurationGroup_FK,
  DateAdded_FK,
  DateLastModified_FK,
  DateTimeAdded,
  DateTimeLastModified,
  DateTimeOfTransfer,
  KeyValue,
  SMC_InstanceID,
  State,
  TimeAdded_FK,
  TimeLastModified_FK,
  UserLastModified_FK ) 
SELECT
ClassDefinition_FK,
ClassInstanceID,
ConfigurationGroup_FK,
DateAdded_FK,
DateLastModified_FK,
DateTimeAdded,
DateTimeLastModified,
DateTimeOfTransfer,
KeyValue,
SMC_InstanceID,
State,
TimeAdded_FK,
TimeLastModified_FK,
UserLastModified_FK
FROM SCR.dbo.SC_ClassInstanceFact_Table_8e4bdb5a
go


SET IDENTITY_INSERT SCR.dbo.SC_ClassInstanceFact_Table OFF
go


CREATE TABLE dbo.SC_ComputerDimension_Table
(
    ComputerDomain_PK     nvarchar(100)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    ComputerID            uniqueidentifier NOT NULL,
    ComputerName_PK       nvarchar(255)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    ComputerType          int              NOT NULL,
    DateTimeLastContacted datetime         NULL,
    Description           nvarchar(255)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    DNSName               nvarchar(512)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    FullComputerName      nvarchar(512)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    IsAgent               bit              CONSTRAINT DF__SC_Comput__IsAge__4924D839 DEFAULT 0 NOT NULL,
    IsCollector           bit              CONSTRAINT DF__SC_Comput__IsCol__4A18FC72 DEFAULT 0 NOT NULL,
    SMC_InstanceID        bigint           IDENTITY
)
go


SET IDENTITY_INSERT SCR.dbo.SC_ComputerDimension_Table ON
go


INSERT INTO SCR.dbo.SC_ComputerDimension_Table
( ComputerDomain_PK,
  ComputerID,
  ComputerName_PK,
  ComputerType,
  DateTimeLastContacted,
  Description,
  DNSName,
  FullComputerName,
  IsAgent,
  IsCollector,
  SMC_InstanceID ) 
SELECT
ComputerDomain_PK,
ComputerID,
ComputerName_PK,
ComputerType,
DateTimeLastContacted,
Description,
DNSName,
FullComputerName,
IsAgent,
IsCollector,
SMC_InstanceID
FROM SCR.dbo.SC_ComputerDimension_Table_cca094f5
go


SET IDENTITY_INSERT SCR.dbo.SC_ComputerDimension_Table OFF
go


CREATE TABLE dbo.SC_ComputerRuleDimension_Table
(
    ComputerRuleID_PK uniqueidentifier NOT NULL,
    Description       nvarchar(1000)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    Expression        nvarchar(1000)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    IsEnabled         bit              NOT NULL,
    Name              nvarchar(255)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SMC_InstanceID    bigint           IDENTITY,
    [Type ]           int              NOT NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_ComputerRuleDimension_Table ON
go


INSERT INTO SCR.dbo.SC_ComputerRuleDimension_Table
( ComputerRuleID_PK,
  Description,
  Expression,
  IsEnabled,
  Name,
  SMC_InstanceID,
  [Type ] ) 
SELECT
ComputerRuleID_PK,
Description,
Expression,
IsEnabled,
Name,
SMC_InstanceID,
[Type ]
FROM SCR.dbo.SC_ComputerRuleDimension_Table_84a26c2d
go


SET IDENTITY_INSERT SCR.dbo.SC_ComputerRuleDimension_Table OFF
go


CREATE TABLE dbo.SC_ComputerRuleToProcessRuleGroupFact_Table
(
    ComputerRule_FK       bigint   NOT NULL,
    ConfigurationGroup_FK bigint   NOT NULL,
    DateAdded_FK          bigint   NOT NULL,
    DateTimeAdded         datetime NOT NULL,
    DateTimeOfTransfer    datetime CONSTRAINT DF__SC_Comput__DateT__6F4A8121 DEFAULT getutcdate() NOT NULL,
    ProcessRuleGroup_FK   bigint   NOT NULL,
    SMC_InstanceID        bigint   IDENTITY,
    TimeAdded_FK          bigint   NOT NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_ComputerRuleToProcessRuleGroupFact_Table ON
go


INSERT INTO SCR.dbo.SC_ComputerRuleToProcessRuleGroupFact_Table
( ComputerRule_FK,
  ConfigurationGroup_FK,
  DateAdded_FK,
  DateTimeAdded,
  DateTimeOfTransfer,
  ProcessRuleGroup_FK,
  SMC_InstanceID,
  TimeAdded_FK ) 
SELECT
ComputerRule_FK,
ConfigurationGroup_FK,
DateAdded_FK,
DateTimeAdded,
DateTimeOfTransfer,
ProcessRuleGroup_FK,
SMC_InstanceID,
TimeAdded_FK
FROM SCR.dbo.SC_ComputerRuleToProcessRuleGroupFact_Table_315b1fff
go


SET IDENTITY_INSERT SCR.dbo.SC_ComputerRuleToProcessRuleGroupFact_Table OFF
go


CREATE TABLE dbo.SC_ComputerToComputerRuleFact_Table
(
    Computer_FK           bigint   NOT NULL,
    ComputerRule_FK       bigint   NOT NULL,
    ConfigurationGroup_FK bigint   NOT NULL,
    DateAdded_FK          bigint   NOT NULL,
    DateTimeAdded         datetime NOT NULL,
    DateTimeOfTransfer    datetime CONSTRAINT DF__SC_Comput__DateT__30592A6F DEFAULT getutcdate() NOT NULL,
    [Level]               bigint   CONSTRAINT DF__SC_Comput__Level__314D4EA8 DEFAULT 1 NOT NULL,
    SMC_InstanceID        bigint   IDENTITY,
    TimeAdded_FK          bigint   NOT NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_ComputerToComputerRuleFact_Table ON
go


INSERT INTO SCR.dbo.SC_ComputerToComputerRuleFact_Table
( Computer_FK,
  ComputerRule_FK,
  ConfigurationGroup_FK,
  DateAdded_FK,
  DateTimeAdded,
  DateTimeOfTransfer,
  [Level],
  SMC_InstanceID,
  TimeAdded_FK ) 
SELECT
Computer_FK,
ComputerRule_FK,
ConfigurationGroup_FK,
DateAdded_FK,
DateTimeAdded,
DateTimeOfTransfer,
[Level],
SMC_InstanceID,
TimeAdded_FK
FROM SCR.dbo.SC_ComputerToComputerRuleFact_Table_9c9d2f88
go


SET IDENTITY_INSERT SCR.dbo.SC_ComputerToComputerRuleFact_Table OFF
go


CREATE TABLE dbo.SC_ComputerToConfigurationGroupDimension_Table
(
    Computer_FK_PK           bigint NOT NULL,
    ConfigurationGroup_FK_PK bigint NOT NULL,
    SMC_InstanceID           bigint IDENTITY
)
go


SET IDENTITY_INSERT SCR.dbo.SC_ComputerToConfigurationGroupDimension_Table ON
go


INSERT INTO SCR.dbo.SC_ComputerToConfigurationGroupDimension_Table
( Computer_FK_PK,
  ConfigurationGroup_FK_PK,
  SMC_InstanceID ) 
SELECT
Computer_FK_PK,
ConfigurationGroup_FK_PK,
SMC_InstanceID
FROM SCR.dbo.SC_ComputerToConfigurationGroupDimension_Table_316b88e0
go


SET IDENTITY_INSERT SCR.dbo.SC_ComputerToConfigurationGroupDimension_Table OFF
go


CREATE TABLE dbo.SC_ConfigurationGroupDimension_Table
(
    ConfigurationGroupID_PK uniqueidentifier NOT NULL,
    ConfigurationGroupName  nvarchar(50)     COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SMC_InstanceID          bigint           IDENTITY,
    Version                 nvarchar(10)     COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_ConfigurationGroupDimension_Table ON
go


INSERT INTO SCR.dbo.SC_ConfigurationGroupDimension_Table
( ConfigurationGroupID_PK,
  ConfigurationGroupName,
  SMC_InstanceID,
  Version ) 
SELECT
ConfigurationGroupID_PK,
ConfigurationGroupName,
SMC_InstanceID,
Version
FROM SCR.dbo.SC_ConfigurationGroupDimension_Table_699f11f5
go


SET IDENTITY_INSERT SCR.dbo.SC_ConfigurationGroupDimension_Table OFF
go


CREATE TABLE dbo.SC_CounterDetailDimension_Table
(
    CounterID       uniqueidentifier NOT NULL,
    CounterName_PK  nvarchar(150)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    InstanceName_PK nvarchar(150)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    ObjectName_PK   nvarchar(150)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    ScaleFactor     float            NOT NULL,
    ScaleLegend     varchar(10)      COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    SMC_InstanceID  bigint           IDENTITY
)
go


SET IDENTITY_INSERT SCR.dbo.SC_CounterDetailDimension_Table ON
go


INSERT INTO SCR.dbo.SC_CounterDetailDimension_Table
( CounterID,
  CounterName_PK,
  InstanceName_PK,
  ObjectName_PK,
  ScaleFactor,
  ScaleLegend,
  SMC_InstanceID ) 
SELECT
CounterID,
CounterName_PK,
InstanceName_PK,
ObjectName_PK,
ScaleFactor,
ScaleLegend,
SMC_InstanceID
FROM SCR.dbo.SC_CounterDetailDimension_Table_52815212
go


SET IDENTITY_INSERT SCR.dbo.SC_CounterDetailDimension_Table OFF
go


CREATE TABLE dbo.SC_DateDimension_Table
(
    [Date]         datetime NOT NULL,
    DateDay_PK     int      NOT NULL,
    DateMonth_PK   int      NOT NULL,
    DateYear_PK    int      NOT NULL,
    SMC_InstanceID bigint   IDENTITY
)
go


SET IDENTITY_INSERT SCR.dbo.SC_DateDimension_Table ON
go


INSERT INTO SCR.dbo.SC_DateDimension_Table
( [Date],
  DateDay_PK,
  DateMonth_PK,
  DateYear_PK,
  SMC_InstanceID ) 
SELECT
[Date],
DateDay_PK,
DateMonth_PK,
DateYear_PK,
SMC_InstanceID
FROM SCR.dbo.SC_DateDimension_Table_6e7157da
go


SET IDENTITY_INSERT SCR.dbo.SC_DateDimension_Table OFF
go


CREATE TABLE dbo.SC_EventDetailDimension_Table
(
    Category_PK        nvarchar(50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    EventID_PK         int            NOT NULL,
    EventSource_PK     nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    EventSourceMessage nvarchar(3500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    Language_PK        int            NOT NULL,
    MsgID_PK           int            NOT NULL,
    SMC_InstanceID     bigint         IDENTITY
)
go


SET IDENTITY_INSERT SCR.dbo.SC_EventDetailDimension_Table ON
go


INSERT INTO SCR.dbo.SC_EventDetailDimension_Table
( Category_PK,
  EventID_PK,
  EventSource_PK,
  EventSourceMessage,
  Language_PK,
  MsgID_PK,
  SMC_InstanceID ) 
SELECT
Category_PK,
EventID_PK,
EventSource_PK,
EventSourceMessage,
Language_PK,
MsgID_PK,
SMC_InstanceID
FROM SCR.dbo.SC_EventDetailDimension_Table_60b5bffe
go


SET IDENTITY_INSERT SCR.dbo.SC_EventDetailDimension_Table OFF
go


CREATE TABLE dbo.SC_EventFact_Table
(
    Computer_FK            bigint           NOT NULL,
    ComputerLogged_FK      bigint           NOT NULL,
    ConfigurationGroup_FK  bigint           NOT NULL,
    DateGenerated_FK       bigint           NOT NULL,
    DateOfFirstEvent_FK    bigint           NOT NULL,
    DateOfLastEvent_FK     bigint           NOT NULL,
    DateStarted_FK         bigint           NOT NULL,
    DateStored_FK          bigint           NOT NULL,
    DateTimeGenerated      datetime         NOT NULL,
    DateTimeOfFirstEvent   datetime         NULL,
    DateTimeOfLastEvent    datetime         NULL,
    DateTimeStarted        datetime         NULL,
    DateTimeStored         datetime         NOT NULL,
    EventData              image            NULL,
    EventDetail_FK         bigint           NOT NULL,
    EventID                uniqueidentifier NOT NULL,
    EventMessage           nvarchar(3500)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    EventType_FK           bigint           NULL,
    IsAlerted              bit              NOT NULL,
    IsConsolidated         bit              NULL,
    LocalDateGenerated_FK  bigint           CONSTRAINT DF__SC_EventF__Local__0BE6BFCF DEFAULT 1 NOT NULL,
    LocalDateStored_FK     bigint           CONSTRAINT DF__SC_EventF__Local__0CDAE408 DEFAULT 1 NOT NULL,
    LocalDateTimeGenerated datetime         CONSTRAINT DF__SC_EventF__Local__0DCF0841 DEFAULT getdate() NOT NULL,
    LocalDateTimeStored    datetime         CONSTRAINT DF__SC_EventF__Local__0EC32C7A DEFAULT getdate() NOT NULL,
    LocalTimeGenerated_FK  bigint           CONSTRAINT DF__SC_EventF__Local__0FB750B3 DEFAULT 1 NOT NULL,
    LocalTimeStored_FK     bigint           CONSTRAINT DF__SC_EventF__Local__10AB74EC DEFAULT 1 NOT NULL,
    ProviderDetail_FK      bigint           NOT NULL,
    RepeatCount            int              NULL,
    SMC_InstanceID         bigint           IDENTITY,
    TimeGenerated_FK       bigint           NOT NULL,
    TimeOfFirstEvent_FK    bigint           NOT NULL,
    TimeOfLastEvent_FK     bigint           NOT NULL,
    TimeStarted_FK         bigint           NOT NULL,
    TimeStored_FK          bigint           NOT NULL,
    User_FK                bigint           NOT NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_EventFact_Table ON
go


INSERT INTO SCR.dbo.SC_EventFact_Table
( Computer_FK,
  ComputerLogged_FK,
  ConfigurationGroup_FK,
  DateGenerated_FK,
  DateOfFirstEvent_FK,
  DateOfLastEvent_FK,
  DateStarted_FK,
  DateStored_FK,
  DateTimeGenerated,
  DateTimeOfFirstEvent,
  DateTimeOfLastEvent,
  DateTimeStarted,
  DateTimeStored,
  EventData,
  EventDetail_FK,
  EventID,
  EventMessage,
  EventType_FK,
  IsAlerted,
  IsConsolidated,
  LocalDateGenerated_FK,
  LocalDateStored_FK,
  LocalDateTimeGenerated,
  LocalDateTimeStored,
  LocalTimeGenerated_FK,
  LocalTimeStored_FK,
  ProviderDetail_FK,
  RepeatCount,
  SMC_InstanceID,
  TimeGenerated_FK,
  TimeOfFirstEvent_FK,
  TimeOfLastEvent_FK,
  TimeStarted_FK,
  TimeStored_FK,
  User_FK ) 
SELECT
Computer_FK,
ComputerLogged_FK,
ConfigurationGroup_FK,
DateGenerated_FK,
DateOfFirstEvent_FK,
DateOfLastEvent_FK,
DateStarted_FK,
DateStored_FK,
DateTimeGenerated,
DateTimeOfFirstEvent,
DateTimeOfLastEvent,
DateTimeStarted,
DateTimeStored,
EventData,
EventDetail_FK,
EventID,
EventMessage,
EventType_FK,
IsAlerted,
IsConsolidated,
LocalDateGenerated_FK,
LocalDateStored_FK,
LocalDateTimeGenerated,
LocalDateTimeStored,
LocalTimeGenerated_FK,
LocalTimeStored_FK,
ProviderDetail_FK,
RepeatCount,
SMC_InstanceID,
TimeGenerated_FK,
TimeOfFirstEvent_FK,
TimeOfLastEvent_FK,
TimeStarted_FK,
TimeStored_FK,
User_FK
FROM SCR.dbo.SC_EventFact_Table_171058ea
go


SET IDENTITY_INSERT SCR.dbo.SC_EventFact_Table OFF
go


CREATE TABLE dbo.SC_EventParameterFact_Table
(
    ConfigurationGroup_FK bigint           NOT NULL,
    DateTimeEventStored   datetime         NOT NULL,
    EventID               uniqueidentifier NOT NULL,
    EventParameterName    nvarchar(255)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    EventParameterValue   nvarchar(3500)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Position]            int              NOT NULL,
    SMC_InstanceID        bigint           IDENTITY
)
go


SET IDENTITY_INSERT SCR.dbo.SC_EventParameterFact_Table ON
go


INSERT INTO SCR.dbo.SC_EventParameterFact_Table
( ConfigurationGroup_FK,
  DateTimeEventStored,
  EventID,
  EventParameterName,
  EventParameterValue,
  [Position],
  SMC_InstanceID ) 
SELECT
ConfigurationGroup_FK,
DateTimeEventStored,
EventID,
EventParameterName,
EventParameterValue,
[Position],
SMC_InstanceID
FROM SCR.dbo.SC_EventParameterFact_Table_ef793970
go


SET IDENTITY_INSERT SCR.dbo.SC_EventParameterFact_Table OFF
go


CREATE TABLE dbo.SC_EventTypeDimension_Table
(
    Description    nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    EventType_PK   tinyint       NOT NULL,
    SMC_InstanceID bigint        IDENTITY
)
go


SET IDENTITY_INSERT SCR.dbo.SC_EventTypeDimension_Table ON
go


INSERT INTO SCR.dbo.SC_EventTypeDimension_Table
( Description,
  EventType_PK,
  SMC_InstanceID ) 
SELECT
Description,
EventType_PK,
SMC_InstanceID
FROM SCR.dbo.SC_EventTypeDimension_Table_67d4e0f8
go


SET IDENTITY_INSERT SCR.dbo.SC_EventTypeDimension_Table OFF
go


CREATE TABLE dbo.SC_OperationalDataDimension_Table
(
    OperationalDataID uniqueidentifier NOT NULL,
    SMC_InstanceID    bigint           IDENTITY,
    Type              smallint         NOT NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_OperationalDataDimension_Table ON
go


INSERT INTO SCR.dbo.SC_OperationalDataDimension_Table
( OperationalDataID,
  SMC_InstanceID,
  Type ) 
SELECT
OperationalDataID,
SMC_InstanceID,
Type
FROM SCR.dbo.SC_OperationalDataDimension_Table_fe24ff6e
go


SET IDENTITY_INSERT SCR.dbo.SC_OperationalDataDimension_Table OFF
go


CREATE TABLE dbo.SC_ProcessRuleDimension_Table
(
    IsRuleGroup       bit              CONSTRAINT DF__SC_Proces__IsRul__62E4AA3C DEFAULT 0 NOT NULL,
    ProcessRuleID_PK  uniqueidentifier NOT NULL,
    ProcessRuleName   nvarchar(255)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    ProviderDetail_FK bigint           NULL,
    SMC_InstanceID    bigint           IDENTITY
)
go


SET IDENTITY_INSERT SCR.dbo.SC_ProcessRuleDimension_Table ON
go


INSERT INTO SCR.dbo.SC_ProcessRuleDimension_Table
( IsRuleGroup,
  ProcessRuleID_PK,
  ProcessRuleName,
  ProviderDetail_FK,
  SMC_InstanceID ) 
SELECT
IsRuleGroup,
ProcessRuleID_PK,
ProcessRuleName,
ProviderDetail_FK,
SMC_InstanceID
FROM SCR.dbo.SC_ProcessRuleDimension_Table_1441a71e
go


SET IDENTITY_INSERT SCR.dbo.SC_ProcessRuleDimension_Table OFF
go


CREATE TABLE dbo.SC_ProcessRuleMembershipFact_Table
(
    ConfigurationGroup_FK bigint   NOT NULL,
    DateAdded_FK          bigint   NOT NULL,
    DateTimeAdded         datetime NOT NULL,
    DateTimeOfTransfer    datetime CONSTRAINT DF__SC_Proces__DateT__25DB9BFC DEFAULT getutcdate() NOT NULL,
    [Level]               bigint   CONSTRAINT DF__SC_Proces__Level__26CFC035 DEFAULT 1 NOT NULL,
    ProcessRuleGroup_FK   bigint   NOT NULL,
    ProcessRuleMember_FK  bigint   NOT NULL,
    SMC_InstanceID        bigint   IDENTITY,
    TimeAdded_FK          bigint   NOT NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_ProcessRuleMembershipFact_Table ON
go


INSERT INTO SCR.dbo.SC_ProcessRuleMembershipFact_Table
( ConfigurationGroup_FK,
  DateAdded_FK,
  DateTimeAdded,
  DateTimeOfTransfer,
  [Level],
  ProcessRuleGroup_FK,
  ProcessRuleMember_FK,
  SMC_InstanceID,
  TimeAdded_FK ) 
SELECT
ConfigurationGroup_FK,
DateAdded_FK,
DateTimeAdded,
DateTimeOfTransfer,
[Level],
ProcessRuleGroup_FK,
ProcessRuleMember_FK,
SMC_InstanceID,
TimeAdded_FK
FROM SCR.dbo.SC_ProcessRuleMembershipFact_Table_51270624
go


SET IDENTITY_INSERT SCR.dbo.SC_ProcessRuleMembershipFact_Table OFF
go


CREATE TABLE dbo.SC_ProcessRuleToConfigurationGroupDimension_Table
(
    ConfigurationGroup_FK_PK bigint   NOT NULL,
    DateAdded_FK             bigint   NOT NULL,
    DateLastModified_FK      bigint   NOT NULL,
    DateTimeAdded            datetime NOT NULL,
    DateTimeLastModified     datetime NOT NULL,
    IsEnabled                bit      NULL,
    ProcessRule_FK_PK        bigint   NOT NULL,
    SMC_InstanceID           bigint   IDENTITY,
    TimeAdded_FK             bigint   NOT NULL,
    TimeLastModified_FK      bigint   NOT NULL,
    UserLastModified_FK      bigint   NOT NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_ProcessRuleToConfigurationGroupDimension_Table ON
go


INSERT INTO SCR.dbo.SC_ProcessRuleToConfigurationGroupDimension_Table
( ConfigurationGroup_FK_PK,
  DateAdded_FK,
  DateLastModified_FK,
  DateTimeAdded,
  DateTimeLastModified,
  IsEnabled,
  ProcessRule_FK_PK,
  SMC_InstanceID,
  TimeAdded_FK,
  TimeLastModified_FK,
  UserLastModified_FK ) 
SELECT
ConfigurationGroup_FK_PK,
DateAdded_FK,
DateLastModified_FK,
DateTimeAdded,
DateTimeLastModified,
IsEnabled,
ProcessRule_FK_PK,
SMC_InstanceID,
TimeAdded_FK,
TimeLastModified_FK,
UserLastModified_FK
FROM SCR.dbo.SC_ProcessRuleToConfigurationGroupDimension_Table_a9c6373e
go


SET IDENTITY_INSERT SCR.dbo.SC_ProcessRuleToConfigurationGroupDimension_Table OFF
go


CREATE TABLE dbo.SC_ProcessRuleToScriptFact_Table
(
    ConfigurationGroup_FK bigint   NOT NULL,
    DateAdded_FK          bigint   NOT NULL,
    DateTimeAdded         datetime NOT NULL,
    DateTimeOfTransfer    datetime CONSTRAINT DF__SC_Proces__DateT__37FA4C37 DEFAULT getutcdate() NOT NULL,
    ProcessRule_FK        bigint   NOT NULL,
    Script_FK             bigint   NOT NULL,
    SMC_InstanceID        bigint   IDENTITY,
    TimeAdded_FK          bigint   NOT NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_ProcessRuleToScriptFact_Table ON
go


INSERT INTO SCR.dbo.SC_ProcessRuleToScriptFact_Table
( ConfigurationGroup_FK,
  DateAdded_FK,
  DateTimeAdded,
  DateTimeOfTransfer,
  ProcessRule_FK,
  Script_FK,
  SMC_InstanceID,
  TimeAdded_FK ) 
SELECT
ConfigurationGroup_FK,
DateAdded_FK,
DateTimeAdded,
DateTimeOfTransfer,
ProcessRule_FK,
Script_FK,
SMC_InstanceID,
TimeAdded_FK
FROM SCR.dbo.SC_ProcessRuleToScriptFact_Table_acc59172
go


SET IDENTITY_INSERT SCR.dbo.SC_ProcessRuleToScriptFact_Table OFF
go


CREATE TABLE dbo.SC_ProviderDetailDimension_Table
(
    ProviderInstanceID_PK uniqueidentifier NOT NULL,
    ProviderInstanceName  nvarchar(255)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    ProviderTypeClassID   uniqueidentifier NOT NULL,
    ProviderTypeName      nvarchar(255)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SMC_InstanceID        bigint           IDENTITY
)
go


SET IDENTITY_INSERT SCR.dbo.SC_ProviderDetailDimension_Table ON
go


INSERT INTO SCR.dbo.SC_ProviderDetailDimension_Table
( ProviderInstanceID_PK,
  ProviderInstanceName,
  ProviderTypeClassID,
  ProviderTypeName,
  SMC_InstanceID ) 
SELECT
ProviderInstanceID_PK,
ProviderInstanceName,
ProviderTypeClassID,
ProviderTypeName,
SMC_InstanceID
FROM SCR.dbo.SC_ProviderDetailDimension_Table_0217ca48
go


SET IDENTITY_INSERT SCR.dbo.SC_ProviderDetailDimension_Table OFF
go


CREATE TABLE dbo.SC_RelationshipAttributeDefinitionDimension_Table
(
    Description                nvarchar(255)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    RelationshipAttributeID_PK uniqueidentifier NOT NULL,
    RelationshipAttributeName  nvarchar(255)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    RelationshipDefinition_FK  bigint           NOT NULL,
    SMC_InstanceID             bigint           IDENTITY
)
go


SET IDENTITY_INSERT SCR.dbo.SC_RelationshipAttributeDefinitionDimension_Table ON
go


INSERT INTO SCR.dbo.SC_RelationshipAttributeDefinitionDimension_Table
( Description,
  RelationshipAttributeID_PK,
  RelationshipAttributeName,
  RelationshipDefinition_FK,
  SMC_InstanceID ) 
SELECT
Description,
RelationshipAttributeID_PK,
RelationshipAttributeName,
RelationshipDefinition_FK,
SMC_InstanceID
FROM SCR.dbo.SC_RelationshipAttributeDefinitionDimension_Table_5e770e77
go


SET IDENTITY_INSERT SCR.dbo.SC_RelationshipAttributeDefinitionDimension_Table OFF
go


CREATE TABLE dbo.SC_RelationshipAttributeInstanceFact_Table
(
    ConfigurationGroup_FK              bigint           NOT NULL,
    DateAdded_FK                       bigint           NOT NULL,
    DateLastModified_FK                bigint           NOT NULL,
    DateTimeAdded                      datetime         NOT NULL,
    DateTimeLastModified               datetime         NOT NULL,
    DateTimeOfTransfer                 datetime         CONSTRAINT DF__SC_Relati__DateT__3BCADD1B DEFAULT getutcdate() NOT NULL,
    RelationshipAttributeDefinition_FK bigint           NOT NULL,
    RelationshipAttributeInstanceID    uniqueidentifier NOT NULL,
    RelationshipInstanceID             uniqueidentifier NOT NULL,
    SMC_InstanceID                     bigint           IDENTITY,
    SourceClassInstanceKeyValue        nvarchar(400)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    TargetClassInstanceKeyValue        nvarchar(400)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    TimeAdded_FK                       bigint           NOT NULL,
    TimeLastModified_FK                bigint           NOT NULL,
    UserLastModified_FK                bigint           NOT NULL,
    [Value]                            nvarchar(255)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_RelationshipAttributeInstanceFact_Table ON
go


INSERT INTO SCR.dbo.SC_RelationshipAttributeInstanceFact_Table
( ConfigurationGroup_FK,
  DateAdded_FK,
  DateLastModified_FK,
  DateTimeAdded,
  DateTimeLastModified,
  DateTimeOfTransfer,
  RelationshipAttributeDefinition_FK,
  RelationshipAttributeInstanceID,
  RelationshipInstanceID,
  SMC_InstanceID,
  SourceClassInstanceKeyValue,
  TargetClassInstanceKeyValue,
  TimeAdded_FK,
  TimeLastModified_FK,
  UserLastModified_FK,
  [Value] ) 
SELECT
ConfigurationGroup_FK,
DateAdded_FK,
DateLastModified_FK,
DateTimeAdded,
DateTimeLastModified,
DateTimeOfTransfer,
RelationshipAttributeDefinition_FK,
RelationshipAttributeInstanceID,
RelationshipInstanceID,
SMC_InstanceID,
SourceClassInstanceKeyValue,
TargetClassInstanceKeyValue,
TimeAdded_FK,
TimeLastModified_FK,
UserLastModified_FK,
[Value]
FROM SCR.dbo.SC_RelationshipAttributeInstanceFact_Table_46e8fd21
go


SET IDENTITY_INSERT SCR.dbo.SC_RelationshipAttributeInstanceFact_Table OFF
go


CREATE TABLE dbo.SC_RelationshipDefinitionDimension_Table
(
    Description              nvarchar(512)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    IsConnector              bit              NOT NULL,
    IsContainment            bit              NOT NULL,
    RelationshipTypeID_PK    uniqueidentifier NOT NULL,
    RelationshipTypeName     nvarchar(255)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SMC_InstanceID           bigint           IDENTITY,
    SourceClassDefinition_FK bigint           NOT NULL,
    TargetClassDefinition_FK bigint           NOT NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_RelationshipDefinitionDimension_Table ON
go


INSERT INTO SCR.dbo.SC_RelationshipDefinitionDimension_Table
( Description,
  IsConnector,
  IsContainment,
  RelationshipTypeID_PK,
  RelationshipTypeName,
  SMC_InstanceID,
  SourceClassDefinition_FK,
  TargetClassDefinition_FK ) 
SELECT
Description,
IsConnector,
IsContainment,
RelationshipTypeID_PK,
RelationshipTypeName,
SMC_InstanceID,
SourceClassDefinition_FK,
TargetClassDefinition_FK
FROM SCR.dbo.SC_RelationshipDefinitionDimension_Table_21bd4cf3
go


SET IDENTITY_INSERT SCR.dbo.SC_RelationshipDefinitionDimension_Table OFF
go


CREATE TABLE dbo.SC_RelationshipInstanceFact_Table
(
    ConfigurationGroup_FK       bigint           NOT NULL,
    DateAdded_FK                bigint           NOT NULL,
    DateLastModified_FK         bigint           NOT NULL,
    DateTimeAdded               datetime         NOT NULL,
    DateTimeLastModified        datetime         NOT NULL,
    DateTimeOfTransfer          datetime         CONSTRAINT DF__SC_Relati__DateT__4277DAAA DEFAULT getutcdate() NOT NULL,
    RelationshipDefinition_FK   bigint           NOT NULL,
    RelationshipInstanceID      uniqueidentifier NOT NULL,
    SMC_InstanceID              bigint           IDENTITY,
    SourceClassInstanceID       uniqueidentifier NOT NULL,
    SourceClassInstanceKeyValue nvarchar(400)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    TargetClassInstanceID       uniqueidentifier NOT NULL,
    TargetClassInstanceKeyValue nvarchar(400)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    TimeAdded_FK                bigint           NOT NULL,
    TimeLastModified_FK         bigint           NOT NULL,
    UserLastModified_FK         bigint           NOT NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_RelationshipInstanceFact_Table ON
go


INSERT INTO SCR.dbo.SC_RelationshipInstanceFact_Table
( ConfigurationGroup_FK,
  DateAdded_FK,
  DateLastModified_FK,
  DateTimeAdded,
  DateTimeLastModified,
  DateTimeOfTransfer,
  RelationshipDefinition_FK,
  RelationshipInstanceID,
  SMC_InstanceID,
  SourceClassInstanceID,
  SourceClassInstanceKeyValue,
  TargetClassInstanceID,
  TargetClassInstanceKeyValue,
  TimeAdded_FK,
  TimeLastModified_FK,
  UserLastModified_FK ) 
SELECT
ConfigurationGroup_FK,
DateAdded_FK,
DateLastModified_FK,
DateTimeAdded,
DateTimeLastModified,
DateTimeOfTransfer,
RelationshipDefinition_FK,
RelationshipInstanceID,
SMC_InstanceID,
SourceClassInstanceID,
SourceClassInstanceKeyValue,
TargetClassInstanceID,
TargetClassInstanceKeyValue,
TimeAdded_FK,
TimeLastModified_FK,
UserLastModified_FK
FROM SCR.dbo.SC_RelationshipInstanceFact_Table_cd454610
go


SET IDENTITY_INSERT SCR.dbo.SC_RelationshipInstanceFact_Table OFF
go


CREATE TABLE dbo.SC_SampledNumericDataFact_Table
(
    Computer_FK           bigint   NOT NULL,
    ConfigurationGroup_FK bigint   NOT NULL,
    CounterDetail_FK      bigint   NOT NULL,
    DateSampled_FK        bigint   NOT NULL,
    DateTimeAdded         datetime NOT NULL,
    DateTimeSampled       datetime NOT NULL,
    LocalDateSampled_FK   bigint   CONSTRAINT DF__SC_Sample__Local__6991A7CB DEFAULT 1 NOT NULL,
    LocalDateTimeSampled  datetime CONSTRAINT DF__SC_Sample__Local__6A85CC04 DEFAULT getdate() NOT NULL,
    LocalTimeSampled_FK   bigint   CONSTRAINT DF__SC_Sample__Local__6B79F03D DEFAULT 1 NOT NULL,
    SampleValue           float    NOT NULL,
    SMC_InstanceID        bigint   IDENTITY,
    TimeSampled_FK        bigint   NOT NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_SampledNumericDataFact_Table ON
go


INSERT INTO SCR.dbo.SC_SampledNumericDataFact_Table
( Computer_FK,
  ConfigurationGroup_FK,
  CounterDetail_FK,
  DateSampled_FK,
  DateTimeAdded,
  DateTimeSampled,
  LocalDateSampled_FK,
  LocalDateTimeSampled,
  LocalTimeSampled_FK,
  SampleValue,
  SMC_InstanceID,
  TimeSampled_FK ) 
SELECT
Computer_FK,
ConfigurationGroup_FK,
CounterDetail_FK,
DateSampled_FK,
DateTimeAdded,
DateTimeSampled,
LocalDateSampled_FK,
LocalDateTimeSampled,
LocalTimeSampled_FK,
SampleValue,
SMC_InstanceID,
TimeSampled_FK
FROM SCR.dbo.SC_SampledNumericDataFact_Table_66425fab
go


SET IDENTITY_INSERT SCR.dbo.SC_SampledNumericDataFact_Table OFF
go


CREATE TABLE dbo.SC_ScriptDimension_Table
(
    Description    nvarchar(255)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    Name           nvarchar(255)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    ScriptID_PK    uniqueidentifier NOT NULL,
    SMC_InstanceID bigint           IDENTITY,
    Version        nvarchar(10)     COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_ScriptDimension_Table ON
go


INSERT INTO SCR.dbo.SC_ScriptDimension_Table
( Description,
  Name,
  ScriptID_PK,
  SMC_InstanceID,
  Version ) 
SELECT
Description,
Name,
ScriptID_PK,
SMC_InstanceID,
Version
FROM SCR.dbo.SC_ScriptDimension_Table_83773e97
go


SET IDENTITY_INSERT SCR.dbo.SC_ScriptDimension_Table OFF
go


CREATE TABLE dbo.SC_ScriptToConfigurationGroupDimension_Table
(
    ConfigurationGroup_FK_PK bigint   NOT NULL,
    DateAdded_FK             bigint   NOT NULL,
    DateLastModified_FK      bigint   NOT NULL,
    DateTimeAdded            datetime NOT NULL,
    DateTimeLastModified     datetime NOT NULL,
    Script_FK_PK             bigint   NOT NULL,
    SMC_InstanceID           bigint   IDENTITY,
    TimeAdded_FK             bigint   NOT NULL,
    TimeLastModified_FK      bigint   NOT NULL,
    UserLastModified_FK      bigint   NOT NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_ScriptToConfigurationGroupDimension_Table ON
go


INSERT INTO SCR.dbo.SC_ScriptToConfigurationGroupDimension_Table
( ConfigurationGroup_FK_PK,
  DateAdded_FK,
  DateLastModified_FK,
  DateTimeAdded,
  DateTimeLastModified,
  Script_FK_PK,
  SMC_InstanceID,
  TimeAdded_FK,
  TimeLastModified_FK,
  UserLastModified_FK ) 
SELECT
ConfigurationGroup_FK_PK,
DateAdded_FK,
DateLastModified_FK,
DateTimeAdded,
DateTimeLastModified,
Script_FK_PK,
SMC_InstanceID,
TimeAdded_FK,
TimeLastModified_FK,
UserLastModified_FK
FROM SCR.dbo.SC_ScriptToConfigurationGroupDimension_Table_c18cf92e
go


SET IDENTITY_INSERT SCR.dbo.SC_ScriptToConfigurationGroupDimension_Table OFF
go


CREATE TABLE dbo.SC_TimeDimension_Table
(
    AMPM           nvarchar(2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    Hour_PK        int         NOT NULL,
    Minute_PK      int         NOT NULL,
    Second_PK      int         NOT NULL,
    SMC_InstanceID bigint      IDENTITY,
    TimeOfDay      datetime    NOT NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_TimeDimension_Table ON
go


INSERT INTO SCR.dbo.SC_TimeDimension_Table
( AMPM,
  Hour_PK,
  Minute_PK,
  Second_PK,
  SMC_InstanceID,
  TimeOfDay ) 
SELECT
AMPM,
Hour_PK,
Minute_PK,
Second_PK,
SMC_InstanceID,
TimeOfDay
FROM SCR.dbo.SC_TimeDimension_Table_fa2368e9
go


SET IDENTITY_INSERT SCR.dbo.SC_TimeDimension_Table OFF
go


CREATE TABLE dbo.SC_UserDimension_Table
(
    SMC_InstanceID bigint        IDENTITY,
    UserName_PK    nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
go


SET IDENTITY_INSERT SCR.dbo.SC_UserDimension_Table ON
go


INSERT INTO SCR.dbo.SC_UserDimension_Table
( SMC_InstanceID,
  UserName_PK ) 
SELECT
SMC_InstanceID,
UserName_PK
FROM SCR.dbo.SC_UserDimension_Table_62c3c491
go


SET IDENTITY_INSERT SCR.dbo.SC_UserDimension_Table OFF
go


CREATE TABLE dbo.SMC_Messages
(
    SM_MsgID    int           NOT NULL,
    SM_Language nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SM_Severity int           NOT NULL,
    SM_Name     nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SM_Message  nvarchar(400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
go


INSERT INTO SCR.dbo.SMC_Messages
( SM_MsgID,
  SM_Language,
  SM_Severity,
  SM_Name,
  SM_Message ) 
SELECT
SM_MsgID,
SM_Language,
SM_Severity,
SM_Name,
SM_Message
FROM SCR.dbo.SMC_Messages_a1120a3e
go


CREATE TABLE dbo.SMO_CSharpAssemblies
(
    SCA_Name           nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SCA_Version        nvarchar(46)     COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SCA_Culture        nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SCA_PublicKeyToken nvarchar(32)     COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SCA_AssemblyID     uniqueidentifier NOT NULL
)
go


INSERT INTO SCR.dbo.SMO_CSharpAssemblies
( SCA_Name,
  SCA_Version,
  SCA_Culture,
  SCA_PublicKeyToken,
  SCA_AssemblyID ) 
SELECT
SCA_Name,
SCA_Version,
SCA_Culture,
SCA_PublicKeyToken,
SCA_AssemblyID
FROM SCR.dbo.SMO_CSharpAssemblies_e8ce6d80
go


CREATE TABLE dbo.SMO_CSharpTypes
(
    SCT_CSharpTypeID uniqueidentifier NOT NULL,
    SCT_Name         nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SCT_Description  nvarchar(256)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SCT_AssemblyID   uniqueidentifier NULL
)
go


INSERT INTO SCR.dbo.SMO_CSharpTypes
( SCT_CSharpTypeID,
  SCT_Name,
  SCT_Description,
  SCT_AssemblyID ) 
SELECT
SCT_CSharpTypeID,
SCT_Name,
SCT_Description,
SCT_AssemblyID
FROM SCR.dbo.SMO_CSharpTypes_bdffdecc
go


CREATE TABLE dbo.SMO_ClassMethods
(
    SCM_SMOClassMethodID    uniqueidentifier NOT NULL,
    SCM_SMOClassID          uniqueidentifier NOT NULL,
    SCM_ClientSideProxyName nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SCM_ServerSideAssembly  nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SCM_ServerSideClass     nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SCM_ServerSideMethod    nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
go


INSERT INTO SCR.dbo.SMO_ClassMethods
( SCM_SMOClassMethodID,
  SCM_SMOClassID,
  SCM_ClientSideProxyName,
  SCM_ServerSideAssembly,
  SCM_ServerSideClass,
  SCM_ServerSideMethod ) 
SELECT
SCM_SMOClassMethodID,
SCM_SMOClassID,
SCM_ClientSideProxyName,
SCM_ServerSideAssembly,
SCM_ServerSideClass,
SCM_ServerSideMethod
FROM SCR.dbo.SMO_ClassMethods_d6c0d6c0
go


CREATE TABLE dbo.SMO_ClassProperties
(
    SCP_SMOClassPropertyID uniqueidentifier NOT NULL,
    SCP_SMOClassSMCClassID uniqueidentifier NULL,
    SCP_SMOClassID         uniqueidentifier NOT NULL,
    SCP_SMCClassPropertyID uniqueidentifier NULL,
    SCP_Name               nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SCP_Description        nvarchar(256)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SCP_CSharpTypeID       uniqueidentifier NOT NULL,
    SCP_Hidden             bit              CONSTRAINT DF_SMO_ClassProperties_SCP_Hidden DEFAULT 0 NOT NULL
)
go


INSERT INTO SCR.dbo.SMO_ClassProperties
( SCP_SMOClassPropertyID,
  SCP_SMOClassSMCClassID,
  SCP_SMOClassID,
  SCP_SMCClassPropertyID,
  SCP_Name,
  SCP_Description,
  SCP_CSharpTypeID,
  SCP_Hidden ) 
SELECT
SCP_SMOClassPropertyID,
SCP_SMOClassSMCClassID,
SCP_SMOClassID,
SCP_SMCClassPropertyID,
SCP_Name,
SCP_Description,
SCP_CSharpTypeID,
SCP_Hidden
FROM SCR.dbo.SMO_ClassProperties_1fe34a82
go


CREATE TABLE dbo.SMO_ClassSMCClassJoins
(
    SCSCJ_SourceSMOClassSMCClassID uniqueidentifier NOT NULL,
    SCSCJ_TargetSMOClassSMCClassID uniqueidentifier NOT NULL,
    SCSCJ_SMCRelationshipTypeID    uniqueidentifier NOT NULL
)
go


INSERT INTO SCR.dbo.SMO_ClassSMCClassJoins
( SCSCJ_SourceSMOClassSMCClassID,
  SCSCJ_TargetSMOClassSMCClassID,
  SCSCJ_SMCRelationshipTypeID ) 
SELECT
SCSCJ_SourceSMOClassSMCClassID,
SCSCJ_TargetSMOClassSMCClassID,
SCSCJ_SMCRelationshipTypeID
FROM SCR.dbo.SMO_ClassSMCClassJoins_185627cd
go


CREATE TABLE dbo.SMO_ClassSMCClasses
(
    SCSC_SMOClassSMCClassID    uniqueidentifier NOT NULL,
    SCSC_SMOClassID            uniqueidentifier NOT NULL,
    SCSC_SMCClassID            uniqueidentifier NOT NULL,
    SCSC_IsPrimary             bit              CONSTRAINT DF_SMO_ClassSMCClasses_SCSC_IsPrimary DEFAULT 0 NOT NULL,
    SCSC_IsUsedInRelationships bit              CONSTRAINT DF_SMO_ClassSMCClasses_SCSC_IsUsedInRelationships DEFAULT 0 NOT NULL,
    SCSC_ViewAlias             nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
go


INSERT INTO SCR.dbo.SMO_ClassSMCClasses
( SCSC_SMOClassSMCClassID,
  SCSC_SMOClassID,
  SCSC_SMCClassID,
  SCSC_IsPrimary,
  SCSC_IsUsedInRelationships,
  SCSC_ViewAlias ) 
SELECT
SCSC_SMOClassSMCClassID,
SCSC_SMOClassID,
SCSC_SMCClassID,
SCSC_IsPrimary,
SCSC_IsUsedInRelationships,
SCSC_ViewAlias
FROM SCR.dbo.SMO_ClassSMCClasses_a848adfa
go


CREATE TABLE dbo.SMO_ClassSchemas
(
    SCS_SMOClassID          uniqueidentifier NOT NULL,
    SCS_CSharpClassTypeName nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SCS_CSharpAssemblyID    uniqueidentifier NOT NULL,
    SCS_ViewName            nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SCS_Description         nvarchar(256)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
go


INSERT INTO SCR.dbo.SMO_ClassSchemas
( SCS_SMOClassID,
  SCS_CSharpClassTypeName,
  SCS_CSharpAssemblyID,
  SCS_ViewName,
  SCS_Description ) 
SELECT
SCS_SMOClassID,
SCS_CSharpClassTypeName,
SCS_CSharpAssemblyID,
SCS_ViewName,
SCS_Description
FROM SCR.dbo.SMO_ClassSchemas_abd03da5
go


CREATE TABLE dbo.SMO_RelationshipSources
(
    SRS_SMORelationshipTypeID uniqueidentifier NOT NULL,
    SRS_SourceSMCClassID      uniqueidentifier NOT NULL,
    SRS_SourceSMOClassID      uniqueidentifier NOT NULL
)
go


INSERT INTO SCR.dbo.SMO_RelationshipSources
( SRS_SMORelationshipTypeID,
  SRS_SourceSMCClassID,
  SRS_SourceSMOClassID ) 
SELECT
SRS_SMORelationshipTypeID,
SRS_SourceSMCClassID,
SRS_SourceSMOClassID
FROM SCR.dbo.SMO_RelationshipSources_83990197
go


CREATE TABLE dbo.SMO_RelationshipTargets
(
    SRT_SMORelationshipTypeID uniqueidentifier NOT NULL,
    SRT_TargetSMCClassID      uniqueidentifier NOT NULL,
    SRT_TargetSMOClassID      uniqueidentifier NOT NULL
)
go


INSERT INTO SCR.dbo.SMO_RelationshipTargets
( SRT_SMORelationshipTypeID,
  SRT_TargetSMCClassID,
  SRT_TargetSMOClassID ) 
SELECT
SRT_SMORelationshipTypeID,
SRT_TargetSMCClassID,
SRT_TargetSMOClassID
FROM SCR.dbo.SMO_RelationshipTargets_69e4b599
go


CREATE TABLE dbo.SMO_RelationshipTypes
(
    SRT_SMORelationshipTypeID    uniqueidentifier NOT NULL,
    SRT_SMCRelationshipTypeID    uniqueidentifier NULL,
    SRT_SMCSourceClassPropertyID uniqueidentifier NULL,
    SRT_SMCTargetClassPropertyID uniqueidentifier NULL,
    SRT_Name                     nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SRT_Description              nvarchar(256)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SRT_SourceCSharpPropertyName nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    SRT_TargetCSharpPropertyName nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
go


INSERT INTO SCR.dbo.SMO_RelationshipTypes
( SRT_SMORelationshipTypeID,
  SRT_SMCRelationshipTypeID,
  SRT_SMCSourceClassPropertyID,
  SRT_SMCTargetClassPropertyID,
  SRT_Name,
  SRT_Description,
  SRT_SourceCSharpPropertyName,
  SRT_TargetCSharpPropertyName ) 
SELECT
SRT_SMORelationshipTypeID,
SRT_SMCRelationshipTypeID,
SRT_SMCSourceClassPropertyID,
SRT_SMCTargetClassPropertyID,
SRT_Name,
SRT_Description,
SRT_SourceCSharpPropertyName,
SRT_TargetCSharpPropertyName
FROM SCR.dbo.SMO_RelationshipTypes_f306396b
go


CREATE TABLE dbo.SMO_TypeConversions
(
    STC_TypeConversionID uniqueidentifier NOT NULL,
    STC_CSharpTypeID     uniqueidentifier NOT NULL,
    STC_SMCTypeID        uniqueidentifier NOT NULL,
    STC_ConversionClass  uniqueidentifier NOT NULL
)
go


INSERT INTO SCR.dbo.SMO_TypeConversions
( STC_TypeConversionID,
  STC_CSharpTypeID,
  STC_SMCTypeID,
  STC_ConversionClass ) 
SELECT
STC_TypeConversionID,
STC_CSharpTypeID,
STC_SMCTypeID,
STC_ConversionClass
FROM SCR.dbo.SMO_TypeConversions_75bdf051
go


CREATE TABLE dbo.Users
(
    U_UserID      int           IDENTITY,
    U_UserName    nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    U_Description nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    U_Mail        nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    U_Problem     nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    U_Location    nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    U_Phone       nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    U_MobilePhone nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    U_Pager       nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    U_Fax         nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    U_Role        nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
go


SET IDENTITY_INSERT SCR.dbo.Users ON
go


INSERT INTO SCR.dbo.Users
( U_UserID,
  U_UserName,
  U_Description,
  U_Mail,
  U_Problem,
  U_Location,
  U_Phone,
  U_MobilePhone,
  U_Pager,
  U_Fax,
  U_Role ) 
SELECT
U_UserID,
U_UserName,
U_Description,
U_Mail,
U_Problem,
U_Location,
U_Phone,
U_MobilePhone,
U_Pager,
U_Fax,
U_Role
FROM SCR.dbo.Users_4d8405f6
go


SET IDENTITY_INSERT SCR.dbo.Users OFF
go


CREATE TABLE dbo.ValidationUDFParameterValues
(
    VUPV_PropertyTypeID  uniqueidentifier NOT NULL,
    VUPV_ValidationUDFID uniqueidentifier NOT NULL,
    VUPV_ParamName       nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    VUPV_Value           nvarchar(512)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
go


INSERT INTO SCR.dbo.ValidationUDFParameterValues
( VUPV_PropertyTypeID,
  VUPV_ValidationUDFID,
  VUPV_ParamName,
  VUPV_Value ) 
SELECT
VUPV_PropertyTypeID,
VUPV_ValidationUDFID,
VUPV_ParamName,
VUPV_Value
FROM SCR.dbo.ValidationUDFParameterValues_483c41eb
go


CREATE TABLE dbo.ValidationUDFParameters
(
    VUP_ValidationUDFID uniqueidentifier NOT NULL,
    VUP_ParamName       nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    VUP_ParamOrder      int              NOT NULL,
    VUP_ParamDatatypeID int              NOT NULL,
    VUP_ParamLength     int              NOT NULL,
    VUP_ParamScale      int              NOT NULL,
    VUP_ParamPrecision  int              NOT NULL
)
go


INSERT INTO SCR.dbo.ValidationUDFParameters
( VUP_ValidationUDFID,
  VUP_ParamName,
  VUP_ParamOrder,
  VUP_ParamDatatypeID,
  VUP_ParamLength,
  VUP_ParamScale,
  VUP_ParamPrecision ) 
SELECT
VUP_ValidationUDFID,
VUP_ParamName,
VUP_ParamOrder,
VUP_ParamDatatypeID,
VUP_ParamLength,
VUP_ParamScale,
VUP_ParamPrecision
FROM SCR.dbo.ValidationUDFParameters_597ca84f
go


CREATE TABLE dbo.ValidationUDFs
(
    VU_ValidationUDFID uniqueidentifier NOT NULL,
    VU_Name            nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    VU_Description     nvarchar(256)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    VU_Signed          bit              CONSTRAINT DF_ValidationUDFs_VU_Signed DEFAULT 0 NOT NULL,
    VU_SignedModID     bigint           NULL
)
go


INSERT INTO SCR.dbo.ValidationUDFs
( VU_ValidationUDFID,
  VU_Name,
  VU_Description,
  VU_Signed,
  VU_SignedModID ) 
SELECT
VU_ValidationUDFID,
VU_Name,
VU_Description,
VU_Signed,
VU_SignedModID
FROM SCR.dbo.ValidationUDFs_eddc8219
go


CREATE TABLE dbo.WarehouseClassProperty
(
    WCP_ClassPropertyID      uniqueidentifier NOT NULL,
    WCP_IsFilterColumn       bit              NOT NULL,
    WCP_IsGroomColumn        bit              NOT NULL,
    WCP_ColumnLevelTransform ntext            COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
go


INSERT INTO SCR.dbo.WarehouseClassProperty
( WCP_ClassPropertyID,
  WCP_IsFilterColumn,
  WCP_IsGroomColumn,
  WCP_ColumnLevelTransform ) 
SELECT
WCP_ClassPropertyID,
WCP_IsFilterColumn,
WCP_IsGroomColumn,
WCP_ColumnLevelTransform
FROM SCR.dbo.WarehouseClassProperty_45d5a0fb
go


CREATE TABLE dbo.WarehouseClassSchema
(
    WCS_ClassID             uniqueidentifier NOT NULL,
    WCS_WarehouseTableType  int              NOT NULL,
    WCS_DimensionType       int              NULL,
    WCS_FactType            int              NULL,
    WCS_TableTransformOrder int              NOT NULL,
    WCS_MustBeGroomed       bit              NOT NULL,
    WCS_GroomDays           int              NOT NULL
)
go


INSERT INTO SCR.dbo.WarehouseClassSchema
( WCS_ClassID,
  WCS_WarehouseTableType,
  WCS_DimensionType,
  WCS_FactType,
  WCS_TableTransformOrder,
  WCS_MustBeGroomed,
  WCS_GroomDays ) 
SELECT
WCS_ClassID,
WCS_WarehouseTableType,
WCS_DimensionType,
WCS_FactType,
WCS_TableTransformOrder,
WCS_MustBeGroomed,
WCS_GroomDays
FROM SCR.dbo.WarehouseClassSchema_263c6ba5
go


CREATE TABLE dbo.WarehouseClassSchemaToProductSchema
(
    WCSPS_ClassID                     uniqueidentifier NOT NULL,
    WCSPS_ProductID                   uniqueidentifier NOT NULL,
    WCSPS_SourceQuery                 ntext            COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    WCSPS_LowWatermarkFromSourceQuery ntext            COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
go


INSERT INTO SCR.dbo.WarehouseClassSchemaToProductSchema
( WCSPS_ClassID,
  WCSPS_ProductID,
  WCSPS_SourceQuery,
  WCSPS_LowWatermarkFromSourceQuery ) 
SELECT
WCSPS_ClassID,
WCSPS_ProductID,
WCSPS_SourceQuery,
WCSPS_LowWatermarkFromSourceQuery
FROM SCR.dbo.WarehouseClassSchemaToProductSchema_0f6b48e4
go


CREATE TABLE dbo.WarehouseGroomingInfo
(
    WG_ClassID   uniqueidentifier NOT NULL,
    WG_EndTime   datetime         NULL,
    WG_StartTime datetime         NOT NULL
)
go


INSERT INTO SCR.dbo.WarehouseGroomingInfo
( WG_ClassID,
  WG_EndTime,
  WG_StartTime ) 
SELECT
WG_ClassID,
WG_EndTime,
WG_StartTime
FROM SCR.dbo.WarehouseGroomingInfo_565ed31f
go


CREATE TABLE dbo.WarehouseTransformInfo
(
    WTI_ConfigurationGroupID uniqueidentifier NOT NULL,
    WTI_CurrentEndTime       datetime         NULL,
    WTI_CurrentStartTime     datetime         NULL
)
go


INSERT INTO SCR.dbo.WarehouseTransformInfo
( WTI_ConfigurationGroupID,
  WTI_CurrentEndTime,
  WTI_CurrentStartTime ) 
SELECT
WTI_ConfigurationGroupID,
WTI_CurrentEndTime,
WTI_CurrentStartTime
FROM SCR.dbo.WarehouseTransformInfo_31b8f41b
go


CREATE TABLE dbo.WrapperColumns
(
    WC_WrapperID       uniqueidentifier NOT NULL,
    WC_ClassPropertyID uniqueidentifier NOT NULL,
    WC_InOrder         int              NULL,
    WC_OutOrder        int              NULL,
    WC_ColumnName      nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    WC_VariableType    int              NULL
)
go


INSERT INTO SCR.dbo.WrapperColumns
( WC_WrapperID,
  WC_ClassPropertyID,
  WC_InOrder,
  WC_OutOrder,
  WC_ColumnName,
  WC_VariableType ) 
SELECT
WC_WrapperID,
WC_ClassPropertyID,
WC_InOrder,
WC_OutOrder,
WC_ColumnName,
WC_VariableType
FROM SCR.dbo.WrapperColumns_e92fe117
go


CREATE TABLE dbo.WrapperSchemas
(
    WS_WrapperID          uniqueidentifier NOT NULL,
    WS_ClassID            uniqueidentifier NULL,
    WS_ClassName          nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    WS_Query              nvarchar(1024)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    WS_QueryType          int              NOT NULL,
    WS_WrapperType        int              NOT NULL,
    WS_WrapperFileName    nvarchar(512)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    WS_RelationshipTypeID uniqueidentifier NULL
)
go


INSERT INTO SCR.dbo.WrapperSchemas
( WS_WrapperID,
  WS_ClassID,
  WS_ClassName,
  WS_Query,
  WS_QueryType,
  WS_WrapperType,
  WS_WrapperFileName,
  WS_RelationshipTypeID ) 
SELECT
WS_WrapperID,
WS_ClassID,
WS_ClassName,
WS_Query,
WS_QueryType,
WS_WrapperType,
WS_WrapperFileName,
WS_RelationshipTypeID
FROM SCR.dbo.WrapperSchemas_c7ea2dd3
go


CREATE TABLE dbo.dtproperties
(
    id       int           IDENTITY,
    objectid int           NULL,
    property varchar(64)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [value]  varchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    uvalue   nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    lvalue   image         NULL,
    version  int           CONSTRAINT DF__dtpropert__versi__4D61141F DEFAULT 0 NOT NULL
)
go


SET IDENTITY_INSERT SCR.dbo.dtproperties ON
go


INSERT INTO SCR.dbo.dtproperties
( id,
  objectid,
  property,
  [value],
  uvalue,
  lvalue,
  version ) 
SELECT
id,
objectid,
property,
[value],
uvalue,
lvalue,
version
FROM SCR.dbo.dtproperties_a3b24350
go


SET IDENTITY_INSERT SCR.dbo.dtproperties OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.BaseChar (@char varbinary(2))
RETURNS BIT
AS
BEGIN
   IF (
 (@char BETWEEN 0x0041 AND 0x005A) OR 
 (@char BETWEEN 0x0061 AND 0x007A) OR 
 (@char BETWEEN 0x00C0 AND 0x00D6) OR 
 (@char BETWEEN 0x00D8 AND 0x00F6) OR 
 (@char BETWEEN 0x00F8 AND 0x00FF) OR 
 (@char BETWEEN 0x0100 AND 0x0131) OR 
 (@char BETWEEN 0x0134 AND 0x013E) OR 
 (@char BETWEEN 0x0141 AND 0x0148) OR 
 (@char BETWEEN 0x014A AND 0x017E) OR 
 (@char BETWEEN 0x0180 AND 0x01C3) OR 
 (@char BETWEEN 0x01CD AND 0x01F0) OR 
 (@char BETWEEN 0x01F4 AND 0x01F5) OR 
 (@char BETWEEN 0x01FA AND 0x0217) OR 
 (@char BETWEEN 0x0250 AND 0x02A8) OR 
 (@char BETWEEN 0x02BB AND 0x02C1) OR 
 @char = 0x0386 OR 
 (@char BETWEEN 0x0388 AND 0x038A) OR 
 @char = 0x038C OR 
 (@char BETWEEN 0x038E AND 0x03A1) OR 
 (@char BETWEEN 0x03A3 AND 0x03CE) OR 
 (@char BETWEEN 0x03D0 AND 0x03D6) OR 
 @char = 0x03DA OR 
 @char = 0x03DC OR 
 @char = 0x03DE OR 
 @char = 0x03E0 OR 
 (@char BETWEEN 0x03E2 AND 0x03F3) OR 
 (@char BETWEEN 0x0401 AND 0x040C) OR 
 (@char BETWEEN 0x040E AND 0x044F) OR 
 (@char BETWEEN 0x0451 AND 0x045C) OR 
 (@char BETWEEN 0x045E AND 0x0481) OR 
 (@char BETWEEN 0x0490 AND 0x04C4) OR 
 (@char BETWEEN 0x04C7 AND 0x04C8) OR 
 (@char BETWEEN 0x04CB AND 0x04CC) OR 
 (@char BETWEEN 0x04D0 AND 0x04EB) OR 
 (@char BETWEEN 0x04EE AND 0x04F5) OR 
 (@char BETWEEN 0x04F8 AND 0x04F9) OR 
 (@char BETWEEN 0x0531 AND 0x0556) OR 
 @char = 0x0559 OR 
 (@char BETWEEN 0x0561 AND 0x0586) OR 
 (@char BETWEEN 0x05D0 AND 0x05EA) OR 
 (@char BETWEEN 0x05F0 AND 0x05F2) OR 
 (@char BETWEEN 0x0621 AND 0x063A) OR 
 (@char BETWEEN 0x0641 AND 0x064A) OR 
 (@char BETWEEN 0x0671 AND 0x06B7) OR 
 (@char BETWEEN 0x06BA AND 0x06BE) OR 
 (@char BETWEEN 0x06C0 AND 0x06CE) OR 
 (@char BETWEEN 0x06D0 AND 0x06D3) OR 
 @char = 0x06D5 OR 
 (@char BETWEEN 0x06E5 AND 0x06E6) OR 
 (@char BETWEEN 0x0905 AND 0x0939) OR 
 @char = 0x093D OR 
 (@char BETWEEN 0x0958 AND 0x0961) OR 
 (@char BETWEEN 0x0985 AND 0x098C) OR 
 (@char BETWEEN 0x098F AND 0x0990) OR 
 (@char BETWEEN 0x0993 AND 0x09A8) OR 
 (@char BETWEEN 0x09AA AND 0x09B0) OR 
 @char = 0x09B2 OR 
 (@char BETWEEN 0x09B6 AND 0x09B9) OR 
 (@char BETWEEN 0x09DC AND 0x09DD) OR 
 (@char BETWEEN 0x09DF AND 0x09E1) OR 
 (@char BETWEEN 0x09F0 AND 0x09F1) OR 
 (@char BETWEEN 0x0A05 AND 0x0A0A) OR 
 (@char BETWEEN 0x0A0F AND 0x0A10) OR 
 (@char BETWEEN 0x0A13 AND 0x0A28) OR 
 (@char BETWEEN 0x0A2A AND 0x0A30) OR 
 (@char BETWEEN 0x0A32 AND 0x0A33) OR 
 (@char BETWEEN 0x0A35 AND 0x0A36) OR 
 (@char BETWEEN 0x0A38 AND 0x0A39) OR 
 (@char BETWEEN 0x0A59 AND 0x0A5C) OR 
 @char = 0x0A5E OR 
 (@char BETWEEN 0x0A72 AND 0x0A74) OR 
 (@char BETWEEN 0x0A85 AND 0x0A8B) OR 
 @char = 0x0A8D OR 
 (@char BETWEEN 0x0A8F AND 0x0A91) OR 
 (@char BETWEEN 0x0A93 AND 0x0AA8) OR 
 (@char BETWEEN 0x0AAA AND 0x0AB0) OR 
 (@char BETWEEN 0x0AB2 AND 0x0AB3) OR 
 (@char BETWEEN 0x0AB5 AND 0x0AB9) OR 
 @char = 0x0ABD OR 
 @char = 0x0AE0 OR 
 (@char BETWEEN 0x0B05 AND 0x0B0C) OR 
 (@char BETWEEN 0x0B0F AND 0x0B10) OR 
 (@char BETWEEN 0x0B13 AND 0x0B28) OR 
 (@char BETWEEN 0x0B2A AND 0x0B30) OR 
 (@char BETWEEN 0x0B32 AND 0x0B33) OR 
 (@char BETWEEN 0x0B36 AND 0x0B39) OR 
 @char = 0x0B3D OR 
 (@char BETWEEN 0x0B5C AND 0x0B5D) OR 
 (@char BETWEEN 0x0B5F AND 0x0B61) OR 
 (@char BETWEEN 0x0B85 AND 0x0B8A) OR 
 (@char BETWEEN 0x0B8E AND 0x0B90) OR 
 (@char BETWEEN 0x0B92 AND 0x0B95) OR 
 (@char BETWEEN 0x0B99 AND 0x0B9A) OR 
 @char = 0x0B9C OR 
 (@char BETWEEN 0x0B9E AND 0x0B9F) OR 
 (@char BETWEEN 0x0BA3 AND 0x0BA4) OR 
 (@char BETWEEN 0x0BA8 AND 0x0BAA) OR 
 (@char BETWEEN 0x0BAE AND 0x0BB5) OR 
 (@char BETWEEN 0x0BB7 AND 0x0BB9) OR 
 (@char BETWEEN 0x0C05 AND 0x0C0C) OR 
 (@char BETWEEN 0x0C0E AND 0x0C10) OR 
 (@char BETWEEN 0x0C12 AND 0x0C28) OR 
 (@char BETWEEN 0x0C2A AND 0x0C33) OR 
 (@char BETWEEN 0x0C35 AND 0x0C39) OR 
 (@char BETWEEN 0x0C60 AND 0x0C61) OR 
 (@char BETWEEN 0x0C85 AND 0x0C8C) OR 
 (@char BETWEEN 0x0C8E AND 0x0C90) OR 
 (@char BETWEEN 0x0C92 AND 0x0CA8) OR 
 (@char BETWEEN 0x0CAA AND 0x0CB3) OR 
 (@char BETWEEN 0x0CB5 AND 0x0CB9) OR 
 @char = 0x0CDE OR 
 (@char BETWEEN 0x0CE0 AND 0x0CE1) OR 
 (@char BETWEEN 0x0D05 AND 0x0D0C) OR 
 (@char BETWEEN 0x0D0E AND 0x0D10) OR 
 (@char BETWEEN 0x0D12 AND 0x0D28) OR 
 (@char BETWEEN 0x0D2A AND 0x0D39) OR 
 (@char BETWEEN 0x0D60 AND 0x0D61) OR 
 (@char BETWEEN 0x0E01 AND 0x0E2E) OR 
 @char = 0x0E30 OR 
 (@char BETWEEN 0x0E32 AND 0x0E33) OR 
 (@char BETWEEN 0x0E40 AND 0x0E45) OR 
 (@char BETWEEN 0x0E81 AND 0x0E82) OR 
 @char = 0x0E84 OR 
 (@char BETWEEN 0x0E87 AND 0x0E88) OR 
 @char = 0x0E8A OR 
 @char = 0x0E8D OR 
 (@char BETWEEN 0x0E94 AND 0x0E97) OR 
 (@char BETWEEN 0x0E99 AND 0x0E9F) OR 
 (@char BETWEEN 0x0EA1 AND 0x0EA3) OR 
 @char = 0x0EA5 OR 
 @char = 0x0EA7 OR 
 (@char BETWEEN 0x0EAA AND 0x0EAB) OR 
 (@char BETWEEN 0x0EAD AND 0x0EAE) OR 
 @char = 0x0EB0 OR 
 (@char BETWEEN 0x0EB2 AND 0x0EB3) OR 
 @char = 0x0EBD OR 
 (@char BETWEEN 0x0EC0 AND 0x0EC4) OR 
 (@char BETWEEN 0x0F40 AND 0x0F47) OR 
 (@char BETWEEN 0x0F49 AND 0x0F69) OR 
 (@char BETWEEN 0x10A0 AND 0x10C5) OR 
 (@char BETWEEN 0x10D0 AND 0x10F6) OR 
 @char = 0x1100 OR 
 (@char BETWEEN 0x1102 AND 0x1103) OR 
 (@char BETWEEN 0x1105 AND 0x1107) OR 
 @char = 0x1109 OR 
 (@char BETWEEN 0x110B AND 0x110C) OR 
 (@char BETWEEN 0x110E AND 0x1112) OR 
 @char = 0x113C OR 
 @char = 0x113E OR 
 @char = 0x1140 OR 
 @char = 0x114C OR 
 @char = 0x114E OR 
 @char = 0x1150 OR 
 (@char BETWEEN 0x1154 AND 0x1155) OR 
 @char = 0x1159 OR 
 (@char BETWEEN 0x115F AND 0x1161) OR 
 @char = 0x1163 OR 
 @char = 0x1165 OR 
 @char = 0x1167 OR 
 @char = 0x1169 OR 
 (@char BETWEEN 0x116D AND 0x116E) OR 
 (@char BETWEEN 0x1172 AND 0x1173) OR 
 @char = 0x1175 OR 
 @char = 0x119E OR 
 @char = 0x11A8 OR 
 @char = 0x11AB OR 
 (@char BETWEEN 0x11AE AND 0x11AF) OR 
 (@char BETWEEN 0x11B7 AND 0x11B8) OR 
 @char = 0x11BA OR 
 (@char BETWEEN 0x11BC AND 0x11C2) OR 
 @char = 0x11EB OR 
 @char = 0x11F0 OR 
 @char = 0x11F9 OR 
 (@char BETWEEN 0x1E00 AND 0x1E9B) OR 
 (@char BETWEEN 0x1EA0 AND 0x1EF9) OR 
 (@char BETWEEN 0x1F00 AND 0x1F15) OR 
 (@char BETWEEN 0x1F18 AND 0x1F1D) OR 
 (@char BETWEEN 0x1F20 AND 0x1F45) OR 
 (@char BETWEEN 0x1F48 AND 0x1F4D) OR 
 (@char BETWEEN 0x1F50 AND 0x1F57) OR 
 @char = 0x1F59 OR 
 @char = 0x1F5B OR 
 @char = 0x1F5D OR 
 (@char BETWEEN 0x1F5F AND 0x1F7D) OR 
 (@char BETWEEN 0x1F80 AND 0x1FB4) OR 
 (@char BETWEEN 0x1FB6 AND 0x1FBC) OR 
 @char = 0x1FBE OR 
 (@char BETWEEN 0x1FC2 AND 0x1FC4) OR 
 (@char BETWEEN 0x1FC6 AND 0x1FCC) OR 
 (@char BETWEEN 0x1FD0 AND 0x1FD3) OR 
 (@char BETWEEN 0x1FD6 AND 0x1FDB) OR 
 (@char BETWEEN 0x1FE0 AND 0x1FEC) OR 
 (@char BETWEEN 0x1FF2 AND 0x1FF4) OR 
 (@char BETWEEN 0x1FF6 AND 0x1FFC) OR 
 @char = 0x2126 OR 
 (@char BETWEEN 0x212A AND 0x212B) OR 
 @char = 0x212E OR 
 (@char BETWEEN 0x2180 AND 0x2182) OR 
 (@char BETWEEN 0x3041 AND 0x3094) OR 
 (@char BETWEEN 0x30A1 AND 0x30FA) OR 
 (@char BETWEEN 0x3105 AND 0x312C) OR 
 (@char BETWEEN 0xAC00 AND 0xD7A3)  
      )
   BEGIN
 RETURN 1
   END

   RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.CombiningChar (@char varbinary(2))
RETURNS BIT
AS
BEGIN
   IF (   
 (@char BETWEEN 0x0300 AND 0x0345) OR 
 (@char BETWEEN 0x0360 AND 0x0361) OR 
 (@char BETWEEN 0x0483 AND 0x0486) OR 
 (@char BETWEEN 0x0591 AND 0x05A1) OR 
 (@char BETWEEN 0x05A3 AND 0x05B9) OR 
 (@char BETWEEN 0x05BB AND 0x05BD) OR 
 @char = 0x05BF OR 
 (@char BETWEEN 0x05C1 AND 0x05C2) OR 
 @char = 0x05C4 OR 
 (@char BETWEEN 0x064B AND 0x0652) OR 
 @char = 0x0670 OR 
 (@char BETWEEN 0x06D6 AND 0x06DC) OR 
 (@char BETWEEN 0x06DD AND 0x06DF) OR 
 (@char BETWEEN 0x06E0 AND 0x06E4) OR 
 (@char BETWEEN 0x06E7 AND 0x06E8) OR 
 (@char BETWEEN 0x06EA AND 0x06ED) OR 
 (@char BETWEEN 0x0901 AND 0x0903) OR 
 @char = 0x093C OR 
 (@char BETWEEN 0x093E AND 0x094C) OR 
 @char = 0x094D OR 
 (@char BETWEEN 0x0951 AND 0x0954) OR 
 (@char BETWEEN 0x0962 AND 0x0963) OR 
 (@char BETWEEN 0x0981 AND 0x0983) OR 
 @char = 0x09BC OR 
 @char = 0x09BE OR 
 @char = 0x09BF OR 
 (@char BETWEEN 0x09C0 AND 0x09C4) OR 
 (@char BETWEEN 0x09C7 AND 0x09C8) OR 
 (@char BETWEEN 0x09CB AND 0x09CD) OR 
 @char = 0x09D7 OR 
 (@char BETWEEN 0x09E2 AND 0x09E3) OR 
 @char = 0x0A02 OR 
 @char = 0x0A3C OR 
 @char = 0x0A3E OR 
 @char = 0x0A3F OR 
 (@char BETWEEN 0x0A40 AND 0x0A42) OR 
 (@char BETWEEN 0x0A47 AND 0x0A48) OR 
 (@char BETWEEN 0x0A4B AND 0x0A4D) OR 
 (@char BETWEEN 0x0A70 AND 0x0A71) OR 
 (@char BETWEEN 0x0A81 AND 0x0A83) OR 
 @char = 0x0ABC OR 
 (@char BETWEEN 0x0ABE AND 0x0AC5) OR 
 (@char BETWEEN 0x0AC7 AND 0x0AC9) OR 
 (@char BETWEEN 0x0ACB AND 0x0ACD) OR 
 (@char BETWEEN 0x0B01 AND 0x0B03) OR 
 @char = 0x0B3C OR 
 (@char BETWEEN 0x0B3E AND 0x0B43) OR 
 (@char BETWEEN 0x0B47 AND 0x0B48) OR 
 (@char BETWEEN 0x0B4B AND 0x0B4D) OR 
 (@char BETWEEN 0x0B56 AND 0x0B57) OR 
 (@char BETWEEN 0x0B82 AND 0x0B83) OR 
 (@char BETWEEN 0x0BBE AND 0x0BC2) OR 
 (@char BETWEEN 0x0BC6 AND 0x0BC8) OR 
 (@char BETWEEN 0x0BCA AND 0x0BCD) OR 
 @char = 0x0BD7 OR 
 (@char BETWEEN 0x0C01 AND 0x0C03) OR 
 (@char BETWEEN 0x0C3E AND 0x0C44) OR 
 (@char BETWEEN 0x0C46 AND 0x0C48) OR 
 (@char BETWEEN 0x0C4A AND 0x0C4D) OR 
 (@char BETWEEN 0x0C55 AND 0x0C56) OR 
 (@char BETWEEN 0x0C82 AND 0x0C83) OR 
 (@char BETWEEN 0x0CBE AND 0x0CC4) OR 
 (@char BETWEEN 0x0CC6 AND 0x0CC8) OR 
 (@char BETWEEN 0x0CCA AND 0x0CCD) OR 
 (@char BETWEEN 0x0CD5 AND 0x0CD6) OR 
 (@char BETWEEN 0x0D02 AND 0x0D03) OR 
 (@char BETWEEN 0x0D3E AND 0x0D43) OR 
 (@char BETWEEN 0x0D46 AND 0x0D48) OR 
 (@char BETWEEN 0x0D4A AND 0x0D4D) OR 
 @char = 0x0D57 OR 
 @char = 0x0E31 OR 
 (@char BETWEEN 0x0E34 AND 0x0E3A) OR 
 (@char BETWEEN 0x0E47 AND 0x0E4E) OR 
 @char = 0x0EB1 OR 
 (@char BETWEEN 0x0EB4 AND 0x0EB9) OR 
 (@char BETWEEN 0x0EBB AND 0x0EBC) OR 
 (@char BETWEEN 0x0EC8 AND 0x0ECD) OR 
 (@char BETWEEN 0x0F18 AND 0x0F19) OR 
 @char = 0x0F35 OR 
 @char = 0x0F37 OR 
 @char = 0x0F39 OR 
 @char = 0x0F3E OR 
 @char = 0x0F3F OR 
 (@char BETWEEN 0x0F71 AND 0x0F84) OR 
 (@char BETWEEN 0x0F86 AND 0x0F8B) OR 
 (@char BETWEEN 0x0F90 AND 0x0F95) OR 
 @char = 0x0F97 OR 
 (@char BETWEEN 0x0F99 AND 0x0FAD) OR 
 (@char BETWEEN 0x0FB1 AND 0x0FB7) OR 
 @char = 0x0FB9 OR 
 (@char BETWEEN 0x20D0 AND 0x20DC) OR 
 @char = 0x20E1 OR 
 (@char BETWEEN 0x302A AND 0x302F) OR 
 @char = 0x3099 OR 
 @char = 0x309A  
       )
   BEGIN
 RETURN 1
   END

   RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.Digit (@char varbinary(2))
RETURNS BIT
BEGIN
    IF (
 (@char BETWEEN 0x0030 AND 0x0039) OR 
 (@char BETWEEN 0x0660 AND 0x0669) OR 
 (@char BETWEEN 0x06F0 AND 0x06F9) OR 
 (@char BETWEEN 0x0966 AND 0x096F) OR 
 (@char BETWEEN 0x09E6 AND 0x09EF) OR 
 (@char BETWEEN 0x0A66 AND 0x0A6F) OR 
 (@char BETWEEN 0x0AE6 AND 0x0AEF) OR 
 (@char BETWEEN 0x0B66 AND 0x0B6F) OR 
 (@char BETWEEN 0x0BE7 AND 0x0BEF) OR 
 (@char BETWEEN 0x0C66 AND 0x0C6F) OR 
 (@char BETWEEN 0x0CE6 AND 0x0CEF) OR 
 (@char BETWEEN 0x0D66 AND 0x0D6F) OR 
 (@char BETWEEN 0x0E50 AND 0x0E59) OR 
 (@char BETWEEN 0x0ED0 AND 0x0ED9) OR 
 (@char BETWEEN 0x0F20 AND 0x0F29)  
         )
    BEGIN
 RETURN 1
    END

    RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.Extender (@char varbinary(2))
RETURNS BIT
AS
BEGIN
   IF (
 @char = 0x00B7 OR 
 @char = 0x02D0 OR 
 @char = 0x02D1 OR 
 @char = 0x0387 OR 
 @char = 0x0640 OR 
 @char = 0x0E46 OR 
 @char = 0x0EC6 OR 
 @char = 0x3005 OR 
 (@char BETWEEN 0x3031 AND 0x3035) OR 
 (@char BETWEEN 0x309D AND 0x309E) OR 
 (@char BETWEEN 0x30FC AND 0x30FE)  
     )
 BEGIN
  RETURN 1
 END

 RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.Ideographic (@char varbinary(2))
RETURNS BIT
AS
BEGIN
    IF (  
 (@char BETWEEN 0x4E00 AND 0x9FA5) OR 
 @char = 0x3007 OR 
 (@char BETWEEN 0x3021 AND 0x3029)  
        )
   BEGIN
 RETURN 1
   END

   RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.Letter (@char varbinary(2))
RETURNS BIT
AS
BEGIN
 IF dbo.BaseChar(@char) = 1 OR dbo.Ideographic (@char) = 1
 BEGIN
  RETURN 1
 END

 RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.NameChar (@char varbinary(2))
RETURNS BIT
AS  
BEGIN
 IF ( dbo.Letter(@char) = 1 OR 
  dbo.Digit(@char) = 1 OR 
  @char IN (0x002E,0x002D,0x005F,0x003a) OR 
  dbo.CombiningChar(@char) = 1 OR 
  dbo.Extender(@char) = 1
   )
 BEGIN
  RETURN 1
 END

 RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.SMC_Meta_ClassInstances_Hist
(@date AS datetime)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT InstanceID,
       ClassID,
       FriendlyName,
        SMC_StartDate, 
       SMC_StartModID,
       SMC_UserName
       FROM [dbo].[SMC_Meta_ClassInstances_TT]
       WHERE SMC_StartDate <= @date
       AND   SMC_EndDate   >  @date
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.SMC_Meta_PropertyInstances_Hist
(@date AS datetime)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT ClassID, 
       InstanceID, 
       ClassPropertyID, 
       Value, 
        SMC_StartDate, 
       SMC_StartModID,
       SMC_UserName
       FROM [dbo].[SMC_Meta_PropertyInstances_TT]
       WHERE SMC_StartDate <= @date
       AND   SMC_EndDate   >  @date
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.SMC_Meta_RelationshipInstances_Hist
(@date AS datetime)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT SMC_InstanceID, 
       RelationshipTypeID, 
       SourceInstanceID, 
       TargetInstanceID, 
       Usage, 
        SMC_StartDate, 
       SMC_StartModID,
       SMC_UserName
       FROM [dbo].[SMC_Meta_RelationshipInstances_TT]
       WHERE SMC_StartDate <= @date
       AND   SMC_EndDate   >  @date
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.ValidStartChar (@char varbinary (2))
RETURNS BIT
AS
BEGIN
 IF (dbo.Letter(@char) = 1 OR @char IN (0x005F,0x003A))
 BEGIN
  RETURN 1
 END

 RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE   FUNCTION dbo.fn_ConvertToLocalDate 
(@MyUTCDate    AS DATETIME)
RETURNS DATETIME
AS
BEGIN
    DECLARE @MyLocalDate AS DATETIME
    DECLARE @CurUTCDate AS DATETIME
    DECLARE @CurLocalDate AS DATETIME

    SELECT @CurLocalDate = CurrentDate, @CurUTCDate = CurrentUTCDate
    FROM dbo.[SC_CurrentDate_View]

    SELECT @MyLocalDate = DATEADD(MINUTE,
                                  DATEDIFF(MINUTE, @CurUTCDate, @CurLocalDate),
                                  @MyUTCDate)

    RETURN @MyLocalDate
END
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.fn_ExpandString(@inputstring nvarchar(1024), @ALL nvarchar(10))
RETURNS nvarchar(1024)
AS 
BEGIN
    DECLARE @ExpandedString nvarchar(1024)
    SET @ExpandedString = (CASE WHEN @inputstring = @ALL THEN '%'
                           ELSE @inputstring END) 
    RETURN (@ExpandedString)
END
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.fn_GetComputerIDsInGroup(@computergroup nvarchar(1024))
RETURNS TABLE
AS RETURN (
            SELECT DISTINCT CD.SMC_InstanceID AS ComputerID,
                            CD.FullComputerName AS Computer
            FROM   SC_ComputerDimension_View CD 
            INNER JOIN SC_ComputerToComputerRuleFact_Latest_View CCRF 
            ON CD.SMC_InstanceID = CCRF.Computer_FK 
            INNER JOIN SC_ComputerRuleDimension_View CRD 
            ON CCRF.ComputerRule_FK = CRD.SMC_InstanceID
            WHERE CRD.Name =@computergroup
     
)
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.fn_GetComputersInGroup(@computergroup nvarchar(1024))
RETURNS TABLE
AS RETURN (
            SELECT DISTINCT CD.FullComputerName AS Computer
            FROM   SC_ComputerDimension_View CD 
            INNER JOIN SC_ComputerToComputerRuleFact_Latest_View CCRF 
            ON CD.SMC_InstanceID = CCRF.Computer_FK 
            INNER JOIN SC_ComputerRuleDimension_View CRD 
            ON CCRF.ComputerRule_FK = CRD.SMC_InstanceID
            WHERE CRD.Name = @computergroup
    
)
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.fn_GetDateRange (@numberofdays int)
RETURNS TABLE
AS RETURN (
          SELECT CurrentDate - @numberofdays AS BeginDate, CurrentDate AS EndDate
          FROM dbo.[SC_CurrentDate_View]
)
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


CREATE FUNCTION dbo.fn_GetManagedComputers()
RETURNS TABLE 
AS RETURN (
           
  SELECT DISTINCT CD.FullComputerName AS Server
            FROM   SC_ComputerDimension_View CD 
            INNER JOIN SC_ComputerToComputerRuleFact_Latest_View CCRF ON CD.SMC_InstanceID = CCRF.Computer_FK
             
)
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.fn_GetOperationalDataIDs(@param NVARCHAR(32))
RETURNS TABLE
AS RETURN (
 SELECT *
 FROM dbo.SC_OperationalDataDimension_View 
 WHERE
  (@param=N'ComputerGroups' AND Type=1) OR
  (@param=N'ProcessingRules' AND Type=2)
)
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.fn_GetProductID (@ProductName NVARCHAR(128))
RETURNS uniqueidentifier
AS
BEGIN
    DECLARE @ProductID uniqueidentifier
    SELECT @ProductID = PS.ProductID
    FROM dbo.SMC_Meta_ProductSchema AS PS
    WHERE PS.ProductName = @ProductName
    RETURN @ProductID
END
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.fn_ListComputerGroups()
RETURNS TABLE
AS RETURN (
            SELECT     Name AS CompGroup
            FROM       SC_ComputerRuleDimension_View CRD
            WHERE      SMC_InstanceID > 3
    
            
)
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE   FUNCTION dbo.fn_MaxDateTimeOfTransfer 
(@DWViewName   AS NVARCHAR(128))
RETURNS @MaxDateTimeOfTransferPerConfigGroup TABLE (ConfigurationGroup BIGINT NOT NULL,
                                                    MaxDateTimeOfTransfer DATETIME NOT NULL)
AS
BEGIN

 IF (@DWViewName = N'dbo.SC_ClassInstanceFact_View') 
 BEGIN
     INSERT @MaxDateTimeOfTransferPerConfigGroup
     SELECT CIF.ConfigurationGroup_FK AS ConfigurationGroup,
            MAX(CIF.DateTimeOfTransfer) AS MaxDateTimeOfTransfer
     FROM dbo.SC_ClassInstanceFact_View AS CIF
     GROUP BY CIF.ConfigurationGroup_FK
 END
 ELSE IF (@DWViewName = N'dbo.SC_RelationshipInstanceFact_View')  
 BEGIN
     INSERT @MaxDateTimeOfTransferPerConfigGroup
     SELECT RIF.ConfigurationGroup_FK AS ConfigurationGroup,
            MAX(RIF.DateTimeOfTransfer) AS MaxDateTimeOfTransfer
     FROM dbo.SC_RelationshipInstanceFact_View AS RIF
     GROUP BY RIF.ConfigurationGroup_FK
 END
 ELSE IF (@DWViewName = N'dbo.SC_ClassAttributeInstanceFact_View')  
 BEGIN
     INSERT @MaxDateTimeOfTransferPerConfigGroup
     SELECT CAIF.ConfigurationGroup_FK AS ConfigurationGroup,
            MAX(CAIF.DateTimeOfTransfer) AS MaxDateTimeOfTransfer
     FROM dbo.SC_ClassAttributeInstanceFact_View AS CAIF
     GROUP BY CAIF.ConfigurationGroup_FK
 END
 ELSE IF (@DWViewName = N'dbo.SC_RelationshipAttributeInstanceFact_View')  
 BEGIN
     INSERT @MaxDateTimeOfTransferPerConfigGroup
     SELECT RAIF.ConfigurationGroup_FK AS ConfigurationGroup,
            MAX(RAIF.DateTimeOfTransfer) AS MaxDateTimeOfTransfer
     FROM dbo.SC_RelationshipAttributeInstanceFact_View AS RAIF
     GROUP BY RAIF.ConfigurationGroup_FK
 END
 ELSE IF (@DWViewName = N'dbo.SC_ComputerToComputerRuleFact_View')  
 BEGIN
     INSERT @MaxDateTimeOfTransferPerConfigGroup
     SELECT CCRF.ConfigurationGroup_FK AS ConfigurationGroup,
            MAX(CCRF.DateTimeOfTransfer) AS MaxDateTimeOfTransfer
     FROM dbo.SC_ComputerToComputerRuleFact_View AS CCRF
     GROUP BY CCRF.ConfigurationGroup_FK
 END
 ELSE IF (@DWViewName = N'dbo.SC_ComputerRuleToProcessRuleGroupFact_View')  
 BEGIN
     INSERT @MaxDateTimeOfTransferPerConfigGroup
     SELECT CRPRGF.ConfigurationGroup_FK AS ConfigurationGroup,
            MAX(CRPRGF.DateTimeOfTransfer) AS MaxDateTimeOfTransfer
     FROM dbo.SC_ComputerRuleToProcessRuleGroupFact_View AS CRPRGF
     GROUP BY CRPRGF.ConfigurationGroup_FK
 END
 ELSE IF (@DWViewName = N'dbo.SC_ProcessRuleMembershipFact_View')  
 BEGIN
     INSERT @MaxDateTimeOfTransferPerConfigGroup
     SELECT PRMF.ConfigurationGroup_FK AS ConfigurationGroup,
            MAX(PRMF.DateTimeOfTransfer) AS MaxDateTimeOfTransfer
     FROM dbo.SC_ProcessRuleMembershipFact_View AS PRMF
     GROUP BY PRMF.ConfigurationGroup_FK
 END
 ELSE IF (@DWViewName = N'dbo.SC_ProcessRuleToScriptFact_View')  
 BEGIN
     INSERT @MaxDateTimeOfTransferPerConfigGroup
     SELECT PRSF.ConfigurationGroup_FK AS ConfigurationGroup,
            MAX(PRSF.DateTimeOfTransfer) AS MaxDateTimeOfTransfer
     FROM dbo.SC_ProcessRuleToScriptFact_View AS PRSF
     GROUP BY PRSF.ConfigurationGroup_FK
 END
 RETURN
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE   FUNCTION dbo.fn_ToLocalDate 
(@MyUTCDate    AS DATETIME,
 @CurUTCDate   AS DATETIME,
 @CurLocalDate AS DATETIME)
RETURNS DATETIME
AS
BEGIN
 DECLARE @MyLocalDate AS DATETIME
 SELECT @MyLocalDate = DATEADD(MINUTE,
                               DATEDIFF(MINUTE, @CurUTCDate, @CurLocalDate),
                               @MyUTCDate)
 RETURN @MyLocalDate
END
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_DeleteRelationshipConstraint (
 @ConstraintID  as uniqueidentifier
)
AS
       SET NOCOUNT ON
 DELETE FROM dbo.SMC_Meta_RelationshipConstraints WHERE ConstraintID = @ConstraintID
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_GetClasses 
AS
         SET NOCOUNT ON
         SELECT ClassID as ID, ClassName as Name  FROM dbo.SMC_Meta_ClassSchemas
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_GetConstraints (
 @RelationshipTypeID  as uniqueidentifier
)
AS
    SET NOCOUNT ON
    SELECT ConstraintID, SourceClassID AS Source, TargetClassID AS Target, TargetFK as TargetFK, 
     CAST (CASE WHEN  TargetFK IS NULL THEN 0 ELSE 1 END AS BIT) AS HasTargetFK 
                        FROM dbo.SMC_Meta_RelationshipConstraints
                        WHERE RelationshipTypeID = @RelationshipTypeID
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_Internal_GetAllChanges
(
 @histViewName  as nvarchar(128), -- Transaction Time view name
 @startDate  as datetime,
 @endDate  as datetime
)
AS
BEGIN
 SET NOCOUNT ON

 DECLARE @params AS NVARCHAR(50)
 SET @params   = N'@startDate datetime, @endDate datetime'

 DECLARE @str AS NVARCHAR(2000)
 SET @str =
 N'SELECT * INTO #tmpChanges
   FROM dbo.' + QuoteName(@histViewName) + N' 
   WHERE SMC_EndDate   >  @startDate
   AND   SMC_StartDate <= @endDate

 SELECT *
 FROM
 (
  SELECT *, ''I'' AS Operation, P1.SMC_StartDate AS WhenChanged
  FROM #tmpChanges AS P1
  WHERE NOT EXISTS (
   SELECT *
   FROM #tmpChanges AS P2
   WHERE P1.SMC_InstanceID = P2.SMC_InstanceID
   AND   P2.SMC_EndDate  = P1.SMC_StartDate
   )
  AND P1.SMC_StartDate >= @startDate
  UNION ALL
  SELECT P2.*, ''U'', P1.SMC_EndDate AS WhenChanged
  FROM #tmpChanges AS P1, #tmpChanges AS P2
  WHERE P1.SMC_InstanceID = P2.SMC_InstanceID
  AND   P1.SMC_EndDate  = P2.SMC_StartDate
  UNION ALL
  SELECT *, ''D'', P1.SMC_EndDate As WhenChanged
  FROM #tmpChanges AS P1
  WHERE P1.SMC_EndDate <> ''9999-12-31''
  AND NOT EXISTS (
   SELECT * FROM #tmpChanges AS P2
   WHERE P1.SMC_InstanceID = P2.SMC_InstanceID
   AND   P1.SMC_EndDate  = P2.SMC_StartDate)
 ) Changes
 ORDER BY SMC_InstanceID, WhenChanged'

       EXEC dbo.sp_executesql @str, @params, @startDate, @endDate
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_Internal_GetChanges
(
 @histUDFName as nvarchar(128),
 @startDate as datetime,
        @endDate as datetime
)
AS
BEGIN
 SET NOCOUNT ON

 DECLARE @params AS NVARCHAR(50)
 SET @params = N'@startDate datetime, @endDate datetime'
 
 DECLARE @str AS NVARCHAR(2000)
 SET @str =
 N'SELECT * INTO #past FROM dbo.' + QuoteName(@histUDFName) + N'(@startDate)
  
  SELECT * INTO #current FROM dbo.' + QuoteName(@histUDFName) + '(@endDate)
 
  SELECT C.*, ''U'' AS Operation 
  FROM 
  #past P,
  #current C
  WHERE P.SMC_InstanceID =  C.SMC_InstanceID
  AND   P.SMC_StartDate  <> C.SMC_StartDate
  UNION ALL
  SELECT P.*, ''D'' AS Operation
  FROM #past P
  WHERE NOT EXISTS 
  (
  SELECT * 
  FROM #current C
  WHERE P.SMC_InstanceID = C.SMC_InstanceID
  )
  UNION ALL
  SELECT C.*, ''I'' AS Operation
  FROM  #current C
  WHERE NOT EXISTS 
  (
  SELECT * 
  FROM #past P
  WHERE P.SMC_InstanceID = C.SMC_InstanceID
  )'

   EXEC dbo.sp_executesql @str, @params, @startDate, @endDate
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_UpdateRelationshipConstraint (
 @ConstraintID  as uniqueidentifier,
 @SourceClassID        as uniqueidentifier,
 @TargetClassID         as uniqueidentifier,
 @TargetFK uniqueidentifier = NULL
)
AS
       SET NOCOUNT ON
 UPDATE dbo.SMC_Meta_RelationshipConstraints SET SourceClassID  = @SourceClassID, TargetClassID  = @TargetClassID, TargetFK = @TargetFK
                        WHERE ConstraintID = @ConstraintID
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_internal_CheckQuerySyntax
(
 @queryText nvarchar(1024)
)
AS
BEGIN

 SET NOCOUNT ON

 DECLARE @ret int
 
 SET FMTONLY ON
 EXEC @ret = dbo.sp_executesql @queryText
 SET FMTONLY OFF

 RETURN @ret
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


create proc dbo.dt_addtosourcecontrol_u
    @vchSourceSafeINI nvarchar(255) = '',
    @vchProjectName   nvarchar(255) ='',
    @vchComment       nvarchar(255) ='',
    @vchLoginName     nvarchar(255) ='',
    @vchPassword      nvarchar(255) =''

as
	-- This procedure should no longer be called;  dt_addtosourcecontrol should be called instead.
	-- Calls are forwarded to dt_addtosourcecontrol to maintain backward compatibility
	set nocount on
	exec dbo.dt_addtosourcecontrol 
		@vchSourceSafeINI, 
		@vchProjectName, 
		@vchComment, 
		@vchLoginName, 
		@vchPassword



go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


create proc dbo.dt_checkinobject_u
    @chObjectType  char(4),
    @vchObjectName nvarchar(255),
    @vchComment    nvarchar(255)='',
    @vchLoginName  nvarchar(255),
    @vchPassword   nvarchar(255)='',
    @iVCSFlags     int = 0,
    @iActionFlag   int = 0,   /* 0 => AddFile, 1 => CheckIn */
    @txStream1     text = '',  /* drop stream   */ /* There is a bug that if items are NULL they do not pass to OLE servers */
    @txStream2     text = '',  /* create stream */
    @txStream3     text = ''   /* grant stream  */

as	
	-- This procedure should no longer be called;  dt_checkinobject should be called instead.
	-- Calls are forwarded to dt_checkinobject to maintain backward compatibility.
	set nocount on
	exec dbo.dt_checkinobject
		@chObjectType,
		@vchObjectName,
		@vchComment,
		@vchLoginName,
		@vchPassword,
		@iVCSFlags,
		@iActionFlag,   
		@txStream1,		
		@txStream2,		
		@txStream3		



go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


create proc dbo.dt_checkoutobject_u
    @chObjectType  char(4),
    @vchObjectName nvarchar(255),
    @vchComment    nvarchar(255),
    @vchLoginName  nvarchar(255),
    @vchPassword   nvarchar(255),
    @iVCSFlags     int = 0,
    @iActionFlag   int = 0/* 0 => Checkout, 1 => GetLatest, 2 => UndoCheckOut */

as

	-- This procedure should no longer be called;  dt_checkoutobject should be called instead.
	-- Calls are forwarded to dt_checkoutobject to maintain backward compatibility.
	set nocount on
	exec dbo.dt_checkoutobject
		@chObjectType,  
		@vchObjectName, 
		@vchComment,    
		@vchLoginName,  
		@vchPassword,  
		@iVCSFlags,    
		@iActionFlag 



go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.dt_displayoaerror
    @iObject int,
    @iresult int
as

set nocount on

declare @vchOutput      varchar(255)
declare @hr             int
declare @vchSource      varchar(255)
declare @vchDescription varchar(255)

    exec @hr = master.dbo.sp_OAGetErrorInfo @iObject, @vchSource OUT, @vchDescription OUT

    select @vchOutput = @vchSource + ': ' + @vchDescription
    raiserror (@vchOutput,16,-1)

    return


go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.dt_displayoaerror_u
    @iObject int,
    @iresult int
as
	-- This procedure should no longer be called;  dt_displayoaerror should be called instead.
	-- Calls are forwarded to dt_displayoaerror to maintain backward compatibility.
	set nocount on
	exec dbo.dt_displayoaerror
		@iObject,
		@iresult



go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


create procedure dbo.dt_getpropertiesbyid_vcs_u
    @id       int,
    @property varchar(64),
    @value    nvarchar(255) = NULL OUT

as

    -- This procedure should no longer be called;  dt_getpropertiesbyid_vcsshould be called instead.
	-- Calls are forwarded to dt_getpropertiesbyid_vcs to maintain backward compatibility.
	set nocount on
    exec dbo.dt_getpropertiesbyid_vcs
		@id,
		@property,
		@value output


go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


create proc dbo.dt_isundersourcecontrol_u
    @vchLoginName nvarchar(255) = '',
    @vchPassword  nvarchar(255) = '',
    @iWhoToo      int = 0 /* 0 => Just check project; 1 => get list of objs */

as
	-- This procedure should no longer be called;  dt_isundersourcecontrol should be called instead.
	-- Calls are forwarded to dt_isundersourcecontrol to maintain backward compatibility.
	set nocount on
	exec dbo.dt_isundersourcecontrol
		@vchLoginName,
		@vchPassword,
		@iWhoToo 



go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


create proc dbo.dt_validateloginparams_u
    @vchLoginName  nvarchar(255),
    @vchPassword   nvarchar(255)
as

	-- This procedure should no longer be called;  dt_validateloginparams should be called instead.
	-- Calls are forwarded to dt_validateloginparams to maintain backward compatibility.
	set nocount on
	exec dbo.dt_validateloginparams
		@vchLoginName,
		@vchPassword 



go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


create proc dbo.dt_vcsenabled

as

set nocount on

declare @iObjectId int
select @iObjectId = 0

declare @VSSGUID varchar(100)
select @VSSGUID = 'SQLVersionControl.VCS_SQL'

    declare @iReturn int
    exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT
    if @iReturn <> 0 raiserror('', 16, -1) /* Can't Load Helper DLLC */



go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


/*
**	This procedure returns the version number of the stored
**    procedures used by legacy versions of the Microsoft
**	Visual Database Tools.  Version is 7.0.00.
*/
create procedure dbo.dt_verstamp006
as
	select 7000

go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


/*
**	This procedure returns the version number of the stored
**    procedures used by the the Microsoft Visual Database Tools.
**	Version is 7.0.05.
*/
create procedure dbo.dt_verstamp007
as
	select 7005

go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


create proc dbo.dt_whocheckedout_u
        @chObjectType  char(4),
        @vchObjectName nvarchar(255),
        @vchLoginName  nvarchar(255),
        @vchPassword   nvarchar(255)

as

	-- This procedure should no longer be called;  dt_whocheckedout should be called instead.
	-- Calls are forwarded to dt_whocheckedout to maintain backward compatibility.
	set nocount on
	exec dbo.dt_whocheckedout
		@chObjectType, 
		@vchObjectName,
		@vchLoginName, 
		@vchPassword  



go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_ComputeWatermark @CurrentStartTime DATETIME = NULL, @Latency INT = NULL, @ProductID UNIQUEIDENTIFIER = NULL, @ProductName NVARCHAR(128) = NULL, @ConfigurationGroupID UNIQUEIDENTIFIER = NULL
AS
BEGIN
    
    DECLARE @saveError                    INT
    DECLARE @ViewName                     NVARCHAR(128)
    DECLARE @FilterColumnName             NVARCHAR(128)
    DECLARE @ConfigGroupFKColumnName      NVARCHAR(128)
    DECLARE @ConfigGroupDimensionClassID  UNIQUEIDENTIFIER
    DECLARE @Command                      NVARCHAR(4000)
    DECLARE @ClassID                      UNIQUEIDENTIFIER
    DECLARE @HighWatermark                DATETIME
    DECLARE @ConfigGroupSMCID             BIGINT

    --
    -- Initialize
    --
    
    SET @saveError = 0
    SET @ConfigGroupDimensionClassID = '396ac80f-cb40-46ae-851d-bf0784b23c1a'
    
    --
    -- Validate the Product
    --
    
    IF (@ProductID IS NULL AND @ProductName IS NULL) 
    BEGIN 
    
        SET @saveError = 1
        GOTO QuitWithError   
        
    END
    ELSE IF (@ProductID IS NULL AND @ProductName IS NOT NULL) 
    BEGIN 
        
        SELECT @ProductID = PS.ProductID
        FROM dbo.SMC_Meta_ProductSchema AS PS
        WHERE PS.ProductName = @ProductName

        SET @saveError = @@ERROR   
        IF (@saveError <> 0 OR @ProductID IS NULL)
        BEGIN
            GOTO QuitWithError   
        END
                
    END
    
    --
    -- Validate the CurrentStartTime
    --
    
    IF (@CurrentStartTime IS NULL) 
    BEGIN 
        SELECT @CurrentStartTime = GETUTCDATE()
    END
    
    --
    -- Validate the Latency.
    -- The latency default is picked as 5 mins. Latency is subtracted to allow 
    -- for data to make it to the database so that we minimize data loss.
    -- When we move to multiple product support, if this latency does not
    -- work for all tables across products, we may have to make it 
    -- configurable per table
    --

    IF (@Latency IS NULL) 
    BEGIN 
        SET @Latency = 5
    END
        
    --
    -- Define a temporary table to hold the watermark
    --
    
    CREATE TABLE #tmpWatermark
    (
        ClassID        UNIQUEIDENTIFIER,
        LowWatermark   DATETIME,
        HighWatermark  DATETIME
    )   
    
    SET @saveError = @@ERROR   
    IF (@saveError <> 0)
    BEGIN
        GOTO QuitWithError   
    END
 
    --
    -- Compute the high watermark for each class. The high watermark is the
    -- same for all classes. It is the current start time minus a latency.
    -- The latency default is picked as 5 mins. Latency is subtracted to allow 
    -- for data to make it to the database so that we minimize data loss.
    -- When we move to multiple product support, if this latency does not
    -- work for all tables across products, we may have to make it 
    -- configurable per table
    --
    
    SET @HighWatermark = DATEADD(minute, -@Latency, @CurrentStartTime)
     
    --
    -- Get all the classes corresponding to this product, and compute the
    -- low watermark for each class
    --
    
    DECLARE CursorClasses CURSOR LOCAL FOR
        SELECT WCSPS.ClassID AS ClassID
        FROM dbo.SMC_Meta_WarehouseClassSchemaToProductSchema AS WCSPS
        INNER JOIN dbo.SMC_Meta_ProductSchema AS PS
        ON WCSPS.ProductID = PS.ProductID
        WHERE PS.ProductID = @ProductID
    OPEN CursorClasses
    FETCH NEXT FROM CursorClasses INTO @ClassID
    WHILE @@fetch_status = 0
    BEGIN
        --
        -- Reset Variables
        -- 

        SET @ViewName = NULL
        SET @FilterColumnName = NULL
        SET @ConfigGroupFKColumnName = NULL
        SET @ConfigGroupSMCID = NULL

        --
        -- Get the view name and filter column name corresponding to the ClassID
        --
        
        SELECT @ViewName = CS.ViewName, 
            @FilterColumnName = CP.PropertyName
        FROM [dbo].[SMC_Meta_ClassSchemas] AS CS
        INNER JOIN [dbo].[SMC_Meta_ClassProperties] AS CP
        ON CS.ClassID = CP.ClassID
        INNER JOIN [dbo].[SMC_Meta_WarehouseClassProperty] AS WCP
        ON CP.ClassPropertyID = WCP.ClassPropertyID
        WHERE CS.ClassID = @ClassID
        AND WCP.IsFilterColumn = 1
        
        SELECT @saveError = @@ERROR
        IF @saveError <> 0 
            GOTO QuitWithError
           
        IF (@ViewName IS NOT NULL AND @FilterColumnName IS NOT NULL)
        BEGIN
            --
            -- Get the column name of the column that is the foreign key to the
            -- ConfigurationGroupDimension.
            --
            
            SELECT @ConfigGroupFKColumnName = CP.PropertyName
            FROM [dbo].[SMC_Meta_RelationshipConstraints] AS RC
            INNER JOIN [dbo].[SMC_Meta_ClassProperties] AS CP
            ON RC.TargetFK = CP.ClassPropertyID
            WHERE RC.TargetClassID = @ClassID
            AND RC.SourceClassID = @ConfigGroupDimensionClassID
            
            SELECT @saveError = @@ERROR
            IF (@saveError <> 0) OR 
            (@ConfigGroupFKColumnName IS NULL) OR
            ((@ConfigGroupFKColumnName IS NOT NULL) AND
                (@ConfigurationGroupID = NULL OR @ProductID = NULL)
            )
            GOTO QuitWithError
           
            --
            -- Construct the command that computes the watermark
            -- Watermark is the maximum value on the filter column
            -- that currently exisits in the table for a given 
            -- configuration group.            
            --
            -- Note: If we support multiple products in the future, our 
            -- assumption is that additive facts for these products will not
            -- share configuration group ids. Hence computation of the low 
            -- watermark need not include any product information. It is 
            -- sufficient to base it on configuration group id information.
            --
               
            SET @Command = N'INSERT INTO #tmpWatermark
            SELECT '''                                                                         +
                            CAST(@ClassID AS NVARCHAR(50))                     +
                            N''' AS ClassID,
                            MAX(['                                             +
                            @FilterColumnName                                  +
                            N']) AS LowWatermark,
                            '                                                  +
                            N'CONVERT(DATETIME, '''                            +
                            CONVERT(NVARCHAR(50), @HighWatermark, 21)          +
                            N''', 21) AS HighWatermark
                            FROM [dbo].['                                      +
                            @ViewName                                          +
                            N'] AS CV'
                              
            IF (@ConfigGroupFKColumnName IS NOT NULL)
            BEGIN
                --
                -- Get the SMCInstanceID for the ConfigGroup
                -- Note: Had to seperate this out because when combined with 
                -- the query in @Command, the query optimizer was not utilizing
                -- the index (index on ConfgirationGroup_FK + Filter column
                -- correctly. 
                --
                
                SELECT @ConfigGroupSMCID = SMC_InstanceID
                FROM [dbo].[SC_ConfigurationGroupDimension_View] AS CD
                WHERE CD.ConfigurationGroupID_PK = @ConfigurationGroupID
                                                
                SELECT @saveError = @@ERROR 
                IF (@saveError <> 0)
                    GOTO QuitWithError    

                IF @ConfigGroupSMCID IS NOT NULL
                BEGIN               
                    --
                    -- If the ConfigGroupID is found, it means that there has
                    -- been a previous transfer from this config group and
                    -- we can compute the low watermark.
                    -- 
                    
                    SET @Command = @Command                                        +
                                    N'
                                    WHERE CV.['                                    +
                                    @ConfigGroupFKColumnName                       +
                                    N'] = '                                        +
                                    CAST(@ConfigGroupSMCID AS NVARCHAR(40))
                    
                END
                ELSE
                BEGIN
                    --
                    -- If the ConfigGroupID is not found, it means that there 
                    -- has not been a previous transfer from this config group 
                    -- and we cannot compute the low watermark. We should 
                    -- return NULL for low watermark - by comparing it with
                    -- NULL below, it will result in NULL for low watermark.
                    -- 

                    SET @Command = @Command                                        +
                                    N'
                                    WHERE CV.['                                    +
                                    @ConfigGroupFKColumnName                       +
                                    N'] IS NULL'

                END 
                
            END
               
            --
            -- Execute the command
            --   
    
            PRINT @Command
            EXEC (@Command)
            SELECT @saveError = @@ERROR
    
            IF (@saveError <> 0)
                GOTO QuitWithError    
                
        END

        --
        -- Fetch the next  class
        --

        FETCH NEXT FROM CursorClasses INTO @ClassID
    
    END
    CLOSE CursorClasses
    DEALLOCATE CursorClasses

   --
   -- Select the watermark
   --
   
   SELECT ClassID, LowWatermark, HighWatermark FROM #tmpWatermark
   
   --
   -- Drop the table 
   --
   
   DROP TABLE #tmpWatermark
   
   RETURN 0
         
QuitWithError:

   RETURN @saveError

END
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_CreateDWGroomJob @ownerLogin sysname = NULL,
                               @destDataSource sysname = NULL,
                               @destCatalog sysname = NULL,
                               @saveToDisk BIT = NULL,
                               @savePath NVARCHAR(255) = NULL,
                               @scheduleTime DATETIME = NULL

AS
BEGIN

        DECLARE @jobID UNIQUEIDENTIFIER
        DECLARE @jobName NVARCHAR(50)
        DECLARE @jobDesc NVARCHAR(100)
        DECLARE @returnCode INT
        DECLARE @schedule INT
        DECLARE @outputLogFileGroom NVARCHAR(300)
        
        -----------------------------------------------
        -- Create a job that schedules DW grooming   --
        -----------------------------------------------
        
        -----------------------------------------------
        -- Establish defaults                        --
        -----------------------------------------------

        -- If the owner login is null, the owner will default to the callers context.


        -- Set the dest data source 

        IF @destDataSource IS NULL
            SET @destDataSource = N'(local)'

        -- Set the dest catalog 

        IF @destCatalog IS NULL
            SET @destCatalog = N'SystemCenterReporting'

        -- Set save to disk option and save path

        IF @saveToDisk IS NULL
            SET @saveToDisk = 0

        IF @saveToDisk = 1 
        BEGIN
            IF @savePath IS NULL
            BEGIN
                SET @savePath = N''
                SET @outputLogFileGroom = N'SCDWGroomJob.log'
            END
            ELSE
            BEGIN
                SET @outputLogFileGroom = @savePath 
                IF @savePath NOT LIKE N'%\'
                BEGIN
                    SET @outputLogFileGroom = @outputLogFileGroom + N'\'
                END
                SET @outputLogFileGroom = @outputLogFileGroom + N'SCDWGroomJob.log'
            END
        END
        ELSE
        BEGIN
            SET @savePath = N''
            SET @outputLogFileGroom = N''
        END

        -- Set schedule 
        
        IF @scheduleTime IS NULL
        BEGIN
            SET @schedule = 30000
        END
        ELSE
        BEGIN
            SET @schedule = (DATEPART(hour, @scheduleTime) * 10000 ) +
                            (DATEPART(minute, @scheduleTime) * 100 ) +  
                            (DATEPART(second, @scheduleTime))
        END


        -----------------------------------------------
        -- Create the job for DW Grooming            --
        -----------------------------------------------
        
        -- Establish a name and description for the job
    
        SET @jobName = N'SCDWGroomJob'
        SET @jobDesc = N'Job that executes the datawarehouse grooming stored procedure.'

        -- Delete the job with the same name (if it exists)

        SELECT @jobID = job_id     
        FROM   msdb.dbo.sysjobs    
        WHERE ([name] = @jobName)       

        IF (@jobID IS NOT NULL)    
        BEGIN  

            -- Delete the job 

            EXECUTE msdb.dbo.sp_delete_job @job_name = @jobName 
            SELECT @jobID = NULL
        END 

        -- Add the job

        EXECUTE @returnCode = msdb.dbo.sp_add_job @job_id = @jobID OUTPUT , 
                                                  @job_name = @jobName, 
                                                  @description = @jobDesc,
                                                  @owner_login_name = @ownerLogin

       IF (@@ERROR <> 0 OR @returnCode <> 0) GOTO QuitWithError 


        -- Add the job step for DW grooming job

        EXECUTE @returnCode = msdb.dbo.sp_add_jobstep @job_id = @jobID,
                                                      @step_id = 1, 
                                                      @step_name = N'DWGroomingStep', 
                                                      @command = N'EXECUTE dbo.p_GroomDatawarehouseTables',
                                                      @database_name = @destCatalog, 
                                                      @server = N'', 
                                                      @database_user_name = N'', 
                                                      @subsystem = N'TSQL', 
                                                      @cmdexec_success_code = 0, 
                                                      @flags = 0, 
                                                      @retry_attempts = 0, 
                                                      @retry_interval = 1, 
                                                      @output_file_name = @outputLogFileGroom, 
                                                      @on_success_step_id = 0, 
                                                      @on_success_action = 1,
                                                      @on_fail_step_id = 0, 
                                                      @on_fail_action = 2

        IF (@@ERROR <> 0 OR @returnCode <> 0) GOTO QuitWithError 

        -- Indicate the starting step

        EXECUTE @returnCode = msdb.dbo.sp_update_job @job_id = @jobID, 
                                                     @start_step_id = 1 

        IF (@@ERROR <> 0 OR @returnCode <> 0) GOTO QuitWithError 


        -- Add the job schedules

        EXECUTE @returnCode = msdb.dbo.sp_add_jobschedule @job_id = @jobID, 
                                                          @name = N'MOMX DW Groom Job Schedule',
                                                          @enabled = 1, 
                                                          @freq_type = 4, 
                                                          @freq_interval = 1, 
                                                          @freq_subday_type = 1, 
                                                          @active_start_time = @schedule

        IF (@@ERROR <> 0 OR @returnCode <> 0) GOTO QuitWithError 


        -- Add the Target Servers

        EXECUTE msdb.dbo.sp_add_jobserver @job_id = @jobID, 
                                          @server_name = N'(local)' 


        IF (@@ERROR <> 0 OR @returnCode <> 0) GOTO QuitWithError 


QuitWithError:

        IF (@@ERROR <> 0) 
            RETURN @@ERROR

        IF (@returnCode <> 0)
            RETURN @returnCode

        RETURN 0
END
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.p_CreateIndexes
@Choice NVARCHAR(20) = N'Facts'
AS
BEGIN
        
    DECLARE     @SaveRowCount         INTEGER
    DECLARE     @SaveError            INTEGER
    DECLARE     @SourceQuery          NVARCHAR(3000)
    DECLARE     @Where                NVARCHAR(256)
    DECLARE     @CreateIndexPrefix    NVARCHAR(1000)
    DECLARE     @CreateIndexSuffix    NVARCHAR(1000)
    DECLARE     @ColumnSelect         NVARCHAR(4000)
    DECLARE     @PrevIndexID          UNIQUEIDENTIFIER
    DECLARE     @IndexID              UNIQUEIDENTIFIER
    DECLARE     @IndexName            NVARCHAR(128)
    DECLARE     @TableName            NVARCHAR(128)
    DECLARE     @Clustered            BIT
    DECLARE     @Unique               BIT
    DECLARE     @FillFactor           SMALLINT
    DECLARE     @FileGroupName        NVARCHAR(128)
    DECLARE     @Order                INT
    DECLARE     @ColumnName           NVARCHAR(128)
    DECLARE     @Ascending            BIT

    -- 
    -- The create index statement will be of the following form
    -- 
    -- CREATE {UNIQUE | CLUSTERED} INDEX {IndexName}
    -- ON {TableName}
    -- (
    --
    --   {Begin repeat for all index columns}
    --   {ColumnName} {ASC | DESC}
    --   {End repeat for all index columns}
    --
    -- )
    -- WITH FILLFACTOR {Fill Factor number}
    -- ON FILEGROUP {FileGroupName}
    --
          
    --
    -- Create a temp table that will hold index definitions
    --

    CREATE TABLE #tmpDefinitions
    (
        IndexID                                       UNIQUEIDENTIFIER NOT NULL,
        IndexName                                     NVARCHAR(128)    NOT NULL,
        TableName                                     NVARCHAR(128)    NOT NULL,
        [Clustered]                                   BIT              NOT NULL,
        [Unique]                                      BIT              NOT NULL,
        [FillFactor]                                  SMALLINT         NOT NULL,
        FileGroupName                                 NVARCHAR(128)    NULL,
        [Order]                                       INT              NOT NULL,
        ColumnName                                    NVARCHAR(128)    NOT NULL,
        Ascending                                     BIT              NOT NULL
    )   
    
    SET @SaveError = @@ERROR
    IF (@SaveError <> 0)
    BEGIN
        GOTO Error_Exit
    END

    --
    -- Initialize variables, depending on the choice
    --

    SET @SourceQuery = N'INSERT INTO #tmpDefinitions
        SELECT CI.ClassIndexID    AS IndexID,         
               CI.IndexName       AS IndexName,          
               CS.TableName       AS TableName,      
               CI.[Clustered]     AS [Clustered],         
               CI.[Unique]        AS [Unique],         
               CI.[FillFactor]    AS [FillFactor],        
               FG.[Name]          AS FileGroupName,        
               CIC.[Order]        AS [Order],         
               CP.PropertyName    AS ColumnName,        
               CIC.Ascending      AS Ascending        
        FROM dbo.SMC_Meta_ClassIndexes AS CI        
        LEFT OUTER JOIN dbo.SMC_Meta_FileGroups AS FG
        ON CI.FileGroupID = FG.FileGroupID
        INNER JOIN dbo.SMC_Meta_ClassIndexesColumns AS CIC        
        ON CI.ClassIndexID = CIC.ClassIndexID        
        INNER JOIN dbo.SMC_Meta_ClassProperties AS CP
        ON CIC.ClassPropertyID = CP.ClassPropertyID
        INNER JOIN dbo.SMC_Meta_ClassSchemas AS CS
        ON CI.ClassID = CS.ClassID
        INNER JOIN dbo.SMC_Meta_WarehouseClassSchema AS WCS
        ON CS.ClassID = WCS.ClassID
'

    IF (@Choice = N'Facts')
    BEGIN
        SET @Where = N'        WHERE WarehouseTableType = 2'
    END
    ELSE IF (@Choice = N'Dimensions')
    BEGIN
        SET @Where = N'        WHERE WarehouseTableType = 1'
    END
    ELSE IF (@Choice = N'Both')
    BEGIN
        SET @Where = N'        WHERE WarehouseTableType = 1 OR WarehouseTableType = 2'
    END
    ELSE 
    BEGIN
        GOTO Error_Exit
    END

    SET @SourceQuery = @SourceQuery    +
                       @Where          +
                       N'
        ORDER BY CI.[Clustered] DESC, CI.ClassIndexID ASC, CIC.[Order] ASC'
 
    --
    -- Populate the temp table
    --

    PRINT @SourceQuery
    EXECUTE (@SourceQuery)

    SET @SaveError = @@ERROR
    IF (@SaveError <> 0)
    BEGIN
        GOTO Error_Exit
    END

    -- 
    -- Delcare a cursor that iterates through all index definitions
    -- as creates the indexes. Order such that clustered indexes 
    -- appear first.
    -- 

    DECLARE CursorDefinitions CURSOR LOCAL FOR
        SELECT D.IndexID        AS IndexID,
               D.IndexName      AS IndexName,
               D.TableName      AS TableName,
               D.[Clustered]    AS [Clustered],
               D.[Unique]       AS [Unique],
               D.[FillFactor]   AS [FillFactor],
               D.FileGroupName  AS FileGroupName,
               D.[Order]        AS [Order],
               D.ColumnName     AS ColumnName,
               D.Ascending      AS Ascending
        FROM #tmpDefinitions AS D
        ORDER BY D.[Clustered] DESC, D.IndexID ASC, D.[Order] ASC
    OPEN CursorDefinitions
    FETCH NEXT FROM CursorDefinitions INTO @IndexID,
                                           @IndexName,
                                           @TableName,
                                           @Clustered,
                                           @Unique,
                                           @FillFactor,
                                           @FileGroupName,
                                           @Order,
                                           @ColumnName,
                                           @Ascending
    WHILE @@fetch_status = 0
    BEGIN
    
        --
        -- Reset the variables for the new index definition
        --
        
        IF (@PrevIndexID <> @IndexID)
        BEGIN            
            --
            -- Create the prefix to the create index statement
            -- 

            SET @CreateIndexPrefix = N'CREATE '
        
            IF (@Unique = 1)
            BEGIN 
                SET @CreateIndexPrefix = @CreateIndexPrefix +
                                         N'UNIQUE '
            END

            IF (@Clustered = 1)
            BEGIN 
                SET @CreateIndexPrefix = @CreateIndexPrefix +
                                         N'CLUSTERED '
            END

            SET @CreateIndexPrefix = @CreateIndexPrefix     +
                                     N'INDEX ['

            SET @CreateIndexPrefix = @CreateIndexPrefix     +
                                     @IndexName             +
                                     N']
ON '

            SET @CreateIndexPrefix = @CreateIndexPrefix     +
                                     N'['                   +
                                     @TableName             +
                                     N']
('

            --
            -- Create the suffix to the create index statement
            -- 
 
            SET @CreateIndexSuffix = N'
)
WITH FILLFACTOR = '

            SET @CreateIndexSuffix = @CreateIndexSuffix    +
                                     CAST(@FillFactor AS NVARCHAR(10))

            IF (@FileGroupName IS NOT NULL)
            BEGIN 
                SET @CreateIndexSuffix = @CreateIndexSuffix +
                                         N'
ON FILEGROUP '
                SET @CreateIndexSuffix = @CreateIndexSuffix +
                                         @FileGroupName
            END

            --
            -- Initialize the column select variable
            --

            SET @ColumnSelect = N''     

        END
     
        --
        -- Save the IndexID
        --
    
        SET @PrevIndexID = @IndexID
    
        --
        -- Add the the current column to the index
        --
   
        IF (@ColumnSelect <> N'')
        BEGIN 
            SET @ColumnSelect =  @ColumnSelect        +
                                 N','
        END

        SET @ColumnSelect =  @ColumnSelect        +
                             N'
['                                                +
                             @ColumnName          +                              
                             N'] '

        SET @SaveError = @@ERROR    
        IF (@SaveError <> 0)
        BEGIN
            GOTO Error_Exit
        END

        IF (@Ascending = 1)
        BEGIN 
            SET @ColumnSelect =  @ColumnSelect    +       
                                 N'ASC ' 
        END
        ELSE
        BEGIN 
            SET @ColumnSelect =  @ColumnSelect    +                
                                 N'DESC ' 
        END

        SET @SaveError = @@ERROR    
        IF (@SaveError <> 0)
        BEGIN
            GOTO Error_Exit
        END
               
        --
        -- Fetch the next row
        --
        
        FETCH NEXT FROM CursorDefinitions INTO @IndexID,
                                               @IndexName,
                                               @TableName,
                                               @Clustered,
                                               @Unique,
                                               @FillFactor,
                                               @FileGroupName,
                                               @Order,
                                               @ColumnName,
                                               @Ascending
        --
        -- Detect if a index definition has ended, if so  
        -- execute the create index command
        -- 
    
        IF (@PrevIndexID IS NOT NULL AND
            @PrevIndexID <> @IndexID) OR 
            @@fetch_status <> 0
        BEGIN

            --
            -- Concatenate the variables to form the create index command
            -- and execute it
            --

     PRINT @CreateIndexPrefix +
                  @ColumnSelect      +
                  @CreateIndexSuffix               

            EXECUTE (@CreateIndexPrefix                   +
                     @ColumnSelect                        +  
                     @CreateIndexSuffix)
    
            SET @SaveError = @@ERROR
            IF (@SaveError <> 0)
            BEGIN
                GOTO Error_Exit
            END

        END
                                               
    END
    CLOSE CursorDefinitions
    DEALLOCATE CursorDefinitions
 
    --
    -- Drop all the temp tables
    --
    
    DROP TABLE #tmpDefinitions

    RETURN 0
    
Error_Exit:
    
    -- SQL Server error %u encountered in p_CreateIndexes.
    RAISERROR (777977205, 16, 1, @SaveError) WITH LOG
       
    RETURN @SaveError
                
END
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_CreateLinkedServer @linkedServerName sysname = NULL, 
                                 @onePointDataSource sysname = NULL, 
                                 @onePointCatalog sysname = NULL,
                                 @useSqlAuthentication BIT = 0,
                                 @SqlUser sysname = N'',
                                 @SqlPassword sysname = N''
AS
BEGIN
        -----------------------------------------------
        -- Create a linked server that points to the --
        -- Onepoint database                         --
        -----------------------------------------------

        DECLARE @returnCode INT

        -- Establish defaluts if the parameters are NULL

     IF @linkedServerName IS NULL
         SET @linkedServerName = N'SOURCE'

        IF @onePointDataSource IS NULL
         SET @onePointDataSource = N'(local)'

     IF @onePointCatalog IS NULL
         SET @onePointCatalog = N'OnePoint' 


        -- Note: Since this procedure will be called from a user that belongs
        --       to a setupadmin role, we cannot check in the master database
        --       if this definition already exists. But since we are naming
        --       the linked servers with GUIDs, most likely it will not exist.

        -- Add the linked server definition

      EXECUTE @returnCode = sp_addlinkedserver @server=@linkedServerName, 
                                               @srvproduct=N'', 
                                               @provider=N'SQLOLEDB', 
                                               @datasrc=@onePointDataSource,
                                               @catalog=@onePointCatalog
      IF (@@ERROR <> 0 OR @returnCode <> 0) GOTO QuitWithError 

      IF @useSqlAuthentication = 1
      BEGIN
        EXEC @returnCode = sp_addlinkedsrvlogin @rmtsrvname=@linkedServerName, 
                                                @useself=N'false', 
                                                @locallogin=NULL, 
                                                @rmtuser=@SqlUser,
                                                @rmtpassword=@SqlPassword
       IF (@@ERROR <> 0 OR @returnCode <> 0) GOTO QuitWithError 

      END
        
QuitWithError:

        IF (@@ERROR <> 0) 
            RETURN @@ERROR

        IF (@returnCode <> 0)
            RETURN @returnCode

        RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.p_CreateLogin 
(
    @login sysname,
    @role sysname,
    @defaultdb sysname = NULL,
    @deleteExisting BIT = 1,
    @addToSetupadmin BIT = 0,
    @addToDdladmin BIT = 0,
    @addToSecurityadmin BIT = 0
)
AS
BEGIN

    DECLARE @returnCode INT
    DECLARE @sid varbinary(85)

    -- Establish defaluts if the parameters are NULL

    IF @defaultdb IS NULL
     SET @defaultdb = N'SystemCenterReporting'
    
    IF @deleteExisting IS NULL
     SET @deleteExisting = 1    

    -- Delete the existing login, depending on what was specified. Note that
    -- in cases where you install reporting on the same machine as the 
    -- operational database, some of the logins may already exist which should
    -- not get deleted.
    
    IF @deleteExisting = 1
    BEGIN
        
        -- If the login exists and is a member of the role, remove the login from
        -- the role membership
        
        IF (EXISTS (SELECT * FROM sysmembers SM 
                    INNER JOIN sysusers SU 
                    ON SM.memberuid = SU.uid 
                    WHERE name = @login)
        AND EXISTS (SELECT * FROM sysmembers SM 
                    INNER JOIN sysusers SU 
                    ON SM.groupuid = SU.uid 
                    WHERE name = @role))
        BEGIN
            EXECUTE sp_droprolemember @role, @login
        END

        -- If the login exists, reveoke db access to the login
        
        IF (EXISTS (SELECT * FROM sysusers WHERE name = @login))
        BEGIN
            EXECUTE sp_revokedbaccess @login
        END

        -- If the login exists, remove the login
        
        IF (EXISTS (SELECT * FROM master..syslogins WHERE name = @login))
        BEGIN
            EXECUTE sp_revokelogin @login
        END
        
    END

    -- Add the login if it does not exist

    IF NOT EXISTS (SELECT * FROM master..syslogins WHERE name = @login)
    BEGIN
      
        -- Add the login
        
        EXECUTE @returnCode = sp_grantlogin @login   
        
        IF (@@ERROR <> 0 OR @returnCode <> 0) GOTO QuitWithError 
     
        -- Assign the default db for the login
        
        EXECUTE @returnCode = sp_defaultdb @login, @defaultdb

        IF (@@ERROR <> 0 OR @returnCode <> 0) GOTO QuitWithError 
        
    END        

    -- Get the security identifier for the login
    
    SELECT @sid = sid FROM master..syslogins where loginname = @login

    IF (@sid IS NULL) GOTO QuitWithError

    -- Grant db access, if it has not already been granted
      
    IF NOT EXISTS (select * from sysusers 
                   where  sid = @sid )
    BEGIN
        EXECUTE @returnCode = sp_grantdbaccess @login, @login

        IF (@@ERROR <> 0 OR @returnCode <> 0) GOTO QuitWithError 
    END
        
    
    -- Make the login a role member, if it is not already a member
    
    IF NOT EXISTS (SELECT * FROM sysmembers AS M 
               -- Matching role
               JOIN sysusers AS R
               ON M.groupuid = R.uid
               AND R.issqlrole = 0  
               -- Matching user
               JOIN sysusers AS U
               ON M.memberuid = U.uid
               AND U.islogin = 1                    
               WHERE R.[name] = @role
               AND  U.[sid] = @sid ) 
    BEGIN
        EXECUTE @returnCode = sp_addrolemember @role, @login

        IF (@@ERROR <> 0 OR @returnCode <> 0) GOTO QuitWithError 
    END

    -- If needed, make the login the member of the database
    -- role - db_ddladmin. This is needed for the SC DW DTS role

    IF @addToDdladmin = 1
    BEGIN
        IF NOT EXISTS (SELECT * FROM sysmembers AS M 
                   -- Matching role
                   JOIN sysusers AS R
                   ON M.groupuid = R.uid
                   AND R.issqlrole = 1  
                   -- Matching user
                   JOIN sysusers AS U
                   ON M.memberuid = U.uid
                   AND U.islogin = 1                    
                   WHERE R.[name] = N'db_ddladmin'
                   AND  U.[sid] = @sid ) 
        BEGIN
           EXECUTE @returnCode = sp_addrolemember N'db_ddladmin', @login
            IF (@@ERROR <> 0 OR @returnCode <> 0) GOTO QuitWithError 
        END
    END

    -- If needed, make the login the member of the database
    -- role - db_securityadmin. This is needed for the SC DW DTS role

    IF @addToSecurityadmin = 1
    BEGIN
        IF NOT EXISTS (SELECT * FROM sysmembers AS M 
                   -- Matching role
                   JOIN sysusers AS R
                   ON M.groupuid = R.uid
                   AND R.issqlrole = 1  
                   -- Matching user
                   JOIN sysusers AS U
                   ON M.memberuid = U.uid
                   AND U.islogin = 1                    
                   WHERE R.[name] = N'db_securityadmin'
                   AND  U.[sid] = @sid ) 
        BEGIN
           EXECUTE @returnCode = sp_addrolemember N'db_securityadmin', @login
            IF (@@ERROR <> 0 OR @returnCode <> 0) GOTO QuitWithError 
        END
    END
    
    -- If needed, make the login the member of the server 
    -- role - setupadmin. This is needed for the SC DW DTS role

    IF @addToSetupadmin = 1
    BEGIN
    
        IF (0 = IS_SRVROLEMEMBER(N'setupadmin', @login))
        BEGIN        
         EXECUTE @returnCode = sp_addsrvrolemember @login, N'setupadmin'
         
            IF (@@ERROR <> 0 OR @returnCode <> 0) GOTO QuitWithError 
        END
    END

QuitWithError:

     IF (@@ERROR <> 0) 
        RETURN @@ERROR

     IF (@returnCode <> 0)
        RETURN @returnCode

     RETURN 0
    
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_CreateViewsForClassOrRelationshipDefinitions
@Choice NVARCHAR(20) = N'Class'
AS
BEGIN
        
    DECLARE     @SaveRowCount                                  INTEGER
    DECLARE     @SaveError                                     INTEGER
    DECLARE     @PrevClassIDOrRelationshipTypeID               UNIQUEIDENTIFIER
    DECLARE     @ClassIDOrRelationshipTypeID                   UNIQUEIDENTIFIER
    DECLARE     @ClassNameOrRelationshipTypeName               NVARCHAR(255)
    DECLARE     @ClassAttributeIDOrRelationshipAttributeID     UNIQUEIDENTIFIER
    DECLARE     @ClassAttributeNameOrRelationshipAttributeName NVARCHAR(255)
    DECLARE     @ClassPrimaryKeyName                           NVARCHAR(255)
    DECLARE     @QuotedClassAttributeNameOrRelationshipAttributeName NVARCHAR(255)
    DECLARE     @QuotedClassPrimaryKeyName                     NVARCHAR(255)    
    DECLARE     @ViewNamePrefix                                NVARCHAR(512)
    DECLARE     @ViewName                                      NVARCHAR(512)
    DECLARE     @QuotedViewName                                NVARCHAR(512)
    DECLARE     @DropView                                      NVARCHAR(1024)
    DECLARE     @GrantPermission                               NVARCHAR(512)
    DECLARE     @AttributePrefixInitialColumnSelectPart1       NVARCHAR(400)
    DECLARE     @AttributeSuffixInitialColumnSelectPart1       NVARCHAR(400)
    DECLARE     @AttributePrefixInitialColumnSelect            NVARCHAR(1000)
    DECLARE     @AttributeSuffixInitialColumnSelect            NVARCHAR(1000)
    DECLARE     @CreateViewPrefix                              NVARCHAR(512)
    DECLARE     @CreateViewFilter                              NVARCHAR(700)
    DECLARE     @GroupBy                                       NVARCHAR(200)
    DECLARE     @CreateViewSuffix                              NVARCHAR(1020)
    DECLARE     @AttributePrefix                               NVARCHAR(4000)
    DECLARE     @AttributePrefix1                              NVARCHAR(4000)
    DECLARE     @AttributePrefix2                              NVARCHAR(4000)
    DECLARE     @AttributePrefix3                              NVARCHAR(4000)
    DECLARE     @AttributePrefix4                              NVARCHAR(4000)
    DECLARE     @AttributePrefix5                              NVARCHAR(4000) 
    DECLARE     @AttributePrefix6                              NVARCHAR(4000) 
    DECLARE     @AttributePrefix7                              NVARCHAR(4000) 
    DECLARE     @AttributePrefix8                              NVARCHAR(4000) 
    DECLARE     @AttributePrefix9                              NVARCHAR(4000) 
    DECLARE     @AttributePrefix10                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix11                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix12                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix13                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix14                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix15                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix16                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix17                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix18                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix19                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix20                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix21                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix22                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix23                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix24                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix25                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix26                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix27                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix28                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix29                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix30                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix31                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix32                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix33                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix34                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix35                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix36                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix37                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix38                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix39                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix40                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix41                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix42                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix43                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix44                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix45                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix46                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix47                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix48                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix49                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix50                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix51                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix52                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix53                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix54                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix55                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix56                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix57                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix58                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix59                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix60                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix61                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix62                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix63                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix64                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix65                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix66                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix67                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix68                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix69                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix70                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix71                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix72                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix73                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix74                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix75                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix76                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix77                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix78                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix79                             NVARCHAR(4000) 
    DECLARE     @AttributePrefix80                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffixBegin                          NVARCHAR(10)
    DECLARE     @AttributeSuffixCaseBegin                      NVARCHAR(300)
    DECLARE     @AttributeSuffixCaseEnd                        NVARCHAR(75)
    DECLARE     @AttributeSuffix                               NVARCHAR(4000)
    DECLARE     @AttributeSuffix1                              NVARCHAR(4000)
    DECLARE     @AttributeSuffix2                              NVARCHAR(4000)
    DECLARE     @AttributeSuffix3                              NVARCHAR(4000)
    DECLARE     @AttributeSuffix4                              NVARCHAR(4000)
    DECLARE     @AttributeSuffix5                              NVARCHAR(4000)
    DECLARE     @AttributeSuffix6                              NVARCHAR(4000)
    DECLARE     @AttributeSuffix7                              NVARCHAR(4000) 
    DECLARE     @AttributeSuffix8                              NVARCHAR(4000) 
    DECLARE     @AttributeSuffix9                              NVARCHAR(4000) 
    DECLARE     @AttributeSuffix10                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix11                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix12                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix13                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix14                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix15                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix16                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix17                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix18                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix19                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix20                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix21                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix22                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix23                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix24                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix25                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix26                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix27                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix28                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix29                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix30                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix31                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix32                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix33                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix34                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix35                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix36                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix37                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix38                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix39                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix40                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix41                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix42                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix43                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix44                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix45                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix46                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix47                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix48                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix49                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix50                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix51                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix52                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix53                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix54                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix55                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix56                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix57                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix58                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix59                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix60                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix61                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix62                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix63                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix64                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix65                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix66                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix67                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix68                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix69                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix70                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix71                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix72                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix73                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix74                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix75                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix76                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix77                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix78                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix79                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix80                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix81                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix82                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix83                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix84                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix85                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix86                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix87                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix88                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix89                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix90                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix91                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix92                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix93                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix94                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix95                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix96                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix97                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix98                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix99                             NVARCHAR(4000) 
    DECLARE     @AttributeSuffix100                            NVARCHAR(4000) 
    DECLARE     @AttributeSuffix101                            NVARCHAR(4000) 
    DECLARE     @AttributeSuffix102                            NVARCHAR(4000) 
    DECLARE     @AttributeSuffix103                            NVARCHAR(4000) 
    DECLARE     @AttributeSuffix104                            NVARCHAR(4000) 
    DECLARE     @AttributeSuffix105                            NVARCHAR(4000) 
    DECLARE     @AttributeSuffix106                            NVARCHAR(4000) 
    DECLARE     @AttributeSuffix107                            NVARCHAR(4000) 
    DECLARE     @AttributeSuffix108                            NVARCHAR(4000) 
    DECLARE     @AttributeSuffix109                            NVARCHAR(4000) 
    DECLARE     @AttributeSuffix110                            NVARCHAR(4000) 
    DECLARE     @AttributeSuffix111                            NVARCHAR(4000) 
    DECLARE     @AttributeSuffix112                            NVARCHAR(4000) 
    DECLARE     @AttributeSuffix113                            NVARCHAR(4000) 
    DECLARE     @AttributeSuffix114                            NVARCHAR(4000) 
    DECLARE     @AttributeSuffix115                            NVARCHAR(4000) 
    DECLARE     @AttributeSuffix116                            NVARCHAR(4000) 
    DECLARE     @AttributeSuffix117                            NVARCHAR(4000) 
    DECLARE     @AvailableAttributePrefixNumber                INTEGER
    DECLARE     @AvailableAttributeSuffixNumber                INTEGER
    DECLARE     @AttributePrefixThresholdLength                INTEGER
    DECLARE     @AttributeSuffixThresholdLength                INTEGER
  
    --
    -- The class view will be of the following form
    -- 
    --    SELECT S.ClassInstanceID AS ClassInstanceID,
    --           MAX(S.[{@PKAttribute}]) AS [{@PKAttribute}],
    --
    --           {Begin - Repeat for all attributes}
    --           MAX(S.[{@Attribute#1}]) AS [{@Attribute#1}],
    --           MAX(S.[{@Attribute#2}]) AS [{@Attribute#2}]
    --           {End - Repeat for all attributes}
    --
    --    FROM 
    --   (SELECT CI.ClassInstanceID AS ClassInstanceID,
    --           CI.KeyValue AS [{@PKAttribute}],
    --
    --    {Begin - Repeat for all attributes}
    --    [{@Attribute#1}] =
    --    CASE 
    --        WHEN  CAI.ClassAttributeDefinition_FK = (SELECT CAD.SMC_InstanceID
    --                                                FROM dbo.SC_ClassAttributeDefinitionDimension_View AS CAD
    --                                                WHERE CAD.ClassAttributeID_PK = '{@Attribute#1ID}')
    --        THEN CAI.Value
    --        ELSE NULL
    --    END
    --    {End - Repeat for all attributes}
    --
    --    FROM dbo.SC_ClassInstanceFact_Latest_View AS CI
    --    LEFT OUTER JOIN dbo.SC_ClassAttributeInstanceFact_Latest_View AS CAI
    --    ON CI.ClassInstanceID = CAI.ClassInstanceID
    --    WHERE CI.ClassDefinition_FK = (SELECT CD.SMC_InstanceID 
    --                                   FROM dbo.SC_ClassDefinitionDimension_View AS CD
    --                                   WHERE CD.ClassID_PK = '{@ClassID}')
    --    ) AS S
    --    GROUP BY S.ClassInstanceID
    --
    
    --
    -- The relationship view will be of the following form
    -- 
    --    SELECT S.RelationshipInstanceID AS RelationshipInstanceID,
    --           S.SourceClassInstanceID  AS SourceClassInstanceID,
    --           S.TargetClassInstanceID  AS TargetClassInstanceID,
    --           S.SourceClassInstanceKeyValue AS SourceClassInstanceKeyValue,
    --           S.TargetClassInstanceKeyValue AS TargetClassInstanceKeyValue,
    --
    --           {Begin - Repeat for all attributes}
    --           MAX(S.[{@Attribute#1}]) AS [{@Attribute#1}],
    --           MAX(S.[{@Attribute#2}]) AS [{@Attribute#2}]
    --           {End - Repeat for all attributes}
    --
    --    FROM 
    --   (SELECT RI.RelationshipInstanceID AS RelationshipInstanceID,
    --           RI.SourceClassInstanceID  AS SourceClassInstanceID,
    --           RI.TargetClassInstanceID  AS TargetClassInstanceID,
    --           RI.SourceClassInstanceKeyValue AS SourceClassInstanceKeyValue,
    --           RI.TargetClassInstanceKeyValue AS TargetClassInstanceKeyValue,
    --
    --    {Begin - Repeat for all attributes}
    --    [{@Attribute#1}] =
    --    CASE 
    --        WHEN  RAI.ClassAttributeDefinition_FK = (SELECT RAD.SMC_InstanceID
    --                                                 FROM dbo.SC_RelationshipAttributeDefinitionDimension_View AS RAD
    --                                                 WHERE RAD.RelationshipAttributeID_PK = '{@Attribute#1ID}')
    --        THEN RAI.Value
    --        ELSE NULL
    --    END
    --    {End - Repeat for all attributes}
    --
    --    FROM dbo.SC_RelationshipInstanceFact_Latest_View AS RI
    --    LEFT OUTER JOIN dbo.SC_RelationshipAttributeInstanceFact_Latest_View AS RAI
    --    ON RI.RelationshipInstanceID = RAI.RelationshipInstanceID
    --    WHERE RI.RelationshipDefinition_FK = (SELECT RD.SMC_InstanceID 
    --                                          FROM dbo.SC_RelationshipDefinitionDimension_View AS RD
    --                                          WHERE RD.RelationshipTypeID_PK = '{@RelationshipTypeID}')
    --    ) AS S
    --    GROUP BY S.RelationshipInstanceID
    --

    --
    -- Create a temp table that will hold either the class/attribute definition
    -- or relationship/attribute definitions
    --

    CREATE TABLE #tmpDefinitions
    (
        ClassIDOrRelationshipTypeID                   UNIQUEIDENTIFIER NOT NULL,
        ClassNameOrRelationshipTypeName               NVARCHAR(108) NOT NULL,
        ClassAttributeIDOrRelationshipAttributeID     UNIQUEIDENTIFIER NULL,
        ClassAttributeNameOrRelationshipAttributeName NVARCHAR(128) NULL,
        ClassPrimaryKeyName                           NVARCHAR(128) NULL
    )   
    
    SET @SaveError = @@ERROR
    IF (@SaveError <> 0)
    BEGIN
        GOTO Error_Exit
    END

    --
    -- Initialize variables, depending on the choice
    --

    IF (@Choice = N'Class')
    BEGIN

        --
        -- Initialize for Class
        -- 

        --
        -- Populate the temp table used by the cursor
        --

        INSERT INTO #tmpDefinitions
        SELECT CD.ClassID_PK                                  AS ClassID,
               CAST(CD.[Name] AS NVARCHAR(108))               AS ClassName,
               CAD.ClassAttributeID_PK                        AS ClassAttributeID,
               CAST(CAD.ClassAttributeName AS NVARCHAR(128))  AS ClassAttributeName,
               (SELECT CAST(CADPK.ClassAttributeName AS NVARCHAR(128))
                FROM dbo.SC_ClassAttributeDefinitionDimension_View AS CADPK
                WHERE CADPK.IsPrimaryKey = 1
                AND CADPK.ClassDefinition_FK = CAD.ClassDefinition_FK) AS ClassPrimaryKeyName
        FROM dbo.SC_ClassAttributeDefinitionDimension_View AS CAD
        INNER JOIN dbo.SC_ClassDefinitionDimension_View AS CD
        ON CAD.ClassDefinition_FK = CD.SMC_InstanceID           
        WHERE CD.[Name] NOT IN (N'NULL_CLASS', N'UNRESOLVED_CLASS', N'UNAVAILABLE_CLASS')
        ORDER BY CD.[Name], CAD.ClassAttributeName ASC

        SET @SaveError = @@ERROR  
        IF (@SaveError <> 0)
        BEGIN
            GOTO Error_Exit
        END

        --
        -- Set the prefix that will be used to construct the view name
        -- 
     
        SET @ViewNamePrefix = N'Class'

        --
        -- Set the initial column select for prefix and suffix part
        --

        SET @AttributePrefixInitialColumnSelectPart1 = N'SELECT S.ClassInstanceID AS ClassInstanceID'
        
        SET @AttributeSuffixInitialColumnSelectPart1 = N'
FROM (SELECT CI.ClassInstanceID AS ClassInstanceID'
        
        -- 
        -- Set the filter clause for the create view statement to 
        -- filter based on class id
        --
            
        SET @CreateViewFilter = N'
FROM dbo.SC_ClassInstanceFact_Latest_View AS CI
LEFT OUTER JOIN dbo.SC_ClassAttributeInstanceFact_Latest_View AS CAI
ON CI.ClassInstanceID = CAI.ClassInstanceID
WHERE CI.ClassDefinition_FK = (SELECT CD.SMC_InstanceID 
                               FROM dbo.SC_ClassDefinitionDimension_View AS CD
                               WHERE CD.ClassID_PK = '''
                               
        SET @GroupBy = N'
GROUP BY S.ClassInstanceID'

        --
        -- Set the threshold lengths for attribute prefix and suffix. This 
        -- will determine when to save off to a backup variable
        -- 
        
        SET @AttributePrefixThresholdLength = 3700
        SET @AttributeSuffixThresholdLength = 3400

        --
        -- Create the suffix helpers that will be used to construct the suffix
        --
   
        SET @AttributeSuffixBegin = N',
'
    
        SET @AttributeSuffixCaseBegin = N' = 
CASE
    WHEN CAI.ClassAttributeDefinition_FK = (SELECT CAD.SMC_InstanceID
                                            FROM dbo.SC_ClassAttributeDefinitionDimension_View AS CAD
                                            WHERE CAD.ClassAttributeID_PK = '''
                                                                                     
        SET @AttributeSuffixCaseEnd = N''')
    THEN CAI.Value
    ELSE NULL
END'

    END
    ELSE IF (@Choice = N'Relationship')
    BEGIN

        --
        -- Initialize for Relationship
        -- 
 
        --
        -- Populate the temp table used by the cursor
        --

        INSERT INTO #tmpDefinitions
        SELECT RD.RelationshipTypeID_PK                                AS RelationshipTypeID,
               CAST(RD.RelationshipTypeName AS NVARCHAR(108))          AS RelationshipTypeName,
               RAD.RelationshipAttributeID_PK                          AS RelationshipAttributeID,
               CAST(RAD.RelationshipAttributeName AS NVARCHAR(128))    AS RelationshipAttributeName,
               N''                                                     AS ClassPrimaryKeyName
        FROM dbo.SC_RelationshipDefinitionDimension_View AS RD
        LEFT OUTER JOIN dbo.SC_RelationshipAttributeDefinitionDimension_View AS RAD
        ON RD.SMC_InstanceID = RAD.RelationshipDefinition_FK
        WHERE RD.RelationshipTypeName NOT IN (N'NULL_RELATIONSHIP', N'UNRESOLVED_RELATIONSHIP', N'UNAVAILABLE_RELATIONSHIP')
        ORDER BY RD.RelationshipTypeName, RAD.RelationshipAttributeName ASC

        SET @SaveError = @@ERROR  
        IF (@SaveError <> 0)
        BEGIN
            GOTO Error_Exit
        END
        
        --
        -- Set the prefix that will be used to construct the view name
        -- 
     
        SET @ViewNamePrefix = N'Class_Rel'

        --
        -- Set the initial column select for create view statement
        --

        --
        -- Set the initial column select for prefix and suffix part
        --

        SET @AttributePrefixInitialColumnSelectPart1 = N'SELECT S.RelationshipInstanceID AS RelationshipInstanceID,
S.SourceClassInstanceID  AS SourceClassInstanceID,
S.TargetClassInstanceID  AS TargetClassInstanceID,
S.SourceClassInstanceKeyValue AS SourceClassInstanceKeyValue,
S.TargetClassInstanceKeyValue AS TargetClassInstanceKeyValue'
        
        SET @AttributeSuffixInitialColumnSelectPart1 = N'
FROM (SELECT RI.RelationshipInstanceID AS RelationshipInstanceID,
        RI.SourceClassInstanceID  AS SourceClassInstanceID,
        RI.TargetClassInstanceID  AS TargetClassInstanceID,
        RI.SourceClassInstanceKeyValue AS SourceClassInstanceKeyValue,
        RI.TargetClassInstanceKeyValue AS TargetClassInstanceKeyValue'

        -- 
        -- Set the filter clause for the create view statement to 
        -- filter based on class id
        --

        SET @CreateViewFilter = N'
FROM dbo.SC_RelationshipInstanceFact_Latest_View AS RI
LEFT OUTER JOIN dbo.SC_RelationshipAttributeInstanceFact_Latest_View AS RAI
ON RI.RelationshipInstanceID = RAI.RelationshipInstanceID
WHERE RI.RelationshipDefinition_FK = (SELECT RD.SMC_InstanceID 
                                      FROM dbo.SC_RelationshipDefinitionDimension_View AS RD
                                      WHERE RD.RelationshipTypeID_PK = '''
                               
        SET @GroupBy = N'
GROUP BY S.RelationshipInstanceID,
S.SourceClassInstanceID,
S.TargetClassInstanceID,
S.SourceClassInstanceKeyValue,
S.TargetClassInstanceKeyValue'
             
        --
        -- Set the threshold lengths for attribute prefix and suffix. This 
        -- will determine when to save off to a backup variable
        -- 
        
        SET @AttributePrefixThresholdLength = 3700
        SET @AttributeSuffixThresholdLength = 3400

        --
        -- Create the suffix helpers that will be used to construct the suffix
        --
    
        SET @AttributeSuffixBegin = N',
'
    
        SET @AttributeSuffixCaseBegin = N' = 
CASE
    WHEN RAI.RelationshipAttributeDefinition_FK = (SELECT RAD.SMC_InstanceID
                                                   FROM dbo.SC_RelationshipAttributeDefinitionDimension_View AS RAD
                                                   WHERE RAD.RelationshipAttributeID_PK = '''
                                                                                     
        SET @AttributeSuffixCaseEnd = N''')
    THEN RAI.Value
    ELSE NULL
END'

    END
    ELSE
    BEGIN
        GOTO Error_Exit
    END

    -- 
    -- Delcare a cursor that iterates through all class or relationship 
    -- definition and their class or relationship attribute definitions 
    -- and creates a view for each class or relationship definition
    -- 

    DECLARE CursorDefinitions CURSOR LOCAL FOR
        SELECT D.ClassIDOrRelationshipTypeID                   AS ClassIDOrRelationshipTypeID,
               D.ClassNameOrRelationshipTypeName               AS ClassNameOrRelationshipTypeName,
               D.ClassAttributeIDOrRelationshipAttributeID     AS ClassAttributeIDOrRelationshipAttributeID,
               D.ClassAttributeNameOrRelationshipAttributeName AS ClassAttributeNameOrRelationshipAttributeName,
               D.ClassPrimaryKeyName                           AS ClassPrimaryKeyName
        FROM #tmpDefinitions AS D
        ORDER BY D.ClassNameOrRelationshipTypeName, D.ClassAttributeNameOrRelationshipAttributeName ASC
    OPEN CursorDefinitions
    FETCH NEXT FROM CursorDefinitions INTO @ClassIDOrRelationshipTypeID,
                                           @ClassNameOrRelationshipTypeName,
                                           @ClassAttributeIDOrRelationshipAttributeID,
                                           @ClassAttributeNameOrRelationshipAttributeName,
                                           @ClassPrimaryKeyName
    WHILE @@fetch_status = 0
    BEGIN
    
        --
        -- Reset the variables for the new class or relationship definition
        --
        
        IF @PrevClassIDOrRelationshipTypeID <> @ClassIDOrRelationshipTypeID
        BEGIN
                
            SET @ViewName = N'SC_'                                                             +
                            @ViewNamePrefix                                                    +
                            N'_'                                                               +
                            @ClassNameOrRelationshipTypeName                                   +
                            N'_View'

            SET @QuotedViewName = N'[dbo].'                                                    +
                                  QUOTENAME(@ViewName)

            SET @GrantPermission = N'GRANT SELECT ON '                                         +
                                   @QuotedViewName                                             +
                                   N' TO [SC DW Reader]'

            SET @DropView = N'IF EXISTS (SELECT * FROM dbo.sysobjects '                        + 
                            N'WHERE ID = OBJECT_ID(N'''                                        +
                            @QuotedViewName                                                    +
                            N''') AND OBJECTPROPERTY(ID, N''IsView'') = 1) 
    DROP VIEW '                                                                                +
                            @QuotedViewName

            SET @CreateViewPrefix = N'CREATE VIEW '                                            +
                                    @QuotedViewName                                            +
                                    N' AS
'
                                    
            IF (@ClassPrimaryKeyName IS NOT NULL AND
                @ClassPrimaryKeyName <> N'')
            BEGIN

    --
    -- Create the quoted name for the class or relationship attribute.
    -- Quoted name is necessary in scenarios where the name may have
    -- the characters [ or ] in them. Since we delimit our column names
    -- with [ and ], we will have to use quoted names.
    --
         
    SET @QuotedClassPrimaryKeyName = QUOTENAME(@ClassPrimaryKeyName)
            
                SET @AttributePrefixInitialColumnSelect = @AttributePrefixInitialColumnSelectPart1   + 
                                        N',
MAX(S.'                                                                                              +
                                        @QuotedClassPrimaryKeyName                                   +
                                        N') AS '                                                     +
                                        @QuotedClassPrimaryKeyName

                SET @AttributeSuffixInitialColumnSelect = @AttributeSuffixInitialColumnSelectPart1   + 
                                        N',
CI.KeyValue AS '                                                                                     +
                                        @QuotedClassPrimaryKeyName
            END
            ELSE
            BEGIN
                SET @AttributePrefixInitialColumnSelect = @AttributePrefixInitialColumnSelectPart1
                SET @AttributeSuffixInitialColumnSelect = @AttributeSuffixInitialColumnSelectPart1 
            END
    
            SET @CreateViewSuffix = @CreateViewFilter                                          + 
                                    CAST(@ClassIDOrRelationshipTypeID AS NVARCHAR(40))         +
                                    N''')
) AS S'                                                                                        +
                                    @GroupBy                                                 
    
            SET @AttributePrefix  = N''
            SET @AttributePrefix1 = N''
            SET @AttributePrefix2 = N''
            SET @AttributePrefix3 = N''
            SET @AttributePrefix4 = N''
            SET @AttributePrefix5 = N'' 
            SET @AttributePrefix6 = N'' 
            SET @AttributePrefix7 = N'' 
            SET @AttributePrefix8 = N'' 
            SET @AttributePrefix9 = N'' 
            SET @AttributePrefix10 = N'' 
            SET @AttributePrefix11 = N'' 
            SET @AttributePrefix12 = N'' 
            SET @AttributePrefix13 = N'' 
            SET @AttributePrefix14 = N'' 
            SET @AttributePrefix15 = N'' 
            SET @AttributePrefix16 = N'' 
            SET @AttributePrefix17 = N'' 
            SET @AttributePrefix18 = N'' 
            SET @AttributePrefix19 = N'' 
            SET @AttributePrefix20 = N'' 
            SET @AttributePrefix21 = N'' 
            SET @AttributePrefix22 = N'' 
            SET @AttributePrefix23 = N'' 
            SET @AttributePrefix24 = N'' 
            SET @AttributePrefix25 = N'' 
            SET @AttributePrefix26 = N'' 
            SET @AttributePrefix27 = N'' 
            SET @AttributePrefix28 = N'' 
            SET @AttributePrefix29 = N'' 
            SET @AttributePrefix30 = N'' 
            SET @AttributePrefix31 = N'' 
            SET @AttributePrefix32 = N'' 
            SET @AttributePrefix33 = N'' 
            SET @AttributePrefix34 = N'' 
            SET @AttributePrefix35 = N'' 
            SET @AttributePrefix36 = N'' 
            SET @AttributePrefix37 = N'' 
            SET @AttributePrefix38 = N'' 
            SET @AttributePrefix39 = N'' 
            SET @AttributePrefix40 = N'' 
            SET @AttributePrefix41 = N'' 
            SET @AttributePrefix42 = N'' 
            SET @AttributePrefix43 = N'' 
            SET @AttributePrefix44 = N'' 
            SET @AttributePrefix45 = N'' 
            SET @AttributePrefix46 = N'' 
            SET @AttributePrefix47 = N'' 
            SET @AttributePrefix48 = N'' 
            SET @AttributePrefix49 = N'' 
            SET @AttributePrefix50 = N'' 
            SET @AttributePrefix51 = N'' 
            SET @AttributePrefix52 = N'' 
            SET @AttributePrefix53 = N'' 
            SET @AttributePrefix54 = N'' 
            SET @AttributePrefix55 = N'' 
            SET @AttributePrefix56 = N'' 
            SET @AttributePrefix57 = N'' 
            SET @AttributePrefix58 = N'' 
            SET @AttributePrefix59 = N'' 
            SET @AttributePrefix60 = N'' 
            SET @AttributePrefix61 = N'' 
            SET @AttributePrefix62 = N'' 
            SET @AttributePrefix63 = N'' 
            SET @AttributePrefix64 = N'' 
            SET @AttributePrefix65 = N'' 
            SET @AttributePrefix66 = N'' 
            SET @AttributePrefix67 = N'' 
            SET @AttributePrefix68 = N'' 
            SET @AttributePrefix69 = N'' 
            SET @AttributePrefix70 = N'' 
            SET @AttributePrefix71 = N'' 
            SET @AttributePrefix72 = N'' 
            SET @AttributePrefix73 = N'' 
            SET @AttributePrefix74 = N'' 
            SET @AttributePrefix75 = N'' 
            SET @AttributePrefix76 = N'' 
            SET @AttributePrefix77 = N'' 
            SET @AttributePrefix78 = N'' 
            SET @AttributePrefix79 = N'' 
            SET @AttributePrefix80 = N'' 
            SET @AttributeSuffix  = N''
            SET @AttributeSuffix1 = N''
            SET @AttributeSuffix2 = N''
            SET @AttributeSuffix3 = N''
            SET @AttributeSuffix4 = N''
            SET @AttributeSuffix5 = N''
            SET @AttributeSuffix6 = N''
            SET @AttributeSuffix7 = N'' 
            SET @AttributeSuffix8 = N'' 
            SET @AttributeSuffix9 = N'' 
            SET @AttributeSuffix10 = N'' 
            SET @AttributeSuffix11 = N'' 
            SET @AttributeSuffix12 = N'' 
            SET @AttributeSuffix13 = N'' 
            SET @AttributeSuffix14 = N'' 
            SET @AttributeSuffix15 = N'' 
            SET @AttributeSuffix16 = N'' 
            SET @AttributeSuffix17 = N'' 
            SET @AttributeSuffix18 = N'' 
            SET @AttributeSuffix19 = N'' 
            SET @AttributeSuffix20 = N'' 
            SET @AttributeSuffix21 = N'' 
            SET @AttributeSuffix22 = N'' 
            SET @AttributeSuffix23 = N'' 
            SET @AttributeSuffix24 = N'' 
            SET @AttributeSuffix25 = N'' 
            SET @AttributeSuffix26 = N'' 
            SET @AttributeSuffix27 = N'' 
            SET @AttributeSuffix28 = N'' 
            SET @AttributeSuffix29 = N'' 
            SET @AttributeSuffix30 = N'' 
            SET @AttributeSuffix31 = N'' 
            SET @AttributeSuffix32 = N'' 
            SET @AttributeSuffix33 = N'' 
            SET @AttributeSuffix34 = N'' 
            SET @AttributeSuffix35 = N'' 
            SET @AttributeSuffix36 = N'' 
            SET @AttributeSuffix37 = N'' 
            SET @AttributeSuffix38 = N'' 
            SET @AttributeSuffix39 = N'' 
            SET @AttributeSuffix40 = N'' 
            SET @AttributeSuffix41 = N'' 
            SET @AttributeSuffix42 = N'' 
            SET @AttributeSuffix43 = N'' 
            SET @AttributeSuffix44 = N'' 
            SET @AttributeSuffix45 = N'' 
            SET @AttributeSuffix46 = N'' 
            SET @AttributeSuffix47 = N'' 
            SET @AttributeSuffix48 = N'' 
            SET @AttributeSuffix49 = N'' 
            SET @AttributeSuffix50 = N'' 
            SET @AttributeSuffix51 = N'' 
            SET @AttributeSuffix52 = N'' 
            SET @AttributeSuffix53 = N'' 
            SET @AttributeSuffix54 = N'' 
            SET @AttributeSuffix55 = N'' 
            SET @AttributeSuffix56 = N'' 
            SET @AttributeSuffix57 = N'' 
            SET @AttributeSuffix58 = N'' 
            SET @AttributeSuffix59 = N'' 
            SET @AttributeSuffix60 = N'' 
            SET @AttributeSuffix61 = N'' 
            SET @AttributeSuffix62 = N'' 
            SET @AttributeSuffix63 = N'' 
            SET @AttributeSuffix64 = N'' 
            SET @AttributeSuffix65 = N'' 
            SET @AttributeSuffix66 = N'' 
            SET @AttributeSuffix67 = N'' 
            SET @AttributeSuffix68 = N'' 
            SET @AttributeSuffix69 = N'' 
            SET @AttributeSuffix70 = N'' 
            SET @AttributeSuffix71 = N'' 
            SET @AttributeSuffix72 = N'' 
            SET @AttributeSuffix73 = N'' 
            SET @AttributeSuffix74 = N'' 
            SET @AttributeSuffix75 = N'' 
            SET @AttributeSuffix76 = N'' 
            SET @AttributeSuffix77 = N'' 
            SET @AttributeSuffix78 = N'' 
            SET @AttributeSuffix79 = N'' 
            SET @AttributeSuffix80 = N'' 
            SET @AttributeSuffix81 = N'' 
            SET @AttributeSuffix82 = N'' 
            SET @AttributeSuffix83 = N'' 
            SET @AttributeSuffix84 = N'' 
            SET @AttributeSuffix85 = N'' 
            SET @AttributeSuffix86 = N'' 
            SET @AttributeSuffix87 = N'' 
            SET @AttributeSuffix88 = N'' 
            SET @AttributeSuffix89 = N'' 
            SET @AttributeSuffix90 = N'' 
            SET @AttributeSuffix91 = N'' 
            SET @AttributeSuffix92 = N'' 
            SET @AttributeSuffix93 = N'' 
            SET @AttributeSuffix94 = N'' 
            SET @AttributeSuffix95 = N'' 
            SET @AttributeSuffix96 = N'' 
            SET @AttributeSuffix97 = N'' 
            SET @AttributeSuffix98 = N'' 
            SET @AttributeSuffix99 = N'' 
            SET @AttributeSuffix100 = N'' 
            SET @AttributeSuffix101 = N'' 
            SET @AttributeSuffix102 = N'' 
            SET @AttributeSuffix103 = N'' 
            SET @AttributeSuffix104 = N'' 
            SET @AttributeSuffix105 = N'' 
            SET @AttributeSuffix106 = N'' 
            SET @AttributeSuffix107 = N'' 
            SET @AttributeSuffix108 = N'' 
            SET @AttributeSuffix109 = N'' 
            SET @AttributeSuffix110 = N'' 
            SET @AttributeSuffix111 = N'' 
            SET @AttributeSuffix112 = N'' 
            SET @AttributeSuffix113 = N'' 
            SET @AttributeSuffix114 = N'' 
            SET @AttributeSuffix115 = N'' 
            SET @AttributeSuffix116 = N'' 
            SET @AttributeSuffix117 = N'' 
            SET @AvailableAttributePrefixNumber = 1
            SET @AvailableAttributeSuffixNumber = 1
        END
     
        --
        -- Save the RelationshipTypeID
        --
    
        SET @PrevClassIDOrRelationshipTypeID = @ClassIDOrRelationshipTypeID
        
        --
        -- Create the quoted name for the class or relationship attribute.
        -- Quoted name is necessary in scenarios where the name may have
        -- the characters [ or ] in them. Since we delimit our column names
        -- with [ and ], we will have to use quoted names.
        --
       
        SET @QuotedClassAttributeNameOrRelationshipAttributeName = QUOTENAME(@ClassAttributeNameOrRelationshipAttributeName)
        
        --
        -- Check if there is a valid attribute name (in case of classes, 
        -- ignore the PK column as it is already included in the prefix
        --

        IF (@ClassAttributeIDOrRelationshipAttributeID IS NOT NULL AND
            @ClassPrimaryKeyName <> @ClassAttributeNameOrRelationshipAttributeName)   
        BEGIN
      
            --
            -- If the prefix variable is full save it off into the 1st  
            -- available backup variable
            --
           
            IF (LEN(@AttributePrefix) > @AttributePrefixThresholdLength)
            BEGIN

               IF (@AttributePrefix1 = N'')
                   SET @AttributePrefix1 = @AttributePrefix
               ELSE IF (@AttributePrefix2 = N'')
                   SET @AttributePrefix2 = @AttributePrefix 
               ELSE IF (@AttributePrefix3 = N'')
                   SET @AttributePrefix3 = @AttributePrefix 
               ELSE IF (@AttributePrefix4 = N'')
                   SET @AttributePrefix4 = @AttributePrefix 
               ELSE IF (@AttributePrefix5 = N'')
                   SET @AttributePrefix5 = @AttributePrefix 
               ELSE IF (@AttributePrefix6 = N'')
                   SET @AttributePrefix6 = @AttributePrefix 
               ELSE IF (@AttributePrefix7 = N'')
                   SET @AttributePrefix7 = @AttributePrefix 
               ELSE IF (@AttributePrefix8 = N'')
                   SET @AttributePrefix8 = @AttributePrefix 
               ELSE IF (@AttributePrefix9 = N'')
                   SET @AttributePrefix9 = @AttributePrefix 
               ELSE IF (@AttributePrefix10 = N'')
                   SET @AttributePrefix10 = @AttributePrefix 
               ELSE IF (@AttributePrefix11 = N'')
                   SET @AttributePrefix11 = @AttributePrefix 
               ELSE IF (@AttributePrefix12 = N'')
                   SET @AttributePrefix12 = @AttributePrefix 
               ELSE IF (@AttributePrefix13 = N'')
                   SET @AttributePrefix13 = @AttributePrefix 
               ELSE IF (@AttributePrefix14 = N'')
                   SET @AttributePrefix14 = @AttributePrefix 
               ELSE IF (@AttributePrefix15 = N'')
                   SET @AttributePrefix15 = @AttributePrefix 
               ELSE IF (@AttributePrefix16 = N'')
                   SET @AttributePrefix16 = @AttributePrefix 
               ELSE IF (@AttributePrefix17 = N'')
                   SET @AttributePrefix17 = @AttributePrefix 
               ELSE IF (@AttributePrefix18 = N'')
                   SET @AttributePrefix18 = @AttributePrefix 
               ELSE IF (@AttributePrefix19 = N'')
                   SET @AttributePrefix19 = @AttributePrefix 
               ELSE IF (@AttributePrefix20 = N'')
                   SET @AttributePrefix20 = @AttributePrefix 
               ELSE IF (@AttributePrefix21 = N'')
                   SET @AttributePrefix21 = @AttributePrefix 
               ELSE IF (@AttributePrefix22 = N'')
                   SET @AttributePrefix22 = @AttributePrefix 
               ELSE IF (@AttributePrefix23 = N'')
                   SET @AttributePrefix23 = @AttributePrefix 
               ELSE IF (@AttributePrefix24 = N'')
                   SET @AttributePrefix24 = @AttributePrefix 
               ELSE IF (@AttributePrefix25 = N'')
                   SET @AttributePrefix25 = @AttributePrefix 
               ELSE IF (@AttributePrefix26 = N'')
                   SET @AttributePrefix26 = @AttributePrefix 
               ELSE IF (@AttributePrefix27 = N'')
                   SET @AttributePrefix27 = @AttributePrefix 
               ELSE IF (@AttributePrefix28 = N'')
                   SET @AttributePrefix28 = @AttributePrefix 
               ELSE IF (@AttributePrefix29 = N'')
                   SET @AttributePrefix29 = @AttributePrefix 
               ELSE IF (@AttributePrefix30 = N'')
                   SET @AttributePrefix30 = @AttributePrefix 
               ELSE IF (@AttributePrefix31 = N'')
                   SET @AttributePrefix31 = @AttributePrefix 
               ELSE IF (@AttributePrefix32 = N'')
                   SET @AttributePrefix32 = @AttributePrefix 
               ELSE IF (@AttributePrefix33 = N'')
                   SET @AttributePrefix33 = @AttributePrefix 
               ELSE IF (@AttributePrefix34 = N'')
                   SET @AttributePrefix34 = @AttributePrefix 
               ELSE IF (@AttributePrefix35 = N'')
                   SET @AttributePrefix35 = @AttributePrefix 
               ELSE IF (@AttributePrefix36 = N'')
                   SET @AttributePrefix36 = @AttributePrefix 
               ELSE IF (@AttributePrefix37 = N'')
                   SET @AttributePrefix37 = @AttributePrefix 
               ELSE IF (@AttributePrefix38 = N'')
                   SET @AttributePrefix38 = @AttributePrefix 
               ELSE IF (@AttributePrefix39 = N'')
                   SET @AttributePrefix39 = @AttributePrefix 
               ELSE IF (@AttributePrefix40 = N'')
                   SET @AttributePrefix40 = @AttributePrefix 
               ELSE IF (@AttributePrefix41 = N'')
                   SET @AttributePrefix41 = @AttributePrefix 
               ELSE IF (@AttributePrefix42 = N'')
                   SET @AttributePrefix42 = @AttributePrefix 
               ELSE IF (@AttributePrefix43 = N'')
                   SET @AttributePrefix43 = @AttributePrefix 
               ELSE IF (@AttributePrefix44 = N'')
                   SET @AttributePrefix44 = @AttributePrefix 
               ELSE IF (@AttributePrefix45 = N'')
                   SET @AttributePrefix45 = @AttributePrefix 
               ELSE IF (@AttributePrefix46 = N'')
                   SET @AttributePrefix46 = @AttributePrefix 
               ELSE IF (@AttributePrefix47 = N'')
                   SET @AttributePrefix47 = @AttributePrefix 
               ELSE IF (@AttributePrefix48 = N'')
                   SET @AttributePrefix48 = @AttributePrefix 
               ELSE IF (@AttributePrefix49 = N'')
                   SET @AttributePrefix49 = @AttributePrefix 
               ELSE IF (@AttributePrefix50 = N'')
                   SET @AttributePrefix50 = @AttributePrefix 
               ELSE IF (@AttributePrefix51 = N'')
                   SET @AttributePrefix51 = @AttributePrefix 
               ELSE IF (@AttributePrefix52 = N'')
                   SET @AttributePrefix52 = @AttributePrefix 
               ELSE IF (@AttributePrefix53 = N'')
                   SET @AttributePrefix53 = @AttributePrefix 
               ELSE IF (@AttributePrefix54 = N'')
                   SET @AttributePrefix54 = @AttributePrefix 
               ELSE IF (@AttributePrefix55 = N'')
                   SET @AttributePrefix55 = @AttributePrefix 
               ELSE IF (@AttributePrefix56 = N'')
                   SET @AttributePrefix56 = @AttributePrefix 
               ELSE IF (@AttributePrefix57 = N'')
                   SET @AttributePrefix57 = @AttributePrefix 
               ELSE IF (@AttributePrefix58 = N'')
                   SET @AttributePrefix58 = @AttributePrefix 
               ELSE IF (@AttributePrefix59 = N'')
                   SET @AttributePrefix59 = @AttributePrefix 
               ELSE IF (@AttributePrefix60 = N'')
                   SET @AttributePrefix60 = @AttributePrefix 
               ELSE IF (@AttributePrefix61 = N'')
                   SET @AttributePrefix61 = @AttributePrefix 
               ELSE IF (@AttributePrefix62 = N'')
                   SET @AttributePrefix62 = @AttributePrefix 
               ELSE IF (@AttributePrefix63 = N'')
                   SET @AttributePrefix63 = @AttributePrefix 
               ELSE IF (@AttributePrefix64 = N'')
                   SET @AttributePrefix64 = @AttributePrefix 
               ELSE IF (@AttributePrefix65 = N'')
                   SET @AttributePrefix65 = @AttributePrefix 
               ELSE IF (@AttributePrefix66 = N'')
                   SET @AttributePrefix66 = @AttributePrefix 
               ELSE IF (@AttributePrefix67 = N'')
                   SET @AttributePrefix67 = @AttributePrefix 
               ELSE IF (@AttributePrefix68 = N'')
                   SET @AttributePrefix68 = @AttributePrefix 
               ELSE IF (@AttributePrefix69 = N'')
                   SET @AttributePrefix69 = @AttributePrefix 
               ELSE IF (@AttributePrefix70 = N'')
                   SET @AttributePrefix70 = @AttributePrefix 
               ELSE IF (@AttributePrefix71 = N'')
                   SET @AttributePrefix71 = @AttributePrefix 
               ELSE IF (@AttributePrefix72 = N'')
                   SET @AttributePrefix72 = @AttributePrefix 
               ELSE IF (@AttributePrefix73 = N'')
                   SET @AttributePrefix73 = @AttributePrefix 
               ELSE IF (@AttributePrefix74 = N'')
                   SET @AttributePrefix74 = @AttributePrefix 
               ELSE IF (@AttributePrefix75 = N'')
                   SET @AttributePrefix75 = @AttributePrefix 
               ELSE IF (@AttributePrefix76 = N'')
                   SET @AttributePrefix76 = @AttributePrefix 
               ELSE IF (@AttributePrefix77 = N'')
                   SET @AttributePrefix77 = @AttributePrefix 
               ELSE IF (@AttributePrefix78 = N'')
                   SET @AttributePrefix78 = @AttributePrefix 
               ELSE IF (@AttributePrefix79 = N'')
                   SET @AttributePrefix79 = @AttributePrefix 
               ELSE IF (@AttributePrefix80 = N'')
                   SET @AttributePrefix80 = @AttributePrefix 

               SET @SaveError = @@ERROR    
               IF (@SaveError <> 0)
               BEGIN
                   GOTO Error_Exit
               END

               SET @AvailableAttributePrefixNumber = @AvailableAttributePrefixNumber + 1
               IF (@AvailableAttributePrefixNumber > 80)
               BEGIN
                   GOTO Error_Exit
               END
               SET @AttributePrefix = N''

            END

            --
            -- For the current attribute, create the prefix part of the create  
            -- view command 
            --
     
            SET @AttributePrefix =  @AttributePrefix                                     +
                                    N',
MAX(S.'                                                                                  +
                                    @QuotedClassAttributeNameOrRelationshipAttributeName +
                                    N') AS '                                             +
                                    @QuotedClassAttributeNameOrRelationshipAttributeName
        
            SET @SaveError = @@ERROR    
            IF (@SaveError <> 0)
            BEGIN
                GOTO Error_Exit
            END
        
            --
            -- If the suffix variable is full save it off into the 1st available 
            -- backup variable
            --

            IF (LEN(@AttributeSuffix) > @AttributeSuffixThresholdLength)
            BEGIN

               IF (@AttributeSuffix1 = N'')
                   SET @AttributeSuffix1 = @AttributeSuffix
               ELSE IF (@AttributeSuffix2 = N'')
                   SET @AttributeSuffix2 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix3 = N'')
                   SET @AttributeSuffix3 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix4 = N'')
                   SET @AttributeSuffix4 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix5 = N'')
                   SET @AttributeSuffix5 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix6 = N'')
                   SET @AttributeSuffix6 = @AttributeSuffix                  
               ELSE IF (@AttributeSuffix7 = N'')
                   SET @AttributeSuffix7 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix8 = N'')
                   SET @AttributeSuffix8 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix9 = N'')
                   SET @AttributeSuffix9 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix10 = N'')
                   SET @AttributeSuffix10 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix11 = N'')
                   SET @AttributeSuffix11 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix12 = N'')
                   SET @AttributeSuffix12 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix13 = N'')
                   SET @AttributeSuffix13 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix14 = N'')
                   SET @AttributeSuffix14 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix15 = N'')
                   SET @AttributeSuffix15 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix16 = N'')
                   SET @AttributeSuffix16 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix17 = N'')
                   SET @AttributeSuffix17 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix18 = N'')
                   SET @AttributeSuffix18 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix19 = N'')
                   SET @AttributeSuffix19 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix20 = N'')
                   SET @AttributeSuffix20 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix21 = N'')
                   SET @AttributeSuffix21 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix22 = N'')
                   SET @AttributeSuffix22 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix23 = N'')
                   SET @AttributeSuffix23 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix24 = N'')
                   SET @AttributeSuffix24 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix25 = N'')
                   SET @AttributeSuffix25 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix26 = N'')
                   SET @AttributeSuffix26 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix27 = N'')
                   SET @AttributeSuffix27 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix28 = N'')
                   SET @AttributeSuffix28 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix29 = N'')
                   SET @AttributeSuffix29 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix30 = N'')
                   SET @AttributeSuffix30 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix31 = N'')
                   SET @AttributeSuffix31 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix32 = N'')
                   SET @AttributeSuffix32 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix33 = N'')
                   SET @AttributeSuffix33 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix34 = N'')
                   SET @AttributeSuffix34 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix35 = N'')
                   SET @AttributeSuffix35 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix36 = N'')
                   SET @AttributeSuffix36 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix37 = N'')
                   SET @AttributeSuffix37 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix38 = N'')
                   SET @AttributeSuffix38 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix39 = N'')
                   SET @AttributeSuffix39 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix40 = N'')
                   SET @AttributeSuffix40 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix41 = N'')
                   SET @AttributeSuffix41 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix42 = N'')
                   SET @AttributeSuffix42 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix43 = N'')
                   SET @AttributeSuffix43 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix44 = N'')
                   SET @AttributeSuffix44 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix45 = N'')
                   SET @AttributeSuffix45 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix46 = N'')
                   SET @AttributeSuffix46 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix47 = N'')
                   SET @AttributeSuffix47 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix48 = N'')
                   SET @AttributeSuffix48 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix49 = N'')
                   SET @AttributeSuffix49 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix50 = N'')
                   SET @AttributeSuffix50 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix51 = N'')
                   SET @AttributeSuffix51 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix52 = N'')
                   SET @AttributeSuffix52 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix53 = N'')
                   SET @AttributeSuffix53 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix54 = N'')
                   SET @AttributeSuffix54 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix55 = N'')
                   SET @AttributeSuffix55 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix56 = N'')
                   SET @AttributeSuffix56 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix57 = N'')
                   SET @AttributeSuffix57 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix58 = N'')
                   SET @AttributeSuffix58 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix59 = N'')
                   SET @AttributeSuffix59 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix60 = N'')
                   SET @AttributeSuffix60 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix61 = N'')
                   SET @AttributeSuffix61 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix62 = N'')
                   SET @AttributeSuffix62 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix63 = N'')
                   SET @AttributeSuffix63 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix64 = N'')
                   SET @AttributeSuffix64 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix65 = N'')
                   SET @AttributeSuffix65 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix66 = N'')
                   SET @AttributeSuffix66 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix67 = N'')
                   SET @AttributeSuffix67 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix68 = N'')
                   SET @AttributeSuffix68 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix69 = N'')
                   SET @AttributeSuffix69 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix70 = N'')
                   SET @AttributeSuffix70 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix71 = N'')
                   SET @AttributeSuffix71 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix72 = N'')
                   SET @AttributeSuffix72 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix73 = N'')
                   SET @AttributeSuffix73 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix74 = N'')
                   SET @AttributeSuffix74 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix75 = N'')
                   SET @AttributeSuffix75 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix76 = N'')
                   SET @AttributeSuffix76 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix77 = N'')
                   SET @AttributeSuffix77 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix78 = N'')
                   SET @AttributeSuffix78 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix79 = N'')
                   SET @AttributeSuffix79 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix80 = N'')
                   SET @AttributeSuffix80 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix81 = N'')
                   SET @AttributeSuffix81 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix82 = N'')
                   SET @AttributeSuffix82 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix83 = N'')
                   SET @AttributeSuffix83 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix84 = N'')
                   SET @AttributeSuffix84 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix85 = N'')
                   SET @AttributeSuffix85 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix86 = N'')
                   SET @AttributeSuffix86 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix87 = N'')
                   SET @AttributeSuffix87 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix88 = N'')
                   SET @AttributeSuffix88 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix89 = N'')
                   SET @AttributeSuffix89 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix90 = N'')
                   SET @AttributeSuffix90 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix91 = N'')
                   SET @AttributeSuffix91 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix92 = N'')
                   SET @AttributeSuffix92 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix93 = N'')
                   SET @AttributeSuffix93 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix94 = N'')
                   SET @AttributeSuffix94 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix95 = N'')
                   SET @AttributeSuffix95 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix96 = N'')
                   SET @AttributeSuffix96 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix97 = N'')
                   SET @AttributeSuffix97 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix98 = N'')
                   SET @AttributeSuffix98 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix99 = N'')
                   SET @AttributeSuffix99 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix100 = N'')
                   SET @AttributeSuffix100 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix101 = N'')
                   SET @AttributeSuffix101 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix102 = N'')
                   SET @AttributeSuffix102 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix103 = N'')
                   SET @AttributeSuffix103 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix104 = N'')
                   SET @AttributeSuffix104 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix105 = N'')
                   SET @AttributeSuffix105 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix106 = N'')
                   SET @AttributeSuffix106 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix107 = N'')
                   SET @AttributeSuffix107 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix108 = N'')
                   SET @AttributeSuffix108 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix109 = N'')
                   SET @AttributeSuffix109 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix110 = N'')
                   SET @AttributeSuffix110 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix111 = N'')
                   SET @AttributeSuffix111 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix112 = N'')
                   SET @AttributeSuffix112 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix113 = N'')
                   SET @AttributeSuffix113 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix114 = N'')
                   SET @AttributeSuffix114 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix115 = N'')
                   SET @AttributeSuffix115 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix116 = N'')
                   SET @AttributeSuffix116 = @AttributeSuffix 
               ELSE IF (@AttributeSuffix117 = N'')
                   SET @AttributeSuffix117 = @AttributeSuffix 
                   

               SET @SaveError = @@ERROR    
               IF (@SaveError <> 0)
               BEGIN
                   GOTO Error_Exit
               END

               SET @AvailableAttributeSuffixNumber = @AvailableAttributeSuffixNumber + 1
               IF (@AvailableAttributeSuffixNumber > 117)
               BEGIN
                   GOTO Error_Exit
               END
               SET @AttributeSuffix = N''

            END

            --
            -- For the current attribute, create the suffix part of the create  
            -- view command 
            --
      
            SET @AttributeSuffix =  @AttributeSuffix                                                 +
                                    @AttributeSuffixBegin                                            +
                                    @QuotedClassAttributeNameOrRelationshipAttributeName             +
                                    @AttributeSuffixCaseBegin                                        + 
                                    CAST(@ClassAttributeIDOrRelationshipAttributeID AS NVARCHAR(40)) +
                                    @AttributeSuffixCaseEnd
        
            SET @SaveError = @@ERROR    
            IF (@SaveError <> 0)
            BEGIN
                GOTO Error_Exit
            END
        END
       
        --
        -- Fetch the next row
        --
        
        FETCH NEXT FROM CursorDefinitions INTO @ClassIDOrRelationshipTypeID,
                                               @ClassNameOrRelationshipTypeName,
                                               @ClassAttributeIDOrRelationshipAttributeID,
                                               @ClassAttributeNameOrRelationshipAttributeName,
                                               @ClassPrimaryKeyName

        --
        -- Detect if a class or relationship definition has ended, if so  
        -- execute the create view command
        -- 
    
        IF (@PrevClassIDOrRelationshipTypeID IS NOT NULL AND
            @PrevClassIDOrRelationshipTypeID <> @ClassIDOrRelationshipTypeID) OR 
            @@fetch_status <> 0
        BEGIN

            --
            -- First drop the view if it exists
            --
 
            EXECUTE (@DropView)

            SET @SaveError = @@ERROR
            IF (@SaveError <> 0)
            BEGIN
                GOTO Error_Exit
            END
    
            --
            -- Concatenate the variables to form the create view command
            -- and execute it
            --

            EXECUTE (@CreateViewPrefix                    +
                     @AttributePrefixInitialColumnSelect  +
                     @AttributePrefix1                    +
                     @AttributePrefix2                    +
                     @AttributePrefix3                    + 
                     @AttributePrefix4                    + 
                     @AttributePrefix5                    + 
                     @AttributePrefix6                    + 
                     @AttributePrefix7                    + 
                     @AttributePrefix8                    + 
                     @AttributePrefix9                    + 
                     @AttributePrefix10                   + 
                     @AttributePrefix11                   + 
                     @AttributePrefix12                   + 
                     @AttributePrefix13                   + 
                     @AttributePrefix14                   + 
                     @AttributePrefix15                   + 
                     @AttributePrefix16                   + 
                     @AttributePrefix17                   + 
                     @AttributePrefix18                   + 
                     @AttributePrefix19                   + 
                     @AttributePrefix20                   + 
                     @AttributePrefix21                   + 
                     @AttributePrefix22                   + 
                     @AttributePrefix23                   + 
                     @AttributePrefix24                   + 
                     @AttributePrefix25                   + 
                     @AttributePrefix26                   + 
                     @AttributePrefix27                   + 
                     @AttributePrefix28                   + 
                     @AttributePrefix29                   + 
                     @AttributePrefix30                   + 
                     @AttributePrefix31                   + 
                     @AttributePrefix32                   + 
                     @AttributePrefix33                   + 
                     @AttributePrefix34                   + 
                     @AttributePrefix35                   + 
                     @AttributePrefix36                   + 
                     @AttributePrefix37                   + 
                     @AttributePrefix38                   + 
                     @AttributePrefix39                   + 
                     @AttributePrefix40                   + 
                     @AttributePrefix41                   + 
                     @AttributePrefix42                   + 
                     @AttributePrefix43                   + 
                     @AttributePrefix44                   + 
                     @AttributePrefix45                   + 
                     @AttributePrefix46                   + 
                     @AttributePrefix47                   + 
                     @AttributePrefix48                   + 
                     @AttributePrefix49                   + 
                     @AttributePrefix50                   + 
                     @AttributePrefix51                   + 
                     @AttributePrefix52                   + 
                     @AttributePrefix53                   + 
                     @AttributePrefix54                   + 
                     @AttributePrefix55                   + 
                     @AttributePrefix56                   + 
                     @AttributePrefix57                   + 
                     @AttributePrefix58                   + 
                     @AttributePrefix59                   + 
                     @AttributePrefix60                   + 
                     @AttributePrefix61                   + 
                     @AttributePrefix62                   + 
                     @AttributePrefix63                   + 
                     @AttributePrefix64                   + 
                     @AttributePrefix65                   + 
                     @AttributePrefix66                   + 
                     @AttributePrefix67                   + 
                     @AttributePrefix68                   + 
                     @AttributePrefix69                   + 
                     @AttributePrefix70                   + 
                     @AttributePrefix71                   + 
                     @AttributePrefix72                   + 
                     @AttributePrefix73                   + 
                     @AttributePrefix74                   + 
                     @AttributePrefix75                   + 
                     @AttributePrefix76                   + 
                     @AttributePrefix77                   + 
                     @AttributePrefix78                   + 
                     @AttributePrefix79                   + 
                     @AttributePrefix80                   + 
                     @AttributePrefix                     + 
                     @AttributeSuffixInitialColumnSelect  +
                     @AttributeSuffix1                    + 
                     @AttributeSuffix2                    + 
                     @AttributeSuffix3                    + 
                     @AttributeSuffix4                    + 
                     @AttributeSuffix5                    + 
                     @AttributeSuffix6                    + 
                     @AttributeSuffix7                    + 
                     @AttributeSuffix8                    + 
                     @AttributeSuffix9                    + 
                     @AttributeSuffix10                   + 
                     @AttributeSuffix11                   + 
                     @AttributeSuffix12                   + 
                     @AttributeSuffix13                   + 
                     @AttributeSuffix14                   + 
                     @AttributeSuffix15                   + 
                     @AttributeSuffix16                   + 
                     @AttributeSuffix17                   + 
                     @AttributeSuffix18                   + 
                     @AttributeSuffix19                   + 
                     @AttributeSuffix20                   + 
                     @AttributeSuffix21                   + 
                     @AttributeSuffix22                   + 
                     @AttributeSuffix23                   + 
                     @AttributeSuffix24                   + 
                     @AttributeSuffix25                   + 
                     @AttributeSuffix26                   + 
                     @AttributeSuffix27                   + 
                     @AttributeSuffix28                   + 
                     @AttributeSuffix29                   + 
                     @AttributeSuffix30                   + 
                     @AttributeSuffix31                   + 
                     @AttributeSuffix32                   + 
                     @AttributeSuffix33                   + 
                     @AttributeSuffix34                   + 
                     @AttributeSuffix35                   + 
                     @AttributeSuffix36                   + 
                     @AttributeSuffix37                   + 
                     @AttributeSuffix38                   + 
                     @AttributeSuffix39                   + 
                     @AttributeSuffix40                   + 
                     @AttributeSuffix41                   + 
                     @AttributeSuffix42                   + 
                     @AttributeSuffix43                   + 
                     @AttributeSuffix44                   + 
                     @AttributeSuffix45                   + 
                     @AttributeSuffix46                   + 
                     @AttributeSuffix47                   + 
                     @AttributeSuffix48                   + 
                     @AttributeSuffix49                   + 
                     @AttributeSuffix50                   + 
                     @AttributeSuffix51                   + 
                     @AttributeSuffix52                   + 
                     @AttributeSuffix53                   + 
                     @AttributeSuffix54                   + 
                     @AttributeSuffix55                   + 
                     @AttributeSuffix56                   + 
                     @AttributeSuffix57                   + 
                     @AttributeSuffix58                   + 
                     @AttributeSuffix59                   + 
                     @AttributeSuffix60                   + 
                     @AttributeSuffix61                   + 
                     @AttributeSuffix62                   + 
                     @AttributeSuffix63                   + 
                     @AttributeSuffix64                   + 
                     @AttributeSuffix65                   + 
                     @AttributeSuffix66                   + 
                     @AttributeSuffix67                   + 
                     @AttributeSuffix68                   + 
                     @AttributeSuffix69                   + 
                     @AttributeSuffix70                   + 
                     @AttributeSuffix71                   + 
                     @AttributeSuffix72                   + 
                     @AttributeSuffix73                   + 
                     @AttributeSuffix74                   + 
                     @AttributeSuffix75                   + 
                     @AttributeSuffix76                   + 
                     @AttributeSuffix77                   + 
                     @AttributeSuffix78                   + 
                     @AttributeSuffix79                   + 
                     @AttributeSuffix80                   + 
                     @AttributeSuffix81                   + 
                     @AttributeSuffix82                   + 
                     @AttributeSuffix83                   + 
                     @AttributeSuffix84                   + 
                     @AttributeSuffix85                   + 
                     @AttributeSuffix86                   + 
                     @AttributeSuffix87                   + 
                     @AttributeSuffix88                   + 
                     @AttributeSuffix89                   + 
                     @AttributeSuffix90                   + 
                     @AttributeSuffix91                   + 
                     @AttributeSuffix92                   + 
                     @AttributeSuffix93                   + 
                     @AttributeSuffix94                   + 
                     @AttributeSuffix95                   + 
                     @AttributeSuffix96                   + 
                     @AttributeSuffix97                   + 
                     @AttributeSuffix98                   + 
                     @AttributeSuffix99                   + 
                     @AttributeSuffix100                  + 
                     @AttributeSuffix101                  + 
                     @AttributeSuffix102                  + 
                     @AttributeSuffix103                  + 
                     @AttributeSuffix104                  + 
                     @AttributeSuffix105                  + 
                     @AttributeSuffix106                  + 
                     @AttributeSuffix107                  + 
                     @AttributeSuffix108                  + 
                     @AttributeSuffix109                  + 
                     @AttributeSuffix110                  + 
                     @AttributeSuffix111                  + 
                     @AttributeSuffix112                  + 
                     @AttributeSuffix113                  + 
                     @AttributeSuffix114                  + 
                     @AttributeSuffix115                  + 
                     @AttributeSuffix116                  + 
                     @AttributeSuffix117                  + 
                     @AttributeSuffix                     + 
                     @CreateViewSuffix)
    
            SET @SaveError = @@ERROR
            IF (@SaveError <> 0)
            BEGIN
                GOTO Error_Exit
            END

            -- Grant permission to the view

            EXECUTE (@GrantPermission)

            SET @SaveError = @@ERROR
            IF (@SaveError <> 0)
            BEGIN
                GOTO Error_Exit
            END

        END
                                               
    END
    CLOSE CursorDefinitions
    DEALLOCATE CursorDefinitions
 
    --
    -- Drop all the temp tables
    --
    
    DROP TABLE #tmpDefinitions

    RETURN 0
    
Error_Exit:
    
    -- SQL Server error %u encountered in p_CreateViewsForClassOrRelationshipDefinitions.
    RAISERROR (777977204, 16, 1, @SaveError) WITH LOG
       
    RETURN @SaveError
        
END
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_DeleteDWGroomJob @jobName NVARCHAR(50) = NULL

AS
BEGIN

        DECLARE @jobID UNIQUEIDENTIFIER
        DECLARE @returnCode INT
        
        -----------------------------------------------
        -- Drop DW messages --
        -----------------------------------------------

        if exists (select * from master.dbo.sysmessages where error = 777977201)
            exec sp_dropmessage @msgnum = 777977201, @lang = 'all'
        if exists (select * from master.dbo.sysmessages where error = 777977202)
            exec sp_dropmessage @msgnum = 777977202, @lang = 'all'
        if exists (select * from master.dbo.sysmessages where error = 777977203)
            exec sp_dropmessage @msgnum = 777977203, @lang = 'all'

        -----------------------------------------------
        -- Disable the job for DW Grooming           --
        -----------------------------------------------
        
        -- Establish a name for the job
    
        IF (@jobName IS NULL)
        BEGIN
            SET @jobName = N'SCDWGroomJob'
        END

        -- Disable the job with the same name (if it exists)

        SELECT @jobID = job_id     
        FROM   msdb.dbo.sysjobs    
        WHERE ([name] = @jobName)       

        IF (@jobID IS NOT NULL)    
        BEGIN  

            -- Delete the job 
            EXECUTE msdb.dbo.sp_delete_job @job_name = @jobName 
           IF (@@ERROR <> 0 OR @returnCode <> 0) GOTO QuitWithError 
        END 

QuitWithError:

        IF (@@ERROR <> 0) 
            RETURN @@ERROR

        IF (@returnCode <> 0)
            RETURN @returnCode

        RETURN 0
END
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.p_DeleteIndexes
@Choice NVARCHAR(20) = N'Facts'
AS
BEGIN
        
    DECLARE     @SaveRowCount         INTEGER
    DECLARE     @SaveError            INTEGER
    DECLARE     @SourceQuery          NVARCHAR(3000)
    DECLARE     @Where                NVARCHAR(256)
    DECLARE     @IndexID              UNIQUEIDENTIFIER
    DECLARE     @IndexName            NVARCHAR(128)
    DECLARE     @TableName            NVARCHAR(128)

    -- 
    -- The delete index will be of the following form:
    -- 
    -- DROP INDEX [{TableName}].[{IndexName}]
    --
          
    --
    -- Create a temp table that will hold index definitions
    --

    CREATE TABLE #tmpDefinitions
    (
        IndexID                                       UNIQUEIDENTIFIER NOT NULL,
        IndexName                                     NVARCHAR(128)    NOT NULL,
        TableName                                     NVARCHAR(128)    NOT NULL,
        [Clustered]                                   BIT              NOT NULL
    )   
    
    SET @SaveError = @@ERROR
    IF (@SaveError <> 0)
    BEGIN
        GOTO Error_Exit
    END

    --
    -- Initialize variables, depending on the choice
    --

    SET @SourceQuery = N'INSERT INTO #tmpDefinitions
        SELECT CI.ClassIndexID    AS IndexID,         
               CI.IndexName       AS IndexName,          
               CS.TableName       AS TableName,
               CI.[Clustered]     AS [Clustered]      
        FROM dbo.SMC_Meta_ClassIndexes AS CI        
        INNER JOIN dbo.SMC_Meta_ClassSchemas AS CS
        ON CI.ClassID = CS.ClassID
        INNER JOIN dbo.SMC_Meta_WarehouseClassSchema AS WCS
        ON CS.ClassID = WCS.ClassID
'

    IF (@Choice = N'Facts')
    BEGIN
        SET @Where = N'        WHERE WarehouseTableType = 2'
    END
    ELSE IF (@Choice = N'Dimensions')
    BEGIN
        SET @Where = N'        WHERE WarehouseTableType = 1'
    END
    ELSE IF (@Choice = N'Both')
    BEGIN
        SET @Where = N'        WHERE WarehouseTableType = 1 OR WarehouseTableType = 2'
    END
    ELSE 
    BEGIN
        GOTO Error_Exit
    END

    SET @SourceQuery = @SourceQuery    +
                       @Where          +
                       N'
        ORDER BY CI.[Clustered] ASC, CI.ClassIndexID ASC'
 
    --
    -- Populate the temp table
    --

    PRINT @SourceQuery
    EXECUTE (@SourceQuery)

    SET @SaveError = @@ERROR
    IF (@SaveError <> 0)
    BEGIN
        GOTO Error_Exit
    END

    -- 
    -- Delcare a cursor that iterates through all index definitions
    -- as creates the indexes. Order such that clustered indexes
    -- appear last.
    -- 

    DECLARE CursorDefinitions CURSOR LOCAL FOR
        SELECT D.IndexID        AS IndexID,
               D.IndexName      AS IndexName,
               D.TableName      AS TableName
        FROM #tmpDefinitions AS D
        ORDER BY D.[Clustered] ASC, D.IndexID ASC
    OPEN CursorDefinitions
    FETCH NEXT FROM CursorDefinitions INTO @IndexID,
                                           @IndexName,
                                           @TableName
    WHILE @@fetch_status = 0
    BEGIN

        PRINT N'IF EXISTS (SELECT [name] FROM sysindexes WHERE [name] = N''' +
                 @IndexName           +               
                 ''')
    DROP INDEX dbo.['                 +
                 @TableName           +
                 N'].['               +
                 @IndexName           +
                 N']'

        EXECUTE (N'IF EXISTS (SELECT [name] FROM sysindexes WHERE [name] = N''' +
                 @IndexName           +               
                 ''')
    DROP INDEX dbo.['                 +
                 @TableName           +
                 N'].['               +
                 @IndexName           +
                 N']')
        
        SET @SaveError = @@ERROR
        IF (@SaveError <> 0)
        BEGIN
           GOTO Error_Exit
        END
               
        --
        -- Fetch the next row
        --
        
        FETCH NEXT FROM CursorDefinitions INTO @IndexID,
                                               @IndexName,
                                               @TableName
    END
    CLOSE CursorDefinitions
    DEALLOCATE CursorDefinitions
 
    --
    -- Drop all the temp tables
    --
    
    DROP TABLE #tmpDefinitions

    RETURN 0
    
Error_Exit:
    
    -- SQL Server error %u encountered in p_DeleteIndexes.
    RAISERROR (777977206, 16, 1, @SaveError) WITH LOG
       
    RETURN @SaveError
        
END
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_DeleteLinkedServer @linkedServerName sysname = NULL
AS
BEGIN
        -- Establish defaults if the parameters are NULL

     IF @linkedServerName IS NULL
         SET @linkedServerName = N'SOURCE'

        -- Note: Since this procedure will be called from a user that belongs
        --       to a setupadmin role, we cannot check in the master database
        --       if this definition exists. But since we are calling this only
        --       after we have successfully created the linked server (whose 
        --       name is a GUID), most likely it will exist.

        EXECUTE sp_dropserver @linkedServerName

        RETURN 0
 
END
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


Create PROC dbo.p_ExchangeServer2003ClientMonitoringReport
 @Computer nvarchar(1000) ,
 @BeginDate datetime ,
 @EndDate datetime 
AS
BEGIN

DECLARE @countername nvarchar(1000), @server nvarchar(510)
Create table #totaltable (server nvarchar(510), countername nvarchar(1000), total float)
Create table #resulttable ( 
 Server nvarchar(510),
 attempted float,
 failed float,
 percentSuccess float,
 avgClientLatency float,
 avgServerLatency float,
 percentLatencyGT2 float,
 percentLatencyGT5 float,
 percentLatencyGT10 float,
 rpcErrorType nvarchar(1000), 
 numberOfFailures float)
DECLARE @total float, @attempted float, @failed float, @succeeded float
DECLARE @latency_total float, @latency_gt10 float, @latency_gt5 float, @latency_gt2 float, @avg_latency_serverside float
DECLARE @counterProcessed int

 
CREATE TABLE #XClientMonTB(
 orderID int IDENTITY PRIMARY KEY,
 time datetime,
 server nvarchar(600),
 countername nvarchar(1000),
 value float )

 INSERT #XClientMonTB (time, server, countername, value)
 SELECT time, server, countername, value 
 FROM (
  SELECT  
   [Time]   = SND.LocalDateTimeSampled, 
   Server  = CD.FullComputerName,
   [countername] = CDD.ObjectName_PK + ':' + CDD.CounterName_PK,
   [value]  = SND.SampleValue
  FROM          
   dbo.SC_SampledNumericDataFact_View SND INNER JOIN
          dbo.SC_CounterDetailDimension_View CDD ON CDD.SMC_InstanceID = SND.CounterDetail_FK INNER JOIN
          dbo.SC_ComputerDimension_View CD ON CD.SMC_InstanceID = SND.Computer_FK 
  WHERE   
   CDD.ObjectName_PK in ('MSExchangeIS') AND CDD.CounterName_PK in ('Client: RPCs attempted',
    'Client: RPCs succeeded',
    'Client: RPCs Failed',
    'Client: RPCs Failed: Access Denied',
    'Client: RPCs Failed: All other errors',
    'Client: RPCs Failed: Call Cancelled',
    'Client: RPCs Failed: Call Failed',
    'Client: RPCs Failed: Server Too Busy',
    'Client: RPCs Failed: Server Unavailable',
    'Client: Total reported latency',
    'Client: Latency > 2 sec RPCs',
    'Client: Latency > 5 sec RPCs',
    'Client: Latency > 10 sec RPCs',
    'RPC Averaged Latency')
   and SND.LocalDateTimeSampled between @BeginDate and @EndDate and CD.FullComputerName IN (SELECT DISTINCT SourceClassInstanceKeyValue AS Computer FROM dbo.[SC_Class_Rel_Computer-Exchange_View] where (@Computer='<ALL>' or SourceClassInstanceKeyValue = @Computer))

  ) temp
 ORDER BY server, countername, time ASC

DECLARE curClientMonServer CURSOR FAST_FORWARD LOCAL FOR
 SELECT distinct(server) FROM #XClientMonTB

OPEN curClientMonServer

FETCH NEXT FROM curClientMonServer INTO @server
WHILE (@@FETCH_STATUS = 0) BEGIN

  SET @counterProcessed = 0
  WHILE (@counterProcessed < 14) BEGIN
        IF (@counterProcessed =  0) SET @countername = 'MSExchangeIS:Client: Latency > 2 sec RPCs'
   ELSE IF (@counterProcessed =  1) SET @countername = 'MSExchangeIS:Client: Latency > 5 sec RPCs'
   ELSE IF (@counterProcessed =  2) SET @countername = 'MSExchangeIS:Client: Latency > 10 sec RPCs'
   ELSE IF (@counterProcessed =  3) SET @countername = 'MSExchangeIS:Client: RPCs attempted'
   ELSE IF (@counterProcessed =  4) SET @countername = 'MSExchangeIS:Client: RPCs Failed'
   ELSE IF (@counterProcessed =  5) SET @countername = 'MSExchangeIS:Client: RPCs Failed: Access Denied'
   ELSE IF (@counterProcessed =  6) SET @countername = 'MSExchangeIS:Client: RPCs Failed: All other errors'
   ELSE IF (@counterProcessed =  7) SET @countername = 'MSExchangeIS:Client: RPCs Failed: Call Cancelled'
   ELSE IF (@counterProcessed =  8) SET @countername = 'MSExchangeIS:Client: RPCs Failed: Call Failed'
   ELSE IF (@counterProcessed =  9) SET @countername = 'MSExchangeIS:Client: RPCs Failed: Server Too Busy'
   ELSE IF (@counterProcessed = 10) SET @countername = 'MSExchangeIS:Client: RPCs Failed: Server Unavailable'
   ELSE IF (@counterProcessed = 11) SET @countername = 'MSExchangeIS:Client: RPCs succeeded'
   ELSE IF (@counterProcessed = 12) SET @countername = 'MSExchangeIS:Client: Total reported latency'
   ELSE IF (@counterProcessed = 13) SET @countername = 'MSExchangeIS:RPC Averaged Latency'
   IF (@countername <> 'MSExchangeIS:RPC Averaged Latency') BEGIN
    SET @total = 0
    SET @total = (SELECT SUM(T1.value)
         FROM
        #XClientMonTB AS T1 LEFT OUTER JOIN #XClientMonTB AS T2
        ON ( T2.orderID = T1.orderID + 1 AND 
          T1.Server = T2.Server AND
          T1.countername = T2.countername)
         WHERE
        T1.Server = @server AND 
        T1.countername = @countername AND
        (T2.value - T1.value < 0 OR T2.value is NULL)
         GROUP BY T1.Server, T1.countername)
    IF (@total is NULL) SET @total = 0

    IF (@countername = 'MSExchangeIS:Client: RPCs attempted') SET @attempted = @total
    ELSE IF (@countername = 'MSExchangeIS:Client: RPCs Failed') SET @failed = @total
    ELSE IF (@countername = 'MSExchangeIS:Client: RPCs succeeded') SET @succeeded = @total
    ELSE IF (@countername = 'MSExchangeIS:Client: Total reported latency') SET @latency_total = @total
    ELSE IF (@countername = 'MSExchangeIS:Client: Latency > 10 sec RPCs') SET @latency_gt10 = @total
    ELSE IF (@countername = 'MSExchangeIS:Client: Latency > 5 sec RPCs') SET @latency_gt5 = @total
    ELSE IF (@countername = 'MSExchangeIS:Client: Latency > 2 sec RPCs') SET @latency_gt2 = @total
    ELSE IF (@countername LIKE 'MSEXCHANGEIS:Client: RPCs Failed:%') INSERT INTO #totaltable VALUES (@server, @countername, @total)

   END -- IF (@countername <> 'MSExchangeIS:RPC Averaged Latency')
   SET @counterProcessed = @counterProcessed + 1

  END -- WHILE.. CounterName Loop

  SET @avg_latency_serverside = (SELECT AVG(value) FROM #XClientMonTB WHERE countername = 'MSExchangeIS:RPC Averaged Latency' AND server = @server)

  INSERT INTO #resulttable
  SELECT
   @server,
   @attempted,
   @failed,
   CASE WHEN @attempted > 0 THEN @succeeded / @attempted ELSE 0 END,
   CASE WHEN @attempted > 0 THEN @latency_total / @attempted ELSE 0 END,
   @avg_latency_serverside,
   CASE WHEN @attempted > 0 THEN @latency_gt2 / @attempted ELSE 0 END,
   CASE WHEN @attempted > 0 THEN @latency_gt5 / @attempted ELSE 0 END,
   CASE WHEN @attempted > 0 THEN @latency_gt10 / @attempted ELSE 0 END,
   SUBSTRING(countername, 35, 500), 
   total
  FROM #totaltable 
  WHERE server = @server
  
FETCH NEXT FROM curClientMonServer INTO @server
END -- WHILE... Server Loop

SELECT  
 Server,
 [Total_Attempted_RPCs] = attempted,
 [Total_Failed_RPCs] = failed,
 [Percentage_Successful_RPCs] = percentSuccess,
 [Average_Client_RPC_Latency_Seconds] = avgClientLatency / 1000,
 [Average_Server_RPC_Latency_Seconds] = avgServerLatency / 1000,
 [Percent_RPCs_Latency_GT_2_Secs] = percentLatencyGT2,
 [Percent_RPCs_Latency_GT_5_Secs] = percentLatencyGT5,
 [Percent_RPCs_Latency_GT_10_Secs] = percentLatencyGT10,
 [RPC_Error_Types] = rpcErrorType, 
 [Number_Of_Failures] = numberOfFailures
FROM #resulttable

CLOSE curClientMonServer
DEALLOCATE curClientMonServer
end
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_GetNullCurrentEndTime 
AS
BEGIN
        /**************************************************
        * Get the rows where the CurrentEndTime is null.  *
        * This will indicate that the (product id +       *
        * config group id) is in the midst of a transform *
        **************************************************/

        DECLARE @saveError INT
        SET @saveError = 0

        SELECT WTI.ConfigurationGroupID
        FROM [dbo].[SMC_Meta_WarehouseTransformInfo] AS WTI WITH (NOLOCK)
        WHERE WTI.CurrentEndTime IS NULL        

         SELECT @saveError = @@ERROR
         IF @saveError <> 0 GOTO QuitWithError

QuitWithError:

         RETURN @saveError

END
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_GroomDatawarehouseTables
AS
BEGIN
        
    DECLARE     @SaveRowCount       INTEGER
    DECLARE     @SaveError          INTEGER
    DECLARE     @ClassID            UNIQUEIDENTIFIER
    DECLARE     @GroomTableName     NVARCHAR(255)
    DECLARE     @GroomColumnName    NVARCHAR(255)
    DECLARE     @GroomDays          INTEGER
    DECLARE     @Command            NVARCHAR(2000)
    DECLARE     @Dependency         NVARCHAR(1000)
    DECLARE     @StartGroomTime     DATETIME
    DECLARE     @EndGroomTime       DATETIME
    DECLARE     @TargetClassName    NVARCHAR(255)
    DECLARE     @TargetFKColumnName NVARCHAR(255)
    
    --
    -- Do not run if data transfer job is already running. 
    -- SP1 fix #50314: When a package is running or when grooming
    -- is running, we will take a lock (sp_getapplock) on the 
    -- resource MOM.Datawarehousing.DTSPackageGenerator.exe for the
    -- session (connection).
    -- We will not allow another instance or the exe and/or
    -- grooming to run simultaneously. 
    -- Earlier, we were taking a lock on the WarehouseTransformInfo
    -- table for the duration of the run (by having a transaction)
    -- and it was preventing the transaction log truncation.
    --
  
    EXECUTE @SaveError = sp_getapplock @Resource = N'MOM.Datawarehousing.DTSPackageGenerator.exe', 
                                       @LockMode = N'Exclusive',
                                       @LockOwner = N'Session'
   
    IF (@SaveError < 0)
    BEGIN
        GOTO Error_AlreadyRunning_Exit
    END
    
    --
    -- Define a temporary table that holds the list of all source and target
    -- class ids from the relationship constraints table.
    --

    CREATE TABLE #tmpRelationshipConstraints
    (
        SourceClassID         UNIQUEIDENTIFIER NOT NULL,
        TargetClassID         UNIQUEIDENTIFIER NOT NULL
    )   
    
    SET @SaveError = @@ERROR
    
    IF (@SaveError <> 0)
    BEGIN
        GOTO Error_Exit
    END

    -- Populate the table
    -- Note: We are incluing all target class ids that are not dw classes
    -- as well. This is because we do not want to groom the dw class which
    -- acts as a source, if there is a non dw target class that depends on it.
    -- It does not matter if the source is a non dw class and the target is a
    -- dw class.
    
    INSERT INTO #tmpRelationshipConstraints
    SELECT RC.SourceClassID AS SourceClassID,
           RC.TargetClassID AS TargetClassID
    FROM dbo.SMC_Meta_RelationshipConstraints AS RC
    WHERE RC.SourceClassID IN (SELECT WCS.ClassID
                               FROM dbo.SMC_Meta_WarehouseClassSchema AS WCS)
    
    
    --
    -- Save the rowcount and error in local variables
    --
    
    SET @SaveRowCount = @@ROWCOUNT
    SET @SaveError = @@ERROR
    
    IF (@SaveError <> 0)
    BEGIN
        GOTO Error_Exit
    END
    
       
    --
    -- Define a temporary table to hold the ordered list of classids (ordered
    -- in the delete order)
    --
    
    CREATE TABLE #tmpDeleteList
    (
        ClassID             UNIQUEIDENTIFIER NOT NULL,
        DeleteOrder         INT IDENTITY(1,1)
    )   
    
    SET @SaveError = @@ERROR
    
    IF (@SaveError <> 0)
    BEGIN
        GOTO Error_Exit
    END
    

    --
    -- Construct an ordered list of warehouse tables to be groomed
    --

    -- Repeat while there are rows in the #tmpRelationshipConstraints table
        
    WHILE @SaveRowCount <> 0
    BEGIN
        
        -- Add to the #tmpDeleteList, class ids that are not sources in a 
        -- relationship
        
        INSERT INTO #tmpDeleteList
        SELECT CS.ClassID AS ClassID
        FROM dbo.SMC_Meta_ClassSchemas AS CS
        INNER JOIN dbo.SMC_Meta_WarehouseClassSchema AS WCS
        ON CS.ClassID = WCS.ClassID
        WHERE CS.ClassID NOT IN (SELECT TMPRC.SourceClassID AS SourceClassID
                                 FROM #tmpRelationshipConstraints AS TMPRC
                                 UNION
                                 SELECT TMPDL.ClassID AS AlreadyAddedClassID 
                                 FROM #tmpDeleteList AS TMPDL)
                                 
        SET @SaveError = @@ERROR
        
        IF (@SaveError <> 0)
        BEGIN
            GOTO Error_Exit
        END
                             
        -- Delete from #tmpRelationshipConstraints all rows where the 
        -- TargetClassID is already in the #tmpDeleteList
        
        DELETE FROM #tmpRelationshipConstraints
        WHERE TargetClassID IN (SELECT TMPDL.ClassID AS ClassID
                                FROM #tmpDeleteList AS TMPDL)
                                      
        SET @SaveError = @@ERROR
        
        IF (@SaveError <> 0)
        BEGIN
            GOTO Error_Exit
        END
        
        -- Save the count of remaining rows in #tmpRelationshipConstraints
        --
        
        SELECT @SaveRowCount = COUNT(*) FROM #tmpRelationshipConstraints
        
    END
    
    -- Add the remaining classes from the class schemas table that have
    -- not been added
    
    INSERT INTO #tmpDeleteList
    SELECT CS.ClassID AS ClassID
    FROM dbo.SMC_Meta_ClassSchemas AS CS
    INNER JOIN dbo.SMC_Meta_WarehouseClassSchema AS WCS
    ON CS.ClassID = WCS.ClassID
    WHERE CS.ClassID NOT IN (SELECT TMPDL.ClassID AS ClassID
                             FROM #tmpDeleteList AS TMPDL)


    SET @SaveError = @@ERROR

    IF (@SaveError <> 0)
    BEGIN
        GOTO Error_Exit
    END
        
    -- From #tmpDeleteList, eliminate the classes that need no grooming
    
    DELETE FROM #tmpDeleteList 
    WHERE ClassID IN (SELECT WCS.ClassID AS ClassID
                      FROM dbo.SMC_Meta_WarehouseClassSchema AS WCS
                      WHERE WCS.MustBeGroomed IS NULL
                      OR    WCS.MustBeGroomed = 0)

    SET @SaveError = @@ERROR

    IF (@SaveError <> 0)
    BEGIN
        GOTO Error_Exit
    END

    
    --
    -- Iterate through the ordered list of tables to be groomed and construct
    -- the delete statement for each of them, and execute the delete.
    --
    
    DECLARE CursorGroomTable CURSOR LOCAL FOR
            SELECT TMPDL.ClassID AS ClassID
            FROM #tmpDeleteList AS TMPDL
            ORDER BY TMPDL.DeleteOrder ASC

    OPEN CursorGroomTable
    FETCH NEXT FROM CursorGroomTable INTO @ClassID
    WHILE @@fetch_status = 0
    BEGIN
        
        -- Reset variables
        
        SET @GroomTableName = N''
        SET @GroomColumnName = N''
        SET @GroomDays = 0
        SET @Command = N''
        SET @Dependency = N''        
        
        -- Get the name of the table to groom
        -- Get the name of the column on which to apply the groom criteria
        -- Get the number of days to groom
        
        SELECT @GroomTableName = CS.ViewName, 
               @GroomColumnName = CP.PropertyName, 
               @GroomDays = WCS.GroomDays
        FROM dbo.SMC_Meta_WarehouseClassProperty AS WCP
        INNER JOIN dbo.SMC_Meta_ClassProperties AS CP
        ON WCP.ClassPropertyID = CP.ClassPropertyID
        INNER JOIN dbo.SMC_Meta_WarehouseClassSchema AS WCS
        ON WCS.ClassID = CP.ClassID
        INNER JOIN dbo.SMC_Meta_ClassSchemas AS CS
        ON CS.ClassID = CP.ClassID
        WHERE WCP.IsGroomColumn = 1
        AND CP.ClassID = @ClassID
        
        SET @SaveRowCount = @@ROWCOUNT
        
        IF (@GroomTableName IS NULL  OR
            @GroomTableName = N''    OR
            @GroomColumnName IS NULL OR
            @GroomColumnName = N''   OR
            @GroomDays IS NULL       OR
            @GroomDays = 0           OR
            @SaveRowCount <> 1)
        BEGIN
            GOTO ConfigError_Exit
        END
        
                
        --
        -- Construct the delete statement that will groom the data
        --
              
        -- Initialize the delete statement with groom criteria
        
        SET @Command =
        N'DELETE FROM '                                 +
        @GroomTableName                                 +
        N'
        WHERE '                                         +
        @GroomColumnName                                +
        N' < DATEADD(DAY, -'                            +
        CAST(@GroomDays AS NVARCHAR(20))                +
        N', GETUTCDATE())'
               
        -- Determine if this table participates as a source of a relationship

        DECLARE CursorDependency CURSOR LOCAL FOR
                SELECT CS.ViewName AS TargetClassName,
                        CP.PropertyName AS TargetFKColumnName
                FROM dbo.SMC_Meta_RelationshipConstraints AS RC
                INNER JOIN dbo.SMC_Meta_ClassSchemas AS CS
                ON RC.TargetClassID = CS.ClassID
                INNER  JOIN dbo.SMC_Meta_ClassProperties AS CP
                ON RC.TargetFK = CP.ClassPropertyID
                WHERE RC.SourceClassID = @ClassID
                                       
        OPEN CursorDependency
        FETCH NEXT FROM CursorDependency INTO @TargetClassName, 
                                              @TargetFKColumnName
        WHILE @@fetch_status = 0
        BEGIN
        
            -- Construct a statement to eliminate dependent rows
            
            IF @Dependency <> N''
            BEGIN
                SET @Dependency = @Dependency         + 
                                  N'
                                  UNION'
            END
                      
            SET @Dependency = @Dependency             +
                              N'SELECT '              +
                              @TargetFKColumnName     +
                              N' FROM '               +
                              @TargetClassName

            -- Fetch the next row
            
            FETCH NEXT FROM CursorDependency INTO @TargetClassName, 
                                                  @TargetFKColumnName
                           
        END
        CLOSE CursorDependency
        DEALLOCATE CursorDependency


        -- Update the delete statement to exclude dependent rows.
        
        IF (@Dependency IS NOT NULL AND
            @Dependency <> N'')
        BEGIN
            SET @Command = @Command                         +
                           N'
                           AND SMC_InstanceID NOT IN (
                           '                                +
                           @Dependency                      +
                           N')'
        END
        
        
        --
        -- Execute the groom statement
        --
        
        -- Note the start time
        
        SET @StartGroomTime = GETUTCDATE()
        
        -- Execute the groom command and save the result
        
        SELECT @Command
        EXECUTE sp_executesql @Command
        SET @SaveError = @@ERROR
        
        -- Note the end time
        
        SET @EndGroomTime = GETUTCDATE()

        -- Check the groom command results
        
        IF (@SaveError <> 0)
        BEGIN
            GOTO GroomError_Exit
        END
        
        
        --
        -- Update the grooming statistics
        --
        
        DECLARE     @tmpID            UNIQUEIDENTIFIER

        SET @tmpID = NULL
                
        SELECT  @tmpID = WGI.ClassID 
        FROM dbo.SMC_Meta_WarehouseGroomingInfo AS WGI
        WHERE WGI.ClassID = @ClassID
        
        IF (@tmpID IS NULL)
        BEGIN
            
            INSERT INTO dbo.SMC_Meta_WarehouseGroomingInfo
            (ClassID,
             StartTime,
             EndTime)
            VALUES
            (@ClassID,
             @StartGroomTime,
             @EndGroomTime)
        
        END
        ELSE
        BEGIN
        
            UPDATE dbo.SMC_Meta_WarehouseGroomingInfo
            SET StartTime = @StartGroomTime,
            EndTime = @EndGroomTime
            WHERE ClassID = @ClassID
            
        END
        
        SET @SaveError = @@ERROR
        IF (@SaveError <> 0)
        BEGIN
            GOTO GroomError_Exit
        END
        
        -- Fetch the next row
        
        FETCH NEXT FROM CursorGroomTable INTO @ClassID
        
    END
    CLOSE CursorGroomTable
    DEALLOCATE CursorGroomTable

    --
    -- Drop all the temp tables
    --
    
    DROP TABLE #tmpRelationshipConstraints
    DROP TABLE #tmpDeleteList

    --
    -- SP1 fix #50314: Reset the TransformOrGroomInProgress switch
    --
    
    SET @SaveError = 0
    GOTO Reset_Exit
    
Error_AlreadyRunning_Exit:
    -- p_GroomDatawarehouseTables will not be executed because it has detected that data is being transferred (DTS) into the warehouse and/or another grooming instance is running.
    RAISERROR (777977210, 16, 1) WITH LOG
    RETURN @SaveError

Error_Exit:    
    -- SQL Server error %u encountered in p_GroomDatawarehouseTables.
    RAISERROR (777977202, 16, 1, @SaveError) WITH LOG
    GOTO Reset_Exit
    
GroomError_Exit:
    -- SQL Server error %u encountered in p_GroomDatawarehouseTables while grooming %s.
    RAISERROR (777977203, 16, 1, @SaveError, @GroomTableName) WITH LOG
    GOTO Reset_Exit
    
ConfigError_Exit:
    -- Configuration error encountered in p_GroomDatawarehouseTables.
    RAISERROR (777977201, 16, 1) WITH LOG
    SET @SaveError = 1
    GOTO Reset_Exit
 
Reset_Exit:   
     EXECUTE sp_releaseapplock @Resource = N'MOM.Datawarehousing.DTSPackageGenerator.exe', 
                               @LockOwner = N'Session'
     RETURN @SaveError
            
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_MOMCapacityPlanningReport
  @BeginDate DATETIME, @EndDate DATETIME 
AS
BEGIN

/* Create 61 minutes Moving Average Data */
SET ARITHABORT OFF
Select  
 ComputerGroup,
 IDENTITY(int,1,1) as SerialNum,
 Server,
 ProcDate  = convert(datetime, convert(varchar,[Time],101)),
 ProcMvgAvg  = Max(ProcMvgAvg),
 ProcThreshold   = 90.00, 
 ProcDaysToThreshold = convert(float,0.0),
 ProcTrend    = convert(float,0.0),
 ProcScore  = convert(float,0.0),
 MemDate   = convert(datetime, convert(varchar,[Time],101)),
 MemMvgAvg  = Max(MemMvgAvg),
 MemThreshold   = 90.00, 
 MemDaysToThreshold = convert(float,0.0),
 MemTrend    = convert(float,0.0),
 MemScore  = convert(float,0.0), 
 DiskADate  = convert(datetime, convert(varchar,[Time],101)),
 DiskAMvgAvg  = Max(DiskAMvgAvg),
 DiskAThreshold   = 90.00, 
 DiskADaysToThreshold = convert(float,0.0),
 DiskATrend    = convert(float,0.0),
 DiskAScore  = convert(float,0.0),
 DiskBDate  = convert(datetime, convert(varchar,[Time],101)),
 DiskBMvgAvg  = Max(DiskBMvgAvg),
 DiskBThreshold   = 0.30, 
 DiskBDaysToThreshold = convert(float,0.0),
 DiskBTrend    = convert(float,0.0),
 DiskBScore  = convert(float,0.0), 
 DiskCDate  = convert(datetime, convert(varchar,[Time],101)),
 DiskCMvgAvg  = Max(DiskCMvgAvg),
 DiskCThreshold   = 4.00, 
 DiskCDaysToThreshold = convert(float,0.0),
 DiskCTrend    = convert(float,0.0),
 DiskCScore  = convert(float,0.0)
INTO #MOM_CapacityPlanningReport_Table
FROM (
      SELECT 
 CRD.Name as ComputerGroup,
 CD.FullComputerName as Server,
 SND1.LocalDateTimeSampled as [Time], 
 SND1.SampleValue, 
 Avg(case when CDD1.ObjectName_PK='Processor'  then SND2.SampleValue end) as ProcMvgAvg,
 Avg(case when CDD1.ObjectName_PK='Memory'     then SND2.SampleValue end) as MemMvgAvg,
 Avg(case when CDD1.ObjectName_PK='PhysicalDisk' and  CDD1.CounterName_PK = '% Disk Time' then SND2.SampleValue end) as DiskAMvgAvg,
 Avg(case when CDD1.ObjectName_PK='PhysicalDisk' and  CDD1.CounterName_PK = 'Avg. Disk sec/Transfer' then SND2.SampleValue end) as DiskBMvgAvg,
 Avg(case when CDD1.ObjectName_PK='PhysicalDisk' and  CDD1.CounterName_PK = 'Avg. Disk Queue Length' then SND2.SampleValue end) as DiskCMvgAvg
      FROM 
 dbo.SC_SampledNumericDataFact_View SND1, 
      dbo.SC_SampledNumericDataFact_View SND2,
 dbo.SC_CounterDetailDimension_View CDD1, 
 dbo.SC_ComputerDimension_View     CD,
 SC_ComputerToComputerRuleFact_View CCRF,
 SC_ComputerRuleDimension_View      CRD
      WHERE 
 SND2.LocalDateTimeSampled      <= SND1.LocalDateTimeSampled
 AND SND2.LocalDateTimeSampled  >= (DateAdd(mi, -61, SND1.LocalDateTimeSampled))
 AND SND1.CounterDetail_FK  = SND2.CounterDetail_FK
 AND SND1.CounterDetail_FK  = CDD1.SMC_InstanceID 
 AND SND1.Computer_FK       = CD.SMC_InstanceID
 AND SND2.Computer_FK       = SND1.Computer_FK
 and CD.SMC_InstanceID   = CCRF.Computer_FK 
 and CCRF.ComputerRule_FK  = CRD.SMC_InstanceID
 AND CDD1.ObjectName_PK in  ('Processor','Memory','PhysicalDisk')
 AND CDD1.CounterName_PK in  ('% Processor Time','% Committed Bytes In Use','Avg. Disk sec/Transfer','Avg. Disk Queue Length','% Disk Time')
  and CDD1.InstanceName_PK in  ('_Total','NULL_INSTANCE')
 and CRD.Name in('Microsoft Operations Manager 2005 Servers',
   'Microsoft Operations Manager 2005 Databases',
   'Microsoft Operations Manager 2005 Report Servers')
 and SND1.LocalDateTimeSampled BETWEEN @BeginDate AND @EndDate
 GROUP BY CRD.Name,CD.FullComputerName,SND1.LocalDateTimeSampled, SND1.SampleValue
) temp
GROUP BY ComputerGroup,Server,convert(datetime, convert(varchar, [Time], 101))
ORDER BY ComputerGroup,Server,convert(datetime, convert(varchar, [Time], 101))

/* Calculate Trend and Score */
SET IDENTITY_INSERT #MOM_CapacityPlanningReport_Table ON
Declare @Computer Varchar(256)
Declare @Server  Varchar(128)
Declare @Time  DateTime
declare @Lambda  float
declare @MaxDate datetime
declare @Mindate datetime
declare @MaxNum  float
declare @MinNum  float
declare @NextSerNum float
declare @NextProcX float
declare @NextMemX float
declare @NextDiskAX float
Declare @xbar  Float
Declare @ybar  Float
declare @m  float
declare @b  float
declare @x  float
declare @sum1  float
declare @sum2  float
declare @MaxX  float
declare @ProcThresDays  Integer
Declare @ProcMvgAvg Float
declare @ProcScore float
declare @ProcTrendDate datetime
Declare @ProcThreshold float
declare @MemScore float
declare @MemTrendDate datetime
Declare @MemThreshold float
Declare @MemMvgAvg Float
declare @MemThresDays  Integer
declare @DiskAScore float
declare @DiskATrendDate datetime
Declare @DiskAThreshold float
Declare @DiskAMvgAvg Float
declare @DiskAThresDays Integer

declare @DiskBScore float
declare @DiskBTrendDate datetime
Declare @DiskBThreshold float
Declare @DiskBMvgAvg Float
declare @DiskBThresDays Integer

declare @DiskCScore float
declare @DiskCTrendDate datetime
Declare @DiskCThreshold float
Declare @DiskCMvgAvg Float
declare @DiskCThresDays Integer

Declare @term1  float
Declare @term2   float

Declare ComputerList cursor for 
 SELECT  Distinct Server FROM #MOM_CapacityPlanningReport_Table
OPEN ComputerList
set @ProcThreshold = 90.00
set @MemThreshold  = 90.00
set @DiskAThreshold= 90.00
set @DiskBThreshold= 0.30
set @DiskCThreshold= 4.00

Fetch Next From ComputerList into @Computer
While @@FETCH_STATUS = 0 
Begin  
 /* Calculate y=mx+b for Processor */
 set @xbar  = (select avg(SerialNum*1.00) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @ybar  = (select avg(ProcMvgAvg) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @sum1  = (select sum((SerialNum*1.00 - @xbar)*(ProcMvgAvg - @ybar)) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @sum2       = (select sum((SerialNum*1.00 - @xbar)*(SerialNum*1.00 - @xbar)) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 
 if @sum2 > 0 set @m = @sum1/@sum2
 else
  set @m = 0
 set @b = @ybar-@m*@xbar
 /* Calculate  x = (Threshold - b)/m  */
 if @m = 0 set @x = 99999 /* Set to a large number (infinity) */
  else  set @x = (@ProcThreshold-@b)/@m 
 /* Calculate  T and Lamda To find Score of each machine */
 set @MaxX      = (select max(SerialNum*1.00) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @MaxDate   = (select max(ProcDate) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @Mindate   = (select min(ProcDate) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @MaxNum    = (select max(SerialNum) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @MinNum    = (select min(SerialNum) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @NextSerNum = @MaxX + 1
 set @NextProcX = @xbar
 Set @ProcThresDays = @x-@MaxX
 set @ProcTrendDate = @MaxDate+@ProcThresDays
 set @Lambda     = (@ProcThreshold-@ybar)/@ProcThreshold
 set @term1  = 1.0000-(1.0000/power(2.0000,10.0000*@Lambda))
 /* calculate Term2 of the Formula */
 if (@ProcThresDays < 0) or (@ProcThresDays > 90)
 begin
  set @term2 = 1.0000
  set @ProcTrendDate = @MaxDate+1
 end
  else  
 begin
   set @term2  = (1.0000-(1.0000/power(2.0000, @ProcThresDays/30.0000)))
  set @ProcTrendDate = @MaxDate+@ProcThresDays
 end 
 set @ProcScore  = @term1*@term2*100 
 update #MOM_CapacityPlanningReport_Table set ProcTrend=@m*SerialNum+@b, ProcScore=@ProcScore, ProcDaysToThreshold=@ProcThresDays where Server = @Computer
 /* Calculate y=mx+b for Memory */
 set @xbar  = (select avg(SerialNum*1.00) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @ybar  = (select avg(MemMvgAvg) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @sum1  = (select sum((SerialNum*1.00 - @xbar)*(MemMvgAvg - @ybar)) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @sum2       = (select sum((SerialNum*1.00 - @xbar)*(SerialNum*1.00 - @xbar)) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 
 if @sum2 > 0 set @m = @sum1/@sum2
 else
  set @m = 0
 set @b = @ybar-@m*@xbar
 /* Calculate  x = (Threshold - b)/m  */
 if @m = 0 set @x = 99999
 else
  set @x = (@MemThreshold-@b)/@m 
 /* Calculate  T and Lamda To find Score of each machine */
 set @MaxDate    = (select max(MemDate) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 Set @MemThresDays = @x-@MaxX
 set @Lambda     = (@MemThreshold-@ybar)/@MemThreshold
 set @term1  = 1.0000-(1.0000/power(2.0000,10.0000*@Lambda))
 if  (@MemThresDays < 0) or (@MemThresDays > 90)
   begin 
    set @MemTrendDate = @MaxDate+1 
  set @term2    = 1.0000 
   end
  else 
   begin
    set @MemTrendDate = @MaxDate+@MemThresDays
  set @term2  = (1.0000-(1.0000/power(2.0000, @MemThresDays/30.0000)))
   end
  set @MemScore  = @term1*@term2*100 
  update #MOM_CapacityPlanningReport_Table set MemTrend=@m*SerialNum+@b,MemScore=@MemScore,MemDaysToThreshold=@MemThresDays where Server = @Computer

 /* Calculate y=mx+b for DiskA - PhysiacalDisk - %Disk Time and _Total */
 set @xbar  = (select avg(SerialNum*1.00) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @ybar  = (select avg(DiskAMvgAvg) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @sum1  = (select sum((SerialNum*1.00 - @xbar)*(DiskAMvgAvg - @ybar)) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @sum2       = (select sum((SerialNum*1.00 - @xbar)*(SerialNum*1.00 - @xbar)) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 
 if @sum2 > 0 set @m = @sum1/@sum2
 else
  set @m = 0
 set @b = @ybar-@m*@xbar
 /* Calculate  x = (Threshold - b)/m  */
 if @m = 0 set @x = 99999
 else
  set @x = (@DiskAThreshold-@b)/@m 
 /* Calculate  T and Lamda To find Score of each machine */
 set @MaxDate    = (select max(DiskADate) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 Set @DiskAThresDays = @x-@MaxX
 set @Lambda     = (@DiskAThreshold-@ybar)/@DiskAThreshold
 set @term1  = 1.0000-(1.0000/power(2.0000,10.0000*@Lambda))
 if  (@DiskAThresDays < 0) or (@DiskAThresDays > 90)
   begin 
    set @DiskATrendDate = @MaxDate+1 
  set @term2    = 1.0000 
   end
  else 
   begin
    set @DiskATrendDate = @MaxDate+@DiskAThresDays
  set @term2  = (1.0000-(1.0000/power(2.0000, @DiskAThresDays/30.0000)))
   end
  set @DiskAScore  = @term1*@term2*100 
  update #MOM_CapacityPlanningReport_Table set DiskATrend=@m*SerialNum+@b, DiskAScore=@DiskAScore,DiskADaysToThreshold=@DiskAThresDays   where Server = @Computer

 /* Calculate y=mx+b for DiskB - PhysiacalDisk - Avg. Disk sec/Transfer and _Total */
 set @xbar  = (select avg(SerialNum*1.00) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @ybar  = (select avg(DiskBMvgAvg) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @sum1  = (select sum((SerialNum*1.00 - @xbar)*(DiskBMvgAvg - @ybar)) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @sum2       = (select sum((SerialNum*1.00 - @xbar)*(SerialNum*1.00 - @xbar)) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 
 if @sum2 > 0 set @m = @sum1/@sum2
 else
  set @m = 0
 set @b = @ybar-@m*@xbar
 /* Calculate  x = (Threshold - b)/m  */
 if @m = 0 set @x = 99999
 else
  set @x = (@DiskBThreshold-@b)/@m 
 /* Calculate  T and Lamda To find Score of each machine */
 set @MaxDate    = (select max(DiskADate) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 Set @DiskBThresDays = @x-@MaxX
 set @Lambda     = (@DiskBThreshold-@ybar)/@DiskBThreshold
 set @term1  = 1.0000-(1.0000/power(2.0000,10.0000*@Lambda))
 if  (@DiskBThresDays < 0) or (@DiskBThresDays > 90)
   begin 
    set @DiskBTrendDate = @MaxDate+1 
  set @term2    = 1.0000 
   end
  else 
   begin
    set @DiskBTrendDate = @MaxDate+@DiskBThresDays
  set @term2  = (1.0000-(1.0000/power(2.0000, @DiskBThresDays/30.0000)))
   end
  set @DiskBScore  = @term1*@term2*100 
  update #MOM_CapacityPlanningReport_Table set DiskBTrend=@m*SerialNum+@b, DiskBScore=@DiskBScore,DiskBDaysToThreshold=@DiskBThresDays   where Server = @Computer


 /* Calculate y=mx+b for DiskC - PhysiacalDisk - Avg. Disk Queue Length and _Total */
 set @xbar  = (select avg(SerialNum*1.00) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @ybar  = (select avg(DiskCMvgAvg) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @sum1  = (select sum((SerialNum*1.00 - @xbar)*(DiskCMvgAvg - @ybar)) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @sum2       = (select sum((SerialNum*1.00 - @xbar)*(SerialNum*1.00 - @xbar)) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 
 if @sum2 > 0 set @m = @sum1/@sum2
 else
  set @m = 0
 set @b = @ybar-@m*@xbar
 /* Calculate  x = (Threshold - b)/m  */
 if @m = 0 set @x = 99999
 else
  set @x = (@DiskCThreshold-@b)/@m 
 /* Calculate  T and Lamda To find Score of each machine */
 set @MaxDate    = (select max(DiskCDate) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 Set @DiskCThresDays = @x-@MaxX
 set @Lambda     = (@DiskCThreshold-@ybar)/@DiskCThreshold
 set @term1  = 1.0000-(1.0000/power(2.0000,10.0000*@Lambda))
 if  (@DiskCThresDays < 0) or (@DiskCThresDays > 90)
   begin 
    set @DiskCTrendDate = @MaxDate+1 
  set @term2    = 1.0000 
   end
  else 
   begin
    set @DiskCTrendDate = @MaxDate+@DiskCThresDays
  set @term2  = (1.0000-(1.0000/power(2.0000, @DiskCThresDays/30.0000)))
   end
  set @DiskCScore  = @term1*@term2*100 
  update #MOM_CapacityPlanningReport_Table set DiskCTrend=@m*SerialNum+@b, DiskCScore=@DiskCScore,DiskCDaysToThreshold=@DiskCThresDays   where Server = @Computer
 Fetch Next From ComputerList into @Computer
End

Select ServerRole,ComputerGroup,Server,min(ProcScore) as ProcScore,min(MemScore) as MemScore,Min(DiskScore) as DiskScore
from(
select 
 substring(ComputerGroup,35,50) as ServerRole,
 ComputerGroup,  
 Server, 
 Avg(ProcScore) as ProcScore , 
 Avg(MemScore) as MemScore,
 Avg(DiskAScore) as  DiskScore
from 
 #MOM_CapacityPlanningReport_Table
group by 
 substring(ComputerGroup,35,50),ComputerGroup,Server
union
select 
 substring(ComputerGroup,35,50) as ServerRole,
 ComputerGroup,  
 Server, 
 Avg(ProcScore) as ProcScore , 
 Avg(MemScore) as MemScore,
 Avg(DiskBScore) as  DiskScore
from 
 #MOM_CapacityPlanningReport_Table
group by 
 substring(ComputerGroup,35,50),ComputerGroup,Server
union
select 
 substring(ComputerGroup,35,50) as ServerRole,
 ComputerGroup,  
 Server, 
 Avg(ProcScore) as ProcScore , 
 Avg(MemScore) as MemScore,
 Avg(DiskCScore) as  DiskScore
from 
 #MOM_CapacityPlanningReport_Table
group by 
 substring(ComputerGroup,35,50),ComputerGroup,Server)temp
group by ServerRole,ComputerGroup,Server

CLOSE ComputerList
DEALLOCATE ComputerList

END
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_MOMCapacityPlanningReportDetail
  @BeginDate DATETIME, @EndDate DATETIME, @Server nvarchar(256), @CompGroup nvarchar(256)
AS
BEGIN

/* Create 61 minutes Moving Average Data */
SET ARITHABORT OFF
Select  
 ComputerGroup,
 IDENTITY(int,1,1) as SerialNum,
 Server,
 ProcDate  = convert(datetime, convert(varchar,[Time],101)),
 ProcMvgAvg  = Max(ProcMvgAvg),
 ProcThreshold   = 90.00, 
 ProcDaysToThreshold = convert(float,0.0),
 ProcTrend    = convert(float,0.0),
 ProcScore  = convert(float,0.0),
 MemDate   = convert(datetime, convert(varchar,[Time],101)),
 MemMvgAvg  = Max(MemMvgAvg),
 MemThreshold   = 90.00, 
 MemDaysToThreshold = convert(float,0.0),
 MemTrend    = convert(float,0.0),
 MemScore  = convert(float,0.0), 
 DiskADate  = convert(datetime, convert(varchar,[Time],101)),
 DiskAMvgAvg  = Max(DiskAMvgAvg),
 DiskAThreshold   = 90.00, 
 DiskADaysToThreshold = convert(float,0.0),
 DiskATrend    = convert(float,0.0),
 DiskAScore  = convert(float,0.0),
 DiskBDate  = convert(datetime, convert(varchar,[Time],101)),
 DiskBMvgAvg  = Max(DiskBMvgAvg),
 DiskBThreshold   = 0.30, 
 DiskBDaysToThreshold = convert(float,0.0),
 DiskBTrend    = convert(float,0.0),
 DiskBScore  = convert(float,0.0), 
 DiskCDate  = convert(datetime, convert(varchar,[Time],101)),
 DiskCMvgAvg  = Max(DiskCMvgAvg),
 DiskCThreshold   = 4.00, 
 DiskCDaysToThreshold = convert(float,0.0),
 DiskCTrend    = convert(float,0.0),
 DiskCScore  = convert(float,0.0)
INTO #MOM_CapacityPlanningReport_Table
FROM (
      SELECT 
 CRD.Name as ComputerGroup,
 CD.FullComputerName as Server,
 SND1.LocalDateTimeSampled as [Time], 
 SND1.SampleValue, 
 Avg(case when CDD1.ObjectName_PK='Processor'  then SND2.SampleValue end) as ProcMvgAvg,
 Avg(case when CDD1.ObjectName_PK='Memory'     then SND2.SampleValue end) as MemMvgAvg,
 Avg(case when CDD1.ObjectName_PK='PhysicalDisk' and  CDD1.CounterName_PK = '% Disk Time' then SND2.SampleValue end) as DiskAMvgAvg,
 Avg(case when CDD1.ObjectName_PK='PhysicalDisk' and  CDD1.CounterName_PK = 'Avg. Disk sec/Transfer' then SND2.SampleValue end) as DiskBMvgAvg,
 Avg(case when CDD1.ObjectName_PK='PhysicalDisk' and  CDD1.CounterName_PK = 'Avg. Disk Queue Length' then SND2.SampleValue end) as DiskCMvgAvg
      FROM 
 dbo.SC_SampledNumericDataFact_View SND1, 
      dbo.SC_SampledNumericDataFact_View SND2,
 dbo.SC_CounterDetailDimension_View CDD1, 
 dbo.SC_ComputerDimension_View     CD,
 SC_ComputerToComputerRuleFact_View CCRF,
 SC_ComputerRuleDimension_View      CRD
      WHERE 
 SND2.LocalDateTimeSampled      <= SND1.LocalDateTimeSampled
 AND SND2.LocalDateTimeSampled  >= (DateAdd(mi, -61, SND1.LocalDateTimeSampled))
 AND SND1.CounterDetail_FK  = SND2.CounterDetail_FK
 AND SND1.CounterDetail_FK  = CDD1.SMC_InstanceID 
 AND SND1.Computer_FK       = CD.SMC_InstanceID
 AND SND2.Computer_FK       = SND1.Computer_FK
 and CD.SMC_InstanceID   = CCRF.Computer_FK 
 and CCRF.ComputerRule_FK  = CRD.SMC_InstanceID
 AND CDD1.ObjectName_PK in  ('Processor','Memory','PhysicalDisk')
 AND CDD1.CounterName_PK in  ('% Processor Time','% Committed Bytes In Use','Avg. Disk sec/Transfer','Avg. Disk Queue Length','% Disk Time')
  and CDD1.InstanceName_PK in  ('_Total','NULL_INSTANCE')
 and CRD.Name = @CompGroup and CD.FullComputerName = @Server 
 and SND1.LocalDateTimeSampled BETWEEN @BeginDate AND @EndDate
 GROUP BY CRD.Name,CD.FullComputerName,SND1.LocalDateTimeSampled, SND1.SampleValue
) temp
GROUP BY ComputerGroup,Server,convert(datetime, convert(varchar, [Time], 101))
ORDER BY ComputerGroup,Server,convert(datetime, convert(varchar, [Time], 101))

/* Calculate Trend and Score */
SET IDENTITY_INSERT #MOM_CapacityPlanningReport_Table ON
Declare @Computer Varchar(256)
--Declare @Server  Varchar(128)
Declare @Time  DateTime
declare @Lambda  float
declare @MaxDate datetime
declare @Mindate datetime
declare @MaxNum  float
declare @MinNum  float
declare @NextSerNum float
declare @NextProcX float
declare @NextMemX float
declare @NextDiskAX float
Declare @xbar  Float
Declare @ybar  Float
declare @m  float
declare @b  float
declare @x  float
declare @sum1  float
declare @sum2  float
declare @MaxX  float
declare @ProcThresDays  Integer
Declare @ProcMvgAvg Float
declare @ProcScore float
declare @ProcTrendDate datetime
Declare @ProcThreshold float
declare @MemScore float
declare @MemTrendDate datetime
Declare @MemThreshold float
Declare @MemMvgAvg Float
declare @MemThresDays  Integer
declare @DiskAScore float
declare @DiskATrendDate datetime
Declare @DiskAThreshold float
Declare @DiskAMvgAvg Float
declare @DiskAThresDays Integer

declare @DiskBScore float
declare @DiskBTrendDate datetime
Declare @DiskBThreshold float
Declare @DiskBMvgAvg Float
declare @DiskBThresDays Integer

declare @DiskCScore float
declare @DiskCTrendDate datetime
Declare @DiskCThreshold float
Declare @DiskCMvgAvg Float
declare @DiskCThresDays Integer

Declare @term1  float
Declare @term2   float

Declare ComputerList cursor for 
 SELECT  Distinct Server FROM #MOM_CapacityPlanningReport_Table
OPEN ComputerList
set @ProcThreshold = 90.00
set @MemThreshold  = 90.00
set @DiskAThreshold= 90.00
set @DiskBThreshold= 0.30
set @DiskCThreshold= 4.00

Fetch Next From ComputerList into @Computer
While @@FETCH_STATUS = 0 
Begin  
 /* Calculate y=mx+b for Processor */
 set @xbar  = (select avg(SerialNum*1.00) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @ybar  = (select avg(ProcMvgAvg) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @sum1  = (select sum((SerialNum*1.00 - @xbar)*(ProcMvgAvg - @ybar)) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @sum2       = (select sum((SerialNum*1.00 - @xbar)*(SerialNum*1.00 - @xbar)) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 
 if @sum2 > 0 set @m = @sum1/@sum2
 else
  set @m = 0
 set @b = @ybar-@m*@xbar
 /* Calculate  x = (Threshold - b)/m  */
 if @m = 0 set @x = 99999 /* Set to a large number (infinity) */
  else  set @x = (@ProcThreshold-@b)/@m 
 /* Calculate  T and Lamda To find Score of each machine */
 set @MaxX      = (select max(SerialNum*1.00) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @MaxDate   = (select max(ProcDate) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @Mindate   = (select min(ProcDate) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @MaxNum    = (select max(SerialNum) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @MinNum    = (select min(SerialNum) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @NextSerNum = @MaxX + 1
 set @NextProcX = @xbar
 Set @ProcThresDays = @x-@MaxX
 set @ProcTrendDate = @MaxDate+@ProcThresDays
 set @Lambda     = (@ProcThreshold-@ybar)/@ProcThreshold
 set @term1  = 1.0000-(1.0000/power(2.0000,10.0000*@Lambda))
 /* calculate Term2 of the Formula */
 if (@ProcThresDays < 0) or (@ProcThresDays > 90)
 begin
  set @term2 = 1.0000
  set @ProcTrendDate = @MaxDate+1
 end
  else  
 begin
   set @term2  = (1.0000-(1.0000/power(2.0000, @ProcThresDays/30.0000)))
  set @ProcTrendDate = @MaxDate+@ProcThresDays
 end 
 set @ProcScore  = @term1*@term2*100 
 update #MOM_CapacityPlanningReport_Table set ProcTrend=@m*SerialNum+@b, ProcScore=@ProcScore, ProcDaysToThreshold=@ProcThresDays where Server = @Computer
 /* Calculate y=mx+b for Memory */
 set @xbar  = (select avg(SerialNum*1.00) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @ybar  = (select avg(MemMvgAvg) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @sum1  = (select sum((SerialNum*1.00 - @xbar)*(MemMvgAvg - @ybar)) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @sum2       = (select sum((SerialNum*1.00 - @xbar)*(SerialNum*1.00 - @xbar)) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 
 if @sum2 > 0 set @m = @sum1/@sum2
 else
  set @m = 0
 set @b = @ybar-@m*@xbar
 /* Calculate  x = (Threshold - b)/m  */
 if @m = 0 set @x = 99999
 else
  set @x = (@MemThreshold-@b)/@m 
 /* Calculate  T and Lamda To find Score of each machine */
 set @MaxDate    = (select max(MemDate) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 Set @MemThresDays = @x-@MaxX
 set @Lambda     = (@MemThreshold-@ybar)/@MemThreshold
 set @term1  = 1.0000-(1.0000/power(2.0000,10.0000*@Lambda))
 if  (@MemThresDays < 0) or (@MemThresDays > 90)
   begin 
    set @MemTrendDate = @MaxDate+1 
  set @term2    = 1.0000 
   end
  else 
   begin
    set @MemTrendDate = @MaxDate+@MemThresDays
  set @term2  = (1.0000-(1.0000/power(2.0000, @MemThresDays/30.0000)))
   end
  set @MemScore  = @term1*@term2*100 
  update #MOM_CapacityPlanningReport_Table set MemTrend=@m*SerialNum+@b,MemScore=@MemScore,MemDaysToThreshold=@MemThresDays where Server = @Computer

 /* Calculate y=mx+b for DiskA - PhysiacalDisk - %Disk Time and _Total */
 set @xbar  = (select avg(SerialNum*1.00) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @ybar  = (select avg(DiskAMvgAvg) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @sum1  = (select sum((SerialNum*1.00 - @xbar)*(DiskAMvgAvg - @ybar)) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @sum2       = (select sum((SerialNum*1.00 - @xbar)*(SerialNum*1.00 - @xbar)) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 
 if @sum2 > 0 set @m = @sum1/@sum2
 else
  set @m = 0
 set @b = @ybar-@m*@xbar
 /* Calculate  x = (Threshold - b)/m  */
 if @m = 0 set @x = 99999
 else
  set @x = (@DiskAThreshold-@b)/@m 
 /* Calculate  T and Lamda To find Score of each machine */
 set @MaxDate    = (select max(DiskADate) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 Set @DiskAThresDays = @x-@MaxX
 set @Lambda     = (@DiskAThreshold-@ybar)/@DiskAThreshold
 set @term1  = 1.0000-(1.0000/power(2.0000,10.0000*@Lambda))
 if  (@DiskAThresDays < 0) or (@DiskAThresDays > 90)
   begin 
    set @DiskATrendDate = @MaxDate+1 
  set @term2    = 1.0000 
   end
  else 
   begin
    set @DiskATrendDate = @MaxDate+@DiskAThresDays
  set @term2  = (1.0000-(1.0000/power(2.0000, @DiskAThresDays/30.0000)))
   end
  set @DiskAScore  = @term1*@term2*100 
  update #MOM_CapacityPlanningReport_Table set DiskATrend=@m*SerialNum+@b, DiskAScore=@DiskAScore,DiskADaysToThreshold=@DiskAThresDays   where Server = @Computer

 /* Calculate y=mx+b for DiskB - PhysiacalDisk - Avg. Disk sec/Transfer and _Total */
 set @xbar  = (select avg(SerialNum*1.00) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @ybar  = (select avg(DiskBMvgAvg) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @sum1  = (select sum((SerialNum*1.00 - @xbar)*(DiskBMvgAvg - @ybar)) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @sum2       = (select sum((SerialNum*1.00 - @xbar)*(SerialNum*1.00 - @xbar)) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 
 if @sum2 > 0 set @m = @sum1/@sum2
 else
  set @m = 0
 set @b = @ybar-@m*@xbar
 /* Calculate  x = (Threshold - b)/m  */
 if @m = 0 set @x = 99999
 else
  set @x = (@DiskBThreshold-@b)/@m 
 /* Calculate  T and Lamda To find Score of each machine */
 set @MaxDate    = (select max(DiskADate) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 Set @DiskBThresDays = @x-@MaxX
 set @Lambda     = (@DiskBThreshold-@ybar)/@DiskBThreshold
 set @term1  = 1.0000-(1.0000/power(2.0000,10.0000*@Lambda))
 if  (@DiskBThresDays < 0) or (@DiskBThresDays > 90)
   begin 
    set @DiskBTrendDate = @MaxDate+1 
  set @term2    = 1.0000 
   end
  else 
   begin
    set @DiskBTrendDate = @MaxDate+@DiskBThresDays
  set @term2  = (1.0000-(1.0000/power(2.0000, @DiskBThresDays/30.0000)))
   end
  set @DiskBScore  = @term1*@term2*100 
  update #MOM_CapacityPlanningReport_Table set DiskBTrend=@m*SerialNum+@b, DiskBScore=@DiskBScore,DiskBDaysToThreshold=@DiskBThresDays   where Server = @Computer


 /* Calculate y=mx+b for DiskC - PhysiacalDisk - Avg. Disk Queue Length and _Total */
 set @xbar  = (select avg(SerialNum*1.00) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @ybar  = (select avg(DiskCMvgAvg) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @sum1  = (select sum((SerialNum*1.00 - @xbar)*(DiskCMvgAvg - @ybar)) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 set @sum2       = (select sum((SerialNum*1.00 - @xbar)*(SerialNum*1.00 - @xbar)) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 
 if @sum2 > 0 set @m = @sum1/@sum2
 else
  set @m = 0
 set @b = @ybar-@m*@xbar
 /* Calculate  x = (Threshold - b)/m  */
 if @m = 0 set @x = 99999
 else
  set @x = (@DiskCThreshold-@b)/@m 
 /* Calculate  T and Lamda To find Score of each machine */
 set @MaxDate    = (select max(DiskCDate) from #MOM_CapacityPlanningReport_Table where Server = @Computer)
 Set @DiskCThresDays = @x-@MaxX
 set @Lambda     = (@DiskCThreshold-@ybar)/@DiskCThreshold
 set @term1  = 1.0000-(1.0000/power(2.0000,10.0000*@Lambda))
 if  (@DiskCThresDays < 0) or (@DiskCThresDays > 90)
   begin 
    set @DiskCTrendDate = @MaxDate+1 
  set @term2    = 1.0000 
   end
  else 
   begin
    set @DiskCTrendDate = @MaxDate+@DiskCThresDays
  set @term2  = (1.0000-(1.0000/power(2.0000, @DiskCThresDays/30.0000)))
   end
  set @DiskCScore  = @term1*@term2*100 
  update #MOM_CapacityPlanningReport_Table set DiskCTrend=@m*SerialNum+@b, DiskCScore=@DiskCScore,DiskCDaysToThreshold=@DiskCThresDays   where Server = @Computer
 Fetch Next From ComputerList into @Computer
End

Select * from #MOM_CapacityPlanningReport_Table order by ProcDate
CLOSE ComputerList
DEALLOCATE ComputerList

END
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_MOMLicensesInUseReport
AS
BEGIN

CREATE TABLE #MOMLicensesInUseReport (
 Server   nvarchar(256),
 MOMAgents integer,
 MOMVSAgents integer,
 MOMCSAgents integer
)

Declare @MOMVSAgents integer
Declare @MOMAgents integer
Declare @MOMCSAgents integer

set @MOMVSAgents  = 0
set @MOMAgents  = 0
set @MOMCSAgents = 0


/* count all MOM agents */
set @MOMAgents = (select count(*) from dbo.SC_Class_Computer_View where [Management Mode] <> 'Unmanaged')

/* count all Virtual Server agents if available */
IF  EXISTS (select * from dbo.sysobjects where id = object_id(N'dbo.[SC_Class_Virtual Server_View]') )
 set @MOMVSAgents = (Select count(*) from [SC_Class_Virtual Server_View])

/* count all Virtual Cluster Server agents if available */
IF  EXISTS (select * from dbo.sysobjects where id = object_id(N'dbo.[SC_Class_Rel_Virtual Server-Physical Server_View]') )
 set @MOMCSAgents = (Select  count(distinct SourceClassInstanceKeyValue ) from dbo.[SC_Class_Rel_Virtual Server-Physical Server_View])

/* Insert them to this table for counting licenses in the Operations Manager 2005 Licenses in Use report */
INSERT INTO #MOMLicensesInUseReport
   SELECT 
 distinct CD.FullComputerName,@MOMAgents,@MOMVSAgents,@MOMCSAgents
   FROM         
 SC_ComputerDimension_view CD INNER JOIN
        SC_ComputerToComputerRuleFact_view CCRF ON CD.SMC_InstanceID = CCRF.Computer_Fk INNER JOIN
        SC_ComputerRuleDimension_view CRD ON CCRF.ComputerRule_FK = CRD.SMC_InstanceID
   WHERE      
 CRD.Name  like 'Microsoft Operations Manager 2005 Servers'

select * from #MOMLicensesInUseReport

END
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_PopulateDateDimension @startDate DATETIME = NULL, @endDate DATETIME = NULL
AS
BEGIN
     DECLARE @date DATETIME
        DECLARE @saveError INT
        DECLARE @setIdentity BIT

        SET @saveError = 0
        SET @setIdentity = 0

        /**********************************************
     * Create a date that represents N/A           *
        **********************************************/

        SET @date = '1/1/1800 12:00 AM' 

        IF NOT EXISTS (SELECT * FROM dbo.SC_DateDimension_View
                       WHERE DateYear_PK = 1800
                       AND DateMonth_PK = 1
                       AND DateDay_PK = 1)
        BEGIN
          
            SET IDENTITY_INSERT dbo.SC_DateDimension_Table ON

            SELECT @saveError = @@ERROR
            IF @saveError <> 0 GOTO QuitWithError

            SET @setIdentity = 1
     
         INSERT INTO dbo.SC_DateDimension_View
         (SMC_InstanceID,
             [Date], 
          DateYear_PK,
          DateMonth_PK,
          DateDay_PK)
         VALUES
         (1,
             @date,
          DATEPART(year, @date),
          DATEPART(month, @date),
          DATEPART(day, @date)
            )     
    
             SELECT @saveError = @@ERROR
             IF @saveError <> 0 GOTO QuitWithError

             SET IDENTITY_INSERT dbo.SC_DateDimension_Table OFF

             SELECT @saveError = @@ERROR
             IF @saveError <> 0 GOTO QuitWithError

             SET @setIdentity = 0
          
          END  
          
        /**********************************************
        * Populate the date dimension                 *
        ***********************************************/
        
     IF @startDate IS NULL
         SET @startDate = '1/1/1998 12:00 AM' 

        IF @endDate IS NULL
         SET @endDate = '1/1/2010 12:00 AM'

     SET @date = @startDate
     WHILE @date <= @endDate
       BEGIN

        INSERT INTO dbo.SC_DateDimension_View
        ([Date], 
         DateYear_PK,
         DateMonth_PK,
         DateDay_PK)
        VALUES
        (@date,
         DATEPART(year, @date),
         DATEPART(month, @date),
         DATEPART(day, @date)
           )

            SELECT @saveError = @@ERROR
            IF @saveError <> 0 GOTO QuitWithError
     
         SELECT @date = @date + 1
     END

QuitWithError:

         IF @setIdentity = 1
         BEGIN
             SET IDENTITY_INSERT dbo.SC_DateDimension_Table OFF
         END

         RETURN @saveError

END
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_PopulateOperationalDataDimension 
AS
BEGIN
        DECLARE @saveError INT
        DECLARE @setIdentity BIT

        SET @saveError = 0
        SET @setIdentity = 0

        SET IDENTITY_INSERT dbo.SC_OperationalDataDimension_Table ON

        SELECT @saveError = @@ERROR
        IF @saveError <> 0 GOTO QuitWithError

        SET @setIdentity = 1

        /***********************************************
     * Delete any existing rows. 
        * NOTE: If there are any tables referencing this
        * (currently there are none) then the following
        * rules should be followed.
        * 1. If you delete rows from this table, then
        *    you will have to fix up the references.
        * 2. If you change any SMC_InstanceIDs then you
        *    you will have to fix up the references.
        ************************************************/

        DELETE FROM dbo.SC_OperationalDataDimension_View

        SELECT @saveError = @@ERROR
        IF @saveError <> 0 GOTO QuitWithError

        /***********************************************
     * Create an operational data that represents N/A
        ************************************************/
     
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (1, '00000000-0000-0000-0000-000000000000',  0)   

        /***********************************************
     * Populate the rest of the operational data
        ************************************************/

     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (2, '65AB6B45-7DC4-44FA-A311-57D987E0BFCC', 2)
     
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (3, '7FC0553B-B029-4E83-B20A-74ED05DBD996', 2)
     
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (4, '7012732D-7BAE-4A56-8FC5-4EAB3F6FD0E8', 2)
     
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (5, '1B58ED50-BA99-4F4F-AE89-1C50438D7123', 2)
     
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES 
     (6, '0983E76F-461C-414B-B72C-262DF9B764E8', 2)
     
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (7, 'F8FF1CC9-6A8A-4670-9E5E-CD89D2A5E58E', 2)
     
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (8, '4E267FCC-1B15-4A19-80F9-37ADE94E8A12', 2)
     
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (9, '8A3957DE-9AEF-47A5-8A6A-14B238EE20AD', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (10, '06D2E20B-ECF0-4887-B06A-A07C6238D5CC', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (11, '7250D1B2-6C7C-467F-90BB-09ABCE52B33B', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (12, '4BBB6CBA-33AB-4EA5-99EB-A7FE91409662', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (13, '2D76CF14-4A32-464D-8994-D72ED6967F12', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (14, 'ED0D16E8-CBCF-46B5-8294-D8013E35A7C4', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (15, 'ED03138B-5616-4FD1-9DD0-7FDE59680D03', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (16, '03B1DBA6-1707-4CBD-812C-35315A2B5A18', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (17, '5FAF29BE-80BB-4FF6-BC1B-8B64C6B4D305', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (18, 'FCCFC4AE-16C6-4EFE-8097-07A911DD1805', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (19, 'ADD4F855-9C83-44CC-90ED-226876AE2F4C', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (20, '0ED4EB05-BA1F-4547-B997-297DA7404806', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (21, '9E42BD92-71EB-44E0-B2A9-479FCF33F5D4', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (22, '2A15F123-4AA8-4851-B3C2-64A8F0DBFD22', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (23, '313F5F73-B5D8-4C30-B714-A67A2149ADD9', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (24, 'E80AF363-C218-4C56-9063-66D56FFC6641', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (25, 'DDA8E84C-44A1-47EB-892C-8A4925EA576D', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (26, 'ED81808A-818B-11D3-880B-0090270D4908', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (27, 'B5FC297C-4AC4-4C65-9997-2F9AA7C60877', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (28, '01DD9AA2-0941-488F-98DD-FEA6B5BEE940', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (29, '376949DD-F535-4E92-BCB0-67808A734EE0', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (30, 'CCB0A577-7B7D-49CE-8EF1-68368DA94C79', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (31, 'D45D1295-21EF-4522-B69D-0B2061647A7B', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (32, '3CF0EC68-08BE-4429-B31B-F06EFBDF4B60', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (33, 'F5923CC0-D6FA-4E39-9951-0AD5B1E3ABFD', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (34, '9FDDDB23-998F-4AF8-94D3-9A79289E2C3E', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (35, 'C3093133-5DFF-4143-84B6-9CEB26164C22', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (36, '10D7FE7F-5960-4CEE-B93C-716BA9FCD0EC', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (37, '356CD745-75A6-401D-AF39-9CBCC5F6D2CF', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (38, '572548DF-DC00-4E47-A33A-202EF9ED7022', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (39, 'D9F4CF15-D8AE-48CC-885E-FB6EF6393B6B', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (40, '11FFAC32-A158-4B0F-8952-CF97D40108F5', 2)
     
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (41, 'E1561211-EB34-4E41-A28B-635EFD0EBE62', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (42, '1EEFADE5-D73D-4136-832B-39239D01292D', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (43, '686F3129-70CD-4861-9124-B4C25E455B85', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (44, 'E5BAB05A-179B-4A65-874C-E6DA79B7EEDD', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (45, '4C6BF59F-F4B9-4862-9C58-DC77704EFC8D', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (46, 'A110DB6D-8FAE-4EB5-955E-06AC13AA147C', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (47, '89A39D7F-0049-4CBF-931F-71E3DFF9F443', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (48, 'DE3FB1CE-6833-44FE-9EBA-BE7C99DC4856', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (49, '49D8A116-147B-4E28-BBAD-0A4593E7AAC7', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (50, '1C00AD16-8043-44CB-8EC7-60B513673039', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (51, '4FBDC41E-E0B0-48C2-9DC9-3860CD7475E0', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (52, '3561653E-C374-4F38-BA21-FDA64ADD8A54', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (53, '988D8433-E3D1-40F5-88A8-AE18BD997F0E', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (54, '955FBEA1-9506-4A44-9BA7-5D701D305F6E', 2)
                 
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (56, '4789106F-F310-49C4-8FEC-927AFCE4E2B0', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (57, 'D8BC4C59-C51C-11D3-881B-0090270D4908', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (58, 'D9CD9CEE-0E98-4D3E-A2D9-27EEC75589B4', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (59, '4D34581E-8C83-11D3-880C-0090270D4908', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (60, 'AE2760FD-770D-45BA-9C04-3241E3DF1539', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (61, '661A7A0A-E4A3-471A-9B32-8960F42362CD', 2)
                           
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (64, '73A45127-F46E-4537-8F99-6301B49B3DB2', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (65, 'F7491467-B91A-41CC-BBAE-0035EC67BFC1', 2)
                   
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (67, '017BEEC2-A234-4E90-8B6B-E906492095D5', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (68, '6B6F26B4-DBA7-49FA-A7A5-DE9A6FCA05C7', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (69, '81A2388A-96EE-4B4B-B95D-8EE820BF59E0', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (70, 'E0CFCE0F-51A5-4118-A857-9069FA7AC177', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (71, 'BBAF2C72-CADB-4C89-9C6B-4534B707FB43', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (72, 'E10E733E-20AB-498F-A562-41A1A247C5EA', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (73, '064902E1-AA35-4B79-987D-4748E59FF534', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (74, '869E1A11-35DE-4F91-9D49-BF9BFAA692EE', 2)
                            
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (77, '189702A2-DB75-4D69-A840-7866ADA006DF', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (78, '51BC3334-55BC-11D4-8853-0090270D4908', 2)         
         
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (81, '3922EA9D-3F5E-42B4-A759-2DF95349BADB', 2)
                   
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (83, '3A3C2703-ED82-4F46-A5F7-269CA94E5822', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (84, '33ECCAD5-EC18-4360-B228-87733E35C6CA', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (85, '83553721-B337-440F-8031-80BAA86754D8', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (86, '9A0836CD-7FF8-4BA1-8AD9-D5485E8527B0', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (87, 'DD8AB629-5327-4662-996F-5FF6EA39A8E5', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (88, 'D2DE313B-682E-4E59-87A1-75E96F23146C', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (89, 'C1978EBF-DD92-4B40-ADC3-90CB0457F183', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (90, '55BD6362-583F-46D0-8862-1D9A337CE695', 2)
                                     
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (94, 'D6C516C9-F6EA-4331-AC60-7BD71E6C5CBF', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (95, 'B531CD48-41DB-4F8F-92AE-5AACD7520154', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (96, '9BA74BC1-9625-42E3-8AD4-0688E151B277', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (97, 'FEC1EB17-0231-4695-8794-E7838B1BFBA6', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (98, '3AB5F8F1-5C6E-47AB-8C4B-DA5315C19D2E', 2)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (99, 'F5BC05BD-DCD9-483C-8613-D604A63B70DD', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (100, '5CE08187-0A7B-4E0C-97CC-6E2DBBEAC015', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (101, '8CFBEA36-0A59-48A1-99C4-6BAB528AC2B3', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (102, 'F185151A-65C2-4C74-B591-5FE4F714CAE1', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (103, '1E0984BA-999B-4A57-8CDC-03A7D77FB1B2', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (104, 'A6E73C42-C9EB-403A-AD60-D6539ED16C38', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (105, 'E0136218-760E-49A4-929C-755B25988ACB', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (106, '5BCC9E15-4EC1-49AB-AABC-E63CFC1D0F31', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (107, 'F15EFC79-99D6-4256-8CAD-97FE18C305EE', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (108, '35339C4A-C7F2-4A65-83EF-FCC4314D9962', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (109, '718A2A3D-72BE-4DBB-BB9D-BBE54A3C5934', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (110, '5A9D6669-7A5C-47AB-86D9-FEEAA73523EC', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (111, 'A3D8869C-7418-4249-A623-7B829828B363', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (112, '551F3751-72E1-4F62-B516-775D9ACBE7BD', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (113, '6E07E901-5EEF-4D43-ABC9-5A73BC9B072D', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (114, '46B98966-C802-4A3D-AED7-40F7B4E6BB42', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (115, '40FAD9DD-6453-49D8-AC36-3DD71C32A025', 1)
                             
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (121, '5A84832A-349A-4DF2-94CF-5B17C234E803', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (122, '1BD3506B-C1B3-4836-B569-EBF2289DC6EC', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (123, '37B5AB26-6DE0-11D3-945C-0090275A5879', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (124, '1C77A494-F086-4C7B-9469-5713AD1B5FAC', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (125, '4F9FFDA8-E4C9-484C-AB06-E72173442F87', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (126, '7CE18496-52B5-474F-922D-D2C092853F32', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (127, 'FB0FAF2A-704A-11D3-945D-0090275A5879', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (128, '8816F88A-6002-401E-B06D-253B5048394B', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (129, 'ED84E696-21A7-4534-9DE7-C4ACE5E08C20', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (130, '5B14218E-32D4-43FA-A0F5-40604534A4EB', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (131, 'FA97060F-A547-4229-8B75-B3892BA0254E', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (132, '641ABC48-6592-458A-8DA5-34066BDCB087', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (133, 'FDCB5DF1-F57E-4E33-BB57-A4EEFD48BA95', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (134, 'EF8AD353-7104-4D22-B418-93DB8DE0FC73', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (135, '78C287BA-90F4-4FAB-8C99-920C48B071F8', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (136, '6A1923E7-8E52-46FF-A4DA-4A2B49FDB7BF', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (137, 'C2531CD3-7ABE-4A2D-891F-1BA294606778', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (138, '26E974A0-CBF9-4B98-9C50-09A892CDC4E7', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (139, '596AE10F-1797-4D61-91DE-BFF3CC459EB1', 1)
                    
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (142, 'B3933E60-1B76-4CE3-9D85-22B64F74D795', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (143, '8B0CD97E-2CDB-4CA9-A83D-ED730105D73E', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (146, '802743FF-317C-415E-B3DB-17A5BA61D7AB', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (147, '14308A28-1040-43C8-8191-8E63388A6148', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (148, '6B945393-FF6A-477A-98C0-98DD3472EB29', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (149, 'BF58F4A2-0A23-463F-A834-AE0B6CEFF4D1', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (150, '8C3458E9-4BAA-4E14-98E4-72557585623F', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (151, '8088F959-2929-4056-BB71-CE7AE4CC9664', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (152, 'BB26CF90-AE93-46A5-B691-E5A970EFA874', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (153, 'CD8C2E88-3B2F-48E2-84BF-AA7D79C59E1D', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (154, '228EF409-B3B6-4E29-83D8-645601CAB36E', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (155, 'EB4265A7-5730-11D3-87EF-0090270D4908', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (156, 'F7F2D982-5AF9-11D3-BEEE-00A0C938A970', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (158, 'AB58830D-887E-47F0-AC29-94C521DADEB2', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (159, '8128A8AA-4E98-11D3-A79D-0090270D3D83', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (160, 'BE192596-4C5E-4B4E-8840-57A67FBDAB9D', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (162, '71378356-EB9B-4F53-A1D1-4DA3927EF09F', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (163, 'B6B3E79C-E4A9-11D3-AB67-0090275A4C62', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (164, 'B6B3E7A0-E4A9-11D3-AB67-0090275A4C62', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (165, 'B6B3E467-E4A9-11D3-AB67-0090275A4C62', 1)
                  
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (167, 'B6B3E798-E4A9-11D3-AB67-0090275A4C62', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (168, '1F0F1732-90A7-4A89-8752-FE294C7E4C4F', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (169, 'D4708F17-B578-48D2-9C8B-B47CC0D9286C', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (170, '80475B23-0CA9-455D-A97D-91AE7E060C6E', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (171, 'A9D949FB-0091-4A29-BE6A-B358234FFA4A', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (172, '798E7C77-9BE6-4292-8F0F-3B46CBFE209E', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (173, 'D09120C2-2A30-45A6-BE2E-EC4AB377E743', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (174, 'BEE79262-51CD-11D3-A79D-0090270D3D83', 1)
                            
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (177, '70002B7B-5EE3-11D3-B2DF-009027884ACB', 1)

     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (181, '70002BC5-5EE3-11D3-B2DF-009027884ACB', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (183, '11175E95-4B5F-4650-9B1E-2AC004BD3D35', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (184, '57809D46-DA7D-4D1C-8B41-3DAAEDD35418', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (185, '143F49A0-8455-4B19-A581-65221E6C2300', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (186, '5151E7B2-C8D5-42E6-B57C-CC8CEC2D1ED1', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (187, 'DF2A80BA-8F82-40D8-B23E-B583DF0FB718', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (189, 'ADCE42D0-44BA-4417-A0A7-467F39EE66C4', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (192, '70002AC3-5EE3-11D3-B2DF-009027884ACB', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (196, '22568432-DA48-4199-AD66-5B2B4B02C6DF', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (197, '8D8F80E2-DD64-44C2-A165-59B84CE76C7F', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (198, '4860E930-D9C6-4C02-A44C-0D1FD8F0D1A2', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (199, 'C1BBF9FB-C5C8-487E-AB76-B0196E5147AC', 1)
          
     INSERT INTO dbo.SC_OperationalDataDimension_View
     (SMC_InstanceID, OperationalDataID, Type)
     VALUES
     (200, '757CFA20-F170-4166-ADE3-5BA06981BC57', 1)

QuitWithError:

         IF @setIdentity = 1
         BEGIN
             SET IDENTITY_INSERT dbo.SC_OperationalDataDimension_Table OFF
         END

         RETURN @saveError

END
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_PopulateTimeDimension
AS
BEGIN
         DECLARE @time DATETIME
         DECLARE @cSeconds INT
         DECLARE @iSecond INT
         DECLARE @hour INT
         DECLARE @saveError INT
         DECLARE @setIdentity BIT
   
         SET @saveError = 0
         SET @cSeconds = 86400
         SET @iSecond = 0
         SET @time = '1/1/2003 00:00:00 AM'
         SET @setIdentity = 0

        /**********************************************
     * Add a time dimension that represents N/A    *
        **********************************************/

        SET IDENTITY_INSERT dbo.SC_TimeDimension_Table ON

        SELECT @saveError = @@ERROR
        IF @saveError <> 0 GOTO QuitWithError

        SET @setIdentity = 1

         INSERT INTO dbo.SC_TimeDimension_View
         (SMC_InstanceID,
          TimeOfDay,
          [Hour_PK],
          [Minute_PK],
          [Second_PK],
          AMPM
         )
         VALUES
         (1,
          '1/1/1800 00:00:00 AM',
          99,
          99,
          99,
          'AM'
         )

         SELECT @saveError = @@ERROR
         IF @saveError <> 0 GOTO QuitWithError

         SET IDENTITY_INSERT dbo.SC_TimeDimension_Table OFF

         SELECT @saveError = @@ERROR
         IF @saveError <> 0 GOTO QuitWithError

         SET @setIdentity = 0

        /**********************************************
        * Populate the time dimension                 *
        ***********************************************/
 
         WHILE @iSecond < @cSeconds
         BEGIN

             SELECT @hour = DATEPART(hour, @time)

             INSERT INTO dbo.SC_TimeDimension_View
             (TimeOfDay,
              [Hour_PK],
              [Minute_PK],
              [Second_PK],
              AMPM
             )
             VALUES
             (@time,
              @hour,
              DATEPART(minute, @time),
              DATEPART(second, @time),
              CASE 
                  WHEN @hour >= 12 THEN 'PM'
                  ELSE 'AM'
              END
             )
 
             SELECT @saveError = @@ERROR
             IF @saveError <> 0 GOTO QuitWithError

             SELECT @time = DATEADD(second, 1, @time)
             SELECT @iSecond = @iSecond + 1 
         END

QuitWithError:

         IF @setIdentity = 1
         BEGIN
             SET IDENTITY_INSERT dbo.SC_DateDimension_Table OFF
         END

         RETURN @saveError

END
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_SQLBackupHistoryReport
  @Computer nvarchar(256), @BeginDate DATETIME, @EndDate DATETIME 
AS
BEGIN
create table #SQL_Backup_History_Table
(
 [Server]  nvarchar(256),
 [Time]   datetime,
 [Instance]  nvarchar(256),
 [Database]  nvarchar(256),
 [Failed Backups]  nvarchar(3),
 [Successful Backups]  nvarchar(3),
 [Backup Type]   nvarchar(32),
 [Backup Name]  nvarchar(256),
 [FailOrSuccess]  nvarchar(32)
)
Declare @Time  dateTime
Declare @Instance  nvarchar(1000)
Declare @EventMessage nvarchar(4000)
Declare @FailedBackups nvarchar (3)
Declare @SuccessBackups nvarchar (3)
Declare @Database nvarchar (256)
Declare @BackupName nvarchar (256)
Declare @FailOrSuccess nvarchar (32)
Declare @BackupType nvarchar (32)
Declare BackupHistory cursor for
   SELECT  
 cd.FullComputerName , 
 EF.LocalDateTimeGenerated ,
 CASE WHEN substring(EDD.EventSource_PK, 1, 6) = 'MSSQL$' THEN substring(EDD.EventSource_PK, 7,190) ELSE EDD.EventSource_PK END AS [Instance], 
 EF.EventMessage  
   FROM    
 dbo.SC_EventFact_View EF INNER JOIN
        dbo.SC_EventDetailDimension_View EDD ON EF.EventDetail_FK = EDD.SMC_InstanceID INNER JOIN
        dbo.SC_EventTypeDimension_View ETD ON EF.EventType_FK = ETD.SMC_InstanceID INNER JOIN
        dbo.SC_ComputerDimension_View CD ON EF.Computer_FK = CD.SMC_InstanceID
   WHERE      
        EDD.EventID_PK = 17055 AND ((PATINDEX('%3041%', EF.EventMessage) <> 0) OR (PATINDEX('%18264%', EF.EventMessage) <> 0)) 
        AND (@Computer='<ALL>' or cd.FullComputerName = @Computer) AND EF.LocalDateTimeGenerated BETWEEN @BeginDate AND @EndDate

Open BackupHistory

Fetch Next From BackupHistory into @Computer,@Time,@Instance,@EventMessage
While @@FETCH_STATUS = 0 
Begin   
 set @SuccessBackups  = Null
 set @FailOrSuccess     = Null
 set @Database  = Null
 set @BackupName  = Null
 set @FailedBackups = Null
 if PATINDEX('%18264%', @EventMessage) <> 0
 begin
  set @SuccessBackups  = 'Yes' 
  set @FailOrSuccess     = 'Successful Backups'
  if CHARINDEX('Database: ', @EventMessage) > 0 
   set @Database      = SubString(@EventMessage, CHARINDEX('Database: ', @EventMessage) + 10, charindex(',', SubString(@EventMessage, CHARINDEX('Database: ', @EventMessage) + 10, 50)) - 1)
  if CHARINDEX('NAME = N',@EventMessage) > 0
   set @BackupName  = SubString(@EventMessage, CHARINDEX('NAME = N',@EventMessage) + 9, charindex(',', SubString(@EventMessage, CHARINDEX('NAME = N', @EventMessage) + 9, 50)) - 2)
 end
 if CHARINDEX('DIFFERENTIAL', @EventMessage) <> 0
  set @BackupType = 'Differential' else set @BackupType = 'Full'
 if PATINDEX('%3041%', @EventMessage) <> 0
 begin
  if CHARINDEX('BACKUP DATABASE ' + char(91), @EventMessage) > 0
   set @Database    = SubString(@EventMessage,CHARINDEX('BACKUP DATABASE ' + char(91), @EventMessage) + 17, CHARINDEX(char(93), @EventMessage) - (CHARINDEX('BACKUP DATABASE', @EventMessage) + 17)) 
  if CHARINDEX('BACKUP LOG ' + char(91), @EventMessage) > 0
   set @Database    = SubString(@EventMessage,CHARINDEX('BACKUP LOG ' + char(91), @EventMessage) + 12, CHARINDEX(char(93), @EventMessage) - (CHARINDEX('BACKUP LOG', @EventMessage) + 12)) 
  if CHARINDEX('NAME = N',@EventMessage) > 0
   set @BackupName  = SubString(@EventMessage, CHARINDEX('NAME = N',@EventMessage) + 9, charindex(',', SubString(@EventMessage, CHARINDEX('NAME = N', @EventMessage) + 9, 50)) - 2)
  set @FailOrSuccess = 'Failed Backups'
  set @FailedBackups   = 'Yes'
 end
 Insert into #SQL_Backup_History_Table values(@Computer,@Time,@Instance,@Database,@FailedBackups,@SuccessBackups,@BackupType,@BackupName,@FailOrSuccess)
 Fetch Next From BackupHistory into @Computer,@Time,@Instance,@EventMessage

end 

SELECT  Server, 
 Instance, 
 COUNT([Failed Backups]) AS [Failed Backups], 
 COUNT([Successful Backups]) AS [Successful Backups], 
 COUNT([Failed Backups]) + COUNT([Successful Backups]) AS TotalBackups, 
 [Time], 
 [Backup Type], 
 [Backup Name], 
 [FailOrSuccess] as  [FailedSuccessful], 
 [Database]
FROM   
 #SQL_Backup_History_Table
GROUP BY 
 Server, Instance, [Time], [Backup Type], [Backup Name], [FailOrSuccess], [Database]

CLOSE BackupHistory
DEALLOCATE BackupHistory
END
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_SQLBlockAnalysisDetailReport
 @Computer nvarchar(256), @Program nvarchar(256), @Instance nvarchar(256), @Database nvarchar(256),@BeginDate datetime, @EndDate datetime
AS
BEGIN
create table #SQL_BlockAnalysisDetail_Table
(
 Server   nvarchar(256),
 LocalDateTimeRaised datetime,
 ProgramName  nvarchar(256),
 BlockedDB  nvarchar(256),
 BlockedInstance  nvarchar(256),
 BlockedDuration  integer,
 LoginName  nvarchar(256),
 BlockedSPID  nvarchar(256),
 BlockedbySPID  nvarchar(256),
 ResourceGUID  nvarchar(256)
)

Declare @BlockedInstance  nvarchar (256)
Declare @BlockedDB   nvarchar (256)
Declare @ProgramName   nvarchar (256)
Declare @BlockedDuration  integer
Declare @LoginName   nvarchar (256)
Declare @BlockedSPID   nvarchar (256)
Declare @BlockedbySPID   nvarchar (256)
Declare @ResourceGUID   nvarchar (256)
Declare @AlertDescription nvarchar (4000)
Declare @DateTimeRaised datetime




Declare BlockAnalysis cursor for
Select  CD.FullComputerName as Server,
 AF.AlertDescription ,AF.LocalDateTimeRaised
from 
 dbo.SC_AlertFact_View AF inner join 
 dbo.SC_ComputerDimension_View CD ON CD.SMC_InstanceID = AF.Computer_FK
where 
 AF.AlertName Like 'SQL Server 2000 Block Analysis%'  
 and AF.AlertDescription Like 'The Program%' 
 and CD.FullComputerName  = @Computer
 and AF.LocalDateTimeRaised between @BeginDate and @EndDate
Open BlockAnalysis

Fetch Next From BlockAnalysis into @Computer,@AlertDescription,@DateTimeRaised
While @@FETCH_STATUS = 0 
Begin   
 set @ProgramName  = Null
 set @BlockedDuration    = 0
 set @BlockedDB  = Null
 set @BlockedInstance = Null
 set @LoginName  = Null
 set @BlockedSPID = Null
 set @BlockedbySPID = Null
 set @ResourceGUID = Null
 
 if CHARINDEX(' has been blocked',@AlertDescription)-CHARINDEX('The program ',@AlertDescription)-14 > 0
  set @ProgramName=substring(@AlertDescription,CHARINDEX('The program ',@AlertDescription)+13,CHARINDEX(' has been blocked',@AlertDescription)-CHARINDEX('The program ',@AlertDescription)-14) 
 if CHARINDEX('minutes',@AlertDescription)-CHARINDEX('for',@AlertDescription)-4 > 0
  set @BlockedDuration =Cast(substring(@AlertDescription,CHARINDEX('for',@AlertDescription)+4,CHARINDEX('minutes',@AlertDescription)-CHARINDEX('for',@AlertDescription)-4) as integer) 
 if CHARINDEX('in the SQL',@AlertDescription)-CHARINDEX('database',@AlertDescription)-9 > 0
  set @BlockedDB  =substring(@AlertDescription,CHARINDEX('database',@AlertDescription)+9,CHARINDEX('in the SQL',@AlertDescription)-CHARINDEX('database',@AlertDescription)-9)
 if  CHARINDEX('.',@AlertDescription)-CHARINDEX('instance',@AlertDescription)-9 > 0
  set @BlockedInstance =substring(@AlertDescription,CHARINDEX('instance',@AlertDescription)+9,CHARINDEX('.',@AlertDescription)-CHARINDEX('instance',@AlertDescription)-9) 
 if CHARINDEX('and is blocked',@AlertDescription)-CHARINDEX('as login',@AlertDescription)-9 > 0
  set @LoginName = substring(@AlertDescription,CHARINDEX('as login',@AlertDescription)+9,CHARINDEX('and is blocked',@AlertDescription)-CHARINDEX('as login',@AlertDescription)-9) 
 if CHARINDEX('as login',@AlertDescription)-CHARINDEX('SPID',@AlertDescription)-5 > 0
  set @BlockedSPID = substring(@AlertDescription,CHARINDEX('SPID',@AlertDescription)+5,CHARINDEX('as login',@AlertDescription)-CHARINDEX('SPID',@AlertDescription)-5) 
 if CHARINDEX('.  The resource',@AlertDescription)-CHARINDEX('by SPID',@AlertDescription)-8 > 0
  set @BlockedbySPID = substring(@AlertDescription,CHARINDEX('by SPID',@AlertDescription)+8,CHARINDEX('.  The resource',@AlertDescription)-CHARINDEX('by SPID',@AlertDescription)-8) 
 if CHARINDEX(')',@AlertDescription,200)-CHARINDEX('id is KEY:',@AlertDescription)-10 > 0
  set @ResourceGUID = substring(@AlertDescription,CHARINDEX('id is KEY:',@AlertDescription)+11,CHARINDEX(')',@AlertDescription,200)-CHARINDEX('id is KEY:',@AlertDescription)-10) 
 if (@Instance=@BlockedInstance)
 begin
  if (@Program = '<ALL>') and (@Database='<ALL>') 
   Insert into #SQL_BlockAnalysisDetail_Table values(@Computer,@DateTimeRaised,@ProgramName,@BlockedDB,@BlockedInstance,@BlockedDuration,@LoginName,@BlockedSPID,@BlockedbySPID,@ResourceGUID)
  if (@Program = '<ALL>')  and (@Database=@BlockedDB) 
   Insert into #SQL_BlockAnalysisDetail_Table values(@Computer,@DateTimeRaised,@ProgramName,@BlockedDB,@BlockedInstance,@BlockedDuration,@LoginName,@BlockedSPID,@BlockedbySPID,@ResourceGUID)
  if (@Program = @ProgramName)  and (@Database='<ALL>')
   Insert into #SQL_BlockAnalysisDetail_Table values(@Computer,@DateTimeRaised,@ProgramName,@BlockedDB,@BlockedInstance,@BlockedDuration,@LoginName,@BlockedSPID,@BlockedbySPID,@ResourceGUID)
  if (@Program = @ProgramName)  and (@Database=@BlockedDB)
   Insert into #SQL_BlockAnalysisDetail_Table values(@Computer,@DateTimeRaised,@ProgramName,@BlockedDB,@BlockedInstance,@BlockedDuration,@LoginName,@BlockedSPID,@BlockedbySPID,@ResourceGUID)
 end
 Fetch Next From BlockAnalysis into @Computer,@AlertDescription,@DateTimeRaised
end 
Select   
 Server,
 LocalDateTimeRaised,
 ProgramName,
 BlockedDB,
 BlockedInstance,
 BlockedDuration,
 LoginName,
 BlockedSPID,
 BlockedbySPID,
 ResourceGUID
from 
 #SQL_BlockAnalysisDetail_Table

CLOSE BlockAnalysis
DEALLOCATE BlockAnalysis
END
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_SQLBlockAnalysisReport
  @Computer nvarchar(256),@BeginDate datetime, @EndDate datetime
AS
BEGIN
create table #SQL_BlockAnalysis_Table
(
 Server   nvarchar(256),
 ProgramName  nvarchar(256),
 BlockedDB  nvarchar(256),
 BlockedInstance  nvarchar(256),
 BlockedDuration  integer
)

Declare @BlockedInstance  nvarchar (256)
Declare @BlockedDB   nvarchar (256)
Declare @ProgramName   nvarchar (256)
Declare @BlockedDuration  integer
Declare @AlertDescription nvarchar (4000)

Declare BlockAnalysis cursor for
Select  CD.FullComputerName as Server,
 AF.AlertDescription 
from 
 dbo.SC_AlertFact_View AF inner join 
 dbo.SC_ComputerDimension_View CD ON CD.SMC_InstanceID = AF.Computer_FK
where 
 AF.AlertName Like 'SQL Server 2000 Block Analysis%'  
 and AF.AlertDescription Like 'The Program%' 
 and CD.FullComputerName  = @Computer
 and AF.LocalDateTimeRaised between @BeginDate and @EndDate

Open BlockAnalysis

Fetch Next From BlockAnalysis into @Computer,@AlertDescription
While @@FETCH_STATUS = 0 
Begin   
 set @ProgramName  = Null
 set @BlockedDuration    = 0
 set @BlockedDB  = Null
 set @BlockedInstance = Null
 

 if CHARINDEX(' has been blocked',@AlertDescription)-CHARINDEX('The program ',@AlertDescription)-14 > 0
  set @ProgramName=substring(@AlertDescription,CHARINDEX('The program ',@AlertDescription)+13,CHARINDEX(' has been blocked',@AlertDescription)-CHARINDEX('The program ',@AlertDescription)-14) 
 if CHARINDEX('minutes',@AlertDescription)-CHARINDEX('for',@AlertDescription)-4 > 0
  set @BlockedDuration =Cast(substring(@AlertDescription,CHARINDEX('for',@AlertDescription)+4,CHARINDEX('minutes',@AlertDescription)-CHARINDEX('for',@AlertDescription)-4) as integer) 
 if CHARINDEX('in the SQL',@AlertDescription)-CHARINDEX('database',@AlertDescription)-9 > 0
  set @BlockedDB  =substring(@AlertDescription,CHARINDEX('database',@AlertDescription)+9,CHARINDEX('in the SQL',@AlertDescription)-CHARINDEX('database',@AlertDescription)-9)
 if  CHARINDEX('.',@AlertDescription)-CHARINDEX('instance',@AlertDescription)-9 > 0
  set @BlockedInstance =substring(@AlertDescription,CHARINDEX('instance',@AlertDescription)+9,CHARINDEX('.',@AlertDescription)-CHARINDEX('instance',@AlertDescription)-9) 
 Insert into #SQL_BlockAnalysis_Table values(@Computer,@ProgramName,@BlockedDB,@BlockedInstance,@BlockedDuration)
 Fetch Next From BlockAnalysis into @Computer,@AlertDescription
end 
Select   
 Server,
 ProgramName,
 BlockedDB,
 BlockedInstance,
 Count(*) as TotalBlocks,
 Avg(BlockedDuration) as AvgBlockTime
from 
 #SQL_BlockAnalysis_Table
group by Server,ProgramName,BlockedDB,BlockedInstance

CLOSE BlockAnalysis
DEALLOCATE BlockAnalysis

END
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_SQLTop25FailedloginsReport
  @Computer nvarchar(256), @Instance nvarchar(256), @BeginDate datetime, @EndDate datetime
AS
BEGIN
create table #SQL_SQLTop25PercentFailedLogins_Table
(
 Server   nvarchar(256),
 Instance  nvarchar(256),
 UserName  nvarchar(256),
 Reason   nvarchar(256)
)

Declare @Time     datetime
Declare @UserName nvarchar (256)
Declare @Reason  nvarchar (256)
Declare @count  integer
Declare @Message nvarchar (4000)

Declare FailedLogins cursor for

SELECT  TOP 25 PERCENT CD.FullComputerName AS [Server], 
 CASE WHEN substring(EDD.EventSource_PK, 1, 6) = 'MSSQL$' THEN substring(EDD.EventSource_PK, 7, 199) ELSE EDD.EventSource_PK END , 
        LocalDateTimeGenerated AS [Time], 
 EF.EventMessage
FROM    dbo.SC_EventFact_View EF INNER JOIN
        dbo.SC_EventTypeDimension_View ETD ON ETD.SMC_InstanceID = EF.EventType_FK INNER JOIN
        dbo.SC_EventDetailDimension_View EDD ON EDD.SMC_InstanceID = EF.EventDetail_FK INNER JOIN
        dbo.SC_ProviderDetailDimension_View PDD ON PDD.SMC_InstanceID = EF.ProviderDetail_FK INNER JOIN
        dbo.SC_ComputerDimension_View CD ON CD.SMC_InstanceID = EF.Computer_FK
WHERE   EDD.EventID_PK IN (17055)  
 AND (PATINDEX('%18452%',EF.EventMessage) <> 0)
 AND LocalDateTimeGenerated BETWEEN @BeginDate AND @EndDate  
 AND CD.FullComputerName = @Computer
GROUP BY CD.FullComputerName, EDD.EventSource_PK, LocalDateTimeGenerated,EF.EventMessage

Open FailedLogins

Fetch Next From FailedLogins into @Computer,@Instance,@Time,@Message
While @@FETCH_STATUS = 0 
Begin   
 set @UserName  = Null
 set @Reason  = Null
 if CHARINDEX('Reason',@Message)- CHARINDEX('Login failed for user',@Message)-26 > 0
  set @UserName = SUBSTRING(@Message,CHARINDEX('Login failed for user',@Message)+23,CHARINDEX('Reason',@Message)- CHARINDEX('Login failed for user',@Message)-26)
 if Len(@Message)- CHARINDEX('Reason:',@Message)-7 > 0 
         set @Reason       = SUBSTRING(@Message,CHARINDEX('Reason:',@Message)+8,Len(@Message)- CHARINDEX('Reason:',@Message)-7)
 Insert into #SQL_SQLTop25PercentFailedLogins_Table values(@Computer,@Instance,@UserName,@Reason)  
 Fetch Next From FailedLogins into @Computer,@Instance,@Time,@Message
end 

Select   
 Server,
 Instance,
 UserName,
 Reason,
 Count(*) as [count]
from 
 #SQL_SQLTop25PercentFailedLogins_Table
group by Server,
 Instance,
 UserName,
 Reason

CLOSE FailedLogins
DEALLOCATE FailedLogins
END
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_SQLTop25SuccessfulLoginsReport
  @Computer nvarchar(256), @Instance nvarchar(256), @BeginDate datetime, @EndDate datetime
AS
BEGIN
create table #SQL_SQLTop25PercentSuccessfulLogins_Table
(
 Server   nvarchar(256),
 Instance  nvarchar(256),
 UserName  nvarchar(256),
 Reason   nvarchar(256)
)

Declare @Time     datetime
Declare @UserName nvarchar (256)
Declare @Reason  nvarchar (256)
Declare @count  integer
Declare @Message nvarchar (4000)

Declare SuccessfulLogins cursor for

SELECT  TOP 25 PERCENT CD.FullComputerName AS [Server], 
 CASE WHEN substring(EDD.EventSource_PK, 1, 6) = 'MSSQL$' THEN substring(EDD.EventSource_PK, 7, 199) ELSE EDD.EventSource_PK END , 
        LocalDateTimeGenerated AS [Time], 
 EF.EventMessage
FROM    dbo.SC_EventFact_View EF INNER JOIN
        dbo.SC_EventTypeDimension_View ETD ON ETD.SMC_InstanceID = EF.EventType_FK INNER JOIN
        dbo.SC_EventDetailDimension_View EDD ON EDD.SMC_InstanceID = EF.EventDetail_FK INNER JOIN
        dbo.SC_ProviderDetailDimension_View PDD ON PDD.SMC_InstanceID = EF.ProviderDetail_FK INNER JOIN
        dbo.SC_ComputerDimension_View CD ON CD.SMC_InstanceID = EF.Computer_FK
WHERE   EDD.EventID_PK IN (17055)  
 AND (PATINDEX('%18453%',EF.EventMessage) <> 0)
 AND LocalDateTimeGenerated BETWEEN @BeginDate AND @EndDate  
 AND CD.FullComputerName = @Computer
GROUP BY EDD.EventSource_PK, CD.FullComputerName, EF.LocalDateTimeGenerated, EF.EventMessage

Open SuccessfulLogins

Fetch Next From SuccessfulLogins into @Computer,@Instance,@Time,@Message
While @@FETCH_STATUS = 0 
Begin   
 set @UserName  = Null
 set @Reason  = Null

 if CHARINDEX('Connection',@Message)- CHARINDEX('Login succeeded for user',@Message)-29 > 0
  set @UserName  = SUBSTRING(@Message,CHARINDEX('Login succeeded for user',@Message)+26,CHARINDEX('Connection',@Message)- CHARINDEX('Login succeeded for user',@Message)-29)
 if Len(@Message)- CHARINDEX('Connection:',@Message)-12 > 0
         set @Reason     = SUBSTRING(@Message,CHARINDEX('Connection:',@Message)+12,Len(@Message)- CHARINDEX('Connection:',@Message)-12)
 Insert into #SQL_SQLTop25PercentSuccessfulLogins_Table values(@Computer,@Instance,@UserName,@Reason)  
 Fetch Next From SuccessfulLogins into @Computer,@Instance,@Time,@Message
end 

Select   
 Server,
 Instance,
 UserName,
 Reason,
 Count(*) as [count]
from 
 #SQL_SQLTop25PercentSuccessfulLogins_Table
group by Server,
 Instance,
 UserName,
 Reason

CLOSE SuccessfulLogins
DEALLOCATE SuccessfulLogins
END
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.p_SetupLogins
(
    @loginprefix sysname
)
AS
BEGIN

    DECLARE @ret int
    DECLARE @login sysname

    SET @login = @loginprefix + '\SC DW Reader'
    EXECUTE @ret = dbo.p_CreateLogin @login, N'SC DW Reader', N'SystemCenterReporting', 0, 0, 0, 0
    IF (@@ERROR <> 0 OR @ret <> 0) GOTO Error_Exit

    SET @login = @loginprefix + '\SC DW DTS'
    EXECUTE @ret = dbo.p_CreateLogin @login, N'SC DW DTS', N'SystemCenterReporting', 0, 1, 1, 1
    IF (@@ERROR <> 0 OR @ret <> 0) GOTO Error_Exit

    RETURN 0

Error_Exit:

    RETURN 1

END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_UpdateCurrentEndTime @ConfigurationGroupID UNIQUEIDENTIFIER = NULL, @CurrentEndTime DATETIME = NULL
AS
BEGIN
        /**********************************************
        * Update the CurrentEndTime                   *
        ***********************************************/

        DECLARE @saveError INT
        SET @saveError = 0

        UPDATE [dbo].[SMC_Meta_WarehouseTransformInfo]
        SET CurrentEndTime = @CurrentEndTime
        WHERE ConfigurationGroupID = @ConfigurationGroupID

        SELECT @saveError = @@ERROR
        IF @saveError <> 0 GOTO QuitWithError

QuitWithError:

         RETURN @saveError

END
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_UpdateGroomDays
@TableName NVARCHAR(128) = NULL,
@GroomDays INT = NULL
AS
BEGIN

    DECLARE @SaveError INTEGER
    DECLARE @ValidatedClassID UNIQUEIDENTIFIER
    SET @ValidatedClassID = NULL
    DECLARE @GroomingEnabled BIT
    SET @GroomingEnabled = NULL

    --
    -- Validate the parameters
    -- 
    
    IF (@TableName IS NULL OR
        @GroomDays IS NULL
       )        
    BEGIN
        GOTO ParamError_Exit
    END   
    ELSE
    BEGIN
        SELECT @ValidatedClassID = ClassID
        FROM dbo.SMC_Meta_ClassSchemas
        WHERE TableName = @TableName
    END

    SET @SaveError = @@ERROR
    IF (@SaveError <> 0) 
    BEGIN
        GOTO Error_Exit
    END
    
    IF (@ValidatedClassID IS NULL)
    BEGIN
        GOTO ParamError_Exit
    END        

    SELECT @GroomingEnabled = MustBeGroomed
    FROM dbo.SMC_Meta_WarehouseClassSchema
    WHERE ClassID = @ValidatedClassID

    SET @SaveError = @@ERROR
    IF (@SaveError <> 0) 
    BEGIN
        GOTO Error_Exit
    END

    IF (@GroomingEnabled IS NULL OR
        @GroomingEnabled = 0)
    BEGIN
        GOTO GroomingDisabledOnTable_Exit
    END        
    
    --
    -- Update the groom days setting for the table
    --
     
    UPDATE dbo.SMC_Meta_WarehouseClassSchema
    SET GroomDays = @GroomDays
    WHERE ClassID = @ValidatedClassID

    SET @SaveError = @@ERROR
    IF (@SaveError <> 0) 
    BEGIN
        GOTO Error_Exit
    END
    
    RETURN 0

Error_Exit:
    
    -- SQL Server error %u encountered in p_UpdateGroomDays.
    RAISERROR (777977207, 16, 1, @SaveError) WITH LOG
    RETURN @SaveError
    
ParamError_Exit:

    -- Invalid parameter encountered in p_UpdateGroomDays.
    RAISERROR (777977208, 16, 1) WITH LOG
    RETURN 1
    
GroomingDisabledOnTable_Exit:

    -- Invalid table name encountered in p_UpdateGroomDays. Grooming is not 
    -- enabled on this table
    RAISERROR (777977209, 16, 1, @TableName) WITH LOG
    RETURN 1
    
END
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_UpsertCurrentStartAndEndTime @ConfigurationGroupID UNIQUEIDENTIFIER = NULL, @CurrentStartTime DATETIME = NULL, @CurrentEndTime DATETIME = NULL
AS
BEGIN
        /*************************************************
        * Update the CurrentStartTime and CurrentEndTime *
        **************************************************/

        DECLARE @saveError INT
        DECLARE @ExistingCurrentStartTime DATETIME

        SET @saveError = 0

        SELECT @ExistingCurrentStartTime = WTI.CurrentStartTime
        FROM [dbo].[SMC_Meta_WarehouseTransformInfo] AS WTI
        WHERE WTI.ConfigurationGroupID = @ConfigurationGroupID

        SELECT @saveError = @@ERROR
        IF @saveError <> 0 GOTO QuitWithError

        IF @ExistingCurrentStartTime IS NULL
        BEGIN

            INSERT INTO [dbo].[SMC_Meta_WarehouseTransformInfo]
            (ConfigurationGroupID,
             CurrentStartTime,
             CurrentEndTime)
            VALUES
            (@ConfigurationGroupID,
             @CurrentStartTime,
             @CurrentEndTime)

            SELECT @saveError = @@ERROR
            IF @saveError <> 0 GOTO QuitWithError

        END
        ELSE
        BEGIN

            UPDATE [dbo].[SMC_Meta_WarehouseTransformInfo]
            SET CurrentStartTime = @CurrentStartTime,
                CurrentEndTime = @CurrentEndTime
            WHERE ConfigurationGroupID = @ConfigurationGroupID

            SELECT @saveError = @@ERROR
            IF @saveError <> 0 GOTO QuitWithError

        END

QuitWithError:

        RETURN @saveError

END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_UpsertCurrentStartTime @ConfigurationGroupID UNIQUEIDENTIFIER = NULL, @CurrentStartTime DATETIME = NULL
AS
BEGIN
        /**********************************************
        * Update the CurrentStartTime and set the     *
        * CurrentEndTime to NULL                      *
        ***********************************************/

        DECLARE @saveError INT
        DECLARE @ExistingCurrentStartTime DATETIME

        SET @saveError = 0

        SELECT @ExistingCurrentStartTime = WTI.CurrentStartTime
        FROM [dbo].[SMC_Meta_WarehouseTransformInfo] AS WTI
        WHERE WTI.ConfigurationGroupID = @ConfigurationGroupID

        SELECT @saveError = @@ERROR
        IF @saveError <> 0 GOTO QuitWithError

        IF @ExistingCurrentStartTime IS NULL
        BEGIN

            INSERT INTO [dbo].[SMC_Meta_WarehouseTransformInfo]
            (ConfigurationGroupID,
             CurrentStartTime,
             CurrentEndTime)
            VALUES
            (@ConfigurationGroupID,
             @CurrentStartTime,
             NULL)

            SELECT @saveError = @@ERROR
            IF @saveError <> 0 GOTO QuitWithError

        END
        ELSE
        BEGIN

            UPDATE [dbo].[SMC_Meta_WarehouseTransformInfo]
            SET CurrentStartTime = @CurrentStartTime,
                CurrentEndTime = NULL
            WHERE ConfigurationGroupID = @ConfigurationGroupID

            SELECT @saveError = @@ERROR
            IF @saveError <> 0 GOTO QuitWithError

        END

QuitWithError:

        RETURN @saveError

END
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_CheckExistsObject @ObjectName nvarchar(256), @ObjectType nvarchar(30)
AS
BEGIN
 SET NOCOUNT ON
 DECLARE @xtype char(2), @id int, @retval int

 -- Quietly return if null object name passed in.   There might be some view names, udf names, etc.
 -- which are null if not applicable to a given class or relationship.
 IF @ObjectName IS NULL
  RETURN 0
 SELECT @xtype = xtype, @id = id FROM dbo.sysobjects WHERE id = OBJECT_ID(@ObjectName)
 IF @xtype IS NULL
  RETURN 0

 SET @retval = 
         CASE 
           WHEN @ObjectType = 'TABLE' AND OBJECTPROPERTY(@id, 'IsUserTable') = 1 THEN 1
           WHEN @ObjectType = 'VIEW' AND OBJECTPROPERTY(@id, 'IsView') = 1 THEN 1
           WHEN @ObjectType = 'TRIGGER' AND OBJECTPROPERTY(@id, 'IsTrigger') = 1 THEN 1
           WHEN @ObjectType = 'FUNCTION' AND @xtype IN ('FN', 'IF', 'TF') THEN 1
           WHEN @ObjectType = 'PROCEDURE' AND OBJECTPROPERTY(@id, 'IsProcedure') = 1 THEN 1
           ELSE 0
  END

 RETURN @retval
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_InsertClassIndex @ClassID uniqueidentifier,
  @ClassIndexID uniqueidentifier,
  @IndexName nvarchar(128),
  @FileGroupID uniqueidentifier = NULL,
  @FileGroupName nvarchar(128) = NULL,
  @IsUnique bit = 0,
  @IsClustered bit = 0,
  @FillFactor smallint = 0,
  @System bit = 0
AS
BEGIN
 SET NOCOUNT ON
 
 -- If filegroup was passed in by name, get the ID
 IF @FileGroupID IS NULL AND @FileGroupName IS NOT NULL
  SELECT @FileGroupID = FileGroupID FROM dbo.SMC_Meta_FileGroups WHERE [Name] = @FileGroupName

 IF EXISTS (SELECT * FROM dbo.SMC_Meta_ClassIndexes WHERE ClassIndexID = @ClassIndexID AND ClassID = @ClassID)
  RETURN 0
 
 -- Now insert the row
 INSERT INTO dbo.SMC_Meta_ClassIndexes (ClassID, ClassIndexID, IndexName, FileGroupID, [Unique], [Clustered], [FillFactor], [System]) 
  VALUES (@ClassID, @ClassIndexID, @IndexName, @FileGroupID,
   @IsUnique, @IsClustered, @FillFactor, @System) 
 
 RETURN 0
  
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_InsertClassIndexColumn @ClassIndexID uniqueidentifier,
  @ClassPropertyID uniqueidentifier = NULL,
  @ClassPropertyName nvarchar(128) = NULL,
                @Order int,
  @IsAscending bit = 0,
  @System bit = 0
AS
BEGIN
 SET NOCOUNT ON
 
 -- If property type was passed in by name, get the ID
 IF @ClassPropertyID IS NULL AND @ClassPropertyName IS NOT NULL
  SELECT @ClassPropertyID = ClassPropertyID FROM dbo.SMC_Meta_ClassProperties WHERE PropertyName = @ClassPropertyName

 IF EXISTS (SELECT * FROM dbo.SMC_Meta_ClassIndexesColumns WHERE ClassIndexID = @ClassIndexID AND [Order] = @Order)
  RETURN 0

  
 -- Now insert the row
 INSERT INTO dbo.SMC_Meta_ClassIndexesColumns (ClassIndexID, ClassPropertyID, [Order], [Ascending], [System])
  VALUES (@ClassIndexID, @ClassPropertyID, @Order, @IsAscending, @System)
 
 RETURN 0
  
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_InsertClassProperty @ClassID uniqueidentifier,
  @ClassPropertyID uniqueidentifier,
  @PropertyTypeID uniqueidentifier = NULL,
  @PropertyTypeName nvarchar(128) = NULL,
  @PropertyName nvarchar(128),
  @PrimaryKey bit = 0,
  @Nullable bit = 0,
  @Description nvarchar(256),
  @DefaultValue nvarchar(512) = NULL,
  @IsInherited bit = 0,
  @System bit = 0,
  @IsIdentity bit = 0
AS
BEGIN
 SET NOCOUNT ON
 
 -- If property type was passed in by name, get the ID
 IF @PropertyTypeID IS NULL AND @PropertyTypeName IS NOT NULL
  SELECT @PropertyTypeID =TypeID FROM dbo.SMC_Meta_PropertyTypes WHERE TypeName = @PropertyTypeName

 IF EXISTS (SELECT * FROM dbo.SMC_Meta_ClassProperties WHERE ClassPropertyID = @ClassPropertyID AND ClassID = @ClassID)
  RETURN 0

 -- SMC_InstanceID has already been inserted; when we are passed that one just update it
 IF (@PropertyName IN  ('SMC_InstanceID' , 'SMC_GroupDescription', 'SMC_GroupQuery', 'SMC_GroupName'))
  BEGIN
  UPDATE dbo.SMC_Meta_ClassProperties SET ClassPropertyID = @ClassPropertyID, Description = @Description, PrimaryKey = @PrimaryKey,
   IsIdentity = @IsIdentity, PropertyTypeID = @PropertyTypeID
   WHERE ClassID = @ClassID AND PropertyName = @PropertyName
  RETURN 0
  END
  
 -- Now insert the row
 INSERT INTO dbo.SMC_Meta_ClassProperties (ClassID, ClassPropertyID, PropertyTypeID,  PropertyName, PrimaryKey,
   Nullable, Description, DefaultValue, IsInherited, System, IsIdentity) 
  VALUES (@ClassID, @ClassPropertyID, @PropertyTypeID, @PropertyName, @PrimaryKey,
   @Nullable, @Description, @DefaultValue, @IsInherited, @System, @IsIdentity) 
 
 RETURN 0
  
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_InsertClassSchema @ClassID uniqueidentifier,
  @ClassName nvarchar(128),
  @IsGroup bit = 0,
  @Description nvarchar(256),
  @ParentClassID uniqueidentifier = NULL,
  @ParentClassName nvarchar(128) = NULL,
  @Signed bit = 0,
  @ValidateRow nvarchar(128) = NULL,
  @ValidateTable nvarchar(128) = NULL,
  @InheritsFromClassID uniqueidentifier = NULL,
  @InheritsFromClassName nvarchar(128) = NULL,
  @ViewName nvarchar(128) = NULL,
  @TableName nvarchar(128) = NULL,
  @HistoryTableName nvarchar(128) = NULL,
  @HistoryUDFName nvarchar(128) = NULL,
  @HistoryViewName nvarchar(128) = NULL,
  @IsHighVolume bit = 0,
  @SupportsPartitions bit = 0,
  @GenerateView bit = 0,
  @GenerateHistory bit = 0,
  @InsertViewName nvarchar(128) = NULL
AS
BEGIN
 SET NOCOUNT ON
 
 IF EXISTS (SELECT * FROM dbo.SMC_Meta_ClassSchemas WHERE ClassID = @ClassID)
  RETURN 0

 -- If parent or inherits from was passed in by name, get the ID
 IF @ParentClassID IS NULL AND @ParentClassName IS NOT NULL
  SELECT @ParentClassID = ClassID FROM dbo.SMC_Meta_ClassSchemas WHERE ClassName = @ParentClassName
 IF @InheritsFromClassID IS NULL AND @InheritsFromClassName IS NOT NULL
  SELECT @InheritsFromClassID = ClassID FROM dbo.SMC_Meta_ClassSchemas WHERE ClassName = @InheritsFromClassName

 -- Now insert the row
 INSERT INTO dbo.SMC_Meta_ClassSchemas (ClassID, ClassName, IsGroup, Description, ParentClassID,
   Signed, SP_ValidateRow, SP_ValidateTable, InheritsFrom, ViewName, TableName, HistoryTableName,
   HistoryUDFName, HistoryViewName, IsHighVolume, SupportsPartitions, GenerateView,
   GenerateHistory, InsertViewName) 
  VALUES (@ClassID, @ClassName, @IsGroup, @Description, @ParentClassID, @Signed, @ValidateRow,
   @ValidateTable, @InheritsFromClassID, @ViewName, @TableName, @HistoryTableName,
   @HistoryUDFName, @HistoryViewName, @IsHighVolume, @SupportsPartitions, @GenerateView,
   @GenerateHistory, @InsertViewName)
 
 RETURN 0
  
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_InsertFileGroup @FileGroupID uniqueidentifier = NULL,
 @FileGroupName nvarchar(128)
 
AS
BEGIN

 SET NOCOUNT ON

 IF EXISTS (SELECT * FROM dbo.SMC_Meta_FileGroups WHERE [Name] = @FileGroupName) 
  RETURN 0

 IF EXISTS (SELECT * FROM dbo.SMC_Meta_FileGroups WHERE FileGroupID = @FileGroupID)
  RETURN 0

 IF @FileGroupID IS NULL
  SET @FileGroupID = newid()
  
 INSERT INTO dbo.SMC_Meta_FileGroups (FileGroupID, [Name]) 
  VALUES (@FileGroupID, @FileGroupName)
 RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_InsertFunctionParameter  @PropertyTypeID uniqueidentifier,
 @ValidationUDFID uniqueidentifier,
 @ParamName nvarchar(128),
 @Value nvarchar(512) = NULL
AS
BEGIN
 SET NOCOUNT ON
 
 IF EXISTS (SELECT * FROM dbo.SMC_Meta_ValidationUDFParameterValues WHERE ValidationUDFID = @ValidationUDFID AND
   PropertyTypeID = @PropertyTypeID AND ParamName = @ParamName)
  RETURN 0


 INSERT INTO dbo.SMC_Meta_ValidationUDFParameterValues (PropertyTypeID, ValidationUDFID, ParamName, Value) 
  VALUES (@PropertyTypeID, @ValidationUDFID, @ParamName, @Value)

 RETURN 0
  
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_InsertProductSchema 
  @ProductID uniqueidentifier,
  @ProductName nvarchar(128),
  @Description nvarchar(256),
  @PostDTSTransferSP nvarchar(256) = NULL
AS
BEGIN
 SET NOCOUNT ON
 
 IF EXISTS (SELECT * FROM dbo.SMC_Meta_ProductSchema WHERE ProductID = @ProductID)
  RETURN 0

 -- Now insert the row
 INSERT INTO dbo.SMC_Meta_ProductSchema (ProductID, ProductName, Description, PostDTSTransferSP) 
  VALUES (@ProductID, @ProductName, @Description, @PostDTSTransferSP) 
 RETURN 0
  
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_InsertPropertyType @TypeID uniqueidentifier = NULL,
 @TypeName nvarchar(128),
 @DataType nvarchar(128) = NULL,
 @Length int = 0,
 @Scale int = 0,
 @Precision int = 0,
 @UDFValidationID uniqueidentifier = NULL,
 @Description nvarchar(256),
 @ParentTypeID uniqueidentifier = NULL,
 @ParentTypeName nvarchar(128) = NULL,
 @IsEnumeration bit = 0,
 @System bit = 0,
 @Signed bit = 0
 
AS
BEGIN

 SET NOCOUNT ON
 DECLARE @DatatypeID int

 IF EXISTS (SELECT * FROM dbo.SMC_Meta_PropertyTypes WHERE TypeName = @TypeName)
  RETURN 0

 IF EXISTS (SELECT * FROM dbo.SMC_Meta_PropertyTypes WHERE TypeID = @TypeID)
  RETURN 0

 SELECT @DatatypeID = DatatypeID FROM dbo.SMC_Meta_DatatypeDefinitions WHERE Name = @DataType
 IF @TypeID IS NULL
  SET @TypeID = newid()
  
 IF @ParentTypeID IS NULL AND @ParentTypeName IS NOT NULL
  SELECT @ParentTypeID = TypeID FROM dbo.SMC_Meta_PropertyTypes WHERE TypeName = @ParentTypeName

 INSERT INTO dbo.SMC_Meta_PropertyTypes (TypeID, TypeName, DatatypeID, Length, Scale, [Precision], UDFValidationID, Description, 
   ParentTypeID, IsEnumeration, System, Signed) 
  VALUES (@TypeID, @TypeName, @DatatypeID, @Length, @Scale, @Precision, @UDFValidationID, @Description, 
   @ParentTypeID, @IsEnumeration, @System, @Signed)
 RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_InsertRelationshipConstraint  @ConstraintID uniqueidentifier = NULL,
 @RelationshipTypeID uniqueidentifier,
 @SourceClassID uniqueidentifier = NULL,
 @SourceClassName nvarchar(128) = NULL,
 @TargetClassID uniqueidentifier = NULL,
 @TargetClassName nvarchar(128) = NULL,
 @TargetFK uniqueidentifier = NULL
AS
BEGIN

 SET NOCOUNT ON

 IF EXISTS (SELECT * FROM dbo.SMC_Meta_RelationshipConstraints WHERE ConstraintID = @ConstraintID)
  RETURN 0

 -- This exists so that the SMCViewer can call the same SP when it is inserting a relationship constraint.
 IF @ConstraintID IS NULL
  SET @ConstraintID = newid()
  
 IF @SourceClassID IS NULL 
  SELECT @SourceClassID = ClassID FROM dbo.SMC_Meta_ClassSchemas WHERE ClassName = @SourceClassName

 IF @TargetClassID IS NULL 
  SELECT @TargetClassID = ClassID FROM dbo.SMC_Meta_ClassSchemas WHERE ClassName = @TargetClassName
  
 INSERT INTO dbo.SMC_Meta_RelationshipConstraints (ConstraintID, RelationshipTypeID, SourceClassID, TargetClassID, TargetFK) 
  VALUES  (@ConstraintID, @RelationshipTypeID, @SourceClassID, @TargetClassID, @TargetFK) 
 RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_InsertRelationshipType @RelationshipTypeID uniqueidentifier,
 @Name nvarchar(128),
 @Description nvarchar(128) = '',
 @ViewSrcName nvarchar(128),
 @ViewTargetName nvarchar(128),
 @ViewName nvarchar(128) = NULL,
 @HistoryViewName nvarchar(128) = NULL,
 @HistoryUDFName nvarchar(128) = NULL,
 @Cardinality nvarchar(10) = 'M:N',
 @IsConstrained bit = 0,
 @MustBeDeleted bit = 0,
 @AllowMultipleConstraints bit = 0,
 @IsHighVolume bit = 0,
 @NotifyOnInsert bit = 0,
 @NotifyOnUpdate bit = 0,
 @NotifyOnDelete bit = 0 
AS
BEGIN

 SET NOCOUNT ON

 IF EXISTS (SELECT * FROM dbo.SMC_Meta_RelationshipTypes WHERE RelationshipTypeID = @RelationshipTypeID)
  RETURN 0

 INSERT INTO dbo.SMC_Meta_RelationshipTypes (RelationshipTypeID, Name, Description, ViewSrcName,
  ViewTargetName, ViewName, HistoryViewName, HistoryUDFName, Cardinality, IsConstrained,
  MustBeDeleted, AllowMultipleConstraints, IsHighVolume, NotifyOnInsert, NotifyOnUpdate, NotifyOnDelete) 
  VALUES (@RelationshipTypeID, @Name, @Description, @ViewSrcName,
  @ViewTargetName, @ViewName, @HistoryViewName, @HistoryUDFName, @Cardinality, @IsConstrained,
  @MustBeDeleted, @AllowMultipleConstraints, @IsHighVolume, @NotifyOnInsert, @NotifyOnUpdate, @NotifyOnDelete)
 RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_InsertWarehouseClassProperty 
  @ClassPropertyID uniqueidentifier,
  @IsFilterColumn bit = 0,
  @IsGroomColumn bit = 0,
  @ColumnLevelTransform ntext = null
AS
BEGIN
 SET NOCOUNT ON
 
 IF EXISTS (SELECT * FROM dbo.SMC_Meta_WarehouseClassProperty WHERE ClassPropertyID = @ClassPropertyID)
  RETURN 0

 -- Now insert the row
 INSERT INTO dbo.SMC_Meta_WarehouseClassProperty (ClassPropertyID, IsFilterColumn, IsGroomColumn, ColumnLevelTransform) 
  VALUES (@ClassPropertyID, @IsFilterColumn, @IsGroomColumn, @ColumnLevelTransform) 
 RETURN 0
  
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_InsertWarehouseClassSchema 
  @ClassID uniqueidentifier,
  @WarehouseTableType int = 0,
  @DimensionType int = 0,
  @FactType int = 0,
  @TableTransformOrder int = 0,
  @MustBeGroomed bit = 0,
  @GroomDays int = 0
AS
BEGIN
 SET NOCOUNT ON
 
 IF EXISTS (SELECT * FROM dbo.SMC_Meta_WarehouseClassSchema WHERE ClassID = @ClassID)
  RETURN 0

 -- Now insert the row
 INSERT INTO dbo.SMC_Meta_WarehouseClassSchema (ClassID, WarehouseTableType, DimensionType, FactType, TableTransformOrder, MustBeGroomed, GroomDays) 
  VALUES (@ClassID, @WarehouseTableType, @DimensionType, @FactType, @TableTransformOrder, @MustBeGroomed, @GroomDays) 
 RETURN 0
  
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_InsertWarehouseClassSchemaToProductSchema 
  @ClassID uniqueidentifier,
  @ProductID uniqueidentifier,
  @SourceQuery ntext = null,
        @LowWatermarkFromSourceQuery ntext = null
AS
BEGIN
 SET NOCOUNT ON
 
 IF EXISTS (SELECT * FROM dbo.SMC_Meta_WarehouseClassSchemaToProductSchema WHERE ClassID = @ClassID AND ProductID = @ProductID)
  RETURN 0

 -- Now insert the row
 INSERT INTO dbo.SMC_Meta_WarehouseClassSchemaToProductSchema (ClassID, ProductID, SourceQuery, LowWatermarkFromSourceQuery) 
  VALUES (@ClassID, @ProductID, @SourceQuery, @LowWatermarkFromSourceQuery) 
 RETURN 0
  
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_InsertWarehouseGroomingInfo 
  @ClassID uniqueidentifier,
  @EndTime datetime,
  @StartTime datetime
AS
BEGIN
 SET NOCOUNT ON
 
 IF EXISTS (SELECT * FROM dbo.SMC_Meta_WarehouseGroomingInfo WHERE ClassID = @ClassID)
  RETURN 0

 -- Now insert the row
 INSERT INTO dbo.SMC_Meta_WarehouseGroomingInfo (ClassID, EndTime, StartTime) 
  VALUES (@ClassID, @EndTime, @StartTime) 
 RETURN 0
  
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_dropobject @ObjectName nvarchar(256), @ObjectType nvarchar(30)
AS
BEGIN
 SET NOCOUNT ON

 -- Quietly return if null object name passed in.   There might be some view names, udf names, etc.
 -- which are null if not applicable to a given class or relationship.
 IF @ObjectName IS NULL
  RETURN

 DECLARE @sqlcommand nvarchar(4000), @sqlpropclause nvarchar(1000)

 SET   @sqlpropclause = 
        CASE @ObjectType
           WHEN 'TABLE' THEN 'OBJECTPROPERTY(id, N''IsUserTable'') = 1'
           WHEN 'VIEW' THEN 'OBJECTPROPERTY(id, N''IsView'') = 1'
           WHEN 'TRIGGER' THEN 'OBJECTPROPERTY(id, N''IsTrigger'') = 1'
           WHEN 'FUNCTION' THEN  'xtype in (N''FN'', N''IF'', N''TF'')'
           ELSE 'id = id'
  END
 SET @sqlcommand = 'IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID (''' + @ObjectName + ''')  AND ' + 
   @sqlpropclause + ' )
    BEGIN
     DROP ' + @ObjectType + ' ' + @ObjectName + '
    END'
 EXEC  dbo.sp_executesql @sqlcommand
 

END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_insertenumeration @EnumID uniqueidentifier,
 @PropertyTypeID uniqueidentifier,
 @Value int,
 @Description nvarchar(256)
AS
BEGIN
 SET NOCOUNT ON
 
 IF EXISTS (SELECT * FROM dbo.SMC_Meta_PropertyTypeEnumerations WHERE EnumerationID = @EnumID)
  RETURN


 INSERT INTO dbo.SMC_Meta_PropertyTypeEnumerations (EnumerationID, PropertyTypeID, EnumerationValue, Description) 
  VALUES (@EnumID, @PropertyTypeID, @Value, @Description)
  
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE   PROCEDURE dbo.smc_instance_info
(
 @instanceid as uniqueidentifier -- id for which we want information
)
AS
BEGIN
 SET NOCOUNT ON

 SELECT
  PS.PS_PropertyName  AS PropertyName, 
  PI.PI_Value   AS PropertyValue
 FROM
  dbo.PropertyInstances PI, 
  dbo.PropertySchemas PS
 WHERE  PI.PI_InstanceID = @instanceid
 AND  PI.PI_PropertyID = PS.PS_PropertyID

END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_internal_IsValidClassSPValidator 
(
  @spName AS NVARCHAR(200), -- stored procedure name
 @isOK AS BIT OUTPUT   -- 1 sp ok, 0 if not ok
)
AS
BEGIN
 SET NOCOUNT ON

 SET @isOK = 0

 DECLARE @numRows AS INTEGER 

 -- first count the number of parameters, and ensure that the return value is 'bit'
  -- the number of parameters need to be exactly one
 SELECT @numRows = COUNT(*)
 FROM INFORMATION_SCHEMA.ROUTINES   R,
      INFORMATION_SCHEMA.PARAMETERS P
 WHERE R.SPECIFIC_NAME = P.SPECIFIC_NAME
 AND   R.ROUTINE_TYPE  = 'PROCEDURE'
 AND   P.IS_RESULT     = 'NO'
 AND   R.SPECIFIC_NAME = @spName

 IF (@numRows = 1)
 BEGIN
  -- We know that there is only one parameter. Now ensure that it has the correct datatype
  SELECT @numRows = COUNT(*)
  FROM INFORMATION_SCHEMA.ROUTINES   R,
       INFORMATION_SCHEMA.PARAMETERS P
  WHERE R.SPECIFIC_NAME  = P.SPECIFIC_NAME
  AND   R.ROUTINE_TYPE   = 'PROCEDURE'
  AND   P.IS_RESULT      = 'NO'
  AND   R.SPECIFIC_NAME  = @spName
  AND   P.PARAMETER_MODE = 'INOUT'
  AND   P.DATA_TYPE      = 'bit'
  
  IF (@numRows = 1)
  BEGIN
   SET @isOK = 1
  END
 END
 
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_internal_IsValidPropertyValidator 
(
  @udfname AS NVARCHAR(200), 
 @paramtype AS NVARCHAR(50), 
 @isOK AS BIT OUTPUT
)
AS
BEGIN
 SET NOCOUNT ON

 SET @isOK = 0

 DECLARE @numRows AS INTEGER 

 -- first count the number of parameters, and ensure that the return value is 'bit'
  -- the number of parameters need to be exactly one
 SELECT @numRows = count(*)
 FROM information_schema.routines R,
      information_schema.parameters P
 WHERE R.specific_name = P.specific_name
 AND   R.routine_type = 'FUNCTION'
 AND   P.IS_RESULT = 'NO'
 AND   R.specific_name = @udfname
 AND   R.DATA_TYPE = 'bit'

 IF (@numRows = 1)
 BEGIN
  -- We know that there is only one parameter. Now ensure that it has the correct datatype
  SELECT @numRows = count(*)
  FROM information_schema.routines R,
       information_schema.parameters P
  WHERE R.specific_name = P.specific_name
  AND   R.routine_type = 'FUNCTION'
  AND   P.IS_RESULT = 'NO'
  AND   R.specific_name = @udfname
  AND   R.DATA_TYPE = 'bit'
  AND   P.DATA_TYPE = @paramtype
  
  IF (@numRows = 1)
  BEGIN
   SET @isOK = 1
  END
 END
 
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_internal_alter_insertview
( 
 @viewName as nvarchar(128),
 @tableName as nvarchar(128)
)
AS
BEGIN

 SET NOCOUNT ON

 DECLARE @command nvarchar(2048)
 DECLARE @ret int


 SET @command = N'ALTER VIEW [dbo].' + QUOTENAME(@viewName) + N' AS SELECT * FROM [dbo].' + QUOTENAME(@tableName)
 PRINT 'Executing command ' + @command
 EXEC @ret = dbo.sp_executesql @command

 RETURN @ret
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_internal_truncatetable
(
 @tableName as nvarchar(128)
)
AS
BEGIN
 SET NOCOUNT ON
 
 DECLARE @command as nvarchar(512)
 DECLARE @ret int

                    
 SET @command = N'IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N''[dbo].' + QUOTENAME(@tableName) + ''') AND OBJECTPROPERTY(id, N''IsUserTable'') = 1) TRUNCATE TABLE [dbo].' + QUOTENAME(@tableName)

 EXEC @ret = dbo.sp_executesql @command

 RETURN @ret
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_partitioning
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @classID as uniqueidentifier
    
    DECLARE @errResult AS integer
    DECLARE @errMsg AS nvarchar(400)
    DECLARE @severity AS int
    DECLARE @msgID AS int
    DECLARE @className as nvarchar(128)

    SET @errResult = 0

    DECLARE cur CURSOR LOCAL FOR
        SELECT ClassID, ClassName 
        FROM dbo.SMC_Meta_ClassSchemas 
        WHERE SupportsPartitions = 1

    OPEN cur

    FETCH NEXT FROM cur INTO @classID, @className

    WHILE @@FETCH_STATUS = 0
    BEGIN

 PRINT 'Partitioning class ' + CONVERT(nvarchar(128), @classID)

        EXEC @errResult = dbo.smc_partition_class @classID

        IF (@errResult <> 0)
 BEGIN
     EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_PARTITIONING_JOB_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1, @className)
            -- Should keep going for the others?
    END

 FETCH NEXT FROM cur INTO @classID, @className

    END

 
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smo_InsertCSharpAssembly @AssemblyID uniqueidentifier,
 @Name nvarchar(128),
 @Version nvarchar(46),
 @Culture nvarchar(128),
 @PublicKeyToken nvarchar(32)
 
AS
BEGIN

 SET NOCOUNT ON

 IF EXISTS (SELECT * FROM dbo.SMO_Meta_CSharpAssemblies WHERE AssemblyID =  @AssemblyID)
  RETURN 0

 INSERT INTO dbo.SMO_Meta_CSharpAssemblies (AssemblyID, Name, Version, Culture, PublicKeyToken)  
  VALUES (@AssemblyID, @Name, @Version, @Culture, @PublicKeyToken)
 RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smo_InsertCSharpType @CSharpTypeID uniqueidentifier,
 @Name nvarchar(128),
 @Description nvarchar(256),
 @AssemblyID uniqueidentifier = NULL,
 @AssemblyName nvarchar(128) = NULL
AS
BEGIN

 SET NOCOUNT ON

 IF EXISTS (SELECT * FROM dbo.SMO_Meta_CSharpTypes WHERE CSharpTypeID =  @CSharpTypeID)
  RETURN 0

 IF @AssemblyID IS NULL
  SELECT @AssemblyID = AssemblyID FROM dbo.SMO_Meta_CSharpAssemblies WHERE Name = @AssemblyName
  
 INSERT INTO dbo.SMO_Meta_CSharpTypes (CSharpTypeID, Name, Description, AssemblyID)  
  VALUES (@CSharpTypeID, @Name, @Description, @AssemblyID)
 RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smo_InsertClassMethod   @SMOClassID uniqueidentifier,
  @SMOClassMethodID uniqueidentifier,
  @ClientSideProxyName nvarchar(128),
  @ServerSideAssembly nvarchar(128),
  @ServerSideClass nvarchar(128),
  @ServerSideMethod nvarchar(128)
  
AS
BEGIN

 SET NOCOUNT ON

 IF EXISTS (SELECT * FROM dbo.SMO_Meta_ClassMethods WHERE SMOClassMethodID =  @SMOClassMethodID)
  RETURN 0
  
 INSERT INTO dbo.SMO_Meta_ClassMethods (SMOClassID, SMOClassMethodID, ClientSideProxyName, ServerSideAssembly, 
  ServerSideClass, ServerSideMethod)  
  VALUES (@SMOClassID, @SMOClassMethodID, @ClientSideProxyName, @ServerSideAssembly, 
  @ServerSideClass, @ServerSideMethod)   
 RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smo_InsertClassProperty   @SMOClassID uniqueidentifier,
  @SMOClassPropertyID uniqueidentifier,
  @SMOClassSMCClassID uniqueidentifier = NULL,
  @SMCClassPropertyID uniqueidentifier = NULL,
  @SMCClassPropertyName nvarchar(128) = NULL,
  @Name nvarchar(128),
  @Description nvarchar(256),
  @CSharpTypeID  uniqueidentifier = NULL,
  @CSharpTypeName nvarchar(128) = NULL,
  @Hidden bit = 0
  
AS
BEGIN

 SET NOCOUNT ON

 IF EXISTS (SELECT * FROM dbo.SMO_Meta_ClassProperties WHERE SMOClassPropertyID =  @SMOClassPropertyID)
  RETURN 0

 IF @SMCClassPropertyID IS NULL AND @SMCClassPropertyName IS NOT NULL
  SELECT @SMCClassPropertyID = ClassPropertyID FROM dbo.SMC_Meta_ClassProperties WHERE PropertyName = @SMCClassPropertyName

 IF @CSharpTypeID IS NULL AND @CSharpTypeName IS NOT NULL
  SELECT @CSharpTypeID = CSharpTypeID FROM dbo.SMO_Meta_CSharpTypes WHERE Name = @CSharpTypeName
  
 INSERT INTO dbo.SMO_Meta_ClassProperties (SMOClassID, SMOClassPropertyID, SMOClassSMCClassID, SMCClassPropertyID, Name,
  Description, CSharpTypeID, Hidden)  
  VALUES (@SMOClassID, @SMOClassPropertyID, @SMOClassSMCClassID, @SMCClassPropertyID, @Name,
  @Description, @CSharpTypeID, @Hidden)  
 RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smo_InsertClassSchema @SMOClassID uniqueidentifier,
  @CSharpClassTypeName nvarchar(128),
  @CSharpAssemblyID uniqueidentifier = NULL,
  @CSharpAssemblyName  nvarchar(128) = NULL,
  @ViewName nvarchar(128),
  @Description nvarchar(128)
AS
BEGIN

 SET NOCOUNT ON

 IF EXISTS (SELECT * FROM dbo.SMO_Meta_ClassSchemas WHERE SMOClassID =  @SMOClassID)
  RETURN 0

 IF @CSharpAssemblyID IS NULL
  SELECT @CSharpAssemblyID = AssemblyID FROM dbo.SMC_Meta_CSharpAssemblies WHERE Name = @CSharpAssemblyName
  
 INSERT INTO dbo.SMO_Meta_ClassSchemas (SMOClassID, CSharpClassTypeName, CSharpAssemblyID, ViewName, Description)  
  VALUES (@SMOClassID, @CSharpClassTypeName, @CSharpAssemblyID, @ViewName, @Description) 
 RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smo_InsertRelationshipType @SMORelationshipTypeID uniqueidentifier,
  @SMCRelationshipTypeID uniqueidentifier = NULL,
  @SMCRelationshipTypeName nvarchar(128) = NULL,
  @Name nvarchar(128),
  @Description nvarchar(256),
  @SourceCSharpPropertyName nvarchar(128),
  @TargetCSharpPropertyName nvarchar(128)
AS
BEGIN

 SET NOCOUNT ON

 IF EXISTS (SELECT * FROM dbo.SMO_Meta_RelationshipTypes WHERE SMORelationshipTypeID =  @SMORelationshipTypeID)
  RETURN 0

 IF @SMCRelationshipTypeID IS NULL AND @SMCRelationshipTypeName IS NOT NULL
  SELECT @SMCRelationshipTypeID = RelationshipTypeID FROM dbo.SMC_Meta_RelationshipTypes WHERE Name = @SMCRelationshipTypeName
  
 INSERT INTO dbo.SMO_Meta_RelationshipTypes (SMORelationshipTypeID, SMCRelationshipTypeID, Name, 
   Description, SourceCSharpPropertyName, TargetCSharpPropertyName)  
  VALUES  (@SMORelationshipTypeID, @SMCRelationshipTypeID, @Name, 
   @Description, @SourceCSharpPropertyName, @TargetCSharpPropertyName) 
 RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smo_InsertSMCClass @SMOClassID uniqueidentifier,
  @SMOClassSMCClassID uniqueidentifier,
  @SMCClassID uniqueidentifier = NULL,
  @SMCClassName  nvarchar(128) = NULL,
  @IsPrimary bit = 0,
  @IsUsedInRelationships bit = 0
AS
BEGIN

 SET NOCOUNT ON

 IF EXISTS (SELECT * FROM dbo.SMO_Meta_ClassSMCClasses WHERE SMOClassSMCClassID =  @SMOClassSMCClassID)
  RETURN 0

 IF @SMCClassID IS NULL
  SELECT @SMCClassID = ClassID FROM dbo.SMC_Meta_ClassSchemas WHERE ClassName = @SMCClassName
  
 INSERT INTO dbo.SMO_Meta_ClassSMCClasses (SMOClassID, SMOClassSMCClassID, SMCClassID, IsPrimary, IsUsedInRelationships)  
  VALUES (@SMOClassID, @SMOClassSMCClassID, @SMCClassID, @IsPrimary, @IsUsedInRelationships) 
 RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smo_InsertSMCClassJoin @SourceSMOClassSMCClassID uniqueidentifier,
  @TargetSMOClassSMCClassID uniqueidentifier,
  @SMCRelationshipTypeID uniqueidentifier = NULL,
  @SMCRelationshipTypeName  nvarchar(128) = NULL
AS
BEGIN

 SET NOCOUNT ON

 IF EXISTS (SELECT * FROM dbo.SMO_Meta_ClassSMCClassJoins WHERE SourceSMOClassSMCClassID =  @SourceSMOClassSMCClassID AND
    TargetSMOClassSMCClassID = @TargetSMOClassSMCClassID)
  RETURN 0

 IF @SMCRelationshipTypeID IS NULL
  SELECT @SMCRelationshipTypeID = RelationshipTypeID FROM dbo.SMC_Meta_RelationshipTypes WHERE Name = @SMCRelationshipTypeName
  
 INSERT INTO dbo.SMO_Meta_ClassSMCClassJoins (SourceSMOClassSMCClassID, TargetSMOClassSMCClassID, SMCRelationshipTypeID)  
  VALUES (@SourceSMOClassSMCClassID, @TargetSMOClassSMCClassID, @SMCRelationshipTypeID)
 RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smo_InsertTypeConversion @TypeConversionID uniqueidentifier,
  @CSharpTypeID uniqueidentifier,
  @SMCTypeID uniqueidentifier = NULL,
  @SMCTypeName nvarchar(128) = NULL,
  @ConversionClass uniqueidentifier
AS
BEGIN

 SET NOCOUNT ON

 IF EXISTS (SELECT * FROM dbo.SMO_Meta_TypeConversions WHERE TypeConversionID =  @TypeConversionID)
  RETURN 0

 IF @SMCTypeID IS NULL
  SELECT @SMCTypeID = TypeID FROM dbo.SMC_Meta_PropertyTypes WHERE TypeName = @SMCTypeName
  
 INSERT INTO dbo.SMO_Meta_TypeConversions (TypeConversionID, CSharpTypeID, SMCTypeID, ConversionClass)  
  VALUES (@TypeConversionID, @CSharpTypeID, @SMCTypeID, @ConversionClass)
 RETURN 0
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


CREATE TABLE dbo.ClassIndexes
(
    CI_ClassIndexID uniqueidentifier NOT NULL,
    CI_ClassID      uniqueidentifier NOT NULL,
    CI_IndexName    nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CI_Clustered    bit              CONSTRAINT DF_ClassIndexes_CI_Clustered DEFAULT 0 NOT NULL,
    CI_Unique       bit              CONSTRAINT DF_ClassIndexes_CI_Unique DEFAULT 0 NOT NULL,
    CI_FillFactor   smallint         CONSTRAINT DF_ClassIndexes_CI_FillFactor DEFAULT 0 NOT NULL,
    CI_FileGroupID  uniqueidentifier NULL,
    CI_System       bit              CONSTRAINT DF_ClassIndexes_CI_System DEFAULT 0 NOT NULL
)
go


INSERT INTO SCR.dbo.ClassIndexes
( CI_ClassIndexID,
  CI_ClassID,
  CI_IndexName,
  CI_Clustered,
  CI_Unique,
  CI_FillFactor,
  CI_FileGroupID,
  CI_System ) 
SELECT
CI_ClassIndexID,
CI_ClassID,
CI_IndexName,
CI_Clustered,
CI_Unique,
CI_FillFactor,
CI_FileGroupID,
CI_System
FROM SCR.dbo.ClassIndexes_21924dfd
go


CREATE NONCLUSTERED INDEX smc_idx_ClassIndex_ClassID
    ON dbo.ClassIndexes(CI_ClassID)
go


ALTER TABLE dbo.ClassIndexes
    ADD CONSTRAINT smc_pk_ClassIndexes
    PRIMARY KEY CLUSTERED (CI_ClassIndexID)
go


ALTER TABLE dbo.ClassIndexes
    ADD CONSTRAINT smc_idx_ClassIndexes_ClassID_IndexName_Unique
    UNIQUE NONCLUSTERED (CI_ClassID,CI_IndexName)
go


ALTER TABLE dbo.ClassIndexes
    WITH NOCHECK
    ADD CONSTRAINT smc_chk_ClassIndexes_FillFactor
    CHECK ([CI_FillFactor] >= 0 and [CI_FillFactor] <= 100)
go


CREATE TRIGGER dbo.triu_ClassIndexes_Validate on dbo.ClassIndexes
FOR INSERT, UPDATE
AS
BEGIN
 SET NOCOUNT ON

 PRINT N'FOR INSERT,UPDATE Trigger ' + OBJECT_NAME(@@PROCID) + N' firing'

 DECLARE @errMsg AS NVARCHAR(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int
 DECLARE @err AS int

 -- there can be only one clustered index per class
 IF (UPDATE (CI_Clustered))
 BEGIN
  IF EXISTS 
  (
   SELECT *
   FROM dbo.ClassIndexes CI
   WHERE CI_Clustered = 1
   GROUP BY CI_ClassID
   HAVING COUNT (*) > 1
  )
  BEGIN
   EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASSINDEXES_CLUSTERED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END 
 END

 -- all properties need to belong to the class for which the index is defined. If this
        -- is not the case, an error should be raised
 IF (UPDATE (CI_ClassID))
 BEGIN
  IF EXISTS 
  (
   SELECT *
   FROM dbo.ClassIndexes CI, 
        dbo.ClassIndexesColumns CIC,
        dbo.ClassProperties CP
   WHERE CI.CI_ClassIndexID = CIC.CIC_ClassIndexID
   AND CIC.CIC_ClassPropertyID = CP.CP_ClassPropertyID
   AND CI.CI_ClassID <> CP.CP_ClassID
  )
  BEGIN
   EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASSINDEXES_PROPS_IN_SAME_CLASS', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END 
 END
END
go


CREATE TRIGGER dbo.triud_ClassIndexes_Signed ON dbo.ClassIndexes
FOR INSERT, UPDATE, DELETE 
AS
BEGIN  

    SET NOCOUNT ON

    PRINT N'FOR INSERT, UPDATE, DELETE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

    IF EXISTS ( SELECT CS.CS_ClassID 
                FROM dbo.ClassSchemas AS CS 
                JOIN ( SELECT * FROM deleted UNION ALL
                       SELECT * FROM inserted) AS M
                ON CS.CS_ClassID = M.CI_ClassID
         WHERE CS.CS_Signed = 1 )
    BEGIN
        DECLARE @errResult AS integer
 DECLARE @errMsg AS nvarchar(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int

        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASSINDEXES_CANNOT_MODIFY_SIGNED_CLASS', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
 RAISERROR (@errMsg, @severity, 1)
 ROLLBACK TRANSACTION
 RETURN 
    END
END
go


CREATE TRIGGER dbo.triu_ClassIndexesColumns_Validate on dbo.ClassIndexesColumns
FOR INSERT, UPDATE
AS
BEGIN
 SET NOCOUNT ON

 PRINT N'FOR INSERT,UPDATE Trigger ' + OBJECT_NAME(@@PROCID) + N' firing'

 DECLARE @errMsg AS NVARCHAR(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int
 DECLARE @err AS int

 -- there can be only one clustered index per class
 -- all properties need to belong to the class for which the index is defined. If this
        -- is not the case, an error should be raised
 IF (UPDATE (CIC_ClassIndexID) OR UPDATE(CIC_ClassPropertyID))
 BEGIN
  IF EXISTS 
  (
   SELECT *
   FROM dbo.ClassIndexes CI, 
        dbo.ClassIndexesColumns CIC,
        dbo.ClassProperties CP
   WHERE CI.CI_ClassIndexID = CIC.CIC_ClassIndexID
   AND CIC.CIC_ClassPropertyID = CP.CP_ClassPropertyID
   AND CI.CI_ClassID <> CP.CP_ClassID
  )
  BEGIN
   EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASSINDEXES_PROPS_IN_SAME_CLASS', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END 
 END

 -- Indexes cannot be defined on blob columns
 IF (UPDATE (CIC_ClassPropertyID))
 BEGIN
  IF EXISTS
  (
   SELECT *
   FROM inserted I,
        dbo.ClassProperties CP,
        dbo.PropertyTypes PT,
        dbo.DatatypeDefinitions DD
   WHERE I.CIC_ClassPropertyID = CP.CP_ClassPropertyID
   AND   CP.CP_PropertyTypeID = PT.PT_TypeID
   AND   PT.PT_DatatypeID    = DD.DD_DatatypeID
   AND   DD.DD_IsBlob    = 1
  )
  BEGIN
   EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASSINDEXESCOLUMNS_NO_BLOB', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN

  END
 END
END
go


CREATE TRIGGER dbo.triud_ClassIndexesColumns_Signed ON dbo.ClassIndexesColumns
FOR INSERT, UPDATE, DELETE 
AS
BEGIN  

    SET NOCOUNT ON

    PRINT N'FOR INSERT, UPDATE, DELETE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

    IF EXISTS ( SELECT CS.CS_ClassID
         FROM dbo.ClassSchemas AS CS
         JOIN dbo.ClassIndexes AS CI
         ON CS.CS_ClassID = CI.CI_ClassID
         JOIN (SELECT * FROM deleted UNION ALL
                      SELECT * FROM inserted) AS M
          ON M.CIC_ClassIndexID = CI.CI_ClassIndexID
         WHERE CS.CS_Signed = 1 )
    BEGIN
 DECLARE @errResult AS integer
 DECLARE @errMsg AS nvarchar(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int

 EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASSINDEXESCOLUMNS_CANNOT_MODIFY_SIGNED_CLASS', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
 RAISERROR (@errMsg, @severity, 1)
 ROLLBACK TRANSACTION
 RETURN 
    END
END
go


CREATE TABLE dbo.ClassIndexesColumns
(
    CIC_ClassIndexID    uniqueidentifier NOT NULL,
    CIC_Order           int              NOT NULL,
    CIC_ClassPropertyID uniqueidentifier NOT NULL,
    CIC_Ascending       bit              CONSTRAINT DF_ClassIndexesColumns_CI_Ascending DEFAULT 1 NOT NULL,
    CIC_System          bit              CONSTRAINT DF_ClassIndexesColumns_CIC_System DEFAULT 0 NOT NULL
)
go


INSERT INTO SCR.dbo.ClassIndexesColumns
( CIC_ClassIndexID,
  CIC_Order,
  CIC_ClassPropertyID,
  CIC_Ascending,
  CIC_System ) 
SELECT
CIC_ClassIndexID,
CIC_Order,
CIC_ClassPropertyID,
CIC_Ascending,
CIC_System
FROM SCR.dbo.ClassIndexesColumns_4409022b
go


ALTER TABLE dbo.ClassIndexesColumns
    ADD CONSTRAINT smc_pk_ClassIndexesColumns
    PRIMARY KEY CLUSTERED (CIC_ClassIndexID,CIC_Order)
go


CREATE TABLE dbo.ClassInstances
(
    CI_InstanceID   uniqueidentifier CONSTRAINT DF_ClassInstances_CI_InstanceID DEFAULT newid() NOT NULL,
    CI_ClassID      uniqueidentifier NOT NULL,
    CI_FriendlyName nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CI_StartModID   bigint           NOT NULL
)
go


INSERT INTO SCR.dbo.ClassInstances
( CI_InstanceID,
  CI_ClassID,
  CI_FriendlyName,
  CI_StartModID ) 
SELECT
CI_InstanceID,
CI_ClassID,
CI_FriendlyName,
CI_StartModID
FROM SCR.dbo.ClassInstances_47eb57f2
go


ALTER TABLE dbo.ClassInstances
    ADD CONSTRAINT smc_pk_ClassInstances_InstanceID
    PRIMARY KEY CLUSTERED (CI_InstanceID)
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.SMC_GroupsForInstance
(
 @instanceID as uniqueidentifier,
 @groupClassID as uniqueidentifier = NULL,
 @recursive as bit = 1
)
RETURNS @groups TABLE ( SMC_InstanceID uniqueidentifier PRIMARY KEY, 
   SMC_ClassID uniqueidentifier, 
   lvl int)
WITH SCHEMABINDING
BEGIN
 DECLARE @rowCount as int
 DECLARE @lvl as int
 SET @lvl = 0

 INSERT INTO @groups (SMC_InstanceID, lvl) VALUES (@instanceID, @lvl)
 SET @rowCount = @@ROWCOUNT

 WHILE @rowCount > 0
 BEGIN
  SET @lvl = @lvl + 1

  INSERT INTO @groups (SMC_InstanceID, lvl)
  SELECT GM.GroupID, @lvl
  FROM dbo.SMC_GroupMembers GM, 
       @groups G
  WHERE G.lvl = @lvl - 1
  AND GM.MemberID = G.SMC_InstanceID
  AND GM.GroupID NOT IN (SELECT SMC_InstanceID FROM @groups)

  SET @rowCount = @@ROWCOUNT

  -- if we don't want recursion, jump out of the loop
  IF (@recursive = 0)
  BEGIN
   BREAK
  END 
 END

 -- delete the initial element that was passed in
 DELETE @groups 
 WHERE SMC_InstanceID = @instanceID

 -- we got all the instances, let's add the classID

 UPDATE G
 SET G.SMC_ClassID = CI.CI_ClassID
 FROM @groups G, dbo.ClassInstances CI
 WHERE G.SMC_InstanceID = CI.CI_InstanceID

 -- if we have a groupClassID, we have to filter out the instances that do not belong to this class
 IF (@groupClassID IS NOT NULL)
 BEGIN
  DELETE @groups 
  WHERE SMC_ClassID <> @groupClassID
 END

 RETURN
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.SMC_MembersInGroup
(
 @groupID as uniqueidentifier,    -- group id
 @classID as uniqueidentifier  = NULL,  -- only include instances that have this class id.
 @includeGroups as bit   = 1,  -- include groups in the result set
 @recursive as bit   = 1  -- if set to 0, only get direct children
)
RETURNS @members TABLE (SMC_InstanceID uniqueidentifier PRIMARY KEY, 
   SMC_ClassID uniqueidentifier, 
   lvl int)
WITH SCHEMABINDING
BEGIN
 DECLARE @rowCount int
 DECLARE @lvl int
 SET @lvl = 0

 INSERT INTO @members (SMC_InstanceID, lvl) VALUES (@groupID, @lvl)
 SET @rowCount = @@ROWCOUNT

 -- recursively add all the members.
 WHILE @rowCount > 0
 BEGIN
  SET @lvl = @lvl + 1

  INSERT INTO @members (SMC_InstanceID, lvl)
  SELECT GM.MemberID, @lvl
  FROM dbo.SMC_GroupMembers GM, 
       @members M
  WHERE M.lvl      = @lvl - 1
  AND   GM.GroupID = M.SMC_InstanceID
  AND   GM.Usage IN ('D', 'S')
  AND   GM.MemberID NOT IN 
   (SELECT SMC_InstanceID FROM @members)
  
  SET @rowCount = @@ROWCOUNT

  -- in case we don't want recursion, jump out the while loop
  IF (@recursive = 0)
  BEGIN
   BREAK
  END
 END

 -- delete the starting element, as we do not want that in the result set
 DELETE @members
 WHERE SMC_InstanceID = @groupID

 -- add the ClassID information
 UPDATE M
 SET M.SMC_ClassID = CI.CI_ClassID
 FROM @members M, dbo.ClassInstances CI
 WHERE M.SMC_InstanceID = CI.CI_InstanceID

 -- exclude classes that don't have the given class ID when the @classID flag is set
 IF (@classID IS NOT NULL)
 BEGIN
  DELETE @members
  WHERE SMC_ClassID <> @classID
 END

 -- exclude groups when the @includeGroups flag is set to 0
 IF (@includeGroups = 0)
 BEGIN
  DELETE M
  FROM @members M, dbo.ClassSchemas CS
  WHERE M.SMC_ClassID = CS.CS_ClassID
  AND   CS.CS_IsGroup = 1
 END

 RETURN
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


CREATE TRIGGER dbo.triud_ClassInstances_History ON dbo.ClassInstances 
FOR INSERT, UPDATE, DELETE
AS
BEGIN
 SET NOCOUNT ON
 Print N'FOR INSERT, UPDATE, DELETE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

 DECLARE @errMsg AS nvarchar(400)
    DECLARE @severity AS int
    DECLARE @msgID AS int

 DECLARE @modid as bigint
    EXEC dbo.smc_internal_getmodificationid @modid output

    IF EXISTS (SELECT * FROM inserted)
    BEGIN
  UPDATE CI
  SET CI_StartModID = @modid
  FROM dbo.ClassInstances CI, inserted I
  WHERE CI.CI_InstanceID = I.CI_InstanceID

  IF (@@ERROR <> 0)
  BEGIN
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_UPDATE_CLASSINSTANCESAUDITS_TABLE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END
 END

 IF EXISTS (SELECT * FROM deleted)
 BEGIN
  INSERT INTO dbo.ClassInstancesAudits
  (CIA_InstanceID, CIA_ClassID, CIA_FriendlyName, CIA_StartModID, CIA_EndModID)
  SELECT CI_InstanceID, CI_ClassID, CI_FriendlyName, CI_StartModID, @modid
  FROM deleted

  IF (@@ERROR <> 0)
  BEGIN 
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSERT_CLASSINSTANCESAUDITS_TABLE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END
 END
END
go


CREATE TRIGGER dbo.triu_RelationshipInstances_CheckConstraints ON dbo.RelationshipInstances
FOR INSERT, UPDATE
AS
BEGIN
 SET NOCOUNT ON

 Print N'FOR INSERT/UPDATE trigger ' + OBJECT_NAME(@@PROCID) + N' firing'

 -- only check for constraints when either the source or target instance id has changed
 IF (UPDATE (RI_SourceInstanceID) OR UPDATE (RI_TargetInstanceID))
 BEGIN
  IF NOT EXISTS (SELECT * FROM inserted)
  BEGIN
   RETURN
  END
 
  IF EXISTS
  (
   -- We need to get the class of both the source instance and the class instance
   -- and then verify that for the relationships that are constrainted, that
   -- the source and target instance appears in the relationshipconstraints table
   -- When this query returns an row that does not have anything in the contstraints
   -- table, we have a violation.
   SELECT  *
   FROM 
        inserted I
   JOIN dbo.ClassInstances SRC    ON (SRC.CI_InstanceID    = I.RI_SourceInstanceID)
   JOIN dbo.ClassInstances TARGET ON (TARGET.CI_InstanceID = I.RI_TargetInstanceID)
   JOIN dbo.RelationshipTypes RT  ON (RT.RT_RelationshipTypeID = I.RI_RelationshipTypeID AND RT.RT_IsConstrained = 1)
   LEFT OUTER JOIN dbo.RelationshipConstraints RC
   ON (    I.RI_RelationshipTypeID = RC.RC_RelationshipTypeID 
    AND TARGET.CI_ClassID = RC.RC_TargetClassID
    AND SRC.CI_ClassID = RC.RC_SourceClassID)
   WHERE  RC.RC_RelationshipTypeID IS NULL
  )
  BEGIN
   DECLARE @errMsg AS NVARCHAR(400)
   DECLARE @severity AS int
   DECLARE @msgID AS int
 
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_RELATIONSHIP_CONSTRAINT_VIOLATED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
 
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END
 END
END
go


CREATE TRIGGER [dbo].[tri_SMC_GroupMembers] ON [dbo].[SMC_GroupMembers]
INSTEAD OF INSERT AS
BEGIN
   SET NOCOUNT ON

   Print N'INSERT TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

   IF NOT EXISTS (SELECT * FROM inserted)
   BEGIN
      RETURN
   END

   DECLARE @errResult AS integer
   DECLARE @errMsg AS nvarchar(400)
   DECLARE @severity AS int
   DECLARE @msgID AS int

   IF (UPDATE (GroupID))
   BEGIN
      -- we cannot create memberships between non-groups and other things.
      -- we need to ensure that the instance that is filled out in GroupID
      -- is actually a group. If not, we should flag an error

      IF EXISTS 
      (
  SELECT *
  FROM inserted I,
       dbo.ClassInstances CI,
       dbo.ClassSchemas CS
  WHERE I.GroupID     = CI.CI_InstanceID
  AND   CI.CI_ClassID = CS.CS_ClassID
  AND   CS.CS_IsGroup = 0
       )
       BEGIN
          EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_GROUPMEMBERS_GROUPID_NOTGROUP', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
       END
   END

   -- we do not allow exclusion of groups.
   IF (UPDATE (MemberID) OR UPDATE (Usage))
   BEGIN
 IF EXISTS 
 (
  SELECT *
  FROM inserted I,
       dbo.ClassInstances CI,
       dbo.ClassSchemas CS
  WHERE I.Usage = 'X'
  AND I.MemberID = CI.CI_InstanceID
  AND CI.CI_ClassID = CS.CS_ClassID
  AND CS.CS_IsGroup = 1
 )
 BEGIN
   EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_EXCLUSION_GROUPMEMBERS_INVALID', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
 END
   END

   -- group ok. Store the information in the relationshipinstances table
   DECLARE @modid as bigint
   EXEC dbo.smc_internal_getmodificationid @modid output

   INSERT INTO dbo.RelationshipInstances 
   (RI_InstanceID, RI_RelationshipTypeID, RI_SourceInstanceID, RI_TargetInstanceID, RI_Usage, RI_StartModID)
   SELECT SMC_InstanceID, 'FA97E5AB-4E21-4BBF-90CD-26000A226227', GroupID, MemberID, Usage, @modid
   FROM inserted

   SET @errResult = @@ERROR
   IF (@errResult <> 0)
   BEGIN
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSERT_RELATIONSHIPINSTANCES_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
   END

END
go


CREATE TRIGGER [dbo].[tru_SMC_GroupMembers] ON [dbo].[SMC_GroupMembers]
INSTEAD OF UPDATE AS
BEGIN
   SET NOCOUNT ON
   
   Print N'UPDATE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

   IF NOT EXISTS (SELECT * FROM inserted)
   BEGIN
      RETURN
   END

   DECLARE @errResult AS integer
   DECLARE @errMsg AS nvarchar(400)
   DECLARE @severity AS int
   DECLARE @msgID AS int

   IF UPDATE(SMC_InstanceID)
   BEGIN
 EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSTANCEID_CANNOT_BE_UPDATED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
 RAISERROR (@errMsg, @severity, 1, '[dbo].[SMC_GroupMembers]')
 ROLLBACK TRANSACTION
 RETURN
   END

   IF (UPDATE (GroupID))
   BEGIN
      -- we cannot create memberships between non-groups and other things.
      -- we need to ensure that the instance that is filled out in GroupID
      -- is actually a group. If not, we should flag an error

      IF EXISTS 
      (
  SELECT *
  FROM inserted I,
       dbo.ClassInstances CI,
       dbo.ClassSchemas CS
  WHERE I.GroupID     = CI.CI_InstanceID
  AND   CI.CI_ClassID = CS.CS_ClassID
  AND   CS.CS_IsGroup = 0
       )
       BEGIN
          EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_GROUPMEMBERS_GROUPID_NOTGROUP', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
       END
   END

   -- we do not allow exclusion of groups.
   IF (UPDATE (MemberID) OR UPDATE (Usage))
   BEGIN
 IF EXISTS 
 (
  SELECT *
  FROM inserted I,
       dbo.ClassInstances CI,
       dbo.ClassSchemas CS
  WHERE I.Usage = 'X'
  AND I.MemberID = CI.CI_InstanceID
  AND CI.CI_ClassID = CS.CS_ClassID
  AND CS.CS_IsGroup = 1
 )
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_EXCLUSION_GROUPMEMBERS_INVALID', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
  RAISERROR (@errMsg, @severity, 1)
  ROLLBACK TRANSACTION
  RETURN
 END
   END


   DECLARE @modid as bigint
   EXEC dbo.smc_internal_getmodificationid @modid output

   UPDATE RI
   SET RI.RI_SourceInstanceID = I.[GroupID],
       RI.RI_TargetInstanceID = I.[MemberID],
       RI.RI_Usage            = I.[Usage]
   FROM dbo.RelationshipInstances RI, inserted I
   WHERE RI.RI_InstanceID = I.SMC_InstanceID

   SET @errResult = @@ERROR
   IF (@errResult <> 0)
   BEGIN
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_UPDATE_RELATIONSHIPINSTANCES_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
   END
END
go


CREATE TABLE dbo.ClassInstancesAudits
(
    CIA_InstanceID   uniqueidentifier NOT NULL,
    CIA_ClassID      uniqueidentifier NOT NULL,
    CIA_FriendlyName nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CIA_StartModID   bigint           NOT NULL,
    CIA_EndModID     bigint           NOT NULL,
    CIA_SuserSid     varbinary(85)    CONSTRAINT DF__ClassInst__CIA_S__108B795B DEFAULT suser_sid() NULL
)
go


INSERT INTO SCR.dbo.ClassInstancesAudits
( CIA_InstanceID,
  CIA_ClassID,
  CIA_FriendlyName,
  CIA_StartModID,
  CIA_EndModID,
  CIA_SuserSid ) 
SELECT
CIA_InstanceID,
CIA_ClassID,
CIA_FriendlyName,
CIA_StartModID,
CIA_EndModID,
CIA_SuserSid
FROM SCR.dbo.ClassInstancesAudits_33e6793d
go


ALTER TABLE dbo.ClassInstancesAudits
    ADD CONSTRAINT PK_ClassInstancesAudits
    PRIMARY KEY CLUSTERED (CIA_InstanceID,CIA_StartModID)
go


CREATE TABLE dbo.ClassMethods
(
    CM_MethodID    uniqueidentifier CONSTRAINT DF_ClassMethods_CM_MethodID DEFAULT newid() NOT NULL,
    CM_ClassID     uniqueidentifier NOT NULL,
    CM_MethodName  nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CM_IsStatic    bit              CONSTRAINT DF_ClassMethods_CM_IsStatic DEFAULT 0 NOT NULL,
    CM_Description nvarchar(256)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CM_DllID       uniqueidentifier NOT NULL
)
go


INSERT INTO SCR.dbo.ClassMethods
( CM_MethodID,
  CM_ClassID,
  CM_MethodName,
  CM_IsStatic,
  CM_Description,
  CM_DllID ) 
SELECT
CM_MethodID,
CM_ClassID,
CM_MethodName,
CM_IsStatic,
CM_Description,
CM_DllID
FROM SCR.dbo.ClassMethods_1b66045d
go


CREATE NONCLUSTERED INDEX smc_idx_ClassMethods_ClassID
    ON dbo.ClassMethods(CM_ClassID)
go


ALTER TABLE dbo.ClassMethods
    ADD CONSTRAINT smc_pk_ClassMethods_MethodID
    PRIMARY KEY CLUSTERED (CM_MethodID)
go


ALTER TABLE dbo.ClassMethods
    ADD CONSTRAINT IX_Methods
    UNIQUE NONCLUSTERED (CM_MethodName,CM_ClassID)
go


CREATE TABLE dbo.ClassProperties
(
    CP_ClassPropertyID uniqueidentifier NOT NULL,
    CP_ClassID         uniqueidentifier NOT NULL,
    CP_PropertyTypeID  uniqueidentifier NOT NULL,
    CP_PropertyName    nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CP_PrimaryKey      bit              CONSTRAINT DF_ClassProperties_CP_PrimaryKey DEFAULT 0 NOT NULL,
    CP_Nullable        bit              CONSTRAINT DF_ClassProperties_CP_Nullable DEFAULT 0 NOT NULL,
    CP_Description     nvarchar(256)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CP_DefaultValue    nvarchar(512)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CP_IsInherited     bit              CONSTRAINT DF_ClassProperties_CP_IsInherited DEFAULT 0 NOT NULL,
    CP_System          bit              CONSTRAINT DF_ClassProperties_CP_System DEFAULT 0 NOT NULL,
    CP_IsIdentity      bit              CONSTRAINT DF_ClassProperties_CP_IsIdentity DEFAULT 0 NOT NULL
)
go


INSERT INTO SCR.dbo.ClassProperties
( CP_ClassPropertyID,
  CP_ClassID,
  CP_PropertyTypeID,
  CP_PropertyName,
  CP_PrimaryKey,
  CP_Nullable,
  CP_Description,
  CP_DefaultValue,
  CP_IsInherited,
  CP_System,
  CP_IsIdentity ) 
SELECT
CP_ClassPropertyID,
CP_ClassID,
CP_PropertyTypeID,
CP_PropertyName,
CP_PrimaryKey,
CP_Nullable,
CP_Description,
CP_DefaultValue,
CP_IsInherited,
CP_System,
CP_IsIdentity
FROM SCR.dbo.ClassProperties_ba1fe774
go


CREATE NONCLUSTERED INDEX smc_idx_ClassProperty_ClassID
    ON dbo.ClassProperties(CP_ClassID)
go


ALTER TABLE dbo.ClassProperties
    ADD CONSTRAINT smc_pk_ClassProperties_ClassPropertyID
    PRIMARY KEY CLUSTERED (CP_ClassPropertyID)
go


ALTER TABLE dbo.ClassProperties
    WITH NOCHECK
    ADD CONSTRAINT smc_chk_ClassProperties_PK_NOT_NULLABLE
    CHECK ([CP_PrimaryKey] = 0 or [CP_PrimaryKey] = 1 and [CP_Nullable] = 0)
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_GetGuidColumns (
 @classID  as uniqueidentifier
)
AS
       SET NOCOUNT ON
 SELECT CP_PropertyName AS Name, CP_ClassPropertyID AS ID FROM dbo.ClassProperties WHERE CP_ClassID = @classID and
  CP_PropertyTypeID IN
  (SELECT PT_TypeID FROM dbo.PropertyTypes, dbo.DatatypeDefinitions WHERE
   PT_DatatypeID = DD_DatatypeID AND DD_Name IN ( 'uniqueidentifier', 'bigint', 'int'))
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


CREATE TRIGGER dbo.triu_ClassProperties_UniqueNamesInClass ON dbo.ClassProperties
AFTER INSERT, UPDATE
AS
BEGIN
 SET NOCOUNT ON
 PRINT N'FOR INSERT/UPDATE trigger ' + OBJECT_NAME(@@PROCID) + N' firing'

 IF (UPDATE(CP_ClassID) OR UPDATE(CP_PropertyName))
 BEGIN
  IF EXISTS (
   SELECT CP_ClassID, CP_PropertyName, COUNT(*) 
   FROM dbo.ClassProperties
   GROUP BY CP_ClassID, CP_PropertyName
   HAVING COUNT(*) > 1
   )
  BEGIN
   DECLARE @errMsg AS NVARCHAR(400)
   DECLARE @severity AS int
   DECLARE @msgID AS int
 
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_PROPERTY_NAME_UNIQUE_IN_CLASS', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
 
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END
 END
END
go


CREATE TRIGGER dbo.triu_ClassProperties_ValidateDefaultValue ON dbo.ClassProperties
AFTER INSERT, UPDATE
AS
BEGIN
 SET NOCOUNT ON
 DECLARE @errMsg AS NVARCHAR(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int
 PRINT N'FOR INSERT/UPDATE trigger ' + OBJECT_NAME(@@PROCID) + N' firing'

 IF (UPDATE (CP_PropertyTypeID) OR UPDATE(CP_PrimaryKey) OR UPDATE (CP_DefaultValue))
 BEGIN
 IF EXISTS 
  (
   SELECT *
   FROM inserted I, 
        dbo.PropertyTypes PT,
        dbo.DatatypeDefinitions DD
   WHERE I.CP_PropertyTypeID  = PT.PT_TypeID
   AND   PT.PT_DatatypeID     = DD.DD_DatatypeID
   AND   DD.DD_IsBlob         = 1
   AND   (I.CP_PrimaryKey = 1 OR I.CP_DefaultValue IS NOT NULL)
  )
  BEGIN
 
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_BLOBUSAGE_VIOLATION', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
 
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN 
  END
 END

 IF UPDATE (CP_DefaultValue) OR UPDATE (CP_PropertyTypeID)
 BEGIN
  -- we need to use a cursor because we need to create the CONVERT
  -- for each value that has changed. If we would do it in one string,
  -- we might run out of space (4000 nchar max)
  DECLARE cur CURSOR LOCAL FOR
   SELECT CP_DefaultValue, CP_PropertyTypeID, CP_PropertyName
   FROM inserted
   WHERE CP_DefaultValue IS NOT NULL

  DECLARE @defaultValue as nvarchar(512)
  DECLARE @proptypeID as uniqueidentifier
  DECLARE @propName as nvarchar(128)
  DECLARE @datatype as nvarchar(40)
  DECLARE @str as nvarchar(1000)
  DECLARE @ValidationID as uniqueidentifier
  DECLARE @ValidationFunc as sysname
  DECLARE @retval bit

  -- temp table will hold the input for the validation function, and its output.  They all return a bit.
  CREATE TABLE #funcret (input nvarchar(256), output bit)
  -- insert nulls, we'll change input after each fetch, change output by calling EXEC ('update #funcret ...')
  INSERT INTO #funcret values (NULL, NULL)
  
  OPEN cur

  FETCH NEXT FROM cur INTO @defaultValue, @proptypeID, @propName
  WHILE @@FETCH_STATUS = 0
  BEGIN
   select @datatype = DD_Name + 
    CASE WHEN DD.DD_RequiresLength = 1 THEN '(' + CAST(PT.PT_Length AS NVARCHAR(5)) + ')'
    ELSE ''
    END
   FROM dbo.PropertyTypes PT, dbo.DatatypeDefinitions DD
   WHERE PT.PT_DatatypeID = DD.DD_DatatypeID
   AND PT.PT_TypeID = @proptypeID

   -- Put default value into temp table so that we can use EXEC ()  to dynamically call a function on it
   UPDATE #funcret SET input = @defaultValue
   
   IF (@datatype like '%char%' or @datatype like '%text%' )
    set @defaultValue = '''' + @defaultValue + ''''
   set @str = 'CONVERT (' + @datatype + ',' + @defaultValue + ')'
  
   PRINT 'Verifying Default value for property ' + @propName + ': ' + @str

   DECLARE @strPossibleDefault AS NVARCHAR(2000)
   SET @strPossibleDefault = 'DECLARE @x AS ' + @datatype + ' SELECT @x = ' + @str
   EXEC dbo.sp_executesql @strPossibleDefault
      
   -- Look up the PropertyTypeID in SMC_Meta_PropertyTypes
   SELECT @ValidationID = PT_UDFValidationID FROM dbo.PropertyTypes WHERE PT_TypeID = @proptypeID
   
   -- If no validationID, then default value is presumed to be valid
   IF @ValidationID IS NOT NULL
    SELECT @ValidationFunc = [Name] FROM [dbo].[SMC_Meta_ValidationUDFs] WHERE ValidationUDFID = @ValidationID
   ELSE
    SET @ValidationFunc = NULL
   IF @ValidationFunc IS NOT NULL
    BEGIN
    declare @extra_params nvarchar(1000)
    set @extra_params = ''
    select  @extra_params = @extra_params + ',' + case WHEN VUP_ParamDatatypeID in (14, 15, 17, 18, 23, 24)
         THEN '''' + VUPV_Value + ''''
        else VUPV_Value 
      END from dbo.ValidationUDFParameterValues, dbo.ValidationUDFParameters
      where VUPV_PropertyTypeID = @proptypeID and VUP_ValidationUDFID = @ValidationID and VUPV_ParamName = VUP_ParamName and
       VUP_ParamOrder > 1
      order by VUP_ParamOrder
    set @str = N'update #funcret set output = [dbo].[' + @ValidationFunc + N'] (input' + @extra_params + ')'
    EXEC dbo.sp_executesql @str
    -- If we got 0, rollback the transaction
    IF EXISTS (SELECT output FROM #funcret WHERE output = 0) 
     BEGIN
     CLOSE cur
     DEALLOCATE cur
     DROP TABLE #funcret
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSERT_CLASSPROPERTIES_TABLE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRAN
        RETURN
     END
    END

   FETCH NEXT FROM cur INTO @defaultValue, @proptypeID, @propName
  END

  CLOSE cur
  DEALLOCATE cur
     SELECT @retval = output FROM #funcret
  DROP TABLE #funcret
  IF @retval = 0  
      BEGIN
    EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSERT_CLASSPROPERTIES_TABLE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
   RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRAN
   END
 END
END
go


CREATE TRIGGER dbo.triud_ClassProperties_Signed ON dbo.ClassProperties
FOR INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON

    PRINT N'FOR INSERT, UPDATE, DELETE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

    -- Make sure that none of the modified classes were related 
    -- to a signed class in ClassSchemas
    IF EXISTS ( SELECT CS.CS_ClassID 
                FROM dbo.ClassSchemas AS CS 
                JOIN (SELECT * FROM deleted UNION ALL
                      SELECT * FROM inserted) AS M
                ON CS.CS_ClassID = M.CP_ClassID
  WHERE CS.CS_Signed = 1 )
    BEGIN
        DECLARE @errResult AS integer
 DECLARE @errMsg AS nvarchar(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int

        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASSPROPERTIES_CANNOT_MODIFY_SIGNED_CLASS', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
 RAISERROR (@errMsg, @severity, 1)
 ROLLBACK TRANSACTION
 RETURN 
    END

END
go


CREATE TRIGGER dbo.triud_ClassProperties_ViewInvalid ON dbo.ClassProperties
FOR  INSERT, UPDATE, DELETE
AS
BEGIN

 SET NOCOUNT ON

     Print N'FOR INSERT, UPDATE, DELETE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

 UPDATE dbo.ClassSchemas SET CS_ViewInvalid = 1 WHERE CS_ClassID IN (SELECT CP_ClassID FROM inserted) OR
   CS_ClassID IN (SELECT CP_ClassID from deleted)
   

END
go


CREATE TRIGGER dbo.tri_ClassSchemas_SMCInstanceID on dbo.ClassSchemas
FOR INSERT
AS
BEGIN
 SET NOCOUNT ON

 PRINT N'FOR INSERT Trigger ' + OBJECT_NAME(@@PROCID) + N' firing'

 IF NOT EXISTS (SELECT * from inserted)
 BEGIN
  RETURN
 END

 DECLARE @errMsg AS NVARCHAR(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int

 -- add SMC_InstanceID property. B10B699F-D2F4-47F0-BA7E-A4A64D0FB040 is
        -- the guid of the SMC_InstanceID_Type property

 INSERT INTO dbo.ClassProperties
 (CP_ClassPropertyID, CP_ClassID, CP_PropertyTypeID, CP_PropertyName, CP_Description, CP_Nullable, CP_System)
 SELECT newid(), I.CS_ClassID, 'B10B699F-D2F4-47F0-BA7E-A4A64D0FB040', N'SMC_InstanceID', N'Unique Instance ID', 0, 1
 FROM inserted I

 IF (@@ERROR <> 0)
 BEGIN
     EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASSSCHEMAS_INSERT_INSTANCEID', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1)
     ROLLBACK TRANSACTION
     RETURN
 END
END
go


CREATE TRIGGER dbo.triu_ClassSchemas_Groups on dbo.ClassSchemas
FOR INSERT, UPDATE
AS
BEGIN
 SET NOCOUNT ON

 PRINT N'FOR INSERT,UPDATE Trigger ' + OBJECT_NAME(@@PROCID) + N' firing'

 IF (UPDATE (CS_IsGroup))
 BEGIN
  DECLARE @errMsg AS NVARCHAR(400)
  DECLARE @severity AS int
  DECLARE @msgID AS int
  DECLARE @err AS int

  -- delete existing ones (note that when signing is implemented we don't need this

  DELETE CP
  FROM dbo.ClassProperties CP, 
       inserted i, 
       dbo.PropertyTypes PT
  WHERE CP.CP_ClassID   = i.CS_ClassID
  AND CP.CP_PropertyTypeID = PT.PT_TypeID
  AND PT.PT_TypeName LIKE N'SMC_Group%'

  SET @err = @@ERROR
  IF (@err <> 0)
  BEGIN
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASSSCHEMAS_GROUP', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
 
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END

  -- add common group properties (will be changed when we support copy inheritance
  -- in case classes are marked as group, create the standard group members
  IF EXISTS (SELECT * FROM inserted WHERE CS_IsGroup = 1)
  BEGIN

   INSERT INTO dbo.ClassProperties
   (CP_ClassPropertyID, CP_ClassID, CP_PropertyTypeID, CP_PropertyName, CP_Description, CP_Nullable)
   SELECT newid(), I.CS_ClassID, PT.PT_TypeID, 'SMC_GroupName', 'Group Name', 0
   FROM dbo.PropertyTypes PT, inserted I
   WHERE PT.PT_TypeName = N'SMC_GroupName_Type'
   AND I.CS_IsGroup = 1
 
   SET @err = @@ERROR
   IF (@err <> 0)
   BEGIN
       EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASSSCHEMAS_GROUP', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
  
       RAISERROR (@errMsg, @severity, 1)
       ROLLBACK TRANSACTION
       RETURN
   END

   INSERT INTO dbo.ClassProperties
   (CP_ClassPropertyID, CP_ClassID, CP_PropertyTypeID, CP_PropertyName, CP_Description, CP_Nullable)
   SELECT newid(), I.CS_ClassID, PT.PT_TypeID, 'SMC_GroupDescription', 'Group Description', 0
   FROM dbo.PropertyTypes PT, inserted I
   WHERE PT.PT_TypeName = N'SMC_GroupDescription_Type'
   AND I.CS_IsGroup = 1
 
   SET @err = @@ERROR
   IF (@err <> 0)
   BEGIN
       EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASSSCHEMAS_GROUP', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
  
       RAISERROR (@errMsg, @severity, 1)
       ROLLBACK TRANSACTION
       RETURN
   END
 
   INSERT INTO dbo.ClassProperties
   (CP_ClassPropertyID, CP_ClassID, CP_PropertyTypeID, CP_PropertyName, CP_Description, CP_Nullable)
   SELECT newid(), I.CS_ClassID, PT.PT_TypeID, 'SMC_GroupQuery', 'Group Query', 1
   FROM dbo.PropertyTypes PT, inserted I
   WHERE PT.PT_TypeName = N'SMC_GroupQuery_Type'
   AND I.CS_IsGroup = 1
 
   SET @err = @@ERROR
   IF (@err <> 0)
   BEGIN
       EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASSSCHEMAS_GROUP', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
  
       RAISERROR (@errMsg, @severity, 1)
       ROLLBACK TRANSACTION
       RETURN
   END
  END
 END
END
go


CREATE TRIGGER [dbo].[triu_RelationshipConstraints_CheckNotHighVolume] ON [dbo].[RelationshipConstraints] 
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @errMsg AS NVARCHAR(400)
    DECLARE @severity AS int
    DECLARE @msgID AS int

    Print N'INSERT, UPDATE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

    IF NOT EXISTS (SELECT * FROM inserted)
     BEGIN
  RETURN
     END

    IF UPDATE(RC_SourceClassID) OR UPDATE(RC_TargetClassID)
    BEGIN 
        -- Verify if any of the classes indicated as part of either
        -- the source or the target of the relationship constraint
        -- is a high-volume class
        IF EXISTS (
             SELECT * FROM inserted AS I
                    JOIN dbo.ClassSchemas AS CS
         ON I.RC_SourceClassID = CS.CS_ClassID OR
                    I.RC_TargetClassID = CS.CS_ClassID JOIN dbo.RelationshipTypes AS RT
                  ON I.RC_RelationshipTypeID = RT.RT_RelationshipTypeID
      WHERE CS.CS_IsHighVolume = 1 and RT.RT_IsHighVolume = 0
            )
         BEGIN

      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_HIGHVOLUMECLASS_CANNOT_HAVE_RELATIONSHIP', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
         RAISERROR (@errMsg, @severity, 1)
         ROLLBACK TRANSACTION
         RETURN
         END
    END
    -- Verify that if a non-null TargetFK is specified then the relationship must be marked as High Volume
    -- and the TargetFK ClassProperty must belong to the TargetClass
    IF EXISTS (SELECT * FROM inserted AS I JOIN dbo.ClassSchemas AS CS ON I.RC_TargetClassID = CS.CS_ClassID JOIN
       dbo.ClassProperties AS CP ON I.RC_TargetFK = CP.CP_ClassPropertyID
      WHERE CP.CP_ClassID <> CS.CS_ClassID )
            BEGIN

      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_HIGHVOLUMECLASS_CANNOT_HAVE_RELATIONSHIP', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
         RAISERROR (@errMsg, @severity, 1)
         ROLLBACK TRANSACTION
         RETURN
         END
   
END
go


CREATE TABLE dbo.ClassRelationships
(
    CR_RelationshipID uniqueidentifier CONSTRAINT DF_ClassRelationships_CR_RelationshipID DEFAULT newid() NOT NULL,
    CR_Description    nvarchar(256)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CR_SourceClassID  uniqueidentifier NOT NULL,
    CR_TargetClassID  uniqueidentifier NULL,
    CR_System         bit              CONSTRAINT DF_ClassRelationships_CR_System DEFAULT 0 NOT NULL
)
go


INSERT INTO SCR.dbo.ClassRelationships
( CR_RelationshipID,
  CR_Description,
  CR_SourceClassID,
  CR_TargetClassID,
  CR_System ) 
SELECT
CR_RelationshipID,
CR_Description,
CR_SourceClassID,
CR_TargetClassID,
CR_System
FROM SCR.dbo.ClassRelationships_5000c1c6
go


ALTER TABLE dbo.ClassRelationships
    ADD CONSTRAINT smc_pk_ClassRelationships
    PRIMARY KEY CLUSTERED (CR_RelationshipID)
go


CREATE TABLE dbo.ClassSchemaPartitions
(
    CSP_ClassID            uniqueidentifier NOT NULL,
    CSP_PartitionTableName nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CSP_PartitionDate      datetime         NOT NULL,
    CSP_DTSDone            bit              CONSTRAINT DF_ClassSchemaPartitions_CSP_DTSDone DEFAULT 0 NOT NULL,
    CSP_Current            bit              CONSTRAINT DF_ClassSchemaPartitions_CSP_Current DEFAULT 0 NOT NULL,
    CSP_ID                 tinyint          NOT NULL
)
go


INSERT INTO SCR.dbo.ClassSchemaPartitions
( CSP_ClassID,
  CSP_PartitionTableName,
  CSP_PartitionDate,
  CSP_DTSDone,
  CSP_Current,
  CSP_ID ) 
SELECT
CSP_ClassID,
CSP_PartitionTableName,
CSP_PartitionDate,
CSP_DTSDone,
CSP_Current,
CSP_ID
FROM SCR.dbo.ClassSchemaPartitions_d4446ea8
go


ALTER TABLE dbo.ClassSchemaPartitions
    ADD CONSTRAINT PK_ClassSchemaPartitions
    PRIMARY KEY CLUSTERED (CSP_ClassID,CSP_PartitionTableName)
go


ALTER TABLE dbo.ClassSchemaPartitions
    ADD CONSTRAINT smc_idx_ClassSchemaPartitions_ID_ClassID_Unique
    UNIQUE NONCLUSTERED (CSP_ID,CSP_ClassID)
go


ALTER TABLE dbo.ClassSchemaPartitions
    WITH NOCHECK
    ADD CONSTRAINT smc_chk_ClassSchemaPartitions_ID
    CHECK ([CSP_ID] >= 1 and [CSP_ID] <= 60)
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.SMC_Internal_DBHasUniqueObjectNames ()
RETURNS bit
WITH SCHEMABINDING
AS
BEGIN

 DECLARE @objectTable TABLE (ObjectName nvarchar(128))

 INSERT INTO @objectTable
 SELECT CS_ViewName AS ObjectName
 FROM dbo.ClassSchemas
 UNION ALL
 SELECT CS_TableName
 FROM dbo.ClassSchemas
 UNION ALL
 SELECT CS_HistoryTableName
 FROM dbo.ClassSchemas
 UNION ALL
 SELECT CS_HistoryUDFName
 FROM dbo.ClassSchemas
 UNION ALL
 SELECT CS_HistoryViewName
 FROM dbo.ClassSchemas
 UNION ALL
        SELECT CS_InsertViewName
 FROM dbo.ClassSchemas
 UNION ALL
 SELECT CSP_PartitionTableName
 FROM dbo.ClassSchemaPartitions
        UNION ALL
 SELECT RT_ViewName
 FROM dbo.RelationshipTypes
 UNION ALL
 SELECT RT_HistoryViewName
 FROM dbo.RelationshipTypes
 UNION ALL
 SELECT RT_HistoryUDFName
 FROM dbo.RelationshipTypes

 IF EXISTS
 (
  SELECT ObjectName 
  FROM @objectTable
  WHERE ObjectName IN (
   N'ClassIndexes', N'SMC_Meta_ClassIndexes',
   N'ClassIndexesColumns', N'SMC_Meta_ClassIndexesColumns',
   N'ClassInstances', N'ClassInstancesAudits', N'SMC_Meta_ClassInstances',
   N'ClassProperties', N'SMC_Meta_ClassProperties',
   N'ClassSchemas', N'SMC_Meta_ClassSchemas', 
                        N'ClassSchemaPartitions', N'SMC_Meta_ClassSchemaPartitions',
   N'DatatypeDefinitions', N'SMC_Meta_DatatypeDefinitions', 
   N'FileGroups', N'SMC_Meta_FileGroups', 
                        N'GroomingSettings', N'SMC_GroomingSettings',
   N'MetaVersion', N'SMC_Meta_MetaVersion',
   N'Modifications', N'SMC_Meta_Modifications',
   N'PropertyTypes', N'SMC_Meta_PropertyTypes',
   N'PropertyTypeEnumerations', N'SMC_Meta_PropertyTypeEnumerations',
   N'PropertyInstances', N'PropertyInstancesAudits', N'SMC_Meta_PropertyInstances',
   N'RelationshipTypes', N'SMC_Meta_RelationshipTypes',
   N'RelationshipConstraints', N'SMC_Meta_RelationshipConstraints',
   N'RelationshipInstances', N'RelationshipInstancesAudits', N'SMC_Meta_RelationshipInstances',
   N'Users', N'SMC_Meta_Users',
   N'ValidationUDFs', N'SMC_Meta_ValidationUDFs',
   N'ValidationUDFParameters', N'SMC_Meta_ValidationUDFParameters',
   N'ValidationUDFParameterValues', N'SMC_Meta_ValidationUDFParameterValues',
   N'WrapperColumns', N'SMC_Meta_WrapperColumns',
   N'WrapperSchemas', N'SMC_Meta_WrapperSchemas',
   N'SMC_Messages')
 )
 BEGIN
  RETURN 0
 END

 IF EXISTS 
 (
  SELECT ObjectName
  FROM @objectTable  
  GROUP BY ObjectName
  HAVING COUNT(*) > 1
  
 )
 BEGIN 
  RETURN 0
 END

 RETURN 1
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_partition_class
(
 @classID as uniqueidentifier
)
AS
BEGIN
 -- TODO: Remove
 PRINT 'Executing smc_partition_class'

 SET NOCOUNT ON

 DECLARE @errResult AS integer
    DECLARE @errMsg AS nvarchar(400)
    DECLARE @severity AS int
    DECLARE @msgID AS int
 
 DECLARE @currentID AS tinyint 
        DECLARE @previousID AS tinyint
 DECLARE @currentName as nvarchar(128)
 DECLARE @className as nvarchar(128)
        DECLARE @insertViewName as nvarchar(128)
 DECLARE @command AS nvarchar(150)

 -- Get the ID of the Current table
 SELECT @currentID = CSP.CSP_ID, @insertViewName = CS.CS_InsertViewName,
        @className = CS.CS_ClassName 
        FROM dbo.ClassSchemaPartitions AS CSP
 JOIN dbo.ClassSchemas AS CS
        ON CSP.CSP_ClassID = CS.CS_ClassID
        WHERE CSP.CSP_Current = 1 AND CSP.CSP_ClassID = @classID

 -- There should be one and only one Current table
 IF (@@ROWCOUNT <> 1)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASSSCHEMAPARTITIONS_INVALID_CURRENT', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1, @className)
     ROLLBACK TRANSACTION
     RETURN
 END

 -- Keeping track of the current, as we will modify it but we need
        -- the previous value for later
 SET @previousID = @currentID

 -- Updating the CurrentID to point to the next table
 SET @currentID = @currentID + 1

 -- If it was the last table in the partition, point to the first one 
 IF (@currentID > 60)
 BEGIN
  SET @currentID = 1
 END

 -- Get the name of our next Current table
 SELECT @currentName = CSP_PartitionTableName 
 FROM dbo.ClassSchemaPartitions 
 WHERE CSP_ID = @currentID 
        AND CSP_ClassID = @classID

 -- We should get one and only one row 
 IF (@@ROWCOUNT <> 1)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASSSCHEMAPARTITIONS_ID_NOT_FOUND', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1, @currentID, @className)
     ROLLBACK TRANSACTION
     RETURN
 END

 -- Truncate the table if there's any data there
 EXEC @errResult = dbo.smc_internal_truncatetable @currentName 
 
 IF (@errResult <> 0)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_TRUNCATE_PARTITION_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1, @currentName) WITH LOG
  -- Should continue anyway?
     ROLLBACK TRANSACTION
     RETURN
 END

 -- Update the Current table in ClassSchemaPartitions
        -- Switching the old Current and the current Current at the same time
        -- by inverting the Current bit of these 2 rows with (1 - CSP_Current)
 UPDATE dbo.ClassSchemaPartitions         
        SET CSP_Current = (1 - CSP_Current)
        WHERE CSP_ClassID = @classID
        AND   CSP_ID IN (@currentID, @previousID)
 
 IF (@@ERROR <> 0)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_UPDATE_CURRENT_PARTITION_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1, @className) WITH LOG
     ROLLBACK TRANSACTION
     RETURN
 END

 -- Now update the PartitionDate of the Current partition
 UPDATE dbo.ClassSchemaPartitions 
        SET CSP_PartitionDate = getutcdate()
        WHERE CSP_ClassID = @classID
        AND   CSP_ID = @currentID
 
 IF (@@ERROR <> 0)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_UPDATE_PARTITIONDATE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1, @className) WITH LOG
     ROLLBACK TRANSACTION
     RETURN
 END


 -- Alter the INSERT VIEW to point to the current table
 EXEC @errResult = dbo.smc_internal_alter_insertview @insertViewName, @currentName

 IF (@errResult <> 0)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_UPDATE_INSERT_VIEW_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1, @currentName) WITH LOG
     ROLLBACK TRANSACTION
     RETURN
 END
 
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


CREATE TRIGGER dbo.triud_ClassSchemaPartitions_Current ON dbo.ClassSchemaPartitions
FOR  INSERT, UPDATE, DELETE
AS
BEGIN

 SET NOCOUNT ON

     Print N'FOR INSERT, UPDATE, DELETE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'
 
 DECLARE @errMsg AS NVARCHAR(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int
 DECLARE @err AS int

 IF EXISTS
 (  
                -- Verifying if there is any class that supports partitions
                -- but is not present in a temporary table that contains
                -- all classes with exactly one row where Current = 1
         SELECT * FROM dbo.ClassSchemas AS CS
                WHERE CS.CS_ClassID IN
  (
   SELECT CSP_ClassID FROM inserted
                        UNION ALL
                        SELECT CSP_ClassID FROM deleted
  )
  AND CS.CS_SupportsPartitions = 1
  AND NOT EXISTS (
                        -- Creating a temporary table with all the classes
                        -- that have exactly one row where Current = 1
    SELECT * FROM  (
    SELECT CSP_ClassID, count(*) AS cnt
    FROM dbo.ClassSchemaPartitions
    WHERE CSP_Current = 1
    GROUP BY CSP_ClassID
                                       ) as TMP
          WHERE TMP.cnt = 1
                        AND TMP.CSP_ClassID = CS.CS_ClassID
                )
 )
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASSSCHEMAPARTITIONS_ONE_CURRENT', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1)
     ROLLBACK TRANSACTION
     RETURN
 END

END
go


CREATE TABLE dbo.ClassSchemas
(
    CS_ClassID                 uniqueidentifier CONSTRAINT DF_ClassSchemas_CS_ClassID DEFAULT newid() NOT NULL,
    CS_ClassName               nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CS_Description             nvarchar(256)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CS_IsGroup                 bit              CONSTRAINT DF_ClassSchemas_CS_IsGroup DEFAULT 0 NOT NULL,
    CS_Signed                  bit              CONSTRAINT DF_ClassSchemas_CS_Signed DEFAULT 0 NOT NULL,
    CS_ParentClassID           uniqueidentifier NULL,
    CS_SP_ValidateRow          nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CS_SP_ValidateTable        nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CS_InheritsFrom            uniqueidentifier NULL,
    CS_NotifyOnInsert          bit              CONSTRAINT DF_ClassSchemas_CS_NotifyInsert DEFAULT 0 NOT NULL,
    CS_NotifyOnUpdate          bit              CONSTRAINT DF_ClassSchemas_CS_NotifyUpdate DEFAULT 0 NOT NULL,
    CS_NotifyOnDelete          bit              CONSTRAINT DF_ClassSchemas_CS_NotifyDelete DEFAULT 0 NOT NULL,
    CS_ClassDeleted            bit              CONSTRAINT DF_ClassSchemas_CS_ClassDeleted DEFAULT 0 NOT NULL,
    CS_SingleTable             bit              CONSTRAINT DF_ClassSchemas_CS_SingleTable DEFAULT 0 NOT NULL,
    CS_ViewName                nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CS_TableName               nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CS_HistoryTableName        nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CS_HistoryUDFName          nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CS_HistoryViewName         nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CS_TableFileGroupID        uniqueidentifier NULL,
    CS_HistoryTableFileGroupID uniqueidentifier NULL,
    CS_System                  bit              CONSTRAINT DF_ClassSchemas_CS_System DEFAULT 0 NOT NULL,
    CS_IsHighVolume            bit              CONSTRAINT DF_ClassSchemas_CS_IsHighVolume DEFAULT 0 NOT NULL,
    CS_GenerateHistory         bit              CONSTRAINT DF_ClassSchemas_CS_GenerateHistory DEFAULT 1 NOT NULL,
    CS_GenerateView            bit              CONSTRAINT DF_ClassSchemas_CS_GenerateView DEFAULT 1 NOT NULL,
    CS_SupportsPartitions      bit              CONSTRAINT DF_ClassSchemas_CS_SupportsPartitions DEFAULT 0 NOT NULL,
    CS_ViewInvalid             bit              CONSTRAINT DF_ClassSchemas_CS_ViewInvalid DEFAULT 1 NOT NULL,
    CS_InsertViewName          nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CS_SignedModID             bigint           NULL
)
go


INSERT INTO SCR.dbo.ClassSchemas
( CS_ClassID,
  CS_ClassName,
  CS_Description,
  CS_IsGroup,
  CS_Signed,
  CS_ParentClassID,
  CS_SP_ValidateRow,
  CS_SP_ValidateTable,
  CS_InheritsFrom,
  CS_NotifyOnInsert,
  CS_NotifyOnUpdate,
  CS_NotifyOnDelete,
  CS_ClassDeleted,
  CS_SingleTable,
  CS_ViewName,
  CS_TableName,
  CS_HistoryTableName,
  CS_HistoryUDFName,
  CS_HistoryViewName,
  CS_TableFileGroupID,
  CS_HistoryTableFileGroupID,
  CS_System,
  CS_IsHighVolume,
  CS_GenerateHistory,
  CS_GenerateView,
  CS_SupportsPartitions,
  CS_ViewInvalid,
  CS_InsertViewName,
  CS_SignedModID ) 
SELECT
CS_ClassID,
CS_ClassName,
CS_Description,
CS_IsGroup,
CS_Signed,
CS_ParentClassID,
CS_SP_ValidateRow,
CS_SP_ValidateTable,
CS_InheritsFrom,
CS_NotifyOnInsert,
CS_NotifyOnUpdate,
CS_NotifyOnDelete,
CS_ClassDeleted,
CS_SingleTable,
CS_ViewName,
CS_TableName,
CS_HistoryTableName,
CS_HistoryUDFName,
CS_HistoryViewName,
CS_TableFileGroupID,
CS_HistoryTableFileGroupID,
CS_System,
CS_IsHighVolume,
CS_GenerateHistory,
CS_GenerateView,
CS_SupportsPartitions,
CS_ViewInvalid,
CS_InsertViewName,
CS_SignedModID
FROM SCR.dbo.ClassSchemas_48c92478
go


CREATE UNIQUE NONCLUSTERED INDEX smc_idx_ClassSchema_ClassName
    ON dbo.ClassSchemas(CS_ClassName)
go


ALTER TABLE dbo.ClassSchemas
    ADD CONSTRAINT smc_pk_ClassSchemas_ClassID
    PRIMARY KEY CLUSTERED (CS_ClassID)
go


ALTER TABLE dbo.ClassSchemas
    WITH NOCHECK
    ADD CONSTRAINT smc_chk_ClassSchemas_CheckHighVolume
    CHECK ([CS_IsHighVolume] <> 1 or [CS_NotifyOnInsert] <> 1 and [CS_NotifyOnUpdate] <> 1 and [CS_NotifyOnDelete] <> 1 and [CS_SingleTable] <> 1)
go


ALTER TABLE dbo.ClassSchemas
    WITH NOCHECK
    ADD CONSTRAINT smc_chk_ClassSchemas_ClassID_NOTEQUAL_ParentClassID_InheritsFrom
    CHECK ([CS_ClassID] <> [CS_ParentClassID] and [CS_ClassID] <> [CS_InheritsFrom])
go


ALTER TABLE dbo.ClassSchemas
    WITH NOCHECK
    ADD CONSTRAINT smc_chk_ClassSchemas_InsertViewName
    CHECK ([CS_InsertViewName] is not null or [CS_SupportsPartitions] = 0)
go


ALTER TABLE dbo.ClassSchemas
    WITH NOCHECK
    ADD CONSTRAINT smc_chk_ClassSchemas_SupportsPartitions
    CHECK ([CS_SupportsPartitions] = 0 or [CS_IsHighVolume] = 1)
go


ALTER TABLE dbo.ClassSchemas
    WITH NOCHECK
    ADD CONSTRAINT smc_chk_ClassSchemas_ValidateSPs
    CHECK ([CS_SP_ValidateRow] is null or [CS_SP_ValidateTable] is null)
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_dropinvalid @Upgrade bit = 0
AS
BEGIN
 SET NOCOUNT ON
 DECLARE @ObjectName nvarchar(256), @SourceClass nvarchar(128), @TargetClass nvarchar(128),
  @ViewName nvarchar(128), @TableName nvarchar(128), @HistoryView nvarchar(128), @HistoryTable nvarchar(128),
  @HistoryUDF nvarchar(128), @InsertView nvarchar(128), @IsPartitioned bit, @ClassID uniqueidentifier, @PartitionNum int,
  @DeleteCommand nvarchar(1000)
  
 -- This first loop is to delete any invalid join tables that were created for High Volume Relationships
 DECLARE cur1 CURSOR LOCAL FOR 
  SELECT CS1.CS_ClassName, CS2.CS_ClassName, RT.RT_ViewName FROM
    dbo.ClassSchemas AS CS1, dbo.ClassSchemas AS CS2,
    dbo.RelationshipTypes AS RT, dbo.RelationshipConstraints as RC
    WHERE RT.RT_IsHighVolume = 1 AND RT.RT_ViewInvalid = 1 AND
     RC.RC_RelationshipTypeID = RT.RT_RelationshipTypeID AND
     RC.RC_SourceClassID = CS1.CS_ClassID AND
     RC.RC_TargetClassID = CS2.CS_ClassID AND
     RC.RC_TargetFK IS NULL

 OPEN cur1
 FETCH NEXT FROM cur1 INTO @SourceClass, @TargetClass, @ViewName

 WHILE @@FETCH_STATUS = 0
 BEGIN
  -- Drop the view first, as it references the join table created for it.
  SET @ObjectName = '[dbo].[' + @ViewName + ']'
  EXEC dbo.smc_dropobject @ObjectName, 'VIEW'

  -- Drop the join table.
  SET @ObjectName = '[dbo].[SMC_' + @SourceClass + '_' + @TargetClass + ']'
  IF (@Upgrade <> 1)
  BEGIN
      EXEC dbo.smc_dropobject @ObjectName, 'TABLE'
  END

  FETCH NEXT FROM cur1 INTO @SourceClass, @TargetClass, @ViewName
 END

 -- This next loop is over all invalidated relationships to drop the views, history views, and history udf's
 DECLARE cur2 CURSOR LOCAL FOR
  SELECT RT_ViewName, RT_HistoryViewName, RT_HistoryUDFName FROM
   dbo.RelationshipTypes WHERE RT_ViewInvalid = 1 AND RT_System = 0
 OPEN cur2
 FETCH NEXT FROM cur2 INTO @ViewName, @HistoryView, @HistoryUDF
 WHILE @@FETCH_STATUS = 0
 BEGIN
  SET @ObjectName = '[dbo].[' + @ViewName + ']'
  EXEC dbo.smc_dropobject @ObjectName, 'VIEW'

  SET @ObjectName = '[dbo].[' + @HistoryUDF + ']'
  EXEC dbo.smc_dropobject @ObjectName, 'FUNCTION'
  
  SET @ObjectName = '[dbo].[' + @HistoryView + ']'
  EXEC dbo.smc_dropobject @ObjectName, 'VIEW'

  FETCH NEXT FROM cur2 INTO @ViewName, @HistoryView, @HistoryUDF
 END

 -- Clear the invalid bits if we succeeded in dropping the view
 UPDATE dbo.RelationshipTypes SET RT_ViewInvalid = 0 WHERE
  RT_ViewInvalid = 1 AND OBJECT_ID(RT_ViewName) IS NULL

 -- Third cursor loop goes over ClassSchemas looking for Classes that have been invalidated.
 DECLARE cur3 CURSOR LOCAL FOR 
  SELECT CS_ViewName, CS_InsertViewName, CS_HistoryUDFName, CS_HistoryViewName, 
   CS_TableName, CS_HistoryTableName, CS_SupportsPartitions, CS_ClassID FROM dbo.ClassSchemas
   WHERE CS_ViewInvalid = 1
 OPEN cur3
 FETCH NEXT FROM cur3 INTO @ViewName, @InsertView, @HistoryUDF, @HistoryView, @TableName, @HistoryTable, @IsPartitioned, @ClassID
 WHILE @@FETCH_STATUS = 0
 BEGIN
  -- Drop the View and InsertView
  SET @ObjectName = '[dbo].[' + @ViewName + ']'
  EXEC dbo.smc_dropobject @ObjectName, 'VIEW'
  SET @ObjectName = '[dbo].[' + @InsertView + ']'
  EXEC dbo.smc_dropobject @ObjectName, 'VIEW'

  -- Drop the HistoryUDF and the History View
  SET @ObjectName = '[dbo].[' + @HistoryUDF + ']'
  EXEC dbo.smc_dropobject @ObjectName, 'FUNCTION'
  SET @ObjectName = '[dbo].[' + @HistoryView + ']'
  EXEC dbo.smc_dropobject @ObjectName, 'VIEW'

  -- Drop the Table and History Table
  SET @ObjectName = '[dbo].[' + @TableName + ']'
  IF (@Upgrade <> 1)
  BEGIN
      EXEC dbo.smc_dropobject @ObjectName, 'TABLE'  
  END
  SET @ObjectName = '[dbo].[' + @HistoryTable + ']'
  IF (@Upgrade <> 1)
  BEGIN
      EXEC dbo.smc_dropobject @ObjectName, 'TABLE'
  END

  -- If this is a partitioned class, drop all of the partition tables and delete rows from ClassSchemaPartitions
  IF @IsPartitioned = 1
   BEGIN
   SET @PartitionNum = 0
   WHILE @PartitionNum < 60
    BEGIN
    SET @PartitionNum = @PartitionNum + 1
    IF @PartitionNum < 10
        SET @ObjectName = @TableName + '_0' + convert(char, @PartitionNum)
    ELSE
        SET @ObjectName = @TableName + '_'  + convert(char(2), @PartitionNum)
     SET @DeleteCommand = 'DELETE FROM dbo.SMC_Meta_ClassSchemaPartitions WHERE PartitionTableName = ''' + 
      @ObjectName + ''' AND ClassID = ''' + convert(char(36), @ClassID) + ''''
     SET @ObjectName = '[dbo].[' + @ObjectName + ']'
     IF (@Upgrade <> 1)
     BEGIN
         EXEC dbo.smc_dropobject @ObjectName, 'TABLE'
         EXEC dbo.sp_executesql @DeleteCommand
     END
    END
   END
  
  FETCH NEXT FROM cur3 INTO @ViewName, @InsertView, @HistoryUDF, @HistoryView, @TableName, @HistoryTable, @IsPartitioned, @ClassID
 END
 -- Clear the invalid bits if we succeeded in dropping the view
 UPDATE dbo.ClassSchemas SET CS_ViewInvalid = 0 WHERE
  CS_ViewInvalid = 1 AND OBJECT_ID(CS_ViewName) IS NULL
 
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


CREATE  TRIGGER [dbo].[triu_ClassSchemas_CheckIsHighVolume] ON [dbo].[ClassSchemas] 
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON

    Print N'INSERT, UPDATE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

    -- If the IsHighVolume flag was updated
    IF UPDATE(CS_IsHighVolume)
    BEGIN
        -- Verify if there's a HighVolume class that is
        -- specified as part of a relationship constraint
 IF EXISTS (
      SELECT *
      FROM inserted AS I
      JOIN dbo.RelationshipConstraints AS RC
      ON (I.CS_ClassID = RC.RC_SourceClassID) OR 
         (I.CS_ClassID = RC.RC_TargetClassID)
      WHERE I.CS_IsHighVolume = 1
                   )
 BEGIN
     DECLARE @errMsg AS NVARCHAR(400)
     DECLARE @severity AS int
     DECLARE @msgID AS int
     DECLARE @err AS int

       EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_HIGHVOLUMECLASS_CANNOT_HAVE_RELATIONSHIP', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
        RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
 END   
    END
END
go


CREATE TRIGGER dbo.triu_ClassSchemas_CheckValidationSPs ON dbo.ClassSchemas
FOR INSERT, UPDATE
AS
BEGIN
 SET NOCOUNT ON

 PRINT N'FOR INSERT/UPDATE trigger ' + OBJECT_NAME(@@PROCID) + N' firing'

 IF (UPDATE (CS_SP_ValidateTable))
 BEGIN
  -- get the names of the validation stored procedures, and check if they have
  -- the correct signature:
  -- SP_Name (@success as bit OUTPUT)

  DECLARE cur CURSOR FOR 
  SELECT CS_SP_ValidateTable, CS_SP_ValidateRow
  FROM inserted I
  WHERE CS_SP_ValidateTable IS NOT NULL OR CS_SP_ValidateRow IS NOT NULL
 
  OPEN cur
  
  DECLARE @spTableName as nvarchar(500)
  DECLARE @spRowName as nvarchar(500)
  DECLARE @bOK as bit
 
  SET @bOK = 1
  FETCH NEXT FROM cur INTO @spTableName, @spRowName
  WHILE @@FETCH_STATUS = 0 AND @bOK = 1
  BEGIN
   IF (@spTableName IS NOT NULL)
   BEGIN
    EXEC dbo.smc_internal_IsValidClassSPValidator @spTableName, @bOK OUTPUT
   END
   
   IF (@spRowName IS NOT NULL)
   BEGIN
    EXEC dbo.smc_internal_IsValidClassSPValidator @spRowName, @bOK OUTPUT
   END
    
   FETCH NEXT FROM cur INTO @spTableName, @spRowName
  END
  CLOSE cur
  DEALLOCATE cur
 
  if (@bOK = 0)
  BEGIN
   DECLARE @errMsg AS NVARCHAR(400)
   DECLARE @severity AS int
   DECLARE @msgID AS int
 
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INVALID_CLASSSPVALIDATOR', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END
 END
END
go


CREATE TRIGGER dbo.triu_ClassSchemas_PopulateNames on dbo.ClassSchemas
FOR INSERT, UPDATE
AS
BEGIN
 SET NOCOUNT ON

 PRINT N'FOR INSERT Trigger ' + OBJECT_NAME(@@PROCID) + N' firing'

 IF NOT EXISTS (SELECT * FROM inserted)
 BEGIN
  RETURN
 END

 DECLARE @errMsg AS NVARCHAR(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int
 DECLARE @err AS int

 -- we always want names for viewname, etc. If the user specified NULL, we automatically generate
 -- one for them
 IF (UPDATE (CS_ClassName) OR UPDATE (CS_ViewName) OR UPDATE (CS_TableName) OR 
            UPDATE(CS_HistoryTableName) OR UPDATE (CS_HistoryUDFName) OR 
            UPDATE (CS_HistoryViewName) OR UPDATE(CS_InsertViewName))
 BEGIN
  UPDATE CS
  SET CS_ViewName       = ISNULL (I.CS_ViewName,         N'SC_' + I.CS_ClassName + N'_View'),
      CS_TableName       = ISNULL (I.CS_TableName,        N'SC_' + I.CS_ClassName + N'_Table'),
      CS_HistoryTableName  = ISNULL (I.CS_HistoryTableName, N'SC_' + I.CS_ClassName + N'_Hist_Table'),
      CS_HistoryUDFName    = ISNULL (I.CS_HistoryUDFName,   N'SC_' + I.CS_ClassName + N'_Hist'),
      CS_HistoryViewName   = ISNULL (I.CS_HistoryViewName,  N'SC_' + I.CS_ClassName + N'_TT_View'),
      CS_InsertViewName    = ISNULL (I.CS_InsertViewName,   N'SC_' + I.CS_ClassName + N'_Ins_View')
  FROM dbo.ClassSchemas CS, inserted I
  WHERE CS.CS_ClassID = I.CS_ClassID
  
  IF (@err <> 0)
  BEGIN
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSERT_CLASSSCHEMAS_TABLE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END

  -- verify that the object names are still unique
  IF (dbo.SMC_Internal_DBHasUniqueObjectNames()  <> 1)
  BEGIN 
   EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_OBJECTNAMES_UNIQUE', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
   RAISERROR (@errMsg, @severity, 1)
   ROLLBACK TRANSACTION
   RETURN
  END
 END
END
go


CREATE TRIGGER dbo.tru_ClassSchemas_ViewInvalid ON dbo.ClassSchemas
FOR UPDATE
AS
BEGIN

 SET NOCOUNT ON

 -- Don't do anything if the view invalid bit is being explicitly set or cleared
 -- this keeps trigger from nesting indefinitely and allows us to clear the
 -- flag when we have deleted any invalid tables or views.
 IF UPDATE(CS_ViewInvalid)
  RETURN

     Print N'FOR UPDATE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

 UPDATE dbo.ClassSchemas SET CS_ViewInvalid = 1 WHERE CS_ClassID IN (SELECT CS_ClassID FROM inserted WHERE CS_ViewInvalid = 0) 
   

END
go


CREATE TRIGGER dbo.trud_ClassSchemas_Signed ON dbo.ClassSchemas
FOR UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON

    PRINT N'FOR UPDATE, DELETE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

    -- Make sure none of the modified tables were signed
    IF EXISTS ( SELECT * 
                FROM deleted
                WHERE CS_Signed = 1 )
    BEGIN
        DECLARE @errResult AS integer
 DECLARE @errMsg AS nvarchar(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int

        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CANNOT_MODIFY_SIGNED_CLASS', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
 RAISERROR (@errMsg, @severity, 1)
 ROLLBACK TRANSACTION
 RETURN 
    END

END
go


CREATE TRIGGER dbo.triu_RelationshipTypes_Validate ON dbo.RelationshipTypes
FOR INSERT, UPDATE
AS
BEGIN
 SET NOCOUNT ON

 PRINT N'FOR INSERT/UPDATE trigger ' + OBJECT_NAME(@@PROCID) + N' firing'

 -- don't allow relationshipconstraints for relationship types that are marked as
 -- non-constrainted (RT_IsConstrined = 0)

 IF NOT EXISTS (SELECT * from inserted)
 BEGIN
  RETURN
 END

 DECLARE @errMsg AS NVARCHAR(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int

 -- we do not allow the user to set RT_IsConstrained to 0 if there are any constraints in the
 -- relationshipconstraints table
 IF (UPDATE (RT_IsConstrained))
 BEGIN
  IF EXISTS
  (
   SELECT * 
   FROM  inserted I,
         dbo.RelationshipConstraints RC
   WHERE I.RT_RelationshipTypeID = RC.RC_RelationshipTypeID
   AND   I.RT_IsConstrained      = 0
  )
  BEGIN
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_RELATIONSHIPTYPE_NON_CONSTRAINT_WITH_CONSTRAINTS', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END
 END

 -- we do not allow the user to set RT_AllowMultipleConstraint to 0 if there is more than
 -- one constraint for this type
 IF (UPDATE (RT_AllowMultipleConstraints))
 BEGIN
 IF EXISTS
  (
   SELECT * 
   FROM  inserted I,
         dbo.RelationshipConstraints RC
   WHERE I.RT_RelationshipTypeID = RC.RC_RelationshipTypeID
   AND   I.RT_AllowMultipleConstraints  = 0
   GROUP BY RC.RC_RelationshipTypeID
   HAVING COUNT (*) > 1
  )
  BEGIN
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_RELATIONSHIPTYPE_SINGLE_CONSTRAINT_VIOLATION', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END
 END
 -- we do not allow the user to turn off the IsHighVolume flag if there is a constraint involving a high volume relation
 IF (UPDATE (RT_IsHighVolume)) AND EXISTS (SELECT * FROM inserted I, dbo.RelationshipConstraints RC, dbo.ClassSchemas CS
    WHERE I.RT_IsHighVolume = 0 AND I.RT_RelationshipTypeID = RC.RC_RelationshipTypeID AND
     (RC.RC_SourceClassID = CS.CS_ClassID OR RC.RC_TargetClassID = CS.CS_ClassID) AND
     CS.CS_IsHighVolume = 1)
  BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_HIGHVOLUMECLASS_CANNOT_HAVE_RELATIONSHIP', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
           RAISERROR (@errMsg, @severity, 1)
           ROLLBACK TRANSACTION
           RETURN
  END

 -- we do not allow multiple constraints for a high volume relationship
 IF EXISTS (SELECT * FROM inserted I WHERE I.RT_IsHighVolume = 1 AND I.RT_AllowMultipleConstraints = 1)
  BEGIN
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_RELATIONSHIPTYPE_SINGLE_CONSTRAINT_VIOLATION', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END
END
go


ALTER TABLE dbo.DatatypeDefinitions
    ADD CONSTRAINT smc_pk_DatatypeDefinitions
    PRIMARY KEY CLUSTERED (DD_DatatypeID)
go


ALTER TABLE dbo.DatatypeDefinitions
    WITH NOCHECK
    ADD CONSTRAINT CK_DatatypeDefinitions
    CHECK ([DD_MaxLength] >= 0)
go


CREATE TRIGGER dbo.triu_PropertyTypes_DatatypeUsage on dbo.PropertyTypes
FOR INSERT, UPDATE
AS
BEGIN
 SET NOCOUNT ON

 PRINT N'FOR INSERT/UPDATE trigger ' + OBJECT_NAME(@@PROCID) + N' firing'

 IF (UPDATE(PT_DatatypeID) OR UPDATE (PT_Length) OR UPDATE(PT_Scale) OR UPDATE (PT_Precision))
 BEGIN
  DECLARE @errMsg AS NVARCHAR(400)
  DECLARE @severity AS int
  DECLARE @msgID AS int
 
  -- in case length needs to be specified, ensure it is bigger than zero
  -- and ensure that the size is not greater than the maximum size specified for the
  -- datatype
  IF EXISTS
  (
   SELECT *
   FROM inserted I, 
        dbo.DatatypeDefinitions DD
   WHERE I.PT_DatatypeID   = DD.DD_DatatypeID
   AND   DD.DD_RequiresLength  = 1
   AND   (I.PT_Length <= 0 OR I.PT_Length > DD.DD_MaxLength)
  )
  BEGIN
   
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CHECK_LENGTH_DATATYPE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END
 
  -- if the datatype does not require a length, make sure that the length column is zero
  IF EXISTS
  (
   SELECT *
   FROM inserted I,
        dbo.DatatypeDefinitions DD
   WHERE I.PT_DatatypeID          = DD.DD_DatatypeID
   AND   DD.DD_RequiresLength  = 0
   AND   I.PT_Length <> 0
  )
  BEGIN
   EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DATATYPE_NEED_ZERO_LENGTH', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END

  -- if the datatype does not require a scale/precision, make sure that the scale/precision column is zero
  IF EXISTS
  (
   SELECT *
   FROM inserted I,
          dbo.DatatypeDefinitions DD
   WHERE I.PT_DatatypeID             = DD.DD_DatatypeID
   AND   DD.DD_RequiresScalePrecision = 0
   AND   (I.PT_Scale <> 0 OR I.PT_Precision <> 0)
  )
  BEGIN
   EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DATATYPE_NEED_ZERO_SCALE_PRECISION', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END
 END

 IF (UPDATE (PT_DatatypeID) OR UPDATE (PT_UDFValidationID))
 BEGIN

  IF EXISTS 
  (
   SELECT *
   FROM inserted I,
        dbo.DatatypeDefinitions DD
   WHERE I.PT_DatatypeID = DD.DD_DatatypeID
   AND  DD.DD_IsBlob = 1
   AND  I.PT_UDFValidationID IS NOT NULL
  )
  BEGIN
   EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_BLOBS_NEED_NO_VALIDATION', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END
 END
END
go


CREATE TRIGGER dbo.triu_ValidationUDFParameterValues_ValidateValue ON dbo.ValidationUDFParameterValues
AFTER INSERT, UPDATE
AS
BEGIN
 SET NOCOUNT ON
 PRINT N'FOR INSERT/UPDATE trigger ' + OBJECT_NAME(@@PROCID) + N' firing'

 IF (UPDATE (VUPV_Value) OR UPDATE (VUPV_ParamName) OR UPDATE (VUPV_ValidationUDFID))
 BEGIN
  -- we need to use a cursor because we need to create the CONVERT
  -- for each value that has changed. If we would do it in one string,
  -- we might run out of space (4000 nchar max)
  DECLARE cur CURSOR LOCAL FOR
   SELECT  VUPV_Value   AS ParamValue, 
    VUPV_ParamName  AS ParamName, 
    DD.DD_Name +
    CASE 
     WHEN DD.DD_RequiresLength = 1 
          THEN  '(' + CAST(VUP.VUP_ParamLength AS NVARCHAR(5)) + ')'
          WHEN DD.DD_RequiresScalePrecision = 1
          THEN '(' + CAST (VUP.VUP_ParamPrecision AS NVARCHAR(5)) + ',' + CAST (VUP.VUP_ParamScale AS NVARCHAR(5)) +')' 
    ELSE ''
    END AS SqlDatatype,
    DD.DD_Name as DatatypeName
   FROM inserted I,
        dbo.ValidationUDFParameters VUP,
        dbo.DatatypeDefinitions DD
   WHERE I.VUPV_ValidationUDFID = VUP.VUP_ValidationUDFID
   AND   I.VUPV_ParamName      = VUP.VUP_ParamName
   AND   DD.DD_DatatypeID      = VUP.VUP_ParamDatatypeID

  DECLARE @paramValue  as nvarchar(512)
  DECLARE @paramName   as nvarchar(128)
  DECLARE @sqlDatatype  as nvarchar(40)
  DECLARE @datatypeName as nvarchar(40)
  DECLARE @str as nvarchar(1000)

  OPEN cur

  FETCH NEXT FROM cur INTO @paramValue, @paramName, @sqlDatatype, @datatypeName
  WHILE @@FETCH_STATUS = 0
  BEGIN
   IF (@datatypeName IN ('nvarchar',  'nchar', 'ntext'))
   BEGIN
    SET @str = 'CONVERT (' + @sqlDatatype + ',N''' + @paramValue + ''')'
   END
   ELSE IF (@datatypeName IN ('bigint', 'int', 'smallint', 'tinyint', 'bit', 'decimal', 'numeric', 'real',
                                                   'float', 'money', 'smallmoney', 'binary', 'varbinary'))
   BEGIN
    SET @str = 'CONVERT (' + @sqlDatatype + ',' + @paramValue + ')'
   END
   ELSE
   BEGIN
    SET @str = 'CONVERT (' + @sqlDatatype + ',''' + @paramValue + ''')'
   END
 
   PRINT 'Verifying parameter value for property ' + @paramName + ': ' + @str

   DECLARE @strPossibleValue AS NVARCHAR(2000)
   SET @strPossibleValue = 'DECLARE @x AS ' + @sqlDatatype + ' SELECT @x = ' + @str
   EXEC dbo.sp_executesql @strPossibleValue

   FETCH NEXT FROM cur INTO @paramValue, @paramName, @sqlDatatype, @datatypeName
  END

  CLOSE cur
  DEALLOCATE cur
 END
END
go


ALTER TABLE dbo.DllDefinitions
    ADD CONSTRAINT smc_pk_DllDefinitions_DllID
    PRIMARY KEY CLUSTERED (DD_DllID)
go


ALTER TABLE dbo.EventsQueue
    ADD CONSTRAINT PK_EventsQueue
    PRIMARY KEY CLUSTERED (EQ_EventID)
go


ALTER TABLE dbo.EventsQueue
    WITH NOCHECK
    ADD CONSTRAINT smc_chk_EventQueue_Action
    CHECK ([EQ_Action] = 'D' or [EQ_Action] = 'U' or [EQ_Action] = 'I')
go


ALTER TABLE dbo.FileGroups
    ADD CONSTRAINT smc_pk_FileGroups
    PRIMARY KEY CLUSTERED (FG_FileGroupID)
go


ALTER TABLE dbo.GroomingSettings
    WITH NOCHECK
    ADD CONSTRAINT smc_chk_GroomingSettings_LiveDataPeriod
    CHECK ([GS_LiveDataPeriod] >= 1 and [GS_LiveDataPeriod] <= 60)
go


CREATE TRIGGER dbo.triud_GroomingSettings_RowCount ON [dbo].[GroomingSettings] 
FOR INSERT, UPDATE, DELETE 
AS
BEGIN
 SET NOCOUNT ON

 PRINT N'FOR INSERT, UPDATE, DELETE Trigger ' + OBJECT_NAME(@@PROCID) + N' firing'

 DECLARE @errMsg AS NVARCHAR(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int
 DECLARE @err AS int
 DECLARE @count AS int

 SELECT @count = COUNT(*) FROM dbo.GroomingSettings

 IF (@count <> 1)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_GROOMINGSETTINGS_ONE_ROW', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1)
     ROLLBACK TRANSACTION
     RETURN
 END

END
go


ALTER TABLE dbo.MetaVersion
    ADD CONSTRAINT PK_SMC_MetaVersion
    PRIMARY KEY CLUSTERED (MV_MajorVersion,MV_MinorVersion)
go


CREATE TABLE dbo.MethodParameterDefinitions
(
    MPD_MethodID        uniqueidentifier NOT NULL,
    MPD_Order           int              NOT NULL,
    MPD_ParameterName   nvarchar(128)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    MPD_ParameterTypeID int              NOT NULL,
    MPD_ParameterUsage  nvarchar(10)     COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
go


INSERT INTO SCR.dbo.MethodParameterDefinitions
( MPD_MethodID,
  MPD_Order,
  MPD_ParameterName,
  MPD_ParameterTypeID,
  MPD_ParameterUsage ) 
SELECT
MPD_MethodID,
MPD_Order,
MPD_ParameterName,
MPD_ParameterTypeID,
MPD_ParameterUsage
FROM SCR.dbo.MethodParameterDefinitions_ec02e7df
go


ALTER TABLE dbo.MethodParameterDefinitions
    ADD CONSTRAINT smc_pk_MethodParameterDefinitions_MethodID_Order
    PRIMARY KEY CLUSTERED (MPD_MethodID,MPD_Order)
go


ALTER TABLE dbo.MethodParameterDefinitions
    WITH NOCHECK
    ADD CONSTRAINT CK_MethodParameterDefinitions
    CHECK ([MPD_ParameterUsage] = 'INOUT' or [MPD_ParameterUsage] = 'OUT' or [MPD_ParameterUsage] = 'IN')
go


ALTER TABLE dbo.MethodParameterTypes
    ADD CONSTRAINT smc_pk_MethodParameterTypes_ParameterTypeID
    PRIMARY KEY CLUSTERED (MPT_ParameterTypeID)
go


CREATE UNIQUE NONCLUSTERED INDEX smc_idx_Modifications_TransactionToken
    ON dbo.Modifications(M_TransactionToken)
go


ALTER TABLE dbo.Modifications
    ADD CONSTRAINT PK_Modifications_ModificationID
    PRIMARY KEY CLUSTERED (M_ModificationID)
go


ALTER TABLE dbo.Modifications
    ADD CONSTRAINT smc_fk_Modifications_Users
    FOREIGN KEY (M_UserID)
    REFERENCES dbo.Users (U_UserID)
go


ALTER TABLE dbo.ProductSchema
    ADD CONSTRAINT smc_pk_ProductSchema_ProductID
    PRIMARY KEY CLUSTERED (PS_ProductID)
go


CREATE NONCLUSTERED INDEX smc_idx_PropertyInstances_InstanceID
    ON dbo.PropertyInstances(PI_InstanceID)
go


CREATE NONCLUSTERED INDEX smc_idx_PropertyInstances_PropertyID
    ON dbo.PropertyInstances(PI_ClassPropertyID)
go


ALTER TABLE dbo.PropertyInstances
    ADD CONSTRAINT smc_fk_PropertyInstances_ClassID_InstanceID_ClassPropertyID
    PRIMARY KEY CLUSTERED (PI_ClassID,PI_InstanceID,PI_ClassPropertyID)
go


CREATE TRIGGER dbo.triud_PropertyInstances_History ON dbo.PropertyInstances 
FOR INSERT, UPDATE, DELETE
AS
BEGIN
 SET NOCOUNT ON
 Print N'FOR INSERT, UPDATE, DELETE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

 DECLARE @errMsg AS nvarchar(400)
    DECLARE @severity AS int
    DECLARE @msgID AS int

 DECLARE @modid AS bigint
    EXEC dbo.smc_internal_getmodificationid @modid OUTPUT

    IF EXISTS (SELECT * FROM inserted)
    BEGIN
  UPDATE PI
  SET PI_StartModID = @modid
  FROM dbo.PropertyInstances PI, inserted I
  WHERE PI.PI_ClassID   = I.PI_ClassID
  AND   PI.PI_InstanceID   = I.PI_InstanceID
  AND   PI.PI_ClassPropertyID  = I.PI_ClassPropertyID

  IF (@@ERROR <> 0)
  BEGIN
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_UPDATE_PROPERTYINSTANCESAUDITS_TABLE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END
 END

 IF EXISTS (SELECT * FROM deleted)
 BEGIN
  INSERT INTO dbo.PropertyInstancesAudits
  (PIA_ClassID, PIA_ClassPropertyID, PIA_InstanceID, PIA_Value, PIA_StartModID, PIA_EndModID)
  SELECT PI_ClassID, PI_ClassPropertyID, PI_InstanceID, PI_Value, PI_StartModID, @modid
  FROM deleted
 
  IF (@@ERROR <> 0)
  BEGIN
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSERT_PROPERTYINSTANCESAUDITS_TABLE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END
 END
END
go


ALTER TABLE dbo.PropertyInstancesAudits
    ADD CONSTRAINT PK_PropertyInstancesAudits
    PRIMARY KEY CLUSTERED (PIA_ClassID,PIA_ClassPropertyID,PIA_InstanceID,PIA_StartModID)
go


CREATE TABLE dbo.PropertyTypeEnumerations
(
    PTE_EnumerationID    uniqueidentifier NOT NULL,
    PTE_PropertyTypeID   uniqueidentifier NOT NULL,
    PTE_EnumerationValue int              NOT NULL,
    PTE_Description      nvarchar(256)    COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
go


INSERT INTO SCR.dbo.PropertyTypeEnumerations
( PTE_EnumerationID,
  PTE_PropertyTypeID,
  PTE_EnumerationValue,
  PTE_Description ) 
SELECT
PTE_EnumerationID,
PTE_PropertyTypeID,
PTE_EnumerationValue,
PTE_Description
FROM SCR.dbo.PropertyTypeEnumerations_fb681fcf
go


ALTER TABLE dbo.PropertyTypeEnumerations
    ADD CONSTRAINT smc_pk_PropertyTypeEnumerations
    PRIMARY KEY CLUSTERED (PTE_EnumerationID)
go


ALTER TABLE dbo.PropertyTypeEnumerations
    ADD CONSTRAINT smc_idx_PropertyTypeEnumerations_PropType_Value_Unique
    UNIQUE NONCLUSTERED (PTE_PropertyTypeID,PTE_EnumerationValue)
go


CREATE TRIGGER dbo.triud_PropertyTypeEnumerations_Signed ON dbo.PropertyTypeEnumerations
FOR INSERT, UPDATE, DELETE 
AS
BEGIN 
    SET NOCOUNT ON
 
    PRINT N'FOR INSERT, UPDATE, DELETE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

    IF EXISTS ( SELECT PT.PT_TypeID
  FROM dbo.PropertyTypes AS PT
  JOIN (SELECT * FROM deleted UNION ALL
                      SELECT * FROM inserted ) AS M
         ON M.PTE_PropertyTypeID = PT.PT_TypeID
         WHERE PT.PT_Signed = 1 )
    BEGIN
 DECLARE @errResult AS integer
 DECLARE @errMsg AS nvarchar(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int

 EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_PROPERTYTYPEENUMERATIONS_CANNOT_MODIFY_SIGNED_PROPERTY', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
 RAISERROR (@errMsg, @severity, 1)
 ROLLBACK TRANSACTION
 RETURN 
    END

END
go


ALTER TABLE dbo.PropertyTypes
    ADD CONSTRAINT smc_pk_PropertyTypes_TypeID
    PRIMARY KEY CLUSTERED (PT_TypeID)
go


ALTER TABLE dbo.PropertyTypes
    ADD CONSTRAINT smc_fk_PropertyTypes_ValidationUDFs
    FOREIGN KEY (PT_UDFValidationID)
    REFERENCES dbo.ValidationUDFs (VU_ValidationUDFID)
go


ALTER TABLE dbo.PropertyTypes
    WITH NOCHECK
    ADD CONSTRAINT smc_chk_PropertyTypes_EnumDatatype_is_int
    CHECK ([PT_IsEnumeration] = 0 or [PT_IsEnumeration] = 1 and [PT_DatatypeID] = 2)
go


ALTER TABLE dbo.PropertyTypes
    WITH NOCHECK
    ADD CONSTRAINT smc_chk_PropertyTypes_Enumeration_No_UDF
    CHECK ([PT_IsEnumeration] = 0 or [PT_IsEnumeration] = 1 and [PT_UDFValidationID] is null)
go


ALTER TABLE dbo.PropertyTypes
    WITH NOCHECK
    ADD CONSTRAINT smc_chk_PropertyTypes_PropertyID_NOTEQUAL_ParentPropertyID
    CHECK ([PT_TypeID] <> [PT_ParentTypeID])
go


ALTER TABLE dbo.PropertyTypes
    WITH NOCHECK
    ADD CONSTRAINT smc_chk_PropertyTypes_ScalePrecision_Range
    CHECK ([PT_Scale] <= [PT_Precision] and [PT_Precision] <= @@max_precision and [PT_Precision] >= 0 and [PT_Scale] >= 0)
go


CREATE TRIGGER dbo.trud_PropertyTypes_Signed ON dbo.PropertyTypes
FOR UPDATE, DELETE 
AS
BEGIN  
    SET NOCOUNT ON

    PRINT N'FOR UPDATE, DELETE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

    IF EXISTS ( SELECT *
  FROM deleted          
         WHERE PT_Signed = 1 )
    BEGIN
 DECLARE @errResult AS integer
 DECLARE @errMsg AS nvarchar(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int

 EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CANNOT_MODIFY_SIGNED_PROPERTY', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
 RAISERROR (@errMsg, @severity, 1)
 ROLLBACK TRANSACTION
 RETURN 
    END
END
go


CREATE TRIGGER dbo.triud_ValidationUDFParameterValues_Signed ON dbo.ValidationUDFParameterValues
FOR INSERT, UPDATE, DELETE 
AS
BEGIN  
    SET NOCOUNT ON

    PRINT N'FOR INSERT, UPDATE, DELETE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

    IF EXISTS ( SELECT PT.PT_TypeID
  FROM dbo.PropertyTypes AS PT
  JOIN (SELECT * FROM deleted UNION ALL
                      SELECT * FROM inserted) AS M
         ON M.VUPV_PropertyTypeID = PT.PT_TypeID
         WHERE PT.PT_Signed = 1 )
    BEGIN
 DECLARE @errResult AS integer
 DECLARE @errMsg AS nvarchar(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int

 EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_VALIDATIONUDFPARAMETERVALUES_CANNOT_MODIFY_SIGNED_PROPERTYTYPE', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
 RAISERROR (@errMsg, @severity, 1)
 ROLLBACK TRANSACTION
 RETURN 
    END
END
go


CREATE TABLE dbo.RelationshipConstraints
(
    RC_ConstraintID       uniqueidentifier NOT NULL,
    RC_RelationshipTypeID uniqueidentifier NOT NULL,
    RC_SourceClassID      uniqueidentifier NOT NULL,
    RC_TargetClassID      uniqueidentifier NOT NULL,
    RC_TargetFK           uniqueidentifier NULL,
    RC_System             bit              CONSTRAINT DF_RelationshipConstraints_RC_System DEFAULT 0 NOT NULL
)
go


INSERT INTO SCR.dbo.RelationshipConstraints
( RC_ConstraintID,
  RC_RelationshipTypeID,
  RC_SourceClassID,
  RC_TargetClassID,
  RC_TargetFK,
  RC_System ) 
SELECT
RC_ConstraintID,
RC_RelationshipTypeID,
RC_SourceClassID,
RC_TargetClassID,
RC_TargetFK,
RC_System
FROM SCR.dbo.RelationshipConstraints_0540f2b5
go


CREATE NONCLUSTERED INDEX smx_idx_RelationshipConstraints_RelTypeID
    ON dbo.RelationshipConstraints(RC_RelationshipTypeID)
go


ALTER TABLE dbo.RelationshipConstraints
    ADD CONSTRAINT PK_RelationshipConstraints
    PRIMARY KEY CLUSTERED (RC_ConstraintID)
go


CREATE TRIGGER dbo.triu_RelationshipConstraints_Validate ON dbo.RelationshipConstraints
FOR INSERT, UPDATE
AS
BEGIN
 SET NOCOUNT ON

 PRINT N'FOR INSERT/UPDATE trigger ' + OBJECT_NAME(@@PROCID) + N' firing'

 -- don't allow relationshipconstraints for relationship types that are marked as
 -- non-constrainted (RT_IsConstrined = 0)

 IF NOT EXISTS (SELECT * from inserted)
 BEGIN
  RETURN
 END

 DECLARE @errMsg AS NVARCHAR(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int

 IF EXISTS 
 (
  SELECT * 
  FROM  inserted I, 
             dbo.RelationshipTypes RT
  WHERE I.RC_RelationshipTypeID = RT.RT_RelationshipTypeID
  AND   RT_IsConstrained = 0
 )
 BEGIN
     EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CONSTRAINT_FOR_NON_CONSTRAINT_RELATIONTYPE', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1)
     ROLLBACK TRANSACTION
     RETURN
 END

 -- verify that relationshiptypes that only allow a single constraint have at most one constraint
 IF EXISTS 
 (
  SELECT *
  FROM dbo.RelationshipConstraints RC, 
       dbo.RelationshipTypes RT
  WHERE RC.RC_RelationshipTypeID     = RT.RT_RelationshipTypeID
  AND   RT_AllowMultipleConstraints = 0
  GROUP BY RC.RC_RelationshipTypeID
  HAVING COUNT (*) > 1
 )
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_MULTIPLE_CONSTRAINT_FOR_SINGLE_CONSTRAINT_RELATIONTYPE', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1)
     ROLLBACK TRANSACTION
     RETURN
 END
END
go


CREATE TRIGGER dbo.triud_RelationshipConstraints_ViewInvalid ON dbo.RelationshipConstraints
FOR  INSERT, UPDATE, DELETE
AS
BEGIN

 SET NOCOUNT ON

     Print N'FOR INSERT, UPDATE, DELETE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

 UPDATE dbo.RelationshipTypes SET RT_ViewInvalid = 1 WHERE RT_RelationshipTypeID IN (SELECT RC_RelationshipTypeID FROM inserted) OR
   RT_RelationshipTypeID IN (SELECT RC_RelationshipTypeID from deleted)
   

END
go


CREATE TRIGGER dbo.trud_RelationshipConstrainsts_Signed ON dbo.RelationshipConstraints
FOR UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON

    PRINT N'FOR UPDATE, DELETE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

    -- Make sure none of the modified tables were signed
    IF EXISTS ( SELECT RT_RelationshipTypeID 
                FROM dbo.RelationshipTypes AS RT
  JOIN deleted AS D
  ON D.RC_RelationshipTypeID = RT.RT_RelationshipTypeID
                WHERE RT.RT_Signed = 1 )
    BEGIN
        DECLARE @errResult AS integer
 DECLARE @errMsg AS nvarchar(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int

        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_RELATIONSHIPCONSTRAINTS_CANNOT_MODIFY_SIGNED_RELATIONSHIPTYPE', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
 RAISERROR (@errMsg, @severity, 1)
 ROLLBACK TRANSACTION
 RETURN 
    END

END
go


CREATE TABLE dbo.RelationshipInstances
(
    RI_InstanceID         uniqueidentifier CONSTRAINT DF_InstanceRelationships_IR_RelationShipID DEFAULT newid() NOT NULL,
    RI_RelationshipTypeID uniqueidentifier NOT NULL,
    RI_SourceInstanceID   uniqueidentifier NOT NULL,
    RI_TargetInstanceID   uniqueidentifier NOT NULL,
    RI_Usage              char(1)          COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT DF_RelationshipInstances_RI_Usage DEFAULT 'S' NOT NULL,
    RI_StartModID         bigint           NOT NULL
)
go


INSERT INTO SCR.dbo.RelationshipInstances
( RI_InstanceID,
  RI_RelationshipTypeID,
  RI_SourceInstanceID,
  RI_TargetInstanceID,
  RI_Usage,
  RI_StartModID ) 
SELECT
RI_InstanceID,
RI_RelationshipTypeID,
RI_SourceInstanceID,
RI_TargetInstanceID,
RI_Usage,
RI_StartModID
FROM SCR.dbo.RelationshipInstances_40cdafc0
go


CREATE NONCLUSTERED INDEX smc_idx_InstanceRelationships_SourceInstanceID
    ON dbo.RelationshipInstances(RI_SourceInstanceID)
go


CREATE NONCLUSTERED INDEX smc_idx_InstanceRelationships_TargetInstanceID
    ON dbo.RelationshipInstances(RI_TargetInstanceID)
go


ALTER TABLE dbo.RelationshipInstances
    ADD CONSTRAINT smc_pk_InstanceRelationships
    PRIMARY KEY CLUSTERED (RI_RelationshipTypeID,RI_SourceInstanceID,RI_TargetInstanceID)
go


ALTER TABLE dbo.RelationshipInstances
    ADD CONSTRAINT smc_idx_RelationshipInstances_RelationshipID_Unique
    UNIQUE NONCLUSTERED (RI_InstanceID)
go


ALTER TABLE dbo.RelationshipInstances
    WITH NOCHECK
    ADD CONSTRAINT smc_chk_RelationshipInstances_Usage
    CHECK ([RI_Usage] = 'D' or [RI_Usage] = 'S' or [RI_Usage] = 'X')
go


CREATE TRIGGER dbo.tri_RelationshipInstances_EnforceCardinality on dbo.RelationshipInstances
FOR INSERT
AS
BEGIN
 SET NOCOUNT ON

 PRINT N'FOR INSERT Trigger ' + OBJECT_NAME(@@PROCID) + N' firing'

 IF NOT EXISTS (SELECT * FROM inserted)
 BEGIN
  RETURN
 END

 DECLARE @errMsg AS NVARCHAR(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int
 DECLARE @err AS int


 -- For 1:1 relationships we have to ensure that for a particular relationshiptype, both
 -- the source and the target can be used in one and only one relationship instance.
 -- For instance, suppose we have Agent1, Agent2 and Agent3, and Computer1, Computer2 and
 -- computer3. Further we have 1:1 relationship between Agent and Computer called 
 -- AgentIsInstalledOnComputer
 -- Suppose we create a relationship between Agent1 and Computer1
 -- After the relationship is there, Agent1 cannot be part of any other relationship (for this
 -- relationshiptype) and Computer1 cannot be part of any other relationship (for this type)
 --
 -- For 1:N, only the Target cannot be part of more than one relationship, i.e. suppose I
 -- have a 1:N relationship between Agent adn Computers (i.e. an AgentMonitorsComputer)
 -- One agent can monitor multiple computers, but one computer can only be monitored by a
 -- single agent. In this case, the source can be part of multiple relatoinship instances, but
 -- the target can only be part of a single relationship.
 
 IF EXISTS 
 (
  SELECT *
  FROM dbo.RelationshipInstances RI,
       dbo.RelationshipTypes RT
  WHERE RI.RI_RelationshipTypeID  = RT.RT_RelationshipTypeID
  AND   RT.RT_Cardinality  = '1:1'
  AND   EXISTS
        ( 
     SELECT *
     FROM inserted I
     WHERE I.RI_SourceInstanceID   = RI.RI_SourceInstanceID
     AND   I.RI_RelationshipTypeID = RI.RI_RelationshipTypeID
        )
  GROUP BY RI.RI_RelationshipTypeID, RI.RI_SourceInstanceID
  HAVING COUNT (*) > 1
 )
 BEGIN 
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_RELATIONSHIP_CARDINALITY_CHECK_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
  RAISERROR (@errMsg, @severity, 1)
  ROLLBACK TRANSACTION
  RETURN
 END

 --1:N
 IF EXISTS 
 (
  SELECT *
  FROM dbo.RelationshipInstances RI,
       dbo.RelationshipTypes RT
  WHERE RI.RI_RelationshipTypeID  = RT.RT_RelationshipTypeID
  AND   RT.RT_Cardinality  IN ('1:1', '1:N', '0..1:N')
  AND EXISTS
      (
   SELECT *
   FROM inserted I
   WHERE I.RI_TargetInstanceID   = RI.RI_TargetInstanceID
   AND   I.RI_RelationshipTypeID = RI.RI_RelationshipTypeID
    
      )
  GROUP BY RI.RI_RelationshipTypeID, RI.RI_TargetInstanceID
  HAVING COUNT (*) > 1
 )
 BEGIN 
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_RELATIONSHIP_CARDINALITY_CHECK_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
  RAISERROR (@errMsg, @severity, 1)
  ROLLBACK TRANSACTION
  RETURN
 END
END
go


CREATE TRIGGER dbo.triud_RelationshipInstances_History ON dbo.RelationshipInstances 
FOR INSERT, UPDATE, DELETE
AS
BEGIN
 SET NOCOUNT ON
 Print N'FOR INSERT, UPDATE, DELETE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

 DECLARE @errMsg AS nvarchar(400)
    DECLARE @severity AS int
    DECLARE @msgID AS int

 DECLARE @modid AS bigint
    EXEC dbo.smc_internal_getmodificationid @modid OUTPUT

    IF EXISTS (SELECT * FROM inserted)
    BEGIN
  UPDATE RI
   SET RI_StartModID = @modid
  FROM dbo.RelationshipInstances RI, inserted I
  WHERE RI.RI_InstanceID = I.RI_InstanceID

  IF (@@ERROR <> 0)
  BEGIN 
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_UPDATE_INSTANCERELATIONSHIPSAUDITS_TABLE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END
 END

 IF EXISTS (SELECT * FROM deleted)
 BEGIN
  INSERT INTO dbo.RelationshipInstancesAudits
  (RIA_InstanceID, RIA_RelationshipTypeID, RIA_SourceInstanceID, RIA_TargetInstanceID, 
   RIA_Usage, RIA_StartModID, RIA_EndModID)
  SELECT RI_InstanceID, RI_RelationshipTypeID, RI_SourceInstanceID, RI_TargetInstanceID, 
         RI_Usage, RI_StartModID, @modid
  FROM deleted
 
  IF (@@ERROR <> 0)
  BEGIN
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSERT_INSTANCERELATIONSHIPSAUDITS_TABLE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END
 END
END
go


CREATE TRIGGER dbo.tru_RelationshipInstances_Validate on dbo.RelationshipInstances
FOR UPDATE
AS
BEGIN
 SET NOCOUNT ON

 PRINT N'FOR UPDATE Trigger ' + OBJECT_NAME(@@PROCID) + N' firing'

 IF UPDATE (RI_SourceInstanceID) OR UPDATE (RI_TargetInstanceID)
 BEGIN 

  DECLARE @errMsg AS NVARCHAR(400)
  DECLARE @severity AS int
  DECLARE @msgID AS int
  DECLARE @err AS int

  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_RELATIONSHIP_CANNOT_UPDATE_SRC_TARGET', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
  RAISERROR (@errMsg, @severity, 1)
  ROLLBACK TRANSACTION
  RETURN
 END
END
go


CREATE TRIGGER dbo.trd_SMC_GroupMembers ON [dbo].[SMC_GroupMembers]
INSTEAD OF DELETE AS
BEGIN
   SET NOCOUNT ON

   Print N'DELETE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

   IF NOT EXISTS (SELECT * FROM deleted)
   BEGIN
      RETURN
   END

   DECLARE @errResult AS integer
   DECLARE @errMsg AS nvarchar(400)
   DECLARE @severity AS int
   DECLARE @msgID AS int

   DELETE RI
   FROM dbo.RelationshipInstances RI, deleted D
   WHERE RI.RI_InstanceID = SMC_InstanceID

   SET @errResult = @@ERROR
   IF (@errResult <> 0)
   BEGIN
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_RELATIONSHIPINSTANCES_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
   END
END
go


CREATE TABLE dbo.RelationshipInstancesAudits
(
    RIA_InstanceID         uniqueidentifier NOT NULL,
    RIA_RelationshipTypeID uniqueidentifier NOT NULL,
    RIA_SourceInstanceID   uniqueidentifier NOT NULL,
    RIA_TargetInstanceID   uniqueidentifier NULL,
    RIA_Usage              char(1)          COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    RIA_StartModID         bigint           NOT NULL,
    RIA_EndModID           bigint           NOT NULL,
    RIA_SuserSid           varbinary(85)    CONSTRAINT DF__Relations__RIA_S__173876EA DEFAULT suser_sid() NULL
)
go


INSERT INTO SCR.dbo.RelationshipInstancesAudits
( RIA_InstanceID,
  RIA_RelationshipTypeID,
  RIA_SourceInstanceID,
  RIA_TargetInstanceID,
  RIA_Usage,
  RIA_StartModID,
  RIA_EndModID,
  RIA_SuserSid ) 
SELECT
RIA_InstanceID,
RIA_RelationshipTypeID,
RIA_SourceInstanceID,
RIA_TargetInstanceID,
RIA_Usage,
RIA_StartModID,
RIA_EndModID,
RIA_SuserSid
FROM SCR.dbo.RelationshipInstancesAudits_6770f36c
go


ALTER TABLE dbo.RelationshipInstancesAudits
    ADD CONSTRAINT PK_RelationshipInstancesAudits
    PRIMARY KEY CLUSTERED (RIA_InstanceID,RIA_StartModID)
go


ALTER TABLE dbo.RelationshipTypes
    ADD CONSTRAINT smc_pk_RelationshipTypes_Type
    PRIMARY KEY CLUSTERED (RT_RelationshipTypeID)
go


ALTER TABLE dbo.RelationshipTypes
    WITH NOCHECK
    ADD CONSTRAINT smc_chk_RelationshipTypes_Cardinality
    CHECK ([RT_Cardinality] = 'M:N' or [RT_Cardinality] = '1:N' or [RT_Cardinality] = '1:1' or [RT_Cardinality] = '0..1:N')
go


ALTER TABLE dbo.RelationshipTypes
    WITH NOCHECK
    ADD CONSTRAINT smc_chk_RelationshipTypes_ViewSrcName_NotEqual_ViewTargetName
    CHECK ([RT_ViewSrcName] <> [RT_ViewTargetName])
go


CREATE TRIGGER dbo.triu_RelationshipTypes_PopulateNames on dbo.RelationshipTypes
FOR INSERT, UPDATE
AS
BEGIN
 SET NOCOUNT ON

 PRINT N'FOR INSERT,UPDATE Trigger ' + OBJECT_NAME(@@PROCID) + N' firing'

 IF NOT EXISTS (SELECT * FROM inserted)
 BEGIN
  RETURN
 END

 DECLARE @errMsg AS NVARCHAR(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int
 DECLARE @err AS int

 -- we always want names for viewname, etc. If the user specified NULL, we automatically generate
 -- one for them
 IF (UPDATE (RT_Name) OR UPDATE (RT_ViewName) OR 
            UPDATE (RT_HistoryUDFName) OR UPDATE (RT_HistoryViewName))
 BEGIN
  UPDATE RT
  SET RT_ViewName   = ISNULL (I.RT_ViewName,         N'SC_Rel_' + I.RT_Name +'_View'),
      RT_HistoryUDFName    = ISNULL (I.RT_HistoryUDFName,   N'SMC_Rel_' + I.RT_Name + N'_Hist'),
      RT_HistoryViewName   = ISNULL (I.RT_HistoryViewName,  N'SMC_Rel_' + I.RT_Name + N'_TT')
  FROM dbo.RelationshipTypes RT, inserted I
  WHERE RT.RT_RelationshipTypeID = I.RT_RelationshipTypeID
  
  IF (@err <> 0)
  BEGIN
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSERT_RELATIONSHIPTYPES_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END

  -- verify that the object names are still unique
  IF (dbo.SMC_Internal_DBHasUniqueObjectNames()  <> 1)
  BEGIN 
   EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_OBJECTNAMES_UNIQUE', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
   RAISERROR (@errMsg, @severity, 1)
   ROLLBACK TRANSACTION
   RETURN
  END
 END
END
go


CREATE TRIGGER dbo.tru_RelationshipTypes_ViewInvalid ON dbo.RelationshipTypes
FOR  UPDATE  AS
BEGIN

 SET NOCOUNT ON

 -- Don't do anything if the ViewInvalid bit is being explicitly set or cleared
 -- this limits nesting and allows us to clear the bit when invalid views have 
 -- been dropped.
 
 IF UPDATE(RT_ViewInvalid)
  RETURN
  
     Print N'FOR UPDATE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

 
 UPDATE dbo.RelationshipTypes SET RT_ViewInvalid = 1 WHERE RT_RelationshipTypeID IN (SELECT RT_RelationshipTypeID FROM inserted) 
  AND RT_ViewInvalid = 0 AND RT_System = 0
   

END
go


CREATE TRIGGER dbo.trud_RelationshipTypes_Signed ON dbo.RelationshipTypes
FOR UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON

    PRINT N'FOR UPDATE, DELETE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

    -- Make sure none of the modified tables were signed
    IF EXISTS ( SELECT * 
                FROM deleted
                WHERE RT_Signed = 1 )
    BEGIN
        DECLARE @errResult AS integer
 DECLARE @errMsg AS nvarchar(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int

        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CANNOT_MODIFY_SIGNED_RELATIONSHIPTYPE', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
 RAISERROR (@errMsg, @severity, 1)
 ROLLBACK TRANSACTION
 RETURN 
    END

END
go


CREATE NONCLUSTERED INDEX AlertFact_AlertLevelFK_Index
    ON dbo.SC_AlertFact_Table(AlertLevel_FK)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX AlertFact_AlertName_Index
    ON dbo.SC_AlertFact_Table(AlertName)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX AlertFact_ComputerFK_Index
    ON dbo.SC_AlertFact_Table(Computer_FK)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX AlertFact_ConfigurationGroupFK_DateTimeAdded_Index
    ON dbo.SC_AlertFact_Table(ConfigurationGroup_FK,DateTimeAdded DESC)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX AlertFact_LocalDateTimeRaised_Index
    ON dbo.SC_AlertFact_Table(LocalDateTimeRaised)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX AlertFact_LocalDateTimeResolved_Index
    ON dbo.SC_AlertFact_Table(LocalDateTimeResolved)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX AlertFact_ProcessRuleFK_Index
    ON dbo.SC_AlertFact_Table(ProcessRule_FK)
  WITH FILLFACTOR = 98
go


CREATE UNIQUE CLUSTERED INDEX AlertFact_SMCInstanceID_ClusteredIndex
    ON dbo.SC_AlertFact_Table(SMC_InstanceID)
  WITH FILLFACTOR = 98
go


ALTER TABLE dbo.SC_AlertFact_Table
    ADD CONSTRAINT SC_AlertFact_Table_PK
    PRIMARY KEY NONCLUSTERED (AlertID_PK)
go


CREATE NONCLUSTERED INDEX AlertHistoryFact_ConfigurationGroupFK_DateTimeLastModified_Index
    ON dbo.SC_AlertHistoryFact_Table(ConfigurationGroup_FK,DateTimeLastModified DESC)
  WITH FILLFACTOR = 98
go


ALTER TABLE dbo.SC_AlertHistoryFact_Table
    ADD CONSTRAINT SC_AlertHistoryFact_Table_PK
    PRIMARY KEY CLUSTERED (SMC_InstanceID)
go


CREATE UNIQUE NONCLUSTERED INDEX AlertLevelDimension_SurrogateKey_Index
    ON dbo.SC_AlertLevelDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 70
go


ALTER TABLE dbo.SC_AlertLevelDimension_Table
    ADD CONSTRAINT SC_AlertLevelDimension_Table_PK
    PRIMARY KEY CLUSTERED (AlertLevel_PK)
go


CREATE UNIQUE NONCLUSTERED INDEX AlertResolutionStateDimension_SurrogateKey_Index
    ON dbo.SC_AlertResolutionStateDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 70
go


ALTER TABLE dbo.SC_AlertResolutionStateDimension_Table
    ADD CONSTRAINT SC_AlertResolutionStateDimension_Table_PK
    PRIMARY KEY CLUSTERED (AlertResolutionState_PK)
go


CREATE NONCLUSTERED INDEX AlertToEventFact_ConfigurationGroupFK_DateTimeEventStored_Index
    ON dbo.SC_AlertToEventFact_Table(ConfigurationGroup_FK,DateTimeEventStored DESC)
  WITH FILLFACTOR = 98
go


ALTER TABLE dbo.SC_AlertToEventFact_Table
    ADD CONSTRAINT SC_AlertToEventFact_Table_PK
    PRIMARY KEY CLUSTERED (SMC_InstanceID)
go


CREATE UNIQUE NONCLUSTERED INDEX ClassAttributeDefinitionDimension_SurrogateKey_Index
    ON dbo.SC_ClassAttributeDefinitionDimension_Table(SMC_InstanceID DESC)
  WITH FILLFACTOR = 70
go


ALTER TABLE dbo.SC_ClassAttributeDefinitionDimension_Table
    ADD CONSTRAINT SC_ClassAttributeDefinitionDimension_Table_PK
    PRIMARY KEY CLUSTERED (ClassAttributeID_PK)
go


CREATE NONCLUSTERED INDEX ClassAttributeInstanceFact_ClassAttributeDefinitionFK_Index
    ON dbo.SC_ClassAttributeInstanceFact_Table(ClassAttributeDefinition_FK)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX ClassAttributeInstanceFact_ClassInstanceID_Index
    ON dbo.SC_ClassAttributeInstanceFact_Table(ClassInstanceID)
  WITH FILLFACTOR = 98
go


CREATE CLUSTERED INDEX ClassAttributeInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex
    ON dbo.SC_ClassAttributeInstanceFact_Table(ConfigurationGroup_FK,DateTimeOfTransfer)
  WITH FILLFACTOR = 98
go


ALTER TABLE dbo.SC_ClassAttributeInstanceFact_Table
    ADD CONSTRAINT SC_ClassAttributeInstanceFact_Table_PK
    PRIMARY KEY NONCLUSTERED (SMC_InstanceID)
go


CREATE UNIQUE NONCLUSTERED INDEX ClassDefinitionDimension_SurrogateKey_Index
    ON dbo.SC_ClassDefinitionDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 70
go


ALTER TABLE dbo.SC_ClassDefinitionDimension_Table
    ADD CONSTRAINT SC_ClassDefinitionDimension_Table_PK
    PRIMARY KEY CLUSTERED (ClassID_PK)
go


CREATE NONCLUSTERED INDEX ClassInstanceFact_ClassDefinitionFK_Index
    ON dbo.SC_ClassInstanceFact_Table(ClassDefinition_FK)
  WITH FILLFACTOR = 98
go


CREATE CLUSTERED INDEX ClassInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex
    ON dbo.SC_ClassInstanceFact_Table(ConfigurationGroup_FK,DateTimeOfTransfer)
  WITH FILLFACTOR = 98
go


ALTER TABLE dbo.SC_ClassInstanceFact_Table
    ADD CONSTRAINT SC_ClassInstanceFact_Table_PK
    PRIMARY KEY NONCLUSTERED (SMC_InstanceID)
go


CREATE NONCLUSTERED INDEX ComputerDimension_FullComputerName_Index
    ON dbo.SC_ComputerDimension_Table(FullComputerName)
  WITH FILLFACTOR = 70
go


CREATE UNIQUE NONCLUSTERED INDEX ComputerDimension_SurrogateKey_Index
    ON dbo.SC_ComputerDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 70
go


ALTER TABLE dbo.SC_ComputerDimension_Table
    ADD CONSTRAINT SC_ComputerDimension_Table_PK
    PRIMARY KEY CLUSTERED (ComputerDomain_PK,ComputerName_PK)
go


CREATE UNIQUE NONCLUSTERED INDEX ComputerRuleDimension_SurrogateKey_Index
    ON dbo.SC_ComputerRuleDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 70
go


ALTER TABLE dbo.SC_ComputerRuleDimension_Table
    ADD CONSTRAINT SC_ComputerRuleDimension_Table_PK
    PRIMARY KEY CLUSTERED (ComputerRuleID_PK)
go


CREATE CLUSTERED INDEX ComputerRuleToProcessRuleGroupFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex
    ON dbo.SC_ComputerRuleToProcessRuleGroupFact_Table(ConfigurationGroup_FK,DateTimeOfTransfer)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX ComputerRuleToProcessRuleGroupFact_ConfigurationGroupFK_DateTimeOfTransfer_ComputerRuleFK_Index
    ON dbo.SC_ComputerRuleToProcessRuleGroupFact_Table(ConfigurationGroup_FK,DateTimeOfTransfer,ComputerRule_FK)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX ComputerRuleToProcessRuleGroupFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleGroupFK_Index
    ON dbo.SC_ComputerRuleToProcessRuleGroupFact_Table(ConfigurationGroup_FK,DateTimeOfTransfer,ProcessRuleGroup_FK)
  WITH FILLFACTOR = 98
go


ALTER TABLE dbo.SC_ComputerRuleToProcessRuleGroupFact_Table
    ADD CONSTRAINT SC_ComputerRuleToProcessRuleGroupFact_Table_PK
    PRIMARY KEY NONCLUSTERED (SMC_InstanceID)
go


CREATE CLUSTERED INDEX ComputerToComputerRuleFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex
    ON dbo.SC_ComputerToComputerRuleFact_Table(ConfigurationGroup_FK,DateTimeOfTransfer)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX ComputerToComputerRuleFact_ConfigurationGroupFK_DateTimeOfTransfer_ComputerFK_Index
    ON dbo.SC_ComputerToComputerRuleFact_Table(ConfigurationGroup_FK,DateTimeOfTransfer,Computer_FK)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX ComputerToComputerRuleFact_ConfigurationGroupFK_DateTimeOfTransfer_ComputerRuleFK_Index
    ON dbo.SC_ComputerToComputerRuleFact_Table(ConfigurationGroup_FK,DateTimeOfTransfer,ComputerRule_FK)
  WITH FILLFACTOR = 98
go


ALTER TABLE dbo.SC_ComputerToComputerRuleFact_Table
    ADD CONSTRAINT SC_ComputerToComputerRuleFact_Table_PK
    PRIMARY KEY NONCLUSTERED (SMC_InstanceID)
go


CREATE UNIQUE NONCLUSTERED INDEX ComputerToConfigurationGroupDimension_SurrogateKey_Index
    ON dbo.SC_ComputerToConfigurationGroupDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 70
go


ALTER TABLE dbo.SC_ComputerToConfigurationGroupDimension_Table
    ADD CONSTRAINT SC_ComputerToConfigurationGroupDimension_Table_PK
    PRIMARY KEY CLUSTERED (Computer_FK_PK,ConfigurationGroup_FK_PK)
go


CREATE UNIQUE NONCLUSTERED INDEX ConfigurationGroupDimension_SurrogateKey_Index
    ON dbo.SC_ConfigurationGroupDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 70
go


ALTER TABLE dbo.SC_ConfigurationGroupDimension_Table
    ADD CONSTRAINT SC_ConfigurationGroupDimension_Table_PK
    PRIMARY KEY CLUSTERED (ConfigurationGroupID_PK)
go


CREATE UNIQUE NONCLUSTERED INDEX CounterDetailDimension_SurrogateKey_Index
    ON dbo.SC_CounterDetailDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 70
go


ALTER TABLE dbo.SC_CounterDetailDimension_Table
    ADD CONSTRAINT SC_CounterDetailDimension_Table_PK
    PRIMARY KEY CLUSTERED (CounterName_PK,InstanceName_PK,ObjectName_PK)
go


CREATE UNIQUE NONCLUSTERED INDEX DateDimension_SurrogateKey_Index
    ON dbo.SC_DateDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 98
go


ALTER TABLE dbo.SC_DateDimension_Table
    ADD CONSTRAINT SC_DateDimension_Table_PK
    PRIMARY KEY CLUSTERED (DateDay_PK,DateMonth_PK,DateYear_PK)
go


CREATE NONCLUSTERED INDEX EventDetailDimension_EventIDPK_Index
    ON dbo.SC_EventDetailDimension_Table(EventID_PK)
  WITH FILLFACTOR = 50
go


CREATE UNIQUE NONCLUSTERED INDEX EventDetailDimension_SurrogateKey_Index
    ON dbo.SC_EventDetailDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 50
go


ALTER TABLE dbo.SC_EventDetailDimension_Table
    ADD CONSTRAINT SC_EventDetailDimension_Table_PK
    PRIMARY KEY CLUSTERED (Category_PK,EventID_PK,EventSource_PK,Language_PK,MsgID_PK)
go


CREATE NONCLUSTERED INDEX EventFact_ComputerFK_Index
    ON dbo.SC_EventFact_Table(Computer_FK)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX EventFact_ConfigurationGroupFK_DateTimeStored_Index
    ON dbo.SC_EventFact_Table(ConfigurationGroup_FK,DateTimeStored DESC)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX EventFact_EventDetailFK_Index
    ON dbo.SC_EventFact_Table(EventDetail_FK)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX EventFact_EventType_Index
    ON dbo.SC_EventFact_Table(EventType_FK)
  WITH FILLFACTOR = 98
go


CREATE CLUSTERED INDEX EventFact_LocalDateTimeGenerated_ClusteredIndex
    ON dbo.SC_EventFact_Table(LocalDateTimeGenerated)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX EventFact_ProviderDetailFK_Index
    ON dbo.SC_EventFact_Table(ProviderDetail_FK)
  WITH FILLFACTOR = 98
go


ALTER TABLE dbo.SC_EventFact_Table
    ADD CONSTRAINT SC_EventFact_Table_PK
    PRIMARY KEY NONCLUSTERED (SMC_InstanceID)
go


CREATE NONCLUSTERED INDEX EventParameterFact_ConfigurationGroupFK_DateTimeEventStored_Index
    ON dbo.SC_EventParameterFact_Table(ConfigurationGroup_FK,DateTimeEventStored DESC)
  WITH FILLFACTOR = 98
go


ALTER TABLE dbo.SC_EventParameterFact_Table
    ADD CONSTRAINT SC_EventParameterFact_Table_PK
    PRIMARY KEY CLUSTERED (SMC_InstanceID)
go


CREATE UNIQUE NONCLUSTERED INDEX EventTypeDimension_SurrogateKey_Index
    ON dbo.SC_EventTypeDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 98
go


ALTER TABLE dbo.SC_EventTypeDimension_Table
    ADD CONSTRAINT SC_EventTypeDimension_Table_PK
    PRIMARY KEY CLUSTERED (EventType_PK)
go


CREATE UNIQUE NONCLUSTERED INDEX OperationalData_SurrogateKey_Index
    ON dbo.SC_OperationalDataDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 70
go


ALTER TABLE dbo.SC_OperationalDataDimension_Table
    ADD CONSTRAINT SC_OperationalDataDimension_Table_PK
    PRIMARY KEY CLUSTERED (OperationalDataID)
go


CREATE NONCLUSTERED INDEX ProcessRuleDimension_ProcessRuleName_Index
    ON dbo.SC_ProcessRuleDimension_Table(ProcessRuleName)
  WITH FILLFACTOR = 70
go


CREATE NONCLUSTERED INDEX ProcessRuleDimension_ProviderDetailFK_Index
    ON dbo.SC_ProcessRuleDimension_Table(ProviderDetail_FK)
  WITH FILLFACTOR = 70
go


CREATE UNIQUE NONCLUSTERED INDEX ProcessRuleDimension_SurrogateKey_Index
    ON dbo.SC_ProcessRuleDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 70
go


ALTER TABLE dbo.SC_ProcessRuleDimension_Table
    ADD CONSTRAINT SC_ProcessRuleDimension_Table_PK
    PRIMARY KEY CLUSTERED (ProcessRuleID_PK)
go


CREATE CLUSTERED INDEX ProcessRuleMembershipFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex
    ON dbo.SC_ProcessRuleMembershipFact_Table(ConfigurationGroup_FK,DateTimeOfTransfer)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX ProcessRuleMembershipFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleGroupFK_Index
    ON dbo.SC_ProcessRuleMembershipFact_Table(ConfigurationGroup_FK,DateTimeOfTransfer,ProcessRuleGroup_FK)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX ProcessRuleMembershipFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleMemberFK_Index
    ON dbo.SC_ProcessRuleMembershipFact_Table(ConfigurationGroup_FK,DateTimeOfTransfer,ProcessRuleMember_FK)
  WITH FILLFACTOR = 98
go


ALTER TABLE dbo.SC_ProcessRuleMembershipFact_Table
    ADD CONSTRAINT SC_ProcessRuleMembershipFact_Table_PK
    PRIMARY KEY NONCLUSTERED (SMC_InstanceID)
go


CREATE UNIQUE NONCLUSTERED INDEX ProcessRuleToConfigurationGroupDimension_SurrogateKey_Index
    ON dbo.SC_ProcessRuleToConfigurationGroupDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 70
go


ALTER TABLE dbo.SC_ProcessRuleToConfigurationGroupDimension_Table
    ADD CONSTRAINT SC_ProcessRuleToConfigurationGroupDimension_Table_PK
    PRIMARY KEY CLUSTERED (ConfigurationGroup_FK_PK,ProcessRule_FK_PK)
go


CREATE CLUSTERED INDEX ProcessRuleToScriptFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex
    ON dbo.SC_ProcessRuleToScriptFact_Table(ConfigurationGroup_FK,DateTimeOfTransfer)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX ProcessRuleToScriptFact_ConfigurationGroupFK_DateTimeOfTransfer_ProcessRuleFK_Index
    ON dbo.SC_ProcessRuleToScriptFact_Table(ConfigurationGroup_FK,DateTimeOfTransfer,ProcessRule_FK)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX ProcessRuleToScriptFact_ConfigurationGroupFK_DateTimeOfTransfer_ScriptFK_Index
    ON dbo.SC_ProcessRuleToScriptFact_Table(ConfigurationGroup_FK,DateTimeOfTransfer,Script_FK)
  WITH FILLFACTOR = 98
go


ALTER TABLE dbo.SC_ProcessRuleToScriptFact_Table
    ADD CONSTRAINT SC_ProcessRuleToScriptFact_Table_PK
    PRIMARY KEY NONCLUSTERED (SMC_InstanceID)
go


CREATE NONCLUSTERED INDEX ProviderDetailDimension_ProviderInstanceName_Index
    ON dbo.SC_ProviderDetailDimension_Table(ProviderInstanceName)
  WITH FILLFACTOR = 70
go


CREATE UNIQUE NONCLUSTERED INDEX ProviderDetailDimension_SurrogateKey_Index
    ON dbo.SC_ProviderDetailDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 70
go


ALTER TABLE dbo.SC_ProviderDetailDimension_Table
    ADD CONSTRAINT SC_ProviderDetailDimension_Table_PK
    PRIMARY KEY CLUSTERED (ProviderInstanceID_PK)
go


CREATE UNIQUE NONCLUSTERED INDEX RelationshipAttributeDefinitionDimension_SurrogateKey_Index
    ON dbo.SC_RelationshipAttributeDefinitionDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 70
go


ALTER TABLE dbo.SC_RelationshipAttributeDefinitionDimension_Table
    ADD CONSTRAINT SC_RelationshipAttributeDefinitionDimension_Table_PK
    PRIMARY KEY CLUSTERED (RelationshipAttributeID_PK)
go


CREATE CLUSTERED INDEX RelationshipAttributeInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex
    ON dbo.SC_RelationshipAttributeInstanceFact_Table(ConfigurationGroup_FK,DateTimeOfTransfer)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX RelationshipAttributeInstanceFact_RelationshipAttributeDefinitionFK_Index
    ON dbo.SC_RelationshipAttributeInstanceFact_Table(RelationshipAttributeDefinition_FK)
  WITH FILLFACTOR = 98
go


ALTER TABLE dbo.SC_RelationshipAttributeInstanceFact_Table
    ADD CONSTRAINT SC_RelationshipAttributeInstanceFact_Table_PK
    PRIMARY KEY NONCLUSTERED (SMC_InstanceID)
go


CREATE UNIQUE NONCLUSTERED INDEX RelationshipDefinitionDimension_SurrogateKey_Index
    ON dbo.SC_RelationshipDefinitionDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 70
go


ALTER TABLE dbo.SC_RelationshipDefinitionDimension_Table
    ADD CONSTRAINT SC_RelationshipDefinitionDimension_Table_PK
    PRIMARY KEY CLUSTERED (RelationshipTypeID_PK)
go


CREATE CLUSTERED INDEX RelationshipInstanceFact_ConfigurationGroupFK_DateTimeOfTransfer_ClusteredIndex
    ON dbo.SC_RelationshipInstanceFact_Table(ConfigurationGroup_FK,DateTimeOfTransfer)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX RelationshipInstanceFact_RelationshipDefinitionFK_Index
    ON dbo.SC_RelationshipInstanceFact_Table(RelationshipDefinition_FK)
  WITH FILLFACTOR = 98
go


ALTER TABLE dbo.SC_RelationshipInstanceFact_Table
    ADD CONSTRAINT SC_RelationshipInstanceFact_Table_PK
    PRIMARY KEY NONCLUSTERED (SMC_InstanceID)
go


CREATE NONCLUSTERED INDEX SampledNumericDataFact_ComputerFK_Index
    ON dbo.SC_SampledNumericDataFact_Table(Computer_FK)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX SampledNumericDataFact_ConfigurationGroupFK_DateTimeAdded_Index
    ON dbo.SC_SampledNumericDataFact_Table(ConfigurationGroup_FK,DateTimeAdded DESC)
  WITH FILLFACTOR = 98
go


CREATE NONCLUSTERED INDEX SampledNumericDataFact_CounterDetailFK_Index
    ON dbo.SC_SampledNumericDataFact_Table(CounterDetail_FK)
  WITH FILLFACTOR = 98
go


CREATE CLUSTERED INDEX SampledNumericDataFact_LocalDateTimeSampled_ClusteredIndex
    ON dbo.SC_SampledNumericDataFact_Table(LocalDateTimeSampled)
  WITH FILLFACTOR = 98
go


ALTER TABLE dbo.SC_SampledNumericDataFact_Table
    ADD CONSTRAINT SC_SampledNumericDataFact_Table_PK
    PRIMARY KEY NONCLUSTERED (SMC_InstanceID)
go


CREATE UNIQUE NONCLUSTERED INDEX Script_SurrogateKey_Index
    ON dbo.SC_ScriptDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 70
go


ALTER TABLE dbo.SC_ScriptDimension_Table
    ADD CONSTRAINT SC_ScriptDimension_Table_PK
    PRIMARY KEY CLUSTERED (ScriptID_PK)
go


CREATE UNIQUE NONCLUSTERED INDEX ScriptToConfigurationGroupDimension_SurrogateKey_Index
    ON dbo.SC_ScriptToConfigurationGroupDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 70
go


ALTER TABLE dbo.SC_ScriptToConfigurationGroupDimension_Table
    ADD CONSTRAINT SC_ScriptToConfigurationGroupDimension_Table_PK
    PRIMARY KEY CLUSTERED (ConfigurationGroup_FK_PK,Script_FK_PK)
go


CREATE UNIQUE NONCLUSTERED INDEX TimeDimension_SurrogateKey_Index
    ON dbo.SC_TimeDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 98
go


ALTER TABLE dbo.SC_TimeDimension_Table
    ADD CONSTRAINT SC_TimeDimension_Table_PK
    PRIMARY KEY CLUSTERED (Hour_PK,Minute_PK,Second_PK)
go


CREATE UNIQUE NONCLUSTERED INDEX UserDimension_SurrogateKey_Index
    ON dbo.SC_UserDimension_Table(SMC_InstanceID)
  WITH FILLFACTOR = 70
go


ALTER TABLE dbo.SC_UserDimension_Table
    ADD CONSTRAINT SC_UserDimension_Table_PK
    PRIMARY KEY CLUSTERED (UserName_PK)
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_internal_getmessage 
(
 @name AS nvarchar(128),
 @text AS nvarchar(400) OUTPUT,
 @severity AS int OUTPUT,
 @ID AS int OUTPUT
)
AS
BEGIN
 SET NOCOUNT ON

 SELECT @text=SM_Message,
        @severity=SM_Severity,
        @ID=SM_MsgID
 FROM  dbo.SMC_Messages
 WHERE SM_Language = @@LANGUAGE
 AND   SM_Name     = @name

 IF (@@ROWCOUNT = 0)
 BEGIN
  -- message not found for this language. Let's try to find the message 
  -- for us_english instead
  SELECT @text=SM_Message,
         @severity=SM_Severity,
         @ID=SM_MsgID
  FROM  dbo.SMC_Messages
  WHERE SM_Language = N'us_english'
  AND   SM_Name     = @name

  IF (@@ROWCOUNT = 0)
  BEGIN
   -- message doesn't exist for us-english either. Let's return the 
   -- default message instead
   SELECT @text=SM_Message,
          @severity=SM_Severity,
          @ID=SM_MsgID
   FROM  dbo.SMC_Messages
   WHERE SM_Language = N'us_english'
   AND   SM_Name     = N'MSG_SMC_INTERNAL_UNKNOWN'
  END
 END
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


ALTER TABLE dbo.SMO_CSharpTypes
    ADD CONSTRAINT FK_SMO_CSharpTypes_SMO_CSharpAssembly
    FOREIGN KEY (SCT_AssemblyID)
    REFERENCES dbo.SMO_CSharpAssemblies (SCA_AssemblyID)
go


ALTER TABLE dbo.SMO_ClassMethods
    ADD CONSTRAINT FK_SMO_ClassMethods_SMO_ClassSchemas
    FOREIGN KEY (SCM_SMOClassID)
    REFERENCES dbo.SMO_ClassSchemas (SCS_SMOClassID)
go


ALTER TABLE dbo.SMO_ClassProperties
    ADD CONSTRAINT FK_SMO_ClassProperties_SMO_ClassSMCClasses
    FOREIGN KEY (SCP_SMOClassSMCClassID)
    REFERENCES dbo.SMO_ClassSMCClasses (SCSC_SMOClassSMCClassID)
go


ALTER TABLE dbo.SMO_ClassProperties
    ADD CONSTRAINT smc_fk_SMO_ClassProperties_SMO_CSharpTypes_CSharpTypeID
    FOREIGN KEY (SCP_CSharpTypeID)
    REFERENCES dbo.SMO_CSharpTypes (SCT_CSharpTypeID)
go


ALTER TABLE dbo.SMO_ClassProperties
    ADD CONSTRAINT smc_fk_SMO_ClassProperties_SMO_ClassSchemas_SMOClassID
    FOREIGN KEY (SCP_SMOClassID)
    REFERENCES dbo.SMO_ClassSchemas (SCS_SMOClassID)
go


ALTER TABLE dbo.SMO_ClassSMCClassJoins
    ADD CONSTRAINT smc_fk_SMO_ClassSMCClassJoins_SMO_ClassSMCClasses_SourceSMOClassSMCClass
    FOREIGN KEY (SCSCJ_SourceSMOClassSMCClassID)
    REFERENCES dbo.SMO_ClassSMCClasses (SCSC_SMOClassSMCClassID)
go


ALTER TABLE dbo.SMO_ClassSMCClassJoins
    ADD CONSTRAINT smc_fk_SMO_ClassSMCClassJoins_SMO_ClassSMCClasses_TargetSMOClassSMCClass
    FOREIGN KEY (SCSCJ_TargetSMOClassSMCClassID)
    REFERENCES dbo.SMO_ClassSMCClasses (SCSC_SMOClassSMCClassID)
go


ALTER TABLE dbo.SMO_ClassSMCClasses
    ADD CONSTRAINT smc_fk_SMO_ClassSMCClasses_SMO_ClassSchemas_SMOClassID
    FOREIGN KEY (SCSC_SMOClassID)
    REFERENCES dbo.SMO_ClassSchemas (SCS_SMOClassID)
go


ALTER TABLE dbo.SMO_ClassSchemas
    ADD CONSTRAINT smc_fk_SMO_ClassSchemas_SMO_CSharpAssemblies
    FOREIGN KEY (SCS_CSharpAssemblyID)
    REFERENCES dbo.SMO_CSharpAssemblies (SCA_AssemblyID)
go


ALTER TABLE dbo.SMO_RelationshipSources
    ADD CONSTRAINT smc_fk_SMO_RelationshipSources_SMO_ClassSchemas_SourceSMOClassID
    FOREIGN KEY (SRS_SourceSMOClassID)
    REFERENCES dbo.SMO_ClassSchemas (SCS_SMOClassID)
go


ALTER TABLE dbo.SMO_RelationshipSources
    ADD CONSTRAINT smc_fk_SMO_RelationshipSources_SMO_RelationshipTypes_SMORelationshipTypeID
    FOREIGN KEY (SRS_SMORelationshipTypeID)
    REFERENCES dbo.SMO_RelationshipTypes (SRT_SMORelationshipTypeID)
go


ALTER TABLE dbo.SMO_RelationshipTargets
    ADD CONSTRAINT smc_fk_SMO_RelationshipTargets_SMO_ClassSchemas_TargetSMOClassID
    FOREIGN KEY (SRT_TargetSMOClassID)
    REFERENCES dbo.SMO_ClassSchemas (SCS_SMOClassID)
go


ALTER TABLE dbo.SMO_RelationshipTargets
    ADD CONSTRAINT smc_fk_SMO_RelationshipTargets_SMO_RelationshipTypes_SMORelationshipTypeID
    FOREIGN KEY (SRT_SMORelationshipTypeID)
    REFERENCES dbo.SMO_RelationshipTypes (SRT_SMORelationshipTypeID)
go


ALTER TABLE dbo.SMO_TypeConversions
    ADD CONSTRAINT smc_fk_SMO_TypeConversions_SMO_CSharpTypes_CSharpTypeID
    FOREIGN KEY (STC_CSharpTypeID)
    REFERENCES dbo.SMO_CSharpTypes (SCT_CSharpTypeID)
go


ALTER TABLE dbo.SMO_TypeConversions
    ADD CONSTRAINT smc_fk_SMO_TypeConversions_SMO_CSharpTypes_ConversionClass
    FOREIGN KEY (STC_ConversionClass)
    REFERENCES dbo.SMO_CSharpTypes (SCT_CSharpTypeID)
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_internal_getuserid 
(
 @userid as int OUTPUT
)
AS
BEGIN
 SET NOCOUNT ON

 DECLARE @username AS sysname
 SET @username = SUSER_SNAME()

 SELECT @userid=U_UserID 
 FROM dbo.Users
 WHERE U_UserName = @username

 IF (@@ROWCOUNT=0)
 BEGIN
  INSERT INTO dbo.Users (U_UserName) VALUES (@username)

  IF (@@ERROR <> 0)
  BEGIN
   DECLARE @errMsg AS NVARCHAR(400)
   DECLARE @severity AS int
   DECLARE @msgID AS int
 
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSERT_USERS_TABLE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      RETURN @@ERROR
  END
  
  SELECT @userid = SCOPE_IDENTITY()
 END
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


ALTER TABLE dbo.ValidationUDFParameterValues
    ADD CONSTRAINT smc_fk_ValidationUDFParameterValues_ValidationUDFParameters
    FOREIGN KEY (VUPV_ValidationUDFID,VUPV_ParamName)
    REFERENCES dbo.ValidationUDFParameters (VUP_ValidationUDFID,VUP_ParamName)
go


ALTER TABLE dbo.ValidationUDFParameters
    ADD CONSTRAINT smc_fk_ValidationUDFParameters_ValidationUDFs
    FOREIGN KEY (VUP_ValidationUDFID)
    REFERENCES dbo.ValidationUDFs (VU_ValidationUDFID)
go


ALTER TABLE dbo.ValidationUDFParameters
    WITH NOCHECK
    ADD CONSTRAINT smc_chk_ValidationUDFParameters_ScalePrecisionInRange
    CHECK ([VUP_ParamScale] <= [VUP_ParamPrecision] and [VUP_ParamPrecision] <= @@max_precision and [VUP_ParamPrecision] >= 0 and [VUP_ParamScale] >= 0)
go


CREATE TRIGGER dbo.triud_ValidationUDFParameters_Signed ON dbo.ValidationUDFParameters
FOR INSERT, UPDATE, DELETE 
AS
BEGIN  

    SET NOCOUNT ON

    PRINT N'FOR INSERT, UPDATE, DELETE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

    IF EXISTS ( SELECT VU.VU_ValidationUDFID
  FROM dbo.ValidationUDFs AS VU
  JOIN (SELECT * FROM deleted UNION ALL
                      SELECT * FROM inserted) AS M
         ON M.VUP_ValidationUDFID = VU.VU_ValidationUDFID
         WHERE VU.VU_Signed = 1 )
    BEGIN
 DECLARE @errResult AS integer
 DECLARE @errMsg AS nvarchar(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int

 EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_VALIDATIONUDFPARAMETERS_CANNOT_MODIFY_SIGNED_VALIDATIONUDF', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
 RAISERROR (@errMsg, @severity, 1)
 ROLLBACK TRANSACTION
 RETURN 
    END
END
go


CREATE TRIGGER dbo.triu_ValidationUDFs_Validate on dbo.ValidationUDFs
FOR INSERT, UPDATE
AS
BEGIN
 SET NOCOUNT ON

 PRINT N'FOR INSERT/UPDATE trigger ' + OBJECT_NAME(@@PROCID) + N' firing'

 IF (UPDATE (VU_Name))
 BEGIN
  DECLARE @errMsg AS NVARCHAR(400)
  DECLARE @severity AS int
  DECLARE @msgID AS int

  -- make sure that all the functions that we define exist and are owned by dbo
  IF EXISTS
  (
   SELECT *
   FROM inserted I
   WHERE NOT EXISTS
   (
    SELECT *
    FROM information_schema.routines R
    WHERE R.routine_type   = 'FUNCTION'
    AND   R.ROUTINE_SCHEMA = 'dbo'
    AND   R.SPECIFIC_NAME  = I.VU_Name
           COLLATE Latin1_General_CI_AI
   )
  )
  BEGIN
   EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_UDF_DOES_NOT_EXIST', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END

  -- validate that the return type of the UDF is a bit
  IF EXISTS
  (
   SELECT *
   FROM inserted I
   WHERE NOT EXISTS
   (
    SELECT *
    FROM information_schema.routines R
    WHERE R.routine_type   = 'FUNCTION'
    AND   R.ROUTINE_SCHEMA = 'dbo'
    AND   R.DATA_TYPE      = 'bit'
    AND   R.SPECIFIC_NAME  = I.VU_Name
    COLLATE Latin1_General_CI_AI
   )
  )
  BEGIN
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_UDFVALIDATION_RETURNS_NOT_BIT', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END

  -- We only accept functions that have at least one parameter. The following
  -- query counts all parameters, and if it returns a row with less than two
  -- parameters (the return value is counted as param as well), we raise an error
  IF EXISTS
  (
   SELECT *
   FROM information_schema.routines R,
        information_schema.parameters P,
        inserted I
   WHERE R.routine_type   = 'FUNCTION'
   AND   R.ROUTINE_SCHEMA = 'dbo'
   AND R.specific_name    = P.specific_name
   AND R.specific_name    = I.VU_Name
   COLLATE Latin1_General_CI_AI
   GROUP BY R.SPECIFIC_NAME
   HAVING COUNT(*) < 2  -- return value counts as parameter
  )
  BEGIN
   EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_UDFVALIDATION_NEEDS_MULTIPLE_PARAMS', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      ROLLBACK TRANSACTION
      RETURN
  END
 END
END
go


CREATE TRIGGER dbo.trud_ValidationUDFs_Signed ON dbo.ValidationUDFs
FOR UPDATE, DELETE 
AS
BEGIN  
    SET NOCOUNT ON

    PRINT N'FOR UPDATE, DELETE TRIGGER ' + OBJECT_NAME(@@PROCID) + N' firing'

    IF EXISTS ( SELECT *
  FROM deleted
  WHERE VU_Signed = 1 )
    BEGIN
 DECLARE @errResult AS integer
 DECLARE @errMsg AS nvarchar(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int

        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CANNOT_MODIFY_SIGNED_VALIDATIONUDF', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
 RAISERROR (@errMsg, @severity, 1)
 ROLLBACK TRANSACTION
 RETURN 
    END
END
go


ALTER TABLE dbo.WrapperColumns
    ADD CONSTRAINT smc_fk_WrapperColumns_WrapperSchemas
    FOREIGN KEY (WC_WrapperID)
    REFERENCES dbo.WrapperSchemas (WS_WrapperID)
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


/*
**	Add an object to the dtproperties table
*/
create procedure dbo.dt_adduserobject
as
	set nocount on
	/*
	** Create the user object if it does not exist already
	*/
	begin transaction
		insert dbo.dtproperties (property) VALUES ('DtgSchemaOBJECT')
		update dbo.dtproperties set objectid=@@identity 
			where id=@@identity and property='DtgSchemaOBJECT'
	commit
	return @@identity

go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


create procedure dbo.dt_adduserobject_vcs
    @vchProperty varchar(64)

as

set nocount on

declare @iReturn int
    /*
    ** Create the user object if it does not exist already
    */
    begin transaction
        select @iReturn = objectid from dbo.dtproperties where property = @vchProperty
        if @iReturn IS NULL
        begin
            insert dbo.dtproperties (property) VALUES (@vchProperty)
            update dbo.dtproperties set objectid=@@identity
                    where id=@@identity and property=@vchProperty
            select @iReturn = @@identity
        end
    commit
    return @iReturn



go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


/*
**	Drop one or all the associated properties of an object or an attribute 
**
**	dt_dropproperties objid, null or '' -- drop all properties of the object itself
**	dt_dropproperties objid, property -- drop the property
*/
create procedure dbo.dt_droppropertiesbyid
	@id int,
	@property varchar(64)
as
	set nocount on

	if (@property is null) or (@property = '')
		delete from dbo.dtproperties where objectid=@id
	else
		delete from dbo.dtproperties 
			where objectid=@id and property=@property


go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


/*
**	Drop an object from the dbo.dtproperties table
*/
create procedure dbo.dt_dropuserobjectbyid
	@id int
as
	set nocount on
	delete from dbo.dtproperties where objectid=@id

go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


/* 
**	Generate an ansi name that is unique in the dtproperties.value column 
*/ 
create procedure dbo.dt_generateansiname(@name varchar(255) output) 
as 
	declare @prologue varchar(20) 
	declare @indexstring varchar(20) 
	declare @index integer 
 
	set @prologue = 'MSDT-A-' 
	set @index = 1 
 
	while 1 = 1 
	begin 
		set @indexstring = cast(@index as varchar(20)) 
		set @name = @prologue + @indexstring 
		if not exists (select value from dtproperties where value = @name) 
			break 
		 
		set @index = @index + 1 
 
		if (@index = 10000) 
			goto TooMany 
	end 
 
Leave: 
 
	return 
 
TooMany: 
 
	set @name = 'DIAGRAM' 
	goto Leave 

go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


/*
**	Retrieve the owner object(s) of a given property
*/
create procedure dbo.dt_getobjwithprop
	@property varchar(30),
	@value varchar(255)
as
	set nocount on

	if (@property is null) or (@property = '')
	begin
		raiserror('Must specify a property name.',-1,-1)
		return (1)
	end

	if (@value is null)
		select objectid id from dbo.dtproperties
			where property=@property

	else
		select objectid id from dbo.dtproperties
			where property=@property and value=@value

go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


/*
**	Retrieve the owner object(s) of a given property
*/
create procedure dbo.dt_getobjwithprop_u
	@property varchar(30),
	@uvalue nvarchar(255)
as
	set nocount on

	if (@property is null) or (@property = '')
	begin
		raiserror('Must specify a property name.',-1,-1)
		return (1)
	end

	if (@uvalue is null)
		select objectid id from dbo.dtproperties
			where property=@property

	else
		select objectid id from dbo.dtproperties
			where property=@property and uvalue=@uvalue

go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


/*
**	Retrieve properties by id's
**
**	dt_getproperties objid, null or '' -- retrieve all properties of the object itself
**	dt_getproperties objid, property -- retrieve the property specified
*/
create procedure dbo.dt_getpropertiesbyid
	@id int,
	@property varchar(64)
as
	set nocount on

	if (@property is null) or (@property = '')
		select property, version, value, lvalue
			from dbo.dtproperties
			where  @id=objectid
	else
		select property, version, value, lvalue
			from dbo.dtproperties
			where  @id=objectid and @property=property

go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


/*
**	Retrieve properties by id's
**
**	dt_getproperties objid, null or '' -- retrieve all properties of the object itself
**	dt_getproperties objid, property -- retrieve the property specified
*/
create procedure dbo.dt_getpropertiesbyid_u
	@id int,
	@property varchar(64)
as
	set nocount on

	if (@property is null) or (@property = '')
		select property, version, uvalue, lvalue
			from dbo.dtproperties
			where  @id=objectid
	else
		select property, version, uvalue, lvalue
			from dbo.dtproperties
			where  @id=objectid and @property=property

go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


create procedure dbo.dt_getpropertiesbyid_vcs
    @id       int,
    @property varchar(64),
    @value    varchar(255) = NULL OUT

as

    set nocount on

    select @value = (
        select value
                from dbo.dtproperties
                where @id=objectid and @property=property
                )


go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


create proc dbo.dt_isundersourcecontrol
    @vchLoginName varchar(255) = '',
    @vchPassword  varchar(255) = '',
    @iWhoToo      int = 0 /* 0 => Just check project; 1 => get list of objs */

as

	set nocount on

	declare @iReturn int
	declare @iObjectId int
	select @iObjectId = 0

	declare @VSSGUID varchar(100)
	select @VSSGUID = 'SQLVersionControl.VCS_SQL'

	declare @iReturnValue int
	select @iReturnValue = 0

	declare @iStreamObjectId int
	select @iStreamObjectId   = 0

	declare @vchTempText varchar(255)

    declare @iPropertyObjectId int
    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchProjectName   varchar(255)
    declare @vchSourceSafeINI varchar(255)
    declare @vchServerName    varchar(255)
    declare @vchDatabaseName  varchar(255)
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSProject',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLServer',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLDatabase',   @vchDatabaseName  OUT

    if (@vchProjectName = '')	set @vchProjectName		= null
    if (@vchSourceSafeINI = '') set @vchSourceSafeINI	= null
    if (@vchServerName = '')	set @vchServerName		= null
    if (@vchDatabaseName = '')	set @vchDatabaseName	= null
    
    if (@vchProjectName is null) or (@vchSourceSafeINI is null) or (@vchServerName is null) or (@vchDatabaseName is null)
    begin
        RAISERROR('Not Under Source Control',16,-1)
        return
    end

    if @iWhoToo = 1
    begin

        /* Get List of Procs in the project */
        exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT
        if @iReturn <> 0 GOTO E_OAError

        exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
												'GetListOfObjects',
												NULL,
												@vchProjectName,
												@vchSourceSafeINI,
												@vchServerName,
												@vchDatabaseName,
												@vchLoginName,
												@vchPassword

        if @iReturn <> 0 GOTO E_OAError

        exec @iReturn = master.dbo.sp_OAGetProperty @iObjectId, 'GetStreamObject', @iStreamObjectId OUT

        if @iReturn <> 0 GOTO E_OAError

        create table #ObjectList (id int identity, vchObjectlist varchar(255))

        select @vchTempText = 'STUB'
        while @vchTempText is not null
        begin
            exec @iReturn = master.dbo.sp_OAMethod @iStreamObjectId, 'GetStream', @iReturnValue OUT, @vchTempText OUT
            if @iReturn <> 0 GOTO E_OAError
            
            if (@vchTempText = '') set @vchTempText = null
            if (@vchTempText is not null) insert into #ObjectList (vchObjectlist ) select @vchTempText
        end

        select vchObjectlist from #ObjectList order by id
    end

CleanUp:
    return

E_OAError:
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    goto CleanUp



go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


create procedure dbo.dt_removefromsourcecontrol

as

    set nocount on

    declare @iPropertyObjectId int
    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    exec dbo.dt_droppropertiesbyid @iPropertyObjectId, null

    /* -1 is returned by dt_droppopertiesbyid */
    if @@error <> 0 and @@error <> -1 return 1

    return 0



go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


/*
**	If the property already exists, reset the value; otherwise add property
**		id -- the id in sysobjects of the object
**		property -- the name of the property
**		value -- the text value of the property
**		lvalue -- the binary value of the property (image)
*/
create procedure dbo.dt_setpropertybyid
	@id int,
	@property varchar(64),
	@value varchar(255),
	@lvalue image
as
	set nocount on
	declare @uvalue nvarchar(255) 
	set @uvalue = convert(nvarchar(255), @value) 
	if exists (select * from dbo.dtproperties 
			where objectid=@id and property=@property)
	begin
		--
		-- bump the version count for this row as we update it
		--
		update dbo.dtproperties set value=@value, uvalue=@uvalue, lvalue=@lvalue, version=version+1
			where objectid=@id and property=@property
	end
	else
	begin
		--
		-- version count is auto-set to 0 on initial insert
		--
		insert dbo.dtproperties (property, objectid, value, uvalue, lvalue)
			values (@property, @id, @value, @uvalue, @lvalue)
	end


go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


/*
**	If the property already exists, reset the value; otherwise add property
**		id -- the id in sysobjects of the object
**		property -- the name of the property
**		uvalue -- the text value of the property
**		lvalue -- the binary value of the property (image)
*/
create procedure dbo.dt_setpropertybyid_u
	@id int,
	@property varchar(64),
	@uvalue nvarchar(255),
	@lvalue image
as
	set nocount on
	-- 
	-- If we are writing the name property, find the ansi equivalent. 
	-- If there is no lossless translation, generate an ansi name. 
	-- 
	declare @avalue varchar(255) 
	set @avalue = null 
	if (@uvalue is not null) 
	begin 
		if (convert(nvarchar(255), convert(varchar(255), @uvalue)) = @uvalue) 
		begin 
			set @avalue = convert(varchar(255), @uvalue) 
		end 
		else 
		begin 
			if 'DtgSchemaNAME' = @property 
			begin 
				exec dbo.dt_generateansiname @avalue output 
			end 
		end 
	end 
	if exists (select * from dbo.dtproperties 
			where objectid=@id and property=@property)
	begin
		--
		-- bump the version count for this row as we update it
		--
		update dbo.dtproperties set value=@avalue, uvalue=@uvalue, lvalue=@lvalue, version=version+1
			where objectid=@id and property=@property
	end
	else
	begin
		--
		-- version count is auto-set to 0 on initial insert
		--
		insert dbo.dtproperties (property, objectid, value, uvalue, lvalue)
			values (@property, @id, @avalue, @uvalue, @lvalue)
	end

go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


create proc dbo.dt_validateloginparams
    @vchLoginName  varchar(255),
    @vchPassword   varchar(255)
as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId =0

declare @VSSGUID varchar(100)
select @VSSGUID = 'SQLVersionControl.VCS_SQL'

    declare @iPropertyObjectId int
    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchSourceSafeINI varchar(255)
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT

    exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT
    if @iReturn <> 0 GOTO E_OAError

    exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
											'ValidateLoginParams',
											NULL,
											@sSourceSafeINI = @vchSourceSafeINI,
											@sLoginName = @vchLoginName,
											@sPassword = @vchPassword
    if @iReturn <> 0 GOTO E_OAError

CleanUp:
    return

E_OAError:
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    GOTO CleanUp



go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


create proc dbo.dt_whocheckedout
        @chObjectType  char(4),
        @vchObjectName varchar(255),
        @vchLoginName  varchar(255),
        @vchPassword   varchar(255)

as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId =0

declare @VSSGUID varchar(100)
select @VSSGUID = 'SQLVersionControl.VCS_SQL'

    declare @iPropertyObjectId int

    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchProjectName   varchar(255)
    declare @vchSourceSafeINI varchar(255)
    declare @vchServerName    varchar(255)
    declare @vchDatabaseName  varchar(255)
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSProject',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLServer',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLDatabase',   @vchDatabaseName  OUT

    if @chObjectType = 'PROC'
    begin
        exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT

        if @iReturn <> 0 GOTO E_OAError

        declare @vchReturnValue varchar(255)
        select @vchReturnValue = ''

        exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
												'WhoCheckedOut',
												@vchReturnValue OUT,
												@sProjectName = @vchProjectName,
												@sSourceSafeINI = @vchSourceSafeINI,
												@sObjectName = @vchObjectName,
												@sServerName = @vchServerName,
												@sDatabaseName = @vchDatabaseName,
												@sLoginName = @vchLoginName,
												@sPassword = @vchPassword

        if @iReturn <> 0 GOTO E_OAError

        select @vchReturnValue

    end

CleanUp:
    return

E_OAError:
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    GOTO CleanUp



go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE FUNCTION dbo.SMC_IsValidName (@str nvarchar(4000))
RETURNS BIT
AS
BEGIN
 IF (@str IS NULL)
 BEGIN
  RETURN 1
 END

 DECLARE @len INT
 DECLARE @idx INT
 
 SET @idx = 1
 -- use DATALENGTH, because LEN will strip off spaces. DATALENGTH returns number of bytes,
 -- so to get number of characters, divide by 2
 SET @len = DATALENGTH(@str) / 2

 IF (@len = 0)
 BEGIN
  RETURN 1
 END

 DECLARE @iUnicode as int
 DECLARE @hexUnicode as varbinary(2)

 SET @iUnicode = UNICODE(substring (@str, 1, 1))
 SET @hexUnicode = CONVERT(varbinary(2), @iUnicode)

 IF (dbo.ValidStartChar (@hexUnicode) = 0)
 BEGIN
  RETURN 0
 END

 SET @idx = 2
 
 WHILE (@idx <= @len)
 BEGIN
  SET @iUnicode = UNICODE(substring (@str, @idx, 1))
  SET @hexUnicode = CONVERT(varbinary(2), @iUnicode)

  IF (dbo.NameChar(@hexUnicode) = 0)
  BEGIN
   RETURN 0
  END

  SET @idx = @idx + 1
 END

 RETURN 1
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.p_CreateDynamicViews
AS
BEGIN

    DECLARE     @SaveError   INTEGER
    
    --
    -- Create views for classes
    -- 

    EXEC dbo.p_CreateViewsForClassOrRelationshipDefinitions N'Class'

    SET @SaveError = @@ERROR
    IF (@SaveError <> 0)
    BEGIN
        GOTO Error_Exit
    END

    --
    -- Create views for relationships
    -- 

    EXEC dbo.p_CreateViewsForClassOrRelationshipDefinitions N'Relationship'

    SET @SaveError = @@ERROR
    IF (@SaveError <> 0)
    BEGIN
        GOTO Error_Exit
    END

    RETURN 0

Error_Exit:
      
    --
    -- Since this sp is called from the DTS package, and you dont want to 
    -- fail the step on error, do not fail this SP in case of an error.
    --
    
    RETURN 0

END
go


SET QUOTED_IDENTIFIER OFF
go


ALTER TABLE dbo.ClassIndexesColumns
    ADD CONSTRAINT smc_fk_ClassIndexesColumns_ClassIndexes
    FOREIGN KEY (CIC_ClassIndexID)
    REFERENCES dbo.ClassIndexes (CI_ClassIndexID)
go


ALTER TABLE dbo.ClassIndexes
    ADD CONSTRAINT smc_fk_ClassIndexes_ClassSchemas
    FOREIGN KEY (CI_ClassID)
    REFERENCES dbo.ClassSchemas (CS_ClassID)
go


ALTER TABLE dbo.ClassIndexes
    ADD CONSTRAINT smc_fk_ClassIndexes_FileGroups
    FOREIGN KEY (CI_FileGroupID)
    REFERENCES dbo.FileGroups (FG_FileGroupID)
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_Meta_DeleteClass
(
 @classID as uniqueidentifier
)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errResult AS integer
    DECLARE @errMsg AS nvarchar(400)
    DECLARE @severity AS int
    DECLARE @msgID AS int
    DECLARE @viewName AS nvarchar(128)


    -- Delete all RelationshipConstraints that refer to this class
    DELETE dbo.RelationshipConstraints
    WHERE RC_SourceClassID = @classID
    OR RC_TargetClassID = @classID

    IF (@@ERROR <> 0)
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_CLASSSCHEMA_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
        RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END


    -- Delete all ClassIndexesColumns related to this class
    DELETE dbo.ClassIndexesColumns
    FROM dbo.ClassIndexesColumns AS CIC
    JOIN dbo.ClassIndexes AS CI
    ON CIC.CIC_ClassIndexID = CI.CI_ClassIndexID
    WHERE CI.CI_ClassID = @classID

    IF (@@ERROR <> 0)
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_CLASSSCHEMA_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
        RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END


    -- Delete all ClassIndexes defined for this class
    DELETE dbo.ClassIndexes
    WHERE CI_ClassID = @classID
    
    IF (@@ERROR <> 0)
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_CLASSSCHEMA_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
        RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
 

    -- Delete all ClassProperties
    DELETE dbo.ClassProperties
    WHERE CP_ClassID = @classID

    IF (@@ERROR <> 0)
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_CLASSSCHEMA_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
        RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

    -- Delete all relationship instances that refer 
    -- a class instance of this class
    DELETE dbo.RelationshipInstances
    FROM dbo.ClassInstances
    JOIN dbo.RelationshipInstances
    ON CI_InstanceID = RI_SourceInstanceID 
    OR CI_InstanceID = RI_TargetInstanceID
    WHERE CI_ClassID = @classID

    IF (@@ERROR <> 0)
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_CLASSSCHEMA_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
        RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

    -- Delete all ClassInstancesAudits
    DELETE dbo.ClassInstancesAudits
    WHERE CIA_ClassID = @classID

    IF (@@ERROR <> 0)
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_CLASSSCHEMA_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
        RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END


    -- Delete all ClassInstances
    DELETE dbo.ClassInstances
    WHERE CI_ClassID = @classID

    IF (@@ERROR <> 0)
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_CLASSSCHEMA_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
        RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

    -- Marking this class as not supporting partitions
    -- otherwise won't be able to delete the partitions from
    -- ClassSchemaPartitions and then will get a FK violation
    UPDATE dbo.ClassSchemas SET CS_SupportsPartitions = 0
    WHERE CS_ClassID = @classID

    IF (@@ERROR <> 0)
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_CLASSSCHEMA_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
        RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

    -- Delete all entries in ClassSchemaPartitions
    DELETE dbo.ClassSchemaPartitions
    WHERE CSP_ClassID = @classID

    IF (@@ERROR <> 0)
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_CLASSSCHEMA_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
        RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

    -- Delete the class from ClassSchema
    DELETE dbo.ClassSchemas
    WHERE CS_ClassID = @classID

    IF (@@ERROR <> 0)
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_CLASSSCHEMA_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
        RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


ALTER TABLE dbo.ClassIndexesColumns
    ADD CONSTRAINT smc_fk_ClassIndexesColumns_ClassProperties
    FOREIGN KEY (CIC_ClassPropertyID)
    REFERENCES dbo.ClassProperties (CP_ClassPropertyID)
go


ALTER TABLE dbo.PropertyInstances
    ADD CONSTRAINT smc_fk_PropertyInstances_ClassInstances
    FOREIGN KEY (PI_InstanceID)
    REFERENCES dbo.ClassInstances (CI_InstanceID)
go


ALTER TABLE dbo.RelationshipInstances
    ADD CONSTRAINT smc_fk_InstanceRelationships_ClassInstances_
    FOREIGN KEY (RI_TargetInstanceID)
    REFERENCES dbo.ClassInstances (CI_InstanceID)
go


ALTER TABLE dbo.RelationshipInstances
    ADD CONSTRAINT smc_fk_InstanceRelationships_ClassInstances_Source
    FOREIGN KEY (RI_SourceInstanceID)
    REFERENCES dbo.ClassInstances (CI_InstanceID)
go


ALTER TABLE dbo.ClassInstances
    ADD CONSTRAINT smc_fk_ClassInstances_ClassSchemas
    FOREIGN KEY (CI_ClassID)
    REFERENCES dbo.ClassSchemas (CS_ClassID)
go


ALTER TABLE dbo.ClassInstances
    ADD CONSTRAINT smc_fk_ClassInstances_Modifications_CreationID
    FOREIGN KEY (CI_StartModID)
    REFERENCES dbo.Modifications (M_ModificationID)
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_AddMembersToGroup
(
 @groupID AS uniqueidentifier -- group id
)
AS
BEGIN
 SET NOCOUNT ON

  DECLARE @errResult AS integer
    DECLARE @errMsg AS nvarchar(400)
    DECLARE @severity AS int
    DECLARE @msgID AS int

 DECLARE @viewName nvarchar(200)

 -- Get the name of the view in which we need to retrieve the group query
 SELECT @viewName = CS.CS_ViewName
 FROM dbo.ClassSchemas CS, 
      dbo.ClassInstances CI
 WHERE CS.CS_ClassID  = CI.CI_ClassID
 AND CI.CI_InstanceID = @groupID
 AND CS.CS_IsGroup    = 1

 IF (@@ROWCOUNT <> 1)
 BEGIN
          EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSTANCE_NOT_GROUP', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
       RAISERROR (@errMsg, @severity, 1)
       RETURN
 END

 DECLARE @strQuery nvarchar(1024)
 DECLARE @strGetQuery nvarchar(256)
 SET @strGetQuery = N' SELECT @strQuery = SMC_GroupQuery' + 
      N' FROM dbo.' + QUOTENAME(@viewName) +
      N' WHERE SMC_InstanceID = @groupID'

 DECLARE @ret int
 EXEC @ret = dbo.sp_executesql @strGetQuery, N'@groupID uniqueidentifier, @strQuery nvarchar(1024) OUT', @groupID, @strQuery OUT
 IF (@ret <> 0)
 BEGIN
       EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DYNAMIC_QUERY_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
       RAISERROR (@errMsg, @severity, 1, @strGetQuery)
       RETURN
 END

 CREATE TABLE dbo.#newMembers (MemberID uniqueidentifier)

 IF (@strQuery IS NOT NULL)
 BEGIN
  PRINT 'Executing dynamic query: ' + @strQuery
 
  -- get the instances for this dynamic group
  INSERT INTO dbo.#newMembers
  EXEC dbo.sp_executesql @strQuery
 END
 ELSE
 BEGIN
  -- no query specified. Note that we still need to continue with deleting the old entries, 
  -- because it might be possible that there were values before and that the query has been
  -- set to NULL explicitely because we don't want to be the group dynamic anymore
  Print 'Dynamic query for group has NULL value for column SMC_IsGroup'
 END

 SET @errResult = @@ERROR
 IF (@errResult <> 0)
 BEGIN
       EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DYNAMIC_QUERY_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
       RAISERROR (@errMsg, @severity, 1, @strQuery)
       RETURN
 END

 -- delete old dynamic members, because they do not belong to the group anymore
 DELETE FROM dbo.SMC_GroupMembers
 WHERE GroupID = @groupID
 AND Usage = 'D'
 AND MemberID NOT IN 
  (SELECT MemberID FROM #newMembers)

 SET @errResult = @@ERROR
 IF (@errResult <> 0)
 BEGIN
       EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_GROUPMEMBERS_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
       RAISERROR (@errMsg, @severity, 1)
       ROLLBACK TRANSACTION
       RETURN
 END


 -- add new dynamic members to the GroupMembers table
 INSERT INTO dbo.SMC_GroupMembers
 (SMC_InstanceID, GroupID, MemberID, Usage)
 SELECT newid(), @groupID, MemberID, 'D'
 FROM dbo.#newMembers M
 WHERE NOT EXISTS 
  (SELECT *
   FROM dbo.SMC_GroupMembers R
   WHERE R.GroupID  = @groupID
   AND   R.MemberID = M.MemberID)

 SET @errResult = @@ERROR
 IF (@errResult <> 0)
 BEGIN
       EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSERT_GROUPMEMBERS_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
       RAISERROR (@errMsg, @severity, 1)
       ROLLBACK TRANSACTION
       RETURN
 END
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


ALTER TABLE dbo.ClassInstancesAudits
    ADD CONSTRAINT smc_fk_ClassInstancesAudits_ClassSchemas
    FOREIGN KEY (CIA_ClassID)
    REFERENCES dbo.ClassSchemas (CS_ClassID)
go


ALTER TABLE dbo.ClassInstancesAudits
    ADD CONSTRAINT smc_fk_ClassInstancesAudits_Modifications_ArchivedID
    FOREIGN KEY (CIA_EndModID)
    REFERENCES dbo.Modifications (M_ModificationID)
go


ALTER TABLE dbo.ClassInstancesAudits
    ADD CONSTRAINT smc_fk_ClassInstancesAudits_Modifications_CreationID
    FOREIGN KEY (CIA_StartModID)
    REFERENCES dbo.Modifications (M_ModificationID)
go


ALTER TABLE dbo.MethodParameterDefinitions
    ADD CONSTRAINT smc_fk_MethodParameterDefinitions_ClassMethods
    FOREIGN KEY (MPD_MethodID)
    REFERENCES dbo.ClassMethods (CM_MethodID)
go


ALTER TABLE dbo.ClassMethods
    ADD CONSTRAINT smc_fk_ClassMethods_ClassSchemas
    FOREIGN KEY (CM_ClassID)
    REFERENCES dbo.ClassSchemas (CS_ClassID)
go


ALTER TABLE dbo.ClassMethods
    ADD CONSTRAINT smc_fk_ClassMethods_DllDefinitions
    FOREIGN KEY (CM_DllID)
    REFERENCES dbo.DllDefinitions (DD_DllID)
go


ALTER TABLE dbo.PropertyInstances
    ADD CONSTRAINT smc_fk_PropertyInstances_ClassProperties
    FOREIGN KEY (PI_ClassPropertyID)
    REFERENCES dbo.ClassProperties (CP_ClassPropertyID)
go


ALTER TABLE dbo.PropertyInstancesAudits
    ADD CONSTRAINT smc_fk_PropertyInstancesAudits_ClassProperties
    FOREIGN KEY (PIA_ClassPropertyID)
    REFERENCES dbo.ClassProperties (CP_ClassPropertyID)
go


ALTER TABLE dbo.SMO_ClassProperties
    ADD CONSTRAINT smc_fk_SMO_ClassProperties_ClassProperties_SMCClassPropertyID
    FOREIGN KEY (SCP_SMCClassPropertyID)
    REFERENCES dbo.ClassProperties (CP_ClassPropertyID)
go


ALTER TABLE dbo.SMO_RelationshipTypes
    ADD CONSTRAINT smc_fk_SMO_RelationshipTypes_ClassProperties_SMCSourceClassProperty
    FOREIGN KEY (SRT_SMCSourceClassPropertyID)
    REFERENCES dbo.ClassProperties (CP_ClassPropertyID)
go


ALTER TABLE dbo.SMO_RelationshipTypes
    ADD CONSTRAINT smc_fk_SMO_RelationshipTypes_ClassProperties_SMCTargetClassProperty
    FOREIGN KEY (SRT_SMCTargetClassPropertyID)
    REFERENCES dbo.ClassProperties (CP_ClassPropertyID)
go


ALTER TABLE dbo.WarehouseClassProperty
    ADD CONSTRAINT smc_fk_WarehouseClassProperty_ClassPropertyID
    FOREIGN KEY (WCP_ClassPropertyID)
    REFERENCES dbo.ClassProperties (CP_ClassPropertyID)
go


ALTER TABLE dbo.WrapperColumns
    ADD CONSTRAINT smc_fk_WrapperColumns_ClassProperties
    FOREIGN KEY (WC_ClassPropertyID)
    REFERENCES dbo.ClassProperties (CP_ClassPropertyID)
go


ALTER TABLE dbo.ClassProperties
    ADD CONSTRAINT smc_fk_ClassProperties_ClassSchemas
    FOREIGN KEY (CP_ClassID)
    REFERENCES dbo.ClassSchemas (CS_ClassID)
go


ALTER TABLE dbo.ClassProperties
    ADD CONSTRAINT smc_fk_ClassProperties_PropertyTypes
    FOREIGN KEY (CP_PropertyTypeID)
    REFERENCES dbo.PropertyTypes (PT_TypeID)
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_Meta_CreateHighVolumeViews (@RelationshipTypeID uniqueidentifier, @EncryptFlag bit)
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @errResult  integer, @errMsg  nvarchar(400), @severity  int, @msgID  int
    DECLARE @srcID uniqueidentifier, @targID uniqueidentifier, @targFK uniqueidentifier
    DECLARE @srcTableName sysname, @targTableName sysname, @objName sysname
    DECLARE @srcPKName sysname, @targPKName sysname, @targFKName sysname
    DECLARE @ViewSrcName sysname, @ViewTargName sysname, @ViewName sysname
    DECLARE @EncryptString nvarchar(20)
    DECLARE @command nvarchar(4000)

    IF @EncryptFlag = 1
       SET @EncryptString = N', ENCRYPTION'
    ELSE
         SET @EncryptString = N''
         
    SELECT @ViewSrcName = RT_ViewSrcName, @ViewTargName = RT_ViewTargetName, @ViewName = RT_ViewName 
         FROM dbo.RelationshipTypes where RT_RelationshipTypeID = @RelationshipTypeID

    IF @ViewName IS NULL
  BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_RELATIONSHIPTYPE_NOT_FOUND',  @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
  RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
        END
    -- Put square brackets around names for safety, in case we want to allow these names to have embedded spaces or duplicate keywords
    SET @ViewTargName = '[' + @ViewTargName + ']'
    SET @ViewSrcName = '[' + @ViewSrcName + ']'
    SET @ViewName = '[' + @ViewName + ']'

    -- Look for relationship constraints with this typeid
    SELECT @srcID  = RC_SourceClassID, @targID = RC_TargetClassID, @targFK = RC_TargetFK 
     FROM RelationshipConstraints where RC_RelationshipTypeID = @RelationshipTypeID

    SELECT @srcTableName = CS_TableName  FROM dbo.ClassSchemas WHERE CS_ClassID = @srcID
    SELECT @targTableName = CS_TableName  FROM dbo.ClassSchemas WHERE CS_ClassID = @targID
    IF @targFK IS NULL
   BEGIN
   -- Create a name for our join table 
   SELECT @objName = 'SMC_' + CS_ClassName from dbo.ClassSchemas WHERE CS_ClassID = @srcID
   SELECT @objName = @objName + '_' + CS_ClassName  from dbo.ClassSchemas WHERE CS_ClassID = @targID
   -- Create the join table   NOTE 4000 chars is more than enough, as even if all 6 names are max length that is 768 plus the 100 to 200 from
   --  the string literals that we use in building the command.
   SET @command = N'CREATE TABLE dbo.[' + @objName + N'] (' + @ViewSrcName + N' uniqueidentifier NOT NULL, ' + @ViewTargName +
     N' uniqueidentifier NOT NULL,  CONSTRAINT [PK_' + @objName + N'] PRIMARY KEY (' + @ViewSrcName + N',' + @ViewTargName + N') )'
   EXEC dbo.sp_executesql @command
   if @@error <> 0
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CREATE_TABLE_FAILED',  @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
  RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
    
   -- Create additional index for join table
   SET @command = N'CREATE NONCLUSTERED INDEX [' + @objName + N'_NC1] ON dbo.[' + @objName + N'] (' + @ViewTargName + N')'
   EXEC dbo.sp_executesql @command
   if @@error <> 0
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CREATE_TABLE_FAILED',  @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
  RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
   
   -- Create view over the join table
   SET @command = N'CREATE VIEW dbo.' + @ViewName + N'WITH VIEW_METADATA, SCHEMABINDING' + @EncryptString + N' 
    AS SELECT ' +  @ViewTargName + N' AS [SMC_InstanceID], ' + @ViewSrcName + N' AS ' + @ViewSrcName + N', 
    ' + @ViewTargName + N' AS ' + @ViewTargName + N', ''S'' AS [Usage], NULL AS [SMC_StartModID] FROM dbo.[' + @objName + ']'
   EXEC dbo.sp_executesql @command
   if @@error <> 0
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CREATE_VIEW_FAILED',  @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
  RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END   
   END
    ELSE
   BEGIN
   -- No join table needed.  Create view over the target table.
   -- Get the column names which we are selecting from the target table.
   SELECT @targPKName = CP_PropertyName FROM dbo.ClassProperties WHERE CP_ClassPropertyID = @targFK
   SELECT @objName = CS_TableName FROM dbo.ClassSchemas WHERE CS_ClassID = @targID
    SET @command = N'CREATE VIEW dbo.' + @ViewName + N'WITH VIEW_METADATA, SCHEMABINDING' + @EncryptString + N' 
    AS SELECT [SMC_InstanceID] AS [SMC_InstanceID], ' + @targPKName  + N' AS ' + @ViewSrcName + N', 
    [SMC_InstanceID]  AS ' + @ViewTargName + N', ''S'' AS [Usage], NULL AS [SMC_StartModID] FROM dbo.[' + @objName + ']'
   EXEC dbo.sp_executesql @command
   if @@error <> 0
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CREATE_VIEW_FAILED',  @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
  RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END   
       
   END

    
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_add_property_to_wrapper
( 
 @wrapperName AS nvarchar(128),
 @className as nvarchar(128),
 @propertyName as nvarchar(128),
 @inout AS bit,
 @order AS integer
)
AS
 SET NOCOUNT ON
 -- add a new class/property combination to the classproperties table

 DECLARE @WrapperID AS uniqueidentifier
 DECLARE @QueryType AS int
 DECLARE @classID as uniqueidentifier
 DECLARE @ClassPropertyID AS uniqueidentifier
 DECLARE @InOrder AS integer
 DECLARE @OutOrder AS integer

 DECLARE @errMsg AS NVARCHAR(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int

 IF (@inout = 0)
 BEGIN
  SET @InOrder = NULL
  SET @OutOrder = @order
 END
 ELSE
 BEGIN
  SET @OutOrder = NULL
  SET @InOrder = @order
 END

 -- verify that we have only one class with this name

 SELECT @WrapperID = WS_WrapperID, @QueryType = WS_QueryType
 FROM dbo.WrapperSchemas
 WHERE WS_ClassName = @wrapperName

 IF (@@ROWCOUNT <> 1)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_WRAPPER_NAME_NOT_EXIST', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1, @wrapperName)
     RETURN @@ERROR
 END

 -- For queries of type stored procedure, we only support OUT properties 
 -- (parameters should be specified through smc_add_parameter_to_sproc)
 IF (@QueryType = 3)
 BEGIN
  IF (@InOrder IS NOT NULL)
  BEGIN
   EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_WRAPPERCOLUMNS_INCOMPATIBLE_INOUT_QUERY', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1, @wrapperName)
   RETURN -1
  END
 END

 SELECT @classID = CS_ClassID
 FROM dbo.ClassSchemas
 WHERE CS_ClassName = @className

 IF (@@ROWCOUNT <> 1)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASSNAME_NOT_EXIST', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1, @className)
     RETURN @@ERROR
 END

 SELECT @ClassPropertyID = CP.CP_ClassPropertyID
 FROM   dbo.ClassProperties CP
 WHERE CP.CP_PropertyName = @propertyName
 AND   CP.CP_ClassID   = @classID

 IF (@@ROWCOUNT <> 1)
 BEGIN
  DECLARE @strGUID AS NVARCHAR(40)
  SET @strGUID = CAST (@ClassPropertyID AS NVARCHAR(40))
     EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASSPROPERTY_ID_NOT_EXIST', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1, @strGUID)
     RETURN @@ERROR
 END
 
 INSERT INTO dbo.WrapperColumns
 ([WC_WrapperID], [WC_ClassPropertyID], [WC_InOrder], [WC_OutOrder], [WC_ColumnName])
 VALUES 
 (@WrapperID, @ClassPropertyID, @InOrder, @OutOrder, @propertyName)

 IF (@@ERROR <> 0)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSERT_WRAPPERCOLUMNS_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1, @strGUID)
     RETURN @@ERROR
 END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_class_info 
(
 @classname AS nvarchar(128) -- name of the class to get info for
)
AS
BEGIN
 SET NOCOUNT ON

 DECLARE @classid AS UNIQUEIDENTIFIER

 SELECT @classid = CS_ClassID
 FROM dbo.ClassSchemas CS
 WHERE CS_ClassName = @classname
 
 IF (@@ROWCOUNT = 0)
 BEGIN
  DECLARE @errMsg AS NVARCHAR(400)
  DECLARE @severity AS int
  DECLARE @msgID AS int

     EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASS_BY_NAME_NOT_EXIST', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1, @classname)
     RETURN @@ERROR
 END 
 
 SELECT 
  CS_ClassID   as ClassID,
  CS_ClassName as ClassName,
  CS_Description as [Description]
 FROM dbo.ClassSchemas CS
 WHERE CS_ClassID = @classid
 
 
 SELECT 
  CP.CP_PropertyName  as PropertyName,
  PT.PT_TypeName  as PropertyTypeName,
  PT.PT_TypeID   as PropertyTypeID,
  CP.CP_PrimaryKey  as PK,
  CP.CP_Nullable   as [Null],
  DD.DD_Name   as Datatype,
  PT.PT_Length   as Length,
  PT.PT_Scale   as Scale,
  PT.PT_Precision  as [Precision],
  PT.PT_UDFValidationID  as UDFValidationID,
  CP.CP_Description  as [Description],
  CP.CP_DefaultValue      as DefaultValue
 FROM  dbo.ClassSchemas CS, 
  dbo.ClassProperties CP, 
  dbo.PropertyTypes PT, 
  dbo.DatatypeDefinitions DD
 WHERE CS.CS_ClassID   = CP.CP_ClassID
 AND   CP.CP_PropertyTypeID  = PT.PT_TypeID
 AND   PT.PT_DatatypeID   = DD.DD_DatatypeID
 AND   CS_ClassID   = @classid
 ORDER BY PropertyName

END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


ALTER TABLE dbo.ClassRelationships
    ADD CONSTRAINT smc_fk_ClassRelationships_ClassSchemas_SourceClassID
    FOREIGN KEY (CR_SourceClassID)
    REFERENCES dbo.ClassSchemas (CS_ClassID)
go


ALTER TABLE dbo.ClassRelationships
    ADD CONSTRAINT smc_fk_ClassRelationships_ClassSchemas_TargetClassID
    FOREIGN KEY (CR_TargetClassID)
    REFERENCES dbo.ClassSchemas (CS_ClassID)
go


ALTER TABLE dbo.ClassSchemaPartitions
    ADD CONSTRAINT smc_fk_ClassSchemaPartitions_ClassSchemas
    FOREIGN KEY (CSP_ClassID)
    REFERENCES dbo.ClassSchemas (CS_ClassID)
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_grooming
AS
BEGIN
 SET NOCOUNT ON

 DECLARE @errResult AS integer
    DECLARE @errMsg AS nvarchar(400)
    DECLARE @severity AS int
    DECLARE @msgID AS int

 DECLARE @datawarehouseInUse AS bit
 DECLARE @livePeriod AS tinyint
 DECLARE @tableName AS nvarchar(128)
 DECLARE @command AS nvarchar(150)
 

 -- Verify whether Datawarehousing is being used
 SELECT @datawarehouseInUse = GS_DataWarehouseInUse,
               @livePeriod = GS_LiveDataPeriod 
 FROM dbo.GroomingSettings

 -- There should be one and only one row
 IF (@@ROWCOUNT <> 1)
 BEGIN  
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INVALID_DATAWAREHOUSEINUSE', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
  -- Log the error so that the administrator can have a chance to fix it
  RAISERROR (@errMsg, @severity, 1) WITH LOG
  ROLLBACK TRANSACTION
     RETURN
 END

 IF (@datawarehouseInUse = 1)
 BEGIN
  -- If we are using DataWarehousing we need the names of
                -- all the tables that are older than the livePeriod
  DECLARE cur CURSOR LOCAL FOR 
  SELECT CSP_PartitionTableName 
                FROM dbo.ClassSchemaPartitions 
                WHERE CSP_DTSDone = 1 AND 
                      CSP_PartitionDate < dateadd(day, -1 * @livePeriod, getutcdate())
  OPEN cur
 END
 ELSE
 BEGIN
  DECLARE cur CURSOR LOCAL FOR 
  SELECT CSP_PartitionTableName 
                FROM dbo.ClassSchemaPartitions 
                WHERE CSP_PartitionDate < dateadd(day, -1 * @livePeriod, getutcdate())
  OPEN cur
 END

 FETCH NEXT FROM cur INTO @tableName

 WHILE @@FETCH_STATUS = 0
 BEGIN
                PRINT 'TRUNCATING TABLE ' + @tableName
         EXEC @errResult = dbo.smc_internal_truncatetable @tableName

  IF (@errResult <> 0)
  BEGIN  
   EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_GROOMING_TRUNCATE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1, @tableName) WITH LOG
      ROLLBACK TRANSACTION
      RETURN  
  END

  FETCH NEXT FROM cur INTO @tableName
 END
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


ALTER TABLE dbo.ClassSchemas
    ADD CONSTRAINT smc_fk_ClassSchemas_ClassSchemas_InheritsFrom
    FOREIGN KEY (CS_InheritsFrom)
    REFERENCES dbo.ClassSchemas (CS_ClassID)
go


ALTER TABLE dbo.ClassSchemas
    ADD CONSTRAINT smc_fk_ClassSchemas_ClassSchemas_ParentClassID
    FOREIGN KEY (CS_ParentClassID)
    REFERENCES dbo.ClassSchemas (CS_ClassID)
go


ALTER TABLE dbo.PropertyInstancesAudits
    ADD CONSTRAINT smc_fk_PropertyInstancesAudits_ClassSchemas
    FOREIGN KEY (PIA_ClassID)
    REFERENCES dbo.ClassSchemas (CS_ClassID)
go


ALTER TABLE dbo.RelationshipConstraints
    ADD CONSTRAINT smc_fk_RelationshipConstraints_ClassSchemas_SourceClassID
    FOREIGN KEY (RC_SourceClassID)
    REFERENCES dbo.ClassSchemas (CS_ClassID)
go


ALTER TABLE dbo.RelationshipConstraints
    ADD CONSTRAINT smc_fk_RelationshipConstraints_ClassSchemas_TargetClassID
    FOREIGN KEY (RC_TargetClassID)
    REFERENCES dbo.ClassSchemas (CS_ClassID)
go


ALTER TABLE dbo.SMO_ClassSMCClasses
    ADD CONSTRAINT smc_fk_SMO_ClassSMCClasses_ClassSchemas
    FOREIGN KEY (SCSC_SMCClassID)
    REFERENCES dbo.ClassSchemas (CS_ClassID)
go


ALTER TABLE dbo.SMO_RelationshipTargets
    ADD CONSTRAINT smc_fk_SMO_RelationshipTargets_ClassSchemas_TargetSMCClassID
    FOREIGN KEY (SRT_TargetSMCClassID)
    REFERENCES dbo.ClassSchemas (CS_ClassID)
go


ALTER TABLE dbo.WarehouseClassSchema
    ADD CONSTRAINT smc_fk_WarehouseClassSchema_ClassID
    FOREIGN KEY (WCS_ClassID)
    REFERENCES dbo.ClassSchemas (CS_ClassID)
go


ALTER TABLE dbo.WarehouseClassSchemaToProductSchema
    ADD CONSTRAINT smc_fk_WarehouseClassSchemaToProductSchema_ClassID
    FOREIGN KEY (WCSPS_ClassID)
    REFERENCES dbo.ClassSchemas (CS_ClassID)
go


ALTER TABLE dbo.WarehouseGroomingInfo
    ADD CONSTRAINT smc_fk_WarehouseGroomingInfo_ClassID
    FOREIGN KEY (WG_ClassID)
    REFERENCES dbo.ClassSchemas (CS_ClassID)
go


ALTER TABLE dbo.WrapperSchemas
    ADD CONSTRAINT smc_fk_WrapperSchemas_ClassSchemas
    FOREIGN KEY (WS_ClassID)
    REFERENCES dbo.ClassSchemas (CS_ClassID)
go


ALTER TABLE dbo.ClassSchemas
    ADD CONSTRAINT smc_fk_ClassSchemas_FileGroups
    FOREIGN KEY (CS_TableFileGroupID)
    REFERENCES dbo.FileGroups (FG_FileGroupID)
go


ALTER TABLE dbo.ClassSchemas
    ADD CONSTRAINT smc_fk_ClassSchemas_FileGroups1
    FOREIGN KEY (CS_HistoryTableFileGroupID)
    REFERENCES dbo.FileGroups (FG_FileGroupID)
go


ALTER TABLE dbo.ClassSchemas
    ADD CONSTRAINT smc_fk_ClassSchemas_Modifications
    FOREIGN KEY (CS_SignedModID)
    REFERENCES dbo.Modifications (M_ModificationID)
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_GetAllChangesForClass
(
 @classID  as uniqueidentifier,
 @startDate  as datetime,
 @endDate  as datetime
)
AS
BEGIN
 SET NOCOUNT ON

    DECLARE @errMsg AS nvarchar(400)
    DECLARE @severity AS int
    DECLARE @msgID AS int

 DECLARE @histViewName AS NVARCHAR(128)

 SELECT @histViewName = CS_HistoryViewName
 FROM dbo.ClassSchemas 
 WHERE CS_ClassID = @classID

 IF (@@ROWCOUNT <> 1)
 BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASS_NOT_FOUND', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
       RAISERROR (@errMsg, @severity, 1)
       RETURN
 END

 EXEC dbo.SMC_Internal_GetAllChanges @histViewName, @startDate, @endDate
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_generate_wrapper_for_class
( 
 @className AS nvarchar(128)
)
AS
 SET NOCOUNT ON
 -- add a new class/property combination to the classproperties table
 DECLARE @classID AS UNIQUEIDENTIFIER
 DECLARE @errMsg AS NVARCHAR(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int
 DECLARE @rowCount as int

 SELECT @classID = CS_ClassID 
 FROM dbo.ClassSchemas
 WHERE CS_ClassName = @className

 SET @rowCount = @@ROWCOUNT
 
 IF (@rowCount = 0)
 BEGIN
     EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASS_BY_NAME_NOT_EXIST', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1, @className)
     RETURN @@ERROR
 END
 ELSE IF (@rowCount != 1)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DUPLICATE_CLASS_NAME_WRAPPER', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1, @className)
  RETURN @@ERROR
 END
 
 
 INSERT INTO dbo.WrapperSchemas
 ([WS_WrapperID], [WS_Query], [WS_QueryType], [WS_WrapperType], [WS_WrapperFileName], [WS_ClassID], [WS_ClassName])
 VALUES(NewID(), NULL, 0, 1, NULL, @classID, @className)

 IF (@@ERROR <> 0)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSERT_WRAPPERSCHEMAS_TABLE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1, @className)
     RETURN @@ERROR
 END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


ALTER TABLE dbo.PropertyTypes
    ADD CONSTRAINT smc_fk_PropertyTypes_DatatypeDefinitions
    FOREIGN KEY (PT_DatatypeID)
    REFERENCES dbo.DatatypeDefinitions (DD_DatatypeID)
go


ALTER TABLE dbo.ValidationUDFParameters
    ADD CONSTRAINT smc_fk_ValidationUDFParameters_DatatypeDefinitions
    FOREIGN KEY (VUP_ParamDatatypeID)
    REFERENCES dbo.DatatypeDefinitions (DD_DatatypeID)
go


ALTER TABLE dbo.MethodParameterDefinitions
    ADD CONSTRAINT smc_fk_MethodParameterDefinitions_MethodParameterTypes
    FOREIGN KEY (MPD_ParameterTypeID)
    REFERENCES dbo.MethodParameterTypes (MPT_ParameterTypeID)
go


ALTER TABLE dbo.PropertyInstances
    ADD CONSTRAINT smc_fk_PropertyInstances_Modifications
    FOREIGN KEY (PI_StartModID)
    REFERENCES dbo.Modifications (M_ModificationID)
go


ALTER TABLE dbo.PropertyInstancesAudits
    ADD CONSTRAINT smc_fk_PropertyInstancesAudits_Modifications_ArchivedID
    FOREIGN KEY (PIA_EndModID)
    REFERENCES dbo.Modifications (M_ModificationID)
go


ALTER TABLE dbo.PropertyInstancesAudits
    ADD CONSTRAINT smc_fk_PropertyInstancesAudits_Modifications_CreationID
    FOREIGN KEY (PIA_StartModID)
    REFERENCES dbo.Modifications (M_ModificationID)
go


ALTER TABLE dbo.PropertyTypes
    ADD CONSTRAINT smc_fk_PropertyTypes_Modifications
    FOREIGN KEY (PT_SignedModID)
    REFERENCES dbo.Modifications (M_ModificationID)
go


ALTER TABLE dbo.RelationshipInstances
    ADD CONSTRAINT smc_fk_InstanceRelationships_Modifications
    FOREIGN KEY (RI_StartModID)
    REFERENCES dbo.Modifications (M_ModificationID)
go


ALTER TABLE dbo.RelationshipInstancesAudits
    ADD CONSTRAINT smc_fk_InstanceRelationshipsAudits_Modifications_ArchivedID
    FOREIGN KEY (RIA_EndModID)
    REFERENCES dbo.Modifications (M_ModificationID)
go


ALTER TABLE dbo.RelationshipInstancesAudits
    ADD CONSTRAINT smc_fk_InstanceRelationshipsAudits_Modifications_CreationID
    FOREIGN KEY (RIA_StartModID)
    REFERENCES dbo.Modifications (M_ModificationID)
go


ALTER TABLE dbo.RelationshipTypes
    ADD CONSTRAINT smc_fk_RelationshipTypes_Modifications
    FOREIGN KEY (RT_SignedModID)
    REFERENCES dbo.Modifications (M_ModificationID)
go


ALTER TABLE dbo.ValidationUDFs
    ADD CONSTRAINT smc_fk_ValidationUDFs_Modifications
    FOREIGN KEY (VU_SignedModID)
    REFERENCES dbo.Modifications (M_ModificationID)
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE  PROCEDURE dbo.smc_internal_getmodificationid 
(
 @modificationID AS int OUTPUT
)
AS
BEGIN
 SET NOCOUNT ON

 -- get the unique transaction token
 DECLARE @transactionToken AS VARCHAR(255)
 EXEC dbo.sp_getbindtoken @transactionToken OUT

 SELECT @modificationID = M_ModificationID
 FROM dbo.Modifications
 WHERE M_TransactionToken = @transactionToken

 IF (@@ROWCOUNT = 0)
 BEGIN
  DECLARE @userid AS INT
  EXEC dbo.smc_internal_getuserid @userid OUT
 
  INSERT INTO dbo.Modifications (M_UserID, M_Date, M_TransactionToken) 
  VALUES (@userid, GETUTCDATE(), @transactionToken)
 
  IF (@@ERROR <> 0)
  BEGIN
   DECLARE @errMsg AS NVARCHAR(400)
   DECLARE @severity AS int
   DECLARE @msgID AS int
 
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSERT_MODIFICATIONS_TABLE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
      RAISERROR (@errMsg, @severity, 1)
      RETURN @@ERROR
  END
 
  SELECT @modificationID = SCOPE_IDENTITY()
 END
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_GetModificationID 
(
 @modID bigint OUT  -- modification id
)
AS
BEGIN
 SET NOCOUNT ON

 EXEC dbo.smc_internal_getmodificationid @modID OUT
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_Meta_Sign_RelationshipType 
(
 @relationshipTypeID as uniqueidentifier
)
AS
BEGIN
 SET NOCOUNT ON

 DECLARE @errResult AS int
 DECLARE @errMsg AS nvarchar(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int
 DECLARE @propTypeID AS uniqueidentifier
 DECLARE @modid AS bigint
 
 IF (@@TRANCOUNT <= 0)
        BEGIN
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_TRANSACTION_REQUIRED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1)     
     RETURN
 END

 -- Get a modification ID
        EXEC dbo.smc_internal_getmodificationid @modid output

 -- Sign the RelationshipType and assign the SignedModID 
 UPDATE dbo.RelationshipTypes 
        SET RT_Signed = 1, RT_SignedModID = @modid
 WHERE RT_RelationshipTypeID = @relationshipTypeID
 
 SET @errResult = @@ERROR 

 IF (@@ROWCOUNT <> 1)
 BEGIN
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INVALID_RELATIONSHIPTYPE_ID', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1)
     ROLLBACK TRANSACTION
     RETURN
 END
 
 IF (@errResult <> 0)
 BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_SIGN_RELATIONSHIPTYPE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1)
     ROLLBACK TRANSACTION
     RETURN
 END

END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_Meta_Sign_ValidationUDF
(
 @validationUDFID as uniqueidentifier
)
AS
BEGIN
 SET NOCOUNT ON

 DECLARE @errResult AS int
 DECLARE @errMsg AS nvarchar(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int
 DECLARE @modid AS bigint

 IF (@@TRANCOUNT <= 0)
        BEGIN
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_TRANSACTION_REQUIRED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1)     
     RETURN
 END

 -- Get a modification ID
        EXEC dbo.smc_internal_getmodificationid @modid output

 -- Sign the UDF and assign the SignedModID 
 UPDATE dbo.ValidationUDFs 
 SET VU_Signed = 1, 
            VU_SignedModID = @modid 
        WHERE VU_ValidationUDFID = @validationUDFID

 SET @errResult = @@ERROR

 IF (@@ROWCOUNT <> 1)
 BEGIN 
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INVALID_VALIDATIONUDF_ID', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
  RAISERROR (@errMsg, @severity, 1)
  ROLLBACK TRANSACTION
  RETURN
 END

 IF (@errResult <> 0)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_SIGN_VALIDATIONUDF_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
  RAISERROR (@errMsg, @severity, 1)
  ROLLBACK TRANSACTION
  RETURN
 END

END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


ALTER TABLE dbo.WarehouseClassSchemaToProductSchema
    ADD CONSTRAINT smc_fk_WarehouseClassSchemaToProductSchema_ProductID
    FOREIGN KEY (WCSPS_ProductID)
    REFERENCES dbo.ProductSchema (PS_ProductID)
go


ALTER TABLE dbo.PropertyTypeEnumerations
    ADD CONSTRAINT smc_fk_PropertyTypeEnumerations_PropertyTypes
    FOREIGN KEY (PTE_PropertyTypeID)
    REFERENCES dbo.PropertyTypes (PT_TypeID)
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_Meta_DeletePropertyType
(
 @propertyTypeID as uniqueidentifier
)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errResult AS integer
    DECLARE @errMsg AS nvarchar(400)
    DECLARE @severity AS int
    DECLARE @msgID AS int

    -- Delete ValidationUDFParameterValues associated
    -- with this property
    DELETE dbo.ValidationUDFParameterValues
    WHERE VUPV_PropertyTypeID = @propertyTypeID

    IF (@@ERROR <> 0)
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_PROPERTYTYPE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
        RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

    -- Delete the PropertyTypeEnumerations defined for
    -- this property
    DELETE dbo.PropertyTypeEnumerations
    WHERE PTE_PropertyTypeID = @propertyTypeID

    IF (@@ERROR <> 0)
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_PROPERTYTYPE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
        RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

    -- Delete the type itself
    DELETE dbo.PropertyTypes
    WHERE PT_TypeID = @propertyTypeID

    IF (@@ERROR <> 0)
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_PROPERTYTYPE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
        RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
  
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


ALTER TABLE dbo.PropertyTypes
    ADD CONSTRAINT smc_fk_PropertyTypes_PropertyTypes_ParentTypeID
    FOREIGN KEY (PT_ParentTypeID)
    REFERENCES dbo.PropertyTypes (PT_TypeID)
go


ALTER TABLE dbo.SMO_TypeConversions
    ADD CONSTRAINT smc_fk_SMO_TypeConversions_PropertyTypes_TypeID
    FOREIGN KEY (STC_SMCTypeID)
    REFERENCES dbo.PropertyTypes (PT_TypeID)
go


ALTER TABLE dbo.ValidationUDFParameterValues
    ADD CONSTRAINT smc_fk_ValidationUDFValues_PropertyTypes
    FOREIGN KEY (VUPV_PropertyTypeID)
    REFERENCES dbo.PropertyTypes (PT_TypeID)
go


ALTER TABLE dbo.RelationshipConstraints
    ADD CONSTRAINT smc_fk_RelationshipConstraints_RelationshipTypes
    FOREIGN KEY (RC_RelationshipTypeID)
    REFERENCES dbo.RelationshipTypes (RT_RelationshipTypeID)
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_Meta_DeleteRelationshipType
(
 @relationshipTypeID as uniqueidentifier
)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errResult AS integer
    DECLARE @errMsg AS nvarchar(400)
    DECLARE @severity AS int
    DECLARE @msgID AS int

    -- This one has FK relationship to RelationshipTypes
    DELETE dbo.RelationshipInstancesAudits
    WHERE RIA_RelationshipTypeID = @relationshipTypeID

    IF (@@ERROR <> 0)
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_RELATIONSHIPTYPE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
        RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

    -- This one has FK relationship to RelationshipTypes
    DELETE dbo.RelationshipInstances
    WHERE RI_RelationshipTypeID = @relationshipTypeID

    IF (@@ERROR <> 0)
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_RELATIONSHIPTYPE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
        RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END


    -- Delete the constraints defined for this type
    DELETE dbo.RelationshipConstraints 
    WHERE RC_RelationshipTypeID = @relationshipTypeID

    IF (@@ERROR <> 0)
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_RELATIONSHIPTYPE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
        RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

    -- Delete the type itself
    DELETE dbo.RelationshipTypes
    WHERE RT_RelationshipTypeID = @relationshipTypeID

    IF (@@ERROR <> 0)
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_RELATIONSHIPTYPE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
        RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


ALTER TABLE dbo.RelationshipInstances
    ADD CONSTRAINT smc_fk_InstanceRelationships_RelationshipTypes
    FOREIGN KEY (RI_RelationshipTypeID)
    REFERENCES dbo.RelationshipTypes (RT_RelationshipTypeID)
go


ALTER TABLE dbo.RelationshipInstancesAudits
    ADD CONSTRAINT smc_fk_InstanceRelationshipsAudits_RelationshipTypes
    FOREIGN KEY (RIA_RelationshipTypeID)
    REFERENCES dbo.RelationshipTypes (RT_RelationshipTypeID)
go


ALTER TABLE dbo.SMO_ClassSMCClassJoins
    ADD CONSTRAINT smc_fk_SMO_ClassSMCClassJoins_RelationshipTypes_SMCRelationshipType
    FOREIGN KEY (SCSCJ_SMCRelationshipTypeID)
    REFERENCES dbo.RelationshipTypes (RT_RelationshipTypeID)
go


ALTER TABLE dbo.SMO_RelationshipTypes
    ADD CONSTRAINT smc_fk_SMO_RelationshipTypes_RelationshipTypes_SMCRelationshipTypeID
    FOREIGN KEY (SRT_SMCRelationshipTypeID)
    REFERENCES dbo.RelationshipTypes (RT_RelationshipTypeID)
go


ALTER TABLE dbo.WrapperSchemas
    ADD CONSTRAINT smc_fk_WrapperSchemas_RelationshipTypes
    FOREIGN KEY (WS_RelationshipTypeID)
    REFERENCES dbo.RelationshipTypes (RT_RelationshipTypeID)
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_GetAllChangesForRelationshipType
(
 @relationshiptypeID as uniqueidentifier,
 @startDate      as datetime,
 @endDate      as datetime
)
AS
BEGIN
 SET NOCOUNT ON

    DECLARE @errMsg AS nvarchar(400)
    DECLARE @severity AS int
    DECLARE @msgID AS int

 DECLARE @histViewName AS NVARCHAR(128)

 SELECT @histViewName = RT_HistoryViewName
 FROM dbo.RelationshipTypes 
 WHERE RT_RelationshipTypeID = @relationshiptypeID

 IF (@@ROWCOUNT <> 1)
 BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_RELATIONSHIPTYPE_NOT_FOUND', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
       RAISERROR (@errMsg, @severity, 1)
       RETURN
 END

 EXEC dbo.SMC_Internal_GetAllChanges @histViewName, @startDate, @endDate
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE  PROCEDURE dbo.smc_generate_wrapper_for_relationshiptype
( 
        @relationshipTypeName AS nvarchar(128),
 @relationshipTypeFriendlyName AS nvarchar(128)
)
AS
BEGIN
 SET NOCOUNT ON
 
 DECLARE @relationshipTypeID AS UNIQUEIDENTIFIER
 DECLARE @errMsg AS NVARCHAR(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int
 DECLARE @rowCount as int

 SELECT @relationshipTypeID = RT_RelationshipTypeID 
 FROM dbo.RelationshipTypes
 WHERE RT_Name = @relationshipTypeName

 SET @rowCount = @@ROWCOUNT
 
 IF (@rowCount = 0)
 BEGIN
     EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASS_BY_NAME_NOT_EXIST', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1, @relationshipTypeName)
     RETURN @@ERROR
 END
 ELSE IF (@rowCount != 1)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DUPLICATE_CLASS_NAME_WRAPPER', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1, @relationshipTypeName)
  RETURN @@ERROR
 END
 
 
 INSERT INTO dbo.WrapperSchemas
 ([WS_WrapperID], [WS_Query], [WS_QueryType], [WS_WrapperType], [WS_WrapperFileName], [WS_ClassID], [WS_ClassName], [WS_RelationshipTypeID])
 VALUES(NewID(), NULL, 2, 1, NULL, NULL, @relationshipTypeFriendlyName, @relationshipTypeID)

 IF (@@ERROR <> 0)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSERT_WRAPPERSCHEMAS_TABLE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1, @relationshipTypeName)
     RETURN @@ERROR
 END
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_AddValidationUDF (@udfName as nvarchar(128), @description as nvarchar(256), @udfID uniqueidentifier OUT)
AS
BEGIN
 SET NOCOUNT ON

 DECLARE @errMsg AS NVARCHAR(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int

 IF (@udfName is NULL OR @description is NULL OR @udfID IS NULL)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_PARAMETER_CANNOT_BE_NULL', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1)
     RETURN
 END

 -- This stored proc needs to be called inside a transaction. Fail if that is not the case.
 IF (@@TRANCOUNT = 0)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_TRANSACTION_REQUIRED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1)
     RETURN
 END
 
 -- check if the UDF exists
 IF NOT EXISTS 
 (
  SELECT *
  FROM INFORMATION_SCHEMA.ROUTINES R
         WHERE ROUTINE_TYPE = 'FUNCTION'
  AND SPECIFIC_NAME  = @udfName
 )
 BEGIN
     EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_UDF_NOT_DEFINED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1, @udfName)
     RETURN @@ERROR
 END

 -- check if the UDF definition already exists
 SELECT @udfID = VU_ValidationUDFID
 FROM dbo.ValidationUDFs
 WHERE VU_Name = @udfName
 
 IF (@@ROWCOUNT = 1)
 BEGIN
  -- UDF already defined. Immediately return
  RETURN
 END
 
 DECLARE @numParams as int

 -- Get the names and data types of the parameters for the UDF 
 SELECT  R.SPECIFIC_NAME    AS UDFName, 
  P.PARAMETER_NAME    AS ParameterName, 
  P.DATA_TYPE     AS Datatype, 
  P.ORDINAL_POSITION    AS ParameterOrder,
  ISNULL(P.CHARACTER_MAXIMUM_LENGTH, 0)  AS Length,
  ISNULL(P.NUMERIC_PRECISION,0)   AS Numeric_Precision,
  ISNULL(P.NUMERIC_SCALE,0)  AS Numeric_Scale
 INTO #udfParams
 FROM INFORMATION_SCHEMA.ROUTINES R,
      INFORMATION_SCHEMA.PARAMETERS P
 WHERE R.ROUTINE_TYPE   = 'FUNCTION'
 AND   R.SPECIFIC_NAME  = P.SPECIFIC_NAME
 AND   R.SPECIFIC_NAME  = @udfName
 AND   P.IS_RESULT      = 'NO'

 SET @numParams = @@ROWCOUNT

 -- Let's create the entries for the UDF and the parameters
 INSERT INTO dbo.ValidationUDFs
        (VU_ValidationUDFID, VU_Name, VU_Description)
 VALUES
 (@udfID, @udfName, @description)

 IF (@@ERROR <> 0)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSERT_VALIDATIONUDFS_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1)
  ROLLBACK TRANSACTION
     RETURN @@ERROR
 END

 INSERT INTO dbo.ValidationUDFParameters
 (VUP_ValidationUDFID, VUP_ParamName, VUP_ParamOrder, VUP_ParamDatatypeID, VUP_ParamLength, VUP_ParamScale, VUP_ParamPrecision)
 SELECT @udfID, U.ParameterName, U.ParameterOrder, DD.DD_DatatypeID, 
  CASE DD.DD_RequiresLength
   WHEN 1 THEN U.Length
   ELSE 0
  END, 
  CASE DD.DD_RequiresScalePrecision
   WHEN 1 THEN U.Numeric_Scale
   ELSE 0
  END, 
  CASE DD.DD_RequiresScalePrecision
   WHEN 1 THEN U.Numeric_Precision
   ELSE 0
  END
 FROM #udfParams U, dbo.DatatypeDefinitions DD
 WHERE U.Datatype = DD.DD_Name

 IF (@@ERROR <> 0)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSERT_VALIDATIONUDFPARAMETERS_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1)
  ROLLBACK TRANSACTION
     RETURN @@ERROR
 END

 DECLARE @expectedNumParams as int
 
 -- ensure that all datatypes were recognized properly. If not, the number of parameters in the udf and the number of parameters
 -- stored in the parameter table are out of sync, and we will have to rollback in that case.
 SELECT @expectedNumParams = COUNT(*)
 FROM dbo.ValidationUDFParameters
 WHERE VUP_ValidationUDFID = @udfID

 IF (@expectedNumParams <> @numParams)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSERT_VALIDATIONUDFPARAMERTS_COUNT_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1)
  ROLLBACK TRANSACTION
     RETURN @@ERROR
 END
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_Meta_DeleteValidationUDF
(
 @validationUDFID as uniqueidentifier
)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errResult AS integer
    DECLARE @errMsg AS nvarchar(400)
    DECLARE @severity AS int
    DECLARE @msgID AS int

    -- Delete all the parameters defined for this ValidationUDF
    DELETE dbo.ValidationUDFParameters
    WHERE VUP_ValidationUDFID = @validationUDFID

    IF (@@ERROR <> 0)
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_VALIDATIONUDFS_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
        RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

    -- Delete the ValidationUDF
    DELETE dbo.ValidationUDFs
    WHERE VU_ValidationUDFID = @validationUDFID

    IF (@@ERROR <> 0)
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_DELETE_VALIDATIONUDFS_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
        RAISERROR (@errMsg, @severity, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.smc_add_parameter_to_sproc
(
    @wrapperName nvarchar(128),
    @className nvarchar(128),
    @propertyName nvarchar(128),
    @order int,
    @type int
)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @wrapperID AS uniqueidentifier
    DECLARE @classID AS uniqueidentifier
    DECLARE @queryType AS int
    DECLARE @classPropertyID AS uniqueidentifier
    DECLARE @inOrder AS int
    DECLARE @outOrder AS int

    DECLARE @errMsg AS NVARCHAR(400)
    DECLARE @severity AS int
    DECLARE @msgID AS int

-- Type 1 -> IN parameter only
-- Type 2 -> IN/OUT parameter
-- Type 3 -> Return value - Order has to be 1

    -- Type 0 or NULL is only for return set
    IF ((@type <> 1) AND (@type <> 2) AND (@type <> 3) )
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_WRAPPERCOLUMNS_VARIABLETYPE_INVALID', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT  
        RAISERROR (@errMsg, @severity, 1, @wrapperName)  
        RETURN @@ERROR  
    END
    
    -- Type 1 means IN only parameter
    IF (@type = 1)
    BEGIN
        SET @inOrder = @order
        SET @outOrder = NULL
    END
 
    -- Type 2 means variables declared as OUTPUT 
    -- which can be IN an OUT
    IF (@type = 2)
    BEGIN
        SET @inOrder = @order;
        SET @outOrder = @order;
    END

    -- Type 3 (return value) must be the first
    -- parameter, so its order has to be 1
    IF (@type = 3) 
    BEGIN
        IF (@order <> 1)
        BEGIN
            EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_WRAPPERCOLUMNS_INCOMPATIBLE_ORDER_TYPE', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT  
            RAISERROR (@errMsg, @severity, 1, @wrapperName)  
            RETURN @@ERROR             
        END
        ELSE
        BEGIN
            SET @inOrder = NULL
            SET @outOrder = 1
        END
    END

    -- Getting the matching entry for the sproc in WrapperSchemas
    SELECT @wrapperID = WrapperID, @queryType = QueryType
    FROM dbo.SMC_Meta_WrapperSchemas
    WHERE ClassName = @wrapperName

    IF (@@ROWCOUNT <> 1)  
    BEGIN  
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_WRAPPER_NAME_NOT_EXIST', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT  
        RAISERROR (@errMsg, @severity, 1, @wrapperName)  
        RETURN @@ERROR  
    END  

    -- Making sure the wrapper type is SPROC
    IF (@queryType <> 3)
    BEGIN
          EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_WRAPPERCOLUMNS_INVALID_REFERENCED_WRAPPER', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT  
          RAISERROR (@errMsg, @severity, 1, @wrapperName)  
          RETURN @@ERROR  
    END

    -- Getting the ClassID from ClassSchemas for the supplied class name  
    SELECT @classID = ClassID  
    FROM dbo.SMC_Meta_ClassSchemas  
    WHERE ClassName = @className  
  
    IF (@@ROWCOUNT <> 1)  
    BEGIN  
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASSNAME_NOT_EXIST', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT  
        RAISERROR (@errMsg, @severity, 1, @className)  
        RETURN @@ERROR  
    END  
  
    -- Getting the ClassPropertyID from ClassProperties that matches
    -- the supplied className and propertyName
    SELECT @classPropertyID = CP.ClassPropertyID  
    FROM   dbo.SMC_Meta_ClassProperties AS CP  
    WHERE CP.PropertyName = @propertyName  
          AND CP.ClassID   = @classID  
  
    IF (@@ROWCOUNT <> 1)  
    BEGIN  
        DECLARE @strGUID AS NVARCHAR(40)  
        SET @strGUID = CAST (@classPropertyID AS NVARCHAR(40))  
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_CLASSPROPERTY_ID_NOT_EXIST', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT  
        RAISERROR (@errMsg, @severity, 1, @strGUID)  
        RETURN @@ERROR  
    END  

    INSERT INTO dbo.SMC_Meta_WrapperColumns
    (WrapperID, ClassPropertyID, InOrder, OutOrder, ColumnName, VariableType)
    VALUES
    (@wrapperID, @classPropertyID, @inOrder, @outOrder, @propertyName, @type)
 

    IF (@@ERROR <> 0)
    BEGIN
 EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSERT_WRAPPERCOLUMNS_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
    RAISERROR (@errMsg, @severity, 1, @strGUID)
    RETURN @@ERROR
    END
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.smc_generate_wrapper_for_query
( 
 @query AS nvarchar(512),
 @className AS nvarchar(128)
)
AS
BEGIN
 SET NOCOUNT ON
 -- add a new class/property combination to the classproperties table
 
 INSERT INTO dbo.WrapperSchemas
 ([WS_WrapperID], [WS_Query], [WS_QueryType], [WS_WrapperType], [WS_WrapperFileName], [WS_ClassID], [WS_ClassName])
 VALUES(NewID(), @query, 1, 1, NULL, NULL, @className)

 IF (@@ERROR <> 0)
 BEGIN
  DECLARE @errMsg AS NVARCHAR(400)
  DECLARE @severity AS int
  DECLARE @msgID AS int

     EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSERT_WRAPPERSCHEMAS_TABLE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1)
     RETURN @@ERROR
 END
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROC dbo.smc_generate_wrapper_for_sproc
(
 @query nvarchar(512),
 @className nvarchar(128),
 @fileName nvarchar(512) = NULL
)
AS
BEGIN
 SET NOCOUNT ON
 
 INSERT INTO dbo.SMC_Meta_WrapperSchemas
 (WrapperID, ClassID, ClassName, Query, QueryType, WrapperType, WrapperFileName, RelationshipTypeID)
 VALUES
 (newid()  , NULL  , @className, @query,  3      , 1          ,  @fileName     , NULL) 
 
 IF (@@ERROR <> 0)
 BEGIN
  DECLARE @errMsg AS NVARCHAR(400)
  DECLARE @severity AS int
  DECLARE @msgID AS int
   EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INSERT_WRAPPERSCHEMAS_TABLE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
  RAISERROR (@errMsg, @severity, 1)
  RETURN @@ERROR
 END
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


create proc dbo.dt_addtosourcecontrol
    @vchSourceSafeINI varchar(255) = '',
    @vchProjectName   varchar(255) ='',
    @vchComment       varchar(255) ='',
    @vchLoginName     varchar(255) ='',
    @vchPassword      varchar(255) =''

as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId = 0

declare @iStreamObjectId int
select @iStreamObjectId = 0

declare @VSSGUID varchar(100)
select @VSSGUID = 'SQLVersionControl.VCS_SQL'

declare @vchDatabaseName varchar(255)
select @vchDatabaseName = db_name()

declare @iReturnValue int
select @iReturnValue = 0

declare @iPropertyObjectId int
declare @vchParentId varchar(255)

declare @iObjectCount int
select @iObjectCount = 0

    exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT
    if @iReturn <> 0 GOTO E_OAError


    /* Create Project in SS */
    exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
											'AddProjectToSourceSafe',
											NULL,
											@vchSourceSafeINI,
											@vchProjectName output,
											@@SERVERNAME,
											@vchDatabaseName,
											@vchLoginName,
											@vchPassword,
											@vchComment


    if @iReturn <> 0 GOTO E_OAError

    /* Set Database Properties */

    begin tran SetProperties

    /* add high level object */

    exec @iPropertyObjectId = dbo.dt_adduserobject_vcs 'VCSProjectID'

    select @vchParentId = CONVERT(varchar(255),@iPropertyObjectId)

    exec dbo.dt_setpropertybyid @iPropertyObjectId, 'VCSProjectID', @vchParentId , NULL
    exec dbo.dt_setpropertybyid @iPropertyObjectId, 'VCSProject' , @vchProjectName , NULL
    exec dbo.dt_setpropertybyid @iPropertyObjectId, 'VCSSourceSafeINI' , @vchSourceSafeINI , NULL
    exec dbo.dt_setpropertybyid @iPropertyObjectId, 'VCSSQLServer', @@SERVERNAME, NULL
    exec dbo.dt_setpropertybyid @iPropertyObjectId, 'VCSSQLDatabase', @vchDatabaseName, NULL

    if @@error <> 0 GOTO E_General_Error

    commit tran SetProperties
    
    select @iObjectCount = 0;

CleanUp:
    select @vchProjectName
    select @iObjectCount
    return

E_General_Error:
    /* this is an all or nothing.  No specific error messages */
    goto CleanUp

E_OAError:
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    goto CleanUp



go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


create proc dbo.dt_checkinobject
    @chObjectType  char(4),
    @vchObjectName varchar(255),
    @vchComment    varchar(255)='',
    @vchLoginName  varchar(255),
    @vchPassword   varchar(255)='',
    @iVCSFlags     int = 0,
    @iActionFlag   int = 0,   /* 0 => AddFile, 1 => CheckIn */
    @txStream1     Text = '', /* drop stream   */ /* There is a bug that if items are NULL they do not pass to OLE servers */
    @txStream2     Text = '', /* create stream */
    @txStream3     Text = ''  /* grant stream  */


as

	set nocount on

	declare @iReturn int
	declare @iObjectId int
	select @iObjectId = 0
	declare @iStreamObjectId int

	declare @VSSGUID varchar(100)
	select @VSSGUID = 'SQLVersionControl.VCS_SQL'

	declare @iPropertyObjectId int
	select @iPropertyObjectId  = 0

    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchProjectName   varchar(255)
    declare @vchSourceSafeINI varchar(255)
    declare @vchServerName    varchar(255)
    declare @vchDatabaseName  varchar(255)
    declare @iReturnValue	  int
    declare @pos			  int
    declare @vchProcLinePiece varchar(255)

    
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSProject',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLServer',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLDatabase',   @vchDatabaseName  OUT

    if @chObjectType = 'PROC'
    begin
        if @iActionFlag = 1
        begin
            /* Procedure Can have up to three streams
            Drop Stream, Create Stream, GRANT stream */

            begin tran compile_all

            /* try to compile the streams */
            exec (@txStream1)
            if @@error <> 0 GOTO E_Compile_Fail

            exec (@txStream2)
            if @@error <> 0 GOTO E_Compile_Fail

            exec (@txStream3)
            if @@error <> 0 GOTO E_Compile_Fail
        end

        exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT
        if @iReturn <> 0 GOTO E_OAError

        exec @iReturn = master.dbo.sp_OAGetProperty @iObjectId, 'GetStreamObject', @iStreamObjectId OUT
        if @iReturn <> 0 GOTO E_OAError
        
        if @iActionFlag = 1
        begin
            
            declare @iStreamLength int
			
			select @pos=1
			select @iStreamLength = datalength(@txStream2)
			
			if @iStreamLength > 0
			begin
			
				while @pos < @iStreamLength
				begin
						
					select @vchProcLinePiece = substring(@txStream2, @pos, 255)
					
					exec @iReturn = master.dbo.sp_OAMethod @iStreamObjectId, 'AddStream', @iReturnValue OUT, @vchProcLinePiece
            		if @iReturn <> 0 GOTO E_OAError
            		
					select @pos = @pos + 255
					
				end
            
				exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
														'CheckIn_StoredProcedure',
														NULL,
														@sProjectName = @vchProjectName,
														@sSourceSafeINI = @vchSourceSafeINI,
														@sServerName = @vchServerName,
														@sDatabaseName = @vchDatabaseName,
														@sObjectName = @vchObjectName,
														@sComment = @vchComment,
														@sLoginName = @vchLoginName,
														@sPassword = @vchPassword,
														@iVCSFlags = @iVCSFlags,
														@iActionFlag = @iActionFlag,
														@sStream = ''
                                        
			end
        end
        else
        begin
        
            select colid, text into #ProcLines
            from syscomments
            where id = object_id(@vchObjectName)
            order by colid

            declare @iCurProcLine int
            declare @iProcLines int
            select @iCurProcLine = 1
            select @iProcLines = (select count(*) from #ProcLines)
            while @iCurProcLine <= @iProcLines
            begin
                select @pos = 1
                declare @iCurLineSize int
                select @iCurLineSize = len((select text from #ProcLines where colid = @iCurProcLine))
                while @pos <= @iCurLineSize
                begin                
                    select @vchProcLinePiece = convert(varchar(255),
                        substring((select text from #ProcLines where colid = @iCurProcLine),
                                  @pos, 255 ))
                    exec @iReturn = master.dbo.sp_OAMethod @iStreamObjectId, 'AddStream', @iReturnValue OUT, @vchProcLinePiece
                    if @iReturn <> 0 GOTO E_OAError
                    select @pos = @pos + 255                  
                end
                select @iCurProcLine = @iCurProcLine + 1
            end
            drop table #ProcLines

            exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
													'CheckIn_StoredProcedure',
													NULL,
													@sProjectName = @vchProjectName,
													@sSourceSafeINI = @vchSourceSafeINI,
													@sServerName = @vchServerName,
													@sDatabaseName = @vchDatabaseName,
													@sObjectName = @vchObjectName,
													@sComment = @vchComment,
													@sLoginName = @vchLoginName,
													@sPassword = @vchPassword,
													@iVCSFlags = @iVCSFlags,
													@iActionFlag = @iActionFlag,
													@sStream = ''
        end

        if @iReturn <> 0 GOTO E_OAError

        if @iActionFlag = 1
        begin
            commit tran compile_all
            if @@error <> 0 GOTO E_Compile_Fail
        end

    end

CleanUp:
	return

E_Compile_Fail:
	declare @lerror int
	select @lerror = @@error
	rollback tran compile_all
	RAISERROR (@lerror,16,-1)
	goto CleanUp

E_OAError:
	if @iActionFlag = 1 rollback tran compile_all
	exec dbo.dt_displayoaerror @iObjectId, @iReturn
	goto CleanUp



go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


create proc dbo.dt_checkoutobject
    @chObjectType  char(4),
    @vchObjectName varchar(255),
    @vchComment    varchar(255),
    @vchLoginName  varchar(255),
    @vchPassword   varchar(255),
    @iVCSFlags     int = 0,
    @iActionFlag   int = 0/* 0 => Checkout, 1 => GetLatest, 2 => UndoCheckOut */

as

	set nocount on

	declare @iReturn int
	declare @iObjectId int
	select @iObjectId =0

	declare @VSSGUID varchar(100)
	select @VSSGUID = 'SQLVersionControl.VCS_SQL'

	declare @iReturnValue int
	select @iReturnValue = 0

	declare @vchTempText varchar(255)

	/* this is for our strings */
	declare @iStreamObjectId int
	select @iStreamObjectId = 0

    declare @iPropertyObjectId int
    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchProjectName   varchar(255)
    declare @vchSourceSafeINI varchar(255)
    declare @vchServerName    varchar(255)
    declare @vchDatabaseName  varchar(255)
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSProject',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLServer',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLDatabase',   @vchDatabaseName  OUT

    if @chObjectType = 'PROC'
    begin
        /* Procedure Can have up to three streams
           Drop Stream, Create Stream, GRANT stream */

        exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT

        if @iReturn <> 0 GOTO E_OAError

        exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
												'CheckOut_StoredProcedure',
												NULL,
												@sProjectName = @vchProjectName,
												@sSourceSafeINI = @vchSourceSafeINI,
												@sObjectName = @vchObjectName,
												@sServerName = @vchServerName,
												@sDatabaseName = @vchDatabaseName,
												@sComment = @vchComment,
												@sLoginName = @vchLoginName,
												@sPassword = @vchPassword,
												@iVCSFlags = @iVCSFlags,
												@iActionFlag = @iActionFlag

        if @iReturn <> 0 GOTO E_OAError


        exec @iReturn = master.dbo.sp_OAGetProperty @iObjectId, 'GetStreamObject', @iStreamObjectId OUT

        if @iReturn <> 0 GOTO E_OAError

        create table #commenttext (id int identity, sourcecode varchar(255))


        select @vchTempText = 'STUB'
        while @vchTempText is not null
        begin
            exec @iReturn = master.dbo.sp_OAMethod @iStreamObjectId, 'GetStream', @iReturnValue OUT, @vchTempText OUT
            if @iReturn <> 0 GOTO E_OAError
            
            if (@vchTempText = '') set @vchTempText = null
            if (@vchTempText is not null) insert into #commenttext (sourcecode) select @vchTempText
        end

        select 'VCS'=sourcecode from #commenttext order by id
        select 'SQL'=text from syscomments where id = object_id(@vchObjectName) order by colid

    end

CleanUp:
    return

E_OAError:
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    GOTO CleanUp



go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_Meta_Sign_ClassSchema
(
 @classID as uniqueidentifier
)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @errResult AS int
    DECLARE @rowcount AS int
    DECLARE @errMsg AS nvarchar(400)
    DECLARE @severity AS int
    DECLARE @msgID AS int
    DECLARE @propTypeID AS uniqueidentifier
    DECLARE @modid AS bigint

    IF (@@TRANCOUNT <= 0)
    BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_TRANSACTION_REQUIRED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
 RAISERROR (@errMsg, @severity, 1)     
 RETURN
    END

    -- Get a modification ID
    EXEC dbo.smc_internal_getmodificationid @modid output

    -- Sign the Class and assign the SignedModID 
    UPDATE dbo.ClassSchemas 
    SET CS_Signed = 1,
    CS_SignedModID = @modid 
    WHERE CS_ClassID = @classID

    SET @errResult = @@ERROR

    IF (@@ROWCOUNT <> 1)
    BEGIN
        EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INVALID_CLASS_ID', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
 RAISERROR (@errMsg, @severity, 1)
 ROLLBACK TRANSACTION
 RETURN
    END

    IF (@errResult <> 0)
    BEGIN
 EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_SIGN_CLASSSCHEMAS_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
 RAISERROR (@errMsg, @severity, 1)
 ROLLBACK TRANSACTION
 RETURN
    END

    -- Now we need to sign all the associated PropertyTypes

    SET @rowcount = 1
 
    -- While there are unsigned Properties related to this class
    WHILE ( @rowcount <> 0 )
    BEGIN
 -- Getting one of the properties that are not yet signed
 SELECT TOP 1 @propTypeID = PT.PT_TypeID 
 FROM dbo.ClassSchemas as CS
 JOIN dbo.ClassProperties as CP
 ON CS.CS_ClassID = CP.CP_ClassID
 JOIN dbo.PropertyTypes as PT
 ON PT.PT_TypeID = CP.CP_PropertyTypeID
 WHERE PT.PT_Signed = 0
 AND CS.CS_ClassID = @classID

        SET @rowcount = @@ROWCOUNT

        IF (@rowcount <> 0)
        BEGIN
            PRINT 'Calling SMC_Meta_Sign_PropertyType ' + CONVERT(nvarchar(60), @propTypeID)

            EXEC dbo.SMC_Meta_Sign_PropertyType @propTypeID

            IF (@@ERROR <> 0)
     BEGIN
         EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_SIGN_PROPERTYTYPE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
         RAISERROR (@errMsg, @severity, 1)
  ROLLBACK TRANSACTION
  RETURN
            END
        END  
    END 

END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


SET ANSI_NULLS ON
go


SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE dbo.SMC_Meta_Sign_PropertyType
(
 @propertyTypeID as uniqueidentifier
)
AS
BEGIN
 SET NOCOUNT ON

 DECLARE @errResult AS int
 DECLARE @errMsg AS nvarchar(400)
 DECLARE @severity AS int
 DECLARE @msgID AS int
 DECLARE @udfID AS uniqueidentifier
 DECLARE @modid AS bigint

 IF (@@TRANCOUNT <= 0)
        BEGIN
      EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_TRANSACTION_REQUIRED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
     RAISERROR (@errMsg, @severity, 1)     
     RETURN
 END

 -- Get a modification ID
        EXEC dbo.smc_internal_getmodificationid @modid output

 -- Sign the Property and assign the SignedModID 
 UPDATE dbo.PropertyTypes 
 SET PT_Signed = 1,
            PT_SignedModID = @modid
        WHERE PT_TypeID = @propertyTypeID

 SET @errResult = @@ERROR

 IF (@@ROWCOUNT <> 1)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_INVALID_PROPERTYTYPE_ID', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
  RAISERROR (@errMsg, @severity, 1)
           ROLLBACK TRANSACTION
  RETURN
 END

 IF (@errResult <> 0)
 BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_SIGN_PROPERTYTYPE_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
  RAISERROR (@errMsg, @severity, 1)
           ROLLBACK TRANSACTION
  RETURN
 END

 -- Getting the ID of the validationUDF associated with this 
        -- PropertyType if there is one and it's not signed yet
 SELECT @udfID = PT.PT_UDFValidationID 
 FROM dbo.PropertyTypes AS PT
 JOIN dbo.ValidationUDFs as VU
 ON PT.PT_UDFValidationID = VU.VU_ValidationUDFID
 WHERE PT.PT_TypeID = @propertyTypeID
 AND VU.VU_Signed = 0

 IF (@udfID IS NOT NULL)
 BEGIN
     PRINT 'Calling SMC_Meta_Sign_ValidationUDF ' + CONVERT(nvarchar(60), @udfID)

     EXEC dbo.SMC_Meta_Sign_ValidationUDF @udfID

        IF (@@ERROR <> 0)
     BEGIN
  EXEC dbo.smc_internal_getmessage N'MSG_SMC_INTERNAL_SIGN_VALIDATIONUDF_FAILED', @errMsg OUTPUT, @severity OUTPUT, @msgID OUTPUT
  RAISERROR (@errMsg, @severity, 1)
           ROLLBACK TRANSACTION
  RETURN
     END
 END
END
go


SET ANSI_NULLS OFF
go


SET QUOTED_IDENTIFIER OFF
go


