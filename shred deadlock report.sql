-- REFERENCES:
-- see http://msdn.microsoft.com/en-us/library/ms188246.aspx
-- (MS BOL Analyzing Deadlocks with SQL Server Profiler)
-- see http://msdn.microsoft.com/en-us/library/ms175519.aspx
-- (MS BOL Lock Modes)
-- http://blogs.msdn.com/bartd/archive/2006/09/09/Deadlock-Troubleshooting_2C00_-Part-1.aspx
-- http://blogs.msdn.com/b/bartd/archive/2008/09/24/today-s-annoyingly-unwieldy-term-intra-query-parallel-thread-deadlocks.aspx
-- Shred XML Deadlock Graphs, showing in tabular format as much information as possible.
-- Insert the XML Deadlock Graph into the @deadlock table.
-- Author: Wayne Sheffield
-- Modification History:
-- Version - Date       - Description
-- 2         2010-10-10 - Added individual items in the Execution Stack node.
--                      - Converted from using an XML variable to a table variable with an XML variable
--                      -   to allow seeing multiple deadlocks simultaneously.
-- 3         2010-10-11 - Added KPID to Process CTE and final results.
--                      - Expanded LockMode to varchar(10).
-- 4         2011-05-11 - Added Waits.
-- 5         2011-05-15 - Revamped to minimize calls to the root of the deadlock xml nodes.
--                        Modified InputBuffer to be XML.
--                        Modified Execution Stack to return XML (vs. one row for each item, which
--                          was causing duplication of other data).
-- 6         2012-02-01 - Add loading deadlock info from fn_trace_gettable.
--                      - Get the InputBuffer from .query vs. trying to build XML.
--                      - Add number of processes involved in the deadlock.
--                      - Add the Query Statement being run.
-- 7         2012-09-01 - Corrected typo in ObjNode in both the Locks and Waits CTEs.
--                      - Added DENSE_RANK for each process.
--                      - Added support for exchangeEvent, threadpool, resourceWait events.
--                      -   (threadpool and resourceWait events are not tested - need to find a deadlock with them to test)
--                      - Simplified xpath queries
-- 8         2012-09-04 - Greatly simplified locks and waits CTEs based on feedback from Mark Cowne.
--                      - Added database_id and AssociatedObjectId per feedback from Gianluca Sartori.
--                      - Combined the Locks and Waits CTEs into one.
-- 9         2012-10-26 - Handle deadlock graphs from the system_health xe (has a victim-list node for multi-victim deadlocks).
-- 10        2013-07-29 - Added ability to load in a deadlock file (.xdl).
--                      - Added QueryStatement to output.
--                      - Switched from clause order from "Locks JOIN Process" to "Process LEFT JOIN Locks"
-- 11        2013-12-26 - Read in deadlocks from the system_health XE file target
-- 12        2014-05-06 - Read in deadlocks from the system_health XE ring buffer
-- 13        2014-07/01 - Read in deadlocks from SQL Sentry
 
DECLARE	@deadlock	TABLE	(
				DeadlockID		INT IDENTITY PRIMARY KEY CLUSTERED
				,DeadlockGraph		XML
				,DeadlockDateTime	DateTime
				);


-- Read in the deadlock from the system_health XE ring buffer
INSERT INTO	@deadlock(DeadlockGraph,DeadlockDateTime)
SELECT		CONVERT(XML, XEventData.XEvent.value('(data/value)[1]', 'varchar(max)'))	[DeadlockGraph]
		,XEventData.XEvent.value('@timestamp', 'datetime')				[DeadlockDateTime]
FROM		(
		SELECT		CAST(target_data AS XML)			[TargetData]
		FROM		sys.dm_xe_session_targets st WITH (NOLOCK)
		JOIN		sys.dm_xe_sessions s WITH (NOLOCK)
			ON	s.address = st.event_session_address
		WHERE		[name] = 'system_health'
		)[Data]
CROSS APPLY	TargetData.nodes('//RingBufferTarget/event')			[XEventData](XEvent)
WHERE		XEventData.XEvent.value('@name', 'varchar(4000)') = 'xml_deadlock_report'
ORDER BY	2 desc
;


-- use below to load a deadlock trace file
/*
DECLARE @file VARCHAR(500);
SELECT  @file = REVERSE(SUBSTRING(REVERSE([PATH]), CHARINDEX('\', REVERSE([path])), 260)) + N'LOG.trc'
FROM    sys.traces 
WHERE   is_default = 1; -- get the system default trace, use different # for other active traces.
 
-- or just SET @file = 'your trace file to load';
 
INSERT  INTO @deadlock (DeadlockGraph)
SELECT  TextData
FROM    ::FN_TRACE_GETTABLE(@file, DEFAULT)
WHERE   TextData LIKE '<deadlock-list>%';
*/
 
