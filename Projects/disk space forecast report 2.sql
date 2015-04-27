;WITH		DriveData
		AS
		(		
		SELECT		[SQLName]
					,REPLACE([Unit],'DRIVE_','') AS [Drive]
					,[Period]
					,DATEADD(week,CAST(REPLACE([Period],LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'-','') AS INT)-1,DATEADD(day,(DATEPART(weekday,CAST(LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'0101' AS DateTime))-1)*(-1),CAST(LEFT([Period],CHARINDEX('-',[Period]+'-')-1)+'0101' AS DateTime))) AS [Time]
					,COALESCE([Forecast],0) AS [Value]
					,[LimitDataSizeMB] AS [MAX]
		FROM		[DBAperf_reports].[dbo].[DMV_DiskSpaceForecast]
		--WHERE		COALESCE(CAST([Forecast] AS INT),0) != 0	
		)
		,MF
		AS
		(
		SELECT		RANK() OVER(PARTITION BY [SQLName],[Drive] ORDER BY [Time] Desc) [Rank]
					,*
		FROM		DriveData
		WHERE		Time > GETDATE()				
		)
		,FU
		AS
		(
		SELECT		RANK() OVER(PARTITION BY [SQLName],[Drive] ORDER BY [Time]) [Rank]
					,*
		FROM		DriveData
		WHERE		[Value] >= [MAX]
				AND	Time > GETDATE()	
		)
		,ReportData
		AS
		(
		SELECT		CAST(MF.SQLName AS VarChar(25))						SQLName
					,CAST(MF.Drive AS Char(1))						Drive
					,CAST(dbaadmin.dbo.dbaudf_FormatNumber(MF.MAX/1024,8,2) AS CHAR(8))	CUR_Limit
					,CONVERT(VarChar(20),MF.Time,101)					MAX_ForecastDate
					,CAST(dbaadmin.dbo.dbaudf_FormatNumber(MF.Value/1024,8,2) AS CHAR(8))	MAX_ForecastSize
					,CAST(ISNULL(DATEDIFF(week,GETDATE(),FU.Time),99) AS CHAR(2))		WeeksTillFull
					,CONVERT(VarChar(20),FU.Time,101)					Full_ForecastDate
					,CAST(dbaadmin.dbo.dbaudf_FormatNumber(FU.Value/1024,8,2) AS CHAR(8))	FULL_ForecastSize
		FROM		MF
		LEFT JOIN	FU
				ON	MF.SQLName = FU.SQLName
				AND	MF.Drive = FU.Drive
				AND	MF.[Rank] = FU.[Rank]
		WHERE		MF.[Rank] = 1
		)

SELECT		CAST(dbacentral.dbo.dbaudf_GetServerClass(SI.SQLName) AS VarChar(10)) ServerClass
			,CAST(SI.SQLEnv AS VarChar(15)) [Env]
			,CAST(SI.DomainName AS VarChar(10)) [DomainName]
			,CAST(SI.SQLName AS VarChar(25)) [SQLName]
			,RD.Drive
			,RD.CUR_Limit
			,RD.MAX_ForecastDate
			,RD.MAX_ForecastSize
			,RD.WeeksTillFull
			,RD.Full_ForecastDate
			,RD.FULL_ForecastSize		
		
		
FROM		dbacentral.dbo.DBA_ServerInfo SI
LEFT JOIN	ReportData RD
		ON	SI.SQLName = RD.SQLName
WHERE		SI.SQLEnv = 'Production'
		AND	SI.Active = 'Y'
		--AND	RD.SQLName IS NULL
		AND	RD.WeeksTillFull < 99
ORDER BY	1,3 desc,4,5	
			
		
--SELECT		CAST(dbacentral.dbo.dbaudf_GetServerClass(SI.SQLName) AS VarChar(10)) ServerClass
--			,CAST(SI.SQLEnv AS VarChar(15)) [Env]
--			,CAST(SI.SQLName AS VarChar(25)) [SQLName]	
--			,RD.Drive
--			,RD.CUR_Limit
--			,RD.MAX_ForecastDate
--			,RD.MAX_ForecastSize
--			,RD.WeeksTillFull
--			,RD.Full_ForecastDate
--			,RD.FULL_ForecastSize
				
--FROM		dbacentral.dbo.DBA_ServerInfo SI
--LEFT JOIN	ReportData RD
--		ON	SI.SQLName = RD.SQLName
--WHERE		SI.SQLEnv = 'Production'	
--ORDER BY	CAST(isnull(RD.WeeksTillFull,99) AS INT),SQLName,Drive
