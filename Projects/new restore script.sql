SET NOCOUNT ON

--------------------------------------------------------------------------------------			
--------------------------------------------------------------------------------------			
--									DEFINE PARAMETERS
--------------------------------------------------------------------------------------			
--------------------------------------------------------------------------------------			

DECLARE		@DBName					SYSNAME

			,@File_Backup			VarChar(2048)
			,@Path_Backup			VarChar(2048)
			,@Path_MDF				VarChar(2048)
			,@Path_NDF				VarChar(2048)
			,@Path_LDF				VarChar(2048)
			
			,@Flag_Partial			CHAR(1)
			,@Flag_NoRecovery		CHAR(1)
			,@Flag_ScriptOnly		CHAR(1)
			,@Flag_IgnoreCtlTbl		CHAR(1)
			,@Flag_SourcePath		CHAR(1)
			,@Flag_DropDB			CHAR(1)
			,@Flag_PostShrink		CHAR(1)
			,@Flag_DateStampFiles	CHAR(1)
			,@Flag_CommentedScript  CHAR(1)
			
			,@CSV_filegroups		VarChar(2048)
			,@CSV_files				VarChar(2048)
			,@PassThruComment		VarChar(8000)

--------------------------------------------------------------------------------------			
--------------------------------------------------------------------------------------			
--								SET PARAMETERS & DEFAULTS
--------------------------------------------------------------------------------------			
--------------------------------------------------------------------------------------			

SELECT		@DBName					= 'Gestalt'
			,@File_Backup			= 'Gestalt.SQB'
			,@Path_Backup			= '\\ASPSQLTEST01-N\ASPSQLTEST01-N$A_backup'
			,@Path_MDF				= NULL
			,@Path_NDF				= NULL
			,@Path_LDF				= NULL
			,@Flag_Partial			= 'Y'
			,@Flag_NoRecovery		= 'N'
			,@Flag_ScriptOnly		= 'Y'
			,@Flag_IgnoreCtlTbl		= 'N'
			,@Flag_SourcePath		= 'N'
			,@Flag_DropDB			= 'Y'
			,@Flag_PostShrink		= 'N'
			,@Flag_DateStampFiles	= 'N'
			,@Flag_CommentedScript	= 'N'
			,@CSV_filegroups		= NULL
			,@CSV_files				= 'Gestalt_data'

--------------------------------------------------------------------------------------			
--------------------------------------------------------------------------------------			
--									START OF CODE
--------------------------------------------------------------------------------------			
--------------------------------------------------------------------------------------			

DECLARE		@ShareName				sysname
			,@Path_Default_MDF		VarChar(2048)
			,@Path_Default_NDF		VarChar(2048)
			,@Path_Default_LDF		VarChar(2048)
			,@BkUpMethod			VarChar(50)
			,@DynamicCode			VarChar(8000)
			,@DynamicCode2			VarChar(8000)
			,@DynamicCode3			VarChar(8000)
			,@CRLF					VarChar(10)
			,@DateTime_Both			DateTime
			,@DateTime_Date			VarChar(8)
			,@DateTime_Time			VarChar(4) --HHMM
			,@ProductVersionInt		INT
			,@ProductVersion		VarChar(50)
			,@ProductEdition		VarChar(50)
			,@FlagInt_Misc			INT
			,@GUID_RunInstance		UniqueIdentifier

DECLARE	@Output			TABLE
							(
							[rownum]		int identity primary key
							,[TextOutput]	nVARCHAR(4000)
							)
									
DECLARE @filelist		TABLE
							(
							LogicalName nvarchar(128) null, 
							PhysicalName nvarchar(260) null, 
							Type char(1) null, 
							FileGroupName nvarchar(128) null, 
							Size numeric(20,0) null, 
							MaxSize numeric(20,0) null,
							FileId bigint null,
							CreateLSN numeric(25,0) null,
							DropLSN numeric(25,0) null,
							UniqueId uniqueidentifier null,
							ReadOnlyLSN numeric(25,0) null,
							ReadWriteLSN numeric(25,0) null,
							BackupSizeInBytes bigint null,
							SourceBlockSize int null,
							FileGroupId int null,
							LogGroupGUID sysname null,
							DifferentialBaseLSN numeric(25,0) null,
							DifferentialBaseGUID uniqueidentifier null,
							IsReadOnly bit null,
							IsPresent bit null,
							TDEThumbprint varbinary(32) null
							)

