
SELECT * FROM dbo.AUTO_Request
		
DECLARE @APPLlist	VarChar(max)
SELECT	@APPLlist	=  'asp,bndl,cws,ds,pc,gmsa,gmsb,hga,mrt,vmt,cog,dw'


SELECT			DISTINCT
				depl_servername -- select *
FROM			[dbaadmin].[dbo].[depl_server_db_list]
WHERE			DEPL_DBName IN	(
								select			distinct 
												[db_name]
								from			dbaadmin.dbo.db_ApplCrossRef 
								where			RSTRfolder in	(
																SELECT			UPPER(LTRIM(RTRIM(CAST(SplitValue AS VarChar(10)))))
																FROM			DBAADMIN.dbo.dbaudf_split(@APPLlist,',')
																)
											AND	[db_name] NOT LIKE '%*%'
											AND	[db_name] NOT LIKE '%MessageQueue%'
								)
			AND	DEPL_ENVnum	= 'test01'								
			AND	nullif(App_name,'') IS NOT NULL


SELECT			DISTINCT
				SI.SQLName
FROM			[dbacentral].dbo.DBA_DBInfo			DI
JOIN			[dbacentral].dbo.DBA_ServerInfo		SI
		ON		DI.SQLName = SI.SQLName
WHERE			DBName IN	(
							select			distinct 
											[db_name]
							from			dbaadmin.dbo.db_ApplCrossRef 
							where			RSTRfolder in	(
															SELECT			UPPER(LTRIM(RTRIM(CAST(SplitValue AS VarChar(10)))))
															FROM			DBAADMIN.dbo.dbaudf_split(@APPLlist,',')
															)
										AND	[db_name] NOT LIKE '%*%'
										AND	[db_name] NOT LIKE '%MessageQueue%'
							)
		AND		SI.SQLENV = 'Dev'
		AND		SI.Active = 'Y'					