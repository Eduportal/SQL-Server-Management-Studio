
USE tempdb
GO

SET NOCOUNT ON
SET	QUOTED_IDENTIFIER ON

DECLARE @target DECIMAL(5,2)		-- Target Free Space (MB)
DECLARE	@file sysname			-- Modified Candidate Commands Query
SET	@target = 20			-- Modify to desired value of DB Free space %
SET	@file = N'C:\CC.sql'		-- Modify directory and file name as needed

/***************************************************************************
FREESPACE CHECK
							
Purpose: Assist in file size management.  Will produce candidate shrink/grow commands based on given Target.
	This script will execute a modified version of the Candidate Commands script against a list of designated servers.
Calls: xp_fixeddrives, cc.sql (Modified Candidate Commands script)
Data Modifications: None
User Modifications:
 * Modify @target to desired value of free space percent
 * Pass the fully qualified name of the Candidate Commands script to @file.  The script needs to be accessible
    by the sql server service.
 * Mody Cursor for the desired list of servers to use

Known Issue:	There is an issue when dealing with smaller values because this uses int data type. 
		This may round to a value equal to the current file size.Thus a MODIFY FILE statement
			will fail. Workaround: these can be ignored

After you execute this script, copy and paste the candidate commands into a new window
Sample output:
:connect Server1  ALTER DATABASE [master]  MODIFY FILE (   NAME = master,   SIZE = 4   )  GO
:connect Server2  USE [Testy] DBCC SHRINKFILE('TestyData1', 3)  GO

Then add carriage returns in the appropriate places, for example:
:connect Server1  
ALTER DATABASE [master]  MODIFY FILE (   NAME = master,   SIZE = 4   ) 
GO
:connect Server2 
USE [Testy] DBCC SHRINKFILE('TestyData1', 1) 
GO

Then execute in SQLCMD mode (MUST EXECUTE IN SQLCMD MODE)
									
***************************************************************************/

DECLARE @xcmd nvarchar(MAX)		-- Large insert statement
DECLARE @counter tinyint		-- Number of servers (adjust data type as needed)
DECLARE @cmd nvarchar(75)		-- command that pushes query
DECLARE	@Server sysname			-- ServerName
DECLARE @crlf nchar(2)			-- carriage return line feed

SET	@crlf = CHAR(13) + CHAR(10)
--SET	@target = (100.0 - @target) * .01

--CREATE TABLE #BadServers (ServerName sysname)
--INSERT INTO #BadServers VALUES('DLVRSQLDEV01\A')
--INSERT INTO #BadServers VALUES('DLVRSQLDEV01\A02')
--INSERT INTO #BadServers VALUES('DLVRSQLTEST01\A')
--INSERT INTO #BadServers VALUES('DLVRSQLTEST01\A02')
--INSERT INTO #BadServers VALUES('NYCMVSQLDEV01')

-- Initial raw data from sqlcmd (one wide column)
DECLARE @RawResults TABLE (
	RawData nvarchar(800) -- adjust data type as needed
	)

-- Table to hold your final result set
IF OBJECT_ID('tempdb..#FinalResults') IS NOT NULL DROP TABLE #FinalResults
CREATE TABLE #FinalResults   (
	ServerName sysname,
	DBName sysname,
	[FileName] sysname,
	FileType sysname,
	Drive nchar(1),
	UsedData nvarchar(25),
	TotalDataSize nvarchar(25),
	MBFree nvarchar(10),
	Smallest decimal(10,2)
	)

DECLARE ServerCursor CURSOR
FOR
SELECT	DISTINCT
	Machine + CASE WHEN Instance > '' THEN '\' + Instance ELSE '' END
FROM	dbaadmin.dbo.Filescan_MachineSource
WHERE	Machine + CASE WHEN Instance > '' THEN '\' + Instance ELSE '' END NOT IN (SELECT ServerName FROM #BadServers)
  AND	Domain =
	'AMER'
	--'STAGE'
	--'PRODUCTION'
ORDER BY 1

-- Beginning of xp_cmdshell wrapper
-- The xp_cmdshell wrapper is used to maintain the current configuration setting of xp_cmdshell
DECLARE @xp_flag bit

IF EXISTS (SELECT * FROM sys.configurations WITH (NOLOCK)
			WHERE [NAME] = 'xp_cmdshell'
			AND		value_in_use = 1)
BEGIN	
	SET @xp_flag = 1
END
ELSE BEGIN
	SET @xp_flag = 0
	EXEC sp_configure 'show advanced options', 1
	RECONFIGURE WITH OVERRIDE
	EXEC sp_configure 'xp_cmdshell', 1
	RECONFIGURE 
END

