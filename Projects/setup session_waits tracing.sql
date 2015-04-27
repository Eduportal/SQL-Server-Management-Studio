--CHECKPOINT;
--GO
--DBCC DROPCLEANBUFFERS;
--GO
--DBCC FREEPROCCACHE
--GO


--DBCC TRACEON(3004,3605,-1)
--DBCC TRACESTATUS
--DBCC TRACEOFF(3004,3605,-1)
GO



SELECT SUM(pending_disk_io_count) AS [Number of pending I/Os] FROM sys.dm_os_schedulers 

SELECT *  FROM sys.dm_io_pending_io_requests

SELECT DB_NAME(database_id) AS [Database],[file_id], [io_stall_read_ms],[io_stall_write_ms],[io_stall] 
FROM sys.dm_io_virtual_file_stats(NULL,NULL) 



DROP event session session_waits on server

create event session session_waits on server
add event sqlos.wait_info
(WHERE sqlserver.session_id=57 and duration>0)
, add event sqlos.wait_info_external
(WHERE sqlserver.session_id=57 and duration>0)
add target package0.asynchronous_file_target
      (SET filename=N'c:\wait_stats.xel', metadatafile=N'c:\wait_stats.xem');


alter event session session_waits on server state = start;




alter event session session_waits on server state = stop;



select * from sys.fn_xe_file_target_read_file
      ('c:\wait_stats*.xel', 'c:\wait_stats*.xem', null, null)


create view dbo.read_xe_file as
select object_name as event, CONVERT(xml, event_data) as data
from sys.fn_xe_file_target_read_file
('c:\wait_stats*.xel', 'c:\wait_stats*.xem', null, null)
go
 
create view dbo.xe_file_table as
select
      event
      , data.value('(/event/data/text)[1]','nvarchar(50)') as 'wait_type'
      , data.value('(/event/data/value)[3]','int') as 'duration'
      , data.value('(/event/data/value)[6]','int') as 'signal_duration'
from dbo.read_xe_file
go
 
select
      wait_type
      , sum(duration) as 'total_duration'
      , sum(signal_duration) as 'total_signal_duration'
from dbo.xe_file_table
group by wait_type
order by sum(duration) desc
go