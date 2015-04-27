SELECT		*

FROM		sys.dm_os_performance_counters
WHERE		object_name IN ('SQLServer:Database Mirroring','SQLServer:Databases','Logical Disk','','')
	AND	counter_name IN ('Send/Receive Ack Time','Log Bytes Sent/sec','Log Send Queue KB','Transaction Delay','Transactions/sec','Log Bytes Flushed/sec','Disk Write Bytes/sec','Redo Bytes/sec','Redo Queue KB')
ORDER BY	1,2,3
GO


Declare		@LBS		bigint
		,@LBS_Delta	bigint
		,@LBSC		bigint
		,@LBSC_Delta	bigint
		,@SRAT		bigint
		,@SRAT_Delta	bigint
		

Select		@LBS		= CASE counter_name  WHEN 'Log Bytes Sent/sec' THEN cntr_value ELSE @LBS END
		,@LBSC		= CASE counter_name  WHEN 'Log Bytes Sent from Cache/sec' THEN cntr_value ELSE @LBSC END
		,@SRAT		= CASE counter_name  WHEN 'Send/Receive Ack Time' THEN cntr_value ELSE @SRAT END
From		sys.dm_os_performance_counters
Where		object_name Like '%:Database Mirroring%'
--	And	counter_name = 'Log Bytes Sent/sec'
	And	instance_name = 'DeliveryDB';

Waitfor Delay '0:00:10';

Select		@LBS_Delta	= CASE counter_name  WHEN 'Log Bytes Sent/sec' THEN cntr_value ELSE @LBS_Delta END
		,@LBSC_Delta	= CASE counter_name  WHEN 'Log Bytes Sent from Cache/sec' THEN cntr_value ELSE @LBSC_Delta END
		,@SRAT_Delta	= CASE counter_name  WHEN 'Send/Receive Ack Time' THEN cntr_value ELSE @SRAT_Delta END
From		sys.dm_os_performance_counters
Where		object_name Like '%:Database Mirroring%'
--	And	counter_name = 'Log Bytes Sent/sec'
	And	instance_name = 'DeliveryDB';

Select		Convert(decimal(11,2), (@LBS_Delta - @LBS)/10.0)
		,Convert(decimal(11,2), (@LBSC_Delta - @LBSC)/10.0)
		,Convert(decimal(11,2), (@SRAT_Delta - @SRAT)/10.0)










GO

USE msdb;
GO
EXEC sp_dbmmonitoraddmonitoring;
GO


EXEC sys.sp_dbmmonitorresults
       @database_name = 'DeliveryDB', -- sysname
       @mode = 0, -- int
       @update_table = 0 -- int