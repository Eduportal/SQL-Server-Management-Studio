DECLARE @RC int
EXECUTE @RC = [DBAperf_reports].[dbo].[dbasp_DiskSpaceChecks_Import] 
GO


;WITH		DriveData AS
		(
		SELECT		[DriveType]
				,[SQLName]
				,SUM([Dive_GB])					[Dive_GB]
				,SUM([Free_GB])					[Free_GB]
				,SUM([Used_GB])					[Used_GB]
				,SUM([OneYearForcastGrowthGB])			[OneYearForcastGrowthGB]
				,SUM([Used_GB])+SUM([OneYearForcastGrowthGB])	[OneYearForcastSizeGB]
		FROM		(
				SELECT		[SQLName]
						,[CheckDate]
						,[DriveLetter]
						,[DriveType]
						,[FileType]
						,[Dive_MB] / 1000 [Dive_GB]
						,[Free_MB] / 1000 [Free_GB]
						,[Used_MB] / 1000 [Used_GB]
						,COALESCE([OneYearForcastGrowthMB],0) / 1000 [OneYearForcastGrowthGB]
				FROM		[DBAperf_reports].[dbo].[DMV_DiskSpaceUsage]
				WHERE		[FileType] IN ('Data','Both')
					--AND	[OneYearForcastGrowthMB] IS NOT NULL
				)  Data

		GROUP BY	[DriveType],[SQLName]	
		) 

SELECT		T2.SQLEnv
		,T1.*
		,CASE
			WHEN (((([Used_GB])*100)/80) - [Dive_GB]) < 0 
			THEN 0 
			ELSE (((([Used_GB])*100)/80) - [Dive_GB]) 
			END 							[CurrentSpaceNeededGB]
		,(((([Used_GB]+[OneYearForcastGrowthGB])*100)/80) - [Dive_GB])	[ForecastSpaceNeededGB]
FROM		DriveData T1
LEFT JOIN	dbacentral.dbo.DBA_ServerInfo T2
	ON	T1.[SQLName] = T2.[SQLName]
WHERE		(((([Used_GB]+COALESCE([OneYearForcastGrowthGB],0))*100)/80) - [Dive_GB]) > 0	
ORDER BY	1,2,3
GO
