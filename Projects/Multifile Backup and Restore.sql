
DECLARE	@CMD			VarChar(max)
		,@CMD2			VarChar(max)
		,@CMD3			nVarChar(4000)
		,@NOW			VarChar(max)
		,@FileName		VarChar(max)
		,@Extension		VarChar(50)
		,@SetSize		INT
		,@SetNumber		INT
		,@Stats			INT
		,@FilePath		VarChar(max)
		,@SetName		VarChar(max)
		,@SetDesc		VarChar(max)
		,@DBName		SYSNAME
		,@ServerName	SYSNAME
		,@MachineName	SYSNAME
		,@Recovery		BIT
		,@CopyOnly		BIT
		,@Init			BIT
		,@Checksum		BIT
		,@Compress		BIT
		,@StandBy		VarChar(MAX)
		,@Files			VarChar(max)
		,@FileGroups	VarChar(Max)
		,@Size			FLOAT
		,@Mode			CHAR(2) -- 'BF' Backup FULL
						-- 'BD' Backup DIFFERENTIAL
						-- 'BL' Backup LOG
						-- 'RD' Restore DATABASE
						-- 'RL' Restore LOG
						-- 'RH' Restore (Header Only)
						-- 'RF' Restore (Filelist Only)
						-- 'LA' Restore (Label Only)
						-- 'RV' Restore (Verify Only)

