--****************************************************************************
--
--	Example for Peforming Linear Regression with SQL
--
--****************************************************************************

--*****************************************************************************
--
--	Step 1 - Create a table variable and insert test data.  
--		Test data is stripped of promotions and aggregated to a monthly level.
--		Then update Smoothed_Value with a central moving average
--		
--*****************************************************************************

-- Create Table Variable to hold results
Declare @ForecastTable as Table (
				ForecastKey int, 
				CYear int, 
				CMonth int, 
				CWeek int, 
				DBName nvarchar(25),
				Baseline_Data numeric(38,17), 
				Smoothed_Data numeric(38,17), 
				Trend_Data numeric(38,17), 
				Seasonality_Data numeric(38,17),
				Baseline_Index numeric(38,17), 
				Smoothed_Index numeric(38,17), 
				Trend_Index numeric(38,17), 
				Seasonality_Index numeric(38,17))


INSERT INTO @ForecastTable (Forecastkey, CYear, CMonth, CWeek, DBName, Baseline_Data, Baseline_Index)
SELECT	ROW_NUMBER() OVER(ORDER BY rundate) AS [RowNumber]
		,YEAR([rundate])
		,MONTH([rundate])
		,DATENAME(week,[rundate])
		,[DatabaseName]
		,CAST([data_space_used_KB] AS numeric(38,17)) / 1024.000000
		,CAST([index_size_used_KB] AS numeric(38,17)) / 1024.000000
FROM	[dbaadmin].[dbo].[db_stats_log]
Where	DatabaseName = 'Transcoder'

--SELECT	ROW_NUMBER() OVER(ORDER BY rundate) AS [RowNumber]
--		,YEAR([rundate])
--		,MONTH([rundate])
--		,DATENAME(week,[rundate])
--		,[DatabaseName] + ' - Size'
--		,CAST([database_size_MB] AS numeric(38,17))
--FROM	[dbaadmin].[dbo].[db_stats_log]
--Where DatabaseName = 'Transcoder'
--UNION ALL
--SELECT	ROW_NUMBER() OVER(ORDER BY rundate) AS [RowNumber]
--		,YEAR([rundate])
--		,MONTH([rundate])
--		,DATENAME(week,[rundate])
--		,[DatabaseName] + ' - Unallocated'
--		,CAST([unallocated space_MB] AS numeric(38,17))
--FROM	[dbaadmin].[dbo].[db_stats_log]
--Where DatabaseName = 'Transcoder'
--UNION ALL
--SELECT	ROW_NUMBER() OVER(ORDER BY rundate) AS [RowNumber]
--		,YEAR([rundate])
--		,MONTH([rundate])
--		,DATENAME(week,[rundate])
--		,[DatabaseName] + ' - Reserved'
--		,CAST([reserved_space_KB] AS numeric(38,17)) / 1024.000000
--FROM	[dbaadmin].[dbo].[db_stats_log]
--Where DatabaseName = 'Transcoder'
--UNION ALL
--SELECT	ROW_NUMBER() OVER(ORDER BY rundate) AS [RowNumber]
--		,YEAR([rundate])
--		,MONTH([rundate])
--		,DATENAME(week,[rundate])
--		,[DatabaseName] + ' - Data'
--		,CAST([data_space_used_KB] AS numeric(38,17)) / 1024.000000 
--FROM	[dbaadmin].[dbo].[db_stats_log]
--Where DatabaseName = 'Transcoder'
--UNION ALL
--SELECT	ROW_NUMBER() OVER(ORDER BY rundate) AS [RowNumber]
--		,YEAR([rundate])
--		,MONTH([rundate])
--		,DATENAME(week,[rundate])
--		,[DatabaseName] + ' - Index'
--		,CAST([index_size_used_KB] AS numeric(38,17)) / 1024.000000
--FROM	[dbaadmin].[dbo].[db_stats_log]
--Where DatabaseName = 'Transcoder'
--UNION ALL
--SELECT	ROW_NUMBER() OVER(ORDER BY rundate) AS [RowNumber]
--		,YEAR([rundate])
--		,MONTH([rundate])
--		,DATENAME(week,[rundate])
--		,[DatabaseName] + ' - Unused'
--		,CAST([unused_space_KB] AS numeric(38,17)) / 1024.000000
--FROM	[dbaadmin].[dbo].[db_stats_log]
--Where DatabaseName = 'Transcoder'


