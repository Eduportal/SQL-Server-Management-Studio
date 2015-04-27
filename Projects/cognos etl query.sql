USE WCDS
GO

DECLARE		@DateFrom		DateTime
			,@DateTo		DateTime
			
DECLARE		@AddressIDs		TABLE (iAddressID INT PRIMARY KEY)	
DECLARE		@IndividualIDs	TABLE (iIndividualId INT PRIMARY KEY)	

SELECT		@DateFrom			= CAST([value] AS DateTime)
			,@DateTo			= GetDate()
FROM		fn_listextendedproperty('LastETLDate', 'SCHEMA', 'dbo', 'TABLE', 'Individual', default, default);

IF @@ROWCOUNT = 0 OR COALESCE(@DateFrom,'') = '' 
BEGIN
	SELECT		@DateFrom			= GetDate()-7
				,@DateTo			= GetDate()

	EXEC sys.sp_addextendedproperty 
		@name= N'LastETLDate',				@value= @DateFrom ,
		@level0type= N'SCHEMA',				@level0name= N'dbo', 
		@level1type= N'TABLE',				@level1name= N'Individual'
END



-- POPULATE TABLE VARIABLES WITH INCLUDED ID's
INSERT INTO	@AddressIDs
SELECT		DISTINCT 
			iAddressID
FROM		dbo.Address WITH(NOLOCK)
WHERE		(dtCreated >= @DateFrom
	AND		dtCreated <= @DateTo)

INSERT INTO	@AddressIDs
SELECT		DISTINCT 
			iAddressID
FROM		dbo.Address WITH(NOLOCK)
WHERE		iAddressID NOT IN (SELECT iAddressID FROM @AddressIDs)
	AND		dtModified >= @DateFrom
	AND		dtModified <= @DateTo

INSERT INTO	@IndividualIDs
SELECT		DISTINCT
			iIndividualId
FROM		dbo.Individual WITH(NOLOCK)
WHERE		iIndividualId NOT IN (SELECT iIndividualId FROM @IndividualIDs)
	AND		dtCreated >= @DateFrom
	AND		dtCreated <= @DateTo

INSERT INTO	@IndividualIDs
SELECT		DISTINCT
			iIndividualId
FROM		dbo.Individual WITH(NOLOCK)
WHERE		iIndividualId NOT IN (SELECT iIndividualId FROM @IndividualIDs)
	AND		dtModified >= @DateFrom
	AND		dtModified <= @DateTo

INSERT INTO	@IndividualIDs
SELECT		DISTINCT
			iIndividualId
FROM		dbo.WebSiteUse WITH(NOLOCK)
WHERE		iIndividualId NOT IN (SELECT iIndividualId FROM @IndividualIDs)
	AND		dtCreated >= @DateFrom
	AND		dtCreated <= @DateTo
				
INSERT INTO	@IndividualIDs
SELECT		DISTINCT
			iIndividualId
FROM		dbo.WebSiteUse WITH(NOLOCK)
WHERE		iIndividualId NOT IN (SELECT iIndividualId FROM @IndividualIDs)
	AND		dtModified >= @DateFrom
	AND		dtModified <= @DateTo

INSERT INTO	@IndividualIDs
SELECT		DISTINCT
			iIndividualId
FROM		dbo.Email WITH(NOLOCK)
WHERE		iIndividualId NOT IN (SELECT iIndividualId FROM @IndividualIDs)
	AND		dtCreated >= @DateFrom
	AND		dtCreated <= @DateTo

INSERT INTO	@IndividualIDs
SELECT		DISTINCT
			iIndividualId
FROM		dbo.Email WITH(NOLOCK)
WHERE		iIndividualId NOT IN (SELECT iIndividualId FROM @IndividualIDs)
	AND		dtModified >= @DateFrom
	AND		dtModified <= @DateTo
						
			
