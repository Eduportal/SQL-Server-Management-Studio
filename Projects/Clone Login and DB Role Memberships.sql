IF OBJECT_ID('tempdb..#perms') IS NOT NULL	
	DROP TABLE #perms
GO
CREATE TABLE	#perms ([ln] [INT] IDENTITY(1,1), [Line] VarChar(max))
GO
DECLARE		@OldLogin		SYSNAME
		,@NewLogin		SYSNAME
		,@CMD			nVarChar(4000)
		,@Output		VarChar(max)
		,@CRLF			CHAR(2)

SELECT		@OldLogin		= 'AMER\acash'
		,@NewLogin		= 'AMER\pthangsombat'
		,@CRLF			= CHAR(13)+CHAR(10)




SET	@Output =  'USE [master]'+@CRLF+'GO'+@CRLF+'CREATE LOGIN ['+@NewLogin+'] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]'+@CRLF+'GO'

SET @CMD =
'USE [?];
DECLARE @CMD VarChar(8000)

IF EXISTS (SELECT * from sys.database_principals where Type = ''U'' and name = '''+@OldLogin+''')
BEGIN

	SELECT		@CMD = ''USE [?];''+CHAR(13)+CHAR(10)+''CREATE USER ['+@NewLogin+'] for login ['+@NewLogin+']''
	from		sys.database_principals
	where		Type = ''U''
		and	name = '''+@OldLogin+'''

	SELECT		@CMD = @CMD+CHAR(13)+CHAR(10)+''EXECUTE sp_AddRoleMember '''''' + roles.name + '''''', '''''+@NewLogin+'''''''+CHAR(13)+CHAR(10)+''GO''
	from		sys.database_principals users
	join		sys.database_role_members link
		on	link.member_principal_id = users.principal_id
	join		sys.database_principals roles
		on	roles.principal_id = link.role_principal_id
	WHERE		users.name = '''+@OldLogin+'''

	INSERT INTO	#perms([Line])
	SELECT		@CMD
END'

   exec sp_MsForEachDB @CMD

   SELECT	@Output = @Output +@CRLF+@CRLF+[Line]
   FROM		#Perms

   PRINT @Output

   SET @Output = REPLACE(@Output,@CRLF+'GO',@CRLF+'--GO')

   --EXEC(@Output)