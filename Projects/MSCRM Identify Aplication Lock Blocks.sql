--sp_whoisactive
--USE [Getty_Images_US_Inc__MSCRM]

GO


select		T1.resource_description
		,request_mode
		,request_status
		,SUM(T3.wait_duration_ms/1000.0/60.0/60.0) [BLOCKED_HR]
		,MAX(T2.wait_duration_ms/1000.0/60.0/60.0) [MAX_WAIT_HR]
		,MIN(T2.wait_duration_ms/1000.0/60.0/60.0) [MIN_WAIT_HR]
		,count(*)
From		sys.dm_tran_locks T1
LEFT JOIN	sys.dm_os_waiting_tasks T2
	ON	T1.request_session_id = T2.session_id
	AND	T1.request_status = 'WAIT'

LEFT JOIN	sys.dm_os_waiting_tasks T3
	ON	T1.request_session_id = T3.blocking_session_id
	AND	T1.request_status = 'GRANT'

WHERE		resource_type = 'APPLICATION'
	AND	ISNULL(T2.wait_duration_ms,0)+ISNULL(T3.wait_duration_ms,0) > 0
GROUP BY	T1.resource_description
		,request_mode
		,request_status

ORDER BY	1,2,3



SELECT		*
FROM    sys.dm_os_waiting_tasks AS wt
        JOIN sys.dm_exec_sessions AS s ON wt.session_id = s.session_id
WHERE   s.is_user_process = 1


SELECT		*
From		sys.dm_tran_locks
WHERE		resource_type = 'APPLICATION'


/*

0:[PhoneCall_6ae8d389-f282-e311-b85]:(2579568b)                                                                                                                                                                                                                 
0:[PhoneCall_9ee8d389-f282-e311-b85]:(c1a760b9)                                                                                                                                                                                                                 
0:[PhoneCall_a6e8d389-f282-e311-b85]:(07c32757)                                                                                                                                                                                                                 
0:[PhoneCall_1bf3d08f-f282-e311-b85]:(979a22af)                                                                                                                                                                                                                 
0:[PhoneCall_86e8d389-f282-e311-b85]:(8076b45f)     

*/