
USE [DBAadmin]
GO
/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetJobStatus]    Script Date: 9/18/2014 12:56:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--ALTER FUNCTION [dbo].[dbaudf_GetJobStatus] ( 
--    @pJobName varchar(100) 
--) 
--RETURNS int
--AS
---- ============================================= 
---- Author:      Steve Ledridge 
---- Create date: 10/29/2012
---- Description: Gets state of particular Job 
---- 
---- NULL = Job was not Found 
---- NEGATIVE VALUE = Job is Disabled 
----  1 = Failed 
----  2 = Succeeded 
----  3 = Retry 
----  4 = Canceled 
----  5 = In progress 
----  6 = Idle
---- ============================================= 

--BEGIN
--    DECLARE @status int 
--    DECLARE @Factor INT   
 
--    SELECT
--	@Factor = CASE WHEN O.enabled = 0 THEN -1 ELSE 1 END
--        ,@status = CASE
--			WHEN OA.run_requested_date IS NULL THEN 6
--			ELSE ISNULL(JH.RUN_STATUS, 4)+1
--			END       
--    FROM MSDB.DBO.SYSJOBS O 
--    INNER JOIN MSDB.DBO.SYSJOBACTIVITY OA ON (O.job_id = OA.job_id) 
--    INNER JOIN (SELECT MAX(SESSION_ID) AS SESSION_ID FROM MSDB.DBO.SYSSESSIONS ) AS S ON (OA.session_ID = S.SESSION_ID) 
--    LEFT JOIN MSDB.DBO.SYSJOBHISTORY JH ON (OA.job_history_id = JH.instance_id) 
--    WHERE O.name = @pJobName 
 
--    RETURN @status * @Factor
--END
--GO
--/*

--select		'RESTORE DATABASE ['+name+'] WITH RECOVERY'
--From		sys.databases
--WHERE		state_desc = 'RESTORING'

--*/



---- DISABLE ALL LOG SHIPPING JOBS
--EXEC msdb.dbo.sp_update_job @job_name=N'LSAlert_ASHPCRMSQL11', @enabled=0
--GO
--EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_SEAPCRMSQL1A_Getty_Images_CRM_GENESYS', @enabled=0
--EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_SEAPCRMSQL1A_Getty_Images_US_Inc__MSCRM_Clone', @enabled=0
--EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_SEAPCRMSQL1A_Getty_Images_US_Inc_Custom', @enabled=0
--EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_SEAPCRMSQL1A_MSCRM_CONFIG', @enabled=0
--EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_SEAPCRMSQL1A_ReportServer', @enabled=0
--EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_SEAPCRMSQL1A_ReportServerTempDB', @enabled=0
--EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_SEAPCRMSQL1A_ImportManager', @enabled=0
--EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_SEAPCRMSQL1A_ReportServer2', @enabled=0
--EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_SEAPCRMSQL1A_ReportServer2TempDB', @enabled=0
--EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_SEAPCRMSQL1A_Getty_Images_US_Inc__MSCRM', @enabled=0
--GO
--EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_SEAPCRMSQL1A_Getty_Images_CRM_GENESYS', @enabled=0
--EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_SEAPCRMSQL1A_Getty_Images_US_Inc__MSCRM_Clone', @enabled=0
--EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_SEAPCRMSQL1A_Getty_Images_US_Inc_Custom', @enabled=0
--EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_SEAPCRMSQL1A_MSCRM_CONFIG', @enabled=0
--EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_SEAPCRMSQL1A_ReportServer', @enabled=0
--EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_SEAPCRMSQL1A_ReportServerTempDB', @enabled=0
--EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_SEAPCRMSQL1A_ImportManager', @enabled=0
--EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_SEAPCRMSQL1A_ReportServer2', @enabled=0
--EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_SEAPCRMSQL1A_ReportServer2TempDB', @enabled=0
--EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_SEAPCRMSQL1A_Getty_Images_US_Inc__MSCRM', @enabled=0
--GO


--DISABLE ALL LOG SHIPPING AND BRING DATABASES ONLINE

DECLARE @DBName		SYSNAME
DECLARE @JobName	SYSNAME

DECLARE DatabaseListCursor CURSOR
FOR
-- SELECT QUERY FOR CURSOR
--SELECT 'Getty_Images_US_Inc__MSCRM_Clone' UNION ALL
--SELECT 'Getty_Images_US_Inc_Custom' UNION ALL
--SELECT 'MSCRM_CONFIG' UNION ALL
--SELECT 'ReportServer' UNION ALL
--SELECT 'ReportServerTempDB' UNION ALL
--SELECT 'ImportManager' UNION ALL
--SELECT 'ReportServer2' UNION ALL
--SELECT 'ReportServer2TempDB' UNION ALL
--SELECT 'Getty_Images_US_Inc__MSCRM' UNION ALL
SELECT 'Getty_Images_CRM_GENESYS'


