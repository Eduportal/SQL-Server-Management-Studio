SELECT
    COUNT(Name) AS ExecutionCount,
    Name,
    SUM(TimeDataRetrieval) AS TimeDataRetrievalSum,
    SUM(TimeProcessing) AS TimeProcessingSum,
    SUM(TimeRendering) AS TimeRenderingSum,
    SUM(ByteCount) AS ByteCountSum,
    SUM([RowCount]) AS RowCountSum
FROM
    (
     SELECT
        TimeStart,
        Catalog.Type,
        Catalog.Name,
        TimeDataRetrieval,
        TimeProcessing,
        TimeRendering,
        ByteCount,
        [RowCount]
     FROM
        Catalog
     INNER JOIN ExecutionLog
        ON Catalog.ItemID = ExecutionLog.ReportID
     WHERE
        Type = 2
    ) AS RE
GROUP BY
    Name
ORDER BY
    COUNT(Name) DESC,
    Name


SELECT
ex.UserName, ex.Format, ex.TimeStart, cat.Name, 
ex.Parameters, 
CONVERT(nvarchar(10), ex.TimeStart, 101) AS rundate
FROM ExecutionLog AS ex, Catalog AS cat
where ex.ReportID = cat.ItemID AND cat.Name = 'IndexHealthCheck'
ORDER BY ex.TimeStart DESC