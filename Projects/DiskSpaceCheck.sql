USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_FileAccess_Write]    Script Date: 06/09/2010 14:22:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_FileAccess_Write]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


CREATE PROCEDURE [dbo].[dbasp_FileAccess_Write]
 (
@String Varchar(max), --8000 in SQL Server 2000
@Path VARCHAR(1024),
@Filename VARCHAR(1024)

--
)
AS
DECLARE  @objFileSystem int
        ,@objTextStream int
	,@objErrorObject int
	,@strErrorMessage Varchar(1024)
	,@Command varchar(1024)
	,@hr int
	,@fileAndPath varchar(1024)

set nocount on

select @strErrorMessage=''opening the File System Object''
EXECUTE @hr = sp_OACreate  ''Scripting.FileSystemObject'' , @objFileSystem OUT

Select @FileAndPath=@path+''\''+@filename
if @HR=0 Select @objErrorObject=@objFileSystem , @strErrorMessage=''Creating file "''+@FileAndPath+''"''
if @HR=0 execute @hr = sp_OAMethod   @objFileSystem   , ''CreateTextFile''
	, @objTextStream OUT, @FileAndPath,2,True

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
EXECUTE sp_OADestroy @objTextStream
' 
END
GO


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
			exec sp_OAGetProperty @Drive,''IsReady''	, @Results OUT; UPDATE @DriveList SET [IsReady]		= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
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

USE [dbaperf]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_ChartData_DBGrowth]    Script Date: 06/09/2010 08:50:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_ChartData_DBGrowth]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*

Object:			dbasp_ChartData_DBGrowth

Description:	Returns Chart Data to Forecast future growth on SQL Server Databases based on historical
				data stored in the [dbaadmin].[dbo].[db_stats_log] Table. This table is added to on a
				weekly schedule with the current database sizes. Because of this, we kept the level of
				granularity at "weekly" so any refference to "PERIOD" in this process will be a week.
				Period names are {Year}-{ISO Week Number}. 
				
				This SPROC uses a Linear Regression formula to forecast the next 52 periods, or 1 year.
				The three previous periods and the three following periods are used to create a smoothed
				"Moving Average" for each recorded value. Then A forecast is calculated using the following
				formulas and adjusting for seasonality.

				Metric			M.
				ForcastKey		X.
				Count			C.
				Slope:			B= (C * SXY - (SX)(SY)) / (C * SX2 - (SX)2) 
				Y-Intercept:	A= (SY - B(SX)) / C 
				Seasonality:	Metric/A+BX.
				Forcast:		A+BX.				

