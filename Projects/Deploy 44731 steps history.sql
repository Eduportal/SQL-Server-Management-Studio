--exec dpsp_help

DECLARE	@gears_id INT
SET	@gears_id = 44731


--exec dpsp_Status @gears_id

--Approve Gears Request for Deployment:
--exec DEPLcontrol.dbo.dpsp_Approve @gears_id 
--                                 ,@runtype = 'manual'  --'auto'
--                                 --,@DBA_override = 'y'
                                 
-- SCRIPT OUT PRE-RELEASE BACKUP TASKS
--exec dpsp_Script_PreRelease @gears_id

-- SCRIPT OUT MANUAL STARTS
-- exec DEPLcontrol.dbo.dpsp_ManualStart @gears_id , @SQLname = 'ScriptAll'  




/*******************************************************************
   SQL Automated Deployment Requests - Server: SEAFRESQLDBA01
 
-- Script Starting of PreRelease Backup Jobs 
*******************************************************************/
 
/***
DECLARE @CMD nVarChar(4000)
SET @CMD = 'sqlcmd -SG1SQLA\A -dmsdb -E -Q"exec msdb.dbo.sp_Start_Job @job_name=''SPCL - PreRelease Backups'';"'
exec master.sys.xp_cmdshell @cmd , no_output
--***/
GO

/***
DECLARE @CMD nVarChar(4000)
SET @CMD = 'sqlcmd -SG1SQLB\B -dmsdb -E -Q"exec msdb.dbo.sp_Start_Job @job_name=''SPCL - PreRelease Backups'';"'
exec master.sys.xp_cmdshell @cmd , no_output
--***/
GO

/***
DECLARE @CMD nVarChar(4000)
SET @CMD = 'sqlcmd -SSEADCASPSQLA\A -dmsdb -E -Q"exec msdb.dbo.sp_Start_Job @job_name=''SPCL - PreRelease Backups'';"'
exec master.sys.xp_cmdshell @cmd , no_output
--***/
GO

/***
DECLARE @CMD nVarChar(4000)
SET @CMD = 'sqlcmd -SSEADCPCSQLA\A -dmsdb -E -Q"exec msdb.dbo.sp_Start_Job @job_name=''SPCL - PreRelease Backups'';"'
exec master.sys.xp_cmdshell @cmd , no_output
--***/
GO

/***
DECLARE @CMD nVarChar(4000)
SET @CMD = 'sqlcmd -SSEADCSHSQLA\A -dmsdb -E -Q"exec msdb.dbo.sp_Start_Job @job_name=''SPCL - PreRelease Backups'';"'
exec master.sys.xp_cmdshell @cmd , no_output
***/
GO

/***
DECLARE @CMD nVarChar(4000)
SET @CMD = 'sqlcmd -SSEAFRESQLRPT01 -dmsdb -E -Q"exec msdb.dbo.sp_Start_Job @job_name=''SPCL - PreRelease Backups'';"'
exec master.sys.xp_cmdshell @cmd , no_output
--***/
GO

/***
DECLARE @CMD nVarChar(4000)
SET @CMD = 'sqlcmd -SSEAPSHLSQL0A\A -dmsdb -E -Q"exec msdb.dbo.sp_Start_Job @job_name=''SPCL - PreRelease Backups'';"'
exec master.sys.xp_cmdshell @cmd , no_output
--***/
GO



:CONNECT G1SQLA\A,1252 -U DBAsledridge -P Tigger4U
--exec msdb.dbo.sp_Start_Job @job_name='SPCL - PreRelease Backups'
exec msdb.dbo.sp_help_jobactivity @job_name = 'SPCL - PreRelease Backups'
exec msdb.dbo.sp_help_jobhistory @job_name = 'SPCL - PreRelease Backups'
GO

:CONNECT G1SQLB\B,1893 -U DBAsledridge -P Tigger4U
--exec msdb.dbo.sp_Start_Job @job_name='SPCL - PreRelease Backups'
exec msdb.dbo.sp_help_jobactivity @job_name = 'SPCL - PreRelease Backups'
exec msdb.dbo.sp_help_jobhistory @job_name = 'SPCL - PreRelease Backups'
GO

