









USE [DBAperf_reports]
GO

SET NOCOUNT ON
GO
DROP TABLE #MostRecentCheck
GO
DROP TABLE #LogSizes
GO
DROP TABLE #CurrentValue
GO
DROP TABLE #FutureValue
GO





SELECT		UPPER(T3.DomainName) [DomainName]
		,T1.ServerName
		,T1.DatabaseName
		,MAX(T1.RunDate) RunDate
INTO		#MostRecentCheck
FROM		[dbo].[DMV_DATABASE_FORECAST_DETAIL] T1

		-- SERVERS ONLY
JOIN		(SELECT '' [ServerName]		UNION ALL
		SELECT 'SEAPLOGSQL01'		UNION ALL
		SELECT 'SEAPLOGSQL01\A'		UNION ALL
		SELECT 'SEAPSQLLSHP01'		UNION ALL
		SELECT 'SEAPSQLLSHP01\SQL2K5'	UNION ALL
		SELECT 'SEAPSQLLSHP01\SQL2012ENT'		
		) T2
	ON	T1.ServerName Like T2.ServerName
		--SPECIFIC SERVER AND DATABASES
--JOIN		(
--		SELECT '' [DatabaseName]		,'' [ServerName]	UNION ALL
--		SELECT 'EditorialSiteDb'		,'EDSQLG0A'		UNION ALL
--		SELECT 'EventServiceDb'			,'EDSQLG0A'		UNION ALL

--		SELECT 'alliant_dtc_work'		,'FREPSQLRYLA01'	UNION ALL
--		SELECT 'Alliant_Feeds'			,'FREPSQLRYLA01'	UNION ALL
--		SELECT 'ContractMaintenanceControl'	,'FREPSQLRYLA01'	UNION ALL
--		SELECT 'getty'				,'FREPSQLRYLA01'	UNION ALL
--		SELECT 'getty_deploy'			,'FREPSQLRYLA01'	UNION ALL
--		SELECT 'Getty_Master'			,'FREPSQLRYLA01'	UNION ALL
--		SELECT 'getty_work_a'			,'FREPSQLRYLA01'	UNION ALL
--		SELECT 'getty_work_b'			,'FREPSQLRYLA01'	UNION ALL
--		SELECT 'reports_work'			,'FREPSQLRYLA01'	UNION ALL
--		SELECT 'rm_integration'			,'FREPSQLRYLA01'	UNION ALL

--		SELECT 'alliant_dist_source'		,'FREPSQLRYLB01'	UNION ALL
--		SELECT 'alliant_dtc_work'		,'FREPSQLRYLB01'	UNION ALL
--		SELECT 'Alliant_feeds'			,'FREPSQLRYLB01'	UNION ALL
--		SELECT 'ContractMaintenanceControl'	,'FREPSQLRYLB01'	UNION ALL
--		SELECT 'getty'				,'FREPSQLRYLB01'	UNION ALL
--		SELECT 'gins'				,'FREPSQLRYLB01'	UNION ALL
--		SELECT 'gins_deploy'			,'FREPSQLRYLB01'	UNION ALL
--		SELECT 'gins_feeds'			,'FREPSQLRYLB01'	UNION ALL
--		SELECT 'gins_integration'		,'FREPSQLRYLB01'	UNION ALL
--		SELECT 'gins_master'			,'FREPSQLRYLB01'	UNION ALL
--		SELECT 'gins_work_a'			,'FREPSQLRYLB01'	UNION ALL
--		SELECT 'gins_work_b'			,'FREPSQLRYLB01'	UNION ALL
--		SELECT 'reports_work'			,'FREPSQLRYLB01'	UNION ALL
--		SELECT 'Subscription'			,'FREPSQLRYLB01'	UNION ALL

--		SELECT 'AdHoc'				,'FREPVARSQL01'		UNION ALL
--		SELECT 'Controller'			,'FREPVARSQL01'		UNION ALL
--		SELECT 'CRM_Funnel_Load'		,'FREPVARSQL01'		UNION ALL
--		SELECT 'CRM_Funnel_Suppression'		,'FREPVARSQL01'		UNION ALL
--		SELECT 'CRM_OPPS_Funnel_Load'		,'FREPVARSQL01'		UNION ALL
--		SELECT 'ImportManager'			,'FREPVARSQL01'		UNION ALL
--		SELECT 'iStockBridge'			,'FREPVARSQL01'		UNION ALL
--		SELECT 'KPI'				,'FREPVARSQL01'		UNION ALL
--		SELECT 'LeadGeneration'			,'FREPVARSQL01'		UNION ALL
--		SELECT 'Lookups'			,'FREPVARSQL01'		UNION ALL
--		SELECT 'Misc_Reports'			,'FREPVARSQL01'		UNION ALL
--		SELECT 'Scheduled_Reports'		,'FREPVARSQL01'		UNION ALL
--		SELECT 'Varicent_Processing'		,'FREPVARSQL01'		UNION ALL

--		SELECT 'WCDS'				,'G1SQLA\A'		UNION ALL
--		SELECT 'WCDSwork'			,'G1SQLA\A'		UNION ALL

--		SELECT 'AssetUsage_Archive'		,'G1SQLB\B'		UNION ALL
--		SELECT 'Product'			,'G1SQLB\B'		UNION ALL
--		SELECT 'RightsPrice'			,'G1SQLB\B'		UNION ALL
				
--		SELECT 'Getty_Images_CRM_GENESYS'	,'SEAPCRMSQL1A'		UNION ALL
--		SELECT 'Getty_Images_US_Inc__MSCRM'	,'SEAPCRMSQL1A'		UNION ALL
--		SELECT 'Getty_Images_US_Inc_Custom'	,'SEAPCRMSQL1A'		UNION ALL
				
--		SELECT 'ContributorSystemsContract'	,'SEAPCTBSQLA'		UNION ALL
				
--		SELECT 'genccadm'			,'SEAPGSYSSQL01'	UNION ALL
--		SELECT 'genccahyp'			,'SEAPGSYSSQL01'	UNION ALL
--		SELECT 'genccaods'			,'SEAPGSYSSQL01'	UNION ALL
--		SELECT 'gencfg'				,'SEAPGSYSSQL01'	UNION ALL
--		SELECT 'genixn'				,'SEAPGSYSSQL01'	UNION ALL
--		SELECT 'genlog'				,'SEAPGSYSSQL01'	UNION ALL
				
--		SELECT 'DeliveryLog'			,'SEAPSCFWSQLA\A'	UNION ALL
				
--		SELECT 'AssetKeyword'			,'SEAPSDTSQLA\A'	UNION ALL
				
--		SELECT 'BP_Reports_Work'		,'SEAPSQLRYLINT02'	UNION ALL
--		SELECT 'BundledProduct'			,'SEAPSQLRYLINT02'	UNION ALL
--		SELECT 'Reports_Work'			,'SEAPSQLRYLINT02'	UNION ALL
--		SELECT 'Subscription'			,'SEAPSQLRYLINT02'	UNION ALL
				
--		SELECT 'DeliveryDb'			,'SQLDISTG0A'		
--		) T2
	--ON	T1.ServerName Like T2.ServerName
	--AND	T1.DatabaseName Like T2.DatabaseName
