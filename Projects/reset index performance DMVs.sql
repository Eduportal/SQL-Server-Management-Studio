USE MASTER
GO

DBCC FREEPROCCACHE
GO
DBCC DROPCLEANBUFFERS
GO
DBCC SQLPERF("sys.dm_os_latch_stats",CLEAR);
GO
DBCC SQLPERF("sys.dm_os_wait_stats",CLEAR);
GO
alter database DeliveryDB set offline WITH ROLLBACK IMMEDIATE 
GO
alter database DeliveryDB set online WITH ROLLBACK IMMEDIATE 
GO
exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport
GO