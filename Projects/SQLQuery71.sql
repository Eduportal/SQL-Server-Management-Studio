USE DBAADMIN
GO
IF OBJECT_ID('dbo.dbasp_print') IS NOT NULL
	DROP PROCEDURE dbo.dbasp_print
GO
CREATE PROCEDURE	dbo.dbasp_Print
	(
	@Text			VarChar(max)	
	,@NestLevel		INT				= 0 -- ADDS ADITIONAL "  " (TWO SPACES) MULTIPLIED BY THIS VALUE TO BEGINING OF EACH LINE 
	,@ScriptSafe	BIT				= 1 -- ADDS a "-- " AT THE BEGINNING OF SONGLE LINES OR WRAPS WITH "/* " & " */" IF MULTIPLE LINES
	,@Force			BIT				= 0 -- PRINTS EVEN IF EnableCodeComments IS CURRENTLY OFF
	)
AS
BEGIN
	DECLARE @ECC BIT, @ExtProp_chk sql_variant, @ExtProp sysname, @ExtProp_val sql_variant,@CRLF CHAR(2), @NestString VarChar(100)
	SELECT	@CRLF = CHAR(13) + CHAR(10)
			,@NestString = COALESCE(REPLICATE('  ',@NestLevel),'')
	-- GET EnableCodeComments FROM DATABASE
	SELECT	@ExtProp_chk = NULL, @ExtProp = 'EnableCodeComments', @ExtProp_val = '0' --USE AS DEFAULT VALUE IF CREATING PARAMETER
	SELECT	@ExtProp_chk = Value FROM sys.fn_listextendedproperty(@ExtProp, default, default, default, default, default, default)
	IF @@ROWCOUNT = 0 EXEC sys.sp_addextendedproperty @name=@ExtProp, @value=@ExtProp_val	
	SELECT	@ECC = COALESCE(CAST(@ExtProp_chk AS bit),0)
	

	SET @Text = CASE @ScriptSafe WHEN 1 THEN @NestString + '-- ' ELSE @NestString END + REPLACE(@Text,@CRLF,CASE @ScriptSafe WHEN 1 THEN @CRLF + @NestString + '-- ' ELSE @CRLF + @NestString END)
	
	IF @ECC = 1 OR @Force = 1 --ONLY PRINT IF COMMENTS ARE ON OR FORCED TO
		RAISERROR (@Text,-1,-1) WITH NOWAIT
END
GO	




IF OBJECT_ID('dbo.dbasp_UnlockAndDelete') IS NOT NULL
	DROP PROCEDURE dbo.dbasp_UnlockAndDelete
GO


CREATE PROCEDURE	dbo.dbasp_UnlockAndDelete
	(
	@FileName			VarChar(1000)
	,@Unlock			BIT				= 0
	,@Delete			BIT				= 0
	,@StartNestLevel	INT				= 0
	)
