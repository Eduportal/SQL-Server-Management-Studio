




WITH		ListDBs
		AS
		(
		select		SQLName
				,dbaadmin.dbo.dbaudf_ConcatenateUnique(DBName) DBs
		FROM		DBA_DBInfo
		GROUP BY	SQLName
		)

select		DI.SQLName
		,dbaadmin.dbo.dbaudf_ConcatenateUnique(DI.DriveName) Drives
		,dbaadmin.dbo.dbaudf_FormatNumber(SUM(DI.DriveSize),20,0) TotalSizeMB
		,DB.DBs
FROM		DBA_DiskInfo DI
JOIN		ListDBs DB
	ON	DI.SQLName = DB.SQLName
WHERE		DI.SQLName IN
		(
		'g1sqla\a'
		,'g1sqlb\b'
		,'seadcpcsqla\a'
		,'seadcaspsqla\a'
		,'seafresqlshra\a'
		,'SEAPSQLSHR02A'
		)	
AND		DI.DriveName !='C'	
AND		DI.active = 'y'
GROUP BY	DI.SQLName,DB.DBs
ORDER BY	1,3