OPEN ServerCursor
FETCH NEXT FROM ServerCursor INTO @Server
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		PRINT 'Getting Data From ' + @Server + '...'
		SET @cmd = N'sqlcmd -E -S ' + @Server + N' -I -h-1 -W -s"|" -i ' + @file

		INSERT @RawResults
		EXEC master..xp_cmdshell @cmd

		PRINT '	...Checking for Results'
		IF EXISTS(SELECT * FROM @RawResults WHERE RawData LIKE N'HResult%')
		BEGIN
			PRINT N'Server ' + @server + N' is not reachable.  Please remove the server from your list.'
			INSERT INTO #BadServers VALUES(@server)
		END
		ELSE
		BEGIN
			PRINT '	...Cleaning Results'
			DELETE	@RawResults 
			WHERE	NULLIF(RawData, '') IS NULL
			OR		RawData LIKE N'Changed%'

			PRINT '	...Building Insert Statement'
			SET		@xcmd = ''
			SELECT	@xcmd = @xcmd + 
					N'SELECT ' + QUOTENAME(@server, '''') + ', ' + 
					'''' + REPLACE(RawData, '|', ''', ''') + '''' + @crlf
			FROM @RawResults

			PRINT '	...Storring Results'
			INSERT #FinalResults
			(ServerName, DBName, [FileName], FileType, Drive, UsedData, TotalDataSize, MBFree)
			EXEC (@xcmd)
			IF @@error > 0 PRINT @xcmd
		END
		-- Prepare for next server
		DELETE @RawResults
		PRINT 'Done With ' + @Server + '...'
	END
	FETCH NEXT FROM ServerCursor INTO @Server
END
CLOSE ServerCursor
DEALLOCATE ServerCursor
PRINT 'Completed Gathering Data...'

IF @xp_flag = 0
BEGIN
	PRINT 'Resetting xp_cmdshell...'
	EXEC sp_configure 'xp_cmdshell', 0
	RECONFIGURE 
END

PRINT 'Modifing Results Table...'

UPDATE		#FinalResults
	SET	TotalDataSize	= REPLACE(COALESCE(TotalDataSize,'0.00'),'NULL','0.00')
		,UsedData	=REPLACE(COALESCE(UsedData,'0.00'),'NULL','0.00')
		,MBFree		=REPLACE(COALESCE(MBFree,'0'),'NULL','0')
		
ALTER TABLE #FinalResults
ALTER COLUMN TotalDataSize decimal(10,2)

ALTER TABLE #FinalResults
ALTER COLUMN UsedData decimal(10,2)

ALTER TABLE #FinalResults
ALTER COLUMN MBFree bigint

UPDATE	#FinalResults
SET	Smallest = ((UsedData * @target)/100)+UsedData


-- Uncomment this section only if you want to perform additional queries against #FinalResults using existing data
--DECLARE @crlf char(2)			-- carriage return line feed
--SET		@crlf = CHAR(13) + CHAR(10)

PRINT 'Processing Results...'
SELECT		[ServerName]
		,[DBName]
		,[FileName]
		,[FileType]
		,[Drive]
		,[UsedData]
		,[TotalDataSize]
		,[MBFree] AS [DiskFreeSpace]
		,[Smallest] [SmallestForTarget]
		,[TotalDataSize]-[UsedData] [FreeData]
		,(([TotalDataSize]-[UsedData])*100)/[TotalDataSize]
		,(([TotalDataSize]-[UsedData])*100)/([TotalDataSize]+[MBFree])
		,CASE
			  WHEN TotalDataSize > Smallest 
				THEN (TotalDataSize - Smallest) * -1
			  ELSE Smallest - TotalDataSize 
		END [Change]
		,CASE
			  WHEN TotalDataSize > Smallest THEN CAST(TotalDataSize - Smallest as varchar(10)) + N' Decrease'
			  ELSE CAST(Smallest - TotalDataSize as varchar(10)) + N' Increase'
		END [CandidateResult]
		,CASE 
			WHEN Smallest - TotalDataSize > MBFree THEN N'Insufficient Disk Space'
			WHEN TotalDataSize > Smallest 
				THEN N':connect ' + ServerName + @crlf + N'USE [' + DBName + N'] DBCC SHRINKFILE([' + [FileName]+ N'], ' + CAST(CAST(Smallest as int) as varchar(10)) + N')' + @crlf + N'GO'
			ELSE	N':connect ' + ServerName + @crlf +
					N'ALTER DATABASE [' + DBName + N']' + @crlf + 
					N'MODIFY FILE (' + @crlf + 
					N'	NAME = [' + [FileName] + N'],' + @crlf + 
					N'	SIZE = ' + CAST(CAST(Smallest as int) as varchar(10)) + @crlf + 
					N'	)' + @crlf + N'GO'
		END [CandidateCommand]
FROM	#FinalResults 
WHERE	[DBName] NOT IN ('master','model','msdb','tempdb')
 AND	[TotalDataSize] > 0
ORDER BY 13 Desc


-- RUN THIS WITH OUTPUT TO TEXT TO GET THE COMMANDS FORMATTED CORRECTLY
/*
SELECT		CASE 
			WHEN Smallest - TotalDataSize > MBFree THEN N'Insufficient Disk Space'
			WHEN TotalDataSize > Smallest 
				THEN N':connect ' + ServerName + CHAR(13) + CHAR(10) + N'USE [' + DBName + N'] DBCC SHRINKFILE([' + [FileName]+ N'], ' + CAST(CAST(Smallest as int) as varchar(10)) + N')' + CHAR(13) + CHAR(10) + N'GO'
			ELSE	N':connect ' + ServerName + CHAR(13) + CHAR(10) +
					N'ALTER DATABASE [' + DBName + N']' + CHAR(13) + CHAR(10) + 
					N'MODIFY FILE (' + CHAR(13) + CHAR(10) + 
					N'	NAME = [' + [FileName] + N'],' + CHAR(13) + CHAR(10) + 
					N'	SIZE = ' + CAST(CAST(Smallest as int) as varchar(10)) + CHAR(13) + CHAR(10) + 
					N'	)' + CHAR(13) + CHAR(10) + N'GO'
		END [CandidateCommand]
FROM	#FinalResults 
WHERE	[DBName] NOT IN ('master','model','msdb','tempdb')
 AND	[TotalDataSize] > 0
ORDER BY CASE
			  WHEN TotalDataSize > Smallest 
				THEN (TotalDataSize - Smallest) * -1
			  ELSE Smallest - TotalDataSize 
		END Desc
*/







--SELECT * FROM #FinalResults 
GO
--DROP TABLE #FinalResults
GO
SELECT 'INSERT INTO #BadServers VALUES('''+ServerName+''')' 
FROM #BadServers
GO