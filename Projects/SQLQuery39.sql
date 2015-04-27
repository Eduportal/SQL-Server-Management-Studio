USE [WCDS]
GO
---------- SubscriptionProperty

/* -- test before

 SELECT   a.SubscriptionAgreementId,   sp.SubscriptionPropertyId,   PropertyId,   InputValue,   CurrentValue  
 FROM   dbo.SubscriptionAgreement (nolock) a  
 JOIN SubscriptionProperty (nolock) sp 
 ON   a.SubscriptionAgreementId = sp.SubscriptionAgreementId   
WHERE   a.SubscriptionAgreementId  in (1,2,3,4,5,6,7,8,9)

--*/

-- Improvement 87%
/*
DROP INDEX [SubscriptionProperty].[SWLIX_SubscriptionProperty_2_INC_1_3_4_5]  
GO
CREATE NONCLUSTERED INDEX [SWLIX_SubscriptionProperty_2_INC_1_3_4_5] ON [dbo].[SubscriptionProperty] 
(
	[SubscriptionAgreementId] ASC
)
INCLUDE ( [SubscriptionPropertyId],
[PropertyId],
[InputValue],
[CurrentValue]) WITH (SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON) ON [PRIMARY]
GO
--*/

/* -- test after

 SELECT   a.SubscriptionAgreementId,   sp.SubscriptionPropertyId,   PropertyId,   InputValue,   CurrentValue  
 FROM   dbo.SubscriptionAgreement (nolock) a  
 JOIN SubscriptionProperty (nolock) sp 
 ON   a.SubscriptionAgreementId = sp.SubscriptionAgreementId   
WHERE   a.SubscriptionAgreementId  in (1,2,3,4,5,6,7,8,9)

--*/
-- verified cost reduction of 87% from .0585071 to .007357 which is an improvement of 700%

---------- CartPromotion
/* -- test before
 SELECT iCartID,    c.iIndividualID,    c.dtCreated,    c.dtModified,    iLineCount,    mSubTotal,    mFreightTotal,    mOrderTotal,    vchPaymentMethodType,    vchCustJobRef,    vchCustOrderedBy,    vchCustClient,    tiPurchaserIsNotLicensee,    vchCustPromotionalCode,    vchCustPurchaseOrder,    chAffiliateCode,    vchLinkCode,    vchShippingMethodType,    vchEmailInvoiceTo,    tiShipOverrideFlag,    tiSaveShipToAddressFlag,    
 vchShipToGivenName,              vchShipToMiddleName,    vchShipToFamilyName,    vchShipToTitle,    vchShipToCompanyName,            vchShipToGivenName1,            iShipToGivenNameLanguageScript1 ,            vchShipToGivenName2,            iShipToGivenNameLanguageScript2 ,            vchShipToFamilyName1 ,            iShipToFamilyNameLanguageScript1 ,            vchShipToFamilyName2 ,            iShipToFamilyNameLanguageScript2 ,            vchShipToCompanyName1 ,            iShipToCompanyNameLanguageScript1 ,            vchShipToCompanyName2 ,            iShipToCompanyNameLanguageScript2 ,      vchShipToPhone,    vchShipToPhoneExtension,    vchShipToFax,    vchShipToZip  = vchShipToPostalCode,    
 vchTaxCity,    vchTaxCounty,    chTaxState,    vchTaxProvince,    c.iOriginalSystemID,    vchCreatedByUserName  = i.vchUsername,                  
 vchCurrencyCode, -- 5/24/01 Lwk                  
 c.nchCountryCode, -- 5/24/01 Lwk    
 vchSalesPersonUserName = i2.vchUserName,  -- 2001-07-16 Bassim Saghir                  
 c.vchSellerVatRegNumber,                  c.vchBuyerVatRegNumber,                  c.vchNotes,                  c.vchCustContact,    c.CashPaymentInfo,    tiDoNotShip,    mFreightListPrice,    CartPromotion.PremiumEmail,    CartPromotion.MasterPromoCode,    CartPromotion.PromoKey     
 FROM CART c    
 LEFT OUTER JOIN INDIVIDUAL i    
 ON c.iCreatedBy = i.iIndividualID   
 LEFT OUTER JOIN Individual i2    
 ON c.iSalesPersonId = i2.iIndividualId   
 LEFT OUTER JOIN CartPromotion    
 ON c.iCartId = CartPromotion.CartId   
 WHERE c.iIndividualID = 1--@iIndividualID   
 AND c.iOriginalSystemID = 1--@iOriginalSystemID   
 AND (c.IsQuoteCart is null or c.IsQuoteCart = 0) 
--*/

