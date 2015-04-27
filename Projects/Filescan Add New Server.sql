INSERT INTO [dbaadmin].[dbo].[Filescan_MachineSource]
           ([Machine]
           ,[Instance]
           ,[SourceType]
           ,[LastReported]
           ,[SessionAdded]
           ,[SessionUpdated])
     VALUES
           ('SEAINTRASQL01'
           ,''
           ,'SQL_ERRORLOG'
           ,GetDate() - 30
           ,NewID()
           ,NewID())
GO


