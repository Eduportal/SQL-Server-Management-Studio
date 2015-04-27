USE maint 
GO 
IF OBJECT_ID('create_alert_notification') IS NOT NULL DROP PROC create_alert_notification 
GO 

CREATE PROC create_alert_notification 
@msgid INT 
,@sev INT 
AS 
--------------------------------------------------------------------------------------------------- 
--This procedure create alert and operator notification 
--It is a wrapper around sp_add_alert and sp_add_notification 
--Paramaters: 
-- @msgid error number to define alert for. Specify 0 if for severity level. 
-- @sev severity level to define alert for. Specify 0 if for error number. 
--One of above must be 0 and the other must be > 0 

--IMPORTANT: Walk the code and replace ward-wired values. 
--Operator name is obvious, but also check other relevant parameter. Adjust to suit you! 

--2009-05-29 Tibor Karaszi 
--------------------------------------------------------------------------------------------------- 
DECLARE 
@alert_name sysname 
,@ret INT 
--Not both @msgid and @sev can be <> 0 
IF @msgid <> 0 AND @sev <> 0 
BEGIN 
RAISERROR('Cannot have both error number and severity <> 0.', 16, 0) 
RETURN -101 
END 

SET @alert_name = 
CASE 
WHEN @sev = 0 THEN 'Error ' + (RIGHT('00000' + CAST(@msgid AS VARCHAR(20)),5)) 
ELSE 'Severity level ' + CAST(@sev AS VARCHAR(20)) 
END 

BEGIN TRY 
EXEC @ret = msdb.dbo.sp_add_alert 
@name = @alert_name 
,@message_id = @msgid 
,@severity = @sev 
,@delay_between_responses = 600 --10 minutes 
,@include_event_description_in = 1 --Email 

EXEC msdb.dbo.sp_add_notification 
@alert_name = @alert_name 
,@operator_name=N'Tibor' 
,@notification_method = 1 
END TRY 

BEGIN CATCH 
DECLARE 
@err_str VARCHAR(2000) 
,@err_sev tinyint 
,@err_state tinyint 
,@err_proc VARCHAR(200) 
SET @err_str = ERROR_MESSAGE() + ' Error rooted in procdure "' + ERROR_PROCEDURE() + '".' 
SET @err_sev = ERROR_SEVERITY() 
SET @err_state = ERROR_STATE() 
RAISERROR(@err_str, @err_sev, @err_state) 
END CATCH 
/* 
--Test execution 
EXEC create_alert_notification @msgid = 1105, @sev = 0 
EXEC create_alert_notification @msgid = 0, @sev = 18 
EXEC create_alert_notification @msgid = 55000, @sev = 0 
EXEC create_alert_notification @msgid = 55000, @sev = 18 
*/ 
GO 


The alert definitions
--Code below defines SQL Server Agent alerts. 
--Don't use it if you don't understand the code. 
USE maint 
GO 

--Query to play with, to investigate sysmessages 
SELECT message_id, severity, is_event_logged, TEXT, language_id 
FROM sys.messages 
WHERE language_id = 1033 
AND severity < 16 
AND is_event_logged = 1 
ORDER BY severity DESC, message_id 

--All severity level 16 and higher 
EXEC create_alert_notification @msgid = 0, @sev = 16 
EXEC create_alert_notification @msgid = 0, @sev = 17 
EXEC create_alert_notification @msgid = 0, @sev = 18 
EXEC create_alert_notification @msgid = 0, @sev = 19 
EXEC create_alert_notification @msgid = 0, @sev = 20 
EXEC create_alert_notification @msgid = 0, @sev = 21 
EXEC create_alert_notification @msgid = 0, @sev = 22 
EXEC create_alert_notification @msgid = 0, @sev = 23 
EXEC create_alert_notification @msgid = 0, @sev = 24 
EXEC create_alert_notification @msgid = 0, @sev = 25 

--Other, selected errors: 
--Level 14 
EXEC create_alert_notification @msgid = 18401, @sev = 0 

--Level 13 
--None that by default goes to eventlog 
--Only add below if you are on 2005sp3 or 2008sp1, or higher: 
EXEC sp_altermessage @message_id = 1205, @parameter = 'WITH_LOG', @parameter_value = 'true' 
EXEC create_alert_notification @msgid = 1205, @sev = 0 

--Level 12 
--None that by default goes to eventlog 
--Only add below if you are on 2005sp3 or 2008sp1, or higher: 
EXEC sp_altermessage @message_id = 601, @parameter = 'WITH_LOG', @parameter_value = 'true' 
EXEC create_alert_notification @msgid = 601, @sev = 0 

