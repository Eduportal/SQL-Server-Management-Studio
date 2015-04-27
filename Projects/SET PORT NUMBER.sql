	DECLARE @MSG VarChar(8000),@RegKey nvarchar(4000),@InstanceNumber varchar(1024),@OldPort VarChar(50),@NewPort VarChar(50)
	
	-- GMSA GMSB HGA VALUES		
	SET @NewPort = CASE @@SERVICENAME 
						WHEN 'A'	THEN '1252' 
						WHEN 'B'	THEN '1893' 
						WHEN 'HGA'	THEN '2082'
						ELSE '1433' 
						END
	
	-- GET CURRENT INSTANCE NUMBER VALUES
	SET		@RegKey				= 'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' 
	EXEC	master..xp_regread 
				@rootkey		= 'HKEY_LOCAL_MACHINE' 
				,@key			= @RegKey 
				,@value_name	= @@SERVICENAME
				,@value			= @InstanceNumber OUTPUT

	SET		@RegKey				= 'SOFTWARE\Microsoft\Microsoft SQL Server\'+@InstanceNumber+'\MSSQLSERVER\SuperSocketNetLib\Tcp\IPAll\'

	EXEC	master..xp_regread
				@rootkey		= 'HKEY_LOCAL_MACHINE' 
				,@key			= @RegKey 
				,@value_name	= 'TcpPort'
				,@value			= @OldPort OUTPUT
				
			
	EXEC	master..xp_regwrite
				@rootkey		= 'HKEY_LOCAL_MACHINE' 
				,@key			= @RegKey 
				,@value_name	= 'TcpPort'
				,@type			= 'REG_SZ' 
				,@value			= @NewPort 	
				
				
PRINT 'PORT CHANGED FROM ' +@OldPort + ' TO ' + @NewPort