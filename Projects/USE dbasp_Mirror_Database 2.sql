
USE [dbaadmin]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


---- ADD DYNAMIC LINKED SERVER SO PROCEDURE DOES NOT FAIL
--IF  EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = N'DYN_DBA_RMT')
--	EXEC master.dbo.sp_dropserver @server=N'DYN_DBA_RMT', @droplogins='droplogins'
	
--EXEC sp_addlinkedserver 
--		@server='DYN_DBA_RMT'
--		,@srvproduct=''
--		,@provider='SQLNCLI'
--		,@datasrc='SEAPEDSQL0A'
--GO
--EXEC master.dbo.sp_serveroption @server=N'DYN_DBA_RMT', @optname=N'collation compatible', @optvalue=N'true'
--EXEC master.dbo.sp_serveroption @server=N'DYN_DBA_RMT', @optname=N'rpc', @optvalue=N'true'
--EXEC master.dbo.sp_serveroption @server=N'DYN_DBA_RMT', @optname=N'rpc out', @optvalue=N'true'
--EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DYN_DBA_RMT', @locallogin = N'AMER\s-sledridge', @useself = N'False', @rmtuser = N'dbasledridge', @rmtpassword = N'Tigger4U'
--GO


----DELETE dbaadmin.dbo.local_control  where subject ='restore_override'

