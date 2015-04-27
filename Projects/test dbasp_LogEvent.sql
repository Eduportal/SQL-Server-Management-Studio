
	exec [dbo].[dbasp_LogEvent]
		@cEModule		= 'TestLogingProccess'	-- SHOULD BE SET ONCE AT BEGINNING OF PROCCESS
		,@cECategory            = 'AUDIT STEP'       
		,@cEEvent               = 'Calculate Sales'         
		,@cEMessage             = 'Calculate Last Month Sales by reconsiling Sales with returns and discounts'
		,@cEWinLog_LogName	= 'APPLICATION' 
		,@cEWinLog_EventType	= 'INFORMATION'
		,@cEWinLog_EventID	= 1 

		,@cETable_FQName	= 'dbaadmin.dbo.SWLEventLog2'
		,@cEMail_Subject	= 'Test email message'
		,@cEMail_To		= 'steve.ledridge@gmail.com'
		,@cEMail_CC		= 'steve.ledridge@gettyimages.com'
		,@cEMail_BCC		= 'steve@ledridgefamily.com'
		,@cEFile_Name		= 'SWLEventLog.txt'
		,@cEFile_Path		= 'c:\temp'
		,@cEFile_OverWrite	= 0

		,@cEMethod_TableLocal	= 1
		,@cEMethod_TableCentral	= 0
		,@cEMethod_WinLog	= 1  
		,@cEMethod_EMail	= 0
		,@cEMethod_File		= 0
		,@cEMethod_Twitter	= 0
		,@DebugPrint		= 0


