DECLARE @RC int
DECLARE @Script			VarChar(6000)
DECLARE	@Export_Source		sysname
DECLARE	@Database_Name		sysname
DECLARE	@Schema_Name		sysname
DECLARE	@Table_Name		sysname
DECLARE	@UNCPath		VarChar(6000)
DECLARE	@LocalPath		VarChar(6000)
DECLARE @FileName		VarChar(6000)

SET	@UNCPath		= '\\g1sqla\d$'

--EXEC [dbaadmin].[dbo].[dbasp_get_share_path] 
--	@share_name	= @UNCPath
--	,@phy_path	= @LocalPath OUTPUT

SET	@LocalPath		= @UNCPath --'d:\'
SET	@Database_Name		= COALESCE(@Database_Name,'NULL')
SET	@Schema_Name		= COALESCE(@Schema_Name,'NULL')
SET	@Table_Name		= COALESCE(@Table_Name,'NULL')

--SELECT [dbaadmin].[dbo].[dbasp_base64_encode] ('G1SQLA\A|dmv_IndexBaseLine|NULL|NULL|NULL')
--SELECT [dbaadmin].[dbo].[dbasp_base64_decode] ('RzFTUUxBXEF8ZG12X01pc3NpbmdJbmRleFNuYXBzaG90fE5VTEx8TlVMTHxOVUxM')

SET	@Export_Source		= 'dbaperf.dbo.dmv_IndexBaseLine'
SELECT	@FileName		= REPLACE([dbaadmin].[dbo].[dbasp_base64_encode] (@@SERVERNAME+'|'+REPLACE(@Export_Source,'dbaperf.dbo.','')+'|'+@Database_Name+'|'+@Schema_Name+'|'+@Table_Name)+'.dat','=','$')
SET	@SCRIPT			= 'bcp '+@Export_Source+' out "'+@LocalPath+'\'+@FileName+'" -S G1SQLA\A,1252 -T -N'
Print	@Script
EXEC	xp_cmdshell		@SCRIPT, no_output


EXEC	[dbaadmin].[dbo].[dbasp_File_Transit] 
		@source_name		= @FileName
		,@source_path		= @UNCPath
		,@target_env		= 'amer'
		,@target_server		= 'SEAFRESQLDBA01'
		,@target_share		= 'SEAFRESQLDBA01_dbasql\dba_UpdateFiles'
		,@retry_limit		= 5
  
waitfor delay '00:00:05'  
  
-- DELETE FILE AFTER SENDING
SET	@Script = 'DEL "'+ @UNCPath+'\'+@FileName+'"'
Print	@Script
exec	master..xp_cmdshell @Script, no_output
		
SET	@Export_Source		= 'dbaperf.dbo.dmv_MissingIndexSnapshot'
SELECT	@FileName		= REPLACE([dbaadmin].[dbo].[dbasp_base64_encode] (@@SERVERNAME+'|'+REPLACE(@Export_Source,'dbaperf.dbo.','')+'|'+@Database_Name+'|'+@Schema_Name+'|'+@Table_Name)+'.dat','=','$')
SET	@SCRIPT			= 'bcp '+@Export_Source+' out "'+@LocalPath+'\'+@FileName+'" -S G1SQLA\A,1252 -T -N'
Print	@Script
EXEC	xp_cmdshell		@SCRIPT, no_output

  
EXEC	[dbaadmin].[dbo].[dbasp_File_Transit] 
		@source_name		= @FileName
		,@source_path		= @UNCPath
		,@target_env		= 'amer'
		,@target_server		= 'SEAFRESQLDBA01'
		,@target_share		= 'SEAFRESQLDBA01_dbasql\dba_UpdateFiles'
		,@retry_limit		= 5  

waitfor delay '00:00:05' 

-- DELETE FILE AFTER SENDING
SET	@Script = 'DEL "'+ @UNCPath+'\'+@FileName+'"'
Print	@Script
exec	xp_cmdshell @Script, no_output

