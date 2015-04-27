:CONNECT ASPSQLDEV01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT ASPSQLDEV01\A02
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT ASPSQLLOAD01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT ASPSQLLOAD01\A02
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT ASPSQLTEST01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT ASPSQLTEST01\A02
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT CATSQLDEV01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT CATSQLDEV01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT CRMSQLDEV01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT CRMSQLDEV02
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT CRMSQLTEST01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT CRMSQLTEST02
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT DAPSQLDEV01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT DAPSQLTEST01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT DEVSHSQL01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT DEVSHSQL02\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREAASPSQL01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREAGMSSQL01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREAGMSSQL01\B
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREAGMSSQL01\HGA
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREAPCXSQL01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREASHLSQL01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREASHWSQL01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREDCRMSQL01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREDMRTSQL01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREDMRTSQL01\B
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREDMRTSQL02\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREDMRTSQL02\B
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREDRZTSQL01\A01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREDRZTSQL01\A03
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREDSQLEDW01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREDSQLSRM01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREDSQLTOL01\A01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRELASPSQL02\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRELGMSSQLA\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRELGMSSQLB\B
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRELLNPSQL01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRELRZTSQL01\A03
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRELSHLSQL01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREPSQLEDW01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREPSQLGLB01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREPSQLRYLA01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREPSQLRYLA11
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREPSQLRYLA13
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREPSQLRYLB11
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREPSQLRYLB12
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREPSQLRYLB13
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREPSQLRYLB14
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREPSQLRYLB15
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREPSQLRYLI01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREPSQLRYLR01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FREPTSSQL01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRESCRMSQL01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRESCRMSQL02
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRESEDSQL0A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRESSQLEDW01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRESSQLRYL01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRESSQLRYL11
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRESSQLRYL12
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRETCRMSQL01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRETMRTSQL01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRETMRTSQL01\B
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRETMRTSQL02\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRETMRTSQL02\B
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRETRZTSQL01\A01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRETRZTSQL01\A02
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRETRZTSQL01\A03
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRETSCOMRPTSQL1
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRETSCOMSQL01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRETSQLCTX01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRETSQLDIP02
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRETSQLEDW01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRETSQLRYL02
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT FRETSQLRYL03
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GINSSQLDEV01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GINSSQLDEV02\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GINSSQLDEV04\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GINSSQLTEST01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GINSSQLTEST02\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GINSSQLTEST03\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GINSSQLTEST04\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLDEV01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLDEV01\B
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLDEV01\HGA
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLDEV04\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLDEV04\B
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLDEV04\HGA
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLLOAD02\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLLOAD02\B
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLLOAD02\HGA
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLTEST01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLTEST01\B
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLTEST01\HGA
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLTEST02\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLTEST02\B
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLTEST02\HGA
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLTEST03\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLTEST03\B
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLTEST03\HGA
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLTEST04\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLTEST04\B
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT GMSSQLTEST04\HGA
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT MSSQLDEV01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT MSSQLTEST01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT NYCMVSQLDEV01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT PCSQLDEV01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT PCSQLDEV01\A02
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT PCSQLLOAD02\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT PCSQLLOADA\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT PCSQLTEST01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT PCSQLTEST01\A02
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEADCCSO01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEADCSQLC01A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEADCSQLWVB\B
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFREAPPNOE01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFREDWDMSDD01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFREDWDMSPD01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRENOETIXTST
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQL01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLBOA
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLBOT01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLBOT01\HGA
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLBOT01\TEST
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLDWARCH
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLDWD01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLDWP01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLDWT01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLIBMDIR
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLIMMGR
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLMOMA\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLPROJ01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLRF01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLSB01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLSHRA\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLSTGDAP
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLT01\DEV
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLT01\STAGE
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLT01\TEST
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLTAL04
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLTAL05
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLTALS01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLTALS02
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLTALTST
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLWVSTGA\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESQLWVSTGB\B
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESRSD01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAFRESRST01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEALABSSQL01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAPDWDCSQLD0A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAPDWDCSQLP0A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAPEDSQL0A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAPSCOMACSSQL1
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAPSECDB01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAPSQLWBS01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAPTRCSQLA\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAPVMWSUS01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEASTRCSQLA
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEATESTHARNESS
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEATESTHARNESS2
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAVMSQLDWFTST1
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAVMSQLMOMT01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAVMSQLMSDEV01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAVMSQLWVLOAD1\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SEAVMSQLWVLOAD1\B
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SHAREDSQLLOAD01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SHAREDSQLLOAD02\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SQLDEPLOYER01
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SQLDEPLOYER02
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SQLDEPLOYER03
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT SQLDEPLOYER04
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT TESTSHSQL01\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
:CONNECT TESTSHSQL02\A
GO
EXEC msdb.dbo.sp_stop_job @job_name=N'DBA - Test LogParser'
GO
EXEC msdb.dbo.sp_update_job @job_name=N'DBA - Test LogParser',@enabled=0
GO
 
 
