USE [dbacentral]
GO
CREATE PROCEDURE	dbo.dbasp_FileScan_UpdateAggSessionResults
			(
			@SessionID UniqueIdentifier
			,@StatusMsg nVarChar(MAX)
			)
AS
PRINT	@StatusMsg
PRINT	''
IF NOT EXISTS (SELECT 1 FROM [dbacentral].[dbo].[Filescan_AggSession] WHERE [SessionID]=@SessionID)
INSERT INTO [dbacentral].[dbo].[Filescan_AggSession]
           ([SessionID]
           ,[RunDate]
           ,[SessionResults])
     VALUES
           (@SessionID
           ,GetDate()
           ,@StatusMsg)
ELSE 
UPDATE	[dbacentral].[dbo].[Filescan_AggSession]
	SET	[SessionResults]	=[SessionResults]
					+ Cast(GetDate()AS VarChar(50)) 
					+ ' - ' 
					+ COALESCE(@StatusMsg,'')
					+ CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
WHERE	[SessionID]=@SessionID
GO