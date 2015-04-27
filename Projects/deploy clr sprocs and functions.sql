USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Filter_Alpha]    Script Date: 09/15/2011 16:39:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Filter_Alpha]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_Filter_Alpha]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Filter_AlphaNumeric]    Script Date: 09/15/2011 16:39:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Filter_AlphaNumeric]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_Filter_AlphaNumeric]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Filter_Numeric]    Script Date: 09/15/2011 16:39:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Filter_Numeric]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_Filter_Numeric]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Filter_ValidFileName]    Script Date: 09/15/2011 16:39:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Filter_ValidFileName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_Filter_ValidFileName]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_FormatString]    Script Date: 09/15/2011 16:39:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_FormatString]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_FormatString]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_FrameworkVersion]    Script Date: 09/15/2011 16:39:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_FrameworkVersion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_FrameworkVersion]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetEV]    Script Date: 09/15/2011 16:39:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetEV]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_GetEV]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetSharePath]    Script Date: 09/15/2011 16:39:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetSharePath]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_GetSharePath]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_LoadFile]    Script Date: 09/15/2011 16:39:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_LoadFile]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_LoadFile]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_SendTweet]    Script Date: 09/15/2011 16:39:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_SendTweet]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_SendTweet]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_SetEV]    Script Date: 09/15/2011 16:39:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_SetEV]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_SetEV]
GO

USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetAllEVs]    Script Date: 09/15/2011 16:27:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetAllEVs]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_GetAllEVs]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Sharepoint_GetCalendarItems]    Script Date: 09/15/2011 16:27:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Sharepoint_GetCalendarItems]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_Sharepoint_GetCalendarItems]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Sharepoint_GetListCollection]    Script Date: 09/15/2011 16:27:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Sharepoint_GetListCollection]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_Sharepoint_GetListCollection]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_StringToTable]    Script Date: 09/15/2011 16:27:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_StringToTable]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_StringToTable]
GO




USE [dbaadmin]
GO

