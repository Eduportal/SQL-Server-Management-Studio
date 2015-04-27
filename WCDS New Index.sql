CREATE STATISTICS [_dta_stat_151059674_3_2_1_6] ON [dbo].[WebNotes]([IndividualID], [SiteID], [WebNoteID], [IsActive])
GO

CREATE STATISTICS [_dta_stat_151059674_6_1_2] ON [dbo].[WebNotes]([IsActive], [WebNoteID], [SiteID])
GO

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_WebNotes_Covering_1] ON [dbo].[WebNotes]
(
	[SiteID] ASC,
	[IndividualID] ASC,
	[IsActive] ASC,
	[WebNoteID] ASC
)
INCLUDE ( 	[Subject],
	[Message],
	[DismissedCount],
	[CreatedBy],
	[dtViewed],
	[dtDismissed],
	[dtExpiration]) WITH (SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = ON) ON [PRIMARY]
GO

CREATE STATISTICS [_dta_stat_151059674_1_2] ON [dbo].[WebNotes]([WebNoteID], [SiteID])
GO

