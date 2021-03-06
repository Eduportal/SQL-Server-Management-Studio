USE [DEPLcontrol]
GO
/****** Object:  StoredProcedure [dbo].[dpsp_ImportGears]    Script Date: 10/4/2013 11:02:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[dpsp_ImportGears]

/***************************************************************
 **  Stored Procedure dpsp_ImportGears                  
 **  Written by Jim Wilson, Getty Images                
 **  September 29, 2008                                      
 **  
 **  This sproc is set up to Import deployment requests from
 **  Gears into DEPLcontrol for processing.
 ***************************************************************/
  as
set nocount on

--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	09/29/2008	Jim Wilson		New process.
--	12/03/2008	Jim Wilson		Fixed DataExtract issue related to companion DB names.
--	01/27/2009	Jim Wilson		Added domain info.
--	02/24/2009	Jim Wilson		Added auto approve code.
--	02/25/2009	Jim Wilson		Added RequestDate to dbo.request table.
--	03/10/2009	Jim Wilson		Set no job restore for sproc only requests.
--	03/16/2009	Jim Wilson		Added email for non-import error.
--	03/26/2009	Jim Wilson		New code to import SQL related tickest with no SQL components.
--	04/01/2009	Jim Wilson		Updated how we deal with requests that have the restore field blank.
--	04/06/2009	Jim Wilson		Fixed domain for start and end rows.
--	04/09/2009	Jim Wilson		New code to make sure stage and prod are not auto approved.
--	04/30/2009	Jim Wilson		Fixed import for detail rows (build and restore).
--	05/08/2009	Jim Wilson		Added auto aprove for stage and prod.
--	09/16/2009	Jim Wilson		Auto reset for start date and time if Saturday or Sunday.
--	10/14/2009	Jim Wilson		New code to auto approve non prod and stage requests with no notes.
--	10/30/2009	Jim Wilson		Added one last start time fix for missing leading zero.
--	11/17/2009	Jim Wilson		New code for SQLname override target.
--	11/24/2009	Jim Wilson		Changed insert into #temp_reqdet3 when sqlname override = 'y'.
--	12/18/2009	Jim Wilson		Addeed 'manual' to resync with Gears section.
--	01/05/2010	Jim Wilson		Code to set APPLname for DataExtract when sqlname override = 'y'.
--	02/17/2010	Jim Wilson		More code to fix bad time inputs from gears.
--	03/26/2010	Jim Wilson		Added code for Candidate environment.
--	04/28/2010	Jim Wilson		Updated auto-approve for non-stage and non-prod.
--						Special password will override 'DBA Override Needed'
--	05/19/2010	Jim Wilson		Updated the companion DB code for DB's in more than one application (e.g. DataLogDB)
--	05/24/2010	Jim Wilson		Fix code for sqlname override - removed reference to envname in the "where"
--	06/01/2010	Jim Wilson		Changed dbaadmin to dbacentral for queries to dba_serverinfo.
--	08/04/2010	Jim Wilson		Updated gmail address.
--	08/10/2010	Jim Wilson		Fixed spelling for cancelled.
--	10/29/2010	Jim Wilson		Added code for Bundle20.
--	03/25/2011	Jim Wilson		Skip deploy for CRMexport.
--	09/15/2011	Jim Wilson		Updated central server name in comment.
--	04/09/2012	Jim Wilson		Added MessageQueue to the must approve a restore list.
--	06/29/2012	Jim Wilson		Added skip deployment (restore only) for AssetUsage_Archive.
--	08/07/2012	Jim Wilson		Removed skip deployment (restore only) for AssetUsage_Archive.
--	======================================================================================

-----------------  declares  ------------------

DECLARE
	 @miscprint			nvarchar(2000)
	,@charpos			int
	,@charpos2			int
	,@save_gears_id			int
	,@save_projectname		sysname
	,@save_projectnum		sysname
	,@save_requestdate		datetime
	,@save_startdate		datetime
	,@save_starttime		nvarchar(50)
	,@hold_starttime		nvarchar(50)
	,@save_environment		sysname
	,@hold_env			sysname
	,@save_notes			nvarchar(4000)
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
	,@save_subject			sysname
	,@save_message			nvarchar(500)
	,@save_gears_status		sysname
	,@save_req_status		sysname
	,@save_hours			char(2)
	,@save_minutes			char(2)
	,@save_domain			sysname
	,@approve_pw			sysname
	,@approve_stage_pw		sysname
	,@approve_prod_pw		sysname
	,@SQLname_override		sysname
	,@save_jobrestore		sysname
	,@SQLname_override_flag		char(1)
	,@companion_flag		char(1)
	,@save_reqdet3_domain		sysname


