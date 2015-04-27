DECLARE @CMD nvarchar(1000)
IF substring(@@VERSION,22,4) = '2005'
SET @CMD = '
select top 60 record_id, dateadd(ms, -1 * ((cpu_ticks / convert(float, cpu_ticks_in_ms ))- timestamp), getdate())  as EventTime,
          SQLProcessUtilization [SQL CPU],
          SystemIdle,
          100 - SystemIdle - SQLProcessUtilization as [Other CPU]
     from (
          select
              record.value(''(./Record/@id)[1]'', ''int'') as record_id,
               record.value(''(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]'', ''int'') as SystemIdle,
               record.value(''(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]'', ''int'') as SQLProcessUtilization,
              timestamp
          from (
              select timestamp, convert(xml, record) as record
              from sys.dm_os_ring_buffers
              where ring_buffer_type = N''RING_BUFFER_SCHEDULER_MONITOR''
              and record like ''%<SystemHealth>%'') as x
          ) as y cross join sys.dm_os_sys_info
     order by record_id desc'
     ELSE
SET @CMD = 'select top 60 record_id,
                   dateadd (ms, timestamp - ms_ticks, getdate()) as EventTime,
          SQLProcessUtilization [SQL CPU],
          SystemIdle,
          100 - SystemIdle - SQLProcessUtilization as [Other CPU]
     from (
          select
              record.value(''(./Record/@id)[1]'', ''int'') as record_id,
               record.value(''(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]'', ''int'') as SystemIdle,
               record.value(''(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]'', ''int'') as SQLProcessUtilization,
              timestamp
          from (
              select timestamp, convert(xml, record) as record
              from sys.dm_os_ring_buffers
              where ring_buffer_type = N''RING_BUFFER_SCHEDULER_MONITOR''
              and record like ''%<SystemHealth>%'') as x
          ) as y cross join sys.dm_os_sys_info
     order by record_id desc '
EXEC sp_executesql @CMD


declare @ms_now bigint
 select @ms_now = ms_ticks from sys.dm_os_sys_info;
select top 15 record_id,
  dateadd(ms, -1 * (@ms_now - [timestamp]), GetDate()) as EventTime, 
  SQLProcessUtilization,
  SystemIdle,
  100 - SystemIdle - SQLProcessUtilization as OtherProcessUtilization
 from (
  select 
   record.value('(./Record/@id)[1]', 'int') as record_id,
   record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') as SystemIdle,
   record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') as SQLProcessUtilization,
   timestamp
  from (
   select timestamp, convert(xml, record) as record 
   from sys.dm_os_ring_buffers 
   where ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
   and record like '%<SystemHealth>%') as x
  ) as y 
 order by record_id desc