CREATE TABLE #filelist_rg(	DBName			SYSNAME NULL,
				LogicalName		NVARCHAR(128) NULL, 
				PhysicalName		NVARCHAR(260) NULL, 
				type			CHAR(1), 
				FileGroupName		NVARCHAR(128) NULL, 
				SIZE			NUMERIC(20,0), 
				MaxSize			NUMERIC(20,0),
				FileId			BIGINT,
				CreateLSN		NUMERIC(25,0),
				DropLSN			NUMERIC(25,0),
				UniqueId		UNIQUEIDENTIFIER,
				ReadOnlyLSN		NUMERIC(25,0),
				ReadWriteLSN		NUMERIC(25,0),
				BackupSizeInBytes	BIGINT,
				SourceBlockSize		INT,
				FileGroupId		INT,
				LogGroupGUID		SYSNAME NULL,
				DifferentialBaseLSN	NUMERIC(25,0),
				DifferentialBaseGUID	UNIQUEIDENTIFIER,
				IsReadOnly		BIT,
				IsPresent		BIT
				)



Declare @cmd nvarchar(4000)


Select @cmd = '-SQL "RESTORE FILELISTONLY FROM DISK = ''\\FRETSQLRYL02\FRETSQLRYL02_backup\post_calc\GETTY_MASTER_db_20130812091113.SQB''"'
INSERT INTO #filelist_rg(LogicalName,PhysicalName,type,FileGroupName,SIZE,MaxSize,FileId,CreateLSN,DropLSN,UniqueId,ReadOnlyLSN,ReadWriteLSN,BackupSizeInBytes,SourceBlockSize,FileGroupId,LogGroupGUID,DifferentialBaseLSN,DifferentialBaseGUID,IsReadOnly,IsPresent)
Exec master.dbo.sqlbackup @cmd
UPDATE #filelist_rg SET DBName = 'GETTY_MASTER' WHERE DBName IS NULL

Select @cmd = '-SQL "RESTORE FILELISTONLY FROM DISK = ''\\FRETSQLRYL02\FRETSQLRYL02_backup\post_calc\RM_Integration_db_20130812090600.SQB''"'
INSERT INTO #filelist_rg(LogicalName,PhysicalName,type,FileGroupName,SIZE,MaxSize,FileId,CreateLSN,DropLSN,UniqueId,ReadOnlyLSN,ReadWriteLSN,BackupSizeInBytes,SourceBlockSize,FileGroupId,LogGroupGUID,DifferentialBaseLSN,DifferentialBaseGUID,IsReadOnly,IsPresent)
Exec master.dbo.sqlbackup @cmd
UPDATE #filelist_rg SET DBName = 'RM_Integration' WHERE DBName IS NULL


Select @cmd = '-SQL "RESTORE FILELISTONLY FROM DISK = ''\\FRETSQLRYL03\FRETSQLRYL03_backup\post_calc\GINS_MASTER_db_20130814045324.SQB''"'
INSERT INTO #filelist_rg(LogicalName,PhysicalName,type,FileGroupName,SIZE,MaxSize,FileId,CreateLSN,DropLSN,UniqueId,ReadOnlyLSN,ReadWriteLSN,BackupSizeInBytes,SourceBlockSize,FileGroupId,LogGroupGUID,DifferentialBaseLSN,DifferentialBaseGUID,IsReadOnly,IsPresent)
Exec master.dbo.sqlbackup @cmd
UPDATE #filelist_rg SET DBName = 'GINS_MASTER' WHERE DBName IS NULL


Select @cmd = '-SQL "RESTORE FILELISTONLY FROM DISK = ''\\FRETSQLRYL03\FRETSQLRYL03_backup\post_calc\GINS_Integration_db_20130814043003.SQB''"'
INSERT INTO #filelist_rg(LogicalName,PhysicalName,type,FileGroupName,SIZE,MaxSize,FileId,CreateLSN,DropLSN,UniqueId,ReadOnlyLSN,ReadWriteLSN,BackupSizeInBytes,SourceBlockSize,FileGroupId,LogGroupGUID,DifferentialBaseLSN,DifferentialBaseGUID,IsReadOnly,IsPresent)
Exec master.dbo.sqlbackup @cmd
UPDATE #filelist_rg SET DBName = 'GINS_Integration' WHERE DBName IS NULL



GO
SELECT		DBName	
		,LogicalName	
		,PhysicalName	
		,type	
		,FileGroupName	
		,CAST(SIZE/POWER(1024.,3) AS NUMERIC(10,2)) SIZE_GB	
		,CAST(MaxSize/POWER(1024.,3) AS NUMERIC(10,2)) MaxSize_GB

FROM		#filelist_rg
ORDER BY	1,4,5,2

SELECT		type
		,SUM(CAST(SIZE/POWER(1024.,3) AS NUMERIC(10,2)))
FROM		#filelist_rg
GROUP BY	type

GO
DROP TABLE #filelist_rg
GO