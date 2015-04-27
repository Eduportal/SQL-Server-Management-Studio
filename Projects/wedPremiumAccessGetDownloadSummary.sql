USE [WCDS]
GO

/****** Object:  StoredProcedure [dbo].[wedPremiumAccessGetDownloadSummary]    Script Date: 10/27/2011 13:50:12 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[wedPremiumAccessGetDownloadSummary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[wedPremiumAccessGetDownloadSummary]
GO

USE [WCDS]
GO

/****** Object:  StoredProcedure [dbo].[wedPremiumAccessGetDownloadSummary]    Script Date: 10/27/2011 13:50:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[wedPremiumAccessGetDownloadSummary]
	@iSubscriptionID int,
	@iUserID int,
	@iDownloadCount int OUTPUT, 
	@iDownloadLimit int OUTPUT,
	@bCanDownload bit OUTPUT,
	@dtLastResetDate datetime OUTPUT,
	@oiErrorID INT = 0 OUTPUT,
	@ovchErrorMessage NVarchar(256) = '' OUTPUT
AS

/* ---------------------------------------------------------------------------
---------------------------------------------------------------------------
--	Procedure: wedPremiumAccessGetDownloadSummary
--	For: Getty Images
--
--	Dependencies:
--	wedGetErrorInfo (sp)
--
--	Revision History
--	Created 04/06/11 Jonathan Wenger
--					Moved download count reset logic out of this procedure and into its own sproc (wedPremiumAccessCountRefresh).
--
--	Purpose
--	Does the following:
--		Retrieves
--
--	Parameters
--	@iSubscriptionID int --SubscriptionID
--	@iUserID int         --UserID
--	@iCompanyID int      --CompanyID

--	@oiErrorID		int = 0 OUTPUT
--		The database Id of the error that occurred. If non-zero, 
--		the transaction is rolled back, and see oErrorMessage
--	@ovchErrorMessage		nvarchar(256) = '' OUTPUT
--		The textual description of the error that occurred
--
--	Return Values
--		0:	Success
--		-999:	Some failure; check output parameters
---------------------------------------------------------------------------
--------------------------------------------------------------------------- */

SET NOCOUNT ON

    
-- Proc-specific variables
DECLARE @RowCount int,
	@Error int,
   	@CurrentError nvarchar(50),
	@iReturnStatus int,
	@downloadAccessPropId int,
	@accessLevel nvarchar(50),
	@userEntityTypeId int,
	@companyEntityTypeId int,
	@iCompanyID int,
	@meteredPropId int
	
	--type values hardcoded all over!
	set @userEntityTypeId=200
	set @companyEntityTypeId=201

--determine if user exceeded his/her download limit.
set @downloadAccessPropId = (select PropertyId from Property WITH(NOLOCK) where PropertyName='DownloadAccessLevel')
select @rowCount=@@rowcount
	if(@rowCount=0)
	begin
		set @iReturnStatus = -1
		set @CurrentError = 'cannot find DownloadAccessLevel prop ID'
		goto ErrorHandler
	end
	
set @meteredPropId = (select PropertyId from Property WITH(NOLOCK) where PropertyName='TimeLimitDownload')
	select @rowCount = @@rowcount
	if(@rowCount = 0)
	begin
		set @iReturnStatus = -1
		set @CurrentError = 'cannot find TimeLimitDownload prop ID'
		goto ErrorHandler
	end
	
set @accessLevel = (select InputValue from SubscriptionProperty WITH(NOLOCK) where PropertyId = @downloadAccessPropId and SubscriptionAgreementId = @iSubscriptionID)
select @rowCount = @@rowcount
	if(@rowCount = 0)
	begin
		set @iReturnStatus = -1
		set @CurrentError='cannot find user/sub access level'
		goto ErrorHandler
	end
	
set @dtLastResetDate = (select LastCurrentValueReset from SubscriptionProperty WITH(NOLOCK) where SubscriptionAgreementId=@iSubscriptionID and PropertyId=@meteredPropId)
	select @rowCount=@@rowcount
	if(@rowCount=0)
	begin
		set @iReturnStatus=-1
		set @CurrentError='cannot find last Company Reset Date'
		goto ErrorHandler
	end

set @iCompanyID=(select EntityId from subscriptionAgreement WITH(NOLOCK) where subscriptionAgreementId=@iSubscriptionID)
select @rowCount=@@rowcount
	if(@rowCount=0)
	begin
		set @iReturnStatus=-1
		set @CurrentError='cannot find companyId with this agreement'
		goto ErrorHandler
	end

--determine the sub download per access level
if(@accessLevel='Company')
begin
	exec @iReturnStatus=wedAgreementDownloadInfoGet_813 @iCompanyID,@companyEntityTypeId,@iSubscriptionID,@iDownloadCount output,@iDownloadLimit output,@oiErrorId,@CurrentError output
	IF @iReturnStatus <> 0
	BEGIN
		goto ErrorHandler
	END
	if(@iDownloadCount>=@iDownloadLimit)
	begin
		set @bCanDownload=0
	end
	else
	begin
		set @bCanDownload=1
	end
end
else if(@accessLevel='Contact')
begin
	exec @iReturnStatus=wedAgreementDownloadInfoGet_813 @iUserID,@userEntityTypeId,@iSubscriptionID,@iDownloadCount output,@iDownloadLimit output,@oiErrorId,@CurrentError output
	IF @iReturnStatus <> 0
	BEGIN
		goto ErrorHandler
	END
	if(@iDownloadCount>=@iDownloadLimit)
	begin
		set @bCanDownload=0
	end
	else
	begin
		set @bCanDownload=1
	end
end
else if(@accessLevel='Unlimited')
begin
	exec @iReturnStatus=wedAgreementDownloadInfoGet_813 @iUserID,@userEntityTypeId,@iSubscriptionID,@iDownloadCount output,@iDownloadLimit output,@oiErrorId,@CurrentError output
	IF @iReturnStatus <> 0
	BEGIN
		goto ErrorHandler
	END
	set @bCanDownload=1
end
else
begin
	set @iReturnStatus=-1
	set @CurrentError='unrecognized access level'
end


-------------------------------------------
-- Normal exit
-------------------------------------------
NormalExit:
	-- Code can "fall into" this exit procedure or
	--	it can be called explicitly 
	RETURN 0

-------------------------------------------
-- Error handler
-------------------------------------------
ErrorHandler:

	IF @iReturnStatus <> 0
	BEGIN
		SELECT @oiErrorID = -999
		SELECT @ovchErrorMessage =@CurrentError
	END
	RETURN -999


GO

GRANT EXECUTE ON [dbo].[wedPremiumAccessGetDownloadSummary] TO [role_oneuser] AS [dbo]
GO


