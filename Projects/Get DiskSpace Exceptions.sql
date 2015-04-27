

DECLARE @Results TABLE (Value NVARCHAR(100), Data NVARCHAR(100))


exec [sys].[xp_instance_regwrite] N'HKEY_LOCAL_MACHINE',N'Software\GettyImages\Script\DiskMonitor','XX','reg_sz','0'
exec [sys].[xp_instance_regdeletevalue] N'HKEY_LOCAL_MACHINE',N'Software\GettyImages\Script\DiskMonitor','XX'



INSERT INTO @Results
exec [sys].[xp_instance_regenumvalues] N'HKEY_LOCAL_MACHINE',N'Software\GettyImages\Script\DiskMonitor'


SELECT		T1.DriveLetter
		,T1.VolumeName
		,T1.TotalSize /POWER(1024.0,3) SizeGB
		,T1.FreeSpace /POWER(1024.0,3) FreeGB
		,(((T1.TotalSize - T1.FreeSpace) * 100)/ T1.TotalSize) PercentFull
		,T2.Data PercentFullOverride
		,Alert = CASE
				WHEN T2.Data = 0 THEN 0 
				WHEN (((T1.TotalSize - T1.FreeSpace) * 100)/ T1.TotalSize) >= COALESCE(T2.Data,90) THEN 1 
				ELSE 0 END
		,*	
FROM		dbaadmin.dbo.dbaudf_ListDrives() T1
LEFT JOIN	@Results T2
	ON	CAST(T1.DriveLetter AS VarCHAR(50)) = CAST(T2.Value AS VarCHAR(50))
WHERE		T1.IsReady = 1
	AND	DriveType = 'Fixed'


