USE [DBAADMIN]
GO

IF OBJECT_ID('dbaudf_ExtractClrDdl') IS NOT NULL
	DROP FUNCTION [dbo].[dbaudf_ExtractClrDdl] 
GO	
CREATE FUNCTION [dbo].[dbaudf_ExtractClrDdl] 
	(
	@DOC		VarChar(max)
	,@Object_Type	sysname
	,@Object_Schema	sysname
	,@Object_Name	sysname
	)
RETURNS VarChar(max)
AS
BEGIN
	DECLARE	@Script			VarChar(MAX)
		,@Text			VarChar(max)

	SET @Text = 'CREATE '+@Object_Type+' '+isnull('['+@Object_Schema+'].','')+'['+@Object_Name+']'

	SELECT @SCRIPT = SUBSTRING	(@DOC
				,CHARINDEX(@Text,@DOC)
				,CHARINDEX(CHAR(13)+CHAR(10)+'GO',@DOC,CHARINDEX(@Text,@DOC)+1)
					-CHARINDEX(@Text,@DOC)+4
				)
	RETURN @SCRIPT

END
GO

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
	
	
SET	@CRLF			= CHAR(13)+CHAR(10)
SET	@FileName_SQL		= '\\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_2005\GettyImages.Operations.CLRTools.SQL'
SET	@FileName_XML		= '\\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_2005\GettyImages.Operations.CLRTools.XML'
SET	@FileName_OUT		= '\\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_2005\ALL_dbaadmin_32_CLR.SQL'

exec dbaadmin.dbo.dbasp_FileAccess_Read_Blob @FileName_SQL, @DOC_SQL OUT

BEGIN	------	GET ASSEMBLY VERSION NUMBER				

	SELECT @DOC = cast(content as varchar(max)) FROM sys.assembly_files where name = 'VersionInfo.g.cs'
	SELECT @XML = CAST(SUBSTRING(
					@DOC
					,CHARINDEX('<version>',@DOC)
					,CHARINDEX('</version>',@DOC)+10-CHARINDEX('<version>',@DOC)
					) AS XML)

	SELECT	@AssemblyVersion = a.b.value('/version[1]','sysname') FROM @XML.nodes('/') a(b)
