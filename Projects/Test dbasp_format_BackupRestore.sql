USE [dbaadmin]
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

--:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\ALL_dbaadmin_32_CLR.sql
--GO
--:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbaudf_BackupScripter_GetHeaderList.sql
--GO
--:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbaudf_BackupScripter_GetBackupFiles.sql
--GO
--:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbaudf_BackupScripter_GetFileList.sql
--GO
--:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbaudf_SplitByLines.sql
--GO
--:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbasp_format_BackupRestore.sql
--GO


 DECLARE	@syntax_out		VarChar(max)	


 EXEC		[dbaadmin].[dbo].[dbasp_format_BackupRestore] 
				@DBName			= 'Getty_Images_CRM_GENESYS'
				,@Mode			= 'BF'
				,@syntax_out		= @syntax_out OUTPUT


 EXEC		[dbaadmin].[dbo].[dbasp_format_BackupRestore] 
				@DBName			= 'Getty_Images_CRM_GENESYS'
				,@Mode			= 'BD'
				,@syntax_out		= @syntax_out OUTPUT


 EXEC		[dbaadmin].[dbo].[dbasp_format_BackupRestore] 
				@DBName			= 'Getty_Images_CRM_GENESYS'
				,@Mode			= 'BL'
				,@syntax_out		= @syntax_out OUTPUT

EXEC		[dbaadmin].[dbo].[dbasp_PrintLarge] @syntax_out

EXEC (@syntax_out)

 --EXEC		[dbaadmin].[dbo].[dbasp_format_BackupRestore] 
	--			@DBName			= 'Getty_Images_US_Inc__MSCRM'
	--			,@Mode			= 'RD'
	--			,@FileGroups		= 'PRIMARY,FG2,ftfg_ftcat_documentindex_9e0efd13ecab427f974e7f1336eb7159'
	--			--,@FromServer		= 'SEAPCRMSQL1A'
	--			,@FilePath		= '\\SEAPCRMSQL1A\I$\Backup\'
	--			,@WorkDir		= 'd:\MSSQL\Backup\'
	--			,@Verbose		= 1
	--			,@FullReset		= 1
	--			,@syntax_out		= @syntax_out OUTPUT


 --EXEC		[dbaadmin].[dbo].[dbasp_format_BackupRestore] 
	--			@DBName			= 'Getty_Images_US_Inc__MSCRM'
	--			,@Mode			= 'RD'
	--			,@FileGroups		= 'PRIMARY,FG2,ftfg_ftcat_documentindex_9e0efd13ecab427f974e7f1336eb7159'
	--			--,@FromServer		= 'SEAPCRMSQL1A'
	--			,@FilePath		= '\\SEAPCRMSQL1A\I$\Backup\'
	--			,@Verbose		= 1
	--			,@syntax_out		= @syntax_out OUTPUT