/* -- IMPACT EST 89%
DROP INDEX	[CartPromotion].[SWLIX_CartPromotion_CL_1]
GO
CREATE CLUSTERED INDEX [SWLIX_CartPromotion_CL_1] ON [dbo].[CartPromotion] 
(
	[CartId] ASC
)WITH (SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON) ON [PRIMARY]
GO
--*/

/* -- test after
 SELECT iCartID,    c.iIndividualID,    c.dtCreated,    c.dtModified,    iLineCount,    mSubTotal,    mFreightTotal,    mOrderTotal,    vchPaymentMethodType,    vchCustJobRef,    vchCustOrderedBy,    vchCustClient,    tiPurchaserIsNotLicensee,    vchCustPromotionalCode,    vchCustPurchaseOrder,    chAffiliateCode,    vchLinkCode,    vchShippingMethodType,    vchEmailInvoiceTo,    tiShipOverrideFlag,    tiSaveShipToAddressFlag,    
 vchShipToGivenName,              vchShipToMiddleName,    vchShipToFamilyName,    vchShipToTitle,    vchShipToCompanyName,            vchShipToGivenName1,            iShipToGivenNameLanguageScript1 ,            vchShipToGivenName2,            iShipToGivenNameLanguageScript2 ,            vchShipToFamilyName1 ,            iShipToFamilyNameLanguageScript1 ,            vchShipToFamilyName2 ,            iShipToFamilyNameLanguageScript2 ,            vchShipToCompanyName1 ,            iShipToCompanyNameLanguageScript1 ,            vchShipToCompanyName2 ,            iShipToCompanyNameLanguageScript2 ,      vchShipToPhone,    vchShipToPhoneExtension,    vchShipToFax,    vchShipToZip  = vchShipToPostalCode,    
 vchTaxCity,    vchTaxCounty,    chTaxState,    vchTaxProvince,    c.iOriginalSystemID,    vchCreatedByUserName  = i.vchUsername,                  
 vchCurrencyCode, -- 5/24/01 Lwk                  
 c.nchCountryCode, -- 5/24/01 Lwk    
 vchSalesPersonUserName = i2.vchUserName,  -- 2001-07-16 Bassim Saghir                  
 c.vchSellerVatRegNumber,                  c.vchBuyerVatRegNumber,                  c.vchNotes,                  c.vchCustContact,    c.CashPaymentInfo,    tiDoNotShip,    mFreightListPrice,    CartPromotion.PremiumEmail,    CartPromotion.MasterPromoCode,    CartPromotion.PromoKey     
 FROM CART c    
 LEFT OUTER JOIN INDIVIDUAL i    
 ON c.iCreatedBy = i.iIndividualID   
 LEFT OUTER JOIN Individual i2    
 ON c.iSalesPersonId = i2.iIndividualId   
 LEFT OUTER JOIN CartPromotion    
 ON c.iCartId = CartPromotion.CartId   
 WHERE c.iIndividualID = 1--@iIndividualID   
 AND c.iOriginalSystemID = 1--@iOriginalSystemID   
 AND (c.IsQuoteCart is null or c.IsQuoteCart = 0) 
 
 --*/
-- verified cost reduction of 89% from .129584 to .0131462 which is an improvement of 890%

/* -- TEST BEFORE


--*/
GO
/* -- ADD INDEX
DROP INDEX [SWLIX_SubscriptionDetail_2_7_21_INC_12] ON [dbo].[SubscriptionDetail] 
GO
CREATE NONCLUSTERED INDEX [SWLIX_SubscriptionDetail_2_7_21_INC_12] ON [dbo].[SubscriptionDetail] 
(
	[SubscriptionID] ASC,
	[Billable] ASC,
	[ActiveFlag] ASC
)
INCLUDE ( [StartDate],
[EndDate]) WITH (SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON) ON [PRIMARY]
GO
--*/
GO
/* --TEST AFTER


--*/
GO


