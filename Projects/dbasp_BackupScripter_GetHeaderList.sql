USE [dbaadmin]
GO


IF OBJECT_ID('dbasp_BackupScripter_GetHeaderList') IS NOT NULL
	DROP PROCEDURE dbasp_BackupScripter_GetHeaderList
GO
CREATE PROCEDURE dbasp_BackupScripter_GetHeaderList
		(
		@BackupEngine		VarChar(50)
		,@SetSize		INT
		,@FileName		VarChar(MAX)
		,@FullPathName		VarChar(MAX)
		)

AS
BEGIN
	DECLARE		@CMD			VarChar(MAX)
			,@NOW			VarChar(20)
			,@LogPath		VarChar(500)
			,@DataPath		VarChar(500)
			,@NDFPath		VarChar(500)

	DECLARE		@headerlist		TABLE
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
			containment		bit,
			BackupFileName		[nvarchar](4000) NULL,
			[BackupDateRange_Start]	datetime NULL,
			[BackupDateRange_End]	datetime NULL,
			[BackupChainStartDate]	datetime NULL,
			[BackupLinkStartDate]	datetime NULL
			)

	IF OBJECT_ID('tempdb..#headerlist') IS NOT NULL	
		DROP TABLE #headerlist	

	CREATE TABLE #headerlist	(
					[id] INT IDENTITY PRIMARY KEY
					, [Data] VarChar(max) NULL
					)

	INSERT INTO @headerlist	(
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
				,Containment	
				)
	SELECT		*
	FROM		[dbaadmin].[dbo].[dbaudf_RestoreHeader](@FullPathName) 

	UPDATE		@headerlist
		SET	BackupFileName = CASE WHEN @SetSize > 1 THEN @FileName ELSE @FullPathName END

	SELECT		*
	FROM		@headerlist
END
GO
