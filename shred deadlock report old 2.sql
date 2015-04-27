DECLARE		@TSQL		VarChar(max) =

'USE [?];
SELECT		DB_Name()											[DBName]
		,XEventData.Xevent.value(''@timestamp'', ''datetime2(3)'')					[TimeStamp]
		,getutcdate()											[now]
		,DATEDIFF(minute,XEventData.Xevent.value(''@timestamp'', ''datetime2(3)''),GetutcDate())	[MinAgo]
		,CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/resource-list[1]/pagelock[1]/@objectname'', ''varchar(200)'')	[PagelockObject]
		,CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/resource-list[1]/objectlock[1]/@objectname'', ''varchar(200)'')	[DeadlockObject]
		,CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/resource-list[1]/keylock[1]/@objectname'', ''varchar(200)'')	[KeyLockObject] 
		,CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/resource-list[1]/keylock[1]/@indexname'', ''varchar(200)'')	[KeyLockIndex]
 
		,CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/resource-list[1]/keylock[1]/@hobtid'', ''varchar(200)'')	[hobtid1] 
		,CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/resource-list[1]/keylock[2]/@hobtid'', ''varchar(200)'')	[hobtid2]

		,(SELECT OBJECT_SCHEMA_NAME(object_id)+''.''+OBJECT_NAME(object_id) FROM sys.partitions WHERE hobt_id = CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/resource-list[1]/keylock[1]/@hobtid'', ''varchar(200)'')) [Object1]
		,(SELECT OBJECT_SCHEMA_NAME(object_id)+''.''+OBJECT_NAME(object_id) FROM sys.partitions WHERE hobt_id = CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/resource-list[1]/keylock[2]/@hobtid'', ''varchar(200)'')) [Object2]

		,CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/process-list[1]/process[1]/@waitresource'', ''varchar(200)'') [WR1]
		,CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/process-list[1]/process[2]/@waitresource'', ''varchar(200)'') [WR2]

		,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/process-list[1]/process[1]/@waitresource'', ''varchar(200)''),'':'',''|''),''('',''|''),1) [WR1A]
		,DB_NAME(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/process-list[1]/process[1]/@waitresource'', ''varchar(200)''),'':'',''|''),''('',''|''),2)) [WR1B]
		,(SELECT OBJECT_SCHEMA_NAME(object_id)+''.''+OBJECT_NAME(object_id) FROM sys.partitions WHERE hobt_id = dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/process-list[1]/process[1]/@waitresource'', ''varchar(200)''),'':'',''|''),''('',''|''),3)) [WR1C]

		,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/process-list[1]/process[2]/@waitresource'', ''varchar(200)''),'':'',''|''),''('',''|''),1) [WR2A]
		,DB_NAME(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/process-list[1]/process[2]/@waitresource'', ''varchar(200)''),'':'',''|''),''('',''|''),2)) [WR2B]
		,(SELECT OBJECT_SCHEMA_NAME(object_id)+''.''+OBJECT_NAME(object_id) FROM sys.partitions WHERE hobt_id = dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/process-list[1]/process[2]/@waitresource'', ''varchar(200)''),'':'',''|''),''('',''|''),3)) [WR2C]

		,CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/process-list[1]/process[1]/inputbuf[1]'', ''varchar(1000)'') [IB1]
		,CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/process-list[1]/process[2]/inputbuf[1]'', ''varchar(1000)'') [IB2]


		,CASE	WHEN RIGHT(LTRIM(RTRIM(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/process-list[1]/process[1]/inputbuf[1]'', ''varchar(1000)''),''['',''|''),'']'',''|''),''Database Id ='',''|''),''Object Id ='',''|''),1))),4) = ''Proc''
			THEN 
			    OBJECT_NAME	(
					LTRIM(RTRIM(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/process-list[1]/process[1]/inputbuf[1]'', ''varchar(1000)''),''['',''|''),'']'',''|''),''Database Id ='',''|''),''Object Id ='',''|''),4)))
					,LTRIM(RTRIM(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/process-list[1]/process[1]/inputbuf[1]'', ''varchar(1000)''),''['',''|''),'']'',''|''),''Database Id ='',''|''),''Object Id ='',''|''),3)))
					) ELSE ''XXX'' END [IBO1]

		,CASE	WHEN RIGHT(LTRIM(RTRIM(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/process-list[1]/process[2]/inputbuf[1]'', ''varchar(1000)''),''['',''|''),'']'',''|''),''Database Id ='',''|''),''Object Id ='',''|''),1))),4) = ''Proc''
			THEN 
			    OBJECT_NAME	(
					LTRIM(RTRIM(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/process-list[1]/process[2]/inputbuf[1]'', ''varchar(1000)''),''['',''|''),'']'',''|''),''Database Id ='',''|''),''Object Id ='',''|''),4)))
					,LTRIM(RTRIM(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/process-list[1]/process[2]/inputbuf[1]'', ''varchar(1000)''),''['',''|''),'']'',''|''),''Database Id ='',''|''),''Object Id ='',''|''),3)))
					) END [IBO2]

		--,CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML)
		,CAST(XEventData.XEvent.value(''(data/value)[1]'', ''varchar(max)'') AS XML) [xml_deadlock_report]


