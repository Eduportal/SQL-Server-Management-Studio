

--/*
USE [WCDS]
GO

DROP INDEX [IndividualUsernamePass_cmp_cvr_clndx] ON [dbo].[Individual] WITH ( ONLINE = OFF )
GO
CREATE NONCLUSTERED INDEX [IndividualUsernamePass_cmp_cvr_clndx] ON [dbo].[Individual] 
(
	[vchUserName] ASC,
	[vchPassword] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO


CREATE CLUSTERED INDEX [IX_Individual_iIndividualId] ON [dbo].[Individual] ([iIndividualId] ASC)
GO


CREATE NONCLUSTERED INDEX [IX_Address_dtCreated_I_iAddressID]
ON [dbo].[Address] ([dtCreated])
INCLUDE ([iAddressID])
GO

CREATE NONCLUSTERED INDEX [IX_WebSiteUse_dtCreated_I_iIndividualID]
ON [dbo].[WebSiteUse] ([dtCreated])
INCLUDE ([iIndividualID])
GO

CREATE NONCLUSTERED INDEX [IX_Email_dtCreated_I_iIndividualID]
ON [dbo].[Email] ([dtCreated])
INCLUDE ([iIndividualID])
GO

CREATE NONCLUSTERED INDEX [IX_Individual_dtCreated_I_iIndividualID]
ON [dbo].[Individual] ([dtCreated])
INCLUDE ([iIndividualID])
GO


CREATE NONCLUSTERED INDEX [IX_Address_iAddressID_dtModified_dtCreated] ON [dbo].[Address] 
(
	[iAddressID] ASC,
	[dtModified] ASC,
	[dtCreated] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [IX_Email_iIndividualID_dtModified_dtCreated] ON [dbo].[Email] 
(
	[iIndividualID] ASC,
	[dtCreated] ASC,
	[dtModified] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [IX_WebSiteUse_iIndividualID_dtModified_dtCreated] ON [dbo].[WebSiteUse] 
(
	[iIndividualID] ASC,
	[dtModified] ASC,
	[dtCreated] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]



*/


