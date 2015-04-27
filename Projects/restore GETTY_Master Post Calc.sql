exec master.sys.xp_cmdshell "del \\FRETSQLRYL02\FRETSQLRYL02_dbasql\GETTY_MASTER_restore.gsql"

GO

Declare @cmd varchar(500)

Select @cmd = 'sqlcmd /S' + @@servername + ' /E /u /Q"exec dbaadmin.dbo.dbasp_autorestore @full_path = ''\\FRETSQLRYL02\FRETSQLRYL02_backup\post_calc'', @datapath = ''I:\data'', @logpath = ''f:\log'', @force_newldf = ''n'', @differential_flag = ''y'', @dbname = ''GETTY_MASTER''" -o\\FRETSQLRYL02\FRETSQLRYL02_DBASQL\GETTY_MASTER_restore.gsql -w265'
exec master.sys.xp_cmdshell @cmd

GO

If (select convert(sysname,DatabasePropertyEx('Getty_Master','Status'))) = 'ONLINE'
begin
	exec dbaadmin.dbo.dbasp_capture_UserDB_Access 'Getty_Master'
end


GO

if exists (select * from master.sys.sysdatabases where name = 'GETTY_MASTER')
begin
	exec dbaadmin.dbo.dbasp_SetStatusForRestore @dbname = 'GETTY_MASTER'
end

GO

If exists (select * from master.sys.sysdatabases where name = 'GETTY_MASTER')
begin
	drop database GETTY_MASTER
end

Declare @cmd varchar(500)

Select @cmd = 'Del \\FRETSQLRYL02\FRETSQLRYL02_mdf\getty_master.MDF'
EXEC master.sys.xp_cmdshell @cmd


Select @cmd = 'Del \\FRETSQLRYL02\FRETSQLRYL02_ldf\GETTY_MASTER_log.LDF'
EXEC master.sys.xp_cmdshell @cmd



GO

--Declare @cmd varchar(500)

--Select @cmd = 'sqlcmd /S' + @@servername + ' /E /u /i\\FRETSQLRYL02\FRETSQLRYL02_dbasql\GETTY_MASTER_restore.gsql -o\\FRETSQLRYL02\FRETSQLRYL02_DBASQL\DBA_REPORTS\GETTY_MASTER_restore.log -w255'
--exec master.sys.xp_cmdshell @cmd

Use Master
go
 
--  Note:  RedGate Syntax will be used for this request

Declare @cmd nvarchar(4000)
Select @cmd = '-SQL "RESTORE FILELISTONLY FROM DISK = ''\\FRETSQLRYL02\FRETSQLRYL02_backup\post_calc\GETTY_MASTER_db_20130812091113.SQB''"'
SET @cmd = REPLACE(@cmd,CHAR(9),'')
SET @cmd = REPLACE(@cmd,CHAR(13)+char(10),' ')
Exec master.dbo.sqlbackup @cmd
go

 
Declare @cmd nvarchar(4000)
Select @cmd = '-SQL "RESTORE DATABASE [GETTY_MASTER]
	 FROM DISK = ''\\FRETSQLRYL02\FRETSQLRYL02_backup\post_calc\GETTY_MASTER_db_20130812091113.SQB''
	 WITH NORECOVERY
	,MOVE ''dv_installapplData'' to ''H:\data\getty_master.MDF''
	,MOVE ''dv_installappData2'' to ''F:\data\getty_master_1.NDF''
	,MOVE ''dv_installappData04'' to ''H:\data\dv_installappData04.ndf''
	,MOVE ''dv_installappData03'' to ''H:\data\dv_installappData03.ndf''
	,MOVE ''getty_master05'' to ''I:\data\getty_master05.ndf''
	,MOVE ''getty_master06'' to ''I:\data\getty_master06.ndf''
	,MOVE ''lg_installapplLog'' to ''f:\log\getty_master_log.LDF''
	,REPLACE"'
SET @cmd = REPLACE(@cmd,CHAR(9),'')
SET @cmd = REPLACE(@cmd,CHAR(13)+char(10),' ')
Exec master.dbo.sqlbackup @cmd
go
 
-- Restore Differential backup to database GETTY_MASTER
Declare @cmd nvarchar(4000)
Select @cmd = '-SQL "RESTORE DATABASE [GETTY_MASTER]
 FROM DISK = ''\\FRETSQLRYL02\FRETSQLRYL02_backup\post_calc\Getty_Master_dfntl_20130816210247.SQD''
 WITH RECOVERY"'
SET @cmd = REPLACE(@cmd,CHAR(9),'')
SET @cmd = REPLACE(@cmd,CHAR(13)+char(10),' ')
Exec master.dbo.sqlbackup @cmd
go
 


GO

exec dbaadmin.dbo.dbasp_ShrinkLDFFiles 'Getty_Master'

GO

Declare @cmd varchar(500)

Select @cmd = 'sqlcmd -E -u -w265 -i\\FRETSQLRYL02\FRETSQLRYL02_dbasql\GETTY_MASTER_cleanup.sql -o\\FRETSQLRYL02\FRETSQLRYL02_DBASQL\DBA_reports\GETTY_MASTER_cleanup.txt'
exec master.sys.xp_cmdshell @cmd

GO

exec dbaadmin.dbo.dbasp_Reset_UserDB_Access 'GETTY_MASTER'

GO
