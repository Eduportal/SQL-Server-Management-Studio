-------------------------------------------------
--Script to create SDShadowDB db and tables, you may have to update the FILENAMEs
-------------------------------------------------

USE [master]
GO
/****** Object:  Database [SDShadowDB]    Script Date: 09/18/2007 11:19:50 ******/
--CREATE DATABASE [SDShadowDB] --ON  PRIMARY 
--( NAME = N'SDShadowDB', FILENAME = N'H:\Microsoft SQL Server\MSSQL.1\MSSQL\Data\SDShadowDB.mdf' , SIZE = 3072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
-- LOG ON 
--( NAME = N'SDShadowDB_log', FILENAME = N'f:\microsoft sql server\SQLBUVS1\Logs\SDShadowDB_log.ldf' , SIZE = 2560KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
EXEC dbo.sp_dbcmptlevel @dbname=N'SDShadowDB', @new_cmptlevel=90
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [SDShadowDB].[dbo].[sp_fulltext_database] @action = 'disable'
end
GO
ALTER DATABASE [SDShadowDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [SDShadowDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [SDShadowDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [SDShadowDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [SDShadowDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [SDShadowDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [SDShadowDB] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [SDShadowDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [SDShadowDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [SDShadowDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [SDShadowDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [SDShadowDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [SDShadowDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [SDShadowDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [SDShadowDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [SDShadowDB] SET  ENABLE_BROKER 
GO
ALTER DATABASE [SDShadowDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [SDShadowDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [SDShadowDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [SDShadowDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [SDShadowDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [SDShadowDB] SET  READ_WRITE 
GO
ALTER DATABASE [SDShadowDB] SET RECOVERY FULL 
GO
ALTER DATABASE [SDShadowDB] SET  MULTI_USER 
GO
ALTER DATABASE [SDShadowDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [SDShadowDB] SET DB_CHAINING OFF 
go
-------------------------------------------------
USE [SDShadowDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[branchtypes](
      [id] [int] NOT NULL,
      [branchtype] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
      [description] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_branchtypes] PRIMARY KEY CLUSTERED 
(
      [id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
go
-------------------------------------------------
USE [SDShadowDB]
GO
/****** Object:  Table [dbo].[enlistments]    Script Date: 09/26/2007 10:24:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[enlistments](
      [creationdate] [datetime] NOT NULL CONSTRAINT [DF_enlistments_creationdate]  DEFAULT (getdate()),
      [startsyncdate] [datetime] NOT NULL,
      [endsyncdate] [datetime] NOT NULL,
      [emailaddress] [nvarchar](30) NOT NULL,
      [branchid] [smallint] NOT NULL,
      [branchviewname] [nvarchar](100) NOT NULL CONSTRAINT [DF_enlistments_branchviewname]  DEFAULT (N'none'),
      [branchtype] [nvarchar](20) NOT NULL CONSTRAINT [DF_enlistments_branchtype]  DEFAULT (N'none'),
      [prefix] [nvarchar](256) NOT NULL,
      [isArchive] [bit] NOT NULL CONSTRAINT [DF_enlistments_isArchieve]  DEFAULT ((1)),
      [doSync] [bit] NOT NULL CONSTRAINT [DF_enlistments_doSync]  DEFAULT ((1)),
      [doremove] [bit] NOT NULL,
      [filelog] [int] NOT NULL CONSTRAINT [DF_enlistments_filelog]  DEFAULT ((0)),
      [syncmsglog] [int] NOT NULL CONSTRAINT [DF_enlistments_syncmsglog]  DEFAULT ((1)),
      [share] [nvarchar](256) NOT NULL,
      [port] [nvarchar](50) NOT NULL,
      [client] [nvarchar](256) NOT NULL,
      [logDuration] [smallint] NOT NULL CONSTRAINT [DF_enlistments_logDuration]  DEFAULT ((7)),
      [branchState] [nvarchar](20) NOT NULL CONSTRAINT [DF_enlistments_branchState]  DEFAULT (N'new'),
      [genClient] [bit] NOT NULL CONSTRAINT [DF_enlistments_genClient]  DEFAULT ((0)),
 CONSTRAINT [PK_enlistments] PRIMARY KEY CLUSTERED 
(
      [branchid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The date the isArchieve flag was set to false' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'enlistments', @level2type=N'COLUMN',@level2name=N'startsyncdate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The date the isArchieve flag was set to true' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'enlistments', @level2type=N'COLUMN',@level2name=N'endsyncdate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'the users email address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'enlistments', @level2type=N'COLUMN',@level2name=N'emailaddress'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'branch id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'enlistments', @level2type=N'COLUMN',@level2name=N'branchid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'depot branch prefix for the path' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'enlistments', @level2type=N'COLUMN',@level2name=N'prefix'
GO
-------------------------------------------------
USE [SDShadowDB]
GO
/****** Object:  Table [dbo].[paths]    Script Date: 09/05/2007 09:12:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[paths](
      [pathid] [int] IDENTITY(1,1) NOT NULL,
      [branchid] [smallint] NOT NULL,
      [duration] [bigint] NOT NULL CONSTRAINT [DF_paths_duration]  DEFAULT ((0)),
      [numberfiles] [bigint] NOT NULL CONSTRAINT [DF_paths_numberfiles]  DEFAULT ((0)),
      [sizefiles] [bigint] NOT NULL CONSTRAINT [DF_paths_sizefiles]  DEFAULT ((0)),
      [state] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
      [path] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
      [options] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_paths_options]  DEFAULT ('no options'),
      [creationdate] [datetime] NOT NULL CONSTRAINT [DF_paths_creationdate]  DEFAULT (getdate()),
      [startsyncdate] [datetime] NOT NULL CONSTRAINT [DF_paths_startsyncdate]  DEFAULT (getdate()),
      [endsyncdate] [datetime] NOT NULL CONSTRAINT [DF_paths_endsyndate]  DEFAULT (getdate()),
 CONSTRAINT [PK_paths] PRIMARY KEY CLUSTERED 
(
      [pathid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'branch id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'paths', @level2type=N'COLUMN',@level2name=N'branchid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'How long it took to sync thread to run (in milliseconds, negative means checkit)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'paths', @level2type=N'COLUMN',@level2name=N'duration'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'number of files synced' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'paths', @level2type=N'COLUMN',@level2name=N'numberfiles'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'size of all the files synced (if possible, from file system)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'paths', @level2type=N'COLUMN',@level2name=N'sizefiles'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'current state of the sync thread, also the error that occured if any' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'paths', @level2type=N'COLUMN',@level2name=N'state'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The prefix plus the standard path used to sync (must be < 256 chars)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'paths', @level2type=N'COLUMN',@level2name=N'path'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'paths'
GO
ALTER TABLE [dbo].[paths]  WITH CHECK ADD  CONSTRAINT [FK_paths_enlistments] FOREIGN KEY([branchid])
REFERENCES [dbo].[enlistments] ([branchid])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[paths] CHECK CONSTRAINT [FK_paths_enlistments]
go
-------------------------------------------------
USE [SDShadowDB]
GO
/****** Object:  Table [dbo].[pathtypes]    Script Date: 08/28/2007 09:40:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[pathtypes](
      [id] [int] NOT NULL,
      [action] [int] NOT NULL CONSTRAINT [DF_pathtypes_action]  DEFAULT ((0)),
      [partialpath] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
      [updatewithpath] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_pathtypes_updatewithpath]  DEFAULT (N'none')
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[pathtypes]  WITH CHECK ADD  CONSTRAINT [FK_branchtypes_pathtypes] FOREIGN KEY([id])
REFERENCES [dbo].[branchtypes] ([id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[pathtypes] CHECK CONSTRAINT [FK_branchtypes_pathtypes]
go
-------------------------------------------------
USE [SDShadowDB]
GO
/****** Object:  Table [dbo].[syncmessages]    Script Date: 10/04/2007 09:48:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[syncmessages](
	[timestamp] [datetime] NOT NULL CONSTRAINT [DF_syncmessages_timestamp]  DEFAULT (getdate()),
	[branchid] [smallint] NOT NULL,
	[pathid] [int] NOT NULL,
	[messageid] [bigint] IDENTITY(1,1) NOT NULL,
	[type] [int] NOT NULL CONSTRAINT [DF_syncmessages_type]  DEFAULT ((0)),
	[eventid] [int] NOT NULL CONSTRAINT [DF_syncmessages_eventid]  DEFAULT ((0)),
	[message] [nvarchar](max) NOT NULL CONSTRAINT [DF_syncmessages_message]  DEFAULT ((1)),
 CONSTRAINT [PK_syncmessages] PRIMARY KEY CLUSTERED 
(
	[messageid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
go
-------------------------------------------------
--Script to create the SDShadowDB stored procedures
-------------------------------------------------
create view branchState AS
SELECT dbo.enlistments.branchid, dbo.paths.state, 
 CASE state WHEN 'synced' THEN 'synced' 
 WHEN 'nofilesynced' THEN 'synced' 
 ELSE 'checksync' END AS branchState, 1 AS id
FROM dbo.enlistments INNER JOIN
dbo.paths ON dbo.enlistments.branchid = dbo.paths.branchid
GROUP BY dbo.enlistments.branchid, dbo.paths.state
go
-------------------------------------------------
CREATE  PROCEDURE [dbo].[branchSyncMeter]
AS
  SELECT  branchState, sum(id)
   from branchState
   group by branchState
   order by branchstate asc
RETURN      
go
-------------------------------------------------
CREATE PROCEDURE dbo.deleteEnlistment 
      @branchid smallint
AS
DELETE enlistments WHERE branchid = @branchid 
RETURN
go
-------------------------------------------------
CREATE PROCEDURE dbo.deletePath 
      @branchid int
AS
DELETE paths WHERE branchid = @branchid 
RETURN
go
-------------------------------------------------
CREATE PROCEDURE [dbo].[deleteSyncMsgs]
      @branchid smallint, 
      @time datetime
AS
DELETE syncmessages 
WHERE ((branchid = @branchid) AND (timestamp < @time)) 
RETURN
go
-------------------------------------------------
CREATE PROCEDURE [dbo].[getBranchState]
  @branchid as smallint
AS
SELECT distinct top 1 branchid, branchState FROM branchState
where branchid = @branchid
RETURN
go
-------------------------------------------------
CREATE PROCEDURE dbo.importexternalbranches
AS
SELECT BranchID,BranchViewName,IsArchived,BranchType,DepotPathPrefix
FROM IntegrationDB.INTEGRATION_SCHEMA.Branch 
WHERE(((IsArchived = 'false') OR (IsArchived = 'true')) 
AND (BranchType = 'Improvement'))
ORDER BY BranchID;
RETURN
go
--------------------------------------------------
CREATE PROCEDURE dbo.insertEnlistment 
      @branchid smallint,
      @branchviewname nvarchar(100),
      @branchtype nvarchar(20),
      @startsyncdate datetime,
      @endsyncdate datetime,
      @prefix nvarchar(256),
      @emailaddress nvarchar(30),
      @isarchive bit,
      @dosync bit,
      @doremove bit,
      @share nvarchar(256),
      @port nvarchar(50),
      @client nvarchar(256),
      @filelog int,
      @syncmsglog int
AS
Insert INTO enlistments
(branchid,branchviewname,branchtype,startsyncdate,endsyncdate,prefix,
  emailaddress,isarchive,dosync,doremove,share,port,client,filelog,syncmsglog) 
values 
(@branchid,@branchviewname,@branchtype,@startsyncdate,@endsyncdate,@prefix,
  @emailaddress,@isarchive,@dosync,@doremove,@share,@port,@client,@filelog,@syncmsglog);
RETURN
go
-------------------------------------------------
CREATE PROCEDURE dbo.insertPath 
      @branchid smallint,
      @state nvarchar(256),
      @path nvarchar(256),
      @duration bigint,
      @options nvarchar(50)
AS
Insert INTO paths (branchid,state,path,duration,options) 
values (@branchid,@state,@path,@duration,@options);
RETURN
go
-------------------------------------------------
CREATE PROCEDURE dbo.insertSyncMsg
    @branchid smallint,
    @pathid int,
    @msg  nvarchar(max),
    @type int,
    @eid int
AS
Insert INTO syncmessages (branchid,pathid,message,type,eventid) 
values (@branchid,@pathid,@msg,@type,@eid);
RETURN
go
-------------------------------------------------
CREATE PROCEDURE [dbo].[isBranchSynced] 
      @branchid smallint
AS
--DECLARE @RC int
--EXECUTE @RC = [SDShadowDB].[dbo].[getBranchState] 
--   @branchid
SELECT branchid, branchState FROM enlistments
where branchid = @branchid
RETURN
go
-------------------------------------------------
CREATE PROCEDURE [dbo].[selectActivePathsToSync]
    @fromBranch smallint,
      @toBranch smallint      
AS
SELECT enlistments.emailaddress, enlistments.branchid, 
           enlistments.branchviewname, enlistments.branchtype,enlistments.prefix,
           enlistments.isArchive, enlistments.doSync, 
           enlistments.doremove, enlistments.port,
           enlistments.client,  enlistments.share, 
           enlistments.endsyncdate, enlistments.startsyncdate, 
           enlistments.filelog, enlistments.syncmsglog, enlistments.branchstate,
           enlistments.genClient,
           paths.duration, paths.path, paths.pathid, paths.state, paths.options, 
           paths.numberfiles, paths.sizefiles
           FROM enlistments 
           INNER JOIN paths ON enlistments.branchid = paths.branchid
           WHERE (((enlistments.branchid >= @fromBranch) AND 
                  (enlistments.branchid <= @toBranch))) AND 
                  (paths.state = 'syncpending' OR 
                   paths.state = 'synced' OR
                   paths.state = 'checksync')
           order by branchid;
RETURN
go
-------------------------------------------------
CREATE PROCEDURE dbo.selectAllEnlistments
AS
BEGIN
Select * from enlistments
END
return
go
-------------------------------------------------
CREATE PROCEDURE [dbo].[selectBranches]
AS
SELECT enlistments.branchid, enlistments.branchviewname, enlistments.branchtype, 
       enlistments.isArchive, enlistments.doSync, enlistments.doremove, 
       enlistments.endsyncdate, enlistments.startsyncdate, 
       enlistments.filelog, enlistments.syncmsglog,
       paths.duration, paths.path, paths.pathid, paths.state, paths.options, 
       paths.numberfiles, paths.sizefiles,
         CASE state
         WHEN 'synced'THEN 'synced'
         WHEN 'nofilesynced' THEN 'synced'
         ELSE 'checksync'
         END AS branchState
       FROM enlistments 
       INNER JOIN paths ON enlistments.branchid = paths.branchid
       ORDER BY branchviewname, State ASC;
RETURN
go
-------------------------------------------------
CREATE PROCEDURE dbo.selectBranchPath 
      @branchid smallint,
      @path nvarchar(256)
AS
SELECT branchid, pathid, path from paths
WHERE ((paths.branchid=@branchid) and (paths.path=@path));
RETURN
go
-------------------------------------------------
CREATE PROCEDURE dbo.selectBranchType
      @type nvarchar(20)
AS
SELECT branchtypes.id, 
       branchtypes.branchtype, 
       branchtypes.description, 
       pathtypes.partialpath,
       pathtypes.action,
       pathtypes.updatewithpath
           FROM branchtypes 
           INNER JOIN pathtypes ON branchtypes.id = pathtypes.id
           WHERE  (branchtypes.branchtype = @type);
RETURN
go
-------------------------------------------------
CREATE PROCEDURE dbo.selectEnlistments
      @branchid smallint
AS
SELECT * from enlistments
WHERE enlistments.branchid = @branchid;
RETURN
go
-------------------------------------------------
CREATE PROCEDURE dbo.selectMsgs
      @pathid int
AS
SELECT * from syncmessages
WHERE syncmessages.pathid = @pathid;
RETURN
go
-------------------------------------------------
CREATE PROCEDURE [dbo].[selectMsgsByBranch]
      @fromBranch int,
    @toBranch int
AS
SELECT * from syncmessages
WHERE ((syncmessages.branchid >= @fromBranch) and 
       (syncmessages.branchid <= @toBranch))
RETURN
go
-------------------------------------------------
CREATE  PROCEDURE dbo.selectPaths
      @state nvarchar(256)
AS
SELECT * from paths
WHERE paths.state like @state + '%';
RETURN
go
-------------------------------------------------
CREATE PROCEDURE [dbo].[selectPathsByState]
      @fromBranch smallint,
      @toBranch smallint,
      @state nvarchar(20)     
AS
SELECT enlistments.emailaddress, enlistments.branchid, 
           enlistments.branchviewname, enlistments.branchtype,enlistments.prefix,
           enlistments.isArchive, enlistments.doSync, 
           enlistments.doremove, enlistments.port,
           enlistments.client,  enlistments.share, 
           enlistments.endsyncdate, enlistments.startsyncdate,
           enlistments.filelog, enlistments.syncmsglog, 
           paths.duration, paths.path, paths.pathid, paths.state, paths.options, 
           paths.numberfiles, paths.sizefiles, 
           paths.startsyncdate as pathstartsyncdate, paths.endsyncdate as pathendsyncdate
           FROM enlistments 
           INNER JOIN paths ON enlistments.branchid = paths.branchid
           WHERE ((enlistments.branchid >= @fromBranch) AND 
                  (enlistments.branchid <= @toBranch) AND
                  (paths.state = @state))
Order By enlistments.branchviewname, enlistments.branchid
RETURN
go
-------------------------------------------------
CREATE PROCEDURE dbo.selectPathsToSync
      @fromBranch smallint,
      @toBranch smallint      
AS
SELECT enlistments.emailaddress, enlistments.branchid, 
           enlistments.branchviewname, enlistments.branchtype,enlistments.prefix,
           enlistments.isArchive, enlistments.doSync, 
           enlistments.doremove, enlistments.port,
           enlistments.client,  enlistments.share, 
           enlistments.endsyncdate, enlistments.startsyncdate,
           enlistments.filelog, enlistments.syncmsglog, enlistments.branchstate,
           enlistments.genClient,
           paths.duration, paths.path, paths.pathid, paths.state, paths.options, 
           paths.numberfiles, paths.sizefiles
           FROM enlistments 
           INNER JOIN paths ON enlistments.branchid = paths.branchid
           WHERE ((enlistments.branchid >= @fromBranch) AND 
                  (enlistments.branchid <= @toBranch));
RETURN
go
-------------------------------------------------
CREATE PROCEDURE [dbo].[stateMeter]
AS
SELECT state, count(*) id, 
 CASE state
 WHEN 'synced'THEN 'synced'
 WHEN 'nofilesynced' THEN 'synced'
 ELSE 'checksync'
 END AS branchState
from paths
group by state
RETURN      
go
-------------------------------------------------
CREATE PROCEDURE [dbo].[syncMeter]
AS
SELECT enlistments.branchid, enlistments.branchviewname, enlistments.branchtype, 
       paths.state,
         CASE state
         WHEN 'synced'THEN 'synced'
         WHEN 'nofilesynced' THEN 'synced'
         ELSE 'checksync'
         END AS branchState
       FROM enlistments 
       INNER JOIN paths ON enlistments.branchid = paths.branchid
       ORDER BY branchviewname, State ASC;
RETURN      
go
-------------------------------------------------
CREATE PROCEDURE dbo.updateBranchPath
    @branchid smallint,
    @pathid int, 
      @path nvarchar(256)
AS
UPDATE paths 
SET paths.path = @path
WHERE ((paths.branchid = @branchid) and (paths.pathid = @pathid))
return
go
-------------------------------------------------
CREATE PROCEDURE dbo.updateEnlistment
      @branchid smallint,
      @isarchive bit
AS
UPDATE enlistments
SET enlistments.isarchive = @isarchive
WHERE enlistments.branchid = @branchid
return
go

-------------------------------------------------
CREATE PROCEDURE [dbo].[updateEnlistmentClearRunning]
    @fromBranch smallint,
	@toBranch smallint	
AS
UPDATE enlistments
SET enlistments.branchstate = 'idle' where ((branchid >= @frombranch) and (branchid <= @toBranch))
return
go
-------------------------------------------------
CREATE PROCEDURE dbo.updateEnlistmentEndDate
      @branchid smallint,
      @startsyncdate datetime,
      @endsyncdate datetime,
      @dosync bit
AS
UPDATE enlistments
SET enlistments.endsyncdate = @endsyncdate,
    enlistments.startsyncdate = @startsyncdate,
    enlistments.dosync = @dosync
WHERE enlistments.branchid = @branchid
return
go
--------------------------------------------------
CREATE PROCEDURE [dbo].[updateEnlistmentState]
      @branchid smallint,
      @state nvarchar(20)
AS
UPDATE enlistments
SET enlistments.branchstate = @state
WHERE enlistments.branchid = @branchid
return
go
--------------------------------------------------
CREATE PROCEDURE dbo.updateFolder
    @pathid int, 
      @folder nvarchar(256)
AS
UPDATE paths SET paths.path = @folder
WHERE paths.pathid = @pathid 
return
go
-------------------------------------------------
CREATE PROCEDURE dbo.updatePath
    @pathid int, 
      @duration bigint,
      @state nvarchar(256),
      @nofiles bigint,
      @sizefile bigint
AS
UPDATE paths 
SET paths.duration = @duration, 
    paths.state = @state, 
    paths.numberfiles = @nofiles,
    paths.sizefiles = @sizefile
WHERE paths.pathid = @pathid
return
go
-------------------------------------------------
CREATE PROCEDURE dbo.updatePathStats
    @pathid int, 
      @duration bigint,
      @state nvarchar(256),
      @nofiles bigint,
      @sizefile bigint,
      @options nvarchar(50),
      @startsyncdate datetime,
      @endsyncdate datetime
AS
UPDATE paths SET paths.duration = @duration, paths.state = @state, 
paths.numberfiles = @nofiles, paths.sizefiles = @sizefile, paths.options = @options,
paths.startsyncdate = @startsyncdate, paths.endsyncdate = @endsyncdate
WHERE paths.pathid = @pathid
Return
go
------------------------------------------------------
USE [SDShadowDB]
CREATE ROLE [SDShadowService] AUTHORIZATION [dbo]
GO
------------------------------------------------------
use [SDShadowDB]
GRANT SELECT ON [dbo].[branchState] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[branchSyncMeter] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[deleteEnlistment] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[deletePath] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[deleteSyncMsgs] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[getBranchState] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[importexternalbranches] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[insertEnlistment] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[insertPath] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[insertSyncMsg] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[isBranchSynced] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[selectActivePathsToSync] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[selectAllEnlistments] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[selectBranches] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[selectBranchPath] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[selectBranchType] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[selectEnlistments] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[selectMsgs] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[selectMsgsByBranch] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[selectPaths] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[selectPathsByState] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[selectPathsToSync] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[syncMeter] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[updateBranchPath] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[updateEnlistment] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[updateEnlistmentClearRunning] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[updateEnlistmentEndDate] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[updateEnlistmentState] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[updateFolder] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[updatePath] TO [SDShadowService]
GRANT EXECUTE ON [dbo].[updatePathStats] TO [SDShadowService]
GO
------------------------------------------------------
use [SDShadowDB]
GRANT INSERT ON [dbo].[enlistments] TO [SDShadowService] AS [dbo]
GRANT SELECT ON [dbo].[enlistments] TO [SDShadowService] AS [dbo]
GRANT INSERT ON [dbo].[paths] TO [SDShadowService] AS [dbo]
GRANT SELECT ON [dbo].[paths] TO [SDShadowService] AS [dbo]
GRANT INSERT ON [dbo].[branchtypes] TO [SDShadowService] AS [dbo]
GRANT SELECT ON [dbo].[branchtypes] TO [SDShadowService] AS [dbo]
GRANT INSERT ON [dbo].[pathtypes] TO [SDShadowService] AS [dbo]
GRANT SELECT ON [dbo].[pathtypes] TO [SDShadowService] AS [dbo]
GRANT INSERT ON [dbo].[syncmessages] TO [SDShadowService] AS [dbo]
GRANT SELECT ON [dbo].[syncmessages] TO [SDShadowService] AS [dbo]
GO
------------------------------------------------------
Use SDShadowDB
INSERT INTO [SDShadowDB].[dbo].[branchtypes]([id],[branchtype],[description])
     VALUES (0 ,'Improvement' ,'Improvement')
INSERT INTO [SDShadowDB].[dbo].[branchtypes]([id],[branchtype],[description])
     VALUES (1 ,'custom' ,'custom')
go
------------------------------------------------------
Use SDShadowDB
INSERT INTO [SDShadowDB].[dbo].[pathtypes] ([id],[action],[partialpath],[updatewithpath])
     VALUES(0,0,'test/ntdbms/SWS/...','none')
INSERT INTO [SDShadowDB].[dbo].[pathtypes] ([id],[action],[partialpath],[updatewithpath])
     VALUES(0,0,'test/XML/...','none')
INSERT INTO [SDShadowDB].[dbo].[pathtypes] ([id],[action],[partialpath],[updatewithpath])
     VALUES(0,0,'test/ReplTest/WTT/...','none')
INSERT INTO [SDShadowDB].[dbo].[pathtypes] ([id],[action],[partialpath],[updatewithpath])
     VALUES(0,0,'testsrc/komodo/...','none')
INSERT INTO [SDShadowDB].[dbo].[pathtypes] ([id],[action],[partialpath],[updatewithpath])
     VALUES(0,0,'testsrc/setup/GQL/...','none')
INSERT INTO [SDShadowDB].[dbo].[pathtypes] ([id],[action],[partialpath],[updatewithpath])
     VALUES(0,0,'Test/AS_SP2DBUnify/EngineTest/Test Cases/...','none')
INSERT INTO [SDShadowDB].[dbo].[pathtypes] ([id],[action],[partialpath],[updatewithpath])
     VALUES(0,0,'TestSrc/DTS/test/...','none')
INSERT INTO [SDShadowDB].[dbo].[pathtypes] ([id],[action],[partialpath],[updatewithpath])
     VALUES(0,0,'TestSrc/Rosetta/...','none')
INSERT INTO [SDShadowDB].[dbo].[pathtypes] ([id],[action],[partialpath],[updatewithpath])
     VALUES(0,0,'Test/ntdbms/EngineGQL/...','none')
INSERT INTO [SDShadowDB].[dbo].[pathtypes] ([id],[action],[partialpath],[updatewithpath])
     VALUES(0,0,'testsrc/ntdbms/sqlncli/...','none')
INSERT INTO [SDShadowDB].[dbo].[pathtypes] ([id],[action],[partialpath],[updatewithpath])
     VALUES(1,0,'test/XML/...','none')
go
------------------------------------------------------
--end
------------------------------------------------------


