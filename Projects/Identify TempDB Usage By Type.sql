SELECT		@@ServerName
			,user_object_perc		= CONVERT(DECIMAL(6,3), u*100.0/(u+i+v+f))
			,internal_object_perc	= CONVERT(DECIMAL(6,3), i*100.0/(u+i+v+f))
			,version_store_perc		= CONVERT(DECIMAL(6,3), v*100.0/(u+i+v+f))
			,free_space_perc		= CONVERT(DECIMAL(6,3), f*100.0/(u+i+v+f))
			,[total]				= (u+i+v+f)
FROM (
SELECT
u = SUM(user_object_reserved_page_count)*8,
i = SUM(internal_object_reserved_page_count)*8,
v = SUM(version_store_reserved_page_count)*8,
f = SUM(unallocated_extent_page_count)*8
FROM
sys.dm_db_file_space_usage
) x