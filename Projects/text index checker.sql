
DECLARE @Uptime Bigint
select @Uptime=DATEDIFF(hour,login_time,getdate()) 
From sys.sysprocesses where SPID = 1

SELECT		CASE
			WHEN avg_fragmentation_in_percent < 8 THEN 'NO MAINT NEEDED'
			WHEN avg_fragmentation_in_percent < 30 THEN 'REORGANIZE'
			ELSE 'REBUILD' END AS [ACTION]
			,user_seeks + user_scans + User_lookups [Uses]
			,(user_seeks + user_scans + User_lookups) / @Uptime [UsesPerHr]
			
			,*
FROM		dbaadmin.ndx.IndexMaintenancePhysicalStats
 Order by	1,user_seeks + user_scans + User_lookups desc




Select * 

FROM		