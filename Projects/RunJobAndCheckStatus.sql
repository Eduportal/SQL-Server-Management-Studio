
SET NOCOUNT ON

DECLARE @RC		int
DECLARE @job_name	sysname
DECLARE @job_status	varchar(10)
DECLARE @run_date	VarChar(20)
DECLARE @run_time	VarChar(20)
DECLARE @RunDateTime	DATETIME
DECLARE	@Overide	VarChar(5)
DECLARE @Status		VarChar(8000)
DECLARE @Hours		INT

SET	@Overide	= 'NONE'
SET	@job_name	= 'UTIL - DBA Nightly Processing'
SET	@Hours		= 4

EXECUTE @RC = [dbaadmin].[dbo].[dbasp_Check_Jobstate] 
   @job_name
  ,@job_status OUTPUT

IF @job_status = 'active'
BEGIN
	SET @Status = 'Job is Currently Running'
	IF	@Overide = 'STOP'
		BEGIN
			exec msdb.dbo.sp_Stop_Job @job_name=@job_name
			SET @Status = @Status + CHAR(13)+CHAR(10)+'Job has been Stoped using "STOP" Overide Value'
		END	
END	
ELSE
BEGIN
	SELECT	TOP 1
		@run_date = run_date
		,@run_time = run_time
		,@RunDateTime = dbaadmin.dbo.dbaudf_AgentDateTime2DateTime(run_date,run_time)
	From	msdb.dbo.sysjobhistory
	WHERE	job_id = (Select job_id FROM msdb.dbo.sysjobs where name = @job_name)
	ORDER BY	run_date desc, run_time desc
	
	IF	DATEDIFF(hour,@RunDateTime,getdate()) < @Hours
		BEGIN
			SET @Status ='Job already Run '+CAST(DATEDIFF(hour,@RunDateTime,getdate()) AS VarChar(50)) +' Hours ago at : ' +CAST(@RunDateTime AS VarChar(50))
			IF	@Overide = 'FORCE'
			BEGIN
				exec msdb.dbo.sp_Start_Job @job_name=@job_name
				SET @Status = @Status + CHAR(13)+CHAR(10)+'Job has been Re-Started using "FORCE" Overide Value'
			END
		END					
	Else
	BEGIN
		exec msdb.dbo.sp_Start_Job @job_name=@job_name
		SET @Status = 'Job has been Started'
	END
END
SELECT @Status	
GO