
/*********************************************************
 **  Calculation Integrity Monitor for GINS
 **  -----------------------------------------------------
 **  Written by joanne St Charles, Getty Images            
 **  CREATE Date: June 2009	
 **  
 ** 1) Find and Replace Period_Ending_date criteria 
		-- Last Criteria Used = '04/30/2009'
 ** 
 ** 2) Find and Replace value for Log_datetime criteria 
		-- Last Criteria Used = '2009-06-02 22:10:00'
**********************************************************
 **                         Change History
 *********************************************************
 ** Date		Author		Description
 ** ------------------------------------------------------
 ** 06/02/2009	Jo St Charles Initial Create Date
 ** 12/29/2014 JDS - modified for Alliant 6.2
**********************************************************/
USE GINS
-------------------------------------------------------
-- Display errors from this run to-date, per criteria
-- Includes Errors on Templates Stmnts, and PDFs
-------------------------------------------------------
Select S.Process_server_Name, * from batch_manager_log l with (Nolock)
join c_batch_process p on p.batch_process_sid = l.batch_Process_sid
join process_server s on s.process_server_sid = l.process_server_sid
where 
( log_text like '%exceed%'
or log_text like '%Excel%'
or log_text like '% warn %' 
or log_text like '%error %' 
or log_text like '%error:%' 
or log_text like '% hold %' 
or log_text like '% fail %'
or log_text like '% link %'
--or log_text like '% incomplete %'
or log_text like '% released %'
)
and log_text not like '%debug%'
and log_text not like '%incomplete%'
--and log_text like '%parameter%'-- '%communication link failure%'-- incomplete%') 
and log_datetime 
> '2014-12-09 10:07:00'
and batch_process_id in ('Statement','Template' , 'STATEMENT','RESOLVER')
order by log_datetime desc;



------------------------------------------
-- Display current process servers loads  
-- and Log Date times
-- Specify Templates, Stmnts, or PDFs
------------------------------------------
Select S.Process_server_name, service_nbr, batch_process_id , max(log_datetime)  as Log_Datetime
from batch_manager_log l with (Nolock)
join c_batch_process P on p.batch_process_sid = l.batch_process_sid
join process_server s on s.process_server_sid = l.process_server_sid
where log_datetime  >  '2014-12-09 10:07:00'
and P.batch_process_id in ('TEMPLATE')
-- and batch_process_code in ('STATEMENT')
-- and batch_process_code in ('PDFSTMT')
group by 
Process_server_name, batch_process_id, service_nbr
order by max(log_datetime);



------------------------------------------
-- Which contracts are Currently running?
------------------------------------------
Select 
C.contract_id, 
C.descr, 
U.Contract_group_flag, 
Process_server_name, 
Batch_Process_id, 
U.service_nbr, 
U.appl_sid, 
U.Error_flag, 
U.modified_datetime
from GINS_master.dbo.x_contract_in_use U with (nolock) 
join GINS_master.dbo.x_contract C with (Nolock)
	on C.contract_sid = U.Contract_or_group_sid
join process_server s on s.process_server_sid = U.process_server_sid
join c_batch_process P on p.batch_process_sid = U.batch_process_sid
-- order by U.Batch_process_code, U.modified_datetime,  U.Process_server_name
order by Process_server_name, Service_nbr;


------------------------------------------
-- of those currently running
-- how long did that take last period
-- ***** Set your own period criteria *** 
------------------------------------------
-- BEGIN SELECT 
Declare		@LastPeriod_sid		int
		,@ThisPeriod_sid	int
		,@LastPeriod_EndDate	DateTime
		,@ThisPeriod_EndDate	DateTime

SELECT		@ThisPeriod_EndDate	= MAX(period_ending_date) 
from		GINS_master.dbo.x_period 
where		period_ending_date < GetDate()

SELECT		@LastPeriod_EndDate	= MAX(period_ending_date) 
from		GINS_master.dbo.x_period 
where		period_ending_date < @ThisPeriod_EndDate

SELECT		@ThisPeriod_sid = (Select period_sid from GINS_master.dbo.x_period where period_ending_date = @ThisPeriod_EndDate)
		,@LastPeriod_sid = (Select period_sid from GINS_master.dbo.x_period where period_ending_date = @LastPeriod_EndDate)

