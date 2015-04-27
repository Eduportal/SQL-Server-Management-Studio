USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_DeployDrop]    Script Date: 09/15/2011 11:55:16 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_DeployDrop]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_DeployDrop]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_DirectoryCompare]    Script Date: 09/15/2011 11:55:16 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_DirectoryCompare]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_DirectoryCompare]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_LoadFile]    Script Date: 09/15/2011 11:55:16 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_LoadFile]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_LoadFile]
GO

/****** Object:  SqlAssembly [GettyImages.Operations.CLRTools.net35]    Script Date: 09/15/2011 11:55:16 ******/
IF  EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'GettyImages.Operations.CLRTools.net35' and is_user_defined = 1)
DROP ASSEMBLY [GettyImages.Operations.CLRTools.net35]

GO

/****** Object:  SqlAssembly [System.Core]    Script Date: 09/15/2011 11:55:16 ******/
IF  EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'System.Core' and is_user_defined = 1)
DROP ASSEMBLY [System.Core]

GO

USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbo].[CommunicatorTest]    Script Date: 09/15/2011 11:56:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CommunicatorTest]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[CommunicatorTest]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_DiskSpace]    Script Date: 09/15/2011 11:56:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_DiskSpace]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_DiskSpace]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_FileCompare]    Script Date: 09/15/2011 11:56:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_FileCompare]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_FileCompare]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_FTP_Get]    Script Date: 09/15/2011 11:56:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_FTP_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_FTP_Get]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_FTP_Put]    Script Date: 09/15/2011 11:56:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_FTP_Put]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_FTP_Put]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_ReadFile]    Script Date: 09/15/2011 11:56:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_ReadFile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_ReadFile]
GO

/****** Object:  UserDefinedAggregate [dbo].[dbaudf_Concatenate]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Concatenate]') AND type = N'AF')
DROP AGGREGATE [dbo].[dbaudf_Concatenate]

GO

/****** Object:  UserDefinedAggregate [dbo].[dbaudf_ConcatenateUnique]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_ConcatenateUnique]') AND type = N'AF')
DROP AGGREGATE [dbo].[dbaudf_ConcatenateUnique]

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAdjacentCalendar]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAdjacentCalendar]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetAdjacentCalendar]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAdjacentCalendarBase]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAdjacentCalendarBase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetAdjacentCalendarBase]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAdjacentCalendarSingle]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAdjacentCalendarSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetAdjacentCalendarSingle]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAttachment]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAttachment]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetAttachment]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAttachmentBase]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAttachmentBase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetAttachmentBase]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAttachmentSingle]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAttachmentSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetAttachmentSingle]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAttendeeCalendar]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAttendeeCalendar]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetAttendeeCalendar]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAttendeeCalendarBase]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAttendeeCalendarBase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetAttendeeCalendarBase]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAttendeeCalendarSingle]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAttendeeCalendarSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetAttendeeCalendarSingle]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetAvailability]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetAvailability]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetAvailability]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetCalendar]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetCalendar]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetCalendar]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetCalendarBase]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetCalendarBase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetCalendarBase]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetConflictingCalendar]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetConflictingCalendar]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetConflictingCalendar]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetConflictingCalendarBase]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetConflictingCalendarBase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetConflictingCalendarBase]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetConflictingCalendarSingle]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetConflictingCalendarSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetConflictingCalendarSingle]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContacts]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContacts]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetContacts]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsAddress]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsAddress]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetContactsAddress]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsAddressSingle]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsAddressSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetContactsAddressSingle]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsEmail]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsEmail]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetContactsEmail]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsEmailSingle]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsEmailSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetContactsEmailSingle]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsIM]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsIM]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetContactsIM]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsIMSingle]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsIMSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetContactsIMSingle]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsPhone]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsPhone]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetContactsPhone]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetContactsPhoneSingle]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetContactsPhoneSingle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetContactsPhoneSingle]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_exchange_GetInbox]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_exchange_GetInbox]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_exchange_GetInbox]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Filter_Alpha]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Filter_Alpha]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_Filter_Alpha]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Filter_AlphaNumeric]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Filter_AlphaNumeric]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_Filter_AlphaNumeric]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Filter_Numeric]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Filter_Numeric]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_Filter_Numeric]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Filter_ValidFileName]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Filter_ValidFileName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_Filter_ValidFileName]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_FormatString]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_FormatString]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_FormatString]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_FrameworkVersion]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_FrameworkVersion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_FrameworkVersion]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetAllEVs]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetAllEVs]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_GetAllEVs]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetEV]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetEV]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_GetEV]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetSharePath]    Script Date: 09/15/2011 11:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetSharePath]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_GetSharePath]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_SendTweet]    Script Date: 09/15/2011 11:56:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_SendTweet]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_SendTweet]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_SetEV]    Script Date: 09/15/2011 11:56:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_SetEV]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_SetEV]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Sharepoint_GetCalendarItems]    Script Date: 09/15/2011 11:56:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Sharepoint_GetCalendarItems]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_Sharepoint_GetCalendarItems]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Sharepoint_GetListCollection]    Script Date: 09/15/2011 11:56:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Sharepoint_GetListCollection]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_Sharepoint_GetListCollection]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_StringToTable]    Script Date: 09/15/2011 11:56:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_StringToTable]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_StringToTable]
GO

/****** Object:  StoredProcedure [dbo].[dbaudf_UnlockAndDeleteFile]    Script Date: 09/15/2011 11:56:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_UnlockAndDeleteFile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbaudf_UnlockAndDeleteFile]
GO

/****** Object:  SqlAssembly [GettyImages.Operations.CLRTools]    Script Date: 09/15/2011 11:56:07 ******/
IF  EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'GettyImages.Operations.CLRTools' and is_user_defined = 1)
DROP ASSEMBLY [GettyImages.Operations.CLRTools]

