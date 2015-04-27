declare @err    int
        ,   @ErrMsg    varchar(255)
    ,   @MaxProdUDFSeqNum int
    ,   @MaxProdSeqNum int
        ,       @DebugText varchar(500)
        ,       @MaxDateTime Datetime
-- BEGIN TRANSACTION
--------------------------
-- INITIALIZE VARIABLES
--------------------------

Select @MaxDateTime = GetDate()

Select @MaxProdSeqNum = Max(p.SeqNum) 
from dbo.Product_imp p
Where p.CreatedDate < @MaxDateTime

Select @MaxProdUDFSeqNum = Max(pu.SeqNum) 
from ProductUDF_Imp pu
   , dbo.Product_imp p
where p.ProductId = pu.ProductId
        and p.SeqNum <= @MaxProdSeqNum
        and pu.CreatedDate < @MaxDateTime

if @maxProdUDFSeqNum is null set @maxProdUDFSeqNum = 0
if @maxProdSeqNum is null set @maxProdSeqNum = 0

DECLARE @Last_ProductID	VarChar(40)
DECLARE @Max_ProductID	VarChar(40)
SELECT	@Last_ProductID = '',@Max_ProductID = MAX(ProductID) FROM dbo.ProductUDF_Stg WITH(NOLOCK)
	
DECLARE @Data TABLE(
	[SeqNum] [int] NOT NULL,
	[ProductId] [varchar](40) NULL,
	[UDFName] [varchar](80) NULL,
	[UDFValue] [varchar](100) NULL,
	[Process_Status] [char](2) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL)

ReDelete:
DELETE @Data

INSERT INTO	@Data
SELECT		TOP 100 WITH TIES 
		*
FROM		dbo.ProductUDF_Stg WITH(NOLOCK)
WHERE		ProductID > @Last_ProductID
ORDER BY	ProductID

SELECT		@Last_ProductID = MAX(ProductID) FROM @Data		

DELETE		ProductUDF_Imp
FROM		dbo.ProductUDF_Imp pudfi WITH(NOLOCK)
JOIN		@Data pudfs 
	ON	ISNULL(pudfi.UDFName, 'a') = ISNULL(Pudfs.UDFName, 'a')
	AND	ISNULL(pudfi.UDFValue, 'a') = ISNULL(pudfs.UDFValue, 'a')
	AND	ISNULL(rtrim(ltrim(pudfi.ProductId)), 'a') = ISNULL(pudfs.ProductId, 'a')
WHERE		pudfi.SeqNum <= @maxProdUDFSeqNum
	AND	pudfi.CreatedDate < @MaxDateTime

IF       @Last_ProductID != @Max_ProductID
	GOTO      ReDelete	





--SELECT		TOP 100 ProductId,UDFName,UDFValue
--FROM		dbo.ProductUDF_Stg WITH(NOLOCK)


--SELECT		TOP 100 *
--FROM		dbo.ProductUDF_Imp pudfi WITH(NOLOCK)
--JOIN		dbo.ProductUDF_Stg pudfs WITH(NOLOCK)
--	ON	ISNULL(pudfi.UDFName, 'a') = ISNULL(Pudfs.UDFName, 'a')
--	AND	ISNULL(pudfi.UDFValue, 'a') = ISNULL(pudfs.UDFValue, 'a')
--	AND	ISNULL(rtrim(ltrim(pudfi.ProductId)), 'a') = ISNULL(pudfs.ProductId, 'a')
--WHERE		pudfi.SeqNum <= @maxProdUDFSeqNum
--	AND	pudfi.CreatedDate < @MaxDateTime



--ReDelete:
DELETE		FROM ProductUDF_Imp
FROM		dbo.ProductUDF_Imp pudfi WITH(NOLOCK)
JOIN		dbo.ProductUDF_Stg pudfs WITH(NOLOCK)
	ON	ISNULL(pudfi.UDFName, 'a') = ISNULL(Pudfs.UDFName, 'a')
	AND	ISNULL(pudfi.UDFValue, 'a') = ISNULL(pudfs.UDFValue, 'a')
	AND	ISNULL(rtrim(ltrim(pudfi.ProductId)), 'a') = ISNULL(pudfs.ProductId, 'a')
WHERE		pudfi.SeqNum <= @maxProdUDFSeqNum
	AND	pudfi.CreatedDate < @MaxDateTime
--OPTION(Fast 100)
	
--If @@ROWCOUNT = 100
--	GOTO      ReDelete


