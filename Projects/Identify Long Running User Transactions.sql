 DECLARE	@FilterMinutes		INT
 SET		@FilterMinutes		= 10
 
 SELECT		CAST(@@SERVERNAME AS VarChar(20))[ServerName]
			,DTAT.transaction_id
			,DTAT.[name]
			,DTAT.transaction_begin_time
			,CASE DTAT.transaction_type
				WHEN 1 THEN 'Read/write'
				WHEN 2 THEN 'Read-only'
				WHEN 3 THEN 'System'
				WHEN 4 THEN 'Distributed'
				END AS transaction_type
			,CASE DTAT.transaction_state
				WHEN 0 THEN 'Not fully initialized'
				WHEN 1 THEN 'Initialized, not started'
				WHEN 2 THEN 'Active'
				WHEN 3 THEN 'Ended' -- only applies to read-only transactions
				WHEN 4 THEN 'Commit initiated'-- distributed transactions only
				WHEN 5 THEN 'Prepared, awaiting resolution' 
				WHEN 6 THEN 'Committed'
				WHEN 7 THEN 'Rolling back'
				WHEN 8 THEN 'Rolled back'
				END AS transaction_state
			,CASE DTAT.dtc_state
				WHEN 1 THEN 'Active'
				WHEN 2 THEN 'Prepared'
				WHEN 3 THEN 'Committed'
				WHEN 4 THEN 'Aborted'
				WHEN 5 THEN 'Recovered'
				END AS dtc_state
			,DATEDIFF(SECOND,DTAT.transaction_begin_time,GETDATE())/60.00 [age_minutes]
			,DTAT.name
			,DTST.session_id 
			,DEXS.program_name
			,DEXS.host_name
			,DEXS.login_name
			,DEXS.row_count
			,SPT.text
FROM		sys.dm_tran_active_transactions		DTAT
JOIN		sys.dm_tran_session_transactions	DTST
	ON		DTAT.transaction_id = DTST.transaction_id
	AND		DTST.is_user_transaction = 1
	AND		DTAT.name <> 'worktable'
	AND		DTAT.transaction_begin_time <= dateadd(minute,(@FilterMinutes*-1),Getdate()) 
JOIN		sys.dm_exec_sessions DEXS
	ON		DEXS.session_id = DTST.session_id
JOIN		(
			SELECT		SP.spid
						,st.text
			FROM		master.dbo.sysprocesses SP
			CROSS APPLY	sys.dm_exec_sql_text(SP.sql_handle) as ST
			) SPT
	ON		SPT.spid = DTST.session_id
ORDER BY	DTAT.transaction_begin_time 