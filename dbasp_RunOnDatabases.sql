USE DBAADMIN
GO

CREATE TYPE dbo.database_name_list AS TABLE
(database_name SYSNAME NOT NULL);

GO

CREATE PROCEDURE dbo.dbasp_RunOnDatabases
	(
	@sql_command VARCHAR(MAX),
	@system_databases BIT = 1,
	@database_name_like VARCHAR(100) = NULL,
	@database_name_not_like VARCHAR(100) = NULL,
	@database_name_equals VARCHAR(100) = NULL,
	@database_list dbo.database_name_list READONLY
	)
AS
BEGIN
       SET NOCOUNT ON;
       -- Check if there is a database list to parse
       DECLARE @database_list_count INT = (SELECT COUNT(*) FROM @database_list)
      
       DECLARE @database_name VARCHAR(300) -- Stores database name for use in the cursor
       DECLARE @sql_command_to_execute NVARCHAR(MAX) -- Will store the TSQL after the database name has been inserted
       -- Stores our final list of databases to iterate through, after filters have been applied
       DECLARE @database_names TABLE
              (database_name VARCHAR(100))

       DECLARE @SQL VARCHAR(MAX) -- Will store TSQL used to determine database list
       SET @SQL =
       '      SELECT
                     SD.name AS database_name
              FROM sys.databases SD
              WHERE 1 = 1
       '
       IF @system_databases = 0 -- Check if we want to omit system databases
       BEGIN
              SET @SQL = @SQL + '
                     AND SD.name NOT IN (''master'', ''model'', ''msdb'', ''tempdb'')
              '
       END
       IF @database_name_like IS NOT NULL -- Check if there is a LIKE filter and apply it if one exists
       BEGIN
              SET @SQL = @SQL + '
                     AND SD.name LIKE ''%' + @database_name_like + '%''
              '
       END
       IF @database_name_not_like IS NOT NULL -- Check if there is a NOT LIKE filter and apply it if one exists
       BEGIN
              SET @SQL = @SQL + '
                     AND SD.name NOT LIKE ''%' + @database_name_not_like + '%''
              '
       END
       IF @database_name_equals IS NOT NULL -- Check if there is an equals filter and apply it if one exists
       BEGIN
              SET @SQL = @SQL + '
                     AND SD.name = ''' + @database_name_equals + '''
              '
       END
       IF @database_list_count > 0 AND @database_list_count IS NOT NULL
       BEGIN
              SELECT
                     DBLIST.database_name
              INTO ##database_list
              FROM @database_list DBLIST
             
              SET @SQL = @SQL + '
                     AND SD.name IN (SELECT database_name FROM ##database_list)
              '
       END
      
       -- Prepare database name list
       INSERT INTO @database_names
               ( database_name )
       EXEC (@SQL)
      
       DECLARE db_cursor CURSOR FOR SELECT database_name FROM @database_names
       OPEN db_cursor

       FETCH NEXT FROM db_cursor INTO @database_name

       WHILE @@FETCH_STATUS = 0
       BEGIN
              SET @sql_command_to_execute = REPLACE(@sql_command, '?', @database_name) -- Replace "?" with the database name
      
              EXEC sp_executesql @sql_command_to_execute

              FETCH NEXT FROM db_cursor INTO @database_name
       END

       CLOSE db_cursor;
       DEALLOCATE db_cursor;

       IF (SELECT OBJECT_ID('tempdb..##database_list')) IS NOT NULL
       BEGIN
              DROP TABLE ##database_list
       END
END
GO


