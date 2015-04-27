USE [master]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('sp_Help_Doc') IS NOT NULL
	DROP PROCEDURE dbo.sp_Help_Doc
GO

CREATE PROCEDURE	[dbo].[sp_Help_Doc]
		(
		@object_name		SYSNAME		=NULL	-- NULL OR 'HELP' DISPLAYS HELP INFO
		,@Action		SYSNAME		=NULL	-- ADD_DPND MOD_DPND DEL_DPND
								-- ADD_PARM MOD_PARM DEL_PARM
								-- ADD_PERM MOD_PERM DEL_PERM
								-- ADD_CHNG MOD_CHNG DEL_CHNG
								-- ADD_EXAM MOD_EXAM DEL_EXAM
								-- NO_DDL		: Show Report Without DDL
								-- ONLY_DDL		: Only Show DDL of Report
								-- FORCE_UPD_DDL	: Force DDL to Be Updated from Extended Property if it Exists
								-- FORCE_UPD_EXPROP	: Force Extended Property to Be Updated from DDL if it Exists
								-- FORCE_UPD_PASSED	: Force Extended Property and DDL to Be Updated from @ActionProperty1
								-- BUILD_IF_MISSING	: Build Commend Block From Existing Database Object If One Does Not Exist.
								-- FORCE_BUILD_NEW	: Force Build Commend Block From Existing Database Object and Replace existing.
		,@ActionParam1		VARCHAR(max)	=NULL
		,@ActionParam2		VARCHAR(max)	=NULL
		,@ActionParam3		VARCHAR(max)	=NULL
		,@ActionParam4		VARCHAR(max)	=NULL
		,@ActionParam5		VARCHAR(max)	=NULL
		)

/****************************************************************************
<CommentHeader>
  <VersionControl>
    <DatabaseName>master</DatabaseName>
    <SchemaName>dbo</SchemaName>
    <ObjectType>SQL_STORED_PROCEDURE</ObjectType>
    <ObjectName>sp_Help_Doc</ObjectName>
    <Version>_</Version>
    <Build Number="_" Application="_" Branch="_" />
    <Created By="_" On="2013-10-09 20:50:47" />
    <Modifications>
      <Mod By="" On="" Reason="" />
    </Modifications>
  </VersionControl>
  <Purpose>_</Purpose>
  <Description>_</Description>
  <Dependencies>
    <Object Type="" Schema="" Name="" VersionCompare="" Version="" />
  </Dependencies>
  <Parameters>
    <Parameter No="1" Type="sysname" Name="@object_name" Description="" />
    <Parameter No="2" Type="sysname" Name="@Action" Description="" />
    <Parameter No="3" Type="varchar" Name="@ActionParam1" Description="" />
    <Parameter No="4" Type="varchar" Name="@ActionParam2" Description="" />
    <Parameter No="5" Type="varchar" Name="@ActionParam3" Description="" />
    <Parameter No="6" Type="varchar" Name="@ActionParam4" Description="" />
    <Parameter No="7" Type="varchar" Name="@ActionParam5" Description="" />
    <Parameter No="" Type="" Name="" Description="" />
  </Parameters>
  <Permissions>
    <Perm Type="" Priv="" To="" With="" />
  </Permissions>
  <Examples>
    <Example Name="" Text="" />
  </Examples>
</CommentHeader>
*****************************************************************************/
AS

SET NOCOUNT ON

BEGIN	------	DECLARE VARIABLE AND SET INITAL VALUES			--

	DECLARE	 @DDL			VarChar(max)
		,@ObjectID		INT
		,@ObjectType		SYSNAME
		,@HeaderXML		XML
		,@HeaderXML_DDL		XML
		,@HeaderXML_EXPROP	XML
		,@HeaderXML_NEW		XML
		,@Print			nVarChar(max)
		,@Node			XML
		,@ComBlkPart		VarChar(8000)
		,@PartNumber		INT
		,@PropertyName		SYSNAME
		,@Schema_name		SYSNAME
		,@WorkString		VarChar(max)
		,@DDL_HasCB		BIT
		,@EXP_HasCB		BIT
		,@DDL_HasChange		BIT
		,@EXP_HasChange		BIT
		,@CBHasChanged		BIT
		,@Pointer		INT
		,@Hold			VarChar(max)
		,@MaxCol1		INT
		,@MaxCol2		INT
		,@MaxCol3		INT
		,@MaxCol4		INT
		,@MaxCol5		INT
		,@MaxCol6		INT
		,@Debug			BIT
		,@IsCLR			BIT

	DECLARE		@HeaderMain		TABLE
				(
				[DatabaseName]	sysname		NULL
				,[SchemaName]	sysname		NULL
				,[ObjectType]	sysname		NULL
				,[ObjectName]	sysname		NULL
				,[Version]	sysname		NULL
				,[CreatedBy]	sysname		NULL
				,[CreatedOn]	datetime	NULL
				,[BldNum]	sysname		NULL
				,[BldApp]	sysname		NULL
				,[BldBrnch]	sysname		NULL
				,[Purpose]	varChar(max)	NULL
				,[Description]	varChar(max)	NULL
				)

	DECLARE		@Dependencies		TABLE
				(
				[Type]		sysname		NULL
				,[Schema]	sysname		NULL
				,[Name]		sysname		NULL
				,[VC]		sysname		NULL
				,[Ver]		sysname		NULL
				)

	DECLARE		@Parameters		TABLE
				(
				[No]		INT		NULL
				,[Type]		sysname		NULL
				,[Name]		sysname		NULL
				,[Description]	varchar(max)	NULL
				)

	DECLARE		@Permissions		TABLE
				(
				[Type]		sysname		NULL
				,[Priv]		sysname		NULL
				,[To]		sysname		NULL
				,[With]		sysname		NULL
				)

	DECLARE		@Mods			TABLE
				(
				[By]		sysname		NULL
				,[On]		datetime	NULL
				,[Reason]	varchar(max)	NULL
				)

	DECLARE		@Examples		TABLE
				(
				[Name]		sysname		NULL
				,[Text]		varchar(max)	NULL
				)

	SELECT	@DDL_HasCB	= 0
		,@EXP_HasCB	= 0
		,@CBHasChanged	= 0
		,@DDL_HasChange	= 0
		,@EXP_HasChange	= 0
		,@Debug		= 0


END

IF	------	PRINT HELP						--
 ISNULL(@object_name,'HELP') = 'HELP'
BEGIN

		PRINT 'EXAMPLES OF HOW TO USE THIS PROCEDURE'
		PRINT ''
		PRINT ''
		PRINT '	SHOW HELP (YOUR LOOKING AT IT NOW)'
		PRINT ''
		PRINT '		exec sp_Help_Doc NULL,''HELP'''
		PRINT ''
		PRINT ''
		PRINT '	SHOW OBJECT DOCUMENTATION'
		PRINT ''
		PRINT '		exec sp_Help_Doc ''{OBJECT_NAME}''                               -- REPORT AND DDL'
		PRINT '		exec sp_Help_Doc ''{OBJECT_NAME}'',''NO_DDL''                    -- ONLY REPORT'
		PRINT '		exec sp_Help_Doc ''{OBJECT_NAME}'',''ONLY_DDL''                  -- ONLY DDL'
		PRINT ''
		PRINT '	CREATE NEW COMMENT BLOCK'
		PRINT ''
		PRINT '		exec sp_Help_Doc ''{OBJECT_NAME}'',''FORCE_BUILD_NEW''           -- BUILD A NEW COMMENT BLOCK FROM OBJECT SCHEMA'
		PRINT '		exec sp_Help_Doc ''{OBJECT_NAME}'',''BUILD_IF_MISSING''          -- BUILD A NEW COMMENT BLOCK FROM OBJECT SCHEMA IF ONE DOES NOT EXIST'
		PRINT '		exec sp_Help_Doc ''{OBJECT_NAME}'',''FORCE_UPD_EXPROP''          -- FORCE CB IN DDL TO OVERWRITE EXTENDED PROPERTY'
		PRINT '		exec sp_Help_Doc ''{OBJECT_NAME}'',''FORCE_UPD_DDL''             -- FORCE CB IN EXTENDED PROPERTY TO OVERWRITE DDL'
		PRINT ''
		PRINT '		DECLARE @CB VarChar(max)'
		PRINT '		SET	@CB = ''{XML TEXT OF COMMENT BLOCK}'''
		PRINT '		exec sp_Help_Doc ''{OBJECT_NAME}'',''FORCE_UPD_PASSED'',@CB      -- FORCE CB TO BE REPLACED WITH VALUE PASSED IN'
		PRINT ''
		PRINT ''
		PRINT '	ADD A DEPENDENCY'
		PRINT '	MODIFY A DEPENDENCY'
		PRINT '	DELETE A DEPENDENCY'
		PRINT ''
		PRINT '	ADD A PARAMETER'
		PRINT '	MODIFY A PARAMETER'

		PRINT '	DELETE A PARAMETER'
		PRINT ''
		PRINT '	ADD A PERMISSION'
		PRINT '	MODIFY A PERMISSION'
		PRINT '	DELETE A PERMISSION'
		PRINT ''
		PRINT '	ADD A CHANGE RECORD'
		PRINT '	MODIFY A CHANGE RECORD'
		PRINT '	DELETE A CHANGE RECORD'
		PRINT ''
		PRINT '	ADD AN EXAMPLE'
		PRINT '	MODIFY AN EXAMPLE'
		PRINT '	DELETE AN EXAMPLE'
		PRINT ''
		PRINT ''
		PRINT ''
		PRINT ''
		PRINT ''
		PRINT ''
		PRINT ''
		PRINT ''

		GOTO ExitProcess
