


	SET NOCOUNT ON
	SET ANSI_NULLS ON
	SET ANSI_WARNINGS ON

/*
-- SECTIONS
	-- GATHER FILES
	-- BUILD SCRIPT


-- COPY THEN RESTORE
-- REMOTE RESTORE


--EXAMPLE USAGE

	-- FROM SERVER TO SELF	(USING BACKUP SHARES)
	-- FROM SELF TO SERVER	(USING BACKUP SHARES)
	-- FROM SELF TO SELF	(USING BACKUP SHARES)
	-- FROM PATH TO SELF	(REMOTE PATH AND LOCAL SHARE)

	'\\SEAPSDTSQLB\SEAPSDTSQLB$B_backup' 'StackFactors'
	'\\SEAPSQLDPLY01\SEAPSQLDPLY01_backup\test_destination\Done' 'Getty_Master'

	'\\SEAPSQLDPLY01\SEAPSQLDPLY01_backup\test_destination\Done\Getty_Master_db_20130822163737_set_01_of_32.SQB'

*/

-- RESTORE	DATABASE
USE [DBAADMIN]
GO

	


DECLARE		@DBName			SYSNAME		= 'Getty_Images_US_Inc__MSCRM'--'StackFactors'
		,@NewDBName		SYSNAME		= NULL --'xxx'
		,@FilePath		VarChar(MAX)	= NULL --'\\SEAPSDTSQLB\SEAPSDTSQLB$B_backup'
		,@FromServer		SYSNAME		= 'SEAPCRMSQL1A' --NULL
		,@WorkDir		VarChar(MAX)	= NULL
		,@RestoreToDateTime	DateTime	= NULL --'2013-10-08 08:30:00.000'	
		,@LeaveNORECOVERY	BIT		= 0
		,@NoLogRestores		BIT		= 0
		,@NoDifRestores		BIT		= 0
		,@filegroups		VARCHAR(MAX)	= 'PRIMARY,FG2' --NULL
		,@Verbose		INT		= 0 -- -1=NO NOUTPUT, 0=ONLY ERRORS, 1=INFO MESSAGES, 2=INFO AND OUTPUT
		,@FullReset		BIT		= 1
		,@IgnoreSpaceLimits	BIT		= 1
		,@syntax_out		VarChar(max)	= NULL
		,@OverrideXML		XML		= NULL

--'<RestoreFileLocations>
--  <Override LogicalName="StackFactors" PhysicalName="I:\Data\StackFactors.mdf" New_PhysicalName="X:\MSSQL\Data\XXX_StackFactors_data.mdf" />
--  <Override LogicalName="StackFactors_log" PhysicalName="J:\Log\StackFactors_log.ldf" New_PhysicalName="X:\MSSQL\Log\XXX_StackFactors_log.ldf" />
--</RestoreFileLocations>'

	SET NOCOUNT ON
	SET ANSI_NULLS ON
	SET ANSI_WARNINGS ON

BEGIN	-- VARIABLE AND TEMP TABLE DECLARATIONS			
	DECLARE		@BackupEngine		VarChar(50)
			,@BackupTimeStamp	DATETIME
			,@BackupType		VarChar(10)
			,@CMD			VARCHAR(MAX)
			,@CMD2			VARCHAR(MAX)
			,@CMD3			NVARCHAR(4000)
			,@CMD4			NVARCHAR(4000)
			,@ColID			INT
			,@ColName1		SYSNAME
			,@ColName2		SYSNAME
			,@ColName3		SYSNAME
			,@ColName4		SYSNAME
			,@ColName5		SYSNAME
			,@ColName6		SYSNAME
			,@ColName7		SYSNAME
			,@ColName8		SYSNAME
			,@ColName9		SYSNAME
			,@ColumnName		SYSNAME
			,@ColumnSize		INT
			,@DataPath		VarChar(500)
			,@DriveFreeSpace	BIGINT
			,@DriveLetter		SYSNAME
			,@ExistingSize		BIGINT
			,@FileGroup		SYSNAME
			,@FileName		VARCHAR(MAX)
			,@FileNameSet		VarChar(MAX)
			,@FilesRestored		INT
			,@FMT1			VarChar(max)
			,@FMT2			VarChar(max)
			,@FullPathName		VarChar(max)
			,@HeaderLine		VarChar(max)
			,@LogicalName		SYSNAME
			,@LogPath		VarChar(500)
			,@NDFPath		VarChar(500)
			,@NewPhysicalName	VarChar(8000)
			,@NOW			VarChar(20)
			,@partial_flag		BIT
			,@RedGateInstalled	BIT
			,@RestoreOrder		INT
			,@SetNumber		INT
			,@SetSize		INT
			,@Size			BIGINT
			,@SkipFlag		bit
			,@TBL			VarChar(max)
			,@XML			XML
			,@xtype			INT

			--,@AgentJob		SYSNAME
			--,@CMD_TYPE		CHAR(3)
			--,@CnD_CMD		VARCHAR(8000)
			--,@CopyThreads		INT
			--,@COPY_CMD		VARCHAR(MAX)
			--,@CreateEndpoint	VarChar(MAX)
			--,@errorcode		INT
			--,@Extension		VARCHAR(MAX)
			--,@files			VARCHAR(MAX)
			--,@LocalEndpointID	INT
			--,@LocalEndpointName	SYSNAME
			--,@LocalEndpointPort	INT
			--,@Local_FQDN		SYSNAME
			--,@MachineName		SYSNAME
			--,@MaxSize		BIGINT
			--,@MostRecent_Diff	DATETIME
			--,@MostRecent_Full	DATETIME
			--,@MostRecent_Log	DATETIME
			--,@PhysicalName		VarChar(8000)
			--,@RemoteEndpointID	INT
			--,@RemoteEndpointName	SYSNAME
			--,@RemoteEndpointPort	INT
			--,@Remote_FQDN		SYSNAME
			--,@RtnCode		INT
			--,@ShareName		VarChar(500)
			--,@sqlerrorcode		INT
	--DECLARE		@CopyAndDeletes		TABLE (CnD_CMD VarChar(max))

	DECLARE		@VDR		TABLE	-- ValidDateRanges	
			(
			BackupDateRange_Start DATETIME
			, BackupDateRange_End DATETIME
			)

	DECLARE		@SF		TABLE	-- SourceFiles		
			(
			[Mask]			[nvarchar](4000) NULL,
			[DBName]		SYSNAME NULL,
			[BackupTimeStamp]	DATETIME NULL,
			[BackupType]		[nvarchar](4000) NULL,
			[BackupEngine]		VarChar(50) NULL,
			[BackupSetSize]		INT NULL,
			[Files]			INT NULL,
			[Name]			[nvarchar](4000) NULL,
			[FullPathName]		[nvarchar](4000) NULL,
			[Directory]		[nvarchar](4000) NULL,
			[Extension]		[nvarchar](4000) NULL,
			[DateCreated]		[datetime] NULL,
			[DateAccessed]		[datetime] NULL,
			[DateModified]		[datetime] NULL,
			[Attributes]		[nvarchar](4000) NULL,
			[Size_GB]		[bigint] NULL
			)				
			
	DECLARE		@HL		TABLE	-- HeaderList		
			(
			BackupName		nvarchar(128), 
			BackupDescription	nvarchar(255) ,
			BackupType		smallint ,
			ExpirationDate		datetime ,
			Compressed		bit ,
			Position		smallint ,
			DeviceType		tinyint ,
			UserName		nvarchar(128) ,
			ServerName		nvarchar(128) ,
			DatabaseName		nvarchar(128) ,
			DatabaseVersion		int ,
			DatabaseCreationDate	datetime ,
			BackupSize		numeric(20,0) ,
			FirstLSN		numeric(25,0) ,
			LastLSN			numeric(25,0) ,
			CheckpointLSN		numeric(25,0) ,
			DatabaseBackupLSN	numeric(25,0) ,
			BackupStartDate		datetime ,
			BackupFinishDate	datetime ,
			SortOrder		smallint ,
			CodePage		smallint ,
			UnicodeLocaleId		int ,
			UnicodeComparisonStyle	int ,
			CompatibilityLevel	tinyint ,
			SoftwareVendorId	int ,
			SoftwareVersionMajor	int ,
			SoftwareVersionMinor	int ,
			SoftwareVersionBuild	int ,
			MachineName		nvarchar(128) ,
			Flags			int ,
			BindingID		uniqueidentifier ,
			RecoveryForkID		uniqueidentifier ,
			Collation		nvarchar(128) ,
			FamilyGUID		uniqueidentifier ,
			HasBulkLoggedData	bit ,
			IsSnapshot		bit ,
			IsReadOnly		bit ,
			IsSingleUser		bit ,
			HasBackupChecksums	bit ,
			IsDamaged		bit ,
			BeginsLogChain		bit ,
			HasIncompleteMetaData	bit ,
			IsForceOffline		bit ,
			IsCopyOnly		bit ,
			FirstRecoveryForkID	uniqueidentifier ,
			ForkPointLSN		numeric(25,0) NULL,
			RecoveryModel		nvarchar(60) ,
			DifferentialBaseLSN	numeric(25,0) NULL,
			DifferentialBaseGUID	uniqueidentifier ,
			BackupTypeDescription	nvarchar(60) ,
			BackupSetGUID		uniqueidentifier NULL ,
			CompressedBackupSize	bigint NULL,
			containment		bit,
			BackupFileName		[nvarchar](4000) NULL,
			[BackupDateRange_Start]	datetime NULL,
			[BackupDateRange_End]	datetime NULL,
			[BackupChainStartDate]	datetime NULL,
			[BackupLinkStartDate]	datetime NULL
			)

	DECLARE		@FL		TABLE	-- FileList		
			(
			LogicalName		NVARCHAR(128) NULL, 
			PhysicalName		NVARCHAR(260) NULL, 
			type			CHAR(1), 
			FileGroupName		NVARCHAR(128) NULL, 
			SIZE			NUMERIC(20,0), 
			MaxSize			NUMERIC(20,0),
			FileId			BIGINT,
			CreateLSN		NUMERIC(25,0),
			DropLSN			NUMERIC(25,0),
			UniqueId		VARCHAR(50),
			ReadOnlyLSN		NUMERIC(25,0),
			ReadWriteLSN		NUMERIC(25,0),
			BackupSizeInBytes	BIGINT,
			SourceBlockSize		INT,
			FileGroupId		INT,
			LogGroupGUID		VARCHAR(50) NULL,
			DifferentialBaseLSN	NUMERIC(25,0),
			DifferentialBaseGUID	VARCHAR(50),
			IsReadOnly		BIT,
			IsPresent		BIT,
			TDEThumbprint		NVARCHAR(128) NULL,
			New_PhysicalName	NVARCHAR(1000) NULL,
			BackupFileName		NVARCHAR(4000) NULL
			)

	IF OBJECT_ID('tempdb..#FileGroups') IS NOT NULL	
		DROP TABLE #FileGroups
			
	IF OBJECT_ID('tempdb..#TMP1') IS NOT NULL	
		DROP TABLE #TMP1

	IF OBJECT_ID('tempdb..#TMP2') IS NOT NULL	
		DROP TABLE #TMP2

	IF OBJECT_ID('tempdb..#TMP3') IS NOT NULL	
		DROP TABLE #TMP3

	IF OBJECT_ID('tempdb..#TMP4') IS NOT NULL	
		DROP TABLE #TMP4

	IF OBJECT_ID('tempdb..#TMP5') IS NOT NULL	
		DROP TABLE #TMP5

	IF OBJECT_ID('tempdb..#DBFileSpaceCheck') IS NOT NULL	
		DROP TABLE #DBFileSpaceCheck

	IF OBJECT_ID('tempdb..#filelist') IS NOT NULL
		DROP TABLE #filelist

	IF OBJECT_ID('tempdb..#filelist_last') IS NOT NULL
		DROP TABLE #filelist_last

	CREATE TABLE	#filelist		
			(
			LogicalName		NVARCHAR(128) NULL, 
			PhysicalName		NVARCHAR(260) NULL, 
			type			CHAR(1), 
			FileGroupName		NVARCHAR(128) NULL, 
			SIZE			NUMERIC(20,0), 
			MaxSize			NUMERIC(20,0),
			FileId			BIGINT,
			CreateLSN		NUMERIC(25,0),
			DropLSN			NUMERIC(25,0),
			UniqueId		VARCHAR(50),
			ReadOnlyLSN		NUMERIC(25,0),
			ReadWriteLSN		NUMERIC(25,0),
			BackupSizeInBytes	BIGINT,
			SourceBlockSize		INT,
			FileGroupId		INT,
			LogGroupGUID		VARCHAR(50) NULL,
			DifferentialBaseLSN	NUMERIC(25,0),
			DifferentialBaseGUID	VARCHAR(50),
			IsReadOnly		BIT,
			IsPresent		BIT,
			TDEThumbprint		NVARCHAR(128) NULL,
			New_PhysicalName	NVARCHAR(1000) NULL,
			BackupFileName		nvarchar(4000) NULL
			)

