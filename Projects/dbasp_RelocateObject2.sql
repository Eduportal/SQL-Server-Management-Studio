DROP PROCEDURE dbasp_RelocateObject
GO
CREATE PROCEDURE dbasp_RelocateObject
		(
		@SourceObject	sysname
		,@ObjectType	sysname	-- PROCS, FUNCTIONS, TABLES, VIEWS, INDEXES
		,@SourceSchema	sysname	= 'dbo'	-- DEFAULT SCHEMA IS DBO
		,@SourceDB		sysname = NULL  -- DEFALT DATABASE IS DB_NAME()
		,@DestServer	sysname	= NULL  -- DEFALT SERVER IS @@SERVERNAME
		,@DestDB		sysname = NULL  -- DEFALT DATABASE IS DB_NAME(), MUST BE DIFFERENT IF
										--  @DestServer is @@SSERVERNAME	
		,@DestSchema	sysname = 'dbo' -- DEFAULT SCHEMA IS DBO
		,@Tasks_CreateCopy		bit = 0 -- DEFAULT ASSUMES YOU HAVE CREATED COPY AT NEW LOCATION ALREADY
		,@Tasks_CopyData		bit = 0 -- DEFAULT ASSUMES YOU HAVE COPIED DATA TO NEW LOCATION ALREADY
		,@Tasks_DropOrigional	bit = 1 -- DEFAULT ASSUMES YOU ARE DROPING
		,@Tasks_CreateSynonym	bit = 1 -- DEFAULT ASSUMES YOU ARE CREATING A SYNONYM
		,@DebugLevel	int = 0
		)
	
			/* DEBUG LEVELS
			
			0 NONE
			1 BLOCK LEVEL BREADCRUMBS
			2 DETAILED BREADCRUMBS
			3 USER DEFINED
			4 USER DEFINED
			5 USER DEFINED
			6 PRINT AND RUN ALL DYNAMIC SCRIPTS
			7 PRINT ONLY ALL DYNAMIC SCRIPTS
			8 USER DEFINED
			9 USER DEFINED
			100 MAX
			*/
AS
BEGIN		-- SET OPTIONS
SET NOCOUNT ON

END

BEGIN		-- DECLARE VARIABLES
		IF @DebugLevel >= 1 -- BLOCK LEVEL BREADCRUMB
			PRINT 'STARTING VARIABLE DECLARATIONS'

	BEGIN	-- STANDARDIZED VARIABLES
		DECLARE @ErrorSeverity		INT
		DECLARE @ErrorState			INT
		DECLARE @SprocName			sysname
		DECLARE @ErrorMessage		nVarChar(4000)
		DECLARE @ShortMsg			nVarChar(4000)
		DECLARE @LongMsg			nVarChar(4000)
		DECLARE @DebugData			nVarChar(4000)
		DECLARE @ErrorStateLookUps	TABLE
									(
									ErrorState	INT
									,ShortMsg	nVarChar(4000)
									,LongMsg	nVarChar(4000)
									)
	END		-- STANDARDIZED VARIABLES

		DECLARE @TSQL1				VarChar(MAX)
		DECLARE @TSQL2				VarChar(MAX)
		DECLARE	@SourceSVR			sysname
		DECLARE @line				varchar(8000)
		DECLARE @Buffer				Bit

		SELECT	@SourceDB			= COALESCE(@SourceDB,DB_NAME())
				,@DestServer		= COALESCE(@DestServer,@@SERVERNAME)
				,@DestDB			= COALESCE(@DestDB,DB_NAME())
				,@SourceSVR			= @@SERVERNAME
				
END		-- DECLARE VARIABLES

