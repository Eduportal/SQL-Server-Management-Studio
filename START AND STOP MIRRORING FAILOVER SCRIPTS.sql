-- START MIRRORING

DECLARE @DBName		SYSNAME
DECLARE @JobName	SYSNAME

DECLARE DatabaseListCursor CURSOR
FOR
-- SELECT QUERY FOR CURSOR (CUSTOMIZED FOR THIS SERVER)
SELECT 'Getty_Images_US_Inc_Custom' UNION ALL
SELECT 'Getty_Images_US_Inc__MSCRM' UNION ALL
SELECT 'Getty_Images_CRM_GENESYS'

BEGIN TRY
	EXEC sp_addlinkedserver @server='DYN_DBA_RMT',@srvproduct='',@provider='SQLNCLI',@datasrc=@@SERVERNAME
END TRY
BEGIN CATCH
	IF @@ERROR = 15028
		RAISERROR(' Linked Server Already Exists',-1,-1) WITH NOWAIT
END CATCH


OPEN DatabaseListCursor;
FETCH DatabaseListCursor INTO @DBName;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
	
		insert into dbaadmin.dbo.Local_ServerEnviro values('mirror_failover_override', getdate())

		EXEC [dbaadmin].[dbo].[dbasp_DBMirror_Control] 
				@Function		= 'START' 
				,@DBName		= @DBName
				,@ServerName	= 'ASHPCRMSQL11'

		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM DatabaseListCursor INTO @DBName;
END
CLOSE DatabaseListCursor;
DEALLOCATE DatabaseListCursor;
GO



-- STOP MIRRORING

DECLARE @DBName		SYSNAME
DECLARE @JobName	SYSNAME

DECLARE DatabaseListCursor CURSOR
FOR
-- SELECT QUERY FOR CURSOR (CUSTOMIZED FOR THIS SERVER)
SELECT 'Getty_Images_US_Inc_Custom' UNION ALL
SELECT 'Getty_Images_US_Inc__MSCRM' UNION ALL
SELECT 'Getty_Images_CRM_GENESYS'

BEGIN TRY
	EXEC sp_addlinkedserver @server='DYN_DBA_RMT',@srvproduct='',@provider='SQLNCLI',@datasrc=@@SERVERNAME
END TRY
BEGIN CATCH
	IF @@ERROR = 15028
		RAISERROR(' Linked Server Already Exists',-1,-1) WITH NOWAIT
END CATCH


OPEN DatabaseListCursor;
FETCH DatabaseListCursor INTO @DBName;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
	
		insert into dbaadmin.dbo.Local_ServerEnviro values('mirror_failover_override', getdate())

		EXEC [dbaadmin].[dbo].[dbasp_DBMirror_Control] 
				@Function		= 'OFF' 
				,@DBName		= @DBName
				,@ServerName	= 'ASHPCRMSQL11'

		EXEC ('RESTORE DATABASE ['+@DBName+'] WITH RECOVERY')
		EXEC ('DROP DATABASE ['+@DBName+']')

		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM DatabaseListCursor INTO @DBName;
END
CLOSE DatabaseListCursor;
DEALLOCATE DatabaseListCursor;
GO