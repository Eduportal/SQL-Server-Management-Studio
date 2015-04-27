

;WITH		CurrentVersion
		AS
		(
		SELECT		SQL_Version
				,MAX(OPSDBVersion_DBAADMIN) OPSDBVersion_DBAADMIN
		FROM		Serverinfo
		WHERE		Active = 'y'
		GROUP BY	SQL_Version
		)

SELECT		SI.SQLName
		,SI.SQL_Version
		,SI.OPSDBVersion_DBAADMIN
		,CV.OPSDBVersion_DBAADMIN OPSDBVersion_DBAADMIN_Current
FROM		Serverinfo SI
JOIN		CurrentVersion CV
	ON	SI.SQL_Version = CV.SQL_Version
WHERE		SI.OPSDBVersion_DBAADMIN < CV.OPSDBVersion_DBAADMIN
	AND	SI.Active = 'y'
						