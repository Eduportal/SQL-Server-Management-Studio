
SELECT		[rundate]
		,dbaadmin.dbo.dbaudf_FormatBytes(SUM(([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])*8),'kb') TotalDB
		,dbaadmin.dbo.dbaudf_FormatBytes(SUM([unallocated_extent_page_count]*8),'kb') Unalocated
		,dbaadmin.dbo.dbaudf_FormatBytes(SUM([version_store_reserved_page_count]*8),'kb') VersionStore
		,dbaadmin.dbo.dbaudf_FormatBytes(SUM([user_object_reserved_page_count]*8),'kb') UserObjects
		,dbaadmin.dbo.dbaudf_FormatBytes(SUM([internal_object_reserved_page_count]*8),'kb') InternalObjects
		,dbaadmin.dbo.dbaudf_FormatBytes(SUM([mixed_extent_page_count]*8),'kb') MixedExtents

		,REPLICATE(NCHAR(9751),(SUM([version_store_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					+(SUM([user_object_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					+(SUM([internal_object_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					+(SUM([mixed_extent_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5)
		--+'|'
		+COALESCE(REPLICATE(NCHAR(9750),20-	(
					 (SUM([version_store_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					+(SUM([user_object_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					+(SUM([internal_object_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					+(SUM([mixed_extent_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					)),'')
		AS [Version|User|Internal|Mixed|Empty]

		,COALESCE(REPLICATE(NCHAR(9419),(SUM([version_store_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5),'')
		--+'|'
		+COALESCE(REPLICATE(NCHAR(9418),(SUM([user_object_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5),'')
		--+'|'
		+COALESCE(REPLICATE(NCHAR(9406),(SUM([internal_object_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5),'')
		--+'|'
		+COALESCE(REPLICATE(NCHAR(9410),(SUM([mixed_extent_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5),'')
		--+'|'
		+COALESCE(REPLICATE(NCHAR(9675),20-	(
					 (SUM([version_store_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					+(SUM([user_object_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					+(SUM([internal_object_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					+(SUM([mixed_extent_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					)),'')
		AS [Version|User|Internal|Mixed|Empty]	

		
FROM		[DBAperf].[dbo].[tempdb_pagestats_log]
GROUP BY	[rundate]
order by	[rundate] desc