/****** Object:  UserDefinedAggregate [dbo].[dbaudf_Concatenate]    Script Date: 09/15/2011 16:24:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Concatenate]') AND type = N'AF')
DROP AGGREGATE [dbo].[dbaudf_Concatenate]

GO

/****** Object:  UserDefinedAggregate [dbo].[dbaudf_ConcatenateUnique]    Script Date: 09/15/2011 16:24:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_ConcatenateUnique]') AND type = N'AF')
DROP AGGREGATE [dbo].[dbaudf_ConcatenateUnique]

GO

USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_DeployDrop]    Script Date: 09/15/2011 16:24:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_DeployDrop]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_DeployDrop]
GO

USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_DirectoryCompare]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_DirectoryCompare]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_DirectoryCompare]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAdjacentCalendar]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAdjacentCalendar]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetAdjacentCalendar]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAdjacentCalendarBase]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAdjacentCalendarBase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetAdjacentCalendarBase]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAdjacentCalendarSingle]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAdjacentCalendarSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetAdjacentCalendarSingle]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAttachment]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAttachment]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetAttachment]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAttachmentBase]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAttachmentBase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetAttachmentBase]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAttachmentSingle]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAttachmentSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetAttachmentSingle]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAttendeeCalendar]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAttendeeCalendar]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetAttendeeCalendar]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAttendeeCalendarBase]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAttendeeCalendarBase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetAttendeeCalendarBase]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAttendeeCalendarSingle]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAttendeeCalendarSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetAttendeeCalendarSingle]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAvailability]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAvailability]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetAvailability]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetCalendar]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetCalendar]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetCalendar]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetCalendarBase]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetCalendarBase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetCalendarBase]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetConflictingCalendar]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetConflictingCalendar]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetConflictingCalendar]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetConflictingCalendarBase]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetConflictingCalendarBase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetConflictingCalendarBase]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetConflictingCalendarSingle]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetConflictingCalendarSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetConflictingCalendarSingle]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContacts]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContacts]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetContacts]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsAddress]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsAddress]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetContactsAddress]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsAddressSingle]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsAddressSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetContactsAddressSingle]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsEmail]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsEmail]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetContactsEmail]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsEmailSingle]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsEmailSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetContactsEmailSingle]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsIM]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsIM]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetContactsIM]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsIMSingle]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsIMSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetContactsIMSingle]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsPhone]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsPhone]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetContactsPhone]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsPhoneSingle]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsPhoneSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetContactsPhoneSingle]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetInbox]    Script Date: 09/15/2011 16:22:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetInbox]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetInbox]
GO

USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_CPU_Top4]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_CPU_Top4]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_CPU_Top4]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Blocked_Sessions]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Blocked_Sessions]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Blocked_Sessions]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Top5IO_DB]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Top5IO_DB]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Top5IO_DB]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TopElapsed]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TopElapsed]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_TopElapsed]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TopCPU]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TopCPU]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_TopCPU]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TablesWithoutClusteredIndexes]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TablesWithoutClusteredIndexes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_TablesWithoutClusteredIndexes]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TablesWithoutAnyIndexes]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TablesWithoutAnyIndexes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_TablesWithoutAnyIndexes]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_MissingIndexesDB]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_MissingIndexesDB]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_MissingIndexesDB]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_SQLAgent_Jobs_Stats]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_SQLAgent_Jobs_Stats]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_SQLAgent_Jobs_Stats]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_SQLAgent_Jobs_Run]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_SQLAgent_Jobs_Run]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_SQLAgent_Jobs_Run]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_SQLAgent_Status]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_SQLAgent_Status]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_SQLAgent_Status]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_RecentBackups]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_RecentBackups]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_RecentBackups]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TablesWithoutPKs]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TablesWithoutPKs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_TablesWithoutPKs]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TopIO_DB]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TopIO_DB]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_TopIO_DB]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_MissingIndexes]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_MissingIndexes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_MissingIndexes]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Wait_Stats]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Wait_Stats]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Wait_Stats]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_RecordCounts]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_RecordCounts]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_RecordCounts]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Dbspace_Usage_Sumall]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Dbspace_Usage_Sumall]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Dbspace_Usage_Sumall]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Dbspace_Usage_All]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Dbspace_Usage_All]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Dbspace_Usage_All]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_IndexFrag]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_IndexFrag]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_IndexFrag]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Failed_Sqlagent_Jobs_Day]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Failed_Sqlagent_Jobs_Day]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Failed_Sqlagent_Jobs_Day]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Execution_TopSPs]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Execution_TopSPs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Execution_TopSPs]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Execution_TopFNs]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Execution_TopFNs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Execution_TopFNs]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_DiskSpace]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_DiskSpace]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_DiskSpace]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_JobFailureTotals]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_JobFailureTotals]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_JobFailureTotals]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Gather_PerformanceStats]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Gather_PerformanceStats]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Gather_PerformanceStats]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TopIOSPs]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TopIOSPs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_TopIOSPs]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_IO_Top4]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_IO_Top4]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_IO_Top4]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Dbspace_Usage]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Dbspace_Usage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Dbspace_Usage]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Blocked_Processes]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Blocked_Processes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Blocked_Processes]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Wait_Stat_Percentage]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Wait_Stat_Percentage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Wait_Stat_Percentage]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_CPU_Utilization]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_CPU_Utilization]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_CPU_Utilization]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_PerformanceCounters]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_PerformanceCounters]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_PerformanceCounters]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Allsps]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Allsps]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Allsps]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Failed_Sqlagent_Jobs]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Failed_Sqlagent_Jobs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Failed_Sqlagent_Jobs]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TasksWaitingToRun]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TasksWaitingToRun]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_TasksWaitingToRun]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Gather_Wait_Stats]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Gather_Wait_Stats]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Gather_Wait_Stats]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TopIO]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TopIO]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_TopIO]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Unused_Indexes]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Unused_Indexes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Unused_Indexes]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TablesWithPKs]    Script Date: 09/15/2011 13:48:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TablesWithPKs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_TablesWithPKs]
GO

USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_FTP_Get]    Script Date: 09/15/2011 13:47:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_FTP_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_FTP_Get]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_FTP_Put]    Script Date: 09/15/2011 13:47:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_FTP_Put]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_FTP_Put]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_FileCompare]    Script Date: 09/15/2011 13:47:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_FileCompare]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_FileCompare]
GO

/****** Object:  StoredProcedure [dbo].[dbaudf_UnlockAndDeleteFile]    Script Date: 09/15/2011 13:47:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_UnlockAndDeleteFile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbaudf_UnlockAndDeleteFile]
GO

USE [dbaadmin]
GO


/****** Object:  StoredProcedure [dbo].[dbasp_FTP_Get]    Script Date: 09/15/2011 13:47:35 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_FTP_Get]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_FTP_Get]
	@filename [nvarchar](4000),
	@local_path [nvarchar](4000),
	@ftp_path [nvarchar](4000),
	@login [nvarchar](4000),
	@password [nvarchar](4000)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.StoredProcedures].[dbasp_FTP_Get]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_FTP_Put]    Script Date: 09/15/2011 13:47:36 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_FTP_Put]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_FTP_Put]
	@filename [nvarchar](4000),
	@local_path [nvarchar](4000),
	@ftp_path [nvarchar](4000),
	@login [nvarchar](4000),
	@password [nvarchar](4000)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.StoredProcedures].[dbasp_FTP_Put]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_FileCompare]    Script Date: 09/15/2011 13:47:36 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_FileCompare]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_FileCompare]
	@file1 [nvarchar](4000),
	@file2 [nvarchar](4000)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.StoredProcedures].[dbasp_FileCompare]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbaudf_UnlockAndDeleteFile]    Script Date: 09/15/2011 13:47:36 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_UnlockAndDeleteFile]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbaudf_UnlockAndDeleteFile]
	@fileName [nvarchar](4000),
	@DoItNow [bit]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.StoredProcedures].[dbaudf_UnlockAndDeleteFile]' 
END
GO


/****** Object:  StoredProcedure [dbo].[dbasp_Get_CPU_Top4]    Script Date: 09/15/2011 13:48:42 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_CPU_Top4]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_CPU_Top4]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_CPU_Top4]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Blocked_Sessions]    Script Date: 09/15/2011 13:48:42 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Blocked_Sessions]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_Blocked_Sessions]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_Blocked_Sessions]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Top5IO_DB]    Script Date: 09/15/2011 13:48:42 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Top5IO_DB]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_Top5IO_DB]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_Top5IO_DB]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TopElapsed]    Script Date: 09/15/2011 13:48:42 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TopElapsed]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_TopElapsed]
	@TopNumber [int]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_TopElapsed]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TopCPU]    Script Date: 09/15/2011 13:48:42 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TopCPU]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_TopCPU]
	@TopNumber [int],
	@DBName [nvarchar](128)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_TopCPU]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TablesWithoutClusteredIndexes]    Script Date: 09/15/2011 13:48:42 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TablesWithoutClusteredIndexes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_TablesWithoutClusteredIndexes]
	@DatabaseName [nvarchar](128)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_TablesWithoutClusteredIndexes]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TablesWithoutAnyIndexes]    Script Date: 09/15/2011 13:48:42 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TablesWithoutAnyIndexes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_TablesWithoutAnyIndexes]
	@DatabaseName [nvarchar](128)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_TablesWithoutAnyIndexes]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_MissingIndexesDB]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_MissingIndexesDB]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_MissingIndexesDB]
	@DBNAME [nvarchar](128)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_MissingIndexesDB]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_SQLAgent_Jobs_Stats]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_SQLAgent_Jobs_Stats]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_SQLAgent_Jobs_Stats]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_SQLAgent_Jobs_Stats]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_SQLAgent_Jobs_Run]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_SQLAgent_Jobs_Run]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_SQLAgent_Jobs_Run]
	@Interval [nvarchar](2)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_SQLAgent_Jobs_Run]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_SQLAgent_Status]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_SQLAgent_Status]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_SQLAgent_Status]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_SQLAgent_Status]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_RecentBackups]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_RecentBackups]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_RecentBackups]
	@DatabaseName [nvarchar](128)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_RecentBackups]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TablesWithoutPKs]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TablesWithoutPKs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_TablesWithoutPKs]
	@DatabaseName [nvarchar](128)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_TablesWithoutPKs]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TopIO_DB]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TopIO_DB]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_TopIO_DB]
	@TopNumber [int]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_TopIO_DB]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_MissingIndexes]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_MissingIndexes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_MissingIndexes]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_MissingIndexes]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Wait_Stats]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Wait_Stats]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_Wait_Stats]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_Wait_Stats]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_RecordCounts]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_RecordCounts]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_RecordCounts]
	@DatabaseName [nvarchar](128)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_RecordCounts]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Dbspace_Usage_Sumall]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Dbspace_Usage_Sumall]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_Dbspace_Usage_Sumall]
	@DB [nvarchar](100)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_Dbspace_Usage_Sumall]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Dbspace_Usage_All]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Dbspace_Usage_All]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_Dbspace_Usage_All]
	@db [nvarchar](128),
	@sort [nvarchar](128)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_Dbspace_Usage_All]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_IndexFrag]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_IndexFrag]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_IndexFrag]
	@DatabaseName [nvarchar](128)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_IndexFrag]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Failed_Sqlagent_Jobs_Day]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Failed_Sqlagent_Jobs_Day]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_Failed_Sqlagent_Jobs_Day]
	@failed_after [int],
	@failed_to [int]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_Failed_Sqlagent_Jobs_Day]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Execution_TopSPs]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Execution_TopSPs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_Execution_TopSPs]
	@TopNumber [int],
	@DBNAME [nvarchar](128)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_Execution_TopSPs]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Execution_TopFNs]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Execution_TopFNs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_Execution_TopFNs]
	@TopNumber [int],
	@DBNAME [nvarchar](128)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_Execution_TopFNs]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_DiskSpace]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_DiskSpace]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_DiskSpace]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_DiskSpace]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_JobFailureTotals]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_JobFailureTotals]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_JobFailureTotals]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_JobFailureTotals]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Gather_PerformanceStats]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Gather_PerformanceStats]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Gather_PerformanceStats]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Gather_PerformanceStats]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TopIOSPs]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TopIOSPs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_TopIOSPs]
	@TopNumber [int],
	@DBNAME [nvarchar](128)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_TopIOSPs]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_IO_Top4]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_IO_Top4]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_IO_Top4]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_IO_Top4]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Dbspace_Usage]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Dbspace_Usage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_Dbspace_Usage]
	@dbname [nvarchar](128)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_Dbspace_Usage]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Blocked_Processes]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Blocked_Processes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_Blocked_Processes]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_Blocked_Processes]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Wait_Stat_Percentage]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Wait_Stat_Percentage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_Wait_Stat_Percentage]
	@NumInv [int]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_Wait_Stat_Percentage]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_CPU_Utilization]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_CPU_Utilization]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_CPU_Utilization]
	@IntervalNum [int]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_CPU_Utilization]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_PerformanceCounters]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_PerformanceCounters]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_PerformanceCounters]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_PerformanceCounters]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Allsps]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Allsps]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_Allsps]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_Allsps]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Failed_Sqlagent_Jobs]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Failed_Sqlagent_Jobs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_Failed_Sqlagent_Jobs]
	@failed_after [int],
	@failed_to [int]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_Failed_Sqlagent_Jobs]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TasksWaitingToRun]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TasksWaitingToRun]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_TasksWaitingToRun]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_TasksWaitingToRun]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Gather_Wait_Stats]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Gather_Wait_Stats]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Gather_Wait_Stats]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Gather_Wait_Stats]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TopIO]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TopIO]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_TopIO]
	@TopNumber [int],
	@DBNAME [nvarchar](128)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_TopIO]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Unused_Indexes]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Unused_Indexes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_Unused_Indexes]
	@DatabaseName [nvarchar](128)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_Unused_Indexes]' 
END
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TablesWithPKs]    Script Date: 09/15/2011 13:48:43 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TablesWithPKs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_Get_TablesWithPKs]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DBA_Dashboard].[StoredProcedures].[Get_TablesWithPKs]' 
END
GO


/****** Object:  UserDefinedFunction [dbo].[dbaudf_DirectoryCompare]    Script Date: 09/15/2011 16:22:47 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_DirectoryCompare]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_DirectoryCompare](@pathA [nvarchar](4000), @pathB [nvarchar](4000))
RETURNS  TABLE (
	[FileName] [nvarchar](255) NULL,
	[RelativePath] [nvarchar](4000) NULL,
	[Comparison] [nvarchar](50) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools.net35].[GettyImages.Operation.UserDefinedFunctions].[dbaudf_DirectoryCompare]' 
END

GO


/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAdjacentCalendar]    Script Date: 09/15/2011 16:22:48 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAdjacentCalendar]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetAdjacentCalendar](@daysBefore [int], @daysAfter [int])
RETURNS  TABLE (
	[AdjacentItemId1] [nvarchar](156) NULL,
	[AdjacentChangeKey1] [nvarchar](100) NULL,
	[AdjacentItemId2] [nvarchar](156) NULL,
	[AdjacentChangeKey2] [nvarchar](100) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeCalendarAdjacent].[dbaudf_exchange_GetAdjacentCalendar]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAdjacentCalendarBase]    Script Date: 09/15/2011 16:22:48 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAdjacentCalendarBase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetAdjacentCalendarBase]()
RETURNS  TABLE (
	[AdjacentItemId1] [nvarchar](156) NULL,
	[AdjacentChangeKey1] [nvarchar](100) NULL,
	[AdjacentItemId2] [nvarchar](156) NULL,
	[AdjacentChangeKey2] [nvarchar](100) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeCalendarAdjacent].[dbaudf_exchange_GetAdjacentCalendarBase]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAdjacentCalendarSingle]    Script Date: 09/15/2011 16:22:48 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAdjacentCalendarSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetAdjacentCalendarSingle](@itemId [nvarchar](4000))
RETURNS  TABLE (
	[AdjacentItemId1] [nvarchar](156) NULL,
	[AdjacentChangeKey1] [nvarchar](100) NULL,
	[AdjacentItemId2] [nvarchar](156) NULL,
	[AdjacentChangeKey2] [nvarchar](100) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeCalendarAdjacent].[dbaudf_exchange_GetAdjacentCalendarSingle]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAttachment]    Script Date: 09/15/2011 16:22:48 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAttachment]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetAttachment](@daysBefore [int], @daysAfter [int])
RETURNS  TABLE (
	[CalendarItemId] [nvarchar](156) NULL,
	[AttachmentId] [nvarchar](168) NULL,
	[AttachmentName] [nvarchar](100) NULL,
	[AttachmentContent] [varbinary](max) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeCalendarAttachment].[dbaudf_exchange_GetAttachment]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAttachmentBase]    Script Date: 09/15/2011 16:22:48 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAttachmentBase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetAttachmentBase]()
RETURNS  TABLE (
	[CalendarItemId] [nvarchar](156) NULL,
	[AttachmentId] [nvarchar](168) NULL,
	[AttachmentName] [nvarchar](100) NULL,
	[AttachmentContent] [varbinary](max) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeCalendarAttachment].[dbaudf_exchange_GetAttachmentBase]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAttachmentSingle]    Script Date: 09/15/2011 16:22:48 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAttachmentSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetAttachmentSingle](@itemId [nvarchar](4000))
RETURNS  TABLE (
	[CalendarItemId] [nvarchar](156) NULL,
	[AttachmentId] [nvarchar](168) NULL,
	[AttachmentName] [nvarchar](100) NULL,
	[AttachmentContent] [varbinary](max) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeCalendarAttachment].[dbaudf_exchange_GetAttachmentSingle]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAttendeeCalendar]    Script Date: 09/15/2011 16:22:48 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAttendeeCalendar]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetAttendeeCalendar](@daysBefore [int], @daysAfter [int])
RETURNS  TABLE (
	[CalendarItemId] [nvarchar](156) NULL,
	[CalendarChangeKey] [nvarchar](100) NULL,
	[AttendeeName] [nvarchar](100) NULL,
	[AttendeeEMailAddr] [nvarchar](100) NULL,
	[AttendeeResponse] [nvarchar](20) NULL,
	[InviteeType] [nvarchar](20) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeCalendarAttendee].[dbaudf_exchange_GetAttendeeCalendar]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAttendeeCalendarBase]    Script Date: 09/15/2011 16:22:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAttendeeCalendarBase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetAttendeeCalendarBase]()
RETURNS  TABLE (
	[CalendarItemId] [nvarchar](156) NULL,
	[CalendarChangeKey] [nvarchar](100) NULL,
	[AttendeeName] [nvarchar](100) NULL,
	[AttendeeEMailAddr] [nvarchar](100) NULL,
	[AttendeeResponse] [nvarchar](20) NULL,
	[InviteeType] [nvarchar](20) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeCalendarAttendee].[dbaudf_exchange_GetAttendeeCalendarBase]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAttendeeCalendarSingle]    Script Date: 09/15/2011 16:22:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAttendeeCalendarSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetAttendeeCalendarSingle](@itemId [nvarchar](4000))
RETURNS  TABLE (
	[CalendarItemId] [nvarchar](156) NULL,
	[CalendarChangeKey] [nvarchar](100) NULL,
	[AttendeeName] [nvarchar](100) NULL,
	[AttendeeEMailAddr] [nvarchar](100) NULL,
	[AttendeeResponse] [nvarchar](20) NULL,
	[InviteeType] [nvarchar](20) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeCalendarAttendee].[dbaudf_exchange_GetAttendeeCalendarSingle]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAvailability]    Script Date: 09/15/2011 16:22:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAvailability]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetAvailability](@person [nvarchar](4000), @startTime [datetime], @endTime [datetime])
RETURNS  TABLE (
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[State] [nvarchar](10) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeAvailability].[dbaudf_exchange_GetAvailability]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetCalendar]    Script Date: 09/15/2011 16:22:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetCalendar]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetCalendar](@daysBefore [int], @daysAfter [int])
RETURNS  TABLE (
	[ItemId] [nvarchar](156) NULL,
	[ItemChangeKey] [nvarchar](100) NULL,
	[Class] [nvarchar](100) NULL,
	[Subject] [nvarchar](512) NULL,
	[Sensitivity] [nvarchar](10) NULL,
	[Received] [datetime] NULL,
	[Sent] [datetime] NULL,
	[Created] [datetime] NULL,
	[Size] [int] NULL,
	[Importance] [nvarchar](10) NULL,
	[Submitted] [bit] NULL,
	[Draft] [bit] NULL,
	[HasAttachment] [bit] NULL,
	[DisplayCc] [nvarchar](255) NULL,
	[Organizer] [nvarchar](100) NULL,
	[ReminderDueBy] [datetime] NULL,
	[ReminderIsSet] [bit] NULL,
	[ReminderMinutesBeforeStart] [int] NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[IsAllDayEvent] [bit] NULL,
	[LegacyFreeBusyStatus] [nvarchar](10) NULL,
	[Location] [nvarchar](100) NULL,
	[isMeeting] [bit] NULL,
	[isRecurring] [bit] NULL,
	[MeetingRequestWasSent] [bit] NULL,
	[IsResponseRequested] [bit] NULL,
	[IsFromMe] [bit] NULL,
	[AllowNewTimeProposal] [bit] NULL,
	[IsResend] [bit] NULL,
	[IsUnmodified] [bit] NULL,
	[CalendarItemType] [nvarchar](20) NULL,
	[MyResponseType] [nvarchar](20) NULL,
	[Duration] [nvarchar](20) NULL,
	[TimeZone] [nvarchar](60) NULL,
	[Culture] [nvarchar](60) NULL,
	[ConferenceType] [int] NULL,
	[AppointmentState] [int] NULL,
	[AppointmentSequenceNumber] [int] NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeCalendar].[dbaudf_exchange_GetCalendar]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetCalendarBase]    Script Date: 09/15/2011 16:22:50 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetCalendarBase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetCalendarBase]()
RETURNS  TABLE (
	[ItemId] [nvarchar](156) NULL,
	[ItemChangeKey] [nvarchar](100) NULL,
	[Class] [nvarchar](100) NULL,
	[Subject] [nvarchar](512) NULL,
	[Sensitivity] [nvarchar](10) NULL,
	[Received] [datetime] NULL,
	[Sent] [datetime] NULL,
	[Created] [datetime] NULL,
	[Size] [int] NULL,
	[Importance] [nvarchar](10) NULL,
	[Submitted] [bit] NULL,
	[Draft] [bit] NULL,
	[HasAttachment] [bit] NULL,
	[DisplayCc] [nvarchar](255) NULL,
	[Organizer] [nvarchar](100) NULL,
	[ReminderDueBy] [datetime] NULL,
	[ReminderIsSet] [bit] NULL,
	[ReminderMinutesBeforeStart] [int] NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[IsAllDayEvent] [bit] NULL,
	[LegacyFreeBusyStatus] [nvarchar](10) NULL,
	[Location] [nvarchar](100) NULL,
	[isMeeting] [bit] NULL,
	[isRecurring] [bit] NULL,
	[MeetingRequestWasSent] [bit] NULL,
	[IsResponseRequested] [bit] NULL,
	[IsFromMe] [bit] NULL,
	[AllowNewTimeProposal] [bit] NULL,
	[IsResend] [bit] NULL,
	[IsUnmodified] [bit] NULL,
	[CalendarItemType] [nvarchar](20) NULL,
	[MyResponseType] [nvarchar](20) NULL,
	[Duration] [nvarchar](20) NULL,
	[TimeZone] [nvarchar](60) NULL,
	[Culture] [nvarchar](60) NULL,
	[ConferenceType] [int] NULL,
	[AppointmentState] [int] NULL,
	[AppointmentSequenceNumber] [int] NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeCalendar].[dbaudf_exchange_GetCalendarBase]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetConflictingCalendar]    Script Date: 09/15/2011 16:22:50 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetConflictingCalendar]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetConflictingCalendar](@daysBefore [int], @daysAfter [int])
RETURNS  TABLE (
	[ConflictingItemId1] [nvarchar](156) NULL,
	[ConflictingChangeKey1] [nvarchar](100) NULL,
	[ConflictingItemId2] [nvarchar](156) NULL,
	[ConflictingChangeKey2] [nvarchar](100) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeCalendarConflicting].[dbaudf_exchange_GetConflictingCalendar]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetConflictingCalendarBase]    Script Date: 09/15/2011 16:22:51 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetConflictingCalendarBase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetConflictingCalendarBase]()
RETURNS  TABLE (
	[ConflictingItemId1] [nvarchar](156) NULL,
	[ConflictingChangeKey1] [nvarchar](100) NULL,
	[ConflictingItemId2] [nvarchar](156) NULL,
	[ConflictingChangeKey2] [nvarchar](100) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeCalendarConflicting].[dbaudf_exchange_GetConflictingCalendarBase]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetConflictingCalendarSingle]    Script Date: 09/15/2011 16:22:51 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetConflictingCalendarSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetConflictingCalendarSingle](@itemId [nvarchar](4000))
RETURNS  TABLE (
	[ConflictingItemId1] [nvarchar](156) NULL,
	[ConflictingChangeKey1] [nvarchar](100) NULL,
	[ConflictingItemId2] [nvarchar](156) NULL,
	[ConflictingChangeKey2] [nvarchar](100) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeCalendarConflicting].[dbaudf_exchange_GetConflictingCalendarSingle]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContacts]    Script Date: 09/15/2011 16:22:51 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContacts]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetContacts]()
RETURNS  TABLE (
	[ItemId] [nvarchar](156) NULL,
	[ItemChangeKey] [nvarchar](100) NULL,
	[DisplayName] [nvarchar](100) NULL,
	[CompanyName] [nvarchar](100) NULL,
	[JobTitle] [nvarchar](100) NULL,
	[SurName] [nvarchar](100) NULL,
	[GivenName] [nvarchar](100) NULL,
	[Initials] [nvarchar](100) NULL,
	[Importance] [nvarchar](10) NULL,
	[Culture] [nvarchar](10) NULL,
	[FileAs] [nvarchar](100) NULL,
	[FileAsMapping] [nvarchar](100) NULL,
	[BusinessHomePage] [nvarchar](100) NULL,
	[Created] [datetime] NULL,
	[Size] [int] NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeContacts].[dbaudf_exchange_GetContacts]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsAddress]    Script Date: 09/15/2011 16:22:51 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsAddress]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetContactsAddress]()
RETURNS  TABLE (
	[ItemId] [nvarchar](156) NULL,
	[EntryType] [nvarchar](20) NULL,
	[Street] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[State] [nvarchar](100) NULL,
	[Country] [nvarchar](100) NULL,
	[PostalCode] [nvarchar](100) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeContactAddress].[dbaudf_exchange_GetContactsAddress]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsAddressSingle]    Script Date: 09/15/2011 16:22:51 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsAddressSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetContactsAddressSingle](@itemId [nvarchar](4000))
RETURNS  TABLE (
	[ItemId] [nvarchar](156) NULL,
	[EntryType] [nvarchar](20) NULL,
	[Street] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[State] [nvarchar](100) NULL,
	[Country] [nvarchar](100) NULL,
	[PostalCode] [nvarchar](100) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeContactAddress].[dbaudf_exchange_GetContactsAddressSingle]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsEmail]    Script Date: 09/15/2011 16:22:51 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsEmail]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetContactsEmail]()
RETURNS  TABLE (
	[ItemId] [nvarchar](156) NULL,
	[EntryType] [nvarchar](20) NULL,
	[EmailAddress] [nvarchar](255) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeContactEmail].[dbaudf_exchange_GetContactsEmail]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsEmailSingle]    Script Date: 09/15/2011 16:22:51 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsEmailSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetContactsEmailSingle](@itemId [nvarchar](4000))
RETURNS  TABLE (
	[ItemId] [nvarchar](156) NULL,
	[EntryType] [nvarchar](20) NULL,
	[EmailAddress] [nvarchar](255) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeContactEmail].[dbaudf_exchange_GetContactsEmailSingle]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsIM]    Script Date: 09/15/2011 16:22:51 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsIM]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetContactsIM]()
RETURNS  TABLE (
	[ItemId] [nvarchar](156) NULL,
	[EntryType] [nvarchar](20) NULL,
	[ImAddress] [nvarchar](255) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeContactIm].[dbaudf_exchange_GetContactsIM]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsIMSingle]    Script Date: 09/15/2011 16:22:52 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsIMSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetContactsIMSingle](@itemId [nvarchar](4000))
RETURNS  TABLE (
	[ItemId] [nvarchar](156) NULL,
	[EntryType] [nvarchar](20) NULL,
	[ImAddress] [nvarchar](255) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeContactIm].[dbaudf_exchange_GetContactsIMSingle]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsPhone]    Script Date: 09/15/2011 16:22:52 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsPhone]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetContactsPhone]()
RETURNS  TABLE (
	[ItemId] [nvarchar](156) NULL,
	[EntryType] [nvarchar](20) NULL,
	[PhoneNumber] [nvarchar](255) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeContactPhone].[dbaudf_exchange_GetContactsPhone]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsPhoneSingle]    Script Date: 09/15/2011 16:22:52 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsPhoneSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetContactsPhoneSingle](@itemId [nvarchar](4000))
RETURNS  TABLE (
	[ItemId] [nvarchar](156) NULL,
	[EntryType] [nvarchar](20) NULL,
	[PhoneNumber] [nvarchar](255) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeContactPhone].[dbaudf_exchange_GetContactsPhoneSingle]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetInbox]    Script Date: 09/15/2011 16:22:52 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetInbox]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_exchange_GetInbox]()
RETURNS  TABLE (
	[ItemId] [nvarchar](156) NULL,
	[ItemChangeKey] [nvarchar](100) NULL,
	[Class] [nvarchar](100) NULL,
	[Subject] [nvarchar](512) NULL,
	[Sensitivity] [nvarchar](10) NULL,
	[Received] [datetime] NULL,
	[Sent] [datetime] NULL,
	[Created] [datetime] NULL,
	[Size] [int] NULL,
	[Importance] [nvarchar](10) NULL,
	[Submitted] [bit] NULL,
	[Draft] [bit] NULL,
	[HasAttachment] [bit] NULL,
	[IsRead] [bit] NULL,
	[IsReadReceiptRequested] [bit] NULL,
	[IsDeliveryReceiptRequested] [bit] NULL,
	[DisplayCc] [nvarchar](255) NULL,
	[DisplayTo] [nvarchar](255) NULL,
	[Sender] [nvarchar](100) NULL,
	[DisplayFrom] [nvarchar](100) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.ExchangeInbox].[dbaudf_exchange_GetInbox]' 
END

GO

USE [dbaadmin]
GO




/****** Object:  UserDefinedFunction [dbo].[dbaudf_DeployDrop]    Script Date: 09/15/2011 16:23:58 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_DeployDrop]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_DeployDrop](@Folder [nvarchar](4000), @command [nvarchar](4000), @fileName [nvarchar](4000), @ticketType [nvarchar](4000), @ticketNumber [nvarchar](4000), @SQLname [nvarchar](4000), @login [nvarchar](4000), @password [nvarchar](4000))
RETURNS [varbinary](8000) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools.net35].[UserDefinedFunctions].[dbaudf_DeployDrop]' 
END

GO



/****** Object:  UserDefinedAggregate [dbo].[dbaudf_Concatenate]    Script Date: 09/15/2011 16:25:11 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Concatenate]') AND type = N'AF')
EXEC dbo.sp_executesql @statement =
N'CREATE AGGREGATE [dbo].[dbaudf_Concatenate]
(@value [nvarchar](4000))
RETURNS[nvarchar](4000)
EXTERNAL NAME [GettyImages.Operations.CLRTools].[dbaudf_Concatenate]
'
GO

/****** Object:  UserDefinedAggregate [dbo].[dbaudf_ConcatenateUnique]    Script Date: 09/15/2011 16:25:11 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_ConcatenateUnique]') AND type = N'AF')
EXEC dbo.sp_executesql @statement =
N'CREATE AGGREGATE [dbo].[dbaudf_ConcatenateUnique]
(@value [nvarchar](4000))
RETURNS[nvarchar](4000)
EXTERNAL NAME [GettyImages.Operations.CLRTools].[dbaudf_ConcatenateUnique]
'
GO


/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetAllEVs]    Script Date: 09/15/2011 16:27:38 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetAllEVs]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_GetAllEVs]()
RETURNS  TABLE (
	[Name] [nvarchar](400) NULL,
	[Value] [nvarchar](4000) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[UserDefinedFunctions].[dbaudf_GetAllEVs]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Sharepoint_GetCalendarItems]    Script Date: 09/15/2011 16:27:39 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Sharepoint_GetCalendarItems]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_Sharepoint_GetCalendarItems](@url [nvarchar](4000), @listName [nvarchar](4000))
RETURNS  TABLE (
	[EventDate] [nvarchar](100) NULL,
	[Title] [nvarchar](4000) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.SharePointCalendar].[dbaudf_Sharepoint_GetCalendarItems]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Sharepoint_GetListCollection]    Script Date: 09/15/2011 16:27:39 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Sharepoint_GetListCollection]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_Sharepoint_GetListCollection](@url [nvarchar](4000))
RETURNS  TABLE (
	[Name] [nvarchar](4000) NULL,
	[Title] [nvarchar](4000) NULL,
	[URL] [nvarchar](4000) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.SharePointList].[dbaudf_Sharepoint_GetListCollection]' 
END

GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'Version' , N'SCHEMA',N'dbo', N'FUNCTION',N'dbaudf_Sharepoint_GetListCollection', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'Version', @value=N'1.0.0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'dbaudf_Sharepoint_GetListCollection'
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_StringToTable]    Script Date: 09/15/2011 16:27:40 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_StringToTable]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_StringToTable](@input [nvarchar](4000), @separator [nvarchar](4000))
RETURNS  TABLE (
	[OccurenceId] [int] NULL,
	[SplitValue] [nvarchar](400) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[UserDefinedFunctions].[dbaudf_StringToTable]' 
END

GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'Version' , N'SCHEMA',N'dbo', N'FUNCTION',N'dbaudf_StringToTable', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'Version', @value=N'1.0.0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'dbaudf_StringToTable'
GO

USE [dbaadmin]
GO


/****** Object:  UserDefinedFunction [dbo].[dbaudf_Filter_Alpha]    Script Date: 09/15/2011 16:39:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Filter_Alpha]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_Filter_Alpha](@filenameToCheck [nvarchar](4000), @ReplacementCharacter [nchar](1))
RETURNS [nvarchar](4000) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.UserDefinedFunctions].[dbaudf_Filter_Alpha]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Filter_AlphaNumeric]    Script Date: 09/15/2011 16:39:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Filter_AlphaNumeric]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_Filter_AlphaNumeric](@filenameToCheck [nvarchar](4000), @ReplacementCharacter [nchar](1))
RETURNS [nvarchar](4000) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.UserDefinedFunctions].[dbaudf_Filter_AlphaNumeric]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Filter_Numeric]    Script Date: 09/15/2011 16:39:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Filter_Numeric]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_Filter_Numeric](@filenameToCheck [nvarchar](4000), @ReplacementCharacter [nchar](1))
RETURNS [nvarchar](4000) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.UserDefinedFunctions].[dbaudf_Filter_Numeric]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Filter_ValidFileName]    Script Date: 09/15/2011 16:39:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Filter_ValidFileName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_Filter_ValidFileName](@filenameToCheck [nvarchar](4000), @ReplacementCharacter [nchar](1))
RETURNS [nvarchar](4000) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.UserDefinedFunctions].[dbaudf_Filter_ValidFileName]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_FormatString]    Script Date: 09/15/2011 16:39:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_FormatString]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_FormatString](@format [nvarchar](4000), @var01 [nvarchar](4000), @var02 [nvarchar](4000), @var03 [nvarchar](4000), @var04 [nvarchar](4000), @var05 [nvarchar](4000), @var06 [nvarchar](4000), @var07 [nvarchar](4000), @var08 [nvarchar](4000), @var09 [nvarchar](4000), @var10 [nvarchar](4000))
RETURNS [nvarchar](4000) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.UserDefinedFunctions].[dbaudf_FormatString]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_FrameworkVersion]    Script Date: 09/15/2011 16:39:50 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_FrameworkVersion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_FrameworkVersion]()
RETURNS [nvarchar](4000) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.UserDefinedFunctions].[dbaudf_FrameworkVersion]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetEV]    Script Date: 09/15/2011 16:39:50 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetEV]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_GetEV](@EVname [nvarchar](4000))
RETURNS [nvarchar](4000) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[UserDefinedFunctions].[dbaudf_GetEV]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetSharePath]    Script Date: 09/15/2011 16:39:50 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetSharePath]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_GetSharePath](@unc [nvarchar](4000))
RETURNS [nvarchar](4000) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.UserDefinedFunctions].[dbaudf_GetSharePath]' 
END

GO


/****** Object:  UserDefinedFunction [dbo].[dbaudf_LoadFile]    Script Date: 09/15/2011 16:39:50 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_LoadFile]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_LoadFile](@filename [nvarchar](4000))
RETURNS [varbinary](8000) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools.net35].[UserDefinedFunctions].[dbaudf_LoadFile]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_SendTweet]    Script Date: 09/15/2011 16:39:50 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_SendTweet]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_SendTweet](@userName [nvarchar](4000), @password [nvarchar](4000), @status [nvarchar](4000))
RETURNS [nvarchar](4000) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.UserDefinedFunctions].[dbaudf_SendTweet]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_SetEV]    Script Date: 09/15/2011 16:39:50 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_SetEV]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_SetEV](@EVname [nvarchar](4000), @EVvalue [nvarchar](4000))
RETURNS [nvarchar](4000) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools].[UserDefinedFunctions].[dbaudf_SetEV]' 
END

GO

