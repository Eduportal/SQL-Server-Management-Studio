EXEC	dbaadmin.[dbo].[dbasp_CreateDBSnapshot]
		@DBName			= 'Getty_Images_CRM_Genesys'
		,@SnapName		= 'Getty_Images_CRM_Genesys_Daily'
		,@SnapShotPath		= NULL
		,@ReplaceExisting	= 1


EXEC	dbaadmin.[dbo].[dbasp_CreateDBSnapshot]
		@DBName			= 'Getty_Images_US_Inc__MSCRM'
		,@SnapName		= 'Getty_Images_US_Inc__MSCRM_Daily'
		,@SnapShotPath		= NULL
		,@ReplaceExisting	= 1
		
		
		
