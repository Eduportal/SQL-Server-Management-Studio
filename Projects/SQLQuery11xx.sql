--DROP TABLE #DriveList
--GO
--CREATE TABLE #DriveList ([Drive] CHAR(1),[MBFree] Float)
--INSERT INTO #DriveList
--exec xp_fixeddrives

--SELECT		DISTINCT
--			upper(db_name(T1.dbid)) [DatabaseName]
--			,upper(left(T1.filename,1)) [Drive]
--			,(SELECT [MBFree]/1024.0 FROM #DriveList WHERE [Drive] = left(T1.filename,1)) [GBFreeSpace]
--FROM		sysaltfiles T1
--WHERE		db_name(T1.dbid) != 'TempDB'
--	AND		left(T1.filename,1) IN (SELECT left(filename,1) From sysaltfiles WHERE db_name(dbid) = 'TempDB')




IF LEFT(CAST(convert(sysname, serverproperty('ProductVersion')) AS VarChar(255)),1) != '8'
BEGIN



SELECT
user_object_perc = CONVERT(DECIMAL(6,3), u*100.0/(u+i+v+f)),
internal_object_perc = CONVERT(DECIMAL(6,3), i*100.0/(u+i+v+f)),
version_store_perc = CONVERT(DECIMAL(6,3), v*100.0/(u+i+v+f)),
free_space_perc = CONVERT(DECIMAL(6,3), f*100.0/(u+i+v+f)),
[total] = (u+i+v+f)
FROM (
SELECT
u = SUM(user_object_reserved_page_count)*8,
i = SUM(internal_object_reserved_page_count)*8,
v = SUM(version_store_reserved_page_count)*8,
f = SUM(unallocated_extent_page_count)*8
FROM
sys.dm_db_file_space_usage
) x;









END