USE master
GO
SET NOCOUNT ON
GO
DECLARE		@DBName					SYSNAME			--=	'WCDS'
			,@BackUpFilePath		VarChar(4000)	--=	'\\seapsqldba01\SEAPSQLDBA01_backup\CapacityManagerRepository_db_20120312220132.cBAK'
			,@NXTSharePath			VarChar(8000)
			,@NXTDrivePath			VarChar(8000)
			,@BackupModDate			DateTime
			,@TSQL					VarChar(max)
			,@CustomProperty		SYSNAME
			,@IsSnapshot			bit
			,@IsSnapCurrent			bit
			,@CurrentModValue		DateTime
			,@spid					int
			,@str					varchar(255)
			,@SnapDBName			SYSNAME

SELECT		@DBName				= 'WCDS'
			,@BackUpFilePath	= '\\gmssqldev04\GMSSQLDEV04$A_base\WCDS_prod.sqb'

			,@BackupModDate		= dbaadmin.dbo.dbaudf_GetFileProperty(@BackUpFilePath,'File','DateLastModified')
			,@CustomProperty	= 'SnapshotModDate_'+@DBName
			,@SnapDBName		= 'z_snap_' + @DBName
			,@IsSnapshot		= 0
			,@IsSnapCurrent		= 0
			,@NXTSharePath		= REPLACE(@@SERVERNAME,'\','$')+'_nxt'	


exec dbaadmin.dbo.dbasp_get_share_path @NXTSharePath, @NXTDrivePath output


IF NOT EXISTS (SELECT value FROM fn_listextendedproperty(@CustomProperty, default, default, default, default, default, default))
	PRINT 'No Property Found'
ELSE
	BEGIN
		PRINT 'Reading Property'
		SELECT		@IsSnapshot			= 1
					,@CurrentModValue	= CAST(value AS DateTime)
		FROM		fn_listextendedproperty(@CustomProperty, default, default, default, default, default, default)

		If	@CurrentModValue = @BackupModDate
		BEGIN
			PRINT 'Baseline Snapshot is up to date'
			SELECT		@IsSnapCurrent	= 1
		END
		ELSE
			PRINT 'Baseline Snapshot is NOT up to date'
	END
	
IF @IsSnapshot = 1 AND @IsSnapCurrent = 1
-- REVERT SNAPSHOT
BEGIN
	PRINT 'Starting Revert'
	PRINT '  Killing All Connections'
	-- START BY KILLING ALL CONNECTIONS IN DB
	DECLARE USERS CURSOR FOR 
	SELECT SPID
	FROM MASTER..SYSPROCESSES 
	WHERE DB_NAME(DBID) = @DBNAME

	OPEN USERS
	FETCH NEXT FROM USERS INTO @SPID

	WHILE @@FETCH_STATUS <> -1
	BEGIN
	   IF @@FETCH_STATUS = 0
	   BEGIN
		  SET @STR = 'KILL ' + CONVERT(VARCHAR, @SPID)
		  EXEC (@STR)
	   END
	   FETCH NEXT FROM USERS INTO @SPID
	END
	DEALLOCATE USERS

	IF DB_ID(@SnapDBName) IS NOT NULL
	BEGIN
		-- Reverting DATABASE
		PRINT '  Reverting to Snapshot'
		SET		@TSQL	= 'RESTORE DATABASE '+@DBName+' FROM DATABASE_SNAPSHOT = '''+@SnapDBName+''''
		EXEC	(@TSQL)
	END
	ELSE
	BEGIN
		PRINT '  No Snapshot Found'
		SELECT		@IsSnapshot = 0, @IsSnapCurrent = 0
	END
END

IF @IsSnapshot = 1 AND @IsSnapCurrent = 0
-- SNAPSHOT IS NOT CURRENT
BEGIN
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	--								FLUSH SNAPSHOT
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	IF DB_ID(@SnapDBName) IS NOT NULL
	BEGIN
		PRINT 'Dropping Snapshot'
		SET		@TSQL	= 'DROP DATABASE '+@SnapDBName
		EXEC	(@TSQL)
	END
	ELSE
		PRINT 'Snapshot Does Not Exist'
		
	SET  @IsSnapshot = 0
END

IF @IsSnapshot = 0
-- SNAPSHOT IS NOT CURRENT
BEGIN
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	--								NORMAL RESTORE
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------

	PRINT 'RESTORE DB'


END

-- TEST IF SNAPSHOT EXISTS
IF @IsSnapshot = 0
BEGIN
	-- TEST IF PATH IS VALID
	IF 	dbaadmin.dbo.dbaudf_GetFileProperty(@NXTDrivePath,'Folder','Path') IS NOT NULL 
	BEGIN
		------------------------------------------------------------------------------
		------------------------------------------------------------------------------
		--								CREATE SNAPSHOT
		------------------------------------------------------------------------------
		------------------------------------------------------------------------------
		PRINT 'Snapshot Database AS ' + @SnapDBName
		SET			@TSQL = NULL
			
		SELECT		@TSQL = COALESCE(@TSQL,'')+',(NAME = '+name+', FILENAME = '''+@NXTDrivePath+'\'+name+'.ss'')'+CHAR(13)+CHAR(10) 
		FROM		sys.Master_files
		WHERE		database_id = DB_ID(@DBName) AND type = 0
		ORDER BY	file_id

		SET		@TSQL	= 'CREATE DATABASE '+@SnapDBName+' ON' +CHAR(13)+CHAR(10)
						+ STUFF(@TSQL,1,1,'')
						+ 'AS SNAPSHOT OF ' + @DBName
		EXEC	(@TSQL)

		IF NOT EXISTS (SELECT value FROM fn_listextendedproperty(@CustomProperty, default, default, default, default, default, default))
			BEGIN
				PRINT 'Adding Property'
				EXEC sys.sp_addextendedproperty @Name = @CustomProperty, @value = @BackupModDate
			END
		ELSE
			BEGIN
				PRINT 'Updating Property'
				EXEC sys.sp_updateextendedproperty @Name = @CustomProperty, @value = @BackupModDate
			END
	END
	ELSE
		PRINT 'NXT Path was invalid, No SnapShot Was Taken'
END
ELSE
	PRINT 'Existing Snapshot is still Valid, No New SnapShot Was Taken'
GO






