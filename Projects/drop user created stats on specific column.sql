DECLARE		@sql		NVARCHAR(MAX)
		,@TableName	SYSNAME
		,@ColumnName	SYSNAME

SELECT		@TableName	= ''
		,@ColumnName	= ''
		,@sql		= ''
	
SELECT		@sql = @sql	+ 'DROP STATISTICS ' + QUOTENAME(SCHEMA_NAME(t.schema_id)) 
			+ '.' + QUOTENAME(t.name) 
			+ '.' + QUOTENAME(s.name)
			+ CHAR(13)+CHAR(10)
FROM		sys.stats s
JOIN		sys.tables t
	ON	s.object_id = t.object_id
JOIN		sys.stats_columns sc
	ON	s.object_id = sc.object_id
	AND	s.stats_id = sc.stats_id
JOIN		sys.columns c
	ON	s.object_id = c.object_id
	AND	sc.column_id = c.column_id
WHERE		s.user_created = 1
	AND	t.name = @TableName
	AND	c.name = @ColumnName

PRINT	@SQL
EXEC	(@SQL)
