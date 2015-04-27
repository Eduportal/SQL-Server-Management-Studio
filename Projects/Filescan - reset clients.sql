:CONNECT ASPSQLDEV01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT ASPSQLDEV01\A02
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT ASPSQLLOAD01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT ASPSQLLOAD01\A02
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT ASPSQLTEST01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT ASPSQLTEST01\A02
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT CATSQLDEV01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT CATSQLDEV01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT CRMSQLDEV01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT CRMSQLDEV02
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT CRMSQLTEST01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT CRMSQLTEST02
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT DAPSQLDEV01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT DAPSQLTEST01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT DEVSHSQL01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT DEVSHSQL02\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT DLVRSQLDEV01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT DLVRSQLDEV01\A02
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT DLVRSQLTEST01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT DLVRSQLTEST01\A02
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREAASPSQL01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREAGMSSQL01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREAGMSSQL01\B
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREAGMSSQL01\HGA
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREAPCXSQL01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREASHLSQL01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREASHWSQL01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREDCRMSQL01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREDMRTSQL01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREDMRTSQL01\B
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREDMRTSQL02\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREDMRTSQL02\B
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREDRZTSQL01\A01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREDRZTSQL01\A03
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREDSQLEDW01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREDSQLSRM01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREDSQLTOL01\A01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRELASPSQL02\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRELGMSSQLA\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRELGMSSQLB\B
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRELLNPSQL01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRELRZTSQL01\A03
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRELSHLSQL01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREPDPMBAK01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREPSQLEDW01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREPSQLGLB01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREPSQLRYLA01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREPSQLRYLA11
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREPSQLRYLA12
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREPSQLRYLA13
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREPSQLRYLA15
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREPSQLRYLB01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREPSQLRYLB11
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREPSQLRYLB12
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREPSQLRYLB13
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREPSQLRYLB14
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREPSQLRYLB15
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREPSQLRYLI01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREPSQLRYLR01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FREPTSSQL01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRESCRMSQL01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRESCRMSQL02
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRESEDSQL0A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRESSQLEDW01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRESSQLRYL01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRESSQLRYL11
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRESSQLRYL12
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRETCRMSQL01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRETMRTSQL01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRETMRTSQL01\B
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRETMRTSQL02\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRETMRTSQL02\B
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRETRZTSQL01\A01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRETRZTSQL01\A02
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRETRZTSQL01\A03
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRETSCOMRPTSQL1
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRETSCOMSQL01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRETSQLCTX01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRETSQLDIP02
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRETSQLEDW01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRETSQLRYL02
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT FRETSQLRYL03
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GINSSQLDEV01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GINSSQLDEV02\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GINSSQLDEV04\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GINSSQLTEST01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GINSSQLTEST02\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GINSSQLTEST03\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GINSSQLTEST04\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GMSSQLDEV01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GMSSQLDEV01\B
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GMSSQLDEV01\HGA
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT gmssqldev04\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT gmssqldev04\B
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT gmssqldev04\HGA
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GMSSQLLOAD02\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GMSSQLLOAD02\B
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GMSSQLLOAD02\HGA
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GMSSQLTEST01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GMSSQLTEST01\B
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GMSSQLTEST01\HGA
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GMSSQLTEST02\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GMSSQLTEST02\B
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GMSSQLTEST02\HGA
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GMSSQLTEST03\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GMSSQLTEST03\B
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GMSSQLTEST03\HGA
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GMSSQLTEST04\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GMSSQLTEST04\B
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT GMSSQLTEST04\HGA
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT MSSQLDEV01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT MSSQLTEST01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT NYCMVSQLDEV01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT PCSQLDEV01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT PCSQLDEV01\A02
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT PCSQLLOAD02\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT PCSQLLOADA\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT PCSQLTEST01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT PCSQLTEST01\A02
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEADCCSO01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEADCSQLC01A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEADCSQLWVA\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEADCSQLWVB\B
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFREAPPNOE01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFREDWDMSDD01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFREDWDMSPD01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRENOETIXTST
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQL01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLBOA
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLBOT01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLBOT01\HGA
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLBOT01\TEST
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLDBA01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLDWARCH
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLDWD01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLDWP01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLDWT01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLIBMDIR
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLIMMGR
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLMOMA\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLMOMRP
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLPROJ01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLRF01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLRGAPP1
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLRGAPP2
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLRGAPP3
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLRGAPP4
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLRGAPP5
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLRGDB
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLRPT01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLSB01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLSHRA\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLSTGDAP
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLT01\DEV
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLT01\STAGE
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLT01\TEST
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLTAL04
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLTAL05
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLTALS01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLTALS02
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLTALTST
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLWVSTGA\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESQLWVSTGB\B
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESRSD01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESRSP01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAFRESRST01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEALABSSQL01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAPDWDCSQLD0A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAPDWDCSQLP0A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAPEDSQL0A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAPSCOMACSSQL1
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAPSECDB01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAPSQLSHR02A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAPSQLTFS0A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAPSQLWBS01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAPTRCSQLA\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAPVMWSUS01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEASTRCSQLA
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEATESTHARNESS
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEATESTHARNESS2
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAVMSQLDWFTST1
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAVMSQLMOMT01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SEAVMSQLMSDEV01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SHAREDSQLLOAD01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SHAREDSQLLOAD02\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT sqldeployer01
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SQLDEPLOYER02
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT sqldeployer03
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT SQLDEPLOYER04
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT TESTSHSQL01\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
:CONNECT TESTSHSQL02\A
GO
 
USE [msdb]
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
sp_purge_jobhistory @job_name = 'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_start_job @job_name=N'DBA - Test LogParser'
GO
 
GO
 
