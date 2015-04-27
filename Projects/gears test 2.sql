

ALTER VIEW	[dbo].[DBA_Dashboard_TicketDetails_Gears]
AS
WITH		Team_tbl_users
AS		(
		SELECT		id
				,name
				,fname
				,lname
				,uid
				,email
				,CASE	WHEN ID IN (3529,7519,833,1474,6542,7368,7075,7255) THEN 'DBA'
					WHEN ID IN (3532,1626,1988,6611,6838,6384) THEN 'WEB'
					ELSE '' END AS TS_Team
		FROM		dbo.tbl_users
		WHERE		ID IN (3529,7519,833,1474,6542,7368,7075,7255,3532,1626,1988,6611,6838,6384)
		)
		,Team_EMP_RESOURCE
AS		(
		SELECT		DISTINCT
				[emp_resource_id]
				,[first_name]
				,[last_name]
				,[login]
				,[password]
				,[email_address]
				,T2.TS_Team
		FROM		[gears].[dbo].[EMP_RESOURCE] T1
		LEFT JOIN	Team_tbl_users T2	
			ON	T1.email_address = T2.email
			OR	(
				T1.first_name = T2.fname
				AND
				T1.last_name = T2.lname
				)
			OR	T1.login = T2.uid
		)
		,TicketNotes
AS		(
		SELECT		build_request_id
				,min(notes_date) min_date
				,max(notes_date) max_date
				,max(CASE WHEN T2.TS_Team = 'DBA' THEN 1 ELSE 0 END) AS [TS_DBA_Notes]
				,max(CASE WHEN T2.TS_Team = 'WEB' THEN 1 ELSE 0 END) AS [TS_WEB_Notes]
				,dbaadmin.dbo.dbaudf_Concatenate(T2.first_name + ' ' + T2.last_name + '(' + T2.[email_address] + ') ' + CAST(T1.engineer_notes AS VarChar(500))+'... ' + CHAR(13) + CHAR(10)) Notes
		FROM		[GEARS].dbo.ENGINEER_NOTES T1
		LEFT JOIN	Team_EMP_RESOURCE T2
			ON	T1.user_id = T2.[emp_resource_id]
		GROUP BY	build_request_id
		)
		,Components
AS		(
		SELECT		build_request_id
				,LEFT([Components],LEN([Components])-1)			AS [Components]
				,LEFT([Types],LEN([Types])-1)				AS [Types]
				,CASE WHEN [Types] like '%DB%' THEN 1 ELSE 0 END	AS [TS_DBA_Comps]
				,CASE WHEN [Types] like '%WEB%' THEN 1 ELSE 0 END	AS [TS_WEB_Comps]
		FROM		(
				SELECT		T1.build_request_id
						,dbaadmin.dbo.ConcatenateUnique(COALESCE(T3.component_name,'none')+',') AS [Components]
						,dbaadmin.dbo.ConcatenateUnique(COALESCE(LTRIM(RTRIM(CAST(T4.component_type AS VarChar(4)))),'none')+',') AS [Types]
						
				FROM		[gears].[dbo].[BUILD_REQUESTS] T1 WITH(NOLOCK) 
				LEFT JOIN	gears.dbo.BUILD_REQUEST_COMPONENTS T2
					ON	T2.build_request_id = T1.build_request_id 
				LEFT JOIN	gears.dbo.COMPONENTS T3
					ON	T3.component_id = T2.component_id
				LEFT JOIN	[gears].[dbo].[COMPONENT_TYPE] T4
					ON	T4.[component_type_id] = T3.[component_type_id]	
				GROUP BY	T1.build_request_id
				) Components
		)		
		
