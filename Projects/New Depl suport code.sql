USE [dbaadmin]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_ReturnPart]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_ReturnPart]
GO
CREATE   FUNCTION [dbo].[dbaudf_ReturnPart]  
    (@String VarChar(8000),  
     @WordNumber int) 
RETURNS VarChar(50) 
AS 
BEGIN 
If    @WordNumber < 1 
    Return '' 
IF CHARINDEX('|', @String, 1) = 0  
    BEGIN 
        IF @WordNumber = 1 
            RETURN @String 
        ELSE 
            Return '' 
    END 
SET    @String = LTRIM(RTRIM(@String)) 
IF      @String = '' 
        RETURN '' 
IF @WordNumber = 1 
        RETURN SUBSTRING(@String, 1, CHARINDEX('|', @String, 1) - 1) 
WHILE @WordNumber > 1 
    BEGIN 
        IF CHARINDEX('|', @String, 1) = 0 
            Return '' 
          SET @String = SUBSTRING(@String,  CHARINDEX('|', @String, 1) + 1, LEN(@String) - CHARINDEX('|', @String, 1)) 
        SET @WordNumber = @WordNumber - 1     
    END 
IF CHARINDEX('|', @String, 1) = 0  
    RETURN @String 
RETURN SUBSTRING(@String, 1, CHARINDEX('|', @String, 1) - 1) 
END 
GO



if exists (select * from sys.objects where object_id = object_id(N'[dbo].[dbasp_FileAccess_Write]'))
drop procedure [dbo].[dbasp_FileAccess_Write]
GO
CREATE PROCEDURE [dbo].[dbasp_FileAccess_Write]
	(
	@String			Varchar(max)			--8000 in SQL Server 2000
	,@Path			VARCHAR(4000)
	,@Filename		VARCHAR(1024)	= NULL	-- CAN BE NULL IF PASSING THE FILENAME AS PART OF THE PATH
	,@Append		bit				= 0		-- DEFAULT IS TO OVERWRITE
	,@WriteNewLine	bit				= 1		-- EACH APPEND ENDS WITH A CR/LF
	)
/**************************************************************
 **  Stored Procedure dbasp_FileAccess_Write                  
 **  Written by Steve Ledridge, Getty Images                
 **  April 01, 2005                                      
 **  
 **  This dbasp is set up to write a string variable into a file.
 ***************************************************************/
as
--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	04/01/2010	Steve Ledridge		New process
--	04/01/2011	Steve Ledridge		Modified to Allow Append or overwrite.
--  04/04/2011	Steve Ledridge		Modified to allow @Path to be path and file name.
--	======================================================================================
SET NOCOUNT ON

DECLARE		@objFileSystem		int
			,@objTextStream		int
			,@objErrorObject	int
			,@strErrorMessage	Varchar(1024)
			,@Command			varchar(1024)
			,@hr				int
			,@fileAndPath		varchar(1024)
			,@Method			INT
			,@Source			varchar(1024)
			,@Description		Varchar(1024)
			,@Helpfile			Varchar(1024)
			,@HelpID			int

IF RIGHT(@String,2) = CHAR(13) + CHAR(10)
	SET @WriteNewLine = 0;
	
SELECT		@Method				= CASE @Append WHEN 0 THEN 2 ELSE 8 END
			,@String				= CASE @Append & @WriteNewLine
									WHEN 1 THEN @String + CHAR(13) + CHAR(10)
									ELSE @String END

SELECT		@strErrorMessage	='opening the File System Object'
EXECUTE @hr = sp_OACreate  'Scripting.FileSystemObject' , @objFileSystem OUT

