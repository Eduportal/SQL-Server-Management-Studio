USE [DEPLcontrol]
GO
/****** Object:  StoredProcedure [dbo].[dpsp_ManualStart]    Script Date: 10/4/2013 11:02:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[dpsp_ManualStart] (@gears_id int = null
					,@SQLname sysname = null)

/*********************************************************
 **  Stored Procedure dpsp_ManualStart                  
 **  Written by Jim Wilson, Getty Images                
 **  April 09, 2009                                      
 **  
 **  This sproc will assist in manually starting deployment
 **  processes in stage and production.  
 **
 **  Input Parm(s);
 **  @gears_id - is the Gears ID for a specific request
 **
 **  @SQLname - is the SQLname (with instance) you want to start.
 **
 ***************************************************************/
  as
set nocount on

--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	04/09/2009	Jim Wilson		New process.
--	04/29/2009	Jim Wilson		Added ckeck for status = 'manual' to update process.
--	12/14/2009	Jim Wilson		Added Scriptall function.
--	04/11/2011	Steve Ledridge		Modified the Script All section to output grouped by domain
--						and use sqlcmd connect to be able to run all from one server
--	09/15/2011	Jim Wilson		Updated central server name.
--	======================================================================================


/***
Declare @gears_id int
Declare @SQLname sysname

Select @gears_id = 41496
Select @SQLname = 'ScriptAll'
--***/

-----------------  declares  ------------------

DECLARE
	 @miscprint			nvarchar(2000)
	,@cmd				nvarChar(4000)
	,@update_flag			char(1)
	,@scriptall_flag		char(1)
	,@error_count			int

/*********************************************************************
 *                Initialization
 ********************************************************************/
Select @error_count = 0
Select @update_flag = 'n'
Select @scriptall_flag = 'n'

If @SQLname = 'ScriptAll'
   begin
	Select @scriptall_flag = 'y'
	Print  '----------------------  Print the headers  ----------------------'
	Print  ':r "\\SEAPSQLDBA01\DBA_Docs\SQLCMD Scripts\SQLCMD_Header.sql"'
	Print  ''
	Print  '--COMMENT OUT THE PREVIOUS LINE AND UNCOMMENT & EDIT THE FOLLOWING LINE IF SQLCMD_UserSettings.sql IS NOT PRESENT'
	Print  ''
	Print  '--:setvar SQLCMDUSER DBAxxxxx'
	Print  '--:setvar SQLCMDPASSWORD xxxxxxx'	
	PRINT	''
	PRINT	''
   end 

Print  '/*******************************************************************'
Select @miscprint = '   SQL Automated Deployment Requests - Server: ' + @@servername
Print  @miscprint
Print  ' '
Select @miscprint = '-- Manual Start Process '
Print  @miscprint
Print  '*******************************************************************/'
Print  ' '


--  Verify input parms

If @gears_id is null
   begin
	Select @miscprint = 'Error: No Gears ID specified.' 
	Print  @miscprint
	Print ''

	exec dbo.dpsp_Status @report_only = 'y'

	goto label99
   end

If @SQLname is null
   begin
	Select @miscprint = 'Error: No @SQLname specified.' 
	Print  @miscprint
	Print ''

	exec dbo.dpsp_Status @gears_id = @gears_id, @report_only = 'y'

	goto label99
   end
   

  

If not exists (select 1 from dbo.request_detail where gears_id = @gears_id and SQLname = @SQLname) and @scriptall_flag <> 'y' 
   begin
	Select @miscprint = 'Error: @SQLname specified for this request (' + @SQLname + ') does not exist in this gears_id (' + convert(nvarchar(10), @gears_id) + ').' 
	Print  @miscprint
	Print ''

	exec dbo.dpsp_Status @gears_id = @gears_id, @report_only = 'y'

	goto label99
   end

If not exists (select 1 from dbo.request_detail where gears_id = @gears_id and SQLname = @SQLname and status = 'manual') and @scriptall_flag <> 'y' 
   begin
	Select @miscprint = 'Error: Status for this gears_id/SQLname is not set to ''manual''.  No action taken.' 
	Print  @miscprint
	Print ''

	exec dbo.dpsp_Status @gears_id = @gears_id, @report_only = 'y'

	goto label99
   end


	

/****************************************************************
 *                MainLine
 ***************************************************************/