/* -- TEST BEFORE


--*/
GO
/* -- ADD INDEX
DROP INDEX [DownloadDetail].[SWLIX_DownloadDetail_4_3_8_10_2]
GO
CREATE NONCLUSTERED INDEX [SWLIX_DownloadDetail_4_3_8_10_2] ON [dbo].[DownloadDetail] 
(
	[IndividualId] ASC,
	[ImageID] ASC,
	[DownloadSourceId] ASC,
	[StatusID] ASC,
	[DownloadId] ASC
)WITH (SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON) ON [PRIMARY]
GO
--*/
GO
/* --TEST AFTER


--*/
GO



/* -- TEST BEFORE


--*/
GO
/* -- ADD INDEX
DROP INDEX [DownloadDetail].[SWLIX_DownloadDetail_4_2_INC_3_8] 
GO
CREATE NONCLUSTERED INDEX [SWLIX_DownloadDetail_4_2_INC_3_8] ON [dbo].[DownloadDetail] 
(
	[IndividualId] ASC,
	[DownloadId] ASC
)
INCLUDE ( [ImageID],[DownloadSourceId]
) WITH (SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON) ON [PRIMARY]
GO
--*/
GO
/* --TEST AFTER


--*/
GO



/* -- TEST BEFORE


--*/
GO
/* -- ADD INDEX
DROP INDEX [SubscriptionDownload].[SWLIX_SubscriptionDownload_2_1_8] 
GO
CREATE NONCLUSTERED INDEX [SWLIX_SubscriptionDownload_2_1_8] ON [dbo].[SubscriptionDownload] 
(
	[SubscriptionId] ASC,
	[SubscriptionDownloadId] ASC,
	[DownloadId] ASC
)WITH (SORT_IN_TEMPDB = ON, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = ON) ON [PRIMARY]
GO
--*/
GO
/* --TEST AFTER


--*/
GO



/* -- TEST BEFORE


--*/
GO
/* -- ADD INDEX


--*/
GO
/* --TEST AFTER


--*/
GO











    


---- Remove dup downloads from the list    
--SELECT	dd.ImageId 
--	,dd.DownloadSourceId     
--FROM	Downloaddetail (nolock) dd 
--WHERE	dd.individualId = 1--@IndividualId         

---- if the list is empty, just stop.    
---- Create a temporary list of all images downloaded by an individual    
---- under the specified agreement id.   
-- --insert into @DownloadedImages(StatusID, ImageID)   
-- select StatusID, ImageID 
-- from SubscriptionDownload sd   
-- join DownloadDetail dd 
-- on dd.DownloadID = sd.DownloadID 
-- and sd.AssetId = dd.ImageID   
-- where SubscriptionID = 1--@iAgreementID   
-- and dd.IndividualID = 1--@iEntityID    
-- and DownloadSourceId = 3103 



---- Create a set of images downloaded since DownloadLimitDateUTC  
--DECLARE @ImagesDownloaded TABLE(ImageId NVARCHAR(100) primary key)  
--INSERT INTO @ImagesDownloaded   
--SELECT DISTINCT(dd.ImageID)   
--FROM DownloadDetail dd   
--JOIN Download d 
--ON d.DownloadID = dd.DownloadID -- Need Download table for the created date.  
--AND dd.DownloadSourceId = 3102 -- Only include RF Subscriptions  
--AND dd.StatusID <> 951 -- Don't count records which failed.  
--AND dd.IndividualID = 1--@IndividualID -- For a specific Individual  
--JOIN RFSubscription r 
--ON r.RFSubscriptionID = dd.SourceDetailID 
--AND r.RFSubscriptionID = 1--@RFSubscriptionID  
--AND DATEADD(hour,7,d.CreatedDate) >= r.DownloadLimitDateUTC -- images downloaded since this UTC date    

 

--SELECT	dd.ImageId 
--	,dd.DownloadSourceId     
--FROM Downloaddetail (nolock) dd 
--JOIN SubscriptionDownload (nolock) sd 
--ON sd.DownloadID = dd.DownloadID    
--WHERE dd.individualId = 1--@IndividualId      
--AND sd.SubscriptionId = 1--@SubscriptionAgreementID     
--AND dd.StatusID = 950  


-- select COUNT(ImageID) 
-- from SubscriptionDownload sd   
-- join DownloadDetail dd 
-- on dd.DownloadID = sd.DownloadID 
-- and sd.AssetId = dd.ImageID   
-- where SubscriptionID = 1--@iAgreementID   
-- and dd.IndividualID = 1--@iEntityID    
-- and dd.ImageID = 1--@masterID    
-- and DownloadSourceId = 3103   
-- and dd.StatusID in (950, 954)
 