Select @FileAndPath=@path+COALESCE(CASE WHEN RIGHT(@Path,1) = '\' THEN '' ELSE '\' END+@filename,'')
if @HR=0 Select @objErrorObject=@objFileSystem , @strErrorMessage=CASE @Append WHEN 0 THEN 'Creating file "' ELSE 'Appending file "' END +@FileAndPath+'"'
if @HR=0 execute @hr = sp_OAMethod   @objFileSystem,'OpenTextFile',@objTextStream OUT,@FileAndPath,@Method,True

if @HR=0 Select @objErrorObject=@objTextStream, 
	@strErrorMessage='writing to the file "'+@FileAndPath+'"'
if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Write', Null, @String

if @HR=0 Select @objErrorObject=@objTextStream, @strErrorMessage='closing the file "'+@FileAndPath+'"'
if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Close'

if @hr<>0
	begin
		EXECUTE sp_OAGetErrorInfo  @objErrorObject, @source output,@Description output,@Helpfile output,@HelpID output
		Select @strErrorMessage='Error whilst '+coalesce(@strErrorMessage,'doing something')+', '+coalesce(@Description,'')
		raiserror (@strErrorMessage,16,1)
	end
IF 	@objTextStream IS NOT NULL
	EXECUTE	sp_OADestroy @objTextStream
	
IF 	@objFileSystem IS NOT NULL
	EXECUTE	sp_OADestroy @objFileSystem
GO 



if exists (select * from sys.objects where object_id = object_id(N'[dbo].[dbasp_Print]'))
drop procedure [dbo].[dbasp_Print]
GO
CREATE PROCEDURE	[dbo].[dbasp_Print]
	(
	@Text			VarChar(max)	
	,@NestLevel		INT				= 0 -- ADDS ADITIONAL "  " (TWO SPACES) MULTIPLIED BY THIS VALUE TO BEGINING OF EACH LINE 
	,@ScriptSafe	BIT				= 1 -- ADDS a "-- " AT THE BEGINNING OF SONGLE LINES OR WRAPS WITH "/* " & " */" IF MULTIPLE LINES
	,@Force			BIT				= 0 -- PRINTS EVEN IF EnableCodeComments IS CURRENTLY OFF
	)
AS
BEGIN
	DECLARE @ECC BIT, @ExtProp sysname, @CRLF CHAR(2), @NestString VarChar(1024)
	SELECT	@ExtProp		= 'EnableCodeComments'
			,@CRLF			= CHAR(13) + CHAR(10)
			,@NestString	= COALESCE(REPLICATE('  ',@NestLevel),'') + CASE @ScriptSafe WHEN 1 THEN '-- ' ELSE '' END 
			,@Text			= @NestString + REPLACE(@Text,@CRLF,@CRLF+@NestString)

	SELECT	@ECC			= CAST(Value AS bit)
	FROM	sys.fn_listextendedproperty(@ExtProp, default, default, default, default, default, default)

	IF COALESCE(@ECC,0)|@Force = 1 --ONLY PRINT IF COMMENTS ARE ON OR FORCED TO
		RAISERROR (@Text,-1,-1) WITH NOWAIT
END
GO




IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_UnlockAndDelete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_UnlockAndDelete]
GO
CREATE PROCEDURE	[dbo].[dbasp_UnlockAndDelete]
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
		
		SET @TXT = 'Checking Handles on '+@FileName; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel;

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
			SET @TXT = 'No Locks Found'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel

			IF @Delete = 1
			BEGIN
				SELECT	@NestLevel	= @NestLevel + 1
						,@TXT		= 'Deleting...' 
				EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel

				SELECT	@CMD		= 'DEL ' + QUOTENAME(@FileName,'"')
						,@TXT		= @cmd
				EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
				EXEC	@Result		= master.sys.xp_cmdshell @cmd,no_output		

				SELECT	@TXT		= 'Deleted.'
				EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
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
						SET @TXT = 'Lock Found on ' + @FileNameFound + ' (PID:' + @PID + ' HANDLE:' + @Handle + ')'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel

						IF @Unlock = 1
						BEGIN
							SELECT	@NestLevel	= @NestLevel + 1
									,@TXT		= 'Unlocking...' 
							EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel

							SELECT	@cmd		= 'handle -c ' + @Handle + ' -p ' + @Pid + ' -y'
									,@TXT		= @cmd
							EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
							EXEC	@Result		= master.sys.xp_cmdshell @cmd,no_output

							SELECT	@TXT		= 'Unlocked.'
							EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
							SELECT	@NestLevel	= @NestLevel - 1
						END
						
						IF @Delete = 1
						BEGIN
							SELECT	@NestLevel	= @NestLevel + 1
									,@TXT		= 'Deleting...' 
							EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel

							SELECT	@CMD		= 'DEL ' + QUOTENAME(@FileNameFound,'"')
									,@TXT		= @cmd
							EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
							EXEC	@Result		= master.sys.xp_cmdshell @cmd,no_output		

							SELECT	@TXT		= 'Deleted.'
							EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
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
	,@OutputText		VarChar(max)	= NULL OUTPUT
	,@OutputMatrix		INT				= NULL -- NULL=DYNAMIC,0=NONE Bit-Matrix(1=Screen,2=File,4=Parameter) ONLY APLIES TO QUERY RESULTS: DEBUG MESSAGES ALL GO TO SCREEN
	,@DebugMatrix		INT				= 0 -- NULL=0=NONE Bit-Matrix(1=Dont Delete Temp OUT File,2=Dont Delete Temp SQL File,4=,8=,16=)
	)
