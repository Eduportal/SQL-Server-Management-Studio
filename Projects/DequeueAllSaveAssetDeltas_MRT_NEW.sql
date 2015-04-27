--SELECT		top 100
--		LEN(AssetDeltasXML) 
--		,*
--FROM		dbo.AssetDeltaJob
--WHERE		jobtype = 'mrt'
--	and	jobstatus = 'pending'
--	and	assetdeltasxml like '%VitriaPublishPriority%'



USE [AssetKeyword]
GO
/****** Object:  StoredProcedure [dbo].[DequeueAllSaveAssetDeltas]    Script Date: 10/18/2012 08:22:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--DROP TABLE #AssetsToIndex
--GO

--CREATE TABLE #AssetsToIndex (MasterID varchar(50))
--GO

--ALTER PROCEDURE [dbo].[DequeueAllSaveAssetDeltas]
DECLARE
	@JobType		CHAR(3), 
	@oiErrorID		int,-- = 0 OUTPUT, -- App-defined error if non-zero. 
	@ovchErrorMessage	nvarchar(256)-- = '' OUTPUT -- Text description of app-defined error
--AS
SET @JobType = 'MRT'

declare @dtStart datetime
set @dtStart = getdate()
/*
---------------------------------------------------------------------------
---------------------------------------------------------------------------

	Revision History
		Modified:	05/06/2008	Ziji Huang, Added @UserGroupCode parameter of auditing
			Modified to call dbo.SaveAssetDeltasJob118 with new parameter @UserGroupCode
		Modified:	04/13/2009	Ziji Huang, Added logic to handle jobType = 'RUE'
		Modified:	11/09/2009	Ed Leckert, Remove JobType "RUE"
		Modified:	07/20/2010	Ed Leckert, call PerformVocabularyUpdateJob138
		Modified:	2/7/2011	Jacob Graves call SaveAssetDeltasJob130 instead of SaveAssetDeltasJob125

	Return Values
		0:	Success
		-999:	Some failure; check output parameters
---------------------------------------------------------------------------
---------------------------------------------------------------------------
*/
SET NOCOUNT ON

DECLARE
	@JobID			INT,
	@Username		VARCHAR(100),
	@UserGroupCode		VARCHAR(10),
	@Command		NVARCHAR(MAX),
	@JobReturn		INT,
	@EventData		VARCHAR(2000),
	@JobStartTime		DATETIME,
	@EventStartTime		DATETIME,
	@TXT			VarChar(2000)

SET @JobStartTime = GETDATE()

-- Loop to find all records that need processing.
JobLoop:
SET @EventStartTime = GETDATE()

SET @JobID = NULL

-- Get record to process. 
UPDATE		dbo.AssetDeltaJob
		-- SET VALUES IN SELECTED RECORD
	SET	JobStatus	= 'Processing'
		,UpdatedDate	= GETDATE()
		-- GET VALUES FROM UPDATED RECORD
		,@JobID		= JobID
		,@Username	= Username
		,@UserGroupCode	= ISNULL(UserGroupCode, 'GETTY')
		,@Command	= AssetDeltasXML
		
WHERE		JobID =	( -- GET NEXT ID TO PROCESS
			SELECT		TOP 1 
					JobID
			FROM		dbo.AssetDeltaJob WITH (NOLOCK)
			WHERE		JobType = @JobType
				AND	(
						JobStatus IN  ('Pending', 'Retrying')
					OR	(
							JobStatus = 'Processing'  -- Get 'Processing' to recover from aborted jobs
						AND	UpdatedDate < dateadd(mi,-60,GetDate())
						)
					)
			ORDER BY	JobID
			)
IF @@Error <> 0 GOTO ErrorHandler



IF @JobID IS NULL
	WAITFOR DELAY '0:0:05'
ELSE
BEGIN
	SET @JobReturn = -999

	-- Process the record
	--IF @JobType = 'MRT'
	--	EXEC @JobReturn = dbo.SaveAssetDeltasJob130
	--		@Username
	--		, @UserGroupCode
	--		, @Command
	--		, @oiErrorID		OUTPUT -- App-defined error if non-zero. 
	--		, @ovchErrorMessage	OUTPUT
			
	IF @JobType = 'MRT'
		EXEC @JobReturn = dbo.SaveAssetDeltasJob130_XPATH
			@Username
			, @UserGroupCode
			, @Command
			, @oiErrorID		OUTPUT -- App-defined error if non-zero. 
			, @ovchErrorMessage	OUTPUT			
			
			
			
	ELSE IF @JobType = 'VOC'
		EXEC @JobReturn = dbo.PerformVocabularyUpdateJob138
			@Command
			, @Username
			, @UserGroupCode
			, @oiErrorID		OUTPUT -- App-defined error if non-zero. 
			, @ovchErrorMessage	OUTPUT -- Text description of app-defined error

	ELSE
		BEGIN
			SET @EventData = 'Invalid JobType: ' + @JobType + '; JobID: ' + CAST(@JobID AS VARCHAR(10))
			EXEC dbo.LogEvent
				@logLevel=5
				, @username=@Username
				, @eventType='DequeueJob'
				, @eventData=@EventData
				, @oiErrorID=@oiErrorID				OUTPUT -- App-defined error if non-zero. 
				, @ovchErrorMessage=@ovchErrorMessage	OUTPUT
		END

	-- Update the job status and release the XML storage
	IF @JobReturn <> 0 
	BEGIN
		-- SET TO RETRYING OR FAILED
		RAISERROR('Job Failed',-1,-1)WITH NOWAIT
		UPDATE		dbo.AssetDeltaJob 
			SET	JobStatus	= CASE WHEN TriesRemaining > 1 THEN 'Retrying' ELSE 'Failed' END
				,TriesRemaining	= CASE WHEN TriesRemaining > 1 THEN TriesRemaining - 1 ELSE 0 END
				,UpdatedDate	= GETDATE()
		WHERE		JobID = @JobID
	END
	ELSE
	BEGIN
		-- SET TO COMPLETED
		RAISERROR('Job Completed',-1,-1)WITH NOWAIT
		UPDATE		dbo.AssetDeltaJob 
			SET	JobStatus	= 'Completed'
				,TriesRemaining	= 0
				,UpdatedDate	= GETDATE()
				,AssetDeltasXML	= NULL
		WHERE		JobID = @JobID
	END
END

SET @TXT = 'Size: ' +  CAST(LEN(@Command)AS VarChar(50)) + ' DURATION: ' + CAST(DATEDIFF(second, @EventStartTime, GETDATE()) AS VarChar(50))
RAISERROR(@TXT,-1,-1) WITH NOWAIT

---- If last event took too long to process, take a breather and let others have the db.
--IF DATEDIFF(mi, @EventStartTime, GETDATE()) > 15	-- 15 minutes
--	WAITFOR DELAY '00:05:00'						-- 5 minutes

---- After a day of processing, exit and let scheduler restart. This is to give DBAs a periodic success log entry.
---- Also, exit if job disabled.
--IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE [Name] = 'APPL - ProcessSaveAssetDeltas' + @JobType AND enabled = 1) 
--	AND DATEDIFF(mi, @JobStartTime, GETDATE()) < 1440	-- 1 day

	GOTO JobLoop

-------------------------------------------
-- Normal exit
-------------------------------------------
NormalExit:
	--RETURN 0

-------------------------------------------
-- Error handler
-------------------------------------------
ErrorHandler:
	--RETURN -999