--DECLARE @SiteID INt
--set @SiteID = 0

----INSERT INTO @OrdersOfInterest     
--SELECT DISTINCT dd.DownloadID     
--FROM DownloadDetail (nolock) dd     
--JOIN Download (nolock) d 
--ON dd.DownloadID = d.DownloadID     
--AND dd.IndividualID = 1--@IndividualId      
--JOIN (select distinct ImageID from @ImagesDownloaded) IL 
--ON IL.ImageID = DD.ImageID       
---- AND d.CreatedDate BETWEEN @StartDate AND @EndDate     
--AND d.SiteID = CASE @SiteID WHEN 0 THEN d.SiteID ELSE @SiteID END   

--set @SiteID = 1

----INSERT INTO @OrdersOfInterest     
--SELECT DISTINCT dd.DownloadID     
--FROM DownloadDetail (nolock) dd     
--JOIN Download (nolock) d 
--ON dd.DownloadID = d.DownloadID     
--AND dd.IndividualID = 1--@IndividualId      
--JOIN (select distinct ImageID from @ImagesDownloaded) IL 
--ON IL.ImageID = DD.ImageID       
---- AND d.CreatedDate BETWEEN @StartDate AND @EndDate     
--AND d.SiteID = CASE @SiteID WHEN 0 THEN d.SiteID ELSE @SiteID END   




