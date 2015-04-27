CREATE PROCEDURE [dbo].[dbasp_RelocateObject]
		(
		@SourceObject	sysname
		,@ObjectType	sysname	-- PROCS, FUNCTIONS, TABLES, VIEWS, INDEXES
		,@SourceSchema	sysname	= 'dbo'
		,@SourceDB		sysname = NULL
		,@DestServer	sysname	= NULL
		,@DestDB		sysname = NULL
		,@DestSchema	sysname = 'dbo'
		,@Tasks_CreateCopy		bit = 0
		,@Tasks_CopyData		bit = 0
		,@Tasks_DropOrigional	bit = 1
		,@Tasks_CreateSynonym	bit = 1
		)
AS
DECLARE @TSQL1 VarChar(MAX)
DECLARE @TSQL2 VarChar(MAX)
DECLARE	@SourceSVR [sys].[sysname]
DECLARE @line varchar(8000)
DECLARE @Buffer Bit

SELECT	@SourceDB		= COALESCE(@SourceDB,DB_NAME())
		,@DestServer	= COALESCE(@DestServer,@@SERVERNAME)
		,@DestDB		= COALESCE(@DestDB,DB_NAME())
		,@SourceSVR		= @@SERVERNAME

If @Tasks_CreateCopy = 1
BEGIN
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	-- CREATE COPY OF OBJECT
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	exec [dbo].[dbasp_ScriptObject]
				@SourceDB		= @SourceDB
				,@SourceObject	= @SourceObject
				,@SourceUID		=  null 				-- null for trusted connection
				,@SourcePWD		=  null 				-- null for trusted connection
				,@OutFilePath	= 'C:\' 
				,@OutFileName	= 'tempddlscript.txt'   -- null for separate file per object script
				,@ObjectType	= @ObjectType 
				,@WorkPath		= 'C:\' 
				,@SourceSVR		= 'SEAFRESQLDBA01'

	SET		@TSQL1 = 'USE [' + @DestDB +'];'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
	SET		@Buffer = 0
	DECLARE ScriptCursor CURSOR
	FOR
	SELECT	[dbo].[dbaudf_ReadfileAsTable].[line] 
	From	[dbo].[dbaudf_ReadfileAsTable] ('C:','tempddlscript.txt')

	IF		@DestServer != @@SERVERNAME
	BEGIN
		---------------------------------------------------------------------------
		---------------------------------------------------------------------------
		-- CREATE TEMPORARY LINKED SERVER IF COPY TO OTHER SERVER
		---------------------------------------------------------------------------
		---------------------------------------------------------------------------
		PRINT '  -- Adding Temporary Linked Server...'
		IF  EXISTS (SELECT srv.name FROM [sys].[servers] srv WHERE srv.server_id != 0 AND srv.name = N'TempLinkedServer')
			EXEC [master].[dbo].[sp_dropserver] @server=N'TempLinkedServer', @droplogins='droplogins'

		EXEC sp_addlinkedserver					@server			= N'TempLinkedServer' 
												, @srvproduct	= 'SQL Server'
												, @provider		= 'SQLNCLI'
												, @datasrc		= @DestServer
		EXEC master.dbo.sp_addlinkedsrvlogin	@rmtsrvname		= N'TempLinkedServer'
												, @locallogin	= NULL 
												, @useself		= N'True'
		EXEC master.dbo.sp_serveroption			@server			=N'TempLinkedServer'
												, @optname		=N'collation compatible'
												, @optvalue		=N'true'
		EXEC master.dbo.sp_serveroption			@server			=N'TempLinkedServer'
												, @optname		=N'data access'
												, @optvalue		=N'true'
		EXEC master.dbo.sp_serveroption			@server			=N'TempLinkedServer'
												, @optname		=N'dist'
												, @optvalue		=N'false'
		EXEC master.dbo.sp_serveroption			@server			=N'TempLinkedServer'
												, @optname		=N'pub'
												, @optvalue		=N'false'
		EXEC master.dbo.sp_serveroption			@server			=N'TempLinkedServer'
												, @optname		=N'rpc'
												, @optvalue		=N'true'
		EXEC master.dbo.sp_serveroption			@server			=N'TempLinkedServer'
												, @optname		=N'rpc out'
												, @optvalue		=N'true'
		EXEC master.dbo.sp_serveroption			@server			=N'TempLinkedServer'
												, @optname		=N'sub'
												, @optvalue		=N'false'
		EXEC master.dbo.sp_serveroption			@server			=N'TempLinkedServer'
												, @optname		=N'connect timeout'
												, @optvalue		=N'0'
		EXEC master.dbo.sp_serveroption			@server			=N'TempLinkedServer'
												, @optname		=N'collation name'
												, @optvalue		=null
		EXEC master.dbo.sp_serveroption			@server			=N'TempLinkedServer'
												, @optname		=N'lazy schema validation'
												, @optvalue		=N'false'
		EXEC master.dbo.sp_serveroption			@server			=N'TempLinkedServer'
												, @optname		=N'query timeout'
												, @optvalue		=N'0'
		EXEC master.dbo.sp_serveroption			@server			=N'TempLinkedServer'
												, @optname		=N'use remote collation'
												, @optvalue		=N'true'
		---------------------------------------------------------------------------
		---------------------------------------------------------------------------
		-- END OF CREATE TEMPORARY LINKED SERVER IF COPY TO OTHER SERVER
		---------------------------------------------------------------------------
		---------------------------------------------------------------------------
	END
	
	OPEN ScriptCursor
	FETCH NEXT FROM ScriptCursor INTO @line
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			IF @line = 'GO'
			BEGIN -- EXECUTE SO FAR
				IF @Buffer = 1
				BEGIN
					IF @DestServer != @@SERVERNAME
						EXEC (@TSQL1) AT  TempLinkedServer
					ELSE
						EXEC (@TSQL1)
				END	
				SET		@TSQL1 = 'USE [' + @DestDB +'];'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
				SET		@Buffer = 0
			END
			ELSE
			BEGIN
				SET		@TSQL1	= @TSQL1 + @line +CHAR(13)+CHAR(10)
				IF @line > ''
					SET @Buffer = 1
			END
		END
		FETCH NEXT FROM ScriptCursor INTO @line
	END

	IF @Buffer = 1 --SCRIPT MAY NOT HAVE ENDED IN A GO
	BEGIN
		IF @DestServer != @@SERVERNAME
			EXEC (@TSQL1) AT  TempLinkedServer
		ELSE
			EXEC (@TSQL1)
	END
		
	CLOSE ScriptCursor
	DEALLOCATE ScriptCursor
	
	IF @DestServer != @@SERVERNAME
	BEGIN
		---------------------------------------------------------------------------
		---------------------------------------------------------------------------
		-- DROP TEMPORARY LINKED SERVER IF COPY TO OTHER SERVER
		---------------------------------------------------------------------------
		---------------------------------------------------------------------------
		IF  EXISTS (SELECT srv.name FROM [sys].[servers] srv WHERE srv.server_id != 0 AND srv.name = N'TempLinkedServer')
			EXEC [master].[dbo].[sp_dropserver] @server=N'TempLinkedServer', @droplogins='droplogins'
		---------------------------------------------------------------------------
		---------------------------------------------------------------------------
		-- END OF DROP TEMPORARY LINKED SERVER IF COPY TO OTHER SERVER
		---------------------------------------------------------------------------
		---------------------------------------------------------------------------
	END
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	-- END OF CREATE COPY OF OBJECT
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
END


