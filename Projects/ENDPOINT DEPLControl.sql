IF EXISTS (SELECT * FROM sys.endpoints e WHERE e.name = N'DEPLControl') 
DROP ENDPOINT [DEPLControl] 
GO
IF NOT EXISTS (SELECT * FROM sys.endpoints e WHERE e.name = N'DEPLControl') 
BEGIN
CREATE ENDPOINT [DEPLControl] 
	AUTHORIZATION [AMER\sledridge]
	STATE=STARTED
	AS HTTP	(
			PATH=N'/DEPLControl'
			, AUTHENTICATION = (NTLM)
			, PORTS = (CLEAR)
			, SITE=N'SEAFRESQLDBA01'
			)
	FOR SOAP	(
				WEBMETHOD 'Status'					(NAME=N'[DEPLcontrol].[dbo].[dpsp_Status]')
				,WEBMETHOD 'Update'					(NAME=N'[DEPLcontrol].[dbo].[dpsp_Update_dummy]')
				,WEBMETHOD 'Approve'				(NAME=N'[DEPLcontrol].[dbo].[dpsp_Approve_dummy]')
				,WEBMETHOD 'Cancel'					(NAME=N'[DEPLcontrol].[dbo].[dpsp_Cancel_Gears_dummy]')
				,WEBMETHOD 'Delete'					(NAME=N'[DEPLcontrol].[dbo].[dpsp_Delete_dummy]')
				,WEBMETHOD 'ManualStart'			(NAME=N'[DEPLcontrol].[dbo].[dpsp_ManualStart]')
				,WEBMETHOD 'StartPreReleaseBackups'	(NAME=N'[DEPLcontrol].[dbo].[dpsp_StartPreReleaseBackups_dummy]')
				, BATCHES=DISABLED
				, WSDL=DEFAULT
				, DATABASE=N'DEPLcontrol'
				, NAMESPACE=N'http://ecommops/DBA'
				)
END
GO
GRANT CONNECT ON ENDPOINT:: DEPLControl TO PUBLIC
GO
GRANT VIEW DEFINITION ON ENDPOINT:: DEPLControl TO PUBLIC
GO
