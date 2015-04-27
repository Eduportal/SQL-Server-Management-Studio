ALTER VIEW	[dbo].[DBA_DashBoard_NOCTicketHistory]
AS
SELECT		CAST( DATEPART(year,timeStamp)AS VarChar(4))
			+ '-' + RIGHT('00'+CAST(DATEPART(month,timeStamp)AS VarChar(2)),2) [Date]
			, count(Distinct tid) [TicketCount]
FROM		(
			SELECT		TID
						,FID
						,status
						,UserID
						,priority
						,subject
						,workflowtitle
						,category
						,category2
						,category3
						,timestamp
						,timestamp2
						,timestamp3
						,handler
			FROM		Users.dbo.frmTransactions 
			WHERE		year(timeStamp) >= year(Getdate())-1
				AND		FID = 831
				AND		handler = 'SEA SQL DBA Team' 
			UNION ALL
			SELECT		TID
						,FID
						,status
						,UserID
						,priority
						,subject
						,workflowtitle
						,category
						,category2
						,category3
						,timestamp
						,timestamp2
						,timestamp3
						,handler
			FROM		TicketingArchive.dbo.frmTransactions
			WHERE		year(timeStamp) >= year(Getdate())-1
				AND		FID  = 840		--NOC Ticket
				AND		handler = 'SEA SQL DBA Team' 
			)frmTransactions 
GROUP BY	 CAST( DATEPART(year,timeStamp)AS VarChar(4))
			+ '-' + RIGHT('00'+CAST(DATEPART(month,timeStamp)AS VarChar(2)),2)
GO
--ORDER BY	1





ALTER VIEW	[dbo].[DBA_DashBoard_CCTicketHistory]
AS
SELECT		CAST( DATEPART(year,timeStamp)AS VarChar(4))
			+ '-' + RIGHT('00'+CAST(DATEPART(month,timeStamp)AS VarChar(2)),2) [Date]
			, count(Distinct tid) [TicketCount]
FROM		(
			SELECT		TID
						,FID
						,status
						,UserID
						,priority
						,subject
						,workflowtitle
						,category
						,category2
						,category3
						,timestamp
						,timestamp2
						,timestamp3
						,handler
			FROM		Users.dbo.frmTransactions 
			WHERE		year(timeStamp) >= year(Getdate())-1
				AND		FID = 831
				AND		handler = 'SEA SQL DBA Team' 
			UNION ALL
			SELECT		TID
						,FID
						,status
						,UserID
						,priority
						,subject
						,workflowtitle
						,category
						,category2
						,category3
						,timestamp
						,timestamp2
						,timestamp3
						,handler
			FROM		TicketingArchive.dbo.frmTransactions
			WHERE		year(timeStamp) >= year(Getdate())-1
				AND		FID  IN (358,360,468,805,831,835,850,1018,1849)		--CC Ticket
				AND		handler = 'SEA SQL DBA Team' 
			)frmTransactions 
GROUP BY	 CAST( DATEPART(year,timeStamp)AS VarChar(4))
			+ '-' + RIGHT('00'+CAST(DATEPART(month,timeStamp)AS VarChar(2)),2)
GO
--ORDER BY	1


