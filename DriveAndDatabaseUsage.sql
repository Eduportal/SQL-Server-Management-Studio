USE dbaperf
GO
SET NOCOUNT ON


DECLARE		@DBName			SYSNAME
		,@SnapshotDB		BIT
		,@SizeOnDisk		NUMERIC(38,10)
		,@FileSize		NUMERIC(38,10)
		,@CMD			nVarChar(4000)
		,@dbsize		BIGINT
		,@LogSize		BIGINT
		,@ReservedPages		BIGINT
		,@UsedPages		BIGINT
		,@DataPages		BIGINT
		,@IndexPages		BIGINT
		,@FileType		SYSNAME
		,@DataSpaceID		INT
		,@FileGroupName		SYSNAME
		,@DriveLetter		CHAR(1)
		,@DriveSize_GB		NUMERIC(38,10)
		,@DriveFree_GB		NUMERIC(38,10)
		,@FileCount		INT
		,@FileSize_GB		NUMERIC(38,10)
		,@Pct_Unused		FLOAT
		,@Pct_Data		FLOAT
		,@Pct_Index		FLOAT
		,@RunDate		DateTime
		,@FileName		VarChar(max)
		,@TableName		SYSNAME
		,@SCRIPT		VarChar(8000)
		,@Output_Path		VarChar(max)
		,@target_env		SYSNAME
		,@target_server		SYSNAME
		,@target_share		SYSNAME
		,@retry_limit		INT
		,@RC			INT

DECLARE		@Results		TABLE
		(
		DriveLetter		CHAR(1)
		,FileType		SYSNAME
		,DBName			SYSNAME
		,DataSpaceID		INT NULL
		,FileGroup		SYSNAME NULL
		,DriveSize_GB		NUMERIC(38,10)
		,DriveFree_GB		NUMERIC(38,10)
		,FileCount		INT
		,FileSize_GB		NUMERIC(38,10)
		,UnUsed_GB		NUMERIC(38,10)
		,Data_GB		NUMERIC(38,10)
		,Index_GB		NUMERIC(38,10)
		)

