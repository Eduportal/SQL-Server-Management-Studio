USE dbaadmin
GO

IF OBJECT_ID('dbasp_FixJobLogOutputFiles') IS NOT NULL
	DROP PROCEDURE dbo.dbasp_FixJobLogOutputFiles
GO

CREATE PROCEDURE dbo.dbasp_FixJobLogOutputFiles
						(
						@NestLevel					INT		= 0
						,@Verbose					INT		= 0
						,@PrintOnly					INT		= 0
						)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET	NOCOUNT ON
	SET ANSI_WARNINGS ON
	
											
	--DECLARE		@NestLevel					INT
	--DECLARE		@Verbose					INT
	--DECLARE		@PrintOnly					INT

	--SELECT		@NestLevel					= 1
	--			,@Verbose					= 0
	--			,@PrintOnly					= 0
				

				
	DECLARE		@CheckDate					DateTime
	DECLARE		@EnableCodeComments			INT
	DECLARE		@save_EnableCodeComments	INT
	DECLARE		@PrintWidth					INT
	DECLARE		@MSG						VARCHAR(MAX)
	DECLARE		@StatusPrint				INT
	DECLARE		@DebugPrint					INT
	DECLARE		@OutputPrint				INT

	DECLARE		@CMDTable					Table	(
													[CMD]						VarChar(MAX),
													[RevertCMD]					VarChar(MAX)
													)	
	DECLARE		@CMD						varchar	(8000)
	DECLARE		@RevertCMD					varchar	(8000)
	DECLARE		@share_name					varchar	(100)
	DECLARE		@LogPath					VarChar	(8000)
	DECLARE		@JobLogFileList				TABLE	(
													[job_id]					[uniqueidentifier]	NOT	NULL,
													[step_id]					[int]				NOT	NULL,
													[step_name]					[sysname]			NOT	NULL,
													[subsystem]					[nvarchar](40)		NOT	NULL,
													[command]					[nvarchar](MAX)		NULL,
													[flags]						[int]				NOT	NULL,
													[additional_parameters]		[ntext]				NULL,
													[cmdexec_success_code]		[int]				NOT	NULL,
													[on_success_action]			[tinyint]			NOT	NULL,
													[on_success_step_id]		[int]				NOT	NULL,
													[on_fail_action]			[tinyint]			NOT	NULL,
													[on_fail_step_id]			[int]				NOT	NULL,
													[server]					[sysname]			NULL,
													[database_name]				[sysname]			NULL,
													[database_user_name]		[sysname]			NULL,
													[retry_attempts]			[int]				NOT	NULL,
													[retry_interval]			[int]				NOT	NULL,
													[os_run_priority]			[int]				NOT	NULL,
													[output_file_name]			[nvarchar](200)		NULL,
													[last_run_outcome]			[int]				NOT NULL,
													[last_run_duration]			[int]				NOT NULL,
													[last_run_retries]			[int]				NOT NULL,
													[last_run_date]				[int]				NOT NULL,
													[last_run_time]				[int]				NOT NULL,
													[proxy_id]					[int]				NULL,
													[step_uid]					[uniqueidentifier]	NULL,
													[JobName]					[sysname]			NULL,
													[FileStatus]				[varchar](50)		NULL,
													[FileName]					[nvarchar](200)		NULL,
													[Folder]					[nvarchar](4000)	NULL
													)


				
	-- SET VALUE IF IT DOES NOT EXIST
	IF NOT EXISTS (SELECT value FROM fn_listextendedproperty('EnableCodeComments', default, default, default, default, default, default))
		EXEC sys.sp_addextendedproperty		@Name = 'EnableCodeComments', @value = 0

	SELECT		@PrintWidth					= 80
				,@OutputPrint				= CASE WHEN @Verbose >= 0 THEN 1 ELSE 0 END
				,@StatusPrint				= CASE WHEN @Verbose >  0 THEN 1 ELSE 0 END
				,@DebugPrint				= CASE WHEN @Verbose >  1 THEN 1 ELSE 0 END
				,@CheckDate					= GetDate()
				,@share_name				=  REPLACE(@@SERVERNAME,'\','$') + '_SQLjob_logs'
				,@EnableCodeComments		= CASE @DebugPrint WHEN 1 THEN 1 ELSE 0 END
				,@save_EnableCodeComments	= COALESCE(CAST([value] AS INT),0)
	FROM	fn_listextendedproperty('EnableCodeComments', default, default, default, default, default, default)


											
	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint
	SELECT @MSG='STARTING '+COALESCE(CAST(Objectpropertyex(@@Procid,'BaseType')AS SYSNAME),'')+COALESCE(', ['+CAST(Object_Name(@@Procid)AS SYSNAME)+']',''),@MSG=REPLICATE(' ',(@PrintWidth-LEN(@MSG))/2)+@MSG;EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint
	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint

	EXEC	sys.sp_updateextendedproperty	@Name	= 'EnableCodeComments'
											,@value	= @EnableCodeComments

	SELECT @MSG='PREVIOUS "EnableCodeComments" VALUE WAS '+CASE @save_EnableCodeComments WHEN 1 THEN 'ON' ELSE 'OFF' END ,@MSG='DEBUG: '+REPLICATE(' ',(@PrintWidth-7-LEN(@MSG)))+@MSG;EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@DebugPrint
	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@DebugPrint
	SELECT @MSG='DATABASE EXTENDED PROPERTY "EnableCodeComments" IS ENABLED',@MSG=REPLICATE(' ',(@PrintWidth-LEN(@MSG))/2)+@MSG;EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel

	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint
	SELECT @MSG='GETTING PATH FOR SQLJOB_LOG SHARE',@MSG=REPLICATE(' ',(@PrintWidth-LEN(@MSG))/2)+@MSG;EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint
	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint
	EXEC		dbaadmin.dbo.dbasp_get_share_path @share_name = @share_name, @phy_path = @LogPath OUT

	SELECT @MSG='@LogPath = '+QUOTENAME(CAST(@LogPath AS VarChar(max)),'"'),@MSG='DEBUG: '+REPLICATE(' ',(@PrintWidth-7-LEN(@MSG)))+@MSG;EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@DebugPrint
	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@DebugPrint

	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint
	SELECT @MSG='GETTING JOB STEP DATA',@MSG=REPLICATE(' ',(@PrintWidth-LEN(@MSG))/2)+@MSG;EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint
	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint

	INSERT INTO	@JobLogFileList
	SELECT		*
				,(SELECT name FROM msdb..sysjobs WHERE job_id = T1.job_id)									AS [JobName]
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
	FROM		msdb..sysjobsteps T1

	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint
	SELECT @MSG='GENERATING OUTPUT COMMANDS',@MSG=REPLICATE(' ',(@PrintWidth-LEN(@MSG))/2)+@MSG;EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint
	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint
	;WITH		BadOutputFiles
				AS
				(
				SELECT		job_id
							,JobName
							,step_id
							,step_uid
							,CASE
								WHEN nullif([output_file_name],'') IS NULL									THEN 'No File'
								WHEN [FileStatus] = 'Path not found'
								 AND dbaadmin.dbo.dbaudf_GetFileProperty([Folder],'Folder','Name') IS NULL	THEN 'Bad Path'
								WHEN [FileStatus] = 'Path not found'										THEN 'Bad FileName'
								WHEN [FileStatus] = 'Logon failure: unknown user name or bad password'		THEN 'Permissions'
								ELSE [FileStatus]
								END AS [BadReason]
							,[FileName]
							,[Folder]
							,[output_file_name]
				FROM		@JobLogFileList
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
						AND	T2.step_uid NOT IN (SELECT step_uid FROM BadOutputFiles)
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

	-- CURRENT OUTPUT_FILE_NAME IS BAD OR MISSING AND OTHER STEPS IN JOB ONLY REFER TO ONE OTHER GOOD OUTPUT_FILE_NAME
	SELECT		'exec msdb.dbo.sp_update_jobstep @job_id='''+CAST(B.job_id AS VarChar(50))
					+''' ,@step_id='+CAST(B.step_id AS VarChar(10))
					+' ,@output_file_name='''+F.output_file_name+''''
				,'exec msdb.dbo.sp_update_jobstep @job_id='''+CAST(B.job_id AS VarChar(50))
					+''' ,@step_id='+CAST(B.step_id AS VarChar(10))
					+' ,@output_file_name='''+B.output_file_name+''''	
	FROM		BadOutputFiles B
	JOIN		AutoFixes F
			ON	F.job_id = B.job_id

	-- NO OUTPUT_FILE_NAME SPECIFIED
	UNION 
	SELECT		'exec msdb.dbo.sp_update_jobstep @job_id='''+CAST(B.job_id AS VarChar(50))
					+''' ,@step_id='+CAST(B.step_id AS VarChar(10))
					+' ,@output_file_name='''+@LogPath+'\'+
					dbaadmin.dbo.dbaudf_FilterCharacters(
					STUFF(JobName,1,1,isnull(nullif(LEFT(JobName,1),'x'),''))
					,' -/:*?"<>|','I','_',1)
					+'.txt'+''''
				,'exec msdb.dbo.sp_update_jobstep @job_id='''+CAST(B.job_id AS VarChar(50))
					+''' ,@step_id='+CAST(B.step_id AS VarChar(10))
					+' ,@output_file_name='''''	
	FROM		BadOutputFiles B
	WHERE		B.BadReason = 'No File'
			AND	job_id NOT IN (Select job_id FROM AutoFixes)

	-- BAD CHARACTER IN FILE NAME
	UNION
	SELECT		'exec msdb.dbo.sp_update_jobstep @job_id='''+CAST([job_id] AS VarChar(50))
					+ ''' ,@step_id='+CAST([step_id] AS VarChar(10))
					+ ' ,@output_file_name='''+[Folder]+'\'
					+ dbaadmin.dbo.dbaudf_FilterCharacters([FileName],' -/:*?"<>|','I','_',1)+''''
				,'exec msdb.dbo.sp_update_jobstep @job_id='''+CAST(B.job_id AS VarChar(50))
					+''' ,@step_id='+CAST(B.step_id AS VarChar(10))
					+' ,@output_file_name='''+B.output_file_name+''''	
	FROM		BadOutputFiles B
	WHERE		BadReason='Bad FileName'
			AND [FileName] != dbaadmin.dbo.dbaudf_FilterCharacters([FileName],' -/:*?"<>|','I','',1)
			AND	job_id NOT IN (Select job_id FROM AutoFixes)

	-- MISSING SUBDIRECTORY UNDER LOG SHARE
	UNION 
	SELECT		'exec xp_CMDShell ''mkdir ' + [Folder] + ''''
				,''
	FROM		BadOutputFiles B
	WHERE		BadReason='Bad Path'
			AND	[Folder] LIKE @LogPath+'%'
			AND	job_id NOT IN (Select job_id FROM AutoFixes)

	IF @@ROWCOUNT = 0 GOTO NoFixesNeeded

	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint
	SELECT @MSG='START GENERATING OUTPUT',@MSG=REPLICATE(' ',(@PrintWidth-LEN(@MSG))/2)+@MSG;EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint
	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint
	SELECT @MSG=CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,0,@StatusPrint

	EXEC dbaadmin.dbo.dbasp_Print	'GO'																	,@NestLevel,0,@OutputPrint
	EXEC dbaadmin.dbo.dbasp_Print	'DECLARE	@RevertCMD		Bit'										,@NestLevel,0,@OutputPrint
	EXEC dbaadmin.dbo.dbasp_Print	'SET		@RevertCMD		= 0'										,@NestLevel,0,@OutputPrint
	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@OutputPrint
	SELECT @MSG='CHANGE @RevertCMD VALUE TO 1 AND RERUN TO REVERT CHANGES',@MSG=REPLICATE(' ',(@PrintWidth-LEN(@MSG))/2)+@MSG;EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@OutputPrint
	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@OutputPrint

	DECLARE FixStepOutputFile CURSOR
	FOR SELECT '	'+CMD,'	'+RevertCMD FROM @CMDTable
	OPEN FixStepOutputFile
	FETCH NEXT FROM FixStepOutputFile INTO @CMD, @RevertCMD
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			EXEC dbaadmin.dbo.dbasp_Print	''																,@NestLevel,0,@OutputPrint
			EXEC dbaadmin.dbo.dbasp_Print	'IF @RevertCMD = 0'												,@NestLevel,0,@OutputPrint
			EXEC dbaadmin.dbo.dbasp_Print	@CMD															,@NestLevel,0,@OutputPrint

			IF @PrintOnly = 0
			BEGIN
				SET @NestLevel = @NestLevel + 1
				SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@OutputPrint
				SELECT @MSG='STATEMENT WAS EXECUTED.',@MSG=REPLICATE(' ',(@PrintWidth-LEN(@MSG))/2)+@MSG;EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@OutputPrint
				SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@OutputPrint
				EXEC (@CMD)
				SET @NestLevel = @NestLevel - 1
			END	

			EXEC dbaadmin.dbo.dbasp_Print	'IF @RevertCMD = 1'												,@NestLevel,0,@OutputPrint
			EXEC dbaadmin.dbo.dbasp_Print	@RevertCMD														,@NestLevel,0,@OutputPrint		
		END
		FETCH NEXT FROM FixStepOutputFile INTO @CMD, @RevertCMD
	END
	CLOSE FixStepOutputFile
	DEALLOCATE FixStepOutputFile

	SELECT @MSG=CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,0,@StatusPrint
	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint
	SELECT @MSG='DONE GENERATING OUTPUT',@MSG=REPLICATE(' ',(@PrintWidth-LEN(@MSG))/2)+@MSG;EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint
	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint

	EXEC	sys.sp_updateextendedproperty	@Name	= 'EnableCodeComments'
											,@value	= @EnableCodeComments

	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint
	SELECT @MSG='EXITING '+COALESCE(CAST(Objectpropertyex(@@Procid,'BaseType')AS SYSNAME),'')+COALESCE(', ['+CAST(Object_Name(@@Procid)AS SYSNAME)+']',''),@MSG=REPLICATE(' ',(@PrintWidth-LEN(@MSG))/2)+@MSG;EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint
	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@StatusPrint
											
	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@DebugPrint
	SELECT @MSG='DATABASE EXTENDED PROPERTY "EnableCodeComments" IS STILL ENABLED',@MSG=REPLICATE(' ',(@PrintWidth-LEN(@MSG))/2)+@MSG;EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel
	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@DebugPrint

	GOTO ExitProcess

	NoFixesNeeded:

	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@OutputPrint
	SELECT @MSG='***  NO FIXES WERE NEEDED  ***',@MSG=REPLICATE(' ',(@PrintWidth-LEN(@MSG))/2)+@MSG;EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@OutputPrint
	SELECT @MSG=REPLICATE('-',@PrintWidth);EXEC dbaadmin.dbo.dbasp_Print @MSG,@NestLevel,1,@OutputPrint

	ExitProcess:	
END										
GO

		