
USE DEPLcontrol;

--DROP TABLE [DEPLcontrol].[dbo].[DBA_Dashboard_GearsRunningTicketStatus]

--IF OBJECT_ID('[DEPLcontrol].[dbo].[DBA_Dashboard_GearsRunningTicketStatus]') IS NULL
--BEGIN
--	CREATE TABLE [DEPLcontrol].[dbo].[DBA_Dashboard_GearsRunningTicketStatus]
--			(
--			[GRTStatusID] INT IDENTITY(1,1)
--			,[TicketID] INT
--			,[Complete] bit
--			,[Link] VarChar(4000)
--			,[Code] VarChar(50)
--			,[StatusDate] DateTime
--			,[StatusMessage] VarChar(MAX)
--			)
--END

--IF OBJECT_ID('[DEPLcontrol].[dbo].[GRiTS_DataChanged]') IS NULL
--BEGIN			
--	exec sp_executesql N'CREATE TRIGGER GRiTS_DataChanged ON [dbo].[DBA_Dashboard_GearsRunningTicketStatus] 
--	FOR INSERT, UPDATE, DELETE
--	AS EXEC dbaadmin.dbo.dbasp_FileAccess_Write '''',''c:\windows'',''GRiTS.DataChanged'''
--END


GO
ALTER PROCEDURE DBA_Dashboard_GearsRunningTicketStatus_Updater
	(
	@TicketID	INT
	,@Verbose	BIT = 0
	,@Tweet		BIT = 0
	)