;WITH		SummaryData
		AS
		(
		Select		CAST(MONTH(end_datetime) AS VarChar(2))			[MONTH]
				,CAST(DAY(end_datetime) AS VarChar(2))			[DAY]
				,CAST(DATEPART(hour,end_datetime) AS VarChar(2))	[HOUR]
				,COUNT(*)						[TOTAL_DEALS]
				,sum(datediff (ss, start_datetime, end_datetime))	[TOTAL_SECONDS]
		from		GINS_master.dbo.x_deal_calc_msg 
		where		period_sid = @ThisPeriod_sid
		group by	MONTH(end_datetime)
				,DAY(end_datetime)
				,DATEPART(hour,end_datetime)
		)
		SELECT		[MONTH]
				,[DAY]
				,[HOUR]
				,dbaadmin.dbo.dbaudf_FormatNumber([TOTAL_DEALS],15,0) [TOTAL_DEALS]
				,dbaadmin.dbo.dbaudf_FormatNumber([TOTAL_SECONDS],15,0) [TOTAL_SECONDS]
		FROM		SummaryData
		UNION ALL
		SELECT		'TOTAL'
				,''
				,''
				,dbaadmin.dbo.dbaudf_FormatNumber(SUM([TOTAL_DEALS]),15,0)
				,dbaadmin.dbo.dbaudf_FormatNumber(SUM([TOTAL_SECONDS]),15,0)
		FROM		SummaryData
		order by	1,2,3
		



;WITH		SummaryData
		AS
		(
		Select		CAST(MONTH(end_datetime) AS VarChar(2))			[MONTH]
				,CAST(DAY(end_datetime) AS VarChar(2))			[DAY]
				,CAST(DATEPART(hour,end_datetime) AS VarChar(2))	[HOUR]
				,COUNT(*)						[TOTAL_DEALS]
				,sum(datediff (ss, start_datetime, end_datetime))	[TOTAL_SECONDS]
		from		GINS_master.dbo.x_deal_calc_msg 
		where		period_sid = @LastPeriod_sid
		group by	MONTH(end_datetime)
				,DAY(end_datetime)
				,DATEPART(hour,end_datetime)
		)
		SELECT		[MONTH]
				,[DAY]
				,[HOUR]
				,dbaadmin.dbo.dbaudf_FormatNumber([TOTAL_DEALS],15,0) [TOTAL_DEALS]
				,dbaadmin.dbo.dbaudf_FormatNumber([TOTAL_SECONDS],15,0) [TOTAL_SECONDS]
		FROM		SummaryData
		UNION ALL
		SELECT		'TOTAL'
				,''
				,''
				,dbaadmin.dbo.dbaudf_FormatNumber(SUM([TOTAL_DEALS]),15,0)
				,dbaadmin.dbo.dbaudf_FormatNumber(SUM([TOTAL_SECONDS]),15,0)
		FROM		SummaryData
		order by	1,2,3



;With		LastPeriod_Deals (Deal_sid,start_datetime,end_datetime,Seconds) 
		as 
		(
		Select		deal_sid
				,min(start_datetime) as start_datetime
				,max(end_datetime) as end_datetime
				,sum(datediff (ss, start_datetime, end_datetime)) as seconds 
		from		GINS_master.dbo.x_deal_calc_msg 
		where		period_sid = @LastPeriod_sid
		group by	deal_sid
		)
		,ThisPeriod_Deals (Deal_sid,start_datetime,end_datetime,Seconds) 
		as 
		(
		Select		deal_sid
				,min(start_datetime) as start_datetime
				,max(end_datetime) as end_datetime
				,sum(datediff (ss, start_datetime, end_datetime)) as seconds 
		from		GINS_master.dbo.x_deal_calc_msg 
		where		period_sid = @ThisPeriod_sid
		group by	deal_sid
		)

