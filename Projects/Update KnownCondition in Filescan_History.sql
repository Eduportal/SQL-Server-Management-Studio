DECLARE	@CheckOrSet		BIT		-- 0=Check, 1=Set
DECLARE @ShowIt			BIT
DECLARE	@RunIT			BIT
DECLARE @SourceType		sysname
DECLARE	@MessageType		sysname
DECLARE	@MessageID		sysname
DECLARE	@KnownCondition		sysname
DECLARE	@FixData_Param_01	sysname
DECLARE	@FixData_Param_02	sysname
DECLARE	@FixData_Param_03	sysname
DECLARE	@FixData_Param_04	sysname
DECLARE	@FixData_Param_05	sysname
DECLARE @MessageMarker_1A	VARCHAR(255)
DECLARE @MessageMarker_1B	VARCHAR(255)
DECLARE @MessageMarker_2A	VARCHAR(255)
DECLARE @MessageMarker_2B	VARCHAR(255)
DECLARE @MessageMarker_3A	VARCHAR(255)
DECLARE @MessageMarker_3B	VARCHAR(255)
DECLARE @MessageMarker_4A	VARCHAR(255)
DECLARE @MessageMarker_4B	VARCHAR(255)
DECLARE @MessageMarker_5A	VARCHAR(255)
DECLARE @MessageMarker_5B	VARCHAR(255)
DECLARE @MessageMarker_6A	VARCHAR(255)
DECLARE @MessageMarker_6B	VARCHAR(255)
DECLARE @MessageMarker_7A	VARCHAR(255)
DECLARE @MessageMarker_7B	VARCHAR(255)
DECLARE @MessageMarker_8A	VARCHAR(255)
DECLARE @MessageMarker_8B	VARCHAR(255)
DECLARE @MessageMarker_9A	VARCHAR(255)
DECLARE @MessageMarker_9B	VARCHAR(255)
DECLARE	@WhereFilter		VARCHAR(255)
DECLARE	@TSQL			VARCHAR(MAX)



