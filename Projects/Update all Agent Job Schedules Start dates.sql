

SELECT 'exec sp_update_jobschedule @job_id = '''+cast(sjs.job_id as varchar(50))+''',@name = '''+ss.name+''',@Active_start_date = 20130101'
from sysschedules ss
join sysjobschedules sjs
 on ss.schedule_id = sjs.schedule_id