END	-- VARIABLE AND TEMP TABLE DECLARATIONS

BEGIN	-- VARIABLE INITIALIZATIONS AND PARAMETER CHECKING	
	
	SELECT		@NOW			= REPLACE(REPLACE(REPLACE(CONVERT(VarChar(50),getdate(),120),'-',''),':',''),' ','')
			,@DataPath		= dbaadmin.[dbo].[dbaudf_GetSharePath](dbaadmin.[dbo].[dbaudf_getShareUNC]('mdf'))
			,@NdfPath		= COALESCE(dbaadmin.[dbo].[dbaudf_GetSharePath](dbaadmin.[dbo].[dbaudf_getShareUNC]('ndf')),@DataPath)
			,@LogPath		= dbaadmin.[dbo].[dbaudf_GetSharePath](dbaadmin.[dbo].[dbaudf_getShareUNC]('ldf'))
			,@FilesRestored		= 0
			,@NewDBName		= COALESCE(@NewDBName,@DBName)


	IF @FromServer	IS NOT NULL
	BEGIN
		SET @FilePath = '\\'+ LEFT(@FromServer,CHARINDEX('\',@FromServer+'\')-1)+'\'+REPLACE(@FromServer,'\','$')+'_Backup' -- '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup'
	END

	IF @DataPath IS NULL
	BEGIN
		PRINT ''
		RAISERROR('    -- ERROR: THE DBA "_MDF" SHARE DOES NOT EXIST OR IS INVALID.',-1,-1) WITH NOWAIT
		GOTO SkipRestore
	END

	IF @LogPath IS NULL
	BEGIN
		PRINT ''
		RAISERROR('    -- ERROR: THE DBA "_LDF" SHARE DOES NOT EXIST OR IS INVALID.',-1,-1) WITH NOWAIT
		GOTO SkipRestore
	END

	IF OBJECT_ID('master.dbo.sqlbackup') IS NULL
		SET @RedGateInstalled = 0
	ELSE
		SET @RedGateInstalled = 1

END	-- VARIABLE INITIALIZATIONS AND PARAMETER CHECKING

BEGIN	-- GATHER LIST OF BACKUP FILES				

	DELETE		@SF

	INSERT INTO	@SF
	SELECT		*
	FROM		dbaadmin.dbo.dbaudf_BackupScripter_GetBackupFiles(@DBName,@FilePath)


	IF @NoLogRestores = 1
		DELETE
		FROM		@SF
		WHERE		BackupType = 'tlog'

	IF @NoDifRestores = 1
		DELETE
		FROM		@SF
		WHERE		BackupType = 'dfntl'

	IF @RedGateInstalled = 0
	BEGIN
		DELETE
		FROM		@SF
		WHERE		BackupEngine = 'RedGate'

		IF @@ROWCOUNT > 0
			RAISERROR('    -- REDGATE BACKUP FILES WERE NOT USABLE BECAUSE REDGATE IS NOT INSTALLED',-1,-1) WITH NOWAIT

	END

	IF NOT EXISTS(SELECT * FROM @SF)
	BEGIN
		PRINT ''
		RAISERROR('    -- NO SUITABLE BACKUP FILES EXIST',-1,-1) WITH NOWAIT
		GOTO SkipRestore
	END
END	-- GATHER LIST OF BACKUP FILES

BEGIN	-- CHECK BACKUP FILES					

	IF @Verbose >= 1
		RAISERROR('  -- Checking Backup Files',-1,-1) WITH NOWAIT
	
	DECLARE BackupFileCheckCursor CURSOR
	FOR
	SELECT		DISTINCT
			T1.BackupTimeStamp
			,T1.[BackupSetSize]
			,T1.[Name]
			,T2.FullPathName
	FROM		@SF T1
	CROSS APPLY	dbaadmin.dbo.dbaudf_DirectoryList2(@FilePath,T1.Name,0) T2
	ORDER BY	T1.BackupTimeStamp

	OPEN BackupFileCheckCursor
	FETCH NEXT FROM BackupFileCheckCursor INTO @BackupTimeStamp,@SetSize,@FileName,@FullPathName
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			SELECT		@SetNumber	= CASE	WHEN CHARINDEX('_set_',@FullPathName) > 0 
								THEN dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(@FullPathName,'_','|'),'.','|'),REPLACE(@DBName,'_','|'),@DBName),7) 
								ELSE 1 
								END
			IF @SetNumber = 1
			BEGIN
				INSERT INTO	@FL
				SELECT		*
				FROM		dbaadmin.dbo.dbaudf_BackupScripter_GetFileList (@DBName,@NewDBName,@SetSize,@FileName,@FullPathName,@OverrideXML,@NOW,@DataPath,@NdfPath,@LogPath)
						
				INSERT INTO	@HL														
				SELECT		*,null,null,null,null												
				FROM		dbaadmin.dbo.dbaudf_BackupScripter_GetHeaderList (@SetSize,@FileName,@FullPathName)				
			END
		END
		FETCH NEXT FROM BackupFileCheckCursor INTO @BackupTimeStamp,@SetSize,@FileName,@FullPathName
	END

	CLOSE BackupFileCheckCursor
	DEALLOCATE BackupFileCheckCursor

END	-- CHECK BACKUP FILES

