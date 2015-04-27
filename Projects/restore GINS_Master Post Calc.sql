exec master.sys.xp_cmdshell "del \\FRETSQLRYL02\FRETSQLRYL02_dbasql\GINS_Master_restore.gsql"


GO

Declare @cmd varchar(500)

Select @cmd = 'sqlcmd /S' + @@servername + ' /E /u /Q"exec dbaadmin.dbo.dbasp_autorestore @full_path = ''\\FRETSQLRYL03\FRETSQLRYL03_backup\post_calc'', @datapath = ''e:\data'', @logpath = ''f:\log'', @force_newldf = ''n'', @differential_flag = ''y'', @dbname = ''GINS_Master''" -o\\FRETSQLRYL02\FRETSQLRYL02_DBASQL\GINS_Master_restore.gsql -w265'
exec master.sys.xp_cmdshell @cmd

GO

If (select convert(sysname,DatabasePropertyEx('GINS_Master','Status'))) = 'ONLINE'
begin
	exec dbaadmin.dbo.dbasp_capture_UserDB_Access 'GINS_Master'
end

GO
if exists (select * from master.sys.sysdatabases where name = 'GINS_Master')
begin
	exec dbaadmin.dbo.dbasp_SetStatusForRestore @dbname = 'GINS_Master'
end

GO

If exists (select * from master.sys.sysdatabases where name = 'GINS_Master')
begin
	drop database GINS_Master
end

Declare @cmd varchar(500)

Select @cmd = 'Del \\FRETSQLRYL02\FRETSQLRYL02_mdf\GINS_Master.MDF'
EXEC master.sys.xp_cmdshell @cmd


Select @cmd = 'Del \\FRETSQLRYL02\FRETSQLRYL02_ldf\GINS_Master_log.LDF'
EXEC master.sys.xp_cmdshell @cmd

GO

--Declare @cmd varchar(500)

--Select @cmd = 'sqlcmd /S' + @@servername + ' /E /u /i\\FRETSQLRYL02\FRETSQLRYL02_dbasql\GINS_Master_restore.gsql -o\\FRETSQLRYL02\FRETSQLRYL02_DBASQL\DBA_REPORTS\GINS_Master_restore.log -w255'
--exec master.sys.xp_cmdshell @cmd


Use Master
go
 
--  Note:  RedGate Syntax will be used for this request
 
Declare @cmd nvarchar(4000)
Select @cmd = '-SQL "RESTORE DATABASE [GINS_Master]
	 FROM DISK = ''\\FRETSQLRYL03\FRETSQLRYL03_backup\post_calc\GINS_MASTER_db_20130814045324.SQB''
	 WITH NORECOVERY
	,MOVE ''dv_installapplData'' to ''e:\data\gins_prod.mdf''
	,MOVE ''dv_installapplData02'' to ''e:\data\dv_installapplData02.ndf''
	,MOVE ''gins_master03'' to ''e:\data\gins_master03.ndf''
	,MOVE ''gins_master04'' to ''e:\data\gins_master04.ndf''
	,MOVE ''gins_master05'' to ''e:\data\gins_master05.ndf''
	,MOVE ''lg_installapplLog'' to ''f:\log\gins_prod_log.ldf''
	,REPLACE"'
SET @cmd = REPLACE(@cmd,CHAR(9),'')
SET @cmd = REPLACE(@cmd,CHAR(13)+char(10),' ')
Exec master.dbo.sqlbackup @cmd
go
 
-- Restore Differential backup to database GINS_Master
Declare @cmd nvarchar(4000)
Select @cmd = '-SQL "RESTORE DATABASE [GINS_Master]
 FROM DISK = ''\\FRETSQLRYL03\FRETSQLRYL03_backup\post_calc\gins_master_dfntl_20130815202124.SQD''
 WITH RECOVERY"'
SET @cmd = REPLACE(@cmd,CHAR(9),'')
SET @cmd = REPLACE(@cmd,CHAR(13)+char(10),' ')
Exec master.dbo.sqlbackup @cmd
go


GO

Declare @cmd varchar(500)

Select @cmd = 'sqlcmd -E -u -w265 -i\\FRETSQLRYL02\FRETSQLRYL02_dbasql\GINS_Master_cleanup.sql -o\\FRETSQLRYL02\FRETSQLRYL02_DBASQL\DBA_reports\GINS_Master_cleanup.txt'
exec master.sys.xp_cmdshell @cmd

GO

exec dbaadmin.dbo.dbasp_Reset_UserDB_Access 'GINS_Master'

GO