-- Update Smoothed_Value with Central Moving Average

	Update 
		@ForecastTable 
	SET 
		Smoothed_Data = MovAvg.Smoothed_Data
		,Smoothed_Index = MovAvg.Smoothed_Index
	FROM(
		SELECT 
			a.ForecastKey as FKey,
			a.DBName as DBN, 
			Round(AVG(Cast(b.Baseline_Data as numeric(14,1))),0) Smoothed_Data,
			Round(AVG(Cast(b.Baseline_Index as numeric(14,1))),0) Smoothed_Index
		FROM 
			@ForecastTable a
		INNER JOIN 
			@ForecastTable b 
		ON 
			a.DBName = b.DBName 
			AND	(a.ForecastKey - b.ForecastKey) BETWEEN -3 AND 3
		GROUP BY
			a.ForecastKey,
			a.DBName) MovAvg
	WHERE 
		DBName = MovAvg.DBN
		AND ForecastKey = MovAvg.FKey
	
--****************************************************************************************
--
--	Step 2 - Create a second table variable to hold the trend formula by item.  
--		This step is performed with an insert and update to make the calculations more clear
--		It could just as easily be performed with a single insert.
--		Lastly, update the trend for historical data and calculate seasonality
--
--*****************************************************************************************

	-- Create table to store calculations by Item
	DECLARE @Formula as Table(
					DBName nvarchar(25),
					Counts int,  
					SumX Numeric(14,4), 
					SumXsqrd Numeric(14,4), 
					SumY_Data Numeric(14,4),
					SumXY_Data Numeric(14,4), 
					SumY_Index Numeric(14,4),
					SumXY_Index Numeric(14,4), 
					b_Data Numeric(38,17), 
					a_Data Numeric(38,17),
					b_Index Numeric(38,17), 
					a_Index Numeric(38,17))

	INSERT INTO @Formula (DBName, Counts, SumX, SumY_Data, SumXY_Data, SumY_Index, SumXY_Index, SumXsqrd)	
		(SELECT 
			DBName,
			COUNT(*),
			sum(ForecastKey),
			sum(Smoothed_Data),
			sum(Smoothed_Data * ForecastKey),
			sum(Smoothed_Index),
			sum(Smoothed_Index * ForecastKey),
			sum(power(ForecastKey,2)) 
		FROM 
			@ForecastTable
		WHERE 
			Smoothed_Data IS NOT NULL
			and Smoothed_Index IS NOT NULL
		GROUP BY 
			DBName)
		
		-- Calculate B (Slope)
		UPDATE		@Formula 
			SET		b_Data = ((tb.counts * tb.sumXY_Data)-(tb.sumX * tb.sumY_Data))/ (tb.Counts * tb.sumXsqrd - power(tb.sumX,2))
					,b_Index = ((tb.counts * tb.sumXY_Index)-(tb.sumX * tb.sumY_Index))/ (tb.Counts * tb.sumXsqrd - power(tb.sumX,2))
		FROM		(
					SELECT		DBName as XDBName
								, Counts
								, SumX
								, SumY_Data
								, SumY_Index
								, SumXY_Data
								, SumXY_Index
								, SumXsqrd 
					FROM		@Formula
					) tb
		WHERE		DBName = tb.XDBName
		
		--Calculate A (Y Intercept)
		UPDATE		@Formula 
			SET		a_Data = ((tb2.sumY_Data - tb2.b_Data * tb2.sumX) / tb2.Counts)
					,a_Index = ((tb2.sumY_Index - tb2.b_Index * tb2.sumX) / tb2.Counts)
		FROM		(
					SELECT		DBName as XDBName
								, Counts
								, SumX
								, SumY_Data
								, SumY_Index
								, SumXY_Data
								, SumXY_Index
								, SumXsqrd
								, b_Data
								, b_Index 
					FROM		@Formula
					) tb2
		WHERE		DBName = tb2.XDBName
		
		-- Update Historical Trend and Seasonality
		--y = a + bx
		--Forecast = Y Intercept + (Slope * ForecastKey)
		
		UPDATE		@ForecastTable 
			SET		Trend_Data = A_Data + (B_Data * ForecastKey)
					,Trend_Index = A_Index + (B_Index * ForecastKey)
					,Seasonality_Data = CASE WHEN Baseline_Data = 0 THEN 1 ELSE Baseline_Data /(A_Data + (B_Data * ForecastKey)) END
					,Seasonality_Index = CASE WHEN Baseline_Index = 0 THEN 1 ELSE Baseline_Index /(A_Index + (B_Index * ForecastKey)) END
		FROM		(
					SELECT		DBName as XDBName
								, Counts
								, SumX
								, SumY_Data
								, SumY_Index
								, SumXY_Data
								, SumXY_Index
								, SumXsqrd
								, b_Data
								, b_Index 
								, a_Data 
								, a_Index 
					FROM		@Formula
					) TrendUpdate
		WHERE		DBName = TrendUpdate.XDBName

