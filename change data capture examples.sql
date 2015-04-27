USE [master]
GO

IF  EXISTS (SELECT * FROM sys.server_audits WHERE name = N'Audit-Anthill-DataChanges')
DROP SERVER AUDIT [Audit-Anthill-DataChanges]
GO

CREATE SERVER AUDIT [Audit-Anthill-DataChanges]
TO APPLICATION_LOG
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
	,AUDIT_GUID = 'd1a07781-9ba0-4b3a-88e9-0ca6be08126d'
)
GO


USE [anthill3]
GO

IF  EXISTS (SELECT * FROM sys.database_audit_specifications WHERE name = N'InsertUpdateDelete-JOB_CONFIG_STEP-Public')
BEGIN
	ALTER DATABASE AUDIT SPECIFICATION [InsertUpdateDelete-JOB_CONFIG_STEP-Public]
	WITH (STATE = OFF)
	
	DROP DATABASE AUDIT SPECIFICATION [InsertUpdateDelete-JOB_CONFIG_STEP-Public]
END
GO

CREATE DATABASE AUDIT SPECIFICATION [InsertUpdateDelete-JOB_CONFIG_STEP-Public]
FOR SERVER AUDIT [Audit-Anthill-DataChanges]

ADD (UPDATE ON OBJECT::[anthill3].[JOB_CONFIG_STEP] BY [public]),
ADD (INSERT ON OBJECT::[anthill3].[JOB_CONFIG_STEP] BY [public]),
ADD (DELETE ON OBJECT::[anthill3].[JOB_CONFIG_STEP] BY [public]),

ADD (UPDATE ON OBJECT::[anthill3].[WORKFLOW_CASE] BY [public]),
ADD (INSERT ON OBJECT::[anthill3].[WORKFLOW_CASE] BY [public]),
ADD (DELETE ON OBJECT::[anthill3].[WORKFLOW_CASE] BY [public]),

ADD (UPDATE ON OBJECT::[anthill3].[BUILD_PROFILE] BY [public]),
ADD (INSERT ON OBJECT::[anthill3].[BUILD_PROFILE] BY [public]),
ADD (DELETE ON OBJECT::[anthill3].[BUILD_PROFILE] BY [public])

WITH (STATE = ON)
GO


USE [master]
GO
ALTER SERVER AUDIT [Audit-Anthill-DataChanges]
WITH (STATE = ON)
GO
ALTER DATABASE Anthill3
SET CHANGE_TRACKING = ON
(CHANGE_RETENTION = 2 DAYS, AUTO_CLEANUP = ON)





USE [anthill3]
GO
EXEC sys.sp_cdc_enable_db 
GO  
SELECT [name], is_tracked_by_cdc  
FROM sys.tables 
WHERE is_tracked_by_cdc = 1
GO  
EXEC sys.sp_cdc_enable_table 
@source_schema = N'anthill3', 
@source_name   = N'JOB_CONFIG_STEP', 
@role_name     = NULL 
GO
EXEC sys.sp_cdc_enable_table 
@source_schema = N'anthill3', 
@source_name   = N'WORKFLOW_CASE', 
@role_name     = NULL 
GO
EXEC sys.sp_cdc_enable_table 
@source_schema = N'anthill3', 
@source_name   = N'BUILD_PROFILE', 
@role_name     = NULL 
GO
SELECT [name], is_tracked_by_cdc  
FROM sys.tables 
WHERE is_tracked_by_cdc = 1
GO  

ALTER TABLE [anthill3].[JOB_CONFIG_STEP]
ENABLE CHANGE_TRACKING
WITH (TRACK_COLUMNS_UPDATED = ON)
GO

ALTER TABLE [anthill3].[WORKFLOW_CASE]
ENABLE CHANGE_TRACKING
WITH (TRACK_COLUMNS_UPDATED = ON)
GO

ALTER TABLE [anthill3].[BUILD_PROFILE]
ENABLE CHANGE_TRACKING
WITH (TRACK_COLUMNS_UPDATED = ON)
GO




SELECT		* 
FROM		[anthill3].[JOB_CONFIG_STEP]
GO 
SELECT		* 
FROM		cdc.anthill3_JOB_CONFIG_STEP_CT 
GO
SELECT		* 
FROM		cdc.anthill3_WORKFLOW_CASE_CT 
GO
SELECT		* 
FROM		cdc.anthill3_BUILD_PROFILE_CT 
GO

SELECT MAX([min_lsn])
FROM
(
SELECT [sys].[fn_cdc_get_min_lsn]('anthill3_JOB_CONFIG_STEP') [min_lsn] UNION ALL

SELECT [sys].[fn_cdc_get_min_lsn]('anthill3_WORKFLOW_CASE') UNION ALL

SELECT [sys].[fn_cdc_get_min_lsn]('anthill3_BUILD_PROFILE')
) data