IF (OBJECT_ID('tempdb..#ExecOutput'))	IS NOT NULL	DROP TABLE #ExecOutput
IF (OBJECT_ID('tempdb..#File_Exists'))	IS NOT NULL	DROP TABLE #File_Exists
CREATE TABLE	#ExecOutput			([rownum] int identity primary key,[TextOutput] VARCHAR(8000));
CREATE	TABLE	#File_Exists		(isFile bit, isDir bit, hasParentDir bit)

IF @Flag_DateStampFiles = 'Y'
	SELECT		@DateTime_Both	= GetDate()
				,@DateTime_Time	= convert(varchar(8), @DateTime_Both, 8)
				,@DateTime_Date	= '_' + convert(char(8), @DateTime_Both, 112) 
					+ substring(@DateTime_Time, 1, 2) 
					+ substring(@DateTime_Time, 4, 2) 
					+ substring(@DateTime_Time, 7, 2) 


-- GET DEFAULT BACKUP SHARE IF PATH NOT SET
IF nullif(@Path_Backup,'') IS NULL
BEGIN			
	SELECT @ShareName = REPLACE(@@SERVERNAME,'\','$') + '_Backup'
	exec dbaadmin.dbo.dbasp_get_share_path @ShareName,@Path_Backup OUT
END

SELECT		@CRLF					= CHAR(13)+CHAR(10)
			,@GUID_RunInstance		= NEWID()
									-- CLEAN OFF TRAILING SLASHES
			,@Path_Backup			= REPLACE(REPLACE(@Path_Backup+'|','\|',''),'|','')
			,@Path_MDF				= REPLACE(REPLACE(@Path_MDF+'|','\|',''),'|','')
			,@Path_NDF				= REPLACE(REPLACE(@Path_NDF+'|','\|',''),'|','')
			,@Path_LDF				= REPLACE(REPLACE(@Path_LDF+'|','\|',''),'|','')
			
			,@ProductVersion		= CAST(SERVERPROPERTY('productversion') AS VarChar(50))
			,@ProductEdition		= CAST(SERVERPROPERTY('Edition') AS VarChar(50))
			,@ProductVersionInt		= CAST(RIGHT('0000'+dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(CAST(@ProductVersion AS VarChar(50)),'.','|'),1),2)
									+ RIGHT('0000'+dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(CAST(@ProductVersion AS VarChar(50)),'.','|'),2),2)
									+ RIGHT('0000'+dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(CAST(@ProductVersion AS VarChar(50)),'.','|'),3),4) AS INT)

-- IDENTIFY BACKUP METHOD FROM FILE EXTENSION
SELECT	@BkUpMethod = CASE
	WHEN @File_Backup like '%.BKP' THEN 'LS'
	WHEN @File_Backup like '%.DFL' THEN 'LS'
	WHEN @File_Backup like '%.TNL' THEN 'LS'
	
	WHEN @File_Backup like '%.SQB' THEN 'RG'
	WHEN @File_Backup like '%.SQD' THEN 'RG'
	WHEN @File_Backup like '%.SQT' THEN 'RG'
	
	WHEN @File_Backup like '%.BAK' THEN 'MS'
	WHEN @File_Backup like '%.DIF' THEN 'MS'
	WHEN @File_Backup like '%.TRN' THEN 'MS'
	
	WHEN @File_Backup like '%.CBAK' THEN 'MS2'
	
	ELSE '??' END

--  CHECK INPUT PARMETERS
SET @FlagInt_Misc = NULL;TRUNCATE TABLE #File_Exists;INSERT INTO #File_Exists EXEC Master.dbo.xp_fileexist @Path_Backup;SELECT @FlagInt_Misc = [isDir] FROM #File_Exists
if isnull(@FlagInt_Misc,0) != 1
BEGIN
	SET @DynamicCode = 'DBA ERROR: Can Not Locate Backup Directory: ' + isnull(@Path_Backup,'') + ', Set @Path_Backup or Verify "_Backup" Share.'
	RAISERROR(@DynamicCode,16,-1)
	GOTO TheEnd