IF @Tasks_CopyData = 1
BEGIN
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	-- COPY DATA
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------

	PRINT 'STILL NEED TO WRITE THIS CODE'

	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	-- END OF COPY DATA
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
END


IF @Tasks_DropOrigional = 1
BEGIN
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	-- DROP ORIGIONAL
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	SET		@TSQL2	= CASE @ObjectType
						WHEN 'PROCS'		THEN 'DROP PROCEDURE ['
						WHEN 'FUNCTIONS'	THEN 'DROP FUNCTION ['
						WHEN 'TABLES'		THEN 'DROP TABLE ['
						WHEN 'VIEWS'		THEN 'DROP VIEW ['
						END
					+ @SourceSchema + '].[' + @SourceObject + ']' 
	EXEC	(@TSQL2)
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	-- END OF DROP ORIGIONAL
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
END


IF @Tasks_CreateSynonym = 1
BEGIN
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	-- CREATE SYNONYM
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	SET		@TSQL2	= 'CREATE SYNONYM ['+ @SourceSchema +'].[' + @SourceObject + ']'+CHAR(13)+CHAR(10) 
					+ 'FOR [' + @DestServer + '].[' + @DestDB + '].[' + @DestSchema + '].[' + @SourceObject + '];'+CHAR(13)+CHAR(10)
	EXEC	(@TSQL2)
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	-- END OF CREATE SYNONYM
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
END

