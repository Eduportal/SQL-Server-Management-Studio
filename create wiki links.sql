use dbacentral
GO

DECLARE		@TableWidth		INT
DECLARE		@Output			VarChar(max)
SET		@TableWidth		= 3


;WITH		LinkSet
		AS
		(
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
		)
		,
		[Table]
		AS
		(
		SELECT	200 / (MAX(LEN(LinkName))+4) [Width]
		FROM	[LinkSet]
		)
SELECT		row
		,'|-' + CHAR(13) +CHAR(10) + RTRIM(REPLACE(dbaadmin.dbo.dbaudf_Concatenate('| [[MSSQL_DATABASE_'+ REPLACE(LinkName,' ','_') +'|' + REPLACE(LinkName,' ','_') + ']]'
				--+REPLICATE(' ',[LinkGutter])
				),',',CHAR(13) +CHAR(10))) [LinkSet]
		,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						((rn-1)/(SELECT TOP 1 [Width] From [Table])+1) row
						,rn
						,LinkName
						,(SELECT MAX(LEN(LinkName))+4 FROM LinkSet) [MaxLinkSize]
						,LEN(LinkName) [LinkSize]
						,(((SELECT MAX(LEN(LinkName))+4 FROM LinkSet)-LEN(LinkName))) [LinkGutter]
				FROM		(
						SELECT		row_number()over(order by LinkName) rn
								,LinkName
						FROM		LinkSet
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	LinkName
				)Data
		GROUP BY	row


	