--MAIN QUERY TO OUTPUT RESULTS
SELECT		DISTINCT
			i.iIndividualID
			, s.vchDescription					AS Status
			, t.vchDescription					AS IndividualType
			, jtc.JobTitleCategoryName
			, jt.JobTitleName
			, ISNULL(i.nchCountryCode,'Unk')	AS nchCountryCode
			, i.iOriginalSystemID
			, i.vchUserName
			, i.vchGivenName
			, i.vchMiddleName
			, i.vchFamilyName
			, i.vchTitle
			, i.vchOffice
			, i.dtDateOfBirth
			, e.vchEmailAddress
			, i.tiAssociatedFlag
			, i.iOrgTypeCategoryOrgTypeRelID
			, otc.OrgTypeCategoryName
			, ot.OrgTypeName
			, i.dtCreated
			, i.dtModified
			, i.tiGIPrintedMaterialFlag
			, i.tiJIPrintedMaterialFlag
			, i.tiPSPrintedMaterialFlag
			, i.tiCAPrintedMaterialFlag 
			, i.tiPHPrintedMaterialFlag
			, i.tiTSPrintedMaterialFlag			AS tiTSPrintedMaterialFlag
			, i.iPrimBillToAddressID
			, i.iPrimMailToAddressID
			, i.iOfficeId
			, i.vchJobTitleText    
			, adb.vchAddress1					as BillAddress1    
			, adb.vchAddress2					as BillAddress2     
			, adb.vchAddress3					as BillAddress3    
			, adb.vchCity						as BillCity     
			, adb.chStateCode					as BillStateCode    
			, adb.vchProvince					as BillProvince     
			, isnull(adb.nchCountryCode,'Unk')	as BillCountryCode 
			, adb.vchPostalCode					as BillPostalCode      
			, adbs.vchDescription 				as BillValidationStatus             
			, adm.vchAddress1					as MailAddress1    
			, adm.vchAddress2					as MailAddress2     
			, adm.vchAddress3					as MailAddress3    
			, adm.vchCity						as MailCity     
			, adm.chStateCode					as MailStateCode    
			, adm.vchProvince					as MailProvince     
			, isnull(adm.nchCountryCode,'Unk')	as MailCountryCode 
			, adm.vchPostalCode					as MailPostalCode      
			, adms.vchDescription 				as MailValidationStatus    

FROM        (
			SELECT		*
			FROM		dbo.Individual WITH(NOLOCK)
			WHERE		iIndividualId IN (SELECT iIndividualId FROM @IndividualIDs)
				OR		iPrimBillToAddressID IN (SELECT iAddressID FROM @AddressIDs)
				OR		iPrimMAILToAddressID IN (SELECT iAddressID FROM @AddressIDs)
			) i 
LEFT JOIN	dbo.Type t WITH (nolock) 
	ON		i.iTypeID = t.iTypeID 

LEFT JOIN	dbo.Status s WITH (nolock) 
	ON		i.iStatusID = s.iStatusID 

LEFT JOIN	dbo.Email e WITH (nolock) 
	ON		i.iIndividualID = e.iIndividualID 

LEFT JOIN	dbo.JobTitleCategoryJobTitleRel jtr WITH (nolock) 
	ON		i.iJobTitleCategoryJobTitleRelID = jtr.JobTitleCategoryJobTitleRelID 

LEFT JOIN	dbo.JobTitleCategory jtc WITH (nolock) 
	ON		jtr.JobTitleCategoryID = jtc.JobTitleCategoryID 

LEFT JOIN	dbo.JobTitle jt WITH (nolock) 
	ON		jtr.JobTitleID = jt.JobTitleID 

LEFT JOIN	dbo.OrgTypeCategoryOrgTypeRel otr WITH (nolock) 
	ON		i.iOrgTypeCategoryOrgTypeRelID = otr.OrgTypeCategoryOrgTypeRelID 

LEFT JOIN	dbo.OrgTypeCategory otc WITH (nolock) 
	ON		otr.OrgTypeCategoryID = otc.OrgTypeCategoryID 

LEFT JOIN	dbo.OrgType ot WITH (nolock) 
	ON		otr.OrgTypeID = ot.OrgTypeID   

LEFT JOIN	dbo.WebSiteUse w with (nolock) 
	ON		i.iIndividualId = w.iIndividualId  

left join	Address adb WITH(NOLOCK)
	on		i.iPrimBillToAddressID = adb.iAddressID  

left join	Status adbs with(nolock) 
	on		isnull(adb.iValidateAddressStatusID,0) = adbs.iStatusID    

left join	Address adm WITH(NOLOCK)
	on		i.iPrimMAILToAddressID = adm.iAddressID  

left join	Status adms with(nolock) 
	on		isnull(adm.iValidateAddressStatusID,0) = adms.iStatusID

order by 1


EXEC sys.sp_updateextendedproperty 
	@name= N'LastETLDate',				@value= @DateTo ,
	@level0type= N'SCHEMA',				@level0name= N'dbo', 
	@level1type= N'TABLE',				@level1name= N'Individual'

GO




























