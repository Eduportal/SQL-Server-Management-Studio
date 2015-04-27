--USE dbaperf
--GO

--IF OBJECT_ID (N'dbo.dbaudf_ReturnScommPerfCounters') IS NOT NULL
--    DROP FUNCTION dbo.dbaudf_ReturnScommPerfCounters
--GO

--CREATE FUNCTION dbo.dbaudf_ReturnScommPerfCounters
--			(
--			@Servers		VarChar(8000)
--			,@Counters		VarChar(8000)
--			)
--RETURNS TABLE
--AS RETURN
--(
--WITH		GroupMembersCTE				-- BASE GROUP OF COMPUTERS TO PULL 
--			AS
--			(
--			SELECT		DISTINCT
--						UPPER(COALESCE(PARSENAME(TargetMonitoringObjectDisplayName,4),PARSENAME(TargetMonitoringObjectDisplayName,3),PARSENAME(TargetMonitoringObjectDisplayName,2),PARSENAME(TargetMonitoringObjectDisplayName,1)))  as [ServerName]
--						,TargetMonitoringObjectId [TopLevelHostEntityId]
--			FROM		[OperationsManager].[dbo].[RelationshipGenericView] WITH(NOLOCK)
--			WHERE		isDeleted=0 
--					AND	SourceMonitoringObjectDisplayName IN	( --WHICH SCOM GROUPS TO TO INCLUDE
--																'SQL Computers'
--																,'GYI-Group - BackofficeServers'
--																,'GYI-G-WEB - EcommOps Servers'
--																)
--					AND	UPPER(COALESCE(PARSENAME(TargetMonitoringObjectDisplayName,4),PARSENAME(TargetMonitoringObjectDisplayName,3),PARSENAME(TargetMonitoringObjectDisplayName,2),PARSENAME(TargetMonitoringObjectDisplayName,1))) 
--						IN (SELECT LEFT([Item],CHARINDEX('\',[Item]+'\')-1) FROM dbaadmin.dbo.fn_Split(@Servers,',')) 
--			) 
--			,PerformanceCountersCTE		-- BASE GROUP OF COUNTERS TO PULL
--			AS
--			(
--			SELECT		DISTINCT
--						GM.[ServerName]
--						,PS.PerformanceSourceInternalId
--						,LTRIM(RTRIM(PC.CounterName))			AS CounterName
--			FROM		GroupMembersCTE GM								-- ONLY USE COUNTERS FOR GROUP MEMBERS						
--			JOIN		[OperationsManager].[dbo].BaseManagedEntity BME WITH(NOLOCK) 
--					on	BME.[TopLevelHostEntityId] = GM.[TopLevelHostEntityId]
--					AND	BME.IsDeleted = 0 			
--			JOIN		[OperationsManager].[dbo].PerformanceSource AS PS WITH (NOLOCK)
--					ON	PS.[BaseManagedEntityId] = BME.[BaseManagedEntityId]
--			JOIN		[OperationsManager].[dbo].PerformanceCounter AS PC WITH (NOLOCK)
--					ON	PS.PerformanceCounterId = PC.PerformanceCounterId
--			WHERE		PC.CounterName IN (SELECT LEFT([Item],CHARINDEX('\',[Item]+'\')-1) FROM dbaadmin.dbo.fn_Split(@Counters,','))
--			)
--			SELECT		PCV.ServerName
--						,PCV.CounterName
--						,PDV.TimeSampled as [Time] 
--						,PDV.SampleValue as [Value]
--			FROM		[OperationsManager].[dbo].PerformanceDataAllView PDV WITH(NOLOCK)
--			JOIN		PerformanceCountersCTE PCV WITH(NOLOCK) 
--					ON	pdv.PerformanceSourceInternalId = pcv.PerformanceSourceInternalId
--)
--GO
--IF OBJECT_ID (N'dbo.dbasp_ReturnScommPerfResults') IS NOT NULL
--    DROP PROCEDURE dbo.dbasp_ReturnScommPerfResults
--GO

--CREATE PROCEDURE dbo.dbasp_ReturnScommPerfResults
--			(
--			@Servers		sysname
--			,@Counters		sysname
--			,@Data			VarChar(max) OUT
--			)
--AS
--BEGIN
--	SELECT @Data = 
--	(STUFF((SELECT ',' + CONVERT(VarChar(50),[Time],120)+'='+CAST([Value] AS VarChar(50)) FROM dbaperf.dbo.dbaudf_ReturnScommPerfCounters(@Servers,@Counters)ORDER BY 1
--	FOR XML PATH(''), TYPE, ROOT).value('root[1]','nvarchar(max)'),1,1,'')) 
--END	
--GO

					
--SELECT		* 
--FROM		dbaperf.dbo.dbaudf_ReturnScommPerfCounters('G1SQLA\A,G1SQLB\B','Logins/sec');



--DECLARE		@Servers		VarChar(8000)
--			,@Counters		VarChar(8000)
--SELECT		@Servers		= 'G1SQLA\A,G1SQLB\B'
--			,@Counters		= 'Logins/sec,User Connections,Number of Deadlocks/sec,Buffer cache hit ratio,SQL Re-Compilations/sec,SQL SENDs/sec,Rows written,Rows read,Broker Transaction Rollbacks,Open Connection Count,Tasks Aborted/sec,Stored Procedures Invoked/sec,Lock Requests/sec,Transactions/sec,Message Fragment Sends/sec,Enqueued Transport Msgs/sec,Buffers spooled,Enqueued Messages/sec,Tasks Started/sec,SQL Compilations/sec,Task Limit Reached,Task Limit Reached/sec,Lock Timeouts/sec,Send I/Os/sec,Message Fragment Receives/sec,Lock Waits/sec,Receive I/Os/sec,SQL RECEIVEs/sec'



--GO
--DECLARE		@Data VarChar(max)
--EXEC		dbaperf.dbo.dbasp_ReturnScommPerfResults 'G1SQLA\A','Logins/sec,
--SELECT		@Data
--Go
