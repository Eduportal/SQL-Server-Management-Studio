/****** Object:  LinkedServer [TEAMSREP]    Script Date: 08/16/2010 11:12:38 ******/
IF NOT EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = N'TEAMSREP')
BEGIN
EXEC master.dbo.sp_addlinkedserver @server = N'TEAMSREP', @srvproduct=N'ORACLE', @provider=N'OraOLEDB.Oracle'
	, @datasrc=N'TEAMS.seateamsrep'

EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'TEAMSREP',@useself=N'False',@locallogin=NULL
	,@rmtuser=N'GINS_USER'
	,@rmtpassword='REPORT'
END
GO

EXEC master.dbo.sp_serveroption @server=N'TEAMSREP', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'TEAMSREP', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'TEAMSREP', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'TEAMSREP', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'TEAMSREP', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'TEAMSREP', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'TEAMSREP', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'TEAMSREP', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'TEAMSREP', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'TEAMSREP', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'TEAMSREP', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'TEAMSREP', @optname=N'use remote collation', @optvalue=N'true'
GO


