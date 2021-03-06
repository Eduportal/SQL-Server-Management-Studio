--USE [master]
--GO
--ALTER DATABASE [wcds] SET PARAMETERIZATION FORCED WITH NO_WAIT
--GO
--ALTER DATABASE [wcds] SET COMPATIBILITY_LEVEL = 100
--GO
--ALTER DATABASE [wcds] SET AUTO_UPDATE_STATISTICS_ASYNC ON WITH NO_WAIT
--GO
--ALTER DATABASE [wcds] SET ALLOW_SNAPSHOT_ISOLATION ON
--GO
--ALTER DATABASE [WCDS] SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE
--GO


USE [wcds]
GO
/****** Object:  StoredProcedure [dbo].[wedOrderDetailsGetCountByMediaType140]    Script Date: 3/13/2015 4:05:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[wedOrderDetailsGetCountByMediaType140]   
 @iOrderID    INT,   --Primary Key of order. if provided, get just this order.  
 @iUserID   int, --If provided, get all orders for this user    
 @iCompanyID INT = 0, --If provided, get all orders for this user. Takes precedence over user.  
 @iOriginalSystemID  INT = 100,  -- Get all orders initated from this site. Combine with other filters  
 @iMediaTypeID INT,   -- if NULL, returns records for all MediaTypes; otherwise, returns for that MediaType only 
 @oiErrorID    INT = 0 OUTPUT,    -- App-defined error if non-zero.   
 @ovchErrorMessage  NVARCHAR(256) = '' OUTPUT -- Text description of app-defined error  
  
AS  

/* ---------------------------------------------------------------------------  
---------------------------------------------------------------------------  
-- Procedure: wedOrderDetailsGetCountByMediaType140
-- For: Getty Images  
--  
-- Dependencies:  
--  wedGetErrorInfo (sp)  
--  
--  
-- Purpose  
--  Get an order or group of orders based on passed filter criteria  
  
-- HISTORY
-- john boen 08/23/06 Revised counts to include additional columns for Editorial and non-editorial assets.
-- Added:
-- Family1: Editorial
-- Family2: non-Editorial.

-- Santosh Bhosale 06/02 removed LMS orders from count as there will not be RM link
-- Larry Krueger  10/15/07 The parameterized @iOrderId was causing the sproc to perform inefficiently.  
--						   I broke the stored procedure into if statements based on @iOrderId
--                         and @iMediaTypeId.  Based on sql traces, I found that this stored procedure is
--                         called 99% (maybe 100%) of the time with null parameters for both @iOrderId and @iMediaTypeId.
--                         the number of reads is cut by about 60% by breaking this into IF statements
--                         when these parameters are null.  I also put a nolock hint on the Orders table.
 
-- Liem Nguyen 09/10 Enable company count
-- Return Values  
--  0: Success  
--  -999: Some failure; check output parameters  
  
---------------------------------------------------------------------------  
--------------------------------------------------------------------------- */  

set nocount on;
SET TRANSACTION ISOLATION LEVEL snapshot;

select t.iTypeID as TypeID, t.vchdescription as Description, count(*) TotalCount
		, isnull(sum(case biseditorialCollectionflag  when 1 then 1 end),0) as Family1
		, isnull(sum(case biseditorialCollectionflag  when 0 then 1 end),0) as Family2
		from orders o
			join orderdetail od on o.iorderid = od.iorderid
			join [type] t on od.iMediaTypeid = t.iTypeID
			join brand b on od.ibrandid = b.ibrandid
		where  (o.iCompanyID = @iCompanyID OR o.iIndividualID = @iUserID) 
		--this ensures that the purchase history on GI shows orders from Jupiter and Punchstock as well
				and ((@iOriginalSystemID = 100 AND o.iOriginalSystemId in (100, 302, 400))
						OR o.iOriginalSystemID = @iOriginalSystemID)
				and od.iStatusID not in (301, 304) --canceled, returned
				and (isnull(@iOrderID,0) = 0 or o.iOrderID = @iOrderID )
				and (isnull(@iMediaTypeID,0) = 0 or iMediaTypeID = @iMediaTypeID )
				and isnull(rtrim(ltrim(od.LMSInvoiceNumber)),'') = ''
		group by t.iTypeID, t.vchdescription

select @oiErrorID = @@Error


/*

DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS
GO

  declare  @iOrderID    INT,   --Primary Key of order. if provided, get just this order.  
 @iUserID   int, --If provided, get all orders for this user    
 @iCompanyID INT, --If provided, get all orders for this user. Takes precedence over user.  
 @iMediaTypeID INT,
 @oiErrorID    INT ,    -- App-defined error if non-zero.   
 @ovchErrorMessage  NVARCHAR(256)  -- Text description of app-defined error  

select @iUserID = 1144896, @iCompanyID=907645 -- qaterms
exec dbo.wedOrderDetailsGetCountByMediaType140   
 @iOrderID    ,   --Primary Key of order. if provided, get just this order.  
 @iUserID   , --If provided, get all orders for this user    
 @iCompanyID , --If provided, get all orders for this user. Takes precedence over user.  
 100 ,  -- Get all orders initated from this site. Combine with other filters  
 @iMediaTypeID ,   -- if NULL, returns records for all MediaTypes; otherwise, returns for that MediaType only 
 @oiErrorID    =@oiErrorID OUTPUT,    -- App-defined error if non-zero.   
 @ovchErrorMessage  =@ovchErrorMessage OUTPUT -- Text description of app-defined error  
  
select @oiErrorID, @ovchErrorMessage
*/

GO

