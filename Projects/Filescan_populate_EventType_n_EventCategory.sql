SELECT	DISTINCT [EventType],[EventTypeName]
--INTO	FileScan_EVTLOG_EventType  
FROM	[dbaadmin].[dbo].[FilescanImport_CurrentWorkTable_ServerError] T1


SELECT [EventCategory],[SourceName],[EventCategoryName]
--INTO FileScan_EVTLOG_EventCategory
FROM
(
SELECT DISTINCT T1.[EventCategory],T1.[SourceName],T1.[EventCategoryName]	  
FROM	[dbaadmin].[dbo].[FilescanImport_CurrentWorkTable_ServerError] T1
JOIN	(
	SELECT DISTINCT [EventCategory],COUNT(DISTINCT [EventCategoryName])Cnt
	--INTO FileScan_EVTLOG_EventCategory
	FROM [dbaadmin].[dbo].[FilescanImport_CurrentWorkTable_ServerError]  
	GROUP BY  [EventCategory]
	HAVING	COUNT(DISTINCT [EventCategoryName]) > 1
	)T2
	ON T1.[EventCategory]=T2.[EventCategory]
UNION	
SELECT DISTINCT T1.[EventCategory],NULL,T1.[EventCategoryName]
FROM	[dbaadmin].[dbo].[FilescanImport_CurrentWorkTable_ServerError] T1
JOIN	(
	SELECT DISTINCT [EventCategory],COUNT(DISTINCT [EventCategoryName])Cnt
	--INTO FileScan_EVTLOG_EventCategory
	FROM [dbaadmin].[dbo].[FilescanImport_CurrentWorkTable_ServerError]  
	GROUP BY  [EventCategory]
	HAVING	COUNT(DISTINCT [EventCategoryName]) = 1
	)T2
	ON T1.[EventCategory]=T2.[EventCategory]
) Data	  
ORDER BY 1,2,3