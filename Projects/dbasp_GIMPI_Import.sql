USE [DBAperf_reports]
GO
/****** Object:  StoredProcedure [dbo].[dbasp_GIMPI_Import]    Script Date: 10/15/2014 12:10:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC	[dbo].[dbasp_GIMPI_Import]
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @Script			nVarChar(4000)
	,@PARAM			nVarChar(4000)
	,@Path			VarChar(8000)
	,@Path2			VarChar(8000)
	,@FileName		VarChar(4000)
	,@Import_Destination	sysname
	,@Server_Name		sysname
	,@Database_Name		sysname
	,@Schema_Name		sysname
	,@Table_Name		sysname
	,@DateLastModified	varchar(2048)
	,@outpath		varchar(255)
	,@LocalShareShortName	sysname
	,@LocalShareSubDir	sysname
	,@RunDate		DateTime
	,@Size			bigint
	,@rslt			int

IF OBJECT_ID('[dbo].[IndexHealth_Results]') IS NULL
BEGIN
	EXEC ('CREATE TABLE [dbo].[IndexHealth_Results]
		(
		[rundate] [datetime] NOT NULL,
		[ServerName] [nvarchar](128) NOT NULL,
		[DatabaseName] [nvarchar](128) NOT NULL,
		[SchemaName] [nvarchar](128) NULL,
		[TableName] [nvarchar](128) NULL,
		[IHCR_id] [int] NOT NULL,
		[check_id] [int] NOT NULL,
		[findings_group] [varchar](4000) NOT NULL,
		[finding] [varchar](200) NOT NULL,
		[URL] [varchar](200) NOT NULL,
		[details] [nvarchar](4000) NOT NULL,
		[index_definition] [nvarchar](max) NOT NULL,
		[secret_columns] [nvarchar](max) NULL,
		[index_usage_summary] [nvarchar](max) NULL,
		[index_size_summary] [nvarchar](max) NULL,
		[create_tsql] [nvarchar](max) NULL,
		[more_info] [nvarchar](max) NULL,
		[database_id] [smallint] NULL,
		[object_id] [int] NULL,
		[index_id] [int] NULL,
		[index_type] [tinyint] NULL,
		[database_name] [nvarchar](128) NULL,
		[schema_name] [nvarchar](128) NULL,
		[object_name] [nvarchar](128) NULL,
		[index_name] [nvarchar](128) NULL,
		[key_column_names] [nvarchar](max) NULL,
		[key_column_names_with_sort_order] [nvarchar](max) NULL,
		[key_column_names_with_sort_order_no_types] [nvarchar](max) NULL,
		[count_key_columns] [int] NULL,
		[include_column_names] [nvarchar](max) NULL,
		[include_column_names_no_types] [nvarchar](max) NULL,
		[count_included_columns] [int] NULL,
		[partition_key_column_name] [nvarchar](max) NULL,
		[filter_definition] [nvarchar](max) NULL,
		[is_indexed_view] [bit] NULL,
		[is_unique] [bit] NULL,
		[is_primary_key] [bit] NULL,
		[is_XML] [bit] NULL,
		[is_spatial] [bit] NULL,
		[is_NC_columnstore] [bit] NULL,
		[is_CX_columnstore] [bit] NULL,
		[is_disabled] [bit] NULL,
		[is_hypothetical] [bit] NULL,
		[is_padded] [bit] NULL,
		[fill_factor] [smallint] NULL,
		[user_seeks] [bigint] NULL,
		[user_scans] [bigint] NULL,
		[user_lookups] [bigint] NULL,
		[user_updates] [bigint] NULL,
		[last_user_seek] [datetime] NULL,
		[last_user_scan] [datetime] NULL,
		[last_user_lookup] [datetime] NULL,
		[last_user_update] [datetime] NULL,
		[is_referenced_by_foreign_key] [bit] NULL,
		[secret_columns_2] [nvarchar](max) NULL,
		[count_secret_columns] [int] NULL,
		[create_date] [datetime] NULL,
		[modify_date] [datetime] NULL,
		[create_tsql_2] [nvarchar](max) NULL,
		[stat_date] [datetime] NULL
		)')

		ALTER TABLE [dbo].[IndexHealth_Results] ADD  CONSTRAINT [PK_IndexHealth_Results] PRIMARY KEY CLUSTERED 
		(
			[rundate] ASC,
			[ServerName] ASC,
			[DatabaseName] ASC,
			[IHCR_id] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	END

SELECT	@LocalShareShortName	= 'dbasql' -- ONLY USE SHORT NAME
	,@LocalShareSubDir	= 'IndexAnalysis'

-- GET FULL SHARE PATH FROM SHORN NAME
SELECT @Path = dbaadmin.dbo.dbaudf_getShareUNC(@LocalShareShortName) 

-- CHECK IF SHARE IS VALID
IF [dbaadmin].[dbo].[dbaudf_GetFileProperty]
	(
	@Path
	,'Folder'
	,'FullName'
	) IS NULL
BEGIN	-- SHARE BAD

	PRINT '"'+@LocalShareShortName+'" Share Does Not Exist at ' + @Path
	--RETURN -1
END
ELSE
BEGIN	-- SHARE GOOD

	PRINT '"'+@LocalShareShortName+'" Share Exist at ' + @Path
	
	-- CHECK IF SUB DIRECTORY EXISTS UNDER SHARE
	SET @Path2 = @Path +'\' + @LocalShareSubDir
	IF [dbaadmin].[dbo].[dbaudf_GetFileProperty]
		(
		@Path2
		,'Folder'
		,'FullName'
		) IS NULL
	BEGIN	--SUBDIR BAD
	
		PRINT '"IndexAnalysis" Directory does not exist under ' + @Path
		
		-- Convert Share Path to Drive Letter Path (MKDIR NEED DRIVE PATH INSTEAD OF SHARE PATH)
		SELECT @Path = [dbaadmin].[dbo].[dbaudf_GetSharePath] (@Path)
		
		-- Create Directory
		set @Script = 'MkDir '+ @Path2
		exec master..xp_cmdshell @Script, NO_OUTPUT

		-- CHECK IF DIRECTORY WAS CREATED
		IF [dbaadmin].[dbo].[dbaudf_GetFileProperty]
			(
			@Path2
			,'Folder'
			,'FullName'
			) IS NULL
		BEGIN	-- SUBDIR BAD
		
			PRINT 'Directory Could Not be Created at ' + @Path2
			--RETURN -1
		END
		PRINT 'Directory Was Created at ' + @Path2
		PRINT ''
		PRINT 'Since Directory was just Created, There will be no files to import so quititng now.'
		PRINT 'Nothing to Process..'
		--RETURN 0
	END
	ELSE
		PRINT 'Directory Exists at ' + @Path2
END

-- RESET PATH VARIABLE TO SHARE PATH AND SUB DIRECTORY
SELECT @Path = dbaadmin.dbo.dbaudf_getShareUNC(@LocalShareShortName) + '\' + @LocalShareSubDir


DECLARE @RunCount INT

SET @RunCount = 0
--CREATE TABLE #DirectoryListing (ln nvarchar(4000))

--set @Script = 'DIR '+@Path+'\'+'*.DAT /b'
--Insert #DirectoryListing exec master..xp_cmdshell @Script

--delete from #DirectoryListing
--where	ln is NULL
-- or	ln like 'File Not Found'
-- =============================================
-- READ FILES INTO TABLES
-- =============================================
RAISERROR('Starting Import Loop',-1,-1) WITH NOWAIT
DECLARE	ImportFileCursor CURSOR 
FOR
SELECT	Name,DateModified,Size
FROM	dbaadmin.dbo.dbaudf_DirectoryList(@Path,'*.dat')
WHERE IsFolder = 0
ORDER BY DateModified
OPEN ImportFileCursor
FETCH NEXT FROM ImportFileCursor INTO @FileName,@DateLastModified,@Size
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		RAISERROR('Starting ON %s',-1,-1,@FileName) WITH NOWAIT
		--select @DateLastModified = dbaadmin.dbo.dbaudf_GetFileProperty(@Path+'\'+@FileName,'File','LastWriteTime')
		--IF @DateLastModified < GetDate()-30
		--BEGIN
		--	FETCH NEXT FROM ImportFileCursor INTO @FileName
		--	CONTINUE
		--END		
		
		PRINT [dbaadmin].[dbo].[dbaudf_base64_decode] (LEFT(REPLACE(@FileName,'$','='),LEN(@FileName)-4)) + '  (' 
		+ CASE 
			WHEN @Size < power(1024.0,1) THEN [dbaadmin].[dbo].[dbaudf_FormatNumber](@Size,8,2) + 'B)'
			WHEN @Size < power(1024.0,2) THEN [dbaadmin].[dbo].[dbaudf_FormatNumber](@Size/power(1024.0,1),8,2) + 'KB)'
			WHEN @Size < power(1024.0,3) THEN [dbaadmin].[dbo].[dbaudf_FormatNumber](@Size/power(1024.0,2),8,2) + 'MB)'
			ELSE [dbaadmin].[dbo].[dbaudf_FormatNumber](@Size/power(1024.0,3),8,2) + 'GB)'
			END
		
		SELECT	@Server_Name		= REPLACE([dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[dbaudf_base64_decode] (LEFT(REPLACE(@FileName,'$','='),LEN(@FileName)-4)),1),'$','\')
			,@Import_Destination	= [dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[dbaudf_base64_decode] (LEFT(REPLACE(@FileName,'$','='),LEN(@FileName)-4)),2)
			,@Database_Name		= NULLIF([dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[dbaudf_base64_decode] (LEFT(REPLACE(@FileName,'$','='),LEN(@FileName)-4)),3),'NULL')
			,@Schema_Name		= NULLIF([dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[dbaudf_base64_decode] (LEFT(REPLACE(@FileName,'$','='),LEN(@FileName)-4)),4),'NULL')
			,@Table_Name		= NULLIF([dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[dbaudf_base64_decode] (LEFT(REPLACE(@FileName,'$','='),LEN(@FileName)-4)),5),'NULL')
			,@RunDate		= NULLIF([dbaadmin].[dbo].[ReturnPart] ([dbaadmin].[dbo].[dbaudf_base64_decode] (LEFT(REPLACE(@FileName,'$','='),LEN(@FileName)-4)),6),'NULL')
			,@Script		= CONVERT(VarChar(10),@RunDate,101)

		RAISERROR('  Import to Table:%s From Server:%s Database:%s for Rundate:%s',-1,-1,@Import_Destination,@Server_Name,@Database_Name,@Script) WITH NOWAIT

		IF OBJECT_ID(@Import_Destination) IS NULL
			GOTO SkipImport

		RAISERROR('    Delete Existing Records',-1,-1) WITH NOWAIT
		IF @Import_Destination = 'IndexHealth_Results'
		BEGIN
			SET @PARAM	= '@Server_Name sysname, @Database_Name sysname, @Schema_Name sysname, @Table_Name sysname, @RunDate datetime'
			SET @Script	= 'DELETE ' + QuoteName(@Import_Destination)+ CHAR(13)+CHAR(10) 
					+ 'WHERE ([ServerName] = @Server_Name)'+ CHAR(13)+CHAR(10)
					+ 'AND ([DatabaseName] = @Database_Name OR @Database_Name IS NULL)'+ CHAR(13)+CHAR(10)
					+ 'AND ([SchemaName] = @Schema_Name OR @Schema_Name IS NULL)'+ CHAR(13)+CHAR(10)
					+ 'AND ([TableName] = @Table_Name OR @Table_Name IS NULL)'+ CHAR(13)+CHAR(10)
					+ CASE @Import_Destination
						WHEN 'IndexHealth_Results' THEN 'AND ([rundate] = @RunDate OR @RunDate IS NULL)'+ CHAR(13)+CHAR(10)
						ELSE ''
						END
			EXEC sp_executesql 
				@Script
				,@PARAM
				,@Server_Name
				,@Database_Name
				,@Schema_Name
				,@Table_Name
				,@RunDate

		END
		ELSE
		BEGIN
			SET @PARAM	= '@Server_Name sysname, @Database_Name sysname, @Schema_Name sysname, @Table_Name sysname'
			SET @Script	= 'DELETE ' + QuoteName(@Import_Destination)+ CHAR(13)+CHAR(10) 
					+ 'WHERE ([Server_Name] = @Server_Name)'+ CHAR(13)+CHAR(10)
					+ 'AND ([Database_Name] = @Database_Name OR @Database_Name IS NULL)'+ CHAR(13)+CHAR(10)
					+ 'AND ([Schema_Name] = @Schema_Name OR @Schema_Name IS NULL)'+ CHAR(13)+CHAR(10)
					+ 'AND ([Table_Name] = @Table_Name OR @Table_Name IS NULL)'+ CHAR(13)+CHAR(10)
				 
			EXEC sp_executesql 
				@Script
				,@PARAM
				,@Server_Name
				,@Database_Name
				,@Schema_Name
				,@Table_Name
		END

		
		SET @Script	= 'bcp DBAperf_reports.dbo.'+@Import_Destination+' in "'+@Path+'\'+@FileName+'" -T -N -e'

		DECLARE @Output TABLE (OutputMessage NVARCHAR(4000));

		RAISERROR('    BCP File With: %s',-1,-1,@Script) WITH NOWAIT
		INSERT INTO @Output
		EXEC xp_cmdshell @Script			
		
		PRINT ''
		PRINT '-------------------------------------------------------------------------------------------------------'
		PRINT 'Processed File:     ' + @Path+'\'+@FileName
		PRINT 'Server:             '+@Server_Name	
		PRINT 'Import_Destination: '+@Import_Destination
		PRINT 'Database:           '+@Database_Name		
		PRINT 'Schema:             '+@Schema_Name		
		PRINT 'Table:              '+@Table_Name		
		PRINT '-------------------------------------------------------------------------------------------------------'
		RAISERROR('',-1,-1) WITH NOWAIT
		
		IF EXISTS (SELECT OutputMessage FROM @Output WHERE OutputMessage Like '%Error = %')
		BEGIN
			DELETE FROM @Output WHERE OutputMessage IS NULL
			SELECT * FROM @Output
			RAISERROR('      Import Failed, File will not be deleted.',-1,-1) WITH NOWAIT
		END
		ELSE
		BEGIN
			-- DELETE FILE AFTER READING
			RAISERROR('    Delete File',-1,-1) WITH NOWAIT
			SET @Script = 'DEL "'+ @Path+'\'+@FileName+'"'
			exec master..xp_cmdshell @Script, no_output
		END
	
	SET @RunCount = @RunCount + 1

	SkipImport:
	
	END
	FETCH NEXT FROM ImportFileCursor INTO @FileName,@DateLastModified,@Size
END
CLOSE ImportFileCursor
DEALLOCATE ImportFileCursor
-- =============================================
-- READ FILES INTO TABLES
-- =============================================


--DROP TABLE #DirectoryListing

IF @RunCount = 0 
	PRINT 'Nothing to Process..'
ELSE
	PRINT 'Processed '+CAST(@RunCount AS VarChar(10))+' Files.'
