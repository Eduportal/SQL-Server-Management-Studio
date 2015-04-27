SELECT DISTINCT COALESCE(REPLACE(ServerTypeName,'[SELECT]','Other'),'Other') [ServerType]
FROM [EnlightenServers] 
WHERE	COALESCE(REPLACE(ServerTypeName,'[SELECT]','Other'),'Other') != 'Other'
ORDER BY 1

SELECT DISTINCT UPPER(LEFT(ShortName,3)) [ServerNamePrefix]
FROM [EnlightenServers] 
ORDER BY 1

SELECT DISTINCT UPPER([ShortName]) [ShortName] 
FROM [EnlightenServers]
WHERE  [ShortName] Like @ServerNamePrefix
AND	[ServerTypeName] Like @ServerType
ORDER BY [ShortName] 