GO

USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Gather_PerformanceStats]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Gather_PerformanceStats]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Gather_PerformanceStats]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Gather_Wait_Stats]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Gather_Wait_Stats]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Gather_Wait_Stats]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Allsps]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Allsps]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Allsps]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Blocked_Processes]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Blocked_Processes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Blocked_Processes]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Blocked_Sessions]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Blocked_Sessions]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Blocked_Sessions]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_CPU_Top4]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_CPU_Top4]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_CPU_Top4]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_CPU_Utilization]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_CPU_Utilization]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_CPU_Utilization]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Dbspace_Usage]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Dbspace_Usage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Dbspace_Usage]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Dbspace_Usage_All]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Dbspace_Usage_All]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Dbspace_Usage_All]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Dbspace_Usage_Sumall]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Dbspace_Usage_Sumall]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Dbspace_Usage_Sumall]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_DiskSpace]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_DiskSpace]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_DiskSpace]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Execution_TopFNs]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Execution_TopFNs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Execution_TopFNs]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Execution_TopSPs]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Execution_TopSPs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Execution_TopSPs]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Failed_Sqlagent_Jobs]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Failed_Sqlagent_Jobs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Failed_Sqlagent_Jobs]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Failed_Sqlagent_Jobs_Day]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Failed_Sqlagent_Jobs_Day]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Failed_Sqlagent_Jobs_Day]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_IndexFrag]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_IndexFrag]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_IndexFrag]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_IO_Top4]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_IO_Top4]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_IO_Top4]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_JobFailureTotals]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_JobFailureTotals]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_JobFailureTotals]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_MissingIndexes]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_MissingIndexes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_MissingIndexes]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_MissingIndexesDB]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_MissingIndexesDB]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_MissingIndexesDB]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_PerformanceCounters]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_PerformanceCounters]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_PerformanceCounters]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_RecentBackups]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_RecentBackups]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_RecentBackups]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_RecordCounts]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_RecordCounts]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_RecordCounts]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_SQLAgent_Jobs_Run]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_SQLAgent_Jobs_Run]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_SQLAgent_Jobs_Run]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_SQLAgent_Jobs_Stats]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_SQLAgent_Jobs_Stats]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_SQLAgent_Jobs_Stats]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_SQLAgent_Status]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_SQLAgent_Status]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_SQLAgent_Status]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TablesWithoutAnyIndexes]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TablesWithoutAnyIndexes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_TablesWithoutAnyIndexes]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TablesWithoutClusteredIndexes]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TablesWithoutClusteredIndexes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_TablesWithoutClusteredIndexes]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TablesWithoutPKs]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TablesWithoutPKs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_TablesWithoutPKs]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TablesWithPKs]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TablesWithPKs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_TablesWithPKs]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TasksWaitingToRun]    Script Date: 09/15/2011 11:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TasksWaitingToRun]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_TasksWaitingToRun]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Top5IO_DB]    Script Date: 09/15/2011 11:56:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Top5IO_DB]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Top5IO_DB]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TopCPU]    Script Date: 09/15/2011 11:56:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TopCPU]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_TopCPU]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TopElapsed]    Script Date: 09/15/2011 11:56:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TopElapsed]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_TopElapsed]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TopIO]    Script Date: 09/15/2011 11:56:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TopIO]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_TopIO]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TopIO_DB]    Script Date: 09/15/2011 11:56:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TopIO_DB]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_TopIO_DB]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_TopIOSPs]    Script Date: 09/15/2011 11:56:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_TopIOSPs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_TopIOSPs]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Unused_Indexes]    Script Date: 09/15/2011 11:56:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Unused_Indexes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Unused_Indexes]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Wait_Stat_Percentage]    Script Date: 09/15/2011 11:56:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Wait_Stat_Percentage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Wait_Stat_Percentage]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_Get_Wait_Stats]    Script Date: 09/15/2011 11:56:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_Get_Wait_Stats]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_Get_Wait_Stats]
GO

/****** Object:  SqlAssembly [DBA_Dashboard]    Script Date: 09/15/2011 11:56:31 ******/
IF  EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'DBA_Dashboard' and is_user_defined = 1)
DROP ASSEMBLY [DBA_Dashboard]

GO