END

SET @FlagInt_Misc = NULL;TRUNCATE TABLE #File_Exists;INSERT INTO #File_Exists EXEC Master.dbo.xp_fileexist @Path_MDF;SELECT @FlagInt_Misc = [isDir] FROM #File_Exists
if isnull(@FlagInt_Misc,0) != 1 AND nullif(@Path_MDF,'') IS NOT NULL
BEGIN
	SET @DynamicCode = 'DBA ERROR: Can Not Locate MDF Directory: '+isnull(@Path_MDF,'')+', Set @Path_MDF to Valid Directory or Leave NULL.'
	RAISERROR(@DynamicCode,16,-1)
	GOTO TheEnd
END

SET @FlagInt_Misc = NULL;TRUNCATE TABLE #File_Exists;INSERT INTO #File_Exists EXEC Master.dbo.xp_fileexist @Path_NDF;SELECT @FlagInt_Misc = [isDir] FROM #File_Exists
if isnull(@FlagInt_Misc,0) != 1 AND nullif(@Path_NDF,'') IS NOT NULL
BEGIN
	SET @DynamicCode = 'DBA ERROR: Can Not Locate NDF Directory: '+isnull(@Path_NDF,'')+', Set @Path_NDF to Valid Directory or Leave NULL.'
	RAISERROR(@DynamicCode,16,-1)
	GOTO TheEnd
END

SET @FlagInt_Misc = NULL;TRUNCATE TABLE #File_Exists;INSERT INTO #File_Exists EXEC Master.dbo.xp_fileexist @Path_LDF;SELECT @FlagInt_Misc = [isDir] FROM #File_Exists
if isnull(@FlagInt_Misc,0) != 1 AND nullif(@Path_LDF,'') IS NOT NULL
BEGIN
	SET @DynamicCode = 'DBA ERROR: Can Not Locate LDF Directory: '+isnull(@Path_LDF,'')+', Set @Path_LDF to Valid Directory or Leave NULL.'
	RAISERROR(@DynamicCode,16,-1)
	GOTO TheEnd
END

IF nullif(@DBName,'') IS NULL
BEGIN
	SET @DynamicCode = 'DBA ERROR: Database Name Was Not Specified, Set @DBName'
	RAISERROR(@DynamicCode,16,-1)
	GOTO TheEnd
END

-- CHECK FOR PARAMETER CONFLICTS
IF nullif(@Flag_DropDB,'N') = 'Y' AND nullif(@Flag_Partial,'N') = 'Y'
BEGIN
	SET @DynamicCode = 'DBA ERROR: Conflicting Parameters @Flag_DropDB, @Flag_Partial, You Can Not Drop Before a Partial Restore.'
	RAISERROR(@DynamicCode,16,-1)
	GOTO TheEnd
END


-- CHECK IF APP IS INSTALLED FOR CURRENT BACKUP METHOD
IF	@BkUpMethod = '??' 
BEGIN
	RAISERROR('DBA ERROR: Unknown Backup File Type, Make Sure File Extension is Standardized.',16,-1)
	GOTO TheEnd
END
	
IF	@BkUpMethod = 'LS' AND OBJECT_ID('master.dbo.xp_backup_database') IS NULL
BEGIN
	RAISERROR('DBA ERROR: Can Not Restore LiteSpeed Backup File, Software Not Installed.',16,-1)
	GOTO TheEnd
END

IF	@BkUpMethod = 'RG' AND OBJECT_ID('master.dbo.sqlbackup') IS NULL
BEGIN
	RAISERROR('DBA ERROR: Can Not Restore RedGate Backup File, Software Not Installed.',16,-1)
	GOTO TheEnd
END

IF	@BkUpMethod = 'MS2' AND (@ProductVersionInt < 10500000 OR (@ProductVersionInt < 10000000 AND @ProductEdition Like '%Enterprise%'))
BEGIN
	RAISERROR('DBA ERROR: Can Not Restore Compressed Backup File, SQL Must Be 2008 Enterprise or R2 and Better.',16,-1)
	GOTO TheEnd
END


