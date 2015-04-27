 
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
 
--/* 
--:CONNECT ASPSQLDEV01\A,1392
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT ASPSQLDEV01\A02,1475
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT ASPSQLLOAD01\A,1793
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT ASPSQLLOAD01\A02,2036
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT ASPSQLTEST01\A,1361
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT ASPSQLTEST01\A02,1617
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT CATSQLDEV01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT CATSQLDEV01\A,4331
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT CRMSQLDEV01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT CRMSQLDEV02
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT CRMSQLTEST01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT CRMSQLTEST02
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT DAPSQLDEV01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT DAPSQLTEST01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT DEVSHSQL01\A,1252
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT DEVSHSQL02\A,1252
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
----:CONNECT FREAASPSQL01\A
----PRINT ''
----PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
----:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
----PRINT'-- DONE...'
----PRINT ''
----GO
--:CONNECT FREAGMSSQL01\A,1252
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREAGMSSQL01\B,1893
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREAGMSSQL01\HGA,2082
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
----:CONNECT FREAPCXSQL01\A,1149
----PRINT ''
----PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
----:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
----PRINT'-- DONE...'
----PRINT ''
----GO
----:CONNECT FREASHLSQL01\A,1615
----PRINT ''
----PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
----:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
----PRINT'-- DONE...'
----PRINT ''
----GO
----:CONNECT FREASHWSQL01\A
----PRINT ''
----PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
----:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
----PRINT'-- DONE...'
----PRINT ''
----GO
--:CONNECT FRECASPSQL01\A,3447
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRECGMSSQLA01\A,3382
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRECGMSSQLB01\B,2591
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRECGMSSQLB01\HGA,2665
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRECPCXSQL01\A,1149
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
----:CONNECT FRECSHLSQL01\A,1615
----PRINT ''
----PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
----:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
----PRINT'-- DONE...'
----PRINT ''
----GO
--:CONNECT FRECSHWSQL01\A,1834
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREDCRMSQL01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREDMRTSQL01\A,1578
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREDMRTSQL01\B,2169
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREDMRTSQL02\A,1313
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREDMRTSQL02\B,1754
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREDRZTSQL01\A01,1252
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREDRZTSQL01\A02,1893
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREDRZTSQL01\A03,2082
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREDSQLDIST01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREDSQLEDW01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
----:CONNECT FREDSQLSRM01
----PRINT ''
----PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
----:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
----PRINT'-- DONE...'
----PRINT ''
----GO
--:CONNECT FREDSQLTAX01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREDSQLTOL01\A01,4173
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRELASPSQL02\A,1197
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRELGMSSQLA\A,1454
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRELGMSSQLB\B,1799
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRELLNPSQL01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRELRZTSQL01\A01,1627
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRELRZTSQL01\A02,1858
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRELRZTSQL01\A03,2043
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRELSHLSQL01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPDPMBAK01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPHYPERSQL01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPSQLDWARCH
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPSQLEDW01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPSQLGLB01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPSQLNOE01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPSQLRYLA01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPSQLRYLA11
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPSQLRYLA12
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPSQLRYLA13
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPSQLRYLA14
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPSQLRYLA15
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPSQLRYLB01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPSQLRYLB11
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPSQLRYLB12
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPSQLRYLB13
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPSQLRYLB14
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPSQLRYLB15
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPSQLRYLI01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPSQLRYLR01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FREPTSSQL01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRESCRMSQL01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRESCRMSQL02
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRESDBASQL01 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRESEDSQL0A
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRESSHLSQL01\A -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRESSQLDIST0A
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRESSQLEDW01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRESSQLRYL01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRESSQLRYL11
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRESSQLRYL12
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRESSQLRYLI01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRETCRMSQL01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRETHYPERSQL01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRETMRTSQL01\A,2033
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRETMRTSQL01\B,2218
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRETMRTSQL02\A,1168
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRETMRTSQL02\B,1283
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
----:CONNECT FRETRZTSQL01\A01,1252
----PRINT ''
----PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
----:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
----PRINT'-- DONE...'
----PRINT ''
----GO
----:CONNECT FRETRZTSQL01\A02,1893
----PRINT ''
----PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
----:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
----PRINT'-- DONE...'
----PRINT ''
----GO
----:CONNECT FRETRZTSQL01\A03,2082
----PRINT ''
----PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
----:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
----PRINT'-- DONE...'
----PRINT ''
----GO
--:CONNECT FRETSBRSQL01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRETSCOMRPTSQL1
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRETSCOMSQL01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRETSQLCTX01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRETSQLDIP02
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRETSQLDIST01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRETSQLEDW01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRETSQLNOE01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRETSQLRYL02
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRETSQLRYL03
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRETSQLRYLI02
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRETSQLRYLI03
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT FRETSQLTAX01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT G1SQLA\A,1252 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT G1SQLB\B,1893 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GINSSQLDEV01\A,1101
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GINSSQLDEV02\A,1101
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GINSSQLDEV04\A,1119
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GINSSQLTEST01\A,1126
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GINSSQLTEST02\A,1124
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GINSSQLTEST03\A,1101
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GINSSQLTEST04\A,1111
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GMSSQLDEV01\A,1252
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GMSSQLDEV01\B,1893
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GMSSQLDEV01\HGA,2082
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
----:CONNECT GMSSQLDEV02\A,1494
----PRINT ''
----PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
----:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
----PRINT'-- DONE...'
----PRINT ''
----GO
----:CONNECT GMSSQLDEV02\B,1676
----PRINT ''
----PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
----:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
----PRINT'-- DONE...'
----PRINT ''
----GO
----:CONNECT GMSSQLDEV02\HGA,1792
----PRINT ''
----PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
----:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
----PRINT'-- DONE...'
----PRINT ''
----GO
--:CONNECT GMSSQLDEV04\A,1226
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GMSSQLDEV04\B,1311
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GMSSQLDEV04\HGA,1383
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GMSSQLLOAD02\A,1395
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GMSSQLLOAD02\B,1683
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GMSSQLLOAD02\HGA,1868
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GMSSQLTEST01\A,1252
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GMSSQLTEST01\B,1893
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GMSSQLTEST01\HGA,2082
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GMSSQLTEST02\A,1252
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GMSSQLTEST02\B,1893
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GMSSQLTEST02\HGA,2082
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GMSSQLTEST03\A,1463
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GMSSQLTEST03\B,1654
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GMSSQLTEST03\HGA,1713
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GMSSQLTEST04\A,1252
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GMSSQLTEST04\B,1893
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GMSSQLTEST04\HGA,2082
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GONESSQLA\A,1252 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT GONESSQLB\B,1893 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT MSSQLDEV01\A,1085
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT MSSQLTEST01\A,3844
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT NYMVSQLDEV02
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
----:CONNECT PCSQLDEV01\A,1253
----PRINT ''
----PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
----:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
----PRINT'-- DONE...'
----PRINT ''
----GO
----:CONNECT PCSQLDEV01\A02,3861
----PRINT ''
----PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
----:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
----PRINT'-- DONE...'
----PRINT ''
----GO
--:CONNECT PCSQLLOAD02\A,2652
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT PCSQLLOADA\A,2335
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT PCSQLTEST01\A,1213
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT PCSQLTEST01\A02,1298
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT SEADCASPSQLA\A,1511 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT SEADCBLACKBRY01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT SEADCCSO01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT SEADCLABSSQL01\A,1166 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT SEADCPCSQLA\A,1996 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT SEADCSHSQLA\A,4889 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT SEADCSQLC01A
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT SEADCSQLWVA\A,1501
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT SEADCSQLWVB\B,1477
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
----:CONNECT SEADCVISQL01 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
----PRINT ''
----PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
----:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
----PRINT'-- DONE...'
----PRINT ''
----GO
--:CONNECT SEAEXSQLMAIL -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT SEAEXSQLMOM03 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT SEAFREAPPNOE01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT SEAFREDWDMSDD01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT SEAFREDWDMSPD01
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO */
----:CONNECT SEAFRENOETIXTST
----PRINT ''
----PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
----:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
----PRINT'-- DONE...'
----PRINT ''
----GO
:CONNECT SEAFRESQL01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLBOA
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLBOT01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLBOT01\HGA,2082
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLBOT01\TEST,3261
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLDBA01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLDWARCH
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLDWD01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLDWP01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLDWT01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLIBMDIR
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLIMMGR
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLMOMA\A,2210
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLMOMRP
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLPROJ01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLRF01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLRPT01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLSB01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLSHRA\A,1271
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLSTGDAP
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLT01\DEV,1900
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLT01\STAGE,1218
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLT01\TEST,1168
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLTAL04
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLTAL05
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLTALS01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLTALS02
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLTALTST
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLWVSTGA\A,1501
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESQLWVSTGB\B,2104
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESRSD01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESRSP01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAFRESRST01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
--:CONNECT SEAFRESTGSQL -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
:CONNECT SEAINTRASQL01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEALABSSQL01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAPDASSQL01 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAPDWDCSQLD0A
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAPDWDCSQLP0A
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAPEDSQL0A
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAPHWUSQL01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAPSCOMSQLA
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAPSCOMSQLDWA
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAPSECDB01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
--:CONNECT SEAPSHLSQL0A\A -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
:CONNECT SEAPSQLCTX01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAPSQLDIP01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAPSQLDIST0A
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAPSQLMVINT01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAPSQLSHR02A
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAPSQLSPS0A
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAPSQLTFS0A
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAPSQLWBS01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAPTRCSQLA\A,1608
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAPVMWSUS01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEASDELSQL01 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEASTGASPSQLA\A,4175 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEASTGPCSQLA\A,2272 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEASTGSHSQLA\A,1558 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEASTRCSQLA
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEATESTHARNESS
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEATESTHARNESS2
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAVMSQLDWFTST1
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SEAVMSQLMSDEV01\A,2763
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
--:CONNECT SEAVMSQLWVLOAD1\A,1198
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
--:CONNECT SEAVMSQLWVLOAD1\B,1290
--PRINT ''
--PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
--:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
--PRINT'-- DONE...'
--PRINT ''
--GO
:CONNECT SHAREDSQLLOAD01\A,2023
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SHAREDSQLLOAD02\A,2508
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SQLDEPLOYER01
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SQLDEPLOYER02
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SQLDEPLOYER03
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SQLDEPLOYER04
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT SQLDEPLOYER05
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT TESTSHSQL01\A,1252
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
:CONNECT TESTSHSQL02\A,1252
PRINT ''
PRINT'-- RUNNING COMMAND > :r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"'
:r "\\SEAFRESQLDBA01\DBA_Docs\SQLCMD Scripts\write db builds into registry.sql"
PRINT'-- DONE...'
PRINT ''
GO
 
-- CLEAR USERNAME AND PASSWORD
:setvar SQLCMDUSER 
:setvar SQLCMDPASSWORD 
 
