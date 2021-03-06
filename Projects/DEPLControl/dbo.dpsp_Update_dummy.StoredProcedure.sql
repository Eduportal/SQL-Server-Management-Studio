USE [DEPLcontrol]
GO
/****** Object:  StoredProcedure [dbo].[dpsp_Update_dummy]    Script Date: 10/4/2013 11:02:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
