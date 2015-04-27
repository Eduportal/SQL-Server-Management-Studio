DBCC TRACEON(1222,-1)	-- This trace flag returns the resources and types of locks that are participating in a deadlock and also the current command affected, in an XML format that does not comply with any XSD schema.
DBCC TRACEON (3605,-1)	-- This trace flag sends trace output to the error log. The error log is located \program files\MSSQL\Log\ERRORLOG, notice the date and time of the error log to get the correct log file.
DBCC TRACEON (1204,-1)	-- This trace flag returns the type of locks participating in the deadlock and the current command affected.
DBCC TRACEON (1205,-1)	-- This trace flag returns more detailed information about the command being executed at the time of a deadlock.


--DBCC TRACEON (3226,-1)


--/*-- OTHER TRACE FLAGS FROM http://msdn.microsoft.com/en-us/library/ms188396.aspx

--3226	-- By default, every successful backup operation adds an entry in the SQL Server error log and in the system event log. If you create very frequent log backups, these success messages accumulate quickly, resulting in huge error logs in which finding other messages is problematic.
--		-- With this trace flag, you can suppress these log entries. This is useful if you are running frequent log backups and if none of your scripts depend on those entries.

--3042	-- Bypasses the default backup compression pre-allocation algorithm to allow the backup file to grow only as needed to reach its final size. This trace flag is useful if you need to save on space by allocating only the actual size required for the compressed backup. Using this trace flag might cause a slight performance penalty (a possible increase in the duration of the backup operation).
--		-- For more information about the pre-allocation algorithm, see Backup Compression (SQL Server).

--*/
--DBCC TRACESTATUS 
--DBCC TRACEOFF(1222,-1)	-- This trace flag returns the resources and types of locks that are participating in a deadlock and also the current command affected, in an XML format that does not comply with any XSD schema.
--DBCC TRACEOFF (3605,-1)	-- This trace flag sends trace output to the error log. The error log is located \program files\MSSQL\Log\ERRORLOG, notice the date and time of the error log to get the correct log file.
--DBCC TRACEOFF (1204,-1)	-- This trace flag returns the type of locks participating in the deadlock and the current command affected.
--DBCC TRACEOFF (1205,-1)