Select		T1.[build_request_id]				AS [Ticket]
		,T1.requestor					AS [Sender]
		,T1.email					AS [Sender EMAIL]
		,T1.priority					AS [Priority]
		,T2.environment_name 
			+ ' ' + project_name 
			+ ' (' + project_version + ')'		AS [Subject]
		,CASE
			WHEN COALESCE(T6.[Status],T1.[Status],'') 
				like '%complete%'
			THEN 'Complete'
			WHEN COALESCE(T6.[Status],T1.[Status],'')
				like '%work%'
			THEN 'In Work'
			WHEN COALESCE(T6.[Status],T1.[Status],'')
				like '%cancel%'
			THEN 'Canceled'
			ELSE COALESCE(T6.[Status],T1.[Status],'')
			END					AS [Status]
		,T2.environment_name				AS [Environment]
		,project_name					AS [Project]
		,project_version				AS [Version]
		,T7.[Components]				AS [Components]
		,T7.[Types]					AS [ComponentTypes]
		,Convert(VarChar(10),[target_date],120)+' '
			+RIGHT('00'+CAST(CASE WHEN RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([target_time],'|'),1),2) > 23 THEN '00'
			  ELSE RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([target_time],'|'),1),2) END
			  + CASE
			    WHEN RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([target_time],'|'),1),2) BETWEEN 1 and 11
				AND [target_time] LIKE '%pm%' THEN 12 ELSE 0 END AS varCHAR(2)),2) +':'
			+CASE WHEN RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([target_time],'|'),2),2) > 59 THEN '00'
			  ELSE RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([target_time],'|'),2),2) END +':'
			+CASE WHEN RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([target_time],'|'),3),2) > 59 THEN '00'
			  ELSE RIGHT('00'+[dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[Filter_OnlyNumeric]([target_time],'|'),3),2) END AS [Start Time]
		,T1.request_date				AS [Date Received]
		,CASE	WHEN COALESCE(T6.[Status],T1.[Status],'') like '%complete%'
			THEN COALESCE(T6.ModDate,[dbaadmin].[dbo].[fn_max_datetime](T5.[max_date],T1.request_date))
			ELSE NULL
			END					AS [Date Complete]
		,[dbaadmin].[dbo].[fn_max_datetime] 
			(
			COALESCE(T6.[ModDate],T1.request_date)
			,COALESCE(T5.[max_date],T1.request_date)
			)					AS [Date Updated] 
		,COALESCE([DBAapproved],'n')			AS [DBAapproved]
		,COALESCE([DBAapprover],'')			AS [DBAapprover]
		,CASE	WHEN T6.[Gears_id] IS NULL 
			THEN 'N' 
			ELSE 'Y' 
			END					AS [InDC]
		,CAST(T1.Notes AS VarChar(max)) 
			+ CHAR(13) + CHAR(10)
			+ T5.[Notes]				AS [Notes]
			
		,COALESCE(T5.[TS_DBA_Notes],0)			AS [TS_DBA_Notes]
		,CASE WHEN T4.TS_Team = 'DBA' THEN 1 ELSE 0 END AS [TS_DBA_Create]
		,CASE	WHEN T6.[Gears_id] IS NULL 
			THEN 0 
			ELSE 1 
			END					AS [TS_DBA_Assign]
		,T7.[TS_DBA_Comps]				AS [TS_DBA_Comps]
		,COALESCE(T5.[TS_WEB_Notes],0)			AS [TS_WEB_Notes]
		,CASE WHEN T4.TS_Team = 'WEB' THEN 1 ELSE 0 END AS [TS_WEB_Create]
		,T7.[TS_WEB_Comps]				AS [TS_WEB_Comps]
FROM		[gears].[dbo].[BUILD_REQUESTS] T1 WITH(NOLOCK) 
JOIN		[gears].dbo.ENVIRONMENT T2  WITH(NOLOCK)
	ON	T1.[environment_id] = T2.[environment_id]
JOIN		[gears].dbo.PROJECTS T3 WITH(NOLOCK)
	ON	T1.project_id = T3.Project_id
LEFT JOIN	Team_tbl_users T4
	ON	T4.email = T1.email
	OR	T4.name = T1.requestor

LEFT JOIN	TicketNotes T5
	ON	T5.build_request_id = T1.build_request_id
	
LEFT JOIN	[DEPLcontrol].[dbo].[Request] T6
	ON	T6.[Gears_id] = T1.[build_request_id]
	
LEFT JOIN	Components T7
	ON	T7.[build_request_id] = T1.[build_request_id]
GO



ALTER VIEW	DBA_Dashboard_Chart_GTicketCounts
AS
SELECT		[TicketDate]			[Date]
		, SUM([TS_DBA_Critical])	[DBA_Critical]
		, SUM([TS_DBA_Standard])	[DBA_Standard]
		, SUM([TS_DBA_Low])		[DBA_Low]
		, SUM([TS_DBA_Critical])+SUM([TS_DBA_Standard])+SUM([TS_DBA_Low]) [DBA]
		, CAST(SUM([TS_DBA_Critical]) AS VarChar(10))+'-'+CAST(SUM([TS_DBA_Standard]) AS VarChar(10))+'-'+CAST(SUM([TS_DBA_Low]) AS VarChar(10)) [DBA_Lab]
		, SUM([TS_WEB_Critical])	[WEB_Critical]
		, SUM([TS_WEB_Standard])	[WEB_Standard]
		, SUM([TS_WEB_Low])		[WEB_Low]
		, SUM([TS_WEB_Critical])+SUM([TS_WEB_Standard])+SUM([TS_WEB_Low]) [WEB]
		, CAST(SUM([TS_WEB_Critical]) AS VarChar(10))+'-'+CAST(SUM([TS_WEB_Standard]) AS VarChar(10))+'-'+CAST(SUM([TS_WEB_Low]) AS VarChar(10)) [WEB_Lab]
