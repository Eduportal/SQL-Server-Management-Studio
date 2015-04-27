USE [dbaadmin]
GO


IF OBJECT_ID('dbasp_BackupScripter_GetFileList') IS NOT NULL
	DROP PROCEDURE dbasp_BackupScripter_GetFileList
GO
CREATE PROCEDURE dbasp_BackupScripter_GetFileList
		(
		@DBName			SYSNAME
		,@NewDBName		SYSNAME
		,@BackupEngine		VarChar(50)
		,@SetSize		INT
		,@FileName		VarChar(MAX)
		,@FullPathName		VarChar(MAX)
		,@OverrideXML		XML
		)

AS
BEGIN
	DECLARE		@CMD			VarChar(MAX)
			,@NOW			VarChar(20)
			,@LogPath		VarChar(500)
			,@DataPath		VarChar(500)
			,@NDFPath		VarChar(500)


	DECLARE		@filelist		TABLE
			(
			LogicalName		NVARCHAR(128) NULL, 
			PhysicalName		NVARCHAR(260) NULL, 
			type			CHAR(1), 
			FileGroupName		NVARCHAR(128) NULL, 
			SIZE			NUMERIC(20,0), 
			MaxSize			NUMERIC(20,0),
			FileId			BIGINT,
			CreateLSN		NUMERIC(25,0),
			DropLSN			NUMERIC(25,0),
			UniqueId		VARCHAR(50),
			ReadOnlyLSN		NUMERIC(25,0),
			ReadWriteLSN		NUMERIC(25,0),
			BackupSizeInBytes	BIGINT,
			SourceBlockSize		INT,
			FileGroupId		INT,
			LogGroupGUID		VARCHAR(50) NULL,
			DifferentialBaseLSN	NUMERIC(25,0),
			DifferentialBaseGUID	VARCHAR(50),
			IsReadOnly		BIT,
			IsPresent		BIT,
			TDEThumbprint		NVARCHAR(128) NULL,
			New_PhysicalName	NVARCHAR(1000) NULL,
			BackupFileName		NVARCHAR(4000) NULL
			)

	SELECT		@NOW			= REPLACE(REPLACE(REPLACE(CONVERT(VarChar(50),getdate(),120),'-',''),':',''),' ','')
			,@DataPath		= dbaadmin.[dbo].[dbaudf_GetSharePath](dbaadmin.[dbo].[dbaudf_getShareUNC]('mdf'))
			,@NdfPath		= COALESCE(dbaadmin.[dbo].[dbaudf_GetSharePath](dbaadmin.[dbo].[dbaudf_getShareUNC]('ndf')),@DataPath)
			,@LogPath		= dbaadmin.[dbo].[dbaudf_GetSharePath](dbaadmin.[dbo].[dbaudf_getShareUNC]('ldf'))
			,@NewDBName		= COALESCE(NULLIF(@NewDBName,''),@DBName)

	INSERT INTO	@filelist (LogicalName,PhysicalName,type,FileGroupName,SIZE,MaxSize,FileId,CreateLSN,DropLSN,UniqueId,ReadOnlyLSN,ReadWriteLSN,BackupSizeInBytes,SourceBlockSize,FileGroupId,LogGroupGUID,DifferentialBaseLSN,DifferentialBaseGUID,IsReadOnly,IsPresent,TDEThumbprint)
	SELECT		*
	FROM		[dbaadmin].[dbo].[dbaudf_RestoreFileList](@FullPathName) 

	UPDATE		T1
		SET	New_PhysicalName	= COALESCE	(
								T4.[New_PhysicalName] /* MANUAL OVERRIDE */
								,COALESCE	(
						/* DBAADMIN OVERRIDE */		T2.[detail03]
						/* SQLDEPLOY OVERRIDE */	,T3.[NewPath]
						/* DEFAULT NDF SHARE PATH */	,CASE	WHEN dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(T1.[PhysicalName],'.','|'),2) = 'ndf' THEN @NDFPath
						/* DEFAULT MDF SHARE PATH */		WHEN T1.TYPE = 'D' THEN @DataPath
						/* DEFAULT LDF SHARE PATH */		ELSE @LogPath END
										) 
										+ '\' 
						/* DATETIMESTAMP */		+ CASE WHEN @DBName != @NewDBName THEN @NOW + '_' ELSE '' END
										+ dbaadmin.dbo.dbaudf_GetFileFromPath(T1.PhysicalName)
								)
			,BackupFileName		= CASE WHEN @SetSize > 1 THEN @FileName ELSE @FullPathName END		
	FROM		@filelist T1
	LEFT JOIN	dbaadmin.dbo.local_control T2
		ON	T2.subject = 'restore_override' 
		AND	T2.detail01 = @NewDBName 
		AND	T2.detail02 = T1.LogicalName
	LEFT JOIN	(
			SELECT		dbaadmin.dbo.dbaudf_ReturnPart(REPLACE([subject],'_','|'),3) [Type]
					,CASE subject WHEN 'auto_restore_file' THEN dbaadmin.dbo.dbaudf_ReturnPart(REPLACE([control01],'\','|'),1) ELSE [control01] END [DBName]
					,CASE subject WHEN 'auto_restore_file' THEN dbaadmin.dbo.dbaudf_ReturnPart(REPLACE([control01],'\','|'),2) END [DeviceName]
					,[control02] [ServerName]
					,[control03] [NewPath]
			FROM		[SQLdeploy].[dbo].[ControlTable]
			WHERE		subject like 'auto_restore%'
			) T3
		ON	T3.[ServerName] = @@SERVERNAME
		AND	T3.[DBName] = @NewDBName
		AND	(T3.[DeviceName] = T1.LogicalName OR T3.[DeviceName] IS NULL)
		AND	(T3.[Type] = dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(T1.[PhysicalName],'.','|'),2) OR T3.[Type] IS NULL)
	LEFT JOIN	(
			SELECT		a.x.value('@LogicalName','sysname') [LogicalName]
					,a.x.value('@PhysicalName','varchar(500)') [PhysicalName]
					,a.x.value('@New_PhysicalName','varchar(500)') [New_PhysicalName]
			FROM		@OverrideXML.nodes('/RestoreFileLocations/*') a(x)
			) T4
		ON	T4.[LogicalName] = T1.LogicalName
		AND	T4.[PhysicalName] = T1.PhysicalName

	SELECT		*
	FROM		@filelist 
END
GO

