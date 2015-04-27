USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_DirectoryCompare]    Script Date: 05/13/2010 11:34:11 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_DirectoryCompare]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_DirectoryCompare](@pathA [nvarchar](4000), @pathB [nvarchar](4000))
RETURNS  TABLE (
	[FileName] [nvarchar](255) NULL,
	[RelativePath] [nvarchar](4000) NULL,
	[Comparison] [nvarchar](50) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.OperationsCLRTools].[UserDefinedFunctions].[dbaudf_DirectoryCompare]' 
END

GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'AutoDeployed' , N'SCHEMA',N'dbo', N'FUNCTION',N'dbaudf_DirectoryCompare', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'AutoDeployed', @value=N'yes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'dbaudf_DirectoryCompare'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'SqlAssemblyFile' , N'SCHEMA',N'dbo', N'FUNCTION',N'dbaudf_DirectoryCompare', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'SqlAssemblyFile', @value=N'DirectoryCompare.cs' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'dbaudf_DirectoryCompare'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'SqlAssemblyFileLine' , N'SCHEMA',N'dbo', N'FUNCTION',N'dbaudf_DirectoryCompare', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'SqlAssemblyFileLine', @value=51 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'dbaudf_DirectoryCompare'
GO


