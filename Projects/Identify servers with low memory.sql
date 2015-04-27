WITH	ClusterNodes
AS	(
	SELECT	ClusterName
		,NodeName
	FROM	(
		SELECT	ClusterName	
			,clustNode01 NodeName
		From	dbo.DBA_ClusterInfo
		UNION
		SELECT	ClusterName	
			,clustNode02
		From	dbo.DBA_ClusterInfo
		UNION
		SELECT	ClusterName	
			,clustNode03
		From	dbo.DBA_ClusterInfo
		UNION
		SELECT	ClusterName	
			,clustNode04
		From	dbo.DBA_ClusterInfo
		UNION
		SELECT	ClusterName	
			,clustNode05
		From	dbo.DBA_ClusterInfo
		) Data
	WHERE	COALESCE(NodeName,'') !=''
	)
SELECT		GroupingName
		,Nodes
		,max(MEM_MB_Total) MEM_MB_Total
		,sum(Instances) Instances
		,sum(TotalSQLMax) TotalSQLMax
FROM		(
		select
		DISTINCT
		COALESCE	(
				'(Cluster) ' + T3.ClusterName
				,T1.ServerName
				) GroupingName
		,(SELECT dbaadmin.dbo.dbaudf_Concatenate(NodeName) FROM ClusterNodes WHERE ClusterName =  T3.ClusterName GROUP BY ClusterName) Nodes
		,'(Cluster) ' + T3.ClusterName ClusterName
		,T1.ServerName 
		--,T1.SQLNAME	
		--,DomainName	
		--,SQLEnv	

		--,SQL_Version	
		--,SQL_Edition	
		--,SQL_BitLevel

		--,CPU_BitLevel
			
		--,OS_Version		
		--,OS_Edition	
		--,OS_BitLevel

		,MEM_MB_Total
		,T2.Instances
		,T2.TotalSQLMax
		--,MEM_MB_Total - TotalSQLMax MEM_LeftForOS	
		--,MEM_MB_SQLMax	
		--,MEM_MB_PageFileMax
		--,MEM_MB_PageFileAvailable	
		

		--,awe_enabled	
		--,boot_3gb	
		--,boot_pae	
		--,boot_userva

		From		dbo.ServerInfo T1
		LEFT JOIN	(
				SELECT		ServerName 
						,COUNT(DISTINCT SQLNAME)	Instances
						,SUM(MEM_MB_SQLMax)		TotalSQLMax
				FROM		dbo.ServerInfo T1
				GROUP BY	ServerName
				) T2
			ON	T1.ServerName = T2.ServerName		
		LEFT JOIN	dbo.DBA_ClusterInfo T3
			ON	T1.SQLNAME = T3.SQLNAME	
		) T1

WHERE		MEM_MB_Total < 2048 + (2048 * Instances) -10
GROUP BY	GroupingName		
		,Nodes








----LEFT JOIN	(
----		SELECT		DISTINCT
----				T1.SQLNAME
----				,T2.Instances
----		FROM		dbo.DBA_ClusterInfo T1
----		JOIN		(
----				SELECT		NodeName
----						,Count(DISTINCT SQLNAME) Instances
----				FROM		(
--						SELECT	ClusterName	
--							,clustNode01 NodeName
--						From	dbo.DBA_ClusterInfo
--						UNION
--						SELECT	SQLNAME	
--							,clustNode02
--						From	dbo.DBA_ClusterInfo
--						UNION
--						SELECT	SQLNAME	
--							,clustNode03
--						From	dbo.DBA_ClusterInfo
--						UNION
--						SELECT	SQLNAME	
--							,clustNode04
--						From	dbo.DBA_ClusterInfo
--						UNION
--						SELECT	SQLNAME	
--							,clustNode05
--						From	dbo.DBA_ClusterInfo
----						) T1
----				WHERE		COALESCE(NodeName,'') != '' 		
----				GROUP BY	NodeName
----				) T2
----			ON	T2.NodeName = T1.clustNode01
----			OR	T2.NodeName = T1.clustNode02
----			OR	T2.NodeName = T1.clustNode03
----			OR	T2.NodeName = T1.clustNode04
----			OR	T2.NodeName = T1.clustNode05		
----		) T3
----	ON	T3.SQLNAME = T1.SQLNAME






--SELECT		DISTINCT
--		T1.SQLNAME
--		,T2.Instances
--FROM		dbo.DBA_ClusterInfo T1
--JOIN		(
--		SELECT		NodeName
--				,Count(DISTINCT SQLNAME) Instances
--		FROM		(
--				SELECT	SQLNAME	
--					,clustNode01 NodeName
--				From	dbo.DBA_ClusterInfo
--				UNION
--				SELECT	SQLNAME	
--					,clustNode02
--				From	dbo.DBA_ClusterInfo
--				UNION
--				SELECT	SQLNAME	
--					,clustNode03
--				From	dbo.DBA_ClusterInfo
--				UNION
--				SELECT	SQLNAME	
--					,clustNode04
--				From	dbo.DBA_ClusterInfo
--				UNION
--				SELECT	SQLNAME	
--					,clustNode05
--				From	dbo.DBA_ClusterInfo
--				) T1
--		WHERE		COALESCE(NodeName,'') != '' 		
--		GROUP BY	NodeName
--		) T2
--	ON	T2.NodeName = T1.clustNode01
--	OR	T2.NodeName = T1.clustNode02
--	OR	T2.NodeName = T1.clustNode03
--	OR	T2.NodeName = T1.clustNode04
--	OR	T2.NodeName = T1.clustNode05


--FROM		(
--		select	SQLNAME
--			,VirtSrv01_node NodeName
--		From	dbo.DBA_ClusterInfo
--		UNION 
--		select	SQLNAME
--			,VirtSrv02_node
--		From	dbo.DBA_ClusterInfo
--		--UNION 	
--		--select	SQLNAME
--		--	,VirtSrv03_node
--		--From	dbo.DBA_ClusterInfo
--		--UNION 	
--		--select	SQLNAME
--		--	,VirtSrv04_node
--		--From	dbo.DBA_ClusterInfo
--		--UNION 	
--		--select	SQLNAME
--		--	,VirtSrv05_node
--		--From	dbo.DBA_ClusterInfo
--		) T1
--WHERE		COALESCE(NodeName,'') > ''
