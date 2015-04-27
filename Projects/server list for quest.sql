

SELECT		'MSSQL'--,SQLEnv
		,ServerName
		,REPLACE(REPLACE(SQLName,ServerName+'\',''),ServerName,'')
		,Port
FROM		dbo.DBA_ServerInfo
WHERE		Active = 'y'
	AND	DomainName = 'AMER'
	AND	SQLEnv NOT IN ('dev','test','production','candidate','beta')