

--SP_WHO2

--delete dbo.OriginalSystem where iOriginalSystemID = 10015

;WITH	FKEYS
		AS
		(
		SELECT f.name AS ForeignKey,
		SCHEMA_NAME(f.SCHEMA_ID) SchemaName,
		OBJECT_NAME(f.parent_object_id) AS TableName,
		COL_NAME(fc.parent_object_id,fc.parent_column_id) AS ColumnName,
		SCHEMA_NAME(o.SCHEMA_ID) ReferenceSchemaName,
		OBJECT_NAME (f.referenced_object_id) AS ReferenceTableName,
		COL_NAME(fc.referenced_object_id,fc.referenced_column_id) AS ReferenceColumnName
		FROM sys.foreign_keys AS f
		INNER JOIN sys.foreign_key_columns AS fc ON f.OBJECT_ID = fc.constraint_object_id
		INNER JOIN sys.objects AS o ON o.OBJECT_ID = fc.referenced_object_id
		)
		,IDXs
		AS
		(
		select		S.name as SchemaName
					, T.name as TableName
					, I.name as IndexName
					, AC.Name as ColumnName
					, IC.index_column_id IndexColumn
					, I.type_desc as IndexType
					  
		from		sys.tables as T
		join		sys.schemas s 
				on	t.schema_id = s.schema_id  
		join		sys.indexes as I 
				on	T.[object_id] = I.[object_id]
		join		sys.index_columns as IC 
				on	IC.[object_id] = I.[object_id] 
				and IC.[index_id] = I.[index_id]     
		join		sys.all_columns as AC 
				on	IC.[object_id] = AC.[object_id] 
				and IC.[column_id] = AC.[column_id]  
		)		

--SELECT		*
--FROM		IDXs
--WHERE		TableName = 'AuthSiteAccess'


SELECT		DISTINCT
			F.SchemaName
			,F.TableName
			,F.ColumnName
			--,I.IndexName
			--,I.IndexType
			,MIN(I.IndexColumn) IndexColumn
			,'IX_'+F.TableName+'_'+F.ColumnName [NewIndexName]
			,'CREATE NONCLUSTERED INDEX IX_'+F.TableName+'_'+F.ColumnName+' ON ['+F.SchemaName+'].['+F.TableName+'] (['+F.ColumnName+'])'
			
			
			
FROM		FKEYS F
LEFT JOIN	IDXs I
		ON	I.SchemaName = F.SchemaName
		AND I.TableName	 = F.TableName
		AND I.ColumnName = F.ColumnName
		
--WHERE		F.ReferenceTableName = 'OriginalSystem'
GROUP BY	F.SchemaName
			,F.TableName
			,F.ColumnName
			--,I.IndexName
			--,I.IndexType
HAVING		MIN(COALESCE(I.IndexColumn,0)) != 1		
		

ORDER BY	1,2,3





