USE [DEPLcontrol]
GO
/****** Object:  StoredProcedure [dbo].[dpsp_ImportAHP]    Script Date: 10/4/2013 11:02:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[dpsp_ImportAHP]

/***************************************************************
 **  Stored Procedure dpsp_ImportAHP                  
 **  Written by Jim Wilson, Getty Images                
 **  August 8, 2010                                      
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
--	08/02/2010	Jim Wilson		New process.
--	09/15/2011	Jim Wilson		Updated central server name in comment.
--	======================================================================================

-----------------  declares  ------------------

DECLARE
	 @miscprint			nvarchar(2000)
	,@charpos			int
	,@charpos2			int
	,@save_request_id		int
	,@save_release_ver		sysname
	,@save_projectname		sysname
	,@save_projectnum		sysname
	,@save_requestdate		datetime
	,@save_startdate		datetime
	,@save_starttime		nvarchar(50)
	,@save_environment		sysname
	,@hold_env			sysname
	,@save_notes			nvarchar(4000)
	,@save_DBname			sysname
	,@save_build_number		sysname
	,@save_BuildFlag		char(1)
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
	,@save_Approval_KW		sysname
	,@save_message			nvarchar(500)
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
CREATE TABLE #temp_req (request_id int not null
			,release_ver sysname not null
			,DBname sysname null
			,RestoreFlag char(1) null
			,BuildFlag char(1) null
			,Buildnum sysname null
			,Environment sysname null
			,Approval_KW sysname null
			,ProcessNotes nvarchar(500) null
			,CreateDate datetime null)


CREATE TABLE #temp_reqdet (request_id int)

CREATE TABLE #temp_reqdet2 (DBname sysname
			    ,build_number sysname null
			    ,BuildFlag char(1) null
			    ,component_restore sysname null)

CREATE TABLE #temp_reqdet2_save (DBname sysname
			    ,build_number sysname null
			    ,BuildFlag char(1) null
			    ,component_restore sysname null)

CREATE TABLE #temp_reqdet3 (APPLname sysname
			    ,BASEfolder sysname null
			    ,SQLname sysname null
			    ,domain sysname null)

CREATE TABLE #temp_companion (DBname sysname
			    ,APPLname sysname null)

CREATE TABLE #temp_SQLname (SQLname sysname)
	

/****************************************************************
 *                MainLine
 ***************************************************************/

Print 'Start import process from AHP into DEPLcontrol.'

--------------------------------------------------------------------------------------------------------------------
--  Section to Import Requests  ------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------

-- First, set all rows with a status of "new" to a status of "importing"
If exists (select 1 from DeployMaster.dbo.AHP_requests where status = 'new' and CreateDate < getdate()-.0015)
   begin
	Update DeployMaster.dbo.AHP_requests set status = 'importing' where status = 'new' and CreateDate < getdate()-.0015
   end
Else
   begin
	Print 'No rows to process at this time.'
	goto label99
   end


--  Load temp table
--  Get requests from the AHP_requests table
Insert into #temp_req select request_id, release_ver, DBname, RestoreFlag, BuildFlag, Buildnum, Environment, Approval_KW, ProcessNotes, CreateDate
from DeployMaster.dbo.AHP_requests
where status = 'importing'
--select * from #temp_req


