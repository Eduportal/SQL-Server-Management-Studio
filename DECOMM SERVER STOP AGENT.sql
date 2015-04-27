DECLARE @Test Bit
SET @Test = 0
IF @@ServerName IN
('FREPSQLRYLB01'
,'FREPSQLRYLB11'
,'FREPSQLRYLB12'
,'FREPSQLRYLB13'
,'FREPSQLRYLB14'
,'FREPSQLRYLB15'

,'FREPSQLRYLA01'
,'FREPSQLRYLA11'
,'FREPSQLRYLA12'
,'FREPSQLRYLA13'
,'FREPSQLRYLA14'
,'FREPSQLRYLA15'

,'FRESSQLRYLI01'
,'FRETSQLRYLI02'
,'FRETSQLRYLI03'

,'FRESSQLRYL01'

,'FRETSQLRYL02'
,'FRETSQLRYL03'
)
BEGIN
	SET @Test = 1
	UPDATE DBAADMIN.dbo.dba_ServerInfo SET Active = 'N'

	EXEC xp_servicecontrol N'STOP',N'SQLServerAGENT'
	EXEC xp_servicecontrol N'STOP',N'SQLBackupAgent'
	EXEC xp_servicecontrol N'STOP',N'ah3agent-0'
	EXEC xp_servicecontrol N'STOP',N'SplunkForwarder'

	exec xp_cmdshell 'sc config "SQLServerAGENT" start= disabled'
	exec xp_cmdshell 'sc config "SQLBackupAgent" start= disabled'
	exec xp_cmdshell 'sc config "ah3agent-0" start= disabled'
	exec xp_cmdshell 'sc config "SplunkForwarder" start= disabled'
	exec xp_cmdshell 'sc config "MSSQLServer" start= disabled'

	SELECT @Test
	--EXEC xp_servicecontrol N'Querystate',N'MSSQLServer'
	exec ('SHUTDOWN')
END
ELSE 
	SELECT @Test
GO




:CONNECT SEAPDBASQL01

UPDATE DBACentral.dbo.dba_ServerInfo SET Active = 'N'
WHERE SERVERNAME IN
('FREPSQLRYLB01'
,'FREPSQLRYLB11'
,'FREPSQLRYLB12'
,'FREPSQLRYLB13'
,'FREPSQLRYLB14'
,'FREPSQLRYLB15'

,'FREPSQLRYLA01'
,'FREPSQLRYLA11'
,'FREPSQLRYLA12'
,'FREPSQLRYLA13'
,'FREPSQLRYLA14'
,'FREPSQLRYLA15'

,'FRESSQLRYLI01'
,'FRETSQLRYLI02'
,'FRETSQLRYLI03'

,'FRESSQLRYL01'

,'FRETSQLRYL02'
,'FRETSQLRYL03'
)
GO
