
USE tempdb
GO

SET NOCOUNT ON
SET	QUOTED_IDENTIFIER ON

DECLARE @target DECIMAL(5,2)
SET		@target = 20	-- Modify to desired value of free space %

/***************************************************************************
Candidate Commands				
							
Purpose: Assist in file size management.  Will produce candidate shrink/grow commands based on given Target						
Calls: xp_fixeddrives 		
Data Modifications: None

User Modifications:
 * Modify @target to desired value of free space percent

Known Issue: There is an issue when dealing with smaller values because the
candidate commands use int data type. The candidate command may round to a value equal to the current file size.
Thus a MODIFY FILE statement will fail. Workaround: Add 1 to the candidate command	
									
***************************************************************************/

DECLARE	@cmd varchar(1000)          -- various commands
DECLARE	@counter tinyint            -- Number of databases
DECLARE	@crlf char(2)               -- carriage return line feed
DECLARE	@db sysname                 -- Database Name

SET		@crlf = CHAR(13) + CHAR(10)
SET		@target = (100.0 - @target) * .01

IF OBJECT_ID('tempdb..#Results') IS NOT NULL DROP TABLE #Results
CREATE TABLE #Results (
	DBName sysname,
	[FileName] sysname,
	FileType sysname,
	Drive char(1),
	UsedData varchar(25),
	TotalDataSize varchar(25),
	Smallest decimal(10,2)
	)

-- Databases to examine
DECLARE @Databases TABLE  (
	DID tinyint IDENTITY(1,1) primary key,
	db sysname NULL
	)

-- Hold values from xp_fixeddrives
DECLARE @DiskInfo TABLE(
	Drive char(1) primary key,
	MBFree int
	)

-- Gather databases
INSERT @Databases
SELECT	DISTINCT sd.[name]
FROM	sys.master_files mf WITH (NOLOCK)
JOIN	sys.databases sd WITH (NOLOCK)
ON		mf.database_id = sd.database_id
WHERE	sd.[state] = 0
AND		sd.is_read_only = 0
AND		sd.is_in_standby = 0
AND		sd.[name] NOT IN ('model', 'tempdb')
AND		mf.[type] = 0
-- to exclude databases that have a full text-catalog offline
AND		sd.database_id NOT IN (
                            SELECT DISTINCT database_id
                            FROM  sys.master_files WITH (NOLOCK)
                            WHERE [state] <> 0)

SET		@counter = SCOPE_IDENTITY()

WHILE	@counter > 0
BEGIN
		SELECT      @db = db
		FROM  @Databases
		WHERE DID = @counter    

		SELECT @cmd = 

		N'USE [' + @db + N']' +  @crlf + 
		N'SET NOCOUNT ON' + @crlf + 
		N'SELECT     '+ QUOTENAME(@db, '''') + N',' + @crlf + 
		N'[name],' + @crlf + 
		N'CASE type ' + @crlf + 
		N'     WHEN 0 THEN ''DATA''' + @crlf + 
		N'     WHEN 1 THEN ''LOG'''  + @crlf + 
		N'     ELSE ''Other''' + @crlf + 
		N'END,' + @crlf + 
		N'LEFT(physical_name, 1), ' + @crlf + 
		N'CAST(FILEPROPERTY ([name], ''SpaceUsed'')/128.0 as varchar(15)),' + @crlf + 
		N'CAST([size]/128.0 as varchar(15))' + @crlf + 
		N'FROM sys.database_files WITH (NOLOCK)' + @crlf + 
		N'WHERE      [state] = 0' + @crlf + 
		N'AND        [type] IN (0,1)'

		-- Preliminary results
		INSERT #Results
		(DBName, [FileName], FileType, Drive, UsedData, TotalDataSize)
		EXEC (@cmd)

		SET   @counter = @counter - 1
END

ALTER TABLE #Results
ALTER COLUMN TotalDataSize decimal(10,2)

ALTER TABLE #Results
ALTER COLUMN UsedData decimal(10,2)

UPDATE	#Results
SET		Smallest = UsedData / @target

-- Command determines free space in MB
INSERT INTO @DiskInfo
EXEC master..xp_fixeddrives

---- Final Query
SELECT	DBName,
		[FileName],
		FileType,
		r.Drive,
		UsedData,
		TotalDataSize - UsedData N'FreeData',
		TotalDataSize,
		CAST(((TotalDataSize - UsedData) / TotalDataSize) * 100 as decimal(5,2)) [%DataFeeSpace],
		d.MBFree N'DiskFreeSpace',
		Smallest N'SmallestForTarget',
		CASE
			  WHEN TotalDataSize > Smallest THEN CAST(TotalDataSize - Smallest as varchar(10)) + N' Decrease'
			  ELSE CAST(Smallest - TotalDataSize as varchar(10)) + N' Increase'
		END N'CandidateResult',
		CASE 
			WHEN Smallest - TotalDataSize > d.MBFree THEN N'Insufficient Disk Space'
			  WHEN TotalDataSize > Smallest 
					THEN N'USE [' + DBName + N'] DBCC SHRINKFILE([' + [FileName] + N'], ' + CAST(CAST(Smallest as int) as varchar(10)) + N')'
			  ELSE  N'ALTER DATABASE [' + DBName + N']' + @crlf + 
						  N'MODIFY FILE (' + @crlf + 
						  N'     NAME = [' + [FileName] + N'],' + @crlf + 
						  N'     SIZE = ' + CAST(CAST(Smallest as int) as varchar(10)) + @crlf + 
						  N'     )' 
		END N'CandidateCommand'
FROM	#Results r
JOIN	@DiskInfo d
ON		r.Drive = d.Drive
ORDER BY (TotalDataSize - UsedData) / TotalDataSize

DROP TABLE #Results


