USE [DEPLcontrol]
GO
/****** Object:  StoredProcedure [dbo].[dpsp_Status]    Script Date: 10/4/2013 11:02:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[dpsp_Status] (@gears_id int = null
				,@report_fromdate datetime = null
				,@report_only char(1) = 'n')

/*********************************************************
 **  Stored Procedure dpsp_Status                  
 **  Written by Jim Wilson, Getty Images                
 **  September 30, 2008                                      
 **  
 **  This sproc will provide status information for SQL related
 **  deployment requests as part of the SQL Request Driven Process.
 **
 **  Input Par(s);
 **  @gears_id - is the Gears ID for a specific request.  This
 **              will display information for only that Gears request.
 **
 ***************************************************************/
  as
set nocount on

--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	09/30/2008	Jim Wilson		New process.
--	12/01/2008	Jim Wilson		New code to handle same DB name for many different APPL's.
--	01/27/2009	Jim Wilson		Added domain info at the detail level.
--	02/25/2009	Jim Wilson		Moved status column for request_detail output and
--						add request date.
--	03/26/2009	Jim Wilson		Fixed bug for requests with no request_detail.
--	06/08/2009	Jim Wilson		Adjusted format for DBname and status.
--	05/27/2010	Jim Wilson		Adjusted format for Project and ProcessDetail.
--	======================================================================================


/***
Declare @gears_id int
Declare @report_fromdate datetime
Declare @report_only char(1)

Select @gears_id = 46070
--Select @report_fromdate = getdate()-5
Select @report_only = 'n'
--***/

-----------------  declares  ------------------

DECLARE
	 @miscprint			nvarchar(2000)
	,@save_gears_id			int
	,@save_projectname		sysname
	,@save_projectnum		sysname
	,@save_Project			sysname
	,@save_RequestDate		datetime
	,@save_startdate		datetime
	,@save_starttime		nvarchar(50)
	,@save_Start			sysname
	,@save_environment		sysname
	,@save_notes			nvarchar(4000)
	,@hold_notes			nvarchar(4000)
	,@save_DBname			sysname
	,@save_component_option		sysname
	,@save_build_number		sysname
	,@save_component_restore	sysname
	,@save_next_build		sysname
	,@save_APPLname			sysname
	,@save_BASEfolder		sysname
	,@save_SQLname			sysname
	,@save_BuildType		sysname
	,@save_Restore			char(1)
	,@save_RestoreType		sysname
	,@save_Build			sysname
	,@save_DETAILout_flag		char(1)
	,@DataExtract_flag		char(1)
	,@save_DBAapproved		char(1)
	,@save_DBAapprover		sysname
	,@save_companionDB_name		sysname
	,@save_domain			sysname

DECLARE
	 @error_count			int
	,@detail_report			char(1)
	,@save_Status			sysname
	,@save_ProcessType		sysname
	,@save_ProcessDetail		sysname
	,@save_ModDate			datetime
	,@save_reqdet_id		int


/*********************************************************************
 *                Initialization
 ********************************************************************/
Select @error_count = 0
Select @detail_report = 'n'

--  Create temp table
CREATE TABLE #temp_status_req ([Gears_id] [int] NOT NULL,
			[ProjectName] [sysname] NULL,
			[ProjectNum] [sysname] NULL,
			[RequestDate] [datetime] NULL,
			[StartDate] [datetime] NULL,
			[StartTime] [nvarchar] (50) NULL,
			[Environment] [sysname] NULL,
			[Notes] [nvarchar] (4000) NULL,
			[DBAapproved] [char] (01) NOT NULL,
			[DBAapprover] [sysname] NULL,
			[Status] [sysname] NULL,
			[ModDate] [datetime] NULL,
			)



CREATE TABLE #temp_status_reqdet ([Status] [sysname] NULL,
			[DBname] [sysname] NULL,
			[seq_id] [int] NULL,
			[APPLname] [sysname] NULL,
			[SQLname] [sysname] NULL,
			[domain] [sysname] NULL,
			[BASEfolder] [sysname] NULL,
			[Process] [sysname] NULL,
			[ProcessType] [sysname] NULL,
			[ProcessDetail] [sysname] NULL,
			[ModDate] [datetime] NULL,
			[reqdet_id] [int] NULL,
			)

