USE [dbaadmin]
GO




GO
IF  OBJECT_ID(N'[dbo].[dbasp_ChartData_DBGrowth]') IS NOT NULL
DROP PROCEDURE	dbasp_ChartData_DBGrowth 
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
				Y-Intercept:	A= (SY - B(SX)) / C 
				Seasonality:	Metric/A+BX.
				Forcast:		A+BX.				

Usage: dbasp_ChartData_DBGrowth	[@DBName='{DatabaseName}|SUMMARY|DETAIL'|''|{NULL}]
								[, @TargetSizeMB='[+]#####[%]']
								[, @TimeTillTarget] OUTPUT ONLY
								[, @TimeTillCL] OUTPUT ONLY
								[, @CurrentSizeMB] OUTPUT ONLY
								[, @CurrentLimit] OUTPUT ONLY
								[, @NoDataTable=0|1] Default=0
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
					
			dbasp_ChartData_DBGrowth	@DBName='WCDS'
										, @TimeTillTarget=@TimeTillTarget OUT
										, @TimeTillCL=@TimeTillCL OUT
										, @CurrentSizeMB=@CurrentSizeMB OUT
										, @CurrentLimit=@CurrentLimit OUT
										
			SELECT @TimeTillTarget,@TimeTillCL,@CurrentSizeMB,@CurrentLimit
										
Created: 2010-03-25. $Modtime: 4/07/00 8:38p $.

*/ 

