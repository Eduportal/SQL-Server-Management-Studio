DECLARE @state VARCHAR(30)
DECLARE @DbMirrored INT
DECLARE @DbId INT
DECLARE @String VARCHAR(100)
DECLARE @databases TABLE (DBid INT, mirroring_state_desc VARCHAR(30))
 
-- get status for mirrored databases
INSERT @databases
SELECT database_id, mirroring_state_desc
FROM sys.database_mirroring
WHERE mirroring_role_desc IN ('PRINCIPAL','MIRROR')
AND mirroring_state_desc NOT IN ('SYNCHRONIZED','SYNCHRONIZING')
 
-- iterate through mirrored databases and send email alert
WHILE EXISTS (SELECT TOP 1 DBid FROM @databases WHERE mirroring_state_desc IS NOT NULL)
BEGIN
SELECT TOP 1 @DbId = DBid, @State = mirroring_state_desc
FROM @databases
SET @string = 'Host: '+@@servername+'.'+CAST(DB_NAME(@DbId) AS VARCHAR)+ ' - DB Mirroring is '+@state +' - notify DBA'
EXEC dbaadmin.dbo.dbasp_sendmail 
	@recipients	= 'steve.ledridge@gmail.com'
	,@subject	= @string
	,@message	= @string
DELETE FROM @databases WHERE DBid = @DbId
END
 
--also alert if there is no mirroring just in case there should be mirroring :)
SELECT @DbMirrored = COUNT(*)
FROM sys.database_mirroring
WHERE mirroring_state IS NOT NULL
IF @DbMirrored = 0
BEGIN
SET @string = 'Host: '+@@servername+' - No databases are mirrored on this server - notify DBA'
EXEC dbaadmin.dbo.dbasp_sendmail 
	@recipients	= 'steve.ledridge@gettyimages.com'
	,@subject	= @string
	,@message	= @string
END
GO



--SELECT		DB_NAME(database_id)		[DBName]
--		,mirroring_role_desc		[Role]
--		,mirroring_partner_instance	[Partner]
--		,mirroring_state_desc		[State]

--		,CASE	WHEN mirroring_state_desc NOT IN ('SYNCHRONIZED','SYNCHRONIZING') THEN 1 
--			WHEN mirroring_safety_level != 1 THEN 1

--		ELSE 0 END [IsAlarm]
--		,CASE	WHEN mirroring_state_desc NOT IN ('SYNCHRONIZED','SYNCHRONIZING') THEN  mirroring_state_desc
--			WHEN mirroring_safety_level != 1 THEN 'NOT HIGH SPEED ASYNCHRONOUS'

--		ELSE NULL END [Alarm]
		

--FROM		sys.database_mirroring
--WHERE		mirroring_role_desc IN ('PRINCIPAL','MIRROR')

--SELECT * FROM sys.database_mirroring_endpoints


--SELECT		*

--FROM		sys.dm_os_performance_counters
--WHERE		object_name IN ('SQLServer:Database Mirroring','SQLServer:Databases','Logical Disk','','')
--	AND	counter_name IN ('Send/Receive Ack Time','Log Bytes Sent/sec','Log Send Queue KB','Transaction Delay','Transactions/sec','Log Bytes Flushed/sec','Disk Write Bytes/sec','Redo Bytes/sec','Redo Queue KB')
--ORDER BY	1,2,3
--GO


--Declare		@LBS		bigint
--		,@LBS_Delta	bigint
--		,@LBSC		bigint
--		,@LBSC_Delta	bigint
--		,@SRAT		bigint
--		,@SRAT_Delta	bigint
		

--Select		@LBS		= CASE counter_name  WHEN 'Log Bytes Sent/sec' THEN cntr_value ELSE @LBS END
--		,@LBSC		= CASE counter_name  WHEN 'Log Bytes Sent from Cache/sec' THEN cntr_value ELSE @LBSC END
--		,@SRAT		= CASE counter_name  WHEN 'Send/Receive Ack Time' THEN cntr_value ELSE @SRAT END
--From		sys.dm_os_performance_counters
--Where		object_name Like '%:Database Mirroring%'
----	And	counter_name = 'Log Bytes Sent/sec'
--	And	instance_name = 'Getty_Images_US_Inc__MSCRM';

