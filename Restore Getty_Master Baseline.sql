


--exec	dbaadmin.dbo.dbasp_ShrinkAllLargeFiles
--			@FileTypes = 'BOTH'
--			,@DoItNow = 1
GO 
IF DB_ID('Getty_Master') IS NOT NULL
BEGIN
	IF DATABASEPROPERTYEX ('Getty_Master','status') <> 'RESTORING'
		ALTER DATABASE [Getty_Master] SET OFFLINE WITH ROLLBACK IMMEDIATE;
		ALTER DATABASE [Getty_Master] SET ONLINE WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [Getty_Master];
END
 
DELETE msdb.dbo.restorefile WHERE restore_history_id IN (SELECT restore_history_id from msdb.dbo.restorehistory WHERE destination_database_name = 'Getty_Master')
DELETE msdb.dbo.restorefilegroup WHERE restore_history_id IN (SELECT restore_history_id from msdb.dbo.restorehistory WHERE destination_database_name = 'Getty_Master')
DELETE msdb.dbo.restorehistory WHERE destination_database_name = 'Getty_Master'
EXEC [msdb].[dbo].[sp_delete_database_backuphistory] 'Getty_Master'
 
 
DECLARE @FilesRestored INT = 0
 
 
RAISERROR ('Restoring File "Getty_Master_DB_20150323100553_SET_[0-9][0-9]_OF_[0-9][0-9].cBAK"',-1,-1) WITH NOWAIT
RESTORE DATABASE [Getty_Master] 
FROM    DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_01_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_02_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_03_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_04_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_05_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_06_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_07_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_08_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_09_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_10_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_11_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_12_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_13_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_14_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_15_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_16_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_17_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_18_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_19_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_20_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_21_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_22_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_23_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_24_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_25_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_26_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_27_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_28_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_29_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_30_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_31_OF_32.cBAK'
       ,DISK = '\\SEAPSQLRYL0A\save\Getty_Master_DB_20150323100553_SET_32_OF_32.cBAK'
 
  WITH  NORECOVERY
        ,REPLACE
        ,MOVE 'dv_installappData03' TO 'E:\Data2\Getty_Master_3.ndf'
        ,MOVE 'dv_installappData04' TO 'E:\Data4\Getty_Master_2.ndf'
        ,MOVE 'dv_installappData2' TO 'E:\Data3\Getty_Master_1.NDF'
        ,MOVE 'dv_installapplData' TO 'E:\Data4\Getty_Master.MDF'
        ,MOVE 'getty_master05' TO 'E:\Data3\Getty_Master_4.ndf'
        ,MOVE 'getty_master06' TO 'E:\Data5\Getty_Master_5.ndf'
        ,MOVE 'lg_installapplLog' TO 'F:\Log\Getty_Master_6.LDF'
        ,STATS=1


SET @FilesRestored = @FilesRestored + 1
 
RESTORE DATABASE [Getty_Master] WITH RECOVERY
SELECT @FilesRestored
IF @FilesRestored > 0
	RAISERROR('DATABASE WAS UPDATED',-1,-1) WITH NOWAIT
ELSE
	RAISERROR('DATABASE WAS NOT UPDATED',16,1) WITH NOWAIT
GO
 
 
