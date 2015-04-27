USE [WCDS]
GO

/****** Object:  StoredProcedure [dbo].[wedAgreementDownloadInfoGet_813]    Script Date: 10/27/2011 13:52:41 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[wedAgreementDownloadInfoGet_813]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[wedAgreementDownloadInfoGet_813]
GO

USE [WCDS]
GO

/****** Object:  StoredProcedure [dbo].[wedAgreementDownloadInfoGet_813]    Script Date: 10/27/2011 13:52:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[wedAgreementDownloadInfoGet_813]
	@iEntityID int,
	@iEntityTypeID int,
	@iAgreementID int,
	@iDownloadCount int OUTPUT,
	@iDownloadLimit int Output,
	@oiErrorID INT = 0 OUTPUT,
	@ovchErrorMessage NVarchar(256) = '' OUTPUT
AS

/* ---------------------------------------------------------------------------
---------------------------------------------------------------------------
--	Procedure: wedAgreementDownloadInfoGet_813
--	For: Getty Images
--
--	Dependencies:
--	wedGetErrorInfo (sp)
--
--	Revision History
--	Created 10/20/06 Santosh Bhosale
--
--	Purpose
--	Does the following:
--		1. Returns Download Info Count
--
--	Parameters
--	@iEntityID int, 	--EntityID
--	@iEntityTypeID int,	--EntityTypeID
--	@iAgreementID int	--AgreementID

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

-- Establish error handler constants
DECLARE
    @Error_Select_Failed nvarchar(50)  

SELECT
    @Error_Select_Failed = 'Select_Failed'
    
-- Proc-specific variables
DECLARE @RowCount int,
	@Error int,
    @CurrentError nvarchar(50),
	@iReturnStatus int,
	@strCurrentCount  nvarchar(50),
	@meteredPropId int,
	@contactId int,
	@strDownloadLimit nvarchar(50),
	@downloadLimitPropId int,
	@strDownloadUnlimited nvarchar(50)

set @meteredPropId=(select PropertyId from Property WITH(NOLOCK) where PropertyName='TimeLimitDownload')
select @rowCount=@@rowcount
if(@rowCount=0)
begin
	set @iReturnStatus=-1
	set @CurrentError='cannot find TimeLimitDownload prop ID'
	goto ErrorHandler
end

--determine if user exceeded he's/her download limit.
set @downloadLimitPropId=(select PropertyId from Property WITH(NOLOCK) where PropertyName='MeteredDownload')
select @rowCount=@@rowcount
if(@rowCount=0)
begin
	set @iReturnStatus=-1
	set @CurrentError='cannot find MeteredDownload prop ID'
	goto ErrorHandler
end

--indicates if this is contact, company or unlimited.
SELECT @strDownloadUnlimited = InputValue FROM dbo.SubscriptionProperty WITH(NOLOCK) WHERE PropertyId = 6 AND SubscriptionAgreementId=@iAgreementID
IF(@strDownloadUnlimited = 'Unlimited')
	BEGIN
		--unlimited so set both properties to -1 and exit
		SELECT @iDownloadCount= -1
		SELECT @iDownloadLimit = -1
	END
ELSE
	BEGIN	
		if(@iEntityTypeID=200)
		begin
			
			if(@iEntityID not in (select IndividualId from SubscriptionContact WITH(NOLOCK) where SubscriptionAgreementId=@iAgreementID and IndividualId=@iEntityID))
			begin
				select @CurrentError='invalid user or agreement ID'
				select @iReturnStatus=-1
				GOTO ErrorHandler
			end
			set @contactId=(select SubscriptionContactId from SubscriptionContact WITH(NOLOCK) where SubscriptionAgreementId=@iAgreementID and IndividualId=@iEntityID)
			set @strCurrentCount=(select  CurrentValue from SubscriptionContactProperty WITH(NOLOCK) where SubscriptionContactId=@contactId and PropertyId=@meteredPropId)
			set @iDownloadCount=CONVERT(int, @strCurrentCount)
			
			--this is a work around, eventually we will need to get the property from the correct location for contact  which is in SubscriptionContactProperty like this:
			--select  InputValue from SubscriptionContactProperty where SubscriptionContactId=@contactId and PropertyId=@downloadLimitPropId
			set @strDownloadLimit=(select  InputValue from SubscriptionProperty WITH(NOLOCK) where SubscriptionAgreementId=@iAgreementID and PropertyId=@downloadLimitPropId)
			set @iDownloadLimit=CONVERT(int, @strDownloadLimit)
		end
		else if(@iEntityTypeID=201)
		begin
			if(@iEntityID not in (select EntityId from SubscriptionAgreement WITH(NOLOCK) where SubscriptionAgreementId=@iAgreementID and EntityId=@iEntityID))
			   begin
					select @CurrentError='invalid company or agreement ID'
					select @iReturnStatus=-1
					GOTO ErrorHandler
			   end
			set @strCurrentCount=(select CurrentValue from SubscriptionProperty WITH(NOLOCK) where SubscriptionAgreementId=@iAgreementID and PropertyId=@meteredPropId)
			set @iDownloadCount=CONVERT(int, @strCurrentCount)

			set @strDownloadLimit=(select  InputValue from SubscriptionProperty WITH(NOLOCK) where SubscriptionAgreementId=@iAgreementID and PropertyId=@downloadLimitPropId)
			set @iDownloadLimit=CONVERT(int, @strDownloadLimit)
		end
		else
		begin
			select @CurrentError='invalid entity type ID'
			select @iReturnStatus=-1
			GOTO ErrorHandler
		end
	END


SELECT @RowCount = @@RowCount, @Error = @@ERROR
IF @Error <> 0
BEGIN
	SELECT @CurrentError = @Error_Select_Failed
	GOTO ErrorHandler
END

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

	-- call error-lookup proc, filling OUTPUT parameters
	IF @iReturnStatus <> 0
	BEGIN
		SELECT @oiErrorID = -999
		SELECT @ovchErrorMessage = 'Call to wedGetErrorInfo failed with ' + @CurrentError
	END
	RETURN -999

/* TEST
declare @oiErrorId INT, @Msg NVARCHAR(256)

EXEC wedAgreementDownloadInfoGet_813 2, 201, 1, @oiErrorId, @Msg

*/


GO

GRANT EXECUTE ON [dbo].[wedAgreementDownloadInfoGet_813] TO [role_oneuser] AS [dbo]
GO


