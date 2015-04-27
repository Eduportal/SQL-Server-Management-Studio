-----------------------------------------------------------------
-----------------------------------------------------------------
-- CREATE INDEXFK_Event_EventType|PARENT
-----------------------------------------------------------------
-----------------------------------------------------------------

USE [ProductCatalog]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Event]') AND name = N'FK_Event_EventType|PARENT')
CREATE INDEX [FK_Event_EventType|PARENT] ON [dbo].[Event]
(
[EventTypeId]
)
WITH
(
SORT_IN_TEMPDB = ON
, IGNORE_DUP_KEY = OFF
, DROP_EXISTING = OFF
, ONLINE = ON
, PAD_INDEX = OFF
, STATISTICS_NORECOMPUTE = OFF
, ALLOW_ROW_LOCKS = ON
, ALLOW_PAGE_LOCKS = ON
)

GO

-----------------------------------------------------------------
-----------------------------------------------------------------
-- CREATE INDEXIX_Event_3_INC_1_13
-----------------------------------------------------------------
-----------------------------------------------------------------

USE [ProductCatalog]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Event]') AND name = N'IX_Event_3_INC_1_13')
CREATE INDEX [IX_Event_3_INC_1_13] ON [dbo].[Event]
(
[EventTypeId]
)
INCLUDE
(
[EventId], [isDisplayed]
)
WITH
(
SORT_IN_TEMPDB = ON
, IGNORE_DUP_KEY = OFF
, DROP_EXISTING = OFF
, ONLINE = ON
, PAD_INDEX = OFF
, STATISTICS_NORECOMPUTE = OFF
, ALLOW_ROW_LOCKS = ON
, ALLOW_PAGE_LOCKS = ON
)

