USE [master]
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2
GO

 
-------------------------------------------------
-- Create login 'AMER\S-sledridge'
-------------------------------------------------
If not exists (select * from master.sys.syslogins where name = N'AMER\S-Rwolff')
   Begin
      Print 'Add NT Login ''AMER\S-s-sledridge'''
      CREATE LOGIN [AMER\s-sledridge] FROM WINDOWS
             WITH DEFAULT_DATABASE = [master]
                 ,DEFAULT_LANGUAGE = us_english
   End
Else
   Begin
      Print 'Note:  Login ''AMER\s-sledridge'' already exists on this server.'
   End
go

-------------------------------------------------
-- Create login 'AMER\sledridge'
-------------------------------------------------
If not exists (select * from master.sys.syslogins where name = N'AMER\sledridge')
   Begin
      Print 'Add NT Login ''AMER\sledridge'''
      CREATE LOGIN [AMER\sledridge] FROM WINDOWS
             WITH DEFAULT_DATABASE = [master]
                 ,DEFAULT_LANGUAGE = us_english
   End
Else
   Begin
      Print 'Note:  Login ''AMER\sledridge'' already exists on this server.'
   End
go
-------------------------------------------------
-- Create login 'DBAsledridge'
-------------------------------------------------
If not exists (select * from master.sys.syslogins where name = N'DBAsledridge')
   Begin
      Declare @cmd nvarchar(3000)
      
      select @cmd = 'CREATE LOGIN DBAsledridge
             WITH PASSWORD = '''+nchar(1)+nchar(54682)+nchar(3334)+nchar(44074)+nchar(31328)+nchar(51719)+nchar(22136)+nchar(50538)+nchar(61578)+nchar(19318)+nchar(45260)+nchar(41688)+nchar(34679)+''' HASHED
                                 ,DEFAULT_DATABASE = [master]
                                 ,DEFAULT_LANGUAGE = us_english
                                 ,CHECK_POLICY = OFF
                                 ,CHECK_EXPIRATION = OFF
                                 ,SID = 0xCDA987029B505C43B8B1F7C97F7674EF'
        Print @cmd
        Exec (@cmd)
   End
Else
   Begin
      Print 'Note:  Login ''DBAsledridge'' already exists on this server.'
   End
go
 
exec sp_addsrvrolemember 'AMER\s-sledridge', 'sysadmin';
go
exec sp_addsrvrolemember 'AMER\sledridge', 'sysadmin';
go
exec sp_addsrvrolemember 'DBAsledridge', 'sysadmin';
go