-- EXEC		[dbaadmin].[dbo].[dbasp_format_BackupRestore] 
--				@DBName			= 'Getty_Master'
--				--,@NewDBName		= 'XXX'
--				,@Mode			= 'RD'
--				,@FromServer		= 'FREPSQLRYLA01'
--				--,@FileGroups		= 'PRIMARY,FG2'
--				--,@Verbose		= 0
--				,@syntax_out		= @syntax_out OUTPUT
--				--,@RestoreToDateTime	= '2013-10-21 21:46:48'
--				--,@WorkDir		= 'd:\MSSQL\Backup\'
--				,@FullReset		= 1
--				,@OverrideXML		=
--'<RestoreFileLocations>
--  <Override LogicalName="ftrow_ftcat_documentindex_9e0efd13ecab427f974e7f1336eb7159" PhysicalName="D:\SQL\MSSQL10_50.MSSQLSERVER\MSSQL\FTData\ftrow_ftcat_documentindex_9e0efd13ecab427f974e7f1336eb7159.ndf" New_PhysicalName="D:\MSSQL\data\ftrow_ftcat_documentindex_9e0efd13ecab427f974e7f1336eb7159.ndf" />
--  <Override LogicalName="Getty_Images_US_Inc__MSCRM" PhysicalName="E:\Data\Getty_Images_US_Inc__MSCRM.mdf" New_PhysicalName="D:\MSSQL\data\Getty_Images_US_Inc__MSCRM.mdf" />
--  <Override LogicalName="Getty_Images_US_Inc__MSCRM_log" PhysicalName="F:\log\Getty_Images_US_Inc__MSCRM_log.LDF" New_PhysicalName="D:\MSSQL\data\Getty_Images_US_Inc__MSCRM_log.LDF" />
--  <Override LogicalName="Getty_Images_US_Inc__MSCRM2" PhysicalName="m:\data\Getty_Images_US_Inc__MSCRM2.ndf" New_PhysicalName="D:\MSSQL\Log\Getty_Images_US_Inc__MSCRM2.ndf" />
--  <Override LogicalName="Getty_Images_US_Inc__MSCRM3" PhysicalName="H:\Data\Getty_Images_US_Inc__MSCRM3.ndf" New_PhysicalName="D:\MSSQL\Log\Getty_Images_US_Inc__MSCRM3.ndf" />
--  <Override LogicalName="Getty_Images_US_Inc__MSCRM4" PhysicalName="H:\Data\Getty_Images_US_Inc__MSCRM4.ndf" New_PhysicalName="D:\MSSQL\Log\Getty_Images_US_Inc__MSCRM4.ndf" />
--  <Override LogicalName="Getty_Images_US_Inc__MSCRM5" PhysicalName="I:\Data\Getty_Images_US_Inc__MSCRM5.ndf" New_PhysicalName="D:\MSSQL\Log\Getty_Images_US_Inc__MSCRM5.ndf" />
--  <Override LogicalName="Getty_Images_US_Inc__MSCRM6" PhysicalName="I:\Data\Getty_Images_US_Inc__MSCRM6.ndf" New_PhysicalName="D:\MSSQL\Log\Getty_Images_US_Inc__MSCRM6.ndf" />
--  <Override LogicalName="Getty_Images_US_Inc__MSCRM7" PhysicalName="I:\Data\Getty_Images_US_Inc__MSCRM7.ndf" New_PhysicalName="D:\MSSQL\Log\Getty_Images_US_Inc__MSCRM7.ndf" />
--</RestoreFileLocations>'

 --EXEC		[dbaadmin].[dbo].[dbasp_format_BackupRestore] 
	--			@DBName			= 'Getty_Images_US_Inc__MSCRM'
	--			,@Mode			= 'BF'
	--			--,@FilePath		= '\\SEAPCRMSQL1A\I$\Backup\'
	--			--,@FromServer		= 'SEAPCRMSQL1A'
	--			,@Verbose		= 0
	--			,@FullReset		= 1
	--			,@syntax_out		= @syntax_out OUTPUT


