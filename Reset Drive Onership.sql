-- RESET DRIVE OWNERSHIP

	DECLARE @DriveLetter	VarChar(50)
	DECLARE @CMD		nVarChar(4000)

	DECLARE DriveCursor CURSOR
	FOR
		select RootFolder 
		From dbaadmin.dbo.dbaudf_ListDrives() 
		Where DriveLetter Is Not Null 
		ORDER BY 1

	OPEN DriveCursor;
	FETCH DriveCursor INTO @DriveLetter;
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			SET @CMD = 'takeown /f '+LEFT(@DriveLetter,2)+' /r /d y'
				exec xp_cmdshell @CMD

			SET @CMD = 'icacls '+@DriveLetter+' /setowner BUILTIN\Administrators /T /C /Q'
				exec xp_cmdshell @CMD
			SET @CMD = 'icacls '+@DriveLetter+' /setowner '+CAST(SERVERPROPERTY('ComputerNamePhysicalNetBIOS')AS VarChar(50)) +'\Administrators /T /C /Q'
				exec xp_cmdshell @CMD

			SET @CMD = 'iCACLS '+@DriveLetter+' /T /C /Q /grant BUILTIN\Administrators:(OI)(CI)F /inheritance:e'
				exec xp_cmdshell @CMD
			SET @CMD = 'iCACLS '+@DriveLetter+' /T /C /Q /grant '+CAST(SERVERPROPERTY('ComputerNamePhysicalNetBIOS')AS VarChar(50))+'\Administrators:(OI)(CI)F /inheritance:e'
				exec xp_cmdshell @CMD

			SET @CMD = 'attrib '+@DriveLetter+'* -s -r -h /S /D'
				exec xp_cmdshell @CMD
		END
 		FETCH NEXT FROM DriveCursor INTO @DriveLetter;
	END
	CLOSE DriveCursor;
	DEALLOCATE DriveCursor;