/*********************************************************************
 *                Initialization
 ********************************************************************/
Select @approve_pw = '%orion%'
Select @approve_stage_pw = '%asterism%'
Select @approve_prod_pw = '%betelgeuse%'


--  Create temp table
CREATE TABLE #temp_req (gears_id int
			,projectname sysname null
			,projectnum sysname null
			,requestdate datetime null
			,startdate datetime null
			,starttime nvarchar(50) null
			,environment sysname
			,notes nvarchar(4000))

CREATE TABLE #temp_reqdet (gears_id int)

CREATE TABLE #temp_reqdet2 (DBname sysname
			    ,component_option sysname null
			    ,build_number sysname null
			    ,component_restore sysname null
			    ,next_build sysname null)

CREATE TABLE #temp_reqdet2_save (DBname sysname
			    ,component_option sysname null
			    ,build_number sysname null
			    ,component_restore sysname null
			    ,next_build sysname null)

CREATE TABLE #temp_reqdet3 (APPLname sysname
			    ,BASEfolder sysname null
			    ,SQLname sysname null
			    ,domain sysname null)

CREATE TABLE #temp_resync (gears_id int
			    ,gears_status sysname null
			    ,req_status sysname null)

CREATE TABLE #temp_companion (DBname sysname
			    ,APPLname sysname null)

CREATE TABLE #temp_SQLname (SQLname sysname)
	

/****************************************************************
 *                MainLine
 ***************************************************************/

Print 'Start import process from Gears into DEPLcontrol.'

--------------------------------------------------------------------------------------------------------------------
--  Section to Import Requests  ------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------

--  Load temp table
--  Get requests with SQL components
Insert into #temp_req select distinct br.build_request_id, p.project_name, p.project_version, br.request_date, br.target_date, br.target_time, e.environment_name, convert(nvarchar(4000), br.notes)
from Gears.dbo.BUILD_REQUESTS br
    ,Gears.dbo.PROJECTS p
    ,Gears.dbo.ENVIRONMENT e
    ,Gears.dbo.BUILD_REQUEST_COMPONENTS brc
    ,Gears.dbo.COMPONENTS c
    ,Gears.dbo.COMPONENT_TYPE ct
where br.project_id = p.project_id
and br.environment_id = e.environment_id
and br.build_request_id = brc.build_request_id
and brc.component_id = c.component_id
and c.component_type_id = ct.component_type_id
and ct.component_type = 'DB'
and br.request_date > getdate()-5
and br.status not in ('complete', 'Cancelled')

--  Get requests with SQL as part of the comments or in the project name
Insert into #temp_req select distinct br.build_request_id, p.project_name, p.project_version, br.request_date, br.target_date, br.target_time, e.environment_name, convert(nvarchar(4000), br.notes)
from Gears.dbo.BUILD_REQUESTS br
    ,Gears.dbo.PROJECTS p
    ,Gears.dbo.ENVIRONMENT e
