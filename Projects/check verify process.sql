--sp_who2

--DBCC xp_sqlbackup (FREE);

--master.dbo.sqbstatus 1

SELECT  TOP 1
	[cECategory]
	,[cEEvent]
	,[cEMessage]
	,[cEStat_Duration]
	,COALESCE((
	select	percent_complete
	FROM	sys.dm_exec_requests r
	WHERE	command = 'RESTORE VERIFYON'
	),100) [PercentDone]
FROM	[dbaadmin].[dbo].[EventLog]
WHERE	[cEModule] = 'dbasp_Backup_Verify'  
ORDER BY [EventLogID] DESC

--select		percent_complete
--FROM		sys.dm_exec_requests r
--WHERE		command = 'RESTORE VERIFYON'
 
--CROSS APPLY	sys.dm_exec_sql_text(r.sql_handle) AS t

SELECT [EventLogID]
      ,[EventDate]
      ,[cEModule]
      ,[cECategory]
      ,[cEEvent]
      ,[cEGUID]
      ,[cEMessage]
      ,[cEStat_Rows]
      ,[cEStat_Duration]
  FROM [dbaadmin].[dbo].[EventLog]
GO

SELECT	DISTINCT
	[cEEvent]
  FROM [dbaadmin].[dbo].[EventLog]
WHERE	[cEModule] = 'dbasp_Backup_Verify'
  AND	[cEMessage] IN ('Valid','Invalid','File Not Found')
GO


-- DELETE [dbaadmin].[dbo].[EventLog] WHERE EventDate > '2012-09-05'

SELECT dbaadmin.dbo.dbaudf_CheckFileStatus('G:\Backup\pre_calc\GETTY_MASTER_db_20120807171145.SQB')
exec dbo.dbasp_UnlockAndDelete 'G:\Backup\pre_calc\GETTY_MASTER_db_20120807171145.SQB',1,0,0