BEGIN	-- GENERATE FILEGROUP LIST				

	SELECT		FileGroupName
			,FileGroupId
			,CASE MIN(CAST(IsPresent AS INT)) WHEN 0 THEN 1 ELSE 0 END [HasFGExcluded]
			,MAX(CAST(IsPresent AS INT)) [HasFGIncluded]
	INTO		#FileGroups
	FROM		@FL
	WHERE		FileGroupId > 0
	GROUP BY	FileGroupName
			,FileGroupId

	IF @filegroups IS NOT NULL 
	BEGIN
		SELECT		T1.*
				,CASE WHEN T2.SplitValue IS NOT NULL THEN 1 ELSE 0 END [BeingRestored]
		INTO		#TMP5
		FROM		#FileGroups T1
		LEFT JOIN	[dbaadmin].[dbo].[dbaudf_StringToTable](@filegroups,',') T2
			ON	T1.FileGroupName = T2.SplitValue

		IF @Verbose >= 1
		BEGIN
			DECLARE CreateHeadersCursor CURSOR
			FOR
			SELECT		name
					,xtype
					,colid
			FROM		TempDB..syscolumns
			WHERE		id = OBJECT_ID('tempdb..#TMP5')
			ORDER BY	colid

			SELECT		@FMT1		= ''
					,@FMT2		= ''
					,@HeaderLine	= ''

			OPEN CreateHeadersCursor
			FETCH NEXT FROM CreateHeadersCursor INTO @ColumnName,@xtype,@ColID
			WHILE (@@fetch_status <> -1)
			BEGIN
				IF (@@fetch_status <> -2)
				BEGIN
					SET @CMD3 = 'SET ANSI_WARNINGS OFF;SELECT @ColumnSize = MAX(LEN(['+@ColumnName+'])) FROM #TMP5'
					SET @CMD4 = '@ColumnSize INT OUTPUT'
					EXEC sp_executesql @CMD3,@CMD4,@ColumnSize=@ColumnSize OUTPUT

					IF LEN(@ColumnName) > COALESCE(@ColumnSize,0)
						SET @ColumnSize = LEN(@ColumnName)

					SELECT		@FMT1		= @FMT1 + '{'+CAST(@ColID-1 AS VarChar(5))+',-'+CAST(@ColumnSize AS VarChar(5))+'} '
							,@FMT2		= @FMT2 + '{'+CAST(@ColID-1 AS VarChar(5))+','+ CASE @xtype WHEN 108 then '' else '-' END + CAST(@ColumnSize AS VarChar(5))+'} '
							,@HeaderLine	= @HeaderLine + REPLICATE('_',@ColumnSize) + ' '
							,@ColName1	= CASE @ColID WHEN 1 THEN @ColumnName ELSE COALESCE(@ColName1,'') END
							,@ColName2	= CASE @ColID WHEN 2 THEN @ColumnName ELSE COALESCE(@ColName2,'') END
							,@ColName3	= CASE @ColID WHEN 3 THEN @ColumnName ELSE COALESCE(@ColName3,'') END
							,@ColName4	= CASE @ColID WHEN 4 THEN @ColumnName ELSE COALESCE(@ColName4,'') END
							,@ColName5	= CASE @ColID WHEN 5 THEN @ColumnName ELSE COALESCE(@ColName5,'') END
							,@ColName6	= CASE @ColID WHEN 6 THEN @ColumnName ELSE COALESCE(@ColName6,'') END
							,@ColName7	= CASE @ColID WHEN 7 THEN @ColumnName ELSE COALESCE(@ColName7,'') END
							,@ColName8	= CASE @ColID WHEN 8 THEN @ColumnName ELSE COALESCE(@ColName8,'') END
							,@ColName9	= CASE @ColID WHEN 9 THEN @ColumnName ELSE COALESCE(@ColName9,'') END

				END
				FETCH NEXT FROM CreateHeadersCursor INTO @ColumnName,@xtype,@ColID
			END
			CLOSE CreateHeadersCursor
			DEALLOCATE CreateHeadersCursor

			SET		@TBL = [dbaadmin].[dbo].[dbaudf_FormatString](@FMT1,@ColName1,@ColName2,@ColName3,@ColName4,@ColName5,@ColName6,@ColName7,@ColName8,@ColName9,'') +CHAR(13)+CHAR(10)
					+ @HeaderLine +CHAR(13)+CHAR(10)
			SELECT		@TBL = @TBL + [dbaadmin].[dbo].[dbaudf_FormatString](@FMT2,FileGroupName,FileGroupID,HasFGExcluded,HasFGIncluded,BeingRestored,'','','','','') +CHAR(13)+CHAR(10)
			FROM		#TMP5

			RAISERROR('/* =============================================== DATABASE FILE GROUP PROPERTIES =============================================== --',-1,-1) WITH NOWAIT
			RAISERROR('',-1,-1) WITH NOWAIT
			PRINT @TBL
			RAISERROR('-- ============================================================================================================================== */',-1,-1) WITH NOWAIT
			RAISERROR('',-1,-1) WITH NOWAIT
		END

	END

END	-- GENERATE FILEGROUP LIST	

