exec	dbaadmin.dbo.dbasp_ShrinkAllLargeFiles @DBNameFilter = 'gins_work_a',
			@FileTypes = 'LOG'
			,@DoItNow = 1


USE [gins_work_a]
GO
DBCC SHRINKFILE (N'gins_work_a_log' , 0)
GO


ALTER DATABASE [gins_work_a]
MODIFY FILE (NAME=gins_work_a_log,SIZE=8000MB,MAXSIZE=UNLIMITED,FILEGROWTH=1000MB);


sp_whoisactive @get_transaction_info=1


SELECT * FROM sys.dm_exec_requests
SELECT * FROM sys.dm_os_waiting_tasks
SELECT * FROM sys.dm_tran_active_transactions


SELECT * FROM sys.dm_tran_locks where resource_database_id = db_id()
SELECT * FROM sys.dm_tran_database_transactions WHERE database_id = db_id()


DBCC LOGINFO



SELECT des.*
FROM sys.dm_exec_sessions des
INNER JOIN sys.dm_tran_session_transactions dtst ON des.session_id = dtst.session_id
LEFT JOIN sys.dm_exec_requests der ON dtst.session_id = der.session_id
WHERE der.session_id IS NULL
ORDER BY des.session_id

