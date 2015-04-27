	DECLARE
		@Error_CompanyID_InvalidParam			nvarchar(50), 
		@Error_Company_NotFound				nvarchar(50), 
		@Error_Individual_NotFound			nvarchar(50), 
		@Error_Address_NotFound				nvarchar(50),
		@Error_Phone_NotFound				nvarchar(50),
		@Error_Contact_NotFound				nvarchar(50),
		@Error_Invalid_TypeforColumn			nvarchar(50), 
		@Error_Invalid_StatusForTable 			nvarchar(50),
		@Error_Unspecified				nvarchar(50),
		@CurrentError					nvarchar(50),
		@CurrentErrorLoc				nvarchar(50),
		@RowCount					int,
		@returnStatus					int,
		@iCompanyID					int,
		@oiErrorID					int,
		@ovchErrorMessage				nvarchar(256)

DECLARE @SiteList varchar(200) 
		
	SELECT
		@Error_CompanyID_InvalidParam			= 'CompanyID_InvalidParam',
		@Error_Company_NotFound				= 'Company_NotFound',
		@Error_Individual_NotFound			= 'Individual_NotFound',
		@Error_Address_NotFound				= 'Address_NotFound',
		@Error_Phone_NotFound				= 'Phone_NotFound',
		@Error_Contact_NotFound				= 'Contact_NotFound',
		@Error_Invalid_TypeforColumn			= 'Invalid_TypeforColumn',
		@Error_Invalid_StatusForTable 			= 'Invalid_StatusForTable',
		@Error_Unspecified				= 'Unspecified',
		@CurrentError					= @Error_Unspecified,
		@RowCount					= 0,
		@oiErrorID					= 0

	-- Proc-specific variables
	DECLARE
		@iUsageTypeID_BillTo_LKUP			int,
		@iUsageTypeID_ShipTo_LKUP			int,
		@iUsageTypeID_MailTo_LKUP			int,
		@iUsageTypeID_Main_LKUP				int,
		@iUsageTypeID_Primary_LKUP			int,
		@iEntityTypeID_LKUP				int,
		@iTechnologyTypeID_Phone_LKUP    		int,
		@iTechnologyTypeID_Fax_LKUP			int,
		@iActiveStatusID_LKUP    			int,
		@iPartialCoStatusID_LKUP			int,
		@iMergeStatusID_LKUP				int,
		@vchStatusDescription				nvarchar(30),
		@vchTypeDescription				nvarchar(30),
		@vchOriginalSystemName				nvarchar(30),
		@vchStatementCyclePrefTypeDesc			nvarchar(30),
		@vchPricePlanTypeDescription			nvarchar(30),
		@vchOperationalUnitCode				varchar(50),

		--Bill-To Address/Phone/Fax
			@iBillToAddressID				int,
			@iBillToPhoneID					int,
			@iBillToFaxID					int,
		--Ship-To Address/Phone/Fax
			@iShipToAddressID				int,
			@iShipToPhoneID					int,
			@iShipToFaxID					int,
		--Mail-To Address/Phone/Fax
			@iMailToAddressID				int,
			@iMailToPhoneID					int,
			@iMailToFaxID					int,
		--Main Phone/Fax
			@iMainPhoneID					int,
			@iMainFaxID					int,
		--Bill-To Contact Info/Phone/Fax
			@iBillToContactID				int,
		--Ship-To Contact Info/Phone/Fax
			@iShipToContactID				int,
		--Mail-To Contact Info/Phone/Fax
			@iMailToContactID				int,
		--Primary Contact Info/Phone/Fax
			@iPrimaryContactID				int,
			@iPrimaryPhoneID				int,
			@iPrimaryFaxID					int,	
		-- Other Stuff
			@iModifiedBy					int,
		@iSiteAccessMask        			int				-- NOT NULL

	SELECT
		@vchOperationalUnitCode					= NULL,
		@iUsageTypeID_BillTo_LKUP				= 0,
		@iUsageTypeID_ShipTo_LKUP				= 0,
		@iUsageTypeID_MailTo_LKUP				= 0,
		@iUsageTypeID_Primary_LKUP				= 0,
		@iEntityTypeID_LKUP					= 0,
		--Bill-To Address/Phone/Fax
			@iBillToAddressID				= 0,
			@iBillToPhoneID					= 0,
			@iBillToFaxID					= 0,
		--Ship-To Address/Phone/Fax
			@iShipToAddressID				= 0,
			@iShipToPhoneID					= 0,
			@iShipToFaxID					= 0,
		--Mail-To Address/Phone/Fax
			@iMailToAddressID				= 0,
			@iMailToPhoneID					= 0,
			@iMailToFaxID					= 0,
		--Main Phone/Fax
			@iMainPhoneID					= 0,
			@iMainFaxID					= 0,
		--Primary Contact Info/Phone/Fax
			@iPrimaryContactID				= 0,
			@iPrimaryPhoneID				= 0,
			@iPrimaryFaxID					= 0,
		--Bill-To Contact Info/Phone/Fax
			@iBillToContactID				= 0,
		--Ship-To Contact Info/Phone/Fax
			@iShipToContactID				= 0,
		--Mail-To Contact Info/Phone/Fax
			@iMailToContactID				= 0,
		-- Other Stuff
		@iModifiedBy						= 0

 
 	SELECT
		-- fields in vitria design doc
                ResultSetName                                   = 'Company',
		iCompanyID					= c.iCompanyID,
                dtModified                                      = c.dtModified,
		vchTypeDescription				= @vchTypeDescription,
		vchOriginalSystemName				= @vchOriginalSystemName,
		vchStatusDescription				= @vchStatusDescription,
		vchCompanyName					= c.vchCompanyName,
		vchShortCompanyName				= c.vchShortCompanyName,
		vchCompanyCN					= c.vchCompanyCN,
		vchCompanyIDXref				= c.vchCompanyIDXref,
		tiCreditHoldFlag				= c.tiCreditHoldFlag,
		vchCreditHoldReason				= c.vchCreditHoldReason,
		mCreditBalance					= c.mCreditBalance,
		mCreditLimit					= c.mCreditLimit,
		siCreditLimitType				= c.siCreditLimitType,
		siCreditLimitPeriod				= c.siCreditLimitPeriod,
		mCreditLimitPeriodAmt    		= c.mCreditLimitPeriodAmt,
		vchComment						= c.vchComment,
		tiTaxExemptFlag					= c.tiTaxExemptFlag,
		vchTaxRegNumber					= c.vchTaxRegNumber,
        vchVatRegNumber                 = c.vchVatRegNumber,
        vchTaxRegNumberCan              = c.vchTaxRegNumberCan,
        vchTaxRegNumberCanProv          = c.vchTaxRegNumberCanProv,
      	vchBusinessType					= c.vchBusinessType,
		vchTermsCode					= c.vchTermsCode,
		vchStatementCycle				= @vchStatementCyclePrefTypeDesc,
		vchPricePlanTypeDescription			= @vchPricePlanTypeDescription,
		vchCurrencyCode					= c.vchCurrencyCode,
		tiAgentFlag					= ISNULL(c.tiAgentFlag,0),
		tiVATOptOutFlag					= ISNULL(c.tiVATOptOutFlag,0),
		--additional fields from previous version
		--Bill-To Address/Phone/Fax
		iBillToAddressID				= @iBillToAddressID,
		iBillToPhoneID					= @iBillToPhoneID,
		iBillToFaxID					= @iBillToFaxID,
		--Ship-To Address/Phone/Fax
		iShipToAddressID				= @iShipToAddressID,
		iShipToPhoneID					= @iShipToPhoneID,
		iShipToFaxID					= @iShipToFaxID,
		--Mail-To Address/Phone/Fax
		iMailToAddressID				= @iMailToAddressID,
		iMailToPhoneID					= @iMailToPhoneID,
		iMailToFaxID					= @iMailToFaxID,
		--Main Phone/Fax
		iMainPhoneID					= @iMainPhoneID,
		iMainFaxID					= @iMainFaxID,
		--Bill-To Contact Info/Phone/Fax
		iBillToContactID				= @iBillToContactID,
		--Ship-To Contact Info/Phone/Fax
		iShipToContactID				= @iShipToContactID,
		--Mail-To Contact Info/Phone/Fax
		iMailToContactID				= @iMailToContactID,
		--Primary Contact Info/Phone/Fax
		iPrimaryContactID				= @iPrimaryContactID,
		iPrimaryPhoneID					= @iPrimaryPhoneID,
		iPrimaryFaxID					= @iPrimaryFaxID,
             -- tiGINSEnabledFlag                               = c.tiGINSEnabledFlag,
             -- tiNBAEnabledFlag                                = c.tiNBAEnabledFlag,
             -- iSiteAccessMask = c.iSiteAccessMask,
        bHasNASCARAccess		  = CASE WHEN CHARINDEX('NASCAR',@SiteList)  > 0 THEN 1 ELSE 0 END,
        bHasMLBAccess			  = CASE WHEN CHARINDEX('MLB',@SiteList)  > 0 THEN 1 ELSE 0 END,
        bHasNFLAccess			  = CASE WHEN CHARINDEX('NFL',@SiteList)  > 0 THEN 1 ELSE 0 END,
        bHasNBAAccess			  = CASE WHEN CHARINDEX('NBA',@SiteList)  > 0 THEN 1 ELSE 0 END,
        bHasPGAAccess			  = CASE WHEN CHARINDEX('PGA',@SiteList)  > 0 THEN 1 ELSE 0 END,
        bHasShellAccess			  = CASE WHEN CHARINDEX('Shell',@SiteList)  > 0 THEN 1 ELSE 0 END,

                iOperationalUnitId			        = AOU.iOperationalUnitId,
		vchOperationalUnitCode				= @vchOperationalUnitCode,
		tiLiveFeed					= c.tiLiveFeed,
		tiIndividualInvoiceFlag		                = c.tiIndividualInvoiceFlag,
		iCompanyTypeID				    = c.iOrgTypeCategoryOrgTypeRelID, -- Vitria wants to repurpose column for new relationship id
		iCompanyClassID					= c.iOrgTypeCategoryOrgTypeRelID, -- Vitria wants this value twice w/two different names
		nvchCompanyClassDescription		= ot.OrgTypeName, --Vitria wants to repurpose column for new value (OrgType name)
		nvchCompanyOrgTypCategoryDescription		= otc.OrgTypeCategoryName, 
		vchCompanyName1 			        = cc.CompanyName1,
		vchCompanyNameLanguageScript1       = cu1.CultureValue,
		vchCompanyName2				        = cc.CompanyName2,
		vchCompanyNameLanguageScript2       = cu2.CultureValue,
 	    vchCompanyShortName1 		                = cc.CompanyShortName1,
		vchCompanyShortNameLanguageScript1              = cu3.CultureValue,
    	vchCompanyShortName2 		                = cc.CompanyShortName2,
		vchCompanyShortNameLanguageScript2              = cu4.CultureValue,
		ParentCompanyID,
        dtEZAAccess                                     = EAH.EndDate,
	    dtFirstPurchaseDate                             = D2.dtFirstPurchaseDate,
	    dtLastPurchaseDate                              = D2.dtLastPurchaseDate,
        dtSubscriptions                                 = D1.dtSubsEndDate,
		dtPremiumaccess                                 = D1.dtPAEndDate,
        vchCompanyShortName                             = C.vchShortCompanyName,
        dtOnlinePriceAgmt                               = A1.dtEndDate,
        tiCountryReadOnlyFlag                           = CROF.tiCountryReadOnlyFlag,
		BillToEmailAddress,
		PORequiredFlag									= c.tiPORequiredFlag

	FROM
			Company c
        LEFT	JOIN 	AgentOperationalUnitRel AOU 
		ON 		c.iCompanyId = AOU.iCompanyId
	LEFT	JOIN	Company_Culture cc
		ON		cc.CompanyID = c.iCompanyID
	LEFT	JOIN OrgTypeCategoryOrgTypeRel otcotr
		ON c.iOrgTypeCategoryOrgTypeRelID = otcotr.OrgTypeCategoryOrgTypeRelID
	LEFT	JOIN OrgType ot
		ON ot.OrgTypeID = otcotr.OrgTypeID
	LEFT	JOIN OrgTypeCategory otc
		ON otc.OrgTypeCategoryID = otcotr.OrgTypeCategoryID
	LEFT	JOIN	Culture cu1
		ON		cu1.CultureID = cc.CompanyNameLanguageScript1
	LEFT	JOIN	Culture cu2
		ON		cu2.CultureID = cc.CompanyNameLanguageScript2
	LEFT	JOIN	Culture cu3
		ON		cu3.CultureID = cc.CompanyShortNameLanguageScript1
	LEFT	JOIN	Culture cu4
		ON	cu4.CultureID = cc.CompanyShortNameLanguageScript2
        LEFT JOIN EasyAccessHeader EAH
	        ON (C.iCompanyID=EAH.CompanyID)
		LEFT JOIN (SELECT C2.iCompanyID,
					max(SD.EndDate) as dtSubsEnddate,
					max(PA.EndDate) as dtPAEnddate
			   FROM Company C2
					LEFT JOIN Subscription S ON (	C2.iCompanyID = s.CompanyID)
					LEFT JOIN SubscriptionDetail SD ON (S.SubscriptionID = SD.SubScriptionID AND SD.ActiveFlag=1)
					LEFT JOIN SubscriptionAgreement pa on (c2.iCompanyID = pa.EntityID AND pa.EntityTypeID = 201 AND pa.ActiveFlag = 1)
			   WHERE c2.iCompanyID = iCompanyID
			   GROUP BY C2.iCompanyID) AS D1
		ON (C.iCompanyID=D1.iCompanyID)
        LEFT JOIN  (SELECT iCompanyID,MIN(dtOrderDate) 'dtFirstPurchaseDate',MAX(dtOrderDate) 'dtLastPurchaseDate'
                    FROM Orders
                    GROUP BY iCompanyID
                    ) AS D2
		ON (D2.iCompanyID=C.iCompanyID)
        LEFT JOIN  (SELECT iCompanyID, MAX(dtEndDate) 'dtEndDate'
                    FROM Agreement
                    WHERE iCompanyID=@iCompanyID
                    GROUP BY iCompanyID) AS A1
                ON (C.iCompanyID=A1.iCompanyID)

        LEFT JOIN (SELECT @iCompanyID 'iCompanyID',COALESCE(MAX(I.tiCountryReadOnlyFlag),CAST(0 AS TINYINT))  'tiCountryReadOnlyFlag'
                   FROM Company C
                   INNER JOIN companyIndividualrel CIR
                    ON  (C.iCompanyID=CIR.iCompanyID)
                   INNER JOIN Individual I
                    ON (CIR.iIndividualID=I.iIndividualID)
                   WHERE C.iCompanyID=@iCompanyID) AS CROF
                ON (C.iCompanyID=CROF.iCompanyID)
	WHERE	c.iCompanyID = @iCompanyID 
	        AND ((c.iStatusID = @iPartialCoStatusID_LKUP) 
		OR (c.iStatusID = @iActiveStatusID_LKUP)
		OR (c.iStatusID = @iMergeStatusID_LKUP))

