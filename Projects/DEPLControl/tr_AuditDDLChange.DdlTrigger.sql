USE [DEPLcontrol]
GO
/****** Object:  DdlTrigger [tr_AuditDDLChange]    Script Date: 10/4/2013 11:02:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [tr_AuditDDLChange] ON DATABASE FOR DDL_DATABASE_LEVEL_EVENTS
/****************************************************************************
<CommentHeader>
	<VersionControl>
 		<DatabaseName>dbaadmin</DatabaseName>				
		<SchemaName></SchemaName>
		<ObjectType>Trigger</ObjectType>
		<ObjectName>tr_AuditDDLChange</ObjectName>
		<Version>1.6.5</Version>
		<Build Number="" Application="" Branch=""/>
		<Created By="Steve Ledridge" On="03/09/2011"/>
		<Modifications>
			<Mod By="Steve Ledridge" On="03/11/2011" Reason="Added Sections for Dependencies and Permissions"/>
			<Mod By="Steve Ledridge" On="03/11/2011 05:42:00 PM" Reason="Modified Modifications Section to allow sorting by datetime"/>
			<Mod By="Steve Ledridge" On="03/14/2011 05:08:00 PM" Reason="Added Fields For Build app,branch,number"/>
			<Mod By="Steve Ledridge" On="03/14/2011 07:45:00 PM" Reason="Added Status Column"/>
			<Mod By="Steve Ledridge" On="03/18/2011 01:10:00 PM" Reason="Added DEPLInstanceID Column"/>
		</Modifications>
	</VersionControl>
	<Purpose>Generate Audit History of all DDL Changes</Purpose>
	<Description>This was Created in order to automate DB Object Versioning</Description>
	<Dependencies>
		<Object Type="Table" Schema="dbo" Name="BuildSchemaChanges" VersionCompare=">=" Version="1.6.2"/>
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
	---------------------------------------------------------------
	---------------------------------------------------------------
----------		DECLARES AND SETS
	---------------------------------------------------------------
	---------------------------------------------------------------	
	SET			NOCOUNT				ON
	
	DECLARE		@data				XML
				,@HeaderXML			XML
				,@EventType			sysname
				,@PostTime			DateTime
				,@ServerName		sysname
				,@LoginName			sysname
				,@UserName			sysname
				,@DatabaseName		sysname
				,@SchemaName		sysname
				,@ObjectName		sysname
				,@ObjectType		sysname
				,@DDL				VarChar(max)
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
				,@CB_BldNum			sysname
				,@CB_BldApp			sysname
				,@CB_BldBrnch		sysname
				,@DBVersion			sysname
				,@DBBldNum			sysname
				,@DBBldApp			sysname
				,@DBBldBrnch		sysname
				,@DBAllowRollBack	bit
				,@ExtProp			sysname
				,@ExtProp_val		sql_variant
				,@ExtProp_chk		sql_variant
				,@Status			VarChar(2000)
				,@ECC				bit
				,@DEPLFileName		sysname
				,@DEPLInstanceID	sysname


	DECLARE		@Dependencies		TABLE
				(
				[Name]				sysname			NULL
				,[Schema]			sysname			NULL
				,[Type]				sysname			NULL
				,[VC]				sysname			NULL
				,[Ver]				sysname			NULL
				)

	DECLARE		@Permissions		TABLE
				(
				[Type]				sysname			NULL 
				,[Priv]				sysname			NULL
				,[To]				sysname			NULL
				,[With]				sysname			NULL
				)

	DECLARE		@Mods				TABLE
				(
				[By]				sysname			NULL 
				,[On]				datetime		NULL
				,[Reason]			varchar(max)	NULL
				)
			
	SET			@Status				= ''
	
	BEGIN -- START PROCESSING	
		---------------------------------------------------------------
		---------------------------------------------------------------
	----------		GET DATABASE EXTENDED PROPERTIES
		---------------------------------------------------------------
		---------------------------------------------------------------	
		BEGIN -- GET DATABASE EXTENDED PROPERTIES
		
			PRINT '-- Getting EnableCodeComments From ' + DB_Name() 
			-- GET EnableCodeComments FROM DATABASE
			SELECT	@ExtProp_chk = NULL, @ExtProp = 'EnableCodeComments', @ExtProp_val = '0' --USE AS DEFAULT VALUE IF CREATING PARAMETER
			SELECT	@ExtProp_chk = Value FROM sys.fn_listextendedproperty(@ExtProp, default, default, default, default, default, default)
			IF @@ROWCOUNT = 0 EXEC sys.sp_addextendedproperty @name=@ExtProp, @value=@ExtProp_val	
			SELECT	@ECC = COALESCE(CAST(@ExtProp_chk AS bit),0)
					
			
			IF @ECC = 1 PRINT '-- Getting DEPLInstanceID From ' + DB_Name()
			-- GET DEPLINSTANCEID FROM DEPLINFO DATABASE IF IT IS POPULATED
			if DB_ID('DEPLinfo') IS NOT NULL
			BEGIN -- GET DEPLInstanceID FROM DEPLinfo DB
				SELECT	@ExtProp_chk = NULL, @ExtProp = 'DEPLInstanceID'
				SELECT	@ExtProp_chk = Value FROM DEPLinfo.sys.fn_listextendedproperty(@ExtProp, default, default, default, default, default, default)
				IF		COALESCE(@ExtProp_chk,'') = '' SET @ExtProp_chk = NULL
				SELECT	@DEPLInstanceID = COALESCE(CAST(@ExtProp_chk AS sysname),'11111111-1111-1111-1111-111111111111')
			END
				
			IF @ECC = 1 PRINT '-- Getting Version From ' + DB_Name()
			-- GET Version FROM DATABASE			
			SELECT	@ExtProp_chk = NULL, @ExtProp = 'Version', @ExtProp_val = '1.0.0' --USE AS DEFAULT VALUE IF CREATING PARAMETER
			SELECT	@ExtProp_chk = Value FROM sys.fn_listextendedproperty(@ExtProp, default, default, default, default, default, default)
			IF @@ROWCOUNT = 0 EXEC sys.sp_addextendedproperty @name=@ExtProp, @value=@ExtProp_val	
			SELECT	@DBVersion = CAST(@ExtProp_chk AS sysname)
			
			
			IF @ECC = 1 PRINT '-- Getting BuildApplication From ' + DB_Name()
			-- GET BuildApp FROM DATABASE
			SELECT	@ExtProp_chk = NULL, @ExtProp = 'BuildApplication', @ExtProp_val = '' --USE AS DEFAULT VALUE IF CREATING PARAMETER
			SELECT	@ExtProp_chk = Value FROM sys.fn_listextendedproperty(@ExtProp, default, default, default, default, default, default)
			IF @@ROWCOUNT = 0 EXEC sys.sp_addextendedproperty @name=@ExtProp, @value=@ExtProp_val	
			SELECT	@DBBldApp = CAST(@ExtProp_chk AS sysname)

			IF @ECC = 1 PRINT '-- Getting BuildBranch From ' + DB_Name()
			-- GET BuildBrnch FROM DATABASE
			SELECT	@ExtProp_chk = NULL, @ExtProp = 'BuildBranch', @ExtProp_val = '' --USE AS DEFAULT VALUE IF CREATING PARAMETER
			SELECT	@ExtProp_chk = Value FROM sys.fn_listextendedproperty(@ExtProp, default, default, default, default, default, default)
			IF @@ROWCOUNT = 0 EXEC sys.sp_addextendedproperty @name=@ExtProp, @value=@ExtProp_val	
			SELECT	@DBBldBrnch = CAST(@ExtProp_chk AS sysname)

			IF @ECC = 1 PRINT '-- Getting BuildNumber From ' + DB_Name()
			-- GET BuildNum FROM DATABASE
			SELECT	@ExtProp_chk = NULL, @ExtProp = 'BuildNumber', @ExtProp_val = '' --USE AS DEFAULT VALUE IF CREATING PARAMETER
			SELECT	@ExtProp_chk = Value FROM sys.fn_listextendedproperty(@ExtProp, default, default, default, default, default, default)
			IF @@ROWCOUNT = 0 EXEC sys.sp_addextendedproperty @name=@ExtProp, @value=@ExtProp_val	
			SELECT	@DBBldNum = CAST(@ExtProp_chk AS sysname)

			IF @ECC = 1 PRINT '-- Getting DeplFileName From ' + DB_Name()
			-- GET DeplFileName FROM DATABASE
			SELECT	@ExtProp_chk = NULL, @ExtProp = 'DeplFileName', @ExtProp_val = '' --USE AS DEFAULT VALUE IF CREATING PARAMETER
			SELECT	@ExtProp_chk = Value FROM sys.fn_listextendedproperty(@ExtProp, default, default, default, default, default, default)
			IF @@ROWCOUNT = 0 EXEC sys.sp_addextendedproperty @name=@ExtProp, @value=@ExtProp_val	
			SELECT	@DEPLFileName = CAST(@ExtProp_chk AS sysname)

			IF @ECC = 1 PRINT '-- Getting AllowRollback From ' + DB_Name()
			-- GET ALLOWROLLBACK FROM DATABASE
			SELECT	@ExtProp_chk = NULL, @ExtProp = 'AllowRollback', @ExtProp_val = '1' --USE AS DEFAULT VALUE IF CREATING PARAMETER
			SELECT	@ExtProp_chk = Value FROM sys.fn_listextendedproperty(@ExtProp, default, default, default, default, default, default)
			IF @@ROWCOUNT = 0 EXEC sys.sp_addextendedproperty @name=@ExtProp, @value=@ExtProp_val	
			SELECT	@DBAllowRollBack = COALESCE(CAST(@ExtProp_chk AS bit),1)

		END

		---------------------------------------------------------------
		---------------------------------------------------------------
	----------		PROCESS EVENTDATA
		---------------------------------------------------------------
		---------------------------------------------------------------	
		BEGIN -- PROCESS EVENTDATA
			IF @ECC = 1 PRINT '-- Getting EVENTDATA From ' + DB_Name()	
			SET	@data			= EVENTDATA()
			SELECT	@EventType	= a.b.value('EventType[1]','sysname')
				,@PostTime		= a.b.value('PostTime[1]','datetime')
				,@ServerName	= a.b.value('ServerName[1]','sysname')
				,@LoginName		= a.b.value('LoginName[1]','sysname')
				,@UserName		= a.b.value('UserName[1]','sysname')
				,@DatabaseName	= a.b.value('DatabaseName[1]','sysname')
				,@SchemaName	= a.b.value('SchemaName[1]','sysname')
				,@ObjectName	= a.b.value('ObjectName[1]','sysname')
				,@ObjectType	= a.b.value('ObjectType[1]','sysname')
				,@DDL			= a.b.value('TSQLCommand[1]','varchar(max)')
			FROM	@Data.nodes('EVENT_INSTANCE') a(b)
		
			-- GET CURRENT VERSION
			IF @ECC = 1 PRINT '-- Getting Current Version From ' +  COALESCE(@SchemaName + '.','') + @ObjectName
			SELECT	@CurrentVersion = CAST(value AS sysname) 
			FROM	fn_listextendedproperty('Version', 'schema', @SchemaName, @ObjectType, @ObjectName, default, default)

			-- PRINT EVENT COMMENT
			IF @ECC = 1 PRINT '-- ' + @EventType + ' - ' + QUOTENAME(@DatabaseName) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ObjectName) + ' (' + COALESCE(@CurrentVersion,'?.?.?') + ')'
		
			-- IDENTIFY IF DDL HAS CODED COMMENT BLOCK
			IF	CHARINDEX('<CommentHeader>',@DDL) = 0
				BEGIN -- NO COMMENT BLOCK PROCESSING
					-----------------------------------
					-- NO CODED COMMENT BLOCK IN DDL
					-----------------------------------
					IF @ECC = 1 PRINT ' -- CommentHeader Not Found'
					SET	@Status = @Status + 'CommentHeader Not Found' + CHAR(13) + CHAR(10)
					
					IF @EventType NOT LIKE 'DROP%' -- VERSION IS NOT RELIVENT FOR DROPS
					BEGIN
						SET	@CB_Version = @DBVersion
						IF @ECC = 1 PRINT '  -- Using Database Version (' + @CB_Version + ')'
					END
				END
			ELSE
				BEGIN -- COMMENT BLOCK PROCESSING
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
					SELECT	@CB_DatabaseName		= a.b.value('VersionControl[1]/DatabaseName[1]','sysname')
							,@CB_SchemaName			= a.b.value('VersionControl[1]/SchemaName[1]','sysname')
							,@CB_ObjectType			= a.b.value('VersionControl[1]/ObjectType[1]','sysname')
							,@CB_ObjectName			= a.b.value('VersionControl[1]/ObjectName[1]','sysname')
							,@CB_Version			= a.b.value('VersionControl[1]/Version[1]','sysname')
							,@CB_CreatedBy			= a.b.value('VersionControl[1]/Created[1]/@By','sysname')
							,@CB_CreatedOn			= a.b.value('VersionControl[1]/Created[1]/@On','datetime')
							,@CB_BldNum				= a.b.value('VersionControl[1]/Build[1]/@Number','sysname')
							,@CB_BldApp				= a.b.value('VersionControl[1]/Build[1]/@Application','sysname')
							,@CB_BldBrnch			= a.b.value('VersionControl[1]/Build[1]/@Branch','sysname')
							,@CB_Purpose			= a.b.value('Purpose[1]','varchar(max)')
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
						,a.b.value('@Schema','sysname')
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
						AND @ECC = 1 PRINT '  -- Drop Purpose: ' + COALESCE(@CB_Purpose,'No Purpose Given')
					ELSE
						IF @ECC = 1 PRINT '  -- Deploying Version (' + @CB_Version + ')'
					----------------------------------------------
					----------------------------------------------
				END
		END
		
		---------------------------------------------------------------
		---------------------------------------------------------------
	----------		PROCESS DEPENDENCIES IF INCLUDED
		---------------------------------------------------------------
		---------------------------------------------------------------		
		IF EXISTS (SELECT * FROM @Dependencies WHERE COALESCE([Name],'')!='')
		BEGIN -- PROCESS DEPENDENCIES IF INCLUDED
			IF @ECC = 1 PRINT '  -- CHECKING DEPENDENCIES'
			DECLARE Deps_Cursor CURSOR
			KEYSET
			FOR
			SELECT * From @Dependencies
			DECLARE	@Dep_Name	sysname
				,@Dep_Sch	sysname
				,@Dep_Type	sysname
				,@Dep_VC	sysname
				,@Dep_Ver	sysname
				,@Dep_Ver_Chk	sysname
				,@Dep_Fail	bit
			Set	@Dep_Fail	= 0
			OPEN Deps_Cursor
			FETCH NEXT FROM Deps_Cursor INTO @Dep_Name,@Dep_Sch,@Dep_Type,@Dep_VC,@Dep_Ver	
			WHILE (@@fetch_status <> -1)
			BEGIN
				IF (@@fetch_status <> -2)
				BEGIN
					If @Dep_VC = ''		-- DOES EXIST 
						AND Object_ID(@Dep_Name) Is Null
						BEGIN
							IF @ECC = 1 PRINT '   -- DEP FAIL:'+@Dep_Name+' OBJECT DOES NOT EXIST.'
							SET @Status = @Status + 'DEP FAIL:'+@Dep_Name+' OBJECT DOES NOT EXIST' + CHAR(13) + CHAR(10)
							Set @Dep_Fail = 1
							GOTO DEP_DONE
						END
						
					If @Dep_VC = '!'	-- DOES NOT EXIST 
						AND Object_ID(@Dep_Name) Is NOT Null
						BEGIN
							IF @ECC = 1 PRINT '   -- DEP FAIL:'+@Dep_Name+' OBJECT DOES EXIST.'
							SET	@Status = @Status + 'DEP FAIL:'+@Dep_Name+' OBJECT DOES EXIST' + CHAR(13) + CHAR(10)
							Set	@Dep_Fail	= 1
							GOTO DEP_DONE
						END
										
					SELECT	@Dep_Ver_Chk = CAST(value AS sysname) 
					FROM	fn_listextendedproperty('Version', 'schema', @Dep_Sch, @Dep_Type, @Dep_Name, default, default)
				
					IF	PARSENAME(@Dep_Ver_Chk, 3) < PARSENAME(@Dep_Ver, 3)	GOTO DEP_LT
					ELSE IF PARSENAME(@Dep_Ver_Chk, 3) = PARSENAME(@Dep_Ver, 3)
					  AND	PARSENAME(@Dep_Ver_Chk, 2) < PARSENAME(@Dep_Ver, 2)	GOTO DEP_LT
					ELSE IF	PARSENAME(@Dep_Ver_Chk, 3) = PARSENAME(@Dep_Ver, 3)
					  AND	PARSENAME(@Dep_Ver_Chk, 2) = PARSENAME(@Dep_Ver, 2)	
					  AND	PARSENAME(@Dep_Ver_Chk, 1) < PARSENAME(@Dep_Ver, 1)	GOTO DEP_LT
					ELSE IF	PARSENAME(@Dep_Ver_Chk, 3) = PARSENAME(@Dep_Ver, 3)
					  AND	PARSENAME(@Dep_Ver_Chk, 2) = PARSENAME(@Dep_Ver, 2)	
					  AND	PARSENAME(@Dep_Ver_Chk, 1) = PARSENAME(@Dep_Ver, 1)	GOTO DEP_EQ

					DEP_GT:
					IF @ECC = 1 PRINT '   -- DEP_GT ' + @Dep_Ver_Chk
										
					IF	@Dep_VC = '<'	-- LESS THAN
						BEGIN
							IF @ECC = 1 PRINT '   -- DEP FAIL:'+@Dep_Name+' OBJECT VERSION (' +COALESCE(@Dep_Ver_Chk,'')+ ') IS NOT LESS THAN (' + @Dep_Ver + ')'
							SET	@Status = @Status + 'DEP FAIL:'+@Dep_Name+' OBJECT VERSION (' +COALESCE(@Dep_Ver_Chk,'')+ ') IS NOT LESS THAN (' + @Dep_Ver + ')' + CHAR(13) + CHAR(10)
							Set	@Dep_Fail	= 1
						END
					
					IF	@Dep_VC = '<='	-- LESS THAN
						BEGIN
							IF @ECC = 1 PRINT '   -- DEP FAIL:'+@Dep_Name+' OBJECT VERSION (' +COALESCE(@Dep_Ver_Chk,'')+ ') IS NOT LESS THAN OR EQUAL TO (' + @Dep_Ver + ')'
							SET	@Status = @Status + 'DEP FAIL:'+@Dep_Name+' OBJECT VERSION (' +COALESCE(@Dep_Ver_Chk,'')+ ') IS NOT LESS THAN OR EQUAL TO (' + @Dep_Ver + ')' + CHAR(13) + CHAR(10)
							Set	@Dep_Fail	= 1
						END

					IF	@Dep_VC = '='	-- EQUAL TO
						BEGIN
							IF @ECC = 1 PRINT '   -- DEP FAIL:'+@Dep_Name+' OBJECT VERSION (' +COALESCE(@Dep_Ver_Chk,'')+ ') IS NOT EQUAL TO (' + @Dep_Ver + ')'
							SET	@Status = @Status + 'DEP FAIL:'+@Dep_Name+' OBJECT VERSION (' +COALESCE(@Dep_Ver_Chk,'')+ ') IS NOT EQUAL TO (' + @Dep_Ver + ')' + CHAR(13) + CHAR(10)
							Set	@Dep_Fail	= 1
						END
						
					GOTO DEP_DONE
					
					DEP_EQ:
					IF @ECC = 1 PRINT '   -- DEP_EQ ' + @Dep_Ver_Chk
					
					IF	@Dep_VC = '>'	-- GREATER THAN
						BEGIN
							IF @ECC = 1 PRINT '   -- DEP FAIL:'+@Dep_Name+' OBJECT VERSION (' +COALESCE(@Dep_Ver_Chk,'')+ ') IS NOT GREATER THAN (' + @Dep_Ver + ')'
							SET	@Status = @Status + 'DEP FAIL:'+@Dep_Name+' OBJECT VERSION (' +COALESCE(@Dep_Ver_Chk,'')+ ') IS NOT GREATER THAN (' + @Dep_Ver + ')' + CHAR(13) + CHAR(10)
							Set	@Dep_Fail	= 1
						END
					
					IF	@Dep_VC = '<'	-- GREATER THAN
						BEGIN
							IF @ECC = 1 PRINT '   -- DEP FAIL:'+@Dep_Name+' OBJECT VERSION (' +COALESCE(@Dep_Ver_Chk,'')+ ') IS NOT LESS THAN (' + @Dep_Ver + ')'
							SET	@Status = @Status + 'DEP FAIL:'+@Dep_Name+' OBJECT VERSION (' +COALESCE(@Dep_Ver_Chk,'')+ ') IS NOT LESS THAN (' + @Dep_Ver + ')' + CHAR(13) + CHAR(10)
							Set	@Dep_Fail	= 1
						END					
					
					GOTO DEP_DONE
					
					DEP_LT:
					IF @ECC = 1 PRINT '   -- DEP_LT ' + @Dep_Ver_Chk
					
					IF	@Dep_VC = '>'	-- GREATER THAN
						BEGIN
							IF @ECC = 1 PRINT '   -- DEP FAIL:'+@Dep_Name+' OBJECT VERSION (' +COALESCE(@Dep_Ver_Chk,'')+ ') IS NOT GREATER THAN (' + @Dep_Ver + ')'
							SET	@Status = @Status + 'DEP FAIL:'+@Dep_Name+' OBJECT VERSION (' +COALESCE(@Dep_Ver_Chk,'')+ ') IS NOT GREATER THAN (' + @Dep_Ver + ')' + CHAR(13) + CHAR(10)
							Set	@Dep_Fail	= 1
						END
					
					IF	@Dep_VC = '>='	-- GREATER THAN
						BEGIN
							IF @ECC = 1 PRINT '   -- DEP FAIL:'+@Dep_Name+' OBJECT VERSION (' +COALESCE(@Dep_Ver_Chk,'')+ ') IS NOT GREATER THAN OR EQUAL TO (' + @Dep_Ver + ')'
							SET	@Status = @Status + 'DEP FAIL:'+@Dep_Name+' OBJECT VERSION (' +COALESCE(@Dep_Ver_Chk,'')+ ') IS NOT GREATER THAN OR EQUAL TO (' + @Dep_Ver + ')' + CHAR(13) + CHAR(10)
							Set	@Dep_Fail	= 1
						END
					
					IF	@Dep_VC = '='	-- EQUAL TO
						BEGIN
							IF @ECC = 1 PRINT '   -- DEP FAIL:'+@Dep_Name+' OBJECT VERSION (' +COALESCE(@Dep_Ver_Chk,'')+ ') IS NOT EQUAL TO (' + @Dep_Ver + ')'
							SET	@Status = @Status + 'DEP FAIL:'+@Dep_Name+' OBJECT VERSION (' +COALESCE(@Dep_Ver_Chk,'')+ ') IS NOT EQUAL TO (' + @Dep_Ver + ')' + CHAR(13) + CHAR(10)
							Set	@Dep_Fail	= 1
						END					
				
					DEP_DONE:
			
				END
				FETCH NEXT FROM Deps_Cursor INTO @Dep_Name,@Dep_Sch,@Dep_Type,@Dep_VC,@Dep_Ver
			END
			CLOSE Deps_Cursor
			DEALLOCATE Deps_Cursor

			IF @Dep_Fail = 0
			BEGIN
				 IF @ECC = 1 PRINT '   -- Dependencies Passed'
			END
			ELSE
			BEGIN
				ROLLBACK
				GOTO TriggerLogging
			END
			
		END
		
		---------------------------------------------------------------
		---------------------------------------------------------------
	----------		PROCESS SECTIONS BASED ON EVENT TYPE
		---------------------------------------------------------------
		---------------------------------------------------------------
		BEGIN -- EVENT TYPE PROCESSING
			--------------------------------------------
			--------------------------------------------
			--	DROP OBJECTS SECTION
			--------------------------------------------
			--------------------------------------------
			IF @EventType LIKE 'DROP%' 
			BEGIN -- DROP OBJECT LOGIC
				IF @ECC = 1 PRINT '  -- No Drop Checks'
						
			END


			--------------------------------------------
			--------------------------------------------
			--	CREATE OBJECTS SECTION
			--------------------------------------------
			--------------------------------------------
			IF @EventType LIKE 'CREATE%' 
			BEGIN -- CREATE OBJECT LOGIC
				IF @ECC = 1 PRINT '   -- No Create Checks'
						
			END
			
			--------------------------------------------
			--------------------------------------------
			--	ALTER OBJECTS SECTION
			--------------------------------------------
			--------------------------------------------
			IF @EventType LIKE 'ALTER%' 
			BEGIN -- ALTER OBJECT LOGIC
				BEGIN -- VERSION CHECKS
					-- SKIP OBJECTS THAT DO NOT ALLOW EXTENDED PROPERTIES
					IF @ObjectType IN ('EXTENDED_PROPERTY','TRIGGER')
					  GOTO SkipVersionChecks
					---------------------------------------------------------------
					---------------------------------------------------------------
					-- BEGIN VERSION CHECKS
					---------------------------------------------------------------
					---------------------------------------------------------------
					If	@CurrentVersion IS NULL
					BEGIN
						IF @ECC = 1 PRINT '  -- Current Object has no Version'
						GOTO CurrentOlder
					END

					IF @ECC = 1 PRINT '  -- Current Object Version (' + @CurrentVersion + ')'

					IF	PARSENAME(@CurrentVersion, 3) < PARSENAME(COALESCE(@CB_Version,@DBVersion), 3)		GOTO CurrentOlder
					ELSE IF PARSENAME(@CurrentVersion, 3) = PARSENAME(COALESCE(@CB_Version,@DBVersion), 3)
					  AND	PARSENAME(@CurrentVersion, 2) < PARSENAME(COALESCE(@CB_Version,@DBVersion), 2)	GOTO CurrentOlder
					ELSE IF	PARSENAME(@CurrentVersion, 3) = PARSENAME(COALESCE(@CB_Version,@DBVersion), 3)
					  AND	PARSENAME(@CurrentVersion, 2) = PARSENAME(COALESCE(@CB_Version,@DBVersion), 2)	
					  AND	PARSENAME(@CurrentVersion, 1) < PARSENAME(COALESCE(@CB_Version,@DBVersion), 1)	GOTO CurrentOlder
					ELSE IF	PARSENAME(@CurrentVersion, 3) = PARSENAME(COALESCE(@CB_Version,@DBVersion), 3)
					  AND	PARSENAME(@CurrentVersion, 2) = PARSENAME(COALESCE(@CB_Version,@DBVersion), 2)	
					  AND	PARSENAME(@CurrentVersion, 1) = PARSENAME(COALESCE(@CB_Version,@DBVersion), 1)	GOTO CurrentSame

					CurrentNewer:
						---------------------------------------------------------------
						---------------------------------------------------------------
						-- CURRENT OBJECT IS NEWER THAN THE ONE BEING DEPLOYED
						---------------------------------------------------------------
						---------------------------------------------------------------
						IF @DBAllowRollBack = 1
						BEGIN
							IF @ECC = 1 PRINT '   -- Current Object is a Newer Version.  *** ROLLBACK ALLOWED ***'
							SET	@Status = @Status + 'Current Object is a Newer Version.  *** ROLLBACK ALLOWED ***' + CHAR(13) + CHAR(10)
							GOTO PassedVersionTests
						END
						ELSE
						BEGIN
							IF @ECC = 1 PRINT '   -- Current Object is a Newer Version.  *** Object NOT Deployed ***'
							SET	@Status = @Status + 'Current Object is a Newer Version.  *** Object NOT Deployed ***' + CHAR(13) + CHAR(10)
							ROLLBACK
							GOTO TriggerLogging
						END
						
					CurrentSame:
						---------------------------------------------------------------
						---------------------------------------------------------------
						-- CURRENT OBJECT IS THE SAME AS THE ONE BEING DEPLOYED
						---------------------------------------------------------------
						---------------------------------------------------------------
						IF @DBAllowRollBack = 1
						BEGIN
							IF @ECC = 1 PRINT '   -- Current Object is the Same Version.  *** REAPLY ALLOWED ***'
							SET	@Status = @Status + 'Current Object is a Newer Version.  *** ROLLBACK ALLOWED ***' + CHAR(13) + CHAR(10)
							GOTO PassedVersionTests
						END
						ELSE
						BEGIN
							IF @ECC = 1 PRINT '   -- Current Object is the Same Version.  *** Object NOT Deployed ***'
							SET	@Status = @Status + 'Current Object is a Newer Version.  *** Object NOT Deployed ***' + CHAR(13) + CHAR(10)
							ROLLBACK
							GOTO TriggerLogging
						END
						
					CurrentOlder:
						---------------------------------------------------------------
						---------------------------------------------------------------
						-- CURRENT OBJECT IS OLDER THAN THE ONE BEING DEPLOYED
						---------------------------------------------------------------
						---------------------------------------------------------------
						IF @ECC = 1 PRINT '   -- Current Object is an Older Version. *** Replacing Object ***'

					PassedVersionTests:
						---------------------------------------------------------------
						---------------------------------------------------------------
						-- DONE WITH ALL VERSION TESTS
						---------------------------------------------------------------
						---------------------------------------------------------------
					SkipVersionChecks:
				END
			END		
		
		END
		
		---------------------------------------------------------------
		---------------------------------------------------------------
	----------		PROCESS PERMISSIONS IF INCLUDED
		---------------------------------------------------------------
		---------------------------------------------------------------
		IF EXISTS (SELECT * FROM @Permissions WHERE COALESCE([Type],'')!='')
		BEGIN -- PROCESS PERMISSIONS
			---------------------------------------------------------------
			---------------------------------------------------------------
		----------			PROCESS PERMISSIONS
			---------------------------------------------------------------
			---------------------------------------------------------------		
			IF @ECC = 1 PRINT '   -- NO PERMISSIONS CODE YET'
			

		END
		---------------------------------------------------------------
		---------------------------------------------------------------
	----------		SET OBJECT EXTENDED PROPERTIES
		---------------------------------------------------------------
		---------------------------------------------------------------
		IF @ObjectType IN ('AGGREGATE', 'DEFAULT', 'FUNCTION', 'LOGICAL FILE NAME', 'PROCEDURE', 'QUEUE', 'RULE', 'SYNONYM', 'TABLE', 'TABLE_TYPE', 'TYPE', 'VIEW', 'XML SCHEMA COLLECTION')
		AND @EventType NOT LIKE 'DROP%'
		BEGIN -- SET EXTENDED PROPERTIES
			---------------------------------------------------------------
			---------------------------------------------------------------
		----------		SET EXTENDED PROPERTIES ON DDL OBJECT
			---------------------------------------------------------------
			---------------------------------------------------------------	
			-- VERSION
			-----------------------------
			SELECT	@ExtProp = 'Version', @ExtProp_val = COALESCE(@CB_Version,@DBVersion)
			IF NOT EXISTS (SELECT Value FROM sys.fn_listextendedproperty(@ExtProp,N'SCHEMA',@SchemaName, @ObjectType, @ObjectName, default, default))
		    BEGIN
				IF @ECC = 1 PRINT '   -- Creating "'+@ExtProp+'" Extended Property'
				EXEC sys.sp_addextendedproperty @name=@ExtProp,@value=@ExtProp_val,@level0type=N'SCHEMA',@level0name=@SchemaName,@level1type=@ObjectType,@level1name=@ObjectName
		    END
			ELSE
			BEGIN
				IF @ECC = 1 PRINT '   -- Updating "'+@ExtProp+'" Extended Property'
				EXEC sys.sp_updateextendedproperty @name=@ExtProp,@value=@ExtProp_val,@level0type=N'SCHEMA',@level0name=@SchemaName,@level1type=@ObjectType,@level1name=@ObjectName
			END
			
			-- Build Application
			-----------------------------
			SELECT	@ExtProp = 'BuildApplication',@ExtProp_val = COALESCE(@CB_BldApp,@DBBldApp)
			IF NOT EXISTS (SELECT Value FROM sys.fn_listextendedproperty(@ExtProp,N'SCHEMA',@SchemaName, @ObjectType, @ObjectName, default, default))
		    BEGIN
				IF @ECC = 1 PRINT '   -- Creating "'+@ExtProp+'" Extended Property'
				EXEC sys.sp_addextendedproperty @name=@ExtProp,@value=@ExtProp_val,@level0type=N'SCHEMA',@level0name=@SchemaName,@level1type=@ObjectType,@level1name=@ObjectName
		    END
			ELSE
			BEGIN
				IF @ECC = 1 PRINT '   -- Updating "'+@ExtProp+'" Extended Property'
				EXEC sys.sp_updateextendedproperty @name=@ExtProp,@value=@ExtProp_val,@level0type=N'SCHEMA',@level0name=@SchemaName,@level1type=@ObjectType,@level1name=@ObjectName
			END

			-- Build Branch
			-----------------------------
			SELECT	@ExtProp = 'BuildBranch',@ExtProp_val = COALESCE(@CB_BldBrnch,@DBBldBrnch)
			IF NOT EXISTS (SELECT Value FROM sys.fn_listextendedproperty(@ExtProp,N'SCHEMA',@SchemaName, @ObjectType, @ObjectName, default, default))
		    BEGIN
				IF @ECC = 1 PRINT '   -- Creating "'+@ExtProp+'" Extended Property'
				EXEC sys.sp_addextendedproperty @name=@ExtProp,@value=@ExtProp_val,@level0type=N'SCHEMA',@level0name=@SchemaName,@level1type=@ObjectType,@level1name=@ObjectName
		    END
			ELSE
			BEGIN
				IF @ECC = 1 PRINT '   -- Updating "'+@ExtProp+'" Extended Property'
				EXEC sys.sp_updateextendedproperty @name=@ExtProp,@value=@ExtProp_val,@level0type=N'SCHEMA',@level0name=@SchemaName,@level1type=@ObjectType,@level1name=@ObjectName
			END
			
			-- Build Number
			-----------------------------
			SELECT	@ExtProp = 'BuildNumber',@ExtProp_val = COALESCE(@CB_BldNum,@DBBldNum)
			IF NOT EXISTS (SELECT Value FROM sys.fn_listextendedproperty(@ExtProp,N'SCHEMA',@SchemaName, @ObjectType, @ObjectName, default, default))
		    BEGIN
				IF @ECC = 1 PRINT '   -- Creating "'+@ExtProp+'" Extended Property'
				EXEC sys.sp_addextendedproperty @name=@ExtProp,@value=@ExtProp_val,@level0type=N'SCHEMA',@level0name=@SchemaName,@level1type=@ObjectType,@level1name=@ObjectName
		    END
			ELSE
			BEGIN
				IF @ECC = 1 PRINT '   -- Updating "'+@ExtProp+'" Extended Property'
				EXEC sys.sp_updateextendedproperty @name=@ExtProp,@value=@ExtProp_val,@level0type=N'SCHEMA',@level0name=@SchemaName,@level1type=@ObjectType,@level1name=@ObjectName
			END

			-- DEPL File Name
			-----------------------------
			SELECT	@ExtProp = 'DeplFileName',@ExtProp_val = @DEPLFileName
			IF NOT EXISTS (SELECT Value FROM sys.fn_listextendedproperty(@ExtProp,N'SCHEMA',@SchemaName, @ObjectType, @ObjectName, default, default))
		    BEGIN
				IF @ECC = 1 PRINT '   -- Creating "'+@ExtProp+'" Extended Property'
				EXEC sys.sp_addextendedproperty @name=@ExtProp,@value=@ExtProp_val,@level0type=N'SCHEMA',@level0name=@SchemaName,@level1type=@ObjectType,@level1name=@ObjectName
		    END
			ELSE
			BEGIN
				IF @ECC = 1 PRINT '   -- Updating "'+@ExtProp+'" Extended Property'
				EXEC sys.sp_updateextendedproperty @name=@ExtProp,@value=@ExtProp_val,@level0type=N'SCHEMA',@level0name=@SchemaName,@level1type=@ObjectType,@level1name=@ObjectName
			END
		END

		TriggerLogging:

		---------------------------------------------------------------
		---------------------------------------------------------------
	----------	LOG ALL ACTIVITY TO LOCAL TABLE IF IT EXISTS
		---------------------------------------------------------------
		---------------------------------------------------------------
		IF COALESCE(@CB_Version,'')=''
			SET @CB_Version = @DBVersion
		
		IF OBJECT_ID('[dbo].[BuildSchemaChanges]') IS NOT NULL
		BEGIN
			IF @ECC = 1 PRINT	'    -- Logging Activity in LOCAL DB'
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
				,[VC_BuildApp]
				,[VC_BuildBrnch]
				,[VC_BuildNum]
				,[DB_BuildApp]
				,[DB_BuildBrnch]
				,[DB_BuildNum]
				,[DEPLInstanceID]
				,[DEPLFileName]
				,[Status]
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
				,@CB_ModReason
				,@CB_BldApp
				,@CB_BldBrnch
				,@CB_BldNum
				,@DBBldApp
				,@DBBldBrnch
				,@DBBldNum
				,@DEPLInstanceID
				,@DEPLFileName
				,@Status
				)
		END
		ELSE
			IF @ECC = 1 PRINT	'    -- [dbo].[BuildSchemaChanges] does not Exist *** Not Logging Activity in LOCAL DB ***'
			
		---------------------------------------------------------------
		---------------------------------------------------------------
	----------	LOG ALL ACTIVITY TO CENTRAL TABLE IF IT EXISTS
		---------------------------------------------------------------
		---------------------------------------------------------------
		IF OBJECT_ID('[dbaadmin].[dbo].[BuildSchemaChanges]') IS NOT NULL AND @DatabaseName != 'dbaadmin'
		BEGIN
			IF @ECC = 1 PRINT	'    -- Logging Activity in DBAADMIN DB'
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
				,[VC_BuildApp]
				,[VC_BuildBrnch]
				,[VC_BuildNum]
				,[DB_BuildApp]
				,[DB_BuildBrnch]
				,[DB_BuildNum]
				,[DEPLInstanceID]
				,[DEPLFileName]
				,[Status]
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
				,@CB_ModReason
				,@CB_BldApp
				,@CB_BldBrnch
				,@CB_BldNum
				,@DBBldApp
				,@DBBldBrnch
				,@DBBldNum
				,@DEPLInstanceID
				,@DEPLFileName
				,@Status
				)
		END
		ELSE IF @DatabaseName != 'dbaadmin'
			AND @ECC = 1 PRINT '    -- [dbaadmin].[dbo].[BuildSchemaChanges] does not Exist *** Not Logging Activity in DBAADMIN DB ***'
	END		

	TriggerComplete:

END

GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
ENABLE TRIGGER [tr_AuditDDLChange] ON DATABASE
GO
