USE dbaadmin
GO

SET NOCOUNT ON
IF OBJECT_ID('tempdb..#XMLSCHEMA')	IS NOT NULL	DROP TABLE #XMLSCHEMA
IF OBJECT_ID('tempdb..##Source')	IS NOT NULL	DROP TABLE ##Source

DECLARE			@XML		XML
				,@XSL		XML
				,@TSQL		nVarChar(4000)
				,@TableName	sysname
			
CREATE TABLE	#XMLSCHEMA
				([name]		sysname NULL
				,[use]		sysname NULL
				,[type]		sysname NULL
				,[base]		sysname NULL
				,[value1]	sysname NULL
				,[value2]	sysname NULL)
------------------------------------------------------------------------
------------------------------------------------------------------------
--	GENERATE A XML CHUNK TO PLAY WITH
------------------------------------------------------------------------
------------------------------------------------------------------------
SET			@XML		=  
(SELECT * From dbaadmin.dbo.DBA_DBInfo FOR XML AUTO,XMLSCHEMA,ROOT('Table'))

SELECT @XML
------------------------------------------------------------------------
------------------------------------------------------------------------
--GET ONLY THE TOP XDS PORTION OF THE XML CHUNK
------------------------------------------------------------------------
------------------------------------------------------------------------
SELECT		@XSL		= x.query('.') 
FROM		@XML.nodes('/Table/*[1]') a(x)

-- COULD NOT USE REPLACE FUNCTION AS IT DOES NOT 
-- WORK FOR LARGE TABLES WHERE XML IS LARGER THAN 8000
-- EVEN THOUGH REPLACE DOES ACCEPT VARCHAR(MAX)
-- WOULD LIKE TO FIND XQUERY VERSION OF REPLACE
-- SELECT		@XML		= CAST(REPLACE(CAST(@XML AS VarChar(max)),CAST(@XSL AS VarChar(max)),'') AS XML)

SELECT		@XML =	(
					SELECT		CAST(STUFF	(
											CAST(@XML.query('*[1]/*') AS VarChar(max))
											,1
											,CHARINDEX	(
														'</xsd:schema>'
														,CAST(@XML.query('*[1]/*') AS VarChar(max))
														)+12
											,''
											) AS XML)
					FOR XML RAW ('Table')
					)


------------------------------------------------------------------------
------------------------------------------------------------------------
--	GET THE TABLE NAME
------------------------------------------------------------------------
------------------------------------------------------------------------
SELECT		@TableName	= a.x.value('*[2]/@name','sysname')
FROM		@XSL.nodes('*') a(x)

SELECT		@TableName [TableName]

------------------------------------------------------------------------
------------------------------------------------------------------------
--	POPULATE THE XMLSCHEMA TEMP TABLE
------------------------------------------------------------------------
------------------------------------------------------------------------
INSERT INTO	#XMLSCHEMA
SELECT		a.x.value('@name','sysname') [name]
			,a.x.value('@use','sysname') [use] -- use="required" for PK of Source
			,a.x.value('@type','sysname') [type]
			,a.x.value('*[1]/*[1]/@base','sysname') [base]
			,a.x.value('*[1]/*[1]/*[1]/@value','sysname') [value1]
			,a.x.value('*[1]/*[1]/*[2]/@value','sysname') [value2]
FROM		@XSL.nodes('/*/*/*/*') a(x)

