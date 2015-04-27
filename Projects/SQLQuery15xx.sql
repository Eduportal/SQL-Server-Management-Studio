



DECLARE @spid int 
DECLARE @handle binary(20) 
SET @spid = (SELECT top 1 SPID from master..sysprocesses order by last_batch desc) 
SET @handle = (SELECT sql_handle from master..sysprocesses where spid = @spid) 
SELECT text FROM ::fn_get_sql(@Handle)



select sq.text,r.* from sys.dm_exec_requests r 
CROSS APPLY sys.dm_exec_sql_text(sql_handle) sq 
join sys.dm_exec_sessions s 
on r.session_id = s.session_id 
where r.session_id >50 
and r.session_id not in (Select @@spid) 
order by s.last_request_start_time desc




--SELECT		LEFT(CAST(convert(sysname, serverproperty('ProductVersion')) AS VarChar(255)),1) 
--			,CAST(convert(sysname, serverproperty('ProductVersion')) AS VarChar(255))
--			,CAST(convert(sysname, [cmptlevel]) AS VarChar(255))
--From		sysdatabases 
--WHERE		dbid = 1


--CREATE TABLE #TempDBSpace(KB INT)
--exec sp_msforeachdb '
--INSERT INTO #TempDBSpace
--EXEC (''DBCC CHECKDB (?) WITH ESTIMATEONLY'')
--'
--SELECT SUM(KB) [KBNeeded] From #TempDBSpace
--GO
--DROP TABLE #TempDBSpace
--GO


--DBCC CHECKDB (ACAT) WITH ESTIMATEONLY
--DBCC CHECKDB (AIMS) WITH ESTIMATEONLY
--DBCC CHECKDB (Assignments) WITH ESTIMATEONLY
--DBCC CHECKDB (Assignments_Test) WITH ESTIMATEONLY
--DBCC CHECKDB (BkupReports) WITH ESTIMATEONLY
--DBCC CHECKDB (BundledProduct) WITH ESTIMATEONLY
--DBCC CHECKDB (DAP) WITH ESTIMATEONLY
--DBCC CHECKDB (DAPwork) WITH ESTIMATEONLY
--DBCC CHECKDB (dbaadmin) WITH ESTIMATEONLY
--DBCC CHECKDB (dbaadmin_seafresql02) WITH ESTIMATEONLY
--DBCC CHECKDB (DEPLinfo) WITH ESTIMATEONLY
--DBCC CHECKDB (EARepository) WITH ESTIMATEONLY
--DBCC CHECKDB (eds) WITH ESTIMATEONLY
--DBCC CHECKDB (eXpress) WITH ESTIMATEONLY
--DBCC CHECKDB (HADS) WITH ESTIMATEONLY
--DBCC CHECKDB (iLoc) WITH ESTIMATEONLY
--DBCC CHECKDB (integrity) WITH ESTIMATEONLY
--DBCC CHECKDB (Localizer) WITH ESTIMATEONLY
--DBCC CHECKDB (Marcom) WITH ESTIMATEONLY
--DBCC CHECKDB (master) WITH ESTIMATEONLY
--DBCC CHECKDB (mell) WITH ESTIMATEONLY
--DBCC CHECKDB (model) WITH ESTIMATEONLY
--DBCC CHECKDB (msdb) WITH ESTIMATEONLY
--DBCC CHECKDB (Objectname_ID) WITH ESTIMATEONLY
--DBCC CHECKDB (Reports_work) WITH ESTIMATEONLY
--DBCC CHECKDB (systeminfo) WITH ESTIMATEONLY
--DBCC CHECKDB (tempdb) WITH ESTIMATEONLY
--DBCC CHECKDB (usability) WITH ESTIMATEONLY
--DBCC CHECKDB (usability_test) WITH ESTIMATEONLY



--USE [dbaadmin]
--GO

