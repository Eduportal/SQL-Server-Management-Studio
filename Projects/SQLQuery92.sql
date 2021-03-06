USE [master]
GO
CREATE DATABASE [SystemCenterReporting] ON 
( Name = 'RepData', FILENAME = N'E:\MSSQL\Data\RepData.mdf' ),
( Name = 'RepLog', FILENAME = N'f:\MSSQL\Log\RepLog.ldf' ),
( Name = 'RepData2', FILENAME = N'E:\MSSQL\Data\REPDATA_2_Data.NDF' )
 FOR ATTACH
GO
USE [master]
GO
CREATE DATABASE [SystemCenterReporting] ON 
( FILENAME = N'E:\MSSQL\Data\RepData.mdf' ),
( FILENAME = N'f:\MSSQL\Log\RepLog.ldf' ),
( FILENAME = N'E:\MSSQL\Data\REPDATA_2_Data.NDF' )
 FOR ATTACH
GO

sp_attach_single_file_db 'SystemCenterReporting','E:\MSSQL\Data\RepData.mdf'

GO

select * from master..sysdatabases
--1073741840

-- SQL Server database suspect - SQL Server database marked suspect

-- How to recover a database marked suspect
GO
sp_configure "Allow updates" , 1

RECONFIGURE WITH OVERRIDE
go

--update master..sysdatabases set status = 32768 where dbid = 9
--update master..sysdatabases set status = 24 where dbid = 9

go

dbcc rebuild_log ('SystemCenterReporting', 'f:\MSSQL\Log\RepLog.ldf')


ALTER DATABASE SystemCenterReporting SET Single_user WITH ROLLBACK IMMEDIATE


use SystemCenterReporting
go 
sp_dboption 'SystemCenterReporting', 'dbo use only', 'false'
go 
dbcc checkdb (SystemCenterReporting, repair_allow_data_loss)
go

dbcc checkdb ('SystemCenterReporting' )

DBCC CHECKDB (SystemCenterReporting, NOINDEX);




 

sp_configure "Allow updates" , 0
RECONFIGURE WITH OVERRIDE

go