JOIN		DBACENTRAL.dbo.DBA_ServerInfo T3
	ON	T1.ServerName = T3.SQLName
GROUP BY	T3.DomainName
		,T1.ServerName
		,T1.DatabaseName



SELECT		T1.SQLName [ServerName]
		,T1.DBName [DatabaseName]
		,SUM(T1.Size_MB) [LogSize]
INTO		#LogSizes
FROM		DBACENTRAL.dbo.DBA_DBfileInfo T1
JOIN		#MostRecentCheck T2
	ON	T1.SQLName = T2.ServerName
	AND	T1.DBName = T2.DatabaseName
WHERE		T1.FileType = 'LOG'
GROUP BY	T1.SQLName
		,T1.DBName




SELECT		DomainName
		,[RunDate]
		,[ServerName]
		,[DatabaseName]
		,[DateTimeValue]
		,[Recorded_Smooth]
		,[Forecasted]
		,[Actual]
INTO		#CurrentValue
FROM		(
		SELECT		T2.DomainName
				,T1.[RunDate]
				,T1.[ServerName]
				,T1.[DatabaseName]
				,[DateTimeValue]
				,[Recorded_Smooth]
				,[Forecasted]
				,[Actual]
				,ROW_NUMBER() OVER(PARTITION BY T1.[ServerName],T1.[DatabaseName] ORDER BY [DateTimeValue]) [RowNumber]
		FROM		[dbo].[DMV_DATABASE_FORECAST_DETAIL] T1
		JOIN		#MostRecentCheck T2
			ON	T1.ServerName = T2.ServerName
			AND	T1.DatabaseName = T2.DatabaseName
			AND	T1.RunDate = T2.RunDate
		WHERE		[DateTimeValue] >= GetDate()-1
		) Data
