/*
Use dbaperf
go


select * from [dbo].[tempdb_filestats_log]
where rundate > getdate()-55
and file_id = 1
order by  rundate desc
go

select * from [dbo].[tempdb_sessionstats_log]
where rundate > getdate()-5
order by  rundate desc
go


use tempdb
go
SELECT t1.session_id, t1.request_id, t1.task_alloc,
  t1.task_dealloc, t2.sql_handle, t2.statement_start_offset, 
  t2.statement_end_offset, t2.plan_handle
FROM (Select session_id, request_id,
    SUM(internal_objects_alloc_page_count) AS task_alloc,
    SUM (internal_objects_dealloc_page_count) AS task_dealloc 
  FROM sys.dm_db_task_space_usage 
  GROUP BY session_id, request_id) AS t1, 
  sys.dm_exec_requests AS t2
WHERE t1.session_id = t2.session_id
  AND (t1.request_id = t2.request_id)
ORDER BY t1.task_alloc DESC
Go


use tempdb
GO
SELECT
SUM (user_object_reserved_page_count)*8 as usr_obj_kb,
SUM (internal_object_reserved_page_count)*8 as internal_obj_kb,
SUM (version_store_reserved_page_count)*8  as version_store_kb,
SUM (unallocated_extent_page_count)*8 as freespace_kb,
SUM (mixed_extent_page_count)*8 as mixedextent_kb
FROM sys.dm_db_file_space_usage
Go

SELECT top 5 *
FROM sys.dm_db_task_space_usage
ORDER BY (user_objects_alloc_page_count +
internal_objects_alloc_page_count) DESC
go

--These next queries are user DB specific
select top 100 * from sys.conversation_endpoints
ORDER BY lifetime desc
--for EditorialSireDb the count was 6.3 million
--for EventServiceDb the count was 65.5 million

SELECT TOP 10 * FROM sys.transmission_queue
--for EventServiceDb the count was over 131 million


select state,COUNT(*) 
from sys.conversation_endpoints WITH(NOLOCK)
Group By State 


select transmission_status,COUNT(*) 
from sys.transmission_queue WITH(NOLOCK)
Group By transmission_status 

select * from sys.service_broker_endpoints


*/

exec sp_whoisactive

GO




DECLARE @CH	UniqueIdentifier
DECLARE @CH2	VarChar(50)
DECLARE @Count	INT
DECLARE ClosedCoversationCursor CURSOR
FOR
-- SELECT QUERY FOR CURSOR
select	conversation_handle 
from	sys.conversation_endpoints 
where	state = 'DO' 

SET @COUNT = 0
OPEN ClosedCoversationCursor;
FETCH ClosedCoversationCursor INTO @CH;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
		SET @COUNT = @COUNT + 1;
		if @COUNT >= 1000
		BEGIN
			RAISERROR('Cleand Up 1000 Conversation',-1,-1) WITH NOWAIT
			SET @COUNT = 0

		END
		END CONVERSATION @CH WITH CLEANUP

		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM ClosedCoversationCursor INTO @CH;
END
CLOSE ClosedCoversationCursor;
DEALLOCATE ClosedCoversationCursor;



