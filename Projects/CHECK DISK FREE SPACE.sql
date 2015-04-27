 
:SETVAR	SQLCMD_UserSettings "\SQLCMD_UserSettings.sql"
:SETVAR SQLCMD_GlobalSettings "\\seafresqldba01\DBA_Docs\SQLCMD_GlobalSettings.sql"
GO
:ON ERROR IGNORE
GO
-- DECLARE AND SET USER VARIABLES
:r $(USERPROFILE)$(SQLCMD_UserSettings)
GO
-- DECLARE AND SET GLOBAL VARIABLES
:r $(SQLCMD_GlobalSettings)
GO
 

--:Connect SEADCPCSQLA\A,1996  -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)
:CONNECT SEAFRESQLRPT01

USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetFileProperty]    Script Date: 06/04/2010 17:41:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetFileProperty]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

CREATE FUNCTION [dbo].[dbaudf_GetFileProperty] (@filename varchar(8000),@GetAs VarChar(50),@property VarChar(255))
RETURNS VarChar(2048)
AS
BEGIN
    DECLARE @rv int 
    DECLARE @fso int 
    DECLARE @file int 
    DECLARE @Results VarChar(2048) 
    
    IF @GetAs NOT IN (
			''File''
			,''Folder''
			,''Drive''
			)
    BEGIN
	SET @Results = @GetAs +'' is Not A Valid @GetAs Value. Use File, Folder, or Drive.''
	RETURN @Results
    END	
        
    IF (@GetAs = ''File'' AND @property NOT IN	(
						''Drive''
						,''ParentFolder''
						,''Path''
						,''ShortPath''
						,''Name''
						,''ShortName''						
						,''Type''
						,''DateCreated''
						,''DateLastAccessed''
						,''DateLastModified''
						,''Attributes''
						,''size''
						))
    OR (@GetAs = ''Folder'' AND @property NOT IN	(
						''Drive''
						,''ParentFolder''
						,''Path''
						,''ShortPath''
						,''Name''
						,''ShortName''						
						,''Type''
						,''DateCreated''
						,''DateLastAccessed''
						,''DateLastModified''
						,''Attributes''
						,''Size''
						,''Files''
						,''SubFolders''
						,''IsRootFolder''
						))
												
    OR (@GetAs = ''Drive'' AND @property NOT IN	(
						''TotalSize''
						,''AvailableSpace''
						,''FreeSpace''
						,''DriveLetter''
						,''DriveType''
						,''SerialNumber''
						,''FileSystem''
						,''IsReady''
						,''ShareName''
						,''VolumeName''
						,''Path''
						,''RootFolder''
						))						
    BEGIN
	SET @Results = ''"''+ @property +''" is Not A Valid @Property Name with the "''+@GetAs+''" @GetAs Value.''
	RETURN @Results
    END			
        
    EXEC @rv = sp_OACreate ''Scripting.FileSystemObject'', @fso OUT 
    IF @rv = 0
    BEGIN 
	SET @GetAs =	CASE @GetAs
			WHEN ''File''	THEN ''GetFile''
			WHEN ''Folder''	THEN ''GetFolder''
			WHEN ''Drive''	THEN ''GetDrive''
			END
			
	EXEC @rv = sp_OAMethod @fso, @GetAs, @file OUT, @filename
	IF @rv = 0
	BEGIN
		EXEC @rv = sp_OAGetProperty @file, @Property, @Results OUT
		EXEC @rv = sp_OADestroy @file 
	END 
        EXEC @rv = sp_OADestroy @fso 
    END
    RETURN @Results
END

' 
END

GO
USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_ListDrives]    Script Date: 06/04/2010 23:56:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_ListDrives]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_ListDrives]()
RETURNS @DriveList Table
		(
		[DriveLetter]		CHAR(1)
		,[TotalSize]		BigInt
		,[AvailableSpace]	BigInt
		,[FreeSpace]		BigInt
		,[DriveType]		VarChar(50)
		,[SerialNumber]		VarChar(50)
		,[FileSystem]		VarChar(50)
		,[IsReady]		VarChar(50)
		,[ShareName]		VarChar(255)
		,[VolumeName]		VarChar(255)
		,[Path]			VarChar(2048)
		,[RootFolder]		VarChar(2048)
		)
