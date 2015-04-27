SET NOCOUNT ON
USE master
GO
DECLARE	@MaxMem			INT
DECLARE @AWEDefault		INT
DECLARE @Platform		VARCHAR(255)
DECLARE	@CPUCount		INT
DECLARE	@PhysicalMemory 	INT
DECLARE	@ConfigStatus		VARCHAR(MAX)
SET	@AWEDefault		= 1

CREATE TABLE #XP_MSVER_RESULTS
	(
	[Index] int
	, [Name] varchar(255)
	, [Internal_Value] varchar(255)
	, [Character_Value] varchar(255)
	)
INSERT INTO #XP_MSVER_RESULTS
	EXEC master..xp_msver
SELECT		@CPUCount = CASE NAME
				WHEN 'ProcessorCount' THEN [Internal_Value]
				ELSE @CPUCount END
		,@PhysicalMemory = CASE NAME
				WHEN 'PhysicalMemory' THEN [Internal_Value]
				ELSE @PhysicalMemory END
		,@Platform = CASE NAME
				WHEN 'Platform' THEN [Character_Value]
				ELSE @Platform END
FROM		#XP_MSVER_RESULTS 
DROP TABLE	#XP_MSVER_RESULTS



-- CALCULATE AWE DEFAULT
IF @Platform LIKE '%64'
	SET @AWEDefault = 0

-- CALCULATE MAX MEMORY
SET	@MaxMem = @PhysicalMemory - 2048
 


declare @configurations_option_table table (
        name nvarchar(128)
,       run_value bigint
,       default_value bigint 
);
declare @sp_configure_table table (
        name nvarchar(128)
,       minimum bigint
,       maximum bigint
,       config_value bigint
,       run_value bigint 
);
declare @tracestatus table(
        TraceFlag nvarchar(40)
,       Status tinyint
,       Global tinyint
,       Session tinyint
);

declare @trace_option_table table(
        TraceFlag nvarchar(40)
,       Status tinyint
,       Global tinyint
,       Session tinyint
);

insert into @sp_configure_table 
select name
,       convert(bigint,minimum)
,       convert(bigint,maximum)
,       convert(bigint,value)
,       convert(bigint,value_in_use) 
from sys.configurations  


-- THESE DEFAULT VALUES REPRESENT GETTY IMAGES DEFAULT CONFIG
insert into @configurations_option_table values('Ad Hoc Distributed Queries',0,0)
insert into @configurations_option_table values('affinity I/O mask',0,0)
insert into @configurations_option_table values('affinity mask',0,0)
insert into @configurations_option_table values('Agent XPs',1,1)
insert into @configurations_option_table values('allow updates',0,0)
insert into @configurations_option_table values('awe enabled',1,1)--,@AWEDefault,@AWEDefault)
insert into @configurations_option_table values('blocked process threshold',0,0)
insert into @configurations_option_table values('c2 audit mode',0,0)
insert into @configurations_option_table values('clr enabled',1,1)
insert into @configurations_option_table values('cost threshold for parallelism',5,5)
insert into @configurations_option_table values('cross db ownership chaining',0,0)
insert into @configurations_option_table values('cursor threshold',-1,-1)
insert into @configurations_option_table values('Database Mail XPs',0,0)
insert into @configurations_option_table values('default full-text language',1033,1033)
insert into @configurations_option_table values('default language',0,0)
insert into @configurations_option_table values('default trace enabled',1,1)
insert into @configurations_option_table values('disallow results from triggers',1,1)
insert into @configurations_option_table values('fill factor (%)',0,0)
insert into @configurations_option_table values('ft crawl bandwidth (max)',100,100)
insert into @configurations_option_table values('ft crawl bandwidth (min)',0,0)
insert into @configurations_option_table values('ft notify bandwidth (max)',100,100)
insert into @configurations_option_table values('ft notify bandwidth (min)',0,0)
insert into @configurations_option_table values('index create memory (KB)',0,0)
insert into @configurations_option_table values('in-doubt xact resolution',0,0)
insert into @configurations_option_table values('lightweight pooling',0,0)
insert into @configurations_option_table values('locks',0,0)
insert into @configurations_option_table values('max degree of parallelism',0,0)
insert into @configurations_option_table values('max full-text crawl range',4,4)
insert into @configurations_option_table values('max server memory (MB)',@MaxMem,@MaxMem)
insert into @configurations_option_table values('max text repl size (B)',65536,65536)
insert into @configurations_option_table values('max worker threads',0,0)
insert into @configurations_option_table values('media retention',0,0)
insert into @configurations_option_table values('min memory per query (KB)',1024,1024)
insert into @configurations_option_table values('min server memory (MB)',0,0)
insert into @configurations_option_table values('nested triggers',1,1)
insert into @configurations_option_table values('network packet size (B)',4096,4096)
insert into @configurations_option_table values('Ole Automation Procedures',1,1)
insert into @configurations_option_table values('open objects',0,0)
insert into @configurations_option_table values('PH timeout (s)',60,60)
insert into @configurations_option_table values('precompute rank',0,0)
insert into @configurations_option_table values('priority boost',0,0)
insert into @configurations_option_table values('query governor cost limit',0,0)
insert into @configurations_option_table values('query wait (s)',-1,-1)
insert into @configurations_option_table values('recovery interval (min)',0,0)
insert into @configurations_option_table values('remote access',1,1)
insert into @configurations_option_table values('remote admin connections',1,1)
insert into @configurations_option_table values('remote login timeout (s)',20,20)
insert into @configurations_option_table values('remote proc trans',1,1)
insert into @configurations_option_table values('remote query timeout (s)',600,600)
insert into @configurations_option_table values('Replication XPs',0,0)
insert into @configurations_option_table values('RPC parameter data validation',0,0)
insert into @configurations_option_table values('scan for startup procs',0,0)
insert into @configurations_option_table values('server trigger recursion',1,1)
insert into @configurations_option_table values('set working set size',0,0)
insert into @configurations_option_table values('show advanced options',1,1)
insert into @configurations_option_table values('SMO and DMO XPs',1,1)
insert into @configurations_option_table values('SQL Mail XPs',0,0)
insert into @configurations_option_table values('transform noise words',0,0)
insert into @configurations_option_table values('two digit year cutoff',2049,2049)
insert into @configurations_option_table values('user connections',0,0)
insert into @configurations_option_table values('user options',0,0)
insert into @configurations_option_table values('Web Assistant Procedures',0,0)
insert into @configurations_option_table values('xp_cmdshell',1,1)