-- or read in a deadlock file - doesn't have to have a "xdl" extension.
/*INSERT INTO @deadlock (DeadlockGraph)
SELECT *
FROM OPENROWSET(BULK 'I:\Ntirety\Alaska National Insurance Company\T20130724.0122.xdl', SINGLE_BLOB) UselessAlias;
*/
 
 
-- or read in the deadlock from the system_health XE file target
/*
WITH cte1 AS
(
SELECT    target_data = convert(XML, target_data)
FROM    sys.dm_xe_session_targets t
        JOIN sys.dm_xe_sessions s 
          ON t.event_session_address = s.address
WHERE    t.target_name = 'event_file'
AND        s.name = 'system_health'
), cte2 AS
(
SELECT    [FileName] = FileEvent.FileTarget.value('@name', 'varchar(1000)')
FROM    cte1
        CROSS APPLY cte1.target_data.nodes('//EventFileTarget/File') FileEvent(FileTarget)
), cte3 AS
(
SELECT    event_data = CONVERT(XML, t2.event_data)
FROM    cte2
        CROSS APPLY sys.fn_xe_file_target_read_file(cte2.[FileName], NULL, NULL, NULL) t2
WHERE    t2.object_name = 'xml_deadlock_report'
)
INSERT INTO @deadlock(DeadlockGraph)
SELECT  Deadlock = Deadlock.Report.query('.')
FROM    cte3    
        CROSS APPLY cte3.event_data.nodes('//event/data/value/deadlock') Deadlock(Report);
*/
 

 
;WITH		CTE 
		AS 
		(
		SELECT		DeadlockID
				,DeadlockGraph
				,DeadlockDateTime
		FROM		@deadlock
		)
		,Victims 
		AS 
		(
		SELECT		DISTINCT
				Victims.List.value('@id', 'varchar(50)')	[ID]
		FROM		CTE
		CROSS APPLY	CTE.DeadlockGraph.nodes('//deadlock/victim-list/victimProcess') AS Victims(List)
		)
		,Locks 
		AS 
		(
		-- Merge all of the lock information together.
		SELECT		DISTINCT
				CTE.DeadlockID
				,REPLACE(MainLock.Process.value('local-name(.)', 'varchar(100)'), 'lock', '')	[LockEvent]

				,MainLock.Process.value('@hobtid', 'BIGINT')					[Lock_hobtid]
				,MainLock.Process.value('@dbid', 'INTEGER')					[Lock_dbid]
				,MainLock.Process.value('@objectname', 'sysname')				[Lock_ObjectName]
				,MainLock.Process.value('@indexname', 'sysname')				[Lock_IndexName]
				,MainLock.Process.value('@id', 'varchar(100)')					[Lock_id]
				,MainLock.Process.value('@mode', 'varchar(10)')					[Lock_mode]
				,MainLock.Process.value('@associatedObjectId', 'BIGINT')			[Lock_associatedObjectId]
				,MainLock.Process.value('@WaitType', 'varchar(100)')				[Lock_WaitType]

				,OwnerList.Owner.value('@id', 'varchar(200)')					[Owner_id]
				,OwnerList.Owner.value('@mode', 'varchar(10)')					[Owner_mode]

				,WaiterList.Waiter.value('@id', 'varchar(200)')					[Waiter_id]
				,WaiterList.Waiter.value('@mode', 'varchar(10)')				[Waiter_mode]
				,WaiterList.Waiter.value('@requestType', 'varchar(20)')				[Waiter_requestType]
		FROM		CTE
		CROSS APPLY	CTE.DeadlockGraph.nodes('//deadlock/resource-list')	AS Lock(list)
		CROSS APPLY	Lock.list.nodes('*')					AS MainLock(Process)
		OUTER APPLY	MainLock.Process.nodes('owner-list/owner')		AS OwnerList(Owner)
		CROSS APPLY	MainLock.Process.nodes('waiter-list/waiter')		AS WaiterList(Waiter)
		)
		,Process
		AS 
		(
		-- get the data from the process node
		SELECT		DISTINCT
				CTE.DeadlockID
				,DeadlockDateTime
				,CONVERT(BIT, CASE	WHEN Deadlock.Process.value('@id', 'varchar(50)') = ISNULL(Deadlock.Process.value('../../@victim', 'varchar(50)'), v.ID) 
							THEN 1
							ELSE 0
							END)					[Victim]
				--,Process.ID							[ProcessID]		
				,Deadlock.Process.value('@id', 'varchar(50)')			[Process_id]		-- Deadlock.Process.value('@id', 'varchar(50)')
				,Deadlock.Process.value('@taskpriority', 'int')			[TaskPriority]
				,Deadlock.Process.value('@logused', 'int')			[LogUsed]
				,Deadlock.Process.value('@waitresource', 'varchar(200)')	[WaitResource]
				,Deadlock.Process.value('@waittime', 'INT')			[WaitTime]
				,Deadlock.Process.value('@ownerId', 'INT')			[OwnerId]
				,Deadlock.Process.value('@transactionname', 'varchar(100)')	[TransactionName]
				,Deadlock.Process.value('@lasttranstarted', 'datetime')		[TransactionTime]
				,Deadlock.Process.value('@XDES', 'varChar(50)')			[XDES]
				,Deadlock.Process.value('@lockMode', 'varChar(50)')		[LockMode]		-- how is this different from in the resource-list section?
				,Deadlock.Process.value('@schedulerid', 'INT')			[SchedulerID]
				,Deadlock.Process.value('@kpid', 'int')				[KPID]			-- kernel-process id / thread ID number
				,Deadlock.Process.value('@status', 'varchar(100)')		[Status]
				,Deadlock.Process.value('@spid', 'int')				[SPID]			-- system process id (connection to sql)
				,Deadlock.Process.value('@sbid', 'int')				[SBID]			-- system batch id / request_id (a query that a SPID is running)
				,Deadlock.Process.value('@ecid', 'int')				[ECID]			-- execution context ID (a worker thread running part of a query)
				,Deadlock.Process.value('@priority', 'INT')			[Priority]
				,Deadlock.Process.value('@trancount', 'INT')			[TransactionCount]
				,Deadlock.Process.value('@lastbatchstarted', 'datetime')	[BatchStarted]
				,Deadlock.Process.value('@lastbatchcompleted', 'datetime')	[BatchCompleted]
				,Deadlock.Process.value('@lastattention', 'datetime')		[LastAttention]
				,Deadlock.Process.value('@clientapp', 'varchar(100)')		[ClientApp]
				,Deadlock.Process.value('@hostname', 'varchar(20)')		[HostName]
				,Deadlock.Process.value('@hostpid', 'int')			[HostPID]
				,Deadlock.Process.value('@loginname', 'varchar(20)')		[LoginName]
				,Deadlock.Process.value('@isolationlevel', 'varchar(200)')	[IsolationLevel]
				
				,Deadlock.Process.value('@xactid', 'INT')			[xactid]
				,Deadlock.Process.value('@currentdb', 'INT')			[CurrentDB]
				,Deadlock.Process.value('@lockTimeout', 'BIGINT')		[LockTimeout]
				,Deadlock.Process.value('@clientoption1', 'varchar(100)')	[ClientOption1]
				,Deadlock.Process.value('@clientoption2', 'varchar(100)')	[ClientOption2]
					
				,Execution.Frame.value('@procname', 'SYSNAME')			[Frame_ProcName]
				,Execution.Frame.value('@line', 'INT')				[Frame_Line]
				,Execution.Frame.value('@stmtstart', 'INT')			[Frame_StatementStart]
				,Execution.Frame.value('@stmtend', 'INT')			[Frame_StatementEnd]
				,Execution.Frame.value('@sqlhandle', 'varchar(100)')		[Frame_SQLHandle]
				
				,Input.Buffer.value('.', 'varchar(max)')			[InputBuffer]

				,SUM(1) OVER (PARTITION BY CTE.DeadlockID)			[ProcessQty]
		FROM		CTE
		CROSS APPLY	CTE.DeadlockGraph.nodes('//deadlock/process-list/process')	AS Deadlock(Process)
		CROSS APPLY	(SELECT Deadlock.Process.value('@id', 'varchar(50)'))		AS Process(ID)
		LEFT JOIN	Victims								AS v 
			ON	Process.ID = v.ID
		CROSS APPLY	Deadlock.Process.nodes('inputbuf')				AS Input(Buffer)
		CROSS APPLY	Deadlock.Process.nodes('executionStack/frame')			AS Execution(Frame)
		)
		, ReportData
		AS
		(
		SELECT		DISTINCT
				p.DeadlockID
				,p.DeadlockDateTime
				,DATEDIFF(minute,p.DeadlockDateTime,GetutcDate())			[MinAgo]
				,DENSE_RANK() OVER (PARTITION BY p.DeadlockId ORDER BY p.Process_id)	[ProcessNbr]	
				,p.Victim	
				,p.Process_id	
				,p.TaskPriority	
				,p.LogUsed
				,p.WaitResource	
				,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(p.WaitResource,':','|'),'(','|'),1) [WaitResource_Type]
				,CAST(dbaadmin.dbo.dbaudf_execute_tsql('SELECT OBJECT_SCHEMA_NAME(object_id,'+dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(p.WaitResource,':','|'),'(','|'),2)+')+''.''+OBJECT_NAME(object_id,'+dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(p.WaitResource,':','|'),'(','|'),2)+') [WaitResourceName] FROM ['+DB_NAME(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(p.WaitResource,':','|'),'(','|'),2))+'].sys.partitions WHERE hobt_id = '+dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(p.WaitResource,':','|'),'(','|'),3)) AS XML).value('(/Results/@WaitResourceName)[1]', 'varchar(100)') [WaitResource_Name]
				,p.WaitTime	
				,p.OwnerId	
				,p.TransactionName	
				,p.TransactionTime	
				,p.XDES	
				,p.LockMode	
				,p.SchedulerID	
				,p.KPID	
				,p.Status	
				,p.SPID	
				,p.SBID	
				,p.ECID	
				,p.Priority	
				,p.TransactionCount	
				,p.BatchStarted	
				,p.BatchCompleted	
				,p.LastAttention	
				,p.ClientApp	
				,p.HostName	
				,p.HostPID	
				,p.LoginName	
				,p.IsolationLevel	
				,p.xactid	
				,p.CurrentDB	
				,p.LockTimeout	
				,p.ClientOption1	
				,p.ClientOption2	
				,p.Frame_ProcName	
				,p.Frame_Line	
				,p.Frame_StatementStart	
				,p.Frame_StatementEnd	
				,p.Frame_SQLHandle	
				,p.InputBuffer	
				,CASE	WHEN RIGHT(LTRIM(RTRIM(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(p.InputBuffer,'[','|'),']','|'),'Database Id =','|'),'Object Id =','|'),1))),4) = 'Proc'
					THEN 
					    OBJECT_SCHEMA_NAME	(
							LTRIM(RTRIM(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(p.InputBuffer,'[','|'),']','|'),'Database Id =','|'),'Object Id =','|'),4)))
							,LTRIM(RTRIM(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(p.InputBuffer,'[','|'),']','|'),'Database Id =','|'),'Object Id =','|'),3)))
							) 
						+'.'+
					    OBJECT_NAME	(
							LTRIM(RTRIM(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(p.InputBuffer,'[','|'),']','|'),'Database Id =','|'),'Object Id =','|'),4)))
							,LTRIM(RTRIM(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(p.InputBuffer,'[','|'),']','|'),'Database Id =','|'),'Object Id =','|'),3)))
							)
					ELSE 'N/A' END [InputBuffer_Name]
				,p.ProcessQty	
				,l.LockEvent	
				,l.Lock_hobtid
		
				,CASE WHEN l.DeadlockID IS NOT NULL
					THEN CAST(dbaadmin.dbo.dbaudf_execute_tsql('SELECT OBJECT_SCHEMA_NAME(object_id,'+CAST(l.Lock_dbid AS VarChar(50))+')+''.''+OBJECT_NAME(object_id,'+CAST(l.Lock_dbid AS VarChar(50))+') [WaitResourceName] FROM ['+DB_NAME(l.Lock_dbid)+'].sys.partitions WHERE hobt_id = '+ CAST(l.Lock_hobtid AS VarChar(50))) AS XML).value('(/Results/@WaitResourceName)[1]', 'varchar(100)') 
					END [Lock_hobtid_Name]
			
				,l.Lock_dbid	
				,l.Lock_ObjectName	
				,l.Lock_IndexName	
				,l.Lock_id	
				,l.Lock_mode	
				,l.Lock_associatedObjectId	
				,l.Lock_WaitType	
				,l.Owner_id	
				,l.Owner_mode	
				,l.Waiter_id	
				,l.Waiter_mode	
				,l.Waiter_requestType

		FROM		Process p
		LEFT JOIN	Locks l
			ON	p.DeadlockID = l.DeadlockID
			AND	p.Process_id = l.Owner_id

		)

SELECT		*
		,(Select [DeadlockGraph] FROM CTE WHERE DeadlockID = rd.DeadlockID) [DeadlockGraph]
FROM		ReportData rd
ORDER BY	DeadlockId
		,Victim DESC
		,Process_id