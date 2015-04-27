/*
USE DBAADMIN
GO
:R \\seapsqldba01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbaudf_TimeTable.sql
:R \\seapsqldba01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbaudf_TimeDimension.sql
:R \\seapsqldba01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbaudf_MAX_Float.sql
:R \\seapsqldba01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbaudf_NumberTable.sql

:R \\seapsqldba01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\ALL_dbaadmin_32_CLR.SQL


SELECT * From  [dbaperf].[dbo].[db_stats_log] WHERE [ServerName] != @@SERVERNAME

UPDATE		[dbaperf].[dbo].[db_stats_log]
		SET	[ServerName] = @@SERVERNAME
WHERE		[ServerName] != @@SERVERNAME

--DELETE [dbaperf].[dbo].[db_stats_log] WHERE [ServerName] != @@SERVERNAME


*/
SET NOEXEC OFF
GO
IF @@Version Like '%SQL Server  2000%'
	SET NOEXEC ON
GO 
IF DB_ID('DBAPERF') IS NULL
	SET NOEXEC ON
GO
USE DBAPERF
GO
IF OBJECT_ID('[dbaperf].[dbo].[db_stats_log]') IS NULL
	SET NOEXEC ON

GO
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON


IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[db_stats_log]') AND name = N'PK_db_stats_log')
	ALTER TABLE [dbo].[db_stats_log] DROP CONSTRAINT [PK_db_stats_log]
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[db_stats_log]') AND name = N'IX_db_stats_log_6_309576141__K2_K1_3')
	DROP INDEX IX_db_stats_log_6_309576141__K2_K1_3 ON dbo.db_stats_log

IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[db_stats_log]') AND name = N'IX_db_stats_log_30_613577224__K1_K2_K3_7_8')
	DROP INDEX IX_db_stats_log_30_613577224__K1_K2_K3_7_8 ON dbo.db_stats_log

IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[db_stats_log]') AND name = N'IX_db_stats_log_c_6_309576141__K2_K1')
	DROP INDEX IX_db_stats_log_c_6_309576141__K2_K1 ON dbo.db_stats_log


IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[db_stats_log]') AND name = N'PK_db_stats_log_Clustered')
ALTER TABLE dbo.db_stats_log ADD CONSTRAINT
	PK_db_stats_log_Clustered PRIMARY KEY CLUSTERED 
	(
	rundate DESC,
	ServerName,
	DatabaseName
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

-- UPDATE DATA IF NOT RUN TODAY

IF NOT EXISTS (SELECT * FROM [dbaperf].[dbo].[db_stats_log] WHERE rundate >= CAST(CONVERT(VARCHAR(12),GetDate(),101)AS DateTime)) 
	exec dbaperf.dbo.dbasp_extract_db_stats
GO


SET NOCOUNT ON
GO
IF OBJECT_ID('tempdb..#DateDimension') IS NOT NULL DROP TABLE #DateDimension
GO
IF OBJECT_ID('tempdb..#CleanHistory') IS NOT NULL DROP TABLE #CleanHistory
GO
IF OBJECT_ID('tempdb..#SmothedHistory') IS NOT NULL DROP TABLE #SmothedHistory
GO
IF OBJECT_ID('tempdb..#DBResults') IS NOT NULL DROP TABLE #DBResults
GO
IF OBJECT_ID('tempdb..#DriveResults') IS NOT NULL DROP TABLE #DriveResults
GO
IF OBJECT_ID('tempdb..#DriveSnapshot') IS NOT NULL DROP TABLE #DriveSnapshot
GO
IF OBJECT_ID('tempdb..#DriveSummary') IS NOT NULL DROP TABLE #DriveSummary
GO
IF OBJECT_ID('tempdb..#DBSummary') IS NOT NULL DROP TABLE #DBSummary
GO
IF OBJECT_ID('tempdb..#FinalData') IS NOT NULL DROP TABLE #FinalData
GO
IF OBJECT_ID('tempdb..#RawData') IS NOT NULL DROP TABLE #RawData
GO
IF OBJECT_ID('tempdb..#DBRanges') IS NOT NULL DROP TABLE #DBRanges
GO
IF OBJECT_ID('tempdb..#ResultKey') IS NOT NULL DROP TABLE #ResultKey
GO
IF OBJECT_ID('tempdb..#History') IS NOT NULL DROP TABLE #History
GO

DECLARE		@DaysToForecast		INT
DECLARE		@RunDate		DateTime

SET		@RunDate		= CAST(CONVERT(VARCHAR(12),GetDate(),101) AS DateTime)
SET		@DaysToForecast		= (365*2) -- Two Years

RAISERROR('Forecasting %d Days.',-1,-1,@DaysToForecast) WITH NOWAIT

	CREATE TABLE #DriveResults
					(
					[ServerName]	SYSNAME
					,[DriveLetter]	CHAR(1)
					,[Period]	INT
					,[DataGrowth]	NUMERIC(38,10)
					,[IndexGrowth]	NUMERIC(38,10)
					,[FreeSpaceMB]	NUMERIC(38,10)
					,[Growth_Desc]	VARCHAR(MAX)
					)

	CREATE CLUSTERED INDEX [IX_DriveResults_1]
	ON [dbo].[#DriveResults] ([ServerName],[DriveLetter],[Period])

RAISERROR('  Generating Date Dimmension Table.',-1,-1) WITH NOWAIT

	SELECT		ROW_NUMBER()OVER(ORDER BY [TimeKey]) [Period]
			,T2.DateTimeValue
			,CASE WHEN DateTimeValue < = MaxHistory THEN 'HISTORY' ELSE 'FORECAST' END AS [Range]
	INTO		#DateDimension
	FROM		(
			SELECT		MinDate		= CAST(CONVERT(VarChar(12),MIN([rundate]),101)AS DateTime)
					,MaxDate	= CAST(CONVERT(VarChar(12),Getdate()+@DaysToForecast,101)AS DateTime)
					,MaxHistory	= CAST(CONVERT(VarChar(12),MAX([rundate]),101)AS DateTime)
			FROM		[dbaperf].[dbo].[db_stats_log] [db_stats_log] WITH(NOLOCK)
			WHERE		[DatabaseName] IN (SELECT name FROM sys.databases where source_database_id IS NULL)
			) T1
	CROSS APPLY	[dbaadmin].[dbo].[dbaudf_TimeDimension](T1.MinDate,T1.MaxDate,'Day',1) T2

	CREATE CLUSTERED INDEX [IX_DateDimension_1]
	ON [dbo].[#DateDimension] ([Period] DESC)


RAISERROR('  Generating #RawData Table.',-1,-1) WITH NOWAIT

	SELECT		 [ServerName]
			,[DatabaseName]
			,CAST(CONVERT(VarChar(12),[rundate],101)AS DateTime) [rundate]
			,MAX(CAST([data_space_used_KB] AS NUMERIC(38,10)) / POWER(1024.0,1)) DataSize	-- IN MB
			,MAX(CAST([index_size_used_KB] AS NUMERIC(38,10)) / POWER(1024.0,1)) IndexSize	-- IN MB
	INTO		#RawData
	FROM		[dbaperf].[dbo].[db_stats_log] [db_stats_log] WITH(NOLOCK)
	WHERE		[DatabaseName] IN (SELECT name FROM sys.databases where source_database_id IS NULL)
	GROUP BY	[ServerName]
			,[DatabaseName]
			,CAST(CONVERT(VarChar(12),[rundate],101)AS DateTime)

	CREATE CLUSTERED INDEX [IX_RawData_1]
	ON [dbo].[#RawData] ([rundate] DESC,[ServerName],[DatabaseName])


RAISERROR('  Generating #DBRanges Table.',-1,-1) WITH NOWAIT

	SELECT		[ServerName]
			,[DatabaseName]
			,MinDate	= MIN([rundate])
			,MaxDate	= MAX([rundate])
	INTO		#DBRanges
	FROM		#RawData [db_stats_log] WITH(NOLOCK)
	GROUP BY	[ServerName]
			,[DatabaseName]
	CREATE CLUSTERED INDEX [IX_DBRanges_1]
	ON [dbo].[#DBRanges] ([ServerName],[DatabaseName])


RAISERROR('  Generating #ResultKey Table.',-1,-1) WITH NOWAIT

	SELECT		[DateDimension].[Period]
			,[DBRanges].[ServerName]
			,[DBRanges].[DatabaseName]
			,[DateDimension].[DateTimeValue]
			,CASE
				WHEN [DateDimension].[DateTimeValue] < [DBRanges].[MinDate] THEN 'NO_DB'
				WHEN [DateDimension].[DateTimeValue] <=[DBRanges].[MaxDate] THEN 'HISTORY' 
				ELSE 'FORECAST' END AS [Range]
	INTO		#ResultKey
	FROM		#DateDimension [DateDimension]
	CROSS JOIN	#DBRanges [DBRanges]
	ORDER BY	1 DESC ,2,3

	CREATE CLUSTERED INDEX [IX_ResultKey_1]
	ON [dbo].[#ResultKey] ([Period] DESC,[ServerName],[DatabaseName])


RAISERROR('  Generating #History Table.',-1,-1) WITH NOWAIT

	SELECT		[ResultKey].[ServerName]
			,[ResultKey].[DatabaseName]
			,[ResultKey].[Period]
			,ROW_NUMBER() OVER (PARTITION BY [ResultKey].[Range],[ResultKey].[ServerName],[ResultKey].[DatabaseName] ORDER BY [ResultKey].[Period]) [CntUp]
			,ROW_NUMBER() OVER (PARTITION BY [ResultKey].[Range],[ResultKey].[ServerName],[ResultKey].[DatabaseName] ORDER BY [ResultKey].[Period] DESC) [CntDn]
			,[ResultKey].[Range]
			,[RawData].[DataSize]
			,[RawData].[IndexSize]
	INTO		#History
	FROM		#ResultKey [ResultKey]
	LEFT JOIN	#RawData [RawData]
		ON	[ResultKey].[DateTimeValue]	= [RawData].[rundate]
		AND	[ResultKey].[ServerName]	= [RawData].[ServerName]
		AND	[ResultKey].[DatabaseName]	= [RawData].[DatabaseName]
	ORDER BY	3 desc,1,2


	CREATE CLUSTERED INDEX [IX_History_1]
	ON [dbo].[#History] ([Period] DESC,[ServerName],[DatabaseName])

	CREATE NONCLUSTERED INDEX [IX_History_2]
	ON [dbo].[#History] ([ServerName],[DatabaseName],[Period],[IndexSize])

	CREATE NONCLUSTERED INDEX [IX_History_3]
	ON [dbo].[#History] ([ServerName],[DatabaseName],[Period],[DataSize])


RAISERROR('  Generating #CleanHistory Table.',-1,-1) WITH NOWAIT

	SELECT		[ServerName]
			,[DatabaseName]
			,[Period]
			,([CntUp]*100)/([CntUp]+[CntDn]-1)/5 [Pos]
			,20-(([CntUp]*100)/([CntUp]+[CntDn]-1)/5) [Pre]
			,[Range]
			,CASE
				WHEN [DataSize] IS NULL AND [Range] = 'HISTORY'
				THEN (SELECT TOP 1 [DataSize] FROM #History WHERE [DataSize] IS NOT NULL AND [ServerName] = H.[ServerName] AND [DatabaseName] = H.[DatabaseName] AND [Period] < H.[Period] ORDER BY [Period] DESC)
				ELSE [DataSize] END [DataSize]

			,CASE
				WHEN [IndexSize] IS NULL AND [Range] = 'HISTORY'
				THEN (SELECT TOP 1 [IndexSize] FROM #History WHERE [IndexSize] IS NOT NULL AND [ServerName] = H.[ServerName] AND [DatabaseName] = H.[DatabaseName] AND [Period] < H.[Period] ORDER BY [Period] DESC)
				ELSE [IndexSize] END [IndexSize]
	INTO		#CleanHistory
	FROM		#History H
	ORDER BY	3 desc,1,2

RAISERROR('  Generating #SmoothedHistory Table.',-1,-1) WITH NOWAIT

	SELECT		T1.ServerName	
			,T1.DatabaseName	
			,T1.Period
			,T1.DataSize	
			,T1.IndexSize
			,avg(T2.DataSize) [Smoothed_MetricA]
			,avg(T2.IndexSize) [Smoothed_MetricB]
	INTO		#SmothedHistory	
	FROM		#CleanHistory T1
	LEFT JOIN	#CleanHistory T2
		ON	T1.ServerName = T2.ServerName
		AND	T1.DatabaseName = T2.DatabaseName
		AND	T2.Period >= T1.Period - T1.Pre
		AND	T2.Period <= T1.Period + T1.Pos
		AND	T1.Range = T2.Range
	WHERE		T1.Range = 'History'
	GROUP BY	T1.ServerName	
			,T1.DatabaseName	
			,T1.Period
			,T1.DataSize	
			,T1.IndexSize
	ORDER BY	3 desc,1,2

RAISERROR('  Generating #DBResults Table.',-1,-1) WITH NOWAIT

	-- HIDE ANY SHRINKAGE IN SIZE
	SELECT		T1.ServerName
			,T1.DatabaseName
			,T1.Period
			,T1.DataSize
			,T1.IndexSize
			,Smoothed_MetricA
			,Smoothed_MetricB
			--,(
			--	SELECT		[dbaadmin].[dbo].[dbaudf_max_Float](DataSize,T1.Smoothed_MetricA)
			--	FROM		#SmothedHistory
			--	WHERE		ServerName		=  T1.ServerName
			--		AND		DatabaseName	=  T1.DatabaseName
			--		AND		Period		=  T1.Period - 1
			--) Smoothed_MetricA
			--,(
			--	SELECT		[dbaadmin].[dbo].[dbaudf_max_Float](IndexSize,T1.Smoothed_MetricB)
			--	FROM		#SmothedHistory
			--	WHERE		ServerName		=  T1.ServerName
			--		AND		DatabaseName	=  T1.DatabaseName
			--		AND		Period		=  T1.Period - 1
			--) Smoothed_MetricB
	INTO		#DBResults
	FROM		#SmothedHistory T1
	ORDER BY	3 desc,1,2


	CREATE CLUSTERED INDEX [IX_DBResults_1]
	ON [dbo].[#DBResults] ([Period] DESC,[ServerName],[DatabaseName])

	CREATE NONCLUSTERED INDEX [IX_DBResults_2]
	ON [dbo].[#DBResults] ([Period])
	INCLUDE ([ServerName],[DatabaseName],[Smoothed_MetricA],[Smoothed_MetricB])

	CREATE NONCLUSTERED INDEX [IX_DBResults_3]
	ON [dbo].[#DBResults] ([ServerName],[DatabaseName])
	INCLUDE ([Period],[DataSize],[IndexSize],[Smoothed_MetricA],[Smoothed_MetricB])

RAISERROR('  Generating #DriveSnapshot Table.',-1,-1) WITH NOWAIT

	SELECT		CAST(DriveLetter AS CHAR(1)) DriveLetter	
				,TotalSize/POWER(1024.0,2)	TotalSizeMB
				,AvailableSpace/POWER(1024.0,2)	AvailableSpaceMB
				,FreeSpace/POWER(1024.0,2)	FreeSpaceMB
				,DriveType	
				,FileSystem	
				,IsReady	
				,VolumeName	
				,RootFolder
	INTO		#DriveSnapshot
	FROM		dbaadmin.dbo.dbaudf_ListDrives()
	WHERE		IsReady = 1

	CREATE CLUSTERED INDEX [IX_DriveSnapshot_1]
	ON [dbo].[#DriveSnapshot] ([DriveLetter])

RAISERROR('  Starting Forecasting Loop.',-1,-1) WITH NOWAIT

DECLARE @FORECASTDATE VARCHAR(12)
WHILE 1=1
BEGIN
	SELECT		@FORECASTDATE = CONVERT(VarChar(12),DateTimeValue,101)
	FROM		#DateDimension
	WHERE		Period = (SELECT MAX([Period]) FROM #DBResults)+1

	--RAISERROR('    FORECASTING %s.',-1,-1,@FORECASTDATE) WITH NOWAIT
	--RAISERROR('      Calculating DB Data.',-1,-1) WITH NOWAIT


	-- CALCULATE DB DATA
	--
	;WITH		B
			AS
			(
			SELECT		[ServerName]
					,[DatabaseName]
					,MAX([Period])+1 [Period]
					,dbaadmin.dbo.dbaudf_slope	(CAST([Period] as VarChar(50))	+ CHAR(0) +	CAST(Smoothed_MetricA as VarChar(50)))	B_MetricA
					,dbaadmin.dbo.dbaudf_slope	(CAST([Period] as VarChar(50))	+ CHAR(0) +	CAST(Smoothed_MetricB as VarChar(50)))	B_MetricB
					,dbaadmin.dbo.dbaudf_Intercept	(CAST([Period] as VarChar(50))	+ CHAR(0) +	CAST(Smoothed_MetricA as VarChar(50)))	A_MetricA
					,dbaadmin.dbo.dbaudf_Intercept	(CAST([Period] as VarChar(50))	+ CHAR(0) +	CAST(Smoothed_MetricB as VarChar(50)))	A_MetricB
			FROM		#DBResults B
			WHERE		[Period] IN (SELECT DISTINCT TOP (90) [Period] FROM #DBResults WHERE DataSize+IndexSize IS NOT NULL ORDER BY [Period] DESC)
			GROUP BY	[ServerName]
					,[DatabaseName]
			)
			
			
	INSERT INTO	#DBResults ([ServerName],[DatabaseName],[Period],[DataSize],[IndexSize],[Smoothed_MetricA],[Smoothed_MetricB])
	SELECT		[ServerName]	
			,[DatabaseName]
			,[Period] 
			,A_MetricA + (B_MetricA * ([Period]))	
			,A_MetricB + (B_MetricB * ([Period]))	
			,[dbaadmin].[dbo].[dbaudf_max_Float](A_MetricA + (B_MetricA * ([Period])),(SELECT [Smoothed_MetricA] FROM #DBResults WHERE ServerName = B.ServerName AND DatabaseName = B.DatabaseName and Period = B.Period-1))
			,[dbaadmin].[dbo].[dbaudf_max_Float](A_MetricB + (B_MetricB * ([Period])),(SELECT [Smoothed_MetricB] FROM #DBResults WHERE ServerName = B.ServerName AND DatabaseName = B.DatabaseName and Period = B.Period-1))
	FROM		B
	

	--RAISERROR('      Extrapolating Drive Data.',-1,-1) WITH NOWAIT
	-- EXTRAPOLATE DRIVE DATA FROM DB DATA
	--
	;WITH		MasterFileData
				AS
				(
				SELECT		DB_NAME(database_id) [DBName]
							,name 
							,CASE type WHEN 0 THEN 'DATA' WHEN 1 THEN 'LOG' ELSE 'Other' END [FileType]
							,UPPER(LEFT(physical_name,1)) [Drive]
							,(CAST(size AS NUMERIC(38,10))*8)/POWER(1024.0,1) SizeMB
							,CASE max_size
								WHEN 0	THEN (CAST(size AS NUMERIC(38,10))*8)/POWER(1024.0,1) -- CURRENT SIZE IS MAX IF 0
								WHEN -1	THEN (CAST(size AS NUMERIC(38,10))*8)/POWER(1024.0,1) -- CURRENT SIZE + FREE SPACE IS MAX IF -1
											+ CAST(T2.[FreeSpaceMB] AS NUMERIC(38,10))
								ELSE (CAST(max_size AS NUMERIC(38,10))*8)/POWER(1024.0,1) END MaxSizeMB
							,CAST(T2.[FreeSpaceMB] AS NUMERIC(38,10)) FreeSpaceMB
							,max_size
							,growth
							,is_percent_growth
							,CASE is_percent_growth
										WHEN 1 THEN (((growth * size)/100.0)*8)/POWER(1024.0,1)
										ELSE (CAST(growth AS NUMERIC(38,10))*8)/POWER(1024.0,1)
										END [NextGrowthMB]
							,CASE
								WHEN growth = 0												THEN 'No Growth'
								WHEN max_size = 0											THEN 'No Growth'

								-- CURRENT SIZE >= MAX SIZE
								WHEN max_size > 0 
									AND (CAST(size AS NUMERIC(38,10))*8)/POWER(1024.0,1) 
										>= (CAST(max_size AS NUMERIC(38,10))*8)/POWER(1024.0,1) 
																							THEN 'Max Size'

								-- NEXT GROWTH > FREE SPACE
								WHEN CAST(T2.[FreeSpaceMB] AS NUMERIC(38,10)) < 
									CASE is_percent_growth
										WHEN 1 THEN (((growth * size)/100.0)*8)/POWER(1024.0,1)
										ELSE (CAST(growth AS NUMERIC(38,10))*8)/POWER(1024.0,1)
										END													THEN 'No Room On Drive'

								-- CURRENT SIZE + NEXT GROWTH > MAX SIZE
								WHEN max_size > 0 
									AND (CAST(size AS NUMERIC(38,10))*8)/POWER(1024.0,1) 
										+ CASE is_percent_growth
											WHEN 1 THEN (((growth * size)/100.0)*8)/POWER(1024.0,1)
											ELSE (CAST(growth AS NUMERIC(38,10))*8)/POWER(1024.0,1) END
										> (CAST(max_size AS NUMERIC(38,10))*8)/POWER(1024.0,1)		THEN 'No Room Till Max'

								ELSE 'Room To Grow'
								END [Growth_Desc]
				FROM		sys.master_files AS f WITH (NOLOCK)
				JOIN		#DriveSnapshot T2
						ON T2.[DriveLetter] = UPPER(LEFT(physical_name,1))
				WHERE		type != 1
					AND	f.database_id IN (SELECT database_id FROM sys.databases where source_database_id IS NULL)
				)
				,DB2DriveRatios
				AS
				(
				SELECT		DBName
							,COUNT(DISTINCT Drive) [DriveCount]
							,dbaadmin.[dbo].[dbaudf_ConcatenateUnique]([Drive])[DriveList]
				FROM		MasterFileData
				WHERE		Growth_Desc NOT IN ('No Growth','Max Size')
				GROUP BY	DBName
				)
				,GrowthRatio
				AS
				(
				SELECT		DISTINCT
							T1.DBName
							,T1.Drive
							,COALESCE(1/CAST(T2.DriveCount AS NUMERIC(38,10)),0) [GrowthRatio]
							,T1.[FreeSpaceMB]
							,[Growth_Desc]
				FROM		MasterFileData T1
				LEFT JOIN	DB2DriveRatios T2
						ON	T1.DBName = T2.DBName
				)
				,DBGrowth
				AS
				(
				SELECT		T1.[ServerName]	
							,T1.[DatabaseName]
							,T1.[Period]
							,CAST(T1.[Smoothed_MetricA] AS NUMERIC(38,10)) - CAST(T2.[Smoothed_MetricA] AS NUMERIC(38,10))	DataGrowth
							,CAST(T1.[Smoothed_MetricB] AS NUMERIC(38,10)) - CAST(T2.[Smoothed_MetricB] AS NUMERIC(38,10))	IndexGrowth
				FROM		(
							SELECT		*
							FROM		#DBResults
							WHERE		[Period] = (SELECT MAX([Period]) FROM #DBResults)
							) T1
				JOIN		(
							SELECT		*
							FROM		#DBResults
							WHERE		[Period] = (SELECT MAX([Period]) FROM #DateDimension WHERE [Range] = 'HISTORY')
							) T2
						ON	T1.[ServerName]		= T2.[ServerName]
						AND	T1.[DatabaseName]	= T2.[DatabaseName]
				)
	INSERT INTO	#DriveResults ([ServerName],[DriveLetter],[Period],[DataGrowth],[IndexGrowth],[FreeSpaceMB],[Growth_Desc])
	SELECT		T2.ServerName
				,T1.Drive
				,T2.Period
				,SUM(T2.DataGrowth * T1.GrowthRatio)	[DataGrowth]
				,SUM(T2.IndexGrowth * T1.GrowthRatio)	[IndexGrowth]
				,MIN(T1.[FreeSpaceMB]) [FreeSpaceMB]
				,dbaadmin.[dbo].[dbaudf_ConcatenateUnique](T1.DBName+'='+T1.[Growth_Desc])[Growth_Desc]
	FROM		GrowthRatio T1
	JOIN		DBGrowth T2
			ON	T1.DBName = T2.[DatabaseName]
	GROUP BY	T2.ServerName
				,T1.Drive
				,T2.Period


	UPDATE		T1
		SET		[FreeSpaceMB] = T1.[FreeSpaceMB] - ((T2.[DataGrowth]+T2.[IndexGrowth])-(T3.[DataGrowth]+T3.[IndexGrowth]))
	FROM		#DriveSnapshot T1
	JOIN		(
				SELECT		*
				FROM		#DriveResults
				WHERE		[Period] = (SELECT MAX([Period]) FROM #DBResults)
				) T2
			ON	T1.[DriveLetter] = T2.[DriveLetter]
	JOIN		(
				SELECT		*
				FROM		#DriveResults
				WHERE		[Period] = (SELECT MAX([Period]) FROM #DBResults)-1
				) T3
			ON	T1.[DriveLetter] = T3.[DriveLetter]

	--RAISERROR('        %s Done.',-1,-1,@FORECASTDATE) WITH NOWAIT

	-- DROP OUT OF LOOP IF END OR FORECAST RANGE IS REACHED
	IF (SELECT MAX([Period]) FROM #DBResults) = (SELECT MAX([Period]) FROM #DateDimension) BREAK

END
RAISERROR('  Finnishing Forecasting Loop.',-1,-1) WITH NOWAIT

BEGIN -- OUTPUT SECTION
	RAISERROR('  Building #DBSummary Table.',-1,-1) WITH NOWAIT

	;WITH		DBResults
				AS
				(
				SELECT		T1.ServerName
							,T1.DatabaseName
							,T3.DateTimeValue
							,CASE T3.Range WHEN 'History' THEN Smoothed_MetricA + Smoothed_MetricB ELSE NULL END [Recorded_Smooth]
							,CASE T3.Range WHEN 'History' THEN NULL ELSE Smoothed_MetricA + Smoothed_MetricB END [Forecasted]
							,DataSize + IndexSize [Actual]
				FROM		#DBResults T1
				JOIN		#DateDimension T3
						ON	T1.Period = T3.Period
				)
				,DBDates
				AS
				(
				SELECT		T1.ServerName
							,T1.DatabaseName
							,MIN(T3.DateTimeValue) [History_StartDate]
							,MAX(CASE T3.Range WHEN 'History' THEN T3.DateTimeValue END) [History_EndDate]
							,MAX(T3.DateTimeValue) [Forecast_EndDate]
				FROM		#DBResults T1
				JOIN		#DateDimension T3
						ON	T1.Period = T3.Period
				WHERE		COALESCE(DataSize,0) + COALESCE(IndexSize,0) > 0
				GROUP BY	T1.ServerName
							,T1.DatabaseName
				)
	SELECT		T1.ServerName
				,T1.DatabaseName
				,T1.[History_StartDate]
				,T2.[Actual] [History_StartSize]
				,T1.[History_EndDate]
				,T3.[Actual] [History_EndSize]
				,T1.[Forecast_EndDate]
				,T4.[Actual] [Forecast_EndSize]
				,DATEDIFF(day,T1.[History_StartDate],T1.[History_EndDate]+1) [DaysOfHistory]
				,DATEDIFF(day,T1.[History_EndDate],T1.[Forecast_EndDate]) [DaysForecasted]
	INTO		#DBSummary
	FROM		DBDates T1
	JOIN		DBResults T2
		ON		T1.ServerName = T2.ServerName
		AND		T1.DatabaseName = T2.DatabaseName
		AND		T1.[History_StartDate] = T2.[DateTimeValue]
	JOIN		DBResults T3
		ON		T1.ServerName = T3.ServerName
		AND		T1.DatabaseName = T3.DatabaseName
		AND		T1.[History_EndDate] = T3.[DateTimeValue]
	JOIN		DBResults T4
		ON		T1.ServerName = T4.ServerName
		AND		T1.DatabaseName = T4.DatabaseName
		AND		T1.[Forecast_EndDate] = T4.[DateTimeValue]


	---------------------------------------------------------------
	---------------------------------------------------------------
	--		POPULATE OR BUILD DMV_DATABASE_FORECAST_SUMMARY
	---------------------------------------------------------------
	---------------------------------------------------------------
	IF OBJECT_ID('dbaperf.dbo.DMV_DATABASE_FORECAST_SUMMARY') IS NULL
	BEGIN
		RAISERROR('    Creating dbaperf.dbo.DMV_DATABASE_FORECAST_SUMMARY Table.',-1,-1) WITH NOWAIT

		SELECT		@RunDate [RunDate]
					,*
		INTO		dbaperf.dbo.DMV_DATABASE_FORECAST_SUMMARY
		FROM		#DBSummary
	END
	ELSE
	BEGIN
		RAISERROR('    Populating dbaperf.dbo.DMV_DATABASE_FORECAST_SUMMARY Table.',-1,-1) WITH NOWAIT

		DELETE		dbaperf.dbo.DMV_DATABASE_FORECAST_SUMMARY
		WHERE		[RunDate] = @RunDate

		INSERT INTO	dbaperf.dbo.DMV_DATABASE_FORECAST_SUMMARY
		SELECT		@RunDate [RunDate]
					,*
		FROM		#DBSummary
	END


	RAISERROR('  Building #DriveSummary Table.',-1,-1) WITH NOWAIT

	;WITH		DriveResults
				AS
				(
				SELECT		T1.ServerName
							,T1.DriveLetter
							,T1.Period
							,T3.DateTimeValue
							,T2.TotalSize/power(1024.0,2) [DriveSize_MB]
							,T2.TotalSize/power(1024.0,2) - T2.FreeSpace/power(1024.0,2) [CurrentUsed_MB]
							,(T2.TotalSize/power(1024.0,2) - T2.FreeSpace/power(1024.0,2)) + (T1.DataGrowth + T1.IndexGrowth) [ForecastUsed_MB]
							,CASE WHEN T2.FreeSpace/power(1024.0,2) - (T1.DataGrowth + T1.IndexGrowth) < 0 THEN 'Failed' END [Status]
				FROM		#DriveResults T1
				JOIN		dbaadmin.dbo.dbaudf_ListDrives() T2
						ON	T1.DriveLetter = T2.DriveLetter
				JOIN		#DateDimension T3
						ON	T1.Period = T3.Period
				)
				,FailDates
				AS
				(
				SELECT		ServerName
							,DriveLetter
							,MIN(DateTimeValue) [FailDate]
				FROM		DriveResults
				WHERE		[Status] = 'Failed'
				GROUP BY	ServerName
							,DriveLetter
				)
	SELECT		T1.ServerName
				,T1.DriveLetter
				,T1.DateTimeValue [ForecastedTo]
				,T2.[FailDate]
				,DATEDIFF(day,getdate(),T1.DateTimeValue) [DaysForecasted]
				,DATEDIFF(day,getdate(),T2.[FailDate]) [DaysTillFail]
				,T1.ForecastUsed_MB-T1.CurrentUsed_MB [TotalGrowth_MB]
				,T1.DriveSize_MB-T1.ForecastUsed_MB [FinalFreeSpace_MB]
	INTO		#DriveSummary
	FROM		DriveResults T1
	LEFT JOIN	FailDates T2
			ON	T1.ServerName = T2.ServerName
			AND	T1.DriveLetter = T2.DriveLetter
	WHERE		T1.Period = (SELECT MAX(Period) FROM DriveResults)
	ORDER BY	1,2


	---------------------------------------------------------------
	---------------------------------------------------------------
	--		POPULATE OR BUILD DMV_DRIVE_FORECAST_SUMMARY
	---------------------------------------------------------------
	---------------------------------------------------------------
	IF OBJECT_ID('dbaperf.dbo.DMV_DRIVE_FORECAST_SUMMARY') IS NULL
	BEGIN
		RAISERROR('    Creating dbaperf.dbo.DMV_DRIVE_FORECAST_SUMMARY Table.',-1,-1) WITH NOWAIT

		SELECT		@RunDate [RunDate]
					,*
		INTO		dbaperf.dbo.DMV_DRIVE_FORECAST_SUMMARY
		FROM		#DriveSummary
	END
	ELSE
	BEGIN
		RAISERROR('    Populating dbaperf.dbo.DMV_DRIVE_FORECAST_SUMMARY Table.',-1,-1) WITH NOWAIT

		DELETE		dbaperf.dbo.DMV_DRIVE_FORECAST_SUMMARY
		WHERE		[RunDate] = @RunDate

		INSERT INTO	dbaperf.dbo.DMV_DRIVE_FORECAST_SUMMARY
		SELECT		@RunDate [RunDate]
					,*
		FROM		#DriveSummary
	END


	DECLARE		@HTMLOutput				VarChar(max)
	DECLARE		@Output_Path			VarChar(1024)
	DECLARE		@HTMLOut_File			VarChar(1024)
	DECLARE		@TitleString			VarChar(max)
	DECLARE		@HA_TitleString			VarChar(max)
	DECLARE		@DriveLetter			CHAR(1)
	DECLARE		@ServerName				SYSNAME
	DECLARE		@DatabaseName			SYSNAME
	DECLARE		@TableName				SYSNAME
	DECLARE		@ForecastedTo			DateTime
	DECLARE		@FailDate				DateTime
	DECLARE		@DaysForecasted			INT
	DECLARE		@DaysTillFail			INT
	DECLARE		@TotalGrowth_MB			NUMERIC(38,10)
	DECLARE		@FinalFreeSpace_MB		NUMERIC(38,10)
	DECLARE		@History_StartDate		DATETIME
	DECLARE		@History_StartSize		NUMERIC(38,10)
	DECLARE		@History_EndDate		DATETIME
	DECLARE		@History_EndSize		NUMERIC(38,10)
	DECLARE		@Forecast_EndDate		DATETIME
	DECLARE		@Forecast_EndSize		NUMERIC(38,10)
	DECLARE		@DaysOfHistory			INT
	DECLARE		@FileName				VARCHAR(MAX)
	DECLARE		@SCRIPT					NVARCHAR(4000)
	DECLARE		@target_env				SYSNAME
	DECLARE		@target_server			SYSNAME
	DECLARE		@target_share			SYSNAME
	DECLARE		@retry_limit			INT
	DECLARE		@UniqueVal				sysname

	SELECT		@Output_Path	= '\\'+REPLACE(@@ServerName,'\'+@@ServiceName,'')+'\'+REPLACE(@@ServerName,'\','$')+'_dbasql\dba_reports'
				,@target_env	= 'amer'
				,@target_server	= 'SEAPSQLDBA01'
				,@target_share	= 'SEAPSQLDBA01_dbasql\DiskSpaceChecks'
				,@retry_limit	= 5

	RAISERROR('  Generating Database Size Forecast Charts.',-1,-1) WITH NOWAIT
	--------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------
	--				GENERATE DATABASE SIZE FORECAST CHARTS
	--------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------
	SET @HTMLOut_File = @Output_Path +'\'+ 'DBGrowthForecast_' + REPLACE(@@ServerName,'\','$') + '_DB_ALL.html' 
	EXEC dbaadmin.dbo.dbasp_FileAccess_Write '',@HTMLOut_File,0,1

	DECLARE DBCursor CURSOR
	FOR
	SELECT		ServerName	
				,DatabaseName	
				,History_StartDate	
				,History_StartSize	
				,History_EndDate	
				,History_EndSize	
				,Forecast_EndDate	
				,Forecast_EndSize	
				,DaysOfHistory	
				,DaysForecasted
	FROM		#DBSummary
	ORDER BY	1,2

	OPEN DBCursor;
	FETCH DBCursor INTO @ServerName,@DatabaseName,@History_StartDate,@History_StartSize,@History_EndDate,@History_EndSize,@Forecast_EndDate,@Forecast_EndSize,@DaysOfHistory,@DaysForecasted;
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			---------------------------- 
			---------------------------- CURSOR LOOP TOP
			SET @UniqueVal = @DatabaseName
			SET @HTMLOutput = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
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
      function drawVisualization_'+@UniqueVal+'() {
        // Create and populate the data table.
        var data_'+@UniqueVal+' = new google.visualization.DataTable();
        data_'+@UniqueVal+'.addColumn(''string'', ''Date'');
        data_'+@UniqueVal+'.addColumn(''number'', ''Recorded'');
        data_'+@UniqueVal+'.addColumn(''number'', ''Forecast'');
        data_'+@UniqueVal+'.addColumn(''number'', ''Actual'');
        data_'+@UniqueVal+'.addRows(['+CHAR(13)+CHAR(10)


		;WITH			FinalData
						AS
						(
						SELECT		T1.ServerName
									,T1.DatabaseName
									,T3.DateTimeValue
									,CASE T3.Range WHEN 'History' THEN Smoothed_MetricA + Smoothed_MetricB ELSE NULL END [Recorded_Smooth]
									,CASE T3.Range WHEN 'History' THEN NULL ELSE Smoothed_MetricA + Smoothed_MetricB END [Forecasted]
									,COALESCE(DataSize,0) + COALESCE(IndexSize,0) [Actual]
						FROM		#DBResults T1
						JOIN		#DateDimension T3
								ON	T1.Period = T3.Period
						)
			SELECT		@HTMLOutput		= @HTMLOutput +
										'            [''' + CONVERT(VarChar(12),[DateTimeValue],101)
										+ ''','	+ COALESCE(CAST([Recorded_Smooth] AS VarChar(50)),'')	
										+ ','	+ COALESCE(CAST([Forecasted] AS VarChar(50)),'')
										+ ','	+ COALESCE(CAST([Actual] AS VarChar(50)),'')
										+ '],'	+CHAR(13)+CHAR(10)
			FROM		FinalData
			WHERE		[ServerName] = @ServerName
					AND	[DatabaseName] = @DatabaseName
			ORDER BY	[DateTimeValue]
	
			SELECT		@TitleString		= CAST(@DaysForecasted AS VarChar(10)) +' Day Database Size Forecast for '+ @ServerName + '.' + @DatabaseName 
						,@HA_TitleString	= CONVERT(VarChar(12),@History_StartDate,101) + ' -(' +CAST(@DaysOfHistory AS VarChar(10))+ ' Days Of History)- ' + CONVERT(VarChar(12),@History_EndDate,101) + ' -(' +CAST(@DaysForecasted AS VarChar(10))+ ' Days Forecasted)- ' + CONVERT(VarChar(12),@Forecast_EndDate,101)
						,@HTMLOut_File		= 'DBGrowthForecast_' + REPLACE(@@ServerName,'\','$') + '_DB_'+ @DatabaseName + '.html'


			SELECT		@HTMLOutput = @HTMLOutput +'      ]);
		var chart_'+@UniqueVal+'		= new google.visualization.ComboChart(document.getElementById(''chart_'+@UniqueVal+'''));
		var options_'+@UniqueVal+'	= {curveType: "function",
							pointSize: 2, 
							width: 800, 
							height: 400, 
							legend: "bottom", 
							title: "'+@TitleString+'",
							vAxis: {title: "SPACE USED IN MB"},
							hAxis: {title: "'+@HA_TitleString+'"},
							seriesType: "area",
							series: {1:{type: "area"}, 2:{type: "line"}}
							};
		
		var table_'+@UniqueVal+'		= new google.visualization.Table(document.getElementById(''table_'+@UniqueVal+'''));
		var dataView_'+@UniqueVal+'	= new google.visualization.DataView(data_'+@UniqueVal+');
		
        // Create and draw the visualization.
		dataView_'+@UniqueVal+'.setColumns([0,1,2,3]);
        chart_'+@UniqueVal+'.draw(dataView_'+@UniqueVal+', options_'+@UniqueVal+');  
		table_'+@UniqueVal+'.draw(data_'+@UniqueVal+', null);
        }
	function ShowHide_'+@UniqueVal+'(divId) 
		{
		if(document.getElementById(divId).style.display == ''none'')
			{
			document.getElementById(divId).style.display=''block'';
			}
		else
			{
			document.getElementById(divId).style.display = ''none'';
			}
		drawVisualization_'+@UniqueVal+';
		}
      google.setOnLoadCallback(drawVisualization_'+@UniqueVal+');
    </script>
  </head>
  <body style="font-family: Arial;border: 0 none;">
    <div id="chart_'+@UniqueVal+'" style="width: 800px; height: 400px;"></div>
	<input id="ShowHideData_'+@UniqueVal+'" type="button" value="Show/Hide Data" onclick="ShowHide_'+@UniqueVal+'(''table_'+@UniqueVal+''')" />
	<div id="table_'+@UniqueVal+'" style="DISPLAY: none"></div>
 </body>
</html>'
		
			SET @HTMLOut_File = @Output_Path +'\'+ @HTMLOut_File
			RAISERROR('    Writing %s File to %s.',-1,-1,@DatabaseName,@HTMLOut_File) WITH NOWAIT
			EXEC dbaadmin.dbo.dbasp_FileAccess_Write @HTMLOutput,@HTMLOut_File,0,1

			SET @HTMLOut_File = @Output_Path +'\'+ 'DBGrowthForecast_' + REPLACE(@@ServerName,'\','$') + '_DB_ALL.html' 
			EXEC dbaadmin.dbo.dbasp_FileAccess_Write @HTMLOutput,@HTMLOut_File,1,1
			---------------------------- CURSOR LOOP BOTTOM
			----------------------------
		END
 		FETCH NEXT FROM DBCursor INTO @ServerName,@DatabaseName,@History_StartDate,@History_StartSize,@History_EndDate,@History_EndSize,@Forecast_EndDate,@Forecast_EndSize,@DaysOfHistory,@DaysForecasted;
	END
	CLOSE DBCursor;
	DEALLOCATE DBCursor;

	SET @FileName = 'DBGrowthForecast_' + REPLACE(@@ServerName,'\','$') + '_DB_ALL.html' 
	RAISERROR('  Sending ALL DB Chart.',-1,-1) WITH NOWAIT
	EXEC	[dbaadmin].[dbo].[dbasp_File_Transit] 
			@source_name		= @FileName
			,@source_path		= @Output_Path
			,@target_env		= @target_env
			,@target_server		= @target_server
			,@target_share		= @target_share
			,@retry_limit		= @retry_limit



	---------------------------------------------------------------
	---------------------------------------------------------------
	--		POPULATE OR BUILD DMV_DATABASE_FORECAST_DETAIL
	---------------------------------------------------------------
	---------------------------------------------------------------
	IF OBJECT_ID('dbaperf.dbo.DMV_DATABASE_FORECAST_DETAIL') IS NULL
	BEGIN
		RAISERROR('  Creating dbaperf.dbo.DMV_DATABASE_FORECAST_DETAIL Table.',-1,-1) WITH NOWAIT

		SELECT		@RunDate [RunDate]
					,T1.ServerName
					,T1.DatabaseName
					,T3.DateTimeValue
					,CASE T3.Range WHEN 'History' THEN Smoothed_MetricA + Smoothed_MetricB ELSE NULL END [Recorded_Smooth]
					,CASE T3.Range WHEN 'History' THEN NULL ELSE Smoothed_MetricA + Smoothed_MetricB END [Forecasted]
					,DataSize + IndexSize [Actual]
		INTO		dbaperf.dbo.DMV_DATABASE_FORECAST_DETAIL
		FROM		#DBResults T1
		JOIN		#DateDimension T3
				ON	T1.Period = T3.Period
	END
	ELSE
	BEGIN
		RAISERROR('  Populating dbaperf.dbo.DMV_DATABASE_FORECAST_DETAIL Table.',-1,-1) WITH NOWAIT

		DELETE		dbaperf.dbo.DMV_DATABASE_FORECAST_DETAIL
		WHERE		[RunDate] = @RunDate

		INSERT INTO	dbaperf.dbo.DMV_DATABASE_FORECAST_DETAIL
		SELECT		@RunDate [RunDate]
					,T1.ServerName
					,T1.DatabaseName
					,T3.DateTimeValue
					,CASE T3.Range WHEN 'History' THEN Smoothed_MetricA + Smoothed_MetricB ELSE NULL END [Recorded_Smooth]
					,CASE T3.Range WHEN 'History' THEN NULL ELSE Smoothed_MetricA + Smoothed_MetricB END [Forecasted]
					,DataSize + IndexSize [Actual]
		FROM		#DBResults T1
		JOIN		#DateDimension T3
				ON	T1.Period = T3.Period
	END


	RAISERROR('  Generating Drive Space Forecast Charts.',-1,-1) WITH NOWAIT
	--------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------
	--				GENERATE DRIVE SPACE FORECAST CHARTS
	--------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------
	SET @HTMLOut_File = @Output_Path +'\'+ 'DBGrowthForecast_' + REPLACE(@@ServerName,'\','$') + '_DRIVE_ALL.html' 
	EXEC dbaadmin.dbo.dbasp_FileAccess_Write '',@HTMLOut_File,0,1

	DECLARE DriveCursor CURSOR
	FOR
	SELECT		ServerName	
				,DriveLetter	
				,ForecastedTo	
				,FailDate	
				,DaysForecasted	
				,DaysTillFail	
				,TotalGrowth_MB	
				,FinalFreeSpace_MB
	FROM		#DriveSummary
	ORDER BY	1,2

	OPEN DriveCursor;
	FETCH DriveCursor INTO @ServerName,@DriveLetter,@ForecastedTo,@FailDate,@DaysForecasted,@DaysTillFail,@TotalGrowth_MB,@FinalFreeSpace_MB; 
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			---------------------------- 
			---------------------------- CURSOR LOOP TOP
			SET @UniqueVal = @DriveLetter
			SET @HTMLOutput = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
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
      function drawVisualization_'+@UniqueVal+'() {
        // Create and populate the data table.
        var data_'+@UniqueVal+' = new google.visualization.DataTable();
        data_'+@UniqueVal+'.addColumn(''string'', ''Date'');
        data_'+@UniqueVal+'.addColumn(''number'', ''Forecast'');
        data_'+@UniqueVal+'.addColumn(''number'', ''Current'');
        data_'+@UniqueVal+'.addColumn(''number'', ''Limit'');
		data_'+@UniqueVal+'.addColumn(''string'', ''Status'');   
        data_'+@UniqueVal+'.addRows(['+CHAR(13)+CHAR(10)

		;WITH			FinalData
						AS
						(
						SELECT		T1.ServerName
									,T1.DriveLetter
									,T1.Period
									,T3.DateTimeValue
									,T2.TotalSize/power(1024.0,2) [DriveSize_MB]
									,T2.TotalSize/power(1024.0,2) - T2.FreeSpace/power(1024.0,2) [CurrentUsed_MB]
									,(T2.TotalSize/power(1024.0,2) - T2.FreeSpace/power(1024.0,2)) + (T1.DataGrowth + T1.IndexGrowth) [ForecastUsed_MB]
									,CASE WHEN T2.FreeSpace/power(1024.0,2) - (T1.DataGrowth + T1.IndexGrowth) < 0 THEN 'FULL' END [Status]
						FROM		#DriveResults T1
						JOIN		dbaadmin.dbo.dbaudf_ListDrives() T2
								ON	T1.DriveLetter = T2.DriveLetter
						JOIN		#DateDimension T3
								ON	T1.Period = T3.Period
						)
			SELECT		@HTMLOutput		= @HTMLOutput +
										'            [''' + CONVERT(VarChar(12),[DateTimeValue],101)
										+ ''','	+ CAST(COALESCE([ForecastUsed_MB],'')	AS VarChar(50))
										+ ','	+ CAST(COALESCE([CurrentUsed_MB],'')	AS VarChar(50))
										+ ','	+ CAST(COALESCE([DriveSize_MB],'')		AS VarChar(50))
										+ ','''	+ CAST(COALESCE([Status],'')			AS VarChar(50))
										+ '''],'	+CHAR(13)+CHAR(10)
			FROM		FinalData
			WHERE		[ServerName] = @ServerName
					AND	[DriveLetter] = @DriveLetter
			ORDER BY	[DateTimeValue]
	
			SELECT		@TitleString		= CAST(@DaysForecasted AS VarChar(10)) +' Day Drive Growth Forecast for '+ @ServerName + ' on ' + 'Drive '+ @DriveLetter 
						,@HA_TitleString	= CONVERT(VarChar(12),getdate(),101) + ' - ' + CONVERT(VarChar(12),@ForecastedTo,101)
											+ COALESCE(' ** FAILURE IN ' + CAST(@DaysTillFail AS VarChar(10)) + ' Days, on ' + CONVERT(VarChar(12),@FailDate,101) + ' **','')
						,@HTMLOut_File		= 'DBGrowthForecast_' + REPLACE(@@ServerName,'\','$') + '_Drive_'+ @DriveLetter + '.html'


			SELECT		@HTMLOutput = @HTMLOutput +'      ]);
		var chart_'+@UniqueVal+'		= new google.visualization.ComboChart(document.getElementById(''chart_'+@UniqueVal+'''));
		var options_'+@UniqueVal+'	= {curveType: "function",
							pointSize: 2, 
							width: 800, 
							height: 400, 
							legend: "bottom", 
							title: "'+@TitleString+'",
							vAxis: {title: "SPACE USED IN MB"},
							hAxis: {title: "'+@HA_TitleString+'"},
							seriesType: "area",
							series: {1:{type: "line"}, 2:{type: "line"}}
							};
		
		var table_'+@UniqueVal+'		= new google.visualization.Table(document.getElementById(''table_'+@UniqueVal+'''));
		var dataView_'+@UniqueVal+'	= new google.visualization.DataView(data_'+@UniqueVal+');
		
        // Create and draw the visualization.
		dataView_'+@UniqueVal+'.setColumns([0,1,2,3]);
        chart_'+@UniqueVal+'.draw(dataView_'+@UniqueVal+', options_'+@UniqueVal+');  
		table_'+@UniqueVal+'.draw(data_'+@UniqueVal+', null);
        }
	function ShowHide_'+@UniqueVal+'(divId) 
		{
		if(document.getElementById(divId).style.display == ''none'')
			{
			document.getElementById(divId).style.display=''block'';
			}
		else
			{
			document.getElementById(divId).style.display = ''none'';
			}
		drawVisualization_'+@UniqueVal+';
		}
      google.setOnLoadCallback(drawVisualization_'+@UniqueVal+');
    </script>
  </head>
  <body style="font-family: Arial;border: 0 none;">
    <div id="chart_'+@UniqueVal+'" style="width: 800px; height: 400px;"></div>
	<input id="ShowHideData_'+@UniqueVal+'" type="button" value="Show/Hide Data" onclick="ShowHide_'+@UniqueVal+'(''table_'+@UniqueVal+''')" />
	<div id="table_'+@UniqueVal+'" style="DISPLAY: none"></div>
 </body>
</html>'
		
			SET @HTMLOut_File = @Output_Path +'\'+ @HTMLOut_File
			RAISERROR('    Writing %s File to %s.',-1,-1,@DatabaseName,@HTMLOut_File) WITH NOWAIT
			EXEC dbaadmin.dbo.dbasp_FileAccess_Write @HTMLOutput,@HTMLOut_File,0,1

			SET @HTMLOut_File = @Output_Path +'\'+ 'DBGrowthForecast_' + REPLACE(@@ServerName,'\','$') + '_DRIVE_ALL.html' 
			EXEC dbaadmin.dbo.dbasp_FileAccess_Write @HTMLOutput,@HTMLOut_File,1,1
			---------------------------- CURSOR LOOP BOTTOM
			----------------------------
		END
 		FETCH NEXT FROM DriveCursor INTO @ServerName,@DriveLetter,@ForecastedTo,@FailDate,@DaysForecasted,@DaysTillFail,@TotalGrowth_MB,@FinalFreeSpace_MB;
	END
	CLOSE DriveCursor;
	DEALLOCATE DriveCursor;

	SET @FileName = 'DBGrowthForecast_' + REPLACE(@@ServerName,'\','$') + '_DRIVE_ALL.html' 
	RAISERROR('  Sending ALL DRIVE Chart.',-1,-1) WITH NOWAIT
	EXEC	[dbaadmin].[dbo].[dbasp_File_Transit] 
			@source_name		= @FileName
			,@source_path		= @Output_Path
			,@target_env		= @target_env
			,@target_server		= @target_server
			,@target_share		= @target_share
			,@retry_limit		= @retry_limit

	---------------------------------------------------------------
	---------------------------------------------------------------
	--		POPULATE OR BUILD DMV_DRIVE_FORECAST_DETAIL
	---------------------------------------------------------------
	---------------------------------------------------------------
	IF OBJECT_ID('dbaperf.dbo.DMV_DRIVE_FORECAST_DETAIL') IS NULL
	BEGIN
		RAISERROR('  Creating dbaperf.dbo.DMV_DRIVE_FORECAST_DETAIL Table.',-1,-1) WITH NOWAIT

		SELECT		@RunDate [RunDate]
					,T1.ServerName
					,T1.DriveLetter
					,T3.DateTimeValue
					,T2.TotalSize/power(1024.0,2) [DriveSize_MB]
					,T2.TotalSize/power(1024.0,2) - T2.FreeSpace/power(1024.0,2) [CurrentUsed_MB]
					,(T2.TotalSize/power(1024.0,2) - T2.FreeSpace/power(1024.0,2)) + (T1.DataGrowth + T1.IndexGrowth) [ForecastUsed_MB]
					,CASE WHEN T2.FreeSpace/power(1024.0,2) - (T1.DataGrowth + T1.IndexGrowth) < 0 THEN 'FULL' END [Status]
		INTO		dbaperf.dbo.DMV_DRIVE_FORECAST_DETAIL
		FROM		#DriveResults T1
		JOIN		dbaadmin.dbo.dbaudf_ListDrives() T2
				ON	T1.DriveLetter = T2.DriveLetter
		JOIN		#DateDimension T3
				ON	T1.Period = T3.Period
	END
	ELSE
	BEGIN
		RAISERROR('  Populating dbaperf.dbo.DMV_DRIVE_FORECAST_DETAIL Table.',-1,-1) WITH NOWAIT

		DELETE		dbaperf.dbo.DMV_DRIVE_FORECAST_DETAIL
		WHERE		[RunDate] = @RunDate

		INSERT INTO	dbaperf.dbo.DMV_DRIVE_FORECAST_DETAIL
		SELECT		@RunDate [RunDate]
					,T1.ServerName
					,T1.DriveLetter
					,T3.DateTimeValue
					,T2.TotalSize/power(1024.0,2) [DriveSize_MB]
					,T2.TotalSize/power(1024.0,2) - T2.FreeSpace/power(1024.0,2) [CurrentUsed_MB]
					,(T2.TotalSize/power(1024.0,2) - T2.FreeSpace/power(1024.0,2)) + (T1.DataGrowth + T1.IndexGrowth) [ForecastUsed_MB]
					,CASE WHEN T2.FreeSpace/power(1024.0,2) - (T1.DataGrowth + T1.IndexGrowth) < 0 THEN 'FULL' END [Status]
		FROM		#DriveResults T1
		JOIN		dbaadmin.dbo.dbaudf_ListDrives() T2
				ON	T1.DriveLetter = T2.DriveLetter
		JOIN		#DateDimension T3
				ON	T1.Period = T3.Period
	END

END -- OUTPUT SECTION


DECLARE ExportCursor CURSOR
FOR
		SELECT	'dbaperf.dbo.DMV_DATABASE_FORECAST_SUMMARY' [TableName]
UNION ALL	SELECT	'dbaperf.dbo.DMV_DATABASE_FORECAST_DETAIL'
UNION ALL	SELECT	'dbaperf.dbo.DMV_DRIVE_FORECAST_SUMMARY'
UNION ALL	SELECT	'dbaperf.dbo.DMV_DRIVE_FORECAST_DETAIL'

OPEN ExportCursor;
FETCH ExportCursor INTO @TableName;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP

		SELECT	@FileName	= REPLACE([dbaadmin].[dbo].[dbaudf_base64_encode] (@@SERVERNAME+'|'+REPLACE(@TableName,'dbaperf.dbo.',''))+'.dat','=','$')
			,@SCRIPT	= 'bcp "SELECT * FROM '+@TableName+' WHERE [RunDate] = '''+CONVERT(VarChar(12),@RunDate,101)+'''" queryout "'+@Output_Path+'\'+@FileName+'" -S '+@@Servername+' -T -N'

		RAISERROR('Exporting Data from %s to file %s.',-1,-1,@TableName,@FileName) WITH NOWAIT
		EXEC	xp_cmdshell		@SCRIPT, no_output

		RAISERROR('  Sending Data from %s.',-1,-1,@TableName) WITH NOWAIT
		EXEC	[dbaadmin].[dbo].[dbasp_File_Transit] 
				@source_name		= @FileName
				,@source_path		= @Output_Path
				,@target_env		= @target_env
				,@target_server		= @target_server
				,@target_share		= @target_share
				,@retry_limit		= @retry_limit
  
		waitfor delay '00:00:05'  
  
		-- DELETE FILE AFTER SENDING
		RAISERROR('    Deleting file %s after sending.',-1,-1,@FileName) WITH NOWAIT
		SET		@SCRIPT = 'DEL "'+ @Output_Path+'\'+@FileName+'"'
		exec	master..xp_cmdshell @Script, no_output

		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM ExportCursor INTO @TableName;
END
CLOSE ExportCursor;
DEALLOCATE ExportCursor;



