USE [DEPLcontrol]
GO
/****** Object:  StoredProcedure [dbo].[dpsp_ProcessUpdateFiles]    Script Date: 10/4/2013 11:02:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[dpsp_ProcessUpdateFiles]

/*********************************************************
 **  Stored Procedure dpsp_ProcessUpdateFiles                  
 **  Written by Jim Wilson, Getty Images                
 **  February 24, 2009                                      
 **  
 **  This sproc will process files in the local DEPLcontrol
 **  share, which will include updates to several tables
 **  within DEPLcontrol.  There will also be Gears DB updates.
 **
 ***************************************************************/
  as
set nocount on

--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	02/24/2009	Jim Wilson		New process.
--	======================================================================================



-----------------  declares  ------------------
DECLARE
	 @miscprint			nvarchar(4000)
	,@cmd 				nvarchar(4000)
	,@sqlcmd			nvarchar(4000)
	,@filename_wild			nvarchar(100)
	,@Hold_hhmmss			varchar(8)
	,@tempcount			int
	,@Hold_filename			sysname
	,@Hold_filedate			varchar(14)
	,@charpos			bigint
	,@save_servername		sysname
	,@save_servername2		sysname
	,@save_share			sysname
	,@SaveDays			smallint
	,@Retention_filedate		varchar(14)


DECLARE
	 @cu12cmdoutput			nvarchar(255)


----------------  initial values  -------------------
select @filename_wild 	= '%.sml'
select @SaveDays = 5

Select @save_servername = @@servername
Select @save_servername2 = @@servername