AS
BEGIN
	SET NOCOUNT ON
	EXEC [dbo].[dbasp_print] 'Database Extended Property "EnableCodeComments" is Enabled',@StartNestLevel
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
					,@ErrorCount	INT
					
	DECLARE			@HandleTab		TABLE([Row] VarChar(max) NULL)
	DECLARE			@ResultTab		TABLE([Lineno] INT, [Line] VarChar(max) NULL)

	SELECT			@cEGUID			= CAST(value as VarChar(50))
					,@ErrorCount	= 0
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
		SELECT	@Results	= @CRLF + @CRLF + 'Running DB\file: ' + @DBName + ' \ ' + @Name + '		'  
							+ @CRLF + CAST(Getdate() AS VarChar(50))  + @CRLF + @CRLF
				,@NestLevel	= @NestLevel + 1
				,@cmd		= 'sqlcmd -S' + @Server 
							+ ' -d' + @DBName
							+ ' -i' + @Name
							+ @SQLcmdOptions
		IF [dbo].[dbaudf_GetFileProperty] (@Name,'File','Path') IS NULL
			BEGIN
				SELECT	@TXT			= 'Error: The File, ' + @Name + ', Does Not Exist.'
						,@OutputText	= @TXT
				EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1 -- ALWAYS PRINT ERROR
				RETURN -1			
			END
		SET @TXT = @cmd; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		EXEC @Result = master.sys.xp_cmdshell @cmd,no_output
		If @Result !=0
		BEGIN
			SELECT	@TXT			= 'Error: Script Execution Returned This Error Code (' + CAST(@Result AS VarChar) + ')' 
					,@OutputText	= @TXT
			EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1 -- ALWAYS PRINT ERROR
			RETURN	@Result
		END
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
		If @Result !=0
		BEGIN
			SELECT	@ErrorCount = @ErrorCount + 1
					,@NestLevel = @NestLevel + 1
			
			SET		@TXT			= 'Error: Script Execution Returned This Error Code (' + CAST(@Result AS VarChar) + ')'; 
			EXEC	dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1 -- ALWAYS PRINT ERROR
			SELECT	@NestLevel		= @NestLevel - 1
			
		END
		
		-- UNLOCK AND DELETE TEMP .SQL FILE
		IF @DebugMatrix & 2 != 2
		BEGIN
			SET @TXT = 'Deleting Temp .SQL File ' + @UniqueName; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
			EXEC dbo.dbasp_UnlockAndDelete @UniqueName,1,1,@NestLevel
		END
		ELSE
		BEGIN
			SET @TXT = 'Temp .SQL File ' + @UniqueName + ' was NOT Deleted.'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1
		END
						
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
		
		SET		@TXT = 'Reading Results into Table'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel	
		INSERT INTO	@ResultTab([Lineno],[Line])
		SELECT		[Lineno],[Line]
		FROM		dbaadmin.dbo.dbaudf_FileAccess_Read(@UniqueName,NULL)
		ORDER BY	[Lineno]

		SET		@TXT = 'Agrigating Results Into Variable'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		SELECT		@Results = @Results+COALESCE([Line],'') + @CRLF
		FROM		@ResultTab
		ORDER BY	[Lineno]

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

		If @OutputMatrix IS NULL -- DYNAMICLY BUILD MATRIX FROM PARAMETERS
		BEGIN
			SET		@TXT = '@OutputMatrix was NULL, Building Dynamicly.'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
			SET	@OutputMatrix = 0
			IF	@OutputPath IS NULL SET @OutputMatrix = @OutputMatrix | 1		--SET SCREEN BIT
			IF	@OutputPath IS NOT NULL SET @OutputMatrix = @OutputMatrix | 2	--SET FILE BIT
			SET @OutputMatrix = @OutputMatrix | 4								--SET PARAMETER BIT
		END

		IF @OutputMatrix & 1 = 1 -- CHECK SCREEN BIT
		BEGIN
			-- OUTPUT TO SCREEN
			SET		@TXT = '@OutputMatrix Screen=YES'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
						
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
			SET		@TXT = '@OutputMatrix Screen=NO'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		END

		IF @OutputMatrix & 2 = 2 -- CHECK FILE BIT
		BEGIN
			-- OUTPUT TO FILE
			SET		@TXT = '@OutputMatrix File=YES'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
			EXEC	dbaadmin.[dbo].[dbasp_FileAccess_Write]	@Results,@OutputPath,@OutputFile,1
		END
		ELSE
		BEGIN
			SET		@TXT = '@OutputMatrix File=NO'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		END
		
		IF @OutputMatrix & 4 = 4 -- CHECK PARAMETER BIT
		BEGIN
			-- OUTPUT TO PARAMETER
			SET		@TXT = '@OutputMatrix Parameter=YES'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
			SET		@OutputText = @Results
		END
		ELSE
		BEGIN
			SET		@TXT = '@OutputMatrix Parameter=NO'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		END
		
	END		-- SHOW OUTPUT -------------------------------------------------------
			----------------------------------------------------------------------
			--																	--
			--						END SHOW OUTPUT BLOCK						--
			--																	--
			----------------------------------------------------------------------
			----------------------------------------------------------------------	

	-- UNLOCK AND DELETE TEMP .OUT FILE
	IF @DebugMatrix & 1 != 1
	BEGIN
		SET @TXT = 'Deleting Temp .OUT File ' + @UniqueName; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel
		EXEC dbo.dbasp_UnlockAndDelete @UniqueName,1,1,@NestLevel
	END
	ELSE
	BEGIN
		SET @TXT = 'Temp .OUT File ' + @UniqueName + ' was NOT Deleted.'; EXEC dbaadmin.dbo.dbasp_Print @TXT,@NestLevel,1,1
	END
	
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

RETURN COALESCE(@ErrorCount,0)
END
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_APP_NAME]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_APP_NAME]
GO
CREATE FUNCTION [dbo].[dbaudf_APP_NAME] 
	(
		@AgentPartName sysname = NULL
	)
