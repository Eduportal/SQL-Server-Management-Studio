SELECT		DISTINCT
		T2.FullPathName,T2.DateModified -- SELECT *
FROM		dbaadmin.dbo.dbaudf_ListDrives() T1
CROSS APPLY	dbaadmin.dbo.dbaudf_FileAccess_Dir2(T1.RootFolder,1,0) T2
WHERE		T1.DriveLetter IS NOT NULL
	AND	T2.IsFolder = 1
	AND	T1.DriveLetter = 'D:'
	AND	T2.FullPathName Not Like '%$RECYCLE.BIN%'
	AND	T1.DriveType = 'Local Disk'
ORDER BY	1


;with		root
		as
		(
		SELECT T2.*,1 Lvl 
		FROM dbaadmin.dbo.dbaudf_ListDrives() T1
		CROSS APPLY dbaadmin.dbo.dbaudf_DirectoryList(T1.RootFolder,null) T2
		WHERE T1.DriveLetter IS NOT NULL
		AND	T2.IsFolder = 1
		AND	T1.DriveLetter = 'C:'
		AND	T2.FullPathName Not Like '%$RECYCLE.BIN%'
		AND	T2.FullPathName Not Like '%\RECYCLER\%'
		AND	T2.FullPathName Not Like '%\WINDOWS\%'
		AND	T1.DriveType = 'Local Disk'
		AND	T2.Attributes NOT LIKE '%System%'
		UNION ALL
		SELECT T2.*,Lvl + 1 Lvl 
		FROM root T1
		CROSS APPLY dbaadmin.dbo.dbaudf_DirectoryList(T1.FullPathName,null) T2
		WHERE T2.IsFolder = 1
		AND	T2.FullPathName Not Like '%$RECYCLE.BIN%'
		AND	T2.FullPathName Not Like '%\RECYCLER\%'
		AND	T2.FullPathName Not Like '%\WINDOWS\%'
		AND	T2.Attributes NOT LIKE '%System%'
		)
Select		FullPathName
		,DateModified
		,Lvl
FROM		root
ORDER BY	1
		


	DECLARE @DriveLetter	CHAR(1)
	DECLARE @CMD		nVarChar(4000)

	DECLARE DriveCursor CURSOR
	FOR
		SELECT DISTINCT LEFT(DriveLetter,1) FROM dbaadmin.dbo.dbaudf_ListDrives() Where TotalSize IS Not Null

	OPEN DriveCursor;
	FETCH DriveCursor INTO @DriveLetter;
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			SET @CMD = 'takeown /f '+@DriveLetter+': /r /d y'
				exec xp_cmdshell @CMD
			SET @CMD = 'icacls '+@DriveLetter+':\ /setowner BUILTIN\Administrators /T /C /Q'
				exec xp_cmdshell @CMD
			SET @CMD = 'iCACLS '+@DriveLetter+':\ /T /C /Q /grant BUILTIN\Administrators:(OI)(CI)F /inheritance:e'
				exec xp_cmdshell @CMD
			SET @CMD = 'attrib '+@DriveLetter+':\* -s -r -h /S /D'
				exec xp_cmdshell @CMD
		END
 		FETCH NEXT FROM DriveCursor INTO @DriveLetter;
	END
	CLOSE DriveCursor;
	DEALLOCATE DriveCursor;
