DECLARE @Data		Table	(
				[EventID] [int] NULL,
				[KnownCondition] VarChar(50)
				)
DECLARE @Data1		Table	(
				[EventLog] [varchar](255) NULL,
				[EventID] [int] NULL,
				[KnownCondition] VarChar(50),
				[EventType] [int] NULL,
				[EventTypeName] [varchar](255) NULL,
				[EventCategory] [int] NULL,
				[EventCategoryName] [varchar](255) NULL,
				[SourceName] [varchar](255) NULL
				)

INSERT INTO	@Data1
SELECT		DISTINCT
		[EventLog]
		,[EventID]
		,'Unknown'
		,[EventType]
		,[EventTypeName]
		,[EventCategory]
		,CASE	WHEN [EventCategoryName] LIKE 'The name for%' THEN 'None' 
			ELSE [EventCategoryName] END
		,CASE	WHEN [SourceName] LIKE 'MSSQL$%' THEN 'MSSQLSERVER' 
			WHEN [SourceName] LIKE 'SqlAgent$%' THEN 'SQLSERVERAGENT'
			WHEN [SourceName] LIKE '%Noetix%' THEN 'Noetix'
			WHEN [SourceName] LIKE '%Talisma%' THEN 'Talisma'
			ELSE [SourceName] END
FROM		[dbaadmin].[dbo].[FilescanImport_CurrentWorkTable_ServerEvent]
WHERE		SourceName Like '%SQL%' 
	OR	EventType IN (1,16)
ORDER BY	1,2,4,6




