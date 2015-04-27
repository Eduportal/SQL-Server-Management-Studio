

DECLARE @BackupDirectory VARCHAR(100) 
EXEC master..xp_instance_regread @rootkey='HKEY_LOCAL_MACHINE', 
  @key='SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer', 
  @value_name='BackupDirectory', 
  @BackupDirectory=@BackupDirectory OUTPUT 
SELECT @BackupDirectory



dbo.dbasp_dba_sqlsetup @BackupDirectory -- 'E:\MSSQL.1\MSSQL\Backup'


--Write a value into the registry if needed .

--EXEC master..xp_instance_regwrite 
--     @rootkey='HKEY_LOCAL_MACHINE', 
--     @key='SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer', 
--     @value_name='BackupDirectory', 
--     @type='REG_SZ', 
--     @value='E:\MSSQL.1\MSSQL\Backup'
     
     