USE [DEPLcontrol]
GO
/****** Object:  StoredProcedure [dbo].[dpsp_help]    Script Date: 10/4/2013 11:02:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[dpsp_help](@deplSPName sysname = null)
/*********************************************************
 **  Stored Procedure dpsp_help                  
 **  Written by David Spriggs, Getty Images                
 **  April 16, 2009                                     
 **  
 **   This stored procedure will provide help documentation
 **   for the following Request Driven Stored Procedures:
 **	
 **    * dpsp_Approve
 **    * dpsp_Cancel_Gears
 **    * dpsp_Delete
 **    * dpsp_ManualStart
 **    * dpsp_Status
 **    * dpsp_Update
 **    * dpsp_Script_PreRelease
 **
 **    * dpsp_ahp_StartDeployment
 **
 ***************************************************************/
  as
set nocount on

--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	04/16/2009	David Spriggs		New process.
--	04/28/2009	Jim Wilson		Changed input parm for approval from @manual tp @runtype.
--	12/14/2009	Steve Ledridge		Added refference to the dpsp_Script_PreRelease sproc.
--	05/12/2011	Jim Wilson		Added refference to the dpsp_ahp_StartDeployment.
--	======================================================================================

-------------------  declares  ------------------
declare @miscprint nvarchar(2000)
declare @specReq char(5)


/**
    declare @deplSPName sysname
    --set @deplSPName = 'dpsp_ahp_StartDeployment'
--**/

/*********************************************************************
 *                Initialization
 ********************************************************************/
 



/****************************************************************
 *                MainLine
 ***************************************************************/

if @deplSPName is null 
    begin    
	goto getall
    end
else if @deplSPName = 'dpsp_Approve' 
    begin
	set @specReq = 'y'
	goto dpsp_Approve
    end
else if @deplSPName = 'dpsp_Cancel_Gears' 
    begin
	set @specReq = 'y'
	goto dpsp_Cancel_Gears
    end
else if @deplSPName = 'dpsp_Delete' 
    begin
	set @specReq = 'y'
	goto dpsp_Delete
    end
else if @deplSPName = 'dpsp_ManualStart' 
    begin
	set @specReq = 'y'
	goto dpsp_ManualStart
    end
else if @deplSPName = 'dpsp_Status' 
    begin
	set @specReq = 'y'
	goto dpsp_Status
    end
else if @deplSPName = 'dpsp_Update' 
    begin
	set @specReq = 'y'
	goto dpsp_Update
    end
else if @deplSPName = 'dpsp_Script_PreRelease' 
    begin
	set @specReq = 'y'
	goto dpsp_Script_PreRelease
    end