where br.project_id = p.project_id
and br.environment_id = e.environment_id
and (br.notes like '%sql%' or p.project_name like '%sql%')
and br.request_date > getdate()-1
and br.status not in ('complete', 'Cancelled')
and br.build_request_id not in (select gears_id from #temp_req)

--select * from #temp_req


-- Loop through #temp_req
If (select count(*) from #temp_req) > 0
   begin
	start_req:

	Select @save_Gears_id = (select top 1 gears_id from #temp_req order by gears_id)

	If exists(select 1 from dbo.request where gears_id = @save_Gears_id)
	   begin
		--  skip this gears request.  We already have it.
		goto skip_req
	   end

	Select @save_projectname = (select top 1 projectname from #temp_req where gears_id = @save_Gears_id)
	Select @save_projectnum = (select top 1 projectnum from #temp_req where gears_id = @save_Gears_id)
	Select @save_requestdate = (select top 1 requestdate from #temp_req where gears_id = @save_Gears_id)
	Select @save_startdate = (select top 1 startdate from #temp_req where gears_id = @save_Gears_id)
	Select @save_starttime = (select top 1 starttime from #temp_req where gears_id = @save_Gears_id)
	Select @save_environment = (select top 1 environment from #temp_req where gears_id = @save_Gears_id)
	Select @save_notes = (select top 1 notes from #temp_req where gears_id = @save_Gears_id)

	--  fix start time
	If @save_starttime not like '%:%'
	   begin
		Select @save_starttime = 'z' + @save_starttime
		goto skip_fixtime
	   end


	If @save_starttime like '%am%'
	   begin
		Select @hold_starttime = @save_starttime
		Select @save_starttime = replace(@save_starttime, 'am', '')
		Select @save_starttime = rtrim(ltrim(@save_starttime))
		Select @charpos = charindex(':', @save_starttime)
		If @charpos <> 0
		   begin
			Select @save_hours = substring(@save_starttime, 1, @charpos-1)
			Select @save_hours = left(@save_hours, 2)
			If len(@save_hours) = 0
			   begin
				Select @save_hours = '00'
			   end
			Else If len(@save_hours) = 1
			   begin
				Select @save_hours = '0' + @save_hours
			   end


			If @save_hours = 12
			   begin
				Select @save_hours = '00'
			   end


			Select @save_minutes = substring(@save_starttime, @charpos+1, 2)
			Select @save_minutes = rtrim(ltrim(@save_minutes))

			If len(@save_minutes) = 1 and @save_minutes in ('6', '7', '8', '9')
			   begin
				Select @save_minutes = '0' + rtrim(@save_minutes)
			   end
			Else If len(@save_minutes) = 1
			   begin
				Select @save_minutes = rtrim(@save_minutes) + '0'
			   end

			If convert(int, rtrim(@save_minutes)) > 59
			   begin
				Select @save_minutes = '00'
			   end

			Select @save_starttime = rtrim(@save_hours) + ':' + rtrim(@save_minutes)

		   end
		Else
		   begin
	 		Select @save_starttime = 'z' + @hold_starttime
			goto skip_fixtime
		   end
	   end
	Else If @save_starttime like '%pm%'
	   begin
		Select @hold_starttime = @save_starttime
		Select @save_starttime = replace(@save_starttime, 'pm', '')
		Select @save_starttime = rtrim(ltrim(@save_starttime))
		Select @charpos = charindex(':', @save_starttime)
		If @charpos <> 0
		   begin
			Select @save_hours = substring(@save_starttime, 1, @charpos-1)
			Select @save_hours = left(@save_hours, 2)
			If len(@save_hours) = 0
			   begin
				Select @save_hours = '12'
			   end
			Else If @save_hours in ('1', '01')
			   begin
				Select @save_hours = '13'
			   end
			Else If @save_hours in ('2', '02')
			   begin
				Select @save_hours = '14'
			   end
			Else If @save_hours in ('3', '03')
			   begin
				Select @save_hours = '15'
			   end
			Else If @save_hours in ('4', '04')
			   begin
				Select @save_hours = '16'
			   end
			Else If @save_hours in ('5', '05')
			   begin
				Select @save_hours = '17'
			   end
			Else If @save_hours in ('6', '06')
			   begin
				Select @save_hours = '18'
			   end
			Else If @save_hours in ('7', '07')
			   begin
				Select @save_hours = '19'
			   end
			Else If @save_hours in ('8', '08')
			   begin
				Select @save_hours = '20'
			   end
			Else If @save_hours in ('9', '09')
			   begin
				Select @save_hours = '21'
			   end
			Else If @save_hours = '10'
			   begin
				Select @save_hours = '22'
			   end
			Else If @save_hours = '11'
			   begin
				Select @save_hours = '23'
			   end


			Select @save_minutes = substring(@save_starttime, @charpos+1, 2)
			Select @save_minutes = rtrim(ltrim(@save_minutes))

			If len(@save_minutes) = 1 and @save_minutes in ('6', '7', '8', '9')
			   begin
				Select @save_minutes = '0' + rtrim(@save_minutes)
			   end
			Else If len(@save_minutes) = 1
			   begin
				Select @save_minutes = rtrim(@save_minutes) + '0'
			   end

			If convert(int, rtrim(@save_minutes)) > 59
			   begin
				Select @save_minutes = '00'
			   end

			Select @save_starttime = rtrim(@save_hours) + ':' + rtrim(@save_minutes)

		   end
		Else
		   begin
	 		Select @save_starttime = 'z' + @hold_starttime
			goto skip_fixtime
		   end
	   end
	Else If @save_starttime like '%:%'
	   begin
		Select @hold_starttime = @save_starttime
		Select @save_starttime = rtrim(ltrim(@save_starttime))
		Select @charpos = charindex(':', @save_starttime)
		If @charpos <> 0
		   begin
			Select @save_hours = substring(@save_starttime, 1, @charpos-1)
			Select @save_hours = left(@save_hours, 2)
			If len(@save_hours) = 0
			   begin
				Select @save_hours = '00'
			   end
			Else If len(@save_hours) = 1
			   begin
				Select @save_hours = '0' + @save_hours
			   end


			If @save_hours > 23
			   begin
				Select @save_hours = '00'
			   end


			Select @save_minutes = substring(@save_starttime, @charpos+1, 2)
			Select @save_minutes = rtrim(ltrim(@save_minutes))

			If len(@save_minutes) = 1 and @save_minutes in ('6', '7', '8', '9')
			   begin
				Select @save_minutes = '0' + rtrim(@save_minutes)
			   end
			Else If len(@save_minutes) = 1
			   begin
				Select @save_minutes = rtrim(@save_minutes) + '0'
			   end

			If convert(int, rtrim(@save_minutes)) > 59
			   begin
				Select @save_minutes = '00'
			   end

			Select @save_starttime = rtrim(@save_hours) + ':' + rtrim(@save_minutes)

		   end
		Else
		   begin
	 		Select @save_starttime = 'z' + @hold_starttime
			goto skip_fixtime
		   end
	   end



	skip_fixtime:

	--  One last start time fix
	Select @charpos = charindex(':', @save_starttime)
	If @charpos = 0
	   begin
		Select @save_starttime = '00' + @save_starttime
	   end
	Else If @charpos = 1
	   begin
		Select @save_starttime = '0' + @save_starttime
	   end



	--  If request is for Saturday or Sunday before 8:00PM, change the start date and time
	If datepart(dw, @save_startdate) = 7
	   begin
		Select @save_startdate = dateadd(day, 1, @save_startdate)
		Select @save_starttime = '20:00'
	   end
	Else If datepart(dw, @save_startdate) = 1 and @save_starttime < '20:00'
	   begin
		Select @save_starttime = '20:00'
	   end


	Select @miscprint = 'Import Gears ID : ' + convert(nvarchar(20), @save_Gears_id)
	Print @miscprint
	Insert into dbo.request values(@save_Gears_id
					,@save_projectname
					,@save_projectnum
					,@save_requestdate 
					,@save_startdate
					,@save_starttime
					,@save_environment
					,@save_notes
					,'n'
					,''
					,'Initializing'
					,getdate()
					)


	skip_req:

	Delete from #temp_req where gears_id = @save_Gears_id
	If (select count(*) from #temp_req) > 0
	   begin
		goto start_req
	   end


   end	

--select * from dbo.request



--------------------------------------------------------------------------------------------------------------------
--  Section to Import Request Details  -----------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------

--  Capture all the requests with status 'initializing'
delete from #temp_reqdet
Insert into #temp_reqdet select gears_id from dbo.request where status = 'Initializing'
--select * from #temp_reqdet


-- Loop through #temp_reqdet (Gears ticket numbers)
If (select count(*) from #temp_reqdet) > 0
   begin
	start_reqdet:

	Select @save_Gears_id = (select top 1 gears_id from #temp_reqdet order by gears_id)
	Select @save_projectname = (select top 1 projectname from dbo.request where gears_id = @save_Gears_id)
	Select @save_projectnum = (select top 1 projectnum from dbo.request where gears_id = @save_Gears_id)
	Select @save_environment = (select top 1 environment from dbo.request where gears_id = @save_Gears_id)

	Select @save_notes = (select top 1 notes from gears.dbo.BUILD_REQUESTS where build_request_id = @save_Gears_id)

	Select @SQLname_override = ''
	Select @SQLname_override_flag = 'n'

	--  Check to see if a specific target server was requested e.g. SQLname=(seapsqldba01) in the notes section
	If @save_notes is not null and @save_notes <> ''
	   begin
		Select @charpos = charindex('SQLname=(', @save_notes)
		If @charpos > 0
		   begin
			Select @charpos2 = charindex(')', @save_notes, @charpos+1)
	
			If @charpos2 > @charpos
			   begin
				Select @SQLname_override = substring(@save_notes, @charpos+9, @charpos2-@charpos-9)
				Select @SQLname_override = rtrim(ltrim(@SQLname_override))
				Select @SQLname_override_flag = 'y'
			   end
		   end
	   end

	--  Check SQLname Override to make sure it's a valid server
	If @SQLname_override_flag = 'y'
	   begin
		If not exists (select 1 from dbacentral.dbo.dba_serverinfo where sqlname = @SQLname_override and active = 'y')
		   begin
			Select @miscprint = 'DBA Error: SQLname Override not found in the central DBA_ServerInfo table: ' + @SQLname_override
			Print @miscprint
			Select @miscprint = '           Unable to import this gears request ' + convert(nvarchar(20), @save_Gears_id) + '.'
			Print @miscprint
			Print ''

			--  Send email to DBA
			Select @save_subject = 'DEPLcontrol Import Error:  SQLname Override not found in the central DBA_ServerInfo table ' + @SQLname_override
			Select @save_message = 'Unable to import this gears request ' + convert(nvarchar(20), @save_Gears_id) + '.'
			EXEC dbaadmin.dbo.dbasp_sendmail 
				--@recipients = 'jim.wilson@gettyimages.com',  
				@recipients = 'tssqldba@gettyimages.com',  
				@subject = @save_subject,
				@message = @save_message

			EXEC dbaadmin.dbo.dbasp_sendmail 
				@recipients = 'jdtorpedo58@gmail.com',  
				@subject = @save_subject,
				@message = @save_message

			goto skip_reqdet
		   end
	   end



	--  Capture DBnames for this Gears request
	Delete from #temp_reqdet2
	Insert into #temp_reqdet2 select c.component_name, brc.component_option, brc.build_number, brc.component_restore, brc.next_build 
	from Gears.dbo.BUILD_REQUEST_COMPONENTS brc
	,Gears.dbo.COMPONENTS c
	,Gears.dbo.COMPONENT_TYPE ct
	where brc.build_request_id = @save_Gears_id
	and brc.component_id = c.component_id
	and c.component_type_id = ct.component_type_id
	and ct.component_type = 'DB'
	--select * from #temp_reqdet2

	--  If this request has no SQL components, go to the next request
	If (select count(*) from #temp_reqdet2) = 0
	   begin
		goto skip_component
	   end
	   
	Delete from #temp_reqdet2_save
	Insert into #temp_reqdet2_save select * from #temp_reqdet2
	--select * from #temp_reqdet2_save


	-- Loop through #temp_reqdet2 (DBnames)
	If (select count(*) from #temp_reqdet2) > 0
	   begin
		start_reqdet2:

		Select @companion_flag = 'n'
		Select @save_DBname = (select top 1 DBname from #temp_reqdet2 order by DBname)

		If (select count(*) from dbo.db_BaseLocation where DB_name = @save_DBname and RSTRfolder not like '%sfp%') > 1
		   begin
			Select @companion_flag = 'y'
		   end

		Select @save_component_option = (select component_option from #temp_reqdet2 where DBname = @save_DBname)
		Select @save_build_number = (select build_number from #temp_reqdet2 where DBname = @save_DBname)
		Select @save_component_restore = (select component_restore from #temp_reqdet2 where DBname = @save_DBname)
		Select @save_next_build = (select next_build from #temp_reqdet2 where DBname = @save_DBname)
		Select @save_RestoreType = ''

		--  Get Build Type
		If @save_component_option like '%sprocs%'
		   begin
			select @save_BuildType = 'sproc_on'
		   end
		Else
		   begin
			select @save_BuildType = 'full_on'
		   end


		--  Check for restore
		Select @save_Restore = 'n'

		If @save_component_restore = 'on'
		   begin
			select @save_Restore = 'y'

			If @save_DBname in ('ProductCatalog', 'Bundle', 'Bundle20', 'DynamicSortOrder', 'MessageQueue')
			   begin
				Select @save_RestoreType = 'Override_Needed'
			   end
		   end

		If @save_BuildType like 'sproc%' or @save_environment like '%prod%'
		   begin
			select @save_Restore = 'n'
		   end



		--  check for build
		If @save_DBname in ('CRMexport')
		   begin
			select @save_Build = 'none'
			goto build_end
		   end

		If @save_build_number is not null and @save_build_number <> ''
		   begin
			select @save_Build = @save_build_number
			goto build_end
		   end

		If @save_next_build = 'on' or @save_component_option like '%Full Build%'
		   begin
			select @save_Build = 'next'
			goto build_end
		   end





		Select @save_Build = 'none'

		build_end:


		If @save_environment like 'stag%'
		   begin
			Select @hold_env = 'stag%'
		   end
		Else If @save_environment like 'candidate%'
		   begin
			Select @hold_env = 'candidate%'
		   end
		Else
		   begin
			Select @hold_env = '%' + @save_environment + '%'
		   end
			

		--  Capture details for this DBname
		If @SQLname_override_flag = 'n'
		   begin
			Delete from #temp_reqdet3
			Insert into #temp_reqdet3 select APPLname, BASEfolder, SQLname, domain 
			from dbo.Base_Appl_Info 
			where DBname = @save_DBname 
			and ENVnum like @hold_env 
			--select * from #temp_reqdet3
		   end
		Else
		   begin
			Delete from #temp_reqdet3
			
			Select @save_reqdet3_domain = (select top 1 DomainName from dbacentral.dbo.dba_serverinfo where SQLname = @SQLname_override)

			Insert into #temp_reqdet3 select APPLname, BASEfolder, @SQLname_override, @save_reqdet3_domain 
			from dbo.Base_Appl_Info 
			where DBname = @save_DBname 
			--select * from #temp_reqdet3
		   end



		--  Remove rows for companion DB's not in the request
		If @companion_flag = 'y'
		   begin
			Delete from #temp_companion
			Insert into #temp_companion select distinct CompanionDB_name, APPLname from dbo.Base_Appl_Info where DBname = @save_DBname
			--  If a companion DB is not in the request, create the request for all APPLnames related to this DB
			If exists (select 1 from #temp_companion c, #temp_reqdet2_save s where c.DBname = s.DBname)
			   begin
				Delete from #temp_companion where DBname not in (select DBname from #temp_reqdet2_save)
				Delete from #temp_reqdet3 where APPLname not in (select APPLname from #temp_companion)
			   end
		   end


		-- Loop through #temp_reqdet3 (Appl and SQLname info for this DBname - insert a row for each combination)
		If (select count(*) from #temp_reqdet3) = 0
		   begin
			Select @miscprint = 'DBA Error: APPLname and SQLSRVname not found for DB ' + @save_DBname + ' and environment ' + @hold_env + '.'
			Print @miscprint
			Select @miscprint = '           Unable to import this component for gears request ' + convert(nvarchar(20), @save_Gears_id) + '.'
			Print @miscprint
			Print ''

			--  Send email to DBA
			Select @save_subject = 'DEPLcontrol Import Error:  APPLname and SQLSRVname not found for DB ' + @save_DBname + ' and environment ' + @hold_env + '.'
			Select @save_message = 'Unable to import this component for gears request ' + convert(nvarchar(20), @save_Gears_id) + '.'
			EXEC dbaadmin.dbo.dbasp_sendmail 
				--@recipients = 'jim.wilson@gettyimages.com',  
				@recipients = 'tssqldba@gettyimages.com',  
				@subject = @save_subject,
				@message = @save_message

			EXEC dbaadmin.dbo.dbasp_sendmail 
				@recipients = 'jdtorpedo58@gmail.com',  
				@subject = @save_subject,
				@message = @save_message


			goto skip_reqdet2
		   end

		-- Loop through #temp_reqdet3 (Appl and SQLname info for this DBname - insert a row for each combination)
		If (select count(*) from #temp_reqdet3) > 0
		   begin
			start_reqdet3:
	    
			Select @save_APPLname = (select top 1 APPLname from #temp_reqdet3 order by APPLname)
			Select @save_BASEfolder = (select top 1 BASEfolder from #temp_reqdet3 where APPLname = @save_APPLname)

			If @SQLname_override is null or @SQLname_override = ''
			   begin
				Select @save_SQLname = (select top 1 SQLname from #temp_reqdet3 where APPLname = @save_APPLname and BASEfolder = @save_BASEfolder)
				Select @save_domain = (select top 1 domain from #temp_reqdet3 where APPLname = @save_APPLname and BASEfolder = @save_BASEfolder and SQLname = @save_SQLname)
				Select @save_jobrestore = 'JobRestore-y'
			   end
			Else
			   begin
				Select @save_SQLname = @SQLname_override
				Select @save_domain = (select top 1 DomainName from dbacentral.dbo.dba_serverinfo where SQLname = @save_SQLname)
				Select @save_jobrestore = 'JobRestore-n'

				If @save_domain is null or @save_domain = ''
				   begin
					Select @save_domain = 'unknown'
				   end
			   end



			If @save_APPLname is null or @save_APPLname = ''
			   begin
				select @save_APPLname = 'UNKNOWN'
			   end

			If @save_BASEfolder is null or @save_BASEfolder = ''
			   begin
				select @save_BASEfolder = 'UNKNOWN'
			   end

			If @save_SQLname is null or @save_SQLname = ''
			   begin
				select @save_SQLname = 'UNKNOWN'
			   end

			If @save_domain is null or @save_domain = ''
			   begin
				select @save_domain = 'UNKNOWN'
			   end


			--  Insert the restore data into the request_detail table
			If @save_Restore = 'y'
			   begin
				Select @miscprint = 'Import restore data for DBname ' + @save_DBname + ', APPLname ' + @save_APPLname + ', Gears ID : ' + convert(nvarchar(20), @save_Gears_id)
				Print @miscprint
				Insert into dbo.request_detail values(@save_Gears_id
								,'pending'
								,@save_DBname
								,@save_APPLname
								,@save_SQLname
								,@save_domain
								,@save_BASEfolder 
								,'Restore'
								,@save_RestoreType
								,''
								,getdate()
								)
			   end

			If @save_Build is not null and @save_Build <> '' and @save_Build <> 'none'
			   begin
				Select @miscprint = 'Import build data for DBname ' + @save_DBname + ', APPLname ' + @save_APPLname + ', Gears ID : ' + convert(nvarchar(20), @save_Gears_id)
				Print @miscprint
				Insert into dbo.request_detail values(@save_Gears_id
								,'pending'
								,@save_DBname
								,@save_APPLname
								,@save_SQLname
								,@save_domain
								,@save_BASEfolder 
								,'Deploy'
								,@save_BuildType
								,@save_Build
								,getdate()
								)
			   end



			Delete from #temp_reqdet3 where APPLname = @save_APPLname and BASEfolder = @save_BASEfolder and SQLname = @save_SQLname
			If (select count(*) from #temp_reqdet3) > 0
			   begin
				goto start_reqdet3
			   end

		   end


		skip_reqdet2:

		Delete from #temp_reqdet2 where DBname = @save_DBname
		If (select count(*) from #temp_reqdet2) > 0
		   begin
			goto start_reqdet2
		   end
	   end


	--  Create start and end detail rows for each SQLname in the request_detail table for this gears_id
	--  Load temp table
	Delete from #temp_SQLname
	Insert into #temp_SQLname select SQLname from dbo.request_detail where gears_id = @save_Gears_id
	--select * from #temp_SQLname

	If (select count(*) from #temp_SQLname) > 0
	   begin
		start_end_insert_01:

		Select @save_SQLname = (select top 1 SQLname from #temp_SQLname order by SQLname)
		Select @save_domain = (select top 1 Domain from dbo.request_detail where gears_id = @save_Gears_id and SQLname = @save_SQLname)

		Select @miscprint = 'Create start and end rows for SQL server ''' + @save_SQLname + ''', Gears ID : ' + convert(nvarchar(20), @save_Gears_id)
		Print @miscprint
		If @save_environment <> 'production' and exists(select 1 from dbo.request_detail 
									where gears_id = @save_Gears_id 
									and SQLname = @save_SQLname 
									and Process = 'Restore'
								)
		   begin
			Insert into dbo.request_detail values(@save_Gears_id
							,'pending'
							,''
							,''
							,@save_SQLname
							,@save_domain
							, ''
							,'start'
							,@save_jobrestore
							,''
							,getdate()
							)
		   end
		Else If @save_environment <> 'production' and exists(select 1 from dbo.request_detail 
									where gears_id = @save_Gears_id 
									and SQLname = @save_SQLname 
									and (Process = 'Deploy' 
									and ProcessType not like'%sproc%')
								)
		   begin
			Insert into dbo.request_detail values(@save_Gears_id
							,'pending'
							,''
							,''
							,@save_SQLname
							,@save_domain
							, ''
							,'start'
							,@save_jobrestore
							,''
							,getdate()
							)
		   end
		Else
		   begin
			Insert into dbo.request_detail values(@save_Gears_id
							,'pending'
							,''
							,''
							,@save_SQLname
							,@save_domain
							, ''
							,'start'
							,'JobRestore-n'
							,''
							,getdate()
							)
		   end

		Insert into dbo.request_detail values(@save_Gears_id
						,'pending'
						,''
						,''
						,@save_SQLname
						,@save_domain
						,'' 
						,'end'
						,''
						,''
						,getdate()
						)

		--  check for more rows to process
		Delete from #temp_SQLname where SQLname = @save_SQLname

		If (select count(*) from #temp_SQLname) > 0
		   begin
			goto start_end_insert_01
		   end

	   end


	skip_component:

	--  Now update the status for this Gears request in the request table
	update dbo.request set status = 'pending' where gears_id = @save_Gears_id


	skip_reqdet:

	Delete from #temp_reqdet where gears_id = @save_Gears_id
	If (select count(*) from #temp_reqdet) > 0
	   begin
		goto start_reqdet
	   end

   end	



--------------------------------------------------------------------------------------------------------------------
--  Section to Resync with Gears  ----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------

--  Load temp table
Insert into #temp_resync select br.build_request_id, br.status, r.Status
from Gears.dbo.BUILD_REQUESTS br
    ,dbo.request r
where br.build_request_id = r.Gears_id
and br.request_date > getdate()-30
and br.status in ('complete', 'completed', 'Cancelled')
and r.status not in ('complete', 'completed', 'Gears Completed', 'Cancelled', 'Gears Cancelled', 'Gears Canceled')
--select * from #temp_resync


If (select count(*) from #temp_resync) > 0
   begin
	start_resync:

	Select @save_Gears_id = (select top 1 gears_id from #temp_resync order by gears_id)
	Select @save_gears_status = (select gears_status from #temp_resync where gears_id = @save_Gears_id)
	Select @save_req_status = (select req_status from #temp_resync where gears_id = @save_Gears_id)

	If @save_req_status in ('pending', 'manual')
	   begin
		If @save_gears_status like 'Complete%'
		   begin
			Select @miscprint = 'Update gears_id ' + convert(nvarchar(10), @save_Gears_id) + ' with ''Gears Completed''.'
			Print @miscprint
			update dbo.request set Status = 'Gears Completed' where Gears_id = @save_Gears_id
			update dbo.request_detail set Status = 'Gears Completed' where Gears_id = @save_Gears_id
		   end
		Else If @save_gears_status like 'Cancel%'
		   begin
			Select @miscprint = 'Update gears_id ' + convert(nvarchar(10), @save_Gears_id) + ' with ''Gears Cancelled''.'
			Print @miscprint
			update dbo.request set Status = 'Gears Cancelled' where Gears_id = @save_Gears_id
			update dbo.request_detail set Status = 'Gears Cancelled' where Gears_id = @save_Gears_id
		   end
		Else
		   begin
			Select @miscprint = 'Update gears_id ' + convert(nvarchar(10), @save_Gears_id) + ' with ''Gears Unknown''.'
			Print @miscprint
			update dbo.request set Status = 'Gears Unknown' where Gears_id = @save_Gears_id
			update dbo.request_detail set Status = 'Gears Unknown' where Gears_id = @save_Gears_id
		   end
	   end
	Else If @save_req_status = 'in-work'
	   begin
		--  Send email to DBA
		Select @save_subject = 'DEPLcontrol Error:  Gears Request Closed for In-Work deployment ' + convert(nvarchar(10), @save_Gears_id)
		Select @save_message = 'The Gears request has been cancelled or closed for In-Work deployment ' + convert(nvarchar(10), @save_Gears_id)
		EXEC dbaadmin.dbo.dbasp_sendmail 
			--@recipients = 'jim.wilson@gettyimages.com',  
			@recipients = 'tssqldba@gettyimages.com',  
			@subject = @save_subject,
			@message = @save_message

			EXEC dbaadmin.dbo.dbasp_sendmail 
				@recipients = 'jdtorpedo58@gmail.com',  
				@subject = @save_subject,
				@message = @save_message

	   end



	skip_resync:

	Delete from #temp_resync where gears_id = @save_Gears_id
	If (select count(*) from #temp_resync) > 0
	   begin
		goto start_resync
	   end
   end



-----------------  Finalizations  ------------------

label99:

drop table #temp_req
drop table #temp_reqdet
drop table #temp_reqdet2
drop table #temp_reqdet2_save
drop table #temp_reqdet3
drop table #temp_resync
drop table #temp_companion
drop table #temp_SQLname









GO
EXEC sys.sp_addextendedproperty @name=N'BuildApplication', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'dpsp_ImportGears'
GO
EXEC sys.sp_addextendedproperty @name=N'BuildBranch', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'dpsp_ImportGears'
GO
EXEC sys.sp_addextendedproperty @name=N'BuildNumber', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'dpsp_ImportGears'
GO
EXEC sys.sp_addextendedproperty @name=N'DeplFileName', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'dpsp_ImportGears'
GO
EXEC sys.sp_addextendedproperty @name=N'Version', @value=N'1.0.0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'dpsp_ImportGears'
GO