BEGIN	-- CLEANUP BACKUP FILES					

	UPDATE		T1
		SET	[BackupDateRange_Start]	=	COALESCE(
								CASE BackupType 
								WHEN 2 THEN
								(
								SELECT		MAX(BackupFinishDate) 
								FROM		@HL 
								WHERE		LastLSN = T1.FirstLSN
									AND	BackupType = 2
								)
								ELSE [BackupFinishDate] 
								END
								,(
								SELECT		MAX(BackupFinishDate) 
								FROM		@HL 
								WHERE		FirstLSN < T1.LastLSN
									AND	LastLSN > T1.LastLSN
									AND	BackupType IN(1,5)
								)
								)

			,[BackupDateRange_End]	=	[BackupFinishDate] --DATEADD(SECOND,-1,[BackupFinishDate])
			,[BackupChainStartDate]	=	CASE BackupType WHEN 1 THEN [BackupFinishDate] 
							ELSE
							(
							SELECT		BackupFinishDate 
							FROM		@HL 
							WHERE		FirstLSN = T1.DatabaseBackupLSN
								AND	BackupType = 1
							)
							END 

			,[BackupLinkStartDate]	=	CASE BackupType WHEN 2 
							THEN
							(
							SELECT		MAX(BackupFinishDate)
							FROM		@HL 
							WHERE		LastLSN < T1.LastLSN
								AND	BackupType IN(1,5)
							)
							ELSE [BackupFinishDate]
							END 
	FROM		@HL T1

	DELETE		T1
	FROM		@HL T1
	JOIN		(
			SELECT		BackupChainStartDate	
					,BackupLinkStartDate
					,MIN(BackupDateRange_End) BackupDateRange_End
			FROM		@HL
			WHERE		BackupDateRange_Start IS NULL
				AND	BackupType = 2
			GROUP BY	BackupChainStartDate	
					,BackupLinkStartDate
			)T2
		ON	T1.BackupChainStartDate = T2.BackupChainStartDate
		AND	T1.BackupLinkStartDate = T2.BackupLinkStartDate
		AND	T1.BackupDateRange_End >= T2.BackupDateRange_End
	WHERE		T1.BackupType = 2

	SET ANSI_WARNINGS OFF

	;WITH		RawRanges
			AS
			(
			SELECT		BackupDateRange_Start	
					,BackupDateRange_End
			FROM		@HL
			WHERE		BackupType != 2
			UNION ALL
			SELECT		MIN(BackupLinkStartDate)
					,MAX(BackupDateRange_End)
			FROM		@HL
			WHERE		BackupType = 2
			)
			,SummaryRanges
			AS
			(
			SELECT		BackupDateRange_Start
					,BackupDateRange_End
					,0 lvl
			FROM		RawRanges
			WHERE		BackupDateRange_Start = BackupDateRange_End
			UNION ALL
			SELECT		T2.BackupDateRange_Start
					,T1.BackupDateRange_End
					,T2.lvl + 1 lvl
			FROM		RawRanges T1
			JOIN		SummaryRanges T2
				ON	T1.BackupDateRange_Start = T2.BackupDateRange_End
				AND	T1.BackupDateRange_Start != T1.BackupDateRange_End
			)
			,RankedRanges
			AS
			(
			SELECT		*
					,DENSE_RANK() OVER(PARTITION BY [BackupDateRange_Start] ORDER BY [lvl] desc) AS rank
			FROM		SummaryRanges
			)
	INSERT		@VDR
	SELECT		BackupDateRange_Start
			,BackupDateRange_End
	FROM		RankedRanges
	WHERE		[rank] = 1
	ORDER BY	BackupDateRange_Start

	SET ANSI_WARNINGS ON

	IF @RestoreToDateTime IS NOT NULL AND NOT EXISTS (SELECT * FROM @VDR WHERE BackupDateRange_Start < @RestoreToDateTime AND BackupDateRange_End > @RestoreToDateTime)
	BEGIN
		IF @Verbose >= 0
		BEGIN
			RAISERROR('  -- *** NO VALID BACKUPS TO RESTORE TO THAT POINT IN TIME ***',-1,-1) WITH NOWAIT
			RAISERROR('  -- *** SELECT A DATETIME VALUE FROM ONE OF THE FOLLOWING RANGES ***',-1,-1) WITH NOWAIT

			SELECT		*
			FROM		@VDR

		END

		GOTO SkipRestore
	END

	BEGIN	-- REMOVE LOGS FROM BROKEN LINKS			
		DELETE		@SF
		WHERE		FullPathName IN	(
						SELECT		[BackupFileName]
						FROM		@HL
						WHERE		[BackupType] = 2	
							AND	[BackupLinkStartDate] IS NULL
						)

		DELETE		@HL
		WHERE		[BackupType] = 2	
			AND	[BackupLinkStartDate] IS NULL
	END	-- REMOVE LOGS FROM BROKEN LINKS

	BEGIN	-- REMOVE LOGS AND DIFFS FROM OTHER LINKS		
		DELETE		@SF
		WHERE		FullPathName IN	(
						SELECT		[BackupFileName]
						FROM		@HL
						WHERE		[BackupType] NOT IN (1,4)	
							AND	COALESCE([BackupLinkStartDate],'1980-01-01') != (
												SELECT		MAX([BackupLinkStartDate])[BackupLinkStartDate]
												FROM		@HL T1
												WHERE		[BackupDateRange_Start] <= COALESCE(@RestoreToDateTime, (SELECT MAX([BackupDateRange_End]) FROM @HL))
													AND	[BackupDateRange_End] >= COALESCE(@RestoreToDateTime, (SELECT MAX([BackupDateRange_End]) FROM @HL))
												)
						)

		DELETE		@HL
		WHERE		[BackupType] NOT IN (1,4)	
			AND	COALESCE([BackupLinkStartDate],'1980-01-01') !=	(
								SELECT		MAX([BackupLinkStartDate])[BackupLinkStartDate]
								FROM		@HL T1
								WHERE		[BackupDateRange_Start] <= COALESCE(@RestoreToDateTime, (SELECT MAX([BackupDateRange_End]) FROM @HL))
									AND	[BackupDateRange_End] >= COALESCE(@RestoreToDateTime, (SELECT MAX([BackupDateRange_End]) FROM @HL))
								)
	END	-- REMOVE LOGS AND DIFFS FROM OTHER LINKS

	BEGIN	-- REMOVE FG BACKUPS FOR FG'S NOT BEING RESTORED	

		DELETE		@SF
		WHERE		FullPathName NOT IN	(
							SELECT		DISTINCT
									T1.BackupFileName
							FROM		@FL T1
							JOIN		[dbaadmin].[dbo].[dbaudf_StringToTable](@filegroups,',') T2
									ON	T1.FileGroupName = T2.SplitValue
									AND	T1.IsPresent = 1
							)

		DELETE		@HL
		WHERE		BackupFileName NOT IN	(
							SELECT		DISTINCT
									T1.BackupFileName
							FROM		@FL T1
							JOIN		[dbaadmin].[dbo].[dbaudf_StringToTable](@filegroups,',') T2
									ON	T1.FileGroupName = T2.SplitValue
									AND	T1.IsPresent = 1
							)

	END	-- REMOVE FG BACKUPS FOR FG'S NOT BEING RESTORED

	;WITH		RestoreChain
			AS
			(
			SELECT		T1.*,1 as[ReverseOrder]
			FROM		@HL T1
			WHERE		[BackupDateRange_Start] <= COALESCE(@RestoreToDateTime, (SELECT MAX([BackupDateRange_End]) FROM @HL))
				AND	[BackupDateRange_End] >= COALESCE(@RestoreToDateTime, (SELECT MAX([BackupDateRange_End]) FROM @HL))


			UNION ALL
			SELECT		T1.*,[ReverseOrder]+1 [ReverseOrder]
			FROM		@HL T1
			JOIN		RestoreChain T2
				ON	(	-- ADD LOGS
						T1.BackupType = 2
					AND	T2.BackupType = 2
					AND	T2.FirstLSN = T1.LastLSN
					)
				OR	(	-- ADD DIFF
						T1.BackupType = 5
					AND	T2.BackupType = 2
					AND	T2.LastLSN > T1.LastLSN
					AND	T2.FirstLSN < T1.LastLSN
					)
				OR	(	-- ADD FULL
						T1.BackupType = 1
					AND	T2.BackupType IN (2,5)
					AND	T1.FirstLSN = T2.DatabaseBackupLSN
					)
				OR	(	-- ADD FULL
						T1.BackupType = 4
					AND	T2.BackupType IN (2,5)
					AND	T1.DatabaseBackupLSN = T2.DatabaseBackupLSN
					)
			)
	DELETE		
	FROM		@SF
	WHERE		(
				BackupSetSize = 1
			AND	FullPathName NOT IN	(
							SELECT		BackupFileName
							FROM		RestoreChain T1
							WHERE		[ReverseOrder] =	(
												SELECT	MAX([ReverseOrder]) 
												FROM	RestoreChain 
												WHERE	BackupFileName = T1.BackupFileName
												)
							)
			)
		OR	(
				BackupSetSize > 1
			AND	Name NOT IN	(
							SELECT		BackupFileName
							FROM		RestoreChain T1
							WHERE		[ReverseOrder] =	(
												SELECT	MAX([ReverseOrder]) 
												FROM	RestoreChain 
												WHERE	BackupFileName = T1.BackupFileName
												)
							)
			)

	IF @Verbose >= 1
	BEGIN
		RAISERROR('    -- Done Checking Backup Files',-1,-1) WITH NOWAIT
		RAISERROR('',-1,-1) WITH NOWAIT
	END
					
END	-- CLEANUP BACKUP FILES

