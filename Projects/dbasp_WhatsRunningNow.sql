SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
USE DBAADMIN
GO

IF OBJECT_ID('dbo.dbasp_WhatsRunningNow', 'P') IS NOT NULL DROP PROCEDURE dbo.dbasp_WhatsRunningNow
GO

/*

dbasp_WhatsRunningNow

Reports all running requests along with the request's identifying information (SPID, login etc),
	current resource consumption, query batch text, statement text, and XML query plan.

Requires VIEW_SERVER_STATE permission to work.  DB-owner does not have this permission.
	Sysadmin does have this permission. VIEW_SERVER_STATE can be granted as a separate permission to some or all dbo users.

Update 2009-09-21:
	Tweaked the pigging score - cpu*(reads+writes) is now cpu*(reads*10+writes*10+logical_reads)
	Fixed EndPos for cases when it is -1
	Added StatementTextLength

Update 2009-10-15:
	Added DatabaseID, DatabaseName, BlockedBySessionID, BlockingRequestCount, WaitType, and PendingIOCount

Required Input Parameters
	none

Optional Input Parameters
	none

Usage:
 	EXECUTE Util.dbasp_WhatsRunningNow


*/

CREATE PROCEDURE dbo.dbasp_WhatsRunningNow AS

--The Gritty Requests
SELECT
	Sessions.session_id AS SessionID, Requests.request_id AS RequestID,
	Requests.database_id AS DatabaseID, databases.name AS DatabaseName,
	Sessions.login_name AS LoginName, Sessions.host_name AS HostName, Sessions.program_name AS ProgramName,
	Sessions.client_interface_name AS ClientInterfaceName,
	Requests.blocking_session_id AS BlockedBySessionID,
	ISNULL(BlockRequests.BlockingRequestCount,0) AS BlockingRequestCount,
	Requests.wait_type AS WaitType,
	Requests.wait_time AS WaitTime, Requests.cpu_time AS CPUTime, Requests.total_elapsed_time AS ElapsedTime,
	Requests.reads AS Reads, Requests.writes AS Writes, Requests.logical_reads AS LogicalReads,
	dm_os_tasks.PendingIOCount, Requests.row_count AS [RowCount],
	Requests.granted_query_memory*8 AS GrantedQueryMemoryKB,
	CONVERT(BigInt, (Requests.cpu_time+1))*CONVERT(BigInt, (Requests.reads*10+Requests.writes*10+Requests.logical_reads+1)) AS Score,
	Statements.text AS BatchText,
	LEN(Statements.text) AS BatchTextLength,
	Requests.statement_start_offset/2 AS StatementStartPos,
	CASE
		WHEN Requests.statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(MAX),Statements.text))*2
		ELSE Requests.statement_end_offset
	END/2 AS StatementEndPos,
	(CASE
		WHEN Requests.statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(MAX),Statements.text))*2
		ELSE Requests.statement_end_offset
	END - Requests.statement_start_offset)/2 AS StatementTextLength,
	CASE
		WHEN Requests.sql_handle IS NULL THEN ' '
		ELSE
			SubString(
				Statements.text,
				(Requests.statement_start_offset+2)/2,
				(CASE
					WHEN Requests.statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(MAX),Statements.text))*2
					ELSE Requests.statement_end_offset
				END - Requests.statement_start_offset)/2
			)
	END AS StatementText,
	QueryPlans.query_plan AS QueryPlan
FROM
	sys.dm_exec_sessions AS Sessions
	JOIN sys.dm_exec_requests AS Requests ON Sessions.session_id=Requests.session_id
	LEFT OUTER JOIN sys.databases ON Requests.database_id=databases.database_id
	LEFT OUTER JOIN (
		SELECT blocking_session_id, COUNT(*) AS BlockingRequestCount FROM sys.dm_exec_requests GROUP BY blocking_session_id
	) AS BlockRequests ON Requests.session_id=BlockRequests.blocking_session_id
	LEFT OUTER JOIN (
		SELECT request_id, session_id, SUM(pending_io_count) AS PendingIOCount
		FROM sys.dm_os_tasks WITH (NOLOCK)
		GROUP BY request_id, session_id
	) AS dm_os_tasks ON
		Requests.request_id=dm_os_tasks.request_id
		AND Requests.session_id=dm_os_tasks.session_id
	CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS Statements
	CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS QueryPlans
ORDER BY score DESC
GO

--*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

