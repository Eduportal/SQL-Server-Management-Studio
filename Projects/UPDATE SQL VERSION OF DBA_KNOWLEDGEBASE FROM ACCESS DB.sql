------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
--
--	UPDATE SQL VERSION OF DBA_KNOWLEDGEBASE FROM ACCESS DB
--
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

	
	UPDATE		[dbacentral].[dbo].[DBA_KnowledgeBase]
		SET	[ProblemDescription]	= KB.[ProblemDescription]
	FROM		[dbacentral].[dbo].[DBA_KnowledgeBase] Dest	
	JOIN		[runbooks]...[tblKnowledgeBase] KB
		ON	Dest.[KnowledgeBaseID] = KB.[KnowledgeBaseID]
	WHERE		DATALENGTH(Dest.[ProblemDescription])	!= DATALENGTH(KB.[ProblemDescription])
GO
	UPDATE		[dbacentral].[dbo].[DBA_KnowledgeBase]
		SET	[ProblemResolution]	= KB.[ProblemResolution]
	FROM		[dbacentral].[dbo].[DBA_KnowledgeBase] Dest	
	JOIN		[runbooks]...[tblKnowledgeBase] KB
		ON	Dest.[KnowledgeBaseID] = KB.[KnowledgeBaseID]
	WHERE		DATALENGTH(Dest.[ProblemResolution])	!= DATALENGTH(KB.[ProblemResolution])
GO
	SET IDENTITY_INSERT [dbacentral].[dbo].[DBA_KnowledgeBase] ON
GO	
	INSERT INTO	[dbacentral].[dbo].[DBA_KnowledgeBase]
			(
			[KnowledgeBaseID]
			,[CaseNumber]
			,[DateOpened]
			,[DateClosed]
			,[DBA]
			,[Server]
			,[ProblemDescription]
			,[ProblemResolution]
			,[MicrosoftContactName]
			,[MicrosoftContactEmail]
			,[MicrosoftContactPhone]
			,[Application]
			)
	SELECT		KB.[KnowledgeBaseID]
			,KB.[CaseNumber]
			,KB.[DateOpened]
			,KB.[DateClosed]
			,DBA.[DBName]
			,KB.[Server]
			,KB.[ProblemDescription]
			,KB.[ProblemResolution]
			,KB.[MicrosoftContactName]
			,KB.[MicrosoftContactEmail]
			,KB.[MicrosoftContactPhone]
			,KB.[Application]
	FROM		[runbooks]...[tblKnowledgeBase] KB
	LEFT JOIN	[runbooks]...[tblDBA] DBA
		ON	DBA.[DBID] = KB.[DBAID] 
	LEFT JOIN	[dbacentral].[dbo].[DBA_KnowledgeBase] Dest
		ON	Dest.[KnowledgeBaseID] = KB.[KnowledgeBaseID]
	WHERE		KB.[KnowledgeBaseID] NOT IN (SELECT [KnowledgeBaseID] FROM [dbacentral].[dbo].[DBA_KnowledgeBase])
GO
	SET IDENTITY_INSERT [dbacentral].[dbo].[DBA_KnowledgeBase] OFF
GO
	








SELECT		* 
FROM		[dbacentral].[dbo].[DBA_KnowledgeBase]
WHERE		CONTAINS(*,'steve')
ORDER BY	[KnowledgeBaseID]
  

