Usage: dbasp_ChartData_DBGrowth	[@DBName=''{DatabaseName}|SUMMARY|DETAIL''|''''|{NULL}]
								[, @TargetSizeMB=''[+]#####[%]'']
								[, @TimeTillTarget] OUTPUT ONLY
								[, @TimeTillCL] OUTPUT ONLY
								[, @CurrentSizeMB] OUTPUT ONLY
								[, @CurrentLimit] OUTPUT ONLY
								[, @CurrentLimit2] OUTPUT ONLY
								[, @NoDataTable=0|1] Default=0
								[, @OutputAsHTML=0|1] Default=0
								[, @Exclusions=''{comma delimited list of databases to exclude when not a single DB'']

Arguments:
			@DBName
			This can be a single Database, one of the two "KeyWords" or '''' or NULL.
				{DatabaseName}	= Returns data and/or output parameters for that single database.
				{NULL}			= Same as ''SUMMARY''
				''''				= Same as ''SUMMARY''
				''SUMMARY''		= Returns data and/or output parameters for all databases as a
									single series.
				''DETAIL''		= Returns data and/or output parameters for all databases as 
									multiple series.
				
			@TargetSizeMB		= Can be a specific value in MB (Numeric Digits Only), or can be 
									relative by using the ''+'' Prefix.
									+ Prefix = Adds Target to Existing Size.
									% Suffix = Uses Numeric portion as a percent of Existing Size.
									ex.	{CurrentSize} = 10GB
									
										30000	= 30GB									= 30GB
										+30000	= {CurrentSize}+30GB					= 40GB
										200%	= 200% of {CurrentSize}					= 20GB
										+200%	= {CurrentSize}+200% of {CurrentSize}	= 30GB
										
			@NoDataTable		= specify a 1 here to prevent returning the chart data{DataTable}.
			
			@OutputAsHTML		= specify a 1 here to write an html Chart Report to the ''_dbasql\dba_reports'' share
									filename = DBGrowthForecast_{ServerName}_{DBName}_{date}.html
			
			@Exclusions			= A comma delimited list of databases to exclude from SUMMARY
									or DETAIL methods of this process.
Returns: 
			{ReturnValue}		= None.
			{DataTable}			= Single Recordset.
			{Messages}			= Text Version of the Output Parameters.
			@CurrentSizeMB		= Returns The Current Used Space (Data+Index) of the specified 
									Database/Databases.
			@CurrentLimit		= Returns The Current Potential Maximum Used Space of the specified 
									Database/Databases if it used all of the current free space for 
									all drives currently being used for DB Data Devices.
			@CurrentLimit2		= Returns The Current Potential Maximum Used Space of the specified 
									Database/Databases if it used all of the current free space for 
									the drives the Database/Databases is currently using for DB Data Devices.
			@TimeTillTarget		= Returns Number of periods till Target Size is Reached.
			@TimeTillCL			= Returns Number of Periods till Current Limit is Reached.			

$Workfile: dbasp_ChartData_DBGrowth.sql $

$Author: sledridge $. Email: steve.ledridge@gettyimages.com

$Revision: 1 $

Example: 
			DECLARE	@TimeTillTarget		Int
					,@TimeTillCL		Int
					,@CurrentSizeMB		numeric(38,17)
					,@CurrentLimit		numeric(38,17)
					
			dbasp_ChartData_DBGrowth	@DBName=''WCDS''
										, @TimeTillTarget=@TimeTillTarget OUT
										, @TimeTillCL=@TimeTillCL OUT
										, @CurrentSizeMB=@CurrentSizeMB OUT
										, @CurrentLimit=@CurrentLimit OUT
										
			SELECT @TimeTillTarget,@TimeTillCL,@CurrentSizeMB,@CurrentLimit
										
Created: 2010-03-25. $Modtime: 4/07/00 8:38p $.

*/ 

CREATE PROCEDURE	[dbo].[dbasp_ChartData_DBGrowth]
					(
					@DBName			VarChar(50) = NULL --IF NULL A SERVER SUMMARY IS RUN
					,@DriveLetter		CHAR(1) = NULL
					,@TargetSizeMB		VarChar(50) = NULL --IF NULL THIS IS THE SAME AS @CurrentLimit
					,@TimeTillTarget	Int = NULL OUTPUT
					,@TimeTillCL		Int = NULL OUTPUT
					,@CurrentSizeMB		numeric(38,17) = NULL OUTPUT
					,@CurrentLimit		numeric(38,17) = NULL OUTPUT
					,@CurrentLimit2		numeric(38,17) = NULL OUTPUT
					,@NoDataTable		bit = 0
					,@OutputAsHTML		bit = 0
					,@NoComments		bit = 0
					,@Exclusions		VarChar(2048) = NULL
					,@OneYearForcastSizeMB	numeric(38,17) = NULL OUTPUT
					)
AS
SET NOCOUNT ON
--****************************************************************************
--
--	Database Growth Trending and Forcasting using Linear Regression
--	By: Steve Ledridge
--  
--	ALL SIZES IN MB
--****************************************************************************
--DROP TABLE #DiskInfo 
--DROP TABLE #DBDrivesUsed
--DROP TABLE #ForecastTable
--DROP TABLE #Formula
--GO
------ SET TEST VARIABLES
--DECLARE	@DBName				sysname
--		,@TargetSizeMB		VarChar(50)
--		,@TimeTillTarget	Int
--		,@TimeTillCL		Int
--		,@CurrentSizeMB		numeric(38,17)
--		,@CurrentLimit		numeric(38,17)
--		,@NoDataTable		Bit
--		,@Exclusions		VarChar(2048)
--SELECT	@DBName				= ''SUMMARY''
--		,@TargetSizeMB		= ''+50%''
--		,@NoDataTable		= 0
--		,@Exclusions		= NULL -- Carefull, Can Conflict with @DBName
--------------------------------------------------------------------------------
--
--	SET VARIABLES
--
--------------------------------------------------------------------------------
-- Create Table Variable to hold Current Drive Freespace
DECLARE		@RawData	Table
			(
			EventDate			DateTime
			,ServerName			sysname
			,DatabaseName			sysname
			,DataSize			NUMERIC(38,17)
			,IndexSize			NUMERIC(38,17)
			)
			
--CREATE		TABLE		#DiskInfo 
--			(
--			Drive				CHAR(1) PRIMARY KEY
--			,MBFree				INT
--			,Tag				VARCHAR(50)
--			)

-- Create table to hold the drives used by each database			
--CREATE		TABLE		#DBDrivesUsed 
--			(
--			DBName				sysname
--			,FileType			sysname
--			,Drive				char(1)
--			)	
CREATE		TABLE		#Results 
			(
			DBName				sysname		COLLATE SQL_Latin1_General_CP1_CI_AS
			,[FileName]			sysname		COLLATE SQL_Latin1_General_CP1_CI_AS
			,FileType			sysname		COLLATE SQL_Latin1_General_CP1_CI_AS
			,Drive				char(1)		COLLATE SQL_Latin1_General_CP1_CI_AS
			,UsedData			FLOAT
			,TotalDataSize			FLOAT
			,Growth				VarChar(50)	COLLATE SQL_Latin1_General_CP1_CI_AS
			)						

-- Create Table Variable to hold results
CREATE		TABLE		#ForecastTable  
			(
			ForecastKey			INT 
			,CYear				INT 
			,CWeek				INT
			,Unit				VARCHAR(50) 
			
			,Baseline_MetricA		NUMERIC(38,17)
			,Smoothed_MetricA		NUMERIC(38,17)
			,Trend_MetricA			NUMERIC(38,17)
			,Seasonality_MetricA		NUMERIC(38,17)
			,Forcast_MetricA		NUMERIC(38,17)
			
			,Baseline_MetricB		NUMERIC(38,17)
			,Smoothed_MetricB		NUMERIC(38,17)
			,Trend_MetricB			NUMERIC(38,17)
			,Seasonality_MetricB		NUMERIC(38,17)
			,Forcast_MetricB		NUMERIC(38,17)
			)

-- Create table to store calculations by Item
CREATE		TABLE		#Formula 
			(
			Unit				varchar(50)
			,Counts				int
			,SumX				Numeric(14,4)
			,SumXsqrd			Numeric(14,4)
			,SumY_MetricA			Numeric(14,4)
			,SumXY_MetricA			Numeric(14,4)
			,SumY_MetricB			Numeric(14,4)
			,SumXY_MetricB			Numeric(14,4)
			,b_MetricA			Numeric(38,17)
			,a_MetricA			Numeric(38,17)
			,b_MetricB			Numeric(38,17)
			,a_MetricB			Numeric(38,17)
			)

DECLARE		@Periods	TABLE
			(
			ID				INT  IDENTITY(1,1)
			,CYear				INT 
			,CWeek				INT
			,MinDate			DateTime
			,MaxDate			DateTime
			)
					
-- Other Variables
DECLARE		@startDate	datetime
DECLARE		@enddate	datetime
DECLARE		@CurrentPeriod	INT
DECLARE		@CurrentDate	DateTime
DECLARE		@HTMLOutput	VarChar(MAX)
DECLARE		@HTMLOut_Path	VarChar(1024)
DECLARE		@HTMLOut_File	VarChar(1024)
DECLARE		@Factor		Float
DECLARE		@KeyPointer	INT
DECLARE		@FixPointer1	INT
DECLARE		@FixPointer2	INT
DECLARE		@FixValue1	NUMERIC(38,17)
DECLARE		@FixValue2	NUMERIC(38,17)
DECLARE		@FixValue3	NUMERIC(38,17)
DECLARE		@TSQL		VarChar(8000)

SET @Factor =	1
SET @Factor =	@Factor		--B
		/1024		--KB
		/1024		--MB
		--/1024		--GB
		--/1024		--TB

If @DriveLetter > ''''		
	SET @DBName = ''DRIVE_'' + @DriveLetter

If @DBName = '''' 
  SET @DBName	= NULL
SET @DBName	= COALESCE(@DBName,''SUMMARY'')

SET @Exclusions = COALESCE(@Exclusions,''Master,Model,MSDB,TempDB'')

SELECT		@startDate = CAST(CONVERT(VarChar(12),DATEADD(year,-1,GetDate()),101)AS DateTime)
		, @enddate = CAST(CONVERT(VarChar(12),DATEADD(week,-1,GetDate()),101)AS DateTime)

--Print ''getting #DiskInfo''
SELECT * INTO #DiskInfo FROM [dbaadmin].[dbo].[dbaudf_ListDrives]() WHERE IsReady = ''True''


SET @TSQL =
''USE [?];
INSERT #Results(DBName, [FileName], FileType, Drive, UsedData, TotalDataSize, Growth)
SELECT	DB_Name()
	,name 
	,CASE groupid WHEN 1 THEN ''''DATA'''' WHEN 0 THEN ''''LOG'''' ELSE ''''Other'''' END
	,UPPER(LEFT(filename,1))
	,CAST(FILEPROPERTY ([name], ''''SpaceUsed'''') AS Float)*(8*1024)
	,CAST(size AS Float)*(8*1024)
	,CASE
		WHEN growth = 0		THEN ''''No Growth''''
		WHEN maxsize = 0	THEN ''''No Growth''''
		WHEN maxsize = -1	THEN ''''Unlimited''''
		WHEN maxsize >= size	THEN ''''Unlimited''''
		WHEN CAST(maxsize-size AS Float)*(8*1024) > T2.[FreeSpace] THEN ''''Unlimited''''
		ELSE CAST(CAST(maxsize-size AS Float)*(8*1024) AS VarChar(50))
		END
FROM sysfiles T1
JOIN #DiskInfo T2
ON LEFT(T1.filename,1) COLLATE SQL_Latin1_General_CP1_CI_AS = T2.DriveLetter COLLATE SQL_Latin1_General_CP1_CI_AS

IF EXISTS (SELECT * FROM sys.databases WHERE name = ''''z_?_new'''' AND state_desc != ''''ONLINE'''')
INSERT #Results(DBName, [FileName], FileType, Drive, UsedData, TotalDataSize, Growth)
SELECT	''''z_?_new''''
	,name 
	,CASE groupid WHEN 1 THEN ''''DATA'''' WHEN 0 THEN ''''LOG'''' ELSE ''''Other'''' END
	,UPPER(LEFT(filename,1))
	,CAST(FILEPROPERTY ([name], ''''SpaceUsed'''') AS Float)*(8*1024)
	,CAST(size AS Float)*(8*1024)
	,CASE
		WHEN growth = 0		THEN ''''No Growth''''
		WHEN maxsize = 0	THEN ''''No Growth''''
		WHEN maxsize = -1	THEN ''''Unlimited''''
		WHEN maxsize >= size	THEN ''''Unlimited''''
		WHEN CAST(maxsize-size AS Float)*(8*1024) > T2.[FreeSpace] THEN ''''Unlimited''''
		ELSE CAST(CAST(maxsize-size AS Float)*(8*1024) AS VarChar(50))
		END
FROM sysfiles T1
JOIN #DiskInfo T2
ON LEFT(T1.filename,1) COLLATE SQL_Latin1_General_CP1_CI_AS = T2.DriveLetter COLLATE SQL_Latin1_General_CP1_CI_AS
''

EXEC sp_MSForEachDB @TSQL

DELETE #Results WHERE DBName in (Select DISTINCT SplitValue FROM dbaadmin.dbo.dbaudf_split(@Exclusions,'',''))

----Print ''getting #DBDrivesUsed''
--exec sp_msForEachDB ''INSERT INTO #DBDrivesUsed(DBName, FileType, Drive) SELECT DISTINCT ''''?'''',CASE groupid WHEN 1 THEN ''''DATA'''' WHEN 0 THEN ''''LOG'''' ELSE ''''Other'''' END,UPPER(LEFT(filename,1)) COLLATE SQL_Latin1_General_CP1_CI_AS FROM [?]..sysfiles''
--DELETE #DBDrivesUsed WHERE DBName in (Select DISTINCT SplitValue FROM dbaadmin.dbo.dbaudf_split(@Exclusions,'',''))

INSERT INTO	@RawData
SELECT		[rundate]
		,[ServerName]
		,CASE 
			WHEN @DBName = ''SUMMARY'' THEN [ServerName]
			WHEN @DBName Like ''DRIVE%'' THEN @DBName
			ELSE [DatabaseName]
			END
		,CAST([data_space_used_KB] AS Numeric(38,17)) / 1024.00000 DataSize
		,CAST([index_size_used_KB] AS Numeric(38,17)) / 1024.00000 IndexSize
FROM		(SELECT * FROM [dbaadmin].[dbo].[db_stats_log] UNION ALL SELECT * FROM [dbaperf].[dbo].[db_stats_log]) [db_stats_log]
WHERE		([DatabaseName] = @DBName
	OR	@DBName IN (''SUMMARY'',''DETAIL'')
	OR	(@DBName Like ''DRIVE%'' AND DatabaseName IN (SELECT DBName FROM #Results WHERE FileType = ''DATA'' and Growth != ''No Growth'' and Drive = @DriveLetter))
		)
AND		[DatabaseName] NOT IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_split(@Exclusions,'',''))
AND		[rundate] >= @startDate


--RESET DATES TO DATES IN ARCHIVE
SELECT		@startDate = MIN(EventDate)
		,@enddate = MAX(EventDate)
FROM		@RawData

WHILE @startDate<@enddate
BEGIN
	UPDATE		@Periods	
		SET	MaxDate = @startDate
	WHERE		CYear = YEAR(@startDate)
		AND	CWeek = DATEPART(week ,@startDate)
	If @@ROWCOUNT = 0		
	BEGIN
	INSERT INTO @Periods (CYear,CWeek,MinDate,MaxDate)
	SELECT	YEAR(@startDate) [Year]
			,DATEPART(week ,@startDate) [Week]
			,@startDate [MinDate]
			,@startDate [MaxDate]
	END
	SET @startDate = @startDate +1
END


--RESET DATES TO DATES IN ARCHIVE
SELECT		@startDate = MIN(EventDate)
		,@enddate = MAX(EventDate)
FROM		@RawData


--Print ''getting @CurrentSizeMB''	
SELECT		@CurrentSizeMB = SUM(COALESCE(CAST([DataSize] AS numeric(38,17))+CAST([IndexSize] AS numeric(38,17)),0))
FROM		@RawData
WHERE		DATEPART(year,[EventDate]) = (SELECT DATEPART(year,MAX([EventDate])) FROM @RawData)
	AND	DATEPART(week,[EventDate]) = (SELECT DATEPART(week,MAX([EventDate])) FROM @RawData)


--USING DATABASES CURRENT DATA DRIVES
SELECT		@CurrentLimit  = @CurrentSizeMB + SUM(COALESCE(Freespace,0)*@Factor)
FROM		#DiskInfo
WHERE		DriveLetter IN
				(
				SELECT	Drive
				FROM	#Results
				WHERE	FileType = ''DATA''
				  AND	Growth != ''No Growth''
				  AND	(
					DBName = @DBName
					  OR	@DBName IN (''SUMMARY'',''DETAIL'')
					  OR	(@DBName Like ''DRIVE%'' AND Drive = @DriveLetter)
					)
				  AND	DBName NOT IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_split(@Exclusions,'',''))	
				)


-- USING ALL CURRENT DATA DRIVES
If @DriveLetter > ''''
	SET @CurrentLimit2 = @CurrentLimit
ELSE	
	SELECT		@CurrentLimit2 = @CurrentSizeMB + SUM(COALESCE(Freespace,0)*@Factor) 
	FROM		#DiskInfo
	WHERE		DriveLetter IN
				(
				SELECT	Drive
				FROM	#Results
				WHERE	FileType = ''DATA''
				  AND	Growth != ''No Growth''
				)



--Print ''Cleaning @TargetSizeMB''	
If LEFT(@TargetSizeMB,1) = ''+'' -- ADD Calculation to Existing Size
BEGIN
	If RIGHT (@TargetSizeMB,1) = ''%'' -- Percent of Existing Size
		SET @TargetSizeMB = ((CAST(SUBSTRING(@TargetSizeMB,1,LEN(@TargetSizeMB)-2) AS Numeric(38,17)) * @CurrentSizeMB)/100) + @CurrentSizeMB
	else -- Fixed Value
		SET @TargetSizeMB = CAST(RIGHT(@TargetSizeMB,LEN(@TargetSizeMB)-1) AS Numeric(38,17)) + @CurrentSizeMB
END
else -- Just Use calculation or fixed value without adding to existing size
BEGIN	
	If RIGHT (@TargetSizeMB,1) = ''%'' --	Percent of Existing Size
		SET @TargetSizeMB = ((CAST(LEFT(@TargetSizeMB,LEN(@TargetSizeMB)-1) AS Numeric(38,17)) * @CurrentSizeMB)/100) 
END	
-- IF None of the previous logic is applied the value is assumed to be a fixed value in MB.

-- USE CURRENT LIMIT AS TARGET IF NOT SPECIFIED
SET @TargetSizeMB = COALESCE(@TargetSizeMB,@CurrentLimit)


--Print ''Starting Step 1''	
--*****************************************************************************
--
--	Step 1 - Populate Forcast Table with all historical Data Grouped By Year-Week.
--		Then update Smoothed_Value with a central moving average
--		
--*****************************************************************************

DECLARE @CurDB sysname
DECLARE DBCursor CURSOR
FOR
SELECT	DISTINCT 
	[DatabaseName]
From	@RawData
	
OPEN DBCursor
FETCH NEXT FROM DBCursor INTO @CurDB
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN

		INSERT INTO #ForecastTable (ForecastKey,CYear, CWeek, Unit, Baseline_MetricA, Baseline_MetricB)
		SELECT		ID
					,[Year]
					,[Week]
					,[Unit]
					,MAX(COALESCE([MetricA],0)) [MetricA] 
					,MAX(COALESCE([MetricB],0)) [MetricB]
		FROM		(
					SELECT		P1.ID
								,P1.CYear [Year]
								,P1.CWeek [Week]
								,@CurDB [Unit]
								,CAST([DataSize] AS numeric(38,17)) [MetricA]
								,CAST([IndexSize] AS numeric(38,17)) [MetricB]
					FROM		@Periods P1
					LEFT outer JOIN	@RawData T1
						ON		P1.CYear = YEAR([EventDate])
						AND		P1.CWeek = DATEPART(week,[EventDate])
						AND		[DatabaseName] NOT IN (SELECT [SplitValue] FROM dbaadmin.dbo.dbaudf_split(@Exclusions,'',''))
						AND		@CurDB = CASE @DBName
								WHEN ''SUMMARY'' THEN @CurDB
								ELSE [DatabaseName]
								END 
					) Data	
					
		GROUP BY	ID
					,[Year]
					,[Week]
					,[Unit]
					
	END
	FETCH NEXT FROM DBCursor INTO @CurDB
END
CLOSE DBCursor
DEALLOCATE DBCursor
	
-- CLEAN UP BLANK SPACES

FixEmptyValue:
	
SELECT	@KeyPointer = MIN(ForecastKey)
FROM	#ForecastTable WHERE Baseline_MetricA = 0			

If	@KeyPointer IS NOT NULL		
BEGIN			
	If @KeyPointer = 1
	UPDATE #ForecastTable
	SET Baseline_MetricA = (SELECT Baseline_MetricA FROM #ForecastTable WHERE ForecastKey = (SELECT MIN(ForecastKey) FROM #ForecastTable WHERE Baseline_MetricA > 0))
	WHERE ForecastKey = @KeyPointer
	ELSE
	If @KeyPointer = (SELECT MIN(ForecastKey) FROM #ForecastTable)
	UPDATE #ForecastTable
	SET Baseline_MetricA = (SELECT Baseline_MetricA FROM #ForecastTable WHERE ForecastKey = (SELECT MAX(ForecastKey) FROM #ForecastTable WHERE Baseline_MetricA > 0))
	WHERE ForecastKey = @KeyPointer
	ELSE
	BEGIN
		SELECT	@FixPointer1	= ForecastKey
			,@FixValue1	= Baseline_MetricA 
		FROM	#ForecastTable 
		WHERE	ForecastKey = (SELECT MAX(ForecastKey) FROM #ForecastTable WHERE Baseline_MetricA > 0 AND ForecastKey <@KeyPointer)

		SELECT	@FixPointer2	= ForecastKey
			,@FixValue2	= Baseline_MetricA 
		FROM	#ForecastTable 
		WHERE	ForecastKey = (SELECT MIN(ForecastKey) FROM #ForecastTable WHERE Baseline_MetricA > 0 AND ForecastKey >@KeyPointer)

		SELECT	@FixValue3 = (@FixValue2 - @FixValue1)/(@FixPointer2-@FixPointer1)

		UPDATE #ForecastTable
		SET Baseline_MetricA = @FixValue1 + @FixValue3
		WHERE ForecastKey = @KeyPointer

	END				
END

IF EXISTS(SELECT * FROM #ForecastTable WHERE Baseline_MetricA = 0)
 GOTO FixEmptyValue


-- Update Smoothed_Value with Central Moving Average 

	Update		#ForecastTable 
		SET		Smoothed_MetricA = MovAvg.Smoothed_MetricA
				,Smoothed_MetricB = MovAvg.Smoothed_MetricB
	FROM		(
				SELECT		a.ForecastKey as FKey
							,a.Unit as XUnit 
							,Round(AVG(Cast(b.Baseline_MetricA as numeric(14,1))),0) Smoothed_MetricA
							,Round(AVG(Cast(b.Baseline_MetricB as numeric(14,1))),0) Smoothed_MetricB
				FROM		#ForecastTable a
				INNER JOIN	#ForecastTable b 
					ON		a.Unit = b.Unit 
					AND		(a.ForecastKey - b.ForecastKey) BETWEEN -3 AND 3 -- Averaged with the 3 periods before and after.
				GROUP BY	a.ForecastKey
							,a.Unit
				) MovAvg
	WHERE		Unit = MovAvg.XUnit
		AND		ForecastKey = MovAvg.FKey
--Print ''Starting Step 2''		
--****************************************************************************************
--
--	Step 2 - Populate the Formula Table for both Metrics on each Unit.
--		This step is performed with an insert and update to make the calculations more clear
--		It could just as easily be performed with a single insert.
--		Lastly, update the trend for historical data and calculate seasonality
--
--*****************************************************************************************
	-- Set starting values
	INSERT INTO #Formula (Unit, Counts, SumX, SumY_MetricA, SumXY_MetricA, SumY_MetricB, SumXY_MetricB, SumXsqrd)	
	SELECT		Unit
				,COUNT(*)
				,sum(ForecastKey)
				,sum(Smoothed_MetricA)
				,sum(Smoothed_MetricA * ForecastKey)
				,sum(Smoothed_MetricB)
				,sum(Smoothed_MetricB * ForecastKey)
				,sum(power(ForecastKey,2)) 
	FROM		#ForecastTable
	WHERE		Smoothed_MetricA IS NOT NULL
		AND		Smoothed_MetricB IS NOT NULL
	GROUP BY	Unit

		
	-- Calculate B (Slope)
	UPDATE		#Formula 
		SET		b_MetricA	= ((tb.counts * tb.sumXY_MetricA)-(tb.sumX * tb.sumY_MetricA))/ (tb.Counts * tb.sumXsqrd - power(tb.sumX,2))
				,b_MetricB	= ((tb.counts * tb.sumXY_MetricB)-(tb.sumX * tb.sumY_MetricB))/ (tb.Counts * tb.sumXsqrd - power(tb.sumX,2))
	FROM		(
				SELECT		Unit as XUnit
							, Counts
							, SumX
							, SumY_MetricA
							, SumY_MetricB
							, SumXY_MetricA
							, SumXY_MetricB
							, SumXsqrd 
				FROM		#Formula
				) tb
	WHERE		Unit = tb.XUnit
	
		
	-- Calculate A (Y Intercept)
	UPDATE		#Formula 
		SET		a_MetricA	= ((tb2.sumY_MetricA - tb2.b_MetricA * tb2.sumX) / tb2.Counts)
				,a_MetricB	= ((tb2.sumY_MetricB - tb2.b_MetricB * tb2.sumX) / tb2.Counts)
	FROM		(
				SELECT		Unit as XUnit
							, Counts
							, SumX
							, SumY_MetricA
							, SumY_MetricB
							, SumXY_MetricA
							, SumXY_MetricB
							, SumXsqrd
							, b_MetricA
							, b_MetricB 
				FROM		#Formula
				) tb2
	WHERE		Unit = tb2.XUnit

	-- Calculate Seasonality		
	UPDATE		#ForecastTable 
		SET		Trend_MetricA = A_MetricA + (B_MetricA * ForecastKey)
				,Trend_MetricB = A_MetricB + (B_MetricB * ForecastKey)
				,Seasonality_MetricA = CASE WHEN Baseline_MetricA = 0 THEN 1 ELSE Baseline_MetricA /(A_MetricA + (B_MetricA * ForecastKey)) END
				,Seasonality_MetricB = CASE WHEN Baseline_MetricB = 0 THEN 1 ELSE Baseline_MetricB /(A_MetricB + (B_MetricB * ForecastKey)) END
	FROM		(
				SELECT		Unit as XUnit
							, Counts
							, SumX
							, SumY_MetricA
							, SumY_MetricB
							, SumXY_MetricA
							, SumXY_MetricB
							, SumXsqrd
							, b_MetricA
							, b_MetricB 
							, a_MetricA 
							, a_MetricB 
				FROM		#Formula
				) TrendUpdate
	WHERE		Unit = TrendUpdate.XUnit
--Print ''Starting Step 3''
--**********************************************************************************
--
--	Step 3 - Insert Trendline and forecast into Forecast table for future Dates.
--		
--**********************************************************************************
					

		-- Create Forecast
		DECLARE @Loop as int
		SET @Loop = -1
		----------------------------------------------------------------------------
		----------------------------------------------------------------------------
		-- COSMETIC FIX TO GET FORCAST TO START RIGHT FROM LAST RECORDED
		----------------------------------------------------------------------------
		----------------------------------------------------------------------------
		UPDATE		#ForecastTable
			SET		Forcast_MetricA		= Baseline_MetricA
					,Forcast_MetricB	= Baseline_MetricB
		WHERE		CYear = YEAR(dateadd(week,@Loop,getdate()))	
				AND	CWeek = DatePart(week,dateadd(week,@Loop,getdate())) 
				
		SET @Loop = 0

		WHILE @Loop <52 -- ONE YEARS
			BEGIN
				INSERT INTO	#ForecastTable (Forecastkey,CYear, CWeek, Unit, Trend_MetricA, Trend_MetricB, Forcast_MetricA, Forcast_MetricB)
				SELECT		MAX(Forecastkey) + 1 
							,YEAR(dateadd(week,@Loop,getdate()))
							,DatePart(week,dateadd(week,@Loop,getdate()))
							,a.Unit
							,MAX(A_MetricA) + (MAX(B_MetricA) * MAX(Forecastkey) + 1)	Trend_MetricA						-- Trendline
							,MAX(A_MetricB) + (MAX(B_MetricB) * MAX(Forecastkey) + 1)	Trend_MetricB						-- Trendline
							,(MAX(A_MetricA) + (MAX(B_MetricA) * MAX(Forecastkey) + 1))
							*	COALESCE((
								SELECT	Case 
										WHEN avg(Seasonality_MetricA) = 0 
										THEN 1 
										ELSE avg(Seasonality_MetricA) 
										END 
								FROM #ForecastTable SeasonalMask
								WHERE SeasonalMask.Unit = a.Unit
								AND SeasonalMask.CWeek = DatePart(week,dateadd(week,@Loop,getdate()))
								),1) Forcast_MetricA	-- Trendline * Avg seasonality

							,(MAX(A_MetricB) + (MAX(B_MetricB) * MAX(Forecastkey) + 1))
							*	COALESCE((
								SELECT	Case
										WHEN avg(Seasonality_MetricB) = 0 
										THEN 1 
										ELSE avg(Seasonality_MetricB) 
										END 
								FROM #ForecastTable SeasonalMask
								WHERE SeasonalMask.Unit = a.Unit
								AND SeasonalMask.CWeek = DatePart(week,dateadd(week,@Loop,getdate()))
								),1) Forcast_MetricB	-- Trendline * Avg seasonality
				FROM		#ForecastTable a
				INNER JOIN	#Formula b
					ON		a.Unit = b.Unit
				GROUP BY	a.Unit
				
			SET @Loop = @Loop +1
			END

SET		@CurrentDate = GetDate()



--Print ''Getting @CurrentPeriod''
SELECT		@CurrentPeriod = MAX(ID)
FROM		@Periods
	
--Print ''Getting @TimeTillTarget''
SELECT		TOP 1
			@TimeTillTarget = ForecastKey - @CurrentPeriod
FROM		#ForecastTable
WHERE		ForecastKey > @CurrentPeriod
	AND		Forcast_MetricA + Forcast_MetricB >= @TargetSizeMB
ORDER BY	ForecastKey 

--Print ''Getting @TimeTillCL''
SELECT		TOP 1
			@TimeTillCL = ForecastKey - @CurrentPeriod
FROM		#ForecastTable
WHERE		ForecastKey > @CurrentPeriod
	AND		Forcast_MetricA + Forcast_MetricB >= @CurrentLimit
ORDER BY	ForecastKey 

SELECT		TOP 1 
		@OneYearForcastSizeMB = CASE	WHEN COALESCE(Forcast_MetricA,0) + COALESCE(Forcast_MetricB,0) = 0 THEN NULL 
						ELSE COALESCE(Forcast_MetricA,0) + COALESCE(Forcast_MetricB,0)
						END
FROM		#ForecastTable
ORDER BY	ForecastKey DESC
		
		-- Review results
IF @NoComments = 0
BEGIN
	PRINT		''Database:				'' + @DBName
	PRINT		''Exclusions:				'' + @Exclusions
	PRINT		''Current Size:				'' + CAST(@CurrentSizeMB AS VarChar(50)) + ''MB''
	PRINT		''Target Size:				'' + @TargetSizeMB + ''MB''
	PRINT		''Time Till Target:			'' + COALESCE(CAST(@TimeTillTarget AS VarChar(50)) + '' Weeks'',''Not within Current Forcast'') 
	PRINT		''Current Limit:				'' + CAST(@CurrentLimit AS VarChar(50)) + ''MB''
	PRINT		''Time Till Current Limit:		'' + COALESCE(CAST(@TimeTillCL AS VarChar(50)) + '' Weeks'',''Not within Current Forcast'')
	PRINT		''One Year Forcasted Size:		'' + CAST(@OneYearForcastSizeMB AS VarChar(50)) + ''MB''
	PRINT		''''
END

If @NoDataTable = 0	
BEGIN			
	SELECT		Unit
				, CAST(CYear AS VarChar(4)) + ''-'' + RIGHT(''00''+CAST(CWeek AS VarChar(2)),2) [Period]
				, CASE WHEN COALESCE(Baseline_MetricA,0) + COALESCE(Baseline_MetricB,0) = 0 THEN NULL ELSE COALESCE(Baseline_MetricA,0) + COALESCE(Baseline_MetricB,0)END [Recorded] 
				, CASE WHEN COALESCE(Forcast_MetricA,0) + COALESCE(Forcast_MetricB,0) = 0 THEN NULL ELSE COALESCE(Forcast_MetricA,0) + COALESCE(Forcast_MetricB,0)END [Forcast]
				, Trend_MetricA + Trend_MetricB [Trend]
				, @CurrentSizeMB [CurrentSizeMB]	
				, CASE WHEN CAST(@TargetSizeMB AS numeric(38,17)) > (SELECT TOP 1 COALESCE(Forcast_MetricA,0) + COALESCE(Forcast_MetricB,0) FROM #ForecastTable ORDER BY Forecastkey DESC)THEN NULL ELSE CAST(@TargetSizeMB AS numeric(38,17)) END [TargetSizeMB]
				, CASE WHEN CAST(@CurrentLimit AS numeric(38,17)) > (SELECT TOP 1 COALESCE(Forcast_MetricA,0) + COALESCE(Forcast_MetricB,0) FROM #ForecastTable ORDER BY Forecastkey DESC)THEN NULL ELSE CAST(@CurrentLimit AS numeric(38,17)) END [CurrentLimitMB]
	FROM		#ForecastTable
	WHERE		Forecastkey >= @CurrentPeriod - 52
		AND		Forecastkey <= @CurrentPeriod + 52
	ORDER BY	Unit,Forecastkey		
END

If @OutputAsHTML = 1		
BEGIN 
	SELECT		@HTMLOutput = ''<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <title>
      Getty Images Opperations Report
    </title>
    <script type="text/javascript" src="http://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load(''''visualization'''', ''''1'''', {packages: [''''linechart'''']});
    </script>
    <script type="text/javascript">
      function drawVisualization() {
        // Create and populate the data table.
        var data = new google.visualization.DataTable();
        data.addColumn(''''string'''', ''''Name'''');
        data.addColumn(''''number'''', ''''Recorded'''');
        data.addColumn(''''number'''', ''''Forecast'''');
        data.addColumn(''''number'''', ''''Trend'''');
        data.addColumn(''''number'''', ''''Current'''');
        data.addColumn(''''number'''', ''''Target'''');
        data.addColumn(''''number'''', ''''Limit'''');  
        data.addRows([''+CHAR(13)+CHAR(10)


		SELECT		@HTMLOutput = @HTMLOutput +
					''            [''''''+CAST(CYear AS VarChar(4)) + ''-'' + RIGHT(''00''+CAST(CWeek AS VarChar(2)),2)
					+'''''','' + CAST(COALESCE(Baseline_MetricA,0) + COALESCE(Baseline_MetricB,0) AS VarChar(50))
					+'','' + CAST(COALESCE(Forcast_MetricA,0) + COALESCE(Forcast_MetricB,0) AS VarChar(50))
					+'','' + CAST(Trend_MetricA + Trend_MetricB AS VarChar(50))
					+'','' + CAST(@CurrentSizeMB AS VarChar(50))
					+'','' + CAST(@TargetSizeMB AS VarChar(50))
					+'','' + CAST(@CurrentLimit AS VarChar(50))
					+''],''+CHAR(13)+CHAR(10)
		FROM		#ForecastTable
		WHERE		Forecastkey >= @CurrentPeriod - 52
			AND		Forecastkey <= @CurrentPeriod + 52
		ORDER BY	Unit,Forecastkey

	SELECT		@HTMLOutput = @HTMLOutput +''      ]);
        // Create and draw the visualization.
        new google.visualization.LineChart(document.getElementById(''''visualization'''')).
            draw(data, {pointSize: 2, width: 800, height: 400, legend: ''''bottom'''', title: ''''Database Growth Forecast for '' + REPLACE(@@ServerName,''\'',''$'') + ''.''+ @DBName +''''''});  
      }
      google.setOnLoadCallback(drawVisualization);
    </script>
  </head>
  <body style="font-family: Arial;border: 0 none;">
    <div id="visualization" style="width: 800px; height: 400px;"></div>
  </body>
</html>''
		

	SELECT	@HTMLOut_Path = ''\\''+REPLACE(@@ServerName,''\''+@@ServiceName,'''')+''\''+REPLACE(@@ServerName,''\'',''$'')+''_dbasql\dba_reports''
			,@HTMLOut_File = ''DBGrowthForecast_'' + REPLACE(@@ServerName,''\'',''$'') + ''_'' + @DBName 
				--+ ''_'' + CONVERT(VarChar(8),getdate(),112)
				+''.html''

	EXEC dbaadmin.dbo.dbasp_FileAccess_Write
		@String			= @HTMLOutput
		,@Path			= @HTMLOut_Path
		,@Filename		= @HTMLOut_File

	PRINT ''File Writen To '' + @HTMLOut_Path +''\''+ @HTMLOut_File


	SET @HTMLOutput = ''''

	SELECT		@HTMLOutput = @HTMLOutput + DriveLetter + ''='' + CAST(COALESCE(Freespace,0)*@Factor AS VarChar(50))+''MB , '' 
	FROM		#DiskInfo
	WHERE		DriveLetter IN
				(
				SELECT	Drive
				FROM	#Results
				WHERE	FileType = ''DATA''
				  AND	Growth != ''No Growth''
				  AND	([DBName] = @DBName
					OR	@DBName IN (''SUMMARY'',''DETAIL'')
					OR	(@DBName Like ''DRIVE%'' AND DBName IN (SELECT DBName FROM #Results WHERE FileType = ''DATA'' and Growth != ''No Growth'' and Drive = @DriveLetter))
					)
				  AND	[DBName] NOT IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_split(@Exclusions,'',''))
				)
				
	SELECT @HTMLOutput = ''Calculations using all space on the following drives. '' + REPLACE(@HTMLOutput+''|'','', |'','''')
	PRINT @HTMLOutput
	PRINT ''''
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
USE dbaperf
GO
IF OBJECT_ID('dbaperf.dbo.DMV_DiskSpaceUsage') IS NOT NULL
	DROP TABLE dbo.DMV_DiskSpaceUsage
GO
IF OBJECT_ID('dbaperf.dbo.DMV_DiskSpaceForecast') IS NOT NULL
	DROP TABLE dbo.DMV_DiskSpaceForecast
GO

CREATE TABLE	DMV_DiskSpaceForecast  
		(
		[SQLName]			sysname DEFAULT (@@SERVERNAME)
		,[CheckDate]			DateTime DEFAULT (GETDATE())
		,Unit				VARCHAR(50) 
		,Period				VarChar(10)
		,Recorded			FLOAT
		,Forecast			FLOAT
		,[Trend]			FLOAT
		,CurrentDataSizeMB		FLOAT
		,TargetDataSizeMB		FLOAT
		,LimitDataSizeMB		FLOAT
		)

GO

SET NOCOUNT ON
DECLARE @TSQL			VARCHAR(8000)
DECLARE @Factor			Float
DECLARE @DriveLetter		CHAR(1)
	,@TimeTillTarget	Int
	,@TimeTillCL		Int
	,@CurrentSizeMB		Float
	,@CurrentLimit		Float
	,@OneYearForcastSizeMB	Float
	,@UNCPath		VarChar(8000)
	,@target_env		VarChar(50)
	,@target_server		sysname
	,@target_share		VarChar(2048)
	,@retry_limit		INT
	,@Export_Source		VarChar(8000)
	,@FileName		VarChar(8000)
	,@SCRIPT		VarChar(8000)

SELECT	@UNCPath		= '\\' + LEFT(@@SERVERNAME,(CHARINDEX('\',@@SERVERNAME+'\')-1)) + '\' + REPLACE(@@SERVERNAME,'\','$') + '_dbasql\dba_reports'
	,@target_env		= 'amer'
	,@target_server		= 'SEAFRESQLDBA01'
	,@target_share		= 'SEAFRESQLDBA01_dbasql\DiskSpaceChecks'
	,@retry_limit		= 5

CREATE TABLE #Results (
	DBName sysname COLLATE SQL_Latin1_General_CP1_CI_AS
	,[FileName] sysname COLLATE SQL_Latin1_General_CP1_CI_AS
	,FileType sysname COLLATE SQL_Latin1_General_CP1_CI_AS
	,Drive char(1) COLLATE SQL_Latin1_General_CP1_CI_AS
	,UsedData FLOAT
	,TotalDataSize FLOAT
	,Growth VarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS
	)

CREATE TABLE #DiskInfo (
	[DriveLetter] [char](1) NULL
	,[TotalSize] [bigint] NULL
	,[AvailableSpace] [bigint] NULL
	,[FreeSpace] [bigint] NULL
	,[DriveType] [varchar](50) NULL
	,[SerialNumber] [varchar](50) NULL
	,[FileSystem] [varchar](50) NULL
	,[IsReady] [varchar](50) NULL
	,[ShareName] [varchar](255) NULL
	,[VolumeName] [varchar](255) NULL
	,[Path] [varchar](2048) NULL
	,[RootFolder] [varchar](2048) NULL
	,[TimeTillTarget] Int NULL
	,[TimeTillCL] Int NULL
	,[CurrentSizeMB] numeric(38,17) NULL
	,[CurrentLimit]	numeric(38,17) NULL
	,[OneYearForcastSizeMB]	numeric(38,17) NULL
	)
DECLARE DiskCursor 
CURSOR
FOR
SELECT DriveLetter FROM [dbaadmin].[dbo].[dbaudf_ListDrives]() WHERE IsReady = 'True'

OPEN DiskCursor
FETCH NEXT FROM DiskCursor INTO @DriveLetter
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET @TimeTillCL = NULL

		INSERT INTO [DBAperf].[dbo].[DMV_DiskSpaceForecast]
			   ([Unit]
			   ,[Period]
			   ,[Recorded]
			   ,[Forecast]
			   ,[Trend]
			   ,[CurrentDataSizeMB]
			   ,[TargetDataSizeMB]
			   ,[LimitDataSizeMB])
		exec dbasp_ChartData_DBGrowth 
			@DRiveLetter		= @DriveLetter
			, @OutputAsHTML		= 1
			, @NoDataTable		= 0
			, @NoComments		= 1
			, @TimeTillTarget	= @TimeTillTarget	OUTPUT
			, @TimeTillCL		= @TimeTillCL		OUTPUT
			, @CurrentSizeMB	= @CurrentSizeMB	OUTPUT
			, @CurrentLimit		= @CurrentLimit		OUTPUT
			, @OneYearForcastSizeMB	= @OneYearForcastSizeMB	OUTPUT

		INSERT INTO	#DiskInfo
		SELECT		*
				,@TimeTillTarget
				,@TimeTillCL
				,@CurrentSizeMB
				,@CurrentLimit
				,ABS(@OneYearForcastSizeMB - @CurrentSizeMB)
		FROM		[dbaadmin].[dbo].[dbaudf_ListDrives]() WHERE IsReady = 'True' AND DriveLetter = @DriveLetter
		
		IF @TimeTillCL IS NOT NULL
		BEGIN -- ONLY SEND CHART IF LIMIT REACHED WITHIN YEAR
		
			Print 'Sending HTML Charts  (' + COALESCE(CAST(@TimeTillCL AS VarChar(50)),'NULL') +')'
			SET	@FileName = 'DBGrowthForecast_'+REPLACE(@@SERVERNAME,'\','$')+'_DRIVE_'+@DriveLetter+'.html'

			EXEC	[dbaadmin].[dbo].[dbasp_File_Transit] 
				@source_name		= @FileName
				,@source_path		= @UNCPath
				,@target_env		= @target_env
				,@target_server		= @target_server
				,@target_share		= @target_share
				,@retry_limit		= @retry_limit
		END

	END
	FETCH NEXT FROM DiskCursor INTO @DriveLetter
END

CLOSE DiskCursor
DEALLOCATE DiskCursor


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
ON LEFT(T1.filename,1) COLLATE SQL_Latin1_General_CP1_CI_AS = T2.DriveLetter COLLATE SQL_Latin1_General_CP1_CI_AS

IF EXISTS (SELECT * FROM sys.databases WHERE name = ''z_?_new'' AND state_desc != ''ONLINE'')
INSERT #Results(DBName, [FileName], FileType, Drive, UsedData, TotalDataSize, Growth)
SELECT	''z_?_new''
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
ON LEFT(T1.filename,1) COLLATE SQL_Latin1_General_CP1_CI_AS = T2.DriveLetter COLLATE SQL_Latin1_General_CP1_CI_AS
'

EXEC sp_MSForEachDB @TSQL


SELECT		@@SERVERNAME				AS [ServerName]
		,GetDate()				AS [CheckDate]
		,[DriveLetter]
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
		,MAX(TimeTillTarget)			AS [WeeksTillTarget]
		,MAX(TimeTillCL)			AS [WeeksTillFull]
		,MAX(OneYearForcastSizeMB)		AS [OneYearForcastGrowthMB]
		,(COALESCE(SUM(TotalDataSize_MB),0)
		 -COALESCE(SUM(CapedDataSize_MB),0))
		 +MAX(OneYearForcastSizeMB)		AS [OneYearForcastSizeMB]
INTO		dbaperf.dbo.DMV_DiskSpaceUsage
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
				,d.TimeTillTarget
				,d.TimeTillCL
				,d.CurrentSizeMB
				,d.CurrentLimit
				,d.OneYearForcastSizeMB
				
		FROM		#DiskInfo d
		LEFT JOIN	#Results r
			ON	r.Drive = d.DriveLetter
		LEFT JOIN	sys.fn_servershareddrives() s
			ON	s.DriveName COLLATE SQL_Latin1_General_CP1_CI_AS = d.DriveLetter COLLATE SQL_Latin1_General_CP1_CI_AS
		) RawData
GROUP BY	DriveLetter
		


SET	@Export_Source		= 'dbaperf.dbo.DMV_DiskSpaceUsage'
SELECT	@FileName		= REPLACE([dbaadmin].[dbo].[dbaudf_base64_encode] (@@SERVERNAME+'|'+REPLACE(@Export_Source,'dbaperf.dbo.',''))+'.dat','=','$')
SET	@SCRIPT			= 'bcp '+@Export_Source+' out "'+@UNCPath+'\'+@FileName+'" -S '+@@Servername+' -T -N'
--Print	@Script

Print 'Exporting Data from '	+ @Export_Source
PRINT 'To File: '		+ @FileName
EXEC	xp_cmdshell		@SCRIPT, no_output

Print 'Sending Data from '	+ @Export_Source
EXEC	[dbaadmin].[dbo].[dbasp_File_Transit] 
		@source_name		= @FileName
		,@source_path		= @UNCPath
		,@target_env		= @target_env
		,@target_server		= @target_server
		,@target_share		= @target_share
		,@retry_limit		= @retry_limit
  
waitfor delay '00:00:05'  
  
-- DELETE FILE AFTER SENDING
SET	@Script = 'DEL "'+ @UNCPath+'\'+@FileName+'"'
--Print	@Script

Print 'Deleting File from ' + @Export_Source
exec	master..xp_cmdshell @Script, no_output




SET	@Export_Source		= 'dbaperf.dbo.DMV_DiskSpaceForecast'
SELECT	@FileName		= REPLACE([dbaadmin].[dbo].[dbaudf_base64_encode] (@@SERVERNAME+'|'+REPLACE(@Export_Source,'dbaperf.dbo.',''))+'.dat','=','$')
SET	@SCRIPT			= 'bcp '+@Export_Source+' out "'+@UNCPath+'\'+@FileName+'" -S '+@@Servername+' -T -N'
--Print	@Script

Print 'Exporting Data from '	+ @Export_Source
PRINT 'To File: '		+ @FileName
EXEC	xp_cmdshell		@SCRIPT, no_output

Print 'Sending Data from '	+ @Export_Source
EXEC	[dbaadmin].[dbo].[dbasp_File_Transit] 
		@source_name		= @FileName
		,@source_path		= @UNCPath
		,@target_env		= @target_env
		,@target_server		= @target_server
		,@target_share		= @target_share
		,@retry_limit		= @retry_limit
  
waitfor delay '00:00:05'  
  
-- DELETE FILE AFTER SENDING
SET	@Script = 'DEL "'+ @UNCPath+'\'+@FileName+'"'
--Print	@Script

Print 'Deleting File from ' + @Export_Source
exec	master..xp_cmdshell @Script, no_output


GO
DROP TABLE #Results
DROP TABLE #DiskInfo
GO
