USE [dbaCentral]
GO

DECLARE @GroupBy VarChar(50)
SET	@GroupBy ='KnownCondition'
DECLARE @Day INT
SET	@Day = 1

SELECT		[GroupBy]
		,CASE @Day
			WHEN 0 THEN COALESCE([0],0)
			WHEN 1 THEN COALESCE([1],0)
			WHEN 2 THEN COALESCE([2],0)
			WHEN 3 THEN COALESCE([3],0)
			WHEN 4 THEN COALESCE([4],0)
			WHEN 5 THEN COALESCE([5],0)
			WHEN 6 THEN COALESCE([6],0)
			WHEN 7 THEN COALESCE([7],0)
			WHEN 8 THEN COALESCE([8],0)
			WHEN 9 THEN COALESCE([9],0)
			WHEN 10 THEN COALESCE([10],0)
			WHEN -1 THEN (COALESCE([0],0)+COALESCE([1],0)+COALESCE([2],0)+COALESCE([3],0)+COALESCE([4],0)+COALESCE([5],0)+COALESCE([6],0)+COALESCE([7],0)+COALESCE([8],0)+COALESCE([9],0)+COALESCE([10],0))/11
			WHEN -2 THEN [dbaadmin].[dbo].[fn_min_Int] ([dbaadmin].[dbo].[fn_min_Int] ([dbaadmin].[dbo].[fn_min_Int] ([dbaadmin].[dbo].[fn_min_Int] ([dbaadmin].[dbo].[fn_min_Int] ([dbaadmin].[dbo].[fn_min_Int] ([dbaadmin].[dbo].[fn_min_Int] ([dbaadmin].[dbo].[fn_min_Int] ([dbaadmin].[dbo].[fn_min_Int] ([dbaadmin].[dbo].[fn_min_Int] ([dbaadmin].[dbo].[fn_min_Int] (COALESCE([0],0),COALESCE([1],0)),COALESCE([2],0)),COALESCE([3],0)),COALESCE([4],0)),COALESCE([5],0)),COALESCE([5],0)),COALESCE([6],0)),COALESCE([7],0)),COALESCE([8],0)),COALESCE([9],0)),COALESCE([10],0))
			WHEN -3 THEN [dbaadmin].[dbo].[fn_max_Int] ([dbaadmin].[dbo].[fn_max_Int] ([dbaadmin].[dbo].[fn_max_Int] ([dbaadmin].[dbo].[fn_max_Int] ([dbaadmin].[dbo].[fn_max_Int] ([dbaadmin].[dbo].[fn_max_Int] ([dbaadmin].[dbo].[fn_max_Int] ([dbaadmin].[dbo].[fn_max_Int] ([dbaadmin].[dbo].[fn_max_Int] ([dbaadmin].[dbo].[fn_max_Int] ([dbaadmin].[dbo].[fn_max_Int] (COALESCE([0],0),COALESCE([1],0)),COALESCE([2],0)),COALESCE([3],0)),COALESCE([4],0)),COALESCE([5],0)),COALESCE([5],0)),COALESCE([6],0)),COALESCE([7],0)),COALESCE([8],0)),COALESCE([9],0)),COALESCE([10],0))
			END AS [Value]
FROM		(
		SELECT		CASE @GroupBy
					WHEN 'Server' THEN [Server]
					WHEN 'KnownCondition' THEN [KnownCondition]
					WHEN 'SourceType' Then [SourceType]
					ELSE 'All' END AS [GroupBy]
				,CAST(DATEDIFF(day,[EventDate],getdate()) AS VarChar(2)) [EventDate]
				,COUNT(DISTINCT [Server]) [FailCount]
		FROM		(
				SELECT		CAST(CONVERT(VarChar(12),T1.EventDateTime,101)AS DateTime) EventDate
						, UPPER(REPLACE(COALESCE (T3.SQLEnv, T2.SQLEnv, N'Unknown'), 'production', 'prod')) AS Env
						, T1.Machine +	CASE 
								WHEN T1.Instance > '' 
								THEN '\' + T1.Instance 
								ELSE '' 
								END AS Server
						, T1.KnownCondition
						, T1.SourceType
						, T1.FixData
				FROM		dbo.FileScan_History AS T1 WITH (NOLOCK) 
				LEFT JOIN	dbo.DBA_ServerInfo AS T2 
					ON	T2.ServerName = T1.Machine 
				LEFT JOIN	dbo.DBA_ServerInfo AS T3 
					ON	T3.SQLName = T1.Machine + CASE WHEN T1.Instance > '' THEN '\' + T1.Instance ELSE '' END
				WHERE		T1.EventDateTime >= CAST(CONVERT(VarChar(12), GETDATE() - 10, 101) AS DateTime)
				) Data
		GROUP BY	CASE @GroupBy
					WHEN 'Server' THEN [Server]
					WHEN 'KnownCondition' THEN [KnownCondition]
					WHEN 'SourceType' Then [SourceType]
					ELSE 'All' END
				,CAST(DATEDIFF(day,[EventDate],getdate()) AS VarChar(2))
		) Data	

