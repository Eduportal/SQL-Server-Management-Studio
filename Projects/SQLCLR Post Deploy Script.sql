GO
:SETVAR DatabaseName "dbaadmin"
:SETVAR Assembly "GettyImages.Operations.CLRTools"



USE [$(DatabaseName)]
GO
SET NOCOUNT ON
SET CONCAT_NULL_YIELDS_NULL ON

DECLARE	@FileName_SQL		VarChar(max)
	,@FileName_XML		VarChar(max)
	,@FileName_OUT		VarChar(max)
	,@XML			XML
	,@DOC			VarChar(MAX)
	,@Text			VarChar(max)
	,@AssemblyVersion	sysname
	,@DOC_SQL		VarChar(max)
	,@MemberName		VarChar(1000)
	,@Object_Name		SYSNAME
	,@Object_Id		INT
	,@Object_Schema		SYSNAME
	,@Object_Type		SYSNAME
	,@Script		VarChar(max)
	,@CB_DatabaseName	SYSNAME
	,@CB_SchemaName		SYSNAME
	,@CB_ObjectType		SYSNAME
	,@CB_ObjectName		SYSNAME
	,@CB_Version		SYSNAME
	,@CB_CreatedBy		SYSNAME
	,@CB_CreatedOn		DATETIME
	,@CB_BldNum		SYSNAME
	,@CB_BldApp		SYSNAME
	,@CB_BldBrnch		SYSNAME
	,@CB_Purpose		VARCHAR(max)
	,@CB_Description	VARCHAR(max)
	,@CommentHeader		XML
	,@Parameters		XML
	,@Summary		XML
	,@Member		XML
	,@CRLF			CHAR(2)
	,@PartNumber		INT
	,@ComBlkPart		nVarChar(4000)
	,@PropertyName		nVarChar(4000)
	,@SourceCodePath	VarChar(max)
	
SET	@CRLF			= CHAR(13)+CHAR(10)
SET	@SourceCodePath		= '\\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_2005\'
SET	@FileName_SQL		= @SourceCodePath+'$(Assembly).SQL'
SET	@FileName_XML		= @SourceCodePath+'$(Assembly).XML'
SET	@FileName_OUT		= @SourceCodePath+'ALL_dbaadmin_32_CLR.SQL'

exec $(DatabaseName).dbo.dbasp_FileAccess_Read_Blob @FileName_SQL, @DOC_SQL OUT

exec $(DatabaseName).dbo.dbasp_FileAccess_Read_Blob @FileName_XML, @DOC OUT
SET @XML = CONVERT(XML,@DOC,1)	