GO 
         
CREATE INDEX SubscriptionDetail__SubscriptionID_Billable_ActiveFlag 
ON [WCDS].[dbo].[SubscriptionDetail] ([SubscriptionID], [Billable], [ActiveFlag]) INCLUDE ([StartDate], [EndDate])      
GO 

	DECLARE
		@Error_CompanyID_InvalidParam			nvarchar(50), 
		@Error_Company_NotFound				nvarchar(50), 
		@Error_Individual_NotFound			nvarchar(50), 
		@Error_Address_NotFound				nvarchar(50),
		@Error_Phone_NotFound				nvarchar(50),
		@Error_Contact_NotFound				nvarchar(50),
		@Error_Invalid_TypeforColumn			nvarchar(50), 
		@Error_Invalid_StatusForTable 			nvarchar(50),
		@Error_Unspecified				nvarchar(50),
		@CurrentError					nvarchar(50),
		@CurrentErrorLoc				nvarchar(50),
		@RowCount					int,
		@returnStatus					int,
		@iCompanyID					int,
		@oiErrorID					int,
		@ovchErrorMessage				nvarchar(256)

DECLARE @SiteList varchar(200) 
		
	SELECT
		@Error_CompanyID_InvalidParam			= 'CompanyID_InvalidParam',
		@Error_Company_NotFound				= 'Company_NotFound',
		@Error_Individual_NotFound			= 'Individual_NotFound',
		@Error_Address_NotFound				= 'Address_NotFound',
		@Error_Phone_NotFound				= 'Phone_NotFound',
		@Error_Contact_NotFound				= 'Contact_NotFound',
		@Error_Invalid_TypeforColumn			= 'Invalid_TypeforColumn',
		@Error_Invalid_StatusForTable 			= 'Invalid_StatusForTable',
		@Error_Unspecified				= 'Unspecified',
		@CurrentError					= @Error_Unspecified,
		@RowCount					= 0,
		@oiErrorID					= 0

	-- Proc-specific variables
	DECLARE
		@iUsageTypeID_BillTo_LKUP			int,
		@iUsageTypeID_ShipTo_LKUP			int,
		@iUsageTypeID_MailTo_LKUP			int,
		@iUsageTypeID_Main_LKUP				int,
		@iUsageTypeID_Primary_LKUP			int,
		@iEntityTypeID_LKUP				int,
		@iTechnologyTypeID_Phone_LKUP    		int,
		@iTechnologyTypeID_Fax_LKUP			int,
		@iActiveStatusID_LKUP    			int,
		@iPartialCoStatusID_LKUP			int,
		@iMergeStatusID_LKUP				int,
		@vchStatusDescription				nvarchar(30),
		@vchTypeDescription				nvarchar(30),
		@vchOriginalSystemName				nvarchar(30),
		@vchStatementCyclePrefTypeDesc			nvarchar(30),
		@vchPricePlanTypeDescription			nvarchar(30),
		@vchOperationalUnitCode				varchar(50),

		--Bill-To Address/Phone/Fax
			@iBillToAddressID				int,
			@iBillToPhoneID					int,
			@iBillToFaxID					int,
		--Ship-To Address/Phone/Fax
			@iShipToAddressID				int,
			@iShipToPhoneID					int,
			@iShipToFaxID					int,
		--Mail-To Address/Phone/Fax
			@iMailToAddressID				int,
			@iMailToPhoneID					int,
			@iMailToFaxID					int,
		--Main Phone/Fax
			@iMainPhoneID					int,
			@iMainFaxID					int,
		--Bill-To Contact Info/Phone/Fax
			@iBillToContactID				int,
		--Ship-To Contact Info/Phone/Fax
			@iShipToContactID				int,
		--Mail-To Contact Info/Phone/Fax
			@iMailToContactID				int,
		--Primary Contact Info/Phone/Fax
			@iPrimaryContactID				int,
			@iPrimaryPhoneID				int,
			@iPrimaryFaxID					int,	
		-- Other Stuff
			@iModifiedBy					int,
		@iSiteAccessMask        			int				-- NOT NULL

	SELECT
		@vchOperationalUnitCode					= NULL,
		@iUsageTypeID_BillTo_LKUP				= 0,
		@iUsageTypeID_ShipTo_LKUP				= 0,
		@iUsageTypeID_MailTo_LKUP				= 0,
		@iUsageTypeID_Primary_LKUP				= 0,
		@iEntityTypeID_LKUP					= 0,
		--Bill-To Address/Phone/Fax
			@iBillToAddressID				= 0,
			@iBillToPhoneID					= 0,
			@iBillToFaxID					= 0,
		--Ship-To Address/Phone/Fax
			@iShipToAddressID				= 0,
			@iShipToPhoneID					= 0,
			@iShipToFaxID					= 0,
		--Mail-To Address/Phone/Fax
			@iMailToAddressID				= 0,
			@iMailToPhoneID					= 0,
			@iMailToFaxID					= 0,
		--Main Phone/Fax
			@iMainPhoneID					= 0,
			@iMainFaxID					= 0,
		--Primary Contact Info/Phone/Fax
			@iPrimaryContactID				= 0,
			@iPrimaryPhoneID				= 0,
			@iPrimaryFaxID					= 0,
		--Bill-To Contact Info/Phone/Fax
			@iBillToContactID				= 0,
		--Ship-To Contact Info/Phone/Fax
			@iShipToContactID				= 0,
		--Mail-To Contact Info/Phone/Fax
			@iMailToContactID				= 0,
		-- Other Stuff
		@iModifiedBy						= 0

 
 	SELECT
		-- fields in vitria design doc
                ResultSetName                                   = 'Company',
		iCompanyID					= c.iCompanyID,
                dtModified                                      = c.dtModified,
		vchTypeDescription				= @vchTypeDescription,
		vchOriginalSystemName				= @vchOriginalSystemName,
		vchStatusDescription				= @vchStatusDescription,
		vchCompanyName					= c.vchCompanyName,
		vchShortCompanyName				= c.vchShortCompanyName,
		vchCompanyCN					= c.vchCompanyCN,
		vchCompanyIDXref				= c.vchCompanyIDXref,
		tiCreditHoldFlag				= c.tiCreditHoldFlag,
		vchCreditHoldReason				= c.vchCreditHoldReason,
		mCreditBalance					= c.mCreditBalance,
		mCreditLimit					= c.mCreditLimit,
		siCreditLimitType				= c.siCreditLimitType,
		siCreditLimitPeriod				= c.siCreditLimitPeriod,
		mCreditLimitPeriodAmt    		= c.mCreditLimitPeriodAmt,
		vchComment						= c.vchComment,
		tiTaxExemptFlag					= c.tiTaxExemptFlag,
		vchTaxRegNumber					= c.vchTaxRegNumber,
        vchVatRegNumber                 = c.vchVatRegNumber,
        vchTaxRegNumberCan              = c.vchTaxRegNumberCan,
        vchTaxRegNumberCanProv          = c.vchTaxRegNumberCanProv,
      	vchBusinessType					= c.vchBusinessType,
		vchTermsCode					= c.vchTermsCode,
		vchStatementCycle				= @vchStatementCyclePrefTypeDesc,
		vchPricePlanTypeDescription			= @vchPricePlanTypeDescription,
		vchCurrencyCode					= c.vchCurrencyCode,
		tiAgentFlag					= ISNULL(c.tiAgentFlag,0),
		tiVATOptOutFlag					= ISNULL(c.tiVATOptOutFlag,0),
		--additional fields from previous version
		--Bill-To Address/Phone/Fax
		iBillToAddressID				= @iBillToAddressID,
		iBillToPhoneID					= @iBillToPhoneID,
		iBillToFaxID					= @iBillToFaxID,
		--Ship-To Address/Phone/Fax
		iShipToAddressID				= @iShipToAddressID,
		iShipToPhoneID					= @iShipToPhoneID,
		iShipToFaxID					= @iShipToFaxID,
		--Mail-To Address/Phone/Fax
		iMailToAddressID				= @iMailToAddressID,
		iMailToPhoneID					= @iMailToPhoneID,
		iMailToFaxID					= @iMailToFaxID,
		--Main Phone/Fax
		iMainPhoneID					= @iMainPhoneID,
		iMainFaxID					= @iMainFaxID,
		--Bill-To Contact Info/Phone/Fax
		iBillToContactID				= @iBillToContactID,
		--Ship-To Contact Info/Phone/Fax
		iShipToContactID				= @iShipToContactID,
		--Mail-To Contact Info/Phone/Fax
		iMailToContactID				= @iMailToContactID,
		--Primary Contact Info/Phone/Fax
		iPrimaryContactID				= @iPrimaryContactID,
		iPrimaryPhoneID					= @iPrimaryPhoneID,
		iPrimaryFaxID					= @iPrimaryFaxID,
             -- tiGINSEnabledFlag                               = c.tiGINSEnabledFlag,
             -- tiNBAEnabledFlag                                = c.tiNBAEnabledFlag,
             -- iSiteAccessMask = c.iSiteAccessMask,
        bHasNASCARAccess		  = CASE WHEN CHARINDEX('NASCAR',@SiteList)  > 0 THEN 1 ELSE 0 END,
        bHasMLBAccess			  = CASE WHEN CHARINDEX('MLB',@SiteList)  > 0 THEN 1 ELSE 0 END,
        bHasNFLAccess			  = CASE WHEN CHARINDEX('NFL',@SiteList)  > 0 THEN 1 ELSE 0 END,
        bHasNBAAccess			  = CASE WHEN CHARINDEX('NBA',@SiteList)  > 0 THEN 1 ELSE 0 END,
        bHasPGAAccess			  = CASE WHEN CHARINDEX('PGA',@SiteList)  > 0 THEN 1 ELSE 0 END,
        bHasShellAccess			  = CASE WHEN CHARINDEX('Shell',@SiteList)  > 0 THEN 1 ELSE 0 END,

                iOperationalUnitId			        = AOU.iOperationalUnitId,
		vchOperationalUnitCode				= @vchOperationalUnitCode,
		tiLiveFeed					= c.tiLiveFeed,
		tiIndividualInvoiceFlag		                = c.tiIndividualInvoiceFlag,
		iCompanyTypeID				    = c.iOrgTypeCategoryOrgTypeRelID, -- Vitria wants to repurpose column for new relationship id
		iCompanyClassID					= c.iOrgTypeCategoryOrgTypeRelID, -- Vitria wants this value twice w/two different names
		nvchCompanyClassDescription		= ot.OrgTypeName, --Vitria wants to repurpose column for new value (OrgType name)
		nvchCompanyOrgTypCategoryDescription		= otc.OrgTypeCategoryName, 
		vchCompanyName1 			        = cc.CompanyName1,
		vchCompanyNameLanguageScript1       = cu1.CultureValue,
		vchCompanyName2				        = cc.CompanyName2,
		vchCompanyNameLanguageScript2       = cu2.CultureValue,
 	    vchCompanyShortName1 		                = cc.CompanyShortName1,
		vchCompanyShortNameLanguageScript1              = cu3.CultureValue,
    	vchCompanyShortName2 		                = cc.CompanyShortName2,
		vchCompanyShortNameLanguageScript2              = cu4.CultureValue,
		ParentCompanyID,
        dtEZAAccess                                     = EAH.EndDate,
	    dtFirstPurchaseDate                             = D2.dtFirstPurchaseDate,
	    dtLastPurchaseDate                              = D2.dtLastPurchaseDate,
        dtSubscriptions                                 = D1.dtSubsEndDate,
		dtPremiumaccess                                 = D1.dtPAEndDate,
        vchCompanyShortName                             = C.vchShortCompanyName,
        dtOnlinePriceAgmt                               = A1.dtEndDate,
        tiCountryReadOnlyFlag                           = CROF.tiCountryReadOnlyFlag,
		BillToEmailAddress,
		PORequiredFlag									= c.tiPORequiredFlag

	FROM
			Company c
        LEFT	JOIN 	AgentOperationalUnitRel AOU 
		ON 		c.iCompanyId = AOU.iCompanyId
	LEFT	JOIN	Company_Culture cc
		ON		cc.CompanyID = c.iCompanyID
	LEFT	JOIN OrgTypeCategoryOrgTypeRel otcotr
		ON c.iOrgTypeCategoryOrgTypeRelID = otcotr.OrgTypeCategoryOrgTypeRelID
	LEFT	JOIN OrgType ot
		ON ot.OrgTypeID = otcotr.OrgTypeID
	LEFT	JOIN OrgTypeCategory otc
		ON otc.OrgTypeCategoryID = otcotr.OrgTypeCategoryID
	LEFT	JOIN	Culture cu1
		ON		cu1.CultureID = cc.CompanyNameLanguageScript1
	LEFT	JOIN	Culture cu2
		ON		cu2.CultureID = cc.CompanyNameLanguageScript2
	LEFT	JOIN	Culture cu3
		ON		cu3.CultureID = cc.CompanyShortNameLanguageScript1
	LEFT	JOIN	Culture cu4
		ON	cu4.CultureID = cc.CompanyShortNameLanguageScript2
        LEFT JOIN EasyAccessHeader EAH
	        ON (C.iCompanyID=EAH.CompanyID)
		LEFT JOIN (SELECT C2.iCompanyID,
					max(SD.EndDate) as dtSubsEnddate,
					max(PA.EndDate) as dtPAEnddate
			   FROM Company C2
					LEFT JOIN Subscription S ON (	C2.iCompanyID = s.CompanyID)
					LEFT JOIN SubscriptionDetail SD ON (S.SubscriptionID = SD.SubScriptionID AND SD.ActiveFlag=1)
					LEFT JOIN SubscriptionAgreement pa on (c2.iCompanyID = pa.EntityID AND pa.EntityTypeID = 201 AND pa.ActiveFlag = 1)
			   WHERE c2.iCompanyID = iCompanyID
			   GROUP BY C2.iCompanyID) AS D1
		ON (C.iCompanyID=D1.iCompanyID)
        LEFT JOIN  (SELECT iCompanyID,MIN(dtOrderDate) 'dtFirstPurchaseDate',MAX(dtOrderDate) 'dtLastPurchaseDate'
                    FROM Orders
                    GROUP BY iCompanyID
                    ) AS D2
		ON (D2.iCompanyID=C.iCompanyID)
        LEFT JOIN  (SELECT iCompanyID, MAX(dtEndDate) 'dtEndDate'
                    FROM Agreement
                    WHERE iCompanyID=@iCompanyID
                    GROUP BY iCompanyID) AS A1
                ON (C.iCompanyID=A1.iCompanyID)

        LEFT JOIN (SELECT @iCompanyID 'iCompanyID',COALESCE(MAX(I.tiCountryReadOnlyFlag),CAST(0 AS TINYINT))  'tiCountryReadOnlyFlag'
                   FROM Company C
                   INNER JOIN companyIndividualrel CIR
                    ON  (C.iCompanyID=CIR.iCompanyID)
                   INNER JOIN Individual I
                    ON (CIR.iIndividualID=I.iIndividualID)
                   WHERE C.iCompanyID=@iCompanyID) AS CROF
                ON (C.iCompanyID=CROF.iCompanyID)
	WHERE	c.iCompanyID = @iCompanyID 
	        AND ((c.iStatusID = @iPartialCoStatusID_LKUP) 
		OR (c.iStatusID = @iActiveStatusID_LKUP)
		OR (c.iStatusID = @iMergeStatusID_LKUP))