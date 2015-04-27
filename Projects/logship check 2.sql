
--DECLARE		@MostRecent_Full	DATETIME
--		,@MostRecent_Diff	DATETIME
--		,@MostRecent_Log	DATETIME
--		,@CMD			VARCHAR(8000)
--		,@DBName		sysname
--		,@BackupPath		VARCHAR(8000)
--		,@RestorePath		VARCHAR(8000)
--		,@FileName		VARCHAR(MAX)
		


--SELECT		@DBName			= 'WCDS'
--		,@BackupPath		= '\\G1sqla\G1SQLA$A_backup\'
--		,@RestorePath		= '\\SEAPLOGSQL01\SEAPLOGSQL01$GMS_backup\LogShip\'


--SELECT		MostRecent_Full		= MAX(CASE [type] WHEN 'D' THEN [backup_start_date] END)
--		,MostRecent_Diff	= MAX(CASE [type] WHEN 'I' THEN [backup_start_date] END)
--		,MostRecent_Log		= MAX(CASE [type] WHEN 'L' THEN [backup_start_date] END)
			
--FROM		[msdb].[dbo].[backupset] bs
--JOIN		[msdb].[dbo].[backupmediafamily] bmf
--	ON	bmf.[media_set_id] = bs.[media_set_id]
--WHERE		bs.database_name = @DBName
--	AND	name IS NOT NULL
--ORDER BY	1  DESC


--GO


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

SELECT		S.name
		,S.ModifyDate
		,CASE	WHEN A.name IS NOT NULL				THEN 'Applied'
			WHEN Q.name IS NULL AND P.Name Is NULL		THEN 'Not Coppied'
			WHEN Q.name IS NOT NULL AND P.Name IS NULL	THEN 'Not Processed'
			WHEN Q.name IS NULL AND P.Name Is Not NULL	THEN 'Processed'
			END AS [Status]
FROM		SourceFiles S 
LEFT JOIN	QueuedFiles Q 
	ON	Q.name = S.Name
LEFT JOIN	ProcessedFiles P
	ON	P.name = S.Name
LEFT JOIN	AppliedFiles A
	ON	A.name = S.Name