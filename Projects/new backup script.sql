SET NOCOUNT ON

DECLARE	@Feature_Clone	bit
DECLARE	@ServerToClone	sysname
DECLARE @DynamicCode VARCHAR(8000)
DECLARE @DBName SYSNAME
			,@machinename		VarChar(8000)
			,@instancename		VarChar(8000)
			,@ServerName		varchar(8000)
			,@ServiceExt		varchar(8000)
			
SELECT			@DynamicCode		= ''
				,@instancename		= isnull('\'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
				,@ServerName		= REPLACE(@@SERVERNAME,@instancename,'')
				,@machinename		= convert(nvarchar(100), serverproperty('machinename')) + @instancename
				,@ServiceExt		= isnull('$'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
				,@Feature_Clone		= 1
				,@ServerToClone		= COALESCE(@ServerToClone,	CASE @Feature_Clone 
																WHEN 0 THEN @@SERVERNAME 
																ELSE	CASE -- PROGRAMATIC DETERMINATIONS
																			WHEN @@SERVERNAME Like 'GMSSQLTEST02%' THEN REPLACE(@@SERVERNAME,'Test02','Test01')
																			ELSE COALESCE(@ServerToClone,REPLACE(@machinename,'-N',''),@@ServerName) 
																		END
															END)


SELECT		@DynamicCode = @DynamicCode+CHAR(13)+CHAR(10)
			+'EXEC dbaadmin.dbo.dbasp_BackupDBs @DBName='''+Name+''',@target_path=''\\'+REPLACE(@@SERVERNAME,'\'+@@SERVICENAME,'')
			+'\'+REPLACE(@@SERVERNAME,'\','$')+'_backup'',@backup_name='''+Name+''',@DeletePrevious = ''Before'''+CHAR(13)+CHAR(10)
FROM		Master..sysdatabases
WHERE		name NOT LIKE 'ASPState%'
    and		name NOT IN ('tempdb','master', 'msdb', 'model', 'pubs', 'Northwind','deplinfo')
	and		name NOT IN (select db_name From dbaadmin.dbo.db_sequence)

SET			@DynamicCode	= 'sqlcmd -S' + @ServerToClone + ' -E -Q"'+@DynamicCode+'"'

IF @@ServerName = 'ASPSQLTEST01-N\A'
BEGIN
	--PRINT @DynamicCode
	EXEC master.sys.xp_cmdshell @DynamicCode
END



--SET @DynamicCode	= 'sqlcmd -S' + @@ServerName + ' -E -Q"EXEC dbaadmin.dbo.dbasp_check_SQLhealth @rpt_recipient=''' + @HealthCheckRecip + '''"'
--INSERT INTO #ExecOutput(TextOutput)
--EXEC master.sys.xp_cmdshell @DynamicCode





--EXEC dbaadmin.dbo.dbasp_BackupDBs @DBName='dbaadmin',@target_path='\\ASPSQLTEST01-N\ASPSQLTEST01-N$A_backup',@backup_name='dbaadmin',@DeletePrevious = 'Before'

--EXEC dbaadmin.dbo.dbasp_BackupDBs @DBName='dbaperf',@target_path='\\ASPSQLTEST01-N\ASPSQLTEST01-N$A_backup',@backup_name='dbaperf',@DeletePrevious = 'Before'

--EXEC dbaadmin.dbo.dbasp_BackupDBs @DBName='Gestalt',@target_path='\\ASPSQLTEST01-N\ASPSQLTEST01-N$A_backup',@backup_name='Gestalt',@DeletePrevious = 'Before'

--EXEC dbaadmin.dbo.dbasp_BackupDBs @DBName='Getty_Artists',@target_path='\\ASPSQLTEST01-N\ASPSQLTEST01-N$A_backup',@backup_name='Getty_Artists',@DeletePrevious = 'Before'


--EXEC dbaadmin.dbo.dbasp_SYSrestoreBYsingledb @DBName='Gestalt'




