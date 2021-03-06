/****** Script for SelectTopNRows command from SSMS  ******/
SELECT		OBJECT_NAME(objectid,dbid) 
		,[rundate]
		,[intrvl_time_S]
		,[dbid]
		,[objectid]
		,[delta_worker_time]
		,[Avg_CPU_Time_MS]
		,[delta_elapsed_time]
		,[Avg_Elapsed_Time_MS]
		,[delta_physical_reads]
		,[delta_logical_reads]
		,[Avg_Logical_Reads]
		,[delta_logical_writes]
		,[Avg_Logical_Writes]
		,[execution_count]
		,[QueryText]
FROM [dbaperf].[dbo].[DMV_QueryStats_log]
WHERE		QueryText Like '%wedEntityGetLightInfo%'


WHERE		dbid = DB_ID('WCDS')
	AND	objectid IN	(
				SELECT OBJECT_ID('[WCDS].[dbo].[wedEntityGetLightInfo]') UNION
				SELECT OBJECT_ID('[WCDS].[dbo].[wedIndividualInterestTypeGet]') UNION
				SELECT OBJECT_ID('[WCDS].[dbo].[wedIndividualInterestTypeSet]') UNION
				SELECT OBJECT_ID('[WCDS].[dbo].[wedIndividualJobRoleGet]') UNION
				SELECT OBJECT_ID('[WCDS].[dbo].[wedIndividualJobRoleSet]') UNION
				SELECT OBJECT_ID('[WCDS].[dbo].[wedIndividualSummaryGet151]') UNION
				SELECT OBJECT_ID('[WCDS].[dbo].[wedIndividualSummarySet151]') UNION
				SELECT OBJECT_ID('[WCDS].[dbo].[wedUserCheckLoginName]') UNION
				SELECT OBJECT_ID('[WCDS].[dbo].[wedUserGetHeavyInfo116]') UNION
				SELECT OBJECT_ID('[WCDS].[dbo].[wedUserGetLightInfo117]') UNION
				SELECT OBJECT_ID('[WCDS].[dbo].[wedUserGetPrefs]') UNION
				SELECT OBJECT_ID('[WCDS].[dbo].[wedUserSetActiveStatus]') UNION
				SELECT OBJECT_ID('[WCDS].[dbo].[wedUserSetHeavyInfo116]') UNION
				SELECT OBJECT_ID('[WCDS].[dbo].[wedUserSetLightInfo126]') UNION
				SELECT OBJECT_ID('[WCDS].[dbo].[wedUserSetPrefs]') UNION
				SELECT OBJECT_ID('[WCDS].[dbo].[wedWebSiteUseGetInfo127]') UNION
				SELECT OBJECT_ID('[WCDS].[dbo].[wedWebSiteUseSetInfo127]')
				)
ORDER BY	[dbid]
		,[objectid]
		,[rundate] DESC




SELECT DB_NAME(dbid) AS [DB_NAME], 
       OBJECT_SCHEMA_NAME(objectid,dbid) AS [SCHEMA_NAME], 
       OBJECT_NAME(objectid,dbid)AS [OBJECT_NAME], 
       SUM(usecounts) AS [Use_Count], 
       dbid, 
       objectid  
FROM sys.dm_exec_cached_plans cp
   CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle)
WHERE objtype = 'Proc'
  AND UPPER(
-- remove white space first
            REPLACE( 
             REPLACE(
              REPLACE(
               REPLACE(
                REPLACE(
                 REPLACE(
                  REPLACE(text,'       ',' '),
                 '       ',' '),
                '      ',' '),
               '     ', ' '),
              '    ',' '),
             '   ',' '),
            '  ',' ')
           )
       LIKE '%CREATE PROC%'
GROUP BY dbid, objectid; 

