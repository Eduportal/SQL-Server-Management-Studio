:setvar DatabaseName "dbaadmin"
:setvar AssName "GettyImages.Operations.CLRTools"
:setvar BuildNumber "20130401_CLR"
:on error ignore


USE [dbaadmin]
GO
SET XACT_ABORT ON
GO
EXEC sp_changedbowner 'sa'
GO
ALTER DATABASE dbaadmin SET TRUSTWORTHY ON
GO
ALTER DATABASE dbaadmin SET ALLOW_SNAPSHOT_ISOLATION ON
GO

IF ('$(DatabaseName)' = '$' + '(DatabaseName)')
BEGIN
	PRINT ''
	PRINT ''
	PRINT ''
	PRINT '======================================================================'
	PRINT '============ SQLCMD MODE MUST BE ENABLED FOR THIS SCRIPT ============='
	PRINT '======================================================================'
	PRINT ''
	PRINT ''
	PRINT ''
	SET NOEXEC ON
	
END    
GO

IF CAST(SERVERPROPERTY('ProductVersion') AS CHAR(1)) = '8'
BEGIN
	PRINT ''
	PRINT ''
	PRINT ''
	PRINT '======================================================================'
	PRINT '============         DO NOT RUN SCRIPT ON SQL 2000       ============='
	PRINT '======================================================================'
	PRINT ''
	PRINT ''
	PRINT '*** YOU WILL STILL SEE PRE-PARSE ERRORS'
	PRINT ''
	raiserror('error',20,1) WITH LOG
	SET NOEXEC ON
	
END    
ELSE
	PRINT 'RUNNING ON SQL Server Version ' + CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(50))
GO
SELECT CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(50))
GO



DECLARE		@CMD		VarChar(max)
		,@CRLF		CHAR(2)
SELECT		@CMD		= ''
		,@CRLF		= CHAR(13)+CHAR(10)

;WITH		CLR_Objects
		AS
		(
		SELECT		DISTINCT
				object_name(id)	[object_name]
				,CASE ObjectpropertyEX(id,'BaseType')
					WHEN 'FN' THEN 'FUNCTION'	-- SQL scalar function
					WHEN 'IF' THEN 'FUNCTION'	-- SQL inline table-valued function
					WHEN 'TF' THEN 'FUNCTION'	-- SQL table-valued-function
					WHEN 'P'  THEN 'PROCEDURE'	-- SQL Stored Procedure
					WHEN 'X'  THEN 'PROCEDURE'	-- Extended stored procedure
					END [object_type]
				,'dbo' [object_schema]
		FROM		syscomments
		WHERE		text like '%sp_Oa%'
		)
SELECT		@CMD = @CMD + @CRLF
		+ 'PRINT ''Dropping ['+[object_schema]+'].['+[object_name]+']...'';'+@CRLF
		+ 'IF OBJECT_ID(''['+[object_schema]+'].['+[object_name]+']'') IS NOT NULL' + @CRLF
		+'     DROP ' + [object_type] + ' ['+[object_schema]+'].['+[object_name]+']'+ @CRLF
		+'--GO'+@CRLF+@CRLF
FROM		CLR_Objects
WHERE		[object_type] IS NOT NULL
EXEC 		(@CMD)
GO

:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbaudf_SplitSize.sql
GO

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--				END OF PRE DEPLOY SCRIPT
--			   	    START CLR DEPLOY
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\ALL_dbaadmin_32_CLR.sql
GO

