USE [WCDS]
GO
DROP PROCEDURE [dbo].[wedAgreementsGet_swl]
GO
CREATE PROCEDURE [dbo].[wedAgreementsGet_swl]
	@AgreementId INT, -- if not passed in, then we want to get all agreements belong to company
	@EntityId INT = 0, 
	@EntityTypeId INT = 0,
	@ForSetup	bit = 1, -- default to true when setting up agreement. For apply part, we need to pass "false".
	@oiErrorID INT = 0 OUTPUT,
	@ovchErrorMessage NVarchar(256) = '' OUTPUT
AS
/* ---------------------------------------------------------------------------

--	Revision History
--		5/1/2008: Liem Nguyen - combined wedAgreementGet and wedAgreementOwnerGet
--		7/2/2008: Liem Nguyen - Added @ForSetup param
--		2/18/2008	Dirk Hubregs - Support for PA download annotations (notes and project codes)
--	Purpose:	return record sets for Premium Access
--						
--
--	Returns: 	0 for success, -999 for error	

--------------------------------------------------------------------------- */

SET NOCOUNT ON

-- Proc-specific variables
DECLARE @CurrentError nvarchar(50),@iReturnStatus int
	
DECLARE @AgreementTable TABLE (SubscriptionAgreementId int)
DECLARE @AgreementBundle TABLE (SubscriptionAgreementId int,portfolioId int, IsWhollyOwn bit, IsRestricted bit, MediaType int,BundleId int,
		BundleName nvarchar(50),WhollyOwnedBundleId int)

IF @AgreementId >0  -- get single agreement data
BEGIN

	IF NOT EXISTS (SELECT 1 FROM SubscriptionAgreement WITH(NOLOCK) WHERE SubscriptionAgreementId = @AgreementId)
	BEGIN
		---goto error label
		SELECT  @CurrentError = 'invalid agreementID'
		select  @iReturnStatus=-999
		goto ErrorHandler
	END

	INSERT @AgreementTable SELECT @AgreementId
	GOTO RETURN_DATA
END

--temporary variable
declare @CompanyId int
select @CompanyId=0

--if the entity type is neither an individual or a company
if(@EntityTypeId not  in (200,201))
begin
			---goto error label
			SELECT  @CurrentError = 'invalid entity type ID'
			select  @iReturnStatus=-999
			goto ErrorHandler
end


if(@EntityTypeId=201)
begin
	if  @EntityId not in (select iCompanyId from Company where iCompanyId=@EntityId)
	begin
			---goto error label
			SELECT  @CurrentError = 'this company does not exist'
			select  @iReturnStatus=-999
			goto ErrorHandler
	end
end


if (@EntityTypeId=200)
begin
	if (@EntityId in (select IndividualId 
			from SubscriptionAgreement a WITH(NOLOCK) 
				Join SubscriptionContact c on a.SubscriptionAgreementId = c.SubscriptionAgreementId
			where IndividualId=@EntityId and a.ActiveFlag=1 ))
	begin
		select @CompanyId=(select iCompanyID from CompanyIndividualRel where iIndividualID=@EntityId)
			if( @CompanyId<>0)
			begin
				--if the select is successfull
				select @EntityId=@CompanyId
				select @EntityTypeId=201
			end
			else
			BEGIN
			---goto error label
			SELECT  @CurrentError = 'this individual may not be part of this company'
			select  @iReturnStatus=-999
			goto ErrorHandler
			END
	end
	else
	BEGIN
		 --goto errorLabel
		 SELECT  @CurrentError =  'User not found or not associated with agreements'
		 goto InvalidHandler -- avoid error logged by Gix.
	END
end

-- get all agreementIds belong to this user
INSERT @AgreementTable
SELECT SubscriptionAgreementId
FROM
	SubscriptionAgreement WITH(NOLOCK) 
WHERE
	EntityId = @EntityId AND
	EntityTypeId = @EntityTypeId


RETURN_DATA:

