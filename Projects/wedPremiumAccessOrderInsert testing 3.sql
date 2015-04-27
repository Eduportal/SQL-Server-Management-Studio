--GET ALL SUBSCRIPTION ORDER INVOICE DATES
SELECT		c1.OrderDetailCustomAttributeID
			, c1.OrderDetailID
			, CONVERT(INT, c1.vchCAValue) as SubscriptionAgreementID
			, MAX(CONVERT(DATETIME, c2.vchCAValue)) AS MaxInvoiceDate



SELECT		CONVERT(INT, c1.vchCAValue)
			,C3.BillingFrequencyId
			,C2.*

FROM		OrderDetailCustomAttribute C1 WITH (NOLOCK) 
JOIN		OrderDetailCustomAttribute C2  WITH (NOLOCK) 
	ON		c1.OrderDetailID = c2.OrderDetailID
	AND		c1.vchCAName = 'SubscriptionAgreementID'
	AND		c2.vchCAName = 'InvoiceStartDate'

join		subscriptionAgreement C3  WITH (NOLOCK) 
	ON		C3.SubscriptionAgreementId	= CONVERT(INT, c1.vchCAValue)

--	AND		CONVERT(INT, c1.vchCAValue) = 3885

WHERE		CAST(C2.vchCAValue AS DATETIME) != CAST(CONVERT(VarChar(12),C2.dtCreated,101)AS DATETIME)
	AND		CAST(C2.vchCAValue AS DATETIME) > '2013-06-14'
	AND		C3.BillingFrequencyId = 1
ORDER BY	1,2





;WITH		ISD
			AS
			(
			SELECT		*
			FROM		OrderDetailCustomAttribute WITH (NOLOCK)
			WHERE		vchCAName = 'InvoiceStartDate'
			)
			,SAID
			AS
			(
			SELECT		*
			FROM		OrderDetailCustomAttribute WITH (NOLOCK)
			WHERE		vchCAName = 'SubscriptionAgreementID'
			)
			,rawdata
			as
			(
			SELECT		CONVERT(INT, SAID.vchCAValue) [SubscriptionAgreementID]
						,ISD.*
						,CAST(ISD.vchCAValue AS DATETIME) [InvoiceStartDate]
			FROM		SAID
			JOIN		ISD
					ON	ISD.OrderDetailID = SAID.OrderDetailID
			)
			,data
			AS
			(
			SELECT		ROW_NUMBER() OVER(PARTITION BY [SubscriptionAgreementID] ORDER BY [InvoiceStartDate] DESC) RN
						,*
			FROM		rawdata
			)
SELECT		*
			,(SELECT billingenddate from wedfncalcbillinginterval149('2011-07-02 03:00:15.373', '2015-07-02 03:00:15.373',
                                                                                  CASE 1
                                                                                          when 1 then 1 -- monthly
                                                                                           when 2 then 3 -- quarterly
                                                                                           when 3 then 12 -- annually
                                                                                           when 4 then 0 -- one time
                                                                                           when 5 then 6 -- twice a year
                                                                                         else NULL
                                                                                  END,'2013-07-02 03:00:15.373'
                                                                                  ,0)) as ActivationDate

FROM		data
WHERE		[RN] < 3
	AND		[SubscriptionAgreementID] IN (SELECT [SubscriptionAgreementID] FROM data where [RN] = 2)
ORDER BY	2,1







GROUP BY	c1.OrderDetailCustomAttributeID
			, c1.OrderDetailID
			, CONVERT(INT, c1.vchCAValue)


SELECT		*
FROM		OrderDetailCustomAttribute C2  WITH (NOLOCK) 
WHERE		c2.vchCAName = 'InvoiceStartDate'
	AND		OrderDetailID IN

	(
SELECT OrderDetailID
			
FROM		OrderDetailCustomAttribute C1 WITH (NOLOCK) 
--JOIN		OrderDetailCustomAttribute C2  WITH (NOLOCK) 
--	ON		c1.OrderDetailID = c2.OrderDetailID
			
WHERE		c1.vchCAName = 'SubscriptionAgreementID'
	AND		CONVERT(INT, c1.vchCAValue) = 3885
	)



			




	AND		c2.vchCAName = 'InvoiceStartDate'