-- READ FILELIST FROM BACKUP FILE
IF @BkUpMethod = 'MS' and @ProductVersionInt >= 10000000
BEGIN
	SET @DynamicCode = 'RESTORE FILELISTONLY FROM DISK = '''+@Path_Backup+'\'+@File_Backup+''''
	insert into @filelist
	EXEC (@DynamicCode)
END
ELSE IF @BkUpMethod = 'MS' and @ProductVersionInt < 10000000
BEGIN
	SET @DynamicCode = 'RESTORE FILELISTONLY FROM DISK = '''+@Path_Backup+'\'+@File_Backup+''''
	insert into @filelist(LogicalName,PhysicalName,Type,FileGroupName,Size,MaxSize,FileId,CreateLSN,DropLSN,UniqueId,ReadOnlyLSN,ReadWriteLSN,BackupSizeInBytes,SourceBlockSize,FileGroupId,LogGroupGUID,DifferentialBaseLSN,DifferentialBaseGUID,IsReadOnly,IsPresent)
	EXEC (@DynamicCode)
END
ELSE IF @BkUpMethod = 'RG'
BEGIN
	SET @DynamicCode = 'Exec master.dbo.sqlbackup ''-SQL "RESTORE FILELISTONLY FROM DISK = '''''+@Path_Backup+'\'+@File_Backup+'''''"'''
	insert into @filelist(LogicalName,PhysicalName,Type,FileGroupName,Size,MaxSize,FileId,CreateLSN,DropLSN,UniqueId,ReadOnlyLSN,ReadWriteLSN,BackupSizeInBytes,SourceBlockSize,FileGroupId,LogGroupGUID,DifferentialBaseLSN,DifferentialBaseGUID,IsReadOnly,IsPresent)
	EXEC (@DynamicCode)
