CREATE TABLE #TempDBSpace(KB INT)
exec sp_msforeachdb '
INSERT INTO #TempDBSpace
EXEC (''DBCC CHECKDB (?) WITH ESTIMATEONLY'')
'
SELECT SUM(KB) [KBNeeded] From #TempDBSpace
GO
DROP TABLE #TempDBSpace
GO