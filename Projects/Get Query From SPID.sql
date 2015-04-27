DECLARE	@SPID	INT
DECLARE @Handle binary(20)

SET	@SPID	= 163

SELECT	@Handle = sql_handle 
FROM	master.dbo.sysprocesses 
WHERE	spid = @SPID

SELECT * 
FROM ::fn_get_sql(@Handle)

exec sp_who2 @SPID