END

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
			+'IF NOT EXISTS(select * From sys.assemblies WHERE name = ''System.Management'')'+@CRLF
			+'	exec(''CREATE ASSEMBLY [System.Management]'+@CRLF
			+'	AUTHORIZATION [dbo]'+@CRLF
			+'	FROM ''''C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\System.Management.dll'''''+@CRLF
			+'	WITH PERMISSION_SET = UNSAFE'')'+@CRLF
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
			+'WHERE		[assembly_name] = ''GettyImages.Operations.CLRTools'''+@CRLF
			+'EXEC		(@CMD)'+@CRLF
			+'GO'+@CRLF+@CRLF
			+'PRINT N''Dropping [GettyImages.Operations.CLRTools]...'';'+@CRLF+'GO'+@CRLF
			+'PRINT N'''';'+@CRLF+'GO'+@CRLF
			+'IF EXISTS(select * From sys.assemblies where name = ''GettyImages.Operations.CLRTools'')'+@CRLF
			+'	DROP ASSEMBLY [GettyImages.Operations.CLRTools]'+@CRLF
			+'GO'+@CRLF

	-- START WRITING TO OUTPUT FILE AND ERASE WHAT ALREADY EXISTED THERE
	-- WRITING ALL DROP SECTION
	EXEC dbaadmin.dbo.dbasp_FileAccess_Write @Script,@FileName_OUT,0,1

	
BEGIN	------	GENERATE COMMENT BLOCK EXTENDED PROPERTIES		
		
	exec dbaadmin.dbo.dbasp_FileAccess_Read_Blob @FileName_XML, @DOC OUT
	SET @XML = CONVERT(XML,@DOC,1)

	SELECT		@Script = 'PRINT N''Creating [GettyImages.Operations.CLRTools]...'';'+@CRLF+'GO'+@CRLF+@CRLF+dbaadmin.dbo.dbaudf_ExtractClrDdl (@DOC_SQL,'ASSEMBLY',NULL,'GettyImages.Operations.CLRTools')+@CRLF

			DECLARE	@PartNumber	INT
				,@ComBlkPart	nVarChar(4000)
			
			DECLARE CommentBlockPartCursor CURSOR
			FOR
			SELECT	* 
			From	dbaadmin.dbo.dbaudf_SplitSize(@Script,4000)
			OPEN CommentBlockPartCursor
			FETCH NEXT FROM CommentBlockPartCursor INTO @PartNumber,@ComBlkPart
			WHILE (@@fetch_status <> -1)
			BEGIN
				IF (@@fetch_status <> -2)
				BEGIN
					-- WRITING TO OUTPUT FILE APPENDING TO WHAT ALREADY EXISTED THERE
					-- WRITING IN MULTIPLE PARTS BECAUSE OF SIZE AND NOT FORCING CRLF BETWEEN WRITES
					-- WRITING CREATE ASSEMBLY SECTION
					EXEC dbaadmin.dbo.dbasp_FileAccess_Write @ComBlkPart,@FileName_OUT,1,0

				END
				FETCH NEXT FROM CommentBlockPartCursor INTO @PartNumber,@ComBlkPart
			END
			CLOSE CommentBlockPartCursor
			DEALLOCATE CommentBlockPartCursor




	DECLARE CLR_DATA_CURSOR CURSOR
	KEYSET
	FOR
	WITH	------	GENERATE CURSOR WITH ALL DATA FOR SCRIPTING			
			XMLData
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
			SELECT		DISTINCT
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
			FROM		XMLData
			WHERE		OBJECT_ID(PARSENAME(SUBSTRING(MemberName,CHARINDEX(':',MemberName)+1,CHARINDEX('(',MemberName+'(')-CHARINDEX(':',MemberName)-1),1)) IS NOT NULL
			)
			,ObjectDDL
			AS
			(
			SELECT		MemberName
					,[Script]	= dbaadmin.dbo.dbaudf_ExtractClrDdl (@DOC_SQL,[Object_Type],[Object_Schema],[Object_Name])
			FROM		ObjectInfo
			)
			,CommentBlock
			AS
			(
			SELECT		MemberName
					,[DatabaseName]	= XMLData.CommentHeader.value('/CommentHeader[1]/VersionControl[1]/DatabaseName[1]','sysname')
					,[SchemaName]	= XMLData.CommentHeader.value('/CommentHeader[1]/VersionControl[1]/SchemaName[1]','sysname')
					,[ObjectType]	= XMLData.CommentHeader.value('/CommentHeader[1]/VersionControl[1]/ObjectType[1]','sysname')
					,[ObjectName]	= XMLData.CommentHeader.value('/CommentHeader[1]/VersionControl[1]/ObjectName[1]','sysname')
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
	SELECT		I.MemberName	
			,I.Object_Name	
			,I.Object_Id	
			,I.Object_Schema	
			,I.Object_Type	
			,D.Script	
			,C.DatabaseName		[CB_DatabaseName]	
			,C.SchemaName		[CB_SchemaName]	
			,C.ObjectType		[CB_ObjectType]	
			,C.ObjectName		[CB_ObjectName]	
			,C.Version		[CB_Version]	
			,C.CreatedBy		[CB_CreatedBy]	
			,C.CreatedOn		[CB_CreatedOn]	
			,C.BldNum		[CB_BldNum]	
			,C.BldApp		[CB_BldApp]	
			,C.BldBrnch		[CB_BldBrnch]	
			,C.Purpose		[CB_Purpose]	
			,C.Description		[CB_Description]	
			,X.CommentHeader	
			,X.Parameters	
			,X.Summary	
			,X.Member

	        
	FROM		ObjectInfo I
	JOIN		ObjectDDL D
		ON	I.MemberName = D.MemberName
	JOIN		CommentBlock C
		ON	I.MemberName = C.MemberName
	JOIN		XMLData X
		ON	I.MemberName = X.MemberName
	ORDER BY	CASE I.Object_Name WHEN 'dbaudf_FormatXML2String' THEN 0 ELSE 1 END
		
	OPEN CLR_DATA_CURSOR
	FETCH NEXT FROM CLR_DATA_CURSOR INTO @MemberName,@Object_Name,@Object_Id,@Object_Schema,@Object_Type,@Script,@CB_DatabaseName,@CB_SchemaName,@CB_ObjectType,@CB_ObjectName,@CB_Version,@CB_CreatedBy,@CB_CreatedOn,@CB_BldNum,@CB_BldApp,@CB_BldBrnch,@CB_Purpose,@CB_Description,@CommentHeader,@Parameters,@Summary,@Member
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			SELECT		@Script = 'PRINT N''Creating ['+@Object_Schema+'].['+@Object_Name+']...'';'+@CRLF
					+ 'GO'+@CRLF+@CRLF+@Script+@CRLF
					+ 'DECLARE	@HeaderXML	XML'+@CRLF
					+ '		,@PartNumber	INT'+@CRLF
					+ '		,@ComBlkPart	VarChar(8000)'+@CRLF
					+ '		,@PropertyName	SYSNAME'+@CRLF
					+ ' 		,@Schema_name	SYSNAME'+@CRLF
					+ '		,@object_name	SYSNAME'+@CRLF
					+ '		,@objectType	SYSNAME'+@CRLF+@CRLF
					+ 'SELECT	@Schema_name	= '''+@Object_Schema+''''+@CRLF
					+ '		,@object_name	= '''+@Object_Name+''''+@CRLF
					+ '		,@objectType	= '''+@Object_Type+''''+@CRLF+@CRLF
					+ 'SET	@HeaderXML = ''' + dbaadmin.dbo.dbaudf_FormatXML2String(@CommentHeader) + ''''+@CRLF+@CRLF


			-- WRITING TO OUTPUT FILE APPENDING TO WHAT ALREADY EXISTED THERE
			-- WRITING CREATE OBJECT SECTION 1
			EXEC dbaadmin.dbo.dbasp_FileAccess_Write @Script,@FileName_OUT,1,1

			SELECT		@Script = @CRLF + 'PRINT '' -- SAVING UPDATED "COMMENT BLOCK_%" EXTENDED PROPERTIES.'''+@CRLF+@CRLF
					+'DECLARE CommentBlockPartCursor CURSOR'+@CRLF
					+'FOR'+@CRLF
					+'SELECT	*'+@CRLF 
					+'From	dbaadmin.dbo.dbaudf_SplitSize(dbaadmin.dbo.dbaudf_FormatXML2String(@HeaderXML),7500)'+@CRLF+@CRLF
					+'OPEN CommentBlockPartCursor'+@CRLF
					+'FETCH NEXT FROM CommentBlockPartCursor INTO @PartNumber,@ComBlkPart'+@CRLF
					+'WHILE (@@fetch_status <> -1)'+@CRLF
					+'BEGIN'+@CRLF
					+'	IF (@@fetch_status <> -2)'+@CRLF
					+'	BEGIN'+@CRLF
					+'		SET @PropertyName = ''CommentBlock_''+CAST(@PartNumber AS VarChar(10))'+@CRLF+@CRLF
					+'		EXEC sys.sp_addextendedproperty'+@CRLF
					+'			@name = @PropertyName,'+@CRLF
					+'			@level0type = N''SCHEMA'',@level0name = @Schema_name,'+@CRLF
					+'			@level1type = @ObjectType,@level1name = @object_name,'+@CRLF
					+'			@value = @ComBlkPart'+@CRLF+@CRLF
					+'	END'+@CRLF
					+'	FETCH NEXT FROM CommentBlockPartCursor INTO @PartNumber,@ComBlkPart'+@CRLF
					+'END'+@CRLF
					+'CLOSE CommentBlockPartCursor'+@CRLF
					+'DEALLOCATE CommentBlockPartCursor'+@CRLF+@CRLF+'GO'+@CRLF+@CRLF

			-- WRITING TO OUTPUT FILE APPENDING TO WHAT ALREADY EXISTED THERE
			-- WRITING CREATE OBJECT SECTION 2
			EXEC dbaadmin.dbo.dbasp_FileAccess_Write @Script,@FileName_OUT,1,1

		END
		FETCH NEXT FROM CLR_DATA_CURSOR INTO @MemberName,@Object_Name,@Object_Id,@Object_Schema,@Object_Type,@Script,@CB_DatabaseName,@CB_SchemaName,@CB_ObjectType,@CB_ObjectName,@CB_Version,@CB_CreatedBy,@CB_CreatedOn,@CB_BldNum,@CB_BldApp,@CB_BldBrnch,@CB_Purpose,@CB_Description,@CommentHeader,@Parameters,@Summary,@Member
	END
	CLOSE CLR_DATA_CURSOR
	DEALLOCATE CLR_DATA_CURSOR

