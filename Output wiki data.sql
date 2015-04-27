SET NOCOUNT ON

DECLARE		@TableWidth	INT
		,@Output_Path	VarChar(8000)
		,@FileName	VarChar(8000)

SELECT		@TableWidth	= 3
		,@FileName	= 'MSSQL Servers.aspx'
		,@Output_Path	= '\\'+REPLACE(@@ServerName,'\'+@@ServiceName,'')+'\'+REPLACE(@@ServerName,'\','$')+'_dbasql\dba_reports\wiki'

-- START THE FILE AS AN EMPTY FILE
SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write] ('',@Output_Path+'\'+@FileName,0,0)

;WITH		[Set_All]
		AS
		(
		SELECT		1					[row]
				,'[[MSSQL SERVERS - ALL|ALL]],[[MSSQL SERVERS - ACTIVE|ACTIVE]],[[MSSQL SERVERS - NOT ACTIVE|NOT ACTIVE]]'	[LinkSet]
				,3					[SetSize]
		)
		,[Set_Domain]
		AS
		(
		SELECT		row
				,dbaadmin.dbo.dbaudf_ConcatenateUnique('[[MSSQL SERVERS - DOMAIN '+LinkName+'|'+LinkName+']]') [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		row_number()over(order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									UPPER(DomainName) LinkName
								FROM	[dbacentral].[dbo].[ServerInfo]
								WHERE	Active = 'y'
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	LinkName
				)Data
		GROUP BY	row
		)
		,[Set_SQLVersion]
		AS
		(
		SELECT		row
				,dbaadmin.dbo.dbaudf_ConcatenateUnique('[[MSSQL SERVERS - SQL Version '+LinkName+'|'+LinkName+']]') [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		row_number()over(order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									UPPER(SQL_Version) LinkName
								FROM	[dbacentral].[dbo].[ServerInfo]
								WHERE	Active = 'y'
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	LinkName
				)Data
		GROUP BY	row
		)
		,[Set_Environment]
		AS
		(
		SELECT		row
				,dbaadmin.dbo.dbaudf_ConcatenateUnique('[[MSSQL SERVERS - ENVIRONMENT '+LinkName+'|'+LinkName+']]') [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		row_number()over(order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									UPPER(SQLEnv) LinkName
								FROM	[dbacentral].[dbo].[ServerInfo]
								WHERE	Active = 'y'
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	LinkName
				)Data
		GROUP BY	row
		)
		,[Set_App]
		AS
		(
		SELECT		row
				,dbaadmin.dbo.dbaudf_ConcatenateUnique('[[MSSQL SERVERS - APPLICATION '+LinkName+'|'+LinkName+']]') [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		row_number()over(order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									UPPER(REPLACE(Appl_desc,',','&#44;')) LinkName
								FROM	[dbacentral].[dbo].[DBA_DBInfo]
								WHERE	SQLName IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE	Active = 'y')
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	LinkName
				)Data
		GROUP BY	row
		)
		,[Set_DB]
		AS
		(
		SELECT		row
				,dbaadmin.dbo.dbaudf_ConcatenateUnique('[[MSSQL SERVERS - DATABASE '+LinkName+'|'+LinkName+']]') [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		row_number()over(order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									UPPER(COALESCE(T2.DBName_Cleaned,T3.DBName_Cleaned,T1.DBName)) LinkName
								FROM	[dbacentral].[dbo].[DBA_DBInfo] T1
								LEFT 
								JOIN	[dbacentral].[dbo].[DBA_DBNameCleaner] T2
								  ON	T1.DBName Like T2.DBName
								LEFT
								JOIN	(
									SELECT	DISTINCT
										[DBName_Cleaned]+'%' [DBName]
										,[DBName_Cleaned]
									FROM	[dbacentral].[dbo].[DBA_DBNameCleaner]
									) T3
								  ON	T1.DBName Like T3.DBName
								WHERE	SQLName IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE	Active = 'y')
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	LinkName
				)Data
		GROUP BY	row
		)

		,[Servers_Active]
		AS
		(
		SELECT		row
				,dbaadmin.dbo.dbaudf_ConcatenateUnique('[['+REPLACE(LinkName,'\','$')+'|'+LinkName+']]') [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		row_number()over(order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									UPPER(SQLName) LinkName
								FROM	[dbacentral].[dbo].[ServerInfo]
								WHERE	Active = 'y'
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	LinkName
				)Data
		GROUP BY	row
		)

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write] ([OutputRow],@Output_Path+'\'+@FileName,1,1)
FROM	(
SELECT	'<br/><br/><br/>
<p>?<br/></p>
<h1>SQL SERVER AND DATABASE LOOKUP TOOL<br/></h1>
<div>
   <a href="http://ecommops/SqlDbaDocs/SQLLookup.aspx">SQL &#160;Server and Database Lookups</a><br/></div>
<div>
   <br/>
</div>
<div>This lookup tool will identify the current deployment of all databases on all servers in all environments. You can search for a database name and it will tell you which servers it exists on in each environment or you can search for a server to Identify what databases are on it. The server and database fields both accept partial names for wider searches. The Server name field also accepts cluster node names.</div>
<div>
   <br/>
</div>
<h1>List Servers By<br/></h1>
<br/>?' [OutputRow]
UNION ALL
SELECT	'<table class="ms-rteTable-default ">'
UNION ALL
SELECT	'     <tbody>'
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"></td></tr>'
-------------------------------------------------------------------------------------
UNION ALL
SELECT	'          <tr><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">'+REPLACE([LinkSet],',','</td><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">')+'</td>'
		+ ISNULL(REPLICATE('<td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;"></td>',@TableWidth-[SetSize]),'')
		+'</tr>'
FROM		[Set_All]
---------------------------------------------------------------------------------------
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"></td></tr>'
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"><h2>DOMAIN</h2></td></tr>'
UNION ALL
SELECT	'          <tr><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">'+REPLACE([LinkSet],',','</td><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">')+'</td>'
		+ ISNULL(REPLICATE('<td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;"></td>',@TableWidth-[SetSize]),'')
		+'</tr>'
FROM		[Set_Domain]
---------------------------------------------------------------------------------------
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"></td></tr>'
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"><h2>SQL VERSION</h2></td></tr>'
UNION ALL
SELECT	'          <tr><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">'+REPLACE([LinkSet],',','</td><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">')+'</td>'
		+ ISNULL(REPLICATE('<td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;"></td>',@TableWidth-[SetSize]),'')
		+'</tr>'
FROM		[Set_SQLVersion]
---------------------------------------------------------------------------------------
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"></td></tr>'
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"><h2>ENVIRONMENT</h2></td></tr>'
UNION ALL
SELECT	'          <tr><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">'+REPLACE([LinkSet],',','</td><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">')+'</td>'
		+ ISNULL(REPLICATE('<td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;"></td>',@TableWidth-[SetSize]),'')
		+'</tr>'
FROM		[Set_Environment]
---------------------------------------------------------------------------------------
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"></td></tr>'
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"><h2>APPLICATIONS</h2></td></tr>'
UNION ALL
SELECT	'          <tr><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">'+REPLACE([LinkSet],',','</td><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">')+'</td>'
		+ ISNULL(REPLICATE('<td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;"></td>',@TableWidth-[SetSize]),'')
		+'</tr>'
FROM		[Set_App]
---------------------------------------------------------------------------------------
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"></td></tr>'
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"><h2>DATABASES</h2></td></tr>'
UNION ALL
SELECT	'          <tr><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">'+REPLACE([LinkSet],',','</td><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">')+'</td>'
		+ ISNULL(REPLICATE('<td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;"></td>',@TableWidth-[SetSize]),'')
		+'</tr>'
FROM		[Set_DB]
---------------------------------------------------------------------------------------
--UNION ALL
--SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'"><h2>ACTIVE MSSQL SERVERS</h2></td></tr>'
--UNION ALL
--SELECT	'          <tr><td>'+REPLACE([LinkSet],',','</td><td>')+'</td>'
--		+ ISNULL(REPLICATE('<td></td>',@TableWidth-[SetSize]),'')
--		+'</tr>'
--FROM		[Servers_Active]





UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"></td></tr>'
UNION ALL
SELECT	'     </tbody>'
UNION ALL
SELECT	'</table>'
UNION ALL
SELECT	'<br/>'
UNION ALL
SELECT	'<br/>' 
UNION ALL
SELECT	'[[Category:SQLServerInfo/|SQLServerInfo]] [[Category:TSSQLDBA/|TSSQLDBA]]'
UNION ALL
SELECT	'<br/>'

) Data













