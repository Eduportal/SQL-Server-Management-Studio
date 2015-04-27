
-----------------------------------------------------------------------
-----------------------------------------------------------------------
--							SET CUSTOM COUNTER			
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- ENSURE STEP HAS NO UNNEEDED OUTPUT
SET NOCOUNT ON;
-- ENSURE STEP DOES NOT BLOCK OR WAIT FOR BLOCKS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- VALUES PASSED TO COUNTER
DECLARE		@newvalue1		INT			,@newvalue2		INT 
			,@newvalue3		INT			,@newvalue4		INT 
			,@newvalue5		INT 		,@newvalue6		INT 
			,@newvalue7		INT 		,@newvalue8		INT 
			,@newvalue9		INT 		,@newvalue10	INT 
-----------------------------------------------------------------------
-----------------------------------------------------------------------
--						QUERY TO GET VALUE
-----------------------------------------------------------------------
-----------------------------------------------------------------------

select		@newvalue1	= NumberProcessed					-- Progress Count
			,@newvalue2 = (NumberProcessed*100)/55000000	-- Progress Percent
from		ProductCatalog.dbo.AssetConversion_GCBundle WITH(nolock)

SELECT		TOP 1
			@newvalue7=CAST([vchLabel] AS INT)					-- DBAPERF BUILD NUMBER
			,@newvalue8=DATEDIFF(day,[dtBuildDate],GETDATE())	-- DBAPERF DAYS SINCE BUILD DEPLOYED
FROM		[dbaadmin].[dbo].[Build]
WHERE		vchName='dbaperf'
ORDER BY	[dtBuildDate] desc

SELECT		TOP 1
			@newvalue9=CAST([vchLabel] AS INT)					-- DBAADMIN BUILD NUMBER
			,@newvalue10=DATEDIFF(day,[dtBuildDate],GETDATE())	-- DBAADMIN DAYS SINCE BUILD DEPLOYED
FROM		[dbaadmin].[dbo].[Build]
WHERE		vchName='dbaadmin'
ORDER BY	[dtBuildDate] desc


-----------------------------------------------------------------------
-----------------------------------------------------------------------
--			SET VALUE			ONLY UNCOMMENT VALUES USED
-----------------------------------------------------------------------
-----------------------------------------------------------------------
EXEC master.sys.sp_user_counter1	@newvalue1
EXEC master.sys.sp_user_counter2	@newvalue2
--EXEC master.sys.sp_user_counter3	@newvalue3
--EXEC master.sys.sp_user_counter4	@newvalue4
--EXEC master.sys.sp_user_counter5	@newvalue5
--EXEC master.sys.sp_user_counter6	@newvalue6
EXEC master.sys.sp_user_counter7	@newvalue7
EXEC master.sys.sp_user_counter8	@newvalue8
EXEC master.sys.sp_user_counter9	@newvalue9
EXEC master.sys.sp_user_counter10	@newvalue10