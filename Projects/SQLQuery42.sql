
SELECT	T1.KnownCondition
	, T1.Machine + CASE WHEN T1.Instance > '' THEN '\' + T1.Instance ELSE '' END AS [Server]
	, T1.SourceType
	, T1.FixData
	, T1.Message
	, T1.EventDateTime
FROM         dbo.FileScan_History AS T1 WITH (NOLOCK) 
WHERE     CAST(CONVERT(VarChar(12), EventDateTime, 101) AS DateTime) = CAST(CONVERT(VarChar(12), GETDATE() - 1, 101) AS DateTime)

GO


