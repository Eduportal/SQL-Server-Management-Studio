USE [DBAperf]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------------------------------------------------------------------------- 
-- dbasp_ChartData_DBGrowth
------------------------------------------------------------------------------------------------------- 
declare @cmd sysname
if not exists (select 1 from sys.objects where object_id = object_id(N'[dbo].[dbasp_ChartData_DBGrowth]') and OBJECTPROPERTY(object_id, N'IsProcedure') = 1)
   begin
	    Select @cmd = 'CREATE PROCEDURE [dbo].[dbasp_ChartData_DBGrowth] as set nocount on'
	    exec(@cmd)
   end
GO
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
				Y-Intercept:		A= (SY - B(SX)) / C 
				Seasonality:		Metric/A+BX.
				Forcast:		A+BX.				

Usage: dbasp_ChartData_DBGrowth	[@DBName='{DatabaseName}|SUMMARY|DETAIL'|''|{NULL}]
								[, @TargetSizeMB='[+]#####[%]']
								[, @TimeTillTarget] OUTPUT ONLY
								[, @TimeTillCL] OUTPUT ONLY
								[, @CurrentSizeMB] OUTPUT ONLY
								[, @CurrentLimit] OUTPUT ONLY
								[, @CurrentLimit2] OUTPUT ONLY
								[, @NoDataTable=0|1] Default=0
								[, @OutputAsHTML=0|1] Default=0
								[, @Exclusions='{comma delimited list of databases to exclude when not a single DB']

Arguments:
			@DBName
			This can be a single Database, one of the two "KeyWords" or '' or NULL.
				{DatabaseName}	= Returns data and/or output parameters for that single database.
				{NULL}			= Same as 'SUMMARY'
				''				= Same as 'SUMMARY'
				'SUMMARY'		= Returns data and/or output parameters for all databases as a
									single series.
				'DETAIL'		= Returns data and/or output parameters for all databases as 
									multiple series.
				
			@TargetSizeMB		= Can be a specific value in MB (Numeric Digits Only), or can be 
									relative by using the '+' Prefix.
									+ Prefix = Adds Target to Existing Size.
									% Suffix = Uses Numeric portion as a percent of Existing Size.
									ex.	{CurrentSize} = 10GB
									
										30000	= 30GB									= 30GB
										+30000	= {CurrentSize}+30GB					= 40GB
										200%	= 200% of {CurrentSize}					= 20GB
										+200%	= {CurrentSize}+200% of {CurrentSize}	= 30GB
										
			@NoDataTable		= specify a 1 here to prevent returning the chart data{DataTable}.
			
			@OutputAsHTML		= specify a 1 here to write an html Chart Report to the '_dbasql\dba_reports' share
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
					,@CurrentSizeMB		FLOAT
					,@CurrentLimit		FLOAT
					
			dbasp_ChartData_DBGrowth	@DBName='WCDS'
										, @TimeTillTarget=@TimeTillTarget OUT
										, @TimeTillCL=@TimeTillCL OUT
										, @CurrentSizeMB=@CurrentSizeMB OUT
										, @CurrentLimit=@CurrentLimit OUT
										
			SELECT @TimeTillTarget,@TimeTillCL,@CurrentSizeMB,@CurrentLimit
										
Created: 2010-03-25. $Modtime: 4/07/00 8:38p $.
--	======================================================================================
--	Revision History
--	Date		Author     			Desc
--	==========	=============== 	=============================================
--	03/25/2010	Steve Ledridge		New sproc
--	01/12/2011	Steve Ledridge		Modified setting start and end date so that
--									hisorical data for the current partial week
--									is not used. 
--	01/20/2011	Steve Ledridge		Removed permenant exclusion of System DB's
--	05/02/2011	Steve Ledridge		Modified formulas to prevent DivideByZero errors.
--  04/20/2012	Steve Ledridge		Rewrote process to be more accurate for Disk level
--									Forecasting by identifying DB growth and evenly applying
--									that to the drives currently holding a growable device.
--	======================================================================================
*/ 

