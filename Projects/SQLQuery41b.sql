SELECT		
		category3 AS Priority
		, status 
		, workflowTitle AS workFlowType
		, category2 AS IssueType
		, category AS SystemEffected
		, TID
		, subject
		, handler
		, [timeStamp] AS TimeOpened
		, [timeStamp2] AS LastUpdated
		, [timeStamp3]
		, [timeStamp4]
FROM		frmTransactions
WHERE		(FID = 840 OR FID = 776) 
	AND	handler like '%sql%'

