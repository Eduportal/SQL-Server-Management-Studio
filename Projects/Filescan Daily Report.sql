SELECT		count(DISTINCT COALESCE(FixData,LEFT(Message,50))) UniqueErrorCount
		,count(*)  As TotalErrorCount
FROM		[dbaadmin].[dbo].[Filescan_History]
WHERE		EventDateTime >= GetDate()-1


SELECT		Machine
		,Instance
		,count(*) As ErrorCount
FROM		[dbaadmin].[dbo].[Filescan_History]
WHERE		EventDateTime >= GetDate()-1
GROUP BY	Machine
		,Instance
ORDER BY	3  desc

SELECT		DISTINCT
		KnownCondition
		,FixData
		,count(DISTINCT COALESCE(FixData,LEFT(Message,50))) UniqueErrorCount
		,count(*)  As TotalErrorCount
FROM		[dbaadmin].[dbo].[Filescan_History]    T1
INNER JOIN	(
		 SELECT		TOP 1
				Machine
				,Instance
				,count(*) As ErrorCount
		FROM		[dbaadmin].[dbo].[Filescan_History]
		WHERE		EventDateTime >= GetDate()-1
			AND	Machine != 'DAPSQLTEST01'
		GROUP BY	Machine
				,Instance
		ORDER BY	3  desc
		) T2
	ON	T1.Machine = T2.Machine
	AND	T1.Instance = T2.Instance		
WHERE		EventDateTime >= GetDate()-1
GROUP BY	KnownCondition
		,FixData
ORDER BY	3 desc, 4 desc


SELECT		LEFT(Message,50) MsgType
		,Count(*)
FROM		[dbaadmin].[dbo].[Filescan_History]
WHERE		EventDateTime >= GetDate()-1
 AND		KnownCondition = 'Unknown'
	--and	Message Not Like '%DBA - Test LogParser%'
GROUP BY	LEFT(Message,50)
ORDER BY	Count(*) DESC


SELECT	Message
FROM	[dbaadmin].[dbo].[Filescan_History]
WHERE	EventDateTime >= GetDate()-1
 AND	LEFT(Message,50) = 
	(
	SELECT		TOP 1 LEFT(Message,50) MsgType
			--,Count(*)
	FROM		[dbaadmin].[dbo].[Filescan_History]
	WHERE		EventDateTime >= GetDate()-1
	 AND		KnownCondition = 'Unknown'
	 and		Message Not Like '%DBA - Test LogParser%'
	GROUP BY	LEFT(Message,50)
	ORDER BY	Count(*) DESC
	)
	
SELECT	[SourceType]
	,[Machine]
	,[Instance]
	,[LastReported]
	,DATEDIFF(Minute,[LastReported],getdate()) MinSinceReported	
  FROM [dbaadmin].[dbo].[Filescan_MachineSource]
WHERE  DATEDIFF(Minute,[LastReported],getdate()) > 15
ORDER BY 5 DESC



--SELECT		DISTINCT LEFT(Message,50)
--FROM		[dbaadmin].[dbo].[Filescan_History]
--WHERE		KnownCondition = 'Unknown'
--AND		Message NOT LIKE '%DBA WARNING%'
--AND		Message NOT LIKE '%DBA ERROR%'

--SELECT		DISTINCT Message
--FROM		[dbaadmin].[dbo].[Filescan_History]
--WHERE		KnownCondition = 'Unknown'
--AND		Message NOT LIKE '%DBA WARNING%'
--AND		Message NOT LIKE '%DBA ERROR%'
--AND		Message Like 'FCB::%'
--ORDER BY	Message


--SELECT		Message
--FROM		[dbaadmin].[dbo].[Filescan_History]
--WHERE		KnownCondition = 'Unknown'
--	AND	Message Like '%BACKUP failed to complete the command%'
