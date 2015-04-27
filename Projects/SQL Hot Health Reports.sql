;WITH		LastCheckIn
			AS
			(
			SELECT		SQLname
						,MAX(CAST(CONVERT(VARCHAR(12),check_date,101)AS DATETIME)) AS last_date
			FROM		[dbacentral].[dbo].[SQLHealth_Central]
			GROUP BY	SQLname
			)
SELECT		SQLName
			,ServerName
			,Domain
			,EnvName
			,Check_Date
			,REPLACE(dbaadmin.dbo.dbaudf_Concatenate(Subject01+ISNULL('('+NULLIF(Value01,' ')+') ',' ')+ISNULL(NULLIF(Notes01,' '),'')+CHAR(13)+CHAR(10)),CHAR(13)+CHAR(10)+',',CHAR(13)+CHAR(10)) [Health_Status]
			,Apps
			,DBs
			,'file://'+[ServerName]+'/'+REPLACE([SQLName],'\','$')+'_dbasql/dba_reports/SQLHealthReport_'+REPLACE([SQLName],'\','$')+'.txt' [ReportLink]
FROM		(


			SELECT		SL.[SQLname]
						,SL.[ServerName]
						,SHC.[Domain]
						,SHC.[ENVname]
						,SHC.[Subject01]
						,SHC.[Value01]
						,SHC.[Notes01]
						,SHC.[Grade01]
						,CAST(CONVERT(VARCHAR(12),SHC.check_date,101)AS DATETIME) [Check_date]
						,SL.[Apps]
						,SL.[DBs]
			FROM		[dbacentral].[dbo].[SQLHealth_Central] SHC
			JOIN		LastCheckIn
					ON	SHC.[SQLname] = LastCheckIn.[SQLname]
					AND	CAST(CONVERT(VARCHAR(12),SHC.[Check_date],101)AS DATETIME) = LastCheckIn.last_date
			JOIN		(
						SELECT		UPPER(SI.[SQLName])																			[SQLName]
									,UPPER(SI.[ServerName])																		[ServerName]
									,MAX(UPPER(COALESCE(SI.SQLEnv,'--')))														[SQLEnv]
									,MAX(UPPER(COALESCE(SI.DomainName,'--')))													[DomainName]
									,LTRIM((
												SELECT		dbaadmin.dbo.dbaudf_Concatenate(' '+ExtractedText)
												FROM		(
															SELECT		DISTINCT TOP 100 PERCENT
																		LTRIM(RTRIM(ExtractedText)) [ExtractedText]
															FROM		[DBAcentral].dbo.dbaudf_StringToTable(UPPER(isnull(NULLIF(dbaadmin.dbo.dbaudf_Concatenate(REPLACE(REPLACE(DI.[Appl_desc],'(',','),')',',')),''),'OTHER')),',')
															WHERE		nullif(ExtractedText,'') IS NOT NULL ORDER BY 1) Data
															))			[Apps]
									,LTRIM((
												SELECT		dbaadmin.dbo.dbaudf_Concatenate(' '+ExtractedText)
												FROM		(
															SELECT		DISTINCT TOP 100 PERCENT
																		LTRIM(RTRIM(ExtractedText)) [ExtractedText]
															FROM		[DBAcentral].dbo.dbaudf_StringToTable(dbaadmin.dbo.dbaudf_Concatenate(UPPER(DI.[DBName])),',')
															WHERE		nullif(ExtractedText,'') IS NOT NULL ORDER BY 1) Data
															))			[DBs]
						FROM		[DBAcentral].[dbo].[DBA_ServerInfo] SI
						LEFT JOIN	[DBAcentral].[dbo].[DBA_DBInfo] DI
							ON		SI.SQLName = DI.SQLName
						WHERE		dbacentral.[dbo].[dbaudf_GetServerClass] (SI.[SQLName]) = 'High' 
						GROUP BY	SI.[SQLName],SI.[ServerName]
						) SL
					ON	SL.SQLname = SHC.[SQLname]
			) Data
GROUP BY	SQLName
			,ServerName
			,Domain
			,EnvName
			,Check_Date
			,Apps
			,DBs
ORDER BY	2,1			