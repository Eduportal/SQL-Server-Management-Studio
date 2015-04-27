set nocount on ;

if object_id(N'[Bcp].[ProcessList]') is null
	create table [Bcp].[ProcessList]
	(SpidNumber smallint not null
	,SpidBatchTime datetime not null
	,ProcessID int not null
	,ProcessName varchar(64) not null
	,ProcessStartTime datetime not null
	,ProcessGUID uniqueidentifier not null
	) ;

exec DbDoc.ObjectSet @SchemaName=Bcp,@ObjectName=ProcessList,@XSpec=
N'<object
	description="Maintains a historical list of processes started by BcpExport for cleanup purposes."
	>
</object>' ;