Select		C.contract_id
		,C.descr
		,U.Contract_group_flag
		,Process_server_name
		,Batch_Process_id
		,U.service_nbr
		,U.appl_sid
		,U.Error_flag
		,U.modified_datetime
		,CONVERT(varchar, (DateDiff(s, U.modified_datetime, getdate()) / 86400))                --Days
		    + ':' +
		    CONVERT(varchar, DATEADD(ss, DateDiff(s, U.modified_datetime, getdate()), 0), 108) as  Current_Days_hrs_min_sec
		,CONVERT(varchar, (LastPeriod_Deals.seconds / 86400))                --Days
		    + ':' +
		    CONVERT(varchar, DATEADD(ss, LastPeriod_Deals.seconds, 0), 108) as LastMonth_Days_hrs_min_sec

		,CONVERT(varchar, (ThisPeriod_Deals.seconds / 86400))                --Days
		    + ':' +
		    CONVERT(varchar, DATEADD(ss, ThisPeriod_Deals.seconds, 0), 108) as ThisMonth_Days_hrs_min_sec
		


from		GINS_master.dbo.x_contract_in_use U with (nolock) 
join		GINS_master.dbo.x_contract C with (Nolock)
	on	C.contract_sid = U.Contract_or_group_sid
join		GINS_master.dbo.x_deal D	
	on	D.contract_sid = C.contract_sid
	and	D.deal_id = 'STATEMENT'
join		process_server s 
	on	s.process_server_sid = U.process_server_sid
join		c_batch_process P 
	on	p.batch_process_sid = U.batch_process_sid
left join	LastPeriod_Deals 
	on	LastPeriod_Deals.deal_sid = D.Deal_sid
left join	ThisPeriod_Deals 
	on	ThisPeriod_Deals.deal_sid = D.Deal_sid


--order by	Process_server_name, Service_nbr
ORDER BY	ThisPeriod_Deals.end_datetime ,U.modified_datetime desc
-- END SELECT







-- Select top 10 * from GINS_master.dbo.x_contract_in_use

--------------------------------------------
-- Stats on what has been picked up
-- Includes for Templates, Stmnts and PDFs
-- Note Change period ending date criteria
--------------------------------------------
--Declare 
--	@Period_ending_date as datetime,
--	@Period_sid as Int;
--Set @Period_ending_date = '11/30/2014';
--Select @period_sid = 
--	(Select period_sid 
--	from GINS_master.dbo.x_period with (Nolock)
--	where period_ending_date = @Period_ending_date
--	)
Select batch_process_id, count(*)
From GINS_master.dbo.x_job_queue q with (Nolock)
join c_batch_process b on b.batch_process_sid = q.batch_process_sid
join c_status S on S.status_sid = q.status_sid
Where start_relative_to_period_sid = @ThisPeriod_sid
	and batch_Process_id <> 'IMPORT'
	and Status_id in ('RUNNING', 'COMPLETE')
Group by batch_process_id
Order by batch_process_id;

------------------------------------------------
-- WHICH contracts templates have been picked up
-- (whether or not they are still running) 
-- Includes Templates
------------------------------------------------
Select * 
,Substring(log_text, (CHARINDEX(': ',log_text)+ 2), (CHARINDEX(';', log_text) - CHARINDEX(': ',log_text)-2)  )
from batch_manager_log BM2 with (Nolock)
join c_batch_process B on B.batch_process_sid = BM2.batch_process_sid
join process_server p on p.process_server_sid = BM2.process_server_sid
Where bm2.log_datetime  >  '2014-12-09 10:07:00'
	and batch_process_id in ('TEMPLATE')
	and BM2.log_text like 'service started job contract%'
order by bm2.log_datetime desc, 
Process_server_name, service_nbr;


---------------------------------------------------------------------------
-- how many are complete
-- Includes Templates, Stmts, and PDFs
-- CHANGE period Ending Date Criteria to the ending date of the calc period
---------------------------------------------------------------------------
Declare 
	@Period_ending_date as datetime,
	@Period_sid as Int;
Set @Period_ending_date = '11/30/2014';
Select @period_sid = 
	(Select period_sid 
	from GINS_master.dbo.x_period with (Nolock)
	where period_ending_date = @Period_ending_date
	)
Select Batch_Process_id, status_id, count(job_queue_sid)
From GINS_master.dbo.x_job_queue J with (nolock)
join c_status S on S.status_sid = J.Status_sid
join c_batch_process b on b.batch_process_sid = j.batch_Process_sid
Where  start_relative_to_period_sid = @Period_sid
and batch_Process_id <> 'IMPORT'
and Status_id = 'COMPLETE'
group by Batch_Process_id, status_id;

