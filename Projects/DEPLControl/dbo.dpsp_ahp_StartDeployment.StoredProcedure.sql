USE [DEPLcontrol]
GO
/****** Object:  StoredProcedure [dbo].[dpsp_ahp_StartDeployment]    Script Date: 10/4/2013 11:02:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[dpsp_ahp_StartDeployment] (@RequestID int = null
					,@TargetSQLname sysname = null
					,@ManualOverride char(1) = 'n'
					,@Automode char(1) = 'n')

/*********************************************************
 **  Stored Procedure dpsp_ahp_StartDeployment                  
 **  Written by Jim Wilson, Getty Images                
 **  October 28, 2010                                      
 **  
 **  This sproc will start local SQL deployments based on data
 **  in the AHP_Import_Requests table.
 **
 ***************************************************************/
  as
set nocount on

--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	10/22/2010	Jim Wilson		New process.
--	03/04/2011	Jim Wilson		Updated manual override process.
--	05/12/2011	Jim Wilson		Added scriptall and example help.
--	======================================================================================


/***
Declare @RequestID int
Declare @TargetSQLname sysname
Declare @ManualOverride char(1)
Declare @Automode char(1)

Select @RequestID = 50475
Select @TargetSQLname = 'ScriptAll'
Select @ManualOverride = 'n'
Select @Automode = 'n'
--***/

-----------------  declares  ------------------

DECLARE
	 @miscprint			nvarchar(2000)
	,@query				nvarchar(2000)
	,@cmd				nvarchar(4000)
	,@charpos			int
	,@returncode			int
	,@save_servername		sysname
	,@save_servername2		sysname
	,@save_servername3		sysname
	,@save_Request_id		int
	,@save_TargetSQLname		sysname
	,@save_SQLport			sysname
	,@examples			char(1)
	,@scriptall_flag		char(1)



/*********************************************************************
 *                Initialization
 ********************************************************************/
Select @examples		= 'n'
Select @scriptall_flag 		= 'n'
Select @save_servername		= @@servername
Select @save_servername2	= @@servername
Select @save_servername3	= @@servername

