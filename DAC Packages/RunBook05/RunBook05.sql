CREATE DATABASE [RunBook05]
 COLLATE SQL_Latin1_General_CP1_CI_AS
GO
ALTER DATABASE [RunBook05] SET COMPATIBILITY_LEVEL = 90
GO
ALTER DATABASE [RunBook05] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [RunBook05] SET  DISABLE_BROKER 
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DBA2005](
	[KnowledgeBaseID] [int] IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NULL,
	[ModifiedBy] [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Description] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Notes] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Server] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)

GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[knowledgebase](
	[KnowledgeBaseID] [int] IDENTITY(1,1) NOT NULL,
	[CaseNumber] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DateOpened] [datetime] NULL,
	[DateClosed] [datetime] NULL,
	[Domain] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DBA] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Server] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ProblemDescription] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ProblemResolution] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MicrosoftContactName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MicrosoftContactEmail] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MicrosoftContactPhone] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Application] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)

GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rb_Server](
	[ServerID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ServerIP] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Location] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Machine] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Processor] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ProcessorCount] [smallint] NULL,
	[NetworkCardCount] [smallint] NULL,
	[PropertyNum] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DomainName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PDC] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OSVersion] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OSBuild] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OSOrgInstalDate] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OSSysRoot] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IEVersion] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SysUpTime] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RemoteType] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RemotePassword] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ServerRole] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Tape_backup_sched] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ModifyUser] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ModifyDate] [datetime] NULL,
	[AutoUpdate_Date] [datetime] NULL,
 CONSTRAINT [PK_rb_server] PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
)

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_clust_rb_server] ON [dbo].[rb_Server] 
(
	[ServerName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rb_Admins](
	[ServerID] [int] NOT NULL,
	[LocAdminName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_rb_Admins] PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC,
	[LocAdminName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
)

GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rb_Applications](
	[ServerID] [int] NOT NULL,
	[ApplicationName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_rb_Applications] PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC,
	[ApplicationName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
)

GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rb_Capture_data](
	[capdata_ID] [int] IDENTITY(1,1) NOT NULL,
	[capdata_detail] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)

GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rb_Category](
	[ServerID] [int] NOT NULL,
	[CategoryType] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_rb_Category] PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC,
	[CategoryType] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
)

GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rb_Comments](
	[ServerID] [int] NOT NULL,
	[CommentNum] [int] IDENTITY(1,1) NOT NULL,
	[CommentTitle] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CommentText] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_rb_Comments] PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC,
	[CommentNum] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
)

GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rb_SQLInfo](
	[ServerID] [int] NOT NULL,
	[SQLID] [int] IDENTITY(1,1) NOT NULL,
	[SQLName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SQLVersion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SQLCollation] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SQLServiceID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SQLServicePW] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SQLAgentID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SQLAgentPW] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SQLSAPW] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SQLPath_SysFiles] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SQLPath_SysDBFiles] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SQLPath_ErrorLogs] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SQLPath_BackupFiles] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SQLPort] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_rb_SQLInfo] PRIMARY KEY CLUSTERED 
(
	[SQLID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
)

GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rb_Dbases](
	[SQLID] [int] NOT NULL,
	[DatabaseName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Comments] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_rb_Dbases] PRIMARY KEY CLUSTERED 
(
	[SQLID] ASC,
	[DatabaseName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
)

GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rb_Drives](
	[ServerID] [int] NOT NULL,
	[DriveName] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DriveFileSys] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DriveSize] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DriveFree] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DriveUsed] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_rb_Drives] PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC,
	[DriveName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
)

GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rb_DropList](
	[DL_Title] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DL_detail] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_rb_DropList] PRIMARY KEY CLUSTERED 
(
	[DL_Title] ASC,
	[DL_detail] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
)

GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rb_HotFixes](
	[ServerID] [int] NOT NULL,
	[HotFixName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[InstallDate] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_rb_HotFixes] PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC,
	[HotFixName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
)

GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rb_KnowledgeBase](
	[KnowledgeBaseID] [int] IDENTITY(1,1) NOT NULL,
	[CaseNumber] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DateOpened] [datetime] NULL,
	[DateClosed] [datetime] NULL,
	[DBAID] [int] NULL,
	[Server] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ProblemDescription] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ProblemResolution] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MicrosoftContactName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MicrosoftContactEmail] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MicrosoftContactPhone] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Application] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)

GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rb_Memory](
	[ServerID] [int] NOT NULL,
	[Physical_tot] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Virtual_tot] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Pagefile] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VirtAvail_current] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VirtAvail_past] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)

GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rb_Passwords](
	[ServerID] [int] NOT NULL,
	[AdminPW] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ID01Text] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ID01PW] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ID02Text] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ID02PW] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ID03Text] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ID03PW] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ID04Text] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ID04PW] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ID05Text] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ID05PW] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)

GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rb_Reboot](
	[ServerID] [int] NOT NULL,
	[DayofWeek] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DayNumber] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TimeOfDay] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Notfication] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Notes] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrimaryContact] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrimaryContact_title] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SecondaryContact] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SecondaryContact_title] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DependencyInstructions] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RebootScheduleConfirmed] [bit] NULL
)

GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rb_RelatedServers](
	[ServerID] [int] NOT NULL,
	[RelatedServerName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Comments] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_rb_RelatedServers] PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC,
	[RelatedServerName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
)

GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rb_Services](
	[ServerID] [int] NOT NULL,
	[ServiceName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ServiceStatus] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_rb_Services] PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC,
	[ServiceName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
)

GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rb_Support](
	[ServerID] [int] NOT NULL,
	[ListOrder] [smallint] NULL,
	[SupportName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Department] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SupportType] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[WorkPhone] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CellPhone] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Comments] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_rb_support] PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC,
	[SupportName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
)

GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[runbookSQL](
	[serverId] [int] NOT NULL,
	[servername] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[serverrole] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[categorytype] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)

GO

SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[rbsp_CaptureDomainInfo]
	@domain_name [varchar](255) = null
WITH EXECUTE AS CALLER
AS
set nocount on

--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	09/16/2002	Jim Wilson		New process
--	12/23/2004	Jim Wilson		Modofied to handel new GETTYPE output (and old)
--	05/06/2005	Jim Wilson		Major revision.  Removed cursors.  This now handles
--						named instances.
--	======================================================================================

/***
DECLARE  @domain_name varchar(255)
Select @domain_name = 'test'
--***/


-----------------  declares  ------------------