RETURNS VarChar(1024)
AS
BEGIN
	DECLARE	@P1			INT
			,@P2		INT
			,@JobID		sysname
			,@JobName	sysname
			,@StepID	sysname
			,@StepName	sysname
			,@APPName	VarChar(1024)
			
	SET		@APPName = APP_NAME()		
	IF		@APPName Like 'SQLAgent - TSQL JobStep%'
	BEGIN
		SELECT	@P1			= CHARINDEX('Job 0x',@APPName)+5
				,@P2		= CHARINDEX(': Step',@APPName)+6
				
		SELECT	@JobID		= CAST(sj.job_id as sysname)
				,@JobName	= sj.name
				,@StepID	= sjs.step_id
				,@StepName	= sjs.step_name
				,@APPName	= CASE @AgentPartName
								WHEN 'JobID'	THEN @JobID
								WHEN 'JobName'	THEN @JobName
								WHEN 'StepID'	THEN @StepID
								WHEN 'StepName'	THEN @StepName
								ELSE 'SQLAgent - TSQL Job ['
										+ sj.name 
										+ '] Step '
										+ CAST(sjs.step_id as VarChar(4)) 
										+ ' [' 
										+ sjs.step_name 
										+ ']' END
		FROM	msdb..sysjobs sj WITH(NOLOCK)
		JOIN	msdb..sysjobsteps sjs WITH(NOLOCK)
			ON	sj.job_id = sjs.job_id
		WHERE	sj.job_id =
				CAST(
				 SUBSTRING(@APPName,@P1+7,2)
				+SUBSTRING(@APPName,@P1+5,2)
				+SUBSTRING(@APPName,@P1+3,2)
				+SUBSTRING(@APPName,@P1+1,2)
				+'-'
				+SUBSTRING(@APPName,@P1+11,2)
				+SUBSTRING(@APPName,@P1+9,2)
				+'-'
				+SUBSTRING(@APPName,@P1+15,2)
				+SUBSTRING(@APPName,@P1+13,2)
				+'-'
				+SUBSTRING(@APPName,@P1+17,2)
				+SUBSTRING(@APPName,@P1+19,2)
				+'-'
				+SUBSTRING(@APPName,@P1+21,2)
				+SUBSTRING(@APPName,@P1+23,2)
				+SUBSTRING(@APPName,@P1+25,2)
				+SUBSTRING(@APPName,@P1+27,2)		
				+SUBSTRING(@APPName,@P1+29,2)
				+SUBSTRING(@APPName,@P1+31,2)
				AS 	UniqueIdentifier)
			AND	sjs.step_id	= CAST(SUBSTRING(@APPName,@P2,CHARINDEX(')',@APPName,@P2)-@P2)AS INT)	
	END
		
	RETURN @APPName
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_FileAccess_Read]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_FileAccess_Read]
GO
CREATE FUNCTION [dbo].[dbaudf_FileAccess_Read]
						(
						@Path VARCHAR(4000)
						,@Filename VARCHAR(1024)= NULL -- CAN BE NULL IF PASSING THE FILENAME AS PART OF THE PATH
						)
						RETURNS @File TABLE
								(
								[LineNo]	int identity(1,1)
								,[line]		varchar(8000)
								) 

/**************************************************************
 **  User Defined Function dbaudf_CheckFileStatus                  
 **  Written by Steve Ledridge, Getty Images                
 **  April 01, 2005                                      
 **  
 **  This dbaudf is set up to read a file into a table.
 ***************************************************************/
as

--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	04/01/2010	Steve Ledridge		New process
--	01/13/2011	Steve Ledridge		Modified to detect ASCII/UNICODE and READ CORRECTLY
--  04/04/2011	Steve Ledridge		Modified to allow @Path to be path and file name.
--	======================================================================================

