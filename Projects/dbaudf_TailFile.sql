USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_TailFile]    Script Date: 02/26/2013 09:27:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_TailFile]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_TailFile]
GO

USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_TailFile]    Script Date: 02/26/2013 09:27:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   FUNCTION [dbo].[dbaudf_TailFile]  
						(
						@Path		VARCHAR(4000)
						,@Filename	VARCHAR(1024)	= NULL -- CAN BE NULL IF PASSING THE FILENAME AS PART OF THE PATH
						,@TailSize	INT				 = 0
						) 
RETURNS VarChar(MAX) 
AS 
BEGIN 
	DECLARE	@File VarChar(max)
	SET		@File = ''

	SELECT		@File = @File + CAST([Lineno] AS Char(10)) + [line] + CHAR(13) + CHAR(10)
	FROM		(
				SELECT		TOP 100 PERCENT
							*
				FROM		(
							SELECT		TOP (@TailSize)
										*
							FROM		dbaadmin.dbo.dbaudf_FileAccess_Read(@Path,@Filename)
							ORDER BY	[LineNo] DESC
							) Document
				ORDER BY	[LineNo]
				) Document

	RETURN @File
END 


GO


