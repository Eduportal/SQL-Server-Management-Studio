


UPDATE DBAADMIN.dbo.dba_ServerInfo SET Active = 'N'
GO
EXEC xp_servicecontrol N'STOP',N'SQLServerAGENT'
EXEC xp_servicecontrol N'STOP',N'SQLBackupAgent'
EXEC xp_servicecontrol N'STOP',N'ah3agent-0'
EXEC xp_servicecontrol N'STOP',N'SplunkForwarder'
GO
exec xp_cmdshell 'sc config "SQLServerAGENT" start= disabled'
exec xp_cmdshell 'sc config "SQLBackupAgent" start= disabled'
exec xp_cmdshell 'sc config "ah3agent-0" start= disabled'
exec xp_cmdshell 'sc config "SplunkForwarder" start= disabled'
exec xp_cmdshell 'sc config "MSSQLServer" start= disabled'
GO
SHUTDOWN WITH NOWAIT
GO
