DECLARE		@ServerString1		VarChar(8000)
			,@ServerString2		VarChar(8000)
			,@ServerString3		VarChar(8000)
			,@ServerToClone		VarChar(8000)
			,@DynamicCode		VarChar(8000)
			,@Msg				VarChar(8000)
			,@Feature_NetSend	bit
			,@Feature_Clone		bit
			,@NetSendRecip		VarChar(8000)
			,@MsgCommand		VarChar(8000)
			,@machinename		VarChar(8000)
			,@instancename		VarChar(8000)
			,@ServerName		varchar(8000)
			,@ServiceExt		varchar(8000)
	
	SELECT		@instancename		= isnull('\'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
				,@ServerName		= REPLACE(@@SERVERNAME,@instancename,'')
				,@machinename		= convert(nvarchar(100), serverproperty('machinename')) + @instancename
				,@ServiceExt		= isnull('$'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
				,@Feature_Clone		= 1
				,@ServerToClone		= COALESCE(@ServerToClone,	CASE @Feature_Clone 
																WHEN 0 THEN @@SERVERNAME 
																ELSE	CASE -- PROGRAMATIC DETERMINATIONS
																			WHEN @@SERVERNAME Like 'GMSSQLTEST02%' THEN REPLACE(@@SERVERNAME,'Test02','Test01')
																			ELSE COALESCE(@ServerToClone,REPLACE(@machinename,'-N',''),@@ServerName) 
																		END
															END)
				,@ServerString1		= LEFT(@ServerToClone,CHARINDEX ('\',@ServerToClone+'\')-1)
				,@ServerString2		= REPLACE(@ServerToClone,'\','$')
				,@ServerString3		= CASE WHEN CHARINDEX ('\',@ServerToClone) > 0 THEN REPLACE(@ServerToClone,'\','(')+')' ELSE @ServerToClone END
				

	-- COPY DBA_ARCHIVE FILES FROM CLONED SERVER
	SET @Msg =		'                Copying dba_archive directory from ' + @ServerString1;IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg;-- INSERT INTO #StatusOutput(TextOutput) Values(@Msg);
	SELECT		@DynamicCode			= 'XCOPY \\'+@ServerString1+'\'+@ServerString2+'_dba_archive\*.* \\'+REPLACE(@@SERVERNAME,'\'+@@SERVICENAME,'')+'\'+REPLACE(@@SERVERNAME,'\','$')+'_dba_archive\BeforeClone\ /Q /C /Y'
	SET @Msg =		'                  -- ' + @DynamicCode;IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg; --INSERT INTO #StatusOutput(TextOutput) Values(@Msg);
	PRINT		@DynamicCode
	EXEC		XP_CMDSHELL  @DynamicCode --, no_output 
	
	
	