AS
BEGIN
		SET NOCOUNT ON
		DECLARE			@TXT			VarChar(1024)
						,@NestLevel		INT 
						,@FileNameFound VarChar(1024)
						,@PID			VarChar(50)
						,@Handle		VarChar(50)
						,@CMD			VarChar(8000)
						,@Result		INT
						,@HandleString	VarChar(8000)

		DECLARE			@HandleTab		TABLE([Row] VarChar(max) NULL)

		SET				@NestLevel		= @StartNestLevel + 1

		IF [dbaadmin].[dbo].[dbaudf_GetFileProperty] (@FileName,'File','Path') IS NULL
		BEGIN	
				SET @TXT = @FileName + ' Does Not Exist.' ; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1
				RETURN
		END
		
		SET @TXT = 'Checking Handles on '+@FileName; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1;

		Select	@cmd		= 'handle ' 
							+ QUOTENAME(@FileName,'"')
							+ ' -accepteula'
				,@NestLevel	= @NestLevel + 1
				,@TXT		= @cmd

		EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		
		INSERT INTO @HandleTab([Row])
		EXEC @Result = master.sys.xp_cmdshell @cmd

		DELETE	@HandleTab	WHERE [ROW] NOT LIKE '%'+REPLACE(@FileName,'.sql','')+'%' OR [ROW] IS NULL

		SELECT	@NestLevel	= @NestLevel - 1
				,@TXT		= 'Locks:'
		EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		SELECT	@NestLevel	= @NestLevel + 1

		IF NOT EXISTS(SELECT 1 FROM @HandleTab)
		BEGIN
			SET @TXT = 'No Locks Found'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1

			IF @Delete = 1
			BEGIN
				SELECT	@NestLevel	= @NestLevel + 1
						,@TXT		= 'Deleting...' 
				EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1

				SELECT	@CMD		= 'DEL ' + QUOTENAME(@FileName,'"')
						,@TXT		= @cmd
				EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
				EXEC	@Result		= master.sys.xp_cmdshell @cmd,no_output		

				SELECT	@TXT		= 'Deleted.'
				EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1
				SELECT	@NestLevel	= @NestLevel - 1
			END		
		END
		
		DECLARE Delete_Cursor CURSOR
		KEYSET FOR SELECT [ROW] FROM @HandleTab
		OPEN Delete_Cursor
		FETCH NEXT FROM Delete_Cursor INTO @HandleString
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN
						-- CLEAR CURSOR VARIABLES
						SELECT	@FileNameFound = NULL, @PID = NULL, @Handle = NULL
						
						-- GET AND DISECT HANDLE RECORD
						SELECT	Identity(int,1,1)[RowId], [SplitValue]
						INTO	#HandleBits
						FROM	dbaadmin.dbo.dbaudf_split(@HandleString,' ')
						WHERE	COALESCE([SplitValue],'')!=''
						ORDER BY [OccurenceId]
						
						-- POPULATE VARIABLES TO PROCESS HANDLE
						SELECT		@Handle			= CASE RowID WHEN 4 THEN REPLACE([SplitValue],':','') ELSE @Handle END
									,@PID			= CASE RowID WHEN 3 THEN [SplitValue] ELSE @PID END
									,@FileNameFound	= CASE RowID WHEN 5 THEN [SplitValue] ELSE @FileNameFound END
						FROM		#HandleBits
						DROP TABLE	#HandleBits

						-- DISPLAY FILE HANDLE
						SET @TXT = 'Lock Found on ' + @FileNameFound + ' (PID:' + @PID + ' HANDLE:' + @Handle + ')'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1

						IF @Unlock = 1
						BEGIN
							SELECT	@NestLevel	= @NestLevel + 1
									,@TXT		= 'Unlocking...' 
							EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1

							SELECT	@cmd		= 'handle -c ' + @Handle + ' -p ' + @Pid + ' -y'
									,@TXT		= @cmd
							EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
							EXEC	@Result		= master.sys.xp_cmdshell @cmd,no_output

							SELECT	@TXT		= 'Unlocked.'
							EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1
							SELECT	@NestLevel	= @NestLevel - 1
						END
						
						IF @Delete = 1
						BEGIN
							SELECT	@NestLevel	= @NestLevel + 1
									,@TXT		= 'Deleting...' 
							EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1

							SELECT	@CMD		= 'DEL ' + QUOTENAME(@FileNameFound,'"')
									,@TXT		= @cmd
							EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
							EXEC	@Result		= master.sys.xp_cmdshell @cmd,no_output		

							SELECT	@TXT		= 'Deleted.'
							EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1
							SELECT	@NestLevel	= @NestLevel - 1
						END
		
			END
			FETCH NEXT FROM Delete_Cursor INTO @HandleString
		END
		CLOSE Delete_Cursor
		DEALLOCATE Delete_Cursor

END
GO


IF OBJECT_ID('dbo.dbasp_RunTSQL') IS NOT NULL
	DROP PROCEDURE dbo.dbasp_RunTSQL
