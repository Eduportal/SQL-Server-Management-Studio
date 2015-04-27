
	DECLARE @RC		int
	DECLARE @job_name	sysname
	DECLARE @job_status	varchar(10)
	DECLARE @run_date	VarChar(20)
	DECLARE @run_time	VarChar(20)
	DECLARE	@Overide	VarChar(5)
	DECLARE @Status		VarChar(8000)
	
	SET	@job_name	= 'UTIL - DBA Nightly Processing'


	IF EXISTS(select SQLName,DomainName,SQLEnv From dbaadmin..DBA_ServerInfo WHERE  SQLName = @@ServerName AND DomainName = 'AMER' AND SQLEnv != 'production')
	BEGIN
		EXECUTE @RC = [dbaadmin].[dbo].[dbasp_Check_Jobstate] 
		   @job_name
		  ,@job_status OUTPUT

		IF @job_status = 'active'
		BEGIN
			SET @Status = '	     Job is Currently Running'
		END	
		ELSE
		BEGIN
			SELECT	TOP 1
				@run_date = run_date
				,@run_time = run_time
			From	msdb.dbo.sysjobhistory
			WHERE	job_id = (Select job_id FROM msdb.dbo.sysjobs where name = @job_name)
			ORDER BY	run_date desc, run_time desc
			
			IF	@run_date = CONVERT(VarChar(10),getdate(),112)
				BEGIN
					SET @Status = '	     Job already Run Today at : ' 
						+ STUFF(STUFF(@run_date,7,0,'-'),5,0,'-') + '  ' 
						+ STUFF(STUFF(RIGHT('000000' + @run_time,6),5,0,'.'),3,0,':')  
				END					
			Else
			BEGIN
				exec msdb.dbo.sp_Start_Job @job_name=@job_name
				SET @Status = '	     Job has been Started'
			END
		END
	END
	ELSE
		SELECT @Status = DomainName +'    ' + SQLEnv From dbaadmin..DBA_ServerInfo WHERE  SQLName = @@ServerName
SELECT @Status