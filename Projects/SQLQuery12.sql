

SELECT		[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Server')	AS [Server]
		,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Job')	AS [Job]
		,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Step')	AS [Step]
		,EventDateTime
FROM		[dbaadmin].[dbo].[Filescan_History]
WHERE		CAST(CONVERT(VarChar(12),EventDateTime,101)AS DateTime) >= CAST(CONVERT(VarChar(12),GETDATE()-1,101)AS DateTime)
	AND	KnownCondition = 'AgentJob-StepFailed'
	AND	[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Step')	 != '(Job outcome)'
UNION
SELECT		JO.*
FROM		(
		SELECT		[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Server')	AS [Server]
				,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Job')	AS [Job]
				,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Step')	AS [Step]
				,EventDateTime
		FROM		[dbaadmin].[dbo].[Filescan_History]
		WHERE		CAST(CONVERT(VarChar(12),EventDateTime,101)AS DateTime) >= CAST(CONVERT(VarChar(12),GETDATE()-1,101)AS DateTime)
			AND	KnownCondition = 'AgentJob-StepFailed'
			AND	[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Step')= '(Job outcome)'
		) JO

LEFT JOIN	(
		SELECT		[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Server')	AS [Server]
				,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Job')	AS [Job]
				,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Step')	AS [Step]
				,EventDateTime
		FROM		[dbaadmin].[dbo].[Filescan_History]
		WHERE		CAST(CONVERT(VarChar(12),EventDateTime,101)AS DateTime) >= CAST(CONVERT(VarChar(12),GETDATE()-1,101)AS DateTime)
			AND	KnownCondition = 'AgentJob-StepFailed'
			AND	[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Step')	!= '(Job outcome)'
		)  JS
	ON	JO.[Server]=JS.[Server]
	AND	JO.[Job]=JS.[Job]
	--AND	DATEDIFF(hour,JS.[EventDateTime],JO.[EventDateTime])<2
	AND	CAST(CONVERT(VarChar(12),JS.[EventDateTime],101)AS DateTime)=CAST(CONVERT(VarChar(12),JO.[EventDateTime],101)AS DateTime)
WHERE		JS.[Server] IS NULL