BEGIN

	DECLARE  @objFileSystem int
			,@objTextStream int
			,@objErrorObject int
			,@strErrorMessage Varchar(1000)
			,@Command varchar(1000)
			,@hr int
			,@String VARCHAR(8000)
			,@YesOrNo INT
			,@OpenAsUnicode int
			,@TextStreamTest nvarchar(10)
			,@char_value int
			,@RetryCount	int


	SET	@RetryCount	= 0
	step1:
	SELECT	@strErrorMessage ='opening the File System Object'
	EXECUTE	@hr = sp_OACreate  'Scripting.FileSystemObject' , @objFileSystem OUT
		IF @hr != 0 
		BEGIN
			SET @RetryCount = @RetryCount + 1
			IF @RetryCount > 5 
			BEGIN
				GOTO DoneReading
			END
			goto step1
		END

	Select	@objErrorObject		= @objFileSystem
			,@strErrorMessage	= 'Opening file "'+@path+'\'+@filename+'"'
			,@command			= @path+COALESCE(CASE WHEN RIGHT(@Path,1) = '\' THEN '' ELSE '\' END+@filename,'')

	SET	@RetryCount	= 0
	step2:
	EXECUTE	@hr = sp_OAMethod @objFileSystem, 'OpenTextFile', @objTextStream OUT, @command, 1, false, 0--for reading, FormatASCII
		IF @hr != 0 
		BEGIN
			SET @RetryCount = @RetryCount + 1
			IF @RetryCount > 5 
			BEGIN
				GOTO DoneReading
			END
			goto step2
		END
	----------------------------------------
	----------------------------------------
	-- CHECK TEXT FORMAT ASCII/UNICODE
	----------------------------------------
	----------------------------------------
	SET	@RetryCount	= 0
	step3:
	--  Read the first byte of the file into @TextStreamTest
	EXECUTE @HR = sp_OAMethod @objTextStream, 'Read(1)', @TextStreamTest OUTPUT
		IF @hr != 0 AND @hr !=  -2146828226
		BEGIN
			SET @RetryCount = @RetryCount + 1
			IF @RetryCount > 5 
			BEGIN
				GOTO DoneReading
			END
			goto step3
		END
		
	IF @HR = -2146828226   -- (File was empty)
		SELECT @char_value = 65  -- force an ascii value (small 'a')
	ELSE
		SELECT @char_value = unicode(@TextStreamTest)

	--  Test the first bite of the file.  Unicode files will have char(239), char(254), char(255) or null at the start.
	If (@char_value in (239, 254, 255) or @char_value is null)
	   SET @OpenAsUnicode = -1
	else
	   SET @OpenAsUnicode = 0
	----------------------------------------
	----------------------------------------
	-- REOPEN FILE AS CORRECT FORMAT
	----------------------------------------
	----------------------------------------
	SET	@RetryCount	= 0
	step4:
	execute @hr = sp_OAMethod   @objFileSystem  , 'OpenTextFile', @objTextStream OUT, @command,1,false,@OpenAsUnicode
		IF @hr != 0 
		BEGIN
			SET @RetryCount = @RetryCount + 1
			IF @RetryCount > 5 
			BEGIN
				GOTO DoneReading
			END
			goto step4
		END	
	----------------------------------------
	----------------------------------------
	CheckFile:
	SET	@RetryCount	= 0
	execute @hr = sp_OAGetProperty @objTextStream, 'AtEndOfStream', @YesOrNo OUTPUT
		IF @hr != 0 
		BEGIN
			SET @RetryCount = @RetryCount + 1
			IF @RetryCount > 5 
			BEGIN
				GOTO DoneReading
			END
			goto CheckFile
		END	
		
		
	WHILE @YesOrNo	= 0
	BEGIN
		ReadLine:
		SET	@RetryCount	= 0
		execute @hr = sp_OAMethod  @objTextStream, 'Readline', @String OUTPUT
			IF @hr != 0 
			BEGIN
				SET @RetryCount = @RetryCount + 1
				IF @RetryCount > 5 
				BEGIN
					GOTO DoneReading
				END
				goto ReadLine
			END	
			
		INSERT INTO @file(line) SELECT @String

		CheckFile2:
		SET	@RetryCount	= 0
		execute @hr = sp_OAGetProperty @objTextStream, 'AtEndOfStream', @YesOrNo OUTPUT
			IF @hr != 0 
			BEGIN
				SET @RetryCount = @RetryCount + 1
				IF @RetryCount > 5 
				BEGIN
					GOTO DoneReading
				END
				goto CheckFile2
			END			
	END
	
	DoneReading:

	IF @objTextStream IS NOT NULL
		execute @hr = sp_OAMethod  @objTextStream, 'Close'
			IF @hr != 0 
			BEGIN
				SET @RetryCount = @RetryCount + 1
				IF @RetryCount > 5 
				BEGIN
					GOTO Destroy
				END
				goto DoneReading
			END		

	Destroy:
	IF @objTextStream IS NOT NULL			
		EXECUTE  @hr = sp_OADestroy @objTextStream
			IF @hr != 0 
			BEGIN
				SET @RetryCount = @RetryCount + 1
				IF @RetryCount > 5 
				BEGIN
					GOTO ExitCodeA
				END
				goto Destroy
			END
	ExitCodeA:
	IF @objFileSystem IS NOT NULL			
		EXECUTE  @hr = sp_OADestroy @objFileSystem
			IF @hr != 0 
			BEGIN
				SET @RetryCount = @RetryCount + 1
				IF @RetryCount > 5 
				BEGIN
					GOTO ExitCodeB
				END
				goto ExitCodeA
			END					
	ExitCodeB:
	RETURN 
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetFileProperty]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_GetFileProperty]
GO
CREATE FUNCTION [dbo].[dbaudf_GetFileProperty] (@filename varchar(8000),@GetAs VarChar(50),@property VarChar(255))
RETURNS VarChar(2048)
AS
BEGIN
    DECLARE @rv int 
    DECLARE @fso int 
    DECLARE @file int 
    DECLARE @Results VarChar(2048) 
    
    IF @GetAs NOT IN (
			'File'
			,'Folder'
			,'Drive'
			)
    BEGIN
	SET @Results = @GetAs +' is Not A Valid @GetAs Value. Use File, Folder, or Drive.'
	RETURN @Results
    END	
        
    IF (@GetAs = 'File' AND @property NOT IN	(
						'Drive'
						,'ParentFolder'
						,'Path'
						,'ShortPath'
						,'Name'
						,'ShortName'						
						,'Type'
						,'DateCreated'
						,'DateLastAccessed'
						,'DateLastModified'
						,'Attributes'
						,'size'
						))
    OR (@GetAs = 'Folder' AND @property NOT IN	(
						'Drive'
						,'ParentFolder'
						,'Path'
						,'ShortPath'
						,'Name'
						,'ShortName'						
						,'Type'
						,'DateCreated'
						,'DateLastAccessed'
						,'DateLastModified'
						,'Attributes'
						,'Size'
						,'Files'
						,'SubFolders'
						,'IsRootFolder'
						))
												
    OR (@GetAs = 'Drive' AND @property NOT IN	(
						'TotalSize'
						,'AvailableSpace'
						,'FreeSpace'
						,'DriveLetter'
						,'DriveType'
						,'SerialNumber'
						,'FileSystem'
						,'IsReady'
						,'ShareName'
						,'VolumeName'
						,'Path'
						,'RootFolder'
						))						
    BEGIN
	SET @Results = '"'+ @property +'" is Not A Valid @Property Name with the "'+@GetAs+'" @GetAs Value.'
	RETURN @Results
    END			
        
    EXEC @rv = sp_OACreate 'Scripting.FileSystemObject', @fso OUT 
    IF @rv = 0
    BEGIN 
	SET @GetAs =	CASE @GetAs
			WHEN 'File'	THEN 'GetFile'
			WHEN 'Folder'	THEN 'GetFolder'
			WHEN 'Drive'	THEN 'GetDrive'
			END
			
	EXEC @rv = sp_OAMethod @fso, @GetAs, @file OUT, @filename
	IF @rv = 0
	BEGIN
		EXEC @rv = sp_OAGetProperty @file, @Property, @Results OUT
		EXEC @rv = sp_OADestroy @file 
	END 
        EXEC @rv = sp_OADestroy @fso 
    END
    RETURN @Results
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Dir]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_Dir]
GO
CREATE FUNCTION [dbo].[dbaudf_Dir](@Directory VARCHAR(8000))
/* returns a table representing all the items in a folder. It takes as parameter the path to the folder. It does not take wildcards in the same way as a DIR command. Instead, you would be expected to filter the results of the function using SQL commands
Notice that the size of the item (e.g. file) is not returned by this function. 

This function uses the Windows Shell COM object via OLE automation. It opens a folder and iterates though the items listing their relevant properties. You can use the SHELL object to do all manner of things such as printing, copying, and moving filesystem objects, accessing the registry and so on. Powerful medicine.

--e.g.
--list all subdirectories directories beginning with M from "c:\program files"
SELECT [path] FROM dbo.dir('c:\program files') 
       WHERE name LIKE 'm%' AND IsFolder =1
SELECT  * FROM dbo.dir('C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\LOG')

*/
RETURNS @MyDir TABLE 
(
    -- columns returned by the function
       [name] VARCHAR(2000),    --the name of the filesystem object
       [path] VARCHAR(2000),    --Contains the item's full path and name. 
       [ModifyDate] DATETIME,   --the time it was last modified 
       [IsFileSystem] INT,      --1 if it is part of the file system
       [IsFolder] INT,          --1 if it is a folsdder otherwise 0
       [error] VARCHAR(2000)    --if an error occured, gives the error otherwise null
)
AS
-- body of the function
BEGIN
   DECLARE 
       --all the objects used
       @objShellApplication INT, 
       @objFolder INT,
       @objItem INT,
       @objErrorObject INT,
       @objFolderItems INT, 
       --potential error message shows where error occurred.
       @strErrorMessage VARCHAR(1000), 
       --command sent to OLE automation
       @Command VARCHAR(1000), 
       @hr INT, --OLE result (0 if OK)
       @count INT,@ii INT,
       @name VARCHAR(2000),--the name of the current item
       @path VARCHAR(2000),--the path of the current item 
       @ModifyDate DATETIME,--the date the current item last modified
       @IsFileSystem INT, --1 if the current item is part of the file system
       @IsFolder INT --1 if the current item is a file
   IF LEN(COALESCE(@Directory,''))<2 
       RETURN

   SELECT  @strErrorMessage = 'opening the Shell Application Object' 
   EXECUTE @hr = sp_OACreate 'Shell.Application', 
       @objShellApplication OUT 
   --now we get the folder.
   IF @HR = 0  
       SELECT  @objErrorObject = @objShellApplication, 
               @strErrorMessage = 'Getting Folder"' + @Directory + '"', 
               @command = 'NameSpace("'+@Directory+'")' 
   IF @HR = 0  
       EXECUTE @hr = sp_OAMethod @objShellApplication, @command, 
           @objFolder OUT
   IF @objFolder IS NULL RETURN --nothing there. Sod the error message
   --and then the number of objects in the folder
       SELECT  @objErrorObject = @objFolder, 
               @strErrorMessage = 'Getting count of Folder items in "' + @Directory + '"', 
               @command = 'Items.Count' 
   IF @HR = 0  
       EXECUTE @hr = sp_OAMethod @objfolder, @command, 
           @count OUT
    IF @HR = 0 --now get the FolderItems collection 
        SELECT  @objErrorObject = @objFolder, 
                @strErrorMessage = ' getting folderitems',
               @command='items()'
    IF @HR = 0  
        EXECUTE @hr = sp_OAMethod @objFolder, 
            @command, @objFolderItems OUTPUT 
   SELECT @ii = 0
   WHILE @hr = 0 AND @ii< @count --iterate through the FolderItems collection
            BEGIN 
                IF @HR = 0  
                    SELECT  @objErrorObject = @objFolderItems, 
                            @strErrorMessage = ' getting folder item ' 
                                   + CAST(@ii AS VARCHAR(5)),
                           @command='item(' + CAST(@ii AS VARCHAR(5))+')'
                           --@Command='GetDetailsOf('+ cast(@ii as varchar(5))+',1)'
                IF @HR = 0  
                    EXECUTE @hr = sp_OAMethod @objFolderItems, 
                        @command, @objItem OUTPUT 

                IF @HR = 0  
                    SELECT  @objErrorObject = @objItem, 
                            @strErrorMessage = ' getting folder item properties'
                                   + CAST(@ii AS VARCHAR(5))
                IF @HR = 0  
                    EXECUTE @hr = sp_OAMethod @objItem, 
                        'path', @path OUTPUT
                IF @HR = 0  
                    EXECUTE @hr = sp_OAMethod @objItem, 
                        'name', @name OUTPUT
                IF @HR = 0  
                    EXECUTE @hr = sp_OAMethod @objItem, 
                        'ModifyDate', @ModifyDate OUTPUT
                IF @HR = 0  
                    EXECUTE @hr = sp_OAMethod @objItem, 
                        'IsFileSystem', @IsFileSystem OUTPUT
                IF @HR = 0  
                    EXECUTE @hr = sp_OAMethod @objItem, 
                        'IsFolder', @IsFolder OUTPUT
               --and insert the properties into a table
               INSERT INTO @MyDir ([NAME], [path], ModifyDate, IsFileSystem, IsFolder)
                   SELECT @NAME, @path, @ModifyDate, @IsFileSystem, @IsFolder
               IF @HR = 0  EXECUTE sp_OADestroy @objItem 
               SELECT @ii=@ii+1
            END 
        IF @hr <> 0  
            BEGIN 
                DECLARE @Source VARCHAR(255), 
                    @Description VARCHAR(255), 
                    @Helpfile VARCHAR(255), 
                    @HelpID INT 
     
                EXECUTE sp_OAGetErrorInfo @objErrorObject, @source OUTPUT, 
                    @Description OUTPUT, @Helpfile OUTPUT, @HelpID OUTPUT 
                SELECT  @strErrorMessage = 'Error whilst ' 
                        + COALESCE(@strErrorMessage, 'doing something') + ', ' 
                        + COALESCE(@Description, '') 
                INSERT INTO @MyDir(error) SELECT  LEFT(@strErrorMessage,2000) 
            END 
        EXECUTE sp_OADestroy @objFolder 
        EXECUTE sp_OADestroy @objShellApplication

