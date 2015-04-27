------------------------------------------------------------
------------------------------------------------------------
--					DROP AND BUILD TABLES
------------------------------------------------------------
------------------------------------------------------------

/*
DROP TABLE [dbo].[QueueMeta]
GO
DROP TABLE [dbo].[QueueSummary]
GO
*/

/*
CREATE TABLE [dbo].[QueueMeta]
	(
    [QueueID] [int] IDENTITY(1,1) NOT NULL,
    [QueueDateTime] [datetime] NOT NULL,
    [TransactionID] [Int] NOT NULL,
    [AssetID] [Int] NOT NULL,
    [Status] [int] NOT NULL)
GO
ALTER TABLE [dbo].[QueueMeta] ADD  CONSTRAINT [PK_Queue] PRIMARY KEY CLUSTERED
(
    [QueueID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_QueueDateTime] ON [dbo].[QueueMeta]
(
    [QueueDateTime] ASC,
    [Status] ASC
)
INCLUDE ([AssetID]) 
GO

CREATE TABLE [dbo].[QueueSummary]
	(
    [AssetID] [int] NOT NULL,
    [FirstDateTime] [datetime] NOT NULL,
    [LastDateTime] [datetime] NOT NULL,
    [UsageCount] [Int] NOT NULL,
    [Transactions] [VarChar](MAX) NOT NULL
    )
GO
ALTER TABLE [dbo].[QueueSummary] ADD  CONSTRAINT [PK_QueueSummary] PRIMARY KEY CLUSTERED
(
    [AssetID] ASC
)
GO
*/

/*

------------------------------------------------------------
------------------------------------------------------------
--					GENERATE SAMPLE DATA
------------------------------------------------------------
------------------------------------------------------------

-- Do not lock anything, and do not get held up by any locks. 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- GENERATE RANDOM RECORDS IN THE QUEUE TABLE
DECLARE @Count INT
WHILE (SELECT COUNT(NULLIF(Status,1)) From QueueMeta) < 1000
BEGIN
	INSERT INTO	QueueMeta
	SELECT		GetDate()
				,COALESCE((SELECT MAX([TransactionID]) FROM QueueMeta),0)+1
				,Number
				,0
	FROM		dbaadmin.dbo.NumberTable(CAST(RAND()*50 AS INT),CAST(RAND()*100 AS INT), CAST(RAND()*10 AS INT))
	WAITFOR DELAY '00:00:05'
	SELECT @Count = COUNT(NULLIF(Status,1)) From QueueMeta
	PRINT @Count
END

-- SHOW DATA IN QUEUE TABLE
SELECT	* From QueueMeta

*/

------------------------------------------------------------
------------------------------------------------------------
--					PROCESSING LOOP
------------------------------------------------------------
------------------------------------------------------------

-- Do not lock anything, and do not get held up by any locks. 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET NOCOUNT ON

declare @BatchSize int
DECLARE	@Batch1	TABLE	(
						[QueueID] [int] NOT NULL,
						[QueueDateTime] [datetime] NOT NULL,
						[TransactionID] [Int] NOT NULL,
						[AssetID] [Int] NOT NULL,
						[Status] [int] NOT NULL
						)
DECLARE	@Batch2	TABLE	(
						[AssetID] [int] NOT NULL,
						[FirstDateTime] [datetime] NOT NULL,
						[LastDateTime] [datetime] NOT NULL,
						[UsageCount] [Int] NOT NULL,
						[Transactions] [VarChar](MAX) NOT NULL
						)					    
set @BatchSize = 1000

WHILE (SELECT COUNT(NULLIF(Status,1)) From QueueMeta) > 0
BEGIN
	DELETE		@Batch1
	DELETE		@Batch2
	
	INSERT INTO @Batch1
	SELECT		*
	FROM		(
				update		top(@BatchSize) 
							QueueMeta WITH (UPDLOCK, READPAST)
						SET Status = 1
				OUTPUT		Inserted.* 
				WHERE		Status = 0
				) Batch


	INSERT INTO	@Batch2
	SELECT		AssetID
				,MIN(QueueDateTime)
				,MAX(QueueDateTime)
				,COUNT(*)
				,REPLACE	((	SELECT	DISTINCT
										CAST(TransactionID AS VarChar(50)) + ','
								FROM	@Batch1
								WHERE	AssetID = B1.AssetID
								ORDER BY CAST(TransactionID AS VarChar(50)) + ','
								FOR XML PATH(''), TYPE
							  ).value('.[1]', 'NVARCHAR(MAX)')+'|',',|','')
	FROM		@Batch1 B1						  
	GROUP BY	AssetID

	MERGE	[dbo].[QueueSummary] AS Target
	USING	@Batch2 AS Source
		ON	(Target.AssetID = Source.AssetID)
	WHEN MATCHED THEN UPDATE 
		SET		LastDateTime	= Source.LastDateTime
				,UsageCount		= Target.UsageCount + Source.UsageCount
				,Transactions	= REPLACE	(
											(SELECT	TransactionID + ','
											FROM	(
													SELECT  splitValue TransactionID
													FROM	dbaadmin.dbo.dbaudf_split(Target.[Transactions],',')
													UNION	
													SELECT  splitValue TransactionID
													FROM	dbaadmin.dbo.dbaudf_split(Source.[Transactions],',')
													) Data
											ORDER BY TransactionID 
											FOR XML PATH(''), TYPE
													).value('.[1]', 'NVARCHAR(MAX)')+'|',',|','')
	WHEN NOT MATCHED THEN 
		INSERT	(AssetID,FirstDateTime,LastDateTime,UsageCount,Transactions)
		VALUES	(Source.AssetID
				,Source.FirstDateTime
				,Source.LastDateTime
				,Source.UsageCount
				,Source.Transactions
				)	
				;		
END			 			




SELECT		COUNT(NULLIF(Status,1)) UnProcessed
			,COUNT(NULLIF(Status,0)) Processed
From		QueueMeta 
SELECT	* From [QueueSummary]
SELECT		COUNT(*) ASSETS ,SUM(UsageCount) USAGE FROM [QueueSummary]
-- UPDATE QueueMeta SET Status = 0; DELETE [QueueSummary];

							


