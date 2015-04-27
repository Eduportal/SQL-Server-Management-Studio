USE [master]
SET NOCOUNT ON

SELECT @@SERVERNAME

DECLARE @TcpPort			VARCHAR(5) 
        ,@RegKey			VARCHAR(100)
		,@ServerName		SYSNAME
		,@ServerName_NEW	SYSNAME
		,@OldPort			VarChar(5)
		,@OldServerName		SYSNAME
		,@machinename		sysname
		,@instancename		sysname
		,@InstanceNumber	VarChar(50)
		,@DefaultDataDir	VarChar(8000)
		,@DefaultLogDir		VarChar(8000)
		,@DefaultBackupDir	VarChar(8000)
		,@DynamicCode		VarChar(8000)
		,@Edition			VARCHAR(255)
		,@AWEDefault		INT
		,@Platform			VARCHAR(255)
		,@PhysicalMemory 	INT
		,@MaxMemory			INT
		,@CPUCores			INT
		,@TempDBFiles		INT
		,@LoginMode			INT
		,@DBName			SysName
		,@ServiceActLogin	sysname
		,@ServiceActPass	sysname
		,@ServiceExt		varchar(10)
		,@RunSection		INT
		,@cmd				nvarchar(500)
		,@central_server	sysname
		,@ScriptPath		VarChar(8000)
		,@ServerToClone		sysname

CREATE	TABLE		#XP_MSVER_RESULTS		([Index] int, [Name] varchar(255), [Internal_Value] varchar(255), [Character_Value] varchar(255))
INSERT	INTO		#XP_MSVER_RESULTS		EXEC master..xp_msver