AS
BEGIN

	DECLARE @DriveLoop	INT
	DECLARE @fso		Int
	DECLARE @DriveCount	INT
	DECLARE @Drives		Int
	DECLARE @Drive		Int
	DECLARE @Property	nVarChar(100)
	DECLARE @Results	VarChar(8000)
	DECLARE @Results_int	bigint

	SET @DriveLoop = 65

	exec sp_OACreate ''Scripting.FileSystemObject'', @fso OUT
	exec sp_OAGetProperty @fso,''Drives'', @Drives OUT
	exec sp_OAGetProperty @Drives,''Count'', @DriveCount OUT

	WHILE @DriveLoop < 91
	BEGIN
		SET @Property = ''item("''+CHAR(@DriveLoop)+''")''
		--SET @Property = ''Drives.item("A").DriveLetter''
		--exec sp_OAGetProperty @fso,@Property, @Results OUT
		exec sp_OAGetProperty @Drives,@Property, @Drive OUT
		exec sp_OAGetProperty @Drive,''DriveLetter'', @Results OUT
		IF @Results = CHAR(@DriveLoop)
		BEGIN
			INSERT INTO @DriveList ([DriveLetter]) VALUES(@Results)

			exec sp_OAGetProperty @Drive,''TotalSize''	, @Results_int OUT; UPDATE @DriveList SET [TotalSize]		= @Results_int WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,''AvailableSpace''	, @Results_int OUT; UPDATE @DriveList SET [AvailableSpace]	= @Results_int WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,''FreeSpace''	, @Results_int OUT; UPDATE @DriveList SET [FreeSpace]		= @Results_int WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,''DriveType''	, @Results OUT; UPDATE @DriveList SET [DriveType]	= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,''SerialNumber''	, @Results OUT; UPDATE @DriveList SET [SerialNumber]	= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,''FileSystem''	, @Results OUT; UPDATE @DriveList SET [FileSystem]	= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,''IsReady''		, @Results OUT; UPDATE @DriveList SET [IsReady]		= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,''ShareName''	, @Results OUT; UPDATE @DriveList SET [ShareName]	= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,''VolumeName''	, @Results OUT; UPDATE @DriveList SET [VolumeName]	= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,''Path''		, @Results OUT; UPDATE @DriveList SET [Path]		= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,''RootFolder''	, @Results OUT; UPDATE @DriveList SET [RootFolder]	= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			
		END
		SET @DriveLoop = @DriveLoop +1
	END	

	RETURN
END
' 
END

GO





----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

--                              START CHECK

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

SELECT @@SERVERNAME


SET NOCOUNT ON
DECLARE @TSQL VARCHAR(8000)
DECLARE @Factor Float
CREATE TABLE #Results (
	DBName sysname COLLATE SQL_Latin1_General_CP1_CI_AS
	,[FileName] sysname COLLATE SQL_Latin1_General_CP1_CI_AS
	,FileType sysname COLLATE SQL_Latin1_General_CP1_CI_AS
	,Drive char(1) COLLATE SQL_Latin1_General_CP1_CI_AS
	,UsedData FLOAT
	,TotalDataSize FLOAT
	,Growth VarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS
	)

SELECT * INTO #DiskInfo FROM [dbaadmin].[dbo].[dbaudf_ListDrives]() WHERE IsReady = 'True'

SET @Factor =	1
SET @Factor =	@Factor		--B
		/1024		--KB
		/1024		--MB
		--/1024		--GB
		--/1024		--TB

