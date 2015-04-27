USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_FileAccess_Read_Tail]    Script Date: 02/26/2013 09:26:32 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_FileAccess_Read_Tail]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_FileAccess_Read_Tail]
GO

USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_FileAccess_Read_Tail]    Script Date: 02/26/2013 09:26:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[dbaudf_FileAccess_Read_Tail]
						(
						@Path		VARCHAR(4000)
						,@Filename	VARCHAR(1024)	= NULL -- CAN BE NULL IF PASSING THE FILENAME AS PART OF THE PATH
						,@TailSize	INT				 = 0
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
--	04/04/2011	Steve Ledridge		Modified to allow @Path to be path and file name.
--	01/25/2013	Steve Ledridge		Made sure all OA Objects are destroyed at end of sproc.
--	======================================================================================
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
					GOTO ExitCode
				END
				goto Destroy
			END	
	ExitCode:
	
	IF @TailSize > 0
	BEGIN
		DELETE @File
		WHERE [LineNo] <= (SELECT MAX([lineno]) From @File)-@TailSize
	END

if @objTextStream IS NOT NULL
	exec sp_OADestroy @objTextStream
	
if @TextStreamTest IS NOT NULL
	exec sp_OADestroy @TextStreamTest
	
IF @objFileSystem IS NOT NULL
	exec sp_OADestroy @objTextStream

		
	RETURN 
END


GO


