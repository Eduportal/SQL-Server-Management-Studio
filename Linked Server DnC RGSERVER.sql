USE [master]
GO

/****** Object:  LinkedServer [RGSERVER]    Script Date: 12/23/2014 10:29:37 AM ******/
EXEC master.dbo.sp_dropserver @server=N'RGSERVER', @droplogins='droplogins'
GO

/****** Object:  LinkedServer [RGSERVER]    Script Date: 12/23/2014 10:29:37 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'RGSERVER', @srvproduct=N'sql', @provider=N'SQLNCLI', @datasrc=N'SEAPSQLRYL0B,1433'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'RGSERVER',@useself=N'False',@locallogin=NULL,@rmtuser=N'rguser',@rmtpassword='C@rr3nT'

GO

EXEC master.dbo.sp_serveroption @server=N'RGSERVER', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'RGSERVER', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'RGSERVER', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'RGSERVER', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'RGSERVER', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'RGSERVER', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'RGSERVER', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'RGSERVER', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'RGSERVER', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'RGSERVER', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'RGSERVER', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'RGSERVER', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'RGSERVER', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

