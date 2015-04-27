USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetSharePath]    Script Date: 05/13/2010 11:47:41 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetSharePath]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_GetSharePath]
GO

USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetSharePath]    Script Date: 05/13/2010 11:47:41 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetSharePath]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_GetSharePath](@unc [nvarchar](4000))
RETURNS [nvarchar](4000) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.OperationsCLRTools].[GetSharePath.UserDefinedFunctions].[dbaudf_GetSharePath]' 
END

GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'AutoDeployed' , N'SCHEMA',N'dbo', N'FUNCTION',N'dbaudf_GetSharePath', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'AutoDeployed', @value=N'yes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'dbaudf_GetSharePath'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'SqlAssemblyFile' , N'SCHEMA',N'dbo', N'FUNCTION',N'dbaudf_GetSharePath', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'SqlAssemblyFile', @value=N'GetSharePath.cs' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'dbaudf_GetSharePath'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'SqlAssemblyFileLine' , N'SCHEMA',N'dbo', N'FUNCTION',N'dbaudf_GetSharePath', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'SqlAssemblyFileLine', @value=13 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'dbaudf_GetSharePath'
GO