PIVOT
(
SUM(FailCount)
FOR [EventDate] IN([0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10])
)
AS P
WHERE	CASE @Day
			WHEN 0 THEN COALESCE([0],0)
			WHEN 1 THEN COALESCE([1],0)
			WHEN 2 THEN COALESCE([2],0)
			WHEN 3 THEN COALESCE([3],0)
			WHEN 4 THEN COALESCE([4],0)
			WHEN 5 THEN COALESCE([5],0)
			WHEN 6 THEN COALESCE([6],0)
			WHEN 7 THEN COALESCE([7],0)
			WHEN 8 THEN COALESCE([8],0)
			WHEN 9 THEN COALESCE([9],0)
			WHEN 10 THEN COALESCE([10],0)
			WHEN -1 THEN (COALESCE([0],0)+COALESCE([1],0)+COALESCE([2],0)+COALESCE([3],0)+COALESCE([4],0)+COALESCE([5],0)+COALESCE([6],0)+COALESCE([7],0)+COALESCE([8],0)+COALESCE([9],0)+COALESCE([10],0))/11
			WHEN -2 THEN [dbaadmin].[dbo].[fn_min_Int] ([dbaadmin].[dbo].[fn_min_Int] ([dbaadmin].[dbo].[fn_min_Int] ([dbaadmin].[dbo].[fn_min_Int] ([dbaadmin].[dbo].[fn_min_Int] ([dbaadmin].[dbo].[fn_min_Int] ([dbaadmin].[dbo].[fn_min_Int] ([dbaadmin].[dbo].[fn_min_Int] ([dbaadmin].[dbo].[fn_min_Int] ([dbaadmin].[dbo].[fn_min_Int] ([dbaadmin].[dbo].[fn_min_Int] (COALESCE([0],0),COALESCE([1],0)),COALESCE([2],0)),COALESCE([3],0)),COALESCE([4],0)),COALESCE([5],0)),COALESCE([5],0)),COALESCE([6],0)),COALESCE([7],0)),COALESCE([8],0)),COALESCE([9],0)),COALESCE([10],0))
			WHEN -3 THEN [dbaadmin].[dbo].[fn_max_Int] ([dbaadmin].[dbo].[fn_max_Int] ([dbaadmin].[dbo].[fn_max_Int] ([dbaadmin].[dbo].[fn_max_Int] ([dbaadmin].[dbo].[fn_max_Int] ([dbaadmin].[dbo].[fn_max_Int] ([dbaadmin].[dbo].[fn_max_Int] ([dbaadmin].[dbo].[fn_max_Int] ([dbaadmin].[dbo].[fn_max_Int] ([dbaadmin].[dbo].[fn_max_Int] ([dbaadmin].[dbo].[fn_max_Int] (COALESCE([0],0),COALESCE([1],0)),COALESCE([2],0)),COALESCE([3],0)),COALESCE([4],0)),COALESCE([5],0)),COALESCE([5],0)),COALESCE([6],0)),COALESCE([7],0)),COALESCE([8],0)),COALESCE([9],0)),COALESCE([10],0))
			END > 0
ORDER BY 2 DESC

GO
DECLARE @GroupBy VarChar(50)
SET	@GroupBy ='KnownCondition'
DECLARE @Day INT
SET	@Day = 1
DECLARE @Group VarChar(50)
SET	@Group ='Login Failed'


SELECT		EventDate
		,Env
		,Server
		,KnownCondition
		,SourceType
		,Message
		,FixData
		,count(*)
FROM		(
		SELECT		CAST(CONVERT(VarChar(12),T1.EventDateTime,101)AS DateTime) EventDate
				, UPPER(REPLACE(COALESCE (T3.SQLEnv, T2.SQLEnv, N'Unknown'), 'production', 'prod')) AS Env
				, T1.Machine +	CASE 
						WHEN T1.Instance > '' 
						THEN '\' + T1.Instance 
						ELSE '' 
						END AS Server
				, T1.KnownCondition
				, T1.SourceType
				, T1.Message
				, T1.FixData
		FROM		dbo.FileScan_History AS T1 WITH (NOLOCK) 
		LEFT JOIN	dbo.DBA_ServerInfo AS T2 
			ON	T2.ServerName = T1.Machine 
		LEFT JOIN	dbo.DBA_ServerInfo AS T3 
			ON	T3.SQLName = T1.Machine + CASE WHEN T1.Instance > '' THEN '\' + T1.Instance ELSE '' END
		WHERE		CAST(CONVERT(VarChar(12),T1.EventDateTime, 101) AS DateTime) = CAST(CONVERT(VarChar(12), GETDATE() - @Day, 101) AS DateTime)
		) Data	
WHERE		@Group = CASE @GroupBy
			WHEN 'Server' THEN [Server]
			WHEN 'KnownCondition' THEN [KnownCondition]
			WHEN 'SourceType' Then [SourceType]
			ELSE 'All' END 
GROUP BY	EventDate
		,Env
		,Server
		,KnownCondition
		,SourceType
		,Message
		,FixData			