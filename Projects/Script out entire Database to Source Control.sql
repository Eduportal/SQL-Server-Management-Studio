
DECLARE		@CMD			VarChar(MAX)
DECLARE		@DBName			SYSNAME
DECLARE		@SavePathRoot	VarChar(max)
DECLARE		@DontReplace	VarChar(MAX)

SELECT		@DBName			= 'dbaadmin'
			,@DontReplace	= 'dbasp_code_updates'
			,@SavePathRoot	= '\\SEAPSQLDBA01\DBA_Docs\SourceCode\'
			,@SavePathRoot	= @SavePathRoot + @DBName +'\'+ @DBName +'_xxxxy\'
			,@CMD			=
'USE [$DBNAME$];
SELECT		dbaadmin.dbo.dbaudf_ScriptObject	(DB_Name()+''.''+object_schema_name(T1.id)+''.''+T1.Name
							,CASE T1.Type WHEN ''U'' THEN 1 ELSE 0 END	-- Drop
							,CASE T1.Type WHEN ''U'' THEN 1 ELSE 0 END	-- Creeate
							,CASE T1.Type WHEN ''U'' THEN 0 ELSE 1 END	-- Alter
							,0						-- Data
							,''$SavePathRoot$''
							+CASE T1.Type
								WHEN ''AF'' THEN     ''Programability\CLR\Aggregate_Function\''
								WHEN ''C''  THEN     ''User_Table\CHECK_Constraint\''
								WHEN ''D''  THEN     ''User_Table\Default_or_DEFAULT_Constraint\''
								WHEN ''F''  THEN     ''User_Table\FOREIGN_KEY_Constraint\''
								WHEN ''L''  THEN     ''Log\''
								WHEN ''FN'' THEN     ''Programability\Scalar_Function\''
								WHEN ''FS'' THEN     ''Programability\CLR\Scalar_Function\''
								WHEN ''FT'' THEN     ''Programability\CLR\Table_Valued_Function\''
								WHEN ''IF'' THEN     ''Programability\In_Lined_Table_Function\''
								WHEN ''IT'' THEN     ''Internal_Table\''
								WHEN ''P''  THEN     ''Programability\Stored_Procedure\''
								WHEN ''PC'' THEN     ''Programability\CLR\Stored_Procedure\''
								WHEN ''PK'' THEN     ''User_Table\PRIMARY_KEY_Constraint\''
								WHEN ''RF'' THEN     ''Programability\Replication_filter_stored_procedure\''
								WHEN ''S''  THEN     ''System_Table\''
								WHEN ''SN'' THEN     ''Synonym\''
								WHEN ''SQ'' THEN     ''Service_Queue\''
								WHEN ''TA'' THEN     ''Programability\CLR\DML_Trigger\''
								WHEN ''TF'' THEN     ''Programability\Table_Function\''
								WHEN ''TR'' THEN     ''Programability\SQL_DML_Trigger\''
								WHEN ''TT'' THEN     ''Table_type\''
								WHEN ''U''  THEN     ''User_Table\''
								WHEN ''UQ'' THEN     ''User_Table\UNIQUE_Constraint\''
								WHEN ''V''  THEN     ''View\''
								WHEN ''X''  THEN     ''Programability\Extended_Stored_Procedure\''
								WHEN ''K''  THEN     ''User_Table\PRIMARY_KEY_UNIQUE_Constraint\''
								ELSE T1.Type+''\'' END
							+T1.name+''.sql''
							,0,1
							,CASE WHEN T1.Name IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(''$DontReplace$'','','')) THEN ''IF OBJECT_ID(''''''+object_schema_name(T1.id)+''.''+T1.Name+'''''') IS NOT NULL SET NOEXEC ON''+CHAR(13)+CHAR(10) ELSE '''' END
							,CASE WHEN T1.Name IN (SELECT SplitValue FROM dbaadmin.dbo.dbaudf_StringToTable(''$DontReplace$'','','')) THEN ''SET NOEXEC OFF''+CHAR(13)+CHAR(10) ELSE '''' END
							)
							
FROM		sysobjects T1
WHERE		1=1
	AND	T1.Type NOT IN (''IT'',''S'') 
	AND	T1.Name NOT IN (''sp_renamediagram'',''sp_upgraddiagrams'',''sp_alterdiagram'',''fn_diagramobjects'',''sp_creatediagram'',''sp_dropdiagram'',''sp_helpdiagramdefinition'',''sp_helpdiagrams'')
	AND	T1.Name NOT LIKE ''vw_AllDB_%''

