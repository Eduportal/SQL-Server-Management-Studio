










DECLARE @PendingReboot  CHAR(1)

CREATE TABLE	#Results
                  (
                  KeyValue    NVARCHAR(100),
                  Value       NVARCHAR(100),
                  Data        NVARCHAR(100)
                  )

CREATE TABLE	#Keys
                  (
                  KeyName           NVARCHAR(100)
                  )


	INSERT INTO #Results
	EXEC [sys].[xp_instance_regRead] N'HKEY_LOCAL_MACHINE',N'SYSTEM\CurrentControlSet\Control\Session Manager',N'PendingFileRenameOperations'

	INSERT INTO #Keys 
	EXEC [sys].[xp_instance_regenumkeys] N'HKEY_LOCAL_MACHINE',N'SYSTEM\CurrentControlSet\Services'

IF EXISTS (SELECT * FROM #Results WHERE KeyValue Like 'PendingFileRenameOperations%' AND Value IS NOT NULL)
      SET @PendingReboot = 'Y'
ELSE
      SET @PendingReboot = 'N'
SELECT		--@@SERVERNAME							[ServerName],
		REPLACE(REPLACE(REPLACE(REPLACE(
			@@VERSION,CHAR(9),' '),CHAR(13)+CHAR(10),' ')
			,CHAR(13),' '),CHAR(10),' ')				[SQLVersion]
		,(Select SQLEnv From dbaadmin.dbo.dba_serverinfo)		[SQLEnv]
		,(Select Backup_Type From dbaadmin.dbo.dba_serverinfo)		[Backup_Type]
		,(Select DomainName From dbaadmin.dbo.dba_serverinfo)		[DomainName]
		,REPLACE(dbaadmin.[dbo].[dbaudf_ConcatenateUnique](CASE
			WHEN KeyName Like 'ah3agent%'       THEN 'AntHill'
			WHEN KeyName Like 'McShield%'       THEN 'Mcafee'
			WHEN KeyName Like 'Splunk%'         THEN 'Splunk'
			WHEN KeyName Like 'TSM%'            THEN 'Tivoli'
			WHEN KeyName Like 'InMage%'         THEN 'InMage'
			WHEN KeyName Like 'MOMConnector%'   THEN 'SCOM'
			WHEN KeyName Like 'HealthService%'  THEN 'SCOM'
			WHEN KeyName Like 'McAfeeFramework%'      THEN 'Mcafee'
			WHEN KeyName Like 'SQLBackupAgent%' THEN 'Redgate'
			WHEN KeyName Like 'EmcSrdfce%'            THEN 'SRDF'
			WHEN KeyName Like 'netbackup%'            THEN 'Veritas'
			END ),',','|')						[Services]
		,dbaadmin.[dbo].[dbaudf_GetFileProperty]
			('C:\Program Files\Tivoli\TSM','Folder','Exists')	[TSM_App_Installed]
		,@PendingReboot							[PendingReboot]
FROM        #Keys
GO
DROP TABLE	#Results
GO
DROP TABLE	#Keys
GO

