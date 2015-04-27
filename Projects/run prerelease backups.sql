 
:SETVAR	SQLCMD_UserSettings "\SQLCMD_UserSettings.sql"
:SETVAR SQLCMD_GlobalSettings "\\seafresqldba01\DBA_Docs\SQLCMD_GlobalSettings.sql"
GO
:ON ERROR IGNORE
GO
-- DECLARE AND SET USER VARIABLES
:r $(USERPROFILE)$(SQLCMD_UserSettings)
GO
-- DECLARE AND SET GLOBAL VARIABLES
:r $(SQLCMD_GlobalSettings)
GO
 
:OUT STDERR
GO
 
 
PRINT	'------------------------------------------------'
PRINT	'--'
PRINT	'--           SCRIPT EXECUTION RESULTS		 '
PRINT	'--'
PRINT	'------------------------------------------------'
PRINT	'-- RUN BY    $(USERNAME) AT ' + CAST(GetDate() AS VarChar(50))
PRINT	'-- RUN FROM  $(USERDNSDOMAIN).$(COMPUTERNAME)   '
PRINT	'-- USING $(SQLCMDUSER) As Login when needed'
PRINT	'--'
PRINT	'-- USER SETTINGS AT      $(USERPROFILE)$(SQLCMD_UserSettings) '
PRINT	'-- GLOBAL SETTINGS AT    $(SQLCMD_GlobalSettings) '
PRINT	'-- SQLCMDINI AT          $(SQLCMDINI) '
PRINT	'--'
PRINT	'------------------------------------------------'
PRINT	''
GO
 

--exec DEPLcontrol.dbo.dpsp_Approve @gears_id = 47568
--                                 ,@runtype = 'manual'  --'auto'
--                                 ,@DBA_override = 'y'
                                 
                                 

 
:CONNECT SEADCSQLWVA\A,1501 
---U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
PRINT ''
PRINT'-- RUNNING COMMAND'

	DECLARE @RC int
	DECLARE @job_name sysname
	DECLARE @job_status varchar(10)
	DECLARE @run_date VarChar(10)

	SET	@job_name = 'SPCL - PreRelease Backups'

	EXECUTE @RC = [dbaadmin].[dbo].[dbasp_Check_Jobstate] 
	   @job_name
	  ,@job_status OUTPUT

	IF @job_status = 'active'
		PRINT '     Job is Currently Running'
	ELSE
	BEGIN
		SELECT	@run_date = MAX(run_date)
		From	msdb.dbo.sysjobhistory
		WHERE	job_id = (Select job_id FROM msdb.dbo.sysjobs where name = 'SPCL - PreRelease Backups')
		
		IF	@run_date = CONVERT(VarChar(10),getdate(),112)
			PRINT '     Job already Run Today'
		Else
		BEGIN
			exec msdb.dbo.sp_Start_Job @job_name=@job_name
			PRINT '     Job has been Started'
		END
	END
PRINT'-- DONE...'
PRINT ''
GO




:CONNECT SEADCSQLWVB\B,1477 
---U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
PRINT ''
PRINT'-- RUNNING COMMAND'

	DECLARE @RC int
	DECLARE @job_name sysname
	DECLARE @job_status varchar(10)
	DECLARE @run_date VarChar(10)

	SET	@job_name = 'SPCL - PreRelease Backups'

	EXECUTE @RC = [dbaadmin].[dbo].[dbasp_Check_Jobstate] 
	   @job_name
	  ,@job_status OUTPUT

	IF @job_status = 'active'
		PRINT '     Job is Currently Running'
	ELSE
	BEGIN
		SELECT	@run_date = MAX(run_date)
		From	msdb.dbo.sysjobhistory
		WHERE	job_id = (Select job_id FROM msdb.dbo.sysjobs where name = 'SPCL - PreRelease Backups')
		
		IF	@run_date = CONVERT(VarChar(10),getdate(),112)
			PRINT '     Job already Run Today'
		Else
		BEGIN
			exec msdb.dbo.sp_Start_Job @job_name=@job_name
			PRINT '     Job has been Started'
		END
	END
PRINT'-- DONE...'
PRINT ''
GO
 
-- CLEAR USERNAME AND PASSWORD
:setvar SQLCMDUSER 
:setvar SQLCMDPASSWORD 
 




           
           
           
                                     