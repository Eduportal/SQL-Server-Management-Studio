
--SET NOCOUNT ON
--DECLARE @TSQL VARCHAR(8000)
--CREATE TABLE #Results (
--	DBName sysname COLLATE SQL_Latin1_General_CP1_CI_AS
--	,[FileName] sysname COLLATE SQL_Latin1_General_CP1_CI_AS
--	,FileType sysname COLLATE SQL_Latin1_General_CP1_CI_AS
--	,Drive char(1) COLLATE SQL_Latin1_General_CP1_CI_AS
--	,UsedData varchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS
--	,TotalDataSize varchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS
--	,Growth VarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS
--	)
	
--CREATE TABLE #DiskInfo (
--	Drive char(1) COLLATE SQL_Latin1_General_CP1_CI_AS primary key
--	,MBFree Float
--	)

--INSERT INTO #DiskInfo
--EXEC master..xp_fixeddrives

--SELECT		*
--		,CAST([dbaadmin].[dbo].[dbaudf_GetFileProperty] (Drive,'Drive','TotalSize') AS FLOAT) /1024/1024 AS [TotalMB]
--		,CAST([dbaadmin].[dbo].[dbaudf_GetFileProperty] (Drive,'Drive','AvailableSpace') AS FLOAT) /1024/1024 AS [AvailableMB]
--		,CAST([dbaadmin].[dbo].[dbaudf_GetFileProperty] (Drive,'Drive','FreeSpace') AS FLOAT) /1024/1024 AS [FreeMB]
--FROM		#DiskInfo



--SET @TSQL =
--'USE [?];
--INSERT #Results(DBName, [FileName], FileType, Drive, UsedData, TotalDataSize, Growth)
--SELECT	DB_Name()
--	,name 
--	,CASE groupid WHEN 1 THEN ''DATA'' WHEN 0 THEN ''LOG'' ELSE ''Other'' END
--	,UPPER(LEFT(filename,1))
--	,CAST(FILEPROPERTY ([name], ''SpaceUsed'')/128.0 as varchar(15)) 
--	,CAST(size/128.0 as varchar(15))
--	,CASE
--		WHEN growth = 0		THEN ''No Growth''
--		WHEN maxsize = 0	THEN ''No Growth''
--		WHEN maxsize = -1	THEN ''Unlimited''
--		WHEN (CAST(maxsize AS BigInt) * (8*1024)/1024.00/1024.00) >= (size/128.0) THEN ''Unlimited''
--		WHEN (CAST(maxsize AS BigInt) * (8*1024)/1024.00/1024.00) - (size/128.0) > T2.MBFree THEN ''Unlimited''
--		ELSE CAST((CAST(maxsize AS BigInt) * (8*1024)/1024/1024)- (size/128.0) AS VarChar(50))
--		END
--FROM sysfiles T1
--JOIN #DiskInfo T2
--ON LEFT(T1.filename,1) COLLATE SQL_Latin1_General_CP1_CI_AS = T2.Drive COLLATE SQL_Latin1_General_CP1_CI_AS'

--EXEC sp_MSForEachDB @TSQL



--SELECT	DBName,
--	[FileName]
--	,FileType
--	,r.Drive
--	,UsedData
--	,TotalDataSize
--	,Growth
--	,MBFree
--FROM	#Results r
--JOIN	#DiskInfo d
--ON	r.Drive = d.Drive


--SELECT		[Drive]
--		,[FileType]
--		,[Used]
--		,[Free]
--		,([Used]*100)/([Used]+[Free]) AS [Pct_Used]
--		,([Adj_Used]*100)/([Adj_Used]+[Free]) AS [Adj_Pct_Used]
--FROM		(
--		SELECT		r.Drive	AS [Drive]
--				,SUM(CAST(TotalDataSize AS FLOAT)) AS [Used]
--				,SUM(CASE Growth
--					WHEN 'No Growth' THEN CAST(0 AS Float)
--					ELSE CAST(TotalDataSize AS FLOAT)
--					END) AS [Adj_Used]
--				,MAX(CAST(MBFree AS Float)) AS [Free]
--				,CASE WHEN MAX(FileType) != MIN(FileType) THEN 'BOTH' ELSE MAX(FileType) END [FileType]
		
--		FROM		(
--				SELECT		*
--				FROM		#Results
--				UNION 
--				select		NULL,NULL,NULL,DriveName COLLATE SQL_Latin1_General_CP1_CI_AS,'0','0','0'
--				From		sys.fn_servershareddrives() T1
--				WHERE		DriveName NOT IN ('a','b','c','d')
--				UNION 	
--				SELECT		NULL,NULL,NULL,Drive COLLATE SQL_Latin1_General_CP1_CI_AS,'0','0','0'
--				FROM		#DiskInfo
--				WHERE		Drive NOT IN ('a','b','c','d')
--					AND	(SELECT COUNT(*) FROM sys.fn_servershareddrives()) = 0
--				) r
--		JOIN		#DiskInfo d
--			ON	r.Drive = d.Drive
--		GROUP BY	r.Drive	
--		) DriveData



