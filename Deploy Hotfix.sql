DECLARE @Script VarChar(8000)

SELECT	@Script = @@VERSION

IF @Script like '%Windows NT 5.2%'
	xp_cmdshell 'wmic qfe | find "KB932370"'


	SET @Script = NULL

SELECT @Script



IF @@Version Like '%(x64)%'
	SET @Script = '"\\seapdbasql01\DBA_Docs\SQL_Server\Windows Server 2003 Hotfix to fix WMI\WindowsServer2003.WindowsXP-KB932370-v3-x64-ENU.exe" /Z /U /O'
ELSE
	SET @Script = '"\\seapdbasql01\DBA_Docs\SQL_Server\Windows Server 2003 Hotfix to fix WMI\WindowsServer2003-KB932370-v3-x86-ENU.exe" /Z /U /O'

PRINT @Script

exec xp_cmdshell @Script


Microsoft SQL Server 2005 - 9.00.4060.00 (X64) 
	Mar 17 2011 13:06:52 
	Copyright (c) 1988-2005 Microsoft Corporation
	Enterprise Edition (64-bit) on Windows NT 5.2 (Build 3790: Service Pack 2)



xp_cmdshell 'wmic qfe | find "KB932370"'