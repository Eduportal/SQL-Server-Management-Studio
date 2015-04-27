-- Do not lock anything, and do not get held up by any locks. 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

;WITH		DriveData
			AS
			(
			SELECT [SQLName]
				  ,REPLACE([Unit],'DRIVE_','') AS [Drive]
				  ,[Period]
				  ,DATEADD(week,CAST(REPLACE([Period],LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'-','') AS INT)-1,DATEADD(day,(DATEPART(weekday,CAST(LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'0101' AS DateTime))-1)*(-1),CAST(LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'0101' AS DateTime))) AS [Time]
				  ,COALESCE([Forecast],0) AS [Value]
				  ,[LimitDataSizeMB] AS [MAX]
			FROM	[DBAperf_reports].[dbo].[DMV_DiskSpaceForecast]
			WHERE	COALESCE(CAST([Forecast] AS INT),0) != 0
				--AND	LEFT([SQLName],CHARINDEX('\',[SQLName]+'\')-1) = LEFT(@ServerName,CHARINDEX('\',@ServerName+'\')-1)
			)
			,DrivesInDanger
			AS
			(
			SELECT [SQLName]
				  ,REPLACE([Unit],'DRIVE_','') AS [Drive]
				  ,MIN([Period]) [Period]
				  ,MIN(DATEADD(week,CAST(REPLACE([Period],LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'-','') AS INT)-1,DATEADD(day,(DATEPART(weekday,CAST(LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'0101' AS DateTime))-1)*(-1),CAST(LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'0101' AS DateTime)))) AS [Time]
			FROM	[DBAperf_reports].[dbo].[DMV_DiskSpaceForecast]
			WHERE	COALESCE(CAST([Forecast] AS INT),0) != 0
				AND COALESCE(CAST([Forecast] AS INT),0) >= CAST([LimitDataSizeMB] AS INT)
				--AND	LEFT([SQLName],CHARINDEX('\',[SQLName]+'\')-1) = LEFT(@ServerName,CHARINDEX('\',@ServerName+'\')-1)
			GROUP BY	[SQLName]
						,REPLACE([Unit],'DRIVE_','')
			)
SELECT		DriveData.SQLName
			,DriveData.Drive
			,DATEDIFF(Week,getdate(),DrivesInDanger.Time) [WeeksTillFull]
			,DriveData.Time
			,CAST(REPLACE([dbaadmin].[dbo].[dbaudf_FormatNumber] (DriveData.Value/1024.0,0,2),',','')AS FLOAT) [Value]
			,CAST(REPLACE([dbaadmin].[dbo].[dbaudf_FormatNumber] (DriveData.MAX/1024.0,0,2),',','')AS FLOAT) [Max]
			,CASE WHEN DriveData.Period = DrivesInDanger.Period THEN CAST(REPLACE([dbaadmin].[dbo].[dbaudf_FormatNumber] (DriveData.MAX/1024.0,0,2),',','')AS FLOAT) ELSE 0 END AS TOF
FROM		DriveData
JOIN		DrivesInDanger
		ON	DrivesInDanger.SQLName	= DriveData.SQLName
		AND	DrivesInDanger.Drive	= DriveData.Drive