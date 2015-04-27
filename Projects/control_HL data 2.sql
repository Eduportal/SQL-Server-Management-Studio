SELECT [domain]
  ,[SQLname]
  ,CASE [HandShake_Status]		WHEN 'in-work' THEN '1.png' 
				WHEN 'completed' THEN '2.png' 
				WHEN 'notify-dba' THEN '3.png' 
				ELSE '0.png' 
				END AS [HandShake_Status]
  ,CASE [HandShake_sql]		WHEN 'OK' THEN '2.png' 
				ELSE '1.png' 
				END AS [HandShake_sql]
  ,CASE [HandShake_agent]	WHEN 'OK' THEN '2.png' 
				ELSE '1.png' 
				END AS [HandShake_agent]
  ,CASE [HandShake_DEPLjobs]	WHEN 'OK' THEN '2.png' 
				ELSE '1.png' 
				END AS [HandShake_DEPLjobs]
  ,CASE [Setup_Status]		WHEN 'in-work' THEN '1.png' 
				WHEN 'completed' THEN '2.png' 
				WHEN 'notify-dba' THEN '3.png' 
				ELSE '0.png' 
				END AS [Setup_Status]
  ,CASE [Restore_Status]	WHEN 'in-work' THEN '1.png' 
				WHEN 'completed' THEN '2.png' 
				WHEN 'notify-dba' THEN '3.png' 
				ELSE '0.png' 
				END AS [Restore_Status]
  ,CASE [Deploy_Status]		WHEN 'in-work' THEN '1.png' 
				WHEN 'completed' THEN '2.png' 
				WHEN 'notify-dba' THEN '3.png' 
				ELSE '0.png' 
				END AS [Deploy_Status]
  ,CASE [End_Status]		WHEN 'in-work' THEN '1.png' 
				WHEN 'completed' THEN '2.png' 
				WHEN 'notify-dba' THEN '3.png' 
				ELSE '0.png' 
				END AS [End_Status]
  ,'file://\\'+LEFT([SQLname]+'\',CHARINDEX('\',[SQLname]+'\')-1)+'\'+REPLACE([SQLname],'\','$')+'_SQLjob_logs\' AS [LogPath]
select *
FROM [DEPLcontrol].[dbo].[control_HL]
WHERE [Gears_id] = 43461