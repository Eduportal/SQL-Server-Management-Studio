-- Do not lock anything, and do not get held up by any locks. 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

;WITH		DriveFullDates
			AS
			(
			SELECT	[SQLName]
					,REPLACE([Unit],'DRIVE_','') AS [Drive]
					,DATEDIFF(WEEK,GETDATE()
						,MIN(DATEADD(week,CAST(REPLACE([Period],LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'-','') AS INT)-1,DATEADD(day,(DATEPART(weekday,CAST(LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'0101' AS DateTime))-1)*(-1),CAST(LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'0101' AS DateTime))))) AS [WeeksTillFull]
					,MIN(DATEADD(week,CAST(REPLACE([Period],LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'-','') AS INT)-1,DATEADD(day,(DATEPART(weekday,CAST(LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'0101' AS DateTime))-1)*(-1),CAST(LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'0101' AS DateTime)))) AS [DateFull]
			FROM	[DBAperf_reports].[dbo].[DMV_DiskSpaceForecast]
			WHERE	COALESCE(CAST([Forecast]/1024 AS INT),0) != 0
				AND COALESCE(CAST([Forecast]/1024 AS INT),0) >= CAST([LimitDataSizeMB]/1024 AS INT)
			GROUP BY	[SQLName]
						,REPLACE([Unit],'DRIVE_','')
			)
SELECT		T1.SQLName
			,CASE WHEN DATEDIFF(day,Check_Date,GETDATE()) > 1 THEN 0 ELSE 1 END AS HealthDate
			,CASE WHEN [Health_Status] Like '%All Health Checks Pass%' THEN 1 ELSE 0 END AS HealthStatus
			,ReportLink
			,CAST(PARSENAME(BuildNumber,4)+'.'+PARSENAME(BuildNumber,3) AS FLOAT)
			,CAST(PARSENAME(BuildNumber,2)+'.'+PARSENAME(BuildNumber,1) AS FLOAT)
			,DENSE_RANK() OVER (PARTITION BY CAST(PARSENAME(BuildNumber,4)+'.'+PARSENAME(BuildNumber,3) AS FLOAT) order by CAST(PARSENAME(BuildNumber,2)+'.'+PARSENAME(BuildNumber,1) AS FLOAT) DESC)
			,CASE WHEN MostRecentBuildNumber != BuildNumber THEN 0 ELSE 1 END AS SQLBuild
			,URL AS SQLUpgradeInfo
			,CASE WHEN DaysSinceRestart >= 100 THEN 0 ELSE 1 END RestartDays
			,CASE WHEN DaysSinceRebooted >= 100 THEN 0 ELSE 1 END RebootDays
			,CASE WHEN dbaadmin_Version	!= dbaadmin_GoldVersion	THEN 0 ELSE 1 END AS DBAAdminVersion
			,CASE WHEN dbaperf_Version	!= dbaperf_GoldVersion	THEN 0 ELSE 1 END AS DBAPerfVersion	
			,CASE WHEN DEPLinfo_Version	!= deplinfo_GoldVersion	THEN 0 ELSE 1 END AS DEPLinfoVersion
			,CASE WHEN dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(AntiVirus_type,')',''),'(',' '),' ','|'),1) = 'na' THEN 0 ELSE 1 END AS AVInstalled
			,CASE WHEN dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(AntiVirus_type,')',''),'(',' '),' ','|'),1) = 'na' THEN 2  
				  WHEN DENSE_RANK() OVER (order by CAST(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(AntiVirus_type,')',''),'(',' '),' ','|'),3) AS FLOAT) DESC) > 1 THEN 0 ELSE 1 END AS CheckEngineVersion
			,CASE WHEN dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(AntiVirus_type,')',''),'(',' '),' ','|'),1) = 'na' THEN 2  
				  WHEN DENSE_RANK() OVER (order by CAST(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(AntiVirus_type,')',''),'(',' '),' ','|'),5) AS FLOAT) DESC) > 1 THEN 0 ELSE 1 END AS CheckAVDatVersion
			,CASE WHEN dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(AntiVirus_type,')',''),'(',' '),' ','|'),1) = 'na' THEN 2  
				  WHEN AntiVirus_Excludes != 'y' THEN 0 ELSE 1 END AS CheckAVExcludes
			,CASE WHEN EXISTS (SELECT 1 FROM DriveFullDates WHERE SQLName = T1.SQLName AND WeeksTillFull < 10 AND WeeksTillFull > 0) THEN 0 ELSE 1 END AS DriveSpaceCheck
FROM		dbacentral.dbo.HotServerHealthData T1

		


