SET NOCOUNT ON

DECLARE @cmd		VarChar(8000)
DECLARE @central_server	sysname
DECLARE @Machine	sysname
DECLARE @Instance	sysname
DECLARE @Last		DateTime
DECLARE @LastDate	VarChar(12)
DECLARE @LastTime	VarChar(8)
DECLARE	@LogBufferMin	INT

SET		@LogBufferMin = -20

SELECT		@Last	= DATEADD(mi,@LogBufferMin,MAX(CAST(left(RIGHT('00000000' + convert(varchar,sjh.run_date),8),4) 
			+ '-' + SUBSTRING(RIGHT('00000000' + convert(varchar,sjh.run_date),8),5,2) 
			+ '-' + right(RIGHT('00000000' + convert(varchar,sjh.run_date),8),2) 
			+ ' ' + left(RIGHT('000000' + convert(varchar,sjh.run_time),6),2) 
			+ ':' +	SUBSTRING(RIGHT('000000' + convert(varchar,sjh.run_time),6), 3,2) 
			+ ':' + right(RIGHT('000000' + convert(varchar,sjh.run_time),6), 2) AS DateTime)))
FROM		msdb..sysjobhistory sjh
Inner Join	msdb..sysjobs sj
	ON	sj.job_id = sjh.job_id
WHERE		step_id = 0
	AND	sj.name = 'DBA - Test LogParser' 		
	AND	sjh.run_status = 1	

SET		@Last = COALESCE(@Last,GetDate()-30)	 

SELECT		@Machine	= REPLACE(@@servername,'\'+@@SERVICENAME,'')
		,@Instance	= REPLACE(@@SERVICENAME,'MSSQLSERVER','')
		,@LastDate	= LEFT(CONVERT(VarChar(20),@Last,120),10)
		,@LastTime	= RIGHT(CONVERT(VarChar(20),@Last,120),8)
		,@central_server = env_detail 
from		dbaadmin.dbo.Local_ServerEnviro 
where		env_type = 'CentralServer'

IF @Instance = '' SET @Instance = '-'

Select	@cmd = '%windir%\system32\LogParser "file:\\'
		+ @central_server + '\' + @central_server 
		+ '_filescan\Aggregates\Queries\'
		+ 'ServerEvent.sql?startdate=' + @LastDate + '+starttime='
		+ @LastTime +'+machine='
		+ @Machine + '+instance='
		+ @Instance + '+machineinstance='
		+ UPPER(REPLACE(@@servername,'\','$')) + '+OutputFile=\\' 
		+ @central_server + '\' + @central_server 
		+ '_filescan\Aggregates\ServerEvent_'
		+ UPPER(REPLACE(@@servername,'\','$'))
		+ '.w3c" -i:EVT -o:W3C -fileMode:0 -binaryFormat:ASC -oDQuotes:ON -encodeDelim:ON -resolveSIDs:ON'
print @cmd

		
exec master..xp_cmdshell @cmd