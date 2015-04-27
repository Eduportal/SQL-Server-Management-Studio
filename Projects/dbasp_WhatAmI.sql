USE dbaadmin
GO
IF OBJECT_ID('dbaudf_hex_to_char') IS NOT NULL
	DROP function dbaudf_hex_to_char
GO	
CREATE function dbaudf_hex_to_char (
  @x varbinary(100), -- binary hex value
  @l int -- number of bytes
  ) returns varchar(200)
 as 
-- Written by: Gregory A. Larsen
-- Date: May 25, 2004
-- Description:  This function will take any binary value and return 
--               the hex value as a character representation.
--               In order to use this function you need to pass the 
--               binary hex value and the number of bytes you want to
--               convert.
begin

declare @i varbinary(10)
declare @digits char(16)
set @digits = '0123456789ABCDEF'
declare @s varchar(100)
declare @h varchar(100)
declare @j int
set @j = 0 
set @h = ''
-- process all  bytes
while @j < @l
begin
  set @j= @j + 1
  -- get first character of byte
  set @i = substring(cast(@x as varbinary(100)),@j,1)
  -- get the first character
  set @s = cast(substring(@digits,@i%16+1,1) as char(1))
  -- shift over one character
  set @i = @i/16 
  -- get the second character
  set @s = cast(substring(@digits,@i%16+1,1) as char(1)) + @s
  -- build string of hex characters
  set @h = @h + @s
end
return(@h)
end
GO


SET NOCOUNT ON
GO

DROP PROCEDURE	dbasp_WhatAmI
GO
CREATE PROCEDURE	dbasp_WhatAmI
			(
			@NoSelectOut	BIT		= 0
			,@ObjectType	sysname		= NULL OUT
			,@ObjectName	sysname		= NULL OUT
			,@ObjectID	Int		= NULL OUT
			)
AS
BEGIN
	DECLARE		@BinVar	varbinary(128)
			
	-- GET CONTEXT_INFO AND CLEAN OUT RIGHT PADDED 0's
	SELECT	@BinVar	= CAST(REPLACE(CAST(CONTEXT_INFO() AS VarChar(128)),CHAR(0),'') AS VarBinary(128))
	
	IF @BinVar = CAST(CAST(@@PROCID  AS varchar(128)) AS VarBinary(128))
	BEGIN
		-- CLEAR CONTEXT_INFO IF SET TO THIS SPROC
		SET @BinVar = 0x0	
		SET CONTEXT_INFO @BinVar
	END

	SELECT		@ObjectType	= 'SQL AGENT JOB'
			,@ObjectName	= SJ.name
	FROM		master.dbo.sysprocesses p 
	JOIN		msdb.dbo.sysjobs sj
		ON	dbaadmin.dbo.dbaudf_hex_to_char(sj.job_id,16) = SUBSTRING(p.Program_name,32,32)
	where		p.Program_name Like 'SQLAgent%' 
		AND	p.spid = @@spid 

	IF @ObjectName IS NULL
		SELECT		@ObjectType	= type_desc
				,@ObjectName	= name
				,@ObjectID	= object_id
		FROM		sys.objects
		WHERE		object_id = CAST(REPLACE(CAST(@BinVar AS VarChar(128)),CHAR(0),'') AS INT)

	SELECT		@ObjectType = COALESCE(@ObjectType,'UNKNOWN') 
			,@ObjectName = COALESCE(@ObjectName,'UNKNOWN')

	PRINT		'-- ' + @ObjectType + ':' + @ObjectName + ':' + CAST(COALESCE(@ObjectID,'') AS VarChar(50))
	
	If @NoSelectOut = 0
		SELECT @ObjectType AS [OBJECT_TYPE], @ObjectName AS [OBJECT_NAME], @ObjectID AS [OBJECT_ID]
	
	RETURN @ObjectID
END
GO















-- TEST IT


GO
DROP PROCEDURE	test_dbasp_WhatAmI
GO
CREATE PROCEDURE	test_dbasp_WhatAmI
AS
	------------------------------------------------------------------------------
	-- CONTEXT TRACKING HEADER 
	------------------------------------------------------------------------------
	DECLARE	@BinVar	varbinary(128)
	SELECT	@BinVar	= CONTEXT_INFO()
	
	IF @@NESTLEVEL <= 1 
		OR 
		COALESCE(@BinVar,0x0) = 0x0
	BEGIN
		PRINT '-- Setting Context for ' + OBJECT_NAME(@@PROCID) + ' (' + CAST(@@PROCID AS VarChar(50)) + ')...'
		SELECT	@BinVar = CAST(CAST(@@PROCID  AS varchar(128)) AS VarBinary(128))
		SET CONTEXT_INFO @BinVar
	END
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	PRINT ''
	PRINT '-- PERFORM NORMAL SPROC OPERATIONS'
	PRINT ''
	PRINT ''
	-- NORMAL SPROC CODE HERE
	DECLARE	@ObjectType	sysname
		,@ObjectName	sysname
		,@ObjectID	Int
		
		

	PRINT ''
	PRINT '-- GET CONTEXT DATA AS PRINT AND RETURN'
	PRINT ''
	PRINT ''
	-- GET CONTEXT DATA AS PRINT AND RETURN
	exec @ObjectID = dbasp_whatAmI 1 
	PRINT @ObjectID


	PRINT ''
	PRINT '-- GET CONTEXT DATA AS SELECT'
	PRINT ''
	PRINT ''
	-- GET CONTEXT DATA AS SELECT
	exec @ObjectID = dbasp_whatAmI 0 


	PRINT ''
	PRINT '-- GET CONTEXT DATA AS OUTPUT PARAMETERS'
	PRINT ''
	PRINT ''
	-- GET CONTEXT DATA AS OUTPUT PARAMETERS
	exec @ObjectID = dbasp_whatAmI
				 @NoSelectOut	= 1 
				,@ObjectType	= @ObjectType OUT
				,@ObjectName	= @ObjectName OUT
				,@ObjectID	= @ObjectID OUT
	

	PRINT @ObjectType
	PRINT @ObjectName
	PRINT @ObjectID

	PRINT ''
	PRINT '-- DONE WITH TESTS'
	PRINT ''
	PRINT ''

	
	------------------------------------------------------------------------------
	-- CONTEXT CLEAN UP
	------------------------------------------------------------------------------
	SET CONTEXT_INFO 0x0
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
GO