Select @charpos = charindex('\', @save_servername)
IF @charpos <> 0
   begin
	Select @save_servername = rtrim(substring(@@servername, 1, (CHARINDEX('\', @@servername)-1)))

	Select @save_servername2 = stuff(@save_servername2, @charpos, 1, '$')
   end


create table #DirectoryTempTable (cmdoutput nvarchar(255) null)



/****************************************************************
 *                MainLine
 ***************************************************************/

Select @save_share = '\\'+ @save_servername + '\' + @save_servername2 + '_DEPLcontrol'

------------------------------------------------------------------------------------------
--  Start BAIupdate process  -------------------------------------------------------------
------------------------------------------------------------------------------------------
Print 'Start BAIupdate.gsql Processing'

Select @filename_wild = 'BAIupdate%'

--  Check for files in the DEPLcontrol folder for this server
Delete from #DirectoryTempTable
Select @cmd = 'dir ' + @save_share + '\*.* /B'
Insert into #DirectoryTempTable exec master.sys.xp_cmdshell @cmd
delete from #DirectoryTempTable where cmdoutput is null or cmdoutput = ''
--select * from #DirectoryTempTable
delete from #DirectoryTempTable where ltrim(rtrim(cmdoutput)) like '%gsql2'
--select * from #DirectoryTempTable


--  If any BAIupdate files were found, process them
If (select count(*) from #DirectoryTempTable) > 0
   begin
	start_cmdoutput01:

	Select @cu12cmdoutput = (select top 1 cmdoutput from #DirectoryTempTable)

	select @sqlcmd = 'sqlcmd -S' + @@servername + ' -i' + @save_share + '\' + rtrim(@cu12cmdoutput) + ' -o\\' + @save_servername + '\' + @save_servername2 + '_SQLjob_logs\DEPLcontrol_UpdateFile_' + rtrim(@cu12cmdoutput) + ' -E'
	print @sqlcmd
	exec master.sys.xp_cmdshell @sqlcmd

	Select @cmd = 'ren "' + @save_share + '\' + rtrim(@cu12cmdoutput) + '" "' + rtrim(@cu12cmdoutput) + '2"'
	print @cmd
	EXEC master.sys.xp_cmdshell @cmd, no_output


	--  Remove this record from #DirectoryTempTable and go to the next
	delete from #DirectoryTempTable where cmdoutput = @cu12cmdoutput
	If (select count(*) from #DirectoryTempTable) > 0
	   begin
		goto start_cmdoutput01
	   end
   end


------------------------------------------------------------------------------------------
--  Start DEPLcontrolUpdate process  -----------------------------------------------------
------------------------------------------------------------------------------------------
Print 'Start DEPLcontrolUpdate.gsql Processing'

Select @filename_wild = 'DEPLcontrolUpdate%'

--  Check for files in the DEPLcontrol folder for this server
Delete from #DirectoryTempTable
Select @cmd = 'dir ' + @save_share + '\*.* /B'
Insert into #DirectoryTempTable exec master.sys.xp_cmdshell @cmd
delete from #DirectoryTempTable where cmdoutput is null or cmdoutput = ''
--select * from #DirectoryTempTable
delete from #DirectoryTempTable where ltrim(rtrim(cmdoutput)) like '%gsql2'
--select * from #DirectoryTempTable


--  If any BAIupdate files were found, process them
If (select count(*) from #DirectoryTempTable) > 0
   begin
	start_cmdoutput02:

	Select @cu12cmdoutput = (select top 1 cmdoutput from #DirectoryTempTable)

	select @sqlcmd = 'sqlcmd -S' + @@servername + ' -i' + @save_share + '\' + rtrim(@cu12cmdoutput) + ' -o\\' + @save_servername + '\' + @save_servername2 + '_SQLjob_logs\DEPLcontrol_UpdateFile_' + rtrim(@cu12cmdoutput) + ' -E'
	print @sqlcmd
	exec master.sys.xp_cmdshell @sqlcmd

	Select @cmd = 'ren "' + @save_share + '\' + rtrim(@cu12cmdoutput) + '" "' + rtrim(@cu12cmdoutput) + '2"'
	print @cmd
	EXEC master.sys.xp_cmdshell @cmd, no_output


	--  Remove this record from #Smail_Info and go to the next
	delete from #DirectoryTempTable where cmdoutput = @cu12cmdoutput
	If (select count(*) from #DirectoryTempTable) > 0
	   begin
		goto start_cmdoutput02
	   end
   end



------------------------------------------------------------------------------------------
--  Start RDupdate process  --------------------------------------------------------------
------------------------------------------------------------------------------------------
Print 'Start RDupdate.gsql Processing'

Select @filename_wild = 'RDupdate%'

--  Check for files in the DEPLcontrol folder for this server
Delete from #DirectoryTempTable
Select @cmd = 'dir ' + @save_share + '\*.* /B'
Insert into #DirectoryTempTable exec master.sys.xp_cmdshell @cmd
delete from #DirectoryTempTable where cmdoutput is null or cmdoutput = ''
--select * from #DirectoryTempTable
delete from #DirectoryTempTable where ltrim(rtrim(cmdoutput)) like '%gsql2'
--select * from #DirectoryTempTable


--  If any BAIupdate files were found, process them
If (select count(*) from #DirectoryTempTable) > 0
   begin
	start_cmdoutput03:

	Select @cu12cmdoutput = (select top 1 cmdoutput from #DirectoryTempTable)

	select @sqlcmd = 'sqlcmd -S' + @@servername + ' -i' + @save_share + '\' + rtrim(@cu12cmdoutput) + ' -o\\' + @save_servername + '\' + @save_servername2 + '_SQLjob_logs\DEPLcontrol_UpdateFile_' + rtrim(@cu12cmdoutput) + ' -E'
	print @sqlcmd
	exec master.sys.xp_cmdshell @sqlcmd

	Select @cmd = 'ren "' + @save_share + '\' + rtrim(@cu12cmdoutput) + '" "' + rtrim(@cu12cmdoutput) + '2"'
	print @cmd
	EXEC master.sys.xp_cmdshell @cmd, no_output


	--  Remove this record from #Smail_Info and go to the next
	delete from #DirectoryTempTable where cmdoutput = @cu12cmdoutput
	If (select count(*) from #DirectoryTempTable) > 0
	   begin
		goto start_cmdoutput03
	   end
   end


------------------------------------------------------------------------------------------
--  Start GEARSupdate process  -----------------------------------------------------------
------------------------------------------------------------------------------------------
Print 'Start GEARSupdate.gsql Processing'

Select @filename_wild = 'GEARSupdate%'

--  Check for files in the DEPLcontrol folder for this server
Delete from #DirectoryTempTable
Select @cmd = 'dir ' + @save_share + '\*.* /B'
Insert into #DirectoryTempTable exec master.sys.xp_cmdshell @cmd
delete from #DirectoryTempTable where cmdoutput is null or cmdoutput = ''
--select * from #DirectoryTempTable
delete from #DirectoryTempTable where ltrim(rtrim(cmdoutput)) like '%gsql2'
--select * from #DirectoryTempTable


--  If any BAIupdate files were found, process them
If (select count(*) from #DirectoryTempTable) > 0
   begin
	start_cmdoutput04:

	Select @cu12cmdoutput = (select top 1 cmdoutput from #DirectoryTempTable)

	select @sqlcmd = 'sqlcmd -S' + @@servername + ' -i' + @save_share + '\' + rtrim(@cu12cmdoutput) + ' -o\\' + @save_servername + '\' + @save_servername2 + '_SQLjob_logs\DEPLcontrol_UpdateFile_' + rtrim(@cu12cmdoutput) + ' -E'
	print @sqlcmd
	exec master.sys.xp_cmdshell @sqlcmd

	Select @cmd = 'ren "' + @save_share + '\' + rtrim(@cu12cmdoutput) + '" "' + rtrim(@cu12cmdoutput) + '2"'
	print @cmd
	EXEC master.sys.xp_cmdshell @cmd, no_output


	--  Remove this record from #Smail_Info and go to the next
	delete from #DirectoryTempTable where cmdoutput = @cu12cmdoutput
	If (select count(*) from #DirectoryTempTable) > 0
	   begin
		goto start_cmdoutput04
	   end
   end



--  Process to delete old files  -------------------
Print 'Start Delete Old Files Processing - DEPLcontrol share'

Select @save_share = '\\'+ @save_servername + '\' + @save_servername2 + '_DEPLcontrol'

Set @Retention_filedate = convert(char(8), getdate()-@SaveDays, 112) + substring(@Hold_hhmmss, 1, 2) + substring(@Hold_hhmmss, 4, 2) + substring(@Hold_hhmmss, 7, 2) 

select @cmd = 'dir ' + @save_share + '\*.gsql2 /B'

Delete from #DirectoryTempTable
insert into #DirectoryTempTable exec master.sys.xp_cmdshell @cmd
Delete from #DirectoryTempTable where cmdoutput is null

Select @tempcount = (select count(*) from #DirectoryTempTable)

While (@tempcount > 0)
   begin
	Select @Hold_filename = (select TOP 1 cmdoutput from #DirectoryTempTable)

	Select @charpos = charindex('.gsql2', @Hold_filename)
	IF @charpos <> 0
	   begin
 		Select @Hold_filedate = substring(@Hold_filename, @charpos -14, 14)
	   end	

	If @Retention_filedate > @Hold_filedate
	   begin
		select @cmd = 'del ' + @save_share + '\' + @Hold_filename
		Print @cmd
		Exec master.sys.xp_cmdshell @cmd

		delete from #DirectoryTempTable where cmdoutput = @Hold_filename
	   end
	Else
	   begin
		delete from #DirectoryTempTable where cmdoutput = @Hold_filename
	   end

	Select @tempcount = (select count(*) from #DirectoryTempTable)

   end



Print 'Start Delete Old Files Processing - dba_reports folder'

Select @save_share = '\\'+ @save_servername + '\' + @save_servername2 + '_DBAsql\dba_reports'

Set @Retention_filedate = convert(char(8), getdate()-@SaveDays, 112) + substring(@Hold_hhmmss, 1, 2) + substring(@Hold_hhmmss, 4, 2) + substring(@Hold_hhmmss, 7, 2) 

select @cmd = 'dir ' + @save_share + '\*.gsql2 /B'

Delete from #DirectoryTempTable
insert into #DirectoryTempTable exec master.sys.xp_cmdshell @cmd
Delete from #DirectoryTempTable where cmdoutput is null

Select @tempcount = (select count(*) from #DirectoryTempTable)

While (@tempcount > 0)
   begin
	Select @Hold_filename = (select TOP 1 cmdoutput from #DirectoryTempTable)

	Select @charpos = charindex('.gsql2', @Hold_filename)
	IF @charpos <> 0
	   begin
 		Select @Hold_filedate = substring(@Hold_filename, @charpos -14, 14)
	   end	

	If @Retention_filedate > @Hold_filedate
	   begin
		select @cmd = 'del ' + @save_share + '\' + @Hold_filename
		Print @cmd
		Exec master.sys.xp_cmdshell @cmd

		delete from #DirectoryTempTable where cmdoutput = @Hold_filename
	   end
	Else
	   begin
		delete from #DirectoryTempTable where cmdoutput = @Hold_filename
	   end

	Select @tempcount = (select count(*) from #DirectoryTempTable)

   end



----------------  End  -------------------
label99:

drop table #DirectoryTempTable






GO
