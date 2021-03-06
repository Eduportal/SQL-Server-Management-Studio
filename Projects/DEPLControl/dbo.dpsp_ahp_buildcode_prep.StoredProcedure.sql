USE [DEPLcontrol]
GO
/****** Object:  StoredProcedure [dbo].[dpsp_ahp_buildcode_prep]    Script Date: 10/4/2013 11:02:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[dpsp_ahp_buildcode_prep] (@BuildLabel sysname = null
						,@ReleaseNum sysname = null
						,@TargetPath nvarchar(500) = null
						,@output_path sysname = 'e:\builds\VSTS_Source')

/*********************************************************
 **  Stored Procedure dpsp_ahp_buildcode_prep                  
 **  Written by Jim Wilson, Getty Images                
 **  November 05, 2010                                      
 **  
 **  This procedure is used to prep build code delivered
 **  by AHP for the SQL deployment process.
 **
 **  This proc accepts the following input parms:
 **  - @BuildLabel  indicates the requested label (top level folder name).
 **  - @ReleaseNum gives us the release number.
 **  - @TargetPath is the path the build code has been copied to.
 **  - @output_path is the path the build code will be copied to.
 **
 ***************************************************************/
  as
  SET NOCOUNT ON

--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	11/05/2010	Jim Wilson		Old Deploymaster process rewritten.
--	09/28/2011	Jim Wilson		Update folder security with xcacls.
--	05/08/2012	Jim Wilson		New Changelist delete process.
--	======================================================================================


/***
declare @BuildLabel sysname
declare @ReleaseNum sysname
declare @TargetPath nvarchar(500)
declare @output_path sysname

select @BuildLabel = 'TranscoderDB_Main_20101105.3753x'
select @ReleaseNum = '14.0'
select @TargetPath = 'e:\builds\VSTS_Source\AHP_Builds'
select @output_path = 'e:\builds\VSTS_Source'
--***/



-----------------  declares  ------------------
DECLARE 
	 @miscprint			NVARCHAR(4000)
	,@cmd				Nvarchar(4000)
	,@result			int
	,@charpos			int
	,@error_count			int
	,@temp_path			nvarchar(500)
	,@dayone_path			nvarchar(500)
	,@largefile_path		nvarchar(500)
	,@temp_path1			nvarchar(500)
	,@temp_path2			nvarchar(500)
	,@recipients			sysname
	,@subject			sysname
	,@message			nvarchar(4000)
	,@codetype			sysname
	,@first_build_flag		char(1)
	,@largefile_flag		char(1)
	,@save_chgfolder		nvarchar(255)
	,@save_chgpath01		nvarchar(500)
	,@save_chgpath02		nvarchar(500)
	,@save_rowout			nvarchar(500)
	,@save_dbname			sysname
	,@save_DayOne_label		sysname
	,@save_BuildLabel		sysname
	,@save_ReleaseNum		sysname
	,@save_projectname		sysname
	,@save_TopFolderName		sysname
	,@save_project_header		sysname
	,@save_TargetPath		nvarchar(500)
	,@save_bc_id			int
	,@save_filetype			sysname
	,@save_chglist_delete		nvarchar(500)
	,@hold_chglist_delete		nvarchar(500)



----------------  initial values  -------------------
Select @recipients = 'tssqldba@gettyimages.com'
Select @largefile_path = '\\devtestdeploy01\Large_Data'


Select @error_count = 0


--  Create temp tables
Create table #DirectoryTempTable(cmdoutput nvarchar(255) null)
Create table #DirectoryTempTable2(cmdoutput nvarchar(255) null)
Create table #DirectoryTempTable3(cmdoutput nvarchar(255) null)
Create table #dbachangelist(change_file nvarchar(500) null)
Create table #dbachangelist3(change_file nvarchar(500) null)

Create table #fileexists ( 
	doesexist smallint,
	fileindir smallint,
	direxist smallint)
	
create table #file_Info(detail nvarchar(4000) null)

Create table #largefiles ( 
	DBname sysname,
	Project sysname,
	Release sysname,
	FileType sysname)



start01:

Select @largefile_flag = 'n'
Select @first_build_flag = 'n'

--  Get data to process
If @BuildLabel is not null and @ReleaseNum is not null
   begin
	Select @save_BuildLabel = @BuildLabel
	Select @save_ReleaseNum = @ReleaseNum
	Select @save_TargetPath = @TargetPath
   end