CREATE TABLE #temp_status_reqdet2 ([DBname] [sysname] NULL,
			[APPLname] [sysname] NULL
			)

CREATE TABLE #temp_status_reqdet3 (APPLname sysname
			    ,BASEfolder sysname
			    ,SQLname sysname
			    ,domain sysname)


--  Verify input parms
If @gears_id is not null and @report_fromdate is not null
   begin
	Select @miscprint = 'DBA WARNING: Invalid input.  ''Gears ID'' and ''Report Date'' cannot both be selected.' 
	raiserror(@miscprint,-1,-1) with log
	Select @error_count = @error_count + 1
	goto label99
   end

If @gears_id is not null
   begin
	Select @detail_report = 'y'
	If not exists (select 1 from dbo.request where gears_id = @gears_id)
	   begin
		Select @miscprint = 'DBA WARNING: Invalid Gears ID (input parm).  No rows for this gears_id in the Request table.' 
		raiserror(@miscprint,-1,-1) with log
		Select @miscprint = '             This Gears ticket (#' + convert(nvarchar(20), @gears_id) + ') has not been imported into the DEPLcontrol database.' 
		raiserror(@miscprint,-1,-1) with log
		Select @error_count = @error_count + 1
		goto label99
	   end
   end


----------------------  Print the headers  ----------------------
If @report_only = 'n'
   begin
	Print  '/*******************************************************************'
	Select @miscprint = '   SQL Automated Deployment Requests - Server: ' + @@servername
	Print  @miscprint
	If @detail_report = 'y'
	   begin
		Print  ' '
		Select @miscprint = '-- Request Detail for gears_id: ' + convert(nvarchar(20), @gears_id)
		Print  @miscprint
	   end
	Print  ' '
	Select @miscprint = '-- Report Generated on ' + convert(varchar(30),getdate())
	Print  @miscprint
	Print  '*******************************************************************/'
	Print  ' '
   end
	

/****************************************************************
 *                MainLine
 ***************************************************************/