DECLARE @CMD VarChar(8000)
SELECT @CMD = dbaadmin.dbo.dbaudf_FormatString('COPY \\seapsqldba01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_2005\ScriptSQLObject.exe \\{0}\{1}\SYSTEM32\'
,dbo.dbaudf_GetEV('COMPUTERNAME')
,REPLACE(dbo.dbaudf_GetEV('windir'),':','$')
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
exec xp_CmdShell @CMD
PRINT @CMD
GO



--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--				    END OF CLR DEPLOY
--		   	        START POST DEPLOY SCRIPT
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
GO

USE DBAADMIN
GO
exec dbaadmin.dbo.dbasp_CreateAllDBViews
GO
:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\sp_Help_Doc.sql
GO
:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbaudf_FileAccess_Dir.sql
GO
:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbaudf_FileAccess_Dir2.sql
GO
:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbasp_SQL_Server_System_Report.sql
GO
:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbasp_RunTSQL.sql
GO
:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbasp_Self_Register_Report.sql
GO
:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbasp_LogEvent_Method_File.proc.sql
GO
:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbasp_IndexUpdateStats.sql
GO
:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbasp_IndexMaintenance.sql
GO
:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbasp_FileCleanup.sql
GO
:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbasp_check_SQLhealth.sql
GO
:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbasp_dbamail_process.sql
GO
:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbasp_FixJobLogOutputFiles.sql
GO
:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbasp_Logship_Fix.sql
GO
:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbasp_Logship_MS_Fix.sql
GO
:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\dbasp_Restore_Tranlog.sql
GO
if object_id('build') IS NOT NULL
INSERT INTO Build	(
			vchName,
 			vchLabel,
 			dtBuildDate,
			vchNotes
			)
SELECT		DB_Name()
		,'$(BuildNumber)'
		,GetDate()
		,'CLR CONVERSION DEPLOYMENT'
GO

SET NOEXEC OFF
GO
if db_id('dbaperf') IS NULL
SET NOEXEC ON
GO

USE DBAPERF
GO
:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAPERF\dbaperf_2005\dbasp_ChartData_DBGrowth.sql
GO
:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAPERF\dbaperf_2005\dbasp_DiskSpaceCheck_CaptureAndExport.sql
GO
if object_id('build') IS NOT NULL
INSERT INTO Build	(
			vchName,
 			vchLabel,
 			dtBuildDate,
			vchNotes
			)
SELECT		DB_Name()
		,'$(BuildNumber)'
		,GetDate()
		,'CLR CONVERSION DEPLOYMENT'
GO

SET NOEXEC OFF
GO
if db_id('deplinfo') IS NULL
SET NOEXEC ON
GO
USE DEPLINFO
GO
IF OBJECT_ID('dpudf_CheckFileSize') IS NOT NULL
     DROP FUNCTION dpudf_CheckFileSize
GO

IF OBJECT_ID('dpudf_CheckFileType') IS NOT NULL
     DROP FUNCTION dpudf_CheckFileType
GO
:r \\seapsqldba01\DBA_Docs\SourceCode\DEPLinfo\DEPLinfo_2005\dpsp_ahp_auto_RunSQLdeployment_ordered.sql
GO
:r \\seapsqldba01\DBA_Docs\SourceCode\DEPLinfo\DEPLinfo_2005\dpsp_auto_RunSQLdeployment.sql
GO
:r \\seapsqldba01\DBA_Docs\SourceCode\DEPLinfo\DEPLinfo_2005\dpsp_auto_RunSQLdeployment_ordered.sql
GO
:r \\seapsqldba01\DBA_Docs\SourceCode\DEPLinfo\DEPLinfo_2005\dpsp_ahp_auto_DEPLsendmail.sql
GO
:r \\seapsqldba01\DBA_Docs\SourceCode\DEPLinfo\DEPLinfo_2005\dpsp_auto_DEPLsendmail.sql
GO
:r \\seapsqldba01\DBA_Docs\SourceCode\DEPLinfo\DEPLinfo_2005\dpsp_auto_RunSQLdeployment_classic.sql
GO
:r \\seapsqldba01\DBA_Docs\SourceCode\DEPLinfo\DEPLinfo_2005\dpsp_UpdateDEPLinfoBuild.sql
GO
if object_id('build') IS NOT NULL
INSERT INTO Build	(
			vchName,
 			vchLabel,
 			dtBuildDate,
			vchNotes
			)
SELECT		DB_Name()
		,'$(BuildNumber)'
		,GetDate()
		,'CLR CONVERSION DEPLOYMENT'
GO


SET NOEXEC OFF
GO
if db_id('sqldeploy') IS NULL
SET NOEXEC ON
GO
USE SQLDEPLOY
GO
IF OBJECT_ID('dpudf_CheckFileSize') IS NOT NULL
     DROP FUNCTION dpudf_CheckFileSize
GO

IF OBJECT_ID('dpudf_CheckFileType') IS NOT NULL
     DROP FUNCTION dpudf_CheckFileType
GO
:r \\seapsqldba01\DBA_Docs\SourceCode\GOLD\SQLdeploy_gold\SQLdeploy_release_20130328.sql
GO
:r \\seapsqldba01\DBA_Docs\SourceCode\SQLdeploy\dpsp_auto_DBrestore.sql
GO
:r \\seapsqldba01\DBA_Docs\SourceCode\SQLdeploy\dpsp_auto_DEPLsendmail.sql
GO
:r \\seapsqldba01\DBA_Docs\SourceCode\SQLdeploy\dpsp_auto_run_post_process.sql
GO
:r \\seapsqldba01\DBA_Docs\SourceCode\SQLdeploy\dpsp_auto_RunSQLdeployment_classic.sql
GO
:r \\seapsqldba01\DBA_Docs\SourceCode\SQLdeploy\dpsp_auto_RunSQLdeployment_ordered.sql
GO
:r \\seapsqldba01\DBA_Docs\SourceCode\SQLdeploy\dpsp_UpdateSQLdeployBuild.sql
GO
:r \\seapsqldba01\DBA_Docs\SourceCode\SQLdeploy\dpsp_UpdateSQLdeployBuild_classic.sql
GO
if object_id('build') IS NOT NULL
INSERT INTO Build	(
			vchName,
 			vchLabel,
 			dtBuildDate,
			vchNotes
			)
SELECT		DB_Name()
		,'$(BuildNumber)'
		,GetDate()
		,'CLR CONVERSION DEPLOYMENT'
GO

SET NOEXEC OFF
GO

if db_id('dbacentral') IS NULL
SET NOEXEC ON
GO
USE DBACENTRAL
GO
:r \\seapsqldba01\DBA_Docs\SourceCode\DBACENTRAL\dbacentral_2005\dbasp_dbamail_process.sql
GO
SET NOEXEC OFF
GO

USE dbaadmin
GO
exec msdb.dbo.sp_start_job @job_name = 'UTIL - DBA Nightly Processing',@step_name = 'Self Register to the Central Server'
GO
Print 'CLR Deployment Done...'
GO
SET NOEXEC OFF
GO