Else If exists (select 1 from dbo.AHPbuildcode_prep where Status = 'pending')
   begin
	Select @save_bc_id = (select top 1 bc_id from dbo.AHPbuildcode_prep where CreateDate is not null and InWorkDate is null and CompletedDate is null)
	Select @save_BuildLabel = (select BuildLabel from dbo.AHPbuildcode_prep where bc_id = @save_bc_id)
	Select @save_ReleaseNum = (select ReleaseNum from dbo.AHPbuildcode_prep where bc_id = @save_bc_id)
	Select @save_TargetPath = (select TargetPath from dbo.AHPbuildcode_prep where bc_id = @save_bc_id)
   end
Else
   begin
	Select @miscprint = 'DBA Note: No data to process at this time.  '
	Print  @miscprint
	goto label99
   end



--  Insert row into AHPbuildcode_prep if it does not exist
If not exists (select 1 from dbo.AHPbuildcode_prep where BuildLabel = @save_BuildLabel)
   begin
	insert into AHPbuildcode_prep values (@save_BuildLabel, @save_ReleaseNum, @save_TargetPath, 'Pending', getdate(), null, null)
	Select @save_bc_id = (select top 1 bc_id from dbo.AHPbuildcode_prep where BuildLabel = @save_BuildLabel)
   end



--  Verify the target folder exists
select @cmd = 'dir ' + rtrim(@save_TargetPath) + '\' + rtrim(@save_BuildLabel)
Select @cmd = @cmd  + ' /AD /B'
print @cmd

delete from #DirectoryTempTable
insert into #DirectoryTempTable exec master.sys.xp_cmdshell @cmd
delete from #DirectoryTempTable where cmdoutput is null
--select * from #DirectoryTempTable

