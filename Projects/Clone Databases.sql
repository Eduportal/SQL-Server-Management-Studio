DECLARE		@ScriptPath		VarChar(8000)
			,@DynamicCode	VarChar(8000)
			,@ServerString1	sysname
			,@ServerString2	sysname
			,@ServerString3	sysname
			,@ServerToClone sysname
			
	SELECT		@ServerToClone		= COALESCE(@ServerToClone,REPLACE(@@ServerName,'-N',''),@@ServerName)		
	SELECT		@ServerString1		= LEFT(@ServerToClone,CHARINDEX ('\',@ServerToClone+'\')-1)
				,@ServerString2		= REPLACE(@ServerToClone,'\','$')
				,@ServerString3		= CASE WHEN CHARINDEX ('\',@ServerToClone) > 0 THEN REPLACE(@ServerToClone,'\','(')+')' ELSE @ServerToClone END

		SELECT		@ScriptPath			= '\\'+REPLACE(@@SERVERNAME,'\'+@@SERVICENAME,'')+'\'+REPLACE(@@SERVERNAME,'\','$')+'_dba_archive\BeforeClone\'+@ServerString3+'_SYScreatedatabases.gsql'
					,@DynamicCode		= ''
					
		SELECT		@DynamicCode	= @DynamicCode +
					'IF DB_ID('''+DBName+''') IS NOT NULL DROP DATABASE ['+DBName+'];'+CHAR(13)+CHAR(10)
					+ 'SET @DynamicText = ''CREATE DATABASE ['+DBName+'];'''+CHAR(13)+CHAR(10)
					+ 'EXEC (@DynamicText)'+CHAR(13)+CHAR(10)
		FROM		(
					SELECT		DISTINCT REPLACE(Line,'Create database ','') [DBName]
					FROM		master.dbo.dbaudf_FileAccess_Read(@ScriptPath,NULL)
					WHERE		line like 'Create database %'
						AND		line NOT Like '%master'
						AND		line NOT Like '%model'
						AND		line NOT Like '%msdb'
						AND		line NOT Like '%tempdb'
						AND		line NOT Like '%dbaadmin'
						AND		line NOT Like '%dbaperf'
						AND		line NOT Like '%deplinfo'
					) DBs


		SELECT		@DynamicCode	= 'DECLARE @DynamicText VarChar(8000)'+CHAR(13)+CHAR(10)+@DynamicCode
		PRINT		(@DynamicCode)
		EXEC		(@DynamicCode)
		

EXECUTE [master].[dbo].[dbasp_CloneDBs] @ServerToClone = @ServerToClone, @OpsDBs = 0,@DeployableDBS = 1		