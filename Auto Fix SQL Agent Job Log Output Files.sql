--exec dbaadmin.dbo.dbasp_dba_sqlsetup
--select dbaadmin.dbo.dbaudf_getSharePath(UPPER(dbaadmin.dbo.dbaudf_getShareUNC('sqljob_logs')))


DECLARE @CMD VarChar(max)

DECLARE JobLogFixCursor CURSOR
FOR
WITH		JobSteps
		AS
		(
		SELECT		(SELECT name FROM msdb..sysjobs WHERE job_id = T1.job_id)	AS [JobName]
				,(SELECT STUFF(name,1,1,isnull(nullif(LEFT(name,1),'x'),'')) FROM msdb..sysjobs WHERE job_id = T1.job_id) AS [CleanJobName]
				,dbaadmin.dbo.dbaudf_ReturnPart((SELECT STUFF(name,1,1,isnull(nullif(LEFT(name,1),'x'),'')) FROM msdb..sysjobs WHERE job_id = T1.job_id),1) AS [JobNameForLog]
				,*
		FROM		msdb..sysjobsteps T1 WITH(NOLOCK)
		WHERE		subsystem = 'TSQL'
		)
		,CD1
		AS
		(
		SELECT		job_id
				,step_id
				,output_file_name
				,CASE WHEN [CleanJobName] LIKE 'APPL%' THEN 'Yes' ELSE 'No' END					AS [IsApplJob]
				,REPLACE(output_file_name,dbaadmin.dbo.dbaudf_GetFileFromPath(output_file_name),'')		AS [CurrentFolder]
				,dbaadmin.dbo.dbaudf_GetFileFromPath(output_file_name)						AS [CurrentFileName]
				,COALESCE	(
						NULLIF	(
							dbaadmin.dbo.dbaudf_getSharePath(UPPER(dbaadmin.dbo.dbaudf_getShareUNC('sqljob_logs')))
							,'Not Found'
							)
						,dbaadmin.dbo.dbaudf_getShareUNC('sqljob_logs')
						)+'\'										AS [DefaultFolder]
				,dbaadmin.dbo.dbaudf_FilterCharacters	(
									[JobNameForLog]
									,' -/:*?"<>|'
									,'I'
									,'_'
									,1
									)+'.txt'						AS [DefaultFileName]
		FROM		JobSteps
		)
		,Tests
		AS
		(
		SELECT		job_id
				,step_id
				,CASE	WHEN nullif(output_file_name,'') IS NULL THEN'Not Specified'
					ELSE CASE dbaadmin.dbo.dbaudf_GetFileProperty(output_file_name,'file','InUse')
						WHEN '0'			THEN 'File is Good'
						WHEN '1'			THEN 'Permission Denied (in use)'
						WHEN '2'			THEN 'Bad Path or FileName'
						ELSE 'Unknown'
						END				
					END											AS [CurrentFileValidity]
				, CASE WHEN [DefaultFolder] = [CurrentFolder] THEN 'correct' ELSE 'Incorrect' END		AS [CurrentFolderStatus]
				, CASE WHEN [DefaultFileName] = [CurrentFileName] THEN 'correct' ELSE 'Incorrect' END		AS [CurrentFileNameStatus]
		FROM		CD1
		)
		,Results
		AS
		(
		SELECT		JobName
				,step_name
				,T1.[output_file_name]
				,T2.[CurrentFolder]
				,T2.[CurrentFileName]
				,T2.[DefaultFolder]
				,T2.[DefaultFileName]
				,T3.[CurrentFileValidity]
				,T3.[CurrentFolderStatus]
				,T3.[CurrentFileNameStatus]
				,T2.[IsApplJob]
				,T1.[CleanJobName]
				,T1.[JobNameForLog]
				,T1.[job_id]
				,T1.[step_id]
				,T1.[flags]
				,T1.[step_uid]
				,T1.[command]
				,T1.[database_name]
				,DB_ID(T1.[database_name]) [db_id]
				,CASE
					WHEN ISNULL(T1.[output_file_name],'') != T2.[DefaultFolder]+T2.[DefaultFileName] OR T1.[flags] != (T1.[flags]|2|4) OR DB_ID(T1.[database_name]) IS NULL
					THEN 'exec msdb.dbo.sp_update_jobstep @job_id='''+CAST(T1.job_id AS VarChar(50))+''' ,@step_id='+CAST(T1.step_id AS VarChar(10))
						+ CASE
							WHEN ISNULL(T1.[output_file_name],'') != T2.[DefaultFolder]+T2.[DefaultFileName]
							THEN ' ,@output_file_name='''+T2.[DefaultFolder]+T2.[DefaultFileName]+''''
							ELSE '' END
						+ CASE
							WHEN T1.[flags] != (T1.[flags]|2|4)
							THEN ' ,@Flags='+ CAST(CAST((T1.[flags]|2|4) AS INT) AS VarChar(4))
							ELSE '' END
						+ CASE
							WHEN DB_ID(T1.[database_name]) IS NULL
							THEN ' ,@database_name=''Master'''
							ELSE '' END
					ELSE '' END										AS [ChangeCommand]

		FROM		JobSteps T1
		JOIN		CD1 T2
			ON	T1.job_id = T2.job_id
			AND	T1.step_id = T2.step_id
		JOIN		Tests T3
			ON	T1.job_id = T3.job_id
			AND	T1.step_id = T3.step_id
		)

