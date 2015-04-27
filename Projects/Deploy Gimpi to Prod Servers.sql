 
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
 
 
:CONNECT G1SQLA\A,1252 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
PRINT ''
PRINT'-- RUNNING COMMAND > :r C:\Users\sledridge\Desktop\DeployGimpi.sql
exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport'
:r C:\Users\sledridge\Desktop\DeployGimpi.sql
exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT G1SQLB\B,1893 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
PRINT ''
PRINT'-- RUNNING COMMAND > :r C:\Users\sledridge\Desktop\DeployGimpi.sql
exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport'
:r C:\Users\sledridge\Desktop\DeployGimpi.sql
exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport
PRINT'-- DONE...'
PRINT ''
GO

-- COLLATION PROBLEM

--:CONNECT SEADCASPSQLA\A,1511 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r C:\Users\sledridge\Desktop\DeployGimpi.sql
--exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport'
--:r C:\Users\sledridge\Desktop\DeployGimpi.sql
--exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport
--PRINT'-- DONE...'
--PRINT ''
--GO



:CONNECT SEADCLABSSQL01\A,1166 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
PRINT ''
PRINT'-- RUNNING COMMAND > :r C:\Users\sledridge\Desktop\DeployGimpi.sql
exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport'
:r C:\Users\sledridge\Desktop\DeployGimpi.sql
exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEADCPCSQLA\A,1996 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
PRINT ''
PRINT'-- RUNNING COMMAND > :r C:\Users\sledridge\Desktop\DeployGimpi.sql
exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport'
:r C:\Users\sledridge\Desktop\DeployGimpi.sql
exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEADCSHSQLA\A,4889 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
PRINT ''
PRINT'-- RUNNING COMMAND > :r C:\Users\sledridge\Desktop\DeployGimpi.sql
exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport'
:r C:\Users\sledridge\Desktop\DeployGimpi.sql
exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEADCVISQL01 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
PRINT ''
PRINT'-- RUNNING COMMAND > :r C:\Users\sledridge\Desktop\DeployGimpi.sql
exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport'
:r C:\Users\sledridge\Desktop\DeployGimpi.sql
exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport
PRINT'-- DONE...'
PRINT ''
GO

-- COLLATION PROBLEM

--:CONNECT SEAEXSQLMAIL -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r C:\Users\sledridge\Desktop\DeployGimpi.sql
--exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport'
--:r C:\Users\sledridge\Desktop\DeployGimpi.sql
--exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport
--PRINT'-- DONE...'
--PRINT ''
--GO


:CONNECT SEAPDASSQL01 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
PRINT ''
PRINT'-- RUNNING COMMAND > :r C:\Users\sledridge\Desktop\DeployGimpi.sql
exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport'
:r C:\Users\sledridge\Desktop\DeployGimpi.sql
exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEASDELSQL01 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
PRINT ''
PRINT'-- RUNNING COMMAND > :r C:\Users\sledridge\Desktop\DeployGimpi.sql
exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport'
:r C:\Users\sledridge\Desktop\DeployGimpi.sql
exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport
PRINT'-- DONE...'
PRINT ''
GO
 
-- CLEAR USERNAME AND PASSWORD
:setvar SQLCMDUSER 
:setvar SQLCMDPASSWORD 
 