INSERT INTO @Data (EventID,KnownCondition) SELECT 0 ,'Generic Error'                                                                              
INSERT INTO @Data (EventID,KnownCondition) SELECT 3 ,'Admin Connection is not Valid'                                                              
INSERT INTO @Data (EventID,KnownCondition) SELECT 8 ,'Windows Update Failures'                                                                    
INSERT INTO @Data (EventID,KnownCondition) SELECT 10 ,'WinMgmt'                                                                                    
INSERT INTO @Data (EventID,KnownCondition) SELECT 107 ,'LDAP Failure'                                                                               
INSERT INTO @Data (EventID,KnownCondition) SELECT 208 ,'Agent Job Failure'                                                                          
INSERT INTO @Data (EventID,KnownCondition) SELECT 265 ,'No Valid License'                                                                           
INSERT INTO @Data (EventID,KnownCondition) SELECT 267 ,'Connection to repository failed'                                                            
INSERT INTO @Data (EventID,KnownCondition) SELECT 318 ,'Unable to read local eventlog'                                                              
INSERT INTO @Data (EventID,KnownCondition) SELECT 333 ,'Registry I/O Failure'                                                                       
INSERT INTO @Data (EventID,KnownCondition) SELECT 439 ,'SUS20ClientDataStore'                                                                       
INSERT INTO @Data (EventID,KnownCondition) SELECT 529 ,'Login Failed'                                                                               
INSERT INTO @Data (EventID,KnownCondition) SELECT 531 ,'Login Failed'                                                                               
INSERT INTO @Data (EventID,KnownCondition) SELECT 537 ,'Login Failed'                                                                               
INSERT INTO @Data (EventID,KnownCondition) SELECT 560 ,'Security Failure Audit'                                                                     
INSERT INTO @Data (EventID,KnownCondition) SELECT 577 ,'Privilaged Use Audit'                                                                       
INSERT INTO @Data (EventID,KnownCondition) SELECT 680 ,'Login Failed'                                                                               
INSERT INTO @Data (EventID,KnownCondition) SELECT 861 ,'Firewall detected listening Red Gate'                                                       
INSERT INTO @Data (EventID,KnownCondition) SELECT 1000 ,'Generic Application Error'                                                                  
INSERT INTO @Data (EventID,KnownCondition) SELECT 1001 ,'Security policy cannot be propagated'                                                       
INSERT INTO @Data (EventID,KnownCondition) SELECT 1005 ,'Perflib Error'                                                                              
INSERT INTO @Data (EventID,KnownCondition) SELECT 1006 ,'Group Policy - Invalid Credentials'                                                         
INSERT INTO @Data (EventID,KnownCondition) SELECT 1008 ,'Perflib Error'                                                                              
INSERT INTO @Data (EventID,KnownCondition) SELECT 1010 ,'Perflib Error'                                                                              
INSERT INTO @Data (EventID,KnownCondition) SELECT 1017 ,'Perflib Error'                                                                              
INSERT INTO @Data (EventID,KnownCondition) SELECT 1021 ,'Perflib Error'                                                                              
INSERT INTO @Data (EventID,KnownCondition) SELECT 1023 ,'Instalation Failed'                                                                         
INSERT INTO @Data (EventID,KnownCondition) SELECT 1024 ,'DELL OMSA'                                                                                  
INSERT INTO @Data (EventID,KnownCondition) SELECT 1030 ,'Group Policy - Can Not Query'                                                               
INSERT INTO @Data (EventID,KnownCondition) SELECT 1053 ,'Access is denied'                                                                           
INSERT INTO @Data (EventID,KnownCondition) SELECT 2001 ,'Perflib Error'                                                                              
INSERT INTO @Data (EventID,KnownCondition) SELECT 3024 ,'Windows Update Failed'                                                                      
INSERT INTO @Data (EventID,KnownCondition) SELECT 4099 ,'Tivoli Storage Manager'                                                                     
INSERT INTO @Data (EventID,KnownCondition) SELECT 4373 ,'Service Pack installation failed. Access is denied'                                         
INSERT INTO @Data (EventID,KnownCondition) SELECT 5004 ,'McAfee Installation Corrupt. Uninstall, Use Microsoft Cleanup Utility, Reinstall'           
INSERT INTO @Data (EventID,KnownCondition) SELECT 5031 ,'Windows Firewall Blocked Application'                                                       
INSERT INTO @Data (EventID,KnownCondition) SELECT 5152 ,'Windows Filtering Platform Blocked Packet'                                                  
INSERT INTO @Data (EventID,KnownCondition) SELECT 5157 ,'Windows Filtering Platform Blocked Packet'                                                  
INSERT INTO @Data (EventID,KnownCondition) SELECT 5159 ,'Windows Filtering Platform blocked bind to local port'                                      
INSERT INTO @Data (EventID,KnownCondition) SELECT 7011 ,'Service Timeout'                                                                            
INSERT INTO @Data (EventID,KnownCondition) SELECT 7024 ,'Tivoli Storage Manager'                                                                     
INSERT INTO @Data (EventID,KnownCondition) SELECT 7034 ,'Service terminated unexpectedly'                                                            
INSERT INTO @Data (EventID,KnownCondition) SELECT 7886 ,'SQL Read Failure'                                                                           
INSERT INTO @Data (EventID,KnownCondition) SELECT 8193 ,'Volume Shadow Copy Service error'                                                           
INSERT INTO @Data (EventID,KnownCondition) SELECT 9100 ,'MOM Failure'                                                                                
INSERT INTO @Data (EventID,KnownCondition) SELECT 10005 ,'Instalation Failed'                                                                         
INSERT INTO @Data (EventID,KnownCondition) SELECT 10016 ,'DCOM Failure'                                                                               
INSERT INTO @Data (EventID,KnownCondition) SELECT 11920 ,'Service Failed To Start'                                                                    
INSERT INTO @Data (EventID,KnownCondition) SELECT 11922 ,'Product: Idera SQL diagnostic manager (x64)'                                                
INSERT INTO @Data (EventID,KnownCondition) SELECT 12291 ,'Package Failure'                                                                            
INSERT INTO @Data (EventID,KnownCondition) SELECT 17061 ,'67015|16|1|ProductCatalog Asset Warning'                                                    
INSERT INTO @Data (EventID,KnownCondition) SELECT 17207 ,'File Failure'                                                                               
INSERT INTO @Data (EventID,KnownCondition) SELECT 17806 ,'SSPI handshake failed'			                                                                
INSERT INTO @Data (EventID,KnownCondition) SELECT 18456 ,'Login Failed'                                                                               
INSERT INTO @Data (EventID,KnownCondition) SELECT 18452 ,'Login Failed'                                                                               
INSERT INTO @Data (EventID,KnownCondition) SELECT 25267 ,'MOM Failure'                                                                                
INSERT INTO @Data (EventID,KnownCondition) SELECT 26009 ,'MOM Failure'                                                                                

UPDATE		@Data1
	SET	KnownCondition = T2.KnownCondition
FROM		@Data1 T1
JOIN		@Data  T2
	ON	T1.EventID = T2.EventID
	
Select * 
INTO FileScan_EVTLOG_EventFilter
From @Data1	