CREATE PROCEDURE	dbasp_ChartData_DBGrowth
					(
					@DBName				VarChar(50) = NULL --IF NULL A SERVER SUMMARY IS RUN
					,@TargetSizeMB		VarChar(50) = NULL --IF NULL THIS IS THE SAME AS @CurrentLimit
					,@TimeTillTarget	Int = NULL OUTPUT
					,@TimeTillCL		Int = NULL OUTPUT
					,@CurrentSizeMB		numeric(38,17) = NULL OUTPUT
					,@CurrentLimit		numeric(38,17) = NULL OUTPUT
					,@NoDataTable		bit = 0
					,@Exclusions		VarChar(2048) = NULL
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
---- SET TEST VARIABLES
--DECLARE	@DBName				sysname
--		,@TargetSizeMB		VarChar(50)
--		,@TimeTillTarget	Int
--		,@TimeTillCL		Int
--		,@CurrentSizeMB		numeric(38,17)
--		,@CurrentLimit		numeric(38,17)
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
CREATE TABLE #DiskInfo 
			(
			Drive					CHAR(1) PRIMARY KEY
			,MBFree					INT
			,Tag					VARCHAR(50)
			)

-- Create table to hold the drives used by each database			
CREATE TABLE #DBDrivesUsed 
	(
	DBName sysname
	,FileType sysname
	,Drive char(1)
	)				

-- Create Table Variable to hold results
CREATE TABLE #ForecastTable  
			(
			ForecastKey				INT IDENTITY(1,1) 
			,CYear					INT 
			,CMonth					INT
			,CWeek					INT
			,Unit					VARCHAR(50) 
			
			,Baseline_MetricA		NUMERIC(38,17)
			,Smoothed_MetricA		NUMERIC(38,17)
			,Trend_MetricA			NUMERIC(38,17)
			,Seasonality_MetricA	NUMERIC(38,17)
			,Forcast_MetricA		NUMERIC(38,17)
			
			,Baseline_MetricB		NUMERIC(38,17)
			,Smoothed_MetricB		NUMERIC(38,17)
			,Trend_MetricB			NUMERIC(38,17)
			,Seasonality_MetricB	NUMERIC(38,17)
			,Forcast_MetricB		NUMERIC(38,17)
			)

-- Create table to store calculations by Item
CREATE TABLE #Formula 
			(
			Unit varchar(50)
			,Counts int
			,SumX Numeric(14,4)
			,SumXsqrd Numeric(14,4)
			,SumY_MetricA Numeric(14,4)
			,SumXY_MetricA Numeric(14,4)
			,SumY_MetricB Numeric(14,4)
			,SumXY_MetricB Numeric(14,4)
			,b_MetricA Numeric(38,17)
			,a_MetricA Numeric(38,17)
			,b_MetricB Numeric(38,17)
			,a_MetricB Numeric(38,17)
			)
					
-- Other Variables
DECLARE @CurrentPeriod INT
DECLARE @CurrentDate DateTime

SET @Exclusions = COALESCE(@Exclusions,'Master,Model,MSDB,TempDB,dbaperf,dbaadmin')
If	@DBName = '' 
  SET @DBName = NULL
SET @DBName = COALESCE(@DBName,'SUMMARY')

-- GATHER SUPPORT DATA
--Print 'getting #DiskInfo'
INSERT INTO #DiskInfo (Drive,MBFree)
EXEC master..xp_fixeddrives

--Print 'getting #DBDrivesUsed'
exec sp_msForEachDB 'INSERT INTO #DBDrivesUsed(DBName, FileType, Drive) SELECT DISTINCT ''?'',CASE groupid WHEN 1 THEN ''DATA'' WHEN 0 THEN ''LOG'' ELSE ''Other'' END,LEFT(filename,1) COLLATE SQL_Latin1_General_CP1_CI_AS FROM [?]..sysfiles'
DELETE #DBDrivesUsed WHERE DBName in (Select DISTINCT SplitValue FROM dbaadmin.dbo.dbaudf_split(@Exclusions,','))

--Print 'getting @CurrentSizeMB'	
SELECT		@CurrentSizeMB = 
			SUM((CAST([usedata] AS numeric(38,17)))+(CAST([useindex] AS numeric(38,17))))
FROM		[dbaadmin].[dbo].[MSSQLusage]
LEFT JOIN	dbaadmin.dbo.dbaudf_split(@Exclusions,',') T2
	ON		[MSSQLusage].[DatabaseName] = T2.[SplitValue]
WHERE		DatabaseName =	CASE @DBName
							WHEN 'SUMMARY'	THEN [DatabaseName]
							WHEN 'DETAIL'	THEN [DatabaseName]
							ELSE @DBName END
	AND		T2.[SplitValue] IS NULL	
	AND		DATEPART(year,[recdate]) = (SELECT DATEPART(year,MAX([recdate])) FROM [dbaadmin].[dbo].[MSSQLusage])
	AND		DATEPART(week,[recdate]) = (SELECT DATEPART(week,MAX([recdate])) FROM [dbaadmin].[dbo].[MSSQLusage])

SELECT		@CurrentLimit = @CurrentSizeMB + SUM(MBFree)
FROM		#DiskInfo
WHERE		Drive IN
				(
				SELECT	Drive
				FROM	#DBDrivesUsed
				WHERE	FileType = 'DATA'
				)


--Print 'Cleaning @TargetSizeMB'	
If LEFT(@TargetSizeMB,1) = '+' -- ADD Calculation to Existing Size
BEGIN
	If RIGHT (@TargetSizeMB,1) = '%' -- Percent of Existing Size
		SET @TargetSizeMB = ((CAST(SUBSTRING(@TargetSizeMB,1,LEN(@TargetSizeMB)-2) AS Numeric(38,17)) * @CurrentSizeMB)/100) + @CurrentSizeMB
	else -- Fixed Value
		SET @TargetSizeMB = CAST(RIGHT(@TargetSizeMB,LEN(@TargetSizeMB)-1) AS Numeric(38,17)) + @CurrentSizeMB
END
else -- Just Use calculation or fixed value without adding to existing size
BEGIN	
	If RIGHT (@TargetSizeMB,1) = '%' --	Percent of Existing Size
		SET @TargetSizeMB = ((CAST(LEFT(@TargetSizeMB,LEN(@TargetSizeMB)-1) AS Numeric(38,17)) * @CurrentSizeMB)/100) 
END	
-- IF None of the previous logic is applied the value is assumed to be a fixed value in MB.


SET @TargetSizeMB = COALESCE(@TargetSizeMB,@CurrentLimit)


--Print 'Starting Step 1'	
--*****************************************************************************
--
--	Step 1 - Populate Forcast Table with all historical Data Grouped By Year-Month-Week.
--		Then update Smoothed_Value with a central moving average
--		
--*****************************************************************************
INSERT INTO #ForecastTable (CYear, CMonth, CWeek, Unit, Baseline_MetricA, Baseline_MetricB)
SELECT	YEAR([recdate]) [Year]
		,MONTH([recdate]) [Month]
		,DATEPART(week,[recdate]) [Week]
		------------------------------------------------------
		------------------------------------------------------
		-- GET DATA FROM ALL DATABASES IF KEYWORD IS USED	--
		------------------------------------------------------
		------------------------------------------------------
		,CASE @DBName
			WHEN 'SUMMARY'		THEN [ServerName]	-- SUMMARY USES ONE SERIES FOR THE ENTIRE SERVER.
			WHEN 'DETAIL'		THEN [DatabaseName] -- DETAIL USES ONE SERIES FOR EACH DATABASE.
			ELSE [DatabaseName]						-- NO KEYWORD USES ONE SERIES FOR A SINGLE DATABASE.
			END [Unit]
		------------------------------------------------------
		------------------------------------------------------
		,SUM(CAST([usedata] AS numeric(38,17))) [MetricA]
		,SUM(CAST([useindex] AS numeric(38,17))) [MetricB]
FROM	[dbaadmin].[dbo].[MSSQLusage]
		------------------------------------------------------
		------------------------------------------------------
		-- JOIN IN EXCLUSION LIST							--
		------------------------------------------------------
		------------------------------------------------------
LEFT JOIN dbaadmin.dbo.dbaudf_split(@Exclusions,',') T2
	ON	[MSSQLusage].[DatabaseName] = T2.[SplitValue]
		------------------------------------------------------
		------------------------------------------------------
		-- GET DATA FROM ALL DATABASES IF KEYWORD IS USED	--
		------------------------------------------------------
		------------------------------------------------------
WHERE	DatabaseName =	CASE @DBName
							WHEN 'SUMMARY'	THEN [DatabaseName]
							WHEN 'DETAIL'	THEN [DatabaseName]
							ELSE @DBName END
	AND	T2.[SplitValue] IS NULL
	
GROUP BY	YEAR([recdate])
			,MONTH([recdate])
			,DATEPART(week,[recdate])
			,CASE @DBName
				WHEN 'SUMMARY'		THEN [ServerName]	-- SUMMARY USES ONE SERIES FOR THE ENTIRE SERVER.
				WHEN 'DETAIL'		THEN [DatabaseName] -- DETAIL USES ONE SERIES FOR EACH DATABASE.
				ELSE [DatabaseName]						-- NO KEYWORD USES ONE SERIES FOR A SINGLE DATABASE.
				END


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
							, CASE Counts WHEN 0 THEN 1 ELSE Counts END [Counts]
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
--Print 'Starting Step 3'
--**********************************************************************************
--
--	Step 3 - Insert Trendline and forecast into Forecast table for future Dates.
--		
--**********************************************************************************

		-- Create Forecast
		DECLARE @Loop as int
		SET @Loop = 0

		WHILE @Loop <52 -- ONE YEARS
			BEGIN
				INSERT INTO	#ForecastTable (CYear, CMonth, CWeek, Unit, Trend_MetricA, Trend_MetricB, Forcast_MetricA, Forcast_MetricB)
				SELECT		YEAR(dateadd(week,@Loop,getdate()))						-- Dates simply generated
							,Month(dateadd(week,@Loop,getdate()))						--  by incrementing from
							,DatePart(week,dateadd(week,@Loop,getdate()))				--  current date
							,a.Unit
							,MAX(A_MetricA) + (MAX(B_MetricA) * MAX(Forecastkey) + 1)	-- Trendline
							,MAX(A_MetricB) + (MAX(B_MetricB) * MAX(Forecastkey) + 1)	-- Trendline
							,(MAX(A_MetricA) + (MAX(B_MetricA) * MAX(Forecastkey) + 1))
							*(	SELECT	Case 
										WHEN avg(Seasonality_MetricA) = 0 
										THEN 1 
										ELSE avg(Seasonality_MetricA) 
										END 
								FROM #ForecastTable SeasonalMask
								WHERE SeasonalMask.Unit = a.Unit
								AND SeasonalMask.CWeek = DatePart(week,dateadd(week,@Loop,getdate())))						-- Trendline * Avg seasonality

							,(MAX(A_MetricB) + (MAX(B_MetricB) * MAX(Forecastkey) + 1))
							*(	SELECT	Case
										WHEN avg(Seasonality_MetricB) = 0 
										THEN 1 
										ELSE avg(Seasonality_MetricB) 
										END 
								FROM #ForecastTable SeasonalMask
								WHERE SeasonalMask.Unit = a.Unit
								AND SeasonalMask.CWeek = DatePart(week,dateadd(week,@Loop,getdate())))						-- Trendline * Avg seasonality
				FROM		#ForecastTable a
				INNER JOIN	#Formula b
					ON		a.Unit = b.Unit
				GROUP BY	a.Unit
				
			SET @Loop = @Loop +1
			END
	
SET		@CurrentDate = GetDate()

--Print 'Getting @CurrentPeriod'
SELECT		TOP 1
			@CurrentPeriod = ForecastKey
FROM		#ForecastTable
WHERE		CYear	= (SELECT DATENAME(year,MAX([recdate])) FROM [dbaadmin].[dbo].[MSSQLusage])
	AND		CWeek	= (SELECT DATENAME(week,MAX([recdate])) FROM [dbaadmin].[dbo].[MSSQLusage])
	
--Print 'Getting @TimeTillTarget'
SELECT		TOP 1
			@TimeTillTarget = ForecastKey - @CurrentPeriod
FROM		#ForecastTable
WHERE		ForecastKey > @CurrentPeriod
	AND		Forcast_MetricA + Forcast_MetricB >= @TargetSizeMB
ORDER BY	ForecastKey 

--Print 'Getting @TimeTillCL'
SELECT		TOP 1
			@TimeTillCL = ForecastKey - @CurrentPeriod
FROM		#ForecastTable
WHERE		ForecastKey > @CurrentPeriod
	AND		Forcast_MetricA + Forcast_MetricB >= @CurrentLimit
ORDER BY	ForecastKey 

		
		-- Review results

	PRINT		'Database:				' + @DBName
	PRINT		'Exclusions:				' + @Exclusions
	PRINT		'Current Size:				' + CAST(@CurrentSizeMB AS VarChar(50)) + 'MB'
	PRINT		'Target Size:				' + @TargetSizeMB + 'MB'
	PRINT		'Time Till Target:			' + COALESCE(CAST(@TimeTillTarget AS VarChar(50)) + ' Weeks','Not within Current Forcast') 
	PRINT		'Current Limit:				' + CAST(@CurrentLimit AS VarChar(50)) + 'MB'
	PRINT		'Time Till Current Limit:		' + COALESCE(CAST(@TimeTillCL AS VarChar(50)) + ' Weeks','Not within Current Forcast')

If @NoDataTable = 0		
BEGIN			
	SELECT		Unit
				, CAST(CYear AS VarChar(4)) + '-' + RIGHT('00'+CAST(CWeek AS VarChar(2)),2) [Period]
				, COALESCE(Baseline_MetricA,0) + COALESCE(Baseline_MetricB,0) [Recorded] 
				, COALESCE(Forcast_MetricA,0) + COALESCE(Forcast_MetricB,0) [Forcast]
				, Trend_MetricA + Trend_MetricB [Trend]
				, @CurrentSizeMB [CurrentSizeMB]	
				, CASE WHEN CAST(@TargetSizeMB AS numeric(38,17)) > (SELECT TOP 1 COALESCE(Forcast_MetricA,0) + COALESCE(Forcast_MetricB,0) FROM #ForecastTable ORDER BY Forecastkey DESC)THEN CAST(0.00 AS numeric(38,17)) ELSE CAST(@TargetSizeMB AS numeric(38,17)) END [TargetSizeMB]
				, CASE WHEN CAST(@CurrentLimit AS numeric(38,17)) > (SELECT TOP 1 COALESCE(Forcast_MetricA,0) + COALESCE(Forcast_MetricB,0) FROM #ForecastTable ORDER BY Forecastkey DESC)THEN CAST(0.00 AS numeric(38,17)) ELSE CAST(@CurrentLimit AS numeric(38,17)) END [CurrentLimitMB]
	FROM		#ForecastTable
	WHERE		Forecastkey >= @CurrentPeriod - 52
		AND		COALESCE(Baseline_MetricA,0) + COALESCE(Baseline_MetricB,0) + COALESCE(Forcast_MetricA,0) + COALESCE(Forcast_MetricB,0) > 0
	ORDER BY	Unit,Forecastkey		

END

GO

USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_split]    Script Date: 03/26/2010 11:41:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[dbaudf_split]') IS NULL
BEGIN
execute dbo.sp_executesql @statement = N'

Create function [dbo].[dbaudf_split] ( @String VARCHAR(200), @Delimiter VARCHAR(5))
returns @SplittedValues TABLE
(
    OccurenceId SMALLINT IDENTITY(1,1),
    SplitValue VARCHAR(200)
)
/**************************************************************
 **  User Defined Function dbaudf_split                 
 **  Written by David Spriggs, Getty Images                
 **  May 12, 2009                                     
 **  
 **  This dbaudf is set up parse a delimited string return values
 **  in tabular format.
 **  
 ***************************************************************/
as

--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	05/13/2009	David Spriggs		New process
--	
--	======================================================================================

/***
declare @String VARCHAR(200)
declare @Delimiter VARCHAR(5)

set @String = ''abc def ghi''
set @Delimiter = '' ''

--***/

BEGIN

    DECLARE @SplitLength INT

    WHILE LEN(@String) > 0

	BEGIN

	    SELECT @SplitLength = (CASE CHARINDEX(@Delimiter,@String) WHEN 0 THEN
			           LEN(@String) ELSE CHARINDEX(@Delimiter,@String) -1 END)

	    INSERT INTO @SplittedValues
	    SELECT SUBSTRING(@String,1,@SplitLength)

	    SELECT @String = (CASE (LEN(@String) - @SplitLength) WHEN 0 THEN ''''
			      ELSE RIGHT(@String, LEN(@String) - @SplitLength - 1) END)
	END

    RETURN

END

' 
END

GO