WHERE		[RowNumber] = 1

SELECT		DomainName
		,[RunDate]
		,[ServerName]
		,[DatabaseName]
		,[DateTimeValue]
		,[Recorded_Smooth]
		,[Forecasted]
		,[Actual]
INTO		#FutureValue
FROM		(
		SELECT		T2.DomainName
				,T1.[RunDate]
				,T1.[ServerName]
				,T1.[DatabaseName]
				,[DateTimeValue]
				,[Recorded_Smooth]
				,[Forecasted]
				,[Actual]
				,ROW_NUMBER() OVER(PARTITION BY T1.[ServerName],T1.[DatabaseName] ORDER BY [DateTimeValue] DESC) [RowNumber]
		FROM		[dbo].[DMV_DATABASE_FORECAST_DETAIL] T1
		JOIN		#MostRecentCheck T2
			ON	T1.ServerName = T2.ServerName
			AND	T1.DatabaseName = T2.DatabaseName
			AND	T1.RunDate = T2.RunDate
		WHERE		[DateTimeValue] <= GetDate()+365
		) Data
WHERE		[RowNumber] = 1
	


















--;with		MostRecentCheck
--		AS
--		(
--		SELECT		UPPER(T3.DomainName) [DomainName]
--				,T1.ServerName
--				,T1.DatabaseName
--				,MAX(T1.RunDate) RunDate
--		FROM		[dbo].[DMV_DATABASE_FORECAST_DETAIL] T1
--		JOIN		(
--				SELECT '' [DatabaseName]		,'' [ServerName]	UNION ALL
--				SELECT 'EditorialSiteDb'		,'EDSQLG0A'		UNION ALL
--				SELECT 'EventServiceDb'			,'EDSQLG0A'		UNION ALL

--				SELECT 'alliant_dtc_work'		,'FREPSQLRYLA01'	UNION ALL
--				SELECT 'Alliant_Feeds'			,'FREPSQLRYLA01'	UNION ALL
--				SELECT 'ContractMaintenanceControl'	,'FREPSQLRYLA01'	UNION ALL
--				SELECT 'getty'				,'FREPSQLRYLA01'	UNION ALL
--				SELECT 'getty_deploy'			,'FREPSQLRYLA01'	UNION ALL
--				SELECT 'Getty_Master'			,'FREPSQLRYLA01'	UNION ALL
--				SELECT 'getty_work_a'			,'FREPSQLRYLA01'	UNION ALL
--				SELECT 'getty_work_b'			,'FREPSQLRYLA01'	UNION ALL
--				SELECT 'reports_work'			,'FREPSQLRYLA01'	UNION ALL
--				SELECT 'rm_integration'			,'FREPSQLRYLA01'	UNION ALL

--				SELECT 'alliant_dist_source'		,'FREPSQLRYLB01'	UNION ALL
--				SELECT 'alliant_dtc_work'		,'FREPSQLRYLB01'	UNION ALL
--				SELECT 'Alliant_feeds'			,'FREPSQLRYLB01'	UNION ALL
--				SELECT 'ContractMaintenanceControl'	,'FREPSQLRYLB01'	UNION ALL
--				SELECT 'getty'				,'FREPSQLRYLB01'	UNION ALL
--				SELECT 'gins'				,'FREPSQLRYLB01'	UNION ALL
--				SELECT 'gins_deploy'			,'FREPSQLRYLB01'	UNION ALL
--				SELECT 'gins_feeds'			,'FREPSQLRYLB01'	UNION ALL
--				SELECT 'gins_integration'		,'FREPSQLRYLB01'	UNION ALL
--				SELECT 'gins_master'			,'FREPSQLRYLB01'	UNION ALL
--				SELECT 'gins_work_a'			,'FREPSQLRYLB01'	UNION ALL
--				SELECT 'gins_work_b'			,'FREPSQLRYLB01'	UNION ALL
--				SELECT 'reports_work'			,'FREPSQLRYLB01'	UNION ALL
--				SELECT 'Subscription'			,'FREPSQLRYLB01'	UNION ALL

--				SELECT 'AdHoc'				,'FREPVARSQL01'		UNION ALL
--				SELECT 'Controller'			,'FREPVARSQL01'		UNION ALL
--				SELECT 'CRM_Funnel_Load'		,'FREPVARSQL01'		UNION ALL
--				SELECT 'CRM_Funnel_Suppression'		,'FREPVARSQL01'		UNION ALL
--				SELECT 'CRM_OPPS_Funnel_Load'		,'FREPVARSQL01'		UNION ALL
--				SELECT 'ImportManager'			,'FREPVARSQL01'		UNION ALL
--				SELECT 'iStockBridge'			,'FREPVARSQL01'		UNION ALL
--				SELECT 'KPI'				,'FREPVARSQL01'		UNION ALL
--				SELECT 'LeadGeneration'			,'FREPVARSQL01'		UNION ALL
--				SELECT 'Lookups'			,'FREPVARSQL01'		UNION ALL
--				SELECT 'Misc_Reports'			,'FREPVARSQL01'		UNION ALL
--				SELECT 'Scheduled_Reports'		,'FREPVARSQL01'		UNION ALL
--				SELECT 'Varicent_Processing'		,'FREPVARSQL01'		UNION ALL

--				SELECT 'WCDS'				,'G1SQLA\A'		UNION ALL
--				SELECT 'WCDSwork'			,'G1SQLA\A'		UNION ALL

--				SELECT 'AssetUsage_Archive'		,'G1SQLB\B'		UNION ALL
--				SELECT 'Product'			,'G1SQLB\B'		UNION ALL
--				SELECT 'RightsPrice'			,'G1SQLB\B'		UNION ALL
				
--				SELECT 'Getty_Images_CRM_GENESYS'	,'SEAPCRMSQL1A'		UNION ALL
--				SELECT 'Getty_Images_US_Inc__MSCRM'	,'SEAPCRMSQL1A'		UNION ALL
--				SELECT 'Getty_Images_US_Inc_Custom'	,'SEAPCRMSQL1A'		UNION ALL
				
--				SELECT 'ContributorSystemsContract'	,'SEAPCTBSQLA'		UNION ALL
				
--				SELECT 'genccadm'			,'SEAPGSYSSQL01'	UNION ALL
--				SELECT 'genccahyp'			,'SEAPGSYSSQL01'	UNION ALL
--				SELECT 'genccaods'			,'SEAPGSYSSQL01'	UNION ALL
--				SELECT 'gencfg'				,'SEAPGSYSSQL01'	UNION ALL
--				SELECT 'genixn'				,'SEAPGSYSSQL01'	UNION ALL
--				SELECT 'genlog'				,'SEAPGSYSSQL01'	UNION ALL
				
--				SELECT 'DeliveryLog'			,'SEAPSCFWSQLA\A'	UNION ALL
				
--				SELECT 'AssetKeyword'			,'SEAPSDTSQLA\A'	UNION ALL
				
--				SELECT 'BP_Reports_Work'		,'SEAPSQLRYLINT02'	UNION ALL
--				SELECT 'BundledProduct'			,'SEAPSQLRYLINT02'	UNION ALL
--				SELECT 'Reports_Work'			,'SEAPSQLRYLINT02'	UNION ALL
--				SELECT 'Subscription'			,'SEAPSQLRYLINT02'	UNION ALL
				
--				SELECT 'DeliveryDb'			,'SQLDISTG0A'		
--				) T2
--			ON	T1.ServerName Like T2.ServerName
--			AND	T1.DatabaseName Like T2.DatabaseName
--		JOIN		DBACENTRAL.dbo.DBA_ServerInfo T3
--			ON	T1.ServerName = T3.SQLName
--		GROUP BY	T3.DomainName
--				,T1.ServerName
--				,T1.DatabaseName
--		)
--		--,LogSizes
--		--AS
--		--(
--		SELECT		T1.*
--		FROM		#LogSizes T1
--		JOIN		MostRecentCheck T2
--			ON	T1.ServerName = T2.ServerName
--			AND	T1.DatabaseName = T2.DatabaseName
--		)
--		,CurrentValue
--		AS
--		(
--		SELECT		DomainName
--				,[RunDate]
--				,[ServerName]
--				,[DatabaseName]
--				,[DateTimeValue]
--				,[Recorded_Smooth]
--				,[Forecasted]
--				,[Actual]
--		FROM		(
--				SELECT		T2.DomainName
--						,T1.[RunDate]
--						,T1.[ServerName]
--						,T1.[DatabaseName]
--						,[DateTimeValue]
--						,[Recorded_Smooth]
--						,[Forecasted]
--						,[Actual]
--						,ROW_NUMBER() OVER(PARTITION BY T1.[ServerName],T1.[DatabaseName] ORDER BY [DateTimeValue]) [RowNumber]
--				FROM		[dbo].[DMV_DATABASE_FORECAST_DETAIL] T1
--				JOIN		MostRecentCheck T2
--					ON	T1.ServerName = T2.ServerName
--					AND	T1.DatabaseName = T2.DatabaseName
--					AND	T1.RunDate = T2.RunDate
--				WHERE		[DateTimeValue] >= GetDate()-1
--				) Data
--		WHERE		[RowNumber] = 1
--		)
--		,FutureValue
--		AS
--		(
--		SELECT		DomainName
--				,[RunDate]
--				,[ServerName]
--				,[DatabaseName]
--				,[DateTimeValue]
--				,[Recorded_Smooth]
--				,[Forecasted]
--				,[Actual]
--		FROM		(
--				SELECT		T2.DomainName
--						,T1.[RunDate]
--						,T1.[ServerName]
--						,T1.[DatabaseName]
--						,[DateTimeValue]
--						,[Recorded_Smooth]
--						,[Forecasted]
--						,[Actual]
--						,ROW_NUMBER() OVER(PARTITION BY T1.[ServerName],T1.[DatabaseName] ORDER BY [DateTimeValue] DESC) [RowNumber]
--				FROM		[dbo].[DMV_DATABASE_FORECAST_DETAIL] T1
--				JOIN		MostRecentCheck T2
--					ON	T1.ServerName = T2.ServerName
--					AND	T1.DatabaseName = T2.DatabaseName
--					AND	T1.RunDate = T2.RunDate
--				WHERE		[DateTimeValue] <= GetDate()+365
--				) Data
--		WHERE		[RowNumber] = 1
--		)

