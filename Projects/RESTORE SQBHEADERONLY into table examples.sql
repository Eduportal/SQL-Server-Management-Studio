
IF OBJECT_ID('tempdb..#headerlist')	IS NOT NULL	
	DROP TABLE #headerlist		
CREATE TABLE #headerlist		([id] INT IDENTITY PRIMARY KEY, [Data] VarChar(max) NULL)

DECLARE		@Table		table
		(
		BackupName		nvarchar(128), 
		BackupDescription	nvarchar(255) ,
		BackupType		smallint ,
		ExpirationDate		datetime ,
		Compressed		bit ,
		Position		smallint ,
		DeviceType		tinyint ,
		UserName		nvarchar(128) ,
		ServerName		nvarchar(128) ,
		DatabaseName		nvarchar(128) ,
		DatabaseVersion		int ,
		DatabaseCreationDate	datetime ,
		BackupSize		numeric(20,0) ,
		FirstLSN		numeric(25,0) ,
		LastLSN			numeric(25,0) ,
		CheckpointLSN		numeric(25,0) ,
		DatabaseBackupLSN	numeric(25,0) ,
		BackupStartDate		datetime ,
		BackupFinishDate	datetime ,
		SortOrder		smallint ,
		CodePage		smallint ,
		UnicodeLocaleId		int ,
		UnicodeComparisonStyle	int ,
		CompatibilityLevel	tinyint ,
		SoftwareVendorId	int ,
		SoftwareVersionMajor	int ,
		SoftwareVersionMinor	int ,
		SoftwareVersionBuild	int ,
		MachineName		nvarchar(128) ,
		Flags			int ,
		BindingID		uniqueidentifier ,
		RecoveryForkID		uniqueidentifier ,
		Collation		nvarchar(128) ,
		FamilyGUID		uniqueidentifier ,
		HasBulkLoggedData	bit ,
		IsSnapshot		bit ,
		IsReadOnly		bit ,
		IsSingleUser		bit ,
		HasBackupChecksums	bit ,
		IsDamaged		bit ,
		BeginsLogChain		bit ,
		HasIncompleteMetaData	bit ,
		IsForceOffline		bit ,
		IsCopyOnly		bit ,
		FirstRecoveryForkID	uniqueidentifier ,
		ForkPointLSN		numeric(25,0) NULL,
		RecoveryModel		nvarchar(60) ,
		DifferentialBaseLSN	numeric(25,0) NULL,
		DifferentialBaseGUID	uniqueidentifier ,
		BackupTypeDescription	nvarchar(60) ,
		BackupSetGUID		uniqueidentifier NULL ,
		CompressedBackupSize	bigint NULL,
		containment		bit
		)

DECLARE		@FileName	VarChar(max)


SET		@FileName = '\\SEAPSQLDPLY01\SEAPSQLDPLY01_backup\test_destination\Done\Getty_Master_db_20130822163737_set_01_of_32.SQB'

INSERT INTO #headerlist
EXEC ('Exec master.dbo.sqlbackup ''-SQL "RESTORE SQBHEADERONLY FROM DISK = N'''''+@FileName+''''' WITH SINGLERESULTSET"''')


--EXEC('RESTORE HEADERONLY FROM DISK = N''\\SEAPSDTSQLB\SEAPSDTSQLB$B_backup\StackFactors_db_20130927170211.cBAK''')



;WITH		HeaderData
		AS
		(
		SELECT		dbaadmin.dbo.dbaudf_ReturnPart(STUFF([Data],CHARINDEX(':',[Data]),1,'|'),1) [Param]
				,dbaadmin.dbo.dbaudf_ReturnPart(STUFF([Data],CHARINDEX(':',[Data]),1,'|'),2) [Value]
		FROM		#headerlist
		WHERE		nullif([Data],'') IS NOT NULL
			AND	[ID] > 1
		)
		,SingleRecord
		AS
		(
		SELECT		 (SELECT LTRIM(RTRIM([Value])) FROM [HeaderData] WHERE [Param] = 'Backup group ID') [Backup group ID]
				,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE((SELECT LTRIM(RTRIM([Value])) FROM [HeaderData] WHERE [Param] = 'File number'),' of ','|'),1) [SetNumber]
				,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE((SELECT LTRIM(RTRIM([Value])) FROM [HeaderData] WHERE [Param] = 'File number'),' of ','|'),2) [SetSize]
				,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE((SELECT LTRIM(RTRIM([Value])) FROM [HeaderData] WHERE [Param] = 'Backup type'),' ','|'),1) [BackupType]
				,(SELECT LTRIM(RTRIM([Value])) FROM [HeaderData] WHERE [Param] = 'Native backup size') [BackupSize]
				,(SELECT LTRIM(RTRIM([Value])) FROM [HeaderData] WHERE [Param] = 'Database size') [Database size]
				,(SELECT LTRIM(RTRIM([Value])) FROM [HeaderData] WHERE [Param] = 'Backup start') [BackupStartDate]
				,(SELECT LTRIM(RTRIM([Value])) FROM [HeaderData] WHERE [Param] = 'Backup end') [BackupFinishDate]
				,(SELECT LTRIM(RTRIM([Value])) FROM [HeaderData] WHERE [Param] = 'Server name') [ServerName]
				,(SELECT LTRIM(RTRIM([Value])) FROM [HeaderData] WHERE [Param] = 'Database name') [DatabaseName]
				,(SELECT LTRIM(RTRIM([Value])) FROM [HeaderData] WHERE [Param] = 'First LSN') [FirstLSN]
				,(SELECT LTRIM(RTRIM([Value])) FROM [HeaderData] WHERE [Param] = 'Last LSN') [LastLSN]
				,(SELECT LTRIM(RTRIM([Value])) FROM [HeaderData] WHERE [Param] = 'Checkpoint LSN') [CheckpointLSN]
				,(SELECT LTRIM(RTRIM([Value])) FROM [HeaderData] WHERE [Param] = 'Database backup LSN') [DatabaseBackupLSN]
		)

