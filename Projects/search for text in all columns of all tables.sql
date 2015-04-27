

set nocount on

DECLARE @SearchText nvarchar(max)
SET	@SearchText = 'Unable to start mail session'	


DECLARE
    @SchemaName VARCHAR(50),
    @TableName VARCHAR(50),
    @ColumnName VARCHAR(50);
BEGIN
    DECLARE textColumns CURSOR FOR
    SELECT s.name, tab.name, c.name
    FROM sys.columns c, sys.types t, sys.tables tab, sys.schemas s
    WHERE s.schema_id = tab.schema_id AND tab.object_id = c.object_id AND c.user_type_id = t.user_type_id
    AND t.name in ('text','ntext','varchar','char','nvarchar','nchar');

    OPEN textColumns

    FETCH NEXT FROM textColumns
    INTO @SchemaName, @TableName, @ColumnName

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @sql NVARCHAR(MAX),
                @ParamDef NVARCHAR(MAX),
                @result NVARCHAR(MAX);              
        SET @sql = N'SELECT '''+@TableName+''' [TableName],' + @ColumnName + ' FROM ' + @SchemaName + '.' + @TableName + ' WHERE ' + @ColumnName + ' LIKE ''%'+@SearchText+'%''';
        SET @ParamDef = N'@resultOut NVARCHAR(MAX) OUTPUT';

        EXEC sp_executesql @sql, @ParamDef, @resultOut = @result OUTPUT;

        PRINT 'Column = ' + @TableName + '.' + @ColumnName + ', Value = ' + @result;
        FETCH NEXT FROM textColumns
        INTO @SchemaName, @TableName, @ColumnName       
    END
    CLOSE textColumns;
    DEALLOCATE textColumns;
END