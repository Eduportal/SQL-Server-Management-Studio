DECLARE @TextLine VarChar(MAX)
DECLARE @Text VarChar(max)
DECLARE TextCursor CURSOR
FOR
-- SELECT QUERY FOR CURSOR
SELECT		st.text
from		sys.dm_exec_cached_plans cp
cross apply	sys.dm_exec_sql_text(cp.plan_handle) st
--cross apply	sys.dm_exec_query_plan(cp.plan_handle) qp 
WHERE st.Text Like '%SEAPSQLRYL0A%' 
OPEN TextCursor;
FETCH TextCursor INTO @Text;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
	
		RAISERROR ('---------****************************************************************************************-----------',-1,-1) WITH NOWAIT
		RAISERROR ('---------****************************************************************************************-----------',-1,-1) WITH NOWAIT
		RAISERROR ('---------****************************************************************************************-----------',-1,-1) WITH NOWAIT
		PRINT ''
		PRINT ''
		
		exec dbaadmin.dbo.dbasp_printLarge @Text

		PRINT ''
		PRINT ''
		RAISERROR ('---------****************************************************************************************-----------',-1,-1) WITH NOWAIT
		RAISERROR ('---------****************************************************************************************-----------',-1,-1) WITH NOWAIT
		RAISERROR ('---------****************************************************************************************-----------',-1,-1) WITH NOWAIT
		PRINT ''
		PRINT ''

		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM TextCursor INTO @Text;
END
CLOSE TextCursor;
DEALLOCATE TextCursor;