Select @charpos = charindex('\', @save_servername)
IF @charpos <> 0
   begin
	Select @save_servername = substring(@@servername, 1, (CHARINDEX('\', @@servername)-1))

	Select @save_servername2 = stuff(@save_servername2, @charpos, 1, '$')

	select @save_servername3 = stuff(@save_servername3, @charpos, 1, '(')
	select @save_servername3 = @save_servername3 + ')'
   end



--  Create temp tables
CREATE TABLE #requests (Request_id int
			,SQLname sysname)



--  Check for rows to process
If not exists (select 1 from dbo.AHP_Import_Requests where Request_Status in ('Local_Inserted', 'Prod_Inserted', 'Local_Inserted_manual', 'Prod_Inserted_manual'))
   begin
	goto label99
   end


----------------------  Print the headers  ----------------------

Print  ' '
Select @miscprint = 'SQL AHP Start Deployment Process from Server: ' + @@servername
Print  @miscprint
Select @miscprint = '-- Process run: ' + convert(varchar(30),getdate())
Print  @miscprint
Print  ' '
raiserror('', -1,-1) with nowait



--  "Script all" process
If @TargetSQLname = 'ScriptAll'
   begin

	Select	@miscprint = '--  Info: @TargetSQLname specified keyword "ScriptAll".' 
	Print	@miscprint
	Print	''
	SET	@cmd = ''
	select	@cmd	= @cmd 
					+ '--exec DEPLcontrol.dbo.dpsp_ahp_StartDeployment @RequestID = '
					+ CAST(@RequestID AS VarChar(20))
					+ ', @TargetSQLname = '''
					+ d.TargetSQLname
					+ ''', @ManualOverride = ''Y'';'
					+ CHAR(13) + CHAR(10)
					+ 'GO'
					+ CHAR(13) + CHAR(10)+ CHAR(13) + CHAR(10)
	FROM	(
			SELECT	DISTINCT
					TargetSQLname 				
			From	dbo.AHP_Import_Requests d
			WHERE	Request_id = @RequestID
				and	Request_Status like '%manual%'
			) d
	PRINT (@CMD)

	goto label99
   end  



--  If no input parms, go to end and print examples
If @ManualOverride = 'y' and (@TargetSQLname = '' or @TargetSQLname is null or @RequestID is null)
   begin
	Select @examples = 'y'
	goto label99
   end

If @ManualOverride = 'n' and @Automode = 'n'
   begin
	Select @examples = 'y'
	goto label99
   end




/****************************************************************
 *                MainLine
 ***************************************************************/


If @ManualOverride <> 'n'
   begin
	goto manual_process
   end

   
--  Auto section
--  Get the Request_id/SQLname rows that need to be processed
delete from #requests
Insert into #requests select Request_id, TargetSQLname from dbo.AHP_Import_Requests where Request_Status in ('Local_Inserted', 'Prod_Inserted') 
--select * from #requests

-- Loop through #requests
If (select count(*) from #requests) > 0
   begin 
	start01:

	Select @save_Request_id = (select top 1 Request_id from #requests order by Request_id)
	Select @save_TargetSQLname = (select top 1 SQLname from #requests where Request_id = @save_Request_id order by Request_id)
	Select @save_SQLport = (select top 1 port from dbacentral.dbo.dba_serverinfo where sqlname = @save_TargetSQLname)


	--  Make sure all rows for this request/sqlname have been inserted to the local server
	If exists (select 1 from dbo.AHP_Import_Requests where Request_id = @save_Request_id 
							and TargetSQLname = @save_TargetSQLname
							and Request_Status not in ('Local_Inserted', 'Prod_Inserted', 'completed'))
	   begin
		Select @miscprint = 'Unmatched status found in table DEPLcontrol.dbo.AHP_Import_Requests for Request_id: ' + convert(nvarchar(20), @save_Request_id) + ' and SQLname: ' + @save_TargetSQLname
		Print  @miscprint
		Print  ' '
		raiserror('', -1,-1) with nowait
		goto skip01
	   end

	--  Start the local SQL Deployment Process
	Select @miscprint = 'Starting SQL job "DEPL_ahp - SQL Deployment Process" for Request_id ' + convert(nvarchar(20), @save_Request_id) + ' and SQLname ' + @save_TargetSQLname + '.'
	Print  @miscprint
	raiserror('', -1,-1) with nowait

	select @query = 'exec msdb.dbo.sp_start_job @job_name = ''DEPL_ahp - SQL Deployment Process'''
	Print @query
	raiserror('', -1,-1) with nowait
	Select @cmd = 'sqlcmd -S' + @save_TargetSQLname + ',' + @save_SQLport + ' -dmaster -E -Q"' + @query + '"'
	print @cmd
	raiserror('', -1,-1) with nowait

	EXEC @returncode = master.sys.xp_cmdshell @cmd--, no_output

	If @returncode <> 0
	   begin
		Select @miscprint = 'Unable to start SQL job "DEPL_ahp - SQL Deployment Process" for Request_id ' + convert(nvarchar(20), @save_Request_id) + ' and SQLname ' + @save_TargetSQLname + '.'
		Print  @miscprint
		raiserror('', -1,-1) with nowait
		goto skip01
	   end
	Else
	   begin
		Update dbo.AHP_Import_Requests set Request_Status = 'Pending' where Request_id = @save_Request_id and TargetSQLname = @save_TargetSQLname and Request_Status in ('Local_Inserted', 'Prod_Inserted')
	   end



	skip01:
	
	--  Check for more rows to process
	delete from #requests where Request_id = @save_Request_id and SQLname = @save_TargetSQLname
	If (select count(*) from #requests) > 0
	   begin
		goto start01
	   end
   end


--  exit for auto processing
goto label99

 


   
--  Manual section
manual_process:

If @RequestID is null or @TargetSQLname is null
   begin
	Select @miscprint = 'DBA Error:  No Request ID or Target SQL name provided. Unable to process this request.'
	Print  @miscprint
	raiserror('', -1,-1) with nowait
	goto label99
   end
   
Select @save_Request_id = @RequestID
Select @save_TargetSQLname = @TargetSQLname
Select @save_SQLport = (select top 1 port from dbacentral.dbo.dba_serverinfo where sqlname = @save_TargetSQLname)

--  Make sure all rows for this request/sqlname have been inserted to the local server
If exists (select 1 from dbo.AHP_Import_Requests where Request_id = @save_Request_id 
						and TargetSQLname = @save_TargetSQLname
						and Request_Status not in ('Local_Inserted_manual', 'Prod_Inserted_manual', 'completed'))
   begin
	Select @miscprint = 'Unmatched status for Production request found in table DEPLcontrol.dbo.AHP_Import_Requests for Request_id: ' + convert(nvarchar(20), @save_Request_id) + ' and SQLname: ' + @save_TargetSQLname
	Print  @miscprint
	Print  ' '
	raiserror('', -1,-1) with nowait
	goto label99
   end

--  Start the local SQL Deployment Process
Select @miscprint = 'Starting SQL job "DEPL_ahp - SQL Deployment Process" for Request_id ' + convert(nvarchar(20), @save_Request_id) + ' and SQLname ' + @save_TargetSQLname + '.'
Print  @miscprint
raiserror('', -1,-1) with nowait

select @query = 'exec msdb.dbo.sp_start_job @job_name = ''DEPL_ahp - SQL Deployment Process'''
Print @query
raiserror('', -1,-1) with nowait
Select @cmd = 'sqlcmd -S' + @save_TargetSQLname + ',' + @save_SQLport + ' -dmaster -E -Q"' + @query + '"'
print @cmd
raiserror('', -1,-1) with nowait

EXEC @returncode = master.sys.xp_cmdshell @cmd--, no_output

If @returncode <> 0
   begin
	Select @miscprint = 'Unable to start SQL job "DEPL_ahp - SQL Deployment Process" for Request_id ' + convert(nvarchar(20), @save_Request_id) + ' and SQLname ' + @save_TargetSQLname + '.'
	Print  @miscprint
	raiserror('', -1,-1) with nowait
	goto label99
   end
Else
   begin
	Update dbo.AHP_Import_Requests set Request_Status = 'Pending' where Request_id = @save_Request_id and TargetSQLname = @save_TargetSQLname and Request_Status in ('Local_Inserted_manual', 'Prod_Inserted_manual')
   end





-----------------  Finalizations  ------------------

label99:

drop TABLE #requests

If @examples = 'y'
   begin
	Print  ' '
	Print  ' '
	Select @miscprint = '-- Here is a sample execute command for this sproc:'
	Print  @miscprint
	Print  ' '
	Select @miscprint = '-- To Start a single Instance:'
	Print  @miscprint
	Print  ' '
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_ahp_StartDeployment @RequestID = 12345, @TargetSQLname = ''servername\a'', @ManualOverride = ''y'''
	Print  @miscprint
	Print  'go'
	Print  ' '
	Select @miscprint = '-- To script the code for all Instances:'
	Print  @miscprint
	Print  ' '
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_ahp_StartDeployment @RequestID = 12345, @TargetSQLname = ''ScriptAll'''
	Print  @miscprint
	Print  'go'
	Print  ' '		
   end







GO