END

BEGIN	------	CLEAN UP PARAMETERS					--

	IF isnull(@Action,'') != 'FORCE_UPD_PASSED'
	SELECT	@ActionParam1 =  dbaadmin.dbo.dbaudf_HtmlEncode(REPLACE(REPLACE(@ActionParam1,char(9),'<tab>'),CHAR(13)+char(10),'<br>'))
		,@ActionParam2 = dbaadmin.dbo.dbaudf_HtmlEncode(REPLACE(REPLACE(@ActionParam2,char(9),'<tab>'),CHAR(13)+char(10),'<br>'))
		,@ActionParam3 = dbaadmin.dbo.dbaudf_HtmlEncode(REPLACE(REPLACE(@ActionParam3,char(9),'<tab>'),CHAR(13)+char(10),'<br>'))
		,@ActionParam4 = dbaadmin.dbo.dbaudf_HtmlEncode(REPLACE(REPLACE(@ActionParam4,char(9),'<tab>'),CHAR(13)+char(10),'<br>'))
		,@ActionParam5 = dbaadmin.dbo.dbaudf_HtmlEncode(REPLACE(REPLACE(@ActionParam5,char(9),'<tab>'),CHAR(13)+char(10),'<br>'))

	IF OBJECT_ID(@object_name) IS NULL
	BEGIN
		Print @Object_name + ' is not a valid object.'
		GOTO ExitProcess
	END

	SELECT	@ObjectID	= OBJECT_ID(@object_name)
		,@Schema_name	= isnull(Parsename(@object_name,2),'dbo')
		,@object_name	= Parsename(@object_name,1)
		,@ObjectType	= CASE ObjectpropertyEX(@ObjectID,'BaseType')
					WHEN 'AF' THEN 'FUNCTION'	-- Aggregate function (CLR)
					WHEN 'FS' THEN 'FUNCTION'	-- Assembly (CLR) scalar-function
					WHEN 'FT' THEN 'FUNCTION'	-- Assembly (CLR) table-valued function
					WHEN 'PC' THEN 'PROCEDURE'	-- Assembly (CLR) stored-procedure
					WHEN 'FN' THEN 'FUNCTION'	-- SQL scalar function
					WHEN 'IF' THEN 'FUNCTION'	-- SQL inline table-valued function
					WHEN 'TF' THEN 'FUNCTION'	-- SQL table-valued-function
					WHEN 'P'  THEN 'PROCEDURE'	-- SQL Stored Procedure
					WHEN 'X'  THEN 'PROCEDURE'	-- Extended stored procedure
					WHEN 'S'  THEN 'TABLE'		-- System base table
					WHEN 'IT' THEN 'TABLE'		-- Internal table
					WHEN 'TT' THEN 'TABLE'		-- Table type
					WHEN 'U'  THEN 'TABLE'		-- Table (user-defined)
					WHEN 'V'  THEN 'VIEW'		-- View
				  ELSE 'UNKNOWN' END
		,@IsCLR		= CASE	WHEN ObjectpropertyEX(@ObjectID,'BaseType') IN ('AF','FS','FT','PC')
					THEN 1 ELSE 0 END

END

IF	------	EXIT ON UNKNOWN						--
@ObjectType = 'UNKNOWN'
BEGIN
	PRINT @object_name + ' is Invalid Object Type, This process only works on Functions, Procedures, Tables and Views.'
	GOTO ExitProcess
END

IF	------	GET OBJECT DDL						--
@ObjectType NOT IN ('TABLE','UNKNOWN') AND @IsCLR = 0
BEGIN
	SELECT @DDL =  [dbaadmin].[dbo].[dbaudf_ScriptObject](QUOTENAME(DB_NAME())+'.'+QUOTENAME(OBJECT_SCHEMA_NAME(@ObjectID))+'.'+QUOTENAME(OBJECT_NAME(@ObjectID)),0,0,1,0,'',0,0,'','')

	WHILE CHARINDEX(' '+CHAR(13)+CHAR(10),@DDL) > 0 OR CHARINDEX(CHAR(9)+CHAR(13)+CHAR(10),@DDL) > 0
		SET @DDL = REPLACE(REPLACE(@DDL,' '+CHAR(13)+CHAR(10),CHAR(13)+CHAR(10)),CHAR(9)+CHAR(13)+CHAR(10),CHAR(13)+CHAR(10))

	-- CLEAN OFF THE GENERIC CREATE EMPTY CODE
	SET	@DDL =	STUFF(@DDL,1,CHARINDEX(' ALTER '+ @ObjectType,REPLACE(REPLACE(REPLACE(@DDL,CHAR(9),' '),CHAR(10),' '),CHAR(13),' ')),'')

	-- GET RID OF EVERYTHING PAST THE FIRST GO
	SET	@DDL =	LEFT(@DDL,CHARINDEX(CHAR(13)+CHAR(10)+'GO',@DDL))

END
ELSE
 SET @DDL = ''

