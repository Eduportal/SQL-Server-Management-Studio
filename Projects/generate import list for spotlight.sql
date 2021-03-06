 
:SETVAR	SQLCMD_UserSettings		"\SQLCMD_UserSettings.sql"
:SETVAR SQLCMD_GlobalSettings	"\\seapsqldba01\DBA_Docs\SQLCMD Scripts\SQLCMD_GlobalSettings.sql"
:SETVAR SQLCMDINI 				"\\seapsqldba01\DBA_Docs\SQLCMD Scripts\SQLCMDINI.sql"
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
--PRINT	'-- RUN FROM  $(USERDNSDOMAIN).$(COMPUTERNAME)   '
PRINT	'--'
PRINT	'-- USING $(SQLCMDUSER) As Login when needed'
PRINT	'--'
PRINT	'-- USER SETTINGS AT      $(USERPROFILE)$(SQLCMD_UserSettings) '
PRINT	'-- GLOBAL SETTINGS AT    $(SQLCMD_GlobalSettings) '
PRINT	'-- SQLCMDINI AT          $(SQLCMDINI) '
PRINT	'--'
PRINT	'------------------------------------------------'
PRINT	''
GO

 
 
/****** Script for SelectTopNRows command from SSMS  ******/
SELECT	[SQLName]
		+ CASE coalesce([DomainName],'amer') WHEN 'amer' THEN '' ELSE ',$(SQLCMDUSER),$(SQLCMDPASSWORD)' END
		--,[DomainName]
		--,[SQLEnv]
		--,(SELECT TOP 1 ENVnum FROM	[dbacentral].[dbo].[DBA_DBInfo] WHERE SQLName = [DBA_ServerInfo].[SQLName]) ENVnum
FROM	[dbacentral].[dbo].[DBA_ServerInfo] 
WHERE	Active = 'Y'
	AND	SQLEnv = 'test'
--ORDER BY 2


	
GO	
