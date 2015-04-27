CREATE PROC	FileScan_History_Daily_Summary
(
@EventDate	DATETIME
)
AS
SET NOCOUNT ON

DECLARE	@TSQL		VARCHAR(MAX)
SET	@EventDate	= CAST(CONVERT(VARCHAR(12),@EventDate,101)AS DATETIME) --STRIP OFF TIME    

SELECT	@TSQL = 'SELECT		[Server]'+CHAR(13)+CHAR(10)
+ REPLACE(REPLACE(REPLACE((
				SELECT		TOP 25
						'|1|'+UPPER([KnownCondition])+'|2|'+UPPER([KnownCondition])+'|3|'
				FROM		[dbaadmin].[dbo].[Filescan_History] T1  WITH(NOLOCK)
				WHERE		[EventDateTime] >= @EventDate
					AND	[EventDateTime] < @EventDate+1
				GROUP BY	'|1|'+UPPER([KnownCondition])+'|2|'+UPPER([KnownCondition])+'|3|'
				HAVING		COUNT(DISTINCT FixData) > 0
				ORDER BY	COUNT(DISTINCT FixData) Desc 
				FOR 
				XML 
				PATH('')
				)
		,'|1|','		,COALESCE([')
		,'|2|','],0) [')
		,'|3|',']'+CHAR(13)+CHAR(10))		
+'FROM		(
		Select		DISTINCT 
				[Server] [Server]
				--,GROUPING([Server]) [SortField]'+CHAR(13)+CHAR(10)
+ REPLACE(REPLACE(REPLACE((
				SELECT		TOP 25
						'|1|'+UPPER([KnownCondition])+'|2|'+UPPER([KnownCondition])+'|3|'
				FROM		[dbaadmin].[dbo].[Filescan_History] T1  WITH(NOLOCK)
				WHERE		[EventDateTime] >= @EventDate
					AND	[EventDateTime] < @EventDate+1
				GROUP BY	'|1|'+UPPER([KnownCondition])+'|2|'+UPPER([KnownCondition])+'|3|'
				HAVING		COUNT(DISTINCT FixData) > 0
				ORDER BY	COUNT(DISTINCT FixData) Desc 
				FOR 
				XML 
				PATH('')
				)
		,'|1|','				,SUM([')
		,'|2|',']) [')
		,'|3|',']'+CHAR(13)+CHAR(10))
+'		FROM		(
				SELECT		UPPER(Machine + CASE WHEN Instance > '''' THEN ''\'' + Instance ELSE '''' END) AS [Server]
						,[KnownCondition]
						,CAST(CONVERT(VARCHAR(12),[EventDateTime],101)AS DATETIME) AS [EventDate]
						,COUNT(DISTINCT FixData) AS [UniqueCount]
				FROM		[dbaadmin].[dbo].[Filescan_History] T1  WITH(NOLOCK)
				WHERE		[EventDateTime] >= ''' + CONVERT(VARCHAR(12),@EventDate,101) + '''
					AND	[EventDateTime] < ''' + CONVERT(VARCHAR(12),@EventDate+1,101) + '''
					AND	(UPPER(Machine + CASE WHEN Instance > '''' THEN ''\'' + Instance ELSE '''' END) IN
						(
						SELECT		TOP 25 
								T1.Machine + CASE WHEN T1.Instance > '''' THEN ''\'' + T1.Instance ELSE '''' END AS [Server]
						FROM		[dbaadmin].[dbo].[Filescan_History] T1  WITH(NOLOCK)
						WHERE		[EventDateTime] >= ''' + CONVERT(VARCHAR(12),@EventDate,101) + '''
							AND	[EventDateTime] < ''' + CONVERT(VARCHAR(12),@EventDate+1,101) + '''
						GROUP BY	T1.Machine + CASE WHEN T1.Instance > '''' THEN ''\'' + T1.Instance ELSE '''' END
						HAVING		COUNT(DISTINCT FixData) > 0
						ORDER BY	COUNT(DISTINCT FixData) DESC
						)
					OR	KnownCondition IN
						(
						SELECT		TOP 25
								KnownCondition	AS [KnownCondition]
						FROM		[dbaadmin].[dbo].[Filescan_History] T1  WITH(NOLOCK)
						WHERE		[EventDateTime] >= ''' + CONVERT(VARCHAR(12),@EventDate,101) + '''
							AND	[EventDateTime] < ''' + CONVERT(VARCHAR(12),@EventDate+1,101) + '''
						GROUP BY	KnownCondition
						HAVING		COUNT(DISTINCT FixData) > 0
						ORDER BY	COUNT(DISTINCT FixData) Desc 
						))
				GROUP BY	UPPER(Machine + CASE WHEN Instance > '''' THEN ''\'' + Instance ELSE '''' END)
						,[KnownCondition]
						,CAST(CONVERT(VARCHAR(12),[EventDateTime],101)AS DATETIME)
				) AS [Data]
		PIVOT		(
				SUM([UniqueCount]) FOR [KnownCondition] IN ('+LEFT(REPLACE(REPLACE((
				SELECT		TOP 25
						'|1|'+UPPER([KnownCondition])+'|2|'
				FROM		[dbaadmin].[dbo].[Filescan_History] T1  WITH(NOLOCK)
				WHERE		[EventDateTime] >= @EventDate
					AND	[EventDateTime] < @EventDate+1
				GROUP BY	'|1|'+UPPER([KnownCondition])+'|2|'
				HAVING		COUNT(DISTINCT FixData) > 0
				ORDER BY	COUNT(DISTINCT FixData) Desc 
				FOR 
				XML 
				PATH('')
				),'|1|','['),'|2|','],'),LEN(REPLACE(REPLACE((
				SELECT		TOP 25
						'|1|'+UPPER([KnownCondition])+'|2|'
				FROM		[dbaadmin].[dbo].[Filescan_History] T1  WITH(NOLOCK)
				WHERE		[EventDateTime] >= @EventDate
					AND	[EventDateTime] < @EventDate+1
				GROUP BY	'|1|'+UPPER([KnownCondition])+'|2|'
				HAVING		COUNT(DISTINCT FixData) > 0
				ORDER BY	COUNT(DISTINCT FixData) Desc 
				FOR 
				XML 
				PATH('')
				),'|1|','['),'|2|','],'))-1)+')
				) AS [PivotTable]
		GROUP BY	[Server] --WITH CUBE
		) [Data]
--ORDER BY	[SortField],[Server]'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)

EXEC (@TSQL)

GO
