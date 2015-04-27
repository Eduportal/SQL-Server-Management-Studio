

SELECT		T1.[ServerName]
			,T1.[InstanceID]			
			,T1.[Started]			
			,T1.[Finished]			
			,T2.[Build]			
			,T2.[Application]			
			,T2.[Branch]			
			,T2.[Version]			

			,CASE	WHEN DATEDIFF(minute,T1.[Started],T1.[Finished])	> 60 THEN CAST(DATEDIFF(minute,T1.[Started],T1.[Finished]) AS FLOAT)/60
					WHEN DATEDIFF(second,T1.[Started],T1.[Finished])	> 60 THEN CAST(DATEDIFF(second,T1.[Started],T1.[Finished]) AS FLOAT)/60
					ELSE DATEDIFF(second,T1.[Started],T1.[Finished]) END [Duration]

			,CASE	WHEN DATEDIFF(minute,T1.[Started],T1.[Finished])	> 60 THEN 'Hours'
					WHEN DATEDIFF(second,T1.[Started],T1.[Finished])	> 60 THEN 'Minutes'
					ELSE 'Seconds' END [Duration]

			, CONVERT(VarChar(50),T1.[Started],20) + ' - ' + T2.[Application] + ' ' + T2.[Version] + ' ' + T2.[Branch] + ' ' + T2.[Build] [Prompt]


FROM		(
			SELECT		@@ServerName [ServerName]
						,DEPLInstanceID		[InstanceID]
						,MAX(DB_BuildNum)	[Build]
						,MIN(EventDate)		[Started]
						,MAX(EventDate)		[Finished]
			FROM		[DBAadmin].[dbo].[BuildSchemaChanges]
			WHERE		COALESCE(CAST(DEPLInstanceID AS sysname),'') != ''
			GROUP BY	[DEPLInstanceID]
			) T1
			
LEFT JOIN	(
			SELECT		[DB_BuildNum]		[Build]
						,MAX(DB_BuildApp)	[Application]
						,MAX(DB_BuildBrnch)	[Branch]
						,MAX(VC_Version)	[Version]
			FROM		[DBAadmin].[dbo].[BuildSchemaChanges]
			GROUP BY	[DB_BuildNum]
			)T2
		ON	T1.BUILD = T2.BUILD
			
	