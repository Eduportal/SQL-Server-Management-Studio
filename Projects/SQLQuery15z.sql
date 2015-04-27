DECLARE @BackupDirectory VARCHAR(100)
		,@NewBackupDirectory VARCHAR(100)  

SET		@NewBackupDirectory = 'G:\MSSQL.1\MSSQL\Backup'

EXEC master..xp_instance_regread @rootkey='HKEY_LOCAL_MACHINE', 
  @key='SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer', 
  @value_name='BackupDirectory', 
  @BackupDirectory=@BackupDirectory OUTPUT 

If nullif(@NewBackupDirectory,'') IS NOT NULL AND @NewBackupDirectory != @BackupDirectory
BEGIN

	SET @BackupDirectory = NULL

	EXEC	master..xp_instance_regwrite
				@rootkey		= 'HKEY_LOCAL_MACHINE' 
				,@key			= 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer' 
				,@value_name	= 'BackupDirectory'
				,@type			= 'REG_SZ' 
				,@value			= @NewBackupDirectory 

	EXEC	master..xp_instance_regread
				@rootkey		= 'HKEY_LOCAL_MACHINE' 
				,@key			= 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer' 
				,@value_name	= 'BackupDirectory'
				,@BackupDirectory=@BackupDirectory OUTPUT

END

PRINT	'Default Backup Directory: ' + 	@BackupDirectory

EXEC dbaadmin.dbo.dbasp_dba_sqlsetup @BackupDirectory
EXEC dbaadmin.dbo.dbasp_create_NXTshare