RETURN
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_FileAccess_Dir]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_FileAccess_Dir]
GO
CREATE FUNCTION [dbo].[dbaudf_FileAccess_Dir]
	(
	@RootDir			VARCHAR(1024)
	,@Subdirectories	BIT=0
	,@details			BIT=1
	)

RETURNS @FileTable TABLE 
                   (
                   [MyID]				INT IDENTITY(1,1)
                   ,[name]				VARCHAR(1024) 
                   ,[FullPathName]		VARCHAR(2048)
                   ,[ShortPath]			VARCHAR(2048)
                   ,[Type]				VARCHAR(100)
                   ,[DateCreated]		DATETIME
                   ,[DateLastAccessed]	DATETIME
                   ,[DateLastModified]	DATETIME
                   ,[Attributes]		INT
                   ,[size]				BIGINT
                   ,[error]				VARCHAR(2000)
                   )
AS
BEGIN
DECLARE		@hr						INT				--the HRESULT returned from 
			,@objFileSystem			INT				--the FileSystem object
			,@objFile				INT				--the File object
			,@ErrorObject			INT				--the error object
			,@ErrorMessage			VARCHAR(255)	--the potential error message
			,@Path					VARCHAR(4096)
			,@ShortPath				VARCHAR(2048)
			,@Type					VARCHAR(100)
			,@DateCreated			DATETIME
			,@DateLastAccessed		DATETIME
			,@DateLastModified		DATETIME
			,@directory				VARCHAR(2048)
			,@MyID					INT
			,@Attributes			INT
			,@size					BIGINT
			,@ii					INT
			,@iiMax					INT
			,@command				VARCHAR(8000)
			,@FileName				VARCHAR(8000)
			,@more					INT
			,@Source				VARCHAR(255)
			,@Description			VARCHAR(255)
			,@Helpfile				VARCHAR(255)
			,@HelpID				INT

