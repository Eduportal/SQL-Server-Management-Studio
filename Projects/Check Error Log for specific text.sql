


SET NOCOUNT ON
DECLARE		@Status			VarChar(8000)
DECLARE		@SQLBitLevel		VarChar(2)

SELECT		@Status = 'BAD'
		,@SQLBitLevel = -- select 
		 CASE	WHEN SQLver LIKE '%X86%' THEN 	'32'
					WHEN SQLver LIKE '%X64%' THEN 	'64'
					END
FROM		dbaadmin.dbo.DBA_ServerInfo

IF OBJECT_ID('tempdb..#ErrorLog') IS NOT NULL DROP TABLE #ErrorLog
IF OBJECT_ID('tempdb..#LogList') IS NOT NULL DROP TABLE #LogList

CREATE TABLE #ErrorLog
	(
	LogDate		DateTime
	,ProcessInfo	SYSNAME
	,Text		VarChar(8000)
	)
CREATE TABLE #LogList

	(
	Archive			INT
	,Date			DateTime
	,[Log File Size (Byte)]	INT
	)
	
INSERT INTO #LogList	
EXEC xp_enumerrorlogs 1 	

DECLARE ErrorLogCursor CURSOR
FOR
SELECT Archive From #LogList 
Order By 1

DECLARE @Archive Int

DECLARE	@Now	DATETIME
SELECT	@Now	= GETDATE()

OPEN ErrorLogCursor
FETCH NEXT FROM ErrorLogCursor INTO @Archive
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		PRINT 'CHECKING LOG ' +CAST(@Archive as VarChar(50))
		
		INSERT INTO #ErrorLog
		EXEC xp_readerrorlog @Archive,1,'Using locked pages for buffer pool'
		
		INSERT INTO #ErrorLog
		EXEC xp_readerrorlog @Archive, 1,  'Starting up database ''master'''
		
		--INSERT INTO #ErrorLog
		--EXEC xp_readerrorlog @Archive, 1, 'warning'
		
		--INSERT INTO #ErrorLog
		--EXEC xp_readerrorlog @Archive, 2, 'TCP', 'forcibly'

	END
	FETCH NEXT FROM ErrorLogCursor INTO @Archive
END

CLOSE ErrorLogCursor
DEALLOCATE ErrorLogCursor
	
--SELECT * From #ErrorLog

IF @SQLBitLevel = 32
	SET @Status = 'NA'
ELSE
BEGIN
	IF EXISTS (SELECT * From #ErrorLog WHERE Text Like '%Starting up database ''master''%')
	BEGIN
		IF EXISTS (SELECT * From #ErrorLog WHERE Text Like '%Using locked pages for buffer pool%')
			SET @Status = 'OK'
	END
	ELSE
		SET @Status = '??'
END

SELECT @SQLBitLevel,@Status

--SELECT		DATENAME(weekday,LogDate)
--		,DATEADD(mi, (DATEDIFF(mi, 0, LogDate)/30*30), 0)
--FROM		#ErrorLog

--SELECT		DISTINCT
--		*
--FROM		#ErrorLog 
----WHERE		DATEDIFF(hour,LogDate,@Now) < 24
--ORDER BY	LogDate desc


--SELECT		CAST(CONVERT(VarChar(12),LogDate,101)AS DateTime) [EventDate]
--		,ProcessInfo
--		--,REPLACE(REPLACE(REPLACE(REPLACE(Text,'[','|'),']','|'),'encountered','|'),'occurrence(s)','|')
--		,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(Text,'[','|'),']','|'),'encountered','|'),'occurrence(s)','|'),6) [DataBase]
--		,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(Text,'[','|'),']','|'),'encountered','|'),'occurrence(s)','|'),4) [File]
--		,SUM(CAST(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(Text,'[','|'),']','|'),'encountered','|'),'occurrence(s)','|'),2) AS INT)) [Times]
--		,COUNT(*) [Cnt]
--FROM		#ErrorLog 
--WHERE		DATEDIFF(hour,LogDate,@Now) < 24
--GROUP BY	CAST(CONVERT(VarChar(12),LogDate,101)AS DateTime)
--		,ProcessInfo
--		--,REPLACE(REPLACE(REPLACE(REPLACE(Text,'[','|'),']','|'),'encountered','|'),'occurrence(s)','|')
--		,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(Text,'[','|'),']','|'),'encountered','|'),'occurrence(s)','|'),6)
--		,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(Text,'[','|'),']','|'),'encountered','|'),'occurrence(s)','|'),4) 
--		--,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(Text,'[','|'),']','|'),'encountered','|'),'occurrence(s)','|'),2)
--ORDER BY	1,2,3

		
--SELECT @Status

--DROP TABLE #ErrorLog
--DROP TABLE #LogList
--SQL Server has encountered 1 occurrence(s) of I/O requests taking longer than 15 seconds to complete on file |E:\Data\Getty_Images_US_Inc__MSCRM.mdf| in database |Getty_Images_US_Inc__MSCRM| (8).  The OS file handle is 0x0000000000000C3C.  The offset of the latest long I/O is: 0x000010ade52000