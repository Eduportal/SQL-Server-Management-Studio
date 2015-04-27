SELECT		*
FROM		(
		SELECT p.spid, j.name, DATEDIFF(SECOND,aj.start_execution_date,GetDate())/60./60 AS Hours
		FROM   master.dbo.sysprocesses p 
		JOIN   msdb.dbo.sysjobs j ON 
		   master.dbo.fn_varbintohexstr(convert(varbinary(16), job_id)) COLLATE Latin1_General_CI_AI = 
		   substring(replace(program_name, 'SQLAgent - TSQL JobStep (Job ', ''), 1, 34)
		JOIN msdb..sysjobactivity aj
		on j.job_id = aj.job_id
		WHERE aj.stop_execution_date IS NULL -- job hasn't stopped running
		AND aj.start_execution_date IS NOT NULL -- job is currently running
		--AND j.name = 'JobX'
		and not exists( -- make sure this is the most recent run
		    select 1
		    from msdb..sysjobactivity new
		    where new.job_id = aj.job_id
		    and new.start_execution_date > aj.start_execution_date
		)
		) Data
WHERE		Hours > 1
