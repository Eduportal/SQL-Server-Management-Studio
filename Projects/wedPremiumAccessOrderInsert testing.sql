DECLARE     @RunDate  as datetime 
SET			@RunDate  = '2013-9-03'
/*
--*************************************************************  
--*************************************************************  
Sproc:   wedPremiumAccessOrderInsert
Created: 11/13/06
By:  Marco Sanchez
Created for 10.3 December 06 release

Stored Procedure to create Orders, OrderDetail, OrderExtension AND OrderDetailCustomAttribute
records for Premium Access Subscriptions.

The source table for Premium Access subscriptions is wcds..SubscriptionAgreement

HISTORY LOG
Date            Name                         Change Description
----------    -----------                  ------------------------------
11/13/06        Marco Sanchez                Initial Implementation
10/17/2007      msanchez                     Nov 07 Release: Added compensation role function wedFnGetCompRoleID
12/07/2007      msanchez                     January 08: Fix for TFS Bug 28666 Premium Access Orders are publishing to Oracle in Production using a
                                             Test User acct
01/07/2008      LNguyen                      Add script to deactivate expired subscriptions.
02/06/2009      LKrueger                     Modify logic to deactive expired subscriptions after 11:59PM of the EndDate of the subscription agreement. 
05/19/2009      LKrueger                     Publish SubscriptionContact individuals associated to those agreements that we inactivate
06/16/2010      LGuo                         Added BillingStartDate and BillingEndDate to OrderDetailCustomAttribute
08/23/2010      Rajib Bhattacharjee.         Modified to update iModifiedBy for corresponding individual record.
03/15/2010      Jeff Gustafson               US3144 - Fixed business logic so billto address is used for shipto address
05/26/2011      Jeff Gustafson               US5318 - Forked wedfncalcbillinginterval so enddate of last billing cycle equals agreement enddate
05/06/2013           Diego Dominguez                          US44862 - PS fix: fix PA invoice date generation (use  wedfncalcbillinginterval149 for both invoice and billing end date because of a gap between them)
--*************************************************************  
--*************************************************************  
*/  

-- Environmental settings
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
       
DECLARE
       @CurrentError                            nvarchar(50),
       @error                                          int,
       @returnValue                             int,
       @ErrorCount                                     int,
       @oiErrorID                                      int,
       @ovchErrorMessage                        nvarchar(256),
       @OrderTypeID_Order_LKUP                  int,
       @iUserStatusID_Test_LKUP          int,
       @iOrderTypeID_Test_LKUP                  int,
       @IndStatusID                             int,
       @AddressTypeID_BILLTO_LKUP        int,
       @AddressTypeID_SHIPTO_LKUP        int,
       @EntityTypeID_COMPANY_LKUP        int,
       @MediaType                                      int,
       @MediaTypeDesc                                  nvarchar(30),
       @BrandID                                        int,
       @DownloadSourceID                        int,
       @DownloadStatusID                        int,
       @Error_Insert_Failed              nvarchar(50),
       @Error_Update_Failed              nvarchar(50),
       @OriginalSystemID                        int,
       @TermsType                                      int,
       @LanguageCode                            nvarchar(10),
       @OrderDate                                      DATETIME


SELECT
       @OrderTypeID_Order_LKUP                  = 1301,
       @AddressTypeID_BILLTO_LKUP        = 300,
       @AddressTypeID_SHIPTO_LKUP        = 301,
       @EntityTypeID_COMPANY_LKUP        = 201,
       @OriginalSystemID                        = 100,
    @iUserStatusID_Test_LKUP             = 2,
    @iOrderTypeID_Test_LKUP              = 1302,
       @BrandID                                        = 404, -- BrAND ID for Premium Access
       @ErrorCount                                     = 0,
       @oiErrorID                                      = 0,
       @DownloadSourceID                        = 3103, -- Premium Access Download
       @DownloadStatusID                        = 950,  -- Downloaded
       @Error_Insert_Failed              = 'Insert_Failed',
       @Error_Update_Failed              = 'Update_Failed',
       @TermsType                                      = 1101 ,
       @LanguageCode                            = 'en-us'


-- Order Table Constants
DECLARE 
       @DownloadDate                            datetime,
       @JobReference                            nvarchar(50),
       @POnumber                                nvarchar(50),
       @ClientName                              nvarchar(50),
       @BillingInterval                         int,
       @BillingIntervalUnit						nvarchar(10),
       @ActivationDate                          datetime,
       @EndDate                                 datetime,     
       @DownloadDetailID                        int,
       @SubscriptionAgreementID					int, 
       @OrderDetailID                           int,
       @CompensationRoleID                      int, 
       @SCIOwnerId                              int,
       @SKU                                     nvarchar(50),
       @OrderID                                 int,
       @IndividualID                            int,
       @CompanyID                               int,
       @vchCurrencyCode                         nvarchar(8), 
       @mOrderTotal                             money, 
       @vchTaxRegNumber                         nvarchar(50), 
       @vchBuyerVatRegNumber                    nvarchar(50),
       @tiTaxExemptFlag                         tinyint, 
       @BillToAddressID                         int,
       @ShipToAddressID                         int,
       @MailToAddressID                         int,
       @vchTaxCity                              nvarchar(62), 
       @vchTaxCounty                            nvarchar(120), 
       @chTaxState                              nchar(4), 
       @vchTaxProvince                          nvarchar(120), 
       @OperationalUnitId                       int,
       @vchTmpShipToGivenName                   nvarchar(100), 
       @vchTmpShipToMiddleName                  nvarchar(100), 
       @vchTmpShipToFamilyName                  nvarchar(100), 
       @vchTmpShipToTitle                       nvarchar(100),
       @vchTmpShipToCompanyName					nvarchar(100),
       @vchTmpShipToPhone                       nvarchar(30),
       @vchTmpShipToExtension                   nvarchar(10),
       @vchTmpShipToFax                         nvarchar(30), 
       @vchTmpShipToEmail                       nvarchar(100),
       @vchTmpBillToPhone                       nvarchar(30), 
       @vchTmpBillToExtension                   nvarchar(10), 
       @vchTmpBillToFax                         nvarchar(30), 
       @vchTmpBillToName                        nvarchar(100), 
       @vchTmpBillToName1                       nvarchar(100),
       @vchTmpBillToName2                       nvarchar(100), 
       @vchTmpInvoiceToName              nvarchar(100), 
       @vchTmpInvoiceToName1                    nvarchar(100),
       @vchTmpInvoiceToName2                    nvarchar(100),
       @BillingFrequencyId                      int,
       @StartDate                                      datetime
       
       ,@iIndividualCommissionStatusId          int
       ,@iCompanyCommissionStatusId             int    

       DECLARE @InactiveAgreements TABLE (SubscriptionAgreementId INT)

       -- SET it up so that we can process everything from midnight  
       SET @RunDate = ISNULL(@RunDate, getdate())                                 
       SET @OrderDate = @RunDate
       SET @RunDate = convert(varchar(10), DATEADD(dd, 1, @RunDate), 101)  

       /* 
       These TEMP tables were added after we encountered perforance issues
       These are to minimize the use of base tables inside the cursor
       */

	  -- DROP TABLE #invoicedate

   --    -- Get maximum Invoice Start Date per agreement
   --    select convert(int, c1.vchCAValue) as SubscriptionAgreementID, max(convert(datetime, c2.vchCAValue)) as MaxInvoiceDate
   --    into   #invoicedate
   --    from   OrderDetailCustomAttribute C1 WITH (NOLOCK) 
   --                  JOIN OrderDetailCustomAttribute C2  WITH (NOLOCK) ON c1.OrderDetailID = c2.OrderDetailID
   --    where  c1.vchCAName = 'SubscriptionAgreementID'
   --       and c2.vchCAName = 'InvoiceStartDate'
		 ---- and CAST(c2.vchCAValue AS DATETIME) < @RunDate
   --    group  by convert(int, c1.vchCAValue)
	  -- order by 1

       -- create unique clustered index idx_inv_0001010 on #invoicedate (SubscriptionAgreementID)