IF	------	BUILD TABLE DDL						--
@ObjectType = 'TABLE'
BEGIN
	Declare @PrimaryKey varchar(50)
	DECLARE @Generate TABLE
		(
		ColumnName	char(35)
		,DataType	char(30)
		,Nullability	varchar(400)
		)

	declare @tblPrimaryKey table
	(PrimaryKeyID int identity(1,1)
	,ColumnName varchar(500) null
	,IndexDefinition varchar(500) null)

	insert into	@Generate
	select		case when syscolumns.colid = 1 then ' ' else ',' end + left('[' + syscolumns.Name + ']', 40)
			,left(systypes.Name + case
						when systypes.xusertype in (175, 11, 167, 165) --varchar, char
						then '(' + cast(syscolumns.length as varchar(10)) + ')'
						when systypes.xusertype in (239, 231) --nvarchar and nchar
						then '(' + cast(syscolumns.length/2 as varchar(10)) + ')'
						when systypes.xusertype in (106) --decimal
						then '(' + cast(syscolumns.xprec as varchar(10)) + ', ' + cast(sys.syscolumns.xscale as varchar(10)) + ')'
						else ''
						end, 20)
			, case	when syscolumns.isnullable = 0 then 'NOT NULL' ELSE 'NULL' end + ' '
			+ case	when sys.default_constraints.name is not null then 'CONSTRAINT ' + ' ' + '[' + sys.default_constraints.name + ']' + ' ' + 'DEFAULT ' + sys.default_constraints.definition else '' end
			+ case	when sys.identity_columns.name is not null then 'IDENTITY' + ' ' + '(' + cast(sys.identity_columns.seed_value as varchar(20)) + ', ' + cast(sys.identity_columns.increment_value as varchar(20)) + ')' else '' end
	FROM		sys.syscolumns
	JOIN		sys.systypes
		ON	sys.syscolumns.xtype = sys.systypes.xtype
	LEFT JOIN	sys.default_constraints
		ON	sys.default_constraints.parent_object_id = object_id(@object_name)
		AND	sys.syscolumns.colid = sys.default_constraints.parent_column_id
	LEFT JOIN	sys.identity_columns
		ON	sys.identity_columns.object_id = object_id(@object_name)
		AND	sys.syscolumns.colid = sys.identity_columns.column_id
	WHERE		id = object_id(@object_name)
		AND	sys.systypes.name <> 'sysname'
	ORDER BY	sys.syscolumns.colid

	SELECT		@PrimaryKey = sys.indexes.name
	FROM		sys.indexes
	JOIN		sys.index_columns
		ON	sys.indexes.object_id = sys.index_columns.object_id
		AND	sys.indexes.index_id = sys.index_columns.index_id
	JOIN		sys.syscolumns
		ON	sys.indexes.object_id = sys.syscolumns.id
		AND	sys.index_columns.column_id = sys.syscolumns.colid
	WHERE		sys.syscolumns.id = object_id(@object_name)
		AND	sys.indexes.is_primary_key = 1



	INSERT INTO	@tblPrimaryKey(ColumnName, IndexDefinition)
	SELECT		sys.syscolumns.name
			,sys.indexes.type_desc
	FROM		sys.indexes
	JOIN		sys.index_columns
		ON	sys.indexes.object_id = sys.index_columns.object_id
		AND	sys.indexes.index_id = sys.index_columns.index_id
	JOIN		sys.syscolumns
		ON	sys.indexes.object_id = sys.syscolumns.id
		AND	sys.index_columns.column_id = sys.syscolumns.colid
	WHERE		sys.syscolumns.id = object_id(@object_name)
		AND	sys.indexes.is_primary_key = 1


	SET @DDL = 'if not exists(select * from sysobjects where id = object_id(''' + @object_name + ''')'
	SET @DDL = @DDL + CHAR(13)+CHAR(10)+ ' and objectproperty(ID, N''IsUserTable'') = 1)'
	SET @DDL = @DDL + CHAR(13)+CHAR(10)+ 'begin'
	SET @DDL = @DDL + CHAR(13)+CHAR(10)+ 'Create Table dbo.' + @object_name + ''
	SET @DDL = @DDL + CHAR(13)+CHAR(10)+ '('

	select		@DDL = @DDL + CHAR(13)+CHAR(10)+ '' + ColumnName + DataType + Nullability
	from		@Generate

	SET @DDL = @DDL + CHAR(13)+CHAR(10)+ ')'

	if @PrimaryKey IS NOT NULL --table has no primary key defined
	BEGIN

		SET @DDL = @DDL + CHAR(13)+CHAR(10)+ CHAR(13)+CHAR(10)+ 'Alter table dbo.' + @object_name + ''
		SET @DDL = @DDL + CHAR(13)+CHAR(10)+ 'Add Constraint ' + @PrimaryKey + ''

		SELECT @DDL = @DDL + CHAR(13)+CHAR(10)+ 'Primary Key ' + IndexDefinition + ' (' +
		max(case when PrimaryKeyID = 1 then ColumnName else ' ' end) +
		max(case when PrimaryKeyID = 2 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 3 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 4 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 5 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 6 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 7 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 8 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 9 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 10 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 11 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 12 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 13 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 14 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 15 then ', ' + ColumnName else '' end) +
		max(case when PrimaryKeyID = 16 then ', ' + ColumnName else '' end) +
		')'
		from @tblPrimaryKey
		group by IndexDefinition

	END

	SET @DDL = @DDL + CHAR(13)+CHAR(10)+ 'End'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)



END

IF	------	CHECK FOR COMMENTBLOCK IN DDL				--
CHARINDEX('<CommentHeader>',@DDL) > 0 AND isnull(@Action,'') NOT IN ('FORCE_UPD_DDL','FORCE_UPD_PASSED','FORCE_BUILD_NEW')
BEGIN

	IF dbaadmin.dbo.dbaudf_isXML(SUBSTRING	(
						@DDL
						,CHARINDEX('<CommentHeader>',@DDL)
						,CHARINDEX('</CommentHeader>',@DDL)+16-CHARINDEX('<CommentHeader>',@DDL)
						)) = 1
	BEGIN
		SELECT @HeaderXML_DDL = CAST(SUBSTRING	(
							@DDL
							,CHARINDEX('<CommentHeader>',@DDL)
							,CHARINDEX('</CommentHeader>',@DDL)+16-CHARINDEX('<CommentHeader>',@DDL)
							) AS XML)

		PRINT ' -- CommentBlock Retrieved From DDL'
		SET @DDL_HasCB	= 1
	END
	ELSE
		PRINT ' -- CommentBlock Retrieved From DDL WAS NOT VALID'

END

IF	------	CHECK FOR COMMENTBLOCK IN EXTENDED PROPERTY		--
isnull(@Action,'') NOT IN ('FORCE_UPD_EXPROP','FORCE_UPD_PASSED','FORCE_BUILD_NEW')
BEGIN

	-- BUILD @WORKSTRING FROM MULTIPLE EXTENDED PROPERTIES
	-- BECAUSE OF 8K EXTENDED PROPERTY LIMIT CommentBlock_1,CommentBlock_2,...
	SET		@WorkString = ''
	SELECT		@WorkString = @WorkString + ISNULL(CAST(Value AS VarChar(8000)),'')
	FROM		sys.extended_properties
	WHERE		major_id = @ObjectID
		AND	name like 'CommentBlock%'
	ORDER BY	Name

	IF nullif(@WorkString,'') IS NOT NULL
	BEGIN
		PRINT ' -- CommentBlock Retrieved From Extended Property'
		SET	@EXP_HasCB	= 1
		SELECT	@HeaderXML_EXPROP = CONVERT(XML,@WorkString,1)
	END
END

IF	------	CREATE COMMENT HEADER DATA FROM DATABASE		--
isnull(@Action,'') = 'FORCE_BUILD_NEW' OR (isnull(@Action,'') != 'FORCE_UPD_PASSED' AND @EXP_HasCB = 0 AND @DDL_HasCB = 0)
BEGIN

	PRINT ' -- Gathering CommentBlock Data From Database'

	INSERT INTO	@HeaderMain
	SELECT		DB_NAME()
			,schema_name(schema_id)
			,[type_desc]
			,[name]
			,'_'
			,'_'
			,[create_date]
			,'_'
			,'_'
			,'_'
			,'_'
			,'_'
	FROM		sys.objects
	WHERE		object_id = @ObjectID


	INSERT INTO	@Dependencies
	SELECT		DISTINCT
			CAST(ObjectpropertyEX([referenced_major_id],'BaseType') AS SYSNAME)
			,OBJECT_SCHEMA_NAME([referenced_major_id])
	                ,OBJECT_NAME(referenced_major_id)
	                ,''
	                ,''
	FROM		sys.sql_dependencies
	WHERE		object_id = @ObjectID


	INSERT INTO	@Parameters
	SELECT		parameter_id
			,TYPE_NAME(user_type_id)
			,name
			,''
	FROM		sys.parameters
	WHERE		object_id = @ObjectID
	ORDER BY	parameter_id


	INSERT INTO	@Permissions
	SELECT		state_desc
			,permission_name
			,USER_NAME(grantee_principal_id)
			,''
	FROM		sys.database_permissions
	WHERE		minor_id = 0
		AND	major_id = @ObjectID
END

IF	------	SET @HeaderXML_NEW FROM DATABASE DATA			--
@Action = 'FORCE_BUILD_NEW' OR (@Action = 'BUILD_IF_MISSING' AND @EXP_HasCB = 0 AND @DDL_HasCB = 0)
BEGIN
	SELECT	@HeaderXML_NEW = (
				SELECT		(	SELECT		[DatabaseName]
									,[SchemaName]
									,[ObjectType]
									,[ObjectName]
									,[Version]
									,(	SELECT	[BldNum] AS [Number]
											,[BldApp] AS [Application]
											,[BldBrnch] AS [Branch]
										FROM	@HeaderMain AS [Build]
										FOR XML AUTO, TYPE)
									,(	SELECT	[CreatedBy] AS [By]
											,CONVERT(VarChar(50),[CreatedOn],120) AS [On]
										FROM	@HeaderMain AS [Created]
										FOR XML AUTO, TYPE)
									,(	SELECT	*
										FROM	(
											SELECT	[By]
												,CONVERT(VarChar(50),[On],120)	[On]
												,[Reason]
											FROM	@Mods
											UNION	SELECT '','',''
											) AS [Mod]
										ORDER BY [On]
										FOR XML AUTO, TYPE,ROOT('Modifications'))


							FROM	@HeaderMain
							FOR XML PATH('VersionControl'),TYPE)
						,[Purpose]
						,[Description]

						,(	SELECT	*
							FROM	(
								SELECT	[Type]
									,[Schema]
									,[Name]
									,[VC] AS [VersionCompare]
									,[Ver] AS [Version]
								FROM	@Dependencies
								UNION SELECT '','','','',''
								)  AS [Object]
							FOR XML AUTO, TYPE,ROOT('Dependencies'))

						,(	SELECT	*
							FROM	(
								SELECT	TOP 100 PERCENT
									REPLACE(CAST([No] AS VarChar(10)),'9999','') [No]
									,[Type]
									,[Name]
									,[Description]
								FROM	(
									SELECT	[No]
										,[Type]
										,[Name]
										,[Description]
									FROM	@Parameters
									UNION ALL SELECT 9999,'','',''
									) [Parameter]
								ORDER BY [No]
								)  AS [Parameter]
							FOR XML AUTO, TYPE,ROOT('Parameters'))

						,(	SELECT	*
							FROM	(
								SELECT	*
								FROM	@Permissions
								UNION SELECT '','','',''
								)  AS [Perm]
							FOR XML AUTO, TYPE,ROOT('Permissions'))

						,(	SELECT	*
							FROM	(
								SELECT	*
								FROM	@Examples
								UNION SELECT '',''
								)  AS [Example]
							FOR XML AUTO, TYPE,ROOT('Examples'))

				FROM	@HeaderMain
				FOR XML PATH('CommentHeader')
				)
END

BEGIN	------	SET @HEADERXML 						--
	SET @HeaderXML = CASE	-- IF XML NEEDS TO BE REWRITTEN FROM SCRATCH
				WHEN @HeaderXML_NEW IS NOT NULL
					THEN @HeaderXML_NEW

				-- IF FORCE_UPD_PASSED AND XML NOT PASSED IN @ActionParam1
				WHEN @Action = 'FORCE_UPD_PASSED' AND (CHARINDEX('<CommentHeader>',@ActionParam1) = 0 OR CHARINDEX('</CommentHeader>',@ActionParam1) = 0)
					THEN 'ERROR: @ACTION = ''FORCE_UPD_PASSED'' BUT @ACTIONPARAM1 IS NOT A VALID XML BLOCK'

				-- IF XML NEEDS TO USE PASSED IN VALUE
				WHEN @Action = 'FORCE_UPD_PASSED' AND CHARINDEX('<CommentHeader>',@ActionParam1) > 0 AND CHARINDEX('</CommentHeader>',@ActionParam1) > 0
					THEN CONVERT(XML,@ActionParam1,1)

				WHEN @Action = 'FORCE_UPD_DDL' AND @EXP_HasCB = 0
					THEN 'ERROR: @ACTION = ''FORCE_UPD_DDL'' BUT EXTENDED PROPERTY DOES NOT HAVE A VALID XML BLOCK'

				WHEN @Action = 'FORCE_UPD_DDL' AND @EXP_HasCB = 1
					THEN @HeaderXML_EXPROP

				WHEN @Action = 'FORCE_UPD_EXPROP' AND @DDL_HasCB = 0
					THEN 'ERROR: @ACTION = ''FORCE_UPD_EXPROP'' BUT DDL DOES NOT HAVE A VALID XML BLOCK'
				WHEN @Action = 'FORCE_UPD_EXPROP' AND @DDL_HasCB = 1
					THEN @HeaderXML_DDL

				WHEN @EXP_HasCB = 1
					THEN @HeaderXML_EXPROP
				WHEN @DDL_HasCB = 1
					THEN @HeaderXML_EXPROP

				WHEN NULLIF(@Action,'HELP') IS NULL
					THEN NULL

				ELSE 'ERROR: NO VALID XML BLOCK WAS FOUND'

				END
	IF @Debug = 1	------	SELECT DEBUG DATA
	SELECT 	'Starting Values'	[WHEN]
		,@Schema_name		[@Schema_name]
		,@object_name		[@object_name]
		,@HeaderXML		[@HeaderXML]
		,@HeaderXML_NEW		[@HeaderXML_NEW]
		,@DDL_HasCB		[@DDL_HasCB]
		,@HeaderXML_DDL		[@HeaderXML_DDL]
		,@EXP_HasCB		[@EXP_HasCB]
		,@HeaderXML_EXPROP	[@HeaderXML_EXPROP]
		,@Action		[@Action]
		,@ActionParam1		[@ActionParam1]
		,@ActionParam2		[@ActionParam2]
		,@ActionParam3		[@ActionParam3]
		,@ActionParam4		[@ActionParam4]
		,@ActionParam5		[@ActionParam5]
		,@DDL			[@DDL]
END

IF	------	EXIT IF XML ERROR					--
CAST(@HeaderXML AS VarChar(max)) LIKE 'ERROR%'
BEGIN
	PRINT CAST(@HeaderXML AS VarChar(max))
	GOTO ExitProcess
END

IF	------	DDL HAS CHANGE						--
@Action IN ('FORCE_UPD_DDL','FORCE_UPD_PASSED','FORCE_BUILD_NEW') OR (@Action = 'BUILD_IF_MISSING' AND @DDL_HasCB = 0)
	SET @DDL_HasChange = 1

IF	------	EXTENDED PROPERTY HAS CHANGE				--
@Action IN ('FORCE_UPD_EXPROP','FORCE_UPD_PASSED','FORCE_BUILD_NEW') OR (@Action = 'BUILD_IF_MISSING' AND @EXP_HasCB = 0)
	SET @EXP_HasChange = 1

IF	------	BUILD NEW						--
@Action IN ('FORCE_BUILD_NEW') OR (@Action = 'BUILD_IF_MISSING' AND @EXP_HasCB = 0 AND @DDL_HasCB = 0)
	SET @CBHasChanged = 1

IF	------	GET VALUES FROM CODED COMMENT BLOCK			--
NOT EXISTS(SELECT 1 FROM @HeaderMain) AND @HeaderXML IS NOT NULL
BEGIN

		INSERT INTO @HeaderMain
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
		INSERT INTO @Mods
		SELECT	a.b.value('@By','sysname')
			,a.b.value('@On','datetime')
			,a.b.value('@Reason','varchar(max)')
		FROM	@HeaderXML.nodes('//CommentHeader/VersionControl/Modifications/Mod') AS a(b)


		-- GATHER ALL DEPENDENCY RECORDS FROM COMMENT BLOCK
		INSERT INTO @Dependencies
		SELECT	a.b.value('@Type','sysname')
			,a.b.value('@Schema','sysname')
			,a.b.value('@Name','sysname')
			,a.b.value('@VersionCompare','sysname')
			,a.b.value('@Version','sysname')
		FROM	@HeaderXML.nodes('//CommentHeader/Dependencies/Object') AS a(b)

		-- GATHER ALL PERMISSIONS RECORDS FROM COMMENT BLOCK
		INSERT INTO @Permissions
		SELECT	a.b.value('@Type','sysname')
			,a.b.value('@Priv','sysname')
			,a.b.value('@To','sysname')
			,a.b.value('@With','sysname')
		FROM	@HeaderXML.nodes('//CommentHeader/Permissions/Perm') AS a(b)

		-- GATHER ALL PARAMETER RECORDS FROM COMMENT BLOCK
		INSERT INTO @Parameters
		SELECT	[No]		= a.b.value('@No','int')
			,[Type]		= a.b.value('@Type','sysname')
			,[Name]		= a.b.value('@Name','sysname')
			,[Description]	= a.b.value('@Description','varchar(max)')
		FROM	@HeaderXML.nodes('//CommentHeader/Parameters/Parameter') AS a(b)

		-- GATHER ALL EXAMPLE RECORDS FROM COMMENT BLOCK
		INSERT INTO @Examples
		SELECT	[Name]		= a.b.value('@Name','sysname')
			,[Text]		= a.b.value('@Text','varchar(max)')
		FROM	@HeaderXML.nodes('//CommentHeader/Examples/Example') AS a(b)

END

IF	------	PRINT DOCUMENTATION REPORT				--
 @Action IS NULL
BEGIN
	DECLARE @ReportWidth INT
	DECLARE @TitleText VarChar(200)
	SET	@ReportWidth = 120

	PRINT '/*'

	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	--	HEADER
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------

	SELECT	@Print = REPLICATE ('=', @ReportWidth)+CHAR(13)+CHAR(10)+
		dbaadmin.dbo.dbaudf_FormatString('DatabaseName       {0}',[DatabaseName],NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)+CHAR(13)+CHAR(10)+
		dbaadmin.dbo.dbaudf_FormatString('SchemaName         {0}',[SchemaName],NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)+CHAR(13)+CHAR(10)+
		dbaadmin.dbo.dbaudf_FormatString('ObjectType         {0}',[ObjectType],NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)+CHAR(13)+CHAR(10)+
		dbaadmin.dbo.dbaudf_FormatString('ObjectName         {0}',[ObjectName],NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)+CHAR(13)+CHAR(10)+
		dbaadmin.dbo.dbaudf_FormatString('Version            {0}',[Version],NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)+CHAR(13)+CHAR(10)+
		dbaadmin.dbo.dbaudf_FormatString('CreatedBy          {0}',[CreatedBy],NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)+CHAR(13)+CHAR(10)+
		dbaadmin.dbo.dbaudf_FormatString('CreatedOn          {0}',[CreatedOn],NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)+CHAR(13)+CHAR(10)+
		dbaadmin.dbo.dbaudf_FormatString('BldNum             {0}',[BldNum],NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)+CHAR(13)+CHAR(10)+
		dbaadmin.dbo.dbaudf_FormatString('BldApp             {0}',[BldApp],NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)+CHAR(13)+CHAR(10)+
		dbaadmin.dbo.dbaudf_FormatString('BldBrnch           {0}',[BldBrnch],NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)+CHAR(13)+CHAR(10)
	FROM	@HeaderMain

	SELECT	@TitleText = 'PURPOSE',@MaxCol2=LEN(@TitleText),@MaxCol1=(@ReportWidth-@MaxCol2)/2,@MaxCol3=@ReportWidth-(@MaxCol1+@MaxCol2),
		@Print = @Print + REPLICATE ('=', @ReportWidth)+CHAR(13)+CHAR(10)+
		REPLICATE(' ',@MaxCol1)+@TitleText+REPLICATE(' ',@MaxCol3)+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+

		dbaadmin.dbo.dbaudf_WordWrap(REPLACE(REPLACE(dbaadmin.dbo.dbaudf_HtmlDecode([Purpose]),'<tab>',CHAR(9)),'<br>',CHAR(13)+char(10)),@ReportWidth,' ',NULL)+CHAR(13)+CHAR(10)
	FROM	@HeaderMain

	SELECT	@TitleText = 'DESCRIPTION',@MaxCol2=LEN(@TitleText),@MaxCol1=(@ReportWidth-@MaxCol2)/2,@MaxCol3=@ReportWidth-(@MaxCol1+@MaxCol2),
		@Print = @Print + REPLICATE ('=', @ReportWidth)+CHAR(13)+CHAR(10)+
		REPLICATE(' ',@MaxCol1)+@TitleText+REPLICATE(' ',@MaxCol3)+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+

		dbaadmin.dbo.dbaudf_WordWrap(REPLACE(REPLACE(dbaadmin.dbo.dbaudf_HtmlDecode([Description]),'<tab>',CHAR(9)),'<br>',CHAR(13)+char(10)),@ReportWidth,' ',NULL)+CHAR(13)+CHAR(10)+
		REPLICATE ('=', @ReportWidth)+CHAR(13)+CHAR(10)
	FROM	@HeaderMain

	PRINT	@Print; SET @Print = '';



	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	--	CHANGE HISTORY
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------

	SELECT	@TitleText = 'CHANGE HISTORY',@MaxCol2=LEN(@TitleText),@MaxCol1=(@ReportWidth-@MaxCol2)/2,@MaxCol3=@ReportWidth-(@MaxCol1+@MaxCol2),
		@Print = @Print + REPLICATE(' ',@MaxCol1)+@TitleText+REPLICATE(' ',@MaxCol3)+CHAR(13)+CHAR(10)+
		REPLICATE ('=', @ReportWidth)+CHAR(13)+CHAR(10)

	-- ALL BUT LAST COLUMN
	SELECT	@MaxCol1 = MAX(LEN([BY]))+2
		,@MaxCol2 = MAX(LEN(CONVERT(VarChar(12),[On],101)))+2
		,@MaxCol3 = @ReportWidth - (@MaxCol1 + @MaxCol2)
	FROM	@Mods

	SELECT	@Print = @Print	+' BY'+ SPACE(@MaxCol1-3)
				+' On'+ SPACE(@MaxCol2-3)
				+' Reason'
				+CHAR(13)+CHAR(10)
				+REPLICATE('-',@MaxCol1-1) + ' '
				+REPLICATE('-',@MaxCol2-1) + ' '
				+REPLICATE('-',@MaxCol3)
				+CHAR(13)+CHAR(10)

	SELECT	@Print = @Print +[By] + SPACE(@MaxCol1-LEN([By]))
				+CONVERT(VarChar(12),[On],101) + SPACE(2)
				+dbaadmin.dbo.dbaudf_WordWrap(REPLACE(REPLACE(dbaadmin.dbo.dbaudf_HtmlDecode([Reason]),'<tab>',CHAR(9)),'<br>',CHAR(13)+char(10)),@MaxCol3,' ',CHAR(13)+CHAR(10)+SPACE(@ReportWidth-@MaxCol3)) +CHAR(13)+CHAR(10)
	FROM	@Mods
	WHERE	nullif([Reason],'') is NOT NULL

	SELECT	@Print = @Print +REPLICATE ('=', @ReportWidth)+CHAR(13)+CHAR(10)

	PRINT	@Print; SET @Print = '';


	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	--	DEPENDANCIES
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------

	SELECT	@TitleText = 'DEPENDANCIES',@MaxCol2=LEN(@TitleText),@MaxCol1=(@ReportWidth-@MaxCol2)/2,@MaxCol3=@ReportWidth-(@MaxCol1+@MaxCol2),
		@Print = @Print + REPLICATE(' ',@MaxCol1)+@TitleText+REPLICATE(' ',@MaxCol3)+CHAR(13)+CHAR(10)+
		REPLICATE ('=', @ReportWidth)+CHAR(13)+CHAR(10)


	-- ALL BUT LAST COLUMN
	SELECT	@MaxCol1 = MAX(LEN([Name]))+5
		,@MaxCol2 = MAX(LEN([Schema]))+10
		,@MaxCol3 = MAX(LEN([Type]))+8
		,@MaxCol4 = MAX(LEN(isnull([VC],' ')))+8
		,@MaxCol5 = @ReportWidth - (@MaxCol1 + @MaxCol2 + @MaxCol3 + @MaxCol4)
	FROM	@Dependencies



	SELECT	@Print = @Print	+' Name'+ SPACE(@MaxCol1-5)
				+' Schema'+ SPACE(@MaxCol2-7)
				+' Type'+ SPACE(@MaxCol3-5)
				+' VC'+ SPACE(@MaxCol4-3)
				+' Version'
				+CHAR(13)+CHAR(10)
				+REPLICATE('-',@MaxCol1-1) + ' '
				+REPLICATE('-',@MaxCol2-1) + ' '
				+REPLICATE('-',@MaxCol3-1) + ' '
				+REPLICATE('-',@MaxCol4-1) + ' '
				+REPLICATE('-',@MaxCol5)
				+CHAR(13)+CHAR(10)

	SELECT	@Print = @Print +ISNULL([Name],'') + SPACE(@MaxCol1-LEN(ISNULL([Name],'')))
				+ISNULL([Schema],'') + SPACE(@MaxCol2-LEN(ISNULL([Schema],'')))
				+ISNULL([Type],'') + SPACE(@MaxCol3-LEN(ISNULL([Type],'')))
				+ISNULL([VC],'') + SPACE(@MaxCol4-LEN(ISNULL([VC],'')))
				+ISNULL([Ver],'') +CHAR(13)+CHAR(10)
	FROM	@Dependencies
	WHERE	nullif([Name],'') is NOT NULL

	SELECT	@Print = @Print +REPLICATE ('=', @ReportWidth)+CHAR(13)+CHAR(10)

	PRINT	@Print; SET @Print = '';



	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	--	PERMISSIONS
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------

	SELECT	@TitleText = 'PERMISSIONS',@MaxCol2=LEN(@TitleText),@MaxCol1=(@ReportWidth-@MaxCol2)/2,@MaxCol3=@ReportWidth-(@MaxCol1+@MaxCol2),
		@Print = @Print + REPLICATE(' ',@MaxCol1)+@TitleText+REPLICATE(' ',@MaxCol3)+CHAR(13)+CHAR(10)+
		REPLICATE ('=', @ReportWidth)+CHAR(13)+CHAR(10)

	-- ALL BUT LAST COLUMN
	SELECT	@MaxCol1 = MAX(LEN([Type]))+2
		,@MaxCol2 = MAX(LEN([Priv]))+2
		,@MaxCol3 = MAX(LEN([To]))+2
		,@MaxCol4 = @ReportWidth - (@MaxCol1 + @MaxCol2 + @MaxCol3)
	FROM	@Permissions

	SELECT	@Print = @Print	+' Type'+ SPACE(@MaxCol1-5)
				+' Priv'+ SPACE(@MaxCol2-7)
				+' To'+ SPACE(@MaxCol3-5)
				+' With'
				+CHAR(13)+CHAR(10)
				+REPLICATE('-',@MaxCol1-1) + ' '
				+REPLICATE('-',@MaxCol2-1) + ' '
				+REPLICATE('-',@MaxCol3-1) + ' '
				+REPLICATE('-',@MaxCol4)
				+CHAR(13)+CHAR(10)

	SELECT	@Print = @Print +[Type] + SPACE(@MaxCol1-LEN([Type]))
				+[Priv] + SPACE(@MaxCol2-LEN([Priv]))
				+[To] + SPACE(@MaxCol3-LEN([To]))
				+[With] +CHAR(13)+CHAR(10)
	FROM	@Permissions
	WHERE	nullif([Type],'') is NOT NULL

	SELECT	@Print = @Print +REPLICATE ('=', @ReportWidth)+CHAR(13)+CHAR(10)

	PRINT	@Print; SET @Print = '';


	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	--	PARAMETERS
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------

	SELECT	@TitleText = 'PARAMETERS',@MaxCol2=LEN(@TitleText),@MaxCol1=(@ReportWidth-@MaxCol2)/2,@MaxCol3=@ReportWidth-(@MaxCol1+@MaxCol2),
		@Print = @Print + REPLICATE(' ',@MaxCol1)+@TitleText+REPLICATE(' ',@MaxCol3)+CHAR(13)+CHAR(10)+
		REPLICATE ('=', @ReportWidth)+CHAR(13)+CHAR(10)

	-- ALL BUT LAST COLUMN
	SELECT	@MaxCol1 = MAX(LEN(CAST([No] AS VarChar(4))))+2
		,@MaxCol2 = MAX(LEN([Type]))+2
		,@MaxCol3 = MAX(LEN([Name]))+2
		,@MaxCol4 = @ReportWidth - (@MaxCol1 + @MaxCol2 + @MaxCol3)
	FROM	@Parameters

	SELECT	@Print = @Print	+' No'+ SPACE(@MaxCol1-3)
				+' Type'+ SPACE(@MaxCol2-5)
				+' Name'+ SPACE(@MaxCol3-5)
				+' Description'
				+CHAR(13)+CHAR(10)
				+REPLICATE('-',@MaxCol1-1) + ' '
				+REPLICATE('-',@MaxCol2-1) + ' '
				+REPLICATE('-',@MaxCol3-1) + ' '
				+REPLICATE('-',@MaxCol4)
				+CHAR(13)+CHAR(10)

	SELECT	@Print = @Print +CAST([No] AS VarChar(4))+ SPACE(@MaxCol1-LEN(CAST([No] AS VarChar(4))))
				+[Type] + SPACE(@MaxCol2-LEN([Type]))
				+[Name] + SPACE(@MaxCol3-LEN([Name]))
				+dbaadmin.dbo.dbaudf_WordWrap(REPLACE(REPLACE(dbaadmin.dbo.dbaudf_HtmlDecode([Description]),'<tab>',CHAR(9)),'<br>',CHAR(13)+char(10)),@MaxCol4,' ',CHAR(13)+CHAR(10)+SPACE(@ReportWidth-@MaxCol4)) +CHAR(13)+CHAR(10)
	FROM	@Parameters
	WHERE	nullif([Name],'') is NOT NULL

	SELECT	@Print = @Print +REPLICATE ('=', @ReportWidth)+CHAR(13)+CHAR(10)

	PRINT	@Print; SET @Print = '';


	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	--	EXAMPLES
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------


	SELECT	@TitleText = 'EXAMPLES',@MaxCol2=LEN(@TitleText),@MaxCol1=(@ReportWidth-@MaxCol2)/2,@MaxCol3=@ReportWidth-(@MaxCol1+@MaxCol2),
		@Print = @Print + REPLICATE(' ',@MaxCol1)+@TitleText+REPLICATE(' ',@MaxCol3)+CHAR(13)+CHAR(10)+
		REPLICATE ('=', @ReportWidth)+CHAR(13)+CHAR(10)


	SELECT	@Print = @Print +
		'EXAMPLE: '+[name]+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+

		REPLACE(REPLACE(dbaadmin.dbo.dbaudf_HtmlDecode([Text]),'<tab>',CHAR(9)),'<br>',CHAR(13)+char(10))+CHAR(13)+CHAR(10)+
		REPLICATE ('=', @ReportWidth)+CHAR(13)+CHAR(10)
	FROM	@Examples
	WHERE	nullif([name],'') is NOT NULL

	PRINT	@Print
	PRINT	''
	PRINT	'*/'
	PRINT	''

	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	--	DDL
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------


	IF	------	DONT DISPLAY DDL SECTION IF OBJECT IS CLR	--
	@IsCLR = 0
	BEGIN
		PRINT	'--'+REPLICATE ('=', @ReportWidth)+CHAR(13)+CHAR(10)+
			'--                                        DDL CODE START'+CHAR(13)+CHAR(10)+
			'--'+REPLICATE ('=', @ReportWidth)+CHAR(13)+CHAR(10)

		SET @Hold = ''
		DECLARE DDLPartCursor CURSOR
		FOR
		SELECT	*
		From	dbaadmin.dbo.dbaudf_SplitSize(@DDL,7000)

		OPEN DDLPartCursor
		FETCH NEXT FROM DDLPartCursor INTO @PartNumber,@ComBlkPart
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN
				SET @ComBlkPart = REPLACE(@Hold,CHAR(13)+CHAR(10),'') + @ComBlkPart
				SET @Pointer = CHARINDEX(CHAR(13),REVERSE(@ComBlkPart))
				SET @Hold = RIGHT(@ComBlkPart,@Pointer)
				SET @ComBlkPart = LEFT(@ComBlkPart,LEN(@ComBlkPart)-@Pointer)
				PRINT @ComBlkPart
			END
			FETCH NEXT FROM DDLPartCursor INTO @PartNumber,@ComBlkPart
		END
		CLOSE DDLPartCursor
		DEALLOCATE DDLPartCursor



		PRINT 'GO'
		PRINT ''
		PRINT	'--'+REPLICATE ('=', @ReportWidth)+CHAR(13)+CHAR(10)+
			'--                                        DDL CODE END'+CHAR(13)+CHAR(10)+
			'--'+REPLICATE ('=', @ReportWidth)+CHAR(13)+CHAR(10)
		PRINT ''
	END

	GOTO ExitProcess
END

BEGIN 	------  UPDATE MODIFICATIONS					--

	IF @Action = 'ADD_CHNG'
	BEGIN

		IF NOT EXISTS(SELECT * FROM @Mods WHERE [By] = @ActionParam1 AND [ON] = @ActionParam2)
		BEGIN
			SET @CBHasChanged = 1
			INSERT INTO @Mods VALUES (@ActionParam1,@ActionParam2,@ActionParam3)
		END
		ELSE
			PRINT dbaadmin.dbo.dbaudf_FormatString('Modification Entry already Exists By="{0}" On="{1}".',@ActionParam1,@ActionParam2,@ActionParam3,@ActionParam4,NULL,NULL,NULL,NULL,NULL,NULL)

	END

	IF @Action = 'MOD_CHNG'
	BEGIN

		IF EXISTS(SELECT * FROM @Mods WHERE [By] = @ActionParam1 AND [ON] = @ActionParam2)
		BEGIN
			SET @CBHasChanged = 1
			UPDATE @Mods
			SET [Reason] = @ActionParam3
			WHERE [By] = @ActionParam1
			  AND [On] = @ActionParam2
		END
		ELSE
			PRINT dbaadmin.dbo.dbaudf_FormatString('Modification Entry Does Not Exist By="{0}" On="{1}".',@ActionParam1,@ActionParam2,@ActionParam3,@ActionParam4,NULL,NULL,NULL,NULL,NULL,NULL)

	END

	IF @Action = 'DEL_CHNG'
	BEGIN

		IF EXISTS(SELECT * FROM @Mods WHERE [By] = @ActionParam1 AND [ON] = @ActionParam2)
		BEGIN
			SET @CBHasChanged = 1
			DELETE @Mods
			WHERE [By] = @ActionParam1
			  AND [On] = @ActionParam2
		END
		ELSE
			PRINT dbaadmin.dbo.dbaudf_FormatString('Modification Entry Does Not Exist By="{0}" On="{1}".',@ActionParam1,@ActionParam2,@ActionParam3,@ActionParam4,NULL,NULL,NULL,NULL,NULL,NULL)

	END

END

BEGIN	------  UPDATE EXAMPLES						--

	IF @Action = 'ADD_EXAM'
	BEGIN

		IF NOT EXISTS(SELECT * FROM @Examples WHERE [Name] = @ActionParam1)
		BEGIN
			SET @CBHasChanged = 1
			INSERT INTO @Examples VALUES (@ActionParam1,@ActionParam2)
		END
		ELSE
			PRINT dbaadmin.dbo.dbaudf_FormatString('Example Entry already Exists Name="{0}".',@ActionParam1,@ActionParam2,@ActionParam3,@ActionParam4,NULL,NULL,NULL,NULL,NULL,NULL)

	END

	IF @Action = 'MOD_EXAM'
	BEGIN

		IF EXISTS(SELECT * FROM @Examples WHERE [Name] = @ActionParam1)
		BEGIN
			SET @CBHasChanged = 1
			UPDATE @Examples
			SET [Text] = @ActionParam2
			WHERE [Name] = @ActionParam1
		END
		ELSE
			PRINT dbaadmin.dbo.dbaudf_FormatString('Example Entry Does Not Exist Name="{0}".',@ActionParam1,@ActionParam2,@ActionParam3,@ActionParam4,NULL,NULL,NULL,NULL,NULL,NULL)

	END

	IF @Action = 'DEL_EXAM'
	BEGIN

		IF EXISTS(SELECT * FROM @Examples WHERE [Name] = @ActionParam1)
		BEGIN
			SET @CBHasChanged = 1
			DELETE @Examples
			WHERE [Name] = @ActionParam1
		END
		ELSE
			PRINT dbaadmin.dbo.dbaudf_FormatString('Modification Entry Does Not Exist Name="{0}".',@ActionParam1,@ActionParam2,@ActionParam3,@ActionParam4,NULL,NULL,NULL,NULL,NULL,NULL)

	END

END

BEGIN	------  UPDATE PARAMETERS					--

	IF @Action = 'ADD_PARM'
	BEGIN

		IF  NOT EXISTS(SELECT * FROM @Parameters WHERE [No] = @ActionParam1) AND NOT EXISTS(SELECT * FROM @Parameters WHERE [Name] = @ActionParam2)
		BEGIN
			SET @CBHasChanged = 1
			INSERT INTO @Parameters VALUES (@ActionParam1,@ActionParam2,@ActionParam3,@ActionParam4)
		END
		ELSE
			PRINT dbaadmin.dbo.dbaudf_FormatString('Parameter Entry already Exists No="{0}" or Name="{1}".',@ActionParam1,@ActionParam2,@ActionParam3,@ActionParam4,NULL,NULL,NULL,NULL,NULL,NULL)

	END

	IF @Action = 'MOD_PARM'
	BEGIN

		IF EXISTS(SELECT * FROM @Parameters WHERE [No] = @ActionParam1 AND [Name] = @ActionParam2)
		BEGIN
			SET @CBHasChanged = 1
			UPDATE @Parameters
			SET	[No]		= @ActionParam1
				,[Name]		= @ActionParam2
				,[Type]		= @ActionParam3
			    ,[Description]	= @ActionParam4
			WHERE [No] = @ActionParam1
			  AND [Name] = @ActionParam2
		END
		ELSE
			PRINT dbaadmin.dbo.dbaudf_FormatString('Parameter Entry Does Not Exists No="{0}" and Name="{1}".',@ActionParam1,@ActionParam2,@ActionParam3,@ActionParam4,NULL,NULL,NULL,NULL,NULL,NULL)

	END

	IF @Action = 'DEL_PARM'
	BEGIN

		IF EXISTS(SELECT * FROM @Parameters WHERE [No] = @ActionParam1 AND [Name] = @ActionParam2)
		BEGIN
			SET @CBHasChanged = 1
			DELETE @Parameters
			WHERE [No] = @ActionParam1
			  AND [Name] = @ActionParam2
		END
		ELSE
			PRINT dbaadmin.dbo.dbaudf_FormatString('Parameter Entry Does Not Exist No="{0}" and Name="{1}".',@ActionParam1,@ActionParam2,@ActionParam3,@ActionParam4,NULL,NULL,NULL,NULL,NULL,NULL)

	END

END

BEGIN	------  UPDATE PERMISSIONS					--

	IF @Action = 'ADD_PERM'
	BEGIN

		IF NOT EXISTS(SELECT * FROM @Permissions WHERE [Type] = @ActionParam1 AND [Priv] = @ActionParam2 AND [To] = @ActionParam3)
		BEGIN
			SET @CBHasChanged = 1
			INSERT INTO @Permissions VALUES (@ActionParam1,@ActionParam2,@ActionParam3,@ActionParam4)
		END
		ELSE
			PRINT dbaadmin.dbo.dbaudf_FormatString('Permission Entry already Exists Type="{0}" and Priv="{1}" and To="{2}".',@ActionParam1,@ActionParam2,@ActionParam3,@ActionParam4,NULL,NULL,NULL,NULL,NULL,NULL)

	END

	IF @Action = 'MOD_PERM'
	BEGIN

		IF EXISTS(SELECT * FROM @Permissions WHERE [Type] = @ActionParam1 AND [Priv] = @ActionParam2 AND [To] = @ActionParam3)
		BEGIN
			SET @CBHasChanged = 1
			UPDATE @Permissions
			SET [With]   = @ActionParam4
			WHERE [Type] = @ActionParam1
			  AND [Priv] = @ActionParam2
			  AND [To] = @ActionParam3
		END
		ELSE
			PRINT dbaadmin.dbo.dbaudf_FormatString('Parameter Entry Does Not Exist Type="{0}" and Priv="{1}" and To="{2}".',@ActionParam1,@ActionParam2,@ActionParam3,@ActionParam4,NULL,NULL,NULL,NULL,NULL,NULL)

	END

	IF @Action = 'DEL_PERM'
	BEGIN

		IF EXISTS(SELECT * FROM @Permissions WHERE [Type] = @ActionParam1 AND [Priv] = @ActionParam2 AND [To] = @ActionParam3)
		BEGIN
			SET @CBHasChanged = 1
			DELETE @Permissions
			WHERE [Type] = @ActionParam1
			  AND [Priv] = @ActionParam2
			  AND [To] = @ActionParam3
		END
		ELSE
			PRINT dbaadmin.dbo.dbaudf_FormatString('Parameter Entry Does Not Exist Type="{0}" and Priv="{1}" and To="{2}".',@ActionParam1,@ActionParam2,@ActionParam3,@ActionParam4,NULL,NULL,NULL,NULL,NULL,NULL)

	END

END

BEGIN	------  UPDATE DEPENDENCIES					--

	IF @Action = 'ADD_DPND'
	BEGIN

		IF NOT EXISTS(SELECT * FROM @Dependencies WHERE [Type] = @ActionParam1 AND [Schema] = @ActionParam2 AND [Name] = @ActionParam3 AND [VC] = @ActionParam4)
		BEGIN
			SET @CBHasChanged = 1
			INSERT INTO @Dependencies VALUES (@ActionParam1,@ActionParam2,@ActionParam3,@ActionParam4,@ActionParam5)
		END
		ELSE
			PRINT dbaadmin.dbo.dbaudf_FormatString('Dependency Entry already Exists Type="{0}" and Schema="{1}" and Name="{2}" and VersionCompare="{3}".',@ActionParam1,@ActionParam2,@ActionParam3,@ActionParam4,@ActionParam5,NULL,NULL,NULL,NULL,NULL)

	END

	IF @Action = 'MOD_DPND'
	BEGIN

		IF EXISTS(SELECT * FROM @Dependencies WHERE [Type] = @ActionParam1 AND [Schema] = @ActionParam2 AND [Name] = @ActionParam3 AND [VC] = @ActionParam4)
		BEGIN
			SET @CBHasChanged = 1
			UPDATE @Dependencies
			SET [Ver]   = @ActionParam5
			WHERE [Type] = @ActionParam1
			  AND [Schema] = @ActionParam2
			  AND [Name] = @ActionParam3
			  AND [VC] = @ActionParam4
		END
		ELSE
			PRINT dbaadmin.dbo.dbaudf_FormatString('Dependency Entry Does Not Exist Type="{0}" and Schema="{1}" and Name="{2}" and VersionCompare="{3}".',@ActionParam1,@ActionParam2,@ActionParam3,@ActionParam4,@ActionParam5,NULL,NULL,NULL,NULL,NULL)

	END

	IF @Action = 'DEL_DPND'
	BEGIN

		IF EXISTS(SELECT * FROM @Dependencies WHERE [Type] = @ActionParam1 AND [Schema] = @ActionParam2 AND [Name] = @ActionParam3 AND [VC] = @ActionParam4)
		BEGIN
			SET @CBHasChanged = 1
			DELETE @Dependencies
			WHERE [Type] = @ActionParam1
			  AND [Schema] = @ActionParam2
			  AND [Name] = @ActionParam3
			  AND [VC] = @ActionParam4
		END
		ELSE
			PRINT dbaadmin.dbo.dbaudf_FormatString('Dependency Entry Does Not Exist Type="{0}" and Schema="{1}" and Name="{2}" and VersionCompare="{3}".',@ActionParam1,@ActionParam2,@ActionParam3,@ActionParam4,@ActionParam5,NULL,NULL,NULL,NULL,NULL)

	END

END

BEGIN	------	UPDATE SECTION						--

	IF	------  COMMENT BLOCK HAS CHANGED  			--
	@CBHasChanged = 1
	BEGIN
		SELECT	@HeaderXML = (
					SELECT		(	SELECT		[DatabaseName]
										,[SchemaName]
										,[ObjectType]
										,[ObjectName]
										,[Version]
										,(	SELECT	[BldNum] AS [Number]
												,[BldApp] AS [Application]
												,[BldBrnch] AS [Branch]
											FROM	@HeaderMain AS [Build]
											FOR XML AUTO, TYPE)
										,(	SELECT	[CreatedBy] AS [By]
												,CONVERT(VarChar(50),[CreatedOn],120) AS [On]
											FROM	@HeaderMain AS [Created]
											FOR XML AUTO, TYPE)
										,(	SELECT	*
											FROM	(
												SELECT	[By]
													,CONVERT(VarChar(50),[On],120)	[On]
													,[Reason]
												FROM	@Mods
												UNION	SELECT '','',''
												) AS [Mod]
											ORDER BY [On]
											FOR XML AUTO, TYPE,ROOT('Modifications'))


								FROM	@HeaderMain
								FOR XML PATH('VersionControl'),TYPE)
							,[Purpose]
							,[Description]

							,(	SELECT	*
								FROM	(
									SELECT	[Type]
										,[Schema]
										,[Name]
										,[VC] AS [VersionCompare]
										,[Ver] AS [Version]
									FROM	@Dependencies
									UNION SELECT '','','','',''
									)  AS [Object]
								FOR XML AUTO, TYPE,ROOT('Dependencies'))

							,(	SELECT	*
								FROM	(
									SELECT	TOP 100 PERCENT
										REPLACE(CAST([No] AS VarChar(10)),'9999','') [No]
										,[Type]
										,[Name]
										,[Description]
									FROM	(
										SELECT	[No]
											,[Type]
											,[Name]
											,[Description]
										FROM	@Parameters
										UNION ALL SELECT 9999,'','',''
										) [Parameter]
									ORDER BY [No]
									)  AS [Parameter]
								FOR XML AUTO, TYPE,ROOT('Parameters'))

							,(	SELECT	*
								FROM	(
									SELECT	*
									FROM	@Permissions
									UNION SELECT '','','',''
									)  AS [Perm]
								FOR XML AUTO, TYPE,ROOT('Permissions'))

							,(	SELECT	*
								FROM	(
									SELECT	*
									FROM	@Examples
									UNION SELECT '',''
									)  AS [Example]
								FOR XML AUTO, TYPE,ROOT('Examples'))

					FROM	@HeaderMain
					FOR XML PATH('CommentHeader')
					)

		PRINT	'-- CREATED UPDATED COMMENT BLOCK'
	END

	IF	------	EXTENDED PROPERTY HAS CHANGED			--
	@EXP_HasChange = 1 OR @CBHasChanged = 1
	BEGIN

		IF	------	REMOVE EXISTING COMMENT BLOCK FROM EXTENDED PROPERTY	--
		EXISTS (SELECT * From fn_listExtendedProperty(DEFAULT,'SCHEMA',@Schema_name,@ObjectType,@object_name,null,null) WHERE name Like 'CommentBlock%')
		BEGIN
			PRINT ' -- REMOVING EXISTING "COMMENT BLOCK_%" EXTENDED PROPERTIES.'

			DECLARE CommentBlockPartCursor CURSOR
			FOR
			SELECT name
			From fn_listExtendedProperty(DEFAULT,'SCHEMA',@Schema_name,@ObjectType,@object_name,null,null)
			WHERE name Like 'CommentBlock%'

			OPEN CommentBlockPartCursor
			FETCH NEXT FROM CommentBlockPartCursor INTO @PropertyName
			WHILE (@@fetch_status <> -1)
			BEGIN
				IF (@@fetch_status <> -2)
				BEGIN

					EXEC sys.sp_dropextendedproperty
						@name = @PropertyName,
						@level0type = N'SCHEMA',@level0name = @Schema_name,
						@level1type = @ObjectType,@level1name = @object_name

				END
				FETCH NEXT FROM CommentBlockPartCursor INTO @PropertyName
			END
			CLOSE CommentBlockPartCursor
			DEALLOCATE CommentBlockPartCursor
		END

		BEGIN	------	WRITE COMMENT BLOCK TO EXTENDED PROPERTY		--

			PRINT ' -- SAVING UPDATED "COMMENT BLOCK_%" EXTENDED PROPERTIES.'
			DECLARE CommentBlockPartCursor CURSOR
			FOR
			SELECT	*
			From	dbaadmin.dbo.dbaudf_SplitSize(dbaadmin.dbo.dbaudf_FormatXML2String(@HeaderXML),7500)

			OPEN CommentBlockPartCursor
			FETCH NEXT FROM CommentBlockPartCursor INTO @PartNumber,@ComBlkPart
			WHILE (@@fetch_status <> -1)
			BEGIN
				IF (@@fetch_status <> -2)
				BEGIN
					SET @PropertyName = 'CommentBlock_'+CAST(@PartNumber AS VarChar(10))

					EXEC sys.sp_addextendedproperty
						@name = @PropertyName,
						@level0type = N'SCHEMA',@level0name = @Schema_name,
						@level1type = @ObjectType,@level1name = @object_name,
						@value = @ComBlkPart

				END
				FETCH NEXT FROM CommentBlockPartCursor INTO @PartNumber,@ComBlkPart
			END
			CLOSE CommentBlockPartCursor
			DEALLOCATE CommentBlockPartCursor
			PRINT '  -- DONE SAVING UPDATED "COMMENT BLOCK_%" EXTENDED PROPERTIES.'
		END

	END


	IF	------	DDL HAS CHANGED					--
	@IsCLR = 0 AND @ObjectType != 'TABLE' AND (@DDL_HasChange = 1 OR @CBHasChanged = 1)
	BEGIN

		---- CHANGE CODE TO AN ALTER
		--SET	@DDL = STUFF	(
		--			@DDL
		--			,CHARINDEX('CREATE',@DDL)
		--			,6
		--			,'ALTER'
		--			)

		IF
		CHARINDEX('<CommentHeader>',@DDL) > 0
		AND dbaadmin.dbo.dbaudf_isXML(SUBSTRING	(
							@DDL
							,CHARINDEX('<CommentHeader>',@DDL)
							,CHARINDEX('</CommentHeader>',@DDL)+16-CHARINDEX('<CommentHeader>',@DDL)
							)) = 1
		BEGIN	------	REPLACE EXISTING COMMENTBLOCK IN DDL			--

			PRINT ' -- REPLACING CURRENT COMMENT BLOCK IN DDL'

			--ADD  COMMENT BLOCK
			SET	@DDL = STUFF	(
						@DDL
						,CHARINDEX('<CommentHeader>',@DDL)
						,CHARINDEX('</CommentHeader>',@DDL)+16-CHARINDEX('<CommentHeader>',@DDL)
						,dbaadmin.dbo.dbaudf_FormatXML2String(@HeaderXML)
						)

		END
		ELSE
		BEGIN	------	ADD NEW COMMENT BLOCK IN DDL				--

			IF	CHARINDEX(	' AS '
						,REPLACE(REPLACE(REPLACE(@DDL,CHAR(9),' '),CHAR(10),' '),CHAR(13),' ')
						,CHARINDEX(	' ALTER '+ @ObjectType + ' '
								,REPLACE(REPLACE(REPLACE(@DDL,CHAR(9),' '),CHAR(10),' '),CHAR(13),' ')
								)
						) = 0
			BEGIN
				PRINT ' -- UNABLE TO FIND "AS" MARKER IN DDL'
				PRINT ' -- COMMENT BLOCK ADDED TO END OF THE SCRIPT'
				SET @DDL	= @DDL
						+ CHAR(13)+CHAR(10)+'/****************************************************************************'
						+CHAR(13)+CHAR(10)+dbaadmin.dbo.dbaudf_FormatXML2String(@HeaderXML)
						+CHAR(13)+CHAR(10)+'*****************************************************************************/'
						+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) 
			END
			ELSE
			BEGIN
				PRINT ' -- ADDING COMMENT BLOCK BEFORE "AS" MARKER IN DDL'

				SET @DDL = STUFF(
						@DDL
						,CHARINDEX(	' AS '
								,REPLACE(REPLACE(REPLACE(@DDL,CHAR(9),' '),CHAR(10),' '),CHAR(13),' ')
								,CHARINDEX(	' ALTER '+ @ObjectType + ' '
										,REPLACE(REPLACE(REPLACE(@DDL,CHAR(9),' '),CHAR(10),' '),CHAR(13),' ')
										)
								)+ 1
						,2
						,CHAR(13)+CHAR(10)+'/****************************************************************************'
						+CHAR(13)+CHAR(10)+dbaadmin.dbo.dbaudf_FormatXML2String(@HeaderXML)
						+CHAR(13)+CHAR(10)+'*****************************************************************************/'
						+CHAR(13)+CHAR(10)+'AS'+CHAR(13)+CHAR(10)
						)
			END
		END


		EXEC(@DDL) ------	EXECUTE DDL SCRIPT

		IF @Debug = 1 OR @@ERROR != 0	------	PRINT OR EXECUTE UPDATE SCRIPT
		BEGIN




			-- PRINT DDL UPDATE SCRIPT
			-- MAKE SURE THAT @DDL ENDS WITH A GO WHEN PRINTING
			SET @DDL = @DDL + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10)

			PRINT ''
			PRINT '========================================================================='
			PRINT '                            UPDATE DDL SCRIPT	'
			PRINT '========================================================================='
			PRINT ''
			PRINT ''

			DECLARE @TextLine VarChar(MAX)
			DECLARE PrintLargeResults CURSOR
			FOR
			-- SELECT QUERY FOR CURSOR
			SELECT		SplitValue
			FROM		dbaadmin.dbo.dbaudf_SplitByLines(@DDL)
			ORDER BY	OccurenceID 

			OPEN PrintLargeResults;
			FETCH PrintLargeResults INTO @TextLine;
			WHILE (@@fetch_status <> -1)
			BEGIN
				IF (@@fetch_status <> -2)
				BEGIN
					---------------------------- 
					---------------------------- CURSOR LOOP TOP
	
					PRINT @TextLine

					---------------------------- CURSOR LOOP BOTTOM
					----------------------------
				END
 				FETCH NEXT FROM PrintLargeResults INTO @TextLine;
			END
			CLOSE PrintLargeResults;
			DEALLOCATE PrintLargeResults;
		END
	END

END

ExitProcess:

	IF @Debug = 1
	SELECT 	'On Exit'		[WHEN]
		,@Schema_name		[@Schema_name]
		,@object_name		[@object_name]
		,@HeaderXML		[@HeaderXML]
		,@HeaderXML_NEW		[@HeaderXML_NEW]
		,@DDL_HasCB		[@DDL_HasCB]
		,@HeaderXML_DDL		[@HeaderXML_DDL]
		,@EXP_HasCB		[@EXP_HasCB]
		,@HeaderXML_EXPROP	[@HeaderXML_EXPROP]
		,@Action		[@Action]
		,@ActionParam1		[@ActionParam1]
		,@ActionParam2		[@ActionParam2]
		,@ActionParam3		[@ActionParam3]
		,@ActionParam4		[@ActionParam4]
		,@ActionParam5		[@ActionParam5]
		,@DDL			[@DDL]

GO


EXEC sys.sp_MS_marksystemobject sp_Help_Doc
GO
exec sp_Help_Doc 'dbo.sp_Help_Doc','BUILD_IF_MISSING'
GO
--exec sp_Help_Doc 'dbo.sp_Help_Doc'
--GO
--exec sp_Help_Doc 
--GO


USE dbaadmin
GO
exec sp_Help_Doc 'dbo.dbasp_LogEvent'