--SELECT * FROM Results ORDER BY 1,2


-- SELECT QUERY FOR CURSOR
SELECT		[ChangeCommand]
FROM		Results
WHERE		nullif([ChangeCommand],'') IS NOT NULL
 

OPEN JobLogFixCursor;
FETCH JobLogFixCursor INTO @CMD;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
	
		EXEC(@CMD)

		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM JobLogFixCursor INTO @CMD;
END
CLOSE JobLogFixCursor;
DEALLOCATE JobLogFixCursor;

--SELECT COALESCE(NULLIF(dbaadmin.dbo.dbaudf_getSharePath(UPPER(dbaadmin.dbo.dbaudf_getShareUNC('sqljob_logs'))),'Not Found'),dbaadmin.dbo.dbaudf_getShareUNC('sqljob_logs'))


--SELECT dbaadmin.dbo.dbaudf_getSharePath('SEASSQLNOE01_sqljob_logs')


-- UPDATE ALL START NEXT JOB STEPS

--SELECT	(SELECT name FROM msdb..sysjobs WHERE job_id = T1.job_id)	AS [JobName],* 
--From msdb..sysjobsteps T1
--where step_name like 'start%'
--and command like '%@currjob_name%'
--and command like '%@nextjob_name%'

--UPDATE msdb..sysjobsteps
--SET command = 
--'Declare @currjob_name sysname
--Declare @nextjob_name sysname

--SELECT @currjob_name  = name
--FROM msdb.dbo.sysjobs
--WHERE Job_id =  CONVERT(uniqueidentifier, $(ESCAPE_SQUOTE(JOBID)))

--Select @nextjob_name = (select top 1 name from msdb..sysjobs where name > @currjob_name order by name)

--Print ''Starting job '' + @nextjob_name

--exec msdb..sp_start_job @job_name = @nextjob_name
--'
--, step_name = 'Start Next Job'
--where step_name like 'start%'
--and command like '%@currjob_name%'
--and command like '%@nextjob_name%'


-- RENAME ALL CALC STREAM JOB NAMES

--Select	REPLACE(STUFF(name,9,0,'-'),'Calc ','Calc | ')
--	,* 
--From msdb..sysjobs
--WHERE name like 'DBA RM%'
--ORDER BY name

--UPDATE msdb..sysjobs
--SET name = REPLACE(STUFF(name,9,0,'-'),'Calc ','Calc | ')
--WHERE name like 'DBA RM%'