DECLARE		@FileAndDirectoryList	TABLE 
				(
				[MyID]				INT IDENTITY(1,1)
				,[name]				VARCHAR(1024) 
				,[FullPathName]		VARCHAR(2048)
				,[isFolder]			INT
				,[ModifyDate]		DATETIME
				,[error]			VARCHAR(2048)
				,[recursed]			INT DEFAULT 0
				)
SET		@more		= 1


INSERT INTO	@FileAndDirectoryList([name],[fullPathName], [ModifyDate], [IsFolder], [error])
SELECT		[name]
			,[path]
			,[ModifyDate]
			,[IsFolder]
			,[error] 
FROM		dbaadmin.dbo.dbaudf_Dir(@RootDir) 
WHERE		IsFileSystem = 1

IF EXISTS (SELECT * FROM  @FileAndDirectoryList WHERE error IS NOT NULL) 
   RETURN
   
WHILE @subdirectories<>0 AND @more>0
BEGIN
	SELECT		TOP 1  
				@MyID		= MyID
	FROM		@FileAndDirectoryList 
	WHERE		isFolder	= 1 
		AND		recursed	= 0
	SET			@more		= @@rowcount
	IF @more > 0
	BEGIN
		SELECT		@directory		= LEFT([FullPathName],2000)
		FROM		@FileAndDirectoryList 
		WHERE		MyID			= @MyID 
		INSERT INTO	@FileAndDirectoryList ([name],[fullPathName],[ModifyDate], [IsFolder], [error])
		SELECT		[name]
					,[path]
					,[ModifyDate]
					,[IsFolder]
					,[error]
		FROM		dbo.dbaudf_Dir(@directory) 
		WHERE		IsFileSystem	= 1
		
		UPDATE		@FileAndDirectoryList 
			SET		recursed		= 1 
		WHERE		MyID			= @MyID
	END
END

INSERT INTO	@fileTable ([name],[fullPathName],[DateLastModified])
SELECT		[Name]
			,[fullPathName]
			,[ModifyDate] 
FROM		@FileAndDirectoryList
WHERE		isFolder=0
		OR	REVERSE(fullPathName) LIKE 'piz.%'
		
SELECT		@hr				= 0
			,@errorMessage	= 'opening the file system object'
EXEC		@hr = sp_OACreate	'Scripting.FileSystemObject'
								,@objFileSystem OUT

SELECT		@ii=MIN(MyID)
			,@iiMax=MAX(MyID) 
FROM		@FileTable