BEGIN		-- DEFINE ANTICIPATED ERRORS
		IF @DebugLevel >= 1 -- BLOCK LEVEL BREADCRUMB
			PRINT 'STARTING DEFINITION OF ANTICIPATED ERRORS'

	INSERT INTO	@ErrorStateLookUps
			  SELECT	1,'Input Parameters Invalid','Src and Dst Server and DB Can Not Be The Same'
	UNION ALL SELECT	2,'XXXXXXX'	,'XXXXXXX'
	UNION ALL SELECT	3,'XXXXXXX'	,'XXXXXXX'
	UNION ALL SELECT	4,'XXXXXXX'	,'XXXXXXX'
	UNION ALL SELECT	5,'XXXXXXX'	,'XXXXXXX'
	UNION ALL SELECT	6,'XXXXXXX'	,'XXXXXXX'
	UNION ALL SELECT	7,'XXXXXXX'	,'XXXXXXX'

		IF @DebugLevel >= 1 -- BLOCK LEVEL BREADCRUMB
			PRINT 'ENDING DEFINITION OF ANTICIPATED ERRORS'
END		-- DEFINE ANTICIPATED ERRORS

BEGIN TRY	-- STORED PROCEDURE 
	BEGIN	-- INPUT PARAMETER CHECKING
			IF @DebugLevel >= 1 -- BLOCK LEVEL BREADCRUMB
				PRINT 'STARTING INPUT PARAMETER CHECK'
		------------------------------------------------------------
		BEGIN -- CHECK 1
			IF 		@DestServer = @@SERVERNAME
				AND	@SourceDB	= @DestDB
			BEGIN	-- RAISERROR
				SET		@ErrorState = 1 
				RAISERROR ('Anticipated Error',16,@ErrorState)
			END		-- RAISERROR 
		END -- CHECK
		------------------------------------------------------------
			IF @DebugLevel >= 1 -- BLOCK LEVEL BREADCRUMB
				PRINT 'ENDING INPUT PARAMETER CHECK'
	END		-- INPUT PARAMETER CHECKING

	BEGIN	-- SPROC BODY
			IF @DebugLevel >= 1 -- BLOCK LEVEL BREADCRUMB
				PRINT 'STARTING SPROC BODY'
		------------------------------------------------------------
		IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
			PRINT '	TESTING @Tasks_CreateCopy'
		If @Tasks_CreateCopy = 1
		BEGIN	-- CREATE COPY OF OBJECT
				IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
					PRINT '	Starting Create Copy'

			IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
				PRINT '	exec dbasp_ScriptObject'
			exec dbasp_ScriptObject
						@SourceDB		= @SourceDB
						,@SourceObject	= @SourceObject
						,@SourceUID		=  null 				-- null for trusted connection
						,@SourcePWD		=  null 				-- null for trusted connection
						,@OutFilePath	= 'C:\' 
						,@OutFileName	= 'tempddlscript.txt'   -- null for separate file per object script
						,@ObjectType	= @ObjectType 
						,@WorkPath		= 'C:\' 
						,@SourceSVR		= @SourceSVR

			SET		@TSQL1 = ''
			SET		@Buffer = 0
			IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
				PRINT '	DECLARE ScriptCursor CURSOR'
			DECLARE ScriptCursor CURSOR
			FOR
			SELECT	line 
			From	[dbaudf_ReadfileAsTable] ('C:','tempddlscript.txt')

			--IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
			--	PRINT '	TESING @DestServer'
			--IF		@DestServer != @@SERVERNAME
			BEGIN	-- CREATE TEMPORARY LINKED SERVER
					IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
						PRINT '	CREATING TEMPORARY LINKED SERVER'
				
				IF  EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = N'TempLinkedServer')
					EXEC master.dbo.sp_dropserver @server=N'TempLinkedServer', @droplogins='droplogins'

				EXEC sp_addlinkedserver					@server			=N'TempLinkedServer' 
														, @srvproduct	=''
														, @provider		='SQLNCLI'
														, @datasrc		=@DestServer
														, @catalog		=@DestDB
				EXEC master.dbo.sp_addlinkedsrvlogin	@rmtsrvname		=N'TempLinkedServer'
														, @locallogin	=NULL 
														, @useself		=N'True'
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
			END		-- CREATE TEMPORARY LINKED SERVER
			
			BEGIN	-- READ FILE
				IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
					PRINT '	Open Cursor'			
				OPEN ScriptCursor
				IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
					PRINT '	Fetch Row'				
				FETCH NEXT FROM ScriptCursor INTO @line
				WHILE (@@fetch_status <> -1)
				BEGIN
					IF (@@fetch_status <> -2)
					BEGIN	-- PROCESS ROW
						IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
							PRINT '	Start Processing Row'			
						IF @line = 'GO'
						BEGIN -- EXECUTE SO FAR
							IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
								PRINT '	FOUND a "GO"'			
							IF @Buffer = 1
							BEGIN
								IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
									PRINT '	Script in Buffer'								
								IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
									PRINT '	Executing Remotly'				
								IF	@DebugLevel >= 6 -- PRINT DYNAMIC SQL BEFORE EXECUTING IT
									PRINT (@TSQL1)
								IF	@DebugLevel < 7 -- ALLOW DYNAMIC SQL TO BE EXECUTED
									EXEC (@TSQL1) AT  TempLinkedServer
								ELSE
									PRINT '	*** @DebugLevel Prevented Execution ***'
							END
							IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
								PRINT '	Resetting Buffer'				
							SET		@TSQL1 = ''
							SET		@Buffer = 0
						END
						ELSE
						BEGIN	-- NOT A GO LINE
							IF @line > ''
							BEGIN -- LINE IS NOT BLANK
								IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
									PRINT '	Adding Line to Buffer {'+ @line + '}'				
								SET	@TSQL1	= @TSQL1 + @line +CHAR(13)+CHAR(10)
								SET @Buffer = 1
							END	 -- LINE IS NOT BLANK
							ELSE
								IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
									PRINT '	Blank Line, Skipping'							
						END		-- NOT A GO LINE
					END		-- PROCESS ROW
					IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
						PRINT '	Fetch Next Row'					
					FETCH NEXT FROM ScriptCursor INTO @line
				END
				IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
					PRINT '	Done with Cursor'				

				IF @Buffer = 1 --SCRIPT MAY NOT HAVE ENDED IN A GO
				BEGIN
					IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
						PRINT '	Still Script in Buffer'				
					IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
						PRINT '	Executing Remotly'				
					IF	@DebugLevel >= 6 -- PRINT DYNAMIC SQL BEFORE EXECUTING IT
						PRINT (@TSQL1)
					IF	@DebugLevel < 7 -- ALLOW DYNAMIC SQL TO BE EXECUTED
						EXEC (@TSQL1) AT  TempLinkedServer
					ELSE
						PRINT '	*** @DebugLevel Prevented Execution ***'
				END
					
				IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
					PRINT '	Close and Deallocate Cursor'
				CLOSE ScriptCursor
				DEALLOCATE ScriptCursor
			END	-- READ FILE
			
			IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
				PRINT '	TESING @DestServer'			
			IF @DestServer != @@SERVERNAME AND EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = N'TempLinkedServer')
			BEGIN	-- DROP TEMPORARY LINKED SERVER
				IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
					PRINT '	Dropping Temporary Linked Server'			
				EXEC master.dbo.sp_dropserver @server=N'TempLinkedServer', @droplogins='droplogins'
			END		-- DROP TEMPORARY LINKED SERVER
		END		-- CREATE COPY OF OBJECT	


		IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
			PRINT '	TESING @Tasks_CopyData'			
		IF @Tasks_CopyData = 1
		BEGIN
			IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
				PRINT '	Start Copy of Data'			

			PRINT 'DATA COPY CODE NOT DONE'

			IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
				PRINT '	Finished Copy of Data'			
		END


		IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
			PRINT '	TESING @Tasks_DropOrigional'
		IF @Tasks_DropOrigional = 1
		BEGIN	-- DROP ORIGIONAL
			IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
				PRINT '	Start Building Drop Script'
			SET		@TSQL2	= CASE @ObjectType
								WHEN 'PROCS'		THEN 'DROP PROCEDURE ['
								WHEN 'FUNCTIONS'	THEN 'DROP FUNCTION ['
								WHEN 'TABLES'		THEN 'DROP TABLE ['
								WHEN 'VIEWS'		THEN 'DROP VIEW ['
								END
							+ @SourceSchema + '].[' + @SourceObject + ']' 

			IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
				PRINT '	Execute Drop Script'
			EXEC	(@TSQL2)
		END		-- DROP ORIGIONAL

		IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
			PRINT '	TESING @Tasks_CreateSynonym'
		IF @Tasks_CreateSynonym = 1
		BEGIN	-- CREATE SYNONYM
			IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
				PRINT '	Start Building Synonym Script'
			SET		@TSQL2	= 'CREATE SYNONYM ['+ @SourceSchema +'].[' + @SourceObject + ']'+CHAR(13)+CHAR(10) 
							+ 'FOR [' + @DestServer + '].[' + @DestDB + '].[' + @DestSchema + '].[' + @SourceObject + '];'+CHAR(13)+CHAR(10)

			IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
				PRINT '	Execute Synonym Script'
			EXEC	(@TSQL2)
		END		-- CREATE SYNONYM

		IF	@DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
			PRINT '	Completed All Tasks'
		------------------------------------------------------------
			IF @DebugLevel >= 1 -- BLOCK LEVEL BREADCRUMB
				PRINT 'ENDING SPROC BODY'
	END		-- SPROC BODY
