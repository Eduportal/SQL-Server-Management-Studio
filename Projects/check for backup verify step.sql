DECLARE @JobID UniqueIdentifier
select @JobID = job_id From msdb..sysjobs WHERE name = 'MAINT - Weekly Backup and DBCC'

SELECT		M1,M2,
		CASE WHEN M1 > M2 THEN @@SERVERNAME ELSE '' END
FROM		(	
		select		MAX(step_id) M1
				,max(case step_name WHEN 'Backup Verify' THEN step_id ELSE 0 END) M2
		From		msdb..sysjobsteps
		WHERE		job_id = @JobId
		) DATA
		
		