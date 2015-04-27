exec dbaadmin.dbo.[dbasp_IndexMaintenance]
	@usesOnlineReindex		 = 0
	,@mode				 = 3
	,@databaseName			 = 'WCDS' 
	,@maxIndexLevelToConsider	 = 9
	,@sortInTempDb			 = 1
	,@minPages			 = 10
	,@continueOnError		 = 1
	,@ScriptMode			 = 1
	,@Path				 = 'd:'
	,@Filename			 = 'IndexMaintenanceScript.sql'
	
GO

--!!DIR \\GONESSQLA\d$\*.sql	
--:r \\GONESSQLA\d$\IndexMaintenanceScript.sql	
	


