Select		Max(period_ending_date) 
from		getty_master.dbo.x_deal_calc_result DC
join		getty_master.dbo.x_period P 
	on	P.period_sid = DC.period_sid
	
	
SELECT		Max(period_ending_date)
FROM		getty_master.dbo.x_period WITH(NOLOCK)
WHERE		period_sid IN (SELECT period_sid FROM getty_master.dbo.x_deal_calc_result WITH(NOLOCK))



