DECLARE	@Path		VarChar(8000)
	,@FileName	VarChar(8000)
	,@bd_id		INT
	,@AllowRollBack	bit
	
SELECT	@Path		= 'D:\'
	,@FileName	= 'ALL_dbaadmin_35_sprocs.sql' --'dbavw_DatabaseFileSummary.sql'
	,@bd_id		= NULL
	,@AllowRollBack	= 0
	
SET	NOCOUNT		ON

DECLARE	@StartLine	INT
	,@EndLine	INT
	,@PathAndFile	VarChar(8000)
	,@CommentHeader	VarChar(8000)
	,@HeaderXML	XML
	,@DDL		VarChar(8000)
	,@COMMAND	nVarChar(4000)
	,@PARAM_DEF	NVARCHAR(500)
	,@ObjectID	INT
	,@CurrentVersion sysname
	,@DatabaseName	sysname
	,@SchemaName	sysname
	,@ObjectType	sysname
	,@ObjectName	sysname
	,@Version	sysname
	,@CreatedBy	sysname
	,@CreatedOn	datetime
	,@ModifiedBy	sysname
	,@ModifiedOn	datetime
	,@RC		INT



SELECT	TOP 1000 *
FROM	[dbaadmin].[dbo].[dbaudf_FileAccess_Read] (@Path, @Filename)
--WHERE	[Line] Like 'CREATE%'









	
SELECT	@StartLine	= CASE WHEN line = '<CommentHeader>' THEN [LineNo] ELSE @StartLine END	 
	,@EndLine	= CASE WHEN line = '</CommentHeader>' THEN [LineNo] ELSE @EndLine END
	,@PathAndFile	= @Path + @FileName
FROM	[dbaadmin].[dbo].[dbaudf_FileAccess_Read] (@Path, @Filename)

SELECT	@CommentHeader = COALESCE(@CommentHeader,'') + CHAR(13) + CHAR(10) + [line]
FROM	[dbaadmin].[dbo].[dbaudf_FileAccess_Read] (@Path, @Filename)
WHERE	[lineNo] Between @StartLine AND @EndLine	

SET	@HeaderXML = CAST(@CommentHeader AS XML)

SELECT	@DatabaseName	= a.b.value('VersionControl[1]/DatabaseName[1]','sysname')	--AS [DatabaseName]
	,@SchemaName	= a.b.value('VersionControl[1]/SchemaName[1]','sysname')	--AS [SchemaName]
	,@ObjectType	= a.b.value('VersionControl[1]/ObjectType[1]','sysname')	--AS [ObjectType]
	,@ObjectName	= a.b.value('VersionControl[1]/ObjectName[1]','sysname')	--AS [ObjectName]
	,@Version	= a.b.value('VersionControl[1]/Version[1]','sysname')		--AS [Version]
	,@CreatedBy	= a.b.value('VersionControl[1]/Created[1]/@By','sysname')	--AS [CreatedBy]
	,@CreatedOn	= a.b.value('VersionControl[1]/Created[1]/@On','datetime')	--AS [CreatedOn]
	,@ModifiedBy	= a.b.value('VersionControl[1]/Modified[1]/@By','sysname')	--AS [ModifiedBy]
	,@ModifiedOn	= a.b.value('VersionControl[1]/Modified[1]/@On','datetime')	--AS [ModifiedOn]
		
FROM	@HeaderXML.nodes('CommentHeader') a(b)

PRINT	'Deploy ' + @ObjectType
PRINT	' - ' + @DatabaseName + '.' + @SchemaName + '.' + @ObjectName + '  (' + @Version + ')'


-- CHECK IF OBJECT EXISTS
SELECT	@ObjectID = OBJECT_ID(@DatabaseName + '.' + @SchemaName + '.' + @ObjectName,  @ObjectType)
IF OBJECT_NAME(@ObjectID,DB_ID(@DatabaseName)) IS NULL
BEGIN
	PRINT '  - Object does not currently exist.'
	GOTO DeployScript
END
PRINT '  - Object does currently exist.'	
-- CHECK CURRENT VERSION

SET @PARAM_DEF = N'@SchemaName sysname, @ObjectType sysname, @ObjectName sysname, @CurrentVersion sysname OUTPUT'

SET @COMMAND = N'USE ['+@DatabaseName+'];SELECT	@CurrentVersion = CAST(value AS sysname) FROM fn_listextendedproperty(''Version'', ''schema'', @SchemaName, @ObjectType, @ObjectName, default, default)'

EXEC sp_executesql @COMMAND, @PARAM_DEF
	,@SchemaName		= @SchemaName
	,@ObjectType		= @ObjectType
	,@ObjectName		= @ObjectName
	,@CurrentVersion	= @CurrentVersion OUTPUT

If	@CurrentVersion IS NULL
BEGIN
	PRINT '  - Current Object has no Version'
	GOTO CurrentOlder
END

PRINT '  - Current Object Version (' + @CurrentVersion + ')'

IF	PARSENAME(@CurrentVersion, 3) < PARSENAME(@Version, 3)	GOTO CurrentOlder
ELSE IF PARSENAME(@CurrentVersion, 3) = PARSENAME(@Version, 3)
  AND	PARSENAME(@CurrentVersion, 2) < PARSENAME(@Version, 2)	GOTO CurrentOlder
ELSE IF	PARSENAME(@CurrentVersion, 3) = PARSENAME(@Version, 3)
  AND	PARSENAME(@CurrentVersion, 2) = PARSENAME(@Version, 2)	
  AND	PARSENAME(@CurrentVersion, 1) < PARSENAME(@Version, 1)	GOTO CurrentOlder
