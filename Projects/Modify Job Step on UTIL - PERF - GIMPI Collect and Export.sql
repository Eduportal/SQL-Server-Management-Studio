USE [msdb]
GO
	DECLARE @job_id uniqueidentifier

	SELECT @job_id = job_id From msdb..sysjobs WHERE name = 'UTIL - PERF - GIMPI Collect and Export'

	EXEC msdb.dbo.sp_update_jobstep @job_id=@job_id, @step_id=1 , 
			@command=N'exec dbaadmin.dbo.dbasp_CreateAllDBViews
	exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport'
GO


-- EXEC msdb.dbo.sp_start_job @job_name = 'UTIL - PERF - GIMPI Collect and Export'