SET NUMERIC_ROUNDABORT OFF;
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT,
    QUOTED_IDENTIFIER, ANSI_NULLS ON;
GO
DROP VIEW	dbo.ScomReportData
GO
CREATE VIEW	dbo.ScomReportData
WITH SCHEMABINDING
AS
SELECT		LEFT(ServerName,CHARINDEX('\',ServerName+'\')-1) AS ServerName	
			,REPLACE(REPLACE(CounterName,'/',CHAR(13)+CHAR(10)),' ',CHAR(13)+CHAR(10)) AS [CounterName]
			,Time	
			,Value
			,Slope
FROM		dbo.SCOM_BUFFER_ReportData
WHERE		CounterName NOT IN ('Broker Transaction Rollbacks','','','')
GO
CREATE UNIQUE CLUSTERED INDEX IDX_ScomReportData 
    ON dbo.ScomReportData (ServerName, CounterName, Time)
 
GO

DECLARE		@ServerName sysname = 'G1SQLB'


--SELECT		ServerName	
--			,CounterName
--			,Time	
--			,CAST(REPLACE(REPLACE(REPLACE([dbaadmin].[dbo].[dbaudf_FormatNumber] (Value,20,2),',',''),'(','-'),')','') AS FLOAT) AS Value
--			,CAST(REPLACE(REPLACE(REPLACE([dbaadmin].[dbo].[dbaudf_FormatNumber] (Slope,20,2),',',''),'(','-'),')','')AS FLOAT) AS Slope
--FROM		dbaperf.dbo.ScomReportData
--WHERE		ServerName = @ServerName
--		AND	CounterName NOT IN ('Broker Transaction Rollbacks','','','')
----AND Time >= @Start AND Time <= @End
--ORDER BY	1,2,3


SELECT		ServerName	
			,REPLACE(REPLACE(CounterName,'/',CHAR(13)+CHAR(10)),' ',CHAR(13)+CHAR(10)) AS [CounterName]
			,Time	
			,CAST(REPLACE(REPLACE(REPLACE([dbaadmin].[dbo].[dbaudf_FormatNumber] (Value,20,2),',',''),'(','-'),')','') AS FLOAT) AS Value
			,CAST(REPLACE(REPLACE(REPLACE([dbaadmin].[dbo].[dbaudf_FormatNumber] (Slope,20,2),',',''),'(','-'),')','')AS FLOAT) AS Slope
FROM		dbaperf.dbo.SCOM_BUFFER_ReportData WITH(NOLOCK)
WHERE		CounterName NOT IN ('Broker Transaction Rollbacks','','','')
		AND	LEFT(ServerName,CHARINDEX('\',ServerName+'\')-1) = LEFT(@ServerName,CHARINDEX('\',@ServerName+'\')-1)
--AND Time >= @Start AND Time <= @End
ORDER BY	1,2,3