BEGIN	-- REPORT BACKUP FILE AND HEADER INFO			

	SELECT		T1.Name
			,T2.ServerName				[FromServer]
			,T1.BackupType				[Type]
			,T1.BackupEngine			[Engine]
			,T1.BackupSetSize			[SetSize]
			,T1.Files
			,CAST(T1.Size_GB AS NUMERIC(38,2))	[Size_GB]
			,CAST(CAST(T2.BackupSize AS NUMERIC(38,10))/POWER(1024.0,2) AS NUMERIC(38,2)) [Size]
	INTO		#TMP2
	FROM		@SF T1
	LEFT JOIN	@HL T2
		ON	T1.Name = T2.BackupFileName
		OR	T1.FullPathName = T2.BackupFileName

	IF @Verbose >= 1
	BEGIN
		DECLARE CreateHeadersCursor CURSOR
		FOR
		SELECT		name
				,xtype
				,colid
		FROM		TempDB..syscolumns
		WHERE		id = OBJECT_ID('tempdb..#TMP2')
		ORDER BY	colid

		SELECT		@FMT1		= ''
				,@FMT2		= ''
				,@HeaderLine	= ''

		OPEN CreateHeadersCursor
		FETCH NEXT FROM CreateHeadersCursor INTO @ColumnName,@xtype,@ColID
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN
				SET @CMD3 = 'SET ANSI_WARNINGS OFF;SELECT @ColumnSize = MAX(LEN(['+@ColumnName+'])) FROM #TMP2'
				SET @CMD4 = '@ColumnSize INT OUTPUT'
				EXEC sp_executesql @CMD3,@CMD4,@ColumnSize=@ColumnSize OUTPUT

				IF LEN(@ColumnName) > COALESCE(@ColumnSize,0)
					SET @ColumnSize = LEN(@ColumnName)

				SELECT		@FMT1		= @FMT1 + '{'+CAST(@ColID-1 AS VarChar(5))+',-'+CAST(@ColumnSize AS VarChar(5))+'} '
						,@FMT2		= @FMT2 + '{'+CAST(@ColID-1 AS VarChar(5))+','+ CASE @xtype WHEN 108 then '' else '-' END + CAST(@ColumnSize AS VarChar(5))+'} '
						,@HeaderLine	= @HeaderLine + REPLICATE('_',@ColumnSize) + ' '
						,@ColName1	= CASE @ColID WHEN 1 THEN @ColumnName ELSE COALESCE(@ColName1,'') END
						,@ColName2	= CASE @ColID WHEN 2 THEN @ColumnName ELSE COALESCE(@ColName2,'') END
						,@ColName3	= CASE @ColID WHEN 3 THEN @ColumnName ELSE COALESCE(@ColName3,'') END
						,@ColName4	= CASE @ColID WHEN 4 THEN @ColumnName ELSE COALESCE(@ColName4,'') END
						,@ColName5	= CASE @ColID WHEN 5 THEN @ColumnName ELSE COALESCE(@ColName5,'') END
						,@ColName6	= CASE @ColID WHEN 6 THEN @ColumnName ELSE COALESCE(@ColName6,'') END
						,@ColName7	= CASE @ColID WHEN 7 THEN @ColumnName ELSE COALESCE(@ColName7,'') END
						,@ColName8	= CASE @ColID WHEN 8 THEN @ColumnName ELSE COALESCE(@ColName8,'') END
						,@ColName9	= CASE @ColID WHEN 9 THEN @ColumnName ELSE COALESCE(@ColName9,'') END

			END
			FETCH NEXT FROM CreateHeadersCursor INTO @ColumnName,@xtype,@ColID
		END
		CLOSE CreateHeadersCursor
		DEALLOCATE CreateHeadersCursor

		SET		@TBL = [dbaadmin].[dbo].[dbaudf_FormatString](@FMT1,@ColName1,@ColName2,@ColName3,@ColName4,@ColName5,@ColName6,@ColName7,@ColName8,@ColName9,'') +CHAR(13)+CHAR(10)
				+ @HeaderLine +CHAR(13)+CHAR(10)
		SELECT		@TBL = @TBL + [dbaadmin].[dbo].[dbaudf_FormatString](@FMT2,Name,FromServer,Type,Engine,SetSize,Files,Size_GB,Size,'','') +CHAR(13)+CHAR(10)
		FROM		#TMP2


		RAISERROR('/* =================================================== BACKUP FILE PROPERTIES =================================================== --',-1,-1) WITH NOWAIT
		RAISERROR('',-1,-1) WITH NOWAIT
		PRINT @TBL
		RAISERROR('',-1,-1) WITH NOWAIT
	END


	SELECT		T1.Name
			,T2.FirstLSN
			,T2.LastLSN
			,T2.DatabaseBackupLSN
	INTO		#TMP3
	FROM		@SF T1
	LEFT JOIN	@HL T2
		ON	T1.Name = T2.BackupFileName
		OR	T1.FullPathName = T2.BackupFileName

	IF @Verbose >= 1
	BEGIN
		DECLARE CreateHeadersCursor CURSOR
		FOR
		SELECT		name
				,xtype
				,colid
		FROM		TempDB..syscolumns
		WHERE		id = OBJECT_ID('tempdb..#TMP3')
		ORDER BY	colid

		SELECT		@FMT1		= ''
				,@FMT2		= ''
				,@HeaderLine	= ''

		OPEN CreateHeadersCursor
		FETCH NEXT FROM CreateHeadersCursor INTO @ColumnName,@xtype,@ColID
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN
				SET @CMD3 = 'SET ANSI_WARNINGS OFF;SELECT @ColumnSize = MAX(LEN(['+@ColumnName+'])) FROM #TMP3'
				SET @CMD4 = '@ColumnSize INT OUTPUT'
				EXEC sp_executesql @CMD3,@CMD4,@ColumnSize=@ColumnSize OUTPUT
			
				IF LEN(@ColumnName) > COALESCE(@ColumnSize,0)
					SET @ColumnSize = LEN(@ColumnName)

				SELECT		@FMT1		= @FMT1 + '{'+CAST(@ColID-1 AS VarChar(5))+',-'+CAST(@ColumnSize AS VarChar(5))+'} '
						,@FMT2		= @FMT2 + '{'+CAST(@ColID-1 AS VarChar(5))+','+ CASE @xtype WHEN 108 then '' else '-' END + CAST(@ColumnSize AS VarChar(5))+'} '
						,@HeaderLine	= @HeaderLine + REPLICATE('_',@ColumnSize) + ' '
						,@ColName1	= CASE @ColID WHEN 1 THEN @ColumnName ELSE @ColName1 END
						,@ColName2	= CASE @ColID WHEN 2 THEN @ColumnName ELSE @ColName2 END
						,@ColName3	= CASE @ColID WHEN 3 THEN @ColumnName ELSE @ColName3 END
						,@ColName4	= CASE @ColID WHEN 4 THEN @ColumnName ELSE @ColName4 END
						,@ColName5	= CASE @ColID WHEN 5 THEN @ColumnName ELSE @ColName5 END
						,@ColName6	= CASE @ColID WHEN 6 THEN @ColumnName ELSE @ColName6 END
						,@ColName7	= CASE @ColID WHEN 7 THEN @ColumnName ELSE @ColName7 END
						,@ColName8	= CASE @ColID WHEN 8 THEN @ColumnName ELSE @ColName8 END
						,@ColName9	= CASE @ColID WHEN 9 THEN @ColumnName ELSE @ColName9 END
			END
			FETCH NEXT FROM CreateHeadersCursor INTO @ColumnName,@xtype,@ColID
		END
		CLOSE CreateHeadersCursor
		DEALLOCATE CreateHeadersCursor

		SET		@TBL = [dbaadmin].[dbo].[dbaudf_FormatString](@FMT1,@ColName1,@ColName2,@ColName3,@ColName4,@ColName5,@ColName6,@ColName7,@ColName8,@ColName9,'') +CHAR(13)+CHAR(10)
				+ @HeaderLine +CHAR(13)+CHAR(10)
		SELECT		@TBL = @TBL + [dbaadmin].[dbo].[dbaudf_FormatString](@FMT2,Name,FirstLSN,LastLSN,DatabaseBackupLSN,'','','','','','') +CHAR(13)+CHAR(10)
		FROM		#TMP3


		RAISERROR('/* ==================================================== BACKUP FILE LSN RANGES ==================================================== --',-1,-1) WITH NOWAIT
		RAISERROR('',-1,-1) WITH NOWAIT
		PRINT @TBL
		RAISERROR('',-1,-1) WITH NOWAIT
	END

	SELECT		T1.Name
			,CONVERT(VarChar(50),T1.BackupTimeStamp,1)		BackupTimeStamp
			,CONVERT(VarChar(50),T2.BackupStartDate,1)		BackupStartDate
			,CONVERT(VarChar(50),T2.BackupFinishDate,1)		BackupFinishDate
			,CONVERT(VarChar(50),T2.BackupDateRange_Start,1)	BackupDateRange_Start
			,CONVERT(VarChar(50),T2.BackupDateRange_End,1)		BackupDateRange_End
			,CONVERT(VarChar(50),T2.BackupChainStartDate,1)	BackupChainStartDate
			,CONVERT(VarChar(50),T2.BackupLinkStartDate,1)		BackupLinkStartDate
			
	INTO		#TMP4
	FROM		@SF T1
	LEFT JOIN	@HL T2
		ON	T1.Name = T2.BackupFileName
		OR	T1.FullPathName = T2.BackupFileName

	IF @Verbose >= 1
	BEGIN
		DECLARE CreateHeadersCursor CURSOR
		FOR
		SELECT		name
				,xtype
				,colid
		FROM		TempDB..syscolumns
		WHERE		id = OBJECT_ID('tempdb..#TMP4')
		ORDER BY	colid

		SELECT		@FMT1		= ''
				,@FMT2		= ''
				,@HeaderLine	= ''

		OPEN CreateHeadersCursor
		FETCH NEXT FROM CreateHeadersCursor INTO @ColumnName,@xtype,@ColID
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN
				SET @CMD3 = 'SET ANSI_WARNINGS OFF;SELECT @ColumnSize = MAX(LEN(['+@ColumnName+'])) FROM #TMP4'
				SET @CMD4 = '@ColumnSize INT OUTPUT'
				EXEC sp_executesql @CMD3,@CMD4,@ColumnSize=@ColumnSize OUTPUT
			
				IF LEN(@ColumnName) > COALESCE(@ColumnSize,0)
					SET @ColumnSize = LEN(@ColumnName)

				SELECT		@FMT1		= @FMT1 + '{'+CAST(@ColID-1 AS VarChar(5))+',-'+CAST(@ColumnSize AS VarChar(5))+'} '
						,@FMT2		= @FMT2 + '{'+CAST(@ColID-1 AS VarChar(5))+','+ CASE @xtype WHEN 108 then '' else '-' END + CAST(@ColumnSize AS VarChar(5))+'} '
						,@HeaderLine	= @HeaderLine + REPLICATE('_',@ColumnSize) + ' '
						,@ColName1	= CASE @ColID WHEN 1 THEN @ColumnName ELSE @ColName1 END
						,@ColName2	= CASE @ColID WHEN 2 THEN @ColumnName ELSE @ColName2 END
						,@ColName3	= CASE @ColID WHEN 3 THEN @ColumnName ELSE @ColName3 END
						,@ColName4	= CASE @ColID WHEN 4 THEN @ColumnName ELSE @ColName4 END
						,@ColName5	= CASE @ColID WHEN 5 THEN @ColumnName ELSE @ColName5 END
						,@ColName6	= CASE @ColID WHEN 6 THEN @ColumnName ELSE @ColName6 END
						,@ColName7	= CASE @ColID WHEN 7 THEN @ColumnName ELSE @ColName7 END
						,@ColName8	= CASE @ColID WHEN 8 THEN @ColumnName ELSE @ColName8 END
						,@ColName9	= CASE @ColID WHEN 9 THEN @ColumnName ELSE @ColName9 END
			END
			FETCH NEXT FROM CreateHeadersCursor INTO @ColumnName,@xtype,@ColID
		END
		CLOSE CreateHeadersCursor
		DEALLOCATE CreateHeadersCursor

		SET		@TBL = [dbaadmin].[dbo].[dbaudf_FormatString](@FMT1,@ColName1,@ColName2,@ColName3,@ColName4,@ColName5,@ColName6,@ColName7,@ColName8,@ColName9,'') +CHAR(13)+CHAR(10)
				+ @HeaderLine +CHAR(13)+CHAR(10)
		SELECT		@TBL = @TBL + [dbaadmin].[dbo].[dbaudf_FormatString](@FMT2,Name,BackupTimeStamp,BackupStartDate,BackupFinishDate,BackupDateRange_Start,BackupDateRange_End,BackupChainStartDate,BackupLinkStartDate,'','') +CHAR(13)+CHAR(10)
		FROM		#TMP4


		RAISERROR('/* =================================================== BACKUP FILE  DATE RANGES =================================================== --',-1,-1) WITH NOWAIT
		RAISERROR('',-1,-1) WITH NOWAIT
		PRINT @TBL
		RAISERROR('',-1,-1) WITH NOWAIT
		RAISERROR('-- ================================================================================================================================ */',-1,-1) WITH NOWAIT
		RAISERROR('',-1,-1) WITH NOWAIT
	END



	SELECT		LogicalName	
			--,PhysicalName
			,LEFT(NEW_PhysicalName,1) [DriveLetter]
			,NEW_PhysicalName
			,MAX(CASE [dbaadmin].[dbo].[dbaudf_GetFileProperty](NEW_PhysicalName,'FILE','Exists') WHEN 'True' THEN 1 ELSE 0 END) [FileExists]
			,MAX(CASE [dbaadmin].[dbo].[dbaudf_GetFileProperty](NEW_PhysicalName,'FILE','Exists') WHEN 'True' THEN CAST(CAST([dbaadmin].[dbo].[dbaudf_GetFileProperty](NEW_PhysicalName,'FILE','Length') AS NUMERIC(38,10))/POWER(1024.0,3) AS NUMERIC(38,2)) ELSE 0 END) [ExistingSizeGB]
			,MAX(CAST(CAST([dbaadmin].[dbo].[dbaudf_GetFileProperty](NEW_PhysicalName,'DRIVE','AvailableFreeSpace') AS NUMERIC(38,10))/POWER(1024.0,3) AS NUMERIC(38,2))) [DriveFreeGB]
			,MAX(CAST(CAST(Size AS NUMERIC(38,10))/POWER(1024.0,3) AS NUMERIC(38,2))) [SizeGB]
			,MAX(CAST(CAST(MaxSize AS NUMERIC(38,10))/POWER(1024.0,3) AS NUMERIC(38,2))) [MaxSizeGB]
	INTO		#DBFileSpaceCheck
	FROM		@FL
	WHERE		IsPresent = 1
	GROUP BY	LogicalName	
			,PhysicalName
			,LEFT(NEW_PhysicalName,1)
			,NEW_PhysicalName


	IF @Verbose >= 1
	BEGIN	
		DECLARE CreateHeadersCursor CURSOR
		FOR
		SELECT		name
				,xtype
				,colid
		FROM		TempDB..syscolumns
		WHERE		id = OBJECT_ID('tempdb..#DBFileSpaceCheck')
		ORDER BY	colid

		SELECT		@FMT1		= ''
				,@FMT2		= ''
				,@HeaderLine	= ''

		OPEN CreateHeadersCursor
		FETCH NEXT FROM CreateHeadersCursor INTO @ColumnName,@xtype,@ColID
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN
				SET @CMD3 = 'SET ANSI_WARNINGS OFF;SELECT @ColumnSize = MAX(LEN(['+@ColumnName+'])) FROM #DBFileSpaceCheck'
				SET @CMD4 = '@ColumnSize INT OUTPUT'
				EXEC sp_executesql @CMD3,@CMD4,@ColumnSize=@ColumnSize OUTPUT
			
				IF LEN(@ColumnName) > COALESCE(@ColumnSize,0)
					SET @ColumnSize = LEN(@ColumnName)

				SELECT		@FMT1		= @FMT1 + '{'+CAST(@ColID-1 AS VarChar(5))+',-'+CAST(@ColumnSize AS VarChar(5))+'} '
						,@FMT2		= @FMT2 + '{'+CAST(@ColID-1 AS VarChar(5))+','+ CASE @xtype WHEN 108 then '' else '-' END + CAST(@ColumnSize AS VarChar(5))+'} '
						,@HeaderLine	= @HeaderLine + REPLICATE('_',@ColumnSize) + ' '
						,@ColName1	= CASE @ColID WHEN 1 THEN @ColumnName ELSE @ColName1 END
						,@ColName2	= CASE @ColID WHEN 2 THEN @ColumnName ELSE @ColName2 END
						,@ColName3	= CASE @ColID WHEN 3 THEN @ColumnName ELSE @ColName3 END
						,@ColName4	= CASE @ColID WHEN 4 THEN @ColumnName ELSE @ColName4 END
						,@ColName5	= CASE @ColID WHEN 5 THEN @ColumnName ELSE @ColName5 END
						,@ColName6	= CASE @ColID WHEN 6 THEN @ColumnName ELSE @ColName6 END
						,@ColName7	= CASE @ColID WHEN 7 THEN @ColumnName ELSE @ColName7 END
						,@ColName8	= CASE @ColID WHEN 8 THEN @ColumnName ELSE @ColName8 END
						,@ColName9	= CASE @ColID WHEN 9 THEN @ColumnName ELSE @ColName9 END
			END
			FETCH NEXT FROM CreateHeadersCursor INTO @ColumnName,@xtype,@ColID
		END
		CLOSE CreateHeadersCursor
		DEALLOCATE CreateHeadersCursor

		SET		@TBL = [dbaadmin].[dbo].[dbaudf_FormatString](@FMT1,@ColName1,@ColName2,@ColName3,@ColName4,@ColName5,@ColName6,@ColName7,@ColName8,@ColName9,'') +CHAR(13)+CHAR(10)
				+ @HeaderLine +CHAR(13)+CHAR(10)
		SELECT		@TBL = @TBL + [dbaadmin].[dbo].[dbaudf_FormatString](@FMT2,LogicalName,DriveLetter,New_PhysicalName,FileExists,ExistingSizeGB,DriveFreeGB,SizeGB,MaxSizeGB,'','') +CHAR(13)+CHAR(10)
		FROM		#DBFileSpaceCheck


		RAISERROR('/* ================================================= NEW FILE AND SIZE PROPERTIES ================================================= --',-1,-1) WITH NOWAIT
		RAISERROR('',-1,-1) WITH NOWAIT
		PRINT @TBL
		RAISERROR('',-1,-1) WITH NOWAIT
		RAISERROR('-- ================================================================================================================================ */',-1,-1) WITH NOWAIT
		RAISERROR('',-1,-1) WITH NOWAIT
	END

	SELECT		DriveLetter	
			,CAST(CAST(TotalSize AS NUMERIC(38,10))/POWER(1024.0,3) AS NUMERIC(38,2)) SizeGB	
			,CAST(CAST(AvailableSpace AS NUMERIC(38,10))/POWER(1024.0,3) AS NUMERIC(38,2)) AvailableGB	
			,CAST(CAST(FreeSpace AS NUMERIC(38,10))/POWER(1024.0,3) AS NUMERIC(38,2)) FreeGB	
			,DriveType	
			,FileSystem	
			,IsReady	
			,VolumeName	
			,RootFolder
	INTO		#TMP1
	FROM		[dbaadmin].[dbo].[dbaudf_ListDrives]()

	IF @Verbose >= 1
	BEGIN
		DECLARE CreateHeadersCursor CURSOR
		FOR
		SELECT		name
				,xtype
				,colid
		FROM		TempDB..syscolumns
		WHERE		id = OBJECT_ID('tempdb..#TMP1')
		ORDER BY	colid

		SELECT		@FMT1		= ''
				,@FMT2		= ''
				,@HeaderLine	= ''

		OPEN CreateHeadersCursor
		FETCH NEXT FROM CreateHeadersCursor INTO @ColumnName,@xtype,@ColID
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN
				SET @CMD3 = 'SET ANSI_WARNINGS OFF;SELECT @ColumnSize = MAX(LEN(['+@ColumnName+'])) FROM #TMP1'
				SET @CMD4 = '@ColumnSize INT OUTPUT'
				EXEC sp_executesql @CMD3,@CMD4,@ColumnSize=@ColumnSize OUTPUT
			
				IF LEN(@ColumnName) > COALESCE(@ColumnSize,0)
					SET @ColumnSize = LEN(@ColumnName)

				SELECT		@FMT1		= @FMT1 + '{'+CAST(@ColID-1 AS VarChar(5))+',-'+CAST(@ColumnSize AS VarChar(5))+'} '
						,@FMT2		= @FMT2 + '{'+CAST(@ColID-1 AS VarChar(5))+','+ CASE @xtype WHEN 108 then '' else '-' END + CAST(@ColumnSize AS VarChar(5))+'} '
						,@HeaderLine	= @HeaderLine + REPLICATE('_',@ColumnSize) + ' '
						,@ColName1	= CASE @ColID WHEN 1 THEN @ColumnName ELSE @ColName1 END
						,@ColName2	= CASE @ColID WHEN 2 THEN @ColumnName ELSE @ColName2 END
						,@ColName3	= CASE @ColID WHEN 3 THEN @ColumnName ELSE @ColName3 END
						,@ColName4	= CASE @ColID WHEN 4 THEN @ColumnName ELSE @ColName4 END
						,@ColName5	= CASE @ColID WHEN 5 THEN @ColumnName ELSE @ColName5 END
						,@ColName6	= CASE @ColID WHEN 6 THEN @ColumnName ELSE @ColName6 END
						,@ColName7	= CASE @ColID WHEN 7 THEN @ColumnName ELSE @ColName7 END
						,@ColName8	= CASE @ColID WHEN 8 THEN @ColumnName ELSE @ColName8 END
						,@ColName9	= CASE @ColID WHEN 9 THEN @ColumnName ELSE @ColName9 END
			END
			FETCH NEXT FROM CreateHeadersCursor INTO @ColumnName,@xtype,@ColID
		END
		CLOSE CreateHeadersCursor
		DEALLOCATE CreateHeadersCursor

		SET		@TBL = [dbaadmin].[dbo].[dbaudf_FormatString](@FMT1,@ColName1,@ColName2,@ColName3,@ColName4,@ColName5,@ColName6,@ColName7,@ColName8,@ColName9,'') +CHAR(13)+CHAR(10)
				+ @HeaderLine +CHAR(13)+CHAR(10)
		SELECT		@TBL = @TBL + [dbaadmin].[dbo].[dbaudf_FormatString](@FMT2,DriveLetter,SizeGB,AvailableGB,FreeGB,DriveType,FileSystem,IsReady,VolumeName,'','') +CHAR(13)+CHAR(10)
		FROM		#TMP1


		RAISERROR('/* =================================================== CURRENT DRIVE PROPERTIES =================================================== --',-1,-1) WITH NOWAIT
		RAISERROR('',-1,-1) WITH NOWAIT
		PRINT @TBL
		RAISERROR('',-1,-1) WITH NOWAIT
		RAISERROR('-- ================================================================================================================================ */',-1,-1) WITH NOWAIT
		RAISERROR('',-1,-1) WITH NOWAIT
	END

