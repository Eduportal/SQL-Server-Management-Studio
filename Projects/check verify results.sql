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


-- DELETE [dbaadmin].[dbo].[EventLog] WHERE EventDate > '2012-08-29'

SELECT dbaadmin.dbo.dbaudf_CheckFileStatus('G:\Backup\pre_calc\GETTY_MASTER_db_20120807171145.SQB')
exec dbo.dbasp_UnlockAndDelete 'G:\Backup\pre_calc\GETTY_MASTER_db_20120807171145.SQB',1,0,0