USE [WCDS]  GO  IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DownloadDetail]') AND name = N'IX_DownloadDetail_3_4_8')  CREATE INDEX [IX_DownloadDetail_3_4_8] ON [dbo].[DownloadDetail]  (   [ImageID], [IndividualId], [DownloadSourceId]  )  WITH  (    SORT_IN_TEMPDB  = ON  , IGNORE_DUP_KEY  = OFF  , DROP_EXISTING   = OFF  , ONLINE   = ON  , PAD_INDEX   = OFF  , STATISTICS_NORECOMPUTE = OFF  , ALLOW_ROW_LOCKS  = ON  , ALLOW_PAGE_LOCKS  = ON  )
USE [WCDS]  GO  IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DownloadDetail]') AND name = N'IX_DownloadDetail_4_8_INC_3')  CREATE INDEX [IX_DownloadDetail_4_8_INC_3] ON [dbo].[DownloadDetail]  (   [IndividualId], [DownloadSourceId]  )  INCLUDE  (   , [ImageID]  )  WITH  (    SORT_IN_TEMPDB  = ON  , IGNORE_DUP_KEY  = OFF  , DROP_EXISTING   = OFF  , ONLINE   = ON  , PAD_INDEX   = OFF  , STATISTICS_NORECOMPUTE = OFF  , ALLOW_ROW_LOCKS  = ON  , ALLOW_PAGE_LOCKS  = ON  )
USE [WCDS]  GO  IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DownloadDetail]') AND name = N'IX_DownloadDetail_4_8_INC_2_3_10')  CREATE INDEX [IX_DownloadDetail_4_8_INC_2_3_10] ON [dbo].[DownloadDetail]  (   [IndividualId], [DownloadSourceId]  )  INCLUDE  (   , [DownloadId], [ImageID], [StatusID]  )  WITH  (    SORT_IN_TEMPDB  = ON  , IGNORE_DUP_KEY  = OFF  , DROP_EXISTING   = OFF  , ONLINE   = ON  , PAD_INDEX   = OFF  , STATISTICS_NORECOMPUTE = OFF  , ALLOW_ROW_LOCKS  = ON  , ALLOW_PAGE_LOCKS  = ON  )
USE [WCDS]  GO  IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DownloadDetail]') AND name = N'IX_DownloadDetail_3_4_8_10_INC_2')  CREATE INDEX [IX_DownloadDetail_3_4_8_10_INC_2] ON [dbo].[DownloadDetail]  (   [ImageID], [IndividualId], [DownloadSourceId], [StatusID]  )  INCLUDE  (   , [DownloadId]  )  WITH  (    SORT_IN_TEMPDB  = ON  , IGNORE_DUP_KEY  = OFF  , DROP_EXISTING   = OFF  , ONLINE   = ON  , PAD_INDEX   = OFF  , STATISTICS_NORECOMPUTE = OFF  , ALLOW_ROW_LOCKS  = ON  , ALLOW_PAGE_LOCKS  = ON  )
USE [WCDS]  GO  IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DownloadDetail]') AND name = N'IX_DownloadDetail_4_8_9_10_INC_2_3')  CREATE INDEX [IX_DownloadDetail_4_8_9_10_INC_2_3] ON [dbo].[DownloadDetail]  (   [IndividualId], [DownloadSourceId], [SourceDetailID], [StatusID]  )  INCLUDE  (   , [DownloadId], [ImageID]  )  WITH  (    SORT_IN_TEMPDB  = ON  , IGNORE_DUP_KEY  = OFF  , DROP_EXISTING   = OFF  , ONLINE   = ON  , PAD_INDEX   = OFF  , STATISTICS_NORECOMPUTE = OFF  , ALLOW_ROW_LOCKS  = ON  , ALLOW_PAGE_LOCKS  = ON  )
USE [WCDS]  GO  IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DownloadDetail]') AND name = N'IX_DownloadDetail_3_4_9_10')  CREATE INDEX [IX_DownloadDetail_3_4_9_10] ON [dbo].[DownloadDetail]  (   [ImageID], [IndividualId], [SourceDetailID], [StatusID]  )  WITH  (    SORT_IN_TEMPDB  = ON  , IGNORE_DUP_KEY  = OFF  , DROP_EXISTING   = OFF  , ONLINE   = ON  , PAD_INDEX   = OFF  , STATISTICS_NORECOMPUTE = OFF  , ALLOW_ROW_LOCKS  = ON  , ALLOW_PAGE_LOCKS  = ON  )
USE [WCDS]  GO  IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DownloadDetail]') AND name = N'IX_DownloadDetail_3_4_9_10')  CREATE INDEX [IX_DownloadDetail_3_4_9_10] ON [dbo].[DownloadDetail]  (   [ImageID], [IndividualId], [SourceDetailID], [StatusID]  )  WITH  (    SORT_IN_TEMPDB  = ON  , IGNORE_DUP_KEY  = OFF  , DROP_EXISTING   = OFF  , ONLINE   = ON  , PAD_INDEX   = OFF  , STATISTICS_NORECOMPUTE = OFF  , ALLOW_ROW_LOCKS  = ON  , ALLOW_PAGE_LOCKS  = ON  )
USE [WCDS]  GO  IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DownloadDetail]') AND name = N'IX_DownloadDetail_3_4_INC_2')  CREATE INDEX [IX_DownloadDetail_3_4_INC_2] ON [dbo].[DownloadDetail]  (   [ImageID], [IndividualId]  )  INCLUDE  (   , [DownloadId]  )  WITH  (    SORT_IN_TEMPDB  = ON  , IGNORE_DUP_KEY  = OFF  , DROP_EXISTING   = OFF  , ONLINE   = ON  , PAD_INDEX   = OFF  , STATISTICS_NORECOMPUTE = OFF  , ALLOW_ROW_LOCKS  = ON  , ALLOW_PAGE_LOCKS  = ON  )
USE [WCDS]  GO  IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DownloadDetail]') AND name = N'IX_DownloadDetail_4_INC_2_3')  CREATE INDEX [IX_DownloadDetail_4_INC_2_3] ON [dbo].[DownloadDetail]  (   [IndividualId]  )  INCLUDE  (   , [DownloadId], [ImageID]  )  WITH  (    SORT_IN_TEMPDB  = ON  , IGNORE_DUP_KEY  = OFF  , DROP_EXISTING   = OFF  , ONLINE   = ON  , PAD_INDEX   = OFF  , STATISTICS_NORECOMPUTE = OFF  , ALLOW_ROW_LOCKS  = ON  , ALLOW_PAGE_LOCKS  = ON  )
USE [WCDS]  GO  IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DownloadDetail]') AND name = N'IX_DownloadDetail_8_10_INC_1_2_5_9_11_19')  CREATE INDEX [IX_DownloadDetail_8_10_INC_1_2_5_9_11_19] ON [dbo].[DownloadDetail]  (   [DownloadSourceId], [StatusID]  )  INCLUDE  (   , [DownloadDetailID], [DownloadId], [CompanyId], [SourceDetailID], [OrderID], [OrderDetailID]  )  WITH  (    SORT_IN_TEMPDB  = ON  , IGNORE_DUP_KEY  = OFF  , DROP_EXISTING   = OFF  , ONLINE   = ON  , PAD_INDEX   = OFF  , STATISTICS_NORECOMPUTE = OFF  , ALLOW_ROW_LOCKS  = ON  , ALLOW_PAGE_LOCKS  = ON  )