--**********************************************************************************
--
--	Step 3 - Insert Trendline and forecast into Forecast table 
--		
--**********************************************************************************

		-- Create Forecast
		DECLARE @Loop as int
		SET @Loop = 0
		
		WHILE @Loop <52
			BEGIN
				INSERT INTO @ForecastTable (ForecastKey, CYear, CMonth, CWeek, DBName, Trend_Data, Trend_Index, BaseLine_Data, BaseLine_Index)
				SELECT 
					MAX(Forecastkey) + 1,  --Create Forecastkey
					YEAR(dateadd(week,@Loop,getdate())), -- Dates could be incremented by joining to a date dimension or using Dateadd for a date type
					Month(dateadd(week,@Loop,getdate())),
					DatePart(week,dateadd(week,@Loop,getdate())),
					a.DBName,
					MAX(A_Data) + (MAX(B_Data) * MAX(Forecastkey) + 1), -- Trendline
					MAX(A_Index) + (MAX(B_Index) * MAX(Forecastkey) + 1), -- Trendline
					(MAX(A_Data) + (MAX(B_Data) * MAX(Forecastkey) + 1))
					*  
					(SELECT 
						Case WHEN avg(Seasonality_Data) = 0 THEN 1 ELSE avg(Seasonality_Data) END 
					FROM 
						@ForecastTable SeasonalMask
					WHERE 
						SeasonalMask.DBName = a.DBName
						AND SeasonalMask.CWeek = @Loop +1),-- Trendline * Avg seasonality

					(MAX(A_Index) + (MAX(B_Index) * MAX(Forecastkey) + 1))
					*  
					(SELECT 
						Case WHEN avg(Seasonality_Index) = 0 THEN 1 ELSE avg(Seasonality_Index) END 
					FROM 
						@ForecastTable SeasonalMask
					WHERE 
						SeasonalMask.DBName = a.DBName
						AND SeasonalMask.CWeek = @Loop +1)-- Trendline * Avg seasonality
				FROM 
					@ForecastTable a
				INNER JOIN 
					@Formula b
				ON 
					a.DBName = b.DBName
				GROUP BY 
					a.DBName
			
				
			SET @Loop = @Loop +1
			END
		
		-- Review results
		--SELECT * FROM @ForecastTable ORDER BY DBName, Forecastkey
		
		
SELECT		DBName
			, CAST(CYear AS VarChar(4)) + '-'
			+ CAST(CMonth AS VarChar(4)) + '-'
			+ CAST(CWeek AS VarChar(4)) AS [YearMonthWeek]
			, Baseline_Data
			, Trend_Data
			, Baseline_Index
			, Trend_Index
FROM		@ForecastTable
ORDER BY DBName, Forecastkey		
