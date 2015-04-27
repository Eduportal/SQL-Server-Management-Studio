DECLARE		@MostRecent_Full	DATETIME
		,@MostRecent_Diff	DATETIME
		,@MostRecent_Log	DATETIME
		,@COPY_CMD		VARCHAR(8000)
		,@DELETE_CMD		VARCHAR(max)
		,@DBName		sysname
		,@BackupPath		VARCHAR(max)
		,@RestorePath		VARCHAR(max)
		,@FileName		VARCHAR(MAX)


SELECT		@DBName			= 'Product'
		,@BackupPath		= '\\G1sqlb\G1SQLB$B_backup\'
		,@RestorePath		= '\\SEAPLOGSQL01\SEAPLOGSQL01_backup\LogShip\'+@DBName
		,@COPY_CMD		= 'ROBOCOPY '+@BackupPath+' '+@RestorePath+'\'
		,@DELETE_CMD		= ''


;WITH		SourceFiles
		AS
		(
		SELECT		*
		FROM		dbaadmin.dbo.dbaudf_Dir(@BackupPath)
		WHERE		LEFT(name,len(@DBName)+1) = @DBName + '_'
			AND	IsFileSystem = 1
			AND	IsFolder = 0
			AND	error IS NULL
		)
		,QueuedFiles
		AS
		(
		SELECT		*
		FROM		dbaadmin.dbo.dbaudf_Dir(@RestorePath+'\')
		WHERE		LEFT(name,len(@DBName)+1) = @DBName + '_'
		)
		,Files
		AS
		(
		SELECT		S.*
				,CASE	WHEN Q.name IS NULL 		THEN 'Not Coppied'
					ELSE 'Coppied'
					END AS [Status]

		FROM		SourceFiles S 
		LEFT JOIN	QueuedFiles Q 
			ON	Q.name = S.Name

		WHERE		(RIGHT(s.path,4) = 'cDIF' AND s.ModifyDate = (SELECT MAX(ModifyDate) FROM SourceFiles WHERE RIGHT(path,4) = 'cDIF'))
			OR	(RIGHT(s.path,4) = 'cBAK' AND s.ModifyDate = (SELECT MAX(ModifyDate) FROM SourceFiles WHERE RIGHT(path,4) = 'cBAK'))
			OR	(RIGHT(s.path,3) = 'TRN' AND s.ModifyDate >= (SELECT MAX(ModifyDate) FROM SourceFiles WHERE RIGHT(path,4) = 'cDIF'))
		)
		
--SELECT * FROM Files	
	
		
SELECT		@COPY_CMD	= @COPY_CMD	+ CASE F.[Status] WHEN 'Not Coppied' THEN ' '+STUFF(f.path,1,CHARINDEX(f.name,f.Path)-1,'') ELSE '' END
		,@DELETE_CMD	= @DELETE_CMD	+ CASE WHEN F.[Status] IS NULL THEN 'exec dbaadmin.dbo.dbasp_UnlockAndDelete '''+Q.path+''',1,1,0'+CHAR(13)+CHAR(10) ELSE '' END
--SELECT		*		
FROM		QueuedFiles Q
FULL JOIN	Files F 
	ON	F.name = Q.name

IF @COPY_CMD != 'ROBOCOPY '+@BackupPath+' '+@RestorePath+'\'
BEGIN
	PRINT @COPY_CMD	
	exec XP_CMDSHELL @COPY_CMD
END

PRINT ''

EXEC (@DELETE_CMD)
	
EXECUTE [dbaadmin].[dbo].[dbasp_autorestore] 
   @full_path =@RestorePath
  ,@dbname = @DBName
  ,@datapath = 'E:\MSSQL\Data\'
  ,@logpath = 'F:\MSSQL\Log\'
  ,@differential_flag = 'Y'
  ,@db_norecovOnly_flag = 'Y'
  ,@Script_out='N'



