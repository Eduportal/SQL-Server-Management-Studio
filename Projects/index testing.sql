select DB_name(us.database_id)
		,object_name(us.object_id)
		,si.name
		,*
From sys.dm_db_index_usage_stats us
JOIN sys.indexes si
on us.object_id = si.object_id
and us.index_id = si.index_id


WHERE	(us.object_id = object_id('dbo.SalesOrderBase') OR us.object_id = object_id('dbo.SalesOrderExtensionBase'))
	--AND	user_seeks		= 0
	--AND	user_scans		= 0
	--AND	user_lookups	= 0
order by 1,2,3



SELECT			database_id
				,DB_Name(database_id) Database_Name	
				,object_id
				,object_name(object_id)	Table_Name
				,index_id
				,(SELECT name FROM sys.indexes WHERE object_id = ips.object_id and index_id = ips.index_id) Index_Name
				,partition_number	
				,index_type_desc	
				,alloc_unit_type_desc	
				,index_depth	
				,index_level
				,avg_fragmentation_in_percent	
				,fragment_count	
				,avg_fragment_size_in_pages	
				,page_count	
				,avg_page_space_used_in_percent	
				,record_count	
				,ghost_record_count	
				,version_ghost_record_count	
				,min_record_size_in_bytes	
				,max_record_size_in_bytes	
				,avg_record_size_in_bytes	
				,forwarded_record_count
FROM			(
				SELECT			*				
				FROM			[sys].[dm_db_index_physical_stats](DB_ID('Getty_Images_US_Inc__MSCRM'),OBJECT_ID('dbo.SalesOrderExtensionBase'),null,null,'DETAILED')
				UNION ALL
				SELECT			*				
				FROM			[sys].[dm_db_index_physical_stats](DB_ID('Getty_Images_US_Inc__MSCRM'),OBJECT_ID('dbo.SalesOrderBase'),null,null,'DETAILED')
				) ips
ORDER BY		1,3,5,7,11






create table #RollupIds(RollupId uniqueidentifier PRIMARY KEY CLUSTERED)
exec p_RollupByAccount '58A2A548-1094-DA11-B75D-00145E2A78FD', 0, 0
create statistics rupstat on #RollupIds(RollupId)

create table ##RollupIds(RollupId uniqueidentifier PRIMARY KEY CLUSTERED)
INSERT INTO ##RollupIds
SELECT * FROM #RollupIds
Create statistics rupstat on ##RollupIds(RollupId)

select		DISTINCT  
			top 51 
			salesorder0.New_EndClient as 'new_endclient'
			, salesorder0.SubmitDate as 'submitdate'
			, salesorder0.New_InvoiceNumber as 'new_invoicenumber'
			, salesorder0.New_PONumber as 'new_ponumber'
			, salesorder0.CustomerId as 'customerid'
			, salesorder0.New_OutstandingBalance as 'new_outstandingbalance'
			, salesorder0.New_OrderNumber as 'new_ordernumber'
			, salesorder0.New_Salesperson as 'new_salesperson'
			, salesorder0.New_Total as 'new_total'
			, salesorder0.New_site as 'new_site'
			, salesorder0.New_JobNumber as 'new_jobnumber'
			, salesorder0.SalesOrderId as 'salesorderid'
			, salesorder0.CustomerIdType as 'customeridtype'
			, salesorder0.CustomerIdDsc as 'customeriddsc'
			, salesorder0.CustomerIdName as 'customeridname'
from		 SalesOrder as salesorder0 
where		salesorder0.DeletionStateCode in (0)
	and		salesorder0.SalesOrderId in 
										(
										select			salesorder0.SalesOrderId 
										from			SalesOrder as salesorder0 
										where			exists (
																select			RollupId 
																from			##RollupIds 
																where			RollupId = salesorder0.ContactId
																)
										union all
										select			salesorder0.SalesOrderId 
										from			SalesOrder as salesorder0 
										where			exists	(
																select			RollupId 
																from			##RollupIds 
																where			RollupId = salesorder0.AccountId
																)
										)
	and		salesorder0.StateCode = 0
order by	salesorder0.New_OrderNumber desc



drop table #RollupIds







--CREATE NONCLUSTERED INDEX [_dta_index_SalesOrderBase_8_1474104292__K1_K14_K15] ON [dbo].[SalesOrderBase] 
--(
--	[SalesOrderId] ASC,
--	[AccountId] ASC,
--	[ContactId] ASC
--)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]


--CREATE STATISTICS [_dta_stat_1474104292_1_15] ON [dbo].[SalesOrderBase]([SalesOrderId], [ContactId])
--CREATE STATISTICS [_dta_stat_1474104292_15_14] ON [dbo].[SalesOrderBase]([ContactId], [AccountId])