END
ELSE IF @BkUpMethod = 'LS'
BEGIN
	SET @DynamicCode = 'EXEC master.dbo.xp_restore_filelistonly @filename = '''+@Path_Backup +'\'+@File_Backup+''''
	insert into @filelist(LogicalName,PhysicalName,Type,FileGroupName,Size,MaxSize)
	EXEC (@DynamicCode)
END

-- GET PATHS FROM SHARES
SELECT @ShareName = REPLACE(@@SERVERNAME,'\','$') + '_mdf'
exec dbaadmin.dbo.dbasp_get_share_path @ShareName,@Path_Default_MDF OUT

SELECT @ShareName = REPLACE(@@SERVERNAME,'\','$') + '_ndf'
exec dbaadmin.dbo.dbasp_get_share_path @ShareName,@Path_Default_NDF OUT

-- USE MDF FOR NDF IF SHARE NOT CREATED
SELECT	@Path_Default_NDF = COALESCE(@Path_Default_NDF,@Path_Default_MDF)

SELECT @ShareName = REPLACE(@@SERVERNAME,'\','$') + '_ldf'
exec dbaadmin.dbo.dbasp_get_share_path @ShareName,@Path_Default_LDF OUT

--GET PATHS FROM DBAADMIN DB IF NOT FOUND FROM SHARES
SELECT		@Path_Default_MDF = CASE RIGHT(filename,CHARINDEX('.',REVERSE(filename))-1)
								WHEN 'mdf' THEN COALESCE(@Path_Default_MDF,REPLACE(filename,'\'+RIGHT(filename,CHARINDEX('\',REVERSE(filename))-1),''))
								ELSE @Path_Default_MDF END
			,@Path_Default_NDF = CASE RIGHT(filename,CHARINDEX('.',REVERSE(filename))-1)
								WHEN 'ndf' THEN COALESCE(@Path_Default_NDF,REPLACE(filename,'\'+RIGHT(filename,CHARINDEX('\',REVERSE(filename))-1),''))
								ELSE @Path_Default_NDF END					
			,@Path_Default_LDF = CASE RIGHT(filename,CHARINDEX('.',REVERSE(filename))-1)
								WHEN 'ldf' THEN COALESCE(@Path_Default_LDF,REPLACE(filename,'\'+RIGHT(filename,CHARINDEX('\',REVERSE(filename))-1),''))
								ELSE @Path_Default_LDF END					
FROM		dbaadmin.sys.sysfiles


INSERT INTO	@Output([TextOutput])
          SELECT 'RESTORE DATABASE ['+@DBName+']'

-- CREATE LINES FOR FILES AND/OR FILEGROUPS
If @Flag_Partial = 'Y' and (nullif(@CSV_filegroups,'') IS NOT NULL OR nullif(@CSV_files,'') IS NOT NULL)
BEGIN
	INSERT INTO	@Output([TextOutput])
	SELECT		CASE WHEN [rownum] = 1 THEN '' ELSE ',' END + [CommandText]
	FROM		(
				SELECT		Rank() OVER(ORDER BY [set],[nmbr]) [rownum],[CommandText]
				FROM		(		
							SELECT		1 [Set],OccurenceId [nmbr],'	FILE		=''' + SplitValue + '''' [CommandText]
							FROM		dbaadmin.dbo.dbaudf_split(@CSV_files,',')
							UNION ALL
							SELECT		2 [Set],OccurenceId [nmbr],'	FILEGROUP	=''' + SplitValue + ''''
							FROM		dbaadmin.dbo.dbaudf_split(@CSV_filegroups,',')
							) Data
				)Data
	ORDER BY	[rownum]			
END			


			
-- WHERE TO RESTORE FROM			
INSERT INTO	@Output([TextOutput])
SELECT		'FROM DISK = '''+@Path_Backup+'\'+@File_Backup+''''

-- GENERATE INITAL WITH CLAUSE
IF @Flag_Differential = 'Y' OR @Flag_NoRecovery = 'Y'
BEGIN
	IF @Flag_Partial = 'Y' AND nullif(@CSV_filegroups,'') IS NOT NULL
	BEGIN
		INSERT INTO	@Output([TextOutput])
		SELECT		'WITH	PARTIAL'		UNION ALL
		SELECT		'		,NORECOVERY'	UNION ALL
		SELECT		'		,REPLACE'
	END
	ELSE
	BEGIN
		INSERT INTO	@Output([TextOutput])
		SELECT		'WITH	NORECOVERY'	UNION ALL
		SELECT		'		,REPLACE'	END
END	
ELSE
BEGIN
	IF @Flag_Partial = 'y' and @CSV_filegroups is not null and @CSV_filegroups <> ''
	BEGIN
		INSERT INTO	@Output([TextOutput])
		SELECT		'WITH	PARTIAL'		UNION ALL
		SELECT		'		,REPLACE'	END
	ELSE
	BEGIN
		INSERT INTO	@Output([TextOutput])
		SELECT		'WITH	REPLACE'	END
END

-- CALCULATE MOVE STATEMENTS
INSERT INTO	@Output([TextOutput])
SELECT		CASE @BkUpMethod
			WHEN 'LS' THEN '		,@with = ''MOVE "'+[LogicalName]+'" TO "'+COALESCE([Overide],[CT_Overide],[DeviceDefault],[DatabaseDefault],[ServerDefault])+'"'''
			ELSE '		,MOVE '''+[LogicalName]+''' TO '''+COALESCE([Overide],[CT_Overide],[DeviceDefault],[DatabaseDefault],[ServerDefault])+''''
			END
FROM		(
			SELECT		BUFiles.LogicalName																				[LogicalName]
						,RIGHT(PhysicalName,CHARINDEX('\',REVERSE(PhysicalName))-1)										[FileName]
						,REPLACE(PhysicalName,'\'+RIGHT(PhysicalName,CHARINDEX('\',REVERSE(PhysicalName))-1),'')		[FilePath]
						,RIGHT(PhysicalName,CHARINDEX('.',REVERSE(PhysicalName))-1)										[FileExtension]
						,DBFiles.filename																				[DeviceDefault]
						,DBPathByGroup.[FilePath]+'\'+RIGHT(PhysicalName,CHARINDEX('\',REVERSE(PhysicalName))-1)		[DatabaseDefault]
						,CASE RIGHT(PhysicalName,CHARINDEX('.',REVERSE(PhysicalName))-1)
							WHEN 'mdf'	THEN @Path_Default_MDF + '\' + RIGHT(PhysicalName,CHARINDEX('\',REVERSE(PhysicalName))-1)
							WHEN 'ndf'	THEN @Path_Default_NDF + '\' + RIGHT(PhysicalName,CHARINDEX('\',REVERSE(PhysicalName))-1)
							WHEN 'ldf'	THEN @Path_Default_LDF + '\' + RIGHT(PhysicalName,CHARINDEX('\',REVERSE(PhysicalName))-1)
							END																							[ServerDefault]
						,CT.[Path] + '\' + RIGHT(PhysicalName,CHARINDEX('\',REVERSE(PhysicalName))-1)					[CT_Overide]	
						,CASE RIGHT(PhysicalName,CHARINDEX('.',REVERSE(PhysicalName))-1)
							WHEN 'mdf'	THEN @Path_MDF + '\' + RIGHT(PhysicalName,CHARINDEX('\',REVERSE(PhysicalName))-1)
							WHEN 'ndf'	THEN @Path_NDF + '\' + RIGHT(PhysicalName,CHARINDEX('\',REVERSE(PhysicalName))-1)
							WHEN 'ldf'	THEN @Path_LDF + '\' + RIGHT(PhysicalName,CHARINDEX('\',REVERSE(PhysicalName))-1)
							END																							[Overide]
			FROM		@filelist BUFiles
			LEFT JOIN	sys.sysaltfiles DBFiles
				ON		DBFiles.dbid = DB_ID(@DBName)
				AND		DBFiles.name = BUFiles.LogicalName
			LEFT JOIN	(
						SELECT		dbid
									,groupid
									,MIN(REPLACE(filename,'\'+RIGHT(filename,CHARINDEX('\',REVERSE(filename))-1),'')) [FilePath]
						FROM		sys.sysaltfiles 
						GROUP BY	dbid,groupid
						HAVING		MAX(REPLACE(filename,'\'+RIGHT(filename,CHARINDEX('\',REVERSE(filename))-1),'')) = MIN(REPLACE(filename,'\'+RIGHT(filename,CHARINDEX('\',REVERSE(filename))-1),''))
						) DBPathByGroup		
				ON		DBPathByGroup.dbid		= DB_ID(@DBName)
				AND		DBPathByGroup.groupid	= BUFiles.FileGroupId
			LEFT JOIN	(
						SELECT	REPLACE([subject],'auto_restore_','') [FileType]
								,[control01] [DBName]
								,[control02] [ServerName]
								,[control03] [Path]
						FROM	[deplinfo].[dbo].[ControlTable]
						WHERE	[subject] like 'auto_restore_%'
							AND	[control02] = @@SERVERNAME
							AND	[control01] = @DBName
						)CT
				ON		CT.[FileType] = RIGHT(PhysicalName,CHARINDEX('.',REVERSE(PhysicalName))-1)
			)Data

-- POPULATE VARIABLE FROM CODE TABLE
SELECT		@DynamicCode = NULL
SELECT		@DynamicCode = COALESCE(@DynamicCode+@CRLF+TextOutput,TextOutput)
FROM		@Output
ORDER BY	rownum

-- ADJUST CODE BASED ON METHOD BEING USED
IF @BkUpMethod = 'MS' AND @Flag_CommentedScript = 'Y' AND @Flag_ScriptOnly = 'Y'
	SELECT	@DynamicCode	= '/*  Note:  Microsoft Syntax will be used for this restore */' + @CRLF + @CRLF + @DynamicCode

IF @BkUpMethod = 'RG'
BEGIN
	SELECT	@DynamicCode	= CASE	WHEN @Flag_CommentedScript = 'Y' AND @Flag_ScriptOnly = 'Y'
									THEN '/*  Note:  RedGate Syntax will be used for this restore */' + @CRLF + @CRLF
									ELSE '' END 
							+ 'Declare @cmd nvarchar(4000);' + @CRLF
							+ 'Select @cmd = ''-SQL "'+REPLACE(@DynamicCode,'''','''''')+'"'';' + @CRLF
							+ 'SET @cmd = REPLACE(REPLACE(REPLACE(@cmd,CHAR(9),'' ''),CHAR(13)+char(10),'' ''),''  '','' '');' + @CRLF
							+ 'Exec master.dbo.sqlbackup @cmd;' + @CRLF 
END
ELSE IF @BkUpMethod = 'LS'
BEGIN
	IF @Flag_CommentedScript = 'Y' AND @Flag_ScriptOnly = 'Y'
		SELECT	@DynamicCode	= '/*  Note:  LiteSpeed Syntax will be used for this restore */' + @CRLF + @CRLF + @DynamicCode
		
	SELECT	@DynamicCode	= REPLACE(REPLACE(@DynamicCode,'RESTORE DATABASE [','EXEC master.dbo.xp_backup_database @database = '''),']','''')
			,@DynamicCode	= REPLACE(@DynamicCode,'FROM DISK ='			,'		,@filename =')
			,@DynamicCode	= REPLACE(@DynamicCode,'WITH	NORECOVERY'		,'		,@with = ''NORECOVERY''')
			,@DynamicCode	= REPLACE(@DynamicCode,'WITH	PARTIAL'		,'		,@with = ''PARTIAL''')
			,@DynamicCode	= REPLACE(@DynamicCode,'WITH	REPLACE'		,'		,@with = ''REPLACE''')
			,@DynamicCode	= REPLACE(@DynamicCode,'		,NORECOVERY'	,'		,@with = ''NORECOVERY''')
			,@DynamicCode	= REPLACE(@DynamicCode,'		,REPLACE'		,'		,@with = ''REPLACE''')
END


-- ADD DROP STATEMENT IF FLAGED
IF @Flag_DropDB = 'Y'
BEGIN
	SELECT	@DynamicCode	= 'DECLARE @DynamicCode VarChar(8000), @RetryCount INT' + @CRLF + @CRLF
							+ 'StartDrop:' + @CRLF + @CRLF
							+ '	IF DB_ID(''' + @DBName + ''') IS NOT NULL'  + @CRLF 
							+ '		DROP DATABASE [' + @DBName + ']' + @CRLF + @CRLF
							+ '	WAITFOR DELAY ''00:00:50''' + @CRLF + @CRLF
							+ '	IF DB_ID('''++''') IS NOT NULL' + @CRLF
							+ '	BEGIN' + @CRLF
							+ '		SET @RetryCount = isnull(RetryCount,0) + 1' + @CRLF
							+ '		IF  @RetryCount < 6 GOTO StartDrop' + @CRLF
							+ '		RAISERROR(''DBA ERROR: Database Can Not Be Dropped, 5 Retrys Attempted.'',16,-1)' + @CRLF
							+ '		GOTO EndRestore' + @CRLF
							+ '	END'+ @CRLF + @CRLF
							+ @DynamicCode + @CRLF
END



-- BUILD HEADDER
DELETE @Output
INSERT INTO	@Output([TextOutput])
			  SELECT 'USE [MASTER]' 
	UNION ALL SELECT ''

IF @Flag_CommentedScript = 'Y' AND @Flag_ScriptOnly = 'Y'
	INSERT INTO	@Output([TextOutput])
	          SELECT '-----------------------------------------------------------------------------'
	UNION ALL SELECT '-----------------------------------------------------------------------------'
	UNION ALL SELECT '--                    DATABASE AUTO RESTORE SCRIPT'
	UNION ALL SELECT '-----------------------------------------------------------------------------'
	UNION ALL SELECT '--                       ' + CAST(GetDate() AS VarChar(50))
	UNION ALL SELECT '-----------------------------------------------------------------------------'
	UNION ALL SELECT '--	@DBName               : ' + isnull(@DBName,'NULL')	
	UNION ALL SELECT '--	@File_Backup          : ' + isnull(@File_Backup,'NULL')
	UNION ALL SELECT '--	@Path_Backup          : ' + isnull(@Path_Backup,'NULL')
	UNION ALL SELECT '--	@Path_MDF             : ' + isnull(@Path_MDF,'NULL')	
	UNION ALL SELECT '--	@Path_NDF             : ' + isnull(@Path_NDF,'NULL')	
	UNION ALL SELECT '--	@Path_LDF             : ' + isnull(@Path_LDF,'NULL')	
	UNION ALL SELECT '--	@CSV_filegroups       : ' + isnull(@CSV_filegroups,'NULL')	
	UNION ALL SELECT '--	@CSV_files            : ' + isnull(@CSV_files,'NULL')	
	UNION ALL SELECT '--	@Flag_Partial	      : ' + isnull(@Flag_Partial,'N') + '              @Flag_ForceNewLDF     : ' + isnull(@Flag_ForceNewLDF,'N')	
	UNION ALL SELECT '--	@Flag_Differential    : ' + isnull(@Flag_Differential,'N') + '              @Flag_DropDB          : ' + isnull(@Flag_DropDB,'N')	
	UNION ALL SELECT '--	@Flag_NoRecovery      : ' + isnull(@Flag_NoRecovery,'N') + '              @Flag_DiffOnly        : ' + isnull(@Flag_DiffOnly,'N')	
	UNION ALL SELECT '--	@Flag_ScriptOnly      : ' + isnull(@Flag_ScriptOnly,'N') + '              @Flag_PostShrink      : ' + isnull(@Flag_PostShrink,'N')	
	UNION ALL SELECT '--	@Flag_IgnoreCtlTbl    : ' + isnull(@Flag_IgnoreCtlTbl,'N') + '              @Flag_DifOnlyFailComp : ' + isnull(@Flag_DifOnlyFailComp,'N')	
	UNION ALL SELECT '--	@Flag_SourcePath      : ' + isnull(@Flag_SourcePath,'N') + '              @Flag_DateStampFiles  : ' + isnull(@Flag_DateStampFiles,'N')
	UNION ALL SELECT '--	@Flag_CommentedScript : ' + isnull(@Flag_SourcePath,'N') + '              @Flag_DateStampFiles  : ' + isnull(@Flag_DateStampFiles,'N')	
	UNION ALL SELECT '-----------------------------------------------------------------------------'
	UNION ALL SELECT '-----------------------------------------------------------------------------'
	UNION ALL SELECT ''

-- POPULATE VARIABLE FROM CODE TABLE
SELECT		@DynamicCode2 = NULL
SELECT		@DynamicCode2 = COALESCE(@DynamicCode2+@CRLF+TextOutput,TextOutput)
FROM		@Output
ORDER BY	rownum

SELECT		@DynamicCode = @DynamicCode2 + @DynamicCode


IF @Flag_NoRecovery = 'Y'
	SELECT	@DynamicCode	= @DynamicCode
							+ '-- DATABASE STILL "RESTORING" AND IS NOT YET USABLE.' + @CRLF
							+ '-- USE THE FOLLOWING TO COMPLETE: RESTORE DATABASE ['+@DBName+'] WITH RECOVERY' + @CRLF
							
SELECT	@DynamicCode	= @DynamicCode + @CRLF
						+ 'EndRestore:' + @CRLF

-- DISPLAY OR EXECUTE FINAL STATEMENT
IF @Flag_ScriptOnly = 'Y'
	PRINT	(@DynamicCode)
ELSE
BEGIN
	-- USE CP_CMDSHELL IN ORDER TO CONTROL THE OUTPUT
	PRINT	'		-- STARTING DATABASE RESTORE ' + CAST(Getdate() as VarChar)
	SELECT	@DynamicCode	= 'SET NOCOUNT ON;'+REPLACE(REPLACE(REPLACE(REPLACE(@DynamicCode,CHAR(9),' '),@CRLF,' '),'  ',' '),'"','""')
			,@DynamicCode	= 'sqlcmd -S"' + @@ServerName + '" -E -Q"'+@DynamicCode+'" -w65535 -h-1'
	INSERT INTO #ExecOutput([TextOutput])
	EXEC	XP_CMDSHELL  @DynamicCode
	PRINT	'		-- FINISHED DATABASE RESTORE ' + CAST(Getdate() as VarChar)
	SELECT	@DynamicCode = ''
	SELECT	@DynamicCode = @DynamicCode + '			-- ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([TextOutput],CHAR(9),' '),'     ',' '),'    ',' '),'   ',' '),'  ',' ') + @CRLF
	FROM	#ExecOutput 
	WHERE	nullif([TextOutput],'') IS NOT NULL
	PRINT	@DynamicCode
	
	IF @Flag_NoRecovery = 'Y'
	BEGIN
		PRINT	''
		PRINT	'			-- DATABASE STILL "RESTORING" AND IS NOT YET USABLE.'
		PRINT	'				-- USE THE FOLLOWING TO COMPLETE: RESTORE DATABASE ['+@DBName+'] WITH RECOVERY'
	END	
END
TheEnd:

GO