-- DEFAULT TRACE FLAGS
insert into @trace_option_table values('Traceflag (1118)',1,1,0)
insert into @trace_option_table values('Traceflag (1222)',1,1,0)
insert into @trace_option_table values('Traceflag (3604)',1,1,0)
insert into @trace_option_table values('Traceflag (845)',1,1,0)


insert into @tracestatus exec('dbcc tracestatus WITH NO_INFOMSGS')
update @tracestatus set TraceFlag = 'Traceflag ('+TraceFlag+')'

SET @ConfigStatus = '[ ] [X] FAILURE...		CONFIGURES		The Following config options are not correct.' + CHAR(13) + CHAR(10)

SELECT		@ConfigStatus = @ConfigStatus + '							' + NAME + ' ' + FIX_IT +  CHAR(13) + CHAR(10)
FROM		(
		select 1 as l1
		,       st.name as name 
		,       convert(nvarchar(15),st.run_value) as run_value
		,       convert(nvarchar(15),ct.default_value) as default_value
		,       1 as msg 
		,	'EXEC sp_configure ''' + st.name +''', ' + convert(nvarchar(15),ct.default_value)   AS FIX_IT
		from @configurations_option_table ct 
		inner join  @sp_configure_table st on (ct.name = st.name  and ct.default_value != st.run_value)
		UNION
		SELECT		2 as l1
		,		'Extra - ' + T2.TraceFlag as name
		,       '1' as run_value
		,       '0' as default_value
		,       1 as msg 
		,	'' AS FIX_IT  
		from		@trace_option_table T1
		FULL JOIN	@tracestatus T2
			ON	T1.TraceFlag = T2.TraceFlag
		WHERE		T1.TraceFlag IS NULL
		UNION 
		SELECT		3 as l1
		,		'Missing - ' + T1.TraceFlag as name
		,       '0' as run_value
		,       '1' as default_value
		,       1 as msg
		,	'' AS FIX_IT  
		from		@trace_option_table T1
		FULL JOIN	@tracestatus T2
			ON	T1.TraceFlag = T2.TraceFlag
		WHERE		T2.TraceFlag IS NULL
		) DATA
ORDER BY 1
IF @@ROWCOUNT = 0
	SET @ConfigStatus = '[X] [ ] SUCCESS...		CONFIGURES		All Config Options are correct.'
PRINT 	@ConfigStatus