DECLARE
	 @miscprint			varchar(1000)
	,@cmd				varchar(255)
	,@osqlcmd			varchar(400)
	,@charpos			int
	,@charpos2			int
	,@start_pos			int
	,@counter			int
	,@counter_txt			char(4)
	,@server_flag			char(1)
	,@IPAddress_flag		char(1)
	,@hotfix_flag			char(1)
	,@drives_flag			char(1)
	,@services_flag			char(1)
	,@mssql_flag			char(1)
	,@cluster_flag			char(1)
	,@SQLversion_flag		char(1)
	,@PSHotFix_flag			char(1)
	,@application_flag		char(1)
	,@memory_update_flag		char(1)
	,@hold_ID			varchar(2000)
	,@hold_sqlinstance		sysname
	,@hold_sqlagent			sysname
	,@save_srvrname			sysname
	,@save_srvrname2		sysname
	,@save_srvrname3		sysname
	,@save_srvrname_sql		sysname
	,@save_hostname			sysname
	,@save_OSversion		varchar(100)
	,@save_OSBuild			varchar(100)
	,@save_OSOrgInstalDate		varchar(50)
	,@save_Domain			varchar(50)
	,@save_PDC			varchar(50)
	,@save_IPAddress		varchar(50)
	,@save_Processor		varchar(50)
	,@save_hotfix			varchar(20)
	,@save_DriveName		varchar(2)
	,@save_DriveFileSys		varchar(8)
	,@save_DriveSize		varchar(8)
	,@save_DriveFree		varchar(8)
	,@save_DriveUsed		varchar(8)
	,@save_ServiceStatus		varchar(7)
	,@save_ServiceName		varchar(50)
	,@save_NetworkCard		varchar(50)
	,@save_SysUpTime		varchar(50)
	,@save_LocalAdmin		varchar(100)
	,@save_PShotfix			varchar(20)
	,@save_PShotfix_date		varchar(20)
	,@save_application		varchar(100)
	,@save_PSIEversion		varchar(50)
	,@save_PSSystemRoot		varchar(50)
	,@save_PSPhysicalMemory		varchar(50)
	,@save_MemoryPhysical		varchar(50)
	,@save_MemoryVirtual		varchar(50)
	,@save_MemoryPagefile		varchar(50)
	,@save_MemoryVirtAvail		varchar(50)
	,@save_SQLVersion		varchar(50)
	,@save_SQLcollation		varchar(500)
	,@save_SQLServiceID		varchar(50)
	,@save_SQLAgentID		varchar(50)
	,@save_SQLSysFilesPath		varchar(100)
	,@save_SQLSysDBFilesPath	varchar(100)
	,@save_SQLBackupFilePath	varchar(100)
	,@save_SQLDatabaseName		varchar(100)


DECLARE
	 @cu11SRVRname		nvarchar(255)

DECLARE
	 @cu20SRVRtype		nvarchar(255)

DECLARE
	 @cu21SRVRinfo		nvarchar(255)

DECLARE
	 @cu22PSinfo		nvarchar(255)

DECLARE
	 @cu23LocalAdmin	nvarchar(255)

DECLARE
	 @cu24Memory		nvarchar(255)

DECLARE
	 @cu25PING		nvarchar(255)

DECLARE
	 @cu31SQLversion	nvarchar(255)

DECLARE
	 @cu32SQLcollation	nvarchar(500)

DECLARE
	 @cu33SQLserviceID	nvarchar(2000)

DECLARE
	 @cu34SQLagentID	nvarchar(2000)

DECLARE
	 @cu35SQLSysFilesPath	nvarchar(2000)

DECLARE
	 @cu36SQLSysDBFilesPath	nvarchar(2000)

DECLARE
	 @cu37SQLBackupFilePath	nvarchar(500)

DECLARE
	 @cu38SQLDatabaseName	nvarchar(255)




----------------  initial values  -------------------



--  Create temp tables and table variables
CREATE TABLE #temp_tbl	(text01	nvarchar(400))

CREATE TABLE #temp_tbl2	(text01	nvarchar(400))

CREATE TABLE #temp_sql (text01	nvarchar(400)) 

CREATE TABLE #reginfo (value varchar(2000))




--declare @tvar_SRVRnames table(@cu11SRVRname sysname)





--  Check Input parms
If @domain_name is null
   begin
	Print 'Error!  Input parameter (domain name) was not entered.'
	goto label99
   end



---------------------------------------------------------------
--  START PROCESS
---------------------------------------------------------------

--------------------  Process Server names  -------------------
select @cmd = 'net view /DOMAIN:' + @domain_name
insert #temp_tbl (text01) exec master..xp_cmdshell @cmd
delete from #temp_tbl where text01 is null
--select * from #temp_tbl