--SET	@SourceType		= 'SQLAGENT'
--SET	@MessageID		= '[298]'
--SET	@KnownCondition		= 'CannotOpenDB'
--SET	@FixData_Param_01	= 'Database'
--SET	@MessageMarker_1A	= QUOTENAME('Cannot open database requested in login ''','''')
--SET	@MessageMarker_1B	= '|1A|'
--SET	@MessageMarker_2A	= QUOTENAME('Cannot open database "','''')
--SET	@MessageMarker_2B	= '|1A|'
--SET	@MessageMarker_3A	= QUOTENAME('''. Login fails','''')
--SET	@MessageMarker_3B	= '|1B|'
--SET	@MessageMarker_4A	= QUOTENAME('" requested by the login','''')
--SET	@MessageMarker_4B	= '|1B|'
--SET	@WhereFilter		= 'Message LIKE ''SQLServer Error: 4060%'''


--SET	@SourceType		= 'SQLAGENT'
--SET	@MessageID		= '[298]'
--SET	@KnownCondition		= 'Login Timeout'
--SET	@WhereFilter		= 'Message LIKE ''SQLServer Error: 258%'''


--SET	@SourceType		= 'SQLAGENT'
--SET	@MessageID		= '[298]'
--SET	@KnownCondition		= 'Agent XPs'
--SET	@WhereFilter		= 'Message LIKE ''SQLServer Error: 15281%'''

--SET	@SourceType		= 'SQLAGENT'
--SET	@MessageID		= '[298]'
--SET	@KnownCondition		= 'Database-LogFull'
--SET	@FixData_Param_01	= 'Database'
--SET	@MessageMarker_1A	= QUOTENAME('The log file for database ''','''')
--SET	@MessageMarker_1B	= '|1A|'
--SET	@MessageMarker_2A	= QUOTENAME(''' is full.','''')
--SET	@MessageMarker_2B	= '|1B|'
--SET	@WhereFilter		= 'Message LIKE ''SQLServer Error: 9002,%'''

--SET	@SourceType		= 'SQLAGENT'
--SET	@MessageID		= '[298]'
--SET	@KnownCondition		= 'AgentFailed'
--SET	@WhereFilter		= 'Message LIKE ''SQLServer Error: 65535,%'''


SET	@SourceType		= 'SQLAGENT'
--SET	@MessageID		= '[298]'
--SET	@KnownCondition		= 'AgentFailed'
--SET	@FixData_Param_01	= 'Database'
--SET	@FixData_Param_02	= ''
--SET	@FixData_Param_03	= ''
--SET	@FixData_Param_04	= ''
--SET	@FixData_Param_05	= ''
--SET	@MessageMarker_1A	= QUOTENAME('The log file for database ''','''')
--SET	@MessageMarker_1B	= '|1A|'
--SET	@MessageMarker_2A	= QUOTENAME(''' is full.','''')
--SET	@MessageMarker_2B	= '|1B|'
--SET	@MessageMarker_3A	= QUOTENAME('{LOOK FOR THIS}','''')
--SET	@MessageMarker_3B	= '{REPLACE WITH THIS}'
--SET	@MessageMarker_4A	= QUOTENAME('{LOOK FOR THIS}','''')
--SET	@MessageMarker_4B	= '{REPLACE WITH THIS}'
--SET	@MessageMarker_5A	= QUOTENAME('{LOOK FOR THIS}','''')
--SET	@MessageMarker_5B	= '{REPLACE WITH THIS}'
--SET	@MessageMarker_6A	= QUOTENAME('{LOOK FOR THIS}','''')
--SET	@MessageMarker_6B	= '{REPLACE WITH THIS}'
--SET	@MessageMarker_7A	= QUOTENAME('{LOOK FOR THIS}','''')
--SET	@MessageMarker_7B	= '{REPLACE WITH THIS}'
--SET	@MessageMarker_8A	= QUOTENAME('{LOOK FOR THIS}','''')
--SET	@MessageMarker_8B	= '{REPLACE WITH THIS}'
--SET	@MessageMarker_9A	= QUOTENAME('{LOOK FOR THIS}','''')
--SET	@MessageMarker_9B	= '{REPLACE WITH THIS}'
--SET	@WhereFilter		= 'Message LIKE ''SQLServer Error: 65535,%''''

--SQLServer Error: 233, Shared Memory Provider: No process is on the other end of the pipe. [SQLSTATE 08001]
--SQLServer Error: 831, SSL Provider: A system shutdown is in progress. [SQLSTATE 08001]
--SQLServer Error: 845, Time-out occurred while waiting for buffer latch type 2 for page (1:28), database ID 4. [SQLSTATE 42000] (ConnExecuteCachableOp)

SET	@CheckOrSet		= 0
SET	@ShowIt			= 1
SET	@RunIt			= 1
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- START IT
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
SET	@TSQL =	CASE @CheckOrSet
		WHEN 1
		THEN 'UPDATE dbaadmin.[dbo].[Filescan_History] SET'+CHAR(13)+CHAR(10)
		ELSE 'SELECT	T1.Machine
	,T1.Instance
	,T1.Message'+CHAR(13)+CHAR(10)
		END

IF @KnownCondition IS NOT NULL AND @CheckOrSet = 0
	SET @TSQL = @TSQL +  '	,[KnownCondition] = '+QUOTENAME(@KnownCondition,'''')+CHAR(13)+CHAR(10)

IF @KnownCondition IS NOT NULL AND @CheckOrSet = 1
	SET @TSQL = @TSQL +  '	[KnownCondition] = '+QUOTENAME(@KnownCondition,'''')+CHAR(13)+CHAR(10)

IF @KnownCondition IS NULL AND @CheckOrSet = 1
	SET @TSQL = @TSQL +	'	[FixData] ='+CHAR(13)+CHAR(10) 
ELSE
	SET @TSQL = @TSQL +	'	,[FixData] ='+CHAR(13)+CHAR(10) 

IF @FixData_Param_05 IS NOT NULL
	SET @TSQL = @TSQL + '		REPLACE('+CHAR(13)+CHAR(10)
IF @FixData_Param_04 IS NOT NULL
	SET @TSQL = @TSQL + '		REPLACE('+CHAR(13)+CHAR(10)
IF @FixData_Param_03 IS NOT NULL
	SET @TSQL = @TSQL + '		REPLACE('+CHAR(13)+CHAR(10)
IF @FixData_Param_02 IS NOT NULL
	SET @TSQL = @TSQL + '		REPLACE('+CHAR(13)+CHAR(10)
IF @FixData_Param_01 IS NOT NULL
	SET @TSQL = @TSQL + '		REPLACE('+CHAR(13)+CHAR(10)

SET @TSQL = @TSQL + 
'		REPLACE(
		''Server=%Server%' 
IF @FixData_Param_01 IS NOT NULL
	SET @TSQL = @TSQL + ','+@FixData_Param_01+'=%'+@FixData_Param_01+'%'
IF @FixData_Param_02 IS NOT NULL
	SET @TSQL = @TSQL + ','+@FixData_Param_02+'=%'+@FixData_Param_02+'%'
IF @FixData_Param_03 IS NOT NULL
	SET @TSQL = @TSQL + ','+@FixData_Param_03+'=%'+@FixData_Param_03+'%'
IF @FixData_Param_04 IS NOT NULL
	SET @TSQL = @TSQL + ','+@FixData_Param_04+'=%'+@FixData_Param_04+'%'
IF @FixData_Param_05 IS NOT NULL
	SET @TSQL = @TSQL + ','+@FixData_Param_05+'=%'+@FixData_Param_05+'%'
			
SET @TSQL = @TSQL + ''''+CHAR(13)+CHAR(10)+
'		,''%Server%'',T1.[Machine] + CASE WHEN T1.[Instance] > '''' THEN ''\''+T1.[Instance] ELSE ''''END)'+CHAR(13)+CHAR(10)

IF @FixData_Param_01 IS NOT NULL
	SET @TSQL = @TSQL + '		,''%'+@FixData_Param_01+'%'',SUBSTRING(T2.[MarkedMessage],CHARINDEX(''|1A|'',T2.[MarkedMessage])+4,CHARINDEX(''|1B|'',T2.[MarkedMessage])-(CHARINDEX(''|1A|'',[MarkedMessage])+4)))'+CHAR(13)+CHAR(10)
IF @FixData_Param_02 IS NOT NULL
	SET @TSQL = @TSQL + '		,''%'+@FixData_Param_02+'%'',SUBSTRING(T2.[MarkedMessage],CHARINDEX(''|2A|'',T2.[MarkedMessage])+4,CHARINDEX(''|2B|'',T2.[MarkedMessage])-(CHARINDEX(''|2A|'',[MarkedMessage])+4)))'+CHAR(13)+CHAR(10)
IF @FixData_Param_03 IS NOT NULL
	SET @TSQL = @TSQL + '		,''%'+@FixData_Param_03+'%'',SUBSTRING(T2.[MarkedMessage],CHARINDEX(''|3A|'',T2.[MarkedMessage])+4,CHARINDEX(''|3B|'',T2.[MarkedMessage])-(CHARINDEX(''|3A|'',[MarkedMessage])+4)))'+CHAR(13)+CHAR(10)
IF @FixData_Param_04 IS NOT NULL
	SET @TSQL = @TSQL + '		,''%'+@FixData_Param_04+'%'',SUBSTRING(T2.[MarkedMessage],CHARINDEX(''|4A|'',T2.[MarkedMessage])+4,CHARINDEX(''|4B|'',T2.[MarkedMessage])-(CHARINDEX(''|4A|'',[MarkedMessage])+4)))'+CHAR(13)+CHAR(10)
IF @FixData_Param_05 IS NOT NULL
	SET @TSQL = @TSQL + '		,''%'+@FixData_Param_05+'%'',SUBSTRING(T2.[MarkedMessage],CHARINDEX(''|5A|'',T2.[MarkedMessage])+4,CHARINDEX(''|5B|'',T2.[MarkedMessage])-(CHARINDEX(''|5A|'',[MarkedMessage])+4)))'+CHAR(13)+CHAR(10)

SET @TSQL = @TSQL + 
'		+ '','' + T1.[FixData]
FROM	dbaadmin.[dbo].[Filescan_History] T1
JOIN	(
	 SELECT	HistoryID
		,Message'
IF @MessageMarker_1A IS NOT NULL
	SET @TSQL = @TSQL + '		,------------------------------------------------------------------'+CHAR(13)+CHAR(10)
IF @MessageMarker_9A IS NOT NULL
	SET @TSQL = @TSQL + '		REPLACE('+CHAR(13)+CHAR(10)
IF @MessageMarker_8A IS NOT NULL
	SET @TSQL = @TSQL + '		REPLACE('+CHAR(13)+CHAR(10)
IF @MessageMarker_7A IS NOT NULL
	SET @TSQL = @TSQL + '		REPLACE('+CHAR(13)+CHAR(10)
IF @MessageMarker_6A IS NOT NULL
	SET @TSQL = @TSQL + '		REPLACE('+CHAR(13)+CHAR(10)
IF @MessageMarker_5A IS NOT NULL
	SET @TSQL = @TSQL + '		REPLACE('+CHAR(13)+CHAR(10)
IF @MessageMarker_4A IS NOT NULL
	SET @TSQL = @TSQL + '		REPLACE('+CHAR(13)+CHAR(10)
IF @MessageMarker_3A IS NOT NULL
	SET @TSQL = @TSQL + '		REPLACE('+CHAR(13)+CHAR(10)
IF @MessageMarker_2A IS NOT NULL
	SET @TSQL = @TSQL + '		REPLACE('+CHAR(13)+CHAR(10)
IF @MessageMarker_1A IS NOT NULL
	SET @TSQL = @TSQL + '		REPLACE('+CHAR(13)+CHAR(10)
IF @MessageMarker_1A IS NOT NULL
	SET @TSQL = @TSQL + '		Message'+CHAR(13)+CHAR(10)
IF @MessageMarker_1A IS NOT NULL
	SET @TSQL = @TSQL + '		,'+@MessageMarker_1A+','''+@MessageMarker_1B+''')'+CHAR(13)+CHAR(10)
IF @MessageMarker_2A IS NOT NULL
	SET @TSQL = @TSQL + '		,'+@MessageMarker_2A+','''+@MessageMarker_2B+''')'+CHAR(13)+CHAR(10)
IF @MessageMarker_3A IS NOT NULL
	SET @TSQL = @TSQL + '		,'+@MessageMarker_3A+','''+@MessageMarker_3B+''')'+CHAR(13)+CHAR(10)
IF @MessageMarker_4A IS NOT NULL
	SET @TSQL = @TSQL + '		,'+@MessageMarker_4A+','''+@MessageMarker_4B+''')'+CHAR(13)+CHAR(10)
IF @MessageMarker_5A IS NOT NULL
	SET @TSQL = @TSQL + '		,'+@MessageMarker_5A+','''+@MessageMarker_5B+''')'+CHAR(13)+CHAR(10)
IF @MessageMarker_6A IS NOT NULL
	SET @TSQL = @TSQL + '		,'+@MessageMarker_6A+','''+@MessageMarker_6B+''')'+CHAR(13)+CHAR(10)
IF @MessageMarker_7A IS NOT NULL
	SET @TSQL = @TSQL + '		,'+@MessageMarker_7A+','''+@MessageMarker_7B+''')'+CHAR(13)+CHAR(10)
IF @MessageMarker_8A IS NOT NULL
	SET @TSQL = @TSQL + '		,'+@MessageMarker_8A+','''+@MessageMarker_8B+''')'+CHAR(13)+CHAR(10)
IF @MessageMarker_9A IS NOT NULL
	SET @TSQL = @TSQL + '		,'+@MessageMarker_9A+','''+@MessageMarker_9B+''')'+CHAR(13)+CHAR(10)

IF @MessageMarker_1A IS NOT NULL
	SET @TSQL = @TSQL + '		AS [MarkedMessage]
		------------------------------------------------------------------'+CHAR(13)+CHAR(10)

SET @TSQL = @TSQL +		
'	FROM	dbaadmin.[dbo].[Filescan_History]
	WHERE	SourceType = '''+@SourceType+'''
	 AND	EventDateTime >= GetDate()-7
	 AND	KnownCondition = ''Unknown'''+CHAR(13)+CHAR(10)
	 
IF @MessageID IS NOT NULL
	SET @TSQL = @TSQL + '	 AND	[dbaadmin].[dbo].[ReturnPairValue] ([FixData],'','',''='',''MessageID'') = '+QUOTENAME(@MessageID,'''')+CHAR(13)+CHAR(10)

IF @WhereFilter IS NOT NULL
	SET @TSQL = @TSQL + '	 AND	'+@WhereFilter +CHAR(13)+CHAR(10)
SET @TSQL = @TSQL +	
'	 ) T2
 ON	T1.HistoryID = T2.HistoryID'	


IF @ShowIt = 1
	PRINT	(@TSQL)

IF @RunIt = 1
	EXEC	(@TSQL)	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	