USE [DEPLcontrol]
GO
DROP PROCEDURE [dbo].[dpsp_Delete_dummy]
GO
CREATE PROCEDURE [dbo].[dpsp_Delete_dummy] (@gears_id int = null)
  as
BEGIN
INSERT INTO dbo.dummyresults (data)
SELECT	'EXEC [DEPLcontrol].[dbo].[dpsp_Delete]'
	+ ' @gears_id = ' +  CAST(@gears_id AS VarChar(20))
END
GO


DROP PROCEDURE [dbo].[dpsp_Cancel_Gears_dummy] 
GO
CREATE PROCEDURE [dbo].[dpsp_Cancel_Gears_dummy] (@gears_id int = null)
  as
BEGIN
INSERT INTO dbo.dummyresults (data)
SELECT	'EXEC [DEPLcontrol].[dbo].[dpsp_Cancel_Gears]'
	+ ' @gears_id = ' +  CAST(@gears_id AS VarChar(20))
END
GO

DROP PROCEDURE [dbo].[dpsp_Update_dummy]
GO
CREATE PROCEDURE [dbo].[dpsp_Update_dummy]
				(@gears_id int = null
				,@detail_id int = null
				,@DBname sysname = null
				,@status sysname = null
				,@start_dt sysname = null
				,@ProcessType sysname = null
				,@SQLname sysname = null
				,@domain sysname = null
				,@BASEfolder sysname = null
				,@update_all_forSQLname char(1) = 'n')
  as
BEGIN
INSERT INTO dbo.dummyresults (data)
SELECT	'EXEC [DEPLcontrol].[dbo].[dpsp_Update]'
	+ ' @gears_id = ' +  CAST(@gears_id AS VarChar(20))
	+ ', @detail_id = ' +  CAST(@detail_id AS VarChar(20))
	+ ', @DBname = ' +  QUOTENAME(@DBname,'''')
	+ ', @status = ' +  QUOTENAME(@status,'''')
	+ ', @start_dt = ' +  QUOTENAME(@start_dt,'''')
	+ ', @ProcessType = ' +  QUOTENAME(@ProcessType,'''')
	+ ', @SQLname = ' +  QUOTENAME(@SQLname,'''')
	+ ', @domain = ' +  QUOTENAME(@domain,'''')
	+ ', @BASEfolder = ' +  QUOTENAME(@BASEfolder,'''')
	+ ', @update_all_forSQLname = ' +  QUOTENAME(@update_all_forSQLname,'''')
END
GO



DROP PROCEDURE [dbo].[dpsp_StartPreReleaseBackups_dummy]
GO
CREATE PROCEDURE [dbo].[dpsp_StartPreReleaseBackups_dummy] (@gears_id int = null)
  as
BEGIN
INSERT INTO dbo.dummyresults (data)
SELECT	'EXEC [DEPLcontrol].[dbo].[dpsp_StartPreReleaseBackups]'
	+ ' @gears_id = ' +  CAST(@gears_id AS VarChar(20))
END
GO