SELECT	@DBName			= 'GPDB'
		,@Mode			= 'BF'
		,@FilePath		= NULL
		,@FileName		= NULL
		,@Standby		= NULL
		,@Files			= NULL
		,@FileGroups	= NULL
		,@Extension		= '.cBAK'
		,@SetName		= NULL
		,@SetDesc		= NULL
		
		
		,@SetSize		= 64
		,@Recovery		= 0
		,@CopyOnly		= 1
		,@Init			= 1
		,@Checksum		= 1
		,@Compress		= 1
		,@Stats			= 1
		
		
		,@MachineName	= LEFT(@@SERVERNAME+'\',CHARINDEX('\',@@SERVERNAME+'\')-1)
		,@ServerName	= REPLACE(@@SERVERNAME,'\','$')
		,@FilePath		= COALESCE(@FilePath,'\\' + @MachineName + '\' + @ServerName + '_Backup\')
		,@NOW			= REPLACE(REPLACE(REPLACE(CONVERT(VarChar(50),getdate(),120),'-',''),':',''),' ','')
		,@FileName		= COALESCE(@FileName,@DBName + CASE @Mode	WHEN 'BF' THEN '_db_'
										WHEN 'BD' THEN '_dfntl_'
										WHEN 'BL' THEN '_tlog_'
										END
							      + CASE WHEN @FileGroups IS NOT NULL THEN 'FG_'+REPLACE(@FileGroups,',','_')+'_' ELSE '' END
							      +@NOW)

		,@SetName		= COALESCE(@SetName,@FileName,'')
		,@SetDesc		= COALESCE(@SetDesc,@FileName,'')
		,@SetNumber		= 0

		
		,@CMD			= CASE @Mode	WHEN 'BF' THEN 'BACKUP DATABASE ['+@DBName+']'+CHAR(13)+CHAR(10)
							WHEN 'BD' THEN 'BACKUP DATABASE ['+@DBName+']'+CHAR(13)+CHAR(10)
							WHEN 'BL' THEN 'BACKUP LOG ['+@DBName+']'+CHAR(13)+CHAR(10)
							WHEN 'RD' THEN 'RESTORE DATABASE ['+@DBName+']'+CHAR(13)+CHAR(10)
							WHEN 'RL' THEN 'RESTORE LOG ['+@DBName+']'+CHAR(13)+CHAR(10)
							WHEN 'RH' THEN 'RESTORE HEADERONLY'+CHAR(13)+CHAR(10)
							WHEN 'RF' THEN 'RESTORE FILELISTONLY'+CHAR(13)+CHAR(10)
							WHEN 'LA' THEN 'RESTORE LABELONLY'+CHAR(13)+CHAR(10)
							WHEN 'RV' THEN 'RESTORE VERIFYONLY'+CHAR(13)+CHAR(10)
							END
						+ CASE @Mode	WHEN 'BF' THEN 'TO '+CHAR(13)+CHAR(10)
							WHEN 'BD' THEN 'TO '+CHAR(13)+CHAR(10)
							WHEN 'BL' THEN 'TO '+CHAR(13)+CHAR(10)
							WHEN 'RD' THEN 'FROM '+CHAR(13)+CHAR(10)
							WHEN 'RL' THEN 'FROM '+CHAR(13)+CHAR(10)
							WHEN 'RH' THEN 'FROM '+CHAR(13)+CHAR(10)
							WHEN 'RF' THEN 'FROM '+CHAR(13)+CHAR(10)
							WHEN 'LA' THEN 'FROM '+CHAR(13)+CHAR(10)
							WHEN 'RV' THEN 'FROM '+CHAR(13)+CHAR(10)
							END


		,@CMD3		= REPLACE('USE {DBNAME};SET NOCOUNT ON;
						SELECT		@Size = (cast((sum(a.used_pages) * 8192/1048576.) as decimal(15, 2))*25)/100 
						from		sys.partitions p 
						join		sys.allocation_units a 
							on	p.partition_id = a.container_id
						left join	sys.internal_tables it 
							on	p.object_id = it.object_id;','{DBNAME}',@DBNAME)
	
		exec sp_executesql @statement = @CMD3, @params = N'@Size FLOAT OUT',@Size = @Size OUT

		SELECT @SetSize = @Size/(1024*2)
		
		IF @SetSize > 64
			SET @SetSize = 64

	
	IF @Mode IN ('BF','BD','BL')
	BEGIN
		IF @SetSize > 1
		BEGIN
			WHILE		@SetNumber < @SetSize
			BEGIN
				SET	@SetNumber = @SetNumber + 1
				SET	@CMD2 = 'DISK = '''+@FilePath+@FileName+'_set_'+RIGHT('0'+CAST(@SetNumber AS VARCHAR(2)),2)+'_of_'+RIGHT('0'+CAST(@SetSize AS VARCHAR(2)),2)+@Extension+''''

				SET	@CMD	= @CMD
						+ CASE @SetNumber  WHEN 1 THEN '' ELSE ',' END + @CMD2 + CHAR(13) + CHAR(10)

			END
		END
		ELSE
			SET	@CMD	= @CMD
					+ 'DISK = '''+@FilePath+@FileName+@Extension+''''
					+ CHAR(13) + CHAR(10)
	END
	ELSE
	BEGIN
		-- GET FILES FROM DISK
		PRINT ''
	
	
	
	END

SELECT		@CMD	= @CMD
		+ 'WITH ' 
		+ dbaadmin.dbo.dbaudf_ConcatenateUnique (WithOptions)
FROM		(
		SELECT	CASE @CopyOnly	WHEN 1 THEN 'COPY_ONLY' ELSE NULL END AS WithOptions UNION 
		SELECT	CASE @Mode	WHEN 'BD' THEN 'DIFFERENTIAL' ELSE NULL END UNION
		SELECT	CASE @Init	WHEN 1 THEN 'INIT' ELSE 'NOINIT' END UNION
		SELECT	CASE @Checksum	WHEN 1 THEN 'CHECKSUM' ELSE NULL END UNION
		SELECT	CASE @Compress	WHEN 1 THEN 'COMPRESSION' ELSE NULL END UNION
		SELECT	'STATS = ' + CAST(@Stats AS VarChar(3)) UNION
		SELECT	'NAME = ''' + @SetName + '''' UNION
		SELECT	'DESCRIPTION = ''' + @SetDesc + ''''
		) Data


PRINT @CMD
RAISERROR('',-1,-1) WITH NOWAIT
--EXEC(@CMD)
GO

	