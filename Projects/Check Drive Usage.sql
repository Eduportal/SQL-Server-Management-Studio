--:R \\seapsqldba01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\ALL_dbaadmin_32_CLR.SQL


--SELECT		*
--FROM		dbaadmin.dbo.dbaudf_ListDrives() 


--select		*
--			,(FreeSpace*100.0)/ISNULL(NULLIF(TotalSize,0),1) AS [PercentFree] 
--From		dbaadmin.dbo.dbaudf_ListDrives();



--SELECT		LD.DriveLetter
--			,CAST(LD.TotalSize/POWER(1024.,3) AS NUMERIC(10,2))				[TotalSize_GB]
--			,CAST(LD.AvailableSpace/POWER(1024.,3) AS NUMERIC(10,2))		[AvailableSpace_GB]
--			,CAST(DBDriveData.Size AS NUMERIC(10,2))						[UsedDB_GB]
--			,CAST((LD.TotalSize/POWER(1024.,3))
--				-(DBDriveData.Size)
--				-(LD.AvailableSpace/POWER(1024.,3)) AS NUMERIC(10,2))		[UsedNonDB_GB]
--			,CAST((LD.AvailableSpace*100.0)/LD.TotalSize AS NUMERIC(10,2))	[% Free]	
--			,LD.DriveType	
--			,LD.FileSystem	
--			,LD.IsReady	
--			,LD.VolumeName
--			,DBDriveData.[DBNames]

--FROM		dbaadmin.dbo.dbaudf_ListDrives() LD
--JOIN		(
--			SELECT		[DriveLetter]
--						,SUM([Size]) [Size]
--						,REPLACE(dbaadmin.[dbo].[dbaudf_ConcatenateUnique]([DB_Name]+':'+Type_desc+'('+ CAST(CAST([Size] AS NUMERIC(10,2)) AS VarChar(50)) + ')'),'.00)',')') [DBNames]
--			FROM		(
--						SELECT		UPPER(LEFT(physical_name,1)) [DriveLetter]
--									,DB_NAME(database_id) [DB_Name]
--									,Type_desc
--									,SUM(size/128./1024.) [Size]

--						FROM		sys.master_files AS f WITH (NOLOCK)
--						GROUP BY	LEFT(physical_name,1)
--									,DB_NAME(database_id)
--									,Type_desc
--						) Data
--			GROUP BY	[DriveLetter]
			
--			) DBDriveData
--	ON		DBDriveData.DriveLetter = LD.DriveLetter
--OPTION (RECOMPILE);
--GO








SELECT		COALESCE([DriveLetter],'TOTAL') [DriveLetter]
			,[DriveSize_GB]
			,[DriveFree_GB]
			,([DriveFree_GB]*100)/[DriveSize_GB] [DriveFree_Pct]
			,COALESCE([FileType],'TOTAL') [FileType]
			,DatabaseName
			,data_space_id
			,[FileCount]
			,[FileSize_GB]
			,([FileSize_GB]*100)/[DriveSize_GB] [PercentOfDrive]
			,([FileSize_GB]*100)/([DriveSize_GB]-[DriveFree_GB]) [PercentOfUsed]