:CONNECT SEADCASPSQLA\A,1511 -U DBAsledridge -P Tigger4U
--exec msdb.dbo.sp_Start_Job @job_name='SPCL - PreRelease Backups'
exec msdb.dbo.sp_help_jobactivity @job_name = 'SPCL - PreRelease Backups'
exec msdb.dbo.sp_help_jobhistory @job_name = 'SPCL - PreRelease Backups'
GO

:CONNECT SEADCPCSQLA\A,1996 -U DBAsledridge -P Tigger4U
--exec msdb.dbo.sp_Start_Job @job_name='SPCL - PreRelease Backups'
exec msdb.dbo.sp_help_jobactivity @job_name = 'SPCL - PreRelease Backups'
exec msdb.dbo.sp_help_jobhistory @job_name = 'SPCL - PreRelease Backups'
GO

:CONNECT SEADCSHSQLA\A,4889 -U DBAsledridge -P Tigger4U
--exec msdb.dbo.sp_Start_Job @job_name='SPCL - PreRelease Backups'
exec msdb.dbo.sp_help_jobactivity @job_name = 'SPCL - PreRelease Backups'
exec msdb.dbo.sp_help_jobhistory @job_name = 'SPCL - PreRelease Backups'
GO

:CONNECT SEAPSHLSQL0A\A,1433 -U DBAsledridge -P Tigger4U
--exec msdb.dbo.sp_Start_Job @job_name='SPCL - PreRelease Backups'
--exec msdb.dbo.sp_help_jobactivity @job_name = 'SPCL - PreRelease Backups'
exec msdb.dbo.sp_help_jobhistory @job_name = 'SPCL - PreRelease Backups'
GO

:CONNECT SEAFRESQLRPT01 
--exec msdb.dbo.sp_Start_Job @job_name='SPCL - PreRelease Backups'
exec msdb.dbo.sp_help_jobactivity @job_name = 'SPCL - PreRelease Backups'
exec msdb.dbo.sp_help_jobhistory @job_name = 'SPCL - PreRelease Backups'
GO


















/*******************************************************************
   SQL Automated Deployment Requests - Server: SEAFRESQLDBA01
 
-- Manual Start Process 
*******************************************************************/
 
--  Info: @SQLname specified keyword "ScriptAll".


-- CHECK STATUS IN AMER
exec DEPLcontrol.dbo.dpsp_Status @gears_id = 44731
GO

-- CHECK STATUS IN PRODUCTION
:CONNECT SEAEXSQLMAIL -U DBAsledridge -P Tigger4U
exec DEPLcontrol.dbo.dpsp_Status @gears_id = 44731
GO

-- CHECK STATUS IN STAGE
:CONNECT SEAFRESTGSQL -U DBAsledridge -P Tigger4U
exec DEPLcontrol.dbo.dpsp_Status @gears_id = 44731
GO



/*
:CONNECT SEAEXSQLMAIL -U DBAsledridge -P Tigger4U
exec DEPLcontrol.dbo.dpsp_ManualStart @gears_id = 44731, @SQLname = 'G1SQLA\A';
GO

:CONNECT SEAEXSQLMAIL -U DBAsledridge -P Tigger4U
exec DEPLcontrol.dbo.dpsp_ManualStart @gears_id = 44731, @SQLname = 'G1SQLB\B';
GO

:CONNECT SEAEXSQLMAIL -U DBAsledridge -P Tigger4U
exec DEPLcontrol.dbo.dpsp_ManualStart @gears_id = 44731, @SQLname = 'SEADCASPSQLA\A';
GO

:CONNECT SEAEXSQLMAIL -U DBAsledridge -P Tigger4U
exec DEPLcontrol.dbo.dpsp_ManualStart @gears_id = 44731, @SQLname = 'SEADCPCSQLA\A';
GO

:CONNECT SEAEXSQLMAIL -U DBAsledridge -P Tigger4U
exec DEPLcontrol.dbo.dpsp_ManualStart @gears_id = 44731, @SQLname = 'SEADCSHSQLA\A';
GO

:CONNECT SEAEXSQLMAIL -U DBAsledridge -P Tigger4U
exec DEPLcontrol.dbo.dpsp_ManualStart @gears_id = 44731, @SQLname = 'SEAPSHLSQL0A\A';
GO

--exec DEPLcontrol.dbo.dpsp_ManualStart @gears_id = 44731, @SQLname = 'SEAFRESQLRPT01';
GO

*/
