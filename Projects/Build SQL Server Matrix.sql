
SELECT		DISTINCT	EnvNum
FROM		(
			select		SQLName
						,REPLACE(DBName,'dbaadmin','|') DBName
						,EnvNum 
			FROM		dba_DBInfo
			WHERE		DBName NOT IN ('master','model','msdb','tempdb','dbaperf','deplinfo','systeminfo','DEPLcontrol','dbacentral','dbTest')
				AND		DBName NOT LIKE 'DBAADMIN_%'
				AND		DBName NOT LIKE 'DBAPerf%'
				
			) Data
WHERE		DBName != '|'



CREATE TABLE [dbo].[#DBA_DBInfo]
	(
	[SQLName] [sysname] NOT NULL
	,[DBName] [sysname] NOT NULL
	,[ENVNum] [sysname] NOT NULL
	,CONSTRAINT PK_CL_DBInfo PRIMARY KEY CLUSTERED ([SQLName] ASC,[DBName] ASC)
	)

	
INSERT INTO	[#DBA_DBInfo]

select		SQLName
			,REPLACE(DBName,'dbaadmin','|')
			,EnvNum 
FROM		dba_DBInfo
WHERE		DBName NOT IN ('master','model','msdb','tempdb','dbaperf','deplinfo','systeminfo','DEPLcontrol','dbacentral','dbTest')
	AND		DBName NOT LIKE 'DBAADMIN_%'
	AND		DBName NOT LIKE 'DBAPerf%'
	AND		SQLName Not Like '%-N%'	
ORDER BY	1,2




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
INTO		#ServerMatrixData
FROM		(
			SELECT		DISTINCT SQLName
						,Port 
			From		DBA_ServerInfo
			WHERE		Active = 'y'
				AND		SQLName Not Like '%-N%'	
			)ActiveServers
LEFT JOIN	(
			select		SQLName
						,EnvNum 
						,REPLACE(REPLACE(dbaadmin.dbo.dbaudf_ConcatenateUnique(DBName),'|,',''),'|','') DBList
			FROM		#dba_DBInfo
			GROUP BY	SQLName,EnvNum
			)DeplDBs
		ON	ActiveServers.SQLName = DeplDBs.SQLName
LEFT JOIN	(
			SELECT		SQLName
						,DBName
			FROM		#DBA_DBInfo
			WHERE		EnvNum = 'production'
				AND		DBName IN
				(
				SELECT		DBName
				FROM		#DBA_DBInfo
				WHERE		EnvNum = 'production'
				GROUP BY	DBName
				HAVING		count(DISTINCT SQLName) = 1
				)
			) UniqueProdDB
		ON	UniqueProdDB.DBName IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(DeplDBs.DBList,','))

LEFT JOIN	(
			SELECT		NONPROD.*
						,PROD.SQLName AS ProdServerMatch
						, PROD.DBList AS ProdDBList		
			FROM		(
						select		SQLName 
									,dbaadmin.dbo.dbaudf_ConcatenateUnique(DBName) DBList
						FROM		#dba_DBInfo
						WHERE		ENVNum != 'production'
							AND		DBName != '|'
						GROUP BY	SQLName
						)NONPROD
			LEFT JOIN	(
						select		SQLName 
									,dbaadmin.dbo.dbaudf_ConcatenateUnique(DBName) DBList
						FROM		#dba_DBInfo
						WHERE		ENVNum = 'production'
							AND		DBName != '|'
						GROUP BY	SQLName
						)PROD
					ON	( nullif(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),1),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(NONPROD.DBList,',')) OR nullif(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),1),'') IS NULL )
					AND	( nullif(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),2),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(NONPROD.DBList,',')) OR nullif(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),2),'') IS NULL )
					AND	( nullif(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),3),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(NONPROD.DBList,',')) OR nullif(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),3),'') IS NULL )
					AND	( nullif(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),4),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(NONPROD.DBList,',')) OR nullif(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),4),'') IS NULL )
					AND	( nullif(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),5),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(NONPROD.DBList,',')) OR nullif(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),5),'') IS NULL )
					AND	( nullif(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),6),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(NONPROD.DBList,',')) OR nullif(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),6),'') IS NULL )
					AND	( nullif(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),7),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(NONPROD.DBList,',')) OR nullif(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),7),'') IS NULL )
					AND	( nullif(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),8),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(NONPROD.DBList,',')) OR nullif(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),8),'') IS NULL )
					AND	( nullif(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),9),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(NONPROD.DBList,',')) OR nullif(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),9),'') IS NULL )
					AND	( nullif(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),10),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(NONPROD.DBList,',')) OR nullif(dbaadmin.dbo.Returnpart(REPLACE(PROD.DBList,',','|'),10),'') IS NULL )
			WHERE		PROD.SQLName IS NOT NULL
			)AllOfProd
		ON	ActiveServers.SQLName = AllOfProd.SQLName
