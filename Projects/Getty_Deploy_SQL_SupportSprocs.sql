USE MASTER
GO
SET NOCOUNT ON
GO
IF OBJECT_ID('dbasp_FileAccess_Write') IS NOT NULL
	DROP PROCEDURE [dbo].[dbasp_FileAccess_Write]
GO
CREATE PROCEDURE [dbo].[dbasp_FileAccess_Write]
		(
		@String			Varchar(max)			--8000 in SQL Server 2000
		,@Path			VARCHAR(4000)
		,@Filename		VARCHAR(1024)	= NULL	-- CAN BE NULL IF PASSING THE FILENAME AS PART OF THE PATH
		,@Append		bit				= 0		-- DEFAULT IS TO OVERWRITE
		)
	as
	SET NOCOUNT ON

	DECLARE		@objFileSystem		int
				,@objTextStream		int
				,@objErrorObject	int
				,@strErrorMessage	Varchar(1024)
				,@Command			varchar(1024)
				,@hr				int
				,@fileAndPath		varchar(1024)
				,@Method			INT
		
	SET			@Method = CASE @Append WHEN 0 THEN 2 ELSE 8 END

	select @strErrorMessage='opening the File System Object'
	EXECUTE @hr = sp_OACreate  'Scripting.FileSystemObject' , @objFileSystem OUT

	Select @FileAndPath=@path+COALESCE(CASE WHEN RIGHT(@Path,1) = '\' THEN '' ELSE '\' END+@filename,'')
	if @HR=0 Select @objErrorObject=@objFileSystem , @strErrorMessage=CASE @Append WHEN 0 THEN 'Creating file "' ELSE 'Appending file "' END +@FileAndPath+'"'
	if @HR=0 execute @hr = sp_OAMethod   @objFileSystem,'OpenTextFile',@objTextStream OUT,@FileAndPath,@Method,True

	if @HR=0 Select @objErrorObject=@objTextStream, 
		@strErrorMessage='writing to the file "'+@FileAndPath+'"'
	if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Write', Null, @String

	if @HR=0 Select @objErrorObject=@objTextStream, @strErrorMessage='closing the file "'+@FileAndPath+'"'
	if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Close'

	if @hr<>0
		begin
		Declare 
			@Source varchar(1024),
			@Description Varchar(1024),
			@Helpfile Varchar(1024),
			@HelpID int
		
		EXECUTE sp_OAGetErrorInfo  @objErrorObject, 
			@source output,@Description output,@Helpfile output,@HelpID output
		Select @strErrorMessage='Error whilst '
				+coalesce(@strErrorMessage,'doing something')
				+', '+coalesce(@Description,'')
		raiserror (@strErrorMessage,16,1)
		end
	EXECUTE  sp_OADestroy @objTextStream
	EXECUTE sp_OADestroy @objTextStream
GO	


GO	
	IF OBJECT_ID('dbaudf_CPUInfo') IS NOT NULL
	DROP FUNCTION [dbo].[dbaudf_CPUInfo]
GO
	CREATE FUNCTION [dbo].[dbaudf_CPUInfo](@Attribute sysname)
	RETURNS INT
	AS
	BEGIN
		DECLARE		@WmiServiceLocator			int
					,@WmiService				int
					,@CounterCollection			int
					,@CounterObject				int
					,@Freespace					float
					,@Value						INT
					,@NumberOfCores				INT
					,@NumberOfLogicalProcessors	INT
					,@Count						int
					,@CPULoop					INT
					,@Property					nVarChar(200)
					,@Value2					sysname
		DECLARE		@SocketList					TABLE (SocketDesignation sysname)
					
		SELECT		@CPULoop					= 0
					,@NumberOfCores				= 0
					,@NumberOfLogicalProcessors	= 0
					 
		exec sp_OACreate 'WbemScripting.SWbemLocator', @WmiServiceLocator output; 
		exec sp_OAMethod @WmiServiceLocator, 'ConnectServer', @WmiService output, '.', 'root\cimv2'; 
		exec sp_OAMethod @WmiService, 'execQuery', @CounterCollection output, 'Select * from Win32_Processor';
		 
		exec sp_OAGetProperty @CounterCollection,'Count', @Count OUT

		WHILE @CPULoop < @Count
		BEGIN
			SET		@Property = 'Win32_Processor.DeviceID=''CPU'+CAST(@CPULoop AS VarChar)+''''
			exec sp_OAMethod @CounterCollection, 'Item', @CounterObject output, @Property;

			SET		@Value = 0
			exec	sp_OAGetProperty @CounterObject, 'NumberOfCores', @Value output;
			SET		@NumberOfCores = @NumberOfCores + @Value
			
			SET		@Value = 0
			exec	sp_OAGetProperty @CounterObject, 'NumberOfLogicalProcessors', @Value output; 
			SET		@NumberOfLogicalProcessors = @NumberOfLogicalProcessors + @Value
		
			SET		@Value2 = ''
			exec	sp_OAGetProperty @CounterObject, 'SocketDesignation', @Value2 output;
			 
			IF @Value2 NOT IN (SELECT SocketDesignation FROM @SocketList)
					INSERT INTO @SocketList(SocketDesignation) VALUES(@Value2)

			SET		@CPULoop = @CPULoop + 1

		END
		
		IF @Count > 0 AND @NumberOfLogicalProcessors = 0
			SELECT	@NumberOfLogicalProcessors	= @Count
					,@Count						= COUNT(*)
					,@NumberOfCores				= @NumberOfLogicalProcessors / @Count
			FROM	@SocketList		 
		
		IF @Attribute = 'Sockets'
			SET @Value = @Count
		ELSE IF @Attribute = 'Cores'
			SET @Value = @NumberOfCores
		ELSE
			SET @Value = @NumberOfLogicalProcessors

		RETURN @Value
	END
GO



GO	
	IF OBJECT_ID('dbaudf_Dir') IS NOT NULL
	DROP FUNCTION [dbo].[dbaudf_Dir]
GO
	CREATE FUNCTION [dbo].[dbaudf_Dir](@Wildcard VARCHAR(8000))
	RETURNS @MyDir TABLE 
	(
		   [name] VARCHAR(2000),    --the name of the filesystem object
		   [path] VARCHAR(2000),    --Contains the item's full path and name. 
		   [ModifyDate] DATETIME,   --the time it was last modified 
		   [IsFileSystem] INT,      --1 if it is part of the file system
		   [IsFolder] INT,          --1 if it is a folsdder otherwise 0
		   [error] VARCHAR(2000)    --if an error occured, gives the error otherwise null
	)
	AS
	BEGIN
	   DECLARE 
		   @objShellApplication INT, 
		   @objFolder INT,
		   @objItem INT,
		   @objErrorObject INT,
		   @objFolderItems INT, 
		   @strErrorMessage VARCHAR(1000), 
		   @Command VARCHAR(1000), 
		   @hr INT, --OLE result (0 if OK)
		   @count INT,@ii INT,
		   @name VARCHAR(2000),--the name of the current item
		   @path VARCHAR(2000),--the path of the current item 
		   @ModifyDate DATETIME,--the date the current item last modified
		   @IsFileSystem INT, --1 if the current item is part of the file system
		   @IsFolder INT --1 if the current item is a file
	   IF LEN(COALESCE(@Wildcard,''))<2 
		   RETURN

	   SELECT  @strErrorMessage = 'opening the Shell Application Object' 
	   EXECUTE @hr = sp_OACreate 'Shell.Application', 
		   @objShellApplication OUT 
	   IF @HR = 0  
		   SELECT  @objErrorObject = @objShellApplication, 
				   @strErrorMessage = 'Getting Folder"' + @wildcard + '"', 
				   @command = 'NameSpace("'+@wildcard+'")' 
	   IF @HR = 0  
		   EXECUTE @hr = sp_OAMethod @objShellApplication, @command, 
			   @objFolder OUT
	   IF @objFolder IS NULL RETURN --nothing there. Sod the error message
	   --and then the number of objects in the folder
		   SELECT  @objErrorObject = @objFolder, 
				   @strErrorMessage = 'Getting count of Folder items in "' + @wildcard + '"', 
				   @command = 'Items.Count' 
	   IF @HR = 0  
		   EXECUTE @hr = sp_OAMethod @objfolder, @command, 
			   @count OUT
		IF @HR = 0 --now get the FolderItems collection 
			SELECT  @objErrorObject = @objFolder, 
					@strErrorMessage = ' getting folderitems',
				   @command='items()'
		IF @HR = 0  
			EXECUTE @hr = sp_OAMethod @objFolder, 
				@command, @objFolderItems OUTPUT 
	   SELECT @ii = 0
	   WHILE @hr = 0 AND @ii< @count --iterate through the FolderItems collection
				BEGIN 
					IF @HR = 0  
						SELECT  @objErrorObject = @objFolderItems, 
								@strErrorMessage = ' getting folder item ' 
									   + CAST(@ii AS VARCHAR(5)),
							   @command='item(' + CAST(@ii AS VARCHAR(5))+')'
							   --@Command='GetDetailsOf('+ cast(@ii as varchar(5))+',1)'
					IF @HR = 0  
						EXECUTE @hr = sp_OAMethod @objFolderItems, 
							@command, @objItem OUTPUT 

					IF @HR = 0  
						SELECT  @objErrorObject = @objItem, 
								@strErrorMessage = ' getting folder item properties'
									   + CAST(@ii AS VARCHAR(5))
					IF @HR = 0  
						EXECUTE @hr = sp_OAMethod @objItem, 
							'path', @path OUTPUT
					IF @HR = 0  
						EXECUTE @hr = sp_OAMethod @objItem, 
							'name', @name OUTPUT
					IF @HR = 0  
						EXECUTE @hr = sp_OAMethod @objItem, 
							'ModifyDate', @ModifyDate OUTPUT
					IF @HR = 0  
						EXECUTE @hr = sp_OAMethod @objItem, 
							'IsFileSystem', @IsFileSystem OUTPUT
					IF @HR = 0  
						EXECUTE @hr = sp_OAMethod @objItem, 
							'IsFolder', @IsFolder OUTPUT
				   INSERT INTO @MyDir ([NAME], [path], ModifyDate, IsFileSystem, IsFolder)
					   SELECT @NAME, @path, @ModifyDate, @IsFileSystem, @IsFolder
				   IF @HR = 0  EXECUTE sp_OADestroy @objItem 
				   SELECT @ii=@ii+1
				END 
			IF @hr <> 0  
				BEGIN 
					DECLARE @Source VARCHAR(255), 
						@Description VARCHAR(255), 
						@Helpfile VARCHAR(255), 
						@HelpID INT 
	     
					EXECUTE sp_OAGetErrorInfo @objErrorObject, @source OUTPUT, 
						@Description OUTPUT, @Helpfile OUTPUT, @HelpID OUTPUT 
					SELECT  @strErrorMessage = 'Error whilst ' 
							+ COALESCE(@strErrorMessage, 'doing something') + ', ' 
							+ COALESCE(@Description, '') 
					INSERT INTO @MyDir(error) SELECT  LEFT(@strErrorMessage,2000) 
				END 
			EXECUTE sp_OADestroy @objFolder 
			EXECUTE sp_OADestroy @objShellApplication

	RETURN
	END
GO

	
	
GO	
	IF OBJECT_ID('dbasp_sp_configure') IS NOT NULL
	DROP PROCEDURE [dbo].[dbasp_sp_configure]
GO
	CREATE Procedure dbasp_sp_configure (@configname VarChar(35),@configvalue Int)
	AS
	BEGIN
		DECLARE	@DynamicText	VarChar(8000)
		SET		@DynamicText	= 'EXEC sp_configure '''+@configname+''', ' + CAST(@configvalue as VarChar)

		SET		@DynamicText	= 'sqlcmd -S' + @@ServerName + ' -E -Q"' + @DynamicText + '"'
		EXEC master.sys.xp_cmdshell @DynamicText, no_output 
	END
GO

	
GO	
	IF OBJECT_ID('dbasp_LogSQLStartup') IS NOT NULL
	DROP PROCEDURE [dbo].[dbasp_LogSQLStartup]
GO
	CREATE PROCEDURE dbasp_LogSQLStartup
	AS
		DECLARE @OutPutText VarChar(8000)
		SET		@OutPutText = 'STARTING SQL ' + CAST(GetDate() AS VarChar(50))
		IF OBJECT_ID('master.dbo.ServerDeploymentStatus') IS NOT NULL
		BEGIN
			INSERT INTO master.dbo.ServerDeploymentStatus(TextOutput) Values(@OutPutText) 
		END
GO		


GO	
	EXEC sp_procoption
		@ProcName		= 'master.dbo.dbasp_LogSQLStartup'
		,@OptionName	= 'STARTUP' 
		,@OptionValue	= 'on'
GO		


GO
IF OBJECT_ID('dbasp_RestoreDatabase') IS NOT NULL
	DROP PROCEDURE dbasp_RestoreDatabase
GO
CREATE PROCEDURE dbasp_RestoreDatabase
	--------------------------------------------------------------------------------------			
	--------------------------------------------------------------------------------------			
	--									DEFINE PARAMETERS
	--------------------------------------------------------------------------------------			
	--------------------------------------------------------------------------------------			
		(
		@DBName					SYSNAME			
		,@File_Backup			VarChar(2048)
		,@Path_Backup			VarChar(2048)	= NULL

		,@AltDBName				SYSNAME			= NULL
		,@Path_MDF				VarChar(2048)	= NULL
		,@Path_NDF				VarChar(2048)	= NULL
		,@Path_LDF				VarChar(2048)	= NULL
		,@Mask_BackMid			SYSNAME			= '_db_2'
		,@Mask_DiffMid			SYSNAME			= '_dfntl_2'			
												
		,@Flag_Partial			CHAR(1)			= 'N'
		,@Flag_Differential		CHAR(1)			= 'N'
		,@Flag_NoRecovery		CHAR(1)			= 'N'
		,@Flag_ScriptOnly		CHAR(1)			= 'Y'
		,@Flag_IgnoreCtlTbl		CHAR(1)			= 'N'
		,@Flag_SourcePath		CHAR(1)			= 'N'
		,@Flag_ForceNewLDF		CHAR(1)			= 'N'
		,@Flag_DropDB			CHAR(1)			= 'N'
		,@Flag_DiffOnly			CHAR(1)			= 'N'
		,@Flag_PostShrink		CHAR(1)			= 'N'
		,@Flag_DifOnlyFailComp	CHAR(1)			= 'N'
		,@Flag_DateStampFiles	CHAR(1)			= 'N'
												
		,@CSV_filegroups		VarChar(2048)	= NULL
		,@CSV_files				VarChar(2048)	= NULL
		,@ScriptOutput			VarChar(max)	= null OUTPUT
		)
	--------------------------------------------------------------------------------------			
	--------------------------------------------------------------------------------------			
	--									START OF CODE
	--------------------------------------------------------------------------------------			
	--------------------------------------------------------------------------------------			
AS
DECLARE		@ShareName				sysname
			,@Path_Default_MDF		VarChar(2048)
			,@Path_Default_NDF		VarChar(2048)
			,@Path_Default_LDF		VarChar(2048)
			,@BkUpMethod			VarChar(50)
			,@DynamicCode			VarChar(8000)
			,@CRLF					VarChar(10)
			,@DateTime_Both			DateTime
			,@DateTime_Date			VarChar(8)
			,@DateTime_Time			VarChar(4) --HHMM

IF (OBJECT_ID('tempdb..#ExecOutput'))	IS NOT NULL	DROP TABLE #ExecOutput
CREATE TABLE	#ExecOutput			([rownum] int identity primary key,[TextOutput] VARCHAR(8000));

-- STRIP PATH OUT OF FILENAME IF EXISTS
IF nullif(@Path_Backup,'') IS NULL AND CHARINDEX('\',@File_Backup) > 0
BEGIN
	 SELECT		@Path_Backup	= REVERSE(STUFF(REVERSE(@File_Backup),1,CHARINDEX('\',REVERSE(@File_Backup))-1,''))
				,@File_Backup	= REPLACE(@File_Backup,@Path_Backup,'')
END

-- GET DEFAULT BACKUP SHARE IF PATH NOT SET
IF nullif(@Path_Backup,'') IS NULL
BEGIN			
	SELECT @ShareName = REPLACE(@@SERVERNAME,'\','$') + '_Backup'
	exec dbaadmin.dbo.dbasp_get_share_path @ShareName,@Path_Backup OUT
END


SELECT		@CRLF					= CHAR(13)+CHAR(10)
									-- CLEAN OFF TRAILING SLASHES
			,@Path_Backup			= REPLACE(REPLACE(@Path_Backup+'|','\|',''),'|','')
			,@Path_MDF				= REPLACE(REPLACE(@Path_MDF+'|','\|',''),'|','')
			,@Path_NDF				= REPLACE(REPLACE(@Path_NDF+'|','\|',''),'|','')
			,@Path_LDF				= REPLACE(REPLACE(@Path_LDF+'|','\|',''),'|','')


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

IF @Flag_DateStampFiles = 'Y'
	SELECT		@DateTime_Both	= GetDate()
				,@DateTime_Time	= convert(varchar(8), @DateTime_Both, 8)
				,@DateTime_Date	= '_' + convert(char(8), @DateTime_Both, 112) 
					+ substring(@DateTime_Time, 1, 2) 
					+ substring(@DateTime_Time, 4, 2) 
					+ substring(@DateTime_Time, 7, 2) 

-- USE @FILE_BACKUP AS MASK TO IDENTIFY MOST RECENT SPECIFIC FILE
SELECT		TOP 1 @File_Backup = Name+'.'+Ext
FROM		(
			SELECT		name
						,REPLACE(REPLACE(REPLACE(Path,@Path_Backup+'\',''),Name+'.',''),Name,'') ext
						,path
						,CAST(ModifyDate AS DateTime) ModifyDate
						,IsFileSystem	
						,IsFolder	
						,error
			FROM		dbaadmin.dbo.dbaudf_Dir(@Path_Backup)
			WHERE		IsFolder		= 0
				AND		IsFileSystem	= 1
				AND		Error			IS NULL
			)Dir
WHERE		Name+'.'+Ext Like '%' + @File_Backup + '%'
ORDER BY	ModifyDate Desc

-- IDENTIFY BACKUP METHOD
SELECT	@BkUpMethod = CASE
	WHEN @File_Backup like '%.BKP%' THEN 'LS'
	WHEN @File_Backup like '%.SQB%' THEN 'RG'
	ELSE 'MS' END

-- CHECK IF APP IS INSTALLED FOR CURRENT BACKUP METHOD	
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

-- READ FILELIST FROM BACKUP FILE
IF @BkUpMethod = 'MS' and SERVERPROPERTY ('productversion') >= '10.00.0000'
BEGIN
	SET @DynamicCode = 'RESTORE FILELISTONLY FROM DISK = '''+@Path_Backup+'\'+@File_Backup+''''
	insert into @filelist
	EXEC (@DynamicCode)
END
ELSE IF @BkUpMethod = 'MS' and SERVERPROPERTY ('productversion') < '10.00.0000'
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

-- START BUILDING SCRIPT
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
			WHEN 'LS' THEN '		,@with = ''MOVE "'+[LogicalName]+'" TO "'+COALESCE([Overide],[DeviceDefault],[DatabaseDefault],[ServerDefault])+'"'''
			ELSE '		,MOVE '''+[LogicalName]+''' TO '''+COALESCE([Overide],[DeviceDefault],[DatabaseDefault],[ServerDefault])+''''
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
			)Data

-- POPULATE VARIABLE FROM CODE TABLE
SELECT		@DynamicCode = NULL
SELECT		@DynamicCode = COALESCE(@DynamicCode+@CRLF+TextOutput,TextOutput)
FROM		@Output
ORDER BY	rownum

-- ADJUST CODE BASED ON METHOD BEING USED
IF @BkUpMethod = 'MS'
	SELECT	@DynamicCode	= '/*  Note:  Microsoft Syntax will be used for this restore */' + @CRLF + @CRLF + @DynamicCode + @CRLF

IF @BkUpMethod = 'RG'
BEGIN
	IF		@ScriptOutput IS NOT NULL
	BEGIN
		IF	@ScriptOutput = ''
			SELECT	@DynamicCode	= '/*  Note:  RedGate Syntax will be used for this restore */' + @CRLF + @CRLF
									+ 'Declare @cmd nvarchar(4000);' + @CRLF
									+ 'Select @cmd = ''-SQL "'+REPLACE(@DynamicCode,'''','''''')+'"'';' + @CRLF
									+ 'SET @cmd = REPLACE(REPLACE(REPLACE(@cmd,CHAR(9),'' ''),CHAR(13)+char(10),'' ''),''  '','' '');' + @CRLF
									+ 'Exec master.dbo.sqlbackup @cmd;' + @CRLF 
		ELSE	
			SELECT	@DynamicCode	= '/*  Note:  RedGate Syntax will be used for this restore */' + @CRLF + @CRLF
									+ 'Select @cmd = ''-SQL "'+REPLACE(@DynamicCode,'''','''''')+'"'';' + @CRLF
									+ 'SET @cmd = REPLACE(REPLACE(REPLACE(@cmd,CHAR(9),'' ''),CHAR(13)+char(10),'' ''),''  '','' '');' + @CRLF
									+ 'Exec master.dbo.sqlbackup @cmd;' + @CRLF 
	END
	ELSE
	SELECT	@DynamicCode	= '/*  Note:  RedGate Syntax will be used for this restore */' + @CRLF + @CRLF
							+ 'Declare @cmd nvarchar(4000);' + @CRLF
							+ 'Select @cmd = ''-SQL "'+REPLACE(@DynamicCode,'''','''''')+'"'';' + @CRLF
							+ 'SET @cmd = REPLACE(REPLACE(REPLACE(@cmd,CHAR(9),'' ''),CHAR(13)+char(10),'' ''),''  '','' '');' + @CRLF
							+ 'Exec master.dbo.sqlbackup @cmd;' + @CRLF 
END
ELSE IF @BkUpMethod = 'LS'
BEGIN
	SELECT	@DynamicCode	= '/*  Note:  LiteSpeed Syntax will be used for this restore */' + @CRLF + @CRLF + @DynamicCode + @CRLF
			,@DynamicCode	= REPLACE(REPLACE(@DynamicCode,'RESTORE DATABASE [','EXEC master.dbo.xp_backup_database @database = '''),']','''')
			,@DynamicCode	= REPLACE(@DynamicCode,'FROM DISK ='			,'		,@filename =')
			,@DynamicCode	= REPLACE(@DynamicCode,'WITH	NORECOVERY'		,'		,@with = ''NORECOVERY''')
			,@DynamicCode	= REPLACE(@DynamicCode,'WITH	PARTIAL'		,'		,@with = ''PARTIAL''')
			,@DynamicCode	= REPLACE(@DynamicCode,'WITH	REPLACE'		,'		,@with = ''REPLACE''')
			,@DynamicCode	= REPLACE(@DynamicCode,'		,NORECOVERY'	,'		,@with = ''NORECOVERY''')
			,@DynamicCode	= REPLACE(@DynamicCode,'		,REPLACE'		,'		,@with = ''REPLACE''')
