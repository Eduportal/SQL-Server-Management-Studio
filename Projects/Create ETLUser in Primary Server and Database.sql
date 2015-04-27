--:SETVAR DBName "Getty_Master"
--:SETVAR DBName "RM_Integration"
--:SETVAR DBName "Gins_Master"
--:SETVAR DBName "Gins_Integration"
--:SETVAR DBName "EditorialSiteDB"
--:SETVAR DBName "EventServiceDB"

-------------------------------------------------
-- Create login 'ETLUser'
-------------------------------------------------
If not exists (select * from master.sys.syslogins where name = N'ETLUser')
   Begin
      Declare @cmd nvarchar(3000)
      
      select @cmd = 'CREATE LOGIN ETLUser
             WITH PASSWORD = ''' + nchar(1) + nchar(58921) + nchar(59396) + nchar(39350) + nchar(47269) + nchar(8867) + nchar(58583) + nchar(54530) + nchar(55853) + nchar(64629) + nchar(10171) + nchar(2428) + nchar(54609) + ''' HASHED
                                 ,DEFAULT_DATABASE = [master]
                                 ,DEFAULT_LANGUAGE = us_english
                                 ,CHECK_POLICY = OFF
                                 ,CHECK_EXPIRATION = OFF
                                 ,SID = 0x1D23FDE4CB085D4486E1E16B3C30865E'
        Print @cmd
        Exec (@cmd)
   End
Else
   Begin
      Print 'Note:  Login ''ETLUser'' already exists on this server.'
   End
go



USE [$(DBName)]
GO
CREATE USER [ETLUser] FOR LOGIN [ETLUser]
GO
EXEC sp_addrolemember N'db_datareader', N'ETLUser'
GO
GRANT SELECT TO [ETLUser]
GO
GRANT SHOWPLAN TO [ETLUser]
GO
GRANT VIEW DATABASE STATE TO [ETLUser]
GO
GRANT VIEW DEFINITION TO [ETLUser]
GO


