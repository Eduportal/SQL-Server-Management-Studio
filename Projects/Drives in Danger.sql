-- Do not lock anything, and do not get held up by any locks. 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE		@ServerName		SYSNAME

SET			@ServerName		= 'G1SQLA\A'


;WITH		DriveData
			AS
			(
			SELECT [SQLName]
				  ,REPLACE([Unit],'DRIVE_','') AS [Drive]
				  ,[Period]
				  ,DATEADD(week,CAST(REPLACE([Period],LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'-','') AS BIGINT)-1,DATEADD(day,(DATEPART(weekday,CAST(LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'0101' AS DateTime))-1)*(-1),CAST(LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'0101' AS DateTime))) AS [Time]
				  ,CASE WHEN [Forecast] >= 0 THEN [Forecast]
						ELSE (	SELECT AVG([Forecast]) 
								FROM [DBAperf_reports].[dbo].[DMV_DiskSpaceForecast] 
								WHERE SQLName = T1.SQLName 
									AND Unit = T1.Unit 
									AND NULLIF(ABS(CAST(REPLACE(Period,'-','.')AS FLOAT) 
										- CAST(REPLACE(T1.Period,'-','.')AS FLOAT)),0) < .02)
				  END AS [Value]
				  ,[Forecast]
				  ,[LimitDataSizeMB] AS [MAX]
			FROM	[DBAperf_reports].[dbo].[DMV_DiskSpaceForecast] T1 WITH(NOLOCK)
			WHERE	COALESCE(CAST([Forecast] AS BIGINT),0) != 0
				AND	SQLName IN (SELECT SQLName FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
				--AND	LEFT([SQLName],CHARINDEX('\',[SQLName]+'\')-1) = LEFT(@ServerName,CHARINDEX('\',@ServerName+'\')-1)
			)
			,DrivesInDanger
			AS
			(
			SELECT [SQLName]
				  ,REPLACE([Unit],'DRIVE_','') AS [Drive]
				  ,MIN([Period]) [Period]
				  ,MIN(DATEADD(week,CAST(REPLACE([Period],LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'-','') AS BIGINT)-1,DATEADD(day,(DATEPART(weekday,CAST(LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'0101' AS DateTime))-1)*(-1),CAST(LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'0101' AS DateTime)))) AS [Time]
			FROM	[DBAperf_reports].[dbo].[DMV_DiskSpaceForecast]
			WHERE	COALESCE(CAST([Forecast] AS BIGINT),0) != 0
				AND COALESCE(CAST([Forecast] AS BIGINT),0) >= CAST([LimitDataSizeMB] AS BIGINT)
				AND	SQLName IN (SELECT SQLName FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
				--AND	LEFT([SQLName],CHARINDEX('\',[SQLName]+'\')-1) = LEFT(@ServerName,CHARINDEX('\',@ServerName+'\')-1)
			GROUP BY	[SQLName]
						,REPLACE([Unit],'DRIVE_','')
			)
SELECT		DriveData.SQLName
			,DriveData.Drive
			,DATEDIFF(Week,getdate(),DrivesInDanger.Time) [WeeksTillFull]
			,DriveData.Time
			,CAST(DriveData.Value/1024.0 AS FLOAT) [Value]
			--,CAST(REPLACE([dbaadmin].[dbo].[dbaudf_FormatNumber] (DriveData.Value/1024.0,0,2),',','')AS FLOAT) [Value]
			,CAST(REPLACE([dbaadmin].[dbo].[dbaudf_FormatNumber] (DriveData.MAX/1024.0,0,2),',','')AS FLOAT) [Max]
			,CASE WHEN DriveData.Period = DrivesInDanger.Period THEN CAST(REPLACE([dbaadmin].[dbo].[dbaudf_FormatNumber] (DriveData.MAX/1024.0,0,2),',','')AS FLOAT) ELSE 0 END AS TOF
FROM		DriveData
JOIN		DrivesInDanger
		ON	DrivesInDanger.SQLName	= DriveData.SQLName
		AND	DrivesInDanger.Drive	= DriveData.Drive
		AND DrivesInDanger.Time > getdate()-30
ORDER BY	3,1,2,4




SELECT		*
FROM		(
			SELECT		ROW_NUMBER() OVER(PARTITION BY ServerName, DriveLetter ORDER BY RunDate DESC) RowNumber
						,*
			FROM		[dbo].[DMV_DRIVE_FORECAST_SUMMARY]
			WHERE		FailDate IS NOT NULL
				AND		ServerName IN (Select SQLName From dbacentral.[dbo].[DBA_ServerInfo] Where active = 'Y')
			) Data
WHERE		RowNumber = 1
ORDER BY	8,3,4



SELECT		*
FROM		(
			SELECT		ROW_NUMBER() OVER(PARTITION BY ServerName,DriveLetter,DateTimeValue ORDER BY RunDate DESC) RowNumber
						,*
			FROM		[dbo].[DMV_DRIVE_FORECAST_DETAIL]
			WHERE		ServerName IN (Select SQLName From dbacentral.[dbo].[DBA_ServerInfo] Where active = 'Y')
			) Data
WHERE		RowNumber = 1



SELECT		ServerName
			,DriveLetter
			,DriveSize_MB-ForecastUsed_MB [FreeSpaceMB]

FROM		[dbo].[DMV_DRIVE_FORECAST_DETAIL]
WHERE		DateTimeValue = CAST(CONVERT(VARCHAR(12),GetDate(),101)AS DateTime)
		AND	DriveSize_MB-ForecastUsed_MB < 0
ORDER BY	3


SELECT		ROW_NUMBER() OVER(PARTITION BY ServerName,DriveLetter,DateTimeValue ORDER BY RunDate DESC) RowNumber
			,*
FROM		[dbaperf_reports].[dbo].[DMV_DRIVE_FORECAST_DETAIL]
WHERE		ServerName  Like '%SQLRYL%'

SELECT		*
FROM		(
		SELECT		T3.SQLEnv
				,T1.DateTimeValue
				,[dbaadmin].[dbo].[dbaudf_ConcatenateUnique](T2.ServerName) Servers
				,SUM(T2.DriveSize_MB-ForecastUsed_MB)/POWER(1024,1) [FreeSpaceGB]
		FROM		[dbaadmin].[dbo].[dbaudf_TimeTable] (CAST(CONVERT(VARCHAR(12),GetDate(),101)AS DateTime),CAST(CONVERT(VARCHAR(12),GetDate()+2000,101)AS DateTime),'Month',6) T1
		JOIN		(
					SELECT		ROW_NUMBER() OVER(PARTITION BY ServerName,DriveLetter,DateTimeValue ORDER BY RunDate DESC) RowNumber
								,*
					FROM		[dbo].[DMV_DRIVE_FORECAST_DETAIL]
					) T2
				ON	T1.DateTimeValue = T2.DateTimeValue
		JOIN		[dbacentral].[dbo].[DBA_ServerInfo] T3
				ON	T2.ServerName = T3.SQLName
		WHERE		T3.Active = 'y'
				AND	T2.RowNumber = 1
				AND T2.DriveSize_MB-ForecastUsed_MB <= 0
				AND T3.SQLName NOT IN ('FRETMRTSQL01\A','FRETMRTSQL01\B','FRETMRTSQL02\A','FRETMRTSQL02\B','FREDMRTSQL01\A','FREDMRTSQL01\B','FREDMRTSQL02\A','FREDMRTSQL02\B','','','','')
				AND T3.SQLName Not Like '%SQLRYL%'
		GROUP BY	T3.SQLEnv
				,T1.DateTimeValue
		WITH ROLLUP
		) T1
WHERE		DateTimeValue IS NOT NULL
ORDER BY	1,2


DECLARE		@RunDate	DateTime
		,@StartDate	DateTime
		,@EndDate	DateTime
		,@Interval	SYSNAME
		,@IntervalCount	INT

DECLARE		@Details	TABLE
		(
		SQLEnv		SYSNAME
		,DateTimeValue	DateTime
		,ServerName	SYSNAME
		,FreeSpaceGB	NUMERIC(38,10)
		)

SELECT		@RunDate	= GetDate()
		,@StartDate	= CAST(CONVERT(VARCHAR(12),GetDate()-DAY(GetDate())+1,101)AS DateTime)	-- 1st of Current Month w/o time
		,@EndDate	= DATEADD(year,2,@StartDate)
		,@Interval	= 'Month'
		,@IntervalCount	= 6

INSERT INTO	@Details
SELECT		T3.SQLEnv
		,T1.DateTimeValue
		,T2.ServerName
		,(T2.DriveSize_MB-ForecastUsed_MB)/POWER(1024,1) [FreeSpaceGB]
FROM		[dbaadmin].[dbo].[dbaudf_TimeTable](@StartDate,@EndDate,@Interval,@IntervalCount) T1
LEFT JOIN	(
		SELECT		ROW_NUMBER() OVER(PARTITION BY T1.ServerName,T1.DriveLetter,T1.DateTimeValue ORDER BY T1.RunDate DESC) RowNumber
				,T1.*
		FROM		[dbaperf_reports].[dbo].[DMV_DRIVE_FORECAST_DETAIL] T1
		JOIN		(
				SELECT		ServerName
						,Max(RunDate) RunDate
				FROM		[dbaperf_reports].[dbo].[DMV_DRIVE_FORECAST_DETAIL]
				GROUP BY	ServerName
				) T2
			ON	T1.ServerName	= T2.ServerName
			AND	T1.RunDate	= T2.RunDate
		) T2
	ON	T1.DateTimeValue = T2.DateTimeValue
JOIN		[dbacentral].[dbo].[DBA_ServerInfo] T3
	ON	T2.ServerName = T3.SQLName
WHERE		T3.Active = 'y'
	AND	T2.RowNumber = 1
	AND	T2.DriveSize_MB-ForecastUsed_MB <= 0
	AND	T3.SQLName NOT IN ('FRETMRTSQL01\A','FRETMRTSQL01\B','FRETMRTSQL02\A','FRETMRTSQL02\B','FREDMRTSQL01\A','FREDMRTSQL01\B','FREDMRTSQL02\A','FREDMRTSQL02\B','','','','')
	AND	T3.SQLName Not Like '%SQLRYL%'
ORDER BY	2,1,3

SELECT		* 
FROM		@Details

SELECT		*
FROM		(
		SELECT		SQLEnv
				,DateTimeValue
				,[dbaadmin].[dbo].[dbaudf_ConcatenateUnique](ServerName) Servers
				,SUM(FreeSpaceGB) [FreeSpaceGB]
		FROM		@Details
		GROUP BY	SQLEnv
				,DateTimeValue
		WITH ROLLUP
		) T1
WHERE		DateTimeValue IS NOT NULL
ORDER BY	1,2















SELECT		SQLNAME
		,SQL_Version
		,*
FROM		dbacentral.dbo.ServerInfo
WHERE		Active = 'Y'
	AND	SQLName NOT IN (SELECT DISTINCT ServerName FROM [dbaperf_reports].[dbo].[DMV_DRIVE_FORECAST_DETAIL] WHERE RunDate = '2013-08-09')
	AND	SQL_Version != '2000'
