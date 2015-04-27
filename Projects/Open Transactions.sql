


DECLARE @Results TABLE (ActiveTran sysname, TranDetails VarChar(max))

INSERT INTO @Results
exec ('DBCC OPENTRAN (''tempdb'') with tableresults, NO_INFOMSGS')


SELECT * From @Results



SELECT dd.transaction_id,
       ds.session_id,
       database_transaction_begin_time,
       CASE database_transaction_type
         WHEN 1 THEN 'Read/write transaction'
         WHEN 2 THEN 'Read-only transaction'
         WHEN 3 THEN 'System transaction'
       END database_transaction_type,
       CASE database_transaction_state
         WHEN 1 THEN 'The transaction has not been initialized.'
         WHEN 3 THEN 'The transaction has been initialized but has not generated any log records.'
         WHEN 4 THEN 'The transaction has generated log records.'
         WHEN 5 THEN 'The transaction has been prepared.'
         WHEN 10 THEN 'The transaction has been committed.'
         WHEN 11 THEN 'The transaction has been rolled back.'
         WHEN 12 THEN 'The transaction is being committed. In this state the log record is being generated, but it has not been materialized or persisted'
       END database_transaction_state,
       database_transaction_log_bytes_used,
       database_transaction_log_bytes_reserved,
       database_transaction_begin_lsn,
       database_transaction_last_lsn,
       host_name,
       program_name, 
       original_login_name,
       st.text
             
FROM	sys.dm_tran_database_transactions dd

JOIN	sys.dm_tran_session_transactions ds
	ON	ds.transaction_id = dd.transaction_id
           
JOIN	sys.dm_exec_connections ec           
	ON	ec.session_id = ds.session_id

JOIN	sys.dm_exec_sessions es
	ON	es.session_id = ec.session_id           
           
           
CROSS APPLY sys.dm_exec_sql_text(ec.most_recent_sql_handle) st


WHERE  dd.database_id = DB_ID('TempDB')








SELECT ec.session_id,host_name,program_name, original_login_name, st.text
   FROM sys.dm_exec_sessions es
      JOIN sys.dm_exec_connections ec
          ON es.session_id = ec.session_id
      CROSS APPLY sys.dm_exec_sql_text(ec.most_recent_sql_handle) st
  WHERE ec.session_id  IN (SELECT TranDetails From @Results WHERE ActiveTran like '%SPID%')
  
  
  
  
  