--/****** Object:  UserDefinedFunction [dbo].[dbaudf_ListDrives]    Script Date: 10/11/2011 12:29:17 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_ListDrives]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
--BEGIN
--execute dbo.sp_executesql @statement = N'

--CREATE FUNCTION [dbo].[dbaudf_ListDrives]()
--RETURNS @DriveList Table
--		(
--		[DriveLetter]		CHAR(1)
--		,[TotalSize]		BigInt
--		,[AvailableSpace]	BigInt
--		,[FreeSpace]		BigInt
--		,[DriveType]		VarChar(50)
--		,[SerialNumber]		VarChar(50)
--		,[FileSystem]		VarChar(50)
--		,[IsReady]		VarChar(50)
--		,[ShareName]		VarChar(255)
--		,[VolumeName]		VarChar(255)
--		,[Path]			VarChar(2048)
--		,[RootFolder]		VarChar(2048)
--		)
--AS
--BEGIN

--	DECLARE @DriveLoop	INT
--	DECLARE @fso		Int
--	DECLARE @DriveCount	INT
--	DECLARE @Drives		Int
--	DECLARE @Drive		Int
--	DECLARE @Property	nVarChar(100)
--	DECLARE @Results	VarChar(8000)
--	DECLARE @Results_int	bigint
--	DECLARE @hr		int
--	DECLARE @RetryCount	int

--	SET	@DriveLoop	= 65
	
	
--	step1:
--	SET	@RetryCount	= 0
--	exec	@hr		= sp_OACreate ''Scripting.FileSystemObject'', @fso OUT
--	IF @hr != 0 
--	BEGIN
--		SET @RetryCount = @RetryCount + 1
--		IF @RetryCount > 5 
--		BEGIN
--			INSERT INTO @DriveList ([DriveLetter],[DriveType],[Path]) VALUES(''!'',@hr,''ERROR CREATING Scripting.FileSystemObject'')
--			RETURN
--		END
--		goto step1
--	END

--	step2:
--	SET	@RetryCount	= 0
--	exec	@hr		= sp_OAGetProperty @fso,''Drives'', @Drives OUT
--	IF @hr != 0 
--	BEGIN
--		SET @RetryCount = @RetryCount + 1
--		IF @RetryCount > 5 
--		BEGIN
--			INSERT INTO @DriveList ([DriveLetter],[DriveType],[Path]) VALUES(''!'',@hr,''ERROR GETTING Drives'')
--			RETURN
--		END
--		goto step2
--	END


--	step3:
--	SET	@RetryCount	= 0
--	exec	@hr		= sp_OAGetProperty @Drives,''Count'', @DriveCount OUT
--	IF @hr != 0 
--	BEGIN
--		SET @RetryCount = @RetryCount + 1
--		IF @RetryCount > 5 
--		BEGIN
--			INSERT INTO @DriveList ([DriveLetter],[DriveType],[Path]) VALUES(''!'',@hr,''ERROR GETTING Drives.Count'')
--			RETURN
--		END
--		goto step3
--	END
		
	
--	WHILE @DriveLoop < 91
--	BEGIN
--		SET @Property = ''item("''+CHAR(@DriveLoop)+''")''
--		exec sp_OAGetProperty @Drives,@Property, @Drive OUT
--		exec sp_OAGetProperty @Drive,''DriveLetter'', @Results OUT
--		IF @Results = CHAR(@DriveLoop)
--		BEGIN
--			INSERT INTO @DriveList ([DriveLetter]) VALUES(@Results)

--			exec sp_OAGetProperty @Drive,''TotalSize''	, @Results_int OUT; UPDATE @DriveList SET [TotalSize]		= @Results_int WHERE [DriveLetter] = CHAR(@DriveLoop)
--			exec sp_OAGetProperty @Drive,''AvailableSpace''	, @Results_int OUT; UPDATE @DriveList SET [AvailableSpace]	= @Results_int WHERE [DriveLetter] = CHAR(@DriveLoop)
--			exec sp_OAGetProperty @Drive,''FreeSpace''	, @Results_int OUT; UPDATE @DriveList SET [FreeSpace]		= @Results_int WHERE [DriveLetter] = CHAR(@DriveLoop)
--			exec sp_OAGetProperty @Drive,''DriveType''	, @Results OUT; UPDATE @DriveList SET [DriveType]	= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
--			exec sp_OAGetProperty @Drive,''SerialNumber''	, @Results OUT; UPDATE @DriveList SET [SerialNumber]	= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
--			exec sp_OAGetProperty @Drive,''FileSystem''	, @Results OUT; UPDATE @DriveList SET [FileSystem]	= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
--			exec sp_OAGetProperty @Drive,''IsReady''		, @Results OUT; UPDATE @DriveList SET [IsReady]		= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
--			exec sp_OAGetProperty @Drive,''ShareName''	, @Results OUT; UPDATE @DriveList SET [ShareName]	= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
--			exec sp_OAGetProperty @Drive,''VolumeName''	, @Results OUT; UPDATE @DriveList SET [VolumeName]	= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
--			exec sp_OAGetProperty @Drive,''Path''		, @Results OUT; UPDATE @DriveList SET [Path]		= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
--			exec sp_OAGetProperty @Drive,''RootFolder''	, @Results OUT; UPDATE @DriveList SET [RootFolder]	= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			
--		END
--		SET @DriveLoop = @DriveLoop +1
--	END	

--	RETURN
--END

--' 
--END

GO



use tempdb

go

-- Drive Space Script

-- By Gonzalo Moles 11 September 2011

BEGIN

SET NOCOUNT ON

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE [Id] = OBJECT_ID('tempdb..DBFileInfo'))
	DROP TABLE DBFileInfo

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE [Id] = OBJECT_ID('Tempdb..#LogSizeStats'))
	DROP TABLE #LogSizeStats

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE [Id] = OBJECT_ID('Tempdb..#DataFileStats'))
	DROP TABLE #DataFileStats

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE [Id] = OBJECT_ID('Tempdb..#FixedDrives'))
	DROP TABLE #FixedDrives

--IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE [Id] = OBJECT_ID('Tempdb..#Temporal'))
--BEGIN
--DROP TABLE #Temporal
--END

select * From dbaadmin.dbo.dbaudf_ListDrives()
exec master..xp_fixeddrives

CREATE TABLE #FixedDrives 
(DriveLetter VARCHAR(10), 
MB_Free DEC(20,2))

CREATE TABLE #DataFileStats 
(DBName VARCHAR(255), 
DBId INT,
FileId TINYINT, 
[FileGroup] TINYINT, 
TotalExtents DEC(20,2),
UsedExtents DEC(20,2),
[Name] VARCHAR(255), 
[FileName] VARCHAR(400))

CREATE TABLE #LogSizeStats -- DBCC SQLPERF -- Provides statistics about how the transaction-log space was used in all databases. It can also be used to reset wait and latch statistics.
(DBName VARCHAR(255) NOT NULL PRIMARY KEY CLUSTERED, -- Database Name -- Name of the database for the log statistics displayed.
DBId INT,
LogFile REAL, -- Log Size (MB) -- Actual amount of space available for the log. This amount is smaller than the amount originally allocated for log space because the SQL Server 2005 Database Engine reserves a small amount of disk space for internal header information.
LogFileUsed REAL, -- Log Space Used (%) -- Percentage of the log file currently occupied with transaction log information.
Status BIT) -- Status -- Status of the log file. Always 0.

CREATE TABLE DBFileInfo
([ServerName] VARCHAR(255),
[DBName] VARCHAR(65),
[LogicalFileName] VARCHAR(400),
[UsageType] VARCHAR (30),
[Size_MB] DEC(20,2), 
[SpaceUsed_MB] DEC(20,2),
[MaxSize_MB] DEC(20,2),
[NextAllocation_MB] DEC(20,2), 
[GrowthType] VARCHAR(65),
[FileId] SMALLINT,
[GroupId] SMALLINT,
[PhysicalFileName] VARCHAR(400),
[DateChecked] DATETIME) 


DECLARE @SQLString VARCHAR(3000)
DECLARE @MinId INT
DECLARE @MaxId INT
DECLARE @DBName VARCHAR(255)

DECLARE @tblDBName TABLE
(RowId INT IDENTITY(1,1),
DBName VARCHAR(255),
DBId INT)

INSERT INTO @tblDBName (DBName,DBId)
SELECT [Name],DBId FROM master..sysdatabases WHERE (Status & 512) = 0 /*NOT IN (536,528,540,2584,1536,512,4194841)*/ ORDER BY [Name]


