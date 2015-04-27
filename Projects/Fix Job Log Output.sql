DECLARE		@CMDTable	Table(CMD VarChar(max))	
DECLARE		@CMD		varchar(8000)

;WITH		JobLogFileList
			AS
			(
			SELECT		*
						,CASE dbaadmin.dbo.dbaudf_CheckFileStatus(output_file_name)
							WHEN 0				THEN 'File is Good'
							WHEN -1				THEN 'FileSystemObject could not be created'
							WHEN -2147024809	THEN 'Parameter is Incorrect'
							WHEN -2147023570	THEN 'Logon failure: unknown user name or bad password'
							WHEN -2146828235	THEN 'File Not Found'
							WHEN -2146828212	THEN 'Path not found'
							WHEN -2146828218	THEN 'Permission Denied (in use)'
							WHEN 1				THEN 'Permission Denied (in use)'
							ELSE CAST(dbaadmin.dbo.dbaudf_CheckFileStatus(output_file_name) AS VarChar(50))
							END																						AS [FileStatus]
						,REVERSE(LEFT(REVERSE(output_file_name),CHARINDEX('\',REVERSE(output_file_name))-1))		AS [FileName]
						,REVERSE(STUFF(REVERSE(output_file_name),1,CHARINDEX('\',REVERSE(output_file_name)),''))	AS [Folder]
			FROM		msdb..sysjobsteps
			)
			,BadOutputFiles
			AS
			(
			SELECT		job_id
						,step_id
						,CASE
							WHEN nullif([output_file_name],'') IS NULL								THEN 'No File' 
							WHEN [FileStatus] = 'Path not found'									THEN 'Bad Path'
							WHEN [FileStatus] = 'Logon failure: unknown user name or bad password'	THEN 'Permissions'
							END AS [BadReason]
			FROM		JobLogFileList
			WHERE		NOT([FileStatus] = 'File is Good')
					AND NOT([FileStatus] = 'Permission Denied (in use)')
					AND	NOT([FileStatus] = 'File Not Found')
			)
			,ValidCounts
			AS
			(
			SELECT		T2.[job_id]
						,T2.[output_file_name]
						,COUNT(*) OVER(PARTITION BY T2.[job_id]) [ValidCount]
			FROM		BadOutputFiles		T1
			JOIN		msdb..sysjobsteps	T2
					ON	T1.job_id = T2.job_id
					AND	T1.step_id != T2.step_id
			GROUP BY	T2.[job_id]
						,T2.[output_file_name]
			)
			,AutoFixes
			AS
			(
			SELECT	*
			FROM	ValidCounts									
			WHERE	[ValidCount] = 1					
			)
INSERT INTO @CMDTable			
SELECT		'exec msdb.dbo.sp_update_jobstep @job_id='''+CAST(BO.job_id AS VarChar(50))+''' ,@step_id='+CAST(BO.step_id AS VarChar(10))+' ,@output_file_name='''+AF.output_file_name+''''
FROM		BadOutputFiles BO
JOIN		AutoFixes AF
		ON	AF.job_id = BO.job_id


DECLARE FixStepOutputFile CURSOR
FOR SELECT CMD FROM @CMDTable
OPEN FixStepOutputFile
FETCH NEXT FROM FixStepOutputFile INTO @CMD
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		PRINT @CMD
		--EXEC (@CMD)	
	END
	FETCH NEXT FROM FixStepOutputFile INTO @CMD
END
CLOSE FixStepOutputFile
DEALLOCATE FixStepOutputFile
GO

		