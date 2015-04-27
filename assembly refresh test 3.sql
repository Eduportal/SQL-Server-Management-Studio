CREATE TABLE #Output (ln VarChar(max))

INSERT INTO #Output
exec xp_cmdshell 'wmic qfe list'

SELECT * FROM #Output where ln like '%2926992%'

DROP TABLE #Output




select		*
FROM		dbaadmin.dbo.dbaudf_DirectoryList2('C:\windows\assembly','*.dll',1)
WHERE		Name like 'System.Management%'