AS
BEGIN	
	SET NOCOUNT ON
	DECLARE @cEGUID		uniqueidentifier
		,@cEModule	sysname
		,@cECategory	sysname
		,@cEEvent	sysname
		,@TicketDetails	VarChar(MAX)
		,@FlipFlop	INT
		,@LastReported	datetime
		
	SET	@FlipFlop	= 1
	SET	@cEGUID		= NEWID()
	SET	@cEModule	= 'GearsTicket:' + CAST(@TicketID AS VarChar(50))

	DECLARE @Status1 TABLE 
		(
		[CheckSumValue] [int] NULL,
		[APPL] [sysname] NOT NULL,
		[DB] [sysname] NOT NULL,
		[Process] [sysname] NOT NULL,
		[Type] [sysname] NOT NULL,
		[Detail] [sysname] NOT NULL,
		[Status] [sysname] NOT NULL,
		[SQL] [sysname] NOT NULL,
		[Domain] [sysname] NOT NULL,
		[Base] [sysname] NOT NULL,
		[Go] [varchar](128) NULL,
		[RecordOrder] [int] NULL,
		[seq_id] [int] NULL,
		[reqdet_id] [int] NULL
		)

	DECLARE @Status2 TABLE 
		(
		[CheckSumValue] [int] NULL,
		[APPL] [sysname] NOT NULL,
		[DB] [sysname] NOT NULL,
		[Process] [sysname] NOT NULL,
		[Type] [sysname] NOT NULL,
		[Detail] [sysname] NOT NULL,
		[Status] [sysname] NOT NULL,
		[SQL] [sysname] NOT NULL,
		[Domain] [sysname] NOT NULL,
		[Base] [sysname] NOT NULL,
		[Go] [varchar](128) NULL,
		[RecordOrder] [int] NULL,
		[seq_id] [int] NULL,
		[reqdet_id] [int] NULL
		)

	DECLARE @StatusComment VarChar(MAX)
	DECLARE @StatusCode VarChar(50)
	DECLARE @StatusLink VarChar(2048)

	BEGIN
		DELETE [DEPLcontrol].[dbo].[DBA_Dashboard_GearsRunningTicketStatus] WHERE [TicketID] = @TicketID --AND [StatusMessage] = 'Monitoring...'

		SET	@cECategory	= 'MONITOR DEPLOY'
		SET	@cEEvent	= 'START'
		SET	@StatusComment  = 'Starting Monitoring of Ticket'
			
		exec dbaadmin.dbo.[dbasp_LogEvent]
				 @cEModule   
				,@cECategory 
				,@cEEvent
				,@cEGUID		= @cEGUID
				,@cEMessage		= @StatusComment
				,@cEMethod_Twitter	= @Tweet
				,@cERE_ForceScreen	= 1
				,@cEMethod_TableLocal	= 1
				
		SET	@LastReported = getdate()
		
		IF @Verbose = 1
		BEGIN
			SELECT	@TicketDetails = replicate('-',80)+CHAR(13)+CHAR(10)
				+'TICKET DETAILS'+CHAR(13)+CHAR(10)
				+replicate('-',80)+CHAR(13)+CHAR(10)
				+' Ticket      # ' + CAST([Gears_id] AS VarChar(50))+CHAR(13)+CHAR(10)
				+' Project     : ' + [ProjectName]+' ('+[ProjectNum]+')'+CHAR(13)+CHAR(10)
				+' Environment : ' + [Environment]+CHAR(13)+CHAR(10)
				+' Request Date: ' + CAST([RequestDate] AS VarChar(50))+CHAR(13)+CHAR(10)
				+' Start Date  : ' + CONVERT(VarChar(12),[StartDate],101)+CHAR(13)+CHAR(10)
				+' Start Time  : ' + [StartTime]+CHAR(13)+CHAR(10)
				+replicate('-',80)+CHAR(13)+CHAR(10)
				+'NOTES'+CHAR(13)+CHAR(10)
				+replicate('-',80)+CHAR(13)+CHAR(10)
				+COALESCE(' ' + [Notes],'')+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
				,@StatusComment = [ProjectName]+' ('+[ProjectNum]+') IN '+ [Environment]
			FROM [DEPLcontrol].[dbo].[Request]
			WHERE [Gears_id] = @TicketID
			
	
			SET	@cECategory = 'INFO'
			SET	@cEEvent    = 'TICKET DETAILS'

			exec dbaadmin.dbo.[dbasp_LogEvent]
				 @cEModule   
				,@cECategory 
				,@cEEvent
				,@cEGUID		= @cEGUID
				,@cEMessage		= @TicketDetails
				,@cEMethod_Twitter	= @Tweet
				,@cERE_ForceScreen	= 1
				,@cEMethod_TableLocal	= 1
				
			SET	@LastReported = getdate()
				
		END
			exec dbaadmin.dbo.[dbasp_LogEvent]
				 @cEModule   
				,@cECategory 
				,@cEEvent
				,@cEGUID		= @cEGUID
				,@cEMessage		= @StatusComment
				,@cEMethod_Twitter	= @Tweet
				,@cERE_ForceScreen	= 1
				,@cEMethod_TableLocal	= 1

			SET	@LastReported = getdate()
	END

	INSERT INTO @Status1
	SELECT checksum(*) as CheckSumValue,* 
	FROM [DEPLcontrol].[dbo].[DBA_DashBoard_GearsTicketDetails] (@TicketID,1)
	ORDER BY [RecordOrder]

	WHILE 1=1
	BEGIN
		WAITFOR DELAY '00:00:01'

		If @FlipFlop = 1 
		SET @FlipFlop = 2
		ELSE 
		SET @FlipFlop = 1

		IF @FlipFlop = 1
		BEGIN
			DELETE @Status1
			
			INSERT INTO @Status1
			SELECT checksum(*) as CheckSumValue,* 
			FROM [DEPLcontrol].[dbo].[DBA_DashBoard_GearsTicketDetails] (@TicketID,1)
			ORDER BY [RecordOrder]
		END

		IF @FlipFlop = 2
		BEGIN
			DELETE @Status2
			
			INSERT INTO @Status2
			SELECT checksum(*) as CheckSumValue,* 
			FROM [DEPLcontrol].[dbo].[DBA_DashBoard_GearsTicketDetails] (@TicketID,1)
			ORDER BY [RecordOrder]
		END

		IF EXISTS
		(
		SELECT	*
		FROM	@Status1 T1
		JOIN	@Status2 T2
		  ON	T1.[reqdet_id] = T2.[reqdet_id]
		WHERE	T1.[CheckSumValue] != T2.[CheckSumValue]
		)
		BEGIN
			DECLARE CHANGE CURSOR
			FOR
			SELECT	UPPER(CASE @FlipFlop
					WHEN 1 THEN T1.[Status]
					WHEN 2 THEN T2.[Status]
					END) AS [Event]
				,CASE @FlipFlop
					WHEN 1 THEN T1.[Base] + ' (' +  T1.[Domain]+ ' '+ T1.[SQL] +')' + '  ' + COALESCE(T1.[DB],'') +' '+ COALESCE(T1.[Process],'') +' '+ COALESCE(T1.[Status],'') 
					WHEN 2 THEN T2.[Base] + ' (' +  T2.[Domain]+ ' '+ T2.[SQL] +')' + '  ' + COALESCE(T2.[DB],'') +' '+ COALESCE(T2.[Process],'') +' '+ COALESCE(T2.[Status],'') 
					END +CHAR(13) + Char(10) AS [Message]
			FROM	@Status1 T1
			JOIN	@Status2 T2
			  ON	T1.[reqdet_id] = T2.[reqdet_id]
			WHERE	T1.[CheckSumValue] != T2.[CheckSumValue]			

			OPEN CHANGE

			FETCH NEXT FROM CHANGE INTO @StatusCode,@StatusComment
			WHILE (@@fetch_status <> -1)
			BEGIN
				IF (@@fetch_status <> -2)
				BEGIN
					SET	@StatusComment = @StatusComment + ':' + @StatusCode

					SET	@cECategory = 'STEP STATUS CHANGE'

					exec dbaadmin.dbo.[dbasp_LogEvent]
						 @cEModule   
						,@cECategory 
						,@cEEvent		= @StatusCode
						,@cEGUID		= @cEGUID
						,@cEMessage		= @StatusComment
						,@cEMethod_Twitter	= @Tweet
						,@cERE_ForceScreen	= 1
						,@cEMethod_TableLocal	= 1
						
					SET	@LastReported = getdate()
				END
				FETCH NEXT FROM CHANGE INTO @StatusCode,@StatusComment
			END

			CLOSE CHANGE
			DEALLOCATE CHANGE
		END
		
		if datediff(minute,@LastReported,getdate()) > 1
		BEGIN

			SET	@cECategory = 'INFO'

			exec dbaadmin.dbo.[dbasp_LogEvent]
				 @cEModule   
				,@cECategory 
				,@cEEvent		= 'WAIT'
				,@cEGUID		= @cEGUID
				,@cEMessage		= 'Waiting...'
				,@cEMethod_Twitter	= @Tweet
				,@cERE_ForceScreen	= 1
				,@cEMethod_TableLocal	= 1

			SET	@LastReported = getdate()		

		END
		
		IF NOT EXISTS (SELECT * FROM @Status1 WHERE Status !='completed')
		 BREAK
		 
		IF NOT EXISTS (SELECT * FROM @Status2 WHERE Status !='completed')
		 BREAK 
	END
	
	SET	@cECategory	= 'MONITOR DEPLOY'
	SET	@cEEvent	= 'STOP'
	SET	@StatusComment  = 'Finishing Monitoring of Ticket'
	
	exec dbaadmin.dbo.[dbasp_LogEvent]
			 @cEModule   
			,@cECategory 
			,@cEEvent
			,@cEGUID		= @cEGUID
			,@cEMessage		= @StatusComment
			,@cEMethod_Twitter	= @Tweet
			,@cERE_ForceScreen	= 1
			,@cEMethod_TableLocal	= 1

END
GO


exec deplcontrol.dbo.DBA_Dashboard_GearsRunningTicketStatus_Updater 45679,1,1