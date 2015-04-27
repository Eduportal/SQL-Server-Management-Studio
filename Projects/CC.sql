
SET NOCOUNT ON

/***************************************************************************
CC
							
Purpose: This script is designed to be called by Candidate Commands Plus!
	See CandidateCommandsPlus.sql for more info
			
A specially modified version of Candidate Commands
									
***************************************************************************/

DECLARE @TSQL VARCHAR(8000)

CREATE TABLE #Results (
	DBName sysname,
	[FileName] sysname,
	FileType sysname,
	Drive char(1),
	UsedData varchar(25),
	TotalDataSize varchar(25)
	)

-- Hold values from xp_fixeddrives
CREATE TABLE #DiskInfo (
	Drive char(1) primary key,
	MBFree int
	)

SET @TSQL =
'USE [?];
INSERT #Results(DBName, [FileName], FileType, Drive, UsedData, TotalDataSize)
SELECT	''?''
	,name
	,CASE groupid WHEN 1 THEN ''DATA'' WHEN 0 THEN ''LOG'' ELSE ''Other'' END
	,LEFT(filename,1)
	,CAST(FILEPROPERTY ([name], ''SpaceUsed'')/128.0 as varchar(15))
	,CAST(size/128.0as varchar(15))
FROM [?]..sysfiles'
EXEC sp_MSForEachDB @TSQL

-- Command determines free space in MB
INSERT INTO #DiskInfo
EXEC master..xp_fixeddrives

SELECT	DBName,
		[FileName],
		FileType,
		r.Drive,
		UsedData,
		TotalDataSize,
		MBFree
FROM	#Results r
JOIN	#DiskInfo d
ON		r.Drive = d.Drive
	
DROP TABLE #Results
DROP TABLE #DiskInfo