--CREATE NONCLUSTERED INDEX IX_AuthSiteAccess_OriginalSystemID ON [dbo].[AuthSiteAccess] ([OriginalSystemID])
--CREATE NONCLUSTERED INDEX IX_AuxDelivery_iOriginalSystemID ON [dbo].[AuxDelivery] ([iOriginalSystemID])
--CREATE NONCLUSTERED INDEX IX_Cart_iOriginalSystemID ON [dbo].[Cart] ([iOriginalSystemID])
--CREATE NONCLUSTERED INDEX IX_CCProcessorAccount_iOriginalSystemId ON [dbo].[CCProcessorAccount] ([iOriginalSystemId])
--CREATE NONCLUSTERED INDEX IX_Company_iOriginalSystemID ON [dbo].[Company] ([iOriginalSystemID])
--CREATE NONCLUSTERED INDEX IX_CompanyLegacyXref_iOriginalSystemId ON [dbo].[CompanyLegacyXref] ([iOriginalSystemId])
--CREATE NONCLUSTERED INDEX IX_CompanyPreference_iOriginalSystemID ON [dbo].[CompanyPreference] ([iOriginalSystemID])
--CREATE NONCLUSTERED INDEX IX_CountryToOpUnit_iOriginalSystemId ON [dbo].[CountryToOpUnit] ([iOriginalSystemId])
--CREATE NONCLUSTERED INDEX IX_Individual_iOriginalSystemID ON [dbo].[Individual] ([iOriginalSystemID])
--CREATE NONCLUSTERED INDEX IX_IndividualPreference_iOriginalSystemID ON [dbo].[IndividualPreference] ([iOriginalSystemID])
--CREATE NONCLUSTERED INDEX IX_IndividualSitePreference_SiteID ON [dbo].[IndividualSitePreference] ([SiteID])
--CREATE NONCLUSTERED INDEX IX_MediaBin_iOriginalSystemID ON [dbo].[MediaBin] ([iOriginalSystemID])
--CREATE NONCLUSTERED INDEX IX_ProfileIndividualRel_iOriginalSystemID ON [dbo].[ProfileIndividualRel] ([iOriginalSystemID])
--CREATE NONCLUSTERED INDEX IX_SearchHistory_iOriginalSystemID ON [dbo].[SearchHistory] ([iOriginalSystemID])
--CREATE NONCLUSTERED INDEX IX_RateProfile_OriginalSystem_OriginalSystemID ON [OPA].[RateProfile_OriginalSystem] ([OriginalSystemID])
--CREATE NONCLUSTERED INDEX IX_Subscription_CreatedFromSiteID ON [Subscription].[Subscription] ([CreatedFromSiteID])
--CREATE NONCLUSTERED INDEX IX_UserExperienceTests_SiteId ON [TestTarget].[UserExperienceTests] ([SiteId])
--CREATE NONCLUSTERED INDEX IX_AgreementFilter_SystemId ON [dbo].[AgreementFilter] ([SystemId])
--CREATE NONCLUSTERED INDEX IX_ScopingBundle_SystemId ON [dbo].[ScopingBundle] ([SystemId])
--CREATE NONCLUSTERED INDEX IX_SecurityComKey_SystemId1 ON [dbo].[SecurityComKey] ([SystemId1])
--CREATE NONCLUSTERED INDEX IX_SecurityComKey_SystemId2 ON [dbo].[SecurityComKey] ([SystemId2])
--CREATE NONCLUSTERED INDEX IX_SecuritySecret_SystemId ON [dbo].[SecuritySecret] ([SystemId])
--CREATE NONCLUSTERED INDEX IX_Address_chStateCode ON [dbo].[Address] ([chStateCode])
--CREATE NONCLUSTERED INDEX IX_Address_iEntityTypeID ON [dbo].[Address] ([iEntityTypeID])
--CREATE NONCLUSTERED INDEX IX_Address_iStatusID ON [dbo].[Address] ([iStatusID])
--CREATE NONCLUSTERED INDEX IX_Address_iTypeID ON [dbo].[Address] ([iTypeID])
--CREATE NONCLUSTERED INDEX IX_Address_nchCountryCode ON [dbo].[Address] ([nchCountryCode])
--CREATE NONCLUSTERED INDEX IX_AgentOperationalUnitRel_iOperationalUnitID ON [dbo].[AgentOperationalUnitRel] ([iOperationalUnitID])
--CREATE NONCLUSTERED INDEX IX_AgentTypeOperationalUnitRel_iOperationalUnitId ON [dbo].[AgentTypeOperationalUnitRel] ([iOperationalUnitId])
--CREATE NONCLUSTERED INDEX IX_AgentTypeOperationalUnitRel_iTypeId ON [dbo].[AgentTypeOperationalUnitRel] ([iTypeId])
--CREATE NONCLUSTERED INDEX IX_AgreementDetail_iBrandID ON [dbo].[AgreementDetail] ([iBrandID])
--CREATE NONCLUSTERED INDEX IX_AgreementDetail_iMediaTypeID ON [dbo].[AgreementDetail] ([iMediaTypeID])
--CREATE NONCLUSTERED INDEX IX_AgreementDetail_iTypeID ON [dbo].[AgreementDetail] ([iTypeID])
--CREATE NONCLUSTERED INDEX IX_AgreementDetailNLMResolution_iAgreementDetailID ON [dbo].[AgreementDetailNLMResolution] ([iAgreementDetailID])
--CREATE NONCLUSTERED INDEX IX_AgreementFilter_AgreementFilterTypeId ON [dbo].[AgreementFilter] ([AgreementFilterTypeId])
--CREATE NONCLUSTERED INDEX IX_AgreementSubDetail_iStatus ON [dbo].[AgreementSubDetail] ([iStatus])
--CREATE NONCLUSTERED INDEX IX_AuthGroupAuthorization_AuthorizationID ON [dbo].[AuthGroupAuthorization] ([AuthorizationID])
--CREATE NONCLUSTERED INDEX IX_AuthGroupCompany_AuthGroupID ON [dbo].[AuthGroupCompany] ([AuthGroupID])
--CREATE NONCLUSTERED INDEX IX_AuthGroupIndividual_AuthGroupID ON [dbo].[AuthGroupIndividual] ([AuthGroupID])
--CREATE NONCLUSTERED INDEX IX_AuxDelivery_iAuxDeliveryReasonID ON [dbo].[AuxDelivery] ([iAuxDeliveryReasonID])
--CREATE NONCLUSTERED INDEX IX_AuxDelivery_iBrandID ON [dbo].[AuxDelivery] ([iBrandID])
--CREATE NONCLUSTERED INDEX IX_AuxDelivery_iStatusID ON [dbo].[AuxDelivery] ([iStatusID])
--CREATE NONCLUSTERED INDEX IX_AuxDeliveryReasonType_iMediaTypeID ON [dbo].[AuxDeliveryReasonType] ([iMediaTypeID])
--CREATE NONCLUSTERED INDEX IX_AuxDeliveryReasonType_iStatusID ON [dbo].[AuxDeliveryReasonType] ([iStatusID])
--CREATE NONCLUSTERED INDEX IX_Cart_iIndividualID ON [dbo].[Cart] ([iIndividualID])
--CREATE NONCLUSTERED INDEX IX_Cart_nchCountryCode ON [dbo].[Cart] ([nchCountryCode])
--CREATE NONCLUSTERED INDEX IX_Cart_vchCurrencyCode ON [dbo].[Cart] ([vchCurrencyCode])
--CREATE NONCLUSTERED INDEX IX_CartDetail_iBrandID ON [dbo].[CartDetail] ([iBrandID])
--CREATE NONCLUSTERED INDEX IX_CartDetail_iMediaTypeID ON [dbo].[CartDetail] ([iMediaTypeID])
--CREATE NONCLUSTERED INDEX IX_CartDetail_iStatusId ON [dbo].[CartDetail] ([iStatusId])
--CREATE NONCLUSTERED INDEX IX_CartDetail_iTaxTypeId ON [dbo].[CartDetail] ([iTaxTypeId])
--CREATE NONCLUSTERED INDEX IX_CartTax_iTaxTypeId ON [dbo].[CartTax] ([iTaxTypeId])
--CREATE NONCLUSTERED INDEX IX_CCProcessorAccount_iPartnerId ON [dbo].[CCProcessorAccount] ([iPartnerId])
--CREATE NONCLUSTERED INDEX IX_CCProcessorAccount_vchCurrencyCode ON [dbo].[CCProcessorAccount] ([vchCurrencyCode])
--CREATE NONCLUSTERED INDEX IX_Company_iCompanyTypeID ON [dbo].[Company] ([iCompanyTypeID])
--CREATE NONCLUSTERED INDEX IX_Company_iOrgTypeCategoryOrgTypeRelID ON [dbo].[Company] ([iOrgTypeCategoryOrgTypeRelID])
--CREATE NONCLUSTERED INDEX IX_Company_iPricePlanTypeID ON [dbo].[Company] ([iPricePlanTypeID])
--CREATE NONCLUSTERED INDEX IX_Company_iStatementCyclePrefTypeID ON [dbo].[Company] ([iStatementCyclePrefTypeID])
--CREATE NONCLUSTERED INDEX IX_Company_iStatusID ON [dbo].[Company] ([iStatusID])
--CREATE NONCLUSTERED INDEX IX_Company_vchCurrencyCode ON [dbo].[Company] ([vchCurrencyCode])
--CREATE NONCLUSTERED INDEX IX_CompanyContentAccessType_ContentAccessTypeID ON [dbo].[CompanyContentAccessType] ([ContentAccessTypeID])
--CREATE NONCLUSTERED INDEX IX_CompanyIndividualRel_iCompanyID ON [dbo].[CompanyIndividualRel] ([iCompanyID])
--CREATE NONCLUSTERED INDEX IX_CompanyIndividualRel_iStatusID ON [dbo].[CompanyIndividualRel] ([iStatusID])
--CREATE NONCLUSTERED INDEX IX_CompanyNotes_iSubjectId ON [dbo].[CompanyNotes] ([iSubjectId])
--CREATE NONCLUSTERED INDEX IX_CompanySCIUserRel_iCompensationRoleID ON [dbo].[CompanySCIUserRel] ([iCompensationRoleID])
--CREATE NONCLUSTERED INDEX IX_CompanySCIUserRel_iStatusID ON [dbo].[CompanySCIUserRel] ([iStatusID])
--CREATE NONCLUSTERED INDEX IX_CompanyTypeLocalized_vchLanguageCode ON [dbo].[CompanyTypeLocalized] ([vchLanguageCode])
--CREATE NONCLUSTERED INDEX IX_CompensationRole_iStatusID ON [dbo].[CompensationRole] ([iStatusID])
--CREATE NONCLUSTERED INDEX IX_CompensationRoleRule_iCompensationRoleID ON [dbo].[CompensationRoleRule] ([iCompensationRoleID])
--CREATE NONCLUSTERED INDEX IX_Contact_iCompanyID ON [dbo].[Contact] ([iCompanyID])
--CREATE NONCLUSTERED INDEX IX_Contact_iStatusID ON [dbo].[Contact] ([iStatusID])
--CREATE NONCLUSTERED INDEX IX_ContactSubject_iStatusId ON [dbo].[ContactSubject] ([iStatusId])
--CREATE NONCLUSTERED INDEX IX_ContentCategory_ContentBillingId ON [dbo].[ContentCategory] ([ContentBillingId])
--CREATE NONCLUSTERED INDEX IX_CountryToOpUnit_iOperationalUnitId ON [dbo].[CountryToOpUnit] ([iOperationalUnitId])
--CREATE NONCLUSTERED INDEX IX_CreateSessionResult_ResultStatusId ON [dbo].[CreateSessionResult] ([ResultStatusId])
--CREATE NONCLUSTERED INDEX IX_CreditCard_iStatusID ON [dbo].[CreditCard] ([iStatusID])
--CREATE NONCLUSTERED INDEX IX_CreditCard_iTypeID ON [dbo].[CreditCard] ([iTypeID])
--CREATE NONCLUSTERED INDEX IX_CreditStatus_imp_iEntityTypeID ON [dbo].[CreditStatus_imp] ([iEntityTypeID])
--CREATE NONCLUSTERED INDEX IX_DistributorContractNote_iContractID ON [dbo].[DistributorContractNote] ([iContractID])
--CREATE NONCLUSTERED INDEX IX_DistributorContractPercentage_iCollectionID ON [dbo].[DistributorContractPercentage] ([iCollectionID])
--CREATE NONCLUSTERED INDEX IX_DistributorContractPercentage_iPercentTypeID ON [dbo].[DistributorContractPercentage] ([iPercentTypeID])
--CREATE NONCLUSTERED INDEX IX_DistributorContractPercentage_iProductTypeID ON [dbo].[DistributorContractPercentage] ([iProductTypeID])
--CREATE NONCLUSTERED INDEX IX_EasyAccessContentCategoryRef_ContentCategoryId ON [dbo].[EasyAccessContentCategoryRef] ([ContentCategoryId])
--CREATE NONCLUSTERED INDEX IX_EasyAccessDetailInfo_ContentCategoryId ON [dbo].[EasyAccessDetailInfo] ([ContentCategoryId])
--CREATE NONCLUSTERED INDEX IX_EasyAccessDetailInfo_EasyAccessTypeId ON [dbo].[EasyAccessDetailInfo] ([EasyAccessTypeId])
--CREATE NONCLUSTERED INDEX IX_EasyAccessDetailInfo_PortfolioCollectionId ON [dbo].[EasyAccessDetailInfo] ([PortfolioCollectionId])
--CREATE NONCLUSTERED INDEX IX_EasyAccessDetailInfo_PortfolioId ON [dbo].[EasyAccessDetailInfo] ([PortfolioId])
--CREATE NONCLUSTERED INDEX IX_EasyAccessHeader_ImageSizeTypeId ON [dbo].[EasyAccessHeader] ([ImageSizeTypeId])
--CREATE NONCLUSTERED INDEX IX_EditorialOrderSchedule_OrderID ON [dbo].[EditorialOrderSchedule] ([OrderID])
--CREATE NONCLUSTERED INDEX IX_EditorialOrderSchedule_SubscriptionID ON [dbo].[EditorialOrderSchedule] ([SubscriptionID])
--CREATE NONCLUSTERED INDEX IX_EditorialSubscriptionCategory_iBrandID ON [dbo].[EditorialSubscriptionCategory] ([iBrandID])
--CREATE NONCLUSTERED INDEX IX_EditorialSubscriptionCategoryRef_SubscriptionCategoryId ON [dbo].[EditorialSubscriptionCategoryRef] ([SubscriptionCategoryId])
--CREATE NONCLUSTERED INDEX IX_Email_iStatusID ON [dbo].[Email] ([iStatusID])
--CREATE NONCLUSTERED INDEX IX_Email_iTypeID ON [dbo].[Email] ([iTypeID])
--CREATE NONCLUSTERED INDEX IX_ImagePartnerBrand_iBrandID ON [dbo].[ImagePartnerBrand] ([iBrandID])
--CREATE NONCLUSTERED INDEX IX_ImagePartnerBrand_iCompanyID ON [dbo].[ImagePartnerBrand] ([iCompanyID])
--CREATE NONCLUSTERED INDEX IX_Individual_iCompanyTypeId ON [dbo].[Individual] ([iCompanyTypeId])
--CREATE NONCLUSTERED INDEX IX_Individual_iJobDescriptionTypeId ON [dbo].[Individual] ([iJobDescriptionTypeId])
--CREATE NONCLUSTERED INDEX IX_Individual_iJobTitleCategoryJobTitleRelID ON [dbo].[Individual] ([iJobTitleCategoryJobTitleRelID])
--CREATE NONCLUSTERED INDEX IX_Individual_iOfficeId ON [dbo].[Individual] ([iOfficeId])
--CREATE NONCLUSTERED INDEX IX_Individual_iOrgTypeCategoryOrgTypeRelID ON [dbo].[Individual] ([iOrgTypeCategoryOrgTypeRelID])
--CREATE NONCLUSTERED INDEX IX_Individual_iStatusID ON [dbo].[Individual] ([iStatusID])
--CREATE NONCLUSTERED INDEX IX_Individual_iTypeID ON [dbo].[Individual] ([iTypeID])
--CREATE NONCLUSTERED INDEX IX_Individual_vchEmailLanguageCode ON [dbo].[Individual] ([vchEmailLanguageCode])
--CREATE NONCLUSTERED INDEX IX_IndividualHomeDomain_HomeDomainSourceID ON [dbo].[IndividualHomeDomain] ([HomeDomainSourceID])
--CREATE NONCLUSTERED INDEX IX_IndividualHomeDomain_TopLevelDomainID ON [dbo].[IndividualHomeDomain] ([TopLevelDomainID])
--CREATE NONCLUSTERED INDEX IX_IndividualInterestType_iInterestTypeId ON [dbo].[IndividualInterestType] ([iInterestTypeId])
--CREATE NONCLUSTERED INDEX IX_IndividualJobRoleRel_JobRoleID ON [dbo].[IndividualJobRoleRel] ([JobRoleID])
--CREATE NONCLUSTERED INDEX IX_IndividualMarketingPreference_MarketingPreferenceCategoryID ON [dbo].[IndividualMarketingPreference] ([MarketingPreferenceCategoryID])
--CREATE NONCLUSTERED INDEX IX_IndividualNotes_iSubjectId ON [dbo].[IndividualNotes] ([iSubjectId])
--CREATE NONCLUSTERED INDEX IX_IndividualRestock_RestockParentValueId ON [dbo].[IndividualRestock] ([RestockParentValueId])
--CREATE NONCLUSTERED INDEX IX_IndividualRestock_RestockValueId ON [dbo].[IndividualRestock] ([RestockValueId])
--CREATE NONCLUSTERED INDEX IX_InterestTypeLocalized_vchLanguageCode ON [dbo].[InterestTypeLocalized] ([vchLanguageCode])
--CREATE NONCLUSTERED INDEX IX_JobDescriptionTypeLocalized_vchLanguageCode ON [dbo].[JobDescriptionTypeLocalized] ([vchLanguageCode])
--CREATE NONCLUSTERED INDEX IX_JobTitleCategoryJobTitleRel_JobTitleCategoryID ON [dbo].[JobTitleCategoryJobTitleRel] ([JobTitleCategoryID])
--CREATE NONCLUSTERED INDEX IX_JobTitleCategoryJobTitleRel_JobTitleID ON [dbo].[JobTitleCategoryJobTitleRel] ([JobTitleID])
--CREATE NONCLUSTERED INDEX IX_JobTitleMap_JobTitleRelID ON [dbo].[JobTitleMap] ([JobTitleRelID])
--CREATE NONCLUSTERED INDEX IX_JobTitleMap_JobTypeID ON [dbo].[JobTitleMap] ([JobTypeID])
--CREATE NONCLUSTERED INDEX IX_JobTitleMap_OrgTypeRelID ON [dbo].[JobTitleMap] ([OrgTypeRelID])
--CREATE NONCLUSTERED INDEX IX_LicensePreferenceBrand_BrandID ON [dbo].[LicensePreferenceBrand] ([BrandID])
--CREATE NONCLUSTERED INDEX IX_MasterDelegateTerritory_iCompanyID ON [dbo].[MasterDelegateTerritory] ([iCompanyID])
--CREATE NONCLUSTERED INDEX IX_MediaBin_iMediaTypeID ON [dbo].[MediaBin] ([iMediaTypeID])
--CREATE NONCLUSTERED INDEX IX_MediaBinItem_iBrandID ON [dbo].[MediaBinItem] ([iBrandID])
--CREATE NONCLUSTERED INDEX IX_MediaRoom_iStatusID ON [dbo].[MediaRoom] ([iStatusID])
--CREATE NONCLUSTERED INDEX IX_MediaRoomAsset_iBrandID ON [dbo].[MediaRoomAsset] ([iBrandID])
--CREATE NONCLUSTERED INDEX IX_MediaRoomAsset_iLicenseStatusID ON [dbo].[MediaRoomAsset] ([iLicenseStatusID])
--CREATE NONCLUSTERED INDEX IX_OfficeLocation_iStatusId ON [dbo].[OfficeLocation] ([iStatusId])
--CREATE NONCLUSTERED INDEX IX_OrderDetail_iBrandID ON [dbo].[OrderDetail] ([iBrandID])
--CREATE NONCLUSTERED INDEX IX_OrderInvoicePub_OrderID ON [dbo].[OrderInvoicePub] ([OrderID])
--CREATE NONCLUSTERED INDEX IX_Orders_chAffiliateCode ON [dbo].[Orders] ([chAffiliateCode])
--CREATE NONCLUSTERED INDEX IX_Orders_iAffiliateDetailID ON [dbo].[Orders] ([iAffiliateDetailID])
--CREATE NONCLUSTERED INDEX IX_Orders_iOperationalUnitId ON [dbo].[Orders] ([iOperationalUnitId])
--CREATE NONCLUSTERED INDEX IX_Orders_iPaymentMethodTypeID ON [dbo].[Orders] ([iPaymentMethodTypeID])
--CREATE NONCLUSTERED INDEX IX_Orders_iShippingMethodTypeID ON [dbo].[Orders] ([iShippingMethodTypeID])
--CREATE NONCLUSTERED INDEX IX_Orders_iStatusID ON [dbo].[Orders] ([iStatusID])
--CREATE NONCLUSTERED INDEX IX_Orders_iTypeID ON [dbo].[Orders] ([iTypeID])
--CREATE NONCLUSTERED INDEX IX_Orders_vchCurrencyCode ON [dbo].[Orders] ([vchCurrencyCode])
--CREATE NONCLUSTERED INDEX IX_Orders_vchLanguageCode ON [dbo].[Orders] ([vchLanguageCode])
--CREATE NONCLUSTERED INDEX IX_OrderTax_iTaxTypeId ON [dbo].[OrderTax] ([iTaxTypeId])
--CREATE NONCLUSTERED INDEX IX_OrgTypeCategoryOrgTypeRel_OrgTypeCategoryID ON [dbo].[OrgTypeCategoryOrgTypeRel] ([OrgTypeCategoryID])
--CREATE NONCLUSTERED INDEX IX_OrgTypeCategoryOrgTypeRel_OrgTypeID ON [dbo].[OrgTypeCategoryOrgTypeRel] ([OrgTypeID])
--CREATE NONCLUSTERED INDEX IX_OrgTypeJobTitleCategoryRel_JobTitleCategoryID ON [dbo].[OrgTypeJobTitleCategoryRel] ([JobTitleCategoryID])
--CREATE NONCLUSTERED INDEX IX_OrgTypeJobTitleCategoryRel_OrgTypeID ON [dbo].[OrgTypeJobTitleCategoryRel] ([OrgTypeID])
--CREATE NONCLUSTERED INDEX IX_OrgTypeMap_CompanyTypeID ON [dbo].[OrgTypeMap] ([CompanyTypeID])
--CREATE NONCLUSTERED INDEX IX_OrgTypeMap_OrgTypeRelID ON [dbo].[OrgTypeMap] ([OrgTypeRelID])
--CREATE NONCLUSTERED INDEX IX_PartnerBundle_PartnerBundleTypeId ON [dbo].[PartnerBundle] ([PartnerBundleTypeId])
--CREATE NONCLUSTERED INDEX IX_Phone_iEntityTypeID ON [dbo].[Phone] ([iEntityTypeID])
--CREATE NONCLUSTERED INDEX IX_Phone_iStatusID ON [dbo].[Phone] ([iStatusID])
--CREATE NONCLUSTERED INDEX IX_Phone_iTechnologyTypeID ON [dbo].[Phone] ([iTechnologyTypeID])
--CREATE NONCLUSTERED INDEX IX_Phone_iUsageTypeID ON [dbo].[Phone] ([iUsageTypeID])
--CREATE NONCLUSTERED INDEX IX_Portfolio_BusinessAreaId ON [dbo].[Portfolio] ([BusinessAreaId])
--CREATE NONCLUSTERED INDEX IX_Portfolio_PortfolioTypeId ON [dbo].[Portfolio] ([PortfolioTypeId])
--CREATE NONCLUSTERED INDEX IX_PortfolioDetail_MediaType ON [dbo].[PortfolioDetail] ([MediaType])
--CREATE NONCLUSTERED INDEX IX_PortfolioFileSize_PortfolioDetailId ON [dbo].[PortfolioFileSize] ([PortfolioDetailId])
--CREATE NONCLUSTERED INDEX IX_PortfolioProperty_PropertyId ON [dbo].[PortfolioProperty] ([PropertyId])
--CREATE NONCLUSTERED INDEX IX_PremiumAccessCountDetail_PremiumAccessDownloadLogId ON [dbo].[PremiumAccessCountDetail] ([PremiumAccessDownloadLogId])
--CREATE NONCLUSTERED INDEX IX_PremiumAccessCountDetail_SubscriptionAgreementId ON [dbo].[PremiumAccessCountDetail] ([SubscriptionAgreementId])
--CREATE NONCLUSTERED INDEX IX_PremiumAccessDownloadLog_IndividualId ON [dbo].[PremiumAccessDownloadLog] ([IndividualId])
--CREATE NONCLUSTERED INDEX IX_PremiumAccessDownloadLog_SubscriptionAgreementId ON [dbo].[PremiumAccessDownloadLog] ([SubscriptionAgreementId])
--CREATE NONCLUSTERED INDEX IX_ProfileDefinition_iAccessLevelTypeID ON [dbo].[ProfileDefinition] ([iAccessLevelTypeID])
--CREATE NONCLUSTERED INDEX IX_PropertyValue_PropertyId ON [dbo].[PropertyValue] ([PropertyId])
--CREATE NONCLUSTERED INDEX IX_Quote_ParentQuoteID ON [dbo].[Quote] ([ParentQuoteID])
--CREATE NONCLUSTERED INDEX IX_Quote_QuoteStatusID ON [dbo].[Quote] ([QuoteStatusID])
--CREATE NONCLUSTERED INDEX IX_RestockValue_RestockParentValueId ON [dbo].[RestockValue] ([RestockParentValueId])
--CREATE NONCLUSTERED INDEX IX_RestockValueMap_OrgTypeCategoryOrgTypeRelID ON [dbo].[RestockValueMap] ([OrgTypeCategoryOrgTypeRelID])
--CREATE NONCLUSTERED INDEX IX_RestockValueMap_RestockValueId ON [dbo].[RestockValueMap] ([RestockValueId])
--CREATE NONCLUSTERED INDEX IX_SecuritySystem_CreativeSortOrder ON [dbo].[SecuritySystem] ([CreativeSortOrder])
--CREATE NONCLUSTERED INDEX IX_SecuritySystem_DownloadAuthorization ON [dbo].[SecuritySystem] ([DownloadAuthorization])
--CREATE NONCLUSTERED INDEX IX_SecuritySystem_SearchScopingMethod ON [dbo].[SecuritySystem] ([SearchScopingMethod])
--CREATE NONCLUSTERED INDEX IX_SecuritySystem_SystemTypeId ON [dbo].[SecuritySystem] ([SystemTypeId])
--CREATE NONCLUSTERED INDEX IX_ShippingCost_iShippingItemTypeId ON [dbo].[ShippingCost] ([iShippingItemTypeId])
--CREATE NONCLUSTERED INDEX IX_ShippingCost_iShippingMethodTypeId ON [dbo].[ShippingCost] ([iShippingMethodTypeId])
--CREATE NONCLUSTERED INDEX IX_ShippingCost_vchCurrencyCode ON [dbo].[ShippingCost] ([vchCurrencyCode])
--CREATE NONCLUSTERED INDEX IX_SiteAccessDefaultAuthGroup_AuthGroupID ON [dbo].[SiteAccessDefaultAuthGroup] ([AuthGroupID])
--CREATE NONCLUSTERED INDEX IX_Subscription_BillingFrequency ON [dbo].[Subscription] ([BillingFrequency])
--CREATE NONCLUSTERED INDEX IX_Subscription_CurrencyCode ON [dbo].[Subscription] ([CurrencyCode])
--CREATE NONCLUSTERED INDEX IX_SubscriptionAgreement_BillingFrequencyId ON [dbo].[SubscriptionAgreement] ([BillingFrequencyId])
--CREATE NONCLUSTERED INDEX IX_SubscriptionAgreement_PpiTypeID ON [dbo].[SubscriptionAgreement] ([PpiTypeID])
--CREATE NONCLUSTERED INDEX IX_SubscriptionAgreement_Sku ON [dbo].[SubscriptionAgreement] ([Sku])
--CREATE NONCLUSTERED INDEX IX_SubscriptionBundle_BundleId ON [dbo].[SubscriptionBundle] ([BundleId])
--CREATE NONCLUSTERED INDEX IX_SubscriptionContact_SubscriptionAgreementId ON [dbo].[SubscriptionContact] ([SubscriptionAgreementId])
--CREATE NONCLUSTERED INDEX IX_SubscriptionContactProperty_PropertyId ON [dbo].[SubscriptionContactProperty] ([PropertyId])
--CREATE NONCLUSTERED INDEX IX_SubscriptionDetail_BrandID ON [dbo].[SubscriptionDetail] ([BrandID])
--CREATE NONCLUSTERED INDEX IX_SubscriptionDetail_ContentAge ON [dbo].[SubscriptionDetail] ([ContentAge])
--CREATE NONCLUSTERED INDEX IX_SubscriptionDetail_SubscriptionID ON [dbo].[SubscriptionDetail] ([SubscriptionID])
--CREATE NONCLUSTERED INDEX IX_SubscriptionPortfolio_PortfolioId ON [dbo].[SubscriptionPortfolio] ([PortfolioId])
--CREATE NONCLUSTERED INDEX IX_SubscriptionPortfolioDetail_FileSizeId ON [dbo].[SubscriptionPortfolioDetail] ([FileSizeId])
--CREATE NONCLUSTERED INDEX IX_SubscriptionPortfolioDetail_PortfolioDetailId ON [dbo].[SubscriptionPortfolioDetail] ([PortfolioDetailId])
--CREATE NONCLUSTERED INDEX IX_SubscriptionProperty_PropertyId ON [dbo].[SubscriptionProperty] ([PropertyId])
--CREATE NONCLUSTERED INDEX IX_SubscriptionUsageDetail_UsageId ON [dbo].[SubscriptionUsageDetail] ([UsageId])
--CREATE NONCLUSTERED INDEX IX_TaxSimple_iTaxProductTypeId ON [dbo].[TaxSimple] ([iTaxProductTypeId])
--CREATE NONCLUSTERED INDEX IX_TaxSimple_iTaxSaleTypeId ON [dbo].[TaxSimple] ([iTaxSaleTypeId])
--CREATE NONCLUSTERED INDEX IX_TaxSimple_iTaxTypeId ON [dbo].[TaxSimple] ([iTaxTypeId])
--CREATE NONCLUSTERED INDEX IX_TaxVat_iTaxProductTypeId ON [dbo].[TaxVat] ([iTaxProductTypeId])
--CREATE NONCLUSTERED INDEX IX_TaxVat_iTaxSaleTypeId ON [dbo].[TaxVat] ([iTaxSaleTypeId])
--CREATE NONCLUSTERED INDEX IX_TaxVat_nchCountryCode ON [dbo].[TaxVat] ([nchCountryCode])
--CREATE NONCLUSTERED INDEX IX_WebNotes_IndividualID ON [dbo].[WebNotes] ([IndividualID])
--CREATE NONCLUSTERED INDEX IX_WebSiteUse_iIndividualID ON [dbo].[WebSiteUse] ([iIndividualID])
--CREATE NONCLUSTERED INDEX IX_FlickrImageRequest_UseTypeID ON [Flickr].[FlickrImageRequest] ([UseTypeID])
--CREATE NONCLUSTERED INDEX IX_FlickrImageRequestDetail_FlickrImageRequestID ON [Flickr].[FlickrImageRequestDetail] ([FlickrImageRequestID])
--CREATE NONCLUSTERED INDEX IX_FlickrImageRequestDetail_StatusID ON [Flickr].[FlickrImageRequestDetail] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_FlickrImageRequestTimerDuration_StatusID ON [Flickr].[FlickrImageRequestTimerDuration] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_FlickrImageRequestUserRel_GettyUserID ON [Flickr].[FlickrImageRequestUserRel] ([GettyUserID])
--CREATE NONCLUSTERED INDEX IX_AssetFamily_StatusID ON [OPA].[AssetFamily] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_AssetFamily_AssetOwnership_AssetOwnershipID ON [OPA].[AssetFamily_AssetOwnership] ([AssetOwnershipID])
--CREATE NONCLUSTERED INDEX IX_AssetFamily_AssetOwnership_StatusID ON [OPA].[AssetFamily_AssetOwnership] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_AssetOwnership_StatusID ON [OPA].[AssetOwnership] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_AssetType_StatusID ON [OPA].[AssetType] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_Collection_StatusID ON [OPA].[Collection] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_CollectionDetail_AssetFamilyID ON [OPA].[CollectionDetail] ([AssetFamilyID])
--CREATE NONCLUSTERED INDEX IX_CollectionDetail_AssetOwnershipID ON [OPA].[CollectionDetail] ([AssetOwnershipID])
--CREATE NONCLUSTERED INDEX IX_CollectionDetail_AssetTypeID ON [OPA].[CollectionDetail] ([AssetTypeID])
--CREATE NONCLUSTERED INDEX IX_CollectionDetail_EditorialGroupID ON [OPA].[CollectionDetail] ([EditorialGroupID])
--CREATE NONCLUSTERED INDEX IX_CollectionDetail_LicenseTypeID ON [OPA].[CollectionDetail] ([LicenseTypeID])
--CREATE NONCLUSTERED INDEX IX_CollectionDetail_StatusID ON [OPA].[CollectionDetail] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_Company_RateProfile_RateProfileID ON [OPA].[Company_RateProfile] ([RateProfileID])
--CREATE NONCLUSTERED INDEX IX_Company_RateProfile_StatusID ON [OPA].[Company_RateProfile] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_EditorialGroup_StatusID ON [OPA].[EditorialGroup] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_Feature_StatusID ON [OPA].[Feature] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_LicenseType_StatusID ON [OPA].[LicenseType] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_OriginalSystem_Feature_FeatureID ON [OPA].[OriginalSystem_Feature] ([FeatureID])
--CREATE NONCLUSTERED INDEX IX_OriginalSystem_Feature_StatusID ON [OPA].[OriginalSystem_Feature] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_RateProfile_OriginalSystem_StatusID ON [OPA].[RateProfile_OriginalSystem] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_RateProfileDetail_CollectionDetailID ON [OPA].[RateProfileDetail] ([CollectionDetailID])
--CREATE NONCLUSTERED INDEX IX_RateProfileDetail_SubProfile_StatusID ON [OPA].[RateProfileDetail_SubProfile] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_RateProfileDetail_SubProfile_SubProfileID ON [OPA].[RateProfileDetail_SubProfile] ([SubProfileID])
--CREATE NONCLUSTERED INDEX IX_RateProfileSeatLicense_RateProfileDetailID ON [OPA].[RateProfileSeatLicense] ([RateProfileDetailID])
--CREATE NONCLUSTERED INDEX IX_SubProfile_StatusID ON [OPA].[SubProfile] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_IndividualPublication_PublicationId ON [Publication].[IndividualPublication] ([PublicationId])
--CREATE NONCLUSTERED INDEX IX_Publication_OwningCompanyId ON [Publication].[Publication] ([OwningCompanyId])
--CREATE NONCLUSTERED INDEX IX_Publication_PublicationType_PublicationTypeId ON [Publication].[Publication_PublicationType] ([PublicationTypeId])
--CREATE NONCLUSTERED INDEX IX_PublicationCountry_CountryCode ON [Publication].[PublicationCountry] ([CountryCode])
--CREATE NONCLUSTERED INDEX IX_NaughtyIp_StatusID ON [SecurityToken].[NaughtyIp] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_UserLogins_ResultStatusID ON [SiteActivity].[UserLogins] ([ResultStatusID])
--CREATE NONCLUSTERED INDEX IX_CustomerAuthorization_AuthorizationTypeId ON [Subscription].[CustomerAuthorization] ([AuthorizationTypeId])
--CREATE NONCLUSTERED INDEX IX_ImagePackInstance_ProductId ON [Subscription].[ImagePackInstance] ([ProductId])
--CREATE NONCLUSTERED INDEX IX_ImagePackInstance_StateId ON [Subscription].[ImagePackInstance] ([StateId])
--CREATE NONCLUSTERED INDEX IX_ImagePackInstanceStateChange_ImagePackInstanceId ON [Subscription].[ImagePackInstanceStateChange] ([ImagePackInstanceId])
--CREATE NONCLUSTERED INDEX IX_Subscription_IndividualID ON [Subscription].[Subscription] ([IndividualID])
--CREATE NONCLUSTERED INDEX IX_Subscription_StatusID ON [Subscription].[Subscription] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_Subscription_SubscriptionBillingFrequencyID ON [Subscription].[Subscription] ([SubscriptionBillingFrequencyID])
--CREATE NONCLUSTERED INDEX IX_Subscription_SubscriptionDefinitionID ON [Subscription].[Subscription] ([SubscriptionDefinitionID])
--CREATE NONCLUSTERED INDEX IX_Subscription_SubscriptionTypeID ON [Subscription].[Subscription] ([SubscriptionTypeID])
--CREATE NONCLUSTERED INDEX IX_SubscriptionBillingHistory_SubscriptionBillingErrorID ON [Subscription].[SubscriptionBillingHistory] ([SubscriptionBillingErrorID])
--CREATE NONCLUSTERED INDEX IX_SubscriptionBillingHistory_SubscriptionBillingStatusID ON [Subscription].[SubscriptionBillingHistory] ([SubscriptionBillingStatusID])
--CREATE NONCLUSTERED INDEX IX_SubscriptionBillingHistory_SubscriptionID ON [Subscription].[SubscriptionBillingHistory] ([SubscriptionID])
--CREATE NONCLUSTERED INDEX IX_SubscriptionBillingInfo_SubscriptionBillingPaymentID ON [Subscription].[SubscriptionBillingInfo] ([SubscriptionBillingPaymentID])
--CREATE NONCLUSTERED INDEX IX_SubscriptionBillingInfo_SubscriptionID ON [Subscription].[SubscriptionBillingInfo] ([SubscriptionID])
--CREATE NONCLUSTERED INDEX IX_SubscriptionBillingNext_SubscriptionID ON [Subscription].[SubscriptionBillingNext] ([SubscriptionID])
--CREATE NONCLUSTERED INDEX IX_SubscriptionDefinition_StatusID ON [Subscription].[SubscriptionDefinition] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_SubscriptionDefinition_SubscriptionDefinitionPropertyValue_StatusID ON [Subscription].[SubscriptionDefinition_SubscriptionDefinitionPropertyValue] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_SubscriptionDefinition_SubscriptionDefinitionPropertyValue_SubscriptionDefinitionPropertyValueID ON [Subscription].[SubscriptionDefinition_SubscriptionDefinitionPropertyValue] ([SubscriptionDefinitionPropertyValueID])
--CREATE NONCLUSTERED INDEX IX_SubscriptionDefinitionProperty_StatusID ON [Subscription].[SubscriptionDefinitionProperty] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_SubscriptionDefinitionPropertyValue_StatusID ON [Subscription].[SubscriptionDefinitionPropertyValue] ([StatusID])
--CREATE NONCLUSTERED INDEX IX_SubscriptionDefinitionPropertyValue_SubscriptionDefinitionPropertyID ON [Subscription].[SubscriptionDefinitionPropertyValue] ([SubscriptionDefinitionPropertyID])
--CREATE NONCLUSTERED INDEX IX_SubscriptionHistory_SubscriptionID ON [Subscription].[SubscriptionHistory] ([SubscriptionID])
--CREATE NONCLUSTERED INDEX IX_SubscriptionPropertyValue_SubscriptionDefinitionPropertyValueID ON [Subscription].[SubscriptionPropertyValue] ([SubscriptionDefinitionPropertyValueID])
--CREATE NONCLUSTERED INDEX IX_UserExperienceTests_StatusId ON [TestTarget].[UserExperienceTests] ([StatusId])
















