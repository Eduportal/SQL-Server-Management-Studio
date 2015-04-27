USE [DBAcentral]
GO
CREATE PROCEDURE dbasp_Build_host_file
AS
;WITH HostData	AS	(
					SELECT	ROW_NUMBER() over (ORDER BY LEFT([Source],22) desc,[ServerName]) [RowID]
							,[IPnum]
							+ CASE WHEN LEN([IPnum]) <  8 THEN CHAR(9) ELSE '' END
							+ CHAR(9) + [ServerName]
							+ CASE WHEN LEN([ServerName]) <  16 THEN CHAR(9) ELSE '' END
							+ CASE WHEN LEN([ServerName]) <  8 THEN CHAR(9) ELSE '' END
							+ CHAR(9) + '# ' + [Source] [Record]
							,[Source]
					FROM	(
							SELECT	[ServerName]
									,[IPnum]
									,'DBA_ServerInfo.ServerName' [Source]
							  FROM [dbacentral].[dbo].[DBA_ServerInfo]
							  WHERE [DomainName] != 'amer'
							UNION
							  
							SELECT [SQLName]
								  ,[IPnum]
								  ,'DBA_ServerInfo.SQLName'
							  FROM [dbacentral].[dbo].[DBA_ServerInfo]
							  WHERE [DomainName] != 'amer' 
							UNION  
							
							SELECT	*
							FROM	(  
									SELECT [ClusterName]
										  ,[ClusterIP]
										  ,'DBA_ClusterInfo.SQLName ' + dbaadmin.dbo.dbaudf_Concatenate([SQLName]) [Source]
									  FROM [dbacentral].[dbo].[DBA_ClusterInfo]
									  GROUP BY [ClusterName],[ClusterIP]
									  ) Clusters
							UNION

							SELECT	*
							FROM	(
									SELECT	[clustNode01]
											,[clustNode01_IP]
											,'DBA_ClusterInfo.clustNode ' + dbaadmin.dbo.dbaudf_Concatenate([SQLName]) + ' (Node 01)' [Source]
									FROM	[dbacentral].[dbo].[DBA_ClusterInfo]
									GROUP BY [clustNode01],[clustNode01_IP]
									) Nodes
							UNION

							SELECT	*
							FROM	(
									SELECT	[clustNode02]
											,[clustNode02_IP]
											,'DBA_ClusterInfo.clustNode ' + dbaadmin.dbo.dbaudf_Concatenate([SQLName]) + ' (Node 02)' [Source]
									FROM	[dbacentral].[dbo].[DBA_ClusterInfo]
									GROUP BY [clustNode02],[clustNode02_IP]
									) Nodes
							UNION

							SELECT	*
							FROM	(
									SELECT	[clustNode03]
											,[clustNode03_IP]
											,'DBA_ClusterInfo.clustNode ' + dbaadmin.dbo.dbaudf_Concatenate([SQLName]) + ' (Node 03)' [Source]
									FROM	[dbacentral].[dbo].[DBA_ClusterInfo]
									GROUP BY [clustNode03],[clustNode03_IP]
									) Nodes
							UNION

							SELECT	*
							FROM	(
									SELECT	[clustNode04]
											,[clustNode04_IP]
											,'DBA_ClusterInfo.clustNode ' + dbaadmin.dbo.dbaudf_Concatenate([SQLName]) + ' (Node 04)' [Source]
									FROM	[dbacentral].[dbo].[DBA_ClusterInfo]
									GROUP BY [clustNode04],[clustNode04_IP]
									) Nodes
							UNION

							SELECT	*
							FROM	(
									SELECT	[clustNode05]
											,[clustNode05_IP]
											,'DBA_ClusterInfo.clustNode ' + dbaadmin.dbo.dbaudf_Concatenate([SQLName]) + ' (Node 05)' [Source]
									FROM	[dbacentral].[dbo].[DBA_ClusterInfo]
									GROUP BY [clustNode05],[clustNode05_IP]
									) Nodes
							
							) Data
					WHERE		parsename([IPnum],4) IS NOT NULL
					)

SELECT		CASE WHEN LEFT(C.[Source],22) != COALESCE(LEFT(P.[Source],22),LEFT(C.[Source],22)) THEN CHAR(13)+ CHAR(10) ELSE '' END
			+ C.[Record]
From		HostData C
LEFT JOIN	HostData P
	ON	C.RowID = P.RowID +1
ORDER BY	C.RowID
GO
