
ALTER TRIGGER tr_AuditDDLChange ON DATABASE FOR DDL_DATABASE_LEVEL_EVENTS
/****************************************************************************
-- PUT MOST RECENT MODIFICATION ENTRY ABOVE OTHER SO MOST RECENT IS FIRST
--
<CommentHeader>
	<VersionControl>
 		<DatabaseName>dbaadmin</DatabaseName>				
		<SchemaName></SchemaName>
		<ObjectType>Trigger</ObjectType>
		<ObjectName>tr_AuditDDLChange</ObjectName>
		<Version>1.0.0</Version>
		<Created By="Steve Ledridge" On="09/10/2011"/>
		<Modified By="" On="" Reason=""/>
	</VersionControl>
	<Purpose>Generate Audit History of all DDL Changes</Purpose>
	<Description>This was Created in order to automate DB Object Versioning</Description>
	<Dependencies>
		<Object Type="Table" Name="BuildSchemaChanges" VersionCompare=">=" Version="1.0.0"/>
	</Dependencies>
	<Parameters>
		<Parameter Type="" Name="" Desc=""/>
	</Parameters>
	<Permissions>
		<Perm Type="" Priv="" To="" With=""/>
	</Permissions>
</CommentHeader>
*****************************************************************************/
AS
BEGIN 
	SET		NOCOUNT			ON
	
	DECLARE		@data			XML
	DECLARE		@HeaderXML		XML
			,@EventType		sysname
			,@PostTime		DateTime
			,@ServerName		sysname
			,@LoginName		sysname
			,@UserName		sysname
			,@DatabaseName		sysname
			,@SchemaName		sysname
			,@ObjectName		sysname
			,@ObjectType		sysname
			,@DDL			VarChar(max)
			,@CurrentVersion	sysname
			,@CB_DatabaseName	sysname
			,@CB_SchemaName		sysname
			,@CB_ObjectType		sysname
			,@CB_ObjectName		sysname
			,@CB_Version		sysname
			,@CB_CreatedBy		sysname
			,@CB_CreatedOn		datetime
			,@CB_ModifiedBy		sysname
			,@CB_ModifiedOn		datetime
			,@CB_Purpose		varChar(max)
			,@DBVersion		sysname
			,@DBAllowRollBack	bit

	-- GET DATABASE EXTENDED PROPERTIES
	
		-- GET Version FROM DATABASE
		SELECT	@DBVersion = CAST(value AS sysname) 
		FROM	fn_listextendedproperty('Version', default, default, default, default, default, default)


		-- GET AllowRollback FROM DATABASE
		SELECT	@DBAllowRollBack = CAST(value AS bit) 
		FROM	fn_listextendedproperty('AllowRollback', default, default, default, default, default, default)

	SET	@data		= EVENTDATA()

	SELECT	@EventType	= a.b.value('EventType[1]','sysname')
		,@PostTime	= a.b.value('PostTime[1]','datetime')
		,@ServerName	= a.b.value('ServerName[1]','sysname')
		,@LoginName	= a.b.value('LoginName[1]','sysname')
		,@UserName	= a.b.value('UserName[1]','sysname')
		,@DatabaseName	= a.b.value('DatabaseName[1]','sysname')
		,@SchemaName	= a.b.value('SchemaName[1]','sysname')
		,@ObjectName	= a.b.value('ObjectName[1]','sysname')
		,@ObjectType	= a.b.value('ObjectType[1]','sysname')
		,@DDL		= a.b.value('TSQLCommand[1]','varchar(max)')
		
	FROM	@Data.nodes('EVENT_INSTANCE') a(b)

	PRINT	'-- ' + @EventType + ' - ' + QUOTENAME(@DatabaseName) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ObjectName) 
	
	IF	CHARINDEX('<CommentHeader>',@DDL) = 0
	BEGIN
		PRINT	' -- CommentHeader Not Found'
		
		IF @EventType NOT LIKE 'DROP%' -- VERSION IS NOT RELIVENT FOR DROPS
		BEGIN
			SET	@CB_Version = @DBVersion
			PRINT	'  -- Using Database Version (' + @CB_Version + ')'
		END
	END
	ELSE
	BEGIN
		SET	@HeaderXML	=	CAST(SUBSTRING	(
								@DDL
								,CHARINDEX('<CommentHeader>',@DDL)
								,CHARINDEX('</CommentHeader>',@DDL)+16-CHARINDEX('<CommentHeader>',@DDL)
								) AS XML)
		
		SELECT	@CB_DatabaseName	= a.b.value('VersionControl[1]/DatabaseName[1]','sysname')
			,@CB_SchemaName		= a.b.value('VersionControl[1]/SchemaName[1]','sysname')
			,@CB_ObjectType		= a.b.value('VersionControl[1]/ObjectType[1]','sysname')
			,@CB_ObjectName		= a.b.value('VersionControl[1]/ObjectName[1]','sysname')
			,@CB_Version		= a.b.value('VersionControl[1]/Version[1]','sysname')
			,@CB_CreatedBy		= a.b.value('VersionControl[1]/Created[1]/@By','sysname')
			,@CB_CreatedOn		= a.b.value('VersionControl[1]/Created[1]/@On','datetime')
			,@CB_ModifiedBy		= a.b.value('VersionControl[1]/Modified[1]/@By','sysname')
			,@CB_ModifiedOn		= a.b.value('VersionControl[1]/Modified[1]/@On','datetime')
			,@CB_ModifiedOn		= a.b.value('VersionControl[1]/Modified[1]/@On','datetime')
			,@CB_Purpose		= a.b.value('Purpose[1]','varchar(max)')
				
		FROM	@HeaderXML.nodes('CommentHeader') a(b)
		
		IF @EventType LIKE 'DROP%'
		BEGIN
			PRINT	'  -- Drop Purpose: ' + COALESCE(@CB_Purpose,'No Purpose Given')
		END
		ELSE
			PRINT	'  -- Deploying Version (' + @CB_Version + ')'
	END
	
	IF @EventType LIKE 'CREATE%' AND @EventType NOT LIKE '%TRIGGER'
	BEGIN
		PRINT '   -- Creating "Version" Extended Property'
		EXEC	sys.sp_addextendedproperty 
				@name		= 'Version'	,@value		= @CB_Version,
				@level0type	= N'SCHEMA'	,@level0name	= @SchemaName,
				@level1type	= @ObjectType	,@level1name	= @ObjectName
	END
	ELSE IF @EventType LIKE 'ALTER%' AND @EventType NOT LIKE '%TRIGGER'
	BEGIN
		SELECT	@CurrentVersion = CAST(value AS sysname) 
		FROM	fn_listextendedproperty('Version', 'schema', @SchemaName, @ObjectType, @ObjectName, default, default)
		
		If	@CurrentVersion IS NULL
		BEGIN
			PRINT '  -- Current Object has no Version'
			GOTO CurrentOlder
		END

		PRINT '  -- Current Object Version (' + @CurrentVersion + ')'

		IF	PARSENAME(@CurrentVersion, 3) < PARSENAME(@CB_Version, 3)	GOTO CurrentOlder
		ELSE IF PARSENAME(@CurrentVersion, 3) = PARSENAME(@CB_Version, 3)
		  AND	PARSENAME(@CurrentVersion, 2) < PARSENAME(@CB_Version, 2)	GOTO CurrentOlder
		ELSE IF	PARSENAME(@CurrentVersion, 3) = PARSENAME(@CB_Version, 3)
		  AND	PARSENAME(@CurrentVersion, 2) = PARSENAME(@CB_Version, 2)	
		  AND	PARSENAME(@CurrentVersion, 1) < PARSENAME(@CB_Version, 1)	GOTO CurrentOlder
		ELSE IF	PARSENAME(@CurrentVersion, 3) = PARSENAME(@CB_Version, 3)
		  AND	PARSENAME(@CurrentVersion, 2) = PARSENAME(@CB_Version, 2)	
		  AND	PARSENAME(@CurrentVersion, 1) = PARSENAME(@CB_Version, 1)	GOTO CurrentSame

		CurrentNewer:
			IF @DBAllowRollBack = 1
			BEGIN
				PRINT '   -- Current Object is a Newer Version.  *** ROLLBACK ALLOWED ***'
				GOTO PassedVersionTests
			
			END
			ELSE
			BEGIN
				PRINT '   -- Current Object is a Newer Version.  *** Object NOT Deployed ***'
				ROLLBACK
				GOTO TriggerComplete
			END
			
		CurrentSame:
			IF @DBAllowRollBack = 1
			BEGIN
				PRINT '   -- Current Object is the Same Version.  *** ROLLBACK ALLOWED ***'
				GOTO PassedVersionTests
			
			END
			ELSE
			BEGIN
				PRINT '   -- Current Object is the Same Version.  *** Object NOT Deployed ***'
				ROLLBACK
				GOTO TriggerComplete
			END
			
		CurrentOlder:
			PRINT '   -- Current Object is an Older Version. *** Replacing Object ***'

		PassedVersionTests:
		
		If @CurrentVersion IS NULL
		BEGIN
			PRINT	'   -- Creating "Version" Extended Property'
			EXEC	sys.sp_addextendedproperty 
				@name		= 'Version'	,@value		= @CB_Version,
				@level0type	= N'SCHEMA'	,@level0name	= @SchemaName,
				@level1type	= @ObjectType	,@level1name	= @ObjectName
		END
		ELSE
		BEGIN
			PRINT	'   -- Updating "Version" Extended Property'
			EXEC	sys.sp_updateextendedproperty 
				@name		= 'Version'	,@value		= @CB_Version,
				@level0type	= N'SCHEMA'	,@level0name	= @SchemaName,
				@level1type	= @ObjectType	,@level1name	= @ObjectName
		END
	END
	
		
	-- SET VALUE FOR LATER USE
	SET	@CB_Purpose	= COALESCE(@CB_Purpose,'No Purpose Given')
	
	IF OBJECT_ID('[dbo].[BuildSchemaChanges]') IS NOT NULL
	BEGIN
		PRINT	'    -- Logging Activity in LOCAL DB'
			
		INSERT INTO [dbo].[BuildSchemaChanges]
			(
			[EventType]
			,[DatabaseName]
			,[SchemaName]
			,[ObjectName]
			,[ObjectType]
			,[SqlCommand]
			,[EventDate]
			,[LoginName]
			,[UserName]
			,[VC_DatabaseName]
			,[VC_SchemaName]
			,[VC_ObjectType]
			,[VC_ObjectName]
			,[VC_Version]
			,[VC_CreatedBy]
			,[VC_CreatedOn]
			,[VC_ModifiedBy]
			,[VC_ModifiedOn]
			,[VC_Purpose]
			)
		VALUES	(
			@EventType	
			,@DatabaseName	
			,@SchemaName	
			,@ObjectName
			,@ObjectType
			,@DDL
			,@PostTime	
			,@LoginName	
			,@UserName	
			,@CB_DatabaseName	
			,@CB_SchemaName	
			,@CB_ObjectType	
			,@CB_ObjectName	
			,@CB_Version	
			,@CB_CreatedBy	
			,@CB_CreatedOn	
			,@CB_ModifiedBy	
			,@CB_ModifiedOn
			,@CB_Purpose	
			)
	END
	ELSE
		PRINT	'    -- [dbo].[BuildSchemaChanges] does not Exist *** Not Logging Activity in LOCAL DB ***'
		
	IF OBJECT_ID('[dbaadmin].[dbo].[BuildSchemaChanges]') IS NOT NULL AND @DatabaseName != 'dbaadmin'
	BEGIN
		PRINT	'    -- Logging Activity in DBAADMIN DB'
		
		INSERT INTO [dbaadmin].[dbo].[BuildSchemaChanges]
			(
			[EventType]
			,[DatabaseName]
			,[SchemaName]
			,[ObjectName]
			,[ObjectType]
			,[SqlCommand]
			,[EventDate]
			,[LoginName]
			,[UserName]
			,[VC_DatabaseName]
			,[VC_SchemaName]
			,[VC_ObjectType]
			,[VC_ObjectName]
			,[VC_Version]
			,[VC_CreatedBy]
			,[VC_CreatedOn]
			,[VC_ModifiedBy]
			,[VC_ModifiedOn]
			,[VC_Purpose]
			)
		VALUES	(
			@EventType	
			,@DatabaseName	
			,@SchemaName	
			,@ObjectName
			,@ObjectType
			,@DDL
			,@PostTime	
			,@LoginName	
			,@UserName	
			,@CB_DatabaseName	
			,@CB_SchemaName	
			,@CB_ObjectType	
			,@CB_ObjectName	
			,@CB_Version	
			,@CB_CreatedBy	
			,@CB_CreatedOn	
			,@CB_ModifiedBy	
			,@CB_ModifiedOn
			,@CB_Purpose	
			)
	END
	ELSE IF @DatabaseName != 'dbaadmin'
		PRINT	'    -- [dbaadmin].[dbo].[BuildSchemaChanges] does not Exist *** Not Logging Activity in DBAADMIN DB ***'
	
TriggerComplete:

END
GO