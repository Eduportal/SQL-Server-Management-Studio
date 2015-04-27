USE DBACENTRAL
GO
DECLARE	@EventID	TinyInt
	,@EventSeverity	nVarChar(100)
	,@EventCategory	nVarChar(100)
	,@Temp1		nVarChar(max)
	,@SeverityID	TinyInt
	,@CategoryID	TinyInt
	,@SymbolicName	nVarChar(50)
	,@Message	nVarChar(MAX)
	,@CRLF		nVarChar(20)
	,@Output	VarChar(MAX)
	,@OutPath	VarChar(255)
	,@Command	VarChar(8000)

SET	@CRLF		= CHAR(13) + CHAR(10)	
SET	@OutPath	= 'E:\builds\dbaadmin\System32'
SET	@Output		= ''

SET	@Output = @Output + @CRLF + '; // OPSMSSQLEventLogMsgs.mc'
SET	@Output = @Output + @CRLF + '; // ********************************************************'
SET	@Output = @Output + @CRLF + ''
SET	@Output = @Output + @CRLF + '; // Use the following commands to build this file:'
SET	@Output = @Output + @CRLF + ''
SET	@Output = @Output + @CRLF + '; //   mc -s OPSMSSQLEventLogMsgs.mc'
SET	@Output = @Output + @CRLF + '; //   rc OPSMSSQLEventLogMsgs.rc'
SET	@Output = @Output + @CRLF + '; //   link /DLL /SUBSYSTEM:WINDOWS /NOENTRY /MACHINE:x86 OPSMSSQLEventLogMsgs.Res' 
SET	@Output = @Output + @CRLF + '; // ********************************************************'
SET	@Output = @Output + @CRLF + '; // ********************************************************'
SET	@Output = @Output + @CRLF + ''
SET	@Output = @Output + @CRLF + ''


DECLARE SeverityCursor 
CURSOR
FOR SELECT * FROM dbo.OPSMSSQL_CustomEventLog_Severity

SET	@Temp1 = 'SeverityNames=('

OPEN SeverityCursor
FETCH NEXT FROM SeverityCursor INTO @SeverityID, @SymbolicName, @Message
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET	@Temp1 = @Temp1 + @Message + '=' + sys.fn_varbintohexstr(@SeverityID) + ':STATUS_SEVERITY_' + @SymbolicName + @CRLF + '               '
	END
	FETCH NEXT FROM SeverityCursor INTO @SeverityID, @SymbolicName, @Message
END

CLOSE SeverityCursor
DEALLOCATE SeverityCursor

SET	@Temp1 = @Temp1 + ')'
--SET	@Output = @Output + @CRLF + @Temp1	

--SET	@Output = @Output + @CRLF + ''
--SET	@Output = @Output + @CRLF + ''
--SET	@Output = @Output + @CRLF + 'LanguageNames=(English=0x409:MSG00409)'
--SET	@Output = @Output + @CRLF + ''
--SET	@Output = @Output + @CRLF + ''
SET	@Output = @Output + @CRLF + ''
SET	@Output = @Output + @CRLF + '; // - Event categories -'
SET	@Output = @Output + @CRLF + '; // Categories must be numbered consecutively starting at 1.'
SET	@Output = @Output + @CRLF + ''
--SET	@Output = @Output + @CRLF + 'MessageIdTypedef=WORD'

DECLARE CategoryCursor 
CURSOR
FOR SELECT * FROM dbo.OPSMSSQL_CustomEventLog_Category
	
OPEN CategoryCursor
FETCH NEXT FROM CategoryCursor INTO @CategoryID, @SymbolicName, @Message
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN

		SET	@Output = @Output + @CRLF + ''
		SET	@Output = @Output + @CRLF + 'MessageId=' + Cast(@CategoryID as VarChar(4))
		SET	@Output = @Output + @CRLF + 'Severity=Success'
		SET	@Output = @Output + @CRLF + 'SymbolicName=CATEGORY_' + @SymbolicName
		SET	@Output = @Output + @CRLF + 'Language=English'
		SET	@Output = @Output + @CRLF + @Message
		SET	@Output = @Output + @CRLF + '.'

	END
	FETCH NEXT FROM CategoryCursor INTO @CategoryID, @SymbolicName, @Message
END

CLOSE CategoryCursor
DEALLOCATE CategoryCursor

SET	@Output = @Output + @CRLF + ''
SET	@Output = @Output + @CRLF + ''
SET	@Output = @Output + @CRLF + '; // The following are the message definitions.'
SET	@Output = @Output + @CRLF + ''
--SET	@Output = @Output + @CRLF + 'MessageIdTypedef=WORD'


DECLARE EventCursor 
CURSOR
FOR
SELECT		T1.EventID
		,T2.Message AS Severity
		,T1.SymbolicName
		,T1.Message
		,T1.CategoryID
FROM		dbo.OPSMSSQL_CustomEventLog_Event T1
JOIN		dbo.OPSMSSQL_CustomEventLog_Severity T2
	ON	T1.SeverityID = T2.SeverityID
	
OPEN EventCursor
FETCH NEXT FROM EventCursor INTO @EventID, @Temp1, @SymbolicName, @Message, @CategoryID
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN

		SET	@Output = @Output + @CRLF + ''
		SET	@Output = @Output + @CRLF + 'MessageId=' + CAST(@EventID AS VarChar(4))
		SET	@Output = @Output + @CRLF + 'Severity=Success'
		SET	@Output = @Output + @CRLF + 'Facility=Application'
		SET	@Output = @Output + @CRLF + 'SymbolicName=EVT_' + @SymbolicName
		SET	@Output = @Output + @CRLF + 'Language=English'
		SET	@Output = @Output + @CRLF + @Message
		SET	@Output = @Output + @CRLF + '.'

	END
	FETCH NEXT FROM EventCursor INTO @EventID, @Temp1, @SymbolicName, @Message, @CategoryID
END

CLOSE EventCursor
DEALLOCATE EventCursor

SET	@Output = @Output + @CRLF + ''

PRINT @Output
EXEC [dbaadmin].[dbo].[dbasp_FileAccess_Write] @Output, @OutPath, 'OPSMSSQLEventLogMsgs.mc' 

SET	@Output	= 'E:' + @CRLF
			+ 'CD ' + @OutPath + @CRLF
			+ 'mc -s OPSMSSQLEventLogMsgs.mc' + @CRLF
			+ 'rc -r -fo OPSMSSQLEventLogMsgs.res OPSMSSQLEventLogMsgs.rc' + @CRLF
			+ 'link /DLL /SUBSYSTEM:WINDOWS /NOENTRY /MACHINE:x86 OPSMSSQLEventLogMsgs.Res' + @CRLF
			+ 'copy OPSMSSQLEventLogMsgs.dll c:\windows\system32 /Y' + @CRLF

--PRINT @Output
EXEC [dbaadmin].[dbo].[dbasp_FileAccess_Write] @Output, @OutPath, 'OPSMSSQLEventLogMsgs.cmd' 

SET	@Command = @OutPath + '\OPSMSSQLEventLogMsgs.cmd'  

EXEC [xp_cmdshell] @Command, NO_OUTPUT


