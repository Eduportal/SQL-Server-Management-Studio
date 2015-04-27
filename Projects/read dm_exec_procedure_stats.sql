





SELECT		usecounts
		, text
		, dbid
		, objectid 
FROM		sys.dm_exec_cached_plans cp
   CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle)
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



SELECT		DB_Name(T2.dbid) DBName
		,OBJECT_SCHEMA_NAME(object_id,T2.dbid) SchemaName
		,OBJECT_NAME(object_id,T2.dbid) ObjectName
		,last_execution_time
		,last_worker_time
		,last_physical_reads
		,last_logical_writes
		,last_logical_reads
		,last_elapsed_time
		,execution_count

FROM		sys.dm_exec_procedure_stats T1
CROSS APPLY	sys.dm_exec_query_plan(T1.plan_handle) T2
		
WHERE		Database_ID = DB_ID('WCDS')
	AND	object_id IN	(
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


/*



[WCDS].[dbo].[wedEntityGetLightInfo]
[WCDS].[dbo].[wedIndividualInterestTypeGet]
[WCDS].[dbo].[wedIndividualInterestTypeSet]
[WCDS].[dbo].[wedIndividualJobRoleGet]
[WCDS].[dbo].[wedIndividualJobRoleSet]
[WCDS].[dbo].[wedIndividualSummaryGet151]
[WCDS].[dbo].[wedIndividualSummarySet151]
[WCDS].[dbo].[wedUserCheckLoginName]
[WCDS].[dbo].[wedUserGetHeavyInfo116]
[WCDS].[dbo].[wedUserGetLightInfo117]
[WCDS].[dbo].[wedUserGetPrefs]
[WCDS].[dbo].[wedUserSetActiveStatus]
[WCDS].[dbo].[wedUserSetHeavyInfo116]
[WCDS].[dbo].[wedUserSetLightInfo126]
[WCDS].[dbo].[wedUserSetPrefs]
[WCDS].[dbo].[wedWebSiteUseGetInfo127]
[WCDS].[dbo].[wedWebSiteUseSetInfo127]




*/

