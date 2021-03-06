/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [alarm_id]
      ,[id]
      ,[source_id]
      ,[message]
      ,[topology_object_id]
      ,[is_cleared]
      ,[is_acknowledged]
      ,[cleared_time]
      ,[created_time]
      ,[severity]
      ,[cleared_by]
      ,[ack_time]
      ,[ack_by]
      ,[source_name]
      ,[rule_id]
      ,[user_defined_data]
      ,[auto_ack]
  FROM [foglight].[dbo].[alarm_alarm]
  WHERE [message] Like 'Cannot establish connection to SEAPCRMSQL1A%'
  ORDER BY [created_time]

--  WHERE topology_object_id = '8f1650ae-51ec-4af8-a020-105894b4f871'

DELETE [foglight].[dbo].[alarm_alarm]
  WHERE [message] Like 'Cannot establish connection to SEAPCRMSQL1A%'



   


  UPDATE [foglight].[dbo].[alarm_alarm]
	SET is_acknowledged = 1
		,ack_time = getdate()
		,ack_by = 'foglight'
  WHERE is_acknowledged = 0
  and	[message] Like 'Cannot establish connection to SEAPCRMSQL1A%'

    UPDATE [foglight].[dbo].[alarm_alarm]
	SET ack_time = getdate()
  WHERE is_acknowledged = 1
	and ack_time is null
  --and	[message] Like 'Cannot establish connection to SEADCPCSQLA%'

      UPDATE [foglight].[dbo].[alarm_alarm]
	SET ack_by = 'foglight'
  WHERE is_acknowledged = 1
	and ack_by is null
  --and	[message] Like 'Cannot establish connection to SEADCPCSQLA%'

      UPDATE [foglight].[dbo].[alarm_alarm]
	SET cleared_time = getdate()
  WHERE is_cleared = 1
	and cleared_time is null
 -- and	[message] Like 'Cannot establish connection to SEADCPCSQLA%'

      UPDATE [foglight].[dbo].[alarm_alarm]
	SET cleared_by = 'foglight'
  WHERE is_cleared = 1
	and cleared_by is null
  --and	[message] Like 'Cannot establish connection to SEADCPCSQLA%'