FROM		(
		SELECT		CAST(target_data AS XML) [TargetData]
		FROM		sys.dm_xe_session_targets
		JOIN		sys.dm_xe_sessions
			ON	event_session_address = address
		WHERE		name = ''system_health''
			AND	target_name = ''ring_buffer''
		) [Data]
CROSS APPLY	TargetData.nodes (''RingBufferTarget/event[@name="xml_deadlock_report"]'') AS XEventData (XEvent)
CROSS APPLY	XEventData.Xevent.nodes (''data/value'') AS datavalue(c)

WHERE		DB_NAME(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(CAST(datavalue.c.value(''(./text())[1]'', ''nvarchar(max)'') AS XML).value(''/deadlock[1]/process-list[1]/process[1]/@waitresource'', ''varchar(200)''),'':'',''|''),''('',''|''),2)) = DB_NAME()

ORDER BY	2 desc'


EXEC dbaadmin.dbo.dbasp_RunOnDatabases  @TSQL


--CREATE TYPE dbo.database_name_list AS TABLE
--(database_name SYSNAME NOT NULL);

--GO

--CREATE PROCEDURE dbo.dbasp_RunOnDatabases
--	(
--	@sql_command VARCHAR(MAX),
--	@system_databases BIT = 1,
--	@database_name_like VARCHAR(100) = NULL,
--	@database_name_not_like VARCHAR(100) = NULL,
--	@database_name_equals VARCHAR(100) = NULL,
--	@database_list dbo.database_name_list READONLY
--	)
--AS
--BEGIN
--       SET NOCOUNT ON;
--       -- Check if there is a database list to parse
--       DECLARE @database_list_count INT = (SELECT COUNT(*) FROM @database_list)
      
--       DECLARE @database_name VARCHAR(300) -- Stores database name for use in the cursor
--       DECLARE @sql_command_to_execute NVARCHAR(MAX) -- Will store the TSQL after the database name has been inserted
--       -- Stores our final list of databases to iterate through, after filters have been applied
--       DECLARE @database_names TABLE
--              (database_name VARCHAR(100))

--       DECLARE @SQL VARCHAR(MAX) -- Will store TSQL used to determine database list
--       SET @SQL =
--       '      SELECT
--                     SD.name AS database_name
--              FROM sys.databases SD
--              WHERE 1 = 1
--       '
--       IF @system_databases = 0 -- Check if we want to omit system databases
--       BEGIN
--              SET @SQL = @SQL + '
--                     AND SD.name NOT IN (''master'', ''model'', ''msdb'', ''tempdb'')
--              '
--       END
--       IF @database_name_like IS NOT NULL -- Check if there is a LIKE filter and apply it if one exists
--       BEGIN
--              SET @SQL = @SQL + '
--                     AND SD.name LIKE ''%' + @database_name_like + '%''
--              '
--       END
--       IF @database_name_not_like IS NOT NULL -- Check if there is a NOT LIKE filter and apply it if one exists
--       BEGIN
--              SET @SQL = @SQL + '
--                     AND SD.name NOT LIKE ''%' + @database_name_not_like + '%''
--              '
--       END
--       IF @database_name_equals IS NOT NULL -- Check if there is an equals filter and apply it if one exists
--       BEGIN
--              SET @SQL = @SQL + '
--                     AND SD.name = ''' + @database_name_equals + '''
--              '
--       END
--       IF @database_list_count > 0 AND @database_list_count IS NOT NULL
--       BEGIN
--              SELECT
--                     DBLIST.database_name
--              INTO ##database_list
--              FROM @database_list DBLIST
             
--              SET @SQL = @SQL + '
--                     AND SD.name IN (SELECT database_name FROM ##database_list)
--              '
--       END
      
--       -- Prepare database name list
--       INSERT INTO @database_names
--               ( database_name )
--       EXEC (@SQL)
      
--       DECLARE db_cursor CURSOR FOR SELECT database_name FROM @database_names
--       OPEN db_cursor

--       FETCH NEXT FROM db_cursor INTO @database_name

--       WHILE @@FETCH_STATUS = 0
--       BEGIN
--              SET @sql_command_to_execute = REPLACE(@sql_command, '?', @database_name) -- Replace "?" with the database name
      
--              EXEC sp_executesql @sql_command_to_execute

--              FETCH NEXT FROM db_cursor INTO @database_name
--       END

--       CLOSE db_cursor;
--       DEALLOCATE db_cursor;

--       IF (SELECT OBJECT_ID('tempdb..##database_list')) IS NOT NULL
--       BEGIN
--              DROP TABLE ##database_list
--       END
--END
--GO