SELECT		* 
FROM		cdc.lsn_time_mapping 
GO

USE anthill3
GO

DECLARE		@begin_time		DATETIME
		,@end_time		DATETIME
		,@begin_lsn		BINARY(10)
		,@end_lsn		BINARY(10)

SELECT		@begin_time	= GETDATE()-1
		,@end_time	= GETDATE()
		,@end_lsn	= sys.fn_cdc_map_time_to_lsn('largest less than or equal', @end_time)

SET		@begin_lsn	= sys.fn_cdc_map_time_to_lsn('smallest greater than', @begin_time) 
IF @begin_lsn < [sys].[fn_cdc_get_min_lsn]('anthill3_JOB_CONFIG_STEP')	
	SET @begin_lsn = [sys].[fn_cdc_get_min_lsn]('anthill3_JOB_CONFIG_STEP')	


SELECT		sys.fn_cdc_map_lsn_to_time([__$start_lsn]) [StartTime]	
		,CASE [__$operation] WHEN 1 THEN 'Delete' WHEN 2 THEN 'Insert' WHEN 3 THEN 'Update OLD' WHEN 4 THEN 'Update NEW' END [AuditType]
		,*
FROM		cdc.fn_cdc_get_all_changes_anthill3_JOB_CONFIG_STEP(@begin_lsn,@end_lsn,'all update old') 
ORDER BY	1

SET		@begin_lsn	= sys.fn_cdc_map_time_to_lsn('smallest greater than', @begin_time) 
IF @begin_lsn < [sys].[fn_cdc_get_min_lsn]('anthill3_WORKFLOW_CASE')	
	SET @begin_lsn = [sys].[fn_cdc_get_min_lsn]('anthill3_WORKFLOW_CASE')	



SELECT		sys.fn_cdc_map_lsn_to_time([__$start_lsn]) [StartTime]	
		,CASE [__$operation] WHEN 1 THEN 'Delete' WHEN 2 THEN 'Insert' WHEN 3 THEN 'Update OLD' WHEN 4 THEN 'Update NEW' END [AuditType]
		,*
FROM		cdc.fn_cdc_get_all_changes_anthill3_WORKFLOW_CASE(@begin_lsn,@end_lsn,'all update old')
ORDER BY	1


SET		@begin_lsn	= sys.fn_cdc_map_time_to_lsn('smallest greater than', @begin_time) 
IF @begin_lsn < [sys].[fn_cdc_get_min_lsn]('anthill3_BUILD_PROFILE')	
	SET @begin_lsn = [sys].[fn_cdc_get_min_lsn]('anthill3_BUILD_PROFILE')	


SELECT		sys.fn_cdc_map_lsn_to_time([__$start_lsn]) [StartTime]	
		,CASE [__$operation] WHEN 1 THEN 'Delete' WHEN 2 THEN 'Insert' WHEN 3 THEN 'Update OLD' WHEN 4 THEN 'Update NEW' END [AuditType]
		,*
FROM		cdc.fn_cdc_get_all_changes_anthill3_BUILD_PROFILE(@begin_lsn,@end_lsn,'all update old') 
ORDER BY	1
GO  

  

  








SELECT		T1.*
		,c.SYS_CHANGE_VERSION
		,c.SYS_CHANGE_CONTEXT
FROM		[anthill3].[JOB_CONFIG_STEP] AS T1
CROSS APPLY	CHANGETABLE (VERSION [anthill3].[JOB_CONFIG_STEP], ([ID]), (T1.[ID])) AS c;



-- Get all changes (inserts, updates, deletes)
DECLARE		@last_sync_version	bigint;
SET		@last_sync_version	= 0;
SELECT		T1.*
		, c.[ID]
		, c.SYS_CHANGE_VERSION
		, c.SYS_CHANGE_OPERATION
		, c.SYS_CHANGE_COLUMNS
		, c.SYS_CHANGE_CONTEXT 
FROM		CHANGETABLE (CHANGES [anthill3].[JOB_CONFIG_STEP], @last_sync_version) AS c
LEFT JOIN	[anthill3].[JOB_CONFIG_STEP] AS T1
	ON	T1.[ID] = c.[ID];









SELECT * FROM CHANGETABLE(CHANGES [anthill3].[JOB_CONFIG_STEP],0) AS CT


 -- Obtain the current synchronization version. This will be used next time that changes are obtained.
    SET @synchronization_version = CHANGE_TRACKING_CURRENT_VERSION();

    -- Obtain initial data set.
    SELECT		*
    FROM		[anthill3].[JOB_CONFIG_STEP] AS P