--SELECT * FROM #invoicedate
;With		RawData
			AS
			(
			SELECT		CAST(C1.vchCAValue AS INT) [SubscriptionAgreementID]
						,C1.OrderDetailID
						,C1.dtCreated
						,(SELECT vchCAValue FROM OrderDetailCustomAttribute WITH (NOLOCK) WHERE OrderDetailID = C1.OrderDetailID AND vchCAName = 'InvoiceStartDate' ) [InvoiceStartDate]
						,(SELECT vchCAValue FROM OrderDetailCustomAttribute WITH (NOLOCK) WHERE OrderDetailID = C1.OrderDetailID AND vchCAName = 'InvoiceEndDate' ) [InvoiceEndDate]
			FROM		OrderDetailCustomAttribute C1
			WHERE		vchCAName = 'SubscriptionAgreementID'
			)
			,BadData
			AS
			(
			SELECT		*
			FROM		RawData
			WHERE		[InvoiceStartDate] = [InvoiceEndDate]
			)
			,GoodKeys
			AS
			(
			SELECT		[SubscriptionAgreementID]
						,MAX([OrderDetailID]) [OrderDetailID]
			FROM		RawData
			WHERE		[InvoiceStartDate] != [InvoiceEndDate]
			GROUP BY	[SubscriptionAgreementID]		
			)
			,GoodData
			AS
			(
			SELECT		T1.*
			FROM		RawData T1
			JOIN		GoodKeys T2
					ON	T1.[SubscriptionAgreementID] = T2.[SubscriptionAgreementID]
					AND T1.[OrderDetailID] = T2.[OrderDetailID]
			)
SELECT		T1.*
			,(SELECT billingstartdate from wedfncalcbillinginterval149(T3.StartDate, T3.EndDate,
                                                                                  CASE T3.BillingFrequencyId
                                                                                          when 1 then 1 -- monthly
                                                                                           when 2 then 3 -- quarterly
                                                                                           when 3 then 12 -- annually
                                                                                           when 4 then 0 -- one time
                                                                                           when 5 then 6 -- twice a year
                                                                                         else NULL
                                                                                  END,cast(T1.dtCreated AS DateTime)
                                                                                  ,0)) as NewStartDate
			,(SELECT billingenddate from wedfncalcbillinginterval149(T3.StartDate, T3.EndDate,
                                                                                  CASE T3.BillingFrequencyId
                                                                                          when 1 then 1 -- monthly
                                                                                           when 2 then 3 -- quarterly
                                                                                           when 3 then 12 -- annually
                                                                                           when 4 then 0 -- one time
                                                                                           when 5 then 6 -- twice a year
                                                                                         else NULL
                                                                                  END,cast(T1.dtCreated AS DateTime)
                                                                                  ,0)) as NewEndDate
			,T2.*
			,T3.*
FROM		BadData T1
LEFT JOIN	GoodData T2
		ON	T1.[SubscriptionAgreementID] = T2.[SubscriptionAgreementID]
LEFT JOIN	SubscriptionAgreement T3
		ON	T1.[SubscriptionAgreementID] = T3.[SubscriptionAgreementID]
ORDER BY	1,3






order by 2



DECLARE		@Start		DATETIME
			,@End		DATETIME
			,@RunDate	DATETIME
			,@Interval	INT

SELECT		@Start		= '2012-08-02 00:00:00.000'
			,@End		= '2013-08-02 00:00:00.000'
			,@RunDate	= '2013-06-02 23:59:59.000'
			,@Interval	= 1

;with		DateRangeA
			AS
			(
			SELECT		ROW_NUMBER() OVER(ORDER BY DateTimeValue) [RN]
						,DateTimeValue
			FROM		dbaadmin.dbo.dbaudf_TimeTable(@Start,@End,'month',@Interval)
			)
			,DateRangeB
			AS
			(
			SELECT		ROW_NUMBER() OVER(ORDER BY DateTimeValue) [RN]
						,DateTimeValue
			FROM		dbaadmin.dbo.dbaudf_TimeTable(DATEADD(month,@Interval,@Start),DATEADD(month,@Interval,@End),'month',@Interval)
			)
SELECT		T1.[RN]								[BillingInterval]
			,T1.DateTimeValue					[BillingStartDate]
			,T2.DateTimeValue					[BillingEndDate]
			,T1.DateTimeValue					[StartDateForCalc]
			,DATEADD(ms,-2,T2.DateTimeValue)	[EndDateForCalc]
FROM		DateRangeA T1
JOIN		DateRangeB T2
		ON	T1.[RN] = T2.[RN]
WHERE		@RunDate BETWEEN T1.DateTimeValue AND DATEADD(ms,-2,T2.DateTimeValue)
		AND DATEADD(ms,-2,T2.DateTimeValue) < @End


