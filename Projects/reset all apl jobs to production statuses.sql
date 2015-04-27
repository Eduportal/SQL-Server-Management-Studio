DECLARE	@TSQL	VarChar(max)
SELECT	@TSQL	= COALESCE(@TSQL,'')
		+ 'exec msdb.dbo.sp_update_job @job_name = ''' + jobname + ''', @enabled = ' + convert(char(1), jobstatus)
		+ CHAR(13)+CHAR(10)
FROM	DEPLinfo.dbo.ProdJobStatus
WHERE	jobname IN (Select name From msdb..sysjobs)
EXEC	(@TSQL)







