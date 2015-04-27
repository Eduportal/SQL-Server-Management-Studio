SET NOCOUNT ON

DECLARE @Path	VarChar(max)
SET	@Path	= '\\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_2005\'

PRINT ':r "\\SEAPSQLDBA01\DBA_Docs\SQLCMD Scripts\SQLCMD_Header.sql"'
PRINT ''
PRINT ''

SELECT		CASE DomainName
			WHEN 'AMER' THEN ':CONNECT ' + SQLName+','+port 
			ELSE ':CONNECT ' + SQLName+','+port + ' -U $(SQLCMDUSER) -P $(SQLCMDPASSWORD)'
			END
			+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
			--+':r "'+@Path+'dbasp_LogEvent_Method_TableLocal'+'.sql"'+CHAR(13)+CHAR(10)
			--+':r "'+@Path+'dbasp_LogEvent'+'.sql"'+CHAR(13)+CHAR(10)
			--+':r "'+@Path+'dbasp_Backup_Verify'+'.sql"'+CHAR(13)+CHAR(10)
			--+':r "'+@Path+'dbasp_UnlockAndDelete'+'.sql"'+CHAR(13)+CHAR(10)
			--+':r "'+@Path+'dbaudf_GetFileProperty'+'.sql"'+CHAR(13)+CHAR(10)
			--+':r "'+@Path+'dbasp_SpawnAsyncTSQLThread'+'.sql"'+CHAR(13)+CHAR(10)
			--+':r "'+@Path+'FIX_DailyMaintenanceJob'+'.sql"'+CHAR(13)+CHAR(10)
			--+':r "'+@Path+'FIX_WeeklyMaintenanceJob'+'.sql"'+CHAR(13)+CHAR(10)
			+'DELETE dbaadmin.dbo.EventLog WHERE cEModule = ''dbasp_Backup_Verify'' AND cEMessage = ''InValid'''+CHAR(13)+CHAR(10)
			+'EXEC dbaadmin.dbo.dbasp_Backup_Verify'+CHAR(13)+CHAR(10)
			--+'EXEC msdb.dbo.sp_start_job @job_name = ''MAINT - Daily Backup and DBCC'', @step_name = ''Backup Verify'''+CHAR(13)+CHAR(10)
			--+'EXEC msdb.dbo.sp_start_job @job_name = ''MAINT - Weekly Backup and DBCC'', @step_name = ''Backup Verify'''+CHAR(13)+CHAR(10)
			--+':r "'+@Path+''+'.sql"'+CHAR(13)+CHAR(10)
			--+':r "'+@Path+''+'.sql"'+CHAR(13)+CHAR(10)
			--+':r "'+@Path+''+'.sql"'+CHAR(13)+CHAR(10)
			+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+'GO'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
			
			
			
--SELECT		DomainName,SQLName,IPnum,port			
FROM		dbo.DBA_ServerInfo
WHERE		Active = 'y'
	AND	SQLver NOT Like '%2000%'
	AND	ServerName NOT IN ('SEADCSQLC01A','DR1PSQLSHR21','SEABAFPSQL01','SEAFRESQLSB01','SEASTGPCSQLA','FREPSQLRYLA14','FREPSQLDWARCH','')
	AND	SQLEnv = 'PRODUCTION'

ORDER BY	DomainName,SQLName	
	
	