-- SCRIPT ALL DATA
SELECT		dbaadmin.dbo.dbaudf_ScriptObject	(DB_Name()+''.''+object_schema_name(T1.id)+''.''+T1.Name
							,1	-- Drop
							,1	-- Creeate
							,0	-- Alter
							,1	-- Data
							,''$SavePathRoot$''
							+''Data\''
							+T1.name+''.sql''
							,0,1,'''','''')
FROM		sysobjects T1
WHERE		1=1
	AND	T1.Type IN (''U'') -- TABLES'

SET @CMD = REPLACE(REPLACE(REPLACE(@CMD,'$DBNAME$',@DBName),'$SavePathRoot$',@SavePathRoot),'$DontReplace$',@DontReplace)

EXEC(@CMD)



DECLARE		@RootPath		VarChar(max)
		,@FolderOrder		VarChar(max)
		,@DeployScriptFile	VarChar(max)
		,@DeployScriptType	VarChar(25)	-- CONTENT or POINTERS
		,@CMD			VarChar(8000)
		,@Document		VarChar(max)
		,@Line			VarChar(max)
		,@LineSeperator		VarChar(max)
		,@LineText		VarChar(max)
		,@LineWidth		INT
		,@CRLF			CHAR(2)
		,@S_DirectoryName	VarChar(max)
		,@S_FileName		VarChar(max)
		,@S_Folder		VarChar(max)
		,@S_FullPathName	VarChar(max)
		,@PreviousFolder	VarChar(MAX)


		
SELECT		@RootPath		= '\\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\DBAADMIN_xxxx\'
		,@FolderOrder		= 'Table_type,User_Table,User_Table\UNIQUE_Constraint,User_Table\CHECK_Constraint,User_Table\Default_or_DEFAULT_Constraint,User_Table\PRIMARY_KEY_UNIQUE_Constraint,User_Table\PRIMARY_KEY_Constraint,User_Table\FOREIGN_KEY_Constraint,View,Programability\CLR\Scalar_Function,Programability\CLR\Table_Valued_Function,Programability\CLR\Aggregate_Function,Programability\CLR\Stored_Procedure,Programability\CLR\DML_Trigger,Programability\Stored_Procedure,Programability\Replication_filter_stored_procedure,Programability\Extended_Stored_Procedure,Programability\Scalar_Function,Programability\Table_Function,Programability\In_Lined_Table_Function,Programability\SQL_DML_Trigger,Log,Internal_Table,System_Table,Synonym,Service_Queue,Data'
		,@DeployScriptFile	= 'DEPLOY.SQL'
		,@Document		= ''
		,@CRLF			= CHAR(13)+CHAR(10)
		,@LineWidth		= 160
		,@DeployScriptType	= 'CONTENT'


-- CREATE DOCUMENT HEADER		
SELECT		@LineSeperator	= '--'+REPLICATE('-',@LineWidth)+@CRLF
		,@Document	= @Document+@LineSeperator+@LineSeperator

		,@LineText	= 'DEPLOYMENT SCRIPT FOR SCRIPTS UNDER ' + @RootPath
		,@Line		= '--'+REPLICATE(' ',((@LineWidth-LEN(@LineText))/2))+@LineText+@CRLF
		,@Document	= @Document+@Line
		
		,@LineText	= 'CREATED ON ' + CAST(GETDATE() AS VarChar(50))
		,@Line		= '--'+REPLICATE(' ',((@LineWidth-LEN(@LineText))/2))+@LineText+@CRLF
		,@Document	= @Document+@Line
		
		,@Document	= @Document+@LineSeperator+@LineSeperator+@CRLF+@CRLF

PRINT @Document;SET @Document='';

DECLARE Script_Cursor CURSOR
FOR
SELECT		D.Directory
		,D.Name
		,D.FullPathName
		,REPLACE(D.Directory,@RootPath,'')
FROM		dbo.dbaudf_DirectoryList2 (@RootPath,'*.sql',1) D
LEFT JOIN	dbo.dbaudf_StringToTable (@FolderOrder,',') O
	ON	REPLACE(D.Directory,@RootPath,'') = O.SplitValue
ORDER BY	isnull(O.OccurenceId,99),D.Name

SET @PreviousFolder = ''

OPEN Script_Cursor
FETCH NEXT FROM Script_Cursor INTO @S_DirectoryName,@S_FileName,@S_FullPathName,@S_Folder	
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		IF @PreviousFolder != @S_Folder
		BEGIN
			SET @PreviousFolder = @S_Folder	
			SET @Document	= @Document
					+ 'PRINT ''  -- DEPLOYING    '+@PreviousFolder+''''+ @CRLF + 'GO' + @CRLF
		END
		
		SELECT @Document = @Document + 'PRINT ''    -- '+@S_FileName+''''+@CRLF 
		
		IF @DeployScriptType		= 'POINTERS'
			SELECT		@Document = @Document + ':r '+@S_FullPathName

		ELSE IF @DeployScriptType	= 'CONTENT'
			SELECT		@Document = @Document + [Line] + @CRLF
			FROM		dbaadmin.dbo.dbaudf_FileAccess_Read(@S_FullPathName)
		ELSE
			SELECT		@Document = @Document + '-- UNKNOWN @DeployScriptType Value.' + @CRLF

		SELECT		@Document = @Document +  @CRLF+ 'GO' + @CRLF
		
		PRINT @Document;SET @Document='';

	END
	FETCH NEXT FROM Script_Cursor INTO @S_DirectoryName,@S_FileName,@S_FullPathName,@S_Folder
END
CLOSE Script_Cursor
DEALLOCATE Script_Cursor

PRINT		@Document












--SELECT		DISTINCT
--		REPLACE(Directory,@RootPath,'')
--FROM		dbo.dbaudf_DirectoryList2 (@RootPath,'*.sql',1)








---- SCRIPT ALL DATA
--SELECT		CASE T1.Name WHEN 'dbasp_code_updates' THEN 'IF OBJECT_ID('''+object_schema_name(T1.id)+'.'+T1.Name+''') IS NOT NULL SET NOEXEC ON'+CHAR(13)+CHAR(10) ELSE '' END

--		+ dbaadmin.dbo.dbaudf_ScriptObject	(DB_Name()+'.'+object_schema_name(T1.id)+'.'+T1.Name
--							,0  -- Drop
--							,0  -- Creeate
--							,1  -- Alter
--							,0  -- Data
--							,'' -- WRITE FILE PATH AND NAME
--							,0  -- APPEND
--							,1) -- FORCE CR/LF AT END OF WRITE

--		+ CASE T1.Name WHEN 'dbasp_code_updates' THEN 'SET NOEXEC OFF'+CHAR(13)+CHAR(10) ELSE '' END
--FROM		sysobjects T1
--WHERE		1=1
--	AND	T1.Type IN ('P') -- SPROCS
--	AND	T1.Name NOT IN ('sp_renamediagram','sp_upgraddiagrams','sp_alterdiagram','fn_diagramobjects','sp_creatediagram','sp_dropdiagram','sp_helpdiagramdefinition','sp_helpdiagrams')












--SELECT distinct type from sysobjects

--D  -- DEFAULT
--IT -- 
--K 
--S 
--SQ

--('U') -- Tables

--('FN','TF','P','V') -- SPROCS,FUNCTIONS,VIEWS

--('AF','FS','FT','PC','TA') -- CLR OBJECTS



--SELECT dbaadmin.dbo.dbaudf_ScriptObject	('dbasp_Base_AutoRestore_fromSQB',0,1,0,0,'',0,0)
SELECT dbaadmin.dbo.dbaudf_ScriptObject	('dbaperf.dbo.build',0,1,0,1,'',0,0,'-- HEADER','--FOOTER')


SELECT Type,* FROM dbaperf.sys.objects WHERE object_id = object_id('build',DB_ID('dbaperf'))

SELECT OBJECT_NAME(object_id('build',DB_ID('dbaperf')),DB_ID('dbaperf'))


SELECT DB_ID('dbaperf')

SELECT OBJECT_ID('dbo.build','dbaperf')


SELECT COALESCE(PARSENAME('dbaperf.dbo.build',3),DB_NAME())

SELECT T2.Name FROM dbaperf.sys.objects T1 JOIN dbaperf.sys.schemas T2 ON T1.schema_id = T2.schema_id WHERE object_id = object_id('dbaperf.dbo.build')

SELECT Type FROM dbaperf.sys.objects WHERE object_id = object_id('dbaperf.dbo.build')