GO
CREATE PROCEDURE	dbo.dbasp_RunTSQL
	(
	@Name				VarChar(1000)	= NULL
	,@TSQL				VarChar(8000)	= NULL
	,@DBName			sysname			= NULL
	,@Server			sysname			= NULL
	,@Login				sysname			= NULL
	,@Password			sysname			= NULL
	,@OutputPath		VarChar(1000)	= NULL
	,@OutputFile		VarChar(1000)	= NULL
	,@SQLcmdOptions		VarChar(1000)	= ' -I -p -b -e'
	,@StartNestLevel	INT				= 0
	)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE			@extprop_cmd	nVarChar(4000)
					,@PARAMETERS	nVarChar(4000)
					,@ExtPropChk	sysname
					,@CMD			VarChar(8000)
					,@Result		Int
					,@UniqueName	sysname
					,@Results		varChar(max)
					,@Results_part	varChar(8000)
					,@Marker1		INT
					,@Marker2		INT
					,@NestLevel		INT
					,@CRLF			CHAR(2)
					,@TXT			VarChar(max)
					,@HandleString	varchar(max)
					,@Handle		varchar(25)
					,@Pid			varchar(25)
					,@cEGUID		VarChar(50)
	DECLARE			@HandleTab		TABLE([Row] VarChar(max) NULL)
	DECLARE			@ResultTab		TABLE([Lineno] INT, [Line] VarChar(max) NULL)

	SELECT			@cEGUID			= CAST(value as VarChar(50))
	FROM			DEPLinfo.sys.fn_listextendedproperty('DEPLInstanceID', default, default, default, default, default, default)	

	SET	@TXT = 'Starting '+COALESCE(OBJECT_NAME(@@PROCID),'');EXEC dbaadmin.dbo.dbasp_Print @TXT,@StartNestLevel

	-- SET CONSTANTS
	SELECT			@NestLevel		= @StartNestLevel + 1
					,@CRLF			= CHAR(13) + CHAR(10)
					,@UniqueName	= sys.fn_repluniquename(NEWID(),object_name(@@Procid),default,default,default)+'.out'
					,@Server		= COALESCE(@Server,@@servername)
					,@DBName		= COALESCE(@DBName,'master')
					,@SQLcmdOptions	= COALESCE(' -U' + @Login + ' -P' + @Password,' -E') + COALESCE(@SQLcmdOptions,'') + ' -o' + QUOTENAME(@UniqueName,'"')
					,@extprop_cmd	= 'DECLARE @TXT VarChar(max)' + @CRLF
									+ 'SET @TXT = ''Setting ''+@ExtProp+'' ExtendedProperty to "''+@ExtPropVal+''"''' + @CRLF
									+ 'EXEC dbaadmin.dbo.dbasp_Print @TXT, @NestLevel' + @CRLF
									+ 'SELECT      @ExtPropChk = CAST(value AS SYSNAME)' + @CRLF
									+ 'FROM  '+@DBName+'.sys.fn_listextendedproperty(@ExtProp, default, default, default, default, default, default)' + @CRLF
									+ 'IF @@ROWCOUNT = 0' + @CRLF
									+ '  EXEC '+@DBName+'.sys.sp_addextendedproperty @name=@ExtProp, @value=@ExtPropVal' + @CRLF
									+ 'ELSE' + @CRLF
									+ '  EXEC '+@DBName+'.sys.sp_updateextendedproperty @name=@ExtProp, @value=@ExtPropVal'
					,@PARAMETERS	= '@ExtProp sysname,@ExtPropVal sysname,@ExtPropChk sysname OUT,@NestLevel INT'
      
	-- Set the extended property 'DeplFileName'
	exec sp_executesql 
		@statement		= @extprop_cmd
		, @params		= @PARAMETERS
		, @ExtProp		= 'DeplFileName'
		, @ExtPropVal	= @Name
		, @ExtPropChk	= @ExtPropChk OUT
		, @NestLevel	= @NestLevel
		
	IF COALESCE(@cEGUID,'') != ''
	BEGIN
			INSERT INTO [dbaadmin].[dbo].[BuildSchemaChanges]
					   (
					   [EventType]
					   ,[DatabaseName]
					   ,[DEPLFileName]
					   ,[SQLCommand]
					   ,[ObjectName]
					   ,[ObjectType]
					   ,[EventDate]
					   ,[Status]
						)
			select		'DEPL_RUN_SCRIPT'
						,@DBName
						,@Name
						,@TSQL
						,@OutputFile
						,@OutputPath
						,getdate()
						,'STARTING'	
	END

	IF @TSQL IS NULL
	BEGIN	-- RUN FILE ----------------------------------------------------------
			----------------------------------------------------------------------
			--																	--
			--						START FILE BLOCK							--
			--																	--
			----------------------------------------------------------------------
			----------------------------------------------------------------------
	SET @TXT = 'Executing File'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		-- Execute the File	
		SET		@Results = @CRLF + @CRLF + 'Running DB\file: ' + @DBName + ' \ ' + @Name + '		'  + @CRLF + CAST(Getdate() AS VarChar(50))  + @CRLF + @CRLF
			
		Select	@NestLevel	= @NestLevel + 1
				,@cmd		= 'sqlcmd -S' + @Server 
							+ ' -d' + @DBName
							+ ' -i' + @Name
							+ @SQLcmdOptions
							
		SET @TXT = @cmd; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		EXEC @Result = master.sys.xp_cmdshell @cmd,no_output
	END		-- RUN FILE ----------------------------------------------------------
			----------------------------------------------------------------------
			--																	--
			--							END FILE BLOCK							--
			--																	--
			----------------------------------------------------------------------
			----------------------------------------------------------------------
	ELSE
	BEGIN	-- RUN SCRIPT --------------------------------------------------------
			----------------------------------------------------------------------
			--																	--
			--						START SCRIPT BLOCK							--
			--																	--
			----------------------------------------------------------------------
			----------------------------------------------------------------------
	SET @TXT = 'Executing Script'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		-- Execute the TSQL Script
		SET		@Results = @CRLF + @CRLF + 'Running TSQL SCRIPT: 		' + CAST(Getdate() AS VarChar(50))  +@CRLF + @CRLF
				
		Select	@NestLevel	= @NestLevel + 1
				,@UniqueName= REPLACE(@UniqueName,'.out','.sql')
				,@cmd		= 'sqlcmd -S' + @Server 
							+ ' -d' + @DBName
							+ ' -i' + QUOTENAME(@UniqueName,'"')
							+ @SQLcmdOptions
							
		SET @TXT = 'Writing Script to Temp File '+@UniqueName; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		EXEC	dbaadmin.[dbo].[dbasp_FileAccess_Write]	@TSQL,@UniqueName,null,0
				
		SET @TXT = @cmd; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		EXEC @Result = master.sys.xp_cmdshell @cmd,no_output
		
		-- UNLOCK AND DELETE TEMP .SQL FILE
		SET @TXT = 'Deleting Temp .sql File ' + @UniqueName; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		EXEC dbo.dbasp_UnlockAndDelete @UniqueName,1,1,@NestLevel
		
		SET		@UniqueName= REPLACE(@UniqueName,'.sql','.out')
	END		-- RUN SCRIPT --------------------------------------------------------
			----------------------------------------------------------------------
			--																	--
			--						END SCRIPT BLOCK							--
			--																	--
			----------------------------------------------------------------------
			----------------------------------------------------------------------

	SET @NestLevel = @NestLevel + 1
	BEGIN	-- GET OUTPUT --------------------------------------------------------
			----------------------------------------------------------------------
			--																	--
			--					START GATHER OUTPUT BLOCK						--
			--																	--
			----------------------------------------------------------------------
			----------------------------------------------------------------------
			
		-- OUTPUT SCRIPT TO WINDOW AFTER EVERYTHING ELSE UNLESS OUTPUT FILE SET
		SET		@TXT = 'Getting Results'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
			
		SELECT		@NestLevel	= @NestLevel + 1
					,@Marker1	= 0
			
		INSERT INTO	@ResultTab([Lineno],[Line])
		SELECT		[Lineno],[Line]
		FROM		dbaadmin.dbo.dbaudf_FileAccess_Read(@UniqueName,NULL)
		ORDER BY	[Lineno]

		SELECT		@Results = @Results+COALESCE([Line],'') + @CRLF
		FROM		@ResultTab
		ORDER BY	[Lineno]
		SET		@Results = @CRLF + @CRLF + @Results + @CRLF + @CRLF

	END		-- GET OUTPUT --------------------------------------------------------
			----------------------------------------------------------------------
			--																	--
			--						END GATHER OUTPUT BLOCK						--
			--																	--
			----------------------------------------------------------------------
			----------------------------------------------------------------------

	BEGIN	-- SHOW OUTPUT -------------------------------------------------------
			----------------------------------------------------------------------
			--																	--
			--						START SHOW OUTPUT BLOCK						--
			--																	--
			----------------------------------------------------------------------
			----------------------------------------------------------------------

		IF @OutputPath IS NULL
		BEGIN
			-- OUTPUT TO SCREEN
			SET		@TXT = 'Display Results (' + CAST(LEN(@Results) AS VarChar(50)) + ')'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
						
			PrintMore: -- LOOP THROUGH 1k+ Chunks of the results Printing them using the first LF after 1k as the break point so it looks right

				SET @Marker2 = CHARINDEX(CHAR(10),@Results,@Marker1 + 1024)
				IF @Marker2 = 0
					SET @Marker2 = LEN(@Results)

				SET @TXT = SUBSTRING(@Results,@Marker1,(@Marker2-@Marker1)-1); EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,0,1;

				SET @Marker1 = @Marker2 + 1
				If @Marker2 < LEN(@Results)
					GOTO PrintMore
		END
		ELSE
		BEGIN
			-- OUTPUT TO FILE
			EXEC	dbaadmin.[dbo].[dbasp_FileAccess_Write]	@Results,@OutputPath,@OutputFile,1
		END
		
	END		-- SHOW OUTPUT -------------------------------------------------------
			----------------------------------------------------------------------
			--																	--
			--						END SHOW OUTPUT BLOCK						--
			--																	--
			----------------------------------------------------------------------
			----------------------------------------------------------------------	

	-- UNLOCK AND DELETE TEMP .SQL FILE
	SET @TXT = 'Deleting Temp .OUT File ' + @UniqueName; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
	EXEC dbo.dbasp_UnlockAndDelete @UniqueName,1,1,@NestLevel

	-- CLEANUP AND CLOSE -------------------------------------------------
	----------------------------------------------------------------------
	--																	--
	--						CLEANUP AND CLOSE							--
	--																	--
	----------------------------------------------------------------------
	----------------------------------------------------------------------
			
	IF COALESCE(@cEGUID,'') != ''
	BEGIN
			INSERT INTO [dbaadmin].[dbo].[BuildSchemaChanges]
					   (
					   [EventType]
					   ,[DatabaseName]
					   ,[DEPLFileName]
					   ,[SQLCommand]
					   ,[ObjectName]
					   ,[ObjectType]
					   ,[EventDate]
					   ,[Status]
						)
			select		'DEPL_RUN_SCRIPT'
						,@DBName
						,@Name
						,@TSQL
						,@OutputFile
						,@OutputPath
						,getdate()
						,'DONE'	
	END
		-- Clear the extended property 'DeplFileName'
		exec sp_executesql 
			@statement		= @extprop_cmd
			, @params		= @PARAMETERS
			, @ExtProp		= 'DeplFileName'
			, @ExtPropVal	= Null
			, @ExtPropChk	= @ExtPropChk OUT
			, @NestLevel	= @NestLevel			

