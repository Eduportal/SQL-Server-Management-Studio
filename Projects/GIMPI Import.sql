USE DBAPERF_reports
GO
SET NOCOUNT ON
GO

DECLARE @Script			nVarChar(4000)
DECLARE @PARAM		nVarChar(4000)
DECLARE @Path			VarChar(8000)
DECLARE @FileName		VarChar(4000)

DECLARE @Import_Destination	sysname
	,@Server_Name		sysname
	,@Database_Name		sysname
	,@Schema_Name		sysname
	,@Table_Name		sysname
	,@DateLastModified	varchar(2048)

SET @Path = '\\seafresqldba01\SEAFRESQLDBA01_dbasql\IndexAnalysis'

DECLARE @RunCount INT

SET @RunCount = 0
CREATE TABLE #DirectoryListing (ln nvarchar(4000))

set @Script = 'DIR '+@Path+'\'+'*.DAT /b'
Insert #DirectoryListing exec master..xp_cmdshell @Script

delete from #DirectoryListing
where	ln is NULL
 or	ln like 'File Not Found'
-- =============================================
-- READ FILES INTO TABLES
-- =============================================
DECLARE	ImportFileCursor CURSOR 
FOR
SELECT DISTINCT ln FROM #DirectoryListing
OPEN ImportFileCursor
FETCH NEXT FROM ImportFileCursor INTO @FileName
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN

		select @DateLastModified = dbaadmin.dbo.dbaudf_GetFileProperty(@Path+'\'+@FileName,'File','DateLastModified')
		IF @DateLastModified < GetDate()-30
		BEGIN
			FETCH NEXT FROM ImportFileCursor INTO @FileName
			CONTINUE
		END		
		
		SELECT	@Server_Name		= REPLACE([dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[dbasp_base64_decode] (LEFT(REPLACE(@FileName,'$','='),LEN(@FileName)-4)),1),'$','\')
			,@Import_Destination	= [dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[dbasp_base64_decode] (LEFT(REPLACE(@FileName,'$','='),LEN(@FileName)-4)),2)
			,@Database_Name		= REPLACE([dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[dbasp_base64_decode] (LEFT(REPLACE(@FileName,'$','='),LEN(@FileName)-4)),3),'NULL',NULL)
			,@Schema_Name		= REPLACE([dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[dbasp_base64_decode] (LEFT(REPLACE(@FileName,'$','='),LEN(@FileName)-4)),4),'NULL',NULL)
			,@Table_Name		= REPLACE([dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[dbasp_base64_decode] (LEFT(REPLACE(@FileName,'$','='),LEN(@FileName)-4)),5),'NULL',NULL)


		SET @PARAM	= '@Server_Name sysname, @Database_Name sysname, @Schema_Name sysname, @Table_Name sysname'
		SET @Script	= 'DELETE ' + QuoteName(@Import_Destination)+ CHAR(13)+CHAR(10) 
				+ 'WHERE ([Server_Name] = @Server_Name)'+ CHAR(13)+CHAR(10)
				+ 'AND ([Database_Name] = @Database_Name OR @Database_Name IS NULL)'+ CHAR(13)+CHAR(10)
				+ 'AND ([Schema_Name] = @Schema_Name OR @Schema_Name IS NULL)'+ CHAR(13)+CHAR(10)
				+ 'AND ([Table_Name] = @Table_Name OR @Table_Name IS NULL)'+ CHAR(13)+CHAR(10)


		SELECT	@Script
			,@PARAM
			,@Server_Name
			,@Import_Destination
			,@Database_Name
			,@Schema_Name
			,@Table_Name
				 
		EXEC sp_executesql 
			@Script
			,@PARAM
			,@Server_Name
			,@Database_Name
			,@Schema_Name
			,@Table_Name

		SET @Script	= 'bcp DBAperf_reports.dbo.'+@Import_Destination+' in "'+@Path+'\'+@FileName+'" -T -N'

		SELECT @Script
		
		EXEC xp_cmdshell
			@Script			

		PRINT 'Processed File: ' + @Path+'\'+@FileName
		
		-- DELETE FILE AFTER READING
		SET @Script = 'DEL "'+ @Path+'\'+@FileName+'"'
		--exec master..xp_cmdshell @Script, no_output
	
	SET @RunCount = @RunCount + 1
	
	END
	FETCH NEXT FROM ImportFileCursor INTO @FileName
END
CLOSE ImportFileCursor
DEALLOCATE ImportFileCursor
-- =============================================
-- READ FILES INTO TABLES
-- =============================================


DROP TABLE #DirectoryListing

IF @RunCount = 0 
	PRINT 'Nothing to Process..'
ELSE
	PRINT 'Processed '+CAST(@RunCount AS VarChar(10))+' Files.'
GO


