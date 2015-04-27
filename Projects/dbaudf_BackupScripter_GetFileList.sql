USE [dbaadmin]
GO


IF OBJECT_ID('dbaudf_BackupScripter_GetFileList') IS NOT NULL
	DROP FUNCTION dbaudf_BackupScripter_GetFileList
GO
CREATE FUNCTION dbaudf_BackupScripter_GetFileList
		(
		@DBName			SYSNAME
		,@NewDBName		SYSNAME
		,@SetSize		INT
		,@FileName		VarChar(MAX)
		,@FullPathName		VarChar(MAX)
		,@OverrideXML		XML
		,@NOW			VarChar(20)
		,@LogPath		VarChar(500)
		,@DataPath		VarChar(500)
		,@NDFPath		VarChar(500)
		)

RETURNS TABLE AS RETURN
(

	SELECT		T1.*
			,New_PhysicalName	= COALESCE	(
								T4.[New_PhysicalName] /* MANUAL OVERRIDE */
								,COALESCE	(
						/* DBAADMIN OVERRIDE */		T2.[detail03]
						/* SQLDEPLOY OVERRIDE */	,T3.[NewPath]
						/* DEFAULT NDF SHARE PATH */	,CASE	WHEN dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(T1.[PhysicalName],'.','|'),2) = 'ndf' THEN @NDFPath
						/* DEFAULT MDF SHARE PATH */		WHEN T1.TYPE = 'D' THEN @DataPath
						/* DEFAULT LDF SHARE PATH */		ELSE @LogPath END
										) 
						/* DATETIMESTAMP */		+ CASE WHEN @DBName != @NewDBName THEN @NOW + '_' ELSE '' END
										+ dbaadmin.dbo.dbaudf_GetFileFromPath(T1.PhysicalName)
								)
			,BackupFileName		= CASE WHEN @SetSize > 1 THEN @FileName ELSE @FullPathName END

	FROM		[dbaadmin].[dbo].[dbaudf_RestoreFileList](@FullPathName) T1
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


)
GO