SELECT name,sum(cast(reserved AS float)*8192./1024./1024.) SpaceUsedMB FROM SYSINDEXES where name in
(
'IX_AuthSiteAccess_OriginalSystemID', 
'IX_AuxDelivery_iOriginalSystemID', 
'IX_Cart_iOriginalSystemID',
'IX_CCProcessorAccount_iOriginalSystemId',
'IX_Company_iOriginalSystemID',
'IX_CompanyLegacyXref_iOriginalSystemId',
'IX_CompanyPreference_iOriginalSystemID',
'IX_CountryToOpUnit_iOriginalSystemId',
'IX_Individual_iOriginalSystemID',
'IX_IndividualPreference_iOriginalSystemID',
'IX_IndividualSitePreference_SiteID',
'IX_MediaBin_iOriginalSystemID',
'IX_ProfileIndividualRel_iOriginalSystemID',
'IX_SearchHistory_iOriginalSystemID',
'IX_RateProfile_OriginalSystem_OriginalSystemID', 
'IX_Subscription_CreatedFromSiteID',
'IX_UserExperienceTests_SiteId',
'IX_AgreementFilter_SystemId',
'IX_ScopingBundle_SystemId',
'IX_SecurityComKey_SystemId1',
'IX_SecurityComKey_SystemId2',
'IX_SecuritySecret_SystemId',
'IX_Address_chStateCode',
'IX_Address_iEntityTypeID',
'IX_Address_iStatusID',
'IX_Address_iTypeID',
'IX_Address_nchCountryCode',
'IX_AgentOperationalUnitRel_iOperationalUnitID',
'IX_AgentTypeOperationalUnitRel_iOperationalUnitId',
'IX_AgentTypeOperationalUnitRel_iTypeId',
'IX_AgreementDetail_iBrandID',
'IX_AgreementDetail_iMediaTypeID',
'IX_AgreementDetail_iTypeID',
'IX_AgreementDetailNLMResolution_iAgreementDetailID',
'IX_AgreementFilter_AgreementFilterTypeId',
'IX_AgreementSubDetail_iStatus',
'IX_AuthGroupAuthorization_AuthorizationID',
'IX_AuthGroupCompany_AuthGroupID',
'IX_AuthGroupIndividual_AuthGroupID',
'IX_AuxDelivery_iAuxDeliveryReasonID',
'IX_AuxDelivery_iBrandID',
'IX_AuxDelivery_iStatusID',
'IX_AuxDeliveryReasonType_iMediaTypeID',
'IX_AuxDeliveryReasonType_iStatusID',
'IX_Cart_iIndividualID',
'IX_Cart_nchCountryCode',
'IX_Cart_vchCurrencyCode',
'IX_CartDetail_iBrandID',
'IX_CartDetail_iMediaTypeID',
'IX_CartDetail_iStatusId',
'IX_CartDetail_iTaxTypeId',
'IX_CartTax_iTaxTypeId',
'IX_CCProcessorAccount_iPartnerId',
'IX_CCProcessorAccount_vchCurrencyCode',
'IX_Company_iCompanyTypeID',
'IX_Company_iOrgTypeCategoryOrgTypeRelID',
'IX_Company_iPricePlanTypeID',
'IX_Company_iStatementCyclePrefTypeID',
'IX_Company_iStatusID',
'IX_Company_vchCurrencyCode',
'IX_CompanyContentAccessType_ContentAccessTypeID',
'IX_CompanyIndividualRel_iCompanyID',
'IX_CompanyIndividualRel_iStatusID',
'IX_CompanyNotes_iSubjectId',
'IX_CompanySCIUserRel_iCompensationRoleID',
'IX_CompanySCIUserRel_iStatusID',
'IX_CompanyTypeLocalized_vchLanguageCode',
'IX_CompensationRole_iStatusID',
'IX_CompensationRoleRule_iCompensationRoleID',
'IX_Contact_iCompanyID',
'IX_Contact_iStatusID',
'IX_ContactSubject_iStatusId',
'IX_ContentCategory_ContentBillingId',
'IX_CountryToOpUnit_iOperationalUnitId',
'IX_CreateSessionResult_ResultStatusId',
'IX_CreditCard_iStatusID',
'IX_CreditCard_iTypeID',
'IX_CreditStatus_imp_iEntityTypeID',
'IX_DistributorContractNote_iContractID',
'IX_DistributorContractPercentage_iCollectionID',
'IX_DistributorContractPercentage_iPercentTypeID',
'IX_DistributorContractPercentage_iProductTypeID',
'IX_EasyAccessContentCategoryRef_ContentCategoryId',
'IX_EasyAccessDetailInfo_ContentCategoryId',
'IX_EasyAccessDetailInfo_EasyAccessTypeId',
'IX_EasyAccessDetailInfo_PortfolioCollectionId',
'IX_EasyAccessDetailInfo_PortfolioId',
'IX_EasyAccessHeader_ImageSizeTypeId',
'IX_EditorialOrderSchedule_OrderID',
'IX_EditorialOrderSchedule_SubscriptionID',
'IX_EditorialSubscriptionCategory_iBrandID',
'IX_EditorialSubscriptionCategoryRef_SubscriptionCategoryId',
'IX_Email_iStatusID',
'IX_Email_iTypeID',
'IX_ImagePartnerBrand_iBrandID',
'IX_ImagePartnerBrand_iCompanyID',
'IX_Individual_iCompanyTypeId',
'IX_Individual_iJobDescriptionTypeId',
'IX_Individual_iJobTitleCategoryJobTitleRelID',
'IX_Individual_iOfficeId',
'IX_Individual_iOrgTypeCategoryOrgTypeRelID',
'IX_Individual_iStatusID',
'IX_Individual_iTypeID',
'IX_Individual_vchEmailLanguageCode',
'IX_IndividualHomeDomain_HomeDomainSourceID',
'IX_IndividualHomeDomain_TopLevelDomainID',
'IX_IndividualInterestType_iInterestTypeId',
'IX_IndividualJobRoleRel_JobRoleID',
'IX_IndividualMarketingPreference_MarketingPreferenceCategoryID',
'IX_IndividualNotes_iSubjectId',
'IX_IndividualRestock_RestockParentValueId',
'IX_IndividualRestock_RestockValueId',
'IX_InterestTypeLocalized_vchLanguageCode',
'IX_JobDescriptionTypeLocalized_vchLanguageCode',
'IX_JobTitleCategoryJobTitleRel_JobTitleCategoryID',
'IX_JobTitleCategoryJobTitleRel_JobTitleID',
'IX_JobTitleMap_JobTitleRelID',
'IX_JobTitleMap_JobTypeID',
'IX_JobTitleMap_OrgTypeRelID',
'IX_LicensePreferenceBrand_BrandID',
'IX_MasterDelegateTerritory_iCompanyID',
'IX_MediaBin_iMediaTypeID',
'IX_MediaBinItem_iBrandID',
'IX_MediaRoom_iStatusID',
'IX_MediaRoomAsset_iBrandID',
'IX_MediaRoomAsset_iLicenseStatusID',
'IX_OfficeLocation_iStatusId',
'IX_OrderDetail_iBrandID',
'IX_OrderInvoicePub_OrderID',
'IX_Orders_chAffiliateCode',
'IX_Orders_iAffiliateDetailID',
'IX_Orders_iOperationalUnitId',
'IX_Orders_iPaymentMethodTypeID',
'IX_Orders_iShippingMethodTypeID',
'IX_Orders_iStatusID',
'IX_Orders_iTypeID',
'IX_Orders_vchCurrencyCode',
'IX_Orders_vchLanguageCode',
'IX_OrderTax_iTaxTypeId',
'IX_OrgTypeCategoryOrgTypeRel_OrgTypeCategoryID',
'IX_OrgTypeCategoryOrgTypeRel_OrgTypeID',
'IX_OrgTypeJobTitleCategoryRel_JobTitleCategoryID',
'IX_OrgTypeJobTitleCategoryRel_OrgTypeID',
'IX_OrgTypeMap_CompanyTypeID',
'IX_OrgTypeMap_OrgTypeRelID',
'IX_PartnerBundle_PartnerBundleTypeId',
'IX_Phone_iEntityTypeID',
'IX_Phone_iStatusID',
'IX_Phone_iTechnologyTypeID',
'IX_Phone_iUsageTypeID',
'IX_Portfolio_BusinessAreaId',
'IX_Portfolio_PortfolioTypeId',
'IX_PortfolioDetail_MediaType',
'IX_PortfolioFileSize_PortfolioDetailId',
'IX_PortfolioProperty_PropertyId',
'IX_PremiumAccessCountDetail_PremiumAccessDownloadLogId',
'IX_PremiumAccessCountDetail_SubscriptionAgreementId',
'IX_PremiumAccessDownloadLog_IndividualId',
'IX_PremiumAccessDownloadLog_SubscriptionAgreementId',
'IX_ProfileDefinition_iAccessLevelTypeID',
'IX_PropertyValue_PropertyId',
'IX_Quote_ParentQuoteID',
'IX_Quote_QuoteStatusID',
'IX_RestockValue_RestockParentValueId',
'IX_RestockValueMap_OrgTypeCategoryOrgTypeRelID',
'IX_RestockValueMap_RestockValueId',
'IX_SecuritySystem_CreativeSortOrder',
'IX_SecuritySystem_DownloadAuthorization',
'IX_SecuritySystem_SearchScopingMethod',
'IX_SecuritySystem_SystemTypeId',
'IX_ShippingCost_iShippingItemTypeId',
'IX_ShippingCost_iShippingMethodTypeId',
'IX_ShippingCost_vchCurrencyCode',
'IX_SiteAccessDefaultAuthGroup_AuthGroupID',
'IX_Subscription_BillingFrequency',
'IX_Subscription_CurrencyCode',
'IX_SubscriptionAgreement_BillingFrequencyId',
'IX_SubscriptionAgreement_PpiTypeID',
'IX_SubscriptionAgreement_Sku',
'IX_SubscriptionBundle_BundleId',
'IX_SubscriptionContact_SubscriptionAgreementId',
'IX_SubscriptionContactProperty_PropertyId',
'IX_SubscriptionDetail_BrandID',
'IX_SubscriptionDetail_ContentAge',
'IX_SubscriptionDetail_SubscriptionID',
'IX_SubscriptionPortfolio_PortfolioId',
'IX_SubscriptionPortfolioDetail_FileSizeId',
'IX_SubscriptionPortfolioDetail_PortfolioDetailId',
'IX_SubscriptionProperty_PropertyId',
'IX_SubscriptionUsageDetail_UsageId',
'IX_TaxSimple_iTaxProductTypeId',
'IX_TaxSimple_iTaxSaleTypeId',
'IX_TaxSimple_iTaxTypeId',
'IX_TaxVat_iTaxProductTypeId',
'IX_TaxVat_iTaxSaleTypeId',
'IX_TaxVat_nchCountryCode',
'IX_WebNotes_IndividualID',
'IX_WebSiteUse_iIndividualID',
'IX_FlickrImageRequest_UseTypeID',
'IX_FlickrImageRequestDetail_FlickrImageRequestID',
'IX_FlickrImageRequestDetail_StatusID',
'IX_FlickrImageRequestTimerDuration_StatusID',
'IX_FlickrImageRequestUserRel_GettyUserID',
'IX_AssetFamily_StatusID',
'IX_AssetFamily_AssetOwnership_AssetOwnershipID',
'IX_AssetFamily_AssetOwnership_StatusID',
'IX_AssetOwnership_StatusID',
'IX_AssetType_StatusID',
'IX_Collection_StatusID',
'IX_CollectionDetail_AssetFamilyID',
'IX_CollectionDetail_AssetOwnershipID',
'IX_CollectionDetail_AssetTypeID',
'IX_CollectionDetail_EditorialGroupID',
'IX_CollectionDetail_LicenseTypeID',
'IX_CollectionDetail_StatusID',
'IX_Company_RateProfile_RateProfileID',
'IX_Company_RateProfile_StatusID',
'IX_EditorialGroup_StatusID',
'IX_Feature_StatusID',
'IX_LicenseType_StatusID',
'IX_OriginalSystem_Feature_FeatureID',
'IX_OriginalSystem_Feature_StatusID',
'IX_RateProfile_OriginalSystem_StatusID',
'IX_RateProfileDetail_CollectionDetailID',
'IX_RateProfileDetail_SubProfile_StatusID',
'IX_RateProfileDetail_SubProfile_SubProfileID',
'IX_RateProfileSeatLicense_RateProfileDetailID',
'IX_SubProfile_StatusID',
'IX_IndividualPublication_PublicationId',
'IX_Publication_OwningCompanyId',
'IX_Publication_PublicationType_PublicationTypeId',
'IX_PublicationCountry_CountryCode',
'IX_NaughtyIp_StatusID',
'IX_UserLogins_ResultStatusID',
'IX_CustomerAuthorization_AuthorizationTypeId',
'IX_ImagePackInstance_ProductId',
'IX_ImagePackInstance_StateId',
'IX_ImagePackInstanceStateChange_ImagePackInstanceId',
'IX_Subscription_IndividualID',
'IX_Subscription_StatusID',
'IX_Subscription_SubscriptionBillingFrequencyID',
'IX_Subscription_SubscriptionDefinitionID',
'IX_Subscription_SubscriptionTypeID',
'IX_SubscriptionBillingHistory_SubscriptionBillingErrorID',
'IX_SubscriptionBillingHistory_SubscriptionBillingStatusID',
'IX_SubscriptionBillingHistory_SubscriptionID',
'IX_SubscriptionBillingInfo_SubscriptionBillingPaymentID',
'IX_SubscriptionBillingInfo_SubscriptionID',
'IX_SubscriptionBillingNext_SubscriptionID',
'IX_SubscriptionDefinition_StatusID',
'IX_SubscriptionDefinition_SubscriptionDefinitionPropertyValue_StatusID',
'IX_SubscriptionDefinition_SubscriptionDefinitionPropertyValue_SubscriptionDefinitionPropertyValueID',
'IX_SubscriptionDefinitionProperty_StatusID',
'IX_SubscriptionDefinitionPropertyValue_StatusID',
'IX_SubscriptionDefinitionPropertyValue_SubscriptionDefinitionPropertyID',
'IX_SubscriptionHistory_SubscriptionID',
'IX_SubscriptionPropertyValue_SubscriptionDefinitionPropertyValueID',
'IX_UserExperienceTests_StatusId'



)s
GROUP BY Name
WITH CUBE
ORDER BY 2





