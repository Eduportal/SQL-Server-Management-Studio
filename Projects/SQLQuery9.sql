select distinct sj.name,sjs.step_name From msdb.dbo.sysjobs sj 
inner join msdb.dbo.sysjobsteps  sjs
on sj.job_id = sjs.job_id
    where sjs.command like '%SystemInfo%'
    
    