DROP PROCEDURE	test2_dbasp_WhatAmI
GO
CREATE PROCEDURE	test2_dbasp_WhatAmI
AS
	SET ANSI_PADDING OFF
	DECLARE	@BinVar	varbinary(128)
	SELECT	@BinVar	= CONTEXT_INFO()
	
	IF @@NESTLEVEL <= 1 
		OR 
		COALESCE(@BinVar,0x0) = 0x0
	BEGIN
		PRINT '-- Setting Context for ' + OBJECT_NAME(@@PROCID) + ' (' + CAST(@@PROCID AS VarChar(50)) + ')...'
		SELECT	@BinVar = CAST(CAST(@@PROCID  AS varchar(128)) AS VarBinary(128))
		SET CONTEXT_INFO @BinVar
	END

	EXEC  dbasp_whatAmI 1
	SET CONTEXT_INFO 0x0

GO
	
exec test_dbasp_whatAmI
exec test2_dbasp_whatAmI
exec test_dbasp_whatAmI

GO

PRINT COALESCE(OBJECT_NAME(CAST(REPLACE(CAST(CONTEXT_INFO() AS VarChar(128)),CHAR(0),'') AS INT)),'NO_CURRENT_CONTECT')





--JOB STEP TO RESET OUTPUT FILE.....

GO
DROP PROCEDURE	dbo.dbasp_ResetJobLogFileName
GO
CREATE PROCEDURE	dbo.dbasp_ResetJobLogFileName
	(
	@OutputPath		VarChar(8000)
	,@OverideFileName	sysname		= null
	,@StampDate		INT		= 0
	)
AS
BEGIN		
	--	@StampDate		= 0	-- NOT
	--				= 1	-- AT BEGINING OF FILE NAME
	--				= 2	-- AT END OF FILE NAME

	DECLARE	@job_id			UniqueIdentifier
		,@job_name		sysname
		,@output_file_name	VarChar(8000)
		,@step_id		INT

	IF RIGHT(@OutputPath,1) != '\' 
		SET @OutputPath = @OutputPath + '\'

	SELECT		@job_id			= sj.job_id
			,@job_name		= sj.name
			,@output_file_name	= @OutputPath
						+ CASE @StampDate WHEN 1 THEN CONVERT(VarChar(50),GetDate(),127)+'_' ELSE '' END
						+ COALESCE(@OverideFileName,@job_name)
						+ CASE @StampDate WHEN 2 THEN '_'+CONVERT(VarChar(50),GetDate(),127) ELSE '' END
						+ '.log'
	FROM		master.dbo.sysprocesses p 
	JOIN		msdb.dbo.sysjobs sj
		ON	dbaadmin.dbo.dbaudf_hex_to_char(sj.job_id,16) = SUBSTRING(p.Program_name,32,32)
	where		p.Program_name Like 'SQLAgent%' 
		AND	p.spid = @@spid 


	DECLARE JobStepCursor 
	CURSOR
	FOR
	SELECT		step_id
	FROM		msdb.dbo.sysjobsteps
	WHERE		job_id = @job_id
		AND	step_id > 1
		AND	command like '%-- RESETFILENAME --%'
	ORDER BY	step_id	

	OPEN JobStepCursor
	FETCH NEXT FROM JobStepCursor INTO @step_id
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			UPDATE		msdb.dbo.sysjobsteps
				SET	output_file_name	= @output_file_name
					,flags			= 6
			WHERE		job_id			= @job_id
				AND	step_id			= @step_id				

			--EXEC msdb.dbo.sp_update_jobstep @job_id=@job_id, @step_id=@step_id , @flags=6,  @output_file_name=@output_file_name
		END
		FETCH NEXT FROM JobStepCursor INTO @step_id
	END

	CLOSE JobStepCursor
	DEALLOCATE JobStepCursor
		
END
GO		




SELECT		output_file_name
FROM		msdb.dbo.sysjobsteps
WHERE		job_id = 'EFF7A14A-5292-4E54-A7EE-8CC495C2204D'
ORDER BY	step_id	



select * from sysobjects order by crdate desc

E:\Testing_$(ESCAPE_NONE(STRTDT))_$(ESCAPE_NONE(STRTTM)).log