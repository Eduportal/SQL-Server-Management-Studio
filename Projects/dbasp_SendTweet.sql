USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_SendTweet]    Script Date: 05/13/2010 11:32:19 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_SendTweet]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dbasp_SendTweet]
	@TwitterUser [nvarchar](4000),
	@TwitterPass [nvarchar](4000),
	@message [nvarchar](4000)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [GettyImages.OperationsCLRTools].[StoredProcedures].[dbasp_SendTweet]' 
END
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'AutoDeployed' , N'SCHEMA',N'dbo', N'PROCEDURE',N'dbasp_SendTweet', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'AutoDeployed', @value=N'yes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'dbasp_SendTweet'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'SqlAssemblyFile' , N'SCHEMA',N'dbo', N'PROCEDURE',N'dbasp_SendTweet', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'SqlAssemblyFile', @value=N'SendTweet.cs' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'dbasp_SendTweet'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'SqlAssemblyFileLine' , N'SCHEMA',N'dbo', N'PROCEDURE',N'dbasp_SendTweet', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'SqlAssemblyFileLine', @value=20 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'dbasp_SendTweet'
GO


