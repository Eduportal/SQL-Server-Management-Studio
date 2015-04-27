xp_cmdshell 'nbtstat -RR'


DECLARE @Domain NVARCHAR(100)


Create table #loginconfig(name sysname null, config_value sysname null)
Insert into #loginconfig exec master.dbo.xp_loginconfig 'default domain'

EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE', 'SYSTEM\CurrentControlSet\services\Tcpip\Parameters', N'Domain',@Domain OUTPUT

DELETE	[dbaadmin].[dbo].[Local_ServerEnviro] WHERE [env_type] IN ('FQDN','DefaultDomain')
INSERT INTO   [dbaadmin].[dbo].[Local_ServerEnviro]   

SELECT 'FQDN',Cast(SERVERPROPERTY('MachineName') as nvarchar) + '.' + @Domain
UNION ALL
SELECT 'DefaultDomain',config_value from #loginconfig where name = 'default domain'

SELECT * 
FROM [dbaadmin].[dbo].[Local_ServerEnviro]
WHERE [env_type] IN ('FQDN','DefaultDomain')