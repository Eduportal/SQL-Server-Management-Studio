DECLARE @PDC SYSNAME
DECLARE @CMD VarChar(8000)

CREATE TABLE #Results(Line VarChar(max))

INSERT INTO #Results(Line)
EXEC xp_CmdShell 'srvinfo'

SELECT @PDC = REPLACE(Line,'PDC: \\','') From #Results WHERE Line like 'PDC:%'
DROP TABLE #Results

SET @CMD = 'tracert ' + @PDC
EXEC xp_cmdshell @CMD