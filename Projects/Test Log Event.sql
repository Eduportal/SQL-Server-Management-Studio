
		  

	--------------------------------------------------
	-- DECLARE ALL cE VARIABLES AT HEAD OF PROCCESS --
	--------------------------------------------------
	DECLARE	@cEModule		sysname
		,@cECategory		sysname
		,@cEEvent		sysname
		,@cEGUID		uniqueidentifier
		,@cEMessage		nvarchar(max)
		,@cE_ThrottleType	VarChar(50)
		,@cE_ThrottleNumber	INT
		,@cE_ThrottleGrouping	VarChar(255)
		,@cE_ForwardTo		VarChar(2048)
		,@cE_RedirectTo		VarChar(2048)
		,@cEStat_Rows		BigInt
		,@cEStat_Duration	FLOAT
		,@cERE_ForceScreen	BIT
		,@cERE_Severity		INT
		,@cERE_State		INT
		,@cERE_With		VarChar(2048)
		,@cEMail_Subject	VarChar(2048)
		,@cEMail_To		VarChar(2048)
		,@cEMail_CC		VarChar(2048)
		,@cEMail_BCC		VarChar(2048)
		,@cEMail_Urgent		BIT
		,@cEFile_Name		VarChar(2048)
		,@cEFile_Path		VarChar(2048)
		,@cEFile_OverWrite	BIT
		,@cEPage_Subject	VarChar(2048)
		,@cEPage_To		VarChar(2048)
		,@cEMethod_Screen	BIT
		,@cEMethod_TableLocal	BIT
		,@cEMethod_TableCentral	BIT
		,@cEMethod_RaiseError	BIT
		,@cEMethod_EMail	BIT
		,@cEMethod_File		BIT
		,@cEMethod_Twitter	BIT
		,@cEMethod_DBAPager	BIT
	--------------------------------------------------
	--           SET GLOBAL cE VARIABLES            --
	--------------------------------------------------
	SELECT	@cEModule		= 'TestLogingProccess'	-- SHOULD BE SET ONCE AT BEGINNING OF PROCCESS
		,@cEGUID		= NEWID()		-- SHOULD BE SET ONCE AT BEGINNING OF PROCCESS



	--------------------------------------------------
	--            SET EVENT cE VARIABLES            --
	--------------------------------------------------
	SELECT	@cECategory		= 'STEP'
		,@cEEvent		= 'INITALIZE VARIABLES'
		,@cEMessage		= 'Initializing Variables'
		
	-- all Defaults	to screen	
	--------------------------------------------------
	--            CALL LOG EVENT SPROC              --
	--------------------------------------------------
	exec dbaadmin.dbo.[dbasp_LogEvent]
				 @cEModule
				,@cECategory
				,@cEEvent
				,@cEGUID
				,@cEMessage
	--------------------------------------------------
	--                    DONE                      --
	--------------------------------------------------

	--------------------------------------------------
	--            SET EVENT cE VARIABLES            --
	--------------------------------------------------
	SELECT	@cECategory		= 'STEP'
		,@cEEvent		= 'INITALIZE VARIABLES'
		,@cEMessage		= 'Initializing Variables'
		
	-- Use Twitter and Screen
	--------------------------------------------------
	--            CALL LOG EVENT SPROC              --
	--------------------------------------------------
	exec dbaadmin.dbo.[dbasp_LogEvent]
				 @cEModule
				,@cECategory
				,@cEEvent
				,@cEGUID
				,@cEMessage
				,@cEMethod_Twitter	= 1
	--------------------------------------------------
	--                    DONE                      --
	--------------------------------------------------	
	
	
	-- Maximum Options	
	--------------------------------------------------
	--            SET EVENT cE VARIABLES            --
	--------------------------------------------------
	SELECT	@cECategory		= 'STEP'
		,@cEEvent		= 'INITALIZE VARIABLES'
		,@cEMessage		= 'Initializing Variables'
	--------------------------------------------------
	--            CALL LOG EVENT SPROC              --
	--------------------------------------------------
	exec dbaadmin.dbo.[dbasp_LogEvent]
				 @cEModule
				,@cECategory
				,@cEEvent
				,@cEGUID
				,@cEMessage
	-- OPTIONAL VALUES  ONLY UNCOMMENT IF NONDEFAULT--

				--,@cE_ThrottleType	= 
				--,@cE_ThrottleNumber	= 
				--,@cE_ThrottleGrouping	= 
				
				--,@cE_ForwardTo		= 
				--,@cE_RedirectTo		= 
				
				,@cEStat_Rows		= 100
				,@cEStat_Duration	= 24.0102030405
				
				,@cERE_ForceScreen	= 0
				,@cERE_Severity		= 10
				,@cERE_State		= 1
				,@cERE_With		= 'WITH NOWAIT,LOG'
				
				,@cEMail_Subject	= 'Test Email Message'
				,@cEMail_To		= 'steve.ledridge@gmail.com'
				,@cEMail_CC		= 'steveledridge@msn.com'
				,@cEMail_BCC		= 'steve@ledridgefamily.com'
				--,@cEMail_Urgent		= 
				
				,@cEFile_Name		= 'TestLogFile'
				,@cEFile_Path		= 'd:'
				,@cEFile_OverWrite	= 0
				
				,@cEPage_Subject	= 'Test Page'
				,@cEPage_To		= 'OnCallDBA'
				
	-- METHODS TO USE TO LOG THE MESSAGE MUST USE ONE OR MORE--

				,@cEMethod_Screen	= 0
				,@cEMethod_TableLocal	= 0
				,@cEMethod_TableCentral	= 0
				,@cEMethod_RaiseError	= 0
				,@cEMethod_EMail	= 0
				,@cEMethod_File		= 0
				,@cEMethod_Twitter	= 1
				,@cEMethod_DBAPager	= 1
		
	--------------------------------------------------
	--                    DONE                      --
	--------------------------------------------------		