 
 

--DELETE [dbaadmin].[dbo].FileScan_History	
SELECT T1.*	 
FROM	[dbaadmin].[dbo].FileScan_History T1
JOIN	[dbaadmin].[dbo].[FileScan_EVTLOG_EventFilter] T2
ON	T1.[KnownCondition] = T2.[KnownCondition]
AND	T1.SourceType = T2.[EventLog]
WHERE	EventType IN
			(
			0	-- Success
			,4	-- Information
			,8	-- Success Audit
			)
 OR	SourceName IN
			(
			'Kerberos'
			,'LSASRV'
			,'TermServDevices'
			,'Windows Update Agent'
			,'W32Time'
			,'SideBySide'
			,'Print'
			)
 OR	EventID IN	(
			0
			,3
			,8
			,10
			,107
			,1000
			,1005
			,1008
			,1010
			,1017
			,1021
			,25267
			,26009
			,9100
			,3024
			,560
			,577
			,861
			,1005
			,1008
			,1017
			,1024
			,2001
			,4099
			,5152
			,5157
			,5031
			,7024
			,17207
			,17806
			,529
			,531
			,537
			,560
			,680
			,5031
			,5159
			)


