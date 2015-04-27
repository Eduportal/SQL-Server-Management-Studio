USE [dbaadmin]
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbaudf_SplitByLines') IS NOT NULL
DROP FUNCTION [dbo].[dbaudf_SplitByLines]
GO

CREATE function [dbo].[dbaudf_SplitByLines] ( @String VARCHAR(max))
returns @SplittedValues TABLE
(
    OccurenceId INT IDENTITY(1,1),
    SplitValue VARCHAR(max)
)
as
BEGIN

	DECLARE	@SplitLength	INT
		,@SplitValue	VarChar(max)
		,@CRLF		CHAR(2)

	SELECT	@CRLF		= CHAR(13)+CHAR(10)
		,@String	= @String + @CRLF

	WHILE LEN(@String) > 0

	BEGIN
		SELECT		@SplitLength	= COALESCE(NULLIF(CHARINDEX(@CRLF,@String),0)-1,LEN(@String))
				,@SplitValue	= LEFT(@String,@SplitLength)
				,@String	= STUFF(@String,1,@SplitLength+2,'')

		INSERT INTO	@SplittedValues([SplitValue])
		SELECT		@SplitValue
	END

	RETURN

END

GO


USE [dbaadmin]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[dbasp_format_BackupRestore] 
						(
						@DBName			SYSNAME		= NULL
						,@NewDBName		SYSNAME		= NULL
						,@Mode			CHAR(2)		= NULL
						
						,@ForceEngine		SYSNAME		= NULL
						,@ForceSetSize		INT		= NULL
						,@ForceCompression	BIT		= NULL
						,@ForceChecksum		BIT		= NULL

						,@FilePath		VarChar(MAX)	= NULL
						,@ForceFileName		VarChar(MAX)	= NULL
						,@FileGroups		VarChar(MAX)	= NULL
						,@FromServer		SYSNAME		= NULL
						,@WorkDir		VarChar(MAX)	= NULL

						,@SetName		VarChar(MAX)	= NULL
						,@SetDesc		VarChar(MAX)	= NULL
						
						,@CopyOnly		BIT		= 0
						,@RestoreToDateTime	DateTime	= NULL
						,@LeaveNORECOVERY	BIT		= 0
						,@NoLogRestores		BIT		= 0
						,@NoDifRestores		BIT		= 0
						,@FullReset		BIT		= 1
						,@IgnoreSpaceLimits	BIT		= 1
						,@OverrideXML		XML		= NULL

						,@Verbose		INT		= 1 
						,@syntax_out		VarChar(max)	OUTPUT
						)

/*********************************************************
 **  Stored Procedure dbasp_Format_BackupRestore                  
 **  Written by Steve Ledridge, Getty Images                
 **  August 08, 2013                                      
 **
 **  
 **  Description: Creates proper syntax for backup and restore processing.
 **
 **
 **  This proc accepts the following input parameters:
 **	PARAMETER		DESCRIPTION						USED IN	BACKUP	RESTORE
 **	-----------------------	-------------------------------------------------------		------	-------
 **	@DBName: (REQ)		Database name							  X	  X
 **	@NewDBName		Restore TO DBName							  X
 **
 **	@Mode: (REQ)		'BF' Backup FULL						  X
 **				'BD' Backup DIFFERENTIAL					  X
 **				'BL' Backup LOG							  X
 **				'RD' Restore DATABASE							  X
 **				'HO' Restore (Header Only)						  X
 **				'FO' Restore (Filelist Only)						  X			
 **				'LO' Restore (Label Only)						  X
 **				'VO' Restore (Verify Only)						  X
 **	
 **	@UseEngine:		'MSSQL' or 'REDGATE' Forces specific Engine to be Used		  X	  X
 **	@FilePath: 		UNC or Drive Path to Backup Files To				  X
 **				UNC or Drive Path to Restore Backup Files From				  X

 **	@FileName: 		Override output file name					  X	  X
 **	@FileGroups: 		Filegroup names to include in BKUP/RSTR	Proccess		  X	  X
 **	@Extension: 		Backup File Extension						  X
 **	@SetName: 		Backup Set Name							  X
 **	@SetDesc: 		Backup Set Description						  X
 **	@SetSize: 		Force Backup to create specific Number of Files			  X
 **     @Redgate:		0 = standard  1 = redgate					  X
 **     @Compress:		0 = no compression  1 = compression				  X
 **     @Checksum:		0 = no Checksum  1 = with Checksum				  X	  X
 **     @CopyOnly:		0 = no CopyOnly  1 = with CopyOnly				  X
 **	@syntax_out		OUTPUT PARAMETER CONTAINING FINAL SCRIPT			  X	  X		
 **	@FromServer		Server to get the Backup Files From (_Backup Share)			  X
 **	@WorkDir		Copy Files to this Directory Before Restoring				  X	
 **	@RestoreToDateTime	Restore to a specific point in time					  X	
 **	@LeaveNORECOVERY	Leave Database in Recovery Mode When Done				  X	
 **	@NoLogRestores		Do Not Create Restore Script For Log Backups				  X		
 **	@NoDifRestores		Do Not Create Restore Script For Diff Backups				  X		
 **	@Verbose		-1=NO NOUTPUT		0=ONLY ERRORS				  X	  X
 **				 1=INFO MESSAGES	2=INFO AND OUTPUT			  X	  X
 **	@FullReset		Wipe Out existing database and start from scratch			  X
 **	@IgnoreSpaceLimits	Generate Restore Script even if there is not enough room to run		  X
 **	@OverrideXML		Force Files to be restored to specific locations			  X
 **
 **	'<RestoreFileLocations>
 **	  <Override LogicalName="StackFactors" PhysicalName="I:\Data\StackFactors.mdf" New_PhysicalName="X:\MSSQL\Data\XXX_StackFactors_data.mdf" />
 **	  <Override LogicalName="StackFactors_log" PhysicalName="J:\Log\StackFactors_log.ldf" New_PhysicalName="X:\MSSQL\Log\XXX_StackFactors_log.ldf" />
 **	</RestoreFileLocations>'
 ***************************************************************/
