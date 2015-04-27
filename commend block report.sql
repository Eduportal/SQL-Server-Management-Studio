
DECLARE		@DBName			SYSNAME
		,@SchemaName		SYSNAME
		,@ObjectName		SYSNAME
		,@ObjectType		SYSNAME
		,@DDL			VarChar(max)
		,@HeaderXML_DDL		XML
		,@HeaderXML_EXPROP	XML
		,@DDL_HasCB		bit
		,@EXP_HasCB		bit
		,@WorkString		VarChar(max)

DECLARE		@AuditRestults	TABLE
		(
		DBName			SYSNAME		NULL
		,SchemaName		SYSNAME		NULL
		,ObjectName		SYSNAME		NULL
		,ObjectType		SYSNAME		NULL
		,DDL			VarChar(max)	NULL
		,HeaderXML_DDL		XML		NULL
		,HeaderXML_EXPROP	XML		NULL
		,DDL_HasCB		bit		NULL
		,EXP_HasCB		bit		NULL
		,[Version]		sysname		NULL
		,[CreatedBy]		sysname		NULL
		,[CreatedOn]		datetime	NULL
		,[BldNum]		sysname		NULL
		,[BldApp]		sysname		NULL
		,[BldBrnch]		sysname		NULL
		,[Purpose]		varChar(max)	NULL
		,[Description]		varChar(max)	NULL
		)

DECLARE ObjectCursor CURSOR
FOR
-- SELECT QUERY FOR CURSOR
SELECT		ROUTINE_CATALOG	
		,ROUTINE_SCHEMA	
		,ROUTINE_NAME	
		,ROUTINE_TYPE
FROM		[INFORMATION_SCHEMA].[ROUTINES] 

OPEN ObjectCursor;
FETCH ObjectCursor INTO @DBName,@SchemaName,@ObjectName,@ObjectType;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
		SELECT	@DDL			= OBJECT_DEFINITION(OBJECT_ID(@ObjectName))
			,@HeaderXML_DDL		= NULL
			,@HeaderXML_EXPROP	= NULL
			,@DDL_HasCB		= 0
			,@EXP_HasCB		= 0

		WHILE CHARINDEX(' '+CHAR(13)+CHAR(10),@DDL) > 0 OR CHARINDEX(CHAR(9)+CHAR(13)+CHAR(10),@DDL) > 0
			SET @DDL = REPLACE(REPLACE(@DDL,' '+CHAR(13)+CHAR(10),CHAR(13)+CHAR(10)),CHAR(9)+CHAR(13)+CHAR(10),CHAR(13)+CHAR(10))

		IF NULLIF(SUBSTRING	(
				@DDL
				,CHARINDEX('<CommentHeader>',@DDL)
				,CHARINDEX('</CommentHeader>',@DDL)+16-CHARINDEX('<CommentHeader>',@DDL)
				),'') IS NOT NULL
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

				RAISERROR( '  %s.%s.%s -- CommentBlock Retrieved From %s DDL',-1,-1,@DBName,@SchemaName,@ObjectName,@ObjectType) WITH NOWAIT
				SET @DDL_HasCB	= 1
			END
			ELSE
				RAISERROR( '* %s.%s.%s -- CommentBlock Retrieved From %s DDL WAS NOT VALID',-1,-1,@DBName,@SchemaName,@ObjectName,@ObjectType) WITH NOWAIT
		END
		ELSE
			RAISERROR( '* %s.%s.%s -- CommentBlock WAS NOT FOUND in %s DDL',-1,-1,@DBName,@SchemaName,@ObjectName,@ObjectType) WITH NOWAIT

		-- BUILD @WORKSTRING FROM MULTIPLE EXTENDED PROPERTIES
		-- BECAUSE OF 8K EXTENDED PROPERTY LIMIT CommentBlock_1,CommentBlock_2,...
		SET		@WorkString = ''
		SELECT		@WorkString = @WorkString + ISNULL(CAST(Value AS VarChar(8000)),'')
		FROM		sys.extended_properties
		WHERE		major_id = OBJECT_ID(@ObjectName)
			AND	name like 'CommentBlock%'
		ORDER BY	Name

		IF nullif(@WorkString,'') IS NOT NULL
		BEGIN
			IF dbaadmin.dbo.dbaudf_isXML(@WorkString) = 1
			BEGIN
				RAISERROR( '  %s.%s.%s -- CommentBlock Retrieved From %s Extended Property',-1,-1,@DBName,@SchemaName,@ObjectName,@ObjectType) WITH NOWAIT
				SET	@EXP_HasCB	= 1
				SELECT	@HeaderXML_EXPROP = CONVERT(XML,@WorkString,1)
			END
			ELSE
				RAISERROR( '* %s.%s.%s -- CommentBlock Retrieved From %s Extended Property WAS NOT VALID',-1,-1,@DBName,@SchemaName,@ObjectName,@ObjectType) WITH NOWAIT
		END
		ELSE
			RAISERROR( '* %s.%s.%s -- CommentBlock WAS NOT FOUND in %s Extended Property',-1,-1,@DBName,@SchemaName,@ObjectName,@ObjectType) WITH NOWAIT




		if @DDL_HasCB = 1
			INSERT INTO	@AuditRestults
			SELECT		@DBName		
					,@SchemaName	
					,@ObjectName	
					,@ObjectType	
					,@DDL		
					,@HeaderXML_DDL
					,@HeaderXML_EXPROP	
					,@DDL_HasCB	
					,@EXP_HasCB
					,a.b.value('VersionControl[1]/Version[1]','sysname')
					,a.b.value('VersionControl[1]/Created[1]/@By','sysname')
					,a.b.value('VersionControl[1]/Created[1]/@On','datetime')
					,a.b.value('VersionControl[1]/Build[1]/@Number','sysname')
					,a.b.value('VersionControl[1]/Build[1]/@Application','sysname')
					,a.b.value('VersionControl[1]/Build[1]/@Branch','sysname')
					,a.b.value('Purpose[1]','varchar(max)')
					,a.b.value('Description[1]','varchar(max)')
			FROM		@HeaderXML_DDL.nodes('CommentHeader') a(b)
		else 
		if @EXP_HasCB = 1
			INSERT INTO	@AuditRestults
			SELECT		@DBName		
					,@SchemaName	
					,@ObjectName	
					,@ObjectType	
					,@DDL		
					,@HeaderXML_DDL
					,@HeaderXML_EXPROP	
					,@DDL_HasCB	
					,@EXP_HasCB
					,a.b.value('VersionControl[1]/Version[1]','sysname')
					,a.b.value('VersionControl[1]/Created[1]/@By','sysname')
					,a.b.value('VersionControl[1]/Created[1]/@On','datetime')
					,a.b.value('VersionControl[1]/Build[1]/@Number','sysname')
					,a.b.value('VersionControl[1]/Build[1]/@Application','sysname')
					,a.b.value('VersionControl[1]/Build[1]/@Branch','sysname')
					,a.b.value('Purpose[1]','varchar(max)')
					,a.b.value('Description[1]','varchar(max)')
			FROM		@HeaderXML_EXPROP.nodes('CommentHeader') a(b)

		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM ObjectCursor INTO @DBName,@SchemaName,@ObjectName,@ObjectType;
END
CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;

SELECT * FROM @AuditRestults