BEGIN	-- ADD COMMENT BLOCK EXTENDED PROPERTIES TO ASSEMBLY OBJECTS

	DECLARE		OBJECT_CURSOR CURSOR
	FOR
	WITH		XMLData
			AS
			(
			SELECT	a.b.value('@name','sysname')	MemberName
				,b.query('.//CommentHeader')	CommentHeader
				,b.query('./param')		[Parameters]
				,b.query('./summary')		Summary
				,b.query('.')			Member
			FROM	@XML.nodes('doc/members/member') a(b)
			)
			,ObjectInfo
			AS
			(
			SELECT		--DISTINCT
					MemberName
					,[Object_Name]		= PARSENAME(SUBSTRING(MemberName,CHARINDEX(':',MemberName)+1,CHARINDEX('(',MemberName+'(')-CHARINDEX(':',MemberName)-1),1)
					,[Object_Id]		= OBJECT_ID(PARSENAME(SUBSTRING(MemberName,CHARINDEX(':',MemberName)+1,CHARINDEX('(',MemberName+'(')-CHARINDEX(':',MemberName)-1),1))
					,[Object_Schema]	= OBJECT_SCHEMA_NAME(OBJECT_ID(PARSENAME(SUBSTRING(MemberName,CHARINDEX(':',MemberName)+1,CHARINDEX('(',MemberName+'(')-CHARINDEX(':',MemberName)-1),1)))
					,[Object_Type]		= CASE ObjectpropertyEX(OBJECT_ID(PARSENAME(SUBSTRING(MemberName,CHARINDEX(':',MemberName)+1,CHARINDEX('(',MemberName+'(')-CHARINDEX(':',MemberName)-1),1)),'BaseType')
									WHEN 'AF' THEN 'AGGREGATE'	-- Aggregate function (CLR)
									WHEN 'FS' THEN 'FUNCTION'	-- Assembly (CLR) scalar-function
									WHEN 'FT' THEN 'FUNCTION'	-- Assembly (CLR) table-valued function
									WHEN 'PC' THEN 'PROCEDURE'	-- Assembly (CLR) stored-procedure
									END
					,[CommentHeader]
			FROM		XMLData
			WHERE		OBJECT_ID(PARSENAME(SUBSTRING(MemberName,CHARINDEX(':',MemberName)+1,CHARINDEX('(',MemberName+'(')-CHARINDEX(':',MemberName)-1),1)) IS NOT NULL
			)
			,CommentBlock
			AS
			(
			SELECT		MemberName
					,[DatabaseName]	= XMLData.CommentHeader.value('/CommentHeader[1]/VersionControl[1]/DatabaseName[1]','sysname')
					,[Object_Schema]= XMLData.CommentHeader.value('/CommentHeader[1]/VersionControl[1]/SchemaName[1]','sysname')
					,[ObjectType]	= XMLData.CommentHeader.value('/CommentHeader[1]/VersionControl[1]/ObjectType[1]','sysname')
					,[Object_Name]	= XMLData.CommentHeader.value('/CommentHeader[1]/VersionControl[1]/ObjectName[1]','sysname')
					,[Version]	= XMLData.CommentHeader.value('/CommentHeader[1]/VersionControl[1]/Version[1]','sysname')
					,[CreatedBy]	= XMLData.CommentHeader.value('/CommentHeader[1]/VersionControl[1]/Created[1]/@By','sysname')
					,[CreatedOn]	= XMLData.CommentHeader.value('/CommentHeader[1]/VersionControl[1]/Created[1]/@On','datetime')
					,[BldNum]	= XMLData.CommentHeader.value('/CommentHeader[1]/VersionControl[1]/Build[1]/@Number','sysname')
					,[BldApp]	= XMLData.CommentHeader.value('/CommentHeader[1]/VersionControl[1]/Build[1]/@Application','sysname')
					,[BldBrnch]	= XMLData.CommentHeader.value('/CommentHeader[1]/VersionControl[1]/Build[1]/@Branch','sysname')
					,[Purpose]	= XMLData.CommentHeader.value('/CommentHeader[1]/Purpose[1]','varchar(max)')
					,[Description]	= XMLData.CommentHeader.value('/CommentHeader[1]/Description[1]','varchar(max)')
			FROM		XMLData 
			WHERE		LEN(ISNULL(CAST(CommentHeader AS VarChar(max)),'')) > 0
			)
	SELECT		OI.*
			,CB.[Purpose]
			,CB.[Description]	
	FROM		ObjectInfo OI
	LEFT JOIN	CommentBlock CB
		ON	OI.MemberName = CB.MemberName
	ORDER BY	OI.[Object_Type],OI.[Object_Schema],OI.[Object_Name]

	OPEN OBJECT_CURSOR
	FETCH NEXT FROM OBJECT_CURSOR INTO @MemberName,@Object_Name,@Object_Id,@Object_Schema,@Object_Type,@CommentHeader,@CB_Purpose,@CB_Description
	WHILE (@@fetch_status <> -1)		       	
	BEGIN					       
		IF (@@fetch_status <> -2)	       
		BEGIN
			--PRINT @MemberName
			PRINT @Object_Type+'  '+@Object_Schema+'.'+@Object_Name
			
			IF	------	REMOVE EXISTING COMMENT BLOCK EXTENDED PROPERTY	--
			EXISTS (SELECT * From fn_listExtendedProperty(DEFAULT,'SCHEMA',@Object_Schema,@Object_Type,@Object_Name,null,null) WHERE name Like 'CommentBlock%')
			BEGIN
				DECLARE CommentBlockPartCursor CURSOR
				FOR
				SELECT name 
				From fn_listExtendedProperty(DEFAULT,'SCHEMA',@Object_Schema,@Object_Type,@Object_Name,null,null) 
				WHERE name Like 'CommentBlock%'

				OPEN CommentBlockPartCursor
				FETCH NEXT FROM CommentBlockPartCursor INTO @PropertyName
				WHILE (@@fetch_status <> -1)
				BEGIN
					IF (@@fetch_status <> -2)
					BEGIN
						PRINT '  -- REMOVING EXISTING "'+@PropertyName+'" EXTENDED PROPERTIES.'

						EXEC sys.sp_dropextendedproperty 
							@name = @PropertyName, 
							@level0type = N'SCHEMA',@level0name = @Object_Schema,
							@level1type = @Object_Type,@level1name = @Object_Name
					END
					FETCH NEXT FROM CommentBlockPartCursor INTO @PropertyName
				END
				CLOSE CommentBlockPartCursor
				DEALLOCATE CommentBlockPartCursor
			END		
			
			------	ADD COMMENT BLOCK EXTENDED PROPERTY	--
			DECLARE CommentBlockPartCursor CURSOR
			FOR
			SELECT	*
			From dbaadmin.dbo.dbaudf_SplitSize(dbaadmin.dbo.dbaudf_FormatXML2String(@CommentHeader),7500)
			OPEN CommentBlockPartCursor
			FETCH NEXT FROM CommentBlockPartCursor INTO @PartNumber,@ComBlkPart
			WHILE (@@fetch_status <> -1)
			BEGIN
				IF (@@fetch_status <> -2)
				BEGIN
					SET @PropertyName = 'CommentBlock_'+CAST(@PartNumber AS VarChar(10))
					PRINT '  -- SAVING "'+@PropertyName+'" EXTENDED PROPERTY.'
					
					EXEC sys.sp_addextendedproperty
						@name = @PropertyName,
						@level0type = N'SCHEMA',@level0name = @Object_Schema,
						@level1type = @Object_Type,@level1name = @Object_Name,
						@value = @ComBlkPart
				END
				FETCH NEXT FROM CommentBlockPartCursor INTO @PartNumber,@ComBlkPart
			END
			CLOSE CommentBlockPartCursor
			DEALLOCATE CommentBlockPartCursor
		END
		FETCH NEXT FROM OBJECT_CURSOR INTO @MemberName,@Object_Name,@Object_Id,@Object_Schema,@Object_Type,@CommentHeader,@CB_Purpose,@CB_Description
	END
	CLOSE OBJECT_CURSOR
	DEALLOCATE OBJECT_CURSOR