-- subscriptionAgreement recordset
SELECT
	a.SubscriptionAgreementId, 
	[EntityId], 
	[EntityTypeId], 
	[Sku], 
	[BillingFrequencyId], 
	BillingUserName,
	[StartDate], 
	[EndDate], 
	[ActivationDate], 
	[CurrencyCode], 
	[InvoiceAmount], 
	[Description], 
	[PONumber], 
	[OrderPerson], 
	[JobReference], 
	[ClientName], 
	[PortfolioId], -- this will be removed
	NumberOfContacts,
	RightsGrantedText,
	[ActiveFlag], 
	[CreatedBy], 
	[CreatedDate], 
	[ModifiedBy], 
	[ModifiedDate],
	[IsNoteRequired],
	[IsProjectCodeRequired],
	[ProjectCodes]
FROM
	dbo.SubscriptionAgreement a WITH(NOLOCK) 
	JOIN @AgreementTable a2 ON
		a.SubscriptionAgreementId = a2.SubscriptionAgreementId

-- subscriptionProperty recordset
SELECT
	a.SubscriptionAgreementId,
	sp.SubscriptionPropertyId,
	PropertyId,
	InputValue,
	CurrentValue
FROM
	dbo.SubscriptionAgreement a WITH(NOLOCK) 
JOIN SubscriptionProperty sp WITH(NOLOCK) 
	ON a.SubscriptionAgreementId = sp.SubscriptionAgreementId 
JOIN @AgreementTable a2 
	ON a.SubscriptionAgreementId = a2.SubscriptionAgreementId

-- subscriptionPortfolioDetail recordset
SELECT sp.SubscriptionAgreementId, sp.PortfolioId, pd.MediaType, FileSizeId as 'DownloadSizeLimit', sp.IsWhollyOwn, spd.IsAllHouse, spd.IsAllPartner
FROM SubscriptionPortfolio sp WITH(NOLOCK) 
JOIN @AgreementTable a ON
	sp.SubscriptionAgreementId = a.SubscriptionAgreementId
JOIN PortfolioDetail pd WITH(NOLOCK) 
	ON sp.PortfolioId = pd.PortfolioId
JOIN SubscriptionPortfolioDetail spd WITH(NOLOCK) 
	ON sp.SubscriptionPortfolioId = spd.SubscriptionPortfolioId
	AND pd.PortfolioDetailId = spd.PortfolioDetailId
