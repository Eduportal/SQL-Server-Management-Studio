USE [DEPLcontrol]
GO
/****** Object:  StoredProcedure [dbo].[dpsp_ahp_UpdateFromLocal]    Script Date: 10/4/2013 11:02:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[dpsp_ahp_UpdateFromLocal] (@request_id int
					,@status sysname
					,@process sysname
					,@ProcessType sysname
					,@ProcessDetail sysname
					,@DBname sysname
					,@TargetSQLname sysname
					,@moddate datetime)

/*********************************************************
 **  Stored Procedure dpsp_ahp_UpdateFromLocal                 
 **  Written by Jim Wilson, Getty Images                
 **  October 29, 2010                                      
 **  
 **  This sproc will update central server tables with information
 **  about deployments that are in process.
 **
 ***************************************************************/
  as
set nocount on

--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	10/29/2010	Jim Wilson		New process.
--	03/01/2011	Jim Wilson		Added update to Request_complte.
--	======================================================================================


/***
Declare @request_id int
Declare @status sysname
Declare @process sysname
Declare @ProcessType sysname
Declare @ProcessDetail sysname
Declare @DBname sysname
Declare @TargetSQLname sysname
Declare @moddate datetime

Select @request_id = 12345
Select @status = 'completed'
Select @process = 'start'
Select @ProcessType = ''
Select @ProcessDetail = ''
Select @DBname = ''
Select @TargetSQLname = ''
Select @moddate = getdate()
--***/



-----------------  declares  ------------------

DECLARE
	 @miscprint			nvarchar(2000)
	,@query				nvarchar(4000)
	,@cmd				nvarchar(4000)
	,@charpos			int
	,@gears_id			int
	,@CentralSQLname		sysname
	,@dynamicSQL			nvarchar(2000)
	,@dynamicVAR			nvarchar(100)
	,@baseline_info			sysname
	,@save_ProjectName		sysname
	,@save_ProjectNum		sysname
	,@save_ProjectNum_mask		sysname
	,@save_APPLname			sysname
	,@save_BASEfolder		sysname
	,@save_ProcessType		sysname
	,@save_ProcessDetail 		sysname
	,@save_DBname 			sysname
	,@save_moddate			datetime

DECLARE
	 @error_count			int
	,@save_Status			sysname
	,@save_subject			sysname
	,@save_message			nvarchar(4000)
	,@retry				int
	,@retry_limit			int


/*********************************************************************
 *                Initialization
 ********************************************************************/
Select @error_count = 0
Select @save_status = 'completed'
Select @retry_limit = 5
Select @save_status = @status
Select @save_ProcessType = @ProcessType
Select @save_ProcessDetail = @ProcessDetail
Select @save_DBname = @DBname
Select @save_moddate = @moddate

create table #output (output_data nvarchar(4000) null)



Select @save_ProjectName = (select top 1 ProjectName from dbo.AHP_Import_Requests where request_id = @request_id)
Select @save_ProjectNum = (select top 1 ReleaseNum from dbo.AHP_Import_Requests where request_id = @request_id)





----------------------  Print the headers  ----------------------

Print  ' '
Select @miscprint = 'SQL DEPLinfo Update From Local process.'
Print  @miscprint
Select @miscprint = '-- Process run: ' + convert(varchar(30),getdate())
Print  @miscprint
Print  ' '



/****************************************************************
 *                MainLine
 ***************************************************************/

-- Check for the start process
If @process = 'start'
   begin

	select @query = 'If not exists (select 1 from DEPLcontrol.dbo.control_ahp 
			where request_id = ' + convert(nvarchar(20), @request_id) + '
			and process = ''start'')' + char(13)+char(10)

	select @query = @query + '   begin' + char(13)+char(10)
	select @query = @query + '      Insert into DEPLcontrol.dbo.control_ahp 
						values (' + convert(nvarchar(20), @request_id) + '
							, ''' + @save_ProjectName + '''
							, ''' + @save_ProjectNum + '''
							, ''' + @save_status + '''
							, ''' + @process + '''
							, null, null, ''' + @TargetSQLname + ''', null, null, null
							, ''' + convert(nvarchar(30), @save_moddate, 121) + '''
							, getdate())' + char(13)+char(10)
	select @query = @query + '   end ' + char(13)+char(10)
	select @query = @query + 'Else' + char(13)+char(10)
	select @query = @query + '   begin' + char(13)+char(10)
	select @query = @query + '      update DEPLcontrol.dbo.control_ahp set Status = ''' + @save_status + ''', ModDate = getdate()' + char(13)+char(10)
 	select @query = @query + '       where request_id = ' + convert(nvarchar(20), @request_id) + ' and TargetSQLname = ''' + @TargetSQLname + ''' and Process = ''start''' + char(13)+char(10)
	select @query = @query + '   end' + char(13)+char(10)
	Print @query
	Exec (@query)
   end