--Waitfor Delay '0:00:10';

--Select		@LBS_Delta	= CASE counter_name  WHEN 'Log Bytes Sent/sec' THEN cntr_value ELSE @LBS_Delta END
--		,@LBSC_Delta	= CASE counter_name  WHEN 'Log Bytes Sent from Cache/sec' THEN cntr_value ELSE @LBSC_Delta END
--		,@SRAT_Delta	= CASE counter_name  WHEN 'Send/Receive Ack Time' THEN cntr_value ELSE @SRAT_Delta END
--From		sys.dm_os_performance_counters
--Where		object_name Like '%:Database Mirroring%'
----	And	counter_name = 'Log Bytes Sent/sec'
--	And	instance_name = 'Getty_Images_US_Inc__MSCRM';

--Select		Convert(decimal(11,2), (@LBS_Delta - @LBS)/10.0)
--		,Convert(decimal(11,2), (@LBSC_Delta - @LBSC)/10.0)
--		,Convert(decimal(11,2), (@SRAT_Delta - @SRAT)/10.0)




--EXEC msdb.sys.sp_dbmmonitorresults @database_name = 'Getty_Images_US_Inc__MSCRM',@mode = 0,@update_table = 1
--EXEC msdb.sys.sp_dbmmonitorresults @database_name = 'Getty_Images_CRM_GENESYS',@mode = 0,@update_table = 1
--EXEC msdb.sys.sp_dbmmonitorresults @database_name = 'Getty_Images_US_Inc_Custom',@mode = 0,@update_table = 1



exec msdb.sys.sp_dbmmonitorupdate
GO
;with		Latest
		AS
		(
		SELECT		*
		FROM		(
				SELECT		db_name(database_id) [DBName]
						,*
						,ROW_NUMBER() OVER(PARTITION BY [database_id] ORDER BY local_time desc) [rownmbr]
				FROM		msdb.dbo.dbm_monitor_data
				) Data
		WHERE		[rownmbr] = 1
		)
		,T2
		AS
		(
		SELECT		*
		FROM		(
				SELECT		db_name(T1.database_id) [DBName]
						,T1.*
						,ROW_NUMBER() OVER(PARTITION BY T1.[database_id] ORDER BY T1.local_time desc) [rownmbr]
				FROM		msdb.dbo.dbm_monitor_data T1
				JOIN		Latest T2
					ON	T1.database_id = T2.database_id
					AND	T1.end_of_log_lsn = T2.failover_lsn
				) Data
		WHERE		[rownmbr] = 1
		)
		,MirrorDelay
		AS
		(
		SELECT		T1.DBName
				,(DATEDIFF(ss,T2.local_time,T1.local_time))/86400		[day]
				,convert(int,DATEDIFF(mi,T2.local_time,T1.local_time))/60	[hour]
				,convert(int,DATEDIFF(mi,T2.local_time,T1.local_time))%60	[min]

		FROM		Latest T1
		LEFT JOIN	T2
			ON	T1.database_id = T2.database_id
		)

SELECT		DB_NAME(database_id)		[DBName]
		,mirroring_role_desc		[Role]
		,mirroring_partner_instance	[Partner]
		,mirroring_state_desc		[State]
		,[day]
		,[hour]
		,[min]

		,CASE	WHEN mirroring_state_desc NOT IN ('SYNCHRONIZED','SYNCHRONIZING') THEN 1 
			WHEN mirroring_safety_level != 1 THEN 1

		ELSE 0 END [IsAlarm]
		,CASE	WHEN mirroring_state_desc NOT IN ('SYNCHRONIZED','SYNCHRONIZING') THEN  mirroring_state_desc
			WHEN mirroring_safety_level != 1 THEN 'NOT HIGH SPEED ASYNCHRONOUS'

		ELSE NULL END [Alarm]
		

FROM		sys.database_mirroring T1
JOIN		MirrorDelay T2
	ON	DB_NAME(T1.database_id) = T2.DBName

WHERE		mirroring_role_desc IN ('PRINCIPAL','MIRROR')


