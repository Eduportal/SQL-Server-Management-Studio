select		DBName
FROM		dbaadmin.dbo.dba_DBInfo
WHERE		DB_ID(DBName) Is Null
	AND		DEPLstatus ='y'


select		'ALTER DATABASE ['+dbname+'] SET RECOVERY FULL WITH NO_WAIT'
FROM		dbaadmin.dbo.dba_DBInfo
WHERE		DB_ID(DBName) Is NOT Null
	AND		DEPLstatus ='n'
	AND		DATABASEPROPERTYEX(dbname,'Recovery') != 'FULL'



select		'ALTER DATABASE ['+dbname+'] SET RECOVERY '+cast(DATABASEPROPERTYEX(dbname,'Recovery') as VarChar(100))+' WITH NO_WAIT'
FROM		dbaadmin.dbo.dba_DBInfo
WHERE		DB_ID(DBName) Is NOT Null
	AND		DEPLstatus ='n'
	AND		DATABASEPROPERTYEX(dbname,'Recovery') != 'FULL'