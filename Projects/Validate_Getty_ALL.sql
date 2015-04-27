SET NOCOUNT ON
USE [master]
GO
ALTER DATABASE [model] SET RECOVERY SIMPLE WITH NO_WAIT
GO

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- CREATE TEMP OBJECTS
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RP]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RP]

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RP]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[RP]  
    (@String VarChar(8000),  
     @PartNumber int) 
RETURNS VarChar(8000) 
AS 
BEGIN
SET	@PartNumber	= COALESCE(@PartNumber,1)
SET	@String		= COALESCE(LTRIM(RTRIM(@String)),'''')  
IF	@PartNumber	< 1 SET @PartNumber = 1

-- SHORT CUT 1: Empty String
IF      @String = ''''	RETURN @String
 
-- SHORT CUT 2: Only 1 Part 
IF	CHARINDEX(''|'', @String, 1) = 0 
    BEGIN 
        IF @PartNumber = 1 
            RETURN @String 
        ELSE 
            Return '''' 
    END 

-- SHORT CUT 3: Part 1
IF @PartNumber = 1 
        RETURN LEFT(@String, CHARINDEX(''|'', @String) - 1)
         
-- GET PART
WHILE @PartNumber > 1 -- CHOP OFF UNWANTED PARTES TO GET TO THE ONE REQUESTED
    BEGIN 
        IF CHARINDEX(''|'', @String) = 0	-- No More Parts
            Return ''''
             
        SET @String = SUBSTRING(@String, CHARINDEX(''|'', @String, 1) + 1, LEN(@String) - CHARINDEX(''|'', @String, 1)) -- STRIP AWAY FIRST PART 
        SET @PartNumber = @PartNumber - 1     
    END	-- LOOP TILL REQUESTED PART
     
-- SHORT CUT 4: Only 1 Part Left
IF CHARINDEX(''|'', @String, 1) = 0 RETURN @String
 
RETURN LEFT(@String, CHARINDEX(''|'', @String, 1) - 1) 
END 
' 
END
GO
CREATE	TABLE		#FileExists			(isFile bit, isDir bit, hasParentDir bit)
GO
CREATE	TABLE		#XP_MSVER_RESULTS		([Index] int, [Name] varchar(255), [Internal_Value] varchar(255), [Character_Value] varchar(255))
GO
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- START
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
PRINT	''
PRINT	'Starting SQL Server Instal Verification....'
PRINT	''
DECLARE	@LoopCnt					INT
DECLARE	@RL1Y						CHAR(20)
DECLARE	@RL1N						CHAR(20)
DECLARE	@RL1W						CHAR(20)
DECLARE	@RL2						CHAR(20)
DECLARE	@RL3Y						VARCHAR(255)
DECLARE	@RL3N						VARCHAR(255)
DECLARE	@RL3W						VARCHAR(255)
DECLARE	@OutputType					INT
DECLARE @TotalFailCount					Int
DECLARE @TotalWarnCount					Int
DECLARE	@Check_DB_dbaadmin				BIT
DECLARE	@Check_DB_dbaperf				BIT
DECLARE	@Check_DB_DEPLinfo				BIT
DECLARE	@Check_Platform_X64				BIT
DECLARE	@Check_OS_X64					BIT
DECLARE	@Check_SQL_X64					BIT
DECLARE	@Check_DefaultTrace				BIT
DECLARE	@Check_AgentXPs					BIT
DECLARE	@Check_SMODMOXPs				BIT
DECLARE	@Check_OLE					BIT
DECLARE	@Check_CMDSHELL					BIT
DECLARE	@Check_Shares					BIT
DECLARE @AWEDefault					INT
DECLARE	@ConfigStatus					VARCHAR(8000)
DECLARE	@CPUCount					INT
DECLARE	@PhysicalMemory 				INT
DECLARE	@MaxMemory					INT
DECLARE	@MinMemory					INT
DECLARE	@OSVersion					DECIMAL(3,1)
DECLARE @Platform					VARCHAR(255)
DECLARE @Version					VARCHAR(255)
DECLARE @Level						VARCHAR(255)
DECLARE @Edition					VARCHAR(255)
DECLARE	@FileDescription				VARCHAR(255)
DECLARE	@ServiceSQLAcnt					VARCHAR(255)
DECLARE	@ServiceAgentAcnt				VARCHAR(255)
DECLARE	@ServiceSQLStart				VARCHAR(255)
DECLARE	@ServiceAGENTStart				VARCHAR(255)
DECLARE	@SQLInstanceNumberName				VARCHAR(255)
DECLARE	@JobName					sysname
DECLARE @jobhistory_max_rows				INT
DECLARE @jobhistory_max_rows_per_job			INT
DECLARE @share_name					varchar(255)
DECLARE @share_name2					varchar(255)
DECLARE @share_type					Int
DECLARE @phy_path					varchar(100)
DECLARE	@FileName					VARCHAR(255)
DECLARE	@FilePath					VARCHAR(255)

DECLARE @File						VARCHAR(255)
DECLARE	@in_key						sysname
DECLARE	@in_path					sysname
DECLARE	@in_value					sysname
DECLARE	@result_value					nvarchar(500)
DECLARE @Print_Local_ServerEnviro_SQLString		nvarchar(500);
DECLARE @Print_Generic_Pair_SQLString			nvarchar(500);
DECLARE @Print_Local_ServerEnviro_ParmDefinition	nvarchar(500);
DECLARE @Print_Generic_Pair_ParmDefinition		nvarchar(500);
DECLARE @TempValue					varchar(8000);

DECLARE	@Settings					TABLE (ParamSource sysname,ParamName sysname,ParamValue sysname NULL)
DECLARE @configuration_defaults_table			TABLE (ParamSource sysname,name sysname,default_value sysname,severity int,autofix int)
DECLARE @tracestatus					TABLE (TraceFlag nvarchar(40),Status tinyint,Global tinyint,Session tinyint)

SET	@Print_Local_ServerEnviro_SQLString		= N'DECLARE @env_detail sysname;SELECT @env_detail = env_detail FROM dbaadmin.dbo.Local_ServerEnviro WHERE env_type = @env_type;SET @env_type = @env_type + '':''+REPLICATE(''.'',40-LEN(@env_type));PRINT @env_type + @env_detail;'
SET	@Print_Local_ServerEnviro_ParmDefinition	= N'@env_type sysname'	
SET	@Print_Generic_Pair_SQLString			= N'SET @Param = @Param + '':''+REPLICATE(''.'',40-LEN(@Param));PRINT @Param + @Value;'
SET	@Print_Generic_Pair_ParmDefinition		= N'@Param sysname,@Value VarChar(255)'	
SET	@RL1Y						= '[X] [ ] [ ] SUCCESS...  '
SET	@RL1N						= '[ ] [ ] [X] FAILURE...  '
SET	@RL1W						= '[ ] [X] [ ] WARNING...  '
SET	@AWEDefault					= 1
SET	@TotalFailCount					= 0
SET	@TotalWarnCount					= 0
SET	@OutputType					= 0	-- Messages Only
							--= 1	-- Messages and Single Select Value
							--= 2	-- Messages and RaiseError
							--= 3	-- Messages and Return All Settings

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--	BUILD SETTINGS TABLE
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--	GET MISC VALUES
INSERT INTO @Settings
Select  'System Function','ServerName' ,CAST(@@servername AS VarChar(255)) 
UNION ALL
Select  'dm_os_schedulers','ProcessorCount', CAST(count(*) AS VarChar(255)) AS ParamValue from sys.dm_os_schedulers where is_online = 1 and scheduler_id < 255 
UNION ALL
Select  'sysprocesses','ServerStart' ,CAST(convert(nvarchar,login_time) AS VarChar(255)) from sys.sysprocesses where spid=1
UNION ALL
SELECT		'sysjobs'
		,SJ.Name
		,CAST(SJ.Enabled AS CHAR(1)) + '|'
		+CASE COALESCE((SELECT TOP 1 run_status FROM msdb..sysjobhistory WHERE job_id = sj.job_id ORDER BY run_date DESC,run_time DESC),'-1')
			WHEN '-1' THEN 'Never Run'
			WHEN '0' THEN 'Failed'
			WHEN '1' THEN 'Succeeded'
			WHEN '2' THEN 'Retry'
			WHEN '3' THEN 'Cancled'
			WHEN '4' THEN 'In Progress'
			ELSE 'Unknown'
			END + '|'
		+COALESCE(CONVERT(VARCHAR(50),(SELECT TOP 1 CONVERT(DATETIME, RTRIM(run_date))+(run_time * 9 + run_time % 10000 * 6 + run_time % 100 * 10) / 216e4 FROM msdb..sysjobhistory WHERE job_id = sj.job_id ORDER BY run_date DESC,run_time DESC),120),'')+'|'
		+COALESCE((SELECT TOP 1 STUFF(STUFF(RIGHT('000000' + CONVERT(varchar(6), run_duration), 6),3,0,':'),6,0,':') FROM msdb..sysjobhistory WHERE job_id = sj.job_id ORDER BY run_date DESC,run_time DESC),'')
FROM		msdb..sysjobs sj

-- GET CURRENT TRACE FLAGS
insert into @tracestatus exec('dbcc tracestatus WITH NO_INFOMSGS')
INSERT INTO	@Settings
SELECT		'TraceFlag'
		,TraceFlag
		,Global
FROM		@tracestatus
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--	GET	SERVERPROPERTY
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
INSERT INTO @Settings
SELECT	'serverproperty','BuildClrVersion' ,CAST(convert(sysname, serverproperty('BuildClrVersion')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','Collation' ,CAST(convert(sysname, serverproperty('Collation')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','CollationID' ,CAST(convert(sysname, serverproperty('CollationID')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','ComparisonStyle' ,CAST(convert(sysname, serverproperty('ComparisonStyle')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','ComputerNamePhysicalNetBIOS' ,CAST(convert(sysname, serverproperty('ComputerNamePhysicalNetBIOS')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','Edition' ,CAST(convert(sysname, serverproperty('Edition')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','EditionID' ,CAST(convert(sysname, serverproperty('EditionID')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','EngineEdition' ,CAST(convert(sysname, serverproperty('EngineEdition')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','InstanceName' ,CAST(convert(sysname, serverproperty('InstanceName')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','IsClustered' ,CAST(convert(sysname, serverproperty('IsClustered')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','IsFullTextInstalled' ,CAST(convert(sysname, serverproperty('IsFullTextInstalled')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','IsIntegratedSecurityOnly' ,CAST(convert(sysname, serverproperty('IsIntegratedSecurityOnly')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','IsSingleUser' ,CAST(convert(sysname, serverproperty('IsSingleUser')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','LCID' ,CAST(convert(sysname, serverproperty('LCID')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','LicenseType' ,CAST(convert(sysname, serverproperty('LicenseType')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','MachineName' ,CAST(convert(sysname, serverproperty('MachineName')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','NumLicenses' ,CAST(convert(sysname, serverproperty('NumLicenses')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','ProcessID' ,CAST(convert(sysname, serverproperty('ProcessID')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','ProductVersion' ,CAST(convert(sysname, serverproperty('ProductVersion')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','ProductLevel' ,CAST(convert(sysname, serverproperty('ProductLevel')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','ResourceLastUpdateDateTime' ,CAST(convert(sysname, serverproperty('ResourceLastUpdateDateTime')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','ServerName' ,CAST(convert(sysname, serverproperty('ServerName')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','SqlCharSet' ,CAST(convert(sysname, serverproperty('SqlCharSet')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','SqlCharSetName' ,CAST(convert(sysname, serverproperty('SqlCharSetName')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','SqlSortOrder' ,CAST(convert(sysname, serverproperty('SqlSortOrder')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','SqlSortOrderName' ,CAST(convert(sysname, serverproperty('SqlSortOrderName')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','FilestreamShareName' ,CAST(convert(sysname, serverproperty('FilestreamShareName')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','FilestreamConfiguredLevel' ,CAST(convert(sysname, serverproperty('FilestreamConfiguredLevel')) AS VarChar(255))
UNION ALL
SELECT	'serverproperty','FilestreamEffectiveLevel' ,CAST(convert(sysname, serverproperty('FilestreamEffectiveLevel')) AS VarChar(255))

-- CHANGE SELECTED '0' VALUES TO 'NO'
UPDATE	@Settings
SET	ParamValue = 'No'
WHERE	ParamName Like 'Is%'
AND	ParamValue = '0'

-- CHANGE SELECTED '1' VALUES TO 'YES'
UPDATE	@Settings
SET	ParamValue = 'Yes'
WHERE	ParamName Like 'Is%'
AND	ParamValue = '1'

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--	GET	SYSCONFIGURES
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- GET VALUES THAT DO NOT NEED TRANSLATION
INSERT INTO @Settings
SELECT	'sys.configurations'
	,name
	,CAST(Value AS VarChar(255))+ CASE WHEN value <> value_in_use THEN '*' ELSE '' END  
FROM	sys.configurations
WHERE	Description Not Like 'Allow%'
AND	Description NOT LIKE 'Disallow%'
AND	Description NOT LIKE 'Show%'
AND	Description NOT LIKE 'Create%'
AND	Description NOT LIKE 'C2%'
AND	Description NOT LIKE 'AWE%'
AND	Description NOT LIKE 'CLR%'
AND	Description NOT LIKE 'Common%'
AND	Description NOT LIKE 'Enable%'
AND	Description NOT LIKE 'Dedicated%'
AND	Description NOT LIKE 'Priority%'
AND	Description NOT LIKE 'Recovery%'
AND	Description NOT LIKE 'Set%'
AND	Description NOT LIKE 'Scan%'
AND	Description NOT LIKE 'Transform%'
AND	Description NOT LIKE 'Use%'

-- GET VALUES THAT DO NEED TRANSLATION
INSERT INTO @Settings
SELECT	'sys.configurations'
	,name
	,CAST(CASE Value WHEN 0 THEN 'No' ELSE 'Yes' END AS VarChar(255))+ CASE WHEN value <> value_in_use THEN '*' ELSE '' END 
FROM	sys.configurations
WHERE	Description Like 'Allow%'
OR	Description LIKE 'Disallow%'
OR	Description LIKE 'Show%'
OR	Description LIKE 'Create%'
OR	Description LIKE 'C2%'
OR	Description LIKE 'AWE%'
OR	Description LIKE 'CLR%'
OR	Description LIKE 'Common%'
OR	Description LIKE 'Enable%'
OR	Description LIKE 'Dedicated%'
OR	Description LIKE 'Priority%'
OR	Description LIKE 'Recovery%'
OR	Description LIKE 'Set%'
OR	Description LIKE 'Scan%'
OR	Description LIKE 'Transform%'
OR	Description LIKE 'Use%'

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--	GET	sysdatabases
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
INSERT INTO	@Settings
SELECT		'sysdatabases'
		,NAME
		,filename
FROM		master.dbo.sysdatabases
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--	GET	sysfiles
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
INSERT INTO @Settings
EXEC sp_msForEachDB 'SELECT ''sysfiles'',''?''+CASE Groupid WHEN ''1'' THEN ''_DataFile'' WHEN ''0'' THEN ''_LogFile'' ELSE ''_File'' END,name +'' ''+ filename FROM ?.dbo.sysfiles'

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--	GET	XP_MSVER
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
INSERT INTO #XP_MSVER_RESULTS EXEC master..xp_msver 
	
INSERT INTO	@Settings
SELECT		'xp_msver'
		,NAME
		,CAST(COALESCE(Internal_Value,'NULL') AS VARCHAR(255))+'|'+CAST(COALESCE(Character_Value,'NULL') AS VARCHAR(255))
FROM		#XP_MSVER_RESULTS

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--	GET	REGISTRY VALUES
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
select @in_key = 'HKEY_LOCAL_MACHINE'
select @in_path = 'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL'
select @in_value = @@SERVICENAME
exec dbaadmin.dbo.dbasp_regread @in_key, @in_path, @in_value, @SQLInstanceNumberName OUTPUT
INSERT INTO @Settings      VALUES('Registry','SQLInstanceNumberName',@SQLInstanceNumberName)	

-- SQL Service Account
SET @result_value = NULL
IF @@SERVICENAME = 'MSSQLSERVER'
   BEGIN
	SELECT @in_key = 'HKEY_LOCAL_MACHINE'
	SELECT @in_path = 'System\CurrentControlSet\Services\MSSQLServer'
	SELECT @in_value = 'ObjectName'
	EXEC dbaadmin.dbo.dbasp_regread @in_key, @in_path, @in_value, @result_value OUTPUT
   END
ELSE
   BEGIN
   	SELECT @in_key = 'HKEY_LOCAL_MACHINE'
	SELECT @in_path = 'System\CurrentControlSet\Services\MSSQL$' + @@SERVICENAME
	SELECT @in_value = 'ObjectName'
	EXEC dbaadmin.dbo.dbasp_regread @in_key, @in_path, @in_value, @result_value OUTPUT
   END
INSERT INTO @Settings      VALUES('Registry','SQLAccount',@result_value)

-- Agent Service Account	
SET @result_value = NULL
If @@SERVICENAME = 'MSSQLSERVER'
   begin
	select @in_key = 'HKEY_LOCAL_MACHINE'
	select @in_path = 'System\CurrentControlSet\Services\SQLServerAgent'
	select @in_value = 'ObjectName'
	exec dbaadmin.dbo.dbasp_regread @in_key, @in_path, @in_value, @result_value output
   end
Else
   begin
	select @in_key = 'HKEY_LOCAL_MACHINE'
	select @in_path = 'System\CurrentControlSet\Services\SQLAgent$' + @@SERVICENAME
	select @in_value = 'ObjectName'
	exec dbaadmin.dbo.dbasp_regread @in_key, @in_path, @in_value, @result_value output
   END
INSERT INTO @Settings      VALUES('Registry','AgentAccount',@result_value)

-- SQL Service AutoStart
SET @result_value = NULL
IF @@SERVICENAME = 'MSSQLSERVER'
   BEGIN
	SELECT @in_key = 'HKEY_LOCAL_MACHINE'
	SELECT @in_path = 'System\CurrentControlSet\Services\MSSQLServer'
	SELECT @in_value = 'Start'
	EXEC dbaadmin.dbo.dbasp_regread @in_key, @in_path, @in_value, @result_value OUTPUT
   END
ELSE
   BEGIN
   	SELECT @in_key = 'HKEY_LOCAL_MACHINE'
	SELECT @in_path = 'System\CurrentControlSet\Services\MSSQL$' + @@SERVICENAME
	SELECT @in_value = 'Start'
	EXEC dbaadmin.dbo.dbasp_regread @in_key, @in_path, @in_value, @result_value OUTPUT
   END
INSERT INTO @Settings      VALUES('Registry','SQLServiceStart',@result_value)

-- Agent Service AutoStart	
SET @result_value = NULL
If @@SERVICENAME = 'MSSQLSERVER'
   begin
	select @in_key = 'HKEY_LOCAL_MACHINE'
	select @in_path = 'System\CurrentControlSet\Services\SQLServerAgent'
	select @in_value = 'Start'
	exec dbaadmin.dbo.dbasp_regread @in_key, @in_path, @in_value, @result_value output
   end
Else
   begin
	select @in_key = 'HKEY_LOCAL_MACHINE'
	select @in_path = 'System\CurrentControlSet\Services\SQLAgent$' + @@SERVICENAME
	select @in_value = 'Start'
	exec dbaadmin.dbo.dbasp_regread @in_key, @in_path, @in_value, @result_value output
   END
INSERT INTO @Settings      VALUES('Registry','AgentServiceStart',@result_value)

-- jobhistory_max_rows
EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
N'JobHistoryMaxRows',
@jobhistory_max_rows OUTPUT,
N'no_output'
INSERT INTO @Settings      VALUES('Registry','jobhistory_max_rows',@jobhistory_max_rows)

 -- jobhistory_max_rows
EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
N'JobHistoryMaxRowsPerJob',
@jobhistory_max_rows_per_job OUTPUT,
N'no_output'
INSERT INTO @Settings      VALUES('Registry','jobhistory_max_rows_per_job',@jobhistory_max_rows_per_job)

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--	GET	SHARE VALUES
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- DEFAULT SHARES
insert into @configuration_defaults_table values('Shares','_builds',0,1,0)       --   Values Used For The Third Field Are:
insert into @configuration_defaults_table values('Shares','_dba_mail',0,1,0)     --
insert into @configuration_defaults_table values('Shares','_SQLJob_logs',1,1,0)  --     0 = Server Level Share
insert into @configuration_defaults_table values('Shares','_dbasql',1,1,0)	     --	    1 = Instance Level Share
insert into @configuration_defaults_table values('Shares','_backup',1,1,0)
insert into @configuration_defaults_table values('Shares','_log',1,1,0)
insert into @configuration_defaults_table values('Shares','_mdf',1,1,0)
insert into @configuration_defaults_table values('Shares','_ldf',1,1,0)
insert into @configuration_defaults_table values('Shares','_dba_archive',1,1,0)
insert into @configuration_defaults_table values('Shares','_nxt',1,2,0)


DECLARE ShareCursor CURSOR
FOR
SELECT NAME,default_value FROM @configuration_defaults_table WHERE ParamSource = 'Shares'
OPEN ShareCursor
FETCH NEXT FROM ShareCursor INTO @share_name,@share_type
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET @phy_path = NULL
		SET @share_name2 = CASE @share_type
					WHEN 0 THEN LEFT(@@SERVERNAME+'\',CHARINDEX('\',@@SERVERNAME+'\')-1)+@share_name
					ELSE REPLACE(@@SERVERNAME,'\','$')+@share_name
					END
		EXECUTE [dbaadmin].[dbo].[dbasp_get_share_path] @share_name2,@phy_path OUTPUT
		INSERT INTO @Settings VALUES('Shares',@share_name,@phy_path)
	END
	FETCH NEXT FROM ShareCursor INTO @share_name,@share_type
END
CLOSE ShareCursor
DEALLOCATE ShareCursor


---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--	GET	FILE VALUES
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- DEFAULT FILES TO CHECK FOR
insert into @configuration_defaults_table values('Files','rmtShare','c:\windows\system32\rmtShare.exe',1,0)       
insert into @configuration_defaults_table values('Files','WINZIP32','c:\windows\system32\WINZIP32.EXE',1,0)     
insert into @configuration_defaults_table values('Files','RedGateBackup1','C:\Program Files (x86)\Red Gate\SQL Backup 6\SQBServerSetup.exe',2,0)  
insert into @configuration_defaults_table values('Files','RedGateBackup2','C:\Program Files\Red Gate\SQL Backup 6\SQBServerSetup.exe',2,0)  
--insert into @configuration_defaults_table values('Files','','',1,0)	     


DECLARE FileCursor CURSOR
FOR
SELECT NAME,default_value FROM @configuration_defaults_table WHERE ParamSource = 'Files'
OPEN FileCursor
FETCH NEXT FROM FileCursor INTO @FileName,@FilePath
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		TRUNCATE TABLE #FileExists
		INSERT INTO #FileExists exec master.dbo.xp_fileexist @FilePath
		IF EXISTS (SELECT * FROM #FileExists WHERE isFile = 1 AND isDir = 0)
		 INSERT INTO @Settings VALUES('Files',@FileName,@FilePath) 
		ELSE
		 INSERT INTO @Settings VALUES('Files',@FileName,NULL) 
	END
	FETCH NEXT FROM FileCursor INTO @FileName,@FilePath
END
CLOSE FileCursor
DEALLOCATE FileCursor
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- SET NEEDED VARIABLES FROM @SETTINGS
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

SELECT		@Version = CASE ParamName
				WHEN 'ProductVersion' THEN [ParamValue]
				ELSE @Version END
		,@Level = CASE ParamName
				WHEN 'ProductLevel' THEN [ParamValue]
				ELSE @Level END
		,@Edition = CASE ParamName
				WHEN 'Edition' THEN [ParamValue]
				ELSE @Edition END

		,@OSVersion = CASE 
				WHEN ParamSource='xp_msver' AND ParamName='WindowsVersion' THEN SUBSTRING(dbo.RP(ParamValue,2),1,3)
				ELSE @OSVersion END
		,@CPUCount = CASE 
				WHEN ParamSource='xp_msver' AND ParamName='ProcessorCount' THEN dbo.RP(ParamValue,1)
				ELSE @CPUCount END
		,@PhysicalMemory = CASE 
				WHEN ParamSource='xp_msver' AND ParamName='PhysicalMemory' THEN dbo.RP(ParamValue,1)
				ELSE @PhysicalMemory END
		,@Platform = CASE 
				WHEN ParamSource='xp_msver' AND ParamName='Platform' THEN dbo.RP(ParamValue,2)
				ELSE @Platform END
		,@FileDescription = CASE 
				WHEN ParamSource='xp_msver' AND ParamName='FileDescription' THEN dbo.RP(ParamValue,2)
				ELSE @FileDescription END

		,@ServiceSQLAcnt = CASE
				WHEN ParamSource = 'Registry' AND ParamName = 'SQLAccount' THEN ParamValue
				ELSE @ServiceSQLAcnt END
		,@ServiceAgentAcnt = CASE
				WHEN ParamSource = 'Registry' AND ParamName = 'AgentAccount' THEN ParamValue
				ELSE @ServiceAgentAcnt END
 		,@ServiceSQLStart = CASE
				WHEN ParamSource = 'Registry' AND ParamName = 'SQLServiceStart' THEN ParamValue
				ELSE @ServiceSQLStart END
		,@ServiceAgentStart = CASE
				WHEN ParamSource = 'Registry' AND ParamName = 'AgentServiceStart' THEN ParamValue
				ELSE @ServiceAgentStart END
 
FROM		@Settings

-- CALCULATE AWE DEFAULT
	
IF UPPER(SUBSTRING(@Edition, 1, 7)) = 'EXPRESS'
  SET @AWEDefault = 0
ELSE IF UPPER(SUBSTRING(@Edition, 1, 9)) = 'WORKGROUP'
  SET @AWEDefault = 0
ELSE
  SET @AWEDefault = 1

IF @Platform LIKE '%64'
	SET @AWEDefault = 0

-- CALCULATE MAX MEMORY

IF @PhysicalMemory < 3072
    SET @MaxMemory = @PhysicalMemory * 0.7

IF @PhysicalMemory >= 3072 
    SELECT @MaxMemory = @PhysicalMemory * 0.8

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--	BUILD DEFAULTS TABLE
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

-- THESE DEFAULT VALUES REPRESENT GETTY IMAGES DEFAULT CONFIG
insert into @configuration_defaults_table values('sys.configurations','Ad Hoc Distributed Queries',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','affinity I/O mask',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','affinity mask',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','Agent XPs',1,1,0)
insert into @configuration_defaults_table values('sys.configurations','allow updates',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','awe enabled',@AWEDefault,1,0)
insert into @configuration_defaults_table values('sys.configurations','blocked process threshold',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','c2 audit mode',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','clr enabled',1,1,0)
insert into @configuration_defaults_table values('sys.configurations','cost threshold for parallelism',5,1,0)
insert into @configuration_defaults_table values('sys.configurations','cross db ownership chaining',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','cursor threshold',-1,1,0)
insert into @configuration_defaults_table values('sys.configurations','Database Mail XPs',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','default full-text language',1033,1,0)
insert into @configuration_defaults_table values('sys.configurations','default language',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','default trace enabled',1,1,0)
insert into @configuration_defaults_table values('sys.configurations','disallow results from triggers',1,1,0)
insert into @configuration_defaults_table values('sys.configurations','fill factor (%)',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','ft crawl bandwidth (max)',100,1,0)
insert into @configuration_defaults_table values('sys.configurations','ft crawl bandwidth (min)',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','ft notify bandwidth (max)',100,1,0)
insert into @configuration_defaults_table values('sys.configurations','ft notify bandwidth (min)',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','index create memory (KB)',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','in-doubt xact resolution',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','lightweight pooling',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','locks',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','max degree of parallelism',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','max full-text crawl range',4,1,0)
insert into @configuration_defaults_table values('sys.configurations','max server memory (MB)',@MaxMemory,1,0)
insert into @configuration_defaults_table values('sys.configurations','max text repl size (B)',65536,1,0)
insert into @configuration_defaults_table values('sys.configurations','max worker threads',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','media retention',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','min memory per query (KB)',1024,1,0)
insert into @configuration_defaults_table values('sys.configurations','min server memory (MB)',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','nested triggers',1,1,0)
insert into @configuration_defaults_table values('sys.configurations','network packet size (B)',4096,1,0)
insert into @configuration_defaults_table values('sys.configurations','Ole Automation Procedures',1,1,0)
insert into @configuration_defaults_table values('sys.configurations','open objects',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','PH timeout (s)',60,1,0)
insert into @configuration_defaults_table values('sys.configurations','precompute rank',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','priority boost',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','query governor cost limit',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','query wait (s)',-1,1,0)
insert into @configuration_defaults_table values('sys.configurations','recovery interval (min)',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','remote access',1,1,0)
insert into @configuration_defaults_table values('sys.configurations','remote admin connections',1,1,0)
insert into @configuration_defaults_table values('sys.configurations','remote login timeout (s)',20,1,0)
insert into @configuration_defaults_table values('sys.configurations','remote proc trans',1,1,0)
insert into @configuration_defaults_table values('sys.configurations','remote query timeout (s)',600,1,0)
insert into @configuration_defaults_table values('sys.configurations','Replication XPs',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','RPC parameter data validation',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','scan for startup procs',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','server trigger recursion',1,1,0)
insert into @configuration_defaults_table values('sys.configurations','set working set size',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','show advanced options',1,1,0)
insert into @configuration_defaults_table values('sys.configurations','SMO and DMO XPs',1,1,0)
insert into @configuration_defaults_table values('sys.configurations','SQL Mail XPs',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','transform noise words',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','two digit year cutoff',2049,1,0)
insert into @configuration_defaults_table values('sys.configurations','user connections',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','user options',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','Web Assistant Procedures',0,1,0)
insert into @configuration_defaults_table values('sys.configurations','xp_cmdshell',1,1,0)

insert into @configuration_defaults_table values('JobHistory','jobhistory_max_rows',10000,1,0)
insert into @configuration_defaults_table values('JobHistory','jobhistory_max_rows_per_job',1000,1,0)


-- DEFAULT TRACE FLAGS
insert into @configuration_defaults_table values('Traceflag','845',1,2,0)
insert into @configuration_defaults_table values('Traceflag','1118',1,2,0)
insert into @configuration_defaults_table values('Traceflag','1222',1,2,0) --Returns the resources and types of locks that are participating in a deadlock and also the current command affected, in an XML format that does not comply with any XSD schema.
insert into @configuration_defaults_table values('Traceflag','3604',1,2,0)


UPDATE		@configuration_defaults_table
	SET	default_value = CASE default_value WHEN 0 THEN 'No' ELSE 'Yes' END
from		@configuration_defaults_table ct 
JOIN		@Settings st
	ON	ct.name = st.ParamName 
	AND	ct.ParamSource = st.ParamSource  
	AND	ct.default_value IN('0','1')
	AND	st.ParamValue IN('No','Yes')
	
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--	QUICK CRITICAL TESTS	Check the few things that this validation process relies on
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
IF EXISTS(SELECT * FROM @Settings WHERE ParamSource ='sys.configurations' AND ParamName = 'xp_cmdshell' AND ParamValue ='0')
BEGIN
	PRINT 'CRITICAL FAILURE: xp_cmdshell MUST be enabled to run this validation'
	GOTO AbortFailedCriticalChecks
END
IF NOT EXISTS(SELECT * FROM @Settings WHERE ParamSource ='sysdatabases' AND ParamName = 'dbaadmin')
BEGIN
	PRINT 'CRITICAL FAILURE: dbaadmin Database MUST be deployed to run this validation'
	GOTO AbortFailedCriticalChecks
END
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- START PRINTING OUTPUT
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
StarPrinting:

PRINT ''
PRINT '		-- SQL SERVER VERSION --'
PRINT ''

EXEC master..sp_executesql	@Print_Generic_Pair_SQLString
				, @Print_Generic_Pair_ParmDefinition
				, @Param = 'SQL Version'
				,  @Value = @Version

EXEC master..sp_executesql	@Print_Generic_Pair_SQLString
				, @Print_Generic_Pair_ParmDefinition
				, @Param = 'SQL Edition'
				,  @Value = @Edition

EXEC master..sp_executesql	@Print_Generic_Pair_SQLString
				, @Print_Generic_Pair_ParmDefinition
				, @Param = 'SP Level'
				,  @Value = @Level

PRINT ''
PRINT '		-- Local_ServerEnviro --'
PRINT ''

EXEC master..sp_executesql	@Print_Local_ServerEnviro_SQLString
				,@Print_Local_ServerEnviro_ParmDefinition
				,  @env_type = 'SRVname'

EXEC master..sp_executesql	@Print_Local_ServerEnviro_SQLString
				,@Print_Local_ServerEnviro_ParmDefinition
				,  @env_type = 'Instance'

EXEC master..sp_executesql	@Print_Local_ServerEnviro_SQLString
				,@Print_Local_ServerEnviro_ParmDefinition
				,  @env_type = 'ShareHeader'

EXEC master..sp_executesql	@Print_Local_ServerEnviro_SQLString
				,@Print_Local_ServerEnviro_ParmDefinition
				,  @env_type = 'CentralServer'

EXEC master..sp_executesql	@Print_Local_ServerEnviro_SQLString
				,@Print_Local_ServerEnviro_ParmDefinition
				,  @env_type = 'SQL Port'
				
EXEC master..sp_executesql	@Print_Local_ServerEnviro_SQLString
				,@Print_Local_ServerEnviro_ParmDefinition
				,  @env_type = 'ENVname'
				
EXEC master..sp_executesql	@Print_Local_ServerEnviro_SQLString
				,@Print_Local_ServerEnviro_ParmDefinition
				,  @env_type = 'domain'

PRINT ''
PRINT '		-- XP_MSVER RESULTS --'
PRINT ''

EXEC master..sp_executesql	@Print_Generic_Pair_SQLString
				, @Print_Generic_Pair_ParmDefinition
				, @Param = 'WindowsVersion'
				,  @Value = @OSVersion

EXEC master..sp_executesql	@Print_Generic_Pair_SQLString
				, @Print_Generic_Pair_ParmDefinition
				, @Param = 'ProcessorCount'
				,  @Value = @CPUCount

EXEC master..sp_executesql	@Print_Generic_Pair_SQLString
				, @Print_Generic_Pair_ParmDefinition
				, @Param = 'PhysicalMemory'
				,  @Value = @PhysicalMemory

EXEC master..sp_executesql	@Print_Generic_Pair_SQLString
				, @Print_Generic_Pair_ParmDefinition
				, @Param = 'Platform'
				,  @Value = @Platform

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--	PRINT CHART HEADER
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
PRINT	''
PRINT	'--------------------------------------------------------------------------------------------------------------------------------------------'
PRINT	''
PRINT	'SUCCESS'
PRINT	' |'
PRINT	' |  WARNING'
PRINT	' |   |'
PRINT	' |   |  FAILURE'
PRINT	' |   |   |'
PRINT	'[X] [X] [X] STATUS      AREA                DESCRIPTION'
PRINT	'--------------------------------------------------------------------------------------------------------------------------------------------'


---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- CHECK	CONFIGURES
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
SET	@RL2	='CONFIGURES'
SET	@RL3Y	='All Config Options are correct.'
SET	@RL3N	='The Following config options are not correct.'
SET	@RL3N	='The Following config options Should Be Checked.'
SET	@ConfigStatus = ''
--@RL1N+@RL2+@RL3N+ CHAR(13) + CHAR(10)

SELECT		@ConfigStatus=@ConfigStatus
				+CASE [severity] WHEN 1 THEN @RL1N WHEN 2 THEN @RL1W ELSE '---' END
				+CAST([Source] AS CHAR(20))+CAST(LEFT(COALESCE(NAME,''),20)AS CHAR(20))
				+COALESCE(FIX_IT,'')+' '+[Msg]+CHAR(13)+CHAR(10)
		,@TotalFailCount = @TotalFailCount + CASE [severity] WHEN 1 THEN 1 ELSE 0 END
		,@TotalWarnCount = @TotalWarnCount + CASE [severity] WHEN 2 THEN 1 ELSE 0 END
FROM		(
		-- Parameters With Non-Default Values
		-- sys.configurations
		select	st.ParamSource       AS [Source]
			, st.ParamName	     AS [Name]
			, st.ParamValue	     AS [CurrentValue]
			, ct.default_value   AS [DefaultValue]
			, CASE WHEN st.ParamValue LIKE '%*' 
				THEN 'Run Value Does Not Match Config Value, a SQL Restart Might be needed' 
				ELSE '' 
				END AS [Msg] 
			, 'EXEC sp_configure ''' + st.ParamName +''', ' + convert(nvarchar(15),ct.default_value) AS FIX_IT
			, ct.severity 
		from		@configuration_defaults_table ct 
		JOIN		@Settings st
			ON	ct.name = st.ParamName 
			AND	ct.ParamSource = st.ParamSource  
			AND	ct.default_value != st.ParamValue
		WHERE		ct.ParamSource = 'sys.configurations'
		UNION
		-- Extra Trace Flag
		select	st.ParamSource
			, 'Extra TraceFlag (' + st.ParamName + ')'
			, st.ParamValue
			, ''
			, 'Use the -T startup option to specify that the trace flag be set on during startup.' AS [Msg] 
			, 'DBCC TRACEOFF ' + st.ParamName  AS [FIX_IT]
			, ct.severity 
		from		@Settings st
		LEFT JOIN	@configuration_defaults_table ct
			ON	ct.ParamSource = st.ParamSource  
			AND	ct.name = st.ParamName 
		WHERE		st.ParamSource = 'TraceFlag'
			AND	ct.NAME IS NULL
		UNION
		-- Missing Trace Flag
		select	ct.ParamSource
			, 'Missing TraceFlag (' + ct.Name + ')'  
			, ''
			, ct.default_value
			, 'Use the -T startup option to specify that the trace flag be set on during startup.' AS [Msg] 
			, 'DBCC TRACEON ' + ct.Name  AS FIX_IT
			, ct.severity 
		from		@configuration_defaults_table ct 
		LEFT JOIN	@Settings st
			ON	ct.name = st.ParamName 
			AND	ct.ParamSource = st.ParamSource  
		WHERE		ct.ParamSource = 'TraceFlag'		
			AND	st.ParamName IS NULL
		) DATA

IF  @TotalFailCount+@TotalWarnCount = 0	-- RESET MESSAGE TO BE A SUCCESS
	SET @ConfigStatus = @RL1Y+@RL2+@RL3Y

PRINT 	@ConfigStatus


---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- CHECK	PLATFORM
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
SET	@RL2	='PLATFORM'

IF @FileDescription LIKE '%64_bit%'
	BEGIN
		SET @Check_SQL_X64 = 1
		SET @Check_Platform_X64 = 1
		SET @Check_OS_X64 = 1
	END
ELSE
	BEGIN
		SET @Check_SQL_X64 = 0
		IF @Platform LIKE '%64%'
			BEGIN
				SET @Check_Platform_X64 = 1
				SET @Check_OS_X64 = 1
			END
		ELSE
			BEGIN
				SET @Check_Platform_X64 = 0
				SET @Check_OS_X64 = 0
			END
	END

IF	@Check_SQL_X64 = 1
	PRINT	@RL1Y+@RL2+'X64 Version of SQL Deployed on an X64 Platform.'
ELSE
	BEGIN
		IF	@Check_Platform_X64 = 1
		BEGIN
			PRINT	@RL1N+@RL2+'X86 Version of SQL Deployed on an X64 Platform.'
			SET @TotalFailCount = @TotalFailCount + 1
		END
		ELSE
			PRINT	@RL1Y+@RL2+'X86 Version of SQL Deployed on an X86 Platform.'
	END	
	
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- CHECK	SERVICE ACCOUNT
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
SET	@RL2	='SERVICE ACCOUNT'

SELECT @ServiceSQLAcnt = ParamValue FROM @Settings WHERE ParamSource = 'Registry' AND ParamName = 'SQLAccount'

IF @ServiceSQLAcnt IS NULL
BEGIN
	PRINT	@RL1N+@RL2+'Unable to Verify SQL Service Account.'
	SET @TotalFailCount = @TotalFailCount + 1
END

SELECT @ServiceAgentAcnt = ParamValue FROM @Settings WHERE ParamSource = 'Registry' AND ParamName = 'AgentAccount'

IF @ServiceAgentAcnt IS NULL
BEGIN
	PRINT	@RL1N+@RL2+'Unable to Verify Agent Service Account.'
	SET @TotalFailCount = @TotalFailCount + 1
END

IF Suser_Sid(@ServiceSQLAcnt) IS NOT NULL
	PRINT	@RL1Y+@RL2+'The SQL Service Account ('+@ServiceSQLAcnt+') is Valid.'
ELSE
BEGIN
	PRINT	@RL1N+@RL2+'The SQL Service Account ('+@ServiceSQLAcnt+') is NOT Valid.'
	SET @TotalFailCount = @TotalFailCount + 1
END

IF Suser_Sid(@ServiceAgentAcnt) IS NOT NULL
	PRINT	@RL1Y+@RL2+'The Agent Service Account ('+@ServiceAgentAcnt+') is Valid.'
ELSE
BEGIN
	PRINT	@RL1N+@RL2+'The Agent Service Account ('+@ServiceAgentAcnt+') is NOT Valid.'
	SET @TotalFailCount = @TotalFailCount + 1
END
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- CHECK	SERVICE AUTOSTART
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
SET	@RL2	='SERVICE START'

IF @ServiceSQLStart IS NULL
BEGIN
	PRINT	@RL1N+@RL2+'Unable to Verify SQL Service Startup Setting.'
	SET @TotalFailCount = @TotalFailCount + 1
END

IF @ServiceAgentStart IS NULL
BEGIN
	PRINT	@RL1N+@RL2+'Unable to Verify Agent Service Startup Setting.'
	SET @TotalFailCount = @TotalFailCount + 1
END

IF @ServiceSQLStart = '0x2'
	PRINT	@RL1Y+@RL2+'The SQL Service is Set to AutoStart.'
ELSE
BEGIN
	PRINT	@RL1N+@RL2+'The SQL Service is NOT Set to AutoStart.'
	SET @TotalFailCount = @TotalFailCount + 1
END

IF @ServiceAgentStart = '0x2'
	PRINT	@RL1Y+@RL2+'The Agent Service is Set to AutoStart.'
ELSE
BEGIN
	PRINT	@RL1N+@RL2+'The Agent Service is NOT Set to AutoStart.'
	SET @TotalFailCount = @TotalFailCount + 1
END
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- CHECK	SECURITY MODE
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
SET	@RL2 = 'SECURITY MODE'

IF (SELECT ParamValue FROM @Settings WHERE ParamName = 'IsIntegratedSecurityOnly') = 'No'
	PRINT @RL1Y+@RL2+'SQL Server is set for Mixed Security.'
ELSE
BEGIN
	PRINT @RL1N+@RL2+'SQL Server is NOT Set for Mixed Security.'
	SET @TotalFailCount = @TotalFailCount + 1
END
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- CHECK	DBAADMIN
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
SET	@RL2 = 'DBAADMIN'

IF NOT EXISTS(SELECT * FROM @Settings WHERE ParamSource ='sysdatabases' AND ParamName = 'dbaadmin')
	BEGIN
		PRINT @RL1N+@RL2+'dbaadmin Database is not deployed.'
		SET	@Check_DB_dbaadmin	= 0
		SET @TotalFailCount = @TotalFailCount + 1
	END
ELSE
	BEGIN
		PRINT @RL1Y+@RL2+'dbaadmin Database is deployed.'
		SET	@Check_DB_dbaadmin		= 1
	END
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- CHECK	DBAPERF
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
SET	@RL2 = 'DBAPERF'

IF NOT EXISTS(SELECT * FROM @Settings WHERE ParamSource ='sysdatabases' AND ParamName = 'dbaperf')
	BEGIN
		PRINT @RL1N+@RL2+'dbaperf Database is not deployed.'
		SET	@Check_DB_dbaperf	= 0
		SET @TotalFailCount = @TotalFailCount + 1
	END
ELSE
	BEGIN
		PRINT @RL1Y+@RL2+'dbaperf Database is deployed.'
		SET	@Check_DB_dbaperf		= 1
	END

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- CHECK	DEPLINFO
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
SET	@RL2 = 'DEPLINFO'

IF NOT EXISTS(SELECT * FROM @Settings WHERE ParamSource ='sysdatabases' AND ParamName = 'DEPLinfo')
	BEGIN
		PRINT @RL1W+@RL2+'DEPLinfo Database is not deployed.'
		SET	@Check_DB_DEPLinfo	= 0
		SET @TotalWarnCount = @TotalWarnCount + 1
	END
ELSE
	BEGIN
		PRINT @RL1Y+@RL2+'DEPLinfo Database is deployed.'
		SET	@Check_DB_DEPLinfo		= 1
	END
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- CHECK	TEMPDB
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
SET	@RL2 = 'TEMPDB'

IF (SELECT COUNT(*) FROM @Settings WHERE ParamSource ='sysfiles' AND ParamName = 'tempdb_Datafile') = @CPUCount
	PRINT @RL1Y+@RL2+'There is one Data Device per CPU.'
ELSE IF (SELECT COUNT(*) FROM @Settings WHERE ParamSource ='sysfiles' AND ParamName = 'tempdb_Datafile') < @CPUCount
	BEGIN 
	PRINT @RL1W+@RL2+'There are Less Data Devices That CPU''s.'
	SET @TotalWarnCount = @TotalWarnCount + 1
	END
ELSE 
	BEGIN
	PRINT @RL1W+@RL2+'There are More Data Devices That CPU''s.'
	SET @TotalWarnCount = @TotalWarnCount + 1
	END
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- CHECK	AGENTHISTORY
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
SET	@RL2 = 'AGENTHISTORY'

SELECT @TempValue = [default_value]  FROM @configuration_defaults_table WHERE [ParamSource] = 'JobHistory' and [name] = 'jobhistory_max_rows'
IF @jobhistory_max_rows >= @TempValue
	PRINT @RL1Y+@RL2+'Job History Max Rows is '+@TempValue+' or More.'
ELSE
BEGIN
	PRINT @RL1N+@RL2+'Job History Max Rows is Less than '+@TempValue+'.'
	SET @TotalFailCount = @TotalFailCount + 1
END

SELECT @TempValue = [default_value]  FROM @configuration_defaults_table WHERE [ParamSource] = 'JobHistory' and [name] = 'jobhistory_max_rows_per_job'
IF @jobhistory_max_rows_per_job >= @TempValue
	PRINT @RL1Y+@RL2+'Job History Max Rows Per Job is '+@TempValue+' or More.'
ELSE
BEGIN
	PRINT @RL1N+@RL2+'Job History Max Rows Per Job is Less than '+@TempValue+'.'
	SET @TotalFailCount = @TotalFailCount + 1
END
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- CHECK	DBAADMIN SPECIFIC CHECKS
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
IF @Check_DB_dbaadmin = 1
BEGIN
	---------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------
	-- CHECK	UTIL-JOB
	---------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------
	SET	@RL2 = 'UTIL-JOB'
	
	----------------------------------------------
	----------------------------------------------	
	-- Job Check Loop:
	-- This Code Chunk Checks for the existance
	-- of the Job and then checks to see If its 
	-- last run was successfull. It will also
	-- wait if the job is currently running for
	-- about 10 Minutes.
	----------------------------------------------	
	----------------------------------------------	
	SET @JobName = 'UTIL - DBA Nightly Processing'
	IF EXISTS (SELECT * FROM @Settings WHERE ParamSource ='sysjobs' AND ParamName = @JobName)
	BEGIN
		IF (SELECT dbo.RP(ParamValue,1) FROM @Settings WHERE ParamSource ='sysjobs' AND ParamName = @JobName) = 1
			PRINT @RL1Y+@RL2+@JobName+' is deployed and enabled.'
		ELSE
		BEGIN
			PRINT @RL1N+@RL2+@JobName+' is deployed but not enabled.'
			SET @TotalFailCount = @TotalFailCount + 1
		END
	END			
	ELSE
	BEGIN
		PRINT @RL1N+@RL2+@JobName+' is not deployed.'
		SET @TotalFailCount = @TotalFailCount + 1
	END
	
	SET @LoopCnt = 1
	WHILE @LoopCnt < 11 AND (SELECT dbo.RP(ParamValue,2) FROM @Settings WHERE ParamSource ='sysjobs' AND ParamName = @JobName) = 'In Progress'
	BEGIN
		SET @LoopCnt = @LoopCnt + 1
		DELETE @Settings WHERE ParamSource ='sysjobs' AND ParamName = @JobName
		INSERT INTO @Settings
		SELECT		'sysjobs'
				,SJ.Name
				,CAST(SJ.Enabled AS CHAR(1)) + '|'
				+CASE COALESCE((SELECT TOP 1 run_status FROM msdb..sysjobhistory WHERE job_id = sj.job_id ORDER BY run_date DESC,run_time DESC),'-1')
					WHEN '-1' THEN 'Never Run'
					WHEN '0' THEN 'Failed'
					WHEN '1' THEN 'Succeeded'
					WHEN '2' THEN 'Retry'
					WHEN '3' THEN 'Cancled'
					WHEN '4' THEN 'In Progress'
					ELSE 'Unknown'
					END + '|'
				+COALESCE(CONVERT(VARCHAR(50),(SELECT TOP 1 CONVERT(DATETIME, RTRIM(run_date))+(run_time * 9 + run_time % 10000 * 6 + run_time % 100 * 10) / 216e4 FROM msdb..sysjobhistory WHERE job_id = sj.job_id ORDER BY run_date DESC,run_time DESC),120),'')+'|'
				+COALESCE((SELECT TOP 1 STUFF(STUFF(RIGHT('000000' + CONVERT(varchar(6), run_duration), 6),3,0,':'),6,0,':') FROM msdb..sysjobhistory WHERE job_id = sj.job_id ORDER BY run_date DESC,run_time DESC),'')
		FROM		msdb..sysjobs sj
		WHERE		sj.name = @JobName
	
		IF (SELECT dbo.RP(ParamValue,2) FROM @Settings WHERE ParamSource ='sysjobs' AND ParamName = @JobName) = 'In Progress'
			WAITFOR DELAY '01:00'
	END	
	
	IF (SELECT dbo.RP(ParamValue,2) FROM @Settings WHERE ParamSource ='sysjobs' AND ParamName = @JobName) = 'Succeeded'
		PRINT @RL1Y+@RL2+@JobName+' most recent run succeded.'
	ELSE
	BEGIN
		SELECT @result_value = dbo.RP(ParamValue,2) FROM @Settings WHERE ParamSource ='sysjobs' AND ParamName = @JobName
		PRINT @RL1N+@RL2+@JobName+' most recent run status was ('+@result_value+').'
		SET @TotalFailCount = @TotalFailCount + 1
	END

	SET @JobName = 'UTIL - DBA Archive Process'
	IF EXISTS (SELECT * FROM @Settings WHERE ParamSource ='sysjobs' AND ParamName = @JobName)
	BEGIN
		IF (SELECT dbo.RP(ParamValue,1) FROM @Settings WHERE ParamSource ='sysjobs' AND ParamName = @JobName) = 1
			PRINT @RL1Y+@RL2+@JobName+' is deployed and enabled.'
		ELSE
		BEGIN
			PRINT @RL1N+@RL2+@JobName+' is deployed but not enabled.'
			SET @TotalFailCount = @TotalFailCount + 1
		END
	END			
	ELSE
	BEGIN
		PRINT @RL1N+@RL2+@JobName+' is not deployed.'
		SET @TotalFailCount = @TotalFailCount + 1
	END
	
	SET @LoopCnt = 1
	WHILE @LoopCnt < 11 AND (SELECT dbo.RP(ParamValue,2) FROM @Settings WHERE ParamSource ='sysjobs' AND ParamName = @JobName) = 'In Progress'
	BEGIN
		SET @LoopCnt = @LoopCnt + 1
		DELETE @Settings WHERE ParamSource ='sysjobs' AND ParamName = @JobName
		INSERT INTO @Settings
		SELECT		'sysjobs'
				,SJ.Name
				,CAST(SJ.Enabled AS CHAR(1)) + '|'
				+CASE COALESCE((SELECT TOP 1 run_status FROM msdb..sysjobhistory WHERE job_id = sj.job_id ORDER BY run_date DESC,run_time DESC),'-1')
					WHEN '-1' THEN 'Never Run'
					WHEN '0' THEN 'Failed'
					WHEN '1' THEN 'Succeeded'
					WHEN '2' THEN 'Retry'
					WHEN '3' THEN 'Cancled'
					WHEN '4' THEN 'In Progress'
					ELSE 'Unknown'
					END + '|'
				+COALESCE(CONVERT(VARCHAR(50),(SELECT TOP 1 CONVERT(DATETIME, RTRIM(run_date))+(run_time * 9 + run_time % 10000 * 6 + run_time % 100 * 10) / 216e4 FROM msdb..sysjobhistory WHERE job_id = sj.job_id ORDER BY run_date DESC,run_time DESC),120),'')+'|'
				+COALESCE((SELECT TOP 1 STUFF(STUFF(RIGHT('000000' + CONVERT(varchar(6), run_duration), 6),3,0,':'),6,0,':') FROM msdb..sysjobhistory WHERE job_id = sj.job_id ORDER BY run_date DESC,run_time DESC),'')
		FROM		msdb..sysjobs sj
		WHERE		sj.name = @JobName
	
		IF (SELECT dbo.RP(ParamValue,2) FROM @Settings WHERE ParamSource ='sysjobs' AND ParamName = @JobName) = 'In Progress'
			WAITFOR DELAY '01:00'
	END	
	
	IF (SELECT dbo.RP(ParamValue,2) FROM @Settings WHERE ParamSource ='sysjobs' AND ParamName = @JobName) = 'Succeeded'
		PRINT @RL1Y+@RL2+@JobName+' most recent run succeded.'
	ELSE
	BEGIN
		SELECT @result_value = dbo.RP(ParamValue,2) FROM @Settings WHERE ParamSource ='sysjobs' AND ParamName = @JobName
		PRINT @RL1N+@RL2+@JobName+' most recent run status was ('+@result_value+').'
		SET @TotalFailCount = @TotalFailCount + 1
	END
	---------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------
	-- CHECK	SHARES	
	---------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------
	SET	@RL2 = 'SHARES'
	SET	@RL3Y	='All Config Options are correct.'
	SET	@RL3N	='The Following config options are not correct.'
	SET	@ConfigStatus = ''
	SET	@Check_Shares = 1
	SET	@ConfigStatus = ''
	
	SELECT		@ConfigStatus	= @ConfigStatus
					+ CASE c.severity when 1 then @RL1N else @RL1W end
					+ @RL2
					+ ParamName + ' Share is not valid.'
					+ CHAR(13) + CHAR(10)
			,@TotalFailCount = @TotalFailCount + CASE c.severity WHEN 1 THEN 1 ELSE 0 END
			,@TotalWarnCount = @TotalWarnCount + CASE c.severity WHEN 2 THEN 1 ELSE 0 END
	FROM		@Settings s
	JOIN		@configuration_defaults_table c
		on	s.ParamName = c.name 
		and	s.ParamSource = c.ParamSource
	WHERE		s.ParamSource = 'Shares'
		AND	s.ParamValue IS NULL
		
	SET @LoopCnt = @@ROWCOUNT

	IF  @LoopCnt = 0	-- RESET MESSAGE TO BE A SUCCESS
		SET @ConfigStatus = @RL1Y+@RL2+'All Shares are Valid.'

	PRINT 	@ConfigStatus
END	
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- CHECK	RESOURCE KIT
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
SET	@RL2 = 'RESOURCE KIT'

IF EXISTS (SELECT * FROM @Settings WHERE ParamSource = 'Files' AND ParamName = 'rmtshare' AND ParamValue IS NULL)
BEGIN
	PRINT @RL1N+@RL2+'Resource Kit is NOT Installed.'
	SET @TotalFailCount = @TotalFailCount + 1
END
ELSE
	PRINT @RL1Y+@RL2+'Resource Kit is Installed.'
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- CHECK	WINZIP
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
SET	@RL2 = 'WINZIP'
	
IF EXISTS (SELECT * FROM @Settings WHERE ParamSource = 'Files' AND ParamName = 'winzip32' AND ParamValue IS NULL)
BEGIN
	PRINT @RL1N+@RL2+'WinZip is NOT Installed.'
	SET @TotalFailCount = @TotalFailCount + 1
END
ELSE
	PRINT @RL1Y+@RL2+'WinZip is Installed.'
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- CHECK	REDGATE BACKUP
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
SET	@RL2 = 'REDGATE BACKUP'
	
IF EXISTS (SELECT * FROM @Settings WHERE ParamSource = 'Files' AND ParamName = 'RedGateBackup1' AND ParamValue IS NULL)
BEGIN
	IF EXISTS (SELECT * FROM @Settings WHERE ParamSource = 'Files' AND ParamName = 'RedGateBackup2' AND ParamValue IS NULL)
	BEGIN
		PRINT @RL1W+@RL2+'RedGate Backup is NOT Installed.'
		SET @TotalWarnCount = @TotalWarnCount + 1
	END
	ELSE
		PRINT @RL1Y+@RL2+'RedGate Backup is Installed.'
END
ELSE
	PRINT @RL1Y+@RL2+'RedGate Backup is Installed.'
	
	
IF EXISTS (SELECT * from MASTER.dbo.sysobjects WHERE NAME = 'sqbutility')
	PRINT @RL1Y+@RL2+'Redgate Backup is Configured.'
ELSE
BEGIN
	PRINT @RL1W+@RL2+'Redgate Backup is NOT Configured.'
	SET @TotalWarnCount = @TotalWarnCount + 1
END
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
AbortFailedCriticalChecks:
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- END OF CHECKS
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
PRINT	''
PRINT	''
PRINT	'Total Failures	:' + CAST(@TotalFailCount as VarChar(50))
PRINT	'Total Warnings	:' + CAST(@TotalWarnCount as VarChar(50))


IF    @TotalFailCount > 0 AND @OutputType = 2
BEGIN
    RAISERROR ('SQL Post Install Validation Failed',16,1)
END

ELSE IF    @OutputType = 1
SELECT @TotalFailCount [Total Failures], @TotalWarnCount [Total Warnings]
-- THIS WOULD ALSO BE THE SPROC RETURN CODE

	
ELSE IF    @OutputType = 3
SELECT * FROM @settings ORDER BY 1,2,3

GO
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- DROP TEMP OBJECTS
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
DROP TABLE	#FileExists
GO
DROP TABLE	#XP_MSVER_RESULTS
GO
DROP FUNCTION	[RP]
GO

USE dbaadmin
GO
PRINT	''
PRINT	''


exec dbaadmin.dbo.dbasp_PivotResults 'DBA_ServerInfo'

exec dbaadmin.dbo.dbasp_PivotResults 'DBA_ClusterInfo'

exec dbaadmin.dbo.dbasp_PivotResults 'DBA_DiskPerfInfo'

DECLARE @DriveName VarChar(50)
DECLARE DiskCursor 
CURSOR
FOR
SELECT DISTINCT 'DriveName = '''+DriveName+'''' FROM DBA_DiskInfo

OPEN DiskCursor
FETCH NEXT FROM DiskCursor INTO @DriveName
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		exec dbaadmin.dbo.dbasp_PivotResults 'DBA_DiskInfo',@DriveName
	END
	FETCH NEXT FROM DiskCursor INTO @DriveName
END

CLOSE DiskCursor
DEALLOCATE DiskCursor


exec sp_msforeachdb 'exec dbaadmin.dbo.dbasp_PivotResults ''DBA_DBInfo'',''DBName = ''''?'''''''

exec sp_msforeachdb 'exec dbaadmin.dbo.dbasp_PivotResults ''DBA_UserLoginInfo'',''DBName = ''''?'''''''

GO


