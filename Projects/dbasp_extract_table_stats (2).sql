use dbaadmin
go



if exists (select * from sys.objects where object_id = object_id(N'[dbo].[dbasp_extract_table_stats]') and OBJECTPROPERTY(object_id, N'IsProcedure') = 1)
drop procedure [dbo].[dbasp_extract_table_stats]
GO


CREATE PROCEDURE dbo.dbasp_extract_table_stats

/**************************************************************
 **  Stored Procedure dbasp_extract_table_stats                  
 **  Written by Jim Wilson, Getty Images                
 **  June 21, 2001                                      
 **  
 **  This dbasp is set up to extract table related stats and
 **  insert the information into the dbaadmin..table_stats_log table.
 ***************************************************************/
  as
set nocount on

--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	04/26/2002	Jim Wilson		Revision History added
--	04/30/2002	Jim Wilson		Added brackets around dbname variable in select stmts.
--	02/03/2003	Jim Wilson		Added server parm to OSQL stmt.
--	04/21/2005	Jim Wilson		Major revision.  Removed cursors.  DBCC Showcontig
--						is now with tableresults.
--	08/29/2004	Jim Wilson		Added brackets around dbname variable in DBCC showcontig stmt.
--	12/05/2006	Jim Wilson		Converted for SQL 2005.
--	12/06/2006	Jim Wilson		Added purge process (2 year retention)
--	06/25/2007	Jim Wilson		Added schema name to sp_spaceused command
--	02/11/2008	Jim Wilson		Added skip for DB's not online.
--	08/04/2008	Jim Wilson		Added brackets for table names with spaces.
--	11/05/2008	Jim Wilson		Fixed bug with DBname capture.
--	08/27/2009	Jim Wilson		Fixed bug with duplicate results in the index section.
--	10/26/2009	Jim Wilson		Added nolock to avoid deadlocks.
--	04/06/2010	Jim Wilson		Removed processing for tables and indexes with zero rows.
--	05/04/2010	Jim Wilson		SQL 2008 updates start here.  Revised #index_data temp table.
--	======================================================================================


DECLARE
	 @miscprint				nvarchar(4000)
	,@query					nvarchar(4000)
	,@cmd					nvarchar(4000)
	,@save_object_id			int
	,@save_object_name			sysname 
	,@save_index_id				int
	,@save_partition_number			int
	,@save_index_type_desc			nvarchar (60)
	,@save_alloc_unit_type_desc		nvarchar (60)
	,@save_index_depth			tinyint
	,@save_index_level			tinyint
	,@save_avg_fragmentation_in_percent	float
	,@save_fragment_count			bigint
	,@save_avg_fragment_size_in_pages	float
	,@save_page_count			bigint
	,@save_avg_page_space_used_in_percent	float
	,@save_record_count			bigint
	,@save_ghost_record_count		bigint
	,@save_version_ghost_record_count	bigint
	,@save_min_record_size_in_bytes		int
	,@save_max_record_size_in_bytes		int
	,@save_avg_record_size_in_bytes		float
	,@save_forwarded_record_count		bigint
	,@save_reserved_space			varchar(18)
	,@save_data_space_used			varchar(18)
	,@save_index_size_used			varchar(18)
	,@save_unused_space			varchar(18)
	,@save_fullTBLname			sysname

DECLARE
	 @cu11DBName			sysname
	,@cu11DBId			smallint

DECLARE
	 @cu22TBLname			sysname
	,@cu22rows			bigint
	,@cu22rowmodctr			int
	,@cu22SCHname			sysname


----------------  initial values  -------------------

--  Create table variable
declare @dbnames table	(name		sysname
			,dbid		smallint
			)

create table #tables (TBLname sysname not null
			,TBLrows bigint not null
			,TBLrowmodctr int not null
			,SCHname sysname not null)


CREATE TABLE #index_data (
	[database_id] [smallint] NOT NULL ,
	[object_id] [int] NOT NULL ,
	[index_id] [int] NOT NULL ,
	[partition_number] [int] NOT NULL ,
	[index_type_desc] [nvarchar] (60) NOT NULL ,
	[alloc_unit_type_desc] [nvarchar] (60) NOT NULL ,
	[index_depth] [tinyint] NULL ,
	[index_level] [tinyint] NULL ,
	[avg_fragmentation_in_percent] [float] NULL ,
	[fragment_count] [bigint] NULL ,
	[avg_fragment_size_in_pages] [float] NULL ,
	[page_count] [bigint] NULL ,
	[avg_page_space_used_in_percent] [float] NULL ,
	[record_count] [bigint] NULL ,
	[ghost_record_count] [bigint] NULL ,
	[version_ghost_record_count] [bigint] NULL ,
	[min_record_size_in_bytes] [int] NULL ,
	[max_record_size_in_bytes] [int] NULL ,
	[avg_record_size_in_bytes] [float] NULL ,
	[forwarded_record_count] [bigint] NULL ,
	[compressed_page_count] [bigint] NULL)

