SELECT		name     
			,database_id 
			,user_access_desc  
			,state_desc   
			,is_cleanly_shutdown 
			,(select SqlEnv from dbaadmin.dbo.dba_ServerInfo) SqlEnv
FROM		sys.databases
WHERE		name = 'Bundle'

IF DB_ID('Bundle') IS NOT NULL
BEGIN
	IF (select SqlEnv from dbaadmin.dbo.dba_ServerInfo) != 'production' 
	BEGIN
		SELECT 'Not Production'
		DROP DATABASE [Bundle]


	END
	ELSE
	BEGIN
		SELECT 'Production'

		ALTER DATABASE [Bundle] 
		SET RESTRICTED_USER, OFFLINE
		WITH ROLLBACK IMMEDIATE;


	END
END
ELSE
	SELECT 'Bundle DATABASE DOES NOT EXIST'


SELECT		name     
			,database_id 
			,user_access_desc  
			,state_desc   
			,is_cleanly_shutdown 
			,(select SqlEnv from dbaadmin.dbo.dba_ServerInfo) SqlEnv
FROM		sys.databases
WHERE		name = 'Bundle'