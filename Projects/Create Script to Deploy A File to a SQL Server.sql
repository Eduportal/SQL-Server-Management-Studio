DECLARE @Script		VarChar(max)
	,@SourceFile	VarChar(max)
	,@DestFile	VarChar(max)
	,@ScriptPath	VarChar(max)
	,@Rslt		INT


SELECT	@ScriptPath	= '\\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\ScriptSQLObject.sql'
	,@SourceFile	= '\\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\ScriptSQLObject.exe'
	,@DestFile	= 'C:\Windows\System32\ScriptSQLObject.exe'
	,@Script	= CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
				+ 'SELECT [dbaadmin].[dbo].[dbaudf_PutFile]('''+@DestFile+''','
				+ CONVERT(VarChar(max),[dbaadmin].[dbo].[dbaudf_GetFile](@SourceFile),1)
				+ ')'
				+ CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)

EXEC	@Rslt = [dbaadmin].[dbo].[dbasp_FileAccess_Write] @Script,@ScriptPath,0,1
IF @Rslt = 0
	RAISERROR('-- %s File Created',-1,-1, @ScriptPath) WITH NOWAIT
ELSE
	RAISERROR('-- %s File NOT Created. Error: %d',-1,-1, @ScriptPath,@Rslt) WITH NOWAIT