-- Select top 100 * from GINS_master.dbo.x_job_queue 
--------------------------------
-- WHICH contracts are complete
-- Includes templates
--------------------------------
Select s.Process_server_name, service_nbr, batch_process_id , log_datetime, 
BM1.log_text
from batch_manager_log BM1 with (Nolock)
join c_batch_process P 
on P.batch_process_sid = BM1.batch_process_sid
join process_server s on s.process_server_sid = BM1.process_server_sid
where 
batch_process_id in ('TEMPLATE')
and BM1.log_text like '%service ended job contract%'
and log_datetime > '2014-12-09 10:07:00'
order by Process_server_name, service_nbr;


---------------------------------
-- specifics on a given contract
-- Update Contract Criteria 
-- Optionally filter types of entries
---------------------------------
Select Process_server_name, service_nbr, batch_process_id , log_datetime, 
BM1.log_text
from batch_manager_log BM1 with (nolock)
join process_server s on s.process_server_sid = BM1.process_server_sid
join c_batch_process B on B.batch_process_sid = BM1.batch_process_sid
where 
log_text like '%5056725%'
-- and batch_process_id in ('TEMPLATE')
  and log_datetime > '2014-12-09 10:07:00'
order by log_datetime,Process_server_name, service_nbr;


--------------------------------------------
-- Overall Stats on current calc processes
-- Note Change period ending date criteria
-- 
-- This is similar to Sched Tasks window but faster and 
-- will not mess up hourly statistics
--------------------------------------------
Declare 
	@Period_ending_date as datetime,
	@Period_sid as Int;
Set @Period_ending_date = '11/30/2014';
Select @period_sid = 
	(Select period_sid 
	from GINS_master.dbo.x_period with (Nolock)
	where period_ending_date = @Period_ending_date
	)
Select batch_process_id, status_id, count(*)
From GINS_master.dbo.x_job_queue q with (Nolock)
join c_batch_process p on p.batch_process_sid = q.batch_process_sid
join c_status S on s.status_sid = q.status_sid
Where start_relative_to_period_sid = @Period_sid
	and batch_Process_id <> 'IMPORT'
Group by batch_process_id, status_id
Order by status_id, batch_process_id;


-----------------------------------------------------
-- Get HOURS amd MIN since calc kick off time
-- Based on the Log_datetime criteria given
-- This can be handy if the Calc stats window closes
------------------------------------------------------
Declare @ExactStartTime as datetime;
Select @ExactStartTime = min(log_datetime)
from batch_manager_log l with (Nolock)
join c_batch_process P on P.batch_process_sid = l.batch_process_sid
where log_datetime  >  '2014-12-09 10:07:00'
and batch_process_id in ('TEMPLATE')
Select 'Given a Template start time of ' + Convert(varchar(20), @exactStartTime, 100) 
+ ' we''ve had:  ' +
Cast(cast(datediff (hh, 
	@ExactStartTime,Getdate()) as decimal (10,0)) as varchar(3)) 
	+ ' Hrs' + ' ' +
cast(Case when (datediff (mi, DATEADD ( hh , cast(datediff (hh, 
	@ExactStartTime,Getdate()) as decimal (10,0)), 
	@ExactStartTime),Getdate()))
 < 0 then (60 + (Select datediff (mi, DATEADD ( hh , cast(datediff (hh, 
	@ExactStartTime,Getdate()) as decimal (10,0)), 
	@ExactStartTime),Getdate())))
Else (Select datediff (mi, DATEADD ( hh , cast(datediff (hh, 
	@ExactStartTime,Getdate()) as decimal (10,0)), 
	@ExactStartTime),Getdate()))
END as varchar(3))
	+ ' Mins run time as of  ' +  Convert(varchar(20),getdate(), 100);

----------------------------------------
-- Monitoring the Resolve Queue AKA COM
----------------------------------------
use GINS_master;
Select resolving_process_table_name , count(1) from x_resolve_queue 
group by resolving_process_table_name;  

Select count(1) from x_resolve_queue ;