--SELECT * FROM dbaadmin.dbo.dbaudf_DirectoryList2('\\SEAPCRMSQL1A\I$\Backup\',null,0)


-- EXEC		[dbaadmin].[dbo].[dbasp_format_BackupRestore] 
--				@DBName			= 'dbaperf'
--				,@NewDBName		= 'XXX'
--				,@Mode			= 'BF'
--				--,@FromServer		= 'SEAPCRMSQL1A'
--				--,@FileGroups		= 'PRIMARY,FG2'
--				--,@Verbose		= 0
--				,@syntax_out		= @syntax_out OUTPUT
--				--,@RestoreToDateTime	= '2013-10-21 21:46:48'
--				,@WorkDir		= 'd:\MSSQL\Backup\'
--				,@FullReset		= 1
----				,@OverrideXML		=
----'<RestoreFileLocations>
----  <Override LogicalName="ftrow_ftcat_documentindex_9e0efd13ecab427f974e7f1336eb7159" PhysicalName="D:\SQL\MSSQL10_50.MSSQLSERVER\MSSQL\FTData\ftrow_ftcat_documentindex_9e0efd13ecab427f974e7f1336eb7159.ndf" New_PhysicalName="D:\MSSQL\data\ftrow_ftcat_documentindex_9e0efd13ecab427f974e7f1336eb7159.ndf" />
----  <Override LogicalName="Getty_Images_US_Inc__MSCRM" PhysicalName="E:\Data\Getty_Images_US_Inc__MSCRM.mdf" New_PhysicalName="D:\MSSQL\data\Getty_Images_US_Inc__MSCRM.mdf" />
----  <Override LogicalName="Getty_Images_US_Inc__MSCRM_log" PhysicalName="F:\log\Getty_Images_US_Inc__MSCRM_log.LDF" New_PhysicalName="D:\MSSQL\data\Getty_Images_US_Inc__MSCRM_log.LDF" />
----  <Override LogicalName="Getty_Images_US_Inc__MSCRM2" PhysicalName="m:\data\Getty_Images_US_Inc__MSCRM2.ndf" New_PhysicalName="D:\MSSQL\Log\Getty_Images_US_Inc__MSCRM2.ndf" />
----  <Override LogicalName="Getty_Images_US_Inc__MSCRM3" PhysicalName="H:\Data\Getty_Images_US_Inc__MSCRM3.ndf" New_PhysicalName="D:\MSSQL\Log\Getty_Images_US_Inc__MSCRM3.ndf" />
----  <Override LogicalName="Getty_Images_US_Inc__MSCRM4" PhysicalName="H:\Data\Getty_Images_US_Inc__MSCRM4.ndf" New_PhysicalName="D:\MSSQL\Log\Getty_Images_US_Inc__MSCRM4.ndf" />
----  <Override LogicalName="Getty_Images_US_Inc__MSCRM5" PhysicalName="I:\Data\Getty_Images_US_Inc__MSCRM5.ndf" New_PhysicalName="D:\MSSQL\Log\Getty_Images_US_Inc__MSCRM5.ndf" />
----  <Override LogicalName="Getty_Images_US_Inc__MSCRM6" PhysicalName="I:\Data\Getty_Images_US_Inc__MSCRM6.ndf" New_PhysicalName="D:\MSSQL\Log\Getty_Images_US_Inc__MSCRM6.ndf" />
----  <Override LogicalName="Getty_Images_US_Inc__MSCRM7" PhysicalName="I:\Data\Getty_Images_US_Inc__MSCRM7.ndf" New_PhysicalName="D:\MSSQL\Log\Getty_Images_US_Inc__MSCRM7.ndf" />
----</RestoreFileLocations>'

--				--,@ForceEngine		= NULL
--				--,@ForceSetSize		= NULL
--				--,@ForceCompression	= NULL
--				--,@ForceChecksum		= NULL

--				--,@FilePath		= NULL
--				--,@FileName		= NULL
				
				
--				--,@WorkDir		= NULL

--				--,@SetName		= NULL
--				--,@SetDesc		= NULL
						
--				--,@CopyOnly		= 0
--				--,@RestoreToDateTime	= NULL
--				--,@LeaveNORECOVERY	= 0
--				--,@NoLogRestores		= 0
--				--,@NoDifRestores		= 0
--				--,@FullReset		= 1
--				--,@IgnoreSpaceLimits	= 1
--				--,@OverrideXML		= NULL

--				--,@Verbose		= 1 
				
						
--DECLARE @TextLine VarChar(MAX)
--DECLARE PrintLargeResults CURSOR
--FOR
---- SELECT QUERY FOR CURSOR
--SELECT		SplitValue
--FROM		dbaadmin.dbo.dbaudf_SplitByLines(@syntax_out)
--ORDER BY	OccurenceID 

--OPEN PrintLargeResults;
--FETCH PrintLargeResults INTO @TextLine;
--WHILE (@@fetch_status <> -1)
--BEGIN
--	IF (@@fetch_status <> -2)
--	BEGIN
--		---------------------------- 
--		---------------------------- CURSOR LOOP TOP
	
--		PRINT @TextLine

--		---------------------------- CURSOR LOOP BOTTOM
--		----------------------------
--	END
-- 	FETCH NEXT FROM PrintLargeResults INTO @TextLine;
--END
--CLOSE PrintLargeResults;
--DEALLOCATE PrintLargeResults;


--SELECT	nullif(dbaadmin.[dbo].[dbaudf_getShareUNC]('backup'),'Not Found') [SHARE_URL]
--	,nullif(dbaadmin.[dbo].[dbaudf_GetSharePath](dbaadmin.[dbo].[dbaudf_getShareUNC]('backup')),'Not Found') [SHARE_PATH]