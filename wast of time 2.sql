sp_whoisactive

DECLARE @MasterPartNum INT
SET @MasterPartNum = 4

Select sum(Allocation_amt) from Usage_integration.dbo.Usage_Master m
	where Master_status = 'Open'
	and $Partition.PF_Usage_Master(Process_period) =  @MasterPartNum
	and exists (select 1 from Reports_work.dbo.Temp_Usage_ValidBrands b
		where m.brand_ID = b.BrandID
		AND b.environ = 'B01')



Select		$Partition.PF_Usage_Master(Process_period)
from		Usage_integration.dbo.Usage_Master m
where		Master_status = 'Open'

	and $Partition.PF_Usage_Master(Process_period) =  2
	and exists (select 1 from Reports_work.dbo.Temp_Usage_ValidBrands b
		where m.brand_ID = b.BrandID
		AND b.environ = 'B01')