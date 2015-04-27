

-- Starting in SQL Server 2012, an extra column was added to LogInfo, named RecoveryUnitId
-- Need to accomodate SQL Server 2012 (version 11.0)
DECLARE		@versionString			VARCHAR(20)
		,@serverVersion			DECIMAL(10,5)
		,@sqlServer2012Version		DECIMAL(10,5)
 
CREATE TABLE	#VLFInfo
			(
			RecoveryUnitID	int NULL
			,FileID		int NULL
			,FileSize	bigint NULL
			,StartOffset	bigint NULL
			,FSeqNo		int NULL
			,[Status]	int NULL
			,Parity		tinyint NULL
			,CreateLSN	numeric(25,0) NULL
			)

CREATE TABLE	#VLFCountResults
			(
			DatabaseName	sysname
			,VLFCount	int
			,name		sysname
			,size		int
			);

SELECT		@versionString		= CAST(SERVERPROPERTY('productversion') AS VARCHAR(20))
		,@serverVersion		= CAST(LEFT(@versionString,CHARINDEX('.', @versionString)) AS DECIMAL(10,5))
		,@sqlServer2012Version	= 11.0 -- SQL Server 2012


-- Get VLF Counts for all databases on the instance (Query 18) (VLF Counts)
IF(@serverVersion >= @sqlServer2012Version)
    BEGIN
        -- Use the new version of the table  
	EXEC sp_MSforeachdb N'Use [?]; 

				INSERT INTO #VLFInfo (RecoveryUnitID,FileID,FileSize,StartOffset,FSeqNo,[Status],Parity,CreateLSN)
				EXEC sp_executesql N''DBCC LOGINFO([?])''; 
	 
				INSERT INTO #VLFCountResults 
				SELECT	DB_NAME()
					, COUNT(*) 
					,T2.name Name
					, T2.size / 128 Size
				FROM #VLFInfo T1
				JOIN sys.database_files T2
				  ON	T1.FileID = T2.file_id
				GROUP BY T2.Name, T2.Size; 

				TRUNCATE TABLE #VLFInfo;'


    END  
ELSE  
    BEGIN
        -- Use the old version of the table
	EXEC sp_MSforeachdb N'Use [?]; 

				INSERT INTO #VLFInfo (FileID,FileSize,StartOffset,FSeqNo,[Status],Parity,CreateLSN)
				EXEC sp_executesql N''DBCC LOGINFO([?])''; 
	 
				INSERT INTO #VLFCountResults 
				SELECT	DB_NAME()
					, COUNT(*) 
					,T2.name Name
					, T2.size / 128 Size
				FROM #VLFInfo T1
				JOIN sys.database_files T2
				  ON	T1.FileID = T2.file_id
				GROUP BY T2.Name, T2.Size; 

				TRUNCATE TABLE #VLFInfo;'

    END
;

SELECT DatabaseName, VLFCount ,name, size 
FROM #VLFCountResults
ORDER BY VLFCount DESC;
	 
DROP TABLE #VLFInfo;
DROP TABLE #VLFCountResults;

-- High VLF counts can affect write performance 
-- and they can make database restores and recovery take much longer


/*


DeliveryArchiveDb	1170	DeliveryArchiveDb_log	36438
DeliveryDb		283	DeliveryDb_log		8929
DeliveryDb		272	DeliveryDb_log2		8704
master			219	mastlog			739
DataLogDb		190	DataLogDb_Log		505
dbaperf			163	dbaperf_log		235
IngestionDb		139	IngestionDb_log		4219
msdb			127	MSDBLog			90
dbaadmin		71	dbaadmin_log		26
model			24	modellog		6
WCDS_STS_Lite		13	WCDSLog			3
SQLdeploy		12	SQLdeploy_log		4
tempdb			8	templog			1024
AdminDb			4	AdminDb_Log		3
FeedsDb			4	FeedsDb_log		1



*/

--GO
--USE []
--GO
--DECLARE @DBName SYSNAME
--SET	@DBName	= DB_NAME()
--exec dbaadmin.dbo.dbasp_backup @DBName = @DBName, @Mode = 'BL'
--GO

--DECLARE @file_name sysname,
--@file_size int,
--@file_growth int,
--@shrink_command nvarchar(max),
--@alter_command nvarchar(max)

----SELECT @file_name = name,
----@file_size = (size / 128)
----FROM sys.database_files
----WHERE type_desc = 'log'

--SELECT @file_name = 'DeliveryDb_log'	
----SELECT @file_name = 'DeliveryDb_log2'


--SELECT @shrink_command = 'DBCC SHRINKFILE (N''' + @file_name + ''' , 0, TRUNCATEONLY)'
--PRINT @shrink_command
--EXEC sp_executesql @shrink_command

--SELECT @shrink_command = 'DBCC SHRINKFILE (N''' + @file_name + ''' , 0)'
--PRINT @shrink_command
--EXEC sp_executesql @shrink_command

--SELECT @alter_command = 'ALTER DATABASE [' + db_name() + '] MODIFY FILE (NAME = N''' + @file_name + ''', SIZE = ' + CAST(@file_size AS nvarchar) + 'MB)'
--PRINT @alter_command
--EXEC sp_executesql @alter_command



--DBCC SHRINKFILE (N'Getty_Images_US_Inc__MSCRM_log' , 0, TRUNCATEONLY)

--DBCC SHRINKFILE (N'Getty_Images_US_Inc__MSCRM_log' , 0, NOTRUNCATE)

--DBCC SHRINKFILE (N'Getty_Images_US_Inc__MSCRM_log' , 0, TRUNCATEONLY)

--DBCC SHRINKFILE (N'Getty_Images_US_Inc__MSCRM_log' , 0, NOTRUNCATE)

--ALTER DATABASE [Getty_Images_US_Inc__MSCRM] MODIFY FILE (NAME = N'Getty_Images_US_Inc__MSCRM_log', SIZE = 60000MB)



--DeliveryDb_log		8929
--DeliveryDb_log2		8704


--DBCC SHRINKFILE (N'DeliveryDb_log' , 0, TRUNCATEONLY)

--DBCC SHRINKFILE (N'DeliveryDb_log' , 0, NOTRUNCATE)

--DBCC SHRINKFILE (N'DeliveryDb_log' , 0, TRUNCATEONLY)

--DBCC SHRINKFILE (N'DeliveryDb_log' , 0, NOTRUNCATE)

--ALTER DATABASE [DeliveryDB] MODIFY FILE (NAME = N'DeliveryDb_log', SIZE = 8929MB)


--DBCC SHRINKFILE (N'DeliveryDb_log2' , 0, TRUNCATEONLY)

--DBCC SHRINKFILE (N'DeliveryDb_log2' , 0, NOTRUNCATE)

--DBCC SHRINKFILE (N'DeliveryDb_log2' , 0, TRUNCATEONLY)

--DBCC SHRINKFILE (N'DeliveryDb_log2' , 0, NOTRUNCATE)

--ALTER DATABASE [DeliveryDB] MODIFY FILE (NAME = N'DeliveryDb_log2', SIZE = 8704MB)