--declare @local_time1 datetime,@end_of_log_lsn1 numeric(25,0),@failover_lsn1 numeric(25,0)
--declare @local_time2 datetime,@end_of_log_lsn2 numeric(25,0),@failover_lsn2 numeric(25,0)
--declare @min int,@hour int,@day int,@min1 int
--declare @old_unsent_trn varchar(100)


--select top(1) @local_time1=local_time,@end_of_log_lsn1=end_of_log_lsn,@failover_lsn1=failover_lsn
--from msdb.dbo.dbm_monitor_data
--where database_id = 8
-- and failover_lsn IN (SELECT end_of_log_lsn FROM msdb.dbo.dbm_monitor_data where database_id = 8)
--order by local_time desc

--select @local_time1 local_time1,@end_of_log_lsn1 end_of_log_lsn1,@failover_lsn1 failover_lsn1

--select top(1) @local_time2=local_time,@end_of_log_lsn2=end_of_log_lsn,@failover_lsn2=failover_lsn
--from  msdb.dbo.dbm_monitor_data
--where database_id = 8
--and end_of_log_lsn=@failover_lsn1
--order by local_time desc

--select @local_time2 local_time2,@end_of_log_lsn2 end_of_log_lsn2,@failover_lsn2 failover_lsn2

--select @day=(DATEDIFF(ss,@local_time2,@local_time1))/86400
--select @min1=DATEDIFF(mi,@local_time2,@local_time1)
--select @hour=convert(int,@min1)/60


--select @min=convert(int,@min1)%60

--select @day,@hour,@min1
--select @old_unsent_trn=convert(varchar(20),@day)+':'+convert(varchar(20),@hour)+':'+convert(varchar(20),@min)
--select @old_unsent_trn 'Oldest Unsent Transaction'





--select top(1) @local_time1=local_time,@end_of_log_lsn1=end_of_log_lsn,@failover_lsn1=failover_lsn
--from msdb.dbo.dbm_monitor_data
--where database_id = 10
--order by local_time desc

--select @local_time1 local_time1,@end_of_log_lsn1 end_of_log_lsn1,@failover_lsn1 failover_lsn1

--select top(1) @local_time2=local_time,@end_of_log_lsn2=end_of_log_lsn,@failover_lsn2=failover_lsn
--from  msdb.dbo.dbm_monitor_data
--where database_id = 10
--and end_of_log_lsn=@failover_lsn1
--order by local_time desc

--select @local_time2 local_time2,@end_of_log_lsn2 end_of_log_lsn2,@failover_lsn2 failover_lsn2

--select @day=(DATEDIFF(ss,@local_time2,@local_time1))/86400
--select @min1=DATEDIFF(mi,@local_time2,@local_time1)
--select @hour=convert(int,@min1)/60


--select @min=convert(int,@min1)%60

--select @day,@hour,@min1
--select @old_unsent_trn=convert(varchar(20),@day)+':'+convert(varchar(20),@hour)+':'+convert(varchar(20),@min)
--select @old_unsent_trn 'Oldest Unsent Transaction'


--select top(1) @local_time1=local_time,@end_of_log_lsn1=end_of_log_lsn,@failover_lsn1=failover_lsn
--from msdb.dbo.dbm_monitor_data
--where database_id = 14
--order by local_time desc

--select @local_time1 local_time1,@end_of_log_lsn1 end_of_log_lsn1,@failover_lsn1 failover_lsn1

--select top(1) @local_time2=local_time,@end_of_log_lsn2=end_of_log_lsn,@failover_lsn2=failover_lsn
--from  msdb.dbo.dbm_monitor_data
--where database_id = 14
--and end_of_log_lsn=@failover_lsn1
--order by local_time desc

--select @local_time2 local_time2,@end_of_log_lsn2 end_of_log_lsn2,@failover_lsn2 failover_lsn2

--select @day=(DATEDIFF(ss,@local_time2,@local_time1))/86400
--select @min1=DATEDIFF(mi,@local_time2,@local_time1)
--select @hour=convert(int,@min1)/60


--select @min=convert(int,@min1)%60

--select @day,@hour,@min1
--select @old_unsent_trn=convert(varchar(20),@day)+':'+convert(varchar(20),@hour)+':'+convert(varchar(20),@min)
--select @old_unsent_trn 'Oldest Unsent Transaction'







