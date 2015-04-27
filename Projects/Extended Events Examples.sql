USE [msdb];
GO

-- Drop the notification if it exists
IF EXISTS ( SELECT  *
            FROM    sys.server_event_notifications
            WHERE   name = N'CaptureAutogrowEvents' ) 
    BEGIN
        DROP EVENT NOTIFICATION CaptureAutogrowEvents ON SERVER;
    END

-- Drop the route if it exists
IF EXISTS ( SELECT  *
            FROM    sys.routes
            WHERE   name = N'AutogrowEventRoute' ) 
    BEGIN
        DROP ROUTE AutogrowEventRoute;
    END

-- Drop the service if it exists
IF EXISTS ( SELECT  *
            FROM    sys.services
            WHERE   name = N'AutogrowEventService' ) 
    BEGIN
        DROP SERVICE AutogrowEventService;
    END

-- Drop the queue if it exists
IF EXISTS ( SELECT  *
            FROM    sys.service_queues
            WHERE   name = N'AutogrowEventQueue' ) 
    BEGIN
        DROP QUEUE AutogrowEventQueue;
    END

--  Create a service broker queue to hold the events
CREATE QUEUE [AutogrowEventQueue]
WITH STATUS=ON;
GO

--  Create a service broker service receive the events
CREATE SERVICE [AutogrowEventService]
ON QUEUE [AutogrowEventQueue] ([http://schemas.microsoft.com/SQL/Notifications/PostEventNotification]);
GO

-- Create a service broker route to the service
CREATE ROUTE [AutogrowEventRoute]
WITH SERVICE_NAME = 'AutogrowEventService',
ADDRESS = 'LOCAL';
GO

-- Create the event notification to capture the events
CREATE EVENT NOTIFICATION [CaptureAutogrowEvents]
ON SERVER
WITH FAN_IN
FOR DATA_FILE_AUTO_GROW, DATA_FILE_AUTO_SHRINK, LOG_FILE_AUTO_GROW, LOG_FILE_AUTO_SHRINK
TO SERVICE 'AutogrowEventService', 'current database';
GO



GO
DROP EVENT SESSION [DatabaseSizeChange] ON SERVER
GO
CREATE EVENT SESSION [DatabaseSizeChange] ON SERVER
ADD EVENT sqlserver.databases_data_file_size_changed	(ACTION (sqlserver.client_hostname, sqlserver.database_context, sqlserver.nt_username, sqlserver.session_nt_username, sqlserver.username)),
ADD EVENT sqlserver.databases_log_file_size_changed	(ACTION (sqlserver.client_hostname, sqlserver.database_context, sqlserver.nt_username, sqlserver.session_nt_username, sqlserver.username))
ADD TARGET package0.asynchronous_file_target		(SET filename='\\GMSSQLTEST03\GMSSQLTEST03$A_log\DatabaseSizeChange.xel',max_file_size=100, max_rollover_files=10)
WITH (MAX_MEMORY = 4096KB, 
EVENT_RETENTION_MODE = NO_EVENT_LOSS, 
MAX_DISPATCH_LATENCY = 300 SECONDS, 
MAX_EVENT_SIZE = 0KB, 
MEMORY_PARTITION_MODE = NONE, 
TRACK_CAUSALITY = OFF, STARTUP_STATE = ON)

ALTER EVENT SESSION [DatabaseSizeChange] ON SERVER STATE = START

SELECT		n.value('(@name)[1]', 'varchar(50)') AS event_name,
		n.value('(@package)[1]', 'varchar(50)') AS package_name,
		n.value('(@id)[1]', 'int') AS id,
		n.value('(@version)[1]', 'int') AS version,
		DATEADD(hh,DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP),n.value('(@timestamp)[1]', 'datetime2')) AS [timestamp],
		n.value('(data[@name="count"]/value)[1]', 'int') as [Count],
		n.value('(data[@name="database_id"]/value)[1]', 'int') as [database_id],
		n.value('(action[@name="client_hostname"]/value)[1]', 'varchar(50)') as [client_hostname],
		n.value('(action[@name="nt_username"]/value)[1]', 'varchar(50)') as [nt_username],
		event_data
FROM		(
		SELECT		CAST(event_data AS XML) AS 'event_data'
		FROM sys.fn_xe_file_target_read_file('\\GMSSQLTEST03\GMSSQLTEST03$A_log\DatabaseSizeChange*.xel', '\\GMSSQLTEST03\GMSSQLTEST03$A_log\DatabaseSizeChange*.xem', NULL, NULL)
		) EXEvents
CROSS APPLY	event_data.nodes('event') as q(n)






SELECT
  EventType = message_body.value('(/EVENT_INSTANCE/EventType)[1]',
                                       'varchar(128)') ,
  Duration = message_body.value('(/EVENT_INSTANCE/Duration)[1]',
                                'varchar(128)') ,
  ServerName = message_body.value('(/EVENT_INSTANCE/ServerName)[1]',
                                  'varchar(128)') ,
  PostTime = CAST(message_body.value('(/EVENT_INSTANCE/PostTime)[1]',
                                     'datetime') AS VARCHAR) ,
  DatabaseName = message_body.value('(/EVENT_INSTANCE/DatabaseName)[1]',
                                    'varchar(128)') ,
  GrowthPages = message_body.value('(/EVENT_INSTANCE/IntegerData)[1]',
                                   'int')
FROM    ( SELECT    CAST(message_body AS XML) AS message_body
          FROM      [AutogrowEventQueue]
        ) AS Tab

order by 4














-- XEvents with customizable columns  
SELECT 
    p.name AS package_name,
    o.name AS event_name,
    oc.name AS column_name,
    oc.column_type,
    oc.type_name,
    oc.description
FROM sys.dm_xe_packages p
JOIN sys.dm_xe_objects o
    ON p.guid = o.package_guid
JOIN sys.dm_xe_object_columns oc
    ON o.name = oc.object_name 
        AND o.package_guid = oc.object_package_guid
WHERE ((p.capabilities is null or p.capabilities & 1 = 0)
  AND (o.capabilities is null or o.capabilities & 1 = 0)
  AND (oc.capabilities is null or oc.capabilities & 1 = 0))
  AND o.object_type = 'event'
  AND oc.column_type = 'customizable'


-- XE Packages
  SELECT 
   p.name,
   p.description,
   lm.name 
FROM sys.dm_xe_packages p
JOIN sys.dm_os_loaded_modules lm
   ON p.module_address = lm.base_address
WHERE (p.capabilities IS NULL OR p.capabilities & 1 = 0)
ORDER BY 1,2

-- Event objects
SELECT p.name AS package_name,
       o.name AS event_name,
       o.description
FROM sys.dm_xe_packages AS p
JOIN sys.dm_xe_objects AS o 
     ON p.guid = o.package_guid
WHERE (p.capabilities IS NULL OR p.capabilities & 1 = 0)
  AND (o.capabilities IS NULL OR o.capabilities & 1 = 0)
  AND o.object_type = 'event'
  ORDER BY 1,2

-- Actions
SELECT p.name AS package_name,
       o.name AS action_name,
       o.description
FROM sys.dm_xe_packages AS p
JOIN sys.dm_xe_objects AS o 
     ON p.guid = o.package_guid
WHERE (p.capabilities IS NULL OR p.capabilities & 1 = 0)
  AND (o.capabilities IS NULL OR o.capabilities & 1 = 0)
  AND o.object_type = 'action' 
ORDER BY 1,2

-- Targets
SELECT p.name AS package_name,
       o.name AS target_name,
       o.description
FROM sys.dm_xe_packages AS p
JOIN sys.dm_xe_objects AS o ON p.guid = o.package_guid
WHERE (p.capabilities IS NULL OR p.capabilities & 1 = 0)
  AND (o.capabilities IS NULL OR o.capabilities & 1 = 0)
  AND o.object_type = 'target'
  order by 1,2