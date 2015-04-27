

EXEC sp_addmessage 
    @msgnum = 67001, 
    @severity = 14,
    @msgtext = N'%s',
    @with_log = 'true',
    @lang = 'us_english',
    @replace = 'replace';
 
 EXEC sp_addmessage 
    @msgnum = 67002, 
    @severity = 15,
    @msgtext = N'%s',
    @with_log = 'true',
    @lang = 'us_english',
    @replace = 'replace';
 
 EXEC sp_addmessage 
    @msgnum = 67003, 
    @severity = 16,
    @msgtext = N'%s',
    @with_log = 'true',
    @lang = 'us_english',
    @replace = 'replace';
 
 

select * from sysmessages



raiserror(67001,-1,-1,'Test Informational')
raiserror(67002,-1,-1,'Test Warning')
raiserror(67003,-1,-1,'Test Error')











DECLARE @object int;
DECLARE @hr int;
DECLARE @src varchar(255), @desc varchar(255);
EXEC @hr = sp_OACreate 'Wscript.Shell', @object OUT
IF @hr <> 0
BEGIN
   EXEC sp_OAGetErrorInfo @object, @src OUT, @desc OUT 
   raiserror('Error Creating COM Component 0x%x, %s, %s',16,1, @hr, @src, @desc)
    RETURN
END;

EXEC @hr = sp_OAMethod @object,'LogEvent',1, 'TEST Error' ;
EXEC @hr = sp_OAMethod @object,'LogEvent',2, 'TEST Warning' ;
EXEC @hr = sp_OAMethod @object,'LogEvent',4, 'TEST Information' ;
EXEC @hr = sp_OAMethod @object,'LogEvent',8, 'TEST Audit Success' ;
EXEC @hr = sp_OAMethod @object,'LogEvent',16, 'TEST Audit Failure' ;

EXEC @hr = sp_OAMethod @object,'LogEvent',0, 'TEST SUCCESS' ;


GO








exec xp_logevent 67004 ,'Test 1 Informational'	,'INFORMATIONAL' 
exec xp_logevent 67004 ,'Test 2 Warning'	,'WARNING' 
exec xp_logevent 67004 ,'Test 3 Error'		,'ERROR' 





raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',0,-1) WITH LOG
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',1,-1) WITH LOG
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',2,-1) WITH LOG
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',3,-1) WITH LOG
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',4,-1) WITH LOG
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',5,-1) WITH LOG
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',6,-1) WITH LOG
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',7,-1) WITH LOG
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',8,-1) WITH LOG
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',9,-1) WITH LOG
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',10,-1) WITH LOG
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',11,-1) WITH LOG
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',12,-1) WITH LOG
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',13,-1) WITH LOG
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',14,-1) WITH LOG
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',15,-1) WITH LOG
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',16,-1) WITH LOG

PRINT 'done'

raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',0,-1) WITH LOG,SETERROR
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',1,-1) WITH LOG,SETERROR
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',2,-1) WITH LOG,SETERROR
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',3,-1) WITH LOG,SETERROR
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',4,-1) WITH LOG,SETERROR
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',5,-1) WITH LOG,SETERROR
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',6,-1) WITH LOG,SETERROR
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',7,-1) WITH LOG,SETERROR
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',8,-1) WITH LOG,SETERROR
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',9,-1) WITH LOG,SETERROR
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',10,-1) WITH LOG,SETERROR
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',11,-1) WITH LOG,SETERROR
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',12,-1) WITH LOG,SETERROR
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',13,-1) WITH LOG,SETERROR
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',14,-1) WITH LOG,SETERROR
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',15,-1) WITH LOG,SETERROR
raiserror('DBA WARNING: Invalid input for XXXXXXX.  Try ''DBname_prod.sqb''.',16,-1) WITH LOG,SETERROR

PRINT 'done'

GO



DECLARE @CMD VarChar(8000)

SET	@CMD =	'ECHO Const EVENT_SUCCESS = 0 > test.vbs'
EXEC	xp_CMDSHELL @CMD
SET	@CMD =	'ECHO Set objShell = Wscript.CreateObject("Wscript.Shell") >> test.vbs'
EXEC	xp_CMDSHELL @CMD
SET	@CMD =	'ECHO objShell.LogEvent EVENT_SUCCESS,"TSSQLDBA application successfully installed." >> test.vbs'
EXEC	xp_CMDSHELL @CMD
SET	@CMD =	'cscript test.vbs'
EXEC	xp_CMDSHELL @CMD

    
    
    
    
    