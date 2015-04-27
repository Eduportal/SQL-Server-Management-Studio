exec master.sys.xp_cmdshell "del \\FRETSQLRYL02\FRETSQLRYL02_dbasql\GINS_Integration_restore.gsql"


GO

Declare @cmd varchar(500)

Select @cmd = 'sqlcmd /S' + @@servername + ' /E /u /Q"exec dbaadmin.dbo.dbasp_autorestore @full_path = ''\\FRETSQLRYL03\FRETSQLRYL03_backup\post_calc'', @datapath = ''H:\data'', @logpath = ''I:\log'', @force_newldf = ''n'', @differential_flag = ''y'', @dbname = ''GINS_Integration''" -o\\FRETSQLRYL02\FRETSQLRYL02_DBASQL\GINS_Integration_restore.gsql -w265'
exec master.sys.xp_cmdshell @cmd

GO

If (select convert(sysname,DatabasePropertyEx('GINS_Integration','Status'))) = 'ONLINE'
begin
	exec dbaadmin.dbo.dbasp_capture_UserDB_Access 'GINS_Integration'
end

GO
if exists (select * from master.sys.sysdatabases where name = 'GINS_Integration')
begin
	exec dbaadmin.dbo.dbasp_SetStatusForRestore @dbname = 'GINS_Integration'
end

GO

If exists (select * from master.sys.sysdatabases where name = 'GINS_Integration')
begin
	drop database GINS_Integration
end

Declare @cmd varchar(500)

Select @cmd = 'Del \\FRETSQLRYL02\FRETSQLRYL02_mdf\GINS_Integration.MDF'
EXEC master.sys.xp_cmdshell @cmd


Select @cmd = 'Del \\FRETSQLRYL02\FRETSQLRYL02_ldf\GINS_Integration_log.LDF'
EXEC master.sys.xp_cmdshell @cmd

GO

Declare @cmd varchar(500)

Select @cmd = 'sqlcmd /S' + @@servername + ' /E /u /i\\FRETSQLRYL02\FRETSQLRYL02_dbasql\GINS_Integration_restore.gsql -o\\FRETSQLRYL02\FRETSQLRYL02_DBASQL\DBA_REPORTS\GINS_Integration_restore.log -w255'
exec master.sys.xp_cmdshell @cmd


Use Master
go
 
--  Note:  RedGate Syntax will be used for this request
 
Declare @cmd nvarchar(4000)
Select @cmd = '-SQL "RESTORE DATABASE [GINS_Integration]
	 FROM DISK = ''\\FRETSQLRYL03\FRETSQLRYL03_backup\post_calc\GINS_Integration_db_20130814043003.SQB''
	 WITH NORECOVERY
	,MOVE ''gins_integration_Data'' to ''H:\data\gins_integration.mdf''
	,MOVE ''gins_integration_Data2'' to ''H:\data\gins_integration_Data2.ndf''
	,MOVE ''gins_integration_Log'' to ''F:\log\gins_integration_log.ldf''
	,REPLACE"'
SET @cmd = REPLACE(@cmd,CHAR(9),'')
SET @cmd = REPLACE(@cmd,CHAR(13)+char(10),' ')
Exec master.dbo.sqlbackup @cmd
go
 
-- Restore Differential backup to database GINS_Integration
Declare @cmd nvarchar(4000)
Select @cmd = '-SQL "RESTORE DATABASE [GINS_Integration]
 FROM DISK = ''\\FRETSQLRYL03\FRETSQLRYL03_backup\post_calc\gins_integration_dfntl_20130815202124.SQD''
 WITH RECOVERY"'
SET @cmd = REPLACE(@cmd,CHAR(9),'')
SET @cmd = REPLACE(@cmd,CHAR(13)+char(10),' ')
Exec master.dbo.sqlbackup @cmd
go
 

 Declare @cmd varchar(500)

Select @cmd = 'sqlcmd -E -u -w265 -i\\FRETSQLRYL02\FRETSQLRYL02_dbasql\GINS_Integration_cleanup.sql -o\\FRETSQLRYL02\FRETSQLRYL02_DBASQL\DBA_reports\GINS_Integration_cleanup.txt'
exec master.sys.xp_cmdshell @cmd

GO

exec dbaadmin.dbo.dbasp_Reset_UserDB_Access 'GINS_Integration'

GO
