USE [WCDS]
GO

/****** Object:  StoredProcedure [dbo].[wedPremiumAccess_IncrementAgreementCount]    Script Date: 10/27/2011 13:36:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[wedPremiumAccess_IncrementAgreementCount]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[wedPremiumAccess_IncrementAgreementCount]
GO

USE [WCDS]
GO

/****** Object:  StoredProcedure [dbo].[wedPremiumAccess_IncrementAgreementCount]    Script Date: 10/27/2011 13:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Steve Mayszak
-- Create date: 8/11/2010
-- Description:	Updates the count in the subscription propety table by 1
-- =============================================
CREATE PROCEDURE [dbo].[wedPremiumAccess_IncrementAgreementCount]
	@IndividualId int,
	@agreementId int,
	@currentValue int OUTPUT,
	@newCurrentValue int OUTPUT,
	@isContactLevelAgreement bit OUTPUT
AS
BEGIN

	DECLARE @SubscriptionContactId int
	IF((SELECT InputValue FROM SubscriptionProperty WITH (NOLOCK) WHERE PropertyId = 6 AND SubscriptionAgreementId = @agreementId) = 'Contact')
		BEGIN
			SELECT @isContactLevelAgreement = 1
			
			SELECT @SubscriptionContactId = SubscriptionContactId 
			FROM dbo.SubscriptionContact WITH (NOLOCK)
			WHERE SubscriptionAgreementId = @agreementId AND IndividualId = @IndividualId
			
			SELECT @currentValue = CurrentValue
			FROM SubscriptionContactProperty WITH (NOLOCK)
			WHERE SubscriptionContactId= @SubscriptionContactId
			
			SET @newCurrentValue = @currentValue + 1
			
			UPDATE dbo.SubscriptionContactProperty
			SET CurrentValue = @newCurrentValue
			WHERE SubscriptionContactId= @SubscriptionContactId
			
		END
	
	ELSE -- will be either Unlimited or Company, regardless, we track both types in the same property in subscriptionagreement table
	
		BEGIN
			SELECT @isContactLevelAgreement = 0
			--read the current value out of the subscriptionproperty table where the propety id = 2
			--property id's row, column currentvalue, is always the current count.
			SELECT @currentValue = CurrentValue
			FROM [dbo].[SubscriptionProperty] WITH (NOLOCK)
			WHERE PropertyId = 2 AND SubscriptionAgreementId = @agreementId
			
			SET @newCurrentValue = @currentValue + 1
			
			UPDATE [SubscriptionProperty]
			SET CurrentValue = @newCurrentValue
			WHERE PropertyId = 2 AND SubscriptionAgreementId = @agreementId
		END
END

GO

GRANT EXECUTE ON [dbo].[wedPremiumAccess_IncrementAgreementCount] TO [role_oneuser] AS [dbo]
GO