FROM		(
		SELECT		T1.DriveLetter
				,CASE	WHEN SUBSTRING(T2.FullPathName,3,14) = '\$RECYCLE.BIN\' THEN 'RECYCLE BIN'
					WHEN T2.Name LIKE '%ERRORLOG%' THEN 'LOGFILE'
					WHEN T2.Name LIKE '%SQLAGENT%' THEN 'LOGFILE'
					WHEN T3.database_id IS NULL THEN
					case T2.Extension
						WHEN '.BAK'	THEN 'BACKUP'
						WHEN '.DIF'	THEN 'BACKUP'
						WHEN '.TRN'	THEN 'BACKUP'
						WHEN '.cBAK'	THEN 'BACKUP'
						WHEN '.cDIF'	THEN 'BACKUP'
						WHEN '.cTRN'	THEN 'BACKUP'
						WHEN '.SQB'	THEN 'BACKUP'
						WHEN '.SQD'	THEN 'BACKUP'
						WHEN '.SQT'	THEN 'BACKUP'

						WHEN '.LDF'	THEN 'DB_LOG'
						WHEN '.MDF'	THEN 'DB_ROWS'
						WHEN '.NDF'	THEN 'DB_ROWS'

						WHEN '.SQL'	THEN 'SCRIPT'
						WHEN '.GSQL'	THEN 'SCRIPT'
						WHEN '.sqlplan'	THEN 'SQL EXECUTION PLAN'

						WHEN '.CSV'	THEN 'DATAFILE'
						WHEN '.TAB'	THEN 'DATAFILE'
						WHEN '.XML'	THEN 'DATAFILE'
						WHEN '.dat'	THEN 'DATAFILE'
						WHEN '.tsv'	THEN 'DATAFILE'

						WHEN '.HTML'	THEN 'DOC'
						WHEN '.HTM'	THEN 'DOC'
						WHEN '.RPT'	THEN 'DOC'
						WHEN '.RTF'	THEN 'DOC'
						WHEN '.TXT'	THEN 'DOC'
							
						WHEN '.OUT'	THEN 'LOGFILE'
						WHEN '.LOG'	THEN 'LOGFILE'
						WHEN '.1'	THEN 'LOGFILE'
						WHEN '.2'	THEN 'LOGFILE'
						WHEN '.3'	THEN 'LOGFILE'
						WHEN '.4'	THEN 'LOGFILE'
						WHEN '.5'	THEN 'LOGFILE'
						WHEN '.w3c'	THEN 'LOGFILE'

						WHEN '.BLG'	THEN 'PERFMON FILE'
						WHEN '.mdmp'	THEN 'CRASH DUMP FILE'
						WHEN '.trc'	THEN 'SQL TRACE FILE'
						WHEN '.actn'	THEN 'FILE TRANSIT ACTION FILE'

						WHEN '.cmd'	THEN 'BATCH FILE'
						WHEN '.bat'	THEN 'BATCH FILE'
						WHEN '.exe'	THEN 'EXECUTABLE'

						WHEN '.ZIP'	THEN 'PACKAGE'
						WHEN '.RAR'	THEN 'PACKAGE'
						WHEN '.Z'	THEN 'PACKAGE'
						WHEN '.CAB'	THEN 'PACKAGE'
							
						ELSE 'OTHER'
						END
					ELSE ISNULL('DB_' + T3.type_desc,'')
					END AS [FileType]
				,ISNULL(DB_NAME(T3.database_id),'') DatabaseName
				,ISNULL(T3.data_space_id,0) data_space_id
				,MAX(T1.TotalSize/POWER(1024.0,3)) AS [DriveSize_GB]
				,MAX(T1.FreeSpace/POWER(1024.0,3)) AS [DriveFree_GB]
				,count(*) AS [FileCount]
				,SUM(T2.size/power(1024.0,3)) AS [FileSize_GB]
		From		dbaadmin.dbo.dbaudf_ListDrives() T1
		CROSS APPLY	dbaadmin.[dbo].[dbaudf_DirectoryList2](T1.RootFolder,null,1) T2
		LEFT JOIN	sys.master_files T3
			ON	T3.physical_name = T2.FullPathName
		WHERE		NULLIF(T1.RootFolder,'') IS NOT NULL
			AND	T1.DriveLetter != 'C'
		GROUP BY	T1.DriveLetter
				,CASE	WHEN SUBSTRING(T2.FullPathName,3,14) = '\$RECYCLE.BIN\' THEN 'RECYCLE BIN'
					WHEN T2.Name LIKE '%ERRORLOG%' THEN 'LOGFILE'
					WHEN T2.Name LIKE '%SQLAGENT%' THEN 'LOGFILE'
					WHEN T3.database_id IS NULL THEN
					case T2.Extension
						WHEN '.BAK'	THEN 'BACKUP'
						WHEN '.DIF'	THEN 'BACKUP'
						WHEN '.TRN'	THEN 'BACKUP'
						WHEN '.cBAK'	THEN 'BACKUP'
						WHEN '.cDIF'	THEN 'BACKUP'
						WHEN '.cTRN'	THEN 'BACKUP'
						WHEN '.SQB'	THEN 'BACKUP'
						WHEN '.SQD'	THEN 'BACKUP'
						WHEN '.SQT'	THEN 'BACKUP'

						WHEN '.LDF'	THEN 'DB_LOG'
						WHEN '.MDF'	THEN 'DB_ROWS'
						WHEN '.NDF'	THEN 'DB_ROWS'

						WHEN '.SQL'	THEN 'SCRIPT'
						WHEN '.GSQL'	THEN 'SCRIPT'
						WHEN '.sqlplan'	THEN 'SQL EXECUTION PLAN'

						WHEN '.CSV'	THEN 'DATAFILE'
						WHEN '.TAB'	THEN 'DATAFILE'
						WHEN '.XML'	THEN 'DATAFILE'
						WHEN '.dat'	THEN 'DATAFILE'
						WHEN '.tsv'	THEN 'DATAFILE'

						WHEN '.HTML'	THEN 'DOC'
						WHEN '.HTM'	THEN 'DOC'
						WHEN '.RPT'	THEN 'DOC'
						WHEN '.RTF'	THEN 'DOC'
						WHEN '.TXT'	THEN 'DOC'
							
						WHEN '.OUT'	THEN 'LOGFILE'
						WHEN '.LOG'	THEN 'LOGFILE'
						WHEN '.1'	THEN 'LOGFILE'
						WHEN '.2'	THEN 'LOGFILE'
						WHEN '.3'	THEN 'LOGFILE'
						WHEN '.4'	THEN 'LOGFILE'
						WHEN '.5'	THEN 'LOGFILE'
						WHEN '.w3c'	THEN 'LOGFILE'

						WHEN '.BLG'	THEN 'PERFMON FILE'
						WHEN '.mdmp'	THEN 'CRASH DUMP FILE'
						WHEN '.trc'	THEN 'SQL TRACE FILE'
						WHEN '.actn'	THEN 'FILE TRANSIT ACTION FILE'

						WHEN '.cmd'	THEN 'BATCH FILE'
						WHEN '.bat'	THEN 'BATCH FILE'
						WHEN '.exe'	THEN 'EXECUTABLE'

						WHEN '.ZIP'	THEN 'PACKAGE'
						WHEN '.RAR'	THEN 'PACKAGE'
						WHEN '.Z'	THEN 'PACKAGE'
						WHEN '.CAB'	THEN 'PACKAGE'
							
						ELSE 'OTHER'
						END
					ELSE  ISNULL('DB_' + T3.type_desc,'')
					END
				,ISNULL(DB_NAME(T3.database_id),'')
				,ISNULL(T3.data_space_id,0)
			) Data
