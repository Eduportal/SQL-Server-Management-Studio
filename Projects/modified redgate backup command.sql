--declare @cmd nvarchar(4000)

--select @cmd = 'sqlcmd -E -w265 -i\\SQLDEPLOYER05\SQLDEPLOYER05_dbasql\ProductCatalog_restore.gsql -o\\SQLDEPLOYER05\SQLDEPLOYER05_dbasql\dba_reports\ProductCatalog_restore.log'
--exec master.sys.xp_cmdshell @cmd



Use Master
go
 
--  Note:  RedGate Syntax will be used for this request


Declare @cmd nvarchar(4000)
Select @cmd = '-SQL "RESTORE FILELISTONLY FROM DISK = ''\\SQLDEPLOYER05\SQLDEPLOYER05_restore\pc\ProductCatalog_db_20110819215333.SQB''"'
Exec master.dbo.sqlbackup @cmd
go

Declare @cmd nvarchar(4000)
Select @cmd = '-SQL "RESTORE SQBHEADERONLY FROM DISK = ''\\SQLDEPLOYER05\SQLDEPLOYER05_restore\pc\ProductCatalog_db_20110819215333.SQB''"'
Exec master.dbo.sqlbackup @cmd
go

  
  
Declare @cmd nvarchar(4000),@RC INT,@exitcode int, @sqlerrorcode int
		
Select @cmd = '-SQL "RESTORE DATABASE [ProductCatalog]
	 FROM DISK = ''\\SQLDEPLOYER05\SQLDEPLOYER05_restore\pc\ProductCatalog_db_20110819215333.SQB''
	 WITH NORECOVERY
	,MOVE ''ProductCatalog_data'' to ''e:\mssql.1\data\ProductCatalog_data.mdf''
	,MOVE ''ProductCatalog_data2'' to ''e:\mssql.1\data\ProductCatalog_data2.ndf''
	,MOVE ''ProductCatalog_log'' to ''e:\mssql.1\data\ProductCatalog_log.ldf''
	,REPLACE
	,LOGTO = ''\\sqldeployer05\SQLDEPLOYER05_SQLjob_logs\ProductCatalog_restore.log''"'
SET @cmd = REPLACE(@cmd,CHAR(9),' ')
SET @cmd = REPLACE(@cmd,CHAR(13)+char(10),' ')
SET @cmd = REPLACE(REPLACE(@cmd,'  ',' '),'  ',' ')
Exec @RC = master.dbo.sqlbackup @cmd,@exitcode OUT, @sqlerrorcode OUT

SELECT @RC,@exitcode,@sqlerrorcode

GO
 
RESTORE DATABASE [ProductCatalog] WITH RECOVERY

--xp_fixeddrives