ALTER PROCEDURE	[dbo].[dbasp_ChartData_DBGrowth]
					(
					@DBName					VarChar(50) = NULL --IF NULL A SERVER SUMMARY IS RUN
					,@DriveLetter			CHAR(1) = NULL
					,@TargetSizeMB			VarChar(50) = NULL --IF NULL THIS IS THE SAME AS @CurrentLimit
					,@TimeTillTarget		Int = NULL OUTPUT
					,@TimeTillCL			Int = NULL OUTPUT
					,@CurrentSizeMB			FLOAT = NULL OUTPUT
					,@CurrentLimit			FLOAT = NULL OUTPUT
					,@CurrentLimit2			FLOAT = NULL OUTPUT
					,@NoDataTable			bit = 0
					,@OutputAsHTML			bit = 0
					,@NoComments			bit = 0
					,@Exclusions			VarChar(2048) = NULL
					,@OneYearForcastSizeMB	FLOAT = NULL OUTPUT
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
--		,@CurrentSizeMB		FLOAT
--		,@CurrentLimit		FLOAT
--		,@NoDataTable		Bit
--		,@Exclusions		VarChar(2048)
--SELECT	@DBName				= 'SUMMARY'
--		,@TargetSizeMB		= '+50%'
--		,@NoDataTable		= 0
--		,@Exclusions		= NULL -- Carefull, Can Conflict with @DBName
--------------------------------------------------------------------------------
--
--	SET VARIABLES
--
--------------------------------------------------------------------------------
-- Create Table Variable to hold Current Drive Freespace
DECLARE		@RawData				Table
			(
			EventDate				DateTime
			,ServerName				sysname
			,DatabaseName			sysname
			,DataSize				FLOAT
			,IndexSize				FLOAT
			)
			
CREATE		TABLE					#Results 
			(
			DBName					sysname		COLLATE SQL_Latin1_General_CP1_CI_AS
			,[FileName]				sysname		COLLATE SQL_Latin1_General_CP1_CI_AS
			,FileType				sysname		COLLATE SQL_Latin1_General_CP1_CI_AS
			,Drive					char(1)		COLLATE SQL_Latin1_General_CP1_CI_AS
			,UsedData				FLOAT
			,TotalDataSize			FLOAT
			,Growth					VarChar(50)	COLLATE SQL_Latin1_General_CP1_CI_AS
			)						

CREATE		TABLE					#CurDBSizes 
			(
			DatabaseName			sysname		COLLATE SQL_Latin1_General_CP1_CI_AS
			,data_space_used_KB		FLOAT
			,index_size_used_KB		FLOAT
			)	
			
-- Create Table to hold results
CREATE		TABLE					#ForecastTable  
			(
			ForecastKey				INT 
			,CYear					INT 
			,CWeek					INT
			,Unit					VARCHAR(50) 
			
			,Baseline_MetricA		FLOAT
			,Smoothed_MetricA		FLOAT
			,Trend_MetricA			FLOAT
			,Seasonality_MetricA	FLOAT
			,Forcast_MetricA		FLOAT
			
			,Baseline_MetricB		FLOAT
			,Smoothed_MetricB		FLOAT
			,Trend_MetricB			FLOAT
			,Seasonality_MetricB	FLOAT
			,Forcast_MetricB		FLOAT
			)

-- Create table to store calculations by Item
CREATE		TABLE					#Formula 
			(
			Unit					varchar(50)
			,Counts					int
			,SumX					Numeric(14,4)
			,SumXsqrd				Numeric(14,4)
			,SumY_MetricA			Numeric(14,4)
			,SumXY_MetricA			Numeric(14,4)
			,SumY_MetricB			Numeric(14,4)
			,SumXY_MetricB			Numeric(14,4)
			,b_MetricA				FLOAT
			,a_MetricA				FLOAT
			,b_MetricB				FLOAT
			,a_MetricB				FLOAT
			)

DECLARE		@Periods				TABLE
			(
			ID						INT  IDENTITY(1,1)
			,CYear					INT 
			,CWeek					INT
			,MinDate				DateTime
			,MaxDate				DateTime
			)

DECLARE		@DriveGrowthForecast		TABLE
			(
			[ForecastedPeriod]	INT
			,[Drive]			CHAR(1)
			,[FreeSpace]		FLOAT
			,[Growth]			FLOAT
			)
					
-- Other Variables
DECLARE		@TargetSet				bit
DECLARE		@startDate				datetime
DECLARE		@enddate				datetime
DECLARE		@CurrentPeriod			INT
DECLARE		@CurrentDate			DateTime
DECLARE		@HTMLOutput				VarChar(MAX)
DECLARE		@HTMLOut_Path			VarChar(1024)
DECLARE		@HTMLOut_File			VarChar(1024)
DECLARE		@Factor					Float
DECLARE		@KeyPointer				INT
DECLARE		@FixPointer1			INT
DECLARE		@FixPointer2			INT
DECLARE		@FixValue1				FLOAT
DECLARE		@FixValue2				FLOAT
DECLARE		@FixValue3				FLOAT
DECLARE		@TSQL					VarChar(8000)
DECLARE		@TSQL2					VarChar(8000)
DECLARE		@CurrentUnusedMB		FLOAT
DECLARE		@LastRatio				Float
DECLARE		@CurDB					SYSNAME
DECLARE		@InputValidation		INT
DECLARE		@InputValidationMsg		VarChar(max)
DECLARE		@AllDBSummary			bit
DECLARE		@AllDBDetail			bit
DECLARE		@RelativeTarget			bit
DECLARE		@PercentTarget			bit
DECLARE		@ColumnString			VarChar(max)
DECLARE		@SeriesString			VarChar(max)
DECLARE		@TitleString			VarChar(max)
DECLARE		@SeriesLineStarter		INT
DECLARE		@SeriesCount			INT
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--		SET STARTING VALUES
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
SELECT		@DBName					= NULLIF(@DBName,'')
			,@AllDBSummary			= CASE WHEN @DBName = 'SUMMARY' THEN 1 ELSE 0 END
			,@AllDBDetail			= CASE WHEN @DBName = 'DETAIL' THEN 1 ELSE 0 END
			,@DBName				= CASE WHEN @DBName IN('SUMMARY','DETAIL') THEN NULL ELSE @DBName END
			,@DriveLetter			= NULLIF(@DriveLetter,'')
			,@TargetSet				= CASE WHEN @DBName IS NOT NULL THEN 1 WHEN @DriveLetter IS NOT NULL THEN 1 ELSE 0 END
			,@InputValidation		= 0
			,@Factor				= 1			--B
									/1024		--KB
									/1024		--MB
									--/1024		--GB
									--/1024		--TB
			 -- NOW
			,@CurrentDate			= CAST(CONVERT(VarChar(12),GetDate(),101)AS DateTime)
			,@RelativeTarget		= CASE WHEN LEFT(@TargetSizeMB,1) = '+' THEN 1 ELSE 0 END
			,@PercentTarget			= CASE WHEN RIGHT(@TargetSizeMB,1) = '%' THEN 1 ELSE 0 END
			,@TargetSizeMB			= CASE @RelativeTarget WHEN 1 THEN STUFF(@TargetSizeMB,1,1,'') ELSE @TargetSizeMB END
			,@TargetSizeMB			= CASE @PercentTarget WHEN 1 THEN LEFT(@TargetSizeMB,LEN(@TargetSizeMB)-1) ELSE @TargetSizeMB END
			



			-- SET START AND END DATE TO MAXIMUM RANGE ALLOWED TO BE EXTRACTED FROM HISTORICAL DATA
			-- VALUES WILL BE RESET TO ACTUAL DATA LIMITS IF SMALLER
			 -- END OF LAST WEEK
			,@enddate				= DATEADD(ms,-2,DATEADD(day,((DATEPART(dw,@CurrentDate)-1)*-1),@CurrentDate))

			 -- ONE YEAR AGO FROM FIRST OF THIS WEEK
			,@startDate				= DATEADD(ms,2,DATEADD(year,-1,@enddate)) 

---------------------------------------------------------------------------------------------------
--		POPULATE #DiskInfo
---------------------------------------------------------------------------------------------------
SELECT		* 
INTO		#DiskInfo 
FROM		[dbaadmin].[dbo].[dbaudf_ListDrives]() 
WHERE		IsReady = 'True'

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--		POPULATE #Results BUILD SCRIPT
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
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
AND T1.name != ''tempdb''

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
AND T1.name != ''tempdb''

INSERT INTO #CurDBSizes
SELECT		DB_NAME() [DatabaseName]
			,CAST([DataPages] AS FLOAT) * 8192. /1024. [data_space_used_KB]			
			,(CAST([UsedPages] AS FLOAT)-CAST([DataPages] AS FLOAT)) * 8192. /1024. [index_size_used_KB]
FROM		(
			SELECT	sum(a.used_pages) [UsedPages]
					,sum(CASE		-- XML-Index and FT-Index-Docid is not considered "data", but is part of "index_size"
									When it.internal_type IN (202,204) Then 0
									When a.type <> 1 Then a.used_pages
									When p.index_id < 2 Then a.data_pages
									Else 0
									END) [DataPages]
			from	sys.partitions p 
			join	sys.allocation_units a 
				on	p.partition_id = a.container_id
			left	join sys.internal_tables it 
				on	p.object_id = it.object_id
			) DBPages'

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--		POPULATE #Results RUN CURSOR
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
DECLARE DBCursor CURSOR
FOR
SELECT	DISTINCT 
		name
FROM	sys.databases
WHERE	state = 0
	AND	name != 'TempDB'
	
OPEN DBCursor
FETCH NEXT FROM DBCursor INTO @CurDB
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET		@TSQL2 = REPLACE(@TSQL,'?',@CurDB)
		EXEC	(@TSQL2)
	END
	FETCH NEXT FROM DBCursor INTO @CurDB
END
CLOSE DBCursor
DEALLOCATE DBCursor

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--		BEGIN INPUT VALIDATION
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
SET @InputValidation = CASE
	---------------------------------------------------
	---------------------------------------------------
	-- ERRORS
	---------------------------------------------------
		---------------------------------------------------
		-- DBNAME ERRORS
		---------------------------------------------------
		WHEN @DBName IS NOT NULL AND @DBName IN ('TempDB') 
			THEN -1 -- RESTRICTED DBNAME
		WHEN @DBName IS NOT NULL AND @DBName IN (Select DISTINCT SplitValue FROM dbaadmin.dbo.dbaudf_split(@Exclusions,',')) 
				THEN -2 -- INCLUDE AND EXCLUED SAME DBNAME
		WHEN @DBName IS NOT NULL AND @DBName NOT IN (SELECT name FROM SYS.DATABASES WHERE state = 0)
			THEN -3 -- DBNAME NOT VALID OR ONLINE
		---------------------------------------------------
		-- DRIVELETTER ERRORS
		---------------------------------------------------
		WHEN @DriveLetter IS NOT NULL AND @DriveLetter NOT IN (SELECT DriveLetter FROM #DiskInfo)
			THEN -4 -- DRIVE LETTER NOT VALID OR READY
			
		WHEN @TargetSizeMB IS NOT NULL AND ISNUMERIC(@TargetSizeMB) = 0
			THEN -5 -- TARGET VALUE IS NOT A NUMBER
			
	---------------------------------------------------
	---------------------------------------------------
	-- WARNINGS
	---------------------------------------------------
		---------------------------------------------------
		-- DRIVELETTER WARNINGS
		---------------------------------------------------
		WHEN @DriveLetter NOT IN (SELECT DISTINCT Drive FROM #Results WHERE Growth != 'No Growth' and DBName NOT IN ('master','model','msdb','tempdb') )
			THEN 1 -- DRIVE LETTER NOT GROWING

		---------------------------------------------------
		-- ALL DATABASE DETAILS WARNINGS
		---------------------------------------------------
		WHEN @DriveLetter IS NULL AND @DBName IS NULL
			THEN 9 -- DRIVE LETTER NOT GROWING


		ELSE 0 END;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--		REACT TO INPUT VALIDATION
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
IF @InputValidation <> 0
BEGIN
	SET @InputValidationMsg = CASE @InputValidation
		-- ERRORS
		WHEN -1	THEN @DBName + ' is not a valid option for @DBName.'
		WHEN -2	THEN @DBName + ' is not allowed as @DBName value and within the @Exclusions Parameter.'
		WHEN -3	THEN @DBName + ' is not a Valid or Online Database Name.'
		WHEN -4	THEN @DriveLetter +' is not a Valid or Ready Drive Letter.'
		WHEN -5	THEN @TargetSizeMB + ' is not a valid number for @TargetSizeMB'
		WHEN -6	THEN ''
		WHEN -7	THEN ''
		WHEN -8	THEN ''
		WHEN -9	THEN ''
		-- WARNINGS
		WHEN 1	THEN @DriveLetter +' currently has no growable databases on it.'
		WHEN 2	THEN ''
		WHEN 3	THEN ''
		WHEN 4	THEN ''
		WHEN 5	THEN ''
		WHEN 6	THEN ''
		WHEN 7	THEN ''
		WHEN 8	THEN ''
		WHEN 9	THEN 'No @DBName or @DriveLetter specified. Results will be Details for All Databases'
		
		ELSE 'Unknown Validation Error' END
		
	PRINT @InputValidationMsg

	--ONLY EXIT FOR ERRORS NOT WARNINGS
	IF @InputValidation < 0
		GOTO EndWithoutRunning
END
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--		START PROCESSING
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------
	--		POPULATE @RawData FROM [dbaperf].[dbo].[db_stats_log] TABLE
	---------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------
	DECLARE DBCursor CURSOR
	FOR
	SELECT	DISTINCT 
			name
	FROM	sys.databases
	WHERE	state = 0
		AND	name != 'TempDB'
		
	OPEN DBCursor
	FETCH NEXT FROM DBCursor INTO @CurDB
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			INSERT INTO	@RawData
			SELECT		[rundate]
						,[ServerName]
						,[DatabaseName]
						,SUM(CAST([data_space_used_KB] AS FLOAT) / 1024) DataSize
						,SUM(CAST([index_size_used_KB] AS FLOAT) / 1024) IndexSize
			FROM		[dbaperf].[dbo].[db_stats_log] [db_stats_log]
			WHERE		[DatabaseName] = @CurDB
				AND		[rundate] >= @startDate
				AND		[rundate] <= @endDate
			GROUP BY	[rundate]
						,[ServerName]
						,[DatabaseName]
		END
		FETCH NEXT FROM DBCursor INTO @CurDB
	END
	CLOSE DBCursor
	DEALLOCATE DBCursor
	---------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------
	--		REMOVE CURRENT WEEK IF IT EXISTS
	---------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------
	DELETE		@RawData
	WHERE		DATEPART(year,[EventDate]) = DATEPART(year,@CurrentDate)
		AND		DATEPART(week,[EventDate]) = DATEPART(week,@CurrentDate)
	---------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------
	--		ADD CURRENT WEEK BASED ON CURRENT VALUES
	---------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------
	INSERT INTO	@RawData
	SELECT		@CurrentDate					[EventDate]
				,@@SERVERNAME					[ServerName]
				,[DatabaseName]					[DBName]
				,[data_space_used_KB] / 1024	[DataSize]
				,[index_size_used_KB] / 1024	[IndexSize]			
	FROM		#CurDBSizes

	---------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--		RESET DATES TO DATES IN ARCHIVE
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
SELECT		@startDate	= MIN(EventDate)
			,@enddate	= MAX(EventDate)
FROM		@RawData

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--		POPULATE @Periods
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
WHILE @startDate<@enddate
BEGIN

	UPDATE		@Periods	
			SET	MaxDate = @startDate
	WHERE		CYear = YEAR(@startDate)
			AND	CWeek = DATEPART(week ,@startDate)
			
	If @@ROWCOUNT = 0		
	BEGIN
	INSERT INTO @Periods (CYear,CWeek,MinDate,MaxDate)
	SELECT	YEAR(@startDate)			[Year]
			,DATEPART(week ,@startDate) [Week]
			,@startDate					[MinDate]
			,@startDate					[MaxDate]
	END
	SET @startDate = @startDate +1
END

--Print 'Getting @CurrentPeriod'
SELECT		@CurrentPeriod = ID
FROM		@Periods
WHERE		[cYear] = DATEPART(year,@CurrentDate)
		AND	[cWeek] = DATEPART(week,@CurrentDate)
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--		RESET DATES TO DATES IN ARCHIVE
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
SELECT		@startDate	= MIN(EventDate)
			,@enddate	= MAX(EventDate)
FROM		@RawData

--*****************************************************************************
--
--	Step 1 - Populate Forcast Table with all historical Data Grouped By Year-Week.
--		Then update Smoothed_Value with a central moving average
--		
--*****************************************************************************
INSERT INTO #ForecastTable (ForecastKey,CYear, CWeek, Unit, Baseline_MetricA, Baseline_MetricB)
SELECT		ID
			,[Year]
			,[Week]
			,[Unit]
			,MAX(COALESCE([MetricA],0)) [MetricA] 
			,MAX(COALESCE([MetricB],0)) [MetricB]
FROM		(
			SELECT		P1.ID						[ID]
						,P1.CYear					[Year]
						,P1.CWeek					[Week]
						,[DatabaseName]				[Unit]
						,CAST([DataSize] AS FLOAT)	[MetricA]
						,CAST([IndexSize] AS FLOAT)	[MetricB]
			FROM		@Periods P1
			LEFT JOIN	@RawData T1
				ON		P1.CYear = YEAR([EventDate])
				AND		P1.CWeek = DATEPART(week,[EventDate])
			) Data	
GROUP BY	ID
			,[Year]
			,[Week]
			,[Unit]
ORDER BY	ID,[Unit]


FixEmptyValue:
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--		FIX ANY LEADING PERIODS WITH 0's in Baseline_MetricA
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
;WITH		EP
			AS
			(
			SELECT		Unit
						,ForecastKey
						,(SELECT MIN(ForecastKey) FROM #ForecastTable WHERE Unit = FT.Unit and ForecastKey > 1 AND Baseline_MetricA != 0) FirstKeyWithValue
						,(SELECT MIN(ForecastKey) FROM #ForecastTable WHERE Unit = FT.Unit and ForecastKey > (SELECT MIN(ForecastKey) FROM #ForecastTable WHERE Unit = FT.Unit and ForecastKey > 1 AND Baseline_MetricA != 0) AND Baseline_MetricA != 0) NextKeyWithValue
						,Baseline_MetricA
			FROM		#ForecastTable FT
			WHERE		ForecastKey = 1
					AND	Baseline_MetricA = 0
			)
UPDATE		EP
	SET		Baseline_MetricA = 
				(SELECT Baseline_MetricA FROM #ForecastTable WHERE Unit = EP.Unit and ForecastKey = EP.FirstKeyWithValue) -
				((((SELECT Baseline_MetricA FROM #ForecastTable WHERE Unit = EP.Unit and ForecastKey = EP.NextKeyWithValue)
					-(SELECT Baseline_MetricA FROM #ForecastTable WHERE Unit = EP.Unit and ForecastKey = EP.FirstKeyWithValue))
					/(EP.NextKeyWithValue-EP.FirstKeyWithValue))*(EP.FirstKeyWithValue-EP.ForecastKey))

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--		FIX ANY LEADING PERIODS WITH 0's in Baseline_MetricB
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
;WITH		EP
			AS
			(
			SELECT		Unit
						,ForecastKey
						,(SELECT MIN(ForecastKey) FROM #ForecastTable WHERE Unit = FT.Unit and ForecastKey > 1 AND Baseline_MetricB != 0) FirstKeyWithValue
						,(SELECT MIN(ForecastKey) FROM #ForecastTable WHERE Unit = FT.Unit and ForecastKey > (SELECT MIN(ForecastKey) FROM #ForecastTable WHERE Unit = FT.Unit and ForecastKey > 1 AND Baseline_MetricB != 0) AND Baseline_MetricB != 0) NextKeyWithValue
						,Baseline_MetricB
			FROM		#ForecastTable FT
			WHERE		ForecastKey = 1
					AND	Baseline_MetricB = 0
			)
UPDATE		EP
	SET		Baseline_MetricB = 
				(SELECT Baseline_MetricB FROM #ForecastTable WHERE Unit = EP.Unit and ForecastKey = EP.FirstKeyWithValue) -
				((((SELECT Baseline_MetricB FROM #ForecastTable WHERE Unit = EP.Unit and ForecastKey = EP.NextKeyWithValue)
					-(SELECT Baseline_MetricB FROM #ForecastTable WHERE Unit = EP.Unit and ForecastKey = EP.FirstKeyWithValue))
					/(EP.NextKeyWithValue-EP.FirstKeyWithValue))*(EP.FirstKeyWithValue-EP.ForecastKey))


---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--		FIX ANY OTHER PERIODS WITH 0's in Baseline_MetricA
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
;WITH		EP
			AS
			(
			SELECT		Unit
						,ForecastKey
						,(SELECT MAX(ForecastKey) FROM #ForecastTable WHERE Unit = FT.Unit and ForecastKey < FT.ForecastKey AND Baseline_MetricA != 0) LastKeyWithValue
						,(SELECT MIN(ForecastKey) FROM #ForecastTable WHERE Unit = FT.Unit and ForecastKey > FT.ForecastKey AND Baseline_MetricA != 0) NextKeyWithValue
						,Baseline_MetricA
			FROM		#ForecastTable FT
			WHERE		Baseline_MetricA = 0
			)
UPDATE		EP
	SET		Baseline_MetricA = 
				(SELECT ForecastKey FROM #ForecastTable WHERE Unit = EP.Unit and ForecastKey = EP.LastKeyWithValue) +
				((((SELECT ForecastKey FROM #ForecastTable WHERE Unit = EP.Unit and ForecastKey = EP.NextKeyWithValue)-(SELECT ForecastKey FROM #ForecastTable WHERE Unit = EP.Unit and ForecastKey = EP.LastKeyWithValue))/(EP.NextKeyWithValue-EP.LastKeyWithValue))*(EP.ForecastKey-EP.LastKeyWithValue))


---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--		FIX ANY OTHER PERIODS WITH 0's in Baseline_MetricB
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
;WITH		EP
			AS
			(
			SELECT		Unit
						,ForecastKey
						,(SELECT MAX(ForecastKey) FROM #ForecastTable WHERE Unit = FT.Unit and ForecastKey < FT.ForecastKey AND Baseline_MetricB != 0) LastKeyWithValue
						,(SELECT MIN(ForecastKey) FROM #ForecastTable WHERE Unit = FT.Unit and ForecastKey > FT.ForecastKey AND Baseline_MetricB != 0) NextKeyWithValue
						,Baseline_MetricB
			FROM		#ForecastTable FT
			WHERE		Baseline_MetricB = 0
			)
UPDATE		EP
	SET		Baseline_MetricB = 
				(SELECT ForecastKey FROM #ForecastTable WHERE Unit = EP.Unit and ForecastKey = EP.LastKeyWithValue) +
				((((SELECT ForecastKey FROM #ForecastTable WHERE Unit = EP.Unit and ForecastKey = EP.NextKeyWithValue)-(SELECT ForecastKey FROM #ForecastTable WHERE Unit = EP.Unit and ForecastKey = EP.LastKeyWithValue))/(EP.NextKeyWithValue-EP.LastKeyWithValue))*(EP.ForecastKey-EP.LastKeyWithValue))

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
				AND		(a.ForecastKey - b.ForecastKey) BETWEEN -5 AND 5 -- Averaged with the 2 periods before and after.
			GROUP BY	a.ForecastKey
						,a.Unit
			) MovAvg
WHERE		Unit = MovAvg.XUnit
	AND		ForecastKey = MovAvg.FKey
	
--Print 'Starting Step 2'		
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
		SET		b_MetricA	= ((tb.counts * tb.sumXY_MetricA)-(tb.sumX * tb.sumY_MetricA))/ isnull(nullif((tb.Counts * tb.sumXsqrd - power(tb.sumX,2)),0),1)
				,b_MetricB	= ((tb.counts * tb.sumXY_MetricB)-(tb.sumX * tb.sumY_MetricB))/ isnull(nullif((tb.Counts * tb.sumXsqrd - power(tb.sumX,2)),0),1)
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
		SET		a_MetricA	= ((tb2.sumY_MetricA - tb2.b_MetricA * tb2.sumX) / isnull(nullif(tb2.Counts,0),1))
				,a_MetricB	= ((tb2.sumY_MetricB - tb2.b_MetricB * tb2.sumX) / isnull(nullif(tb2.Counts,0),1))
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
				,Seasonality_MetricA = CASE WHEN Baseline_MetricA = 0 THEN 1 ELSE Baseline_MetricA /isnull(nullif((A_MetricA + (B_MetricA * ForecastKey)),0),1) END
				,Seasonality_MetricB = CASE WHEN Baseline_MetricB = 0 THEN 1 ELSE Baseline_MetricB /isnull(nullif((A_MetricB + (B_MetricB * ForecastKey)),0),1) END
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

--Print 'Starting Step 3'
--**********************************************************************************
--
--	Step 3 - Insert Trendline and forecast into Forecast table for future Dates.
--		
--**********************************************************************************

		----------------------------------------------------------------------------
		----------------------------------------------------------------------------
		-- COSMETIC FIX TO GET FORCAST TO START RIGHT FROM LAST RECORDED
		----------------------------------------------------------------------------
		----------------------------------------------------------------------------
		UPDATE		#ForecastTable
			SET		Forcast_MetricA		= Baseline_MetricA
					,Forcast_MetricB	= Baseline_MetricB
		WHERE		CYear = YEAR(@CurrentDate)	
			AND	CWeek = DatePart(week,@CurrentDate) 

		-- Create Forecast
		DECLARE @Loop as int
		SET @Loop = 1

		WHILE @Loop <52 -- ONE YEAR
			BEGIN

				INSERT INTO	#ForecastTable (Forecastkey,CYear, CWeek, Unit, Trend_MetricA, Trend_MetricB, Forcast_MetricA, Forcast_MetricB)
				SELECT		MAX(Forecastkey) + 1 
							,YEAR(dateadd(week,@Loop,@CurrentDate))
							,DatePart(week,dateadd(week,@Loop,@CurrentDate))
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
								AND SeasonalMask.CWeek = DatePart(week,dateadd(week,@Loop,@CurrentDate))
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
								AND SeasonalMask.CWeek = DatePart(week,dateadd(week,@Loop,@CurrentDate))
								),1) Forcast_MetricB	-- Trendline * Avg seasonality
				FROM		#ForecastTable a
				INNER JOIN	#Formula b
					ON	a.Unit = b.Unit
				WHERE @loop <= @CurrentPeriod -- ONLY FORECAST AS FAR AS DATA GOES BACK
				GROUP BY	a.Unit

			SET @Loop = @Loop +1
			END


SET			@Loop = @CurrentPeriod + 1
WHILE		@Loop < (SELECT max(ForecastKey) FROM #ForecastTable) + 1
BEGIN
	;WITH		ForecastSummary 
				AS
				(
				SELECT		T1.*
							,T4.[Forecast]										[Forecast]
							,T4.[Forecast] - T1.[CurrentSize]					[TotalGrowth]
							,T2.Drive											[Drive]
							,T5.FreeSpace/1024.0/1024							[FreeSpace]
							,(T4.[Forecast] - T1.[CurrentSize])/T3.[DriveCount]	[DriveGrowth]
				FROM		(
							SELECT		ForecastKey							[CurrentPeriod]
										,Unit								[DBName]	
										,Forcast_MetricA+Forcast_MetricB	[CurrentSize]
							FROM		#ForecastTable
							WHERE		ForecastKey = @CurrentPeriod
									AND	Unit NOT IN (Select DISTINCT SplitValue FROM dbaadmin.dbo.dbaudf_split(@Exclusions,','))
							)T1
				JOIN		(
							SELECT		DISTINCT
										DBName
										,Drive
							FROM		#Results
							WHERE		FileType != 'LOG'
									AND	Growth != 'No Growth'
									AND	DBName NOT IN (Select DISTINCT SplitValue FROM dbaadmin.dbo.dbaudf_split(@Exclusions,','))

							)T2
						ON	T1.DBName = T2.DBName
				JOIN		(
							SELECT		DBName
										,COUNT(DISTINCT Drive) [DriveCount]
							FROM		#Results
							WHERE		FileType != 'LOG'
									AND	Growth != 'No Growth'
									AND	DBName NOT IN (Select DISTINCT SplitValue FROM dbaadmin.dbo.dbaudf_split(@Exclusions,','))
							GROUP BY	DBName
							)T3
						ON	T1.DBName = T3.DBName
				JOIN		(
							SELECT		ForecastKey							[MaxForecastedPeriod]
										,Unit								[DBName]
										,Forcast_MetricA+Forcast_MetricB	[Forecast]
							FROM		#ForecastTable
							WHERE		ForecastKey = @Loop
									AND	Unit NOT IN (Select DISTINCT SplitValue FROM dbaadmin.dbo.dbaudf_split(@Exclusions,','))
							) T4
						ON	T4.DBName = T1.DBName			
				JOIN		#DiskInfo T5
						ON	T5.DriveLetter COLLATE SQL_Latin1_General_CP1_CI_AS = T2.Drive COLLATE SQL_Latin1_General_CP1_CI_AS
				)
	INSERT INTO	@DriveGrowthForecast				
	SELECT		@Loop					[ForecastedPeriod]
				,[Drive]				[Drive]
				,MAX([FreeSpace])		[FreeSpace]
				,SUM([DriveGrowth])		[Growth]
	FROM		ForecastSummary
	WHERE		[Drive] IN (SELECT DISTINCT Drive FROM #Results WHERE Growth != 'No Growth')
	GROUP BY	[Drive]

	SET @Loop = @Loop +1
END

----------------------------------------------------------------------------
----------------------------------------------------------------------------
--		OUTPUT DRIVE SUMMARY TABLE
----------------------------------------------------------------------------
----------------------------------------------------------------------------

IF @TargetSet = 0 AND @AllDBSummary = 0 AND @AllDBDetail = 0
BEGIN
	;WITH		DriveFullDates
				AS
				(
				SELECT		Drive
							,MIN([DateFull]) [DateFull]
				FROM		(			
							SELECT		*
										,CASE WHEN [FreeSpace]-[Growth] <= 0 THEN 'FULL' ELSE 'OK' END AS [DriveStatus]
										,CASE WHEN [FreeSpace]-[Growth] <= 0 THEN DATEADD (week,ForecastedPeriod-1,(SELECT CAST(CONVERT(VarChar(12),MinDate,101)AS DateTime) FROM @Periods WHERE ID = 2)) ELSE NULL END AS [DateFull]
										,CASE WHEN [FreeSpace]-[Growth] <= 0 THEN ForecastedPeriod-@CurrentPeriod ELSE NULL END AS [WeeksTillFull]
							FROM		@DriveGrowthForecast T1
							) Data
				GROUP BY	Drive			
				)

	SELECT		T1.*
				,T2.[DateFull]
				,(STUFF((SELECT DISTINCT ',' + DBName FROM #Results Where Drive = T1.DriveLetter COLLATE SQL_Latin1_General_CP1_CI_AS ORDER BY ',' +DBName FOR XML PATH(''), TYPE, ROOT).value('root[1]','nvarchar(max)'),1,1,'')) [DBsOnDrive]
				,(STUFF((SELECT DISTINCT ',' + DBName FROM #Results Where Growth != 'No Growth' AND Drive = T1.DriveLetter COLLATE SQL_Latin1_General_CP1_CI_AS ORDER BY ',' +DBName FOR XML PATH(''), TYPE, ROOT).value('root[1]','nvarchar(max)'),1,1,'')) [GrowingDBsOnDrive]
				
	FROM		#DiskInfo		T1
	LEFT JOIN	DriveFullDates	T2
			ON	T1.DriveLetter COLLATE SQL_Latin1_General_CP1_CI_AS = T2.Drive COLLATE SQL_Latin1_General_CP1_CI_AS


END

IF @TargetSet = 1
BEGIN
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	--		CALCULATE CURRENT SIZE AND LIMIT IF TARGET WAS SET
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	SELECT	@CurrentSizeMB = CASE WHEN @DBName IS NOT NULL 
								THEN (SELECT CAST([data_space_used_KB]+[index_size_used_KB] AS FLOAT)/1024 FROM #CurDBSizes WHERE [DatabaseName] = @DBName)
								ELSE (SELECT CAST([TotalSize]-[FreeSpace] AS FLOAT)/1024/1024 FROM #DiskInfo WHERE DriveLetter = @DriveLetter)
								END
			,@CurrentLimit = CASE WHEN @DBName IS NOT NULL 
								THEN (SELECT CAST([data_space_used_KB]+[index_size_used_KB] AS FLOAT)/1024 FROM #CurDBSizes WHERE [DatabaseName] = @DBName)
										+ (SELECT SUM(CAST([FreeSpace] AS FLOAT))/1024/1024 FROM #DiskInfo WHERE DriveLetter IN(SELECT Drive FROM #Results Where Growth != 'No Growth' AND DBName = @DBName))
								ELSE (SELECT CAST([TotalSize] AS FLOAT)/1024/1024 FROM #DiskInfo WHERE DriveLetter = @DriveLetter)
								END								
								
END								
ELSE 
	SET @CurrentSizeMB = NULL


----------------------------------------------------------------------------
----------------------------------------------------------------------------
--		CALCULATE TARGET SIZE
----------------------------------------------------------------------------
----------------------------------------------------------------------------
IF @CurrentSizeMB IS NOT NULL								
	IF @RelativeTarget = 1
		IF @PercentTarget = 1
			SET @TargetSizeMB = @CurrentSizeMB + ((@TargetSizeMB*@CurrentSizeMB)/100)
		ELSE
			SET @TargetSizeMB = @CurrentSizeMB + @TargetSizeMB
	ELSE
		IF @PercentTarget = 1
			SET @TargetSizeMB = ((@TargetSizeMB*@CurrentSizeMB)/100)

----------------------------------------------------------------------------
----------------------------------------------------------------------------
--		Store #FinalData
----------------------------------------------------------------------------
----------------------------------------------------------------------------
SELECT		*
INTO		#FinalData
FROM		(
			SELECT		Unit
						, ForecastKey
						, CAST(CYear AS VarChar(4)) + '-' + RIGHT('00'+CAST(CWeek AS VarChar(2)),2) [Period]
						, CAST(CASE WHEN COALESCE(Baseline_MetricA,0) + COALESCE(Baseline_MetricB,0) = 0 THEN NULL ELSE COALESCE(Baseline_MetricA,0) + COALESCE(Baseline_MetricB,0)END AS FLOAT) [Recorded] 
						, CAST(CASE WHEN COALESCE(Forcast_MetricA,0) + COALESCE(Forcast_MetricB,0) = 0 THEN NULL ELSE COALESCE(Forcast_MetricA,0) + COALESCE(Forcast_MetricB,0)END AS Float) [Forecast]
						, CAST(Trend_MetricA + Trend_MetricB AS Float) [Trend]
						, CAST(@CurrentSizeMB AS Float) [CurrentSizeMB]	
						, CAST(@TargetSizeMB AS Float) [TargetSizeMB]
						, CAST(@CurrentLimit AS Float) [CurrentLimitMB]
			FROM		#ForecastTable
			WHERE		(Unit = @DBName OR @AllDBDetail = 1)
					AND Forecastkey >= @CurrentPeriod - 52
					AND	Forecastkey <= @CurrentPeriod + 52
					AND	Unit NOT IN (Select DISTINCT SplitValue FROM dbaadmin.dbo.dbaudf_split(@Exclusions,','))
			UNION ALL
			
			SELECT		'AllDBSummary' [Unit]
						, ForecastKey
						, CAST(CYear AS VarChar(4)) + '-' + RIGHT('00'+CAST(CWeek AS VarChar(2)),2) [Period]
						, SUM(CAST(CASE WHEN COALESCE(Baseline_MetricA,0) + COALESCE(Baseline_MetricB,0) = 0 THEN NULL ELSE COALESCE(Baseline_MetricA,0) + COALESCE(Baseline_MetricB,0)END AS FLOAT)) [Recorded] 
						, SUM(CAST(CASE WHEN COALESCE(Forcast_MetricA,0) + COALESCE(Forcast_MetricB,0) = 0 THEN NULL ELSE COALESCE(Forcast_MetricA,0) + COALESCE(Forcast_MetricB,0)END AS Float)) [Forecast]
						, SUM(CAST(Trend_MetricA + Trend_MetricB AS Float)) [Trend]
						, SUM(CAST(@CurrentSizeMB AS Float)) [CurrentSizeMB]	
						, SUM(CAST(@TargetSizeMB AS Float)) [TargetSizeMB]
						, SUM(CAST(@CurrentLimit AS Float)) [CurrentLimitMB]
			FROM		#ForecastTable
			WHERE		@AllDBSummary = 1
					AND Forecastkey >= @CurrentPeriod - 52
					AND	Forecastkey <= @CurrentPeriod + 52
					AND	Unit NOT IN (Select DISTINCT SplitValue FROM dbaadmin.dbo.dbaudf_split(@Exclusions,','))
			GROUP BY	ForecastKey,CAST(CYear AS VarChar(4)) + '-' + RIGHT('00'+CAST(CWeek AS VarChar(2)),2)

			UNION ALL
			
			SELECT		'Drive_' + [Drive] [Unit]
						, ForecastedPeriod ForecastKey
						, (SELECT TOP 1 CAST(CYear AS VarChar(4)) + '-' + RIGHT('00'+CAST(CWeek AS VarChar(2)),2) FROM #ForecastTable WHERE ForecastKey = T1.ForecastedPeriod)[Period]
						, NULL [Recorded] 
						, @CurrentSizeMB + [Growth] [Forecast]
						, NULL [Trend]
						, CAST(@CurrentSizeMB AS Float) [CurrentSizeMB]	
						, CAST(@TargetSizeMB AS Float) [TargetSizeMB]
						, CAST(@CurrentLimit AS Float) [CurrentLimitMB]
			FROM		@DriveGrowthForecast T1
			WHERE		[Drive] = @DriveLetter
			) FinalData
ORDER BY	1,2

----------------------------------------------------------------------------
----------------------------------------------------------------------------
--		CALCULATE @TimeTillTarget
----------------------------------------------------------------------------
----------------------------------------------------------------------------
IF @TargetSet = 1
	--IF @DBName IS NOT NULL
		SELECT		TOP 1
					@TimeTillTarget = ForecastKey - @CurrentPeriod
		FROM		#FinalData
		WHERE		Unit = CASE WHEN @DriveLetter IS NOT NULL AND @DBName IS NULL THEN 'Drive_'+ @DriveLetter ELSE @DBName END
				AND ForecastKey > @CurrentPeriod
				AND	Forecast >= @TargetSizeMB
		ORDER BY	ForecastKey 
	--ELSE
	--	SELECT		TOP 1
	--				@TimeTillTarget = ForecastedPeriod - @CurrentPeriod
	--	FROM		@DriveGrowthForecast
	--	WHERE		Drive = @DriveLetter
	--			AND	Growth >= @TargetSizeMB-@CurrentSizeMB
		
	
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--		CALCULATE @TimeTillCL
----------------------------------------------------------------------------
----------------------------------------------------------------------------
IF @TargetSet = 1
	SELECT		TOP 1
				@TimeTillCL = ForecastKey - @CurrentPeriod
	FROM		#FinalData
	WHERE		Unit = CASE WHEN @DriveLetter IS NOT NULL AND @DBName IS NULL THEN 'Drive_'+ @DriveLetter ELSE @DBName END
			AND ForecastKey > @CurrentPeriod
			AND	Forecast >= @CurrentLimit
	ORDER BY	ForecastKey 

----------------------------------------------------------------------------
----------------------------------------------------------------------------
--		CALCULATE @OneYearForcastSizeMB
----------------------------------------------------------------------------
----------------------------------------------------------------------------
IF @TargetSet = 1
	SELECT		TOP 1 
				@OneYearForcastSizeMB = CASE 
							WHEN Forecast = 0 THEN NULL 
							ELSE Forecast
							END
	FROM		#FinalData
	WHERE		Unit = CASE WHEN @DriveLetter IS NOT NULL AND @DBName IS NULL THEN 'Drive_'+ @DriveLetter ELSE @DBName END
	ORDER BY	ForecastKey DESC
		
-- Review results
IF @NoComments = 0
BEGIN
			
	PRINT		CASE WHEN @DriveLetter IS NOT NULL AND @DBName IS NULL THEN 
				'Drive:												' + @DriveLetter 
				ELSE 
				'Database:					' + @DBName 
				END
	PRINT		'Exclusions:				' + ISNULL(@Exclusions,'')
	PRINT		'Current Size:				' + [dbaadmin].[dbo].[dbaudf_FormatNumber] (CAST(@CurrentSizeMB AS FLOAT)/1024,23,2) + ' GB'
	PRINT		'Target Size:				' + [dbaadmin].[dbo].[dbaudf_FormatNumber] (CAST(@TargetSizeMB AS FLOAT)/1024,23,2) + ' GB'
	PRINT		'Time Till Target:			' + COALESCE([dbaadmin].[dbo].[dbaudf_FormatNumber] (@TimeTillTarget,20,0) + ' Weeks','Not within Current Forcast') 
	PRINT		'Current Limit:				' + [dbaadmin].[dbo].[dbaudf_FormatNumber] (@CurrentLimit/1024,23,2) + ' GB'
	PRINT		'Time Till Current Limit:	' + COALESCE([dbaadmin].[dbo].[dbaudf_FormatNumber] (@TimeTillCL,20,0) + ' Weeks','Not within Current Forcast')
	PRINT		'One Year Forcasted Size:	' + [dbaadmin].[dbo].[dbaudf_FormatNumber] (@OneYearForcastSizeMB/1024,23,2) + ' GB'
	PRINT		''
END

If @NoDataTable = 0	
BEGIN			
	SELECT		Unit
				, [Period]
				, [Recorded] 
				, [Forecast]
				, [Trend]
				, [CurrentSizeMB]	
				, [TargetSizeMB]
				, [CurrentLimitMB]
	FROM		#FinalData
	ORDER BY	1,2
END

If @OutputAsHTML = 1		
BEGIN 

	SELECT		@HTMLOutput = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <title>
      Getty Images Opperations Report
    </title>
    <script type="text/javascript" src="http://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load(''visualization'', ''1'', {packages: [''table'',''corechart'']});
    </script>
    <script type="text/javascript">
      function drawVisualization() {
        // Create and populate the data table.
        var data = new google.visualization.DataTable();
        data.addColumn(''string'', ''Name'');
        data.addColumn(''number'', ''Recorded'');
        data.addColumn(''number'', ''Forecast'');
        data.addColumn(''number'', ''Trend'');
        data.addColumn(''number'', ''Current'');
        data.addColumn(''number'', ''Target'');
        data.addColumn(''number'', ''Limit'');  
        data.addRows(['+CHAR(13)+CHAR(10)

;WITH			SummaryStrings
				AS
				(
				SELECT		[ColumnString]	= '0'
											+ CASE [Recorded]		WHEN 0 THEN '' ELSE ',1' END
											+ ',2' -- Always Include Forecast Column
											+ CASE [Trend]			WHEN 0 THEN '' ELSE ',3' END
											+ CASE [CurrentSizeMB]	WHEN 0 THEN '' ELSE ',4' END
											+ CASE [TargetSizeMB]	WHEN 0 THEN '' ELSE ',5' END
											+ CASE [CurrentLimitMB]	WHEN 0 THEN '' ELSE ',6' END
				FROM		(
							SELECT		MAX(ISNULL([Recorded],0))			[Recorded]
										,MAX(ISNULL([Trend],0))				[Trend]
										,MAX(ISNULL([CurrentSizeMB],0))		[CurrentSizeMB]
										,MAX(ISNULL([TargetSizeMB],0))		[TargetSizeMB]
										,MAX(ISNULL([CurrentLimitMB],0))	[CurrentLimitMB]
							FROM		#FinalData
							) DataMaxes
				)
								
	SELECT		@HTMLOutput		= @HTMLOutput
								+ '            [''' + [Period]
								+ ''','	+ CAST(COALESCE([Recorded],'')			AS VarChar(50))
								+ ','	+ CAST(COALESCE([Forecast],'')			AS VarChar(50))
								+ ','	+ CAST(COALESCE([Trend],'')				AS VarChar(50))
								+ ','	+ CAST(COALESCE([CurrentSizeMB],'')		AS VarChar(50))
								+ ','	+ CAST(COALESCE([TargetSizeMB],'')		AS VarChar(50))
								+ ','	+ CAST(COALESCE([CurrentLimitMB],'')	AS VarChar(50))
								+ '],'	+CHAR(13)+CHAR(10)
				,@ColumnString	= (SELECT TOP 1 ColumnString FROM SummaryStrings)
	FROM		#FinalData
	ORDER BY	[Unit],[Period]
	
	SELECT		@ColumnString			= COALESCE(@ColumnString,'0,1,2,3,4,5,6') --DEFAULT TO ALL COLUMNS IF THERE IS NO DATA
				,@SeriesLineStarter		= CASE	WHEN LEFT(@ColumnString+'   ',3) = '0,1' THEN 2 ELSE 1 END
				,@SeriesCount			= LEN(@ColumnString) - LEN(REPLACE(@ColumnString,',','')) 
				,@SeriesString			= NULL
				,@TitleString			= CASE WHEN @DriveLetter IS NOT NULL AND @DBName IS NULL THEN 'Drive' ELSE 'Database' END
										+ ' Growth Forecast for '+ @@SERVERNAME + '.' 
										+ CASE WHEN @DriveLetter IS NOT NULL AND @DBName IS NULL THEN 'Drive_'+ @DriveLetter ELSE @DBName END
				,@HTMLOut_Path			= '\\'+REPLACE(@@ServerName,'\'+@@ServiceName,'')+'\'+REPLACE(@@ServerName,'\','$')+'_dbasql\dba_reports'
				,@HTMLOut_File			= 'DBGrowthForecast_' + REPLACE(@@ServerName,'\','$') + '_' 
										+ CASE WHEN @DriveLetter IS NOT NULL AND @DBName IS NULL THEN 'Drive_'+ @DriveLetter ELSE @DBName END
										--+ '_' + CONVERT(VarChar(8),@CurrentDate,112)
										+ '.html'

	WHILE @SeriesLineStarter < @SeriesCount
	BEGIN
		SELECT		@SeriesString	= COALESCE(@SeriesString+', '+CAST(@SeriesLineStarter AS CHAR(1))+':{type: "line"}'
												,CAST(@SeriesLineStarter AS CHAR(1))+':{type: "line"}')
					,@SeriesLineStarter = @SeriesLineStarter + 1
	END

	SET		@SeriesString = ISNULL(@SeriesString,'')	

	SELECT		@HTMLOutput = @HTMLOutput +'      ]);
		var chart1		= new google.visualization.ComboChart(document.getElementById(''chart1''));
		var options1	= {curveType: "function",
							pointSize: 2, 
							width: 800, 
							height: 400, 
							legend: "bottom", 
							title: '''+@TitleString+''',
							vAxis: {title: "SPACE USED IN MB"},
							hAxis: {title: "'+CASE WHEN @InputValidation > 0 THEN COALESCE(@InputValidationMsg,'') ELSE '' END+'"},
							seriesType: "area",
							series: {'+@SeriesString+'}
							};
		
		var table		= new google.visualization.Table(document.getElementById(''table''));
		var dataView	= new google.visualization.DataView(data);
		
        // Create and draw the visualization.
		dataView.setColumns(['+@ColumnString+']);
        chart1.draw(dataView, options1);  
		table.draw(data, null);
        }
	function ShowHide(divId) 
		{
		if(document.getElementById(divId).style.display == ''none'')
			{
			document.getElementById(divId).style.display=''block'';
			}
		else
			{
			document.getElementById(divId).style.display = ''none'';
			}
		drawVisualization;
		}
      google.setOnLoadCallback(drawVisualization);
    </script>
  </head>
  <body style="font-family: Arial;border: 0 none;">
    <div id="chart1" style="width: 800px; height: 400px;"></div>
	<input id="ShowHideData" type="button" value="Show/Hide Data" onclick="ShowHide(''table'')" />
	<div id="table" style="DISPLAY: none"></div>
	<div id="chart2" style="width: 800px; height: 200px;"></div>
  </body>
</html>'
		

	EXEC dbaadmin.dbo.dbasp_FileAccess_Write 
		@String			= @HTMLOutput
		,@Path			= @HTMLOut_Path
		,@Filename		= @HTMLOut_File

	PRINT 'File Writen To ' + @HTMLOut_Path +'\'+ @HTMLOut_File

END

EndWithoutRunning: 
 
GO
exec dbaperf.dbo.dbasp_DiskSpaceCheck_CaptureAndExport
GO
select * from sys.master_files