LEFT JOIN	(
			SELECT		NONPROD.*
						,PROD.SQLName AS ProdServerMatch
						, PROD.DBList AS ProdDBList		

			FROM		(
						select		SQLName 
									,dbaadmin.dbo.dbaudf_ConcatenateUnique(DBName) DBList
						FROM		#dba_DBInfo
						WHERE		ENVNum != 'production'
							AND		DBName != '|'
						GROUP BY	SQLName
						)NONPROD
			LEFT JOIN	(
						select		SQLName 
									,dbaadmin.dbo.dbaudf_ConcatenateUnique(DBName) DBList
						FROM		#dba_DBInfo
						WHERE		ENVNum = 'production'
							AND		DBName != '|'
						GROUP BY	SQLName
						)PROD
					ON	( nullif(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),1),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(PROD.DBList,',')) OR nullif(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),1),'') IS NULL )
					AND	( nullif(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),2),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(PROD.DBList,',')) OR nullif(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),2),'') IS NULL )
					AND	( nullif(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),3),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(PROD.DBList,',')) OR nullif(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),3),'') IS NULL )
					AND	( nullif(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),4),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(PROD.DBList,',')) OR nullif(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),4),'') IS NULL )
					AND	( nullif(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),5),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(PROD.DBList,',')) OR nullif(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),5),'') IS NULL )
					AND	( nullif(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),6),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(PROD.DBList,',')) OR nullif(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),6),'') IS NULL )
					AND	( nullif(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),7),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(PROD.DBList,',')) OR nullif(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),7),'') IS NULL )
					AND	( nullif(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),8),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(PROD.DBList,',')) OR nullif(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),8),'') IS NULL )
					AND	( nullif(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),9),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(PROD.DBList,',')) OR nullif(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),9),'') IS NULL )
					AND	( nullif(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),10),'') IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(PROD.DBList,',')) OR nullif(dbaadmin.dbo.Returnpart(REPLACE(NONPROD.DBList,',','|'),10),'') IS NULL )
			WHERE		PROD.SQLName IS NOT NULL
			) SomeOfProd
		ON	ActiveServers.SQLName = SomeOfProd.SQLName
		
ORDER BY	3,1
GO



