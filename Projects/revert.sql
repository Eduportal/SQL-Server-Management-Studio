GO
DECLARE	@RevertCMD		Bit
SET		@RevertCMD		= 1
--------------------------------------------------------------------
--------------------------------------------------------------------
--		CHANGE @RevertCMD VALUE TO 1 AND RERUN TO REVERT CHANGES
--------------------------------------------------------------------
--------------------------------------------------------------------
 
IF @RevertCMD = 0
	exec msdb.dbo.sp_update_jobstep @job_id='1660C3D9-E0C3-4D42-84A6-EEF5A0B25581' ,@step_id=1 ,@output_file_name='E:\Microsoft SQL Server\MSSQL.1\MSSQL\log\SQLjob_logs\EWS_Byline_(new)_consume_new_updated_TEAMS_contracts_from_Vitria.txt'
IF @RevertCMD = 1
	exec msdb.dbo.sp_update_jobstep @job_id='1660C3D9-E0C3-4D42-84A6-EEF5A0B25581' ,@step_id=1 ,@output_file_name='E:\Microsoft SQL Server\MSSQL.1\MSSQL\log\SQLjob_logs\EWS_Byline_(new)___consume_new/updated_TEAMS_contracts_from_Vitria.txt'
 
IF @RevertCMD = 0
	exec msdb.dbo.sp_update_jobstep @job_id='1660C3D9-E0C3-4D42-84A6-EEF5A0B25581' ,@step_id=2 ,@output_file_name='E:\Microsoft SQL Server\MSSQL.1\MSSQL\log\SQLjob_logs\EWS_Byline_(new)_consume_new_updated_TEAMS_contracts_from_Vitria.txt'
IF @RevertCMD = 1
	exec msdb.dbo.sp_update_jobstep @job_id='1660C3D9-E0C3-4D42-84A6-EEF5A0B25581' ,@step_id=2 ,@output_file_name='E:\Microsoft SQL Server\MSSQL.1\MSSQL\log\SQLjob_logs\EWS_Byline_(new)___consume_new/updated_TEAMS_contracts_from_Vitria.txt'
 
IF @RevertCMD = 0
	exec msdb.dbo.sp_update_jobstep @job_id='A21A3682-B41E-4574-8956-9C30301BE43A' ,@step_id=1 ,@output_file_name='E:\Microsoft SQL Server\MSSQL.1\MSSQL\log\SQLjob_logs\SSIS_Event_Manager_to_Blackbird.txt'
IF @RevertCMD = 1
	exec msdb.dbo.sp_update_jobstep @job_id='A21A3682-B41E-4574-8956-9C30301BE43A' ,@step_id=1 ,@output_file_name=''
