DECLARE		@ObjectName	SYSNAME
		,@ObjectType	SYSNAME
		,@IsCLR		bit
		,@Msg		nVarChar(4000)

DECLARE ObjectCursor CURSOR
FOR
-- SELECT QUERY FOR CURSOR
SELECT	QUOTENAME(OBJECT_SCHEMA_NAME(object_id)) +'.'+ QUOTENAME(OBJECT_NAME(object_id)) name
	,CASE type
		WHEN 'AF' THEN 'FUNCTION'	-- Aggregate function (CLR)
		WHEN 'FS' THEN 'FUNCTION'	-- Assembly (CLR) scalar-function
		WHEN 'FT' THEN 'FUNCTION'	-- Assembly (CLR) table-valued function
		WHEN 'PC' THEN 'PROCEDURE'	-- Assembly (CLR) stored-procedure
		WHEN 'FN' THEN 'FUNCTION'	-- SQL scalar function
		WHEN 'IF' THEN 'FUNCTION'	-- SQL inline table-valued function
		WHEN 'TF' THEN 'FUNCTION'	-- SQL table-valued-function
		WHEN 'P'  THEN 'PROCEDURE'	-- SQL Stored Procedure
		WHEN 'X'  THEN 'PROCEDURE'	-- Extended stored procedure
		WHEN 'S'  THEN 'TABLE'		-- System base table
		WHEN 'IT' THEN 'TABLE'		-- Internal table
		WHEN 'TT' THEN 'TABLE'		-- Table type
		WHEN 'U'  THEN 'TABLE'		-- Table (user-defined)
		WHEN 'V'  THEN 'VIEW'		-- View
		ELSE 'UNKNOWN' END type
	,CASE	WHEN type IN ('AF','FS','FT','PC')
		THEN 1 ELSE 0 END [IsCLR]
FROM	sys.objects
WHERE	is_ms_shipped = 0 
ORDER BY 3,2,1
OPEN ObjectCursor;
FETCH ObjectCursor INTO @ObjectName,@ObjectType,@IsCLR;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
		IF @ObjectType = 'UNKNOWN'
			RAISERROR('-- UNKNOWN OBJECT TYPE FOR %s',-1,-1,@ObjectName) WITH NOWAIT
		ELSE
		BEGIN
			SET @ObjectName = QUOTENAME(DB_NAME())+'.'+@ObjectName
			SET @Msg = '-- CHECKING ' + CASE @IsCLR WHEN 1 THEN 'CLR ' ELSE '' END + @ObjectType + ' ' + @ObjectName
			RAISERROR(@Msg,-1,-1) WITH NOWAIT
			EXEC [dbo].[sp_Help_Doc] @ObjectName,'BUILD_IF_MISSING'
		END
		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM ObjectCursor INTO @ObjectName,@ObjectType,@IsCLR;
END
CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;


