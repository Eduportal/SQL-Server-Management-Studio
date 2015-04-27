

DECLARE @SmoRoot VarChar(2000)
DECLARE @FilterPart VarChar(2000)

DECLARE @AGTGroupSID nvarchar (256)	-- Name of the agent group SID
DECLARE @FTSGroupSID nvarchar (256)	-- Name of the agent group SID
DECLARE @SQLGroupSID nvarchar (256)	-- Name of the agent group SID

DECLARE @AGTGroupSIDBinary varbinary(256) -- binary representation of AGTGroupSID
DECLARE @FTSGroupSIDBinary varbinary(256) -- binary representation of AGTGroupSID
DECLARE @SQLGroupSIDBinary varbinary(256) -- binary representation of AGTGroupSID

DECLARE @AGTGroupName nvarchar (256) -- name of the group
DECLARE @FTSGroupName nvarchar (256) -- name of the group
DECLARE @SQLGroupName nvarchar (256) -- name of the group


EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\Setup', N'AGTGroup', @AGTGroupSID OUTPUT
EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\Setup', N'FTSGroup', @FTSGroupSID OUTPUT
EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\Setup', N'SQLGroup', @SQLGroupSID OUTPUT



exec master.dbo.xp_instance_regread 
  'HKEY_LOCAL_MACHINE'
 ,'SOFTWARE\Microsoft\MSSQLServer\Setup'
 ,'SQLProgramDir'
 ,@SmoRoot OUTPUT
 
 exec master.dbo.xp_instance_regread 
  'HKEY_LOCAL_MACHINE'
 ,'SOFTWARE\Microsoft\MSSQLServer\Setup'
 ,'SQLPath'
 ,@FilterPart OUTPUT

SET	@FilterPart = REPLACE(@FilterPart,@SmoRoot,'')

PRINT @FilterPart

PRINT 'Database Services			[Installation Path]	= ' + @SmoRoot

exec master.dbo.xp_instance_regread 
  'HKEY_LOCAL_MACHINE'
 ,'SOFTWARE\Microsoft\MSSQLServer\Setup'
 ,'SQLDataRoot'
 ,@SmoRoot OUTPUT

PRINT 'Database Services\Data Files		[Installation Path]	= ' + REPLACE(@SmoRoot,@FilterPart,'')


--exec master.dbo.xp_instance_regread 
--  'HKEY_LOCAL_MACHINE'
-- ,'SOFTWARE\Microsoft\MSSQLServer\90\Tools\ClientSetup'
-- ,'SQLBinRoot'
-- ,@SmoRoot OUTPUT

--PRINT 'SQL CLIENT TOOLS				[Installation Path]	= ' + @SmoRoot

select		DISTINCT left(physical_name, len(physical_name)-charindex('\',reverse(physical_name)))
from		sys.master_files
WHERE		database_id > 4
	AND	type_desc != 'LOG'
	
	
exec master.dbo.xp_instance_regread 
  'HKEY_LOCAL_MACHINE'
 ,'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\IPAll'
 ,'TcpPort'
 ,@SmoRoot OUTPUT

PRINT 'SQL CONFGIURATION			[TCP/IP Port]		= ' + @SmoRoot


PRINT 'start /wait setup LOGNAME=C:\setup\setup.cab /settings C:\setup\myTemplate.ini /qn'
PRINT '
echo %errorlevel%'