SET @TSQL =
'USE [?];
INSERT #Results(DBName, [FileName], FileType, Drive, UsedData, TotalDataSize, Growth)
SELECT	DB_Name()
	,name 
	,CASE groupid WHEN 1 THEN ''DATA'' WHEN 0 THEN ''LOG'' ELSE ''Other'' END
	,UPPER(LEFT(filename,1))
	,CAST(FILEPROPERTY ([name], ''SpaceUsed'') AS Float)*(8*1024)
	,CAST(size AS Float)*(8*1024)
	,CASE
		WHEN growth = 0		THEN ''No Growth''
		WHEN maxsize = 0	THEN ''No Growth''
		WHEN maxsize = -1	THEN ''Unlimited''
		WHEN maxsize >= size	THEN ''Unlimited''
		WHEN CAST(maxsize-size AS Float)*(8*1024) > T2.[FreeSpace] THEN ''Unlimited''
		ELSE CAST(CAST(maxsize-size AS Float)*(8*1024) AS VarChar(50))
		END
FROM sysfiles T1
JOIN #DiskInfo T2
ON LEFT(T1.filename,1) COLLATE SQL_Latin1_General_CP1_CI_AS = T2.DriveLetter COLLATE SQL_Latin1_General_CP1_CI_AS'

EXEC sp_MSForEachDB @TSQL


SELECT		[DriveLetter]
		,COALESCE(CASE 
		 WHEN MAX(FileType) != MIN(FileType) 
		 THEN 'BOTH' 
		 ELSE MAX(FileType) 
		 END,'NONE')				AS [FileType]
		
		,MAX(TotalSize_MB)			AS [Dive_MB]
		,MAX(FreeSpace_MB)			AS [Free_MB]
		,MAX([TotalSize_MB])
		 -MAX([FreeSpace_MB])			AS [Used_MB]
		
		,COALESCE(SUM(CapedDataSize_MB),0)	AS [Caped_MB]
		
		,COALESCE(SUM(TotalDataSize_MB),0)	AS [DB_Used_MB]
		
		
		,COALESCE(SUM(TotalDataSize_MB),0)	
		 -COALESCE(SUM(UsedData_MB),0)		AS [DB_Shrinkable_MB]
		
		,MAX(TotalSize_MB)
		 -COALESCE(SUM(CapedDataSize_MB),0)	AS [Adj_Dive_MB]

		,COALESCE(SUM(TotalDataSize_MB),0)
		 -COALESCE(SUM(CapedDataSize_MB),0)	AS [adj_DB_Used_MB]

		
		,100 - (MAX(FreeSpace_MB)
		 *100/MAX(TotalSize_MB))		AS [Pct_Used]
		

		,100 - (
		MAX(FreeSpace_MB)*100/
		(
		MAX(TotalSize_MB)
		 -COALESCE(SUM(CapedDataSize_MB),0)
		))					AS [Adj_Pct_Used]
		




FROM		(
		SELECT		d.DriveLetter
				,d.TotalSize	
				,d.TotalSize*@Factor		[TotalSize_MB]
				,d.AvailableSpace*@Factor	[AvailableSpace_MB]	
				,d.FreeSpace*@Factor		[FreeSpace_MB]	
				,d.DriveType	
				,d.SerialNumber	
				,d.FileSystem	
				,d.IsReady
				,CASE WHEN s.DriveName IS NULL THEN 'False' ELSE 'True' END AS [Clstrd]
				,d.ShareName	
				,d.VolumeName	
				,d.[Path]
				,d.RootFolder	
				,r.DBName	
				,r.FileName	
				,r.FileType	
				,r.UsedData*@Factor		[UsedData_MB]	
				,r.TotalDataSize*@Factor	[TotalDataSize_MB]
				,CASE r.Growth
					WHEN 'No Growth' 
					THEN r.TotalDataSize*@Factor
					ELSE 0
					END			[CapedDataSize_MB]	
				,r.Growth	
				
		FROM		#DiskInfo d
		LEFT JOIN	#Results r
			ON	r.Drive = d.DriveLetter
		LEFT JOIN	sys.fn_servershareddrives() s
			ON	s.DriveName COLLATE SQL_Latin1_General_CP1_CI_AS = d.DriveLetter COLLATE SQL_Latin1_General_CP1_CI_AS
		) RawData
GROUP BY	DriveLetter
		
SELECT * FROM #DiskInfo
SELECT *,TotalDataSize-UsedData AS Shrinkable FROM #Results order by 4,8 desc

GO
DROP TABLE #Results
GO
DROP TABLE #DiskInfo
GO
