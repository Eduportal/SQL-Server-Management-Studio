DECLARE		@instancename		sysname
			,@ServerName		sysname
			,@machinename		sysname
			,@RegKey			VarChar(8000)
			,@IPAddr1			VarChar(255)
			,@IPAddr2			VarChar(255)
			,@TCPPort			VarChar(255)
			,@InstanceNumber	VarChar(255)

Select 	@instancename		= isnull('\'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
		,@ServerName		= REPLACE(@@SERVERNAME,@instancename,'')
		,@machinename		= convert(nvarchar(100), serverproperty('machinename')) + @instancename
		,@RegKey			= 'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' 

-- GET CURRENT INSTANCE NUMBER VALUES
EXEC	master..xp_regread 
			@rootkey		= 'HKEY_LOCAL_MACHINE' 
			,@key			= @RegKey 
			,@value_name	= @@SERVICENAME
			,@value			= @InstanceNumber OUTPUT
			
-- GET CURRENT TCP VALUES
SET		@RegKey				= 'SOFTWARE\Microsoft\Microsoft SQL Server\'+@InstanceNumber+'\MSSQLSERVER\SuperSocketNetLib\Tcp\IP1'
EXEC	master..xp_regread
			@rootkey		= 'HKEY_LOCAL_MACHINE' 
			,@key			= @RegKey 
			,@value_name	= 'IpAddress'
			,@value			= @IPAddr1 OUTPUT


SET		@RegKey				= 'SOFTWARE\Microsoft\Microsoft SQL Server\'+@InstanceNumber+'\MSSQLSERVER\SuperSocketNetLib\Tcp\IP2\'
EXEC	master..xp_regread
			@rootkey		= 'HKEY_LOCAL_MACHINE' 
			,@key			= @RegKey 
			,@value_name	= 'IpAddress'
			,@value			= @IPAddr2 OUTPUT
			
SET		@RegKey				= 'SOFTWARE\Microsoft\Microsoft SQL Server\'+@InstanceNumber+'\MSSQLSERVER\SuperSocketNetLib\Tcp\IPAll\'
EXEC	master..xp_regread
			@rootkey		= 'HKEY_LOCAL_MACHINE' 
			,@key			= @RegKey 
			,@value_name	= 'TcpPort'
			,@value			= @TCPPort OUTPUT
			
		
SELECT	@ServerName			ServerName
		,@instancename		InstanceName
		,@machinename		MachineName
		,@IPAddr1			IP1
		,@IPAddr2			IP2
		,@TCPPort			Port
		
/*		
xp_cmdshell 'ipconfig /all'		



Server Name	output
FREBGMSSQLA01-N\A	   IP Address. . . . . . . . . . . . : 10.200.126.10 
FREBPCXSQL01-N\A	   IP Address. . . . . . . . . . . . : 10.200.126.12 
FREBSHWSQL01-N\A	   IP Address. . . . . . . . . . . . : 10.200.126.13 
FREBASPSQL01-N\A	   IP Address. . . . . . . . . . . . : 10.200.126.19 
FREBGMSSQLB01-N\B	   IP Address. . . . . . . . . . . . : 10.200.126.35 
FREBGMSSQLB01-N\HGA	   IP Address. . . . . . . . . . . . : 10.200.126.35 

*/


