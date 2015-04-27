

DECLARE  @syntax_out VarChar(max)


EXEC [dbaadmin].[dbo].[dbasp_format_BackupRestore] 
			@DBName			= 'Getty_master' 
			,@Mode			= 'RD' 
			,@Verbose		= 0
			,@FullReset             = 0
			,@LeaveNORECOVERY	= 1 
			,@FilePath		= '\\SEAPSQLRYL0A\SEAPSQLRYL0A_Backup\'
			,@StandBy		= 1
			,@syntax_out		= @syntax_out		OUTPUT
			,@NoFullRestores	= 1
			,@NoDifRestores		= 1
			,@UseTryCatch		= 1

exec dbaadmin.dbo.dbasp_PrintLarge @syntax_out