AS
	SET NOCOUNT ON
	SET ANSI_NULLS ON
	SET ANSI_WARNINGS ON
--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	2013-08-08	SteveL			Created
--	======================================================================================


/***
-------------------------------------------------------
-- U N C O M M E N T   T O   T E S T   L O C A L L Y --
-------------------------------------------------------

DECLARE	 @DBName SYSNAME
	,@Mode CHAR(2)
	,@FilePath VarChar(max)
	,@FileName VarChar(max)
	,@FileGroups VarChar(MAX)
	,@Extension VarChar(50)
	,@SetName VarChar(max)
	,@SetDesc VarChar(max)
	,@SetSize INT
	,@Redgate BIT
	,@Compress BIT
	,@Checksum BIT
	,@CopyOnly BIT
	,@syntax_out VarChar(max)
	
SELECT	@DBName = 'DeliveryDb'
	,@Mode = 'BD'
	,@FilePath = NULL
	,@FileName = NULL
	,@FileGroups = NULL
	,@Extension = 'cBAK'
	,@SetName = NULL
	,@SetDesc = NULL
	,@SetSize = NULL
	,@Redgate = 0
	,@Checksum = 1
	,@CopyOnly = 0
	,@Compress = 1

-- ***/


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
				,@Compression		tinyint
				,@CRLF			CHAR(2)
				,@DataPath		VarChar(500)
				,@diffPrediction	int
				,@DriveFreeSpace	BIGINT
				,@DriveLetter		SYSNAME
				,@ExistingSize		BIGINT
				,@Extension		VarChar(50)
				,@FGID			INT
				,@FileGroup		SYSNAME
				,@FileName		VarChar(MAX)
				,@FileNameSet		VarChar(MAX)
				,@FilesRestored		INT
				,@FMT1			VarChar(max)
				,@FMT2			VarChar(max)
				,@FullPathName		VarChar(max)
				,@HeaderLine		VarChar(max)
				,@Init			BIT
				,@LogicalName		SYSNAME
				,@LogPath		VarChar(500)
				,@MachineName		SYSNAME
				,@NDFPath		VarChar(500)
				,@NewPhysicalName	VarChar(8000)
				,@NOW			VarChar(20)
				,@partial_flag		BIT
				,@RedGate		BIT
				,@RedGateInstalled	BIT
				,@RestoreOrder		INT
				,@ServerName		SYSNAME
				,@SetNumber		INT
				,@SetSize		INT
				,@Size			BIGINT
				,@SkipFlag		bit
				,@srvprop		Char(5)
				,@Stats			INT
				,@TBL			VarChar(max)
				,@VersionBuild		INT
				,@VersionMajor		INT
				,@VersionMinor		INT
				,@XML			XML
				,@xtype			INT

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

		IF OBJECT_ID('tempdb..#FGs') IS NOT NULL	
			DROP TABLE #FGs
						
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

		CREATE TABLE	#FGs
				(
				id			INT
				,name			SYSNAME
				,size			DECIMAL(15, 2)
				) 

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

		If @Mode not in ('BF', 'BD', 'BL', 'RD', 'HO', 'FO', 'LO', 'VO')
		BEGIN
			SELECT @CMD = 'DBA WARNING: Invalid @Mode input parm.  Must be in:'
					+@CRLF+'	''BF'' = Backup Full'
					+@CRLF+'	''BD'' = Backup Differential'
					+@CRLF+'	''BL'' = Backup Log'
					+@CRLF+'	''RD'' = Restore Database'
					+@CRLF+'	''HO'' = Restore Header Only'
					+@CRLF+'	''FO'' = Restore File List Only'
					+@CRLF+'	''LO'' = Restore Label Only'
					+@CRLF+'	''VO'' = Restore Verify Only'
				 
			PRINT ''
			RAISERROR(@CMD,-1,-1) WITH NOWAIT
			GOTO label99
		END

		IF @Mode in ('BF', 'BD', 'BL') AND DB_ID(@DBName) IS NULL
		   BEGIN
			PRINT ''
			RAISERROR('DBA WARNING: Invalid @DBName input parm: DBName must Exist to Create Backup Script.',-1,-1) WITH NOWAIT 
			GOTO label99
		   END

		IF @Mode NOT in ('BF', 'BD', 'BL') AND NULLIF(@DBName,'') IS NULL
		   BEGIN
			PRINT ''
			RAISERROR('DBA WARNING: Invalid @DBName input parm: DBName must Exist to Create Backup Script.',-1,-1) WITH NOWAIT 
			GOTO label99
		   END

		SELECT		@NOW			= REPLACE(REPLACE(REPLACE(CONVERT(VarChar(50),getdate(),120),'-',''),':',''),' ','')
				,@DataPath		= nullif(dbaadmin.[dbo].[dbaudf_GetSharePath](dbaadmin.[dbo].[dbaudf_getShareUNC]('mdf')),'Not Found')
				,@NdfPath		= COALESCE	(
									nullif(dbaadmin.[dbo].[dbaudf_GetSharePath](dbaadmin.[dbo].[dbaudf_getShareUNC]('ndf')),'Not Found')
									,@DataPath
									)
				,@LogPath		= nullif(dbaadmin.[dbo].[dbaudf_GetSharePath](dbaadmin.[dbo].[dbaudf_getShareUNC]('ldf')),'Not Found')
				,@FilePath		= COALESCE	(
									nullif(dbaadmin.[dbo].[dbaudf_GetSharePath](dbaadmin.[dbo].[dbaudf_getShareUNC]('backup')),'Not Found')
									,dbaadmin.[dbo].[dbaudf_getShareUNC]('backup')
									)

				-- CLEAN UP PATH NAMES AND MAKE SURE THEY ALL END WITH "\"
				,@DataPath		= @DataPath	+ CASE WHEN RIGHT(@DataPath,1)	= '\' THEN '' ELSE '\' END
				,@NdfPath		= @NdfPath	+ CASE WHEN RIGHT(@NdfPath,1)	= '\' THEN '' ELSE '\' END
				,@LogPath		= @LogPath	+ CASE WHEN RIGHT(@LogPath,1)	= '\' THEN '' ELSE '\' END
				,@FilePath		= @FilePath	+ CASE WHEN RIGHT(@FilePath,1)	= '\' THEN '' ELSE '\' END

				,@FilesRestored		= 0
				,@NewDBName		= COALESCE(@NewDBName,@DBName)
				,@Init			= 1
				,@Stats			= 1
				,@CRLF			= CHAR(13)+CHAR(10)

				,@MachineName		= LEFT(@@SERVERNAME+'\',CHARINDEX('\',@@SERVERNAME+'\')-1)
				,@ServerName		= REPLACE(@@SERVERNAME,'\','$')

				,@VersionMajor		= CAST(REVERSE(PARSENAME(REVERSE(CAST(SERVERPROPERTY ('productversion') AS SYSNAME)),1))AS Int)
				,@VersionMinor		= CAST(REVERSE(PARSENAME(REVERSE(CAST(SERVERPROPERTY ('productversion') AS SYSNAME)),2))AS Int)
				,@VersionBuild		= CAST(REVERSE(PARSENAME(REVERSE(CAST(SERVERPROPERTY ('productversion') AS SYSNAME)),3))AS Int)

				,@SetName		= COALESCE(@SetName,@ForceFileName,'')
				,@SetDesc		= COALESCE(@SetDesc,@ForceFileName,'')
				


		IF @FromServer	IS NOT NULL
		BEGIN
			SET @FilePath = '\\'+ LEFT(@FromServer,CHARINDEX('\',@FromServer+'\')-1)+'\'+REPLACE(@FromServer,'\','$')+'_Backup\' -- '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\'
		END

		IF @DataPath IS NULL AND @Mode NOT IN ('BF', 'BD', 'BL') 
		BEGIN
			PRINT ''
			RAISERROR('    -- ERROR: THE DBA "_MDF" SHARE DOES NOT EXIST OR IS INVALID.',-1,-1) WITH NOWAIT
			GOTO label99
		END

		IF @LogPath IS NULL AND @Mode NOT IN ('BF', 'BD', 'BL')
		BEGIN
			PRINT ''
			RAISERROR('    -- ERROR: THE DBA "_LDF" SHARE DOES NOT EXIST OR IS INVALID.',-1,-1) WITH NOWAIT
			GOTO label99
		END


		-- IS REDGATE INSTALLED
		IF OBJECT_ID('master.dbo.sqlbackup') IS NULL
			SELECT	@RedGateInstalled	= 0
		ELSE
			SELECT	@RedGateInstalled	= 1


		-- CAN SERVER USE MICROSOFT COMPRESSION
		IF (@VersionMajor = 10 AND CAST(SERVERPROPERTY ('Edition') AS SYSNAME) LIKE 'Enterprise%')	-- SQL2008 Enterprise Edition
		 OR (@VersionMajor = 10 AND @VersionMinor >= 50)						-- SQL2008 R2 +
		 OR (@VersionMajor > 10)									-- SQL2012 +
			SET @Compression = 1
		ELSE
			SET @Compression = 0

		IF @ForceEngine = 'REDGATE' AND @RedGateInstalled = 0
		BEGIN
			PRINT ''
			RAISERROR('    -- ERROR: @ForceEngine PARAMETER SPECIFIED "REDGATE" BUT REDGATE IS NOT INSTALLED.',-1,-1) WITH NOWAIT
			GOTO label99
		END

		IF @ForceCompression = 1 AND @Compression = 0
		BEGIN
			PRINT ''
			RAISERROR('    -- ERROR: @ForceCompression PARAMETER SPECIFIED "1" BUT MSSQL COMPRESSION IS NOT AVAILABLE ON THIS SQL VERSION.',-1,-1) WITH NOWAIT
			GOTO label99
		END

	END	-- VARIABLE INITIALIZATIONS AND PARAMETER CHECKING

	IF @Mode IN ('BF','BD','BL')
	BEGIN	-- SCRIPT BACKUPS					
	
		-- SET ENGINE TO USE
		SELECT	@BackupEngine = CASE	WHEN @ForceEngine IS NOT NULL							THEN @ForceEngine
					WHEN @DBName IN ('master','model','msdb','temp','dbaadmin','dbaperf','sqldeploy')	THEN 'MSSQL'
					WHEN @Compression = 1									THEN 'MSSQL'
					WHEN @RedGateInstalled = 1								THEN 'REDGATE'
					ELSE 'MSSQL' END
		
		--  SET EXTENSION
		IF @BackupEngine = 'REDGATE'
			SELECT	@Extension = CASE @Mode	
						WHEN 'BF' THEN 'SQB'
						WHEN 'BD' THEN 'SQD'
						WHEN 'BL' THEN 'SQT'
						END
		ELSE IF @Compression = 1
			SELECT	@Extension = CASE @Mode	
						WHEN 'BF' THEN 'cBAK'
						WHEN 'BD' THEN 'cDIF'
						WHEN 'BL' THEN 'cTRN'
						END
		ELSE
			SELECT	@Extension = CASE @Mode	
						WHEN 'BF' THEN 'BAK'
						WHEN 'BD' THEN 'DIF'
						WHEN 'BL' THEN 'TRN'
						END

		--SELECT @BackupEngine,@ForceEngine,@DBName,@Compression,@RedGateInstalled,@Extension

		-- BUILD LIST OF CURRENT FILE GROUPS IN DATABASE		
		Select @CMD		= REPLACE('USE {DBNAME};
						SET NOCOUNT ON;
						INSERT INTO	#FGs
						SELECT		fg.data_space_id
								,fg.name
								,COALESCE((cast((sum(a.used_pages) * 8192/1048576.) as decimal(15, 2))*25)/100,0) 
						FROM		sys.fileGroups fg
						LEFT JOIN	sys.allocation_units a 
							ON	fg.data_space_id = a.data_space_id

						LEFT JOIN	sys.fulltext_indexes fti
							ON	fg.data_space_id = fti.data_space_id

						LEFT JOIN	sys.fulltext_catalogs ftc
							ON	fti.fulltext_catalog_id = ftc.fulltext_catalog_id

						LEFT JOIN	sys.partitions p 
							ON	p.partition_id = a.container_id
						LEFT JOIN	sys.internal_tables it 
							ON	p.object_id = it.object_id
						GROUP BY	fg.data_space_id
								,fg.name;','{DBNAME}',@DBNAME)
		EXEC (@CMD)
		SET @CMD = NULL

		SELECT * FROM #FGs

		DECLARE LoopBackupFileGroups CURSOR
		FOR
		-- SELECT QUERY FOR CURSOR
		-- THIS UNION ALL CAUSES THE CURSOR TO RUN 
			-- ONE TIME IF THE @FILEGROUPS IS NULL
			-- ONCE FOR EACH FILE GROUP IF THE KEYWORD OF "ALL" IS USED
			-- OR ONCE FOR EACH FILEGROUP SPECIFIED IN THE @FileGroups PARAMETER

		--SELECT		SplitValue
		--FROM		[dbaadmin].[dbo].[dbaudf_StringToTable](@filegroups,',')
		--WHERE		@filegroups != 'ALL'
		--	AND	SplitValue IN (SELECT name FROM #FGs) -- USED TO ONLY ALLOW CURRENT FILEGROUP NAMES
		--UNION ALL

		SELECT		id
				,name
		FROM		#FGs
		WHERE		name in  (SELECT SplitValue FROM [dbaadmin].[dbo].[dbaudf_StringToTable](@filegroups,','))
			OR	@filegroups = 'ALL'
		UNION ALL
		SELECT		1
				,NULL
		WHERE		@filegroups IS NULL 
		ORDER BY	1

		OPEN LoopBackupFileGroups;
		FETCH LoopBackupFileGroups INTO @FGID, @FileGroup;
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN
				---------------------------- EXECUTE LOOP ONCE PER FILE GROUP SPECIFIED
				---------------------------- CURSOR LOOP TOP

				-- SET MULTIFILE SET SIZE
				IF @ForceSetSize is null
				BEGIN
					IF @Mode = 'BF'
					BEGIN
						-- GET THE SIZE OF THE FILEGROUP OR ALL FILEGROUPS IF @FileGroup IS NULL
						SELECT @Size = SUM(size) FROM #FGs WHERE name = COALESCE(@FileGroup,name) 
					END
					Else If @Mode = 'BD'
					BEGIN
      
						exec dbaadmin.dbo.dbasp_Estimate_Diff_Size @DBName = @DBname, @diffPrediction = @diffPrediction output
						Select @size = convert(float, @diffPrediction)
					END

					SELECT @SetSize = COALESCE(@Size,(1024*2))/(1024*2)
				END
				ELSE
					SET @SetSize = @ForceSetSize


				-- LIMIT SETSIZE BASED ON BACKUP ENGINE
				IF @SetSize < 1
					SET @SetSize = 1

				IF @SetSize > 64
					SET @SetSize = 64

				IF @BackupEngine = 'REDGATE' and @SetSize > 32
					SET @SetSize = 32


				SELECT @DBName,@FileGroup,@ForceSetSize,@SetSize,@Mode,@Size,@diffPrediction


				-- START BUILDING COMMAND

				SELECT	@CMD		= CASE @Mode  
								WHEN 'BL' THEN 'BACKUP LOG ['+@DBName+']' + @CRLF
								ELSE 'BACKUP DATABASE ['+@DBName+']' + @CRLF
								END
					,@SetNumber	= 0
					,@FileName	= COALESCE	(
									REPLACE(@ForceFileName,'$FG$',@FileGroup)
									,@DBName
										+ CASE @Mode       
											WHEN 'BF' THEN '_DB_'
											WHEN 'BD' THEN '_DFNTL_'
											WHEN 'BL' THEN '_TLOG_'
											END
										+ CASE
											WHEN @FileGroup IS NOT NULL THEN 'FG_'+@FileGroup+'_' 
											ELSE '' 
											END
										+@NOW
									)

				If @FileGroup IS NOT NULL
					SELECT	@CMD = @CMD + ' FILEGROUP = '''+@FileGroup+''''+@CRLF

				SELECT	@CMD = @CMD + ' TO ' + @CRLF

				IF @SetSize > 1
				BEGIN
					WHILE         @SetNumber < @SetSize
					BEGIN
						--SELECT @FilePath,@FileName,@SetNumber,@SetSize,@Extension

						SET    @SetNumber = @SetNumber + 1
						SET    @CMD2 = ' DISK = '''+@FilePath+@FileName+'_SET_'+RIGHT('0'+CAST(@SetNumber AS VARCHAR(2)),2)+'_OF_'+RIGHT('0'+CAST(@SetSize AS VARCHAR(2)),2)+'.'+@Extension+''''

						--PRINT @CMD2

						SET    @CMD   = @CMD + CASE @SetNumber  WHEN 1 THEN '' ELSE ',' END + @CMD2 + @CRLF
					END
					-- SET FILENAME TO A DOS COMPATIBLE MASK WHICH IDENTIFYS ALL FILES IN THE SET
					SET @FileName = @FileName + '_SET_??_OF_' + RIGHT('0'+CAST(@SetSize AS VARCHAR(2)),2)
				END
				ELSE
					SET    @CMD   = @CMD + ' DISK = '''+@FilePath+@FileName+'.'+@Extension+''''+ @CRLF

				-- ADD EXTENSION TO FILENAME FOR REMAINING USAGE
				SET @FileName = @FileName + '.' + @Extension

				--PRINT @CMD


				-- ADD ALL "WITH" PARAMETERS
				SELECT        @CMD	= @CMD
							+ ' WITH ' 
							+ dbaadmin.dbo.dbaudf_ConcatenateUnique (WithOptions)
				FROM		(
						SELECT CASE @CopyOnly WHEN 1 THEN 'COPY_ONLY' END					UNION ALL
						SELECT CASE @Mode WHEN 'BD' THEN 'DIFFERENTIAL' END					UNION ALL
						SELECT CASE @ForceChecksum WHEN 1 THEN 'CHECKSUM' WHEN 0 THEN 'NO_CHECKSUM' END		UNION ALL
						SELECT CASE WHEN @BackupEngine='MSSQL' AND @Compression=1 THEN 'COMPRESSION' END	UNION ALL
						SELECT CASE @BackupEngine WHEN 'REDGATE' THEN 'COMPRESSION = 1' END			UNION ALL
						SELECT CASE @BackupEngine WHEN 'MSSQL' THEN 'STATS = ' + CAST(@Stats AS VarChar) END	UNION ALL
						SELECT CASE @BackupEngine WHEN 'REDGATE' THEN 'SINGLERESULTSET' END			UNION ALL
						SELECT CASE @BackupEngine WHEN 'REDGATE' THEN 'THREADCOUNT = 3' END			UNION ALL
						SELECT 'NAME = ''' + @SetName + ''''							UNION ALL
						SELECT 'DESCRIPTION = ''' + @SetDesc + ''''
						) Data([WithOptions])
				WHERE		[WithOptions] IS NOT NULL
				
				--PRINT @CMD

				--  SPECIAL FORMATING FOR REDGATE
				If @BackupEngine = 'REDGATE'
					SET	@CMD	= 'EXEC Master.dbo.SQLBackup ''-SQL "' 
							+ REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@CMD,CHAR(9),' '),@CRLF,' '),'''',''''''),'  ',' '),'  ',' ')
							+ '"'''

				-- ADD LOGGING CALL
				SET	@CMD		= @CMD + ';' + @CRLF + @CRLF
							+ 'INSERT INTO dbo.backup_log values(getdate(), ''' 
							+ COALESCE(@DBName,'')		+ ''', ''' 
							+ COALESCE(@FileName,'')	+ ''', ''' 
							+ COALESCE(@FilePath,'')	+ ''', ''' 
							+ COALESCE(@mode,'')		+ ''')' 
							+ @CRLF

				SET	@syntax_out	= COALESCE(@syntax_out,'')
							+ @CRLF
							+ COALESCE(@CMD,'') -- USE COALESCE TO MAKE SURE THAT ONE BAD ENTRY DOES NOT NULL THE STRING

	

				---------------------------- CURSOR LOOP BOTTOM
				----------------------------
			END
 			FETCH NEXT FROM LoopBackupFileGroups INTO @FGID, @FileGroup;
		END
		CLOSE LoopBackupFileGroups;
		DEALLOCATE LoopBackupFileGroups;
	
	
	
	END	-- SCRIPT BACKUPS

	IF @Mode IN ('RD')
	BEGIN	-- SCRIPT DATABASE RESTORE				

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
										THEN dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(@FullPathName,@FilePath,''),'_','|'),'.','|'),REPLACE(@DBName,'_','|'),@DBName),5) 
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

			--SELECT * FROM #FileGroups

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

					SET		@TBL = [dbaadmin].[dbo].[dbaudf_FormatString](@FMT1,@ColName1,@ColName2,@ColName3,@ColName4,@ColName5,@ColName6,@ColName7,@ColName8,@ColName9,'') +@CRLF
							+ @HeaderLine +@CRLF
					SELECT		@TBL = @TBL + [dbaadmin].[dbo].[dbaudf_FormatString](@FMT2,FileGroupName,FileGroupID,HasFGExcluded,HasFGIncluded,BeingRestored,'','','','','') +@CRLF
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

			IF @RestoreToDateTime IS NOT NULL AND NOT EXISTS (SELECT * FROM @VDR WHERE BackupDateRange_Start <= @RestoreToDateTime AND BackupDateRange_End >= @RestoreToDateTime)
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

			IF @filegroups IS NOT NULL
			BEGIN	-- REMOVE FG BACKUPS FOR FG'S NOT BEING RESTORED	

				SELECT		DISTINCT
						T1.BackupFileName
				FROM		@FL T1
				JOIN		[dbaadmin].[dbo].[dbaudf_StringToTable](@filegroups,',') T2
						ON	T1.FileGroupName = T2.SplitValue
						AND	T1.IsPresent = 1



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

				SET		@TBL = [dbaadmin].[dbo].[dbaudf_FormatString](@FMT1,@ColName1,@ColName2,@ColName3,@ColName4,@ColName5,@ColName6,@ColName7,@ColName8,@ColName9,'') +@CRLF
						+ @HeaderLine +@CRLF
				SELECT		@TBL = @TBL + [dbaadmin].[dbo].[dbaudf_FormatString](@FMT2,Name,FromServer,Type,Engine,SetSize,Files,Size_GB,Size,'','') +@CRLF
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

				SET		@TBL = [dbaadmin].[dbo].[dbaudf_FormatString](@FMT1,@ColName1,@ColName2,@ColName3,@ColName4,@ColName5,@ColName6,@ColName7,@ColName8,@ColName9,'') +@CRLF
						+ @HeaderLine +@CRLF
				SELECT		@TBL = @TBL + [dbaadmin].[dbo].[dbaudf_FormatString](@FMT2,Name,FirstLSN,LastLSN,DatabaseBackupLSN,'','','','','','') +@CRLF
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

				SET		@TBL = [dbaadmin].[dbo].[dbaudf_FormatString](@FMT1,@ColName1,@ColName2,@ColName3,@ColName4,@ColName5,@ColName6,@ColName7,@ColName8,@ColName9,'') +@CRLF
						+ @HeaderLine +@CRLF
				SELECT		@TBL = @TBL + [dbaadmin].[dbo].[dbaudf_FormatString](@FMT2,Name,BackupTimeStamp,BackupStartDate,BackupFinishDate,BackupDateRange_Start,BackupDateRange_End,BackupChainStartDate,BackupLinkStartDate,'','') +@CRLF
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

				SET		@TBL = [dbaadmin].[dbo].[dbaudf_FormatString](@FMT1,@ColName1,@ColName2,@ColName3,@ColName4,@ColName5,@ColName6,@ColName7,@ColName8,@ColName9,'') +@CRLF
						+ @HeaderLine +@CRLF
				SELECT		@TBL = @TBL + [dbaadmin].[dbo].[dbaudf_FormatString](@FMT2,LogicalName,DriveLetter,New_PhysicalName,FileExists,ExistingSizeGB,DriveFreeGB,SizeGB,MaxSizeGB,'','') +@CRLF
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

				SET		@TBL = [dbaadmin].[dbo].[dbaudf_FormatString](@FMT1,@ColName1,@ColName2,@ColName3,@ColName4,@ColName5,@ColName6,@ColName7,@ColName8,@ColName9,'') +@CRLF
						+ @HeaderLine +@CRLF
				SELECT		@TBL = @TBL + [dbaadmin].[dbo].[dbaudf_FormatString](@FMT2,DriveLetter,SizeGB,AvailableGB,FreeGB,DriveType,FileSystem,IsReady,VolumeName,'','') +@CRLF
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

			IF @WorkDir IS NOT NULL
			BEGIN		-- COPY FILES TO LOCAL WORK DIRECTORY AND RESTORE FROM THERE

				;WITH		Settings
						AS
						(
						SELECT		32		AS [QueueMax]		-- Max Number of files coppied at once.
								,'false'	AS [ForceOverwrite]	-- true,false
								,1		AS [Verbose]		-- -1 = Silent, 0 = Normal, 1 = Percent Updates
								,300		AS [UpdateInterval]	-- rate of progress updates in Seconds
						)
						,CopyFile -- MoveFile, DeleteFile
						AS
						(
						SELECT		T2.FullPathName		AS [Source]
								,@WorkDir + T2.Name	AS [Destination]
						FROM		@SF T1
						CROSS APPLY	dbaadmin.dbo.dbaudf_DirectoryList2(@FilePath,T1.Name,0) T2
						)
				SELECT		@CMD =	[dbaadmin].[dbo].[dbaudf_FormatXML2String]((
								SELECT		*
										,(SELECT * FROM CopyFile FOR XML RAW ('CopyFile'), TYPE)
								FROM		Settings
								FOR XML RAW ('Settings'),TYPE, ROOT('FileProcess')
								))


				SELECT		@syntax_out	= COALESCE(@syntax_out,'')
								+ @CRLF
								+ 'DECLARE	@Data XML'
								+ @CRLF
								+ 'SET	@Data		='
								+ @CRLF
								+ ''''+ @CMD + ''''
								+ @CRLF
								+ 'exec dbasp_FileHandler @Data'
								+ @CRLF

			END

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
						WHERE		BackupFileName = @FilePath+T1.[Name]
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


			OPEN RestoreDBCursor
			FETCH NEXT FROM RestoreDBCursor INTO @RestoreOrder,@BackupTimeStamp,@BackupType,@BackupEngine,@SetSize,@FileName,@FGID
			WHILE (@@fetch_status <> -1)
			BEGIN
				IF (@@fetch_status <> -2)
				BEGIN
					--SELECT @RestoreOrder,@BackupTimeStamp,@BackupType,@BackupEngine,@SetSize,@FileName,@FGID,@FilePath,@FileName

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

					--SELECT		BackupFileName , @FilePath+@FileName 
					--FROM		@FL

					INSERT INTO	#filelist
					SELECT		* 
					FROM		@FL
					WHERE		BackupFileName = @FilePath+@FileName
						OR	BackupFileName = @FileName

					SET		@FileNameSET = NULL
				
					IF @WorkDir IS NOT NULL
						SELECT		@FileNameSET = COALESCE(@FileNameSET + @CRLF+', DISK = '''+@WorkDir + T1.Name+'''','DISK = '''+@WorkDir + T1.Name+'''')
						FROM		dbaadmin.dbo.dbaudf_DirectoryList2(@FilePath,@FileName,0) T1
						ORDER BY	T1.Name
					ELSE
						SELECT		@FileNameSET = COALESCE(@FileNameSET + @CRLF+', DISK = '''+T1.FullPathName+'''','DISK = '''+T1.FullPathName+'''')
						FROM		dbaadmin.dbo.dbaudf_DirectoryList2(@FilePath,@FileName,0) T1
						ORDER BY	T1.Name		
				
					--PRINT		@FileNameSET
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
				--PRINT @CMD
						IF @FileGroup IS NOT NULL
							SELECT	@CMD = @CMD + dbaadmin.dbo.dbaudf_ConcatenateUnique('FILEGROUP = '''+FileGroupName+'''')
							FROM	#filelist
							WHERE	isPresent = 1

				--PRINT @CMD
						SET @CMD = @CMD + CHAR(13)+ CHAR(10)+'FROM    '+@FileName+ @CRLF
				--PRINT @CMD
						SET @CMD	= @CMD 
								+ 'WITH    ' + CASE @partial_flag WHEN 1 THEN 'PARTIAL, ' ELSE '' END
								+ 'NORECOVERY, REPLACE' + @CRLF

				--PRINT @CMD
						IF @BackupType = 'db'
						-- DB BACKUPS SHOULD ONLY USE MOVE PARAMETERS FOR DEVICES THAT ARE IN THAT BACKUP FILE
						-- FILEGROUP BACKUPS MAY CONTAIN SOME OR ALL OF THE FILES.
						BEGIN
							SELECT		@CMD = @CMD
									+ '        ,MOVE ''' + LogicalName + ''' TO ''' + NEW_PhysicalName + '''' + @CRLF
							FROM		#filelist
							WHERE		isPresent = 1
								AND	(type = 'L' OR @filegroups IS NULL OR FileGroupName IN (Select SplitValue FROM [dbaadmin].[dbo].[dbaudf_StringToTable](@filegroups,',')))
							ORDER BY	FileID
						END
						ELSE
						-- DIFFERENTIAL BACKUPS SHOULD ONLY USE MOVE PARAMETERS FOR DEVICES THAT ARE NEW IN THAT BACKUP FILE
						BEGIN
							SELECT		@CMD = @CMD
									+ '        ,MOVE ''' + LogicalName + ''' TO ''' + NEW_PhysicalName + '''' + @CRLF
							FROM		#filelist T1
							WHERE		isPresent = 1
								AND	(type = 'L' OR @filegroups IS NULL OR FileGroupName IN (Select SplitValue FROM [dbaadmin].[dbo].[dbaudf_StringToTable](@filegroups,',')))
								AND	NOT EXISTS(SELECT * FROM #filelist_last WHERE isPresent = 1 AND LogicalName = T1.LogicalName)
							ORDER BY	T1.FileID
						END
					END

				--PRINT @CMD
		
					IF	-- TRANSACTION LOG BACKUP FILE
					@BackupType = 'tlog'
					BEGIN
						SET @CMD	= 'RESTORE LOG ['+@NewDBName+'] FROM '+@FileName
								+ ' WITH NORECOVERY'
								+ CASE	WHEN @RestoreToDateTime IS NOT NULL 
									THEN ', STOPAT = N'''+CAST(@RestoreToDateTime AS VarChar(50))+''''
									ELSE '' END

						SELECT		@CMD = @CMD
								+ '        ,MOVE ''' + LogicalName + ''' TO ''' + NEW_PhysicalName + '''' + @CRLF
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
														,@CRLF,' ')
														,'''','''''') 
														,'  ',' ')
														,'  ',' ')
														+'"'''
					END
					ELSE	-- MICROSOFT SYNTAX
					BEGIN
						SET @CMD = @CMD + '        ,STATS=1' + @CRLF
					END
			--PRINT @CMD
					IF @Verbose >= 2
					BEGIN
						PRINT '   -- ' + REPLACE(@CMD,@CRLF,@CRLF+'   -- ')
						RAISERROR('',-1,-1) WITH NOWAIT
					END

					SET	@syntax_out	= COALESCE(@syntax_out,'') 
								+ @CRLF
								+ COALESCE(@CMD,'') -- USE COALESCE TO MAKE SURE THAT ONE BAD ENTRY DOES NOT NULL THE STRING

			--PRINT @syntax_out

					-- ADD EXISTING FILELIST TO THE SUMMARY SO THAT YOU CAN TELL IF A DEVICE IS NEW 
					-- TO THE DATABASE WITHIN THE CURRENT BACKUP FILE
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
					PRINT '   -- ' + REPLACE(@CMD,@CRLF,@CRLF+'   -- ')
					RAISERROR('',-1,-1) WITH NOWAIT
				END

				SET	@syntax_out	= COALESCE(@syntax_out,'')
							+ @CRLF
							+ COALESCE(@CMD,'') -- USE COALESCE TO MAKE SURE THAT ONE BAD ENTRY DOES NOT NULL THE STRING
			END


			IF @WorkDir IS NOT NULL
			BEGIN		-- COPY FILES TO LOCAL WORK DIRECTORY AND RESTORE FROM THERE

				;WITH		Settings
						AS
						(
						SELECT		32		AS [QueueMax]		-- Max Number of files coppied at once.
								,'false'	AS [ForceOverwrite]	-- true,false
								,1		AS [Verbose]		-- -1 = Silent, 0 = Normal, 1 = Percent Updates
								,300		AS [UpdateInterval]	-- rate of progress updates in Seconds
						)
						,DeleteFile
						AS
						(
						SELECT		@WorkDir + T2.Name	AS [Source]
						FROM		@SF T1
						CROSS APPLY	dbaadmin.dbo.dbaudf_DirectoryList2(@FilePath,T1.Name,0) T2
						)
				SELECT		@CMD =	[dbaadmin].[dbo].[dbaudf_FormatXML2String]((
								SELECT		*
										,(SELECT * FROM DeleteFile FOR XML RAW ('DeleteFile'), TYPE)
								FROM		Settings
								FOR XML RAW ('Settings'),TYPE, ROOT('FileProcess')
								))


				SELECT		@syntax_out	= COALESCE(@syntax_out,'')
								+ @CRLF
								+ 'SET	@Data		='
								+ @CRLF
								+ ''''+ @CMD + ''''
								+ @CRLF
								+ 'exec dbasp_FileHandler @Data'
								+ @CRLF

			END




			IF @Verbose >= 1
			BEGIN
				RAISERROR('  -- Done with DB Restore''s',-1,-1) WITH NOWAIT
				RAISERROR('',-1,-1) WITH NOWAIT
				RAISERROR('',-1,-1) WITH NOWAIT
			END

		END	-- BUILD RESTORE SCRIPT

		--PRINT @syntax_out

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

	END	-- SCRIPT DATABASE RESTORE

	IF @Verbose >= 1
		RAISERROR('-- Done --',-1,-1) WITH NOWAIT

	--  Finalization  -------------------------------------------------------------------
	label99:
	
	IF @Verbose >= 1
	BEGIN
		RAISERROR('',-1,-1) WITH NOWAIT
		RAISERROR('',-1,-1) WITH NOWAIT
	END
 GO

  DECLARE	@syntax_out		VarChar(max)	


 EXEC		[dbaadmin].[dbo].[dbasp_format_BackupRestore] 
				@DBName			= 'Getty_Images_US_Inc__MSCRM'
				,@Mode			= 'BF'
				,@FileGroups		= 'ALL' --'PRIMARY,FG2'
				,@syntax_out		= @syntax_out OUTPUT






-- EXEC		[dbaadmin].[dbo].[dbasp_format_BackupRestore] 
--				@DBName			= 'dbaperf'
--				,@NewDBName		= 'XXX'
--				,@Mode			= 'BF'
--				--,@FromServer		= 'SEAPCRMSQL1A'
--				--,@FileGroups		= 'PRIMARY,FG2'
--				--,@Verbose		= 0
--				,@syntax_out		= @syntax_out OUTPUT
--				--,@RestoreToDateTime	= '2013-10-21 21:46:48'
--				,@WorkDir		= 'd:\MSSQL\Backup\'
--				,@FullReset		= 1
----				,@OverrideXML		=
----'<RestoreFileLocations>
----  <Override LogicalName="ftrow_ftcat_documentindex_9e0efd13ecab427f974e7f1336eb7159" PhysicalName="D:\SQL\MSSQL10_50.MSSQLSERVER\MSSQL\FTData\ftrow_ftcat_documentindex_9e0efd13ecab427f974e7f1336eb7159.ndf" New_PhysicalName="D:\MSSQL\data\ftrow_ftcat_documentindex_9e0efd13ecab427f974e7f1336eb7159.ndf" />
----  <Override LogicalName="Getty_Images_US_Inc__MSCRM" PhysicalName="E:\Data\Getty_Images_US_Inc__MSCRM.mdf" New_PhysicalName="D:\MSSQL\data\Getty_Images_US_Inc__MSCRM.mdf" />
----  <Override LogicalName="Getty_Images_US_Inc__MSCRM_log" PhysicalName="F:\log\Getty_Images_US_Inc__MSCRM_log.LDF" New_PhysicalName="D:\MSSQL\data\Getty_Images_US_Inc__MSCRM_log.LDF" />
----  <Override LogicalName="Getty_Images_US_Inc__MSCRM2" PhysicalName="m:\data\Getty_Images_US_Inc__MSCRM2.ndf" New_PhysicalName="D:\MSSQL\Log\Getty_Images_US_Inc__MSCRM2.ndf" />
----  <Override LogicalName="Getty_Images_US_Inc__MSCRM3" PhysicalName="H:\Data\Getty_Images_US_Inc__MSCRM3.ndf" New_PhysicalName="D:\MSSQL\Log\Getty_Images_US_Inc__MSCRM3.ndf" />
----  <Override LogicalName="Getty_Images_US_Inc__MSCRM4" PhysicalName="H:\Data\Getty_Images_US_Inc__MSCRM4.ndf" New_PhysicalName="D:\MSSQL\Log\Getty_Images_US_Inc__MSCRM4.ndf" />
----  <Override LogicalName="Getty_Images_US_Inc__MSCRM5" PhysicalName="I:\Data\Getty_Images_US_Inc__MSCRM5.ndf" New_PhysicalName="D:\MSSQL\Log\Getty_Images_US_Inc__MSCRM5.ndf" />
----  <Override LogicalName="Getty_Images_US_Inc__MSCRM6" PhysicalName="I:\Data\Getty_Images_US_Inc__MSCRM6.ndf" New_PhysicalName="D:\MSSQL\Log\Getty_Images_US_Inc__MSCRM6.ndf" />
----  <Override LogicalName="Getty_Images_US_Inc__MSCRM7" PhysicalName="I:\Data\Getty_Images_US_Inc__MSCRM7.ndf" New_PhysicalName="D:\MSSQL\Log\Getty_Images_US_Inc__MSCRM7.ndf" />
----</RestoreFileLocations>'

--				--,@ForceEngine		= NULL
--				--,@ForceSetSize		= NULL
--				--,@ForceCompression	= NULL
--				--,@ForceChecksum		= NULL

--				--,@FilePath		= NULL
--				--,@FileName		= NULL
				
				
--				--,@WorkDir		= NULL

--				--,@SetName		= NULL
--				--,@SetDesc		= NULL
						
--				--,@CopyOnly		= 0
--				--,@RestoreToDateTime	= NULL
--				--,@LeaveNORECOVERY	= 0
--				--,@NoLogRestores		= 0
--				--,@NoDifRestores		= 0
--				--,@FullReset		= 1
--				--,@IgnoreSpaceLimits	= 1
--				--,@OverrideXML		= NULL

--				--,@Verbose		= 1 
				
						
DECLARE @TextLine VarChar(MAX)
DECLARE PrintLargeResults CURSOR
FOR
-- SELECT QUERY FOR CURSOR
SELECT		SplitValue
FROM		dbaadmin.dbo.dbaudf_SplitByLines(@syntax_out)
ORDER BY	OccurenceID 

OPEN PrintLargeResults;
FETCH PrintLargeResults INTO @TextLine;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
	
		PRINT @TextLine

		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM PrintLargeResults INTO @TextLine;
END
CLOSE PrintLargeResults;
DEALLOCATE PrintLargeResults;

