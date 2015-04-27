

DECLARE		@DynamicCode		VARCHAR(8000)
			,@JobName			sysname
			,@JobID				UniqueIdentifier
			,@DropLocation		VarChar(8000)
			,@StepScriptFile	VarChar(8000)
			,@StepName			sysname

	SELECT	@JobName		= 'AssetFamilyBackfill_20110818'
			,@DropLocation	= '\\seafresqldba01\appdata\AssetKeyword\20110818_AssetFamilyBackfill' 
			,@JobName		= 'GEARS_SQL_Misc_'+AssetFamilyBackfill_20110818 + '_' + convert(varchar(64),NEWID())
			
	EXECUTE msdb..sp_add_job @JobName, @owner_login_name='sa', @job_id=@JobID OUTPUT
								,@delete_level = 1 -- USE TO AUTO DELETE JOB AFTER SUCCESFULL EXIT
								
	EXECUTE msdb..sp_add_jobserver @job_id=@JobID, @server_name=@@servername


-- STEP START --
--------------------------------------------------------------------------------------------------------------------------------------
	SELECT	@StepName			= ''
			,@StepScriptFile	= '010_Create_tmp_AssetFamilyBackfill_20110818.sql'
			,@DynamicCode		= ''

IF nullif(@StepScriptFile,'') IS NOT NULL
BEGIN
	-- READ SCRIPT FILE INTO JOB SCRIPT --


END

	EXECUTE msdb..sp_add_jobstep @job_id=@JobID, @step_name		= @StepName
			, @command = @DynamicCode, @database_name			= 'master'
			, @on_success_action	= 3 /*1=quit with Success,3=go to next step*/ 
			, @on_fail_action		= 3 /*2=quit with Failure,3=go to next step*/ 
--------------------------------------------------------------------------------------------------------------------------------------
-- STEP END --
		

-- STEP START --
--------------------------------------------------------------------------------------------------------------------------------------
	SELECT	@StepName			= ''
			,@StepScriptFile	= '020_BackfillAssetFamily.sql'
			,@DynamicCode		= ''



	EXECUTE msdb..sp_add_jobstep @job_id=@JobID, @step_name		= @StepName
			, @command = @DynamicCode, @database_name			= 'master'
			, @on_success_action	= 3 /*1=quit with Success,3=go to next step*/ 
			, @on_fail_action		= 3 /*2=quit with Failure,3=go to next step*/ 
--------------------------------------------------------------------------------------------------------------------------------------
-- STEP END --
		
		
		
		
		
		
-- FINAL STEP --
-- STEP START --
--------------------------------------------------------------------------------------------------------------------------------------
	SELECT	@StepName			= 'REPORT JOB RESULTS'
			,@StepScriptFile	= ''
			,@DynamicCode		= ''

	EXECUTE msdb..sp_add_jobstep @job_id=@JobID, @step_name		= @StepName
			, @command = @DynamicCode, @database_name			= 'master'
			, @on_success_action	= 1 /*1=quit with Success,3=go to next step*/ 
			, @on_fail_action		= 2 /*2=quit with Failure,3=go to next step*/ 
--------------------------------------------------------------------------------------------------------------------------------------
-- STEP END --
-- RUN JOB --
	--EXECUTE msdb..sp_start_job @job_id=@JobID