FROM		(		
		SELECT		CAST( DATEPART(year,[Date Received])AS VarChar(4)) + '-' + RIGHT('00'+CAST(DATEPART(month,[Date Received])AS VarChar(2)),2) [TicketDate]
				,[Ticket]
				,CASE MAX([Priority])
					WHEN 'Critical' 
					THEN MAX([TS_DBA_Notes]|[TS_DBA_Assign]|[TS_DBA_Create]|[TS_DBA_Comps])
					ELSE 0 END					AS [TS_DBA_Critical]
				,CASE MAX([Priority])
					WHEN 'Standard' 
					THEN MAX([TS_DBA_Notes]|[TS_DBA_Assign]|[TS_DBA_Create]|[TS_DBA_Comps])
					ELSE 0 END					AS [TS_DBA_Standard]
				,CASE MAX([Priority])
					WHEN 'low' 
					THEN MAX([TS_DBA_Notes]|[TS_DBA_Assign]|[TS_DBA_Create]|[TS_DBA_Comps])
					ELSE 0 END					AS [TS_DBA_Low]
				,CASE MAX([Priority])
					WHEN 'Critical' 
					THEN MAX([TS_WEB_Notes]|[TS_WEB_Create]|[TS_WEB_Comps])
					ELSE 0 END					AS [TS_WEB_Critical]
				,CASE MAX([Priority])
					WHEN 'Standard' 
					THEN MAX([TS_WEB_Notes]|[TS_WEB_Create]|[TS_WEB_Comps])
					ELSE 0 END					AS [TS_WEB_Standard]
				,CASE MAX([Priority])
					WHEN 'low' 
					THEN MAX([TS_WEB_Notes]|[TS_WEB_Create]|[TS_WEB_Comps])
					ELSE 0 END					AS [TS_WEB_Low]
		FROM		[dbacentral].[dbo].[DBA_Dashboard_TicketDetails_Gears]		
		WHERE		YEAR([Date Received]) >= YEAR(GetDate())-1 -- THIS AND LAST YEAR


		GROUP BY	CAST( DATEPART(year,[Date Received])AS VarChar(4)) + '-' + RIGHT('00'+CAST(DATEPART(month,[Date Received])AS VarChar(2)),2)
				,[Ticket]
		) ChartData
GROUP BY	[TicketDate]
GO





		
WITH		Components
AS		(
		SELECT		build_request_id
				,LEFT([Components],LEN([Components])-1)			AS [Components]
				,LEFT([Types],LEN([Types])-1)				AS [Types]
				,CASE WHEN [Types] like '%DB%' THEN 1 ELSE 0 END	AS [TS_DBA_Comps]
				,CASE WHEN [Types] like '%WEB%' THEN 1 ELSE 0 END	AS [TS_WEB_Comps]
		FROM		(
				SELECT		T1.build_request_id
						,dbaadmin.dbo.ConcatenateUnique(COALESCE(T3.component_name,'none')+',') AS [Components]
						,dbaadmin.dbo.ConcatenateUnique(COALESCE(LTRIM(RTRIM(CAST(T4.component_type AS VarChar(4)))),'none')+',') AS [Types]
						
				FROM		[gears].[dbo].[BUILD_REQUESTS] T1 WITH(NOLOCK) 
				LEFT JOIN	gears.dbo.BUILD_REQUEST_COMPONENTS T2
					ON	T2.build_request_id = T1.build_request_id 
				LEFT JOIN	gears.dbo.COMPONENTS T3
					ON	T3.component_id = T2.component_id
				LEFT JOIN	[gears].[dbo].[COMPONENT_TYPE] T4
					ON	T4.[component_type_id] = T3.[component_type_id]	
				GROUP BY	T1.build_request_id
				) Components
		)		
		

GO








SELECT		[APPL]
		,[Type]
		,LEFT([Components],LEN([Components])-1) AS [Components]
		,[YearToDate]
		,[MonthToDate]
FROM		(
		SELECT		[APPL]
				,[Type]
				,dbaadmin.dbo.ConcatenateUnique(COALESCE([Component],'none')+',')	AS [Components]
				,SUM([YearToDate])							AS [YearToDate]
				,SUM([MonthToDate])							AS [MonthToDate]
		FROM		(
				SELECT		COALESCE(T3.component_APPLname,T5.Appl_desc)				AS [APPL]
						,T4.component_type							AS [Type]
						,T3.component_name							AS [Component]
						,SUM(CASE WHEN year(T1.request_date) = year(getdate())
							THEN 1
							ELSE 0
							END)								AS [YearToDate]
						,SUM(CASE WHEN year(T1.request_date) = year(getdate()) 
								AND month(T1.request_date) = month(getdate())
							THEN 1
							ELSE 0
							END)								AS [MonthToDate]
						
				FROM		[gears].[dbo].[BUILD_REQUESTS] T1 WITH(NOLOCK) 
				LEFT JOIN	gears.dbo.BUILD_REQUEST_COMPONENTS T2
					ON	T2.build_request_id = T1.build_request_id 
				LEFT JOIN	gears.dbo.COMPONENTS T3
					ON	T3.component_id = T2.component_id
				LEFT JOIN	[gears].[dbo].[COMPONENT_TYPE] T4
					ON	T4.[component_type_id] = T3.[component_type_id]
				LEFT JOIN	dbo.db_ApplCrossRef T5
					ON	T5.db_name = T3.component_name
				GROUP BY	COALESCE(T3.component_APPLname,T5.Appl_desc)
						,T4.component_type
						,T3.component_name
				) Data
		WHERE		[YearToDate]	> 0
			AND	TYPE IN ('DB','WEB')
		GROUP BY	[APPL]
				,[Type]	
		) DATA
ORDER BY	1,2	