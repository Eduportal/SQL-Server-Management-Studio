
CREATE TABLE #RegData ([Value] VarChar(255),[Data] VarChar(2048))
DECLARE @SharePath VarChar(2048)
		,@ShareName VarChar(2048)
		,@DynamicString VarChar(8000)
		,@InstanceShares VarChar(max)
		,@GlobalShares VarChar(max)
		
SELECT	@InstanceShares		= 'backup,dba_archive,dbasql,mdf,ldf,ndf,log,SQLjob_logs,xxx'
		,@GlobalShares		= 'builds,dba_mail'

SET		@DynamicString = 'MKDIR C:\SQLDBALinks\ByInstance\' + REPLACE(@@SERVICENAME,'MSSQLSERVER','')
EXEC	xp_CmdShell @DynamicString


-- =============================================
-- CREATE INSTANCE SHARE LINKS
-- =============================================
DECLARE InstanceShareCursor CURSOR
FOR
SELECT REPLACE(@@SERVERNAME,'\','$')+'_'+SplitValue FROM dbaadmin.dbo.dbaudf_split(@InstanceShares,',')

OPEN InstanceShareCursor
FETCH NEXT FROM InstanceShareCursor INTO @ShareName
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
			SELECT	@SharePath = NULL
			DELETE #RegData

			-- GET SHARE PATH
			INSERT INTO #RegData
			EXEC master..xp_regread @rootkey='HKEY_LOCAL_MACHINE' 
				,@key			= 'SYSTEM\CurrentControlSet\Services\lanmanserver\Shares'
				,@value_name	= @ShareName
				,@SharePath		= @SharePath OUTPUT 

			SELECT	@SharePath = REPLACE([Data],'Path=','') 
			FROM	#RegData
			WHERE	[Data] Like 'Path=%'

			-- CREATE JUNCTIONS (SYMBOLIC LINKS)
			SET		@ShareName = REPLACE(@ShareName,REPLACE(@@SERVERNAME,'\','$')+'_','')
			
			SET		@DynamicString = 'MKDIR C:\SQLDBALinks\ByShare\'+@ShareName
			EXEC	xp_CmdShell @DynamicString
			
			-- BY INSTANCE
			SET		@DynamicString = 'LINKD C:\SQLDBALinks\ByInstance\' + REPLACE(@@SERVICENAME,'MSSQLSERVER','') + '\' + @ShareName + ' /D'
			EXEC	xp_CmdShell @DynamicString
			
			SET		@DynamicString = 'LINKD C:\SQLDBALinks\ByInstance\' + REPLACE(@@SERVICENAME,'MSSQLSERVER','') + '\' + @ShareName + ' "' + @SharePath + '"'
			IF nullif(@SharePath,'') IS NOT NULL		
				EXEC	xp_CmdShell @DynamicString
			
			-- BY SHARE
			SET		@DynamicString = 'LINKD C:\SQLDBALinks\ByShare\' + @ShareName + '\' + REPLACE(@@SERVICENAME,'MSSQLSERVER','') + ' /D'
			EXEC	xp_CmdShell @DynamicString
			
			SET		@DynamicString = 'LINKD C:\SQLDBALinks\ByShare\' + @ShareName + '\' + REPLACE(@@SERVICENAME,'MSSQLSERVER','') + ' "'+ @SharePath + '"'
			IF nullif(@SharePath,'') IS NOT NULL		
				EXEC	xp_CmdShell @DynamicString

	END
	FETCH NEXT FROM InstanceShareCursor INTO @ShareName
END
CLOSE InstanceShareCursor
DEALLOCATE InstanceShareCursor

		
-- =============================================
-- CREATE GLOBAL SHARE LINKS
-- =============================================
DECLARE GlobalShareCursor CURSOR
FOR
SELECT REPLACE(@@SERVERNAME,'\','$')+'_'+SplitValue FROM dbaadmin.dbo.dbaudf_split(@GlobalShares,',')

OPEN GlobalShareCursor
FETCH NEXT FROM GlobalShareCursor INTO @ShareName
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
			SELECT	@SharePath = NULL
			DELETE #RegData

			-- GET SHARE PATH
			INSERT INTO #RegData
			EXEC master..xp_regread @rootkey='HKEY_LOCAL_MACHINE' 
				,@key			= 'SYSTEM\CurrentControlSet\Services\lanmanserver\Shares'
				,@value_name	= @ShareName
				,@SharePath		= @SharePath OUTPUT 

			SELECT	@SharePath = REPLACE([Data],'Path=','') 
			FROM	#RegData
			WHERE	[Data] Like 'Path=%'

			-- CREATE JUNCTIONS (SYMBOLIC LINKS)
			SET		@ShareName = REPLACE(@ShareName,REPLACE(@@SERVERNAME,'\','$')+'_','')
			
			SET		@DynamicString = 'MKDIR C:\SQLDBALinks\Global\'+@ShareName
			EXEC	xp_CmdShell @DynamicString
			
			SET		@DynamicString = 'LINKD C:\SQLDBALinks\Global\' + @ShareName + ' /D'
			EXEC	xp_CmdShell @DynamicString

			SET		@DynamicString = 'LINKD C:\SQLDBALinks\Global\' + @ShareName + ' "'+ @SharePath + '"'
			IF nullif(@SharePath,'') IS NOT NULL		
				EXEC	xp_CmdShell @DynamicString
	END
	FETCH NEXT FROM GlobalShareCursor INTO @ShareName
END
CLOSE GlobalShareCursor
DEALLOCATE GlobalShareCursor
				
DROP TABLE #RegData
GO		
		