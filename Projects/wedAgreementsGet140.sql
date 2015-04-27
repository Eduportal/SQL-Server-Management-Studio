USE [WCDS]
GO

/****** Object:  StoredProcedure [dbo].[wedAgreementsGet140]    Script Date: 10/27/2011 20:14:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[wedAgreementsGet140]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[wedAgreementsGet140]
GO

USE [WCDS]
GO

/****** Object:  StoredProcedure [dbo].[wedAgreementsGet140]    Script Date: 10/27/2011 20:14:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[wedAgreementsGet140]
	@AgreementId INT, -- if not passed in, then we want to get all agreements belong to company
	@EntityId INT = 0, 
	@EntityTypeId INT = 0,
	@ForSetup	bit = 1, -- default to true when setting up agreement. For apply part, we need to pass "false".
	@oiErrorID INT = 0 OUTPUT,
	@ovchErrorMessage NVarchar(256) = '' OUTPUT
AS
/* ---------------------------------------------------------------------------

--	Revision History
--		5/1/2008:   Liem Nguyen - combined wedAgreementGet and wedAgreementOwnerGet
--		7/2/2008:   Liem Nguyen - Added @ForSetup param
--		2/18/2008:	Dirk Hubregs - Support for PA download annotations (notes and project codes)
--      9/01/2010:  Jeff Gustafson - Add PPI field for story US22210.
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

--temporary variable
declare @CompanyId int
select @CompanyId=0

IF @AgreementId >0  -- get single agreement data
BEGIN

	IF NOT EXISTS (SELECT 1 FROM dbo.SubscriptionAgreement WITH (NOLOCK) WHERE SubscriptionAgreementId = @AgreementId)
	BEGIN
		---goto error label
		SELECT  @CurrentError = 'invalid agreementID'
		select  @iReturnStatus=-999
		goto ErrorHandler
	END

	INSERT @AgreementTable SELECT @AgreementId
	GOTO RETURN_DATA
END



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
	if  @EntityId not in (select iCompanyId from Company WITH (NOLOCK) where iCompanyId=@EntityId)
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
			from dbo.SubscriptionAgreement a WITH (NOLOCK)
				Join dbo.SubscriptionContact c on a.SubscriptionAgreementId = c.SubscriptionAgreementId
			where IndividualId=@EntityId and a.ActiveFlag=1 ))
	begin
		select @CompanyId=(select iCompanyID from dbo.CompanyIndividualRel WITH (NOLOCK) where iIndividualID=@EntityId)
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
	dbo.SubscriptionAgreement WITH (NOLOCK)
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
	[ProjectCodes],
	[PpiTypeId]
FROM
	dbo.SubscriptionAgreement a WITH (nolock) 
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
	dbo.SubscriptionAgreement a WITH (nolock) 
JOIN dbo.SubscriptionProperty sp WITH (nolock)  ON
	a.SubscriptionAgreementId = sp.SubscriptionAgreementId 
JOIN @AgreementTable a2 ON
	a.SubscriptionAgreementId = a2.SubscriptionAgreementId

-- subscriptionPortfolioDetail recordset
SELECT sp.SubscriptionAgreementId, sp.PortfolioId, pd.MediaType, FileSizeId as 'DownloadSizeLimit', sp.IsWhollyOwn, spd.IsAllHouse, spd.IsAllPartner
FROM dbo.SubscriptionPortfolio sp WITH (nolock) 
JOIN @AgreementTable a ON
	sp.SubscriptionAgreementId = a.SubscriptionAgreementId
JOIN PortfolioDetail pd WITH (nolock)  ON
	sp.PortfolioId = pd.PortfolioId
JOIN dbo.SubscriptionPortfolioDetail spd WITH (nolock)  ON
	sp.SubscriptionPortfolioId = spd.SubscriptionPortfolioId
	AND pd.PortfolioDetailId = spd.PortfolioDetailId

-- prepare subscriptionBundle
INSERT @AgreementBundle (SubscriptionAgreementId,portfolioId, IsWhollyOwn, IsRestricted, MediaType,BundleId,BundleName,WhollyOwnedBundleId)
SELECT DISTINCT 
SubscriptionAgreementId,portfolioId,IsWhollyOwn, IsRestricted, MediaType,BundleId,BundleName,WhollyOwnedBundleId
FROM
(
SELECT distinct sp.SubscriptionAgreementId, 
       sp.portfolioId, 
       sp.IsWhollyOwn, 
       b.IsRestricted, 
       b.MediaType, 
       b.BundleId, 
       b.BundleName,
       b.WhollyOwnedBundleId
FROM @AgreementTable a 
	JOIN dbo.subscriptionPortfolio  sp WITH (nolock) ON a.subscriptionAgreementId = sp.subscriptionAgreementId
	JOIN dbo.portfolioDetail pd WITH (nolock)  on sp.portfolioId = pd.portfolioId
	JOIN dbo.subscriptionPortfolioDetail spd WITH (nolock)  ON sp.subscriptionPortfolioId = spd.subscriptionPortfolioId 
			AND pd.portfolioDetailId = spd.portfolioDetailId
	JOIN dbo.subscriptionBundle sb WITH (nolock)  ON spd.subscriptionPortfolioDetailId = sb.subscriptionPortfolioDetailId
	JOIN dbo.portfoliobundle pb WITH (nolock)  ON sb.BundleId = pb.BundleId AND pb.portfolioId = sp.portfolioId
	INNER LOOP JOIN dbo.Bundle b WITH (nolock) ON pb.bundleId = b.bundleId AND pd.MediaType = b.MediaType
         AND b.EnabledFlag=1
UNION ALL
SELECT sp.SubscriptionAgreementId, 
       sp.portfolioId, 
       sp.IsWhollyOwn, 
       b.IsRestricted, 
       pd.MediaType,
       b.BundleId, 
       b.BundleName,
       b.WhollyOwnedBundleId
FROM @AgreementTable a 
	JOIN dbo.subscriptionPortfolio sp WITH (nolock)  ON a.subscriptionAgreementId = sp.subscriptionAgreementId
	join dbo.subscriptionPortfolioDetail spd WITH (nolock)  ON sp.subscriptionPortfolioId = spd.subscriptionPortfolioId
			AND (spd.IsAllHouse =1 OR spd.IsAllPartner=1)
	join dbo.portfolioDetail pd WITH (nolock)  ON spd.portfolioDetailId = pd.PortfolioDetailId
	JOIN dbo.portfoliobundle pb WITH (nolock) ON sp.portfolioId = pb.portfolioId
	INNER LOOP JOIN dbo.Bundle  b WITH (nolock) ON pb.bundleId = b.bundleId AND pd.MediaType = b.MediaType
            AND b.IsRestricted = 0
        	AND b.EnabledFlag=1
WHERE (abs(spd.IsAllHouse - 1)= b.IsPartner OR abs(spd.IsAllPartner - 0)= b.IsPartner
		OR (spd.IsAllPartner > 0 AND  spd.IsAllHouse >0))
) s

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
FROM dbo.SubscriptionUsageDetail su WITH (NOLOCK)
	JOIN @AgreementTable a on su.subscriptionAgreementId = a.subscriptionAgreementId
	JOIN dbo.SubscriptionUsageRef sr WITH (nolock) on su.UsageId = sr.UsageId
	
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
		SELECT @ovchErrorMessage = 'Call to wedAgreementsGet140 failed with ' + @CurrentError
	END
	RETURN -999


	
/* TEST

declare @ErrorId int, @ErrorMsg varchar(255)

EXEC wedAgreementsGet140 @AgreementId=5,@EntityId=1,@EntityTypeId=201,@ForSetup=0,
	@oiErrorID= @ErrorId output,@ovchErrorMessage = @ErrorMsg output

select @ErrorId, @ErrorMsg

eleconomista
Select * From Individual Where vchuserName = 'eleconomista'
Select * From dbo.CompanyIndividualRel Where iIndividualID = 3968273
Select * From dbo.Subscription Where CompanyID = 4083176
Select * From dbo.SubscriptionAgreement Where EntityId = 4083176

*/

IF OBJECT_ID('wedAgreementsGet140') IS NOT NULL
    PRINT '<<< CREATED STORED PROCEDURE wedAgreementsGet140 >>>'
ELSE
    PRINT '<<< FAILED CREATING STORED PROCEDURE wedAgreementsGet140 >>>'

GO

GRANT EXECUTE ON [dbo].[wedAgreementsGet140] TO [role_oneuser] AS [dbo]
GO


