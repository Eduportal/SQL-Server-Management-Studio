/****** Object:  LinkedServer [SEAFRESQLBOA]    Script Date: 05/18/2010 17:08:42 ******/
IF NOT EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = N'SEAFRESQLBOA')
BEGIN
EXEC master.dbo.sp_addlinkedserver @server = N'SEAFRESQLBOA', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with L84Lunch */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'SEAFRESQLBOA',@useself=N'False',@locallogin=NULL,@rmtuser=N'DEPLMaster',@rmtpassword='L84Lunch'
END
GO

EXEC master.dbo.sp_serveroption @server=N'SEAFRESQLBOA', @optname=N'collation compatible', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SEAFRESQLBOA', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SEAFRESQLBOA', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SEAFRESQLBOA', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SEAFRESQLBOA', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SEAFRESQLBOA', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SEAFRESQLBOA', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SEAFRESQLBOA', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'SEAFRESQLBOA', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'SEAFRESQLBOA', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SEAFRESQLBOA', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'SEAFRESQLBOA', @optname=N'use remote collation', @optvalue=N'true'
GO


/****** Object:  LinkedServer [SEAINTRASQL01]    Script Date: 05/18/2010 17:09:04 ******/
IF NOT EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = N'SEAINTRASQL01')
BEGIN
EXEC master.dbo.sp_addlinkedserver @server = N'SEAINTRASQL01', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with L84Lunch */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'SEAINTRASQL01',@useself=N'False',@locallogin=NULL,@rmtuser=N'DEPLMaster',@rmtpassword='L84Lunch'
END
GO

EXEC master.dbo.sp_serveroption @server=N'SEAINTRASQL01', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SEAINTRASQL01', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SEAINTRASQL01', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SEAINTRASQL01', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SEAINTRASQL01', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SEAINTRASQL01', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SEAINTRASQL01', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SEAINTRASQL01', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'SEAINTRASQL01', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'SEAINTRASQL01', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SEAINTRASQL01', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'SEAINTRASQL01', @optname=N'use remote collation', @optvalue=N'false'
GO




USE [dbacentral]
GO
CREATE SYNONYM [dbo].[DBA_DashBoard_NOCTicketHistory] 
FOR [SEAINTRASQL01].[users].[dbo].[DBA_DashBoard_NOCTicketHistory]
GO

CREATE SYNONYM [dbo].[DBA_DashBoard_CCTicketHistory] 
FOR [SEAINTRASQL01].[users].[dbo].[DBA_DashBoard_CCTicketHistory]
GO

CREATE SYNONYM [dbo].[Servers] 
FOR [SEAFRESQLBOA].[Enlighten].[dbo].[Servers]
GO

CREATE SYNONYM [dbo].[Contacts] 
FOR [SEAFRESQLBOA].[eds].[dbo].[Contacts]
GO


CREATE SYNONYM [dbo].[Contact_Groups] 
FOR [SEAFRESQLBOA].[eds].[dbo].[Contact_Groups]
GO

CREATE SYNONYM [dbo].[Contact_Numbers] 
FOR [SEAFRESQLBOA].[eds].[dbo].[Contact_Numbers]
GO



select * From  [dbo].[DBA_DashBoard_NOCTicketHistory] 

select * From  [dbo].[DBA_DashBoard_CCTicketHistory] 

select * From  [dbo].[Servers] 