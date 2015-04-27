ALTER TRIGGER tr_AuditDDLChange ON DATABASE FOR DDL_DATABASE_LEVEL_EVENTS
/****************************************************************************
<CommentHeader>
	<VersionControl>
 		<DatabaseName>dbaadmin</DatabaseName>				
		<SchemaName></SchemaName>
		<ObjectType>Trigger</ObjectType>
		<ObjectName>tr_AuditDDLChange</ObjectName>
		<Version>1.0.2</Version>
		<Created By="Steve Ledridge" On="03/09/2011"/>
		<Modifications>
			<Mod By="Steve Ledridge" On="03/11/2011" Reason="Added Sections for Dependencies and Permissions"/>
			<Mod By="Steve Ledridge" On="03/11/2011 05:42:00 PM" Reason="Modified Modifications Section to allow sorting by datetime"/>
		</Modifications>
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
			,@CB_ModReason		VarChar(max)
			,@CB_Purpose		varChar(max)
			,@DBVersion		sysname
			,@DBAllowRollBack	bit

	DECLARE		@Dependencies		TABLE
			(
			[Name]			sysname	NULL
			,[Type]			sysname	NULL
			,[VC]			sysname	NULL
			,[Ver]			sysname	NULL
			)

	DECLARE		@Permissions		TABLE
			(
			[Type]			sysname	NULL 
			,[Priv]			sysname	NULL
			,[To]			sysname	NULL
			,[With]			sysname	NULL
			)

	DECLARE		@Mods			TABLE
			(
			[By]			sysname		NULL 
			,[On]			datetime	NULL
			,[Reason]		varchar(max)	NULL
			)
									
	-- GET DATABASE EXTENDED PROPERTIES

		-- GET Version FROM DATABASE
		SELECT	@DBVersion = CAST(value AS sysname) 
		FROM	fn_listextendedproperty('Version', default, default, default, default, default, default)
		IF	@DBVersion IS NULL EXEC sys.sp_addextendedproperty @name='Version', @value='1.0.0'

		-- GET ALLOWROLLBACK FROM DATABASE
		SELECT	@DBAllowRollBack = CAST(value AS bit) 
		FROM	fn_listextendedproperty('AllowRollback', default, default, default, default, default, default)
		IF	@DBAllowRollBack IS NULL EXEC sys.sp_addextendedproperty @name=N'AllowRollback', @value=N'0'

	-- GET EVENTDATA
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
	
	-- GET CURRENT VERSION
		SELECT	@CurrentVersion = CAST(value AS sysname) 
		FROM	fn_listextendedproperty('Version', 'schema', @SchemaName, @ObjectType, @ObjectName, default, default)

	-- PRINT EVENT COMMENT
		PRINT	'-- ' + @EventType + ' - ' + QUOTENAME(@DatabaseName) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ObjectName) + ' (' + COALESCE(@CurrentVersion,'?.?.?') + ')'
	
	-- IDENTIFY IF DDL HAS CODED COMMENT BLOCK
		IF	CHARINDEX('<CommentHeader>',@DDL) = 0
		BEGIN
			-----------------------------------
			-- NO CODED COMMENT BLOCK IN DDL
			-----------------------------------
			PRINT	' -- CommentHeader Not Found'
			
			IF @EventType NOT LIKE 'DROP%' -- VERSION IS NOT RELIVENT FOR DROPS
			BEGIN
				SET	@CB_Version = @DBVersion
				PRINT	'  -- Using Database Version (' + @CB_Version + ')'
			END
		END -- END OF PROCESS FOR NO CODED COMMENT BLOCK
		ELSE
		BEGIN
			-----------------------------------
			-- CODED COMMENT BLOCK IN DDL
			-----------------------------------
			-- EXTRACT CODED COMMENT BLOCK FROM DDL
				SET @HeaderXML = CAST(SUBSTRING	(
								@DDL
								,CHARINDEX('<CommentHeader>',@DDL)
								,CHARINDEX('</CommentHeader>',@DDL)+16-CHARINDEX('<CommentHeader>',@DDL)
								) AS XML)
			-- GET VALUES FROM CODED COMMENT BLOCK
				SELECT	@CB_DatabaseName	= a.b.value('VersionControl[1]/DatabaseName[1]','sysname')
					,@CB_SchemaName		= a.b.value('VersionControl[1]/SchemaName[1]','sysname')
					,@CB_ObjectType		= a.b.value('VersionControl[1]/ObjectType[1]','sysname')
					,@CB_ObjectName		= a.b.value('VersionControl[1]/ObjectName[1]','sysname')
					,@CB_Version		= a.b.value('VersionControl[1]/Version[1]','sysname')
					,@CB_CreatedBy		= a.b.value('VersionControl[1]/Created[1]/@By','sysname')
					,@CB_CreatedOn		= a.b.value('VersionControl[1]/Created[1]/@On','datetime')
					--,@CB_ModifiedBy		= a.b.value('VersionControl[1]/Modified[1]/@By','sysname')
					--,@CB_ModifiedOn		= a.b.value('VersionControl[1]/Modified[1]/@On','datetime')
					--,@CB_ModReason		= a.b.value('VersionControl[1]/Modified[1]/@Reason','varchar(max)')
					,@CB_Purpose		= a.b.value('Purpose[1]','varchar(max)')
				FROM	@HeaderXML.nodes('CommentHeader') a(b)

				-- GATHER ALL MODIFICATION RECORDS FROM COMMENT BLOCK
				INSERT INTO @Mods
				SELECT	a.b.value('@By','sysname')
					,a.b.value('@On','datetime')
					,a.b.value('@Reason','varchar(max)')
				FROM	@HeaderXML.nodes('//CommentHeader/VersionControl/Modifications/Mod') AS a(b)
				
				-- GET MOST RECENT MODIFICATION
				SELECT	TOP 1
					@CB_ModifiedBy		= [By]
					,@CB_ModifiedOn		= [On]
					,@CB_ModReason		= [Reason]
				FROM	@Mods
				ORDER BY [On] Desc

				-- GATHER ALL DEPENDENCY RECORDS FROM COMMENT BLOCK
				INSERT INTO @Dependencies
				SELECT	a.b.value('@Name','sysname')
					,a.b.value('@Type','sysname')
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
				
			-- PRINT COMMENTS FOR VALUES IN COMMENT BLOCK
			----------------------------------------------
			----------------------------------------------
				IF @EventType LIKE 'DROP%'
				    PRINT	'  -- Drop Purpose: ' + COALESCE(@CB_Purpose,'No Purpose Given')
				ELSE
				    PRINT	'  -- Deploying Version (' + @CB_Version + ')'
				    
			----------------------------------------------
			----------------------------------------------
		END -- OF COMMENT BLOCK PROCESSING
		
		---------------------------------------------------------------
		---------------------------------------------------------------
	----------			PROCESS DEPENDENCIES
		---------------------------------------------------------------
		---------------------------------------------------------------		
		IF EXISTS (SELECT * FROM @Dependencies WHERE COALESCE([Name],'')!='')
		BEGIN
			PRINT '   -- NO DEPENDENCIES CODE YET'
			SELECT * FROM @Dependencies





		END
		---------------------------------------------------------------
		---------------------------------------------------------------
	----------			END DEPENDENCIES
		---------------------------------------------------------------
		---------------------------------------------------------------		
		
		---------------------------------------------------------------
		---------------------------------------------------------------
	----------		PROCESS SECTIONS BASED ON EVENT TYPE
		---------------------------------------------------------------
		---------------------------------------------------------------
		
			--------------------------------------------
			--------------------------------------------
			--	DROP OBJECTS SECTION
			--------------------------------------------
			--------------------------------------------
			IF @EventType LIKE 'DROP%' AND @EventType NOT IN ('DROP_EXTENDED_PROPERTY','DROP_TRIGGER')
			BEGIN
				PRINT '  -- No Drop Checks'

						
			END -- OF DROP OBJECT BLOCK
			--------------------------------------------
			--------------------------------------------
		----------------------------------------------------
			-- PROCESS SECTIONS BASED ON EVENT TYPE
			--------------------------------------------
			--------------------------------------------
			--	CREATE OBJECTS SECTION
			--------------------------------------------
			--------------------------------------------
			IF @EventType LIKE 'CREATE%' AND @EventType NOT IN ('CREATE_EXTENDED_PROPERTY','CREATE_TRIGGER')
			BEGIN
				PRINT '   -- Creating "Version" Extended Property'
				EXEC	sys.sp_addextendedproperty 
						@name		= 'Version'	,@value		= @CB_Version,
						@level0type	= N'SCHEMA'	,@level0name	= @SchemaName,
						@level1type	= @ObjectType	,@level1name	= @ObjectName
						
			END -- OF CREATE OBJECT BLOCK
			--------------------------------------------
			--------------------------------------------
		----------------------------------------------------
			--------------------------------------------
			--------------------------------------------
			--	ALTER OBJECTS SECTION
			--------------------------------------------
			--------------------------------------------
			IF @EventType LIKE 'ALTER%' AND @EventType NOT IN ('ALTER_EXTENDED_PROPERTY','ALTER_TRIGGER')
			BEGIN
				---------------------------------------------------------------
				---------------------------------------------------------------
				-- BEGIN VERSION CHECKS
				---------------------------------------------------------------
				---------------------------------------------------------------
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
					---------------------------------------------------------------
					---------------------------------------------------------------
					-- CURRENT OBJECT IS NEWER THAN THE ONE BEING DEPLOYED
					---------------------------------------------------------------
					---------------------------------------------------------------
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
					---------------------------------------------------------------
					---------------------------------------------------------------
					-- CURRENT OBJECT IS THE SAME AS THE ONE BEING DEPLOYED
					---------------------------------------------------------------
					---------------------------------------------------------------
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
					---------------------------------------------------------------
					---------------------------------------------------------------
					-- CURRENT OBJECT IS OLDER THAN THE ONE BEING DEPLOYED
					---------------------------------------------------------------
					---------------------------------------------------------------
					PRINT '   -- Current Object is an Older Version. *** Replacing Object ***'

				PassedVersionTests:
					---------------------------------------------------------------
					---------------------------------------------------------------
					-- DONE WITH ALL VERSION TESTS
					---------------------------------------------------------------
					---------------------------------------------------------------
				If @CurrentVersion IS NULL
				BEGIN
					---------------------------------------------------------------
					---------------------------------------------------------------
					-- CREATE VERSION EXTENDED PROPERTY IF IT DIDNT ALREADY EXIST
					---------------------------------------------------------------
					---------------------------------------------------------------
					PRINT	'   -- Creating "Version" Extended Property'
					EXEC	sys.sp_addextendedproperty 
						@name		= 'Version'	,@value		= @CB_Version,
						@level0type	= N'SCHEMA'	,@level0name	= @SchemaName,
						@level1type	= @ObjectType	,@level1name	= @ObjectName
				END
				ELSE
				BEGIN
					---------------------------------------------------------------
					---------------------------------------------------------------
					-- MODIFY VERSION EXTENDED PROPERTY IF IT DID ALREADY EXIST
					---------------------------------------------------------------
					---------------------------------------------------------------
					PRINT	'   -- Updating "Version" Extended Property'
					EXEC	sys.sp_updateextendedproperty 
						@name		= 'Version'	,@value		= @CB_Version,
						@level0type	= N'SCHEMA'	,@level0name	= @SchemaName,
						@level1type	= @ObjectType	,@level1name	= @ObjectName
				END
			END
			--------------------------------------------
			--------------------------------------------
		---------------------------------------------------------------
		---------------------------------------------------------------
		--		END SECTIONS BASED ON EVENT TYPE
		---------------------------------------------------------------
		---------------------------------------------------------------
		---------------------------------------------------------------
		---------------------------------------------------------------
	----------			PROCESS PERMISSIONS
		---------------------------------------------------------------
		---------------------------------------------------------------		
		IF EXISTS (SELECT * FROM @Permissions WHERE COALESCE([Type],'')!='')
		BEGIN
			PRINT '   -- NO PERMISSIONS CODE YET'
			SELECT * FROM @Permissions





		END
		---------------------------------------------------------------
		---------------------------------------------------------------
	----------			END PERMISSIONS
		---------------------------------------------------------------
		---------------------------------------------------------------			

		---------------------------------------------------------------
		---------------------------------------------------------------
	----------	LOG ALL ACTIVITY TO LOCAL TABLE IF IT EXISTS
		---------------------------------------------------------------
		---------------------------------------------------------------
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
				,COALESCE(@CB_ModReason,@CB_Purpose,'No Purpose Given')	
				)
		END
		ELSE
			PRINT	'    -- [dbo].[BuildSchemaChanges] does not Exist *** Not Logging Activity in LOCAL DB ***'
			
		---------------------------------------------------------------
		---------------------------------------------------------------
	----------	LOG ALL ACTIVITY TO CENTRAL TABLE IF IT EXISTS
		---------------------------------------------------------------
		---------------------------------------------------------------
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
				,COALESCE(@CB_ModReason,@CB_Purpose,'No Purpose Given')	
				)
		END
		ELSE IF @DatabaseName != 'dbaadmin'
			PRINT	'    -- [dbaadmin].[dbo].[BuildSchemaChanges] does not Exist *** Not Logging Activity in DBAADMIN DB ***'
		---------------------------------------------------------------
		---------------------------------------------------------------
		--			DONE WITH ALL LOGGING
		---------------------------------------------------------------
		---------------------------------------------------------------
		
TriggerComplete:

END