WHERE		--DriveFree_GB IS NOT NULL
		(FileType IS NULL AND DatabaseName IS NULL AND data_space_id IS NULL) 
		OR
		(FileType IS NOT NULL AND DatabaseName IS NOT NULL AND data_space_id IS NOT NULL) 
ORDER BY	1,5,6,7 



GO



--SELECT		DB_Name(T1.database_id) DatabaseName
--		,LEFT(T1.physical_name,1) DriveLetter
--		,SUM(size_on_disk_bytes/POWER(1024.,3)) Size_GB

--FROM		sys.master_files T1 WITH (NOLOCK)
--CROSS APPLY	sys.dm_io_virtual_file_stats(T1.database_id,T1.file_id) T2

--GROUP BY	DB_Name(T1.database_id)
--		,LEFT(T1.physical_name,1)
--ORDER BY	1,2

--SELECT		DB_Name(T1.database_id) DatabaseName
--		,T1.physical_name
--		,T1.is_sparse
--		,size_on_disk_bytes/POWER(1024.,3) Size_GB
--		,(T1.size*8)/POWER(1024.,2)
--FROM		sys.master_files T1 WITH (NOLOCK)
--CROSS APPLY	sys.dm_io_virtual_file_stats(T1.database_id,T1.file_id) T2

