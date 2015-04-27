SELECT
user_object_perc = CONVERT(DECIMAL(6,3), u*100.0/(u+i+v+f)),
internal_object_perc = CONVERT(DECIMAL(6,3), i*100.0/(u+i+v+f)),
version_store_perc = CONVERT(DECIMAL(6,3), v*100.0/(u+i+v+f)),
free_space_perc = CONVERT(DECIMAL(6,3), f*100.0/(u+i+v+f)),
[total] = (u+i+v+f)
FROM (
SELECT
u = SUM(user_object_reserved_page_count)*8,
i = SUM(internal_object_reserved_page_count)*8,
v = SUM(version_store_reserved_page_count)*8,
f = SUM(unallocated_extent_page_count)*8
FROM
sys.dm_db_file_space_usage
) x;



SELECT	spu.session_id
		,spu.user_objects_alloc_page_count	
		+spu.internal_objects_alloc_page_count		AS 	alloc_page_count

		,spu.user_objects_dealloc_page_count	
		+spu.internal_objects_dealloc_page_count	AS dealloc_page_count

		,(spu.user_objects_alloc_page_count	
		+spu.internal_objects_alloc_page_count)
		-(spu.user_objects_dealloc_page_count	
		+spu.internal_objects_dealloc_page_count)	AS current_page_count

		,t.text

from sys.dm_db_session_space_usage spu
join sys.dm_exec_sessions s on s.session_id = spu.session_id
join sys.dm_exec_requests r on s.session_id = r.session_id
cross apply sys.dm_exec_sql_text(sql_handle) t 
where		spu.database_id = db_id('tempdb')
	AND		@@SPID != spu.session_id
ORDER BY	4 desc


DECLARE @max int;
DECLARE @i int;
SELECT @max = max (session_id)
FROM sys.dm_exec_sessions
SET @i = 51
  WHILE @i <= @max BEGIN
         IF EXISTS (SELECT session_id FROM sys.dm_exec_sessions
                    WHERE session_id=@i)
         DBCC INPUTBUFFER (@i)
         SET @i=@i+1
         END; 
         
         
         


CREATE VIEW all_task_usage
AS 
SELECT		session_id 
			,SUM(internal_objects_alloc_page_count)		AS task_internal_objects_alloc_page_count
			,SUM(internal_objects_dealloc_page_count)	AS task_internal_objects_dealloc_page_count 
FROM		sys.dm_db_task_space_usage 
GROUP BY	session_id;
GO

CREATE VIEW all_session_usage 
AS
SELECT		R1.session_id
			,R1.internal_objects_alloc_page_count 
			 + R2.task_internal_objects_alloc_page_count	AS session_internal_objects_alloc_page_count
			,R1.internal_objects_dealloc_page_count 
			 + R2.task_internal_objects_dealloc_page_count	AS session_internal_objects_dealloc_page_count
FROM		sys.dm_db_session_space_usage AS R1 
INNER JOIN	all_task_usage AS R2 
	ON		R1.session_id = R2.session_id;
GO


CREATE VIEW all_request_usage
AS 
SELECT		session_id
			, request_id 
			, SUM(internal_objects_alloc_page_count)	AS request_internal_objects_alloc_page_count
			, SUM(internal_objects_dealloc_page_count)	AS request_internal_objects_dealloc_page_count 
FROM		sys.dm_db_task_space_usage 
GROUP BY	session_id
			, request_id;
GO


CREATE VIEW all_query_usage
AS
SELECT		R1.session_id
			, R1.request_id
			, R1.request_internal_objects_alloc_page_count
			, R1.request_internal_objects_dealloc_page_count
			, R2.sql_handle
			, R2.statement_start_offset
			, R2.statement_end_offset
			, R2.plan_handle
FROM		all_request_usage R1
INNER JOIN	sys.dm_exec_requests R2 
	ON		R1.session_id = R2.session_id 
	and		R1.request_id = R2.request_id;
GO



SELECT * From all_task_usage
SELECT * From all_session_usage
SELECT * From all_request_usage
SELECT * From all_query_usage