END	-- REPORT BACKUP FILE AND HEADER INFO

BEGIN	-- CHECK FOR EXISTING FILES				

	DECLARE DBFileExistsCursor CURSOR
	FOR
	SELECT		[LogicalName]
			,[NEW_PhysicalName]
	FROM		#DBFileSpaceCheck
	WHERE		FileExists = 1

	IF @Verbose >= 1
		RAISERROR('  -- Checking for Existing Files',-1,-1) WITH NOWAIT

	OPEN DBFileExistsCursor
	FETCH NEXT FROM DBFileExistsCursor INTO @LogicalName,@NewPhysicalName
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2) AND @Verbose >= 0
		BEGIN
			RAISERROR('      -- WARNING: File "%s" at "%s" Already Exists.',-1,-1,@LogicalName,@NewPhysicalName) WITH NOWAIT
		END
		FETCH NEXT FROM DBFileExistsCursor INTO @LogicalName,@NewPhysicalName
	END
	CLOSE DBFileExistsCursor
	DEALLOCATE DBFileExistsCursor
	
	IF @Verbose >= 1
		RAISERROR('',-1,-1) WITH NOWAIT


END	-- CHECK FOR EXISTING FILES

IF @IgnoreSpaceLimits = 0
BEGIN	-- CHECK FOR SPACE					

	DECLARE DBFileSpaceCursor CURSOR
	FOR
	SELECT		DriveLetter
			,MAX(DriveFreeGB) [DriveFreeSpace]
			,SUM(ExistingSizeGB) [ExistingSize]
			,SUM(SizeGB) [Size]
	FROM		#DBFileSpaceCheck
	GROUP BY	DriveLetter
	HAVING		MAX(DriveFreeGB) < (SUM(SizeGB)-SUM(ExistingSizeGB))

	SET	@SkipFlag = 0 --RESET TO 0 BEFORE CURSOR

	IF @Verbose >= 1
		RAISERROR('  -- Checking for Drive Space',-1,-1) WITH NOWAIT

	OPEN DBFileSpaceCursor
	FETCH NEXT FROM DBFileSpaceCursor INTO @DriveLetter,@DriveFreeSpace,@ExistingSize,@Size
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2) AND @Verbose >= 0
		BEGIN
			RAISERROR('      -- ERROR: THERE IS NOT ENOUGH SPACE ON DRIVE %s:',-1,-1,@DriveLetter) WITH NOWAIT
			RAISERROR('      --------- YOU MUST FREE UP SPACE OR RELOCATE',-1,-1) WITH NOWAIT
			RAISERROR('      --------- FILES TO ANOTHER DRIVE BEFORE RESTORING',-1,-1) WITH NOWAIT
			RAISERROR('',-1,-1) WITH NOWAIT
			SET @SkipFlag = 1
		END
		FETCH NEXT FROM DBFileSpaceCursor INTO @DriveLetter,@DriveFreeSpace,@ExistingSize,@Size
	END
	CLOSE DBFileSpaceCursor
	DEALLOCATE DBFileSpaceCursor
	
	IF @Verbose >= 1
		RAISERROR('',-1,-1) WITH NOWAIT

	IF @SkipFlag = 1
		GOTO SkipRestore

