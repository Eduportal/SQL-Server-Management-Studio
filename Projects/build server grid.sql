

;WITH		DBInfo
		AS
		(
		SELECT		DISTINCT
				SQLName
				,REPLACE(DBName,'dbaadmin','|') [DBName]
				,ENVnum 
		FROM		DBA_DBInfo
		WHERE		DBName NOT IN ('master','model','msdb','tempdb','dbaperf','deplinfo','systeminfo','DEPLcontrol','dbacentral','dbTest','SQLdeploy')
			AND	DBName NOT LIKE 'DBAADMIN_%'
			AND	DBName NOT LIKE 'DBAPerf%'
			AND	SQLName NOT LIKE '%-N%'
			AND	SQLName NOT LIKE '%DEPLOY%'
			AND	SQLName NOT LIKE '%DPLY%'	
		)
		,ActiveServers
		AS
		(
		SELECT		DISTINCT 
				SQLName
				,Port 
		FROM		DBA_ServerInfo
		WHERE		active = 'y'
			AND	SQLName NOT LIKE '%-N%'
			AND	SQLName NOT LIKE '%DEPLOY%'
			AND	SQLName NOT LIKE '%DPLY%'				
		)
		,DeplDBs
		AS
		(
			SELECT		SQLName
					,ENVnum 
					,REPLACE(REPLACE(dbaadmin.dbo.dbaudf_Concatenate(DBName),'|,',''),'|','') DBList
			FROM		DBInfo
			GROUP BY	SQLName,ENVnum
		)
		,UniqueProdDB
		AS
		(
		SELECT		SQLName
				,DBName
		FROM		DBInfo
		WHERE		ENVnum = 'production'
			AND	DBName IN	(
						SELECT		DBName
						FROM		DBInfo
						WHERE		ENVnum = 'production'
						GROUP BY	DBName
						HAVING		Count(DISTINCT SQLName) = 1
						)
		)
		,NONPROD
		AS
		(
		SELECT		SQLName 
				,dbaadmin.dbo.dbaudf_Concatenate(DBName) DBList
		FROM		DBInfo
		WHERE		ENVnum != 'production'
			AND	DBName != '|'
		GROUP BY	SQLName
		)
		,ONLYPROD
		AS
		(
		SELECT		SQLName 
				,dbaadmin.dbo.dbaudf_Concatenate(DBName) DBList
		FROM		DBInfo
		WHERE		ENVnum = 'production'
			AND	DBName != '|'
		GROUP BY	SQLName
		)
		,AllOfProd
		AS
		(
		SELECT		NONPROD.*
				,PROD.SQLName AS ProdServerMatch
				, PROD.DBList AS ProdDBList		
		FROM		NONPROD
		LEFT JOIN	ONLYPROD PROD
			ON	( NULLIF(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),1),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(NONPROD.DBList,',')) OR NULLIF(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),1),'') IS NULL )
			AND	( NULLIF(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),2),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(NONPROD.DBList,',')) OR NULLIF(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),2),'') IS NULL )
			AND	( NULLIF(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),3),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(NONPROD.DBList,',')) OR NULLIF(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),3),'') IS NULL )
			AND	( NULLIF(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),4),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(NONPROD.DBList,',')) OR NULLIF(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),4),'') IS NULL )
			AND	( NULLIF(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),5),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(NONPROD.DBList,',')) OR NULLIF(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),5),'') IS NULL )
			AND	( NULLIF(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),6),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(NONPROD.DBList,',')) OR NULLIF(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),6),'') IS NULL )
			AND	( NULLIF(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),7),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(NONPROD.DBList,',')) OR NULLIF(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),7),'') IS NULL )
			AND	( NULLIF(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),8),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(NONPROD.DBList,',')) OR NULLIF(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),8),'') IS NULL )
			AND	( NULLIF(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),9),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(NONPROD.DBList,',')) OR NULLIF(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),9),'') IS NULL )
			AND	( NULLIF(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),10),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(NONPROD.DBList,',')) OR NULLIF(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),10),'') IS NULL )
		WHERE		PROD.SQLName IS NOT NULL
		)
		,SomeOfProd
		AS
		(
		SELECT		NONPROD.*
				,PROD.SQLName AS ProdServerMatch
				,PROD.DBList AS ProdDBList		
		FROM		NONPROD
		LEFT JOIN	ONLYPROD PROD
			ON	( NULLIF(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),1),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(PROD.DBList,',')) OR NULLIF(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),1),'') IS NULL )
			AND	( NULLIF(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),2),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(PROD.DBList,',')) OR NULLIF(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),2),'') IS NULL )
			AND	( NULLIF(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),3),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(PROD.DBList,',')) OR NULLIF(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),3),'') IS NULL )
			AND	( NULLIF(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),4),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(PROD.DBList,',')) OR NULLIF(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),4),'') IS NULL )
			AND	( NULLIF(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),5),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(PROD.DBList,',')) OR NULLIF(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),5),'') IS NULL )
			AND	( NULLIF(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),6),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(PROD.DBList,',')) OR NULLIF(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),6),'') IS NULL )
			AND	( NULLIF(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),7),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(PROD.DBList,',')) OR NULLIF(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),7),'') IS NULL )
			AND	( NULLIF(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),8),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(PROD.DBList,',')) OR NULLIF(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),8),'') IS NULL )
			AND	( NULLIF(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),9),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(PROD.DBList,',')) OR NULLIF(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),9),'') IS NULL )
			AND	( NULLIF(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),10),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(PROD.DBList,',')) OR NULLIF(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),10),'') IS NULL )
		WHERE		PROD.SQLName IS NOT NULL
		) 
		--,ServerMatrixData		
		--AS
		--(
		SELECT		DISTINCT
				ActiveServers.SQLName
				,ActiveServers.Port
				,DeplDBs.EnvNum
				,DeplDBs.DBList
				,CASE DeplDBs.EnvNum
					WHEN 'Production' THEN ActiveServers.SQLName
					ELSE COALESCE(AllOfProd.ProdServerMatch,SomeOfProd.ProdServerMatch,UniqueProdDB.SQLName) END AS ProdServerMatch
				,CASE DeplDBs.EnvNum
					WHEN 'Production' THEN DeplDBs.DBList
					ELSE COALESCE(AllOfProd.ProdDBList,SomeOfProd.ProdDBList,UniqueProdDB.DBName) END AS ProdDBList
		FROM		ActiveServers
		LEFT JOIN	DeplDBs
			ON	ActiveServers.SQLName = DeplDBs.SQLName
		LEFT JOIN	UniqueProdDB
			ON	UniqueProdDB.DBName IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(DeplDBs.DBList,','))
		LEFT JOIN	AllOfProd
			ON	ActiveServers.SQLName = AllOfProd.SQLName
		LEFT JOIN	SomeOfProd
			ON	ActiveServers.SQLName = SomeOfProd.SQLName
			AND	AllOfProd.SQLName IS NULL
		ORDER BY 3,1			
		--)
		--,PROD
		--AS
		--(
		--SELECT		SQLName
		--		,Port
		--		,DBList
		--FROM		ServerMatrixData
		--WHERE		ENVnum = 'Production' AND NULLIF(DBList,'') IS NOT NULL
		--)
		--,ALPHA
		--AS
		--(
		--SELECT		ProdServerMatch
		--		,SQLName
		--		,Port
		--		,DBList
		--FROM		ServerMatrixData
		--WHERE		ENVnum = 'alpha' 
		--	AND	ProdServerMatch IS NOT NULL
		--)
		--,BETA
		--AS
		--(
		--SELECT		ProdServerMatch
		--		,SQLName
		--		,Port
		--		,DBList
		--FROM		ServerMatrixData
		--WHERE		ENVnum = 'beta' 
		--	AND	ProdServerMatch IS NOT NULL
		--)		
		--,CANDIDATE01
		--AS
		--(
		--SELECT		ProdServerMatch
		--		,SQLName
		--		,Port
		--		,DBList
		--FROM		ServerMatrixData
		--WHERE		ENVnum = 'candidate01' 
		--	AND	ProdServerMatch IS NOT NULL
		--)
		--,DEV01
		--AS
		--(
		--SELECT		ProdServerMatch
		--		,SQLName
		--		,Port
		--		,DBList
		--FROM		ServerMatrixData
		--WHERE		ENVnum = 'dev01' 
		--	AND	ProdServerMatch IS NOT NULL
		--)		
		--,DEV02
		--AS
		--(
		--SELECT		ProdServerMatch
		--		,SQLName
		--		,Port
		--		,DBList
		--FROM		ServerMatrixData
		--WHERE		ENVnum = 'dev02' 
		--	AND	ProdServerMatch IS NOT NULL
		--)
		--,DEV04
		--AS
		--(
		--SELECT		ProdServerMatch
		--		,SQLName
		--		,Port
		--		,DBList
		--FROM		ServerMatrixData
		--WHERE		ENVnum = 'dev04' 
		--	AND	ProdServerMatch IS NOT NULL
		--)		
		--,LOAD01
		--AS
		--(
		--SELECT		ProdServerMatch
		--		,SQLName
		--		,Port
		--		,DBList
		--FROM		ServerMatrixData
		--WHERE		ENVnum = 'load01' 
		--	AND	ProdServerMatch IS NOT NULL
		--)
		--,LOAD02
		--AS
		--(
		--SELECT		ProdServerMatch
		--		,SQLName
		--		,Port
		--		,DBList
		--FROM		ServerMatrixData
		--WHERE		ENVnum = 'load02' 
		--	AND	ProdServerMatch IS NOT NULL
		--)		
		--,STAGE
		--AS
		--(
		--SELECT		ProdServerMatch
		--		,SQLName
		--		,Port
		--		,DBList
		--FROM		ServerMatrixData
		--WHERE		ENVnum = 'stage' 
		--	AND	ProdServerMatch IS NOT NULL
		--)
		--,TEST01
		--AS
		--(
		--SELECT		ProdServerMatch
		--		,SQLName
		--		,Port
		--		,DBList
		--FROM		ServerMatrixData
		--WHERE		ENVnum = 'test01' 
		--	AND	ProdServerMatch IS NOT NULL
		--)		
		--,TEST02
		--AS
		--(
		--SELECT		ProdServerMatch
		--		,SQLName
		--		,Port
		--		,DBList
		--FROM		ServerMatrixData
		--WHERE		ENVnum = 'test02' 
		--	AND	ProdServerMatch IS NOT NULL
		--)
		--,TEST03
		--AS
		--(
		--SELECT		ProdServerMatch
		--		,SQLName
		--		,Port
		--		,DBList
		--FROM		ServerMatrixData
		--WHERE		ENVnum = 'test03' 
		--	AND	ProdServerMatch IS NOT NULL
		--)		
		--,TEST04
		--AS
		--(
		--SELECT		ProdServerMatch
		--		,SQLName
		--		,Port
		--		,DBList
		--FROM		ServerMatrixData
		--WHERE		ENVnum = 'test04' 
		--	AND	ProdServerMatch IS NOT NULL
		--)
		--,DATA
		--AS
		--( 
		--SELECT		Prod.SQLName+'('+Prod.Port+')'															Prod
		--		,dbaadmin.dbo.dbaudf_Concatenate(Alpha.SQLName+'('+Alpha.Port+')')				Alpha
		--		,dbaadmin.dbo.dbaudf_Concatenate(beta.SQLName+'('+beta.Port+')')					beta
		--		,dbaadmin.dbo.dbaudf_Concatenate(candidate01.SQLName+'('+candidate01.Port+')')	cand01
		--		,dbaadmin.dbo.dbaudf_Concatenate(dev01.SQLName+'('+dev01.Port+')') 				dev01
		--		,dbaadmin.dbo.dbaudf_Concatenate(dev02.SQLName+'('+dev02.Port+')') 				dev02
		--		,dbaadmin.dbo.dbaudf_Concatenate(dev04.SQLName+'('+dev04.Port+')') 				dev04
		--		,dbaadmin.dbo.dbaudf_Concatenate(load01.SQLName+'('+load01.Port+')') 				load01
		--		,dbaadmin.dbo.dbaudf_Concatenate(load02.SQLName+'('+load02.Port+')') 				load02
		--		,dbaadmin.dbo.dbaudf_Concatenate(stage.SQLName+'('+stage.Port+')')				Stage
		--		,dbaadmin.dbo.dbaudf_Concatenate(test01.SQLName+'('+test01.Port+')') 				test01
		--		,dbaadmin.dbo.dbaudf_Concatenate(test02.SQLName+'('+test02.Port+')') 				test02
		--		,dbaadmin.dbo.dbaudf_Concatenate(test03.SQLName+'('+test03.Port+')') 				test03
		--		,dbaadmin.dbo.dbaudf_Concatenate(test04.SQLName+'('+test04.Port+')') 				test04
		--FROM		Prod
		--LEFT JOIN	ALPHA
		--		ON	Prod.SQLName = alpha.ProdServerMatch
		--LEFT JOIN	BETA			
		--		ON	Prod.SQLName = beta.ProdServerMatch
		--LEFT JOIN	candidate01
		--		ON	Prod.SQLName = candidate01.ProdServerMatch
		--LEFT JOIN	dev01
		--		ON	Prod.SQLName = dev01.ProdServerMatch
		--LEFT JOIN	dev02
		--		ON	Prod.SQLName = dev02.ProdServerMatch
		--LEFT JOIN	dev04
		--		ON	Prod.SQLName = dev04.ProdServerMatch
		--LEFT JOIN	load01
		--		ON	Prod.SQLName = load01.ProdServerMatch
		--LEFT JOIN	load02
		--		ON	Prod.SQLName = load02.ProdServerMatch
		--LEFT JOIN	Stage
		--		ON	Prod.SQLName = stage.ProdServerMatch
		--LEFT JOIN	test01
		--		ON	Prod.SQLName = test01.ProdServerMatch
		--LEFT JOIN	test02
		--		ON	Prod.SQLName = test02.ProdServerMatch
		--LEFT JOIN	test03
		--		ON	Prod.SQLName = test03.ProdServerMatch
		--LEFT JOIN	test04
		--		ON	Prod.SQLName = test04.ProdServerMatch
		--GROUP BY	Prod.SQLName+'('+Prod.Port+')'
		--)

--SELECT		*
--FROM		DATA
--WHERE		Alpha+beta+cand01+dev01+dev02+dev04+load01+load02+Stage+test01+test02+test03+test04 != ''
--ORDER BY	1

--SELECT		SQLName
--		,Port
--		,ENVnum
--		,DBList
--FROM		ServerMatrixData
--WHERE		ENVnum != 'production'
--	AND	ProdServerMatch IS NULL


--SELECT		T1.SQLName
--		,T1.EnvNum
--		,T2.SQLName AS ProdServer
--		,T2.Port AS ProdPort
--		,'SELECT '''+T1.SQLName+''','''+T1.EnvNum+''','''+T2.SQLName+''','''+T2.Port+''' UNION ALL' AS InsertStrings
--FROM		[ServerMatrixData] T1
--JOIN		[ServerMatrixData] T2
--	ON	T1.EnvNum != 'production'
--	--AND	T2.EnvNum = 'production'
--	AND	T1.ProdServerMatch = T2.SQLName
--ORDER BY	2,1




