USE users
GO

DROP VIEW	DBA_DashBoard_OpenCCTickets
GO
CREATE VIEW	DBA_DashBoard_OpenCCTickets
AS
Select		DISTINCT
		top 100 PERCENT
                t.TID [Ticket],
                'http://intranet.seattle.gettyimages.com/forms/TransactionView.asp?commID=376&comm=Change%20Control&TID={0}&service=Change%20Control%20Request' [Ticket Mask], 
                u.name [Sender],
                u.ID [Sender ID],
                'http://intranet.seattle.gettyimages.com/search/user_record.asp?id={0}' [Sender ID Mask],
                CASE t.priority
			WHEN 1 THEN 'Low'
			WHEN 2 THEN 'Medium'
			WHEN 3 THEN 'High'
			WHEN 4 THEN 'Critical'
			ELSE 'Project' END [Priority], 
                t.subject [Subject], 
		t.workflowTitle [Current Workflow Stage],
                t.category [Review Category], 
                t.category2 [Location], 
                t.category3 [Support Team], 
                f.formTitle [Service], 
                DATEADD(hour,-8,CONVERT(DateTime,LTRIM(REPLACE(RIGHT([start].value,LEN([start].value) - CHARINDEX(',',[start].value)),' UTC','')),113)) [Start Time],
                DATEADD(hour,-8,CONVERT(DateTime,LTRIM(REPLACE(RIGHT([end].value,LEN([end].value) - CHARINDEX(',',[end].value)),' UTC','')),113)) [End Time],  
                t.timeStamp [Date Received], 
                t.timeStamp2 [Date Resolved], 
                t.timeStamp3 [Date Updated], 
                t.handler [Handler],
                'Open' [Status]
from		dbo.frmTransactions t
Join		dbo.frmForm f 
	On	t.FID = f.FID
	and	f.commID = '376'	--Change Control
	and	t.status = '0'		--0=Open,1=Closed
	and	t.handler = 'SEA SQL DBA Team'
Join		dbo.tbl_users u 
	on	u.ID = t.userID
Join		dbo.frmData [start]
	on	[start].TID = t.TID
	AND	[start].CID ='15558'	--Start Date/Time
Join		dbo.frmData [end]
	on	[end].TID = t.TID
	AND	[end].CID ='5035'	--End Date/Time
Order By t.timeStamp desc

GO


DROP VIEW	DBA_DashBoard_ClosedCCTickets
GO
CREATE VIEW	DBA_DashBoard_ClosedCCTickets
AS
Select		DISTINCT
		top 100 PERCENT
                t.TID [Ticket],
                'http://intranet.seattle.gettyimages.com/forms/TransactionView.asp?commID=376&comm=Change%20Control&TID={0}&service=Change%20Control%20Request' [Ticket Mask], 
                u.name [Sender],
                u.ID [Sender ID],
                'http://intranet.seattle.gettyimages.com/search/user_record.asp?id={0}' [Sender ID Mask],
                CASE t.priority
			WHEN 1 THEN 'Low'
			WHEN 2 THEN 'Medium'
			WHEN 3 THEN 'High'
			WHEN 4 THEN 'Critical'
			ELSE 'Project' END [Priority], 
                t.subject [Subject], 
		t.workflowTitle [Current Workflow Stage],
                t.category [Review Category], 
                t.category2 [Location], 
                t.category3 [Support Team], 
                f.formTitle [Service], 
                DATEADD(hour,-8,CONVERT(DateTime,LTRIM(REPLACE(RIGHT([start].value,LEN([start].value) - CHARINDEX(',',[start].value)),' UTC','')),113)) [Start Time],
                DATEADD(hour,-8,CONVERT(DateTime,LTRIM(REPLACE(RIGHT([end].value,LEN([end].value) - CHARINDEX(',',[end].value)),' UTC','')),113)) [End Time],  
                t.timeStamp [Date Received], 
                t.timeStamp2 [Date Resolved], 
                t.timeStamp3 [Date Updated], 
                t.handler [Handler],
                'Closed' [Status]
from		dbo.frmTransactions t
Join		dbo.frmForm f 
	On	t.FID = f.FID
	and	f.commID = '376'	--Change Control
	and	t.status = '1'		--0=Open,1=Closed
	and	t.handler = 'SEA SQL DBA Team'
Join		dbo.tbl_users u 
	on	u.ID = t.userID
Join		dbo.frmData [start]
	on	[start].TID = t.TID
	AND	[start].CID ='15558'	--Start Date/Time
Join		dbo.frmData [end]
	on	[end].TID = t.TID
	AND	[end].CID ='5035'	--End Date/Time
Order By t.timeStamp desc
GO
