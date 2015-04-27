
DECLARE		@LogPath	VarChar(max)		= dbaadmin.dbo.dbaudf_getShareUNC('SQLjob_logs')

SELECT		'exec msdb.dbo.sp_update_jobstep @job_id='''+CAST(job_id AS VarChar(50))
					+''' ,@step_id='+CAST(step_id AS VarChar(10))
					+' ,@output_file_name='''+@LogPath+'\'+
					dbaadmin.dbo.dbaudf_FilterCharacters(
					STUFF(LEFT(JobName,3+CHARINDEX('Calc',JobName)),1,1,isnull(nullif(LEFT(LEFT(JobName,3+CHARINDEX('Calc',JobName)),1),'x'),''))
					,' -/:*?"<>|','I','_',1)
					+'.txt'+''''
		,LEFT(JobName,3+CHARINDEX('Calc',JobName))
		,*
FROM		(
		SELECT		*,
					(SELECT name FROM msdb..sysjobs WHERE job_id = T1.job_id)									AS [JobName]
					,CASE dbaadmin.dbo.dbaudf_GetFileProperty(output_file_name,'file','InUse')
						WHEN '0'			THEN 'File is Good'
						WHEN '1'			THEN 'Permission Denied (in use)'
						WHEN '2'			THEN 'Bad Path or FileName'
						ELSE 'Unknown'
						END																						AS [FileStatus]
					,REVERSE(LEFT(REVERSE(output_file_name),CHARINDEX('\',REVERSE(output_file_name))-1))		AS [FileName]
					,REVERSE(STUFF(REVERSE(output_file_name),1,CHARINDEX('\',REVERSE(output_file_name)),''))	AS [Folder]
		FROM		msdb..sysjobsteps T1
		WHERE		NULLIF(output_file_name,'') IS NOT NULL
		UNION ALL
		SELECT		*
				,(SELECT name FROM msdb..sysjobs WHERE job_id = T1.job_id)	AS [JobName]
				,'na'								AS [FileStatus]
				,'na'								AS [FileName]
				,'na'								AS [Folder]
		FROM		msdb..sysjobsteps T1
		WHERE		subsystem in ('LogReader', 'Snapshot')
		UNION ALL
		SELECT		*
				,(SELECT name FROM msdb..sysjobs WHERE job_id = T1.job_id)	AS [JobName]
				,'Null'								AS [FileStatus]
				,NULL								AS [FileName]
				,NULL								AS [Folder]
		FROM		msdb..sysjobsteps T1
		WHERE		NULLIF(output_file_name,'') IS NULL
			AND	subsystem not in ('LogReader', 'Snapshot')
		) Data
WHERE		JobName Like 'DBA%CALC%'