END

GO




--sp_helpText 'dbasp_DiskSpace'



----GET ALL CLR stored procedures
--SELECT
--sp.name AS [Name],
--sp.object_id AS [object_ID],
--case when amsp.object_id is null then N'''' else asmblsp.name end AS [AssemblyName],
--case when amsp.object_id is null then N'''' else amsp.assembly_class end AS [ClassName],
--case when amsp.object_id is null then N'''' else amsp.assembly_method end AS [MethodName]
--FROM
--sys.all_objects AS sp
--LEFT OUTER JOIN sys.assembly_modules AS amsp ON amsp.object_id = sp.object_id
--LEFT OUTER JOIN sys.assemblies AS asmblsp ON asmblsp.assembly_id = amsp.assembly_id
--LEFT OUTER JOIN sys.procedures AS spp ON spp.object_id = sp.object_id
--WHERE spp.type like 'PC'

----For each CLR SP get the parameters in use
--SELECT
--param.name AS [Name]
--FROM
--sys.all_objects AS sp
--INNER JOIN sys.all_parameters AS param ON param.object_id=sp.object_id
--WHERE sp.name like 'dbasp_DiskSpace' order by param.parameter_id ASC

----For each parameter get the values, data type and so on...
--SELECT
--param.name AS [Name],
--param.parameter_id AS [param_ID],
--sp.object_id AS [object_ID],
--param.default_value AS [DefaultValue],
--usrt.name AS [DataType],
--sparam.name AS [DataTypeSchema],
--ISNULL(baset.name, N'''') AS [SystemType],
--CAST(CASE WHEN baset.name IN (N'nchar', N'nvarchar') AND param.max_length <> -1 THEN         param.max_length/2 ELSE param.max_length END AS int) AS [Length],
--CAST(param.precision AS int) AS [NumericPrecision],
--CAST(param.scale AS int) AS [NumericScale]
--FROM
--sys.all_objects AS sp
--INNER JOIN sys.all_parameters AS param ON param.object_id=sp.object_id
--LEFT OUTER JOIN sys.types AS usrt ON usrt.user_type_id = param.user_type_id
--LEFT OUTER JOIN sys.schemas AS sparam ON sparam.schema_id = usrt.schema_id
--LEFT OUTER JOIN sys.types AS baset ON (baset.user_type_id = param.system_type_id and     baset.user_type_id = baset.system_type_id) 
--WHERE sp.name='dbasp_DiskSpace' -- and param.name='@param1'







