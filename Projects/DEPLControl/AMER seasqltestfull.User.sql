USE [DEPLcontrol]
GO
/****** Object:  User [AMER\seasqltestfull]    Script Date: 10/4/2013 11:02:04 AM ******/
CREATE USER [AMER\seasqltestfull] FOR LOGIN [AMER\seasqltestfull]
GO
ALTER ROLE [aspnet_ChangeNotification_ReceiveNotificationsOnlyAccess] ADD MEMBER [AMER\seasqltestfull]
GO
ALTER ROLE [db_owner] ADD MEMBER [AMER\seasqltestfull]
GO
ALTER ROLE [db_datareader] ADD MEMBER [AMER\seasqltestfull]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [AMER\seasqltestfull]
GO