END TRY		-- STORED PROCEDURE

BEGIN CATCH	-- ERROR HANDELING
	IF @DebugLevel >= 1 -- BLOCK LEVEL BREADCRUMB
		PRINT 'STARTING CATCH BLOCK'
	------------------------------------------------------------

	SELECT	@SprocName		= OBJECT_NAME(@@PROCID)
			,@ShortMsg		= COALESCE(ShortMsg,'UnAnticipated Error')
			,@LongMsg		= COALESCE(LongMsg,@ErrorMessage)
			,@DebugData		= CASE @ErrorState
								WHEN 1	THEN	@SourceSVR + ',' + @SourceDB + ',' + @DestServer + ',' + @DestDB 
								WHEN 2	THEN	'XXXXXXX' 
								WHEN 3	THEN	'XXXXXXX' 
								WHEN 4	THEN	'XXXXXXX' 
								WHEN 5	THEN	'XXXXXXX' 
								END
	FROM	@ErrorStateLookUps 
	WHERE	ErrorState		= @ErrorState
		AND	ERROR_MESSAGE() = 'Anticipated Error'
	
	EXEC dbo.dbasp_CatchError @ShortMsg,@LongMsg,@DebugData,@DebugLevel 

	--   SELECT	@ErrorMessage	= ERROR_MESSAGE()
	--		,@ErrorSeverity	= ERROR_SEVERITY()
	--		,@ErrorState	= ERROR_STATE()

	--IF @DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
	--BEGIN
	--	PRINT ERROR_NUMBER()
	--	PRINT ERROR_SEVERITY()
	--	PRINT ERROR_STATE()
	--	PRINT ERROR_PROCEDURE()
	--	PRINT ERROR_LINE()
	--	PRINT ERROR_MESSAGE()
	--END
	

	
	--IF @DebugLevel >= 2 -- DETAIL LEVEL BREADCRUMB
	--BEGIN
	--	PRINT @ErrorMessage
	--	PRINT @ErrorSeverity
	--	PRINT @ErrorState
	--	PRINT @SprocName
	--	PRINT @ShortMsg
	--	PRINT @LongMsg
	--	PRINT @DebugData
	--END	
				
	--RAISERROR	(
	--			@ErrorMessage
	--			,10				-- SEVERITY SWITCH TO A LOWER SEVERITY FOR 
	--			,@ErrorState	-- STATE
	--			,@SprocName		-- SPROC NAME
	--			,@ShortMsg		-- SHORT MESSAGE
	--			,@DebugData		-- DEBUG DATA
	--			,@LongMsg		-- LONG MESSAGE
	--			)
	------------------------------------------------------------
	IF @DebugLevel >= 1 -- BLOCK LEVEL BREADCRUMB
		PRINT 'ENDING CATCH BLOCK'
END CATCH	-- ERROR HANDELING
GO
