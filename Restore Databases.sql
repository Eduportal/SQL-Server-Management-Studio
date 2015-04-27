--EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Getty_Images_CRM_GENESYS'		,'SEAPCRMSQL1A'		,NULL	,NULL	,1,1,1
--EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Getty_Images_US_Inc__MSCRM'		,'SEAPCRMSQL1A'		,NULL	,NULL	,1,1,1
--EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Getty_Images_US_Inc_Custom'		,'SEAPCRMSQL1A'		,NULL	,NULL	,1,1,1
--EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Subscription'				,'SEAPSQLRYLINT02'	,NULL	,NULL	,1,1,1

--EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Getty_Master'				,'SEAPSQLRYL0A'		,NULL	,NULL	,1,1,1
--EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'RM_Integration'			,'SEAPSQLRYL0A'		,NULL	,NULL	,1,1,1


--RESTORE DATABASE Getty_Images_CRM_GENESYS WITH RECOVERY
--RESTORE DATABASE Getty_Images_US_Inc__MSCRM  WITH RECOVERY
--RESTORE DATABASE Getty_Images_US_Inc_Custom WITH RECOVERY
--RESTORE DATABASE Subscription  WITH RECOVERY

--RESTORE DATABASE Getty_Master WITH RECOVERY
--RESTORE DATABASE RM_Integration  WITH RECOVERY
--EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'DeliveryDB'				,'SQLDISTG0A'		,NULL	,NULL	,0,1,1
--EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'DeliveryArchiveDB'			,'SQLDISTG0A'		,NULL	,NULL	,1,1,1
--EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'EditorialSiteDB'			,'EDSQLG0A'		,NULL	,NULL	,1,1,1
--EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'EventServiceDB'			,'EDSQLG0A'		,NULL	,NULL	,1,1,1


--RESTORE DATABASE DeliveryDB WITH RECOVERY
--RESTORE DATABASE DeliveryArchiveDB  WITH RECOVERY
--RESTORE DATABASE EditorialSiteDB WITH RECOVERY
--RESTORE DATABASE EventServiceDB  WITH RECOVERY



EXECUTE dbaadmin.[dbo].[dbasp_Restore] @dbname = 'DeliveryDB',		@FilePath = '\\SQLDISTG0A\SQLDISTG0A_backup',	@LeaveNORECOVERY = 0, @NoDifRestores = 1, @post_shrink = 1
EXECUTE dbaadmin.[dbo].[dbasp_Restore] @dbname = 'DeliveryArchiveDB',	@FilePath = '\\SQLDISTG0A\SQLDISTG0A_backup',	@LeaveNORECOVERY = 0, @NoDifRestores = 1, @post_shrink = 1
EXECUTE dbaadmin.[dbo].[dbasp_Restore] @dbname = 'EditorialSiteDB',	@FilePath = '\\EDSQLG0A\EDSQLG0A_backup',	@LeaveNORECOVERY = 0, @NoDifRestores = 1, @post_shrink = 1
EXECUTE dbaadmin.[dbo].[dbasp_Restore] @dbname = 'EventServiceDB',	@FilePath = '\\EDSQLG0A\EDSQLG0A_backup',	@LeaveNORECOVERY = 0, @NoDifRestores = 1, @post_shrink = 1





--EXECUTE dbaadmin.[dbo].[dbasp_Restore] @dbname = 'Getty_Images_CRM_GENESYS'	,@FilePath = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_backup',	@LeaveNORECOVERY = 0, @NoDifRestores = 1, @post_shrink = 1
--EXECUTE dbaadmin.[dbo].[dbasp_Restore] @dbname = 'Getty_Images_US_Inc__MSCRM'	,@FilePath = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_backup',	@LeaveNORECOVERY = 0, @NoDifRestores = 1, @post_shrink = 1
EXECUTE dbaadmin.[dbo].[dbasp_Restore] @dbname = 'Getty_Images_US_Inc_Custom'	,@FilePath = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_backup',	@LeaveNORECOVERY = 0, @NoDifRestores = 1, @post_shrink = 1
EXECUTE dbaadmin.[dbo].[dbasp_Restore] @dbname = 'Subscription'			,@FilePath = '\\SEAPSQLRYLINT02\SEAPSQLRYLINT02_backup',	@LeaveNORECOVERY = 0, @NoDifRestores = 1, @post_shrink = 1

EXECUTE dbaadmin.[dbo].[dbasp_Restore] @dbname = 'Getty_Master'			,@FilePath = '\\SEAPSQLRYL0A\SEAPSQLRYL0A_backup',	@LeaveNORECOVERY = 0, @NoDifRestores = 1, @post_shrink = 1
EXECUTE dbaadmin.[dbo].[dbasp_Restore] @dbname = 'RM_Integration'		,@FilePath = '\\SEAPSQLRYL0A\SEAPSQLRYL0A_backup',	@LeaveNORECOVERY = 0, @NoDifRestores = 1, @post_shrink = 1