INSERT INTO #LogSizeStats (DBName,LogFile,LogFileUsed,Status)
EXEC ('DBCC SQLPERF(LOGSPACE) WITH NO_INFOMSGS')


UPDATE #LogSizeStats 
SET DBId = DB_ID(DBName)


INSERT INTO #FixedDrives EXEC master..xp_fixedDrives


SELECT @MinId = MIN(RowId),
@MaxId = MAX(RowId)
FROM @tblDBName

WHILE (@MinId <= @MaxId)
BEGIN
SELECT @DBName = [DBName]
FROM @tblDBName
WHERE RowId = @MinId

SELECT @SQLString =
'SELECT ServerName = @@SERVERNAME,'+
' DBName = '''+@DBName+''','+
' LogicalFileName = [name],'+
' UsageType = CASE WHEN (64&[status])=64 THEN ''Log'' ELSE ''Data'' END,'+
' Size_MB = [size]*8/1024.00,'+
' SpaceUsed_MB = NULL,'+
-- 20081125 Arithmetic overflow error converting expression to data type int.
-- ' MaxSize_MB = CASE [maxsize] WHEN -1 THEN -1 WHEN 0 THEN [size]*8/1024.00 ELSE maxsize*8/1024.00 END,'+
' MaxSize_MB = CASE [maxsize] WHEN -1 THEN -1 WHEN 0 THEN [size]*8/1024.00 ELSE maxsize/1024.00*8 END,'+
-- 20081125 end
' NextExtent_MB = CASE WHEN (1048576&[status])=1048576 THEN ([growth]/100.00)*([size]*8/1024.00) WHEN [growth]=0 THEN 0 ELSE [growth]*8/1024.00 END,'+
' GrowthType = CASE WHEN (1048576&[status])=1048576 THEN ''%'' ELSE ''Pages'' END,'+
' FileId = [fileid],'+
' GroupId = [groupid],'+
' PhysicalFileName= [filename],'+
' CurTimeStamp = GETDATE()'+
-- 20081125 begin @DBName embedded spaces
-- 'FROM '+@DBName+'..sysfiles' 
'FROM ['+@DBName+']..sysfiles' 
-- 20081125 end


INSERT INTO DBFileInfo
EXEC (@SQLString)

UPDATE DBFileInfo
-- 20081125 begin LogFileUsed is %
-- SET SpaceUsed_MB = (SELECT LogFileUsed FROM #LogSizeStats WHERE DBName = @DBName)
SET SpaceUsed_MB = Size_MB / 100.0 * (SELECT LogFileUsed FROM #LogSizeStats WHERE DBName = @DBName)
-- 20081125 end
WHERE UsageType = 'Log'
AND DBName = @DBName 

-- 20081125 begin @DBName embedded spaces
-- SELECT @SQLString = 'USE ' + @DBName + ' DBCC SHOWFILESTATS WITH NO_INFOMSGS'
SELECT @SQLString = 'USE [' + @DBName + '] DBCC SHOWFILESTATS WITH NO_INFOMSGS'
-- 20081125 end

INSERT #DataFileStats (FileId,[FileGroup],TotalExtents,UsedExtents,[Name],[FileName])
EXECUTE(@SQLString)

UPDATE DBFileInfo
SET [SpaceUsed_MB] = S.[UsedExtents]*64/1024.00
FROM DBFileInfo AS F
INNER JOIN #DataFileStats AS S
ON F.[FileId] = S.[FileId]
AND F.[GroupId] = S.[FileGroup]
AND F.[DBName] = @DBName

TRUNCATE TABLE #DataFileStats


SELECT @MinId = @MinId + 1
END

SELECT

SUBSTRING(A.PhysicalFileName,1,1) as DiskUnit,
count(*) as totalfiles,
sum([Size_MB] - [SpaceUsed_MB]) as total_databases_disk_space_free,
sum ([NextAllocation_MB]) as total_databases_next_grow,
sum(B.MB_Free)/count(*) AS FreeSpaceInDrive,
sum([Size_MB] - [SpaceUsed_MB]) - sum ([NextAllocation_MB]) as alert_switch


--into #Temporal

FROM DBFileInfo AS A
LEFT JOIN #FixedDrives AS B
ON SUBSTRING(A.PhysicalFileName,1,1) = B.DriveLetter
group by SUBSTRING(A.PhysicalFileName,1,1) 
ORDER BY SUBSTRING(A.PhysicalFileName,1,1)

--select [DiskUnit], [totalfiles], [total_databases_disk_space_free], [total_databases_next_grow],[FreeSpaceInDrive],[alert_switch], ([FreeSpaceInDrive] - [alert_switch]) as Will_be_free_on_drive from #temporal where [alert_switch] < 0

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE [Id] = OBJECT_ID('Tempdb..DBFileInfo'))
	DROP TABLE DBFileInfo

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE [Id] = OBJECT_ID('Tempdb..#LogSizeStats'))
	DROP TABLE #LogSizeStats

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE [Id] = OBJECT_ID('Tempdb..#DataFileStats'))
	DROP TABLE #DataFileStats

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE [Id] = OBJECT_ID('Tempdb..#FixedDrives'))
	DROP TABLE #FixedDrives



--IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE [Id] = OBJECT_ID('Tempdb..#Temporal'))
--DROP TABLE #Temporal


-- 20081125 begin SET NOCOUNT OFF
SET NOCOUNT OFF
-- 20081125 end
END



