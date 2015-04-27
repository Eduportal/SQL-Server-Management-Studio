USE DBAADMIN
GO
IF OBJECT_ID('dbasp_KillAllOnDB') IS NOT NULL
	DROP  PROCEDURE [dbo].[dbasp_KillAllOnDB]
GO	
CREATE  PROCEDURE [dbo].[dbasp_KillAllOnDB]
	( 
	@dbName		varchar(4000)
	) 
AS 
BEGIN 
	declare		@spid		int
			,@tsql		nvarchar(4000) 
	
	while	( 
		select		count(spid) 
		from		[master].[dbo].[sysprocesses] p 
		join		[Master].[dbo].[sysdatabases] d 
			on	p.dbid = d.dbid 
		where		d.name = @dbName 
		) > 0 
	BEGIN 
		SET		@tsql = ''
		
		select		@tsql = @tsql + 'kill ' + convert(varchar(4), @spid)+';' + CHAR(13)+CHAR(10)
		from		[master].[dbo].[sysprocesses] p 
		join		[master].[dbo].[sysdatabases] d 
			on	p.dbid = d.dbid 
		where		d.name = @dbName 

		exec	[dbo].[sp_executesql] @tsql 
	
	END 
END 
GO

IF OBJECT_ID('dbasp_CreateDBSnapshot') IS NOT NULL
	DROP PROCEDURE [dbo].[dbasp_CreateDBSnapshot]
GO	
CREATE PROCEDURE [dbo].[dbasp_CreateDBSnapshot]
	(
	@DBName				SYSNAME
	,@SnapName			SYSNAME
	,@SnapShotPath			VARCHAR(60)	= NULL	-- IF NULL, USE ORIGIONAL DB PATH
	,@ReplaceExisting		BIT		= 0	-- 1 IS NEEDED TO REPLACE EXISTING SNAPSHOT
	)
AS 
/*

	EXEC dbaadmin.dbo.dbasp_CreateDBSnapshot 'MirrorTest','MirrorTest_Snapshot',NULL,1

*/
BEGIN

	DECLARE		@TSQL			VARCHAR(8000)
			,@OldSnapName		VARCHAR(50)
			,@drop			VARCHAR(200)
			,@create		VARCHAR(500)
			,@path			VARCHAR(400)
			,@path2			VARCHAR(60)
			
	IF @ReplaceExisting =0 AND DB_ID(@SnapName) IS NOT NULL
	BEGIN
		RAISERROR ('Database %s already exists, Use @ReplaceExisting=1 to Replace Database with New Snapshot' ,16,1,@SnapName)
		RETURN -1
	END
	
	IF @ReplaceExisting =1 AND DB_ID(@SnapName) IS NOT NULL
	BEGIN
		EXEC dbaadmin.dbo.dbasp_KillAllOnDB @SnapName
		SET @TSQL = 'DROP DATABASE [' + @SnapName + ']'
		--PRINT (@TSQL)
		EXEC (@TSQL)
	END

	SET		@TSQL	= 'CREATE DATABASE ' + @SnapName + CHAR(13) + CHAR(10) 
				+ 'ON' + CHAR(13) + CHAR(10)

 	;WITH		DBFiles
 			AS
 			(
 			--DECLARE @DBName SYSNAME,@SnapShotPath VarChar(8000);SELECT @DBName = 'MirrorTest',@SnapShotPath='C:\';
			 SELECT		name	
					,REPLACE(dbaadmin.dbo.dbaudf_GetFileProperty(physical_name,'File','Path'),dbaadmin.dbo.dbaudf_GetFileProperty(physical_name,'File','Name'),'') OldPath
					,COALESCE(@SnapShotPath, REPLACE(dbaadmin.dbo.dbaudf_GetFileProperty(physical_name,'File','Path'),dbaadmin.dbo.dbaudf_GetFileProperty(physical_name,'File','Name'),'')) NewPath
					,dbaadmin.dbo.dbaudf_GetFileProperty(physical_name,'File','Name') OldFile
					,@SnapName+'_'+REPLACE(REPLACE(dbaadmin.dbo.dbaudf_GetFileProperty(physical_name,'File','Name'),'.mdf','.ss'),'.ndf','.ss') NewFile
			 FROM		sys.master_files
			 WHERE		data_space_id <> 0
				AND	is_sparse = 0
				AND	database_id = DB_ID(@DBName)
			)

	SELECT		@TSQL = @TSQL + '    ,( NAME=[' + name + '],FILENAME=''' + NewPath + NewFile + ''')'+ CHAR(13) + CHAR(10)
	FROM		DBFiles

	SET		@TSQL	= REPLACE(@TSQL,'ON'+CHAR(13)+CHAR(10)+'    ,( NAME','ON'+CHAR(13)+CHAR(10)+'    ( NAME')
				+ 'AS SNAPSHOT OF ' + @DBName	 
	
	--PRINT(@TSQL)
	EXEC (@TSQL)
 END
 
 
 








