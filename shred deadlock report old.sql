SELECT		XEventData.Xevent.value('@timestamp', 'datetime2(3)')					[TimeStamp]
		,DATEDIFF(minute,XEventData.Xevent.value('@timestamp', 'datetime2(3)'),GetutcDate())	[MinAgo]
		,CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/resource-list[1]/pagelock[1]/@objectname', 'varchar(200)')	[PagelockObject]
		,CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/resource-list[1]/objectlock[1]/@objectname', 'varchar(200)')	[DeadlockObject]
		,CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/resource-list[1]/keylock[1]/@objectname', 'varchar(200)')		[KeyLockObject] 
		,CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/resource-list[1]/keylock[1]/@indexname', 'varchar(200)')		[KeyLockIndex]
 
		,CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/resource-list[1]/keylock[1]/@hobtid', 'varchar(200)')	[hobtid1] 
		,CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/resource-list[1]/keylock[2]/@hobtid', 'varchar(200)')	[hobtid2]

		,(SELECT OBJECT_SCHEMA_NAME(object_id)+'.'+OBJECT_NAME(object_id) FROM sys.partitions WHERE hobt_id = CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/resource-list[1]/keylock[1]/@hobtid', 'varchar(200)')) [Object1]
		,(SELECT OBJECT_SCHEMA_NAME(object_id)+'.'+OBJECT_NAME(object_id) FROM sys.partitions WHERE hobt_id = CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/resource-list[1]/keylock[2]/@hobtid', 'varchar(200)')) [Object2]

		,CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/process-list[1]/process[1]/@waitresource', 'varchar(200)') [WR1]
		,CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/process-list[1]/process[2]/@waitresource', 'varchar(200)') [WR2]

		,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/process-list[1]/process[1]/@waitresource', 'varchar(200)'),':','|'),'(','|'),1) [WR1A]
		,DB_NAME(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/process-list[1]/process[1]/@waitresource', 'varchar(200)'),':','|'),'(','|'),2)) [WR1B]
		,(SELECT OBJECT_SCHEMA_NAME(object_id)+'.'+OBJECT_NAME(object_id) FROM sys.partitions WHERE hobt_id = dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/process-list[1]/process[1]/@waitresource', 'varchar(200)'),':','|'),'(','|'),3)) [WR1C]

		,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/process-list[1]/process[2]/@waitresource', 'varchar(200)'),':','|'),'(','|'),1) [WR2A]
		,DB_NAME(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/process-list[1]/process[2]/@waitresource', 'varchar(200)'),':','|'),'(','|'),2)) [WR2B]
		,(SELECT OBJECT_SCHEMA_NAME(object_id)+'.'+OBJECT_NAME(object_id) FROM sys.partitions WHERE hobt_id = dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/process-list[1]/process[2]/@waitresource', 'varchar(200)'),':','|'),'(','|'),3)) [WR2C]

		,CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/process-list[1]/process[1]/inputbuf[1]', 'varchar(1000)') [IB1]
		,CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/process-list[1]/process[2]/inputbuf[1]', 'varchar(1000)') [IB2]


		,CASE	WHEN RIGHT(LTRIM(RTRIM(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/process-list[1]/process[1]/inputbuf[1]', 'varchar(1000)'),'[','|'),']','|'),'Database Id =','|'),'Object Id =','|'),1))),4) = 'Proc'
			THEN 
			    OBJECT_NAME	(
					LTRIM(RTRIM(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/process-list[1]/process[1]/inputbuf[1]', 'varchar(1000)'),'[','|'),']','|'),'Database Id =','|'),'Object Id =','|'),4)))
					,LTRIM(RTRIM(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/process-list[1]/process[1]/inputbuf[1]', 'varchar(1000)'),'[','|'),']','|'),'Database Id =','|'),'Object Id =','|'),3)))
					) ELSE 'XXX' END [IBO1]

		,CASE	WHEN RIGHT(LTRIM(RTRIM(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/process-list[1]/process[2]/inputbuf[1]', 'varchar(1000)'),'[','|'),']','|'),'Database Id =','|'),'Object Id =','|'),1))),4) = 'Proc'
			THEN 
			    OBJECT_NAME	(
					LTRIM(RTRIM(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/process-list[1]/process[2]/inputbuf[1]', 'varchar(1000)'),'[','|'),']','|'),'Database Id =','|'),'Object Id =','|'),4)))
					,LTRIM(RTRIM(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/process-list[1]/process[2]/inputbuf[1]', 'varchar(1000)'),'[','|'),']','|'),'Database Id =','|'),'Object Id =','|'),3)))
					) END [IBO2]

		--,CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML)
		,CAST(XEventData.XEvent.value('(data/value)[1]', 'varchar(max)') AS XML) [xml_deadlock_report]







FROM		(
		SELECT		CAST(target_data AS XML) [TargetData]
		FROM		sys.dm_xe_session_targets
		JOIN		sys.dm_xe_sessions
			ON	event_session_address = address
		WHERE		name = 'system_health'
			AND	target_name = 'ring_buffer'
		) [Data]
CROSS APPLY	TargetData.nodes ('RingBufferTarget/event[@name="xml_deadlock_report"]') AS XEventData (XEvent)
CROSS APPLY	XEventData.Xevent.nodes ('data/value') AS datavalue(c)

--WHERE		DB_NAME(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(CAST(datavalue.c.value('(./text())[1]', 'nvarchar(max)') AS XML).value('/deadlock[1]/process-list[1]/process[1]/@waitresource', 'varchar(200)'),':','|'),'(','|'),2)) = DB_NAME()

ORDER BY	2 desc



