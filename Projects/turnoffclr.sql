
--exec sp_configure 'clr enabled' , 0
--GO
--RECONFIGURE WITH OVERRIDE
--GO
dbcc freeproccache

--DBCC FREESYSTEMCACHE ('all')

--DBCC FREESESSIONCACHE 