
select		*
			,(FreeSpace*100.0)/ISNULL(NULLIF(TotalSize,0),1) AS [PercentFree] 
From		dbaadmin.dbo.dbaudf_ListDrives();



exec xp_cmdshell 'icacls F:\ /setowner BUILTIN\Administrators /T /C /Q'

exec xp_cmdshell 'iCACLS F:\ /T /C /Q /grant BUILTIN\Administrators:(OI)(CI)F /inheritance:e'

exec xp_cmdshell 'xCACLS F:\ /T /C /P BUILTIN\Administrators:O /Y'

-- CAN ALSO BE USED TO CLEAR RECYCLE BIN
-- exec xp_CmdShell 'attrib F:\* -s -r -h /S /D'
-- exec xp_cmdshell 'rd /S /Q F:\$RECYCLE.BIN\'
-- exec xp_cmdshell 'rd /S /Q "F:\System Volume Information\"'

exec xp_cmdshell 'echo hello > F:\test.txt'
exec xp_cmdshell 'del F:\test.txt'





SELECT		Directory
			,SUM(cast(size AS Float)/POWER(1024,3)) 
FROM		dbaadmin.[dbo].[dbaudf_DirectoryList2] ('F:\',NULL,1)
GROUP BY	Directory


SELECT		*
FROM		dbaadmin.[dbo].[dbaudf_DirectoryList2] ('F:\',NULL,1)
ORDER BY	Size desc


:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\ALL_dbaadmin_32_CLR.sql
GO