USE DEPLinfo
GO
--BEGIN TRANSACTION,.
GO
DECLARE @R	INT
EXEC	@R	= [DEPLinfo].[dbo].[dpsp_auto_RunSQLdeployment_ordered_xxx]
					 @DBname				= 'ArtistListing'
					,@ProjectName			= 'Databases'
					,@DB_Copy_BuildCode		= 'ArtistListing_14.8'
					,@build_path			= '\\GMSSQLTEST02\GMSSQLTEST02_builds\'
					,@BuildType				= 0
					,@ProcessType			= 'normal'

PRINT '-------'
PRINT @R
PRINT '-------'
GO
--ROLLBACK TRANSACTION
GO






--EXEC [dbo].[dbasp_UnlockAndDelete] 'sqlcmd',0,0,1
