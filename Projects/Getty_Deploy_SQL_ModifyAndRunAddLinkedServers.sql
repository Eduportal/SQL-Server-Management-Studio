DECLARE @DynamicCode VarChar(8000)
DECLARE @DynamicCode2 VarChar(MAX)
SELECT	@DynamicCode	= '\\'+REPLACE(@@SERVERNAME,'\'+@@SERVICENAME,'')+'\'+REPLACE(@@SERVERNAME,'\','$')+'_dba_archive\BeforeClone\'+   REPLACE(@@SERVERNAME,'\','(')+CASE WHEN @@SERVICENAME != 'MSSQLSERVER' THEN ')' ELSE '' END+'_SYSaddlinkedservers.gsql'

IF (OBJECT_ID('tempdb..#FileText'))	IS NULL
	CREATE TABLE #FileText (LinNo INT,Line VarChar(max))
	
INSERT INTO #FileText
SELECT * 
FROM  dbaadmin.dbo.dbaudf_FileAccess_Read(@DynamicCode,NULL)

UPDATE	#FileText
	SET	Line = REPLACE([Line],'''xyz''','''gtgdev''')
WHERE	line like '%sp_addlinkedsrvlogin%'
	AND	Line Like '%@rmtuser = ''oneuser''%'

UPDATE	#FileText
	SET	Line = REPLACE([Line],'''xyz''','''Nur3em@iA''')
WHERE	line like '%sp_addlinkedsrvlogin%'
	AND	Line Like '%@rmtuser = ''RP_Link''%'

UPDATE	#FileText
	SET	Line = REPLACE([Line],'''xyz''','''vitriauser''')
WHERE	line like '%sp_addlinkedsrvlogin%'
	AND	Line Like '%@rmtuser = ''vitriauser''%'

UPDATE	#FileText
	SET	Line = REPLACE([Line],'''xyz''','''serviceuser''')
WHERE	line like '%sp_addlinkedsrvlogin%'
	AND	Line Like '%@rmtuser = ''serviceuser''%'

SELECT	@DynamicCode2 = ''
		,@DynamicCode = REPLACE(@DynamicCode,'.gsql','_Updated.gsql') 

SELECT	@DynamicCode2 = @DynamicCode2 + Line + CHAR(13) + CHAR(10)
FROM	#FileText
ORDER BY LinNo

EXECUTE [dbaadmin].[dbo].[dbasp_FileAccess_Write] 
   @String = @DynamicCode2
  ,@Path = @DynamicCode

SELECT	@DynamicCode	= 'sqlcmd -S' + @@SERVERNAME + ' -E -i"'+@DynamicCode+'"'
EXEC xp_CmdShell @DynamicCode

GO
DROP TABLE #FileText
GO






