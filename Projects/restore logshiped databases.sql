

RESTORE DATABASE WCDS
FROM DISK = 'G:\Backup\LogShip\WCDS\WCDS_db_20121123220536.cbak'
WITH NORECOVERY,
REPLACE,
MOVE 'WCDSData' to 'E:\MSSQL\Data\WCDS.mdf',
MOVE 'WCDSData02' to 'E:\MSSQL\Data\WCDSData02.ndf',
MOVE 'WCDSLog' to 'F:\MSSQL\Log\WCDS_log.LDF',
stats
go

RESTORE DATABASE WCDS
FROM DISK = 'G:\Backup\LogShip\WCDS\WCDS_dfntl_20121124000322.cDIF'
WITH NORECOVERY
GO







RESTORE DATABASE Product
FROM DISK = 'G:\Backup\LogShip\Product\Product_db_20121123211051.cBAK'
WITH NORECOVERY,
REPLACE,
MOVE 'ProductData' to 'E:\MSSQL\Data\Product.MDF',
MOVE 'ProductLog' to 'F:\MSSQL\Log\Product_log.LDF',
stats
go


RESTORE DATABASE Product
FROM DISK = 'G:\Backup\LogShip\Product\Product_dfntl_20121123211931.cDIF'
WITH NORECOVERY




RESTORE DATABASE RightsPrice
FROM DISK = 'G:\Backup\LogShip\RightsPrice\RightsPrice_db_20121123211932.cBAK'
WITH NORECOVERY,
REPLACE,
MOVE 'RightsPriceData' to 'E:\MSSQL\Data\\RightsPrice.MDF',
MOVE 'RightsPriceLog' to 'F:\MSSQL\Log\\RightsPrice_log.LDF',
stats
go


RESTORE DATABASE RightsPrice
FROM DISK = 'G:\Backup\LogShip\RightsPrice\RightsPrice_dfntl_20121123214049.cDIF'
WITH NORECOVERY


RESTORE DATABASE AssetUsage_Archive
FROM DISK = 'G:\Backup\LogShip\AssetUsage_Archive\AssetUsage_Archive_db_20121123210521.cBAK'
WITH NORECOVERY,
REPLACE,
MOVE 'AssetUsage' to 'E:\MSSQL\Data\AssetUsage_Archive.MDF',
MOVE 'AssetUsage_log' to 'F:\MSSQL\Log\AssetUsage_Archive_log.LDF',
stats
go

RESTORE DATABASE AssetUsage_Archive
FROM DISK = 'G:\Backup\LogShip\AssetUsage_Archive\AssetUsage_Archive_dfntl_20121123211007.cDIF'
WITH NORECOVERY







EXECUTE [dbaadmin].[dbo].[dbasp_autorestore] 
   @full_path ='\\seaplogsql01\SEAPLOGSQL01_backup\LogShip\WCDS'
  ,@dbname = 'WCDS'
  ,@datapath = 'E:\MSSQL\Data\'
  ,@logpath = 'F:\MSSQL\Log\'
  ,@differential_flag = 'Y'
  ,@db_norecovOnly_flag = 'Y'
  ,@Script_out='Y'
  