If (select count(*) from #temp_tbl) > 0
   begin
	start_SRVRnames:
	Select @cu11SRVRname = (Select top 1 text01 from #temp_tbl)

--print @cu11SRVRname	
 
	Select @save_OSBuild = 'NT '
	Select @server_flag = 'n'
	Select @IPAddress_flag = 'n'
	Select @hotfix_flag = 'n'
	Select @drives_flag = 'n'
	Select @services_flag = 'n'
	Select @mssql_flag = 'n'
	Select @cluster_flag = 'n'
	Select @SQLversion_flag = '0'
	Select @application_flag = 'n'
	Select @memory_update_flag = 'n'
	Select @save_PSPhysicalMemory = ' '
	Select @counter = 1
	Select @counter_txt = str(@counter, 4)
	delete from #temp_sql

	If substring(@cu11SRVRname, 1, 2) <> '\\'
	   begin
		goto skip_to_next
	   end

--	If (substring(@cu11SRVRname, 3, 6) <> 'dapsql'
--	  and substring(@cu11SRVRname, 3, 6) <> 'gmssql')
--	   begin
--		goto skip_to_next
--	   end


	Select @save_srvrname = rtrim(substring(@cu11SRVRname, 1, 23))


	--  Process for Server type  -----------------------------------
	--  execute the gettype command via cmdshell and drop the results in the temp table
	delete from #temp_tbl2
	select @cmd = 'gettype /S ' + @save_srvrname
	--print @cmd
	insert #temp_tbl2(text01) exec master..xp_cmdshell @cmd
	Delete from #temp_tbl2 where text01 is null or text01 = ''
	--select * from #temp_tbl2

	If exists (select * from #temp_tbl2 where text01 like '%ERROR:%')
	   begin
		Select @server_flag = 'n'
		goto end_SRVRtype 
	   end


	--  Capture Host Name
	Select @cu20SRVRtype = (Select top 1 text01 from #temp_tbl2 where text01 like 'Host Name:%')
	If @cu20SRVRtype is not null and @cu20SRVRtype <> ''
	   begin
		Select @save_hostname = ''
		Select @save_hostname = substring(@cu20SRVRtype, 14, 100)
		Select @save_srvrname2 = rtrim(@save_hostname)
	   end

	--  Capture OS Version
	Select @cu20SRVRtype = (Select top 1 text01 from #temp_tbl2 where text01 like 'Name:%')
	If @cu20SRVRtype is not null and @cu20SRVRtype <> ''
	   begin
		Select @charpos = charindex(' Server ', @cu20SRVRtype, 1)
		IF @charpos <> 0
		   begin
			Select @server_flag = 'y'

			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~ServerName~' + @save_srvrname2
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)

			Select @charpos = charindex('Windows', @cu20SRVRtype, 1)
			IF @charpos <> 0
			   begin
				Select @save_OSVersion = rtrim(substring(@cu20SRVRtype, @charpos, 50))
				Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~OSVersion~' + @save_OSVersion
				insert into rb_Capture_data (capdata_detail) values (@miscprint)
				--Print @miscprint
				Select @counter = @counter + 1
				Select @counter_txt = str(@counter, 4)
			   end

		   end
	   end


	end_SRVRtype:



	--  If this is not a server, skip the data gatering process and get the next servername to process
	If @server_flag = 'n'
	   begin
		goto skip_to_next
	   end



	--  Process for SRVINFO  -----------------------------------
	--  execute the srvinfo command via cmdshell and drop the results in the temp table
	delete from #temp_tbl2
	select @cmd = 'srvinfo ' + @save_srvrname
	--print @cmd
	insert #temp_tbl2(text01) exec master..xp_cmdshell @cmd
	Delete from #temp_tbl2 where text01 is null or text01 = ''
	--select * from #temp_tbl2


	If (select count(*) from #temp_tbl2) > 0
	   begin
		start_SRVINFO:
		Select @cu21SRVRinfo = (Select top 1 text01 from #temp_tbl2)
		--print @cu21SRVRinfo


		--  Check to see if we are processing hot fixes
		If @hotfix_flag = 'y' and substring(@cu21SRVRinfo, 1, 4) = '   ['
		   begin
			Select @save_hotfix = rtrim(substring(@cu21SRVRinfo, 4, 20))
			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~HotFixName~' + @save_hotfix
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)
			goto end_SRVINFO
		   end
		Else
		   begin
			Select @hotfix_flag = 'n'
		   end


		--  Check to see if we are processing drive info
		If @drives_flag = 'y' and substring(@cu21SRVRinfo, 1, 2) = '  '
		   begin
			Select @save_DriveName = rtrim(substring(@cu21SRVRinfo, 3, 2))
			Select @save_DriveFileSys = rtrim(ltrim(substring(@cu21SRVRinfo, 6, 7)))
			Select @save_DriveSize = rtrim(ltrim(substring(@cu21SRVRinfo, 16, 8)))
			Select @save_DriveFree = rtrim(ltrim(substring(@cu21SRVRinfo, 26, 8)))
			Select @save_DriveUsed = rtrim(ltrim(substring(@cu21SRVRinfo, 36, 8)))
			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~Drives~' + @save_DriveName + '~' + @save_DriveFileSys + '~' + @save_DriveSize + '~' + @save_DriveFree + '~' + @save_DriveUsed
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)
			goto end_SRVINFO
		   end
		Else
		   begin
			Select @drives_flag = 'n'
		   end


		--  Check to see if we are processing services info
		If @services_flag = 'y' and substring(@cu21SRVRinfo, 1, 4) = '   ['
		   begin
			Select @save_ServiceStatus = rtrim(substring(@cu21SRVRinfo, 5, 7))
			Select @save_ServiceName = rtrim(ltrim(substring(@cu21SRVRinfo, 14, 50)))
			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~Services~' + @save_ServiceName + '~' + @save_ServiceStatus
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)



			If @save_ServiceName = 'MSSQLServerADHelper'
			   begin
				Select @mssql_flag = 'y'
			   end
			Else If @save_ServiceName = 'MSSQLSERVER'
			   begin
				Select @mssql_flag = 'y'
				insert into #temp_sql (text01) values (@save_ServiceName)
			   end
			Else If @save_ServiceName like 'MSSQL$%'
			   begin
				Select @mssql_flag = 'y'
				insert into #temp_sql (text01) values (@save_ServiceName)
			   end
			Else If @save_ServiceName = 'Cluster Service' and @save_ServiceStatus = 'Running'
			   begin
				Select @cluster_flag = 'y'
			   end
			goto end_SRVINFO
		   end
		Else
		   begin
			Select @services_flag = 'n'
		   end



		If substring(@cu21SRVRinfo, 1, 12) = 'Server Name:'
		   begin
			Select @save_srvrname3 = substring(@cu21SRVRinfo, 14, 23)
			If @save_srvrname <> '\\' + @save_srvrname3
			   begin
				Select @miscprint = 'DBA Warning:  Runbook capture process - Servername from srvinfo (' + @save_srvrname3 + ') does not match input servername (' + @save_srvrname + ').'
				Print @miscprint
			   end
		   end
		Else If substring(@cu21SRVRinfo, 1, 8) = 'NT Type:'
		   begin
			goto end_SRVINFO
		   end
		Else If substring(@cu21SRVRinfo, 1, 9) = 'Security:'
		   begin
			goto end_SRVINFO
		   end
		Else If substring(@cu21SRVRinfo, 1, 13) = 'Current Type:'
		   begin
			goto end_SRVINFO
		   end
		Else If substring(@cu21SRVRinfo, 1, 13) = 'Product Name:'
		   begin
			goto end_SRVINFO
		   end
		Else If substring(@cu21SRVRinfo, 1, 10) = 'Registered'
		   begin
			goto end_SRVINFO
		   end
		Else If substring(@cu21SRVRinfo, 1, 10) = 'ProductID:'
		   begin
			goto end_SRVINFO
		   end
		Else If substring(@cu21SRVRinfo, 1, 8) = 'Protocol'
		   begin
			goto end_SRVINFO
		   end
		Else If substring(@cu21SRVRinfo, 1, 8) = 'Version:'
		   begin
			Select @save_OSBuild = @save_OSBuild + substring(@cu21SRVRinfo, 10, 10)
		   end
		Else If substring(@cu21SRVRinfo, 1, 7) = 'Build:'
		   begin
			Select @save_OSBuild = @save_OSBuild + substring(@cu21SRVRinfo, 1, 50)
			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~OSBuild~' + @save_OSBuild
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)
		   end
		Else If substring(@cu21SRVRinfo, 1, 22) = 'Original Install Date:'
		   begin
			Select @save_OSOrgInstalDate = rtrim(substring(@cu21SRVRinfo, 24, 50))
			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~OSOrgInstalDate~' + @save_OSOrgInstalDate
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)
		   end
		Else If substring(@cu21SRVRinfo, 1, 7) = 'Domain:'
		   begin
			Select @save_Domain = rtrim(substring(@cu21SRVRinfo, 9, 50))
			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~DomainName~' + @save_Domain
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)
		   end
		Else If substring(@cu21SRVRinfo, 1, 4) = 'PDC:'
		   begin
			Select @save_PDC = rtrim(substring(@cu21SRVRinfo, 6, 50))
			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~PDC~' + @save_PDC
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)
		   end
		Else If substring(@cu21SRVRinfo, 1, 11) = 'IP Address:'
		   begin
			Select @IPAddress_flag = 'y'
			Select @save_IPAddress = rtrim(substring(@cu21SRVRinfo, 13, 50))
			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~ServerIP~' + @save_IPAddress
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)
		   end
		Else If substring(@cu21SRVRinfo, 1, 3) = 'CPU'
		   begin
			Select @save_Processor = rtrim(substring(@cu21SRVRinfo, 9, 50))
			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~Processor~' + @save_Processor
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)
		   end
		Else If substring(@cu21SRVRinfo, 1, 9) = 'Hotfixes:'
		   begin
			Select @hotfix_flag = 'y'
		   end
		Else If substring(@cu21SRVRinfo, 1, 6) = 'Drive:'
		   begin
			Select @drives_flag = 'y'
		   end
		Else If substring(@cu21SRVRinfo, 1, 9) = 'Services:'
		   begin
			Select @services_flag = 'y'
		   end
		Else If substring(@cu21SRVRinfo, 1, 12) = 'Network Card'
		   begin
			Select @save_NetworkCard = rtrim(substring(@cu21SRVRinfo, 1, 50))
			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~NetworkCard~' + @save_NetworkCard
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)
		   end
		Else If substring(@cu21SRVRinfo, 1, 15) = 'System Up Time:'
		   begin
			Select @save_SysUpTime = rtrim(substring(@cu21SRVRinfo, 17, 50))
			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~SysUpTime~' + @save_SysUpTime
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)
		   end


		end_SRVINFO:


		--  Check to see if there are more rows to process
		Delete from #temp_tbl2 where text01 = @cu21SRVRinfo
		If (select count(*) from #temp_tbl2) > 0
		   begin
			goto start_SRVINFO
		   end

	   end
	



	--  Process for PSinfo  -----------------------------------
	--  execute the PSinfo command via cmdshell and drop the results in the temp table
	Delete from #temp_tbl2
	select @cmd = 'PSinfo ' + @save_srvrname + ' -h -s'
	--print @cmd
	insert #temp_tbl2(text01) exec master..xp_cmdshell @cmd
	Delete from #temp_tbl2 where text01 is null or text01 = ''
	Delete from #temp_tbl2 where substring(text01, 1, 1) = char(13)
	--select * from #temp_tbl2


	If (select count(*) from #temp_tbl2) > 0
	   begin
		start_PSinfo:
		Select @cu22PSinfo = (Select top 1 text01 from #temp_tbl2)
		--print @cu22PSinfo



		--  Check to see if we are done processing PS hot fixes
		If substring(@cu22PSinfo, 1, 13) = 'Applications:'
		   begin
			Select @PSHotFix_flag = 'n'
			Select @application_flag = 'y'
			goto end_PSinfo
		   end

		--  Check to see if we are processing PS hot fixes
		If @PSHotFix_flag = 'y'
		   begin
			Select @save_PShotfix = rtrim(ltrim(substring(@cu22PSinfo, 1, 12)))
			Select @save_PShotfix_date = rtrim(ltrim(substring(@cu22PSinfo, 13, 50)))
			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~PSHotFix~' + @save_PShotfix + '~' + @save_PShotfix_date
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)
			goto end_PSinfo
		   end


		--  Check to see if we are processing applications
		If @application_flag = 'y' and (@cu22PSinfo <> '')
		   begin
			Select @save_application = rtrim(ltrim(substring(@cu22PSinfo, 1, 100)))
			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~PSApplication~' + @save_application
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)
			goto end_PSinfo
		   end
		Else
		   begin
			Select @application_flag = 'n'
		   end


		If substring(@cu22PSinfo, 1, 10) = 'OS Hot Fix'
		   begin
			Select @PSHotFix_flag = 'y'
			goto end_PSinfo
		   end

		If substring(@cu22PSinfo, 1, 11) = 'IE version:'
		   begin
			Select @save_PSIEversion = rtrim(ltrim(substring(@cu22PSinfo, 12, 50)))
			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~PSIEversion~' + @save_PSIEversion
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)
		   end
		Else If substring(@cu22PSinfo, 1, 12) = 'System root:'
		   begin
			Select @save_PSSystemRoot = rtrim(ltrim(substring(@cu22PSinfo, 14, 50)))
			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~PSSystemRoot~' + @save_PSSystemRoot
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)
		   end
		Else If substring(@cu22PSinfo, 1, 16) = 'Physical memory:'
		   begin
			Select @save_PSPhysicalMemory = rtrim(ltrim(substring(@cu22PSinfo, 17, 50)))
		   end


		end_PSinfo:


		--  Check to see if there are more rows to process
		Delete from #temp_tbl2 where text01 = @cu22PSinfo
		If (select count(*) from #temp_tbl2) > 0
		   begin
			goto start_PSinfo
		   end

	   end




	--  Process for LOCAL  -----------------------------------
	--  execute the LOCAL command via cmdshell and drop the results in the temp table
	Delete from #temp_tbl2
	select @cmd = 'local administrators \\' + @save_srvrname2
	--print @cmd
	insert #temp_tbl2(text01) exec master..xp_cmdshell @cmd
	Delete from #temp_tbl2 where text01 is null or text01 = ''
	--select * from #temp_tbl2


	If (select count(*) from #temp_tbl2) > 0
	   begin
		start_LOCAL:
		Select @cu23LocalAdmin = (Select top 1 text01 from #temp_tbl2)
		--print @cu23LocalAdmin



		Select @save_LocalAdmin = rtrim(substring(@cu23LocalAdmin, 1, 100))

		--  Remove char(10)from record
		label03:
		Select @charpos = charindex(char(10), @save_LocalAdmin, 1)
		IF @charpos <> 0
		   begin
		    Select @save_LocalAdmin = stuff(@save_LocalAdmin, @charpos, 1, ' ')
		   end	

		Select @charpos = charindex(char(10), @save_LocalAdmin, 1)
		IF @charpos <> 0
		   begin
		    goto label03
	 	   end

		--  Remove char(13)from record
		label04:
		Select @charpos = charindex(char(13), @save_LocalAdmin, 1)
		IF @charpos <> 0
		   begin
		    Select @save_LocalAdmin = stuff(@save_LocalAdmin, @charpos, 1, ' ')
		   end	

		Select @charpos = charindex(char(13), @save_LocalAdmin, 1)
		IF @charpos <> 0
		   begin
		    goto label04
	 	   end

		Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~LocalAdminName~' + RTRIM(LTRIM(@save_LocalAdmin))
		insert into rb_Capture_data (capdata_detail) values (@miscprint)
		--Print @miscprint
		Select @counter = @counter + 1
		Select @counter_txt = str(@counter, 4)



		--  Check to see if there are more rows to process
		Delete from #temp_tbl2 where text01 = @cu23LocalAdmin
		If (select count(*) from #temp_tbl2) > 0
		   begin
			goto start_LOCAL
		   end
	   end






	--  Process for MemoryInfo  -----------------------------------
	--  Capture memory information for the server and drop the results in the temp table (process only works for win2k)
	If substring(@save_OSBuild, 1, 6) in ('NT 5.0', 'NT 5.1', 'NT 5.2') 
	   begin
		Delete from #temp_tbl2
		select @cmd = 'cscript //nologo c:\winnt\system32\logmeminfo.vbs /s' + @save_srvrname2
		--print @cmd
		insert #temp_tbl2(text01) exec master..xp_cmdshell @cmd
		Delete from #temp_tbl2 where text01 is null or text01 = ''
		--select * from #temp_tbl2


		If (select count(*) from #temp_tbl2) > 0
		   begin
			start_MEMInfo:
			Select @cu24Memory = (Select top 1 text01 from #temp_tbl2)
			--print @cu24Memory

			Select @charpos = charindex('Error', @cu24Memory, 1)
			Select @charpos2 = charindex(@save_srvrname2, @cu24Memory, 1)
			IF @charpos = 0 and @charpos2 <> 0
			   begin
				Select @save_MemoryPhysical = rtrim(ltrim(substring(@cu24Memory, 21, 12))) 
				Select @save_MemoryVirtual = rtrim(ltrim(substring(@cu24Memory, 36, 12))) 
				Select @save_MemoryPagefile = rtrim(ltrim(substring(@cu24Memory, 51, 12))) 
				Select @save_MemoryVirtAvail = rtrim(ltrim(substring(@cu24Memory, 66, 12))) 

				Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~MemoryPhysical~' + @save_MemoryPhysical
				insert into rb_Capture_data (capdata_detail) values (@miscprint)
				--Print @miscprint
				Select @counter = @counter + 1
				Select @counter_txt = str(@counter, 4)

				Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~MemoryVirtual~' + @save_MemoryVirtual
				insert into rb_Capture_data (capdata_detail) values (@miscprint)
				--Print @miscprint
				Select @counter = @counter + 1
				Select @counter_txt = str(@counter, 4)

				Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~MemoryPageFile~' + @save_MemoryPagefile
				insert into rb_Capture_data (capdata_detail) values (@miscprint)
				--Print @miscprint
				Select @counter = @counter + 1
				Select @counter_txt = str(@counter, 4)

				Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~MemoryVirtAvail~' + @save_MemoryVirtAvail
				insert into rb_Capture_data (capdata_detail) values (@miscprint)
				--Print @miscprint
				Select @counter = @counter + 1
				Select @counter_txt = str(@counter, 4)

				Select @memory_update_flag = 'y'
			   end


			--  Check to see if there are more rows to process
			Delete from #temp_tbl2 where text01 = @cu24Memory
			If (select count(*) from #temp_tbl2) > 0
			   begin
				goto start_MEMInfo
			   end
		   end
	   end	


	IF @memory_update_flag = 'n' and @save_PSPhysicalMemory <> ' '
	   begin
		Select @save_MemoryPhysical = @save_PSPhysicalMemory 

		Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~MemoryPhysical~' + @save_MemoryPhysical
		insert into rb_Capture_data (capdata_detail) values (@miscprint)
		--Print @miscprint
		Select @counter = @counter + 1
		Select @counter_txt = str(@counter, 4)

		Select @memory_update_flag = 'y'
	   end









	--  Process for PING  -----------------------------------
	--  If the IP Address has not yet been captured, or we are processing a clustered server
	--  try using PING.
	If @IPAddress_flag = 'n' or @cluster_flag = 'y'
	   begin
		Select @IPAddress_flag = 'n'
		Delete from #temp_tbl2
		select @cmd = 'PING ' + @save_srvrname2
		--print @cmd
		insert #temp_tbl2(text01) exec master..xp_cmdshell @cmd
		Delete from #temp_tbl2 where text01 is null or text01 = ''
		Delete from #temp_tbl2 where text01 = char(9)
		--select * from #temp_tbl2


		If (select count(*) from #temp_tbl2) > 0
		   begin
			start_PING:
			Select @cu25PING = (Select top 1 text01 from #temp_tbl2)
			--print @cu25PING


			Select @charpos = charindex('Reply from', @cu25PING, 1)
			IF @charpos <> 0
			   begin
				Select @IPAddress_flag = 'y'
				Select @charpos2 = charindex(':', @cu25PING, 1)
				Select @save_IPAddress = rtrim(substring(@cu25PING, @charpos+11, @charpos2-@charpos-11))
				Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~ServerIP~' + @save_IPAddress
				insert into rb_Capture_data (capdata_detail) values (@miscprint)
				--Print @miscprint
				Select @counter = @counter + 1
				Select @counter_txt = str(@counter, 4)
			   end


			--  Check to see if there are more rows to process
			Delete from #temp_tbl2 where text01 = @cu25PING
			If (select count(*) from #temp_tbl2) > 0
			   begin
				goto start_PING
			   end
		   end
	   end	






	--  Process for SQL  -----------------------------------
	--  If the server we are processing is a SQL Server, gather the SQL info
	If @mssql_flag = 'y' and (select count(*) from #temp_sql) > 0
	   begin
		start_SQL:
		Select @hold_sqlinstance = (Select top 1 text01 from #temp_sql)

		-- Set the sql instance name for osql processing
		Select @charpos = charindex('$', @hold_sqlinstance)
		IF @charpos <> 0
		   begin
			Select @save_srvrname_sql = @save_srvrname2 + '\'+ rtrim(substring(@hold_sqlinstance, @charpos+1, 50))
		   end
		Else
		   begin
			Select @save_srvrname_sql = @save_srvrname2
		   end




		--  Get SQL version information
		Delete from #temp_tbl2
		Select @osqlcmd = 'osql -S' + @save_srvrname_sql + ' -dmaster -Q"select @@version" -n -E'
		--print @osqlcmd
		insert #temp_tbl2(text01) exec master..xp_cmdshell @osqlcmd
		Delete from #temp_tbl2 where text01 is null or text01 = ''
		--select * from #temp_tbl2

		If (select count(*) from #temp_tbl2) > 0
		   begin
			start_SQLversion:
			Select @cu31SQLversion = (Select top 1 text01 from #temp_tbl2)
			--print @cu31SQLversion


			--  Check to make sure we have access to SQL, if not set the sql flag to 'n'
			Select @charpos = charindex('access denied', @cu31SQLversion)
			Select @charpos2 = charindex('Login failed', @cu31SQLversion)

			IF @charpos <> 0 or @charpos2 <> 0
			   begin
				goto end_SQL
			   end

			Select @charpos = charindex('Microsoft SQL Server', @cu31SQLversion)
			IF @charpos <> 0
			   begin
				Select @charpos = charindex('-', @cu31SQLversion, @charpos+20)
				Select @save_SQLVersion = rtrim(substring(@cu31SQLversion, @charpos+2, 50))
				Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~SQLVersion~' + @save_srvrname_sql + '~' + @save_SQLVersion
				insert into rb_Capture_data (capdata_detail) values (@miscprint)
				--Print @miscprint
				Select @counter = @counter + 1
				Select @counter_txt = str(@counter, 4)
			   end
			

			--  Check to see if there are more rows to process
			Delete from #temp_tbl2 where text01 = @cu31SQLversion
			If (select count(*) from #temp_tbl2) > 0
			   begin
				goto start_SQLversion
			   end
		   end





		--  Get SQL collation information
		Delete from #temp_tbl2
		Select @osqlcmd = 'osql -S' + @save_srvrname_sql + ' -dmaster -Q"exec master..sp_helpsort" -n -E -h-1 -w500'
		--print @osqlcmd
		Insert #temp_tbl2 (text01) EXEC master..xp_cmdshell @osqlcmd
		Delete from #temp_tbl2 where text01 is null or text01 = ''
		--select * from #temp_tbl2

		If exists(select * from #temp_tbl2 where text01 like '%sort order%') and substring(@save_SQLVersion, 1, 1) = '8'
		   begin
			Select @cu32SQLcollation = (Select top 1 text01 from #temp_tbl2 where text01 like '%sort order%')
			Select @save_SQLcollation = rtrim(ltrim(@cu32SQLcollation))
			--Print @save_SQLcollation

			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~SQLCollation~' + @save_srvrname_sql + '~' + @save_SQLcollation
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)
		   end







		--  Get SQL service ID information
		Delete from #reginfo
		Select @osqlcmd = 'osql -S' + @save_srvrname_sql + ' -dmaster -Q"master.dbo.xp_regread N''HKEY_LOCAL_MACHINE'', ''System\CurrentControlSet\Services\' + rtrim(@hold_sqlinstance) + ''', N''ObjectName''" -n -E -h-1 -w2000'
		--print @osqlcmd
		Insert #reginfo (value) EXEC master..xp_cmdshell @osqlcmd
		Delete from #reginfo where value is null or value = ''
		Delete from #reginfo where value = char(9)
		Delete from #reginfo where value like '%ObjectName%'
		Delete from #reginfo where value like '%affected%'
		--select * from #reginfo

		If (select count(*) from #reginfo) > 0
		   begin
			Select @cu33SQLserviceID = (Select top 1 value from #reginfo)
			--Print @cu33SQLserviceID

			--  Remove tabs from record
			label09:
			Select @charpos = charindex(char(9), @cu33SQLserviceID, 1)
			IF @charpos <> 0
			   begin
			    Select @cu33SQLserviceID = stuff(@cu33SQLserviceID, @charpos, 1, ' ')
			   end	

			Select @charpos = charindex(char(9), @cu33SQLserviceID, 1)
			IF @charpos <> 0
			   begin
			    goto label09
		 	   end

			Select @save_SQLServiceID = rtrim(ltrim(substring(@cu33SQLserviceID, 1, 500)))

			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~SQLServiceID~' + @save_srvrname_sql + '~' + @save_SQLServiceID
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)
		   end




		--  Get SQL Agent ID information
		Select @charpos = charindex('$', @hold_sqlinstance)
		IF @charpos <> 0
		   begin
			Select @hold_sqlagent = replace(@hold_sqlinstance, 'MSSQL$', 'SQLAgent$')
		   end
		Else
		   begin
			Select @hold_sqlagent = 'SQLServerAgent'
		   end

		delete from #reginfo
		Select @osqlcmd = 'osql -S' + @save_srvrname_sql + ' -dmaster -Q"master.dbo.xp_regread N''HKEY_LOCAL_MACHINE'', ''System\CurrentControlSet\Services\' + @hold_sqlagent + ''', N''ObjectName''" -n -E -h-1 -w2000'
		--print @osqlcmd
		Insert #reginfo (value) EXEC master..xp_cmdshell @osqlcmd
		Delete from #reginfo where value is null or value = ''
		Delete from #reginfo where value = char(9)
		Delete from #reginfo where value like '%ObjectName%'
		Delete from #reginfo where value like '%affected%'
		--select * from #reginfo

		If (select count(*) from #reginfo) > 0
		   begin
			Select @cu34SQLagentID = (Select top 1 value from #reginfo)
			--Print @cu34SQLagentID


			--  Remove tabs from record
			label11:
			Select @charpos = charindex(char(9), @cu34SQLagentID, 1)
			IF @charpos <> 0
			   begin
			    Select @cu34SQLagentID = stuff(@cu34SQLagentID, @charpos, 1, ' ')
			   end	

			Select @charpos = charindex(char(9), @cu34SQLagentID, 1)
			IF @charpos <> 0
			   begin
			    goto label11
		 	   end

			Select @save_SQLagentID = rtrim(ltrim(substring(@cu34SQLagentID, 1, 500)))
			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~SQLAgentID~' + @save_srvrname_sql + '~' + @save_SQLagentID
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)
		   end





		--  Get SQL SysFiles Path information
		delete from #reginfo
		Select @osqlcmd = 'osql -S' + @save_srvrname_sql + ' -dmaster -Q"master.dbo.xp_instance_regread N''HKEY_LOCAL_MACHINE'', ''Software\Microsoft\MSSQLServer\Setup'', N''SQLPath''" -n -E -h-1 -w2000'
		--print @osqlcmd
		Insert #reginfo (value) EXEC master..xp_cmdshell @osqlcmd
		Delete from #reginfo where value is null or value = ''
		Delete from #reginfo where value = char(9)
		Delete from #reginfo where value like '%SQLPath%'
		Delete from #reginfo where value like '%affected%'
		--select * from #reginfo

		If (select count(*) from #reginfo) > 0
		   begin
			Select @cu35SQLSysFilesPath = (Select top 1 value from #reginfo)
			--Print @cu35SQLSysFilesPath


			--  Remove tabs from record
			label13:
			Select @charpos = charindex(char(9), @cu35SQLSysFilesPath, 1)
			IF @charpos <> 0
			   begin
			    Select @cu35SQLSysFilesPath = stuff(@cu35SQLSysFilesPath, @charpos, 1, ' ')
			   end	

			Select @charpos = charindex(char(9), @cu35SQLSysFilesPath, 1)
			IF @charpos <> 0
			   begin
			    goto label13
		 	   end

			Select @save_SQLSysFilesPath = rtrim(ltrim(substring(@cu35SQLSysFilesPath, 1, 500)))
			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~SQLSysFilesPath~' + @save_srvrname_sql + '~' + @save_SQLSysFilesPath
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)
		   end





		--  Get SQL SysDBFiles Path and Error Log Path information
		delete from #reginfo
		Select @osqlcmd = 'osql -S' + @save_srvrname_sql + ' -dmaster -Q"master.dbo.xp_instance_regread N''HKEY_LOCAL_MACHINE'', ''Software\Microsoft\MSSQLServer\Setup'', N''SQLDataRoot''" -n -E -h-1 -w2000'
		--print @osqlcmd
		Insert #reginfo (value) EXEC master..xp_cmdshell @osqlcmd
		Delete from #reginfo where value is null or value = ''
		Delete from #reginfo where value = char(9)
		Delete from #reginfo where value like '%SQLDataRoot%'
		Delete from #reginfo where value like '%affected%'
		--select * from #reginfo

		If (select count(*) from #reginfo) > 0
		   begin
			Select @cu36SQLSysDBFilesPath = (Select top 1 value from #reginfo)
			--Print @cu36SQLSysDBFilesPath


			--  Remove tabs from record
			label15:
			Select @charpos = charindex(char(9), @cu36SQLSysDBFilesPath, 1)
			IF @charpos <> 0
			   begin
			    Select @cu36SQLSysDBFilesPath = stuff(@cu36SQLSysDBFilesPath, @charpos, 1, ' ')
			   end	

			Select @charpos = charindex(char(9), @cu36SQLSysDBFilesPath, 1)
			IF @charpos <> 0
			   begin
			    goto label15
		 	   end

			Select @save_SQLSysDBFilesPath = rtrim(ltrim(substring(@cu36SQLSysDBFilesPath, 1, 500)))
			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~SQLSysDBFilesPath~' + @save_srvrname_sql + '~' + @save_SQLSysDBFilesPath + '\data'
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)

			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~SQLErrorLogsPath~' + @save_srvrname_sql + '~' + @save_SQLSysDBFilesPath + '\log'
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)
		   end




		--  Get SQL Backup File Path information
		delete from #temp_tbl2
		Select @osqlcmd = 'osql -S' + @save_srvrname_sql + ' -dmaster -Q"select physical_device_name from msdb..backupmediafamily where media_set_id = (select max (media_set_id) from msdb..backupmediafamily)" -n -E -h-1'
		--print @osqlcmd
		Insert #temp_tbl2 (text01) EXEC master..xp_cmdshell @osqlcmd
		Delete from #temp_tbl2 where text01 is null or text01 = ''
		Delete from #temp_tbl2 where text01 = char(9)
		--select * from #temp_tbl2


		If (select count(*) from #temp_tbl2 where text01 like '%Backup\%') > 0
		   begin
			Select @cu37SQLBackupFilePath = (Select top 1 text01 from #temp_tbl2 where text01 like '%Backup\%')
			--Print @cu37SQLBackupFilePath

			Select @save_SQLBackupFilePath = ''


		 	Select @charpos = charindex('Backup\', @cu37SQLBackupFilePath)
			IF @charpos <> 0
			   begin
				Select @save_SQLBackupFilePath = rtrim(ltrim(substring(@cu37SQLBackupFilePath, 1, @charpos+5)))
				Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~SQLBackupFilePath~' + @save_srvrname_sql + '~' + @save_SQLBackupFilePath
				insert into rb_Capture_data (capdata_detail) values (@miscprint)
				--Print @miscprint
				Select @counter = @counter + 1
				Select @counter_txt = str(@counter, 4)
			   end

		   end




		--  Get SQL Database information
		delete from #temp_tbl2
		Select @osqlcmd = 'osql -S' + @save_srvrname_sql + ' -dmaster -Q"select name from master..sysdatabases order by name" -n -E -h-1'
		--print @osqlcmd
		Insert #temp_tbl2 (text01) EXEC master..xp_cmdshell @osqlcmd
		Delete from #temp_tbl2 where text01 is null or text01 = ''
		Delete from #temp_tbl2 where text01 = char(9)
		Delete from #temp_tbl2 where text01 like '%affected%'
		--select * from #temp_tbl2


		If (select count(*) from #temp_tbl2) > 0
		   begin
			start_SQLDatabaseName:
			Select @cu38SQLDatabaseName = (Select top 1 text01 from #temp_tbl2)
			--Print @cu38SQLDatabaseName


			Select @save_SQLDatabaseName = rtrim(ltrim(substring(@cu38SQLDatabaseName, 1, 100)))
			Select @miscprint = @save_srvrname2 + '~' + @counter_txt + '~SQLDatabaseName~' + @save_srvrname_sql + '~' + @save_SQLDatabaseName
			insert into rb_Capture_data (capdata_detail) values (@miscprint)
			--Print @miscprint
			Select @counter = @counter + 1
			Select @counter_txt = str(@counter, 4)


			--  Check to see if there are more rows to process
			Delete from #temp_tbl2 where text01 = @cu38SQLDatabaseName
			If (select count(*) from #temp_tbl2) > 0
			   begin
				goto start_SQLDatabaseName
			   end
		   end



		end_SQL:


		--  Check to see if there are more SQL Instances to process
		Delete from #temp_sql where text01 = @hold_sqlinstance
		If (select count(*) from #temp_sql) > 0
		   begin
			goto start_SQL
		   end
	   end





	skip_to_next:

	--  Check to see if there are more servernames to process
	Delete from #temp_tbl where text01 = @cu11SRVRname
	If (select count(*) from #temp_tbl) > 0
	   begin
		goto start_SRVRnames
	   end

   end


---------------------------  Finalization  -----------------------
drop TABLE #temp_tbl
drop TABLE #temp_tbl2
drop TABLE #temp_sql
drop TABLE #reginfo

label99:


GO

ALTER TABLE [dbo].[rb_Admins]  WITH CHECK ADD  CONSTRAINT [FK_rb_Admins_rb_server] FOREIGN KEY([ServerID])
REFERENCES [dbo].[rb_Server] ([ServerID])
GO
ALTER TABLE [dbo].[rb_Admins] CHECK CONSTRAINT [FK_rb_Admins_rb_server]
GO

ALTER TABLE [dbo].[rb_Applications]  WITH CHECK ADD  CONSTRAINT [FK_rb_Applications_rb_server] FOREIGN KEY([ServerID])
REFERENCES [dbo].[rb_Server] ([ServerID])
GO
ALTER TABLE [dbo].[rb_Applications] CHECK CONSTRAINT [FK_rb_Applications_rb_server]
GO

ALTER TABLE [dbo].[rb_Category]  WITH CHECK ADD  CONSTRAINT [FK_rb_Category_rb_server] FOREIGN KEY([ServerID])
REFERENCES [dbo].[rb_Server] ([ServerID])
GO
ALTER TABLE [dbo].[rb_Category] CHECK CONSTRAINT [FK_rb_Category_rb_server]
GO

ALTER TABLE [dbo].[rb_Comments]  WITH CHECK ADD  CONSTRAINT [FK_rb_Comments_rb_server] FOREIGN KEY([ServerID])
REFERENCES [dbo].[rb_Server] ([ServerID])
GO
ALTER TABLE [dbo].[rb_Comments] CHECK CONSTRAINT [FK_rb_Comments_rb_server]
GO

ALTER TABLE [dbo].[rb_SQLInfo]  WITH CHECK ADD  CONSTRAINT [FK_rb_SQLInfo_rb_server] FOREIGN KEY([ServerID])
REFERENCES [dbo].[rb_Server] ([ServerID])
GO
ALTER TABLE [dbo].[rb_SQLInfo] CHECK CONSTRAINT [FK_rb_SQLInfo_rb_server]
GO

ALTER TABLE [dbo].[rb_Dbases]  WITH CHECK ADD  CONSTRAINT [FK_rb_Dbases_rb_SQLInfo] FOREIGN KEY([SQLID])
REFERENCES [dbo].[rb_SQLInfo] ([SQLID])
GO
ALTER TABLE [dbo].[rb_Dbases] CHECK CONSTRAINT [FK_rb_Dbases_rb_SQLInfo]
GO

ALTER TABLE [dbo].[rb_Drives]  WITH CHECK ADD  CONSTRAINT [FK_rb_Drives_rb_server] FOREIGN KEY([ServerID])
REFERENCES [dbo].[rb_Server] ([ServerID])
GO
ALTER TABLE [dbo].[rb_Drives] CHECK CONSTRAINT [FK_rb_Drives_rb_server]
GO

ALTER TABLE [dbo].[rb_HotFixes]  WITH CHECK ADD  CONSTRAINT [FK_rb_HotFixes_rb_server] FOREIGN KEY([ServerID])
REFERENCES [dbo].[rb_Server] ([ServerID])
GO
ALTER TABLE [dbo].[rb_HotFixes] CHECK CONSTRAINT [FK_rb_HotFixes_rb_server]
GO

ALTER TABLE [dbo].[rb_Memory]  WITH CHECK ADD  CONSTRAINT [FK_rb_Memory_rb_server] FOREIGN KEY([ServerID])
REFERENCES [dbo].[rb_Server] ([ServerID])
GO
ALTER TABLE [dbo].[rb_Memory] CHECK CONSTRAINT [FK_rb_Memory_rb_server]
GO

ALTER TABLE [dbo].[rb_Passwords]  WITH CHECK ADD  CONSTRAINT [FK_rb_Passwords_rb_server] FOREIGN KEY([ServerID])
REFERENCES [dbo].[rb_Server] ([ServerID])
GO
ALTER TABLE [dbo].[rb_Passwords] CHECK CONSTRAINT [FK_rb_Passwords_rb_server]
GO

ALTER TABLE [dbo].[rb_Reboot]  WITH CHECK ADD  CONSTRAINT [FK_rb_Reboot_rb_server] FOREIGN KEY([ServerID])
REFERENCES [dbo].[rb_Server] ([ServerID])
GO
ALTER TABLE [dbo].[rb_Reboot] CHECK CONSTRAINT [FK_rb_Reboot_rb_server]
GO

ALTER TABLE [dbo].[rb_RelatedServers]  WITH CHECK ADD  CONSTRAINT [FK_rb_RelatedServers_rb_server] FOREIGN KEY([ServerID])
REFERENCES [dbo].[rb_Server] ([ServerID])
GO
ALTER TABLE [dbo].[rb_RelatedServers] CHECK CONSTRAINT [FK_rb_RelatedServers_rb_server]
GO

ALTER TABLE [dbo].[rb_Services]  WITH CHECK ADD  CONSTRAINT [FK_rb_Services_rb_server] FOREIGN KEY([ServerID])
REFERENCES [dbo].[rb_Server] ([ServerID])
GO
ALTER TABLE [dbo].[rb_Services] CHECK CONSTRAINT [FK_rb_Services_rb_server]
GO

ALTER TABLE [dbo].[rb_Support]  WITH CHECK ADD  CONSTRAINT [FK_rb_support_rb_server] FOREIGN KEY([ServerID])
REFERENCES [dbo].[rb_Server] ([ServerID])
GO
ALTER TABLE [dbo].[rb_Support] CHECK CONSTRAINT [FK_rb_support_rb_server]
GO