END	-- CHECK FOR SPACE

BEGIN	-- BUILD RESTORE SCRIPT					

	IF @Verbose >= 1
	BEGIN
		RAISERROR('  -- Starting DB Restore''s',-1,-1) WITH NOWAIT
		RAISERROR('',-1,-1) WITH NOWAIT
		RAISERROR('',-1,-1) WITH NOWAIT
	END

	--SELECT * FROM @FL

	DECLARE RestoreDBCursor CURSOR
	FOR
	SELECT		DISTINCT
			CASE T1.BackupType WHEN 'tlog' THEN 3 WHEN 'dfntl' THEN 2 ELSE 1 END [RestoreOrder]
			,T1.BackupTimeStamp
			,T1.[BackupType]
			,T1.[BackupEngine]
			,T1.[BackupSetSize]
			,T1.[Name]
			,(
				SELECT		MIN(FileGroupId)
				FROM		@FL
				WHERE		BackupFileName = @FilePath+'\'+T1.[Name]
					AND	isPresent = 1
					AND	FileGroupId > 0

			) FGID
	FROM		@SF T1
	LEFT JOIN	(		
			SELECT		DISTINCT
					[dbaadmin].[dbo].[dbaudf_GetFileFromPath]([physical_device_name]) [Name]
					,[physical_device_name] AS [Path]
			FROM		[msdb].[dbo].[backupset] bs
			JOIN		[msdb].[dbo].[backupmediafamily] bmf
				ON	bmf.[media_set_id] = bs.[media_set_id]
			JOIN		msdb.dbo.restorehistory rh
				ON	rh.backup_set_id = bs.backup_set_id
				AND	rh.destination_database_name = bs.database_name
			WHERE		bs.database_name = @NewDBName
			) T2		
		ON	T2.[name] = T1.[Name]
		
	WHERE		-- NEW DATABASE DOES NOT EXIST
			(DB_ID(@NewDBName) IS NULL OR  @FullReset = 1)

			-- DATABASE IS NOT CURRENTLY RESTORING AND NOT A LOGSHIPED STANDBY AND RESET IS SET
		OR	(DATABASEPROPERTYEX(@NewDBName,'Status') != 'RESTORING' AND DATABASEPROPERTYEX(@NewDBName,'IsInStandBy') = 0 AND @FullReset = 1)

			-- DATABASE IS CURRENTLY RESTORING OR A LOGSHIPED STANDBY AND FILE NOT A FULL BACKUP AND NOT YET APPLIED	
		OR	((DATABASEPROPERTYEX(@NewDBName,'IsInStandBy') = 1 OR DATABASEPROPERTYEX(@NewDBName,'Status') = 'RESTORING') AND T2.[Name] IS NULL AND BackupType != 'db')

		
	ORDER BY	1,7,2,3

	DECLARE @FGID INT

	OPEN RestoreDBCursor
	FETCH NEXT FROM RestoreDBCursor INTO @RestoreOrder,@BackupTimeStamp,@BackupType,@BackupEngine,@SetSize,@FileName,@FGID
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			--SELECT @RestoreOrder,@BackupTimeStamp,@BackupType,@BackupEngine,@SetSize,@FileName,@FGID

			SET @FileGroup = NULL

			IF LEFT(@BackupType,3) = 'FG_'
			BEGIN
				SET	@FileGroup = STUFF(@BackupType,1,3,'')
				SET	@BackupType = 'db'
			END

			SET @FilesRestored = @FilesRestored + 1

			DELETE		#filelist

			IF OBJECT_ID('tempdb..#filelist_last') IS NULL
				SELECT	*
				INTO	#filelist_last
				FROM	#filelist

			INSERT INTO	#filelist
			SELECT		* 
			FROM		@FL
			WHERE		BackupFileName = @FilePath+'\'+@FileName

			SET		@FileNameSET = NULL
				
			SELECT		@FileNameSET = COALESCE(@FileNameSET + CHAR(13)+CHAR(10)+', DISK = '''+T1.FullPathName+'''','DISK = '''+T1.FullPathName+'''')
			FROM		dbaadmin.dbo.dbaudf_DirectoryList2(@FilePath,@FileName,0) T1
			ORDER BY	T1.Name		
				
			SET		@FileName = @FileNameSET

			--SELECT * FROM #filelist
				
			IF EXISTS (SELECT * FROM #filelist WHERE isPresent = 0) 
				AND EXISTS (SELECT * FROM #filelist WHERE isPresent = 1 AND FileGroupId = 1)
				SET @Partial_flag = 1
			ELSE	
				SET @Partial_flag = 0					
		
			IF	-- FULL OR DIFF BACKUP FILE
			@BackupType IN ('db','dfntl')
			BEGIN
				SET @CMD = 'RESTORE DATABASE ['+ @NewDBName + '] '
				
				IF @FileGroup IS NOT NULL
					SELECT	@CMD = @CMD + dbaadmin.dbo.dbaudf_ConcatenateUnique('FILEGROUP = '''+FileGroupName+'''')
					FROM	#filelist
					WHERE	isPresent = 1

				
				SET @CMD = @CMD + CHAR(13)+ CHAR(10)+'FROM    '+@FileName+ CHAR(13)+CHAR(10)
				
				SET @CMD	= @CMD 
						+ 'WITH    ' + CASE @partial_flag WHEN 1 THEN 'PARTIAL, ' ELSE '' END
						+ 'NORECOVERY, REPLACE' + CHAR(13)+CHAR(10)


				IF @BackupType = 'db'
				BEGIN
					SELECT		@CMD = @CMD
							+ '        ,MOVE ''' + LogicalName + ''' TO ''' + NEW_PhysicalName + '''' + CHAR(13) + CHAR(10)
					FROM		#filelist
					WHERE		isPresent = 1
						AND	FileGroupName IN (Select SplitValue FROM [dbaadmin].[dbo].[dbaudf_StringToTable](@filegroups,','))						
					ORDER BY	FileID
				END
				ELSE
				BEGIN
					SELECT		@CMD = @CMD
							+ '        ,MOVE ''' + LogicalName + ''' TO ''' + NEW_PhysicalName + '''' + CHAR(13) + CHAR(10)
					FROM		#filelist T1
					WHERE		isPresent = 1
						AND	FileGroupName IN (Select SplitValue FROM [dbaadmin].[dbo].[dbaudf_StringToTable](@filegroups,','))
						AND	NOT EXISTS(SELECT * FROM #filelist_last WHERE isPresent = 1 AND LogicalName = T1.LogicalName)
					ORDER BY	T1.FileID
				END
			END

		
			IF	-- TRANSACTION LOG BACKUP FILE
			@BackupType = 'tlog'
			BEGIN
				SET @CMD	= 'RESTORE LOG ['+@NewDBName+'] FROM '+@FileName
						+ ' WITH NORECOVERY'
						+ CASE	WHEN @RestoreToDateTime IS NOT NULL 
							THEN ', STOPAT = N'''+CAST(@RestoreToDateTime AS VarChar(50))+''''
							ELSE '' END

				SELECT		@CMD = @CMD
						+ '        ,MOVE ''' + LogicalName + ''' TO ''' + NEW_PhysicalName + '''' + CHAR(13) + CHAR(10)
				FROM		#filelist T1
				WHERE		isPresent = 1
					AND	FileGroupName IN (Select SplitValue FROM [dbaadmin].[dbo].[dbaudf_StringToTable](@filegroups,','))
					AND	NOT EXISTS(SELECT * FROM #filelist_last WHERE isPresent = 1 AND LogicalName = T1.LogicalName)
				ORDER BY	T1.FileID
			END
			
			IF	-- REDGATE SYNTAX
			@BackupEngine = 'RedGate'
			BEGIN
				SET @CMD = 'Exec master.dbo.sqlbackup ''-SQL "' + REPLACE(
											REPLACE(
											REPLACE(
											REPLACE(
											REPLACE(@CMD,CHAR(9),' ')
												,CHAR(13)+CHAR(10),' ')
												,'''','''''') 
												,'  ',' ')
												,'  ',' ')
												+'"'''
			END
			ELSE	-- MICROSOFT SYNTAX
			BEGIN
				SET @CMD = @CMD + '        ,STATS=1' + CHAR(13) + CHAR(10)
			END

			IF @Verbose >= 2
			BEGIN
				PRINT '   -- ' + REPLACE(@CMD,CHAR(13)+CHAR(10),CHAR(13)+CHAR(10)+'   -- ')
				RAISERROR('',-1,-1) WITH NOWAIT
			END

			SET	@syntax_out = COALESCE(@syntax_out,'')+CHAR(13)+CHAR(10)+@CMD

			INSERT INTO	#filelist_last
			SELECT		*
			FROM		#filelist
			
		END
		FETCH NEXT FROM RestoreDBCursor INTO @RestoreOrder,@BackupTimeStamp,@BackupType,@BackupEngine,@SetSize,@FileName,@FGID
	END

	CLOSE RestoreDBCursor
	DEALLOCATE RestoreDBCursor

	IF @LeaveNORECOVERY = 0 AND @FilesRestored > 0
	BEGIN
		SET @CMD = 'RESTORE DATABASE ['+@NewDBName+'] WITH RECOVERY'

		IF @Verbose >= 2
		BEGIN
			PRINT '   -- ' + REPLACE(@CMD,CHAR(13)+CHAR(10),CHAR(13)+CHAR(10)+'   -- ')
			RAISERROR('',-1,-1) WITH NOWAIT
		END

		SET	@syntax_out = COALESCE(@syntax_out,'')+CHAR(13)+CHAR(10)+@CMD
	END

	IF @Verbose >= 1
	BEGIN
		RAISERROR('  -- Done with DB Restore''s',-1,-1) WITH NOWAIT
		RAISERROR('',-1,-1) WITH NOWAIT
		RAISERROR('',-1,-1) WITH NOWAIT
	END

END	-- BUILD RESTORE SCRIPT

SkipRestore:

BEGIN	-- OUTPUT OVERIDE EXAMPLE				

	IF @Verbose >= 1
	BEGIN
		SELECT		@XML =	(
					SELECT		DISTINCT
							LogicalName	
							,PhysicalName
							,New_PhysicalName
					FROM		@FL
					FOR XML RAW ('Override'),TYPE, ROOT('RestoreFileLocations')
					)

		SELECT @CMD = [dbaadmin].[dbo].[dbaudf_FormatXML2String](@XML)
		RAISERROR('/* ============================================ EXISTING RESTORE FILE OVERRIDE PROPERTY =========================================== --',-1,-1) WITH NOWAIT
		RAISERROR('   ========= THIS XML CHUNK CAN BE MODIFIED AND USED AS THE @OverrideXML PROPERTY TO FORE RESTORES TO ANY NAME AND PATH =========== --',-1,-1) WITH NOWAIT
		RAISERROR('',-1,-1) WITH NOWAIT
		PRINT @CMD
		RAISERROR('',-1,-1) WITH NOWAIT
		RAISERROR('-- ================================================================================================================================ */',-1,-1) WITH NOWAIT
		RAISERROR('',-1,-1) WITH NOWAIT
	END

/*
'<RestoreFileLocations>
  <Override LogicalName="StackFactors" PhysicalName="I:\Data\StackFactors.mdf" New_PhysicalName="D:\MSSQL\Data\StackFactors.mdf" />
  <Override LogicalName="StackFactors_log" PhysicalName="J:\Log\StackFactors_log.ldf" New_PhysicalName="D:\MSSQL\Log\StackFactors_log.ldf" />
</RestoreFileLocations>'
*/

END	-- OUTPUT OVERIDE EXAMPLE

PRINT @syntax_out


--SELECT * FROM [dbo].[dbaudf_SplitString](@syntax_out,CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10))