WHILE @hr=0 AND @ii<=@iiMax AND @Details<>0
BEGIN
	SELECT		@Filename	= FullPathName 
	FROM		@fileTable 
	WHERE		MyID		= @ii
	IF @hr=0
	BEGIN 
		SELECT		@errorMessage		= 'getting the attributes of ''' + @Filename+''''
					,@ErrorObject		= @objFileSystem
		EXEC @hr = sp_OAMethod @objFileSystem,'GetFile',@objFile OUT,@Filename
	END
	
	IF @hr=0 EXEC @hr = sp_OAGetProperty @objFile, 'ShortPath'			,@ShortPath OUT
	IF @hr=0 EXEC @hr = sp_OAGetProperty @objFile, 'Type'				,@Type OUT
	IF @hr=0 EXEC @hr = sp_OAGetProperty @objFile, 'DateCreated'		,@DateCreated OUT
	IF @hr=0 EXEC @hr = sp_OAGetProperty @objFile, 'DateLastAccessed'	,@DateLastAccessed OUT
	IF @hr=0 EXEC @hr = sp_OAGetProperty @objFile, 'DateLastModified'	,@DateLastModified OUT
	IF @hr=0 EXEC @hr = sp_OAGetProperty @objFile, 'Attributes'			,@Attributes OUT
	IF @hr=0 EXEC @hr = sp_OAGetProperty @objFile, 'size'				,@size OUT
	IF @hr=0 
	UPDATE		@FileTable 
		SET 	[ShortPath]			= @ShortPath
		   		,[Type]				= @Type
		   		,[DateCreated]		= @DateCreated
		   		,[DateLastAccessed]	= @DateLastAccessed
		   		,[DateLastModified]	= @DateLastModified
		   		,[Attributes]		= @Attributes
		   		,[size]				= @size
	WHERE		MyID				= @ii
	SELECT		@ii					= @ii + 1
END
IF @hr!=0
BEGIN
	EXECUTE		sp_OAGetErrorInfo	@errorObject,@source OUTPUT,@Description OUTPUT,@Helpfile OUTPUT,@HelpID OUTPUT
	SELECT		@ErrorMessage		= 'Error whilst ' 
									+ @Errormessage 
									+ ', '
									+ @Description
	INSERT INTO	@FileTable (error) 
	SELECT		LEFT(@ErrorMessage,2000) 
END
EXEC sp_OADestroy @objFile
EXEC sp_OADestroy @objFileSystem
RETURN
END
GO




USE [DEPLinfo]
GO
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'dbasp_FileAccess_Write')
DROP SYNONYM [dbo].[dbasp_FileAccess_Write]
GO
CREATE SYNONYM [dbo].[dbasp_FileAccess_Write]		FOR [dbaadmin].[dbo].[dbasp_FileAccess_Write]
GO
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'dbasp_Print')
DROP SYNONYM [dbo].[dbasp_Print]
GO
CREATE SYNONYM [dbo].[dbasp_Print]					FOR [dbaadmin].[dbo].[dbasp_Print]
GO
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'dbasp_UnlockAndDelete')
DROP SYNONYM [dbo].[dbasp_UnlockAndDelete]
GO
CREATE SYNONYM [dbo].[dbasp_UnlockAndDelete]		FOR [dbaadmin].[dbo].[dbasp_UnlockAndDelete]
GO
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'dbasp_RunTSQL')
DROP SYNONYM [dbo].[dbasp_RunTSQL]
GO
CREATE SYNONYM [dbo].[dbasp_RunTSQL]				FOR [dbaadmin].[dbo].[dbasp_RunTSQL]
GO
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'dbaudf_APP_NAME')
DROP SYNONYM [dbo].[dbaudf_APP_NAME]
GO
CREATE SYNONYM [dbo].[dbaudf_APP_NAME]				FOR [dbaadmin].[dbo].[dbaudf_APP_NAME]
GO
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'dbaudf_FileAccess_Read')
DROP SYNONYM [dbo].[dbaudf_FileAccess_Read]
GO
CREATE SYNONYM [dbo].[dbaudf_FileAccess_Read]		FOR [dbaadmin].[dbo].[dbaudf_FileAccess_Read]
GO
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'dbaudf_GetFileProperty')
DROP SYNONYM [dbo].[dbaudf_GetFileProperty]
GO
CREATE SYNONYM [dbo].[dbaudf_GetFileProperty]		FOR [dbaadmin].[dbo].[dbaudf_GetFileProperty]
GO
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'dbaudf_Dir')
DROP SYNONYM [dbo].[dbaudf_Dir]
GO
CREATE SYNONYM [dbo].[dbaudf_Dir]					FOR [dbaadmin].[dbo].[dbaudf_Dir]
GO
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'dbaudf_FileAccess_Dir')
DROP SYNONYM [dbo].[dbaudf_FileAccess_Dir]
GO
CREATE SYNONYM [dbo].[dbaudf_FileAccess_Dir]		FOR [dbaadmin].[dbo].[dbaudf_FileAccess_Dir]
GO
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'dbasp_RunTSQL')
DROP SYNONYM [dbo].[dbasp_RunTSQL]
GO
CREATE SYNONYM [dbo].[dbasp_RunTSQL]				FOR [dbaadmin].[dbo].[dbasp_RunTSQL]
GO
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'dbaudf_ReturnPart')
DROP SYNONYM [dbo].[dbaudf_ReturnPart]
GO
CREATE SYNONYM [dbo].[dbaudf_ReturnPart]			FOR [dbaadmin].[dbo].[dbaudf_ReturnPart]
GO


	