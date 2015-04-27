
Getty_Images_US_Inc__MSCRM

SET NOCOUNT ON


Select Count(AsyncOperationId)from AsyncOperationBase WITH (NOLOCK)
where OperationType in (1, 9, 12, 25, 27, 10) 
AND StateCode = 3 AND StatusCode IN (30,32) 



GO

--CREATE NONCLUSTERED INDEX CRM_WorkflowLog_AsyncOperationID ON [dbo].[WorkflowLogBase] ([AsyncOperationID])
--GO 

--CREATE NONCLUSTERED INDEX CRM_DuplicateRecord_AsyncOperationID ON [dbo].[DuplicateRecordBase] ([AsyncOperationID])
--GO

--CREATE NONCLUSTERED INDEX CRM_BulkDeleteOperation_AsyncOperationID ON [dbo].[BulkDeleteOperationBase]
--(AsyncOperationID)
--GO




--IF EXISTS (SELECT name from sys.indexes
--                  WHERE name = N'CRM_AsyncOperation_CleanupCompleted')
--      DROP Index AsyncOperationBase.CRM_AsyncOperation_CleanupCompleted
--GO
--CREATE NONCLUSTERED INDEX CRM_AsyncOperation_CleanupCompleted
--ON [dbo].[AsyncOperationBase] ([StatusCode],[StateCode],[OperationType])
--WITH (FILLFACTOR = 80, ONLINE = ON,SORT_IN_TEMPDB = ON, STATISTICS_NORECOMPUTE = OFF)
--GO


-- ROLLBACK

DECLARE		@DeletedAsyncRowsTable	TABLE
					(
					AsyncOperationId	uniqueidentifier not null primary key
					)
DECLARE		@DeleteRowCount		int
		,@continue		int
		,@rowCount		int

SELECT		@DeleteRowCount		= 2000
		,@continue		= 1

WHILE (@continue = 1)
BEGIN      
BEGIN TRAN
	
	INSERT INTO	@DeletedAsyncRowsTable(AsyncOperationId)
	SELECT		TOP (@DeleteRowCount) 
			AsyncOperationId 
	FROM		AsyncOperationBase
	WHERE		OperationType in (1, 9, 12, 25, 27, 10) 
		AND	StateCode = 3 
		AND	StatusCode in (30, 32)
		     
	SELECT		@rowCount	= 0
	
	SELECT		@rowCount	= count(*) 
	FROM		@DeletedAsyncRowsTable

	SET @continue = 0
	SELECT		@continue	= CASE WHEN @rowCount <= 0 THEN 0 ELSE 1 END      
	
	IF (@continue = 1)        
	BEGIN
		DELETE		WorkflowLogBase 
		FROM		WorkflowLogBase W
				, @DeletedAsyncRowsTable d
		WHERE		W.AsyncOperationId = d.AsyncOperationId

		DELETE		BulkDeleteFailureBase 
		FROM		BulkDeleteFailureBase B
				, @DeletedAsyncRowsTable d
		WHERE		B.AsyncOperationId = d.AsyncOperationId
		
		DELETE		WorkflowWaitSubscriptionBase 
		FROM		WorkflowWaitSubscriptionBase WS
				, @DeletedAsyncRowsTable d
		WHERE		WS.AsyncOperationId = d.AsyncOperationID 
		
		DELETE		AsyncOperationBase 
		FROM		AsyncOperationBase A
				, @DeletedAsyncRowsTable d
		WHERE		A.AsyncOperationId = d.AsyncOperationId             
		
		DELETE		@DeletedAsyncRowsTable  
		RAISERROR ('BATCH DELETED...',-1,-1) WITH NOWAIT    
	END       
COMMIT
END
GO
----Drop the Index on AsyncOperationBase
--DROP INDEX AsyncOperationBase.CRM_AsyncOperation_CleanupCompleted



---- Rebuild Indexes & Update Statistics on AsyncOperationBase Table 
--ALTER INDEX ALL ON AsyncOperationBase REBUILD WITH (FILLFACTOR = 80, ONLINE = OFF,SORT_IN_TEMPDB = ON, STATISTICS_NORECOMPUTE = OFF)
--GO 
---- Rebuild Indexes & Update Statistics on WorkflowLogBase Table 
--ALTER INDEX ALL ON WorkflowLogBase REBUILD WITH (FILLFACTOR = 80, ONLINE = OFF,SORT_IN_TEMPDB = ON, STATISTICS_NORECOMPUTE = OFF)

--GO



--UPDATE STATISTICS [dbo].[AsyncOperationBase] WITH FULLSCAN
--UPDATE STATISTICS [dbo].[DuplicateRecordBase] WITH FULLSCAN
--UPDATE STATISTICS [dbo].[BulkDeleteOperationBase] WITH FULLSCAN
--UPDATE STATISTICS [dbo].[WorkflowCompletedScopeBase] WITH FULLSCAN
--UPDATE STATISTICS [dbo].[WorkflowLogBase] WITH FULLSCAN
--UPDATE STATISTICS [dbo].[WorkflowWaitSubscriptionBase] WITH FULLSCAN