--GO
--DROP TABLE #Results
--GO
--DROP TABLE #DiskInfo
--GO

----SELECT	name,maxsize, (CAST(maxsize AS BigInt) * (8*1024)/1024.00/1024.00) ,(size/128.0)
----SELECT *
----FROM	assetkeyword..sysfiles



--SELECT * FROM sys.dm_io_cluster_shared_drives
--GO


SET NOCOUNT ON
DECLARE @TSQL VARCHAR(8000)
DECLARE @Factor Float
CREATE TABLE #Results (
	DBName sysname COLLATE SQL_Latin1_General_CP1_CI_AS
	,[FileName] sysname COLLATE SQL_Latin1_General_CP1_CI_AS
	,FileType sysname COLLATE SQL_Latin1_General_CP1_CI_AS
	,Drive char(1) COLLATE SQL_Latin1_General_CP1_CI_AS
	,UsedData FLOAT
	,TotalDataSize FLOAT
	,Growth VarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS
	)

SELECT * INTO #DiskInfo FROM [dbaadmin].[dbo].[dbaudf_ListDrives]() WHERE IsReady = 'True'

SET @Factor =	1
SET @Factor =	@Factor		--B
		/1024		--KB
		/1024		--MB
		--/1024		--GB
		--/1024		--TB

SET @TSQL =
'USE [?];
INSERT #Results(DBName, [FileName], FileType, Drive, UsedData, TotalDataSize, Growth)
SELECT	DB_Name()
	,name 
	,CASE groupid WHEN 1 THEN ''DATA'' WHEN 0 THEN ''LOG'' ELSE ''Other'' END
	,UPPER(LEFT(filename,1))
	,CAST(FILEPROPERTY ([name], ''SpaceUsed'') AS Float)*(8*1024)
	,CAST(size AS Float)*(8*1024)
	,CASE
		WHEN growth = 0		THEN ''No Growth''
		WHEN maxsize = 0	THEN ''No Growth''
		WHEN maxsize = -1	THEN ''Unlimited''
		WHEN maxsize >= size	THEN ''Unlimited''
		WHEN CAST(maxsize-size AS Float)*(8*1024) > T2.[FreeSpace] THEN ''Unlimited''
		ELSE CAST(CAST(maxsize-size AS Float)*(8*1024) AS VarChar(50))
		END
FROM sysfiles T1
JOIN #DiskInfo T2
ON LEFT(T1.filename,1) COLLATE SQL_Latin1_General_CP1_CI_AS = T2.DriveLetter COLLATE SQL_Latin1_General_CP1_CI_AS'

EXEC sp_MSForEachDB @TSQL



--SELECT		[DriveLetter]
--		,COALESCE(CASE 
--		 WHEN MAX(FileType) != MIN(FileType) 
--		 THEN 'BOTH' 
--		 ELSE MAX(FileType) 
--		 END,'NONE')				AS [FileType]
--		,MAX(FreeSpace_MB)			AS [Free_MB]
--		,SUM(CapedDataSize_MB)			AS [Caped_MB]
		
--		,COALESCE(SUM(TotalDataSize_MB),0)	AS [Used_MB]
--		,COALESCE(SUM(TotalDataSize_MB)
--		 -SUM(CapedDataSize_MB),0)		AS [adj_Used_MB]
--		,MAX(TotalSize_MB)			AS [Dive_MB]
--		,MAX(TotalSize_MB)
--		 -SUM(CapedDataSize_MB)			AS [Adj_Dive_MB]
--		,COALESCE(SUM(TotalDataSize_MB)
--		 *100/MAX(TotalSize_MB)
		 
--		 ,(MAX([TotalSize_MB])
--		 -MAX([FreeSpace_MB]))*100
--		 /MAX([TotalSize_MB])
		 
--		 ,0)					AS [Pct_Used]
		 
--		,COALESCE((SUM(TotalDataSize_MB)
--		 -SUM(CapedDataSize_MB))
--		 *100/(MAX(TotalSize_MB)
--		 -SUM(CapedDataSize_MB))
		 
--		 ,(MAX([TotalSize_MB])
--		 -MAX([FreeSpace_MB]))*100
--		 /MAX([TotalSize_MB])
		 
--		 ,0)					AS [Adj_Pct_Used]


