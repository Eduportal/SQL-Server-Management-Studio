IF OBJECT_ID('tempdb..#Output') IS NOT NULL DROP TABLE #Output

DECLARE		@ServerName		SYSNAME
			,@DatabaseName	SYSNAME

DECLARE DBLoopCursor CURSOR
FOR
SELECT		DISTINCT
			[ServerName]
			,[DatabaseName]
FROM		[dbaperf].[dbo].[db_stats_log] [db_stats_log] 

OPEN DBLoopCursor;
FETCH DBLoopCursor INTO @ServerName,@DatabaseName;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
		IF OBJECT_ID('tempdb..#Results') IS NOT NULL DROP TABLE #Results

		;WITH		DateDimension
					AS
					(
					SELECT		ROW_NUMBER()OVER(ORDER BY [TimeKey]) [Period]
								,T2.*
					FROM		(
								SELECT		MinDate		= CAST(CONVERT(VarChar(12),MIN([rundate]),101)AS DateTime)
											,MaxDate	= CAST(CONVERT(VarChar(12),MAX([rundate]),101)AS DateTime)
								FROM		[dbaperf].[dbo].[db_stats_log] [db_stats_log]
								WHERE		[ServerName] = @ServerName
										AND	[DatabaseName] = @DatabaseName 
								) T1
					CROSS APPLY	[dbaadmin].[dbo].[dbaudf_TimeDimension](T1.MinDate,T1.MaxDate,'Day',1) T2
					)
					,RawData
					AS
					(
					SELECT		 CAST(CONVERT(VarChar(12),[rundate],101)AS DateTime) [rundate]
								,[ServerName]
								,[DatabaseName]
								,SUM(CAST([data_space_used_KB] AS FLOAT) / 1024) DataSize
								,SUM(CAST([index_size_used_KB] AS FLOAT) / 1024) IndexSize
					FROM		[dbaperf].[dbo].[db_stats_log] [db_stats_log]
					WHERE		[ServerName] = @ServerName
							AND	[DatabaseName] = @DatabaseName
					GROUP BY	[rundate]
								,[ServerName]
								,[DatabaseName]
					)
					,ResultKey
					AS
					(
					SELECT		DISTINCT
								[DateDimension].[Period]
								,[DateDimension].[DateTimeValue]
								,[RawData].[ServerName]
								,[RawData].[DatabaseName]
					FROM		[DateDimension]
					CROSS JOIN	[RawData]
					)
					,History
					AS
					(
					SELECT		[ResultKey].[Period]
								,[ResultKey].[ServerName]
								,[ResultKey].[DatabaseName]
								,[RawData].[DataSize]
								,[RawData].[IndexSize]
					FROM		[ResultKey]
					LEFT JOIN	[RawData]
						ON		[ResultKey].[DateTimeValue]	= [RawData].[rundate]
						AND		[ResultKey].[ServerName]	= [RawData].[ServerName]
						AND		[ResultKey].[DatabaseName]	= [RawData].[DatabaseName]
					--ORDER BY	1,2,3
					)
					,CleanHistory
					AS
					(
					SELECT		[Period]
								,[ServerName]
								,[DatabaseName]
								,CASE
									WHEN [DataSize] IS NULL
									THEN (SELECT TOP 1 [DataSize] FROM History WHERE [DataSize] IS NOT NULL AND [ServerName] = H.[ServerName] AND [DatabaseName] = H.[DatabaseName] AND [Period] < H.[Period] ORDER BY [Period] DESC)
									ELSE [DataSize] END [DataSize]

								,CASE
									WHEN [IndexSize] IS NULL
									THEN (SELECT TOP 1 [IndexSize] FROM History WHERE [IndexSize] IS NOT NULL AND [ServerName] = H.[ServerName] AND [DatabaseName] = H.[DatabaseName] AND [Period] < H.[Period] ORDER BY [Period] DESC)
									ELSE [IndexSize] END [IndexSize]
					FROM		History H
					--ORDER BY	1,2,3
					)
					,SmoothedHistory
					AS
					(
					SELECT		A.[Period]
								,A.[ServerName]
								,A.[DatabaseName]
								,MAX(A.[DataSize])  [DataSize]
								,MAX(A.[IndexSize]) [IndexSize]
								,Round(AVG(Cast(B.[DataSize]  as numeric(14,1))),0) Smoothed_MetricA
								,Round(AVG(Cast(B.[IndexSize] as numeric(14,1))),0) Smoothed_MetricB
					FROM		CleanHistory A
					INNER JOIN	CleanHistory B 
									ON		A.[ServerName]		= B.[ServerName]
									AND		A.[DatabaseName]	= B.[DatabaseName]
									AND		(
												(
													(A.[Period]*100)/(SELECT MAX(Period) FROM DateDimension) < 10
												AND	(A.[Period] - B.[Period]) BETWEEN 0 AND 10
												)
											OR
												(
													(A.[Period]*100)/(SELECT MAX(Period) FROM DateDimension) > 90
												AND	(A.[Period] - B.[Period]) BETWEEN -10 AND 0
												)
											OR
												(
													(A.[Period]*100)/(SELECT MAX(Period) FROM DateDimension) Between 10 AND 90
												AND	(A.[Period] - B.[Period]) BETWEEN -10 AND 10
												)
											)
								GROUP BY	A.[Period]
											,A.[ServerName]
											,A.[DatabaseName]
					--ORDER BY	1,2,3
					)

					SELECT		A.[Period]
								,A.[ServerName]
								,A.[DatabaseName]
								,A.[DataSize]
								,A.[IndexSize]
								,A.[Smoothed_MetricA]
								,A.[Smoothed_MetricB]
								--,A.[Smoothed_MetricA]
								--	/(dbaadmin.dbo.Intercept(B.[Period],B.Smoothed_MetricA)
								--	+(dbaadmin.dbo.slope(B.[Period],B.Smoothed_MetricA)*A.[Period])) 	[Seasonality_MetricA]
								--,A.[Smoothed_MetricB]
								--	/(dbaadmin.dbo.Intercept(B.[Period],B.Smoothed_MetricB)
								--	+(dbaadmin.dbo.slope(B.[Period],B.Smoothed_MetricB)*A.[Period])) 	[Seasonality_MetricB]
								,dbaadmin.dbo.slope(B.[Period],B.Smoothed_MetricA)		[B_MetricA]
								,dbaadmin.dbo.slope(B.[Period],B.Smoothed_MetricB)		[B_MetricB]
								,dbaadmin.dbo.Intercept(B.[Period],B.Smoothed_MetricA)	[A_MetricA]
								,dbaadmin.dbo.Intercept(B.[Period],B.Smoothed_MetricB)	[A_MetricB]
					INTO		#Results
					FROM		SmoothedHistory A
					INNER JOIN	SmoothedHistory B 
									ON		A.[ServerName]		= B.[ServerName]
									AND		A.[DatabaseName]	= B.[DatabaseName]
									AND		(A.[Period] - B.[Period]) BETWEEN -30 AND 30 -- Averaged with the 1 Months before and after.

					GROUP BY	A.[Period]
								,A.[ServerName]
								,A.[DatabaseName]
								,A.[DataSize]
								,A.[IndexSize]
								,A.[Smoothed_MetricA]
								,A.[Smoothed_MetricB]
					ORDER BY	1,2,3



		DECLARE @Loop INT
		SET		@Loop = 0

		WHILE @Loop < 100
		BEGIN
			;WITH		B
						AS
						(
						SELECT		[ServerName]
									,[DatabaseName]
									,dbaadmin.dbo.slope([Period],Smoothed_MetricA)		B_MetricA
									,dbaadmin.dbo.slope([Period],Smoothed_MetricB)		B_MetricB
									,dbaadmin.dbo.Intercept([Period],Smoothed_MetricA)	A_MetricA
									,dbaadmin.dbo.Intercept([Period],Smoothed_MetricB)	A_MetricB
						FROM		#Results
						WHERE		[Period] IN (SELECT DISTINCT TOP (50) [Period] FROM #Results ORDER BY [Period] DESC)
						GROUP BY	[ServerName]
									,[DatabaseName]
						--ORDER BY	1,2,3
						)
			INSERT INTO	#Results ([Period],[ServerName], [DatabaseName], [DataSize], [IndexSize], [Smoothed_MetricA], [Smoothed_MetricB],[B_MetricA],[B_MetricB],[A_MetricA],[A_MetricB])
			SELECT		A.[Period] + 1 
						,A.[ServerName]	
						,A.[DatabaseName]
						,B.A_MetricA + (B.B_MetricA * (A.[Period] + 1))	Trend_MetricA						-- Trendline
						,B.A_MetricB + (B.B_MetricB * (A.[Period] + 1))	Trend_MetricB						-- Trendline
						,(B.A_MetricA + (B.B_MetricA * (A.[Period] + 1)))
						--	*	COALESCE((
						--		SELECT	Case 
						--				WHEN avg(Seasonality_MetricA) = 0 
						--				THEN 1 
						--				ELSE avg(Seasonality_MetricA) 
						--				END 
						--		FROM #Results SeasonalMask
						--		WHERE SeasonalMask.Unit = a.Unit
						--		AND SeasonalMask.CWeek = DatePart(week,dateadd(week,@Loop,@CurrentDate))
						--		),1) Forcast_MetricA	-- Trendline * Avg seasonality

						,(B.A_MetricB + (B.B_MetricB * (A.[Period] + 1)))
						--	*	COALESCE((
						--		SELECT	Case
						--				WHEN avg(Seasonality_MetricB) = 0 
						--				THEN 1 
						--				ELSE avg(Seasonality_MetricB) 
						--				END 
						--		FROM #Results SeasonalMask
						--		WHERE SeasonalMask.Unit = a.Unit
						--		AND SeasonalMask.CWeek = DatePart(week,dateadd(week,@Loop,@CurrentDate))
						--		),1) Forcast_MetricB	-- Trendline * Avg seasonality
						,B.B_MetricA
						,B.B_MetricB
						,B.A_MetricA
						,B.A_MetricB
			FROM		#Results A
			INNER JOIN	B
				ON		A.[ServerName]		= B.[ServerName]
				AND		A.[DatabaseName]	= B.[DatabaseName]
			WHERE		A.[Period] = (SELECT MAX([Period]) FROM #Results)
			--GROUP BY	A.[ServerName]	
			--			,A.[DatabaseName]

			SET @Loop = @Loop + 1

		END

		IF OBJECT_ID('tempdb..#Output') IS NULL
			SELECT		*
			INTO		#Output
			FROM		#Results
		ELSE
			INSERT INTO #Output
			SELECT		*
			FROM		#Results

		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM DBLoopCursor INTO @ServerName,@DatabaseName;
END
CLOSE DBLoopCursor;
DEALLOCATE DBLoopCursor;


SELECT		*
FROM		#Output
ORDER BY	2,3,1