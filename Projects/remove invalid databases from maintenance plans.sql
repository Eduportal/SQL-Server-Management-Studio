
DECLARE	@TSQL	VarChar(8000)
SET	@TSQL	= ''

SELECT		@TSQL=@TSQL+'EXEC msdb.dbo.sp_delete_maintenance_plan_db '''+CAST(plan_id AS VarChar(50))+''','''+database_name+'''' +CHAR(13)+CHAR(10)
FROM		msdb.dbo.sysdbmaintplan_databases
WHERE		DB_ID(database_name) IS NULL
	AND	database_name NOT LIKE 'All%'

IF @@ROWCOUNT > 0
	EXEC	(@TSQL)


