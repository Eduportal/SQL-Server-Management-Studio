--select 'vsdbcmd /a:import /cs:"Data Source='+@@SERVERNAME+';Initial Catalog='+name+';Trusted_Connection=True;" /model:"\\seafresqldba01\DBA_Docs\SourceCode\Opperations\'+@@SERVERNAME+'.'+name+'.dbschema" /dsp:sql'
--FROM sysdatabases



--SEAW005850

--vsdbcmd /a:Deploy /manifest:"g:\ProductCatalog.dbschema" /cs:"Data Source=SEAW005850;Integrated Security=true"




SELECT	'.\deploy\vsdbcmd /a:import /cs:"Data Source='+si.SQLName+','+si.Port
		+ ';Initial Catalog='+di.DBName+';User ID=DBAsledridge;Password=Tigger4U;" /model:".\'
		+ di.DBName+'.dbschema" /dsp:sql'
		+
FROM		DBACENTRAL.dbo.DBA_ServerInfo	si
JOIN		DBACENTRAL.dbo.DBA_DBInfo	di
	ON	si.sqlname = di.sqlname
	
	
WHERE		si.SQLEnv	= 'production'
	AND	di.DBName	= 'ProductCatalog'	