OPTION(fast 1000)
-- prepare subscriptionBundle
INSERT @AgreementBundle (SubscriptionAgreementId,portfolioId, IsWhollyOwn, IsRestricted, MediaType,BundleId,BundleName,WhollyOwnedBundleId)
SELECT DISTINCT SubscriptionAgreementId,portfolioId,IsWhollyOwn, IsRestricted, MediaType,BundleId,BundleName,WhollyOwnedBundleId
FROM
(
SELECT sp.SubscriptionAgreementId, sp.portfolioId, sp.IsWhollyOwn, b.IsRestricted, b.MediaType, b.BundleId, b.BundleName,b.WhollyOwnedBundleId
FROM		@AgreementTable a 
JOIN		subscriptionPortfolio sp WITH(NOLOCK) 
	ON	a.subscriptionAgreementId = sp.subscriptionAgreementId

JOIN		portfolioDetail pd WITH(NOLOCK) 
	on	sp.portfolioId = pd.portfolioId

JOIN		subscriptionPortfolioDetail spd WITH(NOLOCK) 
	ON	sp.subscriptionPortfolioId = spd.subscriptionPortfolioId 
		AND pd.portfolioDetailId = spd.portfolioDetailId

JOIN		subscriptionBundle sb WITH(NOLOCK) 
	ON	spd.subscriptionPortfolioDetailId = sb.subscriptionPortfolioDetailId

JOIN		portfoliobundle pb WITH(NOLOCK) 
	ON	sb.BundleId = pb.BundleId 
	AND	pb.portfolioId = sp.portfolioId

JOIN		Bundle b WITH(NOLOCK) 
	ON	b.MediaType = pd.MediaType 
	AND	pb.bundleId = b.bundleId
	AND	b.EnabledFlag=1
UNION ALL
SELECT sp.SubscriptionAgreementId, sp.portfolioId, sp.IsWhollyOwn, b.IsRestricted, pd.MediaType,b.BundleId, b.BundleName,b.WhollyOwnedBundleId
FROM		@AgreementTable a 

JOIN		subscriptionPortfolio sp WITH(NOLOCK) 
	ON	a.subscriptionAgreementId = sp.subscriptionAgreementId

join		subscriptionPortfolioDetail spd WITH(NOLOCK) 
	ON	sp.subscriptionPortfolioId = spd.subscriptionPortfolioId
	AND	(
		spd.IsAllHouse =1 
		OR 
		spd.IsAllPartner=1
		)

join		portfolioDetail pd WITH(NOLOCK) 
	ON	spd.portfolioDetailId = pd.PortfolioDetailId

JOIN		portfoliobundle pb WITH(NOLOCK) 
	ON	pb.portfolioId = sp.portfolioId

JOIN		Bundle b WITH(NOLOCK) 
	ON	pb.bundleId		= b.bundleId 
	AND	pd.MediaType		= b.MediaType
		AND b.IsRestricted	= 0
	AND	b.EnabledFlag=1
	AND	(
		spd.IsAllHouse  != b.IsPartner 
		OR 
		spd.IsAllPartner = b.IsPartner
		OR
		spd.IsAllPartner & spd.IsAllHouse >0
		)
) s
OPTION(fast 1)
-- Subscription bundles
IF (@ForSetup=1) 
BEGIN
	SELECT SubscriptionAgreementId,portfolioId,MediaType,BundleId,BundleName--,IsRestricted
	FROM @AgreementBundle
END
ELSE
BEGIN
	SELECT
		SubscriptionAgreementId,
		portfolioId,MediaType, 
		CASE IsWhollyOwn WHEN 1 THEN WhollyOwnedBundleId ELSE BundleId END as 'BundleId',
		BundleName--,
		--IsRestricted
	FROM @AgreementBundle
END

-- SubscriptionUsageDetail
SELECT su.SubscriptionAgreementId, su.UsageId, sr.DisplayName
FROM SubscriptionUsageDetail su WITH(NOLOCK) 
	JOIN @AgreementTable a on su.subscriptionAgreementId = a.subscriptionAgreementId
	JOIN SubscriptionUsageRef sr WITH(NOLOCK) 
	on su.UsageId = sr.UsageId
	
-------------------------------------------
-- Normal exit
-------------------------------------------
NormalExit:
	-- Code can "fall into" this exit procedure or
	--	it can be called explicitly 
	RETURN 0

InvalidHandler:

	SELECT @oiErrorID = -100
	SELECT @ovchErrorMessage = @CurrentError

	RETURN 0
	
-------------------------------------------
-- Error handler
-------------------------------------------
ErrorHandler:

	IF @iReturnStatus <> 0
	BEGIN
		SELECT @oiErrorID = -999
		SELECT @ovchErrorMessage = 'Call to wedAgreementsGet failed with ' + @CurrentError
	END
	RETURN -999
	
/* TEST

declare @ErrorId int, @ErrorMsg varchar(255)

EXEC wedAgreementsGet @AgreementId=5,@EntityId=1,@EntityTypeId=201,@ForSetup=0,
	@oiErrorID= @ErrorId output,@ovchErrorMessage = @ErrorMsg output

select @ErrorId, @ErrorMsg

eleconomista
Select * From Individual Where vchuserName = 'eleconomista'
Select * From dbo.CompanyIndividualRel Where iIndividualID = 3968273
Select * From dbo.Subscription Where CompanyID = 4083176
Select * From dbo.SubscriptionAgreement Where EntityId = 4083176

*/

GO