EXEC msdb.dbo.sp_update_job @job_name=N'LSAlert_ASHPCRMSQL11', @enabled=0

OPEN DatabaseListCursor;
FETCH DatabaseListCursor INTO @DBName;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
	
		SET	@JobName	= 'LSCopy_SEAPCRMSQL1A_' + @DBName
		EXEC	msdb.dbo.sp_update_job @job_name=@JobName, @enabled=0

		SET	@JobName	= 'LSRestore_SEAPCRMSQL1A_' + @DBName
		EXEC	msdb.dbo.sp_update_job @job_name=@JobName, @enabled=0

		WHILE [dbaadmin].[dbo].[dbaudf_GetJobStatus](@JobName) IN (5,-5)
		BEGIN
			RAISERROR('Waiting for %s Job to Complete.',-1,-1,@JobName) WITH NOWAIT
			WAITFOR DELAY '00:01:00'
		END 
		EXEC ('RESTORE DATABASE ['+@DBName+'] WITH RECOVERY')

		EXEC dbaadmin.dbo.dbasp_Backup @DBName = @DBName, @Mode = 'BF'
		EXEC dbaadmin.dbo.dbasp_Backup @DBName = @DBName, @Mode = 'BL'
	
		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM DatabaseListCursor INTO @DBName;
END
CLOSE DatabaseListCursor;
DEALLOCATE DatabaseListCursor;
GO
-- RESET MAINTENANCE PLANS
exec dbaadmin.dbo.dbasp_set_maintplans
GO

-- ENABLE AND START BACKUP JOBS
EXEC msdb.dbo.sp_update_job @job_name=N'MAINT - Weekly Backup and DBCC', @enabled=1
EXEC msdb.dbo.sp_update_job @job_name=N'MAINT - TranLog Backup', @enabled=1
EXEC msdb.dbo.sp_update_job @job_name=N'MAINT - Daily Backup and DBCC', @enabled=1
GO






-- ENABLE ALL LOG SHIPPING

DECLARE @DBName		SYSNAME
DECLARE @JobName	SYSNAME

DECLARE DatabaseListCursor CURSOR
FOR
-- SELECT QUERY FOR CURSOR
--SELECT 'Getty_Images_US_Inc__MSCRM_Clone' UNION ALL
--SELECT 'Getty_Images_US_Inc_Custom' UNION ALL
--SELECT 'MSCRM_CONFIG' UNION ALL
--SELECT 'ReportServer' UNION ALL
--SELECT 'ReportServerTempDB' UNION ALL
--SELECT 'ImportManager' UNION ALL
--SELECT 'ReportServer2' UNION ALL
--SELECT 'ReportServer2TempDB' UNION ALL
--SELECT 'Getty_Images_US_Inc__MSCRM' UNION ALL
SELECT 'Getty_Images_CRM_GENESYS'

-- DISABLE BACKUP JOBS
EXEC msdb.dbo.sp_update_job @job_name=N'MAINT - Weekly Backup and DBCC', @enabled=0
EXEC msdb.dbo.sp_update_job @job_name=N'MAINT - TranLog Backup', @enabled=0
EXEC msdb.dbo.sp_update_job @job_name=N'MAINT - Daily Backup and DBCC', @enabled=0



EXEC msdb.dbo.sp_update_job @job_name=N'LSAlert_ASHPCRMSQL11', @enabled=1

OPEN DatabaseListCursor;
FETCH DatabaseListCursor INTO @DBName;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
	
		EXEC dbaadmin.[dbo].[dbasp_Logship_MS_Fix] @DBName,1,0,1

		SET	@JobName	= 'LSCopy_SEAPCRMSQL1A_' + @DBName
		EXEC	msdb.dbo.sp_update_job @job_name=@JobName, @enabled=1

		SET	@JobName	= 'LSRestore_SEAPCRMSQL1A_' + @DBName
		EXEC	msdb.dbo.sp_update_job @job_name=@JobName, @enabled=1

		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM DatabaseListCursor INTO @DBName;
END
CLOSE DatabaseListCursor;
DEALLOCATE DatabaseListCursor;
GO

-- RESET MAINTENANCE PLANS
exec dbaadmin.dbo.dbasp_set_maintplans
GO




