END

BEGIN	--WRITE HEADER TO OUTPUT FILE CONTAINING ALL DROPS OF ASSEMBLY OBJECTS

	SELECT		@Script = 'USE [MASTER]'+@CRLF
			+'GO'+@CRLF
			+'ALTER DATABASE [dbaadmin] SET TRUSTWORTHY ON'+@CRLF
			+'GO'+@CRLF
			+'exec sp_configure ''clr enabled'' , 1'+@CRLF
			+'GO'+@CRLF
			+'RECONFIGURE WITH OVERRIDE'+@CRLF
			+'GO'+@CRLF
			+'USE [dbaadmin]'+@CRLF
			+'GO'+@CRLF
			+'IF @@VERSION LIKE ''Microsoft SQL Server 2012%'''+@CRLF
			+'BEGIN'+@CRLF
			+'	IF NOT EXISTS(select * From sys.assemblies WHERE name = ''System.Management'')'+@CRLF
			+'		exec(''CREATE ASSEMBLY [System.Management]'+@CRLF
			+'		AUTHORIZATION [dbo]'+@CRLF
			+'		FROM ''''C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\System.Management.dll'''''+@CRLF
			+'		WITH PERMISSION_SET = UNSAFE'')'+@CRLF
			+'END'+@CRLF
			+'ELSE'+@CRLF
			+'BEGIN'+@CRLF
			+'	IF NOT EXISTS(select * From sys.assemblies WHERE name = ''System.Management'')'+@CRLF
			+'		exec(''CREATE ASSEMBLY [System.Management]'+@CRLF
			+'		AUTHORIZATION [dbo]'+@CRLF
			+'		FROM ''''C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\System.Management.dll'''''+@CRLF
			+'		WITH PERMISSION_SET = UNSAFE'')'+@CRLF
			+'END'+@CRLF
			+'GO'+@CRLF+@CRLF
			+'DECLARE		@CMD		VarChar(max)'+@CRLF
			+'		,@CRLF		CHAR(2)'+@CRLF+@CRLF
			+'SELECT		@CMD		= '''''+@CRLF
			+'		,@CRLF		= CHAR(13)+CHAR(10)'+@CRLF+@CRLF
			+';WITH		CLR_Objects'+@CRLF
			+'		AS'+@CRLF
			+'		('+@CRLF
			+'		SELECT      so.name [object_name]'+@CRLF
			+'			    ,so.[type] [object_type]'+@CRLF
			+'			    ,SCHEMA_NAME(so.schema_id) AS [object_schema]'+@CRLF
			+'			    ,asmbly.name [assembly_name]'+@CRLF
			+'			    ,asmbly.permission_set_desc'+@CRLF
			+'			    ,am.assembly_class'+@CRLF
			+'			    ,am.assembly_method'+@CRLF
			+'		FROM        sys.assembly_modules am'+@CRLF
			+'		INNER JOIN  sys.assemblies asmbly'+@CRLF
			+'			ON  asmbly.assembly_id = am.assembly_id'+@CRLF
			+'			AND asmbly.name NOT LIKE ''Microsoft%'''+@CRLF
			+'		INNER JOIN  sys.objects so'+@CRLF
			+'			ON  so.object_id = am.object_id'+@CRLF
			+'		UNION'+@CRLF
			+'		SELECT      at.name, ''TYPE'' AS [type], SCHEMA_NAME(at.schema_id) AS [Schema],'+@CRLF 
			+'			    asmbly.name, asmbly.permission_set_desc, at.assembly_class,'+@CRLF
			+'			    NULL AS [assembly_method]'+@CRLF
			+'		FROM        sys.assembly_types at'+@CRLF
			+'		INNER JOIN  sys.assemblies asmbly'+@CRLF
			+'			ON  asmbly.assembly_id = at.assembly_id'+@CRLF
			+'			AND asmbly.name NOT LIKE ''Microsoft%'''+@CRLF
			+'		)'+@CRLF
			+'SELECT		@CMD = @CMD + @CRLF'+@CRLF
			+'		+ ''PRINT ''''Dropping [''+[object_schema]+''].[''+[object_name]+'']...'''';''+@CRLF'+@CRLF
			+'		+ ''IF OBJECT_ID(''''[''+[object_schema]+''].[''+[object_name]+'']'''') IS NOT NULL'' + @CRLF'+@CRLF
			+'		+''     DROP '''+@CRLF
			+'		+ CASE [object_type]'+@CRLF
			+'			WHEN ''AF'' THEN ''AGGREGATE''	-- Aggregate function (CLR)'+@CRLF
			+'			WHEN ''FS'' THEN ''FUNCTION''	-- Assembly (CLR) scalar-function'+@CRLF
			+'			WHEN ''FT'' THEN ''FUNCTION''	-- Assembly (CLR) table-valued function'+@CRLF
			+'			WHEN ''PC'' THEN ''PROCEDURE''	-- Assembly (CLR) stored-procedure'+@CRLF
			+'			END'+@CRLF
			+'		+ '' [''+[object_schema]+''].[''+[object_name]+'']'''+@CRLF
			+'		+ @CRLF+''--GO''+@CRLF+@CRLF'+@CRLF
			+'FROM		CLR_Objects'+@CRLF
			+'WHERE		[assembly_name] = ''$(Assembly)'''+@CRLF
			+'EXEC		(@CMD)'+@CRLF
			+'GO'+@CRLF+@CRLF
			+'PRINT N''Dropping [$(Assembly)]...'';'+@CRLF+'GO'+@CRLF
			+'PRINT N'''';'+@CRLF+'GO'+@CRLF
			+dbaadmin.dbo.dbaudf_ScriptObject('$(Assembly)',1,0,0,0,'',0,0)

	-- START WRITING TO OUTPUT FILE AND ERASE WHAT ALREADY EXISTED THERE
	-- WRITING ALL DROP SECTION
	EXEC $(DatabaseName).dbo.dbasp_FileAccess_Write @Script,@FileName_OUT,0,1
END
	
BEGIN	------	GENERATE AND APPEND ASSEMBLY CREATE SCRIPT		


	SELECT		@Script = dbaadmin.dbo.dbaudf_ScriptObject('$(Assembly)',0,1,0,0,'',0,0)+@CRLF

	DECLARE CommentBlockPartCursor CURSOR
	FOR
	SELECT	* 
	From	$(DatabaseName).dbo.dbaudf_SplitSize(@Script,4000)
	OPEN CommentBlockPartCursor
	FETCH NEXT FROM CommentBlockPartCursor INTO @PartNumber,@ComBlkPart
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			-- WRITING TO OUTPUT FILE APPENDING TO WHAT ALREADY EXISTED THERE
			-- WRITING IN MULTIPLE PARTS BECAUSE OF SIZE AND NOT FORCING CRLF BETWEEN WRITES
			-- WRITING CREATE ASSEMBLY SECTION
			EXEC $(DatabaseName).dbo.dbasp_FileAccess_Write @ComBlkPart,@FileName_OUT,1,0

		END
		FETCH NEXT FROM CommentBlockPartCursor INTO @PartNumber,@ComBlkPart
	END
	CLOSE CommentBlockPartCursor
	DEALLOCATE CommentBlockPartCursor

END



--SELECT		so.name [object_name]
--		,so.[type] [object_type]
--		,SCHEMA_NAME(so.schema_id) AS [object_schema]
--		,asmbly.name [assembly_name]
--		,asmbly.permission_set_desc
--		,am.assembly_class
--		,am.assembly_method
DECLARE		@TestCode VARCHAR(MAX)
SET		@TestCode = '
GO
DECLARE @ObjectName sysname
SET	@ObjectName = ''$ObjectName$''

IF OBJECT_ID(@ObjectName) IS NOT NULL
	RAISERROR(''    %s Created Successfully...'',-1,-1,@ObjectName) WITH NOWAIT
ELSE	
	RAISERROR(''*** %s Creation Failed...'',16,1,@ObjectName) WITH NOWAIT
GO'
	

SELECT		-- OVERWRITE INDIVIDUAL SCRIPT FILES IN THE SOURCE DIRECTORY
		dbo.dbaudf_ScriptObject(SCHEMA_NAME(so.schema_id)+'.'+so.name,1,1,0,0,@SourceCodePath+so.name+'.sql',0,0)
		,dbo.dbaudf_FileAccess_Write(REPLACE(@TestCode,'$ObjectName$',SCHEMA_NAME(so.schema_id)+'.'+so.name),@SourceCodePath+so.name+'.sql',1,1)

		-- APPEND TO THE ALL_dbaadmin_32_CLR.SQL FILE IN THE SOURCE DIRECTORY
		,dbo.dbaudf_ScriptObject(SCHEMA_NAME(so.schema_id)+'.'+so.name,1,1,0,0,@FileName_OUT,1,1)
		,dbo.dbaudf_FileAccess_Write(REPLACE(@TestCode,'$ObjectName$',SCHEMA_NAME(so.schema_id)+'.'+so.name),@FileName_OUT,1,1)

FROM		sys.assembly_modules am
INNER JOIN	sys.assemblies asmbly
	ON	asmbly.assembly_id = am.assembly_id
INNER JOIN	sys.objects so
	ON	so.object_id = am.object_id
WHERE		asmbly.name	= '$(Assembly)'	
ORDER BY	SCHEMA_NAME(so.schema_id)
		,so.name


GO