SELECT		*
FROM		( 
			SELECT		Prod.SQLName+'('+Prod.Port+')'															Prod
						,dbaadmin.dbo.dbaudf_ConcatenateUnique(Alpha.SQLName+'('+Alpha.Port+')')				Alpha
						,dbaadmin.dbo.dbaudf_ConcatenateUnique(beta.SQLName+'('+beta.Port+')')					beta
						,dbaadmin.dbo.dbaudf_ConcatenateUnique(candidate01.SQLName+'('+candidate01.Port+')')	cand01
						,dbaadmin.dbo.dbaudf_ConcatenateUnique(dev01.SQLName+'('+dev01.Port+')') 				dev01
						,dbaadmin.dbo.dbaudf_ConcatenateUnique(dev02.SQLName+'('+dev02.Port+')') 				dev02
						,dbaadmin.dbo.dbaudf_ConcatenateUnique(dev04.SQLName+'('+dev04.Port+')') 				dev04
						,dbaadmin.dbo.dbaudf_ConcatenateUnique(load01.SQLName+'('+load01.Port+')') 				load01
						,dbaadmin.dbo.dbaudf_ConcatenateUnique(load02.SQLName+'('+load02.Port+')') 				load02
						,dbaadmin.dbo.dbaudf_ConcatenateUnique(stage.SQLName+'('+stage.Port+')')				stage
						,dbaadmin.dbo.dbaudf_ConcatenateUnique(test01.SQLName+'('+test01.Port+')') 				test01
						,dbaadmin.dbo.dbaudf_ConcatenateUnique(test02.SQLName+'('+test02.Port+')') 				test02
						,dbaadmin.dbo.dbaudf_ConcatenateUnique(test03.SQLName+'('+test03.Port+')') 				test03
						,dbaadmin.dbo.dbaudf_ConcatenateUnique(test04.SQLName+'('+test04.Port+')') 				test04

						--,dbaadmin.dbo.dbaudf_ConcatenateUnique(Alpha.SQLName)		Alpha
						--,dbaadmin.dbo.dbaudf_ConcatenateUnique(beta.SQLName)		beta
						--,dbaadmin.dbo.dbaudf_ConcatenateUnique(candidate01.SQLName)	cand01
						--,dbaadmin.dbo.dbaudf_ConcatenateUnique(dev01.SQLName)		dev01
						--,dbaadmin.dbo.dbaudf_ConcatenateUnique(dev02.SQLName)		dev02
						--,dbaadmin.dbo.dbaudf_ConcatenateUnique(dev04.SQLName)		dev04
						--,dbaadmin.dbo.dbaudf_ConcatenateUnique(load01.SQLName)		load01
						--,dbaadmin.dbo.dbaudf_ConcatenateUnique(load02.SQLName)		load02
						--,dbaadmin.dbo.dbaudf_ConcatenateUnique(stage.SQLName)		stage
						--,dbaadmin.dbo.dbaudf_ConcatenateUnique(test01.SQLName)		test01
						--,dbaadmin.dbo.dbaudf_ConcatenateUnique(test02.SQLName)		test02
						--,dbaadmin.dbo.dbaudf_ConcatenateUnique(test03.SQLName)		test03
						--,dbaadmin.dbo.dbaudf_ConcatenateUnique(test04.SQLName)		test04

			FROM		(
						SELECT		SQLName
									,Port
									,DBList
						FROM		#ServerMatrixData
						WHERE		ENVnum = 'Production' AND nullif(DBList,'') IS NOT NULL
						) Prod

			LEFT JOIN	(
						SELECT		ProdServerMatch
									,SQLName
									,Port
									,DBList
						FROM		#ServerMatrixData
						WHERE		ENVnum = 'alpha'
							AND		ProdServerMatch IS NOT NULL
						) alpha
					ON	Prod.SQLName = alpha.ProdServerMatch
			LEFT JOIN	(
						SELECT		ProdServerMatch
									,SQLName
									,Port
									,DBList
						FROM		#ServerMatrixData
						WHERE		ENVnum = 'beta'
							AND		ProdServerMatch IS NOT NULL
						) beta			
					ON	Prod.SQLName = beta.ProdServerMatch

						
			LEFT JOIN	(
						SELECT		ProdServerMatch
									,SQLName
									,Port
									,DBList
						FROM		#ServerMatrixData
						WHERE		ENVnum = 'Candidate01'
							AND		ProdServerMatch IS NOT NULL
						) candidate01
					ON	Prod.SQLName = candidate01.ProdServerMatch

						
			LEFT JOIN	(
						SELECT		ProdServerMatch
									,SQLName
									,Port
									,DBList
						FROM		#ServerMatrixData
						WHERE		ENVnum = 'dev01'
							AND		ProdServerMatch IS NOT NULL
						) dev01
					ON	Prod.SQLName = dev01.ProdServerMatch

						
			LEFT JOIN	(
						SELECT		ProdServerMatch
									,SQLName
									,Port
									,DBList
						FROM		#ServerMatrixData
						WHERE		ENVnum = 'dev02'
							AND		ProdServerMatch IS NOT NULL
						) dev02
					ON	Prod.SQLName = dev02.ProdServerMatch

			LEFT JOIN	(
						SELECT		ProdServerMatch
									,SQLName
									,Port
									,DBList
						FROM		#ServerMatrixData
						WHERE		ENVnum = 'dev04'
							AND		ProdServerMatch IS NOT NULL
						) dev04
					ON	Prod.SQLName = dev04.ProdServerMatch
						
			LEFT JOIN	(
						SELECT		ProdServerMatch
									,SQLName
									,Port
									,DBList
						FROM		#ServerMatrixData
						WHERE		ENVnum = 'load01'
							AND		ProdServerMatch IS NOT NULL
						) load01
					ON	Prod.SQLName = load01.ProdServerMatch
						
			LEFT JOIN	(
						SELECT		ProdServerMatch
									,SQLName
									,Port
									,DBList
						FROM		#ServerMatrixData
						WHERE		ENVnum = 'load02'
							AND		ProdServerMatch IS NOT NULL
						) load02
					ON	Prod.SQLName = load02.ProdServerMatch
						
			LEFT JOIN	(
						SELECT		ProdServerMatch
									,SQLName
									,Port
									,DBList
						FROM		#ServerMatrixData
						WHERE		ENVnum = 'stage'
							AND		ProdServerMatch IS NOT NULL
						) stage
					ON	Prod.SQLName = stage.ProdServerMatch
						
			LEFT JOIN	(
						SELECT		ProdServerMatch
									,SQLName
									,Port
									,DBList
						FROM		#ServerMatrixData
						WHERE		ENVnum = 'test01'
							AND		ProdServerMatch IS NOT NULL
						) test01
					ON	Prod.SQLName = test01.ProdServerMatch
						
			LEFT JOIN	(
						SELECT		ProdServerMatch
									,SQLName
									,Port
									,DBList
						FROM		#ServerMatrixData
						WHERE		ENVnum = 'test02'
							AND		ProdServerMatch IS NOT NULL
						) test02
					ON	Prod.SQLName = test02.ProdServerMatch
						
			LEFT JOIN	(
						SELECT		ProdServerMatch
									,SQLName
									,Port
									,DBList
						FROM		#ServerMatrixData
						WHERE		ENVnum = 'test03'
							AND		ProdServerMatch IS NOT NULL
						) test03
					ON	Prod.SQLName = test03.ProdServerMatch
						
			LEFT JOIN	(
						SELECT		ProdServerMatch
									,SQLName
									,Port
									,DBList
						FROM		#ServerMatrixData
						WHERE		ENVnum = 'test04'
							AND		ProdServerMatch IS NOT NULL
						) test04
					ON	Prod.SQLName = test04.ProdServerMatch

			GROUP BY	Prod.SQLName+'('+Prod.Port+')'
			) Data
WHERE		Alpha+beta+cand01+dev01+dev02+dev04+load01+load02+stage+test01+test02+test03+test04 != ''
ORDER BY	1

SELECT		SQLName
			,Port
			,ENVNum
			,DBList
FROM		#ServerMatrixData
WHERE		ENVnum != 'production'
	AND		ProdServerMatch IS NULL


SELECT		T1.SQLName
			,T1.EnvNum
			,T2.SQLName AS ProdServer
			,T2.Port AS ProdPort
			,'SELECT '''+T1.SQLName+''','''+T1.EnvNum+''','''+T2.SQLName+''','''+T2.Port+''' UNION ALL' AS InsertStrings
FROM		[#ServerMatrixData] T1
JOIN		[#ServerMatrixData] T2
	ON		T1.EnvNum != 'production'
	AND		T1.ProdServerMatch = T2.SQLName
ORDER BY	2,1

GO
DROP TABLE [#DBA_DBInfo]
DROP TABLE [#ServerMatrixData]
GO


