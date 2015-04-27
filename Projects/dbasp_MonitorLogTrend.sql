use dbaperf
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[dbasp_MonitorLogTrend]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[dbasp_MonitorLogTrend]
GO

create procedure dbo.dbasp_MonitorLogTrend
 	@StartDate datetime = '1970-01-01',
 	@EndDate datetime = null
as
/*******************************************************************************************************
*	dbo.dbasp_MonitorLogTrend.PRC 
*
*	Description:   produce a result set of daily sp_monitor results for a specified time period
*
*	Usage:
	     EXECUTE dbaperf.dbo.dbasp_MonitorLogTrend -- all
	     EXECUTE dbaperf.dbo.dbasp_MonitorLogTrend '2003.07.06', '2003.07.13'-- one week
*
*
*	Modifications   
*	 name		   date		  description
*	-------		----------	------------------------------------------------------------
*	Steve Ledridge	09/10/2013	New Procedure
********************************************************************************************************/
declare @msPerTick float
declare @CPU_count Int

set nocount on

print 'Column name - Description 
Date - Time sp_monitor was executed. 
Seconds - Number of elapsed seconds since sp_monitor was run. 
CPU Busy - Number of seconds that the server computer''s CPU has been doing SQL Server work. 
I/O Busy - Number of seconds that SQL Server has spent doing input and output operations. 
Idle - Number of seconds that SQL Server has been idle. 
Packets Received - Number of input packets read by SQL Server. 
Packets Sent - Number of output packets written by SQL Server. 
Packet Errors - Number of errors encountered by SQL Server while reading and writing packets. 
Total Reads - Number of reads by SQL Server. 
Total Write - Number of writes by SQL Server. 
Total Errors - Number of errors encountered by SQL Server while reading and writing. 
Connections - Number of logins or attempted logins to SQL Server.' 

/*
**  Set @mspertick.  This is just used to make the numbers easier to handle
**  and avoid overflow.
*/
SELECT		@mspertick = CAST(@@TIMETICKS AS float) / 1000.0
		,@CPU_count = cpu_count 
FROM		sys.dm_os_sys_info

select
	[Date]			= s1.lastrun, --CAST(convert(varchar(16),s1.lastrun)AS DATETIME) ,
	[Seconds]		= datediff(ss, s2.lastrun, s1.lastrun),
	[CPU Busy]		= (((s1.cpu_busy - coalesce(s2.cpu_busy,0)) * @mspertick)*100)/datediff(ms, s2.lastrun, s1.lastrun),
	[I/O Busy]		= (((s1.io_busy - coalesce(s2.io_busy,0)) * @mspertick)*100)/datediff(ms, s2.lastrun, s1.lastrun),
	[Idle]			= ((((s1.idle/@CPU_count) - (coalesce(s2.idle,0)/@CPU_count)) * @mspertick)*100)/datediff(ms, s2.lastrun, s1.lastrun),
	[Packets Received]	= s1.pack_received - s2.pack_received,
	[Packets Sent]		= s1.pack_sent - s2.pack_sent,
	[Packet Errors]		= s1.pack_errors - s2.pack_errors,
	[Total Reads]		= s1.total_read - s2.total_read,
	[Total Writes]		= s1.total_write - s2.total_write,
	[Total Errors]		= s1.total_errors - s2.total_errors,
	[Connections]		= s1.connections - s2.connections
 --select *
from dbaperf.dbo.MonitorHistory s1
left join dbaperf.dbo.MonitorHistory s2
on s1.Id = s2.Id + 1
where s1.lastrun between @StartDate and coalesce(@EndDate,getdate())
and s1.cpu_busy > s2.cpu_busy
and s1.io_busy > s2.io_busy
and s1.idle > s2.idle
order by s1.lastrun desc


GO

EXECUTE dbaperf.dbo.dbasp_MonitorLogTrend
GO


select *
from dbaperf.dbo.MonitorHistory

select		cpu_count
FROM		sys.dm_os_sys_info