----------------------------------------------------------------------------------------------------------------------
--  Request Report "To Date" section  --------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
If @report_fromdate is not null
   begin
	Insert into #temp_status_req select Gears_id
				    ,ProjectName
				    ,ProjectNum
				    ,RequestDate
				    ,StartDate
				    ,StartTime
				    ,Environment
				    ,Notes
				    ,DBAapproved
				    ,DBAapprover
				    ,Status
				    ,ModDate
				from dbo.request 
				where ModDate >= @report_fromdate or StartDate >= @report_fromdate
				--Select * from #temp_status_req


	If (select count(*) from #temp_status_req) = 0
	   begin
		Select @miscprint = 'No results found for this report.' 
		goto label99
	   end

	--  Print the report headers
	Select @miscprint = 'GearsID  Project                   Environment  Start Date/Time   Status           Approved  Approver               Notes  Request Date      Last Mod Date'
	Print @miscprint
	Select @miscprint = '=======  ========================  ===========  ================  ===============  ========  =====================  =====  ================  ================'
	Print @miscprint

	start_reqFromDate:

	Select @save_Gears_id = (select top 1 Gears_id from #temp_status_req order by Gears_id desc)
	Select @save_ProjectName = (select ProjectName from #temp_status_req where Gears_id = @save_Gears_id)
	Select @save_ProjectNum = (select ProjectNum from #temp_status_req where Gears_id = @save_Gears_id)
	Select @save_Project = rtrim(@save_ProjectName) + ' ' + rtrim(@save_ProjectNum)
	Select @save_RequestDate = (select RequestDate from #temp_status_req where Gears_id = @save_Gears_id)
	Select @save_StartDate = (select StartDate from #temp_status_req where Gears_id = @save_Gears_id)
	Select @save_StartTime = (select StartTime from #temp_status_req where Gears_id = @save_Gears_id)
	Select @save_Start = convert(char(8), @save_StartDate, 112) + ' ' + rtrim(@save_StartTime)
	Select @save_Environment = (select Environment from #temp_status_req where Gears_id = @save_Gears_id)
	If (select notes from #temp_status_req where Gears_id = @save_Gears_id) <> ''
	   begin
		Select @save_notes = 'y'
	   end
	Else
	   begin
		Select @save_notes = 'n'
	   end
	Select @save_DBAapproved = (select DBAapproved from #temp_status_req where Gears_id = @save_Gears_id)
	Select @save_DBAapprover = (select DBAapprover from #temp_status_req where Gears_id = @save_Gears_id)
	Select @save_Status = (select Status from #temp_status_req where Gears_id = @save_Gears_id)
	Select @save_ModDate = (select ModDate from #temp_status_req where Gears_id = @save_Gears_id)


	Select @miscprint = convert(char(7), @save_Gears_id) + '  ' 
			    + convert(char(24), @save_Project) + '  '
			    + convert(char(11), @save_Environment) + '  '
			    + convert(char(16), @save_Start) + '  '
			    + convert(char(15), @save_Status) + '  '
			    + @save_DBAapproved + '         '
			    + convert(char(21), @save_DBAapprover) + '  '
			    + convert(char(5), @save_notes) + '  '
			    + convert(char(16), @save_RequestDate, 120) + '  '
			    + convert(char(16), @save_ModDate, 120)
	Print @miscprint


	--  Check to see if there are more row to process
	delete from #temp_status_req where gears_id = @save_Gears_id
	If (select count(*) from #temp_status_req) > 0
	   begin
		goto start_reqFromDate
	   end


	goto label99

   end

----------------------------------------------------------------------------------------------------------------------
--  Request Report Current section  ----------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
If @detail_report = 'n'
   begin
	Insert into #temp_status_req select Gears_id
				    ,ProjectName
				    ,ProjectNum
				    ,RequestDate
				    ,StartDate
				    ,StartTime
				    ,Environment
				    ,Notes
				    ,DBAapproved
				    ,DBAapprover
				    ,Status
				    ,ModDate
				from dbo.request 
				where status not like '%complete%' and status not like '%cancel%'
	--Select * from #temp_status_req

	If (select count(*) from #temp_status_req) = 0
	   begin
		Select @miscprint = 'No results found for this report.' 
		Print @miscprint
		goto label99
	   end

	--  Print the report headers
	Select @miscprint = 'GearsID  Project                   Environment  Start Date/Time   Status           Approved  Approver               Request Date'
	Print @miscprint
	Select @miscprint = '=======  ========================  ===========  ================  ===============  ========  =====================  ================'
	Print @miscprint

	start_req:

	Select @save_Gears_id = (select top 1 Gears_id from #temp_status_req order by Gears_id desc)
	Select @save_ProjectName = (select ProjectName from #temp_status_req where Gears_id = @save_Gears_id)
	Select @save_ProjectNum = (select ProjectNum from #temp_status_req where Gears_id = @save_Gears_id)
	Select @save_Project = rtrim(@save_ProjectName) + ' ' + rtrim(@save_ProjectNum)
	Select @save_RequestDate = (select RequestDate from #temp_status_req where Gears_id = @save_Gears_id)
	Select @save_StartDate = (select StartDate from #temp_status_req where Gears_id = @save_Gears_id)
	Select @save_StartTime = (select StartTime from #temp_status_req where Gears_id = @save_Gears_id)
	Select @save_Start = convert(char(8), @save_StartDate, 112) + ' ' + rtrim(@save_StartTime)
	Select @save_Environment = (select Environment from #temp_status_req where Gears_id = @save_Gears_id)
	If (select notes from #temp_status_req where Gears_id = @save_Gears_id) <> ''
	   begin
		Select @save_notes = 'y'
	   end
	Else
	   begin
		Select @save_notes = 'n'
	   end
	Select @save_DBAapproved = (select DBAapproved from #temp_status_req where Gears_id = @save_Gears_id)
	Select @save_DBAapprover = (select DBAapprover from #temp_status_req where Gears_id = @save_Gears_id)
	Select @save_Status = (select Status from #temp_status_req where Gears_id = @save_Gears_id)



	Select @miscprint = convert(char(7), @save_Gears_id) + '  ' 
			    + convert(char(24), @save_Project) + '  '
			    + convert(char(11), @save_Environment) + '  '
			    + convert(char(16), @save_Start) + '  '
			    + convert(char(15), @save_Status) + '  '
			    + @save_DBAapproved + '         '
			    + convert(char(21), @save_DBAapprover) + '  '
			    + convert(char(16), @save_RequestDate, 120)

	Print @miscprint


	--  Check to see if there are more row to process
	delete from #temp_status_req where gears_id = @save_Gears_id
	If (select count(*) from #temp_status_req) > 0
	   begin
		goto start_req
	   end


	goto label99

   end


----------------------------------------------------------------------------------------------------------------------
--  Request Detail Report section  -----------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

--  Print the report headers
Select @miscprint = 'GearsID  Project                   Environment  Start Date/Time   Status           Approved  Approver               Request Date'
Print @miscprint
Select @miscprint = '=======  ========================  ===========  ================  ===============  ========  =====================  ================'
Print @miscprint

Select @save_Gears_id = @gears_id
Select @save_ProjectName = (select ProjectName from dbo.request where Gears_id = @save_Gears_id)
Select @save_ProjectNum = (select ProjectNum from dbo.request where Gears_id = @save_Gears_id)
Select @save_Project = rtrim(@save_ProjectName) + ' ' + rtrim(@save_ProjectNum)
Select @save_RequestDate = (select RequestDate from dbo.request where Gears_id = @save_Gears_id)
Select @save_StartDate = (select StartDate from dbo.request where Gears_id = @save_Gears_id)
Select @save_StartTime = (select StartTime from dbo.request where Gears_id = @save_Gears_id)
Select @save_Start = convert(char(8), @save_StartDate, 112) + ' ' + rtrim(@save_StartTime)
Select @save_Environment = (select Environment from dbo.request where Gears_id = @save_Gears_id)
If (select notes from dbo.request where Gears_id = @save_Gears_id) <> ''
   begin
	Select @save_notes = 'y'
	Select @hold_notes = (select notes from dbo.request where Gears_id = @save_Gears_id)
   end
Else
   begin
	Select @save_notes = 'n'
   end
Select @save_DBAapproved = (select DBAapproved from dbo.request where Gears_id = @save_Gears_id)
Select @save_DBAapprover = (select DBAapprover from dbo.request where Gears_id = @save_Gears_id)
Select @save_Status = (select Status from dbo.request where Gears_id = @save_Gears_id)


Select @miscprint = convert(char(7), @save_Gears_id) + '  ' 
		    + convert(char(24), @save_Project) + '  '
		    + convert(char(11), @save_Environment) + '  '
		    + convert(char(16), @save_Start) + '  '
		    + convert(char(15), @save_Status) + '  '
		    + @save_DBAapproved + '         '
		    + convert(char(21), @save_DBAapprover) + '  '
		    + convert(char(16), @save_RequestDate, 120)

Print @miscprint

If @save_notes = 'y'
   begin
	Print ''
	Select @miscprint = 'Notes:'
	Print @miscprint
	Print @hold_notes
	Print ''
   end
Else
   begin
	Print ''
	Select @miscprint = 'No Notes for this request.'
	Print @miscprint
	Print ''
   end



Insert into #temp_status_reqdet select d.Status
				,d.DBname
				,s.seq_id
				,d.APPLname
				,d.SQLname
				,d.domain
				,d.BASEfolder
				,d.Process
				,d.ProcessType
				,d.ProcessDetail
				,d.ModDate
				,d.reqdet_id
			from dbo.Request_detail d, dbo.db_sequence s
			where d.DBname = s.DBname
			and d.gears_id = @gears_id
--Select * from #temp_status_reqdet

--  Load second table to help weed out dataextract requests
Insert into #temp_status_reqdet2 select d.DBname
				,d.APPLname
			from dbo.Request_detail d
			where d.gears_id = @gears_id

--Select * from #temp_status_reqdet2


If (select count(*) from #temp_status_reqdet) = 0
   begin
	Select @miscprint = 'Note: No detail results found for this request.' 
	Print @miscprint
	goto label99
   end


--  Print the detail report headers
Print  ' '
Select @miscprint = 'Appl    DBname                       Process  ProcessType   ProcessDetail                         Status        SQLname                 Domain      BASEfolder  Last Mod Date     DetailID'
Print  @miscprint
Select @miscprint = '======  ===========================  =======  ============  ====================================  ============  ======================  ==========  ==========  ================  ========='
Print  @miscprint

loop_detail:
Select @save_DETAILout_flag = 'n'
Select @save_SQLname = (select top 1 SQLname from #temp_status_reqdet order by APPLname)
Select @save_domain = (select top 1 domain from #temp_status_reqdet where SQLname = @save_SQLname)

--  Report the start row for this SQLname
If exists (select 1 from dbo.request_detail where gears_id = @gears_id and SQLname = @save_SQLname and domain = @save_domain and process = 'start')
   begin
	Select @save_ProcessType = (select ProcessType from dbo.request_detail where gears_id = @save_Gears_id and SQLname = @save_SQLname and domain = @save_domain and process = 'start')
	Select @save_Status = (select Status from dbo.request_detail where gears_id = @save_Gears_id and SQLname = @save_SQLname and domain = @save_domain and process = 'start')
	Select @save_ModDate = (select ModDate from dbo.request_detail where gears_id = @save_Gears_id and SQLname = @save_SQLname and domain = @save_domain and process = 'start')
	Select @save_reqdet_id = (select reqdet_id from dbo.request_detail where gears_id = @save_Gears_id and SQLname = @save_SQLname and domain = @save_domain and process = 'start')

	Select @miscprint = convert(char(6), '') + '  ' 
			    + convert(char(27), '') + '  '
			    + 'Start    '
			    + convert(char(12), @save_ProcessType) + '  '
			    + convert(char(36), '') + '  '
			    + convert(char(12), @save_Status) + '  '
			    + convert(char(22), @save_SQLname) + '  '
			    + convert(char(10), @save_domain) + '  '
			    + convert(char(10), '') + '  '
			    + convert(char(16), @save_ModDate, 20) + '  '
			    + convert(char(15), @save_reqdet_id)
	Print @miscprint
	Select @save_DETAILout_flag = 'y'

	delete from #temp_status_reqdet where reqdet_id = @save_reqdet_id
   end


loop_restore:
--  Report the restore requests for this SQLname 
If exists (select 1 from #temp_status_reqdet where SQLname = @save_SQLname and process = 'restore')
   begin
	Select @save_reqdet_id = (select top 1 reqdet_id from #temp_status_reqdet where SQLname = @save_SQLname and process = 'restore' order by seq_id)
	Select @save_APPLname = (select top 1 APPLname from #temp_status_reqdet where reqdet_id = @save_reqdet_id)
	Select @save_DBname = (select top 1 DBname from #temp_status_reqdet where reqdet_id = @save_reqdet_id)
	Select @save_ProcessType = (select ProcessType from #temp_status_reqdet where reqdet_id = @save_reqdet_id)
	Select @save_ProcessDetail = (select ProcessDetail from #temp_status_reqdet where reqdet_id = @save_reqdet_id)
	Select @save_BASEfolder = (select BASEfolder from #temp_status_reqdet where reqdet_id = @save_reqdet_id)
	Select @save_Status = (select Status from #temp_status_reqdet where reqdet_id = @save_reqdet_id)
	Select @save_ModDate = (select ModDate from #temp_status_reqdet where reqdet_id = @save_reqdet_id)
   end
Else
   begin
	goto skip_restore
   end


Select @miscprint = convert(char(6), @save_APPLname) + '  ' 
		    + convert(char(27), @save_DBname) + '  '
		    + 'Restore  '
		    + convert(char(12), @save_ProcessType) + '  '
		    + convert(char(36), @save_ProcessDetail) + '  '
		    + convert(char(12), @save_Status) + '  '
		    + convert(char(22), @save_SQLname) + '  '
		    + convert(char(10), @save_domain) + '  '
		    + convert(char(10), @save_BASEfolder) + '  '
		    + convert(char(16), @save_ModDate, 20) + '  '
		    + convert(char(15), @save_reqdet_id)
Print @miscprint
Select @save_DETAILout_flag = 'y'



next_restore:

delete from #temp_status_reqdet where reqdet_id = @save_reqdet_id 
If (select count(*) from #temp_status_reqdet where SQLname = @save_SQLname and process = 'restore') > 0
   begin
	goto loop_restore
   end

skip_restore:


loop_deploy:
--  Now we report the deploy requests for this SQLname 
If exists (select 1 from #temp_status_reqdet where SQLname = @save_SQLname and process = 'deploy')
   begin
	Select @save_reqdet_id = (select top 1 reqdet_id from #temp_status_reqdet where SQLname = @save_SQLname and process = 'deploy' order by seq_id)
	Select @save_APPLname = (select top 1 APPLname from #temp_status_reqdet where SQLname = @save_SQLname and reqdet_id = @save_reqdet_id)
	Select @save_DBname = (select top 1 DBname from #temp_status_reqdet where reqdet_id = @save_reqdet_id)
	Select @save_ProcessType = (select ProcessType from #temp_status_reqdet where reqdet_id = @save_reqdet_id)
	Select @save_ProcessDetail = (select ProcessDetail from #temp_status_reqdet where reqdet_id = @save_reqdet_id)
	Select @save_BASEfolder = (select BASEfolder from #temp_status_reqdet where reqdet_id = @save_reqdet_id)
	Select @save_Status = (select Status from #temp_status_reqdet where reqdet_id = @save_reqdet_id)
	Select @save_ModDate = (select ModDate from #temp_status_reqdet where reqdet_id = @save_reqdet_id)
   end
Else
   begin
	goto skip_deploy
   end



Select @miscprint = convert(char(6), @save_APPLname) + '  ' 
		    + convert(char(27), @save_DBname) + '  '
		    + 'Deploy   '
		    + convert(char(12), @save_ProcessType) + '  '
		    + convert(char(36), @save_ProcessDetail) + '  '
		    + convert(char(12), @save_Status) + '  '
		    + convert(char(22), @save_SQLname) + '  '
		    + convert(char(10), @save_domain) + '  '
		    + convert(char(10), @save_BASEfolder) + '  '
		    + convert(char(16), @save_ModDate, 20) + '  '
		    + convert(char(15), @save_reqdet_id)
Print @miscprint


next_deploy:

delete from #temp_status_reqdet where reqdet_id = @save_reqdet_id
If (select count(*) from #temp_status_reqdet where SQLname = @save_SQLname and process = 'deploy') > 0
   begin
	goto loop_deploy
   end


skip_deploy:



--  Report the end row for this SQLname
If exists (select 1 from dbo.request_detail where gears_id = @gears_id and SQLname = @save_SQLname and domain = @save_domain and process = 'end')
   begin
	Select @save_Status = (select Status from dbo.request_detail where gears_id = @save_Gears_id and SQLname = @save_SQLname and domain = @save_domain and process = 'end')
	Select @save_ModDate = (select ModDate from dbo.request_detail where gears_id = @save_Gears_id and SQLname = @save_SQLname and domain = @save_domain and process = 'end')
	Select @save_reqdet_id = (select reqdet_id from dbo.request_detail where gears_id = @save_Gears_id and SQLname = @save_SQLname and domain = @save_domain and process = 'end')

	Select @miscprint = convert(char(6), '') + '  ' 
			    + convert(char(27), '') + '  '
			    + 'End      '
			    + convert(char(12), '') + '  '
			    + convert(char(36), '') + '  '
			    + convert(char(12), @save_Status) + '  '
			    + convert(char(22), @save_SQLname) + '  '
			    + convert(char(10), @save_domain) + '  '
			    + convert(char(10), '') + '  '
			    + convert(char(16), @save_ModDate, 20) + '  '
			    + convert(char(15), @save_reqdet_id)
	Print @miscprint
	Select @save_DETAILout_flag = 'y'

	delete from #temp_status_reqdet where reqdet_id = @save_reqdet_id
   end





If (select count(*) from #temp_status_reqdet) > 0
   begin
	If @save_DETAILout_flag = 'y'
	   begin
		Print ' '
	   end

	goto loop_detail
   end




-----------------  Finalizations  ------------------

label99:

drop table #temp_status_req
drop table #temp_status_reqdet
drop table #temp_status_reqdet2
drop table #temp_status_reqdet3


If @report_only = 'n' and @gears_id is null and @report_fromdate is null
   begin
	If @save_Gears_id is null
	   begin
		Select @save_Gears_id = 12345
	   end

	Print  ' '
	Print  ' '
	Print  ' '
	Select @miscprint = '--------------------------------------------------'
	Print  @miscprint
	Select @miscprint = '--Here are sample execute commands for this sproc:'
	Print  @miscprint
	Select @miscprint = '--------------------------------------------------'
	Print  @miscprint
	Print  ' '
	Select @miscprint = '--Report Status for a speicif Gears ID:'
	Print  @miscprint
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_status @gears_id = ' + convert(char(7), @save_Gears_id) + ' -- The gears_id value must exist in the dbo.request table'
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
   end




GO
