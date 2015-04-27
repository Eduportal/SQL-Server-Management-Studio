
DECLARE		@MostRecent_Full	DATETIME
		,@MostRecent_Diff	DATETIME
		,@MostRecent_Log	DATETIME
		,@DBName		sysname
		,@BackupPath		VARCHAR(8000)
		,@RestorePath		VARCHAR(8000)
		,@CMD			VarChar(8000)

SELECT		@DBName			= 'WCDS'
		,@BackupPath		= '\\G1sqla\G1SQLA$A_backup\'
		,@RestorePath		= '\\SEAPLOGSQL01\SEAPLOGSQL01$GMS_backup\LogShip\'+@DBName+'\'


SELECT		@MostRecent_Full	= MAX(CASE [type] WHEN 'D' THEN [backup_start_date] END)
		,@MostRecent_Diff	= MAX(CASE [type] WHEN 'I' THEN [backup_start_date] END)
		,@MostRecent_Log	= MAX(CASE [type] WHEN 'L' THEN [backup_start_date] END)
FROM		[msdb].[dbo].[backupset] bs
JOIN		[msdb].[dbo].[backupmediafamily] bmf
	ON	bmf.[media_set_id] = bs.[media_set_id]
WHERE		bs.database_name = @DBName
	AND	name IS NOT NULL
ORDER BY	1  DESC


SET		@CMD	= 'ROBOCOPY '+@BackupPath+' '+@RestorePath

SELECT		@CMD = @CMD + ' '+ BackupFileName
FROM		(
			SELECT		DISTINCT
						REPLACE([physical_device_name],@BackupPath,' ') BackupFileName		
			FROM		[msdb].[dbo].[backupset] bs
			JOIN		[msdb].[dbo].[backupmediafamily] bmf
					ON	bmf.[media_set_id] = bs.[media_set_id]
			  WHERE		bs.database_name = @DBName
					AND	name IS NOT NULL
			  
					AND	(
						([type] = 'D' AND [backup_start_date] = @MostRecent_Full) 
					OR	
						([type] = 'I' AND [backup_start_date] = @MostRecent_Diff)
					OR	
						([type] = 'L' AND [backup_start_date] > @MostRecent_Diff)
						)
			)BackupFiles						

PRINT		@CMD

EXEC XP_CMDSHELL @CMD