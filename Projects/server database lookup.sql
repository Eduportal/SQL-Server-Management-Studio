DECLARE	@FilterBy	VarChar(50)
DECLARE @Filter		VarChar(50)

SELECT	@FilterBy	= 'all'
		,@Filter	= 'wcds'

SELECT	DISTINCT
		UPPER(T2.ACTIVE) [Active]
		, UPPER(T1.DBName) DBName
		, UPPER(REPLACE(COALESCE(T2.SQLEnv,'Unknown'),'production','prod'))   ENVname
		, UPPER(T2.DomainName) DomainName
		, UPPER(T1.SQLName) SQLName
		, CAST(T2.port AS VARCHAR(10)) SQLPort
		, UPPER(T1.SQLName)+ ',' + CAST(T2.port AS VARCHAR(10)) SQLLink
		, 'file://\\'+UPPER(T2.ServerName) ShareLink
		, 'mailto://' + REPLACE(COALESCE(T3.NotificationGroupName,''),',',';') + ';'+ REPLACE(COALESCE(T3.OwnerName,''),',',';') MailLink
		, 'NOTES:'+CHAR(13)+CHAR(10)
		+ '_________________________________________________'+CHAR(13)+CHAR(10)
		+ 'Notification Group : '
		+ COALESCE(T3.NotificationGroupName,'')+CHAR(13)+CHAR(10)
		+ 'Owner : '
		+ COALESCE(T3.OwnerName,'')+CHAR(13)+CHAR(10)
		+ 'QA Contact : '
		+ COALESCE(T3.QAContactName,'')+CHAR(13)+CHAR(10)
		+ 'Location Contact : '
		+ COALESCE(T3.LocationContactName,'')+CHAR(13)+CHAR(10)
		+ 'Maintenance Window : '
		+ COALESCE(T3.MaintenanceWindow,'')+CHAR(13)+CHAR(10)
		+ 'Customer Notes : '
		+ COALESCE(T3.CustomerNotes,'')+CHAR(13)+CHAR(10) AS [Notes]
		, CASE @FilterBy
			WHEN 'Server'		THEN UPPER(T1.SQLName)+' ' +UPPER(T1.DBName)
			WHEN 'Database'		THEN UPPER(T1.DBName)+' '+UPPER(REPLACE(COALESCE(T2.SQLEnv,'Unknown'),'production','prod'))+' '+UPPER(T1.SQLName)
			WHEN 'Environment'	THEN UPPER(REPLACE(COALESCE(T2.SQLEnv,'Unknown'),'production','prod'))+' '+UPPER(T1.SQLName)+' ' + UPPER(T1.DBName)
			WHEN 'Domain'		THEN UPPER(T2.DomainName)+' '+UPPER(REPLACE(COALESCE(T2.SQLEnv,'Unknown'),'production','prod'))+' '+UPPER(T1.SQLName)+' ' + UPPER(T1.DBName)
								ELSE UPPER(T2.ACTIVE)+' '+UPPER(T1.DBName)+' '+UPPER(REPLACE(COALESCE(T2.SQLEnv,'Unknown'),'production','prod'))+' '+UPPER(T2.DomainName)+' '+UPPER(T1.SQLName)
			END AS SortBy
		
FROM		SEAFRESQLDBA01.dbaadmin.dbo.DBA_DBInfo T1
LEFT JOIN	SEAFRESQLDBA01.dbaadmin.dbo.DBA_ServerInfo T2
	ON		T1.SQLName=T2.SQLName
LEFT JOIN	SEAFRESQLDBA01.dbaadmin.dbo.EnlightenServers T3
	ON		T2.ServerName = T3.ShortName
	
WHERE		CASE @FilterBy
			WHEN 'Server'		THEN UPPER(T1.SQLName)
			WHEN 'Database'		THEN UPPER(T1.DBName)
			WHEN 'Environment'	THEN UPPER(REPLACE(COALESCE(T2.SQLEnv,'Unknown'),'production','prod'))
			WHEN 'Domain'		THEN UPPER(T2.DomainName)
			WHEN 'Notes'		THEN 	+ T3.NotificationGroupName+CHAR(13)+CHAR(10)
										+ T3.OwnerName+CHAR(13)+CHAR(10)
										+ T3.QAContactName+CHAR(13)+CHAR(10)
										+ T3.LocationContactName+CHAR(13)+CHAR(10)
										+ T3.MaintenanceWindow+CHAR(13)+CHAR(10)
										+ T3.CustomerNotes+CHAR(13)+CHAR(10)
			ELSE @Filter + '%'
			END LIKE @Filter + '%'	
ORDER BY	11