SELECT		T1.DomainName
		,T1.ServerName
		,T1.DatabaseName
		,T1.DateTimeValue [CurrentDate]
		,T2.DateTimeValue [FutureDate]
		,DATEDIFF(day,T1.DateTimeValue,T2.DateTimeValue) [DaySpan]
		,T3.LogSize
		,COALESCE(T1.Recorded_Smooth,T1.Forecasted) [CurrentValue]
		,COALESCE(T2.Forecasted,T2.Recorded_Smooth) [FutureValue]

FROM		#CurrentValue T1
JOIN		#FutureValue T2
	ON	T1.ServerName = T2.ServerName
	AND	T1.DatabaseName = T2.DatabaseName
JOIN		#LogSizes T3
	ON	T1.ServerName = T3.ServerName
	AND	T1.DatabaseName = T3.DatabaseName

ORDER BY	1,2,3



SELECT		T1.DomainName
		,T1.ServerName
		,dbaadmin.dbo.dbaudf_FormatBytes(SUM(T3.LogSize),'MB') LogSize
		,dbaadmin.dbo.dbaudf_FormatBytes(SUM(COALESCE(T1.Recorded_Smooth,T1.Forecasted)),'MB') [CurrentValue]
		,dbaadmin.dbo.dbaudf_FormatBytes(SUM(COALESCE(T2.Forecasted,T2.Recorded_Smooth)),'MB') [FutureValue]

FROM		#CurrentValue T1
JOIN		#FutureValue T2
	ON	T1.ServerName = T2.ServerName
	AND	T1.DatabaseName = T2.DatabaseName
JOIN		#LogSizes T3
	ON	T1.ServerName = T3.ServerName
	AND	T1.DatabaseName = T3.DatabaseName
GROUP BY	T1.DomainName
		,T1.ServerName
ORDER BY	1,2