else if @deplSPName = 'dpsp_ahp_StartDeployment' 
    begin
	set @specReq = 'y'
	goto dpsp_ahp_StartDeployment
    end


	getall:
	Select @miscprint = '*************** dpsp_help *******************'
	Print  @miscprint
	Select @miscprint = 'This stored procedure will provide help documentation'
	Print  @miscprint
	Select @miscprint = 'for the following Request Driven Stored Procedures:'
	Print  @miscprint
        Select @miscprint = '   * dpsp_Approve'
	Print  @miscprint
	Select @miscprint = '  * dpsp_Cancel_Gears'
	Print  @miscprint
	Select @miscprint = '  * dpsp_Delete'
	Print  @miscprint
	Select @miscprint = '  * dpsp_ManualStart'
	Print  @miscprint
	Select @miscprint = '  * dpsp_Status'
	Print  @miscprint
	Select @miscprint = '  * dpsp_Update'
	Print  @miscprint
	Select @miscprint = '  * dpsp_Script_PreRelease'
	Print  @miscprint
	Select @miscprint = '  * '
	Print  @miscprint
	Select @miscprint = '  * dpsp_ahp_StartDeployment'
	Print  @miscprint
	Select @miscprint = '***********************************************'
	Print  @miscprint
	Print  ' '
	Print  ' '
	Print  ' '


	dpsp_Approve:
	Select @miscprint = '*************** dpsp_Approve *****************'
	Print  @miscprint
	Select @miscprint = ' This stored procedure will mark specific Gears '
	Print  @miscprint
	Select @miscprint = ' requests as approved prior to SQL deployment'
	Print  @miscprint
	Select @miscprint = ' processing.'
	Print  @miscprint
	Select @miscprint = '**********************************************'
	Print  @miscprint
	Select @miscprint = 'Input Parameters:'
	Print  @miscprint
	Select @miscprint = ''+char(9)+'@gears_id - is the Gears ID for a specific request. '
	Print  @miscprint
	Select @miscprint = ''+char(9)+'@auto - suppresses the examples at the end. '
	Print  @miscprint
	Select @miscprint = ''+char(9)+'@runtype - For stage and production (''auto'', ''manual''), this sets the request '
	Print  @miscprint
	Select @miscprint = ''+char(9)+''+char(9)+'  to be run manually by SQLname using the stored procedure'
	Print  @miscprint
	Select @miscprint = ''+char(9)+''+char(9)+'  dpsp_ManualStart.'
	Print  @miscprint
	Print  ' '
	select @miscprint = 'Examples:'
	print  @miscprint 
	Select @miscprint = '--Approve Gears Request for Deployment:'
	Print  @miscprint
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_Approve @gears_id = 12345'
	Print  @miscprint
	Print  ' '
	Select @miscprint = '--Approve the request manually and send it up to the Production' 
	Print  @miscprint
	Select @miscprint = '--or Stage central server and will set all the request_detail rows'
	Print  @miscprint
        Select @miscprint = '--to a status of manual.'
	Print  @miscprint
	Select @miscprint = 'exec dbo.dpsp_Approve @gears_id = 12345, @runtype = ''manual'''
	Print  @miscprint
	Print  ' '
	Print  ' '
	Print  ' '
	if @specReq = 'y'
	    begin
		goto label99
	    end



	dpsp_Cancel_Gears:
	Select @miscprint = '*************** dpsp_Cancel_Gears *****************'
	Print  @miscprint
	Select @miscprint = 'This stored procedure will cancel a specific Gears'
	Print  @miscprint
	Select @miscprint = 'ticket and then delete that Gears request from the'
	Print  @miscprint
	Select @miscprint = 'DEPLcontrol database.'
	Print  @miscprint
	Select @miscprint = '***************************************************'
	Print  @miscprint
	Select @miscprint = 'Input Parameters:'
	Print  @miscprint
	Select @miscprint = ''+char(9)+'@gears_id - is the Gears ID for a specific request. '
	Print  @miscprint
	Print  ' '
	select @miscprint = 'Examples:'
	print  @miscprint 
	Select @miscprint = '--Cancel a Request for Deployment and in GEARS:'
	Print  @miscprint
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_Cancel_Gears @gears_id = 12345'
	Print  @miscprint
	Print  ' '
	Print  ' '
	Print  ' '
	if @specReq = 'y'
	    begin
		goto label99
	    end
	

	dpsp_delete:
	Select @miscprint = '*************** dpsp_Delete *****************'
	Print  @miscprint
	Select @miscprint = 'This stored procedure will delete a specific '
	Print  @miscprint
	Select @miscprint = 'Gears request from the DEPLcontrol database;'
	Print  @miscprint
	Select @miscprint = 'but not GEARS.'
	Print  @miscprint
	Select @miscprint = 'Note: To Cancel a Gears Request in GEARS and DeplControl'
	Print  @miscprint
	Select @miscprint = '      and DeplControl use dpsp_Cancel_Gears.'
	Print  @miscprint
	Select @miscprint = '*********************************************'
	Print  @miscprint
	Select @miscprint = 'Input Parameters:'
	Print  @miscprint
	Select @miscprint = ''+char(9)+'@gears_id - is the Gears ID for a specific request. '
	Print  @miscprint
	Print  ' '
	select @miscprint = 'Examples:'
	print  @miscprint 
	Select @miscprint = '--Delete a Request in Deployment:'
	Print  @miscprint
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_Delete @gears_id = 12345'
	Print  @miscprint
	Print  ' '
	Print  ' '
	Print  ' '
	if @specReq = 'y'
	    begin
		goto label99
	    end


	dpsp_ManualStart:
	Select @miscprint = '*************** dpsp_ManualStart *****************'
	Print  @miscprint
	Select @miscprint = 'This stored procedure will assist in manually '
	Print  @miscprint
	Select @miscprint = 'starting deployment processes in stage and production.'
	Print  @miscprint
	Select @miscprint = 'Note: Typically used with dpsp_Approve with'
	Print  @miscprint
	Select @miscprint = '@runtype=''manual''.'
	Print  @miscprint
	Select @miscprint = '**************************************************'
	Print  @miscprint
	Select @miscprint = 'Input Parameters:'
	Print  @miscprint
	Select @miscprint = ''+char(9)+'@gears_id - is the Gears ID for a specific request. '
	Print  @miscprint
	Select @miscprint = ''+char(9)+'@SQLname -  is the SQLname (with instance) you want to start. '
	Print  @miscprint
	Print  ' '
	select @miscprint = 'Examples:'
	print  @miscprint 
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
	Print  ' '
	Print  ' '
	if @specReq = 'y'
	    begin
		goto label99
	    end


	dpsp_status:
	Select @miscprint = '*************** dpsp_status *****************'
	Print  @miscprint
	Select @miscprint = 'This stored procedure will provide status '
	Print  @miscprint
	Select @miscprint = 'information for SQL related deployment requests'
	Print  @miscprint
	Select @miscprint = 'as part of the SQL Request Driven Process.'
	Print  @miscprint
   	Select @miscprint = '*********************************************'
	Print  @miscprint
	Select @miscprint = 'Input Parameters:'
	Print  @miscprint
	Select @miscprint = ''+char(9)+'@gears_id - is the Gears ID for a specific request. '
	Print  @miscprint
	Select @miscprint = ''+char(9)+'@fromdate (optional)  -- All requests after a specific date' 
	Print  @miscprint
	Print  ' '
	select @miscprint = 'Examples:'
	print  @miscprint  
	Select @miscprint = '--Report Status for a specific Gears ID:'
	Print  @miscprint
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_status @gears_id = 12345 ' -- The gears_id value must exist in the dbo.request table'
	Print  @miscprint
	Print  ' '
        Select @miscprint = '--Report Status all current GEARS Tickets in Request Driven:'
	Print  @miscprint
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_status '
	Print  @miscprint
	Print  ' '
	Select @miscprint = '--Report Status for all requests for a specific time period:'
	Print  @miscprint
	Select @miscprint = 'declare @fromdate datetime'
	Print  @miscprint
	Select @miscprint = 'select @fromdate = getdate()-5'
	Print  @miscprint
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_status @report_fromdate = @fromdate  -- All requests after a specific date'
	Print  @miscprint
	Print  ' '
	Print  ' '
	Print  ' '
	if @specReq = 'y'
	    begin
		goto label99
	    end


	dpsp_Update:
	Select @miscprint = '*************** dpsp_Update *****************'
	Print  @miscprint
	Select @miscprint = 'This stored procedure will update specific Gears '
	Print  @miscprint
	Select @miscprint = 'request info as needed prior to SQL deployment'
	Print  @miscprint
	Select @miscprint = 'processing.'
	Print  @miscprint
	Select @miscprint = '*********************************************'
	Print  @miscprint
	Select @miscprint = 'Input Parameters:'
	Print  @miscprint
	Select @miscprint = ''+char(9)+'@gears_id -  is the Gears ID for a specific request. '
	Print  @miscprint
	Select @miscprint = ''+char(9)+'@detail_id - is the detail ID associated with a component '
	Print  @miscprint
	Select @miscprint = ''+char(9)+''+char(9)+'     of the Gears request (from the dpsp_status output)'
	Print  @miscprint
	Select @miscprint = ''+char(9)+'@start_dt -  is desired start time for the specific request. '
	Print  @miscprint
	Print  ' '
	select @miscprint = 'Examples:'
	print  @miscprint 
	Select @miscprint = '--Update Request Start Date/Time:'
	Print  @miscprint
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_update @gears_id = 12345'
	Print  @miscprint
	Select @miscprint = '                                ,@start_dt = ''20091229 09:21'''
	Print  @miscprint
	Print  ' '
	Select @miscprint = '--Update Request Status:'
	Print  @miscprint
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_update @gears_id = 12345'
	Print  @miscprint
	Select @miscprint = '                                ,@status = ''pending''   --''pending'', ''cancelled'', ''complete'', ''completed'', ''Gears Completed'', ''in-work'''
	Print  @miscprint
	Print  ' '
	Select @miscprint = '--Update ''all'' Request Detail for a specific SQLname and Gears ID:'
	Print  @miscprint
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_update @gears_id = 12345'
	Print  @miscprint
	Select @miscprint = '                                ,@SQLname = ''servername\A'''
	Print  @miscprint
	Select @miscprint = '                                ,@status = ''cancelled''   --''pending'', ''cancelled'', ''complete'', ''completed'', ''Gears Completed'', ''in-work'''
	Print  @miscprint
	Select @miscprint = '                                --,@domain = ''stage''     --''amer'', ''stage'', ''production'''
	Print  @miscprint
	Select @miscprint = '                                --,@BASEfolder = ''BNDL'''
	Print  @miscprint
	Print  ' '
	Select @miscprint = '--Update Request Detail for a specific Gears ID:'
	Print  @miscprint
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_update @gears_id = 12345'
	Print  @miscprint
	Select @miscprint = '                                ,@detail_id = 701'
	Print  @miscprint
	Select @miscprint = '                                ,@DBname = ''Bundle'''
	Print  @miscprint
	Select @miscprint = '                                --,@status = ''pending''       --''pending'', ''cancelled'', ''complete'', ''completed'', ''Gears Completed'', ''in-work'''
	Print  @miscprint
	Select @miscprint = '                                --,@ProcessType = ''DBA-ok''   --'' '', ''full'', ''sprocs_only'', ''Override_Needed'', ''DBA-ok'', ''DBA-cancelled'', ''JobRestore-y'', ''JobRestore-n'''
	Print  @miscprint
	Select @miscprint = '                                --,@SQLname = ''servername\A'''
	Print  @miscprint
	Select @miscprint = '                                --,@domain = ''stage''         --''amer'', ''stage'', ''production'''
	Print  @miscprint
	Select @miscprint = '                                --,@BASEfolder = ''BNDL'''
	Print  @miscprint
	Print  ' '
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_update @gears_id = 12345'
	Print  @miscprint
	Select @miscprint = '                                ,@detail_id = 702'
	Print  @miscprint
	Select @miscprint = '                                ,@ProcessType = ''JobRestore-n'''
	Print  @miscprint
	Print  ' '
	Print  ' '
	Print  ' '
	if @specReq = 'y'
	    begin
		goto label99
	    end
	    

	dpsp_Script_PreRelease:
	Select @miscprint = '************* dpsp_Script_PreRelease *****************'
	Print  @miscprint
	Select @miscprint = 'This sproc will assist in manually scripting the'
	Print  @miscprint
	Select @miscprint = 'start of the pre-release Backup Jobs in stage and'
	Print  @miscprint
	Select @miscprint = 'production.'
	Print  @miscprint
	Select @miscprint = '******************************************************'
	Print  @miscprint
	Select @miscprint = 'Input Parameters:'
	Print  @miscprint
	Select @miscprint = ''+char(9)+'@gears_id -  is the Gears ID for a specific request. '
	Print  @miscprint
	Print  ' '
	select @miscprint = 'Examples:'
	print  @miscprint 
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_Script_PreRelease @gears_id = 12345'
	Print  @miscprint
	Print  ' '
	Print  ' '
	Print  ' '	
	if @specReq = 'y'
	    begin
		goto label99
	    end


	dpsp_ahp_StartDeployment:
	Select @miscprint = '*************** dpsp_ahp_StartDeployment *******************'
	Print  @miscprint
	Select @miscprint = 'This stored procedure will assist in manually '
	Print  @miscprint
	Select @miscprint = 'starting AHP deployment processes in stage and production.'
	Print  @miscprint
	Select @miscprint = '************************************************************'
	Print  @miscprint
	Select @miscprint = 'Input Parameters:'
	Print  @miscprint
	Select @miscprint = ''+char(9)+'@RequestID - is the Request ID for a specific request. '
	Print  @miscprint
	Select @miscprint = ''+char(9)+'@TargetSQLname -  is the SQLname (with instance) you want to start. '
	Print  @miscprint
	Select @miscprint = ''+char(9)+'@ManualOverride -  to verify a manual start request. '
	Print  @miscprint
	Print  ' '
	select @miscprint = 'Examples:'
	print  @miscprint 
	Print  ' '
	Select @miscprint = '-- To Start a single Instance:'
	Print  @miscprint
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_ahp_StartDeployment @RequestID = 12345, @TargetSQLname = ''servername\a'', @ManualOverride = ''y'''
	Print  @miscprint
	Print  'go'
	Print  ' '
	Select @miscprint = '-- To script the code for all Instances:'
	Print  @miscprint
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_ahp_StartDeployment @RequestID = 12345, @TargetSQLname = ''ScriptAll'''
	Print  @miscprint
	Print  'go'
	Print  ' '
	Print  ' '
	Print  ' '
	if @specReq = 'y'
	    begin
		goto label99
	    end



-----------------  Finalizations  ------------------

label99:



GO
