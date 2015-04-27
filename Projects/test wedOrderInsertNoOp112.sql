declare @p44 int
set @p44=NULL
declare @p45 int
set @p45=NULL
declare @p46 int
set @p46=NULL
declare @p47 nvarchar(256)
set @p47=NULL
declare @p48 int
set @p48=NULL
declare @p49 varchar(256)
set @p49=NULL
exec wcds.dbo.wedOrderInsertNoOp112 @vchUserName=N'avega',@mSubTotal=34100.0000,@mFreightTotal=0.0000,@mOrderTotal=35805.0000,@vchPaymentMethodType=N'CREDITCARD',@chAffiliateCode=NULL,@vchLinkCode=NULL,@vchShippingMethodType=NULL,@vchEmailInvoiceTo=N'gettyguy@gettyimages.com',@vchShipToGivenName=N'Seat',@vchTmpShipToGivenName1=NULL,@iTmpShipToGivenNameLanguageScript1=NULL,@vchTmpShipToGivenName2=NULL,@iTmpShipToGivenNameLanguageScript2=NULL,@vchShipToMiddleName=NULL,@vchShipToFamilyName=N'49636',@vchTmpShipToFamilyName1=NULL,@iTmpShipToFamilyNameLanguageScript1=NULL,@vchTmpShipToFamilyName2=NULL,@iTmpShipToFamilyNameLanguageScript2=NULL,@vchShipToTitle=NULL,@vchShipToCompanyName=N'ORANGE COUNTY REGISTER',@vchTmpShipToCompanyName1=NULL,@iTmpShipToCompanyNameLanguageScript1=NULL,@vchTmpShipToCompanyName2=NULL,@iTmpShipToCompanyNameLanguageScript2=NULL,@vchShipToPhone=N'714-796-2293',@vchShipToPhoneExtension=NULL,@vchShipToFax=N'',@tiUseInvoiceToCompany=0,@vchTaxCity=N'SANTA ANA',@vchTaxCounty=NULL,@chTaxState=N'13',@vchTaxProvince=NULL,@iOriginalSystemID=100,@iCreatedByID=5788447,@vchPnRefNumber=N'V18C3DDF9777',@vchAuthNumber=N'010101',@tiShipOverrideFlag=0,@tiPurchaserIsNotLicensee=NULL,@vchLanguageCode=N'en-us',@tiZeroOrderFlag=0,@CashPaymentInfo=NULL,@oiOrderID=@p44 output,@oiRemainingCartItems=@p45 output,@oiRightsErrorId=@p46 output,@ovchRightsErrorInfo=@p47 output,@oiErrorID=@p48 output,@ovchErrorMessage=@p49 output
select @p44, @p45, @p46, @p47, @p48, @p49