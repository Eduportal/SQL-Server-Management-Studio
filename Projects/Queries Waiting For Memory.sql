 select text
, query_plan
, requested_memory_kb
, granted_memory_kb
, used_memory_kb 
from sys.dm_exec_query_memory_grants MG 
CROSS APPLY sys.dm_exec_sql_text(sql_handle)  
CROSS APPLY sys.dm_exec_query_plan(MG.plan_handle)
