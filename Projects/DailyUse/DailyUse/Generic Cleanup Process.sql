
--dbasp_DBRestore_Clean	'Cribsheet2'
DROP PROCEDURE dbasp_DBRestore_Clean
GO
CREATE PROCEDURE dbasp_DBRestore_Clean (@DBName sysname)

/*********************************************************
 **  Stored Procedure dbasp_DBRestore_Clean                  
 **  Written by Steve Ledridge, Getty Images                
 **  January 6, 2010                                      
 **  
 **  This procedure is used to .  
 **
 **  This proc accepts a single input parm (outlined below):
 **
 **  - @DBName is the name of the Database to be cleaned.
 **
 ***************************************************************/
  as

SET NOCOUNT ON

--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	01/06/2010	Steve Ledridge		Created and Started Testing
--
--	======================================================================================

/***
Declare	@DBName sysname
SET	@DBName = 'SoundTrackDB'
--***/
BEGIN
	-----------------  declares  ------------------
	DECLARE	@error_count	INT
	DECLARE @SQLVersion	Numeric
	DECLARE @TSQL		nvarChar(max) 
	SET	@SQLVersion	= LEFT(CAST(SERVERPROPERTY('ProductVersion')AS VarChar(50)),4)


	-- VALIDATE DATABASE NAME:
	If not exists(select * from master.sys.sysdatabases where name = @DBname)
	   begin
		raiserror('DBA WARNING: Database name not found in master..sysdatabases',-1,-1)
		SET @error_count = @error_count + 1
		goto label99
	   end
	   
	-- Put Brackets arround DBName for use in Text Blocks.   
	SET	@DBName		= QUOTENAME(@DBName)
	
	/**************************************************************
	CHANGE DATABASE OWNER TO DBO
	**************************************************************/
	SET @TSQL = 'ALTER AUTHORIZATION ON DATABASE::' + @DBName + ' TO sa;'
	PRINT (@TSQL)
	EXEC (@TSQL)
	If @@Error = 0 
	    PRINT '  -- Successfull'
	ELSE
	   begin
		SET @TSQL = 'DBA WARNING: ' + @TSQL
		raiserror(@TSQL,-1,-1)
		SET @error_count = @error_count + 1
		goto label99
	   end	    
	raiserror('', -1,-1) with nowait

	/**************************************************************
	CHANGE ALL ASSEMBLIES OWNER TO DBO
	**************************************************************/
	SET @TSQL= 
	'USE ' + @DBName + ';
	DECLARE @cmd nvarchar(500)
	DECLARE @name sysname
	DECLARE ChangeOwner_Cursor CURSOR
	FOR
	SELECT	QUOTENAME(name) name
	from	' + @DBName + '.sys.assemblies 
	where	principal_id > 4 
	  and	principal_id < 16384
	OPEN ChangeOwner_Cursor
	FETCH NEXT FROM ChangeOwner_Cursor INTO @name
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			SET @cmd = ''ALTER AUTHORIZATION ON Assembly::'' + @name + '' TO dbo;''
			PRINT (@cmd)
			EXEC (@cmd)
			If @@Error = 0 
			    PRINT ''  -- Successfull''
			ELSE
			   begin
				SET @cmd = ''DBA WARNING: '' + @cmd
				raiserror(@cmd,-1,-1)
			   end	    
		END
		FETCH NEXT FROM ChangeOwner_Cursor INTO @name
	END
	CLOSE ChangeOwner_Cursor
	DEALLOCATE ChangeOwner_Cursor'
	EXEC (@TSQL)
	If @@Error = 0 
	    PRINT '  -- Successfull'
	ELSE
	   begin
		SET @TSQL = 'DBA WARNING: ' + @TSQL
		raiserror(@TSQL,-1,-1)
		SET @error_count = @error_count + 1
		goto label99
	   end	    
	raiserror('', -1,-1) with nowait
	
	/**************************************************************
	CHANGE ALL SCHEMAS OWNER TO DBO
	**************************************************************/
	SET @TSQL= 
	'USE ' + @DBName + ';
	DECLARE @cmd nvarchar(500)
	DECLARE @name sysname
	DECLARE ChangeOwner_Cursor CURSOR
	FOR
	SELECT	QUOTENAME(name) name
	from	' + @DBName + '.sys.schemas
	where	principal_id > 4 
	  and	principal_id < 16384
	OPEN ChangeOwner_Cursor
	FETCH NEXT FROM ChangeOwner_Cursor INTO @name
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			SET @cmd = ''ALTER AUTHORIZATION ON SCHEMA::'' + @name + '' TO dbo;''
			PRINT (@cmd)
			EXEC (@cmd)
			If @@Error = 0 
			    PRINT ''  -- Successfull''
			ELSE
			   begin
				SET @cmd = ''DBA WARNING: '' + @cmd
				raiserror(@cmd,-1,-1)
			   end	    
		END
		FETCH NEXT FROM ChangeOwner_Cursor INTO @name
	END
	CLOSE ChangeOwner_Cursor
	DEALLOCATE ChangeOwner_Cursor'
	EXEC (@TSQL)
	If @@Error = 0 
	    PRINT '  -- Successfull'
	ELSE
	   begin
		SET @TSQL = 'DBA WARNING: ' + @TSQL
		raiserror(@TSQL,-1,-1)
		SET @error_count = @error_count + 1
		goto label99
	   end	    
	raiserror('', -1,-1) with nowait
	
	/**************************************************************
	CHANGE ALL ROLES OWNER TO DBO
	**************************************************************/
	SET @TSQL= 
	'USE ' + @DBName + ';
	DECLARE @cmd nvarchar(500)
	DECLARE @name sysname
	DECLARE ChangeOwner_Cursor CURSOR
	FOR
	SELECT	QUOTENAME(name) name
	from	' + @DBName + '.sys.database_principals 
	where is_fixed_role = 0 
	  and type = ''R'' 
	  AND owning_principal_id != 1
	OPEN ChangeOwner_Cursor
	FETCH NEXT FROM ChangeOwner_Cursor INTO @name
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			SET @cmd = ''ALTER AUTHORIZATION ON ROLE::'' + @name + '' TO dbo;''
			PRINT (@cmd)
			EXEC (@cmd)
			If @@Error = 0 
			    PRINT ''  -- Successfull''
			ELSE
			   begin
				SET @cmd = ''DBA WARNING: '' + @cmd
				raiserror(@cmd,-1,-1)
			   end	    
		END
		FETCH NEXT FROM ChangeOwner_Cursor INTO @name
	END
	CLOSE ChangeOwner_Cursor
	DEALLOCATE ChangeOwner_Cursor'
	EXEC (@TSQL)
	If @@Error = 0 
	    PRINT '  -- Successfull'
	ELSE
	   begin
		SET @TSQL = 'DBA WARNING: ' + @TSQL
		raiserror(@TSQL,-1,-1)
		SET @error_count = @error_count + 1
		goto label99
	   end	    
	raiserror('', -1,-1) with nowait
	
	/**************************************************************
	DROP ALL USERS
	**************************************************************/
	SET @TSQL= 
	'USE ' + @DBName + ';
	DECLARE @cmd nvarchar(500)
	DECLARE @name sysname
	DECLARE ChangeOwner_Cursor CURSOR
	FOR
	SELECT	QUOTENAME(name) name
	from	' + @DBName + '.sys.database_principals 
	where type != ''R'' 
	  AND principal_id > 4
	OPEN ChangeOwner_Cursor
	FETCH NEXT FROM ChangeOwner_Cursor INTO @name
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			SET @cmd = ''DROP USER '' + @name + '';''
			PRINT (@cmd)
			EXEC (@cmd)
			If @@Error = 0 
			    PRINT ''  -- Successfull''
			ELSE
			   begin
				SET @cmd = ''DBA WARNING: '' + @cmd
				raiserror(@cmd,-1,-1)
			   end	    
		END
		FETCH NEXT FROM ChangeOwner_Cursor INTO @name
	END
	CLOSE ChangeOwner_Cursor
	DEALLOCATE ChangeOwner_Cursor'
	EXEC (@TSQL)
	If @@Error = 0 
	    PRINT '  -- Successfull'
	ELSE
	   begin
		SET @TSQL = 'DBA WARNING: ' + @TSQL
		raiserror(@TSQL,-1,-1)
		SET @error_count = @error_count + 1
		goto label99
	   end	    
	raiserror('', -1,-1) with nowait

	/****************************************************
	Set database options for database SoundTrackDB
	****************************************************/
	 
	SET @TSQL = 'ALTER DATABASE ' + @DBName + ' SET RECOVERY SIMPLE WITH NO_WAIT;'
	PRINT (@TSQL)
	EXEC (@TSQL)
	If @@Error = 0 
	    PRINT '  -- Successfull'
	ELSE
	   begin
		SET @TSQL = 'DBA WARNING: ' + @TSQL
		raiserror(@TSQL,-1,-1)
		SET @error_count = @error_count + 1
		goto label99
	   end	    
	raiserror('', -1,-1) with nowait

	SET @TSQL = 'ALTER DATABASE ' + @DBName + ' SET MULTI_USER  WITH NO_WAIT;'
	PRINT (@TSQL)
	EXEC (@TSQL)
	If @@Error = 0 
	    PRINT '  -- Successfull'
	ELSE
	   begin
		SET @TSQL = 'DBA WARNING: "' + @TSQL + '" Failed'
		raiserror(@TSQL,-1,-1)
		SET @error_count = @error_count + 1
		goto label99
	   end	    
	raiserror('', -1,-1) with nowait

	SET @DBName = REPLACE(REPLACE(@DBName,'[',''),']','')

	IF @SQLVersion >= 9
	BEGIN
		PRINT 'Setting Compatability Level to 90'
		SET @TSQL = 'EXEC dbo.sp_dbcmptlevel @dbname=N''''' + @DBName + ''''', @new_cmptlevel=90'
	END
	ELSE
	BEGIN
		PRINT 'Setting Compatability Level to 80'
		SET @TSQL = 'EXEC dbo.sp_dbcmptlevel @dbname=N''''' + @DBName + ''''', @new_cmptlevel=80'
	END
	
	SET @TSQL = 'exec master.dbo.xp_cmdshell ''' + 'osql -E -S' + @@SERVERNAME + ' -Q"' + @TSQL + '"'''
	--PRINT @TSQL
	EXEC sp_executesql @TSQL
	If @@Error = 0 
	    PRINT '  -- Successfull'
	ELSE
	   begin
		SET @TSQL = 'DBA WARNING: Unable to Set Compatability Level to 90' 
		raiserror(@TSQL,-1,-1)
		SET @error_count = @error_count + 1
		goto label99
	   end	    
	raiserror('', -1,-1) with nowait


	-- FINALIZATION: RETURN SUCCESS/FAILURE --
	label99:

	if @error_count > 0
	   begin
		return (1)
	   end
	Else
	   begin
		return  (0)
	   end

END

