begin try
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

insert into @sp_configure_table 
select name
,       convert(bigint,minimum)
,       convert(bigint,maximum)
,       convert(bigint,value)
,       convert(bigint,value_in_use) 
from sys.configurations  

insert into @configurations_option_table values('Ad Hoc Distributed Queries',0,0)
insert into @configurations_option_table values('affinity I/O mask',0,0)
insert into @configurations_option_table values('affinity mask',0,0)
insert into @configurations_option_table values('Agent XPs',0,0)
insert into @configurations_option_table values('allow updates',0,0)
insert into @configurations_option_table values('awe enabled',0,0)
insert into @configurations_option_table values('blocked process threshold',0,0)
insert into @configurations_option_table values('c2 audit mode',0,0)
insert into @configurations_option_table values('clr enabled',0,0)
insert into @configurations_option_table values('cost threshold for parallelism',5,5)
insert into @configurations_option_table values('cross db ownership chaining',0,0)
insert into @configurations_option_table values('cursor threshold',-1,-1)
insert into @configurations_option_table values('Database Mail XPs',0,0)
insert into @configurations_option_table values('default full-text language',1033,1033)
insert into @configurations_option_table values('default language',0,0)
insert into @configurations_option_table values('default trace enabled',1,1)
insert into @configurations_option_table values('disallow results from triggers',0,0)
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
insert into @configurations_option_table values('max server memory (MB)',2147483647,2147483647)
insert into @configurations_option_table values('max text repl size (B)',65536,65536)
insert into @configurations_option_table values('max worker threads',0,0)
insert into @configurations_option_table values('media retention',0,0)
insert into @configurations_option_table values('min memory per query (KB)',1024,1024)
insert into @configurations_option_table values('min server memory (MB)',0,0)
insert into @configurations_option_table values('nested triggers',1,1)
insert into @configurations_option_table values('network packet size (B)',4096,4096)
insert into @configurations_option_table values('Ole Automation Procedures',0,0)
insert into @configurations_option_table values('open objects',0,0)
insert into @configurations_option_table values('PH timeout (s)',60,60)
insert into @configurations_option_table values('precompute rank',0,0)
insert into @configurations_option_table values('priority boost',0,0)
insert into @configurations_option_table values('query governor cost limit',0,0)
insert into @configurations_option_table values('query wait (s)',-1,-1)
insert into @configurations_option_table values('recovery interval (min)',0,0)
insert into @configurations_option_table values('remote access',1,1)
insert into @configurations_option_table values('remote admin connections',0,0)
insert into @configurations_option_table values('remote login timeout (s)',20,20)
insert into @configurations_option_table values('remote proc trans',0,0)
insert into @configurations_option_table values('remote query timeout (s)',600,600)
insert into @configurations_option_table values('Replication XPs',0,0)
insert into @configurations_option_table values('RPC parameter data validation',0,0)
insert into @configurations_option_table values('scan for startup procs',0,0)
insert into @configurations_option_table values('server trigger recursion',1,1)
insert into @configurations_option_table values('set working set size',0,0)
insert into @configurations_option_table values('show advanced options',0,0)
insert into @configurations_option_table values('SMO and DMO XPs',1,1)
insert into @configurations_option_table values('SQL Mail XPs',0,0)
insert into @configurations_option_table values('transform noise words',0,0)
insert into @configurations_option_table values('two digit year cutoff',2049,2049)
insert into @configurations_option_table values('user connections',0,0)
insert into @configurations_option_table values('user options',0,0)
insert into @configurations_option_table values('Web Assistant Procedures',0,0)
insert into @configurations_option_table values('xp_cmdshell',0,0)

insert into @tracestatus exec('dbcc tracestatus')
update @tracestatus set TraceFlag = 'Traceflag ('+TraceFlag+')'

select 1 as l1
,       st.name as name 
,       convert(nvarchar(15),st.run_value) as run_value
,       convert(nvarchar(15),ct.default_value) as default_value
,       1 as msg  
from @configurations_option_table ct 
inner join  @sp_configure_table st on (ct.name = st.name  and ct.default_value != st.run_value)
union
select 1 as l1
,       TraceFlag as name
,       convert(nvarchar(15), Status) as run_value
,       '0' as default_value
,       1 as msg  
from @tracestatus where Global=1 order by name
end try
begin catch
select -100 as l1
,       ERROR_NUMBER() as name
,       ERROR_SEVERITY() as run_value
,       ERROR_STATE() as default_value
,       ERROR_MESSAGE() as msg
end catch