--Level 10 
--There are so many of these so we auto-generate the calls 
--(which also auto-adapt to prior version which might how have some message). 
--We create a temp tables with alerts we want, and then use that when we select from sys.messages. 
--You can of course make the temp table a permanent table, add version information etc. 
--Execute below into text and take the generated call, paste them to query windows and execute. 
IF OBJECT_ID('tempdb..#alerts_to_include') IS NOT NULL DROP TABLE #alerts_to_include 
GO 
CREATE TABLE #alerts_to_include 
(message_id INT PRIMARY KEY, short_msg VARCHAR(90), already_defined bit DEFAULT 0) 

INSERT INTO #alerts_to_include(message_id, short_msg) 
SELECT 674, 'Exception occurred in destructor of RowsetNewSS 0x%p...' 
UNION ALL 
SELECT 708, 'Server is running low on virtual address space or machine is running low on virtual...' 
UNION ALL 
SELECT 806, 'audit failure (a page read from disk failed to pass basic integrity checks)...' 
UNION ALL 
SELECT 825, 'A read of the file %ls at offset %#016I64x succeeded after failing %d time(s) wi..' 
UNION ALL 
SELECT 973, 'Database %ls was started . However, FILESTREAM is not compatible with the READ_COM...' 
UNION ALL 
SELECT 3401, 'Errors occurred during recovery while rolling back a transaction...' 
UNION ALL 
SELECT 3410, 'Data in filegroup %s is offline, and deferred transactions exist...' 
UNION ALL 
SELECT 3414, 'An error occurred during recovery, preventing the database %.*ls (database ID %d)...' 
UNION ALL 
SELECT 3422, 'Database %ls was shutdown due to error %d in routine %hs.' 
UNION ALL 
SELECT 3452, 'Recovery of database %.*ls (%d) detected possible identity value inconsistency...' 
UNION ALL 
SELECT 3619, 'Could not write a checkpoint record in database ID %d because the log is out of space...' 
UNION ALL 
SELECT 3620, 'Automatic checkpointing is disabled in database %.*ls because the log is out of spac...' 
UNION ALL 
SELECT 3959, 'Version store is full. New version(s) could not be added.' 
UNION ALL 
SELECT 5029, 'Warning: The log for database %.*ls has been rebuilt.' 
UNION ALL 
SELECT 5144, 'Autogrow of file %.*ls in database %.*ls was cancelled by user or timed out...' 
UNION ALL 
SELECT 5145, 'Autogrow of file %.*ls in database %.*ls took %d milliseconds.' 
UNION ALL 
SELECT 5182, 'New log file %.*ls was created.' 
UNION ALL 
SELECT 8539, 'The distributed transaction with UOW %ls was forced to commit...' 
UNION ALL 
SELECT 8540, 'The distributed transaction with UOW %ls was forced to rollback. ' 
UNION ALL 
SELECT 9001, 'The log for database %.*ls is not available.' 
UNION ALL 
SELECT 14157, 'The subscription created by Subscriber %s to publication %s has expired...' 
UNION ALL 
SELECT 14161, 'The threshold [%s:%s] for the publication [%s] has been set.' 
UNION ALL 
SELECT 17173, 'Ignoring trace flag %d specified during startup' 
UNION ALL 
SELECT 17179, 'Could not use Address Windowing Extensions because the lock pages in mem...' 
UNION ALL 
SELECT 17883, 'Process %ld:%ld:%ld (0x%lx) Worker 0x%p appears to be non-yielding on Scheduler...' 
UNION ALL 
SELECT 17884, 'New queries assigned to process on Node %d have not been picked up by a worker...' 
UNION ALL 
SELECT 17887, 'IO Completion Listener (0x%lx) Worker 0x%p appears to be non-yielding...' 
UNION ALL 
SELECT 17888, 'All schedulers on Node %d appear deadlocked due to a large number of...' 
UNION ALL 
SELECT 17890, 'A significant part of sql server process memory has been paged out...' 
UNION ALL 
SELECT 17891, 'Resource Monitor (0x%lx) Worker 0x%p appears to be non-yielding on Node %ld...' 
UNION ALL 
SELECT 20572, 'Subscriber %s subscription to article %s in publication %s has been reinitiali...' 
UNION ALL 
SELECT 20574, 'Subscriber %s subscription to article %s in publication %s failed...' 

SELECT 
'EXEC create_alert_notification @msgid = ' + 
CAST(message_id AS VARCHAR(10)) + 
', @sev = 0' 
FROM sys.messages 
WHERE message_id IN 
( 
SELECT message_id FROM #alerts_to_include 
) 
AND language_id = 1033 

--Query to play with to generate above: 
/* 
SELECT 'SELECT ' + CAST(message_id AS varchar(10)) + 
', ''' + REPLACE(CAST(text AS varchar(90)), '''', '') + '''' + 
CHAR(13) + CHAR(10) + ' UNION ALL' 
FROM sys.messages 
WHERE language_id = 1033 
AND severity < 16 
AND is_event_logged = 1 
ORDER BY severity DESC, message_id 
*/ 