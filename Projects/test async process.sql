DECLARE		@ServerName		SYSNAME
		,@ParallellQuery	VarChar(8000)
		,@NewID			UniqueIdentifier
		,@rc			INT
		,@object		INT
		,@osql_cmd		VarChar(8000)
		,@desc			VarChar(8000)

SELECT		@ServerName		= @@ServerName
		,@ParallellQuery	= 'WAITFOR DELAY ''01:00:00'''
		,@NewID			= NEWID()

PRINT @NewID		
PRINT 'Running Updater'
-- create shell object 
exec @rc = sp_oacreate 'wscript.shell', @object out
set @osql_cmd = 'sqlcmd -E -dmaster -S'+@ServerName+' -Q"'+@ParallellQuery+'" -H'+ CAST(@NewID AS VarChar(50))

Print 'use method'
exec sp_oamethod @object,
			 'run',
			 @desc OUTPUT,
			 @osql_cmd

print 'destroy object'
exec sp_oadestroy @object