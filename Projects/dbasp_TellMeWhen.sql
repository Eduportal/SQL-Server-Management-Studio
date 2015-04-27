USE DBAADMIN
GO
SET NOCOUNT ON
go
DROP PROCEDURE	dbasp_TellMeWhen
go
CREATE PROCEDURE	dbasp_TellMeWhen
					(
					@JobName			sysname			= NULL			-- IF NOT NULL PROC CHECKS JOB STATUS
					,@TestQuery			nVarChar(4000)	= NULL			-- IF NOT NULL PROC CHECKS FOR TRUE RESPONCE FROM THIS QUERY TEXT
					,@WhereToNotify		INT				= 0				-- 0 = BOTH , 1 = WORK, 2 = HOME 
					,@StepNumber		INT				= 0				-- 0 = ANY STEP, # = ONLY NOTIFY FOR SINGLE STEP
					,@IntervalDelay		CHAR(8)			= '00:01:00'	-- FORMAT IS HH:MM:SS'
					,@ThenDo			VarChar(max)	= NULL			-- SQL CODE TO ALSO EXECUTE WHEN CONDITIONS ARE MET
					)
AS
BEGIN
	-- Do not lock anything, and do not get held up by any locks. 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON

	DECLARE		@RC					int
	DECLARE		@recipients			nvarchar(500)
	DECLARE		@subject			nvarchar(255)
	DECLARE		@attachments		nvarchar(4000)
	DECLARE		@message			nvarchar(4000)
	DECLARE		@outpath			nvarchar(2000)
	DECLARE		@Result				sql_variant
	DECLARE		@printmessage		VarChar(max)
	DECLARE		@Status				TABLE (job_id UniqueIdentifier, job_name SYSNAME, start_execution_date datetime NULL, step_execution INT, step_execution_date DateTime NULL, job_history_id INT NULL, UserName SYSNAME, Email_Work VarChar(1000), EMail_Phone VarChar(1000))
	DECLARE		@LastStatus			TABLE (job_id UniqueIdentifier, job_name SYSNAME, start_execution_date datetime NULL, step_execution INT, step_execution_date DateTime NULL, job_history_id INT NULL, UserName SYSNAME, Email_Work VarChar(1000), EMail_Phone VarChar(1000))
	DECLARE		@DBAinfo			TABLE (UserName SYSNAME, Email_Work VarChar(1000),Email_Phone VarChar(1000) NULL)
	DECLARE		@UserName			sysname
	SET			@UserName			= STUFF(replace(Suser_Sname(),'\s-','\'),1,CHARINDEX('\',Suser_Sname()),'')
	SET			@TestQuery			= 'SELECT @Result = ('+@TestQuery+')'


	INSERT INTO	@DBAinfo
	SELECT		@UserName													AS UserName
				,@UserName+'@GettyImages.com'								AS Email_Work
				,CASE @UserName
					WHEN 'sledridge' THEN 'steve.ledridge@gmail.com'
					END														AS Email_Phone
					
	CheckAgian:
	
		IF @JobName IS NOT NULL
		BEGIN
			SET		@PrintMessage = 'Checking Job Status'
			exec	dbaadmin.dbo.dbasp_print @PrintMessage,0,1
			
			;WITH		JobActivity
						AS
						(
						select		top 1 with ties 
									a.job_id
									,j.name AS job_name
									,CASE WHEN stop_execution_date IS NULL	THEN start_execution_date ELSE NULL END start_execution_date
									,CASE WHEN start_execution_date IS NULL THEN 0		WHEN stop_execution_date IS NULL THEN COALESCE(last_executed_step_id+1,1)						ELSE 0		END AS step_execution
									,CASE WHEN start_execution_date IS NULL THEN NULL	WHEN stop_execution_date IS NULL THEN COALESCE(last_executed_step_date,start_execution_date)	ELSE NULL	END AS step_execution_date
									,CASE WHEN start_execution_date IS NOT NULL AND stop_execution_date IS NULL THEN a.job_history_id ELSE NULL END job_history_id
						from		msdb..sysjobactivity a
						join		msdb..sysjobs j 
								ON	j.job_id = a.job_id
						order by rank() OVER(ORDER BY a.session_id desc)
						)
			INSERT INTO	@Status
			SELECT		*
			FROM		JobActivity
			CROSS JOIN	@DBAInfo
			WHERE		JobActivity.job_name = @JobName
			
			IF @@ROWCOUNT = 0
			BEGIN
				SET		@PrintMessage = 'No Job Exists with the name "'+@JobName+'"'
				exec	dbaadmin.dbo.dbasp_print @PrintMessage,1,1
				SELECT	DISTINCT name From msdb..sysjobs
				GOTO DoneChecking
			END

			IF EXISTS (SELECT * FROM @Status WHERE step_execution > COALESCE(@StepNumber,0)) AND COALESCE(@StepNumber,0) > 0
			BEGIN
				SET		@PrintMessage = 'Job "'+@JobName+'" has already passed step '+ CAST(@StepNumber AS VarChar(5))
				exec	dbaadmin.dbo.dbasp_print @PrintMessage,1,1
				SELECT	* FROM @Status
				GOTO DoneChecking
			END

			SELECT		@recipients = CASE @WhereToNotify WHEN 1 THEN COALESCE(S1.Email_Work,S2.Email_Work) WHEN 2 THEN COALESCE(S1.Email_Phone,S2.Email_Phone) ELSE COALESCE(S1.Email_Work,S2.Email_Work)+';'+COALESCE(S1.Email_Phone,S2.Email_Phone) END
						,@subject	= 'Job Status Change ON ' + @@SERVERNAME
						,@message	= 'The Job ' +COALESCE(S1.Job_Name,S2.Job_Name)
							+ CASE
								WHEN S1.Job_Name IS Not Null AND S2.Job_Name IS NULL AND S1.step_execution = 0
									THEN ' is not running.'
								WHEN S1.job_name IS Not Null AND S2.job_name IS NULL 
									THEN ' has Started Running step '+CAST(S1.step_execution AS VarChar(5))+' at ' + CAST(S1.step_execution_Date AS VarChar(50))
								WHEN S1.step_execution = 0 AND S2.step_execution != 0
									THEN ' has Finished.'
								WHEN S1.step_execution != S2.step_execution AND (COALESCE(@StepNumber,0) = 0 OR COALESCE(@StepNumber,0) BETWEEN S2.step_execution AND S1.step_execution)
									THEN ' has Changed Steps from step ' + CAST(S2.step_execution AS VarChar(5)) + ' to step ' + CAST(S1.step_execution AS VarChar(5))
								END
						,@PrintMessage	= 'Current Step ' + CAST(S1.step_execution AS VarChar(5)) + ', has been running for ' 
										+ COALESCE(CAST(NULLIF(DATEDIFF(Minute,S1.step_execution_date,getdate())/60,0) AS VarChar(20)) + ' Hour and ','')
										+ CAST(DATEDIFF(Minute,S1.step_execution_date,getdate())-((DATEDIFF(Minute,S1.step_execution_date,getdate())/60)*60) AS VarChar(20)) + ' Minutes.'
			FROM		@Status S1
			FULL JOIN	@LastStatus S2
					ON	S1.Job_id = S2.Job_id

			IF @Message IS NOT NULL
			BEGIN
				exec	dbaadmin.dbo.dbasp_print 'SENDING EMAIL....',1,1
				exec	dbaadmin.dbo.dbasp_print @recipients,2,1
				exec	dbaadmin.dbo.dbasp_print @subject,2,1
				exec	dbaadmin.dbo.dbasp_print @message,2,1

				EXECUTE @RC = [dbaadmin].[dbo].[dbasp_sendmail] @recipients=@recipients,@subject=@subject,@message=@message
			END	

			exec	dbaadmin.dbo.dbasp_print @PrintMessage,1

			IF @message like '%has Finished.' OR @message LIKE '%is not running.' OR @message LIKE '% to step '+CAST(COALESCE(@StepNumber,0) AS VarChar(5))
				Goto DoneChecking

			SET			@message = NULL
			DELETE		@LastStatus
			INSERT INTO	@LastStatus
			SELECT		*
			FROM		@Status

		END
		ELSE IF @TestQuery IS NOT NULL
		BEGIN
			SET		@PrintMessage = 'Checking Query Results.'
			exec	dbaadmin.dbo.dbasp_print @PrintMessage,0
			
			exec	sp_executesql 
						@statement	= @TestQuery
						,@params	= N'@Result sql_variant OUT'
						,@Result	= @Result OUT
			
			SET		@PrintMessage	= 'Running SQL Query Test.'
			exec	dbaadmin.dbo.dbasp_print @PrintMessage,1

			IF CAST(@Result AS INT) = 1
			BEGIN
				SELECT	@message		= 'The SQL Query Test Has Returned a Positive Result.'
						,@subject		= 'SQL Query Test ON ' + @@SERVERNAME
						,@recipients	= CASE @WhereToNotify WHEN 1 THEN Email_Work WHEN 2 THEN Email_Phone ELSE Email_Work+';'+Email_Phone END
				FROM	@DBAinfo

				-- ALWAYS PRINT THIS MESSAGE						
				exec	dbaadmin.dbo.dbasp_print 'SENDING EMAIL....',1,1
				exec	dbaadmin.dbo.dbasp_print @recipients,2,1
				exec	dbaadmin.dbo.dbasp_print @subject,2,1
				exec	dbaadmin.dbo.dbasp_print @message,2,1

				EXECUTE @RC = [dbaadmin].[dbo].[dbasp_sendmail] @recipients=@recipients,@subject=@subject,@message=@message

				Goto DoneChecking
			END	
		END
		ELSE
		BEGIN
			-- ALWAYS PRINT THIS MESSAGE
			SET		@PrintMessage = 'Nothing to Check.'
			exec	dbaadmin.dbo.dbasp_print @PrintMessage,0
			Goto DoneChecking
		END

			SET		@PrintMessage = 'Waiting...'
			exec	dbaadmin.dbo.dbasp_print @PrintMessage,2

			WAITFOR DELAY @IntervalDelay
			
					
	GOTO CheckAgian

	DoneChecking:
END
GO

--EXEC dbaadmin.dbo.dbasp_TellMeWhen	@TestQuery		= 'SELECT COUNT(*) FROM dbaadmin.dbo.sysobjects where name =''swl_test_new'''

EXEC dbaadmin.dbo.dbasp_TellMeWhen	@JobName		= 'UTIL - PERF Stat Capture Process'
									,@StepNumber	= 9

GO
