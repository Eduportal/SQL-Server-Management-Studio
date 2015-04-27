USE [dbaadmin]
GO

/****** Object:  UserDefinedAggregate [dbo].[dbaudf_Concatenate]    Script Date: 05/24/2010 21:59:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Concatenate]') AND type = N'AF')
DROP AGGREGATE [dbo].[dbaudf_Concatenate]

GO

/****** Object:  StoredProcedure [dbo].[dbasp_FileCompare]    Script Date: 05/24/2010 21:59:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_FileCompare]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_FileCompare]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_FTP_Get]    Script Date: 05/24/2010 21:59:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_FTP_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_FTP_Get]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_FTP_Put]    Script Date: 05/24/2010 21:59:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_FTP_Put]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_FTP_Put]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Filter_Alpha]    Script Date: 05/24/2010 21:59:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Filter_Alpha]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_Filter_Alpha]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Filter_AlphaNumeric]    Script Date: 05/24/2010 21:59:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Filter_AlphaNumeric]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_Filter_AlphaNumeric]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Filter_Numeric]    Script Date: 05/24/2010 21:59:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Filter_Numeric]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_Filter_Numeric]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Filter_ValidFileName]    Script Date: 05/24/2010 21:59:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Filter_ValidFileName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_Filter_ValidFileName]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetEV]    Script Date: 05/24/2010 21:59:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetEV]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_GetEV]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetSharePath]    Script Date: 05/24/2010 21:59:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetSharePath]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_GetSharePath]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_SendTweet]    Script Date: 05/24/2010 21:59:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_SendTweet]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_SendTweet]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_SetEV]    Script Date: 05/24/2010 21:59:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_SetEV]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_SetEV]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetAllEVs]    Script Date: 05/24/2010 21:59:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetAllEVs]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_GetAllEVs]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_StringToTable]    Script Date: 05/24/2010 21:59:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_StringToTable]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_StringToTable]
GO

/****** Object:  SqlAssembly [GettyImages.Operations.CLRTools]    Script Date: 05/24/2010 21:59:51 ******/
IF  EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'GettyImages.Operations.CLRTools')
DROP ASSEMBLY [GettyImages.Operations.CLRTools]

GO


