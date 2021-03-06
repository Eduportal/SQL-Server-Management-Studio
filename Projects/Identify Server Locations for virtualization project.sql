USE [dbacentral]
GO


WITH	[DB_info_stage]
	AS
	(
	select	* 
	FROM	dbo.DBA_DBInfo
	WHERE	envName Like 'stag%'
	)

	,[DB_info_test]
	AS
	(
	select	* 
	FROM	dbo.DBA_DBInfo
	WHERE	envName = 'test'
	)

	,[DB_info_load]
	AS
	(
	select	* 
	FROM	dbo.DBA_DBInfo
	WHERE	envName = 'load'
	)

	,[DB_info_production]
	AS
	(
	select	* 
	FROM	dbo.DBA_DBInfo
	WHERE	envName = 'production'
	)

	,[DB_info_alpha]
	AS
	(
	select	* 
	FROM	dbo.DBA_DBInfo
	WHERE	envName = 'alpha'
	)

	,[DB_info_dev]
	AS
	(
	select	* 
	FROM	dbo.DBA_DBInfo
	WHERE	envName = 'dev'
	)

	,[DB_info_candidate]
	AS
	(
	select	* 
	FROM	dbo.DBA_DBInfo
	WHERE	envName = 'candidate'
	)

SELECT		T1.Appl_desc

		,MAX(COALESCE(
			CASE WHEN COALESCE(T2.BaselineFolder,'') = '' THEN '' ELSE T2.BaselineFolder + COALESCE(' (' + T2.BaselineServername + ')','') END
			,CASE WHEN COALESCE(T3.BaselineFolder,'') = '' THEN '' ELSE T3.BaselineFolder + COALESCE(' (' + T3.BaselineServername + ')','') END
			,CASE WHEN COALESCE(T4.BaselineFolder,'') = '' THEN '' ELSE T4.BaselineFolder + COALESCE(' (' + T4.BaselineServername + ')','') END
			,CASE WHEN COALESCE(T5.BaselineFolder,'') = '' THEN '' ELSE T5.BaselineFolder + COALESCE(' (' + T5.BaselineServername + ')','') END
			,CASE WHEN COALESCE(T6.BaselineFolder,'') = '' THEN '' ELSE T6.BaselineFolder + COALESCE(' (' + T6.BaselineServername + ')','') END
			,CASE WHEN COALESCE(T7.BaselineFolder,'') = '' THEN '' ELSE T7.BaselineFolder + COALESCE(' (' + T7.BaselineServername + ')','') END
			,CASE WHEN COALESCE(T8.BaselineFolder,'') = '' THEN '' ELSE T8.BaselineFolder + COALESCE(' (' + T8.BaselineServername + ')','') END
			,''
			)) AS [BaselineFolder]
		,replace(dbaadmin.dbo.dbaudf_ConcatenateUnique(T1.DBName_Cleaned),',',', ') AS [Databases] 
		,replace(dbaadmin.dbo.dbaudf_ConcatenateUnique(T2.SQLName),',',', ') AS [Dev]
		,replace(dbaadmin.dbo.dbaudf_ConcatenateUnique(T3.SQLName),',',', ') AS [Test]
		,replace(dbaadmin.dbo.dbaudf_ConcatenateUnique(T4.SQLName),',',', ') AS [Candidate]
		,replace(dbaadmin.dbo.dbaudf_ConcatenateUnique(T5.SQLName),',',', ') AS [Load]
		,replace(dbaadmin.dbo.dbaudf_ConcatenateUnique(T6.SQLName),',',', ') AS [Stage]
		,replace(dbaadmin.dbo.dbaudf_ConcatenateUnique(T7.SQLName),',',', ') AS [Prod]
		,replace(dbaadmin.dbo.dbaudf_ConcatenateUnique(T8.SQLName),',',', ') AS [Alpha]
		,T9.CommentText

FROM		(
		SELECT		DISTINCT
				COALESCE(
					CASE WHEN COALESCE(T1A.Appl_desc,'') = '' THEN NULL ELSE T1A.Appl_desc END
					,T1C.Appl_desc
					,'Unknown'
					) AS [Appl_desc]
				--,T1A.BaselineFolder
				,T1A.SQLName
				,T1A.DBName
				,T1B.DBName_Cleaned + CASE WHEN T1B.DBName = T1B.DBName_Cleaned THEN '' ELSE '%' END AS [DBName_Cleaned]
				
		FROM		dbo.DBA_DBInfo		T1A
		LEFT JOIN	dbo.DBA_DBNameCleaner	T1B
			ON	T1A.DBName = T1B.DBName
			
		LEFT JOIN	dbo.db_ApplCrossRef T1C
			ON	T1A.DBName = T1C.db_name
			AND	(
				T1C.companionDB_name IN (SELECT DISTINCT DBName FROM dbo.DBA_DBInfo WHERE SQLName = T1A.SQLName)
			OR	COALESCE(T1C.companionDB_name,'') = ''
				)
		) T1
LEFT JOIN	DB_Info_dev		T2
	ON	T1.SQLName = T2.SQLName
	AND	T1.DBName = T2.DBName
	
LEFT JOIN	DB_info_test		T3
	ON	T1.SQLName = T3.SQLName
	AND	T1.DBName = T3.DBName

LEFT JOIN	DB_Info_candidate	T4
	ON	T1.SQLName = T4.SQLName
	AND	T1.DBName = T4.DBName

LEFT JOIN	DB_Info_load		T5
	ON	T1.SQLName = T5.SQLName
	AND	T1.DBName = T5.DBName
	
LEFT JOIN	DB_Info_stage		T6
	ON	T1.SQLName = T6.SQLName
	AND	T1.DBName = T6.DBName

LEFT JOIN	DB_Info_production	T7
	ON	T1.SQLName = T7.SQLName
	AND	T1.DBName = T7.DBName

LEFT JOIN	DB_Info_alpha		T8
	ON	T1.SQLName = T8.SQLName
	AND	T1.DBName = T8.DBName

LEFT JOIN	dbo.DBA_CommentInfo T9
	ON	T1.Appl_desc = T9.Appl_desc





WHERE		T1.DBName Not Like '%_new'
	AND	T1.DBName Not Like '%_old'
	AND	T1.DBName Not Like '%_test'
	AND	T1.[Appl_desc] != 'Operations'

GROUP BY	T1.Appl_desc
		,T9.CommentText

ORDER BY	1,2,3


