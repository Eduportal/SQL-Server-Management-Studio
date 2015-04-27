

	

DECLARE		@DBName		SYSNAME
		,@RestorePath		VARCHAR(MAX)
		,@FileName	VARCHAR(MAX)
		,@CMD		VarChar(8000)

SELECT		@DBName		= 'WCDS'
		,@RestorePath		= '\\SEAPLOGSQL01\SEAPLOGSQL01$GMS_backup\LogShip\'

DECLARE PurgeOldFiles CURSOR
FOR
SELECT		FullPathName
FROM		dbaadmin.dbo.dbaudf_FileAccess_Dir(@RestorePath+@DBName+'\Processed',0,1)
WHERE		REPLACE(type,' File','') IN ('SQD','SQB','SQL Backup')
	AND	REPLACE(FullPathName,'\Processed\','\') NOT IN	(
								SELECT		DISTINCT
										[physical_device_name]
								FROM		[msdb].[dbo].[backupset] bs
								JOIN		[msdb].[dbo].[backupmediafamily] bmf
									ON	bmf.[media_set_id] = bs.[media_set_id]
								WHERE		bs.database_name = @DBName		
								)

OPEN PurgeOldFiles
FETCH NEXT FROM PurgeOldFiles INTO @FileName
WHILE (@@FETCH_STATUS <> -1)
BEGIN
	IF (@@FETCH_STATUS <> -2)
	BEGIN
		PRINT 'Moving File ' + @FileName + ' From \Processed.'
		SET @CMD = 'MOVE ' + @FileName + ' ' + @RestorePath+@DBName+'\'
		EXEC dbaadmin.dbo.dbasp_UnlockAndDelete @FileName,1,0,0
		EXEC xp_CmdShell @CMD, no_output
	END
	FETCH NEXT FROM PurgeOldFiles INTO @FileName
END
CLOSE PurgeOldFiles
DEALLOCATE PurgeOldFiles		



--SQL error 4305: SQL error 4305: The log in this backup set begins at LSN 825370000002716700001, which is too recent to apply to the database. An earlier log backup that includes LSN 825370000000650800001 can be restored.