Else If @process = 'restore'
   begin
	Select @save_BASEfolder = (select top 1 BaseName from dbo.AHP_Import_Requests where request_id = @request_id and DBname = @save_DBname and TargetSQLname = @TargetSQLname)
	Select @save_APPLname = @save_BASEfolder

	Select @charpos = charindex('_', @save_APPLname)
	IF @charpos <> 0
	   begin
		Select @save_APPLname = substring(@save_APPLname, 1, @charpos-1)
	   end

	If @ProcessDetail is not null
	   begin
		Select @baseline_info = @ProcessDetail
	   end
	Else
	   begin
		Select @baseline_info = 'Baseline date unknown'
	   end

	select @query = 'If not exists (select 1 from DEPLcontrol.dbo.control_ahp 
						where request_id = ' + convert(nvarchar(20), @request_id) + '
						and process = ''restore''
						and DBname = ''' + @save_DBname + ''')' + char(13)+char(10)

	select @query = @query + '   begin' + char(13)+char(10)
	select @query = @query + '      Insert into DEPLcontrol.dbo.control_ahp 
						values (' + convert(nvarchar(20), @request_id) + '
							, ''' + @save_ProjectName + '''
							, ''' + @save_ProjectNum + '''
							, ''' + @save_status + '''
							, ''' + @process + '''
							, null, null
							, ''' + @TargetSQLname + '''
							, ''' + @save_DBname + '''
							, ''' + @save_APPLname + '''
							, ''' + @save_BASEfolder + '''
							, ''' + convert(nvarchar(30), @save_moddate, 121) + '''
							, getdate())' + char(13)+char(10)
	select @query = @query + '   end ' + char(13)+char(10)
	select @query = @query + 'Else' + char(13)+char(10)
	select @query = @query + '   begin' + char(13)+char(10)
	select @query = @query + '      update DEPLcontrol.dbo.control_ahp set Status = ''' + @save_status + ''', ProcessDetail = ''' + @baseline_info + ''', ModDate = getdate()' + char(13)+char(10)
 	select @query = @query + '       where request_id = ' + convert(nvarchar(20), @request_id) + ' and TargetSQLname = ''' + @TargetSQLname + ''' and Process = ''restore'' and DBname = ''' + @save_DBname + '''' + char(13)+char(10)
	select @query = @query + '   end' + char(13)+char(10)
	Print @query
	Exec (@query)

	--  Update the dbo.AHP_Import_Requests table
	If @save_status like '%cancel%'
	   begin
		update dbo.AHP_Import_Requests set Request_Status = 'Restore cancelled', Request_complete = getdate() where request_id = @request_id and DBname = @save_DBname and TargetSQLname = @TargetSQLname and request_type = 'restore'
	   end
	Else If @save_status like '%complete%'
	   begin
		update dbo.AHP_Import_Requests set Request_Status = 'Restore completed', Request_complete = getdate() where request_id = @request_id and DBname = @save_DBname and TargetSQLname = @TargetSQLname and request_type = 'restore'
	   end
	Else 
	   begin
		update dbo.AHP_Import_Requests set Request_Status = 'Restore in-work' where request_id = @request_id and DBname = @save_DBname and TargetSQLname = @TargetSQLname and request_type = 'restore'
	   end
    end

Else If @process = 'deploy'
   begin
	Select @save_BASEfolder = (select top 1 BaseName from dbo.AHP_Import_Requests where request_id = @request_id and DBname = @save_DBname and TargetSQLname = @TargetSQLname)
	Select @save_APPLname = @save_BASEfolder

	Select @charpos = charindex('_', @save_APPLname)
	IF @charpos <> 0
	   begin
		Select @save_APPLname = substring(@save_APPLname, 1, @charpos-1)
	   end


	select @query = 'If not exists (select 1 from DEPLcontrol.dbo.control_ahp 
						where request_id = ' + convert(nvarchar(20), @request_id) + '
						and process = ''deploy''
						and DBname = ''' + @save_DBname + ''')' + char(13)+char(10)

	select @query = @query + '   begin' + char(13)+char(10)
	select @query = @query + '      Insert into DEPLcontrol.dbo.control_ahp 
						values (' + convert(nvarchar(20), @request_id) + '
							, ''' + @save_ProjectName + '''
							, ''' + @save_ProjectNum + '''
							, ''' + @save_status + '''
							, ''' + @process + '''
							, ''' + @save_ProcessType + '''
							, ''' + @save_ProcessDetail + '''
							, ''' + @TargetSQLname + '''
							, ''' + @save_DBname + '''
							, ''' + @save_APPLname + '''
							, null
							, ''' + convert(nvarchar(30), @save_moddate, 121) + '''
							, getdate())' + char(13)+char(10)
	select @query = @query + '   end ' + char(13)+char(10)
	select @query = @query + 'Else' + char(13)+char(10)
	select @query = @query + '   begin' + char(13)+char(10) + char(13)+char(10)
	select @query = @query + '      update DEPLcontrol.dbo.control_ahp set Status = ''' + @save_status + ''', ProcessDetail = ''' + @save_ProcessDetail + ''', ModDate = getdate()' + char(13)+char(10)
 	select @query = @query + '       where request_id = ' + convert(nvarchar(20), @request_id) + ' and TargetSQLname = ''' + @TargetSQLname + ''' and Process = ''deploy'' and DBname = ''' + @save_DBname + '''' + char(13)+char(10)
	select @query = @query + '   end' + char(13)+char(10)
	Print @query
	Exec (@query)

	--  Update the dbo.AHP_Import_Requests table
	If @save_status like '%cancel%'
	   begin
		update dbo.AHP_Import_Requests set Request_Status = 'Deploy cancelled', Request_complete = getdate() where request_id = @request_id and DBname = @save_DBname and TargetSQLname = @TargetSQLname and request_type = 'deploy'
	   end
	Else If @save_status like '%complete%'
	   begin
		update dbo.AHP_Import_Requests set Request_Status = 'Deploy completed', Request_complete = getdate() where request_id = @request_id and DBname = @save_DBname and TargetSQLname = @TargetSQLname and request_type = 'deploy'
	   end
	Else 
	   begin
		update dbo.AHP_Import_Requests set Request_Status = 'Deploy in-work' where request_id = @request_id and DBname = @save_DBname and TargetSQLname = @TargetSQLname and request_type = 'deploy'
	   end

   end
Else If @process = 'end'
   begin
	select @query = 'If not exists (select 1 from DEPLcontrol.dbo.control_ahp 
						where request_id = ' + convert(nvarchar(20), @request_id) + '
						and process = ''end'')' + char(13)+char(10)

	select @query = @query + '   begin' + char(13)+char(10)
	select @query = @query + '      Insert into DEPLcontrol.dbo.control_ahp	values (' + convert(nvarchar(20), @request_id) + '
							, ''' + @save_ProjectName + '''
							, ''' + @save_ProjectNum + '''
							, ''' + @save_status + '''
							, ''' + @process + '''
							, null, null, ''' + @TargetSQLname + ''', null, null, null
							, ''' + convert(nvarchar(30), @save_moddate, 121) + '''
							, getdate())' + char(13)+char(10)
	select @query = @query + '   end ' + char(13)+char(10)
	select @query = @query + 'Else' + char(13)+char(10)
	select @query = @query + '   begin' + char(13)+char(10)
	select @query = @query + '      update DEPLcontrol.dbo.control_ahp set Status = ''' + @save_status + ''', ModDate = getdate()' + char(13)+char(10)
 	select @query = @query + '       where request_id = ' + convert(nvarchar(20), @request_id) + ' and TargetSQLname = ''' + @TargetSQLname + ''' and Process = ''end''' + char(13)+char(10)
	select @query = @query + '   end' + char(13)+char(10)
	Print @query
	Exec (@query)


	--  Update the dbo.AHP_Import_Requests table
	If @save_status like '%complete%'
	   begin
		update dbo.AHP_Import_Requests set Request_Status = 'completed' where request_id = @request_id and TargetSQLname = @TargetSQLname and Request_Type <> 'handshake'
	   end
   end
Else
   begin
	--  We should never be here.  This is bad!
	Select @save_subject = 'ERROR: DEPL_ahp Central Update From Local from ' + @@servername
	Select @save_message = 'DEPL Central Update Error for server ' + @@servername + '.  This process could not determine what just happened so it was unable to update the central table.'

	EXEC dbaadmin.dbo.dbasp_sendmail 
		@recipients = 'tssqldba@gettyimages.com',  
		@subject = @save_subject,
		@message = @save_message
   end



-----------------  Finalizations  ------------------

label99:


drop  table #output









GO
