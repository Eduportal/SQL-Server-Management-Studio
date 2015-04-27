USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_CLR_Split]    Script Date: 05/13/2010 11:33:40 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_CLR_Split]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_CLR_Split](@input [nvarchar](4000), @separator [nvarchar](4000))
RETURNS  TABLE (
	[Ordinal] [int] NULL,
	[Value] [nvarchar](max) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [Functions.String].[Microsoft.Sql.InternalTools.Sql.Functions.String.UserDefinedFunctions].[Split]' 
END

GO


