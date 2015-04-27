DELETE		T1
FROM		[dbaperf_reports].[dbo].[DMV_DRIVE_FORECAST_DETAIL] T1
JOIN		(
		SELECT		ServerName
				,Max(RunDate) RunDate
		FROM		[dbaperf_reports].[dbo].[DMV_DRIVE_FORECAST_DETAIL]
		GROUP BY	ServerName
		) T2
	ON	T1.ServerName	=  T2.ServerName
	AND	T1.RunDate	!= T2.RunDate





DELETE		T1
FROM		[dbaperf_reports].[dbo].[DMV_DRIVE_FORECAST_SUMMARY] T1
JOIN		(
		SELECT		ServerName
				,Max(RunDate) RunDate
		FROM		[dbaperf_reports].[dbo].[DMV_DRIVE_FORECAST_SUMMARY]
		GROUP BY	ServerName
		) T2
	ON	T1.ServerName	=  T2.ServerName
	AND	T1.RunDate	!= T2.RunDate





DELETE		T1
FROM		[dbaperf_reports].[dbo].[DMV_DATABASE_FORECAST_DETAIL] T1
JOIN		(
		SELECT		ServerName
				,Max(RunDate) RunDate
		FROM		[dbaperf_reports].[dbo].[DMV_DATABASE_FORECAST_DETAIL]
		GROUP BY	ServerName
		) T2
	ON	T1.ServerName	=  T2.ServerName
	AND	T1.RunDate	!= T2.RunDate




DELETE		T1
FROM		[dbaperf_reports].[dbo].[DMV_DATABASE_FORECAST_SUMMARY] T1
JOIN		(
		SELECT		ServerName
				,Max(RunDate) RunDate
		FROM		[dbaperf_reports].[dbo].[DMV_DATABASE_FORECAST_SUMMARY]
		GROUP BY	ServerName
		) T2
	ON	T1.ServerName	=  T2.ServerName
	AND	T1.RunDate	!= T2.RunDate