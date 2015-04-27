USE [dbaadmin]
GO


IF OBJECT_ID('dbaudf_BackupScripter_GetHeaderList') IS NOT NULL
	DROP FUNCTION dbaudf_BackupScripter_GetHeaderList
GO
CREATE FUNCTION dbaudf_BackupScripter_GetHeaderList
		(
		@SetSize		INT
		,@FileName		VarChar(MAX)
		,@FullPathName		VarChar(MAX)
		)

RETURNS TABLE AS RETURN
(

	SELECT		*
			,CASE WHEN @SetSize > 1 THEN @FileName ELSE @FullPathName END [BackupFileName]
	FROM		[dbaadmin].[dbo].[dbaudf_RestoreHeader](@FullPathName) 

)
GO
