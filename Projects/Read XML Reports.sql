DECLARE @TSQL		VarChar(8000)
DECLARE	@FilePath	VarChar(8000)
DECLARE @FileName	VarChar(4000)
DECLARE @XMLDoc		XML

SET @FilePath = '\\G1SQLA\G1SQLA$A_dbasql\XMLData\' -- ENDING WITH \


CREATE TABLE #DirectoryListing (ln nvarchar(4000))
CREATE TABLE #XMLData	(
						XMLFileID INT IDENTITY(1,1)
						, XMLFileName VarChar(8000)
						, XMLData xml
						)
CREATE TABLE #Customer (
					   CustomerId INT PRIMARY KEY,
					   CompanyName NVARCHAR(20),
					   City NVARCHAR(20)
					   )						
						

set @TSQL = 'DIR '+@FilePath+'*.xml /b'
Insert #DirectoryListing exec master..xp_cmdshell @TSQL

delete from #DirectoryListing
where	ln is NULL
 or	ln like 'File Not Found'
 or ln like 'Schema.xml' -- Dont Import Schema Files
 

-- =============================================
-- READ XML FILES INTO #XMLData TABLE
-- =============================================
DECLARE	XMLFileCursor CURSOR 
FOR
SELECT DISTINCT ln FROM #DirectoryListing
OPEN XMLFileCursor
FETCH NEXT FROM XMLFileCursor INTO @FileName
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		
		-- READ FILE CONTENTS AND SAVE TO TABLE
		SET @FileName = @FilePath + @FileName
		SET @TSQL =
		'INSERT INTO	#XMLData(XMLFileName,XMLData)'+CHAR(13)+CHAR(10)
		+'SELECT		'''+@FileName+''',[XML].[Data]'+CHAR(13)+CHAR(10)
		+'FROM		OPENROWSET(BULK '''+@FileName+''',SINGLE_BLOB) AS [XML]([Data])'
		EXEC (@TSQL)
		
		SELECT	@XMLDoc = XMLData
		FROM	#XMLData 
		WHERE	XMLFileName = @FileName
		
		SELECT	a.b.value('Name[1]','VarChar(1024)')			AS ReportName
				,a.b.value('Server[1]','sysname')				AS ReportServer
				,a.b.value('RunTime[1]','datetime')				AS ReportRunTime
		FROM	@XMLDoc.nodes('/ROOT/Report') a(b)
		
		SELECT	a.b.value('./@Name','VarChar(50)')				AS ParameterName
				,a.b.value('./@Value','VarChar(1024)')			AS ParameterValue
		FROM	@XMLDoc.nodes('/ROOT/Report/Parameters/*') a(b)

		SELECT	a.b.value('./@Unit','VarChar(50)')				AS Unit
				,a.b.value('./@Period','VarChar(50)')			AS Period
				,a.b.value('./@Recorded','numeric(38,17)')		AS Recorded
				,a.b.value('./@Forcast','numeric(38,17)')		AS Forcast
				,a.b.value('./@Trend','numeric(38,17)')			AS Trend
				,a.b.value('./@CurrentSizeMB','numeric(38,17)')	AS CurrentSizeMB
				,a.b.value('./@TargetSizeMB','numeric(38,17)')	AS TargetSizeMB
				,a.b.value('./@CurrentLimitMB','numeric(38,17)')AS CurrentLimitMB
		FROM	@XMLDoc.nodes('/ROOT/ChartData/*') a(b)
		
		SELECT	a.b.value('CurrentSizeMB[1]','numeric(38,17)')	AS CurrentSizeMB
				,a.b.value('CurrentLimit[1]','numeric(38,17)')	AS CurrentLimitMB
				,a.b.value('TimeTillTarget[1]','VarChar(50)')	AS TimeTillTarget
				,a.b.value('TimeTillCL[1]','VarChar(50)')		AS TimeTillCL
		FROM	@XMLDoc.nodes('/ROOT/Results') a(b)		
		
		-- DELETE FILE AFTER READING
		SET @TSQL = 'DEL '+ @FileName
		--exec master..xp_cmdshell @TSQL, no_output
		
	END
	FETCH NEXT FROM XMLFileCursor INTO @FileName
END
CLOSE XMLFileCursor
DEALLOCATE XMLFileCursor
-- =============================================
-- READ XML FILES INTO #XMLData TABLE
-- =============================================





SELECT * FROM #XMLData



GO
DROP TABLE #DirectoryListing
DROP TABLE #XMLData
DROP TABLE #Customer