ELSE IF	PARSENAME(@CurrentVersion, 3) = PARSENAME(@Version, 3)
  AND	PARSENAME(@CurrentVersion, 2) = PARSENAME(@Version, 2)	
  AND	PARSENAME(@CurrentVersion, 1) = PARSENAME(@Version, 1)	GOTO CurrentSame

CurrentNewer:
	IF @AllowRollBack = 1
	BEGIN
		PRINT '  - Current Object is a Newer Version.  *** ROLLING BACK ***'
		GOTO DeployScript
	END
	
	PRINT '  - Current Object is a Newer Version.  *** Object Not Deployed ***'
	Goto SkipDeploy
	
CurrentSame:
	PRINT '  - Current Object is the Same Version. *** Object Not Deployed ***'
	Goto SkipDeploy
	
CurrentOlder:
	PRINT '  - Current Object is an Older Version. *** Replacing Object ***'

DeployScript:
-- CREATE HEADER AND FOOTER
SET	@COMMAND	= 'USE [' + @DatabaseName + ']' + CHAR(13) + CHAR(10) 
			+ 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
			+ CASE WHEN OBJECT_NAME(@ObjectID,DB_ID(@DatabaseName)) IS NOT NULL 
				THEN 'BEGIN TRANSACTION' + CHAR(13) + CHAR(10) 
					+ 'DROP ' + @ObjectType + ' ' + @SchemaName + '.' + @ObjectName + CHAR(13) + CHAR(10) 
					+ 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
				ELSE '' END
			
EXEC	[dbaadmin].[dbo].[dbasp_FileAccess_Write] 
		@String		= @COMMAND
		,@Path		= @Path
		,@Filename	= 'DeployHeader.sql'

SET	@COMMAND	= CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
			+ CASE WHEN OBJECT_NAME(@ObjectID,DB_ID(@DatabaseName)) IS NOT NULL 
				THEN ' IF @@ERROR > 0 ROLLBACK TRANSACTION' + CHAR(13) + CHAR(10)
					+ 'ELSE COMMIT TRANSACTION' + CHAR(13) + CHAR(10) 
				ELSE '' END
			+ 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)

EXEC	[dbaadmin].[dbo].[dbasp_FileAccess_Write] 
		@String		= @COMMAND
		,@Path		= @Path
		,@Filename	= 'DeployFooter.sql'


SET	@COMMAND	= 'COPY ' + @Path + 'DeployHeader.sql + ' + @PathAndFile + ' + ' + @Path + 'DeployFooter.sql ' + @Path + 'DeployFinal.sql'
EXEC	xp_CmdShell @COMMAND, no_output


-- DEPLOY SCRIPT
	PRINT '  - Deploying Object.'

	SET 	@COMMAND = 'sqlcmd -S' + @@servername + ' -u -E -b -i' + @Path + 'DeployFinal.sql -o' + @Path + 'DeployOutput.txt'
	EXEC	@RC = master.sys.xp_cmdshell @COMMAND, no_output
	IF @RC != 0
	BEGIN
		PRINT	'  - Deploy Failed.   *** Object Not Deployed ***'
		PRINT	''
		
		SET	@CommentHeader = '-- SCRIPT EXECUTED --' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
		
		SELECT	@CommentHeader = COALESCE(@CommentHeader,'') + CHAR(13) + CHAR(10) + [line]
		FROM	[dbaadmin].[dbo].[dbaudf_FileAccess_Read] (@Path, 'DeployFinal.sql')

		SET	@CommentHeader = @CommentHeader + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + '-- ERROR DETAILS --' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
				
		SELECT	@CommentHeader = COALESCE(@CommentHeader,'') + CHAR(13) + CHAR(10) + [line]
		FROM	[dbaadmin].[dbo].[dbaudf_FileAccess_Read] (@Path, 'DeployOutput.txt')
		
		PRINT	@CommentHeader
		GOTO	SkipDeploy
	END
	ELSE
		PRINT '  - Deploy Successfull.'

-- SET EXTENDED PROPERTIES
	PRINT '  - Setting Extended Properties.'

	SET 	@COMMAND = '
	USE	['+@DatabaseName+']
	EXEC	sys.sp_addextendedproperty 
			@name		= ''Version''	,@value		= '''+@Version+''', 
			@level0type	= N''SCHEMA''	,@level0name	= '''+@SchemaName+''', 
			@level1type	= '''+@ObjectType+'''	,@level1name	= '''+@ObjectName+''''
	EXEC	(@COMMAND)

-- UPDATE BUILDCHANGES TABLE

	INSERT INTO [dbaadmin].[dbo].[BuildSchemaChanges]
			(
			[MajorReleaseNumber]
			,[MinorReleaseNumber]
			,[PointReleaseNumber]
			,[DatabaseName]
			,[SchemaName]
			,[ObjectType]
			,[ObjectName]
			,[DateApplied]
			,[Comments]
			,[bd_id]
			)
	SELECT		PARSENAME(@Version, 3)
			,PARSENAME(@Version, 2)
			,PARSENAME(@Version, 1)
			,@DatabaseName
			,@SchemaName
			,@ObjectType
			,@ObjectName
			,GetDate()
			,CASE	WHEN @ObjectID IS NULL THEN 'New Object'
				ELSE 'Replace Object' END
			,@bd_id

SkipDeploy:

-- CLEANUP TEMP FILES