Create Table #spused (
	[name] [sysname] NOT NULL ,
	[rows] [char] (11) NULL ,
	[reserved] [varchar] (18) NULL ,
	[data] [varchar] (18) NULL ,
	[index_size] [varchar] (18) NULL ,
	[unused] [varchar] (18) NULL)


/****************************************************************
 *                MainLine
 ***************************************************************/

--  Purge process  ----------------------------------------------------------------
Delete from dbaadmin.dbo.table_stats_log where rundate < (dateadd(year, -2, getdate()))

Delete from dbaadmin.dbo.index_stats_log where rundate < (dateadd(year, -2, getdate()))


--------------------  Capture DB names  -------------------
Insert into @dbnames (name, dbid)
SELECT d.name, d.database_id
From master.sys.databases d with (NOLOCK) 
Where d.name not in ('master', 'model', 'msdb', 'tempdb')


delete from @dbnames where name is null or name = ''
--select * from @dbnames


If (select count(*) from @dbnames) > 0
   begin
	start_dbnames:

	Select @cu11DBName = (select top 1 name from @dbnames)
	Select @cu11DBId = dbid from @dbnames where name = @cu11DBName

	If (SELECT DATABASEPROPERTYEX (@cu11DBName,'status')) <> 'ONLINE'
	   begin
		goto skip_db
	   end

	Print ' '
	Print ' '
	Print 'Start Database: ' + @cu11DBName + '  ' + convert(varchar(30),getdate(),9)
	Print '------------------------------------------------'
	raiserror('', -1,-1) with nowait

	
	--------------------  Capture table info  -----------------------
	delete from #tables
	
	Select @query = 'SELECT o.name, i.rowcnt, i.rowmodctr, s.name
	   From [' + @cu11DBName + '].sys.objects  o with (NOLOCK), [' + @cu11DBName + '].sys.sysindexes  i, [' + @cu11DBName + '].sys.schemas  s with (NOLOCK)
	   Where i.id = o.object_id
	      and o.type = ''u''
	     and i.indid in (0,1)
	     and i.rowcnt > 0
	     and o.parent_object_id = 0
	     and o.schema_id = s.schema_id
	     and o.name <> ''dtproperties''
	   Order By o.name, i.indid'

	insert into #tables exec (@query)
	--Select * from #tables

	If (select count(*) from #tables) > 0
	   begin
		start_tables:

		Select @cu22TBLname = (select top 1 TBLname from #tables)
		Select @cu22rows = TBLrows from #tables where TBLname = @cu22TBLname
		Select @cu22rowmodctr = TBLrowmodctr from #tables where TBLname = @cu22TBLname
		Select @cu22SCHname = SCHname from #tables where TBLname = @cu22TBLname

		
		Select @cmd = 'exec [' + @cu11DBName + '].sys.sp_executesql N''insert #spused exec sys.sp_spaceused ''''[' + @cu22SCHname + '].[' + @cu22TBLname + ']''''''';
		--print @cmd
		Delete from #spused
		EXEC (@cmd)


		If (select count(*) from #spused) > 0
		   begin
		    Select @save_reserved_space = (select top 1 reserved from #spused)
		    Select @save_data_space_used = (select top 1 data from #spused)
		    Select @save_index_size_used = (select top 1 index_size from #spused)
		    Select @save_unused_space = (select top 1 unused from #spused)
		   end

		Select @save_fullTBLname = @cu22SCHname + '.' + @cu22TBLname

		If not exists (select * from dbaadmin.dbo.table_stats_log where dbname = @cu11DBName and tblname = @save_fullTBLname and rows = @cu22rows and rowmodctr = @cu22rowmodctr and rundate > getdate()-1)
		   begin
			Print 'Processing table: ' + @cu22TBLname
			raiserror('', -1,-1) with nowait
			INSERT INTO dbaadmin.dbo.table_stats_log (rundate
								,DBName
								,TBLname
								,rows
								,rowmodctr
								,reserved_space
								,data_space_used
								,index_size_used
								,unused_space
								)
			VALUES 			(getdate()
						,@cu11DBName
						,@save_fullTBLname
						,@cu22rows
						,@cu22rowmodctr
						,@save_reserved_space
						,@save_data_space_used
						,@save_index_size_used
						,@save_unused_space
						)
		   end


		--  Remove this record from #tables and go to the next
		end_tables:
		delete from #tables where TBLname = @cu22TBLname and SCHname = @cu22SCHname
		If (select count(*) from #tables) > 0
		   begin
			goto start_tables
		   end


		--------------------  Capture Index info  -----------------------
		Print ''
		Print 'Start Capture Index Section: ' + @cu11DBName + '  ' + convert(varchar(30),getdate(),9)
		Print '------------------------------------------------'
		raiserror('', -1,-1) with nowait
		
		delete from #index_data
		
		Select @query = 'SELECT * from sys.dm_db_index_physical_stats (' + convert(varchar(10), @cu11DBId) + ', null, null, null, ''SAMPLED'')'  
	
		insert into #index_data exec (@query)
		delete from #index_data where record_count = 0
		--Select * from #index_data

		If (select count(*) from #index_data) > 0
		   begin
			start_indexes:

			Select @save_object_id = (select top 1 object_id from #index_data order by object_id)

			Select @cmd = 'USE ' + quotename(@cu11DBName) + ' SELECT @save_object_name = name from sys.objects with (NOLOCK) where object_id = ' + convert(nvarchar(20), @save_object_id)
			EXEC sp_executesql @cmd, N'@save_object_name sysname output', @save_object_name output
			Print 'Processing index: ' + @save_object_name
			raiserror('', -1,-1) with nowait

			Select @save_index_id = (select top 1 index_id from #index_data where object_id = @save_object_id order by index_id)
			Select @save_partition_number = (select top 1 partition_number from #index_data where object_id = @save_object_id and index_id = @save_index_id order by partition_number)
			Select @save_index_type_desc = (select top 1 index_type_desc from #index_data  where object_id = @save_object_id and index_id = @save_index_id and partition_number = @save_partition_number order by index_type_desc, alloc_unit_type_desc)
			Select @save_alloc_unit_type_desc = (select top 1 alloc_unit_type_desc from #index_data  where object_id = @save_object_id and index_id = @save_index_id and partition_number = @save_partition_number and index_type_desc = @save_index_type_desc order by alloc_unit_type_desc)
			Select @save_partition_number = (select partition_number from #index_data where object_id = @save_object_id and index_id = @save_index_id and partition_number = @save_partition_number and index_type_desc = @save_index_type_desc and alloc_unit_type_desc = @save_alloc_unit_type_desc)
			Select @save_index_depth = (select index_depth from #index_data where object_id = @save_object_id and index_id = @save_index_id and partition_number = @save_partition_number and index_type_desc = @save_index_type_desc and alloc_unit_type_desc = @save_alloc_unit_type_desc)
			Select @save_index_level = (select index_level from #index_data where object_id = @save_object_id and index_id = @save_index_id and partition_number = @save_partition_number and index_type_desc = @save_index_type_desc and alloc_unit_type_desc = @save_alloc_unit_type_desc)
			Select @save_avg_fragmentation_in_percent = (select avg_fragmentation_in_percent from #index_data where object_id = @save_object_id and index_id = @save_index_id and partition_number = @save_partition_number and index_type_desc = @save_index_type_desc and alloc_unit_type_desc = @save_alloc_unit_type_desc)
			Select @save_fragment_count = (select fragment_count from #index_data where object_id = @save_object_id and index_id = @save_index_id and partition_number = @save_partition_number and index_type_desc = @save_index_type_desc and alloc_unit_type_desc = @save_alloc_unit_type_desc)
			Select @save_avg_fragment_size_in_pages = (select avg_fragment_size_in_pages from #index_data where object_id = @save_object_id and index_id = @save_index_id and partition_number = @save_partition_number and index_type_desc = @save_index_type_desc and alloc_unit_type_desc = @save_alloc_unit_type_desc)
			Select @save_page_count = (select page_count from #index_data where object_id = @save_object_id and index_id = @save_index_id and partition_number = @save_partition_number and index_type_desc = @save_index_type_desc and alloc_unit_type_desc = @save_alloc_unit_type_desc)
			Select @save_avg_page_space_used_in_percent = (select avg_page_space_used_in_percent from #index_data where object_id = @save_object_id and index_id = @save_index_id and partition_number = @save_partition_number and index_type_desc = @save_index_type_desc and alloc_unit_type_desc = @save_alloc_unit_type_desc)
			Select @save_record_count = (select record_count from #index_data where object_id = @save_object_id and index_id = @save_index_id and partition_number = @save_partition_number and index_type_desc = @save_index_type_desc and alloc_unit_type_desc = @save_alloc_unit_type_desc)
			Select @save_ghost_record_count = (select ghost_record_count from #index_data where object_id = @save_object_id and index_id = @save_index_id and partition_number = @save_partition_number and index_type_desc = @save_index_type_desc and alloc_unit_type_desc = @save_alloc_unit_type_desc)
			Select @save_version_ghost_record_count = (select version_ghost_record_count from #index_data where object_id = @save_object_id and index_id = @save_index_id and partition_number = @save_partition_number and index_type_desc = @save_index_type_desc and alloc_unit_type_desc = @save_alloc_unit_type_desc)
			Select @save_min_record_size_in_bytes = (select min_record_size_in_bytes from #index_data where object_id = @save_object_id and index_id = @save_index_id and partition_number = @save_partition_number and index_type_desc = @save_index_type_desc and alloc_unit_type_desc = @save_alloc_unit_type_desc)
			Select @save_max_record_size_in_bytes = (select max_record_size_in_bytes from #index_data where object_id = @save_object_id and index_id = @save_index_id and partition_number = @save_partition_number and index_type_desc = @save_index_type_desc and alloc_unit_type_desc = @save_alloc_unit_type_desc)
			Select @save_avg_record_size_in_bytes = (select avg_record_size_in_bytes from #index_data where object_id = @save_object_id and index_id = @save_index_id and partition_number = @save_partition_number and index_type_desc = @save_index_type_desc and alloc_unit_type_desc = @save_alloc_unit_type_desc)
			Select @save_forwarded_record_count = (select forwarded_record_count from #index_data where object_id = @save_object_id and index_id = @save_index_id and partition_number = @save_partition_number and index_type_desc = @save_index_type_desc and alloc_unit_type_desc = @save_alloc_unit_type_desc)


			INSERT INTO dbaadmin.dbo.index_stats_log (rundate
								,dbname
								,tblname
								,index_id
								,partition_number
								,index_type_desc
								,alloc_unit_type_desc
								,index_depth
								,index_level
								,avg_fragmentation_in_percent
								,fragment_count
								,avg_fragment_size_in_pages
								,page_count
								,avg_page_space_used_in_percent
								,record_count
								,ghost_record_count
								,version_ghost_record_count
								,min_record_size_in_bytes
								,max_record_size_in_bytes
								,avg_record_size_in_bytes
								,forwarded_record_count
								)
			VALUES 			(getdate()
						,@cu11DBName
						,@save_object_name
						,@save_index_id
						,@save_partition_number
						,@save_index_type_desc
						,@save_alloc_unit_type_desc
						,@save_index_depth
						,@save_index_level
						,@save_avg_fragmentation_in_percent
						,@save_fragment_count
						,@save_avg_fragment_size_in_pages
						,@save_page_count
						,@save_avg_page_space_used_in_percent
						,@save_record_count
						,@save_ghost_record_count
						,@save_version_ghost_record_count
						,@save_min_record_size_in_bytes
						,@save_max_record_size_in_bytes
						,@save_avg_record_size_in_bytes
						,@save_forwarded_record_count	
						)
			Select @save_page_count = (select page_count from #index_data where object_id = @save_object_id and index_id = @save_index_id and partition_number = @save_partition_number and index_type_desc = @save_index_type_desc and alloc_unit_type_desc = @save_alloc_unit_type_desc)
    
			--  Remove this record from #indexes and go to the next
			delete from #index_data where object_id = @save_object_id 
						and index_id = @save_index_id 
						and index_type_desc = @save_index_type_desc 
						and alloc_unit_type_desc = @save_alloc_unit_type_desc 
			If (select count(*) from #index_data) > 0
			   begin
				goto start_indexes
			   end
		   end
	   end


	skip_db:


	--  Remove this record from @dbname and go to the next
	delete from @dbnames where name = @cu11DBName
	If (select count(*) from @dbnames) > 0
	   begin
		goto start_dbnames
	   end
   end

---------------------------  Finalization  -----------------------
label99:


if (object_id('tempdb..#tables') is not null)
   begin
	drop table #tables
   end

if (object_id('tempdb..#index_data') is not null)
   begin
	drop table #index_data
   end

if (object_id('tempdb..#spused') is not null)
   begin
	drop table #spused
   end


go


