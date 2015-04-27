declare @Results VarChar (4000);
Declare @runstatus int

select top 1 @Results = sjh.server + '  ' + CAST(sjh.run_date AS VarChar(10)) + '-' + CAST(sjh.run_time AS VarChar(10)) + '  ' + sjh.message 
,@runstatus = sjh.run_status
From msdb..sysjobs sj
join msdb..sysjobhistory sjh
on sj.job_id = sjh.job_id
where sj.name = 'UTIL - PERF Check Non-Use'
and	sjh.step_id = 0
ORDER BY sjh.run_date desc ,sjh.run_time desc

if @runstatus = 0
BEGIN
	PRINT @Results
	--DBCC FREEPROCCACHE
END
