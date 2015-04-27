USE [OperationsManager]
GO
DECLARE		@Time		DateTime
SELECT		@Time		= DATEADD(hour,-1,GetUTCdate())

;WITH		GroupMembersCTE				-- BASE GROUP OF COMPUTERS TO PULL 
			AS
			(
			SELECT		DISTINCT
						LOWER(TargetMonitoringObjectDisplayName) as [FQDN]
						,UPPER(COALESCE(PARSENAME(TargetMonitoringObjectDisplayName,4),PARSENAME(TargetMonitoringObjectDisplayName,3),PARSENAME(TargetMonitoringObjectDisplayName,2),PARSENAME(TargetMonitoringObjectDisplayName,1))) [MachineName]
						,TargetMonitoringObjectId [TopLevelHostEntityId]
			FROM		RelationshipGenericView 
			WHERE		isDeleted=0 
					AND	SourceMonitoringObjectDisplayName IN	( --WHICH SCOM GROUPS TO TO INCLUDE
																'SQL Computers'
																,'GYI-Group - BackofficeServers'
																,'GYI-G-WEB - EcommOps Servers'
																)
			)
			,PerformanceCountersCTE		-- BASE GROUP OF COUNTERS TO PULL
			AS
			(
			SELECT		DISTINCT
						GM.[FQDN]
						,GM.[MachineName]
						,R.RuleName
						,MP.MPFriendlyName
						,PS.PerformanceSourceInternalId
						,PS.BaseManagedEntityId AS ManagedEntityId
						,LTRIM(RTRIM(CASE WHEN MP.MPFriendlyName LIKE '%SQL%' THEN
						  REPLACE	(
								ObjectName
								,COALESCE	(
											REPLACE(PARSENAME(REPLACE(REPLACE(ObjectName,'.','~'),':','.'),4),'~','.')
											,REPLACE(PARSENAME(REPLACE(REPLACE(ObjectName,'.','~'),':','.'),3),'~','.')
											,REPLACE(PARSENAME(REPLACE(REPLACE(ObjectName,'.','~'),':','.'),2),'~','.')
											)+':'
								,''
								) ELSE ObjectName END)) AS ObjectName
						,LTRIM(RTRIM(PC.CounterName)) AS CounterName
						,LTRIM(RTRIM(CASE WHEN MP.MPFriendlyName LIKE '%SQL%' THEN
						  ISNULL(NULLIF(REPLACE('INST_'+REPLACE(REPLACE(REPLACE(REPLACE(COALESCE	(
											REPLACE(PARSENAME(REPLACE(REPLACE(ObjectName,'.','~'),':','.'),4),'~','.')
											,REPLACE(PARSENAME(REPLACE(REPLACE(ObjectName,'.','~'),':','.'),3),'~','.')
											,REPLACE(PARSENAME(REPLACE(REPLACE(ObjectName,'.','~'),':','.'),2),'~','.')
											)+':','SQLSERVER',''),'MSSQL$',''),' :',':'),': ',':'),'INST_:',':'),':'),'') ELSE '' END
						+ REPLACE(PS.PerfmonInstanceName,'_total',''))) AS InstanceName
						
			FROM		GroupMembersCTE GM								-- ONLY USE COUNTERS FOR GROUP MEMBERS						
			JOIN		dbo.BaseManagedEntity BME WITH(NOLOCK) 
					on	BME.[TopLevelHostEntityId] = GM.[TopLevelHostEntityId]
					AND	BME.IsDeleted = 0 			
			JOIN		dbo.PerformanceSource AS PS WITH (NOLOCK)
					ON	PS.[BaseManagedEntityId] = BME.[BaseManagedEntityId]
					--------------------------------------------------
					--------------------------------------------------
					--			FILTER SOURCE BY RULES
					--------------------------------------------------
					--------------------------------------------------
					JOIN		dbo.Rules AS R WITH(NOLOCK)
							ON	R.RuleId = PS.RuleId
							AND	R.RuleCategory IN('PerformanceCollection','Custom')
																		-- EXCLUDE SPECIFIC RULES
							AND	R.RuleName NOT LIKE 'Microsoft.SystemCenter.HealthService.%'
							AND	R.RuleName NOT LIKE 'Microsoft.Windows.InternetInformationServices.2008.LegacySMTPVirtualServer.%'
							AND	R.RuleName NOT LIKE 'Microsoft.Windows.InternetInformationServices.2008.LegacySMTPServer.%'
							AND	R.RuleName NOT LIKE 'Microsoft.Windows.InternetInformationServices.2003.SMTPVirtualServer.%'
							AND	R.RuleName NOT LIKE 'Microsoft.Windows.InternetInformationServices.2003.SMTPServer.%'
					--------------------------------------------------
					--------------------------------------------------
					--		FILTER SOURCE BY MANAGEMENT PACK
					--------------------------------------------------
					--------------------------------------------------
					JOIN		dbo.ManagementPack MP WITH(NOLOCK)										
							ON	MP.ManagementPackId = R.ManagementPackId
							AND MP.MPFriendlyName NOT IN	(			-- EXCLUDE SPECIFIC MANAGEMENT PACKS
															''
															,''
															,''
															)
			JOIN		dbo.PerformanceCounter AS PC WITH (NOLOCK)
					ON	PS.PerformanceCounterId = PC.PerformanceCounterId
					AND	PC.ObjectName NOT IN		(					-- EXCLUDE SPECIFIC OBJECT NAMES
													'Health Service'
													,'Health Service Management Groups'
													,'SMTP Server'
													,'VM Memory'
													,'VM Processor'
													,'vmStatsProvider'
													)
			)
			,PerformanceData		-- ACTUAL PERFORMANCE DATA
			AS
			(
			SELECT		PCV.[MachineName]
						,PCV.FQDN
						,PCV.RuleName
						,PCV.ObjectName
						,PCV.CounterName
						,PCV.InstanceName
						,PDV.TimeAdded as [TimeAdded]
						,PDV.TimeSampled as [Time] 
						,PDV.SampleValue as [Value]
			FROM		OperationsManager.[dbo].PerformanceDataAllView PDV WITH(NOLOCK)
			JOIN		PerformanceCountersCTE PCV WITH(NOLOCK) 
					ON	pdv.PerformanceSourceInternalId = pcv.PerformanceSourceInternalId
					AND pdv.TimeAdded > @Time
					AND pdv.SampleValue > 0
			)
SELECT		DISTINCT
			PD.[TimeAdded]
			,PD.[Time]
			,PD.[Value]
			,PD.[FQDN] [Server]
			,PD.[ObjectName]	
			,PD.[CounterName]
			,PD.[InstanceName]
FROM		PerformanceData PD