/*

		SELECT	[DatabaseName]	= a.b.value('VersionControl[1]/DatabaseName[1]','sysname')
			,[SchemaName]	= a.b.value('VersionControl[1]/SchemaName[1]','sysname')
			,[ObjectType]	= a.b.value('VersionControl[1]/ObjectType[1]','sysname')
			,[ObjectName]	= a.b.value('VersionControl[1]/ObjectName[1]','sysname')
			,[Version]	= a.b.value('VersionControl[1]/Version[1]','sysname')
			,[CreatedBy]	= a.b.value('VersionControl[1]/Created[1]/@By','sysname')
			,[CreatedOn]	= a.b.value('VersionControl[1]/Created[1]/@On','datetime')
			,[BldNum]	= a.b.value('VersionControl[1]/Build[1]/@Number','sysname')
			,[BldApp]	= a.b.value('VersionControl[1]/Build[1]/@Application','sysname')
			,[BldBrnch]	= a.b.value('VersionControl[1]/Build[1]/@Branch','sysname')
			,[Purpose]	= a.b.value('Purpose[1]','varchar(max)')
			,[Description]	= a.b.value('Description[1]','varchar(max)')
		FROM	@HeaderXML.nodes('CommentHeader') a(b)
				
		-- GATHER ALL MODIFICATION RECORDS FROM COMMENT BLOCK

		SELECT	a.b.value('@By','sysname')
			,a.b.value('@On','datetime')
			,a.b.value('@Reason','varchar(max)')
		FROM	@HeaderXML.nodes('//CommentHeader/VersionControl/Modifications/Mod') AS a(b)
		
		
		-- GATHER ALL DEPENDENCY RECORDS FROM COMMENT BLOCK

		SELECT	a.b.value('@Type','sysname')
			,a.b.value('@Schema','sysname')
			,a.b.value('@Name','sysname')
			,a.b.value('@VersionCompare','sysname')
			,a.b.value('@Version','sysname')
		FROM	@HeaderXML.nodes('//CommentHeader/Dependencies/Object') AS a(b)
		
		-- GATHER ALL PERMISSIONS RECORDS FROM COMMENT BLOCK

		SELECT	a.b.value('@Type','sysname')
			,a.b.value('@Priv','sysname')
			,a.b.value('@To','sysname')
			,a.b.value('@With','sysname')
		FROM	@HeaderXML.nodes('//CommentHeader/Permissions/Perm') AS a(b)
		
		-- GATHER ALL PARAMETER RECORDS FROM COMMENT BLOCK

		SELECT	[No]		= a.b.value('@No','int')
			,[Type]		= a.b.value('@Type','sysname')
			,[Name]		= a.b.value('@Name','sysname')
			,[Description]	= a.b.value('@Description','varchar(max)')
		FROM	@HeaderXML.nodes('//CommentHeader/Parameters/Parameter') AS a(b)

		-- GATHER ALL EXAMPLE RECORDS FROM COMMENT BLOCK

		SELECT	[Name]		= a.b.value('@Name','sysname')
			,[Text]		= a.b.value('@Text','varchar(max)')
		FROM	@HeaderXML.nodes('//CommentHeader/Examples/Example') AS a(b)

*/