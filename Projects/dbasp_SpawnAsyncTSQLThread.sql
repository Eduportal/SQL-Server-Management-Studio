USE DBAADMIN
GO

IF OBJECT_ID('dbasp_SpawnAsyncTSQLThread') IS NOT NULL
	DROP PROCEDURE dbo.dbasp_SpawnAsyncTSQLThread
GO

CREATE PROCEDURE	dbo.dbasp_SpawnAsyncTSQLThread
			(
			@TSQL		VarChar(8000)
			,@ThreadID	UniqueIdentifier	= NULL	OUTPUT
			,@Desc		VarChar(8000)		= NULL	OUTPUT
			,@OutputFile	VarChar(8000)		= NULL	OUTPUT
			,@Session_ID	INT			= NULL	OUTPUT
			)
AS
BEGIN

	DECLARE	@rc		INT
		,@object	INT
		,@sqlcmd	VarChar(8000)

	SELECT	@ThreadID	= NEWID()
		,@OutputFile	= CAST(@ThreadID AS VarChar(50))+'.out'
		,@TSQL		= REPLACE(@TSQL,'"','""')
		,@sqlcmd	= 'sqlcmd -E -dmaster -S'+@@ServerName+' -Q"'+@TSQL+'" -o"'+@OutputFile+'" -H'+ CAST(@ThreadID AS VarChar(50))
		
	-- create shell object 
	exec	@rc = sp_oacreate 'wscript.shell', @object out
	-- USE OBJECT
	exec sp_oamethod @object,
			 'run',
			 @Desc OUTPUT,
			 @sqlcmd
	-- DESTROY OBJECT
	exec sp_oadestroy @object

	waitfor delay '00:00:01'

	select	@Session_ID = Session_ID 
	FROM	sys.dm_exec_sessions
	where	host_name LIKE '%'+cast(@ThreadID as VarChar(50))+'%'
	
	SELECT	@OutputFile = dbaadmin.dbo.dbaudf_GetFileProperty(@OutputFile,'File','Path')

	IF @Session_ID IS NULL
	BEGIN
		SELECT  @Desc = @Desc + CHAR(13) + CHAR(10) + [Line] 
		FROM	dbo.dbaudf_FileAccess_Read(@OutputFile,NULL)
		
		EXEC dbo.dbasp_UnlockAndDelete @OutputFile,1,1,0
	END
END
GO	
