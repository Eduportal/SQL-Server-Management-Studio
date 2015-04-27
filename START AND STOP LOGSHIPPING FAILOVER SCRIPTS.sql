

--RECOVER ALL LOG SHIPPED DATABASES AND GO LIVE

DECLARE @DBName		SYSNAME
DECLARE @JobName	SYSNAME

DECLARE DatabaseListCursor CURSOR
FOR
-- SELECT QUERY FOR CURSOR (CUSTOMIZED FOR THIS SERVER)
SELECT 'Getty_Images_US_Inc__MSCRM_Clone' UNION ALL
SELECT 'Getty_Images_US_Inc_Custom' UNION ALL
SELECT 'MSCRM_CONFIG' UNION ALL
SELECT 'ReportServer' UNION ALL
SELECT 'ReportServerTempDB' UNION ALL
SELECT 'ImportManager' UNION ALL
SELECT 'ReportServer2' UNION ALL
SELECT 'ReportServer2TempDB' UNION ALL
SELECT 'Getty_Images_US_Inc__MSCRM' UNION ALL
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
DECLARE @FromServer	SYSNAME
DECLARE @CreateJobs	

DECLARE DatabaseListCursor CURSOR
FOR
-- SELECT QUERY FOR CURSOR (CUSTOMIZED FOR THIS SERVER)
SELECT 'Getty_Images_US_Inc__MSCRM_Clone'	,'SEAPCRMSQL1A' UNION ALL
SELECT 'Getty_Images_US_Inc_Custom'		,'SEAPCRMSQL1A' UNION ALL
SELECT 'MSCRM_CONFIG'				,'SEAPCRMSQL1A' UNION ALL
SELECT 'ReportServer'				,'SEAPCRMSQL1A' UNION ALL
SELECT 'ReportServerTempDB'			,'SEAPCRMSQL1A' UNION ALL
SELECT 'ImportManager'				,'SEAPCRMSQL1A' UNION ALL
SELECT 'ReportServer2'				,'SEAPCRMSQL1A' UNION ALL
SELECT 'ReportServer2TempDB'			,'SEAPCRMSQL1A' UNION ALL
SELECT 'Getty_Images_US_Inc__MSCRM'		,'SEAPCRMSQL1A' UNION ALL
SELECT 'Getty_Images_CRM_GENESYS'		,'SEAPCRMSQL1A'

-- DISABLE BACKUP JOBS
EXEC msdb.dbo.sp_update_job @job_name=N'MAINT - Weekly Backup and DBCC', @enabled=0
EXEC msdb.dbo.sp_update_job @job_name=N'MAINT - TranLog Backup', @enabled=0
EXEC msdb.dbo.sp_update_job @job_name=N'MAINT - Daily Backup and DBCC', @enabled=0



EXEC msdb.dbo.sp_update_job @job_name=N'LSAlert_ASHPCRMSQL11', @enabled=1

OPEN DatabaseListCursor;
FETCH DatabaseListCursor INTO @DBName,@FromServer;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
	
		EXEC dbaadmin.[dbo].[dbasp_Logship_MS_Fix_2] @DBName,@FromServer,NULL,NULL,1,0,1

		SET	@JobName	= 'LSCopy_SEAPCRMSQL1A_' + @DBName
		EXEC	msdb.dbo.sp_update_job @job_name=@JobName, @enabled=1

		SET	@JobName	= 'LSRestore_SEAPCRMSQL1A_' + @DBName
		EXEC	msdb.dbo.sp_update_job @job_name=@JobName, @enabled=1

		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM DatabaseListCursor INTO @DBName,@FromServer;
END
CLOSE DatabaseListCursor;
DEALLOCATE DatabaseListCursor;
GO

-- RESET MAINTENANCE PLANS
exec dbaadmin.dbo.dbasp_set_maintplans
GO


