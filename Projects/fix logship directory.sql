
DECLARE		@MostRecent_Full	DATETIME
		,@MostRecent_Diff	DATETIME
		,@MostRecent_Log	DATETIME
		,@CMD			VARCHAR(8000)
		,@DBName		sysname
		,@BackupPath		VARCHAR(8000)
		,@RestorePath		VARCHAR(8000)
		,@FileName		VARCHAR(MAX)
		


SELECT		@DBName			= 'WCDS'
		,@BackupPath		= '\\G1sqla\G1SQLA$A_backup\'
		,@RestorePath		= '\\SEAPLOGSQL01\SEAPLOGSQL01$GMS_backup\LogShip\'


SELECT		@MostRecent_Full	= MAX(CASE [type] WHEN 'D' THEN [backup_start_date] END)
		,@MostRecent_Diff	= MAX(CASE [type] WHEN 'I' THEN [backup_start_date] END)
		,@MostRecent_Log	= MAX(CASE [type] WHEN 'L' THEN [backup_start_date] END)
			
FROM		[msdb].[dbo].[backupset] bs
JOIN		[msdb].[dbo].[backupmediafamily] bmf
	ON	bmf.[media_set_id] = bs.[media_set_id]
WHERE		bs.database_name = @DBName
	AND	name IS NOT NULL
ORDER BY	1  DESC


;WITH		SourceFiles
		AS
		(
		SELECT		*
		FROM		dbaadmin.dbo.dbaudf_Dir(@BackupPath)
		WHERE		LEFT(name,len(@DBName)+1) = @DBName + '_'
			AND	IsFileSystem = 1
			AND	IsFolder = 0
			AND	error IS NULL
		)
		,QueuedFiles
		AS
		(
		SELECT		*
		FROM		dbaadmin.dbo.dbaudf_Dir(@RestorePath+@DBName+'\')
		WHERE		LEFT(name,len(@DBName)+1) = @DBName + '_'
		)
		,ProcessedFiles
		AS
		(
		SELECT		*
		FROM		dbaadmin.dbo.dbaudf_Dir(@RestorePath+@DBName+'\Processed\')
		WHERE		LEFT(name,len(@DBName)+1) = @DBName + '_'
		)
		,
		AppliedFiles
		AS
		(
		SELECT		DISTINCT
				REPLACE([physical_device_name],@RestorePath+@DBName+'\','') AS [name]
		FROM		[msdb].[dbo].[backupset] bs
		JOIN		[msdb].[dbo].[backupmediafamily] bmf
			ON	bmf.[media_set_id] = bs.[media_set_id]
		WHERE		bs.database_name = @DBName
		)

SELECT		@MostRecent_Full	LastAppliedFul
		,@MostRecent_Diff	LastAppliedDif
		,@MostRecent_Log	LastAppliedLog
		,S.*
		,CASE	WHEN A.name IS NOT NULL				THEN 'Applied'
			WHEN Q.name IS NULL AND P.Name Is NULL		THEN 'Not Coppied'
			WHEN Q.name IS NOT NULL AND P.Name IS NULL	THEN 'Not Processed'
			WHEN Q.name IS NULL AND P.Name Is Not NULL	THEN 'Processed'
			END AS [Status]
INTO		#Results			
FROM		SourceFiles S 
LEFT JOIN	QueuedFiles Q 
	ON	Q.name = S.Name
LEFT JOIN	ProcessedFiles P
	ON	P.name = S.Name
LEFT JOIN	AppliedFiles A
	ON	A.name = S.Name
	
		
		
DECLARE MissingFiles CURSOR
FOR
SELECT		[name] 
FROM		#Results
WHERE		[Status] = 'Not Coppied'

OPEN MissingFiles
FETCH NEXT FROM MissingFiles INTO @FileName
WHILE (@@FETCH_STATUS <> -1)
BEGIN
	IF (@@FETCH_STATUS <> -2)
	BEGIN
		PRINT 'Copying File ' + @FileName + ' to ' + @RestorePath +@DBName+'\'
		IF @FileName Like '%.SQT'
			SET @CMD = 'ROBOCOPY ' + @BackupPath + ' ' + @RestorePath+@DBName+'\ ' + @FileName
		ELSE
			SET @CMD = 'ROBOCOPY ' + @BackupPath + ' ' + @RestorePath+@DBName+'\Processed\ ' + @FileName
			
		EXEC dbaadmin.dbo.dbasp_UnlockAndDelete @FileName,1,0,0
		EXEC xp_CmdShell @CMD--, no_output
	END
	FETCH NEXT FROM MissingFiles INTO @FileName
END
CLOSE MissingFiles
DEALLOCATE MissingFiles	

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


GO
DROP TABLE #Results
			
--FROM		[msdb].[dbo].[backupset] bs
--JOIN		[msdb].[dbo].[backupmediafamily] bmf
--	ON	bmf.[media_set_id] = bs.[media_set_id]
--WHERE		bs.database_name = 'WCDS'
--	AND	name IS NOT NULL
--ORDER BY	1  DESC









--SET		@CMD	= 'ROBOCOPY '+@BackupPath+' \\SEAPLOGSQL01\SEAPLOGSQL01$GMS_backup\LogShip\'+@DBName+'\Processed'

--SELECT		@CMD = @CMD + BackupFileName
--FROM		(
--			SELECT		DISTINCT
--						REPLACE([physical_device_name],@BackupPath,' ') BackupFileName		
--			FROM		[msdb].[dbo].[backupset] bs
--			JOIN		[msdb].[dbo].[backupmediafamily] bmf
--					ON	bmf.[media_set_id] = bs.[media_set_id]
--			  WHERE		bs.database_name = @DBName
--					AND	name IS NOT NULL
			  
--					AND	(
--						([type] = 'D' AND [backup_start_date] = @MostRecent_Full) 
--					OR	
--						([type] = 'I' AND [backup_start_date] = @MostRecent_Diff)
--					OR	
--						([type] = 'L' AND [backup_start_date] > @MostRecent_Diff)
--						)
--			)BackupFiles						

--PRINT		@CMD

--EXEC XP_CMDSHELL @CMD



--			SELECT		DISTINCT
--						[physical_device_name]
--			FROM		[msdb].[dbo].[backupset] bs
--			JOIN		[msdb].[dbo].[backupmediafamily] bmf
--					ON	bmf.[media_set_id] = bs.[media_set_id]
--			  WHERE		bs.database_name = 'WCDS'
			  
			  
			  
			  
--/*

--EXEC [dbaadmin].[dbo].[dbasp_Restore_Tranlog]
--	@DBName		= 'WCDS'
--	,@DBPath	= 'E:\MSSQL.1\MSSQL\Data'
--	,@LogPath	= 'F:\MSSQL.1\MSSQL\Log'
	
	
--*/
				  