SELECT		@TableName	= 'Drive_Stats_Log'
		,@Output_Path	= '\\'+REPLACE(@@ServerName,'\'+@@ServiceName,'')+'\'+REPLACE(@@ServerName,'\','$')+'_dbasql\dba_reports'
		,@target_env	= 'amer'
		,@target_server	= 'SEAPDBASQL01'
		,@target_share	= 'SEAPDBASQL01_dbasql\DiskSpaceChecks'
		,@retry_limit	= 5
		,@RunDate	= CONVERT(VarChar(12),GetDate(),101)
		,@FileName	= REPLACE([dbaadmin].[dbo].[dbaudf_base64_encode] (@@SERVERNAME+'|'+REPLACE(@TableName,'dbaperf.dbo.',''))+'.dat','=','$')
		,@SCRIPT	= 'bcp "SELECT * FROM [dbaperf].[dbo].['+@TableName+'] WHERE [RunDate] = '''+CONVERT(VarChar(12),@RunDate,101)+'''" queryout "'+@Output_Path+'\'+@FileName+'" -S '+@@Servername+' -T -N'


DECLARE DBCursor CURSOR
FOR
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


OPEN DBCursor;
FETCH DBCursor INTO @DriveLetter,@FileType,@DBName,@DataSpaceID,@DriveSize_GB,@DriveFree_GB,@FileCount,@FileSize_GB;

	

WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
		SELECT	@FileGroupName	= NULL
			,@Pct_Unused	= NULL
			,@Pct_Data	= NULL
			,@Pct_Index	= NULL


		--SELECT @CMD = 'DBCC UPDATEUSAGE ('''+@DBName+''')'
		--EXEC (@CMD)
		IF @FileType = 'DB_ROWS'
		BEGIN
		    Select @cmd = 'use [' + @DBName + ']
    
			select		@FileGroupName = FILEGROUP_NAME(isnull(@DataSpaceID,0)) --select *
			from		dbo.sysfiles 
			where		groupid		= isnull(@DataSpaceID,0)
	
	 
			SELECT		@Pct_Unused	= ([UnusedPages]*100.0)/[TotalPages]	--[Pct_Unused]
					,@Pct_Data	= ([DataPages]*100.0)/[TotalPages]	--[Pct_Data]
					,@Pct_Index	= ([IndexPages]*100.0)/[TotalPages]	--[Pct_Index]
			FROM		(		
					Select		sum(a.total_pages) [TotalPages]
							,sum(a.total_pages)-sum(a.used_pages) [UnusedPages]
							,sum(	CASE	
								WHEN it.internal_type IN (202,204)	Then 0
								When a.type <> 1			Then a.used_pages
								When p.index_id < 2			Then a.data_pages
								Else 0 END) [DataPages]
							,sum(a.used_pages) 
							 -sum(	CASE	
								WHEN it.internal_type IN (202,204)	Then 0
								When a.type <> 1			Then a.used_pages
								When p.index_id < 2			Then a.data_pages
								Else 0 END) [IndexPages]
					from		sys.partitions p 
					join		sys.allocation_units a 
						on	(a.type IN (1,3) AND p.hobt_id = a.container_id)
						or	(a.type IN (2) AND p.partition_id = a.container_id)
					left join	sys.internal_tables it 
						on	p.object_id = it.object_id
					WHERE		a.data_space_id = isnull(@DataSpaceID,0)
					) Data'

		    EXEC	sp_executesql @cmd, N'@DataSpaceID int,@FileGroupName SYSNAME output,@Pct_Unused Float output,@Pct_Data Float output,@Pct_Index Float output'
						,@DataSpaceID
						,@FileGroupName	output
						,@Pct_Unused	output
						,@Pct_Data	output
						,@Pct_Index	output
		END

		INSERT INTO	@Results
		SELECT		@DriveLetter
				,@FileType
				,@DBName		
				,@DataSpaceID
				,@FileGroupName
				,@DriveSize_GB
				,@DriveFree_GB
				,@FileCount
				,@FileSize_GB	
				,CASE @FileType WHEN 'DB_ROWS' THEN ISNULL((@Pct_Unused * @FileSize_GB)/100.0,0) ELSE 0 END
				,CASE @FileType WHEN 'DB_ROWS' THEN ISNULL((@Pct_Data * @FileSize_GB)/100.0,0) ELSE 0 END
				,CASE @FileType WHEN 'DB_ROWS' THEN ISNULL((@Pct_Index * @FileSize_GB)/100.0,0) ELSE 0 END

		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM DBCursor INTO @DriveLetter,@FileType,@DBName,@DataSpaceID,@DriveSize_GB,@DriveFree_GB,@FileCount,@FileSize_GB;
END
CLOSE DBCursor;
DEALLOCATE DBCursor;


IF OBJECT_ID('[dbo].[Drive_Stats_Log]') IS NULL
	EXEC('CREATE TABLE [dbo].[Drive_Stats_Log](
	[ServerName] [nvarchar](128) NULL,
	[RunDate] [datetime] NULL,
	[DriveLetter] [char](1) NULL,
	[FileType] [sysname] NOT NULL,
	[DBName] [sysname] NOT NULL,
	[DataSpaceID] [int] NULL,
	[FileGroup] [sysname] NULL,
	[DriveSize_GB] [numeric](38, 10) NULL,
	[DriveFree_GB] [numeric](38, 10) NULL,
	[FileCount] [int] NULL,
	[FileSize_GB] [numeric](38, 10) NULL,
	[UnUsed_GB] [numeric](38, 10) NULL,
	[Data_GB] [numeric](38, 10) NULL,
	[Index_GB] [numeric](38, 10) NULL
	) ON [PRIMARY]')
ELSE
	DELETE	[dbo].[Drive_Stats_Log]
	WHERE	[RunDate] = @RunDate

INSERT INTO	[dbo].[Drive_Stats_Log]
SELECT		@@ServerName	[ServerName]
		,@RunDate	[RunDate]
		,*
FROM		@Results



		RAISERROR('  Exporting Data from %s to file %s.',-1,-1,@TableName,@FileName) WITH NOWAIT
		EXEC	@RC=xp_cmdshell @SCRIPT, no_output
		
		IF @RC <> 0
		BEGIN
			RAISERROR('    *** ERROR Exporting Data from %s to file %s. ***',-1,-1,@TableName,@FileName) WITH NOWAIT
			RAISERROR(@SCRIPT,-1,-1) WITH NOWAIT
			GOTO ENDOFCODE
		END

		RAISERROR('  Sending Data from %s.',-1,-1,@TableName) WITH NOWAIT
		EXEC	@RC=[dbaadmin].[dbo].[dbasp_File_Transit] 
				@source_name		= @FileName
				,@source_path		= @Output_Path
				,@target_env		= @target_env
				,@target_server		= @target_server
				,@target_share		= @target_share
				,@retry_limit		= @retry_limit

  		IF @RC <> 0
		BEGIN
			RAISERROR('    *** ERROR Sending Data from %s. ***',-1,-1,@TableName) WITH NOWAIT
			GOTO ENDOFCODE
		END

		waitfor delay '00:00:05'  
  
		-- DELETE FILE AFTER SENDING
		RAISERROR('  Deleting file %s after sending.',-1,-1,@FileName) WITH NOWAIT
		SET		@SCRIPT = 'DEL "'+ @Output_Path+'\'+@FileName+'"'
		exec	@RC=xp_cmdshell @Script, no_output

		IF @RC <> 0
		BEGIN
			RAISERROR('    *** ERROR Deleting file %s after sending. ***',-1,-1,@FileName) WITH NOWAIT
			RAISERROR(@SCRIPT,-1,-1) WITH NOWAIT
			GOTO ENDOFCODE
		END

ENDOFCODE:
 
 GO
