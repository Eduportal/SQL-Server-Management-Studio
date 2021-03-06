USE [MG_DB_RPT]
GO
CREATE FUNCTION [dbo].[MFLogSummary_ByGroup](@LimitValue int= 10,@HoursBack Int = 6,@Interval Char(1)='H')
RETURNS TABLE
AS RETURN
(
SELECT	TOP 100 PERCENT
	[DateTime]
	,[channelgroup]
	,[UnderLimit]
	,[Count]
	,([UnderLimit]*100.00)/[Count] AS [PercentUnderLimit]
	,(
		SELECT	TOP 1 backlog_cnt_total 
		FROM MG_DB_RPT.dbo.BacklogOutputSummaryHistory 
		WHERE [createdate] <= CAST(Data.[DateTime] AS DateTime)  
		ORDER BY [createdate] DESC
	) [BackLog]
FROM	(
	SELECT		CASE @Interval
			WHEN 'D' THEN CAST(CONVERT(VarChar(11),[eventtime],120)+'00:00:00' AS DateTime)
			WHEN 'H' THEN CAST(CONVERT(VarChar(14),[eventtime],120)+'00:00' AS DateTime)
			ELSE CAST(CONVERT(VarChar(17),[eventtime],120)+'00' AS DateTime)
			END [DateTime]
			,[channelgroup]
			,SUM(CASE WHEN CAST([duration] AS INT)<= @LimitValue THEN 1 ELSE 0 END) [UnderLimit]	
			,count(*) [Count]
	FROM		(
			SELECT		TOP 100 PERCENT
					T1.[eventtime]
					,T2.[channelgroup]
					,CAST(T1.[duration] AS FLOAT)[duration]
			FROM		[MG_DB].[dbo].[mflog] T1 WITH(NOLOCK)
			JOIN		[MG_DB_RPT].[dbo].[MediaFactoryChannels] T2 WITH(NOLOCK)
				ON	T1.[channel] = T2.[channelname]
			WHERE		T1.[eventtime] >= DATEADD(hour,(@HoursBack*-1),CAST(CONVERT(VarChar(14),GetDate(),120)+'00:00' AS DateTime))
				AND	T1.[duration]  NOT LIKE 't%'
			ORDER BY	T1.[eventtime] DESC
			)Data
	GROUP BY	CASE @Interval
			WHEN 'D' THEN CAST(CONVERT(VarChar(11),[eventtime],120)+'00:00:00' AS DateTime)
			WHEN 'H' THEN CAST(CONVERT(VarChar(14),[eventtime],120)+'00:00' AS DateTime)
			ELSE CAST(CONVERT(VarChar(17),[eventtime],120)+'00' AS DateTime)
			END,[channelgroup]
	)Data
	
ORDER BY 1 DESC
)



SELECT * FROM [dbo].[MFLogSummary_ByGroup] (10,360,'D')