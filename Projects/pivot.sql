DROP TABLE #Data
GO

DECLARE	@EventDate	DATETIME			-- FOR TESTING
SET	@EventDate	= CAST(CONVERT(VARCHAR(12)
			,GETDATE()-1			-- FOR TESTING
			,101)AS DATETIME)		--STRIP OFF TIME  



SELECT		TOP 25
		ROW_NUMBER() OVER (ORDER BY OrderDate) AS 'RowNumber'
		,[Server]
		,MAX([UniqueCount])    [UniqueCount]
FROM		[dbaadmin].[dbo].[dbaudf_Filescan_DateSummary] (@EventDate)
GROUP BY	[Server]
ORDER BY	2 Desc


--WITH DataData AS
--(
--    SELECT SalesOrderID, OrderDate,
--    ROW_NUMBER() OVER (ORDER BY OrderDate) AS 'RowNumber'
--    FROM Sales.SalesOrderHeader 
--) 
--SELECT * 
--FROM OrderedOrders 
--WHERE RowNumber BETWEEN 50 AND 60;


			
CREATE TABLE #Data (SERVER sysname,KnownCondition sysname,UniqueCount INT)
DECLARE @columns VARCHAR(8000)
DECLARE @Query VARCHAR(8000)
			
INSERT INTO #Data			
SELECT		TOP 25
		*
FROM		[dbaadmin].[dbo].[dbaudf_Filescan_DateSummary] (@EventDate)      T1
--LEFT JOIN	(			
--		SELECT		TOP 25
--				[Server]
--				,MAX([UniqueCount])    [UniqueCount]
--		FROM		[dbaadmin].[dbo].[dbaudf_Filescan_DateSummary] (@EventDate)
--		GROUP BY	[Server]
--		ORDER BY	2 Desc
--		)  T2
--	ON	T1.[Server] = T2.[Server]	
--LEFT JOIN	(
--		SELECT		TOP 25
--				[KnownCondition]
--				,MAX([UniqueCount])    [UniqueCount]
--		FROM		[dbaadmin].[dbo].[dbaudf_Filescan_DateSummary] (@EventDate)
--		GROUP BY	[KnownCondition]
--		ORDER BY	2 DESC
--		)  T3
--	ON	T1.[KnownCondition] = T3.[KnownCondition]
ORDER BY	T1.[UniqueCount] DESC

SELECT @columns = COALESCE(
	@columns + ',[' + cast(KnownCondition as varchar) + ']'
	,'[' + cast(KnownCondition as varchar)+ ']')
FROM #Data
GROUP BY KnownCondition

SET @query =
'SELECT *
FROM #Data
PIVOT
(
SUM([UniqueCount])
FOR [KnownCondition]
IN (' + @columns + ')
)
AS p'

EXEC(@query)
GO

--USE dbaadmin
--GO

--IF OBJECT_ID (N'dbo.dbaudf_Filescan_DateSummary') IS NOT NULL
--    DROP FUNCTION dbo.dbaudf_Filescan_DateSummary
--GO

--CREATE FUNCTION dbo.dbaudf_Filescan_DateSummary(@EventDate datetime)
--RETURNS TABLE
--AS RETURN
--(
--SELECT		UPPER(Machine + CASE WHEN Instance > '' THEN '\' + Instance ELSE '' END) AS [Server]
--		,[KnownCondition] 
--		,COUNT(DISTINCT FixData) AS [UniqueCount]
--FROM		[dbaadmin].[dbo].[Filescan_History] T1  WITH(NOLOCK)
--WHERE		[EventDateTime] >= @EventDate
--	AND	[EventDateTime] < @EventDate+1
--GROUP BY	UPPER(Machine + CASE WHEN Instance > '' THEN '\' + Instance ELSE '' END)
--		,[KnownCondition]
--)
--GO
