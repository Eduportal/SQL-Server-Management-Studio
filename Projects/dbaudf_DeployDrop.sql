USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_DeployDrop]    Script Date: 05/24/2010 17:36:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_DeployDrop]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_DeployDrop]
GO

USE [dbaadmin]
GO
CREATE FUNCTION [dbo].[dbaudf_DeployDrop]
	(
	@Folder [nvarchar](4000)
	, @command [nvarchar](4000)
	, @fileName [nvarchar](4000)
	, @ticketType [nvarchar](4000)
	, @ticketNumber [nvarchar](4000)
	, @SQLname [nvarchar](4000)
	, @login [nvarchar](4000)
	, @password [nvarchar](4000)
	)
RETURNS [Varbinary](max) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [GettyImages.Operations.CLRTools.net35].[UserDefinedFunctions].[dbaudf_DeployDrop]
GO