--SELECT		*
--FROM		dbaadmin.[dbo].[dbaudf_DirectoryList2]('E:\Data',null,0)

--SELECT		*
--FROM		dbaadmin.[dbo].[dbaudf_DirectoryList2]('E:\nxt',null,0)



DECLARE		@DBName		SYSNAME
		,@SnapshotDB	BIT
		,@SizeOnDisk	NUMERIC(38,10)
		,@FileSize	NUMERIC(38,10)
		,@CMD		nVarChar(4000)
		,@dbsize	BIGINT
		,@LogSize	BIGINT
		,@ReservedPages	BIGINT
		,@UsedPages	BIGINT
		,@DataPages	BIGINT
		,@IndexPages	BIGINT
		,@FileType	SYSNAME
		,@DataSpaceID	INT
		,@FileGroupName	SYSNAME

DECLARE		@Results	TABLE
		(
		DBName		SYSNAME
		,SnapshotDB	BIT
		,FileType	SYSNAME
		,DataSpaceID	INT NULL
		,FileGroup	SYSNAME NULL
		,SizeOnDisk_GB	NUMERIC(38,10)
		,FileSize_GB	NUMERIC(38,10)
		,Size_GB	NUMERIC(38,10)
		,Reserved_GB	NUMERIC(38,10)
		,Used_GB	NUMERIC(38,10)
		,Data_GB	NUMERIC(38,10)
		,Index_GB	NUMERIC(38,10)
		)

DECLARE DBCursor CURSOR
FOR
SELECT		DB_Name(T1.database_id) DatabaseName
		,CASE WHEN source_database_id IS NULL THEN 0 ELSE 1 END [SnapshotDB]
		,T1.type_desc [FileType]
		,data_space_id
		,SUM(size_on_disk_bytes/POWER(1024.,3)) SizeOnDisk_GB
		,SUM((T1.size*8)/POWER(1024.,2)) Size_GB
FROM		sys.master_files T1 WITH (NOLOCK)
JOIN		sys.dm_io_virtual_file_stats(NULL,NULL) T2
	ON	T2.database_id = T1.database_id
	AND	T2.[file_id] = T1.[file_id]
JOIN		sys.databases T3
	ON	T3.database_id = T1.Database_id
GROUP BY	DB_Name(T1.database_id)
		,CASE WHEN source_database_id IS NULL THEN 0 ELSE 1 END
		,T1.type_desc
		,data_space_id
ORDER BY	1,2,3,4