If exists (select 1 from #DirectoryTempTable where cmdoutput like '%File Not Found%')
   begin
	update top (1) dbo.AHPbuildcode_prep set Status = 'cancelled', InWorkDate = getdate(), CompletedDate = getdate() where bc_id = @save_bc_id

	Select @miscprint = 'DBA ERROR: Target folder not found.  Check path to Target Folder.'
	Print  @miscprint
	Select @error_count = @error_count + 1
	goto error_process
   end
   




--  Set codetype
If @save_BuildLabel like '%[_]main[_]%'
   begin
	Select @codetype = 'MAIN'
   end
Else If @save_BuildLabel like '%[_]ps[_]%'
   begin
	Select @codetype = 'PS'
   end
Else
   begin
	update top (1) dbo.AHPbuildcode_prep set Status = 'cancelled', InWorkDate = getdate(), CompletedDate = getdate() where bc_id = @save_bc_id

	Print @save_BuildLabel
	Select @miscprint = 'DBA ERROR: Invalid input parm for @BuildLabel provided.  Unable to determine MAIN of PS codeline type.'
	Print  @miscprint
	Select @error_count = @error_count + 1
	goto error_process
   end


--  Get the project name and number
print @save_BuildLabel
select @charpos = charindex('_', @save_BuildLabel)
If @charpos <> 0
   begin
	Select @save_projectname = substring(@save_BuildLabel, 1, @charpos-1)
   end
   
   
--  Set the large file flag
If exists (select 1 from dbo.LargeFile_Override where Project = @save_projectname and (Release = 'All' or Release =@save_ReleaseNum))
   begin
	Select @largefile_flag = 'y'
   end



--  Set this row to in-work
update top (1) dbo.AHPbuildcode_prep set Status = 'in-work', InWorkDate = getdate() where bc_id = @save_bc_id


/****************************************************************
 *                MainLine
 ***************************************************************/

--------------------------------------------------
--  reset folder security
--------------------------------------------------
print '--  Reset Folder Security'

Select @cmd = 'XCACLS "' + rtrim(@save_TargetPath) + '\' + rtrim(@save_BuildLabel) + '" /T /G "Administrators":F /Y'
Print @cmd	
EXEC master.sys.xp_cmdshell @cmd--, no_output 

Select @cmd = 'XCACLS "' + rtrim(@save_TargetPath) + '\' + rtrim(@save_BuildLabel) + '" /T /E /G "NT AUTHORITY\SYSTEM":R /Y'
Print @cmd	
EXEC master.sys.xp_cmdshell @cmd--, no_output 



--------------------------------------------------
--  rename the top level folder (add prefix Databases_14.1_b)
--------------------------------------------------
Select @save_project_header = rtrim(@save_projectname) + '_' + rtrim(@save_ReleaseNum)
Select @save_TopFolderName = @save_project_header + '_b' + @save_BuildLabel
print @save_TopFolderName
Select @cmd = 'REN ' + rtrim(@save_TargetPath) + '\' + rtrim(@save_BuildLabel) + ' ' + @save_TopFolderName
Print @cmd	
EXEC master.sys.xp_cmdshell @cmd--, no_output 


--------------------------------------------------
--  Create a new Release folder if needed
--------------------------------------------------
Select @temp_path = @output_path + '\' + @save_project_header
Delete from #fileexists
Insert into #fileexists exec master.sys.xp_fileexist @temp_path

If not exists (select direxist from #fileexists where fileindir = 1)
   begin
	Select @cmd = 'mkdir "' + @output_path + '\' + @save_project_header + '"'
	Print '  Creating the SQL Project folder using command '+ @cmd
	EXEC @Result = master.sys.xp_cmdshell @cmd--, no_output 

	Select @first_build_flag = 'y'
   end


--------------------------------------------------
--  If this is the first build for this project, create the new folder in the DayOne folder
--------------------------------------------------
If @first_build_flag = 'y'
   begin
	Select @dayone_path = @output_path + '\DayOne\' + @save_TopFolderName
	Delete from #fileexists
	Insert into #fileexists exec master.sys.xp_fileexist @dayone_path

	If not exists (select direxist from #fileexists where fileindir = 1)
	   begin
		Select @cmd = 'mkdir "' + @dayone_path + '"'
		Print 'Creating the DayOne SQL Project folder using command '+ @cmd
		EXEC master.sys.xp_cmdshell @cmd--, no_output 
	   
		Print 'Robocopy the new build code to the DayOne folder using the following command'
		Select @cmd = 'robocopy ' + rtrim(@save_TargetPath) + '\' + rtrim(@save_TopFolderName) + ' ' + @dayone_path + ' *.* /E'
		Print @cmd
		EXEC master.sys.xp_cmdshell @cmd--, no_output
	   end
   end
   
   

--------------------------------------------------
--  If the DayOne build is not in place, notify DBA
--------------------------------------------------
--  Get the folders from the new build code
select @cmd = 'dir ' + @output_path + '\DayOne'
Select @cmd = @cmd  + ' /AD /B'

delete from #DirectoryTempTable
insert into #DirectoryTempTable exec master.sys.xp_cmdshell @cmd
delete from #DirectoryTempTable where cmdoutput is null
delete from #DirectoryTempTable where cmdoutput not like '%' + @save_project_header + '_b%'
--select * from #DirectoryTempTable

If (select count(*) from #DirectoryTempTable) > 0
   begin
	Select @save_DayOne_label = (select top 1 cmdoutput from #DirectoryTempTable order by cmdoutput)
   end
Else
   begin
	Select @save_DayOne_label = 'Empty_save'

   	Print 'Email being sent.'
   	
   	Select @subject = 'DBA TFS Pull Build Code Error on ' + @@servername + ' - No DayOne build found'
	Select @message = 'The DayOne build code for ' + @save_TopFolderName + ' could not be found'

	EXEC dbaadmin.dbo.dbasp_sendmail 
	@recipients = 'tssqldba@gettyimages.com', 
	@subject = @subject,
	@message = @message

   	Print 'Gmail being sent.'
	EXEC dbaadmin.dbo.dbasp_sendmail 
	@recipients = 'jwilson.getty@gmail.com', 
	@subject = @subject,
	@message = @message
   end



--------------------------------------------------
--  Create DBA_changelist files for each DB folder
--------------------------------------------------
--  Get the folders from the new build code
select @cmd = 'dir ' + rtrim(@save_TargetPath) + '\' + rtrim(@save_TopFolderName)
Select @cmd = @cmd  + ' /AD /B'

delete from #DirectoryTempTable
insert into #DirectoryTempTable exec master.sys.xp_cmdshell @cmd
delete from #DirectoryTempTable where cmdoutput is null
--select * from #DirectoryTempTable


--  Get the folders from the DayOne build code
select @cmd = 'dir ' + @output_path + '\DayOne\' + @save_DayOne_label
Select @cmd = @cmd  + ' /AD /B'

delete from #DirectoryTempTable2
insert into #DirectoryTempTable2 exec master.sys.xp_cmdshell @cmd
delete from #DirectoryTempTable2 where cmdoutput is null
--select * from #DirectoryTempTable2


--  Create the new DBA_changelist.txt file using our Directory Compare function
If (select count(*) from #DirectoryTempTable) > 0
   begin
	start_DBAchangelist01:

	Select @save_chgfolder = (select top 1 cmdoutput from #DirectoryTempTable order by cmdoutput)

	Print 'Create DBA_changelist.txt for DB ' + @save_chgfolder

	If exists (select 1 from #DirectoryTempTable2 where cmdoutput = @save_chgfolder)
	   begin
		Select @save_chgpath01 = @output_path + '\AHP_Builds\' + @save_TopFolderName + '\' + @save_chgfolder + '\'
		Select @save_chgpath02 = @output_path + '\DayOne\' + @save_DayOne_label + '\' + @save_chgfolder + '\'
	   end
	Else
	   begin
		Select @save_chgpath01 = @output_path + '\AHP_Builds\' + @save_TopFolderName + '\' + @save_chgfolder + '\'
		Select @save_chgpath02 = @output_path + '\DayOne\Empty_save\'
	   end
	
	Print @save_chgpath01
	Print @save_chgpath02
	   
	Select @cmd = 'echo.>>' + @save_chgpath01 + 'DBA_changelist.txt'
	exec master.sys.xp_cmdshell @cmd, no_output

	SELECT 	@cmd = 'select rtrim(ltrim(RelativePath))+rtrim(ltrim(FileName))'
	SELECT 	@cmd = @cmd + ' from dbaadmin.dbo.dbaudf_DirectoryCompare (''' + @save_chgpath01 + ''', ''' + @save_chgpath02 + ''')'
	SELECT 	@cmd = @cmd + ' where (Comparison like ''%DIFFERENT%'' or Comparison like ''%NOT IN B%'')'
	SELECT 	@cmd = @cmd + ' and RelativePath <> '''''
	SELECT 	@cmd = @cmd + ' order by RelativePath, FileName'

	Delete from #dbachangelist
	insert into #dbachangelist exec (@cmd)
	delete from #dbachangelist where change_file is null
	delete from #dbachangelist where change_file = ''
	--select * from #dbachangelist

	--  Create a saved version of the change list
	insert into #dbachangelist3 select * from #dbachangelist

	If (select count(*) from #dbachangelist) > 0
	   begin
		start_DBAchangelist02:
		
		Select @save_rowout = (select top 1 change_file from #dbachangelist order by change_file)

		Select @cmd = 'echo ' + @save_rowout + '>>' + @save_chgpath01 + 'DBA_changelist.txt'
		EXEC master.sys.xp_cmdshell @cmd, no_output
		
		Delete from #dbachangelist where change_file = @save_rowout
		If (select count(*) from #dbachangelist) > 0
		   begin
			goto start_DBAchangelist02
		   end
	   end
	   

	--  create Build Label file
	Select @cmd = 'echo.>>' + @save_chgpath01 + @save_ReleaseNum + '_' + @save_BuildLabel + '.txt'
	exec master.sys.xp_cmdshell @cmd, no_output
	
	Select @cmd = 'echo Label: ' + @save_BuildLabel + ' >>' + @save_chgpath01 + @save_ReleaseNum + '_' + @save_BuildLabel + '.txt'
	EXEC master.sys.xp_cmdshell @cmd, no_output


	--  create updatebuild file
	Select @cmd = 'echo.>>' + @save_chgpath01 + 'UpdateBuild.txt'
	exec master.sys.xp_cmdshell @cmd, no_output

	Select @cmd = 'echo Label: ' + @save_BuildLabel + ' >>' + @save_chgpath01 + 'UpdateBuild.txt'
	EXEC master.sys.xp_cmdshell @cmd, no_output
	Select @cmd = 'echo Version: ' + @save_ReleaseNum + ' >>' + @save_chgpath01 + 'UpdateBuild.txt'
	EXEC master.sys.xp_cmdshell @cmd, no_output


	--  Delete non-changelist files
	--  Capture all the files in the form of a delete command
	select @cmd = 'forfiles /p ' + @save_chgpath01 + ' -s -m * -c "cmd /c echo del /q @path,@isdir"'
	Print @cmd	

	--  Table to process against - files
	delete from #DirectoryTempTable3
	Insert into #DirectoryTempTable3(cmdoutput) exec master.sys.xp_cmdshell @cmd
	delete from #DirectoryTempTable3 where cmdoutput is null
	delete from #DirectoryTempTable3 where cmdoutput like '%No files found%'
	delete from #DirectoryTempTable3 where cmdoutput like '%,TRUE%'
	delete from #DirectoryTempTable3 where cmdoutput like '%DS_Store%'
	delete from #DirectoryTempTable3 where cmdoutput not like '%05_Pre_DB%'
					 and cmdoutput not like '%10_Temp_Pre%'
					 and cmdoutput not like '%15_User_Type%'
					 and cmdoutput not like '%20_Function%'
					 and cmdoutput not like '%25_Pre_Script%'
					 and cmdoutput not like '%30_View%'
					 and cmdoutput not like '%35_DataLoad%'
					 and cmdoutput not like '%40_StoredProcedure%'
					 and cmdoutput not like '%45_Trigger%'
					 and cmdoutput not like '%50_Post_Script%'
					 and cmdoutput not like '%55_CmdScript%'
					 and cmdoutput not like '%60_Post_DB%'
					 and cmdoutput not like '%65_Temp_Post%'
					 and cmdoutput not like '%70_Post_Build%'
					 and cmdoutput not like '%75_SQLJob%'
					 and cmdoutput not like '%90_RawData%'
	--select * from #DirectoryTempTable3

	--  Now remove the files that are in the change list
	If (select count(*) from #DirectoryTempTable3) > 0 and (select count(*) from #dbachangelist3) > 0
	   begin
		start_chglist_delete01:
		select @save_chglist_delete = (select top 1 change_file from #dbachangelist3)
		Delete from #DirectoryTempTable3 where cmdoutput like '%' + @save_chglist_delete + '%' 
	
		Delete from #dbachangelist3 where change_file = @save_chglist_delete
		If (select count(*) from #DirectoryTempTable3) > 0 and (select count(*) from #dbachangelist3) > 0
		   begin
			goto start_chglist_delete01
		   end		
	   end


	--  Now delete any file that was not in the change list
	If (select count(*) from #DirectoryTempTable3) > 0
	   begin
		start_chglist_delete02:
		Select @save_chglist_delete = (select top 1 cmdoutput from #DirectoryTempTable3)
		Select @hold_chglist_delete = @save_chglist_delete
		
		Select @save_chglist_delete = replace(@save_chglist_delete, ',FALSE', '')
		Print @save_chglist_delete
		exec master.sys.xp_cmdshell @save_chglist_delete

		Delete from #DirectoryTempTable3 where cmdoutput = @hold_chglist_delete
		If (select count(*) from #DirectoryTempTable3) > 0
		   begin
			goto start_chglist_delete02
		   end
	   end


		

	--  Check for more folders to process
	delete from #DirectoryTempTable where cmdoutput = @save_chgfolder
	delete from #DirectoryTempTable2 where cmdoutput = @save_chgfolder
	If (select count(*) from #DirectoryTempTable) > 0
	   begin
		goto start_DBAchangelist01
	   end
   end






--------------------------------------------------
--  Large file override process
--------------------------------------------------
If @largefile_flag = 'y'
   begin
	--  Load largefiles temp table
	Delete from #largefiles
	Insert into #largefiles select * from dbo.LargeFile_Override where Project = @save_projectname and (Release = 'All' or Release = @save_ReleaseNum)
	--select * from #largefiles


	If (select count(*) from #largefiles) > 0
	   begin
		Start_Largefile01:

		Select @save_dbname = (Select top 1 dbname from #largefiles)
		Select @save_filetype = (select filetype from #largefiles where dbname = @save_dbname)

		--  DataLoad section
		If @save_filetype = 'DataLoad'
		   begin
			--  Check to make sure source folders exist
			Select @temp_path1 = @largefile_path + '\' + @save_dbname
			--print @temp_path

			Delete from #fileexists
			Insert into #fileexists exec master.sys.xp_fileexist @temp_path1

			If not exists (select direxist from #fileexists where fileindir = 1)
			   BEGIN
				Select @miscprint = 'DBA ERROR: DBname folder not found at path ' +  @temp_path1 + '.'
				Print  @miscprint
				Select @error_count = @error_count + 1
				goto next_Largefile01
			   END


			--  Check to make sure the target folder exists
			Select @temp_path2 = rtrim(@save_TargetPath) + '\' + rtrim(@save_TopFolderName) + '\' + @save_dbname
			--print @temp_path

			Delete from #fileexists
			Insert into #fileexists exec master.sys.xp_fileexist @temp_path2

			If not exists (select direxist from #fileexists where fileindir = 1)
			   BEGIN
				Select @miscprint = 'DBA ERROR: Target Build folder not found at path ' +  @temp_path2 + '.'
				Print  @miscprint
				Select @error_count = @error_count + 1
				goto next_Largefile01
			   END

        		
			--  Now we know both the source and the target exist
			--  Copy files from the source to the target for each of the dataload folders
			select @cmd = 'xcopy ' + @temp_path1 + '\DataLoad_1\*.* ' + @temp_path2 + '\DataLoad_1 /Y'
			Print 'Copy the dataload files using command: ' + @cmd
			EXEC master.sys.xp_cmdshell @cmd 
			Print ''
        		
			select @cmd = 'xcopy ' + @temp_path1 + '\DataLoad_2\*.* ' + @temp_path2 + '\DataLoad_2 /Y'
			Print 'Copy the dataload files using command: ' + @cmd
			EXEC master.sys.xp_cmdshell @cmd 
			Print ''

			select @cmd = 'xcopy ' + @temp_path1 + '\DataLoad_3\*.* ' + @temp_path2 + '\DataLoad_3 /Y'
			Print 'Copy the dataload files using command: ' + @cmd
			EXEC master.sys.xp_cmdshell @cmd 
			Print ''

			select @cmd = 'xcopy ' + @temp_path1 + '\DataLoad_4\*.* ' + @temp_path2 + '\DataLoad_4 /Y'
			Print 'Copy the dataload files using command: ' + @cmd
			EXEC master.sys.xp_cmdshell @cmd 
			Print ''

			select @cmd = 'xcopy ' + @temp_path1 + '\35_DataLoad\*.* ' + @temp_path2 + '\35_DataLoad /Y'
			Print 'Copy the dataload files using command: ' + @cmd
			EXEC master.sys.xp_cmdshell @cmd 
			Print ''

			goto next_Largefile01
		   end





		--  RawData section
		If @save_filetype = 'RawData'
		   begin
			--  Check to make sure source folders exist
			Select @temp_path1 = @largefile_path + '\' + @save_dbname
			--print @temp_path

			Delete from #fileexists
			Insert into #fileexists exec master.sys.xp_fileexist @temp_path1

			If not exists (select direxist from #fileexists where fileindir = 1)
			   BEGIN
				Select @miscprint = 'DBA ERROR: DBname folder not found at path ' +  @temp_path1 + '.'
				Print  @miscprint
				Select @error_count = @error_count + 1
				goto next_Largefile01
			   END


			--  Check to make sure the target folder exists
			Select @temp_path2 = rtrim(@save_TargetPath) + '\' + rtrim(@save_TopFolderName) + '\' + @save_dbname
			--print @temp_path

			Delete from #fileexists
			Insert into #fileexists exec master.sys.xp_fileexist @temp_path2

			If not exists (select direxist from #fileexists where fileindir = 1)
			   BEGIN
				Select @miscprint = 'DBA ERROR: Target Build folder not found at path ' +  @temp_path2 + '.'
				Print  @miscprint
				Select @error_count = @error_count + 1
				goto next_Largefile01
			   END

        		
			--  Now we know both the source and the target exist
			--  Copy files from the source to the target for the rawdata folder
			select @cmd = 'xcopy ' + @temp_path1 + '\RawData\*.* ' + @temp_path2 + '\RawData /Y'
			Print 'Copy the rawdata files using command: ' + @cmd
			EXEC master.sys.xp_cmdshell @cmd 
			Print ''
        		

			goto next_Largefile01
		   end


		Print 'Unknown filetype request. ' + @save_filetype


		next_Largefile01:
		--  check for more row to process
		Delete from #largefiles where dbname = @save_dbname
		If (select count(*) from #largefiles) > 0
		   begin
			goto Start_Largefile01
		   end	
	   end
   end








--------------------------------------------------
--  Move the folder to the target path
--------------------------------------------------
Select @cmd = 'move /Y "' + @output_path + '\AHP_Builds\' + @save_TopFolderName + '" "' + @output_path + '\' + @save_project_header + '"'
Print 'Move the SQL Project folder using command '+ @cmd
EXEC @Result = master.sys.xp_cmdshell @cmd--, no_output 



--  If this is the first PS build, copy this code to the vsts_source\GOLD folders
If @codetype = 'PS'
   begin
	--  Get the folders from the new build code
	select @cmd = 'dir ' + rtrim(@output_path) + '\' + rtrim(@save_project_header)
	Select @cmd = @cmd  + ' /AD /B'

	delete from #DirectoryTempTable
	insert into #DirectoryTempTable exec master.sys.xp_cmdshell @cmd
	delete from #DirectoryTempTable where cmdoutput is null
	--select * from #DirectoryTempTable

	If not exists (select 1 from #DirectoryTempTable where cmdoutput like '%[_]ps[_]%')
	   begin
   		Select @cmd = 'mkdir "' + @output_path + '\GOLD\' + @save_TopFolderName + '"'
		Print 'Creating the DayOne SQL Project folder using command '+ @cmd
		EXEC master.sys.xp_cmdshell @cmd--, no_output 

		Print 'Robocopy the new PS build to the GOLD folders using the following command'
		Select @cmd = 'robocopy ' + @output_path + '\' + @save_project_header + '\' + @save_TopFolderName + ' ' + @output_path + '\GOLD\' + @save_TopFolderName + ' *.* /E'
		Print @cmd
		EXEC master.sys.xp_cmdshell @cmd--, no_output
	   end

   end





--  Email tssqldba
Select @subject = 'TFS ' + rtrim(@codetype) + ' New Code Alert: Build ' + @save_BuildLabel + ' available as of ' + convert(varchar(20), getdate(), 120)
Select @message = 'TFS build code for build #' + @save_BuildLabel + ' is now available.  ' + convert(varchar(20), getdate(), 120)
Exec dbaadmin.dbo.dbasp_sendmail @recipients = @recipients, @subject = @subject, @message = @message



--  Set this row to completed
update top (1) dbo.AHPbuildcode_prep set Status = 'Completed', CompletedDate = getdate() where bc_id = @save_bc_id



--  Check for more rows to process
If exists (select 1 from dbo.AHPbuildcode_prep where Status = 'Pending')
   begin
	Select @BuildLabel = null
	Select @ReleaseNum = null
	Select @save_bc_id = null
	Select @save_BuildLabel = null
	Select @save_ReleaseNum = null
	Select @save_TargetPath = null

	goto start01
   end





-- Finish -------------------------------------------------------------------------------------

label99:


Print ''
Print 'Process Completed'


error_process:

Drop table #DirectoryTempTable
Drop table #DirectoryTempTable2
Drop table #DirectoryTempTable3
Drop table #dbachangelist
Drop table #dbachangelist3
Drop table #fileexists
Drop table #file_Info
Drop table #largefiles

If @error_count > 0
   begin
	Print  ' '
	Print  ' '
	Select @miscprint = '--Here is a sample execute command for sproc dpsp_ahp_buildcode_prep:'
	Print  @miscprint
	Print  ' '
	Select @miscprint = 'exec DEPLcontrol.dbo.dpsp_ahp_buildcode_prep'
	Print  @miscprint
	Select @miscprint = '                                ,@BuildLabel = ''TranscoderDB_Main_20101105.3753''         -- Top level folder name that contains to Build Code to be processed'
	Print  @miscprint
	Select @miscprint = '                                ,@ReleaseNum = ''14.1''                                    -- Release number'
	Print  @miscprint   
	Select @miscprint = '                              --,@output_path = ''e:\builds\VSTS_Source''                  -- Output Path for build files and folders.  Defaults to ''e:\builds\source_vsts'''
	Print  @miscprint   
   end


GO
EXEC sys.sp_addextendedproperty @name=N'BuildApplication', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'dpsp_ahp_buildcode_prep'
GO
EXEC sys.sp_addextendedproperty @name=N'BuildBranch', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'dpsp_ahp_buildcode_prep'
GO
EXEC sys.sp_addextendedproperty @name=N'BuildNumber', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'dpsp_ahp_buildcode_prep'
GO
EXEC sys.sp_addextendedproperty @name=N'DeplFileName', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'dpsp_ahp_buildcode_prep'
GO
EXEC sys.sp_addextendedproperty @name=N'Version', @value=N'1.0.0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'dpsp_ahp_buildcode_prep'
GO