--  "Script all" process
If @scriptall_flag = 'y'
   begin

	Select	@miscprint = '--  Info: @SQLname specified keyword "ScriptAll".' 
	Print	@miscprint
	
	Select	@miscprint = ':CONNECT SEAPSQLDBA01'
	Print	@miscprint
	Select	@miscprint = '--AMER'
	Print	@miscprint
	Print	''
	SET	@cmd = ''
	select	@cmd	= @cmd 
					+ '--exec DEPLcontrol.dbo.dpsp_ManualStart @gears_id = '
					+ CAST(@gears_id AS VarChar(20))
					+ ', @SQLname = '''
					+ d.SQLname
					+ ''';'
					+ CHAR(13) + CHAR(10)
					+ 'GO'
					+ CHAR(13) + CHAR(10)+ CHAR(13) + CHAR(10)
	FROM	(
			SELECT	DISTINCT
					SQLname 				
			From	dbo.Request_detail d
			WHERE	gears_id = @gears_id
				and	status = 'manual'
				and Domain = 'AMER'
			) d
	PRINT (@CMD)

	Select	@miscprint = ':CONNECT FRESDBASQL01,1433 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)'
	Print	@miscprint
	Select	@miscprint = '--STAGE'
	Print	@miscprint
	Print	''
	SET	@cmd = ''
	select	@cmd	= @cmd 
					+ '--exec DEPLcontrol.dbo.dpsp_ManualStart @gears_id = '
					+ CAST(@gears_id AS VarChar(20))
					+ ', @SQLname = '''
					+ d.SQLname
					+ ''';'
					+ CHAR(13) + CHAR(10)
					+ 'GO'
					+ CHAR(13) + CHAR(10)+ CHAR(13) + CHAR(10)
	FROM	(
			SELECT	DISTINCT
					SQLname 				
			From	dbo.Request_detail d
			WHERE	gears_id = @gears_id
				and	status = 'manual'
				and Domain = 'STAGE'
			) d
	PRINT (@CMD)
	
	Select	@miscprint = ':CONNECT SEAEXSQLMAIL,1433 -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)'
	Print	@miscprint
	Select	@miscprint = '--PRODUCTION'
	Print	@miscprint
	Print	''
	SET	@cmd = ''
	select	@cmd	= @cmd 
					+ '--exec DEPLcontrol.dbo.dpsp_ManualStart @gears_id = '
					+ CAST(@gears_id AS VarChar(20))
					+ ', @SQLname = '''
					+ d.SQLname
					+ ''';'
					+ CHAR(13) + CHAR(10)
					+ 'GO'
					+ CHAR(13) + CHAR(10)+ CHAR(13) + CHAR(10)
	FROM	(
			SELECT	DISTINCT
					SQLname 				
			From	dbo.Request_detail d
			WHERE	gears_id = @gears_id
				and	status = 'manual'
				and Domain = 'PRODUCTION'
			) d
	PRINT (@CMD)

	Set @update_flag = 'y'	

	goto label99
   end  

 

--  Manual start for a specific instance
update dbo.Request_detail set status = 'pending' where Gears_id = @gears_id and SQLname = @SQLname and status = 'manual'
Select @update_flag = 'y'

exec dbo.dpsp_Status @gears_id = @gears_id, @report_only = 'y'


-----------------  Finalizations  ------------------

label99:

If @update_flag = 'n'
   begin
	Print  ' '
	Print  ' '
	Select @miscprint = '-- Here is a sample execute command for this sproc:'
	Print  @miscprint
	Print  ' '
	Select @miscprint = '-- To Start a single Instance:'
	Print  @miscprint
	Print  ' '
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_ManualStart @gears_id = 12345, @SQLname = ''servername\a'''
	Print  @miscprint
	Print  'go'
	Print  ' '
	Print  ' '
	Select @miscprint = '-- To script the code for all Instances:'
	Print  @miscprint
	Print  ' '
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_ManualStart @gears_id = 12345, @SQLname = ''ScriptAll'''
	Print  @miscprint
	Print  'go'
	Print  ' '		
   end


GO
EXEC sys.sp_addextendedproperty @name=N'BuildApplication', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'dpsp_ManualStart'
GO
EXEC sys.sp_addextendedproperty @name=N'BuildBranch', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'dpsp_ManualStart'
GO
EXEC sys.sp_addextendedproperty @name=N'BuildNumber', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'dpsp_ManualStart'
GO
EXEC sys.sp_addextendedproperty @name=N'DeplFileName', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'dpsp_ManualStart'
GO
EXEC sys.sp_addextendedproperty @name=N'Version', @value=N'1.0.0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'dpsp_ManualStart'
GO
