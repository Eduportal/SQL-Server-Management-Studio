DECLARE		@Script		VarChar(8000)
DECLARE		@File		VarChar(max)
DECLARE		@XML		XML
SET		@Script		= 'powershell -command "& {$UpdateSession = New-Object -ComObject Microsoft.Update.Session;'
				+ '$UpdateSearcher = $UpdateSession.CreateUpdateSearcher();'
				+ '$SearchResult = $UpdateSearcher.Search(''IsAssigned=1 and IsHidden=0 and IsInstalled=0'');'
				--+ '$SearchResult.updates | select Title,MsrcSeverity | export-csv -delimiter ''|'' -path ''C:\PendingUpdates.csv'';}"'
				+ '$SearchResult.updates | select Title,MsrcSeverity | Export-Clixml ''C:\PendingUpdates.xml'';}"'

exec xp_CmdShell @Script
SET	@XML = dbaadmin.dbo.dbaudf_GetFile('C:\PendingUpdates.XML')
SELECT @File = REPLACE(CAST(@XML AS VarChar(max)),' xmlns="http://schemas.microsoft.com/powershell/2004/04" Version="1.1.0.1"','')
SELECT @XML = CAST(@File AS XML)

;WITH		PendingUpdates ([Update],[Severity])
		AS
		(
		select		t.x.value('(./MS/S[@N="Title"]/text())[1]','VarChar(256)') as [Update]
				,ISNULL(NULLIF(t.x.value('(./MS/S[@N="MsrcSeverity"]/text())[1]','VarChar(256)'),''),'Other') as [Severity]
		from		@XML.nodes('/Objs/Obj') t(x)
		)
		,ReturnOrder ([Severity],[Order])
		AS
		(
		SELECT 'Critical',1 UNION ALL
		SELECT 'Important',2 UNION ALL
		SELECT 'Moderate',3 UNION ALL
		SELECT 'Low',4 UNION ALL
		SELECT 'Other',5 
		)
		,Sums([Order],[Severity],[Cnt],[Updates])
		AS
		(
		SELECT		CASE	WHEN (GROUPING([Order]) = 1) THEN 9
					ELSE [Order]
					END [Order]
				,CASE	WHEN (GROUPING(PendingUpdates.[Severity]) = 1) THEN 'Total'
					ELSE PendingUpdates.[Severity]
					END [Severity]
				,count(*) [Cnt]
				,CASE	WHEN (GROUPING(PendingUpdates.[Severity]) = 1) THEN ''
					ELSE REPLACE(dbaadmin.[dbo].[dbaudf_ConcatenateUnique]([Update]),',','|')
					END [Updates]

		FROM		PendingUpdates
		LEFT JOIN	ReturnOrder
			ON	PendingUpdates.[Severity] = ReturnOrder.[Severity]
		GROUP BY	[Order],PendingUpdates.[Severity] WITH CUBE
		)
SELECT		[Severity],[Cnt],[Updates]
FROM		Sums
WHERE		(Severity != 'Total' AND [Order] != 9)
	OR	(Severity = 'Total' AND [Order] = 9)
ORDER BY	[Order]