SELECT		[DriveLetter]
		,COALESCE(CASE 
		 WHEN MAX(FileType) != MIN(FileType) 
		 THEN 'BOTH' 
		 ELSE MAX(FileType) 
		 END,'NONE')				AS [FileType]
		
		,MAX(TotalSize_MB)			AS [Dive_MB]
		,MAX(FreeSpace_MB)			AS [Free_MB]
		,MAX([TotalSize_MB])
		 -MAX([FreeSpace_MB])			AS [Used_MB]
		
		,COALESCE(SUM(CapedDataSize_MB),0)	AS [Caped_MB]
		
		,COALESCE(SUM(TotalDataSize_MB),0)	AS [DB_Used_MB]
		
		
		,COALESCE(SUM(TotalDataSize_MB),0)	
		 -COALESCE(SUM(UsedData_MB),0)		AS [DB_Shrinkable_MB]
		
		,MAX(TotalSize_MB)
		 -COALESCE(SUM(CapedDataSize_MB),0)	AS [Adj_Dive_MB]

		,COALESCE(SUM(TotalDataSize_MB),0)
		 -COALESCE(SUM(CapedDataSize_MB),0)	AS [adj_DB_Used_MB]

		
		,100 - (MAX(FreeSpace_MB)
		 *100/MAX(TotalSize_MB))		AS [Pct_Used]
		

		,100 - (
		MAX(FreeSpace_MB)*100/
		(
		MAX(TotalSize_MB)
		 -COALESCE(SUM(CapedDataSize_MB),0)
		))					AS [Adj_Pct_Used]
		




FROM		(
		SELECT		d.DriveLetter
				,d.TotalSize	
				,d.TotalSize*@Factor		[TotalSize_MB]
				,d.AvailableSpace*@Factor	[AvailableSpace_MB]	
				,d.FreeSpace*@Factor		[FreeSpace_MB]	
				,d.DriveType	
				,d.SerialNumber	
				,d.FileSystem	
				,d.IsReady
				,CASE WHEN s.DriveName IS NULL THEN 'False' ELSE 'True' END AS [Clstrd]
				,d.ShareName	
				,d.VolumeName	
				,d.[Path]
				,d.RootFolder	
				,r.DBName	
				,r.FileName	
				,r.FileType	
				,r.UsedData*@Factor		[UsedData_MB]	
				,r.TotalDataSize*@Factor	[TotalDataSize_MB]
				,CASE r.Growth
					WHEN 'No Growth' 
					THEN r.TotalDataSize*@Factor
					ELSE 0
					END			[CapedDataSize_MB]	
				,r.Growth	
				
		FROM		#DiskInfo d
		LEFT JOIN	#Results r
			ON	r.Drive = d.DriveLetter
		LEFT JOIN	sys.fn_servershareddrives() s
			ON	s.DriveName COLLATE SQL_Latin1_General_CP1_CI_AS = d.DriveLetter COLLATE SQL_Latin1_General_CP1_CI_AS
		) RawData
GROUP BY	DriveLetter
		
SELECT * FROM #DiskInfo
		

--SELECT		[Drive]
--		,[FileType]
--		,[Used]
--		,[Free]
--		,([Used]*100)/([Used]+[Free]) AS [Pct_Used]
--		,([Adj_Used]*100)/([Adj_Used]+[Free]) AS [Adj_Pct_Used]
--FROM		(
--		SELECT		r.Drive	AS [Drive]
--				,SUM(CAST(TotalDataSize AS FLOAT)) AS [Used]
--				,SUM(CASE Growth
--					WHEN 'No Growth' THEN CAST(0 AS Float)
--					ELSE CAST(TotalDataSize AS FLOAT)
--					END) AS [Adj_Used]
--				,MAX(CAST(MBFree AS Float)) AS [Free]
--				,CASE WHEN MAX(FileType) != MIN(FileType) THEN 'BOTH' ELSE MAX(FileType) END [FileType]
		
--		FROM		(
--				SELECT		*
--				FROM		#Results
--				UNION 
--				select		NULL,NULL,NULL,DriveName COLLATE SQL_Latin1_General_CP1_CI_AS,'0','0','0'
--				From		sys.fn_servershareddrives() T1
--				WHERE		DriveName NOT IN ('a','b','c','d')
--				UNION 	
--				SELECT		NULL,NULL,NULL,Drive COLLATE SQL_Latin1_General_CP1_CI_AS,'0','0','0'
--				FROM		#DiskInfo
--				WHERE		Drive NOT IN ('a','b','c','d')
--					AND	(SELECT COUNT(*) FROM sys.fn_servershareddrives()) = 0
--				) r
--		JOIN		#DiskInfo d
--			ON	r.Drive = d.Drive
--		GROUP BY	r.Drive	
--		) DriveData



GO
DROP TABLE #Results
GO
DROP TABLE #DiskInfo
GO




--Used_MB		Caped_MB	Free_MB		Pct_Used		Pct_Used_Adjstd

--278895.6875	266419.0625	29189.5625	955.463746673147	-5.25930586204498