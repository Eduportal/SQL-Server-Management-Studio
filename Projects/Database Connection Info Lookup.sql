WITH	LoginsUsed	AS
	(
	SELECT		[DBname]
			,dbaadmin.dbo.dbaudf_ConcatenateUnique ([LoginName]) LoginNames
	FROM		[DEPLinfo].[dbo].[Clean_Security_Logins]
	GROUP BY	DBName
	)	
select		T2.DBName
		,T2.ENVnum
		,T1.SQLNAME
		,T1.port
		,T3.LoginNames
		
FROM		dbo.DBA_ServerInfo T1

JOIN		dbo.DBA_DBInfo T2
	ON	T1.sqlname = T2.SQLName

LEFT JOIN	LoginsUsed T3
	ON	T2.DBname = T3.DBName
		
WHERE		T2.DBName IN ('SoundtrackDB','PumpAudio_Live','PumpAudioWeb','PACueSheet')
	AND	T1.SQLName != 'SEAFRESQLRPT01'
	
ORDER BY	1,2	