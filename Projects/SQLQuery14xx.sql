--DROP TABLE #DriveList
--GO
--CREATE TABLE #DriveList ([Drive] CHAR(1),[MBFree] Float)
--INSERT INTO #DriveList
--exec xp_fixeddrives

--SELECT		DISTINCT
--			upper(db_name(T1.dbid)) [DatabaseName]
--			,upper(left(T1.filename,1)) [Drive]
--			,(SELECT [MBFree]/1024.0 FROM #DriveList WHERE [Drive] = left(T1.filename,1)) [GBFreeSpace]
--FROM		sysaltfiles T1
--WHERE		db_name(T1.dbid) != 'TempDB'
--	AND		left(T1.filename,1) IN (SELECT left(filename,1) From sysaltfiles WHERE db_name(dbid) = 'TempDB')




IF LEFT(CAST(convert(sysname, serverproperty('ProductVersion')) AS VarChar(255)),1) != '8'
BEGIN

	--SELECT
	--user_object_perc = CONVERT(DECIMAL(6,3), u*100.0/(u+i+v+f)),
	--internal_object_perc = CONVERT(DECIMAL(6,3), i*100.0/(u+i+v+f)),
	--version_store_perc = CONVERT(DECIMAL(6,3), v*100.0/(u+i+v+f)),
	--free_space_perc = CONVERT(DECIMAL(6,3), f*100.0/(u+i+v+f)),
	--[total] = (u+i+v+f)
	--FROM (
	--SELECT
	--u = SUM(user_object_reserved_page_count)*8,
	--i = SUM(internal_object_reserved_page_count)*8,
	--v = SUM(version_store_reserved_page_count)*8,
	--f = SUM(unallocated_extent_page_count)*8
	--FROM
	--sys.dm_db_file_space_usage
	--) x;

	--SELECT top 5 * 
	--FROM sys.dm_db_session_space_usage  
	--ORDER BY (user_objects_alloc_page_count +
	-- internal_objects_alloc_page_count) DESC

	--SELECT top 5 * 
	--FROM sys.dm_db_task_space_usage
	--ORDER BY (user_objects_alloc_page_count +
	-- internal_objects_alloc_page_count) DESC


	--SELECT t1.session_id, t1.request_id, t1.task_alloc,
	--  t1.task_dealloc, t2.sql_handle, t2.statement_start_offset, 
	--  t2.statement_end_offset, t2.plan_handle
	--FROM (Select session_id, request_id,
	--	SUM(internal_objects_alloc_page_count) AS task_alloc,
	--	SUM (internal_objects_dealloc_page_count) AS task_dealloc 
	--  FROM sys.dm_db_task_space_usage 
	--  GROUP BY session_id, request_id) AS t1, 
	--  sys.dm_exec_requests AS t2
	--WHERE t1.session_id = t2.session_id
	--  AND (t1.request_id = t2.request_id)
	--ORDER BY t1.task_alloc DESC

	--SELECT top 5 transaction_id, transaction_sequence_num, 
	--elapsed_time_seconds 
	--FROM sys.dm_tran_active_snapshot_database_transactions
	--ORDER BY elapsed_time_seconds DESC

--SELECT		top 5 DATEDIFF(hour,transaction_begin_time,GETDATE()), *
--FROM		sys.dm_tran_active_transactions
--ORDER BY	transaction_begin_time

SELECT  DTAT.transaction_id ,
        DTAT.[name] ,
        DTAT.transaction_begin_time ,
        CASE DTAT.transaction_type

          WHEN 1 THEN 'Read/write'
          WHEN 2 THEN 'Read-only'
          WHEN 3 THEN 'System'
          WHEN 4 THEN 'Distributed'
        END AS transaction_type ,
        CASE DTAT.transaction_state

          WHEN 0 THEN 'Not fully initialized'
          WHEN 1 THEN 'Initialized, not started'
          WHEN 2 THEN 'Active'
          WHEN 3 THEN 'Ended' -- only applies to read-only transactions
          WHEN 4 THEN 'Commit initiated'-- distributed transactions only
          WHEN 5 THEN 'Prepared, awaiting resolution' 
          WHEN 6 THEN 'Committed'
          WHEN 7 THEN 'Rolling back'
          WHEN 8 THEN 'Rolled back'
        END AS transaction_state ,
        CASE DTAT.dtc_state

          WHEN 1 THEN 'Active'
          WHEN 2 THEN 'Prepared'
          WHEN 3 THEN 'Committed'
          WHEN 4 THEN 'Aborted'
          WHEN 5 THEN 'Recovered'
        END AS dtc_state

		,DATEDIFF(SECOND,DTAT.transaction_begin_time,GETDATE())/60.00 [age_minutes]
		,DTAT.name
		
FROM    sys.dm_tran_active_transactions DTAT

        INNER JOIN sys.dm_tran_session_transactions DTST
                         ON DTAT.transaction_id = DTST.transaction_id

WHERE   [DTST].[is_user_transaction] = 1

ORDER BY DTAT.transaction_begin_time 




--SELECT  DTL.[request_session_id] AS [session_id] ,
--        DB_NAME(DTL.[resource_database_id]) AS [Database] ,
--        DTL.resource_type ,
--        CASE WHEN DTL.resource_type IN ( 'DATABASE', 'FILE', 'METADATA' )
--             THEN DTL.resource_type

--             WHEN DTL.resource_type = 'OBJECT'
--             THEN OBJECT_NAME(DTL.resource_associated_entity_id,
--                              DTL.[resource_database_id])
--             WHEN DTL.resource_type IN ( 'KEY', 'PAGE', 'RID' )
--             THEN ( SELECT  OBJECT_NAME([object_id])
--                    FROM    sys.partitions
--                    WHERE   sys.partitions.hobt_id = 
--                                            DTL.resource_associated_entity_id

--                  )
--             ELSE 'Unidentified'
--        END AS [Parent Object] ,
--        DTL.request_mode AS [Lock Type] ,
--        DTL.request_status AS [Request Status] ,
--        DER.[blocking_session_id] ,
--        DES.[login_name] ,
--        CASE DTL.request_lifetime

--          WHEN 0 THEN DEST_R.TEXT
--          ELSE DEST_C.TEXT
--        END AS [Statement]

--FROM    sys.dm_tran_locks DTL

--        LEFT JOIN sys.[dm_exec_requests] DER
--                   ON DTL.[request_session_id] = DER.[session_id]

--        INNER JOIN sys.dm_exec_sessions DES
--                   ON DTL.request_session_id = DES.[session_id]

--        INNER JOIN sys.dm_exec_connections DEC
--                   ON DTL.[request_session_id] = DEC.[most_recent_session_id]

--        OUTER APPLY sys.dm_exec_sql_text(DEC.[most_recent_sql_handle])
--                                                         AS DEST_C

--        OUTER APPLY sys.dm_exec_sql_text(DER.sql_handle) AS DEST_R

--WHERE   DTL.[resource_database_id] = DB_ID()
--        AND DTL.[resource_type] NOT IN ( 'DATABASE', 'METADATA' )
--ORDER BY DTL.[request_session_id] ;










END