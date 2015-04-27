--Use Master
--go
 


--exec dbaadmin.dbo.dbasp_BackupFile_mover_trusted @target_path = '\\SEAPSQLDPLY02\SEAPSQLDPLY02_restore\EF',
--				@source_server = '\\seapsqldist0a',
--				@source_path = 'seapsqldist0a_backup',
--				@backupname = 'DeliveryDb_db',
--				@retry_limit = 3,
--				@backup_hh_period = '300'


--GO


RESTORE DATABASE DeliveryDb
FROM DISK = '\\SEAPSQLDPLY02\SEAPSQLDPLY02_restore\EF\DeliveryDb_db_20130614033634.cBAK'
WITH REPLACE,
MOVE 'DeliveryDb_data' to 'd:\mssql\data\DeliveryDb_data.mdf',
MOVE 'DeliveryDB_data_2' to 'd:\mssql\data\DeliveryDB_data_2.ndf',
MOVE 'DeliveryDB_data_5' to 'd:\mssql\data\DeliveryDB_data_5.ndf',
MOVE 'DeliveryDb_log' to 'd:\mssql\log\DeliveryDb_log.ldf',
MOVE 'DeliveryDb_log2' to 'd:\mssql\log\DeliveryDb_log2.ldf',
stats=1,
NORECOVERY
GO

RESTORE DATABASE DeliveryDb
WITH RECOVERY
GO 