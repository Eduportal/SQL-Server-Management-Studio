

SELECT		UPPER(Machine + CASE WHEN Instance > '' THEN '\' + Instance ELSE '' END) AS [Row_ID]
		,[KnownCondition] AS [Col_ID]
		,COUNT(DISTINCT FixData) AS [UniqueCount]
FROM		[dbaadmin].[dbo].[Filescan_History] T1  WITH(NOLOCK)
WHERE		[EventDateTime] >= '02/08/2010'
	AND	[EventDateTime] < '02/09/2010'
GROUP BY	UPPER(Machine + CASE WHEN Instance > '' THEN '\' + Instance ELSE '' END)
		,[KnownCondition]
ORDER BY	1,2