----INSERT INTO dbaadmin.dbo.local_control (subject,detail01,detail02,detail03)
----SELECT	'restore_override'
----	,T3.name	
----	,T2.name	
----	,LEFT(T2.physical_name,(LEN(T2.physical_name)+1-CHARINDEX('\',REVERSE(T2.physical_name))))

----from DYN_DBA_RMT.master.sys.database_mirroring T1
----JOIN DYN_DBA_RMT.master.sys.master_files T2
----on T1.database_id = t2.database_id
----JOIN DYN_DBA_RMT.master.sys.databases T3
----ON T1.database_id = T3.database_id
----WHERE T3.NAME NOT IN ('master','model','msdb','tempdb','dbaadmin','dbaperf','deplcontrol','deplinfo','SQLdeploy')


--SELECT	'EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] ''SEAPSQLTFS0A'','''+name+''',NULL,NULL,1,0; EXEC(''ALTER DATABASE ['+name+'] SET SAFETY OFF'') AT DYN_DBA_RMT'
--FROM	master.sys.databases
--WHERE NAME NOT IN ('master','model','msdb','tempdb','dbaadmin','dbaperf','deplcontrol','deplinfo','SQLdeploy')



--SELECT * FROM DYN_DBA_RMT.master.sys.databases 




--SELECT	'EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] ''SEAPEDSQL0A'','''+name+''',NULL,NULL,1,0; EXEC(''ALTER DATABASE ['+name+'] SET SAFETY OFF'') AT DYN_DBA_RMT'
--FROM	master.sys.databases
--WHERE NAME NOT IN ('master','model','msdb','tempdb','dbaadmin','dbaperf','deplcontrol','deplinfo','SQLdeploy')



--EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLDIST0A','DataLogDB',NULL,NULL,1,0;	EXEC('ALTER DATABASE [DataLogDB] SET SAFETY OFF') AT DYN_DBA_RMT
--EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLDIST0A','DeliveryDB',NULL,NULL,1,0;	EXEC('ALTER DATABASE [DeliveryDB] SET SAFETY OFF') AT DYN_DBA_RMT
--EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLDIST0A','FeedsDB',NULL,NULL,1,0;	EXEC('ALTER DATABASE [FeedsDB] SET SAFETY OFF') AT DYN_DBA_RMT
--EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLDIST0A','IngestionDB',NULL,NULL,1,0;	EXEC('ALTER DATABASE [IngestionDB] SET SAFETY OFF') AT DYN_DBA_RMT

--EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLTFS0A','ReportServer',NULL,NULL,1,0; EXEC('ALTER DATABASE [ReportServer] SET SAFETY OFF') AT DYN_DBA_RMT
--EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLTFS0A','ReportServerTempDB',NULL,NULL,1,0; EXEC('ALTER DATABASE [ReportServerTempDB] SET SAFETY OFF') AT DYN_DBA_RMT
--EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLTFS0A','TeamCity',NULL,NULL,1,0; EXEC('ALTER DATABASE [TeamCity] SET SAFETY OFF') AT DYN_DBA_RMT
--EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLTFS0A','Tfs_Configuration',NULL,NULL,1,0; EXEC('ALTER DATABASE [Tfs_Configuration] SET SAFETY OFF') AT DYN_DBA_RMT
--EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLTFS0A','Tfs_Getty',NULL,NULL,1,0; EXEC('ALTER DATABASE [Tfs_Getty] SET SAFETY OFF') AT DYN_DBA_RMT
--EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLTFS0A','Tfs_Warehouse',NULL,NULL,1,0; EXEC('ALTER DATABASE [Tfs_Warehouse] SET SAFETY OFF') AT DYN_DBA_RMT
--EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLTFS0A','WSS_AdminContent',NULL,NULL,1,0; EXEC('ALTER DATABASE [WSS_AdminContent] SET SAFETY OFF') AT DYN_DBA_RMT
--EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLTFS0A','WSS_Config',NULL,NULL,1,0; EXEC('ALTER DATABASE [WSS_Config] SET SAFETY OFF') AT DYN_DBA_RMT
--EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLTFS0A','WSS_Content',NULL,NULL,1,0; EXEC('ALTER DATABASE [WSS_Content] SET SAFETY OFF') AT DYN_DBA_RMT
--EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLTFS0A','anthill3',NULL,NULL,1,0; EXEC('ALTER DATABASE [anthill3] SET SAFETY OFF') AT DYN_DBA_RMT


--DECLARE @DBName sysname
--DECLARE @CMD VARCHAR(MAX)
--SET @DBName = 'ReportServerTempDB'
--SET @CMD = 'USE [master];ALTER DATABASE ['+@DBName+'] SET RECOVERY FULL WITH NO_WAIT'
--EXEC (@CMD)


--EXEC (
--'DECLARE @DBName SYSNAME
--SET @DBName = ''WSS_Content''
----EXEC dbaadmin.dbo.dbasp_BackupDBs @DBName = @DBName
----exec dbaadmin.dbo.dbasp_Backup_Differential @DBName = @DBName
--EXEC dbaadmin.dbo.dbasp_Backup_Tranlog @DBName = @DBName') AT DYN_DBA_RMT


EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLDIST0A','DataLogDB',NULL,NULL,0,1,0;	
EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLDIST0A','DeliveryDB',NULL,NULL,0,1,0;	
EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLDIST0A','FeedsDB',NULL,NULL,0,1,0;		
EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLDIST0A','IngestionDB',NULL,NULL,0,1,0;	

--EXEC('ALTER DATABASE [DataLogDB] SET SAFETY OFF') AT DYN_DBA_RMT
--EXEC('ALTER DATABASE [DeliveryDB] SET SAFETY OFF') AT DYN_DBA_RMT
--EXEC('ALTER DATABASE [FeedsDB] SET SAFETY OFF') AT DYN_DBA_RMT
--EXEC('ALTER DATABASE [IngestionDB] SET SAFETY OFF') AT DYN_DBA_RMT



--EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAFRESQLSB01\YK2008','DeliveryDB',NULL,NULL,1,0,0;	

--xp_cmdshell 'kill robocopy.exe'
--xp_cmdshell 'kill cmd.exe'
--xp_cmdShell 'kill richcopy.exe'


--GO
--USE DBAadmin
--GO
--:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_2005\dbaadmin_2005_release_20130401.sql
--GO
--:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_2005\dbaudf_SplitSize.sql
--GO
--:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_2005\ALL_dbaadmin_32_CLR.sql
--GO
--:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_2005\dbasp_Mirror_Database.sql
--GO
--:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_2005\dbasp_DBMirror_Control.sql
--GO


--exec dbaadmin.dbo.dbasp_set_maintplans
--exec DYN_DBA_RMT.dbaadmin.dbo.dbasp_set_maintplans