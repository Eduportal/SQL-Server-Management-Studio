USE [dbaadmin]
GO

USE DBAADMIN
GO
IF OBJECT_ID('dbasp_LogEvent_Method_WindowsEvent') IS NOT NULL
	DROP PROCEDURE [dbo].[dbasp_LogEvent_Method_WindowsEvent]
GO	
CREATE PROCEDURE [dbo].[dbasp_LogEvent_Method_WindowsEvent]
	(
	@cEModule		sysname			=null
	,@cECategory		sysname			=null
	,@cEEvent		sysname			=null
	,@cEGUID		uniqueidentifier	=null
	,@cEMessage		varchar(8000)		=null
	,@cEWinLog_LogName	sysname			= 'APPLICATION'
	,@cEWinLog_EventType	sysname			= 'INFORMATION'
	,@cEWinLog_EventID	INT			= 1
	,@cEStat_Rows		BigInt			=null
	,@cEStat_Duration	FLOAT			=null	
	)
AS
BEGIN
	DECLARE @CMD nVarChar(4000)
	DECLARE @CRLF nVarChar(10)
	SET	@CRLF = ''
	
	SET	@cEMessage
		= @cECategory + ' | ' + @cEEvent + @CRLF
		+ @cEModule + @CRLF
		+ @CRLF + @cEMessage + @CRLF
		+ @CRLF + CAST(@cEGUID AS VarChar(50))
		+ COALESCE(@CRLF+N' -- RowCount = ' + cast(@cEStat_Rows as nvarchar(50)), N'')
		+ COALESCE(@CRLF+N' -- Duration = ' + cast(@cEStat_Duration as nvarchar(50)), N'')
		+@CRLF+@CRLF
		+'Source Link: https://mixer.gettyimages.com/troubleshooting-guides/index.cgi?' + @cEModule+@CRLF
		+'Event Link : https://mixer.gettyimages.com/opsmssql/index.cgi?' + CAST(@cEWinLog_EventID AS VarChar(4))+@CRLF
				
	SET	@CMD		= 'eventcreate2'
				+ ' /SO "OPSMSSQL"'
				+ ' /ID ' + CAST(@cEWinLog_EventID AS VarChar(4))
				+ ' /L ' + @cEWinLog_LogName
				+ ' /T ' + @cEWinLog_EventType
				+ ' /D "' + @cEMessage + '"'
	PRINT @CMD
	exec XP_CMDSHELL @CMD , no_output 
	
END
GO





--DECLARE	@CustomLogName	sysname
--DECLARE	@RegFileData	VarChar(8000)

--SET	@CustomLogName	= 'TSSQLDBA4'



--IF CHARINDEX ('X64',@@version) > 0
--SET	@RegFileData	=
--'Windows Registry Editor Version 5.00

--[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\'+@CustomLogName+']
--"MaxSize"=dword:00080000
--"AutoBackupLogFiles"=dword:00000000

--[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\'+@CustomLogName+'\'+@CustomLogName+']
--"EventMessageFile"=hex(2):43,00,3a,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,\
--  00,73,00,5c,00,4d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,00,2e,00,\
--  4e,00,45,00,54,00,5c,00,46,00,72,00,61,00,6d,00,65,00,77,00,6f,00,72,00,6b,\
--  00,36,00,34,00,5c,00,76,00,32,00,2e,00,30,00,2e,00,35,00,30,00,37,00,32,00,\
--  37,00,5c,00,45,00,76,00,65,00,6e,00,74,00,4c,00,6f,00,67,00,4d,00,65,00,73,\
--  00,73,00,61,00,67,00,65,00,73,00,2e,00,64,00,6c,00,6c,00,00,00

--'
--ELSE

--SET	@RegFileData	=
--'Windows Registry Editor Version 5.00

--[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\'+@CustomLogName+']
--"MaxSize"=dword:00080000
--"AutoBackupLogFiles"=dword:00000000

--[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\'+@CustomLogName+'\'+@CustomLogName+']
--"EventMessageFile"=hex(2):43,00,3a,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,\
--  00,73,00,5c,00,4d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,00,2e,00,\
--  4e,00,45,00,54,00,5c,00,46,00,72,00,61,00,6d,00,65,00,77,00,6f,00,72,00,6b,\
--  00,5c,00,76,00,32,00,2e,00,30,00,2e,00,35,00,30,00,37,00,32,00,37,00,5c,00,\
--  45,00,76,00,65,00,6e,00,74,00,4c,00,6f,00,67,00,4d,00,65,00,73,00,73,00,61,\
--  00,67,00,65,00,73,00,2e,00,64,00,6c,00,6c,00,00,00
--'

--EXECUTE [dbaadmin].[dbo].[dbasp_FileAccess_Write] 
--   @RegFileData
--  ,'c:\'
--  ,'tempregimport.reg'


--EXEC XP_CMDSHELL 'regedt32 c:\tempregimport.reg'

--EXEC XP_CMDSHELL 'DEL c:\tempregimport.reg'








--SET NOCOUNT ON; 
--DECLARE	@CustomLogName	sysname
--	,@key		sysname
--	,@value		sysname

--SET	@CustomLogName	= 'TSSQLDBA3'
--SET	@key	= N'SYSTEM\CurrentControlSet\Services\eventlog\'+ @CustomLogName

--EXECUTE [master]..[xp_instance_regwrite]
--  @rootkey = N'HKEY_LOCAL_MACHINE'
-- ,@key = @key
-- ,@value_name = 'AutoBackupLogFiles'
-- ,@type = N'REG_DWORD'
-- ,@value = 0

--EXECUTE [master]..[xp_instance_regwrite]
--  @rootkey = N'HKEY_LOCAL_MACHINE'
-- ,@key = @key
-- ,@value_name = 'MaxSize'
-- ,@type = N'REG_DWORD'
-- ,@value = 524288

--SET	@key	= @key + '\' + @CustomLogName


--IF CHARINDEX ('X64',@@version) > 0
--	SET	@value = 'C:\Windows\Microsoft.NET\Framework64\v2.0.50727\EventLogMessages.dll'
--ELSE
--	SET	@value = 'C:\Windows\Microsoft.NET\Framework\v2.0.50727\EventLogMessages.dll'
	
--EXECUTE [master]..[xp_instance_regwrite]
--  @rootkey = N'HKEY_LOCAL_MACHINE'
-- ,@key = @key
-- ,@value_name = 'EventMessageFile'
-- ,@type = N'REG_EXPAND_SZ'
-- ,@value = @value





