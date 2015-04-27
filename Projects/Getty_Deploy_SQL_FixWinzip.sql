

DECLARE @CMD VarChar(8000),@RegKey VarChar(2048),@InstanceNumber VarChar(50),@Date DateTime

	SET	@Date = GETDATE()
	-- GET CURRENT INSTANCE NUMBER VALUES
	SET		@RegKey				= 'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' 
	EXEC	master..xp_regread 
				@rootkey		= 'HKEY_LOCAL_MACHINE' 
				,@key			= @RegKey 
				,@value_name	= @@SERVICENAME
				,@value			= @InstanceNumber OUTPUT

		Select	@cmd = NULL
		IF @InstanceNumber = 'MSSQL.1'
		Select	@cmd = 'xcopy "\\seafresqldba01\DBA_Docs\utilities\WinZip 9 SR1\Install" "C:\Program Files (x86)\WinZip\" /Q /C /E /Y'
		exec	master.sys.xp_cmdshell @cmd--, no_output

		SET		@Date = DATEADD(mi,1,@Date) 
		Select	@cmd = 'WAITFOR TIME '''+RIGHT('00'+CAST(DATEPART(hour,@Date) AS VarChar(2)),2)+':'+RIGHT('00'+CAST(DATEPART(minute,@Date) AS VarChar(2)),2)+''''
		--exec	(@cmd)

		Select	@cmd = NULL
		IF @InstanceNumber = 'MSSQL.2'
		Select	@cmd = 'xcopy "\\seafresqldba01\DBA_Docs\utilities\WinZip 9 SR1\Install" "C:\Program Files (x86)\WinZip\" /Q /C /E /Y'
		exec	master.sys.xp_cmdshell @cmd--, no_output

		SET		@Date = DATEADD(mi,1,@Date) 
		Select	@cmd = 'WAITFOR TIME '''+RIGHT('00'+CAST(DATEPART(hour,@Date) AS VarChar(2)),2)+':'+RIGHT('00'+CAST(DATEPART(minute,@Date) AS VarChar(2)),2)+''''
		--exec	(@cmd)

		Select	@cmd = NULL
		IF @InstanceNumber = 'MSSQL.3'
		Select	@cmd = 'xcopy "\\seafresqldba01\DBA_Docs\utilities\WinZip 9 SR1\Install" "C:\Program Files (x86)\WinZip\" /Q /C /E /Y'
		exec	master.sys.xp_cmdshell @cmd--, no_output
							
		SET		@Date = DATEADD(mi,1,@Date) 
		Select	@cmd = 'WAITFOR TIME '''+RIGHT('00'+CAST(DATEPART(hour,@Date) AS VarChar(2)),2)+':'+RIGHT('00'+CAST(DATEPART(minute,@Date) AS VarChar(2)),2)+''''
		--exec	(@cmd)

		Select	@cmd = NULL
		IF @InstanceNumber = 'MSSQL.1'
		Select	@cmd = '"C:\Program Files (x86)\WinZip\winzip32.exe" /noqp /notip /autoinstall'
		exec	master.sys.xp_cmdshell @cmd--, no_output

		SET		@Date = DATEADD(mi,1,@Date) 
		Select	@cmd = 'WAITFOR TIME '''+RIGHT('00'+CAST(DATEPART(hour,@Date) AS VarChar(2)),2)+':'+RIGHT('00'+CAST(DATEPART(minute,@Date) AS VarChar(2)),2)+''''
		--exec	(@cmd)

		Select	@cmd = NULL
		IF @InstanceNumber = 'MSSQL.2'
		Select	@cmd = '"C:\Program Files (x86)\WinZip\winzip32.exe" /noqp /notip /autoinstall'
		exec	master.sys.xp_cmdshell @cmd--, no_output
		
		SET		@Date = DATEADD(mi,1,@Date) 
		Select	@cmd = 'WAITFOR TIME '''+RIGHT('00'+CAST(DATEPART(hour,@Date) AS VarChar(2)),2)+':'+RIGHT('00'+CAST(DATEPART(minute,@Date) AS VarChar(2)),2)+''''
		--exec	(@cmd)

		Select	@cmd = NULL
		IF @InstanceNumber = 'MSSQL.3'
		Select	@cmd = '"C:\Program Files (x86)\WinZip\winzip32.exe" /noqp /notip /autoinstall'
		exec	master.sys.xp_cmdshell @cmd--, no_output

		--Select @cmd = 'tasklist'
		--exec	master.sys.xp_cmdshell @cmd--, no_output
				
		--Select @cmd = 'taskkill /F /IM   /T'
		--exec	master.sys.xp_cmdshell @cmd--, no_output	
		
		Select @cmd = 'wzzip -a c:\test.zip c:\*.txxt'
		exec	master.sys.xp_cmdshell @cmd--, no_output