------------------------------------------------------------------------
------------------------------------------------------------------------
--	CREATE THE DYNAMIC SQL TO CREATE THE SOURCE TEMP TABLE FROM THE XSD
------------------------------------------------------------------------
------------------------------------------------------------------------
SET			@TSQL		= 'SELECT		'
SELECT		@TSQL		= @TSQL -- START BUILDING NEXT LINE OF QUERY
						+ 'a.x.value(''@'+[name]+''','''
						+REPLACE(COALESCE([type],[base]+'('+value1+COALESCE(','+nullif(value2,'')+')',')')),'sqltypes:','')+''') ' 
						+ QUOTENAME([name])
						+ CHAR(13) + CHAR(10) + '			,' 
FROM		#XMLSCHEMA ColumnData
			
SET			@TSQL		= REPLACE	(
									@TSQL+'||'			--APPEND DOUBLE PIPE TO END SO I CAN IDENTIFY LAST COMMA 
									,'			,||'	-- REPLACE LINE WITH LAST COMMA WITH NEXT VALUE
									,'INTO ##Source'+CHAR(13) + CHAR(10)+'FROM		@XML.nodes(''/Table/*'') a(x)'
									)

------------------------------------------------------------------------
------------------------------------------------------------------------
--	CREATE THE SOURCE TEMP TABLE FROM THE XSD
------------------------------------------------------------------------
------------------------------------------------------------------------
EXEC		sp_Executesql @TSQL,N'@XML XML',@XML

------------------------------------------------------------------------
------------------------------------------------------------------------
--	SHOW THE SOURCE DATA AFTER INSERTED INTO THE TEMP TABLE
------------------------------------------------------------------------
------------------------------------------------------------------------
SELECT * FROM ##Source

------------------------------------------------------------------------
------------------------------------------------------------------------
--	CREATE THE DYNAMIC SQL TO GENERATE THE MERGE STATEMENT
------------------------------------------------------------------------
------------------------------------------------------------------------

	-- CREATE DESTINATION IF IT DOES NOT ALREADY EXIST




------------------------------------------------------------------------
------------------------------------------------------------------------
--	CREATE THE DYNAMIC SQL TO GENERATE THE MERGE STATEMENT
------------------------------------------------------------------------
------------------------------------------------------------------------

	-- ONLY DO MERGE IF DESTINATION HAS A PRIMARY KEY

IF EXISTS	(
			SELECT		SIK.colid 
			FROM		sysindexkeys SIK 
			JOIN		sysobjects SO 
					ON	SIK.[id] = SO.[id]  
			WHERE		SIK.indid = 1
					AND	SO.ID = OBJECT_ID(@TableName)
			)
BEGIN

		SET			@TSQL		= 'MERGE INTO '+@TableName+' as Target' + CHAR(13) + CHAR(10) 
								+ 'USING ##Source as Source' + CHAR(13) + CHAR(10)
								+ 'ON' + CHAR(9)
				
		SELECT		@TSQL		= @TSQL + 'Target.['+[name]+'] = Source.['+[name]+']'+CHAR(13)+CHAR(10)+'AND'+CHAR(9)
		FROM		syscolumns 
		WHERE		[id] = OBJECT_ID(@TableName)
			AND		colid IN	(
								SELECT		SIK.colid 
								FROM		sysindexkeys SIK 
								JOIN		sysobjects SO 
										ON	SIK.[id] = SO.[id]  
								WHERE		SIK.indid = 1
										AND	SO.ID = OBJECT_ID(@TableName)
								)
				
		SET			@TSQL		= REPLACE(@TSQL+'||','AND'+CHAR(9)+'||',CHAR(13)+CHAR(10)+'when matched then update set'+CHAR(13)+CHAR(10)+'Target.')

		SELECT		@TSQL		= @TSQL + '['+[name]+']=Source.['+[name]+']'+CHAR(13)+CHAR(10)+',Target.'
		FROM		#XMLSCHEMA ColumnData

		SET			@TSQL		= REPLACE(@TSQL+'||',',Target.||',CHAR(13)+CHAR(10)+'when not matched then insert'+CHAR(13)+CHAR(10)+'(')

		SELECT		@TSQL		= @TSQL + '['+[name]+']'+CHAR(13)+CHAR(10)+','
		FROM		#XMLSCHEMA ColumnData

		SET			@TSQL		= REPLACE(@TSQL+'||',CHAR(13)+CHAR(10)+',||',')'+CHAR(13)+CHAR(10)+'values'+CHAR(13)+CHAR(10)+'(Source.')

		SELECT		@TSQL		= @TSQL	+ '['+[name]+']'+CHAR(13)+CHAR(10)+',Source.'
		FROM		#XMLSCHEMA ColumnData

		SET			@TSQL		= REPLACE(@TSQL+'||',CHAR(13)+CHAR(10)+',Source.||',');')


		------------------------------------------------------------------------
		------------------------------------------------------------------------
		--	SHOW THE MERGE STATEMENT
		------------------------------------------------------------------------
		------------------------------------------------------------------------
		PRINT		(@TSQL)
		------------------------------------------------------------------------
		------------------------------------------------------------------------
		--	RUN THE MERGE
		------------------------------------------------------------------------
		------------------------------------------------------------------------
		EXEC		(@TSQL)

END

------------------------------------------------------------------------
------------------------------------------------------------------------
--	CLEAN UP TEMP TABLES
------------------------------------------------------------------------
------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#XMLSCHEMA')	IS NOT NULL	DROP TABLE #XMLSCHEMA
IF OBJECT_ID('tempdb..##Source')	IS NOT NULL	DROP TABLE ##Source