GO

	--SELECT		*
	--FROM		@FL

	--SELECT		*
	--FROM		@SF

	--SELECT		*
	--FROM		@HL
	--ORDER BY	BackupStartDate



/*

SELECT		DISTINCT
		[dbaadmin].[dbo].[dbaudf_GetFileFromPath]([physical_device_name]) [Name]
		,[physical_device_name] AS [Path]
		,*
FROM		[msdb].[dbo].[backupset] bs
JOIN		[msdb].[dbo].[backupmediafamily] bmf
	ON	bmf.[media_set_id] = bs.[media_set_id]
LEFT JOIN	msdb.dbo.restorehistory rh
	ON	rh.backup_set_id = bs.backup_set_id
	AND	rh.destination_database_name = bs.database_name
WHERE		bs.database_name = 'StackFactors'

RESTORE FILELISTONLY 
FROM DISK = N'\\SEAPSDTSQLB\SEAPSDTSQLB$B_backup\StackFactors_db_20130913170202.cBAK' 
WITH NOUNLOAD;

RESTORE HEADERONLY 
FROM DISK = N'\\SEAPSDTSQLB\SEAPSDTSQLB$B_backup\StackFactors_db_20130913170202.cBAK' 
WITH NOUNLOAD;

Exec master.dbo.sqlbackup '-SQL "RESTORE SQBHEADERONLY FROM DISK = N''\\SEAPSQLDPLY01\SEAPSQLDPLY01_backup\test_destination\Done\Getty_Master_db_20130822163737_set_01_of_32.SQB''"'

*/