INSERT INTO @TABLE 
(
BackupType	
,Compressed	
,ServerName	
,DatabaseName	
,BackupSize	
,FirstLSN	
,LastLSN	
,CheckpointLSN	
,DatabaseBackupLSN	
,BackupStartDate	
,BackupFinishDate
)
SELECT		[BackupType]
		,1 [Compressed]
		,[ServerName]
		,[DatabaseName]

		,CASE RIGHT([BackupSize],2)
			WHEN 'TB' THEN CAST(LEFT([BackupSize],LEN([BackupSize])-3) AS FLOAT) * POWER(1024.0,4)
			WHEN 'GB' THEN CAST(LEFT([BackupSize],LEN([BackupSize])-3) AS FLOAT) * POWER(1024.0,3)
			WHEN 'MB' THEN CAST(LEFT([BackupSize],LEN([BackupSize])-3) AS FLOAT) * POWER(1024.0,2)
			WHEN 'KB' THEN CAST(LEFT([BackupSize],LEN([BackupSize])-3) AS FLOAT) * POWER(1024.0,1)
			ELSE [BackupSize]
			END [BackupSize]

		,[FirstLSN]
		,[LastLSN]
		,[CheckpointLSN]
		,[DatabaseBackupLSN]
		,CAST(STUFF([BackupStartDate],1,CHARINDEX(',',[BackupStartDate]),'') AS DATETIME) [BackupStartDate]
		,CAST(STUFF([BackupFinishDate],1,CHARINDEX(',',[BackupFinishDate]),'') AS DATETIME) [BackupFinishDate]
FROM		SingleRecord


SET		@FileName = '\\SEAPSDTSQLB\SEAPSDTSQLB$B_backup\StackFactors_db_20130927170211.cBAK'

INSERT INTO @Table 
(
BackupName		
,BackupDescription	
,BackupType		
,ExpirationDate		
,Compressed		
,Position		
,DeviceType		
,UserName		
,ServerName		
,DatabaseName		
,DatabaseVersion		
,DatabaseCreationDate	
,BackupSize		
,FirstLSN		
,LastLSN			
,CheckpointLSN		
,DatabaseBackupLSN	
,BackupStartDate		
,BackupFinishDate	
,SortOrder		
,CodePage		
,UnicodeLocaleId		
,UnicodeComparisonStyle	
,CompatibilityLevel	
,SoftwareVendorId	
,SoftwareVersionMajor	
,SoftwareVersionMinor	
,SoftwareVersionBuild	
,MachineName		
,Flags			
,BindingID		
,RecoveryForkID		
,Collation		
,FamilyGUID		
,HasBulkLoggedData	
,IsSnapshot		
,IsReadOnly		
,IsSingleUser		
,HasBackupChecksums	
,IsDamaged		
,BeginsLogChain		
,HasIncompleteMetaData	
,IsForceOffline		
,IsCopyOnly		
,FirstRecoveryForkID	
,ForkPointLSN		
,RecoveryModel		
,DifferentialBaseLSN	
,DifferentialBaseGUID	
,BackupTypeDescription	
,BackupSetGUID		
,CompressedBackupSize	
)

EXEC('RESTORE HEADERONLY FROM DISK = N'''+@FileName+'''') 

SELECT * FROM @Table


--dbaudf_PivotData