-- Loop through #temp_req
If (select count(*) from #temp_req) > 0
   begin
	start_req:

	Select @save_request_id = (select top 1 request_id from #temp_req order by request_id)

	If exists(select 1 from dbo.request where gears_id = @save_request_id)
	   begin
		--  skip this gears request.  We already have it.
		goto skip_req
	   end

	Select @save_release_ver = (select top 1 release_ver from #temp_req where request_id = @save_request_id)

	Select @save_projectname = @save_release_ver
	Select @charpos = charindex('_', @save_projectname)
	IF @charpos <> 0
	   begin
		Select @save_projectname = left(@save_projectname, @charpos-1)
	   end
		
	Select @save_projectnum = @save_release_ver
	Select @charpos = charindex('_', @save_projectnum)
	IF @charpos <> 0
	   begin
		Select @save_projectnum = substring(@save_projectnum, @charpos+1, len(@save_projectnum)-@charpos)
	   end
		
	Select @save_requestdate = (select top 1 CreateDate from #temp_req where request_id = @save_request_id)
	
	Select @save_environment = (select top 1 environment from #temp_req where request_id = @save_request_id)
	Select @save_Approval_KW = (select top 1 Approval_KW from #temp_req where request_id = @save_request_id)
	Select @save_notes = (select top 1 Processnotes from #temp_req where request_id = @save_request_id and DBname = 'Notes')
	If @save_notes is null
	   begin
		Select @save_notes = ''
	   end
	   
   	Select @save_Approval_KW = (select top 1 Approval_KW from #temp_req where request_id = @save_request_id)
   	If @save_Approval_KW is not null and @save_Approval_KW <> ''
   	   begin
   		Select @save_notes = @save_Approval_KW + ' ' + @save_notes
	   end

	
	If @save_environment = 'production'
	   begin
		--  Prod start time is always set for 1pm the following day.  This will be changed by the DBA within DEPLcontrol.
		Select @save_startdate = convert(nvarchar(10), getdate()+1, 120)
		Select @save_starttime = '13:00'	
	   end
	Else
	   begin
		Select @save_startdate = convert(nvarchar(10), getdate(), 120)
		Select @save_starttime = convert(nvarchar(16), getdate(), 120)
	   
		Select @charpos = charindex(' ', @save_starttime)
		IF @charpos <> 0
		   begin
			Select @save_starttime = substring(@save_starttime, @charpos+1, 5)
		   end
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




	Select @miscprint = 'Import Gears ID : ' + convert(nvarchar(20), @save_request_id)
	Print @miscprint
	Insert into dbo.request values(@save_request_id
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

	Delete from #temp_req where request_id = @save_request_id
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
Insert into #temp_req select request_id, release_ver, DBname, RestoreFlag, BuildFlag, Buildnum, Environment, Approval_KW, ProcessNotes, CreateDate
from DeployMaster.dbo.AHP_requests
where status = 'importing' 
and DBname <> 'notes'
--select * from #temp_req


-- Loop through #temp_req
If (select count(*) from #temp_req) > 0
   begin
	start_reqdet:

	Select @save_request_id = (select top 1 request_id from #temp_req order by request_id)

	Select @save_projectname = (select top 1 projectname from dbo.request where gears_id = @save_request_id)
	Select @save_projectnum = (select top 1 projectnum from dbo.request where gears_id = @save_request_id)
	Select @save_environment = (select top 1 environment from dbo.request where gears_id = @save_request_id)

	If @save_notes is null or @save_notes = ''
	   begin
		Select @save_notes = (select top 1 notes from dbo.request where gears_id = @save_request_id)
	   end

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
			Select @miscprint = '           Unable to import this gears request ' + convert(nvarchar(20), @save_request_id) + '.'
			Print @miscprint
			Print ''

			--  Send email to DBA
			Select @save_subject = 'DEPLcontrol Import Error:  SQLname Override not found in the central DBA_ServerInfo table ' + @SQLname_override
			Select @save_message = 'Unable to import this gears request ' + convert(nvarchar(20), @save_request_id) + '.'
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
			    
			    
	--  Capture DBnames for this request
	Delete from #temp_reqdet2
	Insert into #temp_reqdet2 select DBname, Buildnum, BuildFlag, RestoreFlag
	from DeployMaster.dbo.AHP_requests
	where request_id = @save_request_id
	and DBname <> 'notes'
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

		Select @save_build_number = (select build_number from #temp_reqdet2 where DBname = @save_DBname)
		Select @save_BuildFlag = (select BuildFlag from #temp_reqdet2 where DBname = @save_DBname)
		Select @save_component_restore = (select component_restore from #temp_reqdet2 where DBname = @save_DBname)
		Select @save_next_build = ''
		Select @save_RestoreType = ''


		--  Get Build Type
		If @save_BuildFlag like '%s%'
		   begin
			select @save_BuildType = 'sproc_on'
		   end
		Else
		   begin
			select @save_BuildType = 'full_on'
		   end


		--  Check for restore
		Select @save_Restore = 'n'

		If @save_component_restore = 'y'
		   begin
			select @save_Restore = 'y'

			If @save_DBname in ('ProductCatalog', 'Bundle', 'DynamicSortOrder')
			   begin
				Select @save_RestoreType = 'Override_Needed'
			   end
		   end

		If @save_BuildType like 'sproc%' or @save_environment like '%prod%'
		   begin
			select @save_Restore = 'n'
		   end



		--  check for build
		If @save_BuildFlag = 'n'
		   begin
			Select @save_Build = 'none'
			goto build_end
		   end

		If @save_build_number is not null and @save_build_number <> ''
		   begin
			If @save_build_number like '%next%'
			   begin
				select @save_Build = 'next'
				goto build_end
			   end
			Else
			   begin
				select @save_Build = @save_build_number
				goto build_end
			   end
		   end
		   

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
			Select @miscprint = '           Unable to import this component for gears request ' + convert(nvarchar(20), @save_request_id) + '.'
			Print @miscprint
			Print ''

			--  Send email to DBA
			Select @save_subject = 'DEPLcontrol Import Error:  APPLname and SQLSRVname not found for DB ' + @save_DBname + ' and environment ' + @hold_env + '.'
			Select @save_message = 'Unable to import this component for gears request ' + convert(nvarchar(20), @save_request_id) + '.'
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
				Select @miscprint = 'Import restore data for DBname ' + @save_DBname + ', APPLname ' + @save_APPLname + ', Gears ID : ' + convert(nvarchar(20), @save_request_id)
				Print @miscprint
				Insert into dbo.request_detail values(@save_request_id
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
				Select @miscprint = 'Import build data for DBname ' + @save_DBname + ', APPLname ' + @save_APPLname + ', Gears ID : ' + convert(nvarchar(20), @save_request_id)
				Print @miscprint
				Insert into dbo.request_detail values(@save_request_id
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


	--  Create start and end detail rows for each SQLname in the request_detail table for this request_id
	--  Load temp table
	Delete from #temp_SQLname
	Insert into #temp_SQLname select SQLname from dbo.request_detail where gears_id = @save_request_id
	--select * from #temp_SQLname

	If (select count(*) from #temp_SQLname) > 0
	   begin
		start_end_insert_01:

		Select @save_SQLname = (select top 1 SQLname from #temp_SQLname order by SQLname)
		Select @save_domain = (select top 1 Domain from dbo.request_detail where gears_id = @save_request_id and SQLname = @save_SQLname)

		Select @miscprint = 'Create start and end rows for SQL server ''' + @save_SQLname + ''', Gears ID : ' + convert(nvarchar(20), @save_request_id)
		Print @miscprint
		If @save_environment <> 'production' and exists(select 1 from dbo.request_detail 
									where gears_id = @save_request_id 
									and SQLname = @save_SQLname 
									and Process = 'Restore'
								)
		   begin
			Insert into dbo.request_detail values(@save_request_id
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
									where gears_id = @save_request_id 
									and SQLname = @save_SQLname 
									and (Process = 'Deploy' 
									and ProcessType not like'%sproc%')
								)
		   begin
			Insert into dbo.request_detail values(@save_request_id
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
			Insert into dbo.request_detail values(@save_request_id
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

		Insert into dbo.request_detail values(@save_request_id
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

	--  Now update the status for this AHP request in the request table
	Update dbo.request set status = 'pending' where gears_id = @save_request_id
	Update DeployMaster.dbo.AHP_requests set status = 'pending' where status = 'importing'


	skip_reqdet:
	
	Delete from #temp_req where request_id = @save_request_id
	If (select count(*) from #temp_req) > 0
	   begin
		goto start_reqdet
	   end

   end	



-----------------  Finalizations  ------------------

label99:

drop table #temp_req
drop table #temp_reqdet
drop table #temp_reqdet2
drop table #temp_reqdet2_save
drop table #temp_reqdet3
drop table #temp_companion
drop table #temp_SQLname





GO
