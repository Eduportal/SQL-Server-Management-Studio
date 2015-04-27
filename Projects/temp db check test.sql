
;WITH [DBFileSummary] AS
(
SELECT		DB_NAME(database_id) AS [DatabaseName]
		,type_desc AS [DeviceType]
		,CASE 
			WHEN DB_NAME(database_id) IN ('master','model','msdb') THEN 'System'
			WHEN DB_NAME(database_id) IN ('tempdb') THEN 'Temp'
			WHEN DB_NAME(database_id) IN ('dbaadmin','dbaperf','deplinfo','dbacentral','gears','deplcontrol') THEN 'Operations'
			ELSE 'User' END AS [DatabaseType]
		,UPPER(LEFT(physical_name,1)) AS [Drive]
		,count(*) AS [Devices]
		,sum((size*8)/1024.0/1024.0) AS [Size]
FROM		sys.master_files
GROUP BY	DB_NAME(database_id)
		,type_desc
		,CASE 
			WHEN DB_NAME(database_id) IN ('master','model','msdb') THEN 'System'
			WHEN DB_NAME(database_id) IN ('tempdb') THEN 'Temp'
			WHEN DB_NAME(database_id) IN ('dbaadmin','dbaperf','deplinfo','dbacentral','gears','deplcontrol') THEN 'Operations'
			ELSE 'User' END
		,UPPER(LEFT(physical_name,1))
)


SELECT		T2.DriveLetter
			,T2.Path
			,STUFF((SELECT	', ' + QUOTENAME([DatabaseName]) FROM (SELECT DISTINCT [DatabaseName] FROM [DBFileSummary] WHERE [Drive] IN (SELECT DISTINCT [Drive] FROM [DBFileSummary] WHERE [DatabaseType] = 'Temp' AND [Drive] IN ( SELECT DISTINCT [Drive] FROM [DBFileSummary] WHERE [DatabaseType] != 'Temp'))) T1 FOR XML PATH('')), 1, 2, '') AS [DatabaseNames]
			,T2.TotalSize/1024.0/1024.0/1024.0 [TotalSize]
			,T2.FreeSpace/1024.0/1024.0/1024.0 [FreeSpace]
			,(T2.FreeSpace*100.0)/T2.TotalSize [PercentFree]
			,T2.FileSystem
			,T2.SerialNumber
			,T2.FileSystem
			,T2.VolumeName
FROM dbaadmin.dbo.dbaudf_ListDrives() T2
WHERE T2.DriveLetter IN (SELECT DISTINCT [Drive] FROM [DBFileSummary] WHERE [DatabaseType] = 'Temp' AND [Drive] IN ( SELECT DISTINCT [Drive] FROM [DBFileSummary] WHERE [DatabaseType] != 'Temp'))

select * From sysobjects where name like '%file%'

SELECT		STUFF((SELECT	', ' + QUOTENAME([DatabaseName]) 
FROM		(
			SELECT		DISTINCT
						upper(db_name(dbid)) [DatabaseName]
			FROM		sysaltfiles
			WHERE		db_name(dbid) != 'TempDB'
				AND		left(filename,1) IN (SELECT left(filename,1) From sysaltfiles WHERE db_name(dbid) = 'TempDB')
			) T1 FOR XML PATH('')), 1, 2, '') AS [DatabaseNames]
	
	
(select distinct upper(db_name(dbid)),upper(left(filename,1)) From sysaltfiles) T1