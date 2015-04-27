DECLARE	@OverrideXML		XML		
	,@syntax_out		VarChar(max)	

	 
EXEC [dbaadmin].[dbo].[dbasp_format_BackupRestore] 
		@DBName			= 'Gins_Master' 
		,@Mode			= 'RD' 
		,@Verbose		= 1
		--,@FilePath		= ''
		,@FromServer		= 'FRPSQLRYLB01'
		,@syntax_out		= @syntax_out		OUTPUT
		,@OverrideXML		= @OverrideXML		OUTPUT

EXEC [dbaadmin].[dbo].[dbasp_PrintLarge] @syntax_out


SELECT	@OverrideXML	


EXEC dbaadmin.dbo.dbasp_PrintLarge @syntax_out