OPEN DBCursor;
FETCH DBCursor INTO @DBName,@SnapshotDB,@FileType,@DataSpaceID,@SizeOnDisk,@FileSize;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP

		--SELECT @CMD = 'DBCC UPDATEUSAGE ('''+@DBName+''')'
		--EXEC (@CMD)
	
		    Select @cmd = 'use [' + @DBName + ']
    
			select		@dbsize		= sum(convert(bigint,case when status & 64 = 0 then size else 0 end))
					,@logsize	= sum(convert(bigint,case when status & 64 <> 0 then size else 0 end))
					,@FileGroupName = FILEGROUP_NAME(isnull(@DataSpaceID,0))
			from		dbo.sysfiles
			where		groupid		= isnull(@DataSpaceID,0)
	
	 
			Select		@reservedpages	= sum(a.total_pages)
					,@UsedPages	= sum(a.used_pages)
					,@DataPages	= sum(	CASE	
								WHEN it.internal_type IN (202,204)	Then 0
								When a.type <> 1			Then a.used_pages
								When p.index_id < 2			Then a.data_pages
								Else 0 END)
					,@IndexPages	= sum(a.used_pages) -sum(CASE	
								WHEN it.internal_type IN (202,204)	Then 0
								When a.type <> 1			Then a.used_pages
								When p.index_id < 2			Then a.data_pages
								Else 0 END)
			from		sys.partitions p 
			join		sys.allocation_units a 
				on	p.partition_id = a.container_id
			left join	sys.internal_tables it 
				on	p.object_id = it.object_id
			WHERE		a.data_space_id = isnull(@DataSpaceID,0)'

		    EXEC	sp_executesql @cmd, N'@DataSpaceID int,@FileGroupName SYSNAME output,@DBSize bigint output,@LogSize bigint output,@ReservedPages bigint output,@UsedPages bigint output,@DataPages bigint output,@IndexPages bigint output'
					, @DataSpaceID
					, @FileGroupName	output
					, @dbsize		output
					, @LogSize		output
					, @ReservedPages	output
					, @UsedPages		output
					, @DataPages		output
					, @IndexPages		output


		INSERT INTO	@Results
		SELECT		@DBName		
				,@SnapshotDB
				,@FileType
				,@DataSpaceID
				,@FileGroupName
				,@SizeOnDisk	
				,@FileSize	
				,CASE @FileType WHEN 'ROWS' THEN (@dbsize*8)/POWER(1024.,2) ELSE (@LogSize*8)/POWER(1024.,2) END
				,CASE @FileType WHEN 'ROWS' THEN (@ReservedPages*8)/POWER(1024.,2) ELSE 0 END
				,CASE @FileType WHEN 'ROWS' THEN (@UsedPages*8)/POWER(1024.,2) ELSE 0 END
				,CASE @FileType WHEN 'ROWS' THEN (@DataPages*8)/POWER(1024.,2) ELSE 0 END
				,CASE @FileType WHEN 'ROWS' THEN (@IndexPages*8)/POWER(1024.,2) ELSE 0 END

		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM DBCursor INTO @DBName,@SnapshotDB,@FileType,@DataSpaceID,@SizeOnDisk,@FileSize;
END
CLOSE DBCursor;
DEALLOCATE DBCursor;

SELECT		*
FROM		@Results









--SELECT
--    LEFT ([mf].[physical_name], 2) AS [Drive],
--    [vfs].[database_id],
--    DB_NAME ([vfs].[database_id]) AS [DB],
--    [mf].[physical_name],
--    --virtual file latency
--    [ReadLatency] = CASE WHEN [num_of_reads] = 0 THEN 0 ELSE ([io_stall_read_ms] / [num_of_reads]) END,
--    [WriteLatency] = CASE WHEN [num_of_writes] = 0 THEN 0 ELSE ([io_stall_write_ms] / [num_of_writes]) END,
--    [Latency] =   CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0) THEN 0 ELSE ([io_stall] / ([num_of_reads] + [num_of_writes])) END,
--    --avg bytes per IOP
--    [AvgBPerRead] = CASE WHEN [num_of_reads] = 0 THEN 0 ELSE ([num_of_bytes_read] / [num_of_reads]) END,
--    [AvgBPerWrite] = CASE WHEN [io_stall_write_ms] = 0 THEN 0 ELSE ([num_of_bytes_written] / [num_of_writes]) END,
--    [AvgBPerTransfer] = CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0) THEN 0 ELSE (([num_of_bytes_read] + [num_of_bytes_written]) /([num_of_reads] + [num_of_writes])) END
--FROM
--    sys.dm_io_virtual_file_stats (NULL,NULL) AS [vfs]
--JOIN sys.master_files AS [mf]
--    ON [vfs].[database_id] = [mf].[database_id]
--    AND [vfs].[file_id] = [mf].[file_id]
---- WHERE [vfs].[file_id] = 2 -- log files
---- ORDER BY [Latency] DESC
---- ORDER BY [ReadLatency] DESC
--ORDER BY [WriteLatency] DESC;