SELECT	@RunSection			= 3
		--,@TcpPort			= '1996'				-- FORCE SPECIFIC PORT
		--,@ServerToClone	= 'FREBSHWSQL01\A'		-- FORCE SPECIFIC NEW NAME
		--,@ServerName_NEW	= 'FREBSHWSQL01\A'		-- FORCE SPECIFIC NEW NAME
		,@MaxMemory			= 2000					-- FORCE SPECIFIC MAX MEMORY
		,@central_server	= 'SEAFRESQLDBA01'
		,@ServiceActLogin	= 'amer\SQLAdminBeta'
		,@ServiceActPass	= '#r3&=azuB'

		,@DefaultDataDir	= 'E:\MSSQL$INSTANCENAME$\Data'
		,@DefaultLogDir		= 'F:\MSSQL$INSTANCENAME$\Log'
		,@DefaultBackupDir	= 'G:\MSSQL$INSTANCENAME$\Backup'

		,@instancename		= isnull('\'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
		,@ServerName		= REPLACE(@@SERVERNAME,@instancename,'')
		,@machinename		= convert(nvarchar(100), serverproperty('machinename')) + @instancename
		,@DefaultDataDir	= REPLACE(@DefaultDataDir,'$INSTANCENAME$',@instancename)
		,@DefaultLogDir		= REPLACE(@DefaultLogDir,'$INSTANCENAME$',@instancename)
		,@DefaultBackupDir	= REPLACE(@DefaultBackupDir,'$INSTANCENAME$',@instancename)
		,@RegKey			= 'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' 
		,@ServiceExt		= isnull('$'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
		,@ServerName_NEW	= COALESCE(@ServerName_NEW,REPLACE(@MachineName,'-N','')) -- ONLY USED FOR THE SWAPS
		,@ServerToClone		= REPLACE(REPLACE(@machinename,'FREB','FREC'),'-N','')
		,@TcpPort			= COALESCE(@TcpPort,CASE @machinename
								WHEN 'FREBASPSQL01-N\A'		THEN	'3847'
								WHEN 'FREBGMSSQLA01-N\A'	THEN	'1063'
								WHEN 'FREBGMSSQLB01-N\B'	THEN	'1178'
								WHEN 'FREBSHWSQL01-N\A'		THEN	'4234'
								WHEN 'FREBGMSSQLB01-N\HGA'	THEN	'1554'
								ELSE '1433' END)
		,@Platform			= (Select TOP 1 Character_Value FROM #XP_MSVER_RESULTS WHERE name = 'Platform')
		,@PhysicalMemory	= (Select TOP 1 Internal_Value  FROM #XP_MSVER_RESULTS WHERE name = 'PhysicalMemory')
		,@Edition			= (Select TOP 1 CAST(convert(sysname, serverproperty('Edition')) AS VarChar(255)))


DROP TABLE #XP_MSVER_RESULTS

IF @RunSection = 2 Goto Section2
IF @RunSection = 3 Goto Section3
IF @RunSection = 4 Goto Section4
IF @RunSection = 5 Goto Section5

Section1:

-- RENAME
IF isnull(nullif(@machinename,''),@@servername) != @@servername
BEGIN
	EXEC sp_dropserver @@servername; 
	EXEC sp_addserver @machinename, 'local'
	PRINT 'SERVER NAME CHANGED TO ' +  @machinename
END
ELSE PRINT 'SERVER NAME ALREADY SET'

EXEC sp_configure 'show advanced option', 1;
RECONFIGURE WITH OVERRIDE;
EXEC sp_configure 'Agent XPs', 1;
RECONFIGURE WITH OVERRIDE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE WITH OVERRIDE;
EXEC sp_configure 'Ole Automation Procedures', 1;
RECONFIGURE WITH OVERRIDE;
EXEC sp_configure 'clr enabled', 1;
RECONFIGURE WITH OVERRIDE; 
EXEC sp_configure 'disallow results from triggers', 1;
RECONFIGURE WITH OVERRIDE; 
EXEC sp_configure 'remote proc trans', 1;
RECONFIGURE WITH OVERRIDE;
EXEC sp_configure 'remote admin connections', 1;
RECONFIGURE WITH OVERRIDE;
EXEC sp_configure N'user options', 0
RECONFIGURE WITH OVERRIDE

-- GET CURRENT INSTANCE NUMBER VALUES
EXEC	master..xp_regread 
			@rootkey		= 'HKEY_LOCAL_MACHINE' 
			,@key			= @RegKey 
			,@value_name	= @@SERVICENAME
			,@value			= @InstanceNumber OUTPUT


-- GET CURRENT AUTHENTICATION VALUE
SET		@RegKey				= 'SOFTWARE\Microsoft\Microsoft SQL Server\'+@InstanceNumber+'\MSSQLServer'
EXEC	master..xp_regread
			@rootkey		= 'HKEY_LOCAL_MACHINE' 
			,@key			= @RegKey 
			,@value_name	= 'LoginMode'
			,@value			= @LoginMode OUTPUT

-- SET CURRENT AUTHENTICATION VALUE
IF @LoginMode != 2
	EXEC	master..xp_regwrite
				@rootkey		= 'HKEY_LOCAL_MACHINE' 
				,@key			= @RegKey 
				,@value_name	= 'LoginMode'
				,@type			= 'REG_DWORD' 
				,@value			= 2


-- GET CURRENT PORT VALUES
SET		@RegKey				= 'SOFTWARE\Microsoft\Microsoft SQL Server\'+@InstanceNumber+'\MSSQLSERVER\SuperSocketNetLib\Tcp\IPAll\'
EXEC	master..xp_regread
			@rootkey		= 'HKEY_LOCAL_MACHINE' 
			,@key			= @RegKey 
			,@value_name	= 'TcpPort'
			,@value			= @OldPort OUTPUT

-- SHOW OLD VALUES
SELECT		''					AS [Old]
			, @OldPort			AS PortNumber 
			,@ServerName		AS ServerName 
			,@InstanceName		AS InstanceName
			,@InstanceNumber	AS InstanceNumber


-- CHANGE PORT
IF		@TcpPort != isnull(nullif(@OldPort,''),'1433')
BEGIN
	SET		@RegKey			= 'SOFTWARE\Microsoft\Microsoft SQL Server\'+@InstanceNumber+'\MSSQLSERVER\SuperSocketNetLib\Tcp\IPAll\'
	EXEC	master..xp_regwrite
				@rootkey		= 'HKEY_LOCAL_MACHINE' 
				,@key			= @RegKey 
				,@value_name	= 'TcpPort'
				,@type			= 'REG_SZ' 
				,@value			= @TcpPort 

	EXEC	master..xp_regread
				@rootkey		= 'HKEY_LOCAL_MACHINE' 
				,@key			= @RegKey 
				,@value_name	= 'TcpPort'
				,@value			= @OldPort OUTPUT

	PRINT 'TCP PORT CHANGED TO ' + @OldPort
END
ELSE PRINT 'TCP PORT ALREADY SET'

-- SET DEFAULT DATA, LOG, AND BACKUP DIRECTORYS
SET			@DynamicCode	= 'MD ' +  @DefaultDataDir
EXEC	XP_CMDSHELL @DynamicCode

EXEC	master..xp_instance_regwrite
			@rootkey		= 'HKEY_LOCAL_MACHINE' 
			,@key			= 'Software\Microsoft\MSSQLServer\MSSQLServer' 
			,@value_name	= 'DefaultData'
			,@type			= 'REG_SZ' 
			,@value			= @DefaultDataDir 

SET			@DynamicCode	= 'MD ' +  @DefaultLogDir
EXEC	XP_CMDSHELL @DynamicCode

EXEC	master..xp_instance_regwrite
			@rootkey		= 'HKEY_LOCAL_MACHINE' 
			,@key			= 'Software\Microsoft\MSSQLServer\MSSQLServer' 
			,@value_name	= 'DefaultLog'
			,@type			= 'REG_SZ' 
			,@value			= @DefaultLogDir 

SET			@DynamicCode	= 'MD ' +  @DefaultBackupDir
EXEC	XP_CMDSHELL @DynamicCode

EXEC	master..xp_instance_regwrite
			@rootkey		= 'HKEY_LOCAL_MACHINE' 
			,@key			= 'Software\Microsoft\MSSQLServer\MSSQLServer' 
			,@value_name	= 'BackupDirectory'
			,@type			= 'REG_SZ' 
			,@value			= @DefaultBackupDir 

-- RECHECK VALUES
-- GET CURRENT PORT VALUES
SET		@RegKey				= 'SOFTWARE\Microsoft\Microsoft SQL Server\'+@InstanceNumber+'\MSSQLSERVER\SuperSocketNetLib\Tcp\IPAll\'
EXEC	master..xp_regread
			@rootkey		= 'HKEY_LOCAL_MACHINE' 
			,@key			= @RegKey 
			,@value_name	= 'TcpPort'
			,@value			= @OldPort OUTPUT

-- SET AGENT JOB HISTORY VALUES
EXEC	msdb.dbo.sp_set_sqlagent_properties
			@jobhistory_max_rows			=10000
			,@jobhistory_max_rows_per_job	=1000



-- CALCULATE AWE DEFAULT
	IF UPPER(SUBSTRING(@Edition, 1, 7)) = 'EXPRESS'
	  SET @AWEDefault = 0
	ELSE
	IF UPPER(SUBSTRING(@Edition, 1, 9)) = 'WORKGROUP'
	  SET @AWEDefault = 0
	ELSE
	  SET @AWEDefault = 1

	IF @Platform LIKE '%64'
		SET @AWEDefault = 0

-- CALCULATE MAX MEMORY
	IF @MaxMemory IS NULL
	BEGIN
		IF @PhysicalMemory < 3072
			SET @MaxMemory = @PhysicalMemory * 0.7

		IF @PhysicalMemory >= 3072 
			SET @MaxMemory = @PhysicalMemory * 0.8
	END

-- SET MAX MEMORY AND AWE  
	exec sp_configure 'max server memory (MB)', @MaxMemory;
	RECONFIGURE WITH OVERRIDE;

	exec sp_configure 'awe enabled', @AWEDefault;
	RECONFIGURE WITH OVERRIDE;

IF OBJECT_ID('dbasp_FileAccess_Write') IS NOT NULL
	DROP PROCEDURE [dbo].[dbasp_FileAccess_Write]
	
	
-- RELOCATE TEMPDB
SET @DynamicCode =
'ALTER DATABASE TempDB MODIFY FILE (NAME = tempdev, FILENAME = '''+@DefaultDataDir+'\tempdb.mdf'')'
EXEC (@DynamicCode)

SET @DynamicCode =
'ALTER DATABASE TempDB MODIFY FILE (NAME = templog, FILENAME = '''+@DefaultLogDir+'\templog.ldf'')'
EXEC (@DynamicCode)
	
SET		@DynamicCode = 'CREATE PROCEDURE [dbo].[dbasp_FileAccess_Write]
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

select @strErrorMessage=''opening the File System Object''
EXECUTE @hr = sp_OACreate  ''Scripting.FileSystemObject'' , @objFileSystem OUT

Select @FileAndPath=@path+COALESCE(CASE WHEN RIGHT(@Path,1) = ''\'' THEN '''' ELSE ''\'' END+@filename,'''')
if @HR=0 Select @objErrorObject=@objFileSystem , @strErrorMessage=CASE @Append WHEN 0 THEN ''Creating file "'' ELSE ''Appending file "'' END +@FileAndPath+''"''
if @HR=0 execute @hr = sp_OAMethod   @objFileSystem,''OpenTextFile'',@objTextStream OUT,@FileAndPath,@Method,True

if @HR=0 Select @objErrorObject=@objTextStream, 
	@strErrorMessage=''writing to the file "''+@FileAndPath+''"''
if @HR=0 execute @hr = sp_OAMethod  @objTextStream, ''Write'', Null, @String

if @HR=0 Select @objErrorObject=@objTextStream, @strErrorMessage=''closing the file "''+@FileAndPath+''"''
if @HR=0 execute @hr = sp_OAMethod  @objTextStream, ''Close''

if @hr<>0
	begin
	Declare 
		@Source varchar(1024),
		@Description Varchar(1024),
		@Helpfile Varchar(1024),
		@HelpID int
	
	EXECUTE sp_OAGetErrorInfo  @objErrorObject, 
		@source output,@Description output,@Helpfile output,@HelpID output
	Select @strErrorMessage=''Error whilst ''
			+coalesce(@strErrorMessage,''doing something'')
			+'', ''+coalesce(@Description,'''')
	raiserror (@strErrorMessage,16,1)
	end
EXECUTE  sp_OADestroy @objTextStream
EXECUTE sp_OADestroy @objTextStream'

EXEC(@DynamicCode)


SET		@DynamicCode = 'strComputer = "."
Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colServiceList = objWMIService.ExecQuery _
    ("Select * from Win32_Service")
For Each objservice in colServiceList
    If objService.name = "MSSQL'+@ServiceExt+'" or objService.name = "SQLAgent'+@ServiceExt+'" Then
	wscript.echo objservice.name
        errReturn = objService.Change( , , , , , ,"'+@ServiceActLogin+'", "'+@ServiceActPass+'")
    End If 
Next'

SET		@ScriptPath		= @DefaultBackupDir + '\SetSQLServiceAccount.vbs'
EXEC	[dbo].[dbasp_FileAccess_Write] 
			@DynamicCode
			,@ScriptPath

-- SET SECURITY POLICY VALUES FOR SERVICE ACCOUNT
SET		@DynamicCode = 'ntrights +r SeServiceLogonRight -u "'+@ServiceActLogin+'"'
EXEC	XP_CMDSHELL @DynamicCode

SET		@DynamicCode = 'ntrights +r SeLockMemoryPrivilege -u "'+@ServiceActLogin+'"'
EXEC	XP_CMDSHELL @DynamicCode

SET		@DynamicCode = 'ntrights +r SeBatchLogonRight -u "'+@ServiceActLogin+'"'
EXEC	XP_CMDSHELL @DynamicCode

SET		@DynamicCode = 'ntrights +r SeTcbPrivilege -u "'+@ServiceActLogin+'"'
EXEC	XP_CMDSHELL @DynamicCode

SET		@DynamicCode = 'ntrights +r SeAssignPrimaryTokenPrivilege -u "'+@ServiceActLogin+'"'
EXEC	XP_CMDSHELL @DynamicCode


-- CHANGE SERVICE ACOUNT
SET		@DynamicCode = 'cscript "'+ @ScriptPath +'"'
EXEC	XP_CMDSHELL @DynamicCode

IF OBJECT_ID('dbasp_FileAccess_Write') IS NOT NULL
	DROP PROCEDURE [dbo].[dbasp_FileAccess_Write]
	
	
-- ADD MEMBERS TO LOCAL ADMIN GROUP

SET		@DynamicCode = 'net localgroup "Administrators" "Amer\DevArchitects" /add'
EXEC	XP_CMDSHELL @DynamicCode	

SET		@DynamicCode = 'net localgroup "Administrators" "Amer\DevDBAs" /add'
EXEC	XP_CMDSHELL @DynamicCode	

SET		@DynamicCode = 'net localgroup "Administrators" "Amer\SeaDevelopers" /add'
EXEC	XP_CMDSHELL @DynamicCode	

SET		@DynamicCode = 'net localgroup "Administrators" "Amer\TestQALeads" /add'
EXEC	XP_CMDSHELL @DynamicCode	

SET		@DynamicCode = 'net localgroup "Administrators" "Amer\TestQualAssurance" /add'
EXEC	XP_CMDSHELL @DynamicCode	

SET		@DynamicCode = 'net localgroup "Administrators" "Amer\SeaSQLProdFull" /add'
EXEC	XP_CMDSHELL @DynamicCode	

SET		@DynamicCode = 'net localgroup "Administrators" "Amer\SeaSQLTestFull" /add'
EXEC	XP_CMDSHELL @DynamicCode	

GOTO TheEnd

Section2:

USE MASTER
-----------------------------------------------------
-----------------------------------------------------
-- DROP AND CREATE EMPTY DBAADMIN DATABASE
-----------------------------------------------------
-----------------------------------------------------
PRINT'-----------------------------------------------------'
PRINT'-----------------------------------------------------'
PRINT'-- DROP AND CREATE EMPTY DBAADMIN DATABASE'
PRINT'-----------------------------------------------------'
PRINT'-----------------------------------------------------'
SET	@DBName	= 'dbaadmin'
SET	@DynamicCode	= 
'IF EXISTS (SELECT name FROM sys.databases WHERE name = N''' + @DBName +''')
	DROP DATABASE [' + @DBName +']

CREATE DATABASE [' + @DBName +'] ON  PRIMARY 
( NAME = N''' + @DBName +''', FILENAME = N''' + @DefaultDataDir + '\' + @DBName +'.mdf'' )
 LOG ON 
( NAME = N''' + @DBName +'_log'', FILENAME = N''' + @DefaultLogDir + '\' + @DBName +'_log.ldf'')'

EXEC	(@DynamicCode)
-----------------------------------------------------
-----------------------------------------------------
-- DROP AND CREATE EMPTY DBAPERF DATABASE
-----------------------------------------------------
-----------------------------------------------------
PRINT'-----------------------------------------------------'
PRINT'-----------------------------------------------------'
PRINT'-- DROP AND CREATE EMPTY DBAPERF DATABASE'
PRINT'-----------------------------------------------------'
PRINT'-----------------------------------------------------'
SET	@DBName	= 'dbaperf'
SET	@DynamicCode	= 
'IF EXISTS (SELECT name FROM sys.databases WHERE name = N''' + @DBName +''')
	DROP DATABASE [' + @DBName +']

CREATE DATABASE [' + @DBName +'] ON  PRIMARY 
( NAME = N''' + @DBName +''', FILENAME = N''' + @DefaultDataDir + '\' + @DBName +'.mdf'' )
 LOG ON 
( NAME = N''' + @DBName +'_log'', FILENAME = N''' + @DefaultLogDir + '\' + @DBName +'_log.ldf'')'

EXEC	(@DynamicCode)
-----------------------------------------------------
-----------------------------------------------------
-- DROP AND CREATE EMPTY DEPLINFO DATABASE
-----------------------------------------------------
-----------------------------------------------------
PRINT'-----------------------------------------------------'
PRINT'-----------------------------------------------------'
PRINT'-- DROP AND CREATE EMPTY DEPLINFO DATABASE'
PRINT'-----------------------------------------------------'
PRINT'-----------------------------------------------------'
SET	@DBName	= 'deplinfo'
SET	@DynamicCode	= 
'IF EXISTS (SELECT name FROM sys.databases WHERE name = N''' + @DBName +''')
	DROP DATABASE [' + @DBName +']

CREATE DATABASE [' + @DBName +'] ON  PRIMARY 
( NAME = N''' + @DBName +''', FILENAME = N''' + @DefaultDataDir + '\' + @DBName +'.mdf'' )
 LOG ON 
( NAME = N''' + @DBName +'_log'', FILENAME = N''' + @DefaultLogDir + '\' + @DBName +'_log.ldf'')'

EXEC	(@DynamicCode)

-----------------------------------------------------
-----------------------------------------------------
-- DEPLOY TOOLS NEED FOR REST OF PROCCESS
-----------------------------------------------------
-----------------------------------------------------
USE MASTER

PRINT'-----------------------------------------------------'
PRINT'-----------------------------------------------------'
PRINT'-- DEPLOY TOOLS NEED FOR REST OF PROCCESS'
PRINT'-----------------------------------------------------'
PRINT'-----------------------------------------------------'
IF OBJECT_ID (N'dbo.Dir') IS NOT NULL
   DROP FUNCTION dbo.Dir

SET	@DynamicCode		= 
'CREATE FUNCTION [dbo].[Dir](@Wildcard VARCHAR(8000))
RETURNS @MyDir TABLE 
(
       [name] VARCHAR(2000),    --the name of the filesystem object
       [path] VARCHAR(2000),    --Contains the item''s full path and name. 
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
   IF LEN(COALESCE(@Wildcard,''''))<2 
       RETURN

   SELECT  @strErrorMessage = ''opening the Shell Application Object'' 
   EXECUTE @hr = sp_OACreate ''Shell.Application'', 
       @objShellApplication OUT 
   IF @HR = 0  
       SELECT  @objErrorObject = @objShellApplication, 
               @strErrorMessage = ''Getting Folder"'' + @wildcard + ''"'', 
               @command = ''NameSpace("''+@wildcard+''")'' 
   IF @HR = 0  
       EXECUTE @hr = sp_OAMethod @objShellApplication, @command, 
           @objFolder OUT
   IF @objFolder IS NULL RETURN --nothing there. Sod the error message
   --and then the number of objects in the folder
       SELECT  @objErrorObject = @objFolder, 
               @strErrorMessage = ''Getting count of Folder items in "'' + @wildcard + ''"'', 
               @command = ''Items.Count'' 
   IF @HR = 0  
       EXECUTE @hr = sp_OAMethod @objfolder, @command, 
           @count OUT
    IF @HR = 0 --now get the FolderItems collection 
        SELECT  @objErrorObject = @objFolder, 
                @strErrorMessage = '' getting folderitems'',
               @command=''items()''
    IF @HR = 0  
        EXECUTE @hr = sp_OAMethod @objFolder, 
            @command, @objFolderItems OUTPUT 
   SELECT @ii = 0
   WHILE @hr = 0 AND @ii< @count --iterate through the FolderItems collection
            BEGIN 
                IF @HR = 0  
                    SELECT  @objErrorObject = @objFolderItems, 
                            @strErrorMessage = '' getting folder item '' 
                                   + CAST(@ii AS VARCHAR(5)),
                           @command=''item('' + CAST(@ii AS VARCHAR(5))+'')''
                           --@Command=''GetDetailsOf(''+ cast(@ii as varchar(5))+'',1)''
                IF @HR = 0  
                    EXECUTE @hr = sp_OAMethod @objFolderItems, 
                        @command, @objItem OUTPUT 

                IF @HR = 0  
                    SELECT  @objErrorObject = @objItem, 
                            @strErrorMessage = '' getting folder item properties''
                                   + CAST(@ii AS VARCHAR(5))
                IF @HR = 0  
                    EXECUTE @hr = sp_OAMethod @objItem, 
                        ''path'', @path OUTPUT
                IF @HR = 0  
                    EXECUTE @hr = sp_OAMethod @objItem, 
                        ''name'', @name OUTPUT
                IF @HR = 0  
                    EXECUTE @hr = sp_OAMethod @objItem, 
                        ''ModifyDate'', @ModifyDate OUTPUT
                IF @HR = 0  
                    EXECUTE @hr = sp_OAMethod @objItem, 
                        ''IsFileSystem'', @IsFileSystem OUTPUT
                IF @HR = 0  
                    EXECUTE @hr = sp_OAMethod @objItem, 
                        ''IsFolder'', @IsFolder OUTPUT
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
                SELECT  @strErrorMessage = ''Error whilst '' 
                        + COALESCE(@strErrorMessage, ''doing something'') + '', '' 
                        + COALESCE(@Description, '''') 
                INSERT INTO @MyDir(error) SELECT  LEFT(@strErrorMessage,2000) 
            END 
        EXECUTE sp_OADestroy @objFolder 
        EXECUTE sp_OADestroy @objShellApplication

RETURN
END'
EXEC	(@DynamicCode)

-----------------------------------------------------
-----------------------------------------------------
-- DEPLOY DBAADMIN DATABASE
-----------------------------------------------------
-----------------------------------------------------
PRINT'-----------------------------------------------------'
PRINT'-----------------------------------------------------'
PRINT'-- DEPLOY DBAADMIN DATABASE'
PRINT'-----------------------------------------------------'
PRINT'-----------------------------------------------------'

-- COPY FILES
Select	@cmd = 'xcopy \\' + @central_server + '\' + @central_server + '_builds\dbaadmin\system32\*.*  %windir%\system32 /Q /C /Y'
print	@cmd
exec	master.sys.xp_cmdshell @cmd

Select	@cmd = 'if not exist c:\DBA_DiskCheck_DoNotDelete.txt (copy \\' + @central_server + '\' + @central_server + '_builds\dbaadmin\DBA_DiskCheck_DoNotDelete.txt  c:\ /Y)'
print	@cmd
exec	master.sys.xp_cmdshell @cmd

-- DEPLOY DB
SELECT		TOP 1 
			@DynamicCode = 'SQLCMD -S '+ @@SERVERNAME + ' -E -i "' + path +'"'
FROM		master.dbo.dir('\\seafresqldba01\builds\dbaadmin\production\')
WHERE		Name Like 'dbaadmin_2005_release%'
ORDER BY	ModifyDate DESC
PRINT		@DynamicCode
EXEC		XP_CMDSHELL  @DynamicCode

SELECT		TOP 1 
			'SQLCMD -S '+ @@SERVERNAME + ' -E -i "' + path +'"'
FROM		master.dbo.dir('\\seafresqldba01\builds\dbaadmin\production\')
WHERE		Name Like 'dbaadmin_2005_release%'
ORDER BY	ModifyDate DESC


-- BUILD SHARES
EXEC dbaadmin.dbo.dbasp_dba_sqlsetup @DefaultBackupDir
EXEC dbaadmin.dbo.dbasp_create_NXTshare

-- FIX JOB OUTPUTS
EXEC dbaadmin.dbo.dbasp_FixJobOutput

-- START JOBS
EXEC msdb.dbo.sp_start_job @Job_Name = 'UTIL - DBA Nightly Processing'
EXEC msdb.dbo.sp_start_job @Job_Name = 'UTIL - DBA Archive process'
-----------------------------------------------------
-----------------------------------------------------
-- DEPLOY DBAPERF DATABASE
-----------------------------------------------------
-----------------------------------------------------
PRINT'-----------------------------------------------------'
PRINT'-----------------------------------------------------'
PRINT'-- DEPLOY DBAPERF DATABASE'
PRINT'-----------------------------------------------------'
PRINT'-----------------------------------------------------'
SELECT		TOP 1 
			@DynamicCode = 'SQLCMD -S '+ @@SERVERNAME + ' -E -i "' + path +'"'
FROM		master.dbo.dir('\\seafresqldba01\builds\dbaperf\production\')
WHERE		Name Like 'dbaperf_2005_release%'
ORDER BY	ModifyDate DESC
EXEC		XP_CMDSHELL  @DynamicCode

-----------------------------------------------------
-----------------------------------------------------
-- DEPLOY DEPLINFO DATABASE
-----------------------------------------------------
-----------------------------------------------------
PRINT'-----------------------------------------------------'
PRINT'-----------------------------------------------------'
PRINT'-- DEPLOY DEPLINFO DATABASE'
PRINT'-----------------------------------------------------'
PRINT'-----------------------------------------------------'
SELECT		TOP 1 
			@DynamicCode = 'SQLCMD -S '+ @@SERVERNAME + ' -E -i "' + path +'"'
FROM		master.dbo.dir('\\seafresqldba01\builds\deplinfo\')
WHERE		Name Like 'deplinfo_2005_20%'
ORDER BY	ModifyDate DESC
EXEC		XP_CMDSHELL  @DynamicCode

-- CREATE JOBS
EXEC deplinfo.dbo.dpsp_addjob_streamline
EXEC deplinfo.dbo.dpsp_ahp_addjob

PRINT'-----------------------------------------------------'
PRINT'-----------------------------------------------------'
PRINT'-- DONE'
PRINT'-----------------------------------------------------'
PRINT'-----------------------------------------------------'


-- MODIFY NUMBER OF DATA DEVICES FOR TEMPDB
SET			@DynamicCode = 
'CREATE FUNCTION [dbo].[dbaudf_CPUInfo](@Attribute sysname)
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
				 
	exec sp_OACreate ''WbemScripting.SWbemLocator'', @WmiServiceLocator output; 
	exec sp_OAMethod @WmiServiceLocator, ''ConnectServer'', @WmiService output, ''.'', ''root\cimv2''; 
	exec sp_OAMethod @WmiService, ''execQuery'', @CounterCollection output, ''Select * from Win32_Processor'';
	 
	exec sp_OAGetProperty @CounterCollection,''Count'', @Count OUT

	WHILE @CPULoop < @Count
	BEGIN
		SET		@Property = ''Win32_Processor.DeviceID=''''CPU''+CAST(@CPULoop AS VarChar)+''''''''
		exec sp_OAMethod @CounterCollection, ''Item'', @CounterObject output, @Property;

		SET		@Value = 0
		exec	sp_OAGetProperty @CounterObject, ''NumberOfCores'', @Value output;
		SET		@NumberOfCores = @NumberOfCores + @Value
		
		SET		@Value = 0
		exec	sp_OAGetProperty @CounterObject, ''NumberOfLogicalProcessors'', @Value output; 
		SET		@NumberOfLogicalProcessors = @NumberOfLogicalProcessors + @Value
	
		SET		@Value2 = ''''
		exec	sp_OAGetProperty @CounterObject, ''SocketDesignation'', @Value2 output;
		 
		IF @Value2 NOT IN (SELECT SocketDesignation FROM @SocketList)
				INSERT INTO @SocketList(SocketDesignation) VALUES(@Value2)

		SET		@CPULoop = @CPULoop + 1

	END
	
	IF @Count > 0 AND @NumberOfLogicalProcessors = 0
		SELECT	@NumberOfLogicalProcessors	= @Count
				,@Count						= COUNT(*)
				,@NumberOfCores				= @NumberOfLogicalProcessors / @Count
		FROM	@SocketList		 
	
	IF @Attribute = ''Sockets''
		SET @Value = @Count
	ELSE IF @Attribute = ''Cores''
		SET @Value = @NumberOfCores
	ELSE
		SET @Value = @NumberOfLogicalProcessors

	RETURN @Value
END'

IF OBJECT_ID('dbaudf_CPUInfo') IS NOT NULL
	DROP FUNCTION [dbo].[dbaudf_CPUInfo]

EXEC (@DynamicCode)

SELECT	@CPUCores		= [dbo].[dbaudf_CPUInfo]('Cores')
		,@TempDBFiles	= count(*)
From	sys.master_files 
where	db_name(database_id)= 'tempdb' 
	and	type = 0

WHILE	@CPUCores > (SELECT count(*) From sys.master_files where db_name(database_id)= 'tempdb' and	type = 0)
BEGIN
	SET	@TempDBFiles = @TempDBFiles + 1

	SET @DynamicCode =
	'ALTER DATABASE TempDB ADD FILE (NAME = tempdev_'+RIGHT('00'+CAST(@TempDBFiles AS VarChar),2)+', FILENAME = '''+@DefaultDataDir+'\tempdb_'+RIGHT('00'+CAST(@TempDBFiles AS VarChar),2)+'.mdf'')'
	EXEC (@DynamicCode)
END

IF OBJECT_ID('dbaudf_CPUInfo') IS NOT NULL
	DROP FUNCTION [dbo].[dbaudf_CPUInfo]

Goto TheEnd

Section3:

DECLARE		@ServerString1		sysname
			,@ServerString2		sysname
			,@ServerString3		sysname

SELECT		@ServerString1		= LEFT(@ServerToClone,CHARINDEX ('\',@ServerToClone+'\')-1)
			,@ServerString2		= REPLACE(@ServerToClone,'\','$')
			,@ServerString3		= CASE WHEN CHARINDEX ('\',@ServerToClone) > 0 THEN REPLACE(@ServerToClone,'\','(')+')' ELSE @ServerToClone END
			
-- CREATE DATABASES
SELECT		@ScriptPath			= '\\'+@ServerString1+'\'+@ServerString2+'_dba_archive\'+@ServerString3+'_SYScreatedatabases.gsql'
			,@DynamicCode		= ''
			
SELECT		@DynamicCode		= @DynamicCode + Line + CHAR(13) + CHAR(10)
FROM		(
			SELECT		DISTINCT Line
			FROM		dbaadmin.dbo.dbaudf_FileAccess_Read(@ScriptPath,NULL)
			WHERE		line like 'Create database %'
				AND		line NOT Like '%master'
				AND		line NOT Like '%model'
				AND		line NOT Like '%msdb'
				AND		line NOT Like '%tempdb'
				AND		line NOT Like '%dbaadmin'
				AND		line NOT Like '%dbaperf'
				AND		line NOT Like '%deplinfo'
			) Data

PRINT @DynamicCode
EXEC (@DynamicCode)

-- CHANGE DB OWNER
SELECT		@ScriptPath			= '\\'+@ServerString1+'\'+@ServerString2+'_dba_archive\'+@ServerString3+'_SYSchgdbowner.gsql'
			,@DynamicCode = 'SQLCMD -S '+ @@SERVERNAME + ' -E -i "' + @ScriptPath +'"'
EXEC		XP_CMDSHELL  @DynamicCode			

-- ADD MASTER LOGINS
SELECT		@ScriptPath			= '\\'+@ServerString1+'\'+@ServerString2+'_dba_archive\'+@ServerString3+'_SYSaddmasterlogins.gsql'
			,@DynamicCode = 'SQLCMD -S '+ @@SERVERNAME + ' -E -i "' + @ScriptPath +'"'
EXEC		XP_CMDSHELL  @DynamicCode			

-- CREATE DB USERS
SELECT		@ScriptPath			= '\\'+@ServerString1+'\'+@ServerString2+'_dba_archive\'+@ServerString3+'_SYScreateDBusers.gsql'
			,@DynamicCode = 'SQLCMD -S '+ @@SERVERNAME + ' -E -i "' + @ScriptPath +'"'
EXEC		XP_CMDSHELL  @DynamicCode			

-- ADD DB ROLES
SELECT		@ScriptPath			= '\\'+@ServerString1+'\'+@ServerString2+'_dba_archive\'+@ServerString3+'_SYSadddbroles.gsql'
			,@DynamicCode = 'SQLCMD -S '+ @@SERVERNAME + ' -E -i "' + @ScriptPath +'"'
EXEC		XP_CMDSHELL  @DynamicCode			

-- ADD DB ROLE MEMBERS
SELECT		@ScriptPath			= '\\'+@ServerString1+'\'+@ServerString2+'_dba_archive\'+@ServerString3+'_SYSadddbrolemembers.gsql'
			,@DynamicCode = 'SQLCMD -S '+ @@SERVERNAME + ' -E -i "' + @ScriptPath +'"'
EXEC		XP_CMDSHELL  @DynamicCode			

-- ADD SERVER ROLE MEMBERS
SELECT		@ScriptPath			= '\\'+@ServerString1+'\'+@ServerString2+'_dba_archive\'+@ServerString3+'_SYSaddsrvrolemembers.gsql'
			,@DynamicCode = 'SQLCMD -S '+ @@SERVERNAME + ' -E -i "' + @ScriptPath +'"'
EXEC		XP_CMDSHELL  @DynamicCode			

-- ADD SYSTEM MESSAGES
SELECT		@ScriptPath			= '\\'+@ServerString1+'\'+@ServerString2+'_dba_archive\'+@ServerString3+'_SYSaddsysmessages.gsql'
			,@DynamicCode = 'SQLCMD -S '+ @@SERVERNAME + ' -E -i "' + @ScriptPath +'"'
EXEC		XP_CMDSHELL  @DynamicCode			




Goto TheEnd

Section4:

Goto TheEnd

Section5:

Goto TheEnd

TheEnd:

USE MASTER

IF OBJECT_ID (N'dbo.Dir') IS NOT NULL
   DROP FUNCTION dbo.Dir

GO


