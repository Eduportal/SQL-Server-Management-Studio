
----sp_executesql 
--DECLARE @TSQL VarChar(max)
--DECLARE @Results VarChar(MAX)
--SET @TSQL = 'dbcc page (5,1,3184962) with tableresults'
--declare @dbccpage table (
--     ParentObject sysname,
--     Object sysname,
--     Field sysname,
--     VALUE sysname)
--insert into @dbccpage
--     exec (@TSQL)
--select @Results = COALESCE(@Results + '|' + Field + ',' + VALUE,Field + ',' + VALUE)
--from @dbccpage
--where Field like 'Metadata:%'
--SELECT @Results

--SELECT * FROM [master].[sys].[dm_exec_requests]

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		*
			--, CASE	WHEN WR1 = 'Page' THEN 
			


FROM		(
			SELECT		[session_id]
						,[blocking_session_id]
						--,[request_id]
						,[start_time]
						,[status]
						,[command]
						--,[sql_handle]
						,(SELECT Text FROM ::fn_get_sql([sql_handle])) SQL_Text
						--,[statement_start_offset]
						--,[statement_end_offset]
						--,[plan_handle]
						,[database_id]
						,[user_id]
						--,[connection_id]
						,[wait_type]
						,[wait_time]
						,[last_wait_type]
						,[wait_resource]
						,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([wait_resource],'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),')',''),'(',''),']',''),'[',''),':',' '),1) WR1
						,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([wait_resource],'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),')',''),'(',''),']',''),'[',''),':',' '),2) WR2
						,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([wait_resource],'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),')',''),'(',''),']',''),'[',''),':',' '),3) WR3
						,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([wait_resource],'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),')',''),'(',''),']',''),'[',''),':',' '),4) WR4
						,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([wait_resource],'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),')',''),'(',''),']',''),'[',''),':',' '),5) WR5
						,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([wait_resource],'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),')',''),'(',''),']',''),'[',''),':',' '),6) WR6
						,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([wait_resource],'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),')',''),'(',''),']',''),'[',''),':',' '),7) WR7
						,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([wait_resource],'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),')',''),'(',''),']',''),'[',''),':',' '),8) WR8
						,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([wait_resource],'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),'  ',' '),')',''),'(',''),']',''),'[',''),':',' '),9) WR9
						,[open_transaction_count]
						,[open_resultset_count]
						,[transaction_id]
						,[context_info]
						,[percent_complete]
						,[estimated_completion_time]
						,[cpu_time]
						,[total_elapsed_time]
						,[scheduler_id]
						,[task_address]
						,[reads]
						,[writes]
						,[logical_reads]
						,[text_size]
						,[language]
						,[date_format]
						,[date_first]
						,[quoted_identifier]
						,[arithabort]
						,[ansi_null_dflt_on]
						,[ansi_defaults]
						,[ansi_warnings]
						,[ansi_padding]
						,[ansi_nulls]
						,[concat_null_yields_null]
						,[transaction_isolation_level]
						,[lock_timeout]
						,[deadlock_priority]
						,[row_count]
						,[prev_error]
						,[nest_level]
						,[granted_query_memory]
						,[executing_managed_code]
			FROM		[master].[sys].[dm_exec_requests]
			WHERE		[session_id] IN (SELECT [blocking_session_id] FROM [master].[sys].[dm_exec_requests] WHERE [blocking_session_id] > 0)
					OR	[blocking_session_id] > 0
			) Data	
			
exec sp_lock			
			
--kill 65			
--select * From sys.databases			

--use master;
----( 1 )
--alter database master set allow_snapshot_isolation OFF;
--sp_msforeachdb 'alter database ? set read_committed_snapshot OFF'
--dbcc useroptions

--select * from sys.dm_tran_version_store
				  
  --DROP TABLE #tempTS 
  --GO
  --CREATE TABLE #tempTS (theTS timestamp)
  --GO
  
  
  --select [EPOBranchNode].NodePath, [EPOBranchNode].NodeTextPath,          
  --[EPOEvents].AgentGUID, [EPOEvents].AutoID, ReceivedUTC, DetectedUTC, Analyzer,          
  --AnalyzerName, AnalyzerVersion, AnalyzerHostName, AnalyzerIPV4,          
  --AnalyzerIPV6, AnalyzerMAC, AnalyzerDATVersion,          
  --AnalyzerEngineVersion, AnalyzerDetectionMethod,          
  --SourceHostName, SourceIPV4, SourceIPV6, SourceMAC, SourceUserName,          
  --SourceProcessName, SourceURL, TargetHostName, TargetIPV4, TargetIPV6,          
  --TargetMAC, TargetUserName, TargetPort,          
  --TargetProtocol, TargetProcessName, TargetFileName, ThreatCategory,          
  --ThreatEventID, ThreatSeverity, ThreatName, ThreatType,          
  --ThreatActionTaken, ThreatHandled, OSType, OSPlatform,          
  --[EPOEventFilterDesc].Name          
  --from		EPOEvents          
  --LEFT JOIN EPOEventFilterDesc          
		--ON	(EPOEvents.ThreatEventID = EPOEventFilterDesc.EventId)          
  --INNER JOIN EPOLeafNode          
		--ON	(EPOEvents.AgentGUID = EPOLeafNode.AgentGUID)          
  --INNER JOIN EPOBranchNode          
		--ON	(EPOLeafNode.ParentID = EPOBranchNode.AutoID)          
  --LEFT JOIN	EPOComputerProperties          
		--ON	(EPOLeafNode.AutoID = EPOComputerProperties.ParentID)          
  --where		(
		--		EPOEvents.TheTimestamp <= (select theTS from #tempTS) 
		--	and EPOEvents.TheTimestamp > (select LastProcessedTimestamp from [dbo].[EPONotificationProcessed] where [Type] = N'epoThreatEvent')
		--	) 
		--and	(
		--		(
		--			(
		--				(
		--					[EPOEvents].[ThreatEventID] = N'1278' 
		--				) 
		--			and	(
		--					[EPOLeafNode].[ParentID] IN (SELECT [EndAutoID] FROM [EPOBranchNodeEnum] WHERE [StartAutoID] = N'2' UNION SELECT N'2')
		--				)
		--			) 
		--			or	(
		--					(
		--						(
		--						not (	[EPOEvents].[ThreatName] is null 
		--							or	ltrim( rtrim( [EPOEvents].[ThreatName] ) ) = '' 
		--							) 
		--						)  
		--						and	(
		--								[EPOEvents].[ThreatCategory] LIKE 'av%' 
		--							or	[EPOEvents].[ThreatCategory] LIKE 'mail%' 
		--							or	[EPOEvents].[ThreatCategory] LIKE 'nip%' 
		--							) 
		--						and	(
		--								[EPOEvents].[TargetFileName] not like N'%Volume%' 
		--							) 
		--						and	(
		--								(
		--									[EPOEvents].[ThreatType] <> N'app_adware' 
		--								) 
		--						and	(
		--								[EPOEvents].[ThreatType] <> N'app_pua'
		--							) 
		--						and	(
		--								[EPOEvents].[ThreatType] <> N'app_puo' 
		--							) 
		--						and	( 
		--								[EPOEvents].[ThreatType] <> N'app_puocookie' 
		--							) 
		--						and ( 
		--								[EPOEvents].[ThreatType] <> N'test' 
		--							) 
		--						and	( 
		--								[EPOEvents].[ThreatType] <> N'joke' 
		--							) 
		--						) 
		--					) 
		--				and ( 
		--						[EPOLeafNode].[ParentID] IN (SELECT [EndAutoID] FROM [EPOBranchNodeEnum] WHERE [StartAutoID] = N'2' 
		--														UNION 
		--														SELECT N'2')
		--					)  
		--				) 
		--			or	(
		--					( 
		--						( 
		--							[EPOEvents].[ThreatName] like N'%mailing%' 
		--						) 
		--					and	( 
		--							( 
		--								[EPOEvents].[TargetHostName] <> N'SEAWW5923' 
		--							) 
		--					and	( 
		--							[EPOEvents].[TargetHostName] <> N'SEAWW2042' 
		--						) 
		--					) 
		--				) 
		--			and	( 
		--					[EPOLeafNode].[ParentID] IN (SELECT [EndAutoID] FROM [EPOBranchNodeEnum] WHERE [StartAutoID] = N'2' UNION SELECT N'2')
		--				)  
		--			) 
  --or ( ( ( [EPOEvents].[ThreatName] like N'%mailing%' ) 
  --and ( ( [EPOEvents].[TargetHostName] not like N'%SEAWW2042%' ) 
  --and ( [EPOEvents].[TargetHostName] not like N'%SEAWW5923%' ) ) ) 
  --and  ( [EPOLeafNode].[ParentID] IN (SELECT [EndAutoID] FROM [EPOBranchNodeEnum] WHERE [StartAutoID] = N'84' UNION SELECT N'84'))  ) 
  --or ( ( ( not ( [EPOEvents].[ThreatName] is null or ltrim( rtrim( [EPOEvents].[ThreatName] ) ) = '' ) )  
  --and ( [EPOEvents].[ThreatCategory] LIKE 'av%' or [EPOEvents].[ThreatCategory] LIKE 'mail%' or [EPOEvents].[ThreatCategory] LIKE 'nip%' ) 
  --and ( [EPOEvents].[TargetFileName] not like N'%Volume%' ) and ( ( [EPOEvents].[ThreatType] <> N'app_adware' ) 
  --and ( [EPOEvents].[ThreatType] <> N'app_pua' ) and ( [EPOEvents].[ThreatType] <> N'app_puo' ) and ( [EPOEvents].[ThreatType] <> N'app_puocookie' ) 
  --and ( [EPOEvents].[ThreatType] <> N'test' ) ) ) and  ( [EPOLeafNode].[ParentID] IN (SELECT [EndAutoID] FROM [EPOBranchNodeEnum] WHERE [StartAutoID] = N'84' UNION SELECT N'84'))  ) 
  --or ( ( [EPOEvents].[ThreatName] like N'%mailing%' ) 
  --and  ( [EPOLeafNode].[ParentID] IN (SELECT [EndAutoID] FROM [EPOBranchNodeEnum] WHERE [StartAutoID] = N'94' UNION SELECT N'94'))  ) 
  --or ( ( ( not ( [EPOEvents].[ThreatName] is null or ltrim( rtrim( [EPOEvents].[ThreatName] ) ) = '' ) )  
  --and ( [EPOEvents].[ThreatCategory] LIKE 'av%' or [EPOEvents].[ThreatCategory] LIKE 'mail%' or [EPOEvents].[ThreatCategory] LIKE 'nip%' ) and ( [EPOEvents].[TargetFileName] not like N'%Volume%' ) 
  --and ( ( [EPOEvents].[ThreatType] <> N'app_adware' ) 
  --and ( [EPOEvents].[ThreatType] <> N'app_pua' ) and ( [EPOEvents].[ThreatType] <> N'app_puo' ) and ( [EPOEvents].[ThreatType] <> N'app_puocookie' ) and ( [EPOEvents].[ThreatType] <> N'test' ) ) ) 
  --and  ( [EPOLeafNode].[ParentID] IN (SELECT [EndAutoID] FROM [EPOBranchNodeEnum] WHERE [StartAutoID] = N'94' UNION SELECT N'94'))  ) or ( ( [EPOEvents].[ThreatName] like N'%mailing%' ) 
  --and  ( [EPOLeafNode].[ParentID] IN (SELECT [EndAutoID] FROM [EPOBranchNodeEnum] WHERE [StartAutoID] = N'158' UNION SELECT N'158'))  ) 
  --or ( ( ( not ( [EPOEvents].[ThreatName] is null or ltrim( rtrim( [EPOEvents].[ThreatName] ) ) = '' ) )  
  --and ( [EPOEvents].[ThreatCategory] LIKE 'av%' 
  --or [EPOEvents].[ThreatCategory] LIKE 'mail%' or [EPOEvents].[ThreatCategory] LIKE 'nip%' ) 
  --and ( [EPOEvents].[TargetFileName] not like N'%Volume%' ) and ( ( [EPOEvents].[ThreatType] <> N'app_adware' ) 
  --and ( [EPOEvents].[ThreatType] <> N'app_pua' ) and ( [EPOEvents].[ThreatType] <> N'app_puo' ) 
  --and ( [EPOEvents].[ThreatType] <> N'app_puocookie' ) and ( [EPOEvents].[ThreatType] <> N'test' ) ) ) 
  --and  ( [EPOLeafNode].[ParentID] IN (SELECT [EndAutoID] FROM [EPOBranchNodeEnum] WHERE [StartAutoID] = N'158' UNION SELECT N'158'))  ) 
  --or ( ( ( not ( [EPOEvents].[ThreatName] is null or ltrim( rtrim( [EPOEvents].[ThreatName] ) ) = '' ) )  
  --and ( [EPOEvents].[ThreatCategory] LIKE 'av%' 
  --or [EPOEvents].[ThreatCategory] LIKE 'mail%' or [EPOEvents].[ThreatCategory] LIKE 'nip%' ) 
  --and ( [EPOEvents].[TargetFileName] not like N'%Volume%' ) and ( ( [EPOEvents].[ThreatType] <> N'app_adware' ) 
  --and ( [EPOEvents].[ThreatType] <> N'app_pua' ) and ( [EPOEvents].[ThreatType] <> N'app_puo' ) 
  --and ( [EPOEvents].[ThreatType] <> N'app_puocookie' ) and ( [EPOEvents].[ThreatType] <> N'test' ) ) ) 
  --and  ( [EPOLeafNode].[ParentID] IN (SELECT [EndAutoID] FROM [EPOBranchNodeEnum] WHERE [StartAutoID] = N'165' UNION SELECT N'165'))  ) 
  --or ( ( [EPOEvents].[ThreatName] like N'%mailing%' ) 
  --and  ( [EPOLeafNode].[ParentID] IN (SELECT [EndAutoID] FROM [EPOBranchNodeEnum] WHERE [StartAutoID] = N'128' UNION SELECT N'128'))  ) 
  --or ( ( ( not ( [EPOEvents].[ThreatName] is null or ltrim( rtrim( [EPOEvents].[ThreatName] ) ) = '' ) )  
  --and ( [EPOEvents].[ThreatCategory] LIKE 'av%' or [EPOEvents].[ThreatCategory] LIKE 'mail%' or [EPOEvents].[ThreatCategory] LIKE 'nip%' ) 
  --and ( [EPOEvents].[TargetFileName] not like N'%Volume%' ) and ( ( [EPOEvents].[ThreatType] <> N'app_adware' ) and ( [EPOEvents].[ThreatType] <> N'app_pua' ) 
  --and ( [EPOEvents].[ThreatType] <> N'app_puo' ) and ( [EPOEvents].[ThreatType] <> N'app_puocookie' ) and ( [EPOEvents].[ThreatType] <> N'test' ) ) ) 
  --and  ( [EPOLeafNode].[ParentID] IN (SELECT [EndAutoID] FROM [EPOBranchNodeEnum] WHERE [StartAutoID] = N'128' UNION SELECT N'128'))  ) 
  --or ( ( [EPOEvents].[ThreatName] like N'%mailing%' ) and  ( [EPOLeafNode].[ParentID] IN (SELECT [EndAutoID] FROM [EPOBranchNodeEnum] WHERE [StartAutoID] = N'136' UNION SELECT N'136'))  ) 
  --or ( ( ( not ( [EPOEvents].[ThreatName] is null or ltrim( rtrim( [EPOEvents].[ThreatName] ) ) = '' ) )  and ( [EPOEvents].[ThreatCategory] LIKE 'av%' 
  --or [EPOEvents].[ThreatCategory] LIKE 'mail%' or [EPOEvents].[ThreatCategory] LIKE 'nip%' ) and ( [EPOEvents].[TargetFileName] not like N'%Volume%' ) 
  --and ( ( [EPOEvents].[ThreatType] <> N'app_adware' ) 
  --and ( [EPOEvents].[ThreatType] <> N'app_pua' ) 
  --and ( [EPOEvents].[ThreatType] <> N'app_puo' ) 
  --and ( [EPOEvents].[ThreatType] <> N'app_puocookie' ) 
  --and ( [EPOEvents].[ThreatType] <> N'test' ) ) ) 
  --and  ( [EPOLeafNode].[ParentID] IN (SELECT [EndAutoID] FROM [EPOBranchNodeEnum] WHERE [StartAutoID] = N'136' UNION SELECT N'136'))  ) or ( ( [EPOEvents].[ThreatName] like N'%mailing%' ) 
  --and  ( [EPOLeafNode].[ParentID] IN (SELECT [EndAutoID] FROM [EPOBranchNodeEnum] WHERE [StartAutoID] = N'165' UNION SELECT N'165'))  )) 
  --and (EPOEventFilterDesc.Language = '0409' or EPOEventFilterDesc.EventId is null))