Select SubscriptionAgreementId
From SubscriptionAgreement
WHERE StartDate < Getdate() 
  and EndDate	>  Getdate() 




---- example call using old function and same values.
--SELECT		*
--FROM		wedfncalcbillinginterval149(@Start, @End,1,@RunDate,0)



       -- Temp table with Agreement information
       SELECT		s.SubscriptionAgreementID
					, @OrderDate
					, c.iCompanyID
					, i.iIndividualID
					, s.SKU
					, s.InvoiceAmount
					, b.interval
					, b.intervalunit
					, s.JobReference
					, s.PONumber
					, s.ClientName
					, t.iTypeID as MediaType
					, t.vchDescription as MediaTypeDesc
                    ,(SELECT billingenddate from wedfncalcbillinginterval149(StartDate, EndDate,
                                                                                  CASE s.BillingFrequencyId
                                                                                          when 1 then 1 -- monthly
                                                                                           when 2 then 3 -- quarterly
                                                                                           when 3 then 12 -- annually
                                                                                           when 4 then 0 -- one time
                                                                                           when 5 then 6 -- twice a year
                                                                                         else NULL
                                                                                  END,COALESCE((SELECT MaxInvoiceDate FROM #invoicedate WHERE SubscriptionAgreementID = s.SubscriptionAgreementID),@OrderDate)
                                                                                  ,0)) as ActivationDate
                     ,i.iStatusID as IndStatusID
					 , s.EndDate
					 , s.BillingFrequencyId
					 , s.StartDate
					 ,dbo.wedFnCalcInvoiceDate(id.MaxInvoiceDate ,s.ActivationDate,b.intervalunit,b.interval,s.EndDate)
					 ,@RunDate
					 ,id.MaxInvoiceDate                       
       --INTO   #Sub
		FROM		SubscriptionAgreement s WITH (NOLOCK) 
		LEFT JOIN	#invoicedate id 
				on	s.SubscriptionAgreementID = id.SubscriptionAgreementID
		JOIN		SubscriptionProperty sp WITH (NOLOCK) 
				on	s.SubscriptionAgreementID = sp.SubscriptionAgreementID
				AND	sp.PropertyID = 5   -- LicenseType
		JOIN		Company c WITH (NOLOCK) 
				ON	s.EntityID = c.iCompanyID 
				AND	c.iStatusID = 1
		JOIN		CompanyIndividualRel r WITH (NOLOCK) 
				ON	c.iCompanyID = r.iCompanyID
				AND	r.iStatusID = 1
		JOIN		Individual i WITH (NOLOCK) 
				ON	r.iIndividualID = i.iIndividualID 
				AND (i.iStatusID = 1           -- ACTIVE
				OR   i.iStatusID = 2)   -- ACTIVETEST
				AND i.iUserVersion > 0
				AND s.BillingUserName = i.vchUserName  -- Grab the individual attached to the agreement
		JOIN		BillingFrequency b WITH (NOLOCK) 
				on	s.billingfrequencyid = b.billingfrequencyid
		JOIN		Type t WITH (NOLOCK) 
				on	t.iTypeiD = (case when sp.InputValue = '1' /*In Perpetuity*/ then 513 else 514 end )

		WHERE		dbo.wedFnCalcInvoiceDate(id.MaxInvoiceDate ,s.ActivationDate,b.intervalunit,b.interval,s.EndDate) < @RunDate
				AND	dbo.wedFnCalcInvoiceDate(id.MaxInvoiceDate ,s.ActivationDate,b.intervalunit,b.interval,s.EndDate) < CONVERT(VARCHAR(10), s.EndDate, 101)  
				AND	s.ActiveFlag = 1 
				AND	s.EntityTypeID = @EntityTypeID_COMPANY_LKUP -- COMPANIES ONLY
				AND	b.EnabledFlag = 1
		ORDER BY	1

--       create index idx_sub_1010 on #sub(iCompanyID)
--       create index idx_sub_1011 on #sub(iIndividualID)

--       -- Temp table with company information to use inside the cursor
--       SELECT distinct b.iCompanyID, b.vchCurrencyCode, 
--              b.vchTaxRegNumber,         b.tiTaxExemptFlag, 
--              b.iPrimBillToAddressID,           b.iPrimShipToAddressID, 
--              b.iPrimMailToAddressID,           c.vchCity, 
--              c.vchCounty,         c.chStateCode, 
--              c.vchProvince,                    CTOU.iOperationalUnitId,
--              b.vchVatRegNumber
--       INTO #Company
--       FROM #Sub s WITH (NOLOCK)
--              JOIN Company b WITH (NOLOCK) ON s.iCompanyID = b.iCompanyID
--              JOIN Address c WITH (NOLOCK) ON c.iAddressID = b.iPrimBillToAddressID
--              JOIN CountryToOpUnit CTOU WITH (NOLOCK) ON CTOU.nchCountryCode =
--                           (CASE CTOU.iOriginalSystemId 
--                           WHEN @OriginalSystemID THEN c.nchCountryCode 
--                           ELSE 'ALL'
--                           END)
--       WHERE  c.iEntityTypeID = @EntityTypeID_COMPANY_LKUP    -- Company's only
--              AND c.iTypeID = @AddressTypeID_BILLTO_LKUP         -- make sure we're using the billing address
--              AND CTOU.iOriginalSystemId = @OriginalSystemID

--       create index idx_comp_1011 on #Company(iCompanyID)

--       -- Temp table with Individual information to use inside the cursor
--       SELECT a.iIndividualID, a.vchGivenName, a.vchMiddleName, 
--              a.vchFamilyName, a.vchTitle, 
--              a.vchOffice, b.vchEmailAddress
--       INTO #Individual
--       FROM #Sub s
--              JOIN Individual a WITH (NOLOCK) ON s.iIndividualID = a.iIndividualID
--              LEFT JOIN  Email b WITH (NOLOCK) ON b.iIndividualID = a.iIndividualID

--       create index idx_indiv_1011 on #Individual (iIndividualID)

--       -- RecordSET containing the agreements that we'll be processing today.
--       DECLARE curPA CURSOR FAST_FORWARD FOR
--              SELECT  SubscriptionAgreementID, iCompanyID, iIndividualID, SKU, 
--                           InvoiceAmount, ActivationDate, interval, intervalunit,
--                           JobReference, PONumber, ClientName, 
--                           MediaType, MediaTypeDesc, IndStatusID,EndDate, BillingFrequencyId,StartDate
--              FROM   #Sub 

--       OPEN curPA
--       FETCH NEXT FROM curPA INTO @SubscriptionAgreementID, @CompanyID, @IndividualID, @SKU, 
--                     @mOrderTotal, @ActivationDate, @BillingInterval, @BillingIntervalUnit,
--                     @JobReference, @PONumber, @ClientName, @MediaType, @MediaTypeDesc, @IndStatusID,@EndDate, @BillingFrequencyId, @StartDate
       
--       WHILE (@@FETCH_STATUS = 0)
--              BEGIN
--              -- Initialize variables
--              select @vchCurrencyCode = null, 
--                           @vchTaxRegNumber = null, 
--                           @tiTaxExemptFlag = null, 
--                           @BillToAddressID = null, 
--                           @ShipToAddressID = null, 
--                           @MailToAddressID = null, 
--                           @vchTaxCity = null, 
--                           @vchTaxCounty = null, 
--                           @chTaxState = null, 
--                           @vchTaxProvince = null, 
--                           @OperationalUnitId = null, 
--                           @vchTmpShipToGivenName  = null, 
--                           @vchTmpShipToMiddleName = null, 
--                           @vchTmpShipToFamilyName = null, 
--                           @vchTmpShipToTitle = null, 
--                           @vchTmpShipToCompanyName = null, 
--                           @vchTmpShipToEmail = null, 
--                           @vchTmpShipToPhone = null, 
--                           @vchTmpShipToExtension = null, 
--                           @vchTmpShipToFax = null, 
--                           @vchTmpBillToPhone = null, 
--                           @vchTmpBillToExtension = null, 
--                           @vchTmpBillToFax = null, 
--                           @CompensationRoleID = 0,
--                           @SCIOwnerId = null,
--                           @iIndividualCommissionStatusId    = null, 
--                           @iCompanyCommissionStatusId       = null
                           

--              /************************************************************************************
--              **            Begin the transaction here! 
--              ************************************************************************************/
--              BEGIN TRAN
--                     SELECT @vchCurrencyCode = vchCurrencyCode, 
--                           @vchTaxRegNumber = vchTaxRegNumber, 
--                           @tiTaxExemptFlag = tiTaxExemptFlag, 
--                           @BillToAddressID = iPrimBillToAddressID, 
--                           @ShipToAddressID = iPrimShipToAddressID,  
--                           @MailToAddressID = iPrimMailToAddressID,
--                           @vchTaxCity = vchCity, 
--                           @vchTaxCounty = vchCounty, 
--                           @chTaxState = chStateCode, 
--                           @vchTaxProvince = vchProvince,    
--                           @OperationalUnitId = iOperationalUnitId,
--                           @vchBuyerVatRegNumber = vchVatRegNumber
--                     FROM   #Company
--                     WHERE  iCompanyID = @CompanyID                  
            
--            -- PA Agreements only involve digital assets so, for tax accounting purposes, the ShipToAddress  
--            -- should agree with the BillToAddress.  If not, create a new ship address for this order.
--                     IF NOT EXISTS(SELECT * FROM [Address] billaddr WITH (NOLOCK) JOIN [Address] shipaddr WITH (NOLOCK)
--                                        ON shipaddr.iAddressID = @ShipToAddressID AND billaddr.iAddressID = @BillToAddressID 
--                                        WHERE billaddr.nchCountryCode           = shipaddr.nchCountryCode           AND 
--                                isnull(billaddr.vchAddress1,'')   = isnull(shipaddr.vchAddress1,'')   AND
--                                isnull(billaddr.vchAddress2,'')   = isnull(shipaddr.vchAddress2,'')   AND
--                                isnull(billaddr.vchAddress3,'')   = isnull(shipaddr.vchAddress3,'')   AND
--                                isnull(billaddr.vchCity,'')       = isnull(shipaddr.vchCity,'')       AND
--                                isnull(billaddr.chStateCode,'')   = isnull(shipaddr.chStateCode,'')   AND
--                                isnull(billaddr.vchProvince,'')   = isnull(shipaddr.vchProvince,'')   AND
--                                isnull(billaddr.vchPostalCode,'') = isnull(shipaddr.vchPostalCode,'') 
--                                    )                          
--                      BEGIN
--                                  INSERT INTO [Address]  WITH (ROWLOCK) ( 
--                                         iStatusID, iTypeID, iEntityID, iEntityTypeID,
--                                         vchAddress1, vchAddress2, vchAddress3, vchCity, 
--                                         chStateCode, vchProvince, vchCounty, nchCountryCode, vchPostalCode, 
--                                         tiCurrentFlag, tiPrimaryFlag, tiRomanCharacterOnlyFlag, 
--                                         iCreatedBy, iModifiedBy, dtCreated, dtModified           )
--                                  SELECT 1, @AddressTypeID_SHIPTO_LKUP, @CompanyID, @EntityTypeID_COMPANY_LKUP,
--                                         vchAddress1, vchAddress2, vchAddress3, vchCity, 
--                                         chStateCode, vchProvince, vchCounty, nchCountryCode, vchPostalCode, 
--                                         1, 0, tiRomanCharacterOnlyFlag, 
--                                         0, 0, getdate(), getdate()
--                                  FROM   [Address] WITH (NOLOCK)
--                                  WHERE  iAddressID = @BillToAddressID -- Use BillToID when creating the new record

--                                  SET @oiErrorID = @@ERROR
--                                  IF @oiErrorID <> 0
--                                    BEGIN
--                                         SELECT @CurrentError = @Error_Insert_Failed
--                                         GOTO ErrorHandler_PA
--                                    END
--                                  SET @ShipToAddressID = @@IDENTITY
--                     END 

--                     -- Fix a ShipToAddress if one in Company table not found above
--                     -- If NOT found create one by duplicating iPrimMailToAddress
--                     -- which we have retrieved into @iInvoiceToAddressID above
--                     IF @ShipToAddressID IS NULL
--                        BEGIN
--                                  INSERT INTO Address  WITH (ROWLOCK) ( 
--                                         iStatusID, iTypeID, iEntityID, iEntityTypeID,
--                                         vchAddress1, vchAddress2, vchAddress3, vchCity, chStateCode, vchProvince, vchCounty, nchCountryCode, vchPostalCode, 
--                                         tiCurrentFlag, tiPrimaryFlag, tiRomanCharacterOnlyFlag, 
--                                         iCreatedBy, iModifiedBy, dtCreated, dtModified           )
--                                  SELECT 1, @AddressTypeID_SHIPTO_LKUP, @CompanyID, @EntityTypeID_COMPANY_LKUP,
--                                         vchAddress1, vchAddress2, vchAddress3, vchCity, chStateCode, vchProvince, vchCounty, nchCountryCode, vchPostalCode, 
--                                         1, 0, tiRomanCharacterOnlyFlag, 
--                                         0, 0, getdate(), getdate()
--                                  FROM   Address WITH (NOLOCK)
--                                  WHERE  iAddressID = @BillToAddressID -- Use BillToID when creating the new record

--                                  SET @oiErrorID = @@ERROR
--                                  IF @oiErrorID <> 0
--                                    BEGIN
--                                         SELECT @CurrentError = @Error_Insert_Failed
--                                         GOTO ErrorHandler_PA
--                                    END
--                                  SET @ShipToAddressID = @@IDENTITY
--                        END  -- If there is NOT a designated ShipToAddress in the Company record
                     
--                     SELECT TOP 1 @iIndividualCommissionStatusId     = CommissionStatusId FROM IndividualCommissionData with (nolock) WHERE IndividualId =  @IndividualId
--                     SELECT TOP 1 @iCompanyCommissionStatusId        = CommissionStatusId FROM CompanyCommissionData with (nolock) WHERE CompanyID = @CompanyID     


--                     -- create an order record for a record in the cursor          
--                     INSERT ORDERS WITH (ROWLOCK) (iTypeID, iIndividualID, iCompanyID, iSalesPersonID, iOriginalSystemID, 
--                           iStatusID, vchOrderIDXRef, dtOrderDate, rCurrencyExchRate,    vchLanguageCode, vchCurrencyCode, 
--                           mTotalTax, mSubTotal, mFreightTotal, mOrderTotal, vchTaxRegNumber, tiTaxExemptFlag, vchAuthNumber, 
--                           dtAuthDate, vchPnRefNumber, iPaymentMethodTypeID, vchCcNumber, vchCcType, sdtCcExpDate, vchNameOnCard, 
--                           vchEmailInvoiceTo, iBillToAddressID, iShipToAddressID, iInvoiceToAddressID, iShippingMethodTypeID, 
--                           vchShipCarrier, vchShipTrackNumber, tiShipOverrideFlag, dtShippedDate, vchTaxCity, vchTaxCounty, 
--                           chTaxState, vchTaxProvince, iLineCount, chAffiliateCode, iAffiliateDetailID, iCreatedBy, dtCreated, 
--                           iModifiedBy, dtModified, vchNotes, iOperationalUnitId, vchCustJobRef, vchCustPurchaseOrder, vchCustClient, 
--                           vchSellerVatRegNumber, vchBuyerVatRegNumber, vchCustPromotionalCode, vchCustOrderedBy, 
--                           vchFulfillmentStatus, iEncryptFormat, iAgentSalesPersonid, mAgentOrderNetRemit, iOrderOpenerID, 
--                           iOrderCloserID, iOrderNamID, vchCustContact, CashPaymentInfo, iIndividualCommissionStatusId , iCompanyCommissionStatusId    ) 
--                     VALUES ((Case when @IndStatusID = @iUserStatusID_Test_LKUP 
--                                  then @iOrderTypeID_Test_LKUP   -- TESTORDER
--                                  else @OrderTypeID_Order_LKUP   -- ORDER
--                                  end)
--                           , @IndividualID, @CompanyID, NULL, @OriginalSystemID, 100 /*AUTHORIZED*/, NULL, getdate(), 
--                           NULL, @LanguageCode, @vchCurrencyCode, 0, @mOrderTotal, NULL, @mOrderTotal, @vchTaxRegNumber, 
--                           @tiTaxExemptFlag, NULL, NULL, NULL, @TermsType, NULL, NULL, 
--                           -- The address IDs are setup this way due to taxation purposes
--                           -- If need to change please check with Oracle APPS representatives
--                           NULL, NULL, NULL, @BillToAddressID, @ShipToAddressID, @BillToAddressID, NULL, 
--                           NULL, NULL, 0, NULL, @vchTaxCity, @vchTaxCounty, @chTaxState, 
--                           @vchTaxProvince, 1, NULL, NULL, 0, getdate(), 0, getdate(), NULL, 
--                           @OperationalUnitId, @JobReference, @POnumber, @ClientName,
--                           NULL, @vchBuyerVatRegNumber, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @iIndividualCommissionStatusId , @iCompanyCommissionStatusId)

--                     SET @oiErrorID = @@Error
--                     IF @oiErrorID <> 0
--                           BEGIN
--                           SET @CurrentError = @Error_Insert_Failed
--                           GOTO ErrorHandler_PA
--                     END

--                     -- retrieve the order number
--                     SELECT @OrderID = @@IDENTITY
                     
--                     SELECT @vchTmpShipToGivenName =  vchGivenName, @vchTmpShipToMiddleName = vchMiddleName, 
--                           @vchTmpShipToFamilyName = vchFamilyName, @vchTmpShipToTitle = vchTitle, 
--                           @vchTmpShipToCompanyName = vchOffice, @vchTmpShipToEmail = vchEmailAddress
--                     FROM #Individual 
--                     WHERE iIndividualID = @IndividualID

--                     -- Billing Phone
--                     SELECT @vchTmpBillToPhone = a.vchPhoneNumber,  @vchTmpBillToExtension = a.vchExtension
--                     FROM Phone a WITH (NOLOCK) 
--                     WHERE a.iEntityID = @CompanyID           
--                           AND a.iEntityTypeID = @EntityTypeID_COMPANY_LKUP       
--                           AND a.iUsageTypeID = 300
--                           AND a.iTechnologyTypeID = 400

--                     -- Billing FAX
--                     SELECT        @vchTmpBillToFax = a.vchPhoneNumber
--                     FROM Phone a WITH (NOLOCK) 
--                     WHERE a.iEntityID = @CompanyID           
--                           AND a.iEntityTypeID = @EntityTypeID_COMPANY_LKUP       
--                           AND a.iUsageTypeID = 300
--                           AND a.iTechnologyTypeID = 401


--                     -- Shipping Phone
--                     SELECT @vchTmpShipToPhone = a.vchPhoneNumber,  @vchTmpShipToExtension = a.vchExtension
--                     FROM Phone a WITH (NOLOCK) 
--                     WHERE a.iEntityID = @CompanyID           
--                           AND a.iEntityTypeID = @EntityTypeID_COMPANY_LKUP       
--                           AND a.iUsageTypeID = 301
--                           AND a.iTechnologyTypeID = 400

--                     -- Shipping FAX
--                     SELECT        @vchTmpShipToFax = a.vchPhoneNumber
--                     FROM Phone a WITH (NOLOCK) 
--                     WHERE a.iEntityID = @CompanyID           
--                           AND a.iEntityTypeID = @EntityTypeID_COMPANY_LKUP       
--                           AND a.iUsageTypeID = 301
--                           AND a.iTechnologyTypeID = 401

--                     INSERT OrderExtension WITH (ROWLOCK) (iOrderID, vchTmpShipToGivenName, vchTmpShipToMiddleName, 
--                           vchTmpShipToFamilyName, vchTmpShipToTitle, vchTmpShipToCompanyName, vchTmpShipToPhone, 
--                           vchTmpShipToExtension, vchTmpShipToFax, vchTmpShipToEmail, vchTmpBillToPhone, vchTmpBillToExtension, 
--                           vchTmpBillToFax, vchTmpBillToName, vchTmpBillToName1, iTmpBillToNameLanguageScript1, vchTmpBillToName2, 
--                           iTmpBillToNameLanguageScript2, vchTmpInvoiceToName, vchTmpInvoiceToName1, iTmpInvoiceToNameLanguageScript1, 
--                           vchTmpInvoiceToName2, iTmpInvoiceToNameLanguageScript2, iCreatedBy, dtCreated, iModifiedBy, dtModified)
--                     VALUES (@OrderID, @vchTmpShipToGivenName, @vchTmpShipToMiddleName, @vchTmpShipToFamilyName, @vchTmpShipToTitle, 
--                           @vchTmpShipToCompanyName, @vchTmpShipToPhone, @vchTmpShipToExtension, @vchTmpShipToFax, @vchTmpShipToEmail, 
--                           @vchTmpBillToPhone, @vchTmpBillToExtension, @vchTmpBillToFax, 
--                           @vchTmpShipToGivenName + ' ' + @vchTmpShipToFamilyName, NULL, NULL, NULL, NULL, 
--                           @vchTmpShipToGivenName + ' ' + @vchTmpShipToFamilyName, NULL, NULL, NULL, NULL, 0, getdate(), 0, getdate())

--                     SET @oiErrorID = @@Error
--                     IF @oiErrorID <> 0
--                           BEGIN
--                           SET @CurrentError = @Error_Insert_Failed
--                           GOTO ErrorHandler_PA
--                     END

--                     SELECT @CompensationRoleID = (select dbo.wedFnGetCompRoleID (@MediaType, @BrandID, @CompanyID, @SKU))
                     
--                     SELECT @SCIOwnerId = c.iSCIOwnerId 
--                     FROM   CompanySCIUserRel c WITH (nolock) 
--                     WHERE  c.iStatusId = 1 
--                           AND c.iCompanyId = @CompanyID 
--                           AND c.iCompensationRoleID = @CompensationRoleID

--                     INSERT INTO OrderDetail WITH (ROWLOCK) (iOrderID, iSCIOwnerId, iStatusID, iMediaTypeID, vchItemDescription, 
--                           vchMasterID, vchPriceCode, vchProductCode, iBrandID, vchBrandName, chBrandCode, vchComment, iQuantity, 
--                           mUnitPrice, mUnitTax, iCreatedBy, dtCreated, iModifiedBy, dtModified, iTaxTypeId, mListPrice, 
--                           mDiscountPrice, mOverridePrice, iCompensationRoleId, vchFulfillmentType)
--                     SELECT @OrderID, @SCIOwnerId, 305 /*FULFILLED*/, @MediaType, @MediaTypeDesc, @SKU, 
--                           NULL, NULL, b.iBrandID, b.vchDescription, b.chBrandCode, 'THIS IS AN AUTO GENERATED PREMIUM ACCESS ORDER', 
--                           1, @mOrderTotal, 0, 0, getdate(), 0, getdate(), NULL, @mOrderTotal, @mOrderTotal, @mOrderTotal,       
--                           @CompensationRoleID, 'Digital'
--                     FROM BrAND b WITH (NOLOCK)
--                     WHERE iBrandID = @BrandID

--                     SET @oiErrorID = @@Error
--                     IF @oiErrorID <> 0
--                           BEGIN
--                           SET @CurrentError = @Error_Insert_Failed
--                           GOTO ErrorHandler_PA
--                     END

--                     SET @OrderDetailID = @@IDENTITY
--                     IF @OrderDetailID > 0 
--                     BEGIN
--                           --Declaration and common attributes
                     
--                           DECLARE @MonthsPerBillingCycle INT
--                           DECLARE @BillingStartDate DATETIME
--                           DECLARE @BillingEndDate DATETIME
--                           DECLARE @BillingStartDateFormatted VARCHAR(10)
                           
--                           SELECT @MonthsPerBillingCycle = CASE @BillingFrequencyId
--                                                                                           when 1 then 1 -- monthly
--                                                                                           when 2 then 3 -- quarterly
--                                                                                           when 3 then 12 -- annually
--                                                                                           when 4 then 0 -- one time
--                                                                                           when 5 then 6 -- twice a year
--                                                                                  else NULL
--                                                                                  END
                           
--                           SELECT        @BillingStartDate = billingstartdate
--                                         , @BillingEndDate = billingenddate 
--                           FROM   wedfncalcbillinginterval149(@StartDate, @EndDate,@MonthsPerBillingCycle,@OrderDate,0)
                           
--                           -- Custom Attribute: Subscription Agreement ID
--                           INSERT INTO OrderDetailCustomAttribute WITH (ROWLOCK) (OrderDetailID, vchCAName, iCATypeID, 
--                                  vchCAValue, dtCreated, iCreatedBy, dtModified, iModifiedBy)
--                            SELECT @OrderDetailID, 'SubscriptionAgreementID', 10000, @SubscriptionAgreementID, getdate(), 0, getdate(), 0

--                           SET @oiErrorID = @@Error
--                           IF @oiErrorID <> 0
--                                  BEGIN
--                                  SET @CurrentError = @Error_Insert_Failed
--                                  GOTO ErrorHandler_PA
--                           END

--                           -- Custom Attribute: Invoice START Date
--                           INSERT INTO OrderDetailCustomAttribute WITH (ROWLOCK) (OrderDetailID, vchCAName, iCATypeID, 
--                                  vchCAValue, dtCreated, iCreatedBy, dtModified, iModifiedBy)
--                           SELECT @OrderDetailID, 'InvoiceStartDate', 10003, convert(varchar(10), @ActivationDate, 101), getdate(), 0, getdate(), 0

--                           SET @oiErrorID = @@Error
--                           IF @oiErrorID <> 0
--                                  BEGIN
--                                  SET @CurrentError = @Error_Insert_Failed
--                                  GOTO ErrorHandler_PA
--                           END

--                           -- Custom Attribute: Invoice END Date
--                           IF(@BillingInterval=0)
--                           BEGIN
--                                  INSERT INTO OrderDetailCustomAttribute WITH (ROWLOCK) (OrderDetailID, vchCAName, iCATypeID, 
--                                  vchCAValue, dtCreated, iCreatedBy, dtModified, iModifiedBy)
--                                  SELECT @OrderDetailID, 'InvoiceEndDate', 10003, convert(varchar(10), @EndDate, 101), getdate(), 0, getdate(), 0

--                           END
--                           ELSE
--                           BEGIN
--                                  INSERT INTO OrderDetailCustomAttribute WITH (ROWLOCK) (OrderDetailID, vchCAName, iCATypeID, 
--                                         vchCAValue, dtCreated, iCreatedBy, dtModified, iModifiedBy)
--                                  SELECT @OrderDetailID, 'InvoiceEndDate', 10003, convert(varchar(10), @BillingEndDate, 101), getdate(), 0, getdate(), 0
--                           END

--                           SET @oiErrorID = @@Error
--                           IF @oiErrorID <> 0
--                                  BEGIN
--                                  SET @CurrentError = @Error_Insert_Failed
--                                  GOTO ErrorHandler_PA
--                           END
                           
--                           -- Custom Attribute: Billing Start Date
                           
--                           --convert billingstartdate to yyyy-mm-dd for string sorting
--                           INSERT INTO OrderDetailCustomAttribute WITH (ROWLOCK) (OrderDetailID, vchCAName, iCATypeID, vchCAValue, dtCreated, iCreatedBy, dtModified, iModifiedBy)
--                           SELECT @OrderDetailID, 'BillingStartDate', 10003, CONVERT(VARCHAR,@BillingStartDate,120) , getdate(), 0, getdate(), 0

--                           SET @oiErrorID = @@Error
--                           IF @oiErrorID <> 0
--                                  BEGIN
--                                  SET @CurrentError = @Error_Insert_Failed
--                                  GOTO ErrorHandler_PA
--                           END
                           
--                           -- Custom Attribute: Billing End Date
                           
--                           --convert billingenddate to yyyy-mm-dd for string sorting
--                           INSERT INTO OrderDetailCustomAttribute WITH (ROWLOCK) (OrderDetailID, vchCAName, iCATypeID, vchCAValue, dtCreated, iCreatedBy, dtModified, iModifiedBy)
--                           SELECT @OrderDetailID, 'BillingEndDate', 10003, CONVERT(VARCHAR,@BillingEndDate,120) , getdate(), 0, getdate(), 0

--                           SET @oiErrorID = @@Error
--                           IF @oiErrorID <> 0
--                                  BEGIN
--                                  SET @CurrentError = @Error_Insert_Failed
--                                  GOTO ErrorHandler_PA
--                           END
                           
--                     END 

--                     -- Update the OrderFulFilledDate 
--                     UPDATE SubscriptionAgreement
--                     SET           OrderFulFilledDate = getdate()
--                     WHERE  SubscriptionAgreementID = @SubscriptionAgreementID
--                        AND EntityID = @CompanyID

--                     SET @oiErrorID = @@Error
--                     IF @oiErrorID <> 0
--                     BEGIN
--                           SET @CurrentError = @Error_update_Failed
--                           GOTO ErrorHandler_PA
--                     END

--                     -- ONLY PUBLISH TO SUBSCRIBING SYSTEMS IF INDIVIDUAL IS NOT A TEST USER
--                     if @IndStatusID <> @iUserStatusID_Test_LKUP  -- ACTIVETEST
--                           -- Add an entry to the vitria event log
--                           EXEC VitriaEventMsg 100, @OrderID, 'Insert', 'Order'  

--                     SET @oiErrorID = @@Error
--                     IF @oiErrorID <> 0
--                           BEGIN
--                           SET @CurrentError = @Error_Insert_Failed
--                           GOTO ErrorHandler_PA
--                     END

--                     -------------------------------------------
--                     -- Error handler
--                     -------------------------------------------
--                     ErrorHandler_PA:
--                           IF @oiErrorID <> 0
--                                  BEGIN                
--                                         -- call error-lookup proc, filling OUTPUT parameters
--                                         EXECUTE @returnValue  = wedGetErrorInfo
--                                                       @CurrentError,
--                                                       @oiErrorID OUTPUT,
--                                                       @ovchErrorMessage OUTPUT
--                                         IF @returnValue <> 0
--                                                BEGIN
--                                                       SET @oiErrorID = -999
--                                                       SET @ovchErrorMessage = 'Call to wedGetErrorInfo failed WITH ' + @CurrentError
--                                                END
--                                         ROLLBACK Transaction
--                                         SET @ErrorCount = @ErrorCount + 1
--                                         SET @oiErrorID = 0
--                                  END
--                           ELSE
--                                  COMMIT Transaction

--                           FETCH NEXT FROM curPA INTO @SubscriptionAgreementID, @CompanyID, @IndividualID, @SKU, 
--                           @mOrderTotal, @ActivationDate, @BillingInterval, @BillingIntervalUnit,
--                           @JobReference, @PONumber, @ClientName, @MediaType, @MediaTypeDesc, @IndStatusID,@EndDate, @BillingFrequencyId, @StartDate
--              END 
--       CLOSE curPA 
--       DEALLOCATE curPA

--       -- RecordSET containing all Premim Access Downloads WITH null OrderID or null OrderDetailID
--       DECLARE curDown CURSOR FAST_FORWARD FOR
--              select d.DownloadDetailID, d.SourceDetailID as SubscriptionAgreementID, d.CompanyID, 
--                           convert(varchar(10), a.CreatedDate, 101) as CreateDate
--              from   DownloadDetail d WITH (nolock)
--                           JOIN Download a WITH (nolock) on a.DownloadID = d.DownloadID
--              where  d.DownloadSourceID = @DownloadSourceID   -- Only Premim Access download
--                 and d.StatusID = @DownloadStatusID                  -- Only successful downloads 
--                 and a.CreatedDate >= dateadd(dd, -5, getdate())     -- The downloaddetail table is 12million+ rows so this statment is to help with performance
--                 and (d.OrderID is null
--                 or  d.OrderDetailID is null)

--       OPEN curDown
--       FETCH NEXT FROM curDown INTO @DownloadDetailID, @SubscriptionAgreementID, @CompanyID, @DownloadDate
--       WHILE (@@FETCH_STATUS = 0)
--              BEGIN
--              -- Initialize variables
--              select @OrderDetailID = null,
--                           @OrderID = null
       
--              /************************************************************************************
--              **            Begin the transaction here! 
--              ************************************************************************************/
--              BEGIN TRAN
--                     select @OrderDetailID = d.iOrderDetailID, @OrderID = o.iOrderID
--                     from   Orders o with(nolock)
--                                  join OrderDetail d with(nolock) on o.iOrderID = d.iOrderID
--                                  join OrderDetailCustomAttribute ca with(nolock) on ca.OrderDetailID = d.iOrderDetailID
--                                         and    ca.vchCAName = 'SubscriptionAgreementID'
--                                         and    ca.vchCAValue = convert(nvarchar(30), @SubscriptionAgreementID)
--                                  join OrderDetailCustomAttribute sd with(nolock) on sd.OrderDetailID = d.iOrderDetailID
--                                         and    sd.vchCAName = 'InvoiceStartDate'
--                                         and    convert(datetime, sd.vchCAValue) <= @DownloadDate
--                                  join OrderDetailCustomAttribute ed with(nolock) on ed.OrderDetailID = d.iOrderDetailID
--                                         and    ed.vchCAName = 'InvoiceEndDate'
--                                         and    convert(datetime, ed.vchCAValue) >= @DownloadDate
--                        and o.iCompanyID = @CompanyID

--                     update DownloadDetail
--                     set           OrderID = @OrderID
--                                  ,OrderDetailID = @OrderDetailID
--                     where  DownloadDetailID = @DownloadDetailID

--                     SET @oiErrorID = @@Error
--                     IF @oiErrorID <> 0
--                        BEGIN
--                                  SET @CurrentError = @Error_Update_Failed
--                                  GOTO ErrorHandler_Down
--                        END

--                     -- Add an entry to the vitria event log
--                     EXEC VitriaEventMsg 100, @DownloadDetailID, 'Update', 'DownloadDetail'  

--                     SET @oiErrorID = @@Error
--                     IF @oiErrorID <> 0
--                           BEGIN
--                           SET @CurrentError = @Error_Insert_Failed
--                           GOTO ErrorHandler_Down
--                     END

--                     -------------------------------------------
--                     -- Error handler
--                     -------------------------------------------
--                     ErrorHandler_Down:
--                           IF @oiErrorID <> 0
--                                  BEGIN                
--                                         -- call error-lookup proc, filling OUTPUT parameters
--                                         EXECUTE @returnValue  = wedGetErrorInfo
--                                                       @CurrentError,
--                                                       @oiErrorID OUTPUT,
--                                                       @ovchErrorMessage OUTPUT

--                                         IF @returnValue <> 0
--                                                BEGIN
--                                                       SET @oiErrorID = -999
--                                                       SET @ovchErrorMessage = 'Call to wedGetErrorInfo failed WITH ' + @CurrentError
--                                                END

--                                         ROLLBACK Transaction
--                                         SET @ErrorCount = @ErrorCount + 1
--                                         SET @oiErrorID = 0
--                                  END
--                           ELSE
--                                  COMMIT Transaction

--                     FETCH NEXT FROM curDown INTO @DownloadDetailID, @SubscriptionAgreementID, @CompanyID, @DownloadDate
--              END 
--       CLOSE curDown 
--       DEALLOCATE curDown
       
--       -- store away the agreements that we need to set to inactive. 
--       -- this table will be used to update the Subscriptions in the SubscriptionAgreement table.
--       -- and, this table will be used to publish individuals associated to those agreements.
--       INSERT INTO @InactiveAgreements (SubscriptionAgreementId)
--       SELECT SubscriptionAgreementId 
--       FROM SubscriptionAgreement 
--       WHERE DATEADD(day, 1, EndDate) < getdate() AND ActiveFlag = 1 


---- Deactivate expired subscriptions.  Assume that the expiration expires at 11:59PM.
----     UPDATE SubscriptionAgreement 
----     SET ActiveFlag = 0 
----     WHERE DATEADD(day, 1, EndDate) < getdate() AND ActiveFlag = 1 

--       -- Deactivate expired subscriptions.  Assume that the expiration expires at 11:59PM.
--       UPDATE S
--       SET ActiveFlag = 0
--       FROM SubscriptionAgreement S
--              JOIN @InactiveAgreements I ON S.SubscriptionAgreementId = I.SubscriptionAgreementId
       
--       UPDATE Individual
--       SET dtModified = getdate(),
--              iModifiedBy = 0
--       FROM @InactiveAgreements a
--              JOIN SubscriptionContact s ON A.SubscriptionAgreementId = s.SubscriptionAgreementId
--              JOIN Individual i on s.IndividualId = i.iIndividualId

--       -- Publish each of the individuals that are associated to this agreement in the SubscriptionContact table.
--       INSERT INTO VitriaEventLog (iOriginalSystemID,iObjectID,vchTransactionType, vchObjectClass, dtCreated)
--       SELECT DISTINCT i.iOriginalSystemId,IndividualId,'Update','Individual',getdate()
--       FROM @InactiveAgreements a
--              JOIN SubscriptionContact s ON A.SubscriptionAgreementId = s.SubscriptionAgreementId
--              JOIN Individual i on s.IndividualId = i.iIndividualId
--              WHERE NOT EXISTS (SELECT 1 FROM VitriaEventLog_sdw WHERE new_iobjectid = s.IndividualId
--                                  AND new_vchObjectClass = 'Individual')

--GO


--From: Xin-Liu Yao 
--Sent: Wednesday, July 24, 2013 2:28 PM
--To: TS SQL DBA
--Subject: WedPremiumAccessOrderInsert

--Hi,

--Can someone send me a copy of this sproc from production WCDS.  I need to check the version of the sproc for a pri3 I’m working on right now.

--Thanks, Xin