--RESTORE DATABASE [Getty_Images_CRM_GENESYS] WITH RECOVERY
--RESTORE DATABASE [Getty_Images_US_Inc__MSCRM_Clone] WITH RECOVERY
--RESTORE DATABASE [Getty_Images_US_Inc_Custom] WITH RECOVERY
--RESTORE DATABASE [MSCRM_CONFIG] WITH RECOVERY
--RESTORE DATABASE [ReportServer] WITH RECOVERY
--RESTORE DATABASE [ReportServerTempDB] WITH RECOVERY
--RESTORE DATABASE [ImportManager] WITH RECOVERY
--RESTORE DATABASE [ReportServer2] WITH RECOVERY
--RESTORE DATABASE [ReportServer2TempDB] WITH RECOVERY
--RESTORE DATABASE [Getty_Images_US_Inc__MSCRM] WITH RECOVERY
--GO








---- DISABLE BACKUP JOBS
--EXEC msdb.dbo.sp_update_job @job_name=N'MAINT - Weekly Backup and DBCC', @enabled=0
--EXEC msdb.dbo.sp_update_job @job_name=N'MAINT - TranLog Backup', @enabled=0
--EXEC msdb.dbo.sp_update_job @job_name=N'MAINT - Daily Backup and DBCC', @enabled=0
--GO

---- REPAIR ALL LOGSHIPPED DATABASES
--EXEC dbaadmin.[dbo].[dbasp_Logship_MS_Fix] 'Getty_Images_CRM_GENESYS',1,1,1
--EXEC dbaadmin.[dbo].[dbasp_Logship_MS_Fix] 'Getty_Images_US_Inc__MSCRM_Clone',1,1,1
--EXEC dbaadmin.[dbo].[dbasp_Logship_MS_Fix] 'Getty_Images_US_Inc_Custom',1,1,1
--EXEC dbaadmin.[dbo].[dbasp_Logship_MS_Fix] 'MSCRM_CONFIG',1,1,1
--EXEC dbaadmin.[dbo].[dbasp_Logship_MS_Fix] 'ReportServer',1,1,1
--EXEC dbaadmin.[dbo].[dbasp_Logship_MS_Fix] 'ReportServerTempDB',1,1,1
--EXEC dbaadmin.[dbo].[dbasp_Logship_MS_Fix] 'ImportManager',1,1,1
--EXEC dbaadmin.[dbo].[dbasp_Logship_MS_Fix] 'ReportServer2',1,1,1
--EXEC dbaadmin.[dbo].[dbasp_Logship_MS_Fix] 'ReportServer2TempDB',1,1,1
--EXEC dbaadmin.[dbo].[dbasp_Logship_MS_Fix] 'Getty_Images_US_Inc__MSCRM',1,1,1
--GO
---- RESET MAINTENANCE PLANS
--exec dbaadmin.dbo.dbasp_set_maintplans
--GO

---- ENABLE ALL LOG SHIPPING JOBS
--EXEC msdb.dbo.sp_update_job @job_name=N'LSAlert_ASHPCRMSQL11', @enabled=1
--GO
--EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_SEAPCRMSQL1A_Getty_Images_CRM_GENESYS', @enabled=1
--EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_SEAPCRMSQL1A_Getty_Images_US_Inc__MSCRM_Clone', @enabled=1
--EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_SEAPCRMSQL1A_Getty_Images_US_Inc_Custom', @enabled=1
--EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_SEAPCRMSQL1A_MSCRM_CONFIG', @enabled=1
--EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_SEAPCRMSQL1A_ReportServer', @enabled=1
--EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_SEAPCRMSQL1A_ReportServerTempDB', @enabled=1
--EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_SEAPCRMSQL1A_ImportManager', @enabled=1
--EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_SEAPCRMSQL1A_ReportServer2', @enabled=1
--EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_SEAPCRMSQL1A_ReportServer2TempDB', @enabled=1
--EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_SEAPCRMSQL1A_Getty_Images_US_Inc__MSCRM', @enabled=1
--GO
--EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_SEAPCRMSQL1A_Getty_Images_CRM_GENESYS', @enabled=1
--EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_SEAPCRMSQL1A_Getty_Images_US_Inc__MSCRM_Clone', @enabled=1
--EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_SEAPCRMSQL1A_Getty_Images_US_Inc_Custom', @enabled=1
--EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_SEAPCRMSQL1A_MSCRM_CONFIG', @enabled=1
--EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_SEAPCRMSQL1A_ReportServer', @enabled=1
--EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_SEAPCRMSQL1A_ReportServerTempDB', @enabled=1
--EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_SEAPCRMSQL1A_ImportManager', @enabled=1
--EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_SEAPCRMSQL1A_ReportServer2', @enabled=1
--EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_SEAPCRMSQL1A_ReportServer2TempDB', @enabled=1
--EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_SEAPCRMSQL1A_Getty_Images_US_Inc__MSCRM', @enabled=1
--GO


