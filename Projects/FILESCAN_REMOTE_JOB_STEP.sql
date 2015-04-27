
DECLARE @cmd VarChar(8000)
DECLARE @central_server sysname
DECLARE @Machine sysname
DECLARE @Instance sysname
DECLARE @DateStamp VarChar(8)
DECLARE @Date DateTime
DECLARE @DaysAgo INT

SET		@DaysAgo = 1
SET		@Date = CAST(CONVERT(VarChar(12),getdate()-(@DaysAgo-1),101)AS DateTime)

SELECT		@Machine	= REPLACE(@@servername,'\'+@@SERVICENAME,'')
		,@Instance	= REPLACE(@@SERVICENAME,'MSSQLSERVER','')
		,@DateStamp	= CAST(YEAR(@Date) AS VarChar(4))
					+ RIGHT('00'+CAST(MONTH(@Date)AS VarChar(4)),2)
					+ RIGHT('00'+CAST(Day(@Date)AS VarChar(4)),2)
		,@central_server = env_detail 
from	dbaadmin.dbo.Local_ServerEnviro 
where	env_type = 'CentralServer'


Select	@cmd = '%windir%\system32\LogParser "file:\\'
		+ @central_server + '\' + @central_server 
		+ '_filescan\Aggregates\Queries\'
		+ 'SQLErrorLog.sql?daysago='
		+ CAST(@DaysAgo AS VarChar(10)) +'+machine='
		+ @Machine + '+instance='
		+ @Instance + '+machineinstance='
		+ UPPER(REPLACE(@@servername,'\','$')) + '+OutputFile=\\' 
		+ @central_server + '\' + @central_server 
		+ '_filescan\Aggregates\SQLErrorLOG_'
		+ UPPER(REPLACE(@@servername,'\','$')) + '_'+ @DateStamp + '.log" -i:TEXTLINE -o:W3C -fileMode:1'

print @cmd
exec master..xp_cmdshell @cmd