END


-- DISPLAY OR EXECUTE FINAL STATEMENT
IF @Flag_ScriptOnly = 'Y'
BEGIN
	IF		@ScriptOutput IS NULL
		PRINT	(@DynamicCode)

	SET @ScriptOutput = @ScriptOutput + CHAR(13)+CHAR(10)+@DynamicCode
END
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



GO
IF OBJECT_ID('dbasp_CloneDBs') IS NOT NULL
	DROP PROCEDURE	dbasp_CloneDBs
GO
CREATE PROCEDURE	dbasp_CloneDBs
	(
	@ServerToClone		sysname
	,@DeployableDBS		bit			= 0
	,@NonDeployableDBs	bit			= 1
	,@OpsDBs			bit			= 1
	,@systemDBs			bit			= 0
	)
AS
	DECLARE		@DynamicCode		VARCHAR(8000)
				,@DBName			SYSNAME
				,@machinename		VarChar(8000)
				,@instancename		VarChar(8000)
				,@ServerName		varchar(8000)
				,@ServiceExt		varchar(8000)
				,@Msg				VarChar(max)
				,@DefaultBackupDir	VarChar(8000)
				,@ScriptOutput		VarChar(max)
				,@statement			nVarChar(4000)
				,@Params			nVarChar(4000)
				,@BackupFile		VarChar(8000)
			
	SELECT		@instancename		= isnull('\'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
				,@ServerName		= REPLACE(@@SERVERNAME,@instancename,'')
				,@machinename		= convert(nvarchar(100), serverproperty('machinename')) + @instancename
				,@ServiceExt		= isnull('$'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
				
	IF (OBJECT_ID('tempdb..#ExecOutput_CloneDBs'))	IS NOT NULL	DROP TABLE #ExecOutput_CloneDBs
	CREATE	TABLE	#ExecOutput_CloneDBs ([rownum] int identity primary key,[TextOutput] VARCHAR(8000));

	DECLARE CloneDBCusrsor CURSOR
	FOR
	SELECT		name
	FROM		Master..sysdatabases
	WHERE		name NOT LIKE 'ASPState%'
		and		name NOT IN ('tempdb', 'pubs', 'Northwind')
		and		(name NOT IN ('master', 'msdb', 'model')						OR @systemDBs			= 1)
		and		(name NOT IN ('dbaadmin', 'dbaperf', 'deplinfo','deplcontrol'
								,'gears','dbacentral','dbaperf_reports'
								,'operations','RunBook','RunBook05','MetricsOps'
								,'DeployMaster')								OR @OpsDBs				= 1)
		and		(name NOT IN (select db_name From dbaadmin.dbo.db_sequence)		OR @DeployableDBS		= 1)
		and		(name NOT IN (	SELECT name from master..sysdatabases 
								where name not in (select db_name From dbaadmin.dbo.db_sequence)
								AND name NOT LIKE 'ASPState%' 
								and name NOT IN ('tempdb', 'pubs', 'Northwind') 
								and name NOT IN ('master', 'msdb', 'model') 
								AND name NOT IN ('dbaadmin', 'dbaperf', 'deplinfo','deplcontrol','gears','dbacentral','dbaperf_reports','operations','RunBook','RunBook05','MetricsOps','DeployMaster')
								)												OR	@NonDeployableDBS	= 1) 	

	OPEN CloneDBCusrsor
	FETCH NEXT FROM CloneDBCusrsor INTO @DBName
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			TRUNCATE TABLE #ExecOutput_CloneDBs
			
			SELECT	@Msg			= 'Backing up Database: ' + @DBName
					,@DynamicCode	= 'EXEC dbaadmin.dbo.dbasp_BackupDBs @DBName='''+@DBName+''',@target_path=''\\'+REPLACE(@@SERVERNAME,'\'+@@SERVICENAME,'')
									+ '\'+REPLACE(@@SERVERNAME,'\','$')+'_backup'',@backup_name='''+@DBName+''',@DeletePrevious = ''Before'''+';'
					,@DynamicCode	= 'sqlcmd -S' + @ServerToClone + ' -E -Q"'+@DynamicCode+'"'

			RAISERROR (@Msg,-1,-1) WITH NOWAIT
			INSERT #ExecOutput_CloneDBs(TextOutput) EXEC master.sys.xp_cmdshell @DynamicCode
			RAISERROR ('	Done...',-1,-1) WITH NOWAIT
			
			SELECT		@BackupFile = REPLACE(TextOutput,'Output file will be: ','')
			FROM		#ExecOutput_CloneDBs 
			WHERE		TextOutput like 'Output file will be:%'

			SELECT		@Msg			= 'Restoring Database: ' + @DBName
			RAISERROR	(@Msg,-1,-1) WITH NOWAIT
			EXEC		master.dbo.dbasp_RestoreDatabase @DBName=@DBName,@File_Backup=@BackupFile,@Flag_NoRecovery='Y',@Flag_ScriptOnly = 'N'
			RAISERROR ('	Done...',-1,-1) WITH NOWAIT
			
			SELECT	@Msg			= 'Recovering Database: ' + @DBName
					,@DynamicCode	= 'RESTORE DATABASE ['+@DBName+'] WITH RECOVERY;'

			RAISERROR (@Msg,-1,-1) WITH NOWAIT
			EXEC (@DynamicCode)
			RAISERROR ('	Done...',-1,-1) WITH NOWAIT
			PRINT ''
		END
		FETCH NEXT FROM CloneDBCusrsor INTO @DBName
	END

	CLOSE CloneDBCusrsor
	DEALLOCATE CloneDBCusrsor
GO

