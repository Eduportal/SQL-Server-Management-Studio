DECLARE		@XML		XML
			,@XSD		XML
			,@TSQL		VarChar(max)
			
SET			@XML		= (SELECT top 10 * From DBA_DBInfo FOR XML AUTO, ELEMENTS, ROOT('Table'),XMLSCHEMA)

SELECT		TOP 1 
			@XSD		= x.query('.') 
FROM		@XML.nodes('/Table/*') a(x)

SELECT		@XML		= CAST(REPLACE(CAST(@XML AS VarChar(max)),CAST(@XSD AS VarChar(max)),'') AS XML)

SELECT		@XML,@XSD

SET			@TSQL		= 'SELECT		'

--SELECT		@TSQL		= @TSQL
--						+ 'a.x.value(''@'+[name]+''','''+REPLACE(COALESCE([type],PARSENAME([sqlAliasType],1),[base]+'('+value1+COALESCE(','+nullif(value2,'')+')',')')),'','')
--						+ CHAR(13) + CHAR(10) + '			,' 
--FROM		(
			SELECT		a.x.value('@name','sysname') [name]
						,a.x.value('@type','sysname') [type]
						--,a.x.value('*[1]/sqltypes:sqlTypeAlias','sysname') [sqlTypeAlias]
						,a.x.value('*[1]/*[1]/@base','sysname') [base]
						,a.x.value('*[1]/*[1]/*[1]/@value','sysname') [value1]
						,a.x.value('*[1]/*[1]/*[2]/@value','sysname') [value2]
			FROM		@XSD.nodes('/*/*/*/*/*') a(x)
--			) ColumnData
			
--SET			@TSQL		= REPLACE(@TSQL+'||','			,||','FROM		@XML.nodes(''/Table/*'') a(x)')

--PRINT		@TSQL

--EXEC		(@TSQL)			