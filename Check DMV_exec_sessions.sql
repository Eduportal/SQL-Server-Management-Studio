SELECT		Application
		,DBAADMIN.dbo.dbaudf_ReturnPart(REPLACE(program_name,'(','|'),1) ProgramName
		,DBAADMIN.[dbo].[dbaudf_ConcatenateUnique](DBName) DBs
		,MIN(rundate) FirstSeen
		,MAX(rundate) LastSeen
FROM		DBAPERF.DBO.DMV_exec_sessions
--WHERE		Application = 'Enterprise Web Services'
GROUP BY	Application
		,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(program_name,'(','|'),1)
ORDER BY	1,2,3,4

