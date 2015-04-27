DECLARE @ObjectName	SYSNAME

DECLARE ObjectCursor CURSOR
FOR
-- SELECT QUERY FOR CURSOR
SELECT	name
FROM	sys.objects
WHERE	is_ms_shipped = 0 

OPEN ObjectCursor;
FETCH ObjectCursor INTO @ObjectName;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
	
		EXEC [dbo].[sp_Help_Doc] @ObjectName,'FORCE_UPD_EXPROP'

		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM ObjectCursor INTO @ObjectName;
END
CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;
