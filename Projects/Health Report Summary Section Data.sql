-- Do not lock anything, and do not get held up by any locks. 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


;With		Parents
			AS
			(
			SELECT		DB.ConnectionString_B87E82BC_1A85_4DE3_330A_13133CF5F9C3 [SQLName]
						,R.SourceEntityId	[ManagedEntityID]
						,R.TargetEntityId	[ChildEntityID]
			FROM		SEAPSCOMSQLA.OperationsManager.dbo.Relationship R WITH(NOLOCK)
			JOIN		SEAPSCOMSQLA.OperationsManager.dbo.MT_DBEngine DB WITH(NOLOCK)
					ON	DB.BaseManagedEntityId = R.SourceEntityId
			UNION ALL
			SELECT		DB.[SQLName]
						,R.SourceEntityId	[ManagedEntityID]
						,R.TargetEntityId	[ChildEntityID]
			FROM		SEAPSCOMSQLA.OperationsManager.dbo.Relationship R WITH(NOLOCK)
			JOIN		Parents DB
					ON	DB.ChildEntityID = R.SourceEntityId
			)
			,EntityList
			AS
			(
			SELECT		[SQLName]
						,[ManagedEntityID]
			FROM		Parents					
			UNION
			SELECT		[SQLName]
						,[ChildEntityID]
			FROM		Parents							
			)
			,ScomAlertSummary
			AS
			(
			SELECT		E.SQLName
						,MAX(A.Severity)	[Severity]
						,COUNT(*)			[OpenAlerts]		
			FROM		SEAPSCOMSQLA.OperationsManager.dbo.Alert A
			JOIN		EntityList E 
					ON	A.BaseManagedEntityId = E.ManagedEntityId
			WHERE		ResolutionState !=255
					AND	Category !='EventCollection'
			GROUP BY	SQLName		
			)
			,DriveData
			AS
			(
			SELECT		UPPER([SQLName]) [SQLName]
						--,dbacentral.dbo.dbaudf_GetServerClass(SQLName) [ServerClass]
						,REPLACE([Unit],'DRIVE_','') AS [Drive]
						,[Period]
						,DATEADD(week,CAST(REPLACE([Period],LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'-','') AS INT)-1,DATEADD(day,(DATEPART(weekday,CAST(LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'0101' AS DateTime))-1)*(-1),CAST(LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'0101' AS DateTime))) AS [Time]
						,COALESCE([Forecast],0) AS [Value]
						,[LimitDataSizeMB] AS [MAX]
			FROM		[DBAperf_reports].[dbo].[DMV_DiskSpaceForecast]
			WHERE		COALESCE(CAST([Forecast] AS INT),0) != 0
			)
			,DrivesInDanger
			AS
			(
			SELECT		UPPER([SQLName]) [SQLName]
						,REPLACE([Unit],'DRIVE_','') AS [Drive]
						,MIN([Period]) [Period]
						,MIN(DATEADD(week,CAST(REPLACE([Period],LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'-','') AS INT)-1,DATEADD(day,(DATEPART(weekday,CAST(LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'0101' AS DateTime))-1)*(-1),CAST(LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'0101' AS DateTime)))) AS [Time]
			FROM		[DBAperf_reports].[dbo].[DMV_DiskSpaceForecast]
			WHERE		COALESCE(CAST([Forecast] AS INT),0) != 0
					AND COALESCE(CAST([Forecast] AS INT),0) >= CAST([LimitDataSizeMB] AS INT)
			GROUP BY	[SQLName]
						,REPLACE([Unit],'DRIVE_','')
			)
			,DriveAlertSummary
			AS
			(
			SELECT		DriveData.SQLName
						,MIN(CASE WHEN COALESCE(DATEDIFF(Week,getdate(),DrivesInDanger.Time),999) < 13 THEN 0 ELSE 1 END) AS CheckDriveSpace
			FROM		DriveData
			LEFT JOIN	DrivesInDanger
					ON	DrivesInDanger.SQLName	= DriveData.SQLName
					AND	DrivesInDanger.Drive	= DriveData.Drive
			--WHERE		[ServerClass] = 'high'
			GROUP BY	DriveData.SQLName
			)
SELECT		T1.SQLName
			,CASE WHEN DATEDIFF(day,Check_Date,GETDATE()) > 1 THEN 0 ELSE 1 END AS HealthDate
			,CASE WHEN [Health_Status] Like '%All Health Checks Pass%' THEN 1 ELSE 0 END AS HealthStatus
			,ReportLink
			,CASE WHEN BuildNumber != MostRecentBuildNumber THEN 2 ELSE 1 END AS SQLBuild
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
			,T3.CheckDriveSpace DriveSpaceCheck
			,CASE COALESCE(T2.Severity,0) WHEN 2 THEN 0 WHEN 1 THEN 2 ELSE 1 END AS OpenScomAlerts
			,COALESCE(T2.OpenAlerts,0) AS OpenScomAlertCount
FROM		dbacentral.dbo.HotServerHealthData T1
LEFT JOIN	ScomAlertSummary T2
		ON	T2.SQLName = T1.SQLName
LEFT JOIN	DriveAlertSummary T3
		ON	T3.SQLName = T1.SQLName					