END
GO

/*


select * From master.sys.master_files


EXEC dbo.dbasp_UnlockAndDelete 'E:\data\test.mdf',1,1



DECLARE @ECID uniqueidentifier
SET @ECID = newID()
EXEC deplinfo.sys.sp_updateextendedproperty @name='DEPLInstanceID', @value=@ECID
GO
EXEC dbaadmin.sys.sp_updateextendedproperty @name='EnableCodeComments', @value=1
GO
USE [dbaadmin]
GO
PRINT DB_NAME()

SELECT * from sysfiles

select * From sysobjects
GO
EXEC dbaadmin.dbo.dbasp_RunTSQL 
	@Name			= 'Test Script'
	,@TSQL			= 'USE [dbaadmin]
GO
PRINT DB_NAME()

SELECT * from sysfiles

select * From sysobjects order by name'
	,@DBName		= 'master'

EXEC dbaadmin.dbo.dbasp_RunTSQL 
	@Name			= 'd:\Test.sql'
	,@TSQL			= NULL --'Select * From sysfiles'
	,@DBName		= 'master'
	
EXEC dbaadmin.sys.sp_updateextendedproperty @name='EnableCodeComments', @value=0
GO
EXEC deplinfo.sys.sp_updateextendedproperty @name='DEPLInstanceID', @value=NULL
GO	



		
		
	SELECT		COALESCE([Line],'')
	FROM		dbaadmin.dbo.dbaudf_FileAccess_Read('dbasp_RunTSQL-C14ADBB47C1A4C06978CAC